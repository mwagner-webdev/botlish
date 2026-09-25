#!/usr/bin/env python3
"""bench-summary.py -- median / min / max / spread of the per-session
best-of-5 times in bench-baseline.sh's bench-session-*.md files
(COMPREHENSIVE-GENERATED-CODE-AUDIT.md, benchmark baseline).

    python3 audit/comprehensive-generated-code/tools/bench-summary.py DIR
"""
import glob
import re
import statistics
import sys

UNITS = {'us': 1.0, 'ms': 1000.0}


def micros(cell):
    m = re.match(r'([0-9.]+) (us|ms)$', cell.strip())
    return float(m.group(1)) * UNITS[m.group(2)] if m else None


def fmt(us):
    return f'{us / 1000:.1f} ms' if us >= 1000 else f'{us:.2f} us'


def main(directory):
    files = sorted(glob.glob(f'{directory}/bench-session-*.md'))
    columns = None
    data = {}
    for path in files:
        for line in open(path, encoding='utf-8'):
            if not line.startswith('| '):
                continue
            cells = [c.strip() for c in line.strip().strip('|').split('|')]
            if cells[0] == 'program':
                columns = cells[1:7]
                continue
            if not cells[0].endswith('.ir'):
                continue
            for col, cell in zip(columns, cells[1:7]):
                v = micros(cell)
                if v is not None:
                    data.setdefault((cells[0], col), []).append(v)
    print(f'sessions: {len(files)} (each: best of 5 runs)')
    print('| program | backend | median | min | max | spread (max/min - 1) |')
    print('|---|---|---:|---:|---:|---:|')
    for (prog, col), vs in sorted(data.items()):
        spread = max(vs) / min(vs) - 1
        print(f'| {prog} | {col} | {fmt(statistics.median(vs))} | {fmt(min(vs))} | {fmt(max(vs))} | {100 * spread:.0f}% |')


if __name__ == '__main__':
    main(sys.argv[1])
