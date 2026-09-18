// Rust equivalent of bench/fib.ir: naive recursive Fibonacci.
//
// Invoked by bench/bench.tcl for the interp/compile/python/rust comparison
// table. Prints a "value:"/"best_us:" pair for the caller to parse; n comes
// from argv (default matches the literal in fib.ir) so rustc never sees a
// compile-time constant to fold.
use std::hint::black_box;
use std::time::Instant;

fn fib(n: i64) -> i64 {
    if n < 2 {
        n
    } else {
        fib(n - 1) + fib(n - 2)
    }
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
    let n: i64 = positional.get(0).map(|s| s.parse().expect("n must be an integer")).unwrap_or(28);

    fib(black_box(n)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = 0;
    for _ in 0..runs {
        let t0 = Instant::now();
        // black_box on the argument stops the optimizer from noticing the
        // call is loop-invariant and hoisting it out after the first run.
        value = fib(black_box(n));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: {}", value);
    println!("best_us: {:.3}", best);
}
