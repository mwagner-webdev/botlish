# OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md

Recursive affine ownership decided on the finite declaration graph, instead
of a walk of applied field types bounded at 64 fields deep and 4096 types.

> Whether a type has recursive affine ownership is a finite property of the
> declaration graph, its ownership edges, and how its type slots carry
> affinity. It does not depend on how many concrete applications the
> compiler manages to unfold.

## Contents

1. Result
2. The starting rule
3. The starting implementation
4. Architecture census
5. The finite ownership model
6. Ownership edges
7. Slots and transformations
8. Affinity integration
9. Uniform, phantom, non-uniform and intrinsic recursion
10. Deep finite affine types
11. Drop descriptors
12. Diagnostics
13. Written, inferred and imprinted parity
14. Old and new
15. The independent oracle and the fuzzer
16. Mutation testing
17. Performance
18. HIR, interchange, isolation
19. Regression and CI
20. Remaining recursive walks
21. Limitations
22. Next milestone

## 1. Result

`hir::structs::OwnedRecursion` is now `hir::ownership::Recursion`
(hir/ownership.tcl): a verdict computed on the graph of *declaration
states* -- a declaration and the set of its slots whose arguments are
affine -- from three finite facts per declaration and one root walk of the
type asked about. No depth, budget, type size or applied-type bound decides
a verdict any more; `recursionDepth 64` and `recursionBudget 4096` are gone,
and so is the `unbounded` verdict and its message.

What became threshold-independent, and what else changed:

* A finite affine type of any depth is accepted: a chain of 65, 96, 128 or
  2100 plain structs ending in a coroutine handle compiles and runs, every
  handle released exactly once, on every backend (the old walk rejected
  everything past 64 fields as "nests applications ... in ever larger
  types"). Its verdict visits N + 1 states.
* A recursion is found however deep it starts: `Node[C]` wrapped in 400
  `Box`es, or reached through a chain of 100 parameterized declarations, is
  rejected; the same chain ending in `v: T` is accepted.
* Three defects of the old walk's *shape* (not of its bound) are fixed, each
  found by the new fuzzer or by stating the rule first (section 14):
  - it looked only for recursion back to the root's own declaration, so
    `Holder[Coroutine{...}]` of `struct Holder[T]: t: Node[T]` was accepted
    and the drop descriptor builder then stopped at its internal assertion
    ("internal compiler error: ... has no finite drop descriptor");
  - it took any reappearance of the root's declaration below a container for
    recursion, so `Box[List[Box[Coroutine{...}]]]` and
    `Many[Many[Coroutine{...}]]` -- finite nestings the type's own arguments
    spell -- and `Swap[int, Coroutine{...}]` of `next: List[Swap[U, int]]`,
    whose affinity dies out after two levels, were rejected;
  - on a declaration whose applications double at every level (`f0:
    D0[D0[U, T], List[T]]`) its types grew exponentially before the depth
    bound tripped: the old compiler ran out of memory ("unable to alloc") on
    a seven-line program writing `D0[Coroutine{...}, int]`. The new one
    rejects it in 83 ms.
* The shared declaration-summary fixpoint (`hir::summaries::Fixpoint`) had
  a latent defect the fuzzer exposed: a declaration first met in a later
  round, when nothing else changed in that round, was never computed and
  kept its bottom fact. No property before this one could meet a
  declaration late (each node walks every field type in full); the through
  facts can, and the fix -- a round that meets a declaration is followed by
  another -- changes nothing for the others (`fixpoint-never-revisits`, the
  declaration-summaries mutant of that loop, is retargeted and still
  applies).

Unchanged: `Node[Coroutine{...}]` and every genuine recursive affine
ownership (uniform, mutual, non-uniform, intrinsic, through a MutableVector
or MutableArray, through a pointer-holding struct) stays
AFFINE-CONTAINER-UNSUPPORTED; `W[Coroutine{...}]` and
`PhantomRec[Coroutine{...}]` stay ordinary unrestricted types; container
policies, pointer, function-type and slot-position semantics, the
affinity summary, Totality, Hashable and SendClass are untouched; no syntax,
runtime representation, NIR operation or HIR, interchange or cache format
changed.

## 2. The starting rule

Read from the code (hir/structs.tcl's `OwnedRecursion`, hir/affine.tcl's
`Descriptor`), the tests (affine.test's `af-recursive-container-rejected`,
affine-applications.test's `aa-recursion-white-box`,
`aa-declaration-through-slot`, tree-struct.test's `ts-decl-affine`,
written-affine-applications.test's `wd-recursive-rejected`,
parameterized-declaration-summaries.test's `pds-owned-recursion-kept`) and
documents (AFFINE-VALUES.md, AFFINE-PARAMETERIZED-APPLICATIONS-CORRECTNESS-
MILESTONE-1.md, WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md), the rule *as
stated* is:

> An affine value is released by a static drop descriptor, a finite walk of
> its type. A type whose values nest to any depth through a List,
> MutableVector or MutableArray, each level owning an affine value, has no
> such walk: it is a recursive affine type, AFFINE-CONTAINER-UNSUPPORTED,
> wherever it is declared, written or made. An unrestricted struct may hold
> itself in a container; an affine struct may name itself through plain
> fields (no finite value has such a type).

Distinguished:

| form | example | stated rule |
|---|---|---|
| recursive nominal reference | `struct Tree: kids: List[Tree]` | fine: unrestricted |
| recursive value ownership | `struct Tree[T]: v: T, kids: List[Tree[T]]` at int | fine: owns nothing affine |
| affine recursive ownership | the same at `Coroutine{...}`; `struct R: handle: C, kids: List[R]` | rejected |
| non-uniform type application | `next: List[W[List[T]]]` | fine unless values of T are held (then affine recursion: GrowA/GrowB) |
| phantom recursion | `PhantomRec[T]: next: List[PhantomRec[List[T]]]` | fine: no value holds T |
| pointer/pointee recursion | `p: Ptr[T]` | the pointee is an identity, never owned; a pointer in every level (`p: Ptr[Void], kids: List[P]`) is an affine root owned at every level: rejected |
| recursion through fields alone | `struct S: c: C, s: S` | fine: no finite value |

## 3. The starting implementation

`OwnedRecursion TYPE` walked TYPE's ownership components (applied fields,
anonymous struct fields, List/MutableVector/MutableArray elements, affine
types only) depth first, carrying a `crossed` flag, and answered
`{recursive PATH}` on meeting an application of the *root's declaration*
after crossing a container; `""` on meeting the root type itself through
fields alone; and `{unbounded PATH}` once its path passed 64 fields or it had
visited 4096 (type, crossed) pairs. It ran on every affine application:
`apply` (each declaration at its own slots), `ApplicationIssue` (every
application a parameter, result, construction, explicit imprint, field,
payload or imprint binding holds), `WrittenProblem` (every written
application) and the drop descriptor's assertion.

The false rejection the bound made: a finite affine type 65 fields deep.

```
struct S0: next: S1        ...        struct S95: next: S96
struct S96: c: Coroutine{args: [], return: int}
```

was rejected: `struct "S0" is affine and its fields nest applications of
parameterized structs in ever larger types (S0.next: S1, S1.next: S2,
S2.next: S3, ...): a recursive affine type is not supported`. (At 60 it was
accepted.)

## 4. Architecture census

Every caller of the verdict and everything downstream that relies on a
rejected type never reaching it:

| place | what it asks | when |
|---|---|---|
| `hir::structs::apply` | a declaration at its own slots (unrestricted) | registration; AFFINE-CONTAINER-UNSUPPORTED at the first field of the path |
| `hir::structs::VerifyDeclarations` -> `ApplicationIssue` | every application in a struct field's or an error payload field's type | after registration |
| `hir::types` (Struct typing) -> `ApplicationIssue` | an inferred or written construction's application (`structApplicationProblem`) | inference |
| `hir::structs::verifyApplications` -> `ApplicationIssue`/`ApplicationProblem` | a block's declared parameter and result types, a call's explicit imprints | after inference |
| `hir::imprint::Bind` -> `ApplicationProblem` | every application of an imprinted signature, the binding substituted | at each call |
| `hir::resolve::ResolveApplied` -> `WrittenProblem` | every written application (innermost first: arguments resolve before their application) | resolution |
| `hir::affine::Descriptor` | its assertion at a cut, and now the repeat guard | every drop descriptor |

Downstream of the verdict, assuming a rejected type never reaches them: the
drop descriptor (`hir::affine::Descriptor`, `DropPlan`, `PlanOf`), its
users -- release plans and exit releases (hir/affine.tcl), affine field and
collection ownership (hir/mutvec.tcl's collection descriptors), native
release lowering (native/lower.tcl), the runtimes' drop walks
(core/affine.tcl, native/src/runtime/affine.rs) -- and semantic instances
and imprinted applications, which ask through `ApplicationProblem`. The
chain: *verdict (finite) -> the type is admitted -> Descriptor builds its
finite descriptor -> every release of the type runs that descriptor.*

## 5. The finite ownership model

Stated over a type's ownership unfolding (its applied fields, anonymous
struct fields and container elements, affine components only):

> **A type is a recursive affine type iff its unfolding has an infinite
> path that crosses a container element infinitely often.**

A path that eventually stays in plain fields describes no finite value
(every field is mandatory), so it is no recursion of values; this is the
stated rule's "an affine struct may name itself through plain fields".

Why it is finite. The unfolding is infinite whenever a declaration recurses,
and its types are all distinct when the recursion is non-uniform. But every
type in it is a declaration's field type with an enclosing application's
arguments substituted. Walking it is a pushdown walk over the declarations'
field types: entering an application `S[e]` *pushes* a frame (S, its
arguments); reaching one of S's own slot variables in S's fields *pops* back
to that argument expression in the frame below. Within a frame the position
only moves deeper into a finite field type, and a pop returns to a deeper
position of the frame below, so an infinite path cannot keep a bounded
stack: it pushes frames it never pops, infinitely often (the "repeating
heads" argument for pushdown automata). Abstract a frame by its declaration
and the set of its slots whose arguments are affine, `(S, A)`: two
never-popped frames of one state, the later inside the earlier, close a cycle
of a finite graph, and the path crosses elements infinitely often exactly
when such a cycle does. On a cycle every state owns every other, so all or
none are affine. Hence the criterion the compiler implements:

> **TYPE is a recursive affine type iff, from TYPE, a cycle of the state
> graph that crosses an element through affine states is reachable.**

It explains the four specimens without a bound:

| type | why |
|---|---|
| `Node[C]` | state (Node, {0}) is affine (`value: T`) and `children: List[Node[T]]` is an edge to itself that crosses: reject |
| `W[C]` | state (W, {0}) is not affine (no field holds T): nothing affine to recur; accept |
| `GrowA[C]` | (GrowA,{0}) -> (GrowB,{0}) through `List[GrowB[List[T]]]` (crosses; `List[C]` is affine) -> (GrowA,{0}) through `a: GrowA[T]`; GrowB holds T: reject |
| a 96-deep chain | 97 states in a line, no cycle: accept |

Stated with the facts below, `Recursion` is: walk TYPE once (its pushes and
what it holds through its applications' slots), classify every state
reachable from those pushes into strongly connected components (iterative
Tarjan, every classification remembered per state), and answer recursive
when a reachable component has an internal edge that crosses. A state of no
affinity owns nothing affine, so it is never explored (and nothing it would
reach can be affine).

The graph is the declarations': at most 2^n states for a declaration of n
slots (n <= 2 everywhere in the repository), whatever applications
substitution makes. The facts are kept per registry and forgotten with the
affinity facts (`hir::structs::ForgetAffinity` -> `hir::ownership::Forget`),
keyed by declaration identity.

## 6. Ownership edges

The edges are the drop descriptor's components, so the verdict speaks about
exactly what a release walks:

| form | edge |
|---|---|
| named struct field (an application's: its arguments substituted) | owned, field |
| anonymous struct field | owned, field |
| List, MutableVector, MutableArray element | owned, **crosses** (an element may be absent: finite values of every depth exist) |
| a refinement | its base |
| coroutine handle | an affine root, owns nothing further |
| C pointer `Ptr[T]`, `FnPtr[...]` | an affine root; the pointee is an identity, never owned |
| function or coroutine type | owns no value of its signature |
| ImmutableSet | holds no affine member (AFFINE-CONTAINER-UNSUPPORTED for one) |
| enum, scalar, `any`, trait view | nothing |

Container policy is unchanged: whether a List, MutableVector or MutableArray
may hold affine elements is the containers' own rule; this milestone only
says when their nesting is recursive.

## 7. Slots and transformations

Two facts per declaration, from its field types with its slots as
variables:

* **through(S)**, for each slot j: whether S holds slot j's argument at an
  owned position through fields alone (0) and/or through a container element
  (1). It is a least fixpoint over the declarations (`Through`, the shared
  `hir::summaries::Fixpoint`): S may hold its slot through another
  application, or through itself (`Node[T]`'s children hold T too, crossing).
  It is a *matched* push and pop: an application S[e] that holds its slot j
  makes what e_j holds held in the enclosing frame.
* **edges(S)**: the applications S's fields hold at owned positions in S's
  own frame -- through anonymous structs, container elements and the
  through facts of the applications they pass -- each with its argument
  expressions over S's slots and whether the way to it crossed (`Edges`).

A slot transformation is an edge's argument expressions: `GrowA[T]`'s edge
`List[GrowB[List[T]]]` maps slot T to `List[T]`. The successor state's
affine set is computed by substituting an affine probe (`coroutine`) for the
slots in A and `any` for the others into each argument expression and
asking `hir::types::IsAffine` -- so `List[T]` stays affine, `Fn{args: [T]}`
does not (FnArg's edge to `FnArg[Fn{args: [T]}]` reaches an unrestricted
state). Mixed[A, B] keeps its owning slot (A) and phantom slot (B) apart
because the state records which slot is affine, not "some argument is":
`Mixed[C, int]` is (Mixed, {0}), affine, recursive; `Mixed[int, C]` is
(Mixed, {1}), unrestricted.

The facts are property-specific: through(S) is neither the affinity
summary's relevant slots (a slot can be held without making S affine
through it -- a declaration affine by its own field holds its slots too) nor
the slot positions (`SlotPositions` counts a Fn type's argument as a value
position for imprinting; ownership does not).

## 8. Affinity integration

A state's affinity is `hir::structs::IsAffine ID PROBES`, the affinity
summary itself (base affinity or a relevant slot's affine argument), with
the state's probes as arguments. Nothing restates what is affine. Own
affinity matters: `struct R: handle: C, kids: List[R]` has no slot, its one
state is affine by its declaration, and its edge to itself crosses: rejected
at the declaration. An affine declaration with an unrelated unrestricted
recursion (`HoldsUnrelated: c: C, tree: Unrelated`) is accepted: the tree's
states are unrestricted and never explored.

## 9. Uniform, phantom, non-uniform and intrinsic recursion

`tests/owned-recursion.test`'s `or-specimens`, `or-declarations`,
`or-written`:

| specimen | verdict |
|---|---|
| `Node[C]` (uniform) | recursive |
| `Node[int]` | finite |
| `W[C]`, `PhantomRec[C]` (phantom, growing) | finite (unrestricted) |
| `Mixed[C, int]` / `Mixed[int, C]` | recursive / finite |
| `GrowA[C]`, `GrowB[C]`, `GrowA[List[C]]` (non-uniform mutual, T held in B) | recursive |
| `NowhereA[C]` (T held nowhere) / `InA[C]`, `InB[C]` (held in A) | finite / recursive |
| `Vectored[C]` (`kids: MutableVector[Vectored[T]]`) | recursive |
| `Fun[C]` (`f: Fn{args: [T]}`), `FnArg[C]`, `HoldsUnrelated`, `HoldsW` | finite |
| `R` (intrinsic: handle and `List[R]`), `P` (a pointer in every level), `Q[T]` (`kids: List[Q[C]]`) | rejected at the declaration |
| `FieldSelf` (`s: FieldSelf`), `FieldGrow[C]` (`g: FieldGrow[List[T]]`) | finite: no finite value |
| `Holder[C]` (`t: Node[T]`), `Wrap[C]` (`g: Grow[T]`) | recursive: another declaration's recursion |
| `Swap[int, C]` (`next: List[Swap[U, int]]`) | finite: affinity dies out |
| `Many[Many[C]]`, `Box[List[Box[C]]]` | finite: nesting through arguments |

## 10. Deep finite affine types

`or-deep-chain-accepted`: a chain of N plain structs ending in a coroutine
handle, N = 1, 8, 24, 48, 64, 65, 96, 128: every one accepted, its verdict
visiting N + 1 states, its drop descriptor 5N + 6 characters, and a program
that builds two values, passes, returns and drops them releasing both
handles exactly once (interp). `or-deep-chain-backends`: the 96-deep chain on
compile, cranelift-generic and cranelift, natively 2 released and 0 swept.
`or-large-graph`: 2100 declarations, each reaching the next through a field
and through a List -- 4200 edges, past the old budget, 2100 deep, past the
old depth -- is accepted from 2101 states and 4200 edges, one computation of
each declaration's facts. `or-deep-slot-chain`: a chain of 100
parameterized declarations handing T on is finite ending in `v: T` and
recursive ending in `n: Node[T]`.

## 11. Drop descriptors

`Descriptor` keeps its architecture -- prove the structure finite, then
build it -- and gains one cut. It already cut an exact repeat of a named
struct type on its stack (`struct S: c: C, s: S`). An accepted type can
still have an infinite unfolding through fields alone that never repeats a
type exactly (`FieldGrow[C]` meets FieldGrow[List[C]], FieldGrow[List[List[
C]]], ...). Such a declaration lies on a cycle of edges that cross nothing
(`hir::ownership::FieldCycle`), and then *every* application of it, whatever
its arguments, would hold another through mandatory fields without end: no
finite value has it. Descriptor cuts such a declaration where it meets it
again.

Why every accepted type now gets a finite descriptor: an infinite descriptor
walk is an infinite path of the affine unfolding; by section 5 it repeats a
state on a cycle; the cycle crosses an element (then the type is recursive
and rejected) or crosses none (a field cycle, cut). `or-field-cycle` pins
the descriptors of the accepted specimens (`FieldGrow[C]` `s1.0.c`,
`Swap[int, C]` `s1.1.ls1.0.c`, `Box[List[Box[C]]]` `s1.0.ls1.0.c`, ...);
`or-field-growth-programs` runs a program over `FieldGrow[C]` on all four
backends; `or-nested-runs` and `or-nested-native` release every handle of
the finite nestings exactly once. Descriptor never decides recursion: its
assertion stays an internal error, and an application of a declaration it
is inside of that is recursive (one no check stopped) is cut and asserted
too, so it can no longer loop.

## 12. Diagnostics

The verdict comes first; the witness is a separate, finite search afterwards
(`Witness`): the first path (depth first, in field order) from the type's
root pushes to a state of a bad component -- one of the type's own
declaration when one is reachable, so the old wording ("holds affine values
of struct X") stays exact -- then the first cycle within that component back
to its head that crosses an element. Its steps are instantiated with the
arguments the path has reached; past 400 characters of arguments (a
recursion whose arguments double at every step) the rest is shown in each
declaration's own terms. It reads only states Explore classified and visits
each state at most twice (with and without a crossing).

Walk events do not carry substituted steps: they carry a compact
*provenance* -- field hops and references to the through facts they used,
set once in fixpoint order, so acyclic -- and a witness expands only the
provenances on its own path (`Expand`). (Building steps eagerly cost a
128-declaration ring 4.2 s for its diagnostic; expanding provenance costs
74 ms.)

Messages (`or-messages`, `or-holder`, `or-message-three-steps`):

* `Node[C]`, GrowA[C], `struct D: c: C, kids: List[Box[D]]` and `TA -> TB ->
  TC -> TA`: as before (the old walk's paths are the cycles' paths).
* `Holder[C]`: `... is affine (its field "t" holds Node[C]) and holds affine
  values of struct "Node" in a List, MutableVector or MutableArray
  (Holder[C].t: Node[C], Node[C].children: List[Node[C]])`.
* `Wrap[C]`: names Grow and its growing children (it was the bound's
  "nest applications ... in ever larger types").
* `Box[Node[C]]`: an argument that is itself the recursive type is named
  (ApplicationIssue looks at the parts first when the recursion is another
  declaration's), as before.

No internal term (state, component, through fact) reaches a message.

## 13. Written, inferred and imprinted parity

`or-written-inferred-imprinted`: `Node[C]` is rejected written (a
parameter), made by a construction and explicitly imprinted
(`tag[Node[C]]()` of `fn tag() -> Tag[T]`, a phantom slot); `Swap[int, C]`
and `Many[Many[C]]` are accepted all three ways; `W[C]` and `Mixed[int, C]`
written and imprinted (no construction makes a phantom slot's argument).
`or-holder`: `Holder[C]` is rejected as a parameter, a result, a List
element and an explicit imprint. One canonical type, one verdict
(`hir::resolve::ResolveApplied` and inference build the same term; the
verdict is remembered per whole type).

## 14. Old and new

The old walk is kept verbatim as an audit-only reference
(audit/owned-recursion/tools/reference.tcl, from revision 09b1ea9, with one
addition: a walk that meets a type longer than 20000 characters stops as
`diverges` -- the old compiler exhausted memory there). The fuzzer compares
every query's verdict with it and classifies every difference mechanically:

| class | old | new | why the old walk was wrong |
|---|---|---|---|
| `old-bound` | unbounded | either | its depth or budget decided |
| `old-diverges` | (exhausted memory) | either | its types grew exponentially |
| `other-declaration` | accepted | recursive | it looked for its root's declaration only; the recursion is another's |
| `transient` | recursive | finite | it met its declaration again through a container at another affine-slot state that is itself finite: the affinity dies out |
| `nested` | recursive | finite | the application it met again is spelled by the type's own arguments or a declaration's fields, or the declaration has no cycle of edges at all: finite nesting |
| `uninhabited` | recursive | finite | its path passed a declaration whose values would hold themselves through fields alone: nothing nests |
| `DIFFERENT` | | | none: any other difference is a failure |

Over four 40-program runs (seeds 2-5; 1,350 queries, 82 of them
recursive): 1,216 same, 48 old-bound, 15 old-diverges, 7 other-declaration,
38 transient, 26 nested, 0 uninhabited and 0 DIFFERENT; the compiler agreed
with the independent oracle on every query, the 1,350 written queries
agreed end to end, and 34 runtime programs (8 of them natively) released
every coroutine exactly once.
`or-old-walk` pins the classes on named specimens. `parity.tcl` runs both
over every affine named struct type the golden suites and examples give an
expression, a binding or a field: see section 19 for its result.

Each changed class is a former artifact of the old walk's shape or bound,
not a change of the rule of section 2: the rule always said "values nest to
any depth, each level owning an affine value", and `Swap[int, C]`,
`Box[List[Box[C]]]` and a 96-deep chain have no such values while
`Holder[C]` does.

## 15. The independent oracle and the fuzzer

`audit/owned-recursion/tools/oracle.py` shares no code with the compiler and
states the question from section 5's definition with a different
formulation: an explicit pushdown model over *positions* of the field type
trees, frames keyed by (declaration, affinity vector), its own affinity
fixpoint over every vector of every declaration (no per-slot summary, no
probes), matched calls computed per (declaration, vector) by a worklist over
positions (not per declaration), every position checked for affinity (the
compiler checks only states), and the verdict as "a reachable head lies on a
head-graph cycle that crosses" by plain reachability. Its 28 hand cases
include every specimen above plus pointer-only and pointee recursion, a
three-declaration chain and a List of a recursive type.

`audit/owned-recursion/tools/fuzz.tcl` generates programs of 1-5
declarations with 0-3 slots and 1-4 fields over slots, int, coroutine
handles, C pointers (to Void or a slot), function types over a slot,
List/MutableVector/MutableArray and applications of the program's
declarations to smaller types (self, mutual and non-uniform recursion), then
checks: the declarations alone are rejected exactly when the oracle finds a
declaration recursive at its own slots; every query (applications of the
declarations to int, a handle, a List of one, a pointer and other
applications) against the oracle, and classified against the old walk; the
same queries written as parameter types of one program (AFFINE-CONTAINER-
UNSUPPORTED exactly at the recursive ones, a written type being no type when
any application in it is recursive); and, for programs over constructible
fields, every accepted affine query built, passed, returned, stored, moved
and dropped on interp and compile (and natively for some): every coroutine
released exactly once. `or-fuzz-smoke` runs a short pass in the test suite.

Two of the fuzzer's first finds were real: the framework's late-met
fixpoint defect (section 1; `or-late-met` pins its program) and the old
walk's memory exhaustion (`or-doubling`).

## 16. Mutation testing

`audit/owned-recursion/tools/mutate.tcl` runs every mutant of its
`mutants.txt` against tests/owned-recursion.test,
tests/affine-applications.test, tests/written-affine-applications.test and
a fuzzer pass, each detector in its own process under a memory cap (a mutant
that brings back an unfolding must not exhaust the machine).

MUTATION-RESULTS

Existing mutants retargeted (`tools/mutant-catalogs.tcl`: 87 catalogs, 0
problems):

* audit/affine `app-recursion-declared-fields` (the walk read declared, not
  applied, fields) is now "an application's slots are never followed into
  its arguments" (`foreach entry {}` in the through-walk);
* audit/affine `app-recursion-same-type-only` (only the very same
  application again) is now "a declaration's application of itself to other
  arguments is no edge";
* audit/declaration-summaries `fixpoint-never-revisits` follows the loop's
  new bound variable.

Not mutants (equivalent): the crossing of an edge read from a walk's last
step (a walk's crossing only grows); a non-affine state explored on
(everything it reaches is unrestricted); a verdict asked during the affinity
fixpoint remembered (nothing asks there).

## 17. Performance

`bench/owned-recursion.tcl` (verdict from fresh facts; structural counters;
the old walk beside it):

BENCH-TABLE

The structural assertions in tests/owned-recursion.test do not time
anything: `or-counters-nonuniform` (GrowA[List^k[C]] visits 2 states and
Grow[List^k[C]] 1 for k = 1, 8, 96; W[List^k[C]] none),
`or-counters-paths` (a chain of 16 declarations each reaching the next
through four fields -- 4^16 paths -- is 17 states and 32 edges, and its walks
grow linearly: 151 for 8 levels, 295 for 16), `or-deep-chain-accepted` (N + 1
states), `or-large-graph` (2101 states, 4200 edges).

FRONTEND-TABLE

## 18. HIR, interchange, isolation

No format changed. The facts are recomputed from the registry after a HIR is
read back (`or-interchange`: the verdicts of Node, Holder, Swap, FieldGrow
and GrowA applications are the same before and after an interchange round
trip read in another compilation's state, and the text is the same before
and after any verdict was asked). `or-isolation`: four interleaved
compilations declaring `Node[T]` four ways (owning T recursively, phantom,
owning an affine handle of its own -- rejected at the declaration -- and
finite) each answer from their own declaration after `hir::activate`.
`or-identity-not-name`: a module's `Node` (finite) and the entry program's
`Node` (recursive) answer differently in one compilation.

## 19. Regression and CI

REGRESSION

## 20. Remaining recursive walks

After this milestone no semantic component verdict depends on unfolding
applied fields under a depth or budget:

| walk | why it is finite |
|---|---|
| `hir::ownership::Walk` | walks one field type (or the root type) once per (subterm, crossing), memoized per session; an application's arguments are entered through its through facts, never by substituting its fields |
| `hir::ownership::Witness` | a search of the finite state graph after the verdict, each state at most twice; its expansion follows provenances set in fixpoint order (acyclic) |
| `hir::affine::Descriptor` | builds a structure for a type the verdict accepted: finite by section 11 |
| `hir::transfer::Schema` | as before: unrestricted arguments bounded, phantom affine ones erased |
| reason walks of Totality, SendClass, MutableComponent, ValueStability | as before: presentation of a class the summary decided |
| `hir::structs::TreeOccurrence`, `hir::resourceescape::Raw`, `hir::mutvec::ShareDescriptor` | keyed by declaration identity |
| `hir::relations::Leaves` | depth 4 by design (a precision bound of what the reorder proofs track) |

## 21. Limitations

* **States are subsets of slots.** A declaration of n slots has up to 2^n
  states. Every declaration of the repository has at most two slots; a
  wide rotation of 32 slots (`bench`'s `wide`) has 32 reachable states and
  costs 141 ms. A per-slot (unary) formulation is possible in principle but
  subtle (a carried slot and a relevant slot interact along a cycle); not
  done.
* **The witness of a long growing recursion is long.** Its steps are the
  path's; past 400 characters of arguments they are shown in each
  declaration's own terms, but a ring of 128 declarations still names 128
  steps.
* **Uninhabited types are accepted, not reported.** A type with no finite
  value (a recursion through fields alone) is accepted as before; nothing
  tells the author it cannot be constructed.
* **Function-type polarity** and **untyped-result precision** are out of
  scope, unchanged.

## 22. Next milestone

NEXT
