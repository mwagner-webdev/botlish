#!/usr/bin/env python3
"""report.py -- renders the measurement JSON (ir.py, materialize.py,
constructors.py) as the Markdown tables of STRING-ALLOCATION.md.

    report.py IR.json MATERIALIZE.json CONSTRUCTORS.json > tables.md
"""
import json, sys

STRING_PROGRAMS = ["refined-checks", "source-checks", "uri-steady", "ai_text_clean", "string_replace", "hashtable",
                   "csv", "csv_chunked", "csv_geometric", "csv_records", "string_reverse", "lex-strategy", "test-selection"]
CONTROLS = ["fib", "loop-count", "sum-refined", "matmul"]


def pct(a, b):
    return f"{100.0 * (b - a) / a:+.2f}%" if a else "n/a"


def f0(x):
    return f"{x:,.0f}"


def corpus_table(ir, cfg, programs, title):
    print(f"\n### {title}\n")
    print("| program | run Ir old | run Ir new | Δ | free-side (reset) Ir old | new | Δ | run+reset old | run+reset new | Δ |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for p in programs:
        if p not in ir:
            continue
        c = ir[p][cfg]
        o, n = c["old"], c["new"]
        ot, nt = o["run"]["ir"] + o["reset"]["ir"], n["run"]["ir"] + n["reset"]["ir"]
        print(f"| {p} | {f0(o['run']['ir'])} | {f0(n['run']['ir'])} | {pct(o['run']['ir'], n['run']['ir'])} | "
              f"{f0(o['reset']['ir'])} | {f0(n['reset']['ir'])} | {pct(o['reset']['ir'], n['reset']['ir'])} | {f0(ot)} | {f0(nt)} | {pct(ot, nt)} |")


def malloc_table(ir, cfg, programs):
    print("\n### malloc / free calls inside the timed window (default configuration)\n")
    print("| program | malloc calls old | malloc calls new | free calls (reset) old | free calls (reset) new |")
    print("|---|---:|---:|---:|---:|")
    for p in programs:
        if p not in ir:
            continue
        c = ir[p][cfg]
        o, n = c["old"], c["new"]
        print(f"| {p} | {f0(o['run']['malloc'])} | {f0(n['run']['malloc'])} | {f0(o['reset']['free'])} | {f0(n['reset']['free'])} |")


def diagnostic(ir, programs):
    print("\n### short-String regime cost under each runtime (B = default tiers + demand rule, A = short strings off, C = tiers without the demand rule)\n")
    print("| program | A off old | B old | B−A old | A off new | B new | B−A new | C demand-off old | C new | C−A old | C−A new |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for p in programs:
        if p not in ir:
            continue
        g = lambda cfg, rt: ir[p][cfg][rt]["run"]["ir"] + ir[p][cfg][rt]["reset"]["ir"]
        a_o, b_o, c_o = g("off", "old"), g("default", "old"), g("demand0", "old")
        a_n, b_n, c_n = g("off", "new"), g("default", "new"), g("demand0", "new")
        print(f"| {p} | {f0(a_o)} | {f0(b_o)} | {pct(a_o, b_o)} | {f0(a_n)} | {f0(b_n)} | {pct(a_n, b_n)} | {f0(c_o)} | {f0(c_n)} | {pct(a_o, c_o)} | {pct(a_n, c_n)} |")


def micro(mat):
    print("\n### Materialization (instructions per materialization; control loop subtracted)\n")
    print("| value | alloc side old | new | free side old | new | churn life cycle old | new | Δ life cycle |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|")
    for label, r in mat.items():
        o, n = r["old"], r["new"]
        print(f"| {label} | {o['alloc']['ir']:.1f} | {n['alloc']['ir']:.1f} | {o['free']['ir']:.1f} | {n['free']['ir']:.1f} | "
              f"{o['lifecycle']['ir']:.1f} | {n['lifecycle']['ir']:.1f} | {pct(o['lifecycle']['ir'], n['lifecycle']['ir'])} |")
    print("\n### Exclusive-Ir breakdown of one `shorttostr` U+0061 (instructions)\n")
    r = mat["scalar U+0061"]
    cats = ["allocator (glibc)", "free (glibc)", "Rust allocator shims", "memcpy/memmove", "runtime constructors", "GC bookkeeping + free_object", "generated code (loop + strlen)", "other"]
    for mode, name in (("alloc", "allocation side (steady state)"), ("free", "free side (between-run reset)"), ("lifecycle", "churn life cycle")):
        print(f"\n{name}:\n")
        print("| part | old | new |")
        print("|---|---:|---:|")
        for c in cats:
            o, n = r["old"][mode]["categories"].get(c, 0), r["new"][mode]["categories"].get(c, 0)
            if abs(o) < 0.05 and abs(n) < 0.05:
                continue
            print(f"| {c} | {o:.1f} | {n:.1f} |")
        print(f"| **total** | {r['old'][mode]['ir']:.1f} | {r['new'][mode]['ir']:.1f} |")
    print("\nmalloc / free calls per materialization (U+0061): "
          f"old {r['old']['lifecycle']['malloc_calls']:.2f} / {r['old']['lifecycle']['free_calls']:.2f}, "
          f"new {r['new']['lifecycle']['malloc_calls']:.2f} / {r['new']['lifecycle']['free_calls']:.2f}")


def ctors(cj):
    print("\n### Per-constructor cost (instructions per construction; control subtracted)\n")
    print("| constructor | alloc side old | new | free side old | new | life cycle old | new | Δ | malloc calls old | new |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for label, r in cj.items():
        o, n = r["old"], r["new"]
        print(f"| {label} | {o['alloc']['ir']:.1f} | {n['alloc']['ir']:.1f} | {o['free']['ir']:.1f} | {n['free']['ir']:.1f} | {o['lifecycle']['ir']:.1f} | {n['lifecycle']['ir']:.1f} | "
              f"{pct(o['lifecycle']['ir'], n['lifecycle']['ir'])} | {o['alloc']['malloc_calls']:.2f} | {n['alloc']['malloc_calls']:.2f} |")


def main():
    ir = json.load(open(sys.argv[1]))
    mat = json.load(open(sys.argv[2])) if len(sys.argv) > 2 else None
    cj = json.load(open(sys.argv[3])) if len(sys.argv) > 3 else None
    allp = sorted(ir)
    corpus_table(ir, "default", STRING_PROGRAMS, "Default configuration (tiered short Strings + demand rule), String programs")
    corpus_table(ir, "default", CONTROLS, "Default configuration, non-String controls")
    corpus_table(ir, "off", STRING_PROGRAMS, "`-short-string-opt 0` (no short Strings: ordinary Strings only)")
    corpus_table(ir, "ascii0", STRING_PROGRAMS, "`-ascii-pack-opt 0` (ShortString1 only)")
    malloc_table(ir, "default", STRING_PROGRAMS)
    diagnostic(ir, STRING_PROGRAMS)
    if mat:
        micro(mat)
    if cj:
        ctors(cj)


if __name__ == "__main__":
    main()
