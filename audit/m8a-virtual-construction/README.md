# M8.a virtual-construction audit artifacts

Measurement and census output for
[M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md](../../M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md).
Every before/after pair comes from the *same* tree and binary, switched only
by native lowering's `-virtual-construction-opt 0|1` (or
`BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT=0|1` for tools that do not take
lowering options), so no comparison depends on reverting or stashing a
change.

```sh
export LANG=C.utf8 LC_ALL=C.utf8

# Scaling probes (bench/virtual-construction.tcl): runtime-variable N.
tclsh9.0 bench/virtual-construction.tcl -opt 0 -runs 5 -sizes "1000 2000 4000 8000 16000"  > probes-opt0.txt
tclsh9.0 bench/virtual-construction.tcl -opt 1 -runs 5 -sizes "1000 2000 4000 8000 16000"  > probes-opt1.txt

# Frozen workloads, off vs on, median of 5 sessions x best of 5 runs.
tclsh9.0 audit/m8a-virtual-construction/tools/workloads.tcl -runs 5 -sessions 5 > workloads.txt

# The repository's own unmodified benchmark scripts, under the env switch.
BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT=0 tclsh9.0 bench/ai_text_clean.tcl -runs 5 > ai_text_clean-opt0.txt
BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT=0 tclsh9.0 bench/uri-steady.tcl -runs 7 -sessions 5 > uri-steady-bench-opt0-*.txt

# Per-program census (plans, barrier reasons, per-function code, allocation
# reports off/on, the product-shaped List census).
tclsh9.0 audit/m8a-virtual-construction/tools/census.tcl bench/uri-steady.bot uri-steady
tclsh9.0 audit/m8a-virtual-construction/tools/census.tcl corpus:csv csv
```

Contents:

* `probes-baseline-pre.txt` -- the scaling probes run against the tree
  *before* any M8.a production change (no flag existed yet); its copy and
  allocation columns are identical to `probes-opt0.txt`'s.
* `probes-opt0.txt`, `probes-opt1.txt` -- final scaling probes.
* `workloads.txt` -- the frozen-workload table.
* `ai_text_clean-opt{0,1}.txt`, `uri-steady-bench-opt{0,1}-*.txt` -- the
  unmodified `bench/` scripts, off and on (uri-steady: four alternating
  sessions).
* One directory per program (`uri-steady`, `refined-checks`, and the
  `examples/stdlib` corpus programs with their own demo drivers), each
  with `summary.txt`, `analysis.txt` (hir::construction::explain),
  `sites.txt` (every construction site: virtual or materialized, with its
  barrier reason), `functions.txt` (per NIR function, off and on),
  `alloc.txt` (allocation reports off and on) and `products.txt` (the H2
  product-shaped List census).
* `tools/census.tcl`, `tools/workloads.tcl` -- the observation-only tools
  that produced them.

Timings were taken on an otherwise idle 4-core host (nothing else running);
allocation, copy and code-size numbers are deterministic.
