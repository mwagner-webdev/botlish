#!/usr/bin/env python3
"""seek.py -- POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md's UTF-8 seek
attribution. Observation only.

    python3 seek.py BINARY NAME=PROFILE_DIR ...

The runtime's three non-ASCII seeks each locate a character index by
decoding forward from byte 0 (native/src/runtime/ops.rs; each followed by
the same metrics.record_utf8_seek call):
    rt_substr            ops.rs:562-564
    rt_str_region_eq     ops.rs:613-615
    region_one_scalar    ops.rs:811-813   (rt_str_region_is_tcl_alnum/alpha)
This prints, per profile, the Ir/run of every instruction whose innermost
botlish-native runtime source frame (addr2line -i, walking outward from the
innermost inlined frame -- exactly cgcensus.py's "by runtime source line")
is one of those lines, i.e. the seek itself, excluding the copy/compare/
decode that follows. Same parser as cgcensus.py (post-M8.a cgprof.py);
figures are per collected run (runs = 20, bench 21 with run 0 excluded).
"""
import collections
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'post-m8a-common-inefficiency', 'tools'))
import cgprof  # noqa: E402

SEEK = {
    'rt_substr': (562, 564),
    'rt_str_region_eq': (613, 615),
    'region_one_scalar': (811, 813),
}
RUNS = 20


def seek_ir(binary, cg):
    events, self_cost, addr_fn, calls, totals = cgprof.parse_callgrind(cg)
    IR = events.index('Ir')
    want = collections.defaultdict(list)
    for addr, vals in self_cost.items():
        obj, fn = addr_fn.get(addr, ('?', '?'))
        if 'botlish-native' not in os.path.basename(obj or ''):
            continue
        for h in SEEK:
            if (fn or '').endswith('::' + h) or fn == h:
                want[h].append((addr, vals[IR]))
    addrs = sorted({a for lst in want.values() for a, _ in lst})
    out = subprocess.run(['addr2line', '-i', '-f', '-C', '-a', '-e', binary] + [hex(a) for a in addrs],
                         capture_output=True, text=True).stdout.splitlines()
    rtline = {}
    cur, chain, i = None, [], 0
    while i < len(out):
        line = out[i]
        if re.match(r'0x[0-9a-f]+$', line):
            if cur is not None:
                rtline[cur] = chain
            cur, chain = int(line, 16), []
            i += 1
            continue
        chain.append(out[i + 1] if i + 1 < len(out) else '?')
        i += 2
    if cur is not None:
        rtline[cur] = chain
    res = {}
    for h, lst in want.items():
        lo, hi = SEEK[h]
        s = 0
        for a, x in lst:
            loc = next((l for l in rtline.get(a, []) if '/src/runtime/ops.rs' in l), '')
            m = re.search(r'ops\.rs:(\d+)', loc)
            if m and lo <= int(m.group(1)) <= hi:
                s += x
        res[h] = s / RUNS
    return res


def main():
    binary = sys.argv[1]
    rows = []
    for a in sys.argv[2:]:
        name, path = a.split('=', 1)
        rows.append((name, seek_ir(binary, os.path.join(path, 'callgrind.out'))))
    hs = list(SEEK)
    print('| profile | ' + ' | '.join(f'{h} seek' for h in hs) + ' | total seek Ir/run |')
    print('|---|' + '---:|' * (len(hs) + 1))
    for name, r in rows:
        print(f'| {name} | ' + ' | '.join(f'{r.get(h, 0):,.0f}' for h in hs) + f' | {sum(r.values()):,.0f} |')


if __name__ == '__main__':
    main()
