# Typed MutableArray builder refactor -- audit data

Evidence for `TYPED-MUTARRAY-BUILDER-REFACTOR.md`. "before" = the parent
fence `0969a30` (tree `b61eb41d6d645c16462e4765b71ec7346c7143c3`), "after" =
the source fence `88e0166` (tree `6df552ca8071447c7203bfa20f43dc272198dde7`).
Every tool is observation-only and runs against the tree it is started in
(`pwd` is the root), so the same script measured both trees ("before" from a
`git archive` of `0969a30` with `native/target` symlinked to the built
backend). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, native backend built
(rustc 1.98.1).

| tool | output | what |
|---|---|---|
| `tools/workloads.tcl OUT [RUNS]` | `out/workloads-{before,after}-run{1,2,3}.txt`, `out/workloads-compare.txt` (via `tools/workloads-compare.py`) | csv_geometric / csv_records: best-of-15 native time, allocation summary by kind, code size, NIR op census, builder function param counts |
| `tools/typedsites.tcl OUT` | `out/typedsites-*.txt` | semantic type of every MutableArray/List primitive call and block call in the two programs |
| `tools/calltypes.tcl OUT [-off]`, `tools/calltypes-diff.py` | `out/calltypes-*`, `out/calltypes-diff-*` | exact-block call precision census, semantic instances on vs off |
| `tools/strict-table.py TREE STRICT` | `out/strict-table-*.txt`, `out/strict-*.txt` | one line per strict-counterfactual site (raw output of `audit/intrinsic-function-contracts/tools/validity.tcl` in a scratch copy with `variant-all-trusted.patch`) |
| `tools/nine-sites.tcl`, `tools/facts.tcl`, `tools/relift.tcl`, `tools/drivers.tcl` | (stdout) | argument type of the nine row-table consumers; instance census and binding types; semantic vs relifted HIR signatures; the builder driven with str / List[str] / mutarray values |
| `tools/guards.tcl NAME`, `tools/spec-edges.tcl FILE`, `tools/codegen-count.tcl [-off]` | `out/guards-csv_records-*.txt` | guards per codegen instance; which used instance references which; codegen instance counts with semantic instances on/off |
| `tools/accepts.tcl NAME 0|1` | `out/semantic-off.txt` | is a program accepted with semantic instances off/on |
| existing tools, reused | `out/census-*.txt`, `out/aot-*.txt`, `out/trace-*.txt`, `out/nir/`, `out/compiletime-*.txt`, `out/bench-runs1.txt`, `out/corpus-csv-runs1.txt`, `out/gc-stress.txt` | `opportunistic-semantic-instances/tools/{census,nir-all}.tcl`, `mutarray-construction/tools/{aot,trace}.tcl`, `intrinsic-function-contracts/tools/compiletime.tcl`, `bench/bench.tcl`, `bench/corpus.tcl`, tests under `BOTLISH_NATIVE_GC_STRESS=1` |

`out/experiments/` -- scratch controls that are not part of the fence:
`probes-definition-obstruction.txt` (probes A-D, run with
`opportunistic-semantic-instances/tools/probe.tcl`), `join-gap-v{0,1,2}-*.bot`
(`main.tcl -aot-spec`: early-return join widens raw+typed to `any`),
`strict-annotated-row-builder.{patch,txt}` (the strict counterfactual with
declared `MutableArray[mutarray]` contracts on the row path only: 23 sites).
`out/draft1/` holds the census/AOT/strict/NIR of the first draft, which defined
`scan_record` before its callee.

Reproduce (tree root):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/typed-mutarray-builder-refactor/tools/workloads.tcl OUT 15
tclsh9.0 audit/opportunistic-semantic-instances/tools/census.tcl OUT
tclsh9.0 audit/typed-mutarray-builder-refactor/tools/calltypes.tcl OUT          # and ... OUT -off
tclsh9.0 audit/mutarray-construction/tools/aot.tcl OUT
tclsh9.0 audit/opportunistic-semantic-instances/tools/nir-all.tcl OUTDIR
tclsh9.0 native/generate-scalar-audit.tcl -outdir OUTDIR
tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl 7
# strict counterfactual, in a scratch copy of the tree:
patch -p1 < audit/intrinsic-function-contracts/out/variant-all-trusted.patch
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl > STRICT
python3 audit/typed-mutarray-builder-refactor/tools/strict-table.py . STRICT
tclsh9.0 bench/bench.tcl -runs 1
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/typed-mutarray-builder.test
```
