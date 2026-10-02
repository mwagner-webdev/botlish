#!/usr/bin/env python3
"""census.py -- String allocation census, old runtime versus new
(STRING-ALLOCATION.md): for each corpus program under two configurations
(default tiers, and -short-string-opt 0), the String objects built, the heap
allocation calls attributable to Strings (old: object + non-empty text buffer;
new: object only), text-buffer allocations and frees, String frees, bytes
allocated (header + UTF-8) and canonical-empty reuses.

    census.py OLD-CENSUS-BIN NEW-BIN NIR-DIR

OLD-CENSUS-BIN is the parent commit's driver with old-census.patch applied (it
counts the old runtime's text buffers exactly); NEW-BIN reports the same
`strings` section natively. Each program runs twice in one process (`bench 2`):
the second report includes the between-run cleanup collection, so frees are the
frees of a whole run. Observation only.
"""
import os, re, subprocess, sys


def parse_dict(text):
    # a flat Tcl dict of ints: "k v k v ..."
    words = text.split()
    return {words[i]: int(words[i + 1]) for i in range(0, len(words), 2)}


def census(binary, nir):
    out = subprocess.run([binary, "bench", "2", nir, "--alloc", "summary"], capture_output=True, text=True,
                         env=dict(os.environ, LANG="C.utf8")).stdout
    m = re.search(r"strings \{([^}]*)\}", out)
    strings = parse_dict(m.group(1))
    return strings


def main():
    old, new, nirdir = sys.argv[1:4]
    progs = sorted({f.split(".")[0] for f in os.listdir(nirdir)})
    cols = ["objects", "heapAllocations", "textBufferAllocations", "frees", "textBufferFrees", "bytes", "emptyReused"]
    for cfg in ("default", "off"):
        print(f"\n## {cfg}\n")
        print("| program | String objects old | String objects new | heap allocs old | heap allocs new | text-buffer allocs old | text-buffer allocs new | frees old | frees new | bytes old | bytes new | empty reuses |")
        print("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
        tot = {k: [0, 0] for k in cols}
        for p in progs:
            nir = os.path.join(nirdir, f"{p}.{cfg}.nir")
            o, n = census(old, nir), census(new, nir)
            if o["objects"] == 0 and n["objects"] == 0:
                continue
            for k in cols:
                tot[k][0] += o[k]
                tot[k][1] += n[k]
            print(f"| {p} | {o['objects']} | {n['objects']} | {o['heapAllocations']} | {n['heapAllocations']} | {o['textBufferAllocations']} | {n['textBufferAllocations']} | "
                  f"{o['frees']} | {n['frees']} | {o['bytes']} | {n['bytes']} | {n['emptyReused']} |")
        print(f"| **total** | {tot['objects'][0]} | {tot['objects'][1]} | {tot['heapAllocations'][0]} | {tot['heapAllocations'][1]} | {tot['textBufferAllocations'][0]} | {tot['textBufferAllocations'][1]} | "
              f"{tot['frees'][0]} | {tot['frees'][1]} | {tot['bytes'][0]} | {tot['bytes'][1]} | {tot['emptyReused'][1]} |")


if __name__ == "__main__":
    main()
