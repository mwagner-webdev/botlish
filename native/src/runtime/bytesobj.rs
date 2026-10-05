//! The owned byte storage behind `abi::bytes::Bytes` (ABI-BYTES.md): one heap
//! allocation holding the object header, the byte count and the bytes
//! themselves, contiguously.
//!
//! ```text
//!   offset  size  field
//!        0     8  hdr      Header { kind: KIND_BYTES, marked, is_static, pad }
//!        8     8  len      the exact byte count (never a scan, never a terminator)
//!       16     n  payload  the bytes, 16-byte aligned, no trailing NUL
//! ```
//!
//! There is no pointer inside the object: the payload is *inline*, so
//! "object -> pointer -> second allocation" does not occur (the one
//! allocation is `BYTES_PAYLOAD_OFFSET + len` bytes rounded up to
//! `BYTES_ALIGN`), and the address of the payload is the object's address
//! plus the constant `BYTES_PAYLOAD_OFFSET` whatever the length -- O(1), with
//! no read. The empty storage has a payload of zero bytes whose address is
//! the end of its own block (a valid, in-bounds-or-one-past address that is
//! never dereferenced because the count is zero).
//!
//! The same layout, with the header kind KIND_MUTBYTES, is the writable
//! storage behind `abi::bytes::MutableBytes` (MUTABLE-BYTES.md). It differs from
//! KIND_BYTES in one promise only: a KIND_BYTES object is never written after
//! it is published; a KIND_MUTBYTES object is written only while it is still
//! private to the one operation that created it (a fresh clone being updated,
//! or the clone `linux::read` hands the kernel), and from the moment that
//! operation returns it is, again, never written. So neither kind is ever
//! observed to change, which is why copying a value of either kind is plain
//! sharing. The collector marks and frees both the same way (no tracing).
//!
//! # Invariants
//!
//! * The payload holds no program value: the collector marks the object and
//!   never scans the bytes (heap.rs). Nothing here is a Botlish reference.
//! * The object never moves (the collector is non-moving) and is immutable
//!   once published: `BytesInit::finish` asserts every byte was written, so
//!   a published storage has no uninitialized byte. A raw address taken from
//!   it is therefore stable and readable for as long as the object is live.
//! * `len <= MAX_COLLECTION_LENGTH` (the runtime's enforced collection-length
//!   ceiling, checked before allocation by `Vm::alloc_bytes`), so the length
//!   always fits a small Int, hence `abi::Usize`.
//! * The allocation layout is computed in one place (`bytes_layout`) for
//!   allocation and for release, so a deallocation always passes the layout
//!   it was allocated with.
//!
//! # Construction sequence
//!
//! As for Strings (strobj.rs): (1) the collection that is due, if any, runs
//! *before* the object exists; (2) one allocation, header written, payload
//! uninitialized; (3) registration with the heap. Nothing between (3) and
//! `finish` allocates, so no collection can run while the payload is being
//! written. The source List a conversion reads is an operand of the
//! allocating instruction and therefore a root across step (1).

use super::value::{Header, KIND_BYTES, KIND_MUTBYTES};
use std::alloc::{Layout, alloc, dealloc, handle_alloc_error};
use std::mem::offset_of;
use std::ptr;

/// Where the payload starts, whatever the length.
pub const BYTES_PAYLOAD_OFFSET: usize = 16;
/// Alignment of the allocation, hence of the payload (its offset is a
/// multiple of it).
pub const BYTES_ALIGN: usize = 16;

#[repr(C)]
pub struct BytesObj {
    pub hdr: Header,
    pub len: usize,
}

pub const BYTES_LEN_OFFSET: i32 = offset_of!(BytesObj, len) as i32;

const _: () = assert!(std::mem::size_of::<BytesObj>() == BYTES_PAYLOAD_OFFSET);
const _: () = assert!(BYTES_PAYLOAD_OFFSET % BYTES_ALIGN == 0);
const _: () = assert!(offset_of!(BytesObj, hdr) == 0);

/// The layout of a storage of LEN payload bytes (header + payload, rounded up
/// to the alignment), or None if the size overflows what a `Layout` can
/// describe.
#[inline]
pub fn bytes_layout(len: usize) -> Option<Layout> {
    let size = BYTES_PAYLOAD_OFFSET.checked_add(len)?;
    Some(Layout::from_size_align(size, BYTES_ALIGN).ok()?.pad_to_align())
}

impl BytesObj {
    /// The byte count of the storage at address V.
    ///
    /// # Safety
    /// V must be the address of a live, fully constructed `BytesObj`.
    #[inline]
    pub unsafe fn len_of(v: u64) -> usize {
        unsafe { (*(v as *const BytesObj)).len }
    }

    /// The payload of the storage at address V.
    ///
    /// # Safety
    /// V must be the address of a live, fully constructed `BytesObj`, and the
    /// returned slice must not outlive it.
    #[inline]
    pub unsafe fn payload<'a>(v: u64) -> &'a [u8] {
        unsafe { std::slice::from_raw_parts((v as *const u8).add(BYTES_PAYLOAD_OFFSET), Self::len_of(v)) }
    }

    /// The writable payload of the MutableBytes storage at V.
    ///
    /// # Safety
    /// V must be the address of a live, fully constructed KIND_MUTBYTES
    /// object that no other reference is currently reading, and the returned
    /// slice must not outlive it. Used only on an object this very operation
    /// has just created (value semantics: a published storage is never
    /// written, MUTABLE-BYTES.md) -- every writer fills a fresh clone.
    #[inline]
    pub unsafe fn payload_mut<'a>(v: u64) -> &'a mut [u8] {
        unsafe { std::slice::from_raw_parts_mut((v as *mut u8).add(BYTES_PAYLOAD_OFFSET), Self::len_of(v)) }
    }

    /// The machine address of the first payload byte of the storage at V.
    #[inline]
    pub fn payload_address(v: u64) -> u64 {
        v + BYTES_PAYLOAD_OFFSET as u64
    }

    /// A static (program-lifetime, never collected, not heap-registered)
    /// storage holding BYTES: an installed constant (constants.rs).
    pub fn new_static(bytes: &[u8]) -> *mut Header {
        let mut init = BytesInit::new(bytes.len(), true);
        init.push_slice(bytes);
        init.finish() as *mut Header
    }

    /// The program-lifetime EMPTY writable storage (zero payload bytes: there
    /// is nothing in it any value could write or observe, so one shared
    /// object is unobservable, unlike a non-empty one).
    pub fn new_static_mutable_empty() -> *mut Header {
        BytesInit::new_kind(KIND_MUTBYTES, 0, true).finish() as *mut Header
    }
}

/// A freshly allocated storage whose header is complete and whose payload is
/// being written: the only way to create one. The payload is written strictly
/// front to back, each write bounds-checked, and `finish` asserts that every
/// byte was written (no uninitialized byte is ever published).
pub struct BytesInit {
    thin: *mut u8,
    len: usize,
    written: usize,
}

impl BytesInit {
    /// Allocates the one block for LEN payload bytes and writes its header.
    /// `is_static` marks a program-lifetime object (never collected).
    pub fn new(len: usize, is_static: bool) -> BytesInit {
        Self::new_kind(KIND_BYTES, len, is_static)
    }

    /// As `new`, for a storage of KIND: KIND_BYTES (immutable `abi::bytes::Bytes`
    /// storage) or KIND_MUTBYTES (the writable `abi::bytes::MutableBytes` storage,
    /// MUTABLE-BYTES.md). The two kinds have one layout; only the header's
    /// kind differs, and nothing ever changes a published object's kind.
    pub fn new_kind(kind: u8, len: usize, is_static: bool) -> BytesInit {
        match Self::try_new_kind(kind, len, is_static) {
            Some(init) => init,
            None => match bytes_layout(len) {
                Some(layout) => handle_alloc_error(layout),
                None => panic!("capacity overflow: a {len}-byte Bytes cannot be allocated"),
            },
        }
    }

    /// As `new_kind`, but None when the block cannot be allocated (a layout
    /// that overflows, or the allocator refusing): a MutableBytes length is
    /// program input (abi::bytes::zeroed(n)), so exhaustion is a reportable
    /// error there, not an abort.
    pub fn try_new_kind(kind: u8, len: usize, is_static: bool) -> Option<BytesInit> {
        assert!(kind == KIND_BYTES || kind == KIND_MUTBYTES, "not a byte storage kind: {kind}");
        let layout = bytes_layout(len)?;
        // SAFETY: the layout has nonzero size (BYTES_PAYLOAD_OFFSET at least).
        let thin = unsafe { alloc(layout) };
        if thin.is_null() {
            return None;
        }
        // SAFETY: THIN is a fresh block of at least BYTES_PAYLOAD_OFFSET + len
        // bytes aligned to 16; the writes stay inside the header.
        unsafe {
            (thin as *mut Header).write(Header::new(kind, is_static));
            (thin.add(offset_of!(BytesObj, len)) as *mut usize).write(len);
        }
        Some(BytesInit { thin, len, written: 0 })
    }

    /// The object's address (what a `Value` holds).
    #[inline]
    pub fn addr(&self) -> u64 {
        self.thin as u64
    }

    /// Appends one byte.
    #[inline]
    pub fn push(&mut self, b: u8) {
        assert!(self.written < self.len, "Bytes payload write out of bounds");
        // SAFETY: in bounds (checked): the block holds BYTES_PAYLOAD_OFFSET + len bytes.
        unsafe { self.thin.add(BYTES_PAYLOAD_OFFSET + self.written).write(b) };
        self.written += 1;
    }

    /// Appends the whole slice.
    #[inline]
    pub fn push_slice(&mut self, bytes: &[u8]) {
        assert!(bytes.len() <= self.len - self.written, "Bytes payload write out of bounds");
        // SAFETY: room checked; the new block cannot overlap BYTES.
        unsafe {
            ptr::copy_nonoverlapping(bytes.as_ptr(), self.thin.add(BYTES_PAYLOAD_OFFSET + self.written), bytes.len());
        }
        self.written += bytes.len();
    }

    /// Appends COUNT zero bytes.
    #[inline]
    pub fn push_zeros(&mut self, count: usize) {
        assert!(count <= self.len - self.written, "Bytes payload write out of bounds");
        // SAFETY: room checked; the destination is inside the block.
        unsafe { ptr::write_bytes(self.thin.add(BYTES_PAYLOAD_OFFSET + self.written), 0, count) };
        self.written += count;
    }

    /// Publishes the storage: every payload byte must have been written.
    #[inline]
    pub fn finish(self) -> u64 {
        assert_eq!(self.written, self.len, "Bytes payload not fully written");
        self.addr()
    }
}

/// Releases the storage at ADDR (static or dynamic): one deallocation with
/// the layout it was allocated with. No Rust destructor runs (the object owns
/// nothing else).
///
/// # Safety
/// ADDR must be a storage created by `BytesInit` and not yet released.
#[inline]
pub unsafe fn free_bytes(addr: *mut Header) {
    unsafe {
        let len = BytesObj::len_of(addr as u64);
        dealloc(addr as *mut u8, Layout::from_size_align_unchecked(BYTES_PAYLOAD_OFFSET + len, BYTES_ALIGN).pad_to_align());
    }
}

/// Bytes the storage at ADDR occupies: header + payload (the accounting size).
///
/// # Safety
/// ADDR must be a live storage.
#[inline]
pub unsafe fn bytes_object_size(addr: *mut Header) -> usize {
    BYTES_PAYLOAD_OFFSET + unsafe { BytesObj::len_of(addr as u64) }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make(bytes: &[u8]) -> u64 {
        let mut init = BytesInit::new(bytes.len(), false);
        init.push_slice(bytes);
        init.finish()
    }

    #[test]
    fn layout_is_header_length_then_aligned_payload() {
        assert_eq!(BYTES_PAYLOAD_OFFSET, 16);
        assert_eq!(BYTES_ALIGN, 16);
        assert_eq!(offset_of!(BytesObj, len), 8);
        for n in [0usize, 1, 7, 8, 15, 16, 17, 255, 4096] {
            let layout = bytes_layout(n).unwrap();
            assert_eq!(layout.align(), 16);
            assert!(layout.size() >= 16 + n);
            assert_eq!(layout.size() % 16, 0);
        }
    }

    #[test]
    fn payload_round_trips_with_embedded_nul_and_high_bytes() {
        let data = [0x41u8, 0x00, 0x42, 0xff, 0x00];
        let v = make(&data);
        unsafe {
            assert_eq!(BytesObj::len_of(v), 5);
            assert_eq!(BytesObj::payload(v), &data);
            // O(1) address: the object address plus a constant, 16-aligned.
            assert_eq!(BytesObj::payload_address(v), v + 16);
            assert_eq!(BytesObj::payload_address(v) % 16, 0);
            assert_eq!(*(BytesObj::payload_address(v) as *const u8).add(3), 0xff);
            assert_eq!(bytes_object_size(v as *mut Header), 16 + 5);
            free_bytes(v as *mut Header);
        }
    }

    #[test]
    fn empty_storage_is_a_valid_object_with_a_one_past_payload_address() {
        let v = make(&[]);
        unsafe {
            assert_eq!(BytesObj::len_of(v), 0);
            assert!(BytesObj::payload(v).is_empty());
            let layout = bytes_layout(0).unwrap();
            // The payload address is the end of the block: legal for count 0.
            assert_eq!(BytesObj::payload_address(v), v + layout.size() as u64);
            free_bytes(v as *mut Header);
        }
    }

    #[test]
    #[should_panic(expected = "not fully written")]
    fn publishing_a_partly_written_payload_is_refused() {
        let mut init = BytesInit::new(3, false);
        init.push(1);
        init.finish();
    }
}
