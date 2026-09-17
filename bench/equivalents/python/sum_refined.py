#!/usr/bin/env python3
# Python equivalent of bench/sum-refined.ir: tail-style recursion over an
# accumulator whose type is only known through an integer? refinement, plus
# a closure created per step.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all four equivalents.
import sys
import time


def sum_refined(n, acc):
    if not isinstance(acc, int):
        raise ValueError("not_an_integer")
    if n == 0:
        return acc
    step = lambda x: x + n
    return sum_refined(n - 1, step(acc))


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
    n0 = int(positional[0]) if len(positional) > 0 else 400
    acc0 = int(positional[1]) if len(positional) > 1 else 0

    sum_refined(n0, acc0)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = sum_refined(n0, acc0)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {value}")
    print(f"best_us: {best:.3f}")
