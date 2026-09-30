#!/usr/bin/env python3
"""strict-table.py TREE STRICT.txt -- one line per strict-counterfactual site:
file:line:col, enclosing source function, parameter (or diagnostic kind) and
the argument type the diagnostic reports. TREE is the tree the strict run was
made in (to find each site's enclosing `fn`)."""
import re, sys, os
tree, path = sys.argv[1], sys.argv[2]
cache = {}
def enclosing(f, line):
    if f not in cache:
        cache[f] = open(f, encoding='utf-8').read().split('\n')
    for i in range(line - 1, -1, -1):
        m = re.match(r'fn ([A-Za-z0-9_?:]+)', cache[f][i])
        if m:
            return m.group(1)
    return '(top)'
prog = None
for raw in open(path, encoding='utf-8'):
    if not raw.startswith('    '):
        continue
    m = re.match(r'\s+(\S+\.bot):(\d+):(\d+): (.*)', raw)
    if not m:
        continue
    f, line, col, msg = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4)
    rel = os.path.relpath(f, tree) if os.path.isabs(f) else f
    p = re.match(r'argument for parameter "([^"]+)" cannot be proven to satisfy ([^,(]+?)(?:,| \()', msg)
    at = re.search(r'\(argument type: ([^,]+(?:\[[^\]]*\])?)', msg)
    if p:
        what = 'param %s needs %s (arg %s)' % (p.group(1), p.group(2).strip(), at.group(1) if at else '?')
    elif msg.startswith('cannot erase element contract'):
        what = 'erasure of element contract'
    elif msg.startswith('call to '):
        what = 'invalid call: ' + msg[:70]
    else:
        what = msg[:70]
    print('%s:%d:%d  %-20s %s' % (os.path.basename(rel), line, col, enclosing(os.path.join(tree, rel), line), what))
