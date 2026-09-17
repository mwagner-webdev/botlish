#!/usr/bin/env python3
# Python equivalent of bench/loop-count.ir: a loop whose body does integer
# work on bindings local to the iteration, driven by an outer recursion.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all four equivalents.
import sys
import time


def work(i):
    while True:
        a = i * 3
        b = a + 7
        if b >= 0:
            return b - a
        # else: continue looping (unreachable for the inputs used here)


def drive(i, total):
    if i <= 0:
        return total
    return drive(i - 1, total + work(i))


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
    i0 = int(positional[0]) if len(positional) > 0 else 500
    total0 = int(positional[1]) if len(positional) > 1 else 0

    drive(i0, total0)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = drive(i0, total0)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {value}")
    print(f"best_us: {best:.3f}")
