# LIST-CARDINALITY-REFINEMENTS.md -- `List[T]{length: N}`, the second scalar refinement

Status: implemented (completion report). This milestone extends the
scalar-refinement system that landed with `DecimalRounded`
(DECIMAL-ROUNDED-MILESTONE-1.md) to Lists:

    List[int]{length: 4}

is an ordinary immutable `List[int]` whose length the compiler knows to be
exactly 4. It is the same schema, the same syntax, the same canonical form,
the same subtyping, joins, text and interchange as `DecimalRounded{...}`,
with a second order (`exactly`) and a second refinement theory (exact
cardinality) beside the first (a decimal guarantee).

Design laws, kept visible:

* A refinement strengthens what is known about a value; it does not change
  what the value is.
* `List[T]{length: N}` is a List, not a tuple and not a native fixed array.
* Exact cardinality may be forgotten freely; recovering it requires proof
  or validation.
* A declared function refinement is an API contract. An implementation
  accident is not.
* One semantic fact has one canonical representation: existing
  exact-cardinality knowledge converges on the scalar-refinement system.
* Immutable cardinality is the easy second specimen. Mutable cardinality
  and relational invariants come later.
* Knowing that a List has two elements does not mean those two positions
  are an idiomatic product. `FIXED-ARITY-LIST-RETURN` remains fully in
  force.

The code: `hir/refinements.tcl` (the schema's List row and its generic
`exactly` order, applied bases), `hir/types.tcl` (the refined cases of
subtype, lub, glb, narrow, kindOf, show; `Refine`, `Unrefined`,
`LengthOf`, `ForgetInferred`; minting through `-result-length`
registrations, collecting loops, layout copies), `hir/refine.tcl` (the
length-equality guard), `hir/range.tcl` (admission, its messages, the
measured `list::length` range), `hir/cardinality.tcl` and
`hir/completions.tcl` (the proofs that read the fact), `hir/layouts.tcl`
(copy types), `hir/listlength.tcl` and `core/listlength.tcl` (the
validator), the `listwithlen` NIR operation (`native/src/runtime/ops.rs`),
and the boundaries that forget minted facts (`hir/semantic.tcl`,
`hir/imprint.tcl`, `hir/traits.tcl`, `hir/signatures.tcl`,
`hir/containers.tcl`).

Contents:

1. Result
2. Relationship to DecimalRounded
3. Semantics
4. The refinement lattice
5. Minting
6. Function contracts
7. Control-flow narrowing
8. Fixed-array integration
9. Cardinality-system migration
10. Bounds proofs
11. Operations preserving cardinality
12. Product versus sequence
13. HIR, interchange, cache and isolation
14. Runtime and code generation
15. Diagnostics
16. Fuzzing
17. Mutation testing
18. Regression
19. Performance
20. Future pressure
21. Acceptance criteria
22. What to run when changing this

## 1. Result

What landed:

* **Syntax.** `List[T]{length: N}` is the existing scalar-refinement
  grammar (`NAME{field: value, ...}`, comma- or line-separated) after an
  applied type: `surface/parser.tcl`'s `TypeExpr` reads braces after
  `List[T]` as `{refine List FIELDS BASE}`, the AST form `DecimalRounded`
  uses plus its base. No `List4[T]`, `FixedList[T, 4]`, `Tuple4[T]` or
  `List[T, 4]`; `length` is a refinement of the value, not a type argument.
  It is valid wherever a type is: parameters, results, struct and context
  fields, error payload fields, function types, nested in List element
  types (`List[List[int]{length: 3}]{length: 2}`), imprints
  (`list::with_length[List[int]{length: 4}](xs)`).
* **Validation.** `length` is required, a non-negative integer literal,
  written once; anything else is the existing REFINEMENT-PARAMETER
  diagnostic (with every problem named) or the existing syntax error for a
  malformed field. No other constructor has refinements (`MutableVector[T]
  {length: 2}`, `MutableArray[T]{...}`, `ImmutableSet[T]{...}` are
  REFINEMENT-PARAMETER: "... has no scalar refinements").
* **Type knowledge.** One canonical form, `{srefined List {length N}
  BASE}`, BASE the List type it refines. Subtyping, admission, joins,
  narrowing, decay, display, HIR text, interchange and the cache all go
  through the scalar-refinement schema.
* **Minting**: List literals, `[]` (length 0), `list::append` (N + 1),
  collecting loops whose cardinality is exact and constant, declared
  parameters, fields and results, the copies of fixed layout arrays
  (recursively), `list::length(xs) == N` guards (both operand orders, and
  the continuation of a `!=` early return), and the explicit validator
  `list::with_length[List[T]{length: N}](xs)` (fails with the new builtin
  declared error LengthMismatch).
* **Consumption**: `list::at` with an index in range has no IndexNotFound
  path (one out of range is KNOWN-ERROR); `list::length` of a refined List
  is the constant N to the range analysis (a decided comparison lowers
  without its other arm); a fixed-array write or emit of a List of the
  extent has no LayoutExtentMismatch path (a wrong one is KNOWN-ERROR; an
  unrefined List keeps the run-time check).
* **Unchanged**: the List's run-time representation on every backend (no
  tag, header, wrapper or check), DecimalRounded's behavior, and
  FIXED-ARITY-LIST-RETURN.

## 2. Relationship to DecimalRounded

DecimalRounded established a schema (`hir/refinements.tcl`'s `families`)
whose every operation is generic. List is its second row:

    DecimalRounded: base DecimalRounded, applied 0, interface inferred
        minDecimalsPreserved  required, 0..1000, order atLeast
        maxDecimalsPreserved  optional, 0..1000, order atLeast (absent: inf)
    List:           base list, applied 1, interface declared
        length                required, 0.., order exactly

Three general extensions of the schema were needed, and nothing
List-specific outside it:

| extension | what it is | why the first family did not need it |
|---|---|---|
| order `exactly` | an equality fact: A implies B only when equal; Lub keeps a parameter only when both values are equal, Glb of two different values is no type (`none`) | `atLeast` was the one order a decimal guarantee needs |
| `applied` | the family refines a type constructor's applications, so the canonical form carries its base: `{srefined FAMILY FACTS BASE}`; `ParseApplied`/`Show` spell it `BASE{facts}` | DecimalRounded's base is one core type, implied by the schema |
| `interface` | where a fact may come from: `inferred` (only a proof where a refined type is expected, so a value carrying one got it from a declaration) or `declared` (inference mints it unannotated, so it crosses a function boundary only as a declared contract: `ForgetInferred`) | a DecimalRounded constant is minted only where its type is expected |

The schema test (`llr-schema-generic`) pins that no procedure of
`hir/refinements.tcl` names `length`, as `dr-schema-generic` pins it for
DecimalRounded's parameters; `llr-decimal-rounded-unchanged` pins that
DecimalRounded keeps its three-word form, its `atLeast` order and its
inferred interface. The validation messages read the family's spelling
(`Spelling`: `List[T]`), never a hard-coded name.

The two families are different theories on one mechanism: an ordered
numerical guarantee proven by exact simulation of binary64 arithmetic
(`hir/decimal.tcl`), and an exact structural fact minted by registrations,
loops and guards and consumed by the cardinality, bounds and extent proofs.
Neither knows the other.

## 3. Semantics

`List[T]{length: N}` means: this value is an ordinary `List[T]`, and its
length is proven to be exactly N. It is not a different representation, an
inline array, a tuple, a fixed-size native object or a distinct collection;
it promises nothing about what the positions mean.

At run time `List[T]{length: N}` and `List[T]` are the same kind of value:
`hir::types::kindOf` of a refined List is its base's (`list`), the native
backends see the same `list` word, and the Tcl backends the same Tcl list.
The refinement exists only in HIR types. `llr-runtime-representation`
compiles a function over a refined List and the same function over an
unrefined one and compares their NIR List operations (equal, apart from the
proofs' removed checks); `llr-decay-free` shows no operation between a
refined value and a `List[T]` parameter it is passed to.

## 4. The refinement lattice

* **Implication** is equality of the length, then the bases' subtyping:
  `List[S]{length: 4} <: List[T]{length: 4}` when `S <: T`; never `<:
  List[T]{length: 3}` or `{length: 5}`.
* **Decay** is subtyping: `List[T]{length: N} <: List[T]`, implicit and
  free (no conversion, no operation).
* **No recovery by admission**: `List[T]` is no subtype of `List[T]{length:
  N}`, and admission (`hir::range::AggregateAdmits`) inserts no check. The
  empty `List[never]` (`[]`) states length 0 by its own canonical form, so
  it is admitted where `List[T]{length: 0}` is required and nowhere a
  positive length is.
* **Joins**: `lub(List[T]{length: 4}, List[T]{length: 4}) =
  List[T]{length: 4}`; `lub({length: 4}, {length: 3}) = List[T]` (no range
  is invented: there is no `{length: 3..4}`); `lub(refined, unrefined) =
  List[T]`. A branch that never completes contributes nothing.
* **Meets** (`narrow`, `glb`): two different lengths meet in `never` (a
  guard's refinement of a List already known to have another length makes
  its branch dead).

## 5. Minting

Every source of the fact, and only these:

| source | how |
|---|---|
| a List literal `[a, b, c]` | the `list` primitive's `-result-length args` registration, read by `hir::types::MintLength` in `Call` |
| `[]` | `{list never}`, which canonically states length 0 (`Refine({list never}, length 0)` is `{list never}` itself) |
| `list::append(xs, v)` | `-result-length {list 0 1}`: one more than xs's length when xs's type states it |
| a collecting loop | `hir::types::LoopResult`: when `hir::cardinality::Exact` holds (no `break` or `continue` targets the loop) and the domain's cardinality is a constant: a List whose type states its length, a counted range with constant bounds (`loop i from 0 to 4`), any domain of a lockstep loop (its domains are proven equal) |
| a fixed array's copy | `binary::parse` (a field projected from the parse's exact copy: `hir::layouts::CopiedFieldType`), `binary::load` of a live array (`-result-length {extent 0}`), `binary::read` of an array designator (`-result-length {path 1}`), all typed by `hir::layouts::CopyType`, recursively |
| a declared parameter, struct field, context field, payload field or result | the declared type, checked where a value enters |
| a guard | `list::length(xs) == N` (section 7) |
| a validator | `list::with_length[List[T]{length: N}](xs)` (below) |

**The validator.** `list::with_length[T](xs)` (`core/listlength.tcl`,
`hir/listlength.tcl`) is imprinted with a refined List type T (TYPE
otherwise; IMPRINT without `[T]`), and its argument must already be
admissible to T's base: it proves a length, never elements. Elaboration
(`hir::listlength::Elaborate`) rewrites the call to the internal
`list#with_length(xs, N)`, so no backend reads the imprint. At run time it
compares the length once and returns its operand unchanged (no copy, no
allocation: `llr-validator-once`) or fails with the declared builtin error
LengthMismatch (`core::native::declareError`; native id
`BUILTIN_ERROR_ID_BASE + 10`, `rt_list_with_length`). Its result is T, so
everything downstream needs no further check.

**Trusted operations.** A native or foreign registration can mint a
refinement only through `-result-length` (a native's registration is
trusted, as its `-result-type` is); a foreign C function returns no List.
`-measures {List length 0}` on `list::length` says which family parameter
its Int result measures (section 7, section 10). No other path mints.

**What never mints**: `list::length(xs) >= N` (an exact length is an
equality fact), a filtering loop, a loop with `break`, a loop over a
domain of unknown length, `mutable_vector`/`mutable_array` conversions to
a List (their lengths are mutable state, with no refinement), and any
value whose type does not state it.

## 6. Function contracts

* **Refined parameters** expose the fact in the body: `fn f(xs:
  List[int]{length: 16})` reads `xs.at(15)` with no IndexNotFound to
  handle (`hir::cardinality::DefinedLength` reads the declared entry type
  of a parameter; a declared parameter type is a fact of every argument the
  function is ever called with, since admission admits no other).
* **Refined results** are contracts: every successful return (the final
  expression, each `return`, each `if` branch) must prove the length (the
  ordinary result check, `hir::range`'s declared-result verification),
  and callers see the declared type.
* **Implementation accidents do not leak.** The List family's interface
  is `declared`, so a fact inference minted crosses a function boundary
  only as a declaration: `hir::types::ForgetInferred` drops every List
  length, at every depth, from
  * an undeclared function result (`Block`; the body's own analysis keeps
    the precise type: `inferredResultType`),
  * a semantic instance's entry types and undeclared result
    (`hir/semantic.tcl`: one instance per call shape, never per length),
  * an imprint variable's binding (`hir/imprint.tcl`'s `MatchInner`),
  * a trait witness (`hir/traits.tcl`),
  * a callable contract's argument types (`hir/signatures.tcl`),
  * a mutable container's element contract (`hir/containers.tcl`,
    `MakeMutVec`): a vector made from `[[1, 2]]` holds any `List[int]`,
  * a handler's admission against its call's type (`hir/completions.tcl`):
    a handler may complete with a List of another length, which joins the
    call's to `List[T]`.
  A DecimalRounded guarantee (interface `inferred`) is kept everywhere it
  was, unchanged.

## 7. Control-flow narrowing

`list::length` is registered `-measures {List length 0}`: its Int result is
the `length` parameter of its argument 0's List family.
`hir/refine.tcl`'s `MeasuredEquality` reads a comparison `==` of such a
call with an integer constant N >= 0, in either operand order, as the
argument fact `List[T]{length: N}` on the comparison's true outcome; the
existing implication engine carries it:

* into the then-branch of `if xs.length() == N:`, through an alias of the
  condition (`same = xs.length() == 4; if same:`),
* past a `!=` early return (`if xs.length() != N: return ...`): the
  continuation is on the condition's false outcome, the negation of `!=`,
  through the engine's ordinary path facts,
* nowhere else: not into the else-branch, not after an `if` whose two
  branches complete, not for `>=`, `>`, `<`, `<=` (those stay the
  completion analysis's own relational size facts, which prove bounds but
  mint no type).

The fact narrows the read's static type (the `ref` of xs inside the
branch), so every later use -- a call, an index, a field store, a return
-- sees a refined List. When the narrowed outcome is impossible (the
static type already states another length), the branch is dead: its facts
meet in `never`, and `IfImplication` still applies the decided branch's
facts to its body rather than leaving it typed with the old length (dead
code is still verified, as for integer domains).

## 8. Fixed-array integration

A fixed layout array's copied value was already a List of exactly its
extent (FIXED-LAYOUT-ARRAYS.md), proven by the extent machinery
(`ExactCopy`, the `extent` and `path` result lengths). Now its type says
so:

* `hir::layouts::CopyType` gives the copy of a representation its type:
  `array N of E` copies to `List[CopyType(E)]{length: N}`, recursively
  (`array 2 of array 3 of binary::U16` copies to
  `List[List[binary::U16]{length: 3}]{length: 2}`), a record element to its
  LayoutStruct, a scalar to its domain.
* `binary::load` of a live array, `binary::read` of an array designator and
  a field projected from what `binary::parse` (or `binary::load` of a
  record) copied (`hir::layouts::CopiedFieldType`) have that type.
* A `LayoutStruct[L]` the program constructs keeps its declared, unrefined
  field types: the nominal struct type is shared by every value of it, a
  copy and a construction alike, so it cannot state that its fields are
  exact copies. A projection of an exact copy is refined; a projection of
  a construction is not (its write keeps the run-time extent check).
* A refined List written whole into a fixed array of its extent
  (`binary::emit`, `binary::write`, `binary::store`) is `in` for the
  extent proof (`hir::completions::ReprValueVerdict` reads its length from
  its type, `TypedLength` beside `ListLength`): no LayoutExtentMismatch
  path, natively no `listlen`/branch/`faildeclared` (`llr-array-writes`).
  A List of another known length is `out`: KNOWN-ERROR. An unrefined List
  keeps the run-time check its handler takes.
* Unions are unchanged: an array of unions or a union holding an array
  still has no copied value (LAYOUT-UNION), so no refined List of one ever
  exists (`llr-array-copy-agrees` checks the refusal stays).

`llr-array-copy-agrees` checks, for every copy source, that the two places
stating a copy's length agree: the refined type (`CopyType`) and the exact
copy the extent proof reads (`ExactCopy`). The mutants `copy-off-by-one`,
`copy-inner-lost` and `copy-unrefined` break one of them.

## 9. Cardinality-system migration

The existing exact-cardinality sources, and where each stands now:

| source | before | after | status |
|---|---|---|---|
| List literals | `hir::cardinality::ListLength` counted a `list` call's arguments; no type knew | the `list` primitive's `-result-length args` mints the refinement (`MintLength`); ListLength reads it from the type (`DefinedLength`) and its own literal case is gone | directly mints; the old case was redundant and removed |
| `[]` | `List[never]` | `{list never}` states length 0 canonically | directly mints (by its canonical form) |
| fixed-array `binary::load`, `binary::read` | ListLength's `extent` and `path` cases | the same registrations mint through `MintLength`; ListLength's two cases are gone | directly mints; the old cases were redundant and removed |
| fields of `binary::parse`'s copy | only `ExactCopy` knew | `CopiedFieldType` types the projection | directly mints |
| `ExactCopy` | the extent proof's evidence that a value is an exact copy of a representation | kept: it also states a fact of a whole `LayoutStruct[L]` value (every array of a record copy has its extent) that `LayoutStruct[L]`'s nominal type cannot state, constructed values sharing it; checked to agree with the types (`llr-array-copy-agrees`) | internal fact for another reason |
| collecting loops | `of_loop` exact plus the domain's cardinality form, used by index proofs | a constant cardinality mints the refinement (`LoopResult`); a symbolic one (a loop over a parameter of unknown length) stays a cardinality form (`len` atom) | directly mints (constant); internal for another reason (symbolic: a refinement holds only constants, section 20) |
| result-length registrations | `int K` and `list K` (a MutableArray's capacity), `extent K`, `path K` | List results (`args`, `{list K D}`, `extent K`, `path K`) mint through `MintLength`; the capacity forms (`int K`, `list K` on a MutableArray result) stay cardinality forms | directly mints (Lists); internal for another reason (MutableArray capacity: no capacity refinement, by design) |
| length-equality guards | the completion walk's relational sizes (`ctx.sizes`, from `list::length(xs) == N` in a branch condition) | `MeasuredEquality` mints the refinement on the narrowed read; `ctx.sizes` stays for what no type states: MutableArray and MutableVector sizes, Strings, and the inequalities' `minSizes`/`upperBounds` | feeds a general proof that mints it (the implication engine); the relational facts stay internal for another reason |
| struct construction | a field declared `List[T]` | a field declared `List[T]{length: N}` is a contract checked at construction and read at projection | directly mints (declared) |
| function return annotations | `-> List[T]` | `-> List[T]{length: N}` is proven on every exit and seen by callers; an undeclared result forgets | directly mints (declared) |
| `list::append` | nothing | `{list 0 1}` | directly mints (new) |
| `list::length` | its argument's cardinality form | also the range point N of a refined argument (`hir::types::MeasuredValue`, read by `hir::range`) | feeds a general proof (the range analysis) |
| exact values (`hir::exact`) | a constant List's elements | unchanged: an exact value states elements, not only a length | internal fact for another reason |
| lockstep equal counts (`hir/lockstep.tcl`) | proves a lockstep loop's domains have one count | unchanged: a relation between two values, no constant | internal for another reason (relational) |
| MutableVector / MutableArray iteration lengths | `IterationLength`'s epochs and places | unchanged | internal for another reason (mutable cardinality) |

So Botlish now has one notion of an exact *constant* List length: the
type. Every source that knows a constant states it there, and every proof
that needs one reads it there (`DefinedLength`, `TypedLength`,
`MeasuredValue`). What remains in the cardinality forms is what a constant
refinement cannot say: symbolic lengths, relations between two values,
mutable state and exact values.

## 10. Bounds proofs

* `list::at(xs, i)` (and every native whose `-bounds` reads a List size):
  `hir::completions::IndexBounds` and `SizesOf` add the length the read's
  own type states (`TypedLength`) to the size forms `ListLength` gives
  (which now include the declared length of a parameter, a loop variable
  over a List of refined Lists, and every expression's type). An index
  proven in `0..N-1` is proven: natively `listgetproven`, with no
  IndexNotFound edge, and a function whose only fallible operations are
  proven stops being fallible; the Tcl compiler calls the native directly.
  An index proven outside is KNOWN-ERROR.
* `list::length(xs)` of a refined xs has the point range N, so a
  comparison with it is decided by the range analysis and a decided
  branch is lowered without its other arm (`llr-length-known`).
* Fixed-array whole writes lose LayoutExtentMismatch (section 8).

The proof key stays an immutable List's. Nothing was generalized to
MutableVector lengths: a MutableVector or MutableArray has no length
refinement, and `IterationLength`'s mutation analysis (the hash-table
investigation's) is untouched.

## 11. Operations preserving cardinality

Preserve exactly:

* binding and aliasing (`ys = xs`), passing and returning through declared
  types, struct and context fields declared refined, capture by a nested
  function, a context's field, a coroutine's construction (an immutable
  List's length never changes, so nothing invalidates it);
* `if`/handler joins of equal lengths;
* `list::append` (N + 1);
* collecting loops with no `break` or `continue` over a domain of constant
  cardinality -- the map shape `loop x in xs: f(x)`, `loop i from 0 to N:`,
  lockstep loops;
* `list::with_length` (its result is exactly its imprint);
* fixed-array copies.

Deliberately decay to `List[T]`:

* a filtering loop (`continue`) or a `break`;
* a loop over a List or range of unknown length;
* the join of different lengths, or of a refined and an unrefined List;
* an undeclared function result, a semantic instance's entry types, an
  imprint variable, a trait witness, a callable contract's arguments, a
  mutable container's elements, a handler's admission (section 6);
* conversions from mutable containers (`mutable_vector::to_list`,
  `mutable_array::freeze`, ...).

There is no List concatenation, slice, map or filter function to give a
rule to (capability.map-filter: a collecting loop is the transformation).

## 12. Product versus sequence

`FIXED-ARITY-LIST-RETURN` (WARNINGS-FIXED-ARITY-LIST-RETURN.md) warns when
every value exit of a function without a declared List result is a List
literal of one length: a struct names the parts. It reads the frontend's
`written {form list}` provenance and the block's `declaredResult`, never a
type's facts, so a refinement neither triggers nor suppresses it:

* a declared `-> List[T]{length: N}` is a list result type exactly like
  `-> List[T]`: the author's statement that the result is a sequence
  (`hir::warnings::DeclaresListResult` asks the declared type's kind,
  `list` through the refinement);
* an undeclared function returning `[a, b]` warns exactly as before, though
  its literal's type is now `List[T]{length: 2}`.

`llr-fixed-arity-unchanged` compiles eight pairs of programs that differ
only in `List[T]` versus `List[T]{length: N}` (two- and four-position
products, nested results, an unannotated function, a declared sequence)
and requires identical warnings; `tests/fixed-arity-list-return.test`
(149 tests) is unchanged and passes. The mutant `fixed-arity-suppressed`
(a literal whose type states a length taken for a declared sequence) is
killed by it. Knowing that a List has two elements does not make its
positions an idiomatic product, and the refinement is not a tuple.

## 13. HIR, interchange, cache and isolation

* **HIR text** writes a refined List in its source spelling
  (`List[int]{length: 4}`; a bare List kind `list{length: 2}` for a
  heterogeneous literal) and `hir::read` reads it back
  (`hir::refinements::ParseApplied`, tried before DecimalRounded's form):
  `llr-hir-text` round-trips parameters, results, struct fields, literals,
  nested refinements.
* **Interchange** holds the HIR's types dict itself, so the canonical form
  travels as it is; `llr-interchange` decodes in a fresh process and
  compares (equal) and runs (alike). The mutant `interchange-drops` is
  killed by it.
* **Cache.** The front-end cache's key holds the source text, so programs
  differing only in a length are two entries, each read back as built
  (`llr-cache-and-isolation`).
* **Isolation.** No registry holds a refinement: the List family is a
  compile-time constant of `hir/refinements.tcl`, and refined types live in
  each HIR's own types. The new builtin error and natives are process
  registrations made once at load time, like every builtin's. Compiling a
  program with other lengths never changes an earlier HIR
  (`llr-cache-and-isolation`).

## 14. Runtime and code generation

* No new value kind, tag, header or wrapper: a refined List is the
  ordinary List word natively and the ordinary Tcl list on the Tcl
  backends (`llr-runtime-representation`).
* Decay emits nothing (`llr-decay-free`).
* No monomorphization by length: Lists of different lengths share an
  untyped function's semantic instance and its codegen instance
  (`llr-no-monomorphization`: semantic instance entry types forget the
  length, `hir::specialize::ElementKeyType` strips refinements).
* The one run-time addition is the validator: `list#with_length` (Tcl:
  `core::listlength::withLength`; native: the NIR op `listwithlen`,
  `rt_list_with_length`, which returns its operand or fails declared).
* What the proofs remove, natively: `listget` with its IndexNotFound edge
  becomes `listgetproven`; a whole-array write's `listlen`/compare/
  `faildeclared LayoutExtentMismatch` disappears; a decided
  `list::length` comparison loses its other arm. The NIR evidence tests
  (`llr-bounds`, `llr-array-writes`, `llr-length-known`,
  `llr-validator-once`) pin each.

## 15. Diagnostics

Admission failures name what is missing, with the refined spelling:

    argument for parameter "r" cannot be proven to satisfy
    List[int]{length: 3} (argument type: List[int]); List[int] states no
    exact length: a List's length is known only where its type states it
    (a List literal, a declared parameter, field or result, a guard such as
    `list::length(xs) == 3`, or list::with_length), and admission inserts
    no length check (CORE SEMANTIC TYPE)

    argument for parameter "r" cannot be proven to satisfy
    List[int]{length: 3} (argument type: List[int]{length: 2}); a List of
    exactly 2 element(s) is never one of 3: an exact length is an equality
    fact, implied by no other length (CORE SEMANTIC TYPE)

The same clause (`hir::range::LengthClause`) follows argument, field,
payload, result, structural-call and layout-write messages, which show the
argument's type with its refinement (`ShownArgType`) whenever the expected
type mentions one. Any other message that shows a value's type shows it
without the lengths inference minted (`hir::types::showValue`): a List is
no struct, and no C scalar, whatever its length, and `cannot project field
"a" from a value of type List[int]` reads as it always did. Parameter
problems are REFINEMENT-PARAMETER (`List[T]'s
"length" must be at least 0, not -1`; `"size" is not a parameter of
List[T] (its parameters: length)`; `"MutableVector" has no scalar
refinements`). A misused validator is TYPE (`list::with_length checks a
List against the exact length its imprint states, so it is imprinted with
a List[T]{length: N} type ...`) or IMPRINT. Out-of-range indices and wrong
extents are the existing KNOWN-ERROR. Every one is recoverable in a
`static compile:` block (`llr-static-compile`). Compilerpedia documents
them: `concept.scalar-refinements`, `concept.list-length` (its `match:`
lines route these messages' help to it), `stdlib.list::with_length`,
`error.refinement-parameter`, `proof.list-bounds`; `principle.idiomatic-
botlish` gains one line and a link.

## 16. Fuzzing

`audit/list-length-refinement/tools/fuzz.tcl` generates random programs
that build a List from random sources (literals, numeric and List
collecting loops, `list::append`, a filtering loop, a branch between two
Lists, a parameter of unknown length, an undeclared and a declared
function result, `list::with_length`, fixed-array copies), nested up to
three deep, and hand it to a consumer that requires an exact length: a
refined parameter, a `==` guard, a `!=` early return, the validator, a
refined struct field; or index a refined List; or write a copied array of
one extent into an array of another.

Its oracle is independent: the generator computes each source's run-time
List itself and the length the language promises for it from the rules of
this document, written out from scratch (never asking `hir/types.tcl` or
`hir/cardinality.tcl`). A case disagrees when the compiler accepts what
the rules reject, rejects what they accept, rejects with another kind
(TYPE for an unproven length, KNOWN-ERROR for an index or extent proven
wrong), or an accepted program's value differs from the oracle's on any of
the four backends (the List itself is part of every value, so an unsound
fact shows as a wrong List, a wrong guard decision or a crash).

Results (four backends, interp, compile, cranelift-generic and cranelift;
the case mix is printed by every run): seeds 1 to 5 of 60 cases each and
seed 6 under `BOTLISH_NATIVE_GC_STRESS=1`, 0 disagreements; after the
index cases were widened to every source (section 17), seeds 1 to 3 of
120 cases each, 0 disagreements. Every family of the mix occurs: the six
consumers accepting and rejecting (TYPE), index reads in and out of range
(KNOWN-ERROR) of parameters and of sources, sources of unknown length
read under a handler, equal and unequal extents (KNOWN-ERROR), nested
literal, loop and ragged Lists.

## 17. Mutation testing

`audit/list-length-refinement/tools/mutate.tcl` applies each mutant of
`audit/list-length-refinement/tools/mutants.txt` to a private copy of the
tree (rebuilding a private native backend for a native mutant) and runs
the detectors: `tests/list-length-refinement.test`, the fuzzer (seed 1,
60 cases) and, for a native mutant, `cargo test --lib list_with_length`.
Every mutant must still apply and be killed by a test of behavior or the
fuzzer.

37 mutants, all applied and all killed. The first full run killed 36 of
them; one survived, `bounds-n-plus-one` (a refined List's size form one
more than its length). It exposed a gap in the tests, not in the
compiler: when two known sizes of one List disagree,
`hir::completions::IndexBounds` takes the read for unreachable and proves
it, so a size form off by one from the type made
every index of a List whose length an *expression's* type states (a
declared result, `list::with_length`, `list::append`, a collecting loop, a
copy) proven, out-of-range ones included -- and the tests indexed only
parameters and literals, which take other paths. `llr-bounds-every-source`
now reads each such source in and out of range, and the fuzzer's index
cases read a random source's List; both kill it (rerun with `-only
bounds-n-plus-one`).

Each row: the tests that failed (the harness lists the first six), the
fuzzer's verdict on its 60 cases of seed 1, and, for a native mutant, the
validator's Rust test. A mutant the fuzzer misses is still killed by a test
of behavior; none is killed by a pinned snapshot alone.

| mutant | the bug | tests killing it | fuzzer | native |
|---|---|---|---|---|
| `refinement-ignored` | a declared List[T]{length: N} resolves to List[T]: the fact is dropped | 21: `llr-admission-static`, `llr-array-writes`, `llr-bounds`, `llr-cache-and-isolation`, `llr-canonical-form`, `llr-captures-contexts-coroutines`, ... | 38 of 60 cases | - |
| `runtime-type` | a refined List's runtime kind is taken to be its refinement form, not the List's | 10: `llr-admission-static`, `llr-array-copies-run`, `llr-bounds`, `llr-declared-contracts`, `llr-fixed-arity-unchanged`, `llr-guard-narrowing`, ... | 6 of 60 cases | - |
| `decay-rejected` | forgetting a length is not subtyping | 2: `llr-implication`, `llr-no-monomorphization` | 4 of 60 cases | - |
| `decay-rejected-admission` | admission does not forget an argument's length where a List[T] is required | 15: `llr-admission-static`, `llr-append`, `llr-array-copies`, `llr-array-writes`, `llr-bounds`, `llr-decay-free`, ... | 32 of 60 cases | - |
| `wrong-length-admitted` | an exact fact implies any other value of it | 4: `llr-admission-static`, `llr-handlers-branches`, `llr-implication`, `llr-static-compile` | 4 of 60 cases | - |
| `generic-ordering-exact` | exact length is ordered like an atLeast parameter (a List of 4 is taken for one of 3) | 1: `llr-implication` | 1 of 60 cases | - |
| `unrefined-admitted` | a List of no known length is admitted where a length is required | 3: `llr-admission-static`, `llr-guard-scopes`, `llr-return-contract` | 11 of 60 cases | - |
| `join-keeps-left` | two different lengths join to the left one | 4: `llr-handlers-branches`, `llr-joins`, `llr-literals-mint`, `llr-return-contract` | survived | - |
| `join-keeps-right` | two different lengths join to the right one | 4: `llr-handlers-branches`, `llr-joins`, `llr-literals-mint`, `llr-return-contract` | 1 of 60 cases | - |
| `join-invents` | two different lengths join to an invented one (their larger) | 4: `llr-handlers-branches`, `llr-joins`, `llr-literals-mint`, `llr-return-contract` | survived | - |
| `return-unchecked` | a declared refined result is not held to its length | 1: `llr-return-contract` | survived | - |
| `result-leaks` | an undeclared result keeps the length its implementation happens to have | 1: `llr-undeclared-result-forgets` | survived | - |
| `instance-key-keeps` | a semantic instance is keyed by the lengths its caller's arguments happen to have | 1: `llr-no-monomorphization` | survived | - |
| `literal-off-by-one` | a List literal's length is one more than its element count | 20: `llr-admission-static`, `llr-append`, `llr-bounds`, `llr-cache-and-isolation`, `llr-captures-contexts-coroutines`, `llr-collecting-loops`, ... | 24 of 60 cases | - |
| `empty-is-one` | the empty List[never] states length 1 | 7: `llr-canonical-form`, `llr-guard-narrowing`, `llr-implication`, `llr-joins`, `llr-literals-mint`, `llr-static-compile`, ... | 8 of 60 cases | - |
| `append-no-increment` | list::append's result has its List's length, not one more | 1: `llr-append` | survived | - |
| `loop-ignores-break` | a collecting loop that breaks still mints its domain's length | 1: `llr-collecting-loops` | survived | - |
| `guard-wrong-branch` | list::length(xs) == N refines xs where it does not hold | 2: `llr-guard-narrowing`, `llr-return-contract` | 6 of 60 cases | - |
| `guard-one-order` | only list::length(xs) == N narrows, never N == list::length(xs) | 1: `llr-guard-narrowing` | survived | - |
| `neguard-no-narrow` | a != early return does not narrow what follows it (the decided-path facts dropped) | 1: `llr-guard-narrowing` | 3 of 60 cases | - |
| `inequality-mints` | list::length(xs) >= N refines xs to List[T]{length: N} | 1: `llr-guard-scopes` | survived | - |
| `copy-unrefined` | a copied fixed array is a List of no known length | 4: `llr-array-copies`, `llr-array-copies-run`, `llr-array-copy-agrees`, `llr-array-writes` | 5 of 60 cases | - |
| `copy-inner-lost` | a copied array of arrays forgets its rows' extent | 3: `llr-array-copies`, `llr-array-copies-run`, `llr-array-copy-agrees` | survived | - |
| `copy-off-by-one` | a copied fixed array's List states one element more than the extent (the type and the exact copy disagree) | 3: `llr-array-copies`, `llr-array-copy-agrees`, `llr-array-writes` | 5 of 60 cases | - |
| `parse-field-unrefined` | a field of what binary::parse made has its LayoutStruct's unrefined field type | 4: `llr-array-copies`, `llr-array-copies-run`, `llr-array-copy-agrees`, `llr-array-writes` | 5 of 60 cases | - |
| `write-still-checks` | a refined List's length is not read by the size forms: an extent (or index) it proves keeps its run-time check | 1: `llr-bounds` | survived | - |
| `write-accepts-wrong` | a List of another known length is admitted into a fixed array (a write proven wrong is taken for proven) | 1: `llr-array-writes` | 5 of 60 cases | - |
| `bounds-n-plus-one` | a refined List's size form is one more than its length | 1: `llr-bounds-every-source` | 3 of 60 cases | - |
| `measured-ignored` | list::length of a refined List is not known to be its length | 1: `llr-length-known` | survived | - |
| `handler-strict` | a handler's List of another length is inadmissible as the call's result | 1: `llr-handlers-branches` | survived | - |
| `vector-keeps-literal-length` | a MutableVector's element contract keeps the length its first elements had | 1: `llr-mutable-element-contracts` | survived | - |
| `hir-text-drops` | HIR text writes a refined List without its facts | 13: `llr-admission-static`, `llr-append`, `llr-array-copies`, `llr-cache-and-isolation`, `llr-canonical-form`, `llr-collecting-loops`, ... | survived | - |
| `interchange-drops` | decoding interchange text forgets every List length (the HIR read back, as from the front-end cache, differs from the built one) | 2: `llr-cache-and-isolation`, `llr-interchange` | survived | - |
| `fixed-arity-suppressed` | a literal exit whose type states a length is no fixed-arity exit (the refinement taken for a suppression) | 1: `llr-fixed-arity-unchanged` | survived | - |
| `validator-unchecked` | list::with_length mints the refinement without checking the length (Tcl runtime) | 1: `llr-validator` | 7 of 60 cases | - |
| `validator-unchecked-native` | list::with_length mints the refinement without checking the length (native runtime) | 1: `llr-validator` | 7 of 60 cases | killed |
| `validator-copies` | list::with_length returns a copy of its List, not the List itself (native runtime) | 1: `llr-validator-once` | survived | killed |

## 18. Regression

Everything below ran on this branch in the development container (Linux
x86-64), with the release native backend built from it.

**The whole suite.** `tclsh9.0 tests/local.tcl` (every Tcl test file on
interp and compile, every golden suite on all four backends): the
failures were all of three kinds, each now fixed and rerun clean --

* tests that show the inferred type of a List literal or collecting loop
  (enums, float64, immutable sets, structs, structural Fn types,
  MutableArray construction and types, virtual construction, exact-value
  facts, variadics, UnicodeChar Lists, loops, HIR types, inference, the
  HIR samples): the type now states the length, as designed; their
  expectations, census descriptions and the three `examples/hir` samples
  were updated;
* inventories of natives, ownership roles and builtin errors
  (stdlib-namespaces, mutable-array's roles audit): they list
  `list::with_length`, `list#with_length` and LengthMismatch;
* two diagnostics that showed a value's type in a message not about
  lengths (a field projected from a List, `destructuring.bot`; a List as a
  variadic C argument, `c-ffi.test`): `hir::types::showValue` (section 15)
  shows them without the minted length again; and the new code's four
  `expr {c ? a : b}` selections of possibly-string values
  (`nl-no-string-ternary`), now `if` statements.

The rerun of every file that had failed, narrowed through
`tests/local.tcl`: 862 tests passed on interp and on compile, 0 failed;
`destructuring.bot` 378/378 on all four backends.

**Harnesses** (each with its own private tree; mutants must apply and be
killed):

| harness | result |
|---|---|
| `tests/list-length-refinement.test` | 38 tests on interp and compile; also under `BOTLISH_NATIVE_GC_STRESS=1` |
| `cargo test --lib list_with_length` | passes |
| List length fuzzer, mutants | section 16, section 17 |
| DecimalRounded: `tests/decimal-rounded.test`, golden suite, fuzzer seeds 1-3, mutants | all pass; 24/24 mutants killed |
| bounds proofs: fuzzer seeds 1-3 and 4 under GC stress; mutants | 0 failures; 57/57 killed |
| fixed layout arrays, layout unions, binary layouts, native views, native edits: fuzzers seeds 1-3 and 4 under GC stress | 0 disagreements each |
| binary-layout, native-view, native-edit mutants | 39/39, 29/29, 40/40 killed |
| layout-arrays, layout-unions mutants | 24/24 killed each (layout arrays: 23 in the run, `loaded-length-one-more` after its retargeting, below) |
| MutableVector, MutableArray: suites; fuzzers seeds 1-2 and 3 under GC stress; MutableArray mutants | 0 disagreements; 36/36 killed |
| affine values, coroutines: suites; affine fuzzer seeds 1-2; mutants | 0 disagreements; 29/29 and 52/52 killed |
| refinement values, traits, structural contracts: fuzzers seeds 1-2 | 0 failures each; structural-contracts mutants 18/18 killed |
| C ABI types: suite; mutants | 26/26 killed (the fuzzer: below) |
| HIR interchange: `roundtrip.tcl -via interchange`, `-via cache`; mutants | 12 suites, 108 and 120 artifacts and outcomes, 0 differ; 27/27 killed |
| compilation isolation: `interleave.tcl`; mutants | 12 suites, 96 artifacts and outcomes, 0 differ; 14/14 killed |
| static decisions: fuzzer seeds 17, 41, 3; mutants | 0 failures (the layout pairs taking different rounds are the same as before the milestone: 0, 2, 2); 73/73 mutants killed (in two runs, mutants 1-48 and 45-73) |
| FIXED-ARITY-LIST-RETURN: `tests/fixed-arity-list-return.test` | 144 tests pass, unchanged (section 12) |
| C binding generator: `tests/c-bindgen.test`; `tools/c-bindgen.tcl check fixture -target committed` | passes; the fixture's four targets current (byte for byte). The real libraries' profiles need their pinned sources (not fetched here; the c-bindgen workflow runs them); the generator is unchanged |
| Compilerpedia: `tools/compilerpedia.tcl check` | 697 topics, 569 examples, 0 problems |
| every mutant of every audit applies | 1295 edits checked statically; the one this milestone moved (`loaded-length-one-more`, layout arrays: the copy's length moved from `hir::cardinality::ListLength` into the type) retargeted and killed |

Two findings outside this milestone, reproduced identically on the tree
before it and left as they are: the C ABI types fuzzer reports
disagreements on every seed, each a program compiled for another target
run on the native backend, which refuses it (`NATIVE TARGET`) -- the
fuzzer predates that refusal; and the static-decision fuzzer's seeds 41
and 3 report two layout pairs taking different rounds (no failure).

**CI.** The batched-against-sequential comparison of the golden suites'
static decisions runs in CI only (`static-decisions.yml`, dispatched on
this branch), as do the Linux arm64 workflow, the full Tcl and golden
suites with duplicates (`tests.yml`) and the macOS tiers. `tests.yml`,
`tests-arm64.yml` and `static-decisions.yml`, dispatched on the branch,
passed (no batched/sequential disagreement); the commits after the one
they ran change only tests, audits and documents. The macOS arm64
workflow (Tier A smoke, Tier B acceptance) passed on the branch's pushes.

## 19. Performance

`bench/list-length-refinement.tcl` regenerates these tables.

Measured on the 4-core development container (2026-10-21) while two
mutation harnesses ran beside it (load about 2): best of 5 in-process runs,
compilation excluded; n = 20000 operations per Tcl program, 2000000 per
Cranelift program. Each operation is measured through a parameter of type
`List[T]` and through one of type `List[T]{length: 16}`, as time per
operation over the program's own baseline, the whole program per operation
in parentheses.

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| list::at(xs, 7), xs: List[int] | 67763.5 ns (102427.9 ns) | 19259.0 ns (21130.9 ns) | -7.5 ns (53.9 ns) |
| list::at(xs, 7), xs: List[int]{length: 16} | 59736.2 ns (90005.6 ns) | 10588.0 ns (12668.9 ns) | 9.6 ns (71.3 ns) |
| list::length(xs), xs: List[int] | 33739.4 ns (67063.9 ns) | 5048.2 ns (8253.9 ns) | -40.6 ns (55.3 ns) |
| list::length(xs), xs: List[int]{length: 16} | 42164.6 ns (74876.4 ns) | 2908.5 ns (5250.4 ns) | 11.0 ns (82.7 ns) |
| binary::write of a 16-element row, row: List[U16] | 227402.0 ns (259893.9 ns) | 118831.4 ns (121086.6 ns) | 356.4 ns (410.3 ns) |
| binary::write of a 16-element row, row: List[U16]{length: 16} | 240700.4 ns (270151.4 ns) | 126700.3 ns (130136.6 ns) | 335.5 ns (388.7 ns) |
| two reads of xs: List[int] (each may fail) | 166955.8 ns (197423.5 ns) | 35212.7 ns (37360.3 ns) | 0.9 ns (58.1 ns) |
| two reads of ys, validated once by list::with_length | 181967.6 ns (215188.8 ns) | 9909.4 ns (12147.5 ns) | 4.1 ns (56.2 ns) |

What it shows:

* **Statically minted facts cost nothing at run time, and decay is free**:
  a refined parameter and an unrefined one are the same List (the
  allocation table: identical counts for every pair).
* **The Tcl compiler** is where a removed check shows in time: a proven
  `list::at` is a direct native call instead of the error-handling call
  path, 19.3 against 10.6 microseconds, and two reads of a List validated
  once by `list::with_length` cost 9.9 microseconds against 35.2 for two
  reads that may each fail -- the validator's one length comparison is all
  the run pays, and every downstream read loses its check. A
  `list::length` whose value the type states is 2.9 against 5.0.
* **Cranelift**: the removed IndexNotFound edge and LayoutExtentMismatch
  branch are a compare and a branch each, below this method's resolution
  (the deltas are within a few nanoseconds of zero, either sign); the NIR
  tests (`llr-bounds`, `llr-array-writes`, `llr-validator-once`,
  `llr-length-known`) are the evidence that they are gone.
* **The interpreter** is the reference and checks every access whatever
  the types say; its differences are noise.
* **A whole fixed-array write** is dominated by building the fresh
  MutableBytes it returns (one allocation per write on every backend);
  the extent check a refined List removes is a length comparison, not
  measurable beside it.

Allocations of each whole Cranelift program:

| program | allocations | Lists |
|---|---:|---:|
| base | 8 | 4 |
| base-refined | 8 | 4 |
| at | 8 | 4 |
| at-refined | 8 | 4 |
| write | 2000008 | 4 |
| write-refined | 2000008 | 4 |
| reads | 8 | 4 |
| validated | 8 | 4 |

**Front-end scaling and no refinement explosion.** A program declaring K
distinct refined List types, lengths 0 to K-1 (each the parameter and
result of a function, each minted by `list::with_length` under a handler),
against the same program with `List[int]` and no validation:

| K | refined | per type | List[int] | per type | ratio |
|---:|---:|---:|---:|---:|---:|
| 10 | 170 ms | 16.99 ms | 110 ms | 11.04 ms | 1.54 |
| 100 | 1797 ms | 17.97 ms | 1082 ms | 10.82 ms | 1.66 |
| 1000 | 36958 ms | 36.96 ms | 29633 ms | 29.63 ms | 1.25 |

The refined program costs 1.25 to 1.66 times the unrefined one at every
size -- it has a validator call and a handler per function more -- and the
ratio does not grow with K: a length is a few integers in one canonical
type, compared by value, with no per-length type object, registry entry or
instance (`llr-no-monomorphization`: Lists of different lengths share one
semantic and one codegen instance). The per-type cost of both programs
rises at K = 1000 for the program's size (a thousand top-level functions),
not for its refinements.

## 20. Future pressure

Assessed, not implemented.

**Symbolic scalar imprints.** A future `fn map[N](xs: List[T]{length: N},
f) -> List[U]{length: N}` needs N to be a rigid scalar variable bound from
an argument's refinement. The representation can hold it: a fact is a
parameter's value in a canonical dict, and nothing but the validation of
written source (`ResolveFacts` requires an integer literal) assumes the
value is a constant. The blockers are where the facts are compared and
combined: `Stronger`, `ImpliesFacts`, `LubFacts` and `GlbFacts` compare
values with `eq`/integer comparison, so a symbolic value would need a
substitution step before admission (imprint matching already binds type
variables left to right, `hir/imprint.tcl`'s `Match`; a scalar variable
would bind the same way) and a rule for joining a symbol with a constant
(the `exactly` order makes that simple: equal or forgotten). The
cardinality forms already compute symbolic lengths (`len` atoms) for
collecting loops and parameters, so a cardinality-preserving map's
body-side proof exists; what is missing is a way to state it in a
signature. Use cases and their extra needs:

* *cardinality-preserving map*: the scalar imprint above; the loop rule is
  in place.
* *exact-size decode*: `binary::parse` results are already refined from
  the static layout; a decoder from a length read at run time needs a
  validator (exists) or a dependent result (out of scope).
* *MutableArray capacity*: a capacity is mutable *state* only in the sense
  that the binding may be replaced; a fixed-size array's capacity never
  changes, so `MutableArray[T]{capacity: N}` would be sound as an
  `exactly` fact of the value -- but MutableArray's value semantics
  (copy-on-write headers, `hir::mutvec::Elaborate`'s logical copies) and
  its place discipline would have to carry the fact through every share
  and move, which this milestone deliberately did not touch.
* *hash-table index helpers*: `h.mod(slots.capacity())` against
  `keys.at(...)` of a second array of equal capacity needs a relation
  between two values, not a constant: a relational refinement (out of
  scope, and the reason `proof.list-bounds` lists it as a limitation).

No architectural blocker was found in the canonical form, the schema or
the interchange: the work is in the comparison procedures and in where
imprints bind.

**Relational refinements** (`length(a) == length(b)`) do not fit the
scalar-refinement form at all: they are facts of two values, which the
lockstep and cardinality analyses keep as internal relations today.

## 21. Acceptance criteria

| # | criterion | where |
|---|---|---|
| 1 | existing scalar-refinement syntax and machinery | sections 1, 2; `llr-parse-forms`, `llr-schema-generic` |
| 2 | non-negative compile-time scalar | `llr-parameters-validated` |
| 3 | equality-style semantics | `llr-implication`, mutants `wrong-length-admitted`, `generic-ordering-exact` |
| 4, 5 | implicit decay, no run-time operation | `llr-decay-free`, mutants `decay-rejected*` |
| 6, 7, 8 | other or no length rejected; no implicit validation | `llr-admission-static`, mutant `unrefined-admitted` |
| 9, 10 | literals and `[]` mint | `llr-literals-mint`, mutants `literal-off-by-one`, `empty-is-one` |
| 11, 12, 13 | parameters, results proven on every return, visible to callers | `llr-declared-contracts`, `llr-return-contract`, mutant `return-unchecked` |
| 14 | accidents do not become contracts | `llr-undeclared-result-forgets`, mutants `result-leaks`, `instance-key-keeps` |
| 15, 16, 17 | `==` narrows, `!=` early return, `>=` does not | `llr-guard-narrowing`, `llr-guard-scopes`, mutants `guard-*`, `neguard-no-narrow`, `inequality-mints` |
| 18 | validator without copy | `llr-validator`, `llr-validator-once`, mutants `validator-*` |
| 19, 20, 21, 22 | layout copies, nested, unions, ExactCopy agreement | `llr-array-copies`, `llr-array-copies-run`, `llr-array-copy-agrees`, mutants `copy-*`, `parse-field-unrefined` |
| 23, 24 | result-length registrations, list::length | `llr-append`, `llr-length-known`, mutants `append-no-increment`, `measured-ignored` |
| 25, 26, 27 | bounds proofs | `llr-bounds`, mutants `bounds-n-plus-one`, `write-still-checks` |
| 28, 29, 30 | fixed-array writes | `llr-array-writes`, mutant `write-accepts-wrong` |
| 31, 32, 33 | loops, preserving operations, conservative decay | `llr-collecting-loops`, `llr-append`, mutant `loop-ignores-break` |
| 34, 35 | no MutableVector or MutableArray refinement | `llr-parameters-validated`, `llr-mutable-element-contracts`, mutant `vector-keeps-literal-length` |
| 36, 37 | no dependent types, no user keys | the schema is the compiler's (`llr-schema-generic`) |
| 38, 39 | struct fields, captures | `llr-declared-contracts`, `llr-captures-contexts-coroutines` |
| 40, 41 | joins | `llr-joins`, `llr-handlers-branches`, mutants `join-*`, `handler-strict` |
| 42 to 45 | HIR text, interchange, cache, isolation | `llr-hir-text`, `llr-interchange`, `llr-cache-and-isolation`, mutants `hir-text-drops`, `interchange-drops` |
| 46 to 49 | representation, no monomorphization, zero cost, validate once | section 14; `llr-runtime-representation`, `llr-no-monomorphization`, `llr-validator-once` |
| 50 to 53 | regressions | section 18 |
| 54, 55 | fuzzer, mutants | sections 16, 17 |
| 56, 57, 58 | FIXED-ARITY-LIST-RETURN | section 12; `llr-fixed-arity-unchanged`, mutant `fixed-arity-suppressed` |
| 59, 60 | migration inventory, future assessment | sections 9, 20 |

## 22. What to run when changing this

If you change the List row of the refinement schema or the generic
`exactly`/`applied`/`interface` machinery (`hir/refinements.tcl`), the
refined-List cases of `hir/types.tcl` (subtype, lub, glb, narrow, kindOf,
`Refine`, `Unrefined`, `LengthOf`, `ForgetInferred`, `MintLength`,
`LoopResult`), the length guard (`hir/refine.tcl`'s `MeasuredEquality`,
`IfImplication`'s decided branches), admission and its messages
(`hir/range.tcl`'s `AggregateAdmits`, `LengthClause`, `MeasuredValue`
use), the size forms (`hir/cardinality.tcl`'s `ListLength`,
`DefinedLength`, `TypedLength`), the proofs that read them
(`hir/completions.tcl`'s `IndexBounds`, `SizesOf`, `ReprValueVerdict`,
handler admission), the copy types (`hir/layouts.tcl`'s `CopyType`,
`CopiedFieldType`), the forgetting boundaries (`hir/semantic.tcl`,
`hir/imprint.tcl`, `hir/traits.tcl`, `hir/signatures.tcl`,
`hir/containers.tcl`), the validator (`hir/listlength.tcl`,
`core/listlength.tcl`, `listwithlen` in `native/src/nir.rs`,
`runtime/ops.rs`, `codegen/clif.rs`) or a `-result-length` / `-measures`
registration: run `tests/list-length-refinement.test`,
`audit/list-length-refinement/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/list-length-refinement/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule) and `cargo test --release --manifest-path native/Cargo.toml
--lib list_with_length`; plus `tests/decimal-rounded.test` and its fuzzer
and mutants for a change to the schema, `tests/fixed-arity-list-return.test`
for anything a warning reads, and the layout-arrays, layout-unions,
binary-layout, native-view and native-edit harnesses for a change to copy
types or extent proofs. `bench/list-length-refinement.tcl` regenerates the
performance report.
