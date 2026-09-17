// Rust equivalent of bench/loop-count.ir: a loop whose body does integer
// work on bindings local to the iteration, driven by an outer recursion.
//
// Invoked by bench/bench.tcl; see fib.rs for the --runs/value/best_us
// protocol shared by all four equivalents.
use std::hint::black_box;
use std::time::Instant;

#[inline(never)]
fn work(i: i64) -> i64 {
    loop {
        let a = i * 3;
        let b = a + 7;
        if b >= 0 {
            return b - a;
        }
        // else: continue looping (unreachable for the inputs used here)
    }
}

#[inline(never)]
fn drive(i: i64, total: i64) -> i64 {
    if i <= 0 {
        total
    } else {
        drive(i - 1, total + work(i))
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
    let i0: i64 = positional.get(0).map(|s| s.parse().expect("i must be an integer")).unwrap_or(500);
    let total0: i64 = positional.get(1).map(|s| s.parse().expect("total must be an integer")).unwrap_or(0);

    drive(black_box(i0), black_box(total0)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = 0;
    for _ in 0..runs {
        let t0 = Instant::now();
        // black_box on the arguments stops the optimizer from noticing the
        // call is loop-invariant and hoisting it out after the first run.
        value = drive(black_box(i0), black_box(total0));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: {}", value);
    println!("best_us: {:.3}", best);
}
