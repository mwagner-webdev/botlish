#!/usr/bin/env python3
# profile-diff.py -- compare two census.txt files written by
# audit/post-r2a-dynamic-census/tools/profile-nir.sh (knob 0 vs knob 1 NIR of
# one program; GENERIC-PREDICATE-PROOF-LOSS.md, fix 3): total Ir/run, the
# run's value line, and every Botlish function whose invocation count or self
# Ir/run differs (inclusive figures of its callers merely propagate it).
#
#   python3 profile-diff.py LABEL DIR0 DIR1
import re
import sys

label, dir0, dir1 = sys.argv[1:4]


def load(d):
    text = open(f"{d}/census.txt", encoding="utf-8").read()
    total = int(re.search(r"total Ir/run: ([\d,]+)", text).group(1).replace(",", ""))
    rows = {}
    section = False
    for line in text.splitlines():
        if line.startswith("== Botlish functions"):
            section = True
            continue
        if section and line.startswith("=="):
            break
        m = re.match(r"\s+(\d+ \S+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s+([\d,]+)\s", line)
        if section and m:
            n = [int(x.replace(",", "")) for x in m.groups()[1:]]
            rows[m.group(1)] = {"invoc": n[0], "self": n[2] + n[3], "incl": n[4]}
    value = ""
    for line in open(f"{d}/run-output.txt", encoding="utf-8"):
        if line.startswith("value "):
            value = line.strip()
    return total, rows, value


t0, r0, v0 = load(dir0)
t1, r1, v1 = load(dir1)
print(f"{label}: total Ir/run {t0:,} -> {t1:,} ({t1 - t0:+,}, {100.0 * (t1 - t0) / t0:+.2f}%)")
print(f"  value knob0: {v0}")
print(f"  value knob1: {v1}  [{'same' if v0 == v1 else 'DIFFERENT'}]")
for key in sorted(set(r0) | set(r1), key=lambda k: int(k.split()[0])):
    a = r0.get(key)
    b = r1.get(key)
    if a is None or b is None:
        print(f"  {key}: present on one side only")
        continue
    if a["self"] == b["self"] and a["invoc"] == b["invoc"]:
        continue
    per0 = a["self"] / a["invoc"] if a["invoc"] else 0
    per1 = b["self"] / b["invoc"] if b["invoc"] else 0
    print(f"  {key}: invocations {a['invoc']:,} -> {b['invoc']:,}; self Ir/run {a['self']:,} -> {b['self']:,}"
          f" ({per0:.1f} -> {per1:.1f} Ir/call); inclusive {a['incl']:,} -> {b['incl']:,}")
