# EQUALITY-SEMANTIC-CENSUS.md

A read-only semantic census of equality in Botlish, building on
[EQUALITY-SEMANTICS.md](../../docs/EQUALITY-SEMANTICS.md) (the first report:
type-blind `==`, the `ONE-CHAR-STRING-LITERAL` hazard, a proposed checked
equality). That report's direction stands: checked equality, with genuinely
dynamic equality kept. This census asks what such a rule should be checked
*against*, before anything is implemented. Nothing here changes the
compiler, the runtimes, the standard library or the language.

The evidence is in this directory (README.md lists the tools):

* `census/*.bot` and `census/methods/`: 101 probe programs, one question
  each, named by the investigation they serve (`i1-` to `i8-`).
* `census-probes.txt`: every probe's static verdict (`main.tcl -check`) and
  its outcome on interp, compile, cranelift and cranelift-generic
  (`tools/run.tcl`). Outcomes are `ok`, `static KIND`, `value V`,
  `runtime EQUALITY` or `runtime KIND`.
* `census-inspect.txt`: for the probes the report leans on, the inferred
  contracts, each `==` with its operand types and the candidate relations,
  each call's target and semantic instance, and each instance's view
  (`tools/inspect.tcl`).
* `census-results.txt`: `==` of Result values, which only core IR can build
  (`tools/results.tcl`).
* `reclassify/`: the corpus re-run (`tools/reclassify.tcl`) with the new
  relations and per-instance classes, and the policy tables built from it
  (`tools/policies.tcl`).

A probe is cited by its file name (`i1-lists`); its outcomes are in
`census-probes.txt` under that name.

## 1. Executive findings

The ten questions of the brief, answered in order. Sections 3 to 9 hold the
evidence.

1. **Which pairs of types `==` can meaningfully compare.** `==` first reads
   what this report calls a value's *head*:
   - its runtime kind;
   - for an enum, its declaration;
   - for a struct, its declaration or (anonymous) its field set.

   Different heads are always unequal. Equal heads compare their components:
   List elements, set members, struct fields, a Result's payload. Type
   arguments, integer domains and refinements play no part at run time
   (`i1-*`). Five properties that a "comparability" relation could mean turn
   out to be different relations (section 3):
   - value overlap;
   - equal heads;
   - componentwise ("structural") head compatibility;
   - totality;
   - static decidability.

   The census recommends **structural comparability**: equal heads at every
   component position the static types state. Integer domains and
   refinements are compatible with their carrier, `never` and `any`
   components are compatible with anything, and type arguments count only
   through the fields that use them.
2. **It cannot be defined both to accept every comparison that can be
   `true` and to protect the warning's respelling inside collections.**
   - `List[int] == List[str]` is `true` for two empty Lists (`i1-lists`).
     So are `ImmutableSet[int]` against `ImmutableSet[str]` (`i1-sets`) and
     `Bag[int] {items: []}` against `Bag[str] {items: []}` (`i1-applied`). A
     phantom slot makes `Tag[int] {n: 1} == Tag[str] {n: 1}` `true`
     (`i1-phantom`).
   - The value-overlap relation admits all of these. It then also admits
     `xs == ['-']` with `xs: List[str]`, which is the warning's hazard one
     level down (`i8-hazard-list`).
   - The structural relation rejects the empty-collection cases. Each of
     them is an emptiness test in disguise.
   - The language already judges equality by type in exactly this way, and
     rejects equal empty Lists:
     - `AFFINE-EQUALITY-UNSUPPORTED` rejects `List[Ptr] == []`
       (`i2-affine-list-empty`);
     - DecimalRounded's rule rejects `List[DecimalRounded] == []`
       (`i2-decimal-list`);
     - Hashable's checked admission rejects `hash` of an empty `List[Fn]`
       (`i2-hash-admission`).
   - Shared Result variants cannot be written in source. `ok`/`error` are
     core IR only, and `error("x") == error("x")` is `true` there
     (`census-results.txt`). The question waits for a sum type with
     payloads.
3. **Totality.** For a pair of static types, equality is:
   - **total** when neither operand can hold a refused value;
   - **undefined** (every comparison raises `EQUALITY`) only when an
     operand's *top-level* kind is refused: a callable, a MutableArray, a
     MutableVector, a coroutine handle, a C pointer, or a type-blind
     DecimalRounded;
   - **partial** for every composite that can hold a refused value.
     `[f] == []` is `false`, `[1, f] == [2, f]` is `false` and `[1, f] ==
     [1, f]` raises (`i2-list-callables`, `-reached`). Which comparisons
     raise depends on values and on comparison order, and the order is the
     field *name* order for an anonymous struct and the declaration order
     for a named one (`i2-struct-order` against `-reached`);
   - **unknown** otherwise.

   `hir::types::Totality`'s `none` means "not every value is total". That is
   right for Hashable, and overstated as "undefined" for a composite.
   Interp and native agree on every probe. The Tcl compiler disagrees on
   one: it answers `false` for `MutableVector == x` where the others raise
   (`i2-mutvec-top`, `i2-mutvec-list`; a fast path that refuses fewer kinds
   than the runtime, queued as a separate fix).
4. **Explicit `any`.**
   - Today a parameter declared `any` and an untyped one are identical to
     semantic instances, to specialization and at run time.
   - They differ in two places:
     - contract inference never strengthens a declared `any`;
     - the erasure audit treats a function with an `any` parameter as
       precondition-bearing (`i5-declared-any-bearing`, a quirk; fixed
       since: `hir::callables::Bearing` reads an entry type of `any` as no
       precondition, and the probe compiles and raises `EQUALITY` at run
       time like `i5-untyped-not-bearing`. TYPED-CALLABLE-ESCAPE-SOUNDNESS.md,
       "Chosen enforcement rule").
   - "Untyped parameters acquire obligations, declared `any` permits
     heterogeneous comparison" fits the model only if no semantic instance
     imposes an equality obligation, because instances see through a
     declared `any` (`i3-any-char`).
5. **Obligations on untyped parameters.**
   - `c == '-'` imposes a concrete obligation. As a contract it must be the
     *comparability class* of the other operand, not its static type. The
     comparison is meaningful for an Int beside a `Small`, and for a
     `List[Small]` beside a `List[int]`. Contract admission is subtyping,
     with invariant Lists: `List[Small]` is not admitted where `List[int]`
     is required (`i4-list-invariance`).
   - `a == b` imposes a relational obligation, which no contract can state
     (section 6).
   - A parameter compared with two kinds (`is_comma`) has no concrete
     contract at all. Only Strings, Ints, Lists, MutableArrays and Result
     tags have a kind test to separate the cases (`i4-kind-tolerant`).
6. **Ordinary inferred contracts are sufficient for the concrete case only,
   and only as CHECKED requirements of a kind-level type.**
   - Relational obligations need a new abstraction. The one relational
     mechanism the language has, imprint variables, comes only from declared
     applied types.
   - Contract inference copies such variables unbound into a forwarder's
     contract, which then rejects every call (`i4-imprint-forwarder`,
     `i4-imprint-forwarder-box`: an existing defect, queued as a separate
     fix).
7. **Callable conversion.**
   - CHECKED contracts never survive conversion to an `Fn` type. That holds
     today for every checked contract: a `str` function stored as `Fn{args:
     [int]}` and called with 5 fails at run time with `TYPE`
     (`i5-checked-erasure`). TRUSTED ones do survive (`i5-trusted-preserved`).
   - An equality-checked contract would be lost the same way, with no
     run-time backstop. The comparison is silently `false`, not a run-time
     error.
   - Exact callable identity survives local bindings, untyped and declared
     `Fn` parameters (through instances), returns, List elements and
     anonymous struct fields (`i5-*`). It is lost through a named struct's
     `Fn` field, a declared `any` position, or a declined instance.
8. **Instance independence.** Equality admissibility can be enforced
   independently of semantic instances only if it is not enforced *in* them.
   - The existing instance checks already make validity depend on budgets
     and on source order. The same invalid call (`apply(big, "a")`, with
     `big(n): n > 5`) is a static `TYPE` error when it is the first of 17
     instances of `apply`. As the 17th it is a run-time `TYPE` error
     (`i6-budget-checked-first`, `-last`).
   - An instance-only equality rule would do the same, and fall back to a
     silent `false` (`i6-budget-equality-first`, `-last`).
   - The existing type-level rules take one of two routes:
     - Hashable admission and the DecimalRounded rule run on the generic HIR
       only;
     - the affine rule forces an instance past every budget.
9. **Collections.** Four questions are distinct:
   - comparing two collections (equality of composite values);
   - a needle against an element type (membership);
   - a key against a key type (lookup);
   - Hashable (totality of every value of a type).

   MutableSet and MutableMap already answer membership and lookup by
   subtype admission of a declared `T`/`K` parameter (`i7-mutable-set-needle`,
   `-domain`, `i7-mutable-map-key`). That is stricter than any equality
   relation, and it rejects `12` for a `MutableSet[Small]`. So membership
   cannot follow from comparability. Whether `ImmutableSet.contains` should
   move to that admission is a policy decision of its own. DecimalRounded
   keeps its own operator. Its type-level rule runs on the generic HIR and
   is bypassed through an untyped function, which fails at run time
   (`i2-decimal-instance`).
10. **The smallest sound next milestone** (section 12) is a static check of
    `==`, `!=` and `std::immutable_set::contains`:
    - **structural comparability**, checked only where both operands' static
      types fix their heads;
    - in the generic HIR only;
    - with no new inference and no instance check;
    - with a refusal of top-level kinds that have no equality.

    It delivers the warning's respelling guarantee wherever the compiler
    knows the operand's type, and it changes no inferred contract, no method
    decision and no callable behaviour. Each later step stays a separate
    decision, and the check forecloses none of them:
    - concrete CHECKED contracts (section 6);
    - a conversion check for callables (section 7);
    - relational obligations.

## 2. Existing equality semantics and compiler representation

### 2.1 The operation

`a == b` is a call of the root native `==` (core/primitives.tcl: `-param-types
{any any} -runtime structural-equality -ownership {equality equality}`);
`a != b` lowers to `if a == b: false else: true`. `core::value::equal`
(core/value.tcl) and native/src/runtime/ops.rs's `equal` implement it, in the
same order:

1. **Refusal**: if *either* top-level operand's kind is in
   `core::value::incomparable` (`block native mutarray coroutine mutvec cptr
   DecimalRounded`), raise `EQUALITY`. This runs before kinds are compared:
   `[f] == [1]` raises, because the first element pair is a callable and an
   Int (`i2-list-callables-first`); `s.contains(1)` raises for a set holding
   a callable (`i2-sets-contains`).
2. **Kinds**: different kinds are `false`.
3. **Within a kind**:
   - Lists compare lengths, then elements in order, stopping at the first
     unequal pair.
   - Results compare the tag, then the payload (`&&`).
   - Structs compare the shape (one interned shape index natively), then
     the fields in slot order: declaration order for a named struct, sorted
     field names for an anonymous one.
   - Sets compare cardinalities, then search each member of the first
     operand in the second.
   - Scalars, enum words and bytes compare by value.

Everything `==` reads is the kind, the declaration, the field names, the
lengths and the values. No type argument, integer domain, refinement or
static type reaches it.

### 2.2 The static side

* **One meaning, chosen once.** `hir::operators::resolve` leaves `==` as the
  one equality for every kind, except that a DecimalRounded operand selects
  `DecimalRounded#==` (hir/decimal.tcl). The choice is made in the generic
  walk and never revisited: "a semantic instance ... see[s] the rewritten
  call and never choose[s] again" (hir/operators.tcl, header). So two
  DecimalRounded values reaching `==` through an untyped function meet the
  type-blind equality, which refuses them at run time
  (`i2-decimal-instance`).
* **No obligation.** `==`'s parameters are `any`, so contract inference
  records an equality operand as a `flow` sink, which imposes nothing. For a
  parameter that is also called, it counts as an escape (hir/signatures.tcl,
  `Use`). `fn hyphen?(c): c == '-'` has no contract (`census-inspect.txt`,
  `i3-untyped-char`).
* **Totality chooses lowering.** `hir::types::Totality equality T` is `total`,
  `none` or `unknown`. Native lowering reads it for `veqtotal` (no error
  edge), and per-kind operations replace both for scalar pairs: `ieq`,
  `streq`, `chareq`, `enumeq`, `f64eq` (native/lower.tcl, `NativeCallOp`).
  It never rejects a comparison.
* **Exact values decide nothing.** `hir::exact` decides `==` only for two
  exact values of one kind. `"-" == '-'` has no `known` outcome
  (hir/exactvalue.tcl).
* **Range facts.** `x == 3` narrows an Int-range operand to `{3}` in the true
  branch (`hir::range::ExactEqualityNarrowing`). That is sound only because
  values of different kinds are never equal. Equality is no kind test for
  contract inference, though: `if v == 3: f(v)` with `f(x: Small)` still
  gives `v` the contract `int[Small]`, so `g("3")` is rejected statically,
  although the guarded call could never run with it (`i3-equality-narrows`).

### 2.3 Static rules that already reject `==` by type

The first report treated `==` as having no static rule. That holds for
operands of plain types, but four existing rules reject comparisons. Each
judges *types*, for every value, including values that would compare fine:

| rule | where | what it rejects | runs in instances? | probes |
|---|---|---|---|---|
| `AFFINE-EQUALITY-UNSUPPORTED` | hir/affine.tcl, from `-ownership {equality ...}` | `==` (and `hash`) of any affine type: a coroutine handle, a C pointer, a List or struct owning one -- the empty `List[Ptr]` included | yes: an affine argument always gets its instance, past every budget (hir/semantic.tcl, `Call`) | `i2-coroutine`, `i2-cptr`, `i2-affine-list-empty`, `i2-affine-instance` |
| DecimalRounded `TYPE` | `hir::decimal::verify` | `==` of a type that holds DecimalRounded values without being one (`List[DecimalRounded]`, a struct field), empty Lists included | no: generic HIR only | `i2-decimal-list`, `i2-decimal-instance`, `i2-decimal-list-instance` |
| typed-callable erasure (`TYPE`, "cannot be preserved") | hir/callables.tcl | passing a precondition-bearing value (a typed callable, an `Fn` type with a non-`any` argument, a List or struct of one) to `==`'s `any` parameter | yes (instance verification runs the erasure audit) | `i2-typed-callable-erasure`, `i2-typed-callable-list-empty`, `i2-named-order` |
| Hashable checked admission (`TRAIT-NOT-SATISFIED`) | `hir::range::VerifyHashing` (`-hashing {0 checked}`) | `hash` of a statically non-Hashable type -- an empty `List[Fn]` included | no: skipped in a semantic context | `i2-hash-admission`, `i7-hash-generic-callable` |

So the remaining run-time refusals are values the static types do not
expose. These are:

- untyped callables (`i5-untyped-not-bearing`);
- MutableArrays and MutableVectors (`i2-mutarray-top`);
- whatever reaches `==` as `any`.

The language reference states the intent more strongly than the
implementation: "Equality on callables is not defined ... Comparing
callables makes the program invalid" (docs/README.md, section 1).

### 2.4 Backend agreement

The three implementations reach `==` by different paths:

* the interpreter always calls `core::value::equal`;
* the Tcl compiler inlines Int, Bool, String and unit comparisons, and
  folds two known, different kinds to the constant `false`
  (`IntrinsicValueEqual`);
* native lowering chooses `ieq`, `streq`, `chareq`, `enumeq` or `f64eq`
  for two operands of one scalar kind, `veqtotal` (the runtime helper with
  no error edge) for two equality-total types, and `veq` otherwise.

All three choose by the static types of the program being compiled. None
of them changes an answer.

99 of the 101 probes have one outcome on all four backends: 30 static
diagnostics, 57 values, 12 run-time `EQUALITY` and 2 other run-time errors,
per the interpreter. Interp, cranelift and cranelift-generic agree on every
probe. The Tcl compiler differs on `i2-mutvec-top` and `i2-mutvec-list`. Its `IntrinsicValueEqual`
(compiler/compiler.tcl) compiles operands of two known, different kinds to
`false`. It skips that only for `{block native mutarray}`, not for the
runtime's whole `incomparable` list. So `MutableVector == 1` is `false`
there and `EQUALITY` elsewhere. This is a backend bug, not a semantic
question, and it is queued as a separate task. Coroutines and pointers are
affine and rejected statically, and DecimalRounded selects its own operator,
so MutableVector is the only kind that reaches it.

## 3. Static compatibility versus value overlap

### 3.1 Five properties

For static types A and B:

* **Value overlap**: some value of A equals some value of B under `==`
  without raising.
* **Head equality**: every value of A and every value of B have the same
  head (kind; enum declaration; struct declaration or field set). When the
  heads differ, `==` is `false` for every pair, before any component is
  read.
* **Structural compatibility**: the heads are equal, and so is every
  component position's pair (List elements, set members, struct fields
  after substituting type arguments), recursively. Integer domains and
  refinements are compatible with their carrier, and a `never` or unknown
  component is compatible with anything.
* **Totality**: no pair of values raises `EQUALITY` (section 4).
* **Static decidability**: the static types fix the answer for every pair,
  either always `false` (disjoint heads) or always refused.

The probes separate them:

| pair (probe) | overlap | heads | structural | total | run-time results |
|---|---|---|---|---|---|
| `str` vs `UnicodeChar` (`i1-primitives`) | no | differ | incompatible | yes | always `false` |
| `Color` vs `Light`, same case names (`i1-enums`) | no | differ | incompatible | yes | always `false` |
| `P` vs `Q`, same fields; `P` vs `{x: int}` (`i1-structs`) | no | differ | incompatible | yes | always `false` |
| `{x: int}` vs `{x: str}` (`i1-structs`) | no | equal | incompatible | yes | always `false` |
| `List[int]` vs `List[str]` (`i1-lists`) | yes (`[]`) | equal | incompatible | yes | `true` for `[]`, else `false` |
| `List[List[int]]` vs `List[List[str]]` (`i1-lists`) | yes (`[]`, `[[]]`) | equal | incompatible | yes | `[[]] == [[]]` is `true` |
| `{items: List[int]}` vs `{items: List[str]}` (`i1-nested`) | yes | equal | incompatible | yes | `true` when both are empty |
| `ImmutableSet[int]` vs `ImmutableSet[str]` (`i1-sets`) | yes | equal | incompatible | yes | `true` when both are empty |
| `Box[int]` vs `Box[str]`, `value: T` (`i1-applied`) | no | equal | incompatible | yes | always `false` |
| `Bag[int]` vs `Bag[str]`, `items: List[T]` (`i1-applied`) | yes | equal | incompatible | yes | `true` when both are empty |
| `Tag[int]` vs `Tag[str]`, a slot no field names (`i1-phantom`) | yes | equal | compatible | yes | `true` when `n` is equal |
| `Small` vs `Big`, disjoint domains (`i1-domains`) | no | equal | compatible | yes | always `false` |
| `Word` vs `Tag`, two refinements of `str` (`i1-refinement`) | yes | equal | compatible | yes | by value |
| Lists of an untyped callable, against each other (`i2-list-callables`) | yes | equal | compatible | no | `[f] == []` is `false`; some pairs raise |

The pairs on which the five disagree are the reason the relation has to be
chosen rather than discovered.

### 3.2 What the run-time answer depends on

* **Runtime kinds**: always, first (after the refusal).
* **Declarations**: an enum's and a named struct's identity, never their
  spelling (`i1-enums`, `i1-structs`). An application of a parameterized
  struct has its constructor's one shape whatever the arguments
  (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md, "No runtime existence"). So
  `Tag[int]` and `Tag[str]` values can be equal (`i1-phantom`).
* **Field structure**: an anonymous struct's field *set* (`{x: 1} == {x:
  1, y: 2}` is `false`), never the order the fields are written in (`{x: 1,
  y: "a"} == {y: "a", x: 1}` is `true`, `i1-structs`).
* **Actual values**:
  - List lengths and elements;
  - set cardinality and members;
  - field values;
  - for Results (core IR only), tags and payloads (`census-results.txt`:
    `ok(1) == error(1)` is `false`, `error("x") == error("x")` is `true`,
    `ok(1) == ok("1")` is `false`).
* **Never**:
  - type arguments;
  - integer domains (`sm(7, 7)` is `true` for `Small` and `Mid`;
    `sb(3, 150)` is `false` because 3 is not 150, not because the domains
    are disjoint);
  - refinements (`i1-refinement`: a `Word` equals a `Tag` and a `str` of
    the same text);
  - List length refinements;
  - any other static type.

### 3.3 The candidate relations

`tools/lib.tcl` implements five relations over the checker's types:

| relation | definition |
|---|---|
| `Head` | the runtime kinds and, for enums and structs, the declarations or field sets |
| `Overlap` | value overlap (list length refinements and integer domains included) |
| `Structural` | 3.1's structural compatibility |
| `Kinded` | the first report's census relation, which rejects disjoint element types as `empty-only` and disjoint type arguments as `disjoint` |
| `Related` | the checker's own `subtype`/`glb` |

`census-inspect.txt` prints all of them for every site of the probes above.
Three observations:

* **The checker's lattice has no answer.** `hir::types::glb` of `List[int]`
  and `List[str]` is "none", and their `lub` is the bare kind `list`.
  `List[never]` is a subtype of both, but glb is computed by admissibility,
  so it is not their meet. Subtyping is not comparability. `"a"` and `'a'`
  are as unrelated as `List[int]` and `List[str]`. So the relation equality
  needs is not one the type system already computes.
* **The first report's relation mixes two rules.**
  - It rejects `List[int]` vs `List[str]` (structural).
  - It also rejects `Tag[int]` vs `Tag[str]` by type arguments, and two
    disjoint integer domains (`disjoint-domain`) by value.

  Both of those can be or are value-level facts, the first of them a
  comparison that can be `true`.
* **Phantom slots exist.** `struct Tag[T]: n: int` is accepted
  (`i1-phantom`). A relation by type arguments therefore rejects
  comparisons that can be `true` for a reason no value carries. A relation
  by substituted fields does not.

### 3.4 What each relation means as a checked rule

* **Head rule** (reject differing heads). This is the weakest rule and the
  only one whose every rejection is a constant `false`. It misses every
  hazard below the top level: `xs == ['-']` with `xs: List[str]`
  (`i8-hazard-list`), and `{c: s} == {c: '-'}` with `s: str`
  (`i8-hazard-struct`).
* **Overlap rule** (reject pairs with no equal value pair). Every rejection
  is again a constant result. It agrees with the head rule on Lists and
  sets, because every two List types overlap at `[]`, so it misses the same
  List hazard. It catches the anonymous-struct hazard
  (`{x: str}` vs `{x: UnicodeChar}` has no equal pair) and disjoint
  integer domains.
* **Structural rule** (reject incompatible component positions). This rule
  catches both hazards. It rejects comparisons that can be `true`: equal
  empty collections, at any depth.
  - Each such comparison is equivalent to an emptiness test on both sides
    (`std::list::length(xs) == 0`).
  - The language already rejects by type in the same way:
    `AFFINE-EQUALITY-UNSUPPORTED` rejects `List[Ptr] == []`, the
    DecimalRounded rule `List[DecimalRounded] == []`, Hashable admission
    `hash` of an empty `List[Fn]`, and `ImmutableSet[Ptr]` is not even a
    type (section 2.3).
  - Rejecting `List[int] == List[str]` is consistent with how Botlish
    already reasons about equality. It is not a new kind of strictness.
* **Kinded rule** (the first report). This is the structural rule plus
  type-argument and domain disjointness. Section 3.3 explains why those two
  additions should be dropped.

**Recommendation.** Define comparability as structural compatibility. It is
the one relation under which the warning's respelling is either a
rejection or a no-op at every depth where the types are known. Its
rejections that are not constant results are the empty-collection cases.
The corpus has one such site, lists-and-sets.bot:472, a test that pins
today's semantics (section 10.2). Shared sum-type variants cannot be written
in source today (Result is core IR only, enums carry no payload). A future
payload-carrying sum type would face the same choice, by variant: payload
positions compatible, or overlap. Structural compatibility there means the
`error` variant of `Result[int, str]` and of `Result[UnicodeChar, str]`
would not be compared, even though they can be equal.

## 4. Partial and undefined equality

### 4.1 By pair of static types

| pair | class | why | probes |
|---|---|---|---|
| two total types (scalars, enums, and Lists, sets and structs of them) | total | nothing refused is reachable | `i1-*` |
| a top-level callable, MutableArray, MutableVector (untyped or bare) | undefined | refused before anything is compared | `i5-untyped-not-bearing`, `i2-mutarray-top`, `i2-mutvec-top` |
| a coroutine handle, a C pointer (affine) | undefined, and rejected statically | `AFFINE-EQUALITY-UNSUPPORTED` | `i2-coroutine`, `i2-cptr` |
| a typed callable, or a List or struct of one | undefined or partial, and rejected statically | erasure audit | `i2-typed-callable-*` |
| a List or set that can hold an untyped callable | partial | `[f] == []` false, `[1, f] == [2, f]` false, `[1, f] == [1, f]` raises | `i2-list-callables`, `-reached`, `-first` |
| a struct holding an untyped callable | partial, decided by field order | `{a: 1, h: f} == {a: 2, h: f}` false; `{z: 1, h: f} == {z: 2, h: f}` raises (`h` sorts before `z`) | `i2-struct-order`, `-reached`, `i2-list-struct-callable` |
| a set holding a callable | partial | cardinality first: `s == from_list([])` false; membership of an Int raises; building a set of two callables raises | `i2-sets`, `-contains`, `-build` |
| a Result with a callable payload (core IR) | partial | tag first: `ok(f) == error(1)` false, `ok(f) == ok(f)` raises | `census-results.txt` |
| two different heads, whatever they hold | total | `false` before components: `[f] == 1` is false | section 2.1 |
| `List[DecimalRounded]` vs itself | partial at run time, and rejected statically | DecimalRounded rule | `i2-decimal-list` |
| an operand of no fixed kind | unknown | | `i3-*` |

Two refinements:

* **Definedness is per pair, not per type.** `List[Fn]` against `int` is
  total, because different heads are compared first.
* **Partial equality depends on the values and on the comparison order.**
  The order is fixed by the implementation in both runtimes, and the two
  agree on every probe. But only the general shape is documented as language
  semantics: "a shape mismatch is unequal without comparing any contents,
  exactly as List's length mismatch is" (STRUCTS.md, core::value::equal's
  comment). That the first unequal pair stops the walk, and that an
  anonymous struct's slots are its sorted names, is the current lowering.
  A rule should not rely on it.

### 4.2 `hir::types::Totality`

* **`total` is accurate**: two values of total types never raise.
* **`none` is accurate for a top-level refused kind.** For a composite it
  means "some value of this type is not total": `List[Fn]` is `none` though
  its empty value compares and hashes. That is the right answer for its
  real clients:
  - Hashable (every value);
  - `veqtotal` and `setcontainstotal` (an error edge is needed if *any*
    value refuses).

  As an "undefined" classification for equality admissibility it would
  over-reject.
* **DecimalRounded is `none`.** That holds only for the type-blind
  operation: two statically DecimalRounded operands use the precise
  operator and compare (`i7-decimal-precision`).
* **`unknown` is conservative and correct** (`any`, imprint variables
  without a guaranteeing constraint, trait views, bare kinds). It also
  covers an opaque struct whose representation field is `any`:
  `std::abi::bytes::Bytes` and `MutableBytes` (`storage: any`) are unknown
  to Totality, although every Bytes value compares, so `==` of two Bytes
  keeps the generic `veq`.

`eqcensus::Defined` (lib.tcl) gives the per-pair classes of 4.1.

### 4.3 What a rule may reject

Rejecting every pair for which *some* value raises would reject:

* `[f] == []`, an emptiness test of a List of callables;
* every struct that holds an untyped callable field, which `==` compares
  by its other fields today;
* every composite holding a MutableArray.

That is Hashable's rule ("every value"). For `hash` it is right, because a
hash must exist for every member of a table. For `==` it would make partial
equality a type error. The existing composite operations (`from_list`,
`contains`, struct and List equality) are deliberately dynamic here.
`setfromlist` and `setcontains` keep an error edge for exactly this case.

The census recommends a narrower rule:

* reject statically only a pair whose class is **undefined**, a top-level
  refused kind;
* leave **partial** pairs dynamic.

The new rejection is then exactly what the reference already says:
"Comparing callables makes the program invalid". For typed callables the
erasure audit already rejects them. The rule adds untyped callables,
MutableArrays and MutableVectors of statically known kind.

`EQUALITY` and `false` stay distinct outcomes. A rejected comparison of
disjoint heads replaces a constant `false`, and a rejected undefined pair
replaces a certain `EQUALITY`.

## 5. Dynamic `any` and untyped-parameter semantics

### 5.1 The operand origins

| origin | in HIR | contract inference | semantic instance | specialization | erasure audit | probes |
|---|---|---|---|---|---|---|
| declared `any` parameter | `declaredParamTypes` holds `any`; entry type `any` | never inferred (declared) | sees through it: the instance's entry type is the argument's | adopts the argument type (narrow of `any`) | **bearing** on the census's tree: the function cannot be erased (`char? == char?` is a static `TYPE`); not bearing since (item 4) | `i3-any-char`, `i3-any-same`, `i5-declared-any-bearing` |
| untyped parameter, no contract | `declaredParamTypes` `{}`; no inferred types | inferred from uses; `==` imposes nothing | sees through it | adopts the argument type | not bearing | `i3-untyped-char`, `i5-untyped-not-bearing` |
| untyped parameter with a CHECKED contract | `checkedParamTypes` | from a native's `-param-types`, an `if`, a loop | held to the contract per call (known argument types only) | | not bearing | `i3-checked-then-compared`, `i4-checked-native` |
| narrowed by a kind test | the use's type is the kind | uses under the test constrain nothing | | | | `i3-kind-test`, `i4-branch` |
| unknown kind from another operation | `any` | nothing | an instance may know more | | | `i3-computed` |
| constrained imprint variable | `{imprint K TRAITS}` | from declared applications only | none needed: K is K | keyed by the variables a source trait constrains | | `i3-imprint`, `i3-imprint-mismatch` |

Findings:

* **Declared `any` and untyped are one thing to everything after typing.**
  The difference lives in two places only:
  - `declaredParamTypes` (inference never strengthens a declaration);
  - `hir::callables::Bearing` (an `any` declaration counts as "typed").

  The second contradicts the audit's own rationale (an `any` parameter
  imposes no precondition) and is worth fixing on its own.
* **Specialization does not distinguish them** (hir/specialize.tcl enters
  an untyped parameter with the instance's argument type, and narrows a
  declared `any` to it). Neither does native lowering:
  `veqtotal` in an instance of `same?(a: any, b: any)` called with a String
  and a character (`census-inspect.txt`).
* **Equality is no kind test.** `if v == '-'` does not make `v` a character
  for contract inference (`i3-equality-narrows-char`). `if v == 3` narrows
  an Int range but still imposes the guarded use on the whole parameter
  (`i3-equality-narrows`).
* **Imprint variables are relational by construction.** One variable
  imprinted by two argument types is a static `IMPRINT` error
  (`i3-imprint-mismatch`). Two variables are independent and compare
  dynamically (`i3-imprint`'s `cross?`).

### 5.2 The proposed policy

"Untyped parameters can acquire equality obligations through inference,
while explicitly declared `any` permits intentional heterogeneous
comparison."

* **It fits the language.** A declaration is never strengthened by
  inference today: a declared parameter keeps its type, inferred contracts
  apply to `{}` slots only. `any` is the existing spelling of "every value,
  on purpose" (`register_equality(name, left: any, right: any, expected)` in
  core-semantics.bot is exactly that).
* **It conflicts with semantic instances.** An instance enters a declared
  `any` parameter with the argument's type. An instance-level equality check
  would reject `register_equality(..., 1, "1", false)` (the first report's 4
  instance-disjoint sites include it). The policy is coherent only if
  equality obligations come from the generic body and its contracts, never
  from instances. Section 8 reaches the same conclusion on independent
  grounds.
* **It needs the Bearing quirk fixed first.** Otherwise declaring `any` to
  say "dynamic" would make a function unstorable in untyped positions,
  which would make `any` an awkward opt-in.

### 5.3 The existing dynamic users

* **`std::test::equal(expected, actual)`**: `actual == expected` of two
  untyped parameters, which is a relational site. Its callers pass every
  kind, and cross-kind mismatches are legitimate test failures
  (`i3-test-equal`: `equal("1", 1).matched` is `false`). It is the canonical
  case for "declared `any`": under the policy it would declare
  `expected: any, actual: any`.
* **`std::test::describe`**: its `v == true` and `v == false` are a Bool kind
  test written as equality, because there is no `bool?`. `v` is the `any`
  field of an `Erased` struct (a computed `any`), so no policy that leaves
  computed `any` alone touches it. A real kind test for Bool (and
  UnicodeChar, Float64) would remove the idiom.
* **`std::ordered_table`'s `t.key_at(e) == key`**: `K` against `K` of a
  `Table[K]` whose slot is `K satisfies Hashable`. It is total (the
  constraint guarantees it) and comparable by construction (one variable).
  A relation over kinds sees two unknowns. A structural relation should
  treat two occurrences of one imprint variable as compatible, and two
  different variables as unknown.
* **MutableArray tables** (`csv_records`, `hashtable` examples):
  `MutableArray[any]` elements compared with Strings, which are computed
  `any` operands.

## 6. Equality obligations and contract inference

### 6.1 The machinery

Contract inference (hir/signatures.tcl; INTRINSIC-FUNCTION-CONTRACT-
INFERENCE.md) walks every reachable use of an untyped parameter and records
a requirement where the use's position has a known admissibility type:

* a native's `-param-types` (CHECKED);
* a declared parameter, a declared result or a structural `Fn` argument
  (TRUSTED);
* an `if` condition and loop domains (CHECKED);
* an untyped callee's contract (an edge, solved to a fixed point).

Requirements combine by `glb`, and no meet is a static `TYPE` conflict.
Uses under a kind test of the parameter are skipped. A CHECKED contract:

* rejects a call whose argument is of a *known* type that is not
  admissible, with the provenance chain ("inferred from the function body:
  argument 1 of native std::str::length requires str (at 4:22)",
  `i4-checked-native`);
* admits an `any` argument, which reaches the operation's run-time check;
* is never seeded into the body;
* never enters a structural `Fn` type.

### 6.2 The concrete case

`fn hyphen?(c): c == '-'` would get the CHECKED contract `UnicodeChar`. The
machinery represents that directly (`ArgSinks` would give `==` a sink the
other operand's type supplies), and a caller passing a String would be
rejected at its call with the chain. Three limits:

* **The contract must be the other operand's comparability class, not its
  type.**
  - With `x: Small`, `n == x` means "an Int"; the contract `int[Small]`
    would reject every unproven Int argument. That is the domain
    forwarder's behaviour (`i4-domain-contract`), right for a call of
    `f(x: Small)` and wrong for a comparison.
  - With `xs == [1, 2]`, the contract `List[int]` would reject `List[Small]`
    arguments, because List admission is invariant (`i4-list-invariance`).

  Contract admission is subtyping (`ProvesValueAcceptedBy`), a directed
  relation with range proofs. Comparability is symmetric and ignores
  domains. So the contract must be widened to a kind-level type: for
  scalars the carrier (`int`, `str`, `UnicodeChar`, an enum, a named
  struct), for collections at most the kind (`list`). Precision below the
  kind would need a new admission predicate, "comparable with", in place of
  subtyping.
* **Kind tolerance becomes a conflict.** `is_comma(c): c == ',' or c ==
  ","` would get `UnicodeChar` and `str`, which have no meet. That is a
  compile-time TYPE error under today's rule for incompatible requirements
  (`i4-kind-tolerant` today returns `true` for both). The repair is a kind
  test, and one exists for Strings (`string?`) but not for UnicodeChar,
  Bool, Float64, enums or structs (core/predicates.tcl: `integer?`,
  `string?`, `list?`, `mutarray?`, `ok?`, `error?`).
* **It reverses a recorded decision.** `ic-unconstrained-stays-any`
  (tests/intrinsic-contracts.test and range-and-contract-values.bot) pins
  `eq_x?(1)` as accepted (`i4-unconstrained-pinned`).

### 6.3 The relational case

`fn same?(a, b): a == b` needs "the types of `a` and `b` are comparable".

* **No contract states it.** Contracts are constant types per parameter,
  combined by `glb`. There is no type variable in a contract, and the
  design forbids function-side generics (AGENTS.md: no `fn f[T]`, no
  constraint on a function).
* **Imprint variables are the one relational mechanism.** They come only
  from *declared* applied types (`a: Box[T], b: Box[T]`, `i3-imprint`).
* **Inference mishandles them.** It copies the callee's declared `Box[T]`
  into an untyped forwarder's contract without binding `T`, and every call
  of the forwarder is then rejected: "Box[int] and Box[T] are distinct
  applications (T is int, not T)" (`i4-imprint-forwarder-box`, and with the
  standard library's `MutableSet[T]`, `i4-imprint-forwarder`). This is an
  existing defect, independent of equality, and is queued separately. It
  shows that even the existing relational information does not survive
  inference.
* **Today only instances see relational comparisons.**
  `same?("-", '-')` has an instance with `str` vs `UnicodeChar`
  (`i3-untyped-same`). `pair?(x): same?(x, '-')` reaches the comparison
  through two functions: its instance chain has the types, its contracts do
  not (`i4-relational-forward`). Equal empty Lists of different element
  types pass through `same?` as `true` (`i4-same-list-generic`).

Relational obligations therefore need a new abstraction: a requirement
between parameters, carried across calls and checked when the argument
types are known. It is not an extension of the existing contract lattice.

### 6.4 Other consumers of inferred contracts

* **Method applicability.** `hir::methods::ParamKinds` reads declared,
  trusted and checked first-parameter contracts. With two visible `mark?`
  functions, one comparing its receiver with a character
  (`methods/m1.bot`) and one with a checked `str` contract
  (`methods/m2.bot`):
  - today a String receiver is `AMBIGUOUS-METHOD-CALL`
    (`methods/ambiguous`);
  - a character receiver is decided (`methods/decided`);
  - a String receiver with m1 alone runs and is `false` (`methods/only-m1`).

  A concrete equality contract on m1 would:
  - make the ambiguous call decided (m2);
  - make `only-m1` `NO-APPLICABLE-METHOD`;
  - leave `decided` as it is.

  The effect is monotone. A contract only removes applicability, so a
  decided call stays decided or becomes a rejection, and an ambiguous one
  may become decided. A program accepted today therefore keeps every
  decision or is rejected: no call can silently switch candidates. Only a
  program rejected today (an ambiguity) can become accepted. It still
  moves decisions, and the method-resolution reference audit and harnesses
  would have to accept it.
* **Static decisions.** An untyped parameter's contract is already a
  backward channel of the static-decision dependency analysis (B:p to R of
  every use, hir/staticdeps.tcl). Equality uses would be new uses in that
  channel, not a new channel. The batched-against-sequential comparison is
  still required (CI's `static-decisions` workflow).
* **Not affected**:
  - `MANY-BOOLEAN-ARGUMENTS` reads trusted contracts only;
  - the erasure audit (`Bearing`) reads trusted contracts only;
  - the semantic-instance key reads declared and trusted entry types.

### 6.5 Verdict

A first implementation does not need inference at all (section 12). If
inference is added, the concrete case fits the existing machinery under
three conditions:

1. a CHECKED requirement;
2. of the kind-level comparability class;
3. with the kind-tolerance conflict and the recorded decision revisited.

The relational case does not fit. Inferring concrete contracts would cover
the 361 sites where an untyped parameter meets an operand of fixed kind
(section 10.3), not the 34 sites whose operands are both unknown.

## 7. Callable-value boundaries

### 7.1 Where identity survives

| route (probe) | call target | instance of `hyphen?` | today |
|---|---|---|---|
| local binding `f = hyphen?; f("-")` (`i5-local`) | `hyphen?` | yes | `false` |
| untyped parameter `apply(hyphen?, "-")` (`i5-param`) | through `apply`'s instance | yes | `false` |
| declared `Fn{args: [str], ...}` parameter (`i5-declared-fn`) | none in the generic body; `hyphen?` in `apply`'s instance | yes | `false` |
| returned `pick()("-")` (`i5-returned`) | `hyphen?` | yes | `false` |
| List element `std::list::at(fs, 0)("-")` (`i5-list`, `i5-untargeted`) | `hyphen?` | yes | `false` |
| anonymous struct field `s.f("-")` (`i5-struct`) | `hyphen?` | yes | `false` |
| named struct's `Fn` field `h.f("-")` (`i5-equality-erasure`) | none | no | `false` |
| an `any` field read back (`i5-any-erased`) | none | no | `false` |
| an instance past the budget (`i6-budget-*-last`) | the call keeps its generic typing | no | |

### 7.2 What survives with it

* **TRUSTED contracts are part of the exact callable's structural
  contract.** Converting `g(n): f(n)`, with `f(x: Small)`, to `Fn{args:
  [int], ...}` is rejected statically, at the conversion
  (`i5-trusted-preserved`).
* **CHECKED contracts are not.** `len1?(s): std::str::length(s) == 1`
  converts to `Fn{args: [int], ...}`, and `h.f(5)` fails at run time with
  `std::str::length`'s `TYPE` (`i5-checked-erasure`), where a direct
  `len1?(5)` is rejected statically (`i5-direct-checked`). The erasure has a
  backstop: the native's own check.
* **An equality contract would have no backstop.** Erased the same way, it
  would turn the call through `Fn{args: [str]}` into the silent `false` the
  contract exists to prevent. So a concrete equality contract is weaker
  than every existing CHECKED contract in exactly the case the warning
  cares about.

### 7.3 The options

* **Preserve checked requirements in `Fn` types.** Making a checked
  contract part of the structural contract makes it, in effect, trusted:
  - every caller through the `Fn` type must then prove it;
  - an `any` argument no longer passes;
  - the body may assume it.

  That is the generics problem the contract-inference milestone avoided
  ("Checked requirements accept any arguments", its known limitations). It
  would reject today's dynamic programs.
* **Retain identity where statically possible.** That already happens
  (7.1), through instances. It is inherently partial: budgets and
  declared-`Fn` storage lose it.
* **An explicit dynamic boundary at erasure.** The conversion point knows
  the callable's checked contract and the target `Fn` type's argument
  types. A rule "an `Fn` argument type of a *known* kind that is
  incompatible with the callable's checked contract is a static error at
  the conversion" mirrors exactly what a CHECKED contract does at a direct
  call:
  - `H {f: hyphen?}` with `f: Fn{args: [str]}` would be rejected;
  - `Fn{args: [any]}` would stay a dynamic boundary.

  It would need no new representation: a check in `hir::types::subtype`'s
  callable case, or in the erasure audit, against `checkedParamTypes`. It
  would also close today's `i5-checked-erasure` gap for native-derived
  contracts.
* **Reject conversions that erase required guarantees.** As a blanket rule
  this would forbid storing any checked-contract function in any `Fn`
  position, most of the corpus's predicates (`scan_while`'s, the list
  helpers'). It is too strong.

With the existing representation, the realistic guarantee is:

* exact identity where the program keeps it;
* a conversion check against known incompatibility (the third option);
* dynamic semantics through `any` and through `Fn{args: [any]}`.

A concrete equality contract should not be added before the conversion
check exists. Without it, the contract protects direct calls and loses
exactly the calls the warning's hazard reaches through a stored predicate.

## 8. Semantic-instance and budget independence

### 8.1 What instances verify

An instance is created for an exact, reachable call whose argument types
are more precise than the target's entry types (hir/semantic.tcl). It is
created only within budgets:

* 16 per block;
* 2,000 in all;
* a nesting limit.

A call beyond the budgets is *declined* and keeps its generic typing.
Verification runs on each used instance:

* `hir::range::verifyBlocks` (typed-call admissibility, including CHECKED
  contracts);
* `hir::callables::verifyBlocks` (erasure);
* struct and layout checks;
* for affine arguments, `hir::affine::verifyInstance`.

A diagnostic there is reported at the call that needed the instance. Not
run in instances:

* `hir::decimal::verify`;
* `hir::range::VerifyHashing`;
* any equality check.

### 8.2 Validity already depends on instances

`i6-budget-checked-first` and `-last` are the same program with the
offending line moved. `apply(big, "a")`, with `apply(g, x): g(x)` and
`big(n): n > 5`, is invalid in its instance:

* as the first of 17 instances of `apply`, it is a static `TYPE` error at
  the call;
* as the 17th, the per-block budget declines its instance
  (`census-inspect.txt`: `instance=declined:budget-block`), the program is
  accepted, and it fails at run time with `>`'s `TYPE`;
* with `-max-per-block 64` it is rejected again.

So today, whether a program compiles depends on how many other instances of
a function precede a call in source order. The design document accepts
this ("A budget never turns into a false error"): a budget never adds a
rejection, but it can remove one. The run-time check makes the missed
rejection a run-time error rather than a wrong answer.

`i6-budget-equality-first` and `-last` show the equality analogue.
`same?("-", '-')`'s instance compares `str` with `UnicodeChar` when it is
the first request. As the 17th it is declined, and no instance sees the
comparison. Both programs run and return `false` today. An instance-level
rule (the first report's Level 1 in instances) would:

* reject the first;
* accept the second, which would then be silently `false`, with no run-time
  backstop.

### 8.3 How the existing type-level rules avoid it

* **Hashable admission and the DecimalRounded rule are generic-only.** They
  hold the generic body to its static types and leave instances alone.
  Their programs are budget-independent. Their cost is that an untyped
  function's instance can still reach the run-time refusal
  (`i2-decimal-instance`, `i7-hash-generic-callable`).
* **The affine discipline forces an instance.** An exact call with an
  affine argument always gets one, keyed by its affine entry types only, past
  every budget (hir/semantic.tcl, `Call`). That is budget-independent
  because the key space is small (affine entry types only) and the
  semantics needs the instance anyway: it decides drops.

  An equality rule cannot copy this. Its key would be every argument type
  of every call of every comparing function. That is unbounded, which is
  why the budgets exist.

### 8.4 The invariant and the boundary

> A semantic instance may establish more precise execution facts, but must
> not introduce a language-level obligation whose enforcement depends on
> whether that instance happens to exist.

Equality admissibility satisfies the invariant when its obligations come
only from:

* the generic body, against static types that fix heads (section 12's
  rule);
* contracts derived from the generic body, checked at calls with known
  argument types (section 6, if adopted);
* a conversion check at callable erasure (section 7).

Instances may still choose lowering: `veqtotal`, `chareq`, the total set
operations. A lowering choice is a fact about execution, not an obligation.

**SFIAE.** An equality obligation is a call obligation like the others
(MISSING-CONTEXT, DIRECT). Making it a contract keeps it applicability
(section 6.4), which SFIAE allows, and the effect is monotone. Making it
an instance diagnostic would also be a call's own problem, and instances are
judged inside method trials (hir/methods.tcl). A budget-dependent
diagnostic would then make method decisions depend on budgets too. That is
one more reason to keep equality out of instances.

The existing CHECKED-contract instance check (8.2) violates the invariant
today. Fixing it is outside this census. A design that adds equality
obligations should not extend that pattern.

## 9. Collections, membership and hashing

### 9.1 Four different questions

| question | today | relation it needs | probes |
|---|---|---|---|
| two collections compared (`xs == ys`, `s1 == s2`) | type-blind structural equality; empty collections of disjoint element types are equal | comparability (section 3) | `i1-lists`, `i1-sets`, `i7-immutable-set` |
| a needle against an element type (`ImmutableSet.contains`) | type-blind: a needle of another kind is `false`; a set member that is a callable raises | comparability of the needle with the member type, or admission | `i7-immutable-set`, `-mixed`, `i2-sets-contains` |
| a key or needle against a declared key type (`MutableSet.contains`, `MutableMap` lookup) | a declared `T`/`K` parameter: subtype admission with range proofs | admission, already decided by the declaration | `i7-mutable-set-needle`, `-domain`, `-empty-list`, `i7-mutable-map-key` |
| a type's Hashable witness | total equality and total hashing of every value | totality, per type | `i7-mutable-set-any`, `i2-hash-admission` |

### 9.2 What follows, and what is policy

* **Admission is stricter than comparability.**
  - `MutableSet[Small].contains(12)` is a static `TYPE` error
    (`i7-mutable-set-domain`), but `12 == x` with `x: Small` is comparable
    (and today `false`).
  - `MutableSet[List[int]].contains([])` is admitted (`i7-mutable-set-empty-list`:
    `List[never]` admits into `List[int]`).

  Membership with a declared key type is a call of a typed parameter. It
  must not become "comparability", which would weaken it.
* **Comparability does not decide membership.** Admitting `List[int] ==
  List[str]` (overlap) would not imply admitting a `UnicodeChar` needle for
  an `ImmutableSet[str]`. The needle shares no value with any member, so
  every relation of section 3 rejects that pair; only the empty-collection
  cases separate the relations.
* **`ImmutableSet.contains`.** Holding it to comparability of the needle
  with the member type is the natural extension of a checked `==`, and the
  first report proposed it. Holding it to admission, as MutableSet does, is
  an independent decision about ImmutableSet's API, not a consequence of
  equality semantics. `from_list` compares elements of one static element
  type with each other, so it has nothing to check.
* **Hashable is consistent with both.** A Hashable type has total
  equality, so its values never raise. MutableSet and MutableMap compare a
  probe key only at an equal stored hash and use the keys' own type for the
  comparison (`ieq`, `streq`, `veqtotal`; ORDERED-MUTABLE-MAP-SET.md).
  Within one `MutableSet[T]`, equality and hashing agree because both read
  the same canonical walk. Across types the question never arises:
  - the needle has type `T`;
  - two MutableSets are opaque, and their `==` is refused at run time.

  ImmutableSets do compare as sets, inside membership too
  (`i7-set-of-sets`).
* **The ordered table's `K == K`** is total and comparable by construction
  (5.3). It is the model for relational comparability: one variable on
  both sides.

### 9.3 DecimalRounded

DecimalRounded is not an ordinary kind for equality:

* `==` of two statically DecimalRounded operands is a different operation,
  `DecimalRounded#==`, at the precision of the operands' static types
  (`i7-decimal-precision`: `two(three()) == 1.25` and `two(three()) ==
  three()` are `true`).
* A DecimalRounded operand beside a Float64 is a static `TYPE`
  (`i7-decimal-float`).
* A type that holds DecimalRounded values is a static `TYPE` for `==`
  (`i2-decimal-list`).
* A set of them is not a type.

Two consequences:

* **A checked `==` must leave DecimalRounded operands to
  `hir/decimal.tcl`.** That module decides them first (operator selection),
  and its precision rule is not comparability. Under the structural rule,
  `List[DecimalRounded]` against itself would be compatible, while the
  decimal rule rejects it. The decimal rule must keep priority, and it does
  if the equality check skips operator calls the decimal pass resolved or
  rejected.
* **The DecimalRounded rule has the generic-only gap of 8.3.** `same?(two(),
  two())` reaches the type-blind `==` and fails at run time
  (`i2-decimal-instance`). A checked equality does not close it: no generic
  rule sees through an untyped function. Only contracts or instances could,
  and section 8 argues against instances.

## 10. Corpus compatibility and migration impact

`tools/reclassify.tcl` re-ran the first census's corpus:

* every program of examples/, bench/ and tests/golden/;
* a loader of every standard-library module;
* a platform's programs compiled for its target.

It recorded every `==` site under every relation, in the generic HIR and in
the worst instance the compilation used. `reclassify/sites.tsv` has one line
per site, `reclassify/params.tsv` one line per would-be contract, and
`reclassify/policies.txt` holds the tables below.

### 10.1 Coverage

1,993 sites, exactly the first census's sites (file, line and column), with
23 failed compilations (the first census: 27). The four platform programs that census could not
compile (the Darwin and Windows hello and 2048 demos) now compile for their
targets, and add no site of their own. The 23 failures
(`reclassify/failed.txt`):

* staged C bindings: SDL3, BoringSSL, Tcl, and Icy Tower's five modules;
* the event loop's Linux package (2);
* entries whose `main` requires a context (3);
* two experimental bench programs;
* the three DFA lexers (a suspending function as a value);
* the two examples rejected on purpose;
* the loaders of the two internal namespaces, whose modules other loaders
  reach.

Every standard-library module is covered.

### 10.2 Sites whose operands both fix a kind

| class | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| both operands of fixed kind | 328 | 257 | 3 | 965 | 1,553 |
| structurally compatible | 328 | 245 | 3 | 809 | 1,385 |
| a component of no fixed kind (`List[any]`, an `any` field) | 0 | 11 | 0 | 111 | 122 |
| incompatible: heads differ in kind | 0 | 0 | 0 | 22 | 22 |
| incompatible: heads differ in declaration or shape | 0 | 1 | 0 | 20 | 21 |
| incompatible: heads equal, a component differs | 0 | 0 | 0 | 3 | 3 |
| of the 46 incompatible, a value pair can be equal | 0 | 0 | 0 | 1 | 1 |
| compatible, but never equal (List lengths) | 0 | 0 | 0 | 1 | 1 |
| refused (a top-level kind with no equality) | 0 | 0 | 0 | 0 | 0 |

* **The incompatible sites are the first census's 44 disjoint sites and its
  two empty-only sites.**
  - The one incompatible pair that can be equal is lists-and-sets.bot:472,
    `ImmutableSet[UnicodeChar]` against `ImmutableSet[int]`, equal when both
    are empty.
  - The first census's other empty-only site, native-values.bot:490:51, is
    `List[int]{length: 1}` against `List[str]{length: 1}`. Its length
    refinements rule out the empty value, so no value pair is equal.
* **The one compatible pair that is never equal** is native-values.bot:490:36,
  `List[int]{length: 1}` against `List[int]{length: 2}`. The overlap rule
  rejects it, the structural rule does not: lengths are values, not
  components.
* **No site is partial or undefined.** By `eqcensus::Defined`, 1,433 sites
  are total and 560 unknown: the 440 with an operand of no fixed kind, and
  120 whose heads are fixed but which hold an `any` component (a
  `List[any]`, or `std::abi::bytes::Bytes`, whose opaque field is `storage:
  any`). No comparison of the corpus has a static type known to hold a
  callable, a MutableArray or another refused kind. So the refusal of
  top-level kinds without equality rejects nothing here.
* **Nothing outside the tests is incompatible** except
  examples/surface/15-enums.bot's demonstration that two enums'
  same-spelled cases differ. No standard-library or benchmark site is
  incompatible, refused, or compatible-but-never-equal.

### 10.3 Sites with an operand of no fixed kind

| origin (other operand) | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| untyped parameter (known) | 1 | 12 | 2 | 256 | 271 |
| untyped parameter with a contract its use does not see (known) | 1 | 2 | 1 | 86 | 90 |
| computed (known) | 2 | 21 | 0 | 22 | 45 |
| two untyped parameters | 1 | 0 | 0 | 11 | 12 |
| computed and computed | 0 | 2 | 0 | 7 | 9 |
| computed and untyped | 0 | 4 | 0 | 1 | 5 |
| contract and untyped, contract and contract | 0 | 2 | 0 | 3 | 5 |
| imprint variable and imprint variable | 1 | 0 | 0 | 1 | 2 |
| declared `any` and declared `any` | 0 | 0 | 0 | 1 | 1 |
| all | 6 | 43 | 3 | 388 | 440 |

* **"With a contract its use does not see"** is a parameter whose CHECKED
  contract (an Int, mostly, from arithmetic) fixes a kind, but whose use in
  the comparison is typed `any`, because checked contracts are not seeded
  into the body. `std::web`'s `domain?(start)`'s `j == start` is one.
* **Declared `any` is one site**: core-semantics.bot's `register_equality`.
  The imprint pair in the standard library is `std::ordered_table`'s
  `key_at(e) == key` (`K` against `K`).
* **The 12 relational sites** are `std::test::equal` and golden registration
  helpers. No instance of any of them compares incompatible types.

### 10.4 What each policy rejects

| policy | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| head rule, generic HIR | 0 | 1 | 0 | 42 | 43 |
| overlap rule, generic HIR | 0 | 1 | 0 | 45 | 46 |
| structural rule, generic HIR (model A) | 0 | 1 | 0 | 45 | 46 |
| first report's Level 1, generic HIR | 0 | 1 | 0 | 45 | 46 |
| refusal of top-level kinds without equality | 0 | 0 | 0 | 0 | 0 |
| further sites only an instance shows (the first report's instance check) | 0 | 0 | 0 | 4 | 4 |
| of those, a declared `any` operand | 0 | 0 | 0 | 1 | 1 |
| of those, an untyped parameter | 0 | 0 | 0 | 3 | 3 |
| relational sites with an incompatible instance (model C's extra) | 0 | 0 | 0 | 0 | 0 |
| every operand of no fixed kind (model D) | 6 | 43 | 3 | 388 | 440 |
| model D, less declared `any` | 6 | 43 | 3 | 387 | 439 |
| model D, less declared `any` and imprint variables | 5 | 43 | 3 | 386 | 437 |

The four generic rules reject almost the same sites:

* the head rule misses the three component cases;
* the overlap rule swaps lists-and-sets.bot:472 (empty sets can be equal)
  for native-values.bot:490:36 (lengths differ);
* the structural rule and the first report's relation agree on this
  corpus, because it has no phantom slot or disjoint domain pair.

The relations differ on the language's future programs (section 3), not on
today's corpus.

### 10.5 Inferred contracts (model B)

| parameters compared with an operand of fixed kind | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| all | 2 | 3 | 3 | 122 | 130 |
| with an inferred contract today, which the comparison agrees with | 1 | 2 | 1 | 81 | 85 |
| without one today: would gain one | 1 | 1 | 2 | 41 | 45 |
| compared with two kinds (a conflict) | 0 | 0 | 0 | 2 | 2 |
| compared with a List, set or struct operand | 0 | 0 | 0 | 0 | 0 |
| first parameter (a method receiver) | 1 | 1 | 3 | 98 | 103 |

* **The 85 existing contracts all agree with the comparison**: 82 Int, 2
  String, 1 Bool. Equality would not narrow any of them.
* **The 45 new ones**: 26 Int, 15 String, 2 UnicodeChar and 2 conflicts
  (warning-programs.bot's two `is_comma`). 43 of them are first parameters.
* **Outside the golden suites the new ones are four**:
  - `bench/source-checks.bot`'s `is_underscore?` and `is_hyphen?`
    (String);
  - `examples/stdlib/ai_text_clean.bot`'s `cleaner_emoji` (UnicodeChar);
  - `std::web`'s nested `char_is?(i, c)` (UnicodeChar).
* **No would-be contract compares with a List, set, struct or integer
  domain.** So the kind-level widening of 6.2 changes nothing on today's
  corpus. It matters for the programs it would reject later.
* **The calls a concrete contract would reject** are the instance-only sites
  with an untyped parameter:
  - range-and-contract-values.bot's `eq_x?(1)`, the pinned decision;
  - the two `is_comma` conflicts, which are rejected at the definition
    rather than at a call.

### 10.6 Migration impact by policy

| | model A | model B | model C | model D |
|---|---|---|---|---|
| standard library | none | `std::web`'s `char_is?` gains `UnicodeChar` (all its callers pass characters) | as B | 5 sites rejected: `std::test::equal`, `describe`'s two Bool tests, and `std::web`'s `char_is?` and `domain?` (unless their parameters' contracts count as known) |
| examples | 15-enums.bot's demonstration | plus `cleaner_emoji`'s contract | as B | 43 sites |
| benchmarks | none | two String contracts in source-checks.bot | as B | 3 sites |
| golden tests to migrate | 45 sites (the first report's list, section "The census") | plus 3: `eq_x?(1)` and the two `is_comma` definitions | as B | 388 sites |
| inferred contracts | unchanged | 45 new, 2 conflicts | plus relational requirements on the 12 relational sites' functions | unchanged |
| method applicability | unchanged | 103 receivers gain or keep a contract; a decision can only move from ambiguous to decided or from decided to rejected (6.4); not measured on the corpus | as B | unchanged |
| callable values | unchanged | unchanged without the conversion check; with it, conversions of the 45 functions to `Fn` types of another kind are rejected | as B | unchanged |
| a silent respelling remains | at the 440 sites of no fixed kind | at sites whose parameter receives `any`, through erased callables (without the conversion check), and at declared `any` | as B, less relational helpers | at declared `any` only |

The golden migration is the same for every generic rule: the tests that pin
a constant cross-kind `false` become rejection tests. Its size is 45
sites in 17 suites (`reclassify/sites.tsv`, class `incompatible`). This
milestone rewrites none of them.

## 11. Candidate semantic models and tradeoffs

Four models, each with the structural relation of section 3 unless stated:

* **A. Narrow static check, no inference.** `==`, `!=` and
  `ImmutableSet.contains` are rejected in the generic HIR when both
  operands' static types fix their heads and are structurally incompatible
  (`EQUALITY-INCOMPATIBLE`), or when an operand's top-level kind has no
  equality (`EQUALITY-UNDEFINED`). Anything else is admitted with today's
  semantics. No instance check, no contract change.
* **B. A plus concrete CHECKED contracts.** An untyped parameter compared
  with an operand of fixed kind gets that operand's kind-level class as a
  CHECKED contract (section 6.2), plus the conversion check of section 7.3.
* **C. B plus relational obligations.** A new requirement between
  parameters ("comparable with parameter j"), propagated across calls and
  checked where argument types are known.
* **D. Restrictive.** Every comparison needs both operands' heads known
  (declared, inferred, narrowed by a kind test), unless an operand is
  declared `any`.

| criterion | A | B | C | D |
|---|---|---|---|---|
| correctness (no rejection of a comparison whose result is not constant, except equal empty collections) | yes | yes for known arguments; kind-tolerant code conflicts | as B | rejects every dynamic comparison not spelled `any` |
| instance and budget independence | yes | yes (contracts are generic) | yes, if the obligation is checked from contracts, not instances | yes |
| the warning's respelling, known operand types (`c: str`, `List[str]`, struct fields) | rejected | rejected | rejected | rejected |
| the respelling against an untyped parameter | silent | rejected at calls with known argument types; silent through `any` and erased callables unless the conversion check exists | as B, also through relational helpers | rejected |
| the respelling against declared `any` | silent | silent | silent | silent (by declaration) |
| language consistency | matches the existing type-level rules (affine, DecimalRounded, Hashable) | reverses `ic-unconstrained-stays-any`; contracts must be kind-level, unlike every other contract | a new abstraction, close to type variables | close to integer-domain admission, but no kind tests exist for UnicodeChar, Bool, Float64, enums or structs |
| ergonomics | no new annotations | kind-tolerant helpers need a kind test that may not exist | as B | heavy: needs kind tests or `any` everywhere |
| compiler complexity | one check beside `hir::decimal::verify`, one relation, two diagnostic kinds | plus a sink in hir/signatures.tcl, a widening rule, a conversion check; method and static-decision harnesses | plus relational constraint propagation and its fixpoint | as A, plus kind tests for every kind |
| diagnostic quality | at the comparison, both types named | at the call, with the inference chain | at the outermost call, with a chain through several functions | at the comparison |
| dynamic programming | untouched | untouched through `any` | untouched through `any` | only through declared `any` |

The most expressive model is not the best first step. C is a type-variable
system by another name. D contradicts the test framework and the standard
library's dynamic helpers (section 5.3) unless every one declares `any`. It
also needs kind tests the language does not have. B is a sound refinement
of A, but only once its two prerequisites exist:

* the kind-level contract;
* the callable conversion check.

Before them it protects direct calls and loses the stored-predicate case.

## 12. Recommended next implementation milestone

**Checked equality, milestone 1 (model A).**

* **Relation.** Structural comparability (section 3.1), computed from the
  generic HIR's static types:
  - heads equal at every component position the types state;
  - integer domains, refinements and List length refinements compatible
    with their carrier and with each other;
  - `never`, `any` and imprint components compatible with anything, and one
    imprint variable compatible with itself;
  - applications compared by their substituted fields, never their type
    arguments;
  - opaque structs by declaration only (their fields are no interface).
* **Sites.**
  - Every reachable `==` the source frontend wrote (`!=` included) that the
    DecimalRounded pass did not select or reject.
  - `std::immutable_set::contains`'s needle against the set's member type,
    as a registration role (`-equality checked`), never by name. This is
    the `-hashing {0 checked}` pattern.
* **Diagnostics.** Two kinds, each with a `std::compiler::DiagnosticCode`
  case, a static-compile census row and a Compilerpedia topic:
  - `EQUALITY-INCOMPATIBLE`: the operands' types and the first
    incompatible component, "== of str and UnicodeChar compares values that
    are never equal: no String is a UnicodeChar";
  - `EQUALITY-UNDEFINED`: an operand whose top-level kind has no equality,
    where the erasure and affine rules have not already reported it.

  Both are reported at the comparison, in the generic HIR only, through
  `hir::CheckOnce` beside `hir::decimal::verify`. They are not
  `CheckingCall` problems of `==`: no method decision reads them.
* **Not in it.** No inference change, no instance check, no change to
  Totality's clients, native lowering, runtime equality or
  `ImmutableSet.from_list`. Partial pairs stay dynamic. Operands of no fixed
  kind keep today's semantics.
* **Before or with it.** Two small fixes found here:
  - the Tcl compiler's MutableVector fast path (2.4);
  - the Bearing quirk for declared `any` (5.1), so that `any` is a usable
    opt-in for later milestones.

  The imprint-variable leak in contract inference (6.3) is independent but
  should precede any inference milestone.
* **Migration.** The rejections of section 10:
  - the golden tests that pin a cross-kind `false` become rejection tests;
  - lists-and-sets.bot:472, the one incompatible pair that can be equal
    (two empty sets), becomes an emptiness test or a rejection test;
  - `examples/surface/15-enums.bot`'s demonstration becomes a rejection;
  - the language reference's sentence becomes "values of different kinds
    are never compared".

  The warning gate compiles `15-enums.bot` (audit/refactor/manifest.txt),
  so the example changes with the check; no standard-library or benchmark
  program is affected.
  The runtime's cross-kind and cross-declaration answers still need
  killers: the enum mutation harness's `equal-ignores-enum-*` and
  `equal-by-ordinal-*` mutants are killed today by `Light::Red ==
  Signal::Red` in values.bot and the example. After the check that
  comparison has to reach `==` through an operand of no fixed kind (a
  declared `any`), which keeps the run-time rule tested.
* **What it delivers.** `ONE-CHAR-STRING-LITERAL`'s respelling can no longer
  silently change a comparison whose operand type is known, at any depth
  (`i8-hazard-list`, `i8-hazard-struct`, `i8-hazard-set` all become
  rejections). That meets the `==` half of the warning's second graduation
  criterion for known types. Untyped parameters, declared `any` and
  computed `any` keep the hazard (`i8-hazard-untyped`, `i8-hazard-any`), and
  the report says so rather than closing it by instances.
* **What it leaves open.** Each is a separate decision:
  - concrete CHECKED contracts (model B);
  - the callable conversion check;
  - relational obligations (model C);
  - ImmutableSet's admission policy (9.2);
  - kind tests for UnicodeChar, Bool and Float64;
  - a payload-carrying sum type's variant rule.

  Model A forecloses none of them. Each would add rejections (at calls, at
  conversions) or kind tests on top of A, and A's own rejections are all
  judged on generic types.

## 13. Remaining uncertainties and reproduction instructions

### Uncertainties

* **Order of partial equality** (4.1). The two runtimes agree, but this
  census found no specification of the walk order beyond "shapes and
  lengths first". A rule relying on it, which A does not, would need one.
* **Results** are tested only as core IR. Their static type in HIR built
  from core IR is the bare `result` kind (unknown to every relation). No
  source program produces one.
* **The corpus's coverage.** Section 10 lists the compilations
  `reclassify.tcl` could not run. They are staged C bindings, other
  platforms' programs the host cannot load, and modules that are not
  programs. The census compiles a platform's programs for their target
  where the front end allows it.
* **Instance-only classes are a lower bound.** They describe the instances
  the corpus's compilations used. A different caller set produces others,
  which is the point of section 8.
* **The would-be contracts** (`params.tsv`) are collected syntactically: an
  untyped parameter, possibly through an immutable alias, compared with an
  operand of fixed kind outside a kind test of it. The real inference would
  also propagate through edges (6.4), so the counts are a lower bound on
  affected parameters and an upper bound on independent decisions.
* **Model B's method effects** were shown on a two-module example, not
  measured on the corpus. Measuring them needs the implementation and the
  method-resolution reference audit.

### Reproduction

```bash
export LANG=C.utf8 LC_ALL=C.utf8
```

```bash
cargo build --release --manifest-path native/Cargo.toml
```

```bash
tclsh9.0 audit/equality-semantics/tools/run.tcl -out /tmp/census-probes.txt
```

```bash
tclsh9.0 audit/equality-semantics/tools/run.tcl audit/equality-semantics/census/methods/ambiguous.bot audit/equality-semantics/census/methods/decided.bot audit/equality-semantics/census/methods/only-m1.bot
```

```bash
tclsh9.0 audit/equality-semantics/tools/inspect.tcl audit/equality-semantics/census/i6-budget-checked-last.bot
```

```bash
tclsh9.0 audit/equality-semantics/tools/results.tcl
```

```bash
tclsh9.0 audit/equality-semantics/tools/reclassify.tcl -out /tmp/reclassify -cache /tmp/hircache
```

```bash
tclsh9.0 audit/equality-semantics/tools/policies.tcl /tmp/reclassify
```

The probes take about 3 minutes on the 4-core container (101 programs,
five runs each). The corpus run compiles 237 programs and loaders. From
scratch that is the first census's half hour or more, nearly all of it the
front end; against a warm `-cache` of the same front end it took under 3
minutes here.
