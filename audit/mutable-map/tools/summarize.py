#!/usr/bin/env python3
"""summarize.py -- bench/mutable-map.tcl's rows (TSV) as Markdown tables
(ORDERED-MUTABLE-MAP-SET.md, "Performance"): one table per key kind, a row
per mode, a column per size, ns per operation. Later rows of the same key
kind, size and mode replace earlier ones (a rerun of some modes appended
to a file).

    python3 -I audit/mutable-map/tools/summarize.py FILE ?KIND...?
"""
import sys
from collections import OrderedDict

def main(argv):
    rows = OrderedDict()
    sizes = set()
    for line in open(argv[1], encoding='utf-8'):
        f = line.rstrip('\n').split('\t')
        if len(f) < 7:
            continue
        kind, n, mode, per = f[0], int(f[1]), f[2], f[6]
        rows[(kind, mode, n)] = per
        sizes.add(n)
    kinds = argv[2:] or list(OrderedDict.fromkeys(k for k, _, _ in rows))
    sizes = sorted(sizes)
    for kind in kinds:
        modes = list(OrderedDict.fromkeys(m for k, m, _ in rows if k == kind))
        present = [n for n in sizes if any((kind, m, n) in rows for m in modes)]
        print('%s, ns per operation:\n' % kind)
        print('| mode | ' + ' | '.join(str(n) for n in present) + ' |')
        print('|---|' + '---:|' * len(present))
        for m in modes:
            print('| %s | ' % m + ' | '.join(rows.get((kind, m, n), '--') for n in present) + ' |')
        print()
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
