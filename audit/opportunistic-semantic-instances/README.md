# Opportunistic semantic function instances -- audit data

Evidence for `OPPORTUNISTIC-SEMANTIC-INSTANCES.md`. Every tool is observation-
only and runs against whatever tree it is started in (`pwd` is the root), so the
same script measured the parent commit (`b1e3e45`, "before") and this
milestone's tree ("after"). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, native
backend built (rustc 1.98.1).

| tool | output | what |
|---|---|---|
| `tools/census.tcl OUTFILE [-off]` | `out/census-after.txt` | the semantic-instance census of the 17 canonical programs: every used instance (function, entry types, result, status, program calls), its recursion/SCC membership, the codegen relationship (`hir::specialize` call targets, the emitted NIR functions), and totals (requests, trivial, cache hits, walks, rounds, unique, valid/invalid/declined, functions with more than one instance, maximum per function, shared/inlined/no-site, retained state size) |
| `tools/calltypes.tcl OUTFILE` | `out/calltypes-{before,after}.txt` | the semantic type of every reachable exact-block call site of the 17 programs, one line per site: which call results became precise |
| `tools/probe.tcl SNIPPETS [-off]` + `tools/probes-{controls,negatives,recursion,list,builder}.txt` | `out/probes-*.txt`, `out/probes-*-off.txt` | the static type or compile-time rejection (with diagnostic) of every probe program with the layer enabled and, with `-off` (`hir::semantic::enabled 0`), the parent's behavior |
| `tools/nir-all.tcl OUTDIR` | (diffed, byte-identical) | the used codegen-instance labels and full NIR text of the 17 programs |
| `out/aot-{before,after}.txt` | | `audit/mutarray-construction/tools/aot.tcl`: `hir::aot` status of every used codegen instance (245 both) |
| `out/strict-counterfactual-{before,after}.txt` | | `audit/intrinsic-function-contracts/tools/validity.tcl` in a scratch copy with `variant-all-trusted.patch` applied (35 -> 32 sites) |
| `out/trace-{before,after}-variant.txt` | | `audit/mutarray-construction/tools/trace.tcl` in the same scratch copies (the nine builder-flow sites) |
| `out/compiletime-{before,after}-run*.txt` | | `audit/intrinsic-function-contracts/tools/compiletime.tcl 7` (median of 7), interleaved runs |
| `out/bench-runs1.txt` | | `tclsh9.0 bench/bench.tcl -runs 1` |

Reproduce (tree root; "before" = `git archive b1e3e45` into a scratch dir with
`native/target` symlinked to the built backend):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/opportunistic-semantic-instances/tools/census.tcl audit/opportunistic-semantic-instances/out/census-after.txt
tclsh9.0 audit/opportunistic-semantic-instances/tools/calltypes.tcl OUT      # also in the before tree, then diff
tclsh9.0 audit/opportunistic-semantic-instances/tools/probe.tcl audit/opportunistic-semantic-instances/tools/probes-controls.txt
tclsh9.0 audit/opportunistic-semantic-instances/tools/probe.tcl audit/opportunistic-semantic-instances/tools/probes-controls.txt -off
tclsh9.0 audit/opportunistic-semantic-instances/tools/nir-all.tcl OUTDIR      # before and after: diff -r
tclsh9.0 audit/mutarray-construction/tools/aot.tcl OUT
tclsh9.0 native/generate-scalar-audit.tcl -outdir OUTDIR                     # diff against the parent's
tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl 7
# strict counterfactual (and trace): in a scratch copy of the tree
patch -p1 < audit/intrinsic-function-contracts/out/variant-all-trusted.patch
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl
tclsh9.0 audit/mutarray-construction/tools/trace.tcl
tclsh9.0 bench/bench.tcl -runs 1
```
