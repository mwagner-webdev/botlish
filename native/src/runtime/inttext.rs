//! An Int's decimal text, both ways (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md;
//! core/inttext.tcl states the semantics, which these follow exactly):
//!
//!   * `std::int::to_string(n)`: N's canonical decimal text -- the one
//!     rendering of an Int the runtime has (ops::with_int_text, which the
//!     hashes' canonical walk, the program-result display, the host
//!     transport and messages also use: show::int_text).
//!   * `std::int::from_string(s)`: the Int whose canonical decimal text is
//!     S, else the declared builtin error InvalidIntegerText. The canonical
//!     text is `0 | -?[1-9][0-9]*` (core::value::isCanonicalInt): ASCII
//!     digits, no leading zero, a "-" only before a nonzero number, nothing
//!     else -- exactly the texts to_string produces.

use super::ops::{fail_builtin, with_int_text};
use super::value::*;
use super::vm::Vm;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

/// Whether TEXT is the canonical decimal text of an Int: "0", or an
/// optional "-" followed by an ASCII digit 1-9 and any further ASCII digits.
pub fn is_canonical_int(text: &str) -> bool {
    let digits = text.strip_prefix('-').unwrap_or(text);
    match digits.as_bytes() {
        [] => false,
        [b'0'] => digits.len() == text.len(),
        [first, rest @ ..] => (b'1'..=b'9').contains(first) && rest.iter().all(u8::is_ascii_digit),
    }
}

/// The Int whose canonical decimal text is TEXT (is_canonical_int), or None.
/// A text of at most 18 digits is an i64; a longer one is read by the
/// parser NIR's Int constants use (num-bigint's), which is given only text
/// the canonical rule accepted (it would itself also take a "+" or "_").
pub fn parse_canonical_int(text: &str) -> Option<IntText> {
    if !is_canonical_int(text) {
        return None;
    }
    let digits = text.len() - usize::from(text.starts_with('-'));
    if digits <= 18 {
        return Some(IntText::Small(text.parse().expect("at most 18 digits fit an i64")));
    }
    Some(IntText::Big(text.parse().expect("canonical decimal digits")))
}

/// The value of a canonical Int text: a machine word, or a big integer.
#[derive(Debug, PartialEq)]
pub enum IntText {
    Small(i64),
    Big(num_bigint::BigInt),
}

/// `std::int::to_string`: the canonical decimal text of the Int N. Never
/// fails (no Int has 2^62 digits).
#[unsafe(no_mangle)]
pub extern "C" fn rt_int_to_str(p: *mut Vm, n: Value) -> Value {
    with_int_text(n, |text| {
        let text = std::str::from_utf8(text).expect("decimal digits are ASCII");
        vm(p).new_str_known(text, text.len(), true)
    })
}

/// `std::int::from_string`: the Int whose canonical decimal text is S, or
/// the declared builtin error InvalidIntegerText.
#[unsafe(no_mangle)]
pub extern "C" fn rt_str_to_int(p: *mut Vm, s: Value) -> Value {
    match parse_canonical_int(str_of(s).as_str()) {
        Some(IntText::Small(n)) => vm(p).new_int(n),
        Some(IntText::Big(n)) => vm(p).new_big(n),
        None => fail_builtin(p, super::error::ERR_INVALID_INTEGER_TEXT, "InvalidIntegerText"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::show::int_text;
    use num_bigint::BigInt;

    #[test]
    fn int_text_canonical_grammar() {
        for good in ["0", "7", "-7", "10", "123456", "-999999999999999999999999999999999"] {
            assert!(is_canonical_int(good), "{good:?} is canonical");
        }
        for bad in [
            "", "-", "+1", "01", "-01", "-0", "00", "1.0", " 1", "1 ", "1x", "x1", "--1", "1_000", "١٢", "\u{FF11}",
            "1\n", "0x10", "1e3",
        ] {
            assert!(!is_canonical_int(bad), "{bad:?} is not canonical");
            assert_eq!(parse_canonical_int(bad), None);
        }
    }

    fn vm() -> Box<Vm> {
        use crate::runtime::metrics::AllocMode;
        use crate::runtime::vm::ProgramInfo;
        Vm::new(
            std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        )
    }

    #[test]
    fn int_text_helpers_round_trip_through_values() {
        let mut vm = vm();
        let p = &mut *vm as *mut Vm;
        for text in ["0", "-1", "4611686018427387903", "4611686018427387904", "-4611686018427387905",
            "340282366920938463463374607431768211456", "-123456789012345678901234567890123456789012345678901234567890"] {
            let n = rt_str_to_int(p, vm.new_str(text));
            assert_ne!(n, NO_VALUE, "{text}");
            assert_eq!(int_text(n), text);
            let s = rt_int_to_str(p, n);
            assert_eq!(str_of(s).as_str(), text);
        }
        assert_eq!(rt_str_to_int(p, vm.new_str("01")), NO_VALUE);
        assert_eq!(vm.declared_error, crate::runtime::error::ERR_INVALID_INTEGER_TEXT);
    }

    #[test]
    fn f64_round_is_round_at_zero() {
        // rt_f64_round against the exact decimal model's round(x, 0)
        // (runtime::decimal::round_at, core::float::Nearest's procedure):
        // ties to even, the neighbors of every half, magnitudes far beyond
        // the small-Int range.
        use crate::runtime::decimal::{exact, round_at};
        use crate::runtime::ops::rt_f64_round;
        let mut vm = vm();
        let p = &mut *vm as *mut Vm;
        let mut xs = vec![0.0, 0.49, 0.5, 1.5, 2.5, 3.5, -0.5, -1.5, -2.5, 1.4, -1.4, 4503599627370495.5,
            4503599627370496.0, 9007199254740993.0, 1e19, -1e19, 4.611686018427388e18, 1e300, -1e300, f64::MAX, f64::MIN,
            f64::MIN_POSITIVE, 5e-324];
        for k in -60i32..=70 {
            let half = 2f64.powi(k) + 0.5;
            for x in [half, -half] {
                xs.extend([x, f64::from_bits(x.to_bits() + 1), f64::from_bits(x.to_bits() - 1)]);
            }
        }
        for x in xs {
            let v = vm.new_float(FloatType::Float64, x.to_bits());
            let r = rt_f64_round(p, v);
            assert_eq!(int_text(r), round_at(&exact(x), 0).to_string(), "{x:e}");
        }
    }

    #[test]
    fn int_text_round_trips() {
        // Every width at the i64 and small-Int boundaries, and far beyond.
        let mut values: Vec<BigInt> = Vec::new();
        for k in [0u32, 1, 9, 17, 18, 19, 20, 61, 62, 63, 64, 65, 200, 1000] {
            let ten = BigInt::from(10).pow(k);
            let two = BigInt::from(2).pow(k);
            for v in [ten.clone(), ten - 1, two.clone(), two - 1] {
                values.push(v.clone());
                values.push(-v);
            }
        }
        for v in values {
            let text = v.to_string();
            match parse_canonical_int(&text) {
                Some(IntText::Small(n)) => assert_eq!(BigInt::from(n), v),
                Some(IntText::Big(n)) => assert_eq!(n, v),
                None => panic!("{text} did not parse"),
            }
        }
    }
}
