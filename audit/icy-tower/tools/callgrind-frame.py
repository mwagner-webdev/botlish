#!/usr/bin/env python3
# callgrind-frame.py -- what one frame of the Icy Tower executable costs
# (ICY-TOWER-VERTICAL-SLICE-1.md, "Performance and allocation"), from two
# callgrind profiles of the same dummy-driver run with different frame
# counts: the difference divided by the frames between them is the steady
# state of a frame, startup and shutdown cancelled out.
#
#   valgrind --tool=callgrind --callgrind-out-file=A.out EXE --autopilot --fixed-step --frames 60
#   valgrind --tool=callgrind --callgrind-out-file=B.out EXE --autopilot --fixed-step --frames 240
#   python3 audit/icy-tower/tools/callgrind-frame.py A.out 60 B.out 240
#
# EXE is an unstripped build (build.sh strips; stage and emit it without
# strip). Prints the instructions of a frame by object (the program's own
# code and runtime, libSDL3, libc, ...), the calls of a frame into SDL's
# exported functions (each one C call the program makes, through the
# generated binding), and the calls of a frame to malloc and free (the
# managed heap's objects are allocated with them, and so are SDL's own).
import re
import sys
from collections import defaultdict


def parse(path):
    names = {"ob": {}, "fl": {}, "fn": {}}
    self_cost = defaultdict(int)  # (ob, fn) -> Ir
    calls = defaultdict(int)      # (caller object, called fn) -> count
    ob = fn = cob = cfn = None
    pending_call = False

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
            cob = None
        elif line.startswith("cob="):
            cob = name("ob", line[4:])
        elif line.startswith("cfn="):
            cfn = name("fn", line[4:])
        elif line.startswith(("fl=", "fi=", "fe=")):
            name("fl", line[3:])
        elif line.startswith(("cfi=", "cfl=")):
            name("fl", line[4:])
        elif line.startswith("calls="):
            calls[(ob, cfn)] += int(line[6:].split()[0])
            pending_call = True
        elif line and (line[0].isdigit() or line[0] in "+-*"):
            parts = line.split()
            if pending_call:
                pending_call = False  # the call's inclusive cost: not self
                continue
            if len(parts) >= 2:
                self_cost[(ob, fn)] += int(parts[1])
    return self_cost, calls


def main(a, na, b, nb):
    sa, ca = parse(a)
    sb, cb = parse(b)
    frames = float(int(nb) - int(na))
    by_object = defaultdict(float)
    for key in set(sa) | set(sb):
        by_object[key[0]] += (sb.get(key, 0) - sa.get(key, 0)) / frames
    total = sum(by_object.values())
    print("instructions a frame: %.0f" % total)
    for ob, cost in sorted(by_object.items(), key=lambda kv: -kv[1]):
        if cost / total < 0.005:
            continue
        print("  %6.1f%%  %9.0f  %s" % (100.0 * cost / total, cost, ob.split("/")[-1]))
    # The program's own object: the one that is no shared library.
    program = [o for o in by_object if o and ".so" not in o.split("/")[-1]]
    print("C calls a frame from the program into SDL's exported functions:")
    sdl = {}
    for key in set(ca) | set(cb):
        caller, fn = key
        if caller in program and fn and re.match(r"^SDL_[A-Za-z0-9]+$", fn):
            n = (cb.get(key, 0) - ca.get(key, 0)) / frames
            if n > 0:
                sdl[fn] = n
    for fn, n in sorted(sdl.items(), key=lambda kv: -kv[1]):
        print("  %7.2f  %s" % (n, fn))
    print("  %7.2f  in all" % sum(sdl.values()))
    print("malloc and free a frame, by caller (the program's are its managed heap's objects):")
    for fn in ["malloc", "free", "realloc"]:
        rows = defaultdict(float)
        for key in set(ca) | set(cb):
            if key[1] == fn:
                rows[key[0].split("/")[-1] if key[0] else "?"] += (cb.get(key, 0) - ca.get(key, 0)) / frames
        print("  %-8s %s" % (fn, ", ".join("%s %.1f" % (o, n) for o, n in sorted(rows.items(), key=lambda kv: -kv[1]) if n >= 0.05)))


if __name__ == "__main__":
    main(*sys.argv[1:5])
