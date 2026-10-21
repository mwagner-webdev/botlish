# Direct modules and contextual capability boundaries

```
# lib/linux.bot -- the raw, explicit low-level layer
direct module

import abi
import abi::bytes
import linux::sys

fn write(fd: abi::I32, data: abi::bytes::Bytes) -> int:
    linux::sys::write(fd, data)        # the architecture's raw syscall
```

```
# lib/linux/io.bot -- an ordinary module: it contextualizes that authority
import linux
...
opaque context struct LinuxIO:
    stdin: FileDescriptor
    stdout: FileDescriptor
    stderr: FileDescriptor

fn write(data: abi::bytes::Bytes, context io: LinuxIO) -> int:
    io.stdout.raw.write(data)          # linux::write, mediated by LinuxIO
```

> Raw authority may be straightforward inside low-level modules. Ordinary
> modules remain capability-safe by mediating that authority through contexts
> they define themselves. `direct` is acknowledged at the module boundary,
> never sprinkled over individual calls or functions.

The whole source surface is one line, `direct module`, at the top of a file.
Everything else is compiler inference.

## Contents

1. What "direct" means
2. The language: `direct module`
3. The rules
4. Why these rules
5. The standard library: the syscall boundary
6. Implementation
7. Tooling
8. What this is not
9. The future C binding architecture (future)
10. Tests, fuzzing, mutation testing, regression
11. Milestone report

---

## 1. What "direct" means

*Direct* means raw, ambient authority that has not yet been converted into
an explicit capability represented by a context. A raw system interface
eventually cashes every abstraction out into a syscall, a raw handle, a
machine address, a foreign call, a retained callback: a module that exposes
such an operation to its callers without a context in between is *direct*.

The trust unit is the **module** -- the file-derived module of IMPORTS.md, the
entry program included. There is no direct function, no direct call, no
direct block: a reviewer who wants to know whether some code can reach raw
authority looks at the module headers, never at every function.

A module stops direct authority by **contextualizing** it: every use of a
direct module's callables happens in a function that requires a context the
module defines itself. Then the module is ordinary, and so is everything above
it:

```
linux::abi::x86_64,   DIRECT (intrinsic)        the raw syscall transitions
linux::abi::aarch64
   |
linux::sys            DIRECT (`direct module`)  one architecture's numbers and registers
   |
linux                 DIRECT (`direct module`)  write(fd, data), read(fd, data)
   |
linux::io             ordinary                  defines LinuxIO; every call into linux requires it
   |
io, 2048, ...         ordinary                  see only the LinuxIO capability
```

The taint stops at the module that contextualizes the authority.

"Direct" is not "unsafe". A direct module can be perfectly memory-correct
(lib/linux.bot is ordinary, checked Botlish); a non-direct module can still
contain bugs. A context does not make a syscall or a future C call
physically safer -- the machine operation still occurs underneath -- it makes
the *authority* to perform it explicit and mediated. The distinction is
architectural authority, not machine risk.

## 2. The language: `direct module`

```
# comments and blank lines may come first (a #! line is a comment)
direct module

import linux::abi::x86_64
...
```

* A **module modifier** of the file-derived module: no name (`direct module
  foo` is `DIRECT-MODULE-FORM`: a module's identity is its file path), no
  `module` declaration of any other kind.
* The **first** non-comment construct of the file, before its imports, once.
  Anywhere else it is a located syntax error: after an import or any other
  declaration (`DIRECT-MODULE-POSITION`), inside a function, loop, branch,
  handler or static block (`DIRECT-MODULE-POSITION`, with a message saying
  there is no function-, block- or call-level form), a second one
  (`DUPLICATE-DIRECT-MODULE`). A recovering parse reports each and keeps the
  valid one.
* `direct` and `module` are **contextual**: the two words in this order at a
  file's start; ordinary names everywhere else (`direct = 1`, `fn
  f(module)`).
* There is **no** `direct fn`, `direct call(...)`, `direct:` block, `unsafe`,
  `allow direct`, `@direct`, pragma or other suppression: the two remedies are
  architectural (mediate through a module-owned context, or declare the whole
  module direct), nothing else.

The AST's `program` node records the marker's span (`direct`, "" without
one); the loader hands every unit's declaration to HIR as `-module-decls`
(`moduleDecls` in HIR: namespace -> `{direct 0|1 origin ORIGIN}`, the entry
program as `""`).

## 3. The rules

### Designation

A module is **designated direct** when

* its file starts with `direct module`, or
* it is an intrinsic namespace the compiler declares direct:
  `core::native::declareDirectNamespace NS`, registration metadata beside the
  namespace's natives. Today exactly the raw syscall transports,
  `linux::abi::x86_64` and `linux::abi::aarch64` (core/linuxabi.tcl declares
  each entry of its transport table), and `binary::native`, whose
  `binary::native::view` reads live native memory (core/binary.tcl,
  NATIVE-LAYOUT-VIEWS.md section 8) and whose `binary::native::edit` makes
  write authority over it (NATIVE-LAYOUT-WRITES.md section 5); storing
  through an edit someone made (`binary::store`) is not direct.

Nothing else designates one: no module name (`raw`, `syscall`, `ffi`,
`linux...`), path, library or naming convention is ever read
(`dm-no-name-heuristic`). Source, intrinsic and (future) generated modules
share the one property.

### Direct edges

A **call** in module U whose target belongs to a designated-direct module D
other than U is a **direct edge** of U. The target is the call's exact
target -- a function (through aliases `g = f`), a module function, a root
native (whose module is its registered namespace) -- the edges contexts
already use (CONTEXTS.md, "Function values"). Deliberately coarse: **every**
callable of a direct module is direct, a pure helper of it included
(`dm-coarse-module`). A future binding generator that wants finer
granularity splits modules.

* A call inside the same module is no edge: inside a `direct module`, raw
  code calls raw code with no ceremony (`dm-direct-module-internal`).
* **Importing** a direct module is not direct: its types, structs and
  layouts are usable in signatures, constructions and projections
  (`dm-import-is-not-authority`), so a wrapper can describe the boundary it
  wraps.
* Calls in unreachable or uncalled code count: they still name the authority
  (`dm-unreachable-code-counts`).
* A **trait operation** calls whatever its witness provides, so it is an
  edge into D when D may provide it: when D declares a top-level function of
  the requirement's name (conformance looks only in a witness's owner
  namespace, TRAITS.md and CONTEXT-TRAITS.md, so only then can D's
  implementation run). The rule reads declarations only -- never which
  witness reaches the call, the program's context selection or
  reachability -- so it over-approximates (`dm-value-trait-operation`,
  `dm-foreign-context-trait`; a module's own context trait mediates its
  operations like any of its contexts, `dm-context-trait-mediates`).
* Method syntax is an ordinary call: `abi::i32(1).write(data)` is an edge into
  `linux`; DIRECT is an *obligation* of the selected call
  (`hir::MethodObligationKinds`), never a reason another candidate fits
  better (`dm-method-sugar-two-candidates`).

### Discharge

A direct edge is **mediated** when the function containing the call requires
a context declared by U itself: a context struct (CONTEXTS.md) or a context
trait (CONTEXT-TRAITS.md) of U, in its context section. The owner is the
declaring module (`hir::structs::owner`, `hir::traits::owner`), never a
spelling. Nothing else mediates:

* **not a context of another module** (`dm-foreign-context`): with `fn
  raw_read(context c: other::Ctx)` the call stays undischarged, and the
  diagnostic says why;
* **not a caller's context**: a context-free helper's direct call is
  undischarged however it is called (`dm-helper-not-laundered`) -- carry the
  context onto the helper, the function that makes the direct call;
* **not top-level code**, which has no context;
* a **nested function** is its own function (`dm-nested-function-is-its-own`);
  only a coroutine construction's thunk, whose body runs at the construction,
  belongs to the function around it (`dm-coroutine-thunk`).

Helpers that make no direct call need no context, above or below a
contextual function: the context reaches the point where the authority is
exercised, not every function around it.

No proof of adequacy is attempted: not that the context holds a handle, that
its fields correspond to the call, or that the function reads it. A
module-owned context requirement is the explicit architectural act of
mediation; the module author defines the policy, as an FFI contract's author
does.

### Context construction

A context whose construction itself needs direct authority -- a descriptor a
future `openat` mints, a handle a foreign library returns -- gets no
exemption: its constructor is a function like any other, and a direct call
in it is mediated only when the constructor requires a context of its
module. So the owning module chains its contexts: a first context minted
with no direct call, and a constructor that requires it.

```
# fs.bot -- ordinary: contextualized
import raw

opaque context struct Root:
    ok: bool

opaque context struct Probe:
    value: int

fn root() -> Root:                    # no direct call: needs no context
    Root {ok: true}

fn open(context r: Root) -> Probe:    # the direct call, mediated by fs's Root
    Probe {value: raw::add(40, 2)}

fn value(context p: Probe) -> int:
    p.value
```

```
import fs

with context fs::root()
with context fs::open()               # under the earlier installation (CONTEXTS.md, "Order")
fs::value()
```

`raw` is direct, `fs` contextualized, the program ordinary; with `fn open()
-> Probe`, a context-free constructor, `fs` is DIRECT
(`dm-context-construction-chain`). The standard library needs none of this:
`linux::io::create()` makes LinuxIO's three descriptor tokens with no
syscall (§5).

**Why no constructor exemption.** Exempting the direct calls of a function
that returns a context of its own module would be unsound, three ways:

* **A constructor is an ordinary function.** `with context` installs a
  context from any expression, but nothing restricts where a function
  returning one is called: from any function of any module that imports it,
  whose call runs its body. An exempt `fs::open()` making the call is a
  context-free wrapper of raw authority with a context for a result; every
  importer reaches the authority through it with no context of its own,
  which is exactly what the rule rules out.
* **The exemption would be keyed on a signature, which says nothing about
  the body.** Any function could be exempted by returning a context of its
  module: `fn write(fd, data) -> Receipt`, Receipt a context struct nobody
  ever installs. That launders directness by a signature, the way a foreign
  context would (§4, "Why the context must be the module's own").
* **Opacity controls who builds a context, not what building it does.** An
  opaque context can be constructed only inside its module, but the
  module's exported constructor is the point: its effects happen at every
  call, installed or not.

A sound version exists, and was not built: exempt a constructor's direct
calls only when every call of it is the expression of a `with context`
installation, so that the authority is exercised once per installation, in
the installing code. It is a call-site rule: today a DIRECT diagnostic reads
only the function making the call, its context section and declarations
(§3, "Static intrinsics"); this one would read the syntax of every caller,
in every module, so a function's directness would depend on how other
modules call it -- the cross-module inference "callers read designation, not
inference" avoids -- and it would add a category of function. The chain
gives the same architecture under the unchanged rule: the authority-free
first context is the explicit grant, installed by the application, and the
constructor is mediated by it.

What the chain does not add is unforgeability: `fs::root()` is a
context-free function any importer may call and install, as
`linux::io::create()` is. That is every context's property: a context makes
the capability explicit and visible where it is installed and required, not
unobtainable (§4: no adequacy of a context's policy is claimed).

### The module result

U is **inferred direct** when one of its edges is undischarged. The
declaration must agree:

| inferred | declared | result |
|---|---|---|
| no | no | an ordinary module (*contextualized*, if it has mediated edges) |
| yes | no | **DIRECT**, at each function's first undischarged edge |
| yes | yes | a deliberate direct module |
| no | yes | **STALE-DIRECT-MODULE**, at the marker |

So an ordinary module never silently becomes direct when a call is added
(the source diff must add `direct module`: `dm-no-silent-promotion`), and a
marker never outlives the authority it acknowledged (`dm-stale-*`): it is an
exact declaration, not a permission bit under which future authority can
accumulate. An intrinsically direct namespace is direct by its metadata and
needs no inference.

The entry program follows exactly the same rules (`dm-root-not-special`): a
program that uses only ordinary modules needs nothing; one that calls a
direct module either declares `direct module` (a deliberately low-level
program, examples/linux/getpid.bot) or defines its own context:

```
import abi
import abi::bytes
import linux
import str

context struct LocalIO:
    out: abi::I32

fn emit(text: str, context io: LocalIO) -> int:
    linux::write(io.out, abi::bytes::from_list(str::encode_utf8(text)))

with context LocalIO {out: abi::i32(1)}
emit("hello\n")
```

No application context is required of any program: an application-owned
context is a good composition boundary, a design practice, not a compiler
mandate.

### Callers read designation, not inference

A caller's edge into D reads D's **designation** only. So directness stops at
a successful contextualization boundary (`dm-transitive-boundary`: Raw
direct, Wrapper contextualized, Consumer and Root ordinary); a module whose
own inference disagrees with its marker reports its own diagnostic and
nothing downstream; and every fact a DIRECT diagnostic reads is local to its
function or a file header.

### First-class callables

A function of a designated-direct module may be called, or bound to another
name as a statement (an alias, whose calls are edges again: also from a
closure capturing it). In a module that is not declared direct, any other
use -- returning it, storing it in a struct or a list, passing it as an
argument, returning an alias of it -- is **DIRECT-CALLABLE-VALUE**: a call
through an unknown function value could not be seen as an edge. No
capability-carrying function type was invented. A direct module may hand
its own callables out (it declared that it exposes raw authority); obtaining
one is itself a call into the direct module, which the receiving module
mediates or declares (`dm-direct-module-hands-out`). A coroutine handle is
the same case: constructing one of a direct module's function is a direct
edge (the construction's thunk belongs to the function around it), and the
handle is from then on the constructing module's value, as a callable a
direct module hands out is. Calls through values (a parameter, a field, a
resumption) are not edges: every value that could carry a direct callable
into a non-direct module got there through an edge or from a direct module.

### Diagnostics

```
DIRECT: main.bot:7:5: the entry program uses direct authority: function "emit" calls
linux::write, a callable of the direct module "linux", without a context defined by the
entry program; require one of this module's own contexts ("context NAME: T", T a context
struct or context trait declared by the entry program) in "emit", the function that makes
the direct call, or declare the module direct with `direct module` as its first line

DIRECT: b.bot:6:25: module "b" uses direct authority: function "b::raw_pid" calls
linux::abi::x86_64::syscall, a callable of the direct module "linux::abi::x86_64",
without a context defined by "b" ("b::raw_pid" requires a::ContextA, a context defined by module "a", but a
context mediates direct authority only in the module that defines it: a context declared
by "b" itself); require one of this module's own contexts ... or declare the module direct
with `direct module` as its first line

STALE-DIRECT-MODULE: m.bot:1:1: `direct module` is unnecessary: all direct authority in
module "m" is mediated by contexts defined by "m" (every call into a direct module is in a
function requiring one of them); remove the declaration (it must state exactly what the
compiler infers)

DIRECT-CALLABLE-VALUE: main.bot:4:5: raw::add is a callable of the direct module "raw":
the entry program, which is not declared direct, may only call it (or bind it to another
name as a statement), never pass, return, store or capture it as a value -- a call through
an unknown function value would carry direct authority past this module's context
boundary unseen (DIRECT-MODULES.md)
```

One DIRECT per function -- at its first undischarged edge in source order,
its other undischarged edges as `related` locations -- never one per
downstream call; top-level code gets its own wording. Unrelated diagnostics
are still reported (`dm-diagnostics-recover`).

### Static intrinsics

DIRECT and DIRECT-CALLABLE-VALUE are recoverable: a `static compile:` block
whose body makes an unmediated direct call is rejected with
`compiler::DiagnosticCode::Direct` (`DirectCallableValue`), through the normal
diagnostic-value mechanism (`dm-static-compile-*`). STALE-DIRECT-MODULE is
located at the file header, never in a block (`tests/static-compile.test`'s
census, class `header`). Directness is the final program's: a direct module
whose only direct call is in a block rejected for another reason is stale
(`dm-static-compile-final-program`). A DIRECT diagnostic reads only its
function's own code (its calls, their exact targets, its context section)
and declarations -- other files' headers, intrinsic metadata, top-level
function names -- that no rejection changes, so no static site's directness
diagnostic depends on another site's form beyond the edges
hir/staticdeps.tcl already has (a site's region and the sites in it): the
dependency analysis needed no channel for it.

## 4. Why these rules

* **Why a module property.** A local escape hatch inside an otherwise safe
  function (Rust's `unsafe {}`, C#'s `unsafe`) changes that function's trust
  assumptions where a reviewer must find it. A module header is where the
  architecture is reviewed. Low-level code stays straightforward inside a
  direct module: no ceremony per call.
* **Why no call or function syntax.** The compiler knows the called module,
  so it knows the call is direct; repeating that at every call recreates the
  unsafe-block review problem. Functions have internal edge facts for
  diagnostics and tooling; they are not source annotations and not part of
  any callable type.
* **Why inference and acknowledgement differ.** Inference is the truth (an
  unmediated edge exists); the marker is the author's statement that the
  truth is intended. Requiring them to agree, in both directions, makes the
  marker a precise review artifact: adding raw authority to an ordinary
  module is a compile error, removing the last of it is too.
* **Why the context must be the module's own.** The module that performs the
  mediation takes architectural responsibility for the capability under
  which its raw authority is valid. Otherwise any unrelated context could be
  added to a signature to launder directness. Contexts already carry
  identity by declaration (CONTEXTS.md); opacity already controls
  construction (OPAQUE-STRUCTS.md); no private members, friend modules or
  visibility rules were needed.
* **Why the root is not special.** A program is capability-safe at its
  application-facing surface exactly when its root is not direct. A
  low-level program says so in its first line.
* **Why stale markers are errors.** A marker that survives its last direct
  edge is a permission under which a future direct call would hide.
* **Why constructors get no exemption.** A function returning a context is
  callable anywhere; exempting it would turn it into a context-free wrapper
  of raw authority (§3, "Context construction", which also has the pattern
  that needs no exemption).

What a non-direct root establishes: *every path from application code to a
module explicitly exposing raw authority crosses a module-owned context
boundary before that authority becomes available to ordinary code*. Nothing
more is claimed: no formal semantic security, no adequacy of a context's
policy.

## 5. The standard library: the syscall boundary

* **The direct modules of raw syscall authority are the transports
  `linux::abi::x86_64` and `linux::abi::aarch64`**, the intrinsic namespaces
  of `linux::abi::x86_64::syscall` and `linux::abi::aarch64::syscall` (the
  raw kernel transitions, LINUX-SYSCALL-TRANSPORTS.md), each declared direct
  by `core::native::declareDirectNamespace` beside its registration in
  core/linuxabi.tcl's loop over the transport table: a third architecture's
  transport is direct by the same line. They are the smallest module
  boundary of raw syscall authority: `abi::x86_64`'s and `abi::aarch64`'s
  register and address conversions (`from_bytes`, `from_mutable_bytes`,
  `register64`, ...) take no authority by themselves -- an address does
  nothing without the syscall -- and stay ordinary.
* **`linux::sys` (lib/linux/sys.x86_64.bot, lib/linux/sys.aarch64.bot, the
  target's architecture selecting one) is a declared direct module**, in
  both files: its `write` and `read` call the architecture's transport for
  any descriptor with no context.
* **`linux` (lib/linux.bot) is a declared direct module.** `write(fd, data)`
  and `read(fd, data)` call `linux::sys` with no context: they take *any*
  descriptor, raw process authority, by design (the explicit low-level
  layer, the same source on every architecture). Its marker is justified by
  inference (two undischarged edges).
* **`linux::io` (lib/linux/io.bot) is ordinary -- contextualized.** Every
  function that calls into `linux` requires `LinuxIO`, the opaque context it
  defines. One function needed a change: `write_all(fd, bytes)` (the
  short-write completion loop behind `write_text`) made its `fd.raw.write`
  call with no context of its own, taking the descriptor as an argument; it
  now also requires `context io: LinuxIO` (its callers, `write_text` and
  `write_error_text`, have it). Unused in the body, and free natively (a
  context parameter loads nothing until projected: CONTEXTS.md, "Loads").
  That is the rule's one friction in the existing library: the FileDescriptor
  token is already a capability-like value (opaque, minted only by
  linux::io), but the rule mediates by context, not by token, so the context
  is carried to the direct point as the rule requires.
* **Everything above is ordinary**: `io` (whose context trait `io::IO`
  linux::io implements), `linux::path`, the 2048 engine and demo (unchanged:
  they use linux::io only).
* **No module split was required.** The existing boundaries already matched:
  the raw transitions are their own intrinsic namespaces, the
  architecture's register convention and the descriptor-taking wrappers
  their own modules, the capability layer another. (linux::sys was split
  out of linux for the AArch64 port, not for directness; both are direct.)
* **Context establishment.** `linux::io::create()` builds the three
  descriptor tokens 0, 1, 2 with no syscall, so installing LinuxIO needs no
  direct authority: no bootstrap exception was needed.
* Programs that call `linux` or a transport themselves are low-level by
  nature and declare it: examples/linux/getpid.bot, write.bot, read-stdin.bot,
  the golden suites abi-bytes, abi-bytes-native, abi-numeric-native,
  imports-abi-child, linux-io, linux-io-native and linux-transports, and the
  test programs of tests/linux-syscall.test, linux-syscall-transports.test,
  abi-bytes.test, abi-mutable-bytes.test, abi-numeric.test and imports.test
  that make raw calls, and the raw programs the abi-bytes, mutable-bytes and
  imports fuzzers and bench/c-pointer-borrowing.tcl generate.
  examples/linux/context-hello.bot and examples/io/hello.bot are ordinary.

The syscall execution and lowering are unchanged: no wrapper, no runtime
check, no new instruction. The scalar-assembly corpus and the machine-code
tests of the syscall path are unchanged.

## 6. Implementation

| piece | where |
|---|---|
| the marker's grammar | surface/parser.tcl `DirectModule`, `AtDirectModule`, `MisplacedDirectModule`; the AST's `direct` (surface/ast.tcl) |
| module declarations | surface/modules.tcl `ModuleDecl`, the loader's `moduleDecls`, `BuildProgram`'s `-module-decls` |
| HIR | hir/hir.tcl: `-module-decls` -> `moduleDecls`; `hir::direct::verify` in `CheckOnce` after contexts; DIRECT an obligation kind of method calls; the monomorphized program keeps the checked program's summary |
| intrinsic metadata | core/native.tcl `declareDirectNamespace`, `isDirectNamespace`, `directNamespaces`, `namespaceOf`; core/linuxabi.tcl declares each transport's namespace |
| the analysis | hir/direct.tcl |
| static intrinsics | hir/static.tcl codes `DIRECT` -> `Direct`, `DIRECT-CALLABLE-VALUE` -> `DirectCallableValue`; lib/compiler.bot; lib/test.bot's `code_name` |

The analysis is one structural pass over the program's expressions: for each
call, its exact target's unit (memoized per scope) and whether it is
designated; for each edge, the innermost enclosing block (the scope's
`invocation`) and its context section. A second pass over references finds
direct callables in non-call positions, and only when one exists does it
build the parent map that tells a value use from an alias statement. No
fixed point: designation is per module and the module graph is acyclic
(`CYCLE` is unchanged, `dm-cycles-stay-forbidden`), and intra-module calls
are never edges. Nothing depends on source discovery or analysis order
(`dm-deterministic`).

What HIR keeps: `moduleDecls` (the declarations, as given) and `direct`:

```
units {NS {declared 0|1 marker ORIGIN provided 0|1 inferred 0|1 status STATUS
           edges {{function NAME origin ORIGIN target D callee NAME via call|trait
                   discharged CONTEXT foreign {{CONTEXT OWNER} ...}} ...}} ...}
intrinsic {linux::abi::x86_64 ...}
```

STATUS is `ordinary`, `contextualized`, `direct`, `provided` (an intrinsic
namespace), `unacknowledged` or `stale`. Both live in the HIR, never in a
process-wide registry, so compilation isolation holds by construction
(`dm-isolation`: one compilation's direct `a` never makes another's `a`
direct), and the HIR interchange format and the front-end cache carry them
unchanged (`dm-interchange-keeps-the-summary`). No lowering or backend reads
either: there is no runtime direct bit and no native representation
(`dm-no-runtime-representation`). Programs past the source boundary -- core
IR text, HIR text -- carry no `moduleDecls` and are not judged
(`dm-core-ir-untouched`): core IR text has nothing to be a module of, and
HIR text's module sections (HIR-INTERCHANGE.md) carry no designations.

The monomorphized build of a trait program is not judged again: directness
is a property of the program as written, decided on the checked build (whose
summary `hir::BuildFull` copies), and a trait plan's placeholder of
never-executed code must not make a module look stale.

Cost: the analysis is 0.5-0.9% of front-end time on the largest programs
measured (examples/games/2048/golden.bot: 49 ms of 7.0 s over 2 builds;
tests/golden/collections.bot: 109 ms of 14.9 s over 6 builds;
bench/uri-steady.bot: 3.6 ms of 530 ms) -- linear in expressions.

## 7. Tooling

`tclsh9.0 main.tcl -direct FILE.bot` prints, per module and the entry program,
the declaration, the inference, the status and every direct edge with the
context that mediates it:

```
module raw: direct (declared direct, inferred direct)
    raw::getpid -> linux::abi::x86_64::syscall (direct module linux::abi::x86_64, raw.bot:10:25): undischarged
module wrapper: contextualized (declared ordinary, inferred ordinary)
    wrapper::pid -> raw::getpid (direct module raw, wrapper.bot:10:5): mediated by wrapper::Pids
module consumer: ordinary (declared ordinary, inferred ordinary)
entry program: ordinary (declared ordinary, inferred ordinary)
intrinsic linux::abi::x86_64: provided direct by the compiler
```

`hir::direct::explain HIR NS` answers "why is this module direct?" for one
unit; `hir::direct::summary HIR` is the whole report.

## 8. What this is not

Not an unsafe-block system, not memory safety, not an effect system, not
function types with capabilities, not path-sensitive authority analysis,
context-field dataflow, whole-program aliasing or a proof that a context's
policy is adequate. Not private members, private functions or friend
modules (name visibility is not the security boundary; capability
availability is). No C: no `extern c fn`, no C calls, linking, capture,
ownership or alias analysis.

## 9. The future C binding architecture (future)

```
generated raw C binding module(s)            direct, by their declarations/contracts
    simple synchronous functions (Tcl_CreateInterp, Tcl_Eval, SHA256, ...)
    and/or retaining raw functions (stored pointers, callbacks)
        |
higher-level wrapper module                   defines Interpreter / TLS / DB context
    contextualizes the raw API                 -> ordinary
        |
application                                   imports the wrapper -> ordinary
```

Because directness is module-granular, the binding generator controls
useful capability granularity partly through module boundaries: one giant
raw binding with one capability-escaping API is direct as a whole, and its
callers mediate all of it; a generator may split mechanical bindings along
sensible boundaries. That policy is the generator's, not decided here.

**The hook.** `extern c fn` needs no new notion of dangerous authority, only
a third source of designation and, optionally, of inference, both in
hir/direct.tcl:

* `hir::direct::Designated HIR NS` answers "is NS a direct module?" from the
  source marker and `core::native::isDirectNamespace`. A foreign
  declaration's module whose contracts make it direct -- a declaration with a
  non-empty `hir::borrow::retaining` / `core::cabi::RetainingParameters`
  (C-POINTER-BORROWING.md, section 12: pointer authority retained beyond the
  call), or a module the generator declares direct -- is one more condition
  here (or the generator writes `direct module`, which the module's own calls
  of its retaining declarations then justify by inference).
* `hir::direct::Targets` turns a call into edges; a call of a retaining
  foreign declaration is a call into its (direct) module like any other, so
  nothing changes there unless the next milestone wants a foreign call to be
  an edge even within its own module -- one more case in `Targets` (a
  target that is itself an authority source).

> Filled by C-FFI.md (section 9) with the second option alone: a call of a
> retaining extern c fn is an edge of the calling unit in `Targets` (a
> target that is itself an authority source, its own module included), and
> no declaration designates its module: declaring a retaining function is
> not using it.

The rest -- edges, discharge by module-owned contexts, the marker
reconciliation, DIRECT-CALLABLE-VALUE, the diagnostics, static intrinsics,
the summary -- works unchanged. A synchronous foreign call whose pointer
parameters are all noescape need not be direct at all
(C-POINTER-BORROWING.md: "Foreign is not direct").

## 10. Tests, fuzzing, mutation testing, regression

* `tests/direct-modules.test` (56 tests; applications of several files in
  fresh directories, on interp and compile, natively where a value is the
  point): the grammar and its errors (`dm-parse-*`); intrinsic metadata and a
  probe intrinsic namespace; no name heuristic; the syscall acceptance case in
  its three states (`dm-syscall-unacknowledged`, `-declared`,
  `-contextualized`) and the stdlib's layering; top-level code; stale markers
  (no authority; fully mediated); no silent promotion; the context carried to
  the direct point; nested functions; foreign contexts and context
  identity; context construction; the transitive boundary (statuses, a native run, `-direct`);
  coarseness; direct modules with and without contexts; imports and types;
  callable escapes and aliases; context traits and value-trait operations;
  cycles; the root; recovery; unreachable code; method syntax; coroutine
  thunks; static intrinsics; isolation, interchange, determinism, core IR,
  the absence of a runtime representation; and the single executable
  (constraint `singleExecutable`: `BOTLISH_SINGLE` or single/out/botlish).
* `audit/direct-modules/tools/fuzz.tcl`: generated applications of 1..4
  modules (markers, own and foreign contexts, raw, direct, aliased and nested
  calls, escapes, a contextual or top-level entry program) against an
  independent model of the rules; per program the -strict 0 verdicts (kind
  and file), every unit's status, and the strict verdict must agree.
* `audit/direct-modules/tools/mutate.tcl` with `mutants.txt`: 18 mutants
  (item 67's list and more), each run against the test file and the fuzzer
  in a private copy of the tree.

Results: §11, items 67-72.

## 11. Milestone report

**Declared, inferred, contextualized, valid (item 74).** The four facts are
distinct and the summary keeps each:

* *declared direct*: the file's `direct module`, or trusted intrinsic
  metadata (`provided`);
* *inferred direct*: an undischarged direct edge exists;
* *contextualized*: direct edges exist and each is mediated by a context of
  the module (status `contextualized`, inferred and declared ordinary);
* *final validity*: inferred and declared agree (statuses `ordinary`,
  `contextualized`, `direct`, `provided`); otherwise DIRECT (`unacknowledged`)
  or STALE-DIRECT-MODULE (`stale`).

**Syscall integration (item 75).** §5: the transports `linux::abi::x86_64`
and `linux::abi::aarch64` direct by intrinsic metadata
(`core::native::declareDirectNamespace`); `linux::sys` (both architectures'
files) and `linux` direct by their markers, justified by their `write` and
`read`; `linux::io` imports `linux` and is contextualized by its own LinuxIO
(write, write_error, read, write_all); nothing else in the library imports
`linux`, `linux::sys` or a transport; no wrapper remains direct; no module
split was required.

**Context limitations (item 76).** One concrete case of friction:
`linux::io::write_all(fd, bytes)` receives an opaque, module-minted
FileDescriptor and still had to require LinuxIO, because the rule mediates
by the context in the function that makes the direct call, not by a token
argument. The rule was kept: the change is one context entry, free natively.
No other existing context API was affected, and no bootstrap limitation
appeared (linux::io::create makes no syscall). The latent one -- a context
whose *construction* needs raw authority, a future `openat`-minted
descriptor -- has a pattern under the unchanged rule and no exemption (§3,
"Context construction"): the owning module mints an authority-free first
context and its constructor requires it (`dm-context-construction-chain`).
Exempting constructors is unsound (a function returning a context is
callable anywhere, so an exempt one is a context-free wrapper of raw
authority); the sound variant, a constructor exempt only where every call
of it is a `with context` installation, is a cross-module call-site rule and
was not built. Also recorded: a context trait a module declares mediates
like its context structs (CONTEXT-TRAITS.md is part of the context system);
a context of another module never does.

**The `extern c fn` hook (item 77).** §9: `hir::direct::Designated` (a third
designation source, derived from foreign contracts:
`hir::borrow::retaining`) and, only if a foreign call must be an edge within
its own module, one case in `hir::direct::Targets`. No `direct fn`, direct
call or unsafe foreign call is needed.

Items in brief:

1-7. §2: `direct module`, a modifier of the file-derived module, first
construct, contextual words; located errors for misplaced, duplicate and
named markers; no call-, function- or block-level forms
(`dm-no-call-or-function-syntax`).
8-11. §3 Designation, Direct edges: designation by marker or metadata, never
by name; a call into a direct module is a direct edge, coarsely; import is
not.
12, 48. §3 First-class callables: DIRECT-CALLABLE-VALUE for returning,
storing, listing, passing, returning an alias; aliases as statements are
edges again.
13-19. §3 Discharge.
20, 45. Directness stops at the contextualization boundary
(`dm-transitive-boundary`, `dm-transitive-runs`).
21-22. A direct module calls raw code plainly and may also contextualize
some of it (`dm-direct-module-internal`, `dm-direct-module-with-contexts`).
23. Top-level direct calls are never mediated (`dm-syscall-raw-getpid`).
24. No bootstrap exception was needed (§5).
25-29. The summary (§6); intrinsic modules participate exactly like source
ones (`dm-intrinsic-metadata-participates`).
30. HIR, not a registry: isolation by construction (`dm-isolation`); the
isolation audit's tests pass (below).
31. Interchange and cache carry `moduleDecls` and `direct`
(`dm-interchange-keeps-the-summary`; interchange and cache tests below).
32. Application modules are judged exactly like library modules (every
test of tests/direct-modules.test is an application).
33, 72. The single executable (packed by single/build.sh from this tree) runs
an application of a raw module, a contextual wrapper and an ordinary root
natively from outside the checkout in an empty environment, rejects an
unmarked raw root with DIRECT and runs a declared direct root
(`dm-single-executable`).
34-37, 64. §3 Diagnostics.
38. §3 Static intrinsics; `Direct`, `DirectCallableValue` added to
`compiler::DiagnosticCode` (97 cases), the census and `test::code_name`.
39-41. No suppression; no silent promotion; no sticky permission.
42-47. The acceptance tests named in §10.
49. Contexts and opaque structs unchanged.
50-55. No C semantics; §9.
56-59. §1, §4.
60. `main.tcl -direct`, `hir::direct::explain`/`summary` (§7).
61-63. One structural pass; no fixed point needed; determinism; cycles
remain forbidden.
65. No runtime representation.
66. §6, Cost.
67-72. Regression, below.
73. This document.
78. None of the non-goals was built.

Regression and audit runs (Linux x86-64, Tcl 9.0.1), after the merge of
main's AArch64 transports (LINUX-SYSCALL-TRANSPORTS.md):

| run | result |
|---|---|
| `tests/direct-modules.test` (interp) | 56 tests, 0 failed (the single-executable test skipped without `BOTLISH_SINGLE`) |
| `audit/direct-modules/tools/fuzz.tcl -n 100`, seeds 2, 3, 17, 41 | 400 programs (137 accepted, 263 rejected), 0 disagreements |
| `audit/direct-modules/tools/mutate.tcl` | 18 mutants, 18 killed, 0 survivors |
| `tests/local.tcl -jobs 4` (every Tcl test file on interp and compile, golden duplicates skipped; every golden suite on four backends) | interp 5718 passed, 0 failed, 3 skipped; compile 5714 passed, 0 failed, 7 skipped (2098 golden duplicates skipped on each); golden suites 92 run: interp 4708/4708, compile 4708/4708, cranelift-generic 4616/4616, cranelift 4718/4718, and one failure, linux-transports.bot, whose marker was stale (every call it made was in a rejected block); with raw_x86_64 and raw_aarch64 added it passes 13/13 on four backends (1962 s) |
| `audit/golden/tools/check.tcl -suites linux-transports.bot,linux-io.bot,imports-abi-child.bot` | 85 ported rows, old pass, new pass: 85 |
| `audit/abi-bytes/tools/fuzz.tcl -mode write`, `audit/mutable-bytes/tools/fuzz.tcl -mode read` (`-n 20`), `audit/imports/tools/fuzz.tcl -n 40` | 0 failures, 0 failures, 0 disagreements (their raw programs now declare `direct module`) |
| `bench/c-pointer-borrowing.tcl -runs 1 -n 10 -sizes 16` | runs, the `linux` row included |
| `audit/refactor/tools/gate.tcl` (the warning gate: lib, examples, bench) | passed: the observed warnings are exactly the manifest |

Before the merge, on the same analysis:

| run | result |
|---|---|
| `audit/compilation-isolation/tools/interleave.tcl`, its ten suites plus linux-io.bot and imports-abi-child.bot (direct modules) | 12 suites, 96 artifacts and outcomes, 0 differ |
| `audit/compilation-isolation/tools/mutate.tcl` | 14 mutants, 14 killed |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` / `-via cache`, the same 12 suites | 108 / 120 artifacts and outcomes, 0 differ |
| `audit/hir-interchange/tools/mutate.tcl` | 27 mutants, 27 killed |
| `audit/contexts/tools/fuzz.tcl -n 100 -seed 20261017` | 100 programs, 0 disagreements |
| `audit/contexts/tools/mutate.tcl -n 30` | 26 mutants, 26 killed (one, `stdout-stderr-swapped`, no longer applied before this milestone -- lib/linux/io.bot's write had become `io.stdout.raw.write(data)` -- and its text was updated; it is killed) |
| `single/build.sh`, then `single/smoke-test.sh` and `dm-single-executable` with the built executable | smoke test passed; the test passes |
| NIR of examples/io/hello.bot and examples/linux/context-hello.bot, before and after | identical but for expression ids (`write_all`'s new context parameter loads nothing) |

Not run locally: the batched-against-sequential comparison of the golden
suites' static decisions (`audit/static-decisions/tools/compare.tcl`), which
AGENTS.md reserves for CI's `static-decisions` workflow; it runs on the next
push to main that changes the front end (or on demand on a branch).
