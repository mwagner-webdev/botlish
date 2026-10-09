# ENUMS.md

Enums: named, closed, nominal sums of payload-free cases.

> Botlish enums are closed nominal sums, not disguised integers or maps. A
> payload-free case is a nominal value belonging to exactly one named enum.
> Representation is private, case order carries no public meaning, and the
> compiler retains the closed case declaration structure so payloads and
> exhaustive matching can later extend the same construct rather than create
> a second tagged-union system.

```botlish
enum VehicleType:
    Boat,
    Car,
    Truck,
```

declares exactly these intrinsic facts, and no others:

* `VehicleType` is one nominal type;
* it has exactly three declared cases;
* `VehicleType::Boat`, `VehicleType::Car` and `VehicleType::Truck` are nominal
  values of `VehicleType`, pairwise distinct;
* the values are unrestricted and support ordinary equality and hashing;
* no case has an integer, String or key/value meaning;
* there is no anonymous enum.

The compiler keeps the complete declaration -- the enum's identity and every
case's in declaration order -- so a later milestone can give some cases
named-field payloads and add exhaustive matching on the same construct.

## Contents

* [The principal program](#the-principal-program)
* [What changed, in one page](#what-changed-in-one-page)
* [Report](#report) -- the 49 points of the milestone report, in order
* [Extensibility audit](#extensibility-audit) -- the ten questions
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The principal program

`tests/enums.test`'s `enum-principal-acceptance` runs it on the Tcl
interpreter, the Tcl compiler, Cranelift without and with specialization:

```botlish
import mutable_array
import mutable_vector

enum VehicleType:
    Boat,
    Car,
    Truck,
    Tank,
    Tractor,
    Airplane,

struct Vehicle:
    name: str
    kind: VehicleType

fn same(value):
    value

fn is_land_vehicle(kind: VehicleType) -> bool:
    (kind == VehicleType::Car or
        kind == VehicleType::Truck or
        kind == VehicleType::Tank or
        kind == VehicleType::Tractor)

fn example() -> List[VehicleType] errors IndexNotFound:
    a = VehicleType::Car
    b = same(a)

    vehicle = Vehicle {
        name: "example",
        kind: b,
    }

    array = mutable_array::create(2, vehicle.kind)
    vector = mutable_vector::from_list([
        array.at(0),
        VehicleType::Boat,
    ])

    [
        vector.at(0),
        vector.at(1),
        a,
    ]
```

`example()` is `[VehicleType::Car, VehicleType::Boat, VehicleType::Car]` on
every backend: the three Car values are equal, Boat is unequal to Car, `a`,
`b`, `vehicle`, `array` and `vector` are all unrestricted
(`enum-principal-types`), and the native program allocates the array, the
vector and the result List -- never anything for a case.

Two spellings differ from the brief's text, neither because of enums, both
existing Botlish rules: the multi-line `or` condition is parenthesized
(Botlish has no line continuation outside brackets: a line ending in `or` is
a syntax error for any operands), and `example` declares the `IndexNotFound`
its `MutableVector` reads may raise (a vector's length is not tracked
statically; the same program over Ints needs the same clause). The five
programs the brief says must be rejected are rejected
(`enum-principal-rejections`):

| program | outcome |
|---|---|
| `enum Empty:` | `ENUM-EMPTY` (syntax error at the name) |
| `enum Bad:` with `A,` twice | `TYPE`: duplicate case "A" in enum "Bad" |
| `wants_a(B::Same)` for `fn wants_a(x: A)` | `TYPE`: argument cannot be proven to satisfy A (argument type: B); A is a nominal enum type ... |
| `VehicleType::Unknown` | `UNKNOWN-ENUM-CASE` (its cases listed, the nearest spelling suggested) |
| `VehicleType::Car + 1` | `TYPE`: `+: expected int, got VehicleType::Car` -- ordinary typing (see 25) |

## What changed, in one page

* **Surface.** `enum Name:` is a contextual top-level declaration whose cases
  are one indented, comma-separated list (`surface/parser.tcl`'s `EnumDecl`, an
  `enumdecl` AST node). `Name::Case` is the existing qualified-name primary;
  the module loader (`surface/modules.tcl`) knows which qualifiers are enum
  types visible in a file (`EnumQualifier`) and never treats one as a
  namespace.
* **Declarations.** `hir/enums.tcl` is the registry: identity, the closed case
  set in declaration order (`hir::enums::cases`, EnumCases(E)), and one
  descriptor per case `{name span payload}` with an empty payload. Enum
  declarations ride in the existing `-type-decls` channel as `kind enum`
  entries and are registered first by `hir::sourcetypes::apply`, in the one
  type namespace of structs, traits and source-defined types.
* **Types.** `{enum ID}` is a new nominal form of the HIR type lattice
  (`hir/types.tcl`); `enum` is the broad kind (the runtime kind's name), never
  source-spellable. Subtyping is identity; two different enums join to `any`.
* **Case values.** `Name::Case` resolves (`hir/resolve.tcl`'s
  `ResolveEnumCase`) to a `const` node whose literal is `enum {ID CASE}` and
  whose value is `{enum ID CASE}`: a constant, typed exactly `{enum ID}`, that
  carries both identities through every check, every analysis and both Tcl
  backends.
* **Runtime.** Tcl: the value `{enum ID CASE}`, nominal equality and hashing
  (`core/value.tcl`, `core/hashing.tcl`). Native: one immediate tagged word per
  case (`native/src/runtime/value.rs`), word equality (`enumeq`), and a
  program enum table (`enum N "ID" cases="..."` in NIR, `ProgramInfo::enums`)
  that printing and hashing read names from.
* **Nothing else.** No reflection, no ordinal, no conversion, no ordering, no
  `match`, no payloads; no change to coroutines, affinity of any other type,
  or collections.

## Report

### 1. Grammar

```
enumDecl = "enum" IDENT ":" NEWLINE INDENT enumCase { "," enumCase } [ "," ] DEDENT
enumCase = IDENT
```

One form: the cases are a single comma-separated list inside the indented
block; a newline may follow any comma (one case per line is the idiom) and
the trailing comma is optional (`enum-syntax-comma-list`). Two cases without
a comma between them are a located syntax error
(`enum-syntax-missing-comma`). A case is a bare identifier: a value or alias
(`Foo = 17`, `Foo = Bar`), a payload (`Foo: int`, `Car {seats: int}`) or a
parameter list (`Car(int, bool)`) is a located error naming what does not
exist (`enum-syntax-no-values-or-aliases`). `enum` is a *contextual* word,
like `trait`: a declaration only as the first word of a top-level statement
directly followed by a name, an ordinary identifier everywhere else
(`enum-syntax-contextual-word`: `enum = 3`, a parameter `enum`, a field
`x.enum`). An empty enum is `ENUM-EMPTY`; `enum {A, B}` as a statement, an
expression or a type is `ANONYMOUS-ENUM` (`enum-syntax-anonymous`). Deleting,
duplicating or replacing any token of an enum program never crashes the lexer
or the parser (`enum-syntax-mutation-robustness`).

### 2. Declaration placement

Exactly a struct's: the top level of the entry program or of a module, never
nested in a function, branch or loop (`enum-syntax-top-level-only`). A module
may declare enums (`surface/modules.tcl` admits `enumdecl` at module top
level and records them as `loadedEnums`). No independent enum module system
exists.

### 3. Canonical enum identity

The declaration identity, by the rule of every nominal type: the declared
name for the entry program (`VehicleType`), `namespace::Name` for a module's
(`geo::VehicleType`, `fleet::kinds::VehicleType`). Moving a declaration to
another module changes its identity. It is stored in the registry entry
(`hir::enums::registry`, `id`), in HIR's `sourceTypes` (`kind enum`), in the
type `{enum ID}`, in every case value `{enum ID CASE}`, and natively in the
enum table's `name`.

### 4. Case identity

The pair (enum declaration identity, case declaration). A case's name is
unique within its enum (a duplicate is rejected), so (ID, CASE) identifies
the case declaration; the pair -- never the spelling alone, never a position
-- is what equality, hashing and the type checker compare. `Car` may be a case
of any number of enums and the name of a module-level function at the same
time (`enum-case-and-function-same-spelling`).

### 5. Case-resolution syntax

`Name::Case`, and nothing else (`Case`, `Name.Case`, `Name::Case()` and
`Name::Case {}` are each rejected: `enum-cases-not-injected`,
`enum-case-is-not-a-constructor`). Resolution is type-qualified, not a
namespace lookup: the qualifier is resolved as a *type* -- with the
visibility of any nominal type annotation: the file's own declaration, an
`import type`, or `ns::Name` of an imported namespace (`hir::enums::lookup`)
-- and then the case among that enum's declared cases only. No other type
became a namespace: a struct, trait, source-defined or built-in type as a
qualifier is `NOT-AN-ENUM` (`enum-qualifier-not-an-enum`); a qualifier that
names nothing is `UNKNOWN-NAMESPACE` with a note that no enum of that name is
visible (`enum-qualifier-unknown`); a qualifier that is both a visible enum
and an existing namespace (imported or not: otherwise `enum mutable_array:`
would turn an intrinsic's spelling into a case) is `AMBIGUOUS-QUALIFIER`,
never resolved by precedence. An enum is a type declaration: it may be used
before it is declared, and a type name never collides with a function of the
same name (`enum-declaration-order`). The spelling stays valid when a later milestone gives other cases
payloads: a payload-free case is a value, not a constructor call.

### 6. Import behavior

The existing model, unchanged and with nothing enum-specific added: after
`import geo`, `geo::VehicleType` is the type and `geo::VehicleType::Car` its
case (`enum-module-qualified`); `import type geo::VehicleType` binds the short
name, so `VehicleType::Car` works and denotes the same value
(`enum-module-type-import`); without the import, `geo::VehicleType::Car` is
`MISSING-IMPORT` for `geo`, and a bare `VehicleType::Car` with only `import
geo` is not visible (`enum-module-diagnostics`). An `import type` colliding
with a local enum is the existing `TYPE-IMPORT-COLLISION`. There is no
`import VehicleType::*`.

### 7. Duplicate and empty enum diagnostics

| situation | kind | where |
|---|---|---|
| empty enum | `ENUM-EMPTY` (syntax) | the enum's name |
| duplicate case | `TYPE` | the second declaration of the case |
| a second declaration of the type name (enum, struct, type, trait) | `TYPE` ("type ... is already declared (as an enum/a trait)") | the later declaration |
| an enum named like a built-in type (`int`, `List`, `enum`, ...) | `TYPE` | the name |
| unknown case | `UNKNOWN-ENUM-CASE`, nearest spellings suggested ("did you mean VehicleType::Car?") | the case expression |
| non-enum qualifier | `NOT-AN-ENUM` | the reference |
| wrong enum at a call, result or struct field, or an Int for an enum | `TYPE`, with a clause saying the type is nominal and listing its cases | the argument / value / field |
| bare case, enum type used as a value | `UNBOUND`, hinting the qualified spelling | the name |
| anonymous enum | `ANONYMOUS-ENUM` (syntax) | the word `enum` |

Duplicate enum declarations follow the existing nominal-type rules; there are
no enum-specific shadowing semantics.

### 8. HIR enum type

`{enum ID}` (`hir/types.tcl`, documented in its header). It is `IsSpecific`,
so every pure type function sees it as a nominal form: `subtype` holds only
for the same ID (and `any`), `lub` of two different enums -- or an enum and
anything else -- is `any` (never an anonymous union, never the bare kind:
`enum-type-algebra`, `enum-branch-join`), `narrow` keeps a precise enum,
`kindOf`/`semantic` give the broad kind `enum`, `show` gives the identity.
The broad kind `enum` is the runtime kind's name in `core::type`'s primitives
and is rejected as an annotation (`enum-syntax-bare-kind-not-a-type`).

### 9. HIR case value

A case expression is a `const` node with `literal {enum {ID CASE}}` and
`value {enum ID CASE}` (`enum-hir-case-node`): explicit enough for any
diagnostic and for a later payload extension (both identities are there),
typed exactly `{enum ID}` by `hir::types::ofValue`. Being a constant, it needs
no new HIR node kind: every analysis already handles constants, which is why
no walker had to learn a new node, and why the exact-value machinery decides
comparisons of known cases (33). Nominal identity is never lost before
lowering: the Tcl backends carry the value itself, and native lowering turns
it into a word only after every check (29).

### 10. HIR round-trip

HIR text prints each declaration as `enum ID name NAME ns NS cases C1, C2,
...` (`hir/format.tcl`), first among the declarations, and each case as `eN
const enum {ID CASE} : ID`; `hir/read.tcl` re-registers the declarations
through the same `hir::sourcetypes::apply` pass and parses `ID` as `{enum ID}`.
Format, parse and format again is byte-identical, and the read-back program
runs (`enum-hir-roundtrip`).

### 11. Closed-case metadata

`hir::enums::cases ID` is EnumCases(E): the declared case names in
declaration order, from the registry -- no runtime representation is
consulted. `hir::enums::caseDescriptor ID CASE` is `{name NAME span SPAN
payload {}}`; `hir::enums::hasCase`, `hir::enums::payloadTypes` complete the
compiler-side queries (`enum-cases-query`). HIR's `sourceTypes` keeps the same
case lists, so a serialized program has them. None of this is a source-visible
operation (35, 36).

### 12. Affinity behavior

`hir::types::IsAffine {enum ID}` asks `hir::enums::IsAffine ID`, which is
derived from the case descriptors: affine iff some case's payload field type
is affine. No payload-free case has a field, so every enum of this milestone
is unrestricted -- by that rule, not by being an enum (`enum-type-algebra`,
and the `enum-affine` mutant). `hir::mutvec::MayHoldVector` reads the same
payload types.

### 13. Copying

A case value is an ordinary unrestricted value: `b = a` leaves both usable
(`enum-copies`); no allocation, ownership object or copy-on-write machinery is
involved on any backend.

### 14. Calls

An enum is an ordinary parameter type; admission is `hir::types::subtype`
alone (the declaration), exactly a named struct's
(`hir::range::ProvesValueAcceptedBy`). A case of another enum, an Int or an
`any` value is a `TYPE` error at the argument (`enum-wrong-enum-call-result-field`).

### 15. Returns

A declared enum result is proved the same way (`fn g() -> A: B::Same` is
`TYPE`); undeclared results infer the enum type (`enum-calls-returns`), and a
function whose branches return cases of one enum has that enum's type
(`enum-branch-join`).

### 16. Generic functions

`fn same(x): x` passes a case through on every backend, and its semantic
instance keeps the concrete nominal type: `b = same(a)` is typed
`VehicleType`, `same(Other::Car)` `Other` (`enum-generic-identity`). No
enum-specific dispatch exists. The *codegen* key of an instance reduces an
enum argument to the broad kind `enum` (`hir::specialize::ElementKeyType`'s
kind rule): an instance's code does not depend on which enum it handles --
equality is word equality and printing and hashing read the word's own enum
number -- so `same<VehicleType>` and `same<Other>` share machine code while
their semantic analyses stay separate.

### 17. Struct fields

An enum is an ordinary struct field type, checked at construction like any
declared field; projection and destructuring give an ordinary case value
(`enum-struct-fields`). Natively an enum field is one word in the struct's
slots, and a struct with an enum field is scalar-replaced like any other (32).

### 18. Collections

`List[E]`, `MutableArray[E]`, `MutableVector[E]` and `ImmutableSet[E]` work
with no collection change: construction, iteration (`enum-list`),
membership by equality (`enum-immutable-set`). Each stays unrestricted
(`enum-collections-unrestricted`); `hir::types::IsEqualityTotal` counts enums,
so `ImmutableSet[E]` uses the non-failing set operations natively.

### 19. MutableArray interaction

`mutable_array::create(n, E::X)` repeats the case (an unrestricted value;
the `repeat` role is satisfied), `mutable_array::generate(n, f)` with an
enum-returning factory, `at`, `set` and `swap` all work
(`enum-mutable-array`). An array of cases is unrestricted, so copies are
ordinary copy-on-write logical copies.

### 20. MutableVector interaction

`push`, `pop`, `swap`, `at`, `length` and iteration (`enum-mutable-vector`);
a vector of cases is unrestricted.

### 21. ImmutableSet / hash interaction

`hash` of a case is FNV-1a over a kind tag of its own (11), the enum's
identity text, a `0xFF` separator byte and the case's name -- byte for byte
the same in `core/hashing.tcl` and `rt_hash` (`enum-hash`, and the Rust test
`enum_hash_and_show_read_names_never_numbers`, which pins the same value). It
never reads a position: reordering or adding cases changes no hash
(`enum-hash-reorder-invariant`), and same-spelled cases of different enums
hash differently. `ImmutableSet[E]` deduplicates and answers membership by
nominal equality, a case of another enum never being a member.

### 22. Equality

Nominal: the same enum declaration and the same case. `core::value::equal`
compares both parts of `{enum ID CASE}`; natively a case word is canonical,
so `rt_value_eq` compares words and two operands statically of enum type
lower to `enumeq`, one inline compare (`enum-equality`,
`enum-native-representation`). It never reads a position or a spelling alone.

### 23. Cross-enum rejection

Every *use* of a case of one enum where another enum is declared is a static
`TYPE` error: an argument, a declared result, a struct field, a List element
of a declared `List[A]` (`enum-wrong-enum-call-result-field`). Equality is
different: Botlish's ordinary typing has no static error for `==` of
operands of unrelated types (`Person == Account` is `false`, as is `1 ==
"1"`; STRUCTS.md's `struct-eq-nominal` pins it), and making `==` reject them
would be a new general rule for every type, not an enum feature. So
`VehicleType::Car == TransportKind::Car` is `false` -- because the enum
identities differ, never because of a tag compared by spelling or
discriminant -- on every backend, and the compiler decides it statically when
both sides are known cases (33). Recorded as a limitation (48).

### 24. Ordering rejection

Declaration order is not an ordering. `<`, `<=`, `>`, `>=` are Int natives,
so `VehicleType::Boat < VehicleType::Car` is their ordinary `TYPE` error
(`<: expected int, got VehicleType::Boat`) on every backend
(`enum-ordering-rejected`); natively the compiler knows it statically and
emits a known-error guard. No ordered operation was added.

### 25. Arithmetic rejection

The same ordinary typing: `VehicleType::Car + 1`, `Truck - Boat`, `2 * Truck`
are the natives' `TYPE` errors on every backend (`enum-arithmetic-rejected`).
Botlish's ordinary typing reports a native applied to a statically known
other kind at run time (exactly `"a" + 1`), with a known-error guard
natively; no enum-specific compile-time diagnostic was added for it (see 48).

### 26. Erasure behavior

The existing unrestricted-value rules: a case may enter `any` (an untyped
parameter, `fn erase(x: any) -> any`, a heterogeneous List) and keeps its
identity there -- `erase(Other::Car) == VehicleType::Car` is `false`
(`enum-erasure`). Natively an erased case is the same immediate word, which
already carries the enum's number, so no extra representation is needed.

### 27. Tcl runtime representation

`{enum ID CASE}` (`core/value.tcl`): a tagged Tcl list of the kind, the enum's
declaration identity and the case's name -- both identities, no number
(`enum-runtime-value`). `core::value::enumValue` is its one constructor.

### 28. Tcl compiler lowering

Nothing enum-specific: HIR lowers a case to core IR `(const enum {ID CASE})`
(`enum-core-ir`), and the Tcl compiler compiles a constant as the boxed
literal value, exactly as for a String; equality goes through the shared
`core::value::equal`.

### 29. Native representation

An immediate 64-bit word, `(enum << 32) | (case << 5) | 0b10010`
(`native/src/runtime/value.rs`): the program's dense number of the enum
declaration (bits 32..63) and the case's position in its declaration (bits
5..31). The low five bits `0b10010` are disjoint from a small Int (`...1`), a
UnicodeChar (`...100`), a heap pointer (`...000`) and the constants
`false`/`true`/`unit` (2, 6, 10), so `kind_of` gives the new `Kind::Enum` and
no other kind mistakes it (`enum_words_are_immediates_of_their_own_kind`). The
word is the representation whether the static type is known or the value is
erased: it is already the smallest, and it carries the enum's number. The
numbers are representation only: canonical within one program, never visible
-- printing and hashing read the declared names from the program's enum table
(`ProgramInfo::enums`, NIR's `enum N "ID" cases="..."`), and standalone
executables embed the same table.

### 30. Native lowering

`native/lower.tcl` assigns enum numbers on first use (`EnumIndex`, like
struct shapes) and lowers a case constant to `%r = enum E C`, which Cranelift
emits as one `iconst` (`Inst::Enum`); `==` of two operands statically of enum
kind lowers to `op enumeq` (an inline `icmp`, never failing); an untyped `==`
uses the generic `veq`, whose runtime compares the words. A context struct may
hold an enum: it is an immediate context leaf.

### 31. Allocation behavior

None: a case is never allocated, rooted or traced. A recursive program
threading a struct with an enum field through 100 calls allocates nothing at
all (`enum-native-no-allocation`: 0 allocations), and in
`bench/enums.tcl` every enum program allocates exactly what its Int twin does
(see 47).

### 32. Scalar replacement

A struct with an enum field is scalar-replaced like any other: the field is
one register (`enum-native-no-allocation`'s census: the struct is virtual
across its call and return, no `StructObj`). The `enum-field-forces-boxing`
mutant (no scalar replacement for a struct with an enum field) is killed by
it.

### 33. Constant folding

The exact-value machinery (`hir/exactvalue.tcl`) counts an enum case as a
scalar constant, so a comparison of two known cases is decided: `true` for
the same case, `false` for another case or another enum, without the
discriminant ever appearing (`enum-equality-constant-folded`: the NIR has
`bool true`/`bool false` and no comparison).

### 34. Debug rendering

`ID::CASE` (`VehicleType::Car`, `geo::VehicleType::Boat`), identically on
every backend and in standalone executables (`enum-debug-rendering`). It is
diagnostic output only: there is no inverse parser, and nothing documents it
as a serialization contract.

### 35. Lack of String/Int mappings

None exists: `VehicleType::Car.name()`, `.to_string()`, `.raw_value()`,
`.case_name()`, `.ordinal()` find no field or function (`NOT-A-STRUCT`), and
`VehicleType::from_string(...)`, `VehicleType::from_int(...)` are unknown
cases (`enum-no-intrinsic-mappings`). A mapping is ordinary code (an `if`
chain, or a function the application writes).

### 36. Lack of public ordinal

No operation exposes a case's position or number: no `ordinal`, `raw_value`,
`to_int`, `from_int`, no `enum::cases`/`case_count` (`enum::cases(E)` is an
unknown namespace), no ordering, no hash derived from a position. The numbers
the native word carries are invisible: every observable use reads names.

### 37. Declaration-reordering behavior

Reordering cases -- or adding one -- changes no program-visible behavior:
equality, hashing, set membership and printing are identical
(`enum-reorder-invariant`, `enum-hash-reorder-invariant`). Generated native
code may differ (the case numbers do); semantics does not. Renaming a case is
an API rename: the old name is `UNKNOWN-ENUM-CASE` (`enum-rename-case`).

### 38. Cross-module nominality

`geo::VehicleType` and `fleet::kinds::VehicleType`, declared with the same
text, are unrelated types with unrelated cases: their cases compare unequal,
hash differently, print with their own identities, and one is rejected where
the other is declared (`enum-module-nominal`).

### 39. Fuzzer design and results

`audit/enums/tools/fuzz.tcl`: each program declares two to four enums drawn
from one pool of names, with case lists drawn from one pool of spellings (so
`Red`, `Car`, `On` recur across enums), each declaration's cases shuffled,
and every other program also uses a module's enum (`fz::Mode`, written into a
private library). A driver performs 6..20 operations -- case construction,
copies, a generic identity, erasure to `any`, typed identity functions,
functions returning cases from branches (with explicit, program-stated
mappings, never ordinals), struct fields (projection and destructuring),
Lists (iteration with a filter), MutableArray (create, set, get, iteration),
MutableVector (push, pop, at, length), ImmutableSet membership, closures
capturing a case, the module's enum and function -- and observes values,
`==`, `!=` (often across enums), `hash` equalities and memberships. The model
is independent: a case is the pair (EnumIdentity, CaseIdentity), equality is
equality of the pair, copies keep it, and there is no ownership state. A
third of the programs carry one fault: an unknown case, a value of another
enum passed to a typed function, returned as a declared result, stored in a
typed field or a declared List, a duplicate case, an empty enum, an unknown
qualifier, a struct as a qualifier, a bare case, an anonymous enum, and, at
run time, arithmetic or ordering of cases. Every accepted program is compared
on all four backends; `-gc-stress 1` also runs it natively with a collection
at every allocation site.

Results (final tree; `audit/enums/out/`):

| run | programs | accepted | rejected statically | rejected at run time | disagreements |
|---|---:|---:|---:|---:|---:|
| `-seed 1000 -n 300` | 300 | 204 | 83 | 13 | **0** |
| `-seed 1 -n 80 -gc-stress 1` | 80 | 53 | 25 | 2 | **0** |

The rejections of the seed-1000 run by code: `ANONYMOUS-ENUM` 8, `ENUM-EMPTY`
13, `NOT-AN-ENUM` 9, `TYPE` 38 (wrong enum as an argument, result, field or
element, and duplicate cases), `UNBOUND` 5 (a bare case), `UNKNOWN-ENUM-CASE`
5, `UNKNOWN-NAMESPACE` 5 (an unknown qualifier), and 13 run-time `TYPE` errors
(arithmetic and ordering of cases). Every injected fault was rejected with
the code the model expects: statically by the shared front end, or, for
arithmetic and ordering, at run time on each of the four backends.

### 40. Mutation results

`audit/enums/tools/mutate.tcl` with `mutants.txt`: **26 mutants, 26 killed, 0 survived** (`audit/enums/out/mutate.txt`; the
tests column gives the number of failing tests of `tests/enums.test` and one
of them, the fuzz column how many of 25 fuzz programs disagree, the Rust
column the killing unit test for the four native-runtime mutants):

| mutant | what it breaks | tests | fuzz | Rust |
|---|---|---|---|---|
| `structural-compat` | enum compatibility is structural: an enum is a subtype of another with the same case list | 4 (`enum-module-nominal`, ...) | -- | -- |
| `equal-ignores-enum-tcl` | case equality ignores the enum's identity (Tcl runtimes, and the compiler's decided comparisons) | 8 (`enum-case-and-function-same-spelling`, ...) | 2 of 25 | -- |
| `same-spelled-enums-equal-tcl` | same-spelled cases of same-spelled enums of different modules compare equal (Tcl runtimes) | 1 (`enum-module-nominal`) | -- | -- |
| `same-spelled-enums-share-number-native` | same-spelled enums of different modules share one native enum number | 1 (`enum-module-nominal`) | -- | -- |
| `equal-by-ordinal-tcl` | case equality compares declaration positions, not identities (Tcl runtimes) | 4 (`enum-equality`, ...) | 5 of 25 | -- |
| `resolution-searches-scope` | an unknown case falls back to an ordinary lookup of its name in the surrounding scope | 1 (`enum-unknown-case`) | -- | -- |
| `bare-case-accepted` | a bare case name resolves to the one enum that declares it (cases injected into the scope) | 1 (`enum-cases-not-injected`) | -- | -- |
| `duplicate-case-accepted` | a duplicate case is accepted | 2 (`enum-duplicate-case`, ...) | 1 of 25 | -- |
| `unknown-case-string` | an unknown case falls back to a String of its spelling | 5 (`enum-module-diagnostics`, ...) | -- | -- |
| `unknown-case-int` | an unknown case falls back to an Int (0) | 5 (`enum-module-diagnostics`, ...) | -- | -- |
| `order-comparison` | declaration order exposed as ordering: < and friends compare cases by position (Tcl runtimes) | 1 (`enum-ordering-rejected`) | 2 of 25 | -- |
| `enum-as-int` | a case value is typed as an Int by the type checker | 31 (`enum-arithmetic-rejected`, ...) | 12 of 25 | -- |
| `arithmetic-accepted` | enum arithmetic is accepted: + uses a case's position (Tcl runtimes) | 2 (`enum-arithmetic-rejected`, ...) | -- | -- |
| `cross-enum-parameter` | a case of any enum is accepted for a parameter of another enum | 3 (`enum-module-nominal`, ...) | 4 of 25 | -- |
| `hash-ignores-enum-tcl` | the hash ignores the enum's identity (Tcl runtimes) | 3 (`enum-executable-parity`, ...) | -- | -- |
| `hash-uses-position-tcl` | the hash reads a case's position instead of its name (Tcl runtimes): reordering changes it | 3 (`enum-executable-parity`, ...) | -- | -- |
| `enum-affine` | an enum is accidentally affine | 41 (`enum-arithmetic-rejected`, ...) | 15 of 25 | -- |
| `enum-field-forces-boxing` | a struct with an enum field is never scalar-replaced | 1 (`enum-native-no-allocation`) | -- | -- |
| `enum-heap-allocated` | a case value is heap-allocated (a List built beside every case constant, native) | 1 (`enum-native-no-allocation`) | -- | -- |
| `case-set-lost-format` | the closed case set is lost in HIR text: only the first case is printed | 1 (`enum-hir-roundtrip`) | -- | -- |
| `enum-type-roundtrip-loses-identity` | an enum type read back from HIR text is the bare enum kind | 1 (`enum-hir-roundtrip`) | -- | -- |
| `case-roundtrip-loses-identity` | a case printed in HIR text loses its enum's identity | 1 (`enum-hir-roundtrip`) | -- | -- |
| `equal-ignores-enum-native` | case equality ignores the enum's identity (native runtime equality) | 1 (`enum-immutable-set`) | 4 of 25 | `enum_equality_is_nominal_word_equality` |
| `enumeq-ignores-enum-native` | the inline enum comparison ignores the enum's number (native code) | 2 (`enum-equality`, ...) | 1 of 25 | -- |
| `hash-ignores-enum-native` | the hash ignores the enum's identity (native runtime) | 3 (`enum-executable-parity`, ...) | -- | `enum_hash_and_show_read_names_never_numbers` |
| `hash-uses-position-native` | the hash reads a case's number instead of its name (native runtime): reordering changes it | 3 (`enum-executable-parity`, ...) | -- | `enum_hash_and_show_read_names_never_numbers` |

Every mutant the brief lists is among them: structural compatibility
(`structural-compat`), equality ignoring the enum's identity (Tcl and both
native comparisons), same-spelled enums of different modules compared equal
(Tcl) or sharing a native number, equality and hashing by position, an
unknown case falling back to a scope lookup, a String or an Int, a bare
case accepted, a duplicate case accepted, ordering and arithmetic by
position, a case typed as an Int, a case of another enum accepted for a
parameter, an affine enum, a heap-allocated case, scalar replacement
disabled by an enum field, and the HIR text losing the case set, the enum
type's identity or a case's enum.

### 41. Full regression

*Pending: the final run is in progress.*

### 42. Affine regression

No affine code changed beyond one new case of the affinity query (an enum
is affine exactly when a case's payload is, so never in this milestone).
`audit/affine/tools/fuzz.tcl`: seeds 1 and 2, 30 programs each (23 accepted;
91 and 92 identities whose releases were checked), **0 disagreements**.
`audit/affine/tools/mutate.tcl`: **29 mutants, 29 killed**, every mutant
applying unchanged (`audit/enums/out/regression-fuzz.txt`,
`regression-mutate-affine.txt`). `tests/affine.test`: see 41.

### 43. Coroutine regression

No coroutine code changed (the native runtime's unit tests only gained the
empty enum table in their `ProgramInfo`). `audit/coroutines/tools/fuzz.tcl`: seeds 1 and 2,
50 programs each (36 accepted; early exits releasing coroutines: 74 and 69),
**0 disagreements**. `audit/coroutines/tools/mutate.tcl`: **52 mutants, 52
killed**, every mutant applying unchanged
(`audit/enums/out/regression-mutate-coroutines.txt`). An enum case crosses a
suspension like any immediate value (`enum-coroutine-events`: a coroutine
yields cases and returns one; the resumer receives each unchanged, on every
backend). `tests/coroutines.test`: see 41.

### 44. Collection regression

*Pending: the final run is in progress.*

### 45. Native coverage

*Pending: the final run is in progress.*

### 46. Scalar audit

*Pending: the final run is in progress.*

### 47. Performance

*Pending: the final run is in progress.*

### 48. Remaining limitations

* **Cross-enum equality is `false`, not a static error** (23): Botlish has
  no static rule rejecting `==` of operands of unrelated types; adding one is
  a general typing change for every type (it would change, e.g., struct
  `Person == Account`), left to a later milestone. A provably-false
  comparison of two different enums would be a natural proof-backed warning.
* **Arithmetic and ordering on a case are run-time `TYPE` errors** (24, 25):
  that is how Botlish's ordinary typing treats a native applied to a
  statically known other kind (`"a" + 1`); natively they are known-error
  guards, but there is no compile-time diagnostic.
* **Refinements over an enum carrier are unsupported**
  (`enum-refinement-unsupported`, `REFINEMENT-CARRIER`): a refinement lives on
  the core type lattice as a primitive kind refined by named facts, which
  would lose the enum's nominal identity (a refined enum would be `enum`, any
  enum). Supporting it needs a refinement representation over nominal types;
  enum nominality was not weakened to accommodate it.
* **No `switch` or `match`** exists in Botlish, so neither was extended: the
  closed case set is retained for them (11).
* **Module-qualified case spellings are long** (`fleet::kinds::VehicleType::Car`);
  `import type` gives the short form. No enum-specific import exists, as the
  brief requires.
* **The principal program's** multi-line `or` needs parentheses (Botlish has
  no line continuation), unrelated to enums.
* **HIR text of programs that import modules** does not round-trip (a
  pre-existing limitation of HIR text, independent of enums); module-free
  enum programs do.

### 49. Future payload-extension audit

See the [extensibility audit](#extensibility-audit): the semantic and HIR
model extends; at most the runtime representation gains a heap form for
payload-bearing cases.

## Extensibility audit

1. **Where is enum declaration identity stored?** In the registry entry
   (`hir::enums::registry`, keyed by `id`), in HIR's `sourceTypes` (`kind
   enum`), in the type `{enum ID}`, in every case value `{enum ID CASE}` (and
   its core IR literal), and natively in the program's enum table (the word
   carries its index).
2. **Where is case identity stored?** In the case value's second component
   (`CASE`, the declared name; with ID the pair identifies the declaration),
   in the registry's descriptor `{name span payload}`, and natively as the
   word's case number, which indexes the table's names.
3. **Where is the complete closed case set stored?** In the registry's
   `cases` (EnumCases(E), declaration order) and descriptors, in HIR's
   `sourceTypes` entries and HIR text, and natively in the enum table.
4. **Does any semantic check rely on case ordinal?** No. Resolution looks a
   name up among the declared names; equality, hashing, printing and typing
   use (ID, name); EnumCases' order is used for diagnostics only. The only use
   of a position is native lowering's choice of a word, after every check.
5. **Does any public operation expose a discriminant?** No (36).
6. **Can a case descriptor later acquire named payload fields without
   changing enum identity?** Yes: the descriptor's `payload` is the slot for
   a named-field product (`{FIELD TYPE ...}`, struct-shaped, never a
   positional tuple); identity is the declaration's and the case's name,
   neither of which a payload touches.
7. **Can enum affinity later be derived from payload types?** Yes: it already
   is. `hir::enums::IsAffine` iterates the descriptors' payload field types;
   payload-free descriptors make it unrestricted today.
8. **Can future matching obtain the complete case set without runtime
   reflection?** Yes: `hir::enums::cases` from the type `{enum ID}`, entirely
   at compile time.
9. **Can future match lowering select a case and then reuse ordinary struct
   destructuring for its payload?** Yes: case selection is a comparison of
   (ID, CASE) -- word equality natively -- and a struct-shaped payload is
   destructured by the existing named projection (STRUCT-DESTRUCTURING.md)
   once a payload-bearing case value carries its payload as a struct value.
10. **Would adding payload-bearing cases require replacing the current
    payload-free enum representation rather than extending it?** No. The
    optimized runtime representation may gain additional forms -- a payload
    case needs a heap object (Tcl: `{enum ID CASE PAYLOAD}`; natively a boxed
    form beside the immediate word, which stays the payload-free cases'
    representation) -- but the semantic/HIR enum model extends rather than
    being replaced: the type `{enum ID}`, the registry and descriptors, the
    qualified `Name::Case` spelling of a payload-free case and the nominal
    equality rule all stay.

## Files

* Surface: `surface/parser.tcl` (`AtEnumDecl`, `EnumDecl`, `ANONYMOUS-ENUM`),
  `surface/ast.tcl` (`enumdecl`), `surface/lower.tcl` (`EnumDeclOf`),
  `surface/modules.tcl` (`loadedEnums`, `EnumQualifier`,
  `OtherTypeQualifier`, `NOT-AN-ENUM`, `AMBIGUOUS-QUALIFIER`).
* HIR: `hir/enums.tcl` (new), `hir/types.tcl`, `hir/resolve.tcl`
  (`ResolveEnumCase`, `EnumHint`), `hir/sourcetypes.tcl`, `hir/structs.tcl`,
  `hir/hir.tcl`, `hir/format.tcl`, `hir/read.tcl`, `hir/range.tcl`,
  `hir/exactvalue.tcl`, `hir/modulebinding.tcl`, `hir/mutvec.tcl`,
  `hir/traits.tcl`, `hir/aot.tcl`.
* Core and Tcl backends: `core/value.tcl`, `core/type.tcl`, `core/ir.tcl`,
  `core/hashing.tcl`.
* Native: `native/lower.tcl`, `native/src/runtime/{value,vm,ops,show}.rs`,
  `native/src/nir.rs`, `native/src/codegen/{clif,roots,aot}.rs`,
  `native/src/main.rs` (and `enums: Vec::new()` in the test constructors).
* Tests: `tests/enums.test`; Rust unit tests in `nir.rs` (`enums_and_enum_*`,
  `malformed_enums_are_rejected`) and `runtime/ops.rs` (`enum_*`).
* Audit: `audit/enums/tools/{fuzz.tcl,mutate.tcl,mutants.txt}`.
* Benchmark: `bench/enums.tcl`.
* Docs: this file, README.md (Values, IR forms, Not implemented, Surface
  syntax, native Values), AGENTS.md (Enums).

## What to run when changing this

If you change the enum grammar, `hir/enums.tcl`, the `{enum ID}` cases of
`hir/types.tcl`, case resolution (`hir/resolve.tcl`'s `ResolveEnumCase`, the
module loader's `EnumQualifier`), the HIR text of enums, the Tcl runtime's
enum value, equality or hashing, or the native word, table, `enumeq` or
`rt_hash` case: run `tests/enums.test`, `audit/enums/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/enums/tools/mutate.tcl` (every mutant
in `audit/enums/tools/mutants.txt` must still apply and be killed) and
`cargo test --release --manifest-path native/Cargo.toml --lib enum`.
`bench/enums.tcl` regenerates the performance report.
