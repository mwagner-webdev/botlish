#!/usr/bin/env python3
# Python equivalent of bench/fib.ir: naive recursive Fibonacci.
#
# Invoked by bench/bench.tcl for the interp/compile/python/rust comparison
# table. Prints a "value:"/"best_us:" pair for the caller to parse; n comes
# from argv (default matches the literal in fib.ir) so nothing here is a
# compile-time constant to an optimizing runtime.
import sys
import time


def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)


def parse_args(argv):
    runs = 5
    positional = []
    i = 0
    while i < len(argv):
        if argv[i] == "--runs":
            i += 1
            runs = int(argv[i])
        else:
            positional.append(argv[i])
        i += 1
    return runs, positional


if __name__ == "__main__":
    runs, positional = parse_args(sys.argv[1:])
    n = int(positional[0]) if positional else 28

    fib(n)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = fib(n)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {value}")
    print(f"best_us: {best:.3f}")
