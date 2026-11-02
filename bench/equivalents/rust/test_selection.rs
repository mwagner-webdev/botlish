// Rust equivalent of bench/test-selection.bot: "which test groups are
// affected by this set of changed files?" -- a named record per test group,
// a closure factory over a set of changed paths, and the selection, search
// and exclusion queries the Botlish program makes with it.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all equivalents. The printed value's shape matches
// core::value::show's rendering of a Botlish List (strings double-quoted,
// Bools true/false).
//
// Mapping: Test is the Botlish struct, make_changed returns a boxed closure
// that owns a HashSet (std::immutable_set), affected is any() over a test's
// dependencies, select_affected the returning-loop selection,
// first_affected the std::list::find with its NotFound fallback, and
// untouched_by_a the std::list::none? query. The test list and both
// changed-file sets are built inside each timed run, as the Botlish program
// builds them on every run.
use std::collections::HashSet;
use std::hint::black_box;
use std::time::Instant;

struct Test {
    name: String,
    dependencies: Vec<String>,
}

fn test(name: &str, dependencies: &[&str]) -> Test {
    Test { name: name.to_string(), dependencies: dependencies.iter().map(|d| d.to_string()).collect() }
}

fn make_changed(changed: &[&str]) -> Box<dyn Fn(&str) -> bool> {
    let changed_set: HashSet<String> = changed.iter().map(|c| c.to_string()).collect();
    Box::new(move |path: &str| changed_set.contains(path))
}

fn affected(test: &Test, changed: &dyn Fn(&str) -> bool) -> bool {
    test.dependencies.iter().any(|dep| changed(dep))
}

fn select_affected<'a>(tests: &'a [Test], changed: &dyn Fn(&str) -> bool) -> Vec<&'a Test> {
    tests.iter().filter(|test| affected(test, changed)).collect()
}

fn first_affected(tests: &[Test], changed: &dyn Fn(&str) -> bool) -> String {
    match tests.iter().find(|test| affected(test, changed)) {
        Some(found) => found.name.clone(),
        None => "<none>".to_string(),
    }
}

fn run_once(seed: &str) -> (usize, usize, String, bool, bool) {
    let tests = vec![
        test("parser-tests", &["src/parser.bot", "src/ast.bot"]),
        test("lexer-tests", &["src/lexer.bot", "src/token.bot"]),
        test("resolve-tests", &["hir/resolve.tcl", "hir/hir.tcl"]),
        test("types-tests", &["hir/types.tcl", "hir/hir.tcl"]),
        test("specialize-tests", &["hir/specialize.tcl", "hir/range.tcl"]),
        test("native-lower-tests", &["native/lower.tcl", "native/native.tcl"]),
        test("compile-tests", &["compiler/compiler.tcl"]),
        test("web-tests", &["stdlib/web.bot", "stdlib/byte.bot"]),
        test("ascii-tests", &["stdlib/ascii.bot"]),
        test("list-tests", &["stdlib/list.bot"]),
        test("byte-tests", &["stdlib/byte.bot", "core/scalarbits.tcl"]),
        test("char-tests", &["stdlib/char.bot", "core/unicodechar.tcl"]),
        test("docs-tests", &["README.md", "AGENTS.md"]),
        test("bench-tests", &["bench/bench.tcl"]),
    ];
    // black_box keeps the probe's input opaque to the optimizer.
    let changed_a = make_changed(&[black_box(seed), "hir/hir.tcl"]);
    let changed_b = make_changed(&["README.md"]);
    let probe = changed_a("stdlib/web.bot");
    let selected_a = select_affected(&tests, &*changed_a);
    let selected_b = select_affected(&tests, &*changed_b);
    let docs_deps = ["README.md", "AGENTS.md"];
    let untouched_by_a = !docs_deps.iter().any(|dep| changed_a(dep));
    (selected_a.len(), selected_b.len(), first_affected(&tests, &*changed_a), probe, untouched_by_a)
}

fn main() {
    let mut runs: u32 = 5;
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == "--runs" {
            runs = args.next().expect("--runs needs a value").parse().expect("--runs must be an integer");
        }
    }

    run_once("stdlib/web.bot"); // untimed warmup
    let mut best = f64::MAX;
    let mut value = (0, 0, String::new(), false, false);
    for _ in 0..runs {
        let t0 = Instant::now();
        value = run_once("stdlib/web.bot");
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: [{}, {}, \"{}\", {}, {}]", value.0, value.1, value.2, value.3, value.4);
    println!("best_us: {:.3}", best);
}
