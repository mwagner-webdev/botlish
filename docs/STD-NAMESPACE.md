# The standard library: one compiler-owned root, `std`

Every public namespace of the standard library is under the root namespace
`std`: `std::list`, `std::str`, `std::io`, `std::abi::x86_64`,
`std::linux::io`, `std::ffi::c`, `std::test`, `std::compiler`, ... A leading
`::` roots any namespace path (`import ::std::list`, `::std::list::at(xs,
0)`). An application's own `list.bot` and the standard `std::list` are two
namespaces that coexist, and neither is ever found by looking for the other.

This milestone changes names and resolution only. No numeric, binary,
collection or FFI abstraction was redesigned: every function, type, error,
context and intrinsic of the standard library still exists with the same
behavior, under one new canonical name.

Before it, the standard namespaces were flat (`list`, `str`, `abi::x86_64`,
`linux::io`), an application module was `ROOT/NAME.bot` unless NAME was a
standard namespace, and an application file that had a standard namespace's
name was `MODULE-COLLISION`. So the standard library owned every short name
it used, and an application could never have a `list` of its own.

## 1. The census

`audit/stdlib-census/` is the machine-readable inventory of the public
standard library, from before and after the migration:

| file | what it holds |
|---|---|
| `before.tsv` | every standard-library entity of the tree before the milestone (603 rows) |
| `after.tsv` | the same entities after it (603 rows) |
| `renames.tsv` | old name -> new name for every program-visible entity (509 rows) |
| `tools/census.tcl` | writes a census from a checkout (`-root DIR -out FILE`) |
| `tools/renames.py` | joins the two censuses; exits 1 if an entity has no partner |
| `tools/migrate.py` | the mechanical part of the corpus migration (section 7) |

Columns:

* **name** and **kind**: namespace, function, binding, type, refined type,
  struct, opaque struct, context struct, enum, enum case, error, trait,
  context trait, intrinsic, intrinsic type, C scalar type, builtin error,
  builtin enum.
* **namespace**: the entity's own namespace.
* **role**: `api` is the public standard library; `primitive` is a root
  language primitive (`+`, `==`, `hash`, `argv`) and is in no namespace;
  `internal` is a `#` native (`mutable_vector#consume`) or a core-IR-only
  accessor that no source can spell; `builtin` is a runtime error or enum
  that every program sees; `demo` is the `std::mathish` demonstration module;
  `std-internal` is an internal namespace (`std::table_hash`) or its member,
  which only standard-library modules may name (HASHABLE-AND-KEYED-HASH.md).
* **origin**: a module file, an intrinsic, or both.
* **location**: the defining file and line.
* **platform**, **arch**, **direct**: as the target table and the module's
  designation say.

The rows are sorted, so two runs over one tree are byte-identical. Regenerate
`after.tsv` whenever the public surface changes:

```sh
tclsh9.0 audit/stdlib-census/tools/census.tcl -out audit/stdlib-census/after.tsv
```

The migration is a bijection, which `renames.py` checks:

* 509 program-visible entities (38 namespaces and 471 members, roles `api`,
  `demo` and `std-internal`), each now named under `std::`;
* the 24 root primitives, 57 internal natives and 13 runtime builtins keep
  their names.

## 2. One root, two origins

A namespace path is resolved from the namespace root. Its first segment says
whose it is, its **origin**, and nothing else does:

| path | origin | file |
|---|---|---|
| `std::NAME` | the standard library | `$::core::libraryDir/NAME.bot`, the target's `NAME.ARCH.bot`, or compiler intrinsics only |
| any other `NAME`, imported by an application file | the application | `ROOT/NAME.bot` (`ROOT/a/b.bot` for `a::b`) |
| `std` itself | none | the root of the standard library is no namespace (`UNKNOWN-NAMESPACE`) |
| `NAME`, `NAME::a`, NAME a package installed in the importing file's scope | the package (BOT-MODULES-MILESTONE-1.md) | `SCOPE/.bot_modules/NAME/NAME.bot`, `.../NAME/a.bot` |

The origin is never part of an identity: `std::list` is the canonical name,
and the file it came from is where it lives. There is no search and no
fallback between the origins:

* a missing application `list` is `UNKNOWN-NAMESPACE`, never `std::list`;
* a missing `std::nosuch` names the standard library's path;
* adding a file anywhere never changes what an existing import names.

Two kinds of file import standard namespaces only:

* **A standard-library module.** An application never changes what
  `stdlib/test.bot` imports.
* **Program text compiled with no application root** (`surface::compile
  TEXT`). It has no application to import from.

`surface/modules.tcl`'s `ResolveModule` is the rule (`Locate` since
BOT-MODULES-MILESTONE-1.md, which added installed packages); its helpers
are:

* `StandardNamespace` and `ReservedNamespace`, which classify a path by its
  first segment;
* `ModulePath`, the standard file of a `std::` path;
* `OwnFile`, the file of a path in a scope's own module tree (formerly
  `RootFile` and `ApplicationFile`, the application file of a path);
* `NoSuchNamespace`, the diagnostic.

### Where the standard library is

`stdlib/` is the directory of the namespace `std`. `core/core.tcl` sets
`$::core::libraryDir` to the `stdlib` directory beside the compiler's own
`core/`, so it is relative to the compiler distribution, wherever that is:

* **A checkout** reads `CHECKOUT/stdlib`.
* **The single executable** reads the `stdlib/` packed beside its `core/`,
  `//zipfs:/app/botlish/stdlib` (`single/package.tcl` packs it; SINGLE-EXECUTABLE.md).
  It never reads the checkout it was built from, or the working directory.
* **An installed copy** of the tree (main.tcl, `core/`, `stdlib/`, ...)
  reads its own `stdlib/`.
* **Windows and macOS** use the same rule. It is a `file join` of the
  compiler's own directory and needs no platform-specific path, environment
  variable or installation prefix.

Nothing else chooses the location:

* not the shell's working directory;
* not an environment variable;
* not the application;
* not a search path.

`$::core::libraryDir` is the one override, and only tests use it
(`withPrivateLibrary` points it at a private copy, and a module a test writes
there is `std::NAME`).

A compiled program does not need the library's `.bot` files to run. The
analyzed HIR holds every module it was built from, so an interchange file
(`.hirx`), NIR and a native executable run with both the source and `stdlib/`
gone (`std-executable-needs-no-source`).

## 3. Rooted paths

A namespace path may begin with `::`, which names the root explicitly:

```
import ::std::list
import type ::std::abi::U8Value

fn widen(x: ::std::abi::U8Value) -> ::std::abi::U8Value errors ::std::list::NotFound:
    ...

r = ::std::list::at(xs, 0):
    on ::std::list::NotFound:
        0
with context ::std::test::suite()
::std::abi::U8 {value: 4}
```

### Where a rooted path is accepted

* An import or a type import: `path = [ "::" ] IDENT { "::" IDENT }` (IMPORTS.md).
* A qualified value or callee, with imprints: `::std::list::at`,
  `::std::ffi::c::null[::std::ffi::c::Void]()`.
* A construction: `::std::abi::U8 {value: 4}`.
* An enum case: `::std::compiler::DiagnosticCode::UnknownSymbol`.
* A type, including a context parameter's: `context io: ::std::io::IO`.
* An error name, in `fail`, `on` and `errors`.

### How it is resolved

**Every path is resolved from the root.** A rooted path and the same path
unrooted name the same namespace, so `import std::list` with `import
::std::list` is `DUPLICATE-IMPORT`. A rooted path to an application module
(`::game::score`) is the application's `game`.

**The root marker is never part of an identity.** The parser records every
path canonically (`std::list`). It adds a `rooted` flag on imports,
qualified values and constructions, the three places where the loader
decides with it, and nothing else reads the flag. So `::std::list::at` and
`std::list::at` are one callee, one HIR, one core IR and one cache entry's
worth of program
(`std-rooted-callable`, `std-rooted-types-and-constructions`,
`std-rooted-contexts`).

**A rooted qualifier is a namespace path.** It is never a type of the file:
`::Color::Red` is not the file's enum Color's case.

**A rooted name needs a namespace.** `::f`, `x: ::T` and `fail ::E` are
`ROOTED-NAME`, at the root marker. A local binding has no root path, and a
leading `::` would only be a second spelling of it.

**`import` stays contextual.** `import::f` glued to the word is still a
qualified name. `import ::std::list`, with the `::` set apart, is an import.

## 4. Local modules and the standard library

**They coexist.** An application module `list.bot` is the namespace `list`.
A program may import it with `std::list` and use both:

```
project/
    main.bot          import list
                      import ::std::list
                      [list::shuffle(xs), std::list::length(xs)]
    list.bot          fn shuffle(xs): ...
```

The two are distinct in every respect:

* module identity and members;
* types and errors: `list::NotFound` and `std::list::NotFound` are two error
  identities on every backend;
* opaque-struct ownership.

A method call `xs.length()` sees the candidates of both imports and is
decided by the ordinary rule: one valid candidate, else ambiguity, never a
precedence (METHOD-SUGAR.md).

**`std` is reserved.** The application file `ROOT/std/NAME.bot` would be the
namespace `std::NAME` by its path, so it is never a module:

* An application file that imports `std::NAME` while that file exists gets
  `RESERVED-NAMESPACE`, which names the file. The compiler never silently
  chooses either file.
* `ROOT/std/mine.bot` does not create a `std::mine`.
* An application `std/` directory that no import names collides with
  nothing.

**`MODULE-COLLISION` remains** for a namespace outside `std` that has
compiler intrinsics, which only a test process registers (`ffi_fixture`),
and for a namespace that an installed package claims while the importing
scope has a file of its own of that namespace (BOT-MODULES-MILESTONE-1.md).
An installed package can never be named std: a `.bot_modules/std` directory
makes an import of a standard namespace from that scope
`RESERVED-NAMESPACE`.

**The diagnostics say what to do.** A missing application module names the
file it would be. When the standard library has a namespace of that name,
the diagnostic adds that `import std::NAME` is the standard one, as a hint.
It never falls back to it. A flat reference after `import std::list`
(`list::at`) is `UNKNOWN-NAMESPACE` with the same hint.

## 5. Canonical identity through the compiler

Every qualified intrinsic is registered once, under its canonical name
(`std::list::at`) in `core::native`'s registry. There is:

* no alias table (`core::native::aliasPairs` is empty);
* no prelude;
* no implicit import;
* no second registration.

Internal `#` natives belong to no namespace and kept their names.

Everything downstream holds the canonical string. That covers HIR, core IR,
NIR, the Rust runtime's messages and the error identities
(`std::list::NotFound`; ERROR-PAYLOADS.md, "Module-qualified error
identity"). It also covers the types, contexts, context traits, the direct
designations (`std::linux`, `std::binary::native`) and the HIR interchange
fingerprint (`core`, `hir`, `surface`, `stdlib`). The front-end cache key
holds the application root, and each import's dependencies, and Compilerpedia
documents the same names. `stdlib.std::list::at` is a note;
`stdlib.module.std::list` is a module topic, generated from `stdlib/`
recursively.

### Decisions now read from registration, not from spelling

The migration replaced three decisions that read a namespace's spelling with
the metadata the registry already had:

* **A mutable collection's kind.** `hir::mutvec::CollectionOf` reads the
  native's parameter and result types. It replaced
  `string match mutable_array*`, which the prefix `std::` would have broken
  silently.
* **The platform of a namespace.** `core::cabi::platformOf` matches whole
  path roots from the target table's `platforms` (`std::linux`), never a
  first segment.
* **The owner of a builtin trait witness.** `hir::traits::WitnessOwner`
  names `std::str` and `std::char`.

## 6. Distribution and portability

Building the single executable is unchanged (`single/build.sh`), except that
`single/package.tcl` packs `stdlib/`. `single/smoke-test.sh` adds a program
with a local `list.bot` beside `::std::list`, and a missing `std::nosuch`
whose diagnostic must name the archive's own `stdlib/`.
`std-bundled-standard-library` and `std-bundled-native` check the same thing
with an archive built from a dynamic `tclsh9.0` in the test process.

The platform namespaces keep their platforms under their new names
(core/cabi.tcl's `platforms`: whole-path roots, never a first segment):

* Linux: `std::linux`, `std::linux::io`, `std::linux::path`,
  `std::linux::sys` and the transports `std::linux::abi::x86_64` and
  `std::linux::abi::aarch64`;
* macOS: `std::darwin`, `std::darwin::io` and `std::darwin::path`
  (MACOS-AARCH64-MILESTONE-8.md);
* Windows: `std::windows` and `std::windows::io`
  (WINDOWS-X86-64-MILESTONE-2.md).

A target of another operating system still gets `UNSUPPORTED-PLATFORM`. A
module a program or a test writes that is merely named like a system (an
application `windows.bot`, a private library's `std::win32`) is no
platform's.

The internal namespace of the keyed table hash is `std::table_hash`
(HASHABLE-AND-KEYED-HASH.md): only standard-library modules, the files whose
namespace is under `std`, may import it or name its member
(`INTERNAL-NAMESPACE` for any other file).

Nothing in this milestone adds a toolchain requirement. It needs no MinGW and
changes no C binding's ABI facts. The generated bindings spell `std::ffi::c`.

## 7. Migration and compatibility

**This is a breaking change for every program that imports a standard
namespace.** `import list` now names an application module `list.bot`, and
`list::at` names that module's member. Neither is ever `std::list`. No
compatibility alias exists, by design: a permanent alias would be a second
identity per symbol.

To migrate a program, rewrite each standard namespace's spelling:

* `import NS` becomes `import std::NS`;
* `NS::member` becomes `std::NS::member`.

A program that does nothing else is the same program. The table of every
rename is `audit/stdlib-census/renames.tsv`.

The repository was migrated by `audit/stdlib-census/tools/migrate.py`. It
rewrites these spellings only where the first segment is a standard
namespace's and nothing before it could make it part of a longer name:

* imports, qualified names and registered native names;
* quoted namespace names in messages;
* `lib/` paths and Compilerpedia's module topic ids.

With `--segments NAMES`, it rewrites only a test's own library modules.

It cannot see a namespace spelled as a bare word in Tcl code, a name
assembled from parts, or a test whose subject was the flat layout. Those
were migrated by hand, in the same change. Tests whose premise the milestone
reversed were rewritten to assert the new rule with the same strength. For
example, `app-cannot-shadow-standard` now proves that a local `list.bot`
coexists with `std::list` and that `std/list.bot` is `RESERVED-NAMESPACE`.

Earlier design documents and milestone reports were migrated to the
canonical spellings. Where one describes the flat layout as the current
rule, this document supersedes it.

## 8. Toward `.bot_modules`

Packages are not part of this milestone. The resolution rule leaves them
exactly one place to go. A path's first segment decides its origin, so a
package is a third origin chosen the same way, by first segment:

* A namespace `NAME` that the application's manifest declares as a dependency
  is `ROOT/.bot_modules/NAME/...`. The declaration decides it, never a
  search.
* It would be one more case of `ResolveModule` and one more hint in
  `NoSuchNamespace`.
* The cache would record it as a dependency, as it records application
  modules now.

What must stay true when one is added:

* no fallback from one origin to another;
* no precedence between a package and an application module of one name
  (that is an error naming both);
* `std` stays reserved to the compiler;
* a package's own imports see its own dependencies and `std`, never the
  application's modules.

## 9. Tests

`tests/std-namespace.test` holds the milestone's regressions:

* a local module;
* `::std::list`, and both together (identities, errors, method candidates);
* rooted callables, types, constructions, enum cases, contexts and imprints;
* intrinsic-only namespaces (`std::str`, `std::char`) and the registry's
  canonical names;
* rejection of shadowing, and the reserved root;
* a missing local with no fallback;
* working-directory independence;
* the library location, and bundled discovery from an archive;
* an executable that needs no source;
* representative APIs of every area on every backend;
* `ROOT/std/NAME.bot` and invalid rooted names.

`tests/application-modules.test`, `tests/imports.test`,
`tests/surface-modules.test` and `tests/stdlib-namespaces.test` hold the
rules they always held, now spelled canonically.

`audit/imports/tools/fuzz.tcl` generates rooted spellings and flat-name
negatives.

If you change the namespace model, run what AGENTS.md lists under "The
standard library: the namespace std".
