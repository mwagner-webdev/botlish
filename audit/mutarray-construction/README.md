# MutableArray construction and refinement -- audit data

Evidence for `MUTABLEARRAY-CONSTRUCTION-REFINEMENT.md`. Every tool is
observation-only and runs against whatever tree it is started in (`pwd` is the
root), so the same script measured the parent commit (`c4437ec`, "before") and
this milestone's tree ("after"). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, native
backend built (rustc 1.98.1).

| tool | output | what |
|---|---|---|
| `tools/census.tcl OUTFILE` | `out/census-{before,after}.txt` (real regime), `out/census-{before,after}-variant.txt` (with `variant-all-trusted.patch`) | every MutableArray constructor call site and its static result type; every function returning `mutarray`; every `List[mutarray]` expression; every `list_get` with its list/result types; every argument position that requires a MutableArray with the argument's static type ("proven" vs "checked boundary") |
| `tools/trace.tcl` | `out/trace-{before,after}.txt`, `out/trace-{before,after}-variant.txt` | result types and parameter contracts along the constructor -> container -> projection -> consumer chain of `csv_records.bot` / `hashtable.bot`, and the `sample()` bindings the counterfactual fails on |
| `tools/controls.tcl` | `out/controls-variant.txt` | positive/negative controls appended to a scratch copy of `csv_records.bot` (literal rows, appended rows, builder rows, `from_list` rows, record pair across a function boundary) under `variant-all-trusted` |
| `tools/aot.tcl OUTFILE` | `out/aot-{before,after}.txt` | `hir::aot` status/blockers of every used instance of the 17 canonical programs |
| `tools/probe-typing.tcl` | `out/probe-typing.txt` | static types and per-backend outcomes of the `from_list` / `mutarray?` probe programs |
| `out/strict-counterfactual-{before,after}.txt` | | `audit/intrinsic-function-contracts/tools/validity.tcl` in a scratch copy with `variant-all-trusted.patch` applied: 10 of 31 programs / 35 sites; byte-identical before and after |
| `out/strict-counterfactual-table.md` | | every one of the 35 sites (before/after, category), and the 9 + 4 MutableArray sites in detail |
| `out/predicate-asm.txt`, `out/guard-elision.txt` | | NIR + machine code of `mutarray?` next to `list?`; NIR of a consumer with and without a static `mutarray` proof |
| `out/compiletime-{before,after}.txt` | | `audit/intrinsic-function-contracts/tools/compiletime.tcl 7` (median of 7) |
| `out/bench-runs1.txt` | | `tclsh9.0 bench/bench.tcl -runs 1` |

Reproduce (tree root; "before" = `git archive c4437ec` into a scratch dir):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/mutarray-construction/tools/census.tcl audit/mutarray-construction/out/census-after.txt
tclsh9.0 audit/mutarray-construction/tools/trace.tcl
tclsh9.0 audit/mutarray-construction/tools/aot.tcl audit/mutarray-construction/out/aot-after.txt
tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl 7
# strict counterfactual (and trace/controls/census "-variant"): in a scratch copy of the tree
patch -p1 < audit/intrinsic-function-contracts/out/variant-all-trusted.patch
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl
tclsh9.0 audit/mutarray-construction/tools/controls.tcl
# generated code
tclsh9.0 native/generate-scalar-audit.tcl -outdir OUTDIR      # diff against audit/native-scalar-asm
tclsh9.0 audit/intrinsic-function-contracts/tools/nir.tcl OUTDIR
```
