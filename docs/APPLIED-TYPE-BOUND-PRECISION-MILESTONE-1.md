# Applied-type bound precision, milestone 1

The applied-type bound (`hir::types::appliedDepth`, 6) keeps the type
lattice finite: an application nested directly in another's argument is one
application deeper, and past six of them `MakeApplied` keeps an
application's constructor but replaces its arguments by `any`. This
milestone removes the false source-program rejections that cut caused,
without raising it, without exact types in the HIR, and without a new
source type.

The design laws, kept visible:

* A compiler approximation is not a source-language type declaration.
* A finite type lattice may forget precision globally without forgetting
  the exact relationship required by a declaration locally.
* Do not raise a precision bound when the real defect is checking after
  precision has already been discarded.
* Declared fields, parameters, results and explicit imprints are semantic
  contracts; internal bounding must not weaken them into false mismatches.
* Exact local checking must not turn into globally unbounded inference.
* Do not manufacture precision from `any`; preserve precision that the
  program and declaration already provide.
* Recursive parameterized types stay finite through declaration summaries,
  not through arbitrary concrete unfolding.
* The right place to cash out precision is the clearest local semantic
  boundary, not after a global approximation has erased the fact the check
  needs.

## 1. Result

What became valid (all at depth 1000 where measured, every backend where
run; `tests/applied-type-bound.test`, 32 tests):

* `Box {value: Box {value: ... 1}}` at any depth, its terminal Int read back
  through `x.value.value...` (the specimen; it was a TYPE error from 7 deep
  on, the same at 1000 as at 7).
* The same value held to a type written that deep: a parameter
  (`fn consume(x: Box[...Box[int]...])`), a result, a struct field (of a
  struct with no slots), an explicit application (`Box[...] {value: ...}`)
  and an explicit imprint (`unwrap[Box[...]](...)`).
* Two slots, one constant and one growing (`Pair[int, Pair[int, ...]]`);
  slot-moving declarations (`Swap[A, B]` holding `Pair[B, A]`); phantom
  slots (`Phantom[T]`) inside deep chains, and a phantom argument written
  deep.
* A slot two fields establish from equal deep values
  (`Two {a: Box {value: X}, b: X}`, X 8 or 50 deep), and a call whose two
  arguments establish one variable from equal deep values -- the bounded
  inference read the variable out of a cut argument one application early
  and reported a conflict that was none.
* A Hashable-constrained slot whose argument is deeper than the bound
  (`H[K satisfies Hashable, V]` with `K = Box[...int...]`), in a
  construction, a written parameter type and an explicit application -- the
  documented limitation "a constrained slot seven applications deep is
  TRAIT-NOT-SATISFIED" of TRAIT-CONSTRAINED-IMPRINTED-TYPES.md.
* A generic function whose semantic instances grow an application past the
  bound (`grow(Box {value: x}, n - 1)`): its deepest instance's construction
  was a TYPE error ("call to grow with x : Box[...] is invalid"), so the
  plain program `grow(1, 3)` was rejected.
* An `if` whose branches end in the same deep type, read back past the
  bound.

What became more precisely rejected (each was accepted, or rejected for the
wrong reason): a deep mismatch against a written type is a TYPE error at its
deepest field, with the same message at every depth past the bound; a deep
conflict between two establishing fields or arguments is IMPRINT naming the
exact types; a deep non-Hashable key is TRAIT-NOT-SATISFIED with a reason
naming the exact component, never `any`; an `if` whose branches differ deep
inside is held to a written type branch by branch.

The bound itself is unchanged (6), every HIR type is still bounded, and the
deep specimen's type table is the same 16 types (460 characters) at 100 and
at 1000 deep.

## 2. Starting defect

Generated `struct Box[T]: value: T` and `x = Box {value: ... 1}` N deep with
`x.value^N` read back (the depth-safe front end's `dsn-box-bound`):

| N | before |
|---|---|
| 1-6 | accepted |
| 7 | TYPE at 4:10 (the outermost construction's field) |
| 8, 12, 24, 48, 96, 256, 1000 | the same TYPE at 4:10 (`8`: 3 diagnostics, `12`: 11, ...) |

The message at 7: `field "value" of struct Box^7[any] cannot be proven to
satisfy its declared type Box^6[any] (value type: Box^6[int])` (Box^k for k
nested Boxes). Mechanically:

* The outer construction's slot T is established by its field value, whose
  type is `Box^6[int]` -- canonical at its own top, within the bound.
* Its type is `MakeApplied(Box, [Box^6[int]])`, seven applications deep: the
  seventh application (nesting 6) keeps no argument, so the type is
  `Box^7[any]`.
* `hir::range::VerifyStruct` read the field's declared type out of that
  type: `hir::types::StructField(Box^7[any], value)`, the argument at
  nesting 1, which is `Box^6[any]` -- cut one application earlier than the
  value standing in the field, which is cut (if at all) at its own sixth
  application.
* Applications are invariant, so `Box^6[int]` is not `Box^6[any]`: TYPE.

The cut is not wrong; the *extraction* is: any part of a bounded
application read back out of it is cut earlier than a value of that part on
its own. Every false rejection found in this milestone is that one
operation, at a different site:

| site | extraction |
|---|---|
| construction check (`VerifyStruct`) | the field type read out of the construction's own type |
| explicit construction (`Box[...] {...}`) | the written arguments kept as the bounded application's |
| projection typing (`hir::types::Project`) | `x.value` read out of `x`'s cut type: `any` after six projections, so `x.value^7...` was UNPROVEN-FIELD |
| construction inference (`InferApplication`) | a slot read out of a cut argument (`a: Box[T]`) against the same slot read from a value (`b: T`): a false IMPRINT conflict |
| constrained slots (`ApplicationIssue`) | the argument of a constrained slot past the bound is `any`, which satisfies nothing |
| semantic instances | the same construction check, in the view of an instance whose argument types grow |

## 3. Why the bound exists

The census (section 4) answers what would fail if applications were simply
kept exact forever. Measured, with `appliedDepth` raised to 100000 in a copy
of the tree:

* **Termination does not depend on it in what was run.** The test files most
  sensitive to applications (trait-constrained-types, affine-applications,
  written-affine-applications, parameterized-declaration-summaries,
  tree-struct, semantic-instances, structs, hashable, value-identity,
  owned-recursion: 461 tests) pass unbounded except the two white-box tests
  that pin the cut itself (`aa-deep-application-kept`, `pds-parity-corpus`),
  in the same time. Self-wrapping recursion (`fn grow(x, n): grow(Box
  {value: x}, n - 1)`), polymorphic recursion through an imprint, and
  recursion through a List terminate unbounded too: the semantic instances'
  budget (`hir::semantic`'s `maxDepth`) stops the first, and invariant
  applications join to no application at all (`lub` of `Box[int]` and
  `Box[Box[int]]`), so a fixpoint over applications does not ascend. The
  bound is what keeps the lattice of *types* finite in principle -- a
  memo, an instance key, a join is over finitely many types -- and the
  instance budget is what stops the instances that would otherwise grow.
* **The cost of exact types is quadratic, and that is what the bound
  prevents in practice.** The Box chain read back, front end only:

  | N | unbounded: ms | types | type-table chars | this milestone: ms | types | chars |
  |---:|---:|---:|---:|---:|---:|---:|
  | 100 | 344 | 202 | 80,999 | 144 | 16 | 460 |
  | 200 | 1,471 | 402 | 322,099 | 211 | 16 | 460 |
  | 400 | 9,042 | 802 | 1,284,299 | 478 | 16 | 460 |

  Every construction's own exact type is interned, each a prefix of the
  next: N types of size O(N), and every operation that compares, hashes or
  prints one (string representations of nested lists are themselves
  quadratic) pays it. The affine exception shows the same today: an
  affine application is never cut (`MakeApplied`: `any` would erase the
  handle it owns), and `Box {value: ... make(1)}` 200 deep takes 10 s.

So the bound stays, and exact information is kept only where a check needs
it, for as long as the check runs.

## 4. Architecture census

Every caller of the bound (`MakeApplied`, `Bound`, `appliedDepth`,
`aggregateDepth`):

| caller | what it relies on |
|---|---|
| `hir::types::MakeApplied` / `Bound` / `canonical` (hir/types.tcl) | the canonical form of every type: interning, `subtype`/`lub`/`glb`/`narrow`, the fixpoints of inference (`Walk`, `FoldBody`, block results), region inference (hir/specialize.tcl) |
| `InferApplication` (hir/types.tcl) | a construction's type from its field values |
| `ResolveApplied` (hir/resolve.tcl) | a written application's type |
| `hir::imprint::Substitute` (hir/imprint.tcl) | a signature's types under a call's binding |
| `hir::transfer` (hir/transfer.tcl) | a transfer's schema is its static type |
| `hir::threads` | a thread entry's `std::thread::Entry[I, R]` |
| `hir::read` (hir/read.tcl) | HIR text's types |
| `hir::summaries::Arguments` | an application's arguments, canonical |
| `hir::structs::AppliedFieldType(s)` | a field's type out of an application |
| `hir::types::StructField` | the same for any struct type |
| `hir::exact` (hir/exactvalue.tcl) | `maxDepth` = `aggregateDepth` for List facts |
| `audit/declaration-summaries/tools/parity.tcl` | raises both bounds to 64 for the old walk's comparison |

What relies on the bound: finiteness of the type lattice for memo keys
(`hir::structs::IsAffine`'s per-application cache, the trait cache keyed by
type, interning per HIR), instance keys (semantic instances, region
inference's specializations, the trait plan's per-binding clones), fixpoint
convergence (bounded types in loops and recursive results), and diagnostic
size. Method decisions and static decisions read diagnostics and types the
same way bounded or not.

## 5. The precision model

Two notions, never the same term:

* **The bounded type** -- what the HIR holds for every expression and
  binding, what joins, fixpoints, instances, method decisions, backends and
  interchange read. Unchanged.
* **Evidence** -- compiler-internal, built by `hir/applied.tcl` while one
  check (or one typing walk) runs, never stored in a type, never interned,
  never given a string form:

  | form | meaning |
  |---|---|
  | `{app ID ARGS CANON CUT SRC EST}` | an exact application: ARGS one evidence per slot, CANON its bounded type, CUT whether the bound cut CANON, SRC the construction that built it, EST the field of SRC that established each slot |
  | `{named ID FIELDS}` | a construction of a struct with no slots whose fields hold evidence that says more than their types (read by projections only) |
  | `{either EVS T}` | an `if` whose branches end in different evidence: one of theirs; T the bounded join |
  | `{type T H}` | only the bounded type T is known, to the horizon H: "" when the bound cut nothing in T, else the number of applications below T's top that are known (appliedDepth for a type at its own top, one less per argument read out of it) |

Where evidence comes from -- only what the program constructs:

* a named construction of a parameterized struct: its slots bound from its
  field values' evidence in field order (`Bind`, mirroring
  `InferApplication`: the first establishing field binds a slot, every later
  one is compared exactly); a slot no field establishes (a phantom slot, an
  empty List's element) is its written argument, which no value can
  contradict;
* an immutable local alias (`y = <construction>`, the binding's one `bind`,
  as hir/exactvalue.tcl follows it), a projection of either, an `if`'s
  branches (the same evidence, or `either`);
* on the expected side only, a written type the resolver recorded exactly
  where the bound cut it (section 6).

A **declaration is never evidence of the values in its position**: a
parameter read in its body is its bounded type. Every way into a parameter
is not checked exactly -- a call through a structural `Fn` type checks its
contract's bounded types, a dynamic call checks the kind -- so reading the
exact declaration back in the body would recover a precision no check
proved, and a backend trusting it (an Int where the HIR says `any`) could
be handed a String. Section 15 lists what stays bounded because of this.

The exact layer **only adds rejections**: the bounded check of the value's
own HIR type against the position's own canonical type runs first and
decides every subtype, Range, refinement and kind question; the exact layer
then compares two applications of one declaration (`Accept`, `Equal`), slot
by slot -- invariantly, as applications are compared -- and reports a
difference the bounded types hide. Bounded parts are compared as far as
both are known (`Truncate` at the nearer horizon): where the program gave no
evidence, the comparison is the bounded one, as before. So an accepted
program's types, and everything a backend reads, are what the bounded types
say.

Every walk of evidence follows the source's nesting and is a loop over an
explicit stack (nesting is never Tcl's limit,
DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md); the only recursive
procedures (`Substitute`, `Mentions`) walk a declaration's own bounded field
type. The comparison's trail is a cons list (nothing copied per level), and
no exact term is ever compared as a string.

## 6. Construction checking

`hir::range::VerifyStruct` of a parameterized construction whose bounded
type the bound cut (`hir::applied::Cut`: an application at spine nesting
appliedDepth or more whose arguments are all `any`, the form MakeApplied
gives every application it cuts) calls `hir::applied::VerifyConstruction`;
every other construction is checked exactly as before.

1. The slots: an explicit application's written arguments -- exact where
   the resolver recorded them (`exactStructArgs`), else each written
   argument at its own top (section 7) -- or the binding the field values'
   evidence establishes (`Bind`). A conflict is IMPRINT, at the
   construction, with inference's wording and the exact types:
   `the construction Two {...} cannot establish its type slots from field
   "b": imprint variable T is Box^7[int] by an earlier argument but
   Box^8[str] by field 2`.
2. Each field: its expected type is the declared field type with the slots
   replaced by their evidence (`FieldExpected`), never read out of the
   construction's bounded type. The bounded check runs against its
   canonical form; then, for a field the binding did not already compare
   exactly (an explicit application's, a field mentioning no slot), the
   exact layer (`Expect`).
3. A difference is reported at the deepest construction inside the checked
   value whose slot it passes through (`Locate`, from the comparison's
   trail and each evidence application's SRC and EST), as that
   construction's field: `field "value" of struct Box[int] cannot be proven
   to satisfy its declared type int (value type: str)`. A construction
   reached through an alias is not inside the use (its definition is no
   part of it): the use is reported, with the exact types.

Inference (`hir::types::Struct`) keeps each cut construction's evidence in
its typing context (`ctx`'s `applied`, ExprId -> evidence, only where the
evidence says more than the type; `TypedConstruction`): the walk's own
context, so evidence never outlives the types it was read from. Three
consumers:

* a projection of a value whose type the bound cut has the canonical type
  of the field's evidence -- the type of the field value the program
  constructed (`TypedProjection`), so `x.value^1000` is the Int;
* `InferApplication`'s bounded conflict is decided again on the evidence
  (`TypedBinding`): equal deep values are no conflict, a genuine one gets
  the exact message;
* a constrained slot's TRAIT-NOT-SATISFIED on a cut argument is decided
  again on the evidence (`TypedIssue`, section 10).

## 7. Parameters, results, fields, imprints

The resolver records a written type's exact form beside its bounded one
where the bound cut it and it mentions no imprint variable
(`hir::applied::Written`: the application spine resolved one application at
a time, every other part `ResolveTypeExpr`'s own bounded answer), in a flat
encoding (`Encode`: a list of nodes, children by index, so its string form
is as long as the term, never quadratic):

| written | HIR field |
|---|---|
| a parameter's type | the block's `exactParamTypes` (aligned with its parameters, "" for the others) |
| a result type | the block's `exactResult` |
| an explicit construction's application | the construction's `exactStructArgs` (one per slot), and `structArgs` each written argument at its own top |
| a call's explicit imprints | the call's `exactImprint` |
| a struct declaration's field type (no slot in it) | the struct registry entry's `exactFields` |

Only programs whose written types the bound cut gain a field: every other
HIR is byte for byte what it was (`atb-no-exact-forms-shallow`).

* **Call arguments** (`VerifyArguments`, after `VerifyCallChecks`' bounded
  loop): when an argument's type was cut, or the callee's parameter type or
  the call's imprint has an exact form, the imprint variables are bound from
  the arguments' evidence exactly (`BindPairs`: a deep conflict is IMPRINT,
  `same: imprint variable T is ... by an earlier argument but ... by
  argument 2`) and each argument the bounded check admitted is held to its
  parameter's exact type (the exact written form, or the signature's type
  under the exact binding). Inside `hir::CheckingCall`: a method-call
  candidate whose argument mismatches deep inside is not applicable.
* **Results** (`VerifyResult`, after `verifyDeclaredResults`' bounded
  check): each exit (hir::warnings::Exits) held to the exact declared
  result.
* **Fields** of a struct with no slots: `VerifyStruct` holds the value to
  the field's exact written type after the bounded check.
* **Explicit imprints**: the exact form binds the callee's variables.
* **Written constrained applications** (`H[Box^50[int], int]` as a
  parameter or result type): `hir::structs::verifyApplications` judges the
  exact form (section 10).

## 8. Multiple slots

Slot identity is the declaration's, never a position: `FieldExpected`
substitutes by slot name, `Bind` walks a declared field type's application
spine against the evidence (a declaration that moves its slots, `Swap[A,
B]` holding `Pair[B, A]`, is followed through `Pair`'s own declaration). A
mismatch is in the slot it is in: a String in the innermost Pair's `second`
is reported at `second`, one in its `first` at `first`
(`atb-pair-slot-identity`), and the fuzzer's random declarations permute
slots through earlier declarations' applications.

## 9. Phantom slots

A phantom slot needs no precision a value depends on: a `Phantom[...]`
nested past the bound in a Box chain is a program, its own field read back
(`atb-phantom`). Its argument is still part of the type: a construction
written with a phantom argument a Box 12 deep is held exactly to a written
type that differs deep inside it (TYPE), because that written argument is
the slot's evidence -- no field value says otherwise
(`atb-phantom-written`).

## 10. Trait constraints

A constrained slot's argument is judged by the trait's satisfaction. The
intrinsic traits whose witness predicates are Totality classes (Hashable:
equality and hashing total; Equatable: equality total) are classes of the
declaration summaries (hir/summaries.tcl), which answer an application from
its arguments' classes -- so an exact argument's class is found by one walk
of the evidence, each application's class `hir::summaries::Level` of its
arguments' classes (`TotalityClass`), never an unfolding of a declaration.
`hir::applied::Issue` re-judges a TRAIT-NOT-SATISFIED of a cut application
that way (every application in the evidence, its bounded parts by the
bounded check; a recursive affine application still the bounded verdict),
and the reason names the exact component responsible
(`hir::summaries::Contributor`): `type argument for "K" in H[Box^8[Fn{...}],
int] does not satisfy Hashable: it holds Box^6[Fn{...}]: field "value" of
...` -- never `any`. Any other trait is judged by the ordinary satisfaction
of the bounded argument (an ordinary trait's conformance reads its
witness's owner, which the bound keeps). Sites: a construction
(`TypedIssue`, at typing), a written parameter or result type
(`verifyApplications`, from its exact form).

Equality totality and hashing of a deep *value* (`==`, `hash`, an
ImmutableSet) are unchanged: they read the bounded type, which says
`unknown` past the bound, so `==` and `hash` stay the dynamic operations
there (correct, not total-lowered); `std::immutable_set::from_list` of deep
Boxes runs (`checked` hashing admits `unknown`).

## 11. Affine applications

Unchanged by construction: an affine application is never cut
(`MakeApplied`'s own exception), so its bounded type is already exact and
`Cut` never fires on it; the exact layer reads affinity nowhere. Pinned:
`Box^12 {make(1)}` is affine, `Box^12 {Phantom[Coroutine{...}] {...}}` is
not (its bounded type is cut), and a written recursive affine application
nested past the bound (`Box^9[Node[Coroutine{...}]]`) is still
AFFINE-CONTAINER-UNSUPPORTED (`atb-affine`). The ownership analyses
(`hir::ownership`, drop descriptors, `hir::affine`) read only bounded
types and declarations.

## 12. Recursive applications

Declaration summaries and the recursive-ownership analysis are untouched.
Evidence is never unfolded through a declaration: it is built from the
program's constructions and written types, so its size is the program's
(the fuzzer's and the tests' specimens are 1000 applications deep and
linear), and `TotalityClass` reads summaries, never field types of an
application.

## 13. `any`

`any` stays `any`: a deep Box whose leaf comes from a function declared to
return `any` is rejected where a written type says Int -- at the leaf,
`value type: any` -- and accepted where it says `any` (`atb-any`). No
covariance is introduced: a deep Box of Int is not a deep Box of any, within
the bound or past it (`atb-no-covariance`). A bounded part is compared only
as far as it is known; nothing past a horizon is read (`Parts` stops at
horizon 0, where only an application's head is known).

## 14. Joins and inference

* An `if` whose branches end in the same deep evidence keeps it (its value
  read back past the bound, `atb-if-join`); one whose branches differ is
  `either`: held to a position branch by branch (`atb-if-join-differ`),
  otherwise its bounded join. Followed at most `maxSteps` (64) aliases and
  branches per query, a determinism guard like hir/exactvalue.tcl's.
* Joins in the lattice (`lub`), folds, loop-carried values, untyped
  functions' results and semantic instances' results stay bounded: a value
  that went through them has its bounded type, compared as before.

## 15. Precision still deliberately bounded

| what | why | what it does |
|---|---|---|
| a projection chain read out of a declared parameter, a call's declared result or an error payload field deeper than the bound | a declaration is no evidence (section 5) | `any` past the bound: `fn f(x: Box^8[int]) -> int: x.value^8` is a TYPE error (`atb-bounded-declarations`) |
| a List's (MutableVector's, MutableArray's) contents | the aggregate bound and its own restart of applications are deliberate (a List element is canonical at its own top) | an application inside a List element is compared and projected to its bound: `std::list::at(xs, 0).value^8` is UNPROVEN-FIELD; a slot read out of a List's contents is known to that horizon (the fuzzer's `list-bounded` cases) |
| anonymous structs past `aggregateDepth` | the aggregate bound | `{v: {v: ...}}` 4 deep is UNPROVEN-FIELD, as before |
| a typed function past the bound | the bounded type of the construction that cuts it cannot carry its parameter contract (as a List past the aggregate bound cannot) | the erasure diagnostic (hir/callables.tcl), the bound's intended one (`atb-erasure-intentional`) |
| sendability past the bound | a transfer's schema is written from the bounded static type, and `any` has no schema | NOT-SENDABLE |
| a constrained variable bound at a call from a bounded type (`m.set(k, v)` of a `MutableMap[Box^8[int], int]`) | the map is an opaque value: its key type is the bounded one | TRAIT-NOT-SATISFIED |
| an opaque value (an untyped function's result, a loop variable, a parameter) whose type the bound cut, held to a written type | no evidence | the bounded comparison, as before: accepted when the bounded types agree |
| written types mentioning imprint variables | the exact form would need the signature's own transformations (constraints, clone imprints) | their bounded form |
| a deep `Fn{...}`, `List[...]` or other non-application written part | the spine is exact, its leaves are `ResolveTypeExpr`'s | bounded |
| HIR text (`hir::format`/`hir::read`) | it prints bounded types; a declaration's `exactFields` is not printed | a HIR read from text checks its written deep types to the bound (interchange `.hirx` carries the fields: section 16) |

## 16. HIR, interchange, cache

* **HIR.** Unchanged for every program the bound cuts nothing of. Where it
  cut a written type, the fields of section 7 (flat encodings). No HIR type,
  side table or node kind changes; evidence is never stored (the typing
  context and the verification memo are a walk's and a pass's).
* **Interchange.** `.hirx` holds the HIR dict and the declarations, so the
  exact fields travel with it; a deep program read back runs and checks as
  built (`atb-interchange`). No format version change: interchange's
  fingerprint covers `hir/`, so text of an earlier front end is refused, not
  misread.
* **Cache.** A hit equals the build and runs (`atb-cache`); the exact fields
  are part of the build, nothing else is read.
* **Isolation.** The struct registry's `exactFields` is part of the entry
  `hir::declarations::capture` captures; a compilation of another `Box`
  (another declaration of the name) does not change a deep program's checks
  or run (`atb-isolation`).

## 17. Oracle and fuzzing

`audit/applied-type-bound/tools/oracle.py` is an independent model (no
compiler code) of a small applied-type language -- atoms, `any`, slot
variables, Lists, applications; declarations with slots and fields; values
built of literals, `any`, one-element Lists and constructions (inferred or
explicitly applied) -- with three verdicts:

* `exact`: the value's exact type inferred bottom-up (slots bound in field
  order, a later establishing field compared exactly: IMPRINT; an explicit
  application holding every field exactly: TYPE) against the expected type
  by equality;
* `model`: the milestone's promise -- the same, a List's contents as the
  bound keeps them (applications in a List element cut below the element,
  the aggregate bound), a slot read out of a List's contents known to that
  horizon -- the verdict the compiler must give;
* `old`: the check before the milestone (every type cut, field types read
  out of the construction's own cut type), for classification only.

`python3 -I oracle.py selftest` checks 16 known cases.

`audit/applied-type-bound/tools/fuzz.tcl` generates random acyclic
declarations beside Box and Pair -- a slot held directly, in a Box, in a
List, inside an earlier declaration's application at a random slot (slot
permutations), or not at all (a phantom slot, constructed through its
written application) -- a random exact type nested across the bound
(depths 3 to 30, biased around 6), a value of exactly that type (some
constructions written applied), and keeps both, changes a leaf of the value
or a leaf of the expected type at a random depth; the program holds the
value to the expected type as a parameter's. A program the model accepts
must compile and one it rejects must not; a verdict that differs from the
old check's on a program the bound cuts nothing of is a failure; the first
accepted programs run on interp and cranelift (value 1).

Seeds 1-11, 40 programs each (440 programs): 0 failures; every first
diagnostic's code the model's (`kind-same 440`); classes `same` 267,
`bound-false-rejection-fixed` 173 (the old check rejected a value that
satisfies the declaration), and among them `list-bounded` 8 (a mismatch only
a List's contents hold, bounded as the model says). No `more-precise-rejection`
arises because the old check rejected every value past the bound before any
deep mismatch could matter.

The fuzzer found three defects while it was being written, each fixed and
pinned: a bounded part's arguments read past its horizon (the cut `any`
taken for a type; `Parts`), a phantom argument written deep taken as its
bounded form (`Constructed`), and the List boundary of a slot's knowledge
(the model's own refinement, not a compiler defect).

## 18. Mutation testing

`audit/applied-type-bound/tools/mutate.tcl` (mutants.txt): every mutant
applied to a private copy, killed by `tests/applied-type-bound.test` or the
fuzzer (seeds 1, 2, 4, 30 programs each). @MUTATION-RESULTS@

## 19. Performance

`bench/applied-type-bound.tcl` (fresh process per measurement):

@BENCH-DEEP@

The work of the exact machinery is linear in the depth (evidence
applications 2N for the read-back specimen, 4N for the written parameter,
one admission and one comparison); the time and memory growth is the front
end's own (structural ids, section 25 of the depth-safe report: the same
chain's memory before this milestone is in the table below), the HIR's type
table constant. @BENCH-MEMORY@

Ordinary programs (front end, median of 3 fresh processes, ms; this tree
against the revision before the milestone):

@BENCH-SUITES@

## 20. Regression and CI

@REGRESSION@

## 21. Next milestone

From the evidence, the precision still lost is of one kind: a *class* of an
argument the bound cut -- Hashable, Equatable, Sendable, affine, bearing --
that an opaque value's bounded type cannot carry (section 15: the
constrained variable bound at a call from a map's type, sendability, the
erased callable). The declaration summaries already answer every such class
of an application from its arguments' classes. A **class-preserving cut**
-- `MakeApplied` replacing a cut argument not by `any` but by an internal
"cut" argument that keeps the classes of what it replaced (one per summary
property, finitely many) -- would keep the lattice finite and make those
answers exact everywhere, not only where evidence reaches. Its design
questions are the cut argument's equality (two cuts of different types
must not be equal types), its printing (never shown as a type the program
wrote) and every consumer that reads `any` today.

The other candidate, end-to-end exact declared contracts (trusting a
parameter's exact written type in its body), needs every way into a
parameter checked exactly first -- calls through structural function
types, dynamic calls, coroutine resumes -- which is larger and has less
evidence of need.

## 22. What to run when changing this

If you change `hir/applied.tcl`, `hir::types::MakeApplied`, `Bound`, the
construction typing (`Struct`, `InferApplication`, `Project`), the
construction or argument checks (`hir::range::VerifyStruct`,
`VerifyCallChecks`, `verifyDeclaredResults`, `verifyBlocks`), imprint
matching, the resolver's exact forms (`ResolveAppliedConstruction`, the
block's parameter and result types, explicit imprints) or the struct
registry's `exactFields`, run `tests/applied-type-bound.test`,
`tests/depth-safe-nesting.test` (`dsn-box-bound`),
`tests/trait-constrained-types.test`, `tests/affine-applications.test`,
`tests/written-affine-applications.test`,
`tests/parameterized-declaration-summaries.test`, `tests/semantic-instances.test`,
`python3 -I audit/applied-type-bound/tools/oracle.py selftest`,
`audit/applied-type-bound/tools/fuzz.tcl` (several seeds) and
`audit/applied-type-bound/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule).
`bench/applied-type-bound.tcl -baseline DIR` is the performance report.
