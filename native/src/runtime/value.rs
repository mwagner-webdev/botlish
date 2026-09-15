//! The native `Value` representation.
//!
//! A value is one 64-bit word, tagged by its low bits:
//!
//! ```text
//!   xxxx...xxx1   small Int n, stored as (n << 1) | 1, n in [-2^62, 2^62)
//!   ...00000010   false          (2)
//!   ...00000110   true           (6)
//!   ...00001010   unit           (10)
//!   ...00001110   unbound cell   (14)  never a program value
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
pub const UNBOUND: Value = 14;

pub const SMALL_MIN: i64 = -(1 << 62);
pub const SMALL_MAX: i64 = (1 << 62) - 1;

/// The runtime's enforced ceiling on a String's character count or a List's
/// element count (`Vm::new_str`/`new_str_known`/`new_list`): a String/List
/// longer than this is rejected with a RANGE error at construction, rather
/// than merely relying on the allocator to fail first. This is what makes
/// `length`/`list_length`'s `-result-range collection-length` metadata
/// (core/native.tcl, consumed by hir/range.tcl) an actual checked runtime
/// contract instead of an assumption: every reachable String/List length is
/// guaranteed to fit the small-Int representation (SMALL_MAX above), so
/// `length(xs)`/`list_length(xs)` can never itself need a BigInt result.
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
pub const KIND_CELL: u8 = 7;
/// A MutableArray: fixed-capacity mutable indexed storage (see
/// MutArrayObj). Distinct from KIND_LIST, whose ListObj is never mutated
/// after construction.
pub const KIND_MUTARRAY: u8 = 8;

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

#[repr(C)]
pub struct StrObj {
    pub hdr: Header,
    /// Number of characters (Unicode scalar values).
    pub chars: usize,
    pub ascii: bool,
    pub text: Box<str>,
}

#[repr(C)]
pub struct ListObj {
    pub hdr: Header,
    pub items: Vec<Value>,
}

/// A MutableArray: fixed-capacity, explicitly mutable indexed storage. Every
/// slot is a program value (initialized to UNIT at allocation: see
/// Vm::new_mutarray), never uninitialized memory. Unlike ListObj, SLOTS is
/// mutated in place by mutable_array_set/mutable_array_copy; its length
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

/// A binding that closures may read before it is bound.
#[repr(C)]
pub struct CellObj {
    pub hdr: Header,
    pub value: Value,
}

pub const CLOSURE_CAPS_OFFSET: i32 = offset_of!(ClosureObj, caps) as i32;
pub const CELL_VALUE_OFFSET: i32 = offset_of!(CellObj, value) as i32;

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
        }
    }

    pub fn code(self) -> u8 {
        self as u8
    }

    pub fn from_code(code: u8) -> Kind {
        [Kind::Int, Kind::Str, Kind::Bool, Kind::Unit, Kind::List, Kind::Result, Kind::Block, Kind::Native, Kind::MutArray]
            [code as usize]
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
    match heap_kind(v) {
        KIND_BIGINT => Kind::Int,
        KIND_STR => Kind::Str,
        KIND_LIST => Kind::List,
        KIND_RESULT => Kind::Result,
        KIND_CLOSURE => Kind::Block,
        KIND_NATIVE => Kind::Native,
        KIND_MUTARRAY => Kind::MutArray,
        _ => panic!("not a program value: {v:#x}"),
    }
}

pub unsafe fn as_ref<'a, T>(v: Value) -> &'a T {
    unsafe { &*(v as *const T) }
}

pub fn str_of<'a>(v: Value) -> &'a StrObj {
    debug_assert_eq!(heap_kind(v), KIND_STR);
    unsafe { as_ref(v) }
}

pub fn list_of<'a>(v: Value) -> &'a ListObj {
    debug_assert_eq!(heap_kind(v), KIND_LIST);
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
