# Exact constants and value-fact propagation -- audit data

Evidence for `EXACT-VALUE-FACTS.md`. Every tool is observation-only and runs
against whatever tree it is started in (`pwd` is the root), so the same
script measured the parent commit (`0d42355`, "before") and this milestone's
tree ("after"). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, native backend built
(rustc 1.98.1).

| tool | output | what |
|---|---|---|
| `tools/probe.tcl [-strict N] 'SOURCE'` | stdout | every expression's semantic type and exact fact, and per used instance its view type and Range |
| `tools/probe2.tcl FILE` | stdout | semantic result type of every function and every instance's result |
| `tools/census.tcl OUTFILE` | `out/census-{before,after}.txt` | every `list_get`/`list_length` call site of `bench/*.bot`, `examples/stdlib/*.bot`, `examples/surface/*.bot` and the loaded `lib/*.bot` (each source location once): semantic type, instance view types and Range facts, and (after only) the exact index / exact List answers; plus counts of exact constants and known exact Lists |
| `out/strict-counterfactual-{before,after}.txt` | | `audit/intrinsic-function-contracts/tools/validity.tcl` in a scratch copy with `audit/intrinsic-function-contracts/out/variant-all-trusted.patch` applied (every inferred requirement treated like a declaration): the strict-contract counterfactual, 10 of 31 programs / 35 sites, before and after this milestone, paths normalized |
| `out/strict-counterfactual-table.md` | | every counterfactual site with the workaround it would need, its category and the verdict after this milestone |
| `out/compiletime-{before,after}.txt` | | `audit/intrinsic-function-contracts/tools/compiletime.tcl 7` (median of 7 front-end compiles) before/after |

Reproduce (tree root):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/exact-value-facts/tools/census.tcl audit/exact-value-facts/out/census-after.txt
tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl 7
# strict counterfactual: in a scratch copy of the tree
patch -p1 < audit/intrinsic-function-contracts/out/variant-all-trusted.patch
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl
# generated code
tclsh9.0 audit/intrinsic-function-contracts/tools/nir.tcl OUTDIR      # NIR + instance labels of the 8 benchmarks
tclsh9.0 native/generate-scalar-audit.tcl -outdir OUTDIR              # diff against audit/native-scalar-asm
```
