//! The runtime ABI: helpers generated code calls.
//!
//! Every helper is `extern "C"`, takes `vm: *mut Vm` first and 64-bit words
//! otherwise, and returns one word. Unless stated otherwise:
//!
//!   * operands already have the kinds the operation requires (generated code
//!     checked them with inline guards, or static types proved them)
//!   * the result is a program value; a helper that can fail records an
//!     `RtError` and returns `NO_VALUE` (0), and the caller must propagate it
//!   * a helper that allocates may run a collection first; its operands are
//!     GC roots because generated code keeps every register on the shadow
//!     stack, and stack arrays passed by pointer hold copies of registers
//!   * results are owned by the heap; nothing is freed explicitly
//!
//! | helper                 | operands            | result / failure             | allocates |
//! |------------------------|---------------------|------------------------------|-----------|
//! | rt_int_add/sub/mul     | Int, Int            | Int                          | big Ints  |
//! | rt_int_mod             | Int, Int            | Int (0<=r<|b|); ARITHMETIC   | big Ints  |
//! | rt_int_and/or/xor      | Int, Int            | Int (two's-complement)       | big Ints  |
//! | rt_int_shl/shr         | Int, Int(shift>=0)  | Int; RANGE if shift invalid  | big Ints  |
//! | rt_int_cmp             | Int, Int            | -1/0/1 (raw i64)             | no        |
//! | rt_value_eq            | any, any            | Bool; EQUALITY on callables  | no        |
//! | rt_str_eq              | Str, Str            | Bool                         | no        |
//! | rt_hash                | any                 | Int (61-bit); EQUALITY       | no        |
//! | rt_table_hash          | any                 | Int (61-bit); EQUALITY       | no        |
//! | rt_str_len             | Str                 | Int                          | no        |
//! | rt_substr              | Str, Int, Int       | Str; declared LowerUnderrun/ | yes       |
//! |                        |                     | UpperOverrun (check_slice)   |           |
//! | rt_str_decode_char_at  | Str, Int(byte off.) | one-char Str                 | yes       |
//! | rt_str_byte_len        | Str                 | Int (UTF-8 byte length)      | no        |
//! | rt_str_lower           | Str                 | Str                          | yes       |
//! | rt_str_cat             | Str, Str            | Str                          | yes       |
//! | rt_str_append_char     | Str, UnicodeChar    | Str (S followed by C)        | yes       |
//! | rt_str_utf8_bytes      | Str                 | List of Int (0..255); RANGE  | yes       |
//! | rt_int_to_str          | Int                 | Str (canonical decimal text) | yes       |
//! | rt_str_to_int          | Str                 | Int; declared                | big Ints  |
//! |                        |                     | InvalidIntegerText           |           |
//! | rt_str_char_at         | Str, Int            | UnicodeChar; declared        | no        |
//! |                        |                     | IndexNotFound (str::char_at) |           |
//! | rt_str_char_at_proven  | Str, Int            | UnicodeChar (index proven    | no        |
//! |                        |                     | valid by hir/completions.tcl)|           |
//! | rt_argv                |                     | List of Str; declared        | yes       |
//! |                        |                     | InvalidArgumentEncoding      |           |
//! | rt_linux_x86_64_syscall| 7 Ints (i64 words)  | Int: raw rax, signed (see    | big Ints  |
//! |                        | rax rdi rsi rdx r10 | runtime/syscall.rs); TYPE if |           |
//! |                        | r8 r9               | an operand is no i64 word    |           |
//! | rt_linux_aarch64_syscall| 7 Ints (i64 words) | Int: raw x0, signed; TYPE if | big Ints  |
//! |                        | x8 x0 x1 x2 x3 x4 x5| an operand is no i64 word    |           |
//! | rt_is_tcl_alpha        | Str (1 scalar)      | Bool; RANGE if not 1 scalar  | no        |
//! | rt_is_tcl_alnum        | Str (1 scalar)      | Bool; RANGE if not 1 scalar  | no        |
//! | rt_char_is_tcl_alpha   | UnicodeChar         | Bool                         | no        |
//! | rt_char_is_tcl_alnum   | UnicodeChar         | Bool                         | no        |
//! | rt_str_region_is_tcl_alpha | Str,Int,Int (region, 1 scalar) | Bool; RANGE | no    |
//! | rt_str_region_is_tcl_alnum | Str,Int,Int (region, 1 scalar) | Bool; RANGE | no    |
//! | rt_list_new            | count, *Value       | List                         | yes       |
//! | rt_list_len            | List                | Int                          | no        |
//! | rt_list_get            | List, Int           | element; declared            | no        |
//! |                        |                     | IndexNotFound (list::at)     |           |
//! | rt_list_get_proven     | List, Int           | element (index proven valid  | no        |
//! |                        |                     | by hir/completions.tcl)      |           |
//! | rt_list_append         | List, any           | new List (copy)              | yes       |
//! | rt_list_with_length    | List, Int           | the same List; declared      | no        |
//! |                        |                     | LengthMismatch               |           |
//! | rt_set_from_list       | List                | ImmutableSet; EQUALITY       | yes       |
//! | rt_set_contains        | ImmutableSet, any   | Bool; EQUALITY               | no        |
//! | rt_mutarray_allocate   | count                | MutableArray (slots = UNIT)  | yes       |
//! | rt_mutarray_capacity   | MutableArray         | Int                          | no        |
//! | rt_mutarray_get        | MutableArray, Int    | element; declared            | no        |
//! |                        |                      | IndexNotFound (mutable_array::at) |      |
//! | rt_mutarray_set        | MutableArray,Int,any | Unit; declared IndexNotFound | no        |
//! | rt_mutarray_copy       | dst,i,src,i,count    | Unit; declared LowerUnderrun/| no        |
//! |                        |                      | UpperOverrun (check_slice)   |           |
//! | rt_mutarray_freeze     | MutableArray, Int    | List (copy); declared        | yes       |
//! |                        |                      | LowerUnderrun/UpperOverrun   |           |
//! | rt_is_kind             | any, kind code      | Bool                         | no        |
//! | rt_is_result           | any, 1 ok / 0 error | Bool                         | no        |
//! | rt_result_payload      | Result, 1/0         | payload; TYPE if wrong tag   | no        |
//! | rt_result_new          | 1/0, any            | Result                       | yes       |
//! | rt_closure_new         | fn, code, n, *Value | Block                        | yes       |
//! | rt_call_value          | callee, n, *Value   | call result; ARITY,          | callee    |
//! |                        |                     | NOT-CALLABLE, callee errors  |           |
//! | rt_type_error          | value, kind, ctx    | records TYPE, returns 0      | no        |
//! | rt_not_boolean         | value               | records NOT-BOOLEAN          | no        |
//! | rt_raise               | kind Str, msg Str   | records a semantic error     | no        |
//! | rt_stack_overflow      |                     | records NATIVE LIMIT STACK   | no        |

use super::construct::{rt_construct, rt_plan_materialize};
use super::affine::rt_affine_drop;
use super::callback::{rt_callback_call, rt_ffi_close, rt_ffi_open};
use super::mutvec::{
    rt_mv_at, rt_mv_clear, rt_mv_clear_drop, rt_mv_empty, rt_mv_from_list, rt_mv_len, rt_mv_pop, rt_mv_push, rt_mv_share,
    rt_mv_swap, rt_mv_swap_drop, rt_mv_take, rt_mv_take_front, rt_mv_to_list,
};
use super::coroutine::{rt_co_create, rt_co_done, rt_co_failed, rt_co_release, rt_co_resume, rt_co_resume0, rt_co_start, rt_co_yield};
use super::error::{semantic_kind, RtError};
use super::ffifixture::{
    rt_ffi_fixture_copy, rt_ffi_fixture_fill, rt_ffi_fixture_fill_checked, rt_ffi_fixture_mixed, rt_ffi_fixture_read,
    rt_ffi_fixture_read_reentrant,
};
use super::ffi::{rt_ffi_bad_address, rt_ffi_bad_bool, rt_ffi_box_i64, rt_ffi_box_u64, rt_ffi_contract_violation, rt_ffi_int_word, rt_ffi_word_cmp, rt_raw_admit, rt_raw_bits, rt_raw_from_bits, rt_raw_narrow, rt_raw_new};
use super::nview::{
    rt_cptr_fixture_bytes, rt_cptr_fixture_memory, rt_cptr_offset, rt_mbytes_write, rt_mbytes_write_ptr, rt_native_load,
    rt_bin_load_array, rt_native_load_array, rt_bin_store_array, rt_native_store_array, rt_bin_store_ptr,
    rt_native_load_ptr, rt_native_store, rt_native_store_ptr,
};
use super::syscall::{rt_linux_aarch64_syscall, rt_linux_x86_64_syscall};
use super::value::*;
use super::vm::{current_program, Identity, Vm, NativeInfo};
use crate::nir::OpCode;
use super::decimal::{rt_decimal_cmp, rt_decimal_round, rt_decimal_to_f64, rt_decimal_to_str};
use super::inttext::{rt_int_to_str, rt_str_to_int};
use num_bigint::BigInt;
use num_traits::Signed;
use std::cmp::Ordering;
use std::rc::Rc;
use unicode_general_category::{get_general_category, GeneralCategory};

/// Whether OP's runtime implementation may allocate (and so may trigger a
/// collection): exactly the "allocates" column of the table above, in one
/// place, so codegen::roots's safepoint classification (which Op instructions
/// are GC safepoints) reads this instead of keeping its own copy of the same
/// fact. `IAdd`/`ISub`/`IMul` are here because their fast (small-Int) path
/// never allocates but their BigInt-overflow fallback (`rt_int_add` etc.)
/// might; codegen has no cheaper way to tell the two paths apart from NIR
/// alone, so the whole instruction is conservatively a safepoint (see
/// codegen::roots's module doc). `IMod` likewise: a BigInt operand can give
/// a remainder outside the small-Int range, which `rt_int_mod` allocates.
/// The raw `RIMod`/`RIModTotal` are not here: both operands are proven small,
/// so the remainder is small too (|r| < |b| <= 2^62) and no path allocates
/// (RIMod's zero-divisor path only records the error).
pub fn op_may_allocate(op: OpCode) -> bool {
    use OpCode::*;
    matches!(
        op,
        // A floating-point result is a heap object (KIND_FLOAT); truncation
        // may make a BigInt. The comparisons allocate nothing.
        F64Add | F64Sub | F64Mul | F64Div | F64Neg | F64FromInt | F64Trunc | F64Round |
        // A DecimalRounded result is one too (KIND_DECIMAL), its decay a
        // Float64, its text a String; its comparisons allocate nothing.
        D64Add | D64Sub | D64Mul | D64Div | D64Neg | D64ToF64 | D64Round | D64ToStr |
        // An Int's text is a String, a text's Int may be a BigInt
        // (runtime::inttext).
        IntToStr | StrToInt |
        // A raw C floating value is a heap object (KIND_RAWF32/64), its bit
        // pattern may be a BigInt, its admission a Float64
        // (RAW-C-FLOAT-FFI-MILESTONE-1.md).
        RawFromBits32 | RawFromBits64 | RawBits64 | RawAdmit32 | RawAdmit64 | RawNarrow32 | RawNarrow64 |
        IAdd | ISub | IMul | IMod | IAnd | IOr | IXor | IShl | IShr | Substr | DecodeCharAt | ShortToStr | AsciiToStr | StrLower | StrCat | StrAppendChar
            | StrUtf8Bytes | Argv | ListNew | ListAppend | MutArrayAllocate | MutArrayFreeze | MkOk
            // The owned byte storage is one allocation (a collection may run
            // first); the empty storage is a shared static (no allocation).
            | BytesFromList | BytesJoin | BytesDecodeUtf8 | BytesSlice
            // The writable storage family (MUTABLE-BYTES.md): each of these
            // but length/address makes a fresh object (a collection may run
            // first, with the operands rooted).
            | MBytesNew | MBytesFrom | MBytesSet | MBytesClone | MBytesFreeze | MBytesFreezePrefix
            // Fixed binary layouts (BINARY-LAYOUT.md): a fresh zeroed storage;
            // a 64-bit field read outside the small-Int range is a BigInt.
            | BytesZeroed | BinLoad
            // A native view's 64-bit field read outside the small-Int range
            // is a BigInt (NATIVE-LAYOUT-VIEWS.md).
            | NativeLoad
            // A layout write into byte storage makes a fresh storage (the
            // MutableBytes rule), the fixture's byte copy a List
            // (NATIVE-LAYOUT-WRITES.md); a store through a native edit
            // allocates nothing.
            | MBytesWrite | MBytesWritePtr | CPtrFixtureBytes
            // A fixed array's row read makes its List (FIXED-LAYOUT-
            // ARRAYS.md); the row writes allocate nothing.
            | BinLoadArray | NativeLoadArray
            // The proven siblings allocate exactly like their checked forms; only
            // their op_may_error classification differs.
            | SubstrProven | MutArrayFreezeProven | MkError
            | SetFromList
            // The raw result register is boxed as a BigInt when it is outside
            // the small-Int range (runtime/syscall.rs).
            | SyscallLinuxX86_64 | SyscallLinuxAarch64
            // A C word outside the small-Int range is boxed as a BigInt
            // (C-FFI-ERROR-CAPTURE-MILESTONE-2.md); the word comparisons
            // allocate nothing.
            | CWBox
            // The borrow test fixture's foreign operations
            // (runtime/ffifixture.rs): a foreign call may run Botlish code
            // (read_reentrant collects and allocates on purpose), and read
            // builds a List, so each is a safepoint whose stack map holds
            // the exposed storages its keepalives keep live.
            | FfiFixtureRead | FfiFixtureReadReentrant | FfiFixtureFill | FfiFixtureFillChecked | FfiFixtureCopy
            | FfiFixtureMixed
            // Same allocation behavior as SetFromList (same runtime helper,
            // same `new_set` construction) -- only its own `op_may_error`
            // classification differs. See SetFromListTotal's own doc
            // comment (nir.rs) and M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md:
            // may_error and may_gc are independent effect dimensions, and
            // this milestone changes only the former.
            | SetFromListTotal
            // Coroutines (COROUTINES.md): create allocates the handle; start,
            // resume and yield run arbitrary code (the body's segment, or
            // other coroutines while this one is suspended), and suspension
            // in particular must be a safepoint -- a suspended frame's roots
            // are found only through its stack map.
            | CoCreate | CoStart | CoResume | CoResume0 | CoYield
            // A fused coroutine's cached failure (codegen::fusion): one
            // terminal coroutine object.
            | CoFailed
            // MutableVector (MUTABLE-VECTOR.md): a new header (from_list, a
            // share) or a List (the snapshot); the mutations allocate no
            // Botlish object (runtime/mutvec.rs).
            | MvFromList | MvShare | MvToList
            // MutableArray (MUTABLE-ARRAY.md): a new header (and backing),
            // or a List; generate runs the factory's code for every slot.
            // The writes allocate no Botlish object.
            | MutArrayCreate | MutArrayFromList | MutArrayGenerate | MutArrayGenerateDrop | MutArrayToList
    )
}

/// Whether OP can report a Botlish semantic error by returning NO_VALUE.
pub fn op_may_error(op: OpCode) -> bool {
    use OpCode::*;
    matches!(op, IMod | IShl | IShr | VEq | Hash | Substr
        // The declared NonFiniteFloat (FLOAT64-MILESTONE-1.md).
        | F64Add | F64Sub | F64Mul | F64Div | F64FromInt
        // DecimalRounded's arithmetic (NonFiniteFloat) and quantization
        // (UnrepresentableDecimal: DECIMAL-ROUNDED-MILESTONE-1.md).
        | D64Add | D64Sub | D64Mul | D64Div | D64Round | StrCat | StrAppendChar | StrUtf8Bytes | StrCharAt | Argv | StrIsTclAlpha | StrIsTclAlnum
        // A text that is no Int's canonical decimal text: the declared
        // InvalidIntegerText (runtime::inttext). Its inverse, IntToStr, and
        // the other conversions to text and to Int never fail.
        | StrToInt
        // A raw value's admission or a binary32 narrowing: the declared
        // NonFiniteFloat; a bit pattern out of the format's range: RANGE; an
        // operand of another kind: TYPE (a checked program reaches neither).
        | RawFromBits32 | RawFromBits64 | RawBits32 | RawBits64 | RawAdmit32 | RawAdmit64 | RawNarrow32 | RawNarrow64
        // The raw mod's zero divisor (ARITHMETIC, IMod's own error).
        // RIModTotal is not here: native/lower.tcl emits it only where the
        // divisor's Range excludes 0 (see OpCode::RIMod).
        | RIMod
        // The C pointer test fixture's out-of-range address (RANGE).
        | CPtrFixture
        // The borrow test fixture: an operand that is no address or count
        // (TYPE; a checked program passes neither), and fill_checked's
        // declared UpperOverrun.
        | FfiFixtureRead | FfiFixtureReadReentrant | FfiFixtureFill | FfiFixtureFillChecked | FfiFixtureCopy
        | FfiFixtureMixed
        // A non-byte element (TYPE, never a truncation), an operand that is
        // not a byte storage (TYPE), an oversized storage (RANGE). A checked
        // program cannot produce any of them: lib/abi/bytes.bot's creator takes
        // a List[Byte] and its storage field only ever holds a storage.
        | BytesFromList | BytesJoin | BytesDecodeUtf8 | BytesSlice | BytesLen | BytesAddr
        // The writable family: a length that is not 0..the ceiling (RANGE), an
        // operand of the wrong kind (TYPE: the readable and writable storages
        // are never interchanged), an index/count outside the payload (RANGE),
        // a value that is not a byte (TYPE). Checked programs cannot produce
        // any of them: lib/abi/bytes.bot's wrappers prove each before the call.
        | MBytesNew | MBytesFrom | MBytesLen | MBytesSet | MBytesClone | MBytesFreeze | MBytesFreezePrefix | MBytesAddr
        // Fixed binary layouts: an operand of the wrong kind (TYPE), an
        // offset or length outside the storage or a value outside its
        // encoding (RANGE). A checked program produces none of them: the
        // layout's fields lie inside its size, the length is checked before
        // any load, and a field's type is its encoding's exact range.
        | BinLoad | BinStore | BytesZeroed
        // Native layout views (runtime/nview.rs): an operand that is no C
        // address word, the null address or a malformed encoding (none of
        // which a checked program produces), and a pointer field holding an
        // address no C address word can hold (NATIVE ADDRESS, like a C
        // call's pointer result). The fixture's: a non-storage operand.
        | NativeLoad | NativeLoadPtr | CPtrOffset | CPtrFixtureMemory
        // Native layout writes (runtime/nview.rs): likewise an operand a
        // checked program never produces -- a value outside its field's
        // encoding (checked before anything is written), no C address word,
        // a storage of another kind -- or a pointer no field width holds.
        | NativeStore | NativeStorePtr | MBytesWrite | MBytesWritePtr | CPtrFixtureBytes
        // Fixed arrays' rows (runtime/nview.rs), likewise: an operand of the
        // wrong kind, a row outside its storage, an element outside its
        // encoding (encoded before anything is written).
        | BinLoadArray | NativeLoadArray | BinStoreArray | NativeStoreArray | BinStorePtr
        // Only on an operand that is not a 64-bit register word (TYPE, never
        // a truncation: runtime/syscall.rs), which a checked program cannot
        // produce. The kernel's own result is never an error here. (On
        // another architecture's target the transport is NATIVE
        // UNSUPPORTED, also through NO_VALUE.)
        | SyscallLinuxX86_64 | SyscallLinuxAarch64
        | ListNew | ListGet | ListAppend | ListWithLength | MutArrayAllocate | MutArrayGet | MutArraySet | MutArrayCopy | MutArrayFreeze
        // MutableVector: the declared IndexNotFound (runtime/mutvec.rs).
        | MvAt | MvPop | MvTake | MvSwap | MvSwapDrop
        // MutableArray: a capacity outside the limit (RANGE), the declared
        // IndexNotFound, and whatever a factory call fails with.
        | MutArrayCreate | MutArrayGenerate | MutArrayGenerateDrop | MutArraySwap | MutArraySwapDrop
        | MutArraySetDrop
        | ResultValue | ResultError | RegionCheck | StrRegionIsTclAlpha | StrRegionIsTclAlnum
        // Construction (dedup) and membership (a linear equal-scan) can
        // both raise EQUALITY through the same pre-existing
        // core::value::equal restriction (Block/Native/MutArray have no
        // structural equality) -- never a new failure mode this milestone
        // invents: see rt_set_from_list's and rt_set_contains's own doc
        // comments, and MINIMAL-IMMUTABLE-SET.md's "Deduplication
        // semantics"/"Membership semantics".
        //
        // SetContainsTotal and SetFromListTotal are deliberately *not*
        // listed here: each is SetContains/SetFromList at a call site
        // native/lower.tcl's own static equality-totality proof
        // (hir::types::IsEqualityTotal) already showed can never reach
        // rt_set_contains's/rt_set_from_list's own EQUALITY branch --
        // op_may_error is keyed by opcode, not by which runtime helper an
        // opcode happens to share, so giving the proven-safe invocation its
        // own opcode is what lets it (and only it) fall out of this list
        // (M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md,
        // M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md). Generic SetFromList/
        // SetContains keep their unconditional classification.
        | SetFromList | SetContains
        // The table hash's dynamically dispatched entry refuses a value with
        // no hash, as Hash does. VEqTotal, HashTotal and TableHashTotal are
        // deliberately *not* listed: each is its generic sibling at a call
        // site whose operands native/lower.tcl proved equality-total or
        // Hashable (hir::types::IsEqualityTotal, IsHashable), so the shared
        // helper's refusal is unreachable there (HASHABLE-AND-KEYED-HASH.md,
        // "Total lowering").
        | TableHash
        // A segment ends with the body's unhandled error; a yield outside a
        // running coroutine is a defensive runtime check a checked program
        // never reaches.
        | CoStart | CoResume | CoResume0 | CoYield)
}

pub type GenericEntry = extern "C" fn(*mut Vm, Value, *const Value) -> Value;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

// ---------------------------------------------------------------------------
// Errors

#[unsafe(no_mangle)]
pub extern "C" fn rt_type_error(p: *mut Vm, v: Value, kind: u64, context: Value) -> Value {
    let context = str_of(context).as_str().to_string();
    vm(p).fail(RtError::Type { context, expected: Kind::from_code(kind as u8), got: v })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_not_boolean(p: *mut Vm, v: Value) -> Value {
    vm(p).fail(RtError::NotBoolean { got: v })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_raise(p: *mut Vm, kind: Value, message: Value) -> Value {
    let kind_text = str_of(kind).as_str();
    let message = str_of(message).as_str().to_string();
    let error = match semantic_kind(kind_text) {
        Some(kind) => RtError::Semantic { kind, message },
        None if kind_text == "BUG" => RtError::Bug(message),
        None => RtError::Bug(format!("unknown error kind {kind_text}: {message}")),
    };
    vm(p).fail(error)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_stack_overflow(p: *mut Vm) -> Value {
    vm(p).fail(RtError::StackOverflow)
}

// ---------------------------------------------------------------------------
// Declared error completions (EXPLICIT-ERROR-COMPLETIONS.md)
//
// `fail NAME` (native/lower.tcl's Inst::Fail) sets the pending declared-
// error id ID (a small compile-time constant native/lower.tcl assigns each
// declared error name, never 0) and a fallback RtError in case this
// propagates all the way to the program boundary uncaught, then returns
// NO_VALUE exactly like `raise` -- every ordinary call site's existing
// `may_error` check (codegen::clif) already propagates that NO_VALUE with
// no change of its own. A `handle` (codegen::clif's PushErrorExit/
// PopErrorExit) that catches the matching id calls rt_clear_declared_error
// to resume normally.

#[unsafe(no_mangle)]
pub extern "C" fn rt_fail_declared(p: *mut Vm, id: u64, name: Value) -> Value {
    let name_text = str_of(name).as_str().to_string();
    let vm = vm(p);
    vm.declared_error = id as u32;
    vm.declared_payload.clear();
    vm.fail(RtError::Semantic { kind: "UNCAUGHT-ERROR", message: format!("uncaught propagated error: <error {name_text}>") })
}

/// `fail NAME {field: value, ...}` (ERROR-PAYLOADS.md; Inst::Fail with
/// payload registers): `rt_fail_declared`, plus the payload's N field values
/// at FIELDS, in the slot order of its anonymous struct SHAPE, copied into
/// the Vm's payload slots (`Vm::declared_payload`, a GC root) -- the field
/// values are transported as they are, no struct object is built for them.
/// The slots reuse their capacity: a payload-bearing failure allocates no
/// heap object. Only an uncaught one is ever rendered (`Vm::describe_error`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_fail_declared_payload(p: *mut Vm, id: u64, name: Value, shape: u64, n: u64, fields: *const Value) -> Value {
    let fields = unsafe { std::slice::from_raw_parts(fields, n as usize) };
    let name_text = str_of(name).as_str().to_string();
    let vm = vm(p);
    vm.declared_error = id as u32;
    vm.declared_payload.clear();
    vm.declared_payload.extend_from_slice(fields);
    vm.declared_payload_shape = shape as u32;
    vm.fail(RtError::Semantic { kind: "UNCAUGHT-ERROR", message: format!("uncaught propagated error: <error {name_text}>") })
}

/// Field INDEX (slot order) of the pending declared error's payload: what a
/// handler that matched it receives (codegen::clif's DeclaredPayload),
/// before `rt_clear_declared_error` releases the slots. No allocation.
#[unsafe(no_mangle)]
pub extern "C" fn rt_declared_payload(p: *mut Vm, index: u64) -> Value {
    // (Out of range only in a program run despite its diagnostics -- a
    // payload-bearing error raised without one, MISSING-ERROR-PAYLOAD,
    // -strict 0: unit, never a read past the slots.)
    vm(p).declared_payload.get(index as usize).copied().unwrap_or(UNIT)
}

/// The pending declared-error id (0 = none), for a `handle`'s own dispatch
/// (codegen::clif's DeclaredErrorEq): a plain small integer widened to a
/// full 64-bit word (every runtime helper's Cranelift signature declares
/// one I64 return -- see `helpers()` -- so this must never leave the upper
/// bits undefined the way a bare `-> u32` extern "C" fn could), never a GC
/// root and never an ordinary Botlish `Value`.
#[unsafe(no_mangle)]
pub extern "C" fn rt_declared_error(p: *mut Vm) -> u64 {
    vm(p).declared_error as u64
}

/// Resumes normal execution after a `handle` has matched and is about to
/// run its handler body: clears both the declared-error id and the
/// fallback RtError it arrived with (item 53: no hidden handler, but also
/// no stale pending error surviving a successful catch). Returns an
/// unused word (every helper's declared signature returns one I64; the
/// generated caller simply discards it -- see codegen::clif's
/// ClearDeclaredError).
#[unsafe(no_mangle)]
pub extern "C" fn rt_clear_declared_error(p: *mut Vm) -> u64 {
    let vm = vm(p);
    vm.declared_error = 0;
    vm.declared_payload.clear();
    vm.error = None;
    0
}

// ---------------------------------------------------------------------------
// Ints

fn int_binary(p: *mut Vm, a: Value, b: Value, small: fn(i64, i64) -> Option<i64>, big: fn(BigInt, BigInt) -> BigInt) -> Value {
    if let (Some(x), Some(y)) = (int_small(a), int_small(b)) {
        if let Some(r) = small(x, y) {
            return vm(p).new_int(r);
        }
    }
    let r = big(int_to_big(a), int_to_big(b));
    vm(p).new_big(r)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_add(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, i64::checked_add, |x, y| x + y)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_sub(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, i64::checked_sub, |x, y| x - y)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_mul(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, i64::checked_mul, |x, y| x * y)
}

/// Euclidean modulo (core/primitives.tcl's modulo): 0 <= result < |b|,
/// regardless of the sign of a or b. Native `%` (small i64, or BigInt) may
/// follow either sign convention -- whichever it picks, "if the result is
/// negative, add |b|" always lands on the unique representative in [0, |b|)
/// congruent to a mod b, so both paths agree with each other and with the
/// reference interpreter's identical fixup (core::primitives::modulo).
/// Generated code computes the small x small case inline (codegen::clif's
/// `euclid_mod`): it calls this only for a BigInt operand or a zero divisor,
/// and the raw `rimod` calls it with a zero divisor to raise the same error.
#[unsafe(no_mangle)]
pub extern "C" fn rt_int_mod(p: *mut Vm, a: Value, b: Value) -> Value {
    if let (Some(x), Some(y)) = (int_small(a), int_small(b)) {
        if y == 0 {
            return vm(p).fail(RtError::Semantic { kind: "ARITHMETIC", message: "mod: division by zero".to_string() });
        }
        let r = x % y;
        return vm(p).new_int(if r < 0 { r + y.abs() } else { r });
    }
    let (aa, bb) = (int_to_big(a), int_to_big(b));
    if bb == BigInt::from(0) {
        return vm(p).fail(RtError::Semantic { kind: "ARITHMETIC", message: "mod: division by zero".to_string() });
    }
    let mut r = &aa % &bb;
    if r.sign() == num_bigint::Sign::Minus {
        r += bb.abs();
    }
    vm(p).new_big(r)
}

/// Maximum shift amount `rt_int_shl`/`rt_int_shr` accept: generous enough for
/// any real bit-manipulation use (nibble/byte positioning shifts by 4), but
/// finite, so a shift amount does not try to allocate an astronomically
/// large BigInt. Not a language-visible width limit on Int itself.
const MAX_SHIFT: i64 = 1 << 20;

/// The nonnegative i64 shift amount B, or a RANGE failure recorded on P (also
/// returned as `None`) if B is negative, not a small Int, or exceeds
/// MAX_SHIFT.
fn shift_amount(p: *mut Vm, b: Value) -> Option<u32> {
    match int_small(b) {
        Some(k) if (0..=MAX_SHIFT).contains(&k) => Some(k as u32),
        _ => {
            vm(p).fail(RtError::Semantic {
                kind: "RANGE",
                message: format!("shift amount out of range (0..{MAX_SHIFT})"),
            });
            None
        }
    }
}

/// Bitwise AND/OR/XOR (two's-complement, matching Tcl's own `&`/`|`/`^` and
/// `num_bigint::BigInt`'s BitAnd/BitOr/BitXor): total over every Int, never
/// fails. core/primitives.tcl documents these as the reference semantics;
/// this is the same computation over the runtime's own Int representation.
#[unsafe(no_mangle)]
pub extern "C" fn rt_int_and(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, |x, y| Some(x & y), |x, y| x & y)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_or(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, |x, y| Some(x | y), |x, y| x | y)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_xor(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, |x, y| Some(x ^ y), |x, y| x ^ y)
}

/// A << K (exact: A * 2^K), K a nonnegative Int (see shift_amount).
#[unsafe(no_mangle)]
pub extern "C" fn rt_int_shl(p: *mut Vm, a: Value, b: Value) -> Value {
    let Some(k) = shift_amount(p, b) else { return NO_VALUE };
    if let Some(x) = int_small(a) {
        if let Some(r) = shl_i64_exact(x, k) {
            return vm(p).new_int(r);
        }
    }
    vm(p).new_big(int_to_big(a) << (k as usize))
}

/// X << K as an i64, or None if the exact result does not fit one. Not
/// `i64::checked_shl`: that only rejects K >= 64 and silently drops the
/// bits shifted out, so `2 << 62` would come back as i64::MIN. A shift is
/// exact exactly when shifting back recovers X (the arithmetic right shift
/// restores every dropped bit only if each was a copy of the sign bit).
fn shl_i64_exact(x: i64, k: u32) -> Option<i64> {
    if k >= 64 {
        return if x == 0 { Some(0) } else { None };
    }
    let r = x.wrapping_shl(k);
    if (r >> k) == x { Some(r) } else { None }
}

/// A >> K: arithmetic (sign-extending) shift, i.e. floor(A / 2^K) -- the
/// two's-complement convention `num_bigint::BigInt`'s `Shr` also follows, so
/// the small-Int and BigInt paths agree exactly. Never fails once K itself is
/// valid: a right shift only ever shrinks magnitude.
#[unsafe(no_mangle)]
pub extern "C" fn rt_int_shr(p: *mut Vm, a: Value, b: Value) -> Value {
    let Some(k) = shift_amount(p, b) else { return NO_VALUE };
    if let Some(x) = int_small(a) {
        // i64 >> is arithmetic (sign-extending); a shift of >= 63 is
        // reliably all-sign-bits, matching an exact BigInt shift's limit.
        return vm(p).new_int(x >> k.min(63));
    }
    vm(p).new_big(int_to_big(a) >> (k as usize))
}

/// The order of two Ints, read in place: a BigInt is borrowed, never
/// copied, so no comparison allocates (a C call's error state survives one
/// that runs before it is read: C-FFI-ERROR-CAPTURE-MILESTONE-2.md).
fn int_compare(a: Value, b: Value) -> Ordering {
    match (int_small(a), int_small(b)) {
        (Some(x), Some(y)) => x.cmp(&y),
        (Some(x), None) => small_big_order(x, big_of(b)),
        (None, Some(y)) => small_big_order(y, big_of(a)).reverse(),
        (None, None) => big_of(a).cmp(big_of(b)),
    }
}

/// The order of the small Int X against the BigInt N.
fn small_big_order(x: i64, n: &BigInt) -> Ordering {
    use num_traits::ToPrimitive;
    match n.to_i64() {
        Some(y) => x.cmp(&y),
        None if n.is_negative() => Ordering::Greater,
        None => Ordering::Less,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_cmp(_p: *mut Vm, a: Value, b: Value) -> i64 {
    int_compare(a, b) as i64
}

// ---------------------------------------------------------------------------
// Equality (core::value::equal)

/// core::value::equal's and core::hashing::Mix's refusals of a
/// DecimalRounded value, word for word.
pub const DECIMAL_EQUALITY_MESSAGE: &str = "== of a DecimalRounded value needs the precision of its type, which this equality does not know (compare DecimalRounded values directly)";
pub const DECIMAL_HASH_MESSAGE: &str = "hash of a DecimalRounded value needs the precision of its type, which a hash does not know";

/// core::value::equal's and core::hashing::Encode's refusals of a raw C
/// floating value (RAW-C-FLOAT-FFI-MILESTONE-1.md), word for word.
pub fn raw_equality_message(v: Value) -> String {
    format!("== is not defined for a raw C floating value ({}): compare its bits (std::ffi::c::raw::float_to_bits, std::ffi::c::raw::double_to_bits) or the Float64 it admits to", super::show::show(v))
}
pub fn raw_hash_message(v: Value) -> String {
    format!("hash is not defined for a raw C floating value ({}): hash its bits", super::show::show(v))
}

fn equal(p: *mut Vm, a: Value, b: Value) -> Result<bool, ()> {
    let (ka, kb) = (kind_of(a), kind_of(b));
    for (k, v) in [(ka, a), (kb, b)] {
        if matches!(k, Kind::RawFloat32 | Kind::RawFloat64) {
            vm(p).fail(RtError::Semantic { kind: "EQUALITY", message: raw_equality_message(v) });
            return Err(());
        }
    }
    // MutableArray, like Block/Native, has no structural equality (req #31:
    // its identity/equality semantics are a separate design question).
    if matches!(ka, Kind::Block | Kind::Native | Kind::MutArray | Kind::Coroutine | Kind::MutVec | Kind::CPtr)
        || matches!(kb, Kind::Block | Kind::Native | Kind::MutArray | Kind::Coroutine | Kind::MutVec | Kind::CPtr)
    {
        vm(p).fail(RtError::Equality { a, b });
        return Err(());
    }
    if ka == Kind::DecimalRounded || kb == Kind::DecimalRounded {
        // core::value::equal's DecimalRounded case: equality at the
        // precision of a static type, which a type-blind `==` does not know
        // (DECIMAL-ROUNDED-MILESTONE-1.md).
        vm(p).fail(RtError::Semantic { kind: "EQUALITY", message: DECIMAL_EQUALITY_MESSAGE.to_string() });
        return Err(());
    }
    if ka != kb {
        return Ok(false);
    }
    Ok(match ka {
        Kind::ImmutableSet => set_equal(p, a, b)?,
        Kind::Int => a == b || (!is_small(a) && !is_small(b) && int_compare(a, b) == Ordering::Equal),
        Kind::Str => str_of(a).as_bytes() == str_of(b).as_bytes(),
        Kind::Bool => a == b,
        Kind::Unit => true,
        // Immediate, canonical (one codepoint, one word): word equality is
        // exactly value equality, like Bool.
        Kind::UnicodeChar => a == b,
        // An enum case word is canonical (ENUMS.md): the same enum
        // declaration and the same case of it have one word, so word
        // equality is exactly nominal equality -- another enum's
        // same-spelled case is another word.
        Kind::Enum => a == b,
        // A finite number with one representation (no NaN, no negative
        // zero: FloatType::admit), so equal numbers have equal bits.
        Kind::Float64 => float_bits(a) == float_bits(b),
        // (Refused above: a DecimalRounded value has no type-blind
        // equality.)
        Kind::DecimalRounded | Kind::RawFloat32 | Kind::RawFloat64 => unreachable!(),
        // Exact byte-sequence equality (core::value::equal's bytestore
        // case): length and every byte, never the storage's identity or
        // address -- a static constant, a heap buffer and a copy of either
        // are equal iff their bytes are.
        Kind::ByteStore => bytes_of(a) == bytes_of(b),
        // The same, for the writable storage: its current contents, never
        // its identity (a MutableBytes has none).
        Kind::MutByteStore => mutbytes_of(a) == mutbytes_of(b),
        Kind::List => {
            let (xs, ys) = (list_of(a).items(), list_of(b).items());
            if xs.len() != ys.len() {
                return Ok(false);
            }
            for (x, y) in xs.iter().zip(ys.iter()) {
                if !equal(p, *x, *y)? {
                    return Ok(false);
                }
            }
            true
        }
        Kind::Result => {
            let (x, y) = (result_of(a), result_of(b));
            x.ok == y.ok && equal(p, x.payload, y.payload)?
        }
        Kind::Struct => {
            // Equal iff the same shape (an anonymous struct's field set, or
            // one named declaration: shapes are interned, so equal shape
            // means equal shape index) and every field equal, slot by
            // slot. A named struct never equals an anonymous one or another
            // named struct; a shape mismatch is unequal without comparing
            // contents (core::value::equal's struct case).
            let (x, y) = (struct_of(a), struct_of(b));
            if x.shape != y.shape {
                return Ok(false);
            }
            if let Some(identity) = current_program(|prog| prog.shapes[x.shape as usize].identity) {
                // A shape that declares its identity (REPRESENTATION-
                // INDEPENDENT-VALUE-IDENTITY.md): equal when the identities
                // are, whatever its other fields hold. Opaque, so a refusal
                // inside it is the opaque values' (below).
                return match identity_equal(p, identity, x.fields(), y.fields()) {
                    Ok(r) => Ok(r),
                    Err(()) => {
                        let vm = vm(p);
                        if matches!(vm.error, Some(RtError::Equality { .. })) {
                            vm.error = Some(RtError::Equality { a, b });
                        }
                        Err(())
                    }
                };
            }
            for (u, w) in x.fields().iter().zip(y.fields().iter()) {
                match equal(p, *u, *w) {
                    Ok(true) => {}
                    Ok(false) => return Ok(false),
                    Err(()) => {
                        // An opaque struct's equality is its
                        // representation's, which no message may show
                        // (OPAQUE-STRUCTS.md): a refusal inside it is the
                        // opaque values' (core::value::equal's struct case;
                        // ORDERED-MUTABLE-MAP-SET.md).
                        let opaque = current_program(|prog| prog.shapes[x.shape as usize].opaque);
                        if opaque {
                            let vm = vm(p);
                            if matches!(vm.error, Some(RtError::Equality { .. })) {
                                vm.error = Some(RtError::Equality { a, b });
                            }
                        }
                        return Err(());
                    }
                }
            }
            true
        }
        Kind::Block | Kind::Native | Kind::MutArray | Kind::Coroutine | Kind::MutVec | Kind::CPtr => unreachable!(),
    })
}

/// Set equality, independent of construction/insertion order (MINIMAL-
/// IMMUTABLE-SET.md item 16, matching core::value::equal's own Tcl-side
/// implementation exactly): both operands are already deduplicated by
/// construction, so equal cardinality plus "every member of A has an equal
/// member in B" is exactly set equality. O(n^2), the same complexity as
/// construction/membership -- the simple representation's deliberate cost
/// (see this module's own doc comment for `rt_set_from_list`).
fn set_equal(p: *mut Vm, a: Value, b: Value) -> Result<bool, ()> {
    let (xs, ys) = (set_of(a).items(), set_of(b).items());
    if xs.len() != ys.len() {
        return Ok(false);
    }
    if xs.len() > PAIRWISE_LIMIT {
        // A larger set is matched by hash (`bucket_match`, identity
        // equality's matcher): expected O(n). Where a member has no hash,
        // the comparison below is the one that refuses it.
        let (a, b) = (Entries { keys: xs, vals: None }, Entries { keys: ys, vals: None });
        if let Some(r) = bucket_match(p, &a, &b, 0)? {
            return Ok(r);
        }
    }
    for x in xs {
        let mut found = false;
        for y in ys {
            if equal(p, *x, *y)? {
                found = true;
                break;
            }
        }
        if !found {
            return Ok(false);
        }
    }
    Ok(true)
}

// ---------------------------------------------------------------------------
// Semantic identity (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md;
// core/value.tcl's IdentityEqual and BucketMatch, core/hashing.tcl's
// Identity)
//
// A struct shape may declare its identity apart from its representation: the
// elements of one List field in no order (members), or the pairs of two in no
// order (associations). Equality is multiset equality of those entries (a
// pair matches a pair whose key and value are both equal): set or map
// equality for the distinct members or keys an owner keeps, and an
// equivalence coherent with the hashes' commutative combination (`walk`)
// whatever the representation holds. Matching is greedy, exact for an
// equivalence: a positional prefix first (two values built alike match in
// order, unhashed), then the rest by hash buckets (expected O(n)), or
// pairwise where the rest is small or an entry has no hash (its comparison
// refuses it). Nothing allocates on the managed heap and no Botlish code
// runs, so equality stays no safepoint: the buckets are two Rust vectors per
// comparison of more than PAIRWISE_LIMIT unmatched entries.

/// Up to this many unmatched entries are compared pairwise, never hashed.
const PAIRWISE_LIMIT: usize = 8;

/// The entries of a value's identity: its members (VALS None), or its keys
/// and their values, as many as both Lists hold.
struct Entries<'a> {
    keys: &'a [Value],
    vals: Option<&'a [Value]>,
}

/// The entries of identity IDENTITY over a struct value's FIELDS.
fn identity_entries(identity: Identity, fields: &[Value]) -> Entries<'_> {
    match identity {
        Identity::Members(f) => Entries { keys: list_of(fields[f]).items(), vals: None },
        Identity::Associations(k, v) => {
            let (keys, vals) = (list_of(fields[k]).items(), list_of(fields[v]).items());
            let n = keys.len().min(vals.len());
            Entries { keys: &keys[..n], vals: Some(&vals[..n]) }
        }
    }
}

/// Whether entry X of A equals entry Y of B: its key, and for pairs its value.
fn entry_equal(p: *mut Vm, a: &Entries, x: usize, b: &Entries, y: usize) -> Result<bool, ()> {
    if !equal(p, a.keys[x], b.keys[y])? {
        return Ok(false);
    }
    match (a.vals, b.vals) {
        (Some(av), Some(bv)) => equal(p, av[x], bv[y]),
        _ => Ok(true),
    }
}

/// Whether two values of one shape whose identity is IDENTITY, with fields
/// XF and YF, are equal.
fn identity_equal(p: *mut Vm, identity: Identity, xf: &[Value], yf: &[Value]) -> Result<bool, ()> {
    let (a, b) = (identity_entries(identity, xf), identity_entries(identity, yf));
    let n = a.keys.len();
    if n != b.keys.len() {
        return Ok(false);
    }
    let mut i = 0;
    while i < n && entry_equal(p, &a, i, &b, i)? {
        i += 1;
    }
    if i == n {
        return Ok(true);
    }
    if n - i > PAIRWISE_LIMIT
        && let Some(r) = bucket_match(p, &a, &b, i)?
    {
        return Ok(r);
    }
    let mut used = vec![false; n - i];
    'entries: for x in i..n {
        for y in i..n {
            if !used[y - i] && entry_equal(p, &a, x, &b, y)? {
                used[y - i] = true;
                continue 'entries;
            }
        }
        return Ok(false);
    }
    Ok(true)
}

/// The keyed table hash of V as a 64-bit word, or None (the Vm's error state
/// as it was) when V has no hash: the buckets' hash. Keyed, so no input
/// arranged against the public hash makes the buckets degenerate; equal
/// values hash equally in one process, which is all a bucket needs.
fn bucket_hash(p: *mut Vm, key: (u64, u64), v: Value) -> Option<u64> {
    let clean = vm(p).error.is_none();
    let mut sink = Sip13::new(key.0, key.1);
    match walk(p, &mut sink, v) {
        Ok(()) => Some(sink.finish()),
        Err(()) => {
            if clean {
                vm(p).error = None;
            }
            None
        }
    }
}

/// Matches A's entries from position FROM on against B's by hash: Some(true)
/// when every one has an unused equal entry of B, Some(false) when one has
/// none, None when a key has no hash (the caller compares pairwise, where
/// that entry is refused). Equal keys hash equally, so only entries of one
/// hash are compared; B's are found through an open-addressed index of
/// their positions, A's probed in order.
fn bucket_match(p: *mut Vm, a: &Entries, b: &Entries, from: usize) -> Result<Option<bool>, ()> {
    let n = a.keys.len();
    let m = n - from;
    let key = table_hash_key();
    let capacity = (2 * m).next_power_of_two().max(8);
    let mask = capacity - 1;
    let mut slots = vec![u32::MAX; capacity];
    let mut hashes = Vec::with_capacity(m);
    for y in from..n {
        let Some(h) = bucket_hash(p, key, b.keys[y]) else { return Ok(None) };
        let mut s = h as usize & mask;
        while slots[s] != u32::MAX {
            s = (s + 1) & mask;
        }
        slots[s] = (y - from) as u32;
        hashes.push(h);
    }
    let mut used = vec![false; m];
    for x in from..n {
        let Some(h) = bucket_hash(p, key, a.keys[x]) else { return Ok(None) };
        let mut s = h as usize & mask;
        loop {
            let j = slots[s];
            if j == u32::MAX {
                return Ok(Some(false));
            }
            let j = j as usize;
            if !used[j] && hashes[j] == h && entry_equal(p, a, x, b, from + j)? {
                used[j] = true;
                break;
            }
            s = (s + 1) & mask;
        }
    }
    Ok(Some(true))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_value_eq(p: *mut Vm, a: Value, b: Value) -> Value {
    match equal(p, a, b) {
        Ok(r) => bool_value(r),
        Err(()) => NO_VALUE,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_eq(_p: *mut Vm, a: Value, b: Value) -> Value {
    bool_value(str_of(a).as_bytes() == str_of(b).as_bytes())
}

// ---------------------------------------------------------------------------
// Hashing (core::hashing::hash): FNV-1a, byte-for-byte identical to the
// reference interpreter (core/hashing.tcl) by construction -- both fold the
// same kind-tag-then-payload bytes through the same 64-bit FNV-1a step, and
// both mask the final accumulator to 61 bits, so a hash result never needs a
// BigInt (2^61 comfortably fits SMALL_MAX = 2^62 - 1) regardless of backend.
// No random seed: see core/hashing.tcl's header for the stability contract.
//
// STATUS: bootstrap native -- candidate for stdlib replacement. This exists
// as a native (here and in core/hashing.tcl) only because Botlish has no
// wrapping-integer type to express FNV-1a's 64-bit wrapping multiply/XOR in
// itself; `wrapping_mul` below is standing in for that missing language
// feature, not evidence this belongs in the runtime long-term. Once Botlish
// has wrapping arithmetic and this runtime's hash semantics are actually
// specified (not just "whatever FNV-1a with these constants produces"),
// move this to an ordinary Botlish implementation and delete both copies.
// See core/hashing.tcl's header for the full rationale.

const FNV_OFFSET: u64 = 0xcbf29ce484222325;
const FNV_PRIME: u64 = 0x100000001b3;
const HASH_MASK: u64 = (1u64 << 61) - 1;

fn fnv1a(h: u64, bytes: &[u8]) -> u64 {
    let mut h = h;
    for &byte in bytes {
        h = (h ^ byte as u64).wrapping_mul(FNV_PRIME);
    }
    h
}

/// "00", "01", ..., "99": two digits per division halve the dependent
/// division chain of a number's text.
const DECIMAL_PAIRS: &[u8; 200] = b"0001020304050607080910111213141516171819\
2021222324252627282930313233343536373839\
4041424344454647484950515253545556575859\
6061626364656667686970717273747576777879\
8081828384858687888990919293949596979899";

/// Writes N's decimal digits, at least MIN_DIGITS of them (zero-padded),
/// into BUF ending before END; returns where they start.
#[inline]
fn put_decimal_digits(buf: &mut [u8], mut end: usize, mut n: u64, min_digits: usize) -> usize {
    let stop = end - min_digits;
    while n >= 100 {
        let pair = 2 * (n % 100) as usize;
        n /= 100;
        end -= 2;
        buf[end..end + 2].copy_from_slice(&DECIMAL_PAIRS[pair..pair + 2]);
    }
    if n >= 10 {
        let pair = 2 * n as usize;
        end -= 2;
        buf[end..end + 2].copy_from_slice(&DECIMAL_PAIRS[pair..pair + 2]);
    } else {
        end -= 1;
        buf[end] = b'0' + n as u8;
    }
    while end > stop {
        end -= 1;
        buf[end] = b'0';
    }
    end
}

/// The canonical decimal text of the integer of magnitude MAG, negative when
/// NEG (never for zero): an optional '-', then the digits, without leading
/// zeros ("0" for zero) -- exactly the bytes `to_string()` gives an i64, a
/// u32 or a BigInt of that value (`tests::decimal_text_is_to_string`),
/// which is core/hashing.tcl's `Utf8Bytes` of an Int's or a code point's
/// text. Written into BUF, never the heap: hashing an Int or a UnicodeChar
/// used to format through `to_string`, one malloc and free per hash. 40
/// bytes hold u128::MAX's 39 digits and a sign; a magnitude beyond 64 bits
/// is cut into 19-digit chunks, so only those few rare values divide a u128.
#[inline]
pub(crate) fn decimal_text(neg: bool, mut mag: u128, buf: &mut [u8; 40]) -> &[u8] {
    const CHUNK: u128 = 10_000_000_000_000_000_000;
    let mut start = buf.len();
    while mag > u64::MAX as u128 {
        let rest = mag / CHUNK;
        start = put_decimal_digits(buf, start, (mag - rest * CHUNK) as u64, 19);
        mag = rest;
    }
    start = put_decimal_digits(buf, start, mag as u64, 1);
    if neg {
        start -= 1;
        buf[start] = b'-';
    }
    &buf[start..]
}

/// F of the canonical decimal text of the Int V (core::value::show's): the
/// runtime's one Int rendering, which hashing's canonical walk, the
/// program-result display and messages (show::int_text) and
/// `std::int::to_string` (runtime::inttext) all read, so no two of them can
/// disagree. Formatted on the stack (`decimal_text`) for every Int of at
/// most 128 bits; a larger BigInt by num-bigint from the object's own value
/// (no clone).
pub(crate) fn with_int_text<R>(v: Value, f: impl FnOnce(&[u8]) -> R) -> R {
    let mut buf = [0u8; 40];
    match int_small(v) {
        Some(n) => f(decimal_text(n < 0, n.unsigned_abs() as u128, &mut buf)),
        None => {
            use num_traits::ToPrimitive;
            let n = big_of(v);
            match n.magnitude().to_u128() {
                Some(mag) => f(decimal_text(n.is_negative(), mag, &mut buf)),
                None => f(n.to_str_radix(10).as_bytes()),
            }
        }
    }
}

// ---------------------------------------------------------------------------
// One canonical walk, two hashes (core/hashing.tcl's Encode;
// HASHABLE-AND-KEYED-HASH.md). `walk` visits a value exactly as `equal`
// recurses -- its kind tag, then its payload -- and hands every piece to a
// sink. The two sinks differ only where the hashes do:
//
//   Fnv (the public `hash`)  a text is its bytes alone; a nested value is its
//                            own 64-bit FNV-1a sub-hash, 8 bytes LE; a set's
//                            members are XOR-combined sub-hashes: the bytes
//                            rt_hash always hashed, so every public hash is
//                            unchanged.
//   Sip13 (the table hash)   a text is its byte count (8 bytes LE) then its
//                            bytes (a prefix-free input); a nested value is
//                            walked inline into the same state, never folded
//                            as a public sub-hash; a set's members are
//                            XOR-combined keyed hashes.
//
// Nothing allocates: texts are borrowed or formatted on the stack
// (`decimal_text`), and both states are a few words on the stack.

trait CanonicalSink: Sized {
    /// Bytes whose length the walk already fixed (a tag, a count, a word).
    fn bytes(&mut self, b: &[u8]);
    /// A variable-length text.
    fn text(&mut self, b: &[u8]);
    /// A nested value (a List element, a struct field, a Result payload).
    fn child(&mut self, p: *mut Vm, v: Value) -> Result<(), ()>;
    /// The whole 64-bit hash of set member V, from a fresh state.
    fn member(&self, p: *mut Vm, v: Value) -> Result<u64, ()>;
    /// The whole 64-bit hash of the identity entry pairing KEY with VALUE,
    /// from a fresh state: the entry tag, then both as nested values
    /// (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md).
    fn entry(&self, p: *mut Vm, key: Value, value: Value) -> Result<u64, ()>;
}

/// The tags of an identity's canonical input (core/hashing.tcl's
/// IdentityTag and EntryTag): its form, after the struct's declaration
/// identity, and the first byte of each pair's own input.
const IDENTITY_MEMBERS: u8 = 1;
const IDENTITY_ASSOCIATIONS: u8 = 2;
const IDENTITY_ENTRY: u8 = 3;

/// Hands the identity IDENTITY of a struct value with FIELDS to SINK (the
/// shape's declaration identity already handed): the form's tag, the entry
/// count (8 bytes LE), then the wrapping sum of every entry's whole hash (8
/// bytes LE) -- a member's own (`member`), a pair's (`entry`). The sum is
/// commutative and a function of the entries' multiset, which identity
/// equality compares, so equal values feed both folds equal input; no other
/// field and no order is read. (A sum, never an XOR: a repeated entry does
/// not cancel.)
fn identity_walk<S: CanonicalSink>(p: *mut Vm, sink: &mut S, identity: Identity, fields: &[Value]) -> Result<(), ()> {
    let entries = identity_entries(identity, fields);
    sink.bytes(&[match identity {
        Identity::Members(_) => IDENTITY_MEMBERS,
        Identity::Associations(..) => IDENTITY_ASSOCIATIONS,
    }]);
    sink.bytes(&(entries.keys.len() as u64).to_le_bytes());
    let mut sum = 0u64;
    match entries.vals {
        None => {
            for &key in entries.keys {
                sum = sum.wrapping_add(sink.member(p, key)?);
            }
        }
        Some(vals) => {
            for (&key, &value) in entries.keys.iter().zip(vals.iter()) {
                sum = sum.wrapping_add(sink.entry(p, key, value)?);
            }
        }
    }
    sink.bytes(&sum.to_le_bytes());
    Ok(())
}

/// The public hash's state: FNV-1a, 64-bit.
struct Fnv(u64);

impl CanonicalSink for Fnv {
    #[inline]
    fn bytes(&mut self, b: &[u8]) {
        self.0 = fnv1a(self.0, b);
    }
    #[inline]
    fn text(&mut self, b: &[u8]) {
        self.0 = fnv1a(self.0, b);
    }
    fn child(&mut self, p: *mut Vm, v: Value) -> Result<(), ()> {
        let sub = self.member(p, v)?;
        self.bytes(&sub.to_le_bytes());
        Ok(())
    }
    fn member(&self, p: *mut Vm, v: Value) -> Result<u64, ()> {
        let mut sub = Fnv(FNV_OFFSET);
        walk(p, &mut sub, v)?;
        Ok(sub.0)
    }
    fn entry(&self, p: *mut Vm, key: Value, value: Value) -> Result<u64, ()> {
        let mut sub = Fnv(FNV_OFFSET);
        sub.bytes(&[IDENTITY_ENTRY]);
        sub.child(p, key)?;
        sub.child(p, value)?;
        Ok(sub.0)
    }
}

/// SipHash-1-3 (Aumasson and Bernstein; one compression round, three
/// finalization rounds, the variant Rust's HashMap uses), streaming: the
/// table hash's state under the process key. core/hashing.tcl's SipHash13 is
/// the same function; audit/hashable/tools/oracle.py is an independent one.
/// C and D are the round counts, so the tests can check the permutation and
/// the padding against std's SipHash-2-4.
#[derive(Clone)]
struct Sip<const C: usize, const D: usize> {
    k: (u64, u64),
    v: [u64; 4],
    /// The pending bytes of an unfinished 8-byte word, little-endian.
    tail: u64,
    ntail: usize,
    length: usize,
}

type Sip13 = Sip<1, 3>;

impl<const C: usize, const D: usize> Sip<C, D> {
    fn new(k0: u64, k1: u64) -> Self {
        Sip {
            k: (k0, k1),
            v: [k0 ^ 0x736f6d6570736575, k1 ^ 0x646f72616e646f6d, k0 ^ 0x6c7967656e657261, k1 ^ 0x7465646279746573],
            tail: 0,
            ntail: 0,
            length: 0,
        }
    }

    #[inline]
    fn round(v: &mut [u64; 4]) {
        v[0] = v[0].wrapping_add(v[1]);
        v[1] = v[1].rotate_left(13) ^ v[0];
        v[0] = v[0].rotate_left(32);
        v[2] = v[2].wrapping_add(v[3]);
        v[3] = v[3].rotate_left(16) ^ v[2];
        v[0] = v[0].wrapping_add(v[3]);
        v[3] = v[3].rotate_left(21) ^ v[0];
        v[2] = v[2].wrapping_add(v[1]);
        v[1] = v[1].rotate_left(17) ^ v[2];
        v[2] = v[2].rotate_left(32);
    }

    #[inline]
    fn compress(&mut self, m: u64) {
        self.v[3] ^= m;
        for _ in 0..C {
            Self::round(&mut self.v);
        }
        self.v[0] ^= m;
    }

    fn write(&mut self, bytes: &[u8]) {
        self.length += bytes.len();
        let mut rest = bytes;
        if self.ntail > 0 {
            while self.ntail < 8 {
                let Some((&b, more)) = rest.split_first() else { return };
                self.tail |= (b as u64) << (8 * self.ntail);
                self.ntail += 1;
                rest = more;
            }
            let m = self.tail;
            self.compress(m);
            self.tail = 0;
            self.ntail = 0;
        }
        let mut words = rest.chunks_exact(8);
        for w in &mut words {
            self.compress(u64::from_le_bytes(w.try_into().unwrap()));
        }
        for (i, &b) in words.remainder().iter().enumerate() {
            self.tail |= (b as u64) << (8 * i);
        }
        self.ntail = words.remainder().len();
    }

    fn finish(&self) -> u64 {
        let mut v = self.v;
        let b = ((self.length as u64 & 0xff) << 56) | self.tail;
        v[3] ^= b;
        for _ in 0..C {
            Self::round(&mut v);
        }
        v[0] ^= b;
        v[2] ^= 0xff;
        for _ in 0..D {
            Self::round(&mut v);
        }
        v[0] ^ v[1] ^ v[2] ^ v[3]
    }
}

impl<const C: usize, const D: usize> CanonicalSink for Sip<C, D> {
    #[inline]
    fn bytes(&mut self, b: &[u8]) {
        self.write(b);
    }
    #[inline]
    fn text(&mut self, b: &[u8]) {
        self.write(&(b.len() as u64).to_le_bytes());
        self.write(b);
    }
    fn child(&mut self, p: *mut Vm, v: Value) -> Result<(), ()> {
        walk(p, self, v)
    }
    fn member(&self, p: *mut Vm, v: Value) -> Result<u64, ()> {
        let mut sub = Self::new(self.k.0, self.k.1);
        walk(p, &mut sub, v)?;
        Ok(sub.finish())
    }
    fn entry(&self, p: *mut Vm, key: Value, value: Value) -> Result<u64, ()> {
        let mut sub = Self::new(self.k.0, self.k.1);
        sub.bytes(&[IDENTITY_ENTRY]);
        walk(p, &mut sub, key)?;
        walk(p, &mut sub, value)?;
        Ok(sub.finish())
    }
}

/// Hands V's canonical input to SINK: its kind tag, then its payload,
/// recursing into List elements, struct fields and a Result payload exactly
/// as `equal` recurses (core/hashing.tcl's Encode, byte for byte). Refuses
/// the kinds `equal` refuses, as rt_hash always did.
fn walk<S: CanonicalSink>(p: *mut Vm, sink: &mut S, v: Value) -> Result<(), ()> {
    let kind = kind_of(v);
    if matches!(kind, Kind::RawFloat32 | Kind::RawFloat64) {
        vm(p).fail(RtError::Semantic { kind: "EQUALITY", message: raw_hash_message(v) });
        return Err(());
    }
    if matches!(kind, Kind::Block | Kind::Native | Kind::MutArray | Kind::Coroutine | Kind::MutVec | Kind::CPtr) {
        vm(p).fail(RtError::Unhashable { value: v });
        return Err(());
    }
    if kind == Kind::DecimalRounded {
        vm(p).fail(RtError::Semantic { kind: "EQUALITY", message: DECIMAL_HASH_MESSAGE.to_string() });
        return Err(());
    }
    // Kind tags matching core/hashing.tcl's KindTag dict exactly (int str
    // bool unit list result UnicodeChar immutableSet -> 0 1 2 3 4 5 6 7), so
    // e.g. Int 1 and Str "1" never collide by coincidence of payload bytes
    // alone.
    let tag = match kind {
        Kind::Int => 0u8,
        Kind::Str => 1,
        Kind::Bool => 2,
        Kind::Unit => 3,
        Kind::List => 4,
        Kind::Result => 5,
        Kind::UnicodeChar => 6,
        Kind::ImmutableSet => 7,
        Kind::Struct => 8,
        Kind::ByteStore => 9,
        Kind::MutByteStore => 10,
        Kind::Enum => 11,
        Kind::Float64 => 12,
        Kind::Block | Kind::Native | Kind::MutArray | Kind::Coroutine | Kind::MutVec | Kind::CPtr
        | Kind::DecimalRounded | Kind::RawFloat32 | Kind::RawFloat64 => unreachable!(),
    };
    sink.bytes(&[tag]);
    match kind {
        // Canonical decimal text, matching how core::value::equal treats
        // textual identity as numeric equality for every Int, small or big
        // (with_int_text: on the stack, no allocation below 2^128).
        Kind::Int => with_int_text(v, |text| sink.text(text)),
        // Evidence is metadata, not part of the value (equal ignores it too).
        Kind::Str => sink.text(str_of(v).as_bytes()),
        Kind::Bool => sink.bytes(&[(v == TRUE) as u8]),
        Kind::Unit => {}
        // The byte count (8 bytes, little-endian), then every byte in order:
        // core/hashing.tcl's bytestore case, byte for byte, and consistent
        // with the byte-sequence equality above. The count delimits the
        // bytes in both hashes.
        Kind::ByteStore => {
            let bytes = bytes_of(v);
            sink.bytes(&(bytes.len() as u64).to_le_bytes());
            sink.bytes(bytes);
        }
        // A MutableBytes hashes by its current contents under its own kind
        // tag (core/hashing.tcl's `bytestore - mutbytes` case).
        Kind::MutByteStore => {
            let bytes = mutbytes_of(v);
            sink.bytes(&(bytes.len() as u64).to_le_bytes());
            sink.bytes(bytes);
        }
        // Canonical decimal codepoint text, matching how Int's own text is
        // hashed above (core/hashing.tcl's identical choice).
        Kind::UnicodeChar => sink.text(decimal_text(false, char_of(v) as u128, &mut [0u8; 40])),
        // The bits, 8 bytes little-endian (core/hashing.tcl's Float64 case):
        // consistent with the bit equality above.
        Kind::Float64 => sink.bytes(&float_bits(v).to_le_bytes()),
        Kind::DecimalRounded | Kind::RawFloat32 | Kind::RawFloat64 => unreachable!(),
        // core/hashing.tcl's enum case, byte for byte (ENUMS.md): the enum's
        // declaration identity text, a 0xFF separator, the case's declared
        // name -- never the numbers the word carries.
        Kind::Enum => {
            let (e, c) = enum_parts(v);
            current_program(|prog| {
                let info = &prog.enums[e as usize];
                sink.text(info.name.as_bytes());
                sink.bytes(&[0xFF]);
                sink.text(info.cases[c as usize].as_bytes());
            })
        }
        Kind::List => {
            let items = list_of(v).items();
            sink.bytes(&(items.len() as u64).to_le_bytes());
            for item in items {
                sink.child(p, *item)?;
            }
        }
        Kind::Result => {
            let r = result_of(v);
            sink.bytes(&[r.ok as u8]);
            sink.child(p, r.payload)?;
        }
        Kind::Struct => {
            // core/hashing.tcl's struct case, byte for byte: the declaration
            // identity text (empty for an anonymous struct), the field
            // count, then each slot's name text and value in slot order.
            // The shape is borrowed for the whole walk, never cloned: a
            // field's walk (a nested struct's or enum's) borrows the program
            // again, and RefCell's shared borrows nest (only `Vm::new`
            // borrows it mutably, and hashing makes no Vm).
            let obj = struct_of(v);
            current_program(|prog| {
                let shape = &prog.shapes[obj.shape as usize];
                sink.text(shape.name.as_deref().unwrap_or("").as_bytes());
                if let Some(identity) = shape.identity {
                    // A declared identity (REPRESENTATION-INDEPENDENT-VALUE-
                    // IDENTITY.md): its entries, never the fields.
                    return identity_walk(p, sink, identity, obj.fields());
                }
                sink.bytes(&(shape.fields.len() as u64).to_le_bytes());
                for (field, item) in shape.fields.iter().zip(obj.fields().iter()) {
                    sink.text(field.as_bytes());
                    sink.child(p, *item)?;
                }
                Ok(())
            })?
        }
        Kind::ImmutableSet => {
            // Order-independent (XOR-combined member hashes), matching
            // `set_equal`'s own order-independent equality and core/
            // hashing.tcl's identical Tcl-side choice: two equal sets must
            // hash equal regardless of construction order. No ImmutableSet-
            // specific hashing API is added (item 92) -- this only keeps
            // the existing, pre-existing generic `hash` native total for
            // the new kind.
            let items = set_of(v).items();
            sink.bytes(&(items.len() as u64).to_le_bytes());
            let mut combined = 0u64;
            for item in items {
                combined ^= sink.member(p, *item)?;
            }
            sink.bytes(&combined.to_le_bytes());
        }
        Kind::Block | Kind::Native | Kind::MutArray | Kind::Coroutine | Kind::MutVec | Kind::CPtr => unreachable!(),
    }
    Ok(())
}

/// The public hash: the FNV-1a of V's canonical input, masked to 61 bits
/// (always a small Int: no allocation). NO_VALUE with EQUALITY for a value
/// with no hash; the compiler's `hashtotal` calls it only for a Hashable one.
#[unsafe(no_mangle)]
pub extern "C" fn rt_hash(p: *mut Vm, v: Value) -> Value {
    let mut sink = Fnv(FNV_OFFSET);
    match walk(p, &mut sink, v) {
        Ok(()) => vm(p).new_int((sink.0 & HASH_MASK) as i64),
        Err(()) => NO_VALUE,
    }
}

// ---------------------------------------------------------------------------
// The table hash's process key (HASHABLE-AND-KEYED-HASH.md, "Hidden secret")

/// The key of every table hash this process computes, drawn once, on first
/// use. Runtime state, never a Botlish value: no operation returns, stores
/// or compares it, and nothing but table_hash_key reads it.
static TABLE_HASH_KEY: std::sync::OnceLock<(u64, u64)> = std::sync::OnceLock::new();

/// Draws a key from the system's random source: std's RandomState, which
/// reads the operating system's entropy (getrandom, arc4random,
/// ProcessPrng) for its own SipHash keys. Two states built in one thread
/// carry different keys (std advances the thread's keys for each), and a
/// hash of a fixed input under each is a 64-bit word derived from them: 128
/// bits of the system's randomness, with no dependency of our own.
fn draw_table_hash_key() -> (u64, u64) {
    use std::hash::{BuildHasher, Hasher};
    let word = |salt: u64| {
        let mut h = std::collections::hash_map::RandomState::new().build_hasher();
        h.write_u64(salt);
        h.finish()
    };
    (word(0x7461626c65), word(0x6861736820))
}

fn table_hash_key() -> (u64, u64) {
    *TABLE_HASH_KEY.get_or_init(draw_table_hash_key)
}

/// Fixes this process's table hash key before any table hash is computed:
/// the driver's `--table-hash-key` (native/src/main.rs), which only test
/// harnesses pass, so the tests can compare exact keyed hashes with an
/// independent implementation. Err if the key was already drawn or set.
pub fn set_table_hash_key(k0: u64, k1: u64) -> Result<(), String> {
    TABLE_HASH_KEY.set((k0, k1)).map_err(|_| "the table hash key is already in use".to_string())
}

/// The table hash of V under the key K: SipHash-1-3 of V's canonical input,
/// masked to 61 bits like the public hash.
fn table_hash_with_key(p: *mut Vm, v: Value, key: (u64, u64)) -> Value {
    let mut sink = Sip13::new(key.0, key.1);
    match walk(p, &mut sink, v) {
        Ok(()) => vm(p).new_int((sink.finish() & HASH_MASK) as i64),
        Err(()) => NO_VALUE,
    }
}

/// The private table hash (core/hashing.tcl's tableHash): what the standard
/// library's hash structures place values with. Equal values hash equal
/// within one process; nothing is promised across processes or versions.
#[unsafe(no_mangle)]
pub extern "C" fn rt_table_hash(p: *mut Vm, v: Value) -> Value {
    table_hash_with_key(p, v, table_hash_key())
}

// ---------------------------------------------------------------------------
// Owned byte storage (ABI-BYTES.md, bytesobj.rs)

/// `byte_store::from_list` (core/bytestore.tcl): L's elements, each an Int
/// in 0..255 stored exactly (no `mod 256`, no sign reinterpretation, no
/// character coercion; a 0 is an ordinary byte), eagerly copied into a new
/// storage that owns them -- the result is not a view of L and does not
/// retain it. The empty List gives the shared static empty storage (no
/// allocation). A non-byte element is a TYPE error with the same text the
/// Tcl implementation raises, naming the element's position.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_from_list(p: *mut Vm, l: Value) -> Value {
    let items = list_of(l).items();
    // Validate and narrow first: the new storage's payload is then written
    // from this buffer with no failure possible while it is half built.
    let mut bytes: Vec<u8> = Vec::with_capacity(items.len());
    for (position, &item) in items.iter().enumerate() {
        let byte = match int_small(item) {
            Some(n) if (0..=255).contains(&n) => n as u8,
            _ => {
                let got = if is_small(item) || heap_kind(item) == KIND_BIGINT {
                    super::show::int_text(item)
                } else {
                    super::show::show(item)
                };
                let message = format!(
                    "std::byte_store::from_list: element {position} must be a byte (an Int in 0..255), got {got}"
                );
                return vm(p).fail(RtError::Semantic { kind: "TYPE", message });
            }
        };
        bytes.push(byte);
    }
    let r = vm(p).new_bytes(&bytes);
    vm(p).metrics.record_list_copy(bytes.len());
    r
}

/// `byte_store::join` (core/bytestore.tcl, WINDOWS-X86-64-MILESTONE-7.md):
/// the storage holding the bytes of every storage of List L, in order -- one
/// allocation of the total length (the shared static empty storage when it
/// is 0), every part copied straight into place. TYPE for an element that is
/// not a byte storage (lib/abi/bytes.bot's wrapper only ever passes the
/// storages of Bytes values), RANGE past the collection-length ceiling
/// (`Vm::alloc_bytes`). The parts stay reachable through L, an operand of
/// the allocating instruction, while the result is allocated.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_join(p: *mut Vm, l: Value) -> Value {
    let items = list_of(l).items();
    let mut total: usize = 0;
    for &item in items.iter() {
        if let Err(failed) = bytes_operand(p, item, "std::byte_store::join") {
            return failed;
        }
        total = total.saturating_add(bytes_of(item).len());
    }
    let r = vm(p).new_bytes_with(total, |init| {
        for &item in items.iter() {
            init.push_slice(bytes_of(item));
        }
    });
    vm(p).metrics.record_list_copy(total);
    r
}

/// `byte_store::slice` (core/bytestore.tcl, WINDOWS-X86-64-MILESTONE-7.md):
/// the storage of V's bytes START..END-1, by the one slice rule
/// (`check_slice`: LowerUnderrun / UpperOverrun unless 0 <= START <= END <=
/// N). One allocation (none for an empty slice); V stays reachable as the
/// allocating instruction's operand while it is made.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_slice(p: *mut Vm, v: Value, start: Value, end: Value) -> Value {
    if let Err(failed) = bytes_operand(p, v, "std::byte_store::slice") {
        return failed;
    }
    let n = bytes_of(v).len();
    let (from, to) = match check_slice(p, bound_of(start), SliceEnd::End(bound_of(end)), n) {
        Ok(bounds) => bounds,
        Err(failed) => return failed,
    };
    let r = vm(p).new_bytes_with(to - from, |init| init.push_slice(&bytes_of(v)[from..to]));
    vm(p).metrics.record_list_copy(to - from);
    r
}

/// `byte_store::decode_utf8` (core/utf8text.tcl, WINDOWS-X86-64-MILESTONE-7.md):
/// the String whose UTF-8 encoding is storage V's bytes, or the declared
/// builtin error InvalidUtf8. Strict, by Rust's own `std::str::from_utf8`
/// (the rule core/utf8text.tcl's strict Tcl decoding and argv() share): an
/// overlong form, an encoded surrogate, a value above U+10FFFF, a truncated
/// sequence or a stray continuation byte is the error, never a replacement
/// character. One String allocation; V stays reachable as the allocating
/// instruction's operand while it is made.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_decode_utf8(p: *mut Vm, v: Value) -> Value {
    if let Err(failed) = bytes_operand(p, v, "std::byte_store::decode_utf8") {
        return failed;
    }
    match std::str::from_utf8(bytes_of(v)) {
        Ok(text) => vm(p).new_str(text),
        Err(_) => fail_builtin(p, super::error::ERR_INVALID_UTF8, "InvalidUtf8"),
    }
}

/// The storage V, or a TYPE error naming CONTEXT (the same text as
/// core::value::expect's, `CONTEXT: expected bytestore, got VALUE`).
fn bytes_operand(p: *mut Vm, v: Value, context: &str) -> Result<(), Value> {
    if heap_kind(v) == KIND_BYTES {
        Ok(())
    } else {
        Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::ByteStore, got: v }))
    }
}

/// `byte_store::byte_count`: the exact byte count, as a small Int (the
/// collection-length ceiling `Vm::alloc_bytes` enforces keeps it in range,
/// which is what `-result-range collection-length` promises).
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_len(p: *mut Vm, v: Value) -> Value {
    if let Err(failed) = bytes_operand(p, v, "std::byte_store::byte_count") {
        return failed;
    }
    make_small(bytes_of(v).len() as i64)
}

/// `abi::x86_64::from_bytes`, the raw address bridge (ABI-BYTES.md): the
/// machine address of the first payload byte of storage V, as a small Int
/// (the object's address plus the constant payload offset; no read of the
/// payload, no allocation). Valid only while V is live and unmoved -- the
/// collector never moves objects, and native lowering keeps V live through the
/// syscall or C call that consumes the address (`op keepalive`). A heap
/// object's address on every host the native backend runs on -- Linux
/// x86-64 (47-bit user space), Linux AArch64 (48-bit, or 52 with large
/// virtual addresses) and macOS AArch64 (47-bit; its heap is above 4 GiB,
/// tests/c-byte-borrowing.test's bb-read-address-above-4gib) -- is below the
/// small-Int ceiling (2^62); anything else is refused rather than truncated.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_addr(p: *mut Vm, v: Value) -> Value {
    if let Err(failed) = bytes_operand(p, v, "std::abi::x86_64::from_bytes") {
        return failed;
    }
    let address = BytesObj::payload_address(v) as i64;
    if !fits_small(address) {
        let message = format!("std::abi::x86_64::from_bytes: the payload address {address:#x} is outside the small-Int range");
        return vm(p).fail(RtError::Semantic { kind: "RANGE", message });
    }
    make_small(address)
}

/// `op cptrfixture %n` (C-ABI-TYPES.md): the C address whose bits are the
/// small Int N, 0 <= N < 2^59 -- the range core::cabi::fixtureAddressImpl
/// accepts. Only the test fixture's natives lower to it.
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_fixture(p: *mut Vm, n: Value) -> Value {
    if !is_small(n) || small_of(n) < 0 || small_of(n) >= (1i64 << 59) {
        let message = format!("C pointer test fixture: address {} is outside 0..2^59-1", super::show::show(n));
        return vm(p).fail(RtError::Semantic { kind: "RANGE", message });
    }
    make_cptr(small_of(n))
}

/// `op cptrfixtureaddress %p` (C-ABI-TYPES.md): the address bits of the C
/// address word P, an Int. Only the test fixture's address_of lowers to it.
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_fixture_address(p: *mut Vm, v: Value) -> Value {
    vm(p).new_int(cptr_address(v))
}

// ---------------------------------------------------------------------------
// Fixed binary layouts (BINARY-LAYOUT.md; core/binary.tcl is the reference).
//
// native/lower.tcl lowers binary::parse / binary::emit of one statically
// known layout to one `binload` / `binstore` per scalar field at a constant
// offset with a constant encoding (no descriptor is read at run time), after
// one length check (parse) or one `byteszeroed` (emit). Every byte order is
// little-endian, the target's; the encoding word keeps room for big-endian.

/// The scalar encoding of a fixed-layout op (`binload`'s word, native/
/// lower.tcl's LayoutEncoding): its width in bytes, its byte order, and
/// either an integer's signedness or, for a C float or double field, its
/// IEEE 754 format (C-FLOAT-FFI-MILESTONE-1.md).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(super) struct BinEncoding {
    pub width: usize,
    pub signed: bool,
    pub big: bool,
    pub float: Option<CFloatFormat>,
    /// A raw C floating representation (RAW-C-FLOAT-FFI-MILESTONE-1.md):
    /// its bits are a raw value's, both ways.
    pub raw: Option<CFloatFormat>,
}

/// The scalar encoding word of `binload`/`binstore`: width in bytes (1, 2, 4
/// or 8, the low four bits), signed (16), big-endian (32), a C floating
/// representation (64: the IEEE 754 format of 4 or 8 bytes, never signed),
/// a raw C floating representation (128: the same formats, never signed or
/// both) -- or None for a malformed word.
pub(super) fn bin_encoding(code: Value) -> Option<BinEncoding> {
    let c = int_small(code)?;
    let width = (c & 15) as usize;
    if !matches!(width, 1 | 2 | 4 | 8) || c & !255 != 0 {
        return None;
    }
    let signed = c & 16 != 0;
    if c & 64 != 0 && c & 128 != 0 {
        return None;
    }
    let format = |flag: i64| -> Option<Option<CFloatFormat>> {
        if c & flag == 0 {
            return Some(None);
        }
        if signed {
            return None;
        }
        Some(Some(CFloatFormat::of_width(width)?))
    };
    let float = format(64)?;
    let raw = format(128)?;
    Some(BinEncoding { width, signed, big: c & 32 != 0, float, raw })
}

/// The storage, offset and encoding operands of a fixed-layout op, checked:
/// the storage is a byte storage and the encoding's bytes at OFFSET lie
/// inside it. (offset, encoding).
fn bin_operands(p: *mut Vm, storage: Value, offset: Value, code: Value, context: &str) -> Result<(usize, BinEncoding), Value> {
    bytes_operand(p, storage, context)?;
    bin_extent(p, storage, offset, code, context)
}

/// bin_operands' offset and encoding checks, for a storage of either byte
/// kind (its length is at the same place in both).
fn bin_extent(p: *mut Vm, storage: Value, offset: Value, code: Value, context: &str) -> Result<(usize, BinEncoding), Value> {
    let Some(encoding) = bin_encoding(code) else {
        let message = format!("{context}: malformed scalar encoding {}", super::show::int_text(code));
        return Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }));
    };
    // (Either byte kind: the payload is at the same place in both.)
    let len = unsafe { super::bytesobj::BytesObj::payload(storage) }.len();
    let width = encoding.width;
    match int_small(offset) {
        Some(o) if o >= 0 && (o as usize).checked_add(width).is_some_and(|end| end <= len) => Ok((o as usize, encoding)),
        _ => {
            let message = format!("{context}: {width} bytes at offset {} lie outside a storage of {len} bytes", super::show::int_text(offset));
            Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }))
        }
    }
}

/// `byteszeroed %n`: a fresh storage of N zero bytes, private to the code
/// that writes its fields next (`binstore`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_bytes_zeroed(p: *mut Vm, n: Value) -> Value {
    let count = match index_operand(p, n, "std::binary::emit", "the layout size", MAX_COLLECTION_LENGTH) {
        Ok(count) => count,
        Err(failed) => return failed,
    };
    vm(p).new_bytes_with(count, |init| init.push_zeros(count))
}

/// `binload %s %o %c`: the value at offset O of storage S in encoding C.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bin_load(p: *mut Vm, storage: Value, offset: Value, code: Value) -> Value {
    let (at, encoding) = match bin_operands(p, storage, offset, code, "std::binary::parse") {
        Ok(operands) => operands,
        Err(failed) => return failed,
    };
    bin_decode(p, &bytes_of(storage)[at..at + encoding.width], encoding)
}

/// The value the encoded scalar BYTES (1, 2, 4 or 8 of them) holds in
/// ENCODING: an integer's Int (two's complement or unsigned), or a C
/// floating representation's Float64 -- admitted by the boundary's rule
/// (value.rs's admit_c_float: NaN and the infinities are NonFiniteFloat,
/// negative zero zero, a binary32 widened exactly). `binload`'s decoding,
/// shared with the native view's `nativeload` and the row reads
/// (runtime/nview.rs).
pub(super) fn bin_decode(p: *mut Vm, bytes: &[u8], encoding: BinEncoding) -> Value {
    let width = bytes.len();
    let mut word = [0u8; 8];
    word[..width].copy_from_slice(bytes);
    if encoding.big {
        word[..width].reverse();
    }
    let raw = u64::from_le_bytes(word);
    if let Some(format) = encoding.raw {
        // A raw C floating field: the bits, as they are.
        return vm(p).new_raw_float(format, raw);
    }
    if let Some(format) = encoding.float {
        return match admit_c_float(format, raw) {
            Ok(bits) => vm(p).new_float(FloatType::Float64, bits),
            Err(result) => rt_float_nonfinite(p, result),
        };
    }
    if encoding.signed {
        let shift = 64 - 8 * width as u32;
        vm(p).new_int(((raw << shift) as i64) >> shift)
    } else if raw <= i64::MAX as u64 {
        vm(p).new_int(raw as i64)
    } else {
        vm(p).new_big(BigInt::from(raw))
    }
}

/// `binstore %s %o %c %v`: writes Int V at offset O of the fresh storage S
/// in encoding C. RANGE (never a truncation) if V is outside the encoding.
#[unsafe(no_mangle)]
pub extern "C" fn rt_bin_store(p: *mut Vm, storage: Value, offset: Value, code: Value, value: Value) -> Value {
    // The fresh storage of an emission (`byteszeroed`, KIND_BYTES) or of a
    // whole-array layout write into byte storage (`mbytesclone`,
    // KIND_MUTBYTES: FIXED-LAYOUT-ARRAYS.md), private to that operation.
    if heap_kind(storage) != KIND_MUTBYTES {
        if let Err(failed) = bytes_operand(p, storage, "std::binary::emit") {
            return failed;
        }
    }
    let (at, encoding) = match bin_extent(p, storage, offset, code, "std::binary::emit") {
        Ok(operands) => operands,
        Err(failed) => return failed,
    };
    let width = encoding.width;
    let bytes = match bin_encode(p, value, encoding, "std::binary::emit") {
        Ok(bytes) => bytes,
        Err(failed) => return failed,
    };
    // SAFETY: STORAGE is the fresh, non-empty storage `byteszeroed` made for
    // this emission (native/lower.tcl's LayoutEmit): no value holds it yet,
    // and the range was checked above.
    unsafe { BytesObj::payload_mut(storage)[at..at + width].copy_from_slice(&bytes[..width]) };
    UNIT
}

/// The ENCODING of VALUE in the first `width` bytes of the result: an Int
/// two's complement or unsigned, or a Float64 as a C float or double --
/// narrowed by the boundary's rule (value.rs's narrow_c_float: to nearest,
/// ties to even; a binary32 overflow is NonFiniteFloat, never clamped) --
/// BIG-endian or little. `binstore`'s encoding, shared with the layout writes
/// of a native edit and of byte storage (runtime/nview.rs, NATIVE-LAYOUT-
/// WRITES.md). A value outside an integer encoding is a RANGE error (CONTEXT
/// names the operation); every failure is raised before the caller writes
/// anything: never a truncation, a wrap or a reinterpretation.
pub(super) fn bin_encode(p: *mut Vm, value: Value, encoding: BinEncoding, context: &str) -> Result<[u8; 8], Value> {
    use num_traits::ToPrimitive;
    let BinEncoding { width, signed, big, float, raw } = encoding;
    if let Some(format) = raw {
        // A raw C floating field: a raw value of the field's format, its
        // bits written as they are (never narrowed or normalized).
        if raw_format_of(value) != Some(format) {
            let expected = if format == CFloatFormat::Binary32 { Kind::RawFloat32 } else { Kind::RawFloat64 };
            return Err(vm(p).fail(RtError::Type { context: context.to_string(), expected, got: value }));
        }
        let mut bytes = raw_bits(value).to_le_bytes();
        if big {
            bytes[..width].reverse();
        }
        return Ok(bytes);
    }
    if let Some(format) = float {
        if heap_kind(value) != KIND_FLOAT {
            return Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::Float64, got: value }));
        }
        let bits = narrow_c_float(format, float64_of(value)).map_err(|result| rt_float_nonfinite(p, result))?;
        let mut bytes = bits.to_le_bytes();
        if big {
            bytes[..width].reverse();
        }
        return Ok(bytes);
    }
    if !is_small(value) && heap_kind(value) != KIND_BIGINT {
        return Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::Int, got: value }));
    }
    // Every encoding's range lies inside i128, so the check needs no BigInt
    // for a small Int (the common case: no allocation per store); a BigInt
    // beyond i128 is outside every encoding.
    let n: i128 = match int_small(value) {
        Some(small) => small as i128,
        None => {
            let big = int_to_big(value);
            big.to_i128().unwrap_or(if big < BigInt::from(0u8) { i128::MIN } else { i128::MAX })
        }
    };
    let bits = 8 * width as u32;
    let (lo, hi): (i128, i128) = if signed {
        (-(1i128 << (bits - 1)), (1i128 << (bits - 1)) - 1)
    } else {
        (0, (1i128 << bits) - 1)
    };
    if n < lo || n > hi {
        let message = format!("{context}: {} is outside the {width}-byte encoding {lo}..{hi}", super::show::int_text(value));
        return Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }));
    }
    // The low 64 bits: two's complement for a negative N, N itself otherwise.
    let word = n as u64;
    let mut bytes = word.to_le_bytes();
    if big {
        bytes[..width].reverse();
    }
    Ok(bytes)
}

// ---------------------------------------------------------------------------
// MutableBytes (MUTABLE-BYTES.md): the writable byte storage, KIND_MUTBYTES.
//
// One rule makes a MutableBytes a VALUE rather than a reference: a storage is
// written only while it is private to the operation that created it. Every
// operation that changes contents (`rt_mbytes_set`, and the clone
// `rt_mbytes_clone` that linux::read's kernel write goes into) allocates a
// FRESH object, fills it from its operand, and (for set) writes the one byte;
// the operand is never written. So a published storage never changes, two
// logical copies may share it freely, and no boundary (binding, argument,
// field, List element, closure capture, generic or `any` transport) has to
// copy anything for independence to hold.

/// The writable storage V, or a TYPE error naming CONTEXT.
fn mutbytes_operand(p: *mut Vm, v: Value, context: &str) -> Result<(), Value> {
    if heap_kind(v) == KIND_MUTBYTES {
        Ok(())
    } else {
        Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::MutByteStore, got: v }))
    }
}

/// A non-negative small Int operand as a usize, or the RANGE/TYPE error
/// CONTEXT names (BigInt and negative are RANGE; a non-Int is TYPE).
fn index_operand(p: *mut Vm, v: Value, context: &str, what: &str, limit: usize) -> Result<usize, Value> {
    if !is_small(v) && heap_kind(v) != KIND_BIGINT {
        return Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: Kind::Int, got: v }));
    }
    match int_small(v) {
        Some(n) if n >= 0 && (n as u64) <= limit as u64 => Ok(n as usize),
        _ => {
            let message = format!("{context}: {what} must be in 0..{limit}, got {}", super::show::int_text(v));
            Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }))
        }
    }
}

/// `mutable_byte_store::zeroed`: N zero bytes in a fresh writable storage.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_new(p: *mut Vm, n: Value) -> Value {
    let count = match index_operand(p, n, "std::mutable_byte_store::zeroed", "the length", MAX_COLLECTION_LENGTH) {
        Ok(count) => count,
        Err(failed) => return failed,
    };
    vm(p).new_mutbytes_with(count, |init| init.push_zeros(count))
}

/// `mutable_byte_store::from_storage`: a fresh writable copy of immutable storage V.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_from(p: *mut Vm, v: Value) -> Value {
    if let Err(failed) = bytes_operand(p, v, "std::mutable_byte_store::from_storage") {
        return failed;
    }
    vm(p).metrics.record_list_copy(bytes_of(v).len());
    vm(p).new_mutbytes_with(bytes_of(v).len(), |init| init.push_slice(bytes_of(v)))
}

/// `mutable_byte_store::count`: the fixed byte count of writable storage V.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_len(p: *mut Vm, v: Value) -> Value {
    if let Err(failed) = mutbytes_operand(p, v, "std::mutable_byte_store::count") {
        return failed;
    }
    make_small(mutbytes_of(v).len() as i64)
}

/// `mutable_byte_store::replace`: a fresh storage equal to M with byte I replaced
/// by B. M is read, never written: the new object is allocated, filled from
/// M, and only then is its one byte written (it is still private here).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_set(p: *mut Vm, m: Value, i: Value, b: Value) -> Value {
    const CONTEXT: &str = "std::mutable_byte_store::replace";
    if let Err(failed) = mutbytes_operand(p, m, CONTEXT) {
        return failed;
    }
    let len = mutbytes_of(m).len();
    if len == 0 {
        // An empty storage has no byte to replace; (the shared static empty
        // storage must never be written either).
        let message = format!("{CONTEXT}: index {} is outside an empty MutableBytes", super::show::int_text(i));
        return vm(p).fail(RtError::Semantic { kind: "RANGE", message });
    }
    let index = match index_operand(p, i, CONTEXT, "the index", len - 1) {
        Ok(index) => index,
        Err(failed) => return failed,
    };
    let byte = match int_small(b) {
        Some(n) if (0..=255).contains(&n) => n as u8,
        _ => {
            let got = if is_small(b) || heap_kind(b) == KIND_BIGINT { super::show::int_text(b) } else { super::show::show(b) };
            let message = format!("{CONTEXT}: the value must be a byte (an Int in 0..255), got {got}");
            return vm(p).fail(RtError::Semantic { kind: "TYPE", message });
        }
    };
    vm(p).metrics.record_list_copy(len);
    let r = vm(p).new_mutbytes_with(len, |init| init.push_slice(mutbytes_of(m)));
    if r != NO_VALUE {
        // SAFETY: R is the fresh, fully written object this call just
        // created (len > 0, so it is not the shared empty storage); nothing
        // else holds it yet.
        unsafe { BytesObj::payload_mut(r)[index] = byte };
    }
    r
}

/// `mutable_byte_store::detach`: a fresh storage equal to M (the detach).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_clone(p: *mut Vm, m: Value) -> Value {
    if let Err(failed) = mutbytes_operand(p, m, "std::mutable_byte_store::detach") {
        return failed;
    }
    vm(p).metrics.record_list_copy(mutbytes_of(m).len());
    vm(p).new_mutbytes_with(mutbytes_of(m).len(), |init| init.push_slice(mutbytes_of(m)))
}

/// `mutable_byte_store::freeze`: an immutable snapshot of all of M's bytes.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_freeze(p: *mut Vm, m: Value) -> Value {
    if let Err(failed) = mutbytes_operand(p, m, "std::mutable_byte_store::freeze") {
        return failed;
    }
    vm(p).metrics.record_list_copy(mutbytes_of(m).len());
    vm(p).new_bytes_with(mutbytes_of(m).len(), |init| init.push_slice(mutbytes_of(m)))
}

/// `mutable_byte_store::freeze_prefix`: an immutable snapshot of M's first N bytes.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_freeze_prefix(p: *mut Vm, m: Value, n: Value) -> Value {
    const CONTEXT: &str = "std::mutable_byte_store::freeze_prefix";
    if let Err(failed) = mutbytes_operand(p, m, CONTEXT) {
        return failed;
    }
    let count = match index_operand(p, n, CONTEXT, "the count", mutbytes_of(m).len()) {
        Ok(count) => count,
        Err(failed) => return failed,
    };
    vm(p).metrics.record_list_copy(count);
    vm(p).new_bytes_with(count, |init| init.push_slice(&mutbytes_of(m)[..count]))
}

/// `abi::x86_64::from_mutable_bytes`, the WRITABLE raw address bridge
/// (MUTABLE-BYTES.md): the machine address of the first payload byte of
/// writable storage M, as a small Int. Exactly `rt_bytes_addr`'s contract,
/// for the other kind: it refuses a readable storage, so the two bridges are
/// never mixed up; it does not copy (the caller -- linux::read -- holds a
/// storage it just detached), and the storage must stay live until the
/// syscall that writes through the address has returned (`op keepalive`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mbytes_addr(p: *mut Vm, m: Value) -> Value {
    if let Err(failed) = mutbytes_operand(p, m, "std::abi::x86_64::from_mutable_bytes") {
        return failed;
    }
    let address = BytesObj::payload_address(m) as i64;
    if !fits_small(address) {
        let message = format!(
            "std::abi::x86_64::from_mutable_bytes: the payload address {address:#x} is outside the small-Int range"
        );
        return vm(p).fail(RtError::Semantic { kind: "RANGE", message });
    }
    make_small(address)
}

// ---------------------------------------------------------------------------
// Strings (indices count characters: Unicode scalar values)

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_len(p: *mut Vm, s: Value) -> Value {
    vm(p).new_int(str_of(s).chars as i64)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_substr(p: *mut Vm, s: Value, start: Value, end: Value) -> Value {
    let obj = str_of(s);
    let (from, to) = match check_slice(p, bound_of(start), SliceEnd::End(bound_of(end)), obj.chars) {
        Ok(slice) => slice,
        Err(failed) => return failed,
    };
    substr_range(p, s, from, to)
}

/// `rt_substr` at a call site whose slice hir/completions.tcl proved valid
/// (`substrproven`): START and END are small Ints with 0 <= START <= END <=
/// the length, so nothing is checked and nothing can fail.
#[unsafe(no_mangle)]
pub extern "C" fn rt_substr_proven(p: *mut Vm, s: Value, start: Value, end: Value) -> Value {
    let (from, to) = proven_slice(start, end, str_of(s).chars);
    substr_range(p, s, from, to)
}

/// The slice `start..end` (character indices, already known valid for the
/// String S) as a new String.
fn substr_range(p: *mut Vm, s: Value, from: usize, to: usize) -> Value {
    let obj = str_of(s);
    // One allocation, one copy: the substring's bytes go straight from the
    // base's text into the new String's text.
    if obj.ascii {
        // ASCII: character index == byte offset, so the slice is known
        // without any scan.
        let r = vm(p).new_str_known(&obj.as_str()[from..to], to - from, true);
        vm(p).metrics.record_string_copy(to - from);
        return r;
    }
    // Non-ASCII: character index `from` is not a byte offset, so it must be
    // located by decoding forward from byte 0 -- the seek this milestone's
    // traversal optimization (hir/traversal.tcl, native/lower.tcl's "String
    // traversal" section) exists to avoid paying on every element of a
    // monotonic scan. `utf8SeekBytes` counts exactly this: the UTF-8 source
    // bytes walked here to map a semantic character index to a physical
    // byte offset, not the copy that follows (record_string_copy, separate).
    // Locating the end of the slice walks the `to - from` scalars once more
    // (the byte length must be known before the one allocation); the result's
    // character count is known (`to - from`) and its ASCII flag follows from
    // byte length == character count, so there is no third pass.
    let text = obj.as_str();
    let mut indices = text.char_indices();
    let seek_start = indices.by_ref().nth(from).map_or(text.len(), |(i, _)| i);
    vm(p).metrics.record_utf8_seek(seek_start);
    let rest = &text[seek_start..];
    let width = rest.char_indices().nth(to - from).map_or(rest.len(), |(i, _)| i);
    let slice = &rest[..width];
    let r = vm(p).new_str_known(slice, to - from, width == to - from);
    vm(p).metrics.record_string_copy(width);
    r
}

// ---------------------------------------------------------------------------
// String regions (native/lower.tcl's string-region optimization,
// hir/stringregion.tcl): a non-materializing internal counterpart of a
// temporary `substring` result -- a validated (base, start, end) character
// range that a supported consumer (equality, length) reads directly instead
// of ever allocating a StrObj. Never a source-visible type: see
// hir/stringregion.tcl's header.

/// Validates a region's bounds exactly as `rt_substr` does, without
/// allocating: UNIT on success, `rt_substr`'s own LowerUnderrun/UpperOverrun
/// (`check_slice`) on failure. Strings are immutable, so a region proven
/// valid here stays valid for as long as its registers are live -- no
/// re-check is ever needed at a consumer.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_region_check(p: *mut Vm, s: Value, start: Value, end: Value) -> Value {
    match check_slice(p, bound_of(start), SliceEnd::End(bound_of(end)), str_of(s).chars) {
        Ok(_) => UNIT,
        Err(failed) => failed,
    }
}

/// BASE\[START..END) (a region `rt_str_region_check` already validated)
/// compared character-for-character against OTHER, with no allocation.
/// Never fallible.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_region_eq(p: *mut Vm, base: Value, start: Value, end: Value, other: Value) -> Value {
    let b = str_of(base);
    let o = str_of(other);
    let from = int_small(start).expect("region start already validated") as usize;
    let to = int_small(end).expect("region end already validated") as usize;
    if to - from != o.chars {
        return bool_value(false);
    }
    if b.ascii {
        bool_value(b.as_bytes()[from..to] == *o.as_bytes())
    } else {
        // Same seek accounting as rt_substr's non-ASCII path: locating
        // character index `from` still means decoding forward from byte 0.
        let text = b.as_str();
        let mut indices = text.char_indices();
        let seek_start = indices.by_ref().nth(from).map_or(text.len(), |(i, _)| i);
        vm(p).metrics.record_utf8_seek(seek_start);
        bool_value(text[seek_start..].chars().take(to - from).eq(o.as_str().chars()))
    }
}

// ---------------------------------------------------------------------------
// String traversal (native/lower.tcl's "String traversal" lowering,
// hir/traversal.tcl): a provably forward, +1-per-iteration character scan
// carries its physical UTF-8 byte position across the loop instead of
// re-seeking from byte 0 each iteration -- see hir/traversal.tcl's header.
// Neither op below ever seeks: both act at a byte offset the caller already
// carries, so unlike rt_substr's/rt_str_region_eq's non-ASCII paths, neither
// touches `utf8SeekBytes`.

/// The one Unicode scalar at BASE's UTF-8 byte offset BYTE_OFFSET, as a
/// one-character String -- the same result `substring(base, i, i+1)` would
/// produce for the character index i that byte offset corresponds to.
/// BYTE_OFFSET is an ordinary tagged small Int (never raw): a traversal's
/// carried position never exceeds BASE's byte length, always well within
/// small-Int range, so keeping it tagged costs no allocation, just a tag
/// bit (value.rs's make_small/small_of are pure bit operations). Never
/// fallible: callers (native/lower.tcl) only ever emit this at a byte
/// offset already proven in range by the traversal's own bounds check, and
/// a one-character String can never exceed MAX_COLLECTION_LENGTH.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_decode_char_at(p: *mut Vm, s: Value, byte_offset: Value) -> Value {
    let obj = str_of(s);
    let off = int_small(byte_offset).expect("decode_char_at: byte_offset must be a small Int") as usize;
    let c = obj.as_str()[off..]
        .chars()
        .next()
        .expect("decode_char_at: byte_offset must be a valid, in-bounds UTF-8 boundary");
    let bytes = c.len_utf8();
    let r = vm(p).new_str_scalar(c);
    // Diagnostic-only (STRING-BYTES-CONSTRUCTION-AUDIT.md): every other
    // String-producing op (rt_substr, rt_str_cat, rt_str_lower) reports its
    // own copied bytes via record_string_copy; this one silently didn't,
    // undercounting "copies: stringBytes" by exactly this op's contribution
    // (confirmed by reconciling allocationReport's byKind.String.payloadBytes
    // against copies.stringBytes on bench/ai_text_clean.tcl). No semantic
    // change: the one allocation and the scalar's encoding happened above.
    vm(p).metrics.record_string_copy(bytes);
    r
}

// ---------------------------------------------------------------------------
// ShortString1 (SHORT-STRING.md): a String the compiler proved has at most
// one character, carried as one i64 -- `SHORT_EMPTY` (-1) is the empty
// String, `0..=0x10FFFF` (never a surrogate: a Botlish String is a Rust
// `str`, so its characters are Unicode scalar values) is the one scalar of a
// one-character String. U+0000 is 0, a one-character String, never Empty.
// None of these three fail; the proof is the caller's, and a violated one
// is a compiler bug (asserted in debug builds, never an error value).

pub const SHORT_EMPTY: i64 = -1;

/// The ShortString1 scalar of String S, which has at most one character.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_to_short(_p: *mut Vm, s: Value) -> u64 {
    let obj = str_of(s);
    debug_assert!(obj.chars <= 1, "ShortString1 of a String with {} characters", obj.chars);
    if obj.chars == 0 {
        return SHORT_EMPTY as u64;
    }
    obj.first_scalar() as u64
}

/// The String a ShortString1 scalar stands for: "" for Empty, else the
/// one-character String of that Unicode scalar value, UTF-8 encoded into a
/// fresh String (there is no interned table: a value the compiler knows
/// statically is a `str` constant and never gets here).
#[unsafe(no_mangle)]
pub extern "C" fn rt_short_to_str(p: *mut Vm, short: u64) -> Value {
    let short = short as i64;
    let r = vm(p).short_to_string(short);
    vm(p).metrics.record_string_copy(char::from_u32(short as u32).map_or(0, |c| c.len_utf8()));
    r
}

/// The packed-ASCII word (tier A, see `value::pack_ascii`) of String S, which
/// the compiler proved ASCII with at most eight characters.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_to_ascii(_p: *mut Vm, s: Value) -> u64 {
    let obj = str_of(s);
    obj.packed_ascii()
}

/// The String a packed-ASCII word stands for, freshly allocated: the word
/// masked to its 7-bit payload, truncated to the length the presence bits
/// give.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ascii_to_str(p: *mut Vm, word: u64) -> Value {
    let r = vm(p).ascii_to_string(word);
    vm(p).metrics.record_string_copy(ascii_word_len(word));
    r
}

/// BASE[START..END) (a range `rt_str_region_check` already validated, at
/// most one character wide) as a ShortString1. Never fails, never
/// allocates. A non-ASCII BASE locates character index START by decoding
/// forward from byte 0, exactly the seek `rt_substr` pays (and counts).
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_slice_short(p: *mut Vm, base: Value, start: Value, end: Value) -> u64 {
    let b = str_of(base);
    let from = int_small(start).expect("slice start already validated") as usize;
    let to = int_small(end).expect("slice end already validated") as usize;
    debug_assert!(to - from <= 1, "ShortString1 slice of width {}", to - from);
    if to == from {
        return SHORT_EMPTY as u64;
    }
    if b.ascii {
        return b.as_bytes()[from] as u64;
    }
    let text = b.as_str();
    let mut indices = text.char_indices();
    let seek_start = indices.by_ref().nth(from).map_or(text.len(), |(i, _)| i);
    vm(p).metrics.record_utf8_seek(seek_start);
    text[seek_start..].chars().next().expect("slice start already validated") as u64
}

/// The UTF-8 byte length of S's text -- distinct from `rt_str_len`, which
/// counts Unicode scalars. A plain field read (StrObj::byte_len), never a
/// scan: applied to `rt_str_decode_char_at`'s own result, this gives the
/// encoded width of the scalar just decoded, letting a traversal advance its
/// carried byte offset by exactly that many bytes.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_byte_len(p: *mut Vm, s: Value) -> Value {
    vm(p).new_int(str_of(s).len_bytes() as i64)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_lower(p: *mut Vm, s: Value) -> Value {
    // The Unicode 16 simple (one-to-one, UnicodeData.txt) lowercase mapping,
    // identical to core::strings::lowercase (see its comment and README.md,
    // "Strings"). Rust's tables are newer than Unicode 16 and its
    // to_lowercase is the *full* mapping, so two adjustments:
    fn lower(c: char) -> char {
        // U+0130's full lowercase is "i" + U+0307 (SpecialCasing.txt's only
        // unconditional multi-character lowercase); its simple mapping is
        // plain U+0069.
        if c == '\u{130}' {
            return 'i';
        }
        // Scalars with a lowercase mapping that Unicode 17 added: leave them
        // unchanged to stay at Unicode 16 (Latin Extended-D U+A7CE, U+A7D2,
        // U+A7D4 and the Beria Erfe capitals U+16EA0..=U+16EB8). tests/
        // native-tcl-unicode.test compares every scalar with the reference,
        // so a toolchain whose tables add more fails there.
        if matches!(c, '\u{A7CE}' | '\u{A7D2}' | '\u{A7D4}' | '\u{16EA0}'..='\u{16EB8}') {
            return c;
        }
        let mut lower = c.to_lowercase();
        match (lower.next(), lower.next()) {
            (Some(l), None) => l,
            _ => c,
        }
    }
    let obj = str_of(s);
    // One allocation either way, no intermediate buffer. ASCII maps ASCII to
    // ASCII, so the result has the operand's size and is written in one
    // pass; otherwise a mapped scalar can change width (U+212A is 3 bytes,
    // its lowercase 'k' one), so a first pass sizes the result and a second
    // writes it (the character count never changes: the mapping is
    // one-to-one).
    let r = if obj.ascii {
        let src = obj.as_bytes();
        vm(p).new_str_with(src.len(), obj.chars, |out| {
            for b in src {
                out.push_ascii(b.to_ascii_lowercase());
            }
        })
    } else {
        let text = obj.as_str();
        let byte_len: usize = text.chars().map(|c| lower(c).len_utf8()).sum();
        vm(p).new_str_with(byte_len, obj.chars, |out| {
            for c in text.chars() {
                out.push_scalar(lower(c));
            }
        })
    };
    vm(p).metrics.record_string_copy(str_bytes_of(r));
    r
}

/// The text byte length of String result R, or 0 for a failure (NO_VALUE).
fn str_bytes_of(r: Value) -> usize {
    if r == NO_VALUE { 0 } else { str_of(r).len_bytes() }
}

/// S's UTF-8 encoding as a List of Ints (one per byte, each 0..255), in
/// order (core/strings.tcl's `encode_utf8`): S's text is already a Rust
/// `String`, so it is already valid UTF-8 -- this is a plain byte-by-byte
/// read, never a re-encode. The general byte-level access String otherwise
/// never exposes (see nir.rs's StrUtf8Bytes doc comment). Reuses
/// `Vm::new_list`'s own MAX_COLLECTION_LENGTH check (same limit any other
/// List/String construction enforces), so an oversized result fails RANGE
/// exactly like `rt_list_new`'s would, not a special case here.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_utf8_bytes(p: *mut Vm, s: Value) -> Value {
    let items: Vec<Value> = str_of(s).as_bytes().iter().map(|b| vm(p).new_int(*b as i64)).collect();
    let n = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_list_copy(n);
    r
}

/// `str::char_at(S, I)` (core/strings.tcl's `charAt`) at a character index
/// I already known valid: the scalar as a UnicodeChar immediate, never an
/// allocation. An ASCII String's character I is its byte I; otherwise
/// character I is located by decoding forward from byte 0 -- the same seek
/// `rt_substr`'s non-ASCII path pays, counted the same way in
/// `utf8SeekBytes`. codegen::clif inlines the ASCII path of the proven form.
fn char_at_index(p: *mut Vm, s: Value, i: usize) -> Value {
    let obj = str_of(s);
    if obj.ascii {
        return make_char(obj.as_bytes()[i] as u32);
    }
    let text = obj.as_str();
    let (at, c) = text.char_indices().nth(i).expect("index validated");
    vm(p).metrics.record_utf8_seek(at);
    make_char(c as u32)
}

/// `str::char_at` checked: any index that is not a small Int in 0..chars (a
/// negative one, one at or past the end, a BigInt) is the declared
/// IndexNotFound, exactly like `rt_list_get`.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_char_at(p: *mut Vm, s: Value, index: Value) -> Value {
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < str_of(s).chars => char_at_index(p, s, i as usize),
        _ => index_not_found(p),
    }
}

/// `rt_str_char_at` at an index proven to designate a character (`strcharatproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_char_at_proven(p: *mut Vm, s: Value, index: Value) -> Value {
    char_at_index(p, s, int_small(index).expect("proven index") as usize)
}

/// `argv()` (core/process.tcl, ARGV.md): the run's argument snapshot as a
/// List of Strings, each argument validated as UTF-8 only now, all or
/// nothing. An invalid argument records the declared builtin error
/// InvalidArgumentEncoding (its NIR id as the pending declared error, plus
/// an UNCAUGHT-ERROR fallback for the program boundary, exactly like
/// `rt_fail_declared`) and returns NO_VALUE: no partial List ever exists.
/// Strings are built with the canonical one-allocation constructor straight
/// from the validated bytes and kept in `temp_roots` while the rest of the
/// vector (and finally the List) allocates, so a collection at any
/// allocation sees every one of them.
#[unsafe(no_mangle)]
pub extern "C" fn rt_argv(p: *mut Vm) -> Value {
    let vm = vm(p);
    if let Some(index) = vm.argv_status() {
        vm.declared_error = super::error::ERR_INVALID_ARGUMENT_ENCODING;
        vm.declared_payload.clear();
        // Same text `rt_fail_declared` records, so an unhandled argv failure
        // reads identically to every other backend's (the offending
        // argument's index is deliberately not part of the error).
        let _ = index;
        let message = "uncaught propagated error: <error InvalidArgumentEncoding>".to_string();
        return vm.fail(RtError::Semantic { kind: "UNCAUGHT-ERROR", message });
    }
    let roots = vm.temp_roots.len();
    let count = vm.argv_raw().len();
    for i in 0..count {
        // The argument was validated above: from_utf8 cannot fail, and the
        // Vec is borrowed only for this copy into the new String.
        let text = std::str::from_utf8(&vm.argv_raw()[i]).expect("validated UTF-8").to_owned();
        let s = vm.new_str(&text);
        if s == NO_VALUE {
            vm.temp_roots.truncate(roots);
            return NO_VALUE;
        }
        vm.temp_roots.push(s);
    }
    let items = vm.temp_roots[roots..].to_vec();
    let list = vm.new_list(items);
    vm.temp_roots.truncate(roots);
    vm.metrics.record_list_copy(count);
    list
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_cat(p: *mut Vm, a: Value, b: Value) -> Value {
    let (x, y) = (str_of(a), str_of(b));
    // The character count and ASCII flag follow from the operands: no rescan.
    // The final byte length is the sum of the operands': one allocation, each
    // operand copied once, straight into place.
    let (chars, ascii) = (x.chars + y.chars, x.ascii && y.ascii);
    let r = vm(p).new_str_pieces(&[x.as_str(), y.as_str()], chars, ascii);
    vm(p).metrics.record_string_copy(x.len_bytes() + y.len_bytes());
    r
}

/// `str::append_char(S, C)` (core/strings.tcl's `appendChar`): a new String
/// of S's characters followed by the character C. The construction
/// rt_str_cat makes, with C's UTF-8 encoding (1 to 4 bytes) as the second
/// piece: one allocation of exactly the final size, S's bytes and C's
/// encoding copied once, straight into place; the character count is S's
/// plus one and the String is ASCII when S is and C is. A UnicodeChar is
/// always a Unicode scalar value, so C always encodes. Fallible exactly as
/// rt_str_cat is: a result past MAX_COLLECTION_LENGTH is RANGE.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_append_char(p: *mut Vm, s: Value, c: Value) -> Value {
    let x = str_of(s);
    let ch = char::from_u32(char_of(c)).expect("a UnicodeChar is a Unicode scalar value");
    let mut buf = [0u8; 4];
    let tail: &str = ch.encode_utf8(&mut buf);
    let r = vm(p).new_str_pieces(&[x.as_str(), tail], x.chars + 1, x.ascii && ch.is_ascii());
    vm(p).metrics.record_string_copy(x.len_bytes() + tail.len());
    r
}

// ---------------------------------------------------------------------------
// Tcl-compatible Unicode character classification (core/tclcompat.tcl):
// TEMPORARY compatibility primitives, not Botlish's eventual public
// Unicode-classification API -- see that file's header for the full
// rationale and the de-nativization path. Both reproduce Tcl 9's `[:alpha:]`
// / `[:alnum:]` regexp bracket-expression classes exactly, empirically
// characterized (not assumed from documentation) against Tcl 9.0.1:
//
//   alpha  General_Category in {Lu, Ll, Lt, Lm, Lo}         ("Letter")
//   alnum  alpha, or General_Category == Nd                 ("Letter | Nd")
//
// Deliberately narrower than Rust's own `char::is_alphabetic`/
// `is_alphanumeric` (the Unicode *Alphabetic*/derived-numeric properties,
// which also admit e.g. Nl letter-numbers and other Other_Alphabetic marks
// Tcl's classes do not: U+2160 ROMAN NUMERAL ONE tests alpha=false in Tcl
// but is_alphabetic()==true in Rust) and than Python's `str.isalnum()`
// (which also admits No/Nl, not just Nd) -- see NATIVE-TCL-UNICODE.md for
// the full edge-case corpus both were checked against.
//
// `unicode-general-category` (Cargo.toml) supplies General_Category from
// Unicode 16.0 data, which matches Tcl 9.0.1's own table exactly on every
// corpus case tested, including code points assigned only as of Unicode
// 15.0/15.1/16.0 (see NATIVE-TCL-UNICODE.md's Unicode-version-skew section)
// -- chosen over hand-rolling a category table (spec's "avoid large
// hand-maintained tables") and over a heavier general-purpose regex/ICU
// dependency this reference runtime does not otherwise need.
fn tcl_alpha_char(c: char) -> bool {
    matches!(
        get_general_category(c),
        GeneralCategory::UppercaseLetter
            | GeneralCategory::LowercaseLetter
            | GeneralCategory::TitlecaseLetter
            | GeneralCategory::ModifierLetter
            | GeneralCategory::OtherLetter
    )
}

fn tcl_alnum_char(c: char) -> bool {
    tcl_alpha_char(c) || get_general_category(c) == GeneralCategory::DecimalNumber
}

/// S's one Unicode scalar, or a RANGE failure (core/tclcompat.tcl's own
/// contract: these primitives are defined only for a one-scalar String,
/// the RANGE convention for an out-of-domain argument
/// rather than silently classifying just the first character of a longer
/// string, or of the empty string).
fn one_scalar(p: *mut Vm, s: Value, native: &str) -> Result<char, Value> {
    let obj = str_of(s);
    if obj.chars != 1 {
        let message = format!("{native}: expects a single Unicode scalar, got a string of length {}", obj.chars);
        return Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }));
    }
    Ok(obj.as_str().chars().next().expect("StrObj.chars == 1 but text has no scalar"))
}

/// `std::char::is_tcl_alpha(c)` (core/tclcompat.tcl): the class of a
/// UnicodeChar, total -- generated code calls it for a non-ASCII scalar only
/// (codegen::clif's CharIsTclAlpha classifies ASCII inline).
#[unsafe(no_mangle)]
pub extern "C" fn rt_char_is_tcl_alpha(_p: *mut Vm, c: Value) -> Value {
    bool_value(tcl_alpha_char(char::from_u32(char_of(c)).expect("a UnicodeChar is a Unicode scalar value")))
}

/// `std::char::is_tcl_alnum(c)`, as rt_char_is_tcl_alpha.
#[unsafe(no_mangle)]
pub extern "C" fn rt_char_is_tcl_alnum(_p: *mut Vm, c: Value) -> Value {
    bool_value(tcl_alnum_char(char::from_u32(char_of(c)).expect("a UnicodeChar is a Unicode scalar value")))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_is_tcl_alpha(p: *mut Vm, s: Value) -> Value {
    match one_scalar(p, s, "std::str::is_tcl_alpha") {
        Ok(c) => bool_value(tcl_alpha_char(c)),
        Err(no_value) => no_value,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_is_tcl_alnum(p: *mut Vm, s: Value) -> Value {
    match one_scalar(p, s, "std::str::is_tcl_alnum") {
        Ok(c) => bool_value(tcl_alnum_char(c)),
        Err(no_value) => no_value,
    }
}

/// A validated StringRegion's (`rt_str_region_check` already checked BASE\
/// [START..END)'s bounds) one Unicode scalar, or the same RANGE failure
/// `one_scalar` reports for a materialized String of any length besides
/// one -- the non-materializing counterpart of `one_scalar` for
/// `rt_str_region_is_tcl_alpha`/`rt_str_region_is_tcl_alnum` (native/
/// lower.tcl's "String regions" section, hir/stringregion.tcl's
/// ConsumingParams). Every one-character region this milestone's own
/// recognized shape ever produces is already exactly width 1 by
/// construction (it always traces back to a `char_at`-shaped
/// `substring(text, i, i+1)`), but the check stays general -- exactly as
/// `rt_str_region_eq` stays sound for a region of any width -- rather than
/// assuming the specific shape that led here.
fn region_one_scalar(p: *mut Vm, base: Value, start: Value, end: Value, native: &str) -> Result<char, Value> {
    let b = str_of(base);
    let from = int_small(start).expect("region start already validated") as usize;
    let to = int_small(end).expect("region end already validated") as usize;
    if to - from != 1 {
        let message = format!("{native}: expects a single Unicode scalar, got a string of length {}", to - from);
        return Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }));
    }
    if b.ascii {
        Ok(b.as_bytes()[from] as char)
    } else {
        // Same seek accounting as rt_substr's/rt_str_region_eq's non-ASCII
        // paths: locating character index `from` still means decoding
        // forward from byte 0.
        let text = b.as_str();
        let mut indices = text.char_indices();
        let seek_start = indices.by_ref().nth(from).map_or(text.len(), |(i, _)| i);
        vm(p).metrics.record_utf8_seek(seek_start);
        Ok(text[seek_start..].chars().next().expect("region already validated"))
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_region_is_tcl_alpha(p: *mut Vm, base: Value, start: Value, end: Value) -> Value {
    match region_one_scalar(p, base, start, end, "std::str::is_tcl_alpha") {
        Ok(c) => bool_value(tcl_alpha_char(c)),
        Err(no_value) => no_value,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_region_is_tcl_alnum(p: *mut Vm, base: Value, start: Value, end: Value) -> Value {
    match region_one_scalar(p, base, start, end, "std::str::is_tcl_alnum") {
        Ok(c) => bool_value(tcl_alnum_char(c)),
        Err(no_value) => no_value,
    }
}

// ---------------------------------------------------------------------------
// Lists

#[unsafe(no_mangle)]
pub extern "C" fn rt_list_new(p: *mut Vm, n: u64, items: *const Value) -> Value {
    let items = unsafe { std::slice::from_raw_parts(items, n as usize) }.to_vec();
    let elements = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_list_copy(elements);
    r
}

/// `structnew SHAPE FIELD...`: a struct value of the program's shape number
/// SHAPE (STRUCTS.md). Never fails; allocates (a GC safepoint), the field
/// Values staying rooted in their registers across the call.
#[unsafe(no_mangle)]
pub extern "C" fn rt_struct_new(p: *mut Vm, shape: u64, n: u64, fields: *const Value) -> Value {
    let fields = unsafe { std::slice::from_raw_parts(fields, n as usize) }.to_vec();
    vm(p).new_struct(shape as u32, fields)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_list_len(p: *mut Vm, l: Value) -> Value {
    vm(p).new_int(list_of(l).len as i64)
}

/// `list::at` / `mutable_array::at` with an Int index that designates no
/// element: records the declared builtin error IndexNotFound (its NIR id as
/// the pending declared error, plus an UNCAUGHT-ERROR fallback for the
/// program boundary, exactly like `rt_fail_declared` and `rt_argv`) and
/// returns NO_VALUE. A `handle` with `on IndexNotFound:` catches it like any
/// declared error (STDLIB-NAMESPACES.md); every other failure of these
/// operations (a wrong-kind argument) is an ordinary semantic error raised
/// before the call by the caller's kind guards.
fn index_not_found(p: *mut Vm) -> Value {
    fail_builtin(p, super::error::ERR_INDEX_NOT_FOUND, "IndexNotFound")
}

/// `ctxroot %h`: the MutableVector or MutableArray header H, just installed
/// in the context area (MUTABLE-VECTOR.md, MUTABLE-ARRAY.md), stays a GC root for the rest of the run (the
/// context owns it; it is mutated in place, never replaced).
#[unsafe(no_mangle)]
pub extern "C" fn rt_context_root(p: *mut Vm, h: Value) -> Value {
    vm(p).context_roots.push(h);
    UNIT
}

/// `index_not_found` for the other runtime modules (runtime/mutvec.rs).
pub fn fail_index_not_found(p: *mut Vm) -> Value {
    index_not_found(p)
}

/// Records the builtin declared error ID (named NAME) as pending and fails:
/// what a handler's `declarederroreq` reads, with an UNCAUGHT-ERROR fallback
/// for the program boundary. Returns NO_VALUE.
pub(crate) fn fail_builtin(p: *mut Vm, id: u32, name: &str) -> Value {
    let vm = vm(p);
    vm.declared_error = id;
    vm.declared_payload.clear();
    let message = format!("uncaught propagated error: <error {name}>");
    vm.fail(RtError::Semantic { kind: "UNCAUGHT-ERROR", message })
}

/// An Int slice bound as `check_slice` compares it: its value, or the side
/// of the small-Int range a BigInt lies on. Every BigInt is outside every
/// valid slice (no sequence is that long), and the derived order
/// (`Below < At(_) < Above`) is the numeric one wherever `check_slice`
/// compares a BigInt with a small value.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug)]
enum Bound {
    Below,
    At(i128),
    Above,
}

fn bound_of(v: Value) -> Bound {
    match int_small(v) {
        Some(n) => Bound::At(n as i128),
        None if int_to_big(v).sign() == num_bigint::Sign::Minus => Bound::Below,
        None => Bound::Above,
    }
}

/// The end of a slice: given directly, or as a count from its start.
enum SliceEnd {
    End(Bound),
    Count(Bound),
}

/// The one slice rule (core::native::checkSlice, STDLIB-NAMESPACES.md): the
/// slice START..END of a sequence of N elements is valid iff 0 <= START <=
/// END <= N. START is checked against 0..N first, then END against
/// START..N; the first bound below its interval fails with the declared
/// builtin error LowerUnderrun, the first above it with UpperOverrun.
/// Ok((start, end)) for a valid slice; otherwise the failure (NO_VALUE),
/// already recorded.
fn check_slice(p: *mut Vm, start: Bound, end: SliceEnd, n: usize) -> Result<(usize, usize), Value> {
    let n = n as i128;
    let lower = |p| Err(fail_builtin(p, super::error::ERR_LOWER_UNDERRUN, "LowerUnderrun"));
    let upper = |p| Err(fail_builtin(p, super::error::ERR_UPPER_OVERRUN, "UpperOverrun"));
    let s = match start {
        Bound::At(s) if (0..=n).contains(&s) => s,
        Bound::At(s) if s > n => return upper(p),
        Bound::Above => return upper(p),
        _ => return lower(p),
    };
    let e = match end {
        SliceEnd::End(e) => e,
        SliceEnd::Count(Bound::At(c)) => Bound::At(s + c),
        SliceEnd::Count(beyond) => beyond,
    };
    match e {
        Bound::At(e) if e >= s && e <= n => Ok((s as usize, e as usize)),
        Bound::At(e) if e > n => upper(p),
        Bound::Above => upper(p),
        _ => lower(p),
    }
}

/// A slice's bounds at a call site proven valid by hir/completions.tcl: both
/// are small Ints, 0 <= START <= END <= N. The proof is what makes them so;
/// a violation is a compiler bug, caught here by a debug assertion (and, in
/// every build, by the slice indexing that follows panicking rather than
/// reading out of bounds).
fn proven_slice(start: Value, end: Value, n: usize) -> (usize, usize) {
    let from = int_small(start).expect("proven slice start is a small Int") as usize;
    let to = int_small(end).expect("proven slice end is a small Int") as usize;
    debug_assert!(from <= to && to <= n, "proven slice {from}..{to} of {n}");
    (from, to)
}

/// `rt_list_get` at an index proven to designate an element (`listgetproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_list_get_proven(_p: *mut Vm, l: Value, index: Value) -> Value {
    let i = int_small(index).expect("proven index is a small Int") as usize;
    list_of(l).items()[i]
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_list_get(p: *mut Vm, l: Value, index: Value) -> Value {
    let items = list_of(l).items();
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < items.len() => items[i as usize],
        _ => index_not_found(p),
    }
}

/// `list#with_length(L, N)` (`listwithlen`, LIST-CARDINALITY-REFINEMENTS.md):
/// L itself -- the same List, never a copy -- when it has exactly N
/// elements, else the declared LengthMismatch.
#[unsafe(no_mangle)]
pub extern "C" fn rt_list_with_length(p: *mut Vm, l: Value, n: Value) -> Value {
    let len = list_of(l).items().len();
    match int_small(n) {
        Some(want) if want >= 0 && want as usize == len => l,
        _ => fail_builtin(p, super::error::ERR_LENGTH_MISMATCH, "LengthMismatch"),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_list_append(p: *mut Vm, l: Value, v: Value) -> Value {
    let old = list_of(l).items();
    // Elements copied: the existing list's backing store, memmoved whole.
    // The appended element itself is a fresh write of a given value, not a
    // copy of stored data, so it is not counted here.
    let copied = old.len();
    let mut items = Vec::with_capacity(old.len() + 1);
    items.extend_from_slice(old);
    items.push(v);
    let r = vm(p).new_list(items);
    vm(p).metrics.record_list_copy(copied);
    r
}

// ---------------------------------------------------------------------------
// ImmutableSet (MINIMAL-IMMUTABLE-SET.md): deliberately the simplest sound
// representation -- an ordinary owned Value array, exactly like ListObj, with
// O(n^2) construction (dedup) and membership (both a linear scan using
// `equal`). No hashing, no bitmap, no perfect hash: this milestone commits
// only to the *semantics* (dedup by value equality, order-independent
// equality, total membership), never to any particular representation --
// see rt_set_from_list's own note on why this is deliberate.

/// L -> ImmutableSet, deduplicating by `equal` (core::value::equal's own
/// rule), O(n^2): the reference/first representation this milestone commits
/// to. A future representation (a Byte bitmap, a domain-indexed bitset, a
/// hash-consed table) may replace this without changing dedup/membership/
/// equality semantics at all -- this is the semantic reference behavior,
/// not a performance baseline to preserve.
#[unsafe(no_mangle)]
pub extern "C" fn rt_set_from_list(p: *mut Vm, l: Value) -> Value {
    let source = list_of(l).items();
    let mut items: Vec<Value> = Vec::with_capacity(source.len());
    if source.len() > PAIRWISE_LIMIT
        && let Some(kept) = dedup_by_hash(p, source)
    {
        items = kept;
    } else if let Err(failed) = dedup_pairwise(p, source, &mut items) {
        return failed;
    }
    let elements = items.len();
    let r = vm(p).new_set(items);
    vm(p).metrics.record_list_copy(elements);
    r
}

/// SOURCE's items, each kept unless an equal one was kept before it
/// (first-occurrence order), deduplicated by hash: an item is compared only
/// with the kept items of its hash, which are all it can equal, so the
/// result is `dedup_pairwise`'s in expected O(n) (REPRESENTATION-
/// INDEPENDENT-VALUE-IDENTITY.md). None when an item has no hash: the
/// pairwise scan is then where it is refused, as it always was.
fn dedup_by_hash(p: *mut Vm, source: &[Value]) -> Option<Vec<Value>> {
    let key = table_hash_key();
    let mut hashes = Vec::with_capacity(source.len());
    for &item in source {
        hashes.push(bucket_hash(p, key, item)?);
    }
    let capacity = (2 * source.len()).next_power_of_two().max(8);
    let mask = capacity - 1;
    let mut slots = vec![u32::MAX; capacity];
    let mut kept: Vec<Value> = Vec::with_capacity(source.len());
    let mut kept_hashes: Vec<u64> = Vec::with_capacity(source.len());
    'items: for (&item, &h) in source.iter().zip(hashes.iter()) {
        let mut s = h as usize & mask;
        loop {
            let j = slots[s];
            if j == u32::MAX {
                break;
            }
            // Hashable items compare totally: no comparison here refuses.
            if kept_hashes[j as usize] == h && equal(p, kept[j as usize], item).unwrap_or(false) {
                continue 'items;
            }
            s = (s + 1) & mask;
        }
        slots[s] = kept.len() as u32;
        kept.push(item);
        kept_hashes.push(h);
    }
    Some(kept)
}

/// SOURCE's items deduplicated pairwise into ITEMS (O(n^2): MINIMAL-
/// IMMUTABLE-SET.md's reference construction): Err (NO_VALUE, the error
/// recorded) when a comparison refuses its operands.
fn dedup_pairwise(p: *mut Vm, source: &[Value], items: &mut Vec<Value>) -> Result<(), Value> {
    for &item in source {
        let mut seen = false;
        for &existing in items.iter() {
            match equal(p, existing, item) {
                Ok(true) => {
                    seen = true;
                    break;
                }
                Ok(false) => {}
                Err(()) => return Err(NO_VALUE),
            }
        }
        if !seen {
            items.push(item);
        }
    }
    Ok(())
}

/// Membership: false for an absent value, never an Error *completion*
/// (items 19-20) -- there is no Result/ok-error wrapping here, unlike a
/// language-level Botlish Error. S must already be an ImmutableSet (the
/// dynamic dispatch guard/-param-types check ahead of this call enforces
/// that); V may be any value of any kind -- a mismatched ordinary kind
/// (e.g. Int vs UnicodeChar) simply never compares equal to any member, not
/// a TYPE error (item 20). The one honest exception, inherited unchanged
/// from `equal`/`core::value::equal` (never invented for sets specifically,
/// per item 17-18's own instruction to reuse existing equality as-is): if V
/// or a member being compared against it is Block/Native/MutArray, that one
/// comparison raises the same pre-existing EQUALITY runtime trap `==`
/// already has for those kinds -- see MINIMAL-IMMUTABLE-SET.md's
/// "Membership semantics" for why this is a documented consequence, not a
/// new failure mode.
#[unsafe(no_mangle)]
pub extern "C" fn rt_set_contains(p: *mut Vm, s: Value, v: Value) -> Value {
    for &item in set_of(s).items() {
        match equal(p, item, v) {
            Ok(true) => return TRUE,
            Ok(false) => {}
            Err(()) => return NO_VALUE,
        }
    }
    bool_value(false)
}

// ---------------------------------------------------------------------------
// MutableArrays (MUTABLE-ARRAY.md): fixed-length mutable VALUES. A
// MutableArray is a header (value.rs's MutArrayObj: the identity of one
// logical array) over a copy-on-write backing (runtime/mutvec.rs's
// header/backing model for a MutableVector; a fixed length makes the backing
// one allocation, `Rc<[Value]>`, where a vector's `Rc<VecDeque>` is two): a
// logical copy (`mvshare` with `h`, inserted by the compiler, hir/mutvec.tcl)
// is a new header on the same backing, and the first write through a header
// whose backing is shared detaches it (`array_writable`: one shallow copy of
// the element words, counted). Growth policy, chunking and finalization
// strategy stay ordinary Botlish (see examples/stdlib): the array's length
// never changes after construction -- only a consuming loop drains an affine
// array it owns, which is dead to the program by then, by advancing its
// header's start past the elements it took.
//
// The writes (set, swap, copy, and their affine `_drop` forms) are the only
// places a slot's value ever changes after construction: a future write
// barrier (e.g. for a generational collector) has exactly these call sites
// to instrument -- and codegen::clif's inline `mutable_array::set` fast
// path (`mutarray_set`), the one store generated code makes to a slot,
// through the header's PTR word when its UNIQUE word says the backing is
// this header's alone (value.rs's MutArrayObj).
//
// "No misleading copy accounting": record_mutarray_copy is called only for
// movement of *existing* values -- bulk copy and finalization -- never for a
// single fresh write of a caller-supplied value (that is charged, optionally,
// as a mutarray write via record_mutarray_write instead); a detach is
// counted apart (record_mutarray_detach).

/// A new MutableArray header on BACKING, its elements from START on
/// (allocates; may collect first), registering BYTES of element storage
/// with the heap: a new backing's, or 0 for a share (counted when it was
/// made; a detach counts its own copy).
pub fn new_mutarray_header(p: *mut Vm, start: usize, backing: Rc<[Value]>, bytes: usize) -> Value {
    vm(p).alloc(MutArrayObj::new(start, backing), bytes)
}

/// The elements of array ARR, unique to its header: a shared backing is
/// detached first (one shallow copy of the elements, counted, into a new
/// backing of exactly their length), a unique one returned as is.
fn array_writable<'a>(p: *mut Vm, arr: Value) -> &'a mut [Value] {
    let obj = mutarray_of_mut(arr);
    if obj.backing_extent().1 > 1 {
        let n = obj.len();
        let vm = vm(p);
        vm.metrics.record_mutarray_detach(n);
        vm.heap.note_growth(n * 8);
        obj.replace_backing(backing_of(obj.items()));
    }
    obj.items_mut().expect("a detached backing is unique")
}

/// The elements of affine array ARR: its backing is never shared (an affine
/// array is moved, never copied), so this never copies an element.
pub fn array_owned<'a>(arr: Value, what: &str) -> &'a mut [Value] {
    match mutarray_of_mut(arr).items_mut() {
        Some(slots) => slots,
        None => panic!("{what}: an affine MutableArray's backing is shared (an ownership invariant violation)"),
    }
}

/// Moves every element out of affine array ARR, which is left with none
/// (its start past them: the array is dying), and returns them, first to
/// last. They stay in the backing's slots, which nothing reads again; no
/// element is copied.
fn take_elements<'a>(arr: Value, what: &str) -> &'a [Value] {
    let n = array_owned(arr, what).len();
    mutarray_of_mut(arr).advance(n)
}

/// The checked capacity of a new array for operation NAME: an Int in
/// 0..=MAX_COLLECTION_LENGTH, else RANGE (Err: the failure, recorded).
fn array_capacity(p: *mut Vm, capacity: Value, name: &str) -> Result<usize, Value> {
    match int_small(capacity) {
        Some(n) if n >= 0 && (n as u64) <= MAX_COLLECTION_LENGTH as u64 => Ok(n as usize),
        _ => {
            let message = format!("{name}: capacity must be 0..{MAX_COLLECTION_LENGTH}, got {}", int_to_big(capacity));
            Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }))
        }
    }
}

/// A new backing holding ITEMS, in one allocation: the iterator's exact
/// length lets the Rc be allocated at its final size and filled in place.
/// Element by element, never one `memcpy` (`Rc::from`): on an x86-64 with
/// ERMS but no FSRM, glibc copies a mid-sized block (80 KB, a detach of
/// 10 000 elements) with `rep movsb`, measured 12 % slower than this loop --
/// and than the `VecDeque` clone the detach used to be.
fn backing_of(items: &[Value]) -> Rc<[Value]> {
    items.iter().copied().collect()
}

/// A fresh array of ITEMS (a new, unique backing). Every caller builds the
/// backing in one allocation, by collecting an iterator of exact length
/// (`backing_of`, `repeat_n`).
fn new_array_of(p: *mut Vm, items: Rc<[Value]>) -> Value {
    let bytes = items.len() * 8;
    new_mutarray_header(p, 0, items, bytes)
}

/// The index Int I of an array of N slots, if it designates one.
fn array_index(i: Value, n: usize) -> Option<usize> {
    match int_small(i) {
        Some(i) if i >= 0 && (i as usize) < n => Some(i as usize),
        _ => None,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_allocate(p: *mut Vm, capacity: Value) -> Value {
    match array_capacity(p, capacity, "std::mutable_array::allocate") {
        Ok(n) => new_array_of(p, std::iter::repeat_n(UNIT, n).collect()),
        Err(failed) => failed,
    }
}

/// `mutable_array::create(n, x)`: N slots, each holding X (one unrestricted
/// value placed N times: the compiler rejects an affine X).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_create(p: *mut Vm, capacity: Value, x: Value) -> Value {
    match array_capacity(p, capacity, "std::mutable_array::create") {
        Ok(n) => new_array_of(p, std::iter::repeat_n(x, n).collect()),
        Err(failed) => failed,
    }
}

/// `mutable_array::from_list(xs)`: the List's elements, in order.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_from_list(p: *mut Vm, list: Value) -> Value {
    new_array_of(p, backing_of(list_of(list).items()))
}

/// `mutable_array::generate(n, f)` (D = None) and `#generate_drop(n, f, D)`:
/// slot I holds FACTORY(I), for I from 0 to N - 1, in order. The first call
/// that fails ends the construction: its failure is the result (NO_VALUE,
/// already recorded by the call), after the elements already made were
/// dropped by D, first to last (affine elements; unrestricted ones are left
/// to the collector). The array under construction, the factory and the
/// descriptor are rooted across every call (each may collect).
fn generate(p: *mut Vm, capacity: Value, factory: Value, d: Option<Value>, name: &str) -> Value {
    let n = match array_capacity(p, capacity, name) {
        Ok(n) => n,
        Err(failed) => return failed,
    };
    let rooted = vm(p).temp_roots.len();
    vm(p).temp_roots.push(factory);
    if let Some(d) = d {
        vm(p).temp_roots.push(d);
    }
    // Every slot is UNIT until its call returns: the collector may trace the
    // array at any call, and finds only values.
    let arr = new_array_of(p, std::iter::repeat_n(UNIT, n).collect());
    vm(p).temp_roots.push(arr);
    for i in 0..n {
        let arg = make_small(i as i64);
        let x = rt_call_value(p, factory, 1, &arg);
        if x == NO_VALUE {
            if let Some(d) = d {
                let items = take_elements(arr, name)[..i].iter().copied();
                let text = str_of(d).as_str().as_bytes().to_vec();
                for item in items {
                    super::affine::drop_descriptor(p, item, &text);
                }
            }
            vm(p).temp_roots.truncate(rooted);
            return NO_VALUE;
        }
        // No safepoint between the call's return and the store: X is in
        // the (rooted) array before anything can collect again.
        mutarray_of_mut(arr).items_mut().expect("a unique backing under construction")[i] = x;
    }
    vm(p).temp_roots.truncate(rooted);
    arr
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_generate(p: *mut Vm, capacity: Value, factory: Value) -> Value {
    generate(p, capacity, factory, None, "std::mutable_array::generate")
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_generate_drop(p: *mut Vm, capacity: Value, factory: Value, d: Value) -> Value {
    generate(p, capacity, factory, Some(d), "mutable_array#generate_drop")
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_capacity(p: *mut Vm, arr: Value) -> Value {
    vm(p).new_int(mutarray_of(arr).items().len() as i64)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_get(p: *mut Vm, arr: Value, index: Value) -> Value {
    let slots = mutarray_of(arr).items();
    match array_index(index, slots.len()) {
        Some(i) => {
            let v = slots[i];
            vm(p).metrics.record_mutarray_read();
            v
        }
        None => index_not_found(p),
    }
}

/// `rt_mutarray_get` at an index proven to designate a slot (`mutarraygetproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_get_proven(p: *mut Vm, arr: Value, index: Value) -> Value {
    let i = int_small(index).expect("proven index is a small Int") as usize;
    let v = mutarray_of(arr).items()[i];
    vm(p).metrics.record_mutarray_read();
    v
}

/// `rt_mutarray_set` at an index proven to designate a slot (`mutarraysetproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_set_proven(p: *mut Vm, arr: Value, index: Value, value: Value) -> Value {
    let i = int_small(index).expect("proven index is a small Int") as usize;
    array_writable(p, arr)[i] = value;
    vm(p).metrics.record_mutarray_write();
    UNIT
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_set(p: *mut Vm, arr: Value, index: Value, value: Value) -> Value {
    match array_index(index, mutarray_of(arr).items().len()) {
        Some(i) => {
            array_writable(p, arr)[i] = value;
            vm(p).metrics.record_mutarray_write();
            UNIT
        }
        None => index_not_found(p),
    }
}

/// `mutable_array::swap(a, i, x)`: X installed at I, the old element moved
/// out; IndexNotFound and nothing changes when I is no slot.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_swap(p: *mut Vm, arr: Value, index: Value, value: Value) -> Value {
    match array_index(index, mutarray_of(arr).items().len()) {
        Some(i) => {
            vm(p).metrics.record_mutarray_write();
            std::mem::replace(&mut array_writable(p, arr)[i], value)
        }
        None => index_not_found(p),
    }
}

/// `mutable_array#swap_drop(a, i, x, d)`: swap of affine elements. When I is
/// no slot the replacement X -- already owned by this operation -- is
/// dropped by D before IndexNotFound; the array is unchanged.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_swap_drop(p: *mut Vm, arr: Value, index: Value, value: Value, d: Value) -> Value {
    match array_index(index, mutarray_of(arr).items().len()) {
        Some(i) => std::mem::replace(&mut array_owned(arr, "mutable_array#swap_drop")[i], value),
        None => {
            super::affine::drop_descriptor(p, value, str_of(d).as_str().as_bytes());
            index_not_found(p)
        }
    }
}

/// `mutable_array#set_drop(a, i, x, d)`: set of affine elements. The
/// displaced element leaves the array, then is dropped by D; when I is no
/// slot, X is dropped by D instead before IndexNotFound.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_set_drop(p: *mut Vm, arr: Value, index: Value, value: Value, d: Value) -> Value {
    let text = str_of(d).as_str().as_bytes();
    match array_index(index, mutarray_of(arr).items().len()) {
        Some(i) => {
            let old = std::mem::replace(&mut array_owned(arr, "mutable_array#set_drop")[i], value);
            super::affine::drop_descriptor(p, old, text);
            UNIT
        }
        None => {
            super::affine::drop_descriptor(p, value, text);
            index_not_found(p)
        }
    }
}

/// Bulk copy: COUNT elements of SRC starting at SRC_START into DST starting
/// at DST_START, with memmove semantics: DST and SRC may be the same array
/// (or share a backing) with overlapping ranges, and the result is always as
/// if SRC's elements were read before any of DST's were written. Both ranges
/// are slices (`check_slice`), the destination's checked first; an invalid
/// one fails with LowerUnderrun/UpperOverrun and copies nothing.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_copy(p: *mut Vm, dst: Value, dst_start: Value, src: Value, src_start: Value, count: Value) -> Value {
    let dst_len = mutarray_of(dst).items().len();
    let src_len = mutarray_of(src).items().len();
    let (ds, end) = match check_slice(p, bound_of(dst_start), SliceEnd::Count(bound_of(count)), dst_len) {
        Ok(slice) => slice,
        Err(failed) => return failed,
    };
    let ss = match check_slice(p, bound_of(src_start), SliceEnd::Count(bound_of(count)), src_len) {
        Ok((ss, _)) => ss,
        Err(failed) => return failed,
    };
    mutarray_copy_range(p, dst, ds, src, ss, end - ds)
}

/// `rt_mutarray_copy` at a call site whose destination and source slices are
/// both proven valid (`mutarraycopyproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_copy_proven(p: *mut Vm, dst: Value, dst_start: Value, src: Value, src_start: Value, count: Value) -> Value {
    let n = int_small(count).expect("proven count is a small Int") as usize;
    let ds = int_small(dst_start).expect("proven start is a small Int") as usize;
    let ss = int_small(src_start).expect("proven start is a small Int") as usize;
    // An internal invariant check (an abort, never a Botlish error), so a
    // proof bug cannot become a wrong copy. One comparison beside a bulk copy.
    assert!(
        ds + n <= mutarray_of(dst).items().len() && ss + n <= mutarray_of(src).items().len(),
        "proven std::mutable_array::copy out of bounds"
    );
    mutarray_copy_range(p, dst, ds, src, ss, n)
}

/// Copies N slots of SRC from SS into DST at DS (both ranges already valid).
fn mutarray_copy_range(p: *mut Vm, dst: Value, ds: usize, src: Value, ss: usize, n: usize) -> Value {
    if n > 0 {
        if dst == src {
            let items = array_writable(p, dst);
            items.copy_within(ss..ss + n, ds);
        } else {
            // DST's elements first: once writable they are DST's alone, so a
            // backing SRC shares with DST (a logical copy) has been detached
            // from DST by now and stays SRC's, unchanged.
            let items = array_writable(p, dst);
            items[ds..ds + n].copy_from_slice(&mutarray_of(src).items()[ss..ss + n]);
        }
        vm(p).metrics.record_mutarray_copy(n);
    }
    UNIT
}

/// Final immutable storage creation: a new List of ARR's first COUNT
/// elements -- the one way an array's contents become an ordinary immutable
/// List. Always copies.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_freeze(p: *mut Vm, arr: Value, count: Value) -> Value {
    let n = mutarray_of(arr).items().len();
    match check_slice(p, Bound::At(0), SliceEnd::End(bound_of(count)), n) {
        Ok((_, n)) => freeze_prefix(p, arr, n),
        Err(failed) => failed,
    }
}

/// `rt_mutarray_freeze` at a call site whose slice is proven valid
/// (`mutarrayfreezeproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_freeze_proven(p: *mut Vm, arr: Value, count: Value) -> Value {
    let n = int_small(count).expect("proven count is a small Int") as usize;
    debug_assert!(n <= mutarray_of(arr).items().len());
    freeze_prefix(p, arr, n)
}

/// A new List of ARR's first N slots (N already known valid).
fn freeze_prefix(p: *mut Vm, arr: Value, n: usize) -> Value {
    let items: Vec<Value> = mutarray_of(arr).items()[..n].to_vec();
    let elements = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_mutarray_copy(elements);
    r
}

/// `mutable_array#to_list(a)`: an immutable List snapshot of every element
/// (the domain a loop over an unrestricted array iterates).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_to_list(p: *mut Vm, arr: Value) -> Value {
    let items: Vec<Value> = mutarray_of(arr).items().to_vec();
    vm(p).new_list(items)
}

/// Whether a consumed array has no element left (a consuming loop's test).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_empty(_p: *mut Vm, arr: Value) -> Value {
    bool_value(mutarray_of(arr).items().is_empty())
}

/// `mutable_array#take_front(a)`: the first element of a consumed array,
/// moved out (one step of a consuming loop, O(1)): the header's start
/// advances past it. The backing is never written, so this never detaches.
/// The drained slots are freed with the header.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_take_front(_p: *mut Vm, arr: Value) -> Value {
    let obj = mutarray_of_mut(arr);
    assert!(obj.len() > 0, "mutable_array#take_front: no element left");
    obj.advance(1)[0]
}

/// The `a` drop of affine.rs: every element of array ARR by the element
/// descriptor at POS of D, first to last. The elements leave the (dying)
/// array before any is dropped. Returns with POS past the element descriptor.
pub fn drop_array_elements(p: *mut Vm, arr: Value, d: &[u8], pos: &mut usize) {
    let start = *pos;
    let items = take_elements(arr, "affine#drop");
    if items.is_empty() {
        super::affine::skip(d, pos);
    }
    for &item in items {
        *pos = start;
        super::affine::drop_at(p, item, d, pos);
    }
}

/// A logical copy of array ARR (`mvshare`'s `h` of an array header): a new
/// header on the same backing (and the same elements of it), O(1).
pub fn share_array(p: *mut Vm, arr: Value) -> Value {
    let (start, backing) = mutarray_of_mut(arr).share_backing();
    vm(p).metrics.record_mutarray_share();
    new_mutarray_header(p, start, backing, 0)
}

/// The live elements of array ARR, first to last (the collector's trace).
pub fn array_elements(arr: Value) -> impl Iterator<Item = Value> {
    mutarray_of(arr).items().iter().copied()
}

/// Approximate bytes array ARR owns (heap.rs's object_size): its header and
/// its share of the backing.
pub fn array_object_size(arr: Value) -> usize {
    let (slots, holders) = mutarray_of(arr).backing_extent();
    std::mem::size_of::<MutArrayObj>() + slots * 8 / holders
}

// ---------------------------------------------------------------------------
// UnicodeChar (char::scalar_value, core/unicodechar.tcl): total,
// never fails. A Unicode scalar value is always <= 0x10FFFF, well inside the
// small-Int range, so the result is always an immediate small Int -- no
// allocation, matching the operand it reads from (see runtime/value.rs's
// own header).

#[unsafe(no_mangle)]
pub extern "C" fn rt_char_codepoint(_p: *mut Vm, v: Value) -> Value {
    make_small(char_of(v) as i64)
}

// ---------------------------------------------------------------------------
// Floating-point values (FLOAT64-MILESTONE-1.md; core/float.tcl states the
// semantics, which these follow operation for operation). Generated code
// computes the arithmetic and comparisons itself (codegen::clif's
// float_op) and calls only rt_float_new and rt_float_nonfinite; the rest
// serve the operations it leaves to the runtime (from_int, truncate) and a
// native called as a value (apply_op).

/// The floating-point value of type TY (FloatType: its numbering in
/// FloatType::code) whose bits BITS FloatType::admit accepted.
#[unsafe(no_mangle)]
pub extern "C" fn rt_float_new(p: *mut Vm, ty: u64, bits: u64) -> Value {
    vm(p).new_float(FloatType::from_code(ty), bits)
}

/// The cases of the builtin enum NonFiniteResult (core/float.tcl), by the
/// code generated code passes rt_float_nonfinite (codegen::clif's
/// `non_finite_code`): which non-finite result an operation had.
pub const NON_FINITE_CASES: [&str; 3] = ["PositiveInfinity", "NegativeInfinity", "NotANumber"];

/// The NonFiniteResult code (NON_FINITE_CASES) of the non-finite number X:
/// NotANumber for NaN, else the infinity of X's sign.
pub fn non_finite_code(x: f64) -> u64 {
    if x.is_nan() {
        2
    } else if x > 0.0 {
        0
    } else {
        1
    }
}

/// Fails with the declared builtin error NonFiniteFloat: an operation's
/// result is no finite number, RESULT (NON_FINITE_CASES) the one it would
/// have been. The payload {result: NonFiniteResult} goes into the payload
/// slots like any declared error's (rt_fail_declared_payload): the case word
/// and the anonymous shape are the program's own, found in its tables by
/// name -- native lowering declares both in every program whose runtime may
/// raise the error (native/lower.tcl's PayloadTables). Returns NO_VALUE.
#[unsafe(no_mangle)]
pub extern "C" fn rt_float_nonfinite(p: *mut Vm, result: u64) -> Value {
    let case = NON_FINITE_CASES[(result as usize).min(2)];
    let payload = super::vm::try_current_program(|program| {
        let e = program.enums.iter().position(|info| info.name == "NonFiniteResult")?;
        let c = program.enums[e].cases.iter().position(|name| name == case)?;
        let s = program.shapes.iter().position(|shape| shape.name.is_none() && shape.fields == ["result"])?;
        Some((make_enum(e as u32, c as u32), s as u32))
    })
    .flatten();
    let failed = fail_builtin(p, super::error::ERR_NON_FINITE_FLOAT, "NonFiniteFloat");
    if let Some((word, shape)) = payload {
        let vm = vm(p);
        vm.declared_payload.push(word);
        vm.declared_payload_shape = shape;
    }
    failed
}

/// The value of number X of type TY, or the NonFiniteFloat failure.
pub(crate) fn float_value(p: *mut Vm, ty: FloatType, x: f64) -> Value {
    match ty.admit(x) {
        Some(bits) => vm(p).new_float(ty, bits),
        None => rt_float_nonfinite(p, non_finite_code(x)),
    }
}

/// The nearest Float64 of the Int N (ties to even), or NonFiniteFloat.
/// num-bigint's conversion rounds to odd at 64 bits and then to nearest, the
/// correctly rounded result (core/float.tcl's Tcl `double()`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_f64_from_int(p: *mut Vm, n: Value) -> Value {
    use num_traits::ToPrimitive;
    let x = match int_small(n) {
        Some(i) => i as f64,
        None => int_to_big(n).to_f64().unwrap_or(f64::INFINITY),
    };
    float_value(p, FloatType::Float64, x)
}

/// The Int of the Float64 V toward zero: exact (every finite float is an
/// Int and a fraction), never failing.
#[unsafe(no_mangle)]
pub extern "C" fn rt_f64_trunc(p: *mut Vm, v: Value) -> Value {
    use num_traits::FromPrimitive;
    let t = float64_of(v).trunc();
    if t.abs() < 4611686018427387904.0 {
        return make_small(t as i64);
    }
    vm(p).new_big(BigInt::from_f64(t).expect("a finite float is an integer once truncated"))
}

/// The Int nearest the Float64 V, ties to the even Int (std::float64::round,
/// core::float::Nearest; NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md): exact and
/// never failing. Rounding a finite binary64 to an integral one is exact
/// (below 2^52 the integer fits the significand; above it every binary64
/// already is one), so the integral value is converted exactly, as
/// rt_f64_trunc converts its own.
#[unsafe(no_mangle)]
pub extern "C" fn rt_f64_round(p: *mut Vm, v: Value) -> Value {
    use num_traits::FromPrimitive;
    let r = float64_of(v).round_ties_even();
    if r.abs() < 4611686018427387904.0 {
        return make_small(r as i64);
    }
    vm(p).new_big(BigInt::from_f64(r).expect("a finite float is an integer once rounded"))
}

/// The floating-point operation OP of type TY on A (and B): what a native
/// called as a value performs, and the reference every generated sequence
/// computes the same as (codegen::clif's float_op).
pub(crate) fn float_apply(p: *mut Vm, ty: FloatType, op: crate::nir::FloatOp, a: Value, b: Value) -> Value {
    use crate::nir::FloatOp::*;
    match ty {
        FloatType::Float64 => match op {
            FromInt => rt_f64_from_int(p, a),
            Trunc => rt_f64_trunc(p, a),
            Neg => float_value(p, ty, 0.0 - float64_of(a)),
            _ => {
                let (x, y) = (float64_of(a), float64_of(b));
                match op {
                    Add => float_value(p, ty, x + y),
                    Sub => float_value(p, ty, x - y),
                    Mul => float_value(p, ty, x * y),
                    Div => float_value(p, ty, x / y),
                    Lt => bool_value(x < y),
                    Le => bool_value(x <= y),
                    Gt => bool_value(x > y),
                    Ge => bool_value(x >= y),
                    Eq => bool_value(float_bits(a) == float_bits(b)),
                    FromInt | Trunc | Neg => unreachable!(),
                }
            }
        },
        // DecimalRounded's arithmetic: the binary64 operation on the
        // representations, exactly Float64's (core::decimal::apply); its
        // result is a DecimalRounded value. Its comparisons and conversions
        // are runtime::decimal's.
        FloatType::DecimalRounded => match op {
            Neg => float_value(p, ty, 0.0 - float64_of(a)),
            Add | Sub | Mul | Div => {
                let (x, y) = (float64_of(a), float64_of(b));
                float_value(p, ty, match op {
                    Add => x + y,
                    Sub => x - y,
                    Mul => x * y,
                    _ => x / y,
                })
            }
            Lt | Le | Gt | Ge | Eq | FromInt | Trunc => unreachable!("no DecimalRounded operation"),
        },
    }
}

// ---------------------------------------------------------------------------
// Kinds and Results

#[unsafe(no_mangle)]
pub extern "C" fn rt_is_kind(_p: *mut Vm, v: Value, kind: u64) -> Value {
    bool_value(kind_of(v).code() as u64 == kind)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_is_result(_p: *mut Vm, v: Value, ok: u64) -> Value {
    bool_value(heap_kind(v) == KIND_RESULT && result_of(v).ok == (ok != 0))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_result_payload(p: *mut Vm, v: Value, ok: u64) -> Value {
    let r = result_of(v);
    if r.ok != (ok != 0) {
        let context = if ok != 0 { "result-value" } else { "result-error" };
        return vm(p).fail(RtError::ResultTag { context, expected_ok: ok != 0, got: v });
    }
    r.payload
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_result_new(p: *mut Vm, ok: u64, v: Value) -> Value {
    vm(p).new_result(ok != 0, v)
}

// ---------------------------------------------------------------------------
// Closures

#[unsafe(no_mangle)]
pub extern "C" fn rt_closure_new(p: *mut Vm, func: u64, code: u64, n: u64, caps: *const Value) -> Value {
    let caps: Box<[Value]> = unsafe { std::slice::from_raw_parts(caps, n as usize) }.into();
    let arity = vm(p).info.functions[func as usize].arity as u32;
    let obj = ClosureObj {
        hdr: Header::new(KIND_CLOSURE, false),
        func: func as u32,
        arity,
        code: code as usize,
        ncaps: n as usize,
        caps: Box::into_raw(caps) as *mut Value,
    };
    vm(p).alloc(obj, n as usize * 8)
}

// ---------------------------------------------------------------------------
// Calls chosen at run time (core::callable::invoke)

#[unsafe(no_mangle)]
pub extern "C" fn rt_call_value(p: *mut Vm, callee: Value, n: u64, args: *const Value) -> Value {
    let args = unsafe { std::slice::from_raw_parts(args, n as usize) };
    match heap_kind(callee) {
        KIND_CLOSURE => {
            let c = closure_of(callee);
            if c.arity as usize != args.len() {
                let pnames = vm(p).info.functions[c.func as usize].pnames.clone();
                let message =
                    format!("block ({pnames}) expects {} argument(s), got {}", c.arity, args.len());
                return vm(p).fail(RtError::Semantic { kind: "ARITY", message });
            }
            let entry: GenericEntry = unsafe { std::mem::transmute(c.code) };
            entry(p, callee, args.as_ptr())
        }
        KIND_NATIVE => {
            let index = unsafe { as_ref::<NativeObj>(callee) }.native as usize;
            let info = vm(p).info.clone();
            invoke_native(p, &info.natives[index], args)
        }
        _ => vm(p).fail(RtError::NotCallable { got: callee }),
    }
}

/// core::native::invoke for a native with a native implementation: the
/// arity check, the parameter kind checks its implementation makes (in
/// order), then the operation.
pub fn invoke_native(p: *mut Vm, native: &NativeInfo, args: &[Value]) -> Value {
    if let Some(arity) = native.arity {
        if arity != args.len() {
            let message = format!("{} expects {} argument(s), got {}", native.name, arity, args.len());
            return vm(p).fail(RtError::Semantic { kind: "ARITY", message });
        }
    }
    for (arg, kind) in args.iter().zip(native.params.iter()) {
        if let Some(kind) = kind {
            if kind_of(*arg) != *kind {
                return vm(p).fail(RtError::Type { context: native.name.clone(), expected: *kind, got: *arg });
            }
        }
    }
    apply_op(p, native.op, args)
}

/// The operation OP on operands of the kinds it requires.
pub fn apply_op(p: *mut Vm, op: OpCode, a: &[Value]) -> Value {
    use OpCode::*;
    let cmp = |ord: fn(Ordering) -> bool| bool_value(ord(int_compare(a[0], a[1])));
    match op {
        IAdd => rt_int_add(p, a[0], a[1]),
        ISub => rt_int_sub(p, a[0], a[1]),
        IMul => rt_int_mul(p, a[0], a[1]),
        IMod => rt_int_mod(p, a[0], a[1]),
        IAnd => rt_int_and(p, a[0], a[1]),
        IOr => rt_int_or(p, a[0], a[1]),
        IXor => rt_int_xor(p, a[0], a[1]),
        IShl => rt_int_shl(p, a[0], a[1]),
        IShr => rt_int_shr(p, a[0], a[1]),
        ILt => cmp(|o| o == Ordering::Less),
        ILe => cmp(|o| o != Ordering::Greater),
        IGt => cmp(|o| o == Ordering::Greater),
        IGe => cmp(|o| o != Ordering::Less),
        IEq => cmp(|o| o == Ordering::Equal),
        VEq | VEqTotal => rt_value_eq(p, a[0], a[1]),
        StrEq => rt_str_eq(p, a[0], a[1]),
        CharEq | EnumEq => bool_value(a[0] == a[1]),
        ListNew => rt_list_new(p, a.len() as u64, a.as_ptr()),
        StrLen => rt_str_len(p, a[0]),
        Substr => rt_substr(p, a[0], a[1], a[2]),
        StrLower => rt_str_lower(p, a[0]),
        StrCat => rt_str_cat(p, a[0], a[1]),
        StrAppendChar => rt_str_append_char(p, a[0], a[1]),
        StrUtf8Bytes => rt_str_utf8_bytes(p, a[0]),
        StrCharAt => rt_str_char_at(p, a[0], a[1]),
        StrCharAtProven => rt_str_char_at_proven(p, a[0], a[1]),
        Argv => rt_argv(p),
        StrIsTclAlpha => rt_is_tcl_alpha(p, a[0]),
        StrIsTclAlnum => rt_is_tcl_alnum(p, a[0]),
        CharIsTclAlpha => rt_char_is_tcl_alpha(p, a[0]),
        CharIsTclAlnum => rt_char_is_tcl_alnum(p, a[0]),
        ListLen => rt_list_len(p, a[0]),
        ListGet => rt_list_get(p, a[0], a[1]),
        ListAppend => rt_list_append(p, a[0], a[1]),
        ListWithLength => rt_list_with_length(p, a[0], a[1]),
        SetFromList => rt_set_from_list(p, a[0]),
        // Same runtime helper as SetFromList: the distinction is purely an
        // op_may_error classification (see OpCode::SetFromListTotal's own
        // doc comment). Unreachable via a Native value's own generic entry
        // (native/lower.tcl's NativeImpl never selects this opcode for a
        // native declaration's `impl=`), kept here only for apply_op's own
        // match exhaustiveness.
        SetFromListTotal => rt_set_from_list(p, a[0]),
        SetContains => rt_set_contains(p, a[0], a[1]),
        // Same runtime helper as SetContains: the distinction is purely an
        // op_may_error classification (see OpCode::SetContainsTotal's own
        // doc comment). Unreachable via a Native value's own generic entry
        // (native/lower.tcl's NativeImpl never selects this opcode for a
        // native declaration's `impl=`), kept here only for apply_op's own
        // match exhaustiveness.
        SetContainsTotal => rt_set_contains(p, a[0], a[1]),
        ListGetProven => rt_list_get_proven(p, a[0], a[1]),
        MutArrayGetProven => rt_mutarray_get_proven(p, a[0], a[1]),
        MutArraySetProven => rt_mutarray_set_proven(p, a[0], a[1], a[2]),
        SubstrProven => rt_substr_proven(p, a[0], a[1], a[2]),
        MutArrayCopyProven => rt_mutarray_copy_proven(p, a[0], a[1], a[2], a[3], a[4]),
        MutArrayFreezeProven => rt_mutarray_freeze_proven(p, a[0], a[1]),
        MutArrayAllocate => rt_mutarray_allocate(p, a[0]),
        MutArrayCapacity => rt_mutarray_capacity(p, a[0]),
        MutArrayGet => rt_mutarray_get(p, a[0], a[1]),
        MutArraySet => rt_mutarray_set(p, a[0], a[1], a[2]),
        MutArrayCopy => rt_mutarray_copy(p, a[0], a[1], a[2], a[3], a[4]),
        MutArrayFreeze => rt_mutarray_freeze(p, a[0], a[1]),
        MutArrayCreate => rt_mutarray_create(p, a[0], a[1]),
        MutArrayFromList => rt_mutarray_from_list(p, a[0]),
        MutArrayGenerate => rt_mutarray_generate(p, a[0], a[1]),
        MutArrayGenerateDrop => rt_mutarray_generate_drop(p, a[0], a[1], a[2]),
        MutArraySwap => rt_mutarray_swap(p, a[0], a[1], a[2]),
        MutArraySwapDrop => rt_mutarray_swap_drop(p, a[0], a[1], a[2], a[3]),
        MutArraySetDrop => rt_mutarray_set_drop(p, a[0], a[1], a[2], a[3]),
        MutArrayToList => rt_mutarray_to_list(p, a[0]),
        MutArrayEmpty => rt_mutarray_empty(p, a[0]),
        MutArrayTakeFront => rt_mutarray_take_front(p, a[0]),
        MvFromList => rt_mv_from_list(p, a[0]),
        MvLen => rt_mv_len(p, a[0]),
        MvEmpty => rt_mv_empty(p, a[0]),
        MvAt => rt_mv_at(p, a[0], a[1]),
        MvPush => rt_mv_push(p, a[0], a[1]),
        MvPop => rt_mv_pop(p, a[0]),
        MvTake => rt_mv_take(p, a[0], a[1]),
        MvSwap => rt_mv_swap(p, a[0], a[1], a[2]),
        MvClear => rt_mv_clear(p, a[0]),
        MvShare => rt_mv_share(p, a[0], a[1]),
        MvToList => rt_mv_to_list(p, a[0]),
        MvTakeFront => rt_mv_take_front(p, a[0]),
        MvClearDrop => rt_mv_clear_drop(p, a[0], a[1]),
        MvSwapDrop => rt_mv_swap_drop(p, a[0], a[1], a[2], a[3]),
        CtxRoot => rt_context_root(p, a[0]),
        IsInt => rt_is_kind(p, a[0], Kind::Int.code() as u64),
        IsStr => rt_is_kind(p, a[0], Kind::Str.code() as u64),
        IsList => rt_is_kind(p, a[0], Kind::List.code() as u64),
        IsMutArray => rt_is_kind(p, a[0], Kind::MutArray.code() as u64),
        IsOk => rt_is_result(p, a[0], 1),
        IsError => rt_is_result(p, a[0], 0),
        ResultValue => rt_result_payload(p, a[0], 1),
        ResultError => rt_result_payload(p, a[0], 0),
        CharCodepoint => rt_char_codepoint(p, a[0]),
        F64Add | F64Sub | F64Mul | F64Div | F64Neg | F64Lt | F64Le | F64Gt | F64Ge | F64Eq | F64FromInt | F64Trunc
        | D64Add | D64Sub | D64Mul | D64Div | D64Neg => {
            let (ty, fop) = op.float().expect("a floating-point operation");
            float_apply(p, ty, fop, a[0], a.get(1).copied().unwrap_or(NO_VALUE))
        }
        D64Lt | D64Le | D64Gt | D64Ge | D64Eq => {
            let order = super::decimal::rt_decimal_cmp(p, a[0], a[1], a[2]);
            bool_value(match op {
                D64Lt => order < 0,
                D64Le => order <= 0,
                D64Gt => order > 0,
                D64Ge => order >= 0,
                _ => order == 0,
            })
        }
        D64ToF64 => super::decimal::rt_decimal_to_f64(p, a[0], a[1]),
        D64Round => super::decimal::rt_decimal_round(p, a[0], a[1]),
        D64ToStr => rt_decimal_to_str(p, a[0], a[1]),
        F64Round => rt_f64_round(p, a[0]),
        IntToStr => rt_int_to_str(p, a[0]),
        StrToInt => rt_str_to_int(p, a[0]),
        RawFromBits32 => super::ffi::rt_raw_from_bits(p, 0, a[0]),
        RawFromBits64 => super::ffi::rt_raw_from_bits(p, 1, a[0]),
        RawBits32 => super::ffi::rt_raw_bits(p, 0, a[0]),
        RawBits64 => super::ffi::rt_raw_bits(p, 1, a[0]),
        RawAdmit32 => super::ffi::rt_raw_admit(p, 0, a[0]),
        RawAdmit64 => super::ffi::rt_raw_admit(p, 1, a[0]),
        RawNarrow32 => super::ffi::rt_raw_narrow(p, 0, a[0]),
        RawNarrow64 => super::ffi::rt_raw_narrow(p, 1, a[0]),
        MkOk => rt_result_new(p, 1, a[0]),
        MkError => rt_result_new(p, 0, a[0]),
        Hash | HashTotal => rt_hash(p, a[0]),
        TableHash | TableHashTotal => rt_table_hash(p, a[0]),
        BytesFromList => rt_bytes_from_list(p, a[0]),
        BytesJoin => rt_bytes_join(p, a[0]),
        BytesDecodeUtf8 => rt_bytes_decode_utf8(p, a[0]),
        BytesSlice => rt_bytes_slice(p, a[0], a[1], a[2]),
        BytesLen => rt_bytes_len(p, a[0]),
        MBytesNew => rt_mbytes_new(p, a[0]),
        MBytesFrom => rt_mbytes_from(p, a[0]),
        MBytesLen => rt_mbytes_len(p, a[0]),
        MBytesSet => rt_mbytes_set(p, a[0], a[1], a[2]),
        MBytesClone => rt_mbytes_clone(p, a[0]),
        MBytesFreeze => rt_mbytes_freeze(p, a[0]),
        MBytesFreezePrefix => rt_mbytes_freeze_prefix(p, a[0], a[1]),
        CoCreate => rt_co_create(p, a[0]),
        CoStart => rt_co_start(p, a[0]),
        CoResume => rt_co_resume(p, a[0], a[1]),
        CoResume0 => rt_co_resume0(p, a[0]),
        CoYield => rt_co_yield(p, a[0]),
        CoDone => rt_co_done(p, a[0]),
        CPtrNull => CPTR_NULL,
        CPtrIsNull => bool_value(a[0] == CPTR_NULL),
        CPtrSame => a[0],
        CPtrFixture => rt_cptr_fixture(p, a[0]),
        CPtrFixtureAddress => rt_cptr_fixture_address(p, a[0]),
        CoRelease => rt_co_release(p, a[0]),
        AffineDrop => rt_affine_drop(p, a[0], a[1]),
        RegionCheck | RegionEq | RBox | RUnbox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq
        // A C word exists only between a C call and its uses, in one
        // function (C-FFI-ERROR-CAPTURE-MILESTONE-2.md): never a value.
        | CWBox | CWLt | CWLe | CWGt | CWGe | CWEq
        | RIShr | RIShl | RIAnd | RIOr | RIXor | RIMod | RIModTotal | RTabLoad8 | RTabLoad16 | StrToShort | ShortToStr | ShortLen | ShortEq | StrSliceShort | StrToAscii | AsciiToStr
        | AsciiLen | AsciiEq | AsciiToShort | AsciiShortEq
        | DecodeCharAt | StrByteLen | StrRegionIsTclAlpha | StrRegionIsTclAlnum
        // The syscall transports and the raw address bridges are never
        // values (hir/syscall.tcl rejects any use but a direct call), so no
        // Native value ever dispatches to them; keepalive is a
        // lowering-internal op.
        | SyscallLinuxX86_64 | SyscallLinuxAarch64 | BytesAddr | MBytesAddr | KeepAlive
        // A foreign operation is only called (hir/borrow.tcl): its byte
        // exposures exist only as one call's arguments.
        | FfiFixtureRead | FfiFixtureReadReentrant | FfiFixtureFill | FfiFixtureFillChecked | FfiFixtureCopy
        | FfiFixtureMixed
        // A fused coroutine's failure cache exists only in the code the
        // fusion pass writes (codegen::fusion).
        | CoFailed
        // The fixed-layout ops exist only in the straight-line code of one
        // statically known layout (native/lower.tcl's LayoutParse /
        // LayoutEmit): a binary operation is never a value.
        | BinLoad | BinStore | BytesZeroed
        // A native view's loads, likewise (one statically known layout's
        // field reads, NATIVE-LAYOUT-VIEWS.md); the memory fixture is an
        // imprinted native, never a value.
        | NativeLoad | NativeLoadPtr | CPtrOffset | CPtrFixtureMemory
        // A native edit's stores and the layout writes into byte storage
        // likewise (NATIVE-LAYOUT-WRITES.md); the byte fixture is an
        // ordinary-looking native of the test fixture, never a value.
        | NativeStore | NativeStorePtr | MBytesWrite | MBytesWritePtr | CPtrFixtureBytes
        // A fixed array's rows likewise (FIXED-LAYOUT-ARRAYS.md).
        | BinLoadArray | NativeLoadArray | BinStoreArray | NativeStoreArray | BinStorePtr => {
            // Raw (untagged) representation ops, StringRegion ops and String
            // traversal ops never implement a dynamic native: native/lower.tcl
            // emits them only directly, as `op` instructions inline in a
            // function's own body.
            unreachable!("{op:?} is never a native implementation")
        }
    }
}

/// Runtime helper symbols: name, number of parameters (after none: all are
/// 64-bit words, including the vm pointer) and, in `helpers()`, address.
/// `HELPER_SIGNATURES` is the same list without the addresses, for what
/// needs only the names: the ABI fingerprint (aotimage::abi_fingerprint),
/// which a system-linked executable's startup computes. Taking a helper's
/// address keeps its code linked, so a fingerprint over `helpers()` kept
/// every helper in every such executable, one that calls five of them too
/// (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, "Sizes").
macro_rules! runtime_helpers {
    ($(($name:ident, $n:expr)),* $(,)?) => {
        pub const HELPER_SIGNATURES: &[(&str, usize)] = &[$((stringify!($name), $n)),*];

        pub fn helpers() -> Vec<(&'static str, usize, *const u8)> {
            vec![$((stringify!($name), $n, $name as *const u8)),*]
        }
    };
}

runtime_helpers! {
    (rt_type_error, 4),
    (rt_ffi_open, 1),
    (rt_ffi_close, 2),
    (rt_callback_call, 5),
    (rt_float_new, 3),
    (rt_decimal_cmp, 4),
    (rt_decimal_to_f64, 3),
    (rt_decimal_round, 3),
    (rt_decimal_to_str, 3),
    (rt_int_to_str, 2),
    (rt_str_to_int, 2),
    (rt_f64_round, 2),
    (rt_float_nonfinite, 2),
    (rt_raw_new, 3),
    (rt_raw_from_bits, 3),
    (rt_raw_bits, 3),
    (rt_raw_admit, 3),
    (rt_raw_narrow, 3),
    (rt_f64_from_int, 2),
    (rt_f64_trunc, 2),
    (rt_cptr_fixture, 2),
    (rt_cptr_fixture_address, 2),
    (rt_ffi_fixture_read, 3),
    (rt_ffi_fixture_read_reentrant, 3),
    (rt_ffi_fixture_fill, 4),
    (rt_ffi_fixture_fill_checked, 4),
    (rt_ffi_fixture_copy, 4),
    (rt_ffi_fixture_mixed, 5),
    (rt_ffi_int_word, 2),
    (rt_ffi_box_i64, 2),
    (rt_ffi_box_u64, 2),
    (rt_ffi_word_cmp, 4),
    (rt_ffi_bad_address, 3),
    (rt_ffi_bad_bool, 3),
    (rt_ffi_contract_violation, 4),
    (rt_not_boolean, 2),
    (rt_raise, 3),
    (rt_stack_overflow, 1),
    (rt_fail_declared, 3),
    (rt_fail_declared_payload, 6),
    (rt_declared_payload, 2),
    (rt_declared_error, 1),
    (rt_clear_declared_error, 1),
    (rt_int_add, 3),
    (rt_int_sub, 3),
    (rt_int_mul, 3),
    (rt_int_mod, 3),
    (rt_int_and, 3),
    (rt_int_or, 3),
    (rt_int_xor, 3),
    (rt_int_shl, 3),
    (rt_int_shr, 3),
    (rt_int_cmp, 3),
    (rt_value_eq, 3),
    (rt_str_eq, 3),
    (rt_hash, 2),
    (rt_table_hash, 2),
    (rt_str_len, 2),
    (rt_substr, 4),
    (rt_substr_proven, 4),
    (rt_str_region_check, 4),
    (rt_str_region_eq, 5),
    (rt_str_decode_char_at, 3),
    (rt_str_byte_len, 2),
    (rt_str_to_short, 2),
    (rt_short_to_str, 2),
    (rt_str_to_ascii, 2),
    (rt_ascii_to_str, 2),
    (rt_str_slice_short, 4),
    (rt_str_lower, 2),
    (rt_str_cat, 3),
    (rt_str_append_char, 3),
    (rt_str_utf8_bytes, 2),
    (rt_str_char_at, 3),
    (rt_str_char_at_proven, 3),
    (rt_argv, 1),
    (rt_linux_x86_64_syscall, 8),
    (rt_linux_aarch64_syscall, 8),
    (rt_bytes_from_list, 2),
    (rt_bytes_join, 2),
    (rt_bytes_decode_utf8, 2),
    (rt_bytes_slice, 4),
    (rt_bytes_len, 2),
    (rt_bytes_addr, 2),
    (rt_mbytes_new, 2),
    (rt_mbytes_from, 2),
    (rt_mbytes_len, 2),
    (rt_mbytes_set, 4),
    (rt_mbytes_clone, 2),
    (rt_mbytes_freeze, 2),
    (rt_mbytes_freeze_prefix, 3),
    (rt_mbytes_addr, 2),
    (rt_bytes_zeroed, 2),
    (rt_bin_load, 4),
    (rt_bin_store, 5),
    (rt_native_load, 4),
    (rt_native_load_ptr, 4),
    (rt_cptr_offset, 3),
    (rt_cptr_fixture_memory, 2),
    (rt_native_store, 5),
    (rt_native_store_ptr, 5),
    (rt_mbytes_write, 5),
    (rt_mbytes_write_ptr, 5),
    (rt_bin_load_array, 5),
    (rt_native_load_array, 5),
    (rt_bin_store_array, 5),
    (rt_native_store_array, 5),
    (rt_bin_store_ptr, 5),
    (rt_cptr_fixture_bytes, 3),
    (rt_is_tcl_alpha, 2),
    (rt_is_tcl_alnum, 2),
    (rt_char_is_tcl_alpha, 2),
    (rt_char_is_tcl_alnum, 2),
    (rt_str_region_is_tcl_alpha, 4),
    (rt_str_region_is_tcl_alnum, 4),
    (rt_list_new, 3),
    (rt_struct_new, 4),
    (rt_list_len, 2),
    (rt_list_get, 3),
    (rt_list_with_length, 3),
    (rt_list_get_proven, 3),
    (rt_list_append, 3),
    (rt_construct, 4),
    (rt_plan_materialize, 2),
    (rt_set_from_list, 2),
    (rt_set_contains, 3),
    (rt_mutarray_allocate, 2),
    (rt_mutarray_capacity, 2),
    (rt_mutarray_get, 3),
    (rt_mutarray_get_proven, 3),
    (rt_mutarray_set, 4),
    (rt_mutarray_set_proven, 4),
    (rt_mutarray_copy, 6),
    (rt_mutarray_copy_proven, 6),
    (rt_mutarray_freeze, 3),
    (rt_mutarray_freeze_proven, 3),
    (rt_mutarray_create, 3),
    (rt_mutarray_from_list, 2),
    (rt_mutarray_generate, 3),
    (rt_mutarray_generate_drop, 4),
    (rt_mutarray_swap, 4),
    (rt_mutarray_swap_drop, 5),
    (rt_mutarray_set_drop, 5),
    (rt_mutarray_to_list, 2),
    (rt_mutarray_empty, 2),
    (rt_mutarray_take_front, 2),
    (rt_is_kind, 3),
    (rt_is_result, 3),
    (rt_result_payload, 3),
    (rt_result_new, 3),
    (rt_char_codepoint, 2),
    (rt_closure_new, 5),
    (rt_call_value, 4),
    (rt_co_create, 2),
    (rt_co_start, 2),
    (rt_co_resume, 3),
    (rt_co_resume0, 2),
    (rt_co_yield, 2),
    (rt_co_done, 2),
    (rt_co_release, 2),
    (rt_co_failed, 1),
    (rt_affine_drop, 3),
    (rt_mv_from_list, 2),
    (rt_mv_len, 2),
    (rt_mv_empty, 2),
    (rt_mv_at, 3),
    (rt_mv_push, 3),
    (rt_mv_pop, 2),
    (rt_mv_take, 3),
    (rt_mv_swap, 4),
    (rt_mv_clear, 2),
    (rt_mv_share, 3),
    (rt_mv_to_list, 2),
    (rt_mv_take_front, 2),
    (rt_mv_clear_drop, 3),
    (rt_mv_swap_drop, 5),
    (rt_context_root, 2),
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::{ProgramInfo, Vm};

    /// Evaluates V and pushes it onto `Vm::temp_roots` for the rest of the
    /// test, as compiled code's stack maps root a live value: under
    /// BOTLISH_NATIVE_GC_STRESS=1 every allocation collects first, so a value
    /// held only in a Rust local is freed by the next allocation.
    macro_rules! rooted {
        ($vm:expr, $v:expr) => {{
            let v = $v;
            $vm.temp_roots.push(v);
            v
        }};
    }

    fn vm() -> Box<Vm> {
        Vm::new(
            std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        )
    }

    /// A VM whose program has these struct shapes (runtime::vm::ShapeInfo).
    fn vm_with_shapes(shapes: &[(Option<&str>, &[&str])]) -> Box<Vm> {
        use crate::runtime::vm::ShapeInfo;
        Vm::new(
            std::rc::Rc::new(ProgramInfo {
                functions: Vec::new(),
                natives: Vec::new(),
                shapes: shapes
                    .iter()
                    .map(|(name, fields)| ShapeInfo {
                        name: name.map(String::from),
                        fields: fields.iter().map(|f| f.to_string()).collect(),
                        opaque: false,
                        identity: None,
                    })
                    .collect(),
                enums: Vec::new(),
                errors: Vec::new(),
            }),
            AllocMode::Summary,
        )
    }

    /// A VM whose program has these enums (runtime::vm::EnumInfo).
    fn vm_with_enums(enums: &[(&str, &[&str])]) -> Box<Vm> {
        use crate::runtime::vm::EnumInfo;
        Vm::new(
            std::rc::Rc::new(ProgramInfo {
                functions: Vec::new(),
                natives: Vec::new(),
                shapes: Vec::new(),
                enums: enums
                    .iter()
                    .map(|(name, cases)| EnumInfo {
                        name: name.to_string(),
                        cases: cases.iter().map(|c| c.to_string()).collect(),
                    })
                    .collect(),
                errors: Vec::new(),
            }),
            AllocMode::Summary,
        )
    }

    // -----------------------------------------------------------------------
    // Character classes (core/tclcompat.tcl, UNICODECHAR-CLASSIFIERS.md):
    // the UnicodeChar forms agree with the one-scalar String forms on every
    // scalar, and codegen::clif's inline ASCII rule agrees with the
    // General_Category tables on every ASCII scalar.

    #[test]
    fn char_classifiers_agree_with_string_classifiers_on_every_scalar() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        for c in (0u32..=0x10FFFF).filter_map(char::from_u32) {
            let ch = make_char(c as u32);
            let s = vm.new_str(c.encode_utf8(&mut [0u8; 4]));
            assert_eq!(rt_char_is_tcl_alpha(p, ch), rt_is_tcl_alpha(p, s), "alpha of U+{:04X}", c as u32);
            assert_eq!(rt_char_is_tcl_alnum(p, ch), rt_is_tcl_alnum(p, s), "alnum of U+{:04X}", c as u32);
            if c as u32 % 4096 == 0 {
                // Strings the test made are garbage now: keep the heap small.
                vm.reset();
            }
        }
    }

    #[test]
    fn inline_ascii_rule_is_the_general_category_rule() {
        for cp in 0u32..0x80 {
            let c = char::from_u32(cp).expect("ASCII is scalar");
            let letter = (cp | 0x20).wrapping_sub(b'a' as u32) < 26;
            let digit = cp.wrapping_sub(b'0' as u32) < 10;
            assert_eq!(letter, tcl_alpha_char(c), "alpha of U+{cp:04X}");
            assert_eq!(letter || digit, tcl_alnum_char(c), "alnum of U+{cp:04X}");
        }
    }

    // -----------------------------------------------------------------------
    // Enums (ENUMS.md): immediate words, nominal equality, hashing and
    // printing by name.

    #[test]
    fn enum_words_are_immediates_of_their_own_kind() {
        let v = make_enum(3, 5);
        assert!(is_enum(v));
        assert_eq!(enum_parts(v), (3, 5));
        assert_eq!(kind_of(v), Kind::Enum);
        assert!(!is_pointer(v) && !is_small(v) && !is_char(v));
        for other in [FALSE, TRUE, UNIT, make_small(0), make_small(-1), make_char(65)] {
            assert!(!is_enum(other), "{other:#x} is not an enum word");
        }
        assert_eq!(enum_parts(make_enum(u32::MAX, MAX_ENUM_CASE)), (u32::MAX, MAX_ENUM_CASE));
        assert_eq!(Kind::parse("enum"), Some(Kind::Enum));
        assert_eq!(Kind::from_code(Kind::Enum.code()), Kind::Enum);
    }

    #[test]
    fn enum_equality_is_nominal_word_equality() {
        let mut vm = vm_with_enums(&[("A", &["X", "Y"]), ("B", &["X"])]);
        let eq = |vm: &mut Vm, a, b| rt_value_eq(vm, a, b);
        assert_eq!(eq(&mut vm, make_enum(0, 0), make_enum(0, 0)), TRUE);
        assert_eq!(eq(&mut vm, make_enum(0, 0), make_enum(0, 1)), FALSE);
        // The same spelling in another enum is another value.
        assert_eq!(eq(&mut vm, make_enum(0, 0), make_enum(1, 0)), FALSE);
        // Never an Int, whatever the word.
        assert_eq!(eq(&mut vm, make_enum(0, 0), make_small(0)), FALSE);
    }

    #[test]
    fn enum_hash_and_show_read_names_never_numbers() {
        use crate::runtime::show::{show, tcl_value};
        let mut vm = vm_with_enums(&[
            ("VehicleType", &["Boat", "Car", "Truck", "Tank", "Tractor", "Airplane"]),
            ("Other", &["Car"]),
        ]);
        let car = make_enum(0, 1);
        // core/hashing.tcl's value for VehicleType::Car (tests/enums.test's
        // enum-hash), byte for byte.
        assert_eq!(rt_hash(&mut *vm, car), small(632455997673246507));
        assert_ne!(rt_hash(&mut *vm, car), rt_hash(&mut *vm, make_enum(1, 0)));
        assert_eq!(show(car), "VehicleType::Car");
        assert_eq!(tcl_value(car).unwrap(), "enum VehicleType Car");
        // Reordered cases: another number, the same name, the same hash.
        let mut reordered = vm_with_enums(&[("VehicleType", &["Airplane", "Tank", "Car"])]);
        assert_eq!(rt_hash(&mut *reordered, make_enum(0, 2)), small(632455997673246507));
        assert_eq!(show(make_enum(0, 2)), "VehicleType::Car");
    }

    // -----------------------------------------------------------------------
    // Structs (STRUCTS.md): equality, hashing and printing by shape.

    #[test]
    fn struct_equality_is_shape_and_field_wise() {
        // shape 0: anonymous {a, b}; 1: named Person {a, b} (same fields);
        // 2: named Account {a, b}; 3: anonymous {a}.
        let mut vm = vm_with_shapes(&[
            (None, &["a", "b"]),
            (Some("Person"), &["a", "b"]),
            (Some("Account"), &["a", "b"]),
            (None, &["a"]),
        ]);
        let s = rooted!(vm, str_val(&mut vm, "x"));
        let s2 = rooted!(vm, str_val(&mut vm, "x"));
        let anon1 = rooted!(vm, vm.new_struct(0, vec![small(1), s]));
        let anon2 = rooted!(vm, vm.new_struct(0, vec![small(1), s2]));
        let anon3 = rooted!(vm, vm.new_struct(0, vec![small(2), s]));
        let person = rooted!(vm, vm.new_struct(1, vec![small(1), s]));
        let account = rooted!(vm, vm.new_struct(2, vec![small(1), s]));
        let short = rooted!(vm, vm.new_struct(3, vec![small(1)]));
        let eq = |vm: &mut Vm, a, b| rt_value_eq(vm, a, b);
        assert_eq!(eq(&mut vm, anon1, anon2), TRUE);
        assert_eq!(eq(&mut vm, anon1, anon3), FALSE);
        // Same field names and values, different declaration or none: unequal.
        assert_eq!(eq(&mut vm, anon1, person), FALSE);
        assert_eq!(eq(&mut vm, person, account), FALSE);
        assert_eq!(eq(&mut vm, person, person), TRUE);
        assert_eq!(eq(&mut vm, anon1, short), FALSE);
        // A struct is never a List.
        let list = vm.new_list(vec![small(1), s]);
        assert_eq!(eq(&mut vm, anon1, list), FALSE);
    }

    #[test]
    fn struct_equality_keeps_the_no_equality_rule_for_arrays() {
        let mut vm = vm_with_shapes(&[(None, &["a"])]);
        let array = rooted!(vm, vm.new_mutarray(1));
        let x = rooted!(vm, vm.new_struct(0, vec![array]));
        let y = rooted!(vm, vm.new_struct(0, vec![array]));
        assert_eq!(rt_value_eq(&mut *vm, x, y), NO_VALUE);
        assert!(vm.error.is_some());
    }

    #[test]
    fn struct_hash_agrees_with_equality() {
        let mut vm = vm_with_shapes(&[(None, &["a", "b"]), (None, &["a"]), (Some("P"), &["a"])]);
        let s = rooted!(vm, str_val(&mut vm, "x"));
        let s2 = rooted!(vm, str_val(&mut vm, "x"));
        let one = rooted!(vm, vm.new_struct(0, vec![small(1), s]));
        let two = rooted!(vm, vm.new_struct(0, vec![small(1), s2]));
        let other = rooted!(vm, vm.new_struct(1, vec![small(1)]));
        let named = rooted!(vm, vm.new_struct(2, vec![small(1)]));
        let h = |vm: &mut Vm, v| rt_hash(vm, v);
        assert_eq!(h(&mut vm, one), h(&mut vm, two));
        assert_ne!(h(&mut vm, one), h(&mut vm, other));
        assert_ne!(h(&mut vm, other), h(&mut vm, named));
    }

    // -----------------------------------------------------------------------
    // hash's byte encoding is formatted without the heap (decimal_text) and
    // folds borrowed shapes; the bytes are the ones `to_string()` and the
    // shape's own strings always gave (core/hashing.tcl's, byte for byte).

    /// Interesting magnitudes: every power of ten and of two in range, each
    /// minus one and plus one, and a deterministic spread in between.
    fn decimal_samples() -> Vec<u128> {
        let mut out = vec![0, 1, 9, 10, 11, 99, 100, 101, u64::MAX as u128, u128::MAX];
        let mut p: u128 = 1;
        while let Some(next) = p.checked_mul(10) {
            out.extend([p - 1, p, p + 1]);
            p = next;
        }
        out.extend([p - 1, p, p + 1]);
        for bit in 1..128 {
            let q = 1u128 << bit;
            out.extend([q - 1, q, q + 1]);
        }
        let mut x: u128 = 0x9E37_79B9_7F4A_7C15;
        for _ in 0..20000 {
            x = x.wrapping_mul(0x2545_F491_4F6C_DD1D_9E37_79B9_7F4A_7C15).wrapping_add(1442695040888963407);
            out.push(x >> (x % 127) as u32);
        }
        out
    }

    #[test]
    fn decimal_text_is_to_string() {
        let mut buf = [0u8; 40];
        for mag in decimal_samples() {
            for neg in [false, true] {
                if neg && mag == 0 {
                    continue;
                }
                let big = if neg { -BigInt::from(mag) } else { BigInt::from(mag) };
                assert_eq!(decimal_text(neg, mag, &mut buf), big.to_string().as_bytes(), "{big}");
                if let Ok(n) = i64::try_from(&big) {
                    assert_eq!(decimal_text(n < 0, n.unsigned_abs() as u128, &mut buf), n.to_string().as_bytes());
                }
            }
        }
        for n in [i64::MIN, i64::MIN + 1, i64::MAX, SMALL_MIN, SMALL_MIN - 1, SMALL_MAX, SMALL_MAX + 1, -1, 0] {
            assert_eq!(decimal_text(n < 0, n.unsigned_abs() as u128, &mut buf), n.to_string().as_bytes());
        }
        for cp in (0..=0x10FFFFu32).filter(|cp| !(0xD800..=0xDFFF).contains(cp)) {
            assert_eq!(decimal_text(false, cp as u128, &mut buf), cp.to_string().as_bytes());
        }
    }

    /// hash_mix as it was before decimal_text and the borrowed shapes (every
    /// Int and code point through `to_string()`, every BigInt through a
    /// clone, every shape's strings cloned), for the kinds those changed:
    /// the reference the allocation-free implementation must equal.
    fn reference_mix(v: Value) -> u64 {
        let tagged = |tag: u8| fnv1a(FNV_OFFSET, &[tag]);
        match kind_of(v) {
            Kind::Int => {
                let text = match int_small(v) {
                    Some(n) => n.to_string(),
                    None => int_to_big(v).to_string(),
                };
                fnv1a(tagged(0), text.as_bytes())
            }
            Kind::Str => fnv1a(tagged(1), str_of(v).as_bytes()),
            Kind::UnicodeChar => fnv1a(tagged(6), char_of(v).to_string().as_bytes()),
            Kind::List => {
                let items = list_of(v).items();
                let mut h = fnv1a(tagged(4), &(items.len() as u64).to_le_bytes());
                for item in items {
                    h = fnv1a(h, &reference_mix(*item).to_le_bytes());
                }
                h
            }
            Kind::Enum => {
                let (e, c) = enum_parts(v);
                let (name, case) = current_program(|prog| {
                    let info = &prog.enums[e as usize];
                    (info.name.clone(), info.cases[c as usize].clone())
                });
                fnv1a(fnv1a(fnv1a(tagged(11), name.as_bytes()), &[0xFF]), case.as_bytes())
            }
            Kind::Struct => {
                let obj = struct_of(v);
                let (name, fields) = current_program(|prog| {
                    let shape = &prog.shapes[obj.shape as usize];
                    (shape.name.clone().unwrap_or_default(), shape.fields.clone())
                });
                let mut h = fnv1a(tagged(8), name.as_bytes());
                h = fnv1a(h, &(fields.len() as u64).to_le_bytes());
                for (field, item) in fields.iter().zip(obj.fields().iter()) {
                    h = fnv1a(h, field.as_bytes());
                    h = fnv1a(h, &reference_mix(*item).to_le_bytes());
                }
                h
            }
            other => panic!("reference_mix: no {other:?} here"),
        }
    }

    fn reference_hash(v: Value) -> Value {
        make_small((reference_mix(v) & HASH_MASK) as i64)
    }

    #[test]
    fn int_and_char_hashes_are_their_to_string_bytes() {
        let mut vm = vm();
        for mag in decimal_samples() {
            for neg in [false, true] {
                let big = if neg { -BigInt::from(mag) } else { BigInt::from(mag) };
                let v = rooted!(vm, vm.new_big(big.clone()));
                assert_eq!(rt_hash(&mut *vm, v), reference_hash(v), "hash({big})");
                // Beyond 128 bits: num-bigint's own text of the borrowed value.
                let wide = rooted!(vm, vm.new_big(big.clone() * BigInt::from(u128::MAX) + 7));
                assert_eq!(rt_hash(&mut *vm, wide), reference_hash(wide), "hash({big} * (2^128-1) + 7)");
            }
        }
        for n in [0, -1, 7, SMALL_MIN, SMALL_MAX, (1 << 61) - 1, 1 << 61, -(1 << 61)] {
            assert_eq!(rt_hash(&mut *vm, small(n)), reference_hash(small(n)), "hash({n})");
        }
        for cp in [0u32, 0x61, 0x7F, 0x80, 0x7FF, 0x800, 0xFFFF, 0x1F642, 0x10FFFF] {
            assert_eq!(rt_hash(&mut *vm, make_char(cp)), reference_hash(make_char(cp)), "hash(char {cp})");
        }
        // core/hashing.tcl's values of 7, i64::MIN (a BigInt here) and 2^80
        // (tests/native-hashing.test's hash-parity-kinds-1 compares many
        // more with interp).
        assert_eq!(rt_hash(&mut *vm, small(7)), small(590693963425087288));
        let min = rooted!(vm, vm.new_big(BigInt::from(i64::MIN)));
        assert_eq!(rt_hash(&mut *vm, min), small(707785774613091011));
        let two80 = rooted!(vm, vm.new_big(BigInt::from(1u128 << 80)));
        assert_eq!(rt_hash(&mut *vm, two80), small(999613055982882793));
    }

    // -----------------------------------------------------------------------
    // The table hash (HASHABLE-AND-KEYED-HASH.md). `cargo test --lib
    // table_hash` runs these.

    /// The key 00 01 .. 0f of the SipHash papers' vectors.
    const VECTOR_KEY: (u64, u64) = (0x0706050403020100, 0x0f0e0d0c0b0a0908);

    fn sip<const C: usize, const D: usize>(key: (u64, u64), chunks: &[&[u8]]) -> u64 {
        let mut s = Sip::<C, D>::new(key.0, key.1);
        for c in chunks {
            s.write(c);
        }
        s.finish()
    }

    #[test]
    fn table_hash_sip_matches_published_vectors() {
        // SipHash-2-4 (the paper's appendix; the reference vectors.h) and
        // SipHash-1-3 (Rust's core tests, test_siphash_1_3).
        let msg: Vec<u8> = (0..64).collect();
        assert_eq!(sip::<2, 4>(VECTOR_KEY, &[&msg[..15]]), 0xa129ca6149be45e5);
        assert_eq!(sip::<2, 4>(VECTOR_KEY, &[&[]]), 0x726fdb47dd0e0e31);
        assert_eq!(sip::<2, 4>(VECTOR_KEY, &[&msg[..8]]), 0x93f5f5799a932462);
        assert_eq!(sip::<1, 3>(VECTOR_KEY, &[&[]]), 0xabac0158050fc4dc);
        assert_eq!(sip::<1, 3>(VECTOR_KEY, &[&msg[..1]]), 0xc9f49bf37d57ca93);
        // audit/hashable/tools/oracle.py's SipHash-1-3, an independent
        // implementation, at every boundary of the block structure.
        for (n, want) in [(7, 0xd3927d989bb11140u64), (8, 0x369095118d299a8e), (15, 0xd320d86d2a519956), (16, 0xcc4fdd1a7d908b66), (63, 0x9d199062b7bbb3a8)] {
            assert_eq!(sip::<1, 3>(VECTOR_KEY, &[&msg[..n]]), want, "SipHash-1-3 of {n} bytes");
        }
    }

    #[test]
    #[allow(deprecated)]
    fn table_hash_sip_streams_like_std_siphasher() {
        // std's SipHasher is SipHash-2-4: the same permutation and padding
        // with other round counts, over any split of the same bytes.
        use std::hash::Hasher;
        let mut seed = 0x2545f4914f6cdd1du64;
        let mut next = || {
            seed ^= seed << 13;
            seed ^= seed >> 7;
            seed ^= seed << 17;
            seed
        };
        for len in 0..80usize {
            let key = (next(), next());
            let msg: Vec<u8> = (0..len).map(|_| next() as u8).collect();
            let mut std = std::hash::SipHasher::new_with_keys(key.0, key.1);
            std.write(&msg);
            let want = std.finish();
            let cut1 = (next() as usize) % (len + 1);
            let cut2 = cut1 + (next() as usize) % (len - cut1 + 1);
            assert_eq!(sip::<2, 4>(key, &[&msg]), want, "len {len}");
            assert_eq!(sip::<2, 4>(key, &[&msg[..cut1], &msg[cut1..cut2], &msg[cut2..]]), want, "len {len} split");
            assert_eq!(sip::<1, 3>(key, &[&msg[..cut1], &msg[cut1..]]), sip::<1, 3>(key, &[&msg]), "len {len} split 1-3");
        }
    }

    #[test]
    fn table_hash_of_values_matches_the_oracle() {
        use crate::runtime::vm::{EnumInfo, ShapeInfo};
        let mut vm = Vm::new(
            std::rc::Rc::new(ProgramInfo {
                functions: Vec::new(),
                natives: Vec::new(),
                shapes: vec![ShapeInfo { name: Some("P".into()), fields: vec!["x".into(), "y".into()], opaque: false, identity: None }],
                enums: vec![EnumInfo { name: "Color".to_string(), cases: vec!["Red".to_string(), "Green".to_string()] }],
                errors: Vec::new(),
            }),
            AllocMode::Summary,
        );
        // audit/hashable/tools/oracle.py under the vector key: 7;
        // P {x: -5, y: "héllo"}; [1, '🙂', Color::Green]; {1, 2, 3}.
        let s = rooted!(vm, str_val(&mut vm, "h\u{e9}llo"));
        let p = rooted!(vm, vm.new_struct(0, vec![small(-5), s]));
        let list = rooted!(vm, vm.new_list(vec![small(1), make_char(0x1F642), make_enum(0, 1)]));
        let set = rooted!(vm, vm.new_set(vec![small(1), small(2), small(3)]));
        let reordered = rooted!(vm, vm.new_set(vec![small(3), small(1), small(2)]));
        assert_eq!(table_hash_with_key(&mut *vm, small(7), VECTOR_KEY), small(1659226329979122286));
        assert_eq!(table_hash_with_key(&mut *vm, p, VECTOR_KEY), small(2049144106076300702));
        assert_eq!(table_hash_with_key(&mut *vm, list, VECTOR_KEY), small(900147083491920494));
        assert_eq!(table_hash_with_key(&mut *vm, set, VECTOR_KEY), small(1805504437171615301));
        // Equal values, different constructions: one hash.
        assert_eq!(table_hash_with_key(&mut *vm, reordered, VECTOR_KEY), small(1805504437171615301));
        // A value with no hash is refused, as the public hash refuses it.
        let array = rooted!(vm, vm.new_mutarray(1));
        assert_eq!(table_hash_with_key(&mut *vm, array, VECTOR_KEY), NO_VALUE);
        assert!(vm.error.take().is_some());
    }

    #[test]
    fn table_hash_reads_the_value_not_its_public_hash() {
        // Two Ints with one 64-bit FNV state (audit/hashable/tools/
        // collide.rs): equal public hashes, nested too, so any function of
        // the public hash and a key collides on them; the table hash does
        // not.
        use num_bigint::BigInt;
        let mut vm = vm();
        let a = rooted!(vm, vm.new_big(BigInt::from(17384044247497657079u64)));
        let b = rooted!(vm, vm.new_big(BigInt::from(13834495523901255922u64)));
        assert_eq!(rt_hash(&mut *vm, a), rt_hash(&mut *vm, b));
        let la = rooted!(vm, vm.new_list(vec![a]));
        let lb = rooted!(vm, vm.new_list(vec![b]));
        assert_eq!(rt_hash(&mut *vm, la), rt_hash(&mut *vm, lb));
        assert_ne!(table_hash_with_key(&mut *vm, a, VECTOR_KEY), table_hash_with_key(&mut *vm, b, VECTOR_KEY));
        assert_ne!(table_hash_with_key(&mut *vm, la, VECTOR_KEY), table_hash_with_key(&mut *vm, lb, VECTOR_KEY));
    }

    #[test]
    fn table_hash_process_key_is_drawn_once() {
        // The production path: one key per process, drawn on first use and
        // never redrawn, so repeated table hashes of one value agree; a key
        // can no longer be fixed once one is in use.
        let mut vm = vm();
        let k = table_hash_key();
        assert_eq!(table_hash_key(), k);
        let first = rt_table_hash(&mut *vm, small(42));
        for _ in 0..100 {
            assert_eq!(rt_table_hash(&mut *vm, small(42)), first);
        }
        assert!(set_table_hash_key(1, 2).is_err());
        // Two draws (two processes' keys) come from the system's source:
        // equal only by a 2^-128 chance.
        assert_ne!(draw_table_hash_key(), draw_table_hash_key());
    }

    #[test]
    fn table_hash_allocates_nothing() {
        // As the public hash (RO-1): Ints up to 128 bits, code points,
        // Strings, structs and nested structs walk without a heap object;
        // the result is a small Int.
        use num_bigint::BigInt;
        let mut vm = vm_with_shapes(&[(Some("P"), &["x", "y"]), (Some("Q"), &["p", "name"])]);
        let s = rooted!(vm, str_val(&mut vm, "session-key-0042"));
        let big = rooted!(vm, vm.new_big(BigInt::from(1u128 << 100)));
        let p = rooted!(vm, vm.new_struct(0, vec![small(1), small(2)]));
        let q = rooted!(vm, vm.new_struct(1, vec![p, s]));
        let before = vm.metrics.total_allocations();
        for v in [small(7), big, make_char(0x1F642), s, p, q] {
            rt_table_hash(&mut *vm, v);
            rt_hash(&mut *vm, v);
        }
        assert_eq!(vm.metrics.total_allocations(), before);
    }

    #[test]
    fn nested_struct_hashes_borrow_their_shapes() {
        use crate::runtime::vm::{EnumInfo, ShapeInfo};
        // shape 0: P {x, y}; 1: Q {a, b, c}; 2: anonymous {p, q, e}.
        let shape = |name: Option<&str>, fields: &[&str]| ShapeInfo {
            name: name.map(String::from),
            fields: fields.iter().map(|f| f.to_string()).collect(),
            opaque: false,
            identity: None,
        };
        let mut vm = Vm::new(
            std::rc::Rc::new(ProgramInfo {
                functions: Vec::new(),
                natives: Vec::new(),
                shapes: vec![shape(Some("P"), &["x", "y"]), shape(Some("m::Q"), &["a", "b", "c"]), shape(None, &["p", "q", "e"])],
                enums: vec![EnumInfo { name: "Color".to_string(), cases: vec!["Red".to_string(), "Green".to_string()] }],
                errors: Vec::new(),
            }),
            AllocMode::Summary,
        );
        let s = rooted!(vm, str_val(&mut vm, "h\u{e9}llo \u{1F642}"));
        let p = rooted!(vm, vm.new_struct(0, vec![small(-5), small(SMALL_MAX)]));
        let list = rooted!(vm, vm.new_list(vec![p, make_char(0x1F642), make_enum(0, 1)]));
        let q = rooted!(vm, vm.new_struct(1, vec![p, list, s]));
        let anon = rooted!(vm, vm.new_struct(2, vec![p, q, make_enum(0, 0)]));
        for v in [p, q, anon, list] {
            assert_eq!(rt_hash(&mut *vm, v), reference_hash(v));
        }
        // A failing field's sub-hash leaves the borrow unwound, the next
        // hash borrows again.
        let array = rooted!(vm, vm.new_mutarray(1));
        let bad = rooted!(vm, vm.new_struct(0, vec![small(1), array]));
        assert_eq!(rt_hash(&mut *vm, bad), NO_VALUE);
        assert!(vm.error.take().is_some());
        assert_eq!(rt_hash(&mut *vm, anon), reference_hash(anon));
    }

    #[test]
    fn an_opaque_struct_shows_its_nominal_type_only() {
        // OPAQUE-STRUCTS.md: user-facing text never dumps a private
        // representation (alone or nested); the host value stays complete.
        use crate::runtime::show::{show, tcl_value};
        use crate::runtime::vm::ShapeInfo;
        let mut vm = Vm::new(
            std::rc::Rc::new(ProgramInfo {
                functions: Vec::new(),
                natives: Vec::new(),
                shapes: vec![
                    ShapeInfo { name: Some("token::Token".into()), fields: vec!["secret".into()], opaque: true, identity: None },
                    ShapeInfo { name: Some("Holder".into()), fields: vec!["token".into()], opaque: false, identity: None },
                ],
                enums: Vec::new(),
                errors: Vec::new(),
            }),
            AllocMode::Summary,
        );
        let token = rooted!(vm, vm.new_struct(0, vec![small(1234)]));
        let holder = rooted!(vm, vm.new_struct(1, vec![token]));
        assert_eq!(show(token), "<opaque token::Token>");
        assert_eq!(show(holder), "Holder {token: <opaque token::Token>}");
        assert_eq!(tcl_value(token).unwrap(), "struct {token::Token secret} {{int 1234}}");
    }

    #[test]
    fn struct_show_names_fields_in_shape_order() {
        use crate::runtime::show::{show, tcl_value};
        let mut vm = vm_with_shapes(&[(None, &["age", "name"]), (Some("geo::Point"), &["y", "x"]), (None, &[])]);
        let name = rooted!(vm, str_val(&mut vm, "Grace"));
        let anon = rooted!(vm, vm.new_struct(0, vec![small(45), name]));
        let named = rooted!(vm, vm.new_struct(1, vec![small(2), small(1)]));
        let empty = rooted!(vm, vm.new_struct(2, vec![]));
        assert_eq!(show(anon), "{age: 45, name: \"Grace\"}");
        assert_eq!(show(named), "geo::Point {y: 2, x: 1}");
        assert_eq!(show(empty), "{}");
        assert_eq!(tcl_value(anon).unwrap(), "struct {{} age name} {{int 45} {str Grace}}");
        assert_eq!(tcl_value(named).unwrap(), "struct {geo::Point y x} {{int 2} {int 1}}");
        assert_eq!(tcl_value(empty).unwrap(), "struct {{}} {}");
    }

    #[test]
    fn a_string_and_a_character_show_the_same_escapes() {
        // core::value::show: the lexer's escape set, each kind in its own
        // quotes; a carriage return is never written raw.
        use crate::runtime::show::show;
        let mut vm = vm();
        for (c, shown) in [('\\', "\\\\"), ('\n', "\\n"), ('\r', "\\r"), ('\t', "\\t"), ('a', "a"), ('é', "é")] {
            let s = str_val(&mut vm, &c.to_string());
            assert_eq!(show(s), format!("\"{shown}\""));
            assert_eq!(show(make_char(c as u32)), format!("'{shown}'"));
        }
        let quotes = str_val(&mut vm, "\"'");
        assert_eq!(show(quotes), "\"\\\"'\"");
        assert_eq!(show(make_char('\'' as u32)), "'\\''");
        assert_eq!(show(make_char('"' as u32)), "'\"'");
    }

    #[test]
    fn struct_fields_are_traced_and_reclaimed() {
        use crate::runtime::metrics::GcReason;
        let mut vm = vm_with_shapes(&[(None, &["a", "b"])]);
        let kept = rooted!(vm, str_val(&mut vm, "kept"));
        let inner = rooted!(vm, vm.new_struct(0, vec![kept, small(1)]));
        let outer = vm.new_struct(0, vec![inner, small(2)]);
        // Only OUTER stays rooted: INNER and KEPT survive by being traced
        // through it. The garbage stays unrooted on purpose (under stress the
        // struct's allocation already reclaims the garbage String).
        vm.temp_roots.clear();
        vm.temp_roots.push(outer);
        let _garbage = str_val(&mut vm, "garbage");
        let _garbage_struct = vm.new_struct(0, vec![small(3), small(4)]);
        vm.collect_for_test(GcReason::Explicit);
        // The struct, its nested struct and the string reachable through both
        // survive; the unreachable string and struct are reclaimed.
        assert_eq!(vm.metrics.by_kind[KIND_STRUCT as usize].live_objects, 2);
        assert_eq!(vm.metrics.by_kind[KIND_STRUCT as usize].reclaimed_objects, 1);
        assert_eq!(vm.metrics.by_kind[KIND_STR as usize].live_objects, 1);
        assert_eq!(str_of(struct_of(struct_of(outer).fields()[0]).fields()[0]).as_str(), "kept");
        vm.temp_roots.clear();
    }

    fn str_val(vm: &mut Vm, s: &str) -> Value {
        vm.new_str(s)
    }

    fn small(n: i64) -> Value {
        make_small(n)
    }

    // -----------------------------------------------------------------------
    // decode_char_at / str_byte_len: 1/2/3/4-byte scalars, mixed widths.

    #[test]
    fn decode_char_at_ascii() {
        let mut vm = vm();
        let s = str_val(&mut vm, "hello");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).as_str(), "e");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(1));
    }

    #[test]
    fn decode_char_at_two_byte() {
        let mut vm = vm();
        // U+00E9 is 2 bytes in UTF-8.
        let s = str_val(&mut vm, "a\u{e9}b");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).as_str(), "\u{e9}");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(2));
    }

    #[test]
    fn decode_char_at_three_byte() {
        let mut vm = vm();
        // U+6771 is 3 bytes in UTF-8.
        let s = str_val(&mut vm, "a\u{6771}b");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).as_str(), "\u{6771}");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(3));
    }

    #[test]
    fn decode_char_at_four_byte() {
        let mut vm = vm();
        // U+1F600 (grinning face) is 4 bytes in UTF-8.
        let s = str_val(&mut vm, "a\u{1f600}b");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).as_str(), "\u{1f600}");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(4));
    }

    #[test]
    fn decode_char_at_mixed_width_sequence() {
        // A mixed-width sequence: verify each character decodes correctly by carrying
        // the byte offset forward exactly as native/lower.tcl's optimized
        // loop would (byte_i += strbytelen(decoded)), never seeking.
        let mut vm = vm();
        let text = "A\u{e9}\u{6771}\u{1f642}A";
        let s = rooted!(vm, str_val(&mut vm, text));
        let mut byte_offset = 0i64;
        let expected: Vec<char> = text.chars().collect();
        for want in expected {
            let c = rt_str_decode_char_at(&mut *vm, s, small(byte_offset));
            let got: Vec<char> = str_of(c).as_str().chars().collect();
            assert_eq!(got, vec![want]);
            let width = rt_str_byte_len(&mut *vm, c);
            byte_offset += small_of(width);
        }
        assert_eq!(byte_offset as usize, str_of(s).len_bytes());
    }

    // -----------------------------------------------------------------------
    // ShortString1 (SHORT-STRING.md): -1 is Empty, 0..=0x10FFFF the one
    // scalar; U+0000 is 0 and never Empty.

    #[test]
    fn short_round_trips_every_character_class() {
        let mut vm = vm();
        for text in ["", "a", "\u{0}", "\u{e9}", "\u{3bb}", "\u{732b}", "\u{1f600}", "\u{10ffff}", "\u{d7ff}", "\u{e000}"] {
            let s = str_val(&mut vm, text);
            let short = rt_str_to_short(&mut *vm, s);
            let back = rt_short_to_str(&mut *vm, short);
            assert_eq!(str_of(back).as_str(), text, "{text:?}");
            assert_eq!(str_of(back).chars, text.chars().count());
            assert_eq!(str_of(back).ascii, text.is_ascii());
        }
    }

    #[test]
    fn short_encoding_is_the_scalar_value_and_empty_is_minus_one() {
        let mut vm = vm();
        let enc = |vm: &mut Vm, text: &str| {
            let s = str_val(vm, text);
            rt_str_to_short(vm, s) as i64
        };
        assert_eq!(enc(&mut vm, ""), -1);
        assert_eq!(enc(&mut vm, "\u{0}"), 0, "NUL is a one-character String, not Empty");
        assert_eq!(enc(&mut vm, "A"), 65);
        assert_eq!(enc(&mut vm, "\u{3bb}"), 0x3bb);
        assert_eq!(enc(&mut vm, "\u{10ffff}"), 0x10ffff);
        // NUL materializes as a one-character String, -1 as the empty one.
        let nul = rt_short_to_str(&mut *vm, 0);
        assert_eq!((str_of(nul).chars, str_of(nul).len_bytes()), (1, 1));
        // No interned table: every materialization of a non-empty value is a
        // fresh String. The empty String is the one canonical static object
        // (STRING-ALLOCATION.md: not an interning table, one shared immutable
        // empty), so every Empty materialization is that same object.
        // (The first is rooted: freed, its address could be the second's.)
        let first = rooted!(vm, rt_short_to_str(&mut *vm, 97));
        assert_ne!(first, rt_short_to_str(&mut *vm, 97));
        assert_eq!(rt_short_to_str(&mut *vm, (-1i64) as u64), rt_short_to_str(&mut *vm, (-1i64) as u64));
        let empty = rt_short_to_str(&mut *vm, (-1i64) as u64);
        assert_eq!((str_of(empty).chars, str_of(empty).len_bytes()), (0, 0));
    }

    // -----------------------------------------------------------------------
    // Packed ASCII (tier A): byte i = 0x80 | c, 0 past the end.

    #[test]
    fn packed_ascii_layout_length_and_canonical_form() {
        assert_eq!(pack_ascii(b""), 0);
        assert_eq!(pack_ascii(b"a"), 0xE1);
        assert_eq!(pack_ascii(b"\0"), 0x80, "NUL is a present 0x80, never absent");
        assert_eq!(pack_ascii(b"ab"), 0xE2E1);
        assert_eq!(pack_ascii(b"abcdefgh"), 0xE8E7_E6E5_E4E3_E2E1);
        for (text, n) in [("", 0usize), ("a", 1), ("\0\0", 2), ("abc", 3), ("1234567", 7), ("12345678", 8)] {
            let w = pack_ascii(text.as_bytes());
            assert_eq!(ascii_word_len(w), n, "{text:?}");
            assert!(is_canonical_ascii_word(w), "{text:?}");
            let (bytes, len) = unpack_ascii(w);
            assert_eq!(&bytes[..len], text.as_bytes());
        }
        // Non-canonical words: a payload byte without its presence flag, or a
        // present byte after an absent one.
        assert!(!is_canonical_ascii_word(0x61));
        assert!(!is_canonical_ascii_word(0xE100));
        assert!(!is_canonical_ascii_word(0xE100_0000_0000_00E1), "a gap before a present byte");
        assert!(is_canonical_ascii_word(0));
    }

    #[test]
    fn packed_ascii_round_trips_through_strings() {
        let mut vm = vm();
        for text in ["", "a", "\0", "ab", "hello", "1234567", "12345678", "\u{7f}\u{0}A"] {
            let s = str_val(&mut vm, text);
            let w = rt_str_to_ascii(&mut *vm, s);
            let back = rt_ascii_to_str(&mut *vm, w);
            assert_eq!(str_of(back).as_str(), text, "{text:?}");
            assert_eq!(str_of(back).chars, text.chars().count());
            assert!(str_of(back).ascii);
        }
    }

    #[test]
    fn slice_short_matches_substring_for_widths_zero_and_one() {
        let mut vm = vm();
        for text in ["hello", "\u{e9}t\u{e9}", "a\u{3bb}\u{1f600}\u{732b}z"] {
            let s = rooted!(vm, str_val(&mut vm, text));
            let n = text.chars().count();
            for from in 0..=n {
                for to in from..=(from + 1).min(n) {
                    let short = rt_str_slice_short(&mut *vm, s, small(from as i64), small(to as i64));
                    let sub = rooted!(vm, rt_substr(&mut *vm, s, small(from as i64), small(to as i64)));
                    let back = rt_short_to_str(&mut *vm, short);
                    assert_eq!(str_of(back).as_str(), str_of(sub).as_str(), "{text:?}[{from}..{to}]");
                }
            }
        }
    }

    #[test]
    fn slice_short_counts_the_non_ascii_seek_like_substring() {
        let mut vm = vm();
        let s = str_val(&mut vm, &"\u{e9}".repeat(10));
        rt_str_slice_short(&mut *vm, s, small(3), small(4));
        assert_eq!(vm.metrics.utf8_seek_bytes, 6);
        let a = str_val(&mut vm, "plain ascii");
        let before = vm.metrics.utf8_seek_bytes;
        rt_str_slice_short(&mut *vm, a, small(3), small(4));
        assert_eq!(vm.metrics.utf8_seek_bytes, before);
    }

    // -----------------------------------------------------------------------
    // utf8SeekBytes: only the non-ASCII, seek-from-zero paths ever record it;
    // decode_char_at/str_byte_len never do (they act at an already-carried
    // position).

    #[test]
    fn substr_ascii_records_no_seek() {
        let mut vm = vm();
        let s = rooted!(vm, str_val(&mut vm, "hello world"));
        rt_substr(&mut *vm, s, small(2), small(5));
        assert_eq!(vm.metrics.utf8_seek_bytes, 0);
    }

    #[test]
    fn substr_non_ascii_records_seek_bytes_to_the_start_offset() {
        let mut vm = vm();
        // Every character is U+00E9 (2 bytes): character index 3 has byte offset
        // is exactly 6.
        let s = rooted!(vm, str_val(&mut vm, &"\u{e9}".repeat(10)));
        rt_substr(&mut *vm, s, small(3), small(4));
        assert_eq!(vm.metrics.utf8_seek_bytes, 6);
    }

    #[test]
    fn substr_non_ascii_seek_grows_with_start_index() {
        let mut vm = vm();
        let s = rooted!(vm, str_val(&mut vm, &"\u{e9}".repeat(50)));
        rt_substr(&mut *vm, s, small(1), small(2));
        let first = vm.metrics.utf8_seek_bytes;
        rt_substr(&mut *vm, s, small(40), small(41));
        let second = vm.metrics.utf8_seek_bytes - first;
        assert!(second > first, "seeking further into the String must walk more bytes ({first} then {second})");
    }

    #[test]
    fn decode_char_at_records_no_seek_regardless_of_offset() {
        let mut vm = vm();
        let s = str_val(&mut vm, &"\u{6771}".repeat(50));
        rt_str_decode_char_at(&mut *vm, s, small(90));
        assert_eq!(vm.metrics.utf8_seek_bytes, 0);
    }

    #[test]
    fn region_eq_non_ascii_records_seek_bytes() {
        let mut vm = vm();
        let base = rooted!(vm, str_val(&mut vm, &"\u{e9}".repeat(10)));
        let other = str_val(&mut vm, "\u{e9}");
        rt_str_region_check(&mut *vm, base, small(3), small(4));
        rt_str_region_eq(&mut *vm, base, small(3), small(4), other);
        assert_eq!(vm.metrics.utf8_seek_bytes, 6);
    }

    // -----------------------------------------------------------------------
    // rt_str_region_is_tcl_alpha/alnum: the non-materializing counterpart of
    // rt_is_tcl_alpha/rt_is_tcl_alnum (one_scalar's RANGE contract, the same
    // ASCII/non-ASCII seek split as rt_str_region_eq), never allocating.

    #[test]
    fn region_classify_matches_materializing_form_ascii_and_non_ascii() {
        let mut vm = vm();
        let base = str_val(&mut vm, "a1\u{e9}\u{6771}!");
        for (i, (alpha, alnum)) in [(true, true), (false, true), (true, true), (true, true), (false, false)]
            .into_iter()
            .enumerate()
        {
            let i = i as i64;
            assert_eq!(
                rt_str_region_is_tcl_alpha(&mut *vm, base, small(i), small(i + 1)),
                bool_value(alpha)
            );
            assert_eq!(
                rt_str_region_is_tcl_alnum(&mut *vm, base, small(i), small(i + 1)),
                bool_value(alnum)
            );
        }
    }

    #[test]
    fn region_classify_range_error_on_non_one_scalar_width() {
        let mut vm = vm();
        let base = str_val(&mut vm, "hello");
        assert_eq!(rt_str_region_is_tcl_alpha(&mut *vm, base, small(1), small(3)), NO_VALUE);
        assert_eq!(rt_str_region_is_tcl_alnum(&mut *vm, base, small(2), small(2)), NO_VALUE);
    }

    #[test]
    fn region_classify_non_ascii_records_seek_bytes() {
        let mut vm = vm();
        let base = str_val(&mut vm, &"\u{6771}".repeat(10));
        rt_str_region_is_tcl_alpha(&mut *vm, base, small(3), small(4));
        assert_eq!(vm.metrics.utf8_seek_bytes, 9);
    }

    #[test]
    fn region_classify_ascii_records_no_seek() {
        let mut vm = vm();
        let base = str_val(&mut vm, "hello");
        rt_str_region_is_tcl_alnum(&mut *vm, base, small(3), small(4));
        assert_eq!(vm.metrics.utf8_seek_bytes, 0);
    }

    // -----------------------------------------------------------------------
    // utf8_bytes (core/strings.tcl's encode_utf8): 1/2/3/4-byte scalars,
    // mixed widths, and the empty String -- the same width coverage as
    // decode_char_at above, since both walk the same UTF-8 encoding.

    fn utf8_bytes_of(vm: &mut Vm, v: Value) -> Vec<i64> {
        let r = rt_str_utf8_bytes(vm, v);
        list_of(r).items().iter().map(|&b| small_of(b)).collect()
    }

    #[test]
    fn utf8_bytes_empty() {
        let mut vm = vm();
        let s = str_val(&mut vm, "");
        assert_eq!(utf8_bytes_of(&mut vm, s), Vec::<i64>::new());
    }

    #[test]
    fn utf8_bytes_ascii() {
        let mut vm = vm();
        let s = str_val(&mut vm, "AB");
        assert_eq!(utf8_bytes_of(&mut vm, s), vec![65, 66]);
    }

    #[test]
    fn utf8_bytes_two_byte() {
        let mut vm = vm();
        let s = str_val(&mut vm, "\u{e9}");
        assert_eq!(utf8_bytes_of(&mut vm, s), vec![0xC3, 0xA9]);
    }

    #[test]
    fn utf8_bytes_three_byte() {
        let mut vm = vm();
        let s = str_val(&mut vm, "\u{6771}");
        assert_eq!(utf8_bytes_of(&mut vm, s), vec![0xE6, 0x9D, 0xB1]);
    }

    #[test]
    fn utf8_bytes_four_byte() {
        let mut vm = vm();
        let s = str_val(&mut vm, "\u{1f600}");
        assert_eq!(utf8_bytes_of(&mut vm, s), vec![0xF0, 0x9F, 0x98, 0x80]);
    }

    #[test]
    fn utf8_bytes_mixed_width_sequence() {
        let mut vm = vm();
        let s = str_val(&mut vm, "a\u{e9}\u{1f600}");
        assert_eq!(utf8_bytes_of(&mut vm, s), vec![97, 0xC3, 0xA9, 0xF0, 0x9F, 0x98, 0x80]);
    }

    // char_at (core/strings.tcl's charAt): the scalar at a character index
    // as a UnicodeChar immediate, ASCII and non-ASCII alike; only the
    // non-ASCII path seeks (utf8SeekBytes, the bytes before the character).
    fn char_at_all(vm: &mut Vm, s: Value, n: i64) -> Vec<u32> {
        (0..n)
            .map(|i| {
                let checked = rt_str_char_at(vm, s, small(i));
                let proven = rt_str_char_at_proven(vm, s, small(i));
                assert_eq!(checked, proven);
                assert!(is_char(checked));
                char_of(checked)
            })
            .collect()
    }

    #[test]
    fn char_at_ascii_reads_without_seeking() {
        let mut vm = vm();
        let s = str_val(&mut vm, "a%2F");
        assert_eq!(char_at_all(&mut vm, s, 4), vec![97, 37, 50, 70]);
        assert_eq!(vm.metrics.utf8_seek_bytes, 0);
    }

    #[test]
    fn char_at_mixed_width_scalars() {
        let mut vm = vm();
        let s = str_val(&mut vm, "a\u{e9}\u{4e16}\u{1f600}z");
        assert_eq!(char_at_all(&mut vm, s, 5), vec![97, 0xE9, 0x4E16, 0x1F600, 122]);
        // Each read seeks from byte 0 to its character (0 + 1 + 3 + 6 + 10
        // bytes), and char_at_all reads every character twice.
        assert_eq!(vm.metrics.utf8_seek_bytes, 40);
    }

    #[test]
    fn char_at_outside_the_string_is_index_not_found() {
        let mut vm = vm();
        let s = rooted!(vm, str_val(&mut vm, "\u{e9}"));
        let empty = rooted!(vm, str_val(&mut vm, ""));
        let big = rooted!(vm, vm.new_big(num_bigint::BigInt::from(1u8) << 80));
        for (text, index) in [(s, small(1)), (s, small(-1)), (s, big), (empty, small(0))] {
            assert_eq!(rt_str_char_at(&mut *vm, text, index), NO_VALUE);
            assert_eq!(vm.declared_error, crate::runtime::error::ERR_INDEX_NOT_FOUND);
            vm.error = None;
            vm.declared_error = 0;
        }
    }

    // append_char (core/strings.tcl's appendChar): S followed by the
    // character C, for every UTF-8 width of C after ASCII and non-ASCII
    // text (the empty String included), through the helper and through
    // apply_op (a str::append_char function value's dispatch).
    #[test]
    fn append_char_every_width() {
        let mut vm = vm();
        for (text, c, expect) in [
            ("ab", '\n' as u32, "ab\n"),
            ("", '\n' as u32, "\n"),
            ("a", 0xE9, "a\u{e9}"),
            ("\u{e9}", 0x4E16, "\u{e9}\u{4e16}"),
            ("x", 0x1F600, "x\u{1f600}"),
            ("\u{1f600}", '!' as u32, "\u{1f600}!"),
        ] {
            let s = rooted!(vm, str_val(&mut vm, text));
            let direct = rooted!(vm, rt_str_append_char(&mut *vm, s, make_char(c)));
            let applied = apply_op(&mut *vm, OpCode::StrAppendChar, &[s, make_char(c)]);
            for r in [direct, applied] {
                assert_eq!(heap_kind(r), KIND_STR);
                assert_eq!(str_of(r).as_str(), expect);
                assert_eq!(str_of(r).chars, expect.chars().count());
                assert_eq!(str_of(r).ascii, expect.is_ascii());
            }
            assert_eq!(str_of(s).as_str(), text);
            vm.temp_roots.clear();
        }
    }

    #[test]
    fn append_char_allocates_and_may_fail_like_concat() {
        assert!(op_may_allocate(OpCode::StrAppendChar));
        assert!(op_may_error(OpCode::StrAppendChar));
        assert_eq!(OpCode::StrAppendChar.arity(), Some(2));
    }

    // -----------------------------------------------------------------------
    // argv() (core/process.tcl, ARGV.md): rt_argv validates the raw snapshot
    // as UTF-8 only when called, all or nothing, with every String rooted
    // while the vector materializes.

    fn argv_strings(list: Value) -> Vec<String> {
        list_of(list).items().iter().map(|&s| str_of(s).as_str().to_string()).collect()
    }

    fn raw(args: &[&[u8]]) -> Vec<Vec<u8>> {
        args.iter().map(|a| a.to_vec()).collect()
    }

    #[test]
    fn argv_default_is_the_synthetic_runner_not_the_process() {
        let mut vm = vm();
        let r = rt_argv(&mut *vm);
        assert_eq!(argv_strings(r), vec!["botlish-runner".to_string()]);
    }

    #[test]
    fn argv_valid_vector_round_trips_exactly() {
        let mut vm = vm();
        // NFC and NFD spellings of "e acute" stay distinct (no normalization);
        // an empty argument and a 4-byte scalar survive.
        vm.set_argv(raw(&["./prog".as_bytes(), "\u{e9}".as_bytes(), "e\u{301}".as_bytes(), b"", "\u{1f600}\u{20ac}".as_bytes()]));
        let r = rt_argv(&mut *vm);
        assert_eq!(argv_strings(r), vec!["./prog", "\u{e9}", "e\u{301}", "", "\u{1f600}\u{20ac}"]);
        // Each element is an ordinary String: character counts are scalars.
        assert_eq!(str_of(list_of(r).items()[4]).chars, 2);
        assert!(vm.error.is_none());
        assert_eq!(vm.declared_error, 0);
    }

    /// A Windows argument (runtime/aot.rs's `wtf8_from_utf16`): valid UTF-16
    /// -- ASCII, a BMP scalar, a surrogate pair, the empty argument, spaces
    /// and quotes, which are content once the command line is split -- is
    /// exactly its UTF-8, so `argv()` reads it as on Linux.
    #[test]
    fn argv_windows_utf16_is_its_utf8() {
        use crate::runtime::aot::wtf8_from_utf16;
        for text in ["C:\\dir with space\\prog.exe", "", "a \"quoted\" b\\", "\u{e9}e\u{301}", "\u{1f600}\u{20ac}", "\u{ffff}\u{10ffff}"] {
            assert_eq!(wtf8_from_utf16(text.encode_utf16()), text.as_bytes(), "{text:?}");
        }
        let mut vm = vm();
        vm.set_argv(["prog", "", "\u{1f600}"].iter().map(|t| wtf8_from_utf16(t.encode_utf16())).collect());
        assert_eq!(argv_strings(rt_argv(&mut *vm)), vec!["prog", "", "\u{1f600}"]);
    }

    /// An unpaired surrogate -- UTF-16 a Windows command line may hold, no
    /// Unicode scalar -- is its code unit's three-byte form (never U+FFFD or
    /// a dropped unit), lossless and distinct for every unit, which strict
    /// UTF-8 rejects: `argv()` is the declared error, as for invalid UTF-8
    /// on Linux. A surrogate pair split by another unit is two unpaired
    /// surrogates.
    #[test]
    fn argv_windows_unpaired_surrogate_is_the_declared_error() {
        use crate::runtime::aot::wtf8_from_utf16;
        assert_eq!(wtf8_from_utf16([0xD800]), b"\xED\xA0\x80");
        assert_eq!(wtf8_from_utf16([0xDFFF]), b"\xED\xBF\xBF");
        assert_eq!(wtf8_from_utf16([0x61, 0xDC00, 0x62]), b"a\xED\xB0\x80b");
        assert_eq!(wtf8_from_utf16([0xD83D, 0x20, 0xDE00]), b"\xED\xA0\xBD \xED\xB8\x80");
        assert_eq!(wtf8_from_utf16([0xD83D, 0xDE00]), "\u{1f600}".as_bytes());
        let lone: Vec<Vec<u8>> = (0xD800..=0xDFFFu16).map(|u| wtf8_from_utf16([u])).collect();
        assert!(lone.iter().all(|b| std::str::from_utf8(b).is_err()));
        assert_eq!(lone.iter().collect::<std::collections::HashSet<_>>().len(), lone.len());
        let mut vm = vm();
        vm.set_argv(vec![b"prog".to_vec(), wtf8_from_utf16([0x61, 0xD800])]);
        assert_eq!(rt_argv(&mut *vm), NO_VALUE);
        assert_eq!(vm.declared_error, crate::runtime::error::ERR_INVALID_ARGUMENT_ENCODING);
    }

    /// The driver's inverse of the Windows encoding, for a linked run's
    /// command line (WINDOWS-X86-64-MILESTONE-2.md): every unit sequence --
    /// lone surrogates of both kinds, pairs, a pair split by another unit,
    /// every boundary scalar -- decodes back from its WTF-8 exactly, and
    /// bytes that are no WTF-8 of anything decode to nothing: stray and
    /// missing continuations, overlong forms, values past U+10FFFF, 0xFF,
    /// and a pair written as two three-byte surrogates (which would encode
    /// back to the scalar's four bytes).
    #[test]
    fn argv_windows_wtf8_decodes_back_to_its_units() {
        use crate::runtime::aot::{utf16_from_wtf8, wtf8_from_utf16};
        let cases: Vec<Vec<u16>> = vec![
            vec![],
            "C:\\dir with space\\prog.exe".encode_utf16().collect(),
            "\u{e9}e\u{301}\u{1f600}\u{ffff}\u{10ffff}\u{7f}\u{80}\u{7ff}\u{800}".encode_utf16().collect(),
            vec![0xD800],
            vec![0xDFFF],
            vec![0x61, 0xDC00, 0x62],
            vec![0xD83D, 0x20, 0xDE00],
            vec![0xD83D, 0xDE00],
            vec![0xDE00, 0xD83D],
            vec![0xD800, 0xD800, 0xDC00],
            vec![0],
        ];
        for units in &cases {
            assert_eq!(utf16_from_wtf8(&wtf8_from_utf16(units.iter().copied())).as_ref(), Some(units), "{units:x?}");
        }
        // Every single unit, and a pseudo-random sample of short sequences.
        for unit in 0..=0xFFFFu16 {
            assert_eq!(utf16_from_wtf8(&wtf8_from_utf16([unit])), Some(vec![unit]), "{unit:#x}");
        }
        let mut state = 0x2545_f491_4f6c_dd1du64;
        for _ in 0..20000 {
            let units: Vec<u16> = (0..(state % 7))
                .map(|_| {
                    state ^= state << 13;
                    state ^= state >> 7;
                    state ^= state << 17;
                    [0x41, 0x7FF, 0x800, 0xD800, 0xDBFF, 0xDC00, 0xDFFF, 0xFFFF, (state >> 16) as u16][(state % 9) as usize]
                })
                .collect();
            state = state.wrapping_mul(6364136223846793005).wrapping_add(1);
            assert_eq!(utf16_from_wtf8(&wtf8_from_utf16(units.iter().copied())), Some(units.clone()), "{units:x?}");
        }
        for bad in [
            &b"\x80"[..],
            b"a\xC3",
            b"\xC3\x28",
            b"\xC0\xAF",
            b"\xE0\x80\xAF",
            b"\xF0\x80\x80\xAF",
            b"\xF4\x90\x80\x80",
            b"\xFF",
            b"\xED\xA0\xBD\xED\xB8\x80",
        ] {
            assert_eq!(utf16_from_wtf8(bad), None, "{bad:x?}");
        }
        // A lone trail before a lone lead is no pair: both stay.
        assert_eq!(utf16_from_wtf8(b"\xED\xB8\x80\xED\xA0\xBD"), Some(vec![0xDE00, 0xD83D]));
    }

    #[test]
    fn argv_zero_arguments_is_the_empty_list() {
        let mut vm = vm();
        vm.set_argv(Vec::new());
        let r = rt_argv(&mut *vm);
        assert_eq!(list_of(r).items().len(), 0);
    }

    #[test]
    fn argv_invalid_utf8_is_the_declared_error_and_never_partial() {
        let mut vm = vm();
        // Valid, valid, invalid (0xFF), valid: the whole call fails.
        vm.set_argv(raw(&[b"./prog", b"ok", b"a\xffb", b"later"]));
        let before = vm.metrics.by_kind[KIND_LIST as usize].live_objects;
        let r = rt_argv(&mut *vm);
        assert_eq!(r, NO_VALUE);
        assert_eq!(vm.declared_error, crate::runtime::error::ERR_INVALID_ARGUMENT_ENCODING);
        assert_eq!(
            vm.error.as_ref().map(|e| (e.error_code(), e.message())),
            Some((vec!["CORE", "SEMANTIC", "UNCAUGHT-ERROR"], "uncaught propagated error: <error InvalidArgumentEncoding>".to_string()))
        );
        // No List (and no String of the valid prefix) was ever built.
        assert_eq!(vm.metrics.by_kind[KIND_LIST as usize].live_objects, before);
        assert_eq!(vm.metrics.by_kind[KIND_STR as usize].live_objects, 0);
        // A handled failure leaves the snapshot as it was: the next call
        // fails the same way.
        vm.error = None;
        vm.declared_error = 0;
        assert_eq!(rt_argv(&mut *vm), NO_VALUE);
        assert_eq!(vm.declared_error, crate::runtime::error::ERR_INVALID_ARGUMENT_ENCODING);
    }

    // -----------------------------------------------------------------------
    // list::at / mutable_array::at (STDLIB-NAMESPACES.md): an index that
    // designates no element -- past the end, negative, a BigInt -- is the
    // builtin declared error IndexNotFound, never RANGE.

    #[test]
    fn indexed_reads_fail_with_index_not_found() {
        let mut vm = vm();
        let list = rooted!(vm, vm.new_list(vec![small(10), small(20)]));
        assert_eq!(small_of(rt_list_get(&mut *vm, list, small(1))), 20);
        assert_eq!(vm.declared_error, 0);
        let arr = rooted!(vm, rt_mutarray_allocate(&mut *vm, small(2)));
        rt_mutarray_set(&mut *vm, arr, small(0), small(7));
        assert_eq!(small_of(rt_mutarray_get(&mut *vm, arr, small(0))), 7);
        let big = rooted!(vm, vm.new_big(num_bigint::BigInt::from(1u8) << 80));
        for index in [small(2), small(-1), big] {
            let reads: [(extern "C" fn(*mut Vm, Value, Value) -> Value, Value); 2] =
                [(rt_list_get, list), (rt_mutarray_get, arr)];
            for (read, container) in reads {
                assert_eq!(read(&mut *vm, container, index), NO_VALUE);
                assert_eq!(vm.declared_error, crate::runtime::error::ERR_INDEX_NOT_FOUND);
                assert_eq!(
                    vm.error.as_ref().map(|e| (e.error_code(), e.message())),
                    Some((vec!["CORE", "SEMANTIC", "UNCAUGHT-ERROR"], "uncaught propagated error: <error IndexNotFound>".to_string()))
                );
                vm.error = None;
                vm.declared_error = 0;
            }
        }
    }

    // list#with_length (LIST-CARDINALITY-REFINEMENTS.md): the List itself
    // (the same object, never a copy) when it has exactly the length, else
    // the builtin declared error LengthMismatch -- also for a negative or
    // BigInt length, which no List has.

    #[test]
    fn list_with_length_returns_its_operand_or_length_mismatch() {
        let mut vm = vm();
        let list = rooted!(vm, vm.new_list(vec![small(10), small(20), small(30)]));
        let lists = vm.metrics.by_kind[KIND_LIST as usize].allocations;
        assert_eq!(rt_list_with_length(&mut *vm, list, small(3)), list);
        assert_eq!(vm.declared_error, 0);
        assert_eq!(vm.metrics.by_kind[KIND_LIST as usize].allocations, lists);
        let big = rooted!(vm, vm.new_big(num_bigint::BigInt::from(1u8) << 80));
        for n in [small(2), small(4), small(0), small(-3), big] {
            assert_eq!(rt_list_with_length(&mut *vm, list, n), NO_VALUE);
            assert_eq!(vm.declared_error, crate::runtime::error::ERR_LENGTH_MISMATCH);
            assert_eq!(
                vm.error.as_ref().map(|e| (e.error_code(), e.message())),
                Some((vec!["CORE", "SEMANTIC", "UNCAUGHT-ERROR"], "uncaught propagated error: <error LengthMismatch>".to_string()))
            );
            vm.error = None;
            vm.declared_error = 0;
        }
        let empty = rooted!(vm, vm.new_list(vec![]));
        assert_eq!(rt_list_with_length(&mut *vm, empty, small(0)), empty);
    }

    // The *proven helpers (hir/completions.tcl's bounds proof, PROOF-FACT-
    // CENSUS.md G1) are the checked helpers minus the checks: on every valid
    // index or slice they must produce exactly what the checked one does.

    #[test]
    fn proven_helpers_agree_with_checked_ones_on_valid_bounds() {
        let mut vm = vm();
        let list = rooted!(vm, vm.new_list(vec![small(10), small(20), small(30)]));
        for i in 0..3 {
            assert_eq!(rt_list_get_proven(&mut *vm, list, small(i)), rt_list_get(&mut *vm, list, small(i)));
        }
        let arr = rooted!(vm, rt_mutarray_allocate(&mut *vm, small(4)));
        for i in 0..4 {
            assert_eq!(rt_mutarray_set_proven(&mut *vm, arr, small(i), small(i * 5)), UNIT);
            assert_eq!(small_of(rt_mutarray_get_proven(&mut *vm, arr, small(i))), i * 5);
            assert_eq!(rt_mutarray_get_proven(&mut *vm, arr, small(i)), rt_mutarray_get(&mut *vm, arr, small(i)));
        }
        for text in ["hello", "\u{e9}t\u{e9}", "a\u{3bb}\u{1f600}\u{732b}z", ""] {
            let s = rooted!(vm, str_val(&mut vm, text));
            let n = text.chars().count() as i64;
            for from in 0..=n {
                for to in from..=n {
                    let checked = rooted!(vm, rt_substr(&mut *vm, s, small(from), small(to)));
                    let proven = rt_substr_proven(&mut *vm, s, small(from), small(to));
                    assert_eq!(str_of(proven).as_str(), str_of(checked).as_str(), "{text:?}[{from}..{to}]");
                    assert_eq!(str_of(proven).chars, str_of(checked).chars);
                }
            }
        }
        // copy: every valid (dst start, src start, count) on overlapping
        // and distinct arrays, compared against the checked helper.
        for dst_start in 0..=4 {
            for src_start in 0..=4 {
                for count in 0..=(4 - dst_start.max(src_start)) {
                    let a = rooted!(vm, rt_mutarray_allocate(&mut *vm, small(4)));
                    let b = rooted!(vm, rt_mutarray_allocate(&mut *vm, small(4)));
                    for i in 0..4 {
                        rt_mutarray_set(&mut *vm, a, small(i), small(i));
                        rt_mutarray_set(&mut *vm, b, small(i), small(i));
                    }
                    assert_eq!(rt_mutarray_copy(&mut *vm, a, small(dst_start), a, small(src_start), small(count)), UNIT);
                    assert_eq!(rt_mutarray_copy_proven(&mut *vm, b, small(dst_start), b, small(src_start), small(count)), UNIT);
                    for i in 0..4 {
                        assert_eq!(rt_mutarray_get(&mut *vm, a, small(i)), rt_mutarray_get(&mut *vm, b, small(i)));
                    }
                }
            }
        }
        for count in 0..=4 {
            let checked = rooted!(vm, rt_mutarray_freeze(&mut *vm, arr, small(count)));
            let proven = rt_mutarray_freeze_proven(&mut *vm, arr, small(count));
            assert_eq!(list_of(proven).items(), list_of(checked).items());
        }
        assert_eq!(vm.declared_error, 0);
    }

    // The slice rule (check_slice, core::native::checkSlice): START against
    // 0..N first, then END against START..N; below is LowerUnderrun, above
    // is UpperOverrun. Writes through an index are IndexNotFound.

    #[test]
    fn error_payload_travels_in_the_payload_slots_and_is_cleared_by_the_handler() {
        // ERROR-PAYLOADS.md: `faildeclared` with payload registers copies the
        // field values into the Vm's payload slots (a GC root: nothing else
        // holds them while the error propagates), `declaredpayload K` reads
        // field K, and the handler's clear empties the slots; a payload-free
        // failure or a builtin error never leaves a stale payload behind.
        let mut vm = vm();
        vm.heap.set_stress_for_test(true);
        let text = rooted!(vm, vm.new_str("detail"));
        let big = rooted!(vm, vm.new_big(num_bigint::BigInt::from(7u8) << 70u32));
        let name = rooted!(vm, vm.new_str("E"));
        let fields = [text, big];
        assert_eq!(rt_fail_declared_payload(&mut *vm, 4, name, 0, 2, fields.as_ptr()), NO_VALUE);
        while vm.temp_roots.len() > 0 {
            vm.temp_roots.pop();
        }
        for _ in 0..3 {
            vm.collect_for_test(crate::runtime::metrics::GcReason::Explicit);
        }
        assert_eq!(vm.declared_error, 4);
        assert_eq!(str_of(rt_declared_payload(&mut *vm, 0)).as_str(), "detail");
        assert_eq!(super::super::show::show(rt_declared_payload(&mut *vm, 1)), (num_bigint::BigInt::from(7u8) << 70u32).to_string());
        assert_eq!(rt_clear_declared_error(&mut *vm), 0);
        assert!(vm.declared_payload.is_empty() && vm.declared_error == 0 && vm.error.is_none());
        let name = rooted!(vm, vm.new_str("E"));
        let fields = [small(1)];
        rt_fail_declared_payload(&mut *vm, 4, name, 0, 1, fields.as_ptr());
        rt_fail_declared(&mut *vm, 5, name);
        assert!(vm.declared_payload.is_empty());
        rt_fail_declared_payload(&mut *vm, 4, name, 0, 1, fields.as_ptr());
        index_not_found(&mut *vm);
        assert!(vm.declared_payload.is_empty());
        assert_eq!(pending(&mut vm), crate::runtime::error::ERR_INDEX_NOT_FOUND);
    }

    fn pending(vm: &mut Vm) -> u32 {
        let id = vm.declared_error;
        vm.error = None;
        vm.declared_error = 0;
        id
    }

    #[test]
    fn slices_fail_with_lower_underrun_or_upper_overrun() {
        use crate::runtime::error::{ERR_LOWER_UNDERRUN as LO, ERR_UPPER_OVERRUN as UP};
        let mut vm = vm();
        let s = rooted!(vm, str_val(&mut vm, "abc"));
        let neg_big = rooted!(vm, vm.new_big(-(num_bigint::BigInt::from(1u8) << 80usize)));
        let pos_big = rooted!(vm, vm.new_big(num_bigint::BigInt::from(1u8) << 80usize));
        let cases = [
            (small(-1), small(2), LO),  // start below 0
            (small(4), small(4), UP),   // start above the length
            (small(2), small(1), LO),   // end below its start (inverted)
            (small(1), small(4), UP),   // end above the length
            (small(-1), small(9), LO),  // the start is checked first
            (small(4), small(1), UP),   // ... and decides alone
            (neg_big, small(1), LO),
            (small(0), pos_big, UP),
            (small(1), neg_big, LO),
        ];
        for (start, end, id) in cases {
            assert_eq!(rt_substr(&mut *vm, s, start, end), NO_VALUE);
            assert_eq!(pending(&mut vm), id);
            assert_eq!(rt_str_region_check(&mut *vm, s, start, end), NO_VALUE);
            assert_eq!(pending(&mut vm), id);
        }
        assert_eq!(str_of(rt_substr(&mut *vm, s, small(3), small(3))).as_str(), "");
        assert_eq!(rt_str_region_check(&mut *vm, s, small(0), small(3)), UNIT);

        let arr = rooted!(vm, rt_mutarray_allocate(&mut *vm, small(2)));
        let big = rooted!(vm, rt_mutarray_allocate(&mut *vm, small(5)));
        assert_eq!(rt_mutarray_set(&mut *vm, arr, small(2), small(1)), NO_VALUE);
        assert_eq!(pending(&mut vm), crate::runtime::error::ERR_INDEX_NOT_FOUND);
        for (count, id) in [(small(-1), LO), (small(3), UP)] {
            assert_eq!(rt_mutarray_freeze(&mut *vm, arr, count), NO_VALUE);
            assert_eq!(pending(&mut vm), id);
        }
        // copy: the destination slice first, then the source slice.
        for (ds, ss, count, id) in [
            (small(-1), small(9), small(1), LO), // destination start, before the source's overrun
            (small(0), small(9), small(1), UP),  // source start above its length
            (small(0), small(0), small(-1), LO), // a negative count: end below start
            (small(1), small(0), small(2), UP),  // destination end above 2
            (small(0), small(4), small(2), UP),  // source end above 5
        ] {
            assert_eq!(rt_mutarray_copy(&mut *vm, arr, ds, big, ss, count), NO_VALUE);
            assert_eq!(pending(&mut vm), id);
        }
        assert_eq!(rt_mutarray_copy(&mut *vm, arr, small(0), big, small(3), small(2)), UNIT);
    }

    #[test]
    fn argv_rejects_exactly_what_utf8_rejects() {
        // Overlong, surrogate, past U+10FFFF, truncated, stray continuation
        // and lone lead bytes are invalid; the largest scalar is valid.
        let invalid: &[&[u8]] = &[
            b"\xc0\x80", b"\xe0\x80\x80", b"\xf0\x80\x80\x80", b"\xed\xa0\x80", b"\xed\xbf\xbf",
            b"\xf4\x90\x80\x80", b"\xf5\x80\x80\x80", b"\xe2\x82", b"\xf0\x9f\x98", b"\x80", b"\xff", b"\xc1\xbf",
        ];
        for bad in invalid {
            let mut vm = vm();
            vm.set_argv(raw(&[b"p", bad]));
            assert_eq!(rt_argv(&mut *vm), NO_VALUE, "{bad:?}");
        }
        let mut vm = vm();
        vm.set_argv(raw(&[b"p", b"\xf4\x8f\xbf\xbf", b"\xef\xbf\xbf"]));
        let r = rt_argv(&mut *vm);
        assert_eq!(argv_strings(r), vec!["p", "\u{10ffff}", "\u{ffff}"]);
    }

    #[test]
    fn argv_survives_a_collection_at_every_allocation() {
        let mut vm = vm();
        vm.heap.set_stress_for_test(true);
        let args: Vec<Vec<u8>> = (0..64).map(|i| format!("argument-{i}-\u{e9}\u{1f600}").into_bytes()).collect();
        vm.set_argv(args.clone());
        let a = rt_argv(&mut *vm);
        assert_ne!(a, NO_VALUE);
        vm.temp_roots.push(a);
        // Allocate a lot in between, then ask again: both Lists are intact.
        for i in 0..200 {
            let _ = vm.new_str(&format!("garbage-{i}"));
        }
        let b = rt_argv(&mut *vm);
        assert_ne!(b, NO_VALUE);
        assert_eq!(vm.temp_roots.len(), 1, "rt_argv must release its temporary roots");
        let want: Vec<String> = args.iter().map(|a| String::from_utf8(a.clone()).unwrap()).collect();
        assert_eq!(argv_strings(a), want);
        assert_eq!(argv_strings(b), want);
        vm.temp_roots.clear();
    }

    #[test]
    fn argv_failure_under_stress_leaves_no_roots_or_objects() {
        let mut vm = vm();
        vm.heap.set_stress_for_test(true);
        vm.set_argv(raw(&[b"a", b"b", b"\xfe"]));
        assert_eq!(rt_argv(&mut *vm), NO_VALUE);
        assert!(vm.temp_roots.is_empty());
        vm.collect_for_test(crate::runtime::metrics::GcReason::Explicit);
        assert_eq!(vm.metrics.by_kind[KIND_STR as usize].live_objects, 0);
    }

    /// rt_int_shl/rt_int_shr over every small/BigInt operand shape, checked
    /// against num_bigint's exact shift (the reference interpreter's
    /// arbitrary-precision semantics): in particular, a small Int shifted
    /// past 2^62/2^63 must promote, never wrap (`2 << 62` is 2^63, not
    /// i64::MIN).
    #[test]
    fn int_shifts_are_exact_across_word_boundaries() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let values: Vec<BigInt> = [
            0i64, 1, 2, 3, -1, -2, -3, -20, 5, 1000000,
            SMALL_MAX, SMALL_MIN, SMALL_MAX - 1, SMALL_MIN + 1,
            1 << 61, -(1 << 61), i64::MAX, i64::MIN,
        ]
        .iter()
        .map(|&n| BigInt::from(n))
        .chain([BigInt::from(1) << 100usize, -(BigInt::from(3) << 90usize)])
        .collect();
        for x in &values {
            for k in [0u32, 1, 2, 60, 61, 62, 63, 64, 65, 100, 200] {
                let a = rooted!(vm, match i64::try_from(x) {
                    Ok(n) => vm.new_int(n),
                    Err(_) => vm.new_big(x.clone()),
                });
                let b = rooted!(vm, vm.new_int(k as i64));
                let shl = rt_int_shl(p, a, b);
                assert_eq!(int_to_big(shl), x << (k as usize), "{x} << {k}");
                let shr = rt_int_shr(p, a, b);
                assert_eq!(int_to_big(shr), x >> (k as usize), "{x} >> {k}");
                vm.temp_roots.clear();
            }
        }
    }

    #[test]
    fn shl_i64_exact_rejects_dropped_bits() {
        assert_eq!(shl_i64_exact(2, 62), None);
        assert_eq!(shl_i64_exact(1, 62), Some(1 << 62));
        assert_eq!(shl_i64_exact(1, 63), None);
        assert_eq!(shl_i64_exact(-1, 63), Some(i64::MIN));
        assert_eq!(shl_i64_exact(-2, 62), Some(i64::MIN));
        assert_eq!(shl_i64_exact(-3, 62), None);
        assert_eq!(shl_i64_exact(-20, 62), None);
        assert_eq!(shl_i64_exact(0, 64), Some(0));
        assert_eq!(shl_i64_exact(0, 100), Some(0));
        assert_eq!(shl_i64_exact(1, 64), None);
        assert_eq!(shl_i64_exact(-1, 64), None);
    }

    // -----------------------------------------------------------------------
    // Fixed binary layouts (BINARY-LAYOUT.md): binload / binstore / byteszeroed

    /// The encoding word of WIDTH bytes, SIGNED, little-endian.
    fn enc(width: i64, signed: bool) -> Value {
        make_small(width + if signed { 16 } else { 0 })
    }

    #[test]
    fn bin_store_then_load_every_encoding_at_its_extremes() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let cases: &[(i64, bool, BigInt, Vec<u8>)] = &[
            (1, false, BigInt::from(255), vec![0xff]),
            (1, true, BigInt::from(-128), vec![0x80]),
            (1, true, BigInt::from(127), vec![0x7f]),
            (2, false, BigInt::from(0x1234), vec![0x34, 0x12]),
            (2, true, BigInt::from(-2), vec![0xfe, 0xff]),
            (4, false, BigInt::from(4_000_000_000u64), vec![0x00, 0x28, 0x6b, 0xee]),
            (4, true, BigInt::from(i32::MIN), vec![0x00, 0x00, 0x00, 0x80]),
            (8, false, BigInt::from(u64::MAX), vec![0xff; 8]),
            (8, true, BigInt::from(i64::MIN), vec![0, 0, 0, 0, 0, 0, 0, 0x80]),
            (8, true, BigInt::from(-1), vec![0xff; 8]),
            (8, false, BigInt::from(0), vec![0; 8]),
        ];
        for (width, signed, n, bytes) in cases {
            // Rooted (as compiled code's stack maps root operands) before the
            // next allocation, which may collect (always, under
            // BOTLISH_NATIVE_GC_STRESS=1).
            vm.temp_roots.clear();
            let s = rt_bytes_zeroed(p, make_small(12));
            vm.temp_roots.push(s);
            assert_eq!(bytes_of(s), &[0u8; 12], "byteszeroed is all zero");
            let v = vm.new_big(n.clone());
            vm.temp_roots.push(v);
            assert_eq!(rt_bin_store(p, s, make_small(3), enc(*width, *signed), v), UNIT);
            let mut expected = vec![0u8; 12];
            expected[3..3 + *width as usize].copy_from_slice(bytes);
            assert_eq!(bytes_of(s), &expected[..], "store {n} as {width}/{signed}");
            let back = rt_bin_load(p, s, make_small(3), enc(*width, *signed));
            assert_eq!(int_to_big(back), *n, "load {width}/{signed}");
        }
    }

    /// Raw C floating encodings (RAW-C-FLOAT-FFI-MILESTONE-1.md): 128 marks
    /// one, of 4 or 8 bytes, never signed and never also a finite float's
    /// (64). A load makes a raw value of exactly the bytes' bits -- a
    /// signaling NaN, a negative NaN payload, negative zero, a subnormal --
    /// and a store writes exactly a raw value's bits; a raw value of the
    /// other format, or a Float64, is refused (TYPE), never converted.
    #[test]
    fn raw_c_float_codec_keeps_every_bit() {
        assert!(matches!(bin_encoding(make_small(128 + 4)), Some(BinEncoding { width: 4, raw: Some(CFloatFormat::Binary32), float: None, .. })));
        assert!(matches!(bin_encoding(make_small(128 + 8)), Some(BinEncoding { width: 8, raw: Some(CFloatFormat::Binary64), float: None, .. })));
        assert!(bin_encoding(make_small(128 + 16 + 4)).is_none(), "a raw encoding is never signed");
        assert!(bin_encoding(make_small(128 + 64 + 8)).is_none(), "raw and finite at once is malformed");
        assert!(bin_encoding(make_small(128 + 2)).is_none(), "no 2-byte C floating format");
        assert!(bin_encoding(make_small(256 + 4)).is_none());
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let cases: &[(usize, u64)] = &[
            (4, 0x7fa0_0001), (4, 0xffc0_0001), (4, 0x8000_0000), (4, 0x0000_0001), (4, 0x7f80_0000), (4, 0xff80_0000),
            (8, 0x7ff4_0000_0000_0000), (8, 0xfff8_0000_0000_0001), (8, 0x8000_0000_0000_0000), (8, 1), (8, u64::MAX),
        ];
        for &(width, bits) in cases {
            vm.temp_roots.clear();
            let encoding = bin_encoding(make_small(128 + width as i64)).unwrap();
            let bytes = bits.to_le_bytes();
            let v = bin_decode(p, &bytes[..width], encoding);
            vm.temp_roots.push(v);
            assert_eq!(raw_bits(v), bits, "load {width}/{bits:#x}");
            assert_eq!(heap_kind(v), if width == 4 { KIND_RAWF32 } else { KIND_RAWF64 });
            let back = bin_encode(p, v, encoding, "test").map_err(|_| ()).unwrap();
            assert_eq!(&back[..width], &bytes[..width], "store {width}/{bits:#x}");
            let other = bin_encoding(make_small(128 + if width == 4 { 8 } else { 4 })).unwrap();
            assert!(bin_encode(p, v, other, "test").is_err(), "a raw value of the other format is refused");
            assert!(vm.error.take().is_some());
        }
        let x = vm.new_float(FloatType::Float64, 1.5f64.to_bits());
        vm.temp_roots.push(x);
        assert!(bin_encode(p, x, bin_encoding(make_small(128 + 8)).unwrap(), "test").is_err(), "a Float64 is no raw value");
        assert!(vm.error.take().is_some());
    }

    /// The raw helpers (codegen's and the generic ops'): bits in and out
    /// exactly, admission and narrowing by the finite types' one rule.
    #[test]
    fn raw_c_float_helpers() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let f = rooted!(vm, rt_raw_from_bits(p, 0, make_small(0x7fa0_0001)));
        assert_eq!(raw_bits(f), 0x7fa0_0001);
        assert_eq!(int_small(rt_raw_bits(p, 0, f)), Some(0x7fa0_0001));
        let big = rooted!(vm, vm.new_big(BigInt::from(0xfff8_0000_0000_0001u64)));
        let d = rooted!(vm, rt_raw_from_bits(p, 1, big));
        assert_eq!(raw_bits(d), 0xfff8_0000_0000_0001);
        let back = rooted!(vm, rt_raw_bits(p, 1, d));
        assert_eq!(int_to_big(back), BigInt::from(0xfff8_0000_0000_0001u64));
        // Out of the format's range: RANGE, never truncated.
        assert_eq!(rt_raw_from_bits(p, 0, make_small(1 << 32)), NO_VALUE);
        assert!(vm.error.take().is_some());
        assert_eq!(rt_raw_from_bits(p, 0, make_small(-1)), NO_VALUE);
        assert!(vm.error.take().is_some());
        // Admission: NaN and the infinities fail, -0 is 0.0, a binary32
        // widens exactly.
        assert_eq!(rt_raw_admit(p, 0, f), NO_VALUE);
        assert!(vm.error.take().is_some());
        let nz = rooted!(vm, rt_raw_new(p, 1, 0x8000_0000_0000_0000));
        let zero = rooted!(vm, rt_raw_admit(p, 1, nz));
        assert_eq!(float64_of(zero).to_bits(), 0);
        let sub = rooted!(vm, rt_raw_new(p, 0, 1));
        let wide = rooted!(vm, rt_raw_admit(p, 0, sub));
        assert_eq!(float64_of(wide), f32::from_bits(1) as f64);
        // Narrowing: binary32 rounded (a tie to even), an overflow fails;
        // binary64 exact.
        let tie = rooted!(vm, vm.new_float(FloatType::Float64, (1.0f64 + 2f64.powi(-24)).to_bits()));
        let narrowed = rooted!(vm, rt_raw_narrow(p, 0, tie));
        assert_eq!(raw_bits(narrowed), 1.0f32.to_bits() as u64);
        let huge = rooted!(vm, vm.new_float(FloatType::Float64, 1e39f64.to_bits()));
        assert_eq!(rt_raw_narrow(p, 0, huge), NO_VALUE);
        assert!(vm.error.take().is_some());
        let exact = rooted!(vm, rt_raw_narrow(p, 1, huge));
        assert_eq!(raw_bits(exact), 1e39f64.to_bits());
        // A raw value of the other format, or no raw value: TYPE.
        assert_eq!(rt_raw_bits(p, 1, f), NO_VALUE);
        assert!(vm.error.take().is_some());
        assert_eq!(rt_raw_admit(p, 0, make_small(3)), NO_VALUE);
        assert!(vm.error.take().is_some());
    }

    #[test]
    fn bin_store_never_truncates_and_ops_check_their_bounds() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        // Every storage is rooted before the next allocation (BigInts below),
        // which may collect (always, under BOTLISH_NATIVE_GC_STRESS=1).
        let s = rt_bytes_zeroed(p, make_small(4));
        vm.temp_roots.push(s);
        // 256 is not an unsigned byte, -1 not an unsigned value at all, 128 not
        // a signed byte: RANGE, nothing written.
        for (value, signed) in [(256, false), (-1, false), (128, true)] {
            assert_eq!(rt_bin_store(p, s, make_small(0), enc(1, signed), make_small(value)), NO_VALUE);
            assert!(vm.error.take().is_some());
        }
        assert_eq!(bytes_of(s), &[0u8; 4]);
        // BigInts just outside the 8-byte encodings, and far beyond i128.
        let wide = rt_bytes_zeroed(p, make_small(8));
        vm.temp_roots.push(wide);
        for (n, signed) in [
            (BigInt::from(u64::MAX) + 1, false),
            (BigInt::from(i64::MIN) - 1, true),
            (BigInt::from(i64::MAX) + 1, true),
            (BigInt::from(1u8) << 200usize, false),
            (-(BigInt::from(1u8) << 200usize), true),
        ] {
            let v = vm.new_big(n.clone());
            assert_eq!(rt_bin_store(p, wide, make_small(0), enc(8, signed), v), NO_VALUE, "store {n}");
            assert!(vm.error.take().is_some());
        }
        assert_eq!(bytes_of(wide), &[0u8; 8]);
        // Four bytes at offset 1 of a 4-byte storage, and a malformed encoding.
        assert_eq!(rt_bin_load(p, s, make_small(1), enc(4, false)), NO_VALUE);
        assert!(vm.error.take().is_some());
        assert_eq!(rt_bin_load(p, s, make_small(0), make_small(3)), NO_VALUE);
        assert!(vm.error.take().is_some());
        assert_eq!(rt_bin_load(p, s, make_small(0), enc(4, false)), make_small(0));
    }

    // -----------------------------------------------------------------------
    // Owned byte storage (ABI-BYTES.md)

    fn bytes_list(vm: &mut Vm, values: &[i64]) -> Value {
        let items: Vec<Value> = values.iter().map(|n| vm.new_int(*n)).collect();
        vm.new_list(items)
    }

    #[test]
    fn bytes_join_copies_every_part_in_order() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = rooted!(vm, vm.new_bytes(&[1, 0, 255]));
        let b = rooted!(vm, vm.new_bytes(&[]));
        let c = rooted!(vm, vm.new_bytes(&[7]));
        let parts = rooted!(vm, vm.new_list(vec![a, b, c, a]));
        let j = rt_bytes_join(p, parts);
        assert_eq!(heap_kind(j), KIND_BYTES);
        assert_eq!(bytes_of(j), &[1, 0, 255, 7, 1, 0, 255]);
        // Nothing, or nothing but empty parts: the shared empty storage.
        let none = rooted!(vm, vm.new_list(vec![]));
        assert_eq!(bytes_of(rt_bytes_join(p, none)), &[] as &[u8]);
        let empties = rooted!(vm, vm.new_list(vec![b, b]));
        assert_eq!(bytes_of(rt_bytes_join(p, empties)), &[] as &[u8]);
        // A part that is no storage: TYPE, never a partial result.
        let bad = rooted!(vm, vm.new_list(vec![a, make_small(3)]));
        assert_eq!(rt_bytes_join(p, bad), NO_VALUE);
        assert!(vm.error.take().is_some());
    }

    #[test]
    fn bytes_slice_copies_the_range_and_refuses_an_invalid_one() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let v = rooted!(vm, vm.new_bytes(&[1, 0, 255, 7, 9]));
        let s = rt_bytes_slice(p, v, make_small(1), make_small(4));
        assert_eq!(heap_kind(s), KIND_BYTES);
        assert_eq!(bytes_of(s), &[0, 255, 7]);
        assert_eq!(bytes_of(rt_bytes_slice(p, v, make_small(0), make_small(5))), &[1, 0, 255, 7, 9]);
        assert_eq!(bytes_of(rt_bytes_slice(p, v, make_small(5), make_small(5))), &[] as &[u8]);
        // std::str::substring's rule: a start below 0 or an end below the
        // start is LowerUnderrun, an end past the count UpperOverrun.
        for (start, end, error) in [(-1, 2, crate::runtime::error::ERR_LOWER_UNDERRUN), (3, 2, crate::runtime::error::ERR_LOWER_UNDERRUN), (0, 6, crate::runtime::error::ERR_UPPER_OVERRUN)] {
            assert_eq!(rt_bytes_slice(p, v, make_small(start), make_small(end)), NO_VALUE, "{start} {end}");
            assert_eq!(vm.declared_error, error, "{start} {end}");
            assert!(vm.error.take().is_some());
        }
    }

    #[test]
    fn bytes_decode_utf8_is_strict() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let good = rooted!(vm, vm.new_bytes("héllo \u{1F4A9}\0".as_bytes()));
        let s = rt_bytes_decode_utf8(p, good);
        assert_eq!(str_of(s).as_str(), "héllo \u{1F4A9}\0");
        // An encoded surrogate (WTF-8), an overlong NUL, a value above
        // U+10FFFF, a stray continuation and a truncated sequence: the
        // declared InvalidUtf8, never a replacement character.
        for bad in [&[0xed, 0xa0, 0x80][..], &[0xc0, 0x80], &[0xf4, 0x90, 0x80, 0x80], &[0x80], &[0xe2, 0x82]] {
            let v = rooted!(vm, vm.new_bytes(bad));
            assert_eq!(rt_bytes_decode_utf8(p, v), NO_VALUE, "{bad:?}");
            assert_eq!(vm.declared_error, crate::runtime::error::ERR_INVALID_UTF8, "{bad:?}");
            assert!(vm.error.take().is_some());
        }
    }

    #[test]
    fn bytes_from_list_copies_every_byte_exactly_including_nul_and_high_bytes() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        // Rooted, as compiled code roots a call's operands for the whole
        // call (codegen::roots's `call_argument_is_rooted_during_the_call`):
        // under BOTLISH_NATIVE_GC_STRESS=1 the allocation inside
        // rt_bytes_from_list collects first, and an unrooted L is swept
        // there. Its block is then free for the result to take (Apple's
        // allocator handed it back at once; glibc's did not), and
        // `assert_ne!(b, l)` compared the result with a dead object.
        let l = rooted!(vm, bytes_list(&mut vm, &[0x41, 0, 0x42, 0xff, 0x80, 0, 0]));
        let b = rt_bytes_from_list(p, l);
        assert_eq!(heap_kind(b), KIND_BYTES);
        assert_eq!(bytes_of(b), &[0x41, 0, 0x42, 0xff, 0x80, 0, 0]);
        assert_eq!(rt_bytes_len(p, b), make_small(7));
        // Eager copy: the storage is its own allocation, not the List. Both
        // are live, so they cannot share an address whatever the allocator.
        assert_ne!(b, l);
    }

    /// The same call with the collection made certain and observed, not left
    /// to the environment or to the allocator: a collection is forced before
    /// every allocation, so one runs inside the call (the collector's cycle
    /// count rises); the rooted List survives it (no List is reclaimed); and
    /// once the caller lets go of the List, the next collection reclaims it
    /// while the storage, now the rooted one, stays exact.
    #[test]
    fn bytes_from_list_survives_its_own_collection_and_the_list_is_reclaimed_after_it() {
        let mut vm = vm();
        vm.heap.set_stress_for_test(true);
        let p: *mut Vm = &mut *vm;
        let expected = [0x41u8, 0, 0x42, 0xff, 0x80, 0, 0];
        let l = rooted!(vm, bytes_list(&mut vm, &expected.map(i64::from)));
        let cycles = vm.metrics.gc_cycles.len();
        let lists_swept = vm.metrics.by_kind[KIND_LIST as usize].reclaimed_objects;
        let b = rt_bytes_from_list(p, l);
        assert!(vm.metrics.gc_cycles.len() > cycles, "no collection ran inside the call");
        assert_eq!(vm.metrics.by_kind[KIND_LIST as usize].reclaimed_objects, lists_swept, "a rooted List was swept");
        assert_eq!(bytes_of(b), &expected);
        // The caller is done with the List: unroot it, root the storage.
        vm.temp_roots.pop();
        vm.temp_roots.push(b);
        vm.collect_for_test(crate::runtime::metrics::GcReason::Explicit);
        assert_eq!(vm.metrics.by_kind[KIND_LIST as usize].reclaimed_objects, lists_swept + 1, "the dead List was not reclaimed");
        assert_eq!(bytes_of(b), &expected);
    }

    #[test]
    fn the_empty_storage_is_the_shared_static_one_and_allocates_nothing() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let empty = bytes_list(&mut vm, &[]);
        let before = vm.metrics.total_allocations();
        let a = rt_bytes_from_list(p, empty);
        let b = vm.new_bytes(&[]);
        assert_eq!(vm.metrics.total_allocations(), before);
        assert_eq!(a, b);
        assert_eq!(unsafe { (*(a as *const Header)).is_static }, 1);
        assert_eq!(rt_bytes_len(p, a), make_small(0));
        assert!(bytes_of(a).is_empty());
    }

    #[test]
    fn a_non_byte_element_is_a_type_error_never_a_truncation() {
        for bad in [256i64, -1, 1 << 40] {
            let mut vm = vm();
            let p: *mut Vm = &mut *vm;
            let l = bytes_list(&mut vm, &[1, bad, 3]);
            assert_eq!(rt_bytes_from_list(p, l), NO_VALUE);
            let message = vm.error.take().unwrap().message();
            assert!(message.contains("element 1 must be a byte"), "{message}");
            assert!(message.contains(&bad.to_string()), "{message}");
        }
        let mut strings = vm();
        let p: *mut Vm = &mut *strings;
        let text = rooted!(strings, strings.new_str("a"));
        let l = rooted!(strings, strings.new_list(vec![text]));
        assert_eq!(rt_bytes_from_list(p, l), NO_VALUE);
        assert!(strings.error.take().unwrap().message().contains("got \"a\""));
        // A BigInt (above the small range) is no byte either.
        let mut bigs = vm();
        let p: *mut Vm = &mut *bigs;
        let big = rooted!(bigs, bigs.new_big(num_bigint::BigInt::from(1u64 << 63) * 4));
        let l = rooted!(bigs, bigs.new_list(vec![big]));
        assert_eq!(rt_bytes_from_list(p, l), NO_VALUE);
    }

    #[test]
    fn length_and_address_refuse_a_value_that_is_not_a_storage() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let l = bytes_list(&mut vm, &[1, 2]);
        for helper in [rt_bytes_len as extern "C" fn(*mut Vm, Value) -> Value, rt_bytes_addr] {
            assert_eq!(helper(p, l), NO_VALUE);
            assert!(vm.error.take().unwrap().message().contains("expected bytestore"));
            assert_eq!(helper(p, make_small(5)), NO_VALUE);
            assert!(vm.error.take().is_some());
        }
    }

    #[test]
    fn the_payload_address_is_the_object_address_plus_sixteen_and_reads_back() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let l = bytes_list(&mut vm, &[7, 0, 9]);
        let b = rt_bytes_from_list(p, l);
        let address = rt_bytes_addr(p, b);
        assert!(is_small(address));
        let address = small_of(address) as u64;
        assert_eq!(address, b + 16);
        assert_eq!(address % 16, 0);
        let read = unsafe { std::slice::from_raw_parts(address as *const u8, 3) };
        assert_eq!(read, &[7, 0, 9]);
        // The empty storage's address is legal for a zero count (one past its header).
        let e = vm.new_bytes(&[]);
        assert_eq!(small_of(rt_bytes_addr(p, e)) as u64, e + 16);
    }

    #[test]
    fn storage_equality_is_by_bytes_never_identity() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = rooted!(vm, vm.new_bytes(&[1, 2, 3]));
        let b = rooted!(vm, vm.new_bytes(&[1, 2, 3]));
        let c = rooted!(vm, vm.new_bytes(&[1, 2, 4]));
        let d = rooted!(vm, vm.new_bytes(&[1, 2]));
        let static_copy = BytesObj::new_static(&[1, 2, 3]) as Value;
        assert_ne!(a, b);
        assert_eq!(rt_value_eq(p, a, b), TRUE);
        assert_eq!(rt_value_eq(p, a, static_copy), TRUE);
        assert_eq!(rt_value_eq(p, a, c), FALSE);
        assert_eq!(rt_value_eq(p, a, d), FALSE);
        assert_eq!(rt_value_eq(p, vm.new_bytes(&[]), vm.new_bytes(&[0])), FALSE);
        // Never equal to a List or String of the same numbers/characters.
        let l = bytes_list(&mut vm, &[1, 2, 3]);
        assert_eq!(rt_value_eq(p, a, l), FALSE);
        unsafe { super::super::heap::free_object(static_copy as *mut Header) };
    }

    #[test]
    fn storage_hash_agrees_with_equality_and_with_the_documented_encoding() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = rooted!(vm, vm.new_bytes(&[1, 2, 3]));
        let b = rooted!(vm, vm.new_bytes(&[1, 2, 3]));
        let c = rooted!(vm, vm.new_bytes(&[1, 2, 4]));
        let zero = rooted!(vm, vm.new_bytes(&[0]));
        let two_zeros = rooted!(vm, vm.new_bytes(&[0, 0]));
        assert_eq!(rt_hash(p, a), rt_hash(p, b));
        assert_ne!(rt_hash(p, a), rt_hash(p, c));
        assert_ne!(rt_hash(p, zero), rt_hash(p, two_zeros));
        // kind tag 9, the byte count as 8 little-endian bytes, then the bytes
        // (core/hashing.tcl's bytestore case).
        let mut h = fnv1a(FNV_OFFSET, &[9]);
        h = fnv1a(h, &3u64.to_le_bytes());
        h = fnv1a(h, &[1, 2, 3]);
        assert_eq!(rt_hash(p, a), make_small((h & HASH_MASK) as i64));
    }

    #[test]
    fn storage_renders_and_crosses_to_the_host_as_core_value_does() {
        use crate::runtime::show::{show, tcl_value};
        let mut vm = vm();
        let b = vm.new_bytes(&[0x41, 0, 0xff]);
        assert_eq!(show(b), "<bytes 3: 4100ff>");
        assert_eq!(tcl_value(b).unwrap(), "bytestore 4100ff");
        let e = vm.new_bytes(&[]);
        assert_eq!(show(e), "<bytes 0: >");
        assert_eq!(tcl_value(e).unwrap(), "bytestore {}");
    }

    #[test]
    fn an_unreferenced_storage_is_collected_and_a_rooted_one_survives() {
        use crate::runtime::metrics::GcReason;
        let mut vm = vm();
        // KEPT is rooted across the garbage's allocation (a collection
        // under stress); the explicit collection below roots only KEPT.
        let kept = rooted!(vm, vm.new_bytes(&[1; 100]));
        let _garbage = vm.new_bytes(&[2; 100]);
        vm.heap.collect(std::iter::once(kept), &mut vm.metrics, GcReason::Explicit, &crate::runtime::framemap::ProgramMap::new());
        assert_eq!(vm.metrics.by_kind[KIND_BYTES as usize].live_objects, 1);
        assert_eq!(vm.metrics.by_kind[KIND_BYTES as usize].reclaimed_objects, 1);
        // The payload holds no program value: the survivor is intact.
        assert_eq!(bytes_of(kept), &[1u8; 100][..]);
    }

    #[test]
    fn an_oversized_storage_is_a_range_error_before_any_allocation() {
        let mut vm = vm();
        let before = vm.metrics.total_allocations();
        let v = vm.new_bytes_with(MAX_COLLECTION_LENGTH + 1, |_| unreachable!("no payload is written"));
        assert_eq!(v, NO_VALUE);
        assert!(vm.error.take().unwrap().message().contains("cannot exceed"));
        assert_eq!(vm.metrics.total_allocations(), before);
    }

    // -----------------------------------------------------------------------
    // Writable byte storage, abi::bytes::MutableBytes (MUTABLE-BYTES.md)

    #[test]
    fn a_mutable_storage_is_zero_filled_fixed_length_and_one_block() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        for n in [0i64, 1, 7, 8, 9, 15, 16, 17, 31, 32, 33, 4096] {
            let m = rt_mbytes_new(p, small(n));
            assert_eq!(heap_kind(m), KIND_MUTBYTES);
            assert_eq!(rt_mbytes_len(p, m), make_small(n));
            assert!(mutbytes_of(m).iter().all(|b| *b == 0), "length {n} must be zero-filled");
            if n > 0 {
                // header + length + payload, the payload at +16 and 16-aligned.
                assert_eq!(small_of(rt_mbytes_addr(p, m)) as u64, m + 16);
                assert_eq!((m + 16) % 16, 0);
                assert_eq!(unsafe { super::super::heap::object_size(m as *mut Header) }, 16 + n as usize);
            }
        }
        // The empty one is the shared static; a non-empty one is never shared.
        let (e1, e2) = (rt_mbytes_new(p, small(0)), rt_mbytes_new(p, small(0)));
        assert_eq!(e1, e2);
        assert_eq!(unsafe { (*(e1 as *const Header)).is_static }, 1);
        // (The first is rooted: freed, its address could be the second's.)
        let first = rooted!(vm, rt_mbytes_new(p, small(4)));
        assert_ne!(first, rt_mbytes_new(p, small(4)));
    }

    #[test]
    fn a_mutable_length_outside_the_ceiling_is_a_range_error() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let big = vm.new_big(num_bigint::BigInt::from(1u8) << 70usize);
        for bad in [small(-1), big, make_small(MAX_COLLECTION_LENGTH as i64 + 1)] {
            let before = vm.metrics.total_allocations();
            assert_eq!(rt_mbytes_new(p, bad), NO_VALUE);
            assert!(vm.error.take().unwrap().message().contains("the length must be in 0.."));
            assert_eq!(vm.metrics.total_allocations(), before);
        }
        // A length the allocator cannot supply is reported, never an abort.
        assert_eq!(rt_mbytes_new(p, make_small(MAX_COLLECTION_LENGTH as i64)), NO_VALUE);
        assert!(vm.error.take().unwrap().message().contains("out of memory"));
    }

    #[test]
    fn set_updates_a_fresh_copy_and_never_writes_its_operand() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = rooted!(vm, vm.new_bytes(&[1, 2, 3, 4, 5]));
        let m = rooted!(vm, rt_mbytes_from(p, a));
        assert_eq!(mutbytes_of(m), &[1, 2, 3, 4, 5]);
        let n = rt_mbytes_set(p, m, small(2), small(0xff));
        assert_ne!(n, m, "an update is a new object");
        assert_eq!(mutbytes_of(n), &[1, 2, 0xff, 4, 5]);
        // The operand, and the immutable source it was copied from, are untouched.
        assert_eq!(mutbytes_of(m), &[1, 2, 3, 4, 5]);
        assert_eq!(bytes_of(a), &[1, 2, 3, 4, 5]);
        // Every index, and the last byte, on objects of several sizes.
        for len in [1usize, 2, 7, 8, 9, 16, 17, 33] {
            let src: Vec<u8> = (0..len as u8).collect();
            let base = rooted!(vm, vm.new_bytes(&src));
            let m = rooted!(vm, rt_mbytes_from(p, base));
            for i in 0..len {
                let n = rt_mbytes_set(p, m, small(i as i64), small(200));
                let mut want = src.clone();
                want[i] = 200;
                assert_eq!(mutbytes_of(n), &want[..]);
                assert_eq!(mutbytes_of(m), &src[..]);
            }
        }
    }

    #[test]
    fn set_refuses_a_bad_index_value_or_operand() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let m = rooted!(vm, rt_mbytes_new(p, small(3)));
        let empty = rooted!(vm, rt_mbytes_new(p, small(0)));
        let big = rooted!(vm, vm.new_big(num_bigint::BigInt::from(1u8) << 70usize));
        let s = rooted!(vm, vm.new_str("x"));
        for (target, index, value, kind) in [
            (m, small(3), small(1), "RANGE"),
            (m, small(-1), small(1), "RANGE"),
            (m, big, small(1), "RANGE"),
            (empty, small(0), small(1), "RANGE"),
            (m, small(0), small(256), "TYPE"),
            (m, small(0), small(-1), "TYPE"),
            (m, small(0), s, "TYPE"),
            (s, small(0), small(1), "TYPE"),
        ] {
            assert_eq!(rt_mbytes_set(p, target, index, value), NO_VALUE);
            let e = vm.error.take().unwrap();
            assert_eq!(e.error_code()[1..], ["SEMANTIC", kind], "{}", e.message());
        }
        assert_eq!(mutbytes_of(m), &[0, 0, 0]);
    }

    #[test]
    fn clone_freeze_and_prefix_copy_and_the_kinds_never_mix() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = rooted!(vm, vm.new_bytes(&[9, 8, 7, 6]));
        let m = rooted!(vm, rt_mbytes_from(p, a));
        let c = rooted!(vm, rt_mbytes_clone(p, m));
        assert_ne!(c, m);
        assert_eq!(mutbytes_of(c), mutbytes_of(m));
        let f = rooted!(vm, rt_mbytes_freeze(p, m));
        assert_eq!(heap_kind(f), KIND_BYTES);
        assert_eq!(bytes_of(f), &[9, 8, 7, 6]);
        assert_ne!(f, a, "freeze is a snapshot copy, not the source storage");
        for (count, want) in [(0usize, &[][..]), (1, &[9][..]), (3, &[9, 8, 7][..]), (4, &[9, 8, 7, 6][..])] {
            let q = rt_mbytes_freeze_prefix(p, m, small(count as i64));
            assert_eq!(heap_kind(q), KIND_BYTES);
            assert_eq!(bytes_of(q), want);
        }
        assert_eq!(rt_mbytes_freeze_prefix(p, m, small(5)), NO_VALUE);
        assert!(vm.error.take().unwrap().message().contains("the count must be in 0..4"));
        assert_eq!(rt_mbytes_freeze_prefix(p, m, small(-1)), NO_VALUE);
        vm.error = None;
        // The two storage kinds are never accepted for one another.
        assert_eq!(rt_bytes_len(p, m), NO_VALUE);
        vm.error = None;
        assert_eq!(rt_bytes_addr(p, m), NO_VALUE);
        vm.error = None;
        for helper in [rt_mbytes_len as extern "C" fn(*mut Vm, Value) -> Value, rt_mbytes_addr, rt_mbytes_clone, rt_mbytes_freeze] {
            assert_eq!(helper(p, a), NO_VALUE, "a Bytes storage is not a MutableBytes");
            assert!(vm.error.take().unwrap().message().contains("expected mutbytes"));
            assert_eq!(helper(p, small(1)), NO_VALUE);
            vm.error = None;
        }
        assert_eq!(rt_mbytes_from(p, m), NO_VALUE, "mutable_from takes an immutable storage");
        vm.error = None;
    }

    #[test]
    fn the_writable_address_is_the_payload_and_the_kernel_can_write_through_it() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let m = rt_mbytes_new(p, small(8));
        let address = small_of(rt_mbytes_addr(p, m)) as u64;
        assert_eq!(address, m + 16);
        // A write through the raw address (what the read syscall does) is
        // visible in the storage's own payload: no copy sits in between.
        unsafe { std::ptr::copy_nonoverlapping([7u8, 6, 5].as_ptr(), address as *mut u8, 3) };
        assert_eq!(mutbytes_of(m), &[7, 6, 5, 0, 0, 0, 0, 0]);
        // The empty storage's address is a valid one-past address.
        let e = rt_mbytes_new(p, small(0));
        assert_eq!(small_of(rt_mbytes_addr(p, e)) as u64, e + 16);
    }

    #[test]
    fn mutable_equality_hash_and_rendering_are_by_contents_under_their_own_kind() {
        use crate::runtime::show::{show, tcl_value};
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let src = rooted!(vm, vm.new_bytes(&[1, 2, 3]));
        let a = rooted!(vm, rt_mbytes_from(p, src));
        let b = rooted!(vm, rt_mbytes_from(p, src));
        let c = rooted!(vm, rt_mbytes_set(p, a, small(0), small(9)));
        assert_ne!(a, b, "two storages, equal contents");
        assert_eq!(rt_value_eq(p, a, b), TRUE);
        assert_eq!(rt_value_eq(p, a, c), FALSE);
        assert_eq!(rt_value_eq(p, a, src), FALSE, "a MutableBytes storage is not a Bytes storage");
        assert_eq!(rt_hash(p, a), rt_hash(p, b));
        assert_ne!(rt_hash(p, a), rt_hash(p, c));
        assert_ne!(rt_hash(p, a), rt_hash(p, src), "its own kind tag (10), not the Bytes tag (9)");
        // kind tag 10, the byte count as 8 little-endian bytes, then the bytes
        // (core/hashing.tcl's `bytestore - mutbytes` case).
        let mut h = fnv1a(FNV_OFFSET, &[10]);
        h = fnv1a(h, &3u64.to_le_bytes());
        h = fnv1a(h, &[1, 2, 3]);
        assert_eq!(rt_hash(p, a), make_small((h & HASH_MASK) as i64));
        assert_eq!(show(a), "<mutbytes 3: 010203>");
        assert_eq!(tcl_value(a).unwrap(), "mutbytes 010203");
        let e = rt_mbytes_new(p, small(0));
        assert_eq!(show(e), "<mutbytes 0: >");
        assert_eq!(tcl_value(e).unwrap(), "mutbytes {}");
    }

    #[test]
    fn a_mutable_storage_is_collected_when_unreferenced_and_survives_when_rooted() {
        use crate::runtime::metrics::GcReason;
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        // KEPT is rooted across the garbage's allocation (a collection
        // under stress); the explicit collection below roots only KEPT.
        let kept = rooted!(vm, rt_mbytes_new(p, small(100)));
        unsafe { BytesObj::payload_mut(kept)[99] = 0x5a };
        let _garbage = rt_mbytes_new(p, small(100));
        vm.heap.collect(std::iter::once(kept), &mut vm.metrics, GcReason::Explicit, &crate::runtime::framemap::ProgramMap::new());
        assert_eq!(vm.metrics.by_kind[KIND_MUTBYTES as usize].live_objects, 1);
        assert_eq!(vm.metrics.by_kind[KIND_MUTBYTES as usize].reclaimed_objects, 1);
        assert_eq!(mutbytes_of(kept)[99], 0x5a);
    }

    #[test]
    fn mutable_operations_survive_a_collection_at_every_allocation() {
        let mut vm = vm();
        vm.heap.set_stress_for_test(true);
        let p: *mut Vm = &mut *vm;
        let src = vm.new_bytes(&[1, 2, 3, 4]);
        vm.temp_roots.push(src);
        let m = rt_mbytes_from(p, src);
        vm.temp_roots.push(m);
        let n = rt_mbytes_set(p, m, small(1), small(77));
        vm.temp_roots.push(n);
        let c = rt_mbytes_clone(p, n);
        vm.temp_roots.push(c);
        let f = rt_mbytes_freeze_prefix(p, c, small(3));
        assert_eq!(mutbytes_of(m), &[1, 2, 3, 4]);
        assert_eq!(mutbytes_of(n), &[1, 77, 3, 4]);
        assert_eq!(mutbytes_of(c), &[1, 77, 3, 4]);
        assert_eq!(bytes_of(f), &[1, 77, 3]);
        vm.temp_roots.clear();
    }

    // -----------------------------------------------------------------------
    // MutableArray as a value (MUTABLE-ARRAY.md): header over a copy-on-write
    // backing.

    /// A rooted array of the Ints XS.
    fn mutarray_of_ints(vm: &mut Vm, xs: &[i64]) -> Value {
        let list = rooted!(vm, vm.new_list(xs.iter().map(|&x| small(x)).collect()));
        rooted!(vm, rt_mutarray_from_list(vm, list))
    }

    fn mutarray_contents(arr: Value) -> Vec<i64> {
        array_elements(arr).map(small_of).collect()
    }

    #[test]
    fn mutarray_copy_shares_and_only_the_first_write_detaches() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = mutarray_of_ints(&mut vm, &[1, 2, 3, 4]);
        let b = rooted!(vm, share_array(p, a));
        // A new header on the same backing: no element copied.
        assert_ne!(a, b);
        assert!(mutarray_of(a).same_backing(mutarray_of(b)));
        assert_eq!((vm.metrics.mutarray.shares, vm.metrics.mutarray.detaches), (1, 0));
        // The first write through either detaches it, once.
        rt_mutarray_set(p, b, small(0), small(9));
        assert_eq!((vm.metrics.mutarray.detaches, vm.metrics.mutarray.detach_elements), (1, 4));
        assert_eq!(mutarray_contents(a), vec![1, 2, 3, 4]);
        assert_eq!(mutarray_contents(b), vec![9, 2, 3, 4]);
        // Later writes to the now unique backings never detach again.
        rt_mutarray_set(p, b, small(1), small(8));
        rt_mutarray_set(p, a, small(3), small(7));
        assert_eq!(vm.metrics.mutarray.detaches, 1);
        assert_eq!(mutarray_contents(a), vec![1, 2, 3, 7]);
        assert_eq!(mutarray_contents(b), vec![9, 8, 3, 4]);
        vm.temp_roots.clear();
    }

    #[test]
    fn mutarray_swap_and_take_front_move_elements_and_keep_copies_intact() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = mutarray_of_ints(&mut vm, &[1, 2, 3]);
        let copy = rooted!(vm, share_array(p, a));
        // swap installs the replacement and moves the old element out.
        assert_eq!(small_of(rt_mutarray_swap(p, a, small(1), small(20))), 2);
        // A consuming loop's drain takes elements first to last; the length
        // shrinks, and a copy taken before is untouched.
        assert_eq!(small_of(rt_mutarray_take_front(p, a)), 1);
        assert_eq!(rt_mutarray_empty(p, a), FALSE);
        assert_eq!(small_of(rt_mutarray_take_front(p, a)), 20);
        assert_eq!(small_of(rt_mutarray_take_front(p, a)), 3);
        assert_eq!(rt_mutarray_empty(p, a), TRUE);
        assert_eq!(mutarray_contents(copy), vec![1, 2, 3]);
        vm.temp_roots.clear();
    }

    #[test]
    fn mutarray_out_of_range_changes_nothing() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = mutarray_of_ints(&mut vm, &[5, 6]);
        let copy = rooted!(vm, share_array(p, a));
        assert_eq!(rt_mutarray_set(p, a, small(2), small(9)), NO_VALUE);
        assert_eq!(rt_mutarray_swap(p, a, small(-1), small(9)), NO_VALUE);
        // A failed write neither changes the array nor detaches its backing.
        assert_eq!(mutarray_contents(a), vec![5, 6]);
        assert_eq!(vm.metrics.mutarray.detaches, 0);
        assert!(mutarray_of(a).same_backing(mutarray_of(copy)));
        vm.temp_roots.clear();
    }

    #[test]
    fn mutarray_operations_survive_a_collection_at_every_allocation() {
        let mut vm = vm();
        vm.heap.set_stress_for_test(true);
        let p: *mut Vm = &mut *vm;
        let inner = mutarray_of_ints(&mut vm, &[1, 2]);
        let outer = rooted!(vm, rt_mutarray_create(p, small(3), inner));
        let copy = rooted!(vm, share_array(p, outer));
        let fresh = rooted!(vm, rt_mutarray_allocate(p, small(4)));
        rt_mutarray_set(p, copy, small(0), fresh);
        let frozen = rooted!(vm, rt_mutarray_to_list(p, outer));
        assert_eq!(list_of(frozen).items().len(), 3);
        assert_eq!(mutarray_contents(inner), vec![1, 2]);
        assert_eq!(array_elements(copy).next(), Some(fresh));
        assert_eq!(array_elements(outer).next(), Some(inner));
        // A drained array keeps (and the collector traces) exactly the
        // elements not taken yet.
        let roots = vm.temp_roots.len();
        let other = mutarray_of_ints(&mut vm, &[3]);
        let list = rooted!(vm, vm.new_list(vec![inner, other]));
        let drained = rt_mutarray_from_list(p, list);
        // OTHER is reachable only through DRAINED from here on.
        vm.temp_roots.truncate(roots);
        vm.temp_roots.push(drained);
        assert_eq!(rt_mutarray_take_front(p, drained), inner);
        rooted!(vm, rt_mutarray_allocate(p, small(1)));
        assert_eq!(array_elements(drained).collect::<Vec<_>>(), vec![other]);
        assert_eq!(mutarray_contents(other), vec![3]);
        vm.temp_roots.clear();
    }

    /// The allocator calls of each array operation (string_alloc_tests.rs's
    /// counting allocator): a new array is its header and one backing
    /// allocation -- the backing's counts and its slots -- whatever its
    /// constructor and length; a copy is a header; the first write through a
    /// copy allocates the detached backing, frees nothing (the shared one
    /// stays the other header's), and later writes, a bulk copy and a
    /// consuming loop's step allocate nothing.
    #[test]
    fn mutarray_is_a_header_and_one_backing_allocation() {
        use crate::runtime::string_alloc_tests::{counting_vm, measure};
        let mut vm = counting_vm();
        let p: *mut Vm = &mut *vm;
        let header = std::mem::size_of::<MutArrayObj>();
        // An Rc's two counts, then the slots.
        let backing = |n: usize| 16 + 8 * n;
        let list = rooted!(vm, vm.new_list((0..8).map(small).collect()));
        let (a, allocs, _, bytes) = measure(|| rt_mutarray_from_list(p, list));
        vm.temp_roots.push(a);
        assert_eq!((allocs, bytes), (2, header + backing(8)), "from_list");
        let (b, allocs, _, bytes) = measure(|| rt_mutarray_create(p, small(8), small(7)));
        vm.temp_roots.push(b);
        assert_eq!((allocs, bytes), (2, header + backing(8)), "create");
        let (c, allocs, _, bytes) = measure(|| rt_mutarray_allocate(p, small(0)));
        vm.temp_roots.push(c);
        assert_eq!((allocs, bytes), (2, header + backing(0)), "allocate(0)");
        let (copy, allocs, _, bytes) = measure(|| share_array(p, a));
        vm.temp_roots.push(copy);
        assert_eq!((allocs, bytes), (1, header), "share");
        let (_, allocs, frees, bytes) = measure(|| rt_mutarray_set(p, copy, small(0), small(9)));
        assert_eq!((allocs, frees, bytes), (1, 0, backing(8)), "detach");
        assert_eq!((vm.metrics.mutarray.detaches, vm.metrics.mutarray.detach_elements), (1, 8));
        let (_, allocs, _, _) = measure(|| {
            rt_mutarray_set(p, copy, small(1), small(9));
            rt_mutarray_set(p, a, small(1), small(9))
        });
        assert_eq!(allocs, 0, "unique writes");
        let (_, allocs, _, _) = measure(|| rt_mutarray_copy(p, b, small(0), a, small(2), small(4)));
        assert_eq!(allocs, 0, "copy between arrays");
        let (x, allocs, frees, _) = measure(|| rt_mutarray_take_front(p, b));
        assert_eq!((small_of(x), allocs, frees), (2, 0, 0), "take_front");
        assert_eq!(vm.metrics.mutarray.detaches, 1);
        vm.temp_roots.clear();
    }

    /// A consuming loop's step only advances its own header's start: a copy
    /// made before keeps every element, and a copy of a drained array (no
    /// program makes one: a consumed array is affine) shares the elements
    /// left, which its first write detaches -- exactly those.
    #[test]
    fn mutarray_drained_elements_are_header_local() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = mutarray_of_ints(&mut vm, &[1, 2, 3, 4]);
        let before = rooted!(vm, share_array(p, a));
        assert_eq!(small_of(rt_mutarray_take_front(p, a)), 1);
        let after = rooted!(vm, share_array(p, a));
        assert_eq!(small_of(rt_mutarray_capacity(p, after)), 3);
        rt_mutarray_set(p, after, small(0), small(20));
        assert_eq!((vm.metrics.mutarray.detaches, vm.metrics.mutarray.detach_elements), (1, 3));
        assert_eq!(mutarray_contents(a), vec![2, 3, 4]);
        assert_eq!(mutarray_contents(after), vec![20, 3, 4]);
        assert_eq!(mutarray_contents(before), vec![1, 2, 3, 4]);
        assert_eq!(small_of(rt_mutarray_take_front(p, after)), 20);
        assert_eq!(mutarray_contents(after), vec![3, 4]);
        assert_eq!(mutarray_contents(a), vec![2, 3, 4]);
        vm.temp_roots.clear();
    }

    /// The three header words generated code reads (codegen::clif's inline
    /// capacity/at/set), read the way it reads them -- raw loads at
    /// MUTARRAY_LEN/PTR/UNIQUE_OFFSET -- after every operation that changes
    /// a header's backing, its start or its backing's holders: LEN and PTR
    /// always designate exactly `items()`, and UNIQUE is nonzero only for a
    /// backing no other header holds (stale only towards 0, and refreshed
    /// by the next runtime write).
    #[test]
    fn mutarray_header_words_track_the_backing() {
        fn words(arr: Value) -> (usize, *const Value, u64) {
            let at = |offset: i32| unsafe { *((arr as usize + offset as usize) as *const u64) };
            (at(MUTARRAY_LEN_OFFSET) as usize, at(MUTARRAY_PTR_OFFSET) as *const Value, at(MUTARRAY_UNIQUE_OFFSET))
        }
        fn exact(arr: Value) -> u64 {
            let (len, ptr, unique) = words(arr);
            let items = mutarray_of(arr).items();
            assert_eq!((len, ptr), (items.len(), items.as_ptr()), "LEN/PTR are the elements");
            for (i, &item) in items.iter().enumerate() {
                assert_eq!(unsafe { *ptr.add(i) }, item, "PTR + 8i is element i");
            }
            let (_, holders) = mutarray_of(arr).backing_extent();
            assert!(unique == 0 || holders == 1, "UNIQUE only for a backing one header holds");
            unique
        }
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let a = mutarray_of_ints(&mut vm, &[1, 2, 3, 4]);
        assert_eq!(exact(a), 1, "a new array is unique");
        let empty = rooted!(vm, rt_mutarray_allocate(p, small(0)));
        assert_eq!(exact(empty), 1);
        // A share: both headers on one backing, neither unique.
        let b = rooted!(vm, share_array(p, a));
        assert_eq!((exact(a), exact(b)), (0, 0));
        assert_eq!(words(a).1, words(b).1);
        // B's first write detaches B (a new, unique backing); A's backing is
        // A's alone again but A still says shared, until A's next write.
        rt_mutarray_set(p, b, small(0), small(9));
        assert_eq!((exact(a), exact(b)), (0, 1));
        assert_ne!(words(a).1, words(b).1);
        rt_mutarray_set_proven(p, a, small(1), small(8));
        assert_eq!(exact(a), 1);
        assert_eq!(vm.metrics.mutarray.detaches, 1);
        assert_eq!((mutarray_contents(a), mutarray_contents(b)), (vec![1, 8, 3, 4], vec![9, 2, 3, 4]));
        // A copy the collector frees leaves A stale-shared; A's next write
        // finds its backing unique (no detach) and re-enables UNIQUE.
        let roots = vm.temp_roots.len();
        let c = share_array(p, a);
        assert_eq!((exact(a), exact(c)), (0, 0));
        vm.collect_for_test(crate::runtime::metrics::GcReason::Explicit);
        assert_eq!(mutarray_of(a).backing_extent().1, 1);
        assert_eq!(exact(a), 0);
        rt_mutarray_set(p, a, small(2), small(7));
        assert_eq!((exact(a), vm.metrics.mutarray.detaches), (1, 1));
        assert_eq!(vm.temp_roots.len(), roots);
        // A consuming loop's step advances PTR past the element and LEN.
        let (len, ptr, _) = words(a);
        assert_eq!(small_of(rt_mutarray_take_front(p, a)), 1);
        assert_eq!(words(a), (len - 1, unsafe { ptr.add(1) }, 1));
        exact(a);
        for _ in 0..3 {
            rt_mutarray_take_front(p, a);
        }
        assert_eq!(words(a).0, 0);
        exact(a);
        // A detach of a drained-then-shared header copies only its elements:
        // PTR moves to the new backing's first slot.
        let d = mutarray_of_ints(&mut vm, &[5, 6, 7]);
        rt_mutarray_take_front(p, d);
        let e = rooted!(vm, share_array(p, d));
        rt_mutarray_set(p, e, small(0), small(60));
        assert_eq!((exact(d), exact(e)), (0, 1));
        assert_eq!((mutarray_contents(d), mutarray_contents(e)), (vec![6, 7], vec![60, 7]));
        vm.temp_roots.clear();
    }
}
