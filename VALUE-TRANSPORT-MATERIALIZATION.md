# Value transport and materialization frontiers

The previous milestone (STRUCT-SCALAR-REPLACEMENT.md) answered *can this
fixed-shape value stay virtual locally, or across one cheap boundary?* This
milestone answers the questions behind it: **for how long** should a value stay
virtual, **where along its path** should it become one physical aggregate, and
**which nested values** should stay bundles and which be opened.

The optimizer no longer asks "can I scalar-replace this struct?". It asks what
the cheapest representation of the value is for each region it must travel
through, from four variables -- *transport distance*, *live width*, *call versus
return direction* and the *nesting frontier* -- with use density as secondary
evidence. Representation is a transport decision.

Every number below is measured, with the tools in
`audit/value-transport-materialization/` (the baseline tree is the completed
scalar-replacement milestone, `b370d52`, built from a `git archive` in a scratch
directory with `native/target` shared; "after" is this tree). Where a decision
is a heuristic weight and not a measured fact, the text says so.

## Outcome

* **Representation is planned over a value's transport path.** A virtual
  struct (or positional product List) is carried as fields only while the whole
  path through its slot -- its exact argument edges, its exact return edges, a
  loop it is carried around -- scores within a budget. Otherwise it becomes one
  physical object **at the point where carrying fields becomes costlier than
  carrying a pointer**: lazily, once, after its cheap local uses, immediately
  before the first expensive edge, and only on the control-flow paths that reach
  it. Eager allocation at construction is never the fallback when a cheaper
  virtual use precedes the expensive one.
* **Distance, width and direction are all inputs.** Distance is counted on the
  exact call/return transport graph (never lexically); width is the number of
  independently transported values (an unopened nested struct is 1); argument
  and return edges have different costs (an argument hop costs
  `W + max(0, W-4)^2`, a return hop `W` above two fields, calibrated against the
  measured stack operands); a loop-carried value costs `3 x W` more and is marked
  cyclic. A width-2 value now crosses ten argument edges or any number of return
  edges as fields; a width-8 value is an object before its first argument edge;
  width 6 crosses three return edges but not three argument edges.
* **Nested structs are a value-tree frontier.** `{a, b, inner: {c, d}}` with
  `inner` only ever projected is opened into one 4-field virtual value: the
  allocation the previous milestone left (one `StructObj` per iteration in the
  nesting probe, 86 ns) disappears (4 ns, zero allocations), at distance 0 and
  across returns and short argument chains. An inner value with an independent
  use (forwarded, stored, compared, returned, bound to a name) stays one field;
  opening one that would widen a long path past its budget is declined.
* **No mechanism was added to NIR, the runtime, HIR or the language.** The
  decisions are made in `hir/escape.tcl` (with the cost arithmetic in the new
  `hir/transport.tcl`) and carried by the existing virtual locals, lazy single
  materialization, `fields` variants and `callmulti`/`retmulti` companions.
  `structnew` still means a real materialization. Core IR, the interpreter, the
  Tcl compiler, the runtime and every `.bot` source are unchanged.
* **The real corpus makes the previous milestone's choices, exactly.** All 17
  canonical programs lower to byte-identical NIR under the new default policy
  and under `-struct-policy legacy` (and to the baseline tree's NIR): 15
  `structnew` (the `Test` values of `test-selection`, stored in Lists), 2
  `structget`, 57 `callmulti`, 50 `retmulti`; the eleven allocation workloads
  have identical allocation counts, bytes, GC cycles and machine code. The new
  model has zero denied slots on the corpus. That is the expected result, not a
  failure: the corpus is dominated by narrow scan returns, 3-field rehash
  argument transport and stored `Test` values. The milestone's value is the
  frontier capability and its evidence.
* **Regression:** `tclsh9.0 tests/all.tcl`: interp 3551 passed, 0 failed; compile 3547 passed, 4 skipped, 0 failed (the same 4 `coreScoping` skips as the baseline), and the same totals under GC stress. The 64 new tests are
  `tests/value-transport.test`; the four old tests that pinned the width-only
  policy now run it explicitly (`-struct-policy legacy`).

## Motivation

The scalar-replacement milestone fixed three width caps (local 16, return 8,
argument 4) because it had to ship a first policy. Its own probes showed why
caps are the wrong abstraction: a width-2 struct carried through eight
argument edges cost 15 -> 22 stack operands and ran 4x faster; an 8-field one
cost 28 -> 224 stack operands over the same eight edges; returns tolerated
widths where arguments did not. A cap on one boundary cannot express "cheap now,
expensive after seven more calls", and it cannot express that a value which is
about to be forwarded through ten functions is better as one pointer *from the
first of them*, while its local uses are best done on registers.

## Starting architecture

Kept as it was (and see "HIR responsibility", "NIR responsibility"):

* descriptors `{N SHAPE}` (SHAPE `{ID LAYOUT}` for a struct, `""` for a
  positional List) as the analysis' fact, now optionally `{N SHAPE CUT}`;
* `UseVerdict`: free / materializing / blocking, with a reason tag;
* virtual locals `{virtual FIELDS SHAPE ROOT MAT}` (now with a `CUT`), lazy
  single materialization with dominance-correct reuse (`MaterializeVirtual`);
* field-wise argument transport (`fields` variants) and return transport
  (`callmulti`/`retmulti` companions);
* the census, now a *transport census*.

`hir::escape` remains the single authority. `hir/transport.tcl` is its
arithmetic (options, scores, SCC summaries); it computes nothing about HIR.

## Terminology

| term | meaning |
|---|---|
| **virtual** | carried as independent compiler values (registers); no object exists |
| **materialization** | building the physical `StructObj`; `structnew` in NIR |
| **transport edge** | one exact call (argument edge) or one exact return (return edge) across which a value is carried unchanged |
| **transport distance** | the number of such edges between where a value is built/opened and where it is consumed or materialized (a local use is distance 0) |
| **transported width** | the number of independently transported physical values at a frontier |
| **live width** | the number of distinct fields actually read downstream of a slot |
| **frontier** | the point where virtual fields become one physical value |
| **cut** | the choice, in a value tree, of which inner aggregates are opened (their fields join the outer value) and which stay one transported value |
| **transport score** | the dimensionless pressure heuristic of a path; compared with a budget. Never cycles. |
| **representation class** | the slots (locals, parameters, results) a value moves between without being rebuilt; they share one transported layout |

## Why boxed/unboxed is insufficient

"Small struct -> virtual, large struct -> object" and "escapes -> allocate, does
not escape -> scalar replace" are both decisions made at the construction. The
measured data say the right answer depends on the path: one 6-field value is
cheaper virtual across one argument edge (-2 stack operands against the
object), neutral at two (+8) and clearly worse at three (+18); the same value is
fine for three return edges (+18 stack operands, +98 code bytes) and a
nested inner struct that is only projected should simply not exist. A physical
bundle can be the optimum -- one pointer over twenty calls -- and a heap
allocation is not a failure. Two further consequences:

* **materialization is a place, not a verdict**: the same semantic value can be
  virtual for its local uses and physical afterwards, and virtual on one branch
  and physical on another;
* **the optimization variable is the cost of carrying the value between
  construction and consumption**, not the number of allocations or pointers.

## Transport graph

Nodes are the slots a value lives in -- parameters, locals (including aliases)
and instance results -- plus the literals/calls that construct it. Edges are
the exact, representation-preserving moves:

| edge | meaning | direction |
|---|---|---|
| argument forward | a `ref` to a slot passed unchanged to an exact callee's parameter | ARGUMENT |
| supply | a literal, a local, or an exact call result handed to a parameter | ARGUMENT (+ the return edges of the call result) |
| return forward | an exact callee's recognized result is an exit of the caller's recognized result | RETURN |
| result consumption | a recognized result read by a caller (`r = f()`, `f().x`, an argument) | RETURN |
| alias / bind | `b = a`, `b = literal`, `b = f()` | none (a local) |

Not edges (natural materialization boundaries): `callvalue`, unknown dispatch,
native calls, closures, storage into Lists/MutableArrays/Sets, equality,
hashing, printing, program results. A callee that receives `{a,b,c}`, uses `a`
and returns `b` ends the original aggregate's transport there: only a `ref`
passed unchanged is a forward; a projection is a consumption and what is built
from it is a new value with a new path.

## Transport distance

Distance is computed on that graph, never from lexical nesting. For a
*parameter slot* `q` the planner summarizes (`hir::transport::Plan`):

* `down(q)` -- the longest argument path out of `q` to a consumption;
* `up(q)` -- the longest argument path into `q` from where a value can first
  become physical (a literal or a local; the nearest slot that could
  materialize), and `ret` -- the return edges at the head of that path when the
  argument is itself the result of an exact call;
* the path through `q` is `up(q) + down(q)` argument edges and `ret` return
  edges, so a slot at the head and a slot at the tail of one chain have the
  same total (they stand or fall together).

Both directions are one graph: a mixed path (construct -> argument into a
helper -> returned from the helper -> argument into a consumer) is a sequence of
direction-labeled edges and accumulates through both summaries. A local
distance is 0; one exact boundary is 1. The distance of a returned value is
the return depth of its instance's exits plus one (`RetTop` for the census,
`DEPTH` for the recognition decision).

## Live width

The transported width of a slot is the number of fields in its descriptor after
the cut: an unopened nested struct counts 1, an opened one its (own, cut) width,
so opening an inner value of width `w` widens the outer path by `w - 1`, and
that feeds the same score. Live width -- the distinct fields read anywhere
downstream of a slot, unioned over its forwarding closure (`used` in `Plan`) --
is computed and reported (census `live`), and enters the score as the use-density
factor (below). It is *not* used to pass a subset of fields: a parameter whose
semantic type is still the whole struct is passed all of it
("no partial-struct ABI"), because evaluation order and effects require every
field expression to run anyway and a partial ABI would be one more physical
variant per live set. A struct that is narrower after a consumer is a **new**
value (the consumer builds it) and has its own, narrower path
(`vt-width-shrinks-with-a-new-value`).

## Direction asymmetry

Distance is symmetric as a fact and asymmetric as a cost. The grid in "Width
experiments" measures, for each width and each of 1..12 edges, the stack
operands and function bytes of the virtual form against the object, in each
direction (`audit/.../out/calibration-grid.md`):

* **argument hop** -- every field is re-passed at every hop and the values past
  the ~4 that stay in registers are spilled, reloaded and re-stored: measured
  extra stack operands per hop **2, 3, 4, 7, 11, 23** at widths **2, 3, 4, 5, 6,
  8**: superlinear;
* **return hop** -- the first two values come back in registers, the rest go
  through memory, linearly: measured **0, 3, 4, 6, 8, 18** per hop at widths
  **2, 3, 4, 6, 8, 12**.

The two are therefore different functions of width, not one factor:

```
hop(arg, W)    = W + argSpill * max(0, W - argRegs)^2         argRegs 4, argSpill 1
hop(return, W) = (W if W > returnFree else 0)
                 + returnSpill * max(0, W - returnRegs)       returnFree 2, returnRegs 8, returnSpill 1.5
```

(`hop(arg)` = 2, 3, 4, 6, 10, 24 and `hop(return)` = 0, 3, 4, 6, 8, 14 at the same
widths.)

## Transport-pressure model

```
path score = (argEdges * argFactor * hop(arg, W)
              + retEdges * returnFactor * hop(return, W)
              + cyclic * cycleFactor * W)
             * density(W, live)

density    = 1 + densityWeight * (1 - live/W)         densityWeight 0.5

budget     = cycleBudget if cyclic, else argBudget if the path has an argument edge,
             else returnBudget                          all 20
```

Every term is a heuristic weight calibrated to a measured fact:

| part | measured fact it is fitted to | status |
|---|---|---|
| `hop(arg, W)`, `hop(return, W)` | stack operands added per hop (grid) | fitted to measurement |
| budget 20 | the physical form's allocation sequence costs ~13 stack operands (intercept of every argument line at 0 edges: -11 .. -14); a budget of 20 tolerates ~7 more than the object. Returns' intercept is 0..-7; the same 20 tolerates 13..20 | heuristic |
| `cycleFactor * W` | stack operands of a loop-carried struct over the physical loop at W = 2, 3, 4, 5, 6, 8: +6, +10, +17, +15, +18, +34 (allocation sequence added back); `3 W` = 6, 9, 12, 15, 18, 24 | fitted |
| `density` | none (secondary evidence; at most x1.5) | heuristic |
| `allocUnits` 13 | the allocation sequence's stack operands, used as the benefit of not building an inner struct | fitted |

The score is "transport pressure": the stack operands it predicts above the
object are a calibration anchor, not a claim -- it is never labeled cycles.
Machine-code evidence for the decisions is in "Machine code".

## Materialized-cost model

The alternative to carrying `W` fields over a path is: materialize once, carry
one word over every later edge, load a field at each projection. The object's
cost is the allocation sequence (the 13 above, and the allocator and GC work
that the runtime numbers show but that the score deliberately does not count),
one word per edge (the `W = 1` hop: 1) and a load per projection. The virtual
path wins while its score is within the budget; the budget is the tolerated
excess over the object, not a break-even, because virtual transport also saves
the allocator and the GC (this runtime's allocation costs ~85 ns). That is
why the isolated runtime is **never** the criterion: the width experiments
repeatedly show hostile wide virtualization running 4-8x faster than the
object (wide-arg W=8 E=8: 40 ns against 100 ns) while using 4x the stack
operands and 1.7x the code.

## Legacy width policy

`-struct-policy legacy` (or `BOTLISH_NATIVE_STRUCT_POLICY=legacy`) is the
previous milestone's whole policy -- local 16, return 8, argument 4 -- kept as
the comparison oracle and as a validation tool, not as a second optimizer: it
runs through the same analysis with the transport arithmetic off. It reproduces
the baseline tree's NIR byte for byte on the corpus and on every probe of this
report (`audit/.../out/` + `legacycmp` check in "Differential modes"). The caps
survive in the new policy as hard safety ceilings (`-struct-local-width` 16,
`-struct-return-width` 16, `-struct-arg-width` 8), configurable.

## New frontier policy

* A **result** is recognized (virtual across returns) only while
  `retEdges * hop(return, W)` over the instance's chain depth stays within the
  return budget (`Arities`, `ReturnVerdict`). Several exact return edges are now
  fine for narrow values; a result whose chain is too long is not recognized, so
  its callers use the canonical (object-returning) function and the object is
  built at the construction.
* A **parameter** slot is denied when the path through it exceeds its budget
  (`TransportPlan`). The caller then materializes before that call -- lazily,
  once, using the existing machinery (`call param`, now tagged
  `transport-budget`) -- and passes a pointer; the denied slot also denies every
  slot that forwards into it (Eligible's own shrink), so the whole chain is
  pointers. Nothing is materialized inside a callee (a per-call allocation), so
  the frontier of a chain is always on the producer's side of an edge.
* A **local** stays virtual for every use that is free (projections, aliases,
  forwards into non-denied slots, branch joins); its first materializing use
  builds the object once and every later use that this scope dominates reuses
  it. A local all of whose uses materialize it is built at construction (it
  would only move the allocation).
* **Nested** values are cut (below).

## Hard versus soft boundaries

Hard (always materialize; the heuristic cannot override them): open calls,
native ABI, dynamic calls, generic value operations needing the object
(equality, hashing, printing), storage in Lists/MutableArrays/Sets, escaping
closure capture, program result, a physical use inside a loop the binding is not
in (to keep one allocation per binding). Soft (the frontier selector decides):
exact argument forwarding, exact return forwarding, local alias, local field
projection, nested projected-only struct, branch merge.

## Path-specific materialization

The lazy single materialization of the previous milestone is the mechanism and
is authoritative; the frontier selector only decides which edges need the
object. `if` branches restore `fn locals` on the way out, so a materialization
inside one branch is never reused on the other (or after the join):

```
r = {8 fields}                       (virtual, projections free)
v = if i >= 100:
        fwd5(r, i)                   <- materialized here, only on this path
    else:
        r.f0 + r.f1
```

`vt-branch-frontier` pins it at run time: with 100 iterations and the long
branch taken on `i >= 90`, the program allocates **exactly 10** `StructObj`s
(and 0 when never taken, 100 when always). Across calls the frontier cannot
differ by branch inside the callee (a parameter never materializes), so a
callee that needs the object on one of its branches makes its parameter
non-virtual and its callers materialize before the call: the conservative
frontier, documented as a limit below.

## Multiple consumers and shared prefixes

One local forwarded to a cheap chain and an expensive one passes fields to the
first and, at the second call, materializes once (`vt-multiple-consumers`:
`cheap` receives 5 field parameters, the long chain 2; one `structnew`). When
several paths share a long expensive prefix, the prefix's slot has the long
path's score, so it is denied and the producer materializes once before the
shared prefix (`vt-shared-prefix`: `head` takes one pointer, one `structnew`),
not once per later path. Two long forwards of one local share the one object
(`vt-materialization-is-single`). No minimum-cut computation is needed or done.

## Recursive and cyclic transport

A slot supplied at a call site that lies on a recursive cycle of the call graph
(a self-tail loop, a non-tail self recursion) is *loop-carried*: its value is
carried around the cycle for an unbounded number of iterations, so its distance
is not a finite number and is not pretended to be one. The slot is marked
cyclic and pays the cycle term (`3 x W`) in addition to its finite argument and
return edges; the cycle budget is 20. In practice a plain loop-carried struct
stays virtual up to 4 fields and a hop or two (the legacy cap was 4, with no
distance), and wider ones are materialized (W=5..8, 200001 allocations in the
probe, as under the legacy policy). The call-graph SCCs are the same linear
Tarjan used for the forwarding graph. Cycles through higher-order calls are
open calls and materialize, as before.

## Nested value-tree model

```
outer
|-- a                          (scalar)
|-- inner1
|   |-- x
|   `-- y
`-- inner2
    |-- p
    |-- q
    `-- r
```

A *cut* chooses which inner aggregates are opened: `{a, inner1*, inner2*}` (width
3), `{a, x, y, inner2*}` (4) or `{a, x, y, p, q, r}` (6). Opening is a decision
per inner aggregate, made once per **representation class**: the slots a value
moves between without being rebuilt (bind, alias, exact argument forwarding,
exact return) are unioned (union-find), so the whole class shares one transported
layout -- a callee has one `fields` form, never a family of layouts. For each
class the planner computes:

1. the **openable** inner values: those that are an *inline* struct literal of
   one shape in every construction that can flow into the class (an inner value
   that is a name, a call result or a field of something else is one opaque
   field: no DAG scalarization);
2. the **independent-use** paths: an inner value is blocked if some
   outermost projection chain in any member slot ends *on it* (`r.inner` as a
   whole: bound, forwarded, stored, compared, returned) rather than continuing
   (`r.inner.c`);
3. the class's worst path (argument edges, return edges, cyclic) from the
   transport summaries.

## Nested frontier algorithm

One greedy pass per class over its openable candidates, outermost first
(`ChooseCut`/`ChooseLevel`). For the candidate with inner width `w`:

```
newW = W + (w - 1)
open  iff  newW <= ceiling(of every boundary the class touches)
      and  score(newW) <= budget
      and  score(newW) - score(W) < allocUnits        # opening must cost less than the allocation it saves
```

then recurse into the opened inner value. At distance 0 the score is 0, so every
projected-only inner value is opened (up to the local ceiling 16); across
edges the widened width is charged `edges x hop`. There is no subset search:
each nested aggregate contributes exactly one decision, the cost is linear in
the size of the value tree. A cut is the flat list `{NAME SUBSHAPE SUBCUT ...}`;
a descriptor with a cut is `{N SHAPE CUT}` (N the *physical* width), and a
literal builds, a projection chain reads and a materialization rebuilds
(inner objects first, with their exact named or anonymous shape) by it.

## Independent nested lifetime

An inner value with an independent use stays one transported field, "however
much else projects it": in `{a, inner: {c, d}}` with `take(r.inner)` anywhere
in the class, `inner` is never opened -- `vt-nested-independent-lifetime`
(`closed:independent-use`, one `structnew` for the inner, three `structget`).
Storing the inner value, comparing it, binding it (`w = r.inner`), or building
the outer from a named inner (`{a, inner: inner}`, shared) are the same.
Materializing an *outer* that has an opened inner rebuilds both objects at the
materialization (`vt-nested-materialization-rebuilds`: two `structnew`, as the
physical form, equal and printed identically, named identity preserved:
`vt-nested-identity`).

## Use density

Recorded per slot as `live` (fields read downstream) against `W`; the score is
multiplied by `1 + 0.5 (1 - live/W)`: a wide value forwarded and almost never
opened scores up to x1.5 and tends to bundle; one whose first consumer uses
most fields scores x1.0. It is secondary: it cannot make a path that is far over
budget fit, and on the corpus it changes no decision.

## Existing owner/storage

Storing a value into an existing physical owner -- List, MutableArray, Set,
closure environment, another materialized aggregate -- remains a hard
materialization boundary (`storage`): `bench/test-selection.bot` keeps its
fifteen `Test` values physical (14 `storage-boundary`, 1 `control-merge`).
**Materializing a semantic struct is not the same as allocating an independent
heap object**: today they coincide (the runtime's `StructObj` is the only
physical form) but a future owner layout that embeds element fields inline would
materialize the semantic struct *into* its owner without any extra box. This
milestone records the distinction in the census (`structnew` is "a materialization
of the semantic struct happens here") and implements no embedding, no inline
`List[Person]`/`MutableArray[Person]` layout and no re-virtualization of an
already-materialized incoming object (it chooses where virtuality *ends*).

## Analysis algorithm

`hir::escape::analyze` (the single authority), in order:

1. `Arities`: instance results, return depth, the return verdict (`transport-budget`);
2. `RawLocalArities` / `RawParamArities`: which slots carry a fixed shape (caller-proven), under the hard ceilings only;
3. `Eligible`: use verdicts, greatest fixpoint (monotone shrink);
4. `TransportPlan`: forwarding graph of the eligible parameter slots, SCCs, longest argument path up/down and the return edges at its head, cyclic marking from the call-graph SCCs, scores, **denied** slots;
5. `Eligible` again with the denied set pre-dropped (a second monotone shrink: dependents fall, nothing is re-admitted);
6. `NestingPlan`: representation classes (union-find), openable/blocked inner values, greedy cut per class, applied to the descriptors the lowering reads;
7. direct projections / projection chains, companion demand, census.

## Convergence / complexity

* **No new fixed point.** `Arities` (growth), `RawParamArities` (growth) and
  `Eligible` (shrink) are the pre-existing ones. The transport pass is a *single*
  evaluation over the eligible graph; its verdicts are final; `Eligible` is run
  once more with the verdict applied (shrink only). Nothing is re-admitted, so
  the planning order cannot produce "callee virtual -> caller virtual -> callee
  physical -> ..." oscillation: costs are computed from one graph, and the second
  shrink only removes.
* **Complexity.** Forwarding SCCs and the call-graph SCCs are iterative Tarjan
  (O(V + E)); longest paths are one pass in topological order each (O(V + E)); the
  cost of a verdict is O(1). Nesting is union-find over slots plus O(tree size) per
  class. Nothing enumerates paths or cuts. A cyclic component is a single node:
  cycles are counted, not unrolled.
* **Determinism.** Every dictionary is iterated in insertion or sorted order;
  `vt-deterministic-planning` lowers a program twice and under explicit
  defaults and requires identical NIR.

## Representation descriptors

`{N SHAPE}` -> `{N SHAPE CUT}`; `hir::escape::arity`/`virtualArity`/
`paramVirtualArity` return the physical `N`, the new `resultCut`/`virtualCut`/
`paramVirtualCut` return the cut; `directRoot` carries the descriptor of a
projection chain rooted at a recognized call. A cut changes the *physical*
layout only: the semantic shape (named identity, anonymous field set, slot
order) is in the descriptor and is what a materialization uses.

## ABI/function variant policy

Per semantic instance, the same four physical functions as before: the
**canonical** function (always), a **companion** (result as `retmulti`), a
**fields** variant (the one planned field-wise form of its parameters) and a
**fields+companion**. A call site chooses canonical or fields per site
(`CanSupplyFields`, binary); cut and frontier choices change the *contents* of a
slot's one descriptor, never the number of descriptors.

### No-combinatorial-variants argument

(a) a variant is keyed by `(instance, mode)` with `mode` in a fixed set of seven
strings; (b) every parameter slot and result has exactly one descriptor, fixed
by its representation class, so there is no per-call-site field layout (call sites
that cannot supply the planned layout call the canonical function); (c) a nested
cut is a property of the class, not of the site: a site with a differently
shaped literal for the same slot simply does not use the fields variant.
`vt-bounded-variants` lowers a program with nested values, three callers of each
function and multiple chains and asserts at most four NIR functions per name;
`vt-one-fields-layout-per-parameter` pins that two call sites with different
inner values still see one parameter layout (5 parameters).

Calling-convention agreement is by construction: the decision to call the
fields variant is made at the site, after the callee's descriptors (physical
width included) are fixed, and a site passes fields only to a variant that
expects exactly that many registers (`TryFields` asserts it; `CanSupplyFields`
returns 0 otherwise).

## HIR responsibility

None changed. Nothing in the source language, types, resolution, `struct` /
`project` nodes or Core IR knows whether a value is virtual, how far it travels
or which cut was chosen (no `.bot` source, no HIR file modified).
`tests/direct-hir-native.test` (native starts from analyzed HIR, never from Core
IR) passes.

## NIR responsibility

Unchanged opcodes: ordinary registers, `fields` variants (`pnames="r.0 r.1"`),
`callmulti`/`retmulti` (`results=N`), `structnew`, `structget`. No virtual
aggregate opcode, no new runtime value, no allocator or GC change (Rust code
untouched; `cargo test --release`: 56 + 22 = 78 passed).

## GC/root handling

Unchanged and sufficient: a virtual value or opened inner is not an object; each
field is an ordinary tagged register rooted by the existing liveness. Opening an
inner value makes its pointer-bearing fields independent roots, each live to its
own last use. A frontier materialization reads registers that stayed live across
the calls before it; its allocation is a safepoint with those operands live.
Pinned under GC stress (a collection at every allocation site): nested virtual
String fields (`vt-gc-nested-strings`), List and MutableArray fields in an
opened inner (`vt-gc-nested-list-mutarray`), a frontier after local use and
several calls (`vt-gc-frontier-after-calls`, `vt-gc-frontier-strings`), a
branch-specific materialization (`vt-gc-branch-specific`), cyclic forwarding
(`vt-gc-cyclic`), materialization of an outer with an opened inner after
safepoints (`vt-gc-nested-materialized-later`); and as standalone executables
with an empty PATH.

## Materialization correctness

Evaluation order is the written order of the (outer, then inner) field
expressions, at the position each is written, whether a value is virtual, opened
or built (`StructFields` evaluates an opened inner literal in place, flattening
its fields in written order); failures and effects propagate as before
(`tick(counter)` is in every fuzzed literal). A value materialized at a later
frontier compares, hashes and prints exactly as one built at the construction
(`vt-late-materialized-is-equal-to-eager`).

## Known limitations

* The frontier of a *chain* is always on the producer's side: a callee never
  materializes its own parameter, so a branch **inside** a callee that needs
  the object on one path makes the parameter non-virtual (its callers
  materialize). Path-specific frontiers exist within a function and across its
  branches, not across call boundaries.
* A returned value that is consumed **directly** by an expensive argument edge
  (no local in between, `fwd(ret(i), i)`) is built at its construction (the canonical
  producer), not at the consumer: carrying fields home first would only add
  return hops to the same allocation (`vt-mixed-direction-accumulates`).
* Equality, hashing and printing still materialize.
* Live width is evidence (score and census) and not an ABI: all fields of a
  forwarded value are passed.
* A shared or computed inner value is one opaque field; no DAG scalarization.
* Zero-field structs are virtual locally and physical across boundaries.
* No re-virtualization of an incoming physical object near its final consumer.
* The score is calibrated to this machine's Cranelift/x86-64 ABI (4 effective
  argument registers, 2 return registers); the knobs exist for that reason.
* `cranelift-generic` (`-specialize 0`) keeps its pre-existing struct limitation.
* The late frontier is not free: in the probe, keeping a wide value virtual
  through local use and then materializing costs more code and stack than
  building it at the construction when the materialization is unconditional (see
  "Late-frontier probe"): its value is where the allocation is placed (after the
  uses, only on the paths that reach the region).

## Canonical corpus census

(`audit/value-transport-materialization/out/census-after.txt`; the same tool
run on the baseline tree gives the baseline rows, `census-base.txt`.)

| | no struct opt | legacy policy | **new default** | baseline tree |
|---|---:|---:|---:|---:|
| `structnew` | 39 | 15 | **15** | 15 |
| `structget` | 52 | 2 | **2** | 2 |
| `call` | 328 | 300 | **300** | 300 |
| `callmulti` | 29 | 57 | **57** | 57 |
| `retmulti` | 18 | 50 | **50** | 50 |
| functions | 231 | 231 | **231** | 231 |
| guards | 59 | 59 | **59** | 59 |
| NIR lines | 6126 | 6042 | **6042** | 6042 |
| machine code bytes | 103751 | 102412 | **102412** | 102412 |

The new default's NIR is **byte-identical** to the legacy policy's and to the
baseline tree's for all 17 programs (`dump-nir.tcl`, `diff -r`, and pinned by
`vt-corpus-identical-nir`). Does the canonical corpus make any new frontier
decision? **No**, and that is the expected result: no slot is denied by the
budget (`deniedParams` 0), no nested value exists to open, no value turns
physical for transport reasons. Of the 39 semantic constructions: 24 are
virtual and never materialized (frontier `never`), 14 are the stored `Test`
values (`storage-boundary`) and 1 the `NotFound` handler's (`control-merge`).

## Field-hop census

Counted from the NIR (an argument hop = one field passed by a `call` to a
function whose parameters are field-expanded; a return hop = one result of a
`callmulti`; a loop hop = one field carried by a self-tail `tail`), summed over
the corpus:

| | virtual constructions | transported field values | argument hops | return hops | loop hops | `structnew` |
|---|---:|---:|---:|---:|---:|---:|
| corpus, new default (= legacy = baseline) | 24 | 52 | 63 | 143 | 18 | 15 |

For comparison the late-frontier probe (W=6, 5 argument edges) is 0 hops under
the default and 30 under `virtual` (every budget raised); the wide-return probe
(W=8, 2 edges) is 16 return hops under both.

## Distance histogram

Virtual and materialized constructions by transport distance (argument +
return edges of the worst path through their slot; `cyclic` separate) and
width bucket, corpus total:

| distance x width | count |
|---|---:|
| 0 x 2 | 15 (the stored `Test` values: no path) |
| 1 x 2 | 4 |
| 2 x 2 | 16 (scan results over two exact returns) |
| cyclic x 3-4 | 4 (the rehash `src`/`dest` groupings, loop-carried by the self-tail scan) |
| 3-4, 5-8, 9+ | 0 |

The real corpus does not exercise distances beyond 2 or widths beyond 4: the new
model is validated by the synthetic probes and tests, not by the corpus.

## Frontier histogram

| frontier | construction | before-first-call | after-local-use | before-long-forwarding-region | storage-boundary | open-call | control-merge | never |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| corpus | 0 | 0 | 0 | 0 | 14 | 0 | 1 | 24 |

(`after local use` is also reported as an attribute of the first-call and
long-region frontiers: `afterLocalUse`.) The synthetic frontier probes populate
the others: `before-long-forwarding-region` with `afterLocalUse` 1 for the
late-frontier probe; `construction` for a wide literal passed straight into
a denied chain.

## CSV control

`csv_geometric` allocates **0** `Struct` objects, as before (also `csv`,
`csv_chunked`, `csv_records`); `callmulti`/`retmulti` transport is unchanged
(`csv`: 12 / 11, `csv_chunked`: 19 / 20, `csv_geometric`: 11 / 9, `csv_records`:
11 / 9); parent-level allocation counts unchanged (`csv_geometric_10000`: 298937
allocations, 13653895 bytes, 7 GC cycles; `vt-corpus-csv-allocation-free`).
The scan results are 2-field returns over at most two return edges: their
return score is 0 (two fields come back in `rax`/`rdx`).

## Hashtable control

The 3-field `src`/`dest` rehash groupings still cross `ht_rehash_scan`
(`pnames="src.0 src.1 src.2 i oldCapacity dest.0 dest.1 dest.2 newCapacity"`, 9
parameters) and `ht_rehash_insert` as fields: 0 `Struct` allocations on all three
hashtable workloads. The model now describes them as *cyclic* (the self-tail
scan carries them around its back edge), width 3, scores 12 and 15 against a
budget of 20: virtual. A 4-field grouping on the same paths would score 16 and 20
(still virtual, as under the legacy cap of 4); a 5-field one 21 and would
materialize, which is the intended behavior for a wider loop-carried group.

## Test-selection control

`bench/test-selection.bot` keeps its **15** `structnew` (14 stored in
`List[Test]`: `storage-boundary`; 1 `control-merge`), `structget` 2: stored
domain values stay physical under every policy
(`vt-corpus-test-selection-control`).

## Long-narrow probe

A 2-field value built at a call site and forwarded through exact calls (`fwd0`
... `fwd{E-1}`, every field read by the last callee). `hop(arg, 2) = 2`, so the
score is `2 E` against a budget of 20: **virtual up to E = 10**, an object
from E = 11. Measured (virtual against the object, stack operands / function
bytes, from the grid): E=1 -9 / -67 B, E=4 -6 / -31 B, E=8 -2 / +17 B, E=12
+2 / +65 B -- the break-even is at E~11, which is where the model changes its mind;
the legacy policy's "argument distance is not measured" would have carried it
further. A simple very-low hop limit would have stopped far earlier. Pinned:
`vt-narrow-long-arg` (E=9: 0 `structnew`, every `fwd` takes 3 parameters; E=10
virtual; E=11 object, `fwd` takes 2).

## Wide-short-return probe

`chainRet W=6/8, E=1..3`: returns cost 6 or 8 per hop (`W`, above the 2
register-returned fields), score `W E <= 20`: **virtual at W=6 for E <= 3 and at
W=8 for E <= 2**. Measured, W=8 E=2: 0 `StructObj`s (200000 -> 0), +76 bytes and
+14 stack operands against the object, 94 -> 11 ns/iter; one `retmulti` of 8
results per function (`ret0:1>8`). `vt-wide-short-return`.

## Wide-long-argument probe

`chainArg W=8, E=4..8`: `hop(arg, 8) = 24` already exceeds the budget at one
edge: **the value is an object from its first argument edge**. Pinned frontier:
`structnew` in the driver (at the call, because the value is built there),
every `fwd` takes **2** parameters (pointer + `k`), the last consumer reads 8
`structget`s: `vt-wide-long-arg`. Measured against forcing it virtual (E=4): the
object costs 1362 function bytes and 55 stack operands, the virtual form 1886 bytes
and 132 (+38% code, 2.4x the stack operands) for 95 -> 20 ns/iter. The census says
why: `class materialized, reason transport-budget, frontier
before-long-forwarding-region, args=4, score 96.0/20.0`.

## Late-frontier probe

The defining test: a wide value, two local projections, then a long forward chain.

```
r = {f0 .. f5}                       # virtual
local = r.f0 + r.f1                  # on registers, no structget
... fwd4(r, i)                       # structnew HERE, one pointer through fwd4..fwd0
```

`vt-late-frontier` (W=6, E=5) pins: exactly 1 `structnew`, in `drive`, **after**
the `iadd` of the two local projections; 0 `structget` in `drive`; every `fwd`
takes 2 parameters; the last consumer 6 `structget`s; value 565 on every
execution. The census record: `class local, mats transport-budget, frontier
before-long-forwarding-region@fwd4, afterLocalUse 1, argEdges 5, score 50.0/20.0,
physical 1`. It is **not** eager construction-time materialization: the
construction does not allocate and the local use does not read memory.

Honest cost note (measured, `late-frontier W=6 E=4`): the object plus
local-register uses costs more code and stack than allocating at the
construction when the materialization is unconditional -- 1440 against 1354
function bytes, 73 against 54 stack operands (six field registers are live until
the call) -- with the same 200000 allocations and the same 96.5 ns/iter. What the
late frontier buys is *placement*: the allocation is after the uses and only on
the paths that reach the region (next probe), and the uses never touch memory.

## Mixed-branch probe

`branchy W=8, E=6`: one branch projects two fields, the other forwards down 6
argument edges. The structnew is in the long branch only: with 100 iterations
and the long branch taken when `i >= 90`, the program allocates **exactly 10**
`StructObj`s (0 if never taken, 100 if always): `vt-branch-frontier`, run
time. Across a call the frontier cannot differ by branch inside the callee (see
"Known limitations"); in that case the conservative frontier is the callee's
parameter being non-virtual.

## Direction comparison

Identical width and distance, different direction (`vt-direction-asymmetry`;
virtual = 0 `Struct` allocations, object = 200000; fn bytes / stack operands from
the key probes):

| probe | argument chain | return chain |
|---|---|---|
| W=6, E=3 | **object** (1114 B, 46 stack; virtual would be +18 stack) | **virtual** (1017 B, 49 stack) -- 94 -> 10 ns |
| W=8, E=2 | **object** | **virtual** |
| W=4, E=6 | object (score 24) | object (score 24): equal at narrow widths |
| W=4, E=4 | virtual (16) | virtual (16) |

The asymmetry is in the *wide* regime, which is where the measurements say it is:
per-hop stack growth 11 against 8 at W=6 and 23 against 8 at W=8.

## Nested-local probe

`outer {a, b, inner {c, d}}`, inner only projected: **0** `StructObj`s
(previously 1 per iteration), 0 `structnew`, 0 `structget`; fn code 740 -> 516
bytes (legacy 608), stack operands 46 -> 25, 163 -> 4 ns/iter (legacy 87).
`vt-nested-local`; `{left{a,b}, right{c,d}}` and a 3-deep
`{a, x{b, y{c,d}}}` likewise 0 (`vt-nested-two-inner`, `vt-nested-deep`).

## Nested-short-return probe

The same value crossing one return: candidates `[a, b, inner*]` (3 results) and
`[a, b, c, d]` (4 results). The planner opens (score 4 against 3, difference
1 < `allocUnits` 13), so `ret0` has `results=4` and `drive` 0 allocations;
`-struct-nesting 0` (and the legacy policy) give `results=3` and one inner
`structnew`. By chain length (`vt-nested-return-budget-chooses`): E=1..5 opened (4
fields x 5 = 20); **E=6: bundled** (opening would score 24 > 20, the closed form
18 <= 20 fits: 6 `callmulti`s, 1 inner `structnew`); E=8: an object (even the closed
form is 24). The default is chosen by score, not by a nesting rule.

## Nested-long-argument probe

`{a, b, inner {c0..c3}}` over argument chains (`vt-nested-long-arg-stays-bundled`):
E=1: opened (7 parameters, 0 allocations); **E=3: bundled** (`closed:transport-budget`:
opened width 6 would score 30 > 20, closed width 3 scores 9; 4 parameters, 1
`structnew` for the inner value); E=2 is the allocation-cheaper rule's
case (opened 20 fits but costs 14 > 13 more than the closed 6, so it is kept
bundled). A narrow inner value is opened across the same long chain (inner width
2, E=4: 5 parameters, 0 allocations). Every inner value is bundled or opened by
the *scores*, none by "nested -> box".

## Legacy comparison

Every focused probe where the new default differs from the legacy
local-16/return-8/argument-4 policy (`out/legacy-comparison.md`; 5 timed runs
per measurement here, the table "Runtime impact" has the 15x3 methodology;
allocations are per 200000 iterations):

| probe | legacy | new default | Struct allocs | field-hops arg+ret | fn code bytes | stack ops | ns/iter (best of 5) |
|---|---|---|---|---|---|---|---|
| narrow-arg W=2 E=12 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1187 -> 1122 | 40 -> 38 | 17.0 -> 96.1 |
| narrow-arg W=2 E=16 | virtual | object (200000 alloc) | 0 -> 200000 | 32 -> 0 | 1443 -> 1330 | 48 -> 42 | 24.8 -> 98.9 |
| wide-return W=8 E=3 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1298 -> 1156 | 61 -> 39 | 13.7 -> 97.7 |
| direction-arg W=4 E=6 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1134 -> 1045 | 46 -> 41 | 12.0 -> 88.9 |
| direction-ret W=4 E=6 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 969 -> 859 | 49 -> 25 | 11.6 -> 89.0 |
| direction-arg W=4 E=8 | virtual | object (200000 alloc) | 0 -> 200000 | 32 -> 0 | 1298 -> 1149 | 54 -> 43 | 14.1 -> 90.3 |
| direction-ret W=4 E=8 | virtual | object (200000 alloc) | 0 -> 200000 | 32 -> 0 | 1115 -> 945 | 57 -> 25 | 15.0 -> 93.8 |
| direction-ret W=6 E=4 | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1108 -> 962 | 55 -> 31 | 12.1 -> 91.5 |
| mixed W=4 R=6 A=6 | virtual | object (200000 alloc) | 0 -> 200000 | 48 -> 0 | 1606 -> 1311 | 76 -> 39 | 20.8 -> 97.0 |
| mixed W=6 R=3 A=2 | object (200000 alloc) | virtual | 200000 -> 0 | 0 -> 30 | 1177 -> 1450 | 43 -> 77 | 93.6 -> 14.8 |
| branchy W=4 E=8 | virtual | object (199900 alloc) | 0 -> 199900 | 32 -> 0 | 1383 -> 1234 | 56 -> 47 | 14.3 -> 89.9 |
| nested-flat4 long-argument | virtual | object (200000 alloc) | 0 -> 200000 | 24 -> 0 | 1129 -> 1040 | 45 -> 40 | 11.5 -> 87.5 |
| nested-inner1 local | object (200000 alloc) | virtual | 200000 -> 0 | 0 -> 0 | 608 -> 516 | 39 -> 25 | 86.7 -> 4.1 |
| nested-inner1 return | object (200000 alloc) | virtual | 200000 -> 0 | 3 -> 4 | 703 -> 600 | 42 -> 29 | 85.8 -> 4.9 |
| nested-inner1 argument | object (200000 alloc) | virtual | 200000 -> 0 | 3 -> 4 | 782 -> 719 | 34 -> 25 | 85.3 -> 6.8 |
| nested-inner2 local | object (400000 alloc) | virtual | 400000 -> 0 | 0 -> 0 | 721 -> 516 | 47 -> 25 | 167.0 -> 4.1 |
| nested-inner2 return | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 763 -> 600 | 41 -> 29 | 165.8 -> 4.9 |
| nested-inner2 argument | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 947 -> 719 | 56 -> 25 | 172.5 -> 7.2 |
| nested-inner2 long-argument | object (400000 alloc) | object (200000 alloc) | 400000 -> 200000 | 12 -> 18 | 1267 -> 1147 | 66 -> 49 | 184.3 -> 94.5 |
| nested-deep local | object (400000 alloc) | virtual | 400000 -> 0 | 0 -> 0 | 730 -> 516 | 46 -> 25 | 163.1 -> 3.9 |
| nested-deep return | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 748 -> 600 | 35 -> 29 | 165.7 -> 4.9 |
| nested-deep argument | object (400000 alloc) | virtual | 400000 -> 0 | 2 -> 4 | 907 -> 719 | 51 -> 25 | 173.1 -> 6.9 |
| nested-deep long-argument | object (400000 alloc) | object (200000 alloc) | 400000 -> 200000 | 12 -> 18 | 1227 -> 1147 | 61 -> 49 | 179.0 -> 92.8 |

Why each group differs:

* **Long narrow or moderately wide chains (`narrow-arg W=2 E=12/16`,
  `direction-* W=4 E=6/8`, `wide-return W=8 E=3`, `direction-ret W=6 E=4`,
  `mixed W=4 R=6 A=6`, `branchy W=4 E=8`, `nested-flat4 long-argument`):** the
  legacy caps never looked at distance, so they carried every value that fit
  *one* boundary through any number of boundaries. The path score exceeds the
  budget (24..32 against 20), the value becomes one object at its construction
  or before the chain. Effects: allocations 0 -> 200000, field-hops 24..48 -> 0,
  function code **-5% .. -18%** (e.g. 1298 -> 1149 B), stack operands **-2 ..
  -37**, runtime 12..25 ns -> ~90 ns (the allocator's cost; the reason this is
  never the criterion). These are exactly the "cheaper to carry a pointer than
  W fields over E edges" cases.
* **`mixed W=6 R=3 A=2`:** the legacy policy refused the argument (6 > 4), so the
  bound local was not virtual and the whole return chain was physical. The path
  model scores the 3 return edges of 6 fields at 18 and, starting at the bound
  local (which can itself become the object), the 2 argument edges at 20: both
  within budget, all virtual. Allocations 200000 -> 0, hops 0 -> 30, code +273 B, stack +34, runtime
  93.6 -> 14.8 ns. A choice in the other direction: the *new* policy keeps *more*
  virtual where the path is short.
* **Nested probes:** the legacy policy never opens an inner value; the cut does.
  Allocations 200000/400000 -> 0 (one per iteration per inner value), function
  code **-8% .. -28%** (e.g. `inner2 local` 721 -> 516 B), stack operands -6 ..
  -31, runtime 85..172 ns -> 4..7 ns. The two long-argument rows keep the inner
  value bundled (only the outer is carried as fields), halving the allocations
  (400000 -> 200000) and the code (-9%).

## Width experiments

The calibration grid (`out/calibration-grid.md`; every cell is the virtual form
minus the object, in stack operands / function bytes; **V** = the default
decision):


arg (V = default keeps it virtual, P = default materializes; cells: delta stack operands / delta function bytes, virtual minus physical)

| W \ E | 1 | 2 | 3 | 4 | 6 | 8 | 12 |
|---|---|---|---|---|---|---|---|
| 2 | **V** -9 / -67 | **V** -8 / -55 | **V** -7 / -43 | **V** -6 / -31 | **V** -4 / -7 | **V** -2 / +17 | P +2 / +65 |
| 3 | **V** -10 / -71 | **V** -8 / -50 | **V** -6 / -29 | **V** -4 / -8 | **V** +0 / +34 | P +4 / +76 | P +12 / +160 |
| 4 | **V** -10 / -61 | **V** -7 / -31 | **V** -4 / -1 | **V** -1 / +29 | P +5 / +89 | P +11 / +149 | P +23 / +269 |
| 5 | **V** -7 / -26 | **V** -1 / +34 | **V** +5 / +94 | P +11 / +154 | P +23 / +274 | P +35 / +394 | P +59 / +634 |
| 6 | **V** -2 / -26 | **V** +8 / +57 | P +18 / +140 | P +28 / +223 | P +48 / +389 | P +68 / +555 | P +108 / +887 |
| 8 | P +11 / +59 | P +33 / +214 | P +55 / +369 | P +77 / +524 | P +121 / +834 | P +165 / +1144 | P +253 / +1764 |

ret (V = default keeps it virtual, P = default materializes; cells: delta stack operands / delta function bytes, virtual minus physical)

| W \ E | 1 | 2 | 3 | 4 | 6 | 8 | 12 |
|---|---|---|---|---|---|---|---|
| 2 | **V** -7 / -93 | **V** -7 / -116 | **V** -7 / -139 | **V** -7 / -162 | **V** -7 / -208 | **V** -7 / -254 | **V** -7 / -346 |
| 3 | **V** -4 / -69 | **V** -1 / -48 | **V** +2 / -27 | **V** +5 / -6 | **V** +11 / +36 | P +17 / +78 | P +29 / +162 |
| 4 | **V** +4 / -40 | **V** +8 / -10 | **V** +12 / +20 | **V** +16 / +50 | P +24 / +110 | P +32 / +170 | P +48 / +290 |
| 6 | **V** +6 / +2 | **V** +12 / +50 | **V** +18 / +98 | P +24 / +146 | P +36 / +242 | P +48 / +338 | P +72 / +530 |
| 8 | **V** +6 / +10 | **V** +14 / +76 | P +22 / +142 | P +30 / +208 | P +46 / +340 | P +62 / +472 | P +94 / +736 |
| 12 | **V** +0 / -55 | P +18 / +80 | P +36 / +215 | P +54 / +350 | P +90 / +620 | P +126 / +890 | P +198 / +1430 |

Reading: the argument table's break-even (stack delta 0) runs from E=11 at W=2
to E~1 at W=6 and never at W=8; the return table's from "never" at W=2 (returns
cost nothing) to E~3 at W=3, E~1 at W=4..6. The default's decision boundary
(budget 20) sits just above break-even in both. Cyclic (loop-carried, W = 2, 3, 4,
5, 6, 8): +6, +10, +17, +15, +18, +34 against the object's allocation sequence
(`out/grid-cyc.tsv`).

## Distance experiments

The same grids read along E: argument transport costs W-proportional hops up to
4 fields (+2, +3, +4 stack operands per hop), then grows (+7, +11, +23); return
transport 0 / +3 / +4 / +6 / +8 per hop at W = 2 / 3 / 4 / 6 / 8. A narrow value
is cheaper than the object over short and medium chains in *both* directions
(W=2 returns: -7 stack operands and -93..-346 bytes at every distance).

## Nesting experiments

(Probe table, `out/probes-key.txt`; fn code bytes / stack operands / ns per
iteration, physical / legacy / new default.)

| probe | Struct allocs p/l/d | fn bytes p/l/d | stack ops p/l/d | ns/iter p/l/d |
|---|---|---|---|---|
| flat4 (control) local | 200000/0/0 | 588/516/516 | 26/25/25 | 83.6/3.9/4.1 |
| inner1 local | 400000/200000/0 | 740/608/516 | 46/39/25 | 162.3/86.7/4.1 |
| inner1 return | 400000/200000/0 | 771/703/600 | 38/42/29 | 162.3/85.8/4.9 |
| inner1 argument | 400000/200000/0 | 909/782/719 | 53/34/25 | 163.4/85.3/6.8 |
| inner1 6-edge argument | 400000/200000/200000 | 1169/1147/1147 | 58/49/49 | 175.7/92.9/94.9 |
| inner2 local | 600000/400000/0 | 810/721/516 | 53/47/25 | 243.4/167.0/4.1 |
| inner2 return | 600000/400000/0 | 837/763/600 | 41/41/29 | 257.4/165.8/4.9 |
| inner2 argument | 600000/400000/0 | 1022/947/719 | 63/56/25 | 255.7/172.5/6.8 |
| deep local | 600000/400000/0 | 811/730/516 | 52/46/25 | 246.7/163.1/3.9 |
| deep 6-edge argument | 600000/400000/200000 | 1267/1227/1147 | 64/61/49 | 264.9/179.0/92.8 |

The flat 4-field control is exactly the cut-opened nested forms' code (516 B,
25 stack operands): opening makes a nested value cost what the flat one costs.
Over the 6-edge chain the width-4 flat value is an object under the default
(score 24), and the nested forms are bundled with only the outer allocated (1
object/iteration against 2 or 3).

## Machine code

(`out/asm/`, `tools/machine.py`; objdump, Intel syntax.) `wide-long-arg`
`fwd1`: default (pointer): 18 instructions, 1 stack operand; forced virtual: 51
instructions, 23 stack operands -- the 9 transported values arrive 5 in
registers and 4 on the stack:

```
mov  QWORD PTR [rsp],r10     ; fields 5..8 stored to the stack argument area
mov  QWORD PTR [rsp+0x8],r11 ;   at every one of the E call sites
mov  QWORD PTR [rsp+0x10],r12
mov  QWORD PTR [rsp+0x18],rdx
...
call botlish_fn_2
```

`late-frontier` `fwd1`: pointer, 18 insns / 1 stack operand against 37 / 11 for
the virtual form; `narrow-long-arg` `fwd4` (W=2): identical under both (21
insns, 2 stack operands: three values in registers). `wide-short-return`
`ret0` (8 results): the first result in `rax`, the other seven stored through a
return-area pointer passed in `rdx` (7 stores): the same under the default and
`virtual`. No new
backend, estimator or Cranelift change; these files only support the choice of
the budgets.

## Register/stack-pressure evidence

| probe | argument count (fn params) | result count | fn code bytes | stack operands |
|---|---|---|---|---|
| wide-arg W=8 E=4: object / virtual | 2 / 9 per `fwd` | 1 / 1 | 1362 / 1886 | 55 / 132 |
| wide-return W=8 E=2: object / virtual | 1 / 1 | 1 / 8 | 1113 / 1189 | 39 / 53 |
| narrow W=2 E=8 arg: object / virtual | 2 / 3 | 1 / 1 | 914 / 931 | 34 / 32 |
| late-frontier W=6 E=4: eager / default / virtual | 2 / 2 / 7 | 1 / 1 / 1 | 1354 / 1440 / 1629 | 54 / 73 / 97 |

Runtime is never reported without these. The stack-operand count is a mechanical
indicator (`[rsp+..]`/`[rbp-..]` operands of the disassembly), not a model.

## Allocation impact

Corpus and workloads: **none** (identical counts; "Benchmark/corpus parity").
Probes: where the default materializes (denied path) the allocation count equals
the physical form's at every iteration; where it opens a nested inner or
accepts a longer virtual path it is 0 against 200000..600000
(`legacy-comparison.md`). Allocated bytes and GC cycles follow (9..27 GC cycles
per probe at 200000 iterations when objects are allocated, 0 virtual; the
tsv columns carry bytes and cycles for every probe and mode). Allocation count is
never the success criterion: `narrow-arg E=12` and `wide-return E=3` are objects
under the default precisely where fewer allocations would cost more transport.

## Code-size impact

Corpus: unchanged (102412 B). Probes (function bytes, the default against the
raised-budget `virtual` form): `wide-arg W=8` E=4 / 6 / 8: 1362 against 1886 /
2300 / 2714 bytes (the default avoids +38% / +57% / +73%); `wide-return W=8 E=3`:
1156 against 1298; `late-frontier W=6 E=4`: 1440 against 1629; nested forms: the
opened form is the smallest (516 B against 740 for the physical form and 608
for the legacy one). `nested-flat4 long-argument` (W=4, E=6): the default object
form is 1040 B, the virtual form 1129 B. Code growth is one of the reasons to
materialize despite faster isolated runtime, and the grids measure it directly.

## Runtime impact

Workloads: best of 15 per round, three interleaved rounds (baseline tree /
after tree in turn), minimum and median over the rounds, microseconds
(`out/workloads-{base,after}-run{1,2,3}.txt`):

| workload | baseline min / med | after min / med | after vs baseline (min / med) |
|---|---|---|---|
| `csv_geometric_100` | 316.9 / 319.0 | 315.8 / 444.3 | -0.4% / +39.3% |
| `csv_geometric_1000` | 4444.1 / 4526.0 | 4412.5 / 4436.0 | -0.7% / -2.0% |
| `csv_geometric_10000` | 52925.8 / 53107.1 | 53646.1 / 53664.3 | +1.4% / +1.0% |
| `csv_records_1000x5` | 2846.4 / 2877.3 | 2837.9 / 2845.0 | -0.3% / -1.1% |
| `csv_records_1000x20` | 12899.1 / 13077.0 | 12938.5 / 13054.0 | +0.3% / -0.2% |
| `csv_records_presized_1000x20` | 11075.9 / 11092.6 | 11280.2 / 11322.1 | +1.8% / +2.1% |
| `csv_records_10000x5` | 35150.8 / 35360.4 | 35110.6 / 35195.6 | -0.1% / -0.5% |
| `csv_records_sample` | 19.1 / 19.4 | 19.3 / 19.3 | +0.6% / -0.4% |
| `hashtable_build_1000` | 292.9 / 292.9 | 292.9 / 294.9 | +0.0% / +0.7% |
| `hashtable_build_10000` | 3163.7 / 3166.9 | 3095.9 / 3130.6 | -2.1% / -1.1% |
| `hashtable_build_50000` | 22005.7 / 22069.1 | 21964.5 / 22024.8 | -0.2% / -0.2% |

NIR and machine code are identical, so any difference is noise (the same
tree's rounds differ by up to ~3%; the one `csv_geometric_100` median outlier,
+39%, is one slow round of the 300 us workload -- its minimum is -0.4%).
Probes: best of 15, three interleaved rounds, ns per iteration, minimum / median
(`out/runtime-probes.txt`), all four modes:

| probe | physical | legacy | **default** | virtual (budgets raised) |
|---|---|---|---|---|
| narrow-arg W=2 E=9 | 93.79 / 94.16 | 12.46 / 12.66 | 13.01 / 13.20 | 12.85 / 13.11 |
| wide-return W=8 E=2 | 90.57 / 92.07 | 10.77 / 10.90 | 10.85 / 10.85 | 10.80 / 10.81 |
| wide-return W=8 E=8 | 101.50 / 102.18 | 24.03 / 24.37 | 100.00 / 101.81 | 24.48 / 24.56 |
| wide-arg W=8 E=4 | 93.51 / 95.71 | 93.89 / 94.80 | 94.81 / 95.01 | 19.75 / 19.75 |
| wide-arg W=8 E=8 | 98.34 / 98.78 | 98.61 / 98.85 | 96.87 / 98.33 | 36.67 / 36.72 |
| late-frontier W=6 E=5 | 95.66 / 95.97 | 95.56 / 95.63 | 94.11 / 95.45 | 17.79 / 17.86 |
| direction-arg W=6 E=3 | 92.57 / 94.87 | 92.75 / 94.67 | 92.68 / 94.39 | 11.53 / 11.60 |
| direction-ret W=6 E=3 | 92.08 / 92.28 | 10.04 / 10.05 | 9.93 / 10.01 | 10.06 / 10.11 |
| branchy W=8 E=6 | 96.33 / 97.16 | 96.57 / 98.27 | 97.10 / 97.40 | 27.96 / 28.08 |
| mixed W=4 R=3 A=6 | 91.02 / 91.72 | 15.73 / 15.85 | 91.29 / 91.79 | 15.58 / 15.76 |
| nested-local | 163.86 / 163.92 | 87.02 / 87.43 | 3.96 / 3.97 | 3.98 / 3.99 |
| nested-return E=1 | 169.06 / 169.23 | 88.03 / 88.67 | 4.87 / 4.96 | 4.86 / 4.91 |
| nested-return E=6 | 175.72 / 176.31 | 96.15 / 96.63 | 96.77 / 98.55 | 11.22 / 11.32 |
| nested-arg inner4 E=3 | 173.33 / 173.44 | 87.01 / 87.13 | 87.80 / 88.76 | 86.36 / 87.69 |

Runtime is one axis: the "virtual" column is fastest on every wide probe and is
exactly what the model declines (the transport columns above are why).

## Compile-time impact

`tools/compile-split.tcl`, 3 rounds x 7 runs per tree, median of the rounds,
milliseconds, whole canonical corpus (baseline tree, then after):

| stage | baseline | after | change |
|---|---:|---:|---:|
| specialization | 374.1 | 367.7 | -1.7% |
| **representation analysis** (`hir::escape::analyze`) | 136.5 | 146.2 | **+7.1%** |
| NIR lowering end to end (includes both above) | 1563.8 | 1606.6 | **+2.7%** |
| Cranelift JIT | 124.2 | 125.8 | +1.3% |

The analysis grows by ~10 ms over 17 programs (the transport and nesting passes
are linear in the eligible slot count; the corpus has 16 planned parameter slots
and no nested values); whole native compile time by under 3%.

## Differential fuzzing

`tools/fuzz.py` (random programs: 2-4 shapes of width 1..9 with 0..2 nested
inner values; return chains of depth 0..9 (forwarding, bound, reshaping,
branching), argument chains of depth 0..10 (forwarding, partially projected,
branching, alias), loop-carried structs, locals, aliases, `if` joins, stores,
equality, hashing, whole inner values taken out, direct chain projections off a
call, side effects in every literal) and `tools/fuzz.tcl` compare the
interpreter and native under six representation modes -- default, legacy,
no-nesting, every budget raised (`virtual`), every budget 0 (`frugal`: every
boundary materializes) and `-struct-opt 0` -- and under GC stress:

| run | programs | compile-skipped (generator type errors) | mismatches | with virtual structs | denied slots | nested values opened |
|---|---:|---:|---:|---:|---:|---:|
| seed 1 (plain) | 25 | 3 | 0 | 16 | 13 | 15 |
| seed 2 (plain) | 200 | 16 | **0** | 143 | 46 | 165 |
| seed 3 (plain) | 150 | 13 | **0** | 116 | 35 | 178 |
| seed 4 (GC stress as well) | 60 | 8 | **0** | 42 | 10 | 56 |

## GC stress

Whole suite with `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempted at every
allocation site; checked effective: a 30000-iteration probe goes from 2 to 60000
collections), final tree (`out/regression-gcstress.txt` is the transcript of the
run, summarized here): interp **3551 passed, 0 failed**; compile **3547 passed, 4
skipped, 0 failed**. This includes every `vt-gc-*` test (nested virtual
String/List/MutableArray fields, a frontier after several calls, branch-specific
materialization, cyclic forwarding, materialization of an outer with an opened inner
after safepoints) and the 64-test file as a whole under stress, and the
differential fuzz run under stress (seed 4).

## Standalone executable parity

`vt-executable-parity`: six programs (nested strings, an opened inner
materialized after safepoints, a frontier after local use and several calls, a
branch-specific materialization, a loop-carried struct, strings through a chain)
are linked as real executables (`native::executable`), run with an empty PATH
plainly and with `BOTLISH_NATIVE_GC_STRESS=1`, and equal the interpreter's value.

## Full regression

| | baseline (`b370d52`) | after |
|---|---:|---:|
| interp | 3487 passed, 0 failed | **3551 passed, 0 failed** |
| compile | 3483 passed, 4 skipped, 0 failed | **3547 passed, 4 skipped, 0 failed** |
| GC stress interp / compile | (previous report) 3487 / 3483 (+4 skipped) | **3551 / 3547 (+4 skipped), 0 failed** |

+64 tests (`value-transport.test`). Four existing tests pinned the *old width-only
policy* and now say so with `-struct-policy legacy`
(`sr-nested-literal-field`, `sr-materialize-wide-return`,
`sr-width-policy-return`, `sr-width-policy-argument`): their expected values are
the previous milestone's, unchanged; the new policy's behavior on the same
programs is pinned in the new file. The baseline run (3487 / 3483 + 4) was
re-taken fresh from a clean `git archive` of `b370d52` (19 min). The
`tests/native-coverage.tcl` census was not re-run for this milestone (no Core IR,
interpreter or backend semantics changed; the new tests are native-only
programs).

Rust (`cargo test --release --manifest-path native/Cargo.toml`,
`out/cargo-test.txt`): 56 + 22 = 78 passed, 0 failed (no Rust code changed).

## Benchmark/corpus parity

`tclsh9.0 bench/bench.tcl -runs 1` (`out/bench-runs1-after.txt`) runs the
canonical programs on every backend and aborts on a value disagreement: it
completed (exit 0). `tclsh9.0 bench/corpus.tcl -runs 1`
(`out/corpus-runs1-after.txt`): every algorithm/input row reports `agree` across
interp, compile, cranelift-generic and cranelift (exit 0). Performance
conclusions in this report come from the dedicated harnesses, not these runs.

## Differential modes

Every focused program in `tests/value-transport.test` is run under the
interpreter, the default, `-struct-policy legacy`, `-struct-nesting 0` and
`-struct-opt 0` (`vtValue`), and the legacy policy is additionally checked
against the baseline tree: for 14 probe programs (narrow/wide, arguments/
returns, late-frontier, mixed, branchy, cyclic W=4/5, nested return/argument) the
NIR text under `-struct-policy legacy` is byte-identical to the baseline tree's.

## Readiness for inline-owner layout / re-virtualization / context struct

Ready: a descriptor with a cut that survives without an object; materialization
as a *place* rather than an allocation (an owner that embeds fields would be
one more frontier kind: `storage-boundary` would become a materialization
*into* the owner); the exact-edge transport graph with direction and cycles; a
census with a distinct frontier vocabulary; calibration tooling. Not done, by
design: inline `List[Person]`/`MutableArray[Person]`, re-virtualization of an
incoming object near its final consumer (the planner chooses where virtuality
*ends*; a mirror pass could decide where it *restarts*), and any source-level
representation hint or "context struct" -- the compiler now infers the ordinary
economics (a wide, long-forwarded value becomes a bundle; a narrow one stays
open) without annotations.

## Answers to the required questions

**Architecture.**
1. *Is representation still decided outside HIR?* **Yes.**
2. *Can one semantic value be virtual in one region and materialized in another?* **Yes** (virtual through local use, materialized before a long chain).
3. *Can two control-flow paths choose different frontier positions?* **Yes within a function** (`vt-branch-frontier`: 10 allocations for 10 long-branch iterations); not across a call boundary inside the callee (limitation above).
4. *Does `structnew` still mean actual materialization?* **Yes.**
5. *Any new runtime aggregate representation?* **No.**

**Distance.**
6. *How is call-graph transport distance computed?* Per parameter slot over the exact-forwarding graph: Tarjan SCCs, then longest argument path up and down in topological order, plus the return edges at the head of the path; per result, the return depth of its exits.
7. *What counts as an argument edge?* An exact call that passes a `ref` to a slot unchanged (or hands a literal / local / call result) to an exact callee's parameter that could receive fields.
8. *A return edge?* An exact callee's recognized result that is an exit of the caller's recognized result, or is consumed by the caller.
9. *How are forwarding chains summarized?* By `(up, down, ret)` per SCC component, one pass each: no path is enumerated.
10. *Recursive cycles?* Marked cyclic (call-graph SCC or forwarding SCC): the cycle term `3 x W` replaces a fabricated distance.
11. *Does lexical nesting affect distance?* **No.**

**Width.**
12. *Transported width?* The number of independently transported physical values (fields after the cut).
13. *Does an unopened nested struct count as one?* **Yes.**
14. *When can width shrink?* When a consumer builds a new, narrower value: that is a new slot with its own path.
15. *Declared or live?* Declared-after-cut transported width drives the ABI; live width (fields read downstream) enters only as the density factor and the census.

**Direction.**
16. *How are they weighted differently?* Different hop functions (argument quadratic spill past 4; return linear past 2) and separate factors/budgets.
17. *What measurements justify it?* The grids (per-hop stack operands 2/3/4/7/11/23 for arguments, 0/3/4/6/8/18 for returns).
18. *An equal-width/equal-distance probe that differs?* W=6, E=3: arguments object, returns virtual; W=8, E=2 likewise.

**Frontier.**
19. *What makes a value materialize before a call chain?* The transport verdict of the callee's parameter (`transport-budget`).
20. *Can it stay virtual for local uses first?* **Yes.**
21. *Can the frontier occur after construction?* **Yes.**
22. *Differently by branch?* Yes, within a function.
23. *Is the materialization reused?* **Yes** (`vt-materialization-is-single`).

**Nesting.**
24. *How is the nested value represented?* As a value tree with a cut `{NAME SUBSHAPE SUBCUT ...}` in the descriptor.
25. *When is an inner struct opened?* Inline literal everywhere in its class, no independent use, widened path within budget and ceilings, opening cheaper than the allocation.
26. *When bundled?* An independent use, a shared/computed inner value, an over-budget or over-ceiling path, or opening not worth the allocation.
27. *How does opening affect width?* `+ (w - 1)`, charged in the same score.
28. *Exponential search?* **No** (one greedy decision per nested aggregate).
29. *Does the old nested-local allocation disappear?* **Yes** (0 allocations).

**Cost model.**
30. *The exact score?* See "Transport-pressure model".
31. *Measured facts versus heuristic weights?* Measured: per-hop stack operands by width and direction, the allocation sequence's stack cost, loop-carried cost. Heuristic: the budgets (20), density weight, `allocUnits` as a benefit, the combination as one number.
32. *Falsely presented as cycles?* **No.**
33. *Audit-configurable knobs?* `-struct-policy`, `-struct-{arg,return,cycle}-{factor,budget}`, `-struct-{local,return,arg}-width`, `-struct-nesting` and `BOTLISH_NATIVE_STRUCT_*`; deeper constants (`argRegs`, `argSpill`, `returnFree`, `returnRegs`, `returnSpill`, `densityWeight`, `allocUnits`) through the analysis' options dict.
34. *Hard ceilings?* local 16, return 16, argument 8 fields.

**ABI.**
35. *Physical function variants per instance?* At most canonical + companion + one fields form + fields-companion.
36. *Can nested choices create combinatorial ABI variants?* **No** (one cut per class).
37. *How does a caller choose canonical vs fields?* Per site, `CanSupplyFields`: fields only if every virtual position can be supplied; otherwise canonical.
38. *Agreement?* Planned before any site is emitted; widths asserted at `TryFields`.

**Probes.**
39. *Width-2 distance-8 argument?* Virtual (score 16..18 <= 20): fields through all hops.
40. *Width-8 distance-8 argument?* Object from the first edge (score 192).
41. *Width-8 distance-8 return?* Object (score 64 > 20): built at the construction, pointers returned (E <= 2 would be virtual).
42. *Wide value with local projections then a long chain?* Virtual through the projections; `structnew` immediately before the chain; one pointer through it.
43. *Nested projected-only local struct?* Opened, 0 allocations.
44. *Nested wide value over a long call chain?* The inner value stays one bundled field (`closed:transport-budget`), only the outer is carried as fields.

**Pressure.**
45-50. See "Field-hop census", "Register/stack-pressure evidence", "Allocation impact", "Code-size impact" and "Runtime impact": argument hops 63 on the corpus (unchanged), return hops 143; stack operands, code bytes, allocations and runtime for each probe are reported together.

**Real corpus.**
51. *CSV scan results allocation-free?* **Yes.** 52. *Rehash wrappers?* **Yes.** 53. *Stored `Test` values?* **Physical (15).** 54. *Any new frontier decision on the corpus?* **No.** The corpus is byte-identical to the previous milestone's.

**Compile time.**
55. *Complexity?* Linear (SCCs, longest paths, union-find, one greedy pass per class). 56. *New fixed points?* None. 57. *SCC handling?* Iterative Tarjan over the forwarding graph and the call graph. 58. *Representation analysis before/after?* 136.5 -> 146.2 ms (+7.1%). 59. *Whole native compile?* +2.7%.

## Architecture note: `hir::escape`

Its responsibilities have clearly become value representation and transport
analysis (descriptors, use verdicts, a transport graph, a cost model, value
trees, a census) with escape analysis proper a small part; a later cleanup
should rename and split it (`representation` / `transport`). It was not renamed
here: one analysis, one authority, `hir/transport.tcl` being only its arithmetic.

## Files

`hir/escape.tcl` (transport planning, nesting, census), `hir/transport.tcl` (new:
policy options, scores, SCC and longest-path summaries), `native/lower.tcl`
(options, cut-aware literals/projection chains/materialization),
`native/native.tcl` (`transportCensus`, `transportCensusText`),
`native/explain-native.tcl` (`transport.txt`), `tests/value-transport.test` (64
tests), `tests/transport-shapes.tcl` (probe generators), four repinned tests in
`tests/struct-scalar-replacement.test`, `README.md`, and
`audit/value-transport-materialization/` (tools, probe programs, measured
outputs). No `.bot` source, HIR, Core IR, runtime or Cranelift code changed.
