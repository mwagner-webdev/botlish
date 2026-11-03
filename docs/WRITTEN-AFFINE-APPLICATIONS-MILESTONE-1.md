# WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md

> A written type application may contain an affine type argument only where
> the application's semantics do not create an unrestricted way to obtain,
> copy, erase or duplicate values of that argument.

A compiler milestone that removes an obsolete admission rule. No syntax,
ownership feature, affine root, container policy or representation was
added; no HIR, HIR text, interchange format or cache key changed.

## Contents

1. [Result](#1-result)
2. [Starting asymmetry](#2-starting-asymmetry)
3. [Architecture census](#3-architecture-census)
4. [Concrete written applications](#4-concrete-written-applications)
5. [Affinity versus value positions](#5-affinity-versus-value-positions)
6. [Whether `AffinitySummary.relevant` was reused](#6-whether-affinitysummaryrelevant-was-reused)
7. [Generic/imprint safety](#7-genericimprint-safety)
8. [Parameters](#8-parameters)
9. [Results](#9-results)
10. [Fields](#10-fields)
11. [Nested applications](#11-nested-applications)
12. [Recursive affine applications](#12-recursive-affine-applications)
13. [Phantom applications](#13-phantom-applications)
14. [Function-type and pointer cases](#14-function-type-and-pointer-cases)
15. [Containers](#15-containers)
16. [Diagnostics](#16-diagnostics)
17. [HIR/interchange/isolation](#17-hirinterchangeisolation)
18. [Oracle/fuzzing](#18-oraclefuzzing)
19. [Mutation testing](#19-mutation-testing)
20. [Performance](#20-performance)
21. [Regression/CI](#21-regressionci)
22. [Explicit limitations](#22-explicit-limitations)
23. [Recommendation for the next milestone](#23-recommendation-for-the-next-milestone)

## 1. Result

The acceptance statement holds:

* **A parameterized type application is not rejected merely because one of
  its type arguments is affine.** `hir::resolve::ResolveApplied` no longer
  refuses an affine argument ("a type slot takes an unrestricted type"); it
  builds the one canonical application and asks
  `hir::structs::WrittenProblem` whether that type is one a value can have.
* **Writing an applied type changes nothing the same type has when
  inferred.** A written application is the identical type term an inferred
  one is (`wd-written-is-inferred`: the same type, affinity, drop descriptor
  and account of why it is affine, for seven applications), so every
  ownership, drop, equality, hash and container decision -- each of which
  asks `hir::types::IsAffine` of the type it has -- agrees
  (`wd-written-is-inferred-ownership`, the fuzzer's inferred twins).
* **A generic body is never handed an affine value through a type variable
  it was checked to treat as unrestricted.** Imprinting still binds a
  variable to an affine type only where no value of it exists
  (`hir::imprint::BindingProblem`, unchanged); what changed is *where values
  exist*: an application's argument now stands where its slot stands in the
  declaration's fields (`hir::structs::SlotPositions`), not at a value
  position by default.

| written | declaration | result |
|---|---|---|
| `Box[Coroutine{...}]` | `struct Box[T]: value: T` | writable, affine |
| `Phantom[Coroutine{...}]` | `struct Phantom[T]: value: int` | writable, unrestricted |
| `Outer[Coroutine{...}]` | `struct Outer[T]: inner: Inner[T]` | writable, affine |
| `Node[Coroutine{...}]` | `struct Node[T]: value: T, children: List[Node[T]]` | affine, then AFFINE-CONTAINER-UNSUPPORTED (recursive affine ownership) |
| `fn f(b: Box[T])`, T := a handle | | IMPRINT: the body can obtain a T (`b.value`) |
| `fn f(p: Phantom[T])`, T := a handle | | accepted: no value of T exists |

What changed:

* **Admission** (`hir/resolve.tcl`, `hir/structs.tcl`): the blanket check is
  gone. A written application is rejected only when it is no type at all: a
  recursive affine type (`OwnedRecursion`, the previous milestone's rule,
  now applied where a type is written, not only where one is constructed),
  or a type with no finite form (`Unfolding`, new: section 12).
* **Slot positions** (`hir/structs.tcl`, `hir/imprint.tcl`): a declaration
  fact -- for each slot, the positions (`value`, `pointee`, `cvalue`,
  `csignature`, or none) `hir::imprint::Occurrences` gives it in the
  declaration's own field types -- computed by a least fixpoint
  (`Fixpoint`, now shared with the affinity summary), kept per registration
  and forgotten with the affinity facts. `Occurrences` places each argument
  of an application at its slot's positions (`Placed`); a slot at none is
  reported at the new position `argument` (a type only).
* **Imprints that make an application with no finite form** are refused at
  the call (`hir::imprint::UnfoldingProblem`), since a phantom slot may now
  be bound to an affine type.
* **Tests and documents that pinned the old rule** were updated: the
  trait-constrained-types test and its golden port (an affine argument is
  accepted), the actor test's affine message (rejected at the `post` that
  would move a message, no longer at `open`, which holds no message: section
  7), TRAIT-CONSTRAINED-IMPRINTED-TYPES.md, AFFINE-VALUES.md,
  C-ABI-TYPES.md, SAME-THREAD-ACTORS-MILESTONE-1.md, Compilerpedia's
  `concept.parameterized-structs` and `error.imprint` (two new checked
  examples), AGENTS.md.

## 2. Starting asymmetry

Reproduced before any change (`wd-starting-asymmetry` pins every row as
accepted now):

| program | before | after |
|---|---|---|
| `fn wrap(x): Box {value: x}` then `wrap(make(1))` (inferred) | accepted, affine | the same |
| `fn consume(job: Box[Coroutine{...}]) -> int` | TYPE: "the argument for slot T of Box is the affine type Coroutine{...}: a type slot takes an unrestricted type (its values may be copied wherever the slot's type is used)" | accepted, an affine parameter |
| `fn mk() -> Box[Coroutine{...}]` | TYPE (the same) | accepted, an affine result |
| `struct Holder: job: Box[Coroutine{...}]` | TYPE, at the field | accepted, Holder affine |
| `Box[Coroutine{...}] {value: make(1)}` | TYPE, "invalid applied type" | accepted |
| `fn f(x: Phantom[Coroutine{...}])` | TYPE, though `Phantom[Coroutine{...}]` is unrestricted | accepted, unrestricted |
| `fn f(x: Phantom[T])` called with `Phantom[Coroutine{...}]` | IMPRINT ("values of T exist") | accepted |
| `fn g(n: Node[Coroutine{...}])` | TYPE (the slot rule) | AFFINE-CONTAINER-UNSUPPORTED (recursive ownership) |

## 3. Architecture census

Every place that decides whether an affine type may stand as a type
argument or an imprint binding, and what this milestone did there:

| place | decides | change |
|---|---|---|
| `hir::resolve::ResolveApplied` | a written application (every type position: parameters, results, fields, payloads, Fn types, List elements, explicit constructions, explicit imprints, trait requirements) | the affine-argument rejection removed; `WrittenProblem` asked instead |
| `hir::structs::WrittenProblem` (new) | whether a written application is a type: recursive affine (`OwnedRecursion`), no finite form (`Unfolding`) | new; undecided while `apply` resolves field types (the batch's fields are not all known; `VerifyDeclarations` judges fields) |
| `hir::types::resolveApplication` | List, MutableVector, MutableArray (affine elements allowed), ImmutableSet (affine refused: AFFINE-CONTAINER-UNSUPPORTED) | unchanged |
| `hir::types::MakeApplied` | the bound: an affine application's arguments never cut | unchanged |
| `hir::imprint::Occurrences` | the positions of an imprint variable in a type | an application's argument placed at its slot's positions (`Placed`) |
| `hir::imprint::Positions`, `BindingProblem` | an affine binding refused where values exist; a pointee, C signature checks | unchanged (they read Occurrences) |
| `hir::imprint::Bind` | the call's binding | also `UnfoldingProblem` when an affine type is bound |
| `hir::structs::SlotPositions`, `PositionsOf` (new) | each slot's positions in its declaration's fields | new declaration fact |
| `hir::structs::AffinitySummary`, `IsAffine`, `AffinityOf` | an application's affinity | unchanged (its fixpoint loop moved into the shared `Fixpoint`) |
| `hir::structs::ApplicationIssue`, `verifyApplications`, `VerifyDeclarations` | trait constraints and recursion of applications made or written | unchanged |
| `hir::cabi::ResolveImprint` | an explicit imprint's type | unchanged (it resolves through `ResolveApplied`) |
| semantic instances (`hir/semantic.tcl`), affine specialization (`hir::traits::NeedsAffinePlan`) | when an untyped function gets an instance for an affine argument | unchanged: they ask `IsAffine` |
| `hir/affine.tcl` (moves, erasure, captures, equality, field moves), drop descriptors | ownership | unchanged: they ask `IsAffine` |
| `any` | holds no affine value | unchanged (AFFINE-ERASURE-UNSUPPORTED) |
| rigid imprint variables | `IsAffine {imprint T}` = 0 | unchanged: that is why value positions must stay unrestricted |
| type aliases | none exist (integer domains and refinements have scalar carriers) | -- |
| trait views | not a slot argument (TRAIT-STORAGE-UNSUPPORTED) | unchanged |
| tree structs | judged by the general recursion rule | unchanged |

Found on the way (sections 12 and 22): three type walks unfold
applications without a bound when an argument is never cut --
`hir::callables::Bearing`/`BearingNamed`, `CarriedInto` and
`hir::types::Totality` -- which a non-uniform recursion with an affine
argument (`W[Coroutine{...}]` of `struct W[T]: next: List[W[List[T]]]`)
made loop forever once that type could be written.

The census answers the brief's distinction directly:

* **affinity relevance** -- does an affine argument make the application
  affine? -- is `AffinitySummary`'s `relevant`, about what a value *owns*;
* **value-position relevance** -- can values of this slot exist in (or be
  obtained from) the application, so that generic code may copy them? -- is
  `SlotPositions`, about what a body can *reach*.

They differ (section 6), so they are two facts, one fixpoint machinery.

## 4. Concrete written applications

A concrete written application is an ordinary type: `ResolveApplied` gives
`hir::types::MakeApplied $id $types`, the same canonical term the
construction `Box {value: c}` infers, so nothing downstream can tell them
apart. `wd-written-is-inferred` compares, for `Box`, `Outer`, `Pair[int,
Box[...]]`, `Many`, `Box[Box[...]]`, `Box[Holder]` and `Phantom`, the type of
a binding made through an untyped identity function with the type of one
made through a function declaring the type: equal, with the same affinity,
the same drop descriptor (`s1.0.c`, `s1.0.s1.0.c`, `s1.1.s1.0.c`,
`s1.0.lc`, ...) and the same `AffineThrough` field. `wd-written-is-inferred-
ownership` runs seven operations on each: the same diagnostic each time
(USE-AFTER-MOVE, AFFINE-ERASURE-UNSUPPORTED, AFFINE-EQUALITY-UNSUPPORTED,
AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE, AFFINE-CAPTURE-UNSUPPORTED,
AFFINE-LIST-OPERATION-UNSUPPORTED, AFFINE-EQUALITY-UNSUPPORTED for a hash),
and an unrestricted `Phantom[...]` copied, erased and compared freely both
ways.

## 5. Affinity versus value positions

| declaration | affine with an affine argument? (`relevant`) | values of the slot reachable? (`SlotPositions`) |
|---|---|---|
| `Box[T]: value: T` | yes (`{0 0}`) | value |
| `Phantom[T]: value: int` | no (`{0 {}}`) | none |
| `Outer[T]: inner: Inner[T]` | yes | value (Inner's) |
| `Handler[T]: f: Fn{args: [T], return: int}` | no: a function owns nothing | value (a function type's variable, conservatively: section 14) |
| `Ref[T]: p: std::ffi::c::Ptr[T]` | affine whatever T (`{1 {}}`) | pointee |
| `Job[T]: tag: Coroutine{...}, value: T` | affine whatever T (`{1 {}}`: no slot relevant) | value |
| `W[T]: next: List[W[List[T]]]` | no (least fixpoint) | none (least fixpoint) |
| `Wrap[T]: p: Phantom[T]` | no | none |
| `Mixed[T]: a: Phantom[T], b: Box[T]` | yes | value |

`wd-slot-positions`, `wd-positions-not-relevance` and `wd-occurrences` pin
these. A position is computed with `Occurrences`' own rules over the
declared field types (a slot is `{imprint SLOT}` there), so there is one
statement of positions for a signature and for a declaration:

    positions(S, k) = { p : (slot k, _, p) in Occurrences(field type), p != argument }

and `Occurrences(S[A1..An])` gives each variable inside `Ak` the position
`Ak` substituted at each of `positions(S, k)` gives it (`Placed`): a bare
variable takes the slot's position; a variable inside a composite argument
takes the position the argument's own structure gives it there (a List's
element is a value even when the List is a pointee, as `Ptr[List[T]]`
already said); for a slot at no position every variable of `Ak` is at
`argument`. Names and the establishing flag stay the written argument's
(what a call's argument establishes is its own form, `Match`), so the
variables a signature has, their order (explicit imprints) and what
establishes them are unchanged.

## 6. Whether `AffinitySummary.relevant` was reused

No: the two facts differ, and reusing one for the other would be unsound
in one direction and imprecise in the other.

* `Job[T]` (`tag: Coroutine{...}, value: T`): `AffinityOf` returns `{1 {}}`
  as soon as a declared field is affine -- every application is affine, so
  no slot is "relevant" -- yet `value: T` holds values of T. Read as
  positions, `relevant` would let `fn get(j: Job[T]) -> T` bind T to a
  coroutine and its body duplicate the handle it destructures
  (`wd-generic-box`'s last case is IMPRINT).
* `Handler[T]` (`f: Fn{args: [T], return: int}`): no slot is relevant (a
  function owns nothing), yet a body is handed a function over T. For
  `Getter[T]` (`f: Fn{args: [], return: T}`) the body obtains values of T by
  calling it (`wd-generic-function-type`).
* `Ref[T]` (`p: std::ffi::c::Ptr[T]`): affine by its pointer whatever T, no
  slot relevant, and no value of T exists -- but the slot is not
  unconstrained: it is a pointee, so a binding must be a valid pointee
  (`wd-generic-pointer`).

What is reused is the machinery: the least fixpoint over the declarations a
summary reaches is now `hir::structs::Fixpoint`, which both
`AffinitySummary` and `SlotPositions` call (the same algorithm, the same
discard of an unfinished fixpoint), and both tables are emptied by the one
`ForgetAffinity` at every registry change.

## 7. Generic/imprint safety

The invariant kept: *a body checked for every T, T unrestricted, is never
bound to an affine T where it can obtain a value of T.* `BindingProblem`
refuses an affine binding whenever any occurrence of the variable in the
signature is at a `value` position; what changed is only that an
application's argument is a value position exactly when its slot is. So
the signatures that become legal for an affine binding are exactly those in
which **every** occurrence of the variable is at a `pointee`, C, or
`argument` position: a slot no field holds (`Phantom[T]`, `Wrap[T]` of
`p: Phantom[T]`, `W[T]` of `next: List[W[List[T]]]`), or a pointer's pointee
inside an application (`Ref[T]`, which takes `std::ffi::c::Void` now, as
`Ptr[T]` itself does; an affine T is still refused there, by the pointee
check). Why no such body can obtain an affine value it was checked as
unrestricted:

* No value of T exists in an argument of such a type: an `argument`
  position holds none by definition (the summary is computed from the
  fields with the very rules `Occurrences` applies to a signature, and a
  slot reached only through its own declaration is held by no finite
  value); a pointee is an identity.
* A body cannot make one: a T value is made only from T values (a
  construction holding one, a List of them, a call returning one); every
  signature that hands the body a T, a List[T], a function returning T or
  an application holding T has a `value` occurrence and is refused.
  A result `-> T` or `-> List[T]` is a value position too
  (`wd-generic-phantom`'s last two cases), so the body is never even asked
  to produce one.
* A forwarded explicit imprint (`h[T]()` inside the body) binds the callee's
  variable to the rigid `{imprint T}`, unrestricted there; the callee's own
  body is held to its own positions by the same rule.
* Phantom copies are copies of unrestricted values: `Phantom[T]` is
  unrestricted in the body (T rigid) and `Phantom[Coroutine{...}]` is
  unrestricted at every call (T irrelevant to its affinity), so the body's
  view and every instantiation agree (`wd-generic-body-never-duplicates`).

Generic code over `Box[T]` still cannot duplicate an affine T:
`fn get(b: Box[T]) -> T`, `fn dup(b: Box[T]) -> List[T]`, `get[C](...)`,
`Outer[T]`, `Mixed[T]`, `Handler[T]` and `Job[T]` all refuse a coroutine
(`wd-generic-box`), as the fuzzer's generic signatures do.

**The actor library.** `std::actor::open[M]` returns `Opened[M]`, whose
`Address[M]` and `Inbox[M]` hold a slot and a generation -- no message. M
has no value position in `open`'s signature, so `open[Coroutine{...}]` now
imprints; every operation that moves a message (`post`, `send`, `deliver`,
`receive`) holds values of M and still refuses an affine M. An affine
message is still out of scope: `tests/actor/reject-affine-message.bot` now
fails at its `post` (IMPRINT), and SAME-THREAD-ACTORS-MILESTONE-1.md says so.
(`audit/thread-actor/probe-a/reject-affine-message.bot` and its recorded
result are the census's history: its `Postbox[Coroutine{...}]` field would
now be written; no test runs it.)

## 8. Parameters

`wd-parameter`: `fn consume(job: Box[Coroutine{...}])` is an affine
parameter. An argument moves into it (a second `consume(b)` is
USE-AFTER-MOVE), the body owns it once (`a = job; c = job` is
USE-AFTER-MOVE; `any_take(job)` AFFINE-ERASURE-UNSUPPORTED), destructures it
to resume the handle, returns it (`fn pass(job: Box[...]) -> Box[...]`), and
releases what it does not move on: ten calls leave no Tcl coroutine alive,
and the value agrees on all four backends. No rule was added for applied
types: the parameter is affine because `IsAffine` of its type says so.

## 9. Results

`wd-result`: a declared `-> Box[Coroutine{...}]` result is owned by its
caller (a duplicate is USE-AFTER-MOVE), released when ignored (`mk(i)` as a
statement) or when its binding dies, moved into a further declared
function and resumed by its last owner, on every backend.
`wd-semantic-instance` makes the same Box through an untyped function's
semantic instance and through a declared one: the same result type, the
same USE-AFTER-MOVE for a duplicate, the same released handles. Natively
(`wd-native-release`, also under GC stress, coroutine fusion off for the
counters): 100 handles owned through a parameter, an ignored declared
result, a field, a nested application and an `Outer` in a `Pair` -- 100
released by their owners' drops, 0 swept by the collector.

## 10. Fields

`wd-field`: `struct JobOwner: job: Box[Coroutine{...}], tag: int` is affine
through its field (`hir::types::Affinity {nstruct JobOwner}` is affine); an
owner of `Phantom[Coroutine{...}]` stays unrestricted. A JobOwner moves (a
duplicate is USE-AFTER-MOVE), drops its handle with it (no Tcl coroutine
alive after ten rows), and is taken apart to resume it. A field whose type
is a recursive affine application is AFFINE-CONTAINER-UNSUPPORTED at the
declaration (`VerifyDeclarations`, as before for a constrained slot's
problems; `wd-recursive-rejected`).

## 11. Nested applications

`wd-nested`: `Box[Box[C]]`, `Outer[C]`, `Pair[int, Box[C]]` and a `Pair`
holding a `JobOwner`, written as explicit constructions, are released whole
on every backend; a parameter `Pair[int, Box[C]]` is affine (its duplicate
USE-AFTER-MOVE) while `Pair[int, Box[str]]` and `Box[Box[int]]` copy
freely. The written and inferred descriptors are compared in
`wd-written-is-inferred`. Nothing changed in the application memo, applied
field substitution, descriptor walk or `appliedDepth` handling: a written
application reaches them as the same term.

## 12. Recursive affine applications

`Node[Coroutine{...}]` is classified affine (relevant slot T) and rejected
for its recursive ownership wherever it is written -- a parameter, a
result, a field, a List element, a function type's argument, an explicit
construction, an explicit imprint (`empty[Node[...]]()`), an error payload's
field (`wd-recursive-rejected`) -- with the recursive affine type's message,
never the slot rule's (`wd-recursive-message`). `Node[int]` is an ordinary
recursive type.

The check had to move to where a type is written: a written recursive
affine parameter reached `hir::affine`'s drop descriptors (which raise an
internal compiler error for a type with no finite descriptor) before
`verifyApplications`' diagnostic could stop anything, since the parameter
kept its declared type. `WrittenProblem` rejects it at resolution, so the
parameter's declaration is dropped like any invalid type -- the precedent is
`ImmutableSet[Coroutine{...}]`, refused by `resolveApplication` with the
same kind. While `hir::structs::apply` resolves a batch's field types the
registry is incomplete; there `WrittenProblem` decides nothing and the
declaration checks (`apply`'s own recursion check, `VerifyDeclarations`)
judge the field, as before.

**No finite form.** Writing types exposed a second shape the compiler
cannot represent: `struct W[T]: next: List[W[List[T]]]` applied to a handle.
`W[Coroutine{...}]` is unrestricted (W's slot holds no value), but its field
types are `W[List[C]]`, `W[List[List[C]]]`, ... and an affine argument is
never cut by the type bound, so every walk of the type's components that
unfolds applications (`hir::callables::Bearing`, `CarriedInto`,
`hir::types::Totality`) never ends: compiling `f(W[C] {next: []})` used all
memory. `hir::structs::Unfolding` walks the components (struct and
applied fields, elements, function types) with `OwnedRecursion`'s bounds
(64 steps, 4096 types) and reports such a type; `WrittenProblem` rejects it
as AFFINE-CONTAINER-UNSUPPORTED ("has no finite form: its fields nest its
affine type argument in ever larger types (W[C].next: List[W[List[C]]],
...)"), also as another application's argument or field (`M[C]` holding a
`W[T]`), and `hir::imprint::UnfoldingProblem` refuses the imprint that
would make one (`mk[Coroutine{...}]()` of `fn mk() -> W[T]`, IMPRINT).
`W[int]` is cut like any type and stays ordinary (`wd-unbounded-rejected`).
No value of such a type could ever be made before: W's slot is
established by no construction, and the type could not be written.

## 13. Phantom applications

`wd-phantom`: `Phantom[Coroutine{...}]` is written as a parameter's and a
result's type, copied, held in a List and read back, erased to `any`,
compared with `==`, hashed and used as an `ImmutableSet` element -- all as
the unrestricted value it is, on every backend. `wd-generic-phantom`:
`fn f(x: Phantom[T]) -> Phantom[T]` (which copies x twice and builds a
`Phantom[T]`), `fn g(w: Wrap[T])` and the explicit imprint `ph[C]()` of
`fn ph() -> Phantom[T]` take a coroutine type for T and run. The two
implementations the brief rules out are each killed: "written application
allowed iff all arguments unrestricted" (`written-rejects-affine-argument`)
and "affine iff any argument affine" (the previous milestone's
`app-any-affine-argument`, still in the harness).

## 14. Function-type and pointer cases

`wd-function-type-and-pointer`: `Handler[Coroutine{...}]` (a slot used only
in a function type) is written and unrestricted, copied freely; `Ref[int]`
(a C pointer field) is written and affine whatever its argument (a copy is
USE-AFTER-MOVE). The argument's affinity decides neither.

For imprinting, a function type's variable is a value position -- in a
declaration as in a signature, where `Occurrences` already counted it.
That is deliberately conservative: a body obtains values of T from a
function *returning* T (`Getter[T]`: `a = g.f(); b = a; c = a` would
duplicate a handle; `wd-generic-function-type`), and from a function *taking*
a function that takes T (the body would pass its own function, whose T
parameter it copies). Only a first-order argument position could be
excluded, which needs a polarity analysis of function types in signatures
generally -- a rule for `fn f(g: Fn{args: [T]})` itself, not for
applications -- and is left out (section 22). The mutant
`positions-fn-type-not-value` (every function type's variable at no value
position) is killed by that test.

A pointer's pointee is a `pointee` position through an application too:
`fn f(r: Ref[T])` takes `std::ffi::c::Void` for T (it was refused as "values
of T exist here"), and refuses a coroutine type as a pointee
(`wd-generic-pointer`).

## 15. Containers

Unchanged policies, applied to the written type (`wd-containers`): a List
or MutableVector of `Box[Coroutine{...}]` holds and releases its elements;
`ImmutableSet[Box[Coroutine{...}]]` is AFFINE-CONTAINER-UNSUPPORTED because
its element is affine (`resolveApplication`'s rule, not the argument's);
`ImmutableSet[Phantom[Coroutine{...}]]` and a copied
`List[Phantom[Coroutine{...}]]` are ordinary. (Lists do own affine elements
today: AFFINE-VALUES.md; the brief's `List[Box[Coroutine...]]` is therefore
an accepted affine List.)

## 16. Diagnostics

The diagnostic "a type slot takes an unrestricted type" is gone; nothing
replaced it with a new kind. A written application now meets the existing
diagnostic of what is wrong with it or of what the program does with it:
AFFINE-CONTAINER-UNSUPPORTED (a recursive affine type -- the previous
milestone's message, naming the application, the field that makes it
affine and the recursing path -- or, new message of the same kind, a type
with no finite form; an affine ImmutableSet element), USE-AFTER-MOVE,
AFFINE-ERASURE-UNSUPPORTED, AFFINE-EQUALITY-UNSUPPORTED,
AFFINE-CAPTURE-UNSUPPORTED, AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE,
AFFINE-LIST-OPERATION-UNSUPPORTED, IMPRINT. A declaration `struct Holder:
x: Box[Coroutine{...}]` is accepted; `struct Recursive: x:
Node[Coroutine{...}]` is rejected for its recursive affine ownership. No
message mentions slot substitution. The static-compile census needed no
change (no new kind).

## 17. HIR/interchange/isolation

No format changed: a written application is an ordinary `{nstruct ID
ARGS}` type, serialized as before, and a written and an inferred occurrence
of one type are one term. Slot positions, like affinity, are derived on
demand and never persisted.

* `wd-hir-text-and-interchange`: a program writing affine applications in a
  parameter, a result and a field (and a Phantom) reads back from HIR text
  to the same text and from interchange with the same release tables, core
  IR and outcome on all four backends.
* `wd-isolation`: two compilations declaring `Box[T]` with the slot held
  and phantom, interleaved: `fn f(b: Box[T])` refuses a coroutine T in the
  first, accepts it in the second, and each HIR activated after the other
  keeps its own slot positions and affinity; the mutant
  `positions-memo-outlives-declarations` is killed by it.
* The corpus harnesses: see section 21.

## 18. Oracle/fuzzing

`audit/affine/tools/fuzz.tcl -written N` (default 30) adds written programs
to the ownership and application programs. Each declares 2..4
parameterized structs as the application programs do -- and, one
declaration in two, drops the fields that only establish a slot, so phantom
slots occur (their constructions are written explicitly, which this
milestone makes possible) -- constructs one application T, and writes T in
one of seven positions: a parameter, a result, a field, a List element, an
ImmutableSet element, an explicit construction, or the declaration at
imprint variables in a generic signature `fn g(x: Sj[A, B])`. The oracle
shares nothing with the compiler: its own types, substitution, affinity, a
recursion search, and slot positions by its own least fixpoint (a slot, a
List of it, a function type over it, an earlier declaration's holding slot
applied to it). It predicts AFFINE-CONTAINER-UNSUPPORTED for a recursive
declaration, a recursive constructed application or any recursive
application the program writes (also as a phantom slot's argument),
AFFINE-CONTAINER-UNSUPPORTED for an affine set element, IMPRINT for a
generic signature whose affine argument sits at a holding slot,
USE-AFTER-MOVE for a duplicated affine value, and otherwise `[1, 0]` on
every backend with every handle released (natively by the counters). For
the parameter and result positions it also compiles the **inferred twin**
(an untyped parameter, an undeclared result) and requires the same verdict:
the differential property "writing X changes nothing X has".

RUNS_TABLE

The first runs found one generator defect and one oracle gap, both fixed
in the tools, not the compiler: the generic position met a declaration
whose own function-type field erases a typed function's contract (a
pre-existing `hir/callables.tcl` rule, unrelated to affinity: such
declarations now use the parameter position), and the oracle did not count
a recursive affine application written as a phantom slot's argument
(`S2[S1[Holder, int]]`), which the compiler rightly rejects.

## 19. Mutation testing

`audit/affine/tools/mutants.txt` gained 17 mutants (its section "Written
applications"), and `audit/affine/tools/mutate.tcl` now runs
`tests/written-affine-applications.test` beside `tests/affine.test` and
`tests/affine-applications.test`, and the fuzzer with `-written 30` beside
its ownership and application programs (seed 11). Every one is killed:

| mutant | the brief's item | killed by |
|---|---|---|
| `written-rejects-affine-argument` | `ResolveApplied` still rejects every affine argument | 21 tests (wd-containers, wd-field, wd-generic-body-never-duplicates, wd-generic-box, wd-generic-function-type, ...); 13 fuzz programs |
| `written-accepts-everything` | accepts every affine argument with no further check | wd-recursive-rejected, wd-recursive-message, wd-unbounded-rejected |
| `written-recursion-unchecked` | a recursive affine application accepted because written types are allowed | wd-recursive-rejected, wd-recursive-message |
| `written-unbounded-unchecked` | (a type with no finite form written) | wd-unbounded-rejected |
| `imprint-unbounded-unchecked` | (one made by an imprint) | wd-unbounded-rejected |
| `written-erases-affine-argument` | written and inferred follow different classifiers; a written result loses its release; a written field loses its propagation | 17 tests (wd-containers, wd-field, wd-generic-box, wd-generic-function-type, wd-generic-phantom, ...); 7 fuzz programs |
| `positions-every-slot-value` | `Positions` treats every slot as a value position; `Phantom[T]` unnecessarily restricted | wd-generic-phantom, wd-generic-pointer, wd-occurrences, wd-isolation, wd-generic-body-never-duplicates |
| `positions-no-slot-value` | no slot is a value position; a body over `Box[T]` duplicates an affine T | wd-generic-box, wd-occurrences, wd-generic-pointer, wd-isolation, wd-generic-body-never-duplicates |
| `positions-direct-fields-only` | only direct fields count, a nested `Box[T]` does not | wd-generic-box, wd-occurrences, wd-slot-positions |
| `positions-phantom-is-value` | a phantom slot counted as stored | wd-generic-phantom, wd-occurrences, wd-slot-positions, wd-isolation, wd-generic-body-never-duplicates |
| `positions-pointee-is-value` | a C pointer's pointee counted as a stored T | wd-generic-pointer, wd-occurrences |
| `positions-fn-type-not-value` | (the opposite of "a function type's T counts as stored": section 14 -- the unsound relaxation) | wd-generic-function-type, wd-generic-box, wd-slot-positions, wd-positions-not-relevance |
| `generic-binding-admits-affine` | a generic `Box[T]` body admits an affine T and duplicates it | wd-generic-box, wd-generic-function-type, wd-generic-phantom, wd-generic-body-never-duplicates, wd-isolation, aa-ownership-consequences |
| `explicit-imprint-rejects-affine` | the explicit imprint path disagrees with the declared and inferred ones | wd-generic-phantom, wd-generic-pointer |
| `set-element-root-only` | (the container policy's: an affine application as an ImmutableSet element) | wd-containers, af-restrictions; 3 fuzz programs |
| `positions-memo-outlives-declarations` | the memo leaks across compilations | wd-isolation |
| `written-walk-per-path` | (section 20's exponential walk) | wd-nested-walks-linear |

The brief's other items are mutants the harness already had, rerun against
this tree: "any affine argument makes the application affine"
(`app-any-affine-argument`), the nested drop descriptor
(`app-descriptor-visits-by-declaration`, `app-nested-argument-not-traversed`),
the recursive affine check (`app-recursion-declared-fields`,
`app-recursion-same-type-only`, `app-recursion-tree-only`). "`List[Box[...]]`
accepted despite the affine-element policy" has no mutant: Lists own affine
elements by policy (section 15); its container counterpart is
`set-element-root-only`. "`List[Phantom[...]]` rejected merely due to its
argument" is `written-rejects-affine-argument`.

(The first batch's runs also counted `af-fuzz-bounded`, which fails on the
unmutated tree until its expected program count includes the written
programs it now runs -- fixed before the second batch; every mutant of the
first batch is killed by the other tests listed.)

**The existing mutants of code this milestone changed**, rerun with their
own harnesses' detectors:

* affine: MUTANTS_OLD_AFFINE
* trait-constrained-types (the 20 mutants of `hir/imprint.tcl`,
  `hir/resolve.tcl`, `hir/structs.tcl`): 20 killed;
* c-abi-types (the 5 of `hir/imprint.tcl`: `imprint-only-intrinsics`,
  `bare-variable-accepted`, `fnptr-erasable`, `imprint-affine-binding`,
  `imprinted-callable-as-value`): 5 killed;
* tree-struct (the 8 of `hir/structs.tcl`): MUTANTS_TREE

Every mutant text of every harness that edits a file this milestone changed
still occurs exactly once, after one update (`app-recursion-declared-fields`
took a line more context: `Unfolding`'s walk repeats two of its lines); the
enum harness's `bare-case-accepted` occurs twice in `hir/resolve.tcl`
before and after this milestone, untouched by it.

## 20. Performance

No runtime change: no backend, runtime or representation changed, and a
written application lowers exactly as the same type inferred. The front
end does two new things, measured on this 4-core container
(`surface::readProgramFile`, best of 3, no front-end cache), this tree
against a worktree of the revision before it:

| suite | before | after | slot-position computations (`PositionsOf`) | `SlotPositions` asked (memo hits included) | `WrittenProblem` | `Unfolding` walks |
|---|---:|---:|---:|---:|---:|---:|
| tests/golden/trait-constrained-types.bot | 7.79 s | 7.93 s | 104 | 7,310 | 372 | 4 |
| tests/golden/tree-struct.bot | 15.26 s | 15.16 s | 80 | 8,380 | 476 | 0 |
| tests/golden/ownership.bot | 9.56 s | 9.34 s | 33 | 56 | 0 | 0 |
| tests/golden/mutable-map.bot | 25.06 s | 24.04 s | 80 | 29,959 | 619 | 0 |

The suites are within this machine's run-to-run noise. A declaration's slot
positions are computed once per registration (the computations column
counts the fixpoint's rounds: a declaration is computed again in the round
that confirms nothing changed), then read from the table; the summary is
memoized per declaration like the affinity summary, by the same `Fixpoint`,
and forgotten with it -- no second fixpoint machinery and no per-application
table (positions are a declaration fact; an application's occurrences are
computed from them and its own arguments, which are small). `WrittenProblem`
runs once per written application: an `OwnedRecursion` (an affine type only:
it returns at once for an unrestricted one) and, only for an application
with an affine argument, the `Unfolding` walk (each type once, a visited
set). `Occurrences` itself is called about 1% more often (`Placed` asks it
of each argument).

**A deep written affine application** -- the previous milestone's nested
specimen (`Li[A, B]: inner: L(i-1)[B, A], tag: int, rest:
List[L(i-1)[int, A]], same: List[Li[int, int]]`, a coroutine at the leaf),
now also written as a parameter and a result of a function the value passes
through:

| N | inferred | written, first version | written, final |
|---:|---:|---:|---:|
| 6 | 64 ms | 118 ms | 114 ms |
| 12 | 129 ms | 2,656 ms | 183 ms |
| 24 | 285 ms | (exponential) | 425 ms |

The first version was exponential, and not in this milestone's code:
`hir::types::MentionsMutable` (asked of a declared parameter's type by the
semantic instances, hir/semantic.tcl) walked a type's applied fields
remembering only its own path, so a type whose fields reach the next level
twice (`inner` and `rest`) was walked along every path -- 2,603 applied-field
reads at N = 8, 10,178 at N = 10. With an unrestricted argument the bound
cuts such a type at depth 6, so the walk was bounded before; an affine
argument is never cut, and writing one in a parameter's type is what made
the walk reachable. It now remembers every type it walked (one met again was
walked and holds no mutable component, or is on the path: a cycle) --
235 and 310 reads -- the same answers (`wd-nested-walks-linear` counts at most
3 reads per level of a 16-level specimen; the mutant `written-walk-per-path`
restores the path-only walk). The remaining written-versus-inferred
difference is the written function itself (its signature, its instance),
linear in N.

The same class of walk -- unfolding applications along their fields --
exists in `hir::callables::Bearing`/`BearingNamed` (a path stack too) and
`hir::types::Totality`; with an affine argument that grows (section 12)
they never end. They were not changed beyond what this milestone needed
(section 22).

## 21. Regression/CI

REGRESSION_SECTION

## 22. Explicit limitations

* **A function type's variable is a value position** for imprinting, in a
  declaration as in a signature, also where it is only a first-order
  argument (`Handler[T]`): `fn f(h: Handler[T])` takes no affine T. Precise
  admission needs a polarity analysis of function types (a doubly negative
  position, a function taking a function that takes T, hands the body T
  values again), a rule for signatures generally.
* **A result is a value position**: `fn f(p: Phantom[T]) -> T` and
  `-> List[T]` take no affine T, though such a body can only fail or return
  an empty List. Unchanged.
* **A type with no finite form is rejected**, not represented: `W[C]` of
  `next: List[W[List[T]]]` is AFFINE-CONTAINER-UNSUPPORTED. With an
  unrestricted argument the declaration is ordinary. The walks that would
  not end -- `hir::callables::Bearing`/`CarriedInto` and
  `hir::types::Totality` -- still unfold applications; they are now never
  given such a type, which is no fix of them (the previous milestone's
  Totality item stands, as the brief asks).
* **A recursive affine application is rejected wherever written**, also
  where no value of it can exist (a phantom slot's argument, a parameter of
  a function nobody calls): a written type must be a type.
* **The precision limit of untyped results** recorded by the previous
  milestone is unchanged: a field destructured from an untyped function's
  struct result reaches a typed consumer as `any`
  (`wd-semantic-instance` resumes it directly for that reason).
* **Explicit imprints** of affine types are judged by the callee's
  positions, as inferred bindings are; an explicit imprint is not more
  permissive than writing the type.

## 23. Recommendation for the next milestone

**Next: one summary per declaration for every walk of a type's
components.** Affinity has one (AFFINE-PARAMETERIZED-APPLICATIONS-
CORRECTNESS-MILESTONE-1.md), slot positions now another, by the same
`Fixpoint`. Three walks still unfold applications along their fields,
bounded only because the type bound cuts arguments -- which it never does
to an affine one:

* `hir::callables::Bearing`/`BearingNamed` and `CarriedInto` (what an erased
  value carries: obligations, errors) -- a path stack, like the
  `MentionsMutable` this milestone had to fix for the exponential case;
* `hir::types::Totality` (equality and hashing) -- the previous milestone's
  open item.

Each is a disjunction (or union) over the components a value owns, the
same shape as affinity, so each has the same summary form: the
declaration's own answer with its slots at a neutral argument, plus the
slots whose argument's answer reaches a field (for `CarriedInto`, a union
of the arguments' errors over those slots). Answering them from summaries
would make every such walk linear and finite, and remove this milestone's
`Unfolding` rejection (W[Coroutine{...}] would be an ordinary unrestricted
type, as W[int] is) together with the Totality limitation. The evidence:
the `W` program that exhausted memory (section 12), the 2^N
`MentionsMutable` walk (section 20), and the fuzzer's generator, which must
avoid non-uniform recursion because its own oracle would have to unfold it
too.

Two smaller items: a polarity analysis of function types for imprinting
(section 22: a first-order argument position holds no value a body can
obtain), and the untyped-result destructuring precision recorded by the
previous milestone (unchanged).
