# PORTABILITY-MID-END-PORT-READINESS-CENSUS-1

**Reassessing a Botlish-native compiler mid-end after the portability
milestones.** A census and feasibility assessment, not an implementation
milestone: nothing in the compiler, the language, the standard library, the
runtimes or the backends changed. The evidence is under
`audit/mid-end-port/readiness/` (its README.md reproduces every figure);
the November audit, `audit/mid-end-port/README.md`, stays as it was
written.

Throughout, a statement is marked by how it is known:

* **(inspection)** read from current source;
* **(observed)** measured by a run on the current checkout;
* **(historical)** recorded by the November audit or a later milestone;
* **(projection)** an estimate or an architectural inference, not measured.

## 1. Executive verdict

**Conclusion B: ready for a clean-room prototype, not for production
integration, and not for a staged complete port.**

The question this census answers is not whether Botlish can implement an
interval analysis -- it could in November -- but whether a substantial,
statically checked, modular mid-end can now be written and maintained in
Botlish, integrated without two semantic authorities, compiled at a port's
scale, and verified against the Tcl implementation, with enough benefit to
justify the migration. On current evidence:

* **The language now expresses compiler data.** A compiler-shaped checker
  (payload-enum IR, recursive type forms, a scoped environment with exact
  rollback, a worklist fixpoint over the call graph, sorted diagnostics)
  computes exactly what its Tcl reference computes on all four backends,
  and natively runs 3.9-4.7 times faster than tuned Tcl (section 8,
  observed). Payload-bearing enums and exhaustive `match` close the
  November audit's largest gap.
* **The compiler now copes with a port-sized program's front end.** A
  generated 55,174-line mid-end-shaped program with a shared untyped helper
  -- rejected at 13,899 lines in November -- compiles in 409 s and 5.1 GiB,
  linear to about 28,000 lines (6.5 ms per line; section 9, observed). The
  semantic-instance cliff is gone (section 10, observed).
* **The complete mid-end's call structure cannot be written yet.** `mutual:`
  is designed and not implemented (inspection). The front end runs 212
  procedures in mutually recursive cycles; the largest cycle holds 82
  procedures across 12 files, and Botlish modules may not import each other
  cyclically (section 5, observed and inspection). The two workarounds
  either allocate a request object per call (23 % slower than the
  alternative in the probe) or are excluded by contexts
  (CONTEXT-FUNCTION-VALUE), which is how a mid-end would receive its
  registries (section 5, observed).
* **The specialized native build of a port-sized program still does not
  fit in memory** (`hir::specialize::memoizeViews` is unchanged, section
  11); an unspecialized build does, and its code is still about three times
  faster than tuned Tcl (sections 11-12, observed).
* **Integration is the unsolved part.** HIR interchange is still format 1, a
  trusted same-front-end dict (inspection); a checked HIR carries 38
  top-level tables, 17 node kinds and 12 declaration registries (observed);
  the mid-end calls 14 `core::` namespaces 27.9 million times over 20
  front-end compilations and five native lowerings, many of them rules the
  runtimes also state (section 14, observed). A port would be a third implementation of those rules
  unless they are first made data or Botlish libraries.
* **The performance case is unchanged and modest.** The mid-end is 76.9 %
  of the warning gate's compilations (76.4 % in November): a complete,
  infinitely fast port would be at most 4.3 times faster on that workload
  (3.6 with a boundary crossing), a realistic one 1.8-2.2 times with
  today's allocator and 2.8 times allocation-free (section 18, observed and
  projection). The
  warning gate's structural redundancy, which the November audit measured
  as a 17-to-2-minute fix, is still there (section 18, inspection); it
  remains the cheapest large saving on that workload by far.

**The single most important next action** is to implement the designed
`mutual:` groups and, in the same milestone, decide whether a group may
span modules (PORTABILITY-MUTUAL-GROUPS-MILESTONE-1, section 20): it is the
one remaining *language* blocker for any mid-end-sized program, it is also
the blocker for recursive-descent parsers and state machines
(SIMCITY-WORKLOAD-KNOWN-GAPS.md, 3.5), and nothing else in the roadmap
removes it. The clean-room prototype
(PORTABILITY-MID-END-CLEANROOM-ANALYSIS-1) can start in parallel on an
analysis outside the large cycles.

**What would change the recommendation** (section 19): evidence that a
mid-end's cycles fit one module per cycle (then `mutual:` as designed
suffices); a boundary whose decode cost in Botlish is measured below a few
percent of a build; a specialized build linear in memory; or a decision
that the Tcl mid-end should stay the authority indefinitely, in which case
the roadmap reduces to its Tcl-side items.

## 2. Current compiler and environment baseline

**Revision.** `db473ee` (`origin/main`, 2026-11-17 18:36 UTC); this census's
branch started there. The checkout is a shallow clone (50 commits): the
November audit's revisions (`f2787af`, `eff6aea`, `53a0d1b`) are not
present, so identical programs could not be compiled by the historical
compiler on this machine; historical comparisons use the recorded results,
and say so (section 21, "Limits").

**Toolchains.** Tcl 9.0.1 (Ubuntu 25.04's `.deb`s, installed as AGENTS.md
prescribes); Rust 1.100.0 (`rust-toolchain.toml`), the native backend built
`cargo build --release` with default features (JIT on); Python 3.13.18;
clang 18.1.3; gcc 13.3.0; valgrind 3.22.0.

**Host.** A shared container: 4 vCPUs (Intel Xeon @ 2.1 GHz), 15.7 GiB of
memory, no swap, Linux 6.18 x86-64. The November audit ran on the same kind
of container (4 cores, 16 GB). Times move by about 10 % between runs; most
long measurements here shared the machine with one or two other
single-threaded measurements, noted where it matters.

**CI** (observed through the GitHub API at the start of the work). The
latest runs on main: every completed workflow green (release gate, prune,
single executable, the two Icy Tower builds and macOS's, macOS tests,
c-bindgen, bench, scalar-asm-audit, static-decisions); `tests`,
`tests (linux arm64)` and `tests (windows x86-64)` at `07dcb10` still in
progress. `db473ee` is scalar-asm-audit's write-back, which no test
workflow runs. This census changes nothing the compiler, the runtimes or
the tests read: it adds audit tools and probes under
`audit/mid-end-port/readiness/` and documents, so its branch push runs only
each test workflow's canary.

**The original tools** (observed). `kernel.tcl`, `kernel-callgrind.tcl`,
`synth.tcl`, `measure.tcl`, `scale.tcl`, `budget.tcl` and `workload.tcl` run
unmodified. `budget.tcl`'s header still prints "maxPerBlock 16", a variable
that no longer exists (setting it changes nothing; the tool says so).
`instance-walks.tcl`, `infer-profile.tcl` and `blockname-share.tcl` take a
checkout root, for before/after worktrees the shallow clone cannot make;
given this checkout as the root they run (`infer-profile.tcl` is used so in
section 10), and `frontend-phases.tcl` (new) measures the phases they
measured, and more, in one run.

**What the census added** (`audit/mid-end-port/readiness/`): fourteen
tools (a size grid of the kernel with memory and allocation figures, the
kernel specialized and unspecialized, the front-end and the native-lowering
phase splits, the reproducers of the inherited context and of lowering's
placeholder numbering, the call graph and its SCCs, the registries, the
HIR's surface, the three probes' runners, a ladder printer, a child-RSS
helper), audit-only probes (a compiler-shaped checker and its Tcl
reference, a mutual-recursion probe and two rejected forms, a
standard-library probe, three index-proof reproducers, a context
reproducer) and three matrices (the findings, the `core::` dependencies,
the authority map).

## 3. The November conclusions: resolved, unresolved, superseded

| November finding (audit README section) | Status now | Evidence |
|---|---|---|
| No payload-carrying unions or `match`: "the largest gap" (4) | **Resolved** for data modeling; two cost and ergonomics limits remain (section 4) | checker.bot, mutual.bot; PORTABILITY-PAYLOAD-ENUMS/EXHAUSTIVE-MATCH |
| `mutual:` designed, one milestone away (4) | **Still blocking**; and the design's module-local restriction meets an 82-procedure, 12-file cycle (section 5) | concept.mutual-recursion; callgraph |
| No sort, split/join/builder, format strings, struct update (4) | **Partially resolved**: linear String and List building by construction plans; sort, String ordering, split, search, format and struct update still absent (section 6) | stdlib.bot, stdlib.txt |
| Every MutableArray/MutableVector access may raise IndexNotFound (4) | **Partially resolved**: guarded and counted accesses are proven; a worklist access followed by a push is not (section 6) | stdlib-index*.bot |
| Allocation decides the native factor: 3.7x vs 8.8x (2) | **Still true**, unchanged: 62.1 % of the struct kernel's instructions in glibc `malloc`/`free` (section 7) | kernel-callgrind.txt |
| Front end linear to 13,000 lines, then the 1.4th power (5) | **Largely resolved**: linear to about 28,000 lines; 2.19x per doubling at 55,000 (section 9) | scale-frontend-*.txt |
| Semantic-instance budget is a cliff at 17 types (5, 8.1) | **Resolved**: 1,024 types compile; the total guard fails as HIR SEMANTIC LIMIT (section 10) | budget.txt; SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1 |
| Instance walks quadratic: each copies the program (8.2) | **Resolved**: 222 walks in 0.23 s at 7,023 lines (section 10) | frontend-phases.txt |
| Specialized native build quadratic in memory (5) | **Still blocking** at a port's size: `memoizeViews` unchanged; 16-pass build 3.88 GiB, as in November (section 11) | scale-native-specialized*.txt |
| Unspecialized lowering superlinear in `hir::aot::BlockName` (5, 8.2) | **Resolved** in November's follow-up (`5696909`); lowering is superlinear again at 25,736 lines, elsewhere in native lowering itself (section 12) | scale-native-generic.txt; native-phases.txt |
| HIR interchange needs a version 2 schema and a validating reader (4) | **Unchanged**: still format 1, trusted same-front-end (section 13) | HIR-INTERCHANGE.md; hir/interchange.tcl |
| Mid-end reads Tcl-side rules: 151 + 324 call sites (4) | **Grown**: 164 into `core::native`, 347 into `core::value`/`type`/`cabi`, 45 into `core::decimal`, more namespaces (section 14) | callgraph summary; grep |
| Native libraries Linux glibc only (4) | **Partially resolved**: Linux glibc x86-64 and AArch64, Windows x86-64 (MSVC); not macOS (section 15) | codegen/library.rs `SUPPORTED` |
| A partial port saves little: flat profile, largest 16 % (3) | **Still true**: largest exclusive analysis 15.2 % of `import std::event_loop` (section 18) | event-loop-analyses.txt |
| Complete port: 2-3x on the gate, at most 4.2x (1, 3) | **Lower** once a boundary is counted: at most 4.3x (3.6x with one crossing), realistically 1.8-2.2x today, 2.8x allocation-free (section 18) | gate-phases.txt |
| Gate structure: strict pass and six gate runs are redundant (1) | **Unchanged** and still the cheapest saving (section 18) | tests/warning-gate.test; gate.tcl |

## 4. Language expressiveness and ergonomic readiness

**Algebraic data (observed).** `programs/checker.bot` models what the
mid-end models, with the language's own types:

* the IR as `enum Expr` with typed payloads (`Call {target: int, args:
  List[int]}`, `Let {name: str, value: int, body: int}`), children by dense
  integer id in one `MutableVector[Expr]` (the HIR's `exprs` table, with
  Int ids instead of `eN` keys);
* type forms as a recursive enum, `Fun {param: Type, result: Type}` beside
  payload-free `Unknown`, `IntT`, `BoolT`, `Poison`;
* diagnostic codes as a payload-free enum, diagnostics as a struct holding
  one;
* function summaries in a `MutableArray[Type]`, the scoped environment as a
  `std::mutable_map::MutableMap[str, Type]` place, updated in place and
  restored after a `let` (the semantic-instance walks' discipline).

Recursive payload enums work, compare structurally with `==`
(recursively, total for a function-free enum) and hash; `match` binds
exactly a case's fields, renames them (`case Type::Fun {param: p2, ...}`) or
ignores the payload (`case Type::Fun:`). Exhaustiveness is checked:
adding a case `Extra` to the checker's `Type` makes exactly its two matches
over `Type` (`show`, `type_number`) compile-time MATCH-NOT-EXHAUSTIVE
errors, naming `Type::Extra` (observed). Nothing needed `any`, a manual tag
or a dynamic field name.

**What the probes found awkward** (observed, each with a reproducer):

1. **One enum for several syntactic categories needs impossible arms.**
   The HIR keeps every node kind in one table. Written as one enum, a
   statement walker must still name the expression cases (mutual.bot's
   `stmt_with` returns 0 for `Lit`, `Add`, `BlockExpr`); written as one
   enum per category, the tables split. Neither is wrong; the first loses
   some of the checking payload enums were added for.
2. **Values selected by `match` are not scalar-replaced.** In the enum
   kernel, `r = match nodes.at(i): ... Range {...}` makes every `Range`
   a heap object at construction (`native::structCensus`: `materialized`,
   reason `control`); the struct kernel's `r = if ...` keeps it virtual
   until the recursive return. Both still allocate one `Range` per call,
   because a recursive call's struct result is materialized (section 7).
3. **Request enums are heap objects.** The only context-compatible way to
   write mutual recursion today, one function over a request enum, builds
   a heap object per request: mutual.bot's merged form allocates 2.46
   million objects against 1.49 million for the function-value form (section
   5).
4. **No typed empty collection.** `std::mutable_vector::from_list([])`
   alone is a `MutableVector[never]`, and its later uses are `any`
   (UNPROVEN-FIELD, ambiguous `at`); checker.bot declares four one-line
   constructors with a declared result type (`fn exprs() ->
   MutableVector[Expr]`). There are no typed local bindings to annotate
   instead (`v: MutableVector[int] = ...` is a syntax error, observed).
5. **Mutable collections are uneven.** `MutableVector` has no `set` (an
   element is replaced with `swap`, whose old value is returned);
   `MutableArray` has no `length` (it is `capacity`); `mutable_array::copy`
   is a slice with two declared bound errors.
6. **Folds as loops.** A side-effect-only loop over indices is a `fold`
   with a dummy intermediate (`fold k from 0 to n with intermediate n 0:
   ...; n + 1`) or a collecting loop whose List is discarded; a fold whose
   last statement is that fold makes a `-> unit` function's result an Int
   (TYPE), so it needs a trailing `unit`.
7. **Strict definition order** puts every helper before its first caller;
   the checker's helpers had to be moved above `check` (UNBOUND) while it
   was written.

None of these blocks the work; together they make the Botlish checker 397
code lines against the Tcl reference's 237 (1.7 times; 492 and 261 with
comments and blanks), of which about 40 are a merge sort and a String
comparison Tcl gets from `lsort` and `string compare`, about 25 the
generator's explicit `Gen` results, and 8 the typed constructors. The
compiler raises 47 METHOD-ELIGIBLE, 7 ONE-CHAR-STRING-LITERAL and 1
SAME-RETURN-VALUE
warnings on it as written in the Tcl style (plain calls, one-letter String
literals); they are style findings, not defects.

**Error contracts** (section 6) and **contexts** (sections 5 and 14) are
assessed where they bite.

## 5. Mutual recursion and the real compiler call graphs

**Status (inspection).** `mutual:` is designed (MUTUAL-RECURSION.md) and not
implemented: writing it is a syntax error, `concept.mutual-recursion` says
so, and `programs/mutual-direct.bot` (two functions calling each other) is
rejected with CORE SEMANTIC UNBOUND. Its design allows a group only at a
module's top level, every member declaring its result type.

**The actual cycles** (observed: `tools/callgraph.tcl`, results in
`results/callgraph/`). 2,909 `::hir` procedures; a front-end build of 20
programs (18 golden suites, the 2048 golden suite and Icy Tower's headless
suite) ran 1,768 of them, native lowering of five programs 750 (397 both,
353 native lowering only). Two graphs, restricted to the procedures a
front-end build ran:

| graph | SCCs of two or more | procedures in them | further self-recursive procedures | largest SCC |
|---|---:|---:|---:|---:|
| static (command-position names in bodies) | 35 | 212 | 74 | 51 procedures, 9 files |
| dynamic (caller -> callee as the build ran) | 24 | 212 | 67 | 82 procedures, 12 files |

The two agree on how many procedures are in cycles and differ in shape:
the static graph misses calls made through a registered procedure name
(hir/summaries.tcl's property nodes), which the dynamic graph sees, and
sees calls the corpus did not exercise. The largest cycles (dynamic):

* **82 procedures, 12 files: the type lattice and everything that
  classifies a type by its components** -- `hir/types.tcl` (40: `Totality`,
  `SendClass`, `HashClass`, `MakeApplied`, `FnSubtype`, `IsAffine`, ...),
  `hir/summaries.tcl` (7: the declaration-summary fixpoint),
  `hir/callables.tcl` (8), `hir/structs.tcl` (7), `hir/traits.tcl` (5),
  `hir/ownership.tcl` (4), `hir/imprint.tcl` (3), two each of
  `staticdeps.tcl`, `mutvec.tcl`, `decimal.tcl`, one each of `range.tcl`
  and `enums.tcl`. It is one cycle because every component analysis
  answers a named struct from its declaration's summary
  (PARAMETERIZED-DECLARATION-SUMMARIES-MILESTONE-1.md), and the summaries
  call the analyses back.
* **32 procedures, 4 files**: resolution and the completion analysis
  (`hir/resolve.tcl` 9, `hir/completions.tcl` 21, `flags.tcl`, `hir.tcl`'s
  `CheckingCall`).
* **16 procedures**: the inference walker (`hir::types::Expr`, `Sequence`,
  `Block`, `Bind`, `Call`, `If`, `Handle`, `Project`, `Struct`, `FoldBody`,
  `FoldInitial`) and semantic instances (`hir::semantic::Analyze`, `Call`,
  `Drain`, `Nested`, `Walk`).
* **15 procedures**: the whole-program build itself (`BuildFull`,
  `BuildOnce`, `check`, `DecideMethodCalls`, the method decision's
  `Build`/`Decide`/`Final`, `monomorphize`, the static rounds): the
  decision and the plan run builds, which run decisions.
* then 8 (type-expression resolution across `resolve`, `layouts`,
  `cabi`), 7 (`exactvalue.tcl`), 6, 5, 5, 5, ... and 67 self-recursive
  procedures. Every member of a cycle would need a declared result type
  under the design (most of these procedures return dicts or lists whose
  Botlish types would be declared anyway).

**What the design's restriction means.** A group lives in one module, and
Botlish's module graph must be acyclic (surface/modules.tcl, CYCLE). The
82-procedure cycle spans 12 Tcl namespaces; as designed, a port would have
to put the whole lattice -- today about a dozen files' worth of code -- in
one module, or break the cycle (for example by passing the summary
property's node function as a value, which is what hir/summaries.tcl's
registration already does in Tcl). This is a design question the
`mutual:` milestone should answer with this census's numbers, not a
detail (projection).

**The workarounds, measured** (observed: `programs/mutual.bot`,
`tools/mutual.tcl`, 3,000 trees of depth 10, 450,962 nodes, best of 3;
results/mutual.txt). A three-member cycle expr -> seq -> stmt -> expr
(a block expression holds statements; `seq` takes a List, as
`hir::types::Sequence` does), written three ways, all computing the same
checksum on every backend:

| form | seconds | peak MB | heap objects | closures |
|---|---:|---:|---:|---:|
| merged: one function over `enum Req {E {e}, S {s}, Q {items}}` | 0.426 | 132 | 2,456,134 | 7 |
| passed: later members handed to earlier ones as `Fn{...}` values | 0.347 | 96 | 1,490,106 | 67,111 |
| flat: one bottom-up pass, no recursion through the cycle | 0.244 | 90 | 1,420,002 | 7 |

* The merged form needs every member's result to be one type (here all
  are int; in the mid-end they are not: `hir::types::Expr` returns a type,
  `Sequence` a type while it updates its context, `Block` a block type),
  and builds a request object per call: 23 % slower than function values
  here.
* The passed form needs a closure per block expression (`expr` must give
  `seq` a statement walker, a nested function capturing `expr`), and it
  **is excluded by contexts**: `programs/mutual-context.bot` gives the
  walkers a context (as a mid-end would give them its registries and its
  diagnostic sink), and the nested function inherits the requirement, so
  passing it is CONTEXT-FUNCTION-VALUE ("function stmt requires context
  Sink, so it can only be called ... it cannot be passed").
* The flat form exists only where the data happens to be ordered (here,
  children before parents); inference over a program is not.

**Verdict: still blocking** for a complete mid-end. Not because one
syntax is missing -- small cycles can be merged -- but because the real
cycles are large, cross files, have heterogeneous results, and would carry
context requirements: exactly the case each workaround fails.

## 6. Standard-library and error-contract readiness

**Facilities** (observed: `programs/stdlib.bot` at 1,000, 4,000 and 16,000
items, natively, `tools/stdlib.tcl`; results/stdlib.txt; best of 3 runs of
the compiled program):

| operation | exists? | how written | 1,000 / 4,000 / 16,000 µs | growth |
|---|---|---|---:|---|
| sort names deterministically | no sort, no String ordering (`"a" < "b"` is a TYPE error) | merge sort over a `MutableArray[str]`, a scalar-value comparison (40 lines) | 881 / 5,770 / 42,308 | n log n |
| a long diagnostic | `concat`, `to_string`; no format, interpolation or join | `concat` in a fold | 67 / 354 / 1,303 | linear (construction plan) |
| update one field of an 8-field state | no struct update (`s with {...}` is a syntax error) | restate all eight fields | 49 / 203 / 892 | linear |
| grow a List | `append` | `append` in a fold | 27 / 108 / 444 | linear (construction plan) |
| push into one of 16 buckets of a `MutableArray[MutableVector[int]]` | no mutable element place | take out (`at`), `push`, store back (`set`) | 114 / 1,463 / 9,789 | **quadratic**: 31,752 / 502,000 / 8,008,000 elements copied |
| the same, moving the bucket out with `swap` | -- | `swap` out, `push`, `swap` back | 177 / 1,485 / 11,203 | **quadratic**, the same copies |
| split on a character | no split, search or trim | a hand-written scanner over `char_at` and `substring` | 148 / 904 / 2,734 | linear |

* **Text is fine.** String and List building in a fold or a self-tail
  recursion are linear natively (the construction plans of
  FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md and
  `task.string-concatenation`); diagnostics can be built.
* **Collections of collections are not.** An element of a
  `MutableArray[MutableVector[T]]` is not a mutation place outside a
  context, and `programs/stdlib-nested-context.bot` shows it is not one
  inside a context either (MUTABLE-PLACE-RECEIVER at the push); taking the
  element out and storing it back copies it each time, because the stored
  value is shared on entry. Adjacency lists, per-block statement lists and
  per-scope binding lists are this shape; the probe used flat tables (a CSR
  reverse call graph) instead, which is what `ranges-tables.bot` does too.
* **Sorting, String ordering, split, search and formatting** are absent and
  written by hand; the costs are reasonable, the code is boilerplate every
  port would repeat. Integer division is still absent
  (`capability.integer-division`).

**Index proofs** (observed: `programs/stdlib-index*.bot`):

* proven, so the function declares no error: a guard on both bounds of a
  `MutableVector` or `List` index (`i >= 0 and i < v.length()`), a counted
  fold over a vector's or an array's indices (`0 to a.capacity()`), an
  early return on the negation (`if head < 0 or head >= q.length():
  return ...`);
* not proven: an index without a lower bound (a parameter has none the
  analysis knows), and -- the worklist shape -- an access under the same
  guard when the vector is pushed to *after* the access, even a local
  vector (`stdlib-index-push.bot`: rejected at the access). So every
  worklist read declares `errors IndexNotFound` or handles it: in
  checker.bot 13 of 32 functions declare it, in the kernels 5 of 10.

**Error contracts (inspection and observed).** Botlish's declared errors fit
the mid-end's *user-facing* failures well: an invalid program is a value of
the checker (its diagnostics, its poison), never an exception, which is how
hir/ already works (`hir::Diagnose`, poison, `hir::recovery`), and the probe
represents poison and cascade suppression as ordinary values. They fit
*compiler-internal* failures badly. hir/ raises internal invariant
violations as Tcl errors (`core::malformed`, 23 sites; `error "..."`
assertions throughout) that a Botlish port would have to declare on every
function that can reach them, or turn into `IndexNotFound`-style declared
errors propagated through the whole call graph; there is no
unrecoverable-failure channel short of `fail` with a declared error. The
census does not recommend broadening erasure for it: the right design is a
deliberate internal-failure convention (one declared `CompilerBug` error
admitted by every mid-end function, or a runtime-error intrinsic), decided
before a port (projection; roadmap item 4).

**Resource limits.** A forged or oversized HIR from outside is a validation
problem of the boundary (section 13), not of the checker; Botlish's
depth-safe front end and arbitrary-precision Int remove two of Tcl's
limits a port would otherwise inherit.

## 7. Kernel results, including the payload-enum implementation

**The reference workload reproduces exactly** (observed: `kernel.tcl
-functions 1500 -depth 8 -repeat 5`, run alone; results/kernel-1500x8.txt):
455,468 nodes, 6 rounds, checksum 275164515 for all six versions.

| version | November (best of 5) | now (best of 5) | `tcl dict` / this | this / `native tables` |
|---|---:|---:|---:|---:|
| `tcl dict` | 5.119 | 5.028 | 1.0 | 20.9 |
| `tcl list` | 2.811 | 2.809 | 1.8 | 11.7 |
| `tcl tables` | 2.587 | 2.508 | 2.0 | 10.4 |
| `native structs` | 0.762 | 0.693 | 7.3 | 2.9 |
| `native enums` | 0.769 (another day) | 0.627 | 8.0 | 2.6 |
| `native tables` | 0.293 | 0.241 | 20.9 | 1.0 |

The Tcl versions ran in the same time as in November; the native ones 9-18
% faster (the `native enums` row was measured on another day then, beside
0.814 s for structs). Like for like: native Botlish is **4.1 times faster
than tuned Tcl when each call returns a small struct** (`tcl list` against
`native structs`), **10.4 times when nothing is allocated** (`tcl tables`
against `native tables`); November recorded 3.7 and 8.8.

**The grid** (observed: `tools/kernel-grid.tcl`, best of 3, executables
built apart; results/kernel-grid.txt; shared the machine with nothing but
its own steps):

| functions:depth | nodes | tcl dict | tcl list | tcl tables | native structs | native enums | native tables | build s | `tcl list`/structs | `tcl tables`/tables |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 375:8 | 108,395 | 1.081 | 0.760 | 0.552 | 0.139 | 0.159 | 0.053 | 1.19 | 5.5 | 10.4 |
| 750:8 | 219,712 | 2.337 | 1.365 | 1.176 | 0.333 | 0.311 | 0.108 | 1.07 | 4.1 | 10.9 |
| 1500:8 | 455,468 | 4.952 | 2.696 | 2.474 | 0.774 | 0.746 | 0.287 | 1.38 | 3.5 | 8.6 |
| 3000:8 | 897,687 | 9.618 | 5.389 | 5.118 | 1.439 | 1.381 | 0.589 | 1.17 | 3.7 | 8.7 |
| 1500:6 | 130,074 | 1.433 | 1.050 | 0.811 | 0.179 | 0.174 | 0.064 | 1.25 | 5.9 | 12.7 |
| 1500:7 | 233,338 | 3.106 | 1.742 | 1.622 | 0.437 | 0.445 | 0.168 | 1.28 | 4.0 | 9.7 |
| 1500:9 | 792,717 | 8.694 | 5.001 | 4.553 | 1.385 | 1.256 | 0.541 | 1.17 | 3.6 | 8.4 |

Peak memory and the native allocation summary (`native::allocationReport`,
one JIT run of the same NIR):

| functions:depth | tcl dict MB | tcl list MB | native structs MB | native enums MB | native tables MB | structs objects | enums objects | tables objects | structs GC ms | enums GC ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 375:8 | 118 | 20 | 50 | 47 | 16 | 758,767 | 823,486 | 108,403 | 22 | 24 |
| 1500:8 | 480 | 66 | 204 | 190 | 58 | 3,188,278 | 3,462,662 | 455,476 | 158 | 183 |
| 3000:8 | 950 | 126 | 400 | 373 | 112 | 6,283,811 | 6,825,602 | 897,695 | 218 | 202 |
| 1500:9 | 841 | 112 | 356 | 333 | 99 | 5,549,021 | 6,028,046 | 792,725 | 193 | 219 |

What the figures say:

* **Every version is linear in the nodes**, Tcl and native; the
  native-over-Tcl factors settle at 3.5-3.7 (structs) and 8.4-8.7 (tables)
  once the program is large enough for its start and its collector to stop
  mattering. Building an executable costs 1.1-1.4 s at every size (the
  program's text does not grow with the workload).
* **Allocation still decides the native factor.** Under callgrind (300
  functions, depth 7; results/kernel-callgrind.txt, observed), 62.1 % of
  the struct version's instructions are glibc's `malloc` and `free`, 18.1 %
  the runtime's allocation and collection, 12.8 % generated code -- the
  November figures to the tenth (62.1, 18.0, 12.8). `native/src/runtime/
  heap.rs` still describes itself as "temporary": every object its own
  allocation, a non-moving mark-and-sweep collector, no nursery
  (inspection). The struct version allocates seven heap objects per node
  over six rounds: the node itself, then one `Range` per evaluation, since
  a recursive call's struct result is materialized (its census: `local`,
  `mats result`).
* **Native code uses more memory than tuned Tcl.** The struct and enum
  versions' peaks are 3 times `tcl list`'s (204 against 66 MB at 1500:8):
  each node is a heap object with a header (the payload is two to four
  words), where Tcl shares small integers and lists. The tables version is
  below Tcl. A mid-end whose HIR is a heap of small objects would pay this
  (section 8's checker: 18-36 % more than its Tcl reference).
* **Payload enums are not intrinsically faster.** `native enums` beats
  `native structs` by 4-10 % at most sizes (0.627 against 0.693 s at the
  reference, best of 5) and loses at the smallest (0.159 against 0.139). It
  allocates *more* objects (an enum-case box per payload-bearing node,
  8.6 % more at the reference) but *fewer bytes* (164 against 168 MB) and
  keeps fewer live bytes (111 against 122 MB at the peak): each node holds
  only its case's fields, and `Param` is an immediate. The difference
  follows the bytes the collector marks, not the language construct; and
  the enum version's `match` defeats the scalar replacement of `Range`
  (section 4), which costs it the advantage it would otherwise have.
* **Data design is still worth 1.8-2.0 times inside Tcl** (`tcl dict`
  against `tcl list` and `tcl tables`), a speedup available without a port.

## 8. Compiler-shaped Botlish prototype

`programs/checker.bot` (audit-only; its Tcl reference is
`programs/checker.tcl`, written as tuned Tcl: flat lists, `lset`, a dict
for the environment). The same seeded generator builds FUNCTIONS
expression trees (constants, Booleans, names, `+`, `<`, conditionals,
calls with 0-2 arguments, `let`), with deliberate faults: names bound
nowhere, calls of two functions that do not exist, Bool and Int mixed,
arity mismatches. Then:

1. a reverse call graph as flat tables (CSR) from the trees;
2. a FIFO worklist over function indices: check a function's body under
   the current summaries, join its result into its summary, enqueue its
   callers when it changed, until nothing changes;
3. a diagnosing pass over every function under the converged summaries,
   poison suppressing cascades (an operation on a poisoned operand reports
   nothing, as `hir::types` does), an unknown result passing silently;
4. a deterministic order: by function name (a String comparison by scalar
   values), node and code, by a merge sort; each diagnostic rendered as
   text (`f12:340: [1] unbound name p3`);
5. a summary: [nodes, rechecks, diagnostics, a checksum of the summaries,
   a checksum of the rendered text].

**Results agree everywhere** (observed: `tools/checker.tcl`,
results/checker.txt): at 300 functions of depth 6, [14,208 nodes, 481
rechecks, 3,486 diagnostics, 677785035, 748260083] from the Tcl reference,
from `compile`, `cranelift-generic` and `cranelift` through main.tcl, and
(once, 3 min 40 s) from `interp`; at 2,000 and 8,000 functions of depth 8,
the same values from the reference and both native builds.

**Cost** (observed; best of 3; the Tcl figure excludes its 20 ms start, the
native ones are whole executables; shared the machine with two other
measurements, the gate workload and the phase split):

| size | nodes | diagnostics | Tcl s | native s | unspecialized s | Tcl / native | Tcl MB | native MB | unspecialized MB | build: lower and link s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2,000:8 | 282,424 | 62,830 | 2.541 | 0.539 | 0.770 | 4.7 | 105 | 123 | 134 | 1.8 (0.98 unspecialized) |
| 8,000:8 | 1,122,566 | 248,028 | 10.706 | 2.711 | 3.687 | 3.9 | 398 | 542 | 476 | 2.4 (1.2 unspecialized) |

At 8,000 functions the native run allocates 9.9 million objects (385 MB):
5.4 million Lists (each call's argument types, the merge's two-element
fold state), 1.6 million Strings (names rebuilt per leaf, messages), 1.4
million structs, and spends 0.28 s in six collections.

**What the prototype shows:**

* **The shape is expressible, with clarity.** Name lookup, type
  propagation and an invalid expression interact as in the mid-end (an
  unbound name is a diagnostic and poison; an argument of the wrong type
  in a call to a function whose summary is not known yet is checked
  against the declared parameter types; the summary flows to callers
  through the worklist). The exhaustive matches made adding a case a
  checked change.
* **It is 3.9-4.7 times faster than tuned Tcl natively, 2.9-3.3 times
  unspecialized**, in line with the kernel's struct factor: the gap to the
  allocation-free factor is the allocator again.
* **The workarounds would scale, at a cost in code**: the typed
  constructors and the hand-written sort scale as boilerplate; the
  `errors IndexNotFound` on every worklist function scales as noise; the
  flat tables scale (they are faster); the cycle in this probe was small
  enough to avoid (check -> operands and mismatch are helpers defined
  first). The probe has none of the mid-end's large cycles (section 5),
  which is precisely the part it cannot show.

The probe is not a mid-end: it has one pass, no declarations, no
resolution of modules, no semantic instances. It distinguishes an ergonomic
gap (none that blocks) from a runtime cost (allocation, memory) and an
algorithmic one (none: both implementations are linear).

## 9. Current frontend scaling

The November ladder, rerun with the same generator and measurement
(observed: `tools/scale.tcl` and `tools/measure.tcl` unmodified, each size
in a process of its own; results/scale-frontend-helper.txt with the shared
untyped helper, results/scale-frontend-nohelper.txt without; both ladders
shared the machine with the call-graph run and the probes, one or two other
single-threaded processes; printed by `tools/ladder.tcl`):

| passes | helper | lines | expressions | front end s | parse and load s | `hir::check` s | decision s | monomorphize s | ms per line | growth (time / lines) | peak GiB | outcome |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---|---:|---|
| 8 | yes | 3,584 | 22,778 | 23.1 | 3.5 | 14.4 | 5.5 | 5.7 | 6.45 | | 0.45 | ok |
| 16 | yes | 7,023 | 42,626 | 46.5 | 6.1 | 30.2 | 12.3 | 11.1 | 6.62 | 2.01 / 1.96 | 0.82 | ok |
| 32 | yes | 13,899 | 82,322 | 89.8 | 12.5 | 56.9 | 20.6 | 23.0 | 6.46 | 1.93 / 1.98 | 1.55 | ok |
| 64 | yes | 27,656 | 161,714 | 186.7 | 24.9 | 120.1 | 44.9 | 47.5 | 6.75 | 2.08 / 1.99 | 2.68 | ok |
| 128 | yes | 55,174 | 320,498 | 409.1 | 47.8 | 272.4 | 99.1 | 109.2 | 7.41 | 2.19 / 2.00 | 5.10 | ok |
| 8 | no | 3,344 | 20,778 | 23.1 | 3.5 | 14.1 | 5.2 | 5.4 | 6.92 | | 0.42 | ok |
| 16 | no | 6,543 | 38,626 | 42.7 | 6.0 | 27.7 | 10.0 | 11.2 | 6.53 | 1.85 / 1.96 | 0.74 | ok |
| 32 | no | 12,939 | 74,322 | 83.4 | 10.7 | 54.2 | 20.8 | 20.8 | 6.45 | 1.95 / 1.98 | 1.40 | ok |
| 64 | no | 25,736 | 145,714 | 166.3 | 22.3 | 106.8 | 40.1 | 43.7 | 6.46 | 1.99 / 1.99 | 2.42 | ok |

The November rows (historical; results/scale.txt, scale-frontend.txt):

| passes | helper | lines | front end s | ms per line | growth | peak GiB | outcome |
|---:|---|---:|---:|---:|---|---:|---|
| 16 | yes | 7,023 | 52.1 | 7.42 | | 1.02 | ok |
| 32 | yes | 13,899 | 77.7 | -- | | 1.92 | **rejected** (TYPE at the 17th instance) |
| 32 | no | 12,939 | 93.5 | 7.23 | | 1.74 | ok |
| 64 | no | 25,736 | 233.0 | 9.06 | 2.49 / 1.99 | 3.03 | ok |
| 128 | no | 51,334 | 622.7 | 12.13 | 2.67 / 1.99 | 5.92 | ok |

* **The front end is now linear to about 28,000 lines**: 6.45-6.75 ms per
  line from 3,344 to 27,656 lines, each doubling 1.85-2.08 times the time.
  In November it was linear to about 13,000 lines and grew 2.49 and 2.67
  times per doubling beyond.
* **At 55,000 lines a little superlinearity is left**: 2.19 times for a
  doubling, 7.41 ms per line, in `hir::check` (2.27 times) and the
  decision and the monomorphization (2.21, 2.30), not in parsing and loading
  (1.92). The same programs' front end costs 0.71 times November's at
  25,736 lines (166 against 233 s) and, per line, 0.61 times at the top
  (7.41 against 12.13 ms; the November top was 51,334 lines without the
  helper, this one 55,174 with it).
* **Memory is linear: about 97 KB per line** (5.10 GiB at 55,174 lines;
  November about 120 KB). Each line is about six HIR expressions.
* **A port-sized program compiles** in about 7 minutes and 5 GiB; with the
  shared helper, which November's compiler rejected from 13,899 lines on.

**The phase split** (observed: `tools/frontend-phases.tcl`, the
with-helper programs, one process each; results/frontend-phases.txt;
inclusive seconds of the outermost activation, exclusive where marked; the
decision's and the monomorphization's builds are checks too, so rows
overlap):

| | 7,023 lines | 27,656 lines | 55,174 lines | growth, last doubling |
|---|---:|---:|---:|---:|
| front end | 43.7 | 185.3 | 417.3 | 2.25x |
| parsing and loading (`CollectAndLoad`) | 6.2 | 23.2 | 48.9 | 2.10x |
| `hir::buildSyntax` | 35.7 | 154.7 | 352.7 | 2.28x |
| `hir::check`, exclusive of the phases below | 14.3 | 62.0 | 126.6 | 2.04x |
| `hir::DecideMethodCalls` (its build) | 10.0 | 45.2 | 104.9 | 2.32x |
| `hir::traits::monomorphize` (its build) | 10.9 | 47.7 | 110.0 | 2.31x |
| `hir::signatures::infer` (type inference) | 8.1 (18.6 %) | 40.7 (22.0 %) | 111.4 (26.7 %) | **2.74x** |
| of which `hir::types::Block`, exclusive | 4.7 (4,806 calls, 0.98 ms each) | 26.7 (17,190, 1.56 ms) | 80.0 (33,702, 2.37 ms) | **2.99x** |
| semantic-instance walks | 0.23 (222 walks, 1.04 ms each) | 1.06 (861, 1.23 ms) | 2.09 (1,692, 1.24 ms) | 1.97x |
| `hir::resolve::program` | 2.9 | 11.2 | 25.1 | 2.23x |
| `hir::errorsets::verify` | 4.8 | 18.7 | 41.8 | 2.23x |
| `hir::warnings::run` | 1.8 | 7.1 | 15.3 | 2.17x |
| peak MB | 836 | 2,742 | 5,222 | |

So the superlinearity that is left is **type inference, and within it the
function-body typing `hir::types::Block`**, whose cost per call grows with
the program (0.98, 1.56, 2.37 ms; its exclusive time includes the
unwrapped statement walkers of the body, whose size does not grow in these
programs). Section 10 bounds the part of it that is the inherited
context's copy. Every other analysis is within 2.0-2.3 times per doubling.
The semantic-instance walks are flat per walk, as the instance milestone
left them.

## 10. Semantic-instance scalability

**The properties SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md established
still hold** (inspection: hir/semantic.tcl has no `maxPerBlock`; its guards
are `maxInstances` 2,000, `maxDepth` 24 -- deferral, not decline -- and
`passLimit` 6; observed below).

**The reproducer** (observed: `audit/mid-end-port/tools/budget.tcl`;
results/budget.txt): one untyped helper called with N struct types whose
result reaches a typed parameter.

| distinct types | outcome | seconds | instances | peak MB |
|---:|---|---:|---:|---:|
| 16 | accepted | 0.13 | 16 | 29 |
| 17 | accepted (rejected in November) | 0.10 | 17 | 33 |
| 64 | accepted | 0.43 | 64 | 48 |
| 256 | accepted | 2.03 | 256 | 113 |
| 1,024 | accepted | 8.02 | 1,024 | 373 |
| 1,024 calls of 1 type | accepted | 7.00 | 1 | 304 |
| 256, a 40-statement helper | accepted | 5.59 | 256 | 166 |
| 1,024 with `maxInstances` 1,000 | **HIR SEMANTIC LIMIT** naming `choose (c : bool, x : T1001, y : T1001)` | 4.68 | -- | -- |

* An instance of the 2-line helper costs about 1 ms in a 1,024-call
  program (8.02 against 7.00 s); of the 40-statement helper, about 14 ms.
* Past the total guard the compiler fails with a resource limit that names
  the function and its entry types; no call silently falls back to the
  untyped analysis. That is a compiler resource failure, not a TYPE error
  at a later use: whether a program is rejected no longer depends on
  unrelated instances (EQUALITY-SEMANTICS.md's rule holds).
* **At scale**: the 64-pass program asks for 65 semantic instances, 64 of
  them of `lattice::choose`, the 128-pass program 129; their walks stay
  flat per walk (1.04, 1.23, 1.24 ms at 7,023, 27,656 and 55,174 lines) and
  cost 2.1 s of a 417 s front end at the largest (section 9). The
  16-instance cliff is not a factor any more; nothing here reopens it.
* **The remaining guard was not measured against a port with many
  polymorphic helpers** (projection, as the milestone itself said): 2,000
  instances of small helpers cost a few seconds of walks, of
  160-statement helpers about a minute
  (SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md, 6.3, historical).

**Remaining type-inference costs.** The copy-on-write pattern the
instance milestone left open (its section 7) is still there (inspection:
`hir::types::Block` starts every body's context with `dict set ctx types
[dict get $outer types]`, the same for `facts` and `implies`, and its first
write -- the function's own binding, a parameter's declared type -- copies
the inherited dict). Measured three ways:

* **How much is copied** (observed:
  `audit/semantic-instance-scalability/tools/remaining-copies.tcl
  contexts`; results/block-contexts.txt): at 3,584, 7,023 and 13,899 lines
  the creating context holds on average 227, 399 and 743 binding types
  (at most 455, 799, 1,487), so the block typings copy at most 0.62, 1.92
  and 6.64 million entries in all: quadratic, 3.1 and 3.5 times per
  doubling.
* **What one copy costs** (observed: `tools/block-copy.tcl`, the reduced
  reproducer: the same two `dict set`s on a shared dict of binding-type
  entries; results/block-copy.txt): 10.9, 19.4, 34.5, 78.6 and 256 µs per
  body at 227, 399, 743, 1,487 and 2,970 entries. At 13,899 lines that is
  about 0.3 s of 90 s; at 55,174 lines (about 2,970 entries on average,
  33,702 typings) about 9 s of 417 s (projection).
* **What `Block` costs per call besides its body** (observed: the
  original `infer-profile.tcl` with November's procedure list, which wraps
  the statement walkers so that `Block`'s exclusive time is its own;
  results/infer-profile.txt): 0.150 ms at 6,543 lines, 0.252 ms at 12,939.
  Its growth, 0.81 s beyond linear at 12,939 lines, is the largest of any
  inference procedure there; every other procedure's cost per call is
  within 20 % across the doubling.

**Bound** (projection): replacing the inherited contexts with the body's
captures and declared bindings (an outer local a body reads is a capture;
a module binding is typed once, outside the context) would remove a cost
that is quadratic but small: about 1 % of the front end at 14,000 lines,
2-4 % at 55,000. It is worth doing when type inference is next changed,
and it does not explain all of the remaining superlinearity (section 9:
inference grows 2.74 times per doubling at the top, `hir::check` 2.04);
the rest is spread over `hir::signatures` and the semantic call handling
(`Call`, `ArgSinks`, `CallableName`: 9-12 % more per call at twice the
size), none dominant. Nothing else has become dominant since the copies
were removed: the profile at 55,174 lines is as flat as at 7,023 (section
9).

## 11. Native specialization and memory

**The view copying is unchanged** (inspection: `hir::specialize::view`,
`memoizeViews` and `View` are as November found them; `View` applies an
instance's overlay to a copy of the whole HIR, "Building a view costs
O(program): its first `dict set` copies HIR's whole exprs table", and the
memo keeps one view per used instance for the whole lowering).

**Measured** (observed: `scale.tcl -generic 0 -native 1 -specialize 1`,
each size in a process of its own; results/scale-native-specialized.txt and
scale-native-specialized-32.txt; the 32-pass run under a 10 GiB
address-space cap so that it could not take the machine):

| passes | lines | front end s | specializer's analysis s | views s (calls) | block escape s | lowering s | Cranelift and link s | peak GiB | outcome |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 8 | 3,344 | 20.7 | 10.9 | 3.6 (4,791) | 3.0 | 16.1 | 0.48 | 1.32 | ok |
| 16 | 6,543 | 42.0 | 40.2 | 12.5 (8,972) | 10.8 | 53.9 | 0.62 | 3.88 | ok |
| 32 | 12,939 | 81.6 | -- | -- | -- | -- | -- | over the cap | **failed in lowering** at the 10 GiB cap (`unable to alloc 56 bytes`), 580 s in; 1.48 GB resident after the specializer's analysis and summary |

November (historical; results/scale-native.txt): 8 passes 17.6 s lowering
and 1.45 GiB; 16 passes 62.2 s and 3.86 GiB; 32 passes killed by the
kernel's out-of-memory killer 692 s in, past 11.75 GiB resident.

* **Memory is still quadratic in the program**: 2.9 times for a doubling
  (1.32 to 3.88 GiB), the same 3.9 GiB at 16 passes as in November, and the
  same failure at 32 -- in lowering, after the analysis, exactly where the
  views are built. Nothing has changed it.
* **Time is quadratic too**: the specializer's analysis grows 3.7 times per
  doubling (10.9 to 40.2 s), the views 3.5 times, block escape 3.6 times.
  The specialized lowering of 16 passes is 15 % faster than November's
  (not analyzed: runs move by 10-25 % here, and native lowering has
  changed since).
* **Cranelift and the link are not the problem** (0.5-0.6 s).

So a specialized native build of a mid-end-sized Botlish program is not
possible on a 16 GB machine today: the wall lies between 6,543 lines (3.9
GiB) and 12,939 lines (more than 10 GiB here, more than 11.75 GiB in
November), a few times smaller than a port.

**Semantic instances and codegen instances are different mechanisms.** A
semantic instance is the type analysis of a function body under one
caller's argument types, inside type inference; its walk now types the
program's own HIR in place and undoes exactly what it wrote. A codegen
instance is a function body as native lowering will compile it, with its
instance's overlay -- types, known values, reachability, call targets --
applied, read a dozen times or more by lowering and the native-path
analyses (range, escape, block escape, regions). The semantic milestone's
rollback works because a walk's writes are confined to one region and
undone before the next walk; a codegen view is read *concurrently* with
others (lowering an instance reads its callees' views too) and must stay
valid for the whole lowering. Reusing the journal therefore needs either
lowering instance by instance with the overlay applied and undone around
each (the consumers would then have to stop reading other instances'
views), or a view that is the generic HIR plus a sparse overlay consulted
by every reader (`hir::get` through an overlay), which is the larger change
and the one that makes memory linear (projection; roadmap item 3).

## 12. Generic native compilation

**Unspecialized lowering at scale** (observed: `scale.tcl -generic 0
-native 1 -specialize 0`, each size in a process of its own;
results/scale-native-generic.txt; shared the machine with the call-graph
run):

| passes | lines | front end s | lowering s | of which the twelve listed analyses s | Cranelift and link s | NIR KB | peak GiB | run | outcome |
|---:|---:|---:|---:|---:|---:|---:|---:|---|---|
| 8 | 3,344 | 20.8 | 4.2 | 2.7 | 0.35 | 345 | 0.43 | value | ok |
| 16 | 6,543 | 41.8 | 8.5 | 5.1 | 0.46 | 651 | 0.77 | value | ok |
| 32 | 12,939 | 79.5 | 19.3 | 11.1 | 1.06 | 1,272 | 1.46 | value | ok |
| 64 | 25,736 | 179.5 | 63.3 | 26.1 | 1.71 | 2,528 | 2.53 | value | ok |

November (historical): 4.6, 11.3, 31.9 and 145.5 s of lowering before the
`BlockName` fix; 15.8 and 39.1 s at 32 and 64 passes after it (one process
at a time).

* **It fits and it finishes**: a 25,736-line program lowers and links in
  about a minute, at the front end's peak memory (2.5 GiB), and the
  executable computes its value.
* **It is superlinear again at the top**: 2.0, 2.3 and 3.3 times per
  doubling. Of the 63.3 s at 64 passes, the twelve analyses
  `measure.tcl` names take 26.1 s (the unspecialized specializer's analysis
  9.0 s, 3.4 times per doubling; range 7.7 s, linear); the other 37.2 s --
  8.2 s at 32 passes, 4.5 times per doubling -- are outside them.

**Where the growth is** (observed: `tools/native-phases.tcl` with every
analysis entry point wrapped, then every procedure of `::native::lower`,
`::hir::specialize` and the native-path analyses' namespaces;
results/native-phases.txt, native-lower-procs.txt,
native-lower-procs-2.txt; 12,939 against 25,736 lines, unspecialized;
the wrappers and the call-graph run beside them inflate absolute times, so
read the growth, not the seconds):

* **The analyses stay linear**: `hir::range::analyze` 3.8 and 7.5 s,
  `hir::lifetime::analyze` (the storage-lifetime facts, added since
  November) 3.1 and 6.6 s, `hir::aot::context` 1.5 and 3.2 s,
  `hir::escape::analyze` 1.4 and 3.0 s.
* **`hir::specialize::MaterializedBlocks` is quadratic**: 0.6 s in 1,164
  calls, then 3.6 s in 2,289 (0.52 and 1.56 ms a call). `InstanceClosed`
  calls it once per static generic instance, and it walks every used
  instance to rebuild the same set each time (inspection): the shape of
  November's `BlockName`, with the same kind of fix (compute it once per
  snapshot; projection).
* **`native::lower::Program`'s own work** -- its exclusive time minus the
  analyses it calls directly -- is about 0.4 s at 12,939 lines and about 23 s
  at 25,736. One quadratic step in it is located by inspection and
  reproduced: it numbers the functions it lowered by one `string map` whose
  map holds a placeholder per function, applied to every function's text
  and info (`tools/placeholder-map.tcl`, the reduced reproducer: 0.81 s for
  1,163 synthetic functions of 0.7 KB, 3.15 s for 2,288; results/
  placeholder-map.txt). It accounts for part of the residual; the rest is
  not located.

Both are Tcl-side fixes of November's `BlockName` kind (strategy A), not
arguments for a port; neither affects the front end.

**Is generic code fast enough for an initial Botlish mid-end?** (observed:
`tools/kernel-generic.tcl`, results/kernel-generic.txt; and the checker
above)

| program | specialized s | unspecialized s | slower by | tuned Tcl s | unspecialized against Tcl |
|---|---:|---:|---:|---:|---:|
| kernel, structs | 0.668 | 0.953 | 1.43x | 2.809 (`tcl list`) | 2.9x faster |
| kernel, enums | 0.600 | 0.885 | 1.48x | 2.809 | 3.2x faster |
| kernel, tables | 0.205 | 0.341 | 1.66x | 2.508 (`tcl tables`) | 7.4x faster |
| checker, 2,000:8 | 0.539 | 0.770 | 1.43x | 2.541 | 3.3x faster |
| checker, 8,000:8 | 2.711 | 3.687 | 1.36x | 10.706 | 2.9x faster |

**Yes, initially** (projection from these): unspecialized code costs 1.4-1.7
times specialized code and is still about three times faster than tuned
Tcl, and its lowering fits and finishes at a port's size -- superlinear at
the top, but by two Tcl-side steps that can be fixed (above). A Botlish
mid-end can be built and bootstrapped unspecialized and take
specialization once roadmap item 3 makes it fit. No production JIT is
needed for any of this: every native figure here is an AOT executable
(`-emit-native-executable`), and `-aot-run` runs one without the JIT on
every host (AOT-RUN-MILESTONE-1.md, inspection).

## 13. HIR boundary and interchange

**What exists (inspection).** `hir/interchange.tcl` writes a header line and
one Tcl dict: the front end's fingerprint, the Tcl libraries required, the
HIR itself with its `declarations`. Format 1 is *trusted* and
*same-front-end*: `decode` checks the fingerprint (a checksum of every
`core`, `hir`, `surface` and stdlib Tcl file) and then believes the dict.
HIR-INTERCHANGE.md's "Towards a front end in Botlish" lists what a
different front end needs: a specified schema, a validating reader, a
smaller surface. None of it exists; that section is unchanged.

**What a checked HIR holds** (observed: `tools/hir-surface.tcl` on four
programs; results/hir-surface.txt):

* **38 top-level keys** in the union of `payload-enums.bot`, `traits.bot`,
  `coroutines.bot` and the 2048 benchmark: `exprs` and `bindings`; scopes,
  modules, files, symbols, roots, `top`; type tables (`types`,
  `typeIds`, `sourceTypes`); semantic instances (`semantic`); analysis
  verdicts (`affine`, `mutvec`, `coroutines`, `contexts`, `direct`,
  `beforeCompletions`, `counters`); method decisions (`methodCalls`,
  `methodChoices`, `methodDecided`, `operatorCalls`); static decisions
  (`staticSites`, `staticRounds`, `staticStats`); traits (`traits`,
  `traitFunctions`, `traitSource`); errors (`errorDecls`, `errorPayloads`);
  `declarations`, `moduleDecls`, `moduleScopeIds`, `flagAllowed`,
  `diagnostics`, `mode`, `target`.
* **17 node kinds** in `exprs` (`ref`, `const`, `call`, `bind`, `block`,
  `struct`, `if`, `project`, `return`, `fail`, `handle`, the four loop
  kinds, `continue`, `break`): few kinds, each a dict of fields that varies
  by role (`written`, `reachable`, `type`, `known`, ...).
* **12 declaration registries** in `declarations` (`types`, `structs`,
  `enums`, `layouts`, `errors`, `payloads`, `traits`, `impls`, `unitNames`,
  `imports`, `foreign`, `generation`).
* **Size**: `traits.bot`'s HIR is 3.0 MB of interchange text; `traitSource`
  (the trait program's checked source build, left out of interchange) 3.0
  MB more, `exprs` 1.8 MB, `semantic` 0.37 MB, `bindings` and `scopes` 0.22
  MB each, the rest small.

**The boundary's cost in Tcl** (observed: `workload.tcl interchange`):
encoding and decoding a loader's whole HIR is 2.8-3.0 % of its build
(`std::event_loop`: 0.05 s and 0.09 s against 5.22 s, 2.1 MB), as in
November. A Botlish decoder of the same text is not measured (no Botlish
reader exists); at the checker's speed for text scanning it would be
comparable (projection), but it is a parser of a Tcl dict's quoting rules
that would have to be written.

**The minimum boundary a port needs** (projection). Two boundaries, not
one, and neither needs to be public or stable:

* **Input: lowered syntax and the process-lifetime metadata.** A mid-end
  starts from `hir::buildSyntax`'s input: the lowered surface syntax of
  every module (with source spans and AST node ids), the loader's module
  graph, and the registries a build *reads* that a build does not fill --
  the 231 registered natives with their 32 metadata keys, the builtin types,
  the C target table (8 targets), the coroutine and syscall natives'
  tables. These are immutable per compiler build: generate them once into
  a data file the Botlish mid-end embeds or reads, versioned by the
  fingerprint, instead of calling `core::native::metadata` (section 14).
* **Output: checked HIR in format 2.** The HIR dict above, specified
  per node kind and per side table, with three classes made explicit:
  facts backends read (keep, schema-checked), analysis caches backends
  could recompute (drop from the boundary: `traitSource` already is), and
  presentation (diagnostics with locations, `related` and `notes`). A
  validating reader on the Tcl side checks the schema and the
  cross-references (every id an expression, every binding a scope's) before
  a backend activates it; it never re-derives facts silently.
* **Ownership and failure**: the input is the Tcl front end's, read-only;
  the output is the mid-end's, and a malformed output is a compiler bug
  (`HIR INTERCHANGE FORMAT`), never a fallback to the Tcl mid-end. Version
  it with the front end's fingerprint *and* a schema version, refusing any
  mismatch, as format 1 does.

For the clean-room prototype (section 16, strategy B) a much smaller
boundary suffices: one analysis's inputs and outputs only (section 17).

## 14. Shared semantic rules and sources of authority

**The mid-end's calls into `core::`** (observed: static call sites by
`grep` over hir/*.tcl; dynamic calls from `tools/callgraph.tcl`'s run of
the 20-program front-end corpus and five native lowerings):

| namespace | static call sites (November) | procedures named (static) | procedures called (dynamic) | dynamic calls | semantic purpose |
|---|---:|---:|---:|---:|---|
| `core::type` | 164 (with value and cabi: 324) | 32 | 29 | 9,998,637 | builtin types and integer domains: normalize, subtype, lub, narrow, integer facts, admissibility of a value, refinement evidence; registers source types |
| `core::native` | 164 (151) | 26 | 18 | 6,939,652 | the native registry: metadata (32 keys), ownership roles, internal and direct namespaces; registers enums, errors, payloads |
| `core::value` | 118 | 23 | 28 | 6,786,296 | values the front end folds and compares: kind, equality, show, int/str/float accessors, the opaque/identity/tree tests |
| `core::coroutines` | 37 | 8 | 8 | 1,789,393 | the coroutine natives' names |
| `core::contexts` | 4 | 3 | 3 | 791,555 | context natives |
| `core::ir` | 37 | 10 | 7 | 618,195 | core IR shapes (HIR text and lowering) |
| `core::decimal` | 45 | 21 | 39 | 413,939 | the exact simulation of binary64 operations; decimal text |
| `core::linuxabi` | 11 | 5 | 6 | 399,951 | the syscall transport table |
| `core::bytestore` | 17 | 6 | 5 | 158,998 | byte-storage bridge types |
| `core::float` | -- | -- | 14 | 22,137 | Float64 rules (reached through `core::value` and `core::decimal`) |
| `core::strings` | 2 | 1 | 2 | 13,826 | String length (scalar values) for exact values |
| `core::cabi` | 65 | 26 | 9 | 3,381 | the C target table: scalar domains, the float narrowing rule, promotions, retaining parameters |
| `core::deep`, `core::inttext` | 217, -- | 3, -- | 6, 2 | 394, 16 | the depth-safe guard; Int text |
| `core::dfa`, `core::semanticError`, `core::malformed`, `core::raiseDiagnostics` | 12, 27, 23, 10 | | | | recognizer tables; error construction |

In all, 27.9 million calls into 14 namespaces for 20 front-end compilations
and five native lowerings (results/callgraph/summary.txt). The dynamic
count includes calls a `core::` procedure makes into another, and a
procedure the static grep does not name can be reached that way (hence
`core::float`).

**Classified by what a port would do with each** (projection):

| rule | where it is stated today | proposed source of truth for a Botlish mid-end | risk if duplicated |
|---|---|---|---|
| native metadata (231 natives, 32 keys), coroutine/context/syscall native names, the C target table, builtin type names | `core/native.tcl` registrations, `core/cabi.tcl`, `core/linuxabi.tcl` | **(1) immutable metadata**: generated once per compiler build into data the mid-end reads | low: data, checkable by fingerprint |
| type admissibility, integer domains, subtype/lub/narrow of builtin types, refinement evidence | `core/type.tcl` (Tcl runtime and front end share it) | **(2) one portable Botlish module**, which the Tcl front end keeps calling through the boundary until it retires, or **(5) stays Tcl-side** for the first slice | **high**: two implementations of the type lattice decide different programs |
| value equality, `show`, exact values, numeric semantics (Int, Float64, the exact binary64 simulation, decimal text) | `core/value.tcl`, `core/decimal.tcl`, `core/float.tcl`; natively `ops.rs`, `decimal.rs` | **(2) once in Botlish** for the front end, and checked against both runtimes' existing implementations by the existing oracles (`audit/decimal-rounded`, `audit/numeric-text`) | **high**: AGENTS.md wants each rule stated once per implementation; a port adds a third |
| C floating narrowing, promotions, scalar domains per target | `core/cabi.tcl` (`Narrow`, `promoted`, the target table) | **(1)** data for the domains; **(2)** for `Narrow` | medium |
| callable contracts, declared errors, completion facts | `hir/` itself (moves with the port) | the mid-end | -- |
| registry *writes* (source types, enums, errors, payloads, identity tests) | `core::type::register`, `core::native::declare*`, `core::value::set*Test` | **(4) mid-end output**: they already travel in the HIR's `declarations` (compilation isolation); the Tcl side installs them with `hir::activate` | low, already data |
| the depth-safe guard, error construction | `core/deep.tcl`, `core::malformed` | none: Botlish's recursion is depth-safe natively; errors become the internal-failure convention | -- |

The dangerous duplications are exactly the rules both runtimes already
state, each with its oracle and its mutants: the integer-domain lattice,
equality, numeric semantics, the decimal simulation. A complete port that
reimplemented them in Botlish would make each rule's third statement; the
only architecture that avoids it makes the Botlish statement *the* front
end's, called by the Tcl front end through the boundary during the
migration (projection). That is a migration of `core::type`/`value`/
`decimal` before or with the mid-end, not after it.

**Contexts and capabilities (inspection).** The mid-end's genuine effects
are few: diagnostics (data today), the static-compile decisions' builds
(pure, whole-program), profiling counters (`hir::buildStats`), the
front-end cache (outside the mid-end, in surface/). Everything else it
reads is immutable input. So a Botlish mid-end could be nearly pure: its
registries as an immutable value passed down (or a context holding one),
its diagnostics as data in its result. The friction is section 5's: a
context requirement on mutually recursive walkers excludes the
function-value workaround, so the registries would have to travel as an
ordinary argument (or be compiled in as constants) until `mutual:` exists.

## 15. Integration mechanisms and their costs

**Native libraries (inspection).** `codegen::library::SUPPORTED`: Linux glibc
on x86-64 and AArch64, Windows x86-64 (MSVC; a DLL and import library);
Android AArch64 as a cross target. Not macOS. A Botlish library has explicit
instances, is thread-affine, bounds its own recursion, installs no signal
handler and carries a private runtime.

**In process (historical, NATIVE-LIBRARY-MILESTONE-1.md, section 10).** A
Botlish library loaded into tclsh as a Tcl extension works:
`audit/compiler-service/probes/export/` builds one (`probe.c` over the
library's header), 37.4 µs per call of a JSON tokenizer on 193 bytes,
results and declared errors with payloads as data, identical under GC
stress. Its C ABI carries `int`, `bool`, `Float64` and `str` (bytes and a
length) only (inspection: the header's contract), so a HIR crosses as
text, decoded on the far side.

**Mechanisms compared** (projection unless marked):

| mechanism | per-compilation overhead | memory | failure isolation | portability | fit |
|---|---|---|---|---|---|
| **subprocess**: a Botlish executable reads the input boundary from a file or pipe and writes format 2 | process start (1-2 ms for an executable, observed: results/process-start.txt) plus encode, transfer and decode of the HIR in each direction (Tcl side 3 % of a build, observed; Botlish side unmeasured) | two processes, the HIR held twice | complete: a crash is an exit status | every host (an executable is AOT everywhere) | **best for the clean-room prototype and a staged migration**: reproducible, debuggable, bisectable |
| **native library in tclsh** | a call (tens of µs, historical) plus the same encode and decode | one process, the HIR held twice | none: a native fault ends the compiler process | Linux and Windows only; macOS would need the subprocess anyway | worth it only once the boundary's text cost dominates the process start, which at a mid-end's granularity (one call per compilation) it never does |
| **hybrid**: the library where supported, the subprocess elsewhere | | | | | two code paths to test for no measured gain |

At a mid-end's granularity -- one crossing per compilation (all of
`hir::buildSyntax`, its three builds inside) -- a subprocess's start is
noise against a build of seconds; the boundary's cost is the encoding,
which both mechanisms pay. The subprocess is the recommended mechanism
(projection).

## 16. Realistic migration strategies

**The size of the work** (observed unless marked):

* **hir/** is 85 files, 96,318 lines, 64,990 of code (November: 79 files,
  85,746 and 60,363): 2,909 procedures whose bodies hold 69,106 lines.
* **What a build runs** (results/callgraph/procs.tsv): the 20 front-end
  compilations ran 1,768 procedures (42,756 body lines) in 65 files; 212 of
  them (10,114 lines, about a quarter) are in cycles. Native lowering alone
  ran 353 more (10,845 lines) in 13 files -- `escape`, `lifetime`,
  `specialize`, `storageplan`, `construction`, `blockescape`,
  `stringregion`, `traversal`, `transport`, `induction`, `rangerec`,
  `condition` and `recovery` (its `runnable` check). 788 procedures (15,505
  lines) ran in neither: HIR text (`read.tcl`, `format.tcl`), interchange,
  core IR lowering (`lower.tcl`), the emission claims' set analysis
  (`emitdfa.tcl`, `intset.tcl`), and the paths a valid corpus does not take
  (most diagnostics, rare features).
* **Per compilation**: three whole-program builds (the plain one, the
  method decision's and the monomorphization's), each running about 30
  analyses (`workload.tcl analyses`: every `verify` pass called 3 times),
  and more builds per round of `static compile:` decisions.
* **The reference's verification assets**: 299 test files (11,212 tests),
  122 golden suites, 90 fuzzers, 107 mutation catalogs, 15 independent
  Python oracles -- most of them aimed at the mid-end's analyses, and all
  usable as a port's differential corpus (section 17).
* **A Botlish mid-end's size** (projection): the 43,000 body lines a build
  runs, plus whatever of the 15,500 unexercised lines are mid-end
  (diagnostics are), at between 1.0 and 1.7 times their Tcl length -- the
  checker's code was 1.7 times its tuned-Tcl reference, but hir/'s dict
  plumbing is the part typed records and matches shorten -- gives roughly
  45,000-90,000 lines, about 15-30 times the largest hand-written Botlish
  file today (3,680 lines). Not a translation of procedures line for line:
  the cycles, the internal-failure convention and the collections of
  collections (section 6) would reshape a good part of it.

**Strategy A: retain the Tcl mid-end** (the baseline). Its known costs and
their cheap fixes, each measured here:

* the warning gate's redundancy (section 18): about 85-90 % of that test's
  time, a test-only change;
* the specialized native build's memory (section 11): a compiler change in
  `hir/specialize.tcl`, needed by any large Botlish program, ported
  compiler or not;
* the remaining superlinearity of type inference at 55,000 lines (section
  9), of which the body-context copy is a bounded part (section 10);
* data design: 1.8-2.0 times inside Tcl for code that moves from `eN`
  dicts to dense ids (section 7), where profiles show it pays.

The Tcl mid-end stays the one semantic authority; nothing is duplicated.
Its weaknesses are not performance but maintainability at 65,000 code
lines of untyped dicts, which a port would address only after it is
complete (projection).

**Strategy B: port one bounded analysis.** The smallest useful slice is
one whose input and output are narrow, which sits in no large cycle, and
which already has an independent check, so that its Botlish version is
verified against two references at once. The census's candidates
(observed SCC membership, inspected harnesses):

* **a warning pass** -- `ONE-CHAR-STRING-LITERAL` (`const` nodes' exact
  values in, findings out; `audit/one-char-string-literal/tools/` has a
  fuzzer and mutants): the smallest boundary and the smallest value;
* **the recursive affine ownership decision** (`hir/ownership.tcl`):
  declaration states in, verdicts and witnesses out, with an independent
  Python oracle and a fuzzer (`audit/owned-recursion/tools/`); but its
  four procedures sit in the 82-procedure lattice cycle through the
  summaries' callbacks, so its Botlish version would take the summaries'
  answers as input;
* **the exact-value analysis** (`hir/exactvalue.tcl`, a 7-procedure cycle of
  its own): expressions and constants in, exact values out; it has a census
  tool (`audit/exact-value-facts/`) but no independent oracle, which the
  prototype would have to write.

Run beside the Tcl analysis on every golden suite through the
subprocess, its output compared fact by fact (section 17). It would save
nothing measurable (section 18: the largest analysis is 15 %); its value is
evidence about the boundary, the duplication and the verification model.

**Strategy C: staged complete port.**

* *Initial slice*: the type lattice and the declaration summaries as a
  Botlish library (the 82-procedure cycle, which needs `mutual:` across what
  are today 12 files), called by the Tcl mid-end through the boundary;
  then inference; then the checks.
* *Authority*: Tcl, until the Botlish implementation passes the whole
  differential corpus on every golden suite and the fuzzers for a release;
  then Botlish, with the Tcl mid-end deleted in the same change (no
  permanent dual implementation).
* *Boundary*: section 13's input and output, format 2.
* *Differential testing*: section 17.
* *Rollback and bisectability*: one switch selects the implementation per
  compilation (as `hir::methodKindProofs 0` selects the reference rule
  today), recorded in the front-end cache's key; both run in CI until the
  switch-over; a disagreement is a failing test naming the program and the
  first differing fact.
* *Prerequisites*: `mutual:` (with the cross-module decision), the
  allocator or small-result work for the 4x-to-9x factor, the
  internal-failure convention, format 2, and moving `core::type`/`value`/
  `decimal` to one Botlish statement.

**Recommendation: A now, B as an experiment, C not yet.** A keeps the
authority single and removes the measured costs; B can start once a
boundary for one analysis is written and answers the questions this
census could only project; C waits for its prerequisites, the first of
which is a language milestone.

## 17. Differential verification

The Tcl mid-end is the reference. A Botlish implementation is compared
with it by **semantic facts, normalized**, never by the HIR's bytes:

* **Inputs**: every golden suite (`tests/golden/*.bot`, 122 suites), the
  examples and benchmarks of the warning gate (132 units), the corpus of
  every fuzzer whose analysis the slice covers (`audit/*/tools/fuzz.tcl`
  with fixed seeds), and the deliberately invalid programs of
  `tests/diagnostic-recovery.test` and the census of
  `tests/static-compile.test`.
* **Facts compared** -- for each expression, keyed by its AST node id and
  source span (stable across implementations), not by `eN`: its type
  (printed by `hir::types::presented`, which hides internal ids), its
  reachability, its known value; for each call, its decided callee
  (`methodChoices`), its error set, its semantic instance's key; for each
  binding, its affinity and release point; for the program, its trait
  selections, its static-decision outcomes, its coroutine protocols.
* **Diagnostics compared** by (kind, primary location, related locations)
  as sets, then by order where the order is specified (the strict
  boundary's first diagnostic; `hir::methods::Report`'s source order); the
  message text compared only after both agree on the kind and the
  locations, so that rewording is visible separately.
* **Normalized away**: expression ids, binding ids, the order of dict
  keys, analysis caches backends do not read, counters and timings.
* **Outcomes compared**: each program run on all four backends from both
  HIRs, values and errors equal (`audit/golden/tools/check.tcl`'s
  side-by-side mode already does this for old and new tests).
* **Existing machinery to reuse**: the static-decision scheduler
  comparison (`audit/static-decisions/tools/compare.tcl`: two schedulers,
  one verdict per suite), `audit/method-resolution/tools/invariance.tcl`
  (decisions, choices and accepted programs' HIR before and after a change
  over the golden suites), the HIR interchange round trip
  (`audit/hir-interchange/tools/roundtrip.tcl`: every HIR, artifact and
  outcome identical through a fresh process), and the mutation catalogs:
  a mutant of the Tcl analysis must make the comparison fail, a mutant of
  the Botlish one too.

Incidental Tcl details -- `eN` numbering, dict order, which of two
equivalent internal forms a type takes -- are not part of the contract;
everything a backend, a diagnostic or a static decision reads is.

## 18. Updated performance case

**The workload** (observed: `workload.tcl units` and `phases`, the gate's
132 units; results/gate-units.txt, gate-phases.txt; run while one other
measurement shared the machine):

* one gate run: first pass 115.5 s, strict pass 85.3 s (November 102.1 and
  72.2 s, 128 units);
* the strict pass is still 42 % of a gate run, and still cannot fail
  where the first pass passed (inspection: `audit/refactor/tools/gate.tcl`
  compiles the strict units again; `tests/warning-gate.test` still runs
  the whole gate six times);
* CI's record (`tests/canary.tsv`, 21 days to 2026-11-15): 860.5 s on
  Linux x86-64 (now second to `depth-safe-nesting.test`'s 882.9 s), 1,018 s
  on macOS, 1,332 s on Windows.

**Where the first pass's time goes:**

| phase | seconds | share | November |
|---|---:|---:|---:|
| all 132 units | 111.2 | 100 % | 97.4 s, 128 units |
| `surface::modules::CollectAndLoad` (reading, parsing) | 11.5 | 10.4 % | 11.1 % |
| of which `Parse` | 9.5 | 8.6 % | 9.0 % |
| **`hir::buildSyntax` (the mid-end)** | **85.6** | **76.9 %** | **76.4 %** |
| of which `hir::check` | 64.5 | 58.0 % | 57.1 % |
| of which `hir::DecideMethodCalls` | 23.8 | 21.4 % | 20.3 % |
| of which `hir::traits::monomorphize` | 21.0 | 18.9 % | 18.5 % |
| of which `hir::signatures::infer` | 13.0 | 11.7 % | 11.9 % |
| `surface::lower::Finish` (warnings, recovery) | 4.4 | 3.9 % | 2.9 % |

**The ceiling** (observed split, arithmetic): with an infinitely fast
mid-end, 23.1 % of the time remains: at most **4.3 times**, as in November
(4.2).

**Realistic scenarios** (projection; each factor applied to the mid-end's
76.9 % of the first pass, the rest unchanged; the strict pass scaled by the
same ratio; one boundary crossing per compilation costing 3 % of a build in
Tcl, observed, plus an assumed equal cost in Botlish; a gate run is the
first pass of `phases` and the strict pass of `units`, 196.5 s):

| mid-end speedup | source of the factor | gate first pass | speedup (without the boundary) | gate run | whole test, here | whole test, CI scaled |
|---:|---|---:|---:|---:|---:|---:|
| 1.0x | today | 111.2 s | -- | 196.5 s | about 20 min | 14.3 min (recorded) |
| 2.9x | unspecialized native (sections 8, 12) | 60.3 s | 1.84x (2.02x) | 107 s | about 11 min | 7.8 min |
| 4.1x | specialized native, today's allocator (section 7) | 51.7 s | 2.15x (2.39x) | 91 s | about 9 min | 6.7 min |
| 10x | allocation-free native (section 7) | 39.4 s | 2.82x (3.25x) | 70 s | about 7 min | 5.1 min |
| unbounded | the ceiling | 30.8 s | 3.61x (4.33x) | 55 s | about 5.5 min | 4.0 min |
| -- | **no port: the strict verdict derived from the first pass, the ratchet cases gating only the files they touch** (November's proposal; the code is unchanged) | 111.2 s once | -- | 111 s | **about 2-3 min** | about 2 min |

What each factor is, so that none is counted twice:

* **execution in native Botlish** is the kernel's and the checker's factor
  at the same algorithm and data design (3.5-4.7x specialized, 2.9-3.3x
  unspecialized);
* **better data structures** (dense ids instead of `eN` dicts) are worth
  1.8-2.0x in Tcl alone and are not in the native factors above (the Tcl
  references already use them);
* **better algorithms** (the remaining superlinearity at 55,000 lines) are
  available in Tcl;
* **removing repeated work** -- the gate's strict pass and its six runs,
  the three whole-program builds per compilation (the decision's and the
  monomorphization's) -- is independent of the language;
* **the boundary** subtracts: 3 % per crossing in Tcl, unmeasured in
  Botlish.

**Value beyond speed** (projection, except where the probe demonstrated
it): typed IR and exhaustive matches catch a forgotten case at compile time
(demonstrated in the checker: adding a case to `Type` made its two matches
over `Type` compile-time errors, section 4); refactoring the 64,990 code lines of hir/ today relies on
tests and mutants for what a type checker would catch; reusing analyses as
ordinary Botlish libraries (an LSP, a linter) and self-hosting are real
options only after a complete port. Against them: a second authority for
the length of the migration, a third statement of the runtimes' rules
unless they move first (section 14), and the workarounds of sections 4-6
in tens of thousands of lines. **Speed alone does not justify the port**:
on the motivating workload, a test change saves more than the best port.

## 19. Remaining blockers and risks

**Blockers for a complete port**, in order of how much they gate:

1. **Mutual recursion** (language). 212 front-end procedures in cycles,
   the largest 82 across 12 files; `mutual:` unimplemented and, as designed,
   module-local.
2. **Semantic authority** (architecture). Type admissibility, equality,
   numeric and decimal semantics are stated by `core::` for the front end
   and again by each runtime; a port must move them, not copy them.
3. **The boundary** (integration). Format 1 is a trusted same-front-end
   dict; format 2 does not exist.
4. **Specialized native build memory** (compiler). Quadratic; an
   unspecialized build is the workaround.

**Costs that make a port less attractive, not impossible:**

5. **The allocator**: 62 % of the struct kernel in `malloc`/`free`; the
   native factor is about 4 instead of about 10.
6. **Native memory**: 1.2-3 times tuned Tcl's peak for heap-object data
   (the checker 1.2-1.4 times, the kernel 3 times).
7. **Collections of collections** are copied on every update; worklist
   accesses after a push need declared errors; no sort, ordering, split,
   format or struct update; no typed empty collections.
8. **Internal failures** have no convention short of a declared error on
   every function.

**Risks:** that a staged migration becomes two permanent implementations;
that the 82-procedure cycle forces a module structure nobody would design
by choice; that the measured factors (kernel, checker) do not carry over to
a mid-end whose work is more hashing of strings and maps
(ORDERED-MUTABLE-MAP-SET.md: 50-300 ns per native map operation, not far
from Tcl's dict) and less integer arithmetic (projection; the November
audit noted the same).

**What would change the recommendation:**

* toward a staged port: `mutual:` implemented with an answer for
  cross-module cycles; a format 2 boundary whose Botlish decode measures a
  few percent of a build; `core::type`/`value`/`decimal` stated once in
  Botlish; the specialized build linear in memory;
* toward abandoning it: the clean-room prototype showing the boundary or
  the verification more expensive than the analysis it carries, or the
  cycle structure needing a module layout that defeats modularity.

## 20. Prioritized PORTABILITY- roadmap

Item 0 is a parallel track: independent of the port, it removes the
largest measured cost of the workload that prompted the question. Items
1-7 are ordered by what each unblocks; item 1 is the most important.
Estimates are rough engineering days for one agent with the repository's
harnesses, assuming no surprises in review; "changes" says which of the
language, the standard library, the compiler or the integration layer
each touches.

| # | milestone | kind | changes | depends on | addresses | precedes because | observable result | acceptance | effort |
|---:|---|---|---|---|---|---|---|---|---|
| 0 | **PORTABILITY-WARNING-GATE-REDUNDANCY-1** | implementation | tests and `audit/refactor/tools/gate.tcl` only | nothing | the motivating workload's cost (section 18) | it is the largest measured saving and makes every later measurement of the gate cheaper | `warning-gate.test` from about 860 s to about 2-3 min in CI | every ratchet case's failure still detected (a planted warning, a closed finding, a drift, an unlisted program, a strict-mode case); the gate's own tests and mutants | 2-3 |
| 1 | **PORTABILITY-MUTUAL-GROUPS-MILESTONE-1** | implementation | language and compiler | nothing | the language blocker (section 5) | nothing else removes it; it also unblocks parsers and state machines | `mutual.bot`'s cycle and the 16-procedure inference-walker shape (`Expr`/`Sequence`/`Block`/`Bind`/`Call`/`If`/...) written as groups | MUTUAL-RECURSION.md's tests; the groups compile and agree on all four backends; a recorded decision, with this census's numbers, on cross-module groups (allowed, or the module structure a port must use for the 82-procedure cycle) | 8-12 |
| 2 | **PORTABILITY-MID-END-CLEANROOM-ANALYSIS-1** | experiment (audit-only code) | none in production; an audit boundary | nothing (an analysis outside the large cycles); 1 for a larger one | boundary cost, duplication, verification (sections 13, 14, 17) | it measures what this census projects before any production commitment | one analysis of section 16 in Botlish, run as a subprocess beside the Tcl analysis on every golden suite | identical facts on every golden suite and the analysis's fuzzer seeds; a mutant of either implementation fails the comparison; the boundary's encode and decode measured in both languages | 6-10 |
| 3 | **PORTABILITY-SPECIALIZATION-VIEW-OVERLAYS-1** | implementation | compiler (`hir/specialize.tcl` and the readers of views) | nothing | the specialized build's quadratic memory (section 11) | needed by any large Botlish program, not only a port | the 32-pass synthetic program's specialized build under 4 GiB | NIR byte-identical on the 238-program corpus November used; the native test files and a GC-stress run | 8-15 |
| 4 | **PORTABILITY-INTERNAL-FAILURE-CONVENTION-CENSUS** | census | none | nothing | section 6's internal failures | every signature of a ported mid-end depends on it | a recommendation: one admitted `CompilerBug` error, or a runtime-error intrinsic, with its interaction with completion proofs and static decisions | a written design checked against the completion and static-decision rules | 2-3 |
| 5 | **PORTABILITY-NATIVE-SMALL-RESULTS-1** | implementation | compiler and runtime | nothing | the allocator factor (section 7): recursive struct results and `match`-bound values are heap objects | roughly doubles a port's factor and speeds every program | `native structs` within 1.5x of `native tables` on the kernel | the struct-representation tests and fuzzers; GC stress; no regression on bench/ | 10-20 |
| 6 | **PORTABILITY-HIR-INTERCHANGE-V2-CENSUS** | census | none | 2 | section 13's boundary | a schema is best specified after a slice of it has been used | a schema per node kind and side table, classified (backend fact, cache, presentation), and a validating reader's design | reviewed against every backend's reads of the HIR | 4-6 |
| 7 | **PORTABILITY-CORE-RULES-AUTHORITY-CENSUS** | census | none | 2 | section 14's duplication | decides whether a staged port is possible without a third implementation of the runtimes' rules | which `core::type`/`value`/`decimal` rules can move to one Botlish statement, and how the Tcl front end and both runtimes would use it | the existing oracle named for each rule | 4-6 |

A staged complete port (strategy C) would follow 1, 3 (or a decision to
stay unspecialized), 4, 6 and 7, and should be decided by a census after 2,
not before.

Smaller items, each worth doing on its own merits and none a
prerequisite: in the Tcl compiler, the two quadratic steps of
unspecialized lowering (section 12) and the inherited body contexts
(section 10); in the library and the analyses the probes exercised, an
index proof that survives a later push (worklists), a mutable element
place for collections of collections, String ordering and a sort, typed
empty collections, `MutableVector.set`, `MutableArray.length`.

**Not recommended now**: a staged complete port (strategy C), a JIT
requirement, a public HIR format, a native library integration.

## 21. Exact reproduction instructions

`audit/mid-end-port/readiness/README.md` lists every command; in short:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
R=audit/mid-end-port/readiness/results; T=audit/mid-end-port/readiness/tools
tclsh9.0 audit/mid-end-port/tools/kernel.tcl -functions 1500 -depth 8 -repeat 5 > $R/kernel-1500x8.txt
tclsh9.0 $T/kernel-grid.tcl -sizes "375:8 750:8 1500:8 3000:8 1500:6 1500:7 1500:9" -repeat 3 > $R/kernel-grid.txt
tclsh9.0 $T/checker.tcl -agree "300:6" -sizes "2000:8 8000:8" > $R/checker.txt
tclsh9.0 $T/mutual.tcl > $R/mutual.txt
tclsh9.0 $T/stdlib.tcl > $R/stdlib.txt
tclsh9.0 audit/mid-end-port/tools/scale.tcl -out $R/scale-frontend-helper.txt -passes "8 16 32 64 128" -generic 1 -native 0
tclsh9.0 audit/mid-end-port/tools/workload.tcl phases > $R/gate-phases.txt
```

**Limits of these measurements.**

* One machine, shared: most long runs had one or two other single-threaded
  measurements beside them (the README says which); ratios and counts are
  each one process's and robust, absolute times move by 10-25 %.
* No historical compiler on this machine (shallow clone): comparisons with
  November are against recorded results on the same kind of container,
  never claimed as causal beyond what the inspected code changes explain
  (the instance walks, the budget, BlockName).
* The call graph's dynamic half covers what 20 programs exercise; its
  static half is a heuristic over command positions. Both are in the
  results so either can be checked.
* The Botlish-side boundary cost and every effort estimate are projections.
