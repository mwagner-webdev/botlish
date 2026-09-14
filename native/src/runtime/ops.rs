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
//! | rt_int_cmp             | Int, Int            | -1/0/1 (raw i64)             | no        |
//! | rt_value_eq            | any, any            | Bool; EQUALITY on callables  | no        |
//! | rt_str_eq              | Str, Str            | Bool                         | no        |
//! | rt_str_len             | Str                 | Int                          | no        |
//! | rt_substr              | Str, Int, Int       | Str; RANGE                   | yes       |
//! | rt_str_lower           | Str                 | Str                          | yes       |
//! | rt_str_cat             | Str, Str            | Str                          | yes       |
//! | rt_list_new            | count, *Value       | List                         | yes       |
//! | rt_list_len            | List                | Int                          | no        |
//! | rt_list_get            | List, Int           | element; RANGE               | no        |
//! | rt_list_append         | List, any           | new List (copy)              | yes       |
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
use std::cmp::Ordering;

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
    if matches!(ka, Kind::Block | Kind::Native) || matches!(kb, Kind::Block | Kind::Native) {
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
            let (xs, ys) = (&list_of(a).items, &list_of(b).items);
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
        Kind::Block | Kind::Native => unreachable!(),
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
    let text: String = obj.text.chars().skip(from).take(to - from).collect();
    let bytes = text.len();
    let r = vm(p).new_str(text);
    vm(p).metrics.record_string_copy(bytes);
    r
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
// Lists

pub extern "C" fn rt_list_new(p: *mut Vm, n: u64, items: *const Value) -> Value {
    let items = unsafe { std::slice::from_raw_parts(items, n as usize) }.to_vec();
    let elements = items.len();
    let r = vm(p).new_list(items);
    vm(p).metrics.record_list_copy(elements);
    r
}

pub extern "C" fn rt_list_len(p: *mut Vm, l: Value) -> Value {
    vm(p).new_int(list_of(l).items.len() as i64)
}

pub extern "C" fn rt_list_get(p: *mut Vm, l: Value, index: Value) -> Value {
    let items = &list_of(l).items;
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
    let old = &list_of(l).items;
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
        ListLen => rt_list_len(p, a[0]),
        ListGet => rt_list_get(p, a[0], a[1]),
        ListAppend => rt_list_append(p, a[0], a[1]),
        IsInt => rt_is_kind(p, a[0], Kind::Int.code() as u64),
        IsStr => rt_is_kind(p, a[0], Kind::Str.code() as u64),
        IsList => rt_is_kind(p, a[0], Kind::List.code() as u64),
        IsOk => rt_is_result(p, a[0], 1),
        IsError => rt_is_result(p, a[0], 0),
        ResultValue => rt_result_payload(p, a[0], 1),
        ResultError => rt_result_payload(p, a[0], 0),
        MkOk => rt_result_new(p, 1, a[0]),
        MkError => rt_result_new(p, 0, a[0]),
        RBox | RUnbox | RIAdd | RISub | RIMul | RILt | RILe | RIGt | RIGe | RIEq => {
            // Raw (untagged) representation ops never implement a dynamic
            // native: native/lower.tcl emits them only directly, as `op`
            // instructions inline in a function's own body.
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
        h!(rt_int_cmp, 3),
        h!(rt_value_eq, 3),
        h!(rt_str_eq, 3),
        h!(rt_str_len, 2),
        h!(rt_substr, 4),
        h!(rt_str_lower, 2),
        h!(rt_str_cat, 3),
        h!(rt_list_new, 3),
        h!(rt_list_len, 2),
        h!(rt_list_get, 3),
        h!(rt_list_append, 3),
        h!(rt_is_kind, 3),
        h!(rt_is_result, 3),
        h!(rt_result_payload, 3),
        h!(rt_result_new, 3),
        h!(rt_cell_new, 1),
        h!(rt_closure_new, 5),
        h!(rt_call_value, 4),
    ]
}
