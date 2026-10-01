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
* **Regression:** `tclsh9.0 tests/all.tcl`: @@REGRESSION@@. The 64 new tests are
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
untouched; `cargo test` 78 + 22 passed).

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
