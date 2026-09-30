# Structs -- audit data

Evidence for `STRUCTS.md`. "before" = the parent fence `84f4d68`
(`git archive` into a scratch directory, `native/target` symlinked to the built
backend), "after" = this milestone's source fence. Every tool is
observation-only and runs against the tree it is started in (`pwd` is the
root), so one script measured both trees. Tcl 9.0.1, `LANG=C.utf8
LC_ALL=C.utf8`, native backend built (release).

| tool | output | what |
|---|---|---|
| `tools/positional.tcl OUT` | `out/positional-{before,after}.txt` | HIR-level census of positional Lists: every list literal of 2+ elements with its element types, every `list_get` with a literal index (and whether its receiver lost its element types), every struct literal/projection |
| `tools/instances.tcl OUT` | `out/instances-{before,after}.txt` | semantic instances per program, those involving a struct type, the distinct codegen keys they fall on, codegen instances, emitted functions |
| `tools/niropcensus.py BEFORE AFTER` | `out/niropcensus.txt` | NIR op census (`structnew`, `structget`, `listnew`, `listget`, guards, calls, multi-value calls/returns, functions, lines) over `out/nir-{before,after}/` |
| `tools/codebytes.tcl OUT` | `out/codebytes-{before,after}.txt` | machine-code bytes per canonical program |
| `tools/strict-diff.py BEFORE AFTER` | `out/strict-diff.txt` | site-by-site comparison of the two strict-counterfactual tables |
| existing tools, reused | `out/strict-table-*`, `out/strict-*`, `out/calltypes-*`, `out/typedsites-*`, `out/aot-*`, `out/codegen-count-*`, `out/workloads-*`, `out/compiletime-*`, `out/bench-runs1-*`, `out/corpus-runs1-*`, `out/nir-*` | `intrinsic-function-contracts/tools/validity.tcl` with `variant-all-trusted.patch` and `typed-mutarray-builder-refactor/tools/strict-table.py`; `typed-mutarray-builder-refactor/tools/{calltypes,typedsites,codegen-count,workloads}.tcl` and `workloads-compare.py`; `mutarray-construction/tools/aot.tcl`; `direct-hir-native-path/tools/compiletime.tcl -mode direct`; `opportunistic-semantic-instances/tools/nir-all.tcl`; `bench/bench.tcl -runs 1`, `bench/corpus.tcl -runs 1` |

Reproduce (tree root):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/structs/tools/positional.tcl OUT
tclsh9.0 audit/structs/tools/instances.tcl OUT
tclsh9.0 audit/structs/tools/codebytes.tcl OUT
tclsh9.0 audit/typed-mutarray-builder-refactor/tools/codegen-count.tcl
tclsh9.0 audit/typed-mutarray-builder-refactor/tools/calltypes.tcl OUT
tclsh9.0 audit/mutarray-construction/tools/aot.tcl OUT
tclsh9.0 audit/opportunistic-semantic-instances/tools/nir-all.tcl OUTDIR
python3 audit/structs/tools/niropcensus.py BEFOREDIR AFTERDIR
tclsh9.0 audit/typed-mutarray-builder-refactor/tools/workloads.tcl OUT 15
tclsh9.0 audit/direct-hir-native-path/tools/compiletime.tcl -root TREE -mode direct -runs 7
# strict counterfactual, in a scratch copy of each tree:
patch -p1 < audit/intrinsic-function-contracts/out/variant-all-trusted.patch
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl > STRICT
python3 audit/typed-mutarray-builder-refactor/tools/strict-table.py . STRICT > TABLE
python3 audit/structs/tools/strict-diff.py BEFORE-TABLE AFTER-TABLE
tclsh9.0 bench/bench.tcl -runs 1
tclsh9.0 bench/corpus.tcl -runs 1
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
```

Timing measurements (`workloads`, `compiletime`) were taken with the two trees
interleaved round by round on a noisy machine; same-tree runs vary by 5-15%.
