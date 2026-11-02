// Rust equivalent of bench/source-checks.bot: a small lint pass whose
// lexical classifiers of an identifier's leading character are held in a
// list of callables and invoked from it, then a selection of the invalid
// names and a search for the first one.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all equivalents. The printed value's shape matches
// core::value::show's rendering of a Botlish List (strings double-quoted).
//
// Mapping: CHECKS is the Botlish `checks` List (two Tcl character classes
// and two ordinary functions) as an array of function pointers;
// classify_leading applies each to the first character, as
// `loop check in checks: check(c)` does, collecting a Vec; the empty name
// short-circuits to four false flags before the list is consulted.
// tcl_alpha/tcl_alnum are Tcl 9's [:alpha:]/[:alnum:] (tcl_unicode.rs).
mod tcl_unicode;

use std::hint::black_box;
use std::time::Instant;

fn is_underscore(c: char) -> bool {
    c == '_'
}

fn is_hyphen(c: char) -> bool {
    c == '-'
}

const CHECKS: [fn(char) -> bool; 4] = [tcl_unicode::tcl_alpha, tcl_unicode::tcl_alnum, is_underscore, is_hyphen];

fn classify_leading(name: &str) -> Vec<bool> {
    match name.chars().next() {
        None => vec![false, false, false, false],
        Some(c) => CHECKS.iter().map(|check| check(c)).collect(),
    }
}

fn valid_start(name: &str) -> bool {
    let flags = classify_leading(name);
    flags.first().copied().unwrap_or(false) || flags.get(2).copied().unwrap_or(false)
}

fn invalid_name(name: &str) -> bool {
    !valid_start(name)
}

fn run_once(candidates: &[String]) -> (usize, usize, String, usize) {
    let invalid_names: Vec<&String> = candidates.iter().filter(|name| !valid_start(name)).collect();
    let first_invalid = candidates
        .iter()
        .find(|name| invalid_name(name))
        .map(|name| name.to_string())
        .unwrap_or_else(|| "<none>".to_string());
    (candidates.len(), invalid_names.len(), first_invalid, candidates.len() - invalid_names.len())
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
    let candidates: Vec<String> = [
        "emailish?",
        "scan_while",
        "list_get",
        "_internal",
        "über_count",
        "2fast",
        "make_changed?",
        "_private_state",
        "9bad_name",
        "-flag",
        "is_tcl_alpha",
        "évalue",
        "-verbose",
        "",
        "x_1",
        "café_name",
    ]
    .iter()
    .map(|s| s.to_string())
    .collect();

    run_once(black_box(&candidates)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = (0, 0, String::new(), 0);
    for _ in 0..runs {
        let t0 = Instant::now();
        value = run_once(black_box(&candidates));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: [{}, {}, {}, {}]", value.0, value.1, quoted(&value.2), value.3);
    println!("best_us: {:.3}", best);
}
