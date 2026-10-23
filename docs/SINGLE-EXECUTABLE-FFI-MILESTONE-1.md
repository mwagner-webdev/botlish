# Single executable FFI, milestone 1: the system linker

The single-file Botlish compiler now compiles, links and runs native
programs that call C. A third executable linker, the **system linker**
(`BOTLISH_NATIVE_LINKER=system`), links the program's Cranelift object, a
startup object the driver writes and a **precompiled runtime archive** built
with the compiler, using the host's own C compiler driver (link.exe on
Windows). Rust is not involved when an application is linked. The single
executable carries the archive and chooses the system linker for a program
that calls C, and the toolchain-free stub linker for every other program
(`BOTLISH_NATIVE_LINKER=auto`).

> The compiler may require the host's native linking toolchain to
> incorporate foreign libraries, but it must never require the user to
> rebuild Botlish's runtime, invoke Rust, or possess Botlish's source tree.

Every platform claim below is labelled **executed** (run on that platform,
by this milestone's CI or locally), **inspected** (compiled or read only) or
**not implemented**.

## Contents

1. [Starting point](#1-starting-point)
2. [The C-linking refusal](#2-the-c-linking-refusal)
3. [The rustc linker's startup: a census](#3-the-rustc-linkers-startup-a-census)
4. [The stub linker's image: a census](#4-the-stub-linkers-image-a-census)
5. [Candidate designs](#5-candidate-designs)
6. [The design](#6-the-design)
7. [The runtime archive](#7-the-runtime-archive)
8. [The runtime's startup boundary](#8-the-runtimes-startup-boundary)
9. [The startup object](#9-the-startup-object)
10. [Program metadata and stack maps](#10-program-metadata-and-stack-maps)
11. [Compatibility checks](#11-compatibility-checks)
12. [Packaging the runtime in the zipkit](#12-packaging-the-runtime-in-the-zipkit)
13. [Installation](#13-installation)
14. [Choosing a linker](#14-choosing-a-linker)
15. [GNU ld](#15-gnu-ld)
16. [Apple's ld](#16-apples-ld)
17. [Microsoft's link.exe](#17-microsofts-linkexe)
18. [Static libraries](#18-static-libraries)
19. [Dynamic dependencies](#19-dynamic-dependencies)
20. [Linked runs](#20-linked-runs)
21. [Standalone executables](#21-standalone-executables)
22. [GC and coroutines](#22-gc-and-coroutines)
23. [Byte borrowing and C error capture](#23-byte-borrowing-and-c-error-capture)
24. [Linux x86-64: the single-file compiler](#24-linux-x86-64-the-single-file-compiler)
25. [Linux AArch64](#25-linux-aarch64)
26. [macOS AArch64](#26-macos-aarch64)
27. [Windows x86-64](#27-windows-x86-64)
28. [Mutation testing](#28-mutation-testing)
29. [Fuzzing](#29-fuzzing)
30. [Sizes](#30-sizes)
31. [Link and startup benchmarks](#31-link-and-startup-benchmarks)
32. [Linux CI](#32-linux-ci)
33. [macOS CI](#33-macos-ci)
34. [Windows CI](#34-windows-ci)
35. [Remaining distribution work](#35-remaining-distribution-work)
36. [For the next macOS milestone](#36-for-the-next-macos-milestone)
37. [What to run when changing this](#37-what-to-run-when-changing-this)

## 1. Starting point

The single-file compiler (SINGLE-EXECUTABLE.md) is a Tcl 9 zipkit: a static
`tclsh` with main.tcl, the compiler stack, the standard library,
Compilerpedia and the native backend's two Rust executables (`botlish-native`,
the driver, and `botlish-aot-stub`) in an attached zip archive.
`single/main.tcl` copies the two executables into a per-build cache
directory, sets `BOTLISH_NATIVE_BIN`, `BOTLISH_NATIVE_AOT_STUB` and
`BOTLISH_NATIVE_LINKER=stub`, and runs main.tcl unchanged.

Before this milestone a standalone executable was linked one of two ways
(`native/src/codegen/aot.rs`):

* **rustc** (the default): rustc compiles a generated startup crate (the
  program's metadata as Rust source) against `libbotlish_native.rlib` and
  links it with the Cranelift object through the system linker. This needs
  rustc, the rlib and its `deps/` directory: a checkout's build.
* **stub**: the prebuilt `botlish-aot-stub` (the runtime plus a loader) has
  the program's image appended to it: the object's sections, laid out and
  relocated by the driver, and the program's metadata. No toolchain is
  needed, but no native library can be linked, and it runs on Linux x86-64
  only.

The single executable used the stub linker, so it linked any program that
calls no C and refused every program that does.

## 2. The C-linking refusal

The refusal, which the single executable gave for `-emit-native-executable`
and for a native backend's run of a program that calls C or declares a
library (`NATIVE LINK`, C-FFI.md section 15), read:

```
native link failed: this program calls C or declares a C library (symbols
bcf_add; libraries -lbotlish_cffi_fixture), which only the system linker
resolves, and the stub linker (BOTLISH_NATIVE_LINKER=stub, the single
executable's) links no native library: link it with the rustc linker of a
Botlish checkout whose native backend is built (BOTLISH_NATIVE_LINKER=rustc;
C-FFI.md)
```

The stub still refuses such a program when the stub is named explicitly, and
the message now names the linkers that can link it: "...: link it with the
system linker (BOTLISH_NATIVE_LINKER=system or auto, the single executable's:
a C compiler driver and the runtime archive) or the rustc linker of a
Botlish checkout (BOTLISH_NATIVE_LINKER=rustc; C-FFI.md)" (`cf-stub-linker`).

## 3. The rustc linker's startup: a census

`codegen::aot::startup` writes a Rust crate that does the following, in this
order:

| what | how |
|---|---|
| `ProgramInfo` | `FunctionInfo {arity, pnames}` per NIR function; `NativeInfo {name, arity, params, op}` per native (the `OpCode` by its variant); `ShapeInfo {name, fields, opaque}`; `EnumInfo {name, cases}` |
| the Vm | `Vm::new(Rc::new(info), AllocMode::Off)` |
| generic entries | `botlish_entry_N as usize`, in NIR order |
| constants and module statics | `constants::install(&mut vm, &[Const::...], &entries, statics)`: `Str`, `Bytes`, `BigInt`, `Native`, `FnValue`, `Float` |
| stack maps | a `ProgramMap`: per function, `FunctionMap {botlish_fn_N, + direct size, safepoints}` and `{botlish_entry_N, + entry size, no safepoints}`; `finish`, `set_framemap` |
| the entry | an `extern "C" fn entry(vm)` calling `botlish_fn_0` |
| the process | `fn main() { std::process::exit(aot::run(aot::process_argv(), init)) }` |

Everything after that is `runtime::aot::run`, which is shared: the worker
thread with its 1 GiB stack, the stack-overflow guard, the argument
snapshot, the result or the error, the driver protocol for linked runs
(`BOTLISH_NATIVE_RESULT`), and the exit status. Coroutine stacks and the
native stack are created lazily by the runtime. They are not part of
startup.

None of this exists in serialized form. It is Rust source text, compiled
into the executable. Everything it holds comes from compiler-side data:
`program_info(program)`, the object's constant pool, `program.statics`,
and the object's per-function sizes and safepoints (`clif::DefineResult`).

## 4. The stub linker's image: a census

`runtime::aotimage::Image` already serializes all of that same data. Its
fields are `info` (the `ProgramInfo`, with natives named by their NIR
operation spelling), `constants`, `statics`, and `functions` (each function's
direct and generic entry offsets, sizes and safepoints). It also holds the
machine code and what is needed to place it: `imports`, `code`, `size`,
`executable` and `fixups`. The image's encoding starts with a format word
and the **ABI fingerprint**: a digest of the Vm and object field offsets
that generated code addresses directly, plus the helper table. The stub
refuses an image whose fingerprint differs from its own runtime's.
`Loaded::instantiate` builds the Vm from a loaded image exactly as the
generated startup does.

The metadata half of the image therefore already has a versioned, checked,
bounds-safe encoding and a startup that the tests compare against rustc's.
The machine-code half (the layout, the GOT, the trampolines, the fixups and
the loader) is exactly what a real linker does for itself.

## 5. Candidate designs

1. **Generated C startup source, compiled by the host C compiler.** This
   needs a C compiler where a linker would do: on Windows `cl` as well as
   `link.exe`. It adds a second encoder of the metadata (C initializers).
   A C file cannot construct the runtime's Rust objects either, so it would
   still have to hand serialized data to Rust or assume Rust struct layouts.
2. **A generated native startup object with relocations.** The object
   format, symbol spelling and relocation types are the platform's, and the
   linker resolves every address. This needs an object writer. The driver
   has one: Cranelift's, the same one that writes the program object.
3. **The existing image format for metadata, with a precompiled startup
   shim.** One encoder and one decoder for both linkers, and a startup that
   is code in the runtime and never generated.
4. **A Rust `main` object (`rustc --emit=obj`) built with the distribution
   and linked beside the staticlib.** This keeps Rust's own `lang_start`,
   but it couples two separately compiled Rust artifacts by crate hash, and
   it still needs the metadata from 2 or 3.
5. **The stub image inside a system-linked executable.** Rejected by the
   brief and by construction: it would carry the machine code twice and
   keep the stub's loader.

**Chosen: 2 and 3 together.** The startup object holds only data: the
program's description, encoded as an `Image` with no machine code, and an
address table that the linker relocates. The shim is the runtime archive's
own `main`. No machine code is generated for startup, no Rust struct layout
crosses the boundary, and no metadata format is added.

## 6. The design

```
            driver (botlish-native)                       host toolchain
  NIR ──► emit_object ─► program.o  (botlish_fn_N, botlish_entry_N, ...)  ┐
      └─► startup_object ─► startup.o  (botlish_program_description)     ├─► cc / link.exe ─► executable
                         libbotlish_runtime.a  (main, rt_*, std)          ┘     + the program's -L, -l
```

* `program.o` is byte for byte the rustc and stub linkers' object
  (`emit_object`).
* `startup.o` defines one read-only-after-relocation data object,
  `botlish_program_description` (section 9).
* The archive's `main` (native/runtime-archive/src/lib.rs) calls
  `aotimage::linked_main(&botlish_program_description,
  &botlish_runtime_startup_v1)`. That function sets up the process the way
  Rust's startup does, reads the description, builds a `Loaded` and runs
  `aot::run(process_argv(), || loaded.instantiate())`, the stub's
  `instantiate`.
* `codegen::aot::link_system` locates the archive and the tool, writes the
  two objects into a private directory beside the destination, runs the
  linker with `system_link_args`, and renames the result into place.

## 7. The runtime archive

`native/runtime-archive` is a new package, `botlish-runtime`, of a Cargo
workspace rooted at `native/Cargo.toml`. It is a default member, so the
usual `cargo build --release --manifest-path native/Cargo.toml` builds it
beside the driver and the stub. It is a `staticlib` that depends on
`botlish-native`'s library and forwards its `fallback-roots` feature. Its
source is 40 lines: `main` and the interface symbol.

| fact (linux-x86_64, executed) | value |
|---|---|
| file | `native/target/release/libbotlish_runtime.a` (`botlish_runtime.lib` with MSVC) |
| build cost | 14 s added to a build with a changed runtime (the archive's own crate and bundling) |
| as built (`debug = 1`: line tables) | 36,115,600 bytes |
| `strip --strip-debug` | 16,097,728 bytes |
| `gzip -9` of the stripped archive | 4,988,905 bytes |
| members | Botlish's runtime (16 codegen units), num-bigint, num-traits, num-integer, unicode-general-category, libc; Rust's std, core, alloc, compiler_builtins (273 members), panic_unwind, unwind, and std's backtrace symbolization (addr2line, gimli, object, miniz_oxide, adler2, memchr, hashbrown, rustc_demangle) |
| compiler-only code | none: no cranelift-*, target-lexicon or log member (botlish-native's library never had a code generator) |
| system libraries (rustc's `--print native-static-libs`) | `-lgcc_s -lutil -lrt -lpthread -lm -ldl -lc` |

The 28 MB recorded earlier (C-FFI.md section 15) was a `cargo rustc
--crate-type staticlib` of the same library. Today's archive is larger with
its line tables and 16 MB without them. Splitting the runtime from the
compiler would gain nothing: the archive already holds no compiler code.
Almost all of what remains is the runtime and Rust's standard library, and
the linker's `--gc-sections` (`-dead_strip`, `/OPT:REF`) keeps only what an
executable reaches: a system-linked executable is 6% larger stripped than
the rustc linker's (section 30), once the startup takes no helper's
address.

## 8. The runtime's startup boundary

The boundary between the two halves is three symbols. No Rust type crosses
it:

| symbol | defined by | what |
|---|---|---|
| `main` | the archive | the executable's C entry, called by the C runtime's startup (crt1's `_start`, libSystem's, `mainCRTStartup`) |
| `botlish_runtime_startup_v1` | the archive | one byte, the interface revision; the startup object refers to it |
| `botlish_program_description` | the startup object | the description (section 9); the archive's `main` refers to it |

The runtime builds every Rust object itself, from bytes it checks
(`aotimage::read_linked`).

**What Rust's startup does, the archive's `main` does too.** A Rust `main`
runs `std::rt::lang_start`, which a staticlib's C `main` does not. Reading
the toolchain's own `std/src/sys/pal/unix/mod.rs` (`init`, `rt.rs`'s
`lang_start_internal`), `aot::rust_process_setup` repeats what matters to a
program:

* A standard descriptor the process was started without is opened on
  /dev/null.
* SIGPIPE is ignored, so a write to a closed pipe is the `EPIPE` error the
  program handles, never a kill.
* On macOS, the main thread is named `main`.
* A panic outside the program's thread is exit status 101.
* `std::process::exit` flushes Rust's standard output, as the generated
  `main` does.

The arguments are `std::env::args_os`'s on every host. In a staticlib that
works on glibc (std reads them from `.init_array`), macOS (`_NSGetArgv`)
and Windows (`GetCommandLineW`). The one part of `lang_start` that is not
public is `stack_overflow::init`, the handler that prints "thread X has
overflowed its stack". The runtime's own guard (runtime/platform/)
reports a Botlish stack's overflow the same way in all three executables.
Any other fault ends a system-linked process by the signal itself rather
than by Rust's message and abort. `system-linker-process-setup` checks the
first two points against the rustc and stub linkers' executables, and the
`sys-sigpipe-default` and `sys-fds-not-sanitized` mutants are killed by it.

## 9. The startup object

`codegen::aot::startup_object` uses Cranelift's object writer
(`cranelift_object::ObjectModule`) with the program object's own ISA and
flags, so the format, symbol spelling (Mach-O's `_` prefix) and relocations
are the target's. It holds one exported data object:

```
offset 0    "BOTLSYS1"                 magic; the last byte is the revision
       8    N                          functions (u64)
      16    L                          metadata bytes (u64)
      24    &botlish_runtime_startup_v1         relocated
      32    &botlish_fn_0, &botlish_entry_0, ... relocated, 2N addresses
32+16N      metadata                   Image::encode() of an image with no code
```

The metadata is `Image::linked(program_info, constants, statics,
functions)`: the stub's encoding, with empty `code`, `imports` and
`fixups`, and each function's sizes and safepoints. The addresses are
`write_function_addr`/`write_data_addr` relocations against imported
symbols: `R_X86_64_64` and `R_AARCH64_ABS64` in `.data.rel.ro` on ELF (a
PIE gets `R_*_RELATIVE` dynamic relocations), `ARM64_RELOC_UNSIGNED` in
`__DATA_CONST,__const` on Mach-O (rebased by dyld), and
`IMAGE_REL_AMD64_ADDR64` in `.rdata` on COFF (base relocations).
`startup_object_relocates_every_address` reads a startup object back and
checks the exported description, the metadata, that there is no code, and a
relocation of each slot against the right symbol.

## 10. Program metadata and stack maps

The milestone asked for more evidence than matching output. Each of the
three startups can now report what it installed:
`BOTLISH_NATIVE_STARTUP_REPORT=PATH` makes any standalone executable write
`Vm::startup_report()` to PATH and then run as usual. The report holds the
program information (every function's arity and parameter names in order,
every native's name, arity, parameter kinds and operation, every shape and
enum), every constant (its heap kind, its `show` text, and for a function
value its function, arity and generic entry), the module-static count, and
the stack-map table. Every code address in it is relative to the lowest
one in the table, so it is free of load addresses:

```
startup-report 1
function 3 arity 1 pnames "flag"
shape 0 None fields ["a", "b"] opaque false
enum 0 "Color" cases ["Red", "Green"]
constant 0 kind 1 "9223372036854775808"
constant 8 kind 5 "<block ()>" function 1 arity 0 code +856
statics 0
code +0 +774 safepoints [(204, [0]), (286, [0, 8, 16, 24, 32]), ...]
code +774 +788 safepoints []
```

All three linkers keep `program.o`'s `.text` intact. **Executed:** for
every program of `system-linker-startup-parity` (the examples, constants of
every kind, closures, enums, coroutines, a runtime error, argv), the rustc,
stub and system linkers' reports are byte for byte equal, and so are their
standard output, standard error and exit status, plain and under
`BOTLISH_NATIVE_GC_STRESS=1`. The C acceptance program
(`system-linker-c-acceptance`) has equal reports for rustc and system.
Mutants that drop a constant, swap two entries, drop the stack maps or one
root per safepoint are each killed by this comparison (section 28).

## 11. Compatibility checks

**Before linking**, `runtime_archive` checks that:

* the archive exists, as `BOTLISH_NATIVE_RUNTIME` or beside the driver;
* it is a static library (`!<arch>`: GNU, BSD/Apple and Microsoft archives
  share the format);
* its first object file is of this host's format and architecture
  (`archive_machine` skips symbol tables, BSD long names and Microsoft
  import members): ELF x86-64 or AArch64, Mach-O arm64, COFF x86-64.

Another architecture or operating system is therefore refused with "is for
ELF AArch64, not this driver's linux-x86_64 (ELF x86-64)" instead of a
linker's "file in wrong format".

**While linking**, the linker checks the startup interface: the startup
object refers to `botlish_runtime_startup_v1`, so an archive of another
interface revision fails to link. That failure is reported as the
archive's: "does not implement this driver's startup interface". An archive
with no `main` is "no Botlish runtime archive".

**At startup**, `read_linked` checks the magic and revision, that every
count is within bounds, that the interface slot holds the archive's own
symbol, the metadata's format word and **ABI fingerprint**
(`Image::decode`, as the stub does), that no code, imports or fixups are
present, that the table matches the program, and that no address is null.
Each failure is `... (NATIVE STARTUP)` with status 1, before any program
code runs (`system-linker-damaged-description` alters the revision and the
fingerprint in a linked file). The fingerprint now also covers the GC root
plan (`framewalk::NATIVE_FRAME_ROOTS`), so a `fallback-roots` driver's code
never runs on a native-frame runtime or the other way round. This applies
to the stub as well.

**Why the fingerprint is not checked before linking.** The fingerprint is
computed by the runtime from its own layout and helper table
(`abi_fingerprint`), at run time. The only way to learn an archive's
fingerprint is to run code from that archive. A build-time constant would
need the helper table rewritten as a `const` and the fingerprint spelled
into a symbol name, which Rust's `export_name` cannot take from a constant.
In the configurations that exist, the driver and the archive come from one
`cargo build` (the checkout's `native/target/release`) or from one package
(the single executable's cache directory is named by all three files'
digests: section 13). A deliberately mixed pair, through
`BOTLISH_NATIVE_RUNTIME`, links but is refused at its first start.

## 12. Packaging the runtime in the zipkit

* `single/build.sh` builds as before. It then compares the driver's list
  of the archive's system libraries (`botlish-native system-linker`'s
  `libraries` line) with rustc's own account (`cargo rustc -p
  botlish-runtime -- --print native-static-libs`) and stops on a
  difference (`native/runtime-archive/libraries.tcl`, which every host's
  system-linker CI job also runs). It copies `libbotlish_runtime.a` with the two executables,
  each `strip --strip-debug`'d.
* `single/package.tcl` packs `native-bin/libbotlish_runtime.a` and folds
  its CRC and size into `native-bin/ID`.
* Nothing else is added: no target directory, no rlib, no Cargo file.

The single executable grows from about 8.7 MB to 13.7 MB (section 30). The
runtime archive in the zip is 5.0 MB compressed and 16.1 MB unpacked.

## 13. Installation

`single/main.tcl`:

* Installs the runtime archive only for a run that **may link**:
  `-emit-native-executable`, or a native backend (`-backend cranelift`,
  `cranelift-generic`, or `CORE_BACKEND` naming one). The usage summary,
  `-help`, `-version` and the language server install nothing. Any other
  run installs only the two executables (smoke-test.sh checks both).
* Installs into the directory named by the build's ID, as before. Every
  file is written under a temporary name and renamed into place, so a
  concurrent first run never links a partial archive. On later runs a file
  of the right size is kept.
* Sets `BOTLISH_NATIVE_LINKER=auto` unless the environment already names a
  linker. An explicit choice is kept for diagnostics and tests
  (`ffi-smoke-test.sh` checks that `BOTLISH_NATIVE_LINKER=stub` still
  refuses C).

The driver finds the archive beside itself, so no new variable is set.
Without a writable cache, the run's private temporary directory serves, as
before. The executable it links does not refer to the archive at run time
(section 21).

## 14. Choosing a linker

| `BOTLISH_NATIVE_LINKER` | program calls no C | program calls C or declares a library |
|---|---|---|
| unset, empty, `rustc` | rustc | rustc |
| `stub` | stub | refused (`NATIVE LINK`) |
| `system` | system | system |
| `auto` | stub where it runs (Linux x86-64), else system | system |

`auto` decides by the program's NIR: its `foreign` and `link` entries
(`calls_c`), never its source text. A program that declares a library and
calls nothing from it counts as calling C, as before (C-FFI.md section 12).
No choice ever falls back to rustc. The default stays rustc, so a
checkout's tests and tools behave as they did.
`linker_selection_auto_follows_the_link_plan` covers every case, and
`system-linker-auto` covers the files `auto` produces.

## 15. GNU ld

**Executed** (Linux x86-64; the paths shortened):

```
/usr/bin/cc -pie -Wl,--eh-frame-hdr -Wl,-z,relro,-z,now -Wl,--gc-sections
    -o WORK/.botlish-aot-PID-NONCE/executable
    WORK/.botlish-aot-PID-NONCE/program.o WORK/.botlish-aot-PID-NONCE/startup.o
    -LWORK/lib -Wl,--start-group -lbotlish_cffi_fixture -Wl,--end-group
    RELEASE/libbotlish_runtime.a -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc
```

* The flags are the ones rustc passes for an executable: a PIE (all three
  inputs are PIC), `--eh-frame-hdr` for Rust's unwinder, full RELRO, and
  unused sections dropped.
* The program's link plan is `link_plan_args_for`'s, the rustc linker's,
  with rustc's `-C link-arg=` wrapping removed: the `-L` directories, then
  the libraries in one archive group, in the plan's order.
* After the plan come the runtime archive and its system libraries. The
  driver appends its default libraries (libc, libgcc, the dynamic loader
  as needed) after all of it, so C-FFI.md section 11's as-needed rule holds.
* `-L` directories that do not exist are passed through, as with the rustc
  linker. A failed link's message then adds "the link directory DIR (-L)
  is not a directory".
* Every path is one argument of a structured `Command`, never a shell
  string. A path with spaces and non-ASCII characters (`system linker
  runtime ä`) links (`system-linker-static-incorporation`).

The tool is `cc` found on PATH, never in the working directory, or
`BOTLISH_NATIVE_SYSTEM_LINKER` (a path, or a name on PATH). Any gcc or
clang driver works. `BOTLISH_NATIVE_LINK_LOG=FILE` appends every system
link's command line, its status and the linker's output to FILE.

GNU ld relaxes a GOT load of a symbol it resolves inside the executable
(`mov sym@GOTPCREL(%rip)` becomes `lea sym(%rip)`: a C function of a static
library). rustc's x86-64 linker, rust-lld, does not. The instruction keeps
its length and position, and the code is one load shorter.
`c-ffi-error-capture.test`'s single-stepping traces compare an executable's
function with its object's, and now allow exactly that relaxation
(`window::sameLinkedCode`: `lea` for `mov`, AArch64's `add` for `ldr`).

## 16. Apple's ld

**Executed** (macOS 15 on Apple silicon: macos-arm64.yml's `system-linker`
job; the paths shortened):

```
/usr/bin/cc -arch arm64 -mmacosx-version-min=11.0 -Wl,-dead_strip
    -o WORK/sl/.botlish-aot-PID-NONCE/executable
    WORK/sl/.botlish-aot-PID-NONCE/program.o WORK/sl/.botlish-aot-PID-NONCE/startup.o
    RELEASE/libbotlish_runtime.a -liconv -lSystem -lc -lm
```

* `/usr/bin/cc` is the xcrun shim to Apple clang, which runs Apple's ld.
* The flags are rustc's for aarch64-apple-darwin: the architecture, the
  deployment target, and dead stripping. The deployment target is
  rustc's default, 11.0, unless `MACOSX_DEPLOYMENT_TARGET` is set, which
  clang then reads itself.
* There is no PIE flag (every arm64 macOS executable is position
  independent) and no `--eh-frame-hdr` (ld writes Mach-O's own
  `__unwind_info`). There is no archive group either: Apple's ld searches
  the archives as often as a symbol needs and rejects GNU's group flags
  (the link plan's Apple flavor, C-FFI.md).
* The plan's `-L` and `-l` arguments are the rustc linker's Apple plan,
  unwrapped.
* ld warns `ignoring duplicate libraries: '-lSystem'`, because clang adds
  `-lSystem` itself. The warning goes to the link log only.
* The executable (hello-darwin.bot) is `Mach-O 64-bit executable arm64`.
  `otool -L` lists `/usr/lib/libiconv.2.dylib` and
  `/usr/lib/libSystem.B.dylib`, both part of macOS. Apple's ld signs an
  arm64 executable ad hoc, so it runs as linked and prints `Hello, world!`.

**The archive's system libraries.** rustc's `--print native-static-libs`
for the archive on macOS names `-liconv -lSystem -lc -lm`. The first CI
run linked with `-lSystem -lc -lm`, a list written without that account.
Every test still linked, because no archive member a Botlish executable
pulls in refers to libiconv, and the executable then depended on
libSystem alone. The list now matches rustc's (the check printed
`runtime archive libraries: -liconv -lSystem -lc -lm (as rustc accounts
for them)`), and ld records libiconv as a dependency even though nothing
uses it, since no `-dead_strip_dylibs` is passed. rustc's own macOS
command, recorded in MACOS-AARCH64-MILESTONE-6.md, passes the same
libraries and flags (`-liconv -lSystem -lc -lm -arch arm64
-mmacosx-version-min=11.0.0 ... -Wl,-dead_strip`) and no
`-dead_strip_dylibs` either. So the omission was avoidable: the record was
already there. `native/runtime-archive/libraries.tcl`, which every host's
system-linker job runs, fails the job when the two lists differ. Before,
only `single/build.sh` compared them, and only on Linux.

## 17. Microsoft's link.exe

**Executed** (windows-2025, Visual Studio 18 Enterprise, MSVC 14.51:
windows-x86_64.yml's `system-linker` job, which imports vcvars64.bat's
environment so that link.exe is on PATH; the paths shortened):

```
link.exe /NOLOGO /SUBSYSTEM:CONSOLE /INCREMENTAL:NO /OPT:REF /OPT:ICF /NXCOMPAT /DYNAMICBASE
    /OUT:WORK\sl\.botlish-aot-PID-NONCE\executable.exe
    WORK\sl\.botlish-aot-PID-NONCE\program.obj WORK\sl\.botlish-aot-PID-NONCE\startup.obj
    kernel32.lib
    RELEASE\botlish_runtime.lib kernel32.lib ntdll.lib userenv.lib ws2_32.lib dbghelp.lib
    libcmt.lib libvcruntime.lib libucrt.lib
    /NODEFAULTLIB:msvcrt.lib /NODEFAULTLIB:msvcrtd.lib /NODEFAULTLIB:vcruntime.lib
    /NODEFAULTLIB:vcruntimed.lib /NODEFAULTLIB:ucrt.lib /NODEFAULTLIB:ucrtd.lib
    /NODEFAULTLIB:libcmtd.lib /NODEFAULTLIB:libvcruntimed.lib /NODEFAULTLIB:libucrtd.lib
    /NODEFAULTLIB:msvcprt.lib /NODEFAULTLIB:msvcprtd.lib /NODEFAULTLIB:libcpmtd.lib
```

* The first `kernel32.lib` is the program's own plan: hello-windows.bot
  declares `extern c library "kernel32"`. The second is one of the
  runtime archive's system libraries. `botlish-native system-linker`
  reported `libraries kernel32.lib ntdll.lib userenv.lib ws2_32.lib
  dbghelp.lib`, and the library check agreed: `(as rustc accounts for
  them)`, rustc's `/defaultlib:` entry for the C runtime left out.
* The C runtime is the rustc linker's policy (`crt_args`,
  WINDOWS-X86-64-MILESTONE-2.md): the static release runtime, with every
  other Microsoft runtime excluded.
* `/INCREMENTAL:NO`: an incremental link's thunks would put a function's
  address somewhere other than its code, and the description's addresses
  must be the code's.
* The executable ran and printed `Hello, world!`. `dumpbin /dependents`
  lists `KERNEL32.dll`, `kernel32.dll`, `api-ms-win-core-synch-l1-2-0.dll`,
  `ntdll.dll` and `bcryptprimitives.dll`. All are system DLLs, and there
  is no `VCRUNTIME140.dll` and no UCRT `api-ms-win-crt-*`. kernel32
  appears twice, in two spellings: two import entries that the loader
  resolves to the same module (DLL names are case-insensitive).
* The tool is link.exe found on PATH. Botlish has no Visual Studio
  discovery of its own; rustc, by contrast, finds link.exe itself.
  **Inspected, not executed** (system-linker-toolchain-failures needs a
  Unix shell): without a Developer environment the link is `NATIVE AOT
  TOOLCHAIN` (`NATIVE LINK TOOLCHAIN` for a program that calls C), "the
  system linker needs Microsoft's linker to link an executable for
  windows-x86_64, and there is none: no link.exe on PATH. To link: run
  from a Visual Studio Developer Command Prompt (or after vcvars64.bat),
  ...". A `link` that is not Microsoft's (Git's or MSYS2's coreutils) is
  refused by its missing banner, `toolchain_error` as well.

## 18. Static libraries

**Executed** (Linux x86-64):

* `system-linker-c-acceptance` and `system-linker-static-incorporation`
  link the C fixture (tests/cffi/fixture.c) and a second library that
  depends on it, built here by `cc` and `ar`. The dependent library is
  declared first, which GNU ld can only resolve inside the archive group.
* The executable then runs from another directory, with the libraries and
  the copy of the runtime archive it was linked with deleted, and prints
  the fixture's arithmetic.
* `ffi-smoke-test.sh` does the same with the packed compiler.
* c-ffi.test's `cf-link-order` and `cf-link-directories` (paths with
  spaces, two directories, a missing one beside a real one) pass with the
  system linker.

**Static or dynamic is the linker's choice, as it is for the rustc linker.**
`-lNAME` finds `libNAME.so` before `libNAME.a` in a directory (`.dylib` or
`.tbd` before `.a` on macOS). The application controls the choice by what
its `-L` directory holds. The acceptance tests use a directory holding only
the archive, and the dynamic-dependency checks confirm no fixture library
is linked dynamically. Today's `extern c library` cannot ask for the static
one when both are beside each other. The smallest extension that could is
a linkage word on the declaration (`extern c library "SDL3" static`)
recorded in the link plan. GNU ld would then get `-l:libSDL3.a`. On macOS,
whose ld has no such spelling, it would get the archive's path, found by
Botlish in the `-L` directories. On Windows, `NAME.lib` already names one
file. That is for the milestone that links SDL3 statically, not this one:
the link plan's format and HIR's side table would change, and no test here
needs it.

## 19. Dynamic dependencies

**Executed** (Linux x86-64): `readelf -d` NEEDED of a system-linked
executable that calls libc's `labs` and two static fixture libraries:

```
libgcc_s.so.1, libm.so.6, libc.so.6, ld-linux-x86-64.so.2
```

These are exactly the rustc linker's (section 31), with no Botlish,
runtime or fixture library among them. The runtime archive is linked in,
so the executable never refers to the compiler's cache. The file is an
ordinary PIE (`readelf -h`: `Type: DYN`, `Machine: Advanced Micro Devices
X86-64`). Its symbols include `botlish_fn_0`, `botlish_entry_0`,
`botlish_program_description`, `main` and `botlish_runtime_startup_v1`, and
nothing is appended to it (`system-linker-ordinary-executable`).

## 20. Linked runs

A native backend's run of a program that calls C links an executable into
`botlish-run-PID-NONCE` and runs it in the driver protocol (C-FFI.md
section 11). That path is unchanged. With `BOTLISH_NATIVE_LINKER=system`
(or `auto`, the single executable's) the same `emit_executable` links it
with the system linker. The program's standard output and error are the
caller's, the result lines come back through `BOTLISH_NATIVE_RESULT`,
`--argv` reaches `argv()`, benchmark runs (`BOTLISH_NATIVE_RUNS`) report
`times` and `timing`, and the temporary directory is removed. **Executed:**
argv.test's linked-run tests, c-ffi.test's `cf-main-tcl`, `cf-argv` and
`cf-bench`, native-program-output.test and `system-linker-linked-run`
(main.tcl, both native backends) pass with the system linker, and so does
`ffi-smoke-test.sh`'s `-backend cranelift` run of the packed compiler.

## 21. Standalone executables

A system-linked executable:

* runs with the compiler, its cache and the C libraries deleted
  (`ffi-smoke-test.sh`, `system-linker-static-incorporation`);
* takes its own process arguments (`system-linker-outcomes`: `argv()` is
  its own path);
* reads standard input;
* prints its value, or a runtime error on standard error with a failing
  status;
* writes its startup report on request.

`tests/all.tcl` over the 61 test files that build an executable or link a
program that calls C passes with `BOTLISH_NATIVE_LINKER=system` (the
compile backend, this milestone's merged head): **3,265 tests, 3,191
passed, 74 skipped, 0 failed (executed, Linux x86-64)**. The skipped
tests are the same ones skipped under the rustc linker on this host:
other hosts' tests (Darwin IO 12, macOS's write interposer 4, other Apple
checks 2, Windows 24, AArch64 2, MinGW 9), a cross generation without the
arm64 C library (1), and BoringSSL (9) and Tcl's acceptance (9) without
their packages. The 2 tests of rustc's own invocation (`rustcLinker`)
make up the rest of the 74.

## 22. GC and coroutines

**Executed** (Linux x86-64):

* Under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every
  allocation site, so every safepoint's stack map is used), system-linked
  executables of the parity programs print exactly what the rustc and stub
  linkers' print.
* The coroutine program (200 suspended segments holding Strings and lists,
  resumed one by one) gives the same value under GC stress.
* coroutines.test, native-executable.test (stack overflows in Botlish code
  and coroutines, NATIVE LIMIT STACK, a moved multi-file application),
  c-byte-borrowing.test and c-ffi-error-capture.test pass with the system
  linker.

The startup report shows that the same stack maps were installed at the
same code offsets (section 10). The collector, the frame walker and the
coroutine ABI are unchanged.

## 23. Byte borrowing and C error capture

**Executed** (Linux x86-64), all with the system linker:

* c-byte-borrowing.test (19 passed, 1 skipped: a Windows test) and
  c-pointer-borrowing.test (62 passed).
* c-ffi-error-capture.test (27 passed), including the ptrace traces
  (`ec-trace`, `ec-trace-large-sentinel`, `ec-trace-captured`). These
  single-step a system-linked executable from a failing C call's return to
  the errno load: only the wrapper, `errno()` and `__errno_location` run,
  with no allocator, and the `(size_t)-1` sentinel is compared as a word
  and never boxed. The eager-foreign-result fault's executable still
  enters the allocator.

`system-linker-c-acceptance` calls libc, two static libraries, borrowed
`Bytes` (`bcf_sum`) and `MutableBytes` (`bcf_fill`, its write-back read
through C again), a variadic sum, an errno sentinel and the
`(size_t)-1` sentinel. It prints `[5, 42, 42, 37602, 1768, 888, 321, [16,
0, 1736], [-1, 34, 1736], [18446744073709551615, 5], [42, 0]]`, which is
the fixture's own arithmetic (37602 = Σ(7i+3 mod 256) over 300 bytes; 1768
= Σ(9+37i mod 256) over 16). It prints the same under GC stress and
beside the rustc linker's executable. Borrowing and directness validation
are the front end's and unchanged.

## 24. Linux x86-64: the single-file compiler

`single/build.sh` → `single/out/botlish`, 13,662,703 bytes. **Executed**
on this milestone's machine (Ubuntu 24.04, gcc 13.3) and in CI (section
32):

* `single/smoke-test.sh`, everything as before in an empty environment (no
  PATH, so no cc, ld, rustc or tclsh), plus:
  * a run that links nothing installs no runtime archive;
  * `-emit-native-executable` installs it, into a directory whose name
    carries its size;
  * a program that calls C is refused there with `NATIVE LINK TOOLCHAIN`
    ("...needs a C compiler driver to link an executable for linux-x86_64,
    and there is none: no cc on PATH. To link: install a C toolchain
    (Debian, Ubuntu: apt install gcc; Fedora: dnf install gcc), or name
    one with BOTLISH_NATIVE_SYSTEM_LINKER").
* `single/ffi-smoke-test.sh`, the packed compiler copied into a private
  directory and run with PATH holding only the C toolchain. The script
  fails if rustc or cargo is reachable, and strace confirms that no Rust
  process starts. It covers applications A to E of the brief:

```
   built a (879800 bytes)
   built b (898416 bytes)
   built c (927216 bytes)
   built d (945568 bytes)
   built e (1266000 bytes, stub-linked, no C compiler on PATH)
   ran a: 42  (needs: libgcc_s.so.1 libm.so.6 libc.so.6 ld-linux-x86-64.so.2 )
   ran b: [42, 42, 321]  (needs: ...)
   ran c: [37602, 1768, 888]  (needs: ...)
   ran d: [[16, 0, 1736], [-1, 34, 1736], [18446744073709551615, 5], [42, 0]]  (needs: ...)
   ran e: Hello from the stub linker | unit  (needs: ...)
   refused no C compiler: NATIVE LINK TOOLCHAIN
   refused a missing library: definitely_missing_botlish_lib
   refused an undefined symbol: botlish_no_such_symbol
   ran b on -backend cranelift
   refused the stub linker, chosen: the stub linker (BOTLISH_NATIVE_LINKER=stub) links no native library
ok
```

  The executables run after the compiler, its cache and the libraries are
  deleted, plainly and under GC stress, and their NEEDED entries name no
  Botlish or fixture library. A failed link keeps the previous executable,
  and no `.botlish-aot-*` directory is left behind.

`strace -f -e trace=execve` of the packed compiler linking a program that
calls C shows `botlish`, the installed `botlish-native`, `/usr/bin/cc`,
`collect2` and `/usr/bin/ld`, and nothing else.

**A real application.** With PATH holding only `/usr/bin:/bin` (no rustc),
the packed compiler builds the Icy Tower workload (examples/games/icy-tower,
ICY-TOWER-VERTICAL-SLICE-1.md) from its sources and the staged generated
SDL3 binding, against the package-owned headless libSDL3
(`tests/cffi/sdl3.tcl`): `botlish -warnings error -emit-native-executable
-L SDL3-DIR app/main.bot` takes 39 s and runs `botlish`, `botlish-native`,
`cc`, `collect2` and `ld`. The 1,360,864-byte executable (built before
section 30's fix, when every system-linked executable kept all the runtime
helpers) needs
`libSDL3.so.0`, `libgcc_s.so.1`, `libm.so.6` and `libc.so.6`. Its headless
runs agree with the game's independent oracle (`python3 -I
audit/icy-tower/oracle.py compare EXECUTABLE`: "0 differences" over every
seed and frame count of its grid), also under GC stress. (Executed on this
milestone's machine. SDL3 is linked dynamically, as the workload's own
build.sh links it.)

## 25. Linux AArch64

**The single executable: executed** (ubuntu-24.04-arm, single-executable.yml's
`build-arm64` job). `single/build.sh` builds it there unchanged: an
`ELF 64-bit LSB pie executable, ARM aarch64`. The library check passes, and
`single/ffi-smoke-test.sh` passes with only gcc on PATH:

```
   built a (1340912 bytes)
   built b (1347184 bytes)
   built c (1347832 bytes)
   built d (1348064 bytes)
   built e (1342000 bytes, system-linked: no stub on aarch64)
   ran a: 42  (needs: libgcc_s.so.1 libm.so.6 libc.so.6 )
   ran b: [42, 42, 321]  (needs: libgcc_s.so.1 libm.so.6 libc.so.6 ld-linux-aarch64.so.1 )
   ran c: [37602, 1768, 888]  (needs: ...)
   ran d: [[16, 0, 1736], [-1, 34, 1736], [18446744073709551615, 5], [42, 0]]  (needs: ...)
   ran e: Hello from the stub linker | unit  (needs: libgcc_s.so.1 libm.so.6 libc.so.6 )
   refused no C compiler: NATIVE LINK TOOLCHAIN
   refused a missing library: definitely_missing_botlish_lib
   refused an undefined symbol: botlish_no_such_symbol
   ran b on -backend cranelift
   refused the stub linker, chosen: the stub linker (BOTLISH_NATIVE_LINKER=stub) links no native library
ok
```

E is the program that calls no C (its text still says "stub linker"). On
AArch64 `auto` links it with the system linker, because there is no stub
(section 35). The arithmetic is x86-64's, byte for byte. The artifact is
uploaded (`botlish-linux-aarch64`) but not published.

**The test files** (**executed**: tests-arm64.yml's `system-linker` job
on 658737d8, ubuntu-24.04-arm, rustc 1.99.1, the compile backend, with
`BOTLISH_NATIVE_LINKER=system` for the whole job):

* `botlish-native system-linker`: `flavor gnu linux-aarch64`, `tool
  /usr/bin/cc`, `runtime .../libbotlish_runtime.a {ELF AArch64}`,
  `libraries -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc`. The library
  check agrees with rustc.
* The 61 test files that build an executable or link C: **3,266 tests,
  3,140 passed, 126 skipped, 0 failed**. The skipped ones are other
  hosts' tests (`linuxX86_64` 40, Darwin IO 12 and macOS's own 6,
  Windows 24), the stub's (`stubLinker` 7, and the stub-against-rustc
  parity, 1), packages not installed (BoringSSL, SDL3, Tcl sources,
  MinGW: 34) and rustc's own invocation (`rustcLinker` 2).
  system-linker.test's own comparisons with the rustc linker (startup
  parity, the helpers kept) ran.
* Under `BOTLISH_NATIVE_GC_STRESS=1`, system-linker.test, c-ffi.test,
  c-byte-borrowing.test, c-ffi-error-capture.test and coroutines.test:
  **260 tests, 253 passed, 7 skipped, 0 failed**. Coroutines switch
  native stacks with the AArch64 switch there.

## 26. macOS AArch64

**Executed** (macos-15-arm64, macOS 15.7.9, Apple clang 17, rustc 1.99.1:
macos-arm64.yml's `system-linker` job on 658737d8, with
`BOTLISH_NATIVE_LINKER=system` for the whole job):

* `botlish-native system-linker`: `flavor apple macos-aarch64`, `tool
  /usr/bin/cc`, `runtime .../libbotlish_runtime.a {Mach-O arm64}`,
  `libraries -liconv -lSystem -lc -lm`. The library check agrees.
* hello-darwin.bot linked and run (section 16).
* `tests/system-linker.test` on both Tcl backends: 14 tests, 10 passed,
  4 skipped (`linuxHost`: the closed-pipe and closed-descriptor run, the
  ELF checks, the strace of the link, the `nm` of the helpers kept). Startup parity is checked against the
  rustc linker: the startup reports of the two executables are identical
  and they print, fail and exit alike, plainly and under GC stress. The C
  acceptance program (libc, two static libraries, borrowed Bytes and
  MutableBytes, a variadic call, `__error()`'s errno and the `(size_t)-1`
  sentinel) prints exactly what it prints on Linux, `[5, 42, 42, 37602,
  1768, 888, 321, [16, 0, 1736], [-1, 34, 1736], [18446744073709551615,
  5], [42, 0]]`. Its executable runs after the
  libraries and the archive copy are deleted, and `otool -L` names no
  Botlish or fixture library.
* `tests/all.tcl` over the 61 test files that build an executable or link
  C: **3,266 tests, 3,076 passed, 190 skipped, 0 failed**. The skipped
  ones are other hosts' tests (`linuxX86_64` 40, `nativeLinux` 70,
  Windows 24), the stub's (8), BoringSSL, SDL3 and Tcl acceptance without their packages,
  MinGW, and rustc's own invocation (`rustcLinker` 2).
* Under `BOTLISH_NATIVE_GC_STRESS=1`, system-linker.test, c-ffi.test,
  darwin-io.test, c-byte-borrowing.test, c-ffi-error-capture.test and
  coroutines.test on both backends: **288 tests, 274 passed, 14 skipped,
  0 failed** on each backend. darwin-io.test is Darwin IO through
  libSystem's C functions; coroutines.test's executables switch native
  stacks.

The first run, before the fixes, had 2 failures out of 3,264. Startup
parity compiled the Linux Hello World on macOS; the test now compiles the
host's own. c-ffi.test's `cf-renamed-binding-native-name` failed on main
too and was fixed there; the fix is merged.

## 27. Windows x86-64

**Executed** (windows-2025, Visual Studio 18 Enterprise, MSVC 14.51:
windows-x86_64.yml's `system-linker` job on 658737d8, inside vcvars64.bat's
environment, with `BOTLISH_NATIVE_LINKER=system`):

* `botlish-native system-linker`: `flavor msvc windows-x86_64`, `tool
  ...\VC\Tools\MSVC\14.51.36231\bin\HostX64\x64\link.exe`, `runtime
  ...\botlish_runtime.lib {COFF x86-64}`, `libraries kernel32.lib
  ntdll.lib userenv.lib ws2_32.lib dbghelp.lib`. The library check
  agrees with rustc.
* hello-windows.bot linked by link.exe, ran and printed `Hello, world!`
  (section 17 has the command and `dumpbin /dependents`).
* The Windows-relevant executable and C test files (c-ffi.test,
  windows-io.test, argv.test, native-executable.test, c-float-ffi.test,
  workload-2048.test): **288 tests, 243 passed, 45 skipped, 0 failed** on
  each Tcl backend. The skipped ones: variadic C calls, which have no
  Win64 lowering (15); native coroutines and the stack guard (5); Linux's
  and macOS's own tests (5); launchers through bash and Python (14);
  BoringSSL (2), a dynamic system C library (1) and Tcl's library (1);
  rustc's own invocation (`rustcLinker`, 2).
* `tests/system-linker.test`, the first time it ran on Windows (until the
  ctool fix, section 34, every test of it was skipped there): 14 tests, 5
  passed, 6 skipped (`linuxHost` 4, `posixErrno`, `unixShell`) and **3
  failed** on each backend, and the same 3 under GC stress (with
  c-ffi.test: 132 tests, 100 passed, 29 skipped). All three were the
  tests' assumptions, not the linker's:
  * `system-linker-outcomes` expected native coroutines, which Windows
    has not got (a coroutine is NATIVE UNSUPPORTED there on every native
    backend, the rustc-linked executable's included), and argument zero
    spelled as Tcl spells the path; Windows passes `D:\a\...\argv.exe`.
  * `system-linker-auto` declared `extern c library "m"`; Windows' C math
    is in the C runtime and there is no `m.lib` (LNK1181).
  * `system-linker-link-failures` matched the unwritable destination's
    message against the path as Tcl spells it; the driver makes it
    absolute with `std::path::absolute`, which on Windows writes
    backslashes.

  The tests now expect the host's: the coroutine refusal where
  `nativeCoroutines` is false, argument zero in the host's spelling,
  `kernel32` as the declared library on Windows, and the driver's
  absolute native path. On Linux x86-64 the changed file passes, 14 of
  14 on both backends (executed). On Windows (3cc2a2b1, run
  40001867739) acceptance shard 4/4, whose tier runs system-linker.test
  on the interp backend, **passed**: 2,024 tests, 1,963 passed, 61
  skipped, 0 failed. The three tests pass, and system-linker.test skips
  the same six as before (8 of its 14 run). The system-linker job, which
  runs the file on both backends and under GC stress, was still queued
  when this was written (PENDING-WINDOWS-SYSTEM-JOB).
* The same three failures were acceptance shard 4/4's only ones (the
  tier runs system-linker.test too: 2,024 tests, 3 failed). Shards 1 to
  3, the smoke job and the root-plans job passed.

## 28. Mutation testing

**Executed** (Linux x86-64). Two harnesses, each mutant applied to a
private copy of the tree and run against its detectors:

* `audit/native-aot/tools/mutate.tcl`, whose detectors are the driver's
  `aot` unit tests, the library's `aotimage` tests and now
  `tests/system-linker.test` beside the executable tests it ran before. It
  gains 25 `sys-*` mutants of the system linker, the description and the
  linked startup.
* `audit/single-executable/tools/mutate.tcl` (new): 9 mutants of
  `single/package.tcl` and `single/main.tcl`. For each one it packs a
  single executable from the mutated tree (its `single/package.tcl`, the
  static tclsh `single/build.sh` cached and this checkout's native build)
  and runs `single/smoke-test.sh` and `single/ffi-smoke-test.sh` on it.

**The `sys-*` mutants: 25, 25 killed.**

| mutant | what it breaks | killed by |
|---|---|---|
| sys-auto-stub-for-c | auto links C with the stub | `linker_selection_auto_follows_the_link_plan`, system-linker-auto |
| sys-auto-system-for-plain | auto system-links a program that calls no C | the same |
| sys-runtime-omitted | no runtime archive in the link | the three `system_link_args_*` tests, 12 system-linker tests |
| sys-runtime-path-split | the archive's path split at spaces | system-linker-static-incorporation |
| sys-runtime-variable-ignored | `BOTLISH_NATIVE_RUNTIME` not read | system-linker-runtime-failures |
| sys-runtime-machine-unchecked | an archive of another machine linked | system-linker-runtime-failures |
| sys-description-local | the description a local symbol | 12 system-linker tests |
| sys-interface-not-referenced | the interface slot unrelocated | `startup_object_relocates_every_address`, 10 tests |
| sys-entries-swapped | direct and generic entries exchanged | `startup_object_relocates_every_address`, 4 tests |
| sys-constant-dropped | the last constant lost | startup parity, outcomes, C acceptance, process setup |
| sys-stack-maps-dropped | no stack maps | the same four |
| sys-root-dropped | one live root dropped per safepoint | startup parity, outcomes, C acceptance |
| sys-group-dropped | GNU ld without the archive group | `system_link_args_gnu` |
| sys-link-dirs-lost | `-L` directories dropped | the three `system_link_args_*` tests, 3 tests |
| sys-plan-lost | the libraries dropped | the same |
| sys-not-pie | a position-dependent executable | `system_link_args_gnu`, system-linker-ordinary-executable |
| sys-failed-link-replaces | the old executable removed first | system-linker-link-failures |
| sys-missing-linker-unclassified | collect2's missing ld a link failure | `missing_linker_is_a_toolchain_failure`, system-linker-toolchain-failures |
| sys-no-command-line-tools-unclassified | xcrun's missing tools a link failure | `missing_linker_is_a_toolchain_failure` |
| sys-revision-unchecked | another startup revision read | `linked_description_rejects_damage`, system-linker-damaged-description |
| sys-fingerprint-unchecked | another runtime build's description run | the same |
| sys-interface-unchecked | another startup interface accepted | `linked_description_rejects_damage` |
| sys-sigpipe-default | SIGPIPE left at its default | system-linker-process-setup |
| sys-fds-not-sanitized | a missing standard descriptor left closed | system-linker-process-setup |
| sys-fingerprint-keeps-helpers | the fingerprint over `helpers()` again (section 30) | system-linker-keeps-only-reached-helpers |

The first full run killed 21 of 23 and found two survivors, both real
gaps in the tests:

* **sys-missing-linker-unclassified** was equivalent. gcc's `collect2:
  fatal error: cannot find 'ld'` matched two of `missing_linker_lines`'
  patterns, so weakening one changed nothing. The redundant pattern is
  gone. The mutant now weakens the remaining one, and the unit test pins
  every pattern by a real tool's words: collect2, clang's `unable to
  execute command` and `invalid linker name`, xcrun's `invalid active
  developer path` and `unable to find utility`, and xcode-select's `No
  developer tools were found`. A new mutant,
  sys-no-command-line-tools-unclassified, pins macOS without the
  Command Line Tools.
* **sys-fds-not-sanitized** survived because system-linker-process-setup
  could not tell `/dev/null` from a closed descriptor. Its program handled
  WriteFailed, and Rust's standard output takes EBADF for success when it
  prints the result line, so a process left without descriptor 1 also
  exited 0. The test now runs a program whose failed write ends in a
  runtime error.

**The single-executable mutants: 9, 9 killed.**

| mutant | what it breaks | killed by |
|---|---|---|
| runtime-not-packed | no runtime archive in the zip | smoke-test.sh (emit), ffi-smoke-test.sh (build a) |
| runtime-never-installed | the archive never installed | smoke-test.sh (install check), ffi-smoke-test.sh |
| runtime-always-installed | installed by a run that links nothing | smoke-test.sh (install check) |
| backend-run-not-linking | `-backend cranelift` not taken for a run that may link | ffi-smoke-test.sh (`-backend cranelift` of b) |
| id-without-runtime | the build id ignores the archive | smoke-test.sh (cache directory name) |
| linker-stub | everything stub-linked, as before | smoke-test.sh (no NATIVE LINK TOOLCHAIN), ffi-smoke-test.sh |
| linker-system | everything system-linked | smoke-test.sh (emit hello needs cc), ffi-smoke-test.sh (e without cc) |
| linker-choice-overridden | an explicit `BOTLISH_NATIVE_LINKER` replaced by auto | ffi-smoke-test.sh (stub chosen) |
| installed-modes-decimal | modes from `expr`, which reads 0755 as decimal | smoke-test.sh (modes 1363 1363 1204, want 755 755 644) |

The last mutant is the bug CI found in this milestone's first
single-executable build. A run that started the stub failed with
"botlish-aot-stub: Permission denied": the installed files had modes
`--wxrw--wt`. The local smoke tests ran as root, which can read and run
a file whatever its mode, and so they passed. They now check the exact
modes, and they pass as `nobody` too.
`runtime-never-installed` was killed only by ffi-smoke-test.sh until
smoke-test.sh gained its install check.

## 29. Fuzzing

The C FFI's and byte borrowing's fuzzers, which build random C libraries
(static archives, compiled here) and Botlish bindings and compare every
call's outcome with an independent model, run unchanged with
`BOTLISH_NATIVE_LINKER=system` (their programs are linked by the native
backends' linked runs). **Executed** (Linux x86-64; the link log confirms
each program was linked by the system linker):

| fuzzer | run | result |
|---|---|---|
| `audit/c-ffi/tools/fuzz.tcl` | `-n 10 -seed 1` | 10 programs, 120 functions, 43 variadic, 211 trailing arguments, 0 disagreements |
| | `-n 10 -seed 2` | 120 functions, 32 variadic, 107 trailing, 0 disagreements |
| | `-n 10 -seed 9 -gc-stress 1` | 120 functions, 33 variadic, 143 trailing, 0 disagreements |
| `audit/c-pointer-borrowing/tools/fuzz.tcl` | `-n 10 -seed 1` | 80 cases, 33 refused, 0 disagreements |
| | `-n 10 -seed 2` | 80 cases, 37 refused, 0 disagreements |
| | `-n 10 -seed 9 -gc-stress 1` | 80 cases, 48 refused, 0 disagreements |

No new fuzzer: the system linker changes no call's semantics, only how its
executable is made, and the existing fuzzers' programs are exactly the
inputs that would expose a wrong link.

## 30. Sizes

**Executed** (Linux x86-64; `bench/system-linker.tcl -runs 7 -single
single/out/botlish`):

| what | bytes |
|---|---:|
| the single executable | 13,662,703 |
| its runtime archive, unpacked (`strip --strip-debug`) / compressed in the zip | 16,097,728 / 5,002,339 |
| its driver, unpacked / compressed | 10,231,448 / 2,847,463 |
| its stub, unpacked / compressed | 1,258,456 / 489,151 |
| the same zipkit without the runtime archive (estimated: the archive's compressed entry removed) | about 8,660,000 |

| program | linker | as linked | stripped | dynamic dependencies |
|---|---|---:|---:|---|
| prints a line, calls no C | system | 9,495,960 | 725,856 | libgcc_s, libm, libc, ld-linux |
| | rustc | 9,536,760 | 685,792 | the same |
| | stub | 9,921,323 | (not strippable: the image is appended) | the same |
| calls libc and a static library | system | 9,490,936 | 717,664 | the same |
| | rustc | 9,527,768 | 675,704 | the same |

* As linked, almost all of an executable is the runtime's line tables
  (`debug = 1`). The single executable's archive is `--strip-debug`'d, so
  the executables it makes are 0.88 to 0.95 MB (section 24).
* Stripped, a system-linked executable is 40 to 42 KB (6%) larger than the
  rustc linker's: the description's decoder, its checks and their messages
  (`aotimage::read_linked`), which the rustc linker's generated startup
  does not need.

**A size defect this measurement found.** The first measurement had the
system-linked executables at 996,216 bytes stripped against rustc's
659,184 (one program, `compute.bot`): `.text` 213 KB and `.rodata` 78 KB
larger. They kept all 163 runtime helpers (`nm`: 163 `rt_*` symbols,
against the rustc-linked executable's 5), as the stub does, which must.
The cause was `aotimage::abi_fingerprint`, which every system-linked
startup computes to check its description. It hashed the helpers' names
and parameter counts by iterating `ops::helpers()`, whose entries also
hold every helper's address, and taking an address keeps the code. The
helper list is now one macro expanding to `HELPER_SIGNATURES` (names and
counts) and `helpers()` (with addresses), and the fingerprint reads the
former. Its value is unchanged (the same words, in the same order). The
same program is now 705,376 bytes and keeps 5 helpers, and its startup
report is the rustc-linked executable's, byte for byte.

## 31. Link and startup benchmarks

**Executed** (Linux x86-64, a shared 4-core container; `bench/system-linker.tcl
-runs 7`).

Link, ms, best of 7. `native::executable` from the HIR is the NIR
lowering in Tcl, the object, the startup and the link. The stub's column is
nearly all lowering and object, so the difference from it is a linker's own
cost:

| program | object (driver) | system | rustc | stub |
|---|---:|---:|---:|---:|
| prints a line | 9.6 | 351.1 | 613.3 | 148.9 |
| calls libc and a static library | 5.6 | 225.0 | 465.4 | refused |

The system linker adds about 200 ms to the stub's time here: `cc` and
GNU ld over the program object, the startup object and the 16 MB archive.
The rustc linker adds about 460 ms, compiling the startup crate with rustc
and then linking.

Runs, ms, best / median of 21, the linkers' executables interleaved run by
run:

| run | system | rustc | stub |
|---|---:|---:|---:|
| process life (prints a line) | 2.2 / 2.4 | 2.1 / 2.7 | 2.3 / 2.5 |
| 200,000 Strings built | 30.4 / 37.2 | 30.0 / 34.2 | 32.3 / 38.4 |
| 2,000 Strings under GC stress | 15.1 / 20.8 | 16.1 / 19.4 | 16.5 / 21.5 |
| 200,000 C calls (labs, bcf_add) | 12.0 / 13.3 | 12.1 / 12.9 | - |

The executables run the same code: Cranelift's, and the same runtime
built once. Within this machine's noise they take the same time, and the
startup (description read, checked and installed) is not measurable
beside a process's life. An earlier version of the benchmark ran each
linker's executables back to back and showed the system linker's 20%
slower on the String run; interleaved, the difference disappears (a
separate 31-run check: medians 34.3, 33.7 and 33.9 ms). The medians here
still differ by up to 4 ms between runs of the benchmark: this machine's
times are bimodal (p90s near 52 ms), and the best is the comparable figure.

The single executable (whole invocations, which compile their program
first, so they compare installations, not linkers):

| invocation | ms |
|---|---:|
| first run, installing the driver and the stub (a compile-backend run) | 1,344 |
| the same, warm | 1,224 |
| first link of a C program, installing the runtime archive | 446 |
| the same, warm | 423 |
| a warm stub link of the plain program (its front end: context traits, `std::io`) | 974 |
| `-version` / `-help` (install nothing) | 125 / 178 |

Installing the runtime archive, 16 MB extracted from the zip and renamed
into place, costs about 20 ms, once per build of the compiler.

## 32. Linux CI

The jobs this milestone adds:

* **tests.yml `system-linker`** (ubuntu-latest; tests.yml runs on pushes
  to main, pull requests and dispatch). It builds the native backend, prints `botlish-native
  system-linker` and runs the library check. Then every test file that
  builds an executable or links C runs with `BOTLISH_NATIVE_LINKER=system`
  (`tests/all.tcl -file`, the compile backend). Finally system-linker.test,
  c-ffi.test, c-byte-borrowing.test, c-ffi-error-capture.test and
  coroutines.test run again under `BOTLISH_NATIVE_GC_STRESS=1`.
  **Passed** on 658737d8 (dispatched on this branch, run 39971743487): the
  library check, then **3,266 tests, 3,186 passed, 80 skipped, 0 failed**
  over the 61 files, and under GC stress **260 tests, 254 passed, 6
  skipped, 0 failed**. The same run's interp suite, golden shard 3,
  stub-linked executables, native Rust unit tests, warning gate,
  method-filter audit, golden shards 1, 2 and 4 and the cranelift and
  cranelift-generic coverage and the compile suite passed too: every job
  of the run passed (the GC-stress job runs on pushes to main only).
* **tests-arm64.yml `system-linker`** (ubuntu-24.04-arm): the same on
  AArch64. **Passed** on 658737d8 (run 39971747629; section 25 has the
  numbers), and so did every other job of that run: interp, compile,
  cranelift and cranelift-generic coverage, the four golden shards, the
  native Rust unit tests (also under GC stress) and the GC-stress run.
* **single-executable.yml**:
  * `build` (ubuntu-24.04): `single/build.sh`, which runs the library
    check, then smoke-test.sh and ffi-smoke-test.sh on the build machine.
    **Passed.**
  * `build-arm64` (ubuntu-24.04-arm): the same build, with
    ffi-smoke-test.sh. **Passed** (section 25). Not published.
  * `smoke` (stock `ubuntu:24.04` and `ubuntu:latest` containers):
    smoke-test.sh with no toolchain at all, as before. It now also checks
    the install, the modes and the C refusal.
  * `ffi-smoke` (new; the same images): `apt-get install gcc libc6-dev
    binutils`, and the job fails if `rustc` or `cargo` exists. It deletes
    the checkout, keeping only ffi-smoke-test.sh and the C fixture, and
    runs the downloaded executable. `ubuntu:latest` (gcc 15.2) and
    `ubuntu:24.04`: **passed**, applications A to E as on the build
    machine.
  * `release` now needs `ffi-smoke` as well, and its notes say what a
    program that calls C needs.

  On 658737d8 (dispatched on this branch, run 39971751378) every job
  **passed**: `build`, `build-arm64`, `smoke` on both images and
  `ffi-smoke` on both. `release` is skipped off main.

The Linux results quoted elsewhere in this report come from this
milestone's machine (Ubuntu 24.04 x86-64, gcc 13.3). There:
`tests/local.tcl` on the 26 files this milestone touched passed (52 runs,
0 failed), and so did the executable and C test files under the system
linker (section 21).

## 33. macOS CI

macos-arm64.yml gains a `system-linker` job (macos-15, every branch push).
It runs with `BOTLISH_NATIVE_LINKER=system` throughout: the discovery
facts and the library check, hello-darwin.bot linked, `file`'d,
`otool -L`'d and run, system-linker.test on both Tcl backends, every
executable and C test file, and the GC-stress set with darwin-io.test
added. On this milestone's merged head it **passed**: section 26 has the
numbers. Every other macOS job (smoke, both acceptance shards, the Linux
control) passed on the same head: the rustc-linked tiers are unaffected
by the runtime archive in the build. On the final head (658737d8, the
helper fix of section 30 included) every macOS job **passed** again, the
system-linker job's GC-stress step included (run 39971727086). On
3cc2a2b1, which changes system-linker.test for Windows (section 27), the
system-linker job, smoke, acceptance shard 1/2 and the Linux control
**passed** (run 40001867659), and so did shard 2/2: every macOS job
passed on 3cc2a2b1.

## 34. Windows CI

windows-x86_64.yml gains a `system-linker` job (windows-2025). It imports
vcvars64.bat's environment into the step, then: the discovery facts, the
library check, hello-windows.bot linked and run with the link command
logged, `dumpbin /dependents`, system-linker.test, the Windows-relevant
executable and C test files, and system-linker.test and c-ffi.test under
GC stress.

Its first run found two problems, neither in the system linker:

* **Every system-linker test and C fixture was skipped.**
  tests/ctoolchain.tcl took an existing Developer environment for no
  MSVC: an empty dict, meaning "nothing to add", is `""` in Tcl. Fixed:
  `ctool::HaveMsvc`. The rustc-linked jobs never ran inside a Developer
  environment, so they never saw it.
* **c-ffi.test's `cf-system-library` failed** with `LNK1146: no argument
  specified with option '/LIBPATH:'`. With the fixture unbuilt (the
  first problem), the test passes an empty fixture directory as a link
  directory. This is latent under every linker; with the fixture built it
  cannot occur. It is recorded for a separate fix (section 35).

The smoke job (rustc-linked, unchanged) **passed** on the merged head;
before the merge, its one failure was `cf-renamed-binding-native-name`
(fixed on main).

Its second run (658737d8, run 39971727264), the first in which
system-linker.test ran on Windows, found three more, again in the tests'
assumptions and not in the linker (section 27 has them and their fix).
They failed the system-linker job and acceptance shard 4/4, whose tier
runs system-linker.test too. Everything else passed: the library check,
hello-windows.bot, the Windows executable and C test files under the
system linker (288 tests, 0 failed, on each backend), the smoke job, the
root-plans job and acceptance shards 1 to 3. On 3cc2a2b1, with the fixed
tests (run 40001867739), the smoke job, the root-plans job and all four
acceptance shards **passed**, shard 4/4 with system-linker.test in it
(section 27). The system-linker job: PENDING-WINDOWS-SYSTEM-JOB.

## 35. Remaining distribution work

* **macOS and Windows single-file compilers** are not built here. The
  system linker and the runtime archive are the parts of them this
  milestone owns, and both work there (sections 26 and 27). What is left
  is the distribution itself: a Tcl 9 zipkit (or an application bundle)
  for each, its signing, its cache location, and its CI.
* **No stub off Linux x86-64.** A single-file compiler on Linux AArch64,
  macOS or Windows links every executable with the system linker (`auto`'s
  choice where there is no stub). That includes a program that calls no
  C, so there it needs a C toolchain for any executable: the Command Line
  Tools on macOS, the Visual Studio Build Tools on Windows, gcc on Linux
  AArch64. Running programs on the native backends needs none: the JIT
  runs everything but a program that calls C. An AArch64 ELF stub is
  possible (LINUX-SYSCALL-TRANSPORTS.md lists what it needs). A Mach-O or
  PE stub is excluded (AGENTS.md).
* **Static or shared, by the program.** `extern c library` cannot yet ask
  for a library's static archive when the shared one is beside it (section
  18). A `static` linkage word in the declaration is the smallest
  extension.
* **Frameworks.** A macOS program that links a static library which needs
  Apple frameworks (SDL3 needs Cocoa, Metal, IOKit and others) has no way
  to declare them: `extern c library` is `-lNAME`. The same milestone as
  `static` would add `extern c framework "NAME"` (`-framework NAME`) to
  the link plan.
* **The fingerprint before linking** (section 11) would need a
  compile-time fingerprint. Today a mismatched archive is caught when the
  executable first starts.
* **The archive's size.** 16 MB stripped, 5 MB compressed in the zipkit.
  The executables it makes are 6% larger stripped than the rustc linker's
  (section 30): the description's decoder and its checks. No runtime split
  is warranted (section 7).
* **Publishing the AArch64 build.** single-executable.yml builds and
  smoke-tests it (section 25) but publishes only x86-64's.
* **An empty link directory.** c-ffi.test passes its fixture directory
  as a link directory even when the fixture did not build and the
  directory is `""`. link.exe then gets `/LIBPATH:` alone (LNK1146). gcc
  gets `-L` alone, which takes the next argument as the directory. The
  test should pass no directory then. Whether `--link-dir ""` should be
  refused by the driver is a separate question. It predates this
  milestone and affects every linker.

## 36. For the next macOS milestone

What a macOS single-file compiler needs from this one, and what it must add:

* **The archive.** `cargo build --release --manifest-path
  native/Cargo.toml` on macOS makes `libbotlish_runtime.a` for
  aarch64-apple-darwin beside the driver (section 26). `single/package.tcl`
  packs it unchanged. The stub (`botlish-aot-stub`) is useless there and
  can be left out of a macOS package, with `auto` choosing the system
  linker for every program.
* **The toolchain.** The system linker runs `cc` (`/usr/bin/cc`, the xcrun
  shim to Apple clang). Without the Command Line Tools, xcrun's "invalid
  active developer path" or "No developer tools were found" makes the link
  `NATIVE LINK TOOLCHAIN` with the remedy `xcode-select --install`
  (`missing_linker_lines`). The runners always have Xcode, so that message
  must be checked on a machine without one.
* **The deployment target.** The link passes `-mmacosx-version-min=11.0`
  (rustc's default for aarch64-apple-darwin, which the archive was built
  for) unless `MACOSX_DEPLOYMENT_TARGET` names one, as rustc does. A
  distribution that raises the minimum must build the archive with the
  same variable.
* **Signing.** Apple's ld signs every arm64 executable ad hoc at link time,
  on the user's machine, so the executables the compiler makes run there.
  The compiler itself, downloaded, needs a Developer ID signature and
  notarization. Nothing here changes how its own executables are signed.
* **The cache.** The archive is installed beside the driver in the
  per-build cache directory (section 13). On macOS that should be
  `~/Library/Caches/botlish` rather than `~/.cache`, which
  `single/main.tcl`'s `CacheRoots` would learn.
* **Static SDL3** needs the `static` linkage word and frameworks (section
  35), and the frameworks SDL3's own build reports (`sdl3.pc`'s
  `Libs.private`).
* **A bundled Tcl.framework**, if the macOS kit links Tcl dynamically,
  is the kit's and does not affect the system linker: the compiler's
  executables never link Tcl.

## 37. What to run when changing this

* The system linker (`codegen/aot.rs`'s `chosen_linker`,
  `startup_object`, `system_link_args`, `link_system`, `runtime_archive`,
  `archive_machine`), the linked description (`aotimage.rs`'s
  `Image::linked`, `linked_description`, `read_linked`, `linked_main`),
  `aot::rust_process_setup`, `Vm::startup_report`, the ABI fingerprint or
  ops.rs's helper list (`runtime_helpers!`) or native/runtime-archive:
  * `cargo test --release --manifest-path native/Cargo.toml --lib
    aotimage` and `--bin botlish-native aot::`;
  * `tests/system-linker.test`;
  * the executable and C test files with `BOTLISH_NATIVE_LINKER=system`
    (tests.yml's `system-linker` job has the command), and the same under
    `BOTLISH_NATIVE_GC_STRESS=1` for the C ones;
  * `tests/aot-stub-linker.test`;
  * `audit/native-aot/tools/mutate.tcl` (every `sys-*` mutant must still
    apply and be killed);
  * on macOS and Windows, those workflows' `system-linker` jobs (every
    branch push).
* The single executable's packing or installation (`single/package.tcl`,
  `single/main.tcl`, `single/build.sh`): `single/build.sh`, then
  `single/smoke-test.sh` and `single/ffi-smoke-test.sh` on its output, and
  `audit/single-executable/tools/mutate.tcl`.
* The runtime's system libraries (a Rust upgrade, a new dependency):
  `tclsh9.0 native/runtime-archive/libraries.tcl` (single/build.sh and
  every system-linker CI job run it) stops when they differ from rustc's
  account. Update `runtime_system_libraries`, never the check.
* `bench/system-linker.tcl` regenerates sections 30 and 31.
