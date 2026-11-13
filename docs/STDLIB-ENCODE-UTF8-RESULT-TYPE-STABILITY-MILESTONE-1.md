# A standard-library native's result type does not depend on unrelated imports (milestone 1)

M3 of [TEXT-AND-COLLECTION-PRECISION-CENSUS.md](TEXT-AND-COLLECTION-PRECISION-CENSUS.md):
`std::str::encode_utf8(s)` is `List[int[std::byte::Byte]]` in every
compilation that can call it, whatever else the program imports. It was the
plain `list` unless the compilation happened to load `std::byte`, so an import
nothing named decided whether a program was accepted.

Measured on `main` at `bd6f99f9` (2026-11-13), Linux x86-64, Tcl 9.0.1,
rustc 1.97.0, the native backend built in release mode. The census was taken
at `f2787af0`; M1 and M2 landed since; every observation below was
reproduced at `bd6f99f9` first, with a pristine worktree of it beside the
change (section B).

Throughout, **Executed** means a command was run and its result observed,
**Inspected** that the behavior was established by reading the
implementation, and **Projected** an architectural consequence not directly
verified.

## A. Result

| observable (a program importing `std::str`, not `std::byte`) | before | after |
|---|---|---|
| static type of `s.encode_utf8()` | `list` | `List[int[std::byte::Byte]]` |
| an indexed element, `bs.at(0)` | `any` | `int[std::byte::Byte]` |
| a loop element, `loop b in bs` (checker and record) | `any` | `int[std::byte::Byte]` |
| the hover at `bs`, `x`, `b` | `list`, `any`, `any` | the types above |
| the facts of an element (a TYPE diagnostic states them) | `[-∞, +∞]` | `[0, 255]` |
| `table.at(b)` over a 256-entry table (probe `c4`) | two UNHANDLED-ERROR (IndexNotFound) | accepted, the value `c5` gives |
| a declared `-> int` result returning an element | rejected (`result type: any`) | accepted |
| the same program with `import std::byte` (`c5`) | as "after" | unchanged |

The contract is now unconditional: whatever a program imports -- `std::str`
alone, `std::abi::bytes`, `std::byte`, any combination, in any order, through
any chain of modules or packages -- the result has one canonical type,
structurally the same Tcl value as a written `List[std::byte::Byte]`
resolves to (Executed: `tests/encode-utf8-type-stability.test`,
`eut-contract-import-independent`, `eut-import-order`,
`eut-import-order-unrelated`, `eut-modules`, `eut-package`).

The mechanism is general and small: a native's result contract that names a
standard-library type (today only `encode_utf8`'s `{typed std::byte::Byte 0
255}`) makes the loader load that type's module for every compilation that
can reach the native, exactly as another standard-library module's
`import` would, granting no file any name of it (section D). Runtime values
are unchanged on every backend (section L).

## B. Minimal reproducer

`audit/encode-utf8-type-stability/programs/repro.bot` (and `repro-byte.bot`,
the same program with an `import std::byte` nothing names):

```botlish
import std::str
import std::list

type Digit = Int in 0..9

fn digit(d: Digit) -> int:
    d

fn classes(s: str) -> List[int]:
    table = loop i from 0 to 256:
        i + 1
    loop b in s.encode_utf8():
        table.at(b)

fn first(s: str) -> int errors IndexNotFound:
    bs = s.encode_utf8()
    x = bs.at(0)
    x

fn facts(s: str):
    loop b in s.encode_utf8():
        digit(b)

classes("héllo")
```

`facts` is a deliberate probe: passing an element to a `Digit` parameter makes
the checker print the element's type and facts. Executed with
`tclsh9.0 audit/encode-utf8-type-stability/tools/evidence.tcl -root DIR` on
the pristine `bd6f99f9` worktree and on the change (the tool queries the
compiler service, as an editor's hover does):

| | before, `repro.bot` | before, `repro-byte.bot` | after, both |
|---|---|---|---|
| hover at `bs` | `bs: list` | `bs: List[int[std::byte::Byte]]` | `bs: List[int[std::byte::Byte]]` |
| hover at `x` | `x: any` | `x: int[std::byte::Byte]` | `x: int[std::byte::Byte]` |
| hover at the loop's `b` | `b: any` | `b: int[std::byte::Byte]` | `b: int[std::byte::Byte]` |
| `first`'s declared `-> int` | TYPE: `result type: any, facts: [-∞, +∞]` | proven | proven |
| `digit(b)` (the probe) | TYPE: `argument type: any, facts: [-∞, +∞]` | TYPE: `argument type: int[std::byte::Byte], facts: [0, 255]` | as `repro-byte.bot` before |
| `table.at(b)` | UNHANDLED-ERROR at 17:9 and at the call `classes(...)` 28:1 | proven | proven |

Before the change the two programs differed in four diagnostics (an
acceptance difference, an error obligation, a declared-result proof and the
range facts); after it they are identical in every observation. The
census's probes `c4` (no import) and `c5` (with it) on the four backends:

| probe | interp | compile | cranelift | cranelift-generic |
|---|---|---|---|---|
| `c4`, before | rejected | rejected | rejected | rejected |
| `c4`, after | `[105, 196, 170, 109, 109, 112]` | the same | the same | the same |
| `c5`, before and after | `[105, 196, 170, 109, 109, 112]` | the same | the same | the same |

Probe `c3` (no `std::byte`, a TYPE probe on an indexed and a loop element)
now states `argument type: int[std::byte::Byte]` at both sites and records
`bs: List[int[std::byte::Byte]]`; it stated `any` and `list`.

## C. Architecture census

**Native result shapes (Inspected).** A native is registered once, at
process start, by `core::native::register` (`core/strings.tcl` for
`encode_utf8`: `-result-type list -result-shape {typed std::byte::Byte 0
255}`). `-result-type` is a static kind; `-result-shape` refines it per call
in `hir::types::ShapeResult` (`hir/types.tcl`). Thirty-one shape kinds are
registered (Executed: a census of the registry). Two of them name a
source-declared type fixed by the native itself, whatever the call's
arguments: `typed NAME LO HI` (one native: `std::str::encode_utf8`) and
`named-struct ID` (fifteen natives; below). The others derive the result
from the call's arguments (`element`, `append`, `layout-struct`,
`context-struct`, ...), from an analysis of the program (the coroutine
shapes), or name a builtin type (`element-type`). A native has no access to a compilation's
declarations at registration: `NAME` is a symbolic identity resolved at
type-inference time (`core::type::isNamed`, `core::type::normalize`).

**Source-declared domains (Inspected).** `type Byte = Int in 0..255` is a
statement of `stdlib/byte.bot`. The loader (`surface/modules.tcl`) collects
the type declarations of every module it loads (`typeDecls`), and
`hir::buildSyntax` registers them in `core::type`'s registry
(`hir::sourcetypes::apply`) as the identity `std::byte::Byte`, after
resetting the previous compilation's (COMPILATION-ISOLATION.md). The
registry holds exactly the declarations of the modules the compilation
loaded.

**Why resolution required a loaded module (Inspected).** A module is loaded
by an import and by nothing else (IMPORTS.md): `import std::byte`, or an
import by another loaded module (`stdlib/abi/bytes.bot` imports `type
std::byte::Byte`, `stdlib/web.bot` imports `std::byte`). `std::str` is an
intrinsic namespace with no file, so `import std::str` loads nothing, and in
a program that loads no module importing `std::byte`, `isNamed
std::byte::Byte` was false and `ShapeResult` returned the plain `list`: the
fallback protected against claiming a type that does not exist in the
compilation, and it was sound -- only imprecise, and non-local.

**Name visibility (Inspected, then Executed).** What a file may name is its
own imports' business, never the loaded set's: `CheckRef` rejects a
qualified reference whose namespace the file does not import
(MISSING-IMPORT), `hir::resolve::MethodCandidates` gathers candidates from
`hir::imports::namespaces` of the calling file, and a short type name
resolves through the file's own `import type`s. A module loaded through
another module's import is therefore in the compilation without being
visible -- the situation of `std::byte` in every program that imports only
`std::abi::bytes` today.

**Nominal identity (Inspected).** Every analysis compares types by their
canonical value: `{refined int {std::byte::Byte}}` for the element, built by
`core::type::normalize` from the registry entry. Applied collections are
admitted invariantly (`hir::range::AggregateAdmits`), so `List[int[0..255]]`
-- were there such a type -- would not be `List[int[std::byte::Byte]]`; the
nominal identity is what interoperates with a written `List[std::byte::Byte]`
parameter.

**The precedent (Inspected).** `hir::cabi::NamespaceTypeDecls` declares
`std::ffi::c`'s C integer scalars when a file imports `std::ffi::c`: those
types belong to the imported namespace itself, so they are prepended to that
module's own declarations. `encode_utf8`'s type belongs to *another* module
than the native's namespace, which is the new case.

**Other shapes (Executed: `eut-contract-census`, `eut-named-struct-census`).**
`typed` has exactly one user, `encode_utf8`, as the census found. The
`named-struct` shapes name `std::abi::bytes::Bytes` (`std::binary::emit`,
`write`, `write_foreign`, `std::transfer::encode`, `std::thread::rt_*`, and
the internal `binary#emit`, `transfer#encode`) and `std::abi::ARCH::
Register64` (`std::abi::ARCH::from_bytes`, `from_mutable_bytes`, and the
syscall transports `std::linux::abi::ARCH::syscall`). Importing the native's
namespace already declares the struct for every one of them -- the
namespace's module imports the struct's module, or declares it -- except the
two syscall transports, intrinsic namespaces without a file. Their result is
`struct` without `std::abi::x86_64` loaded, but the transport's own argument
contract requires an anonymous struct of `std::abi::x86_64::register64(N)`
values, so an accepted call always has the struct declared (Executed: a
direct module calling `syscall(r)` with an untyped `r` is rejected either
way, the result's type in the diagnostic being `struct` or `Register64`).
They are left as they are and pinned as the census's only exception
(`eut-named-struct-census` fails on a new one).

**Was there a cross-compilation leak too? (Executed.)** No: compiling `c4`,
`c5`, `c4` in one process rejects both `c4`s -- a build invalidates the
registry first, so the defect was confined to one compilation's imports.

## D. Selected design

**The rule.** Once a compilation's import closure is loaded, every module
that declares a type the result contract of a reachable native names is
loaded too, if the program did not load it already
(`surface::modules::ContractTypes`). A namespace is reachable when a file of
the compilation imports it, when it is a loaded module's own namespace, or
when it is the root (root natives are always callable). The types come from
the registry, not from a list kept beside it: `core::native::contractTypes
NS` reads the `typed` shapes of the natives of `NS`. The module is loaded by
the loader's one procedure for that, `LoadNamespace`, with no importing file
(as `LoadNamespaces` loads a module by name), so its own header loads its own
dependencies, it is parsed and checked once, and no file's import
environment names it. Loading repeats until no reachable namespace names an
unloaded module (a loaded module's own imports are reachable), and owners are
visited in sorted order, so the result does not depend on import order.

**Alternatives considered.**

* **A. A type-only dependency of the native** -- declare just the named
  type, from its module's own statement, without loading the module.
  *Implemented first and rejected on evidence.* It made `encode_utf8`'s
  result precise everywhere and passed every test of the result's type, but
  a type is not only its declaration: a trait's conformance reads the
  witness's *owner module* (`hir::traits::satisfies`; TRAITS.md: "never the
  call site's imports"). With `Byte` declared and `std::byte` not loaded,
  `trait Complementable: fn complement(value: Complementable) -> int`
  rejected a `Byte` witness with the false message `"complement" is not
  defined by module "std::byte"`, and accepted it once `import std::byte`
  was added -- an unused import deciding acceptance again, one level up
  (Executed; now `eut-trait-conformance`). The `-traits` report showed the
  half-declared module too. A type-only declaration is a second, partial
  notion of "loaded" that every reader of a module's declarations would
  have to know about.
* **B. Type dependencies of a namespace, loading the module** -- *selected*,
  in the form above: the dependency is derived from the natives' contracts
  (A's information) and satisfied by B's mechanism. It introduces no new
  module state: the module is loaded exactly as a transitive import loads
  it, a situation every part of the compiler already handles (privacy,
  method candidates, interchange, isolation, the cache's probes, the
  service's import notes).
* **C. Registering `Byte` with the core** -- rejected: `std::byte::Byte` was
  moved *out* of the core into `stdlib/byte.bot` deliberately
  (SOURCE-DEFINED-INTEGER-DOMAINS.md); a core registration beside the source
  declaration would be two definitions of one identity (duplicate
  registration, and conformance would still read a module that is not
  loaded).
* **D. A structural range result (`List[int]` with 0..255 facts)** --
  rejected: applied collections are admitted invariantly, so such a result
  would still not be a `List[std::byte::Byte]` at a declared boundary
  (`std::abi::bytes::from_list`), and the element facts would not survive
  where facts are not carried (a declared result, a field) the way a domain
  type does.

**Why this is the smallest coherent solution.** Two procedures in the loader
(`ContractTypes`, `ContractOwners`) and one query in the registry
(`contractTypes`); no new syntax, declaration form, module state, HIR field
or interchange field; no special case for `encode_utf8` (a probe native of
another namespace whose contract names `std::byte::Nibble` gets the same
treatment: `eut-probe-native`). The cost is the module's front end, once per
compilation (section N).

**New dependency edges and cycles.** The one new edge today is `std::str` (an
intrinsic namespace) to `std::byte`. `stdlib/byte.bot` imports `std::char`
and `std::immutable_set`, both intrinsic namespaces with no file, so the
closure adds exactly one file. A cycle cannot arise through the new edge:
the contract modules are loaded after the import closure, with the loading
stack empty, and an intrinsic namespace is never on the stack (it has no
file to load), so a contract module that itself imported `std::str` would
find `std::str` already satisfied and its own contract module already loaded
or loading in the same round's list (Inspected; `LoadNamespace`'s `loaded`
check comes before its `stack` check).

## E. Availability versus imports

What the compilation gains when it loads `std::byte` for the contract: the
module's four types (`Byte`, `Nibble`, `LowNibble`, `HighNibble`), its two
errors (`std::byte::BelowRange`, `AboveRange`), its eight functions and its
own import environment -- exactly what an `import std::byte` in another
module would add (Executed: `eut-module-loaded` compares the two programs'
declarations). What stays unavailable to every file that does not import
`std::byte` (Executed: `eut-visibility-qualified`,
`eut-visibility-short-and-method`, probe `c7`):

| written in a file importing `std::str` only | outcome |
|---|---|
| `std::byte::from_int(b)` | MISSING-IMPORT (probe `c7`) |
| `fn f(b: std::byte::Byte)` | MISSING-IMPORT |
| `std::byte::BelowRange` | MISSING-IMPORT |
| `fn f(b: Byte)` | TYPE: unknown type `Byte` |
| `b.complement()` | MISSING-IMPORT, naming the import |
| `import type std::byte::Byte` then `Byte` | accepted (unchanged) |

The method-style call is still rejected -- `complement` is no candidate --
but its diagnosis changed from "no function named complement is visible"
(NOT-A-STRUCT) to `namespace "std::byte" is not imported; add `import
std::byte` to use `std::byte::complement``: byte for byte what the compiler
already said when `std::byte` was loaded through `std::abi::bytes`
(Executed on `bd6f99f9`). No implicit import exists: the entry program's
import environment does not name `std::byte` (`eut-module-loaded`), and the
mutant that adds it is killed (section M).

## F. Nominal identity and proof soundness

* **One identity (Executed).** The call's type is the same Tcl value with
  `std::str` alone, with `std::byte`, with `std::abi::bytes`, with both
  (`eut-contract-import-independent`), and equal to
  `MakeList (normalize std::byte::Byte)`, the value a written
  `List[std::byte::Byte]` resolves to. The program declares
  `std::byte::Byte` once, from `stdlib/byte.bot`, whatever the import order
  (`eut-import-order`). An application module named `byte` (identity
  `byte::Byte`), a program's own `type Byte = Int in 0..15` and a package's
  `byte` module are other identities and never the native's
  (`eut-application-byte-module`, `eut-own-byte-is-not-the-natives`).
* **The range is proven, not assumed (Executed).** `ShapeResult` still proves
  `0..255` admissible in the declaration's domain (`hir::range::ProvesType`)
  before claiming it. A superset (`0..1000`) is claimed soundly; a narrower
  domain (`0..15`), a refinement, or a `str`-based registration of the name
  is the standard library contradicting its own native and fails the
  compilation (`CORE SEMANTIC COMPILER-INTERNAL`, `eut-domain-not-admitting`,
  `eut-missing-declaration`, `eut-incompatible-registration`). It used to
  fall back to `list` silently; with the type now always present, a silent
  fallback could only hide a broken standard library.
* **Admission rules unchanged (Executed).** `List[std::byte::Byte]` is still
  rejected at a declared `List[int]` (`eut-typed-parameter`; probe `d1`), an
  element is admitted where an `int` or a `std::byte::Byte` is required, a
  `Byte` argument discharges `std::byte::from_int`'s errors while an
  unconstrained `int` still owes them (`eut-element-is-int-and-byte`).
  `AggregateAdmits`, `ProvesType` and `from_int` are untouched.
* **No false proof (Executed: `eut-negative-controls`).** An untyped
  parameter's and a bare `list`'s elements stay `any`, a List literal of
  small Ints is `int`, a user domain's elements stay that domain, and
  `std::list::append` of an encoded List and `300` joins to `int`: the rule is
  the native's contract, not "a List of small Ints is a List of Bytes".
* **Malformed contracts (Executed).** A `typed` shape must name a
  standard-library identity (`std::NS::Name`) with `LO <= HI`; an
  unqualified, application or package name, or a reversed range, is refused
  at registration (`eut-registration-validates-name`). A contract naming a
  standard module that does not exist, a platform's module, or a type its
  module does not declare is a COMPILER-INTERNAL failure of the compilation,
  never a diagnostic of the program and never a fallback
  (`eut-contract-module-missing`, `eut-missing-declaration`). A `std::byte`
  whose own declaration is in error reports that diagnostic identically
  whether imported or not (`eut-broken-module-same-outcome`). Only a program
  no loader built (core IR text, which declares no type) still has the plain
  `list`: there is no type to claim (`eut-no-loader-no-claim`).

## G. Implementation

| file | change |
|---|---|
| `core/native.tcl` | `contractTypes NS`: the `{TYPE NATIVE}` pairs of the `typed` shapes of `NS`'s natives, memoized per namespace and forgotten by `register` and `unregister`; `ValidShape` requires a `typed` NAME to be `std::NS::Name`; the shape's documentation |
| `surface/modules.tcl` | `ContractTypes` (the fixpoint that loads contract modules, then checks each declares its type), `ContractOwners` (reachable namespaces to `OWNER -> {NAME -> NATIVE}`), `ContractError` (the COMPILER-INTERNAL failure); called by `BuildProgram` and `LoadNamespaces` after the import closure and before reference errors are raised; the header's account of loading |
| `hir/types.tcl` | `ShapeResult`'s `typed` case: the fallback only for an undeclared NAME (no loader), an unproven domain a COMPILER-INTERNAL failure; comments |
| `surface/cache.tcl` | comments: the contract module is a probe, hence a dependency |
| `compilerpedia/notes/stdlib.notes` (and the generated page) | `encode_utf8`'s note and examples, `decode_utf8`'s note (section O) |
| `docs/README.md`, `docs/IMPORTS.md`, `docs/STATIC-COMPLETION-PROOFS.md`, `docs/SYMBOLIC-TYPE-IDENTITY.md`, the census | the unconditional contract, the loading rule, update notes |
| `tests/encode-utf8-type-stability.test` | new, 37 tests |
| `tests/symbolic-type-identity.test`, `tests/loop-clause-binding-types.test`, `tests/text-collection-docs-diagnostics.test`, `tests/traits.test` | expectations of the old conditional rule flipped (section H) |
| `audit/text-collection-precision/probes/` | `c3`, `c4`, `c5` updated, `c7` added |
| `audit/text-collection-docs/tools/mutants.txt` | M2's documentation mutant rewritten to the new text (same rule) |
| `audit/encode-utf8-type-stability/` | the reproducer, the evidence and benchmark tools, the mutation catalog and harness |

The front-end cache needs no new key input: the contract module's file is a
loader probe, so its text is a dependency of every entry that loaded it
(`eut-cache-dependency`), and every cache entry and interchange text made by
the previous front end is refused by the front-end fingerprint, which covers
`core/`, `hir/` and `surface/` (Inspected: `surface::cache::Key`,
`hir::interchange::fingerprint`). The interchange format does not change;
its content does (the loaded module's section and declarations).

## H. Observable semantic changes

(Pending: the corpus comparison against `bd6f99f9` is running.)

## I. Semantic instances

An untyped helper `fn helper(s): s.encode_utf8()` reached from three typed
consumers -- a list loop, a fold over `helper(std::str::concat(s, "é"))`, and
a loop over another untyped function `relay("😀")` -- each indexing a
`List[int]{length: 256}`, in two programs whose consumers and calls are in
opposite orders (Executed: `eut-instances-order-independent`): every call of
`helper` has the one type `List[int[std::byte::Byte]]`, both programs are
accepted (the index proofs need the instance's Byte), and the four backends
print `[[97], [477], [240, 159, 152, 128]]` and its reverse. The rule reads
nothing of an instance: `ShapeResult`'s `typed` case is argument-independent,
and the type exists before any walk (Inspected). The mutant that falls back
in a semantic instance's walk only is killed by this test (section M).
Compilation isolation (A, then B with a private `std::byte` of `0..1000`,
then A; the first A activated after B) keeps each program's own declaration
(`eut-isolation`), and the harness of COMPILATION-ISOLATION.md was run
(section M).

## J. Modules and packages

Executed (`tests/encode-utf8-type-stability.test`):

| structure | result |
|---|---|
| a single-file program importing `std::str` | Byte (`eut-contract-without-byte`) |
| a module importing `std::str`, through a two-module chain, consumed by a program that imports neither `std::str` nor `std::byte` | Byte; the consumer's index proof holds on interp and cranelift (`eut-modules`) |
| a package (`.bot_modules/textpkg`) whose function returns the result, used by a consumer that imports neither | Byte (`eut-package`) |
| `std::byte`, `std::abi::bytes`, both, neither, in either order | one declaration, one type (`eut-import-order`) |
| `std::str` first or last among unrelated imports | accepted (`eut-import-order-unrelated`) |
| no file importing `std::str` | no `std::byte` loaded; `std::str::encode_utf8` itself MISSING-IMPORT (`eut-no-native-reachable`) |

No consumer installs anything for `std::byte`: it is a standard-library
module, inside the single executable's packed `stdlib/` (Inspected:
`single/package.tcl` packs `stdlib/`).

## K. HIR interchange, cache and isolation

Executed (`tests/encode-utf8-type-stability.test`):

* **Fresh compilation:** the four-backend runs of `eut-every-context` and the
  evidence tool, each in a fresh process.
* **HIR text:** `hir::format` writes `type std::byte::Byte ...`; `hir::parse`
  reads back the declaration and the `List[int[std::byte::Byte]]` call, and
  the text is a fixed point (`eut-hir-text-roundtrip`).
* **Interchange in a fresh process:** a `.hirx` written here and read by a
  separate `tclsh9.0` that builds nothing reports the call's type and
  `std::byte::Byte`'s domain `{interval 0 255}` -- the decoding installs the
  declarations (`eut-interchange-fresh-process`).
* **Cache:** a miss then a hit give the same declaration and type
  (`eut-cache-hit-equals-miss`); after `stdlib/byte.bot` changes (a private
  library), a program importing only `std::str` is compiled again, not read
  from its entry, and gets the new declaration (`eut-cache-dependency`).
* **Isolation:** A, B, A in one process (`eut-isolation`, above).

## L. Backend parity

(Pending.)

## M. Regression and mutation testing

(Pending: the full local run and the mutation harness are running.)

## N. Performance

(Pending.)

## O. Documentation

M2 documented the conditional type; it is replaced:

* `stdlib.std::str::encode_utf8` (`compilerpedia/notes/stdlib.notes`,
  regenerated into `compilerpedia/generated/stdlib.topic`): the paragraph
  "Its static type depends, today, on what the compilation has loaded ...
  import std::byte or std::abi::bytes" is replaced by the unconditional
  statement ("importing std::str is enough, whatever else the program
  imports"), with what an element is proven to be wherever it flows, that
  `std::byte`'s names still need its import, and the invariant element type.
  The rejected example "Without std::byte loaded the compiler knows only the
  plain list" is replaced by an accepted one (the 256-entry table, value
  `[208, 390, 338, 216, 216, 222]`) and a rejected one that keeps collection
  invariance documented (`List[std::byte::Byte]` at a `List[int]`
  parameter).
* `stdlib.std::abi::bytes::decode_utf8`: "with std::abi::bytes imported,
  std::byte is loaded and that result has the type" becomes "which has that
  type whatever the program imports".
* `docs/README.md` §8's `encode_utf8` row, `docs/IMPORTS.md` ("What an import
  loads"), `docs/STATIC-COMPLETION-PROOFS.md` ("UTF-8 result type") and
  `docs/SYMBOLIC-TYPE-IDENTITY.md` (an update note) state the loading rule.
* `tests/text-collection-docs-diagnostics.test`'s `tcd-doc-utf8-static-type`
  now checks the new statements and the absence of the old ones.

(Pending: the single-file compiler's help.)

## P. Remaining limitations

* **Core IR text** declares no types, so a core IR program calling
  `std::str::encode_utf8` still gets the plain `list` (Executed:
  `eut-no-loader-no-claim`). Core IR text is a harness format, not a
  language entry point (AGENTS.md, "Compiler architecture").
* **The callee's hover** at `encode_utf8` shows the native's value type,
  `Fn{args: [any], return: list, errors: []}`, before and after: it is the
  presentation of the native as a function value, unrelated to imports. A
  call through that value is precise (Executed: `g = std::str::encode_utf8;
  g(s)` is `List[int[std::byte::Byte]]`, was `list`).
* **The syscall transports' `named-struct` result** is `struct` without
  `std::abi::ARCH` loaded; only rejected programs can observe it (section C).
  Extending contract types to structs would load `std::abi::ARCH` for every
  program importing a transport; not done here.
* **Contract types are integer domains** (`typed`): a future native whose
  contract names another kind of type needs its own validation.
* **Cost:** every compilation that can reach `encode_utf8` and did not load
  `std::byte` now loads it (section N).
* **Not in scope** (the census's M4-M8): no `join`/`from_chars`, no
  Int-to-UnicodeChar conversion, no numeric escape, no covariant collection
  admission (the invariance pins are unchanged), no fold construction
  change.
