#!/usr/bin/env python3
"""intclasses.py -- per-function executed tagged-Int / Bool-word / root-store
detail from a profile's instr.txt (cgprof.py), for
POST-R2A-DYNAMIC-CENSUS.md's tagged-Int, Bool/completion, counted-loop and
range<->blockescape sections. Observation only.

    python3 intclasses.py PROFILE-DIR [FUNCTION-NAME...]

For each function (direct + generic entry), per run:
  tag         tag tests (test R,0x1 / and R,R + test + jcc)
  ovf         overflow checks (seto / test / jcc)
  boolmat     compare -> Bool word: `mov R,0x2` + cmovCC [rip] (the
              immediate load is counted here when it directly precedes
              the cmov's compare)
  booltest-c  the `cmp R,0x6; jcc` that re-tests a Bool word the same
              function just materialized from a compare (branch-only)
  booltest-h  `cmp R,0x6; jcc` on any other Bool word (a helper/call
              result, a guardbool, a folded constant)
  guardbool   `or R,0x4` of a guardbool (Bool kind check on a dynamic
              result)
  compl       completion checks (test rax,rax; jcc after a call)
  rootst      stack stores into [rsp+N] (root-slot publication, spills,
              out-parameter/argument arrays -- not separable statically)
The "raw-Int removable" column is tag + ovf + boolmat + booltest-c minus
one compare+branch pair per materialized compare (a raw compare still
needs `cmp; jcc`): the instructions a proven small-Int representation of
the compared/incremented values would not execute. An upper bound: it
assumes EVERY tagged Int op in the function becomes raw.
"""
import collections
import re
import sys


def main():
    d = sys.argv[1]
    want = set(sys.argv[2:])
    rows = collections.defaultdict(list)
    for line in open(f'{d}/instr.txt', encoding='utf-8'):
        if line.startswith('#'):
            continue
        m = re.match(r'(0x[0-9a-f]+)\s+([\d,.]+)\s.*?\[(\d+) (.+?)(?: \(generic entry\))? \+0x[0-9a-f]+\]\s+(\S.*?)\s{2,}(\S.*)$', line.rstrip())
        if not m:
            continue
        addr, n, fid, name, cls, text = m.groups()
        rows[(int(fid), name)].append((int(addr, 16), float(n.replace(',', '')), cls.strip(), re.sub(r'\s+', ' ', text.split('#')[0]).strip()))
    print(f'| function | executed | tag | ovf | boolmat | booltest-c | booltest-h | guardbool | compl | rootst | raw-Int removable (upper bound) |')
    print('|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|')
    tot = collections.Counter()
    for (fid, name), ins in sorted(rows.items(), key=lambda kv: -sum(x[1] for x in kv[1])):
        if want and name not in want:
            continue
        ins.sort()
        c = collections.Counter()
        materialized_pairs = 0
        for i, (a, n, cls, t) in enumerate(ins):
            c['executed'] += n
            if cls == 'tag test':
                c['tag'] += n
            elif cls == 'overflow check':
                c['ovf'] += n
            elif cls == 'bool materialize':
                c['boolmat'] += n
                materialized_pairs += n
            elif cls == 'bool test':
                prev = ins[i - 1][2] if i > 0 else ''
                prev2 = ins[i - 2][2] if i > 1 else ''
                if prev == 'bool materialize' or (prev == 'bool test' and prev2 == 'bool materialize'):
                    c['booltest-c'] += n
                else:
                    c['booltest-h'] += n
            elif cls == 'logic' and re.match(r'or \w+,0x4$', t):
                c['guardbool'] += n
            elif cls == 'completion check':
                c['compl'] += n
            elif cls == 'stack store':
                c['rootst'] += n
            if cls == 'mov imm' and re.match(r'mov e?\w+,0x2$', t):
                nxt = [x[2] for x in ins[i + 1:i + 5]]
                if 'bool materialize' in nxt:
                    c['boolmat'] += n
        removable = c['tag'] + c['ovf'] + c['boolmat'] + c['booltest-c'] - 2 * materialized_pairs
        # a raw compare still needs cmp+jcc; the materialized form already
        # has its own cmp (cmp/test other) and the booltest's jcc, so the
        # saving per compare is: mov R,2 + cmov + cmp R,6 (3); subtracting
        # 2 per materialized compare from boolmat(2)+booltest-c(2)=4 leaves
        # 2... keep the documented conservative convention: count the
        # imm + cmov + cmp6 (3) as removable and keep the final jcc.
        removable = c['tag'] + c['ovf'] + (c['boolmat'] + c['booltest-c'] - materialized_pairs)
        for k in c:
            tot[k] += c[k]
        tot['removable'] += removable
        print(f"| {fid} {name} | {c['executed']:,.0f} | {c['tag']:,.0f} | {c['ovf']:,.0f} | {c['boolmat']:,.0f} | {c['booltest-c']:,.0f} | {c['booltest-h']:,.0f} | {c['guardbool']:,.0f} | {c['compl']:,.0f} | {c['rootst']:,.0f} | {removable:,.0f} |")
    print(f"| **total** | {tot['executed']:,.0f} | {tot['tag']:,.0f} | {tot['ovf']:,.0f} | {tot['boolmat']:,.0f} | {tot['booltest-c']:,.0f} | {tot['booltest-h']:,.0f} | {tot['guardbool']:,.0f} | {tot['compl']:,.0f} | {tot['rootst']:,.0f} | {tot['removable']:,.0f} |")


if __name__ == '__main__':
    main()
