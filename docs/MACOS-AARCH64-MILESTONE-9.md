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

**Result.** On commit 69b23498, in run 40140537637 (section 38), and
again on d1e2de57 in run 40452138744:

* **Built** on a macos-15 arm64 runner by `single/macos/build.sh`:
  `Botlish.app`, 26,840 KiB, and the download `botlish-macos-aarch64.zip`,
  10,700,286 bytes, SHA-256
  `f32acfea50104f807eff2d5e3200661870774e392801bf32030dd1cd263566d2`,
  uploaded as the job's artifact only after every check of the job passed.
* **Inspected** (`file`, `lipo`, `otool`): every Mach-O in it is arm64
  only, deployment target 11.0, SDK 15.5. The only load commands that
  point outside the system are the launcher's weak
  `@rpath/Tcl.framework/Versions/9.0/Tcl` and its one `LC_RPATH`,
  `@executable_path/../Frameworks`.
* **Signed** ad hoc, inner code first, and **verified** with `codesign
  --verify --deep --strict`: in the build directory, unpacked in
  "Prögram Files" after every run, after moves, and on a second runner
  with Xcode, the Command Line Tools, Rust and the checkout removed.
* **Executed**:
  - `single/smoke-test.sh` and `single/ffi-smoke-test.sh`, the packaged
    compiler's acceptance, which the Linux single executable also passes;
  - `single/macos/app-test.sh`'s eleven groups;
  - `single/macos/compare.sh`'s comparisons with the checkout, all alike:
    150 on 69b23498, and 157 on d1e2de57, which adds the kept-coroutine
    program;
  - the smoke test again without developer tools.

  26 of 26 application mutants and 5 of 5 driver mutants were killed on
  macOS.
* **Not notarized.** `spctl --assess` rejects it, as it rejects any
  ad-hoc signature (section 41).
* **Found on the way:** Tcl 9.0.1 crashes at startup in a non-ASCII
  directory without a UTF-8 locale (section 11, step 5). The launcher
  avoids the crash.

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

## 3. Tcl framework build census

`audit/macos-app/tools/census.sh` probes each fact this design relies on,
on the runner, and prints every command with its output and status; the
`app` job runs it after building the application. Observed on macos-15
(Xcode 16.4, SDK 15.5), run 40129027396.

**C1, the framework Tcl builds.** `single/macos/tcl-framework.sh` takes the
version, sha256 and download URLs from `single/build.sh` (one pin for both
distributions: Tcl 9.0.1, sha256
`a72b1607d7a399c75148c80fcdead88ed3371a29884181f200f2200cdee33bbc`, the
SourceForge release `tcl9.0.1-src.tar.gz`), checks the checksum with
`shasum -a 256 -c` before unpacking, and runs Tcl's own macOS build:

```
configure --enable-framework --libdir=/Frameworks --prefix=/usr/local --disable-zipfs CFLAGS=-O2 -arch arm64
make DYLIB_INSTALL_DIR=@rpath/Tcl.framework/Versions/9.0 binaries
make DYLIB_INSTALL_DIR=... INSTALL_ROOT=STAGING install-binaries install-libraries install-msgs install-headers
```

with `MACOSX_DEPLOYMENT_TARGET=11.0` (rustc's for aarch64-apple-darwin, so
the framework, the driver and the runtime archive agree). Nothing is
installed outside the staging root. What it produced:

```
$ file .../Tcl.framework/Versions/9.0/Tcl
Mach-O 64-bit dynamically linked shared library arm64
$ otool -D .../Tcl.framework/Versions/9.0/Tcl
@rpath/Tcl.framework/Versions/9.0/Tcl
$ otool -L .../Tcl.framework/Versions/9.0/Tcl
	@rpath/Tcl.framework/Versions/9.0/Tcl (compatibility version 9.0.0, current version 9.0.1)
	/usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.12)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1351.0.0)
	/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (...)
$ codesign -dv .../Tcl.framework/Versions/9.0/Tcl
Identifier=Tcl  flags=0x20002(adhoc,linker-signed)  Info.plist=not bound  Sealed Resources=none
$ du -sk Tcl.framework Versions/9.0/Tcl Versions/9.0/Resources/Scripts
4744  1784  2608
```

* The framework links only the system's zlib, libSystem and CoreFoundation.
  Tcl's own libtommath is compiled in (as on Linux); its zlib is the
  system's here, which is what Tcl's macOS build chooses.
* `--disable-zipfs` only stops `make` from attaching a zipfs image of the
  script library to the binary (configure forces `ZIPFS_BUILD=0` with
  `--enable-framework` anyway): `unzip -l` finds no archive in the binary
  (status 9). The `zipfs` commands and `TclZipfs_Mount` are part of every
  Tcl 9 library; the launcher uses them.
* The script library is plain files, `Versions/9.0/Resources/Scripts`
  (init.tcl, the encodings, msgs) and `Resources/tcl9` (Tcl's bundled
  modules: http, msgcat, tcltest, platform); `Resources/Info.plist` names
  the framework `com.tcltk.tcllibrary`, version 9.0.1.
* The linker's signature of a freshly built framework binary is ad hoc and
  `linker-signed`, binding no Info.plist and sealing no resources: it is
  replaced by the framework's own signature in the application (section 28).
* The build takes about 30 s on the runner. CI caches the output under
  `~/Library/Caches/botlish-app`, as `single/macos/build.sh` does on a
  developer's Mac: `tcl-framework-KEY`, KEY a hash of the recipe
  (tcl-framework.sh, the pin, the deployment target), so a changed recipe
  builds a new framework.

**C2, how an executable linked to the framework finds Tcl's script
library.** The framework's own `tclsh9.0` (rpath `@executable_path`, beside
`Tcl.framework`), with no environment:

```
$ env -i .../tclsh9.0     (puts [info library] ...)
info library: .../Tcl.framework/Versions/9.0/Resources/Scripts
nameofexecutable: .../tclsh9.0
encoding system: utf-8
$ env -i TCL_LIBRARY=.../decoy .../tclsh9.0
DECOY init.tcl sourced from .../decoy/init.tcl
info library: .../decoy
```

Tcl's own search finds the framework's scripts (through CoreFoundation's
bundle of identifier `com.tcltk.tcllibrary`), but tries `$TCL_LIBRARY`
first: a stock framework Tcl runs whatever script library the environment
names.

C2 also runs that `tclsh9.0` with its framework copied into a directory
named "non ascii dü" (run 40133897160):

| environment | status |
|---|---|
| none (the C locale: codeset US-ASCII) | 139, SIGSEGV |
| `LC_ALL=C` | 139, SIGSEGV |
| `LC_CTYPE=UTF-8` | 0 (`utf-8 .../non ascii dü/Tcl.framework/Versions/9.0/Resources/Scripts`) |
| `LANG=en_US.UTF-8` | 0 |
| none, the same Tcl in an ASCII directory | 0 |
| the application copied into "non ascii dü", none and `LC_ALL=C` | 0 (`-version`) |

Tcl 9.0.1 itself crashes at startup in a non-ASCII path without a UTF-8
locale; the launcher works around it (section 11, step 5). So the launcher sets `tcl_library` itself, to the scripts beside the
Tcl binary dyld loaded, before `Tcl_Init` (section 11); app-test's
relocation group runs with a decoy `TCL_LIBRARY` and the
`tcl-library-from-environment` mutant is killed.

## 4. Tcl zipfs application-startup census

**C3, a separate ZIP file.** `zipfs mkzip` writes an ordinary ZIP that
`unzip -l` lists. Tcl 9.0.1's `TclZipfs_AppHook` (which `tclAppInit.c`
calls) mounts only an archive appended to the executable; it never
mounts a ZIP given on the command line
(`SUPPORT_BUILTIN_ZIP_INSTALL` is not defined): the stock `tclsh9.0`
reads such an argument as a script and fails (`couldn't read file
".../app.zip": invalid or incomplete multibyte or wide character`, status
1). `zipfs mount` of the separate file from a script:

```
mounts: //zipfs:/app /private/var/folders/.../app.zip
glob: //zipfs:/app/botlish //zipfs:/app/main.tcl
normalize: //zipfs:/app/botlish/file.txt
dirname of main.tcl: //zipfs:/app
read: inside
writable: 1 wrmax: 2147483647
write, default wrmax: 1 file "//zipfs:/app/botlish/new.txt" not created: operation not supported
write, wrmax 0: 1 writes not permitted: permission denied
the archive file unchanged: 316 bytes
```

Paths inside the mount normalize to themselves, `file dirname` of a mounted
file is its directory in the mount -- what `main.tcl`'s `source` chain and
`core::libraryDir` compute from -- and the archive file is never written.
A file in a mount opens for writing by default (zipfs keeps the new
contents in memory, up to `::tcl::zipfs::wrmax` bytes); with
`::tcl::zipfs::wrmax 0` that is refused with EACCES ("writes not
permitted"), and a new file is refused either way (ENOTSUP). Both
startups now set `wrmax 0`: the compiler cannot modify its own files in
memory and then read the modified ones (the `zip-writable` mutant).

**The startup the launcher reproduces.** `TclZipfs_AppHook`, for a zipkit,
mounts the executable's archive at `//zipfs:/app`, sets the startup script
to `//zipfs:/app/main.tcl` (`Tcl_SetStartupScript`, so that the remaining
arguments are `::argv`, `$argv0` the script) and the script library to
`//zipfs:/app/tcl_library`. The launcher does the same with
`TclZipfs_Mount` of `Contents/Resources/botlish.zip`, the framework's
script library and the same startup script: `single/main.tcl` runs in
both with the same `::argv` and `$argv0` (`//zipfs:/app/main.tcl`), and
the checkout's `main.tcl` is sourced unchanged from `//zipfs:/app/botlish`
in both.

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

The census measured it (C4) with the framework's `tclsh9.0` as base kit
and a two-file archive:

| file | `codesign --verify --strict` | runs |
|---|---|---|
| `zipfs mkimg` output (linker's ad-hoc signature, archive appended) | `main executable failed strict validation` | yes |
| the same, re-signed `codesign --force --sign -` | signing itself reports `main executable failed strict validation`; verification fails | yes |
| base signed first, archive appended with `cat` | `main executable failed strict validation` | yes |
| the kit as an application bundle's main executable, bundle signed | `main executable failed strict validation`; `--deep` reports `invalid Info.plist (plist or signature have been modified)` | -- |

and `install_name_tool` refuses to edit the kit at all ("the `__LINKEDIT`
segment does not cover the end of the file"), so even its search path has
to be set before the archive is appended. The kit runs -- the kernel
enforces no signature on an ad-hoc binary that is only invalid in the
appended bytes -- but nothing about it is a signed, verifiable program;
Gatekeeper, notarization and any distribution channel that checks
signatures reject it. The application therefore keeps the archive as a
separate, sealed resource (section 7).

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

As built by `single/macos/build.sh` (run 40129027396; `find` without the
script library's files; sizes from `ls -l`):

```
Botlish.app/
  Contents/
    Info.plist                                     821 bytes
    MacOS/
      botlish                                      70,272   the launcher
      botlish-native                            6,084,288   the native driver
    Frameworks/
      Tcl.framework/
        Resources -> Versions/Current/Resources
        Tcl -> Versions/Current/Tcl
        Versions/
          Current -> 9.0
          9.0/
            Tcl                                 1.8 MB      libtcl9.0, install name @rpath/...
            Resources/                                      Info.plist, license.terms,
                                                            Scripts/ (Tcl's script library),
                                                            tcl9/ (Tcl's modules)
            _CodeSignature/CodeResources                    the framework's seal (238 files)
    Resources/
      botlish.zip                               1,957,243   190 files, 7,145,465 bytes unpacked
      libbotlish_runtime.a                     14,406,808   the runtime archive
    _CodeSignature/CodeResources                            the application's seal (4 files)
```

`Info.plist`: `CFBundleExecutable` botlish, `CFBundleIdentifier`
io.github.mwagner-webdev.botlish, `CFBundlePackageType` APPL,
`LSMinimumSystemVersion` 11.0, `LSBackgroundOnly` (no Dock icon, no menu
bar: it is a command-line program), `BotlishSourceRevision` (the commit it
was built from; `-version` prints the archive's `BUILD`, the same commit).
No `CFBundleIconFile`, no document types, no URL schemes.

`verify.sh`'s layout group checks this exactly: these names and nothing
else in each directory, the three framework links as symbolic links with
these targets, the executables executable, the two Info.plist keys. The
compiler archive's contents are section 13.

## 9. Tcl framework version and checksum

| | |
|---|---|
| version | Tcl 9.0.1 (`info patchlevel` 9.0.1; `-version` prints `Tcl: 9.0.1`) |
| source | `https://downloads.sourceforge.net/project/tcl/Tcl/9.0.1/tcl9.0.1-src.tar.gz` (mirror `prdownloads.sourceforge.net`), the official source release |
| sha256 | `a72b1607d7a399c75148c80fcdead88ed3371a29884181f200f2200cdee33bbc`, checked by `shasum -a 256 -c` before the tarball is unpacked |
| pin | `single/build.sh`'s `TCL_VERSION`, `TCL_SHA256`, `TCL_URLS`, which `tcl-framework.sh` reads: the Linux single executable's static Tcl and the macOS framework are the same release, and the canonical baseline of AGENTS.md ("Installing Tcl 9") |
| build | Tcl's own `unix/configure --enable-framework`, `-O2 -arch arm64`, deployment target 11.0; Tcl's libtommath built in, the system's zlib |
| recorded | the framework build's `BUILD` file (version, sha256, configure arguments, deployment target, install name) |

The launcher checks the loaded Tcl's version against the one it was
compiled against (`Tcl_GetVersion`, 9.0) and refuses another.

## 10. Framework install names and runtime search paths

```
$ otool -L Contents/MacOS/botlish
	@rpath/Tcl.framework/Versions/9.0/Tcl (compatibility version 9.0.0, current version 9.0.1, weak)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1351.0.0)
$ otool -l Contents/MacOS/botlish | grep -A2 LC_RPATH
          cmd LC_RPATH
      cmdsize 48
         path @executable_path/../Frameworks (offset 12)
$ otool -D Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl
@rpath/Tcl.framework/Versions/9.0/Tcl
$ otool -L Contents/MacOS/botlish-native
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1351.0.0)
```

* The framework's install name is `@rpath/Tcl.framework/Versions/9.0/Tcl`,
  set when it is linked (`DYLIB_INSTALL_DIR`), never rewritten afterwards
  with `install_name_tool`.
* The launcher has exactly one `LC_RPATH`, `@executable_path/../Frameworks`:
  dyld resolves Tcl relative to the launcher's own location, which is how
  the application runs wherever it is moved. It loads Tcl weakly
  (`LC_LOAD_WEAK_DYLIB`), so that a missing or damaged framework is the
  launcher's diagnostic, not a dyld abort (section 11).
* Nothing else in the bundle has a search path: the driver links only
  libSystem and libiconv, the framework only libSystem, zlib and
  CoreFoundation, all of them the system's. No path in any load command is
  absolute outside `/usr/lib` and `/System/Library`: no build directory,
  no `/Library/Frameworks`, no `/opt/homebrew`, no `/usr/local`
  (`verify.sh`'s dependency group checks every load command of every
  Mach-O in the bundle).
* The census's `DYLD_PRINT_LIBRARIES` run of a copy moved to "moved
  place/ü" lists exactly two images outside the system: the launcher and
  `.../moved place/ü/Botlish.app/Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl`.
* `DYLD_FRAMEWORK_PATH` naming a directory with another `Tcl.framework`
  makes dyld load that one (dyld searches it before the rpath, and an
  ad-hoc application is not protected from DYLD variables); the launcher
  then finds that the loaded Tcl is not its own and refuses (app-test's
  relocation group: "loaded Tcl from ..., not this application's own").

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
5. **A UTF-8 locale while Tcl starts.** When the environment's locale is
   not UTF-8 -- no locale at all is the C locale, whose codeset is
   US-ASCII -- the launcher sets `LC_ALL=UTF-8` before Tcl initializes and
   puts it back in AppInit, exactly as it was (unset, or its value, in the
   process's environment and in Tcl's `env` array) before anything else
   runs. Tcl 9.0.1 crashes otherwise when its framework's path is not
   ASCII: the census (C2) runs the framework's own stock `tclsh9.0` copied
   into "non ascii dü" and it ends in SIGSEGV without a locale and with
   `LC_ALL=C`, and runs with `LC_CTYPE=UTF-8` or `LANG=en_US.UTF-8`, and in
   an ASCII directory. The crash report and lldb (run 40131369183) put it
   in `Tcl_GetEncoding` (`EXC_BAD_ACCESS` at 0x5, reading the search path's
   directory array) from `Tcl_GetEncodingNameFromEnvironment`, from the
   *second* `TclpSetInitialEncodings`, the one `Tcl_MainEx` makes: Tcl
   looks for an encoding file named after the codeset ("us-ascii", which
   its table does not know), once while its system encoding is still the
   bootstrap ISO 8859-1 and again after it became UTF-8, and the second
   search reads a directory array that is not one -- by all appearances
   the encoding search path, a process-wide value Tcl converts between
   those two encodings, mangled where the path is not ASCII (not traced
   further: the cure is not to search). Tcl's 9.0 branch has since made the
   second `TclpSetInitialEncodings` a no-op (unix/tclUnixInit.c,
   `initialEncodingSet`), which avoids it. With a UTF-8 codeset Tcl finds
   its encoding in its table and searches no file. Nothing observable
   changes: `single/main.tcl` makes UTF-8 the system encoding anyway, a
   macOS path is UTF-8 whatever the locale, and the compiler's children
   see the user's `LC_ALL` (app-test's processes group links through a
   `cc` on PATH that records its environment, with `LC_ALL` unset, `C`
   and `en_US.UTF-8`: mutants `launcher-locale-kept` and
   `launcher-locale-leaked`).
6. **Failures** before the compiler runs are "botlish: ..." on standard
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

The archive is `Contents/Resources/botlish.zip`, written by `zipfs mkzip`
(`single/package.tcl -archive`): an ordinary ZIP
(deflated entries) that `unzip` reads. The launcher mounts it with
`TclZipfs_Mount(interp, ARCHIVE, "//zipfs:/app", NULL)` -- no password,
read through a read-only `mmap` of the file -- after `Tcl_Init`, before the
startup script runs. What follows from that:

* **The compiler's paths are archive paths.** `single/main.tcl` is
  `//zipfs:/app/main.tcl`; it sources `//zipfs:/app/botlish/main.tcl`, and
  everything the compiler computes from its own location --
  `core::libraryDir` (`//zipfs:/app/botlish/stdlib`), Compilerpedia's
  topics, `source` of `core/`, `hir/`, `surface/`, `service/`, `lsp/`,
  `native/*.tcl` -- is inside the mount. Nothing reads the checkout,
  the working directory or the environment for them (the
  `source-from-checkout` mutant, which makes the launcher source a
  checkout's main.tcl, is killed by the clean-environment job and by
  app-test's tamper and relocation groups).
* **Read-only.** The archive file is never opened for writing; with
  `::tcl::zipfs::wrmax 0` a write to an archived file is refused (EACCES,
  "writes not permitted") and a new file in the mount too (ENOTSUP), so the
  compiler cannot change its own sources in memory (C3; app-test's
  read-only group writes `-emit-hir-interchange` output into
  `//zipfs:/app/botlish/stdlib/` and expects the refusal).
* **Sealed.** The application's signature hashes the archive
  (`_CodeSignature/CodeResources`): a changed byte makes `codesign
  --verify` fail (section 29). The kernel does not check a resource when
  the launcher reads it; verification does.
* **Its identity.** The archive's `BUILD` is the source revision
  (`-version`: `source revision: COMMIT, packaged`), its `native-bin/ID`
  the CRC-32 and size of the bundle's driver and runtime archive
  (`-version`: `native backend: packaged (ID)`), computed after the driver
  is signed: `verify.sh` recomputes it from the bundle (`cksum -o 3`) and
  requires it equal, so an archive from another build is detected.
* **Failures are the launcher's.** A missing archive, one that is not a
  ZIP (truncated), and one without `main.tcl` are each reported before the
  compiler runs, with exit status 2 and the advice to reinstall (app-test's
  damage group).
* **What the mount does not hold.** No Tcl script library (the framework's
  `Resources/Scripts` is `tcl_library`), no native executable, no stub, no
  runtime archive, no tests, benchmarks or tools: `verify.sh` refuses an
  archive with a `tcl_library/` or a `native-bin/` executable.
* **Standard-library copies for editors.** The language server's
  definition of a standard-library name is a file an editor can open, so
  the compiler service copies the packed `stdlib/` once per build to a
  cache directory (`~/Library/Caches/botlish/stdlib-ID` on macOS, section
  26 has the cache's rules) and answers with that path; the copy is
  compared file for file with the archive (app-test's cache group).

## 13. Compiler and standard-library contents

`Contents/Resources/botlish.zip` holds 190 files, about 7.1 MB unpacked,
1.96 MB packed -- exactly what `single/package.tcl`'s `StageCompiler`
stages for the single executable too:

| archive path | files | what |
|---|---:|---|
| `main.tcl` | 1 | `single/main.tcl`, the startup script |
| `botlish/main.tcl`, `LICENSE`, `BUILD` | 3 | the checkout's main.tcl, unchanged; the license; the source revision |
| `botlish/core/` | 39 | the reference interpreter, values, natives' registry |
| `botlish/compiler/` | 1 | the Tcl compiler |
| `botlish/hir/` | 68 | the front end's analyses |
| `botlish/surface/` | 10 | lexer, parser, loader, lowering, the front-end cache |
| `botlish/service/` | 1 | the compiler service (`-check`) |
| `botlish/lsp/` | 10 | the language server (`-lsp`) |
| `botlish/native/*.tcl` | 9 | native lowering and the driver's Tcl side |
| `botlish/stdlib/` | 31 | every standard-library module |
| `botlish/compilerpedia/` | 16 | the engine, 14 topic files, the generated stdlib topic |
| `native-bin/ID` | 1 | the bundle's driver's and runtime archive's identity |

Two checks hold it to the checkout. `verify.sh`'s archive group compares
each of `core`, `compiler`, `hir`, `surface`, `service`, `lsp`, `stdlib`,
`compilerpedia/topics` and `compilerpedia/generated` with the checkout file
for file (names), and counts `native/*.tcl`; and `compare.sh` runs both
compilers on the same programs and requires the same output. Its census
compiles a one-line program importing each standard-library module (30
namespaces from 31 files: `std::linux::sys` is one namespace with an
architecture file per architecture) with `-check` through both: on macOS
the modules of other platforms (`std::linux*`, `std::windows*`) are refused
as UNSUPPORTED-PLATFORM, `std::ordered_table` as INTERNAL-NAMESPACE, by
both alike, and every other loads. Observed (run 40140537637): "the
standard library's 30 modules: 23 load; refused alike: linux, linux-io,
linux-path, linux-sys, windows, windows-io (SURFACE MODULE
UNSUPPORTED-PLATFORM), ordered_table (SURFACE MODULE INTERNAL-NAMESPACE)".

## 14. Compilerpedia contents

The archive's `compilerpedia/` is the checkout's engine, its 14 topic files
and `generated/stdlib.topic`: `-help all` through the application lists
the same 845 topics as the checkout's topic files (`compare.sh`'s census;
the count is computed from the checkout, never written in the script),
and `-help`, `-help warnings`, `-help cli.options`, `-help
std::list::at`, `-help KNOWN-ERROR` and `-help "bounds proof"` print the
same text as the checkout's, after the invocation (`botlish` for
`tclsh9.0 main.tcl`) and the wrapping it moves. The "help:" lines under a
diagnostic name the application's invocation (`botlish -help
error.unsupported-platform`). Compilerpedia reads only those files; it
never compiles, loads a module or starts the native backend
(`single/smoke-test.sh`: every `-help` query runs no program).

## 15. Compiler-service and LSP acceptance

The compiler service and the language server are the checkout's, packed
(`service/`, `lsp/`), run by the application's own Tcl from the archive.

* **`-check`.** The service's command-line client prints what the
  checkout's prints, in `compare.sh`'s runs of:
  - the diagnostics programs: a syntax error, a type error, a missing
    module, and `std::web`'s own warnings, located in
    `//zipfs:/app/botlish/stdlib/web.bot`;
  - every sample at once;
  - the thirty standard-library loaders (section 13).
* **An editor session.** `single/smoke-test.sh` frames the session by
  hand and runs it in an empty environment:
  - Standard output begins with a protocol header (`Content-Length: `).
    Nothing comes before it: no banner (mutant `startup-banner`).
  - The hover on an application module's function is `fn
    shapes::area(w: int, h: int) -> int`.
  - The published diagnostics include `unbound name "nosuch"`.
  - The definition of `std::list::get` is
    `.../Library/Caches/botlish/stdlib-df0224a5/list.bot`: a real file,
    never a `//zipfs:` path, which an editor cannot open.
  - Standard error reports that the analysis worker started. The worker
    is a second run of the launcher: the server starts it from `info
    nameofexecutable`, which is the launcher's real path (section 11).
    That environment's PATH has no `tclsh`.

  The session passed in "Prögram Files" (the app job), and in "Clean
  Äpps" with the developer tools removed (section 19).
* **Its processes.** In app-test's processes group, a SIGINT sent to the
  server's process group, as a terminal sends it, ends both the server
  and its analysis worker (pid 10104 in run 40140537637). Neither
  outlives the interrupt.
* **Its cache.** In app-test's cache group:
  - The library's copy goes to `~/Library/Caches/botlish/stdlib-ID` of
    a HOME named "hömé dir"; nothing else is written in HOME.
  - A second session reuses the copy (same file, same mtime).
  - `BOTLISH_CACHE_DIR` replaces the location.
  - An unwritable HOME gets the diagnostic "cannot be copied out of the
    executable", and nothing is written there.
  - Two servers started at once in one fresh cache leave one copy,
    equal file for file to the archive's `stdlib/`.

  The mutant `cache-in-bundle`, which writes the copy inside the bundle,
  is killed.
* **A moved bundle.** In app-test's moved group, the application is
  moved to another directory while its server runs. The hover asked
  after the move is answered (`fn area(w: int, h: int) -> int`), the
  server exits with status 0 at `exit`, and the moved bundle verifies.
* **Cost.** A whole session (initialize, one document's diagnostics,
  shutdown; synchronous scheduler) takes 74.1 ms, best of 7 (section
  34).

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
executable checks when it starts. When the archive is missing or unusable,
a driver in an application bundle names the application's damage ("the
macOS application carries it as Contents/Resources/libbotlish_runtime.a:
the application is incomplete or damaged (reinstall it)"), never a cargo
build: its user has no checkout (`runtime_remedy`, read from the same
`application_contents` test of the driver's path as the archive's
location; app-test's damage group deletes the archive and replaces it with
an x86_64 one, and fails on any mention of Rust, cargo, Homebrew or
installing Tcl). Unit tests
`packaged_runtime_archive_follows_the_driver` and
`runtime_remedy_is_the_distributions`; `tests/system-linker.test`'s
`system-linker-bundle-runtime` places a driver in "Bötlish Test.app",
runs `botlish-native system-linker` from `/` and links with it (macOS),
and checks that every other host keeps the archive beside the driver;
mutants `sys-runtime-bundle-ignored`, `sys-runtime-bundle-relative` and
`sys-runtime-bundle-remedy-build`.

## 18. System-linker selection

`BOTLISH_NATIVE_LINKER=auto` (`single/main.tcl`, unless the environment
names a linker) is the system linker on macOS for every executable: the
stub is Linux x86-64's (`STUB_LINKER`). No change to the selection.

## 19. Toolchain-free operations

The job "Botlish.app without developer tools" (run 40140537637, job
121013898572) runs on a fresh macos-15 runner:

1. **Before.** Xcode 16.0 to 26.3 and `/Library/Developer/CommandLineTools`
   are installed. There is no `tclsh9.0`, `rustc` and `cargo` are in
   `~/.cargo`, there is no Homebrew Tcl, and `/usr/bin/tclsh` is the
   system's.
2. **The download.** The job downloads the app job's artifact
   (`actions/download-artifact` checks its digest), runs `shasum -a 256
   -c botlish-macos-aarch64.zip.sha256` (`OK`), and unzips it into
   `$RUNNER_TEMP/Clean Äpps`.
3. **Removing the tools.** It copies `single/smoke-test.sh`,
   `single/macos/verify.sh` and five `examples/` directories out, then:
   - deletes the checkout (`rm -rf "${GITHUB_WORKSPACE:?}"/*` and its
     dot files);
   - moves `~/.cargo` and `~/.rustup` away;
   - moves every `/Applications/Xcode*.app` and
     `/Library/Developer/CommandLineTools` to
     `/private/var/hidden-developer`.

   After that, `xcode-select -p` says "Unable to get active developer
   directory", and `/usr/bin/cc --version` says "xcode-select: note: No
   developer tools were found, requesting install." The job fails if cc
   still runs.
4. **Verification.** `codesign --verify --deep --strict` (codesign is the
   system's, not the developer tools') reports the bundle valid on disk
   and that it satisfies its Designated Requirement. `verify.sh
   --no-developer-tools` reports:
   - layout: ok;
   - dependencies: SKIPPED (otool and lipo are developer tools);
   - signature: ok;
   - archive: ok (190 files).
5. **The smoke test.** `single/smoke-test.sh` finds no tclsh9.0, rustc or
   cargo on the host, and passes:
   - interp, compile and cranelift: 23 values each;
   - the usage, the `-help` pages, `-version` and every inspection
     option;
   - a rejected program;
   - an application module 3000 calls deep, on all four backends;
   - non-ASCII directories and arguments with no locale;
   - the standard library read from inside the archive;
   - a native run without HOME;
   - `-emit-native-executable` refused with NATIVE LINK TOOLCHAIN and
     `xcode-select --install`, with no mention of Rust;
   - a C program's link refused (NATIVE LINK TOOLCHAIN);
   - `-lsp`: hover, diagnostics and definition.

**What runs without the developer tools:**
* the Tcl backends;
* the native JIT (`cranelift`, `cranelift-generic`) of a program that
  calls no C;
* `-check`, `-lsp`, `-help`, `-version` and the inspection options.

**What needs them:**
* every standalone executable: the system linker is Apple's `cc`;
* a native run of a program that calls C, which is a linked run
  (C-FFI.md). On macOS that includes every program that prints through
  `std::io`: `std::darwin::io` is libSystem's C
  (MACOS-AARCH64-MILESTONE-8.md), and the Tcl backends refuse C calls
  (NATIVE-ONLY). The clean job does not run this case: its smoke test
  checks the executable's refusal and the C program's.

The refusal names the remedy, `xcode-select --install`, and never Rust
(mutant `sys-apple-remedy-rust`).

## 20. Native executable compilation

Every executable is linked by the system linker (auto, section 18) from
the application, with PATH=/usr/bin:/bin.

* **app-test's executables group.**
  - A copy of the application emits `coroutine`, `coroutine-kept`,
    `context`, `overflow` and `args`, and is then deleted.
  - Each is a Mach-O 64-bit executable for arm64 (`file`) with `LC_MAIN`.
    `otool -L` names only `/usr/lib` and `/System/Library`, there is no
    `LC_RPATH`, and `strings` names neither `Botlish.app` nor the
    builder's directory.
  - Run with `env -i` from `/`, they print:
    - coroutine: `[0, 1, 4, -1]`, also under GC stress;
    - coroutine-kept: `[[0, [1, 4, -1]], [4, 5, 6, 7, -1]]`, also under
      GC stress;
    - context: `[3, 42, -6]`;
    - args: the arguments `a`, `b c` and `ü` as given;
    - overflow: `NATIVE LIMIT STACK`, with status 1.
* **`compare.sh`.** Five programs are linked by both the checkout's
  compiler and the application's. Output, status and startup report
  (`BOTLISH_NATIVE_STARTUP_REPORT`) are the same, plainly and under GC
  stress.
* **`single/smoke-test.sh`.** `hello.bot` (Darwin IO) is linked and run,
  also with no HOME.
* **`single/ffi-smoke-test.sh`.** Five executables, a to e, of 828,840
  to 869,704 bytes, each needing only `/usr/lib/libiconv.2.dylib` and
  `/usr/lib/libSystem.B.dylib`. They run with the compiler, its cache and
  the C libraries deleted, also under GC stress (section 22).
* **Cost.** `-emit-native-executable` of a small program takes 167.8 ms,
  of which the object and the link are about 48.6 ms (section 34).

## 21. Darwin IO acceptance

* **app-test's darwin-io group.**
  - `-check hello-darwin.bot` is ok.
  - Its `-emit-nir` holds a function
    `std::io::print_line<std::io::IO=std::darwin::io::DarwinIO>` that
    calls `std::darwin::io::write_text` directly: the context trait is
    selected statically, with no dispatch.
  - Its executable links `/usr/lib/libSystem.B.dylib` and prints `Hello,
    world!`, then `unit`.
* **`compare.sh`.** `hello-darwin.bot` matches the checkout:
  - on both native backends (a linked run), plainly and under GC stress;
  - as an executable;
  - in `-emit-nir`.
* **`single/ffi-smoke-test.sh`'s E.** `std::io::print_line` through
  `std::darwin::io` prints `Hello from portable IO`, then `unit`. It is
  linked by the system linker: Darwin arm64 has no stub.
* **app-test's concurrency group.** Four links of `hello-darwin.bot` at
  once in one HOME; each executable prints.
* **`single/smoke-test.sh`.** A native run shows the program's output
  before its value on both native backends.

## 22. Static C fixture acceptance

`single/ffi-smoke-test.sh` runs with Apple clang 17.0.0
(clang-1700.0.13.5) on PATH=/usr/bin, and checks that no Rust is
reachable. It builds `tests/cffi/fixture.c` into
`libbotlish_cffi_fixture.a`, and a second library depending on it,
`libbotlish_cffi_dependent.a`, with the host's cc. Then it compiles with
the application (run 40140537637):

| program | what | result |
|---|---|---|
| a | libc's `labs` | `42` |
| b | `bcf_add` and `bcf_add_twice` from the two static libraries, declared in the order that needs GNU ld's group on Linux (macOS's ld needs none), and the variadic `bcf_vsum(3, 1, 20, 300)` | `[42, 42, 321]` |
| c | borrowed Bytes and MutableBytes (section 23) | `[37602, 1768, 888]` |
| d | errno through `__error()`, and the `(size_t)-1` sentinel (section 23) | `[[16, 0, 1736], [-1, 34, 1736], [18446744073709551615, 5], [42, 0]]` |
| e | `std::io` through `std::darwin::io` | `Hello from portable IO \| unit` |

* **The executables.** Each runs after the compiler, its cache and the C
  libraries are deleted, also under GC stress, and needs only libSystem
  and libiconv (`otool -L`).
* **The refusals:**
  - no C compiler: NATIVE LINK TOOLCHAIN;
  - a missing library: named (`definitely_missing_botlish_lib`);
  - an undefined symbol: named (`botlish_no_such_symbol`);
  - `BOTLISH_NATIVE_LINKER=stub`: "links no native library".
* **A linked run.** `b` also runs on `-backend cranelift`.

The same script gives the same values with the Linux single executable
(section 35).

## 23. C borrowing and error-capture acceptance

Programs c and d of section 22 are the application's end-to-end check of
byte borrowing and error capture:

* **c, borrowing.**
  - `bcf_sum` (`read noescape`) reads 300 bytes of Botlish storage in
    place: 37602.
  - `bcf_fill` (`write noescape`) writes 16 bytes into a private copy,
    returned as the call's `out`: its checksum is 1768.
  - The original MutableBytes is unchanged by the write exposure: its
    checksum is 888.
* **d, error capture.**
  - `bcf_fill_errno` succeeds: `[16, 0, 1736]`.
  - It fails with errno 34 (ERANGE), read through `__error()` right after
    the call: `[-1, 34, 1736]`.
  - `bcf_large_error` returns SIZE_MAX, a 64-bit C word compared as it
    is, with errno 5: `[18446744073709551615, 5]`.
  - On success it returns `[42, 0]`.

These are the Linux single executable's values too. The lowering's own
tests run the checkout on macOS, not the application:
`tests/c-pointer-borrowing.test`, `tests/c-byte-borrowing.test` and
`tests/c-ffi-error-capture.test`, in the acceptance tier (the macOS
workflow's Tier B). The application's front end is the checkout's, file
for file (section 13). Its driver is the same `cargo build`'s, stripped
of debug symbols and re-signed.

## 24. Native JIT behavior

The application's driver runs Cranelift's JIT in place, from
`Contents/MacOS`. It is signed ad hoc, with no hardened runtime and no
entitlement (`flags=0x2(adhoc)`).

* **`compare.sh`.** Both compilers agree on:
  - the 24 sample programs (examples/surface, examples/stdlib) on
    interp, compile, cranelift and cranelift-generic: 96 runs alike;
  - the acceptance programs (coroutines fused and kept, closures, a
    context, the stack overflow) on every backend, and natively under GC
    stress;
  - `args.bot` with non-ASCII and invalid-UTF-8 arguments (`-argv-hex
    41ff`) on interp and cranelift;
  - the 2048 benchmark on cranelift;
  - `hello-darwin.bot` on both native backends.

  The counts, the samples' 96 included:
  - run 40140537637, before `coroutine-kept.bot` was added: "the
    acceptance programs, natively also under GC stress: 125 runs alike";
  - run 40452138744: 131 runs alike, and "157 comparisons, the
    application and the checkout alike" in all.
* **A runtime error.** `overflow.bot`'s unbounded recursion ends in
  `NATIVE LIMIT STACK` (the stack guard, MACOS-AARCH64-MILESTONE-4.md):
  - on both native backends, with status 1 through the launcher
    (app-test's processes group);
  - in an executable;
  - with the same text as the checkout's (`compare.sh`).

  This is the only runtime error the application's own tests exercise.
* **The census (C6).** The bundle's driver runs a JIT program. So does a
  copy signed with the hardened runtime and no entitlement, and copies
  with `com.apple.security.cs.allow-jit` or
  `allow-unsigned-executable-memory`. On these runners that shows less
  than it seems: `csrutil status` reports "disabled", and whether the
  signing variants behave the same on a Mac with SIP enabled was not
  tested. The hardened-runtime observation is no evidence for a user's
  Mac (section 41). The shipped driver has no hardened runtime.
* **Time.** A native run of a small program takes 119.2 ms, 14.6 ms more
  than the interpreter's run of it (section 34).

## 25. GC stress and coroutines

`BOTLISH_NATIVE_GC_STRESS=1` forces a collection at every allocation
site. Through the application:

* **The two coroutine programs.**
  - `coroutine.bot` is fused into its function (the driver's fusion log:
    `fused drive e22 {... yields 1 creates 1 starts 1 resumes 3 ...}`).
  - `coroutine-kept.bot` is kept on the general runtime: `kept passed
    ... {its handle reaches ... call ...}` and `kept tree ... {its
    yielding function leaves is recursive}`. Its coroutines are objects
    with stacks of their own, switched at every resume and yield, and
    the collector walks their suspended frames, which hold the structs
    they made.

  Both logs come from this checkout on Linux. The pass reads the
  program's NIR, not the host, and runs wherever native coroutines do,
  macOS AArch64 included.
* **`compare.sh`.** These two, `closures.bot`, `context.bot`,
  `overflow.bot` and `hello-darwin.bot` run on cranelift and
  cranelift-generic under GC stress, alike with the checkout. The five
  executables under GC stress give the same output and startup report.
* **app-test.** The executables group runs both coroutine executables
  under GC stress. The concurrency group runs `coroutine-kept.bot`
  natively four times at once.
* **`single/ffi-smoke-test.sh`.** Every executable runs under GC stress.

Run 40140537637 had only the fused program. The application's tests
therefore exercised no coroutine object, stack switch or walk of a
suspended stack until `coroutine-kept.bot` was added (commit d1e2de57).
In run 40452138744 it passed every one of the checks above.

## 26. Relocation and symlink tests

* **app-test's relocation group.**
  - A copy in "A dir with spaces/Ünïcödé" runs (cranelift, value 50),
    also with `LC_ALL=C`, and verifies.
  - Moved to another directory, it runs and verifies.
  - Through a symbolic link to the launcher on PATH, invoked as
    `botlish` from `/`: `-version` says `invocation: botlish` and
    `native backend: packaged`, and a native run works.
  - Through a symbolic link to the bundle (`Linked.app`), it runs.
  - A `TCL_LIBRARY` naming a decoy script library, and
    `BOTLISH_NATIVE_BIN=/nonexistent/botlish-native`, change nothing: no
    "DECOY", value 50.
  - `DYLD_FRAMEWORK_PATH` naming a copy of the framework whose
    `init.tcl` announces itself: dyld loads that copy, and the launcher
    refuses it ("not this application's own", status 2). The mutant
    `framework-from-system` removes that check and is killed.
* **The census (C5).** A copy in "moved place/ü" runs `-version` and
  verifies. `DYLD_PRINT_LIBRARIES` lists the launcher and the moved
  bundle's Tcl, and nothing else outside the system.
* **app-test's paths group.** An application of two files in "sources
  dir/ünï cödé":
  - by absolute path from `/`, on all four backends (value 42);
  - by relative path;
  - with `-argv 'ü' -argv 'two words'`;
  - as an executable built in that directory, which receives `ü` and
    `two words`.
* **A moved application's first start.** For three fresh copies, the
  first `-version` took 71.8 to 90.4 ms and the second 70.8 to 128.6 ms
  (section 34): nothing is installed or extracted at first start.
* **The CI app job itself** runs every acceptance on a copy unpacked to
  `$RUNNER_TEMP/Prögram Files`, outside the checkout. The clean job uses
  "Clean Äpps".

## 27. Read-only bundle tests

In app-test's read-only group, the copy is made read-only (`chmod -R
a-w`), and `touch` inside it fails. Then:

* `single/smoke-test.sh`'s whole run passes on it ("12 checks": the
  smoke test's summary lines).
* A write into the archive is refused ("writes not permitted"). The
  write comes from `-emit-hir-interchange
  //zipfs:/app/botlish/stdlib/ascii.bot`, whose output would go beside
  the file. The mutant `zip-writable` is killed: with it, zipfs keeps the
  write in memory.
* Afterwards every file's mode, size, mtime and SHA-1 are unchanged
  (`stat`, `shasum`), and the copy verifies.

The app job's last step verifies the bundle the whole job ran from ("The
application, untouched by the runs"). The application never writes into
itself: the language server's cache is outside it (section 15).

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

## 29. Signature verification and tamper controls

* **Verified.** `codesign --verify --deep --strict --verbose=4` of the
  built application validates the framework's version and the driver,
  then reports "valid on disk" and "satisfies its Designated
  Requirement". It reports the same for:
  - the copy in "Prögram Files" after every run;
  - the moved copies;
  - the copy in "moved place/ü";
  - the copy in "Clean Äpps", without developer tools.
* **The signatures** (`codesign -dvvv --entitlements -`):

  | | identifier | format | sealed |
  |---|---|---|---|
  | application | `io.github.mwagner-webdev.botlish` | app bundle with Mach-O thin (arm64) | `Sealed Resources version=2 rules=13 files=4` |
  | framework | `com.tcltk.tcllibrary` | bundle with Mach-O thin (arm64) | `files=238` |
  | driver | `io.github.mwagner-webdev.botlish.native` | Mach-O thin (arm64) | `Info.plist=not bound` |

  Each has `flags=0x2(adhoc)`, `Signature=adhoc` and `TeamIdentifier=not
  set`. None has entitlements.
* **Gatekeeper.** `spctl --assess --type execute`: `rejected`, as
  expected for an ad-hoc signature.
* **Tamper.** In app-test's tamper group, one byte is changed in a copy
  of each part, and strict verification rejects every one:

  | changed | `codesign --verify --deep --strict` |
  |---|---|
  | a byte of `botlish.zip` | a sealed resource is missing or invalid |
  | a byte of the driver | invalid signature (code or signature have been modified) |
  | a byte of the launcher | invalid signature (code or signature have been modified) |
  | a byte of the framework's binary | invalid signature ... In subcomponent |
  | an added resource | a sealed resource is missing or invalid |
  | a byte of the framework's `init.tcl` | a sealed resource is missing or invalid In subcomponent |
  | the bundle copied with `cp -RL` (the framework's links as files) | bundle format is ambiguous (could be app or framework) |

* **What verification does not do.** The copies with a changed driver
  and a changed launcher still ran, with status 0: the native run
  printed value 50, and `-version` printed. We did not establish why.
  The kernel validates a signed page as it is paged in, and these
  runners have SIP disabled. Nothing here shows what a Mac with SIP
  enabled does. Strict verification is the check this milestone relies
  on, and it rejects both. The mutants `modified-after-signing` and
  `zip-changed-after-signing` (a change after the build signed) are
  killed by `verify.sh`.

## 30. Distribution archive integrity

* **How it is made.** `single/macos/build.sh` archives the signed bundle
  with `ditto -c -k --norsrc --noextattr --noacl --keepParent
  Botlish.app botlish-macos-aarch64.zip`. ditto keeps the framework's
  symbolic links as links, and the modes. The script writes `shasum -a
  256` beside the archive, unzips it into a temporary directory and
  verifies what it unpacked (`verify.sh --checkout`: layout, the links,
  dependencies, signature, the archive's contents against the checkout).
* **The app job (run 40140537637).** `f32acfea50104f807eff2d5e3200661870774e392801bf32030dd1cd263566d2
  botlish-macos-aarch64.zip`, 10,700,286 bytes. The job unpacks it again
  with `unzip` into "Prögram Files" and runs `verify.sh` there before
  any test. The artifact is uploaded last, only when every step passed.
* **The clean job.** `actions/download-artifact` checks the artifact's
  digest, `shasum -a 256 -c` prints `botlish-macos-aarch64.zip: OK`, and
  the unpacked bundle verifies strictly with no developer tools
  (section 19).
* **Mutants.** `archive-without-links` stores the links as files; it is
  killed ("Tcl.framework/Versions/Current is not the symbolic link to
  9.0"), as is the `cp -RL` tamper control above.
* **Not reproducible byte for byte.** The mutants job built the same
  commit on another runner. Its download was 10,700,290 bytes, SHA-256
  `028a225cc863cb141b863e07b8b548ffe501e3989fc828dcf6a4d0dd442199ef`.
  The compiler archive inside was the same size in both (1,958,413
  bytes). The checksum identifies a download, not a build. We did not
  look further into which bytes differ.

## 31. Dynamic dependency inspection

The app job's inspect step (run 40140537637):

| Mach-O | `file`, `lipo -archs` | `otool -L` | other load commands | `LC_BUILD_VERSION` |
|---|---|---|---|---|
| `MacOS/botlish` | Mach-O 64-bit executable arm64 | `@rpath/Tcl.framework/Versions/9.0/Tcl` (weak), `/usr/lib/libSystem.B.dylib` | `LC_RPATH @executable_path/../Frameworks` | minos 11.0, sdk 15.5 |
| `MacOS/botlish-native` | Mach-O 64-bit executable arm64 | `/usr/lib/libiconv.2.dylib`, `/usr/lib/libSystem.B.dylib` | none | minos 11.0, sdk 15.5 |
| `Tcl.framework/Versions/9.0/Tcl` | dynamically linked shared library arm64 | `LC_ID_DYLIB @rpath/Tcl.framework/Versions/9.0/Tcl`; `/usr/lib/libz.1.dylib`, libSystem, CoreFoundation | none | minos 11.0, sdk 15.5 |
| `Resources/libbotlish_runtime.a` | `lipo -info`: non-fat, arm64 | (an archive) | | |
| every executable it links | Mach-O 64-bit executable arm64 | libiconv, libSystem | `LC_MAIN`, no `LC_RPATH` | |

* **Loaded at run time.** `DYLD_PRINT_LIBRARIES` of a moved copy shows
  only the launcher and the moved bundle's Tcl outside `/usr/lib` and
  `/System/Library` (section 10).
* **Checked.** `verify.sh`'s dependency group checks every load command
  of every Mach-O in the bundle. It kills the mutants
  `launcher-system-tcl`, `launcher-build-tcl`, `rpath-outside-bundle` and
  `modified-after-signing`, each of which leaves another `LC_RPATH`.

## 32. Mutation results

`audit/macos-app/tools/mutate.tcl` builds the unmutated application and
requires it to pass every detector. Then, for each mutant, it builds the
application and runs the detectors (`verify.sh`, the smoke tests,
`app-test.sh`, the archive's checks) until one fails. Results of the
app-mutants job, run 40140537637, on macos-15:

| mutant | what it breaks | killed by |
|---|---|---|
| `launcher-system-tcl` | search path `/Library/Frameworks` | verify: the launcher's `LC_RPATH` |
| `launcher-build-tcl` | search path the framework's build directory | verify: `LC_RPATH` |
| `rpath-outside-bundle` | search path beside `Frameworks` | verify: `LC_RPATH` |
| `tcl-library-from-environment` | no `tcl_library`: `$TCL_LIBRARY` first | app relocation: DECOY TCL LIBRARY |
| `launcher-locale-kept` | Tcl starts in the environment's locale | app relocation: the copy in a non-ASCII path does not run |
| `launcher-locale-leaked` | `LC_ALL=UTF-8` never put back | app processes: the linker ran with LC_ALL 'UTF-8' |
| `zip-omitted` | no compiler archive | verify layout |
| `zip-wrong-mount` | mounted elsewhere than `//zipfs:/app` | smoke: a native run |
| `zip-writable` | `wrmax` left: writes kept in memory | app read-only: a write into the archive |
| `source-from-checkout` | the compiler sourced from the checkout | smoke: the standard library not read from inside |
| `stdlib-module-omitted` | `std::darwin` left out | verify archive: stdlib differs |
| `compilerpedia-omitted` | no topics | verify (main.tcl fails) |
| `backend-omitted` | no driver | verify layout |
| `backend-from-environment` | `BOTLISH_NATIVE_BIN` from the environment | app relocation |
| `runtime-omitted` | no runtime archive | verify layout |
| `runtime-relative` | runtime archive relative to the working directory | smoke: emit hello |
| `linker-rustc` | linker rustc, not auto | smoke: emit hello |
| `argument-dropped` | the launcher drops an argument | smoke: a native run |
| `startup-banner` | a greeting on standard output | smoke: `-help warnings` |
| `cache-in-bundle` | the library copy inside the bundle | smoke: `-lsp` copied outside `~/Library/Caches/botlish` |
| `modified-after-signing` | the launcher changed after signing | verify: `LC_RPATH` |
| `framework-unsigned` | the framework never signed | verify layout: no `_CodeSignature` |
| `backend-unsigned` | the driver keeps the linker's signature | verify signature: identifier |
| `zip-changed-after-signing` | the archive rewritten after signing | verify: `codesign --verify` rejects |
| `archive-without-links` | the download stores links as files | archive: `Versions/Current` |
| `framework-from-system` | any loaded Tcl accepted | app relocation: DYLD_FRAMEWORK_PATH's Tcl ran |

"26 mutants: 26 KILLED; killed by: framework loading 4, compiler behavior
10, packaging 6, ZIP mounting 1, runtime linking 3, code signing 2."
On d1e2de57 (run 40452138744) the same harness passed again: its exit
status is non-zero for any surviving or unapplied mutant.

**The driver's mutants** (`audit/native-aot/tools/mutate.tcl -only
sys-runtime-bundle-ignored,sys-runtime-bundle-relative,sys-runtime-bundle-remedy-build,sys-apple-remedy-rust,sys-executable-rpath`):

| mutant | macos-aarch64 (runs 40140537637 and 40452138744) | linux-x86_64 (this container) |
|---|---|---|
| `sys-runtime-bundle-ignored` | killed (system-linker.test: `system-linker-bundle-runtime`) | skipped (not compiled differently for Linux) |
| `sys-runtime-bundle-relative` | killed (Rust `packaged_runtime_archive_follows_the_driver`, system-linker.test) | killed (Rust) |
| `sys-runtime-bundle-remedy-build` | killed (Rust `runtime_remedy_is_the_distributions`) | killed (Rust) |
| `sys-apple-remedy-rust` | killed (Rust `toolchain_remedy_is_the_platforms`) | killed (Rust) |
| `sys-executable-rpath` | killed (Rust `system_link_args_*`, system-linker.test) | killed (Rust, system-linker.test) |

**The single executable's mutants**
(`audit/single-executable/tools/mutate.tcl`, Linux x86-64, at d1e2de57's
tree): 9 mutants, 9 killed. The shared staging and `single/main.tcl`'s
new branch kill nothing of its own.

## 33. Bundle and download sizes

`bench/macos-app.tcl`, run 40140537637 (MiB, files only, symbolic links
not counted):

| part | MiB | bytes |
|---|---:|---:|
| `Frameworks/Tcl.framework` (the library 1.74 MiB, its script library 2.55 MiB, on disk) | 4.03 | |
| `MacOS/botlish` (the launcher) | 0.07 | 70,928 |
| `Resources/botlish.zip` (the compiler: 190 files, 7,149,215 bytes unpacked) | 1.87 | 1,958,413 |
| `MacOS/botlish-native` (the driver, `strip -S`) | 5.80 | 6,084,384 |
| `Resources/libbotlish_runtime.a` | 13.74 | 14,406,808 |
| **Botlish.app** | **25.51** | |
| **download** (`botlish-macos-aarch64.zip`) | **10.20** | 10,700,286 |

The runtime archive is more than half of the bundle. Only links read it,
and it is the system linker's input (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md).
For comparison, the Linux single executable built from the same tree is
13,910,137 bytes (static Tcl, and an archive holding the driver, the stub
and the runtime archive).

## 34. Startup and build performance

`bench/macos-app.tcl` on the app job's runner (macos-15 arm64, a shared
CI machine), in runs 40140537637 and 40452138744 (two runners, the
second building d1e2de57). Each figure is the best of 7, in ms, each run
a fresh process with HOME and PATH only:

| measured | 40140537637 | 40452138744 |
|---|---:|---:|
| process: the launcher exiting before Tcl (no framework) | 3.6 | 4.6 |
| tcl: + loading Tcl.framework and `Tcl_Init` | 12.0 | 10.9 |
| mount: + mounting the archive | 13.4 | 12.6 |
| `-version`: + `single/main.tcl` and `main.tcl` | 86.4 | 73.4 |
| `-help` (Compilerpedia's overview) | 119.5 | 116.2 |
| `-check` of a small program | 112.6 | 118.7 |
| the same program on the interpreter | 104.6 | 109.6 |
| a language-server session (section 15) | 74.1 | 74.3 |
| the driver's own start | 6.0 | 4.7 |
| the program on cranelift (JIT) | 119.2 | 120.7 |
| `-emit-native-executable` of it | 167.8 | 173.3 |

| phase (difference) | 40140537637 | 40452138744 |
|---|---:|---:|
| loading Tcl.framework and `Tcl_Init` (tcl - process) | 8.4 | 6.3 |
| mounting the archive (mount - tcl) | 1.4 | 1.7 |
| the compiler's startup (-version - mount) | 73.0 | 60.8 |
| lowering, the driver, Cranelift and the run (jit - interp) | 14.6 | 11.1 |
| the object and the link (executable - jit) | 48.6 | 52.6 |

* **Moving costs nothing.** A moved application's first and second
  `-version`, for three fresh copies:
  - run 40140537637: 71.8/70.8, 90.4/100.7 and 83.4/128.6 ms;
  - run 40452138744: 78.2/83.3, 75.4/79.2 and 78.0/83.6 ms.

  There is no first-start installation, extraction or cache to fill. The
  spread is the shared runners'.
* **The startup is the compiler's sources.** Loading the framework and
  mounting the archive together take under 10 ms. Sourcing the compiler
  from the archive takes 61 to 73 ms.
* **The build.** `single/macos/build.sh` took 96 s on the app job's
  runner, from the step's start to its end. That covers the framework
  built from source (the cache missed), the cargo build (cached: 0.30
  s), the launcher, signing, the archive, `ditto` and both
  verifications.

## 35. Linux single-executable regressions

The shared parts are `single/package.tcl`'s `StageCompiler`,
`single/main.tcl`, `single/smoke-test.sh`, `single/ffi-smoke-test.sh` and
the driver's runtime-archive lookup. Observed:

* **`single-executable` workflow, run 40131935089 on c7d581f6.** This
  commit carries the shared staging, `single/main.tcl`'s re-decoding and
  the portable smoke tests. Success: build, and smoke and FFI smoke tests
  in stock containers. On d1e2de57: run 40451935419, also success.
* **Locally, Linux x86-64, at d1e2de57's tree:**
  - `single/build.sh`: 13,910,137 bytes.
  - `single/smoke-test.sh` passed: interp, compile and cranelift 23
    values each; `-lsp` hover, diagnostics, and definition into
    `~/.cache/botlish/stdlib-df0224a5/list.bot`.
  - `single/ffi-smoke-test.sh`: a `42`; b `[42, 42, 321]`; c `[37602,
    1768, 888]`; d `[[16, 0, 1736], [-1, 34, 1736],
    [18446744073709551615, 5], [42, 0]]`; e stub-linked with no C
    compiler on PATH. These are the macOS application's values.
  - `audit/single-executable/tools/mutate.tcl`: 9 of 9 killed.
  - `cargo test ... aot::`: 19 passed.
  - `tests/system-linker.test`: 15 of 15.
  - `tests/main-cli.test`: 63 of 63.
  - `tests/compilerpedia.test`: 39 of 39.
  - `tools/compilerpedia.tcl check`: 845 topics, 627 examples, 0
    problems.
* **`tests` workflow, run 40131786095 on c7d581f6.** All 14 jobs green:
  - interp and compile;
  - cranelift and cranelift-generic coverage;
  - stub-linked executables;
  - system-linked executables, also under GC stress;
  - golden shards 1 to 4;
  - the warning gate;
  - the native Rust unit tests;
  - the method-call decision.

  On d1e2de57 (run 40451930787), whose later changes are the driver's
  remedy and the macOS scripts, 9 of the 14 jobs passed:
  - the stub-linked executables;
  - golden shards 1 to 4;
  - the warning gate;
  - the native Rust unit tests;
  - the method-call decision.

  Five failed, every one on tests this milestone does not touch:
  - **interp, compile, and cranelift and cranelift-generic coverage:**
    `c-bindgen.test`'s `cb-fixture-current`, `cb-fixture-contracts` and
    `cb-policy-conflict`, and nothing else.
  - **The system-linked executables:** those three, and `c-ffi.test`'s
    `cf-wrong-architecture`.

  Between the two runs, GitHub's `ubuntu-latest` image moved from Ubuntu
  24.04 to 26.04 ("Ubuntu 26.04.1 LTS", image ubuntu-26.04 20261012.163):
  - **clang 18.1.3 became clang 21.1.8.** Its IR names a parameter's
    attributes `readonly nocapture`, where the committed fixture bindings
    and the tests' expectations record clang 18's `nocapture readonly`
    (the manifest's line 118 or 119, and one diagnostic's wording).
  - **GNU ld changed its words** for a library of another architecture:
    the test's reading finds no line that names the library file. The
    log shows only the test's booleans, `error {NATIVE LINK} 0 1`, not
    the linker's text.

  Nothing in this milestone touches either: the generator, its profiles,
  the bindings, `c-ffi.test` and the system linker's link plan are
  unchanged.

  `main` is in the middle of the same migration.
  `docs/C-BINDGEN-UBUNTU-26.04-HANDOFF.md` and commit 19b01025 pin the
  c-bindgen workflow to Ubuntu 26.04 and clang 21, and say that the
  committed-binding check "is expected to fail" until every profile is
  regenerated. There is no fix to port yet. What would fix each:
  - **c-bindgen:** regenerate the committed bindings with the new
    toolchain, as that document plans; or record the compiler's
    attribute words in a canonical order, so that the manifest does not
    depend on clang's printing order. Either is a change to the
    generator's outputs and its checks (AGENTS.md, "The C binding
    generator").
  - **`cf-wrong-architecture`:** capture the 26.04 linker's message (the
    test prints only its booleans) and add its wording to the test's
    pattern.
* **Found:** the non-ASCII directory limitation (section 39). It is
  pre-existing and unchanged.

## 36. Linux AArch64 regressions

* **`tests (linux arm64)`, run 40131788283 on c7d581f6:** success.
* **On d1e2de57:** run @@FINAL-ARM64@@.

Nothing Linux-specific changed after c7d581f6 except `aot.rs`'s remedy
function. Its unit tests run there too.

## 37. Windows regressions

* **`tests (windows x86-64)`, run 40126544966 on 0b941feb:** success.
* **On d1e2de57:** run 40451928051, success.

What reaches Windows is the driver's `runtime_archive`. There
`application_contents` is never true (`bundles` is macOS's), so the
message and location are the ones before this milestone.

## 38. macOS GitHub Actions links

`.github/workflows/macos-arm64.yml` on branch `ccr-c70bc7cc-uspdp2`
(https://github.com/mwagner-webdev/botlish/actions/runs/RUN):

| run | commit | what it showed |
|---|---|---|
| 40126544954 | 0b941feb | push run, cancelled by the next dispatch |
| 40129027396 | effaa172 | the first acceptance run: failed; fixed by 57ed5bc7 (paths in Tcl's encoding, re-decoded arguments) |
| 40130083782 | 57ed5bc7 | failed: the launcher crashing in a non-ASCII path |
| 40131369183 | df2b087a | failed, by design: the crash diagnosed (crash report, lldb) |
| 40133897160 | bb625bf5 | the UTF-8 locale fix; failed: app-test's check after a missing driver matched the wrong pattern (fixed by bd3df4f9) |
| 40137867969 | bd3df4f9 | failed: the driver's remedy named cargo for a damaged application (fixed by 69b23498) |
| **40140537637** | **69b23498** | **app, app-clean, app-mutants: all success** |
| **40452138744** | **d1e2de57** | **the full matrix, all success:** smoke, linux control, Tier B shards 1 and 2, system linker, app, app-clean, app-mutants (26 of 26; driver 5 of 5); `coroutine-kept.bot` added |

The jobs of 40140537637:
* `Botlish.app (macOS arm64 distribution)`: job 121011155199;
* `Botlish.app without developer tools`: job 121013898572;
* `Botlish.app mutants`: job 121011154978.

The artifacts are `botlish-macos-aarch64` (the download and its
`.sha256`), the app job's logs and `botlish-macos-app-mutants`. Like
every artifact, they expire.

## 39. Known limitations

* **Not notarized; Gatekeeper rejects it.** Ad-hoc signatures only
  (`spctl --assess`: `rejected`). A copy downloaded by a browser is
  quarantined and needs the user's explicit permission to open (section
  41); `curl`, `unzip` and CI artifacts are not quarantined.
* **Apple Silicon only.** One architecture, arm64, deployment target 11.0:
  no universal binary, no Intel Mac (the native backend's macOS port is
  AArch64's, MACOS-AARCH64-PORT-AUDIT.md).
* **Executables need Apple's Command Line Tools**, the system linker's C
  compiler driver: without them `-emit-native-executable` and the native
  run of a program that calls C report `NATIVE LINK TOOLCHAIN` with
  `xcode-select --install` (section 19). There is no stub linker on macOS.
  That includes every program that prints through `std::io`: its
  `std::darwin::io` is libSystem's C, so without the developer tools such
  a program runs on no backend (the Tcl backends refuse C calls). Its
  value is shown; its output is not.
* **Not a GUI application.** `LSBackgroundOnly`: it has no window, Dock
  icon or menu, and opening it from Finder is not a supported use (not
  tested). It is used from a terminal, through `Contents/MacOS/botlish` or
  a symbolic link on PATH; nothing creates the link for the user.
* **No automatic update, no version scheme.** `CFBundleShortVersionString`
  0.0; `-version` and `BotlishSourceRevision` name the commit.
* **Built in CI only.** The download is CI's artifact; there is no release
  workflow that publishes it beside the Linux single executable's
  `single-latest` prerelease.
* **The download is not reproducible byte for byte.** Two builds of one
  commit gave different SHA-256s (section 30). The `.sha256` file
  identifies a download, not a source revision.
* **A changed launcher or driver still ran on the runners** (section 29).
  Strict verification rejects both; the kernel's page checks did not stop
  them on a runner with SIP disabled. What a Mac with SIP enabled does
  was not observed.
* **The Linux single executable, in a directory whose name is not ASCII,
  without a UTF-8 locale** (a pre-existing limitation, found by this
  milestone's tests and not changed by it): Tcl decodes its own path with
  the C locale's ISO 8859-1 before `single/main.tcl` runs, so `info
  nameofexecutable` is mis-decoded and the language server cannot start
  its analysis worker (`single/smoke-test.sh` on such a copy: `FAIL: -lsp
  hover`; every other check passes). The arguments, the environment and
  the paths `single/main.tcl` computes are re-decoded (section 11); the
  worker's command line is `lsp/server.tcl`'s, from `info
  nameofexecutable`. The macOS application is not affected: its launcher
  starts Tcl in a UTF-8 locale (section 11, step 5).

## 40. Prerequisites for explicit static-library/framework declarations

A program that calls C names its libraries with `extern c library "NAME"`,
which the system linker passes as `-lNAME` (C-FFI.md): a library the
linker finds on its default search path, a static archive or a dylib,
chosen by the linker. What a distributed application of Botlish would add,
none of it done here:

* **A declared library path.** `-L DIR` and `-F DIR` come only from the
  link plan's runtime libraries and a `BOTLISH_NATIVE_*` variable today; a
  program cannot say where its own static archive is. A declaration
  (`extern c library "NAME" at "PATH"`, or a `static` form naming an
  archive) needs a rule for relative paths (the application root, as for
  modules) and a front-end cache dependency on the file.
* **Frameworks.** Apple's `-framework NAME` (and `-F`) is a different
  linker argument from `-lNAME`; `LinkerFlavor::Apple` has no framework
  entry. A framework declaration needs its own link-plan entry, never a
  `-l` spelling of one.
* **Static versus dynamic.** Apple's ld prefers a dylib to an archive of the
  same name in one directory; a program that must link statically needs
  the archive's path, not its name.
* **The executable's own search paths.** Executables are linked without
  `LC_RPATH` (section 20): a dylib a program links must be the system's or
  found at its install name. Bundling a dylib beside an executable would
  need an `@executable_path` rpath -- a link-plan decision per program,
  which this milestone deliberately does not take.

## 41. Prerequisites for Developer ID signing and notarization

The application is signed ad hoc and not notarized: Gatekeeper rejects it
(`spctl --assess`: `rejected`), so a copy downloaded with a browser carries
the quarantine attribute and macOS refuses to open it until the user
removes the attribute or allows it in System Settings. `curl`, `ditto`,
`unzip` in a terminal and CI artifacts do not set the attribute. A
Developer ID distribution needs, beyond this milestone:

1. **A Developer ID Application certificate** of an Apple Developer
   Program team, in CI as a secret, and `codesign --sign "Developer ID
   Application: ..." --timestamp` in place of `--sign -`, in the same
   order (framework version, driver, application). The identifiers
   (`io.github.mwagner-webdev.botlish`, `.native`, `com.tcltk.tcllibrary`)
   stay.
2. **The hardened runtime** (`--options runtime`) on the launcher, the
   driver and the framework, required for notarization. The launcher loads
   only its own framework (library validation is compatible: every
   library it loads is signed by the same team or is the system's). The
   driver JITs: the census (C6) ran the native JIT with a hardened-runtime
   driver (`codesign -dv`: `flags=0x10002(adhoc,runtime)`) with no
   entitlement, with `com.apple.security.cs.allow-jit` and with
   `com.apple.security.cs.allow-unsigned-executable-memory` -- all three
   ran. The runner reports `System Integrity Protection status:
   disabled.` (empty `kern.bootargs`; the crash reports say `"sip" :
   "disabled"` too), so this says nothing about a Mac with SIP enabled,
   where the hardened runtime is enforced: the entitlement a Developer ID
   driver needs must be measured on one before it is chosen (none is
   added here; AGENTS.md, "The macOS application"). Executables the compiler links are signed by the linker ad hoc
   (`linker-signed`), as any locally built program; a user distributing
   one signs it themselves.
3. **Notarization**: `xcrun notarytool submit botlish-macos-aarch64.zip
   --wait` with an App Store Connect API key, then `xcrun stapler staple
   Botlish.app` and the archive made again. Nothing in the bundle blocks
   it today: no appended data (section 6), every Mach-O signed, no
   unsigned code in Resources (the runtime archive is data: it is never
   loaded, only read by the linker).
4. **The deployment target** stays 11.0, the driver's and the runtime
   archive's.

## 42. Prerequisites for native Icy Tower distribution

Icy Tower (`examples/games/icy-tower`) is Linux x86-64's (its SDL3 binding
is generated for that target, ICY-TOWER-VERTICAL-SLICE-1.md). Distributing
it as a macOS application of its own, compiled by this Botlish.app, needs:

* the SDL3 binding generated for macos-aarch64 (`tools/c-bindgen.tcl
  generate sdl3 -target macos-aarch64`, which needs the macOS SDK and
  SDL3's headers) and its game modules made platform-neutral where they
  name Linux;
* SDL3 itself: a framework or dylib in the game's own bundle, which needs
  section 40's framework declaration and an executable with an
  `@executable_path/../Frameworks` search path -- the link-plan decision
  this milestone does not take;
* a game bundle (`Icy Tower.app`: Info.plist with a GUI executable, an
  icon) assembled and signed like this one -- `single/macos/build.sh`'s
  bundle and signing steps, generalized;
* a window: Cocoa, which SDL3 uses on macOS, handles events and windows
  on the process's main thread only; where a standalone executable runs
  Botlish code (its thread and stack, NATIVE-STACK-OVERFLOW.md) has to be
  checked against that before the game runs there.

## 43. What to run when changing this

If you change the launcher (`single/macos/launcher.c`), the framework build
(`single/macos/tcl-framework.sh`), the bundle's assembly or signing
(`single/macos/build.sh`), its verification (`single/macos/verify.sh`), the
shared staging (`single/package.tcl`), the startup script
(`single/main.tcl`) or the driver's runtime-archive discovery
(`codegen::aot::packaged_runtime_archive`):

* on Linux: `cargo test --release --manifest-path native/Cargo.toml --bin
  botlish-native aot::`, `tests/system-linker.test`,
  `audit/native-aot/tools/mutate.tcl -only 'sys-runtime-bundle-*'` (and the
  other `sys-*` mutants this milestone added), `single/build.sh` then
  `single/smoke-test.sh` and `single/ffi-smoke-test.sh` on its output, and
  `audit/single-executable/tools/mutate.tcl` (the staging and the startup
  script are shared);
* on macOS (CI: a push, or `workflow_dispatch` of macos-arm64.yml with
  `app_only`): the `app` job (build, verification, census, smoke, FFI
  smoke, `single/macos/app-test.sh`, `single/macos/compare.sh`,
  `bench/macos-app.tcl`) and the `app-clean` job, and with
  `[ci-app-mutants]` in the head commit's message (or the `app_mutants`
  input) `audit/macos-app/tools/mutate.tcl`: every mutant in its
  `mutants.txt` must still apply and be killed (update a mutant's text when
  you change the code it mutates, keeping it a mutant of the same rule);
* for a change to the Tcl pin: also the single executable's workflow, and
  the framework's cache key changes by itself.
