//! The runtime side of C calls (C-FFI.md): the few conversions a
//! `foreigncall` (nir.rs) cannot do inline, and its two failures.
//!
//! A C call itself is no helper: codegen::clif converts the operands to
//! their C ABI classes, calls the linked symbol directly with the platform C
//! calling convention, and converts the result back. Only these slow paths
//! leave generated code:
//!
//! * a 64-bit C integer argument held as a BigInt (`rt_ffi_int_word`: its
//!   two's-complement word; the static check proved it fits the C type);
//! * a 64-bit C integer result outside the small-Int range
//!   (`rt_ffi_box_i64`, `rt_ffi_box_u64`: a BigInt), when its C word
//!   (nir.rs's `cwbox`) is boxed -- at the first use that needs the Int,
//!   never merely because C returned it (C-FFI-ERROR-CAPTURE-MILESTONE-2.md);
//! * a C word compared with a BigInt (`rt_ffi_word_cmp`): exact, and with
//!   no allocation, so a comparison never changes the C error state;
//! * a returned address the C address word cannot hold
//!   (`rt_ffi_bad_address`): a NATIVE ADDRESS failure, never a masked or
//!   truncated pointer -- every canonical x86-64 address and every untagged
//!   AArch64 one fits; an AArch64 top-byte-tagged one does not;
//! * a C `_Bool` result whose byte is neither 0 nor 1 (`rt_ffi_bad_bool`):
//!   a NATIVE BOOL failure. The platform ABIs (x86-64 SysV, AAPCS64) define
//!   a `_Bool` result as one byte holding 0 or 1, the register's other bits
//!   unspecified; any other byte is no `_Bool` a C compiler returns, so the
//!   declaration does not describe the function, and no Botlish bool is
//!   made up from it;
//! * a pointer result whose contract says it is exactly a pointer argument
//!   (`alias`) but is not (`rt_ffi_contract_violation`): the development
//!   assertion of the binding's contract, a CONTRACT-VIOLATION failure.
//!
//! None of them names a symbol, opens a library or looks anything up: link
//! symbols are resolved when the program is linked.
use super::error::RtError;
use super::value::*;
use super::vm::Vm;
use num_bigint::BigInt;
use num_traits::ToPrimitive;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    // SAFETY: generated code passes the Vm pointer it was entered with.
    unsafe { &mut *p }
}

/// The text of the String constant V (a C function's Botlish name).
fn text_of(v: Value) -> String {
    let shown = super::show::show(v);
    shown.strip_prefix('"').and_then(|s| s.strip_suffix('"')).map(str::to_string).unwrap_or(shown)
}

/// The two's-complement 64-bit word of the Int V: a C `long`, `long long`
/// or their unsigned forms (the caller's static proof keeps V inside the
/// C type's range, so one of the two conversions holds). Never fails and
/// never allocates.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_int_word(_p: *mut Vm, v: Value) -> u64 {
    if let Some(i) = int_small(v) {
        return i as u64;
    }
    // Borrowed: no copy of the BigInt is made.
    let n: &BigInt = big_of(v);
    match n.to_i64() {
        Some(i) => i as u64,
        None => n.to_u64().unwrap_or(0),
    }
}

/// The order (-1, 0, 1) of the C word WORD -- signed when SIGNED is not 0,
/// else unsigned -- against the Int V (a BigInt: generated code compares a
/// small Int inline), exactly, without converting either: no allocation and
/// no copy, so it runs between a C call and the read of its error state
/// (C-FFI-ERROR-CAPTURE-MILESTONE-2.md). A BigInt beyond the word's range is
/// above or below every word by its sign.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_word_cmp(_p: *mut Vm, word: u64, signed: u64, v: Value) -> i64 {
    use std::cmp::Ordering;
    let order = if let Some(x) = int_small(v) {
        if signed != 0 {
            (word as i64).cmp(&x)
        } else if x < 0 {
            Ordering::Greater
        } else {
            word.cmp(&(x as u64))
        }
    } else {
        let n: &BigInt = big_of(v);
        let negative = n.sign() == num_bigint::Sign::Minus;
        if signed != 0 {
            match n.to_i64() {
                Some(x) => (word as i64).cmp(&x),
                None if negative => Ordering::Greater,
                None => Ordering::Less,
            }
        } else if negative {
            Ordering::Greater
        } else {
            match n.to_u64() {
                Some(x) => word.cmp(&x),
                None => Ordering::Less,
            }
        }
    };
    order as i64
}

/// The Int of the signed 64-bit C result N (a BigInt when it is outside the
/// small range).
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_box_i64(p: *mut Vm, n: i64) -> Value {
    vm(p).new_int(n)
}

/// The Int of the unsigned 64-bit C result N.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_box_u64(p: *mut Vm, n: u64) -> Value {
    vm(p).new_big(BigInt::from(n))
}

/// The failure of a C function NAME (a String constant) that returned the
/// address ADDRESS, which no C address word can hold (value.rs: the payload
/// is a sign-extended 60-bit number). Records it and returns NO_VALUE.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_bad_address(p: *mut Vm, name: Value, address: u64) -> Value {
    let name = text_of(name);
    vm(p).fail(RtError::ForeignAddress(format!(
        "the C function {name} returned the address 0x{address:x}, which a Botlish C pointer cannot hold (its word keeps a sign-extended 60-bit address: a top-byte-tagged pointer is not one); the pointer is never truncated or masked"
    )))
}

/// The failure of a C function NAME (a String constant) whose `_Bool` result
/// byte was BYTE, neither 0 nor 1. Records it and returns NO_VALUE.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_bad_bool(p: *mut Vm, name: Value, byte: u64) -> Value {
    let name = text_of(name);
    vm(p).fail(RtError::ForeignBool(format!(
        "the C function {name} returned the byte 0x{:02x} as its _Bool result, which is neither 0 nor 1: no C compiler returns such a _Bool, so its extern c fn declaration does not describe it",
        byte & 0xff
    )))
}

/// The failure of a C function NAME whose contract declares its result
/// exactly its pointer argument (`alias`), at the address EXPECTED, but that
/// returned RETURNED. Records it and returns NO_VALUE: a false contract is
/// the binding's error, reported where it is seen.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_contract_violation(p: *mut Vm, name: Value, expected: u64, returned: u64) -> Value {
    let name = text_of(name);
    vm(p).fail(RtError::ContractViolation(format!(
        "the C function {name} returned 0x{returned:x}, but its extern c fn declaration says its result is exactly its pointer argument (alias), 0x{expected:x}: the binding's contract is false"
    )))
}

/// The address a C function's symbol has in code the JIT compiles only to
/// inspect (codegen/mod.rs): a program that calls C runs as a linked
/// executable, so this is never reached; if it were, it stops the process
/// rather than call anything.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_unlinked() -> u64 {
    eprintln!("a C function was called from JIT code compiled for inspection only (C-FFI.md): a program that calls C runs as a linked executable (NATIVE BUG)");
    std::process::abort();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ffi_int_word_small_and_big() {
        assert_eq!(rt_ffi_int_word(std::ptr::null_mut(), make_small(-5)), (-5i64) as u64);
        assert_eq!(rt_ffi_int_word(std::ptr::null_mut(), make_small(42)), 42);
        assert_eq!(rt_ffi_int_word(std::ptr::null_mut(), big("18446744073709551615")), u64::MAX);
        assert_eq!(rt_ffi_int_word(std::ptr::null_mut(), big("-9223372036854775808")), i64::MIN as u64);
    }

    /// A static BigInt Value of DIGITS (constants.rs's way), never freed.
    fn big(digits: &str) -> Value {
        Box::into_raw(Box::new(BigIntObj { hdr: Header::new(KIND_BIGINT, true), n: digits.parse().unwrap() })) as Value
    }

    /// rt_ffi_word_cmp (C-FFI-ERROR-CAPTURE-MILESTONE-2.md): the order of a
    /// signed or unsigned word against a small Int or a BigInt, exact at
    /// every boundary, BigInts beyond the word's range ordered by sign.
    #[test]
    fn ffi_word_cmp_exact() {
        let p = std::ptr::null_mut();
        let cmp = |word: u64, signed: bool, v: Value| rt_ffi_word_cmp(p, word, signed as u64, v);
        // Unsigned: above every negative Int, exact against u64 values.
        assert_eq!(cmp(0, false, make_small(-1)), 1);
        assert_eq!(cmp(u64::MAX, false, big("18446744073709551615")), 0);
        assert_eq!(cmp(u64::MAX - 1, false, big("18446744073709551615")), -1);
        assert_eq!(cmp(u64::MAX, false, big("18446744073709551616")), -1);
        assert_eq!(cmp(u64::MAX, false, big("-18446744073709551615")), 1);
        assert_eq!(cmp(1 << 62, false, big("4611686018427387904")), 0);
        assert_eq!(cmp(5, false, make_small(5)), 0);
        // Signed: exact against i64 values, BigInts beyond them by sign.
        assert_eq!(cmp(i64::MIN as u64, true, big("-9223372036854775808")), 0);
        assert_eq!(cmp(i64::MIN as u64, true, big("-9223372036854775809")), 1);
        assert_eq!(cmp(i64::MAX as u64, true, big("9223372036854775808")), -1);
        assert_eq!(cmp((-1i64) as u64, true, make_small(-1)), 0);
        assert_eq!(cmp((-1i64) as u64, true, make_small(0)), -1);
        assert_eq!(cmp((-(1i64 << 62) - 1) as u64, true, big("-4611686018427387905")), 0);
    }
}

// ---------------------------------------------------------------------------
// Raw C floating values (RAW-C-FLOAT-FFI-MILESTONE-1.md; core/cabi.tcl's
// "Raw C floating values" is the reference). FORMAT is 0 for binary32
// (std::ffi::c::RawFloat), 1 for binary64 (std::ffi::c::RawDouble). A raw
// value is a FloatObj of its own heap kind holding the bits as they are:
// these helpers never admit, narrow or normalize anything except where the
// operation says so (admit, narrow), with the boundary's one implementation
// (runtime::value's admit_c_float and narrow_c_float).

fn raw_format(code: u64) -> super::value::CFloatFormat {
    if code == 0 { super::value::CFloatFormat::Binary32 } else { super::value::CFloatFormat::Binary64 }
}

fn raw_kind(format: super::value::CFloatFormat) -> Kind {
    match format {
        super::value::CFloatFormat::Binary32 => Kind::RawFloat32,
        super::value::CFloatFormat::Binary64 => Kind::RawFloat64,
    }
}

/// The raw C floating value of FORMAT whose bits are BITS (a C call's
/// floating result, bit for bit: codegen::clif's foreign_result).
#[unsafe(no_mangle)]
pub extern "C" fn rt_raw_new(p: *mut Vm, format: u64, bits: u64) -> Value {
    vm(p).new_raw_float(raw_format(format), bits)
}

/// `rawfrombits32`/`64`: the raw value whose bit pattern is the Int N --
/// RANGE when N is no pattern of the format (a checked program proves it is:
/// std::ffi::c::RawFloatBits, RawDoubleBits).
#[unsafe(no_mangle)]
pub extern "C" fn rt_raw_from_bits(p: *mut Vm, format: u64, n: Value) -> Value {
    let format = raw_format(format);
    let max: u64 = if format == super::value::CFloatFormat::Binary32 { u32::MAX as u64 } else { u64::MAX };
    let bits = if let Some(i) = int_small(n) {
        (i >= 0).then_some(i as u64)
    } else if !is_small(n) && n != NO_VALUE && n & 7 == 0 && heap_kind(n) == KIND_BIGINT {
        big_of(n).to_u64()
    } else {
        return vm(p).fail(RtError::Type { context: "std::ffi::c raw bits".to_string(), expected: Kind::Int, got: n });
    };
    match bits {
        Some(b) if b <= max => vm(p).new_raw_float(format, b),
        _ => {
            let message = format!("{} is not a {} bit pattern (0..{max})", super::show::int_text(n),
                if format == super::value::CFloatFormat::Binary32 { "binary32" } else { "binary64" });
            vm(p).fail(RtError::Semantic { kind: "RANGE", message })
        }
    }
}

/// The bits of V, a raw value of FORMAT, or the TYPE failure (Err) a
/// checked program never reaches.
fn raw_operand(p: *mut Vm, format: super::value::CFloatFormat, v: Value, context: &str) -> Result<u64, Value> {
    if super::value::raw_format_of(v) != Some(format) {
        return Err(vm(p).fail(RtError::Type { context: context.to_string(), expected: raw_kind(format), got: v }));
    }
    Ok(super::value::raw_bits(v))
}

/// `rawbits32`/`64`: the bit pattern of the raw value V, an Int.
#[unsafe(no_mangle)]
pub extern "C" fn rt_raw_bits(p: *mut Vm, format: u64, v: Value) -> Value {
    match raw_operand(p, raw_format(format), v, "std::ffi::c raw bits") {
        Ok(bits) if bits <= SMALL_MAX as u64 => vm(p).new_int(bits as i64),
        Ok(bits) => vm(p).new_big(BigInt::from(bits)),
        Err(failed) => failed,
    }
}

/// `rawadmit32`/`64`: the Float64 the raw value V stands for, or
/// NonFiniteFloat (NaN, an infinity); negative zero is zero, a binary32
/// widened exactly (runtime::value's admit_c_float: Float's own admission).
#[unsafe(no_mangle)]
pub extern "C" fn rt_raw_admit(p: *mut Vm, format: u64, v: Value) -> Value {
    let format = raw_format(format);
    let bits = match raw_operand(p, format, v, "std::ffi::c raw admission") {
        Ok(bits) => bits,
        Err(failed) => return failed,
    };
    match super::value::admit_c_float(format, bits) {
        Ok(admitted) => vm(p).new_float(super::value::FloatType::Float64, admitted),
        Err(result) => super::ops::rt_float_nonfinite(p, result),
    }
}

/// `rawnarrow32`/`64`: the raw value of the Float64 V's bits in FORMAT
/// (runtime::value's narrow_c_float: binary64 exact, binary32 rounded to
/// nearest, ties to even, an overflow NonFiniteFloat, a zero +0).
#[unsafe(no_mangle)]
pub extern "C" fn rt_raw_narrow(p: *mut Vm, format: u64, v: Value) -> Value {
    let format = raw_format(format);
    if is_small(v) || v == NO_VALUE || v & 7 != 0 || heap_kind(v) != KIND_FLOAT {
        return vm(p).fail(RtError::Type { context: "std::ffi::c raw narrowing".to_string(), expected: Kind::Float64, got: v });
    }
    match super::value::narrow_c_float(format, super::value::float64_of(v)) {
        Ok(bits) => vm(p).new_raw_float(format, bits),
        Err(result) => super::ops::rt_float_nonfinite(p, result),
    }
}
