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
//! | rt_int_cmp             | Int, Int            | -1/0/1 (raw i64)             | no        |
//! | rt_value_eq            | any, any            | Bool; EQUALITY on callables  | no        |
//! | rt_str_eq              | Str, Str            | Bool                         | no        |
//! | rt_hash                | any                 | Int (61-bit); EQUALITY       | no        |
//! | rt_str_len             | Str                 | Int                          | no        |
//! | rt_substr              | Str, Int, Int       | Str; RANGE                   | yes       |
//! | rt_str_decode_char_at  | Str, Int(byte off.) | one-char Str                 | yes       |
//! | rt_str_byte_len        | Str                 | Int (UTF-8 byte length)      | no        |
//! | rt_str_lower           | Str                 | Str                          | yes       |
//! | rt_str_cat             | Str, Str            | Str                          | yes       |
//! | rt_str_utf8_bytes      | Str                 | List of Int (0..255); RANGE  | yes       |
//! | rt_is_tcl_alpha        | Str (1 scalar)      | Bool; RANGE if not 1 scalar  | no        |
//! | rt_is_tcl_alnum        | Str (1 scalar)      | Bool; RANGE if not 1 scalar  | no        |
//! | rt_list_new            | count, *Value       | List                         | yes       |
//! | rt_list_len            | List                | Int                          | no        |
//! | rt_list_get            | List, Int           | element; RANGE               | no        |
//! | rt_list_append         | List, any           | new List (copy)              | yes       |
//! | rt_mutarray_allocate   | count                | MutableArray (slots = UNIT)  | yes       |
//! | rt_mutarray_capacity   | MutableArray         | Int                          | no        |
//! | rt_mutarray_get        | MutableArray, Int    | element; RANGE               | no        |
//! | rt_mutarray_set        | MutableArray,Int,any | Unit; RANGE                  | no        |
//! | rt_mutarray_copy       | dst,i,src,i,count    | Unit; RANGE                  | no        |
//! | rt_mutarray_freeze     | MutableArray, Int    | List (copy); RANGE           | yes       |
//! | rt_is_kind             | any, kind code      | Bool                         | no        |
//! | rt_is_result           | any, 1 ok / 0 error | Bool                         | no        |
//! | rt_result_payload      | Result, 1/0         | payload; TYPE if wrong tag   | no        |
//! | rt_result_new          | 1/0, any            | Result                       | yes       |
//! | rt_cell_new            |                     | unbound Cell                 | yes       |
//! | rt_closure_new         | fn, code, n, *Value | Block                        | yes       |
//! | rt_call_value          | callee, n, *Value   | call result; ARITY,          | callee    |
//! |                        |                     | NOT-CALLABLE, callee errors  |           |
//! | rt_type_error          | value, kind, ctx    | records TYPE, returns 0      | no        |
//! | rt_not_boolean         | value               | records NOT-BOOLEAN          | no        |
//! | rt_unbound             | name Str            | records UNBOUND              | no        |
//! | rt_raise               | kind Str, msg Str   | records a semantic error     | no        |
//! | rt_stack_overflow      |                     | records NATIVE LIMIT STACK   | no        |

use super::error::{semantic_kind, RtError};
use super::value::*;
use super::vm::{Vm, NativeInfo};
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
        IAdd | ISub | IMul | Substr | DecodeCharAt | StrLower | StrCat | StrUtf8Bytes | ListNew
            | ListAppend | MutArrayAllocate | MutArrayFreeze | MkOk | MkError
    )
}

pub type GenericEntry = extern "C" fn(*mut Vm, Value, *const Value) -> Value;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

// ---------------------------------------------------------------------------
// Errors

pub extern "C" fn rt_type_error(p: *mut Vm, v: Value, kind: u64, context: Value) -> Value {
    let context = str_of(context).text.to_string();
    vm(p).fail(RtError::Type { context, expected: Kind::from_code(kind as u8), got: v })
}

pub extern "C" fn rt_not_boolean(p: *mut Vm, v: Value) -> Value {
    vm(p).fail(RtError::NotBoolean { got: v })
}

pub extern "C" fn rt_unbound(p: *mut Vm, name: Value) -> Value {
    let message = format!("name \"{}\" used before its binding", str_of(name).text);
    vm(p).fail(RtError::Semantic { kind: "UNBOUND", message })
}

pub extern "C" fn rt_raise(p: *mut Vm, kind: Value, message: Value) -> Value {
    let kind_text = &str_of(kind).text;
    let message = str_of(message).text.to_string();
    let error = match semantic_kind(kind_text) {
        Some(kind) => RtError::Semantic { kind, message },
        None if &**kind_text == "BUG" => RtError::Bug(message),
        None => RtError::Bug(format!("unknown error kind {kind_text}: {message}")),
    };
    vm(p).fail(error)
}

pub extern "C" fn rt_stack_overflow(p: *mut Vm) -> Value {
    vm(p).fail(RtError::StackOverflow)
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

pub extern "C" fn rt_int_add(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, i64::checked_add, |x, y| x + y)
}

pub extern "C" fn rt_int_sub(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, i64::checked_sub, |x, y| x - y)
}

pub extern "C" fn rt_int_mul(p: *mut Vm, a: Value, b: Value) -> Value {
    int_binary(p, a, b, i64::checked_mul, |x, y| x * y)
}

/// Euclidean modulo (core/primitives.tcl's modulo): 0 <= result < |b|,
/// regardless of the sign of a or b. Native `%` (small i64, or BigInt) may
/// follow either sign convention -- whichever it picks, "if the result is
/// negative, add |b|" always lands on the unique representative in [0, |b|)
/// congruent to a mod b, so both paths agree with each other and with the
/// reference interpreter's identical fixup (core::primitives::modulo).
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

fn int_compare(a: Value, b: Value) -> Ordering {
    match (int_small(a), int_small(b)) {
        (Some(x), Some(y)) => x.cmp(&y),
        _ => int_to_big(a).cmp(&int_to_big(b)),
    }
}

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
        Kind::Int => a == b || (!is_small(a) && !is_small(b) && int_compare(a, b) == Ordering::Equal),
        Kind::Str => str_of(a).text == str_of(b).text,
        Kind::Bool => a == b,
        Kind::Unit => true,
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
        Kind::Block | Kind::Native | Kind::MutArray => unreachable!(),
    })
}

pub extern "C" fn rt_value_eq(p: *mut Vm, a: Value, b: Value) -> Value {
    match equal(p, a, b) {
        Ok(r) => bool_value(r),
        Err(()) => NO_VALUE,
    }
}

pub extern "C" fn rt_str_eq(_p: *mut Vm, a: Value, b: Value) -> Value {
    bool_value(str_of(a).text == str_of(b).text)
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
    // bool unit list result -> 0 1 2 3 4 5), so e.g. Int 1 and Str "1" never
    // collide by coincidence of payload bytes alone.
    let tag = match kind {
        Kind::Int => 0u8,
        Kind::Str => 1,
        Kind::Bool => 2,
        Kind::Unit => 3,
        Kind::List => 4,
        Kind::Result => 5,
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
        Kind::Str => fnv1a(h, str_of(v).text.as_bytes()),
        Kind::Bool => fnv1a(h, &[(v == TRUE) as u8]),
        Kind::Unit => h,
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
        Kind::Block | Kind::Native | Kind::MutArray => unreachable!(),
    })
}

pub extern "C" fn rt_hash(p: *mut Vm, v: Value) -> Value {
    match hash_mix(p, FNV_OFFSET, v) {
        Ok(h) => vm(p).new_int((h & HASH_MASK) as i64),
        Err(()) => NO_VALUE,
    }
}

// ---------------------------------------------------------------------------
// Strings (indices count characters: Unicode scalar values)

pub extern "C" fn rt_str_len(p: *mut Vm, s: Value) -> Value {
    vm(p).new_int(str_of(s).chars as i64)
}

pub extern "C" fn rt_substr(p: *mut Vm, s: Value, start: Value, end: Value) -> Value {
    let obj = str_of(s);
    let len = obj.chars as i64;
    let (from, to) = match (int_small(start), int_small(end)) {
        (Some(from), Some(to)) if from >= 0 && from <= to && to <= len => (from as usize, to as usize),
        _ => {
            // Outside the range (big Ints always are): the reference message.
            let (from, to) = (int_to_big(start), int_to_big(end));
            let message = format!("substring: range {from}..{to} is outside 0..{len}");
            return vm(p).fail(RtError::Semantic { kind: "RANGE", message });
        }
    };
    if obj.ascii {
        let text = obj.text[from..to].to_string();
        let bytes = text.len();
        let r = vm(p).new_str_known(text, to - from, true);
        vm(p).metrics.record_string_copy(bytes);
        return r;
    }
    // Non-ASCII: character index `from` is not a byte offset, so it must be
    // located by decoding forward from byte 0 -- the seek this milestone's
    // traversal optimization (hir/traversal.tcl, native/lower.tcl's "String
    // traversal" section) exists to avoid paying on every element of a
    // monotonic scan. `utf8SeekBytes` counts exactly this: the UTF-8 source
    // bytes walked here to map a semantic character index to a physical
    // byte offset, not the copy that follows (record_string_copy, separate).
    let mut indices = obj.text.char_indices();
    let seek_start = indices.by_ref().nth(from).map_or(obj.text.len(), |(i, _)| i);
    vm(p).metrics.record_utf8_seek(seek_start);
    let text: String = obj.text[seek_start..].chars().take(to - from).collect();
    let bytes = text.len();
    let r = vm(p).new_str(text);
    vm(p).metrics.record_string_copy(bytes);
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
/// allocating: UNIT on success, RANGE (matching `rt_substr`'s own message)
/// on failure. Strings are immutable, so a region proven valid here stays
/// valid for as long as its registers are live -- no re-check is ever needed
/// at a consumer.
pub extern "C" fn rt_str_region_check(p: *mut Vm, s: Value, start: Value, end: Value) -> Value {
    let obj = str_of(s);
    let len = obj.chars as i64;
    match (int_small(start), int_small(end)) {
        (Some(from), Some(to)) if from >= 0 && from <= to && to <= len => UNIT,
        _ => {
            let (from, to) = (int_to_big(start), int_to_big(end));
            let message = format!("substring: range {from}..{to} is outside 0..{len}");
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

/// BASE\[START..END) (a region `rt_str_region_check` already validated)
/// compared character-for-character against OTHER, with no allocation.
/// Never fallible.
pub extern "C" fn rt_str_region_eq(p: *mut Vm, base: Value, start: Value, end: Value, other: Value) -> Value {
    let b = str_of(base);
    let o = str_of(other);
    let from = int_small(start).expect("region start already validated") as usize;
    let to = int_small(end).expect("region end already validated") as usize;
    if to - from != o.chars {
        return bool_value(false);
    }
    if b.ascii {
        bool_value(b.text.as_bytes()[from..to] == *o.text.as_bytes())
    } else {
        // Same seek accounting as rt_substr's non-ASCII path: locating
        // character index `from` still means decoding forward from byte 0.
        let mut indices = b.text.char_indices();
        let seek_start = indices.by_ref().nth(from).map_or(b.text.len(), |(i, _)| i);
        vm(p).metrics.record_utf8_seek(seek_start);
        bool_value(b.text[seek_start..].chars().take(to - from).eq(o.text.chars()))
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
pub extern "C" fn rt_str_decode_char_at(p: *mut Vm, s: Value, byte_offset: Value) -> Value {
    let obj = str_of(s);
    let off = int_small(byte_offset).expect("decode_char_at: byte_offset must be a small Int") as usize;
    let c = obj.text[off..]
        .chars()
        .next()
        .expect("decode_char_at: byte_offset must be a valid, in-bounds UTF-8 boundary");
    vm(p).new_str_known(c.to_string(), 1, c.is_ascii())
}

/// The UTF-8 byte length of S's text -- distinct from `rt_str_len`, which
/// counts Unicode scalars. A plain field read (StrObj::text.len()), never a
/// scan: applied to `rt_str_decode_char_at`'s own result, this gives the
/// encoded width of the scalar just decoded, letting a traversal advance its
/// carried byte offset by exactly that many bytes.
pub extern "C" fn rt_str_byte_len(p: *mut Vm, s: Value) -> Value {
    vm(p).new_int(str_of(s).text.len() as i64)
}

pub extern "C" fn rt_str_lower(p: *mut Vm, s: Value) -> Value {
    // Simple (one-to-one) case mapping, like Tcl's string tolower.
    let text: String = str_of(s)
        .text
        .chars()
        .map(|c| {
            let mut lower = c.to_lowercase();
            match (lower.next(), lower.next()) {
                (Some(l), None) => l,
                _ => c,
            }
        })
        .collect();
    let bytes = text.len();
    let r = vm(p).new_str(text);
    vm(p).metrics.record_string_copy(bytes);
    r
}

/// S's UTF-8 encoding as a List of Ints (one per byte, each 0..255), in
/// order (core/strings.tcl's `encode_utf8`): S's text is already a Rust
/// `String`, so it is already valid UTF-8 -- this is a plain byte-by-byte
/// read, never a re-encode. The general byte-level access String otherwise
/// never exposes (see nir.rs's StrUtf8Bytes doc comment). Reuses
/// `Vm::new_list`'s own MAX_COLLECTION_LENGTH check (same limit any other
/// List/String construction enforces), so an oversized result fails RANGE
/// exactly like `rt_list_new`'s would, not a special case here.
pub extern "C" fn rt_str_utf8_bytes(p: *mut Vm, s: Value) -> Value {
    let items: Vec<Value> = str_of(s).text.bytes().map(|b| vm(p).new_int(b as i64)).collect();
    let n = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_list_copy(n);
    r
}

pub extern "C" fn rt_str_cat(p: *mut Vm, a: Value, b: Value) -> Value {
    let (x, y) = (str_of(a), str_of(b));
    let mut text = String::with_capacity(x.text.len() + y.text.len());
    text.push_str(&x.text);
    text.push_str(&y.text);
    // The character count and ASCII flag follow from the operands: no rescan.
    let (chars, ascii) = (x.chars + y.chars, x.ascii && y.ascii);
    let bytes = text.len();
    let r = vm(p).new_str_known(text, chars, ascii);
    vm(p).metrics.record_string_copy(bytes);
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
/// matching `rt_substr`'s RANGE convention for an out-of-domain argument
/// rather than silently classifying just the first character of a longer
/// string, or of the empty string).
fn one_scalar(p: *mut Vm, s: Value, native: &str) -> Result<char, Value> {
    let obj = str_of(s);
    if obj.chars != 1 {
        let message = format!("{native}: expects a single Unicode scalar, got a string of length {}", obj.chars);
        return Err(vm(p).fail(RtError::Semantic { kind: "RANGE", message }));
    }
    Ok(obj.text.chars().next().expect("StrObj.chars == 1 but text has no scalar"))
}

pub extern "C" fn rt_is_tcl_alpha(p: *mut Vm, s: Value) -> Value {
    match one_scalar(p, s, "is_tcl_alpha") {
        Ok(c) => bool_value(tcl_alpha_char(c)),
        Err(no_value) => no_value,
    }
}

pub extern "C" fn rt_is_tcl_alnum(p: *mut Vm, s: Value) -> Value {
    match one_scalar(p, s, "is_tcl_alnum") {
        Ok(c) => bool_value(tcl_alnum_char(c)),
        Err(no_value) => no_value,
    }
}

// ---------------------------------------------------------------------------
// Lists

pub extern "C" fn rt_list_new(p: *mut Vm, n: u64, items: *const Value) -> Value {
    let items = unsafe { std::slice::from_raw_parts(items, n as usize) }.to_vec();
    let elements = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_list_copy(elements);
    r
}

pub extern "C" fn rt_list_len(p: *mut Vm, l: Value) -> Value {
    vm(p).new_int(list_of(l).len as i64)
}

pub extern "C" fn rt_list_get(p: *mut Vm, l: Value, index: Value) -> Value {
    let items = list_of(l).items();
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < items.len() => items[i as usize],
        _ => {
            let message =
                format!("list_get: index {} is outside 0..{}", int_to_big(index), items.len() as i64 - 1);
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

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

pub extern "C" fn rt_mutarray_allocate(p: *mut Vm, capacity: Value) -> Value {
    match int_small(capacity) {
        Some(n) if n >= 0 => vm(p).new_mutarray(n as usize),
        _ => {
            let message = format!(
                "mutable_array_allocate: capacity must be 0..{MAX_COLLECTION_LENGTH}, got {}",
                int_to_big(capacity)
            );
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

pub extern "C" fn rt_mutarray_capacity(p: *mut Vm, arr: Value) -> Value {
    vm(p).new_int(mutarray_of(arr).slots.len() as i64)
}

pub extern "C" fn rt_mutarray_get(p: *mut Vm, arr: Value, index: Value) -> Value {
    let slots = &mutarray_of(arr).slots;
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < slots.len() => {
            let v = slots[i as usize];
            vm(p).metrics.record_mutarray_read();
            v
        }
        _ => {
            let message =
                format!("mutable_array_get: index {} is outside 0..{}", int_to_big(index), slots.len() as i64 - 1);
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

pub extern "C" fn rt_mutarray_set(p: *mut Vm, arr: Value, index: Value, value: Value) -> Value {
    let obj = mutarray_of_mut(arr);
    match int_small(index) {
        Some(i) if i >= 0 && (i as usize) < obj.slots.len() => {
            obj.slots[i as usize] = value;
            vm(p).metrics.record_mutarray_write();
            UNIT
        }
        _ => {
            let len = obj.slots.len();
            let message = format!("mutable_array_set: index {} is outside 0..{}", int_to_big(index), len as i64 - 1);
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

fn invalid_copy_range(p: *mut Vm, dst: Value, dst_start: Value, src: Value, src_start: Value, count: Value) -> Value {
    let dst_len = mutarray_of(dst).slots.len();
    let src_len = mutarray_of(src).slots.len();
    let message = format!(
        "mutable_array_copy: range dstStart={}, srcStart={}, count={} is invalid for dst capacity {dst_len}, src capacity {src_len}",
        int_to_big(dst_start), int_to_big(src_start), int_to_big(count)
    );
    vm(p).fail(RtError::Semantic { kind: "RANGE", message })
}

/// Bulk copy: COUNT elements of SRC starting at SRC_START into DST starting
/// at DST_START. Uses `ptr::copy` (memmove semantics), so DST and SRC may be
/// the same MutableArray with overlapping ranges: the result is always as if
/// SRC's elements were read before any of DST's were written.
pub extern "C" fn rt_mutarray_copy(p: *mut Vm, dst: Value, dst_start: Value, src: Value, src_start: Value, count: Value) -> Value {
    let (ds, ss, n) = match (int_small(dst_start), int_small(src_start), int_small(count)) {
        (Some(ds), Some(ss), Some(n)) if ds >= 0 && ss >= 0 && n >= 0 => (ds, ss, n),
        _ => return invalid_copy_range(p, dst, dst_start, src, src_start, count),
    };
    let dst_len = mutarray_of(dst).slots.len() as i64;
    let src_len = mutarray_of(src).slots.len() as i64;
    let in_range = |start: i64, len: i64| start.checked_add(n).is_some_and(|end| end <= len);
    if !in_range(ds, dst_len) || !in_range(ss, src_len) {
        return invalid_copy_range(p, dst, dst_start, src, src_start, count);
    }
    if n > 0 {
        let dst_ptr = mutarray_of_mut(dst).slots.as_mut_ptr();
        let src_ptr = mutarray_of(src).slots.as_ptr();
        unsafe { std::ptr::copy(src_ptr.add(ss as usize), dst_ptr.add(ds as usize), n as usize) };
        vm(p).metrics.record_mutarray_copy(n as usize);
    }
    UNIT
}

/// Final immutable storage creation (milestone architecture item #2): a new
/// List of ARR's first COUNT elements. This is substrate, not policy -- it
/// is the one way a MutableArray's contents become an ordinary immutable
/// List; growth/chunking policy is entirely the caller's (ordinary Botlish).
/// Always copies (req #18): a future zero-copy freeze (req #19), proving ARR
/// is uniquely owned and never mutated again, is left open, not implemented.
pub extern "C" fn rt_mutarray_freeze(p: *mut Vm, arr: Value, count: Value) -> Value {
    let slots = &mutarray_of(arr).slots;
    match int_small(count) {
        Some(n) if n >= 0 && (n as usize) <= slots.len() => {
            let items = slots[..n as usize].to_vec();
            let elements = items.len();
            let r = vm(p).new_list(items);
            vm(p).metrics.record_mutarray_copy(elements);
            r
        }
        _ => {
            let message =
                format!("mutable_array_freeze: count {} is outside 0..{}", int_to_big(count), slots.len());
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

// ---------------------------------------------------------------------------
// Kinds and Results

pub extern "C" fn rt_is_kind(_p: *mut Vm, v: Value, kind: u64) -> Value {
    bool_value(kind_of(v).code() as u64 == kind)
}

pub extern "C" fn rt_is_result(_p: *mut Vm, v: Value, ok: u64) -> Value {
    bool_value(heap_kind(v) == KIND_RESULT && result_of(v).ok == (ok != 0))
}

pub extern "C" fn rt_result_payload(p: *mut Vm, v: Value, ok: u64) -> Value {
    let r = result_of(v);
    if r.ok != (ok != 0) {
        let context = if ok != 0 { "result-value" } else { "result-error" };
        return vm(p).fail(RtError::ResultTag { context, expected_ok: ok != 0, got: v });
    }
    r.payload
}

pub extern "C" fn rt_result_new(p: *mut Vm, ok: u64, v: Value) -> Value {
    vm(p).new_result(ok != 0, v)
}

// ---------------------------------------------------------------------------
// Cells and closures

pub extern "C" fn rt_cell_new(p: *mut Vm) -> Value {
    vm(p).alloc(CellObj { hdr: Header::new(KIND_CELL, false), value: UNBOUND }, 0)
}

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
        StrIsTclAlpha => rt_is_tcl_alpha(p, a[0]),
        StrIsTclAlnum => rt_is_tcl_alnum(p, a[0]),
        ListLen => rt_list_len(p, a[0]),
        ListGet => rt_list_get(p, a[0], a[1]),
        ListAppend => rt_list_append(p, a[0], a[1]),
        MutArrayAllocate => rt_mutarray_allocate(p, a[0]),
        MutArrayCapacity => rt_mutarray_capacity(p, a[0]),
        MutArrayGet => rt_mutarray_get(p, a[0], a[1]),
        MutArraySet => rt_mutarray_set(p, a[0], a[1], a[2]),
        MutArrayCopy => rt_mutarray_copy(p, a[0], a[1], a[2], a[3], a[4]),
        MutArrayFreeze => rt_mutarray_freeze(p, a[0], a[1]),
        IsInt => rt_is_kind(p, a[0], Kind::Int.code() as u64),
        IsStr => rt_is_kind(p, a[0], Kind::Str.code() as u64),
        IsList => rt_is_kind(p, a[0], Kind::List.code() as u64),
        IsOk => rt_is_result(p, a[0], 1),
        IsError => rt_is_result(p, a[0], 0),
        ResultValue => rt_result_payload(p, a[0], 1),
        ResultError => rt_result_payload(p, a[0], 0),
        MkOk => rt_result_new(p, 1, a[0]),
        MkError => rt_result_new(p, 0, a[0]),
        Hash => rt_hash(p, a[0]),
        RegionCheck | RegionEq | RBox | RUnbox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq
        | DecodeCharAt | StrByteLen => {
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
        h!(rt_unbound, 2),
        h!(rt_raise, 3),
        h!(rt_stack_overflow, 1),
        h!(rt_int_add, 3),
        h!(rt_int_sub, 3),
        h!(rt_int_mul, 3),
        h!(rt_int_mod, 3),
        h!(rt_int_cmp, 3),
        h!(rt_value_eq, 3),
        h!(rt_str_eq, 3),
        h!(rt_hash, 2),
        h!(rt_str_len, 2),
        h!(rt_substr, 4),
        h!(rt_str_region_check, 4),
        h!(rt_str_region_eq, 5),
        h!(rt_str_decode_char_at, 3),
        h!(rt_str_byte_len, 2),
        h!(rt_str_lower, 2),
        h!(rt_str_cat, 3),
        h!(rt_str_utf8_bytes, 2),
        h!(rt_is_tcl_alpha, 2),
        h!(rt_is_tcl_alnum, 2),
        h!(rt_list_new, 3),
        h!(rt_list_len, 2),
        h!(rt_list_get, 3),
        h!(rt_list_append, 3),
        h!(rt_mutarray_allocate, 2),
        h!(rt_mutarray_capacity, 2),
        h!(rt_mutarray_get, 3),
        h!(rt_mutarray_set, 4),
        h!(rt_mutarray_copy, 6),
        h!(rt_mutarray_freeze, 3),
        h!(rt_is_kind, 3),
        h!(rt_is_result, 3),
        h!(rt_result_payload, 3),
        h!(rt_result_new, 3),
        h!(rt_cell_new, 1),
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
        Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new() }), AllocMode::Summary)
    }

    fn str_val(vm: &mut Vm, s: &str) -> Value {
        vm.new_str(s.to_string())
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
        assert_eq!(str_of(c).text.as_ref(), "e");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(1));
    }

    #[test]
    fn decode_char_at_two_byte() {
        let mut vm = vm();
        // "é" is U+00E9, 2 bytes in UTF-8.
        let s = str_val(&mut vm, "a\u{e9}b");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).text.as_ref(), "\u{e9}");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(2));
    }

    #[test]
    fn decode_char_at_three_byte() {
        let mut vm = vm();
        // "東" is U+6771, 3 bytes in UTF-8.
        let s = str_val(&mut vm, "a\u{6771}b");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).text.as_ref(), "\u{6771}");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(3));
    }

    #[test]
    fn decode_char_at_four_byte() {
        let mut vm = vm();
        // U+1F600 (grinning face) is 4 bytes in UTF-8.
        let s = str_val(&mut vm, "a\u{1f600}b");
        let c = rt_str_decode_char_at(&mut *vm, s, small(1));
        assert_eq!(str_of(c).text.as_ref(), "\u{1f600}");
        assert_eq!(rt_str_byte_len(&mut *vm, c), small(4));
    }

    #[test]
    fn decode_char_at_mixed_width_sequence() {
        // A|é|東|🙂|A: verify each character decodes correctly by carrying
        // the byte offset forward exactly as native/lower.tcl's optimized
        // loop would (byte_i += strbytelen(decoded)), never seeking.
        let mut vm = vm();
        let text = "A\u{e9}\u{6771}\u{1f642}A";
        let s = str_val(&mut vm, text);
        let mut byte_offset = 0i64;
        let expected: Vec<char> = text.chars().collect();
        for want in expected {
            let c = rt_str_decode_char_at(&mut *vm, s, small(byte_offset));
            let got: Vec<char> = str_of(c).text.chars().collect();
            assert_eq!(got, vec![want]);
            let width = rt_str_byte_len(&mut *vm, c);
            byte_offset += small_of(width);
        }
        assert_eq!(byte_offset as usize, str_of(s).text.len());
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
        // Every character is 2 bytes ("é"): character index 3's byte offset
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
}
