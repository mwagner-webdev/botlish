#!/usr/bin/env python3
"""tables.py PROBES.tsv ?MODES? -- renders probes.tcl's tab-separated records as a
markdown table: per probe, for each mode (default physical,virtual,legacy,default),
Struct allocations, whole-program code bytes, bytes of the functions under test,
stack operands, argument/result registers of the functions under test and
ns/iteration."""
import sys, collections
path = sys.argv[1]
modes = (sys.argv[2] if len(sys.argv) > 2 else 'physical,virtual,legacy,default').split(',')
rows = collections.OrderedDict()
for line in open(path):
    f = line.rstrip('\n').split('\t')
    label, mode = f[0], f[1]
    rows.setdefault(label, {})[mode] = dict(structs=int(f[2]), bytes=int(f[3]), gc=int(f[4]), sn=int(f[5]),
        cm=int(f[6]), code=int(f[7]), fn=int(f[8]), stack=int(f[9]), ns=float(f[10]), sig=f[11])
def cell(r, key, fmt='%d'):
    return '/'.join(fmt % r[m][key] if m in r else '-' for m in modes)
print('| probe | Struct allocs ' + '/'.join(modes) + ' | GC cycles | fn code bytes | stack ops | ns/iter |')
print('|---|---|---|---|---|---|')
for label, r in rows.items():
    print('| %s | %s | %s | %s | %s | %s |' % (label, cell(r, 'structs'), cell(r, 'gc'), cell(r, 'fn'), cell(r, 'stack'), cell(r, 'ns', '%.1f')))
