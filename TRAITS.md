# Traits: eager structural trait views (first milestone)

```botlish
trait Named:
    fn name(value: Named) -> str

struct Person:
    value: str

fn name(value: Person) -> str:
    value.value

fn describe(value: Named) -> str:
    value.name()            # the trait's operation: nothing else of Person

describe(Person {value: "Alice"})          # describe<Person>: calls name directly
describe(services::make_service())         # describe<services::Service>
```

> Traits are eager, one-way static views. Structural conformance determines
> whether a concrete value may enter the view; the view limits source-level
> assumptions to the trait contract; compiler-retained provenance permits
> direct specialization without re-exposing the concrete type.

A **trait** is a nominal, signature-only declaration. A concrete type
**satisfies** it structurally: the namespace that owns the type declares, for
every requirement, a function of that name whose declared signature is
compatible with the requirement's (the trait replaced by the type). There is
no `implements`, and nothing the calling code imports or declares takes part.

A value enters a trait only at a **trait-typed boundary** (a parameter or a
result declared with the trait). Inside, the value is a **trait view**:
source code may use exactly the trait's requirements, as method calls, and
nothing else -- no field, no concrete function, no type test, no cast. The
compiler keeps the view's concrete type as hidden **provenance** (the
*witness*), and **monomorphizes**: every trait-polymorphic function becomes
one ordinary function per combination of witnesses its calls pass, every
trait operation an ordinary direct call of the witness's implementation.

At run time nothing exists: no trait value, wrapper, tag, vtable,
dictionary, witness argument, runtime type test or dynamic dispatch. A trait
view is its witness's value, with its representation and ABI. Every backend
(the Tcl interpreter, the Tcl compiler, native/Cranelift) compiles the
monomorphized program, which contains no trait type and no trait operation.

## Contents

* [Syntax](#syntax)
* [Identity, namespaces and imports](#identity-namespaces-and-imports)
* [Requirements](#requirements)
* [Conformance](#conformance)
* [Trait views](#trait-views)
* [Trait operations and method syntax](#trait-operations-and-method-syntax)
* [Provenance, results and joins](#provenance-results-and-joins)
* [Specialization](#specialization)
* [Lowering and ABI](#lowering-and-abi)
* [Function values, aliases and closures](#function-values-aliases-and-closures)
* [`any`, storage and containers](#any-storage-and-containers)
* [Witness kinds](#witness-kinds)
* [Contexts](#contexts)
* [Diagnostics](#diagnostics)
* [HIR, tooling and APIs](#hir-tooling-and-apis)
* [Evidence](#evidence)
* [Source audit](#source-audit)
* [Tests, fuzzing and mutation testing](#tests-fuzzing-and-mutation-testing)
* [Regression](#regression)
* [Scalar machine-code audit](#scalar-machine-code-audit)
* [Limitations](#limitations)
* [Toward trait-aware contexts and portable path/I/O](#toward-trait-aware-contexts-and-portable-pathio)
* [Milestone report](#milestone-report)

## Syntax

```
topStatement     = typeDecl | structDecl | errorDecl | traitDecl | statement
traitDecl        = "trait" IDENT ":" NEWLINE INDENT traitRequirement
                   { traitRequirement } DEDENT
traitRequirement = "fn" IDENT "(" [ paramList ] ")" [ "->" typeExpr ]
                   [ "errors" IDENT { "," IDENT } ] NEWLINE
```

* `trait` is **contextual**: it starts a declaration only as the first word
  of a top-level statement directly followed by a name (`trait Named:`).
  Two names in a row are never an expression, so `trait = 3`, `trait(x)`,
  `fn f(trait):` and `x.trait` keep their meaning
  (`surface::parser::AtTraitDecl`).
* A declaration is top-level only (a module's or the entry program's): one
  nested in a function is `TRAIT-NESTED`.
* A requirement is a **signature only**: no body and no trailing `:`
  (`TRAIT-REQUIREMENT-BODY`), no modifier (`nomethod`, ...), no flags
  (`TRAIT-REQUIREMENT-FLAGS`), no context parameter
  (`TRAIT-CONTEXT-REQUIREMENT`), no `proves` clause. A trait needs at least
  one requirement (`TRAIT-EMPTY`: a structural trait with none would be
  satisfied by every type).

**AST.** One node, `traitdecl` (surface/ast.tcl): `name`, `nameSpan`,
`requirements` -- each `{name nameSpan params paramsSpan resultType
resultTypeSpan errors span}`, `params` being the function node's own `{NAME
SPAN TYPE TYPESPAN}` tuples and `errors` `{NAME SPAN}` pairs. Like
`structdecl` it has no runtime meaning and binds nothing; the owner (the
declaring module) is supplied by the loader. surface/lower.tcl's
`SplitTypeDecls` hands trait declarations to `hir::buildSyntax` as
`-trait-decls` (`{name nameSpan namespace requirements span}`); the module
loader (surface/modules.tcl) collects every loaded module's.

## Identity, namespaces and imports

* A trait's identity is a namespace member's: `ui::named::Named` for a trait
  declared by lib/ui/named.bot, the bare `Named` for one the entry program
  declares -- exactly like a struct or a refinement. Traits share the type
  namespace: no struct, type, refinement, built-in or second trait of the
  same identity (`TRAIT-NAME-COLLISION`).
* A spelling resolves like any source-defined type
  (`hir::traits::lookup`): a qualified `ui::named::Named` is that member; a
  bare name is the file's own trait, else the trait its `import type` binds
  to that name. `import type ui::named::Named` accepts a trait. A module
  never sees the entry program's traits.
* **Registry** (`hir::traits::registry`, per compilation): `ID -> {id name
  namespace nameSpan span requirements {NAME REQ ...} order {NAME ...}}`,
  each requirement resolved to `{name nameSpan span params {{name type
  self} ...} result {type self} | "" errors {E ...}}` -- `self` marks the
  trait's own type. `hir::traits::declare` registers the names before any
  other type declaration is resolved (so a struct field naming a trait is
  recognized and rejected), `hir::traits::resolve` validates the
  requirements once every type is registered, and the program's HIR keeps
  the result as its `traits` field (what HIR text prints and reads back).

## Requirements

Every requirement is an ordinary function signature over the trait's own
values (`hir::traits::ResolveRequirement`):

* its **first ordinary parameter is the trait itself** (`value: Named`):
  the receiver. No parameter, or a first parameter of another type or
  untyped, is `TRAIT-REQUIREMENT-RECEIVER` -- there are no static or
  constructor requirements;
* the trait's own name may appear **only as the first parameter and as the
  result** (`fn normalize(value: Norm) -> Norm`). Elsewhere it would relate
  two values of one witness -- a relational requirement, unsupported
  (`TRAIT-SELF-POSITION`);
* **no other trait** anywhere in it (`TRAIT-OTHER-TRAIT`: no composition),
  and no trait nested in a parameter or result type;
* further parameters are ordinary types (`fn concat(path: Path, component:
  str) -> Path`), or untyped (any);
* `errors E, ...` names declared errors (`UNDECLARED-ERROR`, `DUPLICATE`),
  as for a function. Two requirements of one name are
  `TRAIT-DUPLICATE-REQUIREMENT` (no overloading).

**The trait's own name inside a requirement** means "the implementing
witness": in the receiver position it is the type being checked, and as the
result it says the operation returns a value of that same witness. For
conformance it is substituted by the candidate type (`fn name(value: Named)
-> str` is, for `Person`, `fn name(Person) -> str`); in a generic body, a
self result is a view with the receiver's own witness.

## Conformance

`Satisfies(T, N)` (`hir::traits::satisfies`), for a concrete type `T` and a
trait `N`:

1. **Owner.** `T` has exactly one canonical owner namespace
   (`WitnessOwner`): a struct's (also opaque or context struct) declaring
   module, or the entry program; a refinement's declaring module; a
   source-defined type's (integer domain) namespace; `str` for the built-in
   String and `char` for UnicodeChar (their intrinsic namespaces). Anything
   else has no owner and satisfies nothing: `any`, `never`, `int`, `bool`,
   a trait view, a value statically known as several nominal types, and
   every applied, container or callable type (`List[...]`, `MutableArray`,
   functions, ...).
2. **Implementation lookup.** For each requirement `R`, the owner's own
   top-level `fn` named `R` -- from an index of every unit's top-level
   definitions by source name, built from the resolved program before any
   check (`hir::traits::index`) -- or, for a built-in owner, the intrinsic
   `owner::R` (`str::length`). Only the owner: no import, no call site, no
   other namespace, no helper the caller declares. A value binding is not an
   implementation. A namespace has at most one binding per name (a second is
   `DUPLICATE`; there are no overload sets), so there is never an ambiguous
   implementation to rank.
3. **Compatibility**, from the implementation's **declared** signature
   (never its inferred contract): `R` with `N` replaced by `T` is a
   structural function type, and the implementation's declared function type
   must be usable as it under the existing structural function compatibility
   (`hir::types::FnMismatch`, STRUCTURAL-FUNCTION-TYPES.md): same arity;
   each parameter **contravariant** under declared-parameter admissibility
   (an implementation taking `int` admits a refinement of `int` or an integer
   domain; an untyped parameter admits anything); the result
   **covariant**; an implementation of a requirement with a result must
   declare one (conformance is decided from declarations). Implementations
   with flags or context parameters are not supported yet.
4. **Error contracts**: the implementation's declared errors must be a
   **subset** of the requirement's. Fewer is fine (including none); one more
   is not. A trait operation is typed with the requirement's error contract,
   so handlers in a generic body are written for the requirement's errors;
   in a specialization the direct call carries the implementation's own.

The result is `{ok 0|1 trait witness owner ownerKind impls {REQ IMPL ...}
reason requirement found}` -- `impls` is the static implementation mapping
(a compile-time table, never materialized). **Cache**: per compilation,
keyed by `{canonical T, trait identity}` (`hir::types::canonical`); the
cache is cleared whenever the index is rebuilt (each build of each
compilation), so the generation is the compilation itself. The answer is a
property of `T`, `N` and the program's declarations: two modules importing
the same type and trait get the same answer and the same mapping.

`hir::traits::explain T N` is `""` when `T` satisfies `N`, else the
`TRAIT-NOT-SATISFIED` explanation, naming the first missing or incompatible
requirement and both locations:

```
model::Thing does not satisfy ui::Named
required:
    fn name(model::Thing) -> str   (declared at ui.bot:3:8)
found:
    fn model::name(model::Thing) -> int   (at model.bot:9:4)
return type int does not satisfy required str
```

## Trait views

Types (hir/types.tcl):

| form | meaning |
|---|---|
| `{trait ID}` | the **constraint**: what an annotation `value: Named` / `-> Named` resolves to |
| `{trait ID W}` | a **view**: a value accepted through that constraint, with hidden witness `W` |

`W` is a concrete canonical type (the exact witness), `{param E I}` (the
abstract witness of parameter `I` of function `E` in its generic analysis)
or `{join W...}` (several witnesses met at a join -- always rejected).
`hir::types::show` prints only the trait: the witness is never
source-visible, in a type or a diagnostic about the value.

The one-way rules:

* **Entering.** Only a trait-typed parameter or result makes a view
  (`hir::traits::Accept`, `EntryView`, `ViewResult`): a concrete type that
  satisfies the trait becomes the view with that witness; a view of the same
  trait passes unchanged (its witness kept); anything else is
  `TRAIT-NOT-SATISFIED`. A view of trait `A` is not accepted as `B`, even
  when `A`'s requirements include `B`'s (no conversion or composition).
* **Subtyping.** A view is a subtype of its own constraint and of `any`,
  nothing else. No concrete type is a subtype of a constraint: lub never
  joins unrelated types to a trait they happen to satisfy.
* **No strengthening.** No source operation recovers the concrete type:
  passing a view to a concrete parameter (even its own witness's) is `TYPE`;
  field access is `TRAIT-VIEW-MISUSE`; a type-test or kind-specific native
  (`string?`, `+`, an `if` condition, a loop bound, a call of the view) is
  `TRAIT-VIEW-MISUSE`; a trait has no runtime membership test.
  `hir::types::narrow` never strengthens a view, even by a fact from a
  rejected test.
* **No delayed duck typing.** A generic body is checked against its
  parameters' traits alone, once: an operation the trait does not declare
  is `TRAIT-UNKNOWN-OPERATION` whatever witness reaches it, and also in a
  function nobody calls.
* **No implicit trait parameter.** An untyped parameter never becomes
  trait-polymorphic: a value passed through it is only its concrete value,
  and forwarding an untyped parameter to a trait parameter requires the
  argument to satisfy the trait as usual (contract inference does not
  derive a trait requirement: `hir/signatures.tcl`'s trait-typed sinks are
  plain flows).

## Trait operations and method syntax

A method call `receiver.op(args)` whose receiver is **statically a view** is
an operation of the receiver's trait (`hir::traits::TypeCall`):

* the operation is the trait's requirement `op`, whatever functions named
  `op` the code can see, imports or declares. There is no fallback to the
  ordinary method search, so no import can make a trait operation
  ambiguous, different or available: `METHOD-SUGAR.md`'s candidate rule is
  not consulted (`hir::TraitCallsDecided` marks such calls decided);
* the call has no target (no dynamic dispatch exists to give it one): its
  callee is typed as the requirement's structural contract for the
  receiver's trait, so arity, argument admissibility and the error contract
  are the ordinary checks of a call through a structural function type; a
  self result is the receiver's own view (same witness);
* a trait operation needs no import of the witness's namespace, and works
  where no function `op` is visible at all (the field-shaped
  `receiver.op` is marked as a trait callee, never a field access);
* trait operations are method syntax only: `op(value)` is an ordinary call
  of whatever `op` is visible.

**Concrete method syntax is unchanged**: `person.name()` on a `Person`
resolves the visible function exactly as before; the trait plays no part.

## Provenance, results and joins

* **Identity returns keep the witness.** `fn same(v: Named) -> Named: v`
  returns, at a call, the argument's own view (`SubstituteResult`): later
  trait operations on the result specialize to the same witness, while the
  result stays source-visible as `Named` (`person_only(same(p))` is `TYPE`).
* **Declared trait results.** A function declaring `-> Named` returns the
  view whose witness is its body's one witness (`ViewResult`): an input
  view's for `same`, the concrete type for `fn make() -> Named: Person
  {...}`. Every exit must yield one witness (`TRAIT-WITNESS-JOIN`, checked
  per exit) and satisfy the trait.
* **Self results of requirements** (`fn normalize(value: Norm) -> Norm`) are
  the receiver's view: `value.normalize().normalize()` stays one witness.
* **Joins.** Two views of one trait meet (an `if`, a `handle`, a loop
  result, a block's exits): the same witness keeps the view; different
  witnesses join to `{join ...}`, rejected as `TRAIT-WITNESS-JOIN` at the
  join -- never erased to `any` and never a trait object. In a generic body
  two parameters' abstract witnesses are different, so `if flag: a else: b`
  is rejected even when every caller passes one type.
* **No implicit trait join.** Two concrete types that both satisfy a trait
  join to their ordinary lub (`any` for unrelated structs), not to the trait.

## Specialization

**Semantic instances** (hir/semantic.tcl, OPPORTUNISTIC-SEMANTIC-INSTANCES.md)
are the specialization mechanism, with one change: a trait parameter's
entry type is the argument's **view** (`EntryView`), so the hidden witness
is a component of the instance key. Two witnesses are two instances; two
calls with one witness share one. A view passed where nothing is declared
is erased to its concrete value at that boundary (`any` for the key). A
call of a trait-polymorphic function always gets its instance (reachable or
not -- its witnesses decide which specialization it is), and past the
per-block or total instance budget it gets the instance keyed by its
witnesses alone (every other parameter at its generic type), at most one
per witness combination.

**Monomorphization** (`hir::traits::monomorphize`, `Plan`). A trait program
is built twice from the same syntax:

1. **Build 1** is the checked source program: views, trait operations,
   every diagnostic. Warnings are computed on it (each source function once).
   A program with any diagnostic stops here.
2. The **plan** walks the live code and, transitively, each instance of each
   trait-polymorphic function, and records: one **clone** per `{function,
   witness tuple}` (the codegen key), named `describe<Person>`,
   `show_pair<Person,services::Service>`; for each trait operation the
   witness's implementation (`satisfies`'s mapping); for each call of a
   trait-polymorphic function the clone it calls; for each declared trait
   result the witness it has. Clones are ordered so each is bound after the
   clones and implementations it calls; a cycle between two different
   clones -- polymorphic recursion across witnesses -- is
   `TRAIT-POLYMORPHIC-RECURSION`; an implementation not yet established
   where its first user is placed is `TRAIT-IMPL-ORDER` (the strict
   reference rule, STRICT-REFERENCE-DETERMINISM.md).
3. **Build 2** resolves the same syntax under the plan: each source
   trait-polymorphic function is dropped and its clones are bound at the
   top level of the unit whose statement first needs them, immediately
   before it; a clone's trait parameters take their witness types (each
   parameter binding records the view it is), a declared trait result its
   witness; every trait operation becomes a direct call of the
   implementation; every call of a trait-polymorphic function a direct call
   of its clone; every other reference the clone makes is resolved to the
   binding the source function's own resolution found (never by lexical
   lookup where the clone is placed), so a clone placed in another unit
   calls exactly what the source function would.

Build 2 is an ordinary program: it is type-checked, analyzed, instanced and
compiled like any other. A diagnostic there is the compiler's, said so ("in
the monomorphized program: ...").

**Recursion.** A recursive trait-polymorphic function specializes once per
witness, each clone calling itself directly. Recursion that changes the
witness tuple (`flip(other_value)`, or swapping two trait parameters of
different witnesses) is rejected (`TRAIT-POLYMORPHIC-RECURSION`): two clones
that need each other cannot both be bound first without `mutual:` groups
(MUTUAL-RECURSION.md, not implemented). Swapping two parameters of one
witness is ordinary self recursion.

## Lowering and ABI

* **Trait calls** lower, in build 2, to `call block(E_impl) args` -- the
  same direct call (HIR `target {block E}` or `{native str::length}`) a
  hand-written concrete call gets. In NIR: `%1 = call <impl id> %0`; in
  Cranelift: `call fnN(...)` through a `colocated` function reference; in
  machine code: `call` with an `R_X86_64_PLT32` relocation to the
  implementation. No `callvalue`, no `call_indirect`.
* **Parameters**: a clone's trait parameter is typed with its witness, so its
  ABI is the witness's -- the same as a concrete parameter of that type
  (`params=1 env=0` for `describe<Person>`). No witness or dictionary
  parameter is added.
* **Results**: a declared trait result is the witness type; returned as the
  concrete function returns it.
* **Backends** read the monomorphized HIR only. The interpreter and the Tcl
  compiler (core IR via `hir::lower`) see ordinary functions and direct
  calls; native/Cranelift (`native::lowered` from HIR) likewise, in both its
  modes: `cranelift-generic` (`-specialize 0`, no native call-site
  specialization) gets its exact witnesses from the same HIR-level clones,
  so no backend needs a generic trait representation or a dynamic fallback. No backend
  file mentions traits. The only trait code below HIR is `hir/lower.tcl`'s
  stand-in for an *unchecked* trait operation (a `-strict 0` build whose
  trait check failed, so no plan exists): a call of the unbound
  `trait-operation#NAME`, which raises `UNBOUND` if run -- never a
  stand-in callee that would run some function.

## Function values, aliases and closures

* **Direct calls and aliases.** A trait-polymorphic function is called
  directly or through an immutable alias (`f = describe`, `g = f`,
  `g(person)` calls `describe<Person>`).
* **Function-value frontier.** It is never a general callable value: passing
  it as an argument, storing it in a container, returning it, or making it
  the value of a body is `TRAIT-POLYMORPHIC-FUNCTION-VALUE`, as is a
  structural function type mentioning a trait (`Fn{args: [Named], ...}`). A
  function value has no place for the compile-time witnesses its calls need,
  and there is no runtime dispatch to supply them.
* **Closures.** A closure in a trait-polymorphic function may capture a view:
  it is part of each clone, its witness fixed there (also a closure that
  escapes the clone as a value: it is an ordinary closure of an ordinary
  function).
* **Top level only.** A trait-polymorphic function must be declared at the
  top level of a module or the entry program (`TRAIT-NESTED-POLYMORPHIC`):
  a nested one's specializations would have to be made per activation of the
  enclosing function.

## `any`, storage and containers

* **`any`.** A view stored where `any` is accepted (`[v, 1]`, an untyped
  parameter, `v == x`) is only its concrete value: no trait metadata, and
  the trait is not recovered from it (`describe(list::at(xs, 0))` is
  `TRAIT-NOT-SATISFIED`: `any` has no owner). Aggregate construction erases
  a view to `any` (`MakeStruct`/`MakeList`/...).
* **Storage.** No trait-typed struct field, container element or function
  type position: `struct Box: value: Named`, `List[Named]`,
  `MutableArray[Named]`, `ImmutableSet[Named]`, `-> List[Named]` are
  `TRAIT-STORAGE-UNSUPPORTED`. A stored trait value would need its witness
  stored beside it -- an existential representation this milestone does not
  have. Heterogeneous trait collections are a separate future feature; no
  ABI commitment is made for them.

## Witness kinds

* **Structs, opaque structs.** The declaring module's functions implement;
  for an opaque struct, conformance is checked against declarations only, so
  the representation stays hidden: a consumer outside the owner can call
  the trait operation, never project a field (`OPAQUE-REPRESENTATION`
  unchanged).
* **Refinements.** A refinement's own owner implements, independently of its
  carrier: `w::Word` (a refinement of `str` with no `length`) does not
  satisfy `trait Measured: fn length(value: Measured) -> int` although `str`
  does -- satisfaction is not inherited through forgetting. Sibling
  refinements are **distinct witnesses**: `show<wa::A>` and `show<wb::B>`
  are two specializations calling different implementations, with one
  representation (the carrier's). A value statically known as two
  refinements has no single witness. Proof minting and satisfaction stay
  separate.
* **Integer domains** (`type Meters = Int in 0..1000`): the declaring
  namespace implements; the domain's range semantics are unchanged.
* **Built-in scalars**: `str` through the `str` intrinsics (`str::length`,
  `str::lowercase`, ...), `UnicodeChar` through `char`. `int` and `bool`
  have no operation namespace and satisfy nothing.
* **Applied, container and callable types** are not witnesses yet (no
  canonical owner): the explanation says so.

## Contexts

Context semantics are unchanged (context struct identity, exact nominal
matching, requirement propagation, install/load, the native context area,
the context function-value frontier). A context struct's *value* may be a
trait witness like any struct. A requirement cannot declare a context
parameter, and an implementation that needs one is not an implementation
("context-dependent implementations are not supported yet"): there are no
context-provided implementations and no selection among installed contexts.
Trait metadata (the registry, the implementation mapping per `{type,
trait}`, the plan's per-operation actions) is kept so such a rule can be
added later without changing the basic theorem.

(Since CONTEXT-TRAITS.md: `context trait` declarations, satisfied by
installed contexts through their owners' functions with one context
parameter, selected statically per top-level call, and monomorphized by the
same plan. Ordinary trait requirements still take no context parameter.)

## Diagnostics

| code | where |
|---|---|
| `TRAIT-NESTED` | a trait declaration inside a function |
| `TRAIT-EMPTY` | a trait without requirements |
| `TRAIT-REQUIREMENT-BODY` / `-FLAGS` / `TRAIT-CONTEXT-REQUIREMENT` | a requirement with a body, flags, a context parameter |
| `TRAIT-REQUIREMENT-RECEIVER` | no receiver, or a first parameter that is not the trait |
| `TRAIT-SELF-POSITION` | the trait's own type in a later parameter |
| `TRAIT-OTHER-TRAIT` | another trait in a requirement |
| `TRAIT-DUPLICATE-REQUIREMENT` | two requirements of one name |
| `TRAIT-NAME-COLLISION` | a trait named like a type, struct, built-in or other trait |
| `TRAIT-NOT-SATISFIED` | an argument or result that does not satisfy the declared trait (with `explain`'s text), a view of another trait |
| `TRAIT-UNKNOWN-OPERATION` | a method call on a view that its trait does not declare |
| `TRAIT-VIEW-MISUSE` | a field of a view, a view as a condition/loop operand/callee, a view to a type test or kind-specific native |
| `TRAIT-WITNESS-JOIN` | different witnesses met at a join or among a trait result's exits |
| `TRAIT-STORAGE-UNSUPPORTED` | a trait in a struct field, container element or applied type |
| `TRAIT-POLYMORPHIC-FUNCTION-VALUE` | a trait-polymorphic function used as a value, a function type mentioning a trait |
| `TRAIT-NESTED-POLYMORPHIC` | a trait-polymorphic function that is not top-level |
| `TRAIT-POLYMORPHIC-RECURSION` | clones of different witnesses calling each other |
| `TRAIT-IMPL-ORDER` | an implementation declared after the code that first needs it |
| `TRAIT-INSTANCE-BUDGET` | a call whose specialization the instance analysis declined (only the nesting limit, now) |
| `TRAIT-INTERNAL` | a plan invariant failed (a compiler bug, never expected) |

Trait diagnostics are promoted ahead of their consequences
(`hir::traits::Promote`); a method call whose receiver is an undeclared
trait operation reports that operation, not `NO-APPLICABLE-METHOD` among the
visible candidates.

## HIR, tooling and APIs

* **HIR text** (hir/format.tcl, hir/read.tcl) keeps the trait declarations
  (`trait ui::named::Named owner ui::named requires name(value:
  ui::named::Named) -> str`), each replaced function's source signature and
  clones (`traitfn describe (value: ui::named::Named) -> str clones
  (describe<Person>, describe<services::Service>)`), each clone's parameter
  views (`block ... (b10 value:Person) ... clone (b10 value:
  ui::named::Named)`) and declared trait result (`traitresult ID`), and each
  trait call's operation and witness (`call block(e13) trait
  ui::named::Named.name witness Person`). A single-file trait program's HIR
  reads back to the same text and runs the same on every backend (module
  programs' HIR text does not round-trip, for every program: a pre-existing
  limitation of HIR text).
* **CLI**: `tclsh9.0 main.tcl -traits FILE` prints the traits, each
  conformance the program uses with its implementation mapping, every
  concrete type the program declares (structs, refinements, integer domains
  of every unit) against every trait -- "does `model::Person` satisfy
  `ui::Named`? through which implementations? if not, why?" -- and each
  trait-polymorphic function's specializations
  (audit/traits/principal/traits.txt).
* **APIs**: `hir::traits::satisfies TYPE TRAIT` and `hir::traits::explain
  TYPE TRAIT` (above); `hir::traits::lookup NAME NS`; `hir::traits::report
  HIR`. The monomorphized HIR's `traitFunctions` records what was replaced;
  `traitSource` keeps the checked source build (what warnings read).

## Evidence

`audit/traits/tools/evidence.tcl` regenerates audit/traits/principal/ from
the principal vertical program (Person, opaque services::Service, `describe`,
and a hand-written `describe_person(value: Person) -> str: value.name()`):

* `hir.txt`: `describe<Person>` and `describe<services::Service>` are
  ordinary blocks whose one call has a block target (`call block(e13) trait
  ui::named::Named.name witness Person`); no trait type remains.
* `nir.txt`, `comparison.txt`: each specialization is `%1 = call <impl> %0;
  ret %1`, `params=1 env=0`; `describe<Person>`'s body is identical to
  `describe_person`'s.
* `clif.txt`: `fn0 = colocated u0:86` ... `v4 = call fn0(v0, v3)`.
* `asm.txt`: `call` + `R_X86_64_PLT32 botlish_fn_3 (name)` in
  `describe<Person>`, `botlish_fn_2 (services::name)` in
  `describe<services::Service>`; no indirect call.
* Machine code bytes: `describe<Person>` 31 = `describe_person` 31.
* Allocations (`native::allocationReport`, 50 calls in a loop): trait 0
  allocations / 0 bytes, concrete 0 / 0.

The same facts are pinned by tests (`trait-principal-nir`,
`trait-machine-code-direct`, `trait-code-quality-identical`,
`trait-allocation-free`, `trait-no-runtime-wrapper`).

## Source audit

No compiler, runtime or backend file implements traits with runtime type
names, dynamic method maps, dictionary structs, hidden function-pointer
arrays, backend-specific trait tags or caller imports:

* `core/`, `compiler/`, `native/*.tcl` and `native/src/` contain no trait
  code (the only `trait` words are Rust's own and a pre-existing comment);
  `trait-source-audit` greps them for vtable/dictionary/tag patterns.
* Trait code lives in surface/ (syntax) and hir/ (types, conformance, the
  plan, resolution of build 2). `hir/lower.tcl`'s unchecked-operation
  stand-in raises `UNBOUND`.
* Conformance reads the owner's declarations only (`Implementation`); the
  call site's imports are never consulted (`trait-imports-do-not-affect-
  satisfaction`, `trait-two-importers-same-answer`, the fuzzer's import and
  caller traps).

## Tests, fuzzing and mutation testing

`tests/traits.test` (75 tests) pins every item above, each behavioral case
on interp, compile, cranelift-generic and cranelift through one HIR
(`sourceAgree`/`moduleAgree`): syntax and contextual `trait`; identity,
`import type`, qualified spellings; requirement restrictions; conformance
(missing, wrong result/parameter/arity, undeclared result, error contracts,
import and two-importer independence, built-in, refinement, domain, opaque,
applied); the principal vertical with HIR, NIR, Cranelift, code-size and
allocation evidence; one-way abstraction (concrete parameters, hidden
methods, fields, type tests, narrowing, implicit trait parameters, unknown
operations and their cascade); provenance and trait returns; joins; two
independent parameters; passing onward; recursion and polymorphic
recursion; the instance-budget fallback; aliases, the function-value
frontier, closures, nested polymorphic functions; storage and `any`;
method-sugar stability; implementation order; unreachable calls; contexts;
the future `Path` shape; HIR text and round trip; the trait-free
monomorphized HIR; unchanged non-trait programs; tooling and the source
audit.

**Fuzzer** (`audit/traits/tools/fuzz.tcl`). Each program is 2-4 traits
(entry program or module `tr`, spelled through `import type` or qualified)
over the requirements `label -> str`, `size -> int`, `length -> int` and
`lowercase -> self`; 2-3 witness modules each owning a struct, opaque
struct, refinement of int or integer domain, plus optionally `str` and an
entry-program struct `Local`, with per-requirement matching or mismatching
owner functions (missing, wrong result, no declared result, an extra
parameter, a receiver declared `int`, which admits int carriers only);
trap functions of a requirement's name in an imported module and in the
entry program itself; consumers (unary, two independent parameters,
recursive, swapped-recursive, identity and requirement-result trait returns,
same-witness joins, joins of two parameters, closures, aliases, calls of
earlier consumers) and a main list of calls with concrete witnesses, returned
views, helpers joining two views or two concrete values, trait operations on
returned views, and aliases. Deliberate defects (a field of a view, an
undeclared operation, a view to a concrete function or another trait's
consumer, an unsatisfying witness, a different-witness join, the one-way
violation in concrete code) are drawn into a share of programs. An
independent oracle (it shares no code with the compiler) models structural
satisfaction from the generated declarations, the one-way rules, witness
joins, the specialization set by name and polymorphic recursion among it,
and evaluates the program. A predicted rejection must be a compile error of
a predicted kind; a predicted acceptance must compile to a trait-free HIR
with exactly the predicted specializations, `hir::traits::satisfies` must
agree with the oracle on every witness × trait, and all four backends must
compute the oracle's value.

Four seeds × 150 programs (`-seed 1..4 -count 150`, `-accept 0.6`, every
backend):

| seed | accepted | specializations | rejected | failures |
|---:|---:|---:|---:|---:|
| 1 | 123 | 385 | 27 | 0 |
| 2 | 120 | 363 | 30 | 0 |
| 3 | 116 | 333 | 34 | 0 |
| 4 | 125 | 344 | 25 | 0 |
| **total** | **484** | **1,425** | **116** | **0** |

The 116 rejections, each of a predicted kind: `TRAIT-NOT-SATISFIED` 69,
`TRAIT-WITNESS-JOIN` 11, `TYPE` (a view to a concrete function) 10,
`TRAIT-UNKNOWN-OPERATION` 9, `TRAIT-VIEW-MISUSE` 9,
`TRAIT-POLYMORPHIC-RECURSION` 8.

What fuzzing found, honestly:

* **A diagnostic cascade** (fixed): `x.lowercase().size()` with `lowercase`
  not a requirement reported `NO-APPLICABLE-METHOD` among the visible `size`
  functions ahead of the `TRAIT-UNKNOWN-OPERATION` that caused it
  (`trait-unknown-operation-is-the-cause`).
* **A false rejection** (fixed): a trait-polymorphic function whose untyped
  parameter sees more than 16 distinct types exhausted the per-block
  instance budget, and a declined call of a trait-polymorphic function has
  no generic fallback, so it was `TRAIT-INSTANCE-BUDGET` with one witness
  (`trait-instance-budget-fallback`; found while reviewing the budget for
  the report, not by the generator).
* **Two pre-existing, non-trait bugs** the generator first tripped over,
  listed under [Limitations](#limitations) and worked around in the
  generator (per-kind type names; trap modules only over struct witnesses).

**Mutation testing** (`audit/traits/tools/mutate.tcl`, mutants in
`mutants.txt`): each mutant is applied to a private copy of the compiler and
run against `tests/traits.test` and the fuzzer (seed 11, 40 programs, all
four backends). A mutant is killed when a test fails, the test file fails to
complete, or the fuzzer reports a failure.

Final run (the milestone's eighteen mutants, in its order):

| # | mutant | the milestone's wording | tests failing | fuzzer failures (of 40) | result |
|---|---|---|---:|---:|---|
| 1 | `every-type-satisfies` | allow every type to satisfy every trait | 12 | 36 | killed |
| 2 | `caller-namespace-implements` | make conformance depend on caller imports (the calling program's function implements) | 3 | 4 | killed |
| 3 | `search-imported-namespaces` | search imported namespaces for implementations | 1 | 9 | killed |
| 4 | `ignore-one-missing` | ignore one missing requirement | 3 | 28 | killed |
| 5 | `ignore-result-mismatch` | ignore implementation result mismatch | 2 | 12 | killed |
| 6 | `collapse-refinement-witnesses` | collapse sibling refinement witnesses by representation | 2 | 13 | killed |
| 7 | `witness-leaks-into-applicability` | let hidden witness leak into ordinary source applicability | 1 | 1 | killed |
| 8 | `strengthen-view` | allow trait -> concrete strengthening | 0 → 1 | 0 | survived, then killed by a new test |
| 9 | `concrete-method-search` | resolve trait method using ordinary concrete method search | 44 | 40 | killed |
| 10 | `forget-witness-onward` | forget witness when passing a trait view to another trait consumer | 5 | 21 | killed |
| 11 | `mix-witnesses-at-join` | mix witnesses at a control-flow join | 1 | 0 | killed |
| 12 | `trait-storage-as-any` | allow trait field storage by pretending it is any | 1 | 0 | killed |
| 13 | `runtime-wrapper` | add a runtime trait wrapper (each trait argument boxed in a closure at the call, unboxed on entry) | 7 | 10 | killed |
| 14 | `indirect-trait-calls` | lower trait calls indirectly (through the requirement's function type) | 7 | 0 | killed |
| 15 | `omit-witness-from-key` | omit witness from specialization key (the semantic instance key) | 13 | 25 | killed |
| 16 | `one-codegen-instance` | treat two different trait implementations as same codegen instance (one clone per function) | 11 | 14 | killed |
| 17 | `break-opacity` | break opaque representation while checking trait (no opacity check in a trait program) | 1 | 0 | killed |
| 18 | `function-value-escape` | allow a trait-polymorphic function to escape as an ordinary Fn | 1 | 0 | killed |

**18 of 18 killed.** Notes, honestly:

* **#8 survived the first run.** `hir::types::narrow`'s refusal to
  strengthen a view was unobservable: every way to obtain a fact about a
  view's value (a type-test native, a proof predicate, whose parameter must
  be the carrier) is itself rejected first, so no accepted program differs.
  It is still the rule, so `trait-view-never-narrowed` now pins it under
  `-strict 0` (the rejected test's outcome must not narrow the view), which
  kills #8. The fuzzer does not.
* **#2 was first killed by tests only**: the generator had no function of a
  requirement's name in the calling program. It now has (entry-program
  traps), and kills #2.
* **#11 varies with the generator**: the first run's fuzzer killed it (2 of
  40); the final generator's 40 programs at seed 11 happen not to include a
  different-witness join that the oracle predicts and the mutant accepts.
  `trait-witness-join-rejected` kills it either way.
* **Killed by one test each** (thin, and outside what the generator
  produces): #12 (storage), #17 (opacity), #18 (function values) -- the
  generator never writes a trait-typed field, an opaque field access or a
  function value. #14 (indirect calls) and #13's call shape are visible
  only in NIR/CLIF/allocation evidence, which the fuzzer does not inspect
  (it checks values, specializations and satisfaction); the evidence tests
  kill both.
* #14 is a working alternative implementation, not a crash: it compiles
  and runs every fuzz program to the right value; only the evidence tests
  (`trait-allocation-free`, `trait-code-quality-identical`,
  `trait-principal-nir`, `trait-machine-code-direct`, the HIR text tests)
  tell it apart. #13 runs most programs correctly too (24 of the 34 the
  oracle accepts at seed 11), and fails to type the rest in the
  monomorphized program (a boxed argument loses its exact type in the
  clone's generic analysis), which is what the fuzzer reports; the same
  evidence tests kill it.

## Regression

Every run below is on a frozen snapshot of this milestone's code (a git
worktree at the commit before the last two documentation/tooling commits,
which change no compiler behavior but the `-traits` report, covered by
`tests/traits.test`), next to a clean baseline worktree at the commit before
the milestone (`e6a871f`), both using the same built native backend (no
Rust source changed). Each suite run has its own `-tmpdir`.

| run | baseline (`e6a871f`) | this milestone |
|---|---|---|
| `CORE_BACKEND=interp tests/all.tcl` (146 files) | 6090 passed, 0 failed | **6165 passed, 0 failed** |
| `CORE_BACKEND=compile tests/all.tcl` | 6086 passed, 4 skipped, 0 failed | **6161 passed, 4 skipped, 0 failed** |
| `tests/native-coverage.tcl` (whole suite on Cranelift) | 6090: native 2428, independent 3535, passed-partial 67, unsupported 60, failed 0 | **6165: native 2456, independent 3582, passed-partial 67, unsupported 60, failed 0** |
| `BOTLISH_NATIVE_GC_STRESS=1 tests/all.tcl` (both backends, as CI's `gc-stress` job) | -- | **interp pass 6165 passed; compile pass 6161 passed, 4 skipped; 0 failed** |
| `cargo test --release` (native/, separate target dir) | -- | **214 passed (183 + 31), 0 failed** |

The 75 new tests are exactly `tests/traits.test`'s (28 run native code, 47
are frontend/HIR-only); every other count, and the unsupported-construct
list of the native coverage report, is unchanged. The suite covers the
milestone's regression list: source-defined types and `import type`,
refinement values and proof predicates/repeatability, opaque structs, method
sugar and METHOD-ELIGIBLE, callable values and structural function types,
semantic instances and imprinting, type joins, errors and completions,
contexts, Bytes/MutableBytes, ABI numerics, range/completion analysis, HIR
samples and round trips, and the native backend's own files.

The other subsystems' fuzzers whose code this milestone touches
(hir/types.tcl, hir/resolve.tcl, hir/semantic.tcl, hir/completions.tcl,
hir/warnings.tcl, the method-call decision in hir/hir.tcl), on the same
snapshot:

| fuzzer | result |
|---|---|
| `audit/refinement-values/tools/fuzz.tcl -seed 1 -count 300` | 300 programs, 235 accepted, 65 rejected, 0 failures |
| `audit/method-eligible/tools/fuzz.tcl` | 300 seeds, 1518 of 1518 predicted round trips, 0 failures, 0 extra warnings |
| `audit/same-failure/tools/fuzz.tcl` | 300 seeds, 0 failures, 0 extra warnings |
| `audit/fixed-arity-list-return/tools/fuzz.tcl` | 300 seeds, 204 of 204 conversions, 0 failures, 0 extra warnings |

After merging `main` (the `str::char_at`/encode_utf8 allocation work, with
Rust runtime changes, so the native backend was rebuilt; then refinement
validators and the `PROVES-NAMING` warning, which touch hir/types.tcl,
hir/resolve.tcl, hir/warnings.tcl, the parser and HIR text), on the merged
tree: `CORE_BACKEND=interp` 6322 passed, 0 failed; `CORE_BACKEND=compile`
6318 passed, 4 skipped, 0 failed; the trait fuzzer (seeds 1-2, 100
programs each) 163 accepted, 37 rejected, 0 failures; the refinement fuzzer
(now with validators, seed 1, 300 programs) and the PROVES-NAMING fuzzer
(300 seeds) 0 failures; every mutant in `mutants.txt` still applies; the
scalar audit (after the first merge) byte-identical to `main`'s corpus.

The runs above are local; CI checks the push to `main`.

## Scalar machine-code audit

`native/generate-scalar-audit.tcl` regenerated the whole corpus
(audit/native-scalar-asm: the canonical bench/*.bot programs and every
examples/stdlib/*.bot program; none declares a trait) at this milestone's
code: **all 39 program files (disassembly and summaries) are byte-identical**
to the committed corpus. The only difference is README.md's provenance lines
(the commit, and the rustc of this environment). After merging `main` (whose
string work regenerated the corpus at `5e0eb7f`), the regeneration was
repeated on the merged tree: again every program file is byte-identical to
`main`'s corpus, and only the provenance lines differ, so the committed
corpus is `main`'s unchanged. Traits do not alter code generation for programs that use
none -- also pinned by `trait-no-traits-unchanged` (such a program is built
once, with no trait metadata).

Trait programs show direct specialized calls: audit/traits/principal/asm.txt
(above), where `describe<Person>` and `describe<services::Service>` each
`call` their implementation through an `R_X86_64_PLT32` relocation, and the
trait specialization has the same machine code size as the hand-written
concrete function.

## Limitations

* **Top-level trait-polymorphic functions only** (`TRAIT-NESTED-POLYMORPHIC`).
* **No polymorphic recursion across witnesses**, including two trait
  parameters of different witnesses swapped by a recursive call; it needs
  mutual binding of clones.
* **No trait-polymorphic function values** (the frontier above); no
  structural function type over a trait.
* **No storage**: trait-typed fields and containers are rejected; there is
  no heterogeneous collection.
* **Witnesses** must have one canonical owner: no applied/container/callable
  witnesses, no `int`/`bool` (no operation namespace), no value statically
  known as several refinements.
* **Implementations** are module-level (or entry-level) `fn` declarations
  with declared signatures; none with flags or context parameters; none
  supplied by an import, a call site or a context; no default methods.
* **Requirements** are unary in the trait (receiver + optional self result);
  no static/constructor, relational, associated or composite requirements;
  no supertraits, marker traits or `implements`.
* **Implementation order**: an implementation must be bound before the
  first statement that needs a clone calling it (`TRAIT-IMPL-ORDER`), the
  ordinary strict reference rule.
* **Specialization** is bounded by the semantic-instance machinery's nesting
  limit (`TRAIT-INSTANCE-BUDGET`), and a trait program is built twice (more
  when method calls must be decided), so compile time grows with the
  program; runtime cost is zero.
* **HIR text** of programs with modules does not round-trip (pre-existing).
* Found while fuzzing, **not trait-specific and not fixed here**: a module
  cannot spell another module's refinement or integer domain qualified
  (`fn f(x: qa::M)` in a module is "unknown type"; structs are fine), and
  the source-type registry of a previous compilation in the same process is
  not reset by one that declares only structs (a later `struct w1::Item`
  collides with an earlier `refined type w1::Item`). The fuzzer works around
  both.

## Toward trait-aware contexts and portable path/I/O

**Before trait-aware contexts** (`context LinuxIO provides IO`):

* a declaration form for a context-provided implementation and its owner;
  conformance that may take an implementation from an *installed* context
  instead of the type's owner, with the exactly-one-applicable rule decided
  statically from the installed contexts (no specificity ranking);
* implementations with context parameters (now rejected) and requirements
  whose operation is supplied by the context, threaded through the existing
  context requirement propagation;
* the plan's trait-operation action extended from "call implementation X" to
  "call X with context C": the specialization key already carries the
  witness, and would carry the chosen context.

**Before portable path/I/O**: the `Path` shape already works
(`trait-future-path-shape`: `concat(path: Path, component: str) -> Path`
specialized to a refined `str` and to a module struct with no erased path
object). Still needed: the path refinements and their validators in the
library, an I/O trait whose operations need a context (above), relational or
multi-value operations (`io::copy`) as context operations rather than trait
methods, and probably trait-polymorphic functions inside modules used across
module boundaries at scale (supported, but only exercised by tests).

## Milestone report

1. **Grammar**: `traitDecl = "trait" IDENT ":" NEWLINE INDENT
   traitRequirement { traitRequirement } DEDENT`; `traitRequirement = "fn"
   IDENT "(" [ paramList ] ")" [ "->" typeExpr ] [ "errors" IDENT { ","
   IDENT } ] NEWLINE` ([Syntax](#syntax)).
2. **Contextual**: yes. A declaration only as the first word of a top-level
   statement directly followed by a name; an ordinary name everywhere else
   (`trait-is-contextual`).
3. **AST**: one `traitdecl` node `{name nameSpan requirements}`, each
   requirement `{name nameSpan params paramsSpan resultType resultTypeSpan
   errors span}` with the function node's own parameter tuples.
4. **Registry**: `hir::traits::registry`, per compilation, `ID -> {id name
   namespace nameSpan span requirements order}` with resolved requirements
   `{name params {{name type self}} result {type self} errors}`; HIR's
   `traits` field is its serializable form.
5. **Identity**: `NS::Name` for a module's trait, the bare name for the
   entry program's -- one namespace member, like a struct or refinement.
6. **Namespaces/imports**: resolved like a source-defined type (qualified
   spelling, own namespace, `import type` binding); `import type` accepts a
   trait; modules never see the entry program's traits; traits share the
   type namespace (`TRAIT-NAME-COLLISION`). Imports never affect
   satisfaction.
7. **Requirement restrictions**: first ordinary parameter is the trait
   (receiver); the trait elsewhere only as the result; no other trait; no
   flags, contexts, proof clause, body or modifier; declared errors only; no
   duplicate names; at least one requirement.
8. **The trait's own name in a requirement** denotes the implementing
   witness: substituted by the candidate type for conformance; a self
   result is a view with the receiver's own witness.
9. **Satisfaction algorithm**: owner namespace of the canonical type; for
   each requirement, the owner's own top-level function (or built-in
   intrinsic) of that name; its declared function type must be usable as
   the requirement's with the trait substituted (arity, contravariant
   parameters, covariant result, declared result, error subset); no flags or
   contexts. All requirements, first failure explained.
10. **Implementation lookup rule**: only the namespace that owns the type
    (struct/refinement/domain declaring module or the entry program;
    `str`/`char` intrinsics for built-ins), from an index of top-level
    declarations by source name built before checking. Never an import, the
    call site, or any other namespace.
11. **Signature compatibility**: the existing structural function
    compatibility (`hir::types::FnMismatch`) on declared signatures:
    same arity; implementation parameters contravariant under
    declared-parameter admissibility (untyped admits anything, `int` admits
    an int refinement/domain); result covariant; an implementation of a
    requirement with a result must declare one.
12. **Error contracts**: implementation errors ⊆ requirement errors (fewer
    or none is fine); a trait operation carries the requirement's contract
    in generic code; an implementation that always fails is not an
    instantiation-time error (`trait-error-contracts`).
13. **Cache key**: `{canonical type, trait identity}`, per compilation (the
    cache is cleared with every index rebuild, i.e. each build).
14. **`hir::traits::satisfies TYPE TRAIT`**: `{ok trait witness owner
    ownerKind impls {REQ IMPL ...} reason requirement found}` -- the static
    implementation mapping when ok.
15. **`hir::traits::explain TYPE TRAIT`**: `""` or the multi-line
    `TRAIT-NOT-SATISFIED` text: "X does not satisfy N", the required
    signature with its location, the found one with its location, the reason.
16. **Source-visible view**: `{trait ID W}` shown as `ID`; only the trait's
    requirements are usable on it.
17. **Hidden witness**: `W` in `{trait ID W}`: a concrete canonical type,
    `{param E I}` (abstract, generic analysis) or `{join ...}` (rejected).
18. **Semantic instance key**: a trait parameter's entry type is the
    argument's view (witness included), so witnesses are key components; a
    trait-polymorphic call always gets an instance, and past the budget the
    witness-only key.
19. **Codegen key**: one clone per `{source function, witness tuple}`
    (`describe<Person>`); the clone is an ordinary function whose own
    native specialization keys are the usual ones.
20. **Trait method rule**: a method call on a receiver statically a view is
    the trait's requirement of that name, typed from the requirement; an
    undeclared name is `TRAIT-UNKNOWN-OPERATION`; candidates visible by name
    take no part.
21. **Concrete method sugar**: unchanged; never consults traits.
22. **Lowering of trait calls**: build 2 rewrites each into a direct call of
    the witness's implementation (`call block(E_impl)` / native target); NIR
    `call <id>`; CLIF `colocated` direct call.
23. **Parameter ABI**: a clone's trait parameter has its witness's type and
    ABI; no extra parameter.
24. **Return ABI**: a declared trait result is the witness type, returned as
    the concrete function returns it.
25. **Same-witness returns**: an identity or self result keeps the witness
    (`SubstituteResult`, `ViewResult`); same-witness joins keep the view.
26. **Different-witness joins**: `TRAIT-WITNESS-JOIN` at the join or among a
    trait result's exits; never erased to `any`.
27. **Independent trait parameters**: each has its own witness;
    `show_pair(person, service)` is one clone `show_pair<Person,services::Service>`.
28. **Recursion**: one clone per witness calling itself directly; recursion
    across witnesses is `TRAIT-POLYMORPHIC-RECURSION`.
29. **Aliases/direct calls**: direct calls and immutable aliases call the
    clone.
30. **Function-value escape**: `TRAIT-POLYMORPHIC-FUNCTION-VALUE` for any
    other use, and for function types mentioning a trait.
31. **Closures**: a closure capturing a view is part of each clone, witness
    fixed there; trait-polymorphic functions must be top-level.
32. **`any`**: a view crossing into `any` is only its concrete value;
    nothing recovers the trait from `any`.
33. **Field/container**: `TRAIT-STORAGE-UNSUPPORTED`.
34. **Opaque structs**: satisfy through the owner's declarations; the
    consumer calls the operation, never the representation.
35. **Refinements**: own owner, not the carrier's; sibling refinements are
    distinct witnesses with one representation; minting and satisfaction
    independent.
36. **Integer domains**: the declaring namespace implements; range
    semantics unchanged.
37. **Applied/container witnesses**: not supported (no canonical owner); the
    explanation says so.
38. **Interpreter**: runs the monomorphized HIR via core IR: ordinary procs
    and direct calls.
39. **Tcl compiler**: same core IR, compiled; nothing trait-specific.
40. **Native**: `native::lowered` from the monomorphized HIR: ordinary
    functions, direct calls, the witness's representation.
41. **HIR evidence**: audit/traits/principal/hir.txt (`call block(e13) trait
    ui::named::Named.name witness Person`), `trait-principal-hir`,
    `trait-mono-hir-trait-free`.
42. **NIR evidence**: nir.txt; `%1 = call <impl> %0; ret %1`, `params=1
    env=0` (`trait-principal-nir`).
43. **CLIF/assembly evidence**: clif.txt (`colocated` + `call fn0`),
    asm.txt (`call` + `R_X86_64_PLT32` to the implementation)
    (`trait-machine-code-direct`).
44. **Allocation evidence**: 0 allocations / 0 bytes for 50 trait calls,
    same as concrete (`trait-allocation-free`).
45. **Concrete vs trait code**: `describe<Person>`'s NIR equals the
    hand-written `describe_person`'s; 31 = 31 machine-code bytes
    (`trait-code-quality-identical`).
46. **Import-independence tests**: `trait-imports-do-not-affect-satisfaction`,
    `trait-method-sugar-import-stable`, `trait-operation-needs-no-import`,
    the fuzzer's import and caller traps.
47. **Module-cache tests**: `trait-two-importers-same-answer` (two importers,
    cached module ASTs, one conformance answer and mapping).
48. **One-way tests**: `trait-one-way-source`, `-hidden-method-unavailable`,
    `-no-delayed-duck-typing`, `-unknown-operation-is-the-cause`,
    `-no-field-access`, `-no-type-test-or-kind-operation`,
    `-view-never-narrowed`, `-no-implicit-trait-parameter`.
49. **Hidden-provenance tests**: `trait-provenance-identity`,
    `-returns-from-requirements`, `-passing-onward`.
50. **Refinement witness identity tests**: `trait-refinement-witness-identity`,
    `-refinement-forgetting-not-satisfaction`.
51. **Opaque witness tests**: `trait-opaque-witness`, the principal tests.
52. **Recursion tests**: `trait-recursion-two-witnesses`,
    `-polymorphic-recursion-rejected`.
53. **Trait-return tests**: `trait-provenance-identity`,
    `-returns-from-requirements`, `-same-witness-join`, `-hir-round-trip`.
54. **Witness-join tests**: `trait-same-witness-join`,
    `-witness-join-rejected`, `-no-implicit-trait-join`.
55. **Function-value frontier tests**: `trait-alias-direct-call`,
    `-function-value-escape`, `-closure-capture`,
    `-nested-polymorphic-rejected`.
56. **Fuzz results**: see [Tests, fuzzing and mutation testing](#tests-fuzzing-and-mutation-testing).
57. **Mutation results**: 18 mutants, 18 killed (one, strengthen-view,
    survived the first run and is killed by `trait-view-never-narrowed`).
58. **Full regression**: see [Regression](#regression).
59. **Scalar machine-code audit**: see [Scalar machine-code audit](#scalar-machine-code-audit).
60. **Remaining limitations**: see [Limitations](#limitations).
61. **Before trait-aware contexts**: context-provided implementations with
    a static exactly-one rule, context-parameter implementations, the plan
    carrying the chosen context ([Toward ...](#toward-trait-aware-contexts-and-portable-pathio)).
62. **Before portable path/I/O**: path refinements and validators in the
    library, an I/O trait over contexts, relational operations as context
    operations; the `Path` shape itself already specializes
    (`trait-future-path-shape`).
