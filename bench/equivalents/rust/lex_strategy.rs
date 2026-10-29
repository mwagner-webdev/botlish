// Rust equivalent of bench/lex-strategy.bot: a strict-vs-relaxed
// identifier-character classifier, chosen as a function value at an if/else
// join and then applied to every character of each token, plus a universal
// "is every character of this token alphanumeric?" query.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all equivalents. The printed value's shape matches
// core::value::show's rendering of a Botlish List (strings double-quoted).
//
// Mapping: choose_classifier returns one of two function pointers, as the
// Botlish program's two branches return std::str::is_tcl_alnum or
// lenient_ident_char?; classify collects the per-character flags into a Vec
// (the Botlish collecting loop) and count_true counts them. The Botlish
// chars_of is a recursive accumulator only because the language has no
// String-to-characters conversion; chars().collect() is Rust's own spelling
// of it. tcl_alnum is Tcl 9's [:alnum:] (tcl_unicode.rs).
#[allow(dead_code)]
mod tcl_unicode;

use std::hint::black_box;
use std::time::Instant;

fn lenient_ident_char(c: char) -> bool {
    tcl_unicode::tcl_alnum(c) || c == '_' || c == '-'
}

fn choose_classifier(strict_mode: bool) -> fn(char) -> bool {
    if strict_mode {
        tcl_unicode::tcl_alnum
    } else {
        lenient_ident_char
    }
}

fn chars_of(s: &str) -> Vec<char> {
    s.chars().collect()
}

fn classify(token: &str, strict_mode: bool) -> Vec<bool> {
    let classifier = choose_classifier(strict_mode);
    chars_of(token).into_iter().map(classifier).collect()
}

fn count_true(flags: &[bool]) -> i64 {
    flags.iter().filter(|&&flag| flag).count() as i64
}

fn valid_chars(token: &str, strict_mode: bool) -> i64 {
    count_true(&classify(token, strict_mode))
}

fn fully_alnum(token: &str) -> bool {
    chars_of(token).into_iter().all(tcl_unicode::tcl_alnum)
}

fn total_valid(tokens: &[String], strict_mode: bool) -> i64 {
    tokens.iter().map(|token| valid_chars(token, strict_mode)).sum()
}

fn run_once(tokens: &[String]) -> (i64, i64, usize, String) {
    let strict_total = total_valid(tokens, true);
    let relaxed_total = total_valid(tokens, false);
    let alnum_only_tokens: Vec<&String> = tokens.iter().filter(|token| fully_alnum(token)).collect();
    let first_alnum = alnum_only_tokens.first().map(|token| token.to_string()).unwrap_or_default();
    (strict_total, relaxed_total, alnum_only_tokens.len(), first_alnum)
}

fn quoted(s: &str) -> String {
    format!("\"{}\"", s.replace('\\', "\\\\").replace('"', "\\\""))
}

fn main() {
    let mut runs: u32 = 5;
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == "--runs" {
            runs = args.next().expect("--runs needs a value").parse().expect("--runs must be an integer");
        }
    }
    let tokens: Vec<String> = ["emailish?", "scan_while", "local-part", "tld-check", "x_1", "9bad-name", "café", "is_tcl_alpha"]
        .iter()
        .map(|s| s.to_string())
        .collect();

    run_once(black_box(&tokens)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = (0, 0, 0, String::new());
    for _ in 0..runs {
        let t0 = Instant::now();
        value = run_once(black_box(&tokens));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: [{}, {}, {}, {}]", value.0, value.1, value.2, quoted(&value.3));
    println!("best_us: {:.3}", best);
}
