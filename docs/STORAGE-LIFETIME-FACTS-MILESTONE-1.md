# STORAGE-LIFETIME-FACTS-MILESTONE-1: backend-independent identity confinement, value liveness and suspension-aware storage facts

The first compiler-analysis milestone STORAGE-STATIC-REUSE-CENSUS-1.md
recommends (its sections 18 and 19): **sound, reusable facts about when
Botlish values and the objects behind them are needed**, computed from
analyzed HIR per specialization instance, independently of how any backend
represents or allocates them. The analysis is `hir/lifetime.tcl`
(`hir::lifetime::analyze`); its evidence is `tests/storage-lifetime.test`
and `audit/storage-lifetime/`.

> A value's lifetime is a semantic fact. Its storage location, capacity and
> reuse strategy are implementation decisions.

**No generated program changed.** No backend reads the facts, no HIR field
was added, no lowering, runtime, library or language rule changed: the
analysis is computed on demand and stored nowhere (section 13).

Evidence is tagged as in the census:

* **[inspection]** -- established by reading implementation code;
* **[test]** -- established by automated assertions (`tests/storage-lifetime.test`);
* **[probe]** -- established by compiling or running a specific program;
* **[measurement]** -- an observed size, count or timing;
* **[inference]** -- a conclusion from established evidence;
* **[design]** -- intended behavior not yet implemented.

Source locations are `file:line` at the branch's head; the branch started
from main at c5b22364 (the census's merge). Toolchain: Tcl 9.0.1, rustc
1.100.0 (the pinned toolchain), gcc 13.3.0, Python 3.13.18, Linux 6.18
x86-64, 4 processors.

## Contents

1. [Executive outcome and acceptance status](#1-executive-outcome-and-acceptance-status)
2. [Starting architecture and census findings](#2-starting-architecture-and-census-findings)
3. [Existing analysis reused](#3-existing-analysis-reused)
4. [New analysis architecture and dataflow model](#4-new-analysis-architecture-and-dataflow-model)
5. [Identity-confinement semantics and result categories](#5-identity-confinement-semantics-and-result-categories)
6. [Ordinary-value liveness](#6-ordinary-value-liveness)
7. [Suspension-aware liveness](#7-suspension-aware-liveness)
8. [Region boundaries and exit handling](#8-region-boundaries-and-exit-handling)
9. [Call, specialization and recursion handling](#9-call-specialization-and-recursion-handling)
10. [Ownership and mutation integration](#10-ownership-and-mutation-integration)
11. [Representation-policy independence](#11-representation-policy-independence)
12. [Source-spelling invariance](#12-source-spelling-invariance)
13. [Fact storage, caching and compilation isolation](#13-fact-storage-caching-and-compilation-isolation)
14. [Fact-report format and examples](#14-fact-report-format-and-examples)
15. [Differential comparison with C Persist](#15-differential-comparison-with-c-persist)
16. [Differential comparison with native GC-stress reachability](#16-differential-comparison-with-native-gc-stress-reachability)
17. [Independent oracle](#17-independent-oracle)
18. [Mutation-testing results](#18-mutation-testing-results)
19. [Census probe results](#19-census-probe-results)
20. [Negative and adversarial tests](#20-negative-and-adversarial-tests)
21. [Analysis scalability and compiler overhead](#21-analysis-scalability-and-compiler-overhead)
22. [Existing regression and CI results](#22-existing-regression-and-ci-results)
23. [Known limitations and conservative cases](#23-known-limitations-and-conservative-cases)
24. [Recommended next implementation milestone](#24-recommended-next-implementation-milestone)

## 1. Executive outcome and acceptance status

The compiler now knows, for every object-producing expression of every used
specialization instance, whether the object can be observed outside its
activation, outside each enclosing loop's iteration and outside its
non-suspending segment -- `confined`, `escapes` (with the path that lets it)
or `unknown` (with the boundary the analysis does not follow); which
bindings and pending operands every path still reads at every program point;
and, for every suspension point, the values and objects that must survive
it. On the census corpus it classifies every program as the census
predicted (section 19); it agrees exactly with an independent oracle on 480
generated programs (section 17); C's frame persistence keeps every value it
says survives a suspension, over 255 frames (section 15); native runs under
GC stress never contradict a confinement claim (section 16).

| # | criterion | status |
|---|---|---|
| 1 | backend-independent HIR analysis reports identity confinement | met: `hir/lifetime.tcl`, per producer and region [test] |
| 2 | proven confinement, demonstrated escape and unknown distinguished | met: three verdicts, each non-confined one with reasons and provenance (section 5) [test] |
| 3 | ordinary-value liveness independent of affine ownership | met: every binding, pending operand, accumulator and loop position (section 6) [test] |
| 4 | values and pending operands live across suspension | met: per suspension point, with what a suspended callee and a child handle hold (section 7) [test, oracle, C differential] |
| 5 | loops, folds, branches, early exits, declared errors, runtime-error edges | met: section 8; undeclared run-time failures are terminal (no edge) [inspection, test] |
| 6 | object, binding and frame-storage lifetimes kept distinct | met: verdicts are per object, liveness per variable, suspension facts per point; no frame layout (sections 5-7) |
| 7 | exact calls and specialization; unresolved calls conservative | met: per instance, its own call targets and summaries; a call through a function value is `unknown` (section 9) [test] |
| 8 | immutable sharing is not exclusive ownership | met: containment follows every alias; an object is confined only when no value outside the region may reach it (section 5) [test] |
| 9 | existing machinery reused without its policy ceilings | met: section 3, section 11 |
| 10 | equivalent spellings, equal conclusions | met for the spellings tested, p17's included (section 12) [test] |
| 11 | census corpus classified and justified | met: section 19 [test] |
| 12 | suspension facts checked against C's frame persistence | met: 0 violations over 255 frames (section 15) |
| 13 | confinement claims checked against native reachability | met: 12 shapes, 0 contradictions (section 16) |
| 14 | independent oracle and adversarial mutation tests | met: sections 17, 18, 20 |
| 15 | deterministic, isolated between compilations, scalable across instances | met: sections 13 and 21; liveness is O(nodes x loop depth), measured |
| 16 | backend output, allocation and language semantics unchanged | met: nothing reads the facts (section 13) |
| 17 | relevant tests and CI pass | section 22 |
| 18 | facts accessible to future storage planners | met: `hir::lifetime::analyze` and its accessors (section 13) |

## 2. Starting architecture and census findings

The census (STORAGE-STATIC-REUSE-CENSUS-1.md, sections 1-3) found
[inspection, probe, measurement]:

* liveness existed per class of value only -- affine bindings
  (`hir::affine`, statement-granular, the binding's own sequence),
  mutable-collection places (`hir::mutvec::NoLaterUse`, operand-order
  precise), construction linearity (a use count) -- and nowhere for an
  arbitrary String, List or struct (G1, G2);
* no HIR fact said which values survive a suspension; the C backend decided
  it on its own generated C (`ccompile::Persist`, a line-order
  approximation), native unfused coroutines keep a whole stack (G3);
* the analyses that prove identity unobserved (`hir/escape.tcl`) are
  representation analyses with width and transport policy, and spelling-
  dependent (p17: 1000 Structs for an explicit `return`, 0 without) (G4);
* nothing said that a `to_string` result never leaves its scope (G5);
* the steady-state opportunity is large: a request handler makes 9
  allocations per request with 6 objects reachable at its worst point.

This milestone closes G1, G2 (for the facts it reports), G3 and G5 as
facts, and does not inherit G4 (section 11). G6 (String size bounds) and G7
(facts crossing calls through function values) stay open by design.

## 3. Existing analysis reused

The implementation census read `hir/affine.tcl`, `hir/mutvec.tcl`,
`hir/escape.tcl`, `hir/transport.tcl`, `hir/construction.tcl`,
`hir/blockescape.tcl`, `hir/stringregion.tcl`, `hir/coroutines.tcl`,
`hir/contexts.tcl`, `hir/borrow.tcl`, `hir/completions.tcl`,
`hir/specialize.tcl`, the HIR data model (`hir/hir.tcl`) and
`ccompile::Persist` [inspection]. What the new analysis takes from them,
and what it does not:

| existing | reused for | not reused, and why |
|---|---|---|
| `hir::children`, the node kinds of `hir/hir.tcl` | the evaluation order of every expression (the CFG's node order) | -- |
| `hir::specialize::analyze` | the units: every used instance, its reachable set, its call map (`calls`), its overlay types and targets (an exact callable parameter's call is direct in its instance) | -- |
| `calleeErrors`, `hir::completions::erasureFacts`, `mayLetErasedThrough` | which calls have an error edge: the same rule `hir::affine::ExitReleases` uses | `ExitReleases` itself: it answers which affine bindings a leaving path releases, keyed by affine scopes; the new analysis needs the edges for every value |
| `hir::mutvec::PlaceArgument`, `hir::mutvec::Path` | which argument of a call is a place mutated in place (a collection operation's receiver, a place parameter's argument), and its root binding | `NoLaterUse`: a per-(binding, point) structural query, quadratic if asked for every value at every point, and blind to pending operands; its control-flow cases (operand order, branches, handlers, later iterations) are what the CFG encodes once |
| `hir::coroutines::MayYield`, `thunkOfHandle`, the `thunks` table | which calls suspend (a yield, a call of a block that may yield: the deep yield effect over exact calls), a handle's thunk, a thunk's boundary call | -- |
| `hir/borrow.tcl`'s `borrows` on a C call | byte storage exposed for exactly one call (no escape) | -- |
| `core::native::metadata`: `resultShape` (`element`, `mutvec-element`, `mutarray-element`), `foreign`, `extern` | a native whose result is an element of an operand (no new object), a C call | names: only the coroutine and context natives (`core::coroutines`'s, `context#install`, `context#load`, `mutable_vector#share`, `affine#register_cleanup`, `list`) are recognized by identity, as `hir/coroutines.tcl` and the affine analysis do |
| `hir::types::kindOf`, `hir::enums::IsPayloadFree` | which values may be or hold an object (an Int, Bool, unit, UnicodeChar, C address or payload-free enum case holds none), and an object's kind | -- |
| `hir/escape.tcl`'s use verdict and slots | -- | it decides representation (virtual or materialized) under STRUCTOPTS' widths and transport budgets, and recognizes constructions by spelling (`Exits`, p17): a semantic fact must depend on none of that (section 11) |
| `hir::affine` ownership states, `Releases` | -- (complementary) | affine-only; an affine move proves a binding unused, not its value dead (section 10) |
| `hir::construction::Linear` | -- | a use count of String/List bindings for construction plans: neither liveness nor confinement |
| `ccompile::Persist` | the differential oracle (section 15) | it decides C's variables on generated C; moving it into HIR would decide the wrong things |

The new information the analysis contributes: liveness of every value at
every point (G1), at expression granularity with pending operands (G2),
suspension live sets in HIR (G3), and per-object confinement for every
producer, not only representation candidates (G5).

## 4. New analysis architecture and dataflow model

`hir::lifetime::analyze HIR ?-spec SPEC? ?-specialize 0|1?` builds, for
every used specialization instance (a *unit*), four things [inspection,
`hir/lifetime.tcl`]:

1. **A control-flow graph in Botlish's evaluation order** (`BuildUnit`,
   `Eval`, `Seq`, `Call`, `Loop`, `Handle`): a node per operation after its
   operands (hir::children's order); per `if` a branch, each arm's sequence,
   a phi per completing arm and a join; per loop its operands once, the
   fold's initial value or the accumulator of a used collecting loop, a
   `start` defining the loop's position, a `head`, a `test` reading the
   persistent operands (the iterable, the bound) and the position, an
   `iter` defining the clause bindings and advancing the position, the
   body, and a back edge (`foldnext` replacing the intermediate, `collect`
   appending to the accumulator, or a plain edge); `break` to the loop's
   exit, `continue` to its head, `return` and the unit's last value to the
   exit, `fail` to the exceptional exit; per `handle` an exceptional edge
   from its own call (only: argument evaluation is not protected -- a
   probe confirmed that in `r = outer(inner(z)):` with `on E1:`, inner's E1
   is UNHANDLED-ERROR) to each handler. A call has an error edge to the exceptional
   exit when its `calleeErrors` or an erased callable may raise (the affine
   analysis's rule) and its handlers do not handle all of them. Dead code
   -- outside the instance's reachable set -- has no node.
2. **Variables**: `b:B` every local binding, parameter, capture, loop
   clause binding, fold intermediate and handler payload; `t:E` the pending
   value of every expression E that is not a constant (`const`) and is
   consumed later; `a:L` a used collecting loop's accumulator; `s:L` a
   loop's position (its index or counter: a value of the loop's own, no
   binding's). A reference reads its binding at its consumer (bindings are
   immutable; a mutable collection's logical copies are explicit after
   `hir::mutvec::Elaborate`). A constant, and a static function (a block
   capturing nothing but static functions, `StaticBindings`), needs no
   storage and is no variable. A module binding read by a function is the
   module's value `m:B` (not the activation's storage).
3. **Liveness** (`Liveness`): a backward bit-vector dataflow, one bit per
   variable (Tcl's arbitrary-precision integers as bit sets), worklist in
   DFS postorder.
4. **Containment** (`Solve`): an Andersen-style inclusion analysis. Objects
   are the unit's producer sites `o:E`, one object per parameter and
   capture `p:B` (the caller's), the received resume message `y`, the
   installed contexts `CTX` and the module-retained values `MOD`. `pts(V)`
   is what variable V may be; `C(O)` what object O may contain (field-
   insensitive). Constraint forms are listed at `hir/lifetime.tcl`'s
   "Containment" header; the solver iterates them to their least fixpoint.

**Escape** (`Escapes`) is everything a sink reaches (`reach` = pts, then
the containment closure): the unit's value or a `return` (`result`), a
`fail`'s payload (`error`), a yield (`yield`), `context#install` or a
store into what a context holds (`context`), a module binding (`module`),
a value the caller owns -- a parameter's or capture's object, which only a
place parameter's mutation can add to (`caller`), `affine#register_cleanup`
(`runtime`), a call through a function value (`unknown`), a C call's
non-borrowed argument (`foreign`), a resume message the coroutine's code may
keep (`message`), a callee's escaping parameter (`callee`, with the callee's
own reason).

**Summaries** (`Summary`, `Summaries`) make exact calls precise: per unit,
which parameters its result may hold (`resultParams`), whether it may be
fresh (`fresh`: an object the callee made, standing for every object it
made and returns), whether it may be a context's or module's value
(`global`), which parameters escape and why (`escParams`), which are stored
into which (`stores`: a place parameter's mutation), into which place
parameters it leaves fresh objects (`freshInto`), whether its captures
escape or reach its result, and whether a resume message may be kept
(`msg`, propagated from yielding callees). Components of the call graph are
computed callees first (Tarjan's algorithm, iteratively); a recursive one
iterates to its least fixpoint from the empty summary, monotone over finite
sets. No budget decides a fact: the internal guards (100,000 solver rounds,
10,000 summary rounds) raise an internal error, never answer.

**The facts** (`Facts`) of a unit then combine the two: a producer's
activation verdict from the escape table; its verdict for each enclosing
loop L from the variables some definition of which is outside L's body (an
enclosing binding, a parameter, the fold's intermediate, the accumulator,
the loop's result) -- if one reaches the object it flows out of the
iteration; its segment verdict from what is live across each suspension
point. A forward "may have been made" analysis (`Made`, one bit per
producer, loop heads seeded with their bodies' producers) removes from
every point the objects not made yet on any path to it: containment is
flow-insensitive (a String pushed into a vector later is in the vector's
contents everywhere), liveness is not, and the filter keeps the
combination sound while removing objects that cannot exist yet.

Every walk that follows the program's nesting -- `Eval` and `Seq` -- carries
the depth guard of `core/deep.tcl` and is listed in
`audit/depth-safe-nesting/census.tsv`; every other walk (the call graph's
components, the CFG's DFS order) is iterative. `audit/depth-safe-nesting/
tools/scenarios.tcl` gained a `lifetime` scenario, so the depth-safe probe
and census put every specimen through the analysis too.

## 5. Identity-confinement semantics and result categories

A *producer* is an expression that may make a new object: a struct
construction, a List literal (`list`) or any native whose result may be or
hold an object (a String, a List, a MutableVector, Bytes, a Float64...), a
closure that captures a value, a coroutine construction, a used collecting
loop's List, `ok`/`error` wrappers, the fresh part of an exact call's
result (`o:CALL`: every object the callee made and returns, fails with or
leaves in a place of the caller's), the result of a call the analysis
cannot resolve, a resume's result. A producer no constraint gives an object
(an exact call whose callee never returns a fresh one) is not reported.

Confinement is a property of the object and of every value that may reach
it, never of the binding naming it: `keep(s)` returns `s` itself (its
summary's `resultParams`), and the caller's `s` escapes when the alias does
(`sl-mut-alias`) [test]. Immutable values are shared freely within a VM, so
nothing is exclusive because it is immutable: a value is confined only when
no path lets any value reach a place observable beyond the region.

Results per producer and region:

* **confined** -- proven: no sink, no value outliving the region reaches
  the object, in this unit or (through summaries) any callee;
* **escapes** -- a path the HIR holds lets it reach one; the reasons say
  which (`result`, `error`, `yield`, `context`, `module`, `caller`,
  `runtime`, `callee: ...`, `carried` for a value that outlives the
  iteration, `suspension` for one live across a suspension, `inherited`
  for a region inside one it already escapes). "Escapes" claims a static
  path, not a dynamically feasible one;
* **unknown** -- it reaches only what the analysis does not follow: a call
  through a function value (`unknown`), a C call without a borrowing
  contract (`foreign`), a coroutine whose code may keep a message
  (`message`).

Each reason carries its category, whether it is definite, the expression it
was established at and a sentence; the report prints them (section 14). No
priority, width or score is attached: a storage planner decides separately
whether a confined object fits a region (the census's distinction between
"confined to this iteration" and "eligible for this scratch region").

**The representation contract.** A native's result may be, or may hold, any
object its operands reach -- a String result too: a construction plan keeps
its pieces until it materializes and a substring region keeps its source
(`hir/construction.tcl`, `hir/stringregion.tcl`) -- and fresh objects of
its own. Only the result's *kind* narrows it: a value of one kind is never
an object of another (`OfKind`: a MutableVector made from a String is not
that String; the oracle found the imprecision this removes, section 17). A
List literal holds exactly its elements; a registered element reader
(`resultShape` element) returns an element of its operand and makes
nothing; a logical copy (`mutable_vector#share`) is a new header over the
same elements.

## 6. Ordinary-value liveness

Every binding, parameter, capture, loop clause binding, fold intermediate,
handler payload, pending result, accumulator and loop position has a bit;
liveness is the backward dataflow over the CFG, joins taking the union of
every successor, exceptional successors included (a handler's reads are
live at its call: `sl-mut-handler`) [test]. Program points are the CFG's
nodes, so sequential temporaries of one statement are distinguished: in
`std::str::length(std::int::to_string(seed)) + inner(seed)` the
`length(...)` result is pending across `inner`'s suspension
(`sl-pending-operand`) [test].

`hir::lifetime::liveBefore FACTS UNIT E` and `liveAfter` decode any
expression's live set on demand; the facts keep the bit sets. Object
liveness is value liveness lifted through containment: at a producer's
node, the objects reachable from the live variables (made before it) are
the objects that coexist with the new one (`coexist`), which gives the
census's interference questions: p01's two temporaries do not coexist, p02's
do, p03's branches never do (`sl-p01-sequential`, `sl-p02-simultaneous`,
`sl-p03-exclusive`) [test]. An earlier object of the same producer still
live when it makes the next (a loop-carried one) is reported as coexisting
with itself.

Dead code makes no requirement (it has no node); a branch condition the
compiler cannot decide keeps both arms (a may-analysis).

## 7. Suspension-aware liveness

A suspension point is a `coroutine#yield` and a call of a block that may
yield (`hir::coroutines::MayYield`). For each, the facts list
[inspection, test]:

* the **bindings** live after it (its live-out minus its own result), which
  includes loop-carried values (a fold's intermediate), values a handler
  needs after the resume (exceptional successors), values read only in a
  later iteration;
* the **pending operands** (`t:E`): values of a partially evaluated
  expression waiting for the suspended call;
* the **accumulators** and **loop positions** live across it;
* what a **suspended callee holds**: the objects of a yielding call's
  arguments, which are in the callee's frame while it is suspended;
* the **objects kept**: everything those reach (a child coroutine's handle
  reaches its frame's contents: `sl-child-handle`), made before the point.

Precision against the census: p07's worker keeps exactly `kept`; p08's
counter its intermediate and its fold's position; p09's outer `seed` across
the first nested call and `first` across the second, inner `base` across
both; **p18's worker nothing** -- `x` is read only in the branch that never
resumes, where C keeps `x` and a join field (section 15) [test].

A value live across a suspension is not thereby escaping its coroutine: the
activation verdict of p07b's `kept` is `confined`, its segment verdict
`escapes` with the reason `suspension` [test]. Conversely an object stored
into a child's handle before a suspension is kept by the handle even when
no binding names it. Handles and frames are not conflated: a coroutine
object is a producer like any other (confined to the iteration of p07b's
`drive`, escaping `make` in p10b), and the frames it denotes have no layout
here.

## 8. Region boundaries and exit handling

Regions are the structured execution model's, never new constructs: the
activation of a unit, the iteration of each loop of the unit (the four loop
kinds, folds included), and the non-suspending segment. Exits are
enumerated per region (`exits`) with the values live after each
[inspection, test]:

* activation: `result` (the last value), `return`, `fail`, `error` (a call's
  unhandled error edge, with its error names), `suspend` (a pause, not an
  end: what is live then must survive);
* iteration of L: `next` (the back edge to L's head), `continue`, `break`
  (to L's exit, or an outer loop's), `return`, `fail`, `error`.

A handled call's handled errors are no exit (`sl-p14-errors`: the program's
only activation exit is `result`); an unhandled declared error is one, of
the activation and of every enclosing iteration (`sl-mut-failing-call`)
[test]. Undeclared run-time failures (`CORE SEMANTIC ...`) are terminal for
the run (EXPLICIT-ERROR-COMPLETIONS.md, "Semantic source fence"): nothing
observes a value afterwards, so they have no edge.

The end of a C block is not a Botlish lifetime's end, and a suspension is
not a reset: an object is segment-confined only when it is dead at every
suspension point after it is made.

## 9. Call, specialization and recursion handling

**Instances.** The units are `hir::specialize::analyze`'s used instances
(the backends' own analysis, default options): each with its reachable
set, its types (the overlay, else the semantic HIR's), its call map and
targets. A parameter has an object only where its key type may hold one
(`same<int>` keeps nothing, `same<str>` returns its parameter:
`sl-specialization`) [test]. An exact callable key makes a call through a
parameter direct in its instance, and the analysis follows it
(`sl-exact-callable`: confined; the same program without specialization,
`-specialize 0`: `unknown`, `sl-mut-unknown-call`) [test].

**Exact calls** apply the callee instance's summary (section 4). A callee
that is a capturing closure is called with its closure value: its captures'
escapes and what it returns of them apply to that value
(`sl-closure-returns-capture`) [test].

**Unresolved calls** -- through a function value, an `any`, an erased
parameter -- let every operand and the callee value escape as `unknown`;
their result is fresh and of no fixed kind (`sl-mut-unknown-call`,
`sl-mut-erased`) [test].

**Recursion.** Botlish has no forward reference (a binding is visible only
after it is established), so a function's own recursion is the call graph's
one kind of cycle among top-level functions; instance chains (a self tail
call widening its key) are cycles of the instance graph. A component
iterates from the empty summary to its least fixpoint (`sl-recursion`: a
recursive function returning its argument is summarized as returning it,
and its caller's String escapes) [test]. No instance budget beyond
`hir::specialize`'s own changes a verdict: a function the specializer keeps
generic is analyzed generic, conservatively.

**Coroutines.** A construction (`coroutine#create`) is a producer holding
its thunk's captures; the thunk unit's summary says whether they escape
through the coroutine's code (`sl-coroutine-capture`: a value the coroutine
yields back escapes the constructing activation) [test]. A resume adds its
message to the handle's objects; when the thunk is known (`thunkOfHandle`)
and no yielding function in its chain lets the received message reach
anything but its own locals, the message stays in the handle; otherwise it
is `unknown` (`sl-mut-message`) [test]. A resume's result is fresh and may
be anything the handle holds.

**Context traits** are monomorphized before this analysis runs
(`hir::traits::monomorphize`): their operations are exact calls.

## 10. Ownership and mutation integration

[inspection, inference]

* **Ownership analysis** (`hir::affine`) decides who may use or move a
  value; **lifetime analysis** (this) where it may still be observed;
  **representation analysis** (`hir/escape.tcl`, construction plans) how
  it is stored; **storage planning** (next milestones) where its backing
  lives. The new analysis reads none of the affine facts: an affine move
  proves that a binding is not used again, not that the moved value is
  dead (its new owner may keep it), and liveness already says when the
  binding's last read is.
* A mutable collection's copy-on-write is respected without modeling it: a
  logical copy is an explicit `mutable_vector#share` after elaboration, a
  new header whose elements are the source's; a mutation stores into the
  objects its place's root binding may be (`hir::mutvec::PlaceArgument`,
  `Path`), so a String pushed into a vector made before a loop escapes the
  loop's iteration (`sl-mut-place-param`, the native shapes `outer-vector`,
  `helper-place`) [test, probe]. A unique backing's in-place mutation does
  not make the collection dead, and nothing here says it does.
* A context's members are never request-local: whatever reaches `CTX`
  escapes (`sl-p11-context`, `sl-p19-context-vector`) [test].
* A C call's byte exposure (`borrows`, `hir/borrow.tcl`) lets nothing escape
  (`sl-p16-borrowed`); FOREIGN-BORROW still refuses a retaining contract
  before any analysis runs (`sl-p16b-refused`) [test].

## 11. Representation-policy independence

No fact depends on a field count, a width ceiling, a transport budget, a
backend threshold or a profitability cutoff: `hir/lifetime.tcl` reads
none of `STRUCTOPTS`, `hir/transport.tcl` or `hir/escape.tcl`. A struct of
a thousand String fields is as confined as a pair (`sl-thousand-fields`)
[test]. An object's size is never asked: a String of unknown length, a List
of run-time length, a collected List are confined or not by their flows
alone (`sl-p15-collections`: `fixed`'s and `dynamic`'s Lists escape their
functions and are confined to the caller's iteration alike) [test]. The only
operational limits are the internal non-termination guards (section 4),
which raise rather than answer.

Existing native heuristics are unchanged; where they differ from the facts
(p17's explicit return, which escape.tcl does not recognize as a result),
the difference is recorded, not fixed (section 12).

## 12. Source-spelling invariance

Equivalent semantic forms give equal facts, compared location-free and
id-free (`slNormalized`: each producer's operation, kind, verdict per
region and reason categories; each suspension's live binding names; the
summary) [test]:

| spellings | test |
|---|---|
| `fn f(i) -> P: return P {...}` and `fn f(i) -> P: P {...}` (p17) | `sl-p17-spelling`, `sl-spelling-return` |
| a nested expression and the same through intermediate bindings | `sl-spelling-nested-flat` |
| a conditional value bound, and the same computed in each arm | `sl-spelling-conditional` |

Natively p17 still makes 1000 Structs for the explicit spelling and none
for the implicit one (the census's measurement; `hir/escape.tcl`'s `Exits`
treats the explicit `return` as a mixed exit): a representation
improvement for every backend that reads escape facts, left to its own
follow-up as the brief asks.

## 13. Fact storage, caching and compilation isolation

The facts are computed on demand and stored nowhere [inspection, test]:

* `hir::lifetime::analyze` is a function of the HIR (and of the
  specialization analysis it is given or computes); it calls `hir::activate`
  first, reads no process state and writes none -- no registry, no memo, no
  HIR field. Two analyses of one program give byte-identical reports, and
  analyzing other programs in between changes nothing; the HIR is unchanged
  by the analysis (`sl-deterministic`, `sl-isolation`) [test].
* Instance facts are per instance: one instance's summary never overwrites
  another's.
* Nothing is cached, so nothing needs invalidating; HIR interchange and the
  front-end cache are unaffected (the facts are derived, never stored).
  `hir/lifetime.tcl` lives in `hir/` and is loaded with it, so it is part
  of the front end's fingerprint (`hir::interchange::Fingerprint` checksums
  every `hir/*.tcl`), which only invalidates caches when it changes.
* No unbounded state accumulates: everything is local to one call.

**How a future backend requests the facts** [design]: call
`hir::lifetime::analyze $hir -spec $spec` with the specialization analysis
it lowers from, then read `hir::lifetime::unit $facts $instanceId` --
`producers`, `verdicts` (site -> region -> verdict and reasons),
`suspensions`, `exits`, `coexist`, `summary` -- and `liveBefore`/`liveAfter`
per expression. Region keys are `activation`, `segment` and
`{iteration LOOP}` with LOOP the loop's ExprId in that HIR. Because the
analysis is not run during ordinary compilation, a backend that does not
ask pays nothing.

## 14. Fact-report format and examples

`hir::lifetime::report HIR FACTS ?UNITS?` (and `audit/storage-lifetime/
tools/report.tcl FILE...`) prints, per unit, its summary, every producer
with its verdict per region and reasons and what it coexists with, every
suspension with what it keeps, and every region's exits with what is live
there. Units are named by function and specialization key, or by what and
where they are (a coroutine's thunk: "the coroutine of worker constructed
at FILE:LINE:COL"); sites by operation and `FILE:LINE:COLUMN`; no time, no
host path, no id that an edit elsewhere changes. The corpus's reports are
`audit/storage-lifetime/results/facts/`.

p07b [probe]:

```botlish
fn worker(seed: int) -> int:
    kept = std::int::to_string(seed).concat(" kept")
    gone = std::int::to_string(seed).concat(" gone")
    yield std::str::length(gone)
    std::str::length(kept)
```

```
unit worker<int>
  summary: keeps nothing it is given
  producer call of std::int::to_string (str) at p07b-string-across-suspension.bot:10:12
    activation: confined
    segment: escapes
      - suspension: it is live across a suspension point
  ...
  producer call of std::str::concat (str) at p07b-string-across-suspension.bot:11:12
    activation: confined
    segment: confined
  suspension yield (call of coroutine#yield) at p07b-string-across-suspension.bot:12:5
    live bindings: kept
    objects kept: call of std::str::concat at ...:10:12; call of std::int::to_string at ...:10:12
  exits of activation:
    suspend at p07b-string-across-suspension.bot:12:5: live kept
    result at p07b-string-across-suspension.bot:9:10: live
unit drive<int>
  producer call of std::int::to_string (str) at p07b-string-across-suspension.bot:18:17
    activation: confined
    iteration of the fold at p07b-string-across-suspension.bot:16:5: confined
    segment: confined
```

The HIR the worker's suspension is computed from (`main.tcl -hir`):

```
e13 bind b8 m : Msg
    e14 call native(coroutine#yield) : Msg
        e15 ref b7 coroutine#yield : native coroutine#yield
        e16 ref b6 dead : int
```

(p07: `dead` is the yield's operand, consumed by it; `kept` is read by the
final `+`, after it; the live set is `{kept}`.)

The report is evidence for people; the facts dict is the interface. A
storage plan (objects, sizes, overlaps, placements) is deliberately not
emitted [design, the next milestone's].

## 15. Differential comparison with C Persist

`audit/storage-lifetime/tools/persist.tcl` compiles each program with the C
backend (`ccompile::program`), reads its manifest's `coroutine_frames`
(each yielding function's frame and the C variables Persist made fields,
`suspension_values`) and checks, for the same instance, that every value
the analysis says survives one of the function's suspension points has a
persistent C representation: a parameter (always a field: the frame is the
calling convention), a binding's variable (`v_NAME_N` for binding bN), a
fold intermediate's `acc<k>`, a counted loop's position and count binding
(its counter `i<k>`), a pending operand's result temporary (`r<k>`,
`n<k>`). The comparison is of semantic availability, not of names: C's own
temporaries (joins `j<k>`, constant bounds `hi<k>`, statuses) have no HIR
binding and are reported as extra, never required [measurement]:

| input | frames | violations | extra fields |
|---|---:|---:|---:|
| census corpus, this audit's cases (c01 a pending operand, c02 branches and loops), the kiosk (`examples/c-freestanding/kiosk`) | 15 | 0 | 9 |
| oracle programs, Ints only (seeds 1-6, 40 each) | 240 | 0 | 338 |

Every extra field is one of: a binding no path reads after a resume (p18's
`v_x_5`, c02's `v_far_5`: Persist's line-order approximation), a join
temporary (`j1`), a loop bound copy (`hi<k>`, also where the HIR's bound is
a parameter, already a field). **p18**: the analysis requires nothing
across the yield; C keeps `x` and `j1` -- 16 of the frame's 40 bytes on
this host (the census's measurement) -- which a later C-backend precision
milestone can drop by bounding Persist with these facts (the census's
C-BOUNDED-STORAGE-MILESTONE-1) [measurement, inference]. The frame was not
changed here.

## 16. Differential comparison with native GC-stress reachability

`audit/storage-lifetime/tools/reachability.tcl` runs, for each of twelve
ways of disposing of a per-iteration String, the program at N = 6 and
N = 30 under `BOTLISH_NATIVE_GC_STRESS=1` (a collection before every
allocation, precise roots) and compares the peak of reachable objects with
the analysis's iteration verdict of the String's producer [measurement]:

| shape | iteration verdict | reachable peak N=6 -> N=30 | outcome |
|---|---|---|---|
| dropped | confined | 1 -> 1 | consistent |
| iteration-vector (a vector of the iteration holds it) | confined | 3 -> 3 | consistent |
| outer-vector (pushed into a vector made before the fold) | escapes | 7 -> 31 | confirmed |
| outer-vector-some (every third iteration) | escapes | 4 -> 12 | confirmed |
| carried (a String intermediate `acc.concat(s)`) | escapes | 2 -> 2 | conservative here |
| struct-dropped | confined | 1 -> 1 | consistent |
| helper-alias (`keep(s)`, dropped) | confined | 1 -> 1 | consistent |
| helper-place (a callee pushes it into the caller's vector) | escapes | 7 -> 31 | confirmed |
| closure-dropped (captured by a closure called once) | confined | 1 -> 1 | consistent |
| context-state (pushed into a context's vector) | escapes | 7 -> 31 | confirmed |
| coroutine-iteration (a coroutine per iteration, holding a String across its suspension) | confined | 3 -> 3 | consistent |
| returned-each (a callee's fresh result, dropped) | confined | 1 -> 1 | consistent |

No confined claim was contradicted. The carried intermediate escapes its
iteration (it is the next iteration's) and still dies one iteration later,
so the count stays flat: escaping one iteration is not living forever.
These runs observe the executed paths and the native backend's roots; they
can contradict a claim, never prove one. No runtime instrumentation was
added: the census's existing allocation report (`peakLiveObjects` under GC
stress) suffices when each program's only per-iteration allocation is the
site under test.

## 17. Independent oracle

`audit/storage-lifetime/tools/oracle.py` (Python; reads no compiler code)
generates programs of a small statement language -- Int bindings, Strings
(`to_string`, concatenation, `keep`), MutableVectors (`from_list`, `push`),
`if` on parameters, folds, yields, early returns -- in two functions: a
coroutine `worker` and a plain `make`. From its own syntax tree it computes
the facts its model of the language predicts: the bindings and fold
positions live after every yield (a recursive model of sequences, branches
and fold iterations), and per producer the verdict for the activation, each
enclosing fold's iteration and the segment, by its own containment closure
and its own "may run before" relation. `fuzz.tcl` compiles every program,
runs the analysis and compares; a value the oracle needs that the analysis
calls dead, or an object the analysis confines that the oracle lets escape,
is UNSOUND [test, measurement]:

| run | programs | suspensions (exact / extra / unsound) | verdicts (equal / imprecise / unsound) |
|---|---:|---|---|
| Strings, seeds 1-12, 40 each | 480 | 1087 / 0 / 0 | 6061 / 0 / 0 |
| Ints only, seeds 1-6, 40 each (+ C differential: 240 frames, 0 violations) | 240 | 1696 / 0 / 0 | -- |

(`audit/storage-lifetime/results/fuzz.txt`; the programs are a function of
the seed.) Exact agreement on these programs is the strongest statement
the comparison allows: the analysis claims nothing the model does not, and
reports nothing the model does not need -- on the oracle's language, which
has no unknown calls, no recursion and no messages (those are covered by
the program mutations of section 20).

The oracle earned its keep twice. Its first runs disagreed where the
compiler was right: conditions like `5 > 8` and `n + 1 > 1` with `n = 0`
are decided by the compiler's range facts, making an arm dead; the
generator now writes only conditions no analysis decides (a parameter's
value). Then it found a genuine imprecision: the generic native rule let a
result *be* any object its operands reach, so a vector made from a String
"was" that String, and a later push into the vector put the pushed String
into the returned String's contents (g2_9). The kind filter (section 5)
removed it, with no change to any confined verdict; `sl-kind-precision`
pins it [test].

## 18. Mutation-testing results

Two kinds of mutation:

* **program mutations** (section 20): each takes a base program with a
  fact (confined, dead across a suspension, not coexisting) and changes it
  as the brief lists; the fact must change to the conservative one;
* **code mutants** of `hir/lifetime.tcl` (`audit/storage-lifetime/tools/
  mutants.txt`, the repository's format, run by `mutate.tcl` on a private
  copy of the tree): each breaks one rule and must be killed by the test of
  `tests/storage-lifetime.test` its `!!` line names (or by the oracle).

The catalog's 26 mutants, each with the rule it breaks; the final run's log
is `audit/storage-lifetime/results/mutants.txt` [test]:

| mutant | breaks | killed by |
|---|---|---|
| handler-edge-dropped | a handled call's edge to its handlers | KILL:handler-edge-dropped |
| exceptional-successors-ignored | live-out joins exceptional successors | KILL:exceptional-successors-ignored |
| error-edge-dropped | a failing call's error edge | KILL:error-edge-dropped |
| handled-errors-kept | handled errors are no exit (precision) | KILL:handled-errors-kept |
| fold-back-edge-dropped | a fold's back edge | KILL:fold-back-edge-dropped |
| position-unread | a counted loop's position is read every iteration | KILL:position-unread |
| pending-unreported | pending operands are reported | KILL:pending-unreported |
| callee-held-ignored | a suspended callee holds its arguments | KILL:callee-held-ignored |
| return-not-a-sink | `return` is a sink | KILL:return-not-a-sink |
| fail-not-a-sink | a `fail`'s payload is a sink | KILL:fail-not-a-sink |
| yield-not-a-sink | a yield is a sink | KILL:yield-not-a-sink |
| struct-holds-nothing | a struct holds its fields | KILL:struct-holds-nothing |
| closure-holds-nothing | a closure holds its captures | KILL:closure-holds-nothing |
| result-params-ignored | a summary's `resultParams` | KILL:result-params-ignored |
| place-store-dropped | a mutation stores into its place | KILL:place-store-dropped |
| unknown-call-trusted | a call through a function value is unknown | KILL:unknown-call-trusted |
| context-state-local | context state escapes | KILL:context-state-local |
| caller-values-local | a caller's values escape the callee | KILL:caller-values-local |
| caller-object-empty | a caller's object stands for its contents | KILL:caller-object-empty |
| messages-trusted | a coroutine may keep a resume message | KILL:messages-trusted |
| thunk-captures-trusted | a coroutine's code may keep its captures | KILL:thunk-captures-trusted |
| recursion-one-round | a recursive component iterates to its fixpoint | KILL:recursion-one-round |
| kind-filter-off | a value is never an object of another kind (precision) | KILL:kind-filter-off |
| iteration-escape-unchecked | a value outliving the iteration makes it escape | KILL:iteration-escape-unchecked |
| made-filter-everything | the may-have-been-made filter removes only what does not exist yet | KILL:made-filter-everything |
| static-closure | an exactly called capturing closure carries its captures | KILL:static-closure |

The catalog found three weaknesses of the first test set, each now a test
of its own: `exceptional-successors-ignored`'s first form changed only the
worklist's predecessor map, an equivalent mutant on acyclic graphs (the
live-out still read exceptional successors), and was retargeted at the
live-out itself; `messages-trusted` survived because the test's kept
message also escaped through the resume's result (`sl-message-kept`
stores it in context state with the result unused); `recursion-one-round`
survived because the recursive function's property was visible in the
first round (`sl-recursion-swapped` swaps its arguments, so only the
second round sees the alias). `static-closure` needed
`sl-closure-returns-capture`. `tools/mutant-catalogs.tcl` applies the
catalog with every other one (114 catalogs, 0 problems).

## 19. Census probe results

Every corpus program classified [test, probe]; the census's expectation
(its section 8) and what deeper inspection established:

| probe | required observation | analysis | test |
|---|---|---|---|
| p01 | consecutive temporaries nonoverlapping | a's String and concatenation do not coexist with b's; all confined to `label` | sl-p01-sequential |
| p02 | coexisting temporaries live together | b's objects coexist with a's | sl-p02-simultaneous |
| p03 | exclusive branches distinguished | the two arms' Strings never coexist | sl-p03-exclusive |
| p04 | per-iteration confinement | the struct and the String are confined to the fold's iteration | sl-p04-loop |
| p05 | a returned object outlives the callee | `make`'s String escapes (`result`); `use_it`'s two results are confined | sl-p05-escape-result |
| p06 | retention through a collection | Strings pushed into the returned vector escape `collect` and every iteration | sl-p06-retained |
| p07 | read after resumption: live | `{kept}` | sl-p07-suspension |
| p07b | String across a suspension | kept's objects escape the segment, gone's do not; `drive`'s String confined to its iteration | sl-p07b-string |
| p08 | independent frames live together | the two coroutines coexist; `counter` keeps `acc` and the fold's position | sl-p08-independent |
| p09 | pending caller state across nested suspension | outer `{seed}`, `{first}`; inner `{base}` twice | sl-p09-nested |
| p10 | moving a handle keeps its obligations | `advance`'s result holds its parameter, nothing fresh; the handle is confined to the run | sl-p10-handle |
| p10b | a returned handle | `make`'s coroutine escapes (`result`) | sl-p10b-returned |
| p11, p19 | context state is not request-local | installed values escape (`context`) | sl-p11-context, sl-p19-context-vector |
| p12 | messages through the library: conservative | the reply struct escapes (yielded to the library's host) and its iteration | sl-p12-actor |
| p13 | per-request confinement | every value `handle` makes or receives is confined to its activation (parse's `Request` escapes parse, as it is its result) | sl-p13-request |
| p14 | every exit assessed | check's payload escapes (`error`), its String not; early's String confined on both paths; check leaves by `fail` and by its end; the program's handled call is no exit | sl-p14-errors |
| p15 | size and lifetime separate | collected Lists escape their functions, confined to the caller's iteration, with or without a declared length | sl-p15-collections |
| p16, p16b | borrowed vs retained | the borrowed Bytes confined; p16b refused (FOREIGN-BORROW) | sl-p16-borrowed, sl-p16b-refused |
| p17 | spelling | equal normalized facts | sl-p17-spelling |
| p18 | HIR finds C's surplus | nothing live across the yield | sl-p18-precision |

No probe contradicted the census's expectation. One refinement from
deeper inspection: p13's census row says "every per-request String and the
Request struct" die before the next request; precisely, the `Request` is
`parse`'s result -- it escapes `parse` and is confined in `handle`, as the
census's p05 distinction predicts (the fresh part of a call is the caller's
producer).

## 20. Negative and adversarial tests

The program mutations of `tests/storage-lifetime.test` [test]:

| mutation | base fact | mutated fact | test |
|---|---|---|---|
| return the object | confined | escapes (`result`) | sl-mut-return |
| store it in an escaping aggregate | confined | escapes | sl-mut-aggregate |
| capture it in a closure that is returned | confined | escapes | sl-mut-closure |
| an alias the caller keeps | confined | escapes | sl-mut-alias |
| move a use across a suspension | dead across, segment-confined | live, escapes the segment | sl-mut-across-suspension |
| add a later read | `{n}` | `{n seed}` | sl-mut-later-read |
| a failing call before the region's end | -- | an `error` exit of the activation and the iteration; the payload's object escapes | sl-mut-failing-call |
| a handler reading a binding | dead at the call | live at the call | sl-mut-handler |
| make two lifetimes overlap | do not coexist | coexist | sl-mut-overlap |
| a loop-carried reference | confined to the iteration | escapes (`carried`), still confined to the activation | sl-mut-loop-carried |
| pass to an unknown call | -- | `unknown` | sl-mut-unknown-call |
| transfer through `any` | -- | `unknown` | sl-mut-erased |
| yield it | -- | escapes (`yield`) | sl-mut-yield |
| store it in context state | -- | escapes (`context`) | sl-mut-context |
| a callee pushing into the caller's vector | -- | escapes the callee (`caller`), the caller's iteration | sl-mut-place-param |
| a resume message the coroutine keeps | confined in the handle | escapes | sl-mut-message |
| a resume message stored into context state, result unused | -- | `unknown` (message) | sl-message-kept |
| recursion that reveals an alias only in its second round | -- | the caller's String escapes | sl-recursion-swapped |
| an actor message | -- | escapes (library) | sl-p12-actor |
| generic specialization with different behavior | -- | per instance | sl-specialization |
| recursion | -- | least fixpoint | sl-recursion |
| deep nesting (300 deep, eight specimen kinds, default limit) | -- | analyzed | sl-depth |
| the depth guard's segments every 3 frames (25 specimens, p12) | -- | the same reports | sl-segment-invariance |

None produced a false confined or false dead result.

## 21. Analysis scalability and compiler overhead

`bench/storage-lifetime.tcl` (results: `audit/storage-lifetime/results/
bench.md`) [measurement]:

BENCH-RESULTS

Observations [measurement, inference]:

* On real programs the analysis is a small fraction of compilation: the
  2048 engine's golden suite (189 units, 3,097 CFG nodes, 767 producers)
  in about 300 ms against 4.3 s of front end; the actor probe (178 units)
  in about 0.4 s against 11.6 s. It is not run by ordinary compilation, so
  a compilation that does not ask pays nothing.
* Straight-line code, many functions and many suspension points scale
  about linearly.
* Liveness is iterative: its rounds grow with the loop nesting depth (the
  conventional bound for iterative bit-vector dataflow, d+2 passes for a
  reducible graph of loop connectedness d), so loops nested 400 deep cost
  O(nodes x depth). The made-before analysis is seeded at loop heads and
  needs one pass; the per-loop outflow is computed once per variable. Real
  programs nest a handful of loops deep.
* No budget limits precision: the same verdicts at every size.

## 22. Existing regression and CI results

REGRESSION-RESULTS

## 23. Known limitations and conservative cases

* **Escapes is a static path.** A branch the compiler cannot decide is
  taken as possible; a dynamically infeasible path still makes an object
  escape. The oracle and the native runs show no imprecision of that kind
  on their programs, but it exists by construction.
* **Containment is field-insensitive and flow-insensitive.** A projection
  reads every field's objects; a value stored into a vector later is in its
  contents everywhere (the made-before filter only removes objects that do
  not exist yet). A fold whose String intermediate is replaced every
  iteration escapes each iteration although each dies one iteration later
  (section 16, `carried`).
* **Native results may hold their operands.** Every String operation's
  result is taken to possibly keep its String operands (plans, regions):
  a concatenation's operands live as long as its result. A backend whose
  String results never share could refine this per native, by registration.
* **Resume messages** are `unknown` once any yielding function of the
  coroutine's chain lets a received value reach anything but its locals,
  returning it included (conservative: a value returned to its sender is
  its own).
* **Calls through function values** carry nothing (G7): every argument is
  `unknown`, unless an instance makes the call exact.
* **Int and C values hold no object.** A BigInt's limbs, a Float64's box
  and a runtime service's storage are a backend's representation; Float64
  values are producers (`float64` kind) only because they are heap objects
  natively, and their facts are the same as any immutable value's.
* **Liveness rounds grow with loop nesting** (section 21).
* **Not done, by design:** no storage plan, no sizes or bounds, no
  interference graph, no allocator, no actor or execution-owner anchor,
  no change to `hir/escape.tcl` (p17) or to C's `Persist` (p18).

## 24. Recommended next implementation milestone

[design, inference] **STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1** on the
native backend, as the census and the brief propose, now with its proof
obligations available:

* candidates: String and List producers whose verdict is `confined` for an
  iteration or an activation (p01, p04, p13, p14 have them; p05's callee
  results are the caller's producers);
* the reset points: the region's exits from `exits` (every `next`,
  `continue`, `break`, `return`, `fail`, `error` edge), never a suspension
  unless the producer is also segment-confined;
* two policies from the start -- opportunistic reuse (heap fallback) and
  strict bounded storage -- neither redefining the facts; a bump region as
  one realization of the plan, never the analysis's foundation;
* its evidence: the census's measurement tools before and after, this
  milestone's native reachability check extended to the scratch region
  (no live root into a region at its reset), GC-stress runs.

Two smaller follow-ups the facts enable: bounding C's `Persist` by the
suspension live sets (p18's 16 bytes; C-BOUNDED-STORAGE-MILESTONE-1), and
escape.tcl's recognition of an explicit trailing `return` (p17).

## Files, and how to reproduce

* `hir/lifetime.tcl` -- the analysis;
* `tests/storage-lifetime.test` -- its tests;
* `audit/storage-lifetime/` -- the tools, cases and results (its README);
* `bench/storage-lifetime.tcl` -- the costs.

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/storage-lifetime.test
tclsh9.0 audit/storage-lifetime/tools/report.tcl
tclsh9.0 audit/storage-lifetime/tools/fuzz.tcl -seeds 1-12 -count 40
tclsh9.0 audit/storage-lifetime/tools/fuzz.tcl -seeds 1-6 -count 40 -strings 0
tclsh9.0 audit/storage-lifetime/tools/persist.tcl audit/storage-static-reuse/cases/*.bot audit/storage-lifetime/cases/*.bot examples/c-freestanding/kiosk/*.bot
tclsh9.0 audit/storage-lifetime/tools/reachability.tcl
tclsh9.0 audit/storage-lifetime/tools/mutate.tcl
tclsh9.0 bench/storage-lifetime.tcl
```
