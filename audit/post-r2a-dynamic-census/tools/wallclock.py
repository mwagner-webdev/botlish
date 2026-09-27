#!/usr/bin/env python3
"""wallclock.py -- the wall-clock sanity control (POST-R2A-DYNAMIC-CENSUS.md).
Observation only: the PRODUCTION botlish-native's own `bench RUNS FILE.nir`
(native::measure's path: one JIT compile, then RUNS in-process runs with
Vm::reset between them, each timed by main.rs's own Instant), repeated in
SESSIONS independent processes, interleaved across programs so slow drift
on a shared host hits every program alike.

    python3 wallclock.py BINARY SESSIONS RUNS NAME=FILE.nir ...

Per program: the median over sessions of each session's best run (the
bench.tcl convention, best-of-N, JIT excluded), the best run overall, and
the median of every run except each session's first (warm-up).
"""
import statistics
import subprocess
import sys


def main():
    binary, sessions, runs = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    progs = [a.split('=', 1) for a in sys.argv[4:]]
    data = {n: {'best': [], 'all': []} for n, _ in progs}
    for s in range(sessions):
        for name, path in progs:
            out = subprocess.run([binary, 'bench', str(runs), path], capture_output=True, text=True,
                                 env={'LANG': 'C.utf8', 'LC_ALL': 'C.utf8'}).stdout
            times = next(l for l in out.splitlines() if l.startswith('times ')).split()[1:]
            ns = [int(t) for t in times]
            data[name]['best'].append(min(ns))
            data[name]['all'].extend(ns[1:])
    print(f'sessions={sessions} runs/session={runs} (first run of each session excluded from the all-runs median)')
    print('| program | median of session bests (µs) | best (µs) | median of all runs (µs) | session-best range (µs) |')
    print('|---|---:|---:|---:|---:|')
    for name, _ in progs:
        b = data[name]['best']
        print(f'| {name} | {statistics.median(b) / 1000:.1f} | {min(b) / 1000:.1f} | {statistics.median(data[name]["all"]) / 1000:.1f} | {min(b) / 1000:.1f}-{max(b) / 1000:.1f} |')


if __name__ == '__main__':
    main()
