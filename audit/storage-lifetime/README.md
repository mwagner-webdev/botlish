# audit/storage-lifetime -- the storage lifetime facts and their evidence

Material of STORAGE-LIFETIME-FACTS-MILESTONE-1.md (`docs/`): the tools that
report and check `hir/lifetime.tcl`'s facts -- identity confinement per
region, ordinary-value liveness, suspension liveness -- against independent
sources. Nothing here is loaded by the compiler.

| file | what |
|---|---|
| `tools/report.tcl` | the fact report of programs (`hir::lifetime::report`), by default the census corpus (`../storage-static-reuse/cases/`) and `cases/` into `results/facts/` |
| `tools/oracle.py` | the independent oracle: generates programs of a small statement language and the facts its own model of them predicts (suspension live sets, verdicts per region); `selftest` checks the model on hand-written cases |
| `tools/fuzz.tcl` | runs the oracle's programs through the analysis and compares: a value live across a yield the analysis calls dead, or an object it confines where the oracle's model lets it escape, is UNSOUND; with `-strings 0` (Ints only) also the C differential |
| `tools/persist.tcl` | the C backend's frame persistence (`ccompile::Persist`, the `coroutine_frames` manifest) against the analysis's suspension live sets: every value the analysis says survives a suspension needs a frame field; the fields nothing requires are reported (Persist's line-order imprecision, C's own temporaries) |
| `tools/reachability.tcl` | the native backend's reachability under `BOTLISH_NATIVE_GC_STRESS=1` against the iteration verdicts: a program per way of disposing of a per-iteration String, run at two sizes; a confined claim whose reachable peak grows is CONTRADICTED |
| `tools/mutate.tcl`, `tools/mutants.txt` | the code mutants of `hir/lifetime.tcl`: each breaks one rule and must be killed by the test of `tests/storage-lifetime.test` (or the oracle) its `!!` line names |
| `results/` | the committed results: `facts/` (the corpus's reports), `fuzz.txt`, `persist.txt`, `reachability.txt`, `mutants.txt`, `bench.md` |

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml   # for reachability.tcl
tclsh9.0 audit/storage-lifetime/tools/report.tcl
python3 -I audit/storage-lifetime/tools/oracle.py selftest
tclsh9.0 audit/storage-lifetime/tools/fuzz.tcl -seeds 1-12 -count 40
tclsh9.0 audit/storage-lifetime/tools/fuzz.tcl -seeds 1-6 -count 40 -strings 0
tclsh9.0 audit/storage-lifetime/tools/persist.tcl audit/storage-static-reuse/cases/*.bot examples/c-freestanding/kiosk/*.bot
tclsh9.0 audit/storage-lifetime/tools/reachability.tcl
tclsh9.0 audit/storage-lifetime/tools/mutate.tcl
tclsh9.0 bench/storage-lifetime.tcl
```

Every tool is deterministic (the oracle's programs are a function of the
seed); only the benchmark's times vary run to run.

The facts' first consumer, native scratch storage
(STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md), has checks of its own in
`../storage-scratch/`: the oracle here checks the facts, never a storage
implementation, so the storage mechanism -- the plan, its lowering, the
provider and the collector -- is checked there by a differential fuzzer
under GC stress and poisoning, and by mutants of each part. The three
facts that milestone fixed are tests of `tests/storage-lifetime.test`
(`sl-error-let-through`, `sl-fresh-holds-parameter`,
`sl-recursive-reasons-converge`).
