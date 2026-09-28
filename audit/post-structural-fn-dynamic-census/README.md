# Post-structural-Fn dynamic callable census

Observation-only artifacts for [the report](../../POST-STRUCTURAL-FN-DYNAMIC-CENSUS.md).
The measured compiler/source revision is
`a8a306f986809c0a8b54f4763013070f209c248c`. Only current surface `.bot` inputs
enter the canonical population. There are 31 files, 30 executable programs,
9 compiled callvalue sites and 7 distinct source expressions.

## Reproduce

Run from the repository root on Linux (on Windows, use the installed
Ubuntu-24.04 WSL distribution and this mounted checkout). Tcl 9.0.1,
rustc 1.98.1, Valgrind 3.22.0 and binutils are the recorded tools.
Choose fresh scratch directories for the build and counterfactual.

```sh
export LANG=C.utf8 LC_ALL=C.utf8 PYTHONDONTWRITEBYTECODE=1
N=audit/post-structural-fn-dynamic-census
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 "$N/tools/static.tcl"
tclsh9.0 "$N/tools/proofs.tcl"
python3 "$N/tools/build.py" /tmp/botlish-census-build
AB=/tmp/botlish-census-build/target/release/botlish-native
python3 "$N/tools/dynamic.py" "$AB"
python3 "$N/tools/counterfactual.py" /tmp/botlish-census-control "$AB"
python3 "$N/tools/profile_summary.py"
python3 "$N/tools/timing.py" "$AB"
tclsh9.0 native/generate-scalar-audit.tcl -outdir "$N/out/scalar"
tclsh9.0 tests/all.tcl > "$N/out/tests.txt" 2>&1
tclsh9.0 bench/bench.tcl -runs 1 > "$N/out/parity.txt" 2>&1
python3 "$N/tools/verify.py" "$AB"
python3 "$N/tools/report.py"
```

`verify.py` uses the Windows checkout's `core.autocrlf=true` clean-filter
policy for its Git source-freeze check. It does not change Git configuration
or source files. It compares machine-code/scalar artifacts as raw bytes.

Static exports and dynamic counters must repeat exactly. Ir comparisons must
separate repeatable generated/callable-runtime work from allocator differences.
The report deliberately uses ranges for whole-program Ir. Do not regenerate
the committed `audit/native-scalar-asm` baseline for this milestone.

The report generator is scoped to this frozen milestone and asserts its nine
sites and 8,317 natural calls. Its manually explained provenance/early-exit
witnesses must be reviewed if the source corpus changes. This is not a generic
production target analysis or an optimization pass.

## Tools and artifacts

| Tool | Purpose |
|---|---|
| `static.tcl` | Surface-only enumeration, blob manifest, used instances, NIR counts, types, all reachable calls/arguments, AOT status |
| `proofs.tcl` | Offline target unions with exact source/caller witnesses; never updates HIR |
| `build.py` | Copy production crate to scratch; apply existing profiling hooks and optional counter hooks |
| `dynamic.py` | Two natural native runs, target/object populations, value/allocation preservation, audit-off object-code parity, two profiles |
| `profile_summary.py` | Merge recursive Callgrind contexts and diagnose exclusive instruction-count variation |
| `emit.tcl`, `counterfactual.py` | Existing scanner-clone oracle in a fresh scratch source copy; current `.bot` input, no canonical source edits |
| `timing.py` | Five sessions of twenty measured natural runs after warmup; medians and instrumentation-overhead control |
| `verify.py` | Repeated static/NIR export, source freeze, scalar baseline, complete provenance and audit patch |
| `report.py` | Machine-readable site records, aggregate tables, cost consistency assertions and report |

`out/static.jsonl`, `proofs.jsonl`, `sites.json` and `*.counts-*.tsv` are the
primary structured results. `*.hir.txt`, `*.spec.txt`, `*.nir` preserve their
compiler inputs/outputs. NIR is derived from canonical source and is never
an independently selected workload. `*.production.txt` contains native values
and allocation summaries; `preservation.json` records the 30 execution/code
checks. `profiles/` contains uncounted production-code Callgrind data;
`counterfactual/` is a separate noncanonical hypothetical control. `work.json`
and `repeatability.txt` expose exact attribution and allocator variation.
`provenance.json` hashes the source, compiler trees, binaries and generated NIR.
`audit-build.diff` is the complete actual instrumentation diff from production.

The original post-R2a audit patch, profile wrapper, Callgrind parsers and the
post-module exact-target control are reused **read-only**. Their historical
corpus enumeration is never invoked. The current reducer corrects for
Callgrind recursive-context suffixes when combining per-site inclusive work;
historical reducers and frozen outputs remain untouched.

Counter TSV kinds: 1 call, 2 callenv, 3 callvalue, 4 callmulti,
5 callenvmulti, 6 tail/tailenv backedge. Function IDs map to NIR headers;
stable site keys additionally carry source expression, instance and program.
Block `objects` counts closure identities, whereas `target` counts code IDs.
Raw addresses are neither stable site IDs nor retained GC roots.

The target hook is disabled for machine-code checks, timing baselines and Ir
profiles. It makes Rust-side bookkeeping allocations but no Botlish heap
allocation and no GC attempt. The successful dispatch paths themselves are
allocation-free; closure factories and target bodies are measured separately.
