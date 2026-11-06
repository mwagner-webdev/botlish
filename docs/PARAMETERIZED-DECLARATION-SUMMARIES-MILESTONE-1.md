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

**Evidence** (sections 17 to 22):

* **Parity with the old walks.** 16,572 corpus comparisons of classes and
  reasons found 0 DIFFERENT. 79 answers are more precise where the old walk
  read a type the bound had cut, and 406 are answers the old walks never
  reach.
* **An independent model.** 5,625 random queries over 225 random
  declaration graphs were answered as the oracle answers them. 22,500 more
  comparisons with the old walks found 0 DIFFERENT.
* **Mutants.** All 37 of this milestone's mutants are killed, one of them
  by a test added when it first survived. So are the 40 mutants of seven
  other harnesses that edit code this milestone changed, one of them after
  a retarget.
* **Tests.** `tests/parameterized-declaration-summaries.test` (24 tests).
  Every test file the changes reach passes. The first full local run
  failed only `main`'s `pa-add-refusals` and three tests of
  compilerpedia.test, fixed since; on the merge of `main`'s fixes
  (e6c1d05) the full local run has no failure (section 22).
* **CI.** On 889c5c4, the third merge of `main`, every test workflow
  passed: Linux x86-64 and Linux arm64 (dispatched), macOS, Windows and
  the icy-tower builds; `static-decisions` passed on 961dc07. The runs of
  the last merge of `main` (1e1fe84) are pending (section 22).
* **What the audit found and fixed on the way:**
  * one wrong answer: a refinement's name read as imprecise
    (`MayHoldVector(Box[Small])`, full corpus);
  * an argument's classification that started reason walks without end
    (fuzzer);
  * a reason walk exponential in the paths it revisited (fuzzer);
  * a mutant of the hashable harness that had become equivalent;
  * two defects of the audit tools themselves (the oracle's worklist, the
    reference's swallowed budget).

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
  `hits.NAME`, `applications.NAME`, `rounds`, `fixpoints`; and, of the
  reason walks, `whistles`, `fallbacks`, `reasonWalks`, `reasonReuses`.
  They are structural evidence for the tests, never semantics.
* **`Expansive ID`**, **`Whistle TYPE SEEN`**, **`Embeds A B`**, **`Walk KEY
  SCRIPT`**, **`Walked KEY VAR`** -- the reason walk's termination and cost
  (section 10).

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
that is not total, with every part whose summary class is total skipped.
Pruning removes only parts the old walk would have found total, and the old
walk's path-based `seen` already decided the rest. So on every type the old
walk finished on, this is the old walk's reason, up to the per-question
walk below: a later path reuses the first path's walk, which can in
principle name another part. The corpus and the fuzzer compare every
reason, and found no such case (sections 17 and 18).

One form of type could still make the walk run forever: a non-uniform
recursion whose first part in field order grows (`OwnGrow[T]`: `next:
List[OwnGrow[List[T]]]` before its `f: Fn` field). The class is decided,
but "the first part of that class" descends into ever larger applications.
`hir::summaries::Whistle` stops it: on a
declaration that lies on an *expansive cycle* of the slot graph (`Expansive`:
Kennedy and Pierce's finitary condition -- a cycle through an edge whose
argument nests the slot), a third application on the walk's path, each
embedding the previous one (homeomorphic embedding, `Embeds`), is treated as
met again. Applications of declarations on no expansive cycle never trigger
it, so every finite case keeps the old reason; the whistle only shortens
reasons the old walk could only give after the bound cut its arguments.

If the walk still finds no part of the class, the part that decides it is
past the type bound (or, in principle, was found by no first path):
`Deep[List[Fn{...}]]`, whose declaration holds its
argument three Lists down, holds a function the bound has replaced by a cut
type the walk reads as `unknown`, while the summary, reading the argument
uncut, says `none`. The reason then names the argument that decides the
class and gives that argument's own reason (`TotalityFallback`, through
`hir::summaries::Contributor`, the first slot whose entry reaches the
class). Only if no single argument decides does it say that the class comes
through a non-uniformly recursive declaration. The fallbacks are counted
(`fallbacks`); sections 17 and 18 report them. The class never depends on
the walk.

**Classifying an argument never walks.** While a reason walk runs, every
argument and nested application it meets is classified by its summary
class alone: `totalityClassOnly` for Totality and SendClass,
`stabilityClassOnly`, `mutableClassOnly`. It is never classified by a
second reason walk. Without this, a growth through another declaration's
application (`GrowBoxed[T]`: `next: List[Box[GrowBoxed[List[T]]]]`, `v: T`)
classified `Box[GrowBoxed[List^k[T]]]` by a fresh walk at every step. The
outer walk's whistle could not see that walk, so ValueStability and
MutableComponent never ended. The fuzzer found it (seed 11), and
`pds-reason-classification-terminates` reproduces it; it fails on the code
before the fix. An application's Totality and SendClass classes are also
remembered per registration (`Recall`/`Remember`, forgotten with the
summaries). Nothing is remembered while that property's fixpoint runs,
because an answer may still rise then.

**One question walks an application once.** The old walks' `seen` was a
path: an application reached along two paths was walked twice, and in a
declaration with several recursive fields the paths that reach one
application multiply at every level. The fuzzer found one (seed 31): in
`Braid[A, B]`, with `f0: Braid[MutableVector[int], Fn{...}]`, `f1: Braid[B,
List[Braid[str, A]]]`, `f2: B` and `f3: List[Braid[List[A], B]]`, every
application is `none` through its own `f0`. The equality reason of
`Braid[Braid[Fn{...}, int], Braid[any, str]]` therefore entered all three
recursive fields at every level, backtracking whenever `seen` or the whistle
cut a subwalk. It walked 103 distinct applications more than 200,000 times,
along paths up to 63 deep, and did not finish, while the class took 8 ms.
Now `hir::summaries::Walk` keeps each application's walk for the rest of
the question, and a later path reads it (`Walked`). The outermost walk is
the question: its results are forgotten when it ends, so no reason depends
on what was asked before. Each of the four reason walks of that program now
walks about a hundred applications, under 200 ms (`pds-reason-walk-
polynomial`). A result is the walk's on the first path that reached the
application. Another path might have found another part, but any part found
is a true reason. Sections 17 and 18 check the reasons against the old
walks.

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

The old walks run under limits, so that a walk that would not end is
reported as `diverges` instead of exhausting the machine:

* `corpus.tcl` stops each one after 5,000 field reads (`-budget`).
* `reference.tcl` also stops a walk that reaches a type of more than 4,000
  characters. A recursion that doubles its argument at every step (an
  affine one is never cut) builds exponentially large types, and the old
  walks copy their path lists per frame: one fuzzer seed reached 4 GB
  before this limit.
* Whether the bound cut a field is compared only for types under 2,000
  characters.
* A walk never swallows its own end. The old MutableComponent tolerated a
  field it could not substitute (`catch {AppliedFieldTypes $type}`).
  Rewritten to read `::reference::Fields`, it also caught REFERENCE-BUDGET
  and Tcl's nesting limit, which a walk down a growing recursion reaches
  first. It then went on and answered from whatever fields it had read
  before, so every one of its walks "finished": on `W[Coroutine{...}]` it
  answered `""` where the walk never ends. Fuzzer seed 41 showed it: the
  walk with the bound raised to 64 (`Exact`) ran without end, and the walk
  under the bound named field `f1` where the full walk names `f0`.
  `::reference::CatchFields` now rethrows both, as `::reference::Run`
  counts them, and the extractor refuses any other way of catching
  `Fields` (73e9515). The corpus and fuzzer verdicts here were measured
  after the fix.

**What the full corpus found.** Its first run found one defect of the
summaries: `MayHoldVector(Box[Small])` was DIFFERENT. An application kept
the refinement `Small` by its declared name, which the summary's classifier
read as imprecise where the old walk read the field's normal form.
`hir::summaries::Arguments` now reads every argument that is not
already specific in the normal form a field holds it in (961dc07).

**Result** (`audit/declaration-summaries/tools/corpus.tcl`, final code and
fixed reference, 1,272 s): 1,381 types, 12 analyses each (Bearing,
CarriedErrors, both totalities, HashClass, SendClass, MentionsMutable,
MayHoldVector, CanCarry, `decimal::Mentions`, MutableComponent,
ValueStability), 16,572 comparisons of classes and reasons.

| verdict | count |
|---|---:|
| same | 16,087 |
| diverges | 406 |
| bound | 79 |
| **DIFFERENT** | **0** |

* **diverges**: every one is a non-uniform recursion applied to an affine
  argument (a coroutine handle, or a `std::ffi::c::Ptr`): W 120, GrowA 62,
  GrowB 62, PhantomRec 62, Mixed 46, GrowV 31, NonUniformFn 23, counting
  the Lists, vectors, structs and function types that hold them. These are
  the types the old walks could not finish, the ones `Unfolding` used to
  reject where they were written. The summaries answer every one.
* **bound**: 79 answers differ where the old walk read a field type the
  type bound had cut:
  * `GrowV[Box[int]]` and what holds it (65): total, sendable and stable
    where the old walk read `Box^6[any]` as unknown;
  * `Deep[...]` (12): `values: List[List[T]]` with a function argument.
    The old walk read the function past the bound as a cut type, so it
    found unknown totality and SendClass, and no bearing or carriable
    function. The summary answers none, bearing and can-carry;
  * `ListFn[...]` (2): bearing where the old walk saw a cut function type.

  By analysis: Bearing 4, CanCarry 2, equality 14, hash 14, HashClass 14,
  SendClass 17, ValueStability 14. Every one is the more precise answer,
  and none turns a refutable class into `total`.
* **Reasons.** The whistle stopped 25 walks. 10 reasons came from the
  fallback; every one printed names the deciding argument (all on `Deep`),
  and none uses the generic recursion text.

The run before the reference fix counted 33 of these 406 as `same`: those
were the old MutableComponent's swallowed walks, whose `""` happened to
equal the summary's. Every other verdict was the same in both runs, and
the per-question walk changed no reason the corpus compares.

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
verdicts of section 17), the old walk stopped after 100 field reads
(`-budget`) or at a type of more than 4,000 characters.

What the fuzzer found, each fixed:

* **The compiler**, two defects of the reason walks, never of a class:
  * An argument's classification started a reason walk of its own, which
    never ended on a growth through another declaration's application
    (seed 11; section 10, 7bb86da; `pds-reason-classification-terminates`).
  * A reason walk revisited an application once per path, which is
    exponential (seed 31; section 10, faaadb1; `pds-reason-walk-
    polynomial`).
* **The oracle.** Its worklist could lower a node's value that a nested
  solve had raised during the node's own computation (a cycle through it),
  and oscillate. Seed 31's program grew the oracle's memory without end. A
  node's value now only rises: it is joined with what the nested solve set
  (6ff72ca). The selftest has no case of it; seed 31 is the reproducer.
* **The reference.** The old MutableComponent swallowed its own budget
  error and Tcl's nesting limit (seed 41; section 17, 73e9515).

**Results**, on the final code. Every seed generates 25 programs and asks 25
types of each.

*Against the oracle and the old walks* (`-reference 1`, the fixed
reference; 625 queries a seed, so 625 oracle checks and 7,500 comparisons
with the old walks):

| seed | non-uniform programs | same | bound | diverges | DIFFERENT | whistles | fallbacks | failures |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 11 | 16 | 7,023 | 15 | 462 | 0 | 24 | 0 | 0 |
| 31 | 14 | 6,898 | 75 | 527 | 0 | 5,896 | 0 | 0 |
| 41 | 14 | 7,110 | 75 | 315 | 0 | 120 | 0 | 0 |

Seed 31's program 17 is the `Braid` declaration of section 10. Before the
per-question walk, its reason walks did not finish.

*Against the oracle alone* (`-reference 0`):

| seed | non-uniform programs | queries | whistles | fallbacks | failures |
|---:|---:|---:|---:|---:|---:|
| 21 | 11 | 625 | 2 | 0 | 0 |
| 51 | 11 | 625 | 136 | 0 | 0 |
| 61 | 15 | 625 | 8 | 0 | 0 |
| 71 | 12 | 625 | 0 | 2 | 0 |
| 81 | 10 | 625 | 26 | 4 | 0 |
| 91 | 10 | 625 | 0 | 0 | 0 |

In all, 5,625 queries over 225 programs (113 with a non-uniform recursion)
were answered by the compiler exactly as by the independent model, for
affinity, Bearing, both totalities, carried errors and MentionsMutable.
7,500 comparisons for each of three seeds matched the old walks wherever
they finished on uncut types. The six fallbacks of seeds 71 and 81 are
reasons only: the oracle-only runs print no reasons, so whether each names
an argument is not recorded.

## 19. Mutation testing

`audit/declaration-summaries/tools/mutate.tcl` runs the 37 mutants in its
`mutants.txt`. Its detectors are six test files and the fuzzer:

* `tests/parameterized-declaration-summaries.test`, without the corpus
  test (the fuzzer's comparison with the old walks covers it, in a
  fraction of the time);
* `written-affine-applications`, `hashable`, `value-identity`,
  `typed-callable-escape` and `structural-contract-completions`;
* `fuzz.tcl -programs 6 -queries 15 -seed 5`, which checks against both the
  oracle and the old walks.

Each test file gets a private `-tmpdir`, and a detector that does not
finish within its timeout kills the mutant. The harness first runs the
detectors on the unmutated copy (the control). A detector that fails or
does not finish there would kill every mutant, so the run stops.

**Result** (final code, fixed reference): **37 mutants, 37 killed, 0
survived**. The test files alone kill every one; the fuzzer kills 27 of
them as well. Each control passed in 51 to 57 s.

| mutant | verdict | tests (failed) | fuzzer |
|---|---|---|---|
| `fixpoint-one-round-early` | killed | 9 (`hb-list-of-callables-not-hashable`, `pds-mutual`, `pds-nested-arguments`, ...) | did not finish |
| `fixpoint-never-revisits` | killed | 8 (`hb-list-of-callables-not-hashable`, `pds-mutual`, `pds-nested-arguments`, ...) | did not finish |
| `summary-keyed-by-name` | killed | 1 (`pds-identity-not-name`) | survived |
| `summary-survives-reset` | killed | 2 (`pds-counters-nonuniform`, `pds-isolation`) | did not finish |
| `slot-order-swapped` | killed | 2 (`pds-mixed`, `pds-total-lowering`) | 29 failures |
| `last-slot-ignored` | killed | 12 (`callable-escape-any-beside-typed-parameter-rejected`, `callable-escape-any-parameters-with-errors-rejected`, `pds-identity-not-name`, ...) | 37 failures |
| `every-slot-relevant` | killed | 32 (`callable-escape-any-parameters-unrestricted`, `pds-mixed`, `pds-mutual`, ...) | did not finish |
| `no-slot-relevant` | killed | 13 (`callable-escape-any-beside-typed-parameter-rejected`, `callable-escape-any-parameters-with-errors-rejected`, `pds-identity-not-name`, ...) | 72 failures |
| `own-omitted` | killed | 5 (`hb-hash-static-rejection`, `hb-list-of-callables-not-hashable`, `hb-struct-with-callable-not-hashable`, ...) | 66 failures |
| `union-every-slot` | killed | 7 (`pds-carried-union`, `pds-isolation`, `pds-mixed`, ...) | 20 failures |
| `fixpoint-pessimistic` | killed | 13 (`hb-witness-census`, `pds-mixed`, `pds-mutual`, ...) | did not finish |
| `fixpoint-optimistic-unrevised` | killed | 8 (`hb-list-of-callables-not-hashable`, `pds-mutual`, `pds-nested-arguments`, ...) | did not finish |
| `bearing-own-fields-ignored` | killed | 1 (`pds-nonuniform-own`) | 33 failures |
| `bearing-slot-ignored` | killed | 8 (`callable-escape-any-beside-typed-parameter-rejected`, `callable-escape-any-parameters-with-errors-rejected`, `pds-identity-not-name`, ...) | 15 failures |
| `bearing-phantom-contributes` | killed | 6 (`pds-identity-not-name`, `pds-isolation`, `pds-mixed`, ...) | 38 failures |
| `bearingnamed-other-summary` | killed | 60 (`callable-escape-any-parameters-unrestricted`, `hb-public-hash-pinned`, `pds-mixed`, ...) | 4 failures |
| `bearing-unfolds-again` | killed | did not finish | survived |
| `carried-item-dropped` | killed | 5 (`pds-carried-union`, `pds-isolation`, `pds-mixed`, ...) | did not finish |
| `carried-slot-ignored` | killed | 5 (`pds-carried-union`, `pds-isolation`, `pds-mixed`, ...) | did not finish |
| `carried-first-only` | killed | 1 (`pds-carried-union`) | 2 failures |
| `carried-unfolds-again` | killed | did not finish | 36 failures |
| `totality-unknown-as-total` | killed | 1 (`hb-witness-census`) | survived |
| `totality-none-as-unknown` | killed | 14 (`hb-hash-static-rejection`, `hb-struct-with-callable-not-hashable`, `hb-witness-census`, ...) | 124 failures |
| `totality-field-ignored` | killed | 13 (`hb-list-of-callables-not-hashable`, `hb-witness-census`, `hb-witness-not-user-definable`, ...) | 40 failures |
| `totality-phantom-poisons` | killed | 11 (`pds-counters-nonuniform`, `pds-identity-not-name`, `pds-isolation`, ...) | 68 failures |
| `totality-slot-ignored` | killed | 10 (`pds-identity-not-name`, `pds-isolation`, `pds-mixed`, ...) | 16 failures |
| `totality-total-too-early` | killed | 5 (`hb-list-of-callables-not-hashable`, `pds-mutual`, `pds-nested-arguments`, ...) | 32 failures |
| `totality-none-too-early` | killed | 8 (`hb-witness-census`, `pds-mixed`, `pds-mutual`, ...) | 68 failures |
| `hashable-rejects-total` | killed | 9 (`pds-mixed`, `pds-mutual`, `pds-nested-arguments`, ...) | survived |
| `totality-unfolds-again` | killed | did not finish | survived |
| `totality-depth-limit` | killed | 1 (`pds-no-depth-threshold`) | survived |
| `unfolding-retained` | killed | 6 (`pds-interchange`, `pds-owned-recursion-kept`, `pds-total-lowering`, ...) | survived |
| `growing-argument-rejected` | killed | 6 (`pds-interchange`, `pds-owned-recursion-kept`, `pds-total-lowering`, ...) | survived |
| `owned-recursion-allowed` | killed | 2 (`wd-recursive-message`, `wd-recursive-rejected`) | survived |
| `schema-unfolds-phantom` | killed | did not finish | survived |
| `answers-outlive-declarations` | killed | 1 (`pds-isolation`) | 40 failures |
| `answers-remembered-provisionally` | killed | 6 (`hb-list-of-callables-not-hashable`, `pds-mutual`, `pds-nested-arguments`, ...) | 33 failures |

("did not finish": the detector ran to its 900 s timeout. That is the
designed verdict for the four mutants that bring an unfolding back, since a
walk that unfolds a non-uniform recursion with an affine argument never
ends. Where the fuzzer did not finish otherwise, it was still printing the
failures it found.)

One mutant survived on the first full run: `totality-depth-limit`, a class
decided by the length of an application's text. No test asked about a type
longer than `W[List^8[C]]`, and the fuzzer's types are small.
`pds-no-depth-threshold` now asks about `W[List^N[C]]`, `Mixed[int,
List^N[C]]` and `Box^N[C]` at N = 1, 8, 24, 48 and 96. An affine argument
is never cut by the type bound, so `Box^96[C]` is a type of 1,605
characters. The test requires every answer to equal the one at depth 1,
and it kills the mutant.

The run was split into three parallel harness runs after the first three
mutants, with a control each. Those first three ran with the reference
before its fix, and the test files killed all three.

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
* `audit/hashable/tools/mutants.txt`, two mutants:
  * `struct-ignores-non-hashable-field` did not apply even at this
    branch's base: its text occurs in both Totality's and SendClass's
    `Components`. `main` has since repaired it the same way. It now also
    edits `TotalityNode`, where a struct's class is decided.
  * `recursive-struct-not-hashable` *survived* on this branch (7bb86da). It
    edited Totality's `$type in $seen`, which no longer decides a class:
    taking a struct met again for `unknown` there only changes a reason. Its
    rule now lives where a declaration met again through its own fields is
    decided, the start of the totality summaries' fixpoint
    (`hir::summaries::Bottom`). It now starts them at `unknown`. That is a
    different defect from `totality-none-too-early` in this milestone's
    own catalog, which starts them at `none`.

Every mutant of every catalog that edits a file this milestone changed
applies to the new code (each replaced text occurs exactly once). `main`'s
`tools/mutant-catalogs.tcl` finds 11 mutants elsewhere that do not apply;
all of them predate this branch, and `main` has repaired them (section 22).
Beyond the retargeted ones, every mutant of another
harness whose text lies inside a procedure this milestone changed was run
on the final code (the hashable survivor above shows why: a mutant can stay
applicable while the code around it stops deciding anything). 40 mutants
were run, and all were killed by their own harnesses' detectors:

| harness | mutants | killed |
|---|---:|---:|
| hashable (every mutant of `hir/types.tcl`) | 7 | 7 (one after its retarget) |
| affine | 8 | 8 |
| trait-constrained-types | 9 | 9 |
| tree-struct | 4 | 4 |
| value-identity | 3 | 3 |
| value-transfer | 8 | 8 |
| mutable-vector | 1 | 1 |

Which code each ran on:

* The retargeted affine, tree-struct, value-identity and value-transfer
  mutants (11) ran on 1e0a96b's compiler code.
* Six of the hashable mutants ran on 7bb86da's.
* The other 23, the retargeted `recursive-struct-not-hashable` among them,
  ran on faaadb1's.

The later commits change no class that the earlier mutants decide: they
change only reason texts, how an argument is classified inside a reason
walk, and the walk's cost.

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

`bench/declaration-summaries.tcl -budget 20000` answers every migrated
analysis (both totalities, Bearing, CarriedErrors, SendClass,
MentionsMutable, MayHoldVector, CanCarry) on six families of specimens, from
fresh summaries. It also runs the old walks (`reference.tcl`) on the same
questions, stopped after 20,000 field reads or at a type of more than 4,000
characters (`budget`). The numbers were measured on the final code, on a
4-core container with two other audit jobs running, so wall times are
indicative. The counters do not depend on load; they are the same as before
the per-question walk, which these specimens never need.

| family | N | wall (ms) | computations | memo hits | declarations | applications | rounds | old walks (ms) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| chain | 6 | 218.6 | 966 | 2028 | 56 | 2084 | 24 | 146.7 |
| chain | 12 | 318.8 | 1794 | 4056 | 104 | 4160 | 24 | budget |
| chain | 24 | 597.5 | 3450 | 8112 | 200 | 8312 | 24 | budget |
| chain | 48 | 1441.5 | 6762 | 16224 | 392 | 16616 | 24 | budget |
| chain | 96 | 3688.1 | 13386 | 32448 | 776 | 33224 | 24 | budget |
| nested | 6 | 2.5 | 54 | 40 | 8 | 48 | 16 | 2.5 |
| nested | 12 | 4.1 | 54 | 88 | 8 | 96 | 18 | 7.0 |
| nested | 24 | 9.5 | 54 | 184 | 8 | 192 | 18 | 26.1 |
| nested | 48 | 34.8 | 54 | 376 | 8 | 384 | 18 | 122.5 |
| nested | 96 | 154.9 | 54 | 760 | 8 | 768 | 18 | 733.5 |
| nonuniform | 6 | 6.8 | 46 | 49 | 8 | 57 | 13 | budget |
| nonuniform | 12 | 7.5 | 46 | 49 | 8 | 57 | 13 | budget |
| nonuniform | 24 | 13.4 | 46 | 49 | 8 | 57 | 13 | budget |
| nonuniform | 48 | 26.0 | 46 | 49 | 8 | 57 | 13 | budget |
| nonuniform | 96 | 77.5 | 46 | 49 | 8 | 57 | 13 | budget |
| mutual | 6 | 21.5 | 294 | 205 | 43 | 248 | 16 | budget |
| mutual | 12 | 44.7 | 582 | 403 | 85 | 488 | 16 | budget |
| mutual | 24 | 83.6 | 1158 | 799 | 169 | 968 | 16 | budget |
| mutual | 48 | 171.6 | 2310 | 1591 | 337 | 1928 | 16 | budget |
| mutual | 96 | 418.3 | 4614 | 3175 | 673 | 3848 | 16 | budget |
| wide | 6 | 51.3 | 231 | 144 | 8 | 152 | 15 | 5.9 |
| wide | 12 | 178.0 | 447 | 276 | 8 | 284 | 15 | 11.0 |
| wide | 24 | 731.3 | 879 | 540 | 8 | 548 | 15 | 21.6 |
| wide | 48 | 2626.5 | 1743 | 1068 | 8 | 1076 | 15 | 39.4 |
| wide | 96 | 10814.9 | 3471 | 2124 | 8 | 2132 | 15 | budget |
| repeated | 6 | 15.1 | 133 | 139 | 8 | 147 | 23 | 12.0 |
| repeated | 12 | 16.7 | 133 | 169 | 8 | 177 | 23 | 24.5 |
| repeated | 24 | 23.3 | 133 | 229 | 8 | 237 | 23 | 52.8 |
| repeated | 48 | 39.0 | 133 | 349 | 8 | 357 | 23 | 101.9 |
| repeated | 96 | 57.9 | 133 | 589 | 8 | 597 | 23 | 192.2 |

(`declarations` counts summaries made, one per declaration per property;
`computations` counts node evaluations, a declaration's at the neutral
argument and at each probe in each round; `applications` counts answers
read from a summary.)

* **chain** (N declarations, each reaching the previous one twice and
  itself): computations, summaries and applications grow linearly (about
  140 computations per level), in a constant 24 rounds. The old walks did not
  finish from N = 12 on: a path-based walk visits each declaration once per
  path, and the paths double at every level. At N = 6 the old walk is
  faster (147 ms against 219): making 56 summaries (seven declarations,
  eight properties) costs more than walking so few paths once.
* **nested** (`Box` applied N deep): one declaration, so 54 computations
  whatever N. The questions read 8 applications per level, and the memo
  answers every repeated class. That makes it 4.7 times faster than the
  old walk at N = 96. Before the application memo (section 10), N = 96 took
  3.3 s, because every level classified the level below again.
* **nonuniform** (`W[List^N[C]]` of `next: List[W[List[T]]]`): every counter
  is constant. The question is answered from W's summary and its argument's
  class; only the argument's own size grows. The old walks do not finish at
  any N: `C` is affine, so the type bound never cuts it.
* **mutual** (a ring of N declarations, each nesting its slot in a List
  for the next): linear. The old walks do not finish.
* **wide** (one declaration of N slots, each held in a List): computations
  are linear, but each one substitutes N arguments into N + 1 fields, so the
  wall time is O(N³). This is 10.8 s at N = 96, against the old walks' 6 to
  39 ms up to N = 48, and the one family where the summaries are slower
  (section 24). At N = 96 the old walk's `budget` is the reference's type
  cap: the 96-argument application is a type of more than 4,000 characters.
  Before that cap existed, the same walk took 77 ms.
* **repeated** (N applications of one declaration to N arguments):
  computations are constant (133). Each further question reads the
  summaries, so it takes about a third of the old walks' time at N = 96.

No family grows exponentially, and none unfolds an application; every
family's rounds are constant in N.

**Real programs.** The figures below are the front end's time
(`surface::readProgramFile`, best of three, each in a fresh process) on
golden suites that use parameterized structs, Hashable, identity structs
and callables. Base tree (17b0e66) and this branch ran alternately, suite
by suite, on the same loaded machine.

| suite | base (ms) | branch (ms) | change |
|---|---:|---:|---:|
| hashable.bot | 6,568 | 6,281 | -4.4% |
| trait-constrained-types.bot | 8,594 | 9,076 | +5.6% |
| value-identity.bot | 18,260 | 17,889 | -2.0% |
| immutable-map.bot | 69,373 | 69,467 | +0.1% |
| tree-struct.bot | 15,035 | 15,043 | +0.1% |
| mutable-map.bot | 22,590 | 24,344 | +7.8% |
| callables.bot | 19,111 | 19,914 | +4.2% |
| structs-and-enums.bot | 20,223 | 20,634 | +2.0% |
| total | 179,754 | 182,648 | +1.6% |

The changes go both ways and lie within what the machine's load moves
from run to run. Real programs' declarations are few and small, so the
summaries' cost, like the walks' before them, is a small part of a front
end's time.

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

**Main's CI when the branch started.** The branch starts at 17b0e66.
`main`'s `tests` workflow had no completed run there: the runs of 17b0e66
and of the two commits after it were cancelled by later pushes. Its last
completed run (bdd5e3d8, November 4) failed six jobs: `tests (interp)`,
`tests (compile)`, the cranelift and cranelift-generic coverage jobs,
`tests (native GC-stress)` and `tests (system-linked executables)`. The
golden shards, the stub-linked executables, the warning gate, the
method-call decision job and the native Rust unit tests passed. `main`'s
merge c6269fd (after this branch's base) names the remaining red as three
test defects, none in the compiler: `pn-concurrent-target-compiles`,
`pa-add-refusals` (an AArch64 cross linker the runners lack) and
`pa-pack-refuses-incomplete`. It also repaired eleven mutants in nine
catalogs that no longer applied, and added `tools/mutant-catalogs.tcl`.
Until the merge of e6c1d05 (next) this branch did not contain those fixes,
so its CI before it is compared with that list.

**The full local run** (`tests/local.tcl -jobs 3`, 8,977 s): 267 Tcl
test files on interp and compile, and the 117 golden suites on all four
backends through the front-end cache. It started on the milestone's first
commit (0428fa3). 961dc07, ddd101b and 1cf05eb were committed while it ran,
so files it started later ran that later code.

| part | result |
|---|---|
| golden suites | 117 run, 0 failed; interp 5,589/5,589, compile 5,589/5,589, cranelift-generic 5,497/5,497, cranelift 5,599/5,599 |
| Tcl tests, interp | 8,714 passed, 4 failed, 206 skipped (2,474 golden duplicates) |
| Tcl tests, compile | 8,709 passed, 4 failed, 211 skipped (2,474 golden duplicates) |

The failures were `package-authoring.test`'s `pa-add-refusals` on both
passes (`main`'s defect above), and three of `compilerpedia.test` on both
passes: the new topic's summary length, a line length and an alias. Those
were fixed in 1e0a96b, and `compilerpedia.test` then passed 42/42.

**After the later fixes** (the canonical arguments and the memo of 961dc07,
the reasons past the bound, the class-only classifications of 7bb86da, the
per-question walk of faaadb1), every test file whose answers or reasons
those changes can reach was run again on the final code, each passing:

| test file | tests |
|---|---:|
| parameterized-declaration-summaries | 24 (its small parity corpus included, against the fixed reference) |
| written-affine-applications | 26 |
| hashable | 48 |
| value-identity | 33 |
| immutable-map | 26 |
| trait-constrained-types | 77 |
| sendability | 82 |
| typed-callable-escape | 42 |
| structural-contract-completions | 45 |
| tree-struct | 45 |
| value-transfer | 76 |
| mutable-vector | 68 |
| decimal-rounded | 42 |
| affine-applications | 21 |

Before the per-question walk, the same set plus refinement-values (88),
affine (48), higher-order-completions (62), error-payloads (62), structs
(89), semantic-instances (80), c-abi-types (73), static-economics (93),
compilation-isolation (19), hir-interchange (11) and hir-cache (19) passed
on 7bb86da. Under `BOTLISH_NATIVE_GC_STRESS=1`, the summaries test file
(20/20, 1 skipped) and written-affine-applications (26/26) passed.

`main`'s `tools/mutant-catalogs.tcl`, run against this tree, finds 85
catalogs and 3,003 mutants. Its 11 problems are the 11 `main` repaired,
none in a catalog this milestone touches.

**Merges of `main`.** `main` was merged into the branch four times as it
moved, without a conflict each time:

| merge | `main` at | what `main` brought |
|---|---|---|
| e6c1d05 | 13dd290 | per-thread runtime state, the three test-defect fixes above, `tools/mutant-catalogs.tcl`, run cancellation and the release gate |
| 2aedd83 | 5872c80 | the CI canary |
| 889c5c4 | 418bae3 | counted-loop precision in the emission checker (`hir/range.tcl`, `hir/emission.tcl`), run pruning without a concurrency group |
| 1e1fe84 | a9479ef | one canonical instance per package in the application's dependency graph (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md: `surface/modules.tcl`, `pm/`), the canary job's steps, the scalar assembly audit corpus |

The files both sides changed were checked by hand: AGENTS.md,
docs/INDEX.md, `audit/value-identity/tools/mutants.txt`,
`audit/golden/migration/tcl-names.txt` and `tests/golden/manifest.tsv`
had disjoint hunks, and `audit/hashable/tools/mutants.txt` holds `main`'s
repair of `struct-ignores-non-hashable-field`, the same `lassign` line
this branch added, once. After each merge the manifest that
`audit/golden/migration/merge.tcl` regenerates equals the merged one, and
`tools/mutant-catalogs.tcl` finds no problem (86 catalogs, 3,055 mutants
after the last).

* **e6c1d05**, the full local run (`tests/local.tcl`, 4 jobs, 6,824 s),
  with 0 failures:
  - 268 Tcl test files: 8,732 passed on interp, 8,727 on compile;
  - the 117 golden suites on every backend: interp 5,589/5,589, compile
    5,589/5,589, cranelift-generic 5,497/5,497, cranelift 5,599/5,599.
* **2aedd83**: `tests/canary.test` 11/11 and `tools/ci/test_runs.py` (43
  tests).
* **889c5c4**: the files `main`'s change and this milestone's touch, on
  interp and compile, with the golden suites of their tests (`tests/local.tcl`
  narrowed), 0 failures:
  - emission-claims 95, interval-sets 37, csv-emission 36, hir-range 71,
    parameterized-declaration-summaries 24, hashable 39 (and its 9
    duplicates as golden tests), written-affine-applications 26, canary 11;
  - hashable.bot, hashable-admission.bot and range-and-contract-values.bot
    on all four backends.
* **1e1fe84**, the same way, 0 failures:
  - bot-modules 68 (1 skipped), package-manager 86, package-native 38 (1
    skipped), static-compile 55 (and its 28 duplicates as golden tests),
    warning-gate 6, parameterized-declaration-summaries 24, hashable 39,
    written-affine-applications 26, canary 11;
  - static-compile.bot, diagnostics.bot, errors.bot, hashable.bot and
    hashable-admission.bot on all four backends;
  - `tools/compilerpedia.tcl check`: 1,220 topics, 745 examples, 0
    problems.

**CI on the branch.** Status when this section was last written. Pending
runs are pending: none is counted as passed.

| workflow | commit | result |
|---|---|---|
| `static-decisions` (dispatched) | 961dc07 | **passed**: plan, four shards and mutable-array.bot, batched against sequential |
| `tests (linux arm64)` (dispatched) | 0a9398b | **passed**: all 12 jobs (interp, compile, the four golden shards, cranelift and cranelift-generic coverage, GC stress on interp and compile, the Rust unit tests with and without GC stress, the system-linked executables) |
| `tests (windows x86-64)` | 0a9398b | **passed** |
| `tests (macos arm64)` | 0a9398b | **failed**: one test, `pn-concurrent-target-compiles` (the system-linker job), `main`'s defect above (its wait probed `/proc`, which macOS does not have); every other job passed. e6c1d05 merges `main`'s fix |
| `icy-tower (macos arm64)`, `icy-tower (windows x86-64)` | e6c1d05 | **passed** |
| `raven clean room`, `package reproducibility`, `ci tools` | e6c1d05 | **passed** |
| `tests` (Linux x86-64, dispatched) | 889c5c4 | **passed** |
| `tests (linux arm64)` (dispatched) | 889c5c4 | **passed** |
| `tests (macos arm64)`, `tests (windows x86-64)` | 889c5c4 | **passed** |
| `icy-tower (macos arm64)`, `icy-tower (windows x86-64)` | 889c5c4 | **passed** |
| `ci tools` | 889c5c4 | **failed**: GitHub's API answered HTTP 502 to `tools/ci/history.py`'s read of a run's jobs; the job's tests and the gate's and the pruning's dry runs before it had passed |
| every workflow | 1e1fe84 | **pending**: the last merge's push runs |

Infrastructure, not product:

* The first `tests` (Linux x86-64) run of this branch to finish is
  889c5c4's. Each one dispatched before waited for a runner until the
  next push to the branch replaced it (the workflows' concurrency rule;
  since 5872c80 a branch push starts its canary, so the dispatched run is
  replaced by the push's run, and dispatched again).
* `main` when the branch was merged into it was a9479ef, the scalar
  assembly audit's write-back, which no workflow runs; its parent
  1f076e1's runs: `tests (linux arm64)`, macOS, Windows,
  `static-decisions`, c-bindgen, the single executable and the icy-tower
  workflows passed; `tests` had 13 of its 14 jobs passed, GC stress still
  running (pending); `raven clean room` and `package reproducibility`
  failed building the author image, where apt found no package in the
  pinned Ubuntu snapshot (20261101T000000Z) before any of the
  repository's code ran. The same two passed on this branch's e6c1d05.

The commits after 961dc07 change the reason texts and the reason walks'
cost, never a class, a diagnostic kind or a fact the static-decision
schedulers read. So `static-decisions` was not dispatched again: its
runners are the same scarce Linux pool.

## 23. Remaining recursive type walks

After this milestone, the walks of the census that still recurse into an
application's applied fields, each justified:

| walk | why it stays a walk |
|---|---|
| `hir::structs::OwnedRecursion` | a rule of ownership on affine types (section 15); its bound is the one threshold left that can decide a verdict |
| `hir::affine::Descriptor` | builds a structure (a drop descriptor) for an affine type OwnedRecursion accepted: finite by that check |
| `hir::transfer::Schema` | builds a structure (the schema); finite because unrestricted arguments are bounded and phantom affine ones erased (section 14) |
| reason walks of `Totality`, `SendClass`, `MutableComponent`, `ValueStability` | presentation of a class the summary decided; pruned, stopped on growth by Whistle, each application walked once per question (section 10) |
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
  recursion the reason text may name a shorter path than the old walk's.
  Where the old walk finished, it reported a part it found only after the
  bound cut its arguments. Where the only deciding part sits past the bound,
  the reason names the deciding argument instead of a field path (section
  10). Because a later path reuses an application's first walk, a reason
  can in principle differ from the old walk's on a type it finished on. The
  corpus and the fuzzer found no case of it.
* **Many-slot declarations cost more than they used to.** A declaration of
  N slots costs one node computation per slot per probe, and each
  computation substitutes N arguments into N fields, which is O(N³) in all.
  `bench/declaration-summaries.tcl`'s `wide` family (one declaration of N
  slots, each in a List, plus a List of itself) is the one where the old
  walks were faster (section 20). No declaration in the standard library,
  the examples, the packages or the golden suites has more than two slots.
  A node that substituted only the probed slot would be O(N²), because the
  other slots stay neutral and their fields could be shared. This milestone
  does not do that.
* **Precision gained at the bound, so behavior can change there.** Where the
  old walk read a cut argument, the new answer is the uncut type's: more
  Hashable witnesses (GrowV), and, symmetrically, a struct whose deep
  argument holds a function is now `none` (TRAIT-NOT-SATISFIED where a
  `checked` hash was dynamic) and bearing (an erasure is rejected that was
  silently accepted). Both are the sound answers. The parity corpus shows
  both kinds on its own declarations only (GrowV; Deep and ListFn). No
  test of the full local run, golden suites included, failed for a changed
  answer (section 22).
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
