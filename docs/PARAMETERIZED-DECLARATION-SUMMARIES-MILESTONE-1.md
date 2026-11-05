# PARAMETERIZED-DECLARATION-SUMMARIES-MILESTONE-1.md

Component analyses of parameterized nominal types answered from finite
declaration summaries, instead of recursive walks that unfold applications.

> A parameterized nominal declaration is a finite semantic object even when
> repeatedly substituting its arguments would produce infinitely many
> distinct syntactic applications.

## Contents

1. Result
2. Starting architecture
3. The census of recursive type walks
4. General summary framework
5. Property algebra
6. Affinity
7. Slot positions
8. Bearing / BearingNamed
9. CarriedInto
10. Totality
11. The other migrated analyses
12. Hashable consequences
13. Non-uniform recursion
14. Removal of Unfolding
15. Owned recursion
16. Written versus inferred
17. Parity with the old walks
18. Oracle and fuzzing
19. Mutation testing
20. Performance
21. HIR, interchange, isolation
22. Regression and CI
23. Remaining recursive type walks
24. Limitations
25. Next milestone

## 1. Result

Every analysis that answered a question about a named struct type by
substituting its arguments into its fields and recursing into what it found
now reads a **summary of the declaration** and its own arguments' answers.
The summaries are computed once per declaration per registration, by one
least fixpoint over the declarations (`hir/summaries.tcl`), whatever
applications substitution would make.

* **Migrated** (each still has its own semantics, read through its own
  summary): `hir::callables::Bearing`/`BearingNamed`, `CarriedInto`
  (`CarriedErrors`), `hir::types::Totality` (and through it `HashClass`,
  `IsHashable`, `IsEqualityTotal`, `EqualityClass`, the Hashable and
  Equatable witnesses, the total lowerings `veqtotal`, `hashtotal`,
  `tablehashtotal`, `setcontainstotal`, `setfromlisttotal`),
  `hir::types::SendClass`, `hir::types::MentionsMutable`,
  `hir::mutvec::MayHoldVector`, `hir::staticdeps::CanCarry`,
  `hir::decimal::Mentions`, `hir::structs::MutableComponent`,
  `hir::sourcetypes::ValueStability`.
* **Unchanged, sharing the machinery**: the affinity summary
  (`AffinitySummary`) and the slot positions (`SlotPositions`) now run on the
  shared fixpoint (`hir::summaries::Fixpoint`, `hir::structs::Fixpoint` is its
  thin wrapper), and the one invalidation hook (`ForgetAffinity` calls
  `hir::summaries::Forget`). Their results are byte-for-byte the same.
* **Removed**: the rejection that only compensated for those walks
  (`hir::structs::Unfolding`, `UnfoldingFrom`, `UnfoldingMessage`,
  `hir::imprint::UnfoldingProblem`, `WrittenProblem`'s second branch), and
  `hir::callables::HasMutArray`, a recursive walk with no caller.
* **Became legal**: `W[Coroutine{...}]` of `struct W[T]: next:
  List[W[List[T]]]` -- written as a parameter, a result, a field, an
  argument of another application, made by an imprint, copied, compared,
  hashed, held in an ImmutableSet, erased and transferred -- on all four
  backends. It is unrestricted, total and sendable: no value of W holds a
  value of T at any depth.
* **Kept**: genuine recursive ownership. `Node[Coroutine{...}]` (a value of
  T beside a List of its own applications) and every affine application that
  owns a growing recursive affine one stay AFFINE-CONTAINER-UNSUPPORTED.
* **Not changed**: HIR, HIR text, interchange, the cache key's inputs, every
  runtime and backend, NIR (no new operation), the language's syntax.
  The transfer schema builder erases a phantom slot's affine argument so the
  schema of `W[Coroutine{...}]` is finite; every schema of a type that could
  be transferred before is unchanged.

## 2. Starting architecture

Before this milestone the affinity summary and the slot positions were
declaration summaries (AFFINE-PARAMETERIZED-APPLICATIONS-CORRECTNESS-
MILESTONE-1.md, WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md); every other
analysis of a type's components walked it:

```
X(S[A]) = combine over fields f of S:  X( f's type with A substituted )
```

terminating by a path-based `seen` list of full application types
(`Totality`, `SendClass`, `MayHoldVector`, `CanCarry`, `decimal::Mentions`,
`MutableComponent`, `ValueStability`), a path stack in a namespace variable
(`BearingNamed`, `CarriedInto`, `HasMutArray`) or a per-question visited set
(`MentionsMutable`, after the previous milestone's exponential case). All of
them end only because the set of applications reachable by substitution is
finite -- which it is only because the type bound cuts an unrestricted
argument (`aggregateDepth` 3, `appliedDepth` 6). An affine argument is never
cut, so for `W[Coroutine{...}]` every one of them recursed forever (the
previous milestone's program exhausted memory), and `Unfolding` rejected
such types where they were written so that no walk ever met one.

## 3. The census of recursive type walks

Every procedure in `hir/`, `native/`, `surface/`, `compiler/`, `core/`,
`service/` that meets a named struct type and recurses into its fields
(found by reading every caller of `AppliedFieldTypes`, `AppliedFieldType`,
`AppliedRepresentation`, `fieldTypes`, `fieldType`, `StructField`; only
`hir/*.tcl` and `native/lower.tcl` have such walks). "Applied" substitutes an
application's arguments; "Decl" reads the declaration's own fields and never
unfolds an application.

| # | walk | result | fields | terminated by (before) | now |
|---|---|---|---|---|---|
| 1 | `hir::structs::AffinitySummary`/`IsAffine`/`AffinityOf` | Boolean | Applied (probes) | declaration fixpoint | unchanged; shared fixpoint |
| 2 | `hir::structs::SlotPositions`/`PositionsOf` | positions per slot | Decl | declaration fixpoint | unchanged; shared fixpoint |
| 3 | `hir::structs::OwnedRecursion(From)` | recursive path | Applied, affine types only | visited set, depth 64, budget 4096 | kept (section 15) |
| 4 | `hir::structs::Unfolding(From)` | growth path | Applied | visited set, depth 64, budget 4096 | **removed** |
| 5 | `hir::structs::TreeOccurrence` | tree shape | Applied (catch: Decl) | path of declaration ids | kept: keyed by declaration, finite |
| 6 | `hir::structs::MutableComponent` | reason text | Applied | path of full types | **migrated** (class + pruned reason) |
| 7 | `hir::types::Totality`/`Components` | total/unknown/none + reason | Applied | path of full types | **migrated** (class + pruned reason) |
| 8 | `hir::types::SendClass`/`SendStruct`/`SendComponents` | total/unknown/none + reason | Applied | path of full types | **migrated** (class + pruned reason) |
| 9 | `hir::types::MentionsMutable(From)` | Boolean | Applied | visited set per question | **migrated** |
| 10 | `hir::callables::Bearing`/`BearingNamed` | Boolean | Applied | path stack | **migrated** |
| 11 | `hir::callables::CarriedErrors`/`CarriedInto` | set of errors | Applied | path stack | **migrated** (union) |
| 12 | `hir::callables::HasMutArray` | Boolean | Applied | path stack | **removed** (no caller) |
| 13 | `hir::mutvec::MayHoldVector` | Boolean | Applied | path of full types | **migrated** |
| 14 | `hir::staticdeps::CanCarry` | Boolean | Applied | path of full types | **migrated** |
| 15 | `hir::sourcetypes::ValueStability` | reason text | Applied | path of full types | **migrated** (class + pruned reason) |
| 16 | `hir::relations::Leaves` | leaf paths | Applied | depth 4 (`maxDepth`) | kept: a precision bound of the relational facts (section 23) |
| 17 | `hir::decimal::Mentions` | Boolean | Applied | path of full types | **migrated** |
| 18 | `hir::transfer::Schema`/`Node`/`StructNode` | schema graph | Applied | memo of exact types | kept; phantom affine arguments erased (section 14) |
| 19 | `hir::resourceescape::Raw` | path | Applied (`StructField`) | path of declaration ids | kept: keyed by declaration, finite |
| 20 | `hir::resources::ResourcesOf` | resource ids | Decl | path of ids | kept: never unfolds |
| 21 | `hir::affine::Descriptor(Of)` | drop descriptor | Applied, affine only | stack of types; OwnedRecursion first | kept (section 15) |
| 22 | `hir::mutvec::ShareDescriptor`/`HeldDescriptor` | share descriptor | Applied | visited declaration ids | kept: keyed by declaration, finite |
| 23 | `native::lower::ContextLeaves` | context slots | Decl | path of ids | kept: never unfolds |
| 24 | `native::lower::ContextObjectLeaves`, `ContextLeafRegs`, `ContextAt`, `ContextFields`, `ContextTypeAt` | registers | Decl | ContextLeaves' acceptance | kept: never unfolds |

Walks over a type's own structure that never enter fields are finite by
construction and out of scope: `hir::imprint::Substitute`, `Occurrences`,
`Placed`, `Paths`, `Parts`, `hir::types::Bound`, `MakeApplied`, `canonical`,
`show`, `IsClosedType`, `MentionsTrait`, `hir::privacy::Find`,
`hir::enums::IsAffine`; `hir::decimal::Show` is driven by a value.

Findings of the census besides the migrations:

* `HasMutArray` had no caller (row 12): removed rather than migrated.
* Bearing's `mutable` parameter is passed everywhere and decides nothing; it
  is kept (every caller passes it) and documented.
* `hir::resources::ResourcesOf` reads declarations only and ignores an
  application's arguments (row 20). Probed: `fn drop_box(b:
  Box[handle::Handle])` with `handle::Log` not installed is MISSING-CONTEXT
  exactly like `fn drop_plain(h: handle::Handle)` -- the release's context
  requirement reaches the caller another way -- so no defect was observed.
* `hir::staticdeps::MentionsMutable` (a different procedure from
  `hir::types::MentionsMutable`) never reads struct fields; `ShareDescriptor`
  identifies structs by declaration id. Both are pre-existing precision
  choices, recorded here, unchanged.

## 4. General summary framework

`hir/summaries.tcl` (loaded first among `hir/`'s files):

* **`define NAME -algebra classes|union -neutral TYPE -probes {...} -marker
  TYPE -marker-name NAME -node CMD`** registers a property. `-node` is the
  property's own walk of *one* declaration's applied fields (the old
  named-struct case, unchanged except that a nested named struct is answered
  through the property's top-level procedure, i.e. through this framework).
* **`Summary NAME ID`** -- the summary of declaration ID, computed by
  **`Fixpoint`** over every declaration ID reaches: each starts at the
  property's bottom (**`Bottom`**) and is recomputed (**`Compute`**: the node
  at the neutral argument everywhere, and at each probe at each slot) until
  none changes. The first round meets the declarations; later rounds
  recompute them in reverse order of meeting (dependencies first), so a
  chain of N declarations settles in one more round, not N (section 20). A
  declaration met while a fixpoint runs joins it; only a finished fixpoint's
  facts are kept.
* **`Level NAME TYPE CLASSES`** (classes algebra) and **`Union NAME TYPE`**
  (union algebra) answer an application from the summary.
* **`Arguments TYPE`** -- an application's arguments in slot order (a
  declaration named without arguments: its slots' variables, the types its
  fields are written in).
* **`Forget`** -- every property's facts, with the affinity facts, whenever
  the declarations change. Summaries live exactly as long as the registry
  entries they summarize; nothing is keyed by a name (`pds-identity-not-name`).
* **Counters** (`counters`, `ResetCounters`): `computations.NAME`,
  `hits.NAME`, `applications.NAME`, `rounds`, `fixpoints`, `whistles` --
  structural evidence for the tests, never semantics.
* **`Expansive ID`**, **`Whistle TYPE SEEN`**, **`Embeds A B`** -- the reason
  walk's termination (section 10).

The fixpoint is the one the affinity summary and the slot positions already
used, moved here and parameterized by fully qualified table names. No
theorem engine, lattice language or user-visible analysis: a property is a
few lines of registration beside the analysis it serves.

## 5. Property algebra

**Classes algebra.** A property's answers are levels `0..L`, joined by
`max` (a disjunction for a Boolean property; "the worst" for
total < unknown < none). The property reads an argument at a slot position
only through a finite *class* of the argument, and every class has a probe
type that behaves like each of its members wherever the property reads it.
Then for a declaration S of n slots

```
P(S[A1..An]) = max over i of  entry(S, i, class(Ai))
entry(S, i, c) = P(S[neutral, ..., probe_c at i, ..., neutral])
```

(each entry includes S's own answer, the node at the neutral argument). This
is exact when (a) the neutral argument contributes the bottom wherever it is
read, (b) the property is a join of contributions each of which depends on at
most one slot (true of every property here: a field, an element, a Fn's
argument or result each mention their slots, and the combination is `or` or
"worst"), and (c) the probe of a class is substituted and bounded exactly as
a member of the class is at every position a declared field type holds a
slot -- declared field types are already bounded when registered, so a slot
sits at most `aggregateDepth - 1` deep, where a probe (a scalar, `any`, a
one-level function type) is never cut. Condition (b) is also checked
independently: the oracle (section 18) solves one fixpoint over all of an
application's arguments together, with no per-slot join.

**Union algebra.** CarriedInto's answers are sets, and a slot contributes
its argument's whole answer or nothing (`own ∪ ⋃ over relevant i of
P(Ai)`). The summary is the declaration's own set and the slots whose marker
probe -- a function type whose contract declares the one error no program can
name, `#summary-marker` -- reaches the answer.

**Neutral arguments and probes are each property's own** (no universal
neutral, no shared relevance):

| property | algebra | neutral | probes (class 0, 1, 2) |
|---|---|---|---|
| `bearing` | classes | `any` | `any`, `int`, `Fn{args: [int], return: int}` |
| `carried` | union | `any` | marker `Fn{args: [], return: int, errors: [#summary-marker]}` |
| `totality.equality`, `totality.hash` | classes | `int` | `int` (total), `any` (unknown), `Fn{...}` (none) |
| `send` | classes | `int` | `int`, `any`, `Fn{...}` |
| `mentionsMutable` | classes | `int` | `int`, `MutableVector[int]` |
| `mayHoldVector` | classes | `int` | `int`, `MutableVector[int]` |
| `canCarry` | classes | `any` | `any`, `Fn{...}` |
| `decimalMentions` | classes | `int` | `int`, `DecimalRounded` |
| `mutableComponent` | classes | `int` | `int`, `MutableVector[int]` |
| `valueStability` | classes | `int` | `int`, `MutableVector[int]` |

## 6. Affinity

`AffinitySummary` was left intact: it already had this architecture
({BASE RELEVANT}: the classes algebra with two classes, probe `coroutine`,
neutral `any`), its result shape is read directly by `AffineThrough` and the
drop descriptors, and its resource case (a resource is affine whatever its
fields) is a node-level rule. Moving it onto `define` would change no answer
and its API, for no simplification. It now runs on the shared `Fixpoint`
and is forgotten by the shared hook; `IsAffine`, `AffinityOf`,
`AffineThrough`, drop descriptors, recursive affine rejection, phantom slots
and nested applications are pinned by the unchanged
`tests/affine-applications.test` (21/21), `tests/affine.test` (48/48) and
`tests/written-affine-applications.test`.

## 7. Slot positions

Likewise intact: `SlotPositions` is a per-slot *set* of positions (`value`,
`pointee`, `cvalue`, `csignature`) that imprinting reads through
`hir::imprint::Occurrences`, not an answer joined over an application's
arguments, so it has no application form to read through `Level`. It shares
the fixpoint and the invalidation. Affinity relevance and value positions
remain distinct facts (WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md, section
5): the summaries share machinery, never answers.

## 8. Bearing / BearingNamed

**What Bearing means today** (`hir/callables.tcl`, TYPED-CALLABLE-ESCAPE-
SOUNDNESS.md): a value of the type carries an obligation of its *caller* that
erasing the type would make unenforceable -- an exact block with a typed
(non-`any`) parameter or declared errors, an exact native with declared
errors, a structural `Fn` with a non-`any` argument type or declared errors,
or anything whose callable result, List/set/vector/array element, or struct
field bears. `BearingNamed` is the named-struct case: any applied field
bears. A coroutine type is not bearing. The `mutable` flag decides nothing.

**What it reads at a slot**: where a value of the argument is held (a field,
an element, a callable's result) whether the argument bears; as a `Fn`'s
argument type whether the argument is `any`. Hence three classes: `any`
(neither), another non-bearing type, a bearing type (never `any`). The
summary is one row per slot of three levels (`pds-relevance-per-property`:
`Handler[T]` of `f: Fn{args: [T], ...}` has `{own 0 values {{0 1 1}}}` --
`Handler[int]` bears, `Handler[any]` does not). `BearingNamed` is exactly
that read; `BearingNode` is the old named-struct loop. Both Bearing and
BearingNamed terminate on every type, recursive and non-uniform alike, with
the old answers on every type the old walk finished on (section 17).

## 9. CarriedInto

**What it means**: the declared errors a value of the type may raise once
its type is forgotten -- an exact block's declared errors, an exact
native's, a structural function's or coroutine's contract errors, and what
its result, elements and fields carry (never a function's argument types).
It is a union, kept a union: `CarriedNode` is the old loop, the summary is
`{own SET relevant {INDEX ...}}`, and `CarriedInto` adds the own set and the
whole answer of each relevant slot's argument. `pds-carried-union`: a
declaration's own `Oops`, two slots' `Oops` and `Ouch` joined each once,
`Mixed[Ouch-fn, Oops-fn]` carrying only its held slot's `Ouch`.

## 10. Totality

**Semantics kept**: `{CLASS WHY}`, CLASS total, unknown or none, WHY the
reason in source terms ("field \"f\" of Tree (Fn{...}): a function has no
total equality ..."). The node (`TotalityNode`) is the old named-struct case:
the parts are an identity struct's identity elements
(REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md) or every field but a tree's
child field (`TotalityParts`, shared by the node and the reason); the class
is the worst part's. Totality reads an argument only where a value of it is
a component, and only by its class, so the summary holds each slot's class
for each argument class (`TotalityClass`). A struct met again adds nothing:
the summaries start at `total` (the least fixpoint), as the old `seen` did.

**Soundness** (Totality decides unchecked lowerings): a slot contributes
only where the node reads a value of it -- `Phantom[T]`'s argument, `W[T]`'s
argument and a `Fn{args: [T]}`'s argument are no component
(`pds-phantom-recursion`, `pds-mixed`), a held argument contributes its
whole class (`Box[Fn{...}]` is none). Nothing is ever taken for total that
a value could refute: an `any` argument is `unknown`, a cut is never read
(section 17).

**The reason.** The class comes from the summary; the reason is the old walk
of the parts in field order (Components' format), entered only for a class
that is not total, with every part whose summary class is total skipped. On
every type the old walk finished on, this is the old walk's reason: pruning
removes only parts the old walk would have found total, and the old walk's
path-based `seen` already decided the rest. One form of type could still make
it walk forever: a non-uniform recursion whose first part in field order
grows (`OwnGrow[T]`: `next: List[OwnGrow[List[T]]]` before its `f: Fn`
field) -- the class is decided, but "the first part of that class" descends
into ever larger applications. `hir::summaries::Whistle` stops it: on a
declaration that lies on an *expansive cycle* of the slot graph (`Expansive`:
Kennedy and Pierce's finitary condition -- a cycle through an edge whose
argument nests the slot), a third application on the walk's path, each
embedding the previous one (homeomorphic embedding, `Embeds`), is treated as
met again. Applications of declarations on no expansive cycle never trigger
it, so every finite case keeps the old reason; the whistle only shortens
reasons the old walk could only give after the bound cut its arguments. If
the walk still found no part of the class (it never did in the corpus or the
fuzzer), the reason names the non-uniform recursion
(`TotalityFallback`). The class never depends on the walk.

`SendClass`, `MutableComponent` and `ValueStability` explain their classes
the same way (section 11).

## 11. The other migrated analyses

| analysis | classes | positions it reads an argument at |
|---|---|---|
| `SendClass` (`SendStruct`, `SendParts`, `SendNode`) | total/unknown/none, the caller's `assumed` classifies imprint arguments | fields, elements of List/set/vector/array, an opaque `through` representation; a context struct, an opaque struct without a clause and byte storage are the node's own |
| `MentionsMutable` | 0/1 | List/set elements, fields, a refinement's base |
| `MayHoldVector` | 0/1 | fields and enum payloads (never elements: an element is never a place) |
| `CanCarry` | 0/1 | elements, fields, any callable |
| `decimal::Mentions` | 0/1 | elements, fields -- an identity struct's identity fields only |
| `MutableComponent` | 0/1 + reason | elements, fields; an identity struct is its own check |
| `ValueStability` | 0/1 + reason | List/set elements, fields |

Each keeps its old entry point and signature; only its named-struct case
reads the summary.

## 12. Hashable consequences

`HashClass` is `Totality equality` and `Totality hash` combined, both from
summaries. Evidence:

* **No witness removed.** If the old walk said `total`, it read no cut type
  at a component (every cut -- a bare `list`, `struct` or `immutableSet`
  kind, `any`, a cut Fn -- is unknown or none), so the summary, which reads
  the same uncut parts, says total too. The parity corpus has no `total`
  that became anything else.
* **Witnesses added only where the old answer was a bound artifact.** The
  one family in the corpus is `GrowV[Box[int]]` (`value: T`, `next:
  List[GrowV[Box[T]]]`): its values hold `Box^k[int]`, all total; the old walk
  read `Box^6[any]` after the applied-type bound and answered unknown. The
  summary answers total (section 17).
* **The total lowerings follow.** `pds-total-lowering`: `==` of two
  `W[Coroutine{...}]` and of two `Mixed[int, Coroutine{...}]` lowers to
  `veqtotal`, `hash` of a `W[Coroutine{...}]` to `hashtotal`, `==` of an
  `OwnAny[int]` (a Fn field: none) keeps `veq`. The existing NIR tests
  (`tests/hashable.test`'s `hb-nir-*`, 48/48;
  `tests/setcontains-equality-total.test`, `setfromlist-equality-total.test`)
  pass unchanged.
* The two operations' summaries are equal by construction today:
  `core::value::incomparable` and `core::hashing::unhashable` list the same
  kinds, and the one form that differs by operation (a variable constrained
  by Equatable but not Hashable) is only ever an argument, classified by the
  operation's own Totality. They stay two properties because they are two
  operations (and the mutant that reads one for the other is equivalent:
  section 19).

## 13. Non-uniform recursion

`struct W[T]: next: List[W[List[T]]]` (`pds-w-specimens`), with no
application unfolded:

| type | affine | Bearing | carried | equality | hash | SendClass | mutable |
|---|---|---|---|---|---|---|---|
| `W[int]` | 0 | 0 | {} | total | total | total | 0 |
| `W[Coroutine{...}]` | 0 | 0 | {} | total | total | total | 0 |
| `W[List[int]]` | 0 | 0 | {} | total | total | total | 0 |
| `W[Fn{... errors: [Oops]}]` | 0 | 0 | {} | total | total | total | 0 |
| `W[List^8[Coroutine{...}]]` | 0 | 0 | {} | total | total | total | 0 |

Why: W's only field is a List of W's own applications, and its slot occurs
only as an argument of W itself, so every summary's slot entry equals its
own answer (the least fixpoint never finds a value of T). The same answer
the old walk gave `W[int]` (whose bound cut the argument eventually) and
never gave `W[Coroutine{...}]` (no answer: it recursed forever).

Others (`pds-mutual`, `pds-phantom-recursion`, `pds-mixed`,
`pds-nonuniform-own`):

* **Uniform mutual recursion** `UA[T]: b: List[UB[T]], v: T` / `UB[T]: a:
  UA[T]`: T contributes (it is held by UA).
* **Non-uniform mutual recursion** `GrowA[T]: b: List[GrowB[List[T]]]` /
  `GrowB[T]: a: GrowA[T], v: T`: GrowA[X] holds `List[X]` values through
  GrowB's `v`; `GrowA[Coroutine{...}]` is affine and not total,
  `GrowA[Fn{args: [int]}]` bearing, `GrowA[MutableVector[int]]` mutable.
* **Phantom recursion** `PhantomRec[T]: next: List[PhantomRec[List[T]]]`:
  every argument -- affine, bearing, erroring, mutable, `any` -- gives the
  same unrestricted, total, sendable, obligation-free answer.
* **Mixed** `Mixed[A, B]: value: A, next: List[Mixed[A, List[B]]]`: A
  contributes, B never does (`Mixed[int, Coroutine{...}]` unrestricted and
  total, `Mixed[Coroutine{...}, int]` affine and none).
* **A non-uniform recursion with an answer of its own** `OwnGrow[T]`
  (beside `next: List[OwnGrow[List[T]]]`, an `f: Fn{args: [int]}` field):
  bearing and none for every argument, the reason naming `f` even where the
  walk meets the growing field first.

## 14. Removal of Unfolding

`hir::structs::Unfolding` walked a written application with an affine
argument (struct and applied fields, elements, function types) with
OwnedRecursion's bounds and rejected one that kept growing
(AFFINE-CONTAINER-UNSUPPORTED, "has no finite form"); `hir::imprint::
UnfoldingProblem` did the same for an imprint binding an affine type. Both
existed only because the walks above would not end on such a type. With
every walk reachable from a value's type answered from summaries, both are
removed, and `WrittenProblem` is the recursive-ownership check alone.
No diagnostic replaces them: such a type is now ordinary.

`wd-unbounded-rejected` became `wd-unbounded-accepted` (census row and names
file updated): `W[Coroutine{...}]` written directly, held by another
application (`M[T]: a: T, w: W[T]`) and made by an imprint (`mk[C]()` of
`fn mk() -> W[T]`) compiles; programs over `W[Coroutine{...}]` and `W[int]`
run on all four backends. `pds-w-programs` writes, copies, compares, hashes,
puts in an ImmutableSet, erases and transfers one.

One more walk met such a type once it could exist: the transfer schema
(`hir::transfer::Node`), which memoizes exact types and so would follow
`W[List^k[Coroutine{...}]]` forever. A value's schema cannot depend on an
argument no value holds, and only a phantom slot of a sendable type can
take an affine argument (an affine value is never sendable), so the schema
walk replaces an affine argument at a slot with no position
(`SlotPositions`) by `never` (`hir::transfer::Erased`). Unrestricted
arguments are kept as written, so the schema text, and the bytes, of every
type that could be transferred before are unchanged
(`tests/value-transfer.test`'s fixed vectors pass, 76/76).

## 15. Owned recursion

`OwnedRecursion` is a rule of ownership, not of the compiler's analyses: an
affine type whose values nest affine values to any depth through a container
has no finite drop descriptor, so it is rejected whatever analysis exists.
It is kept unchanged (`pds-owned-recursion-kept`: `Node[Coroutine{...}]`,
`GrowB[Coroutine{...}]` and `GrowA[Coroutine{...}]` are
AFFINE-CONTAINER-UNSUPPORTED; `W[Coroutine{...}]` and
`PhantomRec[Coroutine{...}]`, which own no handle, are not). It runs only on
affine types and still bounds its walk (64 fields deep, 4096 types visited);
a walk past either is reported `unbounded`. That bound decides a verdict in
two kinds of type: an affine type that grows through a container (rejected,
rightly: it is a recursive affine type -- section 24 discusses why its
verdict is still the bound's), and an affine type written more than 64 fields
deep (rejected wrongly; no program writes one). Section 24 records it.

## 16. Written versus inferred

A written application is still the type the same application is inferred
as (`hir::resolve::ResolveApplied` builds the canonical type; nothing here
changed it). `pds-written-inferred`: a `W[Coroutine{...}]` construction
inferred, passed through an untyped function and passed through a parameter
written `W[Coroutine{...}]` have one type term and one set of answers --
affinity, Bearing, carried errors, both totalities, SendClass, the three
mutability questions. The affinity summary, drop descriptors and ownership
behavior of written applications are pinned by
`tests/written-affine-applications.test` (26/26), whose
`wd-written-is-inferred` is unchanged.

## 17. Parity with the old walks

`audit/declaration-summaries/tools/reference.tcl` is the old walks, taken
verbatim from the revision before this milestone (17b0e669) by
`extract-reference.py` into `::reference::NS` (audit-only: no production code
loads it). Every named struct's fields are read through `::reference::Fields`,
which counts reads (a walk past the budget does not finish) and records
whether the type bound cut what the substitution made (comparing the fields
with the bound raised). `tools/parity.tcl` compares, for every analysis, the
compiler's answer with the old walk's, classes *and* reasons:

* `same` -- equal;
* `bound` -- different, and the old walk read a field type the bound had
  cut (the summary reads the argument uncut);
* `diverges` -- the old walk did not finish;
* `DIFFERENT` -- anything else: a failure.

The corpus (`audit/declaration-summaries/corpus.bot`) declares every kind
the analyses walk: scalars, an enum, a refinement, ordinary, opaque,
recursive, mutually recursive, tree and identity-free structs, Fn fields with
and without errors, vectors, arrays, coroutines, C pointers, DecimalRounded,
`any`; parameterized structs with value, phantom, pointee, Fn-argument and
Fn-result slots, nested applications, Lists of slots, and the non-uniform
recursions (W, Mixed, PhantomRec, GrowA/GrowB, GrowV, NonUniformFn). Each
one-slot declaration is applied to a pool of 25 arguments (every kind above,
applications included), each two-slot one to 36 pairs, and some are held in a
List, an anonymous struct, a function's result and a vector.

RESULTS-PARITY

## 18. Oracle and fuzzing

`audit/declaration-summaries/tools/oracle.py` is an independent model with
its own type language (scalars, `any`, a coroutine, three function types, a
vector, `List`, a function's argument and result, applications, slots) and
the five properties it decides (affinity, Bearing, Totality, carried errors,
MentionsMutable), stated per constructor. It shares no code and no algorithm
with the compiler: where the compiler probes each slot separately and joins
the entries, the model solves **one** least fixpoint, by a worklist, over the
graph whose nodes are (declaration, the abstract values of *all* its
arguments together) -- so it also checks that the per-slot join is exact.
Neither unfolds an application. `oracle.py selftest` checks 13 hand-made
cases (W, Mixed, mutual non-uniform recursion, a Fn argument slot, a
self-recursive struct).

`audit/declaration-summaries/tools/fuzz.tcl` generates random declaration
graphs of 1 to 4 declarations of 0 to 3 slots -- fields mixing scalars,
slots, Lists, Fn arguments and results, applications of any declaration
(itself, a later one, a mutual cycle), and with probability 1/2 a
non-uniform recursion (an application whose arguments nest the slots) --
writes them as Botlish source, compiles them, and asks random concrete
types (atoms, a coroutine, Fn types, a vector, Lists, nested applications).
Every query's affinity, Bearing, Totality (both operations, which must
agree), carried errors and MentionsMutable must equal the oracle's; with
`-reference 1` every analysis is also compared with the old walk (the
verdicts of section 17).

RESULTS-FUZZ

## 19. Mutation testing

`audit/declaration-summaries/tools/mutate.tcl` (35 mutants in its
`mutants.txt`; detectors: `tests/parameterized-declaration-summaries.test`
without the corpus test, `written-affine-applications`, `hashable`,
`value-identity`, `typed-callable-escape`,
`structural-contract-completions`, and `fuzz.tcl -programs 12 -seed 5`, the
oracle and the old walks).

RESULTS-MUTANTS

Equivalent mutants left out, and why (recorded in `mutants.txt`): applying
an argument's contribution twice (every join is idempotent), dropping
Bearing's `mutable` flag (it decides nothing), reading hash totality from
equality's summary (equal by construction, section 12).

**Other harnesses.** Their mutants that edited code this milestone moved
were retargeted, keeping each one's rule:

* `audit/affine/tools/mutants.txt`: `written-unbounded-unchecked` and
  `imprint-unbounded-unchecked` retired with the rejection they mutated (the
  inverse defect is this harness's `unfolding-retained`);
  `written-walk-per-path` retargeted (MentionsMutable walks the fields per
  path again); `written-recursion-unchecked` and `written-accepts-
  everything` retargeted to the shorter `WrittenProblem`.
* `audit/tree-struct/tools/mutants.txt`: `totality-equatable-unconditional`,
  `totality-hashable-unconditional`, `totality-child-unknown` retargeted to
  `TotalityParts`/`TotalityClass`; `totality-child-infinite` retired -- a
  tree's class is a least fixpoint, in which walking the child field is
  equivalent to skipping it and cannot recurse.
* `audit/value-identity/tools/mutants.txt`: `witness-reads-representation`,
  `conditional-witness-always` (TotalityParts), `decimal-guard-reads-
  representation` (MentionsNode) retargeted.

Every mutant of every harness applies to the new code (each replaced text
occurs exactly once). RESULTS-OTHER-MUTANTS

## 20. Performance

**Linear in the declarations.** The first version of the shared fixpoint
recomputed every met declaration in every round, in the order met
(dependents first); on a chain of N declarations that is N rounds of N
declarations -- quadratic (measured: 3N + 6 rounds; 21,351 applied-field
reads for N = 32). Later rounds now go in reverse order of meeting
(dependencies first): 9 rounds for three properties whatever N, and the reads
grow linearly (290, 522, 986, 1,914 for N = 4, 8, 16, 32). The affinity
summary and the slot positions share the improvement; their answers are a
least fixpoint and do not depend on the order.

`pds-counters-linear` (16 levels cost at most twice 8 levels plus a constant,
in a fixed number of rounds) and `pds-counters-nonuniform` (W's summary is
computed once per property; answering `W[C]`, ..., `W[List^8[C]]` again
computes nothing and reads one application per question) pin the shape;
`wd-nested-walks-linear` was re-expressed the same way (linear growth of the
applied-field reads, where it used to require at most 3 per level of the
per-question visited set).

RESULTS-BENCH

## 21. HIR, interchange, isolation

* **Isolation.** Summaries are registry facts, forgotten with it
  (`hir::declarations::Install` calls `ForgetAffinity`). `pds-isolation`
  interleaves three compilations declaring `Box[T]` differently (holding T,
  phantom, holding a Fn returning T) and gets each one's own answers in
  every order; `pds-identity-not-name` answers a module's `geo::Box` and the
  entry program's `Box` differently in one compilation. The mutants
  `summary-survives-reset` and `summary-keyed-by-name` are killed by them.
* **Interchange and cache.** No HIR field, side table, text form or front-end
  input changed; nothing of a summary is written (`pds-interchange`: a HIR
  read back from interchange text after another compilation recomputes the
  same answers, and its text mentions no summary). `hir/` changed, so the
  front end's fingerprint changes and earlier cache entries are rebuilt, as
  for any front-end change.
* **No runtime change**: no backend, runtime, NIR operation, object header or
  run-time metadata changed (`git diff --stat` touches `hir/` only among the
  compiler's sources).

## 22. Regression and CI

RESULTS-CI

## 23. Remaining recursive type walks

After this milestone, the walks of the census that still recurse into an
application's applied fields, each justified:

| walk | why it stays a walk |
|---|---|
| `hir::structs::OwnedRecursion` | a rule of ownership on affine types (section 15); its bound is the one threshold left that can decide a verdict |
| `hir::affine::Descriptor` | builds a structure (a drop descriptor) for an affine type OwnedRecursion accepted: finite by that check |
| `hir::transfer::Schema` | builds a structure (the schema); finite because unrestricted arguments are bounded and phantom affine ones erased (section 14) |
| reason walks of `Totality`, `SendClass`, `MutableComponent`, `ValueStability` | presentation of a class the summary decided; pruned, and stopped on growth by Whistle (section 10) |
| `hir::structs::TreeOccurrence`, `hir::resourceescape::Raw`, `hir::mutvec::ShareDescriptor` | keyed by declaration identity: finite whatever the arguments |
| `hir::relations::Leaves` | the relational facts' leaf paths, bounded at depth 4 by design (a precision bound of what the reorder proofs track, not of an analysis of a value's components); a collection deeper than that is simply not tracked |
| `hir::resources::ResourcesOf`, `native::lower::Context*` | read declarations only, never unfold |

## 24. Limitations

* **OwnedRecursion's bound.** Its `unbounded` verdict is reached by a depth
  (64) or a budget (4096). For a growing affine type the verdict is right
  (such a type owns a growing recursive affine type), but it is the bound
  that reaches it; and an affine type written more than 64 fields deep
  would be rejected though finite. Making it a declaration summary needs a
  precise statement of recursive ownership over applications (an affine
  path through a container back to the same declaration, growing or not) --
  recommended next.
* **Reasons, not classes, in growing recursions.** In a non-uniform
  recursion the reason text may name a shorter path than the old walk's
  (which, where it finished, reported a part found only after the bound cut
  its arguments); the fallback text exists for a walk that finds nothing and
  was never reached by the corpus or the fuzzer.
* **Precision gained at the bound, so behavior can change there.** Where the
  old walk read a cut argument, the new answer is the uncut type's: more
  Hashable witnesses (GrowV), and, symmetrically, a struct whose deep
  argument holds a function is now `none` (TRAIT-NOT-SATISFIED where a
  `checked` hash was dynamic) and bearing (an erasure is rejected that was
  silently accepted). Both are the sound answers; the corpus has no case of
  the second kind outside synthetic types.
* **Function-type polarity** (a Fn's argument position holds no value) and
  **untyped-result precision** are out of scope, unchanged.

## 25. Next milestone

The evidence points to **OwnedRecursion as a declaration summary**: it is
the one walk left whose verdict a threshold decides (section 15, 24), it
runs on every affine application, and its question -- does an affine type's
ownership reach its own declaration through a container, or grow without end
-- is a property of the declaration graph with the arguments' affinity, the
shape the framework already handles (the expansive-cycle analysis of
`hir::summaries::Expansive` is half of it). Not function-type polarity: no
evidence here bears on it.
