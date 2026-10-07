# Context traits: trait-aware contexts, portable I/O and textual paths

```botlish
import io
import linux::io
import linux::path
import str

fn run(value: str) -> unit errors WriteFailed:
    linux::path::validate(value):
        on NotAPath:
            io::write_error_line(str::concat(value, " was not a valid path"))
            return unit
    io::print_line(str::concat("Reading config at ", value))   # value: a LinuxPath, still a str

with context linux::io::create()

run("config/tool.json"):
    on WriteFailed:
        unit
```

> Traits abstract values, context traits abstract execution environments,
> refinements establish propositions about values, and all three
> abstractions disappear before runtime dispatch is necessary.

This milestone adds one declaration form and three library modules:

* **`context trait`** (`context trait IO: fn write_text(text: str) -> unit
  errors WriteFailed`): an environment abstraction. A function declares
  `context io: IO`; a concrete installed context (`linux::io::LinuxIO`)
  satisfies `IO` structurally, through its owner's own functions
  (`linux::io::write_text(text: str, context io: LinuxIO)`); a top-level call
  that needs `IO` selects, statically, the one installed context that
  implements it; the compiler clones every function that needs `IO` for that
  selection and turns `io.write_text(text)` into the direct call
  `linux::io::write_text(text)`. Nothing exists at run time: no slot, tag,
  provider table, dictionary, hidden argument or dispatch.
* **`io`** (lib/io.bot): the portable text-output surface -- `io::print`,
  `io::print_line`, `io::write_error`, `io::write_error_line` -- over the
  context trait `io::IO`, with the one error `WriteFailed`.
* **`io::path`** (lib/io/path.bot): the portable textual path trait
  `io::path::Path` (`concat`, `text`) and the error `NotAPath`.
* **`linux::path`** (lib/linux/path.bot): `refined type LinuxPath = str`,
  its predicate `valid?`, its validator `validate`, and `concat`/`text`, which
  make `LinuxPath` satisfy `io::path::Path`.

Validators -- `-> unit proves x: R`, proof by normal completion -- already
existed (REFINEMENT-VALUES.md, "Validators", merged before this milestone);
this milestone uses them for paths and pins the facts it relies on.

## Contents

1. [Language](#1-language)
2. [Satisfaction](#2-satisfaction)
3. [The context-trait binding](#3-the-context-trait-binding)
4. [Selection](#4-selection)
5. [Requirements and diagnostics](#5-requirements-and-diagnostics)
6. [Specialization and lowering](#6-specialization-and-lowering)
7. [HIR, tooling and APIs](#7-hir-tooling-and-apis)
8. [The `io` library](#8-the-io-library)
9. [Paths](#9-paths)
10. [Validator proofs](#10-validator-proofs)
11. [Evidence](#11-evidence)
12. [Tests, fuzzing, mutation testing](#12-tests-fuzzing-mutation-testing)
13. [Regression and audits](#13-regression-and-audits)
14. [Limitations and what remains](#14-limitations-and-what-remains)
15. [Context maturity](#15-context-maturity)
16. [Milestone report](#16-milestone-report)

---

## 1. Language

```
traitDecl        = [ "context" ] "trait" IDENT ":" NEWLINE INDENT
                   traitRequirement { traitRequirement } DEDENT
traitRequirement = "fn" IDENT "(" [ paramList ] ")" [ "->" typeExpr ]
                   [ "errors" IDENT { "," IDENT } ] NEWLINE
contextDecl      = IDENT ":" typeExpr        (a context struct or a context trait)
```

* **`context` is the same declaration modifier** as on `context struct`: one
  more declaration it applies to, recorded as one boolean (`context 0|1`,
  `contextSpan` on the one `traitdecl` AST node; `context 1` in the trait
  registry; ` context` on HIR text's trait line). There is no `interface`,
  `provider`, `service` or `capability` declaration.
* **Contextual.** `context trait NAME` is a declaration only at the start of a
  top-level statement (`surface::parser::AtTraitDecl`: modifier words, then
  `trait`, then a name). `context` and `trait` stay ordinary names everywhere
  else: `context = 3`, `trait = 4`, `fn f(context, trait)`, a field `context`
  (`ct-contextual`). `context` is the one trait modifier: `opaque trait`, a
  repeated `context` and `opaque context trait` are syntax errors with their
  own messages (`ct-modifiers`).
* **Requirements have no receiver.** The installed context is the implicit
  receiver, so every parameter is an ordinary value parameter, and a
  requirement may take none (`fn tick() -> int`). Parameters are ordinary
  types (or untyped, `any`); results are ordinary concrete types; `errors`
  names declared errors.
* **Declaration diagnostics** reuse the ordinary trait codes where the rule is
  the same (`ct-declaration-diagnostics`):

| code | when |
|---|---|
| `TRAIT-EMPTY` | no requirement |
| `TRAIT-REQUIREMENT-BODY` | a requirement with a body |
| `TRAIT-REQUIREMENT-FLAGS` | a requirement with flags |
| `TRAIT-CONTEXT-REQUIREMENT` | a requirement with a context parameter ("the installed context is the requirement's implicit receiver") |
| `TRAIT-OTHER-TRAIT` | an ordinary trait or a context trait as a requirement parameter or result |
| `TRAIT-DUPLICATE-REQUIREMENT` | two requirements of one name |
| `TRAIT-NAME-COLLISION` | a context trait named like a type, struct, built-in or trait |
| `TRAIT-NESTED` | a declaration nested in a function |
| `UNDECLARED-ERROR` | an unknown error in `errors` |

**Identity and imports** are an ordinary trait's: `io::IO` for lib/io.bot's,
the bare name for the entry program's; `import type io::IO` binds the short
name; context traits share the type namespace.

**Context parameters** (`fn f(text: str, context io: IO)`) are unchanged in
form: the context section, last, `NAME: Type`. The type may now be a context
struct (exact, nominal: CONTEXTS.md, unchanged) or a context trait. One
function may have both (`context a: A, out: Out`); one context trait twice
is `DUPLICATE-CONTEXT-PARAMETER`; an ordinary trait as a context type is
`NOT-A-CONTEXT` ("an abstraction over values, not a context").

## 2. Satisfaction

`hir::contexts::satisfiesTrait CONTEXT TRAIT` (CONTEXT a context-struct
identity or its `{nstruct ID}` type) decides whether a concrete context
struct satisfies a context trait. For context struct `W` with owner namespace
`O` (the module that declares it, or the entry program), and every
requirement `R`:

1. **Owner-only lookup.** `O`'s own top-level function named `R`
   (`hir::traits::ImplInfo`, the per-build index of every unit's top-level
   definitions, the one ordinary traits use). Imports, the call site, the
   calling program's own functions and every other namespace take no part
   (`ct-owner-only`: a correctly typed `emit` in the entry program and in an
   imported module implements nothing).
2. **Exactly one context parameter, of `W`.** The implementation's context
   section is its implicit receiver: no context parameter, two of them, or one
   of another context type is a mismatch. The context parameter is not part of
   the ordinary arity (nor, as for every context parameter, of the machine
   ABI): requirement `write_text(str)` matches
   `write_text(str, context LinuxIO)`.
3. **The existing structural function compatibility** on the ordinary
   signature (`hir::types::FnMismatch` through `hir::traits::Mismatch`): same
   arity; parameters contravariant under declared-parameter admissibility (an
   untyped parameter admits anything); result covariant, and declared when
   the requirement declares one; the implementation's errors a subset of the
   requirement's (fewer is fine). No context-trait-specific variance rule.
4. **No flags** (as for ordinary trait implementations).

The result is `{ok 0|1 trait TRAIT witness W owner O impls {REQ IMPL ...}
reason WHY requirement NAME found TEXT}`; `impls` is the static requirement
-> implementation mapping (`{kind block unit O name NAME binding B block E}`),
never materialized. Cached per compilation on `{W, TRAIT}`, cleared with the
implementation index: two importers of one context and one trait get one
answer and one mapping (`ct-two-importers`), and imports change nothing
(`ct-import-independence`). `hir::traits::satisfies` (values) answers no for
every context trait.

`hir::contexts::explainTrait CONTEXT TRAIT ?HIR?` is `""` or:

```
cx::param::C does not satisfy cx::out::Out
required:
    fn emit(int) -> int errors WriteFailed   (declared at .../cx/out.bot:5:8)
found:
    fn cx::param::emit(str, context cx::param::C) -> int errors WriteFailed   (at .../cx/param.bot:5:4)
parameter 1 requires str, which does not admit the required int
```

`ct-explain-mismatches` pins every reason: a wrong parameter, a wrong
result, an error the requirement does not admit, another context type, no
context parameter, two context parameters, no implementation, a wrong arity,
no declared result, a value binding, flags -- and that fewer errors and a
wider (untyped) parameter satisfy.

## 3. The context-trait binding

Inside `fn print_line(text: str, context io: IO)`, `io` is source-visible only
as the context trait. Its one use is calling one of `IO`'s operations on it:
`io.write_text(...)` (method syntax; the operation is the trait's requirement
of that name, typed from the requirement with no receiver parameter --
`hir::traits::TypeCall`, the ordinary trait-operation rule, marks the call
`traitCall {... context 1}`). An undeclared operation is
`TRAIT-UNKNOWN-OPERATION` ("context trait Out has no operation "k" (its
operations: emit)").

Every other use is `CONTEXT-TRAIT-MISUSE` (`hir::contexts::CheckTraitBindings`):
returning it, passing it (to a parameter of the only installed context's own
type, to an untyped parameter, to an ordinary-trait parameter), projecting a
field of the hidden context, type-testing it, comparing it, storing it in a
List, using it as a condition -- whatever is installed, also in a function
nobody calls (`ct-one-way`, `ct-orthogonal`). The check is syntactic over
HIR: a reference to a context-trait binding must be the receiver of a
method-syntax call. The diagnostic is promoted ahead of the type errors it
causes.

**Not a value type.** A context trait is rejected everywhere a value type
goes -- an ordinary parameter, a result, a struct field, a List or
MutableArray element, a function type (`CONTEXT-TRAIT-POSITION`), a
refinement carrier (`REFINEMENT-CARRIER`), an ordinary trait's requirement
(`TRAIT-OTHER-TRAIT`) (`ct-positions`). An ordinary trait view cannot be
installed (`CONTEXT-TYPE-NOT-EXACT`).

**No witness leakage.** The binding's static type is `{trait IO}` (the
`context#load` of a context-trait key, `hir::types::ShapeResult`), never the
selected context's struct type; the selection is made after checking, from
the installations, and only the monomorphization plan reads it. The body is
checked once, against `IO` alone.

## 4. Selection

At every reachable top-level call (`hir::contexts::verify`, `Obligations`),
for every context trait in the callee's requirement, the compiler collects
the contexts **installed at that source position** that satisfy it:

| installed providers | result |
|---|---|
| 0 | `MISSING-CONTEXT` (with the chain and every installed context with why it does not implement the trait) |
| 1 | selected, statically |
| 2+ | `AMBIGUOUS-CONTEXT-IMPLEMENTATION` (every provider, in installation order, and the chain) |

No ranking, no "most specific", no installation-order or namespace
preference: installation order changes nothing (`ct-ambiguous-diagnostic`).
`ct-select-matrix` is the acceptance matrix: two contexts A and B
implementing one trait; only A installed selects A's implementation (value
13), only B selects B's (1001), both are ambiguous, neither is missing --
the same program text, no runtime branch.

**Source position.** Installation is the entry program's top level, in
source order (CONTEXTS.md): a call before the installation is missing; a
context installed after a call does not make that call ambiguous
(`ct-source-position`).

**One selection per trait.** Installation only grows, so every call that
finds exactly one provider of a trait finds the same one: verification
records each call's selection (`contexts selections`) and the program-wide
`contexts selected` they agree on (a disagreement would be the internal
`CONTEXT-TRAIT-INTERNAL`) (`ct-selection-recorded`).

**The implementations' own requirements.** Once the selection binds an
operation to `W`'s implementation, that implementation is a call the
requiring call makes: its own requirements (another exact context, another
context trait) are this call's obligations, checked the same way, with the
chain through the implementation (`ct-implementation-obligations`):

```
MISSING-CONTEXT: ct::clock::Clock is required by this call but is not installed here (...):
    ct::app::run
     -> ct::out::twice
        directly requires ct::out::Out, which installed context ct::timed::Timed implements:
     -> ct::timed::emit
     -> ct::clock::now
        directly requires ct::clock::Clock
```

**Exact contexts are unchanged.** `context x: LinuxIO` still requires exactly
`LinuxIO`; a context implementing a trait never satisfies an exact
requirement of another type, and exact requirements are checked exactly as
before (the messages are byte-identical; `ct-exact-contexts-unchanged` and
all of tests/contexts.test).

## 5. Requirements and diagnostics

The context fixed point (CONTEXTS.md) is unchanged and now carries
context-trait identities beside context-struct identities:

```
direct(B)    = the contexts B's own region loads: context structs and context traits
required(B)  = direct(B) ∪ ⋃ required(E) for every function E that B's region calls
```

`fn twice(n, context out: Out)` directly requires `Out`; `ct::app::run`, with
no context parameter, requires it transitively (`ct-transitive`), and
intermediate functions receive nothing. A trait operation (`out.emit(n)`) is
never a call edge, whatever function of that name its method syntax sees
(its implementation is bound only in the monomorphized program). Reasons are
kept per (function, identity) and diagnostics print the shortest
deterministic chain (`ct-missing-chain`):

```
MISSING-CONTEXT: Out is required by this call, but no installed context implements it (...):
    main
     -> render
     -> twice
        directly requires Out
installed contexts:
    none
```

**Unreachable consumers require nothing**: functions nobody calls, calls in
statically unreachable code, a nested function its enclosing function never
calls (`ct-unreachable-requires-nothing`, with nothing installed).

**Function values**: a function whose requirement includes a context trait
has a non-empty requirement, so the existing frontier applies unchanged
(`CONTEXT-FUNCTION-VALUE`); an alias in statement position is called like the
function (`ct-function-value-frontier`). No new escaping case exists:
clones are bound and called like any function, and a clone's requirement
(the selected context's exact identity) keeps it under the same frontier.

## 6. Specialization and lowering

Context traits use the eager-trait monomorphization (TRAITS.md,
"Specialization"); a program declaring any trait or context trait is
checked once with views and context-trait bindings (build 1), then built
again from the same syntax under a plan (build 2, `hir::traits::Plan`):

* **Context-trait-dependent functions.** Every top-level function whose
  requirement includes a context trait -- one that declares `context io: IO`,
  and every function that calls one, in any module -- is replaced by one
  **clone per selection**, `io::print_line<io::IO=linux::io::LinuxIO>`, keyed
  `{function, ordinary-trait witnesses, {TRAIT WITNESS ...}}` (one function
  can be polymorphic in an ordinary trait and a context trait at once:
  `both<ct::named::P,ct::out::Out=ct::a::A>`). Since there is one selection
  per trait, there is one clone per function.
* **Placement.** A clone is bound in the entry program immediately before the
  first top-level statement that needs it (directly or through other clones).
  This is what makes the rewrite possible across modules: lib/io.bot is
  loaded before lib/linux/io.bot (which imports it), and a library module
  calling `io::print_line` may be loaded before the provider too, so neither
  can call `linux::io::write_text` in place; the entry program sees every
  module. An implementation declared after the first code that needs it is
  `TRAIT-IMPL-ORDER` (`ct-implementation-order`).
* **Operations.** In a clone, `io.write_text(args)` becomes the direct call
  of the selected context's implementation with the written arguments only
  (`hir::resolve::ResolvePlannedCall`, action `context`): the binding that
  was the receiver is no value and is not evaluated. The context-trait
  binding itself is not created in build 2 (`hir::contexts::DeclareParams`).
* **Calls** of dependent functions from the entry program's top level and
  from clones call the clones; aliases of them are dropped and their calls
  redirected, exactly as for trait-polymorphic functions.
* **Dead code.** An operation, or a call of a dependent function, that no
  selection reaches -- in statically unreachable code, or in a nested
  function its enclosing function never calls -- never runs (every call of
  a function requiring a context is an exact call chain from a top-level call,
  which verification checked); build 2 compiles it to a call of the internal
  root native `context#unreachable()`, typed `never` (`-result-shape
  {never}`). The Tcl backends would raise if it ran; native lowering emits an
  `unreachable` trap. It is not a context lookup and has no arguments.

The monomorphized program -- the one every backend compiles -- contains no
context-trait operation, binding, load or type (`ct-mono-hir`,
`contextTraitFree`), only ordinary functions and direct calls; the checked
source program stays available as `traitSource` (what warnings read).

**Backends.** No backend implements selection or lookup. The interpreter and
the Tcl compiler run the core IR of the monomorphized program unchanged;
native lowering compiles it unchanged. The one backend touch is the
placeholder of dead code: `native/lower.tcl` lowers `context#unreachable` to
`unreachable` (core/contexts.tcl registers it like the two context
operations; hir/lower.tcl needed nothing).

**Native context area.** Unchanged: the installed `LinuxIO` occupies its
ordinary slot; a context trait never gets a slot, tag, presence word or table
(`ct-native-context-area`: `contexts=8`, one `context 0 "A"` line).

**No plumbing.** The portable call chain has no hidden argument, dictionary,
vtable, reserved register or runtime trait id. The selected implementation
(`linux::io::write_text`, `context io: LinuxIO`) loads its own descriptor
from its own slot through the existing exact-context machinery; everything
between the top-level call and it is an ordinary call with its ordinary
operands.

## 7. HIR, tooling and APIs

HIR text (hir/format.tcl, read back by hir/read.tcl; `ct-hir-text`: a one-file
program reads back to the same text and runs the same on every backend):

```
trait io::IO context owner io requires write_text(text: str) -> unit errors WriteFailed ; write_error_text(text: str) -> unit errors WriteFailed
traitfn io::print_line (text: str) -> unit clones (io::print_line<io::IO=linux::io::LinuxIO>)
e680 block s.. (b.. text:str) captures (...) clone () contextclone (io::IO=linux::io::LinuxIO) contexts () requires (linux::io::LinuxIO) declares unit errors WriteFailed ...
    e681 call block(e648) contexttrait io::IO.write_text witness linux::io::LinuxIO : unit
```

The checked source program (`traitSource`) keeps the context-trait
declarations, `contextParams {name io context io::IO trait 1}`, the
operations (`traitCall {... context 1}`), the requirements and the
selections.

**`-contexts`** (`hir::contexts::summary`, `TraitSummary`) adds, for a program
with context traits:

```
contexttrait io::IO
    write_text(text: str) -> unit errors WriteFailed
    write_error_text(text: str) -> unit errors WriteFailed
contexttraitparam e12 io io::IO
source-function io::print_line e12 direct-contexts (io::IO) required-contexts (io::IO)
source-function hello e720 direct-contexts () required-contexts (io::IO)
contextselect e731 io::IO linux::io::LinuxIO
    write_text -> linux::io::write_text
    write_error_text -> linux::io::write_error_text
contextclone io::print_line<io::IO=linux::io::LinuxIO> io::IO=linux::io::LinuxIO
contextclone hello<io::IO=linux::io::LinuxIO> io::IO=linux::io::LinuxIO
why hello requires io::IO:
    hello
     -> io::print_line
        directly requires io::IO
```

**`-traits`** lists context traits and, for every declared context struct and
context trait, `context linux::io::LinuxIO implements io::IO (write_text ->
linux::io::write_text, ...)` or why it does not; and for ordinary traits,
e.g. `str[linux::path::LinuxPath] satisfies io::path::Path (concat ->
linux::path::concat, text -> linux::path::text)`.

**APIs**: `hir::contexts::satisfiesTrait`, `explainTrait`, `isTrait`;
`hir::traits::isContext`, `IsContextTraitType`, `ContextTraitsOf`,
`ContextSelection`; `hir::types::MentionedContextTrait`.

## 8. The `io` library

lib/io.bot, namespace `io`:

```botlish
error WriteFailed

context trait IO:
    fn write_text(text: str) -> unit errors WriteFailed
    fn write_error_text(text: str) -> unit errors WriteFailed

fn print(text: str, context io: IO) -> unit errors WriteFailed
fn print_line(text: str, context io: IO) -> unit errors WriteFailed      # text + "\n", one write request
fn write_error(text: str, context io: IO) -> unit errors WriteFailed
fn write_error_line(text: str, context io: IO) -> unit errors WriteFailed
```

The operations are outcome-oriented: unit or `WriteFailed`; no descriptor,
buffer, byte count, raw syscall result or errno reaches a portable caller
(`io-portable-surface`). `print_line` builds one String and makes one write
request. Buffering, batching and scratch storage can later live behind these
operations without any caller changing.

**Linux** (lib/linux/io.bot, which imports `io`): `LinuxIO` implements `IO`
with

```botlish
fn write_text(text: str, context io: LinuxIO) -> unit errors WriteFailed:
    io.stdout.write_all(str::encode_utf8(text))

fn write_error_text(text: str, context io: LinuxIO) -> unit errors WriteFailed:
    io.stderr.write_all(str::encode_utf8(text))
```

over the existing `LinuxIO` context, `FileDescriptor` tokens,
`linux::write`, `abi::bytes` and `str::encode_utf8`; the raw `write`,
`write_error` and `read` stay unchanged (`linux::` and `linux::abi::` remain
the syscall-shaped layer for callers that want it).

`write_all(fd, bytes)` (in linux::io, over an opaque `FileDescriptor` no code
outside the module can supply):

* **Short writes are completed**: a positive count below the length writes
  the unwritten suffix (indices `written..n-1`, a collecting loop the range
  analysis proves in bounds), again until done. One write(2) in the common
  case.
* **A negative result** (the kernel's `-errno`) is `WriteFailed`.
* **A write that makes no progress** (0 bytes for a non-empty request) is
  `WriteFailed` (never a busy loop).

Real-syscall evidence (`io-short-write-completed`, `io-write-failed`, strace
fault injection on the standalone executable):

```
write(1, "Hello, world!\n", 14) = 5 (INJECTED)
write(1, ", world!\n", 9)       = 9                  completed; the caller sees success
write(1, "Hello, world!\n", 14) = -1 EBADF (INJECTED)   -> WriteFailed ("failed")
write(1, "Hello, world!\n", 14) = 0 (INJECTED)          -> WriteFailed ("failed")
```

**The Tcl backends** verify every portable program and run it up to the
write(2) boundary, which they refuse (`NATIVE-ONLY`), as for every
linux::io program (`io-tcl-backends`). A substitute context implementing
`io::IO` without Linux runs the portable API on every backend
(`io-substitute-context`).

**`write_file_text` is deliberately not here.** Its implementation would have
to be chosen jointly by the context witness and the `Path` witness (a Linux
context must not accept a `WindowsPath` merely because both are textual
paths), and converting every portable `Path` to `str` for Linux would erase
exactly the provenance eager traits keep. Context-trait requirements
therefore take no ordinary trait parameter yet (`TRAIT-OTHER-TRAIT`); this is
the likely next I/O extension (multi-witness applicability).

## 9. Paths

**`linux::path::LinuxPath`** (lib/linux/path.bot) is an ordinary source
refinement:

```botlish
refined type LinuxPath = str

fn nul_free?(value: str) -> bool                                    # no U+0000
fn valid?(value: str) -> bool proves value: LinuxPath               # non-empty and nul_free?
fn validate(value: str) -> unit proves value: LinuxPath errors NotAPath
fn text(path: LinuxPath) -> str                                     # the carrier itself
fn concat(path: LinuxPath, component: str) -> LinuxPath errors NotAPath
```

* **Proposition**: a non-empty String without U+0000 -- text that may be
  handed to Linux as an ordinary pathname. Not existence, readability,
  writability, file type, symlink resolution, canonical form, the working
  directory, `PATH_MAX`, a filesystem's name limit, mount state or
  permissions: those are environmental facts at a moment, never facts about
  the String. Not every Linux directory entry either (Linux names are bytes:
  arbitrary-byte paths belong to a lower-level abstraction).
* **Validity** (`path-validity`, every backend): `""`, `"a\0b"`, `"\0"`,
  `"/tmp/\0"` are invalid; `"a"`, `"/"`, `"/a/b"`, `"."`, `".."`, `"./foo"`,
  `"../foo"`, `"foo//bar"`, `"a/"`, `"with space"`, `"é/𝄞"` are valid, exactly
  as written: validation never normalizes.
* **No filesystem**: `valid?` is a repeatable value check
  (`hir::repeatable::Block` = 1: no effect, syscall or context); a path that
  exists nowhere is valid (`path-no-filesystem`).
* **`validate` is implemented with the predicate** (`if valid?(value): unit
  else: fail NotAPath`): no intrinsic validator.
* **`text`** is the carrier String itself: lossless, not escaped, not a
  display form. The standard formatting of a portable textual `Path` should
  equal its `text` (the intended rule for when Botlish has formatting; no
  path-specific exception). A `LinuxPath` is already a String wherever one is
  expected.
* **`concat`** is path joining, not String concatenation: one `/` between the
  two unless the path already ends with one; the component must be non-empty,
  NUL-free and not start with `/` (an absolute component would replace the
  path, which joining never does); it may contain `/`, `.` and `..`, which
  are kept; no normalization, no filesystem. The result is a real
  `LinuxPath`, proven by `validate(joined)` -- the ordinary owner proof, no
  unsafe constructor (`path-concat-semantics`, `path-concat-result-refined`):

| path | component | result |
|---|---|---|
| `/a` | `b` | `/a/b` |
| `/` | `b` | `/b` |
| `a/` | `b` | `a/b` |
| `a` | `b/c` | `a/b/c` |
| `a` | `..` | `a/..` |
| `.` | `x` | `./x` |
| `a//b` | `c` | `a//b/c` |
| `/a` | `./b` | `/a/./b` |
| `/a` | `""`, `/b`, `b\0` | `NotAPath` |

**`io::path::Path`** (lib/io/path.bot):

```botlish
error NotAPath

trait Path:
    fn concat(path: Path, component: str) -> Path errors NotAPath
    fn text(path: Path) -> str

fn concat(path: Path, component: str) -> Path errors NotAPath    # path.concat(component)
fn text(path: Path) -> str                                       # path.text()
```

`LinuxPath` satisfies `Path` through `linux::path::concat` and
`linux::path::text` -- its owner's declarations; `str` itself does not
(`path-trait-conformance`). Path-polymorphic code specializes per witness:

```botlish
fn add_config(path: io::path::Path) -> io::path::Path errors NotAPath:
    path.concat(".config").concat("awesome_tool")
```

is `add_config<linux::path::LinuxPath>`, two direct calls of
`linux::path::concat` (`path-generic-specialization`), whose NIR equals a
hand-written concrete function's and allocates the same
(`path-specialization-code-quality`). A generic result is source-visible as
`Path` only (`path-generic-result-one-way`). A test-only second witness
(`winpath::WinPath`, joining with `\`) proves the specialization is per
witness: `child<linux::path::LinuxPath>` gives `/home/child`,
`child<winpath::WinPath>` gives `C:\Users\child`
(`path-windows-shaped-witness`). There is no production Windows path.

**Path + I/O** (examples/io/show-path.bot, `path-io-vertical`): a valid path is
validated in place and printed (still a `str`); an invalid one is reported on
standard error from the `NotAPath` handler.

## 10. Validator proofs

Validators were designed and merged before this milestone
(REFINEMENT-VALUES.md, "Validators"): the same `proves` clause with `-> unit`,
the generic proof contract `{outcome normal param INDEX fact TYPE}` beside the
predicate's `{outcome 1 ...}`, completion facts applied after the call, the
handled-call join, no repeat elimination. This milestone uses them for
`linux::path::validate` and pins, on the path library
(tests/linux-path.test):

| fact | test |
|---|---|
| predicate true -> proof; false -> nothing | `path-predicate-proof` |
| validator success -> proof; error edge -> nothing (inside its handler the argument is not proven) | `path-validator-proof` |
| a handler that returns: proof on the continuation | `path-validator-terminating-handler` |
| a handler that completes normally: no proof after the join (TYPE); re-proving in the handler keeps it | `path-validator-rejoining-handler` |
| an alias made after validation keeps the proof; validating an alias proves the value it aliases; a shadowing binding is a different value; another value is not proven | `path-validator-identity` |
| the validated value is still the same String | `path-string-forgetting` |

Predicate semantics are unchanged (the existing refinement tests and fuzzer,
and the `emailish?` corpus, below).

## 11. Evidence

### Portable Hello World (examples/io/hello.bot)

```botlish
import io
import linux::io

fn hello() errors WriteFailed:
    io::print_line("Hello, world!")

with context linux::io::create()

hello():
    on WriteFailed:
        unit
```

`hello` has no context parameter; it requires `io::IO` through
`io::print_line` (`io-transitive`); the one top-level call selects
`linux::io::LinuxIO`; the executable writes `Hello, world!\n` to descriptor 1
(`io-hello-executable`, also under GC stress).

**NIR** (`io-nir-direct`):

```
nir 1 call-effects=1 statics=0 contexts=24
context 0 "linux::io::LinuxIO" offset=0 words=3 fields="stdin.raw.value stdout.raw.value stderr.raw.value"

func 11 "linux::io::write_text" params=1 ...
    %1 = contextload 8                      stdout's descriptor, from the fixed slot
    ...
    %4 = call 10 %2 %3                      linux::io::write_all(fd, bytes)
func 12 "io::print_line<io::IO=linux::io::LinuxIO>" params=1 ...
    %3 = call 11 %2                         linux::io::write_text(line): one operand
func 13 "hello<io::IO=linux::io::LinuxIO>" params=0 ...
    %1 = call 12 %0                         print_line's clone: one operand
```

**CLIF** (`main.tcl -emit-clif`; the JIT's, where the area is an absolute
symbol):

```
; function 12 "io::print_line<io::IO=linux::io::LinuxIO>": botlish_fn_12
function u0:106(i64, i64) -> i64 system_v {            (vm, text): no context parameter
    fn1 = colocated u0:104 sig1                          linux::io::write_text
    ...
    v7 = call fn0(v0, v6, v5)                            str::concat(text, "\n")
    v8 = call fn1(v0, v7)                                write_text(vm, line): direct
; function 11 "linux::io::write_text": botlish_fn_11
function u0:104(i64, i64) -> i64 system_v {            (vm, text)
    gv0 = symbol userextname0                            the context area
    v5 = symbol_value.i64 gv0
    v6 = load.i64 notrap aligned v5+8                    stdout's descriptor word
```

**strace** (`io-strace`; `-k` stack, frames mapped to NIR functions):

```
write(1, "Hello, world!\n", 14) = 14
 > botlish_linux_x86_64_syscall
 > rt_linux_x86_64_syscall
 > linux::write
 > linux::io::write_all
 > linux::io::write_text
 > io::print_line<io::IO=linux::io::LinuxIO>
 > hello<io::IO=linux::io::LinuxIO>
 > <program>
```

No libc frame in the program's write; `print`, `print_line`, `write_error`,
`write_error_line` are one write(2) each, on descriptors 1, 1, 2, 2, UTF-8
(`é` two bytes, `𝄞` four) (`io-routing-utf8`, `io-strace`).

### The context-trait clone against hand-written code

The evidence program (tests/context-traits.test `evidence`): `twice(n,
context out: Out)` against the hand-written `twice_a(n, context c: A)`:

```
func 2 "twice_a" params=1 env=0 ...           func 4 "twice<Out=A>" params=1 env=0 ...
    %1 = call 1 %0                                %1 = call 1 %0          emit, direct
    %2 = call 1 %0                                %2 = call 1 %0
    %3 = op riadd %1 %2                           %3 = op riadd %1 %2
    %4 = op rbox %3                               %4 = op rbox %3
    ret %4                                        ret %4
func 1 "emit" ...: %1 = contextload 0; ...    (the implementation's own slot load)
```

Identical bodies, `params=1`, no `callvalue` (`ct-nir-direct`). Machine code
(`ct-machine-code-direct`, objdump of the standalone executable): the clone
is two `call <botlish_fn_1>` (direct, `emit`), no indirect call, 89 bytes --
exactly the hand-written function's size.

### Allocations (`native::allocationReport`)

| what | objects |
|---|---|
| 100 context-trait operations (`sum(50, 0)` over `twice<Out=A>`) | **0** |
| the same through the hand-written concrete function | **0** |
| `io::print_line("Hello, world!")`, whole program | 11 (541 bytes): String 1, List 1, Bytes 1, Struct 8 |
| `linux::io::write_text(str::concat("Hello, world!", "\n"))`, whole program | 11 (541 bytes): the same |
| 1 / 2 / 4 `io::print_line` calls | 11 / 15 / 23: 7 once + 4 per call |
| `child<LinuxPath>` vs hand-written `child_l(LinuxPath)` | equal |

Context-trait adaptation and path refinement adaptation allocate nothing. The
output operation's own allocations, per call, are the line String
(`concat`), the UTF-8 byte List (`str::encode_utf8`), the `Bytes`
(`abi::bytes::from_list`) and one `abi::I32`: `write_text` materializes the
descriptor token it passes to `write_all` (NIR `structnew 2 %1` after the
`contextload 8`). The 7 others are `linux::io::create`'s, once (CONTEXTS.md
§7).

## 12. Tests, fuzzing, mutation testing

* **tests/context-traits.test** (39 tests): syntax and contextual words,
  modifiers, declaration diagnostics, requirements without receiver;
  satisfaction (structural, every mismatch reason and its explanation,
  owner-only, import independence, two importers); the one-way binding,
  positions, orthogonality with ordinary traits, duplicate parameters;
  selection (the A/B/both/neither matrix, the ambiguity and missing
  diagnostics, source position, recorded selections, implementation
  obligations, implementation order); transitive requirements and chains;
  unreachable consumers; flags; the function-value frontier; recursion, nested
  functions over the binding, method syntax, mixed ordinary/context traits;
  exact contexts unchanged; the context-trait-free compiled program; HIR text
  round trip; NIR, the context area, allocations, machine code; tooling;
  programs without traits built once; the source audit (no context-trait
  code, library name or registry access in core/, compiler/, native/).
* **tests/portable-io.test** (12 tests): the surface, LinuxIO's
  implementation, transitive requirement, NIR, the Tcl backends, a substitute
  context on every backend, the executable (also under GC stress), routing and
  UTF-8, strace, short-write completion, write failures, allocations.
* **tests/linux-path.test** (19 tests): the refinement's declaration (and no
  compiler knowledge of it), validity, no filesystem, the validator facts of
  §10, concat and text, conformance, generic specialization, the Windows-shaped
  witness, code quality and allocations, the path + I/O executable.
* Updated pins: tests/contexts.test (linux::io's surface now includes the
  `io::IO` implementation; the root-native list includes `context#unreachable`;
  one ExprId), tests/stdlib-namespaces.test (the root-native inventory).

**Fuzzer** (`audit/context-traits/tools/fuzz.tcl`): see its header and
§16 item 54 for results.

**Mutation testing** (`audit/context-traits/tools/mutate.tcl`, 23 mutants in
`mutants.txt`): see §16 item 55.

## 13. Regression and audits

See §16 items 56-60.

## 14. Limitations and what remains

* **One selection per context trait per program.** Installation is top-level
  and monotone, so all successful selections agree; nested or dynamic
  installation (CONTEXTS.md §9) would need per-scope selections, and the clone
  key already carries the selection.
* **Context-dependent functions are moved to the entry program** (cloned and
  bound before their first top-level use). Their code is unchanged; their
  names in NIR, symbols and diagnostics of the compiled program carry the
  selection (`hello<io::IO=linux::io::LinuxIO>`).
* **Programs that load a trait or context trait are built twice** (TRAITS.md):
  every program importing `io` -- and, since lib/linux/io.bot imports `io`,
  every program importing `linux::io` -- now pays build 2. See item 60.
* **Requirements take no ordinary trait parameters and return no trait**
  (multi-witness dispatch: `write_file_text(path: Path, text: str)`).
* **Implementations**: exactly one context parameter (their own context), no
  flags; module- or entry-level functions of the context's owner.
* **No ranking** of providers, no named instances, no default
  implementations, no context-trait composition or supertraits.
* **Dead code** is compiled to the `context#unreachable` placeholder (a trap)
  rather than removed.
* **No format strings**: `$"..."` does not exist in Botlish; examples use
  `str::concat`. A refined String is a String wherever one is accepted.
* **The Tcl backends cannot run Linux output** (NATIVE-ONLY), as before.
* **Pre-existing METHOD-ELIGIBLE warnings** of lib/linux/io.bot's original
  `write`, `write_error` and `read` (frozen corpus) still print for programs
  loading `linux::io`; the new library code is warning-free.

## 15. Context maturity

The criterion, item by item:

| criterion | status |
|---|---|
| portable library code can declare an abstract environment requirement | `context io: IO` in lib/io.bot |
| concrete installed contexts satisfy it structurally | `satisfiesTrait`, owner-only, no declaration of conformance |
| exactly one provider is selected statically | `Obligations`, `ct-select-matrix` |
| ambiguity is diagnosed | `AMBIGUOUS-CONTEXT-IMPLEMENTATION` |
| requirements propagate transitively | the unchanged fixed point; `ct-transitive` |
| intermediate calls have no plumbing | NIR/CLIF/machine code: ordinary operands only |
| source code cannot recover the concrete provider | `CONTEXT-TRAIT-MISUSE`, `ct-one-way` |
| lowering remains direct, zero-dispatch | direct calls; identical code to hand-written; 0 allocations |
| exact nominal contexts still work unchanged | tests/contexts.test unchanged but for three pins |

All hold. **`context` is mature enough to freeze for now**: further context
features should be driven by the test framework or real library needs, not
added because they are imaginable.

## 16. Milestone report

1. **Grammar.** `traitDecl = [ "context" ] "trait" IDENT ":" NEWLINE INDENT
   traitRequirement { traitRequirement } DEDENT`; `traitRequirement = "fn"
   IDENT "(" [ paramList ] ")" [ "->" typeExpr ] [ "errors" IDENT { "," IDENT
   } ] NEWLINE`; a context section entry's type may be a context trait.
2. **Contextual/modifier behavior.** `context` is the struct modifier applied
   to `trait`; recognized only as `context trait NAME` at the start of a
   top-level statement; `context`, `trait` stay ordinary names elsewhere;
   `opaque` and a repeated `context` are rejected on traits (§1).
3. **AST/HIR representation.** One `traitdecl` node with `context 0|1`,
   `contextSpan`; the trait registry and HIR's `traits` entries carry `context
   1`; requirements `{name params {{name type self 0}} result errors}`;
   context parameters `{name io context io::IO trait 1}`; the binding is
   `bind io (call ^context#load "io::IO")` typed `{trait io::IO}`; operations
   are calls marked `traitCall {trait requirement receiver args shape context
   1}` (build 1). HIR text: `trait ID context owner NS requires ...` (§7).
4. **Identity/imports.** A namespace member's (`io::IO`), the type namespace
   shared with structs, types and traits; `import type io::IO`; imports never
   affect satisfaction.
5. **Requirement restrictions.** No receiver; ordinary (or untyped)
   parameters, ordinary concrete results, declared errors; no ordinary trait
   or context trait parameter or result (`TRAIT-OTHER-TRAIT`), no context
   parameter, flags, body, proof clause; at least one requirement; no
   duplicate names (§1).
6. **Structural concrete-context satisfaction.** Every requirement has a
   compatible implementation in the context struct's owner (§2); no
   `implements`, `provides`, instance or registration.
7. **Owner lookup rule.** The owner namespace's own top-level function of the
   requirement's name; never an import, the caller, or another namespace
   (`ct-owner-only`).
8. **Signature compatibility.** Exactly one context parameter, of the
   concrete context (not part of the arity); the ordinary signature through
   the existing structural function compatibility (`FnMismatch`); a declared
   result when the requirement has one; no flags.
9. **Error compatibility.** The implementation's errors ⊆ the requirement's
   (fewer is fine), the ordinary error-set rule.
10. **Satisfaction API.** `hir::contexts::satisfiesTrait CONTEXT TRAIT` ->
    `{ok trait witness owner impls {REQ IMPL ...} reason requirement found}`;
    `hir::contexts::explainTrait CONTEXT TRAIT ?HIR?` (§2).
11. **Source-visible binding.** Only the context trait: its operations, as
    `io.op(args)`; every other use `CONTEXT-TRAIT-MISUSE` (§3).
12. **Hidden concrete witness.** Never a type: selected after checking, read
    only by the plan; in the compiled program it is the clone's
    `contextClone {TRAIT WITNESS}` and each operation's `traitImpl ...
    witness`.
13. **Exactly-one selection.** Per reachable top-level call, per required
    context trait, among the contexts installed at that position (§4).
14. **Zero providers.** `MISSING-CONTEXT`, with the chain and every installed
    context and why it does not implement the trait.
15. **Multiple providers.** `AMBIGUOUS-CONTEXT-IMPLEMENTATION` listing them in
    installation order, with the chain; no ranking or preference.
16. **Source-position installation.** Selection reads the set installed
    before the call; later installations do not affect it.
17. **Transitive propagation.** The unchanged context fixed point, carrying
    context-trait identities; trait operations are never call edges (§5).
18. **Unreachable calls.** Require nothing; their code becomes the
    `context#unreachable` placeholder in the compiled program (§6).
19. **Call-chain diagnostics.** Shortest deterministic chains, extended
    through a selected implementation for its own requirements (§4, §5).
20. **One-way abstraction.** `ct-one-way`: no projection, passing, type test,
    comparison, storage or undeclared operation, whatever is installed.
21. **Monomorphization rule.** Every top-level function whose requirement
    includes a context trait is replaced by one clone per selection (key
    `{function, ordinary witnesses, {TRAIT WITNESS ...}}`), bound in the entry
    program before its first use; the body is checked once against the trait
    (§6).
22. **Direct operation lowering.** `io.write_text(t)` -> `call
    block(linux::io::write_text) t` in the clone (no receiver).
23. **Exact-context interaction.** Exact contexts unchanged; the selected
    implementation's own `context io: LinuxIO` is an ordinary exact context
    load; both kinds may appear in one function.
24. **Native context area.** Unchanged; no slot, tag or table for a context
    trait (`ct-native-context-area`).
25. **Function-value frontier.** Unchanged (`CONTEXT-FUNCTION-VALUE`); no new
    escaping case; no dictionary-bearing closure.
26. **Interpreter.** Runs the core IR of the monomorphized program; no change.
27. **Tcl compiler.** Compiles the same; no change.
28. **Native.** Lowers the monomorphized HIR; one change: the dead-code
    placeholder `context#unreachable` lowers to `unreachable`.
29. **HIR evidence.** `contextclone (io::IO=linux::io::LinuxIO)`, `call
    block(e648) contexttrait io::IO.write_text witness linux::io::LinuxIO`;
    `ct-mono-hir` (no context-trait operation, binding, load or type remains),
    `ct-hir-text` (round trip).
30. **NIR evidence.** `io::print_line<...>`: `%3 = call 11 %2` (one operand),
    `linux::io::write_text`: `%1 = contextload 8`; the evidence clone's body
    equals the hand-written function's (§11).
31. **CLIF/assembly evidence.** `fn1 = colocated u0:104`, `call fn1(v0, v7)`;
    machine code: two direct `call <botlish_fn_1>`, no indirect call, 89
    bytes = the hand-written function (§11).
32. **ABI evidence.** `params=` and CLIF signatures are the ordinary
    parameters (`(vm, text)`); no context operand on any call.
33. **Allocation evidence.** Context-trait adaptation 0, path adaptation 0;
    output: 4 objects per `print_line` (String, List, Bytes, `abi::I32`), 7
    once for `create` (§11).
34. **Validator proof grammar.** The existing `-> unit proves PARAM: R errors
    ...` (REFINEMENT-VALUES.md): the same `proves` clause, outcome `normal`.
35. **Validator success semantics.** Normal completion proves the argument
    (and its alias root) for the rest of the path (`path-validator-proof`).
36. **Handled-error join.** A handler that leaves contributes no normal path
    (proof kept); one that completes rejoins without the proof (TYPE), unless
    it re-proves (`path-validator-terminating-handler`,
    `-rejoining-handler`).
37. **Predicate regression.** Unchanged: `path-predicate-proof`, the
    refinement tests and fuzzer, the `emailish?` corpus (items 56-58).
38. **LinuxPath definition.** `refined type LinuxPath = str` in
    lib/linux/path.bot; owner `linux::path`; no compiler knowledge
    (`path-declaration`).
39. **Validity rules.** Non-empty, no U+0000; nothing else; no normalization
    (§9).
40. **`valid?`.** `value.length() > 0 and value.nul_free?()`, `nul_free?` a
    counted scan of `char_at(i).scalar_value()`; repeatable.
41. **`validate`.** `if valid?(value): unit else: fail NotAPath`.
42. **`io::path::Path`.** `trait Path: fn concat(path: Path, component: str)
    -> Path errors NotAPath; fn text(path: Path) -> str`, plus the helpers
    `io::path::concat`/`text` (§9).
43. **Conformance mapping.** `concat -> linux::path::concat`, `text ->
    linux::path::text` (owner's declarations; `str` does not satisfy Path).
44. **`concat` semantics.** Join with one `/` unless the path ends with one;
    the component non-empty, NUL-free, not absolute; `.`, `..`, `//` kept; the
    result validated (§9 table).
45. **`text` semantics.** The carrier String itself: lossless, not escaped,
    not display-only.
46. **Generic Path specialization.** `child<linux::path::LinuxPath>`,
    `add_config<...>`: direct calls of `linux::path::concat`; the same
    witness returned; no wrapper; per-witness with a second (test) witness.
47. **Portable IO context trait.** `context trait io::IO: write_text,
    write_error_text (str) -> unit errors WriteFailed`.
48. **Portable `io::` functions.** `print`, `print_line`, `write_error`,
    `write_error_line` (§8).
49. **Linux implementations.** `linux::io::write_text`, `write_error_text`
    over `write_all`, `linux::write`, `abi::bytes`, `str::encode_utf8`.
50. **Short-write policy.** Completed by writing the remaining suffix until
    done; zero progress is `WriteFailed` (strace-injected evidence, §8).
51. **Error translation.** Negative result or no progress -> `WriteFailed`;
    no errno, count or descriptor reaches the portable caller.
52. **Portable Hello World.** examples/io/hello.bot: no context parameter,
    `io::IO` inferred transitively, LinuxIO selected, direct call of
    `linux::io::write_text`, one raw write(2), no libc in the path (§11).
53. **Path + IO vertical.** examples/io/show-path.bot (`path-io-vertical`),
    examples/io/child-path.bot (`path-child-example`).
54. **Fuzz results.** `audit/context-traits/tools/fuzz.tcl`, four seeds ×
    75 programs (`-seed 1, 1001, 2001, 3001`), every backend: **300 programs,
    134 accepted (249 selections checked), 166 rejected as predicted
    (MISSING-CONTEXT 156, AMBIGUOUS-CONTEXT-IMPLEMENTATION 10), 0
    disagreements** -- satisfaction of every context × trait, every
    consumer's requirement, each call's selection, every operation's
    implementation and every value agreed with the oracle. Validator proofs:
    the existing refinement fuzzer generates validators, handled calls whose
    handlers return, fail, complete or re-prove, and validator calls in every
    position (REFINEMENT-VALUES.md); its run is item 58.
55. **Mutation results.** MUTATION-RESULTS
56. **Full regression.** REGRESSION-RESULTS
57. **Eager-trait fuzzer regression.** TRAIT-FUZZ-RESULTS
58. **Refinement fuzzer regression.** REFINEMENT-FUZZ-RESULTS
59. **Scalar machine-code audit.** SCALAR-AUDIT-RESULTS
60. **Compile-time impact.** Context-trait resolution itself is small: on the
    portable Hello World, the plan takes ~5 ms and the whole context
    verification ~22 ms of ~450 ms. The cost is the build structure: before
    this milestone every program was already built twice (the method-call
    decision's final rebuild, TEST-SUITE-COST.md); a program declaring or
    loading a trait or context trait is built a third time, monomorphized.
    Since lib/linux/io.bot now imports `io`, existing `linux::io` programs
    pay it too, and each build is larger (the `io` module and the new
    implementation): examples/linux/context-hello.bot ~240 ms -> ~505-630
    ms (warm, averaged). Programs without traits are unchanged
    (examples/stdlib/matmul.bot ~205 ms before and after), as are
    ordinary-trait programs (the traits principal program ~50 ms both).
    Runtime: zero dispatch overhead (items 30-33).
61. **Remaining limitations.** §14.
62. **Context maturity criterion.** Met (§15): `context` is frozen for now.
63. **Before coroutines.** COROUTINE-PREREQUISITES.md's list is unchanged by
    this milestone; for contexts specifically: a coroutine body that requires
    a context trait would need its selection fixed when it is created (the
    clone already is), and suspended frames that hold no context value
    (true today: contexts are loaded from their slots, never captured as
    hidden arguments) -- context traits add no frame state. Actor- or
    coroutine-local installation needs the per-scope selection of §14.
64. **Before MutableVector.** Nothing context-specific: a growable mutable
    container needs its own ownership/mutation design (MUTABLEARRAY and
    MUTABLE-BYTES precedents); for I/O it would carry buffered output, which
    can then live behind `io::IO`'s operations in a mutable context without
    any caller change.
65. **Before the Botlish-native test framework.** Substitutable environments
    now exist: a test installs a fake context implementing `io::IO` (or any
    context trait) instead of LinuxIO, selected statically like the real one
    (`io-substitute-context`). Still missing for the framework: mutable
    contexts (a capturing fake that records output), scoped/nested
    installation (one installation per test rather than per program), and
    test discovery/assertion syntax.
