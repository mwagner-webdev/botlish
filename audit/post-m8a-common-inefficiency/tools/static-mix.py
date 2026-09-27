#!/usr/bin/env python3
"""static-mix.py -- STATIC machine-code census of every JIT function of a
profile.sh output directory (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md):
per function (direct entry; generic-entry trampolines listed separately),
machine bytes and instruction counts by the same semantic classes
cgprof.py's dynamic mix uses -- unweighted, i.e. what is in the code, not
what executes. Observation only.

    python3 static-mix.py PROFILE-DIR
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from cgprof import load_jitmap, disassemble, classify_function  # noqa: E402

GROUPS = {
    'frame': ('frame: prologue', 'frame: epilogue', 'frame: root-slot zero'),
    'tagged-int': ('tag test', 'overflow check', 'retag', 'untag'),
    'bool word': ('bool materialize', 'bool test'),
    'stack traffic': ('stack store', 'stack load', 'lea (stack addr)'),
    'completion': ('completion check',),
    'calls': ('call botlish', 'call helper'),
    'moves': ('mov reg-reg',),
}


def main(d):
    funcs, _ = load_jitmap(os.path.join(d, 'jitmap.txt'))
    starts = {f['direct'] for f in funcs} | {f['entry'] for f in funcs}
    rows = []
    tot = collections.Counter()
    for f in funcs:
        insns = sorted(disassemble(f['dhex'], f['direct']).items())
        cls = classify_function(insns, starts)
        c = collections.Counter(cls.values())
        n = len(insns)
        g = {k: sum(c[x] for x in v) for k, v in GROUPS.items()}
        rows.append((f['id'], f['name'], f['dsize'], f['esize'], n, g, c))
        tot['bytes'] += f['dsize'] + f['esize']
        tot['insns'] += n
        for k, v in g.items():
            tot[k] += v
    out = [f"# static machine code per JIT function (direct entry); totals include generic entries' bytes",
           f"TOTAL bytes={tot['bytes']} direct-entry instructions={tot['insns']} " + ' '.join(f'{k}={tot[k]}' for k in GROUPS)]
    out.append('')
    out.append(f"{'id name':<28} {'bytes':>6} {'entry':>5} {'insns':>6} " + ' '.join(f'{k:>13}' for k in GROUPS))
    for fid, name, ds, es, n, g, c in rows:
        out.append(f"{str(fid) + ' ' + name:<28} {ds:>6} {es:>5} {n:>6} " + ' '.join(f'{g[k]:>13}' for k in GROUPS))
    with open(os.path.join(d, 'static-mix.txt'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out[:2]))


if __name__ == '__main__':
    main(sys.argv[1])
