# PM-2: target-aware packages, native dependencies and cross-platform FFI deployment

A Botlish package can now ship generated bindings and native libraries for
several targets in one immutable release, and an application consumes it
like any other dependency: `botlish add sdlkit` installs the release, the
package manager derives the target view the compiler reads for the target
being compiled, checks every native file it bundles and every system
library it relies on, links them with no `-L`, runs them with no
`LD_LIBRARY_PATH`, and `botlish native deploy` places the shared libraries
an executable needs where it finds them after it is moved. Pure-Botlish
packages are untouched: schema 1, no target, no view, no native step.

This is milestone PM-2 of PACKAGE-ECOSYSTEM-ROADMAP.md. The normative
format changes are BOTLISH-JSON.md section 12 (schema 2) and
BOTPKG-FORMAT.md (no format change: a target layout inside version 1); the
compiler's one new rule is BOT-MODULES-MILESTONE-1.md, "Target package
trees".

> A package version identifies one immutable release, regardless of its
> supported targets. The package manager prepares and validates the
> appropriate native dependencies; the compiler continues compiling
> ordinary Botlish source and using its established native link
> mechanisms.

Every claim below is marked **Executed** (run here, its output read),
**Inspected** (read from code, a binary's bytes or a tool's output, without
running the claim end to end) or **Not implemented**. Everything executed
ran on one Linux x86-64 container (Ubuntu 24.04, Tcl 9.0.1, rustc 1.97,
GCC 13, clang 18, the Ubuntu GNU AArch64 cross compiler and MinGW-w64).

Contents:

* [0. Design note: what existed, what was missing](#0-design-note-what-existed-what-was-missing)
* [A. Result](#a-result)
* [B. Metadata design](#b-metadata-design)
* [C. Target views](#c-target-views)
* [D. Native verification](#d-native-verification)
* [E. Native deployment](#e-native-deployment)
* [F. Workloads](#f-workloads)
* [G. Tests and security](#g-tests-and-security)
* [H. Performance](#h-performance)
* [I. Remaining limitations](#i-remaining-limitations)
* [J. PM-3 preparation](#j-pm-3-preparation)
* [Repository changes](#repository-changes)

## 0. Design note: what existed, what was missing

Written from the code before anything changed:

| mechanism | existing support | gap |
|---|---|---|
| Package-instance identity, downward resolution (surface/modules.tcl `Locate`, `Instance`, `Identity`) | complete: a tree is read by place, identities never depend on paths | none |
| Package-relative native archives (`static at`, `LinkDecls`: the base is the declaring instance's directory) | complete | none: a projected tree keeps each instance's archive inside it |
| Archive identity at link time (codegen/aot.rs `check_static_archive`) | complete, the driver's | the package manager runs without the driver (single executable): it needs its own reader |
| Front-end cache dependencies (every package directory probed) and the target in the key | complete | none: a tree per target is a different set of probed paths |
| HIR target recording (`targetRead`) and interchange's target check | complete | a HIR read from a target-specific tree must record its target |
| Target-specific source (`stdlib/P.ARCH.bot`, `ModuleFile`) | standard library only, by architecture | packages need whole per-target subtrees (bindings) and per-target native files at fixed paths |
| The application's packages directory | exactly `ROOT/.bot_modules`, no target | **one tree per target needs a compiler-side selection** |
| Libraries linked by name (`extern c library "SDL3"`) | found by `-L` | **a bundled library needs a search directory the consumer does not type** |
| Runtime search paths | none (no rpath anywhere) | **a relocatable deployment of a bundled shared library needs one** |
| Native metadata, verification, closure, deployment | none (PM-1 transported native files as opaque bytes) | **all new** |
| SHA-256 | Tcl only, 0.83 MiB/s | **too slow for native-sized artifacts** |

Two representations of target-specific packages were weighed:

1. **Overlays read by the compiler**: every package instance keeps all its
   targets' subtrees, and the compiler resolves a module or an archive path
   through `targets/T/` first. One installed tree, nothing to project. But
   it makes the compiler interpret a package layout (and with it the
   metadata's choice of directories), puts target selection in the
   compiler rather than the package manager, cannot diagnose an unsupported
   target (the compiler would find the common files and fail later), and
   needs a second resolution rule for link paths.
2. **Views derived by the package manager** (chosen): the store keeps each
   artifact as it is (PM-1's tree, record and verification unchanged);
   per prepared target the manager derives an ordinary package tree, and
   the compiler's only new knowledge is which directory is the
   application's packages for a target. The metadata stays the package
   manager's; an unsupported target is refused before anything is written;
   each view is an ordinary tree every existing mechanism reads unchanged.

The cost of (2) is disk space (each view copies its files) and a derivation
step, both measured in section H.

## A. Result

### What works

| capability | status |
|---|---|
| One release (`sdl3-0.2.0.botpkg`, one SHA-256) holding linux-x86_64's and linux-aarch64's generated bindings, thunk archives and native libraries | **Executed** (`pw-sdlkit-installs-its-binding`, `pw-sdl3-two-targets`) |
| Schema 1 packages unchanged; schema 2 strict and canonical | **Executed** (`pn-schema1-unchanged`, `pn-schema2-*`; the 74 PM-1 tests, two of their expectations updated for schema 2's existence) |
| Target views: A, B, A without reinstalling A; concurrent compilations for two targets; an update deriving every view; nested and multi-version instances in views | **Executed** (`pn-one-artifact-two-targets`, `pn-concurrent-target-compiles`, `pn-update-derives-every-view`, `pn-two-versions-in-views`) |
| Unsupported targets refused with the package's own list, nothing written | **Executed** (`pn-unsupported-target`, `pw-raven-targets`, `pw-event-loop-linux-only`) |
| Bundled native files verified without running them: ELF, ar, Mach-O (also universal), PE/COFF, import libraries | **Executed** (`pn-inspect-*`, `pn-bundled-checks`, `pn-macos-deployment-requirements`) with real binaries built by GCC, clang, lld (Mach-O) and MinGW-w64 |
| System libraries verified by the distribution's metadata (dpkg, pkg-config under /usr), never by a bare file | **Executed** (`pn-system-library-verified`: zlib by its dpkg/pkg-config record; `pn-system-library-needs-system-metadata`: /usr/local's libpython3.so refused) |
| The application's native closure: conflicts refused | **Executed** (`pn-native-conflicts`, `pn-missing-transitive-dependency`, `pn-source-metadata-contradiction`) |
| Linking bundled libraries with no -L; running with no LD_LIBRARY_PATH | **Executed** (`pn-bundled-libraries-link-and-run`; SDL3 `pw-sdlkit-runs` on cranelift and cranelift-generic; Raven `pw-raven-runs`; the SDL3 thunk archive `pw-sdl3-thunk-archive`) |
| A relocatable bundled-shared-library application | **Executed** with real SDL3 (`pw-sdlkit-deploy-relocates`): libSDL3.so.0 deployed in DIR/lib, the executable's RUNPATH `$ORIGIN/lib`, DIR moved, the packages deleted, the program runs and prints `[[true, true, true, true, true, true], true]` |
| Public headers for consumers' C | **Executed** (`pw-event-loop-runs`: the ticker compiled with `native plan -include`'s directory) |
| Transactions over views and deployments, with fault injection and crash recovery | **Executed** (`pn-view-fault-rollback`, `pn-view-crash-recovery`, `pn-deploy-ownership-and-faults`) |
| SHA-256 through the system's tool | **Executed**: about 340 MiB/s on large inputs here (under load) against PM-1's 0.83 MiB/s (section H); the Tcl fallback kept and checked against it |
| Installation with no C compiler or linker on PATH | **Executed** (`pw-raven-installs-without-a-compiler`, PM-1's `pw-pure-botlish-package`) |

### Targets

| target | packages carry it | verified here | executed here |
|---|---|---|---|
| linux-x86_64 | sdl3, raven, event_loop_linux | everything | yes: compile, link, run, deploy, relocate |
| linux-aarch64 | sdl3 (binding, thunk archive; SDL3 system), raven (binding, bridge, bundled libraven), event_loop_linux (archive) | bundled files: every fact, from x86-64 bytes; system SDL3: reported unverified | front end only (`-target linux-aarch64`: HIR, NIR); no AArch64 machine here |
| macos-aarch64 | none of the repository's (no committed macOS binding, PM-1's limitation) | toy packages: dylibs, install names, signatures, universal files (real Mach-O from clang + lld) | no |
| windows-x86_64-gnu, windows-x86_64 | none of the repository's | toy DLLs and import libraries from MinGW-w64 | no |

What can now be installed and deployed without a package-specific command:
SDL3 (through sdlkit or directly), Raven, the Linux event loop's driver and
any pure-Botlish package. The author's side still has per-package recipes
(`tools/package-repository.tcl`, PM-3's subject).

## B. Metadata design

The normative text is BOTLISH-JSON.md section 12. In short:

```json
{
  "schema": 2,
  "name": "sdl3",
  "version": "0.2.0",
  "dependencies": {},
  "targets": {
    "linux-aarch64": {
      "files": "targets/linux-aarch64",
      "libraries": [
        {"name": "SDL3", "origin": "system", "linkage": "shared",
         "identity": "libSDL3.so.0", "version": "3", "pkg-config": "sdl3"},
        {"name": "botlish_shim_sdl3_923ddd74", "origin": "bundled",
         "linkage": "static", "file": "native/libbotlish_shim_sdl3_923ddd74.a"}
      ]
    },
    "linux-x86_64": {
      "files": "targets/linux-x86_64",
      "libraries": [
        {"name": "SDL3", "origin": "bundled", "linkage": "shared",
         "file": "native/libSDL3.so.0", "identity": "libSDL3.so.0",
         "needs": ["libm.so.6", "libc.so.6"],
         "symbols": ["SDL_GetVersion", "SDL_Init"]},
        {"name": "SDL3", "origin": "system", "linkage": "shared",
         "identity": "libSDL3.so.0", "version": "3", "pkg-config": "sdl3"},
        {"name": "botlish_shim_sdl3_6de904a8", "origin": "bundled",
         "linkage": "static", "file": "native/libbotlish_shim_sdl3_6de904a8.a"}
      ]
    }
  }
}
```

(the repository's `packages/sdl3/botlish.json`, shown compacted).

* **Schema versioning.** `targets` and `origins` are schema 2's. PM-1's
  reader refuses `"schema": 2` as an unsupported schema, so a target-aware
  artifact is never installed by it as if its target directories were
  ordinary files; this reader refuses schema 2's keys in a schema 1 file,
  saying so. A schema 1 file reads and writes byte for byte as before
  (`pn-schema1-unchanged`), and a schema 1 project's record stays
  `"state": 1` (`pn-pure-packages-no-views`).
* **Targets are the compiler's names** (core/cabi.tcl's table, read as
  data by `pm/target.tcl`; `pn-target-names-are-the-compilers`), so the OS,
  architecture and toolchain ABI distinctions are the compiler's own:
  windows-x86_64 (MSVC) and windows-x86_64-gnu (MinGW-w64) are two targets,
  and the Linux targets are glibc's -- a library needing `libc.musl-*` or
  musl's loader is refused for them (`pn-bundled-checks`' musl case).
* **Subtree mapping, not file lists**: a target's `files` directory is
  mapped onto the package root for that target. The 62-file SDL3 binding
  needs one line. Collisions between common and target files, nested
  target directories, case collisions and a target `botlish.json` are
  layout errors, checked when the artifact is read (`pm::targets::Problems`,
  at every acquisition, and at packing; `pn-target-layout-problems`).
* **Native declarations describe availability and identity, never linker
  flags.** What links is still the source's `extern c library` declaration;
  the metadata says where each library comes from (bundled file, or the
  system), how it links, and the facts that are checked: loader identity,
  loader dependencies (exactly the binary's), required symbols, a version
  request for a system library. There is no flag, search path or script
  field.
* **One release, every target.** The one archive holds every target's
  files; its digest is the release's identity. A future signature over it
  authenticates every target variant and native declaration at once
  (BOTLISH-JSON.md section 11). Several artifacts claiming one release for
  different targets remain a `CONFLICT`, correctly.
* **Pure-Botlish packages** have no `targets` and need no schema 2.

## C. Target views

### The representation

```
app/
    botlish.json  main.bot
    .bot_modules/
        .botlish/state.json            the record (schema 2 when views exist)
        sdlkit/                        the store: artifacts as they are
            sdlkit.bot  botlish.json
            .bot_modules/sdl3/
                botlish.json  README.md
                targets/linux-x86_64/sdl3/*.bot  targets/linux-x86_64/native/...
                targets/linux-aarch64/sdl3/*.bot targets/linux-aarch64/native/...
        .targets/                      what the compiler reads, per target
            linux-x86_64/
                sdlkit/sdlkit.bot ...
                sdlkit/.bot_modules/sdl3/sdl3/*.bot     the x86-64 binding
                sdlkit/.bot_modules/sdl3/native/libSDL3.so.0 ...
                .lib/libSDL3.so  libSDL3.so.0  libbotlish_shim_sdl3_6de904a8.a
            linux-aarch64/
                sdlkit/.bot_modules/sdl3/sdl3/*.bot     the AArch64 binding
                .lib/libbotlish_shim_sdl3_923ddd74.a
```

* **The store** is PM-1's installation, unchanged: each artifact's files,
  its record of sizes and CRC-32s, its verification against artifacts.
* **A view** (`pm/view.tcl`) is, for each top-level package, the
  instance's common files and its target's files at their mapped paths,
  its dependencies under its own `.bot_modules`, recursively; an editable
  dependency and a package installed by hand are links to themselves
  (never copied or modified: `pn-manual-and-editable-in-views`); and `.lib`
  holds the bundled libraries of the native plan (section E).
* **Deterministic and reusable**: a view's record holds a digest of what it
  was derived from -- the store's record (every file's CRC-32), the target,
  the consumer's origins and the manual packages it links -- and its own
  files. A view whose digest is what its inputs give now and whose files are
  unchanged is reused as it is (`view T: unchanged`); a changed view file is
  reported by `verify` and derived again by the next operation
  (`pn-view-changes-detected`).
* **Which targets have views**: the ones prepared (`-target T`, any number,
  on add/install/update/remove), kept until dropped (`-drop-target T`).
  When the first target-aware package arrives with no target given, the
  host's view is made (or, if the packages do not support the host,
  `TARGET` asks for `-target`). When no installed package is target-aware
  any more, every view and `.targets` itself are removed: the record is
  schema 1 again (`pn-views-dropped-with-last-aware-package`). A project of
  pure-Botlish packages never has a view (`pn-pure-packages-no-views`).

### The compiler

One rule (surface/modules.tcl's `ApplicationTree`; BOT-MODULES-MILESTONE-1.md,
"Target package trees"): when `ROOT/.bot_modules/.targets` exists, the
application's package directory is `.targets/TARGET` for the compilation's
target; if that tree is missing, the application has no package for the
target and UNKNOWN-NAMESPACE says the packages are prepared by target and
not for this one (`pn-unprepared-target-diagnostic`). The rule:

* knows a directory name, never `botlish.json`, a version, the record or
  native metadata (the compiler never loads `pm/`);
* changes nothing else: instance identities (`sdlkit/sdl3::video`), scopes,
  downward resolution, link-path bases (a package's `static at` resolves
  in its instance's directory inside the view), privacy, directness;
* probes `.targets` and the tree through the source seam, so the front-end
  cache's dependencies and the compiler service's sources record them
  (`bm-service-sources` now lists `.bot_modules/.targets` among the
  directories asked about);
* marks the HIR its target's (`targetRead`): HIR interchange refuses a
  view-compiled HIR for another target, and the cache keeps one entry per
  target (`pn-cache-and-interchange`: one hit for the repeated target, the
  other a miss, `HIR INTERCHANGE TARGET` for the wrong target);
* records the tree's `.lib` as the HIR's `nativeDirs`, validated by HIR
  interchange (absolute directories only), which native/native.tcl adds
  after `-L`'s for a link, and for a native backend's own run also as a
  runtime search path.

Diagnostics name real files: a view's files are the package's sources at a
stable path (`.bot_modules/.targets/linux-x86_64/sdlkit/sdlkit.bot`), never
a staging directory.

### Concurrency and ownership

* Compilations for different targets read different directories; two
  processes compiling A and B at once get each its own answer
  (`pn-concurrent-target-compiles`, four processes interleaved).
* Package operations are serialized by PM-1's project lock. A view is
  replaced by renaming its directory; a compilation of the same target
  running *during* that rename can see a mix of the old and new trees (the
  same as PM-1's packages): run package operations and builds of one target
  one after the other.
* The manager owns `.targets` as it owns `.botlish`: a `.targets` it did not
  make (a hand-assembled target tree) is the user's, and making a view there
  is `MANUAL` (`pn-hand-made-targets-refused`). It never leaves an empty
  `.targets`, which would hide every package from the compiler.

### Transactions

Views are part of PM-1's one transaction: staged in `txn/views/T`, moved in
with the packages (`txn/oldviews/T` for the replaced ones), journaled with a
`kind` per operation (a PM-1 journal without kinds is still recovered),
the record written last. A failure while projecting, placing native
libraries or moving a view leaves the project file for file as it was, the
first view usable (`pn-view-fault-rollback`: `project`, `native-placed`,
`commit-view-new`); a process killed while moving views is rolled back by
the next command, or finished after its commit marker
(`pn-view-crash-recovery`: `commit-view-old`, `commit-view-new`,
`state-written`, `committed`). Native validation happens before anything
active is replaced: a native problem fails the operation while staging.

## D. Native verification

### Reading binaries without running them

`pm/binary.tcl` reads, from the bytes and by each format's specification:

| format | facts |
|---|---|
| ELF (64-bit little-endian; others identified and refused) | type, machine, interpreter, soname (DT_SONAME), needed (DT_NEEDED), RUNPATH/RPATH, GNU symbol versions required per library (DT_VERNEED) and defined (DT_VERDEF), defined dynamic symbols (SHT_DYNSYM) |
| `ar` archives (GNU and BSD long names, GNU symbol index) | every member classified, the symbol index; thin archives refused |
| Mach-O 64 (and universal, fat and fat64) | cputype, filetype, install name (LC_ID_DYLIB), every load dylib, LC_RPATH, LC_CODE_SIGNATURE present, platform and minimum OS (LC_BUILD_VERSION), external symbols |
| PE/COFF | machine, DLL or executable, imports and delay-load imports, the export directory's name and exported names; COFF objects; short import objects (MSVC's, llvm-dlltool's) and long-format import objects (MinGW's dlltool) with their DLL names |
| others | GNU linker scripts, Apple `.tbd` stubs, LLVM bitcode, unknown |

Reads are bounded (strings, commands, symbols, members) and a malformed
field is `{PM BINARY}` naming the offset; nothing is loaded or executed.
The driver's own archive check (`check_static_archive`) still judges every
archive again at the link: the package manager's reader exists because the
package manager runs without the native backend (the single-file compiler).

### What is checked

* **A bundled static library**: an ar archive whose every object member is
  the target's format and machine (an AArch64 member in a linux-x86_64
  archive is refused naming it: `pn-inspect-foreign-formats`), no import
  member (an import library declared static is refused: it would link a
  DLL nobody deploys: `pn-inspect-windows`), at least one object, declared
  symbols in its index.
* **A bundled shared library**: the target's format, machine and kind (ELF
  shared object, Mach-O dylib -- a universal file at the target's slice --
  or PE DLL); its loader identity equal to the declared one (soname,
  install name, the DLL's file name and export name); its loader
  dependencies exactly the declared `needs`; declared symbols exported; no
  musl for a glibc target; on Windows, its import library importing that
  DLL (`pn-bundled-checks`, `pn-inspect-windows`).
* **Every loader dependency resolves**: to the target's platform (glibc's
  own objects and libgcc_s; macOS's /usr/lib and /System/Library; Windows'
  system DLLs -- not VCRUNTIME, which is redistributed), or a library the
  application's packages declare; checked per package at packing and
  across the application at installation (`pn-missing-transitive-dependency`).
* **glibc's symbol versions**: a bundled library's highest required
  `GLIBC_x.y` is compared with the host's C library when the target is the
  host's, and reported as a requirement otherwise (`native plan`: "requires
  GLIBC_2.38 or newer"; SDL3 built here needs 2.38, this host has 2.39).
  **Inspected**: the comparison's refusal branch was not exercised by a
  binary that needs a newer glibc.
* **A system library** is verified only when the target is the host's, and
  only by system metadata: a pkg-config record in the distribution's
  directories (`/usr/lib/TRIPLET/pkgconfig`, `/usr/lib/pkgconfig`,
  `/usr/share/pkgconfig`) whose library directory holds the file, or the
  dpkg database owning the file (`/var/lib/dpkg/info/*.list`, its version
  from `/var/lib/dpkg/status`); the file found is then inspected (shared
  object of the target, soname, symbols) and the metadata's version
  compared with the request by its numbers. A file merely present in a
  library directory is refused as "not a system-managed installation":
  /usr/local's libpython3.so, with a pkg-config record of /usr/local's own,
  is refused (`pn-system-library-needs-system-metadata`), and zlib, owned
  by dpkg, is accepted with its version and symbols
  (`pn-system-library-verified`). For another target the plan says
  "unverified" and nothing is claimed (`pn-system-library-other-target`).
* **Source against metadata**: each package's own `extern c library`
  lines (a line scan: Botlish has no multi-line literal) are compared with
  its metadata: a `static` requirement against a shared library, a
  `static at` path against another bundled file, are refused naming both
  (`pn-source-metadata-contradiction`); a library linked by name that no
  metadata declares is noted as the linker's search, unverified.

### The application's native closure

Nested Botlish instances are separate modules but one process has one
loader namespace, so `pm::native::Plan` judges the whole view:

| case | outcome |
|---|---|
| one library, the same bytes from two instances | one library (`pn-native-conflicts`: same) |
| one name, different bundled bytes | refused, both digests named |
| one name, bundled in one instance, system in another; static and shared | refused (`origins` chooses where a package offers both) |
| two names, one loader identity | refused |
| two static archives defining one symbol (their indexes) | refused |
| a need nobody declares | refused (at packing, and across the application) |
| the consumer's `origins` naming a library no package offers | noted |

Different versions of one shared library on two branches are the "different
bytes" case: refused, never unified, and the Botlish instances stay distinct
(they do not have to agree for the source to compile; they do for the
process to load). Duplicate symbols between shared libraries and between a
shared library and a static archive are **not** checked (interposition
rules differ by platform; reported as a limitation).

### Verification is not

* proof of provenance: a bundled file is the bytes of an artifact whose
  digest a project or repository recorded; nothing says who built it, from
  what (PM-3, PM-5);
* proof of runtime identity of a system library: an operating-system update
  may replace it after installation; `verify -target T` checks it again;
* a guarantee of ABI compatibility: a version is compared with a request and
  identities and symbols with the binary; types and structure layouts are
  the binding generator's (C-BINDGEN.md), not checked here.

## E. Native deployment

### What a consumer receives

`botlish native plan [-target T]` (**Executed**) prints, from the view:

```
native plan for linux-x86_64 (this host), project /.../app
  library SDL3: bundled shared (instance sdlkit/sdl3)
    ELF x86-64 shared object; bundled file, sha256 1edd6d65d0ed
    /.../app/.bot_modules/.targets/linux-x86_64/sdlkit/.bot_modules/sdl3/native/libSDL3.so.0
    loads as libSDL3.so.0, needs libm.so.6, libc.so.6
    requires GLIBC_2.38 or newer on the target system
  library botlish_shim_sdl3_6de904a8: bundled static (instance sdlkit/sdl3)
    an ar archive of 1 ELF x86-64 object; bundled file, sha256 99d432a61945
    /.../.bot_modules/sdl3/native/libbotlish_shim_sdl3_6de904a8.a
link: the compiler links these from the target package tree (.bot_modules/.targets/linux-x86_64, its .lib): no -L is needed for bundled libraries
deploy: linux-x86_64's loader must find libSDL3.so.0 at run time:
  botlish native deploy -target linux-x86_64 -out DIR    places them in DIR/lib
  and link the executable with -runtime-path '$ORIGIN/lib' (the compiler's option), so it finds them wherever DIR is moved
  (a native backend's own run finds them in the target package tree without either)
```

* **Link inputs**: the view's `.lib` holds each bundled library under the
  name its linker searches (`libX.a`, `libX.so`, `libX.dylib`; `X.lib` or
  `libX.dll.a` import libraries on Windows) and a shared one also under its
  loader identity. The compiler records it (`nativeDirs`) and the driver
  searches it after `-L`'s: the source's `extern c library "SDL3"` finds the
  bundled SDL3 with no flag. Static archives declared `static at` keep their
  package-relative paths. The link plan is still the source's; metadata
  injects nothing.
* **Headers**: `native plan -include` prints `-IDIR` for every package's
  header directories (`pw-event-loop-runs` builds the application's own
  ticker against the event loop's installed header with it).
* **Runtime**: a native backend's run of a program compiled from a view
  gets the view's `.lib` as a runtime search path (an absolute RUNPATH in
  the temporary executable), so `-backend cranelift` runs with no
  LD_LIBRARY_PATH (`pw-sdlkit-runs`, `pw-raven-runs`). An emitted executable
  gets only what the builder asks: `-runtime-path PATH` (main.tcl;
  botlish-native's `--runtime-path`; GNU and Apple linkers:
  `-Wl,-rpath,PATH`, after the plan; refused on Windows, whose loader
  searches the executable's directory; a path with a comma, colon,
  semicolon or newline refused, since drivers and loaders split there:
  `runtime_paths_lower_per_linker`, `pn-runtime-path-option`).

### `native deploy`

`botlish native deploy -target T -out DIR` (pm/deploy.tcl) places every
bundled shared library of the plan under its loader identity: DIR/lib on
Linux and macOS (for `$ORIGIN/lib`, `@executable_path/lib`), DIR itself on
Windows (beside the executable: the application directory is the first
place Windows' loader searches; `PATH` is never relied on). It is a
transaction of its own: staged in `DIR/.botlish-deploy.txn`, recorded in
`DIR/.botlish-deploy.json` (each file's SHA-256); a file it did not place is
never replaced (`MANUAL`), one changed since it placed it only with `-force`
(`MODIFIED`); a failure at any step, or a crash and the next deploy, leaves
the previous deployment (`pn-deploy-ownership-and-faults`). Files are
placed with mode 0644: no loader of these targets needs an executable bit
on a library, and an artifact carries no mode at all.

### The relocatable application (Executed)

```
$ botlish add sdlkit -project app -repository repo
sdlkit 0.2.0 (sha256 b545297e6caa): installed
  sdl3 0.2.0 (sha256 5ec19d6757b0): installed
view linux-x86_64: derived (70 files, 2 native libraries)
$ SDL_VIDEO_DRIVER=dummy botlish -backend cranelift app/main.bot      (no -L, no LD_LIBRARY_PATH)
   value: [[true, true, true, true, true, true], true]
$ botlish native deploy -project app -target linux-x86_64 -out dist
deployed lib/libSDL3.so.0
$ botlish -emit-native-executable -runtime-path '$ORIGIN/lib' app/game.bot; mv app/game dist/
$ readelf -d dist/game | grep -E 'RUNPATH|SDL'
 (RUNPATH)  Library runpath: [$ORIGIN/lib]
 (NEEDED)   Shared library: [libSDL3.so.0]
$ mv dist /elsewhere/moved-dist; rm -rf app/.bot_modules
$ SDL_VIDEO_DRIVER=dummy /elsewhere/moved-dist/game
[[true, true, true, true, true, true], true]
```

The same sequence is `pw-sdlkit-deploy-relocates` (SDL3) and
`pn-deploy-relocatable` (a toy library: runs everywhere the native backend
does).

### macOS and Windows

* **macOS** (**Inspected**, real Mach-O from clang + lld): a dylib's install
  name must be `@rpath/...` to be relocatable; the plan notes an absolute
  one; a dylib without a code signature is noted as needing to be signed
  with the application (macOS arm64 loads only signed code); `native deploy`
  says so again. The package manager signs nothing and changes no hardened
  runtime setting: signing is the application builder's step
  (`pn-macos-deployment-requirements`). Frameworks are declared and
  system-provided only; a bundled `.framework` (a bundle that relies on
  symbolic links) cannot be represented in format 1 and no package needs one
  (section I).
* **Windows** (**Inspected**, real PE from MinGW-w64): DLLs, their import
  libraries and the import/static distinction are verified; deployment puts
  DLLs beside the executable; `-runtime-path` is refused. No Windows
  execution: the PM's own Windows behavior (PM-1's rename retries, links) is
  as unexecuted as PM-1 reported.
* **Android, iOS**: no target in the compiler's table; nothing done.

## F. Workloads

All from artifacts packed by `tools/package-repository.tcl` (the author's
side: it builds every declared target's native files and refuses to pack a
release missing one) into a fresh repository, installed into fresh
applications by the ordinary commands (`tests/package-workloads.test`,
14 tests, all **Executed** and passing).

| workload | install | compile | link | run | deploy |
|---|---|---|---|---|---|
| A. pure Botlish (`game2048` 1.0.0, schema 1) | no target, no view, no native step, no toolchain | interp, compile, cranelift | -- | the benchmark checksum | -- |
| B. sdlkit 0.2.0 + sdl3 0.2.0 (one release: linux-x86_64 and linux-aarch64 bindings, thunk archives, bundled x86-64 libSDL3.so.0, system SDL3 for AArch64 and as an x86-64 alternative) | sdl3 nested in sdlkit; the host view derived; `-target linux-aarch64` derives the second view from the installed release, the first untouched | x86-64 natively; linux-aarch64 front end (HIR of that target, the AArch64 binding's files) | x86-64: SDL3 and the shim from `.lib`, no -L | cranelift, cranelift-generic, headless: every step true | libSDL3.so.0 deployed, the executable relocated and run |
| B'. SDL3 from the system | `"origins": {"SDL3": "system"}` refused here: no distribution package or system pkg-config record of SDL3 on Ubuntu 24.04; nothing changed | -- | -- | -- | -- |
| B''. an SDL3 thunk | sdl3 directly | `sdl3::thunks::bits::SDL_MostSignificantBitIndex32(8)` | the prebuilt shim archive from `.lib`, no C compiler on the consumer's side | `3` | -- |
| E. Raven 0.2.0 (linux-x86_64 and linux-aarch64: bindings, bridge archives, bundled libraven.so.0 of each, built on the author's side -- AArch64's by Raven's CMake build with the GNU cross compiler) | with PATH emptied (no compiler, no ar); the view equals `tools/raven-package.tcl install`'s tree plus botlish.json and libraven | yes | bridge `static at` inside the instance, libraven from `.lib` | `examples/raven/headless.bot`: `["3", "3 clicks", "false", "0"]`, no LD_LIBRARY_PATH | possible (as B); not separately run |
| E'. Raven elsewhere | `-target linux-aarch64` ok, both its native files inspected as AArch64 ELF; `macos-aarch64`, `windows-x86_64` UNSUPPORTED | | | | |
| F. event_loop_linux 0.2.0 (archives for both Linux targets, public header) | yes; windows-x86_64 and macos-aarch64 UNSUPPORTED | yes | the driver's archive from the instance; the application's own `libticker.a` built against `native plan -include`'s directory | five ticks handled | -- (static) |

Icy Tower is unchanged: it stages its own SDL3 binding
(`tools/c-bindgen.tcl stage -package 1`) and was not moved onto the package
(its own builds and tests are untouched by this milestone).

## G. Tests and security

### Commands and outcomes (Executed)

Every command with `LANG=C.utf8 LC_ALL=C.utf8` and a private `-tmpdir`.

| command | result |
|---|---|
| `tclsh9.0 tests/package-native.test` | 39 tests, 39 passed (clang, lld, llvm-lipo and MinGW-w64 present: no test skipped) |
| `tclsh9.0 tests/package-workloads.test` | 14 tests, 14 passed |
| `tclsh9.0 tests/package-manager.test` | 74 tests, 74 passed (two expectations updated: schema 2 is now read; the no-program-run rule now admits the system's SHA-256 tool, in two procedures only) |
| regression files for the compiler change | all passed: `bot-modules.test` 56/56 (`bm-service-sources` expects the new `.targets` probe), `imports.test` 104/104, `application-modules.test` 21/21, `std-namespace.test` 36/36, `surface-modules.test` 37/37, `hir-cache.test` 19/19, `hir-interchange.test` 11/11, `compiler-service.test` 55/55, `lsp.test` 71/71, `main-cli.test` 64/64 (after shortening the new option's usage line, which its 80-column test caught), `compilation-isolation.test` 19/19, `native-link-plan.test` 34 passed and 3 skipped (macOS, Windows), `system-linker.test` 15/15, `compilerpedia.test` 42/42, `raven.test` 10 passed and 1 skipped (`ravenDesktop`), `event-loop-linux.test` 25/25 |
| `cargo test --release --manifest-path native/Cargo.toml --bin botlish-native -- runtime_paths link_plan system_link` | 17 passed (the new `runtime_paths_lower_per_linker` among them) |
| `tclsh9.0 audit/package-manager/tools/mutate.tcl` | 52 mutants (27 PM-1, 25 PM-2), 52 killed, after one survivor was closed (below) |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1149 topics, 701 examples run, 0 problems |
| `tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | exit 0 (census rows for the new and renamed tests, KEEP-INTERNAL) |

### The adversarial and regression list, case by case

| # | case | test |
|---|---|---|
| 1 | schema 1 compatibility | `pn-schema1-unchanged`, all of package-manager.test |
| 2 | schema 2 strictness, canonical form | `pn-schema2-canonical`, `pn-schema2-refusals` |
| 3 | one release, several targets | `pn-one-artifact-two-targets`, `pw-sdl3-two-targets` |
| 4 | missing and unsupported targets | `pn-unsupported-target`, `pn-unprepared-target-diagnostic`, `pw-raven-targets` |
| 5 | host/target mismatch in cross compilation | `pn-system-library-other-target`, `pw-sdl3-two-targets` (AArch64 system SDL3 unverified; AArch64 archives inspected, never taken for x86-64: `pn-inspect-foreign-formats`) |
| 6 | common and target file mapping | `pn-one-artifact-two-targets`, `pn-target-layout-problems` |
| 7 | collisions between common and target files | `pn-target-layout-problems` |
| 8 | native path traversal, invalid metadata | `pn-schema2-refusals` (`../up`), the archive path rules (PM-1's 43 adversarial archives) |
| 9 | A/B/A persistence | `pn-one-artifact-two-targets`, `pw-sdl3-two-targets` |
| 10 | concurrent target compilation | `pn-concurrent-target-compiles` |
| 11 | invalidation after updates | `pn-update-derives-every-view` |
| 12 | nested dependencies with different target support | `pn-unsupported-target` (outer supports all, geo one) |
| 13 | several versions on separate branches | `pn-two-versions-in-views` |
| 14 | archive architecture and format mismatches | `pn-inspect-foreign-formats`, `pn-bundled-checks` |
| 15 | static versus import library | `pn-inspect-windows` |
| 16 | shared-library architecture and identity mismatches | `pn-bundled-checks`, `pn-macos-deployment-requirements` |
| 17 | incompatible native requirements | `pn-native-conflicts` |
| 18 | missing transitive native dependencies | `pn-missing-transitive-dependency`, `pn-native-conflicts` |
| 19 | system library version/ABI | `pn-system-library-verified`, `pn-system-library-needs-system-metadata` |
| 20 | bundled integrity and deployment | `pn-deploy-*`, `pw-sdlkit-deploy-relocates` |
| 21 | loader paths and relocation | `pn-deploy-relocatable`, `pw-sdlkit-deploy-relocates`, `pn-runtime-path-option` |
| 22 | macOS signing and install names | `pn-macos-deployment-requirements` |
| 23 | Windows DLL deployment and search | `pn-inspect-windows`; deployment layout and the refused runtime path (**Inspected** only: no Windows host) |
| 24 | public header discovery | `pn-headers`, `pw-event-loop-runs` |
| 25 | prebuilt thunk archives | `pw-sdl3-thunk-archive` |
| 26 | recovery after failed projection | `pn-view-fault-rollback`, `pn-view-crash-recovery` |
| 27 | recovery after failed deployment | `pn-deploy-ownership-and-faults` |
| 28 | manual and editable packages | `pn-manual-and-editable-in-views`, `pn-hand-made-targets-refused` |
| 29 | cache and interchange | `pn-cache-and-interchange`, `bm-service-sources` |
| 30 | single-file compiler without the native backend | **Not executed in this milestone**: `pm/` is packed whole by `single/package.tcl` (unchanged list: `pm/`), `native` dispatches like the other package commands in `single/main.tcl`, and the package manager loads no compiler or backend; `single/build.sh` and its smoke tests were not rebuilt here |
| 31 | pure-Botlish packages unaffected | `pn-pure-packages-no-views`, `pw-pure-botlish-*` |
| 32 | hashing backends | `pn-sha256-backends-agree`, `pn-sha256-ignores-path`, `pn-sha256-forced-tool-missing`, PM-1's FIPS vectors |

### Mutation testing (Executed)

`audit/package-manager/tools/mutate.tcl` now runs, for each mutant, the
test files its `%%` line names. 25 new mutants of target selection, view
derivation and reuse, rollback, native classification (machine, import
libraries, identity, needs, musl), closure conflicts, system evidence and
versions, the source cross-check, packing, deployment ownership and
rollback, the compiler's tree rule, the runtime path and the hashing tool's
location, beside PM-1's 27 (one updated for schema 2's key list): the full run killed 51. The survivor,
`sha256-tool-from-path` (the tool looked up on PATH), was caught by the
design but not by the test: the known-answer probe refused the lying
`sha256sum` the test put first on PATH, so the digest stayed right. The
test now also asserts that the program never started; rerun alone, the
mutant is killed. The mutants of other harnesses whose text this milestone
changed were updated, keeping each a mutant of the same rule
(`audit/native-aot` `api-replaces-main-with-worker`,
`audit/single-executable` `package-commands-install-native`);
@@OTHERMUT@@

### Security boundaries

* **Nothing a package holds runs**, at packing, inspection, verification,
  installation, projection or deployment: native files are read as bytes.
  The only programs started are `kill -0` and the system's SHA-256 tool at
  its fixed path (`pm-no-network-in-sources` enforces both, procedure by
  procedure).
* **No metadata reaches a linker as a flag.** `.lib` files and the
  source's own declarations are the link; `-runtime-path` is the builder's.
* **Archive safety is PM-1's, unweakened**: regular files only, the same
  path rules and limits; a view writes only files the manager staged, each
  created exclusively, into directories it made.
* **Integrity only**: everything is checked against local records and the
  artifacts' own bytes. No publisher, upstream source or build is
  authenticated (sections I and J).

## H. Performance

`tclsh9.0 bench/package-manager.tcl` (medians; commands as child
processes, each including Tcl's start-up):

Measured while other test processes ran on the 4-core container (the
times are upper bounds; the ratios are what matter):

| measurement | time |
|---|---|
| read and validate a botlish.json (in process) | 0.18 ms |
| SHA-256 backend for large inputs | tool: /usr/bin/sha256sum |
| SHA-256 of 4 KiB: Tcl / tool | 4.4 ms / 2.5 ms |
| SHA-256 of 1 MiB: Tcl / tool | 1347.5 ms (0.7 MiB/s) / 5.2 ms (192 MiB/s, one process start included) |
| SHA-256 of 16 MiB / 64 MiB, tool | 47.4 ms (338 MiB/s) / 184.6 ms (347 MiB/s) |
| the SDL3 release (two targets, bundled libSDL3) | 1.5 MiB packed, 4.3 MiB unpacked |
| SHA-256 of that artifact (in process) | 4.1 ms (PM-1's Tcl hashing: about 1.9 s) |
| `package inspect` of it (full archive and target-layout validation) | 124.8 ms |
| `add sdlkit` (2 instances, the host's view derived and verified; fresh project) | 597.4 ms |
| `install`, unchanged tree and view (reused) | 104.1 ms |
| `install -target linux-aarch64` (a second view derived) | 201.3 ms |
| the same again (both views reused) | 103.2 ms |
| `verify` (record and views) | 97.4 ms |
| `verify -target linux-x86_64` (the native plan verified again) | 292.4 ms |
| `native plan` | 255.0 ms |
| `install` into a fresh copy of the project (offline) | 574.5 ms |
| `add` a pure-Botlish package (fresh project) | 26.4 ms |
| `install`, unchanged pure-Botlish tree | 18.1 ms |
| main.tcl with no arguments (no package command) | 7.5 ms |
| main.tcl -version (loads the compiler) | 129.7 ms |

PM-1 measured 21 ms for an unchanged `install` and 146 ms for `add sdlkit`
of one target's binding with no native file. A target-aware project's
unchanged `install` now costs about 100 ms: deciding that a view can be
reused reads every file of it (its CRC-32s) and the record's digest; a
pure-Botlish project's is unchanged (18 ms: no view exists). A fresh `add`
of the SDL3 release spends most of its 0.6 s copying the 3.4 MB bundled
library into the store, the view and `.lib`, and inspecting it.

* **Hashing.** PM-1 hashed in Tcl at 0.83 MiB/s (1.2 s per MiB); a
  native-sized package (SDL3's 1.5 MiB artifact) cost about 2 s to hash.
  The system's sha256sum, fed the exact bytes on a pipe, removes that cost;
  below 4 KiB the Tcl implementation is kept (a process start costs about
  1.5 ms, more than hashing a few kilobytes).
* **Views** copy the packages' files once per target (the SDL3 view is
  70 files); a repeated install with unchanged inputs reuses every view and
  reads no artifact.
* **Pure-Botlish packages** pay nothing new: no view, no inspection.

## I. Remaining limitations

### PM-2 defects or incomplete requirements

* **Not executed on macOS, Windows or Linux AArch64.** macOS and Windows
  facts were checked on real binaries made by cross toolchains, and
  AArch64's by compiling the front end for it; nothing ran there.
  Whatever the repository's CI reports for those hosts after this change is
  pushed is not part of this report's evidence.
* **The single-file compiler was not rebuilt** (`single/build.sh`), so its
  package commands' smoke test did not run with PM-2's code.
* **No repository package carries a macOS or Windows target**: there is no
  committed macOS or MSVC SDL3 or Raven binding (generating one needs that
  host's SDK), so "SDL3 for a second target" is linux-aarch64.
* **System verification exists for Linux only** (dpkg, pkg-config). macOS
  SDK frameworks and Windows system DLLs are recognized as platform
  libraries by name, not verified.
* **Duplicate symbols** are checked between static archives only.
* **Views are copies**: disk use grows with targets; hard links were not
  used (they would let an edit of a view file change the store).
* **A compilation of a target concurrent with a package operation that
  replaces that target's view** can observe a mix of trees (as PM-1's
  packages).
* **glibc's version refusal** is implemented and was not exercised by a
  binary needing a newer glibc than the host's.
* **Frameworks bundled by a package** cannot be represented (format 1 holds
  regular files only); a declarative reconstruction was not implemented
  because no package needs one.

### Intentional PM-3 authoring work

* `tools/package-repository.tcl` is still per-package code: assembling each
  target's directory, building thunk archives, bridges and libraries with
  the author's toolchains.
* No `botlish native add`/`audit`: metadata (identity, needs) is written by
  hand and only *checked*.
* No dependency-closure repair, redistribution-license audit, reproducible
  native builds or provenance records.

### PM-4 to PM-6

No registry, TUF, signatures, revocation, upstream history anchors or
transparency. The multi-target artifact is the unit they will sign and
distribute unchanged.

## J. PM-3 preparation

What the real packages showed a generic authoring workflow needs:

1. **Binary import**: `pm/binary.tcl` already reads every fact the metadata
   states; `native add FILE -target T` can draft the library entry
   (identity, needs, symbols) instead of a person writing it.
2. **Closure inspection**: the same reader lists each bundled library's
   needs against the platform list and the package's declarations; PM-3
   classifies the rest as bundle, system or unresolved (blocking
   publication).
3. **Target artifact preparation**: the per-package recipes (generated
   binding staging, `c-bindgen build` for thunks, bridge archives, cross
   CMake builds) are the inputs a declarative author-side step would run in
   the author's environment, never the consumer's.
4. **Provenance recording**: each native file's digest is known at packing;
   PM-3 adds where it came from (source revision, toolchain, flags) as a
   record over the artifact's digest, never inside the files it describes.
5. **Safe release packaging**: packing already refuses a release missing a
   declared target's files, and is deterministic (repacking SDL3 gives the
   same digest); a release check could also run the consumer's view
   derivation for every declared target before publishing.

## Repository changes

* `pm/`: new `target.tcl` (the compiler's target names, read as data),
  `binary.tcl` (native file inspection), `targets.tcl` (schema 2's targets,
  views' file mapping, layout rules), `native.tcl` (verification, system
  evidence, the closure, the plan), `view.tcl` (target views), `deploy.tcl`
  (deployment transactions); `descriptor.tcl` (schema 2), `state.tcl`
  (views in the record, schema 2), `install.tcl` (views in the transaction,
  kinds in the journal, `TidyViews`), `catalog.tcl` (target layout checked
  at acquisition), `commands.tcl` (`-target`, `-drop-target`, `native
  inspect|plan|deploy`, `package inspect -target`, pack's native checks),
  `sha256.tcl` (the system's tool), `pm.tcl`.
* Compiler: `surface/modules.tcl` (`ApplicationTree`: target package trees,
  `nativeDirs`), `hir/interchange.tcl` (`nativeDirs` validated),
  `native/native.tcl` (`nativeDirs` searched and, for runs, a runtime path;
  `runtimePaths`), `native/src/codegen/aot.rs` and `native/src/main.rs`
  (`--runtime-path`), `main.tcl` (`-runtime-path`, the `native` command
  word), `single/main.tcl` (`native` dispatched like the package commands).
* Packages: `packages/sdl3`, `sdlkit`, `raven`, `event_loop_linux`
  descriptors (0.2.0; schema 2 for the three native ones) and READMEs;
  `tools/package-repository.tcl` (assembles every declared target).
* Tests: `tests/package-native.test` (new), `tests/package-workloads.test`
  (rewritten for PM-2), `tests/package-manager.test` and
  `tests/bot-modules.test` (expectations); census rows and the regenerated
  `tests/golden/manifest.tsv`.
* Audit and benchmark: `audit/package-manager/tools/mutate.tcl` (`%%` test
  files per mutant) and `mutants.txt` (52 mutants);
  `bench/package-manager.tcl`.
* Documentation: this report, BOTLISH-JSON.md (schema 2), BOTPKG-FORMAT.md,
  BOT-MODULES-MILESTONE-1.md ("Target package trees"), `docs/INDEX.md`,
  `AGENTS.md` ("The package manager"), Compilerpedia (`cli.packages`,
  `cli.options`, `rule.package-modules`).
