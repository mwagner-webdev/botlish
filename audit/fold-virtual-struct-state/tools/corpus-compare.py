#!/usr/bin/env python3
"""corpus-compare.py BASE MINE -- compares two outputs of corpus.tcl
(FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md): BASE the tree before the
milestone (configuration `default`), MINE this tree with the configurations
default, off (-struct-fold 0 -struct-ref-joins 0), refoff
(-struct-ref-joins 0) and foldoff (-struct-fold 0).

Reports, per program: whether `off` reproduces the base NIR byte for byte
(it must), whether `default` changes the NIR, and if so which feature does
(fold slots: default differs from foldoff; reference joins: default differs
from refoff), with the census and Struct allocations before and after.
Ends with the totals and every program whose native run builds more structs
than before (there must be none: the no-loss property over the corpus).
Exits 1 if `off` differs from the base anywhere or a program builds more."""
import sys


def read(path):
    rows = {}
    for line in open(path, encoding="utf-8"):
        parts = line.split()
        if len(parts) < 3:
            continue
        name, config = parts[0], parts[1]
        fields = {}
        for p in parts[2:]:
            if "=" in p:
                k, v = p.split("=", 1)
                fields[k] = v
            else:
                fields.setdefault("error", "")
                fields["error"] += p + " "
        rows[(name, config)] = fields
    return rows


def main():
    base = read(sys.argv[1])
    mine = read(sys.argv[2])
    names = sorted({n for (n, c) in mine})
    bad = 0
    changed = []
    more = []
    totals = {"programs": 0, "same": 0, "fold": 0, "refjoin": 0, "both": 0, "?": 0}
    sb = sm = 0
    for n in names:
        b = base.get((n, "default"))
        d = mine.get((n, "default"))
        off = mine.get((n, "off"))
        refoff = mine.get((n, "refoff"))
        foldoff = mine.get((n, "foldoff"))
        if not b or not d or "nir" not in b or "nir" not in d:
            continue
        totals["programs"] += 1
        if off is None or off.get("nir") != b["nir"]:
            print(f"OFF DIFFERS FROM BASE: {n}")
            bad += 1
        if d["nir"] == b["nir"]:
            totals["same"] += 1
        else:
            fold = foldoff is not None and foldoff.get("nir") != d["nir"]
            ref = refoff is not None and refoff.get("nir") != d["nir"]
            kind = "both" if fold and ref else "fold" if fold else "refjoin" if ref else "?"
            # "?": neither feature alone changes it (a difference of the
            # two trees unrelated to the milestone): reported, and fails.
            totals[kind] += 1
            if kind == "?":
                print(f"CHANGED BY NEITHER FEATURE: {n}")
                bad += 1
            changed.append((n, kind, b, d))
        try:
            x, y = int(b.get("structs", "-")), int(d.get("structs", "-"))
            sb += x
            sm += y
            if y > x:
                more.append((n, x, y))
        except ValueError:
            pass
    for n, kind, b, d in changed:
        print(f"{n}: {kind}; structs {b.get('structs')} -> {d.get('structs')}; slots {d.get('slots')}")
        print(f"    census {b.get('census')}")
        print(f"        -> {d.get('census')}")
    print(f"\n{totals['programs']} programs: NIR unchanged {totals['same']}, changed by fold slots {totals['fold']}, "
          f"by reference joins {totals['refjoin']}, by both {totals['both']}, by neither {totals['?']}")
    print(f"Struct allocations over the programs that ran on both: {sb} -> {sm}")
    for n, x, y in more:
        print(f"MORE STRUCTS: {n}: {x} -> {y}")
        bad += 1
    sys.exit(1 if bad else 0)


main()
