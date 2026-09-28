#!/usr/bin/env python3
"""cfdelta.py -- POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md's before/after
comparison of two or more census.txt files (audit/post-r2a-dynamic-census/
tools/cgcensus.py output). Observation only: it only re-reads the census
text.

    python3 cfdelta.py NAME=PROFILE_DIR NAME=PROFILE_DIR ...

The first profile is the reference; every later column is printed with its
delta against it. Sections:
  * total Ir/run and the exclusive code-kind split (generated Botlish,
    runtime helpers, libc, other Rust);
  * per Botlish function: exact invocations, self Ir (direct + generic
    entry) and inclusive Ir -- matched by NAME, not NIR function number
    (numbers shift when the counterfactual adds a function);
  * per runtime/libc function: exact invocations, self and inclusive Ir.
Rows whose values are identical in every profile are omitted unless -a.
"""
import re
import sys


def num(s):
    s = s.replace(',', '')
    return None if s == '?' else float(s)


def load(path):
    d = {'fn': {}, 'rt': {}, 'kind': {}}
    sec = None
    for line in open(path, encoding='utf-8'):
        if line.startswith('total Ir/run:'):
            d['total'] = num(line.split(':')[1].strip())
            continue
        if line.startswith('exclusive Ir by code kind:'):
            for k, v in re.findall(r'(\S+) ([\d,]+) \(', line):
                d['kind'][k] = num(v)
            continue
        if line.startswith('== Botlish functions'):
            sec = 'fn'
            continue
        if line.startswith('== runtime/libc functions'):
            sec = 'rt'
            continue
        if line.startswith('=='):
            sec = None
            continue
        if sec == 'fn':
            m = re.match(r'\s+\d+ (.+?)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s', line)
            if m:
                name = m.group(1).strip()
                inv, einv, sd, se, inc = (num(m.group(i)) for i in range(2, 7))
                # the materializing / region char_at companions share a name:
                # tell them apart by their direct self cost per call (region
                # companion 46/call, materializing 34/call).
                if name == 'char_at':
                    name = 'char_at (region)' if inv and sd / inv > 40 else 'char_at (materializing)'
                d['fn'][name] = (inv, sd + se, inc)
        if sec == 'rt':
            m = re.match(r'\s+(.+?)\s+([\d,?]+)\s+self\s+([\d,]+) \(.*?incl\s+([\d,]+)', line)
            if m:
                d['rt'][m.group(1).strip()] = (num(m.group(2)), num(m.group(3)), num(m.group(4)))
    return d


def fmt(v):
    return '-' if v is None else f'{v:,.0f}'


def dfmt(v, ref):
    if v is None or ref is None:
        return ''
    dv = v - ref
    return '' if abs(dv) < 0.5 else f' ({dv:+,.0f})'


def main():
    args = [a for a in sys.argv[1:] if a != '-a']
    show_all = '-a' in sys.argv[1:]
    profs = []
    for a in args:
        name, path = a.split('=', 1)
        profs.append((name, load(path + '/census.txt')))
    ref = profs[0][1]
    print('| | ' + ' | '.join(n for n, _ in profs) + ' |')
    print('|---|' + '---:|' * len(profs))
    print('| total Ir/run | ' + ' | '.join(fmt(p['total']) + dfmt(p['total'], ref['total']) for _, p in profs) + ' |')
    for k in ('botlish', 'runtime', 'libc', 'rust-other'):
        print(f'| {k} (exclusive) | ' + ' | '.join(
            fmt(p['kind'].get(k)) + dfmt(p['kind'].get(k), ref['kind'].get(k)) for _, p in profs) + ' |')
    print()
    for sec, title in (('fn', 'Botlish function'), ('rt', 'runtime/libc function')):
        names = []
        for _, p in profs:
            for n in p[sec]:
                if n not in names:
                    names.append(n)
        print(f'| {title} | ' + ' | '.join(f'{n} invocations | {n} self | {n} inclusive' for n, _ in profs) + ' |')
        print('|---|' + '---:|' * (3 * len(profs)))
        for n in names:
            vals = [p[sec].get(n, (0, 0, 0)) for _, p in profs]
            if not show_all and all(v == vals[0] for v in vals):
                continue
            r = ref[sec].get(n, (0, 0, 0))
            cells = []
            for v in vals:
                cells += [fmt(v[0]) + dfmt(v[0], r[0]), fmt(v[1]) + dfmt(v[1], r[1]), fmt(v[2]) + dfmt(v[2], r[2])]
            print(f'| {n} | ' + ' | '.join(cells) + ' |')
        print()


if __name__ == '__main__':
    main()
