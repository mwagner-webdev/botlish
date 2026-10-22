#!/usr/bin/env python3
"""renames.py -- the old-to-new name table of the std:: migration
(STD-NAMESPACE.md), from the two censuses.

    python3 audit/stdlib-census/tools/renames.py > audit/stdlib-census/renames.tsv

Joins audit/stdlib-census/before.tsv and after.tsv: every program-visible
entity of the standard library (role api, demo or std-internal) with its flat name before
the migration and its canonical std:: name after it. Root primitives,
internal natives and runtime builtins kept their names and are not listed.
Exits 1 if an entity of either census has no partner in the other.
"""

import os
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def rows(name):
    with open(os.path.join(HERE, name), encoding="utf-8") as f:
        lines = f.read().strip().split("\n")
    out = {}
    for line in lines[1:]:
        fields = line.split("\t")
        out[(fields[0], fields[1])] = fields
    return out


def main():
    before = rows("before.tsv")
    after = rows("after.tsv")
    print("old_name\tnew_name\tkind\tnamespace\torigin")
    seen = set()
    lost = []
    for (name, kind), fields in sorted(before.items()):
        if fields[3] not in ("api", "demo", "std-internal"):
            if (name, kind) not in after:
                lost.append(name)
            seen.add((name, kind))
            continue
        new = "std::" + name
        if (new, kind) not in after:
            lost.append(name)
            continue
        seen.add((new, kind))
        print("\t".join([name, new, kind, after[(new, kind)][2], fields[4]]))
    unmatched = [key[0] for key in after if key not in seen]
    if lost or unmatched:
        print("unmatched: %s / %s" % (lost, unmatched), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
