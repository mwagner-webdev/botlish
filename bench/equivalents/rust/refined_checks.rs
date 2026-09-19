// Rust equivalent of bench/refined-checks.ir: repeated refined-type
// predicates. emailish is a structural check (regex-equivalent membership
// test, hand-rolled below rather than pulling in the `regex` crate);
// UriQueryValue is opaque evidence that only uri_escape can attach.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all four equivalents. The printed "[a, b]" shape
// matches core::value::show's rendering of a Botlish list.
//
// Email grammar, matching lib/web.tcl's emailRegex:
//   local: 1+ of [alnum . _ % + -]   (Tcl [:alnum:]: Unicode-aware, see below)
//   '@'
//   domain: 1+ of ( 1+ of [alnum -] followed by '.' )
//   tld: 2+ [:alpha:] letters, then end of string
//
// "alnum"/"alpha" here are Tcl 9's own Unicode-aware [:alnum:]/[:alpha:]
// regexp bracket-expression classes (core::regex::matches's semantics,
// lib/web.tcl's own reference validator) -- NOT c.is_ascii_alphanumeric()/
// is_ascii_alphabetic(), which this file used before this milestone. That
// was a real semantic narrowing (a benchmark bug, not a broader/narrower
// "simplification"): Tcl 9's [:alpha:]/[:alnum:] accept e.g. "café" and
// "日本語", which the ASCII-only version silently rejected. See
// tcl_unicode.rs and NATIVE-TCL-UNICODE.md for the exact classification
// this now reproduces (matching native/src/runtime/ops.rs's
// rt_is_tcl_alpha/rt_is_tcl_alnum and lib/web.tcl's Emailish? native-body).
mod tcl_unicode;

use std::hint::black_box;
use std::time::Instant;

fn is_local_char(c: char) -> bool {
    tcl_unicode::tcl_alnum(c) || matches!(c, '.' | '_' | '%' | '+' | '-')
}

fn is_label_char(c: char) -> bool {
    tcl_unicode::tcl_alnum(c) || c == '-'
}

fn emailish(s: &str) -> bool {
    let chars: Vec<char> = s.chars().collect();
    let mut i = 0;
    let n = chars.len();

    let local_start = i;
    while i < n && is_local_char(chars[i]) {
        i += 1;
    }
    if i == local_start {
        return false;
    }

    if i >= n || chars[i] != '@' {
        return false;
    }
    i += 1;

    loop {
        let label_start = i;
        while i < n && is_label_char(chars[i]) {
            i += 1;
        }
        if i == label_start {
            return false;
        }
        if i >= n || chars[i] != '.' {
            return false;
        }
        i += 1;

        let mut j = i;
        while j < n && tcl_unicode::tcl_alpha(chars[j]) {
            j += 1;
        }
        if j == n && j - i >= 2 {
            i = j;
            break;
        }
    }

    i == n
}

struct UriQueryValue(#[allow(dead_code)] String);

fn uri_query_value(_q: &UriQueryValue) -> bool {
    true
}

fn uri_escape(s: &str) -> UriQueryValue {
    let mut escaped = String::new();
    for byte in s.as_bytes() {
        let c = *byte as char;
        if c.is_ascii_alphanumeric() || matches!(c, '.' | '_' | '~' | '-') {
            escaped.push(c);
        } else {
            escaped.push_str(&format!("%{:02X}", byte));
        }
    }
    UriQueryValue(escaped)
}

fn check(n: i64, acc: i64, s: &str, q: &UriQueryValue) -> i64 {
    if n <= 0 {
        return acc;
    }
    let hit = if emailish(s) {
        // Statically redundant re-check, mirrored from the IR as written.
        if emailish(s) {
            if uri_query_value(q) { 1 } else { 0 }
        } else {
            0
        }
    } else {
        0
    };
    check(n - 1, acc + hit, s, q)
}

fn run_once(n0: i64, s1: &str, s2: &str, raw_q: &str) -> (i64, i64) {
    let q = uri_escape(raw_q);
    (check(n0, 0, s1, &q), check(n0, 0, s2, &q))
}

fn main() {
    let mut runs: u32 = 5;
    let mut positional = Vec::new();
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == "--runs" {
            runs = args.next().expect("--runs needs a value").parse().expect("--runs must be an integer");
        } else {
            positional.push(arg);
        }
    }
    let n0: i64 = positional.get(0).map(|s| s.parse().expect("n must be an integer")).unwrap_or(400);
    let s1 = positional.get(1).cloned().unwrap_or_else(|| "café@例え.テスト".to_string());
    let s2 = positional.get(2).cloned().unwrap_or_else(|| "not-an-email".to_string());
    let raw_q = positional.get(3).cloned().unwrap_or_else(|| "a b".to_string());

    run_once(black_box(n0), black_box(&s1), black_box(&s2), black_box(&raw_q)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = (0, 0);
    for _ in 0..runs {
        let t0 = Instant::now();
        // black_box on the arguments stops the optimizer from noticing the
        // call is loop-invariant and hoisting it out after the first run.
        value = run_once(black_box(n0), black_box(&s1), black_box(&s2), black_box(&raw_q));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: [{}, {}]", value.0, value.1);
    println!("best_us: {:.3}", best);
}
