# Post-R2.a frozen-baseline dynamic census: artifacts

Raw data for [POST-R2A-DYNAMIC-CENSUS.md](../../POST-R2A-DYNAMIC-CENSUS.md).
Nothing here is a build product or a production change. Every tool only
observes. The instrumentation (`tools/audit-native.patch`) is applied to a
*scratch copy* of `native/`, never to the tree, and its generated code is
byte-identical to production (`tools/validate-audit.sh`).

| path | contents |
|---|---|
| `baseline/frozen-r2a3.txt` | deterministic baseline of the frozen tree (`tools/baseline.tcl`): used instances with generic/OPEN/blockescape flags, OpenInstances, blockescape internal variants, NIR shape and op counts, machine bytes (total and per function), parameter entry Ranges, countloop induction-binding Ranges, allocation summary |
| `baseline/history-{pre-r2,r2,r2a,r2a2}.txt` | the same for the historical trees (pre-R2 `0c2dead`, R2 `e7d53b6`, R2.a `63b2199`, R2.a.2 `b472022`) |
| `baseline/nir/*.nir` | the exact NIR profiled: frozen, the four historical trees, the exact-target counterfactual (`cf-exact.nir`), and the frozen tree under `-string-region-opt 0` (`frozen-noregion.nir`) |
| `baseline/environment.txt` | host, toolchain and build configuration |
| `baseline/wallclock.md` | wall-clock control (production binary): `tools/wallclock.py`, 7 interleaved sessions × 200 runs, plus 3 canonical `bench/bench.tcl` sessions |
| `dynamic/alloc-refined-checks.txt` | `native::allocationReport` by site, first run and steady state (post-M8.a `tools/alloc.tcl`, unchanged) |
| `dynamic/reclamation.md` | deferred reclamation cost: Ir per between-run `Vm::reset` (`tools/reclaim.sh`) |
| `profiles/frozen/refined-checks/` | the primary profile: `census.txt` (`tools/cgcensus.py`), `profile.txt`/`instr.txt`/`mix.txt` (post-M8.a `cgprof.py`), `moves.txt`, `static-mix.txt`, `jitmap.txt`, `callgrind.out`, `program.nir` |
| `profiles/probes/*/` | diagnostic input controls: `unicode-only`, `ascii-only`, `invalid-only`, `early-invalid` (`probes/*.ir`), and the post-M8.a `refined-checks-ascii` probe |
| `profiles/history/*/` | the historical trees, same binary, same method |
| `profiles/counterfactual/exact-target/` | the exact-target counterfactual (`counterfactual/exact-target.diff`, applied only in a scratch worktree) |
| `profiles/counterfactual/string-region-off/` | the frozen tree under `-string-region-opt 0` (StringRegion positive control) |
| `probes/*.ir` | `bench/refined-checks.ir`'s own `check`/`q`, one input each. Never benchmarks |
| `counterfactual/exact-target.diff` | audit-only `lib/web.bot` diff for the counterfactual, never applied to the tree |
| `static/corpus-generality.md` | per-program static population of each candidate's pattern across the repository corpus (`tools/corpus.tcl`) |

Tools:

| tool | what |
|---|---|
| `tools/build-audit-native.sh WORKDIR` | copies `native/` to WORKDIR, applies `tools/audit-native.patch`, builds there; prints the binary path |
| `tools/audit-native.patch` | the post-M8.a patch, unchanged (`botlish_audit_run` toggle frame, `BOTLISH_AUDIT_JITMAP`), plus two harness-only additions. `BOTLISH_AUDIT_SKIP_FIRST=1` runs run 0 outside the collected frame (steady state only). `botlish_audit_reset` wraps the between-run `Vm::reset` so its reclamation cost is measurable on its own. No change to code generation or any runtime helper |
| `tools/validate-audit.sh PROD AUDIT FILE.nir` | value, `size`, relocatable `object` bytes, VCode, allocation summary, allocation sites, and JIT-map coverage all identical between production and audit binaries |
| `tools/emit-nir.tcl PROGRAM.ir [OPTS]` | the NIR `bench.tcl` would run, emitted by the tree in the *current directory* (so the same tool serves historical worktrees) |
| `tools/baseline.tcl PROGRAM.ir OUT` | the deterministic baseline (run from the tree to be measured) |
| `tools/profile-nir.sh AUDIT FILE.nir RUNS OUTDIR` | callgrind (post-M8.a configuration + `BOTLISH_AUDIT_SKIP_FIRST`), then `cgprof.py` and `cgcensus.py`; figures are per collected run (RUNS-1) |
| `tools/profile-all.sh AUDIT OUTDIR [WORKTREES]` | every frozen, probe and historical profile, plus the repeatability and run-count controls |
| `tools/counterfactual.sh AUDIT OUTDIR WORKTREES` | the two counterfactual profiles |
| `tools/reclaim.sh AUDIT PROD NAME=FILE.nir...` | the reclamation table |
| `tools/cgcensus.py` | call-graph attribution: exact in-region invocation counts, self/inclusive per function, per-caller helper cost, `callvalue` dispatch split, inlined-source-line attribution of helper self cost (addr2line), JIT class mix per function |
| `tools/intclasses.py PROFILE [FN...]` | per-function tagged-Int / Bool-word / completion / stack-store detail, and the raw-Int upper bound |
| `tools/summarize.py PROFILE...` | the cross-profile headline table |
| `tools/wallclock.py BIN SESSIONS RUNS NAME=FILE.nir...` | wall-clock control |
| `tools/corpus.tcl OUT` | corpus generality census |

Reproduce (Linux, `LANG=C.utf8 LC_ALL=C.utf8`, Tcl 9.0.1, rustc 1.98.1,
valgrind 3.22; `export PYTHONDONTWRITEBYTECODE=1` keeps the post-M8.a
tools' tracked `__pycache__` untouched):

```sh
cargo build --release --manifest-path native/Cargo.toml
AB=$(bash audit/post-r2a-dynamic-census/tools/build-audit-native.sh /tmp/auditbuild | tail -1)
PB=native/target/release/botlish-native
D=audit/post-r2a-dynamic-census
tclsh9.0 $D/tools/baseline.tcl bench/refined-checks.ir $D/baseline/frozen-r2a3.txt
bash $D/tools/validate-audit.sh $PB "$AB" $D/baseline/nir/frozen.nir
bash $D/tools/profile-all.sh "$AB" $D/profiles /tmp/wt
bash $D/tools/counterfactual.sh "$AB" $D/profiles/counterfactual /tmp/wt
bash $D/tools/reclaim.sh "$AB" $PB frozen=$D/baseline/nir/frozen.nir r2=$D/baseline/nir/r2.nir
python3 audit/post-m8a-common-inefficiency/tools/moves.py $D/profiles/frozen/refined-checks
python3 $D/tools/intclasses.py $D/profiles/frozen/refined-checks
tclsh9.0 audit/post-m8a-common-inefficiency/tools/alloc.tcl bench/refined-checks.ir $D/dynamic/alloc-refined-checks.txt
tclsh9.0 $D/tools/corpus.tcl $D/static/corpus-generality.md
python3 $D/tools/wallclock.py $PB 7 200 frozen=$D/baseline/nir/frozen.nir r2=$D/baseline/nir/r2.nir
```

Instruction counts are repeatable to within ±0.004% (±350 Ir of 8.56M)
across repeated profiles and independent of the collected run count once
run 0 is excluded. Allocation, call and site counts are exact.
