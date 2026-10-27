# The single-file compiler

`single/build.sh` builds the Botlish compiler stack and its command line as
**one Linux x86-64 executable** that needs nothing but glibc: no Tcl, no Rust
toolchain, no C compiler or linker, no checkout. It is `main.tcl`: it takes
the same options and arguments and does the same things, on every backend
(`interp`, `compile`, `cranelift`, `cranelift-generic`), and
`-emit-native-executable` builds standalone executables with it too. A
program that calls C (C-FFI.md) needs, besides, the host's C compiler driver
(`cc`, with its linker) and the C libraries it declares -- never Rust or a
checkout: the compiler carries its precompiled runtime
(SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, "The system linker" below).

On macOS (Apple Silicon) the same compiler is an application,
`Botlish.app`, built by `single/macos/build.sh`: Tcl as the bundle's own
`Tcl.framework`, the compiler in a ZIP archive inside it, the native backend
and runtime archive beside them, signed ad hoc (MACOS-AARCH64-MILESTONE-9.md;
"The macOS application" below).

```sh
single/build.sh                     # -> single/out/botlish
single/out/botlish -backend cranelift examples/surface/01-arithmetic.bot
single/out/botlish -emit-native-executable examples/io/hello.bot && examples/io/hello
```

A program may have several files: its own modules are the `.bot` files beside
its entry file (IMPORTS.md, "Application modules"), so in a directory holding
only `botlish`, `main.bot` and `game.bot`, `main.bot`'s `import game` names
`game.bot` -- the packed standard library is consulted first, and a missing
module's diagnostic names the application path before the archive's. A native
run shows what the program prints, then its value, as an executable would, and
the interpreter runs ordinary recursion thousands of calls deep (main.tcl's
recursion limit, core/core.tcl): main.tcl's own behavior, packed.

CI builds it on every push to `main` (`.github/workflows/single-executable.yml`),
smoke-tests it in stock `ubuntu:24.04` and `ubuntu:latest` containers, and
uploads it as the run's `botlish-linux-x86_64` artifact. A build that passes
every smoke test is then published as the `botlish-linux-x86_64` asset (with
its `.sha256`) of the `single-latest` prerelease, whose tag follows `main`:
the README's download button links to
`https://github.com/mwagner-webdev/botlish/releases/download/single-latest/botlish-linux-x86_64`.
Builds can finish out of order; one never replaces the build of a later
commit.

Only the compiler and its CLI are packed. The tests, benchmarks and audit
tools stay checkout-only, and the executables the compiler emits were
already self-contained.

## How it is built: a Tcl 9 zipkit

Tcl 9 runs an application packed into a zip archive attached to its own
executable (TIP 430, `zipfs`): at startup `TclZipfs_AppHook` mounts the
executable's archive at `//zipfs:/app`, takes the Tcl script library from
`//zipfs:/app/tcl_library`, and runs `//zipfs:/app/main.tcl` with the
command-line arguments. An executable built that way, with Tcl itself linked
statically, is a *zipkit*. `zipfs mkimg` makes one from a *base kit* (a static,
zipfs-enabled tclsh) and a directory.

`single/build.sh`:

1. **Base kit.** `--basekit PATH` (or `$BOTLISH_BASEKIT`) uses any such
   executable, for example a prebuilt zipkit such as BAWT's. Otherwise it
   downloads the official Tcl 9.0.1 source release (the repository's Tcl
   baseline, AGENTS.md), checks its sha256, and builds a static `tclsh` with
   zipfs and Tcl's bundled zlib and libtommath (`--disable-shared`), once. The
   result is cached in `~/.cache/botlish-single`. It links only libc and libm.
2. **Native backend.** `cargo build --release`, the same build the test suite
   uses. Both Rust executables are packed with `strip --strip-debug`:
   `botlish-native` (the driver: JIT, objects, executables) and
   `botlish-aot-stub` (below).
3. **Pack.** The base kit runs `single/package.tcl`, which stages the archive
   and calls `zipfs mkimg`:

   ```text
   main.tcl         single/main.tcl
   tcl_library/     the base kit's own Tcl script library
   botlish/         main.tcl, LICENSE, core/, compiler/, hir/, surface/,
                    service/, lsp/, native/*.tcl, stdlib/, compilerpedia/ (its engine, topics/
                    and generated/), BUILD (the source revision -version
                    prints) (checkout-relative paths)
   native-bin/      botlish-native, botlish-aot-stub, libbotlish_runtime.a, ID
   ```

The result is about 13.7 MB: a 3.5 MB static tclsh, plus the compressed
archive, 5 MB of which is the runtime archive (16 MB stripped, uncompressed;
SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, "Sizes"). `single/build.sh` also checks
that the system libraries the driver passes the linker after the runtime
archive are the ones rustc reports for it (`--print native-static-libs`;
`native/runtime-archive/libraries.tcl`, which every host's system-linker CI
job runs too).

## How it runs

`single/main.tcl` runs first:

* It sets UTF-8 as the system and standard-channel encoding. A checkout's
  canonical setup is `LANG=C.utf8` (AGENTS.md), and a single executable does
  not ask its user for a locale.
* It installs the two native executables. The kernel cannot execute a file
  inside the archive, so they are copied once per build into
  `$BOTLISH_CACHE_DIR`, `$XDG_CACHE_HOME/botlish` or `~/.cache/botlish`, in a
  directory named by `native-bin/ID` (the CRC and size of each of the three
  files). Each file is written under a temporary name and renamed into
  place, so concurrent first runs never execute (or link) a partial file.
  Later runs only check the files exist with the right size. Without any
  writable cache directory, a private temporary directory serves the run and
  is removed when it exits. Directories of earlier builds stay until you
  delete them; deleting one is always safe.
* A run that may link a native executable -- `-emit-native-executable`, or a
  native backend (`-backend cranelift`, `cranelift-generic`, or
  `CORE_BACKEND` naming one), which links a program that calls C to run it
  -- also installs the runtime archive into the same directory: the host's
  linker cannot read a file inside the archive either. Any other run never
  unpacks its 16 MB.
* It points the native backend at them: `BOTLISH_NATIVE_BIN`
  (`native::binary`'s existing override), `BOTLISH_NATIVE_AOT_STUB`, and
  `BOTLISH_NATIVE_LINKER=auto` unless the environment names a linker
  already (an explicit choice is kept, for diagnostics and tests). The
  driver finds the runtime archive beside itself.
* An invocation that runs no program -- no arguments (the usage summary),
  `-help` or `-version` first -- skips both steps above: it installs nothing
  and creates no cache directory (COMPILERPEDIA.md, "Packaging"). `-help`
  reads the packed Compilerpedia (`compilerpedia/`), and `-version` the
  packed `BUILD` file.
* It sources `//zipfs:/app/botlish/main.tcl`, unchanged, with the original
  arguments. Every path the compiler computes from its own location
  (`core::libraryDir`, the `source` chain) lands inside the archive, which
  Tcl reads like any directory. Diagnostics in library modules therefore name
  `//zipfs:/app/botlish/lib/...`. A program's application root is the
  directory of the entry file it is given, outside the archive, exactly as
  from a checkout.

The only processes a run starts are the kit itself and its installed
`botlish-native`. `strace -f -e trace=execve` of
`botlish -emit-native-executable` shows no rustc, cc, ld or system tclsh --
for a program that calls C, `cc` and the linker it drives (`collect2`, `ld`)
besides, and still no rustc.

## The linkers

`BOTLISH_NATIVE_LINKER` names the linker of a standalone executable
(`native/src/codegen/aot.rs`):

| | `rustc` (default) | `stub` | `system` |
| --- | --- | --- | --- |
| needs at compile time | rustc, a system linker, `libbotlish_native.rlib` and `deps/` | `botlish-aot-stub` | the host's C compiler driver (link.exe on Windows) and the runtime archive `libbotlish_runtime.a` |
| links C | yes | no: refused | yes |
| hosts | Linux x86-64, AArch64; macOS AArch64; Windows x86-64 | Linux x86-64 | the same as rustc |
| startup | the fixed startup crate, compiled | the image appended to the stub | the archive's `main` |

`auto` -- what the single executable sets -- is the system linker for a
program that calls C or declares a library (the NIR's `foreign` and `link`
entries, never its source text) and the stub for any other on a host that
has it, the system linker elsewhere. It never chooses rustc. All three link
the same program object, whose `botlish_program` record is the program's
startup data (`runtime::program`, NATIVE-LIBRARY-MILESTONE-1.md), and start
it the same way (`program::instantiate_linked`, `runtime::aot::run`);
`tests/system-linker.test` checks that their startups install exactly the
same program state (`BOTLISH_NATIVE_STARTUP_REPORT`).

## The system linker

SINGLE-EXECUTABLE-FFI-MILESTONE-1.md has the design and its evidence. In
short:

* **The runtime archive** (`native/runtime-archive`, the `botlish-runtime`
  package of `native/`'s workspace) is botlish-native's runtime library as a
  Rust `staticlib`, `libbotlish_runtime.a` (`botlish_runtime.lib` on
  Windows), built by the same `cargo build --release --manifest-path
  native/Cargo.toml` as the driver. It holds the runtime and Rust's standard
  library, no code generator, and the executable's C `main`.
* **No startup object.** The program object is the link's only object: its
  `botlish_program` record -- the program's descriptor (program
  information, constant pool, module statics, every function's code sizes
  and stack maps) and its code table, whose addresses the linker's
  relocations fill in -- is the startup data of every linker's executable.
* **The link** is the host's: `cc -pie ... program.o -L... -Wl,--start-group
  -l... -Wl,--end-group libbotlish_runtime.a -lgcc_s -lutil -lrt -lpthread -lm
  -ldl -lc` on Linux (Apple clang with `-dead_strip` and no group on macOS,
  link.exe with the static C runtime on Windows), the program's link plan in
  the rustc linker's terms, every path one argument, never a shell. The
  compiler driver is `cc` on PATH (link.exe on Windows, from a Developer
  environment), or `BOTLISH_NATIVE_SYSTEM_LINKER`; the archive is the one
  beside the driver, or `BOTLISH_NATIVE_RUNTIME`.
* **At startup** the archive's `main` (`runtime::aot::linked_main`) does
  what Rust's own startup does to the process (SIGPIPE ignored, missing
  standard descriptors opened on /dev/null), then exactly what the rustc
  linker's startup crate does: it reads the record --
  `program::instantiate_linked` checks its magic and the ABI fingerprint --
  and runs the program with `aot::run`.
* **Failures** say what failed: `NATIVE LINK TOOLCHAIN` / `NATIVE AOT
  TOOLCHAIN` (no C compiler driver, no linker, a `link.exe` that is not
  Microsoft's), `... RUNTIME` (the archive missing, not an archive, of
  another platform, or without a runtime helper the program calls),
  `NATIVE LINK` with the linker's own lines (a missing library or symbol),
  `NATIVE STARTUP` from the executable (a record of another runtime
  build), and `NATIVE LINK ARCHIVE` for a declared static archive that is
  missing, of another architecture or no static archive at all, before the
  linker runs (NATIVE-LINK-PLAN-MILESTONE-1.md). A failed link
  publishes nothing. `BOTLISH_NATIVE_LINK_LOG=FILE` appends every link's
  resolved plan (which archive each static library is), every system
  link's command line and the linker's output to FILE.
* **Static archives and frameworks** a program declares (`extern c library
  "NAME" static [at "PATH"]`, `extern c framework "NAME"`) are linked by the
  same system linker from the single executable and Botlish.app: the
  archive by its absolute path (a relative one from the program's
  application root, never the compiler's own ZIP), a framework as
  `-framework NAME` on macOS (NATIVE-LINK-PLAN-MILESTONE-1.md;
  single/ffi-smoke-test.sh's application F).
* **The executable** is an ordinary one of the platform: its Botlish
  functions are symbols, it imports only the system's libraries (and any
  shared library the program declared), and it needs neither the compiler
  nor the archive to run.

## The stub linker

A standalone executable used to be linked only one way. `rustc` compiles a
generated startup crate (the program's metadata, constant pool and stack maps
as Rust source) against `libbotlish_native.rlib`, and the system linker links
it with the Cranelift object. That needs a Rust toolchain and the checkout's
`native/target/release` at compile time. The single executable has neither, so
`native/src/codegen/aot.rs` now has a second linker, chosen by
`BOTLISH_NATIVE_LINKER`:

| | `rustc` (default) | `stub` |
| --- | --- | --- |
| needs at compile time | rustc, a system linker, `libbotlish_native.rlib` and `deps/` | `botlish-aot-stub` (beside the driver, or `BOTLISH_NATIVE_AOT_STUB`) |
| machine code | the Cranelift object | the same Cranelift object |
| startup | generated Rust: `Vm::new`, `constants::install`, frame map, `aot::run` | `runtime::aotimage`: the same calls, from the image |
| Botlish code in the file | an ELF section with `botlish_fn_N` / `botlish_entry_N` symbols | an appended image, mapped at startup |

`botlish-aot-stub` (`native/src/bin/botlish-aot-stub.rs`) is the runtime plus a
loader, built by the same `cargo build`. Linking with it copies it and appends
the program:

```text
[botlish-aot-stub ELF][image][image length: u64 LE]["BOTLIMG1"]
```

**The image** (`runtime::aotimage::Image`) holds what the rustc linker's
startup crate compiles in: `ProgramInfo` (functions, natives by their NIR
operation spelling, shapes, enums), the constant pool, the module-static
count, and each function's direct and generic entry with its stack maps. It
also holds the machine code. `codegen::aot::image` lays out the Cranelift
object's allocated sections the way a static linker would:

```text
[.text][trampolines]   page-aligned, made executable
[GOT][data][.bss]      writable
```

References inside the image are resolved at link time:

* calls between Botlish functions;
* GOT-relative loads, each given its own GOT slot;
* the context area's `R_X86_64_REX_GOTPCRELX` loads, relaxed to
  `lea botlish_context_area(%rip)` exactly as GNU ld and lld relax them, so
  CONTEXTS.md's "one RIP-relative load, no GOT" holds for stub-linked code
  too.

Two kinds of reference stay as fixups, because they need load addresses: an
absolute word (`Abs64`, which also fills the GOT slots) and a `call rel32` to
a runtime helper (`Call32`). Any other relocation type is an error at link
time, never a silent miscompile.

**At startup** the stub reads the image back from `/proc/self/exe` and checks
two things:

* its format word;
* an ABI fingerprint: the Vm and object field offsets the generated code
  addresses directly, and the helper table. A stub and a driver from different
  builds are refused.

It then maps the image with `MAP_FIXED_NOREPLACE` just below its own text. That
keeps every helper call within rel32 reach, so the call is the direct
`call helper` a static link produces. If the image lands out of reach, the
call goes through the helper's trampoline (`jmp *GOT`) instead, which is
slower but correct. The stub then applies the fixups and `mprotect`s the code
read+execute. Finally it builds the Vm exactly as the generated startup
does, and runs the program with `aot::run`: same argument handling, worker
stack, overflow guard and output. Nothing is compiled or interpreted at
startup.

**Differences that remain:**

* A stub-linked executable has no ELF symbols for its Botlish functions.
  `objdump` cannot disassemble them by name, and `strace -k` or `perf` stacks
  show the anonymous mapping instead of `botlish_fn_N`. The runtime's own
  symbols (`rt_*`, `botlish_linux_x86_64_syscall`) are in the stub as usual.
  The tests that read those symbols, and the one that tests rustc's
  invocation, carry the `rustcLinker` constraint (`tests/helpers.tcl`).
* `strip` and similar tools rewrite the ELF and drop the appended image. Do
  not strip a stub-linked executable; strip the stub before linking instead
  (`single/build.sh` does).
* Executables are smaller: about 1 MB from the stripped stub in the single
  executable, versus about 8 MB for rustc-linked executables with their debug
  line tables.

**Tests.** `tests/aot-stub-linker.test`:

* builds examples and feature programs with both linkers and requires the
  same stdout, stderr and exit status, plain and under GC stress;
* checks the file layout;
* checks damaged images and a bare stub;
* checks the linker-selection errors;
* checks the near mapping, from `/proc/PID/maps` of a running executable.

CI's `stub-linker` job (`.github/workflows/tests.yml`) runs every test file
that builds an executable with `BOTLISH_NATIVE_LINKER=stub`: 2,183 tests, all
passing except the 10 that read rustc-linked symbols, which now skip.
`single/smoke-test.sh` checks the packed compiler as a user would run it.

## The macOS application

MACOS-AARCH64-MILESTONE-9.md has the design, its census and its evidence.
A signed Mach-O cannot carry a ZIP archive appended to it (code signing
seals a Mach-O up to its signature; anything after it fails strict
verification), so the macOS distribution is not one file but one
application, downloaded as one archive (`botlish-macos-aarch64.zip`):

```text
Botlish.app/Contents/
  Info.plist
  MacOS/botlish                    the launcher (single/macos/launcher.c)
  MacOS/botlish-native             the native backend's driver
  Frameworks/Tcl.framework/        Tcl 9.0.1, built by Tcl's own macOS build
  Resources/botlish.zip            the compiler: single/package.tcl -archive
  Resources/libbotlish_runtime.a   the runtime archive the system linker links
  _CodeSignature/CodeResources     the seal of all of it
```

```sh
single/macos/build.sh                          # -> single/out/macos/Botlish.app and the .zip
Botlish.app/Contents/MacOS/botlish -version    # (or a symbolic link to it on PATH)
```

* **The same compiler.** `botlish.zip` is staged by the procedure that
  stages the single executable's archive (`single/package.tcl`'s
  `StageCompiler`): `main.tcl` (single/main.tcl), `botlish/` (the compiler
  stack, stdlib/, compilerpedia/, BUILD) and `native-bin/ID`, the bundled
  driver's and archive's identity -- but no `tcl_library` (the framework's)
  and no native executable (the bundle's).
* **The launcher** initializes Tcl the way a Tcl application does
  (`Tcl_Main` with an application initialization procedure) and does three
  things of its own: it checks that the Tcl dyld loaded (weakly linked,
  through `LC_RPATH @executable_path/../Frameworks`) is the bundle's own
  framework; it sets `tcl_library` to that framework's script library
  (never `$TCL_LIBRARY`); it mounts `Contents/Resources/botlish.zip` at
  `//zipfs:/app` and runs `//zipfs:/app/main.tcl` with every argument,
  `argv[0]` being its own real path. A missing or damaged part of the
  application is the launcher's diagnostic ("botlish: ...", status 2).
* **single/main.tcl** runs the bundle's driver where it is
  (`BOTLISH_NATIVE_BIN`, whatever the environment names) and sets
  `BOTLISH_NATIVE_LINKER=auto`, which is the system linker on macOS: there
  is no stub. The driver finds the runtime archive in `Contents/Resources`
  from its own path in `Contents/MacOS` (codegen::aot's
  `packaged_runtime_archive`). The application installs nothing; the
  language server's copy of the standard library (for an editor's
  go-to-definition) goes to `~/Library/Caches/botlish`, or
  `$BOTLISH_CACHE_DIR`, never into the bundle. Both distributions make the
  archive read-only to the compiler (`::tcl::zipfs::wrmax 0`).
* **What it needs.** Nothing to analyze, check, run on the Tcl backends or
  the native JIT, answer -help or serve an editor: no Tcl, Rust, Cargo or
  checkout. Every executable it builds is linked by the system linker, so
  `-emit-native-executable` (and a native run of a program that calls C,
  Darwin IO included) needs Apple's Command Line Tools or Xcode; without
  them the link says so (`NATIVE LINK TOOLCHAIN`, "xcode-select
  --install").
* **Signing.** Ad hoc, inner code first: the framework's version, the
  driver, then the application (its launcher and the seal of its
  resources). `codesign --verify --deep --strict` passes, after moving the
  application too; it is not notarized, and Gatekeeper rejects a
  downloaded copy until it is (MACOS-AARCH64-MILESTONE-9.md, "Developer ID
  signing and notarization").

CI's `app` jobs (`.github/workflows/macos-arm64.yml`) build, verify, accept
(single/smoke-test.sh, single/ffi-smoke-test.sh, single/macos/app-test.sh,
single/macos/compare.sh) and measure it on every push, run it once more on
a runner whose developer tools, Rust and checkout were moved away, and
upload `botlish-macos-aarch64.zip` with its checksum as the run's artifact.

## Limits

* x86-64 Linux with glibc. The compiler needs the glibc it was built
  against or newer. CI builds on ubuntu-24.04 (glibc 2.39). The executables
  it emits need glibc 2.34. On AArch64 everything it packs runs, the
  programs that print included (LINUX-SYSCALL-TRANSPORTS.md), except
  `-emit-native-executable`: the `stub` linker it relies on is x86-64 only.
  LINUX-SYSCALL-TRANSPORTS.md, "Single-file compiler on AArch64", lists what
  an AArch64 stub linker and build need.
* A program that calls C links with the system linker, which needs the
  host's C compiler driver and linker (`apt install gcc` on Debian and
  Ubuntu) and the program's C libraries; without a driver its link is
  refused (`NATIVE LINK TOOLCHAIN`), and every other program still links
  with no toolchain at all. Only Linux x86-64 has a single executable, and
  macOS AArch64 the application above; the system linker itself runs on
  Linux AArch64 and Windows x86-64 too (from a checkout's build), where a
  packaged distribution is a later milestone's.
* The single executable runs the checkout's code as of its build. It reports
  library diagnostics at `//zipfs:/app/...` paths, and it has no tests or
  tools. Its standard library is the packed one: an application adds modules
  of its own beside its entry file, never into the archive.
