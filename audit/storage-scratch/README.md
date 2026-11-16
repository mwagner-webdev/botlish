# Compiler-managed scratch storage: audit material

The material of STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md (the
completion report, `docs/`): confined temporary Strings placed natively in
compiler-managed scratch storage, from the lifetime facts of
`hir/lifetime.tcl` through the storage-use plan (`hir/storageplan.tcl`),
native lowering (`native/lower.tcl`'s "Scratch storage") and the storage
provider (`native/src/runtime/scratch.rs`).

## Tools

All run from the checkout's root with `tclsh9.0` and `LANG=C.utf8
LC_ALL=C.utf8`, after `cargo build --release --manifest-path
native/Cargo.toml`. Each keeps its scratch files in a temporary directory.

* `tools/plan.tcl ?-out DIR? ?FILE.bot ...?` -- the storage-use plan of
  each program (the census's cases by default) as native lowering reads
  it, and what lowering emitted for each selected site:
  `results/plans/NAME.txt` and `results/plans/summary.md`.
* `tools/measure.tcl ?-sizes {...}? ?-runs R? ?-time-size N? ?-memory 0|1?`
  -- the census's workloads at N = 1 .. 10000 with scratch storage off
  (`-scratch-opt 0`) and on: heap allocations and bytes, collections and
  their time, scratch placements, regions, reservations, growths, peak
  reserved and in use, fallbacks, stale roots and protocol errors, the
  marginal rates, times through the driver's `bench` and the peak resident
  set of a standalone executable: `results/measurements.md`.
* `tools/costs.tcl ?-n N? ?-runs R?` -- a cost probe: one function placing
  K = 0 .. 8 Strings per call (the frame's own cost at K = 0, the saving per
  placed String above it), and p04 at N = 10^4 .. 10^6:
  `results/costs.md`.
* `tools/compile-cost.tcl ?-runs R? ?FILE.bot ...?` -- native lowering with
  scratch storage off and on (the analysis, the plan and the frames'
  post-processing): `results/compile-cost.md`.
* `tools/memcheck.tcl ?CASE ...?` -- standalone executables of the positive
  workloads under valgrind's memcheck, plain and under GC stress:
  `results/memcheck.txt`.
* `tools/fuzz.tcl ?-seeds A-B? ?-count N? ?-modes {plain stress growth off}?
  ?-compile 0|1? ?-keep DIR?` -- generated programs (helpers that build,
  return, retain, fail with, recurse over and box Strings; loops, handlers,
  closures, calls through function values) run on the reference
  interpreter (the oracle), on the Tcl compiler and natively: scratch
  storage on, under GC stress with released storage poisoned, with tiny
  chunks (growth and fallback) and with scratch storage off; every outcome
  must equal the interpreter's, with no stale root and no protocol error.
  It also says why selected sites were not emitted.
* `tools/mutate.tcl ?-only NAME,...? ?-timeout S?` -- the mutants of
  `tools/mutants.txt`, each a broken rule of the plan, the lowering, the
  provider, the collector, the code generator, the NIR protocol or the
  lifetime facts, applied to a private copy of the tree; each must be
  killed by a detector its `!!` line names.

## Results

* `results/plans/` -- the census's plans (`tools/plan.tcl`).
* `results/measurements.md` -- the measurements (`tools/measure.tcl`).
* `results/costs.md`, `results/compile-cost.md`, `results/memcheck.txt`,
  `results/fuzz.txt`, `results/mutants.txt` -- the runs the report cites.
