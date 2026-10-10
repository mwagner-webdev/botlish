# Imports: explicit namespace dependencies

A source file cannot refer across a namespace boundary unless it says so in
its header. Two declarations, nothing else:

```
import list                    # this file depends on namespace `list`
import abi::x86_64             # ... on the nested namespace `abi::x86_64`
import type abi::U8Value       # ... and binds one short type name
```

A file's namespace is its path: `lib/abi/x86_64.bot` is `abi::x86_64`, and
nothing inside the file states it (there is no `namespace` declaration; the
word is an ordinary name and a `namespace NAME` line is a syntax error). The
entry program is in no namespace.

```
# lib/foo.bot: namespace foo, by its path

import abi
import list
import type abi::U8Value

fn f(x: U8Value) -> abi::U8Value:
    xs = [x]
    list::at(xs, 0):
        on IndexNotFound:
            x
```

## What an import means

`import list` means: *this file directly depends on the namespace `list`;
qualified `list::...` references are allowed, and the functions of `list`
participate in method-call resolution.* It does **not** mean *copy every name
of `list` into this file*: `list::at(xs, 0)` is valid and `at(xs, 0)` is not
(unless an ordinary binding named `at` exists for its own reasons). No hidden
alias `at -> list::at` is created.

`import type abi::U8Value` is the one deliberately narrow exception: *import
exactly one type's final component as a local short type name.* It names a
type position only (`x: U8Value`); it creates no value or function binding,
authorizes nothing else of `abi` (`abi::u8(...)` still needs `import abi`),
and is not a type alias: `U8Value` and `abi::U8Value` are one canonical type.

Imports are **exact**, never subtree imports. `import abi` does not import
`abi::x86_64`; `import abi::x86_64` does not import `abi`. Every module
declares its own dependencies; nothing is transitive (if A imports B and B
imports C, A still writes `import C` to use `C::...`, a method candidate of
`C`, or a type of `C`).

## Grammar

```
program       = { importDecl } { statement-or-declaration }
importDecl    = "import" path NEWLINE
              | "import" "type" path NEWLINE
path          = IDENT { "::" IDENT }
```

* The namespace path has one or more components (`abi::x86_64`,
  `linux::abi`, a depth-three path would parse the same way): the grammar
  names an arbitrary *existing* namespace. This milestone adds no way to
  *create* nested namespaces; it only imports what exists
  (`lib/abi/x86_64.bot` is `abi::x86_64` by its path, as it was).
* A type import's path ends in the type's name and has at least two
  components: `import type foo::bar::Baz` is type `Baz` of namespace
  `foo::bar`.
* `import` is a *contextual* word, not a keyword: it starts an import only
  when immediately followed by a name or by `type`, which no other
  construct allows, so `import = 5` and `import(x)` keep their meaning.
  `type` after `import` is recognized structurally (it is already reserved),
  never as a namespace named `type`.
* There is no `as`, no `*`, no `from ... import`, no `import fn`: each is a
  specific syntax error that says so.

### Canonical header order

```
imports (namespace imports and type imports, any order among themselves)
everything else
```

Imports are file-header declarations, valid in modules and in entry
programs alike. An import after another declaration or statement, or inside
a function, loop, branch or handler, is a syntax error. The order of
imports among themselves is irrelevant: `import abi; import list` and
`import list; import abi` mean the same thing, and the diagnostics never
depend on it. Because the header precedes every declaration, "a type
declared in this file and imported with `import type`" can only be written in
the order import-then-declaration; either way it is rejected (below).

Entry programs get no implicit imports: the standard namespaces (`list`,
`str`, `mutable_array`, `abi`, ...) are not special. The root language
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
  (`native list::at`, or the very module function) a qualified call does.
  No backend (interpreter, Tcl compiler, native) knows imports exist.
* The loader's dependency graph is `state imports`: each file's direct
  imports, recorded per file (`LoadNamespaces` returns it as `imports`),
  without scanning bodies. Imports are the *only* thing that loads a module:
  a qualified reference never loads anything. Module-cycle detection is
  unchanged (`CYCLE`, now found through imports).

### What an import loads

An import loads the namespace's module file if it has one (`import list` loads
`lib/list.bot`, `import abi::x86_64` loads `lib/abi/x86_64.bot`, each at
most once per program), and nothing if the namespace is intrinsics-only
(`import str`). That is the whole of module loading: a module that is not
imported, directly or by another module's own header, is never loaded. One
visible consequence while `error` declarations stay global: `import list`
brings `error NotFound` (declared by `lib/list.bot`) into the program, so a
program that declares its own `error NotFound` collides with it, and says
where. (Types do not leak this way any more.)

## Namespace authorization and existence

A qualified reference `ns::member` (an expression, a struct construction
`ns::Name { ... }`, a type annotation `x: ns::Type`) is checked in this
order:

1. Is `ns` the file's own namespace (its path), or imported **exactly**? A
   module is inside its namespace and needs no import to name its own members. Anything
   else (parent, child, transitive) is not authorized:
   `MISSING-IMPORT: namespace "abi::x86_64" is not imported; add `import
   abi::x86_64` to use `abi::x86_64::register64` (imports are exact: `import
   abi` does not import "abi::x86_64")`.
2. If authorized, does the member exist? Otherwise `UNKNOWN-SYMBOL`.

so `str::concat` without `import str` is `MISSING-IMPORT` even though the
compiler knows it, and `str::reverse` after `import str` is `UNKNOWN-SYMBOL`,
never `MISSING-IMPORT`. A reference into a namespace that does not exist at
all is `UNKNOWN-NAMESPACE` (no import could repair it).

A namespace *exists* if there is a source module file for it
(`lib/NAME.bot`, one directory per leading segment) **or** it has compiler
intrinsics (qualified root natives): `import str` is valid with no
`lib/str.bot`; `import linux::abi` is valid for `linux::abi::syscall`. A bare
prefix of either (`import linux`) is not a namespace. The intrinsic
machinery (`core::native::qualifiedMembers`, `isQualifiedNative`) is the
existing one; source-declared type predicates registered for one compilation
are marked source natives and are not intrinsics (they do not make a
namespace exist and are not protected members).

Header diagnostics, all located at the import:

| Kind | When |
|------|------|
| `UNKNOWN-NAMESPACE` | `import nosuch` -- resolved at the import, not at a later use |
| `DUPLICATE-IMPORT` | the same namespace (or the same type) imported twice |
| `SELF-IMPORT` | a file imports its own namespace (or one of its own types) |
| `UNKNOWN-SYMBOL` | `import type abi::DoesNotExist`: `abi` exists, has no such type |
| `NOT-A-TYPE` | `import type abi::u8` (a function), or a struct / error: it exists, but is not a source-defined `type` |
| `TYPE-IMPORT-COLLISION` | see below |

Imports never grant authority over ownership: `import list` does not let a
file define `list::at` -- the protected-intrinsic rule
(`DUPLICATE-NATIVE`, STDLIB-NAMESPACES.md §4) is about who *declares* inside a
namespace, and is unchanged.

## Methods

`x.f(a)` is `f(x, a)` when `f` is visible and the ordinary call is valid
(METHOD-SUGAR.md). The visible `f`s are now:

* what ordinary lexical resolution finds for `f` (the file's functions,
  parameters and local bindings, root natives) -- unchanged; and
* for every namespace the file **directly** imports, that namespace's
  member `f`: a module function or an intrinsic (`list::at` for
  `import list`; `abi::x86_64` members only for `import abi::x86_64`).

There is no priority of any kind -- not import order, not shortest name, not
"local wins", not "stdlib wins". Candidates that are one function (an alias
of an imported function, `at = list::at`) count once. A candidate that is
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

So with `import list` and `import mutable_array`, `xs.at(i)` on a `List` and
`a.at(i)` on a `MutableArray` each resolve (the other candidate rejects the
receiver's kind), while `q.at(i)` on an untyped `q` is ambiguous: say
`list::at(q, i)`.

Qualified calls are never ambiguous: `alpha::f(x)` and `beta::f(x)` are two
exact names; imports authorize them, they do not merge them.

## Types

A source-declared `type` is a member of its namespace:

```
# lib/abi.bot
type U8Value = Int in 0..255       # declares abi::U8Value
struct U8:
    value: U8Value                 # the defining module names it bare
```

Its canonical identity is `NAMESPACE::Name` (`abi::U8Value`) -- in the type
registry, in HIR's `sourceTypes`, in `int[abi::U8Value]` diagnostics and
printed HIR. The entry program's own types keep their bare name
(`Small`). Two modules can declare the same short type name without
colliding, and loading an unrelated module no longer makes its type names
available anywhere: a module sees its own types, the types it imports, and
the built-in types (not the entry program's).

Three ways to spell a type, all the one canonical type (no alias node, no
wrapper, no conversion):

```
import abi
fn a(x: abi::U8Value): ...           # qualified: needs `import abi`

import type abi::U8Value
fn b(x: U8Value): ...                # short: needs `import type`, nothing else

# inside lib/abi.bot
fn c(x: U8Value): ...                # the defining namespace
```

`import type` imports source-declared `type`s (integer-domain refinements)
only. Structs keep their qualified spelling after `import NS`
(`x: abi::U8`, `abi::U8 { value: v }`). Errors are not namespaced
(below).

The type predicate of a type, `U8Value?(v)`, is the type's own member: bare
inside the declaring file for the entry program or module that declares it,
`abi::U8Value?(v)` (after `import abi`) elsewhere.

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

## Corpus migration

A migrated file is the same program plus a header: `x = list::at(xs, i)` is
unchanged under `import list`. The standard library declares its own
dependencies (`lib/abi/x86_64.bot`: `import abi`; `lib/web.bot`: `import
ascii`, `byte`, `immutable_set`, `list`, `str` and `import type byte::Byte`;
`lib/ascii.bot`: `import type byte::Byte` replaces the old "the Byte type is
registered globally once somebody loads byte" convention). Method calls on
imported functions need no `at = list::at` binding; where one existed for
that reason alone it was removed.

## Not in this milestone

Import aliases, `as`, namespace aliases, wildcard imports, `using`, selective
function/value imports, re-exports, public/private imports, export lists,
subtree imports, implicit imports, import-driven initialization,
transitive visibility, nested-namespace *creation* or inheritance, overload
resolution, namespaced `error` declarations.

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
  (parent / child / transitive / intrinsic-only / nested / `linux::abi`),
  unknown member vs missing import vs unknown namespace, duplicate and self
  imports, no injected names, no import in HIR/core IR/NIR, method
  candidates (imports, typed winners, ambiguity in either import order, nested
  exactness, lexical candidates, aliases), types (identity, `import type`,
  a module naming another module's integer domain and refinement qualified
  or type-imported, collisions, non-types, nested namespaces, ABI), cache
  non-leakage, dependency graph, cycles, protected intrinsics.
* `audit/imports/tools/fuzz.tcl`: random valid programs over `list::`,
  `str::`, `mutable_array::`, `abi::`, `abi::x86_64::` and `linux::abi::` with
  exactly the imports they need, method and type-import spellings checked
  against the qualified spelling, the four backends and a Tcl oracle; and
  thirteen rotating negative shapes (see the file's header).
* The other fuzzers and benchmark drivers that assemble programs from
  fragments declare their dependencies with
  `surface::modules::ImportHeader TEXT` (exactly the namespaces TEXT names).
