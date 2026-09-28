# Post-module-static exact-target counterfactual census: artifacts

Raw data for
[POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md](../../POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md).
Nothing here is a build product or a production change. Every tool only
observes:
* The audit instrumentation (the post-R2.a census's unchanged
  `audit/post-r2a-dynamic-census/tools/audit-native.patch`) is applied to a
  scratch copy of `native/`, never to the tree.
* Every counterfactual lives in a scratch git worktree whose own
  `lib/web.bot` is rewritten by a diff in `counterfactual/`. The tree's own
  `lib/web.bot` is never touched.

| path | contents |
|---|---|
| `baseline/environment.txt` | tree, binaries, audit patch, host, toolchain |
| `baseline/prod.txt`, `baseline/cf-*.txt` | deterministic baseline (`tools/baseline.tcl`) of production and of each counterfactual worktree: used instances (generic / CLOSED / OPEN / blockescape), block environments (captures vs. module-static refs), NIR shape and op counts, `callvalue` sites, machine bytes, parameter entry Ranges, countloop induction Ranges, allocation summary |
| `baseline/targetgraph-*.txt` | structural proof of `scan_while`'s target graph (`tools/targetgraph.tcl`), and of `scan_local`/`scan_alpha` in the counterfactual |
| `baseline/stringregion-*.txt` | StringRegion's own verdict per predicate/scanner instance, with the disqualifying node named (`tools/regionprobe.tcl`) |
| `baseline/nir/*.nir` | every NIR profiled: `prod`, `cf-exact`, `cf-local-only`, `cf-alpha-only`, the StringRegion-off controls (`*-noregion`), the pre-module-static frozen tree and its counterfactual (`hist-*`, copied from the post-R2.a census), and the four single-input probes (`probes/`) |
| `counterfactual/*.diff` | the scratch-only `lib/web.bot` rewrites: `exact-target` (both call sites; hunks byte-identical to the post-R2.a census's), `local-only`, `alpha-only` |
| `profiles/<name>/` | callgrind profile per program (`census.txt`, `profile.txt`, `instr.txt`, `mix.txt`, `jitmap.txt`, `callgrind.out`, `program.nir`); `intclasses.md` and `moves.txt` for `prod` and `cf-exact` |
| `dynamic/validate-audit.txt` | audit vs. production binary on all 16 programs: value, size, object, VCode, allocation counters, allocation sites, JIT-map coverage |
| `dynamic/gc-stress-reset.txt` | `BOTLISH_NATIVE_GC_STRESS=1 bench 8` on both binaries: identical values and collection counts (static slots, rooting, reset) |
| `dynamic/parity-*.txt` | semantic parity: 95 addresses × 4 backends × 2 paths (`tools/parity.tcl`, `tools/corpus.txt`) |
| `dynamic/alloc-sites-*.txt` | `run --alloc sites` per program |
| `dynamic/delta-*.md` | before/after tables (`tools/cfdelta.py`): production vs. the three counterfactuals; historical same-binary bridge; StringRegion-off pair |
| `dynamic/utf8-seek.md` | UTF-8 seek Ir per helper (`tools/seek.py`) |
| `dynamic/reclamation.md` | deferred `Vm::reset` reclamation per program |
| `dynamic/wallclock-7x200.md`, `dynamic/wallclock-15x200.md` | wall-clock control, production binary |
| `dynamic/repeatability.md` | repeat profiles and 10 / 40 collected runs |
| `static/corpus-generality.md` | the post-R2.a census's corpus census, re-run on this tree |

Tools (this directory's own; everything else is reused unchanged from
`audit/post-r2a-dynamic-census/tools/` and `audit/post-m8a-common-inefficiency/tools/`):

| tool | what |
|---|---|
| `tools/run-all.sh SCRATCH` | reproduces every artifact above |
| `tools/baseline.tcl` | successor of the post-R2.a `baseline.tcl` for the module-static representation: counts `guard` and `guardbool` separately, adds `staticget`/`staticset`/`native`, CLOSED, captures vs. `staticRefs`, `callvalue` sites |
| `tools/targetgraph.tcl` | per call site of a scanner: the HIR form and exact type reaching each parameter, the callee Block's captures / module-static refs, `InstanceClosed`, the closed-caller theorem, the NIR forms |
| `tools/regionprobe.tcl` | `hir::stringregion::ConsumingShape` / `consumingParamsOf` verdicts, naming the node that disqualifies an instance |
| `tools/parity.tcl` + `tools/corpus.txt` | semantic parity: `web::emailish?` through a `.bot` program and root `emailish?` through a `.ir` program, on interp / compile / cranelift-generic / cranelift, against the Tcl validator as oracle |
| `tools/cfdelta.py` | per-function and per-helper deltas between `census.txt` files, matched by name |
| `tools/seek.py` | UTF-8 seek Ir per helper: addr2line line attribution of `rt_substr` 562–564, `rt_str_region_eq` 613–615, `region_one_scalar` 811–813 |

Reproduce (Linux, `LANG=C.utf8 LC_ALL=C.utf8`, Tcl 9.0.1, rustc 1.98.1,
valgrind 3.22; `PYTHONDONTWRITEBYTECODE=1` keeps the post-M8.a tools'
tracked `__pycache__` untouched):

```sh
bash audit/post-module-static-exact-target-census/tools/run-all.sh /tmp/census-scratch
```

Instruction counts repeat to within 107 Ir (production) and 324 Ir
(counterfactual) across repeated profiles and 10 / 20 / 40 collected runs.
Allocation, call and site counts are exact.
