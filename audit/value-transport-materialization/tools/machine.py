#!/usr/bin/env python3
"""machine.py ASMFILE... -- summarizes the machine-code sections written by
asm-fn.tcl: per function, instructions, stack-slot operands, stores to and loads
from stack slots, calls, and calls of the runtime's struct allocator
(rt_struct_new). A mechanical register-pressure indicator, not a model."""
import re, sys
for path in sys.argv[1:]:
    text = open(path).read()
    for m in re.finditer(r'=== machine code \(function (\d+)\)\n(.*?)(?=\n=== |\Z)', text, re.S):
        fid, body = m.group(1), m.group(2)
        insns = stack = stores = loads = calls = alloc = 0
        for line in body.split('\n'):
            if re.match(r'\s+[0-9a-f]+:\s', line) and 'R_X86_64' not in line:
                insns += 1
                if re.search(r'\[r[sb]p[+-]', line):
                    stack += 1
                    if re.search(r'mov\s+(QWORD|DWORD) PTR \[r[sb]p[+-][^\]]*\],', line):
                        stores += 1
                    else:
                        loads += 1
                if re.search(r'\bcall\b', line):
                    calls += 1
            if 'rt_struct_new' in line:
                alloc += 1
        # only the fn_ body, entry wrappers counted separately in the dump
        print('%-52s fn %-3s insns %4d stack-ops %3d (stores %3d loads %3d) calls %2d rt_struct_new %d' % (path.split('/')[-1], fid, insns, stack, stores, loads, calls, alloc))
