#!/usr/bin/env python3
"""compiletime.py -- Cranelift compile time (the driver's own `timing
COMPILE_US`, parse + validate + lowering to machine code) of the canonical
corpus NIR on the old and the new driver: median of N compiles per program,
summed over the corpus. The NIR planner and lowering are Tcl code this
milestone does not touch; their time is measured separately by running
emit-nir.tcl in each tree (see STRING-ALLOCATION.md).

    compiletime.py OLD-BIN NEW-BIN NIR-DIR [-n N]
"""
import os, re, statistics, subprocess, sys


def compile_us(binary, nir):
    out = subprocess.run([binary, "bench", "1", nir], capture_output=True, text=True, env=dict(os.environ, LANG="C.utf8")).stdout
    m = re.search(r"timing (\d+) (\d+)", out)
    return int(m.group(1))


def main():
    old, new, nirdir = sys.argv[1:4]
    n = 9
    if "-n" in sys.argv:
        n = int(sys.argv[sys.argv.index("-n") + 1])
    progs = sorted({f.split(".")[0] for f in os.listdir(nirdir)})
    tot = [0, 0]
    print(f"{'program':16} {'old us':>9} {'new us':>9}")
    for p in progs:
        nir = os.path.join(nirdir, f"{p}.default.nir")
        # interleave old/new so machine noise hits both
        runs = {0: [], 1: []}
        for _ in range(n):
            runs[0].append(compile_us(old, nir))
            runs[1].append(compile_us(new, nir))
        a, b = statistics.median(runs[0]), statistics.median(runs[1])
        tot[0] += a
        tot[1] += b
        print(f"{p:16} {a:9.0f} {b:9.0f}")
    print(f"{'TOTAL':16} {tot[0]:9.0f} {tot[1]:9.0f}  {100 * (tot[1] - tot[0]) / tot[0]:+.2f}%")


if __name__ == "__main__":
    main()
