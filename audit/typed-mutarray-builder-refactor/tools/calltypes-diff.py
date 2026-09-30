#!/usr/bin/env python3
"""calltypes-diff.py ON.txt OFF.txt -- per program: exact-block call sites,
sites whose instance-typed (ON) result differs from the instance-less (OFF)
one; then every differing site of the geometric-builder programs."""
import sys, re, collections
def load(p):
    prog = None; out = collections.OrderedDict()
    for line in open(p, encoding='utf-8'):
        line = line.rstrip('\n')
        if line.startswith('== '):
            prog = line[3:]; out[prog] = []
        elif line.strip():
            out[prog].append(line)
    return out
on, off = load(sys.argv[1]), load(sys.argv[2])
tot = imp = 0
print('%-22s %6s %9s' % ('program', 'sites', 'improved'))
for prog in on:
    n = len(on[prog]); d = sum(1 for a, b in zip(on[prog], off[prog]) if a != b)
    tot += n; imp += d
    print('%-22s %6d %9d' % (prog, n, d))
print('%-22s %6d %9d' % ('TOTAL', tot, imp))
if len(sys.argv) > 3:
    for prog in sys.argv[3:]:
        print('\n-- differing sites in', prog)
        for a, b in zip(on[prog], off[prog]):
            if a != b:
                loc = a.split(':')[0].strip(); name = a[9:33].strip()
                print('  %-8s %-24s off: %-24s on: %s' % (loc, name, b.split(' : ',1)[1], a.split(' : ',1)[1]))
