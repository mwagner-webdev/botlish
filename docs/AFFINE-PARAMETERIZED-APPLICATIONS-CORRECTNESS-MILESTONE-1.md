# AFFINE-PARAMETERIZED-APPLICATIONS-CORRECTNESS-MILESTONE-1.md

> A parameterized struct application is affine exactly when the fields of
> that application, after substituting its type arguments, make it affine.

A compiler correctness milestone. No syntax, affine category, ownership
feature or tree special case was added; one tree special case was removed.

## Contents

1. [Result](#1-result)
2. [Starting reproducer](#2-starting-reproducer)
3. [Architecture census](#3-architecture-census)
4. [The old incorrect rule](#4-the-old-incorrect-rule)
5. [The corrected rule](#5-the-corrected-rule)
6. [Why applied fields, not type arguments](#6-why-applied-fields-not-type-arguments)
7. [Recursive applications](#7-recursive-applications)
8. [Tree-struct integration](#8-tree-struct-integration)
9. [Diagnostics](#9-diagnostics)
10. [Generic/unknown-type behavior](#10-genericunknown-type-behavior)
11. [HIR/interchange/isolation](#11-hirinterchangeisolation)
12. [Oracle/fuzzing](#12-oraclefuzzing)
13. [Mutation testing](#13-mutation-testing)
14. [Performance](#14-performance)
15. [Regression/CI](#15-regressionci)
16. [Explicit limitations](#16-explicit-limitations)
17. [Recommendation for the next milestone](#17-recommendation-for-the-next-milestone)

## 1. Result

The acceptance statement holds: every ordinary parameterized struct
application has exactly the affine classification it would have if its
type arguments had first been substituted into its fields and that
concrete struct had been written directly, and every existing affine
restriction observes it, because every consumer asks the one query
(`hir::types::IsAffine`) and that query now answers an application from
its applied fields.

| application | declaration | classification |
|---|---|---|
| `Box[int]`, `Box[str]` | `struct Box[T]: value: T` | unrestricted |
| `Box[Coroutine{...}]` | | affine |
| `Phantom[Coroutine{...}]` | `struct Phantom[T]: value: int` | unrestricted |
| `Outer[Coroutine{...}]` | `struct Outer[T]: inner: Inner[T]` | affine |
| `Fixed[Coroutine{...}]` | `struct Fixed[T]: inner: Inner[int]` | unrestricted |
| `Pair[int, Coroutine{...}]`, `Pair[Coroutine{...}, int]` | `struct Pair[A, B]: first: A, second: B` | affine |
| `Box[Holder]` | `struct Holder: c: Coroutine{...}` | affine |
| `Node[Coroutine{...}]` | `struct Node[T]: value: T, children: List[Node[T]]` | affine, and a recursive affine type: AFFINE-CONTAINER-UNSUPPORTED |

What changed:

* **The query** (`hir/structs.tcl`, `hir/types.tcl`): a declaration's
  *affinity summary* -- its affinity with every slot unrestricted, and the
  slots whose argument's affinity reaches a field -- computed by a least
  fixpoint from `AppliedFieldTypes` and `hir::types::IsAffine` themselves;
  each application answered from the summary and its own arguments, the
  answer kept per whole application (never per declaration); no recursive
  application is unfolded.
* **Recursive affine applications** (`hir::structs::OwnedRecursion`,
  `ApplicationIssue`): the declaration rule (an affine struct that holds
  its own type in a container is AFFINE-CONTAINER-UNSUPPORTED) judged on an
  application's own fields, wherever an application is written or made.
  The tree milestone's tree-only check ("a tree struct applied to an
  affine type") became unnecessary and is gone.
* **Consumers that walked a declaration instead of the application**,
  each part of the same defect: the declaration check of recursive affine
  types read a struct's declared fields (so `kids: List[Box[D]]` in an
  affine `D` was accepted and its inner handles leaked); the drop
  descriptor walk stopped at any second application of a declaration it
  was inside of (so `Box[Box[Coroutine{...}]]` dropped nothing); and an
  affine application nested past the applied-type depth had its arguments
  cut to `any` (an affine List element is never cut; now neither is an
  affine application).
* **A pre-existing native defect on the same path**, found by this
  milestone's tests and fixed: natively, dropping a scalar-replaced struct
  that holds an affine struct in a field applied the inner struct's drop
  descriptor to the coroutine register itself -- a segmentation fault --
  for ordinary nested structs too (`Wrapper {inner: Holder {...}}`), since
  before this milestone. Nested applications made it common.
* **A diagnostic's account**: an affine-value diagnostic naming an
  application affine through its arguments says which field makes it so.
* **Two memo tables, both measured necessary** (section 14): the answer per
  whole application, and the drop descriptor per type -- each cleared with
  the summaries at every change of the declarations.

Nothing else changed: no HIR, Core IR, NIR or runtime representation, no
HIR text or interchange format, no cache key, no ownership rule, no
container policy. The written-type rule "a type slot takes an unrestricted
type" (`hir::resolve::ResolveApplied`) is unchanged (section 10).

## 2. Starting reproducer

```botlish
struct Message:
    value: int

struct Event:
    value: int

struct Holder[T]:
    value: T

fn worker(seed: int, resume Message) -> Event:
    message = yield Event {value: seed}
    return Event {value: message.value}

coroutine {step} = worker(1)
a = Holder {value: step}
b = a
c = a
0
```

Before: accepted, value 0 -- the handle had three owners. The same program
with `struct Holder: value: Coroutine{args: [Message], return: Event}` is
USE-AFTER-MOVE at `c = a`. After: both are USE-AFTER-MOVE
(`aa-reproducer-duplicate`).

The second consequence is the release a value of the application owes. A
function that builds a `Box {value: make(i)}` and returns 1, called 100
times:

| | before | after |
|---|---|---|
| Tcl coroutines alive afterwards (interp, compile) | 100 | 0 |
| natively released / swept by the collector (fusion off) | 0 / 63 (68 stacks mapped) | 100 / 0 (1 stack mapped, 99 reused) |

Nothing released the handle: its owner's type was unrestricted, so no
release was elaborated, and only the collector reclaimed the abandoned
suspended coroutines natively. `aa-reproducer-release-tcl` and
`aa-reproducer-release-native` pin the fixed behavior for six shapes at
once (a Box, an Outer, a nested Box, a Pair of two handles, a Many of two,
a Box of a Holder: 800 handles natively, all released, none swept, also
under GC stress).

How an affine application arises at all: a *written* application with an
affine argument is rejected where it is written (section 10), so every
such application is inferred -- a construction whose field values
establish its slots (`Box {value: step}`), including inside a generic
function's semantic instance (`fn wrap(x): Box {value: x}` called with a
handle). That inference is exactly the path the old rule never judged.

## 3. Architecture census

**Where affinity is decided -- once.** `hir::types::IsAffine` (with
`Affinity` and `AnyAffine` over it) is the one predicate. Its cases are
structural: a coroutine handle, a C pointer or function pointer are roots;
a refinement is its base's; a List, MutableVector, MutableArray and
ImmutableSet their element's; an anonymous struct its fields'; a trait view
its witness's; an imprint variable and `any` are unrestricted; an enum asks
`hir::enums::IsAffine` (its payload-free cases: never affine today); a named
struct type asks `hir::structs::IsAffine ID ARGUMENTS`, which reads the
declaration's affinity summary (`AffinitySummary`, computed by `AffinityOf`
from `fieldTypes`, `AppliedFieldTypes` and `hir::types::IsAffine`). Nothing
else states what is affine.

**Who asks** -- every consumer calls the predicate on the type it has; none
re-derives affinity from a declaration:

| consumer | asks about |
|---|---|
| `hir/affine.tcl` (the ownership analysis: `Used`, `IsAffineBinding`, `Consumer`, `CallConsumer`, `NativeConsumer`, `Into`, `AffineParams`, `Analyze`, `Flow`, `Scopes`, `LoopDomain`, `PendingBefore`, `AffineProjection`, `Components`) | bindings, expressions, fields, argument and result positions |
| `hir::affine::Descriptor` (drop glue) | which components to drop; it walks `hir::types::StructField`, an application's applied fields |
| `hir/mutvec.tcl` (`ShareDescriptor`, `HeldDescriptor`, `Elaborate`, `PlaceParamProblem`, `ConsumedKind`, `Evidence`) | whether a collection or struct is shared or moved, dropping forms |
| `hir/coroutines.tcl` (`AffineProtocol`), `hir/resolve.tcl` (error payloads) | yields, messages, results and payloads |
| `hir/semantic.tcl` (`Call`, `verify`), `hir/traits.tcl` (`AffineWitnesses`, `AffineArgumentsUntyped`, `WitnessName`), `hir/specialize.tcl` (`ElementKeyType`) | when a generic function needs an instance or an affine specialization |
| `hir/staticdeps.tcl` (`Ownership`, `BindingSuccessors`, `CanCarry`, `MayBecomeAffine`) | the static-decision dependency channels |
| `hir/imprint.tcl` (`BindingProblem`), `hir/resolve.tcl` (`ResolveApplied`), `hir::types::resolveApplication` | whether a type may be bound or written |
| `hir/range.tcl` (`VerifyHashing`), `hir/cardinality.tcl` (`CallReach`), `hir/injection.tcl` (`HandleFree`), `hir/structs.tcl` (`MutableComponent`, `apply`, `ApplicationIssue`) | hashing admission, cardinality, retained authority, identity structs, recursive affine types |
| `hir::types::MakeList`, `MakeStruct`, `MakeMutVec`, `MakeMutArray`, `MakeApplied`, `FnMismatch` | whether a bound may cut a type |
| `native/lower.tcl` (`PayloadNeeded`, `ReleaseHandles` through `DropPlan`) | payload fields to keep, releases to lower |

Native lowering, the Tcl compiler and the interpreter read the front end's
decisions (release tables, drop descriptors); none decides affinity. No
affinity fact is persisted: HIR, HIR text, interchange and the front-end
cache hold types and release tables, never a classification.

**Where the defect lived.** Four places treated a named struct type as its
declaration: the `nstruct` case of `hir::types::IsAffine` (it passed only
the identity), `hir::structs::OwnedRecursion` (it walked declared field
types), `hir::affine::Descriptor` (it identified a struct being walked by
its declaration), and `hir::types::MakeApplied` (it cut any application past
its depth). The tree milestone's tree check worked around the first for
trees only.

## 4. The old incorrect rule

```tcl
nstruct {
    return [hir::structs::IsAffine [lindex $type 1] $seen]    ;# the identity only
}
proc hir::structs::IsAffine {id {seen {}}} {
    ... foreach {name t} [fieldTypes $id] { if {[hir::types::IsAffine $t ...]} ...
    ... dict set affinity $id $result                          ;# one answer per declaration
```

An application `{nstruct Box {ARG}}` was answered by Box's declared fields,
where a slot is the variable `{imprint T}`, which is unrestricted (an
imprint variable is bound to an unrestricted type only). So:

* any slot's affine argument was invisible: `Box[Coroutine{...}]`,
  `Outer[Coroutine{...}]`, `Pair[int, Coroutine{...}]` were unrestricted;
* the answer was cached per declaration identity, so a correct per-
  application answer could not have been cached there anyway;
* only a declaration that was affine on its own (a struct with a
  `Coroutine{...}` field beside its slots) made its applications affine.

The consequences followed through every consumer that trusted the
predicate: a binding of such a value was no affine binding (copied freely,
never released), an argument of it an ordinary argument, an `any` erasure
or an equality of it no diagnostic, its drop descriptor never asked.

## 5. The corrected rule

`hir::types::IsAffine` is a disjunction over the components a value owns,
each ending in an affine root or in nothing. Substituting an application's
arguments into its declaration's fields therefore gives

    affine(S[A1, ..., An]) = base(S) or affine(Ai) for some i in relevant(S)

* `base(S)`: the declaration's affinity with every slot unrestricted -- its
  field types as declared, a slot variable unrestricted as in a generic
  body;
* `relevant(S)`: the slots whose argument's affinity reaches a field. Slot
  i is relevant when S applied to an affine root at i (and to `any`, which
  holds no affine value, at every other slot) is affine -- computed with
  `AppliedFieldTypes` (the one substitution) and `hir::types::IsAffine` (the
  one statement of what is affine).

`hir::structs::AffinitySummary` computes `{BASE RELEVANT}` for a
declaration and every declaration it reaches together, as a least fixpoint:
each starts `{0 {}}` and grows while a summary computed from the others'
does. A declaration met inside the fixpoint joins it; an unfinished
fixpoint's summaries are discarded. The summary is a fact of the
declaration, kept per registration: `hir::structs::ForgetAffinity` clears
it, and every place that cleared the old cache (`Reset`, `apply`,
`applyEntries`, `addDecls`, `hir::declarations::Install`) calls it.
`hir::structs::IsAffine ID ARGUMENTS` answers an application from it and
its own arguments, and keeps that answer for the whole application `{ID
ARGUMENTS}` -- never for the declaration alone, and never while a summary
fixpoint is still running (an answer then is provisional:
`app-memo-provisional`, `aa-fixpoint-order`). A missing argument (a bare
constructor) is `any`.

This is exactly the governing rule: the summary is the substitution, read
once per declaration instead of once per application. The fuzzer's oracle
(section 12) does the literal substitution and agrees on every program.

Three consumers needed the same correction because they did their own walk:

* `hir::structs::OwnedRecursion TYPE` (was `OwnedRecursion ID`) walks an
  application's applied fields (section 7);
* `hir::affine::Descriptor` identifies the struct types it is inside of by
  the whole type, so `Box[Box[C]]`'s inner `Box[C]` is walked, not taken for
  the outer one met again (`s1.0.s1.0.c` instead of nothing); it also
  returns at once for an unrestricted type (which owns nothing: every
  component it walks is one `IsAffine` reads);
* `hir::types::MakeApplied` keeps an affine application's arguments past
  `appliedDepth`, as `MakeList` keeps an affine element past
  `aggregateDepth` (cutting them to `any` would erase the handle, and every
  position the value then flowed into would be an erasure).

## 6. Why applied fields, not type arguments

The tempting fix -- "an application is affine if any type argument is" --
is unsound in the other direction, and the tests and mutants kill it
(`aa-not-any-argument`, `app-any-affine-argument`,
`app-every-slot-relevant`):

| application | an argument is affine | a field holds a value of it | affine |
|---|---|---|---|
| `Phantom[Coroutine{...}]` (`value: int`) | yes | no | no |
| `Fixed[Coroutine{...}]` (`inner: Inner[int]`) | yes | no | no |
| `Fun[Coroutine{...}]` (`f: Fn{args: [T], return: int}`) | yes | no: a function type over T holds no T | no |
| `W[Coroutine{...}]` (`next: List[W[List[T]]]`) | yes | no: T is reached only through W itself (least fixpoint) | no |
| `Ref[int]` (`p: std::ffi::c::Ptr[T]`) | no | -- | yes: a C pointer is affine whatever its pointee |

Affinity is a property of the representation the application has, the same
principle the intrinsic witnesses use (an `ImmutableMap[K, V]` is Hashable
exactly when V is: its components decide, not its arguments). An
application is judged by what its values store.

## 7. Recursive applications

Two separate questions, both finite now.

**Classifying a recursive application.** `struct Node[T]: value: T,
children: List[Node[T]]` gives `relevant(Node) = {T}` and `base = 0` by the
fixpoint, without ever unfolding an application: `Node[int]` is
unrestricted, `Node[Coroutine{...}]` affine. A non-uniform recursion, whose
applications grow (`struct W[T]: next: List[W[List[T]]]`: W[int], then
W[List[int]], W[List[List[int]]], ...), would never end if unfolded --
an affine argument's type is never cut -- and the summary needs no
unfolding: W's slot is irrelevant, so `W[Coroutine{...}]` is unrestricted
(no finite value of it stores a handle: every `next` may only be empty or
hold W values that, again, store none).

**A recursive affine type.** An affine application that holds an affine
application of its own declaration in a List, MutableVector or MutableArray
element has values nested to any depth, each level owning an affine value;
no finite drop descriptor reaches them. That is the existing declaration
rule (AFFINE-CONTAINER-UNSUPPORTED, `struct Tree: step: Coroutine{...},
kids: List[Tree]`), now judged on the type's own fields wherever an
application is written or made (`hir::structs::ApplicationIssue`: declared
parameter and result types, constructions, explicit imprints, imprint
bindings, field and payload types). `OwnedRecursion TYPE`:

* walks struct fields (an application's applied fields) and container
  elements -- exactly what a drop descriptor walks -- and only affine types
  (an unrestricted one holds no affine value);
* finds `Node[Coroutine{...}].children: List[Node[Coroutine{...}]]`, and
  `V[Coroutine{...}].next: List[V[List[Coroutine{...}]]]` (another
  application of the declaration nests the values as deep);
* does not find `D[Coroutine{...}]` of `struct D[T]: here: T, kids:
  List[D[int]]` (the recursive field owns nothing) -- accepted, and dropped
  by `s1.0.c`;
* treats its own type met again through fields alone as no path (no finite
  value has it), and walks on into another application of the declaration
  met through fields alone (`Box[Box[C]]`'s `Box[C]`: finite values hold
  it);
* stops a walk whose path passes 64 fields (or 4096 types) as `unbounded`:
  a non-uniform recursion with an affine argument (`struct Wrap[T]: g:
  Grow[T]` over `struct Grow[T]: here: T, next: List[Grow[List[T]]]`), which
  is rejected, never accepted.

The declaration check (`apply`) is the same walk from the declaration's own
type at its slots (`SelfType`), which an application of it can then only
make more affine. It also finds paths through another declaration's slot,
which the old walk missed: `struct D: c: Coroutine{...}, kids: List[Box[D]]`
was accepted and its nested handles leaked; it is now AFFINE-CONTAINER-
UNSUPPORTED (`D.kids: List[Box[D]], Box[D].value: D`,
`aa-declaration-through-slot`).

## 8. Tree-struct integration

TREE-STRUCT-MILESTONE-1.md's `ApplicationIssue` rejected "a tree struct
applied to an affine type": any affine argument of a tree application. That
was a workaround for this defect (it said so) and it used the incorrect
rule of section 6. **It became unnecessary and is removed**: a tree struct's
application asks the same predicate and the same recursion walk as every
application. A tree's child field is `List[Self]`, so an affine tree
application holds an affine application of its own declaration in a List:
AFFINE-CONTAINER-UNSUPPORTED by the general rule (`ts-decl-affine`, now
with the general message). Where the old rule and the general one differ,
the general one is right: `Tree[int, Coroutine{...}]` of `tree struct
Tree[T, U]: value: T, f: Fn{args: [U], return: int}, children: List[Tree[T,
U]]` stores no handle and is an ordinary unrestricted tree type
(`aa-tree-general-rule`; such an application can only be built
white-box: U is established by no field and an affine argument cannot be
written). The tree declaration rules that are about trees -- the shape, no
opaque, context or identity tree, a tree struct with an affine field of its
own -- are unchanged.

## 9. Diagnostics

No new diagnostic kind. A program the corrected affinity rejects is
rejected with the existing affine diagnostic of what it does: USE-AFTER-
MOVE, AFFINE-NOT-DEFINITELY-LIVE, AFFINE-ERASURE-UNSUPPORTED, AFFINE-
EQUALITY-UNSUPPORTED, AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE, AFFINE-
CAPTURE-UNSUPPORTED, AFFINE-LIST-OPERATION-UNSUPPORTED, AFFINE-CONTAINER-
UNSUPPORTED (`aa-ownership-consequences` exercises each).

Two narrow improvements in wording, both in the type's terms:

* a diagnostic that names a value's type (`hir::affine::TypeText`) adds the
  field that makes an application affine when its declaration is not
  (`hir::structs::AffineThrough`):

      `b` is an affine Box[Coroutine{args: [Message], return: Event, errors: []}]
      (affine: its field "value" holds Coroutine{args: [Message], return: Event,
      errors: []}), which cannot become the argument of parameter "x", declared
      any: ...

* a recursive affine application's message names the application, the
  field that makes it affine and the path:

      the construction is invalid: Node[Coroutine{...}] is affine (its field
      "value" holds Coroutine{...}) and holds affine values of struct "Node" in
      a List, MutableVector or MutableArray (Node[Coroutine{...}].children:
      List[Node[Coroutine{...}]]): a recursive affine type is not supported --
      ...

The declaration message (`struct "Tree" is affine and holds values of its
own type ...`) is unchanged for every declaration it reported before; a
step of a parameterized owner prints the application (`Box[D].value: D`).
No message says "slot substitution".

## 10. Generic/unknown-type behavior

Unchanged, and consistent with the corrected rule:

* **`any`** holds no affine value (AFFINE-ERASURE-UNSUPPORTED keeps one out
  of it): `Box[any]` is unrestricted, and an affine value flowing into an
  `any` field is an erasure, as before.
* **An imprint variable** (a rigid T in a generic body) is unrestricted:
  a variable is bound to an unrestricted type only (`hir::imprint::
  BindingProblem` rejects an affine binding where values of the variable
  exist). So `Box[T]` in `fn get(b: Box[T]) -> T` is unrestricted, and
  `get(Box {value: make(1)})` is rejected at the call (IMPRINT), as before.
  `Positions` treats every argument of a struct application as a value
  position, so even `Phantom[T]` takes no affine T in a signature: that is
  conservative and unchanged (section 16).
* **An untyped function** given an affine value is analyzed in its
  semantic instance, where the construction it makes is typed with the
  value's type: `fn wrap(x): Box {value: x}` called with a handle returns a
  `Box[Coroutine{...}]`, affine in the caller (a duplicate is
  USE-AFTER-MOVE) and dropped by its owner. The affine plan specializes
  such functions as before (`NeedsAffinePlan`), now also for an
  application it was blind to.
* **A missing argument** (a bare `{nstruct Box}` of a parameterized struct)
  is `any`.
* **A written application with an affine argument** -- `fn f(b:
  Box[Coroutine{...}])`, a field `b: Box[Holder]` -- is still rejected
  where it is written (`hir::resolve::ResolveApplied`: "a type slot takes an
  unrestricted type"), Phantom included. This milestone did not change that
  policy: it accepts nothing new. Its stated reason ("its values may be
  copied wherever the slot's type is used") was true of the old rule only;
  section 17 recommends deciding it separately.

No separate generic-affinity defect surfaced. One precision limit unrelated
to affinity did: a field destructured from an untyped function's struct
result reaches a typed consumer as `any` (`{value: c} = gwrap(c0, 2)` then
`consume(c, 1)` is a TYPE error, before and after this milestone); the
fuzzer builds its boxes through a typed function for that reason.

## 11. HIR/interchange/isolation

Affinity stays a type analysis, computed on demand: no HIR field, HIR text,
interchange format, front-end cache key or native representation changed.
What a backend reads -- the HIR's release tables, and the drop descriptors
it derives from the HIR's types under the HIR's own declarations
(`hir::affine::DropPlan` after `hir::activate`) -- now describes
applications correctly and is carried exactly as before.

* **HIR text and interchange** (`aa-hir-text-and-interchange`): a program
  holding handles through `Box[...]` and `Box[Box[...]]` reads back from
  HIR text to the same text, and from interchange with the same release
  tables, the same core IR and the same outcome on all four backends.
* **Compilation isolation** (`aa-isolation`): two programs declaring `Box`
  differently (holding T; holding only an int), compiled, run and
  activated interleaved, each keep their own classification
  (`Box[Coroutine{...}]` affine in one, unrestricted in the other) and
  outcome. The summaries, the applications' answers and the drop
  descriptors are cleared together at every registration change
  (`hir::structs::ForgetAffinity`, `hir::declarations::Install` included);
  an answer is kept per whole application, never per declaration
  (`aa-summary-per-declaration`: Box[int] asked first does not decide
  Box[Coroutine{...}], nor the reverse). `aa-isolation-descriptors` drops a
  `Box` of a handle in two programs whose `Box` holds its slot at different
  field positions, interleaved: each releases every handle by its own
  descriptor. The mutants `app-summary-leaks-across-compilations`,
  `app-answer-cached-by-declaration` and
  `app-descriptor-memo-outlives-declarations` are killed.
* The harnesses (section 15) ran clean: <!--HARNESS-->.

## 12. Oracle/fuzzing

`audit/affine/tools/fuzz.tcl` was extended, not replaced:

**Ownership programs through applications.** The prelude gained `struct
GBox[T]: tag: int, value: T`, `struct GNest[T]: label: int, inner:
GBox[T]` and `gmake(c, tag)` (a function whose undeclared result is the
application). The generator boxes handles in a GBox (directly or through
gmake), nests a GBox in a GNest, moves either, and takes them apart (every
field, or only the tag or label: the handle is dropped); the oracle's owner
record (every identity's one owner, every release obligation) is the
existing one. Faults on them -- a use after a move, a projection of the
affine field, an erasure, an equality, a generic duplication -- predict the
existing diagnostics. On the original compiler the extended generator
disagrees with its oracle on most programs that box a handle (seed 1: 8 of
the first 20, every one a handle left alive); on the fixed one it agrees on
every program.

**Application programs** (`-applications N`, default 30). Each program
declares 2..4 random parameterized structs (one or two slots) with fields
drawn from a slot, int, `List[slot]`, an earlier declaration applied to
slots or int (or a List of one), the ordinary structs Holder (affine) and
Plain, a function type over a slot, and the declaration itself in a List
(at its own slots, or at int); then constructs one of them with arguments
drawn from int, str, List[int], a coroutine handle, Plain, Holder and
applications of earlier declarations, and either duplicates the value or
drops it. The **oracle** shares nothing with the compiler: its own type
terms, its own substitution, its own classification (co and holder affine,
a List its element's, an application its substituted fields', a cycle
adding nothing) and its own search for a recursive affine type; it never
calls `IsAffine`. It predicts AFFINE-CONTAINER-UNSUPPORTED (for a recursive
declaration, or any constructed application that is one), USE-AFTER-MOVE
for a duplicated affine value, otherwise `[1, 0]` on every backend (no Tcl
coroutine left alive), and natively every handle constructed released and
none swept.

<!--FUZZ-->

## 13. Mutation testing

`audit/affine/tools/mutants.txt` gained 21 mutants of this milestone
(section "Applications of parameterized structs"), the tree-struct
mutant `decl-affine-application-admitted` was rewritten for the general
check, and `struct-affine-unrestricted` for the new code; `mutate.tcl` runs
`tests/affine.test` and `tests/affine-applications.test` and the fuzzer
(now with its application programs) against each.

<!--MUTANTS-->

## 14. Performance

<!--PERF-->

## 15. Regression/CI

<!--CI-->

## 16. Explicit limitations

* **The written-argument rule** (`ResolveApplied`) still rejects every
  written application with an affine argument, `Phantom[Coroutine{...}]`
  included. So an affine application can be inferred but not written: a
  function can return a `Box` of a handle but cannot declare that result or
  a parameter of that type, and a struct cannot declare a `Box[Holder]`
  field. Lifting it is a decision about which signatures may name affine
  applications (its interaction with imprinting and with the `Positions`
  rule below), not a correctness fix; it was left as it is.
* **Imprinting is conservative about phantom slots**: `hir::imprint::
  Positions` counts every struct argument as a position where values of the
  variable exist, so a signature `fn f(p: Phantom[T])` takes no affine T,
  though `Phantom[Coroutine{...}]` is unrestricted.
* **Phantom-like affine applications are reachable only white-box**: a slot
  is established only by a field that stores a value of it (a function
  type's argument does not establish), and an affine argument cannot be
  written. The tests classify them directly (`aa-classification`,
  `aa-not-any-argument`, `aa-tree-general-rule`).
* **A non-uniform recursion with an affine argument** is rejected as
  unbounded once its walk passes 64 fields or 4096 types: conservative, and
  no program of the corpus or the fuzzer comes near it.
* **Totality over a non-uniform recursion** (`hir::types::Totality`, for
  equality and hashing) still unfolds applications, as before: for
  `W[Coroutine{...}]` of `struct W[T]: next: List[W[List[T]]]`, whose
  growing arguments are never cut, it fails with Tcl's "too many nested
  evaluations" -- identically before and after this milestone, white-box
  only (such an application cannot be written, and no field establishes
  W's slot). It is equality's analysis, not affinity's, and was left
  alone.

## 17. Recommendation for the next milestone

**Next: written affine applications.** Now that an application's
classification is sound, the remaining asymmetry is that an affine
application can be inferred but never written. The evidence from this
milestone:

* every affine application its tests and fuzzers make is inferred from a
  construction; the fuzzer's `gmake` has to leave its result undeclared,
  and no struct can declare a field `job: Box[Holder]` (it is rejected as
  "a type slot takes an unrestricted type", whose stated reason -- the
  slot's values may be copied -- was a consequence of the old rule);
* `Phantom[Coroutine{...}]` is unrestricted, yet cannot be written either,
  and `hir::imprint::Positions` refuses an affine T in `Phantom[T]` because
  it counts every struct argument as a value position.

The milestone would decide (a) whether `ResolveApplied` admits an affine
argument, (b) whether imprinting's value positions follow the relevant
slots (the affinity summary already computes them: one fact, not a second
rule), and (c) what an imprinted function over `Box[T]` may do with a
`Box` of an affine T -- the binding rule is that a body checked for every T
may copy its values, which must stay true. The ownership analysis needs no
change for it: every consumer already asks the corrected predicate.

Two smaller items found on the way, each its own change: `hir::types::
Totality` unfolding a non-uniform recursion (section 16; equality's
analysis, white-box only today), and the precision loss of a field
destructured from an untyped function's struct result (section 10).
