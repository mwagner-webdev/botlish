#!/usr/bin/env python3
"""codesize.py BEFORE-DIR AFTER-DIR -- per-program and per-function machine-code
bytes of two audit/native-scalar-asm-shaped corpora (native/generate-scalar-
audit.tcl -outdir DIR), from the `machine-code bytes: N (per function: ...)`
line and the `functions:` table of every *.summary.txt. EXACT-CALLABLE-CLOSED-
CALLER.md. Prints a markdown table of totals and, per program, the functions
whose label or size changed."""
import sys, os, re, glob
def load(d):
    out = {}
    for f in sorted(glob.glob(os.path.join(d, '**', '*.summary.txt'), recursive=True)):
        name = os.path.relpath(f, d).replace('.summary.txt', '')
        t = open(f).read()
        m = re.search(r'machine-code bytes: (\d+) \(per function: ([0-9 ]+)\)', t)
        if not m: continue
        sizes = [int(x) for x in m.group(2).split()]
        labels = re.findall(r'^\s+\d+ (.*?): nir-regs=', t, re.M)
        out[name] = (int(m.group(1)), list(zip(labels, sizes)))
    return out
b = load(sys.argv[1]); a = load(sys.argv[2])
print('| program | functions before | functions after | bytes before | bytes after | delta |')
print('|---|---:|---:|---:|---:|---:|')
tb = ta = 0
for k in sorted(set(a) | set(b)):
    bb = b.get(k, (0, [])); aa = a.get(k, (0, []))
    tb += bb[0]; ta += aa[0]
    print(f'| {k} | {len(bb[1])} | {len(aa[1])} | {bb[0]} | {aa[0]} | {aa[0]-bb[0]:+d} |')
print(f'| **total** | | | {tb} | {ta} | {ta-tb:+d} ({(ta-tb)*100.0/tb:+.2f}%) |')
print()
for k in sorted(set(a) | set(b)):
    bb = dict(); aa = dict()
    for l, s in b.get(k, (0, []))[1]: bb.setdefault(l, []).append(s)
    for l, s in a.get(k, (0, []))[1]: aa.setdefault(l, []).append(s)
    rows = []
    for l in sorted(set(aa) | set(bb)):
        if aa.get(l) != bb.get(l):
            rows.append((l, ','.join(map(str, bb.get(l, ['-']))), ','.join(map(str, aa.get(l, ['-'])))))
    if rows:
        print(f'### {k}')
        print('| function | before | after |')
        print('|---|---:|---:|')
        for r in rows: print(f'| `{r[0]}` | {r[1]} | {r[2]} |')
        print()
