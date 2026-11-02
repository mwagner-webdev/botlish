# PM-3: generic native package authoring, dependency audits and reproducible release evidence

A package author now turns finished native build outputs into a Botlish
release with the package manager's own commands, whatever built them:

```
botlish package stage -target linux-x86_64 -modules build/gen/raven      # the generated binding
botlish native add build/libraven_bridge.a -target linux-x86_64 -name raven_bridge
botlish native add build/libraven.so.0 -target linux-x86_64 -name raven -symbol Rinit_ex \
    -license "Apache-2.0 AND OFL-1.1 AND (MIT OR Unlicense)" -notice licenses/raven/LICENSE ...
botlish native require X11 -target linux-x86_64 -origin system -identity libX11.so.6
botlish native require vulkan -target linux-x86_64 -runtime capability -capability desktop \
    -identity libvulkan.so.1 -loaded-by raven -purpose "the Vulkan loader, opened by the renderer"
botlish native audit
botlish package pack -out repo -evidence evidence.json      # raven-0.3.2.botpkg + raven-0.3.2.provenance.json
```

`native add` reads every fact a file can establish (format, architecture,
loader identity, loader dependencies, exports, RUNPATH) from its bytes and
writes it into botlish.json; `native require` records what only the author
knows (which dependencies the system provides, what the code opens at run
time); `native audit` judges each target's native closure; `package pack`
refuses an incomplete one and, given the author's evidence, writes an
unsigned provenance record bound to the artifact's SHA-256. SDL3, Raven and
the Linux event-loop adapter are released this way; their recipes keep only
their builds and their authors' statements. The 0.3.1 cross-machine
difference of Raven was traced to one RUNPATH string, fixed, and the
releases now reproduce byte for byte in two independently initialized
builds of a pinned author image.

This is milestone PM-3 of PACKAGE-ECOSYSTEM-ROADMAP.md. The normative
formats are BOTLISH-JSON.md section 13 (schema 3) and BOTPKG-PROVENANCE.md
(provenance records and evidence, format 1); BOTPKG-FORMAT.md is unchanged.

Every claim is marked **Executed** (run here, its output read),
**Inspected** (read from code or bytes without running the claim end to
end) or **Not done**. Everything executed ran on one Linux x86-64 container
(Ubuntu 24.04.5, glibc 2.39, Tcl 9.0.1, GCC 13.3.0, clang 18, the Ubuntu GNU
AArch64 cross compiler, MinGW-w64, Docker 29.9.2), 2026-11-02, except where
GitHub's runners are named.

Contents:

* [0. Inventory: what the recipes did before](#0-inventory-what-the-recipes-did-before)
* [A. Result](#a-result)
* [B. Previous authoring architecture](#b-previous-authoring-architecture)
* [C. CLI and format](#c-cli-and-format)
* [D. Native dependency auditing](#d-native-dependency-auditing)
* [E. Release validation](#e-release-validation)
* [F. Provenance](#f-provenance)
* [G. Reproducibility investigation](#g-reproducibility-investigation)
* [H. Real-package results](#h-real-package-results)
* [I. Clean-room regression](#i-clean-room-regression)
* [J. Security and tests](#j-security-and-tests)
* [K. Performance](#k-performance)
* [L. Remaining limitations](#l-remaining-limitations)
* [M. PM-4 preparation](#m-pm-4-preparation)
* [What to run when changing this](#what-to-run-when-changing-this)
* [Repository changes](#repository-changes)

## 0. Inventory: what the recipes did before

Written from `tools/package-repository.tcl` as PM-2 and the Raven clean
room left it (335 lines), before anything changed. Its three activities
were interleaved in one `switch` arm per package:

| activity | sdl3 | raven | event_loop_linux |
|---|---|---|---|
| **1. building external native libraries** | `tests/cffi/sdl3.tcl` (CMake, headless) for x86-64; strip | `tests/cffi/raven.tcl desktop` for the host; a CMake cross build with the GNU AArch64 compiler and pinned arm64 libX11 `.deb`s; strip | -- |
| **2. generating bindings and bridges** | the committed binding (`generated/c/sdl3/T`); thunk archives by `tools/c-bindgen.tcl build` | the committed binding; the event bridge compiled per target | the adapter compiled per target |
| **3. assembling and validating packages** | `file copy` of the binding into `targets/T/sdl3`; archives and the stripped library copied into `targets/T/native`; **metadata hand-written** in packages/sdl3/botlish.json (identity, needs, symbols, the system alternative) | the same, plus `checkDesktop` (a raven-only check of needs and one symbol); **metadata hand-written** (needs, symbols, system X11); Vulkan nowhere | the archive copied; the header a common file, `headers` hand-written |
| packing | `pm::commands::pack` in process | the same | the same |
| provenance | none | none | none |
| release identity | an existing different file refused (`EXISTS`) in one OUT; nothing across machines | the same | the same |

Activity 3 -- every copy into a target directory, every metadata fact,
the desktop check, the pack call -- is what PM-3 generalizes. Activities 1
and 2 stay in the recipe (they are each package's own).

## A. Result

| capability | status |
|---|---|
| `native add FILE -target T -name N`: a built library imported, its facts read from the file (ELF, ar, Mach-O, PE/COFF; a DLL with `-import`), placed at a deterministic path, botlish.json written; idempotent; differing bytes or contradicting metadata a CONFLICT unless `-replace` | **Executed** (`pa-add-*`: 7 tests, real binaries from GCC, clang+lld and MinGW-w64) |
| refusals of what is no library: another architecture, an object file, no soname, a thin archive, a linker script, LLVM bitcode, a truncated file, a wrong `-linkage`, a declared symbol not exported, an import library alone | **Executed** (`pa-add-refusals`, `pa-add-windows`) |
| nothing imported is run (a constructor that would write a marker; an executable script named like a library) | **Executed** (`pa-add-never-runs`) |
| `native require`: a system library (verified on its own host by system metadata, as an observation never recorded as a requirement), or a run-time dependency (schema 3) | **Executed** (`pa-require-*`) |
| run-time dependencies never mandatory: a package whose "always" run-time library no system has installs, `native plan` lists it apart | **Executed** (`pa-runtime-never-mandatory`; Raven's Vulkan: `pw-raven-runtime-dependencies`) |
| `package stage -modules\|-headers\|-files`: deterministic paths, links refused, hidden files skipped, `-replace` makes a directory exactly its source | **Executed** (`pa-stage-*`) |
| `native audit`: complete / partially verified / incomplete per target; closure, RUNPATH, undeclared binaries, platform libraries bundled, duplicate identities and symbols, the source's links and C functions, one module set across targets | **Executed** (`pa-audit-*`, 5 tests) |
| `package pack` refuses an incomplete native package; a pure-Botlish package takes PM-1's path | **Executed** (`pa-pack-refuses-incomplete`) |
| schema 3 (`runtime`, `license`, `notices`), strict; schemas 1 and 2 byte for byte as before; schema raised only as needed | **Executed** (`pa-schema3`, `pa-schema-raised-only-when-needed`, PM-2's `pn-schema*`) |
| the failed-system-library cascade fixed: one diagnostic naming the instance | **Executed** (`pa-failed-system-library-one-diagnostic`) |
| provenance records: bound to the artifact's SHA-256, computed facts / assertions / checks apart, Git trees recomputed without git, host paths and credentials refused, canonical and deterministic | **Executed** (`pa-provenance-*`, 4 tests; the real releases' records) |
| `package compare`: identical or how two candidates differ (ELF sections, RUNPATH, build ID, archive members, ZIP-only) | **Executed** (`pa-compare*`; the 0.3.1 pair, section G) |
| `package inspect`: schema, run-time dependencies, licenses, bindings, each target's closure status, `-provenance` | **Executed** |
| SDL3/sdlkit, Raven, the event loop authored through the generic commands; `packages/*/botlish.json` hold no native metadata | **Executed** (section H; `pw-native-metadata-derived`) |
| the 0.3.1 discrepancy explained: an AArch64 RUNPATH holding the build machine's cache path | **Executed** (section G) |
| a pinned author image; two independently initialized builds byte-identical (artifacts and records), equal to the host's | **Executed** here (section G); on two GitHub runners: see section G's CI line |
| release ledger: one version, one artifact; a rebuild that does not reproduce is a CANDIDATE, refused with `-release` | **Executed** (`pw-release-ledger`) |
| the single-file compiler authors a native package with no compiler and no native backend installed | **Executed** (`single/smoke-test.sh`'s new check) |
| the clean room with raven 0.3.2: install, headless example, a real X11/Vulkan window driven through the X server, a relocated executable | **Executed**: 33 of 33 checks (section I) |

Releases made by this milestone (each the identical artifact of two fresh
builds in the pinned image; recorded in `packages/RELEASES.tsv`):

| release | SHA-256 | schema | targets |
|---|---|---|---|
| `sdl3-0.2.1.botpkg` | `d4c2d1df5ecc51906309b7352b5d301bf46f914e562c6c08702fe7afce8c6f37` | 2 | linux-aarch64, linux-x86_64 |
| `sdlkit-0.2.1.botpkg` | `2492c596f167ec529e781afa40530b3735ea38c28b675bf951fa106581b439e9` | 1 | every target |
| `raven-0.3.2.botpkg` | `9d94f18733ce2e0b8019abaa2b7810f5e2351699469ca27b2b7af7e38af6007b` | 3 | linux-aarch64, linux-x86_64 |
| `event_loop_linux-0.3.0.botpkg` | `3746cece124b660fa03bf018271e4d5bc6d25f2bf684da84bc9fd621a2bc453c` | 2 | linux-aarch64, linux-x86_64 |

Their provenance records, from the final pair of builds (commit d80d5d6):
`sdl3-0.2.1.provenance.json` sha256 `ff4e7b882f41...`,
`raven-0.3.2.provenance.json` `500dd14764b1...`,
`event_loop_linux-0.3.0.provenance.json` `a6aff034158d...` (identical in
both builds). A record names the environment and the commit it was made
from: the records of the earlier pair (commit bb99687: `634b2ae4...`,
`0b3ff0b9...`, `fc44cc57...`) differ from these in exactly three fields --
the image line (the Dockerfile changed between them), the generators'
`version` (the commit) and `producer.sources-sha256` (the package
manager's sources) -- and in nothing about the artifacts.

## B. Previous authoring architecture

What each recipe is responsible for, before and after:

| responsibility | PM-2 (`tools/package-repository.tcl`, per-package `switch` arms) | PM-3 |
|---|---|---|
| package directory assembly | copy of packages/NAME | the same one copy (`author::prepare`), then generic commands |
| target directories | `file copy` of each binding into `targets/T/NAME` | `botlish package stage -target T -modules DIR` |
| native files into the package | `copyStripped`, `file copy` into `targets/T/native` | the recipe strips into its own build directory (a build step); `botlish native add` places the file |
| native metadata | hand-written in packages/sdl3, raven, event_loop_linux/botlish.json: identities, needs, symbols, files | derived from each file by `native add`; the author's statements by `native require`; packages/*/botlish.json hold only name, version and dependencies |
| header staging | a common `native/` directory and a hand-written `headers` | `botlish package stage -target T -headers FILE` (each target's `include/`) |
| the desktop check | `checkDesktop`, raven-specific code | the required symbol `Rvulkan_get_instance`, checked by `native add` (generic) |
| closure verification | pack's PM-2 checks | the same, then `native audit` (also run by pack) |
| packing | `pm::commands::pack` in process | `botlish package pack DIR -evidence FILE` (the CLI an author uses) |
| provenance | none | the recipe writes its evidence (sources with their Git identities, builds, toolchains, generators); pack writes and checks the record |
| licenses | none | `native add -license -notice`; Raven's license files staged (`package stage -files`) |
| release identity across machines | none | `packages/RELEASES.tsv`, `-release` |

What remains per package (`author::sdl3`, `author::raven`,
`author::event_loop_linux`): fetching the pinned sources, building
(CMake for SDL3 and Raven, the cross builds, the bridges and the thunks),
and stating facts no file holds (SDL3's system alternative, X11, Raven's
run-time dependencies and license). The file grew (335 to 642 lines)
because it now records what it ran as evidence: sources, toolchain
versions, flags with host paths replaced by named roots, binary inputs.

## C. CLI and format

### Commands (all through `botlish`; `tclsh9.0 main.tcl` in a checkout)

```
botlish native add FILE -target T -name N [-linkage static|shared] [-as PATH]
                   [-import FILE] [-symbol S]... [-license EXPR] [-notice PATH]...
                   [-replace] [-package DIR]
botlish native require NAME -target T -origin system [-linkage L] [-identity I]
                   [-version V] [-pkg-config M] [-symbol S]... [-replace] [-package DIR]
botlish native require NAME -target T -runtime always|capability|optional -purpose TEXT
                   [-capability C] [-identity I] [-kind library|facility] [-loaded-by LIB]
botlish package stage [DIR] -target T... -modules|-headers|-files SRC [-as PATH] [-replace]
botlish native audit [DIR] [-target T]
botlish package pack [DIR] [-out DIR] [-force] [-evidence FILE]
botlish package inspect FILE.botpkg [-target T] [-provenance FILE]
botlish package compare A.botpkg B.botpkg [-provenance A.json -provenance B.json]
```

The package directory is the current one, `-package DIR`, or (stage,
audit) `DIR`. Exit status 0, 1 (an operation failed; `native audit` an
incomplete package; `package compare` two different candidates), 2 (usage).

### `native add`

* **What the file says, the metadata says.** The file is inspected by
  `pm/binary.tcl` (no execution, no loading): an ar archive of the target's
  objects is a static library (its index the exports), an ELF shared object
  / Mach-O dylib (a universal file's slice) / PE DLL a shared one, with its
  loader identity (soname, install name, export name), its loader
  dependencies exactly (DT_NEEDED, LC_LOAD_DYLIB, imports) and its exports.
  `-linkage` is only checked against that. The entry is then checked by
  PM-2's `CheckBundled` -- the pack's own check -- before anything is
  written.
* **What it cannot say, the author says, or nobody.** `-name` is required:
  the library's name as the package's `extern c library "N"` writes it is
  never read from a file name. Required symbols are only those `-symbol`
  names (never every export); `-license`/`-notice` are statements. The
  report ends with what the file did not establish.
* **Destinations**: `targets/T/native/` (or the target's own `files`
  directory) and the name a loader asks for (a shared library's identity's
  file name) or a linker searches for (`libN.a`, `N.lib`; a DLL's import
  library under `-import`): `libraven.so.0`, `libraven_bridge.a`. `-as`
  chooses another view path. The bytes are copied exactly.
* **Repeat and replace**: the same file and statements again is
  `(unchanged)`; different bytes at the destination, a derived fact that
  differs from the declaration (identity, needs, file, linkage), a
  statement that changes an earlier one, or another library's file at the
  destination are `CONFLICT` (nothing written) unless `-replace`. A
  statement made where none was (a first `-license`) is an addition.
* A named file that is a symbolic link is followed and the report says so
  (an author names their build's `libX.so.0`, often a link); a link inside
  a staged directory is refused.

### `native require`

`-origin system` declares the target's own library (schema 2's system
entry). On its own host it is verified as PM-2 verifies one at installation
(the distribution's metadata, then the file) and the result is shown as an
observation of this machine -- `-version` is the only version requirement
ever written. For another target it says it cannot be verified here.

`-runtime` declares a run-time dependency (section D, schema 3): `-kind
library` (default with `-identity`) or `facility`, its requirement, its
capability, the library that opens it, its purpose.

### `package stage`

| kind | source | destination | rule |
|---|---|---|---|
| `-modules` | a directory (its name the namespace) or a `.bot` file | `targets/T/NAME/` | only `.bot` files, all inside the package's namespace |
| `-headers` | a directory or a header file | `targets/T/include/` (or `-as`), declared in `targets.T.headers` | only C headers (`.h .hh .hpp .hxx .inc .inl .def`) |
| `-files` | a directory or a file | `-as DIR`, in the target's directory or (no `-target`) common | never into a target's directory as a common file |

A directory staged is the destination's exact contents: a differing
destination is a CONFLICT unless `-replace`, which then also removes files
the source no longer has (a stale module of an older binding). A single file
is staged as that file, so several go into one directory. Links, devices and
names an archive cannot hold are refused; hidden entries are skipped and
counted. The layout the package would have is checked (PM-2's target rules)
before anything is written.

### botlish.json schema 3

BOTLISH-JSON.md section 13 is normative. A target gains `runtime`; a
bundled library gains `license` (an SPDX expression) and `notices` (files
of the view). Schema 3 is otherwise schema 2; a schema 2 file using a
schema 3 key is refused naming it; PM-2's reader refuses schema 3 as
unsupported, so no older reader half-reads it. Schemas 1 and 2 read and
write as before, byte for byte (`pn-schema1-unchanged`, `pa-schema3`).
The commands raise a package's schema only to what its contents need
(`pa-schema-raised-only-when-needed`): sdl3 0.2.1 and event_loop_linux
0.3.0 are schema 2, raven 0.3.2 schema 3, sdlkit schema 1.

### An author's workflow, from built files to a release

This is the whole of what an author does, with nothing of this repository's
recipes; **Executed** exactly as written (a script in a fresh directory,
2026-11-02). The package `greet` wraps a C library for two targets.

**0. Build with your own tools** (here GCC, the GNU AArch64 cross compiler
and ar; CMake or anything else is the same to Botlish):

```sh
cc -O2 -fPIC -c src/greet.c -o build/x86_64/greet.o && ar rcs build/x86_64/libgreet.a build/x86_64/greet.o
aarch64-linux-gnu-gcc -O2 -fPIC -c src/greet.c -o build/aarch64/greet.o
aarch64-linux-gnu-ar rcs build/aarch64/libgreet.a build/aarch64/greet.o
cc -O2 -shared -fPIC -Wl,-soname,libgreetcore.so.1 -o build/x86_64/libgreetcore.so.1 src/core.c -lz
```

**The package directory**: a `botlish.json` naming the package and its
version, and its own modules (`greet.bot`: `extern c library "greet"`,
`import greet::answer`, ...). Run the commands in it.

```sh
mkdir greet && cd greet
printf '{"schema": 1, "name": "greet", "version": "1.0.0"}\n' > botlish.json
```

**1. A simple static archive**, one per target -- its facts read from the
file, placed at `targets/T/native/libgreet.a`:

```sh
botlish native add ../build/x86_64/libgreet.a -target linux-x86_64 -name greet -license MIT
botlish native add ../build/aarch64/libgreet.a -target linux-aarch64 -name greet -license MIT
```

**2. A bundled shared library** -- its loader identity and loader
dependencies from the file; a required symbol checked against its exports:

```sh
botlish native add ../build/x86_64/libgreetcore.so.1 -target linux-x86_64 -name greetcore -symbol greet_crc -license MIT
#   loader identity libgreetcore.so.1; needs libz.so.1, libc.so.6
#   unresolved: it needs libz.so.1, which no library of linux-x86_64 declares ...: native require NAME ... -identity libz.so.1
```

**3. A system native dependency** -- what the file cannot say, the author
does; on this host it is checked by the distribution's metadata:

```sh
botlish native require z -target linux-x86_64 -origin system -identity libz.so.1
#   this host: /usr/lib/x86_64-linux-gnu/libz.so.1, dpkg package zlib1g:amd64, version 1:1.3.dfsg-3.1ubuntu2.3
#     (an observation of this machine, never recorded as a requirement ...)
```

**4. A library with public headers** -- each target's `include/`,
declared for consumers' `botlish native plan -include`:

```sh
botlish package stage -target linux-x86_64 -target linux-aarch64 -headers ../include
```

**5. A multi-target binding package** -- each target's generated modules
at the package's namespace (here `greet/answer.bot`):

```sh
botlish package stage -target linux-x86_64 -modules ../gen/linux-x86_64/greet
botlish package stage -target linux-aarch64 -modules ../gen/linux-aarch64/greet
```

**6. An optional run-time-loaded dependency** -- never part of the link or
of an installation's checks:

```sh
botlish native require compress -target linux-x86_64 -runtime optional -identity libzstd.so.1 \
    -loaded-by greetcore -purpose "opened when a program asks for zstd compression"
```

**Audit, pack, inspect**:

```sh
botlish native audit
#   target linux-aarch64: complete ... target linux-x86_64: complete
#   greetcore              needs libz.so.1                system (z)
#   run-time library compress (libzstd.so.1): optional, loaded by greetcore -- ...
botlish package pack -out ../repo -evidence ../evidence.json
#   packed greet 1.0.0: ../repo/greet-1.0.0.botpkg
#   provenance ../repo/greet-1.0.0.provenance.json (...; bound to the artifact's sha256 ...; unsigned)
botlish package inspect ../repo/greet-1.0.0.botpkg -provenance ../repo/greet-1.0.0.provenance.json
```

`evidence.json` is optional: what the author states about the build (for
example `{"evidence": 1, "builds": [{"name": "greet x86-64", "targets":
["linux-x86_64"], "outputs": ["targets/linux-x86_64/native/"], "toolchain":
{"cc": "gcc 13.3.0"}, "flags": ["-O2", "-fPIC"]}]}`; BOTPKG-PROVENANCE.md).
Repeating any command with the same input changes nothing; a different
input is a CONFLICT until `-replace`. A consumer then runs `botlish add
greet -repository repo` (PM-1, PM-2): nothing of the above runs on their
machine.

## D. Native dependency auditing

`botlish native audit` (`pm::author::Audit`, over the package's files as
they would be packed: the same code audits a package directory, a pack and
an artifact's files in `package inspect`) reports per target:

* each library: origin, linkage, format and machine, file and SHA-256,
  loader identity, glibc requirement, license, and whether the metadata is
  as the file says;
* every loader dependency of every bundled shared library, classified:
  **the platform's** (the target's own C library, loader and libgcc_s; PM-2's
  list), **bundled** (by a library of the package with that identity),
  **system** (a declared system library), or **UNRESOLVED**;
* the C functions the package's modules declare (`extern c fn NAME [named
  "SYMBOL"]`), by which kind of library exports them;
* run-time dependencies, with what can be established without running
  anything (below);
* problems, unverified facts and notes.

**Statuses.** *complete*: every mandatory dependency accounted for, every
check that can run here passed. *partially verified*: the metadata is
complete, and facts this host cannot check remain -- another target's
system libraries, a system library this machine lacks, C functions
expected from such a library or another target's platform. *incomplete*:
any problem. The partially verified status is never reported as complete,
and a cross-target system library is never reported missing.

**Problems** (blocking): an unresolved loader dependency; a declared fact
the file contradicts (identity, needs, linkage, symbols, kind, machine);
a bundled library that is a platform library; **a RUNPATH/RPATH entry that
is absolute (the build machine's directory) or empty (the current
directory)** -- `$ORIGIN`, `@loader_path`, `@executable_path`, `@rpath`
entries are noted; two libraries with one loader identity; two static
archives defining one symbol; a native binary (by its magic bytes) no
library declares; a module set that differs between targets; a library
the source links (`extern c library`) that no metadata declares (platform
link names such as `m` excepted); a static requirement or archive path the
metadata contradicts; on the host target, a declared C function no
library exports (bundled, verified system or the platform's own C library,
read from this host). **Notes**: a bundled library with no license, a
library nothing links or needs, a redundant platform declaration, relative
search paths.

**Drafting.** An unresolved need is reported with the command that would
resolve it (`native require NAME -origin system -identity NEED`, or `native
add` its file); `native require` without `-identity` names the bundled
libraries that need a matching identity. Nothing is classified silently:
which origin a dependency has is the author's decision.

**Run-time dependencies** are never in the closure: never a problem, never
a reason a status changes. For each the audit (and `native require`, and
`native plan` at the consumer's) reports: for a library opened by name,
whether its identity's string occurs in the bytes of the library declared
to open it (`statically consistent ... not a proof that it is opened`, or
`not found statically`); on its own host, whether the system has a
candidate (its dpkg or pkg-config record, then the file), "an observation
of this machine, not a promise about a consumer's"; a facility is reported
as unverifiable from any file.

**Raven's X11 and Vulkan** (**Executed**, the release's own audit and plan):

| dependency | how it is loaded | metadata | at installation | `native plan` |
|---|---|---|---|---|
| `libX11.so.6` | libraven's DT_NEEDED: the loader loads it with libraven | system library `X11` | verified by the distribution's metadata on the host (dpkg `libx11-6` in the clean room); missing: one diagnostic, nothing installed | `library X11: system shared ... dpkg package libx11-6` |
| `libvulkan.so.1` | `dlopen`ed by Raven's renderer (vk_loader.c) when a program starts `raven::desktop()` | run time, capability `desktop`, loaded by raven | never required | `library vulkan (libvulkan.so.1): needed for "desktop" ... this host: /usr/lib/x86_64-linux-gnu/libvulkan.so.1 (dpkg package libvulkan1 ...) -- a candidate` |
| a Vulkan driver (ICD) | found by the loader | run time, facility, capability `desktop` | never required | `not a file: the package manager cannot verify it` |
| an X11 display | -- | run time, facility, capability `desktop` | never required | the same |
| `libX11-xcb.so.1` | `dlopen`ed only for a driver that presents through XCB alone (vk_surface.c) | run time, optional | never required | listed |
| `libdbus-1.so.3` | `dlopen`ed by the AT-SPI bridge (atspi.c) when accessibility is enabled | run time, capability `accessibility` | never required | listed |

Headless Raven installs and runs with none of the run-time dependencies
(the clean room's headless checks; `pa-runtime-never-mandatory` with a
library no system has). The statically consistent check found
`libvulkan.so.1`, `libX11-xcb.so.1` and `libdbus-1.so.3` in libraven's
bytes on both targets.

**Known verification limits**: system libraries are verified on Linux only
(PM-2); run-time dependencies are statements (the string check is
consistency, not proof); duplicate symbols are compared between static
archives only; the C-function check reads the host's platform libraries
only for the host's target; licenses are statements, never checked
against the code.

### The failed-system-library cascade

PM-2's plan, when a declared system library failed verification, dropped
the declaration and then reported the bundled library's need of it as
undeclared -- telling a consumer to declare what the package declares
(RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, section I). The plan now keeps a
failed declaration's identity (or, for one declared without an identity,
its conventional `libNAME.so.N` names) as a *failed provider*: the need is
not reported again, and the one diagnostic names the instance:

```
error: ...
  system library zzghost (libzzghost.so.3 or libzzghost.so) is not installed in linux-x86_64's
  system library directories (...) (declared by instance needy) (PM NATIVE)
```

(`pa-failed-system-library-one-diagnostic`: one line, no "neither part of
linux-x86_64's platform"; PM-2's `pn-native-conflicts` and
`pn-system-library-needs-system-metadata` expect the instance now.) An
undeclared need is still reported (`pa-audit-statuses`).

## E. Release validation

`package pack` of a package, in order (the pack fails at the first stage
with problems, and writes nothing):

1. botlish.json read as a package being packed: name, exact version, every
   direct dependency locked, strict schema (PM-1);
2. the files collected: regular files only, portable names, no collisions
   (PM-1);
3. a target-aware package: the target layout (every target's directory
   holds files, none nested, no target file replacing a common one or
   botlish.json, every library file, import library, header directory and
   notice present: PM-2 and section 13);
4. every bundled file checked against its declaration, and every bundled
   library's need resolved within the package (PM-2's gate, unchanged);
5. the native audit (section D): an incomplete target refuses the pack,
   every problem listed; partially verified targets pack, the count of
   unverifiable facts printed;
6. the evidence read and validated (`-evidence`; BOTPKG-PROVENANCE.md
   section 2), the record made and every check run -- a contradicted
   assertion refuses the pack;
7. the archive written by the deterministic writer and read back by the
   validating reader (PM-1): format 1's limits hold;
8. an existing different `NAME-VERSION.botpkg`, or a record of another
   artifact, refused (`EXISTS`) unless `-force`.

A pure-Botlish package goes from 2 to 7 (no audit, no native output:
`pa-pack-refuses-incomplete`'s second half). An artifact made some other
way is still checked by the consumer: PM-2's installation checks are
unchanged (`pn-source-metadata-contradiction` now packs its contradictory
fixture raw to show it).

The acceptance requirement, case by case (**Executed**): a missing bridge
archive -- a declared file absent from the view (layout problem);
`pa-target-layout-problems`. A wrong-target library -- `pa-add-refusals`,
`pn-bundled-checks`. An inconsistent loader identity -- `pa-add-conflicts`,
`pn-bundled-checks`. An unresolved mandatory dependency --
`pa-pack-refuses-incomplete`. An unused native file -- `pa-audit-native-
closure-errors` (an undeclared binary). An omitted target binding --
`pa-audit-source-and-api` (a target lacking another's module).

## F. Provenance

### The record

BOTPKG-PROVENANCE.md is normative. The complete record of
`event_loop_linux-0.3.0.botpkg`, as both pinned builds wrote it:

```json
{
  "provenance": 1,
  "subject": {
    "name": "event_loop_linux",
    "version": "0.3.0",
    "artifact": "event_loop_linux-0.3.0.botpkg",
    "sha256": "3746cece124b660fa03bf018271e4d5bc6d25f2bf684da84bc9fd621a2bc453c",
    "size": 33589,
    "format": 1,
    "schema": 2,
    "targets": ["linux-aarch64", "linux-x86_64"]
  },
  "producer": {
    "tool": "botlish package manager",
    "sources-sha256": "f0b3c3f94c99604f46d33d7c2ebca5f95ff513107702a8fc4fecc079b36b9f15"
  },
  "contents": [
    {"path": "README.md", "size": 1912, "sha256": "295452af7d62704ba1e60d74ba5837dcb8bddbc8b0fb31ac9f0d8d8987f00160"},
    {"path": "botlish.json", "size": 737, "sha256": "87c624edbb73bb3fac2607cf6456e18d28c3baef2f4266bb0e7098ef0511e265"},
    {"path": "event_loop_linux.bot", "size": 10233, "sha256": "0abdf8f9ce217acd6625d2e56aabdc5368cb79251cdda4f868ba4a3281fb3a60"},
    {"path": "native/event_loop_linux.c", "size": 24712, "sha256": "fafe070c4400e3d3ad2611620b6b9347464d4f02618db5207710b0067331dc53"},
    {"path": "targets/linux-aarch64/include/botlish_event_loop.h", "size": 4437, "sha256": "1e996979844b746f8d1f6bfd66ff9a2fdc591057ed7c5963cbeffa996df17962"},
    {"path": "targets/linux-aarch64/native/libevent_loop_linux.a", "size": 393182, "sha256": "cb58574c5ac4724b5f34819bb199a8a504c809f8e95040839ece255ec907ed0e"},
    {"path": "targets/linux-x86_64/include/botlish_event_loop.h", "size": 4437, "sha256": "1e996979844b746f8d1f6bfd66ff9a2fdc591057ed7c5963cbeffa996df17962"},
    {"path": "targets/linux-x86_64/native/libevent_loop_linux.a", "size": 390062, "sha256": "b687c45ca8364bbdc51a5492a9a2a528b7879bb0d1e63be277c5a61d60e751be"}
  ],
  "native": [
    {"target": "linux-aarch64", "library": "event_loop_linux", "linkage": "static",
     "path": "targets/linux-aarch64/native/libevent_loop_linux.a",
     "sha256": "cb58574c5ac4724b5f34819bb199a8a504c809f8e95040839ece255ec907ed0e",
     "description": "an ar archive of 1 ELF AArch64 object",
     "members": [{"name": "event_loop_linux.o", "size": 392568, "sha256": "bb85ab6a8c4b68a111408f924cbdfed889854d5d00938c2f94e3c9603b3428aa"}],
     "compilers": ["GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"]},
    {"target": "linux-x86_64", "library": "event_loop_linux", "linkage": "static",
     "path": "targets/linux-x86_64/native/libevent_loop_linux.a",
     "sha256": "b687c45ca8364bbdc51a5492a9a2a528b7879bb0d1e63be277c5a61d60e751be",
     "description": "an ar archive of 1 ELF x86-64 object",
     "members": [{"name": "event_loop_linux.o", "size": 389448, "sha256": "896a41c70c6c0b94e3c799bd9365e5c2498985e1da05a6a8f546800fa486fc6f"}],
     "compilers": ["GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"]}
  ],
  "sources": [],
  "builds": [
    {"name": "event loop adapter linux-aarch64", "targets": ["linux-aarch64"],
     "outputs": ["targets/linux-aarch64/native/libevent_loop_linux.a"], "sources": [],
     "configuration": "adapter",
     "toolchain": {"ar": "GNU ar (GNU Binutils for Ubuntu) 2.42",
                   "cc": "aarch64-linux-gnu-gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"},
     "flags": ["-O2", "-Wall", "-Wextra", "-Werror", "-fPIC", "-pthread"],
     "image": "botlish-package-build: Dockerfile sha256 dd557ad571b7ea7eb95e9b0b329a2a612f1e59769c03209aedffb062299fa4ad, FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852, Ubuntu snapshot 20261101T000000Z",
     "steps": ["aarch64-linux-gnu-gcc -c native/event_loop_linux.c",
               "aarch64-linux-gnu-ar rcs libevent_loop_linux.a event_loop_linux.o"]},
    {"name": "event loop adapter linux-x86_64", "...": "the same for x86-64 (cc, ar)"}
  ],
  "generators": [],
  "checks": [
    {"subject": "build event loop adapter linux-aarch64",
     "fact": "output targets/linux-aarch64/native/libevent_loop_linux.a",
     "value": "cb58574c5ac4724b5f34819bb199a8a504c809f8e95040839ece255ec907ed0e",
     "result": "confirmed",
     "method": "the artifact holds 1 file the build names (the value: its SHA-256); that the build made them is the author's statement"},
    {"subject": "build event loop adapter linux-x86_64", "...": "the same"}
  ],
  "notes": [],
  "trust": "This record was made by whoever packed the artifact. ... It is not a signature: it does not authenticate who made the artifact, and it does not show that the sources or the build environment can be trusted."
}
```

(Commit bb99687's build. Shown in a shortened layout: the file itself is
canonical, one key per line; two items are elided as `"..."`. The final
build's record differs in the image line and the producer only: there are no generators.) Raven's record adds two sources --
Raven at `cd228d8e` (tag `v0.1.3`, tag object `ad936b9f`, tree `bf29e6fc`)
and the Vulkan headers at `b379292b` (tree `60d1dc3e`) -- whose trees it
**confirmed** by recomputing them from the source files used (452 and 79
files, SHA-1, no git), each bundled library's build ID, compilers and
(empty) RUNPATH, the AArch64 build's three pinned arm64 `.deb` inputs with
their SHA-256, and the binding generator's outputs; SDL3's adds SDL's tree
(2194 files) confirmed.

### Checked, asserted, and what a signature would add

| | fields | how |
|---|---|---|
| **computed** (by the package manager, from the artifact's bytes, when the record was made) | `subject`, `contents`, `native` (format, machine, identity, needs, build ID, `.comment` compilers, RUNPATH, glibc, archive members) | read, never run |
| **checked** (an assertion tested, or a value computed from files the author gave) | `checks`: a source's Git tree recomputed from its files (`confirmed` or the pack fails), the list-digest of the files given (`computed`), a source archive's or patch's SHA-256, every build's and generator's outputs present in the artifact | no git, no tool: SHA-1 and SHA-256 over the files |
| **asserted** (the author's statements, copied) | `sources` (repository, commit, tag, tag object, archive digest, patches), `builds` (toolchain, flags, environment, image, inputs, steps), `generators`, `notes` | validated for form and publishability only |

Evidence that would publish a host's private facts is refused
(`pa-provenance-publishable`): a home, temporary or cache path (the
recipe writes `$CACHE`, `$BOTLISH`, `$BUILD`, `$VULKAN_HEADERS`,
`$X11_SYSROOT` instead), a credential-shaped string, an environment
variable named like a secret, an unknown key. The local directories a
source's checks read are never recorded (`pa-provenance-record`).

Not a signature: anyone can write a record, and nothing in it says who did.
What PM-4 signs is the subject's SHA-256 (the artifact's bytes) and,
optionally, the record's bytes as an attestation; PM-5 compares `sources`'
identities with the previous authenticated release's anchors. A confirmed
tree says only that the files given were that tree -- not that the tree is
the upstream's, nor that the commit is in its history.

### Determinism

Same artifact, evidence and package manager: the same bytes
(`pa-provenance-deterministic`; both pinned builds wrote identical
records). Two things legitimately differ between records of one artifact:
`producer.sources-sha256` (the package manager's own sources) and a
generator's `version` (the commit the recipe ran at). `package compare
-provenance` names them as such.

## G. Reproducibility investigation

### The 0.3.1 discrepancy

The two raven 0.3.1 artifacts: the developer machine's, sha256
`9336738e...` (1,735,590 bytes; the clean room's transcript records its
four native files' digests), and the GitHub runner's, `4cb6c223...`
(1,735,598 bytes; downloaded from run 41410971721's artifact).

1. **This machine reproduced the developer machine's artifact**:
   `tools/package-repository.tcl OUT` at the starting commit gave
   `9336738e652d...` exactly (**Executed**). The comparison below is
   therefore between full bytes on both sides.
2. **The first level of divergence** (`botlish package compare`,
   **Executed**): the descriptors, the file lists and 55 of 56 files are
   identical; one file differs, `targets/linux-aarch64/native/libraven.so.0`
   (1,710,312 bytes both; sha256 `3d32df32...` and `d3ff7d83...`). The
   x86-64 libraven (`15493f54...`) and both bridge archives are identical.
   ZIP encoding is not involved (no file is identical with different
   compressed bytes; the 8-byte archive difference is that file's deflate
   stream).
3. **Inside the ELF file**:

```
RUNPATH: "/root/.cache/botlish/raven-cross/x11-linux-aarch64-446a14060138/root/usr/lib/aarch64-linux-gnu:"
     and "/home/runner/.cache/botlish/raven-cross/x11-linux-aarch64-446a14060138/root/usr/lib/aarch64-linux-gnu:"
GNU build ID: b3d81a566139bb7a02ef34270c7926a957440a8f and dd9762bbf1843918a64b415472933af019f2d51e
sections whose bytes differ: .note.gnu.build-id, .dynsym (27624 bytes both), .dynstr (24209 and 24216 bytes), .init, .dynamic
sections with equal bytes at other offsets: .gnu.version, .gnu.version_r, .rela.dyn, .rela.plt
```

   `.text` is byte-identical; the compilers (`.comment`: `GCC: (Ubuntu
   13.3.0-6ubuntu2~24.04.1) 13.3.0`) are the same on both.

**Root cause (Executed).** The AArch64 cross build links the pinned arm64
libX11 by an absolute path under the build machine's cache directory;
CMake, by default, records the directories of a build's libraries outside
the system's as the library's RUNPATH. The library therefore carried the
author machine's path -- 7 bytes longer under `/home/runner` than under
`/root`, which grows `.dynstr`, moves every later dynamic section by 8
bytes and changes the build ID. The x86-64 build links the system's own
libX11 (`/usr/lib/x86_64-linux-gnu`), so CMake adds no RUNPATH there and it
reproduced.

**The controlled experiment (Executed).** The unchanged recipe, run twice
on this one machine with only `BOTLISH_CACHE_DIR` changed (two roots of
different lengths), everything fetched and built from nothing: two
artifacts (`5c51ca5d...`, `f07d458a...`) differing only in the AArch64
libraven, by the RUNPATH (`/tmp/claude-0/exp/c1/...` and
`/tmp/claude-0/exp/cache-root-two/...`). The discrepancy is reproduced
without a second machine.

Two further observations from that pair:

* With the 12-byte longer root, `.text` itself grew by 8 KiB (0xfebd0 to
  0x100bd0) while the file kept its size; a disassembly diff shows ten
  extra branches and loads moved into small out-of-line stubs. Ubuntu's
  AArch64 GCC passes `--fix-cortex-a53-843419` to the linker (`gcc
  -dumpspecs`), whose workaround rewrites loads that follow an ADRP near
  the end of a 4 KiB page, so which instructions are rewritten depends on
  their addresses. The observation is consistent with that; it was not
  confirmed with a linker map. Either way the cause is the path.
* **The RUNPATH was a defect beyond reproducibility**: its trailing `:`
  is an empty entry, which glibc's loader takes as the current directory.
  raven 0.3.1's AArch64 library searched the working directory -- and, on
  any consumer machine, the build machine's cache path -- for libX11
  before the system's directories. (On x86-64, never.)

**The fix**: the cross build is configured with `-DCMAKE_SKIP_RPATH=ON`
(`author::crossFlags`; the cross build's stamp includes its flags, so
cached 0.3.1 builds are not reused). raven 0.3.2's AArch64 libraven has no
RUNPATH (`pw-raven-aarch64-runtime-search-path`), and the audit now refuses
any bundled library whose RUNPATH is absolute or empty
(`pa-audit-runtime-search-paths`), so a package cannot be packed with one.
With the fix, the same two-root experiment gave one artifact (`4bba80a1...`,
the README not yet changed) for both roots and equal to the default root's.

### What else was checked, and found not to matter

* Debug paths and `__FILE__`: the stripped x86-64 libraries contain no
  build path (`strings` of libSDL3.so.0 and libraven.so.0).
* Static archives: `ar rcs` with Ubuntu's binutils is deterministic (no
  timestamps, owners: `D` by default); every archive reproduced.
* Toolchain versions: the developer machine, the runner and the pinned
  image all reported `13.3.0-6ubuntu2~24.04.1` and binutils 2.42; the
  only divergent input was the path.
* `sdl3 0.2.0`: PM-2's report shows `sdl3 0.2.0 (sha256 5ec19d6757b0)`
  installed in its transcript; this machine's build of 0.2.0 (old recipe
  and new alike) is `c684ebef...`. The earlier bytes are not preserved
  anywhere this milestone could find, so the difference cannot be
  characterized; it means one version already had two artifacts. The
  PM-3 release of SDL3 is therefore a new version, 0.2.1 (and sdlkit 0.2.1,
  which locks it), never a second 0.2.0.

### The pinned author environment

`tools/package-build/` (**Executed**):

* `Dockerfile`: `FROM ubuntu:24.04@sha256:fe815609...` (a digest, not a
  tag); every Ubuntu package from `snapshot.ubuntu.com/ubuntu/20261101T000000Z`
  (the archive at one instant: apt resolves the same versions on every
  machine, on any day); Tcl 9.0.1's three `.deb` files from the same
  snapshot, each checked by SHA-256. 224 packages
  (`environment-packages.txt`, identical in every build).
* `author.sh build OUT [-release] [NAME...]`: a fresh container, the
  repository's committed tree (`git archive HEAD`) at `/src`, an empty
  cache at `/cache`, every source fetched again (checked by commit and
  SHA-256 by the recipes), `tools/package-repository.tcl` run there.
* What the image does not pin, and how each is handled: the pinned Raven,
  SDL3 and Vulkan-Headers commits (checked by commit at fetch, and by Git
  tree in the record); the arm64 libX11 `.deb`s (SHA-256 pins; Ubuntu's
  snapshot service has no ports archive, and the ports pool drops a
  superseded version: the build then fails naming the file, never takes
  another version); the build machine's kernel and CPU (no output depends
  on them). The proxy CA of this sandbox reached the image build as a
  BuildKit secret and the build container as a file: never baked in.

### Independently initialized builds (Executed)

Two containers, one after the other, each from a fresh container with an
empty cache, at the same commit:

| | sdl3 | sdlkit | raven | event_loop_linux | records |
|---|---|---|---|---|---|
| commit df44599, build A | `c684ebef` (0.2.0) | `4137c394` | `4bba80a1` | `79651e71` | -- |
| commit df44599, build B | identical | identical | identical | identical | all 3 identical |
| the host (outside the image) | identical | identical | identical | identical | (producer differs only) |
| commit bb99687, build A | `d4c2d1df` (0.2.1) | `2492c596` | `9d94f187` | `3746cece` | -- |
| commit bb99687, build B | identical | identical | identical | identical | all 3 identical |
| commit d80d5d6 (the fixed image), builds A and B with `-release` | the recorded release | the recorded release | the recorded release | the recorded release | all 3 identical between A and B |

Both builds of each pair are byte for byte identical, artifacts and
provenance records alike; the pinned image's outputs equal this host's
(the same toolchain versions). Not yet established by this report: two
*different machines* building the pinned image. That is CI's
`package-reproducibility.yml` -- two GitHub runners, each building the image
itself and every package with `-release` against the recorded digests,
compared file for file -- which was pushed with this milestone; its result
is the "CI" line below.

**CI**: the workflow's first run (41527433764, commit bb99687) found a
defect of the image, not of the packages: on a runner, with no proxy, the
image's first `apt-get update` went over HTTPS before `ca-certificates`
was installed, so every package was "not available" (exit 100). The
image now always receives a CA bundle as a build secret -- the building
host's own (`/etc/ssl/certs/ca-certificates.crt` on a runner) or a
proxy's -- used during the build and removed (commit d80d5d6); TLS is
verified everywhere. The two images built here before and after the fix
hold the same 224 packages, and the builds of the fixed image reproduce
every recorded release (the table above, `-release`). The two-runner
result of the fixed workflow: RESULT-PENDING.

### Release immutability

Reproducibility and immutability are separate. `packages/RELEASES.tsv`
records each release of this repository's packages once (name, version,
SHA-256): raven 0.3.0 and 0.3.1 (the clean room's), and this milestone's
four. `tools/package-repository.tcl` reports each build as `release: the
recorded release`, a new release not yet recorded, or `CANDIDATE: the
recorded release of NAME VERSION is sha256 ..., and this build is ...: a
rebuild that did not reproduce it, never the release`; with `-release` --
the pinned image's path, used by every workflow that publishes or tests a
release -- a candidate is an error and its file is renamed
`NAME-VERSION.candidate-DIGEST.botpkg` (`pw-release-ledger`). `package
compare RELEASE CANDIDATE` is the deliberate comparison. The local
`-force` still only overwrites a local file; it is no way to change a
recorded release.

## H. Real-package results

Each column is a separate step; **Executed** throughout on linux-x86_64,
linux-aarch64 built and inspected only (no AArch64 machine).

| | author-side build | staging and import | packing | consumer install | compile | native link | run | deploy |
|---|---|---|---|---|---|---|---|---|
| **sdl3 0.2.1 + sdlkit 0.2.1** | SDL3 (CMake, headless), thunks (clang per target) | 2 bindings (`stage -modules`, 62 modules each), libSDL3.so.0 and 2 thunk archives (`native add`), SDL3 system alternative (`native require`) | partially verified on both (x86-64: the system SDL3 alternative, which this host lacks; aarch64: the system SDL3, another target's) | `add sdlkit` (sdl3 nested), the host view | x86-64 and AArch64 front ends | libSDL3 and the shim from `.lib`, no `-L` | headless frame: every step true (`pw-sdlkit-runs`) | relocated, after the packages are deleted (`pw-sdlkit-deploy-relocates`) |
| **raven 0.3.2** | the desktop libraven for x86-64 and AArch64 (now without RUNPATH), bridges | 2 bindings (22 modules), 2 bridges, 2 libraries with license and notices, X11 system, 5 run-time dependencies per target | x86-64 complete; aarch64 partially verified (X11, calloc/free from its C library) | no compiler on PATH (`pw-raven-installs-without-a-compiler`) | yes | bridge from the instance, libraven from `.lib` | headless example, and real windows (section I) | relocated (`pw-raven-deploy-relocates`, the clean room) |
| **event_loop_linux 0.3.0** | the adapter archive per target | `native add` per target; the header per target (`stage -headers`) | complete, both | yes | yes | the adapter's archive | five ticks handled; the consumer's own C compiled against the package's header found by `native plan -include` (`pw-event-loop-runs`) | -- (static) |
| **pure Botlish** (game2048, and every schema 1 test package) | -- | -- | PM-1's path, no audit | as before | as before | -- | the benchmark checksum (`pw-pure-botlish-package`) | -- |

Byte-for-byte equivalence of the migration (**Executed**): on this
machine, the PM-2 recipe and the PM-3 generic workflow made the same
`sdl3-0.2.0.botpkg` (`c684ebef...`) and `sdlkit-0.2.0.botpkg`
(`4137c394...`) -- the generic commands derive exactly the metadata the
PM-2 author wrote by hand. raven and the event loop changed contents by
design (schema 3 metadata, licenses; the header per target), so their
versions are new.

`tests/package-workloads.test`: 24 tests, 24 passed (5 new: the derived
metadata, Raven's run-time dependencies, its provenance record, its
AArch64 RUNPATH, the release ledger).

## I. Clean-room regression

`audit/raven-cleanroom/tools/cleanroom.sh run` with
`single/out/botlish` (14,570,230 bytes, built from this milestone's tree)
and `raven-0.3.2.botpkg` (the pinned build's): **33 of 33 checks, PASS**
(**Executed**; `audit/raven-cleanroom/results/pm3-acceptance/`). The
container holds Ubuntu 24.04's own packages, no Tcl, Rust, CMake, git or
checkout, and no network:

* `botlish add raven-0.3.2.botpkg`: `view linux-x86_64: derived (41 files,
  3 native libraries)` (the 6 license files are the new ones); `verify`;
  `native plan` lists the bundled libraries, the dpkg-verified libX11 and,
  apart, the run-time dependencies with the container's Vulkan loader as a
  candidate; `-target macos-aarch64` UNSUPPORTED; a second view for
  linux-aarch64;
* the documented example's headless test, `["2", "2 clicks", "0", "0
  clicks"]`, on both native backends;
* the real window (Xvfb, Mesa's lavapipe): found by its title, its pixels
  read, four clicks through XTest each changing the state, the label and
  the pixels, `WM_DELETE_WINDOW` ending it with status 0 -- on cranelift,
  cranelift-generic, and as a deployed executable moved elsewhere after
  `botlish remove raven`, its process mapping the deployed libraven;
* missing display and missing driver reported with their causes.

No new independent-agent experiment was run: the consumer-facing
experience changed only by the plan's run-time section and the license
files, which the existing acceptance exercises.

## J. Security and tests

### Commands and outcomes (Executed)

Every command with `LANG=C.utf8 LC_ALL=C.utf8` and a private `-tmpdir`.

| command | result |
|---|---|
| `tclsh9.0 tests/local.tcl -jobs 3 tests/package-manager.test tests/package-native.test tests/package-authoring.test tests/package-workloads.test tests/bot-modules.test tests/main-cli.test tests/raven.test tests/event-loop-linux.test tests/native-link-plan.test tests/system-linker.test tests/compilerpedia.test` | interp: 420 passed, 0 failed, 3 skipped; compile: 419 passed, 0 failed, 4 skipped (the skips: `native-link-plan.test`'s two macOS and one Windows test, and on compile `compilerpedia.test`'s `cp-examples`, which runs on the interp pass only); 690 s wall, 3 jobs. Per file (both passes): package-manager 74, package-native 39, package-authoring 28, package-workloads 24, bot-modules 56, main-cli 64, raven 19, event-loop-linux 25, native-link-plan 34, system-linker 15, compilerpedia 42 |
| `tclsh9.0 tests/package-authoring.test` | 28 tests, 28 passed (clang, lld, MinGW-w64 and git present: nothing skipped) |
| `single/build.sh`, then `single/smoke-test.sh single/out/botlish` | passed, the new PM-3 check included: `native add`, `native audit`, `pack -evidence`, `inspect -provenance` with no C compiler and no native backend installed |
| `audit/raven-cleanroom/tools/cleanroom.sh run ...` | 33/33 (section I) |
| `tools/package-build/author.sh build OUT -release` (twice, two commits) | section G |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1169 topics, 725 examples run, 0 problems |
| `tclsh9.0 audit/package-manager/tools/mutate.tcl` | MUTANTS-PM |
| `tclsh9.0 audit/raven-cleanroom/tools/mutate.tcl` | MUTANTS-RAVEN |

### Mutation testing

`audit/package-manager/tools/mutants.txt` gains 28 mutants of PM-3's
rules, each killed by `tests/package-authoring.test`: silent replacement of
a file or a contradicting declaration; a destination from the built file's
name; staging that follows links or keeps stale files; the audit ignoring
RUNPATH, empty RUNPATH entries, bundled platform libraries, unresolved
needs, undeclared binaries, differing module sets, missing C functions,
duplicate static symbols; pack skipping the audit; run-time dependencies
made mandatory or allowed to be loader dependencies; schema 3 keys in
schema 2; unchecked license expressions; the cascade restored; a Git tree,
an artifact binding or host paths unchecked; local paths recorded;
unknown evidence keys ignored; Git trees without text conversions or with
Tcl 9's decimal `0100`; comparison by descriptor; the SHA-1 tool from PATH.
`audit/raven-cleanroom/tools/mutants.txt`'s recipe and metadata mutants
were rewritten for the generic recipe (a headless library with and without
its required Vulkan symbol, the X11 declaration dropped, the version
reused, `-force` always) and two added: the cross build's RUNPATH back, and
Vulkan declared a system library.

One mutant-shaped defect was found by the tests rather than planted: Tcl
9 reads `0100` as decimal 100, so `& 0100` tested the wrong bits and every
file of a computed Git tree came out mode 100755 (`pa-compare-git-tree-
matches-git` now pins `0o100`; the mutant `git-tree-octal-mode` keeps it
pinned).

### Adversarial cases

| case | test |
|---|---|
| wrong-target, truncated, thin, script, bitcode, object, no-soname binaries | `pa-add-refusals` |
| import library as static; DLL without import library | `pa-add-windows`, `pn-inspect-windows` |
| imported binaries never executed | `pa-add-never-runs`; `pm-no-network-in-sources` (no `exec` but `kill -0`, the SHA-256 tool's two procedures and now the SHA-1 tool's one) |
| links inside staged sources; hidden files; files outside the namespace | `pa-stage-modules` |
| common files into a target directory | `pa-stage-headers-and-files` |
| build-machine RUNPATH; empty entry | `pa-audit-runtime-search-paths`, `pa-pack-refuses-incomplete` |
| an undeclared binary; a bundled platform library; identity and symbol collisions | `pa-audit-native-closure-errors` |
| a modified source checkout claiming a tree; wrong archive and patch digests; outputs not in the artifact | `pa-provenance-contradictions` |
| host paths, credentials, secret-named variables, unknown keys in evidence | `pa-provenance-publishable` |
| a record of another artifact; a reformatted record; a record replaced by another artifact's | `pa-provenance-deterministic` |
| a lying `sha1sum` first on PATH | `pa-sha1-backends` |
| a candidate published as a release | `pw-release-ledger` |

### Platform coverage

Executed on Linux x86-64 only. linux-aarch64: every native file built
(cross), inspected, audited, packed and compared; nothing run. macOS
(Mach-O from clang+lld) and Windows (PE from MinGW-w64): `native add` and
the audit's checks executed on real files from cross toolchains; nothing
run there; no repository package carries those targets. GitHub's macOS and
Windows workflows ran on this branch for the unchanged compiler (their
results are CI's, not this report's evidence).

## K. Performance

BENCH-TABLE

* **Hashing** stays PM-2's (the system's SHA-256 tool for inputs of 4 KiB
  and more); Git trees use the system's SHA-1 tool the same way: the
  2194-file SDL3 tree in 4.0 s, Raven's 452 files in 0.9 s, the Vulkan
  headers' 79 in 0.5 s (in process).
* **Consumers pay nothing new**: installation does no audit and reads no
  record; the view's plan adds only the run-time list (Raven's 5 entries,
  a dpkg lookup each on the host). `add` of a pure-Botlish package and
  main.tcl's start-up are unchanged code paths.
* **The real releases**: the generic recipe (`tools/package-repository.tcl
  OUT`, every package, builds cached) runs in 28 s wall time here, most of
  it the commands' Tcl start-up (each command a process, as an author runs
  it) and the AArch64 rebuild; a fresh pinned-container build of all four
  packages (SDL3 and two Raven builds from source) takes about 8 minutes.

## L. Remaining limitations

### PM-3 defects or incomplete requirements

* **Cross-machine reproducibility of the pinned image is established on
  one machine** (two independent containers); the two-runner CI
  comparison is pushed and its result is section G's CI line.
* **AArch64 never executed**: built, inspected, audited, compared, not run
  (no arm64 machine; CI's arm64 workflow does not build the packages).
* **The audit's C-function check** reads the host's platform libraries only
  for the host's target; for another target unresolved functions are
  "partially verified" (Raven's AArch64 `calloc`, `free` from its C
  library are reported that way).
* **sdl3 states no license** (a note): SDL3 is Zlib-licensed and its
  LICENSE.txt is not yet in the package; a new version is needed to add
  it. Raven's is stated and its notices are packed.
* **Module sets must be equal across targets**: a package that offers a
  module on one target only cannot be packed (a deliberate rule: one
  public API per release); no repository package needs otherwise.
* **The evidence's toolchain and steps are the recipe's own statements**;
  the package manager checks only that outputs exist, and the `.comment`
  compiler identities it records are consistent with them, not compared.

### Unresolved reproducibility requirements

* The arm64 libX11 `.deb`s are pinned to ports.ubuntu.com's pool, which
  drops superseded versions and has no snapshot service: a future build
  fails (clearly) until the inputs are preserved separately (an
  authenticated mirror of the three files) or re-pinned deliberately.
* The image pins Ubuntu's archive at an instant, not the snapshot
  service's availability; the base image digest depends on Docker Hub
  keeping it.
* Raven's and SDL3's sources and the Vulkan headers are fetched over the
  network at build time, checked by commit; an offline build needs a
  preserved source cache.
* SDL3 0.2.0's two artifacts are left as they are (its bytes from PM-2 are
  not preserved); its PM-3 release is 0.2.1.

### Unsupported native targets or representations

macOS frameworks bundled by a package, Mach-O `.tbd` stubs, LLVM bitcode,
thin archives and GNU linker scripts are refused by `native add` (each
says why); system-library verification exists for Linux only; no
repository package carries a macOS or Windows target.

### PM-4 (signed registry)

No signatures, no TUF, no remote repository, no publication protocol, no
revocation records; `packages/RELEASES.tsv` is a repository file, not a
signed timeline.

### PM-5 (upstream Git continuity)

Commits, tags and tag objects are recorded, not checked against history;
no previous anchor is consulted; a confirmed tree proves only that the
given files were that tree.

### PM-6 (independent attestations and transparency)

Records are unsigned and single-party; `package compare` is the mechanism a
second builder would use, but there is no way to publish or witness its
outcome.

### Unrelated compiler and language ergonomics

Unchanged from RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md section I (retained
callbacks, process exit status, method-call import hints, front-end cost
per run).

## M. PM-4 preparation

What an authenticated registry needs from PM-3's outputs, precisely:

1. **The unit of authentication is the artifact's SHA-256** (`subject.sha256`
   of the record, the digest `package inspect` prints): one release, every
   target, every native declaration inside it. A TUF `targets` entry is
   `NAME-VERSION.botpkg` with that digest and size (`subject.size`).
2. **The record is a separate target**, `NAME-VERSION.provenance.json`,
   with its own digest; a registry can require one per native release,
   sign it as an attestation of the uploader, and reject a record whose
   `subject` is not the artifact's (`package inspect -provenance` is that
   check).
3. **Publication-time checks a registry repeats**, all implemented and
   side-effect free: the archive reader (format 1), the descriptor in the
   artifact context (complete exact locks), the target layout, the native
   audit (no incomplete target), the record's binding and canonical form.
4. **Immutability**: a registry's equivalent of `RELEASES.tsv` (name,
   version, digest, once) and its refusal of a second digest for a
   version; a rebuild reported as a candidate, compared with `package
   compare`, never published under the version.
5. **Identity of builds**: `builds[].image` names an environment by its
   specification (a Dockerfile digest, a base image digest, a snapshot
   instant), which independent builders can rebuild; PM-6 attestations can
   say "this image, these sources, this subject digest".
6. **What PM-4 must not assume**: a record's assertions are the uploader's;
   only `checks` were tested, by whoever made the record; nothing in the
   record identifies a developer.

## What to run when changing this

* `pm/author.tcl`, `pm/release.tcl`, `pm/sha1.tcl`, schema 3
  (`pm/targets.tcl`, `pm/descriptor.tcl`), the plan's run-time section or
  the cascade rule (`pm/native.tcl`): `tests/package-authoring.test`,
  `tests/package-native.test`, `tests/package-manager.test`,
  `audit/package-manager/tools/mutate.tcl`.
* A package's recipe, `tools/package-build/`, `packages/*`: the above,
  `tests/package-workloads.test`, `audit/raven-cleanroom/tools/mutate.tcl`,
  `tools/package-build/author.sh build OUT -release` twice (identical
  outputs, equal to `packages/RELEASES.tsv`), the clean room for raven, and
  on a branch `package-reproducibility.yml`. A change of a package's
  contents is a new version, recorded once.
* The single executable's dispatch: `single/smoke-test.sh` (its PM-3
  check).

## Repository changes

* `pm/`: new `author.tcl` (native add, require, stage, the audit),
  `release.tcl` (evidence, provenance records, Git trees, `package
  compare`), `sha1.tcl` (Git object identities only); `targets.tcl` and
  `descriptor.tcl` (schema 3), `native.tcl` (the cascade fix, run-time
  dependencies in the plan), `binary.tcl` (`elfSections`: build ID,
  `.comment`, sections), `commands.tcl` (the new commands, pack's audit and
  `-evidence`, `inspect`'s schema 3, closure and `-provenance`), `pm.tcl`.
* `tools/package-repository.tcl`: the recipes on the generic commands; the
  evidence; `-release` and the ledger; `-DCMAKE_SKIP_RPATH=ON` for the
  cross build. `tools/package-build/`: the pinned author image and
  `author.sh`.
* `packages/`: botlish.json files without native metadata; raven 0.3.2,
  sdl3 0.2.1, sdlkit 0.2.1, event_loop_linux 0.3.0; READMEs; `RELEASES.tsv`.
* Tests: `tests/package-authoring.test` (new, 28 tests),
  `tests/package-workloads.test` (5 new), `tests/package-native.test` and
  `tests/package-manager.test` (expectations: the instance in a failed
  system library's diagnostic, schema 3, the SHA-1 tool), `single/smoke-test.sh`.
* Audit: `audit/package-manager/tools/mutants.txt` (28 new),
  `audit/raven-cleanroom/tools/mutants.txt` (rewritten and 2 new),
  `audit/raven-cleanroom/results/pm3-acceptance/`.
* CI: `.github/workflows/package-reproducibility.yml` (new);
  `raven-cleanroom.yml` and `tasks-app.yml` build the release in the
  pinned image with `-release`.
* `bench/package-authoring.tcl` (new); `bench/package-manager.tcl` (sdl3
  0.2.1).
* Documentation: this report, BOTPKG-PROVENANCE.md (new), BOTLISH-JSON.md
  (section 13), `docs/INDEX.md`, PACKAGE-ECOSYSTEM-ROADMAP.md (status),
  `AGENTS.md` (the package manager's and the raven release's rules),
  Compilerpedia (`cli.packages`).
