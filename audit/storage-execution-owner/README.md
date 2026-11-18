# Execution-owned storage: census material

The material of STORAGE-EXECUTION-OWNER-CENSUS-1.md (the census report,
`docs/`): how compiler-managed storage could belong to execution owners --
coroutine instances, actors, requests, thread entries, application
instances -- and survive suspension, with configurable capacity and
placement. A census: nothing here changes the compiler, the runtime or a
library. Every tool reads the existing analyses (`hir/lifetime.tcl`,
`hir/storageplan.tcl`, `hir/range.tcl`), the native allocation report or
the C backend's output.

## Probes

`probes/eNN-*.bot` are the corpus (brief section 21), ordinary Botlish
programs; `probes/e09_lease.bot` is an application module E09b imports.

| probe | question |
|---|---|
| e01-sequential-owner | can one owner (a coroutine) reuse storage across separate jobs? |
| e02-nested-calls | which caller values stay live while a callee (suspending or not) runs? |
| e03-independent-coroutines | what persistent storage must stay distinct between two suspended instances? |
| e04-resumption | which temporaries become reusable after a segment? |
| e05-actor-messages | what owns retained messages and actor state today? |
| e06-actor-context-state | storage ownership against injected capability ownership |
| e07-http-worker | what a persistent request worker could share across requests, and what survives a mid-request suspension |
| e08-concurrent-requests | how retained storage grows with K simultaneous requests (K constant) |
| e09-abandonment, e09b-abandonment-resource | when a suspended execution's storage may be reclaimed (released; abandoned with a resource) |
| e10-declared-failure | what storage and runtime allocation remain on failure paths |
| e11-bounded-string | can a sufficient byte bound be derived for a String? |
| e12-unbounded-string | what prevents a strict bound |
| e13-nested-owners, e13b-c-nested-owners | a child owner held by a suspending parent (native; the C subset) |
| e14-recursive-activation | storage that grows with recursion depth; a recursive yielding chain |
| e15-c-frames, e15b-c-returned-handle | explicit C coroutine frames; the C backend's ownership boundary |
| e16-static-instances, e16b-static-binding | independent instances without static state; a static binding |
| e17-async-output-retention, e17b-borrowed-send | output retained after its producer moves on; borrowing until completion (rejected) |
| e18-dynamic-concurrency | a run-time count of simultaneously suspended requests |

## Tools

All run from the checkout's root with `tclsh9.0` and `LANG=C.utf8
LC_ALL=C.utf8`, after `cargo build --release --manifest-path
native/Cargo.toml`. Each keeps its scratch files in a temporary directory.

* `tools/probe.tcl ?-out DIR? ?-native 0|1? ?-scope file|app? ?FILE.bot ...?`
  -- per program: its value on the interpreter and natively; per unit,
  whether it may suspend or is recursive and what each suspension point
  keeps; per producer, its kind, region, verdicts, the census's *owner
  class* (transient, segment, persistent, result, escapes, unknown: the
  tool's header) and the storage plan's decision; per `to_string`, the
  proven Range of its operand; the native allocation report with scratch
  storage on and off. `results/probes/` (the corpus) and, with `-native 0
  -scope app`, `results/applications/` (larger programs).
* `tools/capacity.tcl ?-out FILE? ?FILE.bot ...?` -- a model of
  compiler-derived String capacity: a byte bound per confined String from
  the Ranges and constant text, and each region's bump and overlay
  capacities beside the provider's measured peak: `results/capacity.md`.
* `tools/measure.tcl ?-sizes {N1 N2}? ?-valgrind 0|1? ?-out FILE?` -- per
  unit of work, the managed-heap allocations by kind, scratch placements,
  coroutine stacks and every system allocation (valgrind):
  `results/measurements.md`.
* `tools/stacks.tcl ?-ks {...}? ?-out FILE?` -- K simultaneously suspended
  native coroutines: heap allocations, stacks mapped, minor page faults
  and the peak resident set: `results/stacks.md`.
* `tools/cframes.tcl ?-targets {...}? ?-out FILE?` -- the C subset's
  probes and the kiosk through `main.tcl -emit-c`: coroutine storage sizes
  per target (`examples/c-freestanding/frame-sizes.sh`), writable
  file-scope objects, and gcc's static stack usage: `results/cframes.md`.
* `python3 -I models/composition.py selftest|check [SEEDS] [OWNERS]` -- a
  model (no Botlish code) of how persistent and segment storage compose
  across owners on one thread, checked against every sampled interleaving:
  `results/composition.txt`.

## Results

* `results/probes/` -- one file per probe and `summary.md`.
* `results/applications/` -- the same classification (facts only) over
  `tests/actor/actors.bot`, `tests/actor/lifecycle.bot`,
  `examples/event-loop/03-child.bot`, `examples/dfa/csv/export.bot`,
  `examples/games/2048/demo.bot` and the census's p12.
* `results/capacity.md`, `results/measurements.md`, `results/stacks.md`,
  `results/cframes.md`, `results/composition.txt`.

Deterministic outputs: `probes/`, `applications/`, `capacity.md`,
`cframes.md` and `composition.txt` are the same on every run of one tree
on one host (C sizes are the host compiler's and the cross targets'
clang's). `measurements.md` is deterministic but for valgrind's version;
`stacks.md`'s page faults and resident set are measurements of this
machine.
