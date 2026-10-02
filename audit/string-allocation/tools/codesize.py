#!/usr/bin/env python3
"""codesize.py -- whole-program machine code bytes of the canonical corpus NIR,
old runtime/codegen versus new, plus the runtime binary's own section sizes
(STRING-ALLOCATION.md). Per-program code is compiled from byte-identical NIR;
only codegen changes (the inline StrToShort) can differ. Observation only.

    codesize.py OLD-BIN NEW-BIN NIR-DIR [PROGRAM...]
"""
import os, re, subprocess, sys


def size_of(binary, nir):
    out = subprocess.run([binary, "size", nir], capture_output=True, text=True, env=dict(os.environ, LANG="C.utf8")).stdout
    m = re.search(r"size (\d+) \{([^}]*)\}", out)
    return int(m.group(1)), [int(x) for x in m.group(2).split()]


def sections(binary):
    out = subprocess.run(["size", "-A", binary], capture_output=True, text=True).stdout
    d = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) == 3 and parts[0].startswith("."):
            d[parts[0]] = int(parts[1])
    return d


def main():
    old, new, nirdir = sys.argv[1:4]
    progs = sys.argv[4:] or sorted({f.split(".")[0] for f in os.listdir(nirdir)})
    tot = {"old": 0, "new": 0}
    funcs = {"old": 0, "new": 0}
    print(f"{'program':16} {'old bytes':>10} {'new bytes':>10} {'delta':>8} {'functions':>9}")
    for p in progs:
        nir = os.path.join(nirdir, f"{p}.default.nir")
        (a, fa), (b, fb) = size_of(old, nir), size_of(new, nir)
        tot["old"] += a
        tot["new"] += b
        funcs["old"] += len(fa)
        funcs["new"] += len(fb)
        print(f"{p:16} {a:10} {b:10} {b - a:+8} {len(fb):9}")
    print(f"{'TOTAL':16} {tot['old']:10} {tot['new']:10} {tot['new'] - tot['old']:+8} {funcs['new']:9}")
    so, sn = sections(old), sections(new)
    print()
    print("runtime/driver binary sections (size -A):")
    for k in (".text", ".rodata", ".data", ".bss", ".eh_frame", ".data.rel.ro"):
        print(f"  {k:14} old {so.get(k, 0):>10}  new {sn.get(k, 0):>10}  {sn.get(k, 0) - so.get(k, 0):+d}")
    print(f"  {'file bytes':14} old {os.path.getsize(old):>10}  new {os.path.getsize(new):>10}  {os.path.getsize(new) - os.path.getsize(old):+d}")


if __name__ == "__main__":
    main()
