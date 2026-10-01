#!/usr/bin/env python3
"""compare.py OUTDIR -- three-way comparison (pre-struct parent / structs
milestone "base" / this tree "after") of the workloads-{parent,base,after}-run*.txt
files workloads.tcl wrote: best-of-15 native time (min and median over the
interleaved rounds), allocations by kind, bytes, GC cycles, code size, NIR
op counts."""
import re, sys, glob, statistics
def parse(path):
    out = {}; cur = None
    for line in open(path):
        line = line.rstrip('\n')
        if line.startswith('== '): cur = line[3:]; out[cur] = {'kinds': {}}
        elif cur is None: continue
        elif line.startswith('native best'):
            out[cur]['us'] = float(re.search(r': ([0-9.]+)', line).group(1))
        elif line.startswith('alloc total'):
            m = re.search(r'(\d+) allocations, (\d+) bytes, peak (\d+)', line)
            out[cur]['allocs'], out[cur]['bytes'], out[cur]['peak'] = map(int, m.groups())
        elif line.startswith('gc cycles'): out[cur]['gc'] = int(line.split(': ')[1])
        elif line.startswith('byKind '):
            m = re.match(r'byKind (\w+): allocations (\d+) allocatedBytes (\d+)', line)
            out[cur]['kinds'][m.group(1)] = (int(m.group(2)), int(m.group(3)))
        elif line.startswith('machine code bytes'): out[cur]['code'] = int(line.split(': ')[1])
        elif line.startswith('emitted functions'): out[cur]['funcs'] = int(line.split(': ')[1])
        elif line.startswith('nir lines'): out[cur]['nir'] = int(line.split(': ')[1])
        elif line.startswith('nir guard'): out[cur]['guards'] = int(line.split(': ')[1])
        elif line.startswith('nir retmulti'):
            m = re.match(r'nir retmulti: (\d+)\s+callmulti: (\d+)', line)
            out[cur]['retmulti'], out[cur]['callmulti'] = int(m.group(1)), int(m.group(2))
        elif line.startswith('nir structnew'):
            m = re.match(r'nir structnew: (\d+)\s+structget: (\d+)', line)
            out[cur]['structnew'], out[cur]['structget'] = int(m.group(1)), int(m.group(2))
        elif line.startswith('nir call:'):
            out[cur]['calls'] = int(re.search(r'call: (\d+)', line).group(1))
    return out
d = sys.argv[1]
trees = ['parent', 'base', 'after']
runs = {t: [parse(p) for p in sorted(glob.glob('%s/workloads-%s-run*.txt' % (d, t)))] for t in trees}
names = list(runs['after'][0])
def us(t, w):
    v = [r[w]['us'] for r in runs[t] if w in r]; return min(v), statistics.median(v)
def pct(a, b): return 100.0 * (a - b) / b
print('## Runtime: best-of-15 per round, min / median over %d interleaved rounds (us)' % len(runs['after']))
print('%-32s %18s %18s %18s %9s %9s %9s %9s' % ('workload', 'parent', 'structs', 'after', 'a/s min', 'a/s med', 'a/p min', 'a/p med'))
for w in names:
    p, b, a = us('parent', w), us('base', w), us('after', w)
    print('%-32s %8.1f /%8.1f %8.1f /%8.1f %8.1f /%8.1f %+8.1f%% %+8.1f%% %+8.1f%% %+8.1f%%' % (w, *p, *b, *a, pct(a[0], b[0]), pct(a[1], b[1]), pct(a[0], p[0]), pct(a[1], p[1])))
print()
print('## Allocation (deterministic): total allocations / Struct allocations / bytes / GC cycles')
print('%-32s %s' % ('workload', 'parent | structs | after'))
for w in names:
    row = []
    for t in trees:
        r = runs[t][0][w]
        row.append('%d/%d/%d/%dgc' % (r['allocs'], r['kinds'].get('Struct', (0, 0))[0], r['bytes'], r['gc']))
    print('%-32s %s' % (w, ' | '.join(row)))
print()
print('## Allocations by kind (count): List, MutableArray, String, StringPlan, Struct')
for w in names:
    for t in trees:
        r = runs[t][0][w]['kinds']
        print('%-32s %-7s ' % (w, t) + ' '.join('%s %d' % (k, r.get(k, (0, 0))[0]) for k in ('List', 'MutableArray', 'String', 'StringPlan', 'Struct')))
print()
print('## Code: machine-code bytes / emitted functions / NIR lines / guards / calls / structnew / structget / callmulti / retmulti')
for w in names:
    for t in trees:
        r = runs[t][0][w]
        print('%-32s %-7s %6d B %3d fn %5d lines %3d guards %4s calls  sn %s sg %s cm %s rm %s' % (w, t, r['code'], r['funcs'], r['nir'], r['guards'], r.get('calls', '?'), r.get('structnew', '-'), r.get('structget', '-'), r.get('callmulti', '-'), r.get('retmulti', '-')))
