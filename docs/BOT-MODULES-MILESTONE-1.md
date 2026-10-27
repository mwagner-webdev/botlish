# Package-scoped modules: `.bot_modules` (milestone 1)

A Botlish application can now be assembled from its own source and from
packages installed in a `.bot_modules` directory: ordinary module trees,
each with its own dependency scope, resolved deterministically and only
downward, with no manifest, version, registry, network or package-manager
action. Two installed copies of the same package are two package instances,
whose types, errors, contexts and functions stay distinct through every
stage of the compiler and on every backend. The generated SDL3 binding is
the acceptance workload: installed as `.bot_modules/sdl3`, and nested inside
a reusable SDL3 airlock package, it compiles and runs natively against the
real libSDL3 with no compiler privilege of any kind.

This is a compiler milestone. The package manager (`botlish.json`, version
selection, locks, a registry) is future work and is not implemented; the
compiler is indifferent to it, and its resolution rules will not need to
change when it arrives (section G).

Contents:

* [A. Result](#a-result)
* [B. Resolution model](#b-resolution-model)
* [C. Semantic identity](#c-semantic-identity)
* [D. SDL3 workload](#d-sdl3-workload)
* [E. Repository changes](#e-repository-changes)
* [F. Verification](#f-verification)
* [G. Remaining limitations](#g-remaining-limitations)
* [H. Next milestone](#h-next-milestone)

## A. Result

What works:

* **Installed packages.** `ROOT/.bot_modules/NAME/` is the application's
  package `NAME`; `import NAME` is its file `NAME.bot`, `import NAME::a`
  its `NAME/a.bot`, exactly like an application module below a root.
* **Nested packages.** A package installs its own dependencies under its
  own `.bot_modules` (`ROOT/.bot_modules/NAME/.bot_modules/D/`), which only
  that package sees.
* **Downward-only resolution.** Every module file has an owning scope --
  the application, the standard library or one package instance -- and an
  import is resolved in that scope alone. A package never sees its
  consumer's modules or packages, a sibling package or an ancestor's; the
  application never sees a package its package installed.
* **No precedence.** A package claims its whole root namespace in its
  owner's scope: a file of the owner's own tree of that namespace is
  `MODULE-COLLISION`, naming both candidates. A package that installs a
  package of its own root name collides the same way. `std` stays the
  standard library's: a `.bot_modules/std` is `RESERVED-NAMESPACE`.
* **Package-instance identity.** An instance is its place in the logical
  dependency tree (`physics`, `physics/geometry`), and a module's canonical
  identity is that place and its namespace below the package's root
  (`physics/geometry::Point`). Identities are distinct for distinct
  instances by construction, so nominal types, errors, enums, traits,
  contexts, privacy, directness, registries, HIR, Core IR, NIR, HIR
  interchange, the front-end cache and the compiler service all keep two
  same-named instances apart without any of them learning what a package
  is.
* **No change for programs without packages.** The application's and its
  direct packages' modules keep their spelling as their identity, and a
  file's references are rewritten only where a spelling differs from its
  identity (a package that installs packages, or one installed by a
  package), so an ordinary program's HIR is byte-for-byte what it was
  (`bm-no-packages-same-hir`; `tests/imports.test`,
  `application-modules.test`, `std-namespace.test`, ... unchanged).

Backends covered: the reference interpreter (`interp`), the Tcl compiler
(`compile`, and the Core-IR-text `coretext` harness backend in the
isolation tests), and the native compiler (`cranelift`, `cranelift-generic`,
standalone executables). Every program of `tests/bot-modules.test` that
runs is run on all four or on the backends its property concerns.

The compiler now understands exactly this much about package ownership:
which scope owns each module file, which packages each scope has installed
(directory existence), and the identity of each instance. It knows nothing
of versions, manifests or how the tree was installed.

## B. Resolution model

### The tree

```
game/                                     the application root (the entry file's directory)
    main.bot                              entry program: no namespace
    game.bot                              application module  game
    util/math.bot                         application module  util::math
    .bot_modules/
        sdl3/                             package instance    sdl3
            sdl3.bot                      module              sdl3
            sdl3/video.bot                module              sdl3::video
            .bot_modules/
                helper/                   package instance    sdl3/helper
                    helper.bot            module              helper     (identity sdl3/helper)
                    helper/text.bot       module              helper::text (identity sdl3/helper::text)
```

### The mapping

For a file whose owning scope is S (with directory D: the application root,
or the package's directory), an `import N` with first segment H is:

| N | condition | file | owning scope of the module |
|---|---|---|---|
| `std` | -- | none: `UNKNOWN-NAMESPACE` | -- |
| `std::X` | S has an own file `D/std/X.bot` (application only) or a directory `D/.bot_modules/std` | `RESERVED-NAMESPACE` | -- |
| `std::X` | otherwise | `$libraryDir/X.bot` (or the target's `X.ARCH.bot`, or intrinsics) | the standard library |
| `H` or `H::r` | S is a package whose root is H, and `D/.bot_modules/H` is a directory | `MODULE-COLLISION` | -- |
| `H` or `H::r` | S is a package whose root is H | `D/H.bot`, `D/H/r.bot` | S |
| `H` or `H::r` | `D/.bot_modules/H` is a directory, S the application, and the application has `D/H.bot` or `D/H/r.bot` (not the entry file) | `MODULE-COLLISION` | -- |
| `H` or `H::r` | `D/.bot_modules/H` is a directory | `D/.bot_modules/H/H.bot`, `.../H/H/r.bot` | the instance S/H (H in the application) |
| `H` or `H::r` | S is the application | `D/H.bot`, `D/H/r.bot` | the application |
| `H` or `H::r` | S is a package | none: `UNKNOWN-NAMESPACE` | -- |

and for a standard-library module (scope `#std`) and for program text with
no application root (`#text`), only the `std::` rows apply (as before).
`surface/modules.tcl`'s `Locate` is the rule; `ResolveModule` raises its
problem, `NamespaceExistsFor` asks whether a namespace names anything (for
`MISSING-IMPORT` versus `UNKNOWN-NAMESPACE`), and `NoSuchNamespace` words
the diagnostic.

### Cases

* **Application:** `import game` is `game/game.bot`; `import util::math` is
  `game/util/math.bot` (unchanged).
* **Package:** `import sdl3::video` from `main.bot` is
  `game/.bot_modules/sdl3/sdl3/video.bot`, identity `sdl3::video`.
* **A package's own module:** `import sdl3::video` from `sdl3.bot` is the
  same file: the package's own tree is its root namespace.
* **Nested package:** `import helper` from a module of sdl3 is
  `game/.bot_modules/sdl3/.bot_modules/helper/helper.bot`, identity
  `sdl3/helper`. From `main.bot` it is `game/helper.bot` -- an application
  path that does not exist: `UNKNOWN-NAMESPACE`, never sdl3's helper.
* **Standard library:** `import std::list` from any of them is
  `stdlib/list.bot`; a package's own `std/list.bot` is no module of
  anything.
* **Rooted paths:** `import ::sdl3::video` is `import sdl3::video` in the
  same scope (a second one is `DUPLICATE-IMPORT`). The root marker is never
  part of an identity and never leaves a scope: `::game::f` in a package is
  still the package's (unknown) `game`.

### No search, no fallback

Each namespace has at most one candidate per scope, decided by its first
segment and by the existence of the scope's own `.bot_modules/H`. Nothing
reads a parent directory, the working directory, an environment variable or
a path list; nothing is looked up in another scope when a name is missing;
a file or a package installed elsewhere in the tree never changes an
import's outcome (`bm-no-sibling-or-ancestor`, `bm-no-upward-search`,
`bm-no-packages-same-hir`: a `.bot_modules` in an ancestor directory of the
root changes nothing). A missing name is `UNKNOWN-NAMESPACE`, whose message
says which scope looked where:

```
unknown namespace "game": package snoop (instance snoop, at APP/.bot_modules/snoop)
has no package "game" installed (no directory APP/.bot_modules/snoop/.bot_modules/game),
and its own modules are its root namespace's, snoop and snoop::...: a package's
modules see its own namespace, its own installed packages and the standard
library, never its consumer's modules or packages
```

A package's root namespace is its directory's name: the package's own
modules are `H.bot` and `H/...`. A file in the package directory outside
that tree (`PKG/other.bot`) is no module of anything, and the diagnostic of
an import that would want it says so. This keeps a package's namespace one
public tree and adds no package-private modules (no package-level
visibility, section G).

### What counts as installed

`D/.bot_modules/H` is a package exactly when it is a directory (a symbolic
link to one is followed); a file there, or a `.bot_modules` that is a file,
installs nothing (`bm-not-a-directory`). H is a namespace segment -- an
identifier -- so a malformed directory name (`my-pkg`, `.hidden`) can never
be named, and no namespace maps to a path outside its scope (`..`, `/` and
`.` cannot occur in a segment: `NamespaceFile` rejects them). A package
file inside the standard library's directory is no package module (as for
application files). A package directory installed inside itself through a
symbolic link would make the logical tree endless; the loader compares the
physical package directories (symbolic links resolved) of the modules on
its loading stack and reports the repeat as `CYCLE`
(`bm-symlink-cycle`). Two symbolic links to one shared store directory
(an installer's deduplication) are two instances, by their places
(`bm-symlinked-package`).

The entry file is in no namespace: an entry `widgets.bot` beside an
installed package `widgets` collides with nothing, and its `import
widgets` is the package's (`bm-entry-file-is-no-module`).

### Unchanged rules, extended to packages

Imports are exact and non-transitive (importing `sdl3` imports nothing of
`sdl3::video`; a package's dependency is never its consumer's). Self-import,
duplicate-import and cycle rules hold per module identity
(`bm-self-import-and-cycle`, `bm-nested-self-import`). A package's module
is never a standard-library module: it may not import or name an internal
namespace of the standard library (`INTERNAL-NAMESPACE`,
`bm-package-is-not-std`).

## C. Semantic identity

### The audit

Before changing anything, every place that took a canonical namespace
string to identify one module, and a qualified `NS::Name` to identify one
declaration, across a whole compilation:

| place | what is keyed by the namespace |
|---|---|
| the loader's state (`surface/modules.tcl`) | `loaded`, `loadedStructs`/`Types`/`Errors`/`Traits`/`Enums`/`Layouts`, `imports`, `moduleDecls`, `fileOf`, `open`, `staticDeferred`, `dependentRefs`, `typeKeys`, the cycle `stack`, `application`, `dfaRegistry` |
| sections and the HIR's `modules` table | a section's `namespace`, the body scope of each module; `hir::resolve::ResolveQualifiedRef` resolves `qualified {NS name}` by it |
| `hir::hygiene::qualifyModules` | a module binding's name becomes `NS::name`: Core IR names, the Tcl compiler's names, NIR function names, `hir::aot::BindingName` |
| `core::type`'s registry | source types and refinements `NS::Name` (C scalars `std::ffi::c::...`) |
| `hir::structs`, `hir::enums`, `hir::layouts` | `NS::Name`; enum values `{enum NS::Name CASE}` in Core IR and the native enum table |
| `hir::errordecls` | error identities `NS::Name`; `errorId` (Tcl), `faildeclared` (native) |
| `hir::traits`, `hir::contexts` | trait and context identities; conformance reads the witness's owner namespace |
| `hir::foreign` | an extern's key `NS::name`, its native `extern#NS::name` |
| `hir::privacy`, `hir::direct` | `moduleDecls` by namespace; a member's namespace split at its last `::` |
| `hir::imports` | a file's namespaces and type imports |
| `hir::declarations::capture` | every registry above (isolation and interchange) |
| `surface::cache::Dependencies` | candidate paths derived from the namespaces of `declarations imports` |
| `surface/dfa.tcl` | its registry and class keys `{NS NAME}` |
| the compiler service | a binding's `module NS`; references by binding identity |
| `CheckNativeMembers`, `IntrinsicMembers` | intrinsics by `NS::member` |
| HIR text (`hir/format.tcl`, `hir/read.tcl`) | declaration identities and module namespaces |
| native lowering | function names, the enum and error tables, foreign `name=` |

Every one of them is correct as long as the string is unique to one module
in the compilation. With nested packages a spelling no longer is (two
installed `geometry` packages both spell `geometry`), so the milestone does
not change these places: it makes the string they key by the module's
*identity*, unique by construction, before any of them sees it.

### The representation

A package instance is identified by its place in the logical dependency
tree: the names of the packages from the application down to it, joined by
`/`:

* the application's package `sdl3` is the instance `sdl3`;
* sdl3's own package `helper` is `sdl3/helper`;
* physics's `geometry` is `physics/geometry`, rendering's
  `rendering/geometry`.

The loader records each instance (`state packages`: its name, its parent
scope and its directory) the first time a scope names it, and each module
its owning scope (`scopeOf`) and its namespace as its own files spell it
(`spellingOf`). A module's canonical identity (`Identity`) is its
namespace for the application's and the standard library's modules, and
for a package instance's module the instance followed by its namespace
below the root segment:

| module | spelling (in its package) | identity |
|---|---|---|
| application module | `util::math` | `util::math` |
| standard library | `std::list` | `std::list` |
| the application's package sdl3 | `sdl3::video` | `sdl3::video` |
| physics's geometry | `geometry` | `physics/geometry` |
| physics's geometry | `geometry::shapes` | `physics/geometry::shapes` |
| a type of physics's geometry | `geometry::Point` | `physics/geometry::Point` |

The identity is deterministic: it depends on no load order, counter,
absolute path, version, digest or publishing history, so equivalent builds
-- the same tree anywhere on disk -- give every module the same identity.
It is a path of the program's module tree that no source can spell (`/` is
an operator; `physics/geometry::make(1)` divides, `bm-identity-
unspellable`), so no reference can address an instance except through the
scope that installed it. The application's direct packages keep their
spelling, which is unambiguous because a package claims its root namespace
in the application's scope (section B): an application module of that
namespace can never be loaded beside it.

This is not a mangling applied at the end: the identity is what the loader
names a module by from the moment it resolves it, and every later stage
receives only identities -- exactly the role the namespace string already
had. The instance separator appears in two validators of identities, which
now accept it (`core/ir.tcl`'s enum literal check, `core/type.tcl`'s
`register`).

### How identities reach everything

* **The loader** resolves a spelling in its file's scope (`Locate`) and
  loads the module under its identity (`LoadNamespace`, every state table
  keyed by it). `CheckImports` builds each file's map from the namespaces
  it may name (its own and each import) to their identities (`names`), and
  the import environment it hands on lists identities. `CheckRef` checks
  each qualified reference as written (its diagnostics speak of what the
  file wrote) and looks members up by identity (`IdentityOf`).
* **The rewrite.** Wherever a file's map is not the identity, the loader
  rewrites every qualified spelling of the file to its identity
  (`RewriteQualified`) before declarations are split and lowered: values,
  constructions, case qualifiers (`NS::Enum::Case`), types wherever written
  (parameters, results, context parameters, the variadic parameter, the
  resume clause, struct, layout and error payload fields, refinement
  carriers, trait requirements, extern C types, imprints), error names in
  `fail`, `on`, `errors` and function types, and declared recognizers'
  classes and callees. `QualifiedRefs` (what the loader checks) and
  `RewriteQualified` (what it rewrites) are one traversal (`Walk`), and
  `surface::ast::MapChildren` is `Children`'s traversal; two tests pin both
  over the whole corpus (`bm-ast-map-children-parity`,
  `bm-rewrite-covers-every-reference`). Writing that traversal found four
  places where a type is written that the loader never checked -- context
  parameters, the variadic parameter, the resume clause and error payload
  fields -- so an unimported namespace there was reported only as an
  unknown type by HIR, and accepted when another file had loaded the
  module. They are now authorized like every reference
  (`bm-package-cannot-name-consumer`): without it a package could have
  named its consumer's type through them.
* **Declarations** are split under the identity (`SplitTypeDecls NAME`):
  `physics/geometry::Point` is the struct, `physics/geometry::Bad` the
  error, `physics/geometry::Side` the enum, in the registries, which hold
  both instances side by side (`bm-instances-identities`).
* **Nominal types and errors** follow: passing one instance's Point where
  the other's is declared is a TYPE error naming both identities
  (`bm-instances-nominal-types`), an enum's cases are never the other's
  (`bm-instances-nominal-enums`), a handler of one Bad never handles the
  other's, and an unhandled one is reported by its identity
  (`bm-instances-errors`). Opaque structs, `private` declarations, context
  structs, traits and their witnesses, direct-module designations and
  method candidates are all the instance's (`bm-instances-methods`,
  `bm-nested-privacy-and-opaque`, `bm-nested-direct-module`,
  `bm-application-and-nested-same-name`).
* **HIR, Core IR and NIR** carry the identities like any qualified name:
  `physics/geometry::make` and `rendering/geometry::make` are two NIR
  functions (`bm-instances-native-functions`); native symbols are numbered
  (`botlish_fn_N`), and a foreign call keeps its C symbol (`SDL_Init`)
  under an instance-qualified Botlish name
  (`sdlkit/sdl3::init::SDL_Init`). HIR text round-trips them.
* **Isolation and interchange.** No registry was added; the instances are
  entries of the existing ones, so `hir::activate` installs a HIR's own and
  interleaved compilations stay apart (`bm-isolation`), and a `.hirx` runs
  in another process with the sources gone (`bm-interchange`).
* **The cache and the service** depend on the scope too (section D of the
  seam, below).

### The source seam, the cache and the service

Which file a namespace names now depends on whether a package directory
exists. That is a third question the front end asks about its sources, and
it goes through the seam like the other two: `surface::source::directory
PATH` (a provider's `directory` method; the disk answers `file
isdirectory`; an overlay asks its base, since editor buffers are documents,
never directories). The snapshot records it as `{directory 1 exists E from
F}`. The loader asks only through `Probe`, which records every package
directory and package-tree file it probed; the front-end cache keeps those
probes as dependencies (`{PATH EXISTS "" directory}` for a directory), so
installing, removing or editing a package the program read misses, and
editing an unread branch does not (`bm-cache-invalidation`). A
compiler-service revision's sources include the directory observations,
and `service::stale` compares them again (`bm-service-sources`,
`bm-service-directory-stale`). Navigation goes to the physical declaration
of the instance a reference resolved to, by identity
(`bm-service-navigation`), and analysis past a syntax error in a nested
package reports it in that file (`bm-service-syntax-recovery`).

## D. SDL3 workload

The generated SDL3 binding (`generated/c/sdl3/TARGET/sdl3/`, the
namespaces `sdl3::video`, `sdl3::events`, `sdl3::init`, ...; each module
imports `std::ffi::c` and `sdl3::ctypes`) is a package as it stands: its
directory is already a package root.

### The binding as the application's package

```
APP/
    demo.bot                         examples/ffi/bindgen/sdl3/demo.bot, unchanged
    .bot_modules/
        sdl3/
            sdl3/init.bot  video.bot  events.bot  render.bot  ...
```

`tools/c-bindgen.tcl stage sdl3 -target linux-x86_64 -app DIR -into APP
-package 1` lays it out: the application's files at APP, the binding at
`APP/.bot_modules/sdl3/sdl3/` (`::cbind::generate::stage`'s new PACKAGE
argument). The demo compiles from it under `-warnings error` for
linux-x86_64, its seven binding modules read from the package's tree
(`bm-sdl3-stage-package`), and a module added to the package that imports
the application's `game` is `UNKNOWN-NAMESPACE` (`bm-sdl3-package-
boundary`).

### A reusable SDL3 package with its own binding

```
APP/
    main.bot                         import sdlkit
    .bot_modules/
        sdlkit/
            sdlkit.bot               the airlock: opaque context struct Kit
            .bot_modules/
                sdl3/sdl3/*.bot      the generated binding, sdlkit's own
```

`sdlkit.bot` is an ordinary module: it imports `sdl3::init`, `sdl3::video`,
`sdl3::events`, `sdl3::render`, `sdl3::timer`, `sdl3::version` and the
standard library, and keeps every SDL object behind its own `context
struct Kit`. The application is three lines -- `with context
sdlkit::open()`, `sdlkit::frame()`, `sdlkit::close()` -- and never sees a
pointer. The direct-module analysis reads it exactly as Icy Tower's
`sdl.bot`: the binding modules (`sdlkit/sdl3::video`, ...) ordinary,
`sdlkit` contextualized (every retaining C call mediated by `sdlkit::Kit`),
the entry program ordinary; the foreign table calls `SDL_CreateWindow`,
`SDL_PumpEvents`, ... by their C symbols under the Botlish names
`sdlkit/sdl3::video::SDL_CreateWindow`, ... (`bm-sdl3-nested-airlock`). No
`direct module`, intrinsic or standard-library privilege is involved.

### Running it

Package loading and native compilation need nothing but the binding's
`.bot` files. Running needs the package-owned libSDL3.so
(`tclsh9.0 tests/cffi/sdl3.tcl`, which fetches the pinned SDL 3.4.18 and
builds it headless with CMake and Ninja) and, for the demo's static inline
thunks, the binding's shim (`tools/c-bindgen.tcl build`). With them,
`bm-sdl3-run` runs both programs headless (`SDL_VIDEO_DRIVER=dummy`) on
`cranelift` and `cranelift-generic`: the demo's ten checks all true, and
sdlkit's frame (six checks, the version check) all true. On this
container the library was built and the test ran (section F); without the
library the test is skipped, and the compile-only tests still run.

### Icy Tower's staging

Icy Tower's builds now install the binding as the game's package instead
of copying it into the game's root: `build.sh` and `build-windows.sh` pass
`-package 1` to `tools/c-bindgen.tcl stage`, and the workload test stages
the same way. Since the application's direct package keeps its spelling
as its identity, nothing downstream changes: the game's NIR is
byte-identical in both arrangements (155,350 bytes), and an executable
built by the new `build.sh` is byte-identical to one built by the
unmodified checkout in the same environment. The game's sources, its
airlock and its tests are unchanged (the staged test now reads the
package arrangement). The committed `audit/icy-tower/artifacts/icy-tower`
was not rebuilt: this container's toolchain (rustc 1.97) produces a
different executable from the committed one with or without this change,
so a rebuild here would record the toolchain, not the milestone.

What remains for a production SDL3 package is section H.

## E. Repository changes

Source:

* `surface/modules.tcl` -- owning scopes, `Locate`/`ResolveModule`,
  `Identity`, `Instance`, `Probe`, the package-aware `NoSuchNamespace`;
  `LoadNamespace` under identities with the physical-directory cycle guard;
  `CheckImports`, `CheckRef`, `EnumQualifier`, `OtherTypeQualifier` and
  `CheckInternal` checking spellings and looking up identities; one
  traversal `Walk` for `QualifiedRefs` and `RewriteQualified` (now
  covering context, variadic, resume and error payload types) and
  `DfaRewrite`; `CollectAndLoad` rewriting where needed; probes recorded
  for the cache.
* `surface/ast.tcl` -- `MapChildren`, `Children`'s traversal with a mapping.
* `surface/source.tcl` -- the `directory` question, its snapshot
  observation, the disk provider's answer, the overlay's delegation.
* `surface/cache.tcl` -- the loader's probes as dependencies, directories
  checked on lookup, nested identities skipped in the derived paths.
* `service/service.tcl` -- `stale` compares directory observations.
* `core/ir.tcl`, `core/type.tcl` -- identity validators accept the instance
  separator.
* `tools/c-bindgen.tcl`, `tools/c-bindgen/generate.tcl` -- `stage
  -package 1`.
* `examples/games/icy-tower/build.sh`, `build-windows.sh` -- stage the
  binding as the game's package.

Tests, audits and documentation:

* `tests/bot-modules.test` (53 tests); `tests/workload-icy-tower.test`'s
  staging; census rows (`audit/golden/migration/census/bot-modules.tsv`,
  `tcl-names.txt`, the regenerated `tests/golden/manifest.tsv`).
* `audit/bot-modules/tools/mutate.tcl` and `mutants.txt` (19 mutants);
  mutants of `CheckRef`/`CheckImports` code in the module-privacy,
  error-payloads, hashable and type-predicates harnesses retargeted to the
  rewritten lines (same rules).
* This report, `docs/INDEX.md`, `docs/IMPORTS.md` ("Installed packages"),
  `docs/STD-NAMESPACE.md`, `AGENTS.md` ("Package-scoped modules"),
  Compilerpedia (`rule.package-modules`; `error.module-collision`,
  `error.reserved-namespace`, `error.unknown-namespace`,
  `rule.application-modules`, `concept.modules`).

Intentional compatibility changes:

* A `.bot_modules/NAME` directory beside the entry program now installs a
  package `NAME`: an application that had both such a directory and a
  module of namespace `NAME` gets `MODULE-COLLISION` where it imports it.
  (`.bot_modules` was never a namespace segment, so no import could name
  the directory before.)
* An unimported namespace written in a context parameter's type, the
  variadic parameter's type, the resume clause or an error payload field is
  now `MISSING-IMPORT`/`UNKNOWN-NAMESPACE` at the loader, as everywhere
  else, rather than an unknown type in HIR (or accepted when another file
  had loaded the module). The corpus, the standard library and every test
  compile as before.
* `MODULE-COLLISION`'s and `RESERVED-NAMESPACE`'s meanings widened to
  packages; their existing messages are unchanged.

## F. Verification

Host: Linux x86-64 container, 4 cores, Tcl 9.0.1 (the `.deb`s AGENTS.md
names), rustc 1.97, clang 18.1.3; the native backend built with `cargo
build --release`. Every command ran with `LANG=C.utf8 LC_ALL=C.utf8` and a
private `-tmpdir`. "Executed" means run here, with the output shown.

VERIFICATION-PLACEHOLDER

## G. Remaining limitations

### Bugs or unfinished requirements

None known in the resolution model or identity. What was not done:

* **Windows and macOS were not executed here.** The milestone adds no
  platform-specific code (`file isdirectory`, `file normalize`, the seam),
  and `tests/bot-modules.test` joins both platforms' acceptance tiers
  automatically (`tests/platform/tier.tcl` takes every test file), with its
  symbolic-link tests constrained to POSIX hosts and the SDL3 run to
  linux-x86_64. Section F records which CI runs were requested and their
  results; nothing is claimed for a platform without one.
* **The single executable was not rebuilt.** `single/build.sh` builds a
  static Tcl from source; the bundled compiler was tested the way
  `tests/std-namespace.test` tests it, an archive packed by
  `single/package.tcl` onto this host's dynamic tclsh
  (`bm-bundled-compiler`). The packing is unchanged: the compiler reads no
  new file at run time.
* **The committed Icy Tower executable** was not rebuilt (section D: the
  difference is this container's toolchain, not this milestone).

### Pre-existing compiler limitations that packages expose

* **Messages and printed values show identities.** A diagnostic about a
  nested instance's declaration says `physics/geometry::Point`, and a
  printed enum value `physics/geometry::Side::Right`. The identity is
  unambiguous, but it is no spelling a reader can write (the spelling
  depends on the scope that reads it). Presenting "geometry::Point of the
  package physics/geometry" is a presentation change for every producer;
  the application's direct packages, the common case, read as written.
* **The loader did not authorize every place a type is written.** Context
  parameters, the variadic parameter, the resume clause and error payload
  fields were never checked for an import (an unknown type in HIR at best,
  an accepted reference when another file had loaded the module at
  worst). Packages made it a visibility hole -- a package could have named
  its consumer's type there -- so it is fixed (section E); it is recorded
  here because it predates packages.
* **A module file opened alone in the language server is its own
  program.** Its directory becomes the application root, so a package's
  module opened by itself (or an application module in a subdirectory, as
  before) reports its own imports unknown until the program that loads it
  is open. The service's ownership rule (a document an open program reads
  is that program's module) is unchanged and resolves it.
* **Editor buffers never create directories.** An unsaved new package in
  an editor is installed only once its directory exists on disk (the
  overlay asks its base about directories).
* **C symbols are global.** Two instances of a package that binds a C
  library are two Botlish modules over one C library: their `extern c fn`s
  are distinct Botlish declarations calling the same C symbols, sharing
  the C library's global state, and an `exported c fn` of the same C name
  in two instances would collide at link time. That is C's model, not a
  package rule.
* **No sharing of instances.** Two packages that each install `geometry`
  get two instances whose types are distinct: physics's Point is never
  rendering's, even when the two installations are identical. That is the
  milestone's model of independent ownership; a package manager that wants
  one shared instance must install one package that both use through its
  own API (a *peer* arrangement), which the language does not express yet
  (below).

### Intentional omissions reserved for the package manager

`botlish.json`, `botlish add`/install/update/remove, version comparison and
selection, lock generation and validation, registry access, downloads and
caching, revocation and outdated-version warnings, publishing, dependency
solving, automatic restore, native dependency installation (libSDL3) and
the deduplication of identical installations. The compiler reads none of
them; an installed tree compiles with no `botlish.json` anywhere.

### Potential future language changes

* **Package-level visibility.** Module-local `private` is the only
  visibility: every module of a package's root namespace is importable by
  its consumer (`sdl3::ctypes` included). A package can already keep an
  implementation out of reach by installing it as a package of its own --
  sdlkit's binding, `sdlkit/sdl3::...`, is invisible to the application --
  but it cannot hide a module of its own namespace. A package-internal
  marker would close that; it is a language decision this milestone does
  not take.
* **Peer or shared dependencies**, for types two packages must agree on
  (above).
* **Target-selected package modules.** The standard library selects an
  architecture-specific module (`NAME.ARCH.bot`); a package cannot. The
  SDL3 binding is generated per target (section H).
* **A presentation of instance identities** in diagnostics, hover text and
  printed values (above).


## H. Next milestone

Extracting Icy Tower's SDL3 binding and airlock into a separately
maintained, reusable `sdl3` package needs, beyond what this milestone
provides:

1. **One package for every target.** The binding is generated per target
   (linux-x86_64 and linux-aarch64 committed; windows-x86_64 generated on
   the Windows host; macOS needs the SDK), and enumeration constants differ
   by target. Either the package carries every target's generated modules
   and the loader selects by target -- the standard library's
   `NAME.ARCH.bot` rule extended to packages, which is a loader change -- or
   the package manager installs the target's binding. This is the first
   decision of the next milestone.
2. **The thunk shim.** The binding's static inline thunks are C, compiled
   into a shim library (`tools/c-bindgen.tcl build`); the compiler never
   compiles C. A package that needs one needs build integration (a
   prebuilt archive per target, or a build step of the package manager),
   or a wrapper that avoids thunks, as sdlkit does.
3. **A general airlock API.** Icy Tower's `sdl.bot` is the game's own
   (its session, its text buffer, its drawing operations). A reusable
   wrapper needs a general surface -- windows, renderers, textures, events,
   timing -- over the same pattern sdlkit demonstrates: an opaque context
   owning SDL's objects as affine pointers, every retaining call mediated
   by it, the application ordinary. The CONTEXT-RESOURCE-ESCAPE and
   privacy checks already hold such a package to that boundary.
4. **The native library.** libSDL3 stays the application's (or a future
   package manager's) to provide: `-L`, `LD_LIBRARY_PATH`, SDL3.dll beside
   the executable. Native dependency management is out of scope.
5. **Icy Tower as a consumer.** The game would then import the package's
   API instead of staging the binding, keep its game-specific drawing in
   its own modules, and its tests would compare against today's executable
   (the SDL call trace, `audit/icy-tower/context-refactor/tools/
   trace-compare.sh`).

None of this needs a change to resolution or identity: the package
installs, imports and nests exactly as this milestone defines.

