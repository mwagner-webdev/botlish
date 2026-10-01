# Machine-code proof-loss investigation: artifacts

Raw evidence for
[MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md](../../MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md).
Investigation only. Nothing here is a build product, and no compiler, runtime,
library or canonical `.bot` file was changed.

* The audit instrumentation is the post-R2.a census's
  `audit/post-r2a-dynamic-census/tools/audit-native.patch`. It is applied to a
  scratch copy of `native/`, never to the tree.
* The one counterfactual (the committed
  `audit/post-module-static-exact-target-census/counterfactual/exact-target.diff`)
  is applied in a scratch git worktree. It measures a ceiling. It is not a
  proposed source change.
* The probes under `probes/` are audit-only inputs that isolate one mechanism
  each. They are not benchmarks.

## Frozen fence

`c251e7c` (= `origin/main` when the investigation started): structs, struct
scalar replacement and value transport complete, plus the CI regeneration of
the scalar assembly corpus. Tcl 9.0.1, rustc 1.98.1, Cranelift 0.135.2,
valgrind 3.22, `LANG=C.utf8`.

## Contents

| path | contents |
|---|---|
| `out/regen-identity.txt` | `native/generate-scalar-audit.tcl` rerun on the fence, diffed against the committed `audit/native-scalar-asm/`: byte-identical (only `README.md`'s generating-commit line differs) |
| `out/asm-history/*.txt` | per-function machine-code bytes through every committed regeneration (`tools/fnhist.py`) and across the M9 → now fences (`tools/fnsizes.py`). Git archaeology only; nothing rebuilt |
| `out/nir-identity.txt` | the fence's NIR for every corpus program vs the committed pre-struct (`84f4d68`) and struct-scalar-replacement NIR snapshots |
| `out/nir/*.nir` | the NIR `bench/bench.tcl`'s Cranelift column runs (`native::nir`), for the four scalar benchmarks, `refined-checks.ir`, and the exact-target counterfactual |
| `out/facts/*.txt` | per layer: semantic instances, codegen keys, closed-caller theorems, entry/result Ranges and call targets (`tools/facts.tcl`); Range openness vs `InstanceClosed` (`tools/openness.tcl`); semantic instances before/after `native::prepareHir` (`tools/prepare-census.tcl`); one file per probe |
| `out/profiles/<name>/` | callgrind, steady state, per run: `census.txt` (per-function self/inclusive Ir, per-site and per-helper costs), `mix.txt` (executed-instruction classes), `profile.txt`, `run-output.txt`. `hist-*` re-run the committed historical NIR on the current runtime |
| `out/ir-series.txt` | the total Ir/run of every profile |
| `cases/fib/` | `fib<int>`: pre-M9 (`caf8ca7`), old-good M9 (`0c2dead`) and current (`c251e7c`) machine code, and current NIR |
| `cases/refined-checks/` | old-good R2 (`844c37e`) vs current (`c251e7c`) scanner machine code; R2 / current / counterfactual scanner NIR; `check` at M9, at R2.a.1 (`check<generic>`) and now |
| `probes/*.bot` | `hof-single-exact` (one exact callable through an envless top-level parameter), `hof-two-exact` (two exact callables), `hof-capturing` (`scan_while`'s capturing-closure shape, one target), `emailish-local-copy` (`lib/web.bot`'s `emailish?` copied into a main program) |

## Tools

| tool | what |
|---|---|
| `tools/run-all.sh SCRATCH` | reproduces everything under `out/` (about 4 minutes) |
| `tools/emit-nir.tcl` | the NIR a tree emits for a `.bot` (`surface::readProgramFile`) or `.ir` (post-R2.a route) program, through `native::nir` |
| `tools/facts.tcl` | the per-layer fact dump described above |
| `tools/openness.tcl` | `hir::range::OpenInstances` vs `hir::specialize::closed` per generic instance |
| `tools/prepare-census.tcl` | `hir::semantic::census` before and after `native::prepareHir` |
| `tools/fnsizes.py`, `tools/fnhist.py` | per-function sizes from the committed assembly corpus, by commit |

Reused unchanged: `audit/post-r2a-dynamic-census/tools/build-audit-native.sh`,
`profile-nir.sh` and `cgcensus.py`, and
`audit/post-m8a-common-inefficiency/tools/cgprof.py`.

## Reproduce

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
bash audit/machine-code-proof-loss/tools/run-all.sh /tmp/mcpl-scratch
```

Callgrind counts repeat to within about 250 Ir per run. Machine code, NIR
and facts are deterministic.
