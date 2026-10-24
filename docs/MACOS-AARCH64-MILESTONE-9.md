# MACOS-AARCH64-MILESTONE-9.md

Milestone 9 of the macOS Apple Silicon port: the canonical macOS compiler
distribution. Botlish itself is now a relocatable, ad-hoc-signed
application, `Botlish.app`: Tcl 9 as the bundle's own `Tcl.framework`, the
compiler, its standard library, compiler service and Compilerpedia in a ZIP
archive inside it, the native backend and its precompiled runtime archive
beside them, and a small launcher. A user unpacks one download, moves the
application anywhere, and compiles -- with no checkout, no Tcl, no Rust and
no Cargo; with Apple's Command Line Tools also to standalone Mach-O
executables, programs that call C and `std::darwin::io` included.
Developed on Linux; every macOS fact below was observed on GitHub's
`macos-15` arm64 runners through `.github/workflows/macos-arm64.yml` (the
shared Apple Silicon development machine was not used). It builds on
SINGLE-EXECUTABLE-FFI-MILESTONE-1.md (the system linker and the runtime
archive, on macOS since then) and the port's milestones 1 to 8
(MACOS-AARCH64-PORT-AUDIT.md, roadmap entry 10).

> The canonical Botlish compiler is an application, not a source checkout.
> Its implementation language and native backend are deployment details
> that its users should not have to install or understand. On macOS, use
> the platform's ordinary framework, application-bundle, dynamic-linking and
> signing mechanisms rather than constructing an alternative distribution
> environment.

Claims are labelled as the brief asks: **built**, **inspected** (by the
host's own tools), **executed**, **signed**, **verified** (`codesign
--verify`), and -- never, here -- **notarized**.

<<EV result>>

## Contents

1. [Starting single-executable architecture](#1-starting-single-executable-architecture)
2. [Dependencies from the system-linker milestone](#2-dependencies-from-the-system-linker-milestone)
3. [Tcl framework build census](#3-tcl-framework-build-census)
4. [Tcl zipfs application-startup census](#4-tcl-zipfs-application-startup-census)
5. [Packaging designs considered](#5-packaging-designs-considered)
6. [The code-signing constraint on appended ZIP archives](#6-the-code-signing-constraint-on-appended-zip-archives)
7. [Chosen application-bundle design](#7-chosen-application-bundle-design)
8. [Exact bundle layout](#8-exact-bundle-layout)
9. [Tcl framework version and checksum](#9-tcl-framework-version-and-checksum)
10. [Framework install names and runtime search paths](#10-framework-install-names-and-runtime-search-paths)
11. [Native launcher implementation](#11-native-launcher-implementation)
12. [ZIP resource mounting](#12-zip-resource-mounting)
13. [Compiler and standard-library contents](#13-compiler-and-standard-library-contents)
14. [Compilerpedia contents](#14-compilerpedia-contents)
15. [Compiler-service and LSP acceptance](#15-compiler-service-and-lsp-acceptance)
16. [Native backend discovery](#16-native-backend-discovery)
17. [Runtime archive discovery](#17-runtime-archive-discovery)
18. [System-linker selection](#18-system-linker-selection)
19. [Toolchain-free operations](#19-toolchain-free-operations)
20. [Native executable compilation](#20-native-executable-compilation)
21. [Darwin IO acceptance](#21-darwin-io-acceptance)
22. [Static C fixture acceptance](#22-static-c-fixture-acceptance)
23. [C borrowing and error-capture acceptance](#23-c-borrowing-and-error-capture-acceptance)
24. [Native JIT behavior](#24-native-jit-behavior)
25. [GC stress and coroutines](#25-gc-stress-and-coroutines)
26. [Relocation and symlink tests](#26-relocation-and-symlink-tests)
27. [Read-only bundle tests](#27-read-only-bundle-tests)
28. [Ad-hoc signing implementation](#28-ad-hoc-signing-implementation)
29. [Signature verification and tamper controls](#29-signature-verification-and-tamper-controls)
30. [Distribution archive integrity](#30-distribution-archive-integrity)
31. [Dynamic dependency inspection](#31-dynamic-dependency-inspection)
32. [Mutation results](#32-mutation-results)
33. [Bundle and download sizes](#33-bundle-and-download-sizes)
34. [Startup and build performance](#34-startup-and-build-performance)
35. [Linux single-executable regressions](#35-linux-single-executable-regressions)
36. [Linux AArch64 regressions](#36-linux-aarch64-regressions)
37. [Windows regressions](#37-windows-regressions)
38. [macOS GitHub Actions links](#38-macos-github-actions-links)
39. [Known limitations](#39-known-limitations)
40. [Prerequisites for explicit static-library/framework declarations](#40-prerequisites-for-explicit-static-libraryframework-declarations)
41. [Prerequisites for Developer ID signing and notarization](#41-prerequisites-for-developer-id-signing-and-notarization)
42. [Prerequisites for native Icy Tower distribution](#42-prerequisites-for-native-icy-tower-distribution)
43. [What to run when changing this](#43-what-to-run-when-changing-this)

## 1. Starting single-executable architecture

The single-file compiler (SINGLE-EXECUTABLE.md) is a Tcl 9 *zipkit*: a
static `tclsh` (Tcl 9.0.1 built by `single/build.sh` with
`--disable-shared --enable-zipfs`, Tcl's own zlib and libtommath) with a
ZIP archive appended by `zipfs mkimg`. At startup Tcl's
`TclZipfs_AppHook` mounts the executable's own archive at `//zipfs:/app`,
takes the Tcl script library from `//zipfs:/app/tcl_library` and runs
`//zipfs:/app/main.tcl` -- `single/main.tcl`, which installs the archive's
`native-bin/` (the driver `botlish-native`, the stub `botlish-aot-stub` and
the runtime archive `libbotlish_runtime.a`) into a per-build cache
directory, because the kernel cannot execute and the linker cannot read a
file inside the archive, points `BOTLISH_NATIVE_BIN` at the installed
driver, sets `BOTLISH_NATIVE_LINKER=auto` and sources the checkout's
`main.tcl` unchanged from `//zipfs:/app/botlish`. Every path the compiler
computes from its own location (`core::libraryDir`, Compilerpedia, the
`source` chain) lands inside the archive; an application's own modules stay
beside its entry file (IMPORTS.md, "Application modules").

It is Linux's: one ELF file needing only glibc. The archive was assembled by
`single/package.tcl` from one list of the compiler's files.

## 2. Dependencies from the system-linker milestone

| needed here | established by |
|---|---|
| a linker that needs no Rust: the host's C compiler driver links the program object and the precompiled runtime archive | SINGLE-EXECUTABLE-FFI-MILESTONE-1.md (`BOTLISH_NATIVE_LINKER=system`) |
| that linker on macOS: Apple clang and ld, `-dead_strip`, no archive group, `-mmacosx-version-min=11.0` | ibid., sections 16 and 26 (executed on macos-15) |
| `libbotlish_runtime.a` built for aarch64-apple-darwin by the ordinary `cargo build` | ibid., section 7 |
| `auto` choosing the system linker where there is no stub | ibid., section 14 (`linker_named`) |
| the common `botlish_program` record and ABI fingerprint, checked when an executable starts | ibid., sections 9 and 11; NATIVE-LIBRARY-MILESTONE-1.md |
| Darwin IO, C byte borrowing, variadics and errno capture through the system linker | ibid., section 26 (3,266 tests on macOS, 0 failed); MACOS-AARCH64-MILESTONE-6.md to -8.md |
| the `NATIVE LINK TOOLCHAIN` diagnostic and its remedy `xcode-select --install` | ibid., section 36 (`missing_linker_lines`, `toolchain_remedy`) |

Section 36 of that report listed what a macOS distribution would add: the
archive packed unchanged and no stub, the toolchain diagnostic checked on a
machine without tools, the deployment target, the distribution's own
signature, a cache under `~/Library/Caches`, and a bundled
`Tcl.framework` that "is the kit's and does not affect the system linker".
This milestone does each; no linker, startup path, runtime format or C ABI
lowering changed.

<<EV census>>

## 5. Packaging designs considered

**A. A Linux-style zipkit linked to the framework.** `zipfs mkimg` with the
framework's `tclsh` as base kit: one Mach-O with the archive appended,
`TclZipfs_AppHook` mounting it as on Linux. It runs (C4) -- but an appended
archive cannot be part of a valid signature: signing after appending fails
strict verification, appending after signing invalidates the signature
(section 6). The native executables would still have to be extracted to a
writable cache to run, unsigned there. Rejected.

**B. A launcher that mounts a separate ZIP resource.** A small C program,
the bundle's main executable, linked to `Tcl.framework`, mounts
`Contents/Resources/botlish.zip` with `TclZipfs_Mount` and runs
`single/main.tcl` through `Tcl_Main`. The archive is ordinary bundle data,
sealed by the application's signature; the driver is signed code in
`Contents/MacOS`, run where it is; the runtime archive a resource the
linker reads where it is. Chosen.

**C. The framework's stock `tclsh` with the archive.** A stock `tclsh`
never mounts a ZIP named on its command line (`TclZipfs_AppHook` would
only with `SUPPORT_BUILTIN_ZIP_INSTALL`, which Tcl 9.0.1 does not define;
C3), so it needs a boot script -- and a shell script as the bundle's main
executable keeps its signature in extended attributes, which an ordinary
ZIP extraction loses. It reduces to B with a worse launcher. Rejected.

**D. Tcl linked statically into the launcher.** One Mach-O, no framework:
it saves the framework's 2 MB but is not what the brief asks for (Tcl as
the application's own framework), and needs a second Tcl build recipe.
Rejected; recorded as the alternative should frameworks ever be a burden.

| | A zipkit | B launcher + resource | C stock tclsh | D static Tcl |
|---|---|---|---|---|
| strict signature | fails (section 6) | passes | passes only with xattrs | passes |
| relocation | `@executable_path` | `@executable_path` | `@executable_path` | none needed |
| native code run from | a writable cache, unsigned | the signed bundle | the signed bundle | the signed bundle |
| `single/main.tcl` | unchanged | one application branch | a boot script | one application branch |
| Tcl as a framework | yes | yes | yes | no |

## 6. The code-signing constraint on appended ZIP archives

A Mach-O's code signature (`LC_CODE_SIGNATURE`) is the last thing in its
`__LINKEDIT` segment, and its code directory hashes the file up to the
signature. Data appended after it is outside the hashed range and outside
every segment: `codesign --verify --strict` rejects such a file, Apple's
notarization rejects it, and `codesign` re-signing it does not bring the
data inside a segment. Tcl's own build knows this: a zipfs-attached
`libtcl` on macOS is appended with `macher` when that tool exists, `cat`
otherwise (unix/Makefile.in), and a framework build attaches nothing
(`ZIPFS_BUILD=0` whenever `--enable-framework`, unix/configure.ac).

<<EV signing-constraint>>

## 7. Chosen application-bundle design

* **Tcl** is `Contents/Frameworks/Tcl.framework`, built by Tcl's own macOS
  build: `unix/configure --enable-framework` (the build
  `macosx/GNUmakefile` wraps), its library's install name
  `@rpath/Tcl.framework/Versions/9.0/Tcl`, its script library the files of
  `Versions/9.0/Resources/Scripts` -- a framework build attaches no zipfs
  library -- and nothing but what runs (no headers, stub library or
  `tclConfig.sh`).
* **The compiler** is `Contents/Resources/botlish.zip`, staged by the same
  procedure as the single executable's archive (`single/package.tcl`'s
  `StageCompiler`), written by `zipfs mkzip`: no Tcl library (the
  framework's) and no native executable (the bundle's).
* **The launcher** `Contents/MacOS/botlish` (`single/macos/launcher.c`,
  about 200 lines of C) initializes Tcl as a Tcl application does,
  `Tcl_Main` with an application initialization procedure, after checking
  that the Tcl dyld loaded is the bundle's own; it mounts the archive and
  runs `//zipfs:/app/main.tcl`, which is `single/main.tcl`.
* **The native backend** is `Contents/MacOS/botlish-native`, signed code
  run where it is: nothing is extracted to run. **The runtime archive** is
  `Contents/Resources/libbotlish_runtime.a`, link-time input read where it
  is; the driver finds it from its own path.
* **No stub.** `botlish-aot-stub` is Linux x86-64's and is left out; `auto`
  is the system linker for every macOS executable.
* **Signed ad hoc**, inner to outer, never with `--deep`; verified
  strictly; archived with `ditto` for download.

## 8. Exact bundle layout

<<EV layout>>

## 11. Native launcher implementation

`single/macos/launcher.c` does what a Tcl application's startup does with
the application's own parts, and nothing of the compiler's:

1. **Its bundle.** `_NSGetExecutablePath`, then `realpath`: the real path
   of the running executable, whatever `argv[0]` says and however it was
   reached (a symbolic link on PATH, a link to the bundle). Its directory's
   parent is `Contents`.
2. **Its Tcl.** The framework is weakly linked (`-weak_framework Tcl`), so
   when dyld cannot load it -- missing, of another architecture, truncated
   -- the launcher starts anyway and `Tcl_InitSubsystems` is NULL: it then
   `dlopen`s the path the framework must be at, only to report `dlerror()`'s
   reason, and exits with status 2. When dyld loaded one, `dladdr` names the
   image: it must be `Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl`
   (real paths compared), else the launcher refuses ("loaded Tcl from X,
   not this application's own"): neither `DYLD_FRAMEWORK_PATH` nor any
   other search reaches another Tcl. Its version must be the 9.0 the
   launcher was compiled against.
3. **Tcl_Main.** `argv[0]` is replaced by the real path (Tcl_MainEx calls
   `TclpFindExecutable(argv[0])` itself, so this is how `info
   nameofexecutable` becomes the launcher, and the language server's
   analysis worker, which re-runs `info nameofexecutable`, starts from the
   bundle); `Tcl_SetStartupScript(//zipfs:/app/main.tcl)` makes every
   remaining argument `::argv`, unchanged, exactly as the zipkit's
   `TclZipfs_AppHook` does.
4. **AppInit.** `tcl_library` is set to the loaded framework's
   `Resources/Scripts` before `Tcl_Init`, so Tcl's own search -- which
   tries `$TCL_LIBRARY` first (C2) -- never runs; then `Tcl_Init`; then
   `TclZipfs_Mount(interp, Contents/Resources/botlish.zip, //zipfs:/app)`;
   then a check that the archive holds `main.tcl`; then
   `::single::bundle`, the `Contents` directory, for `single/main.tcl`.
5. **Failures** before the compiler runs are "botlish: ..." on standard
   error, exit status 2, each naming the missing or damaged part and saying
   to reinstall the application -- never to install Tcl, Rust or Cargo.
   Standard output is never written: it is the compiler's, and the
   language server's protocol.

It also compiles on Linux against the system's libtcl (Tcl's own script
library search; `/proc/self/exe`), for testing the startup's logic without
a Mac; that build is never packaged.

`single/main.tcl` gained one branch: with `::single::bundle` set it sets
`BOTLISH_NATIVE_BIN` to the bundle's driver (whatever the environment
names: never another build's) and installs nothing; the single
executable's installation branch is unchanged. Both set
`BOTLISH_NATIVE_LINKER=auto` unless one is named, and both now make the
archive read-only to the compiler (`::tcl::zipfs::wrmax 0`: zipfs would
otherwise keep writes to an archived file in memory; with 0 a write is
refused, EACCES).

## 12. ZIP resource mounting

<<EV zip>>

## 16. Native backend discovery

`BOTLISH_NATIVE_BIN` is `native::binary`'s existing override; the
application sets it to `[file join $::single::bundle MacOS botlish-native]`,
the launcher's real `Contents` directory -- an absolute path computed from
the running executable, never `/Applications/Botlish.app`, never the
working directory, never PATH. A value in the environment is replaced: a
developer's shell naming a checkout's driver must not pair another build's
driver with this archive (app-test's relocation group runs with a decoy
`BOTLISH_NATIVE_BIN`; the `backend-from-environment` mutant is killed). A
missing driver is the application's damage: `native::binary` says "this
compiler's native backend is missing: PATH: the installation is incomplete
(reinstall it)" for a packaged compiler, where it used to say to run
`cargo build` in a directory inside the archive.

## 17. Runtime archive discovery

The driver looks for the runtime archive beside itself; on macOS a driver
in an application bundle's `Contents/MacOS` looks in that bundle's
`Contents/Resources` (`codegen::aot::packaged_runtime_archive`, a function
of the driver's own path: `Contents/MacOS` holds code only, and an archive
there would be taken for nested code by `codesign`). `BOTLISH_NATIVE_RUNTIME`
still wins when set, as on Linux. No environment variable is set for it,
so programs the compiler runs do not inherit one. The archive keeps every
check it had: the file, the `!<arch>` format, the first object's machine
(`Mach-O arm64`), the helpers the linker finds, and the ABI fingerprint the
executable checks when it starts. Unit test
`packaged_runtime_archive_follows_the_driver`; `tests/system-linker.test`'s
`system-linker-bundle-runtime` places a driver in "Bötlish Test.app",
runs `botlish-native system-linker` from `/` and links with it (macOS),
and checks that every other host keeps the archive beside the driver;
mutants `sys-runtime-bundle-ignored` and `sys-runtime-bundle-relative`.

## 18. System-linker selection

`BOTLISH_NATIVE_LINKER=auto` (`single/main.tcl`, unless the environment
names a linker) is the system linker on macOS for every executable: the
stub is Linux x86-64's (`STUB_LINKER`). No change to the selection.

## 28. Ad-hoc signing implementation

`single/macos/build.sh`, after assembling the bundle unsigned:

```sh
codesign --force --sign - Contents/Frameworks/Tcl.framework/Versions/9.0
codesign --force --sign - --identifier io.github.mwagner-webdev.botlish.native Contents/MacOS/botlish-native
TCLSH single/package.tcl -archive Contents/Resources/botlish.zip ...   # native-bin/ID: the signed driver's
codesign --force --sign - Botlish.app
```

* Inner code first, the enclosing bundle last; never `--deep` to sign
  (only to verify). The framework is signed as a framework, on its version
  directory: its binary and the seal of its `Resources`.
* The driver gets an identifier of its own instead of the linker's ad-hoc
  signature (`botlish_native-...`, flagged `linker-signed`), after
  `strip -S` removed its debug symbols.
* The archive is written after the driver is signed, because its
  `native-bin/ID` (the identity `-version` prints) is the CRC and size of
  the bundled driver and runtime archive as they are.
* The application's own signature signs the launcher (identifier
  `io.github.mwagner-webdev.botlish`, the bundle's `CFBundleIdentifier`)
  and seals `Info.plist`, `Resources/botlish.zip` and
  `Resources/libbotlish_runtime.a` in `_CodeSignature/CodeResources`,
  referring to the nested code by its own signatures.
* Nothing changes a signed file afterwards: verification, archiving and
  every test read only.
* Ad hoc: no certificate, no team, no timestamp, no hardened runtime, no
  entitlements. The identifiers are the repository owner's GitHub
  namespace in reverse-DNS form, chosen to stay valid for a Developer ID
  build (section 41).

<<EV rest>>
