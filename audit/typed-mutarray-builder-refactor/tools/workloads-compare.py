#!/usr/bin/env python3
"""workloads-compare.py BEFORE-DIR AFTER-DIR -- compares the workloads-run*.txt
files of two trees: best-of-15 native time (min and median over the runs),
allocations, bytes, per-kind allocations, gc cycles, code size."""
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
        elif line.startswith('copies'): out[cur]['copies'] = line[8:]
        elif line.startswith('byKind '):
            m = re.match(r'byKind (\w+): allocations (\d+) allocatedBytes (\d+)', line)
            out[cur]['kinds'][m.group(1)] = (int(m.group(2)), int(m.group(3)))
        elif line.startswith('machine code bytes'): out[cur]['code'] = int(line.split(': ')[1])
        elif line.startswith('emitted functions'): out[cur]['funcs'] = int(line.split(': ')[1])
        elif line.startswith('nir lines'): out[cur]['nir'] = int(line.split(': ')[1])
        elif line.startswith('nir guard'): out[cur]['guards'] = int(line.split(': ')[1])
        elif line.startswith('nir op '):
            m = re.match(r'nir op (\w+)\s+(\d+)', line); out[cur].setdefault('ops', {})[m.group(1)] = int(m.group(2))
    return out
def runs(d): return [parse(p) for p in sorted(glob.glob(d + '/workloads-run*.txt'))]
b, a = runs(sys.argv[1]), runs(sys.argv[2])
def stat(rs, w): 
    v = [r[w]['us'] for r in rs]; return min(v), statistics.median(v)
print('%-32s %22s %22s %8s' % ('workload', 'before us (min/med)', 'after us (min/med)', 'delta%'))
for w in b[0]:
    bm, bd = stat(b, w); am, ad = stat(a, w)
    print('%-32s %10.1f /%9.1f %10.1f /%9.1f %+7.1f%%' % (w, bm, bd, am, ad, 100.0 * (am - bm) / bm))
print()
print('%-32s %9s %9s %11s %11s %6s %6s' % ('workload', 'allocs B', 'allocs A', 'bytes B', 'bytes A', 'gc B', 'gc A'))
for w in b[0]:
    x, y = b[0][w], a[0][w]
    print('%-32s %9d %9d %11d %11d %6d %6d' % (w, x['allocs'], y['allocs'], x['bytes'], y['bytes'], x['gc'], y['gc']))
print()
print('%-32s %s' % ('workload', 'per-kind allocations (count/bytes) before -> after: List, MutableArray, String, StringPlan'))
for w in b[0]:
    x, y = b[0][w]['kinds'], a[0][w]['kinds']
    print('%-32s ' % w + '; '.join('%s %d/%d -> %d/%d' % (k, x[k][0], x[k][1], y[k][0], y[k][1]) for k in ('List', 'MutableArray', 'String', 'StringPlan')))
print()
print('%-32s %s' % ('workload', 'code bytes / emitted fns / nir lines / guards before -> after'))
for w in b[0]:
    x, y = b[0][w], a[0][w]
    print('%-32s %d/%d/%d/%d -> %d/%d/%d/%d' % (w, x['code'], x['funcs'], x['nir'], x['guards'], y['code'], y['funcs'], y['nir'], y['guards']))
