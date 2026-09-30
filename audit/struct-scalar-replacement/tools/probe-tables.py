#!/usr/bin/env python3
"""probe-tables.py FILE -- reformats a probes.tcl output file as Markdown
tables: one row per probe, the physical / virtual / default modes side by
side (Struct allocations per run, code bytes of the functions under test,
stack-slot operands, ns per iteration)."""
import re, sys, collections
rows = collections.OrderedDict()
pat = re.compile(r'^(\S.*?)\s+(physical|virtual|default)\s+struct-allocs\s+(\d+)\s+structnew\s+(\d+) callmulti\s+(\d+)\s+fn-params\s+(\S*)\s+code\s+(\d+) B \(fns\s+(\d+) B\)\s+stack-ops\s+(\d+)\s+([\d.]+) us\s+([\d.]+) ns/iter')
for line in open(sys.argv[1]):
    m = pat.match(line)
    if not m: continue
    name, mode, allocs, sn, cm, params, code, fns, stack, us, ns = m.groups()
    rows.setdefault(name, {})[mode] = (int(allocs), int(sn), int(cm), int(code), int(fns), int(stack), float(ns))
print('| probe | struct allocs p/v/d | fn code bytes p/v/d | stack ops p/v/d | ns/iter p/v/d |')
print('|---|---|---|---|---|')
for name, r in rows.items():
    def col(i, fmt='%d'):
        return '/'.join(fmt % r[m][i] for m in ('physical', 'virtual', 'default') if m in r)
    print('| %s | %s | %s | %s | %s |' % (name, col(0), col(4), col(5), col(6, '%.1f')))
