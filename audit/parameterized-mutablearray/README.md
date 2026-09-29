# Parameterized MutableArray[T] -- audit data

Evidence for `PARAMETERIZED-MUTABLEARRAY.md`. Every tool is observation-only
and runs against whatever tree it is started in (`pwd` is the root), so the
same script measured the parent commit (`498e3c3`, "before") and this
milestone's tree ("after"). Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, native
backend built (rustc 1.98.1).

| tool | output | what |
|---|---|---|
| `tools/census.tcl OUTFILE` | `out/census-{before,after}.txt` (real regime), `out/census-{before,after}-variant.txt` (with `variant-all-trusted.patch`) | every MutableArray constructor call site (`mutable_array_allocate`, `mutarray::from_list`, `mutarray::create`) and its static result type; every function returning a MutableArray; every `List[<MutableArray>]` expression; every `list_get` with its list/result types; every argument position that requires a MutableArray with the argument's static type |
| `tools/controls.tcl` | `out/controls-variant.txt` | scratch rewrites of representative builder operations onto `mutarray::create` / `MutableArray[T]`, appended to a copy of `csv_records.bot` under `variant-all-trusted` (positive and negative controls; nothing is merged) |
| `tools/probe.tcl SNIPPETS` + `tools/probes-typing.txt`, `tools/probes-soundness.txt` | `out/probes-typing.txt`, `out/probes-soundness.txt` | the static type or the compile-time rejection (with the diagnostic) of every probe program: construction, typed get/set/freeze/copy, invariance, erasure attacks (including the forward-reference ones), identity, propagation |
| `out/strict-counterfactual-{before,after}.txt` | | `audit/intrinsic-function-contracts/tools/validity.tcl` in a scratch copy with `variant-all-trusted.patch` applied |
| `out/compiletime-{before,after}-run{1,2}.txt` | | `audit/intrinsic-function-contracts/tools/compiletime.tcl 7` (median of 7), two interleaved runs |
| `out/aot-{before,after}.txt` | | `audit/mutarray-construction/tools/aot.tcl`: `hir::aot` status/blockers of every used instance of the 17 canonical programs |
| `out/trace-{before,after}-variant.txt` | | `audit/mutarray-construction/tools/trace.tcl`: types along the constructor -> builder -> projection -> consumer chain |
| `tools/guard-elision.bot`, `out/guard-elision.txt` | | NIR of a typed and a raw consumer (`main.tcl -emit-nir`): the typed read has no `guard int`; `create` lowers to `mutarrayallocate` + `mutarrayset` |
| `out/bench-runs1.txt` | | `tclsh9.0 bench/bench.tcl -runs 1` |

Reproduce (tree root; "before" = `git archive 498e3c3` into a scratch dir):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/parameterized-mutablearray/tools/census.tcl audit/parameterized-mutablearray/out/census-after.txt
tclsh9.0 audit/parameterized-mutablearray/tools/probe.tcl audit/parameterized-mutablearray/tools/probes-typing.txt
tclsh9.0 audit/mutarray-construction/tools/trace.tcl
tclsh9.0 main.tcl -emit-nir audit/parameterized-mutablearray/tools/guard-elision.bot
tclsh9.0 audit/mutarray-construction/tools/aot.tcl audit/parameterized-mutablearray/out/aot-after.txt
tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl 7
# strict counterfactual (and trace/controls/census "-variant"): in a scratch copy of the tree
patch -p1 < audit/intrinsic-function-contracts/out/variant-all-trusted.patch
tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl
tclsh9.0 audit/parameterized-mutablearray/tools/controls.tcl
# generated code
tclsh9.0 native/generate-scalar-audit.tcl -outdir OUTDIR      # diff against audit/native-scalar-asm
tclsh9.0 audit/intrinsic-function-contracts/tools/nir.tcl OUTDIR
```
