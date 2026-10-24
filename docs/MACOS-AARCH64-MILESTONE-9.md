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
names. So the launcher sets `tcl_library` itself, to the scripts beside the
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
* **Not a GUI application.** `LSBackgroundOnly`: it has no window, Dock
  icon or menu, and opening it from Finder is not a supported use (not
  tested). It is used from a terminal, through `Contents/MacOS/botlish` or
  a symbolic link on PATH; nothing creates the link for the user.
* **No automatic update, no version scheme.** `CFBundleShortVersionString`
  0.0; `-version` and `BotlishSourceRevision` name the commit.
* **Built in CI only.** The download is CI's artifact; there is no release
  workflow that publishes it beside the Linux single executable's
  `single-latest` prerelease.
* **The Linux single executable, in a directory whose name is not ASCII,
  without a UTF-8 locale** (a pre-existing limitation, found by this
  milestone's tests and not changed by it): Tcl decodes its own path with
  the C locale's ISO 8859-1 before `single/main.tcl` runs, so `info
  nameofexecutable` is mis-decoded and the language server cannot start
  its analysis worker (`single/smoke-test.sh` on such a copy: `FAIL: -lsp
  hover`; every other check passes). The arguments, the environment and
  the paths `single/main.tcl` computes are re-decoded (section 11); the
  worker's command line is `lsp/server.tcl`'s, from `info
  nameofexecutable`. The macOS application is not affected: Tcl's startup
  encoding on macOS without a locale is UTF-8.

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
   driver with no entitlement, with `com.apple.security.cs.allow-jit` and
   with `com.apple.security.cs.allow-unsigned-executable-memory` -- all
   three ran -- on a runner whose SIP status the census records (section
   3); that observation is the runner's and must be repeated on a
   standard Mac with a Developer ID signature before the entitlement is
   chosen. Executables the compiler links are signed by the linker ad hoc
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
