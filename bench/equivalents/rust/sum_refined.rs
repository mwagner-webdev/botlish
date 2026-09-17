// Rust equivalent of bench/sum-refined.ir: tail-style recursion over an
// accumulator whose type is only known through an integer? refinement,
// plus a closure created per step.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all four equivalents. Rust's static typing makes the
// integer? refinement check trivially true for an i64 accumulator; it is
// omitted rather than faked as a runtime check.
use std::hint::black_box;
use std::time::Instant;

#[inline(never)]
fn sum_refined(n: i64, acc: i64) -> i64 {
    if n == 0 {
        return acc;
    }
    let step = |x: i64| x + n;
    // black_box on the accumulator breaks the induction-variable chain the
    // optimizer would otherwise use to reduce the whole recursion to a
    // closed-form Gauss sum, so each step actually runs.
    sum_refined(n - 1, black_box(step(acc)))
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
    let acc0: i64 = positional.get(1).map(|s| s.parse().expect("acc must be an integer")).unwrap_or(0);

    sum_refined(black_box(n0), black_box(acc0)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = 0;
    for _ in 0..runs {
        let t0 = Instant::now();
        // black_box on the arguments stops the optimizer from noticing the
        // call is loop-invariant and hoisting it out after the first run.
        value = sum_refined(black_box(n0), black_box(acc0));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: {}", value);
    println!("best_us: {:.3}", best);
}
