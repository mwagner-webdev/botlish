//! DecimalRounded's run-time operations (DECIMAL-ROUNDED-MILESTONE-1.md):
//! the observations of a value at the precision its static type
//! guarantees, and the quantization of a Float64, computed exactly with
//! big integers -- core/decimal.tcl's procedures, step for step, so the
//! native and the Tcl runtimes make the same decisions.
//!
//! A DecimalRounded value is represented by a finite binary64 (a FloatObj of
//! kind KIND_DECIMAL); its arithmetic is the binary64 operation on the
//! representations (codegen::clif's float_op), which the compiler only ever
//! emits for decimal constant expressions it proved. Everything here reads a
//! representation x through round(x, P), the decimal x rounds to at P
//! places, ties to the even neighbor -- never x's own digits beyond P.

use super::ops::{fail_builtin, float_value};
use super::value::*;
use super::vm::Vm;
use num_bigint::{BigInt, Sign};
use num_traits::{One, Signed, ToPrimitive, Zero};
use std::cmp::Ordering;

/// A rational number NUM/DEN, DEN > 0 (not necessarily reduced).
#[derive(Clone, Debug)]
pub struct Rational {
    pub num: BigInt,
    pub den: BigInt,
}

impl Rational {
    fn cmp(&self, other: &Rational) -> Ordering {
        (&self.num * &other.den).cmp(&(&other.num * &self.den))
    }

    fn abs_difference(&self, other: &Rational) -> Rational {
        Rational { num: (&self.num * &other.den - &other.num * &self.den).abs(), den: &self.den * &other.den }
    }
}

const PRECISION: i64 = 53;
const MIN_EXPONENT: i64 = -1074;
const MAX_EXPONENT: i64 = 1023;
const FRACTION_MASK: u64 = (1 << 52) - 1;

/// The exact value of the finite binary64 X (core::decimal::DoubleRat).
pub fn exact(x: f64) -> Rational {
    let bits = x.to_bits();
    let negative = bits >> 63 == 1;
    let biased = ((bits >> 52) & 0x7FF) as i64;
    let fraction = bits & FRACTION_MASK;
    let (m, e) = if biased == 0 { (fraction, MIN_EXPONENT) } else { (fraction | (1 << 52), biased - 1075) };
    let mut num = BigInt::from(m);
    if negative {
        num = -num;
    }
    if e >= 0 {
        Rational { num: num << (e as usize), den: BigInt::one() }
    } else {
        Rational { num, den: BigInt::one() << ((-e) as usize) }
    }
}

/// NUM/DEN rounded down (toward minus infinity), DEN > 0.
fn floor_div(num: &BigInt, den: &BigInt) -> (BigInt, BigInt) {
    let mut q = num / den;
    let mut r = num - &q * den;
    if r.sign() == Sign::Minus {
        q -= 1;
        r += den;
    }
    (q, r)
}

/// The integer nearest NUM/DEN, ties to the even one (core::decimal::
/// RoundHalfEven).
fn round_half_even(num: &BigInt, den: &BigInt) -> BigInt {
    let (mut q, r) = floor_div(num, den);
    let twice: BigInt = r * 2;
    let odd = (&q % 2u32) != BigInt::zero();
    if twice > *den || (twice == *den && odd) {
        q += 1;
    }
    q
}

/// The integer K with round(R, P) = K x 10^-P (core::decimal::RoundAt).
pub fn round_at(r: &Rational, p: u32) -> BigInt {
    round_half_even(&(&r.num * BigInt::from(10u32).pow(p)), &r.den)
}

/// P/Q divided by 2^E, P and Q positive: rounded down, or to the nearest
/// integer (ties to even) when NEAREST (core::decimal::Scaled).
fn scaled(p: &BigInt, q: &BigInt, e: i64, nearest: bool) -> BigInt {
    let (num, den) = if e >= 0 { (p.clone(), q << (e as usize)) } else { (p << ((-e) as usize), q.clone()) };
    if nearest { round_half_even(&num, &den) } else { floor_div(&num, &den).0 }
}

/// The binary64 nearest R, ties to even (core::decimal::RatDouble), or None
/// when its rounded magnitude is beyond the largest finite binary64.
pub fn nearest_double(r: &Rational) -> Option<f64> {
    if r.num.is_zero() {
        return Some(0.0);
    }
    let negative = r.num.is_negative();
    let p = r.num.abs();
    let q = &r.den;
    let mut e = p.bits() as i64 - q.bits() as i64 - PRECISION + 1;
    let normal = BigInt::one() << ((PRECISION - 1) as usize);
    if scaled(&p, q, e, false) < normal {
        e -= 1;
    }
    if e < MIN_EXPONENT {
        e = MIN_EXPONENT;
    }
    let mut m = scaled(&p, q, e, true);
    if m == BigInt::one() << (PRECISION as usize) {
        m = normal.clone();
        e += 1;
    }
    if m.is_zero() {
        return Some(0.0);
    }
    if e + PRECISION > MAX_EXPONENT + 1 {
        return None;
    }
    let m = m.to_u64().expect("a significand fits 53 bits");
    let mut bits = if m < 1 << 52 { m } else { (((e + 1075) as u64) << 52) | (m & FRACTION_MASK) };
    if negative {
        bits |= 1 << 63;
    }
    Some(f64::from_bits(bits))
}

/// The finite binary64 adjacent to X toward plus (UP) or minus infinity
/// (core::decimal::NextDouble); zero's neighbors are the smallest subnormals.
fn next_double(x: f64, up: bool) -> Option<f64> {
    let bits = x.to_bits();
    let next = if x == 0.0 {
        if up { 1 } else { (1 << 63) | 1 }
    } else if (x > 0.0) == up {
        bits + 1
    } else {
        let next = bits - 1;
        if next & !(1u64 << 63) == 0 {
            return Some(0.0);
        }
        next
    };
    let y = f64::from_bits(next);
    if y.is_finite() { Some(y) } else { None }
}

/// The precision to which the binary64 X satisfies the guarantee of the
/// true value T (core::decimal::Proven): None when X is T itself (every
/// precision), else the largest N with round(X, P) = round(T, P) for every P
/// up to N (-1 when even P = 0 fails).
pub fn proven(x: f64, t: &Rational) -> Option<i64> {
    let xr = exact(x);
    if xr.cmp(t) == Ordering::Equal {
        return None;
    }
    let mut p = 0u32;
    loop {
        if round_at(&xr, p) != round_at(t, p) {
            return Some(p as i64 - 1);
        }
        p += 1;
    }
}

/// The representation of a value whose true value is T
/// (core::decimal::Represent): among the binary64 nearest T and its two
/// neighbors, the one satisfying the guarantee at the highest precision,
/// then the nearest to T. None when T has no finite binary64.
pub fn represent(t: &Rational) -> Option<f64> {
    let x = nearest_double(t)?;
    let mut candidates = vec![x];
    for up in [false, true] {
        if let Some(y) = next_double(x, up) {
            candidates.push(y);
        }
    }
    let mut best: Option<(f64, i64, Rational)> = None;
    for y in candidates {
        let rank = proven(y, t).unwrap_or(1_000_000);
        let distance = exact(y).abs_difference(t);
        let better = match &best {
            None => true,
            Some((_, best_rank, best_distance)) => {
                rank > *best_rank || (rank == *best_rank && distance.cmp(best_distance) == Ordering::Less)
            }
        };
        if better {
            best = Some((y, rank, distance));
        }
    }
    best.map(|(y, _, _)| y)
}

/// The order of round(A, P) and round(B, P) (core::decimal::CompareAt).
pub fn compare_at(a: f64, b: f64, p: u32) -> Ordering {
    round_at(&exact(a), p).cmp(&round_at(&exact(b), p))
}

/// The binary64 nearest round(X, P) (core::decimal::ToFloat64): finite,
/// since round(X, P) is within half a unit of P of the finite X.
pub fn to_f64_at(x: f64, p: u32) -> f64 {
    let k = round_at(&exact(x), p);
    nearest_double(&Rational { num: k, den: BigInt::from(10u32).pow(p) }).expect("a rounded finite binary64 is finite")
}

/// round(X, P) as the integer K with round(X, P) = K x 10^-P, computed with
/// machine integers when that is exact: P <= 19 (10^P fits 64 bits) and X's
/// scaled significand within 127 bits -- every X below 2^10 in magnitude,
/// at every such P, and every X too small to reach a unit of 10^-P. The
/// same rounding as round_at (ties to the even K), on the same exact value
/// m x 2^e of X; None when the operands would not fit, and round_at decides.
pub fn round_at_small(x: f64, p: u32) -> Option<i128> {
    if p > 19 {
        return None;
    }
    let bits = x.to_bits();
    let negative = bits >> 63 == 1;
    let biased = ((bits >> 52) & 0x7FF) as i64;
    let fraction = bits & FRACTION_MASK;
    let (m, e) = if biased == 0 { (fraction, MIN_EXPONENT) } else { (fraction | (1 << 52), biased - 1075) };
    // m < 2^53 and 10^19 < 2^64, so m x 10^p < 2^117.
    let scaled = m as u128 * 10u128.pow(p);
    let k = if e >= 0 {
        // An integer: m x 2^e x 10^p, exact while it stays below 2^127.
        if e > 9 {
            return None;
        }
        scaled << e
    } else {
        let s = (-e) as u32;
        if s >= 120 {
            // scaled < 2^117 is below half of 2^s: it rounds to 0.
            0
        } else {
            let q = scaled >> s;
            let r = scaled & ((1u128 << s) - 1);
            let half = 1u128 << (s - 1);
            if r > half || (r == half && q & 1 == 1) { q + 1 } else { q }
        }
    };
    let k = k as i128;
    Some(if negative { -k } else { k })
}

/// The decimal text of round(X, P) (core::decimal::RoundedText): its digits
/// with exactly P fraction digits (none, and no point, for P = 0), a "-"
/// only before a nonzero result -- DecimalRounded has no negative zero. One
/// rounding at P (round_at_small, else round_at), never a search over
/// precisions, and never X's own digits beyond P.
pub fn text_at(x: f64, p: u32) -> String {
    let k = match round_at_small(x, p) {
        Some(k) => num_bigint::BigInt::from(k),
        None => round_at(&exact(x), p),
    };
    let mut digits = k.magnitude().to_string();
    let p = p as usize;
    let mut out = String::with_capacity(digits.len() + p + 3);
    if k.sign() == Sign::Minus {
        out.push('-');
    }
    if p == 0 {
        out.push_str(&digits);
        return out;
    }
    if digits.len() <= p {
        digits.insert_str(0, &"0".repeat(p + 1 - digits.len()));
    }
    let point = digits.len() - p;
    out.push_str(&digits[..point]);
    out.push('.');
    out.push_str(&digits[point..]);
    out
}

/// The quantization of X at N places (core::decimal::Quantize): the
/// binary64 representing the true value round(X, N), or None when none
/// satisfies that true value's guarantee at N places.
pub fn quantize(x: f64, n: u32) -> Option<f64> {
    let t = Rational { num: round_at(&exact(x), n), den: BigInt::from(10u32).pow(n) };
    let y = represent(&t)?;
    match proven(y, &t) {
        None => Some(y),
        Some(k) if k >= n as i64 => Some(y),
        Some(_) => None,
    }
}

/// The precision word P (an elaborated constant: a small, nonnegative Int).
fn precision_of(p: Value) -> u32 {
    int_small(p).and_then(|n| u32::try_from(n).ok()).expect("a DecimalRounded precision is a small nonnegative Int")
}

/// `decimal_rounded#less` .. `#equal`: the order (-1, 0, 1 as a raw word)
/// of round(A, P) and round(B, P), A and B DecimalRounded values. Never
/// fails, never allocates.
#[unsafe(no_mangle)]
pub extern "C" fn rt_decimal_cmp(_p: *mut Vm, a: Value, b: Value, p: Value) -> i64 {
    compare_at(float64_of(a), float64_of(b), precision_of(p)) as i64
}

/// `decimal_rounded#to_float64`: the Float64 nearest round(V, P).
#[unsafe(no_mangle)]
pub extern "C" fn rt_decimal_to_f64(p: *mut Vm, v: Value, precision: Value) -> Value {
    float_value(p, FloatType::Float64, to_f64_at(float64_of(v), precision_of(precision)))
}

/// `decimal_rounded#to_string`: the decimal text of round(V, P), V a
/// DecimalRounded value and P the precision its static type guarantees
/// (an elaborated constant: hir::decimal::Elaborate). Never fails.
#[unsafe(no_mangle)]
pub extern "C" fn rt_decimal_to_str(p: *mut Vm, v: Value, precision: Value) -> Value {
    let text = text_at(float64_of(v), precision_of(precision));
    let n = text.len();
    vm_of(p).new_str_known(&text, n, true)
}

fn vm_of<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

/// `decimal_rounded#round`: the DecimalRounded value whose true value is
/// round(X, N), X a Float64, or the declared error UnrepresentableDecimal.
#[unsafe(no_mangle)]
pub extern "C" fn rt_decimal_round(p: *mut Vm, x: Value, n: Value) -> Value {
    match quantize(float64_of(x), precision_of(n)) {
        Some(y) => float_value(p, FloatType::DecimalRounded, y),
        None => fail_builtin(p, super::error::ERR_UNREPRESENTABLE_DECIMAL, "UnrepresentableDecimal"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn decimal(text: &str) -> Rational {
        // DIGITS.DIGITS, optionally negative: the exact decimal.
        let negative = text.starts_with('-');
        let text = text.trim_start_matches('-');
        let (whole, fraction) = text.split_once('.').unwrap();
        let mut num: BigInt = format!("{whole}{fraction}").parse().unwrap();
        if negative {
            num = -num;
        }
        Rational { num, den: BigInt::from(10u32).pow(fraction.len() as u32) }
    }

    #[test]
    fn decimal_nearest_double_matches_the_parser() {
        for text in ["0.1", "1.245", "123456.789", "0.000001", "2.2250738585072011e-308", "1.7976931348623157e308"] {
            let r = if text.contains('e') {
                let (mantissa, exponent) = text.split_once('e').unwrap();
                let m = decimal(mantissa);
                let e: i32 = exponent.parse().unwrap();
                if e >= 0 {
                    Rational { num: m.num * BigInt::from(10u32).pow(e as u32), den: m.den }
                } else {
                    Rational { num: m.num, den: m.den * BigInt::from(10u32).pow((-e) as u32) }
                }
            } else {
                decimal(text)
            };
            assert_eq!(nearest_double(&r), Some(text.parse::<f64>().unwrap()), "{text}");
        }
        assert_eq!(nearest_double(&Rational { num: BigInt::from(18u32) * BigInt::from(10u32).pow(307), den: BigInt::one() }), None);
    }

    #[test]
    fn decimal_ties_round_half_even() {
        assert_eq!(compare_at(0.125, 0.12, 2), Ordering::Equal);
        assert_eq!(to_f64_at(2.5, 0), 2.0);
        assert_eq!(to_f64_at(3.5, 0), 4.0);
        assert_eq!(to_f64_at(-0.004, 2), 0.0);
        assert_eq!(to_f64_at(0.1 + 0.2, 2), 0.3);
    }

    #[test]
    fn decimal_represent_chooses_the_tie_side() {
        // 1.245's nearest binary64 is above it; round(1.245, 2) is 1.24.
        let t = decimal("1.245");
        let y = represent(&t).unwrap();
        assert!(y < 1.245);
        assert_eq!(proven(y, &t), Some(15));
        assert_eq!(proven(0.1, &decimal("0.1")), Some(16));
        assert_eq!(proven(0.5, &decimal("0.5")), None);
    }

    #[test]
    fn decimal_text_at_rounds_once_half_to_even() {
        let cases = [
            ("1.245", 2, "1.24"),
            ("1.235", 2, "1.24"),
            ("1.255", 2, "1.26"),
            ("-1.245", 2, "-1.24"),
            ("0.005", 2, "0.00"),
            ("0.295", 2, "0.30"),
            ("2.0", 1, "2.0"),
            ("2.0", 2, "2.00"),
            ("25.0", 2, "25.00"),
            ("-0.04", 1, "0.0"),
            ("-0.05", 1, "0.0"),
            ("-0.15", 1, "-0.2"),
            ("2.5", 0, "2"),
            ("3.5", 0, "4"),
            ("-2.5", 0, "-2"),
            ("0.0", 3, "0.000"),
            ("123456.789", 3, "123456.789"),
        ];
        for (text, p, want) in cases {
            let x = represent(&decimal(text)).unwrap();
            assert_eq!(text_at(x, p), want, "{text} at {p}");
        }
        // The largest finite magnitude, beyond the machine path.
        assert!(text_at(f64::MAX, 2).ends_with(".00"));
        assert!(text_at(-f64::MIN_POSITIVE, 20).starts_with("0.000"));
    }

    #[test]
    fn decimal_round_at_small_matches_round_at() {
        // A deterministic sweep: every precision the fast path takes, over
        // magnitudes from subnormal to 2^70, ties and their neighbors.
        let mut state: u64 = 0x9E37_79B9_7F4A_7C15;
        let mut next = || {
            state ^= state << 13;
            state ^= state >> 7;
            state ^= state << 17;
            state
        };
        let mut xs: Vec<f64> = vec![0.0, 0.5, 1.5, 2.5, -0.5, -2.5, 1.245, 0.295, 1e-300, f64::MIN_POSITIVE, 1023.999, 1024.0];
        for _ in 0..20000 {
            let r = next();
            let exponent = (r % 140) as i32 - 70;
            let mantissa = (next() >> 11) as f64 / (1u64 << 53) as f64 + 0.5;
            let mut x = mantissa * 2f64.powi(exponent);
            if r & (1 << 40) != 0 {
                x = -x;
            }
            xs.push(x);
            xs.push(f64::from_bits(next()) % 1e6);
        }
        for p in 0..=19u32 {
            for &x in &xs {
                if !x.is_finite() {
                    continue;
                }
                let t = (x * 10f64.powi(p as i32)).round() / 10f64.powi(p as i32);
                for y in [x, t, next_double(t, true).unwrap_or(t), next_double(t, false).unwrap_or(t)] {
                    if let Some(k) = round_at_small(y, p) {
                        assert_eq!(BigInt::from(k), round_at(&exact(y), p), "{y:e} at {p}");
                    }
                }
            }
        }
        // The fast path takes every value below 2^10 at every P <= 19.
        assert!(round_at_small(1023.9999, 19).is_some());
        assert!(round_at_small(1.0e300, 0).is_none());
    }

    #[test]
    fn decimal_quantize() {
        assert_eq!(quantize(0.30000000000000004, 2), Some(0.3));
        assert_eq!(quantize(1.0e20, 2), Some(1.0e20));
        // No binary64 holds its nine-place decimal (core::decimal::Quantize
        // agrees: decimal-rounded.test's dr-quantize).
        assert_eq!(quantize(4873863637.854281, 9), None);
        assert_eq!(next_double(0.0, true), Some(5e-324));
        assert_eq!(next_double(5e-324, false), Some(0.0));
    }
}
