//! The native `Value` representation.
//!
//! A value is one 64-bit word, tagged by its low bits:
//!
//! ```text
//!   xxxx...xxx1   small Int n, stored as (n << 1) | 1, n in [-2^62, 2^62)
//!   ...00000010   false          (2)
//!   ...00000110   true           (6)
//!   ...00001010   unit           (10)
//!   ccc...ccc100  UnicodeChar, stored as (codepoint << 3) | 4: an immediate
//!                 (never heap-allocated, never a GC root) carrying its
//!                 21-bit Unicode scalar value CCC directly in the word, the
//!                 same "tag + payload" shape as a small Int but with a
//!                 distinct low-bits tag (`0b100`, disjoint from a small
//!                 Int's `0b...1`, a heap pointer's `0b...000`, and the
//!                 fixed constants' exact values above) so a UnicodeChar can
//!                 never be mistaken for an Int by kind, even through a
//!                 dynamic/untyped path (see UNICODE-CHAR-LITERALS.md).
//!   pppp...p000   pointer to a heap object (non-null, 8-byte aligned)
//!   0             no value: an error is pending (never a program value)
//! ```
//!
//! Heap objects start with a [`Header`] whose `kind` byte says what follows.
//! Ints are canonical: an Int in the small range is always small, so two Ints
//! are equal iff their words are equal, or both are big and numerically
//! equal. Generated code relies on this layout (see `codegen::clif`).

use num_bigint::BigInt;
use std::mem::offset_of;

pub type Value = u64;

pub const NO_VALUE: Value = 0;
pub const FALSE: Value = 2;
pub const TRUE: Value = 6;
pub const UNIT: Value = 10;

pub const SMALL_MIN: i64 = -(1 << 62);
pub const SMALL_MAX: i64 = (1 << 62) - 1;

/// Low-bits tag of an immediate UnicodeChar word (see this module's own
/// header): disjoint from a small Int's `& 1 == 1`, a heap pointer's
/// `& 7 == 0`, and the fixed constants' exact values (2/6/10/14, none of
/// which have low 3 bits `0b100`).
pub const CHAR_TAG: u64 = 0b100;
pub const CHAR_TAG_MASK: u64 = 0b111;

pub const MAX_SCALAR: u32 = 0x10FFFF;
pub const SURROGATE_LO: u32 = 0xD800;
pub const SURROGATE_HI: u32 = 0xDFFF;

/// The runtime's enforced ceiling on a String's character count or a List's
/// element count (`Vm::new_str`/`new_str_known`/`new_list`): a String/List
/// longer than this is rejected with a RANGE error at construction, rather
/// than merely relying on the allocator to fail first. This is what makes
/// `str::length`/`list::length`'s `-result-range collection-length` metadata
/// (core/native.tcl, consumed by hir/range.tcl) an actual checked runtime
/// contract instead of an assumption: every reachable String/List length is
/// guaranteed to fit the small-Int representation (SMALL_MAX above), so
/// `str::length(s)`/`list::length(xs)` can never itself need a BigInt result.
/// Set equal to SMALL_MAX (not some smaller, more "obviously safe" value):
/// the guarantee this milestone needs is exactly "fits a small Int", and
/// picking anything smaller would reject collections the small-Int range
/// itself has no trouble representing.
pub const MAX_COLLECTION_LENGTH: usize = SMALL_MAX as usize;

pub const KIND_BIGINT: u8 = 1;
pub const KIND_STR: u8 = 2;
pub const KIND_LIST: u8 = 3;
pub const KIND_RESULT: u8 = 4;
pub const KIND_CLOSURE: u8 = 5;
pub const KIND_NATIVE: u8 = 6;
// Heap kind 7 was the forward-reference cell (removed by
// DIRECT-HIR-NATIVE-PATH.md); its number is not reused.
/// A MutableArray: fixed-capacity mutable indexed storage (see
/// MutArrayObj). Distinct from KIND_LIST, whose ListObj is never mutated
/// after construction.
pub const KIND_MUTARRAY: u8 = 8;
/// An ImmutableSet (MINIMAL-IMMUTABLE-SET.md, SetObj): distinct from
/// KIND_LIST so a set and a List, even one with identical elements, are
/// never the same runtime kind.
pub const KIND_SET: u8 = 9;
/// Private virtual-construction plans (runtime/construct.rs,
/// M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md): compiler/runtime implementation
/// state, never a program value -- `kind_of` deliberately has no case for
/// them (it panics), so a plan that ever leaked into ordinary Value ABI
/// would fail loudly rather than be misread as a String/List.
pub const KIND_STRPLAN: u8 = 10;
pub const KIND_LISTPLAN: u8 = 11;
/// A struct value (STRUCTS.md, StructObj): distinct from KIND_LIST, so a
/// struct and a List are never the same runtime kind, whatever they hold.
pub const KIND_STRUCT: u8 = 12;
/// The owned byte storage behind `abi::bytes::Bytes` (ABI-BYTES.md, bytesobj.rs): an
/// immutable, finite, contiguous sequence of bytes, header + length + payload
/// in one allocation. Its payload holds no program value.
pub const KIND_BYTES: u8 = 13;
/// The writable byte storage behind `abi::bytes::MutableBytes` (MUTABLE-BYTES.md):
/// the KIND_BYTES layout under its own kind, so the two are never confused
/// (a MutableBytes is not accepted where a Bytes storage is required, nor the
/// reverse). Never written once it is a value (see bytesobj.rs).
pub const KIND_MUTBYTES: u8 = 14;

#[repr(C)]
pub struct Header {
    pub kind: u8,
    pub marked: u8,
    /// 1 for objects that live as long as the compiled program (constants,
    /// natives, closures of environment-free functions): never collected.
    pub is_static: u8,
    _pad: [u8; 5],
}

impl Header {
    pub fn new(kind: u8, is_static: bool) -> Header {
        Header { kind, marked: 0, is_static: is_static as u8, _pad: [0; 5] }
    }
}

#[repr(C)]
pub struct BigIntObj {
    pub hdr: Header,
    pub n: BigInt,
}

// The String object (one allocation: header, metadata and UTF-8 bytes) lives
// in strobj.rs; re-exported so every `use value::*` still sees it.
pub use super::bytesobj::{BYTES_LEN_OFFSET, BYTES_PAYLOAD_OFFSET, BytesObj};
pub use super::strobj::{
    STR_ALIGN, STR_ASCII_OFFSET, STR_BYTE_LEN_OFFSET, STR_CHARS_OFFSET, STR_HEADER_SIZE,
    STR_MIN_ALLOC, STR_TEXT_OFFSET, StrObj, first_scalar,
};

// ---------------------------------------------------------------------------
// Packed ASCII (SHORT-STRING.md, tier A): a String proved ASCII with at most
// eight characters as one 64-bit word. Byte i (bits 8i..8i+7) is `0x80 | c`
// for the character c at index i, and 0 past the end:
//   * the high bit of each byte is a *presence* flag, so the length is
//     recoverable from the word alone with one count-leading-zeros and the
//     word is canonical (equal Strings have equal words);
//   * the empty String is 0, NUL is a present 0x80 (never absent);
//   * unpacking to the String's bytes is `w & 0x7F7F_7F7F_7F7F_7F7F`, stored
//     as one little-endian word, then truncated to the length.

pub const ASCII_PAYLOAD_MASK: u64 = 0x7F7F_7F7F_7F7F_7F7F;

/// The character count (0..=8) of canonical packed word W.
#[inline]
pub fn ascii_word_len(w: u64) -> usize {
    ((71 - w.leading_zeros()) >> 3) as usize
}

/// Packs the ASCII BYTES (at most eight, none above 0x7F) into a word.
#[inline]
pub fn pack_ascii(bytes: &[u8]) -> u64 {
    debug_assert!(bytes.len() <= 8 && bytes.iter().all(|b| *b < 0x80));
    let mut w = 0u64;
    for (i, b) in bytes.iter().enumerate() {
        w |= ((*b as u64) | 0x80) << (8 * i);
    }
    w
}

/// The String's bytes of packed word W (the first `ascii_word_len(w)` of the
/// returned array are meaningful).
#[inline]
pub fn unpack_ascii(w: u64) -> ([u8; 8], usize) {
    ((w & ASCII_PAYLOAD_MASK).to_le_bytes(), ascii_word_len(w))
}

/// Whether W is a canonical packed word: every byte is 0 (absent) or has the
/// presence bit set (present), and no present byte follows an absent one.
pub fn is_canonical_ascii_word(w: u64) -> bool {
    let mut absent = false;
    for i in 0..8 {
        let b = (w >> (8 * i)) & 0xFF;
        if b == 0 {
            absent = true;
        } else if absent || b & 0x80 == 0 {
            return false;
        }
    }
    true
}

/// A List's elements: a raw pointer plus a count, exactly like ClosureObj's
/// `caps`/`ncaps` (see `rt_closure_new`/`free_object`) rather than `Vec`,
/// whose field layout is not something generated native code may rely on
/// (`Vec`'s fields are private and its layout unspecified). `len`/`ptr` have
/// known, `#[repr(C)]` offsets (`LIST_LEN_OFFSET`/`LIST_PTR_OFFSET`) so
/// Cranelift-generated code can load a List's length and index its elements
/// directly, without a runtime call (codegen::clif's `list::at`). Backed by
/// a `Box<[Value]>` (`Box::into_raw`/`Box::from_raw`, freed in
/// `heap::free_object`), sound because a List is never mutated after
/// construction (this module's header) -- `len`/`ptr` are set once, at
/// `Vm::new_list`, and never change.
#[repr(C)]
pub struct ListObj {
    pub hdr: Header,
    pub len: usize,
    pub ptr: *mut Value,
}

impl ListObj {
    pub fn items(&self) -> &[Value] {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len) }
    }
}

/// A struct value (STRUCTS.md): the index of its static shape (the program's
/// `ProgramInfo::shapes` table: anonymous field set or named declaration,
/// with the slot order) plus its field values in slot order, a raw pointer and
/// a count exactly like ListObj so generated code can load a field directly
/// at a constant slot (`STRUCT_PTR_OFFSET`). The object holds no field names
/// and no static types: names live once, in the shape; types are the
/// compiler's. Never mutated after construction (struct values are
/// immutable; `Vm::new_struct` fills the slots before the object is
/// observable).
#[repr(C)]
pub struct StructObj {
    pub hdr: Header,
    pub shape: u32,
    pub len: usize,
    pub ptr: *mut Value,
}

impl StructObj {
    pub fn fields(&self) -> &[Value] {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len) }
    }
}

/// An ImmutableSet's members: a raw pointer plus a count, structurally
/// identical to ListObj (MINIMAL-IMMUTABLE-SET.md item 31: reusing List's
/// own simple storage shape rather than inventing a new one), but under its
/// own `Header::kind` (KIND_SET) so it remains a genuinely distinct runtime
/// kind -- `heap_kind`/`kind_of` can never confuse a set with a List, so
/// untyped code cannot feed one to a List operation. Never mutated after
/// `Vm::new_set` (there is no in-place insertion/removal), and already
/// deduplicated by `rt_set_from_list`'s own O(n^2) `equal`-based scan before
/// this object is ever allocated.
#[repr(C)]
pub struct SetObj {
    pub hdr: Header,
    pub len: usize,
    pub ptr: *mut Value,
}

impl SetObj {
    pub fn items(&self) -> &[Value] {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len) }
    }
}

/// A MutableArray: fixed-capacity, explicitly mutable indexed storage. Every
/// slot is a program value (initialized to UNIT at allocation: see
/// Vm::new_mutarray), never uninitialized memory. Unlike ListObj, SLOTS is
/// mutated in place by mutable_array::set/mutable_array::copy; its length
/// (`slots.len()`) is its fixed capacity and never changes after allocation
/// (see the module-level "no hidden resizing" invariant in ops.rs).
#[repr(C)]
pub struct MutArrayObj {
    pub hdr: Header,
    pub slots: Box<[Value]>,
}

#[repr(C)]
pub struct ResultObj {
    pub hdr: Header,
    pub ok: bool,
    pub payload: Value,
}

/// A Block value: code plus captured values.
#[repr(C)]
pub struct ClosureObj {
    pub hdr: Header,
    /// NIR function id.
    pub func: u32,
    pub arity: u32,
    /// Generic entry: `extern "C" fn(*mut Vm, closure: Value, args: *const Value) -> Value`.
    pub code: usize,
    pub ncaps: usize,
    pub caps: *mut Value,
}

#[repr(C)]
pub struct NativeObj {
    pub hdr: Header,
    /// Index into the program's native declarations.
    pub native: u32,
}

pub const CLOSURE_CAPS_OFFSET: i32 = offset_of!(ClosureObj, caps) as i32;
pub const LIST_LEN_OFFSET: i32 = offset_of!(ListObj, len) as i32;

pub const LIST_PTR_OFFSET: i32 = offset_of!(ListObj, ptr) as i32;
pub const STRUCT_PTR_OFFSET: i32 = offset_of!(StructObj, ptr) as i32;

#[inline]
pub fn is_small(v: Value) -> bool {
    v & 1 == 1
}

#[inline]
pub fn small_of(v: Value) -> i64 {
    (v as i64) >> 1
}

#[inline]
pub fn make_small(n: i64) -> Value {
    debug_assert!((SMALL_MIN..=SMALL_MAX).contains(&n));
    ((n << 1) | 1) as u64
}

#[inline]
pub fn fits_small(n: i64) -> bool {
    (SMALL_MIN..=SMALL_MAX).contains(&n)
}

#[inline]
pub fn is_pointer(v: Value) -> bool {
    v != 0 && v & 7 == 0
}

/// 1 if N is a valid Unicode scalar value (0..=0xD7FF or 0xE000..=0x10FFFF:
/// never a surrogate) -- the one validity rule for a UnicodeChar codepoint,
/// shared by the lexer's own literal validation (core/value.tcl's
/// isValidScalar) and this runtime's `make_char`.
#[inline]
pub fn is_valid_scalar(n: u32) -> bool {
    n <= MAX_SCALAR && !(SURROGATE_LO..=SURROGATE_HI).contains(&n)
}

#[inline]
pub fn is_char(v: Value) -> bool {
    v & CHAR_TAG_MASK == CHAR_TAG
}

#[inline]
pub fn char_of(v: Value) -> u32 {
    debug_assert!(is_char(v));
    (v >> 3) as u32
}

#[inline]
pub fn make_char(codepoint: u32) -> Value {
    debug_assert!(is_valid_scalar(codepoint));
    ((codepoint as u64) << 3) | CHAR_TAG
}

#[inline]
pub fn bool_value(b: bool) -> Value {
    if b { TRUE } else { FALSE }
}

/// The heap kind of V, or 0 if V is not a heap object.
#[inline]
pub fn heap_kind(v: Value) -> u8 {
    if is_pointer(v) { unsafe { (*(v as *const Header)).kind } } else { 0 }
}

/// Semantic value kinds, as core/value.tcl names them.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Kind {
    Int,
    Str,
    Bool,
    Unit,
    List,
    Result,
    Block,
    Native,
    MutArray,
    /// A distinct semantic scalar (never Int, never Str): see this module's
    /// own header and UNICODE-CHAR-LITERALS.md. Named to match its source
    /// spelling exactly (core/type.tcl's primitive name), not abbreviated
    /// like the other variants' lowercase tags, since Kind::name's string
    /// *is* the language-level type name here.
    UnicodeChar,
    /// An ImmutableSet (MINIMAL-IMMUTABLE-SET.md): distinct from List, even
    /// one with identical elements. Named to match its HIR structural tag
    /// and every native's -param-types spelling ("immutableSet",
    /// core/type.tcl's broad primitive name) exactly, the same List/"list"
    /// split UnicodeChar's own comment above describes for its own name.
    ImmutableSet,
    /// A struct value (STRUCTS.md): distinct from List and every other kind.
    Struct,
    /// The owned byte storage behind `abi::bytes::Bytes` (ABI-BYTES.md): distinct
    /// from List and String. Named as core/value.tcl's `bytestore` kind.
    ByteStore,
    /// The writable byte storage behind `abi::bytes::MutableBytes` (MUTABLE-BYTES.md):
    /// distinct from ByteStore. Named as core/value.tcl's `mutbytes` kind.
    MutByteStore,
}

impl Kind {
    pub fn parse(name: &str) -> Option<Kind> {
        Some(match name {
            "int" => Kind::Int,
            "str" => Kind::Str,
            "bool" => Kind::Bool,
            "unit" => Kind::Unit,
            "list" => Kind::List,
            "result" => Kind::Result,
            "block" => Kind::Block,
            "native" => Kind::Native,
            "mutarray" => Kind::MutArray,
            "UnicodeChar" => Kind::UnicodeChar,
            "immutableSet" => Kind::ImmutableSet,
            "struct" => Kind::Struct,
            "bytestore" => Kind::ByteStore,
            "mutbytes" => Kind::MutByteStore,
            _ => return None,
        })
    }

    pub fn name(self) -> &'static str {
        match self {
            Kind::Int => "int",
            Kind::Str => "str",
            Kind::Bool => "bool",
            Kind::Unit => "unit",
            Kind::List => "list",
            Kind::Result => "result",
            Kind::Block => "block",
            Kind::Native => "native",
            Kind::MutArray => "mutarray",
            Kind::UnicodeChar => "UnicodeChar",
            Kind::ImmutableSet => "immutableSet",
            Kind::Struct => "struct",
            Kind::ByteStore => "bytestore",
            Kind::MutByteStore => "mutbytes",
        }
    }

    pub fn code(self) -> u8 {
        self as u8
    }

    pub fn from_code(code: u8) -> Kind {
        [
            Kind::Int, Kind::Str, Kind::Bool, Kind::Unit, Kind::List, Kind::Result, Kind::Block, Kind::Native,
            Kind::MutArray, Kind::UnicodeChar, Kind::ImmutableSet, Kind::Struct, Kind::ByteStore, Kind::MutByteStore,
        ][code as usize]
    }
}

/// The semantic kind of a program value.
pub fn kind_of(v: Value) -> Kind {
    if is_small(v) {
        return Kind::Int;
    }
    match v {
        TRUE | FALSE => return Kind::Bool,
        UNIT => return Kind::Unit,
        _ => {}
    }
    if is_char(v) {
        return Kind::UnicodeChar;
    }
    match heap_kind(v) {
        KIND_BIGINT => Kind::Int,
        KIND_STR => Kind::Str,
        KIND_LIST => Kind::List,
        KIND_RESULT => Kind::Result,
        KIND_CLOSURE => Kind::Block,
        KIND_NATIVE => Kind::Native,
        KIND_MUTARRAY => Kind::MutArray,
        KIND_SET => Kind::ImmutableSet,
        KIND_STRUCT => Kind::Struct,
        KIND_BYTES => Kind::ByteStore,
        KIND_MUTBYTES => Kind::MutByteStore,
        _ => panic!("not a program value: {v:#x}"),
    }
}

pub unsafe fn as_ref<'a, T>(v: Value) -> &'a T {
    unsafe { &*(v as *const T) }
}

pub fn str_of<'a>(v: Value) -> &'a StrObj {
    debug_assert_eq!(heap_kind(v), KIND_STR);
    // SAFETY: V is a live, fully constructed String (a tagged heap pointer
    // of kind KIND_STR); the wide reference covers header and text.
    unsafe { StrObj::from_addr(v) }
}

pub fn list_of<'a>(v: Value) -> &'a ListObj {
    debug_assert_eq!(heap_kind(v), KIND_LIST);
    unsafe { as_ref(v) }
}

pub fn struct_of<'a>(v: Value) -> &'a StructObj {
    debug_assert_eq!(heap_kind(v), KIND_STRUCT);
    unsafe { as_ref(v) }
}

/// The payload of the byte storage V (a slice of its inline bytes).
pub fn bytes_of<'a>(v: Value) -> &'a [u8] {
    debug_assert_eq!(heap_kind(v), KIND_BYTES);
    // SAFETY: V is a live, fully constructed storage (a tagged heap pointer of
    // kind KIND_BYTES); the payload is immutable for the object's life.
    unsafe { BytesObj::payload(v) }
}

/// The payload of the MutableBytes storage V (read-only view of its inline
/// bytes; writers use `BytesObj::payload_mut` on their own fresh clone).
pub fn mutbytes_of<'a>(v: Value) -> &'a [u8] {
    debug_assert_eq!(heap_kind(v), KIND_MUTBYTES);
    // SAFETY: V is a live, fully constructed storage (a tagged heap pointer of
    // kind KIND_MUTBYTES), written only while private to its creator.
    unsafe { BytesObj::payload(v) }
}

pub fn set_of<'a>(v: Value) -> &'a SetObj {
    debug_assert_eq!(heap_kind(v), KIND_SET);
    unsafe { as_ref(v) }
}

pub fn mutarray_of<'a>(v: Value) -> &'a MutArrayObj {
    debug_assert_eq!(heap_kind(v), KIND_MUTARRAY);
    unsafe { as_ref(v) }
}

/// A mutable reference to V's slots (V must be a MutableArray). Sound because
/// every caller holds V, a live tagged pointer, exclusively for the duration
/// of the borrow: MutableArrays are ordinary thread-local runtime state (no
/// aliased native access from generated code), so `&mut` here reflects an
/// actual invariant, not an unchecked assumption.
pub fn mutarray_of_mut<'a>(v: Value) -> &'a mut MutArrayObj {
    debug_assert_eq!(heap_kind(v), KIND_MUTARRAY);
    unsafe { &mut *(v as *mut MutArrayObj) }
}

pub fn result_of<'a>(v: Value) -> &'a ResultObj {
    debug_assert_eq!(heap_kind(v), KIND_RESULT);
    unsafe { as_ref(v) }
}

pub fn closure_of<'a>(v: Value) -> &'a ClosureObj {
    debug_assert_eq!(heap_kind(v), KIND_CLOSURE);
    unsafe { as_ref(v) }
}

/// The Int V as a BigInt (V must be an Int).
pub fn int_to_big(v: Value) -> BigInt {
    if is_small(v) {
        BigInt::from(small_of(v))
    } else {
        debug_assert_eq!(heap_kind(v), KIND_BIGINT);
        unsafe { as_ref::<BigIntObj>(v) }.n.clone()
    }
}

/// The Int V as an i64, if it is small.
pub fn int_small(v: Value) -> Option<i64> {
    if is_small(v) { Some(small_of(v)) } else { None }
}
