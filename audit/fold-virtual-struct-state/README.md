# audit/fold-virtual-struct-state

The material of FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md (docs/): how a fold's
struct intermediate was represented before FOLD-VIRTUAL-STRUCT-STATE-
MILESTONE-1.md, what carrying it as field registers would save, and what a
design must prove -- and the milestone's own tests, fuzzer, mutants and
measurements (below). Nothing here is loaded by the compiler.

* `workloads/` -- the census's probe programs, each with its `# expect:`
  value (checked against the reference interpreter):
  - Probe A, scalar state: `a-scan2-*`, `a-scan4-*` (the scanner of
    `audit/fold-loops/workloads/scanner-*.bot` carrying 2 and 4 fields; the
    6-field originals are measured where they are);
  - Probe B, List fields: `b-wrap-fold` (one List field), `b-counted-*` (a
    List and a count), beside `audit/fold-loops/workloads/chunks-*.bot` and
    `audit/fold-virtual-construction/workloads/list-*.bot`;
  - Probe C, mutable fields: `c-vec-literal`, `c-vec-self`, `c-two-vecs`,
    `c-mixed`, `c-vec-continue`;
  - Probe D, control flow and observation: `d-exits`, `d-observe`,
    `d-errors`, `d-nested`, `d-shapes`, `d-coroutine`,
    `d-identity-materialize`;
  - Probe E, existing positions: `e-positions` (a struct as a local, an `if`
    join, a return, an argument, a self tail call's parameter, and a fold's
    back edge).
* `economics/` -- synthetic inputs (`tools/gen-economics.tcl` writes
  them): compile cost `width-W`, `nested-D`, `many-K`, `locals-K`; run
  time `spill-W` (a W-field fold whose fields are live across a call).
* `tools/`:
  - `nir-sra.tcl` -- the NIR experiment: a NIR-to-NIR rewrite carrying every
    struct register web (registers joined by `move`, defined only by
    `structnew` of one shape) as field registers, optionally one List field
    as a construction plan (`-plan-field`) and a function's result as
    `retmulti` fields (`-return-fields`). The driver validates and runs its
    output like any NIR;
  - `probes.tcl` -- every probe's value on the four backends against the
    interpreter and its expect line, its struct census, its native Struct
    allocations, and the experiment's value (also under GC stress) and
    allocations;
  - `measure.tcl` (with `callgrind-diff.py`) -- allocations, copies,
    construction and MutableVector counters, NIR counts, code size, lowering
    time and callgrind's instructions per run, of the compiler's NIR or the
    experiment's;
  - `economics.tcl` -- analysis and lowering time, the escape analysis' use
    verdicts and classifications, NIR and code size, roots, before and after
    the experiment's rewrite;
  - `nir.tcl` -- writes a program's NIR text, the experiment's input;
  - `backend-time.tcl` -- Cranelift's compile time of a program's NIR and of
    the experiment's;
  - `run-all.sh` -- regenerates `results/`.
* `results/` -- the census's evidence: `probes.txt`, `probe-a.txt`,
  `probe-a-width.txt`, `probe-b.txt`, `probe-c.txt`, `economics.txt`,
  `backend-time.txt`.

FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md (the implementation: fold slots in
hir/escape.tcl, native lowering's `vfold` mode) adds:

* `width/` -- the milestone's width inputs (`tools/gen-width.tcl` writes
  them): `few-W`, `most-W`, `branch-W`, `ret-W`, `nested-W` at 2-64 fields,
  `most-W` and `spill-W` up to 256;
* `tools/`:
  - `fuzz.tcl` -- the differential fuzzer: random folds over a struct
    intermediate (scalar, history and vector templates), values on eight
    configurations, the fold slot's decision against the fuzzer's own model,
    and no program building more structs with fold slots than without;
  - `mutate.tcl` and `mutants.txt` -- the mutation catalog of the
    milestone's rules, each mutant killed by the tests its `!!` line names;
  - `golden-port.tcl` -- writes tests/golden/fold-virtual-struct-state.bot,
    its manifest fragment and census from the Tcl tests' own programs;
  - `corpus.tcl` and `corpus-compare.py` -- a corpus's NIR digests, struct
    census classes, fold slots and Struct allocations under several lowering
    configurations, compared with another checkout's (`-root DIR`);
  - `gen-width.tcl` -- writes `width/`.
* `results/` -- the milestone's evidence: `m1-*.txt` (the report's section
  17 regenerates them).

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
bash audit/fold-virtual-struct-state/tools/run-all.sh            # about an hour
tclsh9.0 audit/fold-virtual-struct-state/tools/gen-economics.tcl
tclsh9.0 audit/fold-virtual-struct-state/tools/economics.tcl -runs 5 \
    audit/fold-virtual-struct-state/economics/{width,nested,many,locals}-*.bot \
    audit/fold-loops/workloads/scanner-fold.bot audit/fold-loops/workloads/chunks-fold.bot \
    tests/golden/fold-loops.bot > audit/fold-virtual-struct-state/results/economics.txt
```
