//! Read-only native layout views (NATIVE-LAYOUT-VIEWS.md): the loads a
//! `NativeView[L]` field read lowers to, and the test fixture's native
//! memory.
//!
//! A native view is a C address word (value.rs: `(address << 4) | 0b1110`)
//! whose static type names a layout; nothing at run time knows the layout.
//! native/lower.tcl lowers each field read of one statically known layout to
//! one op with constant operands:
//!
//! * `nativeload %v %o %c` -- the Int encoded at address V + O by the scalar
//!   encoding C (the `binload` encoding word, ops.rs's `bin_encoding`), read
//!   with one unaligned load;
//! * `nativeloadptr %v %o %w` -- the C address word of the W-byte address
//!   stored at V + O (a pointer field: `ffi::c::Ptr[T]` or `FnPtr`), exactly
//!   the materialization of a C call's pointer result (codegen/clif.rs's
//!   `foreign_call`): an address the word cannot hold is a `NATIVE ADDRESS`
//!   failure, never truncated;
//! * `cptroffset %v %o` -- the address word V + O (a nested layout's view).
//!
//! The offsets are the layout's (hir/layouts.tcl validated every field inside
//! the layout's size), and a view is never null (the view constructor fails
//! with NativeViewNull first). Nothing here can know that the address is a
//! live allocation of the layout's size: that is the foreign interface's
//! contract, and a wrong address faults like the C code it stands for. These
//! helpers still refuse what they can see -- an operand that is no C address
//! word, the null address, a malformed encoding -- because no checked program
//! reaches them with one.
//!
//! `cptrfixturememory %b` is the test fixture's (core/cabi.tcl's
//! installTestFixture, `ffi_fixture::memory`): a fresh, never-freed native
//! copy of the bytes of the abi::bytes::Bytes B (a one-field struct over its
//! storage), 64-byte aligned, and its
//! address. Only that fixture native lowers to it.
//!
//! Native layout writes (NATIVE-LAYOUT-WRITES.md) are the same shape in the
//! other direction, each field write one op with constant operands:
//!
//! * `nativestore %e %o %c %v` -- the Int V written at address E + O (a
//!   `NativeEdit[L]`'s word) in encoding C: the value is encoded first
//!   (`binstore`'s encoder, ops.rs's `bin_encode`: a value outside the
//!   encoding is RANGE, and nothing is written), then one unaligned store of
//!   exactly the field's width -- never the enclosing record, its padding or
//!   a neighbouring field;
//! * `nativestoreptr %e %o %w %p` -- the W-byte address bits of the C
//!   address word P (a pointer the program already has: observed, not
//!   moved) written at E + O; a width that cannot hold the address is
//!   RANGE, never a truncation;
//! * `mbyteswrite %m %o %c %v`, `mbyteswriteptr %m %o %w %p` -- the same
//!   two encodings into byte storage: a FRESH copy of the writable storage M
//!   with the field's bytes replaced (MUTABLE-BYTES.md: a storage anyone can
//!   hold is never written), which is the result.
//!
//! A store is a plain store: no volatile, atomic or ordered access, no fence
//! -- ordinary memory whose synchronization is someone else's protocol. Every
//! store and every load is a helper call the code generator treats as
//! touching all memory, so none is merged, cached or reordered.
//!
//! `cptrfixturebytes %p %n` is the test fixture's oracle (`ffi_fixture::
//! memory_bytes`): the N bytes at the C address P as a List of Ints, copied
//! with no layout, so a native edit's effect can be checked byte for byte
//! by a reader that is not a view.

use super::error::RtError;
use super::value::*;
use super::vm::Vm;

#[inline]
fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

fn fail(p: *mut Vm, kind: &'static str, message: String) -> Value {
    vm(p).fail(RtError::Semantic { kind, message })
}

/// The non-null machine address the view operand V holds, plus the constant
/// offset O; CONTEXT names the operation in a failure.
fn view_address(p: *mut Vm, v: Value, offset: Value, context: &str) -> Result<usize, Value> {
    if !is_cptr(v) {
        let message = format!("{context}: expected a native view (a C address), got {}", super::show::show(v));
        return Err(fail(p, "TYPE", message));
    }
    if v == CPTR_NULL {
        return Err(fail(p, "RANGE", format!("{context}: a native view of the null address")));
    }
    let Some(o) = int_small(offset).filter(|o| *o >= 0) else {
        let message = format!("{context}: malformed field offset {}", super::show::int_text(offset));
        return Err(fail(p, "RANGE", message));
    };
    let base = cptr_address(v) as usize;
    match base.checked_add(o as usize) {
        Some(address) => Ok(address),
        None => Err(fail(p, "RANGE", format!("{context}: address 0x{base:x} + {o} overflows"))),
    }
}

/// `nativeload %v %o %c`: the Int at address V + O in encoding C.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_load(p: *mut Vm, view: Value, offset: Value, code: Value) -> Value {
    let address = match view_address(p, view, offset, "native view") {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let Some(encoding) = super::ops::bin_encoding(code) else {
        let message = format!("native view: malformed scalar encoding {}", super::show::int_text(code));
        return fail(p, "RANGE", message);
    };
    let width = encoding.width;
    let mut bytes = [0u8; 8];
    // SAFETY: the view's contract (NATIVE-LAYOUT-VIEWS.md, "Bounds and
    // lifetime"): the foreign interface that produced the address promises
    // live memory of the layout's size there, and the layout's validation put
    // this field inside that size. Unaligned: a layout may place a field at
    // any offset (a packed record).
    unsafe { std::ptr::copy_nonoverlapping(address as *const u8, bytes.as_mut_ptr(), width) };
    super::ops::bin_decode(p, &bytes[..width], encoding)
}

/// `nativeloadptr %v %o %w`: the C address word of the W-byte address stored
/// at V + O, or NATIVE ADDRESS when no C address word can hold it.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_load_ptr(p: *mut Vm, view: Value, offset: Value, width: Value) -> Value {
    let address = match view_address(p, view, offset, "native view") {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let width = match int_small(width) {
        Some(w @ (4 | 8)) => w as usize,
        _ => {
            let message = format!("native view: malformed pointer width {}", super::show::int_text(width));
            return fail(p, "RANGE", message);
        }
    };
    let mut bytes = [0u8; 8];
    // SAFETY: as rt_native_load's.
    unsafe { std::ptr::copy_nonoverlapping(address as *const u8, bytes.as_mut_ptr(), width) };
    // A pointer is the target's own word: zero-extended from a narrower
    // width (a 32-bit target's address), the full word otherwise.
    let stored = u64::from_le_bytes(bytes) as i64;
    if !cptr_fits(stored) {
        return vm(p).fail(RtError::ForeignAddress(format!(
            "the native view's pointer field at address 0x{address:x} holds 0x{stored:x}, which a Botlish C pointer cannot hold (its word keeps a sign-extended 60-bit address: a top-byte-tagged pointer is not one); the pointer is never truncated or masked"
        )));
    }
    make_cptr(stored)
}

/// `cptroffset %v %o`: the address word V + O (a nested layout's view).
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_offset(p: *mut Vm, view: Value, offset: Value) -> Value {
    let address = match view_address(p, view, offset, "native view") {
        Ok(address) => address as i64,
        Err(failed) => return failed,
    };
    if !cptr_fits(address) {
        return vm(p).fail(RtError::ForeignAddress(format!(
            "the nested native view at 0x{address:x} lies outside the addresses a Botlish C pointer holds"
        )));
    }
    make_cptr(address)
}

/// `cptrfixturememory %b` (the test fixture's `ffi_fixture::memory`): the
/// address of a fresh, 64-byte aligned native copy of the bytes of B, which
/// is never freed (a test process makes a few).
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_fixture_memory(p: *mut Vm, bytes: Value) -> Value {
    // The abi::bytes::Bytes value itself: a one-field struct over its storage.
    let bytes = if heap_kind(bytes) == KIND_STRUCT && struct_of(bytes).fields().len() == 1 {
        struct_of(bytes).fields()[0]
    } else {
        bytes
    };
    if heap_kind(bytes) != KIND_BYTES {
        let message = format!("native memory test fixture: expected byte storage, got {}", super::show::show(bytes));
        return fail(p, "TYPE", message);
    }
    let data = bytes_of(bytes);
    let layout = std::alloc::Layout::from_size_align(data.len().max(1), 64).expect("fixture layout");
    // SAFETY: a non-zero size; the allocation is leaked on purpose.
    let block = unsafe { std::alloc::alloc_zeroed(layout) };
    if block.is_null() {
        std::alloc::handle_alloc_error(layout);
    }
    unsafe { std::ptr::copy_nonoverlapping(data.as_ptr(), block, data.len()) };
    let address = block as i64;
    if !cptr_fits(address) {
        return vm(p).fail(RtError::ForeignAddress(format!("native memory test fixture: address 0x{address:x} does not fit a C address word")));
    }
    make_cptr(address)
}

/// The WIDTH-byte representation of the C address word P (a data or function
/// pointer): its address bits, little-endian; a narrower width must hold the
/// address (a 32-bit target's pointer field), else RANGE.
fn pointer_bits(p: *mut Vm, pointer: Value, width: Value, context: &str) -> Result<([u8; 8], usize), Value> {
    if !is_cptr(pointer) {
        let message = format!("{context}: expected a C pointer, got {}", super::show::show(pointer));
        return Err(fail(p, "TYPE", message));
    }
    let width = match int_small(width) {
        Some(w @ (4 | 8)) => w as usize,
        _ => {
            let message = format!("{context}: malformed pointer width {}", super::show::int_text(width));
            return Err(fail(p, "RANGE", message));
        }
    };
    let bits = cptr_address(pointer) as u64;
    if width < 8 && bits >> (8 * width) != 0 {
        let message = format!("{context}: the address 0x{bits:x} does not fit a {width}-byte pointer field");
        return Err(fail(p, "RANGE", message));
    }
    Ok((bits.to_le_bytes(), width))
}

/// The scalar encoding word C of a layout write (`binstore`'s), or RANGE.
fn write_encoding(p: *mut Vm, code: Value, context: &str) -> Result<super::ops::BinEncoding, Value> {
    super::ops::bin_encoding(code).ok_or_else(|| {
        let message = format!("{context}: malformed scalar encoding {}", super::show::int_text(code));
        fail(p, "RANGE", message)
    })
}

/// Writes BYTES at ADDRESS: one unaligned copy of exactly their length.
fn store_at(address: usize, bytes: &[u8]) {
    // SAFETY: the edit's contract (NATIVE-LAYOUT-WRITES.md, "Bounds and
    // validity"): the foreign interface that produced the address promises
    // live writable memory of the layout's size there, and the layout's
    // validation put this field inside that size. Unaligned: a layout may
    // place a field at any offset (a packed record). No reference to the
    // foreign field is ever formed.
    unsafe { std::ptr::copy_nonoverlapping(bytes.as_ptr(), address as *mut u8, bytes.len()) };
}

/// `nativestore %e %o %c %v`: the Int V written at address E + O in
/// encoding C.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_store(p: *mut Vm, edit: Value, offset: Value, code: Value, value: Value) -> Value {
    const CONTEXT: &str = "native edit";
    let address = match view_address(p, edit, offset, CONTEXT) {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let encoding = match write_encoding(p, code, CONTEXT) {
        Ok(encoding) => encoding,
        Err(failed) => return failed,
    };
    let bytes = match super::ops::bin_encode(p, value, encoding, "binary::store") {
        Ok(bytes) => bytes,
        Err(failed) => return failed,
    };
    store_at(address, &bytes[..encoding.width]);
    UNIT
}

/// `nativestoreptr %e %o %w %q`: the W-byte address bits of the C address
/// word Q written at address E + O.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_store_ptr(p: *mut Vm, edit: Value, offset: Value, width: Value, pointer: Value) -> Value {
    let address = match view_address(p, edit, offset, "native edit") {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let (bits, width) = match pointer_bits(p, pointer, width, "binary::store") {
        Ok(bits) => bits,
        Err(failed) => return failed,
    };
    store_at(address, &bits[..width]);
    UNIT
}

/// The bytes ENCODED (its first WIDTH) written at OFFSET into a fresh copy of
/// the writable storage M: the layout write's result. The operand is never
/// written (MUTABLE-BYTES.md).
fn mbytes_written(p: *mut Vm, m: Value, offset: Value, encoded: &[u8], context: &str) -> Value {
    if heap_kind(m) != KIND_MUTBYTES {
        return vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::MutByteStore, got: m });
    }
    let len = mutbytes_of(m).len();
    let width = encoded.len();
    let at = match int_small(offset) {
        Some(o) if o >= 0 && (o as usize).checked_add(width).is_some_and(|end| end <= len) => o as usize,
        _ => {
            let message = format!("{context}: {width} bytes at offset {} lie outside a storage of {len} bytes", super::show::int_text(offset));
            return fail(p, "RANGE", message);
        }
    };
    vm(p).metrics.record_list_copy(len);
    let r = vm(p).new_mutbytes_with(len, |init| init.push_slice(mutbytes_of(m)));
    if r != NO_VALUE {
        // SAFETY: R is the fresh, fully written object this call just
        // created (len > 0: the field lies inside it, so it is not the
        // shared empty storage); nothing else holds it yet.
        unsafe { super::bytesobj::BytesObj::payload_mut(r)[at..at + width].copy_from_slice(encoded) };
    }
    r
}

/// `mbyteswrite %m %o %c %v`: a fresh copy of the writable storage M with
/// the Int V written at O in encoding C.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_write(p: *mut Vm, m: Value, offset: Value, code: Value, value: Value) -> Value {
    const CONTEXT: &str = "binary::write";
    let encoding = match write_encoding(p, code, CONTEXT) {
        Ok(encoding) => encoding,
        Err(failed) => return failed,
    };
    // Encoded before anything is allocated: a value outside the encoding
    // (or a Float64 no binary32 holds) fails with nothing made or written.
    let bytes = match super::ops::bin_encode(p, value, encoding, CONTEXT) {
        Ok(bytes) => bytes,
        Err(failed) => return failed,
    };
    mbytes_written(p, m, offset, &bytes[..encoding.width], CONTEXT)
}

/// `mbyteswriteptr %m %o %w %q`: a fresh copy of the writable storage M with
/// the W-byte address bits of the C address word Q written at O.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_write_ptr(p: *mut Vm, m: Value, offset: Value, width: Value, pointer: Value) -> Value {
    const CONTEXT: &str = "binary::write_foreign";
    let (bits, width) = match pointer_bits(p, pointer, width, CONTEXT) {
        Ok(bits) => bits,
        Err(failed) => return failed,
    };
    mbytes_written(p, m, offset, &bits[..width], CONTEXT)
}

// ---------------------------------------------------------------------------
// Fixed arrays (FIXED-LAYOUT-ARRAYS.md). A row of N scalars of one encoding
// lies contiguously (a scalar's stride is its width), so native/lower.tcl
// reads or writes a whole row with one helper call; every other array (of
// nested layouts, of pointers, of rows) is a counted NIR loop over the ops
// above, and one element is one of those ops at a computed offset. Nothing
// here reads a layout or a descriptor: the encoding and the count are the
// row's constants.

/// The row's operands: (offset, encoding), checked against SIZE bytes (the
/// storage's, or usize::MAX for native memory, whose extent only the foreign
/// interface knows). A row of C floats strides the C type's width.
fn row_operands(p: *mut Vm, offset: Value, code: Value, count: usize, size: usize, context: &str) -> Result<(usize, super::ops::BinEncoding), Value> {
    let encoding = write_encoding(p, code, context)?;
    let width = encoding.width;
    let at = match int_small(offset) {
        Some(o) if o >= 0 => o as usize,
        _ => return Err(fail(p, "RANGE", format!("{context}: malformed offset {}", super::show::int_text(offset)))),
    };
    match count.checked_mul(width).and_then(|n| n.checked_add(at)) {
        Some(end) if end <= size => Ok((at, encoding)),
        _ => Err(fail(p, "RANGE", format!("{context}: {count} elements of {width} bytes at offset {at} lie outside {size} bytes"))),
    }
}

/// The element count operand N of a row read (a small Int from 1).
fn row_count(p: *mut Vm, n: Value, context: &str) -> Result<usize, Value> {
    match int_small(n) {
        Some(n) if n >= 1 && n <= i32::MAX as i64 => Ok(n as usize),
        _ => Err(fail(p, "RANGE", format!("{context}: malformed element count {}", super::show::int_text(n)))),
    }
}

/// The List of the scalars of BYTES (contiguous, ENCODING's width each),
/// decoded; every heap value (a u64 above i64::MAX's BigInt, a C float's
/// Float64) rooted until the List holds it. The first element that is no
/// value (a NaN or an infinity in a row of C floats) fails the whole read.
fn decoded_row(p: *mut Vm, bytes: &[u8], encoding: super::ops::BinEncoding) -> Value {
    let base = vm(p).temp_roots.len();
    let width = encoding.width;
    let mut items = Vec::with_capacity(bytes.len() / width);
    for chunk in bytes.chunks_exact(width) {
        let v = super::ops::bin_decode(p, chunk, encoding);
        if v == NO_VALUE {
            vm(p).temp_roots.truncate(base);
            return v;
        }
        if !is_small(v) {
            vm(p).temp_roots.push(v);
        }
        items.push(v);
    }
    let r = vm(p).new_list(items);
    vm(p).temp_roots.truncate(base);
    r
}

/// `binloadarray %s %o %c %n`: the List of the N scalars of encoding C at
/// offset O of the byte storage S (a row of a fixed array, imprinted).
#[unsafe(no_mangle)]
pub extern "C" fn rt_bin_load_array(p: *mut Vm, storage: Value, offset: Value, code: Value, n: Value) -> Value {
    const CONTEXT: &str = "binary::parse";
    if heap_kind(storage) != KIND_BYTES {
        return vm(p).fail(RtError::Type { context: CONTEXT.to_string(), expected: Kind::ByteStore, got: storage });
    }
    let count = match row_count(p, n, CONTEXT) {
        Ok(count) => count,
        Err(failed) => return failed,
    };
    let data = bytes_of(storage);
    let (at, encoding) = match row_operands(p, offset, code, count, data.len(), CONTEXT) {
        Ok(operands) => operands,
        Err(failed) => return failed,
    };
    decoded_row(p, &data[at..at + count * encoding.width], encoding)
}

/// `nativeloadarray %v %o %c %n`: the List of the N scalars of encoding C at
/// address V + O (a row of a live fixed array, copied: binary::load).
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_load_array(p: *mut Vm, view: Value, offset: Value, code: Value, n: Value) -> Value {
    const CONTEXT: &str = "native view";
    let address = match view_address(p, view, offset, CONTEXT) {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let count = match row_count(p, n, CONTEXT) {
        Ok(count) => count,
        Err(failed) => return failed,
    };
    let (_, encoding) = match row_operands(p, make_small(0), code, count, usize::MAX, CONTEXT) {
        Ok(operands) => operands,
        Err(failed) => return failed,
    };
    let mut bytes = vec![0u8; count * encoding.width];
    // SAFETY: as rt_native_load's: the foreign interface promises live
    // memory of the layout's size, and the layout's validation put the whole
    // array inside it. One copy of the row; nothing else is read.
    unsafe { std::ptr::copy_nonoverlapping(address as *const u8, bytes.as_mut_ptr(), bytes.len()) };
    decoded_row(p, &bytes, encoding)
}

/// The encoded bytes of the List L (every element an Int, or for a row of C
/// floats a Float64, of ENCODING), all of them encoded before anything is
/// written: RANGE on the first element outside the encoding, NonFiniteFloat
/// on the first Float64 no binary32 holds. Its length is the row's: the
/// lowering checked it (the declared LayoutExtentMismatch) before.
fn encoded_row(p: *mut Vm, l: Value, encoding: super::ops::BinEncoding, context: &str) -> Result<Vec<u8>, Value> {
    if heap_kind(l) != KIND_LIST {
        return Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::List, got: l }));
    }
    let items = list_of(l).items();
    let width = encoding.width;
    let mut bytes = Vec::with_capacity(items.len() * width);
    for &item in items {
        let encoded = super::ops::bin_encode(p, item, encoding, context)?;
        bytes.extend_from_slice(&encoded[..width]);
    }
    Ok(bytes)
}

/// A private, fresh storage operand of the in-place row writes: the
/// `byteszeroed` an emission builds (KIND_BYTES) or the `mbytesclone` a
/// layout write into byte storage makes (KIND_MUTBYTES), both written only
/// while still private to the one operation that created them
/// (MUTABLE-BYTES.md).
fn fresh_storage(p: *mut Vm, storage: Value, context: &str) -> Result<usize, Value> {
    match heap_kind(storage) {
        KIND_BYTES => Ok(bytes_of(storage).len()),
        KIND_MUTBYTES => Ok(mutbytes_of(storage).len()),
        _ => Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::ByteStore, got: storage })),
    }
}

/// `binstorearray %s %o %c %l`: the Ints of the List L written at offset O
/// of the fresh storage S in encoding C, every one encoded before any is
/// written.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bin_store_array(p: *mut Vm, storage: Value, offset: Value, code: Value, l: Value) -> Value {
    const CONTEXT: &str = "binary::write";
    let size = match fresh_storage(p, storage, CONTEXT) {
        Ok(size) => size,
        Err(failed) => return failed,
    };
    let count = if heap_kind(l) == KIND_LIST { list_of(l).items().len() } else { 0 };
    let (at, encoding) = match row_operands(p, offset, code, count, size, CONTEXT) {
        Ok(operands) => operands,
        Err(failed) => return failed,
    };
    let bytes = match encoded_row(p, l, encoding, CONTEXT) {
        Ok(bytes) => bytes,
        Err(failed) => return failed,
    };
    // SAFETY: STORAGE is private to this operation (fresh_storage), and the
    // row lies inside it (row_operands).
    unsafe { super::bytesobj::BytesObj::payload_mut(storage)[at..at + bytes.len()].copy_from_slice(&bytes) };
    UNIT
}

/// `binstoreptr %s %o %w %q`: the W-byte address bits of the C address word
/// Q written at offset O of the fresh storage S (an element of an array of
/// pointers encoded by binary::write_foreign; Q observed).
#[unsafe(no_mangle)]
pub extern "C" fn rt_bin_store_ptr(p: *mut Vm, storage: Value, offset: Value, width: Value, pointer: Value) -> Value {
    const CONTEXT: &str = "binary::write_foreign";
    let size = match fresh_storage(p, storage, CONTEXT) {
        Ok(size) => size,
        Err(failed) => return failed,
    };
    let (bits, width) = match pointer_bits(p, pointer, width, CONTEXT) {
        Ok(bits) => bits,
        Err(failed) => return failed,
    };
    let at = match int_small(offset) {
        Some(o) if o >= 0 && (o as usize).checked_add(width).is_some_and(|end| end <= size) => o as usize,
        _ => return fail(p, "RANGE", format!("{CONTEXT}: {width} bytes at offset {} lie outside a storage of {size} bytes", super::show::int_text(offset))),
    };
    // SAFETY: as rt_bin_store_array's.
    unsafe { super::bytesobj::BytesObj::payload_mut(storage)[at..at + width].copy_from_slice(&bits[..width]) };
    UNIT
}

/// `nativestorearray %e %o %c %l`: the Ints of the List L written at address
/// E + O in encoding C -- every element encoded before the first byte is
/// written (a value outside the encoding is RANGE with the memory
/// untouched), then one unaligned copy of exactly the row's bytes.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_store_array(p: *mut Vm, edit: Value, offset: Value, code: Value, l: Value) -> Value {
    const CONTEXT: &str = "native edit";
    let address = match view_address(p, edit, offset, CONTEXT) {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let encoding = match write_encoding(p, code, CONTEXT) {
        Ok(encoding) => encoding,
        Err(failed) => return failed,
    };
    let bytes = match encoded_row(p, l, encoding, "binary::store") {
        Ok(bytes) => bytes,
        Err(failed) => return failed,
    };
    store_at(address, &bytes);
    UNIT
}

/// `cptrfixturebytes %q %n` (the test fixture's `ffi_fixture::memory_bytes`):
/// the N bytes at the C address Q, as a List of Ints.
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_fixture_bytes(p: *mut Vm, pointer: Value, n: Value) -> Value {
    let address = match view_address(p, pointer, make_small(0), "native memory test fixture") {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let Some(count) = int_small(n).filter(|n| (0..=1 << 20).contains(n)) else {
        let message = format!("native memory test fixture: malformed byte count {}", super::show::int_text(n));
        return fail(p, "RANGE", message);
    };
    let mut bytes = vec![0u8; count as usize];
    // SAFETY: the test's own fixture memory (ffi_fixture::memory) or C's
    // record, of at least N bytes: a test process's contract.
    unsafe { std::ptr::copy_nonoverlapping(address as *const u8, bytes.as_mut_ptr(), bytes.len()) };
    vm(p).new_list(bytes.into_iter().map(|b| make_small(b as i64)).collect())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;

    fn with_vm<R>(f: impl FnOnce(*mut Vm) -> R) -> R {
        let mut vm = Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new() }), AllocMode::Off);
        f(&mut *vm as *mut Vm)
    }

    fn word(bytes: &[u8]) -> (Value, Vec<u8>) {
        let mut storage = bytes.to_vec();
        storage.resize(storage.len() + 16, 0xEE);
        let address = storage.as_ptr() as i64;
        (make_cptr(address), storage)
    }

    #[test]
    fn nview_scalar_loads_every_encoding() {
        with_vm(|p| {
            let (v, _keep) = word(&[0xff, 0x7f, 0x00, 0x80, 0x01, 0x02, 0x03, 0x04, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
            // u8, i8 at 0
            assert_eq!(int_small(rt_native_load(p, v, make_small(0), make_small(1))), Some(255));
            assert_eq!(int_small(rt_native_load(p, v, make_small(0), make_small(17))), Some(-1));
            // u16 at 1 (unaligned): 0x007f
            assert_eq!(int_small(rt_native_load(p, v, make_small(1), make_small(2))), Some(0x7f));
            // i16 at 2: 0x8000
            assert_eq!(int_small(rt_native_load(p, v, make_small(2), make_small(18))), Some(-32768));
            // u32 at 4
            assert_eq!(int_small(rt_native_load(p, v, make_small(4), make_small(4))), Some(0x04030201));
            // i64 at 8: -2
            assert_eq!(int_small(rt_native_load(p, v, make_small(8), make_small(24))), Some(-2));
        });
    }

    #[test]
    fn nview_u64_above_small_range_is_a_bigint() {
        with_vm(|p| {
            let (v, _keep) = word(&[0xff; 8]);
            let n = rt_native_load(p, v, make_small(0), make_small(8));
            assert_ne!(n, NO_VALUE);
            assert_eq!(super::super::show::int_text(n), "18446744073709551615");
        });
    }

    #[test]
    fn nview_pointer_field_round_trips_and_refuses_tagged() {
        with_vm(|p| {
            let target = 0x1234_5678_9a00u64;
            let (v, _keep) = word(&target.to_le_bytes());
            let q = rt_native_load_ptr(p, v, make_small(0), make_small(8));
            assert!(is_cptr(q));
            assert_eq!(cptr_address(q), target as i64);
            let (z, _keep2) = word(&[0; 8]);
            assert_eq!(rt_native_load_ptr(p, z, make_small(0), make_small(8)), CPTR_NULL);
            let (t, _keep3) = word(&0xf000_0000_0000_0010u64.to_le_bytes());
            assert_eq!(rt_native_load_ptr(p, t, make_small(0), make_small(8)), NO_VALUE);
        });
    }

    #[test]
    fn nview_refuses_null_and_non_addresses() {
        with_vm(|p| {
            assert_eq!(rt_native_load(p, CPTR_NULL, make_small(0), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            assert_eq!(rt_native_load(p, make_small(8), make_small(0), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            let (v, _keep) = word(&[0; 8]);
            assert_eq!(rt_native_load(p, v, make_small(0), make_small(3)), NO_VALUE);
        });
    }

    #[test]
    fn nview_offset_moves_the_address() {
        with_vm(|p| {
            let (v, _keep) = word(&[0; 8]);
            let w = rt_cptr_offset(p, v, make_small(6));
            assert_eq!(cptr_address(w), cptr_address(v) + 6);
        });
    }

    /// A sentinel record of N bytes (0xA5) and its address word: the memory a
    /// native edit writes (NATIVE-LAYOUT-WRITES.md).
    fn sentinel(n: usize) -> (Value, Vec<u8>) {
        let storage = vec![0xA5u8; n];
        (make_cptr(storage.as_ptr() as i64), storage)
    }

    #[test]
    fn nedit_scalar_stores_every_encoding_touch_only_their_bytes() {
        with_vm(|p| {
            // {offset, code, value, the bytes it must leave there}
            let cases: [(i64, i64, i64, &[u8]); 9] = [
                (0, 1, 255, &[0xff]),
                (1, 17, -128, &[0x80]),
                (2, 2, 0x1234, &[0x34, 0x12]),
                (3, 18, -2, &[0xfe, 0xff]),
                (5, 4, 0x01020304, &[4, 3, 2, 1]),
                (9, 20, i32::MIN as i64, &[0, 0, 0, 0x80]),
                (13, 8, 0, &[0; 8]),
                (13, 24, -1, &[0xff; 8]),
                (13, 24, -0x0102_0304_0506_0708, &[0xf8, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe]),
            ];
            for (offset, code, value, bytes) in cases {
                let (v, storage) = sentinel(24);
                assert_eq!(rt_native_store(p, v, make_small(offset), make_small(code), make_small(value)), UNIT);
                let at = offset as usize;
                assert_eq!(&storage[at..at + bytes.len()], bytes, "the field at {offset}");
                assert!(storage[..at].iter().all(|b| *b == 0xA5), "bytes before the field at {offset}");
                assert!(storage[at + bytes.len()..].iter().all(|b| *b == 0xA5), "bytes after the field at {offset}");
            }
        });
    }

    #[test]
    fn nedit_u64_store_of_a_bigint() {
        with_vm(|p| {
            let (v, storage) = sentinel(10);
            // Every heap value is rooted before the next allocation, as
            // compiled code's stack maps root operands: under
            // BOTLISH_NATIVE_GC_STRESS=1 every allocation collects first.
            let big = vm(p).new_big(num_bigint::BigInt::from(u64::MAX));
            vm(p).temp_roots.push(big);
            assert_eq!(rt_native_store(p, v, make_small(1), make_small(8), big), UNIT);
            assert_eq!(&storage[1..9], &[0xff; 8]);
            assert_eq!((storage[0], storage[9]), (0xA5, 0xA5));
            let min = vm(p).new_big(num_bigint::BigInt::from(i64::MIN));
            assert_eq!(rt_native_store(p, v, make_small(1), make_small(24), min), UNIT);
            assert_eq!(&storage[1..9], &[0, 0, 0, 0, 0, 0, 0, 0x80]);
        });
    }

    #[test]
    fn nedit_store_refuses_out_of_range_values_before_writing() {
        // An unadmitted value (unreachable from a checked program) is RANGE,
        // and the memory is unchanged: never a truncation or a wrap.
        for (code, value) in [(1, 256), (1, -1), (17, 128), (2, 65536), (18, -32769), (4, -1), (20, 1i64 << 31)] {
            with_vm(|p| {
                let (v, storage) = sentinel(8);
                assert_eq!(rt_native_store(p, v, make_small(0), make_small(code), make_small(value)), NO_VALUE);
                assert!(storage.iter().all(|b| *b == 0xA5), "code {code} value {value}");
            });
        }
        with_vm(|p| {
            let (v, storage) = sentinel(8);
            let too_big = vm(p).new_big(num_bigint::BigInt::from(u64::MAX) + 1u8);
            assert_eq!(rt_native_store(p, v, make_small(0), make_small(8), too_big), NO_VALUE);
            assert!(storage.iter().all(|b| *b == 0xA5));
        });
    }

    #[test]
    fn nedit_store_refuses_null_and_non_addresses() {
        with_vm(|p| {
            assert_eq!(rt_native_store(p, CPTR_NULL, make_small(0), make_small(1), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            assert_eq!(rt_native_store(p, make_small(8), make_small(0), make_small(1), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            let (v, storage) = sentinel(8);
            assert_eq!(rt_native_store(p, v, make_small(0), make_small(3), make_small(1)), NO_VALUE);
            assert!(storage.iter().all(|b| *b == 0xA5));
        });
    }

    #[test]
    fn nedit_pointer_stores_copy_the_address_bits() {
        with_vm(|p| {
            let target = 0x1234_5678_9a00i64;
            let (v, storage) = sentinel(20);
            assert_eq!(rt_native_store_ptr(p, v, make_small(3), make_small(8), make_cptr(target)), UNIT);
            assert_eq!(&storage[3..11], &(target as u64).to_le_bytes());
            assert!(storage[..3].iter().chain(&storage[11..]).all(|b| *b == 0xA5));
            // Read back through the view's load: the same pointer.
            assert_eq!(cptr_address(rt_native_load_ptr(p, v, make_small(3), make_small(8))), target);
            // Null is eight zero bytes.
            assert_eq!(rt_native_store_ptr(p, v, make_small(11), make_small(8), CPTR_NULL), UNIT);
            assert_eq!(&storage[11..19], &[0; 8]);
            assert_eq!(storage[19], 0xA5);
        });
    }

    #[test]
    fn nedit_pointer_store_never_truncates_or_takes_an_int() {
        with_vm(|p| {
            let (v, storage) = sentinel(8);
            // A 4-byte pointer field cannot hold an address above 2^32.
            assert_eq!(rt_native_store_ptr(p, v, make_small(0), make_small(4), make_cptr(1 << 40)), NO_VALUE);
            assert!(storage.iter().all(|b| *b == 0xA5));
        });
        with_vm(|p| {
            let (v, storage) = sentinel(8);
            assert_eq!(rt_native_store_ptr(p, v, make_small(0), make_small(4), make_cptr(0x1000)), UNIT);
            assert_eq!(&storage[..4], &[0, 0x10, 0, 0]);
            assert_eq!(&storage[4..], &[0xA5; 4]);
        });
        with_vm(|p| {
            let (v, storage) = sentinel(8);
            assert_eq!(rt_native_store_ptr(p, v, make_small(0), make_small(8), make_small(4096)), NO_VALUE);
            assert!(storage.iter().all(|b| *b == 0xA5));
        });
    }

    #[test]
    fn nedit_byte_writes_make_a_fresh_storage() {
        with_vm(|p| {
            // Every storage is rooted before the next allocation, as compiled
            // code's stack maps root an allocating op's operands: under
            // BOTLISH_NATIVE_GC_STRESS=1 every allocation collects first, and
            // an unrooted operand's memory would be the fresh storage's.
            let m = super::super::ops::rt_mbytes_new(p, make_small(12));
            vm(p).temp_roots.push(m);
            let r = rt_mbytes_write(p, m, make_small(2), make_small(18), make_small(-2));
            vm(p).temp_roots.push(r);
            assert_ne!(r, m);
            assert_eq!(mutbytes_of(r), &[0, 0, 0xfe, 0xff, 0, 0, 0, 0, 0, 0, 0, 0]);
            // The operand is never written (MUTABLE-BYTES.md).
            assert_eq!(mutbytes_of(m), &[0; 12]);
            let q = rt_mbytes_write_ptr(p, r, make_small(4), make_small(8), make_cptr(0x0102_0304_0506));
            vm(p).temp_roots.push(q);
            assert_eq!(mutbytes_of(q), &[0, 0, 0xfe, 0xff, 6, 5, 4, 3, 2, 1, 0, 0]);
            assert_eq!(mutbytes_of(r), &[0, 0, 0xfe, 0xff, 0, 0, 0, 0, 0, 0, 0, 0]);
            // A field beyond the storage, a value outside the encoding, a
            // storage of the other kind: refused, nothing made.
            assert_eq!(rt_mbytes_write(p, m, make_small(11), make_small(2), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            let m = super::super::ops::rt_mbytes_new(p, make_small(4));
            vm(p).temp_roots.push(m);
            assert_eq!(rt_mbytes_write(p, m, make_small(0), make_small(1), make_small(256)), NO_VALUE);
        });
        with_vm(|p| {
            let (v, _keep) = sentinel(4);
            assert_eq!(rt_mbytes_write(p, v, make_small(0), make_small(1), make_small(1)), NO_VALUE);
        });
    }

    /// The text of a runtime value (a List of Ints here).
    fn shown(v: Value) -> String {
        super::super::show::show(v)
    }

    #[test]
    fn array_native_rows_load_every_encoding() {
        with_vm(|p| {
            let (v, _keep) = word(&[1, 0xff, 0x80, 0x7f, 0x34, 0x12, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
            let row = |code: i64, offset: i64, n: i64| shown(rt_native_load_array(p, v, make_small(offset), make_small(code), make_small(n)));
            assert_eq!(row(1, 0, 4), "[1, 255, 128, 127]");
            assert_eq!(row(17, 0, 4), "[1, -1, -128, 127]");
            // Element i at offset + i * width, little-endian.
            assert_eq!(row(2, 4, 2), "[4660, 65534]");
            assert_eq!(row(18, 4, 2), "[4660, -2]");
            assert_eq!(row(8, 8, 1), "[18446744073709551615]");
            assert_eq!(row(24, 8, 1), "[-1]");
        });
    }

    #[test]
    fn array_native_row_store_writes_only_the_row() {
        with_vm(|p| {
            let (v, storage) = sentinel(16);
            let l = vm(p).new_list(vec![make_small(1), make_small(0x1234), make_small(65535)]);
            vm(p).temp_roots.push(l);
            assert_eq!(rt_native_store_array(p, v, make_small(3), make_small(2), l), UNIT);
            assert_eq!(&storage[3..9], &[1, 0, 0x34, 0x12, 0xff, 0xff]);
            assert!(storage[..3].iter().chain(&storage[9..]).all(|b| *b == 0xA5));
        });
        // Every element is encoded before the first byte is written: one
        // outside the encoding is RANGE with the memory untouched.
        with_vm(|p| {
            let (v, storage) = sentinel(8);
            let l = vm(p).new_list(vec![make_small(1), make_small(2), make_small(256)]);
            vm(p).temp_roots.push(l);
            assert_eq!(rt_native_store_array(p, v, make_small(0), make_small(1), l), NO_VALUE);
            assert!(storage.iter().all(|b| *b == 0xA5));
        });
    }

    #[test]
    fn array_byte_rows_load_store_and_check_bounds() {
        with_vm(|p| {
            let s = vm(p).new_bytes(&[9, 8, 7, 6, 5, 4]);
            vm(p).temp_roots.push(s);
            assert_eq!(shown(rt_bin_load_array(p, s, make_small(1), make_small(2), make_small(2))), "[1800, 1286]");
            // A row past the storage's end is refused, never read.
            assert_eq!(rt_bin_load_array(p, s, make_small(3), make_small(2), make_small(2)), NO_VALUE);
        });
        with_vm(|p| {
            let m = super::super::ops::rt_mbytes_new(p, make_small(6));
            vm(p).temp_roots.push(m);
            let l = vm(p).new_list(vec![make_small(-1), make_small(2)]);
            vm(p).temp_roots.push(l);
            assert_eq!(rt_bin_store_array(p, m, make_small(2), make_small(18), l), UNIT);
            assert_eq!(mutbytes_of(m), &[0, 0, 0xff, 0xff, 2, 0]);
            // A row past the end is refused, nothing written.
            assert_eq!(rt_bin_store_array(p, m, make_small(3), make_small(18), l), NO_VALUE);
            assert_eq!(mutbytes_of(m), &[0, 0, 0xff, 0xff, 2, 0]);
        });
    }

    #[test]
    fn array_byte_pointer_elements_copy_address_bits() {
        with_vm(|p| {
            let m = super::super::ops::rt_mbytes_new(p, make_small(16));
            vm(p).temp_roots.push(m);
            assert_eq!(rt_bin_store_ptr(p, m, make_small(8), make_small(8), make_cptr(0x0102_0304_0506)), UNIT);
            assert_eq!(rt_bin_store_ptr(p, m, make_small(0), make_small(8), CPTR_NULL), UNIT);
            assert_eq!(mutbytes_of(m), &[0, 0, 0, 0, 0, 0, 0, 0, 6, 5, 4, 3, 2, 1, 0, 0]);
            // Past the end, or an Int for a pointer: refused.
            assert_eq!(rt_bin_store_ptr(p, m, make_small(9), make_small(8), CPTR_NULL), NO_VALUE);
            assert_eq!(rt_bin_store_ptr(p, m, make_small(0), make_small(8), make_small(4096)), NO_VALUE);
        });
    }

    #[test]
    fn nedit_fixture_bytes_copy_memory() {
        with_vm(|p| {
            let storage = [9u8, 8, 7, 6];
            let list = rt_cptr_fixture_bytes(p, make_cptr(storage.as_ptr() as i64), make_small(3));
            assert_ne!(list, NO_VALUE);
            assert_eq!(super::super::show::show(list), "[9, 8, 7]");
        });
    }
}
