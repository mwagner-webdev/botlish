# MACOS-AARCH64-PORT-AUDIT.md

The Linux assumptions a native macOS Apple Silicon port of Botlish has to
deal with, where they live, and the CI that tests the port on real Apple
Silicon. Written for the agents of the port's later milestones: start
here, then read the section of the subsystem you are changing. The
milestone that produced it is MACOS-AARCH64-MILESTONE-1.md.

> Let Cranelift own the Apple AArch64 machine ABI, let Mach-O and the
> system linker own executable format and native symbol resolution, and add
> only the Botlish runtime/platform adaptation macOS actually requires. Do
> not build a Darwin toolchain inside Botlish.

The target: macOS (Darwin) on Apple AArch64 (arm64), 64-bit pointers, the
LP64 C data model, the Apple AArch64 C ABI, Mach-O objects, executables
linked by the normal Apple toolchain (through the existing rustc linker
driver). core/cabi.tcl already names it `macos-aarch64`.

## Contents

1. [What is verified on a real macOS arm64 host](#1-what-is-verified-on-a-real-macos-arm64-host)
2. [How to read the findings](#2-how-to-read-the-findings)
3. [Compiler target model (Tcl)](#3-compiler-target-model-tcl)
4. [Cranelift, JIT and object generation](#4-cranelift-jit-and-object-generation)
5. [Executables, the driver, the stub linker and the single executable](#5-executables-the-driver-the-stub-linker-and-the-single-executable)
6. [Runtime: threads, stack bounds and overflow](#6-runtime-threads-stack-bounds-and-overflow)
7. [GC roots and the frame walk](#7-gc-roots-and-the-frame-walk)
8. [Coroutines](#8-coroutines)
9. [Syscall transports, direct modules and contextual IO](#9-syscall-transports-direct-modules-and-contextual-io)
10. [C FFI](#10-c-ffi)
11. [Tests and the test harness](#11-tests-and-the-test-harness)
12. [Packaging, audit tools and benchmarks](#12-packaging-audit-tools-and-benchmarks)
13. [Already portable: reuse unchanged](#13-already-portable-reuse-unchanged)
14. [Boundaries where a broad change would regress Linux](#14-boundaries-where-a-broad-change-would-regress-linux)
15. [The macOS census](#15-the-macos-census)
16. [CI and test tiers](#16-ci-and-test-tiers)
17. [Roadmap](#17-roadmap)

## 1. What is verified on a real macOS arm64 host

Every fact in this section was observed on GitHub's `macos-15` runner by
`.github/workflows/macos-arm64.yml` (runs listed in
MACOS-AARCH64-MILESTONE-1.md). Everything else in this document comes from
reading the code and the pinned crates (cranelift-* 0.135.2, object 0.39.1,
libc 0.2.189 in `native/Cargo.lock`), and says so where it matters.

**The host.** macOS 15.7 (Darwin 24.6.0), `uname -m` = `arm64`, "Apple M1
(Virtual)", 3 CPUs, 7 GiB, **16 KiB pages** (`hw.pagesize` = `getconf
PAGESIZE` = 16384). Xcode 16.4, macOS SDK 15.5, Apple clang 17.0.0
(`arm64-apple-darwin24.6.0`), Apple ld (ld-prime, `ld-1167.5`). `/bin/bash`
is 3.2.57 and is what a workflow's `shell: bash` runs. No `nproc` and no
`timeout` (GNU coreutils) on the image; `objdump` is Xcode's
(`/usr/bin/objdump`), and there is no `readelf` (the census skips
native.test's `readelf` test).

**The toolchains work** (tests/platform/toolchain-smoke.sh): cc compiles,
links and runs a C program, also against a static archive with `-L DIR
-lNAME`; rustc and Cargo build and run Rust programs; each is a `Mach-O
64-bit executable arm64`. That proves the host builds native code. It says
nothing about Botlish.

**C ABI facts** (tests/platform/cabi-facts.tcl): Apple clang's `char` 8
bits and **signed**, `short` 16, `int` 32, `long` 64, `long long` 64,
pointers 64 -- exactly core/cabi.tcl's `macos-aarch64` row, which no
compiler had checked before (the C header archaeology's probe checked the
Linux x86-64 row, and the arm64 CI's C FFI tests exercise Linux
AArch64's). Plain char is signed on Apple arm64 and unsigned on Linux
AArch64: the one scalar fact that differs between the two aarch64
targets.

**Rust keeps frame records.** rustc 1.98/1.99 for `aarch64-apple-darwin`,
at `-O`, gives a function that calls `stp x20, x19, [sp, #-32]!; stp x29,
x30, [sp, #16]; add x29, sp, #16` with no flag: the frame record is kept
by default, and it sits at the *top* of the callee-save area, where Linux
AArch64 puts it at the bottom (`runtime/framewalk.rs`'s header). On Linux
x86-64 the same probe shows no frame pointer, which is why
`.cargo/config.toml` forces one there.

**Tcl.** The CI builds the repository's baseline, Tcl 9.0.1, from its
pinned source release (tests/platform/setup-macos.sh). Homebrew's
`tcl-tk`, which the first runs used, is Tcl **9.0.4**, and that is not
equivalent: its Unicode 17 case tables make the Tcl backends'
`std::str::lowercase` disagree with Botlish's Unicode 16 semantics, which the
native runtime keeps (section 15). `tcl_platform(os)` is `Darwin`,
`machine` `arm64`, so `core::cabi::hostTarget` is `macos-aarch64`. Tcl's
system encoding and stdout encoding are `utf-8` whatever LANG/LC_ALL say
(unset, `C`, `C.UTF-8`, `en_US.UTF-8`): the Linux `C.utf8` precaution is
unnecessary there, and harmless.

**What Botlish does there today** (with the native backend built by the
ordinary `cargo build --release --manifest-path native/Cargo.toml`):

- The front end, the interpreter and the Tcl compiler run the sample
  programs and the front-end test files unchanged.
- **The native crate compiles** (about 1 minute, cold, on the runner),
  with five dead-code warnings: coroutine.rs's stack constants and
  functions that only the Linux build uses.
- **Its 215 library unit tests pass** (`cargo test --release --lib`),
  including the frame-walk tests, which walk real test-thread stacks with
  no stack bound.
- **The JIT works**: `main.tcl -backend cranelift` runs the surface
  samples to the right values. cranelift-jit's code memory (read-write
  pages flipped to read-execute with `mprotect`, no `MAP_JIT`) is accepted
  for the unsigned (linker-ad-hoc-signed) `botlish-native` on this runner.
- **Executable emission is refused**, explicitly: `executable emission
  requires Linux glibc on x86_64 or aarch64 (NATIVE AOT)`. **Since
  milestone 5** (MACOS-AARCH64-MILESTONE-5.md) it is not: an ordinary
  program becomes a Mach-O arm64 executable through the rustc linker and
  runs standalone; a program that calls C is still refused (NATIVE LINK).
  **Since milestone 6** (MACOS-AARCH64-MILESTONE-6.md) that is not refused
  either: it links through Apple's ld with the C libraries it declares
  (static and dynamic, `-L` directories, libSystem) and calls them with
  Apple's arm64 C ABI, checked against Apple clang's own calls.
- **Byte borrowing** (milestone 7, MACOS-AARCH64-MILESTONE-7.md): Bytes and
  MutableBytes storage reaches C calls by the same exposures as on Linux --
  the payload address for reading, a private copy for writing -- checked
  through real C, libSystem's own byte functions and Guard Malloc.
- **IO** (milestone 8, MACOS-AARCH64-MILESTONE-8.md): `std::darwin::io::DarwinIO`
  implements the portable `std::io::IO` through libSystem's write(2); the portable
  Hello World and the 2048 demo run as Mach-O executables with it. No
  Darwin syscall is used anywhere.

The census (section 15) has the rest: every test file and golden suite on
this host.

## 2. How to read the findings

Each table row is one assumption: where it is, what it assumes, its class,
what macOS needs, the risk, the milestone that owns it (section 17), and
whether it can be checked statically on Linux (**L**) or needs macOS
execution (**M**).

Classes:

| Class | Meaning |
|---|---|
| **arch** | architecture-specific (x86-64 vs AArch64), not OS-specific |
| **elf** | ELF/object-format-specific |
| **linux** | Linux-runtime-specific (kernel, glibc, `/proc`, GNU tools) |
| **posix** | portable POSIX behavior, expected to hold on macOS |
| **owned** | already owned by Cranelift, Rust or the system toolchain |
| **test** | a test-only assumption |

Risk: **low** (local, mechanical), **medium** (a subsystem's platform
layer), **high** (correctness of generated code or the GC, or wide test
fallout).

## 3. Compiler target model (Tcl)

The front end already has a target dimension: a compilation's C ABI
target, `-target NAME` or the host's. It is keyed by OS *and*
architecture, and the macOS rows exist. What was keyed by architecture
alone -- the Linux syscall layer and the choice of an
architecture-specific module -- milestone 2 resolved: a target is an
operating system and an architecture everywhere target-dependent meaning
enters (C facts, module resolution), persists (the HIR, interchange, the
cache) or runs (the native driver). MACOS-AARCH64-MILESTONE-2.md has the
details and the evidence.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| core/cabi.tcl `targets`, `models` | **resolved (milestone 2)**: each row names its triple; `macos-aarch64 {os macos arch aarch64 model LP64 charSigned 1 triple aarch64-apple-darwin}`, distinct from `linux-aarch64` (same arch, model and pointer width; other OS, triple and plain char). `operatingSystems`, `systemName`, `hostArchitecture`, `systemTarget` added | -- | none: verified against Apple clang per scalar, `size_t` and `-dumpmachine` (cabi-facts.tcl, every smoke job) | low | 2 (done) | M (done) |
| core/cabi.tcl `hostTarget` | none: Darwin -> macos, arm64 -> aarch64 | -- | none: verified, `macos-aarch64`; the OS is read, never inferred from the architecture (tests/target-model.test `tm-host-default`) | low | 2 (done) | M (done) |
| core/linuxabi.tcl `transports`, `transportOf`, `syscallImpl` ("on Linux") | the syscall transport table is keyed by architecture only | arch + linux | **resolved at the import (milestone 2)**: the table stays Linux's and no macOS compilation reaches it -- its namespaces `std::linux::abi::*` are the Linux platform's, UNSUPPORTED-PLATFORM for any other OS's target. Never a Darwin row (section 9) | low | 2 (done), 9 | L (done) |
| core/linuxabi.tcl registration | both transports registered and their namespaces declared direct whatever the target | linux | **resolved (milestone 2)**: still registered everywhere (bootstrap natives, the same in every compilation), but a macOS compilation cannot import them (UNSUPPORTED-PLATFORM); a Linux program run natively on macOS is refused (NATIVE TARGET) before the runtime refusal | low | 2 (done) | L (done) |
| core/bytestore.tcl `bridges` | `std::abi::ARCH::from_bytes`/`from_mutable_bytes` come from the Linux transport table | arch | OS-neutral in substance (an address to a register word); unchanged: `std::abi::ARCH` are portable architecture namespaces, importable on macOS | low | -- | L |
| surface/modules.tcl `ModuleFile`, `ArchModuleFiles`, `PlatformOf`, `PlatformCheck`, `ResolveModule` | an architecture-specific module is chosen by architecture only | arch | **resolved (milestone 2)**: the namespace trees the target table designates a platform's (`platforms`: `linux`) are that OS's, checked at the import before any file is chosen: `import std::linux::sys` for `macos-aarch64` is UNSUPPORTED-PLATFORM, never `sys.aarch64.bot`. Portable architecture-specific namespaces (a `demo::arch`, `std::abi::aarch64`) are every OS's; application modules the application's | low | 2 (done) | L (done) |
| surface/cache.tcl `Key`, `Dependencies`, `lookup` | none for the key: it holds the full target name | -- | **verified and hardened (milestone 2)**: one entry per full target (tests/target-model.test `tm-cache-target-isolation`, both orders), and a hit's HIR is decoded with `-target` (an entry of another target filed under this key is invalid: `tm-cache-entry-of-another-target`). Dependencies unchanged: a Linux module's build for macOS fails and is never stored | low | 2 (done) | L (done) |
| hir/interchange.tcl `decode`; main.tcl `runFile`, `emitExecutable` | a `.hirx` records no target | posix | **resolved (milestone 2)**: the HIR records its target (`hir::cabi::targetOf`: the compilation target when the build read one, "" for a HIR every target shares), interchange carries it, `decode -target T` refuses another target's (HIR INTERCHANGE TARGET), main.tcl reads a `.hirx` for its `-target` or the host's. No format version change: the field is part of the HIR dict | low | 2 (done) | L (done) |
| main.tcl, hir/cabi.tcl `ResolveTarget`, hir/foreign.tcl `AbiClass` | nothing compares the target with the host before a native run or link | posix | **resolved (milestone 2)**: NIR names the program's target (`target "NAME" triple="TRIPLE"`) and the driver refuses `run`, `bench`, `batch`, `object` and `executable` for another target (NATIVE TARGET: `-target windows-x86_64` on Linux no longer runs a 32-bit `long` C call); the diagnostic commands (`clif`, `vcode`, `size`, `roots`) still show the host's view | low | 2 (done) | L (done) |
| surface/modules.tcl `LoadNamespace` | `NamespaceTypeDecls` ran before the UNKNOWN-TARGET check | posix | **resolved (milestone 2)**: checked first (`tm-unknown-host`) | low | 2 (done) | L (done) |
| main.tcl :61-64, native/native.tcl :46-47, :316 | doc text: executables are "Linux x86_64/glibc" (main.tcl is stale: aarch64 works too) | -- | **resolved (milestone 5)**: Linux glibc ELF and macOS AArch64 Mach-O | low | 6 (done) | L (done) |
| native/rawabi.tcl :8-9, :31-34 | a 64-bit two's complement word, tagged small Ints in [-2^62, 2^62-1] | arch | none: holds on arm64 | low | -- | L |
| core/process.tcl :9, :55-65 | the argument vector is NUL-terminated (Linux wording) | posix | none | low | -- | L |

### Who owns what at the target boundary

Since milestone 2:

- **The Botlish compiler owns** the target identity (core/cabi.tcl's table:
  name, OS, architecture, data model, triple), the C scalar type domains,
  import selection (architecture-specific files, the platform check),
  target compatibility (the HIR's recorded target, interchange's
  `-target`, the native driver's host check) and the target-sensitive cache
  identity (the full target in `surface::cache::Key`), and the choice of
  the C convention a foreign signature is built in (`c_call_conv`: the
  triple's).
- **Cranelift owns** what that convention means: Apple AArch64 call
  lowering, register assignment, stack argument placement, narrow-argument
  extension and the machine ABI generally; and, with the object crate, the
  object format a triple implies (Mach-O).
- **The runtime and the system toolchain own** platform execution (threads,
  stacks, guards), executable linking (Apple ld through rustc) and runtime
  stack handling. Milestone 2 changed none of them.

## 4. Cranelift, JIT and object generation

The code generator already lets Cranelift own the machine ABI: no calling
convention is hard-coded, the ISA comes from the host triple, and the
object format from the ISA. The macOS run confirms the JIT half.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| codegen/mod.rs `isa` (:147-165) | none: `cranelift_native::builder_with_options` = the host triple (AppleAarch64 call conv, Mach-O on macOS); no `--target`, no cross-compilation | owned | none. Host CPU features only for the JIT (`!pic`) | low | 3 | M (JIT done) |
| codegen/mod.rs :155-160 | stack probes (`enable_probestack`, inline) only when `native_stack_overflow_supported()`, i.e. Linux | linux | **resolved (milestone 4, MACOS-AARCH64-MILESTONE-4.md)**: the predicate includes macOS AArch64, so probes are on with the guard; large_frame_overflow.nir is `NATIVE LIMIT STACK` on the macOS runner. Cranelift's probe spacing of one 4 KiB page is within the 16 KiB guard | high | 4 (done) | M (done) |
| codegen/clif.rs `signature_n`, helpers, `c_signature`; codegen/target.rs `c_call_conv` | none: every signature is `module.make_signature()` = the ISA's default convention | owned | **made explicit (milestone 2)**: a foreign C signature's convention is selected where it is built, `c_call_conv(isa.triple())` = the triple's C convention (`apple_aarch64` for aarch64-apple-darwin, observed in CLIF on the macOS runner by native-status's `c-convention` probe); Botlish-to-Botlish and helper calls keep the ISA default (AppleAarch64 on macOS, unchanged) | low | 2 (done), 3 | M (done) |
| codegen/clif.rs `c_signature` (:199-229), `foreign_call` (:1019-1104) | narrow C arguments carry `sext`/`uext`; narrow results are re-extended by the caller | owned | Cranelift honours the extension attributes only for AppleAarch64 (`isa/aarch64/abi.rs` `get_ext_mode`), so they start to matter on macOS; its comment says sub-32-bit extension is "not implemented yet" -- test i8/i16 arguments against clang callees (tests/cffi/fixture.c `bcf_widen_*`) | high | 7 | M |
| codegen/clif.rs :171 | comment: "x86-64 SysV here has only two integer return registers"; the result-buffer rule is portable | arch | comment only | low | 3 | L |
| codegen/clif.rs :237, :92-123 | direct helper calls (R_X86_64_PLT32) only when the ISA is `x64` | arch | **verified (milestone 5)**: a Mach-O object calls the runtime helpers through the GOT (`ARM64_RELOC_GOT_LOAD_PAGE21`/`PAGEOFF12`, then `blr`) and Botlish functions directly (`ARM64_RELOC_BRANCH26`); Apple's ld resolves both | low | 6 (done) | M (done) |
| codegen/clif.rs :947-963, :256-262; mod.rs :353 | the context area is a Local data symbol addressed PC-relatively / through the GOT | owned | **verified (milestone 5)**: `_botlish_context_area` is a non-external `__DATA,__bss` symbol reached by a `GOT_LOAD` pair, and Apple's ld links it (tests/platform/aot-facts.tcl's program installs a context) | medium | 6 (done) | M (done) |
| codegen/mod.rs `compile_actual` (:170-246) | JIT symbols: every runtime helper registered by address (`builder.symbol`); foreign C symbols bound to `rt_ffi_unlinked` (abort); fallback `dlsym` for libcalls | posix | none for the JIT; works on macOS (section 1) | low | 3 | M (done) |
| cranelift-jit `SystemMemoryProvider` (memmap2 + region) | RW pages flipped to RX with `mprotect`, no `MAP_JIT`, no `pthread_jit_write_protect_np` | owned | works for the runner's ad-hoc-signed driver (section 1). A hardened-runtime or notarized driver would need the JIT entitlement or `MAP_JIT`: out of scope until packaging (milestone 10) | medium | 3, 10 | M |
| codegen/mod.rs `emit_object` (:334-350) | none: cranelift-object picks Mach-O from the triple, symbols get the Mach-O `_` prefix from the object crate, `LC_BUILD_VERSION` with platform macOS | owned | **verified (milestone 5)**: `Mach-O 64-bit object arm64` (`file`), `MH_SUBSECTIONS_VIA_SYMBOLS`, `LC_BUILD_VERSION` platform 1 minos 0.0 (no linker warning), `_botlish_fn_N`/`_botlish_entry_N` external text, `_rt_*` undefined (aot-facts.tcl, every smoke job). No unwind tables are written on either OS (`unwind_info` false; cranelift-object has no Mach-O `.eh_frame`) | medium | 6 (done) | M (done) |
| codegen/mod.rs `relax_context_got` (:372-392), `context_relocations` (:397-450); test :483-496 | an ELF64 parser rewriting R_X86_64_GOTPCREL to REX_GOTPCRELX for the context area | elf + arch | none: it returns early for non-ELF objects (a no-op on Mach-O, which keeps its GOT loads); the test is x86-64-only. Without the ELF check it would still find no section in a Mach-O object: an equivalent mutant, not in the campaign (MACOS-AARCH64-MILESTONE-5.md, section 20) | low | 6 (done) | L (done) |
| codegen/clif.rs :631 `stack_maps`, `define` (:327-403, :378 `below_fp`), roots.rs :845 | native-frame stack maps on x64 and aarch64 (by architecture, so on macOS too); aarch64 roots are FP-relative, a rationale observed on Linux prologues (:375-377) | arch | the FP-relative scheme does not depend on where a Rust helper's frame record sits, and macOS puts it elsewhere (section 1). Verified for 400 recursive allocating frames under GC stress (build400.nir, section 15); Tier C's GC-stress acceptance is the wide check | high | 4 | M (partly done) |
| codegen/roots.rs `plan` (:782-827, :788 `depth_reservation`) | the shadow-stack depth token is dropped only when native frames *and* the Linux guard are supported | linux | **resolved (milestone 4)**: dropped on macOS too, with the guard (MACOS-AARCH64-MILESTONE-4.md, "Shadow-stack depth token"); the token and the shadow array remain for hosts without a guard | medium | 4 (done) | M (done) |
| codegen/roots.rs :75, :94, :164, :775-777; clif.rs :559-566; framemap.rs :3 | comments: the stack-map path is "x86-64 only" | arch | stale comments (aarch64 is in the code) | low | 4 | L |

## 5. Executables, the driver, the stub linker and the single executable

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| codegen/aot.rs `emit_executable` (:188-203) | `cfg!(all(target_os = "linux", target_env = "gnu", ...))`, else "executable emission requires Linux glibc on x86_64 or aarch64" | linux | **resolved (milestone 5)**: `EXECUTABLES` admits `macos` + `aarch64`; the rustc linker only (the stub refuses: Linux x86-64); **since milestone 6** `C_CALLS` admits macOS AArch64 too (MACOS-AARCH64-MILESTONE-6.md) | medium | 6, 7 (done) | M (done) |
| codegen/aot.rs `link_rustc` (:241-296), startup crate (:63-180) | rustc links the program object with `-C link-arg=OBJ`, `-C force-frame-pointers=yes`, `-C relocation-model=pic`, no `--target`; the rlib beside the driver | owned | **verified unchanged (milestone 5)**: the same arguments; rustc runs `cc` (Apple clang), which runs Apple's ld; the startup crate's `extern "C"` names resolve to the object's `_`-prefixed symbols; the executable is `Mach-O 64-bit executable arm64`, PIE, linker-signed (ad hoc), loading only `/usr/lib/libSystem.B.dylib` and `/usr/lib/libiconv.2.dylib` (Rust's standard library's) | medium | 6 (done) | M (done) |
| codegen/aot.rs `link_plan_args` (:312-330), rationale :303-311, test :690-708 | `-Wl,--start-group`/`--end-group` and `-C default-linker-libraries=yes`, justified by GNU ld and glibc | linux | **resolved (milestone 6)**: `LinkerFlavor`, GNU ld's plan byte for byte on Linux, the bare `-L`/`-l` list on macOS (Apple's ld rejects the group and searches every archive anyway); the C driver's default libraries on both (on macOS: clang's compiler runtime) | medium | 7 (done) | M (done) |
| codegen/aot.rs `linker_diagnostics` (:224-239) | filters GNU ld/lld/collect2 wording ("undefined reference", "cannot find") | linux | **resolved (milestone 6)**: Apple ld's `Undefined symbols for architecture arm64:` and each symbol's `referenced from:` line, `ld: library 'NAME' not found`, the wrong-architecture warning, clang's `linker command failed` | low | 7 (done) | M (done) |
| main.rs `run_linked` (:352-432) | a program that calls C runs as a linked executable in a temp directory | posix | **verified (milestone 6)**: unchanged; a program that calls C runs this way on macOS on both native backends | low | 7 (done) | M (done) |
| codegen/aot.rs `link_stub` (:333-370), runtime/aotimage.rs `Image::load`/`map_near`/`main` (:477-612), codegen/aot.rs `image`/`read_object` (:372-667), bin/botlish-aot-stub.rs | the toolchain-free stub linker: an ELF64 x86-64 reader, x86 trampolines, 4 KiB pages, `MAP_FIXED_NOREPLACE`, `/proc/self/exe` | elf + arch + linux | none: macOS executables use the rustc linker (milestone 5), and the stub's refusal names Linux x86-64. A Mach-O arm64 stub would need a Mach-O reader, arm64 branch relocations and veneers, an icache flush, 16 KiB pages and code signing -- a Darwin toolchain inside Botlish, which the doctrine rules out | -- | -- | -- |
| single/build.sh, single/main.tcl :101-103, single/package.tcl | one Linux x86-64 glibc executable; forces the stub linker; static zipfs tclsh from source | linux + elf | out of scope (no macOS single executable in this port); package.tcl itself is portable Tcl | -- | 10 | -- |
| main.rs :99-103, runtime/aot.rs :38-45 | Botlish runs on a spawned thread with a 1 GiB stack (`BOTLISH_NATIVE_STACK_BYTES`, at least 1 MiB) | posix | accepted on macOS; **its bounds and guard are found since milestone 4** (libpthread's bounds, the guard confirmed below them) | low | 4 (done) | M (done) |
| main.rs :136-153 (`--result`), :143-144 `#[cfg(target_os = "linux")] set_result_fd` | the overflow report goes to the `--result` file through a Linux-only call; the gate is looser than the platform module's (Linux riscv64 would not compile) | linux | **resolved (milestone 4)**: `runtime::platform::set_result_fd`, under the platform module's own cfg (the three hosts with a guard) | low | 4 (done) | M (done) |
| main.rs exit statuses, `emit` (:104-131), runtime/aot.rs `driver_protocol` (:93-152) | none: driver protocol, result lines, exit status 0/1/2/3 | posix | none | low | -- | M (done) |
| runtime/aot.rs :5-9, main.rs :26-27 | doc text: "the real Linux argument vector", "128 KiB per-argument cap" | -- | **resolved (milestone 5)** for the argument vector (glibc's or libSystem's); the 128 KiB cap is Linux's and stays named as such | low | 6 (done) | L (done) |

## 6. Runtime: threads, stack bounds and overflow

**Resolved (milestone 4, MACOS-AARCH64-MILESTONE-4.md).** The guard Linux
had is now every guarded host's: `runtime/platform/guard.rs` (the handler,
the alternate signal stack, the published running stack), with each host's
stack discovery and thread naming in `platform/linux.rs` and
`platform/macos.rs`. A native stack overflow -- the worker thread's or a
coroutine's -- is `NATIVE LIMIT STACK` on the macOS runner. The table keeps
the original findings with their resolution.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/mod.rs :20-21, native_stack.rs :26-35 (`current`, `native_stack_overflow_supported`) | the platform layer exists for Linux only | linux | **resolved**: `platform/macos.rs` beside linux.rs, the shared guard in `platform/guard.rs`, one cfg for the three hosts; `native_stack_overflow_supported()` includes macOS AArch64 | medium | 4 (done) | M (done) |
| platform/linux.rs `current_stack` (:8-27) | `pthread_getattr_np` + `pthread_attr_getstack` + `pthread_attr_getguardsize`; glibc's guard directly below the reported stack | linux | **resolved**: `pthread_get_stackaddr_np` (the high end) and `pthread_get_stacksize_np`; the usable low bound is the first accessible address of the reported stack, the guard the run of inaccessible mappings below it, confirmed with `mach_vm_region`. Observed: a created thread's guard is one 16 KiB page directly below its stack (SIGBUS on a hit); the main thread's lowest reported page is itself inaccessible, the top of a 56 MiB inaccessible reservation (SIGSEGV on a hit) | high | 4 (done) | M (done) |
| platform/linux.rs `fault_handler` (:46-67), `OverflowGuard` (:81-143) | thread identity by `syscall(SYS_gettid)` in an `AtomicI32`; `sigaltstack` (64 KiB heap Vec), `sigaction` SIGSEGV+SIGBUS `SA_SIGINFO|SA_ONSTACK`, `si_addr`, `write` + `_exit`; unrelated faults re-raised with `SIG_DFL` | linux (tid) + posix (the rest) | **resolved**: the handler and guard moved to `platform/guard.rs`, shared; the thread token is the host's (`gettid` on Linux, `pthread_self` on macOS, both async-signal-safe); SIGSEGV and SIGBUS both handled (macOS raises SIGBUS for a created thread's or a coroutine's guard, SIGSEGV for the main thread's); the alternate stack is `max(SIGSTKSZ, 64 KiB)` (128 KiB on macOS); an unrelated fault goes to the previous disposition | high | 4 (done) | M (done) |
| vm.rs :242-248, :278-301 (non-Linux branches) | without the platform layer: `native_stack: None`, a 32 MiB shadow stack (4M slots) as the depth bound, `publish_active_stack` a no-op | linux | **resolved**: on macOS `native_stack` is the discovered stack, the shadow array is empty and publication is live | high | 4 (done) | M (done) |
| main.rs :563-567, runtime/aot.rs :52-56, :101-106 | the guard is installed for JIT runs and executables on Linux only | linux | **resolved**: installed at the same three points on the three hosts (`runtime::platform::OverflowGuard`) | medium | 4 (done) | M (done) |

## 7. GC roots and the frame walk

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/framewalk.rs `current_fp`, `root_address`, `walk_from` (:105-216) | the AAPCS64 frame-record chain (x29); aarch64 roots at `caller_fp - entry`; the walk bounded by `NativeStack` | arch | compiled, unit-tested and run under GC stress on macOS (sections 1 and 15). **Bounded since milestone 4**: the walk of the worker thread's stack reads the discovered bounds, as on Linux (a mutant halving them is killed under GC stress) | high | 4 (done) | M (done) |
| .cargo/config.toml | `-C force-frame-pointers=yes` for `x86_64-unknown-linux-gnu`, `x86_64-apple-darwin`, `aarch64-unknown-linux-gnu`; no `aarch64-apple-darwin` entry | owned | rustc keeps frame records in calling functions on this target by default (section 1); an explicit entry would also cover leaf functions and state the dependence: add it in milestone 4, with the GC-stress evidence | medium | 4 | M |
| framewalk.rs :205 | return addresses compared raw with code ranges | arch | correct for arm64 (no pointer authentication of return addresses); an arm64e build would need stripping | low | 4 | M |
| heap.rs `collect` (:118-249), vm.rs `collect_with` (:401-468), bytesobj.rs | a non-moving mark-sweep over Rust's global allocator; no mmap, no page size | posix | none | low | 4 | M |

## 8. Coroutines

**Resolved (milestone 3, MACOS-AARCH64-MILESTONE-3.md).** Native coroutines
run on macOS arm64 through both native backends. The refusal that section 15
recorded was a conservative guard (`CoStack::new` returned `Unsupported`
unless the host was Linux) over machinery that needed three adaptations: the
ELF-only switch text, `MAP_STACK` and the 4 KiB page assumption. The
coroutine model, ownership, GC walk and error handling are unchanged and
shared.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/coroutine.rs `CoStack::new`, `MAP_FLAGS`, Drop | `mmap(MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE|MAP_STACK)` + a 64 KiB `PROT_NONE` guard | linux | **resolved (milestone 3)**: Darwin has no `MAP_STACK` and `MAP_NORESERVE` is a no-op there, so a stack is `MAP_PRIVATE|MAP_ANONYMOUS`; guard and size are rounded to the host page size (`round_to_page`, 16 KiB on Apple Silicon). The pool, the guard and the `NativeStack` bounds are shared | medium | 3 (done) | M (done) |
| coroutine.rs `stack_bytes` | rounds `BOTLISH_NATIVE_COROUTINE_STACK_BYTES` to 4 KiB | arch + linux | **resolved**: `round_to_page` (`sysconf(_SC_PAGESIZE)`) | low | 3 (done) | M (done) |
| coroutine.rs switch assembly, `extern "C"` | `global_asm!` with ELF directives and bare labels | elf | **resolved**: the AArch64 instructions are one text (`aarch64_switch!`, `aarch64_trampoline!`) under two headers: ELF (`.type`/`.size`, `bl_co_switch`) and Mach-O (`_bl_co_switch`, no `.type`/`.size`). The Mach-O object was inspected: both symbols global, `bl` to `co_body` relocated. x18 is never touched; the frame record is the switch's first store; no store lies below sp | medium | 3 (done) | M (done) |
| coroutine.rs `prepare` | the initial FPCR is 0, "the Linux default" | arch | **resolved**: a unit test (`a_new_context_starts_with_the_threads_fpcr`) asserts a new thread's FPCR is 0, and it passes on the macOS runner | low | 3 (done) | M (done) |
| coroutine.rs non-Linux `new` | refuses: "implemented for x86-64 Linux only" | linux | **resolved**: the refusal remains for hosts without a switch (macOS x86-64, Windows) and now names the three supported ones | low | 3 (done) | M (done) |
| shadow-stack depth token (codegen/clif.rs `prologue_depth_token`, vm.rs `ss_top`) | none on Linux: its native overflow guard replaces the token | posix | **audited (milestone 3)**: on macOS every calling function bumps `ss_top` by one slot, zeroed, and restores the absolute value on exit. Coroutine segments interleave non-LIFO, but the slots only ever hold zeros (never roots: storage is `NativeFrame` for every function) and `ss_top` only takes values some frame once saw, so the interleaving cannot make the collector read stale data. The token does not bound a recursion by a coroutine's 8 MiB stack, though: that overflow is the guard page's. **Retired on macOS (milestone 4)**: the guard subsumes it there, as on Linux | medium | 3 (done), 4 (done) | M (done) |

## 9. Syscall transports, direct modules and contextual IO

Linux's raw syscall transport does not imply that macOS needs one. Darwin's
kernel interface is private and unstable; its stable interface is
libSystem. The macOS port's IO goes through C calls of libSystem (the C
FFI), behind the same portable `std::io::IO` context trait.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| runtime/syscall.rs transports (:66-139), stubs (:242-270) | `syscall` (x86-64) and `svc #0` with x8 (AArch64) for Linux only; elsewhere `NATIVE UNSUPPORTED "std::linux::abi::aarch64::syscall needs a Linux AArch64 target"` | linux | none: never port raw Darwin syscalls (x16, `svc #0x80`). The refusal is the right macOS behavior (verified, section 15) | low | 9 | M (refusal verified) |
| stdlib/linux.bot, stdlib/linux/sys.{x86_64,aarch64}.bot, stdlib/linux/io.bot, stdlib/linux/path.bot | the `linux` namespace and `std::linux::io::LinuxIO`, the only `std::io::IO` implementation | linux | **done (milestone 8)**: stdlib/darwin.bot (libSystem's write, read, open, close, `__error` as `extern c fn`), stdlib/darwin/io.bot (`DarwinIO`, implementing `std::io::IO`), stdlib/darwin/path.bot; `darwin` designated the macOS platform's; `stdlib/io.bot` unchanged | medium | 9 (done) | M (done) |
| hir/direct.tcl, core/native.tcl `declareDirectNamespace` (:319-332) | the transport namespaces are the designated direct intrinsics | posix | none: a libSystem module is direct because its retaining C calls are (C-FFI.md, section 9) | low | 9 | L |
| ops.rs `rt_bytes_addr`, `rt_mbytes_addr` and their comment | payload addresses as small Ints; "47-bit Linux x86-64 user space" | posix | **done (milestone 7)**: the check is portable (payload addresses above 4 GiB pass exactly, `bb-read-address-above-4gib`); the comment states every host's bound | low | 8 (done) | M (done) |

## 10. C FFI

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| core/cabi.tcl `macos-aarch64` row; hir/cabi.tcl `NamespaceTypeDecls` | plain char signed, LP64 | -- | none: verified per scalar (section 1); a HIR built with it records `macos-aarch64` and keeps its facts through interchange and the cache (milestone 2) | low | 2 (done) | M (done) |
| native/lower.tcl :1608-1619 (NIR `foreign N "symbol"`), clif.rs `foreign_call` | a bare C symbol name | owned | **verified (milestone 6)**: the object crate adds Mach-O's `_`; `named` symbols, libSystem's `labs` (imported "from libSystem", `nm -m`) and the fixture's resolve (`cf-named-symbol`, `cf-system-symbol-resolved`) | low | 7 (done) | M (done) |
| value.rs :32-43, :430-452 (`cptr`), ffi.rs `rt_ffi_bad_address` | a C address is a sign-extended 60-bit word; a top-byte-tagged pointer fails `NATIVE ADDRESS` | arch | **verified (milestone 6)**: C's static addresses (above 4 GiB), the top of user space and an all-high-bits address round-trip; `0xf000000000000010` is `NATIVE ADDRESS` (`cf-pointer-width`, `cf-pointer-mix`, `cf-wild-address`) | medium | 7 (done) | M (done) |
| codegen/clif.rs `c_signature`; nir.rs `ForeignDecl` (no parameter-count limit) | stack-passed C arguments follow the platform ABI | owned | **resolved (milestone 6)**: Cranelift packs Apple's stack arguments at their natural size, but 0.135.2 stores an *extended* narrow stack argument at register width, past its slot; `c_signature` declares Apple's stack-passed narrow parameters unextended (`target::c_extended_parameters`; fixed upstream in 0.136.0). Checked against Apple clang's own calls (`cf-abi-*`) | high | 7 (done) | M (done) |
| native/lower.tcl `BorrowCall`, `ExposeStorage`/`KeepExposedAlive` | byte exposure, private write copies, keepalive | posix | **verified (milestone 7)**: no change; read and write exposures through Apple clang's fixture and libSystem, sizes to 1 MiB, GC stress, coroutines, Guard Malloc (tests/c-byte-borrowing.test) | low | 8 (done) | M (done) |
| tests/cffi/fixture.c :124-154, :180-202 (`bcf_dirty_*` and the other assembly) | inline assembly with ELF directives and bare labels | elf + test | **resolved (milestone 6)**: one AArch64 text, `BCF_FUNCTION` spelling its header for ELF or Mach-O | low | 7 (done) | M (done) |
| tests/c-ffi.test :25-26 `linuxNative`, :36-50 (fixture build: `cc -c -O2 -fPIC`, `ar rcs`) | the fixture is built on Linux only | test | **resolved (milestone 6)**: `nativeCCalls` (tests/helpers.tcl); the fixture builds with Apple clang (`cf-fixture-built`) | low | 7 (done) | M (done) |
| tests/c-ffi.test `cf-scalar-transport`; audit/c-ffi/tools/fuzz.tcl | plain char unsigned when `tcl_platform(machine)` is `aarch64` *or* `arm64` | test | **resolved (milestone 2)**: unsigned on Linux AArch64 only, read from the OS and the architecture (the fuzzer keeps its own model, independent of the registry, as its design requires); both run on macOS since C calls do (milestone 6) | low | 2 (done) | L (done) |
| tests/c-ffi.test `tclLinkable` (:55), examples/ffi/tcl/tcl.bot :17 | `-ltcl9.0` (Debian's library name, on the default library path) | test | the CI's Tcl 9.0.1 build installs `libtcl9.0.dylib` under `~/.cache/botlish/tcl-9.0.1/lib`: link it with `-L`, verify | low | 10 | M |
| examples/ffi/sha256/boringssl.bot :23 | `extern c library "stdc++"` (GNU libstdc++) | linux | macOS links `c++` (libc++): a per-OS library list is a language question (C-FFI.md has no conditional `extern c library`) | medium | 10 | M |
| tests/c-ffi.test `cf-missing-library` (:529), `cf-sha256-executable` (:732-739, `ldd`) | GNU ld wording; `ldd` | test | **resolved (milestone 6)**: either linker's wording; `otool -L` on macOS | low | 7 (done) | M (done) |
| tests/c-bindgen.test, tools/c-bindgen (new on main during this milestone) | the fixture's committed manifests, checked byte for byte, record the clang that generated them (`toolchain_version {Ubuntu clang version 18.1.3 (1ubuntu1)}`) | test | **resolved (milestone 6)**: `cb-fixture-current` compares a generation by another clang with the recorded provenance (version string, token count) put back, every other byte still compared; the committed Linux manifests stay Ubuntu clang's. The generator's `check` command stays byte for byte | low | 7 (done) | M (done) |

## 11. Tests and the test harness

The harness assumes the native backend is built and native code runs:
there is no skip for an unbuilt or unsupported native backend, and most
native tests carry no host constraint at all.

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| per-file constraints `nativeLinux`, `executableAot`, `nativeStackGuard` (`os eq "Linux" && machine in {x86_64 amd64 aarch64}`; 22, 36 and 1 files) | false on macOS (os, and machine `arm64` is not in the list): 117 + 131 + 4 tests skip there (the census) | test | as each capability lands, widen its constraint by capability, not by OS name; keep the definitions in step (they are copied per file). `nativeCoroutines` (milestone 3), `nativeStackGuard` (milestone 4), `executableAot` (milestone 5: 38 files' copies replaced by one definition) and `nativeCCalls` (milestone 6: c-ffi.test's `linuxNative`, c-bindgen.test's `nativeRun`, the C oracles of native-view, native-edit and layout-arrays) are now capabilities defined once in tests/helpers.tcl | medium | 3-9 | L |
| `linuxX86_64` (7 files), `linuxAarch64`, `stubLinker` (3 files), `x86_64Host` (native.test :779, no OS check) | instruction-set/syscall-ABI and ELF tests | test | none: correct to skip on macOS; `x86_64Host` should also require Linux (it reads ELF with `readelf`) | low | 3 | L |
| tests/helpers.tcl `outcomeUnder`/`outcomeUnderHir` (:234-278), `sourceAgree` (:293-302); 97 files with four-backend lists | a differential test runs every backend, cranelift included, unconditionally | test | on macOS these tests run natively and pass or fail on real behavior (section 15): the right signal | -- | 3 | M |
| tests/helpers.tcl `linuxTarget`, `backendsFor`; 13 test files' compile helpers | (milestone 2) a test that compiles a Linux program used the host's default target | test | such a test compiles for `linuxTarget` (the host's own on Linux, so Linux runs exactly as before; `linux-aarch64` on macOS) and runs it on `backendsFor` its HIR's target (the Tcl backends on macOS); a native leg that needs the Linux runtime carries `nativeLinux` | -- | 2 (done) | M (done) |
| tests/native-stack-overflow.test :8 | `native::binary` at top level: the file errors without a driver | test | **resolved (milestone 4)**: its tests carry the capability `nativeStackGuard` (tests/helpers.tcl: linux-x86_64, linux-aarch64, macos-aarch64) and call the driver in their bodies | low | 4 (done) | M (done) |
| tests/native-stack-map.test :126, :132, native-root-storage.test :180, native.test :798 | expect "no depth helper" on Linux x86-64/aarch64 and the depth helper elsewhere | test | **resolved (milestone 4)**: the expectation follows `nativeStackGuard` (native.test :798 is x86-64 ELF only and keeps its own) | low | 4 (done) | M (done) |
| tests/golden/run.tcl `hosts`, `onHost`, `target` | golden hosts are `linux-x86_64`, `linux-aarch64`; `onHost` requires Linux | test | since milestone 2 a suite importing a Linux namespace (16 suites) is a Linux program: on macOS run.tcl compiles it for `linux-aarch64` (`golden::target`) and runs it on the Tcl backends, its native backends excluded with the reason. Add `macos-aarch64` to the hosts when a suite needs it | low | 9 | L |
| tests/golden.test :32-39, tests/workload-2048.test :32-36 | drop the native backends off Linux | test | widen with milestone 3/4 | low | 3 | M |
| tests/local.tcl `processors` (:50-53), :127-129 | `exec nproc` (falls back to 4: macOS has no `nproc`); `LANG=C.utf8` forced | test | `sysctl -n hw.ncpu` on Darwin; the locale is harmless | low | 10 | M |
| objdump `-M intel`, `readelf`, `strace`, `ldd`, `/proc/$pid/maps`, `\x7fELF` (abi-bytes, linux-syscall, contexts, native.test :792, aot-stub-linker :240, native-executable :33, portable-io) | GNU/Linux tools and ELF | test | none: those tests are Linux-constrained or tool-constrained already; native-executable.test's `\x7fELF` became the host's format (tests/binary-header.tcl: ELF or Mach-O; milestone 5) | low | 6 (done) | L |
| tests/argv.test :821-828 | argc == 0 (Linux >= 5.18 behaviour) | test | constrained by `pythonLauncher`; recheck with executables | low | 6 | M |

## 12. Packaging, audit tools and benchmarks

| Where | Linux assumption | Class | macOS adaptation | Risk | M | Check |
|---|---|---|---|---|---|---|
| .devcontainer/setup.sh | apt, `dpkg --print-architecture`, the Tcl 9.0.1 `.deb`s | linux | tests/platform/setup-macos.sh is macOS's: the same Tcl 9.0.1, built from single/build.sh's pinned source (no 9.0.1 package exists for macOS; Homebrew's 9.0.4 changes Unicode case mapping) | -- | 1 (done) | -- |
| .github/actions/build-native | cache keyed by `runner.os` and `runner.arch` | -- | none: reused unchanged on macOS | -- | 1 (done) | M (done) |
| audit/*/tools/mutate.tcl, audit/golden/tools/tree.tcl :151, :244 | `exec timeout` (GNU coreutils; tree.tcl :244 is used by check.tcl) | linux | macOS has no `timeout`: guard or replace before running the mutation harnesses or check.tcl there | low | 10 | M |
| audit/2048/mutate.tcl :23 | `exec nproc` without a fallback | linux | as tests/local.tcl | low | 10 | M |
| audit tools (`raw-int-abi/tools/asm.tcl`, `traits/tools/evidence.tcl`, ...), native/generate-scalar-audit.tcl | `objdump -dr -M intel`, `R_X86_64_*` | arch + elf | x86-64 Linux evidence tools; leave them | -- | -- | -- |
| bench/golden-suites.tcl :98-101, bench/phase-profile.tcl :198-199, bench/coroutines.tcl :270-273, :296 | `/proc/self/status` VmHWM (coroutines.tcl without a fallback); `ru_maxrss` (bytes on macOS, KiB on Linux) | linux | per-OS memory measurement when benchmarks run on macOS | low | 10 | M |
| fuzz/scripts/*.sh | AFL, qemu, `/proc/sys/kernel/core_pattern` | linux | out of scope | -- | -- | -- |

## 13. Already portable: reuse unchanged

- **Cranelift owns the machine ABI.** No calling convention is spelled in
  native/: the host triple gives AppleAarch64, the object format Mach-O,
  the symbol prefix `_`. Do not add a `CallConv` or a symbol-mangling rule.
- **The C ABI target model** (core/cabi.tcl, hir/cabi.tcl): the
  `macos-aarch64` row is right, and the cache key already holds the full
  target. Do not invent a second target representation: the table's rows
  (with their triples, milestone 2) are the one, and the native driver
  reads the triple.
- **The NIR and native lowering** (native/lower.tcl, nir.rs) know no OS:
  only the syscall ops name Linux, and they compile everywhere.
- **The runtime's value model, heap and collector** (value.rs, heap.rs,
  vm.rs, bytesobj.rs, strobj.rs, ops.rs): 215 unit tests pass on macOS.
- **The frame walker** is per architecture, not per OS, and runs on macOS.
- **The driver protocol** (main.rs, native/native.tcl's `RunDriver`,
  `--result`, output inheritance) is std-only.
- **The rustc linker path** (codegen/aot.rs `link_rustc`): rustc drives
  the platform linker, so Mach-O executables need no Botlish linker.
- **Byte borrowing** (hir/borrow.tcl, `BorrowCall`) is OS-neutral.
- **`stdlib/io.bot`'s `std::io::IO` context trait** is the portable IO surface;
  macOS adds an implementation, not a new abstraction.
- **CI plumbing**: `.github/actions/build-native` works on macOS as is.

## 14. Boundaries where a broad change would regress Linux

- **`cfg(target_os = "linux")` gates.** Widening one to `unix` would pull
  glibc-only calls (`pthread_getattr_np`, `SYS_gettid`, `MAP_STACK`,
  `MAP_FIXED_NOREPLACE`) into macOS builds, which then fail to compile --
  or, worse, an `#[cfg(not(...))]` fallback silently becomes Linux's. Add
  a macOS branch beside each Linux one; leave the Linux branch's text
  alone.
- **The syscall transport table and `std::linux::sys` selection.** Giving the
  `aarch64` row an OS-dependent meaning would change Linux AArch64's
  module and transport. An OS dimension must leave every Linux lookup's
  result unchanged (tests/linux-syscall-transports.test pins them).
  Milestone 2 added it at the import (the platform check) and left the
  table and ModuleFile alone: every Linux target resolves exactly as
  before.
- **The link plan.** GNU ld needs `--start-group` and the default linker
  libraries (the BoringSSL AArch64 fix of C-FFI.md, section 11). Apple ld
  needs neither: split by OS, never "simplify" Linux's.
- **Stack probes and the depth token.** They are tied to
  `native_stack_overflow_supported()`. Turning that on for macOS before
  the macOS guard and bounds exist drops the depth token (roots.rs :788)
  and leaves recursion unbounded. Change the predicate only with the
  guard.
- **The AArch64 frame layout.** The walker's FP-relative roots
  (clif.rs `define`, framewalk.rs `root_address`) serve Linux AArch64 too.
  A macOS-motivated change to them must keep the arm64 CI's GC-stress run
  green.
- **Test constraints.** Most native tests have no host constraint. A
  macOS-motivated skip must name a capability, never `os ne "Darwin"`,
  so Linux keeps every test.
- **The golden manifest.** A new `tests/*.test` file needs a census row
  and a regenerated manifest (AGENTS.md, "Golden tests"); the macOS
  scripts in tests/platform/ are deliberately not `.test` files.

## 15. The macOS census

**Update (milestone 3).** The 14 files below that fail on native coroutines
pass on macOS since milestone 3, and every golden suite runs natively
there (the Linux programs excepted, as in milestone 2): the census
(`CI-Tests: all`, run 39161417599) fails only on `c-bindgen.test` and
`c-ffi.test`, milestone 7's. The tables that follow are the milestone 1
census as it was; MACOS-AARCH64-MILESTONE-3.md has the new numbers, and
`native-status.tcl` records the coroutine probe as a value.

**Update (milestone 5).** Executables are no longer refused on macOS: the
`executableAot` tests (131 skipped in the census below) run there, in the
acceptance tier, with one capability defined in tests/helpers.tcl, and
native-status records the Mach-O executable's header and value and a
program object's header (MACOS-AARCH64-MILESTONE-5.md). A C call is still
refused, now with its own reason (NATIVE LINK, "C calls are linked on Linux
glibc only"), and c-ffi.test stays in `notYet`.

**Update (milestone 6).** C calls are no longer refused on macOS:
c-ffi.test and c-bindgen.test run in the acceptance tier, so `notYet` is
empty and the acceptance tier is every Tcl test file and every golden
suite. Inside the two files, what still skips on the runner is what skips
on any host without it: the Tcl, BoringSSL, SDL3 and MinGW libraries and
sources, the committed Linux bindings' checks, and x86-64's
`cf-bool-register` (MACOS-AARCH64-MILESTONE-6.md, sections 21 and 30).
native-status records the `c-call` probe as its value, `5`.

**Update (milestone 7).** The 18 runtime tests of the borrowing and layout
files whose `nativeLinux` predated the port (c-pointer-borrowing 4,
native-view, native-edit, layout-arrays, layout-unions, binary-layout 2
each, abi-mutable-bytes 4) carry the capability they need and run on macOS,
and tests/c-byte-borrowing.test (20 tests: real C, libSystem's byte
functions, Guard Malloc) runs there; abi-bytes' and abi-mutable-bytes'
remaining 35 `nativeLinux` tests are Linux's syscall layer
(MACOS-AARCH64-MILESTONE-7.md, section 1). native-status records
`c-byte-borrow`.

**Update (milestone 8).** tests/darwin-io.test (27 tests) runs on macOS:
its 14 `darwinIO` tests are Darwin IO through libSystem, its other 13 run on
every host. portable-io's and context-traits' `nativeLinux` tests stay
Linux's (LinuxIO); their macOS counterparts are darwin-io's. native-status
records `darwin-read-write`, `darwin-errno`, `darwin-io` and
`darwin-executable` (MACOS-AARCH64-MILESTONE-8.md).

**Update (milestone 4).** The native stack overflow rows below are history:
since milestone 4 a native overflow of the worker thread's stack or of a
coroutine's is `NATIVE LIMIT STACK` on macOS (MACOS-AARCH64-MILESTONE-4.md
has the before and after), and `native-status.tcl` records both probes as
that error. No native capability crashes the driver any more.

What the repository's own tests do on a `macos-15` runner with the native
backend built: run 2 of the workflow (at aac30aa, before main's later
merge), every `tests/*.test` file on interp in three shards (`tests/all.tcl
-file`), every golden suite on all four backends, and probes of the native
runtime; then the files that failed, rerun alone with `[ci-full]` and
`CI-Tests:` (runs 4 and 5) to read their causes. `tclsh9.0
tests/platform/tier.tcl all` (`[ci-full]` with `CI-Tests: all`) reproduces
it.

The census ran under Homebrew's Tcl 9.0.4; the rerun of run 5 under the
repository's baseline Tcl 9.0.1, which the CI uses since (section 16).
That difference turned out to matter (below, "The Tcl version").

**Tcl test files** (interp; the test files run every program on the
native backends too, whatever CORE_BACKEND says):

| Shard | Files | Passed | Failed | Skipped | Wall |
|---|---:|---:|---:|---:|---:|
| 1/3 | 62 | 2459 | 9 | 138 | 601 s |
| 2/3 | 63 | 2565 | 25 | 120 | 568 s |
| 3/3 | 63 | 2375 | 89 | 94 | 426 s |
| **all** | **188** | **7399** | **123** | **352** | |

Under Tcl 9.0.4, 171 of the 188 files passed. The skips are the Linux
host constraints of section 11 (`executableAot` 131, `nativeLinux` 117, `linuxX86_64` 45,
`cfFixture` 40, `stubLinker` 7, `nativeStackGuard` 4, `linuxAarch64` 2,
`boringssl` 2, and single ones: `readelf`, `rustcAvailable`,
`singleExecutable`, `tclLibrary`). The 17 files with failures, their
causes and owners -- tests/platform/tier.tcl's `notYet` holds the first
15 (and c-bindgen.test, below), which the acceptance tier leaves out:

| File | Failed (interp) | Cause | Milestone |
|---|---:|---|---|
| affine.test | 31 | native coroutines: the coroutine handle is the primitive affine value | 4 |
| branch-form-boolean.test | 3 | native coroutines | 4 |
| c-abi-types.test | 1 (`ca-affine-coroutines`) | native coroutines | 4 |
| c-ffi.test | 1 (`cf-missing-library`) | a C call's link is refused before the linker runs, so the linker's words for a missing library never appear | 6, 7 |
| compilation-isolation.test | 3 | native coroutines (one is a golden suite: the golden runner is a coroutine) | 4 |
| coroutines.test | 39 | native coroutines | 4 |
| enums.test | 1 (`enum-coroutine-events`) | native coroutines | 4 |
| error-payloads.test | 8 | native coroutines (affine payloads) | 4 |
| hir-interchange.test | 5 | native coroutines (its sample program has one) | 4 |
| mutable-array.test | 6 | native coroutines (affine elements) | 4 |
| mutable-vector.test | 11 | native coroutines (affine elements, consuming loops) | 4 |
| namespaced-errors.test | 2 | native coroutines | 4 |
| native-listloop.test | 1 | native coroutines | 4 |
| static-compile.test | 2 | native coroutines | 4 |
| structural-contract-completions.test | 3 | native coroutines | 4 |
| argv.test | 1 (`argv-focused-valid-fuzz`) | Tcl 9.0.4 (below); passes with 9.0.1 (run 5) | -- |
| native-tcl-unicode.test | 5 | Tcl 9.0.4 (below); passes with 9.0.1 (run 5) | -- |

With the baseline Tcl, then, 173 of the 188 files pass, and every one of
the 15 that does not fails on a capability the port has not reached yet:
14 on native coroutines, which every native run of an affine value
needs, and one on C linking. With the two files main added since,
c-bindgen.test (next paragraph, in `notYet`) and diagnostic-recovery.test
(passes), 174 of 190 (run 7).

**Milestone 2's census** (run 39128806972, `CI-Tests: all`, at 20957e9)
found the same failures file by file, but for one Linux-importing test in a
`notYet` file that the milestone then fixed (static-compile.test's
`sc-tx-context`; MACOS-AARCH64-MILESTONE-2.md, section 11). The golden
suites that import a Linux namespace now compile for linux-aarch64 on macOS
and run on the Tcl backends only.

**A file main added during the milestone.** tests/c-bindgen.test (the C
binding generator, C-BINDGEN.md) arrived with the merge of main and failed
two tests on macOS in the acceptance tier (run 6).
`cb-fixture-current` checks the fixture's committed bindings byte for byte
against a fresh generation: under Apple clang the generated modules, shim
and reports were identical and only every target's `manifest.txt` differed.
A manifest records the clang that generated it (`toolchain_version
{Ubuntu clang version 18.1.3 (1ubuntu1)}`, and the `evidence` line), so the
check passes under that clang only: a toolchain pin, which a Linux host
with another clang would meet too. (The test prints only which files
changed; whether other lines, such as the preprocessed token count, differ
as well is not verified.) `cb-fixture-no-c-at-compile-time` expected 32 foreign declarations,
linux-x86_64's count, of the host target's binding; an AArch64 target's
declares 33 (`bgf_arm_only`, and macOS's `bgf_apple_only` in place of
`bgf_linux_only`), and main fixed it during this milestone (a96c898,
which found it on Linux arm64). Whether the check should compare the
toolchain lines is the generator's decision; milestone 7, which brings C
to macOS, takes it. tier.tcl's `notYet` records the file until then, so
the acceptance tier leaves it out.

**The Tcl version.** Botlish's `std::str::lowercase` is the Unicode 16 simple
mapping on every backend (README.md, "Strings"). The native runtime pins
it (`rt_str_lower` leaves the Unicode 17 additions alone: U+A7CE, U+A7D2,
U+A7D4, Beria Erfe U+16EA0..U+16EB8), and the Tcl backends inherit Tcl's
tables, which are Unicode 16 in the baseline 9.0.1. Homebrew's Tcl 9.0.4
has Unicode 17 tables, so under it the interpreter and the Tcl compiler
lowercase those capitals and disagree with native code: five tests of
native-tcl-unicode.test, four of the golden unicode-strings.bot and one
iteration of argv.test's fuzz, whose differential uppercases random
multi-byte arguments. All of them pass under 9.0.1. The deviation is the
reference implementation's, not macOS's: Linux with any Tcl newer than the
pin would show it too. It is why the CI builds Tcl 9.0.1 from source on
macOS rather than taking Homebrew's.

**Golden suites.** Every suite passes on interp and compile (under Tcl
9.0.4 all but `unicode-strings.bot`, 4 of whose 56 tests failed; under
9.0.1 it passes, run 5). On both
native backends every suite aborts with `native coroutines need stack
switching, implemented for x86-64 Linux only (COROUTINES.md) (NATIVE
UNSUPPORTED value)`: the golden runner, `stdlib/test.bot`, is itself a
coroutine, so no native golden run is possible before milestone 4. The
two `golden-host: linux-x86_64` suites are compiled and not run, as
designed. (The second golden shard was cancelled by a later push before
it finished; its suites ran on interp and compile in the acceptance
tier of run 4.)

**Native runtime probes** (botlish-native and main.tcl, run 2):

| Probe | Outcome on macOS arm64 | Meaning |
|---|---|---|
| fib.nir, loop-count.nir (driver) | values | the JIT runs NIR |
| build400.nir under `BOTLISH_NATIVE_GC_STRESS=1` | value (400 live recursive allocating frames) | the frame walk finds every root under stress |
| stack_overflow.ir, 4 MiB stack | `thread '<unknown>' has overflowed its stack` / `fatal runtime error: stack overflow, aborting`, SIGABRT | **no Botlish guard**: Rust's own guard-page handler aborts the process |
| large_frame_overflow.nir, 4 MiB stack | the same Rust abort | no stack probes either |
| stack_overflow.ir, default 1 GiB stack | `NATIVE LIMIT STACK` | the shadow depth token (4M frames) is reached before the native stack ends -- for these tiny frames |
| deep recursion (`depth(n - 1)`, 10^8 deep) on cranelift, 1 GiB | **`child killed: segmentation violation` (NATIVE BUG)** | the native stack ran out before the depth token, and the fault escaped Rust's handler too |
| the same with a 64 MiB stack | Rust's stack-overflow abort (NATIVE BUG) | |
| a coroutine program on cranelift | `native coroutines need stack switching, implemented for x86-64 Linux only (COROUTINES.md) (NATIVE UNSUPPORTED value)` | an explicit refusal (stale text: AArch64 Linux works too) |
| examples/io/hello.bot, examples/linux/write.bot on cranelift | `std::linux::abi::aarch64::syscall needs a Linux AArch64 target (NATIVE UNSUPPORTED value)` | an explicit refusal; note the program compiled, with `stdlib/linux/sys.aarch64.bot` chosen for the macOS target (section 3). **Since milestone 2** it does not compile for `macos-aarch64`: `namespace "std::linux" belongs to the Linux platform ... (SURFACE MODULE UNSUPPORTED-PLATFORM)`; compiled with `-target linux-aarch64` it is refused natively (NATIVE TARGET) |
| examples/ffi/tcl/tcl.bot on cranelift | `executable emission requires Linux glibc on x86_64 or aarch64 (NATIVE LINK)` | an explicit refusal |
| `-emit-native-executable` | the same text, `(NATIVE AOT)` | an explicit refusal |
| the stdlib examples on cranelift | values | |
| `native::object` | `Mach-O 64-bit object arm64`; `_botlish_fn_N`, `_botlish_entry_N` defined, `_rt_*` undefined; `LC_BUILD_VERSION` platform 1 (macOS), minos 0.0 | Cranelift writes a Mach-O object; minos 0.0 is to check against Apple ld at link time (milestone 6) |
| `cargo test --release` (every target) | passes | |
| `cargo test --release` under GC stress | **one failure**: `runtime::ops::tests::bytes_from_list_copies_every_byte_exactly_including_nul_and_high_bytes` | a test bug (below) |
| `codesign -dv botlish-native` | `flags=0x20002(adhoc,linker-signed)` | the linker's ad-hoc signature, under which the JIT's mprotect works |
| botlish-aot-stub | `botlish-aot-stub runs on x86-64 Linux only (NATIVE STARTUP)`, exit 1 | as designed |
| `ulimit -s` | 8176 (KiB) | the main thread's; Botlish runs on its own 1 GiB thread |

**The GC-stress unit-test failure is a test bug every platform has.**
`rt_bytes_from_list` copies the list's bytes, then allocates the storage
(native/src/runtime/ops.rs): correct. The unit test holds the list `l`
only in a Rust local, unrooted; under GC stress the allocation collects
it, and macOS's allocator hands the freed block straight back, so
`assert_ne!(b, l)` fails. glibc's allocator does not reuse that block, so
Linux passes by luck. The fix (root `l` in the test, `Vm::temp_roots`)
belongs to milestone 4 with the rest of macOS GC-stress validation.

**What the native status check records** (tests/platform/native-status.tcl,
every smoke run): on `macos-aarch64` the JIT and the GC frame walk under
stress give their values; the stack overflow is the Rust abort (the one
recorded crash, kept so milestone 5 must change it); coroutines and
executables are their refusals above; a C call is `NATIVE LINK` with the
executable-emission refusal. On Linux every one gives its value. Since
milestone 2 the Linux syscall probe is a compile-time refusal on macOS
(UNSUPPORTED-PLATFORM), and three probes record the target boundary on
every host: the driver's reading of the host triple (`format macho
c-call-conv apple_aarch64 runs 1` on macOS, `elf system_v` on Linux), the
convention of a foreign C signature in CLIF (`apple_aarch64` on macOS) and
a program built for the other OS's target of the host's architecture
(NATIVE TARGET: linux-aarch64 code is never run on macOS arm64, macOS code
never on Linux).

**No native code produced a wrong value.** Every native capability either
works, refuses with a stated error, or -- the native stack overflow --
crashes the driver, which main.tcl reports as `NATIVE BUG`. The only wrong
values the census found were the Tcl backends' under Tcl 9.0.4 (above), a
property of that Tcl, not of macOS.

## 16. CI and test tiers

How an agent that develops on Linux (or on a Mac of its own) gets real
Apple Silicon results. Nothing here needs a shared development Mac, a
secret or a self-hosted runner.

### The workflow

`.github/workflows/macos-arm64.yml`, "tests (macos arm64)":

| Job | Tier | Runner | What | Typical time |
|---|---|---|---|---|
| `smoke` | A | `macos-15` | host facts (fails unless `Darwin`/`arm64`, not Rosetta); `tests/platform/toolchain-smoke.sh`; `.github/actions/setup-macos` (tests/platform/setup-macos.sh: Tcl 9.0.1 from source, cached; stable Rust); `tests/platform/cabi-facts.tcl`; the native build (`.github/actions/build-native`, cached); `cargo test --lib`; `cargo test --test native_stack` (the stack facts and the guard, in child processes; since milestone 4); `tests/platform/native-status.tcl`; `tests/platform/aot-facts.tcl` (a program object and an executable as the host's tools see them, the standalone runs; since milestone 5); `tier.tcl smoke` | 1 min 18 s with warm caches (run 4); about 3 min more for the one-time Tcl build |
| `acceptance` (2 shards) | B | `macos-15` | `tier.tcl -shard I/2 -backends interp acceptance` | 20 and 27 min (run 4), 23 and 17 (run 7) |
| `linux-control` | A | `ubuntu-latest` | the smoke commands on Linux x86-64 at the same commit | 1-4 min |
| `full` (3 shards) | C | `macos-15` | opt-in (below) | 4-5 min for a dozen named files (runs 4 and 5); 4 s for a shard with nothing to run; the default payload was not run in milestone 1 |

- **Triggers:** `push` to any branch (so a feature branch is tested before
  the workflow is on main), `pull_request` (a same-repository pull request
  skips every job: its push already ran; a fork's runs), and
  `workflow_dispatch` (only once the file is on main). Pushes and pull
  requests that change only `*.md` files do not run it.
- **Concurrency:** one run per branch; a newer push cancels the running one
  (not on main). So do not push to a branch while you wait for a long run
  on it: the push cancels it.
- **No macOS job waits for a Linux runner.** (An earlier version planned
  the tiers in an ubuntu job; it sat in the queue behind main's Linux
  workflows, which share the account's concurrent-job limit with this
  one.) At most five macOS jobs ran at once (run 2's sixth waited):
  smoke and acceptance are three, a full run three more.
- **The runner label** is `macos-15`, written in the smoke, acceptance and
  full jobs. It is an Apple Silicon image (`macos-15-arm64`); the smoke
  job's host step fails on anything else, so a wrong label cannot pass
  silently.

### The tiers and their commands

The same commands run locally wherever their host requirements hold; the
workflow only adds the macOS host.

**Tier A, development smoke** (seconds, locally and in CI):

```sh
tests/platform/toolchain-smoke.sh            # the host's C and Rust toolchains, not Botlish
tclsh9.0 tests/platform/cabi-facts.tcl       # core::cabi's host row against the C compiler
tclsh9.0 tests/platform/native-status.tcl    # each native capability as recorded for this host
tclsh9.0 tests/platform/aot-facts.tcl        # the object and the executable, with the host's tools
tclsh9.0 tests/platform/tier.tcl smoke       # the sample programs and a dozen front-end test files
tclsh9.0 tests/platform/tier.tcl X.test Y.bot   # any test file or golden suite, as CI runs it
CORE_BACKEND=interp tclsh9.0 tests/X.test    # one file directly (exits 0 even on failures: read it)
cargo test --release --manifest-path native/Cargo.toml --lib NAME   # one Rust test
```

**Tier B, CI acceptance** (every push): `tier.tcl acceptance` -- every
Tcl test file except `notYet`'s, and every golden suite on interp and
compile. CI runs it on interp only (`-backends interp`) in two shards,
40 to 47 minutes of macOS runner time together (runs 7 and 4); the default
`-backends interp,compile` of a local run doubles the Tcl test files'
share.

**Tier C, exhaustive, opt-in.** The default payload is the acceptance tier
on both Tcl backends under `BOTLISH_NATIVE_GC_STRESS=1`, in three shards.
Named items replace it -- test files, golden suites and tier.tcl's check
items (since milestone 6 also `c-ffi-fuzz`, `c-ffi-mutants[=NAMES]` and
`c-ffi-bench`); `all` is the census (every file, every suite on every
backend, the Rust tests). Since milestone 6 `notYet` is empty; the census
itself has not been rerun since milestone 3 (section 15).

### Requesting Tier C from a feature branch

Put `[ci-full]` in the message of the **head** commit of a push (only the
head commit of the push counts). Narrow it with git trailers in the last
paragraph of the same message:

```
Fix the AArch64 frame record offset [ci-full]

CI-Tests: coroutines.test affine.test mutable-vector.test
CI-GC-Stress: 1
Co-Authored-By: ...
```

- `CI-Tests:` names tier.tcl items, space-separated: test files, golden
  suites, `smoke`, `acceptance`, `all`, `rust`, `examples`, `cabi`,
  `native-stack-mutants`, `native-aot-mutants`, `native-stack-bench`. Named
  files and suites run in shard 1 (shards 2 and 3 stop after one step); a
  tier is split in three.
- `CI-GC-Stress: 1` runs the named items under GC stress (the default
  payload always is).
- Without either trailer, `[ci-full]` runs the default payload.
- Once the workflow is on main, a manual run does the same on any branch:
  `workflow_dispatch` of `macos-arm64.yml` with the branch as the ref and
  the inputs `tier: full`, `tests`, `gc_stress` (the GitHub MCP server's
  `actions_run_trigger`, method `run_workflow`; or `gh workflow run
  macos-arm64.yml --ref BRANCH -f tier=full -f tests="X.test"`).
- To run the same payload again on the same commit, re-run the run
  (`actions_run_trigger`'s `rerun_workflow_run` or `rerun_failed_jobs`):
  it reads the same message. To change the payload, push a new commit (or
  amend and force-push your own branch) with new trailers.
- An ordinary push without `[ci-full]` never runs Tier C, and a docs-only
  commit never runs anything: put the marker on a commit that changes a
  non-`.md` file, or use workflow_dispatch.

### Reading results

- **Runs and jobs:** the GitHub MCP server's `actions_list`
  (`list_workflow_runs` with `workflow_runs_filter.branch`, then
  `list_workflow_jobs`). Without it, the public REST API answers
  unauthenticated (`curl -s
  https://api.github.com/repos/OWNER/REPO/actions/runs/RUN/jobs`, 60
  requests an hour).
- **Logs:** `get_job_logs` with the job id (`tail_lines` to bound it; it
  returns at most the last 5000 lines, so a long run's early output may be
  cut). Every tier.tcl run ends with its summary: one `######## LABEL:
  ok|FAILED` line per command, then `FAILED:` lines, each with the command
  that reruns the failing file or suite alone. The job's step summary shows
  the same lines. For one file's whole output, rerun it alone (below).
- **Artifacts:** Tier C uploads each shard's `tier.log`
  (`full-shard-N`). Downloading one goes through Azure blob storage, which
  an agent's network policy may block; the job log holds the same text.

### Toolchain failure or Botlish failure?

| Step that fails | Meaning |
|---|---|
| `Host` | not an arm64 macOS runner (the label changed meaning) |
| `Toolchain smoke` | the runner's C or Rust toolchain: an image problem, not Botlish |
| `Install prerequisites` | the Tcl 9.0.1 source build (its download, or an Xcode change breaking `configure`; the cache hides it until the script changes) or rustup |
| `C ABI facts` | core::cabi's `macos-aarch64` row disagrees with Apple clang: a Botlish target-table bug |
| `Build native` / `Native Rust unit tests` | the native crate on macOS: a Botlish change that compiles only on Linux, or a runtime unit test |
| `Native status` | a native capability changed behavior (section 15): intended, then record it; otherwise a regression |
| a tier | Botlish tests; compare with `linux control` at the same commit and with Linux CI |

### Reproducing one failure

1. Run the failing file locally on Linux (`CORE_BACKEND=interp tclsh9.0
   tests/X.test`, the command the summary printed). If it fails there too
   it is not macOS's; if it passes, it is.
2. Rerun only it on macOS: a push with `[ci-full]` and `CI-Tests: X.test`
   (one job, a few minutes).
3. Read the test's own output in that job's log (tcltest prints each
   failing test with its body and result).

Do not rerun a whole tier to look at one file, and do not start Tier C to
check a change Tier B already covers.

### Keeping Linux covered

The Linux workflows are unchanged (tests.yml, tests-arm64.yml,
single-executable.yml, bench.yml, static-decisions.yml, c-bindgen.yml,
scalar-asm-audit.yml). They run on pushes to main, and tests.yml,
tests-arm64.yml, bench.yml and c-bindgen.yml on pull requests too; on a
branch without a pull request, dispatch them (they have `workflow_dispatch`
on main):
`actions_run_trigger` with `workflow_id` `tests.yml` (and
`tests-arm64.yml`; `static-decisions.yml` for a front-end change) and the
branch as `ref`. A port milestone runs them before it merges.

### Updating CI when a milestone lands

- **A capability starts working on macOS:** update its expectation in
  `tests/platform/native-status.tcl` (the smoke job fails until you do),
  remove the files that now pass from tier.tcl's `notYet` (run them with
  `CI-Tests:` first), and update section 15.
- **Native golden runs** (coroutines work since milestone 3): the acceptance
  tier's golden suites run on all four backends.
- **More backends in Tier B:** the acceptance job's `-backends`.
- **A new macOS-only check:** a step in `smoke` (cheap) or an item of
  tier.tcl (anything a test file or suite cannot express); never a
  `.test` file that only macOS runs.
- **The runner image:** when `macos-15` is retired, change the three
  `runs-on` lines together.

## 17. Roadmap

Each milestone is independently mergeable: it makes one capability work
on macOS, flips that capability's `tests/platform/native-status.tcl`
expectation from its refusal to its value, moves the test files and
golden suites that now pass into `tests/platform/tier.tcl`'s acceptance
lists, and leaves everything not yet ported refusing exactly as before.
Every milestone runs the Linux suites (tests.yml, tests-arm64.yml) on its
branch before it merges; one that changes the front end also runs
static-decisions.yml (AGENTS.md).

### 1. CI infrastructure and platform audit (this milestone)

The workflow, the tiers, the scripts in tests/platform/, this document and
the census. Report: MACOS-AARCH64-MILESTONE-1.md.

### 2. Target representation and macOS C ABI facts

- **Status: done** (MACOS-AARCH64-MILESTONE-2.md). The acceptance below
  holds; the plain-char expectations of c-ffi.test and the C FFI fuzzer read
  the OS and the architecture (the fuzzer keeps its own model).
- **Files:** core/linuxabi.tcl, surface/modules.tcl (`ModuleFile`),
  surface/cache.tcl (`Dependencies`), hir/interchange.tcl, main.tcl,
  hir/cabi.tcl; tests/c-ffi.test :413-415, audit/c-ffi/tools/fuzz.tcl
  :60-64.
- **Prerequisites:** milestone 1.
- **Acceptance:** importing a `linux` namespace for a `macos-aarch64`
  compilation is a stated diagnostic (not `stdlib/linux/sys.aarch64.bot`); a
  `.hirx` records its target and a native run refuses another host's; a
  native run or link refuses a `-target` that is not the host; the tests'
  plain-char expectations come from `core::cabi`. The `macos-aarch64` row
  itself is already verified (cabi-facts.tcl, smoke).
- **macOS CI:** smoke and acceptance; the census (`CI-Tests: all`) to show
  nothing else moved.
- **Linux risks:** `std::linux::sys` selection and its cache dependencies
  (tests/linux-syscall-transports.test, tests/hir-cache.test), the
  interchange format (HIR-INTERCHANGE.md's audits), static decisions.

### 3. Pure Cranelift codegen and native JIT

- **Files:** native/src/codegen/{mod.rs,clif.rs,roots.rs}; the stale
  "x86-64 only" comments; tests/golden.test and tests/workload-2048.test's
  drop-native-off-Linux rules; the constraints of section 11 that guard
  JIT-only tests.
- **Prerequisites:** 2 (for the module refusal the JIT tests see).
- **Acceptance:** every census failure whose cause is JIT code generation
  is fixed; `tests/native-coverage.tcl -backend cranelift` (and
  cranelift-generic) classifies only the capabilities of later milestones
  as failures on macOS; the census shows no other native-value mismatch.
- **macOS CI:** acceptance; `CI-Tests: all`; a coverage run.
- **Linux risks:** low if no codegen change is OS-conditional; any change
  to `isa()` or signatures runs the arm64 workflow.

### 4. Native allocation, GC and coroutine validation

**Done (milestone 3, MACOS-AARCH64-MILESTONE-3.md)** for coroutines, their
stacks and the native golden runner; the entry below is the plan it was
carried out from. Mach-O and C calls (milestones 6 and 7) and stack bounds
(milestone 5) are not part of it.

- **Files:** .cargo/config.toml (an `aarch64-apple-darwin` entry),
  runtime/framewalk.rs, codegen/clif.rs `define`, runtime/coroutine.rs
  (stack mapping without `MAP_STACK`, page-size rounding, Mach-O
  directives and `_` labels in the switch assembly, the initial FPCR).
- **Prerequisites:** 3.
- **Acceptance:** coroutines.test, affine.test, mutable-vector.test and the
  coroutine-using tests of the census pass on macOS, also under
  `BOTLISH_NATIVE_GC_STRESS=1` (Tier C's default payload);
  native-status's `coroutine` expectation is its value; the frame walk's
  termination without stack bounds is either proven (GC stress) or bounded
  by milestone 5 first.
- **macOS CI:** full (GC stress), `CI-Tests: coroutines.test affine.test`.
- **Linux risks:** high: the AArch64 switch and frame layout are shared
  with Linux AArch64 -- the arm64 workflow's GC-stress run is required.

### 5. Runtime stack bounds and overflow handling

**Done (milestone 4, MACOS-AARCH64-MILESTONE-4.md)**: the worker thread's
bounds and guard are discovered (and the main thread's), a native overflow
of the thread's stack or a coroutine's is `NATIVE LIMIT STACK` from the
guard, stack probes are on and the depth token is gone on macOS; the guard
became one module the three hosts share, and coroutine switches publish
the stack they arrive on (a Linux gap closed with it). The entry below is
the plan it was carried out from. Its report is numbered 4: the reports
number milestones in the order they were carried out, this roadmap as it
was first planned.

- **Files:** runtime/platform/ (a macOS module beside linux.rs),
  runtime/native_stack.rs, runtime/vm.rs, main.rs (:143, :563),
  runtime/aot.rs (:52, :101), codegen/mod.rs (stack probes),
  codegen/roots.rs (`depth_reservation`).
- **Prerequisites:** 4 (coroutine stacks have guards too).
- **Acceptance:** the macOS worker thread's bounds and guard are
  discovered; a native overflow is `NATIVE LIMIT STACK` (from the guard,
  not the depth token) for the JIT and, after milestone 6, executables;
  stack probes are on; tests/native-stack-overflow.test, the depth-helper
  expectations of native-stack-map.test, native-root-storage.test and
  native.test run on macOS with the Linux branch's results.
- **macOS CI:** smoke (native-status `stack-overflow`), full.
- **Linux risks:** `native_stack_overflow_supported()` and the depth token
  decide Linux's code too: the predicate may only grow.

### 6. Mach-O AOT, native driver and standalone executable

**Done (milestone 5, MACOS-AARCH64-MILESTONE-5.md)**: `-emit-native-executable`
produces a Mach-O arm64 executable through the rustc linker and Apple's ld
that runs standalone; native-status's `executable` expectation is its value
(and header); the `executableAot` tests run on macOS (one capability in
tests/helpers.tcl); the stub linker stays Linux x86-64; a C call is still
refused on macOS, before the link. The entry below is the plan it was
carried out from; the report is numbered 5.

- **Files:** codegen/aot.rs (`emit_executable`'s gate, `link_rustc`),
  codegen/mod.rs (`emit_object`), runtime/aot.rs; the `executableAot`
  constraints; main.tcl/native.tcl's text.
- **Prerequisites:** 5 (an executable installs the guard).
- **Acceptance:** `-emit-native-executable` produces a Mach-O arm64
  executable through the rustc linker that runs and prints its value;
  native-status's `executable` expectation is its value; the
  executable tests that are not about ELF, Linux syscalls or the stub
  linker run on macOS. The stub linker stays Linux x86-64.
- **macOS CI:** acceptance (the executable test files join it), full.
- **Linux risks:** `link_rustc`'s Linux arguments stay byte-identical; the
  stub-linker job.

### 7. C scalar/pointer ABI, symbol resolution and linking

**Done (milestone 6, MACOS-AARCH64-MILESTONE-6.md)**: a program that calls
C links through Apple's toolchain on macOS AArch64 (`C_CALLS` admits it; a
link plan per `LinkerFlavor`, no GNU group; Apple ld's words kept in NATIVE
LINK) and calls its C functions with Apple's arm64 ABI on both native
backends and in executables; native-status's `c-call` expectation is its
value (`5`); c-ffi.test and c-bindgen.test run in the acceptance tier
(`notYet` is empty). The ABI is checked against Apple clang's own calls
(`cf-abi-*`), which found Cranelift 0.135.2's extended narrow stack
arguments stored at register width past their slot: Apple's stack-passed
narrow parameters are declared unextended (fixed upstream in 0.136.0).
Not here: byte borrowing's own acceptance on macOS (8), Darwin IO (9). The
entry below is the plan it was carried out from; the report is numbered 6.

- **Files:** codegen/aot.rs (`link_plan_args`, `linker_diagnostics`),
  codegen/clif.rs (`c_signature`, `foreign_call`), tests/cffi/fixture.c
  (Mach-O assembly), tests/c-ffi.test (fixture build, char, `ldd`, linker
  wording), tests/c-bindgen.test and tools/c-bindgen (the generator under
  Apple clang).
- **Prerequisites:** 6.
- **Acceptance:** c-ffi.test's fixture tests and c-bindgen.test pass on macOS: narrow
  arguments and results, stack-passed arguments, pointer results and wild
  addresses, `named` symbols, `extern c library` with `-L`;
  native-status's `c-call` expectation is its value.
- **macOS CI:** acceptance, `CI-Tests: c-ffi.test`.
- **Linux risks:** GNU ld's group and default-library flags (C-FFI.md,
  section 11) must stay.

### 8. Bytes borrowing, FFI fuzzers and GC stress

**Done (milestone 7, MACOS-AARCH64-MILESTONE-7.md)**: byte borrowing needed
no change on macOS; tests/c-byte-borrowing.test accepts it through real C
(the host compiler's fixture and libSystem's memcmp, memcpy, memmove and
memset, under GC stress, in coroutines and executables, under Guard
Malloc); c-pointer-borrowing.test and the borrowing-related runtime tests of
the layout files and abi-mutable-bytes run there by capability; the
borrowing mutation tool runs without `timeout(1)` with per-host mutants
(tier items `c-borrow-fuzz`, `c-borrow-mutants`, `c-borrow-bench`).
abi-bytes' and abi-mutable-bytes' syscall tests stay Linux's. The entry
below is the plan it was carried out from; the report is numbered 7.

- **Files:** native/lower.tcl's exposure code (unchanged, expected),
  audit/c-ffi/tools, audit/c-pointer-borrowing/tools (and `exec timeout`,
  which macOS lacks).
- **Prerequisites:** 7.
- **Acceptance:** c-pointer-borrowing.test and the non-syscall parts of
  abi-bytes/abi-mutable-bytes pass on macOS; the C FFI and borrowing
  fuzzers run there with GC stress.
- **macOS CI:** full, with the fuzzers as named items or a Tier C step.
- **Linux risks:** the exposure mechanism is shared with the syscall
  bridges: abi-bytes and mutable-bytes mutation tools.

### 9. Darwin system APIs and contextual IO

**Done (milestone 8, MACOS-AARCH64-MILESTONE-8.md)**: `darwin`, the macOS
platform's namespace, calls libSystem's write, read, open (variadic), close
and `__error` (errno through a native view) as ordinary C calls with
byte-borrowing contracts; `std::darwin::io::DarwinIO` implements `std::io::IO`
structurally with LinuxIO's completion policy; examples/io/hello-darwin.bot
and the 2048 demo run as Mach-O executables; tests/darwin-io.test is the
macOS counterpart of portable-io's Linux tests (which stay Linux's). The
entry below is the plan it was carried out from; the report is numbered 8.

- **Files:** a macOS IO module implementing `std::io::IO` over libSystem C
  calls (stdlib/), tests/portable-io.test, tests/golden/run.tcl's hosts.
- **Prerequisites:** 7 (C calls), 2 (the Linux-module refusal).
- **Acceptance:** examples/io/hello.bot's macOS twin prints through
  libSystem `write`; portable-io's tests run on macOS; no raw Darwin
  syscall anywhere.
- **macOS CI:** acceptance, full.
- **Linux risks:** `std::io::IO` selection must keep choosing LinuxIO on Linux
  (context-traits tests).

### 10. Applications, regression breadth, optional libraries, documentation

- **Files:** examples/games/2048, tests/application-modules.test,
  examples/ffi/{tcl,sha256}, tests/cffi/boringssl.tcl, tests/local.tcl
  (`nproc`), bench/ memory measurement, packaging (hardened runtime and
  the JIT, if a signed driver is ever shipped).
- **Prerequisites:** 9.
- **Acceptance:** the census is all green (`CI-Tests: all`), the 2048
  workload runs natively and as an executable, the Tcl and BoringSSL
  acceptance link on macOS (the CI's Tcl build, libc++); this document's
  findings are closed or recorded as non-goals.
- **macOS CI:** the full matrix; Tier B grows to the whole suite.
- **Linux risks:** none specific.
