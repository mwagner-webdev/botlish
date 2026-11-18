# audit/mid-end-port/readiness

The evidence of PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md: whether the
November 7 audit's conclusions (`../README.md`, kept as it was) still hold
on current main, measured at `db473ee` (2026-11-17) on a shared 4-core,
16 GB Linux x86-64 container. Nothing here is part of the compiler: the
programs are audit-only probes, the tools measure.

## Files

| file | what it is |
|---|---|
| `tools/peak.py` | runs one command, prints its wall time and peak resident size (`/usr/bin/time` is not on every host) |
| `tools/kernel-grid.tcl` | the six-version kernel (`../kernel/`) over a grid of sizes: build apart from run, peak memory, the native allocation and GC summary |
| `tools/kernel-generic.tcl` | the three native kernel versions built specialized and unspecialized |
| `tools/block-copy.tcl` | the reduced reproducer of `hir::types::Block`'s inherited context: the cost of the first write into a shared `types` dict of N entries |
| `tools/placeholder-map.tcl` | the reduced reproducer of native lowering's placeholder numbering: one `string map` with a placeholder per function over every function's text |
| `tools/native-phases.tcl` | lowering to NIR split by every analysis entry point of `::hir` and `::native` |
| `tools/frontend-phases.tcl` | one front-end compilation split into parsing, the mid-end, its builds, type inference, instance walks, warnings |
| `tools/ladder.tcl` | prints `../tools/scale.tcl` result files (current or historical) as one table with per-line cost and growth |
| `tools/callgraph.tcl` | the static and the dynamic procedure call graph of `::hir`, its strongly connected components, which procedures a front-end build and native lowering run, and the mid-end's calls into `::core` |
| `tools/registries.tcl` | the size of the process-wide registries a Botlish mid-end would receive as data |
| `tools/hir-surface.tcl` | a checked HIR's top-level tables, node kinds and declaration registries: what a boundary carries |
| `tools/checker.tcl` | runs `programs/checker.bot` on every backend against `programs/checker.tcl`, then its native cost against the Tcl reference's |
| `tools/mutual.tcl` | times `programs/mutual.bot`'s three forms of one mutually recursive walk natively |
| `tools/stdlib.tcl` | `programs/stdlib.bot`'s operations one at a time at growing sizes, with the copy counters that show linear or quadratic cost |
| `programs/checker.bot`, `programs/checker.tcl` | a compiler-shaped checker (payload-enum IR, scoped environment, type lattice, worklist over the call graph, sorted diagnostics) and its Tcl reference |
| `programs/mutual.bot` | a three-member walker cycle written merged, with function values, and flat |
| `programs/mutual-direct.bot`, `programs/mutual-context.bot` | the cycle written directly, and with a context requirement: both rejected today |
| `programs/stdlib.bot` | sort, text, struct update, List growth, nested collections, split |
| `programs/stdlib-index.bot`, `stdlib-index-worklist2.bot`, `stdlib-index-push.bot` | which index accesses the completion analysis proves |
| `programs/stdlib-nested-context.bot` | a context-owned collection's element pushed through: rejected today |
| `matrices/findings.tsv` | the required findings matrix: question, verdict, reason, evidence |
| `matrices/core-dependencies.tsv`, `matrices/authority.tsv` | the mid-end's calls into `core::` by namespace and purpose, and the proposed source of truth of each shared rule |
| `results/` | every output the report cites, one file per measurement |

## Reproducing

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
R=audit/mid-end-port/readiness/results
T=audit/mid-end-port/readiness/tools
S=$(mktemp -d)

# the kernel (section 7)
tclsh9.0 audit/mid-end-port/tools/kernel.tcl -functions 1500 -depth 8 -repeat 5 > $R/kernel-1500x8.txt
tclsh9.0 $T/kernel-grid.tcl -sizes "375:8 750:8 1500:8 3000:8 1500:6 1500:7 1500:9" -repeat 3 > $R/kernel-grid.txt
tclsh9.0 audit/mid-end-port/tools/kernel-callgrind.tcl > $R/kernel-callgrind.txt
tclsh9.0 $T/kernel-generic.tcl > $R/kernel-generic.txt

# the probes (sections 4-6, 8)
tclsh9.0 $T/checker.tcl -agree "300:6" -sizes "2000:8 8000:8" -repeat 3 > $R/checker.txt
tclsh9.0 $T/mutual.tcl -trees 3000 -depth 10 -repeat 3 > $R/mutual.txt
tclsh9.0 $T/stdlib.tcl -sizes "1000 4000 16000" > $R/stdlib.txt
for f in mutual-direct mutual-context stdlib-index stdlib-index-worklist2 stdlib-index-push stdlib-nested-context; do
    tclsh9.0 main.tcl -warnings off audit/mid-end-port/readiness/programs/$f.bot
done

# the front end at scale (sections 9-10)
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-frontend-helper.txt -passes "8 16 32 64 128" -generic 1 -native 0
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-frontend-nohelper.txt -passes "8 16 32 64" -generic 0 -native 0
tclsh9.0 $T/ladder.tcl $R/scale-frontend-helper.txt $R/scale-frontend-nohelper.txt audit/mid-end-port/results/scale.txt audit/mid-end-port/results/scale-frontend.txt
for p in 8 16 32 64 128; do tclsh9.0 audit/mid-end-port/tools/synth.tcl -out $S/h$p -passes $p -generic 1; done
for p in 16 64 128; do tclsh9.0 $T/frontend-phases.tcl $S/h$p/main.bot >> $R/frontend-phases.txt; done
tclsh9.0 audit/semantic-instance-scalability/tools/remaining-copies.tcl contexts $S/h8/main.bot $S/h16/main.bot $S/h32/main.bot > $R/block-contexts.txt
tclsh9.0 $T/block-copy.tcl > $R/block-copy.txt
for p in 16 32; do tclsh9.0 audit/mid-end-port/tools/infer-profile.tcl . $S/h$p/main.bot audit/mid-end-port/results/infer-procs.txt; done > $R/infer-profile.txt
tclsh9.0 audit/mid-end-port/tools/budget.tcl -types "16 17 64 256 1024" > $R/budget.txt

# the native path (sections 11-12)
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-native-specialized.txt -passes "8 16" -generic 0 -specialize 1
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-native-specialized-32.txt -passes "32" -generic 0 -specialize 1 -memory-mb 10240 -cap 2400
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-native-generic.txt -passes "8 16 32 64" -generic 0 -specialize 0
for p in 32 64; do tclsh9.0 audit/mid-end-port/tools/synth.tcl -out $S/g$p -passes $p -generic 0; done
for p in 32 64; do tclsh9.0 $T/native-phases.tcl $S/g$p/main.bot -specialize 0; done > $R/native-phases.txt
for p in 32 64; do tclsh9.0 $T/native-phases.tcl $S/g$p/main.bot -specialize 0 -top 25 -namespaces "::native::lower ::hir::specialize"; done > $R/native-lower-procs.txt
for p in 32 64; do tclsh9.0 $T/native-phases.tcl $S/g$p/main.bot -specialize 0 -top 20 -namespaces "::native::lower ::hir::escape ::hir::blockescape ::hir::affine ::hir::construction ::hir::traversal ::native::rawabi ::native::shortstr ::hir::stringregion"; done > $R/native-lower-procs-2.txt
tclsh9.0 $T/placeholder-map.tcl > $R/placeholder-map.txt

# the workload (section 18) and the boundary (sections 13-14)
W=audit/mid-end-port/tools/workload.tcl
tclsh9.0 $W units > $R/gate-units.txt
tclsh9.0 $W phases > $R/gate-phases.txt
tclsh9.0 $W analyses std::event_loop > $R/event-loop-analyses.txt
tclsh9.0 $W interchange > $R/interchange.txt
tclsh9.0 $T/registries.tcl > $R/registries.txt
G=tests/golden
tclsh9.0 $T/hir-surface.tcl $G/payload-enums.bot $G/traits.bot $G/coroutines.bot examples/games/2048/bench.bot > $R/hir-surface.txt

# the call graph (section 5; about 40 minutes: every ::hir procedure wrapped)
tclsh9.0 $T/callgraph.tcl $R/callgraph -frontend "$G/payload-enums.bot $G/exhaustive-match.bot $G/traits.bot \
    $G/structs-and-enums.bot $G/affinity.bot $G/contexts.bot $G/coroutines.bot $G/mutable-map.bot $G/refinements.bot \
    $G/callables.bot $G/methods.bot $G/errors.bot $G/decimal-rounded.bot $G/layout-arrays.bot $G/tree-struct.bot \
    $G/value-identity.bot $G/trait-constrained-types.bot $G/fold-loops.bot examples/games/2048/golden.bot \
    examples/games/icy-tower/headless.bot" \
    -native "examples/games/2048/bench.bot $G/payload-enums.bot $G/mutable-map.bot $G/fold-loops.bot audit/mid-end-port/kernel/ranges-enums.bot"
```

A result file of `scale.tcl` is appended to: remove it first to measure
again. `scale.tcl` caps each size with `timeout` and `ulimit -v` (Linux
only); the specialized 32-pass run is capped at 10 GiB so that it cannot
take the machine's memory. The ladders, the gate and the call graph took
about two hours together; several shared the machine with one or two other
single-threaded measurements, which the report notes where it matters.
