# Comprehensive generated-code audit: evidence

Supporting material for `/COMPREHENSIVE-GENERATED-CODE-AUDIT.md` (the final
semantic source fence audit). Nothing here is a build product or a
benchmark source. All of it is diagnostic and can be regenerated.

| path | what |
|---|---|
| `tools/probe.tcl PROGRAM OUTDIR ?LOWER-OPTIONS?` | per-workload dump: static completion facts, instances, per-instance parameter view types and ranges, per-call facts, NIR, asm, roots, call effects, summary |
| `tools/census.tcl OUTDIR...` | guard / box / helper / call / `may_error` census over probe outputs |
| `tools/asm-classes.py ASM` | heuristic byte attribution of a probe's `asm.txt` by instruction class |
| `tools/measure.tcl PROGRAM RUNS SESSIONS ?LOWER-OPTIONS?` | best-of-RUNS native timing (`native::measure`), repeated |
| `tools/bench-baseline.sh OUTDIR ?SESSIONS?` | repository benchmark commands, repeated for variance |
| `tools/bench-summary.py DIR` | median/min/max of `bench-baseline.sh` sessions |
| `probes/*.bot` | call-shape harnesses around the frozen library (each names its origin) |
| `bugs/*.bot` | reproductions of the two correctness findings (C1 fixed, C2 not) |
| `artifacts/` | curated outputs cited by the report (see its §30) |

Run everything with `LANG=C.utf8 LC_ALL=C.utf8`, `tclsh9.0`, and a release
build of `native/`.
