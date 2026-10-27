# NATIVE-LINK-PLAN-MILESTONE-1.md

## Explicit static C libraries, Apple frameworks and source-relative native dependencies

A program can now say, in source, that a C library must be linked
statically, which archive supplies it (a path from the application's own
root), and which Apple frameworks it needs:

```botlish
extern c library "m"                                         # the linker's choice, as before
extern c library "SDL3" static                               # libSDL3.a, never libSDL3.dylib/.so
extern c library "SDL3" static at "native/macos/libSDL3.a"   # exactly that file
extern c framework "Cocoa"                                   # -framework Cocoa (macOS)
```

The front end validates the declarations, merges each library's into its
strictest requirement (or reports LINK-CONFLICT), records an archive's path
as written beside the application root it resolves from, refuses a
framework for a target without frameworks, and keeps the plan through
imports, HIR interchange and the front-end cache. The native driver
resolves the plan when it links: it finds each static archive, checks it is
a real archive of the host's format and architecture (never a shared
library, a text stub, a linker script or a Windows import library), and
gives the platform linker its absolute path -- for the rustc linker and the
system linker alike, on Linux, macOS and Windows. Nothing is a linker flag a
program writes.

Every platform claim below is marked **Executed** (run, its output read),
**Inspected** (read from code, arguments or a tool's output without running
the claim end to end) or **Not implemented**.

## Contents

1. [Result](#1-result)
2. [Starting link-plan census](#2-starting-link-plan-census)
3. [Existing foreign declaration semantics](#3-existing-foreign-declaration-semantics)
4. [Syntax alternatives considered](#4-syntax-alternatives-considered)
5. [Final syntax and grammar](#5-final-syntax-and-grammar)
6. [Linkage semantics](#6-linkage-semantics)
7. [Static archive identity](#7-static-archive-identity)
8. [Application-root-relative path rules](#8-application-root-relative-path-rules)
9. [Imported-module behavior](#9-imported-module-behavior)
10. [Conflicting and repeated declarations](#10-conflicting-and-repeated-declarations)
11. [HIR representation](#11-hir-representation)
12. [HIR interchange](#12-hir-interchange)
13. [Front-end cache and filesystem dependencies](#13-front-end-cache-and-filesystem-dependencies)
14. [Native linker-plan representation](#14-native-linker-plan-representation)
15. [Linux archive selection](#15-linux-archive-selection)
16. [Linux AArch64 behavior](#16-linux-aarch64-behavior)
17. [Apple archive selection](#17-apple-archive-selection)
18. [Apple framework arguments](#18-apple-framework-arguments)
19. [Windows static/import library distinction](#19-windows-staticimport-library-distinction)
20. [Rustc/system linker parity](#20-rustcsystem-linker-parity)
21. [Stub linker behavior](#21-stub-linker-behavior)
22. [Static SDL3 build and linkage](#22-static-sdl3-build-and-linkage)
23. [SDL3 framework dependencies](#23-sdl3-framework-dependencies)
24. [Mach-O dynamic dependency evidence](#24-mach-o-dynamic-dependency-evidence)
25. [Application relocation](#25-application-relocation)
26. [Standalone executable independence](#26-standalone-executable-independence)
27. [C borrowing and error-capture regression](#27-c-borrowing-and-error-capture-regression)
28. [Native-library output implications](#28-native-library-output-implications)
29. [Diagnostics](#29-diagnostics)
30. [Mutation results](#30-mutation-results)
31. [Fuzzing](#31-fuzzing)
32. [Link time and executable size](#32-link-time-and-executable-size)
33. [Linux x86-64 CI](#33-linux-x86-64-ci)
34. [Linux AArch64 CI](#34-linux-aarch64-ci)
35. [macOS AArch64 CI](#35-macos-aarch64-ci)
36. [Windows x86-64 CI](#36-windows-x86-64-ci)
37. [Single-file compiler regressions](#37-single-file-compiler-regressions)
38. [Remaining native-dependency limitations](#38-remaining-native-dependency-limitations)
39. [Prerequisites for macOS graphical Icy Tower](#39-prerequisites-for-macos-graphical-icy-tower)
40. [Prerequisites for general application deployment packaging](#40-prerequisites-for-general-application-deployment-packaging)
41. [What to run when changing this](#41-what-to-run-when-changing-this)
42. [Files](#42-files)

## 1. Result

| Criterion | Status |
|---|---|
| `extern c library "NAME"` keeps its meaning | **Executed**: c-ffi.test, system-linker.test, the whole Linux suite unchanged (sections 33-36) |
| Source can require static linkage, and name the archive | **Executed** on Linux x86-64 (tests/native-link-plan.test, the single executable's FFI smoke); CI sections for the other hosts |
| Source-relative paths from the application root, not the working directory | **Executed** (`nlp-plan-application-root`, `nlp-static-relocation`, smoke F) |
| A static archive is chosen where a shared library of the name exists | **Executed** (`nlp-static-beats-shared`: value 1, no `libnlp.so`; the control 2, `libnlp.so`) |
| No silent fallback to a shared library | **Executed** (`nlp-static-shared-only`; mutant `shared-fallback` killed) |
| Propagation through imports; deterministic merge; LINK-CONFLICT | **Executed** (`nlp-plan-entries`, `-merge`, `-conflicts`) |
| HIR interchange and cache keep every property; stale data impossible | **Executed** (`nlp-plan-interchange`, `nlp-plan-cache`, `nlp-static-rebuild`) |
| Apple framework declarations; refused elsewhere | Lowering **Executed** in Rust unit tests on Linux; refusal **Executed**; macOS link: section 35 |
| Windows import libraries refused as static | **Executed** with synthetic COFF archives in the Rust unit tests; with MSVC: section 36 |
| rustc and system linkers implement the same plan; stub refuses | **Executed** (`nlp-linkers-agree`) |
| Static SDL3 through Botlish.app | section 22-24, 35 (CI job `link-plan-sdl3`) |
| Mutants | 26 in the new harness: 25 killed, 0 survived, 1 another host's (section 30) |

The milestone is a small extension of the existing machinery: one AST node
kind (`externlib`) grew three fields, one HIR side table (`links`) changed
its entries, one NIR header line (`link`) grew two forms and a sibling
(`framework`), and the driver gained one resolution step before the two
existing linkers' argument lowering, which now reads its result.

## 2. Starting link-plan census

One declaration, traced through the tree as it stood before this milestone
(commit 50a4bf1):

```text
source           extern c library "crypto"
  surface/parser.tcl ExternDecl   -> externlib {library NAME librarySpan SPAN}
  surface/lower.tcl  SplitTypeDecls / LinkDeclOf -> {library namespace span origin}
  surface/modules.tcl  a module's link decls appended after its imports'
                     (LoadNamespace: `dict set state linkDecls`), the entry's
                     last (BuildProgram: `-link-decls`)
  hir/hir.tcl        hir::buildSyntax -link-decls -> hir::foreign::apply
  hir/foreign.tcl    the plan {{library NAME origins {...}} ...}, one entry per
                     distinct name, first-declaration order; registry state
                     captured in `declarations` (compilation isolation)
  HIR `links`        side table; hir::foreign::links -> the names
  interchange        the HIR dict itself (no field-level schema); cache = interchange
  native/lower.tcl   NIR header `link "NAME"`, one per entry
  native/src/nir.rs  Program.links: Vec<String>
  codegen/aot.rs     calls_c (foreigns or links non-empty) picks the linker;
                     link_plan_args_for(flavor, program, link_dirs):
                       GNU: -LDIR... --start-group -lNAME... --end-group
                       Apple: -LDIR... -lNAME...
                       MSVC: /LIBPATH:DIR... NAME.lib...
                     system_link_args: the same plan, `-C link-arg=` removed
  main.tcl -L DIR    native::linkDirs -> botlish-native --link-dir DIR
```

What the census settled:

* A library's name was validated once, by the parser (letters, digits,
  `_ + . -`, never a leading `-`).
* The declaring module was known (`namespace`) but the plan kept no
  per-module meaning: every library serves every symbol.
* Several modules could declare one library; the plan kept it once, in
  first-declaration order, collecting every declaration's origin.
* `-L` directories were a link-time input only, never in HIR or a cache key.
* The application root (the entry file's directory) was known to the loader
  (`state root`, for application modules) and is in the front-end cache's
  key, but was not recorded in HIR.
* HIR interchange carries the HIR dict wholesale, and the fingerprint of the
  front end's sources guards its schema: a change to hir/foreign.tcl makes
  every older text and cache entry another front end's.
* Every link-plan entry was retained whether or not a function from it was
  called.
* The C binding generator writes `extern c library "NAME"` lines
  (tools/c-bindgen/emit.tcl); nothing else generates them.
* Native-library emission (`native::library`) linked the program object
  with the runtime into a relocatable object (`ld -r`) and a shared library
  (`cc -shared -Wl,-z,defs`) and ignored the program's link plan: a library
  calling into a declared C library could not be linked as a shared library
  at all (`-z,defs`), and its manifest did not say what a consumer needed.

The smallest extension points, which this milestone used: the `externlib`
node (no new statement kind, so every list of top-level kinds stays right);
`LinkDeclOf`; one loader procedure placing a declaration (`LinkDecls`); one
procedure building the plan (`LinkPlan`); the NIR `link` line; one
resolution function in front of the existing argument lowering.

## 3. Existing foreign declaration semantics

Unchanged (C-FFI.md, sections 1, 2 and 11): `extern c library "NAME"` adds
NAME to the program's link plan, associated with no function; the system
linker resolves every symbol against every library, in one GNU archive group
on Linux, Apple's ld's bare list on macOS, link.exe's `NAME.lib` on
Windows; shared or static is the linker's choice by its own search rules;
`-L` adds a search directory. Every pre-existing test of it passes
unchanged (c-ffi.test: 115 tests on interp and compile; system-linker.test),
and its NIR line is byte for byte what it was (`link "NAME"`).

## 4. Syntax alternatives considered

| Form | Verdict |
|---|---|
| `extern c library "SDL3" static at "native/libSDL3.a"` | **Chosen.** Trailing contextual words, read left to right; the existing declaration is a prefix of it, so the old form is untouched; mirrors `extern c fn NAME named "SYMBOL"`. |
| `extern c static library "SDL3"` | A modifier before the kind reads well but splits the requirement from the path (`... at` would still trail), and makes `static` a fourth word the parser must look ahead past to know the declaration. |
| `extern c library "native/libSDL3.a"` (a path in the name) | Rejected: the name is the linker's library name (the declaration's identity, what merging and conflicts key on); a path would make `"native/libSDL3.a"` and `"SDL3"` two libraries, and the old form's "never a path" rule (an `EXTERN-SYNTAX` error) is what keeps names from being flags. |
| `extern c library "SDL3" at "..."` (path implies static) | Rejected: a path names a static archive, and saying so is cheap; `at` without `static` is an error naming the fix, so the requirement is always visible. |
| An attribute or a block (`@static`, `{static: ..., path: ...}`) | Rejected: no attribute system exists, and a block for one or two facts is ceremony. |
| `extern c library "Cocoa" framework` | Rejected: a framework is not a library -- it has no static variant and no archive path, and Apple's ld searches for it differently (`-F`, `NAME.framework/NAME`) -- so it is its own kind, `extern c framework "NAME"`, sharing the node and the plan. |
| `from` / `path` instead of `at` | `at` reads as a location and is shorter; both alternatives are common identifiers, `at` is contextual like every word after `extern`. |

No combination beyond these three forms was added: no `dynamic`, no
`shared`, no framework search path in source, no weak framework.

## 5. Final syntax and grammar

```
externLibrary   := "extern" "c" "library" STRING ["static" ["at" STRING]]
externFramework := "extern" "c" "framework" STRING
```

* NAME (a library's or a framework's): a string literal of letters,
  digits and `_ + . -`, not starting with `-` -- never a path or a linker
  option (`nir::is_link_name` checks the same rule in the driver).
* PATH (`static at`): a string literal naming a file -- never empty, never
  ending in `/`, no NUL, and `/` between components on every host (a `\`
  is refused: it is a separator on one host and a character on another).
  Relative paths are from the application root; an absolute path is used
  as it is (and makes the program depend on that location: section 8).
* `static`, `at` and `framework` are contextual, like every word after
  `extern`: ordinary names everywhere else (`nlp-parse-contextual`).
* `private` names nothing of them ("an `extern c framework` line names no
  member of the module").

Positive examples are this report's first block. Negative ones, each a
located `EXTERN-SYNTAX` error (`nlp-parse-errors`, `nlp-parse-messages`):

```botlish
extern c library "x" at "a.a"            # an archive path names the file of a static library: write ... static at PATH
extern c library "x" static at ""        # an empty string is no archive path
extern c library "x" static at "a\\b.a"  # write "/" between the components of an archive path
extern c library "x" static at "native/" # names a directory
extern c library "x" static at native    # expected the static archive's path as a string
extern c library "x" static shared       # expected end of line after "static"
extern c framework "-Wl,-x"              # is not a framework name
extern c framework "Cocoa/Cocoa.h"       # is not a framework name
extern c framework "Cocoa" static        # expected end of line after the framework name
extern c package "x"                     # expected "fn", "library" or "framework" after "extern c"
```

A recovering parse (the compiler service, `-check`) reports each malformed
declaration once and keeps the valid ones (`nlp-parse-recover`).

## 6. Linkage semantics

The plan's entries are of two kinds, and a library's of three requirements:

| Requirement | Written | Means | Driver |
|---|---|---|---|
| ordinary | `extern c library "NAME"` | the linker's choice, shared or static | `-lNAME` (`NAME.lib`), as before |
| static | `... static` | a static archive, never a shared library | finds `libNAME.a` (`NAME.lib`) in the -L directories, then the toolchain's; checks it; passes its path |
| static archive | `... static at "PATH"` | exactly that archive | joins PATH to the application root; checks it; passes its path |
| framework | `extern c framework "NAME"` | Apple's framework mechanism | `-framework NAME` on Apple's ld; refused elsewhere |

`static` is a requirement, not a preference: when no archive is found the
link fails (NATIVE LINK ARCHIVE), naming the directories searched and any
shared library of that name it saw and would not take -- never `-lNAME`,
never another file (`nlp-static-shared-only`). An explicit archive is
never substituted: no other file of the name is looked at. A framework is
an ordinary Apple platform dependency, linked as Apple's ld links one (the
system's, or one in a `-F` directory); nothing copies it anywhere, and on a
non-Apple target the declaration is an error (section 18).

## 7. Static archive identity

Before any linker runs, the driver checks each static archive
(codegen/aot.rs's `check_static_archive`, `archive_facts`):

* it exists, is a regular file and can be read;
* it is an `ar` archive (`!<arch>`): an ELF shared library, a Mach-O
  dynamic library, a `.tbd` text stub, a GNU linker script, a thin archive
  (`!<thin>`), a Windows PE file are each refused by name;
* every object member is of the host's format and architecture (`ELF
  x86-64`, `ELF AArch64`, `Mach-O arm64`, `COFF x86-64`): a mixed or foreign
  archive is refused naming the other machine (LLVM bitcode and other
  non-object members are ignored, as linkers treat them);
* on macOS, a universal ("fat") file is read at its arm64 slice, and one
  without an arm64 slice is refused; on any other host a universal file is
  refused;
* it holds no DLL import member (section 19);
* it holds at least one object.

Every member is read, not only the first (the runtime archive's existing
check, `archive_machine`, reads the first object only; it is unchanged).
The archive is passed by its absolute path, so the linker never searches
for it and never substitutes another of the name.

## 8. Application-root-relative path rules

* A relative path resolves from the **application root**: the directory of
  the entry file, `file dirname [file normalize ENTRY]` (the loader's
  existing rule for application modules) -- whatever the working directory,
  whichever module declares it (section 9). The root is recorded beside the
  path (`base`), never joined into it in HIR.
* The join happens at the link, in the driver (`Path::join`): the
  platform's own path semantics, spaces and Unicode included
  (`nlp-static-path-security`: `we-ird/lib nlp $(echo x); 'q'.a`,
  `libnlpü.a`, `-lnlp.a` at the root -- all one argument, absolute, never an
  option).
* Symlinked roots: Tcl's `file normalize` resolves links in the directory
  part; the link reaches the same file either way.
* An absolute path is used as written; it is accepted (a system location
  outside the application is sometimes what a developer means) but makes
  the program depend on that location and is not relocatable.
* Never the compiler's own files: a standard-library module's declaration
  gets no root (`base ""`), so a relative path there cannot resolve -- a
  standard module never sees the application, and nothing resolves against
  the single executable's ZIP or Botlish.app's Resources. A program compiled
  from text (no file) has no root either; a relative path then fails at the
  link with a message saying so (`nlp-static-refusals`).
* No downloading, building or searching beyond the -L and toolchain
  directories for a `static` library without a path.

## 9. Imported-module behavior

A module's declarations reach the program's plan through ordinary imports,
as before (the loader appends a module's after its own imports'), and an
imported application module's archive path resolves from the application
root, exactly as the same line in the entry program would
(`nlp-plan-entries`: the binding module's `static at "native/libSDL3.a"`
has the entry's root as its base). Tested end to end through a binding
module in every link test, and on the native backends' linked runs
(`nlp-static-imported-module-backends`). This is deliberately narrower
than a future package-specific resource root: a module shipped outside the
application (a package) has no root of its own yet (section 38).

## 10. Conflicting and repeated declarations

hir/foreign.tcl's `LinkPlan` identifies a dependency by kind and name, keeps
first-declaration order, and merges each library's declarations into the
strictest requirement, ordinary < static < static at PATH, whichever comes
first (`nlp-plan-merge`):

| Declarations | Plan |
|---|---|
| `"SDL3"` twice | one ordinary entry, two origins |
| `"SDL3"` and `"SDL3" static` | static |
| `"SDL3"` (a binding) and `"SDL3" static at "native/libSDL3.a"` (the application) | that archive, in either order |
| `"SDL3" static` and `"SDL3" static at "native//./libSDL3.a"` | that archive (paths compared with `.` and empty components dropped) |
| `framework "Cocoa"` twice | one framework entry |
| two different archive paths | **LINK-CONFLICT** at the later one, naming the earlier |
| `framework "z"` and `library "z"` | **LINK-CONFLICT** |

The merge is what lets a generated binding (which writes `extern c library
"SDL3"`) and an application that wants the static archive coexist without
editing the binding; each stricter requirement admits everything the looser
one does. LINK-CONFLICT is reported with both locations as data
(`location`, `related`: the compiler service and the language server show
both), whatever the modules' order (`nlp-plan-conflicts`). Order: a
library's place is its first declaration's, the same rule as before; GNU's
group, Apple's ld and link.exe make it irrelevant to a static link
(`nlp-static-dependent-archives`).

## 11. HIR representation

HIR `links` (and the registry state in `declarations foreign links`):

```tcl
{kind library name SDL3 linkage static path native/libSDL3.a base /abs/app origins {ORIGIN ...}}
{kind library name m linkage default path {} base {} origins {...}}
{kind framework name Cocoa origins {...}}
```

Intent only: no `-l`, `-framework`, resolved path or platform spelling.
`hir::foreign::links HIR` spells each entry as declared (`m`, `{z static}`,
`{SDL3 static at native/libSDL3.a}`, `{framework Cocoa}`), the old names
for ordinary libraries; `hir::foreign::linkPlan HIR` returns the entries. A
framework declaration sets the loader's `targetRead`, so its HIR records
its target (`macos-aarch64`); static declarations read no target and keep a
HIR every target's (`nlp-static-needs-no-target`). Compilation isolation
holds by construction: the plan is part of the captured registry state
(`nlp-isolation`; `tests/compilation-isolation.test` passes).

## 12. HIR interchange

The format is the HIR dict, so every property travels: kind, name,
linkage, path as written, root, origins (`nlp-plan-interchange`: the
decoded `links` equal the built ones, and the NIR header lines are
identical). A reader now validates the plan it is given --
`hir::foreign::LinkPlanProblem`, for `links` and for the declaration
state's copy -- and refuses an unknown kind, an unknown linkage, a missing
field, a name that is no library name, a framework with a library's fields,
a path on an ordinary library or one a declaration cannot write, with
`{HIR INTERCHANGE FORMAT}` (six malformed variants refused). Versions: the
interchange format version stays 1 (the dict's shape is the front end's,
and the fingerprint already covers hir/foreign.tcl), so every text written
before this change is another front end's and refused with `{HIR
INTERCHANGE COMPILER}`, never read with the old plan's meaning. No
absolute path of the compiler's checkout enters the text through the plan;
the application root does, as the HIR's file paths always have.

## 13. Front-end cache and filesystem dependencies

* The cache key already holds the application root and the entry path as
  given; the root makes `main.bot` compiled from two applications'
  directories two entries (`nlp-plan-cache`; the `cache-key-without-root`
  mutant, which a moved application alone would not catch, is killed by
  that case). A moved application is another compilation, whose HIR names
  the new root.
* The plan records no file's contents and the front end reads no archive:
  semantic analysis is never invalidated by an archive's bytes, and an
  archive is never part of a cache entry.
* The driver resolves and checks every archive at every link and passes the
  file the linker reads now: rebuilding an archive changes the next
  executable whatever the cache holds (`nlp-static-rebuild`: 7, then 8, the
  second compilation a cache hit; the `archive-contents-kept` mutant, which
  links a copy kept from the first link, is killed by it).
* The cache's schema version stays 1: the fingerprint changed with
  hir/foreign.tcl, so every older entry is a miss.

## 14. Native linker-plan representation

The NIR header states each dependency as the program does:

```
link "m"
link "SDL3" static
link "SDL3" static path="native/macos/libSDL3.a" base="/abs/My App"
framework "Cocoa"
```

`nir.rs` parses them into `Link::{Library, Static {name, archive}, Framework}`
and refuses anything else (a name that could be an option, an empty or
backslashed path, a framework with words after it). The driver resolves
them (`resolve_link_plan`) into `LinkInput::{Library, Archive {name, path,
from}, Framework}` -- the one place a path is joined, an archive found and
checked -- and both linkers lower the same inputs (`link_plan_args_for`).
`BOTLISH_NATIVE_LINK_LOG` records the resolution for either linker:

```
link plan: static nlp: /…/My App ü/native/libnlp.a (declared at "native/libnlp.a")
link plan: static nlpdep: /…/fixture/libnlpdep.a (found in /…/fixture)
```

and `botlish-native link-plan FILE.nir` (`native::linkPlan HIR`) prints the
resolved plan without linking (`archive NAME PATH declared WRITTEN`,
`archive NAME PATH searched DIR`, `library NAME`, `framework NAME`), or the
failure a link would report.

## 15. Linux archive selection

**Executed** on Linux x86-64 (Ubuntu 24.04, GCC 13, GNU ld 2.42). The
driver resolves the archive itself -- the approach shared with macOS -- not
with GNU's `-l:libNAME.a`: so the file is checked before the link and the
same message reports what was searched on every host.

* `static at PATH`: the joined path.
* `static`: the first `libNAME.a` in the `--link-dir` directories, then the
  toolchain's -- the C driver's `-print-search-dirs` libraries (what gcc
  and clang pass ld as `-L`) followed by GNU ld's own SEARCH_DIRs (`ld
  --verbose` of the driver's `-print-prog-name=ld`), in that order, existing
  and deduplicated: `/usr/lib/gcc/x86_64-linux-gnu/13, /usr/lib/x86_64-linux-gnu,
  /usr/lib, /usr/lib64, /usr/local/lib` here. The toolchain is asked only
  when no -L directory has the archive.
* The archive goes inside the existing archive group, by its absolute path.

The system linker's actual command for `static at "native/libnlp.a"`
(BOTLISH_NATIVE_LINK_LOG, compiled from another directory):

```
link plan: static nlp: /tmp/…/evidence/My App ü/native/libnlp.a (declared at "native/libnlp.a")
system linker: /usr/bin/cc -pie -Wl,--eh-frame-hdr -Wl,-z,relro,-z,now -Wl,--gc-sections
  -o '/tmp/…/My App ü/.botlish-aot-12093-…/executable' '/tmp/…/.botlish-aot-12093-…/program.o'
  -Wl,--start-group '/tmp/…/evidence/My App ü/native/libnlp.a' -Wl,--end-group
  …/libbotlish_runtime.a -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc
```

The collision, `libnlp.a` and `libnlp.so` in one -L directory, the shared
one returning 2000 more (**Executed**):

| Declaration | link plan | group | NEEDED | value |
|---|---|---|---|---|
| `extern c library "nlp" static` | `static nlp: …/both/libnlp.a (found in …/both)` | `…/both/libnlp.a` | libgcc_s, libm, libc, ld-linux | 1003 |
| `extern c library "nlp"` | `library nlp: -lnlp` | `-lnlp` | **libnlp.so**, libgcc_s, libm, libc, ld-linux | 2003 |

The test file's link cases (`nlp-static-*`) are the same checks with the
fixture deleted afterwards. The wrong-architecture refusal is **Executed**
with an AArch64 archive built by `clang --target=aarch64-linux-gnu`
(`nlp-static-wrong-architecture`): "holds object code for ELF AArch64, and
this program is linked for linux-x86_64 (ELF x86-64)".

## 16. Linux AArch64 behavior

The Linux implementation is the same code; nothing in it reads x86-64
object members, relocations or symbol tables (the check reads the ELF
header's class and machine; `ELF AArch64` is machine 183). The test file
runs on the arm64 runner in tests-arm64.yml's Tcl suite and its
system-linker job (also under GC stress), and there
`nlp-static-wrong-architecture` builds an x86-64 archive
(`clang --target=x86_64-linux-gnu`) and expects its refusal. Results:
section 34.

## 17. Apple archive selection

Implemented and unit-tested (**Executed** as unit tests on Linux, which
cover the arguments and the archive checks with synthetic Mach-O members);
the link itself on macOS: section 35.

* Apple's ld gets the archive's absolute path among the libraries, with no
  group and no GNU flag (`link_plan_static_archives_and_frameworks_lower_per_linker`).
* `static` searches the -L directories, then ld(1)'s documented defaults,
  `/usr/local/lib` and `/usr/lib` (the SDK holds no third-party archive;
  Homebrew's `/opt/homebrew/lib` is an -L directory, as it is for `-lNAME`).
* A shared library of the name there is `libNAME.dylib` or `libNAME.tbd`;
  either is named in the refusal, never taken.
* Archives of Objective-C objects are ordinary Mach-O members (SDL3's are;
  section 22).

## 18. Apple framework arguments

`extern c framework "NAME"` lowers to the pair `-framework NAME` after the
libraries, and every `-F DIR` (main.tcl's new `-F DIR`, the driver's
`--framework-dir DIR`, `native::withFrameworkDirs`) to `-FDIR` after the
`-L` directories, for both linkers (`-C link-arg=-framework -C
link-arg=NAME` through rustc). Framework and library directories are kept
apart (`LinkSearch {libraries, frameworks}`); `-F` is passed to no other
linker. No framework is special: the name is any `is_link_name` string.

On every non-Apple target the declaration is refused where it is written,
at compile time (UNSUPPORTED-PLATFORM, `nlp-framework-target`, **Executed**
for linux-x86_64, linux-aarch64, windows-x86_64 and windows-x86_64-gnu) --
never lowered to `-lNAME` -- and a hand-written NIR with a framework is
refused by the driver off macOS (NATIVE LINK ARCHIVE). The macOS tests
(`nlp-framework-system`: CoreFoundation's `CFStringGetTypeID`, the
executable loading
`/System/Library/Frameworks/CoreFoundation.framework/…`;
`nlp-framework-dir`: an application framework in a `-F` directory, whose
binary is the fixture's static archive, linked in, and the same link
without `-F` refused with Apple ld's "framework not found") run on the
macOS runners: section 35. Weak frameworks (`-weak_framework`) are not
expressible; SDL3's are linked strongly (section 23).

## 19. Windows static/import library distinction

On Windows `NAME.lib` is a static library or a DLL's import library. The
driver reads every member: a Microsoft short import member (`sig1 0, sig2
0xFFFF`) or a COFF object with an `.idata$` section (a long-form import
library's) makes the file an import library, and a static declaration
refuses it -- the archive a path names and the one a search finds alike --
before link.exe runs, which would accept it ("is an import library: N of
its members import functions from a DLL, so linking it makes the executable
load that DLL at run time"). **Executed** with synthetic archives in the
Rust unit tests (`link_plan_archive_facts_refuse_what_is_no_static_archive`:
a static `.lib`, a short-import one, a long-form one, a DLL renamed). On
Windows the test file builds a real static `nlp.lib` (`cl /MT`, `lib`) and
a real DLL with its import library (`cl /LD`), links the static one with
both linkers and checks the PE import directory names no `nlp.dll`, and
refuses the import library (`nlp-import-library-refused`): section 36. The
static C runtime policy (`/MT`, `/NODEFAULTLIB:` the others), COFF naming,
unwind information and the fallback root plan are untouched (no code of
theirs changed).

## 20. Rustc/system linker parity

Both linkers call `resolve_link_plan` and lower its result with
`link_plan_args_for`; the system linker removes rustc's `-C link-arg=`
wrapping as before. `nlp-linkers-agree` links one static-archive program
with each (**Executed**): value 1009 both, no shared dependency either. The
mutants `rustc-loses-static` and `system-loses-static` (each linker given
`-lNAME` instead of the archive) are killed. Command lines differ (rustc's
startup crate and its libraries); the declared intent is implemented the
same way.

## 21. Stub linker behavior

A program whose plan has any entry -- a static library or a framework
alone, calling nothing, included -- counts as one that calls C (`calls_c`),
so `auto` picks the system linker and the stub refuses it, naming what it
links: "libraries native/libnlp.a (static)", "frameworks Metal"
(`nlp-linkers-agree`'s stub case, Linux x86-64, **Executed**; the
`static-only-plan-is-no-c` mutant is killed by the unit test of `auto`).

## 22. Static SDL3 build and linkage

`tests/platform/link-plan-sdl3.sh BOTLISH.app [TCLSH]`, run by
macos-arm64.yml's `link-plan-sdl3` job on every push (after the `app` job,
from its uploaded download archive extracted to `Prögram Files`):

* SDL3 **3.4.18** (the binding profile's pin:
  tools/c-bindgen/profiles/sdl3.tcl, tag `release-3.4.18`, commit
  `829a65d769d935c4852f8159e964312c0957260a`, verified after the clone),
  built with CMake: `-DCMAKE_BUILD_TYPE=Release -DSDL_STATIC=ON
  -DSDL_SHARED=ON -DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF
  -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0`,
  installed into a prefix the CI caches by the pin; the script prints the
  SDK version, the archive's `lipo -info`, size and SHA-256.
* A hand-written minimal binding (`SDL_GetVersion`, `SDL_Init`,
  `SDL_Quit`) in an application module, `extern c library "SDL3" static at
  "native/macos/libSDL3.a"`, the archive and `libSDL3.dylib` both in
  `native/macos/`; the application in a directory named `My Gäme`.
* Built with `Botlish.app/Contents/MacOS/botlish -emit-native-executable`
  from another working directory; the link plan names the declared archive;
  the executable is `Mach-O 64-bit executable arm64` and prints
  `[3004018, true]` (also under GC stress).

Results: section 35.

## 23. SDL3 framework dependencies

The list is SDL3's own: its installed `sdl3.pc` `Libs.private`, which SDL3's
CMake writes from its targets' link interface. The script translates
`-Wl,-framework,X` and `-Wl,-weak_framework,X` into `extern c framework
"X"` and `-lNAME` into `extern c library "NAME"`, and fails on any entry it
does not know. The link verifies it twice: with the declarations it links;
without the frameworks it is refused with Apple ld's undefined symbols
(the script counts them). Weak frameworks are linked strongly (no weak
form exists; every one is present on macOS 15). The exact list is in the
job's log (section 35).

## 24. Mach-O dynamic dependency evidence

The script requires every dynamic library of the static executables
(`otool -L`) to be under `/usr/lib` or `/System/Library` and none to
mention SDL; it prints the list. The dynamic control (`extern c library
"SDL3"` with the same -L directory) shows `libSDL3.0.dylib` in `otool -L`
(Apple's ld prefers the dylib), runs only with `DYLD_LIBRARY_PATH`, and no
longer starts once SDL3 is deleted. The executable is never called fully
static: libSystem and Apple's frameworks are dynamic, as for every macOS
executable. Results: section 35.

## 25. Application relocation

* Linux (**Executed**): `nlp-static-relocation` compiles through the
  front-end cache from another working directory, renames the application
  directory (`vendor/c libs/libnlp.a` inside it) and compiles again: both
  links run 1005, and the old directory is gone. The single executable's
  FFI smoke test (application F) does the same with the distributed
  compiler (section 37).
* macOS: the SDL3 script moves `My Gäme` to `Möved Gäme` and compiles it
  from a third directory (section 35).

## 26. Standalone executable independence

Every static executable runs with its archive, its application and the
fixture deleted (`nlp-static-at-links`; `runBare`: no environment, PATH
empty), and depends on no shared library of the fixture (ldd: libgcc_s,
libm, libc, the loader). On macOS the SDL3 script runs every static
executable again after deleting SDL3's sources, build, prefix and the
application's `native/` directory.

## 27. C borrowing and error-capture regression

No foreign-call semantics changed: no code of the call path, the
contracts, the exposures, the write-back transport or error capture was
edited. `nlp-static-borrowing` runs a read exposure, a write exposure (the
written bytes summed by C again) and a C sentinel result through a
statically linked archive, plain and under `BOTLISH_NATIVE_GC_STRESS=1`
(`[294, 46, -1, 3]`). c-ffi.test (115), c-byte-borrowing.test and
c-ffi-error-capture.test pass on both Tcl backends (**Executed**), and the
CI system-linker jobs run them on every host, under GC stress too.

## 28. Native-library output implications

`native::library` owns two link steps:

* **The shared library** (`libNAME.so`, `cc -shared -Wl,-z,defs`) now links
  the program's resolved plan (the -L directories, the archives by path and
  the libraries by name, in one group): a static archive's code is inside
  it, nothing of it undefined (`nlp-native-library`: `nlp_add` defined in
  the `.so`, no `libnlp.so` among its NEEDED). Before, `-z,defs` refused a
  library that called into a declared C library.
* **The static library** (`libNAME.a`: the program object and the runtime
  in one relocatable object) does not incorporate the program's
  dependencies -- a relocatable link of a third-party archive would
  localize its symbols into this library only, and a consumer that links
  the same library would get two copies -- and says so: the C function
  stays undefined there (`nm -u`), and the manifest's new `dependencies`
  member lists each resolved dependency with how a consumer links it
  (`{"kind": "library", "name": "nlp", "linkage": "static", "archive":
  "/…/native/libnlp.a", "link": "/…/native/libnlp.a"}`, `-lNAME` for an
  ordinary one, `-framework NAME` for a framework). The manifest schema
  stays 1 (an added member).

No transitive package format, no React Native packaging; the
`botlish_program` record and the exported-function ABI are unchanged.

## 29. Diagnostics

| Situation | Phase | Code | Message (shape) |
|---|---|---|---|
| malformed declaration | parse | `EXTERN-SYNTAX` | section 5 |
| two archives / library and framework | front end | `LINK-CONFLICT` | `library "SDL3" is declared with two static archives, "vendor/libSDL3.a" here and "native/libSDL3.a" at FILE:L:C: a library is one archive, and neither declaration is chosen over the other` |
| framework for a non-Apple target | front end (loader) | `UNSUPPORTED-PLATFORM` | `framework "Cocoa" (`extern c framework`) is an Apple framework, which only macOS's linker links, and this compilation is for target linux-x86_64 (Linux on x86_64): ...; compile for a macOS target (-target macos-x86_64) or declare no framework` |
| static library absent | link (driver, before the linker) | `NATIVE LINK ARCHIVE` | `library "fx" is declared static, and no static archive libfx.a is in the library search directories (DIR, ...): add the archive's directory (main.tcl -L DIR), or name its file (`extern c library "fx" static at "PATH"`)` |
| only a shared library there | link | `NATIVE LINK ARCHIVE` | `... -- DIR/libfx.so is a shared library of that name, which a static declaration never links: ...` |
| declared archive missing / not a file / no archive | link | `NATIVE LINK ARCHIVE` | `the static archive PATH of library "fx" (declared at "native/libfx.a", relative to the application root ROOT) does not exist` / `is not a file` / `is no static archive: it is an ELF shared library` |
| wrong architecture | link | `NATIVE LINK ARCHIVE` | `... holds object code for ELF AArch64, and this program is linked for linux-x86_64 (ELF x86-64): an archive of another architecture or object format never links` |
| Windows import library | link | `NATIVE LINK ARCHIVE` | `... is an import library: N of its members import functions from a DLL ...` |
| relative path, no application root | link | `NATIVE LINK ARCHIVE` | `... a path relative to the program's application root, and this program has none ...` |
| framework off macOS (hand-written NIR) | link | `NATIVE LINK ARCHIVE` | `framework "Cocoa" (`extern c framework`) is an Apple framework, which only macOS's linker links ...` |
| framework not found, symbol missing in an archive | link (the linker) | `NATIVE LINK` | the linker's own lines, as before (`nlp-static-missing-symbol`: GNU ld's `undefined reference to 'nlp_no_such_function'`) |
| no C toolchain | link | `NATIVE LINK TOOLCHAIN` | unchanged, never suggesting Rust |

Checking versus linking: every source-only fact (syntax, conflicts, a
framework's target) is a front-end diagnostic that `-check`, the compiler
service and the language server report with its location as data; nothing
about a file is: checking never reads an archive (`nlp-static-needs-no-target`:
a missing archive compiles and runs on the Tcl backends). LINK-CONFLICT is
classified in tests/static-compile.test's census (a declaration's) and has
its Compilerpedia topic (`error.link-conflict`, with a rejected and an
accepted example); `NATIVE LINK ARCHIVE` is documented in
`error.native-link`, the frameworks in `error.unsupported-platform`, the
whole feature in `concept.native-link-plan`; `tools/compilerpedia.tcl
check` passes (852 topics, 641 examples, 0 problems).

## 30. Mutation results

`audit/native-link-plan/tools/mutate.tcl` (new; mutants.txt beside it; the
C FFI harness's format and procedure: a private tree per mutant, native
mutants rebuilt, detectors tests/native-link-plan.test and the link plan's
Rust unit tests). Linux x86-64 (**Executed**; audit/native-link-plan/
mutate-result.txt): **26 mutants, 25 killed, 0 survived, 1 skipped** (another
host's), 0 not applied, 0 not built.

| Mutant (the milestone's table) | Killed by |
|---|---|
| `static-dropped-in-lowering` | plan, merge, link tests |
| `static-dropped-in-interchange` | `nlp-plan-interchange`, `nlp-plan-cache` |
| `archive-path-ignored` | every `static at` link |
| `path-from-working-directory` (native) | link tests (other cwd), Rust `..._resolve_from_the_application_root` |
| `imported-path-from-library` (the compiler's ZIP) | binding-module tests |
| `cache-key-without-root` | `nlp-plan-cache` (one entry path from two directories) |
| `archive-contents-kept` (native) | `nlp-static-rebuild` |
| `shared-fallback` (native) | `nlp-static-shared-only`, Rust `..._never_take_a_shared_library` |
| `plan-order-reversed` | `nlp-plan-entries` |
| `module-links-dropped` | binding-module tests |
| `archive-conflict-merged` | `nlp-plan-conflicts` |
| `framework-dropped` | `nlp-nir-header` |
| `framework-as-library` (`-lCocoa`, native) | Rust lowering test |
| `framework-on-linux` | `nlp-framework-target` |
| `framework-dir-dropped` (native) | Rust lowering test |
| `framework-dir-not-passed` (native.tcl) | `nlp-framework-dir` -- **skipped** on Linux (`%% macos-aarch64`) |
| `archive-path-as-option` (native) | `nlp-static-path-security` (`-lnlp.a`) |
| `import-library-accepted` (native) | Rust facts test; `nlp-import-library-refused` on Windows |
| `rustc-loses-static` (native) | link tests, `nlp-linkers-agree` |
| `system-loses-static` (native) | `nlp-linkers-agree` |
| `static-only-plan-is-no-c` (stub chosen, native) | Rust test of `auto` |
| `machine-misclassified` (native) | `nlp-static-wrong-architecture`, Rust facts test |
| `linker-diagnostics-hidden` (native) | `nlp-static-missing-symbol` |
| `archive-base-dropped` | every relative `static at` link |
| `library-framework-conflict-merged` | `nlp-plan-conflicts` |
| `shared-library-accepted-as-archive` (native) | `nlp-static-refusals`, Rust facts test |

Kills are by behavior (a test's or a unit test's assertion), never by a
build failure: a mutant that does not build is NOT-BUILT, and none was.
The mutants stay as regression guards.

Existing harnesses whose mutants edit code this milestone changed were
updated, each kept a mutant of the same rule: c-ffi's `library-dropped`,
`nearest-library`, `link-group-dropped`, `link-dirs-dropped`; native-aot's
`msvc-link-plan-is-gnus`; target-model's `driver-runs-any-target` (its
command list now includes `link-plan`). Their runs: section 33. Mutants
of those files that did not apply at the starting commit already (c-ffi's
`stub-links-c`, native-aot's `startup-no-guard` and
`sys-runtime-variable-ignored`, and others in unrelated harnesses) are not
this milestone's and are left as they were.

## 31. Fuzzing

The C FFI fuzzer (`audit/c-ffi/tools/fuzz.tcl`) runs unchanged (its
programs declare ordinary libraries; their meaning did not change) as part
of the c-ffi mutation harness and on its own (section 33). No link-plan
generator was added: the matrix of the merge rule is small and closed
(three requirements, two kinds, an order), and `nlp-plan-merge` and
`nlp-plan-conflicts` enumerate it, in both module orders, with every
mutant of it killed; the semantic cases need real archives, which the
fixture provides.

## 32. Link time and executable size

`bench/native-link-plan.tcl -runs 5` (**Executed**: medians of 5, Linux
x86-64, a 4-core container with nothing else running, the release driver,
GNU ld 2.42 through cc; the fixture of tests/native-link-plan.test, a
static archive and a shared library of one name):

| Front end (parse, load, build, check) | ms |
|---|---:|
| no link declaration | 3.2 |
| 50 ordinary `extern c library` | 4.1 |
| 50 static ones (25 `static at`) | 4.4 |

| The driver's resolution (`botlish-native link-plan`) | ms | result |
|---|---:|---|
| an archive declared at a path | 2.6 | archive |
| an archive on the -L path | 2.4 | archive |
| an archive found nowhere | 8.5 | NATIVE LINK ARCHIVE |

| The link | link ms | executable bytes | dynamic libraries | whole run ms |
|---|---:|---:|---:|---:|
| rustc, `extern c library` (shared) | 386.6 | 10,034,128 | 6 | 3.2 |
| rustc, `static at` (archive) | 368.7 | 10,034,232 | 5 | 2.9 |
| system, `extern c library` (shared) | 202.1 | 9,930,336 | 6 | 2.9 |
| system, `static at` (archive) | 211.6 | 9,930,400 | 5 | 3.1 |

What it shows:

* The plan costs the front end about a millisecond for 50 declarations
  of either kind (3.2 ms without one, 4.1 and 4.4 ms with them).
* Resolution is a few milliseconds and never the link's cost. A refusal
  costs more (8.5 ms) because the driver has looked everywhere first:
  the -L directories, then the toolchain's own (`cc -print-search-dirs`
  and `ld --verbose`, each a process). A found archive never asks the
  toolchain: the -L directories come first.
* A static link takes as long as a shared one (within 5% either way), the
  executable grows by the archive's code (64 to 104 bytes for the
  fixture's two functions) and has one dynamic library fewer (the
  fixture's). The whole runs of an executable that adds two numbers differ
  by less than their noise.
* The system linker links in about half the rustc linker's time, with
  both linkages, as SINGLE-EXECUTABLE-FFI-MILESTONE-1.md measured for
  ordinary programs.

The macOS numbers are the SDL3 job's (section 35): its log prints the
static and dynamic executables' sizes and `otool -L` lists.

## 33. Linux x86-64 CI

Locally (**Executed**, Linux x86-64, the branch merged with main at
ff0826c, the release driver):

* `tests/native-link-plan.test`: 35 tests, 32 passed, 3 skipped (two
  `macosHost`, one `windowsHost`), 0 failed; also with
  `BOTLISH_NATIVE_LINKER=system`, with `stub` and under
  `BOTLISH_NATIVE_GC_STRESS=1`.
* `cargo test --release --bin botlish-native link_plan`: 12 passed.
* The link-plan mutants: 26, 25 killed, 1 skipped (section 30).
* The updated mutants of the other harnesses, each still applying and
  killed: c-ffi's link-plan and declaration mutants (`-only` the 13 of
  them: 12 killed, `macos-link-plan-is-gnus` skipped, another host's
  code), native-aot's link mutants (`msvc-link-plan-is-gnus`,
  `linker-status-ignored`, `sys-auto-stub-for-c`,
  `sys-auto-system-for-plain`, `sys-group-dropped`, `sys-link-dirs-lost`,
  `sys-plan-lost`, `sys-failed-link-replaces`: 8 killed), target-model's
  `driver-runs-any-target` and `windows-environments-one-target` (2
  killed).
* `audit/c-ffi/tools/fuzz.tcl -n 25` with seeds 3 and 17: 50 programs, 600
  functions (172 variadic, 710 trailing arguments), 0 disagreements.
* `audit/hir-interchange/tools/roundtrip.tcl -via interchange` (12 suites,
  108 artifacts and outcomes, 0 differ) and `-via cache` (120, 0 differ);
  `audit/compilation-isolation/tools/interleave.tcl` (96, 0 differ).
* `tools/compilerpedia.tcl check`: 852 topics, 641 examples, 0 problems;
  tests/static-compile.test's `sc-census-exhaustive` passes.

In CI: (Filled in below.)

## 34. Linux AArch64 CI

(Filled in below.)

## 35. macOS AArch64 CI

(Filled in below.)

## 36. Windows x86-64 CI

(Filled in below.)

## 37. Single-file compiler regressions

(Filled in below.)

## 38. Remaining native-dependency limitations

* **No package-relative root.** An archive path is the application's; a
  module distributed apart from an application cannot name its own
  archive relative to itself yet (a package system would supply that root).
* **No weak frameworks**, no framework version selection, no `-needed_` or
  `-reexport_` forms, no linker flags at all.
* **No dynamic dependency bundling.** A program that links a third-party
  shared library or framework still needs it installed where it runs;
  nothing copies a dylib or framework, writes an rpath or makes a bundle.
* **`static` only, never "prefer static".** There is no form that takes a
  static archive when present and a shared library otherwise.
* **The toolchain's default directories** are asked of the C driver and GNU
  ld on Linux, assumed from ld(1) on macOS, read from `LIB` on Windows; a
  toolchain configured otherwise (a sysroot, `-fuse-ld=lld` with other
  defaults) may search directories the driver does not; `-L` or `static
  at` is then the remedy, and the refusal lists what was searched.
* **Thin archives and LTO-only archives** are refused or treated as
  objectless; universal files are read only on macOS.
* **A `.hirx` keeps its build's root**: read and linked after the
  application moved, it links the archive where the application was.
* **Native libraries' static archives** list their dependencies but do not
  incorporate them.

## 39. Prerequisites for macOS graphical Icy Tower

Static SDL3 now links through the distributed compiler with the frameworks
it needs. Still missing, each a separate experiment:

* the macOS SDL3 binding generated for macos-aarch64 (the C binding
  generator's profile on a Mac or with the SDK), replacing the minimal
  hand-written one;
* Cocoa's main-thread requirement: SDL3's video subsystem must be
  initialized and pumped on the process's main thread, and Botlish's native
  runtime runs a program on a worker thread (`aot::run`); either the
  runtime runs the program on the main thread on macOS, or an event pump
  is handed to it -- a runtime design decision this milestone does not
  take;
* a graphical acceptance (a window on a macOS runner) and the game's
  Darwin entry (`std::darwin::io`) beside its Linux and Windows ones;
* an application bundle for the game itself (Info.plist, signing) if it
  is to be distributed rather than run from a terminal.

## 40. Prerequisites for general application deployment packaging

* a package root for native resources (section 38), so a library's
  binding can ship its own archives;
* a decision on shared dependencies: bundling dylibs/frameworks or DLLs
  beside an executable, install names and rpaths, Windows DLL placement --
  none of which this milestone does;
* an application bundle generator for arbitrary programs (Botlish.app's is
  the compiler's own), signing and notarization (MACOS-AARCH64-MILESTONE-9.md's
  Developer ID prerequisites);
* a lockfile and fetching for third-party archives, if packages are to
  acquire them; this plan representation is what they would fill in.

## 41. What to run when changing this

The files: surface/parser.tcl (`ExternDecl`, `LinkDecl`,
`ArchivePathProblem`), surface/ast.tcl (`externlib`), surface/lower.tcl
(`LinkDeclOf`), surface/modules.tcl (`LinkDecls`, `FrameworkCheck`),
core/cabi.tcl (`linksFrameworks`), hir/foreign.tcl (`LinkPlan`,
`MergeLibrary`, `ArchivePathKey`, `LinkConflict`, `links`, `linkPlan`,
`LinkPlanProblem`), hir/interchange.tcl (`decode`'s check),
native/lower.tcl (the `link`/`framework` header lines), native/native.tcl
(`frameworkDirs`, `withFrameworkDirs`, `linkPlan`), native/library.tcl
(`DependencyArgs`, the manifest's `dependencies`), main.tcl (`-F`),
native/src/nir.rs (`Link`, `parse_link`, `is_link_name`),
native/src/codegen/aot.rs (`LinkSearch`, `resolve_link_plan`,
`check_static_archive`, `archive_facts`, `default_library_dirs`,
`link_plan_args_for`, `describe_inputs`, `log_plan`), native/src/main.rs
(`--framework-dir`, `link-plan`, `NATIVE LINK ARCHIVE`).

Run: `tests/native-link-plan.test` (also with `BOTLISH_NATIVE_LINKER=system`
and under `BOTLISH_NATIVE_GC_STRESS=1`), `tests/c-ffi.test`,
`tests/system-linker.test`, `tests/native-library.test`,
`tests/hir-interchange.test`, `tests/hir-cache.test`,
`tests/compilation-isolation.test`, `tests/static-compile.test`
(`sc-census-exhaustive`), `tools/compilerpedia.tcl check`, `cargo test
--release --manifest-path native/Cargo.toml --bin botlish-native
link_plan`, `audit/native-link-plan/tools/mutate.tcl` (every mutant that
applies to the host killed), and for code they share the c-ffi,
native-aot and target-model harnesses; on macOS the `link-plan-sdl3` job,
on Windows the workflow's smoke and system-linker jobs;
`single/ffi-smoke-test.sh` after `single/build.sh` (its application F).
`bench/native-link-plan.tcl` regenerates section 32.

## 42. Files

New: tests/native-link-plan.test, tests/platform/link-plan-sdl3.sh,
audit/native-link-plan/tools/{mutate.tcl,mutants.txt},
audit/native-link-plan/mutate-result.txt, bench/native-link-plan.tcl, this
report. Changed: the files of section 41; single/ffi-smoke-test.sh
(application F); tests/system-linker.test (`system-linker-auto` reads the
log's `system linker:` line among the plan's), tests/static-compile.test
(the census); the workflows (macos-arm64.yml's `link-plan-sdl3` job; the
test file in the system-linker jobs' lists and Windows' smoke list);
Compilerpedia (`concept.native-link-plan`, `error.link-conflict`,
`error.native-link`, `error.unsupported-platform`, `cli.options`);
C-FFI.md, SINGLE-EXECUTABLE.md, SINGLE-EXECUTABLE-FFI-MILESTONE-1.md,
MACOS-AARCH64-MILESTONE-9.md, HIR-INTERCHANGE.md, INDEX.md, AGENTS.md; the
updated mutants of audit/c-ffi, audit/native-aot and audit/target-model.
