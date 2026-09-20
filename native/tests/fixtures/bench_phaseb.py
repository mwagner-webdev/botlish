#!/usr/bin/env python3
# Run from repository root after generating fixtures and building both binaries.
import os
import statistics
import subprocess
import sys

before, after = sys.argv[1:3]
cases = [
    ("fib", "fib.nir", 20, False),
    ("sum-refined", "sum-refined.nir", 100, False),
    ("loop-count", "loop-count.nir", 100, False),
    ("build(400)", "build400.nir", 20, False),
    ("build(400), GC stress", "build400.nir", 5, True),
]
for label, name, runs, stress in cases:
    path = "native/tests/fixtures/" + name
    env = os.environ.copy()
    if stress:
        env["BOTLISH_NATIVE_GC_STRESS"] = "1"
    else:
        env.pop("BOTLISH_NATIVE_GC_STRESS", None)
    samples = {before: [], after: []}
    sizes = {}
    for round_number in range(5):
        order = (before, after) if round_number % 2 == 0 else (after, before)
        for binary in order:
            result = subprocess.run([binary, "bench", str(runs), path], env=env,
                                    text=True, capture_output=True, check=True)
            lines = result.stdout.splitlines()
            times = next(line for line in lines if line.startswith("times ")).split()[1:]
            if not any(line.startswith("value ") for line in lines):
                raise RuntimeError((label, binary, result.stdout))
            samples[binary].append(statistics.median(int(n) for n in times) / 1000)
            if binary not in sizes:
                size = subprocess.run([binary, "size", path], env=env, text=True,
                                      capture_output=True, check=True).stdout.split()
                sizes[binary] = int(size[1])
    old = statistics.median(samples[before])
    new = statistics.median(samples[after])
    change = (new / old - 1) * 100
    print(f"{label}: {old:.3f} -> {new:.3f} us ({change:+.1f}%); "
          f"code {sizes[before]} -> {sizes[after]} bytes", flush=True)
