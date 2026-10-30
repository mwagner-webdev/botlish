# Trait-constrained imprinted type constructors

> «Botlish functions remain imprinted, not generically declared.»
>
> «A parameterized type may state what kinds of concrete types are valid in
> one of its slots.»
>
> «`K satisfies Hashable` constrains K; it does not replace K with
> Hashable.»
>
> «Matching an applied type establishes both its rigid imprints and the
> obligations guaranteed by its constructor.»
>
> «Constraints live at the boundary that requires them. A Map requires
> Hashable keys, so Map declares the constraint once.»
>
> «Trait satisfaction uses the ordinary trait system regardless of whether
> the witness is structural, intrinsic or implementation-supplied.»
>
> «A constraint validates an imprint; it does not manufacture one.»

## Contents

* [Result](#result)
* [Why this is not generic functions](#why-this-is-not-generic-functions)
* [Syntax](#syntax)
* [Type constructor contracts](#type-constructor-contracts)
* [Imprinting](#imprinting)
* [Constraint propagation](#constraint-propagation)
* [Concrete type preservation](#concrete-type-preservation)
* [Fields and substitution](#fields-and-substitution)
* [Construction](#construction)
* [Trait integration](#trait-integration)
* [Hashable integration](#hashable-integration)
* [Typed-storage probe](#typed-storage-probe)
* [Runtime representation](#runtime-representation)
* [HIR, interchange, cache, isolation](#hir-interchange-cache-isolation)
* [Diagnostics](#diagnostics)
* [Tests](#tests)
* [Fuzzing](#fuzzing)
* [Mutation testing](#mutation-testing)
* [Performance](#performance)
* [Regression](#regression)
* [Limitations](#limitations)
* [Map/Set handoff](#mapset-handoff)
* [What to run when changing this](#what-to-run-when-changing-this)

## Result

What landed:

* **Parameterized structs.** `struct Pair[A, B]:` declares a struct type
  constructor with two *type slots*. Its types are its *applications*,
  `Pair[int, str]`, `Pair[K, List[V]]`: every field type naming a slot is
  the declaration's with the slot replaced by its argument. A bare `Pair` is
  no type. Opaque structs may have slots too; context structs may not.
* **Trait-constrained slots.** `struct Map[K satisfies Hashable, V]:` makes
  every valid application's first argument satisfy `Hashable`. A slot names
  at most one trait, intrinsic (`Hashable`) or source-declared, and
  satisfaction is the ordinary trait satisfaction (`hir::traits::satisfies`).
* **Applications validated everywhere a type is written**: a parameter, a
  result, a field, an error payload field, inside a List, a MutableArray or a
  function type, an explicit imprint, a construction, a `static compile:`
  block (a recoverable `TraitNotSatisfied`, `Type` or `Imprint`).
* **Imprinting through applications.** `fn get(m: Map[K, V], key: K)` stays
  an ordinary imprinted function: matching `Map[str, int]` establishes K and
  V exactly as `List[T]` establishes T. Matching a constrained constructor
  also gives the body the constructor's obligation: inside `get`, K is the
  imprint variable K *known to satisfy Hashable*, never the trait view
  `Hashable`.
* **Constraints that reach the code.** A K known Hashable hashes with
  `hashtotal`, compares with `veqtotal` and is admitted by the private table
  hash (`tablehashtotal`); a T that satisfies a source trait has that trait's
  operations, resolved and monomorphized by the ordinary trait machinery
  (one specialization per binding, direct calls of the witness's
  implementation).
* **No runtime cost.** An application is a static fact only: every
  application of a constructor shares the constructor's one runtime
  representation (one Tcl struct kind, one NIR shape), and no check,
  witness object or type-argument vector exists at run time.
* **HIR, HIR text, interchange, the front-end cache and compilation
  isolation** carry slots and constraints (the struct registry is a
  declaration registry).
* **CO-3 answered.** The Map-like probe keeps `MutableArray[K]` through
  field projection; specialized String and Int instances compare keys with
  `streq` and `ieq`, and even the unspecialized generic code uses the total
  `veqtotal` -- the fallible `veq` is gone from the probe
  ([Typed-storage probe](#typed-storage-probe)).

What did not land, deliberately: function-side generic binders (`fn
f[K, V]`), `where`/`requires` clauses, constraints on functions, predicates,
scalar constraints, higher-kinded types, associated types, parameterized
traits, enums, layouts, errors or contexts, and any Map or Set
([Limitations](#limitations)).

## Why this is not generic functions

A generic function declares its type parameters (`fn get[K, V](m: Map[K, V],
key: K)`); its body is checked once against those parameters' bounds, and a
caller instantiates it. Botlish has no such declaration, and this milestone
adds none: `fn get[K, V](...)` and `where` stay syntax errors
(`tc-parse-no-generic-binder`).

A Botlish function is *imprinted* (C-ABI-TYPES.md, "Imprinting"): an
undeclared one-capital-letter name in its signature (`K`, `V`, `T2`) is an
imprint variable, rigid within one call and established by the call's
arguments (left to right, from the arguments' static types), or written by an
explicit imprint (`empty[str]()`). Nothing names the variables except their
occurrences; nothing declares their bounds.

What this milestone adds is on the *type* side. A struct declaration may
name slots, and a slot may state which concrete types are valid in it. A
function never states a constraint: it receives one by mentioning a
constrained constructor. `fn get(m: Map[K, V], key: K)` knows K satisfies
Hashable because `Map` requires it of every valid application -- the
function could not have been given a `Map[K, V]` otherwise. This keeps the
law of the constraint's boundary: Map requires Hashable keys, so Map states
it once, and every function over a Map inherits it.

The consequences that distinguish this from generic functions:

* A constraint never establishes a variable (`tc-imprint-not-manufactured`):
  `fn empty() -> Map[K, int]` still needs `empty[str]()`, because nothing
  but an argument or an explicit imprint says what K is.
* A function's constraints are exactly what its signature's applications
  give it. Its body may not assume more (`tc-constraint-forgetting`: a body
  constructing `Map {keys: ks, ...}` of an unconstrained `ks: List[K]` is
  TRAIT-NOT-SATISFIED in the body, whatever the callers pass).
* There is no instantiation step: the body is checked once, with the
  variables rigid and their obligations as facts; each call is checked by
  imprinting and by validating the applications its binding makes.
* An untyped parameter forwarded to `Map[K, V]` (`fn size(m): m.length()`)
  takes the requirement with variables of its function's own, established
  at each of its calls, constraints included -- the signature the
  programmer could have written, never a declared parameter list
  (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md, "Inherited imprint variables";
  `tc-inherited-forwarder-set`, `-map`, `-constraint`).

## Syntax

```
struct_decl  ::= ["opaque"] "struct" NAME [slots] ":" fields
slots        ::= "[" slot ("," slot)* "]"
slot         ::= VARIABLE ["satisfies" TRAIT]
type         ::= ... | NAME "[" type ("," type)* "]"
construction ::= NAME ["[" type ("," type)* "]"] "{" fields "}"
```

* A slot is named like an imprint variable: one capital letter, optional
  digits (`K`, `V`, `T2`). A duplicate slot, a slot named like a visible
  struct, a trait that does not exist, a type that is no trait and a context
  trait are rejected at the slot (`tc-decl-*`).
* The relation is spelled `satisfies` only. `K: Hashable`, `K where ...`,
  `K requires ...`, `K implements ...` and `K extends ...` are syntax errors
  with their own message (`tc-parse-constraint-word`).
* Type applications are n-ary: `Map[K, V]` parses as `{apply Map {K V}}`,
  one argument as `{NAME ARG}` as before. `List[int, str]` is therefore no
  longer a syntax error but resolution's arity error of List, like
  `MutableArray[int, str]` and `MutableVector[int, str]`
  (`applied-type-malformed-comma-arity`, `mat-syn-4`, `mv-type-syntax`).
* A construction may write its application, `Pair[int, str] {first: 1,
  second: "x"}`, qualified too (`std::tm::Map[str, int] {...}`), or leave it
  to the field values, `Pair {first: 1, second: "x"}`.
* `context struct Foo[T]:` is rejected: a context is installed and required
  by its exact struct type, and a type constructor has no type of its own.
  `enum E[T]:`, `trait T[K]:`, `error E[T]:` and `layout L[T]` stay syntax
  errors. `LayoutStruct Foo:` and `layout struct Foo:` stay syntax errors
  (`bl-syntax-no-generic-struct-declarations`).

## Type constructor contracts

A parameterized struct's registry entry (`hir/structs.tcl`) holds its slots
in order with their traits, `slots {{K {Hashable}} {V {}}}`, and its fields'
types with the slots as imprint variables. An application `{nstruct ID
ARGS}` is valid when:

* it gives one type per slot (TYPE otherwise: `Pair[int]`, `Pair[int, str,
  bool]`, a bare `Pair`, `Point[int]` of a struct without slots;
  `tc-app-arity`);
* every argument is a concrete, unrestricted type: a trait
  (TRAIT-STORAGE-UNSUPPORTED: a struct stores one concrete representation),
  a context trait (CONTEXT-TRAIT-POSITION) or an affine type (TYPE) is no
  argument (`tc-app-slot-argument-kinds`);
* every constrained slot's argument satisfies the slot's trait
  (`hir::structs::ApplicationProblem`): by `hir::traits::satisfies` for a
  concrete type, and for an imprint variable exactly when the variable's own
  constraints include the trait.

The check runs wherever a type is written (`hir::structs::verifyApplications`
over every function's parameter and result types, every construction and
every explicit imprint; `hir::structs::VerifyDeclarations` over every struct
field and error payload field), and on every application an imprint binding
makes (`hir::imprint::Bind`). A rejected application is TRAIT-NOT-SATISFIED
at the application, naming the slot, the application and the reason in
source terms:

```
the type of parameter "m" is invalid: type argument for "K" in
Map[Fn{args: [int], return: int, errors: []}, int] does not satisfy
Hashable: a function has no total equality (== of two functions is not
defined: there is no function identity)
```

**Nested obligations are stated by the enclosing declaration.** A struct
field holding `Map[T, int]` over a slot T of its own requires that T carry
the obligation: `struct Outer[T]: m: Map[T, int]` is rejected at the field,
`struct Outer[T satisfies Hashable]` is accepted
(`tc-decl-nested-obligation-required`). An obligation on a composite argument
is checked through its components: `Map[List[T], int]` needs T Hashable,
`Map[Pair[T, U], int]` needs both (`tc-decl-nested-composite`). An enclosing
declaration therefore never hides an unsatisfied nested slot.

**Identity.** An application's identity is the constructor's identity and
its arguments, nothing else: no witness, trait set or constraint is part of
it (`tc-app-show`: `{nstruct Pair {int {nstruct Map {str int}}}}`).
Applications are distinct types, invariant in every slot -- `Box[str]` is no
`Box[int]`, nor is `Box[Small]` (an integer domain) -- and no slot is
converted, widened or narrowed (`tc-app-distinct-and-invariant`). No new
variance policy was added: a parameterized struct behaves like a named
struct whose identity includes its arguments.

## Imprinting

`hir/imprint.tcl`'s `Match`, `Occurrences` and `Substitute` treat an
application like every other applied type: matching the parameter type
`Map[K, V]` against an argument of type `Map[str, int]` establishes K = str
and V = int (`tc-imprint-establishes`), and an established variable stays
rigid: with K = str, an Int `key: K` is the argument's TYPE error
(`tc-imprint-rigid`). Everything imprinting did before is unchanged
(`tc-imprint-unchanged`; the C ABI and imprint suites pass): a bare `x: T`
still establishes nothing (`identity(x: T) -> T` is still rejected), and a
variable is still not a declared parameter.

The order of a call's checks (`hir::imprint::Call`):

1. match each argument's structured type against its parameter type;
2. establish the rigid imprints, left to right (IMPRINT for a variable
   nothing establishes; TYPE for an argument disagreeing with an
   established one);
3. collect the constructor obligations of every application the signature
   mentions, the result's included;
4. substitute the binding;
5. check ordinary trait satisfaction of each substituted application
   (TRAIT-NOT-SATISFIED).

So an unestablishable variable is always IMPRINT and a failed constraint
always TRAIT-NOT-SATISFIED, never the other way round
(`tc-diagnostic-order`). An argument that was already rejected (a poisoned
construction) establishes nothing and adds no diagnostic of the call.

**The result counts.** `fn make(ks: List[K], vs: List[V]) -> Map[K, V]`
mentions Map only in its result. Its arguments establish K and V; the
result's application gives K its obligation, so `make([twice], [1])` is
TRAIT-NOT-SATISFIED (it would return a Map of functions) and the body may
hash a K (`tc-result-constraint`).

**A constraint never establishes a variable.** `fn empty() -> Map[K, int]`
called as `empty()` is IMPRINT, as before; `empty[str]()` is accepted and
`empty[Fn{...}]()` is TRAIT-NOT-SATISFIED -- a trait failure of the explicit
imprint, not an imprint failure (`tc-imprint-not-manufactured`).

**A nested function's enclosing variable is the enclosing function's.** A
nested signature is written in the enclosing body, so a name of the
enclosing function's variable there is that variable (C-ABI-TYPES.md,
"Imprinting"): rigid, never bound at the nested function's calls, every
argument held to it. In `fn outer(b: Box[T])`, a nested `fn g(c: Box[T])`
takes `b` and rejects `g(Box {value: "s"})` (TYPE), where it once bound
its own T to str while `b` kept outer's -- an accepted program that failed
at run time (`tc-imprint-nested-enclosing-variable`). A variable the
enclosing functions do not have is the nested function's own, bound at
each call as before (`tc-imprint-nested-enclosing-uses`).

## Constraint propagation

At resolution, every function's declared parameter and result types are
rewritten so that each imprint variable carries the traits the signature's
applications require of it (`hir::imprint::Constrain`, from `Obligations`):
in `fn get(m: Map[K, V], key: K) -> V`, every occurrence of K becomes
`{imprint K Hashable}`, V stays `{imprint V}` (`tc-constraint-derived`).

* A slot whose argument is a variable gives it the slot's traits.
* A slot whose argument is a composite of variables, `Map[List[K], V]`,
  gives each variable an intrinsic trait whose witness predicate is
  compositional (Hashable: `List[K]` is Hashable exactly when K is;
  `tc-constraint-composite`). A composite never satisfies a source trait
  (an applied type is no witness, TRAITS.md), which verification reports.
* A variable may collect obligations from several constructors: `fn both(h:
  H[K], p: P[K])` knows K is Hashable and Printable
  (`tc-ordinary-two-constraints`).
* The traits are part of the variable's type in the body, so every
  analysis reading types reads them: `hir::types::Totality` makes a
  Hashable K total for equality and hashing; `hir::traits::satisfies`
  answers for a constrained variable by its constraints; the trait-call
  typing (`hir::traits::TypeImprintCall`) resolves `k.op()` to the trait's
  operation.
* **Strengthening:** a constrained K is usable where an unconstrained
  variable is expected and keeps its facts: `first(xs: List[T]) -> T` of a
  `List[K]` returns a K that is still Hashable (`tc-constraint-strengthening`).
* **Forgetting:** an implementation's assumptions never become part of its
  contract (`tc-constraint-forgetting`, above).
* **Nested signatures:** an enclosing function's variable in a nested
  signature carries exactly the enclosing signature's constraints
  (`hir::imprint::ConstrainEnclosing`): K of `outer(h: H[K])` is Hashable in a nested
  `g(x: K)`, and a nested signature adds none -- `g(h: H[K])` inside
  `outer(b: Box[K])` is TRAIT-NOT-SATISFIED, as a construction in the body
  would be (`tc-constraint-nested-enclosing`). HIR text prints the variable
  by name and reading derives the constraints the same way
  (`tc-hir-text-nested`).
* `any` never satisfies a constraint because some of its values might:
  `H {key: x}` of an untyped `x` is TRAIT-NOT-SATISFIED
  (`tc-constraint-any`).

## Concrete type preservation

`K satisfies Hashable` never replaces K by the trait. In
`tc-constraint-not-a-view`'s body

```botlish
fn keep(m: Map[K, V], key: K) -> List[K]:
    a = std::mutable_array::create(1, key)
    b = Box {value: key}
    c = std::mutable_array::at(a, 0):
        on IndexNotFound:
            key
    [key, b.value, c]
```

every reference to `key` has the HIR type `{imprint K Hashable}`: it is
stored in a `MutableArray[K]`, a `Box[K]` and a `List[K]`, returned as a K,
and read back as a K. A trait view could do none of this
(TRAIT-STORAGE-UNSUPPORTED for `List[Hashable]`). The reverse holds too: a
trait view where a slot argument is expected is no argument (`P {value: v}`
of a `v: Printable` is TRAIT-NOT-SATISFIED;
`tc-ordinary-trait-view-into-slot`).

## Fields and substitution

`hir::structs::AppliedFieldTypes` gives an application's fields: the
declaration's field types with each slot replaced by its argument
(`hir::imprint::Substitute`), through nested applications --
`Storage[str, int]` with `inner: Pair[List[K], Box[V]]` has `inner:
Pair[List[str], Box[int]]` (`tc-field-substitution`).
`hir::types::StructField` reads it for every projection, destructuring,
completion fact and escape decision, so `p.first` of a `Pair[int, str]` is
`int`, and in a generic body `p.second` of a `Pair[A, B]` is `B`
(`tc-projection-types`). Every consumer that walked a struct's declared
field types (callable bearing, mutable-collection detection, decimal
precision, static dependencies, value stability) walks the applied ones.

Application types are bounded like every aggregate type, with one rule
of their own (`hir::types::MakeApplied`): an argument is bounded at the
application's own aggregate depth, exactly where a value standing in a
field that names its slot is. List admission and applications are
invariant, so an argument cut one level earlier than its fields' values
would admit none of them -- the first version did that, and `Box {value:
[[[1]]]}` was rejected (`tc-construction-deep-values` pins the fix, two
mutants guard it). Applications directly inside arguments count separately:
they nest at most six deep (`appliedDepth`), and past that the arguments
are `any` ([Limitations](#limitations)).

## Construction

* **Explicit:** `Pair[int, str] {first: 1, second: "x"}` holds every field
  value to the substituted field type (`tc-construction-explicit`).
* **Inferred:** without an application, the field values establish the slots
  exactly as a call's arguments establish its variables
  (`hir::types::InferApplication`): `Pair {first: 1, second: ["x"]}` is
  `Pair[int, List[str]]`. An exact function's identity is no part of a slot,
  its contract is: `Box {value: twice}` is `Box[Fn{args: [int], return: int,
  errors: []}]` (`tc-construction-inferred`).
* **Unestablished or conflicting:** a construction whose values establish no
  type for a slot (`Bag {items: []}`: an empty List says nothing) or two
  different ones (`Two {a: 1, b: "x"}`) is IMPRINT; the application must be
  written (`Bag[int] {items: []}`; `tc-construction-unestablished`).
* **Invalid:** a construction makes an application, and an invalid one
  (`H {key: twice}`) is rejected at the construction as a poison value: its
  later uses (`hash(h)`) restate nothing (`tc-construction-constrained`).
* **In a generic body:** `Map[K, V] {...}` of the function's own variables is
  an application of them, constrained as the signature constrains them
  (`tc-construction-in-generic-body`).
* **Opaque:** an opaque parameterized struct is constructed and inspected
  only by its owner module (`tc-construction-opaque`).
* **Joins:** one application through both arms of an `if` and a handler
  keeps its type; two different applications have no join (`any`), so a
  projection after one is UNPROVEN-FIELD (`tc-branches-and-handlers`).

Empty-container construction without an application (`Map {keys: [], vals:
[]}`) stays IMPRINT: this milestone adds no typed empty literals.

## Trait integration

**Intrinsic traits.** `Hashable` constrains a slot by its witness predicate
(`hir::types::HashClass`): `Map[str, int]` and `Map[Pair[int, str], int]`
are valid; a function, a struct holding one, a MutableArray and `any` are
not, each with the predicate's reason (`tc-app-hashable-constraint`).

**Source traits.** A source-declared trait constrains a slot through ordinary
conformance (the witness's owner namespace's own functions, TRAITS.md):
`P[Person]` is valid where Person's module implements `describe`, `P[int]`
is TRAIT-NOT-SATISFIED with conformance's reason, "int cannot be a trait
witness: int has no canonical operation namespace" (`tc-ordinary-application`).
An application can itself be a witness when its owner implements the trait
for exactly that application (`fn label(w: Wrap[int])`;
`tc-ordinary-applied-witness`).

**Operations.** On a value whose type is a constrained variable, `v.op()`
resolves to the trait's operation (`hir::traits::TypeImprintCall`) and runs
the witness's own implementation on every backend
(`tc-ordinary-operation`). A requirement returning its trait returns T itself,
so it can be stored as one (`tc-ordinary-self-result`). Two traits of one
variable that both declare the operation make it AMBIGUOUS-METHOD-CALL: no
trait is ranked above another (`tc-ordinary-ambiguous`).

**Monomorphization.** A function whose code applies a source trait's
operation to a value of its own constrained variable -- directly, or by
passing one to another such function or to a trait-typed parameter -- is
specialized per binding by the trait plan (`hir::traits::ImprintPolys`),
exactly as a trait-polymorphic function is per witness:
`show<T=std::people::Person>` and `show<T=std::dogs::Dog>`, each operation
a direct call of the implementation, no runtime trait value, dispatch or
indirect call (`tc-ordinary-monomorphized`). A specialization is keyed by
the binding of the variables a source trait constrains only
(`SelectingBinding`): an unconstrained variable, or one only Hashable
constrains, selects no implementation and stays a variable of the
specialization. An obligation alone selects nothing: a function that makes
no operation on its constrained variable, and every function constrained
only by Hashable, stays one function
(`tc-ordinary-no-clone-without-operation`; Hashable's operations lower
directly). So recursion that imprints an unconstrained variable with ever
new types (`deep(Box {value: [b.value]}, p, n - 1)`) makes one
specialization, `deep<T=std::dogs::Dog>`, and runs; keyed by every variable,
it made one per List depth until the type bound stopped it, and the deepest
failed to type (`tc-ordinary-polymorphic-recursion`; the mutant
`specialization-keyed-by-every-variable`). New witnesses cannot be made by
recursion either: an owner's imprinted function (`fn describe(w: Wrap[T])`)
is no implementation for an application, since conformance admits exact
parameter types, so `Wrap[Wrap[...]]` is rejected, never specialized.
Specializations per function are bounded all the same (64,
`ImprintCloneLimit`, then TRAIT-POLYMORPHIC-RECURSION). Like a
trait-polymorphic function, such a function is top-level only: a nested one
is TRAIT-NESTED-POLYMORPHIC (`tc-ordinary-nested-function`; its
specializations would have to be made per activation of the enclosing
function). A nested function that applies the operation to a value of an
*enclosing* function's constrained variable applies it to that function's
variable: the enclosing function is the one specialized per binding, each
specialization with its own nested function, the nested signature
imprinted with the binding (`tc-ordinary-nested-enclosing-operation`).

## Hashable integration

The constraint reaches the three total lowerings of
HASHABLE-AND-KEYED-HASH.md through `hir::types::Totality`, which knows that
a variable constrained by Hashable has total equality and hashing:

| operation on a constrained K | NIR | unconstrained T | test |
|---|---|---|---|
| `hash(k)`, `k.hash()` | `hashtotal` | `hash` (fallible) | `tc-constraint-hash-total`, `tc-constraint-method-operation` |
| `a == b` | `veqtotal` | `veq` (fallible) | `tc-constraint-equality-total` |
| `std::table_hash::of(k)` | `tablehashtotal` | TRAIT-NOT-SATISFIED (admission `required`) | `tc-constraint-table-hash` |

The values are the concrete values' on every backend
(`tc-constraint-values`): `fingerprint(H {key: "x"}) == hash("x")`, equal
and unequal keys compare as their types do. The public `hash`'s outputs and
admission are unchanged (the Hashable suites and mutants pass).

## Typed-storage probe

The probe (`tc-typed-storage-probe`) is the CO-3 fixture of
HASH-TABLE-COMPILER-PRESSURE.md, written with this milestone's types:

```botlish
struct Table[K satisfies Hashable, V]:
    hashes: MutableArray[int]
    keys: MutableArray[K]
    vals: MutableArray[V]

fn matches(t: Table[K, V], i: int, key: K) -> bool:
    k = std::mutable_array::at(t.keys, i):
        on IndexNotFound:
            return false
    k == key
```

The answers:

* **Does `t.keys.at(i)` retain K?** Yes. The projection `t.keys` has the HIR
  type `{mutarray {imprint K Hashable}}` -- `MutableArray[K]`, never
  `MutableArray[any]` -- and the element read from it is a K.
* **Does the Hashable obligation survive the projection?** Yes: the element
  type is the constrained variable itself.
* **String keys:** the native instance `matches` for `Table[str, int]` (and
  `str`) compares with `streq`.
* **Int keys:** the instance for `Table[int, str]` compares with `ieq`.
* **Is generic `veq` still necessary?** No, not in the probe. The
  unspecialized code (`-specialize 0`) compares with `veqtotal`, the total
  sibling: no error edge, no fallible call. `veq` remains for values whose
  types prove nothing (an untyped key), as before.

`tc-specialize-instances` shows the same for a three-way probe: `Holder[int]`,
`Holder[str]` and `Holder[Point]` are three native instances whose
comparisons are `ieq`, `streq` and `veqtotal` (a struct key's equality is the
total generic one).

**CO-3 is closed for concrete Map instances**: a table written as a
parameterized struct keeps its key type through its storage, and
specialization reaches the typed equality the experiment measured for
`lpstr`/`lpint` (HASH-TABLE-EXPERIMENT.md, "Typed against generic"). The
specialization was already able to do this; what was missing was a struct
whose field types depend on the instance, which applications now are.

## Runtime representation

An application has no runtime existence:

* The Tcl backends' value of a `Pair[int, str]` and of a `Pair[str, int]` is
  the same kind of struct value, `Pair` (`tc-runtime-shared`): no
  type-argument vector, witness or generic header.
* NIR has one shape per constructor whatever its applications: `shape 1
  named "Pair" fields="first second"` serves both; the benchmark's 160
  distinct applications `Box[T1]..Box[T160]` give one `Box` shape.
* A statically valid application costs nothing: `keyOf(h: H[K]) -> K` (a
  constrained slot) and `valueOf(b: Box[T]) -> T` lower to the same NIR body,
  `structget 0` and `ret` (`tc-runtime-no-checks`); the only difference a
  constraint ever makes is the total operations it selects.
* No witness object is allocated because K satisfies Hashable: Hashable's
  operations lower directly, and a source trait's operations are
  monomorphized into direct calls. The benchmark's allocation counts are
  equal for the ordinary and the applied struct.

Specialization is reported separately from representation: native instances
are keyed by the concrete application (`Holder[int], int`), never by a
constraint (the mutant `witness-in-specialization-key` is killed).

## HIR, interchange, cache, isolation

**HIR.** An application is `{nstruct ID {ARG ...}}`, a constrained variable
`{imprint K {TRAIT ...}}`; type expressions are `{apply NAME {ARG ...}}`
before resolution. The struct registry entry carries `slots` and
`constraints`. A trait in a slot is the trait's canonical identity
(`std::printable::Printable`), so isolation and interchange never confuse two
traits of one spelling.

**HIR text** prints a declaration's slots with their traits and every type
as written:

```
struct H name H ns - slots [K satisfies Hashable, V] fields key: K, value: V
    e2 block s3 (b2 h:H[K, V]) captures () declares int : block(e2)/1 -> int
            e5 project key : K
    e8 struct H (key, value) : H[str, int]
```

A variable's constraints are not repeated at each occurrence: reading the
text back derives them from the declarations (`hir::read`'s post-pass), the
one source of truth, so a reader can never see a variable constrained
differently from its constructor. `tc-hir-text` checks that the text, every
expression's type (constraints included) and the outcome survive the round
trip.

**Interchange** (`tc-interchange`, `tc-interchange-fresh-process`): a HIR
written as interchange text and read back -- after a compilation that
declares the same names with other slots and no constraint, and in a fresh
process that runs no front end -- is the HIR written, lowers to the same
artifacts and runs the same on every backend.

**Cache** (`tc-cache`): through the front-end cache a parameterized
program's HIR is the build's; a constraint or a slot order changed in the
source is a miss, never a stale hit. The cache key needed no new input: slots
and constraints are source text.

**Isolation** (`tc-isolation`): a HIR keeps its own parameterized
declarations -- slot count, order, constraint and trait identity -- after
another compilation declares the same names differently. The struct registry
was already captured wholesale by `hir::declarations::capture`; slots and
constraints are part of its entries.

## Diagnostics

| situation | kind | where |
|---|---|---|
| wrong number of type arguments, a bare constructor, arguments to a struct without slots | TYPE | the application |
| an argument that does not satisfy its slot's trait | TRAIT-NOT-SATISFIED | the application (parameter, result, field, construction, explicit imprint, the call whose binding makes it) |
| a field's nested application over a slot that does not state the obligation | TRAIT-NOT-SATISFIED | the field |
| a trait, context trait or affine type as an argument | TRAIT-STORAGE-UNSUPPORTED, CONTEXT-TRAIT-POSITION, TYPE | the application |
| a construction that establishes no single type for a slot | IMPRINT | the construction |
| a variable a constraint would be needed to establish | IMPRINT | the call |
| a bad slot declaration (name, duplicate, unknown trait, a type that is no trait, a context trait, a context struct with slots) | TYPE | the slot |
| `:`, `where`, `requires`, `implements`, `extends` | SYNTAX | the word |
| two traits of one variable declaring the operation | AMBIGUOUS-METHOD-CALL | the call |
| a nested function specialized per binding | TRAIT-NESTED-POLYMORPHIC | the function |

Every diagnostic speaks of slots, applications and traits in source terms,
never of the compiler's machinery (`HashClass`, `Totality`, an intrinsic
witness, an internal id; `tc-diagnostic-vocabulary`). Every one a block can
produce is a recoverable `std::compiler::DiagnosticCode` (`tc-static-compile`);
no new diagnostic kind was added. Applications that hold a poisoned argument
report nothing further.

Compilerpedia documents the feature in `concept.parameterized-structs` and
updates `concept.hashable`, `concept.structs`, `error.imprint` and
`error.trait-not-satisfied`; it presents slots as constrained type positions
of a struct, never as generic function parameters.

## Tests

* `tests/trait-constrained-types.test`, 77 tests: syntax, declarations,
  applications, fields and construction, imprinting (nested functions'
  enclosing variables included), constraint propagation,
  ordinary traits, runtime representation, specialization and the probe,
  HIR text, interchange, the cache, isolation, static compile, vocabulary.
  Every behavioral case runs on interp, compile, cranelift-generic and
  cranelift.
* `tests/golden/trait-constrained-types.bot`, 80 golden tests porting the
  source-observable ones (manifest fragment
  `audit/golden/migration/fragments/trait-constrained-types.tsv`; census
  `audit/golden/migration/census/trait-constrained-types.tsv`). Its three
  rounds of static decisions show no misprediction; a reproducer of its
  diagnostics gives the same outcomes under the batched and the sequential
  scheduler. `audit/golden/tools/perturb.tcl` fails every test (80 inverted,
  79 altered, one not alterable and covered by inversion).
* Tests that pinned the unary grammar were updated: `List[A, A]`,
  `MutableArray[int, str]` and `MutableVector[int, str]` are now arity errors
  (`applied-type-malformed-comma-arity`, ported to types.bot; `mat-syn-4`;
  `mv-type-syntax`), `struct Foo[T]:` parses
  (`bl-syntax-no-generic-struct-declarations`), and UNKNOWN-STRUCT's message
  names parameterized structs (`bl-construction-only-layoutstruct`).

## Fuzzing

`audit/trait-constrained-types/tools/fuzz.tcl` generates programs declaring
one to three parameterized structs of one to three slots, each unconstrained,
`satisfies Hashable` or `satisfies Printable` (a trait of a module with two
witness modules and one non-witness), with fields holding slots bare, in
Lists, in MutableArrays or in applications of earlier structs. It observes
projections, public hashes, trait operations, comparisons and factories on
concrete applications (written and inferred), and probes the rejections.

Its model is independent of the compiler: types are the generator's terms,
bindings are the generator's, and the predicates are its own (Hashable when
every component has total equality and a hash; Printable for the two
witnesses only; a slot variable satisfying exactly its declared trait). It
knows every observation's value and every probe's verdict:
TRAIT-NOT-SATISFIED for an unsatisfied constrained slot (concrete, a variable, a
nested application, a factory's result), TYPE for a wrong arity or a rigid
conflict, IMPRINT for an unestablished slot, and acceptance otherwise.

| run | programs | observations | probes (IMPRINT / TRAIT-NOT-SATISFIED / TYPE / accepted) | failing |
|---|---:|---:|---|---:|
| `-seed 1 -n 30` | 30 | 374 | 308 (3 / 107 / 105 / 93) | 0 |
| `-seed 2 -n 30` | 30 | 374 | 318 (6 / 112 / 107 / 93) | 0 |
| `-seed 17 -n 30` | 30 | 369 | 290 (4 / 97 / 98 / 91) | 0 |
| `-seed 41 -n 30` | 30 | 315 | 291 (5 / 102 / 95 / 89) | 0 |
| `-seed 7 -n 20 -gc-stress 1` | 20 | 240 | 195 (1 / 67 / 69 / 58) | 0 |

Every backend gave the model's value for every observation and the model's
verdict for every probe.

## Mutation testing

`audit/trait-constrained-types/tools/mutate.tcl` applies each mutant of
`audit/trait-constrained-types/tools/mutants.txt` to a private copy of the
tree and runs `tests/trait-constrained-types.test` and the fuzzer (six
programs, seed 3) against it. All 49 mutants -- the 28 the milestone brief
names and 21 more -- apply exactly once and are killed (the run on the
final tree). The table gives the
number of failing tests (and the first ones) and the failing fuzz programs.

| mutant | failing tests | fuzz |
|---|---|---:|
| `constraint-ignored-concrete` | 12: `tc-app-everywhere`, `tc-app-hashable-constraint`, `tc-constraint-any`, ... | 5/6 |
| `constraint-structural-hashable` | 9: `tc-ordinary-ambiguous`, `tc-ordinary-application`, `tc-ordinary-applied-witness`, ... | 6/6 |
| `intrinsic-constraints-rejected` | 49: `tc-app-arity`, `tc-app-distinct-and-invariant`, `tc-app-everywhere`, ... | 6/6 |
| `ordinary-constraints-rejected` | 11: `tc-ordinary-ambiguous`, `tc-ordinary-application`, `tc-ordinary-applied-witness`, ... | 6/6 |
| `callable-admitted-hashable-slot` | 6: `tc-app-everywhere`, `tc-app-hashable-constraint`, `tc-construction-constrained`, ... | 3/6 |
| `any-admitted-hashable-slot` | 3: `tc-app-hashable-constraint`, `tc-constraint-any`, `tc-ordinary-trait-view-into-slot` | 2/6 |
| `constraint-turns-k-into-view` | 56: `tc-app-arity`, `tc-app-distinct-and-invariant`, `tc-app-everywhere`, ... | 6/6 |
| `constraint-erases-k` | 43: `tc-app-show`, `tc-cache`, `tc-constraint-any`, ... | 6/6 |
| `projection-loses-substituted-k` | 38: `tc-app-distinct-and-invariant`, `tc-app-show`, `tc-branches-and-handlers`, ... | 6/6 |
| `mutablearray-field-becomes-any` | 2: `tc-field-substitution`, `tc-typed-storage-probe` | - |
| `result-application-no-obligation` | 6: `tc-constraint-table-hash`, `tc-construction-in-generic-body`, `tc-diagnostic-order`, ... | - |
| `constraint-manufactures-k` | 1: `tc-imprint-not-manufactured` | - |
| `conflicting-imprints-accepted` | 1: `tc-construction-unestablished` | - |
| `nested-application-constraint-ignored` | 2: `tc-app-everywhere`, `tc-decl-concrete-field` | - |
| `enclosing-declaration-hides-obligation` | 2: `tc-decl-nested-composite`, `tc-decl-nested-obligation-required` | 6/6 |
| `arity-ignored` | 2: `tc-app-arity`, `tc-static-compile` | 6/6 |
| `missing-argument-becomes-any` | 2: `tc-app-arity`, `tc-static-compile` | 6/6 |
| `bare-constructor-accepted` | 1: `tc-app-arity` | - |
| `witness-in-type-identity` | 42: `tc-app-everywhere`, `tc-app-hashable-constraint`, `tc-app-show`, ... | 5/6 |
| `witness-in-specialization-key` | 19: `tc-constraint-method-operation`, `tc-constraint-not-a-view`, `tc-constraint-strengthening`, ... | 6/6 |
| `specialization-adopts-rigid-k` | 2: `tc-specialize-instances`, `tc-typed-storage-probe` | - |
| `hir-text-drops-constraint` | 1: `tc-hir-text` | - |
| `hir-read-drops-constraint` | 1: `tc-hir-text` | - |
| `isolation-drops-constraint` | 2: `tc-interchange`, `tc-isolation` | - |
| `cache-confuses-constraints` | 1: `tc-cache` | - |
| `generic-function-binder` | 1: `tc-parse-no-generic-binder` | - |
| `unconstrained-imprints-change` | 3: `tc-constraint-composite`, `tc-constraint-derived`, `tc-ordinary-polymorphic-recursion` | - |
| `hash-of-constrained-k-fallible` | 28: `tc-cache`, `tc-constraint-any`, `tc-constraint-composite`, ... | 4/6 |
| `equality-of-constrained-k-fallible` | 28: `tc-cache`, `tc-constraint-any`, `tc-constraint-composite`, ... | 4/6 |
| `table-hash-rejects-constrained-k` | 1: `tc-constraint-table-hash` | - |
| `constraint-leaks-from-body` | 6: `tc-constraint-equality-total`, `tc-constraint-forgetting`, `tc-constraint-hash-total`, ... | 6/6 |
| `trait-operation-not-specialized` | 7: `tc-ordinary-applied-witness`, `tc-ordinary-monomorphized`, `tc-ordinary-nested-function`, ... | 3/6 |
| `trait-operation-wrong-witness` | 7: `tc-ordinary-applied-witness`, `tc-ordinary-monomorphized`, `tc-ordinary-nested-function`, ... | 3/6 |
| `clone-for-every-obligation` | 1: `tc-ordinary-no-clone-without-operation` | - |
| `ambiguous-operation-picks-first` | 1: `tc-ordinary-ambiguous` | - |
| `applications-covariant` | 1: `tc-app-distinct-and-invariant` | - |
| `inferred-slot-keeps-exact-callable` | 1: `tc-construction-inferred` | - |
| `invalid-construction-not-poison` | 2: `tc-construction-constrained`, `tc-diagnostic-order` | - |
| `construction-unchecked-against-application` | 1: `tc-construction-explicit` | - |
| `nested-imprinted-unchecked` | 1: `tc-ordinary-nested-function` | - |
| `application-argument-cut-early` | 1: `tc-construction-deep-values` | - |
| `nested-application-cut-early` | 1: `tc-construction-deep-values` | - |
| `specialization-keyed-by-every-variable` | 1: `tc-ordinary-polymorphic-recursion` | - |
| `nested-enclosing-variable-own` | 5: `tc-constraint-nested-enclosing`, `tc-hir-text-nested`, `tc-imprint-nested-enclosing-uses`, ... | - |
| `nested-enclosing-bound-in-mixed-parameter` | 1: `tc-imprint-nested-enclosing-uses` | - |
| `nested-enclosing-unestablished` | 4: `tc-constraint-nested-enclosing`, `tc-hir-text-nested`, `tc-imprint-nested-enclosing-uses`, ... | - |
| `nested-enclosing-constraint-own` | 3: `tc-constraint-nested-enclosing`, `tc-hir-text-nested`, `tc-ordinary-nested-enclosing-operation` | - |
| `nested-enclosing-clone-binding-ignored` | 1: `tc-ordinary-nested-enclosing-operation` | - |
| `read-nested-constraints-own` | 1: `tc-hir-text-nested` | - |

## Performance

`bench/trait-constrained-types.tcl` (best of 5 runs, a 4-core container with
one other job running):

**Front end, declarations**: compile time in ms (per declaration in
parentheses).

| declarations | ordinary structs | `struct S[A, B]` | `struct S[A satisfies Hashable, B]` |
|---:|---:|---:|---:|
| 10 | 29 (2.92) | 39 (3.89) | 53 (5.30) |
| 40 | 119 (2.99) | 152 (3.81) | 246 (6.16) |
| 160 | 558 (3.48) | 765 (4.78) | 1125 (7.03) |

**Front end, applications**: compile time in ms of SIZE distinct
applications `Box[Ti]` (per application in parentheses); the NIR struct
shapes of Box and of every struct.

| applications | compile ms, `Box[T]` | compile ms, `Box[T satisfies Hashable]` | Box shapes in NIR | all shapes in NIR |
|---:|---:|---:|---:|---:|
| 10 | 41 (4.11) | 59 (5.95) | 1 | 11 |
| 40 | 171 (4.28) | 232 (5.80) | 1 | 41 |
| 160 | 757 (4.73) | 968 (6.05) | 1 | 161 |

**Run time**: ns per iteration, N = 2000 on the Tcl backends, 200000
natively; allocations natively for N = 1000.

| program | Tcl interp | Tcl compile | Cranelift | Cranelift allocations (N = 1000) |
|---|---:|---:|---:|---:|
| construct and project an ordinary struct | 111776.0 | 11217.5 | 43.5 | 3 |
| construct and project Pair[int, int] | 110945.0 | 10471.0 | 40.1 | 3 |
| hash a field of an ordinary struct | 112234.0 | 21227.0 | 50.1 | 3 |
| hash a field through H[K] (K satisfies Hashable) | 116560.0 | 20842.5 | 46.8 | 3 |

Reading:

* **Front-end cost is approximately linear** in declarations and in
  applications. Over a sixteenfold range the per-declaration time rises by
  about a fifth to a third in all three columns, the ordinary structs'
  included (2.92 to 3.48 ms), so the growth is the front end's, not the
  slots'. Per application it is 4.1 to 4.7 ms unconstrained and a flat
  6.0 ms constrained.
* **Slots and constraints cost the front end a constant per declaration**:
  at 160 declarations a slotted struct and its function cost 1.3 ms more
  than an ordinary one, a constrained one 2.3 ms more again -- resolving
  slot-typed fields, deriving each signature's constraints and validating
  each application by the Hashable predicate. A constrained application
  costs 1.3 to 1.8 ms more than an unconstrained one for the same reason.
* **One runtime shape per constructor** whatever the number of
  applications: 160 applications of Box make one Box shape (the other 160
  shapes are the T1..T160 structs). Specialization (native instances per
  concrete application) is a separate, existing mechanism, reported in
  [Typed-storage probe](#typed-storage-probe).
* **Run time is the same** for an application as for an ordinary struct,
  within the measurement's noise, and hashing a field through a constrained
  K costs what hashing a concrete Int field does: the generated Tcl code of
  the two construction programs is identical, the native instance
  `hashConstrained` for `H[int]` is the same two instructions as
  `hashPlain` for `HInt` (`op hashtotal`, `ret`; the struct passed as its
  field), and natively the allocation counts are equal. The Tcl interpreter's
  absolute numbers are its per-iteration overhead.

## Regression

On the final tree:

* **The full local run** (`tests/local.tcl`: every Tcl test file on interp
  and compile, every golden suite on the four backends through the
  front-end cache) passes: 6,827 Tcl tests on interp and 6,822 on
  compile with none failing (2,184 golden duplicates skipped), and 103
  golden suites, none failing, on every backend (1,985 s with four jobs).
* **Test files** of the areas this touches, run whole: `hir-interchange`
  (11), `hir-cache` (17), `compilation-isolation` (19), `static-economics`
  (87), `static-compile` (83), `diagnostic-recovery` (51),
  `structural-contract-completions` (45), `higher-order-completions` (62),
  `type-predicates` (26), `decimal-rounded` (42), `c-abi-types` (73),
  `method-sugar` (126), `method-filter` (30), `traits` (78), `context-traits`
  (39), `hashable` (48), `applied-types` (51), `structs` (89),
  `mutable-array` (36), `mutable-vector` (67), `golden` (the sample suites
  and this milestone's): all pass.
* **Interchange, cache and isolation audits**: `roundtrip.tcl -via
  interchange` (12 suites, 108 artifacts and outcomes, 0 differ), `-via
  cache` (120, 0 differ), `interleave.tcl` (96, 0 differ).
* **Fuzzers**: traits (seeds 3 and 11, 40 programs each, 0 failures),
  Hashable (30 programs, 0 disagreements), C ABI types (30, 0), decimal
  rounding (38 cases, 0), structural contracts (30, 0), static decisions
  (seeds 17 and 41, 20 programs each, 0 failures).
* **Mutation harnesses**, every mutant applying and killed: traits 20/20,
  context traits 41/41 (its 15 other mutants are macOS' and Windows', skipped
  on this host), Hashable 45/45, C ABI types 26/26, HIR
  interchange 27/27, compilation isolation 14/14, type predicates 14/14,
  structural contracts 18/18, decimal rounding 24/24, diagnostic recovery
  25/25. Two existing mutants were updated because the code they mutate
  changed, each still a mutant of its rule: Hashable's
  `recursive-struct-not-hashable` (the walk's `seen` now holds struct
  types, an application with its arguments) and traits'
  `concrete-method-search` (the trait-call typing first routes a
  constrained variable's receiver).
* **The warning gate** passes; `tools/compilerpedia.tcl check` reports no
  problem.
* The sequential-scheduler comparison of the golden suites runs in CI
  (`static-decisions.yml`), never locally; a small reproducer of this
  milestone's diagnostics (seven blocks: a constraint failure, an arity
  error, an unestablished slot, an accepted trait operation, a nested
  specialized function, a result-only constraint, a non-witness) decides
  identically under both schedulers (3 and 7 rounds).

`audit/hashable/tools/fuzz.tcl` was broken before this milestone: it still
imported its fixture module by the flat name `hashfix` of the time before
STD-NAMESPACE.md, so every program it generated was UNKNOWN-NAMESPACE (30
disagreements in 30 programs), and the Hashable mutation harness, which
runs it as a detector, counted that as a kill. It now imports
`std::hashfix` and reports no disagreement.

Tests that pinned the unary grammar were updated (above), and
`bl-syntax-no-generic-struct-declarations` and
`bl-construction-only-layoutstruct` describe the new boundary.

## Limitations

* **No function-side generics, by design.** No `fn f[K, V]`, no `where` or
  `requires`, no constraint on a function, no constraint written on an
  imprint variable directly. A function is constrained only by the
  applications it mentions.
* **One trait per slot.** `K satisfies A and B` is a syntax error; a
  variable collects several traits only from several constructors.
* **No other parameterized declarations.** Enums, traits, errors, layouts
  and contexts take no slots (a context struct's slots are rejected).
* **No predicates, scalar constraints, higher-kinded types, associated
  types or parameterized traits.**
* **A slot takes only concrete unrestricted types.** No trait view (a
  struct stores one representation), no context trait, no affine type (an
  application holding a coroutine is not yet an affine aggregate).
* **Bare-field establishment is unchanged.** `fn make(key: K, value: V)`
  still establishes nothing from a bare argument; functions establish K
  from `List[K]`, an application or an explicit imprint.
* **Empty constructions need their application** (`Bag[int] {items: []}`),
  as empty Lists need a typed position.
* **Depth.** Applications nest six levels; deeper arguments are `any`, so a
  constrained slot seven applications deep is TRAIT-NOT-SATISFIED (`any`
  satisfies nothing).
* **Nested specialized functions.** A function specialized per binding of a
  source-trait-constrained variable must be top-level, like a
  trait-polymorphic function (TRAIT-NESTED-POLYMORPHIC).
* **Imprinted functions are not values** (unchanged): an imprinted function
  is only called.
* **Context structs holding applications** lower natively by their declared
  field types (a context's representation is the declaration's).

## Map/Set handoff

**Yes.** The language can now express, without erased key storage,

```botlish
struct Map[K satisfies Hashable, V]:
    hashes: MutableArray[int]
    keys: MutableArray[K]
    vals: MutableArray[V]
```

and its operations as ordinary imprinted functions, `fn get(m: Map[K, V],
key: K) -> V errors KeyNotFound`, whose bodies know K is Hashable:

* a key is hashed with the total `hashtotal`, and a standard-library module
  may place it with the private `std::table_hash::of` (`tablehashtotal`);
* stored keys come back from `m.keys` as K, still Hashable, so a probe
  compares with `veqtotal`, and natively with `streq`/`ieq` in String and
  Int instances (CO-3);
* `Map[Fn{...}, int]`, `Map[any, int]` and `Map[MutableArray[int], int]` are
  rejected where they are written.

What the collection milestone still decides: storage layout, insertion
order, deletion, resizing and probing, Map/Set equality and hashing, the
empty Map's construction (an application must be written, `Map[str, int]
{...}`, or imprinted from a result position), and keeping the keyed numbers
unobservable (HASHABLE-AND-KEYED-HASH.md, "Future Map/Set handoff"). No Map
or Set was implemented here; the Table fixture is test material only.

## What to run when changing this

The files:

* `surface/parser.tcl`: `TypeExpr` (n-ary applications), `StructDecl` and
  `TypeSlots`, constructions with an application; `surface/ast.tcl`,
  `surface/lower.tcl` (`StructDeclOf`), `surface/modules.tcl` (`TypeRefs`)
* `hir/structs.tcl`: slots and constraints in the registry,
  `DeclaredSlots`, `AppliedFieldTypes`, `AppliedFieldType`,
  `ApplicationProblem`, `verifyApplications`, `VerifyDeclarations`
* `hir/types.tcl`: `{nstruct ID ARGS}`, `{imprint K TRAITS}`,
  `MakeApplied`, `appliedDepth`, `InferApplication`, `ApplicationProblem`'s
  callers, the constrained-variable case of `Totality`, `StructField`
* `hir/imprint.tcl`: `Match`, `Occurrences`, `Substitute` of applications,
  `Obligations`, `Constrain`, `ConstrainVariables`, `Bind`'s application
  check, `Call`'s poisoned arguments
* `hir/resolve.tcl`: `ResolveApplied`, the block's `Constrain`,
  `ResolveAppliedConstruction`
* `hir/traits.tcl`: `satisfies` of a variable, `TypeImprintCall`,
  `ImprintPolys`/`ImprintPolyBlocks`, the plan's imprint specializations,
  `ImprintCloneLimit`, the nested-function check
* `hir/range.tcl` (`MismatchClause`, struct verification), `hir/specialize.tcl`,
  `hir/callables.tcl`, `hir/decimal.tcl`, `hir/mutvec.tcl`,
  `hir/staticdeps.tcl`, `hir/errordecls.tcl` (`PayloadTypes`),
  `hir/sourcetypes.tcl`
* `hir/format.tcl`, `hir/read.tcl` (slots, applications, the constraint
  post-pass)

AGENTS.md's "Parameterized structs and constrained slots" section has the
commands.
