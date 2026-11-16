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
* `tools/fuzz.tcl ?-seeds A-B? ?-count N? ?-modes {plain stress growth}?
  ?-keep 0|1?` -- generated programs (helpers that build, return, retain,
  fail with, recurse over and box Strings; loops, handlers, closures,
  calls through function values) run on the reference interpreter and
  natively with scratch storage on, plain, under GC stress with released
  storage poisoned, and with tiny chunks (growth and fallback); every
  outcome must equal the interpreter's and the native run without scratch
  storage, with no stale root and no protocol error.
* `tools/mutate.tcl ?-only NAME,...? ?-timeout S?` -- the mutants of
  `tools/mutants.txt`, each a broken rule of the plan, the lowering, the
  provider, the collector, the code generator, the NIR protocol or the
  lifetime facts, applied to a private copy of the tree; each must be
  killed by a detector its `!!` line names.

## Results

* `results/plans/` -- the census's plans (`tools/plan.tcl`).
* `results/measurements.md` -- the measurements (`tools/measure.tcl`).
* `results/fuzz.txt`, `results/mutants.txt` -- the runs the report cites.
