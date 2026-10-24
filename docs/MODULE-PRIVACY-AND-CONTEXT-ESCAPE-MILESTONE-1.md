# MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md -- `private` declarations and the CONTEXT-RESOURCE-ESCAPE warning

Completion report. The milestone gives Botlish module-local declarations
(`private`), the warning ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md proposed for an
airlock that hands its raw foreign representation to ordinary callers
(`CONTEXT-RESOURCE-ESCAPE`), and uses both on the production SDL airlock of
the Icy Tower workload.

## Contents

1. Result
2. Language result: `private`
3. Warning result: `CONTEXT-RESOURCE-ESCAPE`
4. Icy Tower result
5. Repository evidence
6. Fuzzing and mutation
7. Contexts, context traits, tooling
8. Architectural conclusion
9. Remaining limitations
10. Files and what to run

## 1. Result

* **`private` is a module boundary for declarations.** Written first on a
  top-level declaration -- `private fn`, `private x = ...`, `private type`,
  `private refined type`, `private error`, `private struct` (opaque,
  context or both), `private enum`, `private trait`, `private context
  trait`, `private layout`, `private union layout`, `private extern c fn`
  -- it makes the declaration accessible to code of its own module only.
  One fact decides every check: the module declarations' `private` sets in
  the HIR (`moduleDecls`). Nothing exists at run time: the program a
  private declaration lowers to is the one its public spelling lowers to
  (`mp-no-runtime-representation`).
* **The rules it enforces**: another unit naming a private member, by any
  spelling -- qualified, rooted, as a value, a type, a construction, a
  `fail`, a handler, an `errors` clause, an `import type`, an enum case --
  is `PRIVATE-ACCESS` at the reference, with the private declaration as the
  related location; method syntax never sees another module's private
  function (it means what it would mean without it, and is
  `PRIVATE-ACCESS` only when nothing else applies); a private function
  implements no trait or context-trait requirement; a public declaration
  of a module may not expose a private type or error in its declared or
  inferred interface (`PRIVATE-TYPE-ESCAPE`), while an opaque struct may
  hold one as hidden representation. `private` and `opaque` are
  orthogonal.
* **`CONTEXT-RESOURCE-ESCAPE` reports the census's architectural mistake
  and nothing the repository ships.** On the original Icy Tower boundary
  (commit 6df89a8e, kept as `audit/icy-tower/context-refactor/baseline/`)
  it draws exactly the twelve warnings the census predicted (`color`,
  `clear`, `present`, `fill`, `line`, `text`, `scale`, `open`, `poll`,
  `close`, and the open structs `Video` and `Polled`), on the census's
  leaked-view reproducer g1 its one (`airlock::record`, R3), and on the
  refactored game, Design A (opaque values), the standard library, the
  generated bindings, the golden suites and the test and fuzz corpora none
  but the programs written to show it (section 5).
* **Icy Tower's airlock is now genuinely module-local.** Every `sdl.bot`
  function whose signature carries a C pointer, a native view or a native
  edit (ten, two of them new helpers returning one), every native-memory
  layout and the session record are private: 18 private declarations, the
  public API down from 33 declarations to 18 (the operations the game
  calls, and nothing else changed), the session looked up once instead of
  in nine places, no warning. Behavior is unchanged: the SDL call trace of
  a 2,400-frame autopilot run is identical call for call (204,299 calls),
  the golden suite, the independent Python oracle, the 26 rule mutants,
  GC stress, memcheck and Xvfb sessions all as before; the frame costs
  2,293 instructions (0.11%) more under the dummy driver (section 4).

## 2. Language result: `private`

### 2.1 Grammar

```
topStatement = [ "private" ] declaration | statement
declaration  = typeDecl | structDecl | enumDecl | layoutDecl | errorDecl
             | traitDecl | externDecl | function | binding
```

`private` is a contextual word, like every modifier (surface/parser.tcl's
`AtPrivate`): it starts a private declaration only directly before `fn`,
`struct`, `type`, `error` or a name (`opaque`, `context`, `nomethod`,
`enum`, `trait`, `layout`, `union`, `extern`, `refined`, or a module
binding's name), none of which can continue an expression, so a variable,
function or field called `private` is unaffected (`mp-parse-contextual`).
It is written first, before every other modifier (`private opaque context
struct`, `private nomethod fn`, `private context trait`), at most once
(`duplicate modifier "private"`), and only on a named top-level
declaration (`PrivateDecl`): nested in a function, loop or branch, before
an `extern c library` line (which names no member) or before a statement
it is a located syntax error. The modifier is a property of the one
declaration -- the node's `private 1` and `privateSpan`, its span widened
to the modifier -- never a declaration kind of its own; the AST printer
writes it first (`mp-parse-print`), and syntax recovery keeps it on a
damaged declaration (surface/recover.tcl's `Hole`).

### 2.2 Declaration coverage

| declaration | category | where access is checked |
|---|---|---|
| `fn`, a module binding `NAME = VALUE`, `extern c fn` | values | the loader (qualified and rooted references, a function taken as a value), method candidates |
| `type` (domain), `refined type`, `struct` (any modifiers), `enum`, `trait`, `context trait`, `layout`, `union layout` | types | the loader (type expressions, constructions, `import type`, enum cases, layout operands), field access through a value of the type, conformance |
| `error` | errors | the loader (`fail`, `on`, `errors` clauses, function types' `errors` lists) |

An `extern c library` line names no member and cannot be private. A
syntax-recovery hole whose valid prefix binds a name (`private fn NAME`,
`private NAME =`: SYNTAX-RECOVERY-MILESTONE-1.md) is recorded as a private
value of that name, so the recovered analysis never reports an access to
it that the repaired program would make legal or illegal differently.

### 2.3 Module identity

Access is decided by the canonical module identity -- the namespace path
the loader resolved (`std::linux::io`, `game`, `a::b`) -- and nothing
else: `hir::privacy::Denied DECLS NS CATEGORY NAME FROM` is 1 exactly when
FROM is not NS and NS's private set holds NAME. No import, parent or child
namespace (`a::b`'s private member is not `a`'s: `mp-identity-parent-child`),
entry program, short-name coincidence (an application `list` and
`std::list` are two modules: `mp-identity-same-short-name`) or holder of a
value grants access. The entry program may declare private declarations;
nothing imports it, so they change nothing, and its public declarations
are no other module's interface, so it is never judged for
PRIVATE-TYPE-ESCAPE (`mp-entry-program`).

### 2.4 `private` and `opaque`

They answer different questions and never imply each other:

| | who may name it | who may build and take it apart |
|---|---|---|
| `struct S` | every module | every module |
| `opaque struct S` | every module | its module |
| `private struct S` | its module | its module (no other module can even name it) |
| `private opaque struct S` | its module | its module |

`private` determines who may access a declaration; `opaque` who may inspect
a representation. A public opaque struct is an intended abstraction other
modules hold, pass and compare (`mp-opaque-not-private`); a private
non-opaque struct is the module's own record, whose fields the module uses
freely (`mp-private-not-opaque`); a public opaque struct may hold a private
type as hidden representation (`mp-no-escape-opaque-holds`), which is
exactly how Icy Tower's `Sdl` context holds the private `Session`.

### 2.5 Public signature validation (PRIVATE-TYPE-ESCAPE)

A public declaration of a module may not expose a private type or error of
its module in what other modules must name or see to use it:
`hir::privacy::verify` judges every public module binding (a function's
declared parameter types, its declared or else inferred result, its
declared errors, its proof clauses' types, its declared or inferred
context requirements; a value binding's type), every public struct's type
slots' trait constraints and -- unless it is opaque -- its fields, every
public layout's fields, every public refinement's carrier, every public
trait's requirements, every public error's payload fields and every public
extern's C signature. Types are searched structurally (`hir::privacy::Find`:
through applied types, Lists, sets, vectors, arrays, anonymous structs,
function and coroutine contracts, C function pointer signatures, views and
edits, refinements and fixed-array representations) but never into the
fields of a nominal type: a public struct holding a private one is judged
at that struct. An inferred result counts (`mp-escape-inferred`), and so
does an inferred context requirement (`mp-escape-inferred-context`): a
caller would have to install a context it cannot name. A private
declaration may expose anything. The diagnostic is located at the
exposing declaration, says what it exposes and where:

```
m.bot:4:1: public function m::handles exposes private type m::Handles in its result: every module may use m::handles, but only module "m" may use m::Handles (make m::handles private too, or keep m::Handles out of its public interface -- an opaque struct may hold it as hidden representation)
```

(for `private struct Handles: renderer: int` and `fn handles() -> Handles`
in module `m`: `mp-escape-message`).

### 2.6 HIR, interchange, isolation

The loader records each unit's declarations (`ModuleDecl`): `moduleDecls`
maps a namespace ("" for the entry program) to `{direct 0|1 origin ORIGIN
private {CATEGORY {NAME {kind KIND origin ORIGIN}}} declarations {CATEGORY
{NAME ORIGIN}}}` -- the private set and the declarations' name origins
(where PRIVATE-TYPE-ESCAPE of a type is located). Resolution keeps it as the
HIR's `moduleDecls`, which every check reads. It is HIR, not a registry:
compilation isolation holds by construction, HIR interchange keeps it with
the rest of the HIR dict (`mp-interchange`), the front-end cache's entries
are interchange text, and no backend, the Tcl compiler or native lowering
reads it (`mp-no-registry`). Past the source boundary (core IR text, HIR
text) there are no module declarations and nothing to check.

### 2.7 Method and trait resolution

* **Method syntax** (`hir::resolve::MethodCandidates`): another module's
  private function of the name is no candidate. With an accessible
  candidate of another module the call is that one, never ambiguous
  (`mp-method-not-a-candidate`); with none, a receiver's field of the name
  is called exactly as without the private function
  (`mp-method-field`); with neither, the call is `PRIVATE-ACCESS` at the
  method name, noting the call applies only a visible function
  (`mp-method-private-only`). Inside its module, method syntax reaches a
  private function as any (`mp-method-own-module`). A generic function's
  method call reaches no private function through an instance
  (`hir::semantic::DerivedKind` keeps the kind: `mp-method-generic`). A
  private function is never suggested as the import a method call needs
  (`mp-method-no-import-hint`).
* **Field access**: a value of another module's private struct, or a
  native view of its private layout, has no field another module may read
  (`hir::structs::PrivateRepresentation`); such a value cannot exist
  outside its module in a valid program (PRIVATE-TYPE-ESCAPE stops it at
  the boundary), and the access is typed as poison so its type does not
  leak into later diagnostics.
* **Traits and context traits**: conformance reads the witness's owner
  namespace's declarations (TRAITS.md, CONTEXT-TRAITS.md); a private
  function there implements no requirement, whatever its name -- a trait
  operation runs its implementation for code of any module -- and the
  conformance report says why (`m::describe is private to module "m": a
  private function implements no requirement ...`: `mp-trait-private-reason`).
  A public adapter beside a private helper satisfies the trait
  (`mp-trait-public-adapter`, `mp-context-trait-public-adapter`). A
  private trait-polymorphic function, cloned by the trait plan for its own
  module's calls, stays the module's (`mp-trait-plan-clones`).
* **References the build makes itself** (hir/resolve.tcl's
  `ResolveQualifiedRef`) are checked by the same rule, a second line
  behind the loader; no source program reaches it today (section 6).

### 2.8 Diagnostics

| kind | where | when |
|---|---|---|
| syntax errors | the parser | `private` nested, duplicated, on a library line or a statement |
| `PRIVATE-ACCESS` | the loader (with the declaration as related location); method calls; field access; the resolver's second line | another unit names or reaches a private member |
| `PRIVATE-TYPE-ESCAPE` | `hir::privacy::verify`, at the exposing declaration | a public declaration's interface names a private type or error |
| `TRAIT-NOT-SATISFIED` | conformance, with the privacy reason | a requirement's only implementation is private |

`static compile:` reifies PRIVATE-ACCESS as `std::compiler::DiagnosticCode::
PrivateAccess` (`mp-static-compile`); PRIVATE-TYPE-ESCAPE is a top-level
declaration's diagnostic, which no block can produce, and is classified so
in `sc-census-exhaustive`. Both have Compilerpedia topics
(`error.private-access`, `error.private-type-escape`), and the concept page
`concept.private` sets `private` beside `opaque` with the three examples
the brief asked for (a private function returning a raw pointer, a public
opaque resource value, a public contextual operation hiding private
foreign state). The PRIVATE-TYPE-ESCAPE pass reports independently of
other diagnostics (`mp-escape-independent`).

## 3. Warning result: `CONTEXT-RESOURCE-ESCAPE`

### 3.1 The rule

A module U is an **airlock** when the direct-module analysis proves it
`contextualized` (DIRECT-MODULES.md: U makes direct calls -- a retaining C
call, a native view or edit made from a pointer, a call of a direct
module -- and a context U declares mediates every one). For every
reference, in a unit V other than U, to a **public** member M of an airlock
U (hir/resourceescape.tcl), warn when V can take U's raw foreign
representation:

* **R2** -- the result V receives from a call of M, an argument V passes
  to it, or M's value (M taken as a value, or a module binding) holds a C
  address (`Ptr`, `FnPtr`): the address itself, or inside a List, set,
  vector, array, anonymous struct, function result or struct whose
  representation V may read;
* **R3** -- the same with a native view or edit (`NativeView`,
  `NativeEdit`): read or write authority over native memory, pointers
  included, needing no authority to use;
* **R4** -- V constructs, projects or destructures a struct of U whose
  representation holds such raw representation (a destructuring is one
  site: its statement's).

### 3.2 Stopping rules and exclusions

* **Opaque stopping rule.** A struct another module may not read -- opaque,
  or private, and declared by a module other than V -- stops the search
  (`hir::resourceescape::Sealed`). A public opaque resource value crosses
  freely: it is an intended abstraction (the census's Design A). An
  operation that hands out the pointer inside it still warns
  (`ce-opaque-accessor-warns`).
* **Private stopping rule.** A private member of U is never a crossing, so
  a private helper may take and return pointers and views
  (`ce-private-stops`, `ce-private-view-helper`). For members it holds by
  construction: no other unit can reference one (the loader rejects a
  written reference, method syntax never binds one), so the warning has no
  check of its own. For values the analysis states it: a private struct
  of U, like an opaque one, stops the search, so an analysis of a lenient
  HIR never reports a privacy violation a second time
  (`ce-private-stops-lenient`). A public alias of a private helper is a
  public member, and its crossings are its own (`ce-private-alias-public`).
* **Provenance rule.** An argument is reported only when V has no raw
  authority of its own (V is not direct, provided or contextualized): a
  pointer an ordinary module passes in can only have come from an airlock
  or C, while a direct module or another airlock may pass its own resource
  for U to use. A result is always U's (`ce-provenance-direct-caller`).
* **Never reported**: references inside U (`ce-inside-airlock`); members of
  an ordinary module (`ce-ordinary-module`: it mediates nothing) or of a
  designated direct module (`ce-direct-module`: a raw layer by
  declaration); values with no raw representation (`ce-values-only`);
  trait operations, whose types are the trait's contract, written by its
  declarer (`ce-trait-operation`); `extern c fn` bindings (C calls are the
  direct-module analysis's).

### 3.3 Evidence, deduplication and location

The warning is evidence-based: a public pointer-returning function no
other unit references draws nothing (`ce-unused-no-warning`) -- a warning
without use would be a lint on a declaration, which Botlish's warnings do
not do. It reads the program as written (the trait plan's checked source
build, `traitSource`), so a function the plan clones counts once and a
trait call is still a trait call. It runs after every check, on a program
with no diagnostic, like every warning.

One warning per exposing declaration of U -- the function or binding (R2,
R3) or the struct (R4): where the fix is -- located at the declaration (a
function's line, a struct's name), with, per consuming unit, how it crosses (passes one in, receives
one, takes it as a value, constructs, reads the fields, destructures), its
number of crossing sites (distinct source locations) and its first one,
which is also the warning's related location (`ce-one-per-declaration`).
Consumers are listed in the order of their first crossing. The text names
the first raw value found and where:

```
sdl.bot:262:1: warning: sdl::color exposes a raw C pointer (parameter `renderer`: std::ffi::c::Ptr[sdl3::ctypes::SDL_Renderer]) across the boundary of module "sdl", which mediates its raw authority through its context sdl::Sdl: module "render" passes one in (16 calls; first at render.bot:39:30). Keep the resource behind the context and give module "sdl" an operation that takes and returns values, or seal the resource in an opaque struct (CONTEXT-RESOURCE-ESCAPE)
render.bot:39:30: note: a crossing of this resource
```
```
sdl.bot:71:8: warning: sdl::Video holds a raw C pointer (in its representation, at .window: std::ffi::c::Ptr[sdl3::ctypes::SDL_Window]) and its representation is open across the boundary of module "sdl", which mediates its raw authority through its context sdl::Sdl: module "render" constructs it and destructures it (2 sites; first at render.bot:146:5). Keep the resource behind the context, or declare sdl::Video opaque so that only module "sdl" can build and take it apart (CONTEXT-RESOURCE-ESCAPE)
render.bot:146:5: note: a crossing of this resource
```

The record's `data` holds the declaration, the module, the rules (`R2`,
`R3`, `R4`) and the consumers with their site counts: stable for tests
and tooling.

### 3.4 Policy

An ordinary warning, on by default, in Botlish's one policy
(`-warnings default|off|error`): under `error` the first one is the
compilation's error with the warning's own code (`ce-warnings-error`),
under `off` no pass runs (`ce-warnings-off`). No opt-out, fixit, level or
suppression: the responses are the author's -- an operation that takes and
returns values, an opaque struct, `private`, or a redesign. It never
changes what a program means: the HIR of a warned program is the one
built under `-warnings off`, but for the attached warnings
(`ce-no-semantics`). The warning gate is unaffected: no corpus program
draws one.

### 3.5 Examples and non-examples

The Compilerpedia page `warning.context-resource-escape` has a realistic
warning (an airlock's `renderer()` handed to an ordinary module) and three
non-warnings: the pointer behind a private helper and a value-returning
operation, a public opaque resource value, and an ordinary raw module (no
context mediates its calls: a raw layer, not an airlock). It states the
airlock principle: raw foreign authority belongs in inspectable
architectural boundaries, and a context ordinarily exposes what callers
are allowed to do, rather than the raw representation with which it does
it. It does not claim that every public pointer API is unsafe: an
ordinary or designated direct module's pointers are its API.

### 3.6 Differences from the census proposal

| census proposal (section 11) | implemented |
|---|---|
| calls of U's functions only; a function taken as a value unseen | every reference: a call, a function taken as a value, a module binding's value (result direction for a value) |
| provenance "the natural refinement, if a case arises" | implemented: arguments from a unit with raw authority are its own |
| the instrument's R4 followed addresses through opaque structs | R4 stops at opaque and private structs (the census's own recommendation) |
| no private members existed | the private stopping rule |
| trait operations not discussed | skipped: the trait's contract |
| "hands a raw C pointer" | "exposes a raw C pointer", the struct form "holds ... and its representation is open"; both name the remedies |

Everything else -- the airlock definition, R2/R3/R4, the opaque stop for
R2/R3, the exclusions of ordinary and designated direct modules and of
calls inside U, one warning per declaration located there with the first
crossing and the site count -- is the proposal's.

## 4. Icy Tower result

The production workload is the refactored game the census left (its SDL
session owned by the installed `sdl::Sdl`, retained in native memory
behind a view; nothing of SDL above `sdl.bot`). Its architecture is kept;
privacy made the airlock's implementation module-local:

* the helpers are `private`: the census's seven pointer-taking ones
  (`write_text`, `log_failure`, `free_text`, `release`, `remember`,
  `quit_requested?`, `down?`), `write_text_unchecked` (it takes an edit)
  and the text helpers `nul` and `cstring`;
* the native-memory layouts `Handles`, `EventType`, `KeyState`,
  `TextBuffer` and the session record (`private opaque struct Session`)
  are private: no importer can name them;
* the nine repeated `sdl.open.at(0)` session lookups and their handle
  recovery are three private helpers, `session()` (the session),
  `handles()` (its native view) and `renderer()` (the renderer pointer),
  each a fallible contextual function; the drawing operations read
  `target = renderer(): on IndexNotFound: return false` and call SDL on it;
* the public API is the 18 declarations the game uses: `Sdl`, `create`,
  `SdlFailed`, `open`, `close`, `synced?`, `Polled`, `poll`, `seconds`,
  `sleep`, `counter`, `color`, `clear`, `present`, `fill`, `line`,
  `text`, `scale` -- unchanged, so `render.bot` and `main.bot` are
  untouched.

### 4.1 Before and after

Before is the tree this milestone started from (its `sdl.bot`, HEAD of
the branch point); measured by `audit/icy-tower/context-refactor/tools/
census.tcl` and the compiler.

| measure | before | after |
|---|---:|---:|
| `sdl.bot` declarations | 33, all public (no `private` existed) | 36: 18 public, 18 private |
| private declarations introduced | -- | 18 (13 functions, 5 types) |
| public declarations removed from the API | -- | 15 (10 functions, 5 types) |
| session lookups (`sdl.open.at(0)`) | 9 | 1 (`session`) |
| functions whose signature holds a pointer, view or edit | 8, all public | 10, all private |
| ... returning one (a raw result) | 0 | 2 private (`handles`: a view; `renderer`: a pointer), 0 public |
| pointer clones (`std::ffi::c::clone`) | 6 | 6 |
| cross-module pointer-bearing calls | 0 | 0 |
| CONTEXT-RESOURCE-ESCAPE warnings | 0 | 0 |
| `sdl.bot` code lines (no comments or blank lines) | 269 | 262 |
| `sdl.bot` functions / requiring `Sdl` | 25 / 20 | 28 / 23 |
| instructions a frame, SDL dummy driver (program's own) | 2,141,223 (488,709) | 2,143,516 (490,995) |
| instructions a frame, headless | 221,446 | 221,447 |
| mallocs a frame, dummy driver | 511.9 | 511.9 |

The tree before the milestone already drew no warning: its public
pointer-taking helpers were simply not called from outside -- public only
because a module had no private members (ICY-TOWER-CONTEXT-REFACTOR-
CENSUS.md, section 5). The
warning is evidence-based, so that was correct and is the reason privacy
was needed: the next `render.bot` that called `sdl::write_text` with a
pointer it got from `sdl` would have compiled and drawn a warning; now it
is `PRIVATE-ACCESS`. The original boundary draws twelve
(`workload-icy-tower-baseline-warnings`).

The six clones stay, as the brief expected: they are inside the airlock
(the renderer and window handed to SDL's destroy functions and the
scratch memory handed to `SDL_free`), and the census already showed they
are no case for observing parameters.

**Performance.** The frame costs 2,293 instructions more under the dummy
driver (+0.11% of the frame, +0.47% of the program's own instructions,
all in generated code: 24,707 to 26,993): each drawing operation now
returns its renderer through `renderer()`'s `IndexNotFound` handler rather
than reading `sdl.open.at(0).handles.renderer` inline. SDL's own
instructions, every C call count and the allocations are identical; the
headless frame (no SDL) is unchanged.

### 4.2 Behavior preserved

| check | result |
|---|---|
| golden suite (`examples/games/icy-tower/golden.bot`, four backends) and `tests/workload-icy-tower.test` | passes; the new tests `-sdl-helpers-private`, `-no-resource-escape`, `-baseline-warnings` with it |
| independent Python oracle (`audit/icy-tower/oracle.py compare`) | 0 differences |
| rule mutants (`audit/icy-tower/mutate.tcl`) | 26 of 26 killed |
| headless AOT executable, SDL dummy driver | identical summaries (`frames=2400 round=2 floor=27 score=270 ... rng=1790919090`) |
| GC stress (`BOTLISH_NATIVE_GC_STRESS=1`) | identical summaries |
| valgrind memcheck (dummy driver) | 0 errors, 0 bytes lost (544 bytes still reachable, SDL's own) |
| Xvfb sessions (`audit/icy-tower/tools/xvfb-session.py`, an SDL3 built with the x11 driver) | 6 of 6 checks, before and after |
| SDL call trace (`trace-compare.sh OLD NEW`, 2,400 autopilot frames) | identical: 204,299 calls, every draw, poll and release with its arguments; the failure paths' traces identical too |

No intentional call-trace difference exists: the helpers only factor the
lookup the operations already made.

The committed executable `audit/icy-tower/artifacts/icy-tower` is rebuilt
from the new sources.

## 5. Repository evidence

The census's corpus was compiled again, now with the compiler's warning
(`audit/module-privacy/tools/warning-census.tcl`, results in
`audit/module-privacy/census/`): the same unit builders and scanners
(`units-a.tcl`, `extract-tests.tcl`, `extract-fuzz.tcl`, `scan.tcl`,
`scan-b.tcl`, the instrument `escape-candidates.tcl`), unchanged, with the
warning pass applied to the HIR each scan builds -- the front end's own
last step under `-warnings default` -- and every crossing the warning
counted set beside the instrument's sites and the census's classification
of the same location.

Partition A is the census's units-a.tcl corpus (libraries, examples, the
Icy Tower baseline 6df89a8e and working tree, benchmarks, golden suites,
generated bindings, audit programs) plus the opaque-values (Design A) and
canvas variants staged beside the 4be79514 modules they were written
against; partition B is the Tcl tests' embedded programs (the test files
census-b.tcl selects, this milestone's two among them) and 30 programs of
each of six fuzzers (seed 1).

| | partition A | partition B | the earlier census (A / B) |
|---|---:|---:|---:|
| units | 830 | 1,648 | 765 / 1,494 |
| compiled | 750 | 889 | 704 / 901 |
| the instrument's sites, all buckets | 59 (49 hit, 10 no-context) | 34 (22 hit, 1 context-but-ordinary, 4 designated-direct, 7 no-context) | 59 / 9 |
| CONTEXT-RESOURCE-ESCAPE warnings | **13** | 15 | 13 predicted / 0 |
| crossing locations the warnings counted | 41 | 17 | 41 SUSPICIOUS sites / 0 |
| PRIVATE-* rejections | 0 | 37 | -- |

**1,639 compiled programs**, against the earlier census's 1,605.

* **Partition A: the 13 warnings are exactly the census's 13 candidates**
  -- the original boundary's twelve (`sdl::color` 16 crossings from
  render, `fill` 9, `text` 3, `line` 2, `scale` 2, `clear` 1, `present` 1;
  `open`, `poll`, `close` from the entry program; `Video` constructed and
  destructured in render, 2 sites; `Polled` destructured in the entry
  program) and g1's `airlock::record` (R3). **Every one of the 41 sites
  the census classified SUSPICIOUS is a crossing the warning counted, and
  every crossing it counted is one of them; none of the 18 LEGITIMATE
  sites is warned** (Design A's sealed `sdl::Video` crossings and its
  `Polled`/`Shown` carriers, std::windows::io's calls of std::windows, the
  Tcl binding's demo). No false positive, no false negative, nothing
  UNDECIDABLE.
* **Nothing the repository ships warns**: the standard library, every
  example (the refactored Icy Tower included), the benchmarks, the golden
  suites and the generated bindings draw no warning, and the opaque-values
  and canvas variants none either (both compile beside 4be79514; canvas's
  `golden-check-draws.bot` is rejected with CONTEXT-FUNCTION-VALUE as its
  notes say).
* **Partition B's 15 warnings are all `tests/context-resource-escape.test`'s
  programs**, written to warn (14 units); its ordinary-module and
  direct-module programs are the instrument's context-but-ordinary and
  designated-direct sites, and draw none. None of the earlier census's 9
  LEGITIMATE sites (the native-view and native-edit tests' designated raw
  layers and their ordinary readers, std::windows::io) is warned. The 37
  PRIVATE-* rejections are `tests/module-privacy.test`'s (36) and
  `tests/context-resource-escape.test`'s lenient private-stop program (1),
  all on purpose; partition A has none.
* **Differences from the earlier corpus, and that none is this
  milestone's.** Partition A has 65 units the census did not (new audit
  programs since -- the DFA exploration, the syntax-recovery experiments,
  the baseline fixture compiled in place without its binding, which is the
  6df89a8e unit's twin -- and the five variant units), and four units
  changed outcome: the opaque-values and canvas variants staged over the
  working tree no longer compile, because they call `hud::int_text`, which
  NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md removed before this milestone (hence
  the units beside 4be79514). Partition B compiles fewer programs of six
  sets than the census did (c-abi-types, c-ffi, context-traits,
  direct-modules, native-view, native-edit: test and fuzzer changes since).
  To separate drift from this change, both partitions were scanned again
  on this milestone's starting revision (`warning-census.tcl` copied into
  a worktree of the branch point, its `-raw-out` compared unit by unit):
  every one of partition A's 829 units common to both revisions has the
  same outcome and error code (the 830th is the baseline fixture this change
  adds), and so does every one of partition B's 1,391 common units (the 87
  others are the two new test files' programs). The instrument's sites are
  the same 59 in partition A on both revisions; there the starting revision
  warns nowhere (it has no warning), and this one at exactly the census's 41
  SUSPICIOUS sites.

## 6. Fuzzing and mutation

**The fuzzer** (`audit/module-privacy/tools/fuzz.tcl`) generates
applications of a module `u`, a consumer (the entry program, or a module
`v` the entry program imports) and the entry program, varied along every
dimension the two rules read: `u` an airlock, an ordinary module or a
designated direct module; three structs (Open: a pointer and an Int, open
representation; Sealed: opaque, holding a pointer; Plain: an Int), each
public or private; two to five functions of `u`, public or private,
taking nothing, an Int, a pointer, an Open or a Plain and returning an
Int, a pointer, a native view, a List of pointers, an Open, a Sealed or a
Plain (declared or inferred), requiring `u`'s context or not; public
value-returning wrappers of private pointer helpers; the consumer
ordinary, designated direct or an airlock itself; uses -- qualified calls,
method calls, function values, constructions and projections and
destructurings of Open -- and, about one program in eight, an illegal use
of a private member. Its model, written from the specification and never
from the implementation, predicts PRIVATE-ACCESS, PRIVATE-TYPE-ESCAPE or
the set of declarations CONTEXT-RESOURCE-ESCAPE reports, from the
generated source alone, and is compared with the compiler's `-strict 0`
diagnostics and its warnings' declarations.

Nine seeds of 80 programs (1 to 6 and 11 to 13): **720 programs, 469
accepted (227 of them warned), 251 rejected, 0 disagreements.** The first
run of seed 11 found one, in the model: a consumer taking apart a value of
a private struct that a public function had handed out (the
PRIVATE-TYPE-ESCAPE the model predicted) is also PRIVATE-ACCESS at the
field read, as `mp-private-struct-fields` specifies; the model now says so,
and the compiler was right.

**Mutation.** `audit/module-privacy/tools/mutate.tcl` applies each mutant
of its `mutants.txt` to a private copy of the tree and requires
`tests/module-privacy.test`, `tests/context-resource-escape.test` or the
fuzzer to fail.

**37 mutants, 37 killed** -- 21 of privacy (the parser, the loader's
record and every one of its checks -- qualified, rooted, type, error,
`import type` --, the access rule's own-module case, method candidates and
the private-only method call, the import hint, private struct fields,
trait and context-trait conformance, PRIVATE-TYPE-ESCAPE as a whole and its
inferred-result, applied-type, function-type and context-requirement
cases, the opaque exemption, HIR interchange) and 16 of the warning (the
result, parameter, nested-aggregate, view, function-pointer and R4 cases, the
opaque, private and provenance rules, ordinary and direct modules taken for
airlocks, crossings inside the airlock, one warning per call site, sites
counted per reference, trait calls counted, and the warnings read from the
monomorphized program). The fuzzer kills 15 of them on its own; the two
test files kill all 37. Two candidates were found equivalent and are not in
`mutants.txt`, each with its reason there: the resolver's second-line check
(no source program reaches it; the first run of the rooted-reference
mutant survived because that line caught it, which is now told apart by
the related location only the loader gives: `mp-access-message`), and a
separate private-member check inside the warning, which was removed: no
other unit can reference a private member, so the private stopping rule
holds for members by construction, and the analysis states it for values
(`Sealed`: `ce-private-stops-lenient`).

The changes touched code other harnesses mutate; every mutant of every
`audit/*/tools/mutants.txt` still applies (three texts updated:
compiler-service's `loader-unlocated` and `hover-internal-ids`,
diagnostic-recovery's `missing-import-once`), and those whose text overlaps
a changed line were run and killed (the three, diagnostic-recovery's
`missing-import-unknown`, traits' `break-opacity`, type-predicates'
`module-member-admits-type-predicate`). The Icy Tower rule mutants: 26 of
26 killed.

## 7. Contexts, context traits, tooling

* **Contexts are unchanged.** A private helper requiring `Sdl` is a
  contextual function like any: its requirement propagates to its callers
  inside the module (`mp-no-escape-opaque-context`: a private
  `get(context c: C)` called by a public `twice()`), and a public wrapper
  whose declared or inferred requirement is a private context is
  PRIVATE-TYPE-ESCAPE (`mp-escape-context`, `mp-escape-inferred-context`).
  Installation, satisfaction and context parameters are untouched.
* **`private` does not mediate authority.** A private helper's unmediated
  direct call still makes its module DIRECT (`mp-private-no-authority`):
  privacy is who may name a declaration, directness what a module's calls
  do.
* **Context traits.** A private function implements no context-trait
  operation; a public adapter over a private helper does
  (`mp-context-trait-private-impl`, `mp-context-trait-public-adapter`): a
  future SDL package can keep its raw helpers private and expose a public
  adapter satisfying an application-facing trait such as `Canvas`.
* **Tooling.** The compiler service's hover of a private function says
  `private fn ...` (`mp-hover-private`); definitions and references find
  private declarations as any (navigation is no access). The generated
  standard-library reference (`tools/compilerpedia.tcl generate`) lists no
  private declaration, and the standard-library census
  (`audit/stdlib-census/tools/census.tcl`) gives one the role `private`.
  The standard library declares nothing private: its declarations are its
  API. The language server has no document or workspace symbol listing yet,
  so there was no listing to filter. Compilerpedia's examples can now be
  applications (`@module NAME.bot`, COMPILERPEDIA.md), which privacy's
  examples need.

## 8. Architectural conclusion

**Can a contextualized module now use private helpers to manipulate raw
foreign resources internally while the compiler warns when it unnecessarily
exposes that representation to ordinary callers? Yes.** A contextualized
module's private helpers may take and return C pointers, native views and
edits; no other module can name them (`PRIVATE-ACCESS`), so nothing they
return can cross, and the warning never counts them. What the module makes
public is checked twice: its interface may not mention its private
records (`PRIVATE-TYPE-ESCAPE`), and a public member whose use by another
module hands out a raw pointer, a view, an edit or an open record holding
one is reported at that member (`CONTEXT-RESOURCE-ESCAPE`), while opaque
resource values -- deliberate abstractions -- cross without a warning.
Icy Tower's `sdl.bot` is now written this way.

**The original Icy Tower architecture would now be diagnosed**: twelve
warnings, one per exposing declaration, exactly the census's prediction
(the seven drawing functions taking the renderer, `open`, `poll`, `close`
carrying the open `Video`, and `Video` and `Polled` taken apart outside
`sdl.bot`). **The refactored one remains warning-clean**, under every
warning (`-warnings error` in its test), with its helpers now private.

## 9. Remaining limitations

* **Visibility features still missing, deliberately**: no `public`
  keyword, no `internal`/package level, no friends, no per-member
  visibility of struct fields (`opaque` is per struct), no re-exports or
  export lists. A future SDL3 package of several modules would need a
  package level to share helpers between its own modules without making
  them every importer's; today they must live in one module or be public.
* **Context-owned affine state remains separate**: the session still
  lives in native memory behind a view because a context cannot own
  affine values (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, 6.A). Privacy
  hides the record; it does not let the context own the pointers.
* **Resource ownership and lifecycle are untouched**: `close` is still an
  explicit call, an operation after it finds no session (`session()`'s
  `IndexNotFound`) and returns `false` rather than being a compile error,
  and nothing ties the resource's lifetime to the context's installation.
* **Warning cases not classified reliably**: provenance is judged by the
  consumer's raw authority, not by data flow -- an airlock passing another
  airlock's pointer back to it is not reported (it has raw authority of its
  own); a raw value reached only through a callable a member returns is
  reported as the member's result; and an airlock's open record that no
  operation hands out draws nothing until one does (evidence-based by
  design). Generic functions' instances are judged by the source build's
  types.
* **The resolver's second line** (`ResolveQualifiedRef`'s check of a
  reference the build makes) is unreachable from source today; it is
  tested only through the loader's absence.
* **Privacy is not a security boundary** against arbitrary foreign code: it
  is compile-time access control over Botlish declarations. C code, a
  native view someone else made, or another airlock's pointer are outside
  it.

## 10. Files and what to run

| file | what |
|---|---|
| `surface/parser.tcl` (`AtPrivate`, `PrivateDecl`), `surface/ast.tcl`, `surface/recover.tcl` | the modifier |
| `surface/modules.tcl` (`ModuleDecl`, `CheckPrivate`) | the fact and the loader's checks |
| `hir/privacy.tcl` | the access rule, messages, PRIVATE-TYPE-ESCAPE |
| `hir/resolve.tcl`, `hir/structs.tcl`, `hir/types.tcl`, `hir/semantic.tcl` | method candidates, the second line, field access, instances |
| `hir/traits.tcl`, `hir/contexts.tcl` | conformance |
| `hir/resourceescape.tcl`, `hir/warnings.tcl` | the warning |
| `hir/static.tcl`, `stdlib/compiler.bot`, `stdlib/test.bot` | `DiagnosticCode::PrivateAccess` |
| `service/service.tcl` | hover |
| `compilerpedia/` and `tools/compilerpedia.tcl` | `concept.private`, `error.private-access`, `error.private-type-escape`, `warning.context-resource-escape`, `@module` examples |
| `examples/games/icy-tower/sdl.bot`, `audit/icy-tower/artifacts/icy-tower` | the refactor |
| `audit/icy-tower/context-refactor/baseline/` | the original boundary (6df89a8e's modules), the warning's regression fixture |
| `tests/module-privacy.test`, `tests/context-resource-escape.test`, `tests/workload-icy-tower.test` | tests |
| `audit/module-privacy/tools/fuzz.tcl`, `mutate.tcl`, `mutants.txt`, `warning-census.tcl`; `audit/module-privacy/census/` | fuzzer, mutation, census |

**Regression.** The whole local suite (`tests/local.tcl`: every Tcl test
file on interp and compile, every golden suite on all four backends)
passes: 7,105 and 7,100 Tcl tests, 104 golden suites. Its first run found
three count pins that the new `DiagnosticCode` case and warning topic
moved (`sc-codes-one-to-one`, `gf-code-name-complete`, `cli-help-index`),
now updated. The warning gate passes; `tools/compilerpedia.tcl check`: 790
topics, 599 examples, 0 problems; the fuzzers of the code the change
shares -- method-filter, method-eligible, opaque-struct, direct-modules
(two seeds), the golden framework's -- report no disagreement.

To run after a change to any of it: the three test files,
`tclsh9.0 audit/module-privacy/tools/fuzz.tcl -seed S` for several seeds,
`tclsh9.0 audit/module-privacy/tools/mutate.tcl` (every mutant killed),
and for a change to what the warning reads,
`tclsh9.0 audit/module-privacy/tools/warning-census.tcl` (about half an
hour on four cores).
