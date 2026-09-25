#!/usr/bin/env python3
"""asm-classes.py -- heuristic byte attribution of probe.tcl's asm.txt
(COMPREHENSIVE-GENERATED-CODE-AUDIT.md, code-size decomposition).

    python3 audit/comprehensive-generated-code/tools/asm-classes.py OUTDIR/asm.txt

Each instruction's size is the distance to the next instruction's address
(objdump -dr --no-show-raw-insn). Classes, first match wins:

  frame        push/pop rbp, mov rbp,rsp / rsp,rbp, sub/add rsp, ret
  callee-save  mov [rsp+N],{rbx,r12-r15} / mov {rbx,r12-r15},[rsp+N]
               (spills/reloads of callee-saved registers)
  root-store   other stores to [rsp+N] (shadow/root slots)
  call         call to another Botlish function (+ its argument/Vm moves
               are *not* attributed: they fall into "other")
  helper-call  call to an rt_* runtime helper
  guard/error  test rax,rax / jcc directly after a call (may_error check),
               the rt_type_error / rt_fail_declared / rt_declared_error
               call sites' surrounding cold blocks are counted as
               helper-call; kind-tag tests (test reg,0x1 / test reg,0x7 /
               movzx+cmp al,0x1 / sete) count here
  bool         cmovCC reg,[rip+..] and cmp reg,0x6 (tagged Bool
               materialization / re-test)
  padding      constant pool / alignment bytes after the last ret
  other        everything else (the actual computation, moves, branches)

This is deliberately approximate: it classifies by instruction shape, not
by provenance. Its purpose is order-of-magnitude attribution, never an
exact accounting.
"""
import re
import sys
from collections import Counter

LINE = re.compile(r'^\s+([0-9a-f]+):\s+(\S+)\s*(.*)$')
FUNC = re.compile(r'^[0-9a-f]+ <(botlish_\w+)>:(.*)$')
CALLEE_SAVED = r'(rbx|r12|r13|r14|r15)'


def classify(mnem, ops, prev):
    if mnem in ('push', 'pop') and 'rbp' in ops:
        return 'frame'
    if mnem == 'ret':
        return 'frame'
    if mnem == 'mov' and ops in ('rbp,rsp', 'rsp,rbp'):
        return 'frame'
    if mnem in ('sub', 'add') and ops.startswith('rsp,'):
        return 'frame'
    if mnem == 'mov' and re.match(r'QWORD PTR \[rsp(\+0x[0-9a-f]+)?\],' + CALLEE_SAVED + '$', ops):
        return 'callee-save'
    if mnem == 'mov' and re.match(CALLEE_SAVED + r',QWORD PTR \[rsp(\+0x[0-9a-f]+)?\]$', ops):
        return 'callee-save'
    if mnem == 'mov' and ops.startswith('QWORD PTR [rsp'):
        return 'root-store'
    if mnem == 'call':
        return 'call'
    if mnem.startswith('cmov') and '[rip' in ops:
        return 'bool'
    if mnem == 'cmp' and re.match(r'r\w+,0x6$', ops):
        return 'bool'
    if mnem == 'test' and re.match(r'r\w+,0x[17]$', ops):
        return 'guard/error'
    if mnem in ('sete', 'movzx') or (mnem == 'cmp' and ops.endswith('al,0x1')):
        return 'guard/error'
    if mnem == 'test' and ops == 'rax,rax' and prev == 'call':
        return 'guard/error'
    if (mnem == 'add' and ops.startswith('BYTE PTR [r')) or mnem.startswith('(bad)'):
        return 'padding'
    return 'other'


def main(path):
    text = open(path, encoding='utf-8').read().split('\n')
    insns = []  # (addr, mnem, ops, reloc, func)
    func = None
    for i, line in enumerate(text):
        m = FUNC.match(line)
        if m:
            func = m.group(1) + m.group(2)
            continue
        m = LINE.match(line)
        if not m or func is None:
            continue
        addr, mnem, ops = int(m.group(1), 16), m.group(2), m.group(3).strip()
        if mnem.startswith('R_X86_64'):
            if insns:
                insns[-1][3] = ops
            continue
        ops = ops.split('#')[0].strip()
        insns.append([addr, mnem, ops, '', func])
    total = Counter()
    prevclass = None
    prevmnem = None
    for j, (addr, mnem, ops, reloc, func) in enumerate(insns):
        nxt = insns[j + 1][0] if j + 1 < len(insns) else addr
        size = max(nxt - addr, 0)
        cls = classify(mnem, ops, prevmnem)
        if cls == 'call' and reloc.startswith('rt_'):
            cls = 'helper-call'
        if prevclass == 'guard/error' and mnem.startswith('j') and prevmnem == 'test':
            cls = 'guard/error'
        total[cls] += size
        prevclass, prevmnem = cls, mnem
    grand = sum(total.values())
    for cls, n in total.most_common():
        print(f'{cls:12s} {n:7d} B  {100.0 * n / grand:5.1f}%')
    print(f'{"total":12s} {grand:7d} B')


if __name__ == '__main__':
    main(sys.argv[1])
