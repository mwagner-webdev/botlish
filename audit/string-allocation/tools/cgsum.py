#!/usr/bin/env python3
"""cgsum.py -- reduce a callgrind output file (written with --compress-strings=no
--compress-pos=no) to: total Ir, exclusive (self) Ir per function, and the number
of calls made to every function (the allocator entry points among them).

    cgsum.py CALLGRIND.OUT [--json]

Observation only (STRING-ALLOCATION.md). `calls=` lines are followed by one cost
line that is the *inclusive* cost of that call and must not be added to the
caller's self cost.
"""
import json, re, sys
from collections import defaultdict


def parse(path):
    selfc = defaultdict(int)
    calls = defaultdict(int)
    fn = None
    skip = False
    total = 0
    with open(path, errors="replace") as f:
        for line in f:
            if line.startswith("fn="):
                fn = re.sub(r"^\(\d+\)\s*", "", line[3:].strip())
                continue
            if line.startswith("calls="):
                m = re.match(r"calls=(\d+)", line)
                skip = True
                pending_calls[0] = int(m.group(1))
                continue
            if line.startswith("cfn="):
                cur_callee[0] = re.sub(r"^\(\d+\)\s*", "", line[4:].strip())
                continue
            if line[:1].isdigit() or line[:1] in "+-*" or line.startswith("0x"):
                parts = line.split()
                if skip:
                    skip = False
                    if cur_callee[0] is not None:
                        calls[cur_callee[0]] += pending_calls[0]
                    continue
                if fn is not None and len(parts) >= 2:
                    try:
                        c = int(parts[1])
                    except ValueError:
                        continue
                    selfc[fn] += c
                    total += c
    return total, selfc, calls


cur_callee = [None]
pending_calls = [0]

if __name__ == "__main__":
    total, selfc, calls = parse(sys.argv[1])
    if "--json" in sys.argv:
        print(json.dumps({"total": total, "self": selfc, "calls": calls}))
    else:
        print("total", total)
        for name, c in sorted(selfc.items(), key=lambda kv: -kv[1])[:25]:
            print(f"{c:>14} {name}")
        for n in ("malloc", "free", "calloc", "realloc"):
            print("calls", n, calls.get(n, 0))
