#!/usr/bin/env python3
"""moves.py -- dead / redundant register-move census over a profile.sh
output directory (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md). Observation only.

    python3 moves.py PROFILE-DIR

Reads PROFILE-DIR/jitmap.txt (every JIT function's code bytes) and
PROFILE-DIR/instr.txt (per-instruction execution counts from callgrind),
disassembles every function in full, splits it into basic blocks (leaders:
entry, every branch target, every instruction after a jcc/jmp/ret), and
classifies every register-to-register `mov X,Y` as

  dead       the next access to X in the same block is a write that does
             not read X (so this move's value is never used), or a call
             that clobbers X without reading it
  redundant  X already holds Y's value: an earlier `mov X,Y` or `mov Y,X`
             in the same block with neither register written since
  other      everything else (including moves whose destination is live
             out of the block: conservatively counted as needed)

and reports their dynamic (executed) counts per function and in total.
Deliberately conservative: a move is only "dead"/"redundant" when the proof
is local to one basic block.
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from cgprof import load_jitmap, disassemble  # noqa: E402

REGS = ['rax', 'rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'rbp', 'rsp'] + [f'r{i}' for i in range(8, 16)]
ALIAS = {}
for r, subs in {
    'rax': ['eax', 'ax', 'al', 'ah'], 'rbx': ['ebx', 'bx', 'bl', 'bh'], 'rcx': ['ecx', 'cx', 'cl', 'ch'],
    'rdx': ['edx', 'dx', 'dl', 'dh'], 'rsi': ['esi', 'si', 'sil'], 'rdi': ['edi', 'di', 'dil'],
    'rbp': ['ebp', 'bp', 'bpl'], 'rsp': ['esp', 'sp', 'spl'],
}.items():
    ALIAS[r] = r
    for s in subs:
        ALIAS[s] = r
for i in range(8, 16):
    for suf in ('', 'd', 'w', 'b'):
        ALIAS[f'r{i}{suf}'] = f'r{i}'
ARGS = ['rdi', 'rsi', 'rdx', 'rcx', 'r8', 'r9']
CALLER_SAVED = ['rax', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11']


def regs_in(s):
    return {ALIAS[t] for t in re.findall(r'\b([a-z][a-z0-9]*)\b', s) if t in ALIAS}


def rw(text):
    """(reads, writes, full_write) register sets of one instruction."""
    t = re.sub(r'\s+', ' ', text.split('#')[0]).strip()
    mn = t.split(' ')[0]
    ops = t[len(mn):].strip()
    parts = [p.strip() for p in ops.split(',')] if ops else []
    reads, writes = set(), set()
    if mn == 'call':
        return set(ARGS) | regs_in(ops), set(CALLER_SAVED), True
    if mn == 'ret':
        return {'rax', 'rdx', 'rsp'}, set(), False
    if mn.startswith('j'):
        return regs_in(ops), set(), False
    if mn in ('push',):
        return regs_in(ops) | {'rsp'}, {'rsp'}, False
    if mn in ('pop',):
        return {'rsp'}, regs_in(ops) | {'rsp'}, False
    if not parts:
        return set(), set(), False
    dst = parts[0]
    srcs = parts[1:]
    for s in srcs:
        reads |= regs_in(s)
    if '[' in dst:
        reads |= regs_in(dst)          # address registers
        return reads, set(), False
    d = regs_in(dst)
    if mn in ('mov', 'movzx', 'movsx', 'movsxd', 'movabs', 'lea') or mn.startswith('set'):
        # 32-bit mov zero-extends: a full write. setcc writes a byte: partial.
        full = not mn.startswith('set') and not re.match(r'^(ax|bx|cx|dx|si|di|[a-d][lh]|sil|dil|r\d+[wb])$', dst)
        return reads, d, full
    if mn == 'xor' and len(parts) == 2 and parts[0] == parts[1]:
        return set(), d, True
    if mn in ('cmp', 'test'):
        return reads | d, set(), False
    # two-operand ALU / cmov / shifts: read-modify-write
    return reads | d, d, False


def blocks(insns):
    targets = set()
    for a, t in insns:
        m = re.match(r'j\w+\s+(0x[0-9a-f]+)', t)
        if m:
            targets.add(int(m.group(1), 16))
    out, cur = [], []
    for a, t in insns:
        if a in targets and cur:
            out.append(cur)
            cur = []
        cur.append((a, t))
        mn = t.split()[0] if t.split() else ''
        if mn.startswith('j') or mn == 'ret':
            out.append(cur)
            cur = []
    if cur:
        out.append(cur)
    return out


def main(d):
    funcs, _ = load_jitmap(os.path.join(d, 'jitmap.txt'))
    counts = {}
    with open(os.path.join(d, 'instr.txt'), encoding='utf-8') as f:
        for line in f:
            if line.startswith('#'):
                continue
            p = line.split()
            counts[int(p[0], 16)] = float(p[1].replace(',', ''))
    per_fn = collections.defaultdict(lambda: collections.Counter())
    examples = collections.defaultdict(list)
    for fn in funcs:
        name = f"{fn['id']} {fn['name']}"
        insns = sorted(disassemble(fn['dhex'], fn['direct']).items())
        for blk in blocks(insns):
            for i, (a, t) in enumerate(blk):
                n = counts.get(a, 0.0)
                tt = re.sub(r'\s+', ' ', t).strip()
                per_fn[name]['instructions'] += n
                m = re.match(r'mov (\w+),(\w+)$', tt)
                if not m or m.group(1) not in ALIAS or m.group(2) not in ALIAS:
                    continue
                x, y = ALIAS[m.group(1)], ALIAS[m.group(2)]
                if x in ('rsp', 'rbp') or y in ('rsp', 'rbp'):
                    continue
                per_fn[name]['moves'] += n
                # purpose (first match), for the moves that are not dead/redundant too
                later = [re.sub(r'\s+', ' ', bt).strip() for _, bt in blk[i + 1:i + 8]]
                prev_t = re.sub(r'\s+', ' ', blk[i - 1][1]).strip() if i > 0 else ''
                call_follows = any(lt.startswith('call') for lt in later)
                if x == 'rdi' and call_follows:
                    purpose = 'purpose: vm pointer into rdi for a call'
                elif x in ('rsi', 'rdx', 'rcx', 'r8', 'r9') and call_follows:
                    purpose = 'purpose: call argument setup'
                elif y == 'rax' and prev_t.startswith('call'):
                    purpose = 'purpose: call result out of rax'
                elif x in ('rbx', 'r12', 'r13', 'r14', 'r15') and y in ('rdi', 'rsi', 'rdx', 'rcx', 'r8', 'r9'):
                    purpose = 'purpose: incoming argument into callee-saved register'
                elif x == 'rax' and not call_follows:
                    purpose = 'purpose: result into rax (return / op result)'
                elif later and later[-1:] and any(lt.startswith('jmp') for lt in later[:3]):
                    purpose = 'purpose: join/loop-carried copy before jmp'
                else:
                    purpose = 'purpose: other'
                per_fn[name][purpose] += n
                # redundant: X already equals Y from an earlier move in this block
                redundant = False
                for j in range(i - 1, -1, -1):
                    pa, pt = blk[j]
                    pm = re.match(r'mov (\w+),(\w+)$', re.sub(r'\s+', ' ', pt).strip())
                    if pm and pm.group(1) in ALIAS and pm.group(2) in ALIAS and \
                            {ALIAS[pm.group(1)], ALIAS[pm.group(2)]} == {x, y}:
                        redundant = True
                        break
                    r_, w_, _ = rw(pt)
                    if x in w_ or y in w_:
                        break
                if redundant:
                    per_fn[name]['redundant'] += n
                    if n:
                        examples[name].append(f'{a:#x} {tt}  (redundant, x{n:,.0f})')
                    continue
                dead = False
                for k in range(i + 1, len(blk)):
                    r_, w_, full = rw(blk[k][1])
                    if x in r_:
                        break
                    if x in w_ and full:
                        dead = True
                        break
                    if x in w_:
                        break
                if dead:
                    per_fn[name]['dead'] += n
                    if n:
                        examples[name].append(f'{a:#x} {tt}  (dead, x{n:,.0f})')
    tot = collections.Counter()
    lines = []
    for name in sorted(per_fn, key=lambda k: -per_fn[k]['instructions']):
        c = per_fn[name]
        tot.update(c)
        if c['instructions'] == 0:
            continue
        lines.append(f"{name:<32} executed={c['instructions']:>12,.0f}  reg-reg moves={c['moves']:>10,.0f}  "
                     f"dead={c['dead']:>9,.0f}  redundant={c['redundant']:>9,.0f}  "
                     f"(dead+redundant = {100 * (c['dead'] + c['redundant']) / c['instructions']:.1f}% of executed)")
        for e in examples[name][:12]:
            lines.append(f'      {e}')
    head = (f"TOTAL executed={tot['instructions']:,.0f}  reg-reg moves={tot['moves']:,.0f} "
            f"({100 * tot['moves'] / max(tot['instructions'], 1):.1f}%)  dead={tot['dead']:,.0f}  redundant={tot['redundant']:,.0f}  "
            f"dead+redundant={100 * (tot['dead'] + tot['redundant']) / max(tot['instructions'], 1):.1f}% of executed JIT "
            f"instructions ({100 * (tot['dead'] + tot['redundant']) / max(tot['moves'], 1):.1f}% of moves)")
    purposes = sorted(k for k in tot if k.startswith('purpose: '))
    plines = ['', 'register-to-register moves by purpose (heuristic, see moves.py), per run:']
    for k in sorted(purposes, key=lambda k: -tot[k]):
        plines.append(f"  {k[9:]:<52} {tot[k]:>12,.0f}  {100 * tot[k] / max(tot['moves'], 1):5.1f}% of moves  "
                      f"{100 * tot[k] / max(tot['instructions'], 1):5.1f}% of executed")
    with open(os.path.join(d, 'moves.txt'), 'w', encoding='utf-8') as f:
        f.write('# per run; generic entries excluded (cold trampolines)\n' + head + '\n' + '\n'.join(plines) + '\n\n' + '\n'.join(lines) + '\n')
    print(d, head)


if __name__ == '__main__':
    main(sys.argv[1])
