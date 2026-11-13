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

**Why this is the smallest coherent solution.** Four small procedures in the
loader (`ContractTypes`, `ContractOwners`, `ContractModules` for the cache,
`ContractError`) and one query in the registry (`contractTypes`); no new syntax, declaration form, module state, HIR field
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
  platform's module, or a type its module does not declare, is a
  COMPILER-INTERNAL failure of the compilation, never a diagnostic of the
  program and never a fallback (`eut-missing-declaration`). A standard
  library that has no module for the type at all -- in practice a test's
  scratch library, `$::core::libraryDir` holding only the test's own
  modules -- declares no such type and loads nothing: the result is the
  plain `list` there, and no import can change it, because `import
  std::byte` is UNKNOWN-NAMESPACE in such a library (`eut-scratch-library`,
  `eut-contract-module-absent`). The type depends on the standard library
  at hand, never on the imports; the shipped library has every contract's
  module (`eut-contract-census`). A `std::byte`
  whose own declaration is in error reports that diagnostic identically
  whether imported or not (`eut-broken-module-same-outcome`). Only a program
  no loader built (core IR text, which declares no type) still has the plain
  `list`: there is no type to claim (`eut-no-loader-no-claim`).

## G. Implementation

| file | change |
|---|---|
| `core/native.tcl` | `contractTypes NS`: the `{TYPE NATIVE}` pairs of the `typed` shapes of `NS`'s natives, memoized per namespace and forgotten by `register` and `unregister`; `ValidShape` requires a `typed` NAME to be `std::NS::Name`; the shape's documentation |
| `surface/modules.tcl` | `ContractTypes` (the fixpoint that loads contract modules, skipping a module the library at hand lacks, then checks each loaded one declares its type), `ContractOwners` (an import environment's reachable namespaces to `OWNER -> {NAME -> NATIVE}`), `ContractModules` (their sorted owners, for the cache), `ContractError` (the COMPILER-INTERNAL failure); called by `BuildProgram` and `LoadNamespaces` after the import closure and before reference errors are raised; the header's account of loading |
| `hir/types.tcl` | `ShapeResult`'s `typed` case: the fallback only for an undeclared NAME (no loader), an unproven domain a COMPILER-INTERNAL failure; comments |
| `surface/cache.tcl` | `Dependencies` adds the contract modules' paths (`surface::modules::ContractModules` of the HIR's import environments), there or not |
| `compilerpedia/notes/stdlib.notes` (and the generated page) | `encode_utf8`'s note and examples, `decode_utf8`'s note (section O) |
| `docs/README.md`, `docs/IMPORTS.md`, `docs/STATIC-COMPLETION-PROOFS.md`, `docs/SYMBOLIC-TYPE-IDENTITY.md`, the census | the unconditional contract, the loading rule, update notes |
| `tests/encode-utf8-type-stability.test` | new, 40 tests |
| `tests/symbolic-type-identity.test`, `tests/loop-clause-binding-types.test`, `tests/text-collection-docs-diagnostics.test` | expectations of the old conditional rule flipped |
| 16 more test files, the golden case `methods-list-without-str.bot` and its manifest row, the method-sugar fuzzer | the loaded module stated, or a premise about the whole HIR narrowed to the entry program (section H lists each) |
| `audit/text-collection-precision/probes/` | `c3`, `c4`, `c5` updated, `c7` added |
| `audit/text-collection-docs/tools/mutants.txt` | M2's documentation mutant rewritten to the new text (same rule) |
| `audit/encode-utf8-type-stability/` | the reproducer, the evidence and benchmark tools, the mutation catalog and harness |

The front-end cache needs no new key input. `surface::cache::Dependencies`
adds the paths of every contract module, derived from the HIR's import
environments exactly as the loader derives them
(`surface::modules::ContractModules`), there or not: an entry depends on
`stdlib/byte.bot`'s text when the module was loaded, and on its absence when
the library had none (`eut-cache-dependency`, `eut-cache-dependency-absent`).
A first version recorded the file as a loader probe; the cache round-trip
audit (`roundtrip.tcl -via cache`) refused it, since a caller with a HIR
alone must find every file the HIR was built from among its dependencies,
and the absent case was then no dependency at all. Every cache entry and
interchange text made by the previous front end is refused by the front-end
fingerprint, which covers `core/`, `hir/` and `surface/` (Inspected:
`surface::cache::Key`, `hir::interchange::fingerprint`). The interchange format does not change;
its content does (the loaded module's section and declarations).

## H. Observable semantic changes

**The corpus comparison (Executed).** `audit/method-resolution/tools/
invariance.tcl` recorded 282 programs with the front end of the pristine
`bd6f99f9` worktree and of the change -- every golden suite, the 2048 and Icy
Tower suites, every `.bot` file of `examples/` and `bench/`, the census's 19
probes and the reproducer pair -- each in a process of its own, `-strict 0`,
no cache, then compared them (`-compare`). One probe, `f1-escapes.bot` (a
deliberate syntax error whose truncated message the tool cannot read back as
a record), was compared as raw text instead: identical.

| compared | differences |
|---|---|
| method-call decisions (`methodDecided`) | none |
| every call's candidate (`methodChoices`) | none |
| static sites' outcomes | 1: `methods-list-without-str.bot`'s `x.complement()` block reifies MISSING-IMPORT, was NOT-A-STRUCT (below) |
| acceptance | 1: probe `c4`, now accepted (the intended correction) |
| reported diagnostics | 2: probe `c4` and `repro.bot` (the intended correction, section B) |
| HIR text of accepted programs | 108 programs, each now loading `std::byte`: the text grew by 5,695 to 6,178 characters (59 of them by exactly 5,981), `std::byte`'s section and declarations with the expression ids after them renumbered; the other 173 are identical |
| front-end counters, summed | identical: 602 builds, 122 method trial builds, 22 single deviations, 5 final rebuilds, 88 reused builds, 9 reported forms |

No program gained or lost a diagnostic other than these, and no method
decision, static decision or dependency-driven rebuild changed: the extra
module is code nothing calls (Inspected: no reachable function of `std::byte`
is introduced, and its functions are no method candidates where it is not
imported).

**Classification of every change found.**

| change | where | class |
|---|---|---|
| `encode_utf8()` is `List[std::byte::Byte]` without `std::byte`; `c4` accepted; the reproducer's three diagnostics gone; hovers and facts precise | every program reaching `std::str` | 1, the intended correction |
| `std::byte` (4 types, 2 errors, 8 functions) loaded into every program reaching `std::str` without it | the HIR, `-traits`'s declared types, native error numbering, the generic-blocker census (+6: its six untyped functions; natively never compiled, no guard emitted), the Tcl compiler's generated code (its eight functions as procs), front-end time (section N) | 2, a justified consequence: exactly what an import of `std::byte` by another module has always brought (Executed: `ai_text_clean.bot` with an explicit `import std::byte` on `bd6f99f9` has the new numbers) |
| `b.complement()` in a file not importing `std::byte` reports `std::byte`'s missing import, was "no function named complement is visible" | method-style calls of `std::byte`'s names | 2: still rejected, `complement` still no candidate; byte for byte the diagnosis `bd6f99f9` gives when `std::byte` is loaded through `std::abi::bytes` |
| a standard library whose `std::byte::Byte` contradicts the native (narrower domain, refinement, missing) fails as COMPILER-INTERNAL, was a silent `list` | a broken or test library only | 2: the contract is no longer optional, so a silent fallback could only hide a standard-library bug |
| none | -- | 3, unrelated regressions: none found |

**Tests that changed, and why (Executed).** Each changed expectation stated
the old conditional rule or assumed that a program importing `std::str`
loads no other module:

* the old rule, now flipped: `symbolic-type-identity.test` (five tests: no
  `Byte` loaded, the program's own `Byte`, the narrow and the non-Int
  `std::byte::Byte`), `loop-clause-binding-types.test`'s
  `lcb-unknown-elements`, `text-collection-docs-diagnostics.test`'s
  `tcd-doc-utf8-static-type`, probes `c3`-`c5`;
* the loaded module stated: `traits.test`'s `trait-report` (four more
  declared types), `error-payloads.test` (two more declared errors, native
  error number 2 -> 4), `native.test`'s `native-spec-14` and
  `hir-specialize.test`'s corpus and explanation tests (+6 generic blockers),
  `hir-aot.test`'s corpus statuses (`std::byte`'s eight functions listed,
  as `std::list`'s already were),
  the golden `methods-list-without-str.bot` case (MISSING-IMPORT; its manifest
  row marked weaker, so its Tcl original, whose program loads no module at
  all and is not expressible as a suite any more, runs locally again), the
  method-sugar fuzzer's hidden-module case;
* a premise about the HIR made explicit (the entry program's nodes, block
  ids normalized, NIR error numbers matched as any number, counts relative
  to the same program without its function): `stdlib-namespaces.test`,
  `method-sugar.test`, `structural-fn-types.test`, `std-namespace.test`,
  `hir-specialize.test`'s `hir-specialize-11`, `not-callable.test`'s
  `nc-method-binding-not-a-candidate`, `str-append-char.test`'s
  `str-append-char-method-is-the-intrinsic`, `exact-callable-key.test`,
  `direct-hir-native.test`, `checked-domain-proof-provenance.test` (whose
  fixed error numbers would otherwise have let its counts of 0 pass for no
  reason), `refinement-values.test`, `intrinsic-contracts.test` (core IR text
  has no declarations, so `std::byte`'s `errors` clauses come back as
  UNHANDLED-ERRORs of its own functions there); the census's type matrix
  takes its `unknown` column from a List erased to the bare `list` (it used
  `encode_utf8` without `std::byte`) and is the census's again, cell for
  cell.

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
  from its entry, and gets the new declaration (`eut-cache-dependency`); in a
  library without `stdlib/byte.bot`, the entry (the plain `list`) is
  compiled again once the file appears (`eut-cache-dependency-absent`).
* **Isolation:** A, B, A in one process (`eut-isolation`, above).

## L. Backend parity

The change is front-end only: no backend, runtime, NIR instruction or
native registration's implementation was touched (Inspected: the diff
changes `core/native.tcl`'s registry query and shape validation, the
loader, `hir/types.tcl`'s `typed` result and the cache's dependency list),
so a backend sees a HIR whose one difference is the loaded module and the
more precise type. Executed, each through `sourceAgree` (tests/helpers.tcl:
the program compiled once, run on interp, compile, cranelift-generic and
cranelift, every outcome required equal) on Linux x86-64:

| test | what the four backends agree on |
|---|---|
| `eut-utf8-values` | encode_utf8's bytes for "", ASCII, a control character, Latin-1, a BMP and an astral character and mixed text, against bytes written out in the test: `[[], [65, 122], [9, 10], [195, 169], [226, 130, 172], [240, 159, 152, 128], [97, 195, 169, 226, 130, 172, 240, 159, 152, 128]]` |
| `eut-every-context` | one program indexing a 256-entry table by elements reached directly, by method syntax, through a collecting loop, a fold, an undeclared result, an anonymous struct's field, a closure's capture, a nested List and a lockstep loop: 23 values |
| `eut-c4-c5-same-outcome` | probes `c4` (no `std::byte`) and `c5` (with it): one outcome, `[105, 196, 170, 109, 109, 112]`, for both |
| `eut-instances-order-independent` | the two orders of the semantic-instance program (section I) |

The evidence tool (`audit/encode-utf8-type-stability/tools/evidence.tcl`)
runs `c4` and `c5` through `main.tcl` on the four backends with each tree:
on `bd6f99f9`, `c4` is rejected (two UNHANDLED-ERRORs) and `c5` prints
`[105, 196, 170, 109, 109, 112]` everywhere; after the change both print it
everywhere (Executed). `eut-modules` runs its consumer on interp and
cranelift (section J).

**The single-file compiler (Executed).** `single/build.sh` built it from
this change (the cached base kit of Tcl 9.0.1; the native backend's cargo
step a no-op, the release build being current). From an empty directory,
with an empty environment (`env -i HOME=DIR`), it runs probes `c4` and `c5`
on interp, compile, cranelift-generic and cranelift to
`[105, 196, 170, 109, 109, 112]` each; `botlish run c4-unused-import-decides.bot`
exits 0; `botlish -check repro.bot` reports the reproducer's one deliberate
diagnostic, `argument type: int[std::byte::Byte], facts: [0, 255]`. Its
packed `stdlib/` holds `std::byte`, so nothing is installed for the contract.
`single/smoke-test.sh` on it passed (every backend runs the sample programs
to the same values, -help, the inspection options, executables with the
stub linker, -aot-run, -lsp, the package commands; no toolchain, no PATH,
a fresh HOME).

**Not executed here:** Linux AArch64, macOS AArch64 and Windows x86-64. The
change has no platform-dependent part (Inspected: no target, C ABI or
runtime code), and the census's probes import no platform module; whether
the hosts' CI agrees is reported in section M as their runs stand.

## M. Regression and mutation testing

**The milestone's own tests (Executed).**
`tests/encode-utf8-type-stability.test` has 40 tests; all pass on interp
and compile (their four-backend parts through `sourceAgree`). Copied into
the `bd6f99f9` worktree and run there, 30 fail and 10 pass. The 30 are the
rule (the result's type, the loaded module, its order and import
independence, every context, instances, modules, packages, interchange,
cache, isolation, the validation of a broken contract); one of them,
`eut-probe-native`, fails there only because `core::native::contractTypes`
does not exist yet. The 10 that pass state what must not change:
`eut-typed-parameter` (invariance), `eut-utf8-values` (values),
`eut-visibility-qualified`, `eut-element-is-int-and-byte`,
`eut-no-native-reachable`, `eut-no-loader-no-claim` (core IR text),
`eut-contract-module-absent`, `eut-scratch-library`, `eut-import-order`
and `eut-named-struct-census`.

**The census's probes (Executed).** `audit/text-collection-precision/
probes/`: 19 of 19 as their headers state (`c3` the precise types, `c4` and
`c5` accepted with one value, `c7` the visibility negative). The type
matrix (`tools/matrix.py`) prints the census's table cell for cell.

**Mutation testing (Executed).** `audit/encode-utf8-type-stability/tools/
mutate.tcl`: 18 mutants (`mutants.txt`: the loader's fixpoint, reachability
through modules, the import order, an implicit import, the process-wide
registry, the cache dependency, an undeclared type, an absent module, the
registry's memo, the shape's validation, three wrong result types, the
domain proof, the fallback, the semantic-instance walk, the loop element,
interchange's declarations), each applied to a private copy of the tree.
All 18 are killed, each by a test its `!!` line names (run on the final
tree: `tests/encode-utf8-type-stability.test` and
`tests/symbolic-type-identity.test` against each mutant). M2's documentation
mutant
(`audit/text-collection-docs/tools/mutants.txt`, `doc-static-type-
conditional`) now restores the old conditional sentence and is killed by
`tcd-doc-utf8-static-type`. `tools/mutant-catalogs.tcl`: every mutant of
every catalog still applies (0 problems).

**The harnesses of the subsystems the change touches (Executed, on the
change; each exit 0):**

| harness | result |
|---|---|
| `audit/compilation-isolation/tools/interleave.tcl` | 12 suites, 96 artifacts and outcomes compared, 0 differ |
| `audit/compilation-isolation/tools/mutate.tcl` | 14 mutants, 14 killed |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` | 12 suites, 108 compared, 0 differ |
| `audit/hir-interchange/tools/roundtrip.tcl -via cache` | 12 suites, 120 compared, 0 differ |
| `audit/hir-interchange/tools/mutate.tcl` | 29 mutants, 29 killed |
| `audit/bot-modules/tools/mutate.tcl` | 26 mutants, 26 killed |
| `audit/refactor/tools/gate.tcl` (the warning gate) | passed: the observed warnings are exactly the manifest |
| `audit/imports/tools/fuzz.tcl` | 60 programs, 0 disagreements of any kind |
| `audit/method-sugar/tools/fuzz.tcl -n 40`, seeds 11 and 23 | 0 equivalence disagreements, 0 negative escapes, 0 backend disagreements |
| `audit/static-decisions/tools/fuzz.tcl`, seeds 17 and 41 | 20 programs each, 0 failures (every layout gives the nested layout's verdicts); the same statistics as `bd6f99f9` run on the same seeds (seed 17: 484 sites, 260 rejected, 0 layout pairs taking different rounds; seed 41: 564, 340 and 2) |
| `audit/method-resolution/tools/oracle.tcl 200` | 200 programs, 1,128 calls, 0 disagreements |
| `tools/compilerpedia.tcl check` | 1,298 topics, 777 examples, 0 problems |

The batched-against-sequential comparison of the golden suites
(`static-decisions.yml`) is CI's alone (AGENTS.md); its state is below.

LOCAL-SUITE-PLACEHOLDER

## N. Performance

Executed: `audit/encode-utf8-type-stability/tools/bench.tcl` with the
compiler of the pristine `bd6f99f9` worktree (`-root`) and of the change, one
after the other, on the same 4-core container with nothing else running, each
program compiled 7 times in one process after a warm-up (no cache), then
once into an empty cache (a miss) and once from it (a hit). Times are
milliseconds of the whole front end (`surface::readProgramFile`); this is a
shared machine, so the fastest of seven is the figure to compare, and the
two large programs vary by more than the change between runs.

| program | fastest, before | fastest, after | median, before | median, after | modules | source types | interned types | interchange bytes | cache miss | cache hit |
|---|---:|---:|---:|---:|---|---|---|---|---|---|
| `str-call`: `import std::str`, one `encode_utf8` call | 3.9 | 19.3 | 4.1 | 23.2 | 0 -> 1 | 0 -> 4 | 3 -> 31 | 66,754 -> 101,919 | 7.1 -> 22.3 | 3.0 -> 3.3 |
| `str-nocall`: `import std::str`, no `encode_utf8` | 3.7 | 19.1 | 4.0 | 19.6 | 0 -> 1 | 0 -> 4 | 3 -> 31 | 66,584 -> 101,750 | 5.9 -> 22.1 | 1.3 -> 2.6 |
| `str-byte`: `str-call` with `import std::byte` | 21.2 | 18.9 | 22.5 | 19.6 | 1 -> 1 | 4 -> 4 | 31 -> 31 | 102,000 -> 101,931 | 27.3 -> 27.1 | 3.2 -> 3.6 |
| `modules-20`: 20 application modules each importing `std::str` | 63.3 | 79.7 | 66.3 | 90.7 | 20 -> 21 | 0 -> 4 | 45 -> 73 | 191,887 -> 230,387 | 74.4 -> 91.0 | 6.5 -> 7.3 |
| `instances-60`: 10 untyped helpers, 60 semantic instances | 101.7 | 124.0 | 112.5 | 128.5 | 1 -> 2 | 0 -> 4 | 33 -> 57 | 243,331 -> 281,463 | 119.7 -> 133.5 | 7.5 -> 9.2 |
| `examples/stdlib/csv_records.bot` | 580.4 | 585.8 | 596.3 | 639.1 | 2 -> 3 | 1 -> 5 | 113 -> 135 | 766,540 -> 803,321 | 743.4 -> 687.9 | 30.2 -> 29.7 |
| `examples/dfa/json/json.bot` | 1,836.0 | 1,619.1 | 2,018.3 | 2,065.7 | 4 -> 5 | 4 -> 8 | 137 -> 157 | 1,351,231 -> 1,386,896 | 2,148.6 -> 1,886.5 | 71.5 -> 68.0 |

What it shows:

* **The cost is `std::byte`'s front end, once per compilation, and nothing
  else.** `str-byte`, which imported `std::byte` already, does the same work
  before and after (one module, four source types, 31 interned types, the
  same interchange size within 70 bytes of ids; its times differ by noise).
  Every other program now pays what importing `std::byte` would have cost
  it: about 15 ms of front end (`str-call` 3.9 -> 19.3, `str-nocall` 3.7 ->
  19.1, `modules-20` +16, `instances-60` +22), one module, four source
  types, 20 to 28 interned types and 35 to 39 KB of interchange text.
* **It does not grow with the program.** Twenty modules importing
  `std::str` load `std::byte` once (`modules-20`: 20 -> 21 modules), and the
  60 semantic instances are 60 after as before: the type is
  argument-independent and makes no new instance (section I).
* **Whether the program calls `encode_utf8` does not matter**
  (`str-nocall`): the contract is the namespace's, decided before any
  analysis. This is the price of the rule being independent of how the
  native is reached (through a function value, a module, a package); a
  program importing `std::str` for `length` alone now pays the 15 ms too.
* **A cache hit stays cheap** (1.3 to 3.6 ms for the small programs): the
  entry holds the loaded module's text like any other module's, and reading
  it back builds nothing. A miss pays the build.
* **Real programs:** for `csv_records` and the JSON recognizer the
  difference is inside the runs' noise (their medians moved by +43 and +47
  ms and their fastest runs by +5 and -217 ms).

**What the backends compile (Executed, `main.tcl -emit-nir` and
`core::compiler::compileHir` with both trees).** Native lowering compiles
what the program reaches: the NIR of `str-call` and `str-nocall` is the same
before and after, line for line, but for the expression ids its `@` marks
carry (`@e3` became `@e82`: `std::byte`'s expressions are numbered first).
The Tcl compiler compiles every function of every loaded module, so it now
emits `std::byte`'s eight functions as procs: `str-call`'s generated code
grows from 392 to 5,975 characters (1 proc to 9) and `compileHir` from about
2 to 3-7 ms -- exactly what the program with `import std::byte` generated
before (5,987 characters, 9 procs). The values are unchanged.

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

**The single-file compiler's help (Executed).** `botlish -help
std::str::encode_utf8`, run by the single-file compiler built from this
change in an empty directory with an empty environment, prints the new note
("Its static type is List[std::byte::Byte] in every program that calls it:
importing std::str is enough, whatever else the program imports. ...") and
none of the old conditional text; it creates no file there. Its SIGNATURE
line still reads `std::str::encode_utf8(str) -> list`: the registry's result
kind, the same text the native's value type shows (section P), which the
note beneath it makes precise.

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
