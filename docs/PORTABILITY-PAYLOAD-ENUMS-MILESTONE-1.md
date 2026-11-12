# PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md

Payload-bearing enums as ordinary nominal values, without representation
commitments.

> An enum is a closed nominal choice among alternatives. Each alternative may
> carry an ordinary typed value. Its identity, payload, ownership and
> behavior are language semantics; its physical representation is the
> compiler's decision.

```botlish
enum Expression:
    Constant {value: int},
    Parameter,
    Add {left: int, right: int},
    Conditional {condition: int, yes: int, no: int},
    Call {function: int},

fn constant(n: int) -> Expression:
    Expression::Constant {value: n}

a = constant(42)
b = Expression::Add {right: 7, left: 3}
c = Expression::Parameter
[a == constant(42), b == Expression::Add {left: 3, right: 7}, a == c, b]
```

is `[true, true, false, Expression::Add {left: 3, right: 7}]` on the Tcl
interpreter, the Tcl compiler, Cranelift without and with specialization,
and in a standalone executable. The existing `enum` construct was extended:
no second tagged-union construct, no runtime discriminant, no layout, no
`match`.

Evidence is marked by kind throughout: **(inspection)** for what reading
the implementation establishes, **(observed)** for executions in this
session, **(CI)** for GitHub Actions runs, **(projected)** for expectations
not measured.

## Contents

1. [The starting point](#1-the-starting-point)
2. [Syntax](#2-syntax)
3. [Declarations and field-type resolution](#3-declarations-and-field-type-resolution)
4. [Construction: the HIR form](#4-construction-the-hir-form)
5. [Nominal identity, typing and exact-case facts](#5-nominal-identity-typing-and-exact-case-facts)
6. [Equality, hashing and rendering](#6-equality-hashing-and-rendering)
7. [Ownership, cleanup and recursion](#7-ownership-cleanup-and-recursion)
8. [Component analyses](#8-component-analyses)
9. [Runtime representation per backend](#9-runtime-representation-per-backend)
10. [HIR text, interchange and tooling](#10-hir-text-interchange-and-tooling)
11. [Boundaries and other targets](#11-boundaries-and-other-targets)
12. [Diagnostics](#12-diagnostics)
13. [Tests](#13-tests)
14. [The independent model and the fuzzer](#14-the-independent-model-and-the-fuzzer)
15. [Mutation testing](#15-mutation-testing)
16. [Performance and allocations](#16-performance-and-allocations)
17. [Regression results and CI](#17-regression-results-and-ci)
18. [Compatibility with the semantic-instance rollback design](#18-compatibility-with-the-semantic-instance-rollback-design)
19. [Explicitly unsupported, and why](#19-explicitly-unsupported-and-why)
20. [What the exhaustive-match milestone builds on](#20-what-the-exhaustive-match-milestone-builds-on)
21. [Files](#21-files)
22. [What to run when changing this](#22-what-to-run-when-changing-this)

## 1. The starting point

**(inspection)** Three facilities existed:

* **Enums** (ENUMS.md): closed nominal sums of payload-free cases. The
  registry (`hir/enums.tcl`) already kept every case's descriptor
  `{name span payload}` with an empty `payload`, and
  `hir::enums::payloadTypes`/`IsAffine` were written over it; the type is
  `{enum ID}`; a case is a `const` node of the value `{enum ID CASE}`;
  natively an immediate word `(enum << 32) | (case << 5) | 0b10010`, with
  `enumeq` an inline word compare. ENUMS.md's extensibility audit predicted
  exactly what this milestone needed: the descriptor's payload slot, a heap
  form beside the immediate word, case selection as an (ID, CASE)
  comparison.
* **Error payloads** (ERROR-PAYLOADS.md): `fail NAME {field: value}` builds
  an anonymous struct node marked `payloadOf NAME`, checked by the ordinary
  struct construction rules (`hir/resolve.tcl`'s `ResolveStruct`) and
  proven per field (`hir::range::VerifyPayload`); the payload's type is the
  anonymous struct of the declared fields (`hir::errordecls::payloadType`);
  field types resolve once every type is registered (`resolvePayloads`).
  This milestone reuses that machinery -- the same struct node, the same
  checks, the same deferred resolution -- for enum payloads. An error stays
  an exceptional completion: no enum case is usable with `fail` or `on`,
  and no error identity is an enum value.
* **Union layouts** (LAYOUT-UNIONS.md): explicit overlapping storage with a
  declared size and alignment. Nothing of it is used: a payload-bearing
  enum has no size, alignment, offset or discriminant position, and no
  diagnostic or document suggests one.

## 2. Syntax

```
enumDecl     = "enum" IDENT ":" NEWLINE INDENT enumCase { "," enumCase } [ "," ] DEDENT
enumCase     = IDENT [ "{" payloadField { sep payloadField } [ "," ] "}" ]
payloadField = IDENT ":" typeExpr          (sep: "," or a line break)
```

A payload is a named-field product in braces after the case name, on one
line (`Add {left: int, right: int},`) or several (fields separated by
commas or line breaks, as a scalar refinement's parameters are). A
construction is the struct construction syntax with the case as its
qualified type: `Expression::Add {left: 3, right: 7}`, any field order,
any line layout the struct syntax allows.

**Alternatives considered.**

* *Indented field lines* (`Add:` then `left: int` lines, as a struct or an
  error payload declares fields): it breaks the one comma-separated case
  list ENUMS.md established and makes a mixed enum read like several
  declarations. Braces keep every case one list item.
* *Positional payloads* (`Add(int, int)`), *tuple payloads*, *case-assigned
  integers*, *anonymous sums*: excluded by the brief; each stays a located
  error (`Car(int)`: "a payload has named fields, never positional ones";
  `Car: int`; `Foo = 17`).
* *A constructor-function spelling* (`Expression::Constant(42)`): a case is
  not a function; `Expression::Constant(42)` is ENUM-PAYLOAD-REQUIRED (the
  case written without its payload), and a payload-free case called is the
  existing NOT-CALLABLE.

A payload-free case remains a value (`Expression::Parameter`), never a
zero-argument constructor; `Expression::Parameter {}` is
ENUM-PAYLOAD-UNEXPECTED, and a payload-bearing case written alone is
ENUM-PAYLOAD-REQUIRED -- no default payload exists. The parser
(`surface/parser.tcl`'s `EnumPayload`) rejects an empty payload, a missing
type, a default, a rest field and two fields on one line without a comma;
duplicate field names are the registry's (DUPLICATE-FIELD). Deleting,
duplicating or replacing any token of a payload enum program never crashes
the lexer, parser or compiler (`pe-syntax-mutation-robustness`, every token
of a program, five replacements each).

The module loader (`surface/modules.tcl`) walks payload field types for
qualified references like a struct field's, accepts `Q::C {...}` when Q is
an enum visible in the file (the `value` rule of `Q::C` now covers the
`struct` reference kind too; the loader's old NOT-A-STRUCT for braces after
a case is gone), and reports `ns::Enum::Case {...}` without `import ns` as
MISSING-IMPORT.

## 3. Declarations and field-type resolution

**(inspection)** `hir::enums::apply` (run before any other type is
registered, so a struct field may name an enum) records a payload-bearing
case's descriptor with `hasPayload 1`, its fields' raw type expressions and
spans, and checks duplicate field names. `hir::enums::resolvePayloads` runs
in `hir::BuildOnce` right after the error payloads' -- once every struct,
domain, refinement, layout and enum is registered -- and resolves each
field type in the declaring module's namespace with the very resolver
struct fields and error payloads use (`hir::resolve::ResolveTypeExpr`),
rejecting a trait type (TRAIT-STORAGE-UNSUPPORTED) and a context trait
(CONTEXT-TRAIT-POSITION) as error payloads do. So a payload field may name
a type declared later, the case's own enum (`Branch {children:
List[Tree]}`), a struct that names the enum back, a module's type through
an import, an integer domain, a function type or a coroutine type. The
resolved fields go into the descriptor and into HIR's `sourceTypes` entry
of the enum as `payloads {CASE {FIELD TYPE ...} ...}` (absent for a
payload-free enum, whose HIR is unchanged byte for byte:
`pe-payload-free-unchanged`).

`hir::structs::VerifyDeclarations` holds payload field types to the
applications rule (a constrained slot satisfied: TRAIT-NOT-SATISFIED) and
then runs the recursive-affine check (section 7).

**Registry consumers that assumed empty payloads** were found by reading
every `hir::enums::` use and every analysis that answers for a value from
its components; section 8 lists what each now reads.

## 4. Construction: the HIR form

**(inspection)** `hir::resolve::Expr` rewrites a `struct` syntax node whose
type is `Q::C`, Q an enum visible in the code's namespace
(`hir::enums::lookup`, the visibility of a case qualifier), into the call

```
enum#case(PAYLOAD, "ID", "CASE")
```

before resolving it (`CaseConstruction`). PAYLOAD is the anonymous struct of
the written field initializers, marked `casePayloadOf {ID CASE}`; the two
names are String constants the front end synthesized (marked
`synthesized`, so ONE-CHAR-STRING-LITERAL never reads them;
`oc-synthesized-string-consts-enumerated` lists the two new sites).
`enum#case` is an internal root native (`core/enums.tcl`; `#` makes it
unspellable in source): `-param-types {struct str str}`, `-ownership {move
erase erase}` (the payload moves into the value), `-result-shape {enum-case
1}`, context-free, never failing.

Why a call and not a new HIR node kind: every analysis, walker, census and
backend already handles calls and anonymous struct constructions -- the
written-order evaluation of fields, the pending-temporary release of
already-evaluated affine fields when a later one fails, escape analysis,
the depth-safe guards, the static decisions -- so the construction inherits
all of it. A node kind would have touched some fifty kind switches.

`ResolveStruct` checks a `casePayloadOf` struct exactly as it checks an
error payload: an unknown case is UNKNOWN-ENUM-CASE at the case, a
payload-free case given braces ENUM-PAYLOAD-UNEXPECTED, a missing field
MISSING-FIELD, an undeclared one UNKNOWN-FIELD, a repeated one
DUPLICATE-FIELD (named "the payload of case E::C"). The struct's type is
the case's declared payload type (`hir::enums::payloadType`: the anonymous
struct of the declared fields, sorted); `hir::range::VerifyCasePayload`
proves each field value admissible for its declared type with the ordinary
`ProvesValueAcceptedBy`, so an Int outside a domain, a String for an Int, a
struct of another declaration, a List of the wrong element type and a
function of another contract are TYPE errors (`pe-field-contracts-checked`).
The payload's callable contracts are preserved: the call's argument context
for the payload is its own declared type (`hir::callables::ArgContexts`'
`enum-case`), and the enum bears what its payloads bear (section 8).

Because the payload is an anonymous struct with a sorted layout, the field
*construction* order is evaluation order only: `E::Add {right: 7, left: 3}`
evaluates `7` first and makes the same value as `E::Add {left: 3, right:
7}` (`pe-written-order`: the first failing field's error is the
construction's, on every backend).

## 5. Nominal identity, typing and exact-case facts

**(inspection, observed)** `hir::types::ShapeResult`'s `enum-case` reads the
two constants and gives `{enum ID}` -- the enum's type, never a case type
or the payload's -- or `any` for an invalid construction, which the call's
typing then poisons (diagnosed at resolution). So a construction flows as
an enum value through bindings, parameters, declared and inferred results,
`if` joins (two cases of one enum join to the enum; two enums still to
`any`), struct fields, Lists, MutableArrays, MutableVectors, closures,
coroutine yields and generic helpers with semantic instances
(`pe-construction-types`, `pe-transport`, `pe-nested-data`,
`pe-affine-coroutine`). Admission of an enum value at a typed position is
the unchanged nominal rule (`pe-nominal-rejections`).

**Exact-case facts.** `hir::enums::caseFact HIR E` gives `{ID CASE}` when
E is known to be a value of that case -- a case constant, an `enum#case`
construction whatever its payload, or a read of an immutable binding bound
to one, through aliases -- else "" (`pe-exact-case-facts`). It reuses no
new flow framework: it is a syntactic query over the HIR the later matcher
can use to decide a selection statically or report an unreachable arm. The
exact-value machinery (`hir/exactvalue.tcl`) is unchanged: it never folds
`enum#case` (no registered fold), so a payload-bearing value is never a
compile-time constant and no constant of it ever reaches a backend.

## 6. Equality, hashing and rendering

**(inspection, observed)**

* **Equality**: the same enum identity, the same case, and -- for a
  payload-bearing case -- equal payloads under the ordinary value equality
  (field by field, by name). Another case with identical field values,
  another enum with identical spelling and fields, and a payload-free case
  are unequal (`pe-identity-equality`, also two cases with identical field
  names). Tcl: `core::value::equal`'s enum case compares the identity first,
  then the payloads. Native: `equal`'s `Kind::Enum` compares the words, then
  the (enum, case) numbers of either form (`enum_case_parts`), then the
  payloads -- never addresses. A payload holding a function is refused at
  run time exactly as a struct holding one is (EQUALITY), and statically a
  value bearing a typed callable is no `==` operand, as for a struct
  (`pe-field-kinds`).
* **Hashing**: the payload-free form's canonical input (kind tag, enum
  identity text, 0xFF, case name) extended, for a payload-bearing case, by a
  second 0xFF and the payload as a nested value (core/hashing.tcl,
  runtime/ops.rs's walk, both folds: the public FNV hash and the keyed table
  hash). A payload-free case's hash is unchanged; field order takes no part;
  the case and the enum do. The byte after a case's name is 0xFF or the next
  value's kind tag (at most 12), so the table hash's input stays prefix-free.
  `pe-hash-pinned` pins three values on every backend, and the Rust test
  `enum_case_objects_hash_and_show_by_names` pins the same values
  natively.
* **Affine values**: AFFINE-EQUALITY-UNSUPPORTED is unchanged and applies to
  an enum whose payloads make it affine (`pe-affine-moves`).
* **Rendering** (debug only): `Expression::Add {left: 3, right: 7}` -- the
  qualified case, then the payload as an anonymous struct renders (fields
  sorted), identically on every backend and in executables
  (`pe-debug-rendering`, `pe-executable-parity`). No discriminant or address
  ever appears.

## 7. Ownership, cleanup and recursion

**(inspection, observed)**

* **Affinity** is `hir::enums::IsAffine`, unchanged in rule: affine iff some
  case's payload field type is affine -- now with real payloads. A
  payload-free case of an affine enum is an affine value too (its static
  type decides: `a = Job::Idle; b = a; c = a` is USE-AFTER-MOVE), as the
  brief requires. A struct and an enum that hold each other are decided by
  the struct affinity summary's fixpoint, which walks the enum afresh in
  every round (`pe-recursive-through-struct`).
* **Moves**: the payload struct moves its affine fields in, and enum#case's
  `move` role moves the payload into the value; the value then moves through
  bindings, arguments and results by the ordinary discipline; erasure to
  `any` is AFFINE-ERASURE-UNSUPPORTED (`pe-affine-moves`).
* **Release**: `hir::affine::Descriptor` gives an affine enum the
  descriptor `e N . (K . HEX D)*`: for each case whose payload owns
  something affine, the case's name as its UTF-8 bytes in K lowercase hex
  digits, then the payload's (an anonymous struct's) descriptor. The
  runtime reads its value's own case: Tcl `core::affine::Drop` matches the
  name, native `drop_by`'s `e` arm compares the hex name with the program's
  enum table; a payload-free value owns nothing. Names, never positions,
  and hex because `hir::affine::Scoped`, `Acquisition` and both backends
  read the letters `r` and `C` anywhere in a descriptor as "a release that
  runs code": a case named `Circle` spelled plainly would have made every
  binding of the enum lexically scoped. `pe-affine-descriptor` pins the
  form; `pe-affine-releases` and `pe-affine-partial-construction` count the
  coroutines released (Tcl live-coroutine probe, native counters, the
  interpreter's release order): a value releases what its own case's payload
  owns, once; a construction failing at a later field releases the fields it
  had evaluated (the existing pending-temporary path), exactly once, on
  every backend.
* **Dynamic logical copies**: an enum value holding a MutableVector or
  MutableArray in its payload is copied by the copy convention's dynamic
  share (`d`), which now rebuilds a payload-bearing case's value around its
  payload's copy (`core/mutvec.tcl`'s `Share`, `runtime/mutvec.rs`'s
  `share_dynamic`). No program of this milestone can observe it (a payload
  is not readable), which is why no mutant guards it (section 15).
* **Recursion**: an *unrestricted* recursive enum (through a List, a
  struct or its own payload) is an ordinary type with finite values of every
  depth: constructed, compared and hashed on every backend
  (`pe-recursive-enum`: a 50-deep chain, a binary tree). An *affine* enum
  whose values can own a value of itself has no finite drop descriptor --
  `enum L: Nil, Cons {head: C, tail: L}` holds lists of every length -- so
  it is AFFINE-CONTAINER-UNSUPPORTED at its declaration
  (`hir::enums::VerifyRecursion`), with the path back
  (`pe-recursive-affine-rejected`: directly, through a List, through a
  struct, through another enum). The decision is a reachability question
  on the finite graph of enum declarations (`OwnedEnums`: the drop
  descriptor's edges -- applied struct fields, anonymous struct fields,
  List/MutableVector/MutableArray/ImmutableSet elements, a refinement's
  base; never a pointee or a function signature); a struct met again inside
  itself is answered by its arguments, so the walk is finite whatever
  applications substitution makes, and no depth or budget decides anything.
  An enum crossing counts as a container crossing (another case may end the
  nesting), which is the conservative reading: an affine enum on any cycle
  is rejected. `hir/ownership.tcl` keeps treating an enum as a leaf; a cycle
  through an enum is this check's.

## 8. Component analyses

**(inspection)** Every analysis that answers for a value from its
components now walks an enum's payload field types, an enum met again
inside itself adding nothing (the least answer):

| analysis | file | payload enum's answer |
|---|---|---|
| affinity | hir/enums.tcl `IsAffine` | any payload field affine |
| Totality (Equatable, Hashable) | hir/types.tcl | Components over every payload field, named "field "f" of case E::C" |
| Sendable | hir/types.tcl `SendClass` | **none** for any enum with a payload-bearing case (no transfer encoding yet, section 19) |
| MentionsMutable | hir/types.tcl | any payload field |
| MayHoldVector | hir/mutvec.tcl | (already read `payloadTypes`) |
| Bearing, CarriedInto | hir/callables.tcl | any payload field; struct summary nodes start a walk of their own (`FreshWalk`) |
| CanCarry | hir/staticdeps.tcl | any payload field |
| MutableComponent | hir/structs.tcl | the first payload field holding one |
| DecimalRounded guard | hir/decimal.tcl `Mentions` | any payload field |
| PRIVATE-TYPE-ESCAPE | hir/privacy.tcl | a public enum's payload field of a private type |
| applications | hir/structs.tcl `VerifyDeclarations` | each payload field type |

The walks pass their `seen` (or a per-walk visiting stack) through
enums, and a struct summary's node always starts a fresh walk, so a
summary never records an enum's provisional answer: a struct and an enum
that name each other are decided by the struct summary's own least
fixpoint, which re-walks the enum in every round (`pe-recursive-through-
struct`: S holds E, E holds S and a function; both are not Hashable,
whichever is asked first).

## 9. Runtime representation per backend

**(inspection, observed)**

* **Tcl interpreter and Tcl compiler**: `{enum ID CASE PAYLOAD}`
  (`core::value::enumCaseValue`), the payload-free `{enum ID CASE}` with the
  payload (an anonymous struct value) as a fourth component -- the identity
  stays the first two components, so no code reading the identity changed,
  and a payload-free case keeps its form. `core/enums.tcl` implements
  `enum#case`; the Tcl compiler compiles the call like any native call.
* **Native (Cranelift, generic and specialized; executables)**: a
  payload-free case stays the immediate word -- also in an enum with
  payload-bearing cases, and natively never allocated. A payload-bearing
  value is one heap object, `EnumCaseObj {hdr, index: u32, case: u32,
  payload}` of the new heap kind `KIND_ENUMCASE`, whose semantic kind is
  `Kind::Enum` like the word's. It is made by `op enumcase PAYLOAD E C`
  (`rt_enum_case`: one allocation, a GC safepoint whose operands are
  rooted), traced (its payload), sized, freed, counted (`EnumCase` in the
  allocation report, only for a program that makes one, so every other
  program's report is unchanged), compared, hashed, printed and transported
  to the host as `{enum ID CASE PAYLOAD}`. The (enum, case) numbers are
  representation only, as the word's are: every observable use reads the
  enum table's names.
* **Lowering**: `native::lower::EnumCaseValue` emits the op (the two
  name constants read statically); `==` uses `enumeq` only when both
  operands are statically of payload-free enums (`ImmediateEnum`, i.e.
  `hir::enums::IsPayloadFree`), else the structural `veq`/`veqtotal`
  (`pe-native-representation`); a semantic instance's codegen key keeps a
  payload enum's identity (`hir::specialize::ElementKeyType`), as a named
  struct's, while a payload-free enum still reduces to the broad kind
  (`pe-specialization-keys`); a context struct's member of a payload enum
  is no immediate leaf (CONTEXT-NATIVE-LOWERING-UNSUPPORTED with the
  reason); `hir/aot.tcl`'s runtime-requirement analysis drops the
  structural-equality requirement only for payload-free enums.
* **Why a separate payload object**: the payload is an ordinary anonymous
  struct value on every backend, so equality, hashing, rendering, tracing,
  copying and dropping reuse the struct paths unchanged, and the matching
  milestone can hand the payload to struct destructuring as it is. The cost
  is a second allocation per construction (section 16); an inline-fields
  form is a representation change no semantic rule depends on (section 20).

## 10. HIR text, interchange and tooling

**(inspection, observed)** HIR text prints, after every declaration a
payload type may name (after the error lines), one line per payload-bearing
case -- `enumcase ID CASE payload F1: T1, F2: T2` -- and a payload
construction as `struct casepayload(ID#CASE) (FIELDS)`. `hir/read.tcl`'s
`EnumPayloads` re-registers the fields (`hir::enums::setPayload`) and
rewrites the text's `sourceTypes`; format, read and format again is
identical, and the text read back runs on every backend
(`pe-hir-roundtrip`, with a struct and an enum naming each other). The
enum line itself is unchanged, so a payload-free program's text is
byte-identical. Interchange carries the HIR dict and the declaration
registries (`hir/declarations.tcl` captures `hir::enums::registry`
whole), so payload schemas survive a write and a read with no build
(`pe-interchange`). No case number is part of either format.

Tooling: Compilerpedia's `concept.enums` describes payloads, with an
accepted example; `error.enum-payload-required` and
`error.enum-payload-unexpected` are new topics with rejected examples;
`error.not-a-struct` no longer claims braces after a case;
`capability.match` says a payload cannot be read back yet.
`std::compiler::DiagnosticCode` gained `EnumPayloadRequired` and
`EnumPayloadUnexpected` (both recoverable in a `static compile:` block;
`sc-census-exhaustive` classifies them). The compiler service's semantic
tokens (`service::tokens`, which the language server serves) mark a
construction's case as an enum member with its enum before it, from the
`caseOrigin` the resolver records on the construction's struct node, and
a declaration's payload fields as property declarations with their types
(`pe-service-tokens`); nothing else in the service changed (hover and definition read the HIR as
before).

## 11. Boundaries and other targets

**(observed)** Where a boundary commits to a representation or an
encoding, a payload-bearing enum is refused with its reason, never given a
guessed representation (`pe-c-and-boundaries`):

| boundary | outcome |
|---|---|
| C backend (`main.tcl -emit-c`) | C UNSUPPORTED: "an enum whose cases carry payloads (S)" |
| `exported c fn` | EXPORT-SIGNATURE (an enum was never a C export type) |
| `std::transfer`, thread entries, `std::actor::remote` | NOT-SENDABLE: "S has payload-bearing cases, and a payload-bearing enum case has no transfer encoding yet" |
| a context struct member (native) | CONTEXT-NATIVE-LOWERING-UNSUPPORTED: its values may be heap objects |
| `callback c fn` | (an enum was never a callback type) |

The native targets (Linux x86-64 and AArch64, macOS AArch64, Windows
x86-64, Android AArch64 libraries) share the one runtime and lowering: no
platform code changed. **(projected)** Their CI runs exercise
`tests/payload-enums.test` like every test file; section 17 records what
ran.

## 12. Diagnostics

| situation | kind | where |
|---|---|---|
| duplicate case | TYPE (unchanged) | the second case |
| duplicate payload field | DUPLICATE-FIELD | the second field |
| unknown payload field type | TYPE (or the type's own kind) | the field's type |
| trait-typed payload field | TRAIT-STORAGE-UNSUPPORTED | the field's type |
| empty payload `{}`, missing type, default, rest field, two fields without a comma | SURFACE SYNTAX | the token |
| positional `Car(int)`, `Car: int` | SURFACE SYNTAX | the token |
| payload-bearing case written alone | ENUM-PAYLOAD-REQUIRED | the case |
| braces after a payload-free case | ENUM-PAYLOAD-UNEXPECTED | the case |
| unknown case in a construction | UNKNOWN-ENUM-CASE (unchanged) | the case |
| missing / unknown / duplicate field in a construction | MISSING-FIELD / UNKNOWN-FIELD / DUPLICATE-FIELD | the construction / field |
| field value not proven of its type | TYPE ("payload field "f" of case E::C cannot be proven...") | the value |
| another enum's case where an enum is declared | TYPE (unchanged, nominal) | the argument / result |
| copying, comparing or erasing an affine enum | USE-AFTER-MOVE, AFFINE-EQUALITY-UNSUPPORTED, AFFINE-ERASURE-UNSUPPORTED | the use |
| recursive affine enum | AFFINE-CONTAINER-UNSUPPORTED | the declaration |
| ABI boundaries | section 11 | |

Only the two new kinds are enum-specific; every other condition reuses the
struct or error-payload code. Every malformed program of the tests and the
fuzzer is a diagnostic, never a crash.

## 13. Tests

**(observed)** `tests/payload-enums.test`: 41 tests, sections A-I of the
brief and the compiler-shaped probe; every program runs on all four
backends through `pePlain`, which requires them to agree.

| section | tests |
|---|---|
| A. syntax and declarations | `pe-syntax-mixed-cases`, `pe-syntax-malformed`, `pe-syntax-mutation-robustness`, `pe-declaration-diagnostics`, `pe-forward-references`, `pe-modules`, `pe-payload-free-unchanged` |
| B. construction and identity | `pe-construction-types`, `pe-identity-equality`, `pe-hashing`, `pe-hash-pinned`, `pe-transport`, `pe-debug-rendering`, `pe-construction-diagnostics`, `pe-nominal-rejections`, `pe-exact-case-facts` |
| C. field contracts | `pe-field-kinds`, `pe-field-contracts-checked`, `pe-written-order` |
| D. nested data | `pe-nested-data`, `pe-collections-unrestricted` |
| E. recursion | `pe-recursive-enum`, `pe-recursive-through-struct`, `pe-recursive-affine-rejected` |
| F. affinity | `pe-affine-type`, `pe-affine-moves`, `pe-affine-releases`, `pe-affine-partial-construction`, `pe-affine-descriptor`, `pe-affine-coroutine` |
| G. backend parity | `pe-gc-stress`, `pe-executable-parity` |
| H. HIR round-trip | `pe-hir-roundtrip`, `pe-interchange` |
| I. isolation and optimization | `pe-native-representation`, `pe-native-allocation`, `pe-free-programs-unchanged`, `pe-specialization-keys`, `pe-service-tokens`, `pe-c-and-boundaries` |
| section 11 probe | `pe-kernel-probe` |

Rust: `enum_case_objects_are_nominal_and_compare_payloads`,
`enum_case_objects_hash_and_show_by_names` (runtime/ops.rs).

**(observed)** The golden suite `tests/golden/payload-enums.bot`: 18 tests
on all four backends. Ten port value tests of the Tcl file
(`pe-identity-equality`, `pe-hashing`, `pe-hash-pinned`, `pe-transport`,
`pe-forward-references`, `pe-written-order`, `pe-nested-data`,
`pe-recursive-enum`, `pe-affine-coroutine`, `pe-kernel-probe`: four
MIGRATED, six SPLIT, the rendering staying in Tcl), and eight split
`pe-construction-diagnostics` into one rejected `static compile:` block
per diagnostic (`std::compiler::DiagnosticCode::UnknownEnumCase`,
`EnumPayloadUnexpected` twice, `EnumPayloadRequired`, `MissingField`,
`UnknownField`, `DuplicateField`, `Type`), each located by `rejects_at`.
The other 31 Tcl tests are classified in
`audit/golden/migration/census/payload-enums.tsv` (KEEP-INTERNAL for HIR,
NIR and runtime probes, KEEP-MULTI-PROGRAM, KEEP-PARSER,
KEEP-NOT-EXPRESSIBLE for top-level declaration errors, rendering, GC
stress and executables); the manifest is regenerated from it and the
fragment. `std::test`'s `code_name` names the two new codes.
`tclsh9.0 tests/local.tcl tests/golden/payload-enums.bot`: 18 of 18 on
each backend; `audit/golden/tools/perturb.tcl` on the suite: every test
fails when its expectation is inverted (18) or altered (18), and every
`rejects_at` when its column moves (8).

Changed existing tests (intended): `enum-syntax-no-values-or-aliases`
(`Car {seats: int}` is now valid; its slot tests `Car {}`) and
`enum-case-is-not-a-constructor` (braces: ENUM-PAYLOAD-UNEXPECTED, was
NOT-A-STRUCT), the golden test of the latter in `structs-and-enums.bot`
(`std::compiler::DiagnosticCode::EnumPayloadUnexpected`), its manifest
rows (regenerated from the fragment and census), and
`oc-synthesized-string-consts-enumerated` (two new synthesized String
consts).

**The compiler-shaped probe** (`pe-kernel-probe`; the brief's section 11):
`audit/mid-end-port/kernel/`'s node as

```botlish
enum Node:
    Const {value: int},
    Param,
    Add {left: int, right: int},
    If {condition: int, yes: int, no: int},
    Call {function: int},
```

built by a helper per index, collected into a List and a MutableVector,
passed and returned, counted by `==` in a fold, compared and hashed whole --
identically on every backend. The kernel's interval evaluator was not
rewritten: it needs case selection and payload binding, the next
milestone's; its five-way performance comparison is untouched.

## 14. The independent model and the fuzzer

`audit/payload-enums/tools/fuzz.tcl`. The model shares no code with the
compiler or a runtime: a value is the triple (NominalEnumIdentity,
CaseIdentity, PayloadFields), equality is equality of the triple with the
payload compared by field name, every transport keeps it, rendering sorts
the fields. Programs declare two or three enums whose case and field names
overlap, cases and fields in random order, payload field types int, str,
bool, List[int], a struct and earlier enums (nesting), plus, every other
program, the module enum `std::fz::Mode`; a driver makes values (fields in
random written order), passes them through a generic identity, a typed
function, `any`, a struct field, a closure and a List, and observes values,
`==`, `!=`, hash equality and set membership. A third of the programs carry
one fault with its predicted code (missing, unknown or duplicate field,
wrong field type, ENUM-PAYLOAD-UNEXPECTED, ENUM-PAYLOAD-REQUIRED,
UNKNOWN-ENUM-CASE, a value of another enum to a typed function, a duplicate
field in a declaration); every fifth program is an affine one (a coroutine
handle in a payload) that must run on every backend or be rejected with
USE-AFTER-MOVE or AFFINE-EQUALITY-UNSUPPORTED.

Two operations make values that only identity, not provenance, can tell
apart: `remake` constructs an existing value again (another object, its
fields in another written order) and compares it with its source at once;
and a third of the enums give two cases the same payload fields (a twin),
which `remake` uses half the time, so two values differ by their case
alone. Two values statically of one enum are compared, half the time,
through its typed identity `id_E`, where a backend may decide the
comparison by the static type.

**(observed)** `-seed` is the first program's number (the convention of
the enum and error-payload fuzzers), so disjoint ranges were run: 200
distinct programs, 0 disagreements --

| programs | accepted | rejected as predicted | observations | disagreements |
|---|---:|---:|---:|---:|
| 101-140 | 29 | 11 | 344 | 0 |
| 201-240 | 19 | 21 | 196 | 0 |
| 301-340 | 27 | 13 | 316 | 0 |
| 401-440 | 26 | 14 | 320 | 0 |
| 501-540, `-gc-stress 1` | 24 | 16 | 307 | 0 |

-- the rejections spread over every predicted code (AFFINE-EQUALITY-
UNSUPPORTED, USE-AFTER-MOVE, DUPLICATE-FIELD, ENUM-PAYLOAD-REQUIRED,
ENUM-PAYLOAD-UNEXPECTED, MISSING-FIELD, UNKNOWN-FIELD, UNKNOWN-ENUM-CASE,
TYPE). Programs 1-43 (the first, overlapping run of `-seed 1` to `4`) also
agreed. Every accepted program ran on all four backends; every rejection
was the model's predicted code.

## 15. Mutation testing

`audit/payload-enums/tools/mutate.tcl` (adapted from the enum harness:
private copies, the native mutants rebuilt, detectors `tests/payload-enums.test`,
`tests/enums.test`, the fuzzer and `cargo test --lib enum`) over
`audit/payload-enums/tools/mutants.txt`, 25 mutants covering nominal
identity, case identity, payload comparison, hash composition, payload type
admission, the construction's field rules, ownership, cleanup, native
tracing, the representation choices, HIR text and the exact-case fact.

**(observed)** 25 mutants, 25 killed, 0 survived (`tclsh9.0
audit/payload-enums/tools/mutate.tcl`, default detectors, the fuzzer at 25
programs, seed 11):

| mutant | tests that fail | fuzzer | Rust |
|---|---|---|---|
| `payload-ignored-equality-tcl` | 9 (`pe-identity-equality`, `pe-hashing`, `pe-gc-stress`, ...) | 3 of 25 | |
| `case-ignored-equality-tcl` | `pe-identity-equality` | survived (60: 1) | |
| `enum-ignored-equality-native-boxed` | `pe-identity-equality` | survived | `enum_case_objects_are_nominal_and_compare_payloads` |
| `word-compare-for-payload-enums` | 10 (`pe-identity-equality`, `pe-kernel-probe`, ...) | survived (60: 6) | |
| `payload-order-is-identity` | 10 (`pe-identity-equality`, `pe-forward-references`, ...) | 8 of 25 | |
| `payload-ignored-equality-native` | 9 | 3 of 25 | `enum_case_objects_are_nominal_and_compare_payloads` |
| `hash-ignores-payload-tcl` | `pe-hash-pinned`, `pe-hashing` | 2 of 25 | |
| `hash-ignores-payload-native` | `pe-hash-pinned`, `pe-hashing` | 2 of 25 | `enum_case_objects_hash_and_show_by_names` |
| `hash-separator-dropped-tcl` | `pe-hash-pinned` | survived | |
| `payload-types-unchecked` | `pe-construction-diagnostics`, `pe-field-contracts-checked` | 1 of 25 | |
| `missing-payload-field-accepted` | `pe-construction-diagnostics` | survived | |
| `unexpected-payload-accepted` | `pe-construction-diagnostics`, `enum-case-is-not-a-constructor` | survived | |
| `required-payload-defaulted` | `pe-construction-diagnostics`, `pe-nominal-rejections` | 1 of 25 | |
| `case-type-is-payload` | 10 (`pe-construction-types`, `pe-affine-moves`, ...) | 7 of 25 | |
| `enum-affinity-ignores-payloads` | 6 (`pe-affine-*`, `pe-recursive-affine-rejected`) | 3 of 25 | |
| `enum-descriptor-empty` | `pe-affine-descriptor`, `pe-affine-partial-construction`, `pe-affine-releases` | survived | |
| `drop-first-case-tcl` | `pe-affine-partial-construction`, `pe-affine-releases` | 1 of 25 | |
| `drop-skipped-native` | `pe-affine-partial-construction`, `pe-affine-releases` | survived | survived |
| `affine-recursion-accepted` | `pe-recursive-affine-rejected` | survived | |
| `totality-ignores-payloads` | `pe-recursive-through-struct` | survived | |
| `payload-enums-sendable` | `pe-c-and-boundaries` | survived | |
| `payload-untraced-native` | `pe-gc-stress`, `pe-executable-parity` | survived | survived |
| `payload-key-erased` | `pe-specialization-keys` | survived | |
| `hir-text-loses-payloads` | `pe-hir-roundtrip` | survived | |
| `case-fact-lost` | `pe-exact-case-facts` | survived | |

The fuzzer is a second, independent detector, not the primary one: it
observes values, `==`, hashes and set membership, so it cannot see a drop
count, a descriptor, a codegen key, HIR text or a compiler fact, and it
predicts no hash value (the separator mutant changes every payload hash
consistently on the Tcl backends: only the pinned values and the
cross-backend comparison of `pe-hash-pinned` see it). Its first version
missed `case-ignored-equality-tcl` and `word-compare-for-payload-enums`
for want of the programs that expose them: two cases with the same payload
fields, and two distinct objects of one equal value compared at the enum's
static type. The `remake` operation and the twin cases (section 14) were
added for them; with them the fuzzer alone (`-tests tests/enums.test`, so
no payload test runs) kills both at 60 programs (1 and 6 disagreeing),
still neither at 25.

Existing catalogs: six mutants of two catalogs no longer applied after this
change rewrote the code they mutate (`audit/enums/tools/mutants.txt`'s
`equal-ignores-enum-tcl`, `same-spelled-enums-equal-tcl`,
`equal-by-ordinal-tcl`, `equal-ignores-enum-native`;
`audit/declaration-summaries/tools/mutants.txt`'s
`bearing-own-fields-ignored`, `carried-item-dropped`); each was rewritten to
the new code, keeping its rule, and re-run through its harness:

| mutant | killed by |
|---|---|
| `equal-ignores-enum-tcl` | 10 tests (`enum-equality`, `enum-generic-identity`, ...); fuzzer 10 of 25 |
| `same-spelled-enums-equal-tcl` | `enum-module-nominal`; fuzzer 10 of 25 |
| `equal-by-ordinal-tcl` | `enum-equality`, `enum-module-nominal`, `pe-identity-equality`, ...; fuzzer 12 of 25 |
| `equal-ignores-enum-native` | `enum-immutable-set`; fuzzer 11 of 25; `enum_equality_is_nominal_word_equality` |
| `bearing-own-fields-ignored` | `pds-nonuniform-own`; fuzzer 33 failures |
| `carried-item-dropped` | 5 tests (`pds-carried-union`, `pds-isolation`, ...); fuzzer did not complete |

**(observed)** The enum harness's private tree lacked `ccompile/`, so
`pe-c-and-boundaries` failed under every enum mutant for that reason alone
(`source` of a missing file); the run above counts it in each "tests"
column, but every mutant was also killed by the other tests and the
fuzzer. The harness now copies `ccompile/` (audit/enums/tools/mutate.tcl).

`tools/mutant-catalogs.tcl`: 107 catalogs, 3638 mutants, 0 problems.

## 16. Performance and allocations

**(observed)** `tclsh9.0 bench/enums.tcl` (defaults: best of 5 runs,
n = 2000 on the Tcl backends, 200000 natively), on this tree and on the
commit it starts from (73c32da8, a worktree with its own native build), one
after the other on the otherwise idle 4-core container. Times are whole
programs per operation; the bench's other column (minus a baseline
program) is noisier than the differences it would show.

**Payload-free enums, before and after** (ns per operation):

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| case constant | 19882 -> 21414 | 1157 -> 1194 | 43.3 -> 42.8 |
| copy through two bindings | 379926 -> 390537 | 11354 -> 11558 | 44.3 -> 43.4 |
| compare with a case (==) | 350474 -> 355210 | 14049 -> 14814 | 45.7 -> 43.2 |
| pass and return, typed | 365303 -> 361537 | 11509 -> 11753 | 44.0 -> 43.4 |
| iterate List[Kind] | 369540 -> 376895 | 15205 -> 15279 | 83.6 -> 76.7 |
| MutableArray[Kind] at / set / swap | 65398 / 73355 / 74228 -> 65074 / 74071 / 74003 | 5891 / 6156 / 6785 -> 5930 / 6235 / 6988 | 41.7 / 42.9 / 45.0 -> 41.5 / 44.3 / 44.9 |
| MutableVector[Kind] push, pop | 395644 -> 407358 | 25866 -> 26227 | 53.8 -> 49.2 |
| ImmutableSet[Kind] contains | 357914 -> 371699 | 20465 -> 20296 | 56.3 -> 57.9 |

The Int and Bool rows beside them, which no line of this change reaches,
moved as much (an Int `==` natively 44.1 -> 54.8 ns, `List[int]` 82.1 ->
96.7 ns, the Int constant on Tcl compile 1075 -> 1919 ns): the differences
are the container's noise. What does not move is exact: natively every
payload-free program allocates the same number of objects and bytes before
and after (all 33 programs of the allocation table, identical), and
`pe-free-programs-unchanged` and `pe-payload-free-unchanged` pin that a
payload-free enum's NIR is unchanged (`enumeq`, no `enumcase`).

**Payload-bearing cases beside a named struct with the same fields**
(ns per operation, whole program):

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| construction `Expr::Add {left, right}` / `Pair {left, right}` | 92973 / 51642 | 9399 / 6030 | 143.5 / 105.4 |
| a payload-free case of an enum with payloads (`Expr::Param`) | 21777 | 1271 | 44.6 |
| `==` of two equal values | 289301 / 208452 | 26656 / 20711 | 386.3 / 265.2 |
| `hash` | 307071 / 235458 | 155778 / 120367 | 261.7 / 185.6 |
| pass and return | 177367 / 141820 | 9701 / 6630 | 140.1 / 107.4 |
| MutableArray set | 183595 / 143036 | 14204 / 11361 | 195.9 / 117.8 |
| MutableVector push, pop | 210863 / 170451 | 24673 / 20772 | 141.4 / 109.7 |
| a larger nested payload (a List of 4, a nested struct) | 181245 / 136195 | 16034 / 12562 | 292.9 / 258.1 |

Native allocations per value (N = 200000 values):

| program | allocations | Structs | EnumCases | bytes |
|---|---:|---:|---:|---:|
| payload construction | 400003 | 200000 | 200000 | 16000120 |
| struct construction | 200003 | 200000 | 0 | 11200120 |
| a payload-free case of an enum with payloads | 3 | 0 | 0 | 1600120 |
| larger payload / struct | 800003 / 600003 | 400000 / 400000 | 200000 / 0 | 36800120 / 32000120 |

What this shows:

* A payload-free case costs what it did, also in an enum with
  payload-bearing cases: an immediate word, no allocation (3 allocations
  for the whole program, the loop's Lists).
* A payload-bearing value costs one more allocation than the struct of its
  fields, natively: its payload is an anonymous struct object (the
  construction's argument) and the case an EnumCase object pointing at it:
  72 bytes per value against the struct's 48 (the programs' bytes minus the
  loop's 1600120, over 200000 values), the EnumCase object's 24. That
  accounts for the construction's extra cost natively (1.4x); on the Tcl
  backends (1.8x on the interpreter, 1.6x on the Tcl compiler) the value
  is a list holding the enum's and the case's names and the payload
  struct, built by a call of `enum#case`. Every operation that makes a value pays it
  (the array, vector and larger-payload rows construct one per iteration);
  passing one (a word, a pointer) costs what passing a struct does.
* `==` and `hash` read the enum's and the case's names before the payload;
  they cost 1.3x to 1.5x the struct's, mostly the construction rows'
  difference again (both programs build their operands per iteration).
* **(projected)** The second allocation is a representation choice, and
  nothing in the language depends on it: storing the payload's fields in
  the EnumCase object, or scalar-replacing a case whose value does not
  escape as structs already are, would remove it. The bench shows the
  difference: its `==` baselines build two values per iteration and use
  one (`a = smk(i)`, `b = smk(i)`, `a`); natively the struct program
  allocates 200000 structs, the unused one never made, and the
  payload-bearing one 400000 of each kind, `enum#case` an allocating call
  that nothing removes. (The same is why the native `==` rows' "minus
  baseline" column, 79 ns against 163, favors the enum: the struct
  baseline was spared an allocation the struct `==` program pays.) Neither
  is done here; both are optimizations of the native backend alone, with
  no change to what a program means.

## 17. Regression results and CI

**(observed)** Locally (a 4-core Linux x86-64 container, Tcl 9.0.1, the
release native build):

| run | result |
|---|---|
| `tclsh9.0 tests/local.tcl` (290 Tcl test files on interp and compile, golden duplicates skipped; 119 golden suites on the four backends, through the front-end cache) | 697 of 699 items finished before the run's time limit: 690 passed, 7 failed; the two unfinished were `warning-gate.test` (run below) |
| the 7 failures | three intended changes the tests pinned, fixed: `sc-codes-one-to-one` (static-compile.test) and `gf-code-name-complete` (golden-framework.test) count the DiagnosticCode cases, 143 -> 145; `ns-root-inventory` (stdlib-namespaces.test) lists the internal root natives, now with `enum#case`. One transient: `syntax-highlighting.test` on the compile pass (its interp pass passed, and both passes passed in three later runs) |
| the four files again, whole, on both passes | 0 failures (55, 52, 34, 26 passed) |
| `tests/warning-gate.test`, both passes | 6 of 6 |
| `tests/local.tcl tests/golden/payload-enums.bot` (not yet in the run above) | 18 of 18 on each backend |
| `tests/payload-enums.test` (before `pe-service-tokens` was added), `tests/enums.test`, `tests/semantic-instances.test` under the rollback audit | 40, 66, 96 passed |
| `cargo test --release --lib` (native/) | 345 passed (7 of them `enum`) |
| `audit/payload-enums/tools/mutate.tcl` | 25 of 25 killed |
| `audit/payload-enums/tools/fuzz.tcl` | 200 programs, 0 disagreements |
| `tools/mutant-catalogs.tcl` | 107 catalogs, 3638 mutants, 0 problems |
| `merge.tcl -check 1` | 13,770 rows, consistent |
| `tools/compilerpedia.tcl generate`, `check` (through `tests/compilerpedia.test`) | the generated topic unchanged; 0 problems |

RESULTS-CI

## 18. Compatibility with the semantic-instance rollback design

**(inspection, observed)** SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md's
walks type the program's HIR in place and undo exactly what they wrote. This
milestone adds no new HIR field written during typing: the construction's
fields (`casePayloadOf`, the call's args, the constants) are written at
resolution, before any walk; a construction's type comes from
`ShapeResult`, a pure function of the constants and the registry; and the
exact-case query only reads. `pe-*` programs with generic helpers over
payload enums (`same(x)` in `pe-identity-equality`, `pe-hashing`,
`pe-transport`) exercise semantic instances. **(observed)** Under
`BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1`, which compares each walked
instance's HIR with its snapshot and fails on any change left behind:
`tests/payload-enums.test` 40 of 40 (its 41st test, `pe-service-tokens`, came later), `tests/enums.test` 66 of 66,
`tests/semantic-instances.test` 96 of 96.

## 19. Explicitly unsupported, and why

* **Reading a payload** (case selection, payload binding, projection): the
  next milestone's `match`. Nothing here offers a substitute.
* **Sendable payload enums**: the transfer codecs encode a payload-free
  case's name only; a payload-bearing case needs a schema form and both
  codecs' support (core/transfer.tcl, runtime/transfer.rs) with fixed
  vectors. Refused (NOT-SENDABLE), never sent without its payload.
* **The C backend and C ABI boundaries**: no C representation is defined;
  refused (section 11).
* **A payload enum as a context struct's member natively**: the context
  area holds immediate words only; refused with its reason.
* **Recursive affine enums**: no finite drop descriptor (section 7).
* **Refinements over an enum carrier**: unchanged from ENUMS.md (48).
* **Generic enums** (`Option[T]`): not added. A type-parameter system for
  enums is a feature of its own; `Option[T]`-like uses need it. Struct
  applications may appear in payload field types, and a parameterized
  struct may hold an enum.
* **Deep recursive values and host recursion**: equality, hashing and
  printing of a deeply nested recursive enum value recurse in both runtimes
  as they do for an ordinary recursive struct (tree structs alone use work
  stacks, TREE-STRUCT-MILESTONE-1.md); a value nested deeper than the host
  stack allows fails as such a struct would.

## 20. What the exhaustive-match milestone builds on

* The closed case set and every case's payload fields with resolved types:
  `hir::enums::cases`, `fields`, `payloadType`, `hasPayload`.
* Case identity in values on every backend: Tcl's second component, the
  native `enum_case_parts` (word or object), names through the enum table --
  a selection is an (enum, case) comparison, never a position.
* The payload as an ordinary anonymous struct value: a selected case's
  fields can be bound by the existing struct destructuring
  (STRUCT-DESTRUCTURING.md) with no new runtime operation.
* Exact-case facts (`hir::enums::caseFact`) for statically decided
  selections and unreachable arms.
* **Representation opportunities**, none needed for correctness: an
  EnumCaseObj with inline fields (one allocation instead of two); scalar
  replacement of a payload-bearing value that does not escape (today the
  payload struct always materializes, since it escapes into `op enumcase`);
  `==` of two values with known different cases decided statically from
  `caseFact`; a transfer schema for payloads.

## 21. Files

* Surface: `surface/parser.tcl` (`EnumDecl`, `EnumPayload`),
  `surface/ast.tcl`, `surface/modules.tcl` (`Walk`'s `enumdecl`,
  `CheckRef`).
* HIR: `hir/enums.tcl` (payload descriptors, `resolvePayloads`,
  `withPayloads`, `setPayload`, `payloadType`, `payloadParts`,
  `caseFact`, `VerifyRecursion`, `OwnedEnums`, `IsPayloadFree`, the two
  messages), `hir/hir.tcl`, `hir/resolve.tcl` (`CaseConstruction`,
  `ResolveStruct`'s `casePayloadOf`, `ResolveEnumCase`), `hir/types.tcl`
  (`ShapeResult`'s `enum-case`, the payload type, Totality, SendClass,
  MentionsMutable), `hir/range.tcl` (`VerifyCasePayload`),
  `hir/applied.tcl`, `hir/callables.tcl`, `hir/structs.tcl`,
  `hir/decimal.tcl`, `hir/staticdeps.tcl`, `hir/privacy.tcl`,
  `hir/affine.tcl` (the `e` descriptor), `hir/specialize.tcl`,
  `hir/aot.tcl`, `hir/format.tcl`, `hir/read.tcl`, `hir/static.tcl`.
* Core and Tcl backends: `core/enums.tcl` (new), `core/core.tcl`,
  `core/value.tcl`, `core/hashing.tcl`, `core/affine.tcl`,
  `core/mutvec.tcl`, `core/native.tcl`; `stdlib/compiler.bot`.
* Native: `native/lower.tcl` (`EnumCaseValue`, `ImmediateEnum`,
  `ContextLeaves`), `native/src/nir.rs` (`EnumCase`),
  `native/src/codegen/clif.rs`, `native/src/runtime/{value,vm,heap,metrics,
  ops,show,affine,mutvec}.rs`.
* C backend: `ccompile/ccompile.tcl`.
* Tests: `tests/payload-enums.test` (new), `tests/golden/payload-enums.bot`
  (new), `tests/enums.test`, `tests/one-char-string-literal.test`,
  `tests/golden/structs-and-enums.bot`, `tests/golden/manifest.tsv`,
  `audit/golden/migration/{fragments,census}` (`payload-enums.tsv` new),
  `audit/golden/migration/tcl-names.txt`; `stdlib/test.bot` (the two codes'
  names).
* Compiler service: `service/service.tcl` (tokens of a construction's case
  and of a declaration's payload fields; `caseOrigin` recorded on the
  construction's struct node, hir/resolve.tcl).
* Audit: `audit/payload-enums/tools/{fuzz.tcl,mutate.tcl,mutants.txt}`
  (new); `audit/enums/tools/{mutants.txt,mutate.tcl}`,
  `audit/declaration-summaries/tools/mutants.txt` (updated mutants).
* Benchmark: `bench/enums.tcl` (payload rows).
* Docs: this file, ENUMS.md, README.md, INDEX.md, AGENTS.md; Compilerpedia
  topics (`concepts.topic`, `errors-resolution.topic`,
  `capabilities.topic`, the generated stdlib topic).

## 22. What to run when changing this

`tests/payload-enums.test`, `tests/enums.test`,
`audit/payload-enums/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/payload-enums/tools/mutate.tcl` (every mutant must
still apply and be killed), `cargo test --release --manifest-path
native/Cargo.toml --lib enum`, `tclsh9.0 tests/local.tcl
tests/golden/payload-enums.bot tests/golden/structs-and-enums.bot`,
`tools/mutant-catalogs.tcl`,
`tools/compilerpedia.tcl check`, and the enum, affine and
declaration-summaries harnesses for code they share. `bench/enums.tcl`
regenerates the performance rows.
