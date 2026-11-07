# audit/mid-end-port

**The mid-end in Botlish: what it would save, and whether Botlish is ready
for it.** Measurements and analysis; nothing is implemented.

Measured on 2026-11-07 at `f2787af`, on a shared 4-core, 16 GB Linux x86-64
container (Tcl 9.0.1, rustc 1.97, the native backend built `--release`).
Unless a table says "best of N", a figure is one run; times on this machine
move by about 10 % from run to run, and some runs shared it with another
measurement (noted where it matters).

The question, asked repeatedly and answered "no" each time so far: would
rebuilding a part of the compiler in Botlish pay? This time the part is the
**mid-end** -- everything from resolution to the checked HIR,
`hir::buildSyntax` (the method-call decision's builds and trait
monomorphization included) -- and the workload is the one that prompted it,
`tests/warning-gate.test`, the slowest test file in CI. The earlier
assessment of porting native lowering is NATIVE-BOTLISH-LOWERING-IMPL.md;
the mutual-recursion design it depends on is MUTUAL-RECURSION.md.

## Summary

* **A complete port of the mid-end would make this workload about 2-3 times
  faster, and never more than 4.2 times** while parsing, loading and the
  bookkeeping around each compilation stay in Tcl: they are 24 % of the time
  (section 1).
* **A partial port would save little.** The mid-end's profile is flat: its
  largest single analysis is 16 % of a compilation (section 3).
* **Native Botlish is 3.7 times faster than the same algorithm in Tcl when
  each call returns a small struct, and 8.8 times faster when nothing is
  allocated** (section 2). In the struct version 80 % of the instructions
  are allocation and collection (62 % in glibc's `malloc` and `free` alone),
  13 % the generated code: every heap object is its own `malloc`, and every
  collection walks every live object. The allocator, not the language,
  decides whether a port pays.
* **Botlish is not ready for the port, mutual recursion or not** (section 4):
  payload-carrying unions with `match` are missing, and so are sort, String
  split/join/builders, format strings and struct update. Integration needs
  a specified interchange schema and a second implementation of rules the
  front end and the runtimes now share.
* **At a port's size the front end copes and the specialized native build
  does not** (section 5). A generated 51,334-line program shaped like a
  mid-end in Botlish compiles in 10.4 minutes and 5.9 GiB: linear up to
  about 13,000 lines (7.2 ms per line), then about the 1.4th power of the
  size, in one procedure (type inference, `hir::signatures::infer`). Its
  specialized native build is quadratic in
  memory -- lowering keeps a copy of the program's expression table per
  specialized instance -- and was killed for lack of memory at 12,939 lines
  on this 16 GB machine; the unspecialized build lowers and links 25,736
  lines in 2.4 minutes, after a 3.8-minute front end, superlinear in one
  procedure that scans every binding per function. And the
  semantic-instance budget is a cliff: an untyped
  helper called with a 17th distinct type makes that call `any`, which a
  typed parameter rejects, so a valid program stops compiling as it grows.
* **For this workload, fixing the test's structure is far cheaper than any
  port** (section 1): the gate compiles every clean unit twice with the same
  result, the test runs the whole gate six times, and CI runs the test four
  times per push. Those fixes alone would take the test from about 17 to
  about 2 minutes.

## Files

| file | what it is |
|---|---|
| `tools/workload.tcl` | the warning gate's compilations as a workload: per-unit times (`units`), the phase split (`phases`), a per-analysis profile of one program (`analyses`), the cost of HIR interchange (`interchange`) |
| `kernel/ranges.tcl`, `kernel/ranges-structs.bot`, `kernel/ranges-tables.bot` | the mid-end-shaped kernel: one algorithm, three Tcl versions and two Botlish versions |
| `tools/kernel.tcl` | builds and times the five versions (best of N) and checks that they compute the same value |
| `tools/kernel-callgrind.tcl` | where the native struct version's instructions go, under callgrind |
| `tools/synth.tcl` | generates a synthetic Botlish program shaped like a mid-end, of any size |
| `tools/measure.tcl` | measures one compilation: front-end phases, builds, memory, semantic and specializer instances against their budgets, native lowering and its analyses, Cranelift and the link, a run |
| `tools/scale.tcl` | the ladder: generates growing programs and measures each in a process of its own, under a time and memory cap |
| `tools/table.tcl` | prints the ladder's results as this report's tables |
| `tools/budget.tcl` | the semantic-instance budget reduced to one untyped helper and N struct types |
| `tools/native-profile.tcl` | where lowering to NIR spends its time, procedure by procedure |
| `tools/timing.tcl` | inclusive and exclusive time of named procedures, by wrapping them (section 6 says why not by execution traces) |
| `results/` | the recorded outputs of the runs this report cites |

## 1. The workload

`audit/refactor/tools/gate.tcl` compiles 128 *units* -- the 87 corpus
programs (`examples/`, `bench/`, `stdlib/` standalone) and a one-line loader
`import NS` for each of the 41 library modules -- with warnings collected,
then compiles the 90 units that expect no warning again under `-warnings
error`. `tests/warning-gate.test` runs the gate six times: once on the tree,
then once per ratchet case on a scratch copy of the whole corpus with one
file edited.

**Its cost** (`results/gate-units.txt`):

* One gate run: 102 s for the first pass, 72 s for the strict pass.
* The test: about 17 minutes here. `tests/canary.tsv` records 891 s in CI,
  the slowest test file of the suite; `event-loop.test` is next, at 742 s.
* CI runs the file four times per push to main, and the gate never reaches
  a backend: `tests/all.tcl` under interp and compile (tests.yml's matrix),
  and again under cranelift and cranelift-generic (`tests/native-coverage.tcl`);
  tests-arm64.yml repeats both. The canary job runs the gate once more.
* The cost is concentrated. Three loaders cost 6-10 s per compilation
  (`std::actor`, `std::event_loop::deterministic`, `std::event_loop`); 93 of
  the 128 units cost 12 s together.

**Redundancy that has nothing to do with the compiler's speed:**

* **The strict pass cannot fail where the first pass passed.** The build
  does not depend on the warning policy: `surface::modules::BuildProgram`
  takes no mode, and `surface::lower::Finish` applies `hir::warnings::run`
  after it. Under `error` that collects the same warnings and raises the
  first (`hir::warnings::Rejection`). A strict unit is one that expects no
  warning, which the first pass has already compared with what it observed.
  The strict compilation can therefore fail only where the first pass has
  already reported "unexpected warning" (`warning-gate-ratchet-strict-mode`
  pins both messages). It is 41 % of a gate run.
* **Each ratchet case runs the whole gate to check one edit** of one or two
  files.
* **The four suite runs compute the same thing.** Running the file on one
  backend only would be a change of CI policy (AGENTS.md: CI runs every test
  on every backend). Skipping `warning-gate-passes` because the canary ran
  the gate is not allowed (AGENTS.md: the canary never skips).

Deriving the strict verdict from the first pass and letting the ratchet
cases gate only the units they touch would take the test from about 17 to
about 2 minutes, before any change to the compiler.

**Where a compilation's time goes** (`results/gate-phases.txt`: the first
pass, every unit, inclusive seconds, the outermost activation of each
procedure):

| phase | seconds | share |
|---|---:|---:|
| all 128 units | 97.4 | 100 % |
| `surface::modules::CollectAndLoad` (reading and parsing every file) | 10.8 | 11.1 % |
| of which `surface::modules::Parse` | 8.7 | 9.0 % |
| **`hir::buildSyntax` (the mid-end)** | **74.3** | **76.4 %** |
| of which `hir::check` | 55.6 | 57.1 % |
| of which `hir::DecideMethodCalls` (its builds included) | 19.8 | 20.3 % |
| of which `hir::traits::monomorphize` (its build included) | 18.0 | 18.5 % |
| `surface::lower::Finish` (warnings, recovery) | 2.9 | 2.9 % |
| the rest (lowering the AST, reading the file, the sweep's bookkeeping) | 9.4 | 9.6 % |

The nested rows overlap: the method-call decision and the monomorphization
each contain a whole-program build, whose checks are also `hir::check`'s.

**The ceiling:** with an infinitely fast mid-end, 23.6 % of the time
remains, a speed-up of at most 4.2 times.

**The boundary is cheap** (`results/interchange.txt`). Encoding a loader's
whole HIR as interchange text (`hir::interchange::encode`) and decoding it
again costs 2.7-2.9 % of its build: 0.14 s for `std::event_loop`'s 5,165
expressions (2.0 MB of text), against its 5.3 s build. That is the cost of
handing the HIR across a process or language boundary, in Tcl, in one
direction and back.

## 2. The kernel

No existing benchmark compares hand-written Tcl with native Botlish; the
repository's comparisons are Botlish on the Tcl backends against Botlish
native (HASH-TABLE-EXPERIMENT.md: about 1,500 times for table operations),
which says nothing about a Tcl compiler. So `kernel/` holds one mid-end-
shaped algorithm in five versions.

**The algorithm.** An interval analysis of a synthetic program: 1,500
expression trees ("functions") of constants, the parameter, additions, ifs
and calls of other functions, generated from a seeded LCG at most 8 deep
(455,468 nodes). Whole-program rounds evaluate every function under the
other functions' summaries until no summary changes (widening after round
6; 6 rounds), and stamp every node's range into side tables. Every version
computes the same value: the node count, the rounds and a checksum of every
node's range.

**The versions:**

* `ranges.tcl dict` -- written the way `hir/` is: a dict of node dicts keyed
  by `eN` (the HIR's `exprs`), the summaries in it, the ranges in a
  side-table dict reached through `upvar`, each evaluation returning a
  `{lo hi}` pair.
* `ranges.tcl list` -- tuned Tcl: flat lists indexed by Int, `lset` in place,
  each evaluation returning a pair.
* `ranges.tcl tables` -- flat lists, each evaluation returning the node's
  index, its range only in the side tables.
* `ranges-structs.bot` -- native Botlish: an enum of kinds, a `Node` struct
  in a MutableVector, MutableArray side tables through `place` parameters,
  each evaluation returning a `Range` struct.
* `ranges-tables.bot` -- the same, each evaluation returning the node's
  index, its range only in the side tables.

**Results** (`results/kernel.txt`, best of 5; a native time is the whole
executable's, whose process start is about 2 ms):

| version | seconds | `tcl dict` / this | this / `native tables` |
|---|---:|---:|---:|
| `tcl dict` | 5.119 | 1.0 | 17.5 |
| `tcl list` | 2.811 | 1.8 | 9.6 |
| `tcl tables` | 2.587 | 2.0 | 8.8 |
| `native structs` | 0.762 | 6.7 | 2.6 |
| `native tables` | 0.293 | 17.5 | 1.0 |

* **Like for like, native Botlish is 3.7 times faster when each call
  returns a small value, and 8.8 times faster when nothing is allocated**
  (`tcl list` against `native structs`, `tcl tables` against `native
  tables`). An earlier run of the same programs measured 3.7 and 9.3.
* **Data design alone, dense Int ids instead of `eN`-keyed dicts, gives
  1.8-2.0 times inside Tcl.**
* **Allocation decides the native figure.** Under callgrind
  (`results/kernel-callgrind.txt`: `ranges-structs` built for 300 functions,
  depth 7; exclusive instruction counts summed by category), glibc's
  `malloc` and `free` are 62.1 % of the instructions and the runtime's own
  allocation and collection code (`Vm::new_struct`, `Heap::collect`,
  `free_object`, ...) another 18.0 %; the generated code is 12.8 %. Each
  `Range` a recursive call returns is a heap object: 358,209 `new_struct`
  calls for 44,777 nodes over 7 rounds.
  `native/src/runtime/heap.rs` describes itself as a "temporary
  memory-management strategy for the first native backend": every object an
  individual allocation, a non-moving mark-and-sweep collector without a
  nursery, a collection whenever the bytes allocated exceed twice the live
  bytes. Each collection marks every live object -- here the 455,468 nodes;
  in a mid-end, the whole HIR.

A mid-end allocates small values all the time: type forms, ranges, sets of
facts, diagnostics. So the realistic figure today is about 4 times; about 9
times needs small struct results that do not go through the heap (returned
in registers, or a bump or nursery allocator). That change would speed up
every Botlish program, ported compiler or not.

The kernel is one proxy. A real mid-end differs both ways: it does more
hashing of strings, where a native MutableMap (50-300 ns per operation,
ORDERED-MUTABLE-MAP-SET.md) is not much faster than Tcl's C-implemented
dict, and more interpretive overhead per Tcl command than this kernel's
short procedures have.

## 3. What a port would save

**On the gate**, with the mid-end at 76.4 % and the rest unchanged:

| mid-end speed-up | gate run (174 s today) | `warning-gate.test` (about 17 min) |
|---|---:|---:|
| 3.7 times (native Botlish today) | about 77 s | about 7.5 min |
| 8.8 times (allocation-free) | about 56 s | about 5.5 min |
| unbounded (the ceiling) | about 41 s | about 4 min |

The test-structure fixes of section 1 bring the test to about 2 minutes on
their own, and combine with any port.

**Why only a complete port pays.** The profile is flat
(`results/event-loop-analyses.txt`: `import std::event_loop`, every `hir::`
procedure a build calls directly, exclusive seconds):

| procedure | share of the compilation |
|---|---:|
| `hir::errorsets::verify` | 15.7 % |
| `hir::signatures::infer` (type inference included) | 12.9 % |
| `surface::modules::Parse` (front end) | 12.4 % |
| `hir::affine::verify` | 9.7 % |
| `hir::resolve::program` | 7.6 % |
| `hir::range::verifyDeclaredParams` | 5.3 % |
| `hir::mutvec::Elaborate` | 4.7 % |
| 35 more, none above 3.5 % | the rest |

On the synthetic programs of section 5, type inference grows faster than
the rest: `hir::signatures::infer` is 20 % of a compilation at 1,867 lines,
25 % at 7,023 and 41 % at 25,736 (`results/synth-analyses.txt`,
`results/synth-analyses-growth.txt`). That is a superlinear algorithm to fix
where it is, in Tcl; porting it would buy a constant factor of a growing
term. At the gate's sizes nothing dominates. Porting one analysis saves at
most its share and adds a boundary crossing per build (three builds per
compilation here: the method-call decision's and the monomorphization's).
The only cut that captures the 76 % is all of `hir::buildSyntax`: most of
`hir/`, 85,746 lines (60,363 of code) in 79 files.

## 4. Readiness

Against the prerequisites NATIVE-BOTLISH-LOWERING-IMPL.md (section 6.1 and
8) listed, at `f2787af`:

**Landed since:**

* Int to text and back (`std::int::to_string`, `std::int::from_string`;
  NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md).
* Typed, insertion-ordered maps and sets (`std::mutable_map`,
  `std::mutable_set`, `std::immutable_map`; ORDERED-MUTABLE-MAP-SET.md).
* Parameterized structs with imprinted arguments and constrained slots
  (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md).
* Folding loops, the bare form included (FOLD-LOOPS-MILESTONE-1.md): the
  accumulator the earlier assessment called `reduce:`.
* Native-frame GC roots instead of the shadow stack.

**Designed, one milestone away:** `mutual:` groups (MUTUAL-RECURSION.md).
Their restrictions -- module top level only, every member declares its
result type -- fit the shape of the Tcl procedures a port would follow:
`hir/types.tcl`'s inference walker and lattice (about 30 procedures in
cycles) and `hir/completions.tcl` (12).

**Still missing:**

1. **Payload-carrying unions and `match`.** Enums are payload-free and
   there is no `match` (docs/README.md section 11, ENUMS.md). The mid-end's
   central data are exactly such sums: type forms (`{nstruct ID ARGS}`,
   `{srefined FAMILY FACTS}`, `{imprint K TRAITS}`, `any`, `never`,
   poison), about 30 HIR node kinds, range bounds that can be infinite, and
   diagnostics. A kind enum plus a struct of every case's fields loses the
   payload checking the earlier assessment called essential. This is the
   largest gap.
2. **The allocator** (section 2): it decides between about 4 and about 9
   times.
3. **Library:** no sort, no String split, join or builder (`std::str` has
   `concat`, `substring`, `append_char` and the classifiers), no format
   strings (the mid-end has hundreds of diagnostic messages), no struct
   update. A List grown by appending in a fold still copies its prefix on
   every append (LIST-FLAT-MILESTONE-1.md); a MutableVector is the way to
   grow one.
4. **Scale** (section 5): a port-sized program compiles, but its
   specialized native build exhausts memory at about a quarter of that size
   (one copy of the expression table per specialized instance), and a
   shared untyped helper stops type-checking at its 17th distinct type.
   Bootstrapping a native Botlish mid-end today means an unspecialized
   (cranelift-generic) build, and a design of every polymorphic helper
   around the semantic-instance budget.
5. **Integration:**
   * The mid-end reads Tcl-side state throughout: 151 call sites into
     `core::native` (191 registered natives with 32 kinds of metadata) and
     324 into `core::value`, `core::type` and `core::cabi` (value equality,
     the exact simulation of binary64 operations, the C target table). A
     Botlish mid-end needs that metadata as data and a third implementation
     of rules AGENTS.md wants stated once per implementation.
   * The analyses native lowering calls (`hir/specialize.tcl`,
     `hir/range.tcl`, `hir/escape.tcl` and others, still Tcl) share the type
     lattice with the checker, so the lattice would be split or duplicated.
   * The HIR crosses the boundary as interchange text, which today is the
     Tcl dict itself: a front end (or mid-end) in Botlish needs the format
     version 2 HIR-INTERCHANGE.md asks for, a specified schema and a
     validating reader.
   * Native libraries are Linux glibc's only (NATIVE-LIBRARY-MILESTONE-1.md),
     so on macOS and Windows a Botlish mid-end would run as a subprocess.
6. **Friction:** every MutableArray or MutableVector access may raise the
   declared error `IndexNotFound`, so 5 of the kernel's 9 functions needed
   `errors IndexNotFound` (or a handler, or a proof of the index).

## 5. The scale experiment

**The question:** the largest hand-written Botlish file compiled today is
3,680 lines (`tests/golden/destructuring.bot`; `stdlib/event_loop.bot` is
1,851). A port of the mid-end would be 15-20 times that. What happens to the
front end's compile time and memory, to the semantic-instance budget and to
the specializer's limits at that size?

**The program** (`tools/synth.tcl`): an application of `ir.bot` (an enum of
24 node kinds, a `Node` struct, a builder that fills a MutableVector from a
seed), `lattice.bot` (a `Fact` struct; typed `join`, `meet`, `widen`,
`shift`; an untyped `choose`), M pass modules and `main.bot`. Each pass
imports `ir`, `lattice`, std's MutableVector, MutableArray and MutableMap
and up to three earlier passes, and holds:

* its own `Info` struct;
* 40 handlers in three tiers: tier 0 calls the lattice only, tier 1 calls
  tier 0 of its own pass and of earlier passes and calls `lattice::choose`
  with two of its pass's `Info` values, tier 2 calls tier 1 (so the static
  call depth stays about 7, as a pipeline's would); 25 % of the tier-1
  handlers leave their parameters untyped;
* a dispatch on the node kind (an `if` chain over the 24 kinds);
* a fold over the node table that stamps every node's `Fact` into a
  MutableArray side table through a `place` parameter;
* a census of the nodes through a `MutableMap[int, int]`.

`main.bot` builds 400 nodes, runs every pass and returns a checksum. Every
function declares its result type, as a `mutual:` group's members must
(only the untyped tier-1 handlers and `choose` leave parameters untyped).
The program has no tagged unions (Botlish has none: section 4) and no
mutual recursion; it collects about 0.4 warnings per line (METHOD-ELIGIBLE:
its calls are plain calls), and their collection is included in the times.
A 2-pass, 12-handler instance computes the same value on interp, cranelift
and cranelift-generic, and every size the native path built ran and
returned its value.

Two variants: with `-generic 1` (the default) every tier-1 handler calls the
untyped `lattice::choose` with its pass's own `Info` struct, so `choose`
needs one more semantic instance per pass, as a port's shared untyped
helpers would with every new type; `-generic 0` joins the facts directly,
and every untyped function is called with one set of types.

**Results** (`results/scale.txt` with the helper, `results/scale-frontend.txt`
and `results/scale-native.txt` without it, `results/scale-generic.txt`
unspecialized; `tools/table.tcl` prints these tables from them). Each size
ran in a process of its own. "Front end" is `surface::readProgramFile`:
three whole-program builds per compilation at every size (the method-call
decision's and the monomorphization's), with warnings collected.

The front end:

| passes | shared untyped helper | lines | functions | expressions | front end s | of which parsing and loading s | `hir::check` s | peak GiB | outcome |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
| 8 | yes | 3,584 | 356 | 22,778 | 25.0 | 3.7 | 16.0 | 0.56 | ok |
| 16 | yes | 7,023 | 700 | 42,626 | 52.1 | 6.8 | 35.1 | 1.02 | ok |
| 32 | yes | 13,899 | 1,388 | -- | 77.7 | 13.4 | 50.3 | 1.92 | **rejected** (TYPE) |
| 32 | no | 12,939 | 1,388 | 74,322 | 93.5 | 11.8 | 64.2 | 1.74 | ok |
| 64 | no | 25,736 | 2,764 | 145,714 | 233.0 | 24.0 | 172.1 | 3.03 | ok |
| 128 | no | 51,334 | 5,516 | 288,498 | 622.7 | 48.4 | 499.8 | 5.92 | ok |

The native path: lowering to NIR (`native::nir`, which runs the native-path
analyses itself), then the driver's Cranelift compilation and link.
"Specialized" is cranelift's lowering, "unspecialized" cranelift-generic's
(`-specialize 0`, every function lowered once). The 16-pass row without the
helper was measured with `tools/measure.tcl` directly, to read the resident
size after each step.

| passes | shared untyped helper | specialized | lines | lowering s | of which the specializer's analysis s | views s (calls) | block escape s | region analyses s (calls) | Cranelift and link s | peak GiB | outcome |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 8 | yes | yes | 3,584 | 17.6 | 10.9 | 3.7 (4,887) | 3.0 | 1.3 (405) | 0.46 | 1.45 | ok |
| 16 | yes | yes | 7,023 | 84.6 | 62.0 | 22.4 (9,231) | 17.6 | 4.8 (751) | 0.85 | 4.29 | ok |
| 16 | no | yes | 6,543 | 62.2 | 43.8 | 15.1 (8,972) | 12.7 | 4.1 (742) | 1.25 | 3.86 | ok |
| 32 | no | yes | 12,939 | -- | -- | -- | -- | -- | -- | over 11.75 | **killed** (out of memory) |
| 8 | no | no | 3,344 | 4.6 | 0.6 | 0.01 (4,169) | 0.1 | 1.1 (330) | 0.38 | 0.51 | ok |
| 16 | no | no | 6,543 | 11.3 | 1.3 | 0.03 (7,801) | 0.2 | 3.4 (610) | 0.57 | 0.93 | ok |
| 32 | no | no | 12,939 | 31.9 | 2.8 | 0.06 (15,104) | 0.4 | 12.5 (1,173) | 0.99 | 1.74 | ok |
| 64 | no | no | 25,736 | 145.5 | 8.6 | 0.13 (29,697) | 0.9 | 74.6 (2,298) | 1.93 | 3.03 | ok |

**What it shows:**

* **A program of a port's size compiles: 51,334 lines in 10.4 minutes and
  5.9 GiB.** Nothing in the front end gives up: no nesting limit, no
  recursion limit, no budget is reached without the shared helper.
* **The front end is linear up to about 13,000 lines (7.2 ms per line) and
  superlinear beyond:** from 12,939 to 25,736 lines its time grows 2.5
  times, from there to 51,334 lines 2.7 times, about the 1.4th power of the
  size. Parsing and loading stay linear (48 s at 51,334 lines); the growth
  is `hir::check`'s (64, 172, 500 s), the method-call decision's and the
  monomorphization's (their builds are checks too). Inside the check, one
  procedure is superlinear: `hir::signatures::infer`, which runs type
  inference (`hir::types::infer`, semantic instances included), took 10.3,
  26.9 and 95.4 s at 6,543, 12,939 and 25,736 lines -- 23, 28.5 and 41 % of
  the compilation -- while every other analysis stayed linear
  (`hir::errorsets::verify` 4.8, 9.3, 18.5 s; parsing 4.6, 9.2, 18.3 s;
  `results/synth-analyses-growth.txt`). Making that one linear, in Tcl,
  would make the front end linear.
* **Memory grows linearly, by about 120 KB per line** (0.56 GiB at 3,584
  lines, 3.0 GiB at 25,736, 5.9 GiB at 51,334). Each line is about six
  HIR expression nodes.
* **The semantic-instance budget is a cliff, not a slowdown.** With the
  shared helper, the 32-pass program is *rejected*:
  `pass_17.bot:103:23: argument for parameter "x" cannot be proven to
  satisfy lattice::Fact (argument type: any)`. Its 17th pass makes the 17th
  distinct call of `lattice::choose`; past the per-function budget of 16
  (`hir::semantic::maxPerBlock`) the request is declined and the call keeps
  `choose`'s generic typing (hir/semantic.tcl, "Budgets": sound, the
  pre-existing behavior), so its result is `any`, and the typed parameter
  of `lattice::join` refuses `any`. `tools/budget.tcl` reproduces it in
  about 120 lines (`results/budget.txt`): 16 struct types through one
  untyped helper are accepted, 17 are rejected at the 17th call. Which call
  is rejected depends on the order the requests are discovered in, so
  adding a use anywhere can reject a call elsewhere. Botlish has no
  declared generic functions (by design: NATIVE-BOTLISH-LOWERING-IMPL.md,
  section 6.3), so a port's polymorphic helpers rest on semantic instances;
  a mid-end-sized program must keep each of them below 16 distinct type
  combinations program-wide, or duplicate them per type.
* **The specialized native build of a 12,939-line program does not fit in
  16 GB.** The kernel's out-of-memory killer ended it (SIGKILL) 692 s in,
  under a 14 GiB address-space cap (`results/scale-native.txt`). Sampled
  every 5 s, its resident size stayed at 1.70 GiB through the specializer's
  analysis (about 550 s), then grew by about 1.5 GiB every 5 s, past 11.75
  GiB. The 16-pass run locates the growth: 0.91 GiB after the specializer's
  analysis, 0.91 GiB after the region summary, 3.86 GiB after lowering.
  Lowering memoizes one *view* per used instance
  (`hir::specialize::memoizeViews`), and "building a view costs
  O(program): its first `dict set` copies HIR's whole exprs table"
  (hir/specialize.tcl). Memory is instances times program size: quadratic.
  NATIVE-BOTLISH-LOWERING-IMPL.md (section 1) named the views' copying as
  still open; at a port's size it is the wall.
* **Specialized lowering's time grows with about the 2.3rd power of the
  size** (17.6 s at 3,584 lines, 84.6 s at 7,023), most of it the
  specializer's analysis, its views and block escape. The analysis alone
  took 44.7 s at 6,543 lines and, judging by the memory samples, about
  550 s at 12,939. Without the shared helper the 16-pass program has
  nearly as many specialized instances (599 against 607) and costs three
  quarters as much: the instance count follows the functions, not the
  helper.
* **Unspecialized lowering survives, but is superlinear too:** 4.6, 11.3,
  31.9 and 145.5 s from 3,344 to 25,736 lines, at the front end's memory.
  Its growth is the region analyses' (one per emitted function, 3.3 ms
  each at 8 passes and 32.5 ms at 64), and within them one procedure:
  `hir::aot::BlockName`, which finds a block's name by scanning every
  binding of the program, called for every emitted function
  (`results/native-profile-32.txt`: 7,863 calls, most of the time under
  the profiler). `hir::aot::context` already computes the same map
  (`names`). That is a cheap fix in Tcl, not an argument for a port.
* **Cranelift and the link are never the problem:** 1.9 s for 25,736 lines
  (2.5 MB of NIR).
* **The specializer's own limit is not reached by ordinary code:** with the
  helper, `lattice::choose` gets 8 specialized instances (the per-function
  limit, then its generic instance: slower code, no error); every other
  function 1 or 2.

## 6. Measuring Tcl code: execution traces distort it

The first version of these tools timed procedures with `trace add execution
P {enter leave}`. Tcl hands such a callback the command string, so every
traced call formats its arguments and its result as text -- here, the whole
HIR dict for most procedures, again whenever it changed. That made lowering
a 533-line program take 91 s instead of 1.4 s, inflated the front end's
peak memory from 155 MB to 221 MB, and moved the shares of procedures whose
arguments or results are large. `tools/timing.tcl` renames each procedure
and puts a wrapper in its place that calls it through `uplevel 1`; it
formats nothing. Every figure in this report is the wrapper's; the phase
split, measured both ways, came out at 76.4 % for the mid-end with wrappers
and 75.7 % with traces (in 114.5 s instead of 97.4 s).

## 7. Reproducing

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml   # for the kernel and the native path

tclsh9.0 audit/mid-end-port/tools/workload.tcl units > audit/mid-end-port/results/gate-units.txt
tclsh9.0 audit/mid-end-port/tools/workload.tcl phases > audit/mid-end-port/results/gate-phases.txt
tclsh9.0 audit/mid-end-port/tools/workload.tcl analyses std::event_loop > audit/mid-end-port/results/event-loop-analyses.txt
tclsh9.0 audit/mid-end-port/tools/workload.tcl interchange > audit/mid-end-port/results/interchange.txt

tclsh9.0 audit/mid-end-port/tools/kernel.tcl > audit/mid-end-port/results/kernel.txt
tclsh9.0 audit/mid-end-port/tools/kernel-callgrind.tcl > audit/mid-end-port/results/kernel-callgrind.txt

tclsh9.0 audit/mid-end-port/tools/budget.tcl > audit/mid-end-port/results/budget.txt
R=audit/mid-end-port/results
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale.txt -passes "8 16 32"
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-frontend.txt -passes "32 64 128" -generic 0 -native 0
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-native.txt -passes "32" -generic 0 -memory-mb 14336
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-generic.txt -passes "8 16 32 64" -generic 0 -specialize 0
tclsh9.0 audit/mid-end-port/tools/table.tcl $R/scale.txt $R/scale-frontend.txt $R/scale-native.txt $R/scale-generic.txt
```

A result file is appended to, a line per size: remove it first to measure
again. The whole ladder takes about an hour and a half on this machine; the
128-pass front end alone about ten minutes. The 16-pass specialized row of
`scale-native.txt` is `tools/measure.tcl DIR/main.bot -run 0` on
`synth.tcl -passes 16 -generic 0`, its dict given the synth options.

The profiles of generated programs (`results/synth-analyses.txt`: the
default options at 4 and 16 passes; `results/synth-analyses-growth.txt`:
`-generic 0` at 16, 32 and 64; `results/native-profile-32.txt`):

```sh
tclsh9.0 audit/mid-end-port/tools/synth.tcl -out /tmp/synth-g32 -passes 32 -generic 0
tclsh9.0 audit/mid-end-port/tools/workload.tcl analyses /tmp/synth-g32/main.bot
tclsh9.0 audit/mid-end-port/tools/native-profile.tcl /tmp/synth-g32/main.bot -specialize 0
tclsh9.0 main.tcl -warnings off -backend cranelift-generic /tmp/synth-g32/main.bot
```

`scale.tcl` caps each size at an hour (`-cap`, the coreutils `timeout`) and
12 GiB of address space (`-memory-mb`, `ulimit -v`): Linux only. The
callgrind figures need valgrind; `kernel-callgrind.tcl` builds the
300-function kernel itself.
