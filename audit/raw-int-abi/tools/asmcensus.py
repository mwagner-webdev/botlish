#!/usr/bin/env python3
"""asmcensus.py -- machine-code census of the Botlish functions in an objdump
listing written by tools/asm.tcl (RAW-INT-ABI.md). Observation only.

    python3 audit/raw-int-abi/tools/asmcensus.py OUTPREFIX

reads OUTPREFIX.asm (objdump -dr --no-show-raw-insn -M intel) and
OUTPREFIX.roots (native::roots) and prints, per direct function and per
generic entry wrapper: bytes, instructions, stack stores (any store to
[rsp+..]/[rbp-..]), tag/untag shifts (shl/sar/shr by 1 and `or reg,1`),
calls, plus the roots report's safepoints, root candidates and shadow slots.
"""
import re
import sys

prefix = sys.argv[1]
asm = open(prefix + ".asm").read().splitlines()
roots = open(prefix + ".roots").read()

rootinfo = {}
for block in roots.split("\n\n"):
    m = re.match(r'function (\d+) "([^"]*)"', block)
    if not m:
        continue
    d = {}
    for key in ("safepoints", "root candidates", "shadow slots"):
        k = re.search(re.escape(key) + r": (\d+)", block)
        d[key] = int(k.group(1)) if k else 0
    rootinfo[int(m.group(1))] = d

funcs = []  # (label, addr, [(addr, text)])
cur = None
for line in asm:
    m = re.match(r'^([0-9a-f]+) <(botlish_(fn|entry)_(\d+)): (.*)>:$', line)
    if m:
        cur = {"addr": int(m.group(1), 16), "kind": m.group(3), "id": int(m.group(4)), "label": m.group(5), "insns": []}
        funcs.append(cur)
        continue
    m = re.match(r'^\s+([0-9a-f]+):\s+(\S.*)$', line)
    if m and cur is not None and "R_X86_64" not in line:
        cur["insns"].append((int(m.group(1), 16), m.group(2).strip()))

# function end = next function's start (the object's last one ends at its last instruction + 1)
for i, f in enumerate(funcs):
    end = funcs[i + 1]["addr"] if i + 1 < len(funcs) else f["insns"][-1][0] + 1
    f["bytes"] = end - f["addr"]

print("%-34s %-6s %5s %5s %6s %7s %5s %5s %6s %6s" % (
    "function", "kind", "bytes", "insns", "stores", "tagshft", "calls", "safepts", "rootcand", "slots"))
tot = dict(bytes=0, insns=0, stores=0, shifts=0, calls=0)
for f in funcs:
    texts = [t for _, t in f["insns"]]
    stores = sum(1 for t in texts if re.match(r'mov\s+(QWORD|DWORD) PTR \[(rsp|rbp)', t))
    shifts = sum(1 for t in texts if re.match(r'(shl|sar|shr)\s+\w+,(1|0x1)$', t)) \
        + sum(1 for t in texts if re.match(r'or\s+\w+,0x1$', t))
    calls = sum(1 for t in texts if t.startswith("call"))
    info = rootinfo.get(f["id"], {}) if f["kind"] == "fn" else {}
    print("%-34s %-6s %5d %5d %6d %7d %5d %5s %6s %6s" % (
        f["label"][:34], f["kind"], f["bytes"], len(texts), stores, shifts, calls,
        info.get("safepoints", "-"), info.get("root candidates", "-"), info.get("shadow slots", "-")))
    if f["kind"] == "fn":
        tot["bytes"] += f["bytes"]; tot["insns"] += len(texts); tot["stores"] += stores
        tot["shifts"] += shifts; tot["calls"] += calls
print("direct functions total: bytes %(bytes)d insns %(insns)d stack-stores %(stores)d tag-shifts %(shifts)d calls %(calls)d" % tot)
