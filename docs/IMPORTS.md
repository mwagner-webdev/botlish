# Imports: explicit namespace dependencies

A source file cannot refer across a namespace boundary unless it says so in
its header. Two declarations, nothing else:

```
import std::list                    # this file depends on namespace `std::list`
import std::abi::x86_64             # ... on the nested namespace `std::abi::x86_64`
import type std::abi::U8Value       # ... and binds one short type name
import ::std::str                   # a rooted path: the same as `import std::str`
```

Every standard namespace is under the compiler-owned root `std`
(STD-NAMESPACE.md). A file's namespace is its path: `stdlib/abi/x86_64.bot`
is `std::abi::x86_64` (stdlib/ is the directory of `std`), and nothing inside
the file states it (there is no `namespace` declaration; the
word is an ordinary name and a `namespace NAME` line is a syntax error). The
entry program is in no namespace. A program's own modules are the files
beside its entry file, by the same rule: `game.bot` next to `main.bot` is
`game`, `util/math.bot` is `util::math` ([Application
modules](#application-modules)).

```
# stdlib/foo.bot: namespace std::foo, by its path

import std::abi
import std::list
import type std::abi::U8Value

fn f(x: U8Value) -> std::abi::U8Value:
    xs = [x]
    std::list::at(xs, 0):
        on IndexNotFound:
            x
```

## What an import means

`import std::list` means: *this file directly depends on the namespace
`std::list`; qualified `std::list::...` references are allowed, and the
functions of `std::list` participate in method-call resolution.* It does
**not** mean *copy every name of `std::list` into this file*:
`std::list::at(xs, 0)` is valid and `at(xs, 0)` and `std::list::at(xs, 0)` are not
(unless an ordinary binding named `at` exists for its own reasons). No hidden
alias `at -> std::list::at` is created.

`import type std::abi::U8Value` is the one deliberately narrow exception: *import
exactly one type's final component as a local short type name.* It names a
type position only (`x: U8Value`); it creates no value or function binding,
authorizes nothing else of `std::abi` (`std::abi::u8(...)` still needs `import std::abi`),
and is not a type alias: `U8Value` and `std::abi::U8Value` are one canonical type.

Imports are **exact**, never subtree imports. `import std::abi` does not import
`std::abi::x86_64`; `import std::abi::x86_64` does not import `std::abi`. Every module
declares its own dependencies; nothing is transitive (if A imports B and B
imports C, A still writes `import C` to use `C::...`, a method candidate of
`C`, or a type of `C`).

## Grammar

```
program       = { importDecl } { statement-or-declaration }
importDecl    = "import" path NEWLINE
              | "import" "type" path NEWLINE
path          = [ "::" ] IDENT { "::" IDENT }
```

* The namespace path has one or more components (`std::abi::x86_64`,
  `std::linux::abi`, a depth-three path would parse the same way): the grammar
  names an arbitrary *existing* namespace. This milestone adds no way to
  *create* nested namespaces; it only imports what exists
  (`stdlib/abi/x86_64.bot` is `std::abi::x86_64` by its path, as it was).
* A type import's path ends in the type's name and has at least two
  components: `import type foo::bar::Baz` is type `Baz` of namespace
  `foo::bar`.
* A leading `::` roots the path (`import ::std::list`, STD-NAMESPACE.md):
  every path is resolved from the root, so it names the same namespace as
  `import std::list` (and a second one is DUPLICATE-IMPORT).
* `import` is a *contextual* word, not a keyword: it starts an import only
  when immediately followed by a name, by `type` or by a `::` set apart
  from it (`import::f` is still a qualified name), which no other
  construct allows, so `import = 5` and `import(x)` keep their meaning.
  `type` after `import` is recognized structurally (it is already reserved),
  never as a namespace named `type`.
* There is no `as`, no `*`, no `from ... import`, no `import fn`: each is a
  specific syntax error that says so.

### Canonical header order

```
direct module (optional, at most once: DIRECT-MODULES.md)
imports (namespace imports and type imports, any order among themselves)
everything else
```

Imports are file-header declarations, valid in modules and in entry
programs alike. An import after another declaration or statement, or inside
a function, loop, branch or handler, is a syntax error. The order of
imports among themselves is irrelevant: `import std::abi; import std::list` and
`import std::list; import std::abi` mean the same thing, and the diagnostics never
depend on it. Because the header precedes every declaration, "a type
declared in this file and imported with `import type`" can only be written in
the order import-then-declaration; either way it is rejected (below).

Entry programs get no implicit imports: the standard namespaces
(`std::list`, `std::str`, `std::mutable_array`, `std::abi`, ...) are not
special, and there is no prelude. The root language
primitives (`+ == list integer? hash argv ...`) are not namespaced and need
no import.

## Where imports live in the compiler

```
source ──parse──▶ AST (program.imports: `import` / `typeimport` nodes)
                    │            surface/parser.tcl, surface/ast.tcl
                    ▼
        surface::modules::CollectAndLoad   validates the header, loads what it
                    │                      names, authorizes every qualified
                    │                      reference           surface/modules.tcl
                    ▼
  import environment  NAMESPACE -> {namespaces {..} types {SHORT CANONICAL ..}}
                    │            hir::buildSyntax -imports, hir/imports.tcl
                    ▼
        hir::resolve  method candidates, type names     hir/resolve.tcl, hir/types.tcl
                    ▼
                   HIR / core IR / NIR   -- no import anywhere
```

* The AST keeps the header only as `program.imports`; it is not a statement
  of `body`, is not walked as a child, and is never lowered to a syntax
  node. The module AST cache (`surface::modules::ParseModule`, keyed by
  path and text) stores exactly that parse and nothing that depends on an
  importer: short type bindings and method visibility are computed per
  compilation from the *importing* file's header, in the loader's state and
  the import environment above, never written into a cached AST.
* An import is not a call, a binding, an expression or a runtime
  initialization. HIR has no import node; type imports are resolved to the
  canonical `NS::Type` identity the moment a type annotation is resolved,
  so no alias survives into HIR; a method call resolves to the same callee
  (`native std::list::at`, or the very module function) a qualified call does.
  No backend (interpreter, Tcl compiler, native) knows imports exist.
* The loader's dependency graph is `state imports`: each file's direct
  imports, recorded per file (`LoadNamespaces` returns it as `imports`),
  without scanning bodies. Imports are the *only* thing that loads a module:
  a qualified reference never loads anything. Module-cycle detection is
  unchanged (`CYCLE`, now found through imports).

### What an import loads

An import loads the namespace's module file if it has one (`import std::list` loads
`stdlib/list.bot`, `import std::abi::x86_64` loads `stdlib/abi/x86_64.bot`, `import game`
in an application loads the `game.bot` beside its entry file, each at most
once per program), and nothing if the namespace is intrinsics-only
(`import std::str`). An architecture-specific namespace has no `stdlib/NAME.bot` but
one `stdlib/NAME.ARCH.bot` per architecture, and the import loads the one of the
compilation target's architecture (`import std::linux::sys` loads
`stdlib/linux/sys.x86_64.bot` or `stdlib/linux/sys.aarch64.bot`;
LINUX-SYSCALL-TRANSPORTS.md). The target table designates the standard
namespace trees that are an operating system's platform interface
(core/cabi.tcl's `platforms`: `std::linux` and everything under it): importing
one for a target of another operating system is `UNSUPPORTED-PLATFORM` at
the import, before any file is chosen
(`import std::linux::sys` for macos-aarch64 never loads `sys.aarch64.bot`;
MACOS-AARCH64-MILESTONE-2.md). An application module is the application's
whatever its name. That is the whole of module loading: a module that is not
imported, directly or by another module's own header, is never loaded. One
visible consequence while `error` declarations stay global: `import std::list`
brings `error NotFound` (declared by `stdlib/list.bot`) into the program, so a
program that declares its own `error NotFound` collides with it, and says
where. (Types do not leak this way any more.)

## Namespace authorization and existence

A qualified reference `ns::member` (an expression, a struct construction
`ns::Name { ... }`, a type annotation `x: ns::Type`) is checked in this
order:

1. Is `ns` the file's own namespace (its path), or imported **exactly**? A
   module is inside its namespace and needs no import to name its own members. Anything
   else (parent, child, transitive) is not authorized:
   `MISSING-IMPORT: namespace "std::abi::x86_64" is not imported; add `import
   std::abi::x86_64` to use `std::abi::x86_64::register64` (imports are exact: `import
   std::abi` does not import "std::abi::x86_64")`.
2. If authorized, does the member exist? Otherwise `UNKNOWN-SYMBOL`.

so `std::str::concat` without `import std::str` is `MISSING-IMPORT` even though the
compiler knows it, and `std::str::reverse` after `import std::str` is `UNKNOWN-SYMBOL`,
never `MISSING-IMPORT`. A reference into a namespace that does not exist at
all is `UNKNOWN-NAMESPACE` (no import could repair it).

A namespace *exists* if there is a source module file for it
(`stdlib/NAME.bot` for `std::NAME`, one directory per leading segment, or
for an application file an application module `ROOT/NAME.bot`) **or** it has compiler
intrinsics (qualified root natives): `import std::str` is valid with no
`stdlib/str.bot`; `import std::linux::abi::x86_64` is valid for
`std::linux::abi::x86_64::syscall`. A bare prefix of either (`import std::linux::abi`)
is not a namespace. The intrinsic
machinery (`core::native::qualifiedMembers`, `isQualifiedNative`) is the
existing one; source-declared type predicates registered for one compilation
are marked source natives and are not intrinsics (they do not make a
namespace exist and are not protected members).

Header diagnostics, all located at the import:

| Kind | When |
|------|------|
| `UNKNOWN-NAMESPACE` | `import nosuch` -- resolved at the import, not at a later use; from an application file the message names the application path, and the standard namespace `std::nosuch` if there is one; `import std` (the root) |
| `DUPLICATE-IMPORT` | the same namespace (or the same type) imported twice |
| `SELF-IMPORT` | a file imports its own namespace (or one of its own types), or the entry program imports its own file |
| `RESERVED-NAMESPACE` | an application file imports `std::NAME` while the application has a file `ROOT/std/NAME.bot` (below) |
| `MODULE-COLLISION` | an application file imports a namespace outside std that is both an application file and compiler intrinsics (a test process's fixtures only; below) |
| `UNKNOWN-SYMBOL` | `import type std::abi::DoesNotExist`: `std::abi` exists, has no such type |
| `NOT-A-TYPE` | `import type std::abi::u8` (a function), or a struct / error: it exists, but is not a source-defined `type` |
| `TYPE-IMPORT-COLLISION` | see below |

Imports never grant authority over ownership: `import std::list` does not let a
file define `std::list::at` -- the protected-intrinsic rule
(`DUPLICATE-NATIVE`, STDLIB-NAMESPACES.md §4) is about who *declares* inside a
namespace, and is unchanged.

## Methods

`x.f(a)` is `f(x, a)` when `f` is visible and the ordinary call is valid
(METHOD-SUGAR.md). The visible `f`s are now:

* what ordinary lexical resolution finds for `f` (the file's functions,
  parameters and local bindings, root natives) -- unchanged; and
* for every namespace the file **directly** imports, that namespace's
  member `f`: a module function or an intrinsic (`std::list::at` for
  `import std::list`; `std::abi::x86_64` members only for `import std::abi::x86_64`).

There is no priority of any kind -- not import order, not shortest name, not
"local wins", not "stdlib wins". Candidates that are one function (an alias
of an imported function, `at = std::list::at`) count once. A candidate that is
statically a function of a different arity is not a candidate (unless that
leaves none, which keeps the ordinary arity error). Then:

* zero candidates: the call is the call of the field `f`, as always;
* one: it is that call (the same HIR callee as the qualified spelling);
* several: **the ordinary call with the receiver as first argument is tried
  with each** (`hir::buildSyntax` builds the program once per candidate
  position -- only a program with such a call pays -- and counts a
  candidate valid if its call has no diagnostic of its own: a declared
  parameter type or inferred contract the receiver cannot prove, a native
  whose first parameter is of a different known kind, an invalid flag,
  ...; declared errors nobody handled are obligations of a *fit* call, not
  evidence it does not fit). Exactly one valid: that one. More than one:
  `AMBIGUOUS-METHOD-CALL` naming them. None: `NO-APPLICABLE-METHOD`, which
  says why each fails.

So with `import std::list` and `import std::mutable_array`, `xs.at(i)` on a `List` and
`a.at(i)` on a `MutableArray` each resolve (the other candidate rejects the
receiver's kind), while `q.at(i)` on an untyped `q` is ambiguous: say
`std::list::at(q, i)`.

Qualified calls are never ambiguous: `alpha::f(x)` and `beta::f(x)` are two
exact names; imports authorize them, they do not merge them.

## Types

A source-declared `type` is a member of its namespace:

```
# stdlib/abi.bot
type U8Value = Int in 0..255       # declares std::abi::U8Value
struct U8:
    value: U8Value                 # the defining module names it bare
```

Its canonical identity is `NAMESPACE::Name` (`std::abi::U8Value`) -- in the type
registry, in HIR's `sourceTypes`, in `int[std::abi::U8Value]` diagnostics and
printed HIR. The entry program's own types keep their bare name
(`Small`). Two modules can declare the same short type name without
colliding, and loading an unrelated module no longer makes its type names
available anywhere: a module sees its own types, the types it imports, and
the built-in types (not the entry program's).

Three ways to spell a type, all the one canonical type (no alias node, no
wrapper, no conversion):

```
import std::abi
fn a(x: std::abi::U8Value): ...           # qualified: needs `import std::abi`

import type std::abi::U8Value
fn b(x: U8Value): ...                # short: needs `import type`, nothing else

# inside stdlib/abi.bot
fn c(x: U8Value): ...                # the defining namespace
```

`import type` imports source-declared `type`s (integer-domain refinements)
only. Structs keep their qualified spelling after `import NS`
(`x: std::abi::U8`, `std::abi::U8 { value: v }`). Errors are not namespaced
(below).

A type is never a value: a `type` declaration adds no member to its
namespace's values, so neither `import NS` nor `import type NS::T` brings a
value or a function with it. There is no type predicate `U8Value?(v)` (nor
`std::abi::U8Value?(v)`): a namespace offers exactly the functions it declares --
a converter such as `std::abi::u8`, or a predicate it writes itself
(ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md).

### Collision rules

A type import's short name is a *type* name. Rejected (`TYPE-IMPORT-COLLISION`
naming both sides; no first/last/nearest wins, no implicit qualification):

* the same short name imported from two namespaces
  (`import type alpha::Count` + `import type beta::Count`);
* a type the same file declares itself (`type`/`struct` of that name);
* a built-in type (`Int`, `List`, `Byte`-like compiler-registered names).

Importing the same type twice is `DUPLICATE-IMPORT`. A module's own
declarations remain usable bare; the import exists for consumers.

An import never grants authority over a struct's *representation*: a struct
declared `opaque struct` (OPAQUE-STRUCTS.md) may be named, passed, stored and
compared by any file that imports its namespace, but only the declaring module
may construct it from its fields or inspect its fields. The owner is the declaring
namespace exactly (no parent, child or transitive import has any authority), and
it comes from the loader's canonical module identity, never from the cached AST.

Types and values are separate namespaces in Botlish already (a type name is
never a lexical binding), so a type import does not collide with a value
binding of the same spelling (`U8Value = 5` is fine and unrelated).

## Application modules

A program's own modules live beside it: the directory of the entry file
(the `.bot` file main.tcl or the single executable is given) is the
program's **application root**, and an application of several files is just
that directory:

```
project/
    main.bot          import game
    game.bot          import util::math
    util/math.bot
```

`import game` in `main.bot` loads `project/game.bot` as namespace `game`, an
ordinary module: one namespace, parsed and compiled once however many files
import it, its own definitions bare inside it and qualified (`game::move`)
outside it, its functions method candidates of its importers, its types,
structs, enums and errors `game::`-qualified, its opaque structs constructed
and inspected by `game.bot` alone (OPAQUE-STRUCTS.md). Nothing has to be
copied into `stdlib/`, and nothing is.

**Resolution** (STD-NAMESPACE.md). A namespace path is resolved from the
namespace root, and its first segment says whose it is, with no search
beyond that and no fallback from one to the other:

1. `std::NAME` is a standard namespace, for every file alike:
   `$::core::libraryDir/NAME.bot` (`stdlib/` in a checkout, the packed
   `stdlib/` in the single executable: the directory of the namespace
   `std`), the target architecture's `NAME.ARCH.bot` there for an
   architecture-specific one (`std::linux::sys`), or compiler intrinsics
   (`std::str`). `std` itself is no namespace.
2. A `NAME` whose first segment names a package installed in the
   importing file's scope -- `ROOT/.bot_modules/NAME` for an application
   file -- is that package's module (`.bot_modules/NAME/NAME.bot`,
   `.bot_modules/NAME/NAME/a.bot` for `NAME::a`): the package claims that
   root namespace, and an application file of it is `MODULE-COLLISION`
   ([Installed packages](#installed-packages-bot_modules)).
3. Any other `NAME`, imported by an *application file* -- the entry program,
   or an application module -- is the application module `ROOT/NAME.bot`
   (`ROOT/a/b.bot` for `a::b`).
4. Else nothing: `UNKNOWN-NAMESPACE`, naming `ROOT/NAME.bot` -- and, when
   the standard library has a namespace `std::NAME`, saying so (the hint of
   a missing `std::`, never a fallback to it).

A standard-library module's own imports are resolved in the standard library
only: an application never changes what `stdlib/test.bot` imports, and a
standard module imports standard namespaces only (`import std::abi`).

A leading `::` roots a path explicitly: `import ::std::list` is `import
std::list`, `::std::list::at(xs, 0)` is `std::list::at(xs, 0)` -- in a
qualified value, a construction, a type, an error name or an imprint alike
(the grammar above). Every path is resolved from the root either way, so the
root marker is never part of an identity; the only thing it decides is that
a rooted qualifier is a namespace path, never a type of the file
(`::Color::Red` is not the file's enum Color's case).

**The root is the entry file's directory and nothing else**: not the shell's
working directory (`cd /; botlish /path/to/main.bot` and `cd /path/to;
botlish main.bot` compile the same program), not an environment variable,
not a parent directory, not a list of paths. Program *text* compiled with no
file of its own (`surface::compile TEXT`) has no root unless its caller names
one (`surface::compile TEXT FILE -root DIR`, what bench/2048.tcl does for its
edited benchmark text): it imports standard namespaces only.

**Local modules and standard namespaces coexist.** An application module
`list.bot` is the namespace `list`; the standard one is `std::list`. A
program may import both and use both:

```
project/
    main.bot          import list
                      import ::std::list
                      [list::shuffle(xs), std::list::length(xs)]
    list.bot          fn shuffle(xs): ...
```

Their module identities, members, types and errors are distinct
(`list::Error` and `std::list::NotFound`), and a method call `xs.length()`
sees the candidates of both imports, decided by the ordinary rule
(METHOD-SUGAR.md: one valid candidate, else ambiguity, never a precedence).

**The standard library cannot be shadowed.** `std` is reserved: an
application file `ROOT/std/NAME.bot` would be the namespace `std::NAME` by its
path, so it is never a module; when an application file imports `std::NAME`
and the application has that file, the import is `RESERVED-NAMESPACE`, which
names it -- never a silent choice of either. The one ambiguity left between
an application and the compiler is a namespace outside std with compiler
intrinsics, which only a test process registers (`ffi_fixture`): an
application file of that name is `MODULE-COLLISION`. An application file that
is never imported collides with nothing. Importing the entry file itself is
`SELF-IMPORT` (from the entry) or `CYCLE` (from one of its modules). Cycles
between application modules are `CYCLE`, as between library modules.

**After the front end.** The analyzed HIR holds every module it was built
from, so a `.hirx` (`-emit-hir-interchange`) runs on every backend, becomes
NIR, CLIF or an executable with the source directory gone. The front-end
cache keys a program by its application root as well and records each
import's application path as a dependency (HIR-INTERCHANGE.md).

There is no package manager here: no manifest, no dependency download, no
versions, no lock file, no search through installation directories.
(`surface/modules.tcl`'s `ResolveModule` is the rule; tests in
`tests/application-modules.test`; 2048-ENGINE-WORKLOAD.md's S4 is the
finding.)

## Installed packages (`.bot_modules`)

A package is an ordinary module tree installed under the immediate
`.bot_modules` directory of its owner (BOT-MODULES-MILESTONE-1.md):

```
game/
    main.bot                       import sdl3::video
    .bot_modules/
        sdl3/
            sdl3.bot               the namespace sdl3
            sdl3/video.bot         sdl3::video
            .bot_modules/
                helper/helper.bot  sdl3's own package helper
```

Every file has an owning scope: the application, the standard library or
one package instance. An import is resolved in the importing file's scope
only, by its first segment: `std::...` is the standard library's; a segment
that names a package installed in the scope's own `.bot_modules` is that
package's (the whole root namespace: an own file of it beside the package
is `MODULE-COLLISION`); otherwise the scope's own tree -- the application's
files, or a package's own root namespace (`sdl3`, `sdl3::...`). Nothing is
looked up upward or sideways: a package never sees its consumer's modules
or packages, a sibling package or an ancestor's, and the application never
sees a package its package installed. Imports stay exact and
non-transitive; a leading `::` roots a path but never leaves a scope.

A package instance is its place in the logical dependency tree (`sdl3`;
`sdl3/helper`, sdl3's own helper), and a module's canonical identity is that
place and its namespace below the package's root: `sdl3::video` for the
application's sdl3, `physics/geometry::Point` for a type of physics's own
geometry. Two installed copies of a package are two instances: their
types, errors, contexts and functions are distinct on every backend. No
manifest, version, lock or registry is read; the installed directories are
the whole of it. `tests/bot-modules.test` holds the tests.

## Corpus migration

A migrated file is the same program plus a header: `x = std::list::at(xs, i)` is
unchanged under `import std::list`. The standard library declares its own
dependencies (`stdlib/abi/x86_64.bot`: `import std::abi`; `stdlib/web.bot`: `import
std::ascii`, `std::byte`, `std::immutable_set`, `std::list`, `std::str` and `import type std::byte::Byte`;
`stdlib/ascii.bot`: `import type std::byte::Byte` replaces the old "the Byte type is
registered globally once somebody loads byte" convention). Method calls on
imported functions need no `at = std::list::at` binding; where one existed for
that reason alone it was removed.

## Not in this milestone

Import aliases, `as`, namespace aliases, wildcard imports, `using`, selective
function/value imports, re-exports, public/private imports, export lists,
private module members, package management (installed packages came later,
without a package manager: [Installed packages](#installed-packages-bot_modules)),
subtree imports, implicit imports, import-driven initialization,
transitive visibility, nested-namespace *creation* or inheritance, overload
resolution, namespaced `error` declarations.

Private module members came later: a top-level declaration written
`private` is accessible only to code of its own module, by the module's
canonical identity (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md). An
import still loads the whole module; what it may name there is the
module's public declarations.

Errors (`error NAME`) were the remaining global declaration category; they
now have the same `NAMESPACE::Name` identity (ERROR-PAYLOADS.md,
"Module-qualified error identity"): a module's error is named by its short
name inside the module and qualified outside it -- in `fail`, `on`, an
`errors` clause and a function type's `errors` list -- authorized exactly as
every qualified member is (`import NS` exactly; MISSING-IMPORT,
UNKNOWN-NAMESPACE, UNKNOWN-SYMBOL from `surface::modules::CollectAndLoad`).
There is no `import error` form (yet): outside its module an error is
spelled qualified.

## Tests and fuzzing

* `tests/imports.test` (104 tests): grammar and AST, exact authorization
  (parent / child / transitive / intrinsic-only / nested / `std::linux::abi`),
  unknown member vs missing import vs unknown namespace, duplicate and self
  imports, no injected names, no import in HIR/core IR/NIR, method
  candidates (imports, typed winners, ambiguity in either import order, nested
  exactness, lexical candidates, aliases), types (identity, `import type`,
  a module naming another module's integer domain and refinement qualified
  or type-imported, collisions, non-types, nested namespaces, ABI), cache
  non-leakage, dependency graph, cycles, protected intrinsics.
* `tests/bot-modules.test`: installed packages (`.bot_modules`), their
  scopes, collisions and package-instance identity
  (BOT-MODULES-MILESTONE-1.md); `audit/bot-modules/tools/fuzz.tcl` and
  `mutate.tcl`.
* `audit/imports/tools/fuzz.tcl`: random valid programs over `list::`,
  `str::`, `mutable_array::`, `abi::`, `std::abi::x86_64::` and `std::linux::abi::` with
  exactly the imports they need, method and type-import spellings checked
  against the qualified spelling, the four backends and a Tcl oracle; and
  thirteen rotating negative shapes (see the file's header).
* The other fuzzers and benchmark drivers that assemble programs from
  fragments declare their dependencies with
  `surface::modules::ImportHeader TEXT` (exactly the namespaces TEXT names).
