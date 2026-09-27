#!/usr/bin/env python3
"""class-matrix.py -- one table, workloads x executed-instruction classes,
from profile.sh output directories (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md).
Observation only.

    python3 class-matrix.py NAME=PROFILE-DIR ...
"""
import re
import sys

GROUPS = [
    ('frame (prologue/epilogue/zero slots)', ('frame: prologue', 'frame: epilogue', 'frame: root-slot zero')),
    ('register moves', ('mov reg-reg',)),
    ('tagged Int (tag test, overflow, retag, untag)', ('tag test', 'overflow check', 'retag', 'untag')),
    ('Bool word (materialize + test)', ('bool materialize', 'bool test')),
    ('stack traffic (root publish, spills, out-params)', ('stack store', 'stack load', 'lea (stack addr)')),
    ('completion checks', ('completion check',)),
    ('call instructions', ('call botlish', 'call helper')),
    ('heap/VM/const memory', ('heap/vm load', 'heap/vm store', 'const load')),
    ('other generated code (arith, cmp, jcc, jmp, imm, lea)', None),
]


def load(d):
    tot = None
    kinds = {}
    with open(f'{d}/profile.txt', encoding='utf-8') as f:
        for line in f:
            m = re.match(r'totals per run: Ir=([\d,]+)', line)
            if m:
                tot = float(m.group(1).replace(',', ''))
            m = re.match(r'  (botlish|runtime|libc|rust-other|other)\s+[\d.]+% of Ir\s+Ir=\s*([\d,.]+)', line)
            if m:
                kinds[m.group(1)] = float(m.group(2).replace(',', ''))
    mix = {}
    with open(f'{d}/mix.txt', encoding='utf-8') as f:
        in_total = False
        for line in f:
            if line.startswith('== total'):
                in_total = True
                continue
            if in_total and line.startswith('=='):
                break
            m = re.match(r'  (.+?)\s{2,}([\d,.]+)\s', line)
            if in_total and m:
                mix[m.group(1)] = float(m.group(2).replace(',', ''))
    return tot, kinds, mix


def main(args):
    names = [a.split('=', 1)[0] for a in args]
    data = [load(a.split('=', 1)[1]) for a in args]
    print('| class (% of ALL executed instructions per run) | ' + ' | '.join(names) + ' |')
    print('|---|' + '---:|' * len(names))
    print('| instructions per run | ' + ' | '.join(f'{t:,.0f}' for t, _, _ in data) + ' |')
    rows = []
    for label, classes in GROUPS:
        cells = []
        for tot, kinds, mix in data:
            if classes is None:
                used = set(c for _, cs in GROUPS if cs for c in cs)
                v = sum(x for k, x in mix.items() if k not in used)
            else:
                v = sum(mix.get(c, 0) for c in classes)
            cells.append(f'{100 * v / tot:.1f}%')
        rows.append(f'| {label} | ' + ' | '.join(cells) + ' |')
    print('| **generated code, total** | ' + ' | '.join(f"**{100 * k.get('botlish', 0) / t:.1f}%**" for t, k, _ in data) + ' |')
    print('\n'.join(rows))
    for kind, label in (('runtime', 'runtime helpers (Rust, exclusive)'), ('rust-other', 'Rust std inlined out of helpers'), ('libc', 'libc (malloc/free/memcpy/memcmp)')):
        print(f'| **{label}** | ' + ' | '.join(f"**{100 * k.get(kind, 0) / t:.1f}%**" for t, k, _ in data) + ' |')


if __name__ == '__main__':
    main(sys.argv[1:])
