//! The canonical native String object: one heap allocation holding the object
//! header, the String's metadata and its UTF-8 bytes (STRING-ALLOCATION.md).
//!
//! ```text
//!   offset  size  field
//!        0     8  hdr        Header { kind, marked, is_static, pad }
//!        8     8  chars      semantic length: Unicode scalar values
//!       16     8  byte_len   UTF-8 length in bytes (== text.len())
//!       24     1  ascii      every byte < 0x80 (then chars == byte_len)
//!       25     n  text       the UTF-8 bytes, no terminator
//! ```
//!
//! There is no cached first scalar: a String's first character is read from
//! its inline text (STRING-ALLOCATION.md measured both; recovering it is the
//! cheaper design once the text is inline).
//!
//! `StrObj` is a custom dynamically sized type: a `#[repr(C)]` header whose
//! last field is the unsized `[u8]` tail. A `&StrObj` is therefore a wide
//! reference (address + byte length) whose provenance covers header *and*
//! text, so reading the text through it is ordinary safe Rust, with no pointer
//! arithmetic outside this module. Generated code and the garbage collector
//! only ever hold the thin tagged `Value` (the object's address); the wide
//! pointer is rebuilt from the stored `byte_len` (`StrObj::from_value`).
//!
//! # Layout invariants (pinned by the tests at the end of this file)
//!
//! * `STR_HEADER_SIZE == STR_TEXT_OFFSET == 25`: the sized prefix is exactly
//!   25 bytes (the last field, `ascii`, ends at 25) and the text starts right
//!   behind it. Rust gives no offset for an unsized tail (`offset_of!` rejects
//!   it), so the constant is stated here and asserted against the prefix's
//!   last field below. The text is `[u8]`, alignment 1: it needs no padding,
//!   so the header is not rounded up to the object's 8-byte alignment.
//! * The allocation is `STR_TEXT_OFFSET + byte_len` bytes rounded up to a
//!   multiple of `STR_ALIGN == 8` (the header's alignment: it holds `usize`
//!   fields), aligned to 8. The rounding is what makes the wide reference
//!   sound: `size_of_val(&StrObj)` of a struct with an unsized tail is rounded
//!   up to the alignment, so the block must be at least that big or the
//!   reference would claim bytes past it. (It costs nothing with a size-class
//!   allocator: glibc's chunk size is the same with and without it.) The
//!   *accounted* size of a String stays the logical `STR_TEXT_OFFSET +
//!   byte_len`.
//!   The same `str_layout(byte_len)` computes it for allocation and for
//!   release, so a deallocation always passes the layout it was allocated
//!   with. `Layout::from_size_align` rejects any size that, rounded up to the
//!   alignment, exceeds `isize::MAX`, and the addition is checked: a request
//!   that cannot be represented is the same allocation failure a too-large
//!   `Vec` was before (a panic with "capacity overflow"-style text); the
//!   language-level limit (`MAX_COLLECTION_LENGTH` characters, RANGE) is
//!   checked before any allocation, exactly as it was.
//! * `byte_len` is stored in the object, so the byte length never needs a
//!   scan, and `text.len() == byte_len` always; `chars` is the cached
//!   semantic length (`length(s)` is a field read); `ascii` implies
//!   `chars == byte_len` and the converse holds (every scalar is one byte iff
//!   every byte is < 0x80), which is how a constructor that knows the two
//!   counts derives the flag without scanning.
//! * The text is valid UTF-8 for the whole life of the object: every
//!   constructor in this module either copies from a `&str` or writes whole
//!   encoded scalars, and the object is immutable once published.
//! * The text holds no Value: the collector marks the object and never scans
//!   the bytes.
//!
//! # Construction sequence
//!
//! `alloc_str` (vm.rs) performs, in this order: (1) the collection that is
//! due, if any -- *before* the object exists, so a collection can never see a
//! half-built String; (2) the single allocation, with the header fully written
//! (`kind`, `chars`, `byte_len`, `ascii`) and the tail uninitialized; (3)
//! registration with the heap. Nothing between (3) and the end of the
//! constructor allocates, so no collection can run while the tail is still
//! being written; the writer then fills every tail byte. The operands a
//! constructor reads (the pieces of a concatenation, a substring's base) are
//! operands of an allocating instruction and therefore GC roots at that
//! safepoint (codegen::roots: a call's arguments are in its own live-in set),
//! so they survive the collection in step (1) and are still readable in the
//! fill.

use super::value::{Header, KIND_STR};
use std::alloc::{Layout, alloc, dealloc, handle_alloc_error};
use std::mem::offset_of;
use std::ptr;

/// Size of the sized prefix (header + metadata); also where the text starts.
pub const STR_HEADER_SIZE: usize = 25;
/// Offset of the UTF-8 bytes within the object.
pub const STR_TEXT_OFFSET: usize = 25;
/// Alignment of the allocation (the header's; the text needs none).
pub const STR_ALIGN: usize = 8;
/// The smallest a String allocation can be: the header, no text.
pub const STR_MIN_ALLOC: usize = STR_TEXT_OFFSET;

#[repr(C)]
pub struct StrObj {
    pub hdr: Header,
    /// Number of characters (Unicode scalar values).
    pub chars: usize,
    /// UTF-8 length in bytes; equal to `text.len()`. Stored so the wide
    /// pointer can be rebuilt from the thin tagged Value.
    pub byte_len: usize,
    pub ascii: bool,
    text: [u8],
}

pub const STR_CHARS_OFFSET: i32 = offset_of!(StrObj, chars) as i32;
pub const STR_BYTE_LEN_OFFSET: i32 = offset_of!(StrObj, byte_len) as i32;
pub const STR_ASCII_OFFSET: i32 = offset_of!(StrObj, ascii) as i32;

// The text starts exactly where the sized prefix ends, 8-byte aligned.
const _: () = assert!(offset_of!(StrObj, ascii) + 1 == STR_TEXT_OFFSET);
const _: () = assert!(STR_TEXT_OFFSET == STR_HEADER_SIZE);
const _: () = assert!(offset_of!(StrObj, hdr) == 0);
const _: () = assert!(std::mem::align_of::<Header>() <= STR_ALIGN);

/// The layout of a String allocation with BYTE_LEN text bytes (header + text,
/// rounded up to the alignment), or None if the size overflows or exceeds what
/// a `Layout` can describe. The one place the allocation size is computed
/// (allocation and release both use it).
#[inline]
pub fn str_layout(byte_len: usize) -> Option<Layout> {
    let size = STR_TEXT_OFFSET.checked_add(byte_len)?;
    // `from_size_align` rejects a size that rounded up to the alignment would
    // exceed isize::MAX, so the padding below cannot overflow.
    Some(Layout::from_size_align(size, STR_ALIGN).ok()?.pad_to_align())
}

impl StrObj {
    /// The String object at address V (a thin pointer to a live String).
    ///
    /// # Safety
    /// V must be the address of a live, fully constructed `StrObj`.
    #[inline]
    pub unsafe fn from_addr<'a>(v: u64) -> &'a StrObj {
        unsafe { &*Self::wide(v as *mut u8) }
    }

    /// The wide pointer for the String at THIN, reading its stored byte
    /// length. The address is kept as-is (provenance of the caller's pointer).
    #[inline]
    unsafe fn wide(thin: *mut u8) -> *mut StrObj {
        let byte_len = unsafe { *(thin.add(STR_BYTE_LEN_OFFSET as usize) as *const usize) };
        ptr::slice_from_raw_parts_mut(thin, byte_len) as *mut StrObj
    }

    /// The UTF-8 bytes.
    #[inline]
    pub fn as_bytes(&self) -> &[u8] {
        &self.text
    }

    /// The UTF-8 text as a borrowed `&str`: sound because every constructor
    /// establishes valid UTF-8 and the object is immutable afterwards.
    #[inline]
    pub fn as_str(&self) -> &str {
        // SAFETY: see the module's "Layout invariants": the text is valid
        // UTF-8 for the object's whole life.
        unsafe { std::str::from_utf8_unchecked(&self.text) }
    }

    /// The text's first byte address: the object's address plus
    /// `STR_TEXT_OFFSET`, whatever the length (the one accessor generated
    /// code's constant offset mirrors).
    #[inline]
    pub fn text_ptr(&self) -> *const u8 {
        self.text.as_ptr()
    }

    /// UTF-8 length in bytes (no scan).
    #[inline]
    pub fn len_bytes(&self) -> usize {
        self.byte_len
    }

    /// The packed-ASCII word of this String (value.rs: byte i = 0x80 | c, absent
    /// bytes 0), which the compiler proved ASCII with at most eight
    /// characters: one or two loads from the inline text that never leave it,
    /// an OR and a mask, no loop and no overread.
    #[inline]
    pub fn packed_ascii(&self) -> u64 {
        debug_assert!(self.ascii && self.byte_len <= 8, "packed ASCII of a String that is not ASCII of at most 8 characters");
        let n = self.byte_len;
        let mask = if n >= 8 { u64::MAX } else { (1u64 << (8 * n)) - 1 };
        // SAFETY: the text is `n` bytes long, so reading its first `n` (<= 8) is in bounds.
        (unsafe { read_low_bytes(self.text.as_ptr(), n) } | 0x8080_8080_8080_8080) & mask
    }

    /// The first scalar of the String (0 if empty), read from the inline text.
    #[inline]
    pub fn first_scalar(&self) -> u32 {
        first_scalar(&self.text, self.ascii)
    }
}

/// The scalar value of `text`'s first character (0 if empty); ASCII is the
/// caller's already-known `text.is_ascii()`.
#[inline]
pub fn first_scalar(text: &[u8], ascii: bool) -> u32 {
    match text.first() {
        None => 0,
        Some(b) if ascii => *b as u32,
        // SAFETY: String text is valid UTF-8 (module doc).
        Some(_) => unsafe { std::str::from_utf8_unchecked(text) }.chars().next().map_or(0, |c| c as u32),
    }
}

/// A freshly allocated String whose header is complete and whose text is being
/// written: the only way to create a String object. The text is written
/// strictly front to back, only by whole UTF-8 pieces (`push_str`,
/// `push_scalar`, `push_ascii`, `push_ascii_prefix`), each bounds-checked, and
/// `finish` asserts that every one of the `byte_len` bytes was written. So the
/// published text is a concatenation of valid UTF-8 pieces covering the whole
/// tail: valid UTF-8 with no uninitialized byte, whatever the caller does (the
/// invariant `StrObj::as_str` relies on is established here, by construction,
/// and no caller needs `unsafe`).
pub struct StrInit {
    thin: *mut u8,
    byte_len: usize,
    written: usize,
}

impl StrInit {
    /// Allocates the one block for a String of BYTE_LEN text bytes holding
    /// CHARS characters and writes its header; the text is empty so far.
    /// `is_static` marks a program-lifetime constant (never collected, not
    /// registered with the heap). Failure to allocate is the process's
    /// ordinary allocation-failure abort, as it was for the `Box` this
    /// replaces.
    pub fn new(byte_len: usize, chars: usize, ascii: bool, is_static: bool) -> StrInit {
        debug_assert!(ascii == (byte_len == chars), "ASCII flag disagrees with the counts");
        let Some(layout) = str_layout(byte_len) else {
            panic!("capacity overflow: a {byte_len}-byte String cannot be allocated");
        };
        // SAFETY: the layout has nonzero size (STR_TEXT_OFFSET bytes at least).
        let thin = unsafe { alloc(layout) };
        if thin.is_null() {
            handle_alloc_error(layout);
        }
        // SAFETY: THIN is a fresh block of at least STR_TEXT_OFFSET + byte_len
        // bytes, aligned to 8; the writes below stay inside the header.
        unsafe {
            (thin as *mut Header).write(Header::new(KIND_STR, is_static));
            (thin.add(offset_of!(StrObj, chars)) as *mut usize).write(chars);
            (thin.add(offset_of!(StrObj, byte_len)) as *mut usize).write(byte_len);
            thin.add(offset_of!(StrObj, ascii)).write(ascii as u8);
        }
        StrInit { thin, byte_len, written: 0 }
    }

    /// The object's address (what a `Value` holds).
    #[inline]
    pub fn addr(&self) -> u64 {
        self.thin as u64
    }

    /// The text position the next push writes at.
    #[inline]
    fn cursor(&mut self, n: usize) -> *mut u8 {
        assert!(n <= self.byte_len - self.written, "String text write out of bounds");
        // SAFETY: in bounds (checked): the block holds STR_TEXT_OFFSET + byte_len bytes.
        let at = unsafe { self.thin.add(STR_TEXT_OFFSET + self.written) };
        self.written += n;
        at
    }

    /// Appends the whole piece TEXT.
    #[inline]
    pub fn push_str(&mut self, text: &str) {
        let dst = self.cursor(text.len());
        // SAFETY: DST has room for TEXT.len() bytes (checked); the new block
        // cannot overlap TEXT.
        unsafe { ptr::copy_nonoverlapping(text.as_ptr(), dst, text.len()) };
    }

    /// Appends the UTF-8 encoding of scalar C, encoded straight into place (no
    /// intermediate buffer).
    #[inline]
    pub fn push_scalar(&mut self, c: char) {
        let dst = self.cursor(c.len_utf8());
        // SAFETY: DST has room for c.len_utf8() bytes (checked).
        unsafe { write_scalar(dst, c) };
    }

    /// Appends the one ASCII byte B (a lone byte of 0x80 or more could split a
    /// scalar, so it is not accepted).
    #[inline]
    pub fn push_ascii(&mut self, b: u8) {
        assert!(b < 0x80, "push_ascii of a non-ASCII byte");
        let dst = self.cursor(1);
        // SAFETY: one byte of room (checked).
        unsafe { dst.write(b) };
    }

    /// Appends the first N (0..=8) payload bytes of packed-ASCII WORD (the
    /// word masked to its 7-bit payload, so every byte is ASCII), with at most
    /// two stores and no call.
    #[inline]
    pub fn push_ascii_prefix(&mut self, word: u64, n: usize) {
        assert!(n <= 8, "a packed-ASCII word holds at most 8 bytes");
        let dst = self.cursor(n);
        // SAFETY: N bytes of room (checked); the payload mask keeps every byte below 0x80.
        unsafe { write_low_bytes(dst, word & 0x7F7F_7F7F_7F7F_7F7F, n) };
    }

    /// Publishes the String: every text byte must have been written.
    #[inline]
    pub fn finish(self) -> u64 {
        assert_eq!(self.written, self.byte_len, "String text not fully written");
        self.addr()
    }
}

/// Releases the String at ADDR (static or dynamic): one deallocation with the
/// layout it was allocated with. No Rust destructor runs (the object owns
/// nothing else).
///
/// # Safety
/// ADDR must be a String created by `StrInit` and not yet released.
#[inline]
pub unsafe fn free_str(addr: *mut Header) {
    unsafe {
        let byte_len = *((addr as *mut u8).add(STR_BYTE_LEN_OFFSET as usize) as *const usize);
        // The layout `StrInit::new` allocated with (it validated this exact
        // computation), so it is representable: no re-check on the free path.
        dealloc(addr as *mut u8, Layout::from_size_align_unchecked(STR_TEXT_OFFSET + byte_len, STR_ALIGN).pad_to_align());
    }
}

/// Bytes the String at ADDR occupies: header + text (the accounting size).
///
/// # Safety
/// ADDR must be a live String.
#[inline]
pub unsafe fn str_object_size(addr: *mut Header) -> usize {
    STR_TEXT_OFFSET + unsafe { *((addr as *mut u8).add(STR_BYTE_LEN_OFFSET as usize) as *const usize) }
}

/// Writes the low N (0..=8) bytes of WORD, little-endian, to DST with at most
/// two stores and no call: the packed-ASCII materialization's unpack.
///
/// # Safety
/// DST must be valid for N bytes of writes.
#[inline]
unsafe fn write_low_bytes(dst: *mut u8, word: u64, n: usize) {
    unsafe {
        if n >= 4 {
            if n >= 8 {
                (dst as *mut u64).write_unaligned(word.to_le());
            } else {
                // Two overlapping 4-byte stores cover 4..=7 bytes.
                (dst as *mut u32).write_unaligned((word as u32).to_le());
                (dst.add(n - 4) as *mut u32).write_unaligned(((word >> (8 * (n - 4))) as u32).to_le());
            }
        } else if n >= 2 {
            (dst as *mut u16).write_unaligned((word as u16).to_le());
            (dst.add(n - 2) as *mut u16).write_unaligned(((word >> (8 * (n - 2))) as u16).to_le());
        } else if n == 1 {
            dst.write(word as u8);
        }
    }
}

/// Reads N (0..=8) bytes from SRC as the low bytes of a little-endian word, the
/// rest zero, with at most two loads that stay inside `SRC[..N]`: the inverse
/// of `write_low_bytes`, used to pack an inline text of at most eight bytes
/// without a byte loop and without ever reading past the text.
///
/// # Safety
/// SRC must be valid for N bytes of reads.
#[inline]
unsafe fn read_low_bytes(src: *const u8, n: usize) -> u64 {
    unsafe {
        if n >= 4 {
            if n >= 8 {
                u64::from_le((src as *const u64).read_unaligned())
            } else {
                // Two overlapping 4-byte loads cover 4..=7 bytes.
                let lo = u32::from_le((src as *const u32).read_unaligned()) as u64;
                let hi = u32::from_le((src.add(n - 4) as *const u32).read_unaligned()) as u64;
                lo | (hi << (8 * (n - 4)))
            }
        } else if n >= 2 {
            let lo = u16::from_le((src as *const u16).read_unaligned()) as u64;
            let hi = u16::from_le((src.add(n - 2) as *const u16).read_unaligned()) as u64;
            lo | (hi << (8 * (n - 2)))
        } else if n == 1 {
            src.read() as u64
        } else {
            0
        }
    }
}

/// UTF-8 encodes scalar C at DST (`c.len_utf8()` bytes), straight into the
/// destination: no intermediate buffer.
///
/// # Safety
/// DST must be valid for `c.len_utf8()` bytes of writes.
#[inline]
unsafe fn write_scalar(dst: *mut u8, c: char) {
    let c = c as u32;
    unsafe {
        if c < 0x80 {
            dst.write(c as u8);
        } else if c < 0x800 {
            dst.write(0xC0 | (c >> 6) as u8);
            dst.add(1).write(0x80 | (c & 0x3F) as u8);
        } else if c < 0x10000 {
            dst.write(0xE0 | (c >> 12) as u8);
            dst.add(1).write(0x80 | ((c >> 6) & 0x3F) as u8);
            dst.add(2).write(0x80 | (c & 0x3F) as u8);
        } else {
            dst.write(0xF0 | (c >> 18) as u8);
            dst.add(1).write(0x80 | ((c >> 12) & 0x3F) as u8);
            dst.add(2).write(0x80 | ((c >> 6) & 0x3F) as u8);
            dst.add(3).write(0x80 | (c & 0x3F) as u8);
        }
    }
}

impl StrObj {
    /// A program-lifetime String constant: the same one-block layout as a
    /// dynamic String, marked static (never collected, never registered with
    /// the heap, allocation-free at run time: the compiler emits it once into
    /// the constant table).
    pub fn new_static(text: &str) -> *mut Header {
        let ascii = text.is_ascii();
        let chars = if ascii { text.len() } else { text.chars().count() };
        let mut init = StrInit::new(text.len(), chars, ascii, true);
        init.push_str(text);
        init.finish() as *mut Header
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make(text: &str) -> *mut Header {
        StrObj::new_static(text)
    }

    fn obj<'a>(p: *mut Header) -> &'a StrObj {
        unsafe { StrObj::from_addr(p as u64) }
    }

    #[test]
    fn documented_layout() {
        assert_eq!(STR_HEADER_SIZE, 25);
        assert_eq!(STR_TEXT_OFFSET, 25);
        assert_eq!(STR_MIN_ALLOC, 25);
        assert_eq!(STR_ALIGN, 8);
        assert_eq!(offset_of!(StrObj, hdr), 0);
        assert_eq!(STR_CHARS_OFFSET, 8);
        assert_eq!(STR_BYTE_LEN_OFFSET, 16);
        assert_eq!(STR_ASCII_OFFSET, 24);
        assert_eq!(std::mem::size_of::<Header>(), 8);
    }

    #[test]
    fn layout_is_header_plus_text_aligned_to_eight() {
        for n in [0usize, 1, 2, 7, 8, 9, 15, 16, 17, 31, 32, 33, 63, 64, 65, 1000, 4095, 4096, 1 << 20] {
            let l = str_layout(n).unwrap();
            assert_eq!(l.size(), (25 + n).div_ceil(8) * 8, "{n}");
            assert_eq!(l.align(), 8);
            assert!(l.size() >= 25 + n && l.size() < 25 + n + 8);
        }
    }

    #[test]
    fn layout_overflow_is_rejected_not_wrapped() {
        assert!(str_layout(usize::MAX).is_none());
        assert!(str_layout(usize::MAX - 31).is_none());
        assert!(str_layout(isize::MAX as usize).is_none());
        // The largest representable size is isize::MAX rounded down to the
        // alignment: 2^63 - 8 (already a multiple of 8, so no padding there).
        assert_eq!(str_layout(isize::MAX as usize - 25 - 7).unwrap().size(), isize::MAX as usize - 7);
        assert!(str_layout(isize::MAX as usize - 25 - 6).is_none());
    }

    #[test]
    fn every_boundary_length_round_trips() {
        // The lengths around the alignment, the minimum size and 8-byte words.
        for n in [0usize, 1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 16, 17, 31, 32, 33, 63, 64, 65, 127, 128, 129, 1000, 65536, 1 << 20] {
            let text: String = (0..n).map(|i| (b'a' + (i % 26) as u8) as char).collect();
            let p = make(&text);
            let o = obj(p);
            assert_eq!(o.len_bytes(), n);
            assert_eq!(o.chars, n);
            assert!(o.ascii);
            assert_eq!(o.as_str(), text);
            assert_eq!(o.as_bytes().len(), n);
            // The text starts exactly STR_TEXT_OFFSET past the object.
            assert_eq!(o.text_ptr() as usize, p as usize + STR_TEXT_OFFSET);
            assert_eq!(unsafe { str_object_size(p) }, 25 + n);
            unsafe { free_str(p) };
        }
    }

    #[test]
    fn scalars_of_every_width_and_nul() {
        for (text, chars, bytes, ascii) in [
            ("", 0, 0, true),
            ("a", 1, 1, true),
            ("\0", 1, 1, true),
            ("\u{e9}", 1, 2, false),
            ("\u{2026}", 1, 3, false),
            ("\u{1f600}", 1, 4, false),
            ("\u{10ffff}", 1, 4, false),
            ("e\u{301}", 2, 3, false),
            ("a\u{e9}\u{2026}\u{1f600}z", 5, 11, false),
        ] {
            let p = make(text);
            let o = obj(p);
            assert_eq!((o.chars, o.len_bytes(), o.ascii), (chars, bytes, ascii), "{text:?}");
            assert_eq!(o.as_str(), text);
            unsafe { free_str(p) };
        }
        let nul = make("\0");
        assert_eq!(obj(nul).as_bytes(), &[0u8]);
        assert_eq!(obj(nul).chars, 1);
        unsafe { free_str(nul) };
    }

    #[test]
    fn scalar_writer_matches_the_standard_encoder() {
        for c in ['\0', 'a', '\u{7f}', '\u{80}', '\u{ff}', '\u{7ff}', '\u{800}', '\u{2026}', '\u{d7ff}', '\u{e000}', '\u{ffff}', '\u{10000}', '\u{1f600}', '\u{10ffff}'] {
            let mut buf = [0xAAu8; 6];
            unsafe { write_scalar(buf.as_mut_ptr(), c) };
            let mut std_buf = [0u8; 4];
            let expect = c.encode_utf8(&mut std_buf).as_bytes();
            assert_eq!(&buf[..expect.len()], expect, "{c:?}");
            // Nothing past the scalar was touched.
            assert!(buf[expect.len()..].iter().all(|b| *b == 0xAA), "{c:?}");
        }
    }

    #[test]
    fn low_byte_writer_touches_exactly_n_bytes() {
        let word = 0x0807_0605_0403_0201u64;
        for n in 0..=8usize {
            let mut buf = [0xAAu8; 10];
            unsafe { write_low_bytes(buf.as_mut_ptr(), word, n) };
            let expect = &word.to_le_bytes()[..n];
            assert_eq!(&buf[..n], expect, "n={n}");
            assert!(buf[n..].iter().all(|b| *b == 0xAA), "n={n}: wrote past the end");
        }
    }

    #[test]
    fn low_byte_reader_reads_exactly_n_bytes_and_inverts_the_writer() {
        let bytes = [0x11u8, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88];
        for n in 0..=8usize {
            // Exactly an n-byte buffer: a read past it would be caught by the
            // sanitizer-free check below (the result must not depend on later bytes).
            let exact: Vec<u8> = bytes[..n].to_vec();
            let got = unsafe { read_low_bytes(exact.as_ptr(), n) };
            let mut expect = 0u64;
            for (i, b) in exact.iter().enumerate() {
                expect |= (*b as u64) << (8 * i);
            }
            assert_eq!(got, expect, "n={n}");
            let mut round = [0u8; 8];
            unsafe { write_low_bytes(round.as_mut_ptr(), got, n) };
            assert_eq!(&round[..n], &exact[..], "n={n}");
        }
    }

    #[test]
    fn packed_ascii_of_the_inline_text_agrees_with_the_reference_packer() {
        for text in ["", "a", "ab", "abc", "abcd", "abcde", "abcdef", "abcdefg", "abcdefgh", "\0", "\0\0\0", "\u{7f}z"] {
            let p = make(text);
            assert_eq!(obj(p).packed_ascii(), super::super::value::pack_ascii(text.as_bytes()), "{text:?}");
            unsafe { free_str(p) };
        }
    }

    #[test]
    fn first_scalar_is_decoded_from_the_inline_text() {
        for (text, first) in [("", 0), ("a", 0x61), ("\0", 0), ("\u{e9}x", 0xe9), ("\u{2026}", 0x2026), ("\u{1f600}", 0x1f600), ("abc", 0x61)] {
            let p = make(text);
            assert_eq!(obj(p).first_scalar(), first, "{text:?}");
            unsafe { free_str(p) };
        }
    }

    #[test]
    fn static_flag_and_kind_are_in_the_header() {
        let p = make("x");
        unsafe {
            assert_eq!((*p).kind, KIND_STR);
            assert_eq!((*p).is_static, 1);
            assert_eq!((*p).marked, 0);
            free_str(p);
        }
    }

    #[test]
    #[should_panic(expected = "not fully written")]
    fn an_unfinished_text_cannot_be_published() {
        let mut init = StrInit::new(4, 4, true, false);
        init.push_str("abc");
        init.finish();
    }

    #[test]
    #[should_panic(expected = "out of bounds")]
    fn a_write_past_the_text_is_rejected() {
        let mut init = StrInit::new(2, 2, true, false);
        init.push_str("abc");
    }

    #[test]
    #[should_panic(expected = "non-ASCII")]
    fn a_lone_high_byte_is_rejected() {
        let mut init = StrInit::new(1, 1, true, false);
        init.push_ascii(0xC3);
    }

    #[test]
    fn pieces_compose_into_one_valid_text() {
        let mut init = StrInit::new(1 + 2 + 3 + 4 + 2 + 1, 6, false, false);
        init.push_ascii(b'a');
        init.push_scalar('\u{e9}');
        init.push_str("\u{2026}");
        init.push_scalar('\u{1f600}');
        init.push_ascii_prefix(0xE2E1, 2);
        init.push_ascii(b'z');
        let p = init.finish() as *mut Header;
        assert_eq!(obj(p).as_str(), "a\u{e9}\u{2026}\u{1f600}abz");
        unsafe { free_str(p) };
    }

    #[test]
    #[should_panic(expected = "capacity overflow")]
    fn impossible_size_is_an_allocation_failure() {
        let _ = StrInit::new(usize::MAX - 8, usize::MAX - 8, true, false);
    }
}
