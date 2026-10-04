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
//! | rt_int_mod             | Int, Int            | Int (0<=r<|b|); ARITHMETIC   | no        |
//! | rt_int_and/or/xor      | Int, Int            | Int (two's-complement)       | big Ints  |
//! | rt_int_shl/shr         | Int, Int(shift>=0)  | Int; RANGE if shift invalid  | big Ints  |
//! | rt_int_cmp             | Int, Int            | -1/0/1 (raw i64)             | no        |
//! | rt_value_eq            | any, any            | Bool; EQUALITY on callables  | no        |
//! | rt_str_eq              | Str, Str            | Bool                         | no        |
//! | rt_hash                | any                 | Int (61-bit); EQUALITY       | no        |
//! | rt_str_len             | Str                 | Int                          | no        |
//! | rt_substr              | Str, Int, Int       | Str; declared LowerUnderrun/ | yes       |
//! |                        |                     | UpperOverrun (check_slice)   |           |
//! | rt_str_decode_char_at  | Str, Int(byte off.) | one-char Str                 | yes       |
//! | rt_str_byte_len        | Str                 | Int (UTF-8 byte length)      | no        |
//! | rt_str_lower           | Str                 | Str                          | yes       |
//! | rt_str_cat             | Str, Str            | Str                          | yes       |
//! | rt_str_utf8_bytes      | Str                 | List of Int (0..255); RANGE  | yes       |
//! | rt_argv                |                     | List of Str; declared        | yes       |
//! |                        |                     | InvalidArgumentEncoding      |           |
//! | rt_linux_x86_64_syscall| 7 Ints (i64 words)  | Int: raw rax, signed (see    | big Ints  |
//! |                        | rax rdi rsi rdx r10 | runtime/syscall.rs); TYPE if |           |
//! |                        | r8 r9               | an operand is no i64 word    |           |
//! | rt_is_tcl_alpha        | Str (1 scalar)      | Bool; RANGE if not 1 scalar  | no        |
//! | rt_is_tcl_alnum        | Str (1 scalar)      | Bool; RANGE if not 1 scalar  | no        |
//! | rt_str_region_is_tcl_alpha | Str,Int,Int (region, 1 scalar) | Bool; RANGE | no    |
//! | rt_str_region_is_tcl_alnum | Str,Int,Int (region, 1 scalar) | Bool; RANGE | no    |
//! | rt_list_new            | count, *Value       | List                         | yes       |
//! | rt_list_len            | List                | Int                          | no        |
//! | rt_list_get            | List, Int           | element; declared            | no        |
//! |                        |                     | IndexNotFound (list::at)     |           |
//! | rt_list_get_proven     | List, Int           | element (index proven valid  | no        |
//! |                        |                     | by hir/completions.tcl)      |           |
//! | rt_list_append         | List, any           | new List (copy)              | yes       |
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
use super::error::{semantic_kind, RtError};
use super::syscall::rt_linux_x86_64_syscall;
use super::value::*;
use super::vm::{current_program, Vm, NativeInfo};
use crate::nir::OpCode;
use num_bigint::BigInt;
use num_traits::Signed;
use std::cmp::Ordering;
use unicode_general_category::{get_general_category, GeneralCategory};

/// Whether OP's runtime implementation may allocate (and so may trigger a
/// collection): exactly the "allocates" column of the table above, in one
/// place, so codegen::roots's safepoint classification (which Op instructions
/// are GC safepoints) reads this instead of keeping its own copy of the same
/// fact. `IAdd`/`ISub`/`IMul` are here because their fast (small-Int) path
/// never allocates but their BigInt-overflow fallback (`rt_int_add` etc.)
/// might; codegen has no cheaper way to tell the two paths apart from NIR
/// alone, so the whole instruction is conservatively a safepoint (see
/// codegen::roots's module doc).
pub fn op_may_allocate(op: OpCode) -> bool {
    use OpCode::*;
    matches!(
        op,
        IAdd | ISub | IMul | IAnd | IOr | IXor | IShl | IShr | Substr | DecodeCharAt | ShortToStr | AsciiToStr | StrLower | StrCat
            | StrUtf8Bytes | Argv | ListNew | ListAppend | MutArrayAllocate | MutArrayFreeze | MkOk
            // The proven siblings allocate exactly like their checked forms; only
            // their op_may_error classification differs.
            | SubstrProven | MutArrayFreezeProven | MkError
            | SetFromList
            // The raw rax result is boxed as a BigInt when it is outside the
            // small-Int range (runtime/syscall.rs).
            | SyscallLinuxX86_64
            // Same allocation behavior as SetFromList (same runtime helper,
            // same `new_set` construction) -- only its own `op_may_error`
            // classification differs. See SetFromListTotal's own doc
            // comment (nir.rs) and M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md:
            // may_error and may_gc are independent effect dimensions, and
            // this milestone changes only the former.
            | SetFromListTotal
    )
}

/// Whether OP can report a Botlish semantic error by returning NO_VALUE.
pub fn op_may_error(op: OpCode) -> bool {
    use OpCode::*;
    matches!(op, IMod | IShl | IShr | VEq | Hash | Substr | StrCat | StrUtf8Bytes | Argv | StrIsTclAlpha | StrIsTclAlnum
        // Only on an operand that is not a 64-bit register word (TYPE, never
        // a truncation: runtime/syscall.rs), which a checked program cannot
        // produce. The kernel's own result is never an error here.
        | SyscallLinuxX86_64
        | ListNew | ListGet | ListAppend | MutArrayAllocate | MutArrayGet | MutArraySet | MutArrayCopy | MutArrayFreeze
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
        | SetFromList | SetContains)
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
    vm.fail(RtError::Semantic { kind: "UNCAUGHT-ERROR", message: format!("uncaught propagated error: <error {name_text}>") })
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

fn int_compare(a: Value, b: Value) -> Ordering {
    match (int_small(a), int_small(b)) {
        (Some(x), Some(y)) => x.cmp(&y),
        _ => int_to_big(a).cmp(&int_to_big(b)),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_int_cmp(_p: *mut Vm, a: Value, b: Value) -> i64 {
    int_compare(a, b) as i64
}

// ---------------------------------------------------------------------------
// Equality (core::value::equal)

fn equal(p: *mut Vm, a: Value, b: Value) -> Result<bool, ()> {
    let (ka, kb) = (kind_of(a), kind_of(b));
    // MutableArray, like Block/Native, has no structural equality (req #31:
    // its identity/equality semantics are a separate design question).
    if matches!(ka, Kind::Block | Kind::Native | Kind::MutArray) || matches!(kb, Kind::Block | Kind::Native | Kind::MutArray) {
        vm(p).fail(RtError::Equality { a, b });
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
            for (u, w) in x.fields().iter().zip(y.fields().iter()) {
                if !equal(p, *u, *w)? {
                    return Ok(false);
                }
            }
            true
        }
        Kind::Block | Kind::Native | Kind::MutArray => unreachable!(),
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

/// H folded with V's kind tag and payload, recursing into List elements and
/// a Result payload exactly as `equal` recurses (see ops.rs's `equal`).
fn hash_mix(p: *mut Vm, h: u64, v: Value) -> Result<u64, ()> {
    let kind = kind_of(v);
    if matches!(kind, Kind::Block | Kind::Native | Kind::MutArray) {
        vm(p).fail(RtError::Unhashable { value: v });
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
        Kind::Block | Kind::Native | Kind::MutArray => unreachable!(),
    };
    let h = fnv1a(h, &[tag]);
    Ok(match kind {
        // Canonical decimal text, matching how core::value::equal treats
        // textual identity as numeric equality for every Int, small or big.
        Kind::Int => {
            let text = match int_small(v) {
                Some(n) => n.to_string(),
                None => int_to_big(v).to_string(),
            };
            fnv1a(h, text.as_bytes())
        }
        // Evidence is metadata, not part of the value (equal ignores it too).
        Kind::Str => fnv1a(h, str_of(v).as_bytes()),
        Kind::Bool => fnv1a(h, &[(v == TRUE) as u8]),
        Kind::Unit => h,
        // Canonical decimal codepoint text, matching how Int's own text is
        // hashed above (core/hashing.tcl's identical choice).
        Kind::UnicodeChar => fnv1a(h, char_of(v).to_string().as_bytes()),
        Kind::List => {
            let items = list_of(v).items();
            let mut h = fnv1a(h, &(items.len() as u64).to_le_bytes());
            for item in items {
                let sub = hash_mix(p, FNV_OFFSET, *item)?;
                h = fnv1a(h, &sub.to_le_bytes());
            }
            h
        }
        Kind::Result => {
            let r = result_of(v);
            let h = fnv1a(h, &[r.ok as u8]);
            let sub = hash_mix(p, FNV_OFFSET, r.payload)?;
            fnv1a(h, &sub.to_le_bytes())
        }
        Kind::Struct => {
            // core/hashing.tcl's struct case, byte for byte: the declaration
            // identity text (empty for an anonymous struct), the field
            // count, then each slot's name text and sub-hash in slot order.
            let obj = struct_of(v);
            let (name, fields) = current_program(|prog| {
                let shape = &prog.shapes[obj.shape as usize];
                (shape.name.clone().unwrap_or_default(), shape.fields.clone())
            });
            let mut h = fnv1a(h, name.as_bytes());
            h = fnv1a(h, &(fields.len() as u64).to_le_bytes());
            for (field, item) in fields.iter().zip(obj.fields().iter()) {
                h = fnv1a(h, field.as_bytes());
                let sub = hash_mix(p, FNV_OFFSET, *item)?;
                h = fnv1a(h, &sub.to_le_bytes());
            }
            h
        }
        Kind::ImmutableSet => {
            // Order-independent (XOR-combined member sub-hashes), matching
            // `set_equal`'s own order-independent equality and core/
            // hashing.tcl's identical Tcl-side choice: two equal sets must
            // hash equal regardless of construction order. No ImmutableSet-
            // specific hashing API is added (item 92) -- this only keeps
            // the existing, pre-existing generic `hash` native total for
            // the new kind.
            let items = set_of(v).items();
            let mut h = fnv1a(h, &(items.len() as u64).to_le_bytes());
            let mut combined = 0u64;
            for item in items {
                combined ^= hash_mix(p, FNV_OFFSET, *item)?;
            }
            h = fnv1a(h, &combined.to_le_bytes());
            h
        }
        Kind::Block | Kind::Native | Kind::MutArray => unreachable!(),
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_hash(p: *mut Vm, v: Value) -> Value {
    match hash_mix(p, FNV_OFFSET, v) {
        Ok(h) => vm(p).new_int((h & HASH_MASK) as i64),
        Err(()) => NO_VALUE,
    }
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

#[unsafe(no_mangle)]
pub extern "C" fn rt_is_tcl_alpha(p: *mut Vm, s: Value) -> Value {
    match one_scalar(p, s, "str::is_tcl_alpha") {
        Ok(c) => bool_value(tcl_alpha_char(c)),
        Err(no_value) => no_value,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_is_tcl_alnum(p: *mut Vm, s: Value) -> Value {
    match one_scalar(p, s, "str::is_tcl_alnum") {
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
    match region_one_scalar(p, base, start, end, "str::is_tcl_alpha") {
        Ok(c) => bool_value(tcl_alpha_char(c)),
        Err(no_value) => no_value,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_str_region_is_tcl_alnum(p: *mut Vm, base: Value, start: Value, end: Value) -> Value {
    match region_one_scalar(p, base, start, end, "str::is_tcl_alnum") {
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

/// Records the builtin declared error ID (named NAME) as pending and fails:
/// what a handler's `declarederroreq` reads, with an UNCAUGHT-ERROR fallback
/// for the program boundary. Returns NO_VALUE.
fn fail_builtin(p: *mut Vm, id: u32, name: &str) -> Value {
    let vm = vm(p);
    vm.declared_error = id;
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
    for &item in source {
        let mut seen = false;
        for &existing in items.iter() {
            match equal(p, existing, item) {
                Ok(true) => {
                    seen = true;
                    break;
                }
                Ok(false) => {}
                Err(()) => return NO_VALUE,
            }
        }
        if !seen {
            items.push(item);
        }
    }
    let elements = items.len();
    let r = vm(p).new_set(items);
    vm(p).metrics.record_list_copy(elements);
    r
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
// MutableArrays: fixed-capacity, explicitly mutable indexed storage
// (value.rs's MutArrayObj). Every constructor/mutator here is the runtime
// substrate only -- growth policy, chunking and finalization strategy are
// ordinary Botlish (see examples/stdlib), never decided in this file.
//
// rt_mutarray_set and rt_mutarray_copy are the two places a slot's value
// ever changes after allocation: a future write barrier (e.g. for a
// generational collector) has exactly these two call sites to instrument,
// never arbitrary code that pokes at a MutableArray's memory directly.
//
// "No misleading copy accounting" (milestone req #43): record_mutarray_copy
// is called only for movement of *existing* values -- bulk copy and
// finalization -- never for an ordinary append's single fresh write of a
// caller-supplied value into unused capacity (that is charged, optionally,
// as a mutarray write via record_mutarray_write instead).

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_allocate(p: *mut Vm, capacity: Value) -> Value {
    match int_small(capacity) {
        Some(n) if n >= 0 => vm(p).new_mutarray(n as usize),
        _ => {
            let message = format!(
                "mutable_array::allocate: capacity must be 0..{MAX_COLLECTION_LENGTH}, got {}",
                int_to_big(capacity)
            );
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_capacity(p: *mut Vm, arr: Value) -> Value {
    vm(p).new_int(mutarray_of(arr).slots.len() as i64)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_get(p: *mut Vm, arr: Value, index: Value) -> Value {
    let slots = &mutarray_of(arr).slots;
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < slots.len() => {
            let v = slots[i as usize];
            vm(p).metrics.record_mutarray_read();
            v
        }
        _ => index_not_found(p),
    }
}

/// `rt_mutarray_get` at an index proven to designate a slot (`mutarraygetproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_get_proven(p: *mut Vm, arr: Value, index: Value) -> Value {
    let i = int_small(index).expect("proven index is a small Int") as usize;
    let v = mutarray_of(arr).slots[i];
    vm(p).metrics.record_mutarray_read();
    v
}

/// `rt_mutarray_set` at an index proven to designate a slot (`mutarraysetproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_set_proven(p: *mut Vm, arr: Value, index: Value, value: Value) -> Value {
    let i = int_small(index).expect("proven index is a small Int") as usize;
    mutarray_of_mut(arr).slots[i] = value;
    vm(p).metrics.record_mutarray_write();
    UNIT
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_set(p: *mut Vm, arr: Value, index: Value, value: Value) -> Value {
    let obj = mutarray_of_mut(arr);
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < obj.slots.len() => {
            obj.slots[i as usize] = value;
            vm(p).metrics.record_mutarray_write();
            UNIT
        }
        _ => index_not_found(p),
    }
}

/// Bulk copy: COUNT elements of SRC starting at SRC_START into DST starting
/// at DST_START. Uses `ptr::copy` (memmove semantics), so DST and SRC may be
/// the same MutableArray with overlapping ranges: the result is always as if
/// SRC's elements were read before any of DST's were written. Both ranges
/// are slices (`check_slice`), the destination's checked first; an invalid
/// one fails with LowerUnderrun/UpperOverrun and copies nothing.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_copy(p: *mut Vm, dst: Value, dst_start: Value, src: Value, src_start: Value, count: Value) -> Value {
    let dst_len = mutarray_of(dst).slots.len();
    let src_len = mutarray_of(src).slots.len();
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
    // The one proven helper that would otherwise be a raw memmove: an internal
    // invariant check (an abort, never a Botlish error), so a proof bug
    // cannot become memory corruption. One comparison beside a bulk copy.
    assert!(
        ds + n <= mutarray_of(dst).slots.len() && ss + n <= mutarray_of(src).slots.len(),
        "proven mutable_array::copy out of bounds"
    );
    mutarray_copy_range(p, dst, ds, src, ss, n)
}

/// Copies N slots of SRC from SS into DST at DS (both ranges already valid).
fn mutarray_copy_range(p: *mut Vm, dst: Value, ds: usize, src: Value, ss: usize, n: usize) -> Value {
    if n > 0 {
        let dst_ptr = mutarray_of_mut(dst).slots.as_mut_ptr();
        let src_ptr = mutarray_of(src).slots.as_ptr();
        unsafe { std::ptr::copy(src_ptr.add(ss), dst_ptr.add(ds), n) };
        vm(p).metrics.record_mutarray_copy(n);
    }
    UNIT
}

/// Final immutable storage creation (milestone architecture item #2): a new
/// List of ARR's first COUNT elements. This is substrate, not policy -- it
/// is the one way a MutableArray's contents become an ordinary immutable
/// List; growth/chunking policy is entirely the caller's (ordinary Botlish).
/// Always copies (req #18): a future zero-copy freeze (req #19), proving ARR
/// is uniquely owned and never mutated again, is left open, not implemented.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_freeze(p: *mut Vm, arr: Value, count: Value) -> Value {
    let slots = &mutarray_of(arr).slots;
    match check_slice(p, Bound::At(0), SliceEnd::End(bound_of(count)), slots.len()) {
        Ok((_, n)) => freeze_prefix(p, arr, n),
        Err(failed) => failed,
    }
}

/// `rt_mutarray_freeze` at a call site whose slice is proven valid
/// (`mutarrayfreezeproven`).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mutarray_freeze_proven(p: *mut Vm, arr: Value, count: Value) -> Value {
    let n = int_small(count).expect("proven count is a small Int") as usize;
    debug_assert!(n <= mutarray_of(arr).slots.len());
    freeze_prefix(p, arr, n)
}

/// A new List of ARR's first N slots (N already known valid).
fn freeze_prefix(p: *mut Vm, arr: Value, n: usize) -> Value {
    let items = mutarray_of(arr).slots[..n].to_vec();
    let elements = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_mutarray_copy(elements);
    r
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
        VEq => rt_value_eq(p, a[0], a[1]),
        StrEq => rt_str_eq(p, a[0], a[1]),
        ListNew => rt_list_new(p, a.len() as u64, a.as_ptr()),
        StrLen => rt_str_len(p, a[0]),
        Substr => rt_substr(p, a[0], a[1], a[2]),
        StrLower => rt_str_lower(p, a[0]),
        StrCat => rt_str_cat(p, a[0], a[1]),
        StrUtf8Bytes => rt_str_utf8_bytes(p, a[0]),
        Argv => rt_argv(p),
        StrIsTclAlpha => rt_is_tcl_alpha(p, a[0]),
        StrIsTclAlnum => rt_is_tcl_alnum(p, a[0]),
        ListLen => rt_list_len(p, a[0]),
        ListGet => rt_list_get(p, a[0], a[1]),
        ListAppend => rt_list_append(p, a[0], a[1]),
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
        IsInt => rt_is_kind(p, a[0], Kind::Int.code() as u64),
        IsStr => rt_is_kind(p, a[0], Kind::Str.code() as u64),
        IsList => rt_is_kind(p, a[0], Kind::List.code() as u64),
        IsMutArray => rt_is_kind(p, a[0], Kind::MutArray.code() as u64),
        IsOk => rt_is_result(p, a[0], 1),
        IsError => rt_is_result(p, a[0], 0),
        ResultValue => rt_result_payload(p, a[0], 1),
        ResultError => rt_result_payload(p, a[0], 0),
        CharCodepoint => rt_char_codepoint(p, a[0]),
        MkOk => rt_result_new(p, 1, a[0]),
        MkError => rt_result_new(p, 0, a[0]),
        Hash => rt_hash(p, a[0]),
        RegionCheck | RegionEq | RBox | RUnbox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq
        | RIShr | RIShl | StrToShort | ShortToStr | ShortLen | ShortEq | StrSliceShort | StrToAscii | AsciiToStr
        | AsciiLen | AsciiEq | AsciiToShort | AsciiShortEq
        | DecodeCharAt | StrByteLen | StrRegionIsTclAlpha | StrRegionIsTclAlnum
        // linux::abi::syscall is never a value (hir/syscall.tcl rejects any
        // use but a direct call), so no Native value ever dispatches to it.
        | SyscallLinuxX86_64 => {
            // Raw (untagged) representation ops, StringRegion ops and String
            // traversal ops never implement a dynamic native: native/lower.tcl
            // emits them only directly, as `op` instructions inline in a
            // function's own body.
            unreachable!("{op:?} is never a native implementation")
        }
    }
}

/// Runtime helper symbols: name, number of parameters (after none: all are
/// 64-bit words, including the vm pointer), address.
pub fn helpers() -> Vec<(&'static str, usize, *const u8)> {
    macro_rules! h {
        ($name:ident, $n:expr) => {
            (stringify!($name), $n, $name as *const u8)
        };
    }
    vec![
        h!(rt_type_error, 4),
        h!(rt_not_boolean, 2),
        h!(rt_raise, 3),
        h!(rt_stack_overflow, 1),
        h!(rt_fail_declared, 3),
        h!(rt_declared_error, 1),
        h!(rt_clear_declared_error, 1),
        h!(rt_int_add, 3),
        h!(rt_int_sub, 3),
        h!(rt_int_mul, 3),
        h!(rt_int_mod, 3),
        h!(rt_int_and, 3),
        h!(rt_int_or, 3),
        h!(rt_int_xor, 3),
        h!(rt_int_shl, 3),
        h!(rt_int_shr, 3),
        h!(rt_int_cmp, 3),
        h!(rt_value_eq, 3),
        h!(rt_str_eq, 3),
        h!(rt_hash, 2),
        h!(rt_str_len, 2),
        h!(rt_substr, 4),
        h!(rt_substr_proven, 4),
        h!(rt_str_region_check, 4),
        h!(rt_str_region_eq, 5),
        h!(rt_str_decode_char_at, 3),
        h!(rt_str_byte_len, 2),
        h!(rt_str_to_short, 2),
        h!(rt_short_to_str, 2),
        h!(rt_str_to_ascii, 2),
        h!(rt_ascii_to_str, 2),
        h!(rt_str_slice_short, 4),
        h!(rt_str_lower, 2),
        h!(rt_str_cat, 3),
        h!(rt_str_utf8_bytes, 2),
        h!(rt_argv, 1),
        h!(rt_linux_x86_64_syscall, 8),
        h!(rt_is_tcl_alpha, 2),
        h!(rt_is_tcl_alnum, 2),
        h!(rt_str_region_is_tcl_alpha, 4),
        h!(rt_str_region_is_tcl_alnum, 4),
        h!(rt_list_new, 3),
        h!(rt_struct_new, 4),
        h!(rt_list_len, 2),
        h!(rt_list_get, 3),
        h!(rt_list_get_proven, 3),
        h!(rt_list_append, 3),
        h!(rt_construct, 4),
        h!(rt_plan_materialize, 2),
        h!(rt_set_from_list, 2),
        h!(rt_set_contains, 3),
        h!(rt_mutarray_allocate, 2),
        h!(rt_mutarray_capacity, 2),
        h!(rt_mutarray_get, 3),
        h!(rt_mutarray_get_proven, 3),
        h!(rt_mutarray_set, 4),
        h!(rt_mutarray_set_proven, 4),
        h!(rt_mutarray_copy, 6),
        h!(rt_mutarray_copy_proven, 6),
        h!(rt_mutarray_freeze, 3),
        h!(rt_mutarray_freeze_proven, 3),
        h!(rt_is_kind, 3),
        h!(rt_is_result, 3),
        h!(rt_result_payload, 3),
        h!(rt_result_new, 3),
        h!(rt_char_codepoint, 2),
        h!(rt_closure_new, 5),
        h!(rt_call_value, 4),
    ]
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::{ProgramInfo, Vm};

    fn vm() -> Box<Vm> {
        Vm::new(
            std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new() }),
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
                    })
                    .collect(),
            }),
            AllocMode::Summary,
        )
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
        let s = str_val(&mut vm, "x");
        let s2 = str_val(&mut vm, "x");
        let anon1 = vm.new_struct(0, vec![small(1), s]);
        let anon2 = vm.new_struct(0, vec![small(1), s2]);
        let anon3 = vm.new_struct(0, vec![small(2), s]);
        let person = vm.new_struct(1, vec![small(1), s]);
        let account = vm.new_struct(2, vec![small(1), s]);
        let short = vm.new_struct(3, vec![small(1)]);
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
        let array = vm.new_mutarray(1);
        let x = vm.new_struct(0, vec![array]);
        let y = vm.new_struct(0, vec![array]);
        assert_eq!(rt_value_eq(&mut *vm, x, y), NO_VALUE);
        assert!(vm.error.is_some());
    }

    #[test]
    fn struct_hash_agrees_with_equality() {
        let mut vm = vm_with_shapes(&[(None, &["a", "b"]), (None, &["a"]), (Some("P"), &["a"])]);
        let s = str_val(&mut vm, "x");
        let s2 = str_val(&mut vm, "x");
        let one = vm.new_struct(0, vec![small(1), s]);
        let two = vm.new_struct(0, vec![small(1), s2]);
        let other = vm.new_struct(1, vec![small(1)]);
        let named = vm.new_struct(2, vec![small(1)]);
        let h = |vm: &mut Vm, v| rt_hash(vm, v);
        assert_eq!(h(&mut vm, one), h(&mut vm, two));
        assert_ne!(h(&mut vm, one), h(&mut vm, other));
        assert_ne!(h(&mut vm, other), h(&mut vm, named));
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
                    ShapeInfo { name: Some("token::Token".into()), fields: vec!["secret".into()], opaque: true },
                    ShapeInfo { name: Some("Holder".into()), fields: vec!["token".into()], opaque: false },
                ],
            }),
            AllocMode::Summary,
        );
        let token = vm.new_struct(0, vec![small(1234)]);
        let holder = vm.new_struct(1, vec![token]);
        assert_eq!(show(token), "<opaque token::Token>");
        assert_eq!(show(holder), "Holder {token: <opaque token::Token>}");
        assert_eq!(tcl_value(token).unwrap(), "struct {token::Token secret} {{int 1234}}");
    }

    #[test]
    fn struct_show_names_fields_in_shape_order() {
        use crate::runtime::show::{show, tcl_value};
        let mut vm = vm_with_shapes(&[(None, &["age", "name"]), (Some("geo::Point"), &["y", "x"]), (None, &[])]);
        let name = str_val(&mut vm, "Grace");
        let anon = vm.new_struct(0, vec![small(45), name]);
        let named = vm.new_struct(1, vec![small(2), small(1)]);
        let empty = vm.new_struct(2, vec![]);
        assert_eq!(show(anon), "{age: 45, name: \"Grace\"}");
        assert_eq!(show(named), "geo::Point {y: 2, x: 1}");
        assert_eq!(show(empty), "{}");
        assert_eq!(tcl_value(anon).unwrap(), "struct {{} age name} {{int 45} {str Grace}}");
        assert_eq!(tcl_value(named).unwrap(), "struct {geo::Point y x} {{int 2} {int 1}}");
        assert_eq!(tcl_value(empty).unwrap(), "struct {{}} {}");
    }

    #[test]
    fn struct_fields_are_traced_and_reclaimed() {
        use crate::runtime::metrics::GcReason;
        let mut vm = vm_with_shapes(&[(None, &["a", "b"])]);
        let kept = str_val(&mut vm, "kept");
        let inner = vm.new_struct(0, vec![kept, small(1)]);
        let outer = vm.new_struct(0, vec![inner, small(2)]);
        let _garbage = str_val(&mut vm, "garbage");
        let _garbage_struct = vm.new_struct(0, vec![small(3), small(4)]);
        vm.temp_roots.push(outer);
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
        let s = str_val(&mut vm, text);
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
        assert_ne!(rt_short_to_str(&mut *vm, 97), rt_short_to_str(&mut *vm, 97));
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
            let s = str_val(&mut vm, text);
            let n = text.chars().count();
            for from in 0..=n {
                for to in from..=(from + 1).min(n) {
                    let short = rt_str_slice_short(&mut *vm, s, small(from as i64), small(to as i64));
                    let sub = rt_substr(&mut *vm, s, small(from as i64), small(to as i64));
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
        let s = str_val(&mut vm, "hello world");
        rt_substr(&mut *vm, s, small(2), small(5));
        assert_eq!(vm.metrics.utf8_seek_bytes, 0);
    }

    #[test]
    fn substr_non_ascii_records_seek_bytes_to_the_start_offset() {
        let mut vm = vm();
        // Every character is U+00E9 (2 bytes): character index 3 has byte offset
        // is exactly 6.
        let s = str_val(&mut vm, &"\u{e9}".repeat(10));
        rt_substr(&mut *vm, s, small(3), small(4));
        assert_eq!(vm.metrics.utf8_seek_bytes, 6);
    }

    #[test]
    fn substr_non_ascii_seek_grows_with_start_index() {
        let mut vm = vm();
        let s = str_val(&mut vm, &"\u{e9}".repeat(50));
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
        let base = str_val(&mut vm, &"\u{e9}".repeat(10));
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
        let list = vm.new_list(vec![small(10), small(20)]);
        assert_eq!(small_of(rt_list_get(&mut *vm, list, small(1))), 20);
        assert_eq!(vm.declared_error, 0);
        let arr = rt_mutarray_allocate(&mut *vm, small(2));
        rt_mutarray_set(&mut *vm, arr, small(0), small(7));
        assert_eq!(small_of(rt_mutarray_get(&mut *vm, arr, small(0))), 7);
        let big = vm.new_big(num_bigint::BigInt::from(1u8) << 80);
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

    // The *proven helpers (hir/completions.tcl's bounds proof, PROOF-FACT-
    // CENSUS.md G1) are the checked helpers minus the checks: on every valid
    // index or slice they must produce exactly what the checked one does.

    #[test]
    fn proven_helpers_agree_with_checked_ones_on_valid_bounds() {
        let mut vm = vm();
        let list = vm.new_list(vec![small(10), small(20), small(30)]);
        for i in 0..3 {
            assert_eq!(rt_list_get_proven(&mut *vm, list, small(i)), rt_list_get(&mut *vm, list, small(i)));
        }
        let arr = rt_mutarray_allocate(&mut *vm, small(4));
        for i in 0..4 {
            assert_eq!(rt_mutarray_set_proven(&mut *vm, arr, small(i), small(i * 5)), UNIT);
            assert_eq!(small_of(rt_mutarray_get_proven(&mut *vm, arr, small(i))), i * 5);
            assert_eq!(rt_mutarray_get_proven(&mut *vm, arr, small(i)), rt_mutarray_get(&mut *vm, arr, small(i)));
        }
        for text in ["hello", "\u{e9}t\u{e9}", "a\u{3bb}\u{1f600}\u{732b}z", ""] {
            let s = str_val(&mut vm, text);
            let n = text.chars().count() as i64;
            for from in 0..=n {
                for to in from..=n {
                    let checked = rt_substr(&mut *vm, s, small(from), small(to));
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
                    let a = rt_mutarray_allocate(&mut *vm, small(4));
                    let b = rt_mutarray_allocate(&mut *vm, small(4));
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
            let checked = rt_mutarray_freeze(&mut *vm, arr, small(count));
            let proven = rt_mutarray_freeze_proven(&mut *vm, arr, small(count));
            assert_eq!(list_of(proven).items(), list_of(checked).items());
        }
        assert_eq!(vm.declared_error, 0);
    }

    // The slice rule (check_slice, core::native::checkSlice): START against
    // 0..N first, then END against START..N; below is LowerUnderrun, above
    // is UpperOverrun. Writes through an index are IndexNotFound.

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
        let s = str_val(&mut vm, "abc");
        let neg_big = vm.new_big(-(num_bigint::BigInt::from(1u8) << 80usize));
        let pos_big = vm.new_big(num_bigint::BigInt::from(1u8) << 80usize);
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

        let arr = rt_mutarray_allocate(&mut *vm, small(2));
        let big = rt_mutarray_allocate(&mut *vm, small(5));
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
                let a = match i64::try_from(x) {
                    Ok(n) => vm.new_int(n),
                    Err(_) => vm.new_big(x.clone()),
                };
                let b = vm.new_int(k as i64);
                let shl = rt_int_shl(p, a, b);
                assert_eq!(int_to_big(shl), x << (k as usize), "{x} << {k}");
                let shr = rt_int_shr(p, a, b);
                assert_eq!(int_to_big(shr), x >> (k as usize), "{x} >> {k}");
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
}
