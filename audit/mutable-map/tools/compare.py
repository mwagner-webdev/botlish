#!/usr/bin/env python3
"""compare.py -- std::mutable_map beside the hash-table experiment's tables
and the Rust reference (ORDERED-MUTABLE-MAP-SET.md, "Performance"), as
Markdown tables: one per key kind, a row per operation and size, ns per
operation.

    python3 -I audit/mutable-map/tools/compare.py PRODUCTION EXPERIMENT RUST ?KIND...?

PRODUCTION is bench/mutable-map.tcl's rows (keys n mode m reps best-us
per-op checksum), EXPERIMENT audit/hash-table/tools/bench.tcl's (tag impl
keys backend n mode ...), RUST the reference's sweep (impl keys mode n m
reps policy per-op checksum). The operations are matched by meaning:

    insert (growing)    build      build      build
    insert (presized)   presized   presized   presized
    hit                 hit (at)   hit (get)  hit
    miss                has-miss   miss (get with a default: no failure)
    replace             replace    replace    replace
    remove              remove     drop       drop

(a MutableMap miss through `at` raises KeyNotFound, which the experiment's
`get` never does: its own row, `at` miss, is the production table's
`miss`). The experiment's `cd` cannot remove (`# drop: no`).
"""
import sys
from collections import OrderedDict

OPS = [
    ('insert (growing)', 'build', 'build', 'build'),
    ('insert (presized)', 'presized', 'presized', 'presized'),
    ('hit', 'hit', 'hit', 'hit'),
    ('miss', 'has-miss', 'miss', 'miss'),
    ('`at` miss (KeyNotFound)', 'miss', None, None),
    ('replace', 'replace', 'replace', 'replace'),
    ('remove', 'remove', 'drop', 'drop'),
]

def rows(path, fields):
    out = {}
    for line in open(path, encoding='utf-8'):
        f = line.rstrip('\n').split('\t')
        if len(f) < 8:
            continue
        key, value = fields(f)
        out[key] = value
    return out

def fmt(v):
    if v is None:
        return '--'
    x = float(v)
    return '%.0f' % x if x >= 100 else '%.1f' % x

def main(argv):
    prod = rows(argv[1], lambda f: ((f[0], int(f[1]), f[2]), f[6]))
    exp = rows(argv[2], lambda f: ((f[1], f[2], int(f[4]), f[5]), f[9]))
    rust = rows(argv[3], lambda f: ((f[0], f[1], int(f[3]), f[2]), f[7]))
    kinds = argv[4:] or list(OrderedDict.fromkeys(k for k, _, _ in prod))
    for kind in kinds:
        sizes = sorted({n for k, n, _ in prod if k == kind}
                       & {n for _, k, n, _ in exp if k == kind})
        if not sizes:
            continue
        print('%s, ns per operation (MutableMap / lpa / cd / Rust lp / Rust std):\n' % kind)
        print('| operation | n | MutableMap | `lpa` | `cd` | Rust `lp` | Rust `std` |')
        print('|---|---:|---:|---:|---:|---:|---:|')
        for label, p, e, r in OPS:
            for n in sizes:
                cells = [prod.get((kind, n, p))]
                cells += [exp.get((impl, kind, n, e)) if e else None for impl in ('lpa', 'cd')]
                cells += [rust.get((impl, kind, n, r)) if r else None for impl in ('lp', 'std')]
                if all(c is None for c in cells):
                    continue
                print('| %s | %d | %s |' % (label, n, ' | '.join(fmt(c) for c in cells)))
        print()
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
