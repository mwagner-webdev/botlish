#!/usr/bin/env python3
# callgrind-split.py -- where the program's own instructions of a frame go
# (ICY-TOWER-VERTICAL-SLICE-1.md, "Performance and allocation"): two
# callgrind profiles of runs FRAMES apart (callgrind-frame.py says how to
# make them), the program object's self cost split into the generated code
# (botlish_fn_*), the collector, big-integer arithmetic (num_bigint: the
# exact decimal arithmetic of DecimalRounded's rounding and decay), the rest
# of the runtime, and the allocator; and the calls a frame of the runtime
# helpers that box a Float64 or round or decay a DecimalRounded value.
#
#   python3 audit/icy-tower/tools/callgrind-split.py A.out 60 B.out 240
import re
import sys
from collections import defaultdict


def parse(path):
    names = {"ob": {}, "fn": {}, "fl": {}}
    cost = defaultdict(int)
    calls = defaultdict(int)
    ob = fn = cfn = None
    pending = False

    def name(kind, text):
        m = re.match(r"\((\d+)\)(?: (.*))?$", text)
        if not m:
            return text
        if m.group(2) is not None:
            names[kind][m.group(1)] = m.group(2)
            return m.group(2)
        return names[kind].get(m.group(1), "?")

    for line in open(path):
        line = line.rstrip("\n")
        if line.startswith("ob="):
            ob = name("ob", line[3:])
        elif line.startswith("fn="):
            fn = name("fn", line[3:])
        elif line.startswith("cob="):
            name("ob", line[4:])
        elif line.startswith("cfn="):
            cfn = name("fn", line[4:])
        elif line.startswith(("fl=", "fi=", "fe=")):
            name("fl", line[3:])
        elif line.startswith(("cfi=", "cfl=")):
            name("fl", line[4:])
        elif line.startswith("calls="):
            calls[cfn] += int(line[6:].split()[0])
            pending = True
        elif line and (line[0].isdigit() or line[0] in "+-*"):
            if pending:
                pending = False
                continue
            parts = line.split()
            if len(parts) >= 2:
                cost[(ob, fn)] += int(parts[1])
    return cost, calls


def bucket(fn):
    if fn.startswith("botlish_fn_"):
        return "generated code (botlish_fn_*)"
    if "num_bigint" in fn:
        return "big integers (num_bigint)"
    if "heap" in fn and ("collect" in fn or "mark" in fn or "sweep" in fn or "trace" in fn):
        return "collector"
    if "botlish_native" in fn or fn.startswith("rt_"):
        return "runtime helpers"
    if "alloc" in fn or "malloc" in fn or "free" in fn:
        return "allocator"
    return "other"


def main(a, na, b, nb):
    ca, ka = parse(a)
    cb, kb = parse(b)
    frames = float(int(nb) - int(na))
    split = defaultdict(float)
    for key in set(ca) | set(cb):
        ob, fn = key
        if ob is None or ".so" in ob.split("/")[-1]:
            continue
        split[bucket(fn or "")] += (cb.get(key, 0) - ca.get(key, 0)) / frames
    total = sum(split.values())
    print("the program's own instructions a frame: %.0f" % total)
    for k, v in sorted(split.items(), key=lambda kv: -kv[1]):
        print("  %6.1f%%  %9.0f  %s" % (100.0 * v / total, v, k))
    print("runtime helper calls a frame:")
    for fn in sorted(set(ka) | set(kb)):
        if fn and re.search(r"(new_float|rt_d64|decimal::(represent|round|to_float))", fn):
            n = (kb.get(fn, 0) - ka.get(fn, 0)) / frames
            if n >= 0.01:
                print("  %8.2f  %s" % (n, fn))


if __name__ == "__main__":
    main(*sys.argv[1:5])
