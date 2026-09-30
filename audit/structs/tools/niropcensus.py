#!/usr/bin/env python3
"""niropcensus.py BEFORE-DIR AFTER-DIR -- NIR statement census of the NIR text
files audit/opportunistic-semantic-instances/tools/nir-all.tcl wrote for two
trees: per program, the counts STRUCTS.md reports (struct construction and
projection ops, listnew/listget, guards, calls, callvalue, multi-value
returns, functions, NIR lines)."""
import os, re, sys
COLUMNS = [
    ('structnew', r'= structnew '), ('structget', r'= structget '),
    ('listnew', r'= op listnew\b'), ('listget', r'= op listget\b|= listget\b'),
    ('guards', r'^\s+guard(bool)? '),
    ('calls', r'= call '), ('callmulti', r'= callmulti '),
    ('callvalue', r'= callvalue '), ('retmulti', r'^\s+retmulti '),
    ('funcs', r'^func '),
]
def census(path):
    text = open(path, encoding='utf-8').read()
    row = {name: len(re.findall(rx, text, re.M)) for name, rx in COLUMNS}
    row['lines'] = text.count('\n')
    return row
before, after = sys.argv[1], sys.argv[2]
names = sorted(f for f in os.listdir(after) if f.endswith('.nir'))
cols = [c for c, _ in COLUMNS] + ['lines']
print('%-16s %-7s' % ('program', '') + ' '.join('%9s' % c for c in cols))
total = {'before': {c: 0 for c in cols}, 'after': {c: 0 for c in cols}}
for n in names:
    b, a = census(os.path.join(before, n)), census(os.path.join(after, n))
    for label, row in (('before', b), ('after', a)):
        print('%-16s %-7s' % (n[:-4], label) + ' '.join('%9d' % row[c] for c in cols))
        for c in cols:
            total[label][c] += row[c]
for label in ('before', 'after'):
    print('%-16s %-7s' % ('TOTAL', label) + ' '.join('%9d' % total[label][c] for c in cols))
