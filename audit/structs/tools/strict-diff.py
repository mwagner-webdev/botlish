#!/usr/bin/env python3
"""strict-diff.py BEFORE-TABLE AFTER-TABLE -- compares two strict-counterfactual
tables (tools/strict-table.py output of the `variant-all-trusted`
counterfactual) site by site. A site is identified by (file, enclosing function,
what it says without the argument type), matched one-for-one in source order,
so `param stop needs int (arg any)` disappearing from scan_record and a
`param storage needs mutarray (arg MutableArray[str])` appearing in it are two
different sites. Prints the disappeared, remaining and new sites and totals;
the unbound-name forward-reference diagnostic of 09-mutual-recursion.bot is not
a strict contract site and is counted apart."""
import re, sys, collections

def load(path):
    sites = []
    for line in open(path, encoding='utf-8'):
        line = line.rstrip('\n')
        m = re.match(r'(\S+\.bot):(\d+):(\d+)\s+(\S+)\s+(.*)', line)
        if not m:
            continue
        f, ln, col, fn, what = m.groups()
        key = re.sub(r' \(arg .*\)$', '', what)
        key = re.sub(r'^invalid call: .*', 'invalid call', key)
        sites.append((f, fn, key, '%s:%s' % (ln, col), what))
    return sites

before, after = load(sys.argv[1]), load(sys.argv[2])
def bucket(sites):
    d = collections.defaultdict(list)
    for s in sites:
        d[s[:3]].append(s)
    return d
b, a = bucket(before), bucket(after)
gone, kept, new = [], [], []
for key in sorted(set(b) | set(a)):
    nb, na = len(b.get(key, [])), len(a.get(key, []))
    common = min(nb, na)
    kept += a.get(key, [])[:common]
    gone += b.get(key, [])[common:]
    new += a.get(key, [])[common:]
def show(title, sites):
    print('## %s (%d)' % (title, len(sites)))
    for f, fn, key, loc, what in sorted(sites):
        print('  %-24s %-22s %s  [%s]' % (f, fn, what[:110], loc))
    print()
unbound = lambda ss: [s for s in ss if 'unbound name' in s[4]]
print('before: %d lines (%d strict sites + %d forward-reference diagnostic)' % (len(before), len(before) - len(unbound(before)), len(unbound(before))))
print('after:  %d lines (%d strict sites + %d forward-reference diagnostic)' % (len(after), len(after) - len(unbound(after)), len(unbound(after))))
print()
show('disappeared', gone)
show('remaining (same file, function and kind)', kept)
show('new', new)
