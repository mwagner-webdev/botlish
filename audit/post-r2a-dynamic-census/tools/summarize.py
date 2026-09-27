#!/usr/bin/env python3
"""summarize.py -- one row of headline metrics per profile directory
(POST-R2A-DYNAMIC-CENSUS.md's cross-profile tables). Observation only:
reads each directory's census.txt (cgcensus.py) and mix.txt (cgprof.py).

    python3 summarize.py PROFILE-DIR...
"""
import re
import sys


def num(s):
    return float(s.replace(',', ''))


def load(d):
    txt = open(f'{d}/census.txt', encoding='utf-8').read()
    r = {'dir': d}
    r['Ir'] = num(re.search(r'total Ir/run: ([\d,]+)', txt).group(1))
    m = re.search(r'botlish ([\d,]+) \(', txt)
    r['jit'] = num(m.group(1)) if m else 0
    # helper inclusive (runtime table): name -> (invocations, incl)
    helpers = {}
    for line in txt.splitlines():
        m = re.match(r'  (\S.*?)\s+([\d,]+|\?)\s+self\s+([\d,]+) \(\s*[\d.]+%\)\s+incl\s+([\d,]+) \(', line)
        if m:
            helpers[m.group(1).strip()] = (0 if m.group(2) == '?' else num(m.group(2)), num(m.group(4)))
    r['helpers'] = helpers
    # Botlish functions
    fns = {}
    sec = txt.split('== Botlish functions')[1].split('==')[0]
    for line in sec.splitlines()[2:]:
        m = re.match(r'\s+(\d+) (.+?)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s', line)
        if m:
            name = m.group(2).strip()
            fns.setdefault(name, []).append(dict(invoc=num(m.group(3)), self=num(m.group(5)) + num(m.group(6)), incl=num(m.group(7))))
    r['fns'] = fns
    arcs = {}
    sec = txt.split('== calls out of Botlish code')[1].split('\n==')[0]
    for line in sec.splitlines()[1:]:
        m = re.match(r'\s+(\d+ .+?)\s+-> (.+?)\s+([\d,]+)\s+([\d,]+)\s+[\d.]+\s+[\d.]+%', line)
        if m:
            arcs[(m.group(1).strip(), m.group(2).strip())] = (num(m.group(3)), num(m.group(4)))
    r['arcs'] = arcs
    return r


def H(r, name):
    return r['helpers'].get(name, (0, 0))


def main():
    rows = [load(d) for d in sys.argv[1:]]
    print('| profile | Ir/run | generated code | rt_substr calls | rt_substr incl | rt_call_value calls | rt_call_value incl | rt_closure_new incl | rt_set_contains incl | region helpers incl |')
    print('|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|')
    for r in rows:
        reg = sum(H(r, n)[1] for n in ('rt_str_region_eq', 'rt_str_region_is_tcl_alnum', 'rt_str_region_is_tcl_alpha', 'rt_str_region_check'))
        print(f"| {r['dir']} | {r['Ir']:,.0f} | {r['jit']:,.0f} ({100 * r['jit'] / r['Ir']:.1f}%) | {H(r, 'rt_substr')[0]:,.0f} | {H(r, 'rt_substr')[1]:,.0f} ({100 * H(r, 'rt_substr')[1] / r['Ir']:.1f}%) "
              f"| {H(r, 'rt_call_value')[0]:,.0f} | {H(r, 'rt_call_value')[1]:,.0f} ({100 * H(r, 'rt_call_value')[1] / r['Ir']:.1f}%) | {H(r, 'rt_closure_new')[1]:,.0f} | {H(r, 'rt_set_contains')[1]:,.0f} | {reg:,.0f} |")


if __name__ == '__main__':
    main()
