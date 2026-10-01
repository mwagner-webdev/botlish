#!/usr/bin/env python3
"""opcounts.py BEFORE.nir AFTER.nir [REGEX] -- per NIR function: tagged int ops
(iadd isub ilt ile igt ige ieq ine imod imul), raw int ops (ri*), guards and call
forms, before and after. EXACT-CALLABLE-CLOSED-CALLER.md ("Which machine checks
disappear"): a tagged op that becomes raw drops its tag test / Bool word /
overflow check and cold rt_int_* path."""
import re, sys, collections
def parse(path):
    funcs = collections.OrderedDict(); cur = None
    for line in open(path):
        m = re.match(r'func \d+ "([^"]*)".*instance="([^"]*)"', line)
        if m:
            cur = m.group(1) + '<' + m.group(2) + '>'; funcs[cur] = collections.Counter(); continue
        if cur is None: continue
        m = re.match(r'\s+%\d+ = op (\w+)', line)
        if m: funcs[cur][m.group(1)] += 1
        if 'guard ' in line: funcs[cur]['guard'] += 1
        for k in ('callvalue', 'callenv', 'callmulti'):
            if re.search(r'= ' + k + r'\b', line) or (k == 'callmulti' and 'callmulti' in line): funcs[cur][k] += 1
        if re.search(r'= call \d', line): funcs[cur]['call'] += 1
    return funcs
def summ(c):
    tagged = sum(v for k, v in c.items() if k in ('iadd','isub','ilt','ile','igt','ige','ieq','ine','imod','imul'))
    raw = sum(v for k, v in c.items() if k.startswith('ri'))
    return 'tagged=%d raw=%d guards=%d callvalue=%d call=%d callenv=%d callmulti=%d substr=%d' % (
        tagged, raw, c['guard'], c['callvalue'], c['call'], c['callenv'], c['callmulti'], c['substr'])
b = parse(sys.argv[1]); a = parse(sys.argv[2]); pat = re.compile(sys.argv[3] if len(sys.argv) > 3 else '.')
for name in sorted(set(a) | set(b)):
    if not pat.search(name): continue
    print('%-44s before: %s' % (name, summ(b[name]) if name in b else '-'))
    print('%-44s after : %s' % ('', summ(a[name]) if name in a else '-'))
