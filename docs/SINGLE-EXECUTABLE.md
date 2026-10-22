# The single-file compiler

`single/build.sh` builds the Botlish compiler stack and its command line as
**one Linux x86-64 executable** that needs nothing but glibc: no Tcl, no Rust
toolchain, no C compiler or linker, no checkout. It is `main.tcl`: it takes
the same options and arguments and does the same things, on every backend
(`interp`, `compile`, `cranelift`, `cranelift-generic`), and
`-emit-native-executable` builds standalone executables with it too.

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
                    native/*.tcl, stdlib/, compilerpedia/ (its engine, topics/
                    and generated/), BUILD (the source revision -version
                    prints) (checkout-relative paths)
   native-bin/      botlish-native, botlish-aot-stub, ID
   ```

The result is about 7.5 MB: a 3.5 MB static tclsh, plus the compressed
archive.

## How it runs

`single/main.tcl` runs first:

* It sets UTF-8 as the system and standard-channel encoding. A checkout's
  canonical setup is `LANG=C.utf8` (AGENTS.md), and a single executable does
  not ask its user for a locale.
* It installs the two native executables. The kernel cannot execute a file
  inside the archive, so they are copied once per build into
  `$BOTLISH_CACHE_DIR`, `$XDG_CACHE_HOME/botlish` or `~/.cache/botlish`, in a
  directory named by `native-bin/ID` (their CRC and size). Each file is written
  under a temporary name and renamed into place, so concurrent first runs
  never execute a partial file. Later runs only check the files exist with
  the right size. Without any writable cache directory, a private temporary
  directory serves the run and is removed when it exits. Directories of
  earlier builds stay until you delete them; deleting one is always safe.
* It points the native backend at them: `BOTLISH_NATIVE_BIN`
  (`native::binary`'s existing override), `BOTLISH_NATIVE_LINKER=stub` and
  `BOTLISH_NATIVE_AOT_STUB`.
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
`botlish -emit-native-executable` shows no rustc, cc, ld or system tclsh.

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

## Limits

* x86-64 Linux with glibc. The compiler needs the glibc it was built
  against or newer. CI builds on ubuntu-24.04 (glibc 2.39). The executables
  it emits need glibc 2.34. On AArch64 everything it packs runs, the
  programs that print included (LINUX-SYSCALL-TRANSPORTS.md), except
  `-emit-native-executable`: the `stub` linker it relies on is x86-64 only.
  LINUX-SYSCALL-TRANSPORTS.md, "Single-file compiler on AArch64", lists what
  an AArch64 stub linker and build need.
* No C calls yet. The stub linker links no C library, so the native link of
  a program that calls C or declares a library is refused (`NATIVE LINK`;
  C-FFI.md, section 11); the Tcl backends run such a program to its first C
  call. Linking one needs a checkout's rustc linker.
* The single executable runs the checkout's code as of its build. It reports
  library diagnostics at `//zipfs:/app/...` paths, and it has no tests or
  tools. Its standard library is the packed one: an application adds modules
  of its own beside its entry file, never into the archive.
