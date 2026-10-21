# WINDOWS-X86-64-MILESTONE-1.md

Milestone 1 of the Windows x86-64 port: the native driver and runtime built
with Microsoft's toolchain, standalone executables, and GC correctness. The
census before it, which made the toolchain decision this milestone carries
out, is WINDOWS-TOOLCHAIN-CENSUS.md (its section 10 proposed this slice).
Developed on Linux. Every Windows fact below was observed on GitHub's
`windows-2025` runners through `.github/workflows/windows-x86_64.yml`,
running production code: no probe patch, no `BOTLISH_PROBE_*` variable, no
Wine, no WSL.

> MSVC is the native Windows toolchain: `x86_64-pc-windows-msvc`,
> Cranelift's COFF object, rustc, Microsoft's `link.exe`. Nothing of
> Botlish's sits between them.

## Result

The milestone's acceptance criteria hold on a real Windows host
(Windows Server 2025, MSVC, `x86_64-pc-windows-msvc`):

```text
Botlish -> HIR -> NIR (windows-x86_64) -> Cranelift (windows_fastcall) -> COFF object
        -> rustc --target=x86_64-pc-windows-msvc, +crt-static -> link.exe -> NAME.exe
```

| Criterion | Status | Evidence |
|---|---|---|
| The production driver builds with `x86_64-pc-windows-msvc` | tested on real Windows | every smoke job's build; Rust unit tests 242 + 48 there |
| Ordinary programs run through Cranelift | tested on real Windows | native-status `jit`; main.tcl's examples and the census's three programs on cranelift and cranelift-generic |
| Standalone `.exe` programs are produced and run correctly | tested on real Windows | aot-facts (moved, run from another directory, `PATH` reduced to System32), the 2048 and pure programs' executables, native-executable.test, argv.test |
| The driver rejects an incompatible Windows target | tested on real Windows | native-status `other-environment` (windows-x86_64-gnu: NATIVE TARGET) and `other-target`; target-model.test |
| No separately installed Visual C++ runtime DLLs | tested on real Windows | the PE import directory and `dumpbin /dependents`: only system DLLs |
| Windows argument handling documented and validated | tested on real Windows | ARGV.md "Windows"; argv.test's five `argv-windows-*` tests |
| GC tests and allocation-heavy workloads pass under GC stress | tested on real Windows | gc-workloads (133 runs), the census's programs under stress, the acceptance tier under `BOTLISH_NATIVE_GC_STRESS=1` (8491 tests on interp and on compile, 0 failed) |
| The frame walker cannot run in the shadow-stack configuration | implemented, unit-tested on real Windows | one constant, `NATIVE_FRAME_ROOTS`; `walk_from` returns before reading a frame; `without_the_capability_nothing_is_walked` |
| Stack probes enabled appropriately | tested on real Windows | `a_frame_of_many_pages_is_probed_and_runs` (a 1 MiB frame, probed, runs) |
| The Windows CI smoke tier runs production code and passes | tested on real Windows | run [39501615079](https://github.com/mwagner-webdev/botlish/actions/runs/39501615079) (`49cbea2`, this branch's head): smoke and acceptance, every job green; run [39493281912](https://github.com/mwagner-webdev/botlish/actions/runs/39493281912) (`f816bf2`): the acceptance tier under GC stress, 4 of 4 |
| Existing supported targets keep their behavior | tested in CI and locally | Linux x86-64 (local suite, tests.yml), Linux arm64 (tests-arm64.yml), macOS arm64 (macos-arm64.yml): section 6.4, 7.3 |

Along the way the real-Windows runs found one runtime bug the fallback root
plan had always had (section 3.4: a compiled recursion deeper than the
shadow stack crashed instead of reporting `NATIVE LIMIT STACK`), and a
series of harness assumptions about Unix (section 6.3). Both are fixed.

Not implemented (later milestones, each refused with its own error on
Windows): C calls, native coroutines, a stack guard, Windows platform IO,
native-frame GC roots (section 8).

## Contents

1. [Implementation summary](#1-implementation-summary)
2. [MSVC integration](#2-msvc-integration)
3. [GC correctness](#3-gc-correctness)
4. [The argument contract](#4-the-argument-contract)
5. [Stack probes](#5-stack-probes)
6. [Tests](#6-tests)
7. [CI](#7-ci)
8. [Remaining limitations](#8-remaining-limitations)
9. [Next milestone](#9-next-milestone)

## 1. Implementation summary

What runs on a real Windows host now, with MSVC's toolchain:

```text
Botlish -> HIR -> NIR (target windows-x86_64) -> Cranelift (windows_fastcall) -> COFF object
        -> rustc --target=x86_64-pc-windows-msvc (startup crate, +crt-static) -> link.exe -> NAME.exe
```

* the native driver and runtime, built for `x86_64-pc-windows-msvc`, and
  their Rust unit tests;
* `main.tcl -backend cranelift` and `-backend cranelift-generic` (the JIT);
* `main.tcl -emit-native-executable`: a PE console executable named `.exe`,
  importing only the system's DLLs;
* the collector, through the fallback root plan (shadow stack, no frame
  walk), under `BOTLISH_NATIVE_GC_STRESS=1`;
* a recursion bound: Botlish recursion too deep for the shadow stack ends in
  `NATIVE LIMIT STACK`, as on every other host. This needed a fix found on
  Windows (section 3.4);
* Windows arguments, as WTF-8 bytes, through `argv()`.

Refused, each with its own explicit error: native coroutines, C calls,
Linux platform IO. There is no stack guard: a native stack exhausted before
the depth check ends the process in Rust's own report (section 5).

### 1.1 Files and subsystems changed

Native backend (`native/`):

| File | Change |
|---|---|
| `src/runtime/aot.rs` | `process_argv` (Unix: the raw bytes; Windows: `wtf8_from_utf16` of each UTF-16 argument); the module documents Windows' argument rules |
| `src/runtime/aotimage.rs` | the stub startup reads `process_argv` |
| `src/runtime/ops.rs` | two unit tests of the Windows argument encoding |
| `src/codegen/aot.rs` | `EXECUTABLES` admits `windows`+`msvc`+`x86_64`; `LinkerFlavor::Msvc` and its link plan (`/LIBPATH:DIR`, `NAME.lib`, no group); `crt_args` (`+crt-static` for a program that calls no C); `executable_path` (`.exe`); `emit_executable` returns the file it wrote; rustc gets `--target=<host triple>`; the link work file is `executable.exe` on Windows; `linker_diagnostics` keeps `error LNK`, `warning LNK` and `lld-link:` lines; the stub's permission bits under `cfg(unix)`; unit tests |
| `src/codegen/target.rs` | `same_target` compares the triple's environment too; `check_host` names both environments; unit tests |
| `src/main.rs` | the `executable` command emits `executable_path`; `run_linked` runs the file it linked; `linked_command` (Unix: argument zero from the snapshot; Windows: refused, section 4) |
| `src/runtime/framewalk.rs` | `NATIVE_FRAME_ROOTS`, the one root capability; `walk_from` returns at once without it; unit tests |
| `src/codegen/clif.rs` | stack maps are emitted exactly when `NATIVE_FRAME_ROOTS` |
| `src/codegen/roots.rs` | the plan and the root report read the capability; the depth reservation reads `depth_checked` |
| `src/runtime/vm.rs` | the shadow stack is allocated unless native frames hold the roots and the guard reports exhaustion |
| `src/runtime/native_stack.rs` | `depth_checked`: where the shadow stack's depth check bounds recursion |
| `src/nir.rs` | `Function::has_botlish_call`; the call-effect summary makes a function with a Botlish call fallible where the depth is checked (section 3.4); unit tests |
| `src/codegen/mod.rs` | `stack_probes()`: on with the guard or on Windows; the large-frame test; the host's object format test; the ELF relocation test gated to Linux x86-64 |
| `src/runtime/coroutine.rs` | stack-switching items gated to the hosts that switch stacks (no dead code on Windows) |
| `tests/native_stack.rs` | the guard's tests compile only where there is a guard; elsewhere the target says so |
| `Cargo.toml` | the test-only feature `fallback-roots` |

Front end and command line: `native/native.tcl` (the `capabilities`
table, `hostSupports`, `executableFile`, `native::executable` returning the
file written), `main.tcl` (prints the executable it wrote). The front end
itself (`core/`, `hir/`, `surface/`, `lib/`) did not change:
`core::cabi`'s `windows-x86_64` row was already MSVC's.

Tests and tools: `tests/helpers.tcl` (constraints read the capability
table; `runStandalone`; `unixShell`), `tests/binary-header.tcl` (PE and
COFF), `tests/platform/native-status.tcl` (the Windows row, three new
probes), `tests/platform/aot-facts.tcl` (Windows checks),
`tests/platform/gc-workloads.tcl` (new), `tests/platform/cabi-facts.tcl`,
`tests/platform/tier.tcl` (`notYetByHost`), `tests/platform/setup-windows.ps1`
(new), `tests/golden/run.tcl`, `tests/argv.test` (five Windows tests),
55 other test files (section 6.3), the golden census and manifest (the
Windows argv tests' rows), the native-aot, target-model and c-ffi mutants,
`audit/proves-naming/tools/fuzz.tcl` (a Windows path), and Compilerpedia's
engine and checker (an `@target` example directive, the command named
without `.exe`; COMPILERPEDIA.md).

CI: `.github/workflows/windows-x86_64.yml` and
`.github/actions/setup-windows/action.yml` (new).

Documentation: this report, ARGV.md, AGENTS.md ("Windows x86-64 (MSVC)"),
docs/INDEX.md, Compilerpedia (`backend.native-executable`,
`backend.platforms`, `error.native-limit-stack`).

Small corrections next to the binding generator, recorded separately as
the brief asks, all in `tests/c-bindgen.test`:

* The fixture has no committed binding for `windows-x86_64` (its targets
  are Linux's, macOS's and `windows-x86_64-gnu`). So the five tests that
  generate or compile it for the host's target
  (`cb-fixture-no-c-at-compile-time`, `cb-fixture-isolation`,
  `cb-fixture-static-compile`, `cb-layout-ordinary`,
  `cb-layout-union-program`) carry a `fixtureHostBinding` constraint, and
  the first reads its row with `dict getdef`.
* The `mingw` constraint of the Win32 tests now also requires the MinGW-w64
  version the profile pins, read through the toolchain adapter
  (`::chdr::toolchain::macros`). The Windows runner's own MinGW-w64 13
  headers are not the profile's source: generation refuses them
  (`cb-win32-version-pinned`), so the tests no longer run against them. The
  c-bindgen workflow, which installs the pinned 11.0.1, passed with the
  change (run [39486090132](https://github.com/mwagner-webdev/botlish/actions/runs/39486090132)).

No generator code, profile or committed binding changed. The MinGW
bindings (`generated/c/win32/windows-x86_64-gnu/`) are untouched.

## 2. MSVC integration

### 2.1 Target

`windows-x86_64` is the one Windows target that runs natively. It is
`core::cabi`'s existing row, triple `x86_64-pc-windows-msvc`, which
`core::cabi::hostTarget` already chose on every Windows host.
`windows-x86_64-gnu` keeps its row: the binding generator's Win32 binding
and the fixture are generated for it, and its layouts are MinGW-w64's.
But no driver runs it.

The census found the driver comparing only architecture and operating
system (B10: a gnu driver accepted an MSVC program and linked it).
`codegen::target::same_target` now compares the triple's environment as
well. The driver refuses to run or emit machine code for the other
environment's program:

```text
NATIVE TARGET this program was built for target windows-x86_64-gnu (x86_64-pc-windows-gnu),
and native code runs only on its own target's host ... Both are x86_64 windows, but the C
toolchain environment is part of the target: gnu for this program, msvc here
```

That is native-status's `other-environment` probe on the runner. On Linux,
the driver refuses a Linux program built for another environment the same
way (`another_environment_of_the_hosts_system_is_refused`).

The startup crate is compiled with an explicit `--target=<the driver's own
host triple>` (`target_lexicon::HOST`), never whatever rustc's default host
is: a rustc whose default is `x86_64-pc-windows-gnu` would otherwise build
a `-gnu` startup crate against the MSVC runtime library. Linux and macOS
pass their own triple, which is what rustc used before. The runtime library the startup crate links
(`libbotlish_native.rlib`) must still come from the same rustc as the one
compiling the startup crate, as on every host: a different rustc on `PATH`
than the one that built the driver fails the link with rustc's own E0514.
That is unchanged and not Windows-specific.

### 2.2 COFF

Cranelift and the `object` crate write the object. Nothing in this
milestone transforms it: the census's byte-for-byte identity of the gnu
and msvc objects is kept, because nothing distinguishes them. On the
runner (aot-facts, every run):

* header `coff x86_64 object` (machine `0x8664`);
* sections `.text`, `.bss` (the context area), `.rdata$.refptr`;
* relocations `REL32` (calls, `.refptr` loads) and `ADDR64` (`.refptr`
  entries), within the accepted set {`ADDR64`, `ADDR32NB`, `REL32`};
* symbols `botlish_fn_N` and `botlish_entry_N` defined, 157 `rt_*`
  undefined, none decorated.

MSVC's own `dumpbin` reads the same: `8664 machine (x64)`, the
`botlish_fn_` and `rt_list_new` symbols, `REL32` relocations.

### 2.3 Linking

`LinkerFlavor` gains `Msvc`, chosen by `cfg!(target_env = "msvc")` beside
`Apple` and `Gnu` (macOS's precedent). rustc compiles the startup crate and
runs `link.exe` itself. rustc found `link.exe` and the Windows SDK on every
run, with no Developer Command Prompt: the workflow enters `vcvars64.bat`
only to build Tcl and to run `dumpbin`, never for Botlish. Botlish has no
Visual Studio discovery of its own.

The program's link plan in `link.exe`'s terms:

```text
-C link-arg=/LIBPATH:DIR     for each -L DIR
-C link-arg=NAME.lib         for each extern c library "NAME"
```

with no `--start-group`/`--end-group` (GNU ld's) and no `-l`.
`ffi_link_plan_msvc_is_link_exes_spelling` pins it.

**Tested how:** the plan is unit-tested on every host (Rust tests, also on
the runner). It is not exercised by a real link on Windows, because a plan
is only non-empty for a program that calls C, and C calls stay refused on
Windows (`C_CALLS`) until their milestone. The plan exists because the
flavor is the platform seam that milestone fills. The ordinary link
(object, startup crate, runtime library) is exercised on every run.

### 2.4 C runtime

A standalone executable of a program that calls no C links the C runtime
statically: `crt_args` gives the startup crate's rustc `-C
target-feature=+crt-static` for `LinkerFlavor::Msvc` when the program has
no foreign call and no library. The census measured that the default
(dynamic) CRT imports `VCRUNTIME140.dll`, which a Windows machine without
Visual Studio's redistributable lacks.

**Verified, not assumed**, on every run, two ways:

* aot-facts' `executable-imports` reads the PE import directory
  (`tests/binary-header.tcl`'s `peFacts`): `api-ms-win-core-synch-l1-2-0.dll,
  bcryptprimitives.dll, KERNEL32.dll, ntdll.dll`. None is a C runtime DLL
  (`vcruntime*`, `msvcp*`, `concrt*`, `ucrtbase`, `api-ms-win-crt-*`), and
  every one is an API set or a file in System32.
* `dumpbin /dependents` of the 2048 benchmark's executable: the same four.
  The step fails if a CRT DLL appears.

Not imposed elsewhere: the driver itself keeps rustc's default CRT (it is a
development tool), and a program that calls C keeps the dynamic one, so
that a C library compiled against the dynamic CRT links
(`crt_is_static_for_msvc_executables_only`; mutants `msvc-crt-dynamic`,
`msvc-crt-imposed-on-c-programs`).

### 2.5 Executable naming

An executable's file is `codegen::aot::executable_path(PATH)`: on Windows
a name without an extension gets `.exe` (`std::env::consts::EXE_EXTENSION`),
and a name with one is kept; elsewhere the name is unchanged.

* The driver emits that file and returns it.
* `native::executable` returns it in the caller's spelling plus the suffix.
* `main.tcl` prints it (`executable: artifacts/bench.exe` on the runner).
* `run_linked` runs the file it linked.
* `native::executableFile` is the Tcl mirror, for a test that needs the
  name before linking.

The link work file is `executable.exe` on Windows too, by the same rule
(census B8): `link.exe` keeps an extensionless name as given, but MinGW's
gcc appends `.exe` to one, which broke every link of the census's E14a, so
the work file never depends on the linker's habit. Unix names are
unchanged (`executable_names_follow_the_platform`; the Tcl tests on Linux).

### 2.6 Linker diagnostics

`linker_diagnostics` keeps the lines a NATIVE LINK message quotes: GNU
ld's, Apple ld's, and now `error LNK`, `warning LNK` and `lld-link:` lines.
These carry LNK2019 (unresolved external symbol), LNK1120 (unresolved
externals) and LNK1181 (cannot open input file), in `link.exe`'s and
`lld-link`'s spellings. The message's framing is the existing NATIVE LINK
one. **Tested how:** unit-tested with captured `link.exe` and `lld-link`
text (`ffi_linker_diagnostics_keep_the_linkers_words`, also on the runner).
A real LNK error has not been produced on Windows: every input the driver
links is its own, and a missing symbol or library needs a C call, which is
refused first.

## 3. GC correctness

### 3.1 The root strategy

Native code keeps a function's GC roots in one of two places
(`codegen::roots`):

* **native frames** (Linux, macOS): stack-map slots of the function's own
  frame, which the collector finds by walking the machine stack's frame
  pointer chain (`runtime::framewalk`);
* **the shadow stack** (the fallback plan): a function with a Botlish call
  keeps its roots in slots of the Vm's shadow array, and a leaf function
  publishes its frame-local roots through `Vm::native_roots_ptr`. Each
  frame also bumps the shadow stack by at least one slot and checks it
  against its end, which bounds recursion (`depth_reservation`).

Windows uses the fallback plan. It is the existing generic plan for a host
whose native frames cannot be walked, not a Windows mechanism, and it is
reused as it is: no new collector, no Windows-specific root code.

### 3.2 One capability

`runtime::framewalk::NATIVE_FRAME_ROOTS` decides it:

```rust
pub const NATIVE_FRAME_ROOTS: bool = cfg!(all(
    any(target_arch = "x86_64", target_arch = "aarch64"),
    any(all(target_os = "linux", target_env = "gnu"), target_os = "macos"),
    not(feature = "fallback-roots")
));
```

It names what the runtime can do, not what the CPU is: frame-pointer
chains it can climb, on the hosts where they hold. Every decision that
must agree reads it:

| Decision | Where | Reads |
|---|---|---|
| stack maps emitted | `codegen/clif.rs` | `NATIVE_FRAME_ROOTS` |
| a frame's root storage (native frame or shadow stack) | `codegen/roots.rs` `plan` | `NATIVE_FRAME_ROOTS` (the caller's argument) |
| the depth reservation | `roots::plan` | `native_stack::depth_checked(NATIVE_FRAME_ROOTS)` |
| whether a function with a call can fail | `nir.rs` `summarize_call_effects` | `depth_checked(NATIVE_FRAME_ROOTS)` |
| the shadow stack allocated | `runtime/vm.rs` `Vm::new` | `NATIVE_FRAME_ROOTS && native_stack_overflow_supported()` |
| the root report (`native::roots`) | `roots::report` | `NATIVE_FRAME_ROOTS` |
| the frame walk | `framewalk::walk_from` | returns at once without it |

The walk cannot run in the fallback configuration: `walk_from` returns
before reading a frame. With no stack maps emitted, there would be nothing
for it to read anyway. Before, the census found the fallback plan still
running the walk (E5: "the fallback plan is complete without it but still
runs it"). Two separate checks (an ISA name in `clif.rs`, a guard predicate
elsewhere) had been able to disagree. They are now one constant
(`native_frame_roots_are_the_frame_pointer_hosts`,
`without_the_capability_nothing_is_walked`, both on the runner).

The `fallback-roots` cargo feature builds the fallback plan on any host, to
run the suite with Windows' root plan on Linux. It is a test build, never
shipped (section 6.4).

### 3.3 Why the walk is off on Windows

The walker climbs a chain of frame pointers through Botlish frames and the
Rust runtime frames between them (a helper that allocates, then collects).
On Win64, LLVM's prologue sets the frame pointer inside the frame
(`lea rbp, [rsp+N]`, for the unwinder's sake), not to the slot holding the
caller's frame pointer, so the chain the walker follows is not a chain.
Forcing frame pointers in the Rust build does not change where LLVM puts
the pointer within the frame. The census tried exactly that (E5, E13) and
it did not help. Real Windows showed the result (census section 6.1):
uri-steady crashing or wrong under GC stress, and the 2048 benchmark wrong
or crashing *without* stress, with the toolchain as built. Those failures
were reproduced in its probe runs and are gone with no walk.

Native-frame roots on Windows need the unwinder's metadata instead
(`.pdata`/`.xdata` for Botlish's own frames, `RtlVirtualUnwind` to climb
Rust's). That is a milestone of its own, out of this one's scope.

### 3.4 A failure the fallback plan had: the depth check's error

On the first real-Windows run of aot-facts, `standalone-depth-limit` -- a
Botlish `down(n) = 1 + down(n - 1)`, 100,000,000 deep on the executable's
default 1 GiB stack -- did not end in `NATIVE LIMIT STACK`. It ended in an
access violation with an empty stderr. Reproduced on Linux with the
`fallback-roots` driver (same plan):

```text
Thread 2 "botlish-native" received signal SIGSEGV
botlish_native::runtime::value::int_to_big () at src/runtime/value.rs:843
botlish_native::runtime::ops::int_binary () at src/runtime/ops.rs:402
botlish_native::runtime::ops::rt_int_add () at src/runtime/ops.rs:408
```

The depth check fired (at about 1.4 million frames: three shadow slots per
frame, 2^22 slots). It recorded the error and returned the error sentinel,
but `down`'s caller added the sentinel to `1` as if it were an Int. The NIR
call-effect summary (`summarize_call_effects`) had proven `down`
infallible (`may_error=false`), so its call sites carried no error check.
On the hosts with a guard that proof is sound: an exhausted stack ends the
process there, and no call returns an error for it. Under the fallback
plan, every function with a Botlish call can fail from its own prologue.

The fix states that once:

* `runtime::native_stack::depth_checked(native_frame_roots)` says where
  the depth check bounds recursion;
* `roots::plan` reserves depth by it;
* `summarize_call_effects` marks a function with a Botlish call
  (`Function::has_botlish_call`, now one definition for both) fallible by
  it, so its callers check and its raw result carries a status word.

On Linux and macOS `depth_checked` is false and the NIR effects are what
they were. Tests:

* `a_botlish_call_fails_exactly_where_depth_is_checked`, and the existing
  transitive-effects test updated (Rust, every host; under the fallback
  build it checks the Windows answer);
* native-status's new `recursion-limit` probe (a compiled program, JIT,
  default stack), next to the existing `stack-depth-limit` probe, whose
  hand-written NIR has no effect summary and so never showed this;
* aot-facts' `standalone-depth-limit` (an executable).

All three are `NATIVE LIMIT STACK` on every host. With the fix, the Linux
fallback driver reports `NATIVE LIMIT STACK` at 2,000,000 and at
100,000,000, where it crashed before. 1,000,000 still completes.

### 3.5 Validation

Real allocation-heavy programs, against the Tcl compiler's value, on the
runner (`tests/platform/gc-workloads.tcl -repeat 5`, every run):

* the census's two workloads, `bench/uri-steady.bot` (29500) and
  `examples/games/2048/bench.bot` (2002720);
* five standard-library examples that allocate (CSV parsing, geometric
  CSV, text cleaning, string replacement, matrix multiplication).

Each workload runs on cranelift and cranelift-generic, once as is and five
times under `BOTLISH_NATIVE_GC_STRESS=1`, then as a standalone executable,
once and five times under stress: 133 runs, 0 failed, on each of runs 4,
5, 6, 8 and 9 (section 7.3).

The census's three programs (the pure program, uri-steady, 2048) also run
through `main.tcl -backend cranelift` and `cranelift-generic`, as is and
under stress (12 runs per CI run). The 2048 executable prints 2002720 as is
and under stress.

The native GC tests of the Tcl suite run in the acceptance tier on interp
(section 7). Among them: `native-root-liveness.test`,
`native-alloc.test`, `string-allocation.test`, `value-transport.test`,
`native-root-storage.test`, `native-stack-map.test` (whose plan tests
expect the shadow stack there, section 6.3), the struct, list, string and
mutable-collection tests. The whole acceptance tier also ran under
`BOTLISH_NATIVE_GC_STRESS=1` (the workflow's full tier, run 8): every Tcl
test file on interp and on compile, 8491 tests each, 0 failed, and 96
golden suites on both Tcl backends, 0 failed. Every native run those test
files make collected before every allocation.

Before (census section 6.1, the same programs and runner image with the
walk): uri-steady crashed under stress on msvc; the 2048 benchmark was
wrong (`IndexNotFound`) or crashed without stress, and crashed under it.

### 3.6 Native-frame roots elsewhere are unchanged

On Linux x86-64, Linux AArch64 and macOS AArch64, `NATIVE_FRAME_ROOTS` is
what the old checks together said: x64 or aarch64, Linux glibc or macOS.
Stack maps, the walk, the absence of a shadow stack, the guard and the NIR
effects are unchanged. Tests asserting the native-frame plan there (for
example native.test's `native-aot-2`, contexts.test's
`contexts-native-machine-code`) still pass (section 6).

### 3.7 What remains for performance

The fallback plan costs, per Botlish call: the shadow slots' stores and
reloads, the depth check, and now an error check after every call of a
function with a call. Measured on Linux x86-64, where both plans run
(the default driver against the `fallback-roots` driver, one 4-core
container, best of 15 runs of the JIT, two sessions):

| program | backend | native frames | fallback plan | cost |
|---|---|---:|---:|---:|
| `fib(27)` | cranelift | 1536, 1549 us | 2002, 1987 us | +28-30% |
| `fib(27)` | cranelift-generic | 1896, 1895 us | 2592, 2603 us | +37% |
| 2048 benchmark | cranelift | 3255, 3264 us | 3386, 3487 us | +4-7% |
| 2048 benchmark | cranelift-generic | 3313, 3323 us | 3535, 3465 us | +4-7% |
| uri-steady | cranelift-generic | 2806, 2783 us | 2898, 2867 us | +3% |

(uri-steady on cranelift varied between sessions on the shared machine,
2295 and 3537 us natively against 2339 and 3647 us: within noise of the
same +2-3%.) Call-bound code pays most: every call does a shadow-stack
round trip, and on Windows also the error check of section 3.4.
Allocation-bound code pays little. These are Linux numbers for the same
plan; Windows' own (aot-facts' `performance-compute`: JIT 390 us,
executable 382 us for its benchmark program) have no native-frame baseline
on that host to compare with. Getting native-frame roots back on Windows
is the unwind-metadata work of section 3.3.

## 4. The argument contract

ARGV.md, "Windows", is the contract. In short:

* **Splitting** is Rust's runtime's split of `GetCommandLineW()`
  (`std::env::args_os`): the modern Microsoft C runtime rules, which
  MSVC-built C programs see. Quotes, backslash runs before a quote, the
  empty argument, tabs. Argument zero is read by its own rule.
* **Encoding** is WTF-8 of each argument's UTF-16
  (`runtime::aot::wtf8_from_utf16`, written out, not `OsString`'s
  unspecified internal form). Valid UTF-16 is its UTF-8, with no
  normalization. An unpaired surrogate becomes its three-byte generalized
  UTF-8 form, which is lossless. The snapshot is the same `Vec<Vec<u8>>`
  as Linux's: no new string type.
* **Validation** is unchanged: `argv()` is `List[String] errors
  InvalidArgumentEncoding`. It fails on exactly the arguments no Botlish
  String can hold (an unpaired surrogate) with the declared error, never a
  replacement character.
* **Argument zero** is what the launcher wrote. A Windows process cannot
  have `argc == 0` or a NUL inside an argument.
* **In-process runs** (the JIT, the Tcl backends) read the injected
  snapshot. A UTF-8 snapshot is the WTF-8 a standalone executable reads
  for the same arguments, so both agree.
* **Linked runs**, the driver running a program that calls C as an
  executable, are refused on Windows (`NATIVE UNSUPPORTED foreign`,
  `main.rs`'s `linked_command`). The reason: `std::process` writes the
  child's argument zero as the executable's path, and passing the
  snapshot's would need the driver to write the command line itself. No
  program that calls C links on Windows yet, so this is unreachable today.
  The C call milestone owns it.

Tested on the runner, in the smoke tier's argv.test on interp and compile
(`argv-windows-*`, constraint `windowsProcess`), and through one executable
built once per test:

| Test | Edge cases |
|---|---|
| `argv-windows-command-line-round-trips` | spaces, tabs, embedded quotes, backslashes before a quote and at the end, a UNC-like path, `%PATH%` (not expanded), the empty argument, NFC and NFD, BMP and astral scalars: each argument exactly |
| `argv-windows-argument-zero-is-the-command-lines` | argument zero is the path Tcl's `exec` wrote, run after run |
| `argv-windows-unpaired-surrogate-is-the-declared-error` | `a\ud800b` and a lone `\udc00`: `InvalidArgumentEncoding`, handled by the program; a program that never calls `argv()` runs with one |
| `argv-windows-same-values-as-in-process` | the same text in-process and standalone |
| `argv-windows-large-vector` | 300 arguments, also under GC stress |

Plus the Rust unit tests `argv_windows_utf16_is_its_utf8` and
`argv_windows_unpaired_surrogate_is_the_declared_error` (every host, and
the runner). The Unix argv tests that need bash, python or a POSIX shell
carry `bashLauncher`, `pythonLauncher` or `unixShell` and are skipped there
by those constraints.

Not tested: a `CreateProcessW` with an empty command line (Rust's runtime
then gives argument zero the executable's path, by its documented rule; no
test launches one), and console code-page interaction (no Botlish program
prints on Windows yet).

## 5. Stack probes

`codegen::stack_probes()` turns on Cranelift's inline probestack for
generated code on every host with the guard and on Windows:

```rust
fn stack_probes() -> bool {
    native_stack_overflow_supported() || cfg!(target_os = "windows")
}
```

Windows commits a thread's stack a page at a time, through the guard page
below the committed part. A frame larger than a page that touches its far
end first skips the guard page and faults on reserved, uncommitted memory.
MSVC-compiled C probes for the same reason (`__chkstk`). Before, probes
were tied to the guard's existence, so Windows had none (B3).

**Verified** by `codegen::stack_probe_tests::a_frame_of_many_pages_is_probed_and_runs`
(every host, and the runner). It compiles a function with a 1 MiB explicit
stack slot that stores at its lowest address first. It checks the ISA's
flags (probestack on, inline strategy), that the vcode holds
`stack_probe_loop`, and that the function runs (42) on a fresh 4 MiB
thread. Without probes, that store lands below the committed stack on
Windows.

What is **not** protected yet:

* There is no stack guard on Windows: no vectored exception handler turns
  an exhausted stack into `NATIVE LIMIT STACK`. Probes only make stack
  growth correct.
* The shadow stack's depth check bounds Botlish recursion: 2^22 slots, at
  least one per frame. On the default 1 GiB stack it fires first, which is
  `NATIVE LIMIT STACK`, exit status 1 (native-status `stack-depth-limit`,
  `recursion-limit`; aot-facts `standalone-depth-limit`).
* A smaller stack is exhausted before the check fires: 16 MiB
  (`BOTLISH_NATIVE_STACK_BYTES`), or deep recursion inside the Rust
  runtime. The process then ends in Rust's own handler, `thread '<unknown>'
  has overflowed its stack`, with status `STATUS_STACK_OVERFLOW`
  (native-status `stack-overflow`; aot-facts `standalone-stack-overflow`).
  That is a known limitation of this milestone, recorded as such, not a
  clean error.

## 6. Tests

### 6.1 On the real Windows runner

Run [39486044527](https://github.com/mwagner-webdev/botlish/actions/runs/39486044527)
(`0765017`), windows-2025:

| Check | Result |
|---|---|
| native Rust unit tests (`--lib --bins`) | 242 + 48 passed, 0 failed (the guard's, the coroutines' and the ELF tests are compiled for their hosts only) |
| `--test native_stack` | "this host has no native stack guard: nothing to check" |
| cabi-facts (clang, MSVC target) | the windows-x86_64 row agrees |
| native-status | all 15 probes as recorded (the windows-x86_64 row) |
| aot-facts | every check but `standalone-depth-limit`, whose expectation named the guard's line instead of the run-time error's (fixed in `f816bf2`; the outcome itself was right: NATIVE LIMIT STACK, status 1) |
| gc-workloads `-repeat 5` | 133 runs, 0 failed |
| the census's programs through main.tcl | 12 of 12 (3 programs, 2 backends, plain and GC stress) |
| the 2048 and pure programs' executables, dumpbin | values right, plain and under stress; only system DLLs |
| smoke tier + Windows-relevant files, interp | 669 tests: 648 passed, 21 skipped, 0 failed |
| the same, compile | 669 tests: 644 passed, 25 skipped, 0 failed |
| main.tcl's examples | on interp, compile, cranelift-generic and cranelift: ok |
| acceptance, four shards | 8491 tests: 8017 passed, 474 skipped, 0 failed |
| golden suites (interp, compile) | 97 suites, 0 failed; 2 not run on this host (live x86-64 Linux syscalls: `golden-host: linux-x86_64`) |

The acceptance tier's skips, by constraint (all four shards; a test counts
once per constraint it lacks): `nativeCoroutines` 157, `nativeLinux` 89,
`cfFixture` 66 (c-ffi.test's C fixture: C calls), `linuxX86_64` 45,
`nativeStackGuard` 20, `bashLauncher` 12, `mingw` 8, `stubLinker` 7, and
fewer than seven each for the C-library and C-fixture tests
(`boringssl*`, `sdl3*`, `tcl*`, `nativeCCalls`, `nativeRun`,
`neCFixture`, `nvCFixture`, `laCFixture`, `luCFixture`, `floatFixture`),
`fixtureHostBinding` 5, `executableAot` 2, `linuxAarch64` 2, and one each
for `pythonLauncher`, `singleExecutable`, `rustcAvailable`, `unix`,
`unixShell`, `x86_64Host`, `mingwGcc`. Every one names a capability
Windows lacks today or a host tool the runner does not have (bash, python,
the pinned MinGW-w64), except the two `executableAot` skips, an operating
system check found here (below). `notYetByHost windows-x86_64` is empty:
no test file is left out.

Run [39493281912](https://github.com/mwagner-webdev/botlish/actions/runs/39493281912)
(`f816bf2`, dispatched with `tier: full`) repeated all of the above with
the corrected depth-limit check: the smoke job passed every step
(aot-facts' `standalone-depth-limit`: `exit 1, stderr "native stack
exhausted: too many nested calls (NATIVE LIMIT STACK)"`), acceptance shards
2-4 passed with the same totals (shard 1 was cancelled by the next push,
and passed in run 6 and, under GC stress, in this run), and the full tier
ran the acceptance tier under GC stress:

| full shard | interp | compile | golden (interp, compile) |
|---|---|---|---|
| 1/4 | 2067: 1979 passed, 88 skipped, 0 failed | the same | 24 suites, 0 failed |
| 2/4 | 2022: 1794 passed, 228 skipped, 0 failed | 2022: 1789 passed, 233 skipped, 0 failed | 25 suites, 0 failed |
| 3/4 | 2379: 2277 passed, 102 skipped, 0 failed | the same | 24 suites, 0 failed |
| 4/4 | 2023: 1967 passed, 56 skipped, 0 failed | the same | 23 suites, 0 failed |

Two of the skips (`executableAot`, shard 3) turned out to be no capability
at all: decimal-rounded.test and float64.test redefined `executableAot` as
"Linux on x86-64 or AArch64" by `tcl_platform`, a pre-existing operating
system check that skipped their executable tests on macOS and Windows.
They now read the capability (`49cbea2`).

Run [39501615079](https://github.com/mwagner-webdev/botlish/actions/runs/39501615079)
(`49cbea2`, the branch's head, pushed) passed every job: smoke, every step,
and acceptance, four shards, 8491 tests: 8019 passed, 472 skipped, 0
failed. Those are run 6's totals with the two `executableAot` skips gone:
decimal-rounded.test's and float64.test's executable tests now link and run
on Windows and pass. The golden suites ran as in run 6: 97 on interp and
compile, 0 failed, 2 not run on this host.

| acceptance shard (run 9) | Tcl test files on interp | golden (interp, compile) |
|---|---|---|
| 1/4 | 51 files, 2067 tests: 1979 passed, 88 skipped, 0 failed | 25 suites, 0 failed |
| 2/4 | 50 files, 2022: 1794 passed, 228 skipped, 0 failed | 25 suites, 0 failed |
| 3/4 | 50 files, 2379: 2279 passed, 100 skipped, 0 failed | 25 suites, 0 failed |
| 4/4 | 50 files, 2023: 1967 passed, 56 skipped, 0 failed | 24 suites, 0 failed |

The suite counts include the two host-only suites, `abi-numeric-native.bot`
(shard 3) and `linux-io-native.bot` (`golden-host: linux-x86_64`: live
syscalls through the x86-64 Linux transport). Both compile on Windows but
do not run there.

### 6.2 Capabilities the harness knows

`native::capabilities` (native/native.tcl) is the one table of what the
native backend does per host target. `tests/helpers.tcl`'s constraints,
the golden runner and tier.tcl read it:

| Capability | Constraint | windows-x86_64 |
|---|---|---|
| JIT | (none) | yes |
| executables | `executableAot` | yes |
| C calls | `nativeCCalls` | no (refused before linking) |
| coroutines | `nativeCoroutines` | no (NATIVE UNSUPPORTED) |
| stack guard | `nativeStackGuard` | no |
| GC roots in native frames | `nativeFrameRoots` (and `nativeDepthChecked`) | no: the shadow stack, depth-checked |
| Linux platform IO | `nativeLinux`, `linuxX86_64` | no (UNSUPPORTED-PLATFORM) |

The census's C-call probe succeeded on Windows, but `nativeCCalls` stays
off: the probe was a patch, and the Win64 C ABI has not been validated
against real callees.

### 6.3 Harness changes (B11)

* **PE/COFF.** `tests/binary-header.tcl` reads MZ/PE headers (`{pe x86_64
  executable|dll}`), COFF objects (`{coff x86_64 object}`), the PE import
  directory (`peFacts`) and COFF symbols and relocations (`coffFacts`).
  `hostBinaryHeader` has the Windows row. native.test's `x86_64Host` (its
  ELF relocation test) is an ELF host's, not x86-64's.
* **Running an executable** (`runStandalone`): the file
  `native::executable` returned, with `PATH` emptied and named variables
  set through `::env`, never `env PATH= ...` (no `env` on Windows). It is
  used by 23 test files that ran `exec env ...`, and their relocation tests
  move `executableFile` names.
* **No POSIX shell assumed.** The `cd` and launch tests use Tcl's `cd`.
  The ones that genuinely test a shell or a script launcher carry
  `unixShell`, `bashLauncher` or `pythonLauncher`, and chmod only on Unix.
* **The golden runner** leaves cranelift and cranelift-generic out on a
  host without native coroutines, with that reason: lib/test.bot's runner
  is a coroutine. On Windows the golden suites therefore run on interp and
  compile.
* **Tests that run coroutines natively** carry `nativeCoroutines`, as
  AGENTS.md's rule says: 119 tests, most of coroutines.test and
  affine.test (the coroutine handle is the one primitive affine root) and
  the coroutine cases of error-payloads, mutable-array, mutable-vector,
  static-compile, structural-contract-completions, compilation-isolation,
  hir-interchange, branch-form-boolean, enums, namespaced-errors,
  native-listloop, c-abi-types and native-executable. Each ran a coroutine
  program on cranelift and cranelift-generic and failed on the documented
  refusal; nothing else in them failed. Skipping them also skips their
  interp and compile halves on Windows. The Tcl backends' coroutines still
  run there, through every golden suite: the golden runner is a coroutine.
* **Root-plan tests expect the host's plan.** A new capability row,
  `frameRoots`, gives `nativeFrameRoots`. From it and `nativeStackGuard`
  comes `nativeDepthChecked`: the depth check is on unless both hold. Eight
  tests now expect "runtime stack", "yes" (a depth reservation),
  `may_error=true` or no stack map where these say so, instead of the
  Linux plan: native-root-storage's `storage-fib-1` and
  `storage-call-crossing-1` (still run under GC stress), native-stack-map's
  `stack-map-fib-1`, abi-bytes' and abi-mutable-bytes' keepalive tests,
  linux-syscall's `linux-syscall-clif-is-a-helper-call`, and the
  setcontains/setfromlist effect tests of `web::is_unreserved`. That
  function makes a Botlish call, so under the depth check it is fallible
  whatever its SetContains proves. These follow the precedent of
  `storage-call-crossing-2`.
* **The C target's widths.** native-edit's C scalar tests stored LP64's
  `long` extremes. They now store the target's: on Windows (LLP64) a
  `long` is 4 bytes, and the rest of its 8-byte slot stays untouched. The
  borrowing tests' prelude passed a 64-bit storage length as an
  `ffi::c::ULong` count. Where `unsigned long` is 32 bits it proves the
  range with a `mod` on the same line, so no location in the tests moves;
  cb-length-separate already stated that rule. All 61 borrowing tests pass
  on Linux with the Windows prelude forced.
* **ca-native-code and native-bitshift** counted `call ` in CLIF text. On
  Windows a signature's convention, `windows_fastcall {`, contains it.
  They now count the word.
* **Windows paths.** Nine tests stripped a diagnostic's location with
  `^[^:]*:LINE:COL: `, which stops at a drive letter's colon. They now
  strip to the first `:LINE:COL: `. The proves-naming fuzzer split a
  location on `:`; it strips the trailing `:LINE:COL` instead.
* **Line endings.** main.tcl's own lines end in CRLF on Windows (Tcl's
  default stdout translation). A native program's output and an
  executable's are their bytes (LF). The two tests that read main.tcl's
  output untranslated expect the platform's ending for its lines
  (value-display's `value-display-main`, native-program-output's
  `native-output-empty`). They still see any raw carriage return a value
  would print.
* **The command's name.** main.tcl and Compilerpedia name the command as
  typed: `tclsh9.0 main.tcl`, not `tclsh9.0.exe main.tcl` (the help's
  examples overflowed 80 columns).
* **A Compilerpedia example that depends on a target** names it, with a
  new `@target` directive (COMPILERPEDIA.md). The Win32 FILETIME layout
  generated for windows-x86_64-gnu is rejected for `linux-x86_64` (64-bit
  `unsigned long`), not "for this host": on Windows it compiles.
* **C toolchain.** Every job names `CC=clang` (MSVC's target). The image's
  `cc` is MinGW's, which cabi-facts refuses for the MSVC row, as it should.

### 6.4 Linux and the fallback plan

On Linux x86-64 (this development container, 4 cores, at `0765017`):

* `tclsh9.0 tests/local.tcl`: 201 Tcl test files, interp 6333 passed and
  compile 6328 passed, 0 failed (2125 golden duplicates skipped by the
  manifest); 99 golden suites on all four backends, 0 failed (interp
  4935/4935, compile 4935/4935, cranelift-generic 4843/4843, cranelift
  4945/4945); 36 minutes with three jobs.
* The native Rust tests (`--lib --bins`: 267 and 49): as built, under
  `BOTLISH_NATIVE_GC_STRESS=1`, and built with `fallback-roots`.
* `tools/compilerpedia.tcl check`: 692 topics, 548 examples, 0 problems.
* The changed files' own harnesses: the proves-naming fuzzer (seeds 1 and
  17) at `0765017`; earlier in the milestone, after the last change to the
  code they mutate (`codegen/aot.rs`, `codegen/target.rs`, the Tcl target
  model), the target-model mutants (18 of 18 killed) and the native-aot
  mutants (14 killed, 3 skipped as another host's, none surviving).

Windows' root plan on Linux, `tests/local.tcl -backends interp
-golden-backends cranelift,cranelift-generic` with the `fallback-roots`
driver: 98 of 99 golden suites pass on both native backends (cranelift
4883 tests, cranelift-generic 4781). Of 201 Tcl test files, 182 pass. The
19 that fail split three ways:

* assertions of the native-frame plan in Linux machine code or CLIF:
  native-aot-2, contexts-native-machine-code, ct-machine-code-direct,
  abi-bytes' and abi-mutable-bytes' machine-code tests,
  linux-syscall-clif-is-a-helper-call, stub-linker-image, the
  native-root-storage and native-stack-map plan tests, the effect tests of
  section 6.3. They expect the capability table's plan, which is still
  Linux's, and fail against a driver built for the other plan, by design.
* the stack guard's own tests (`native-executable-stack-overflow`,
  `ns-main-finite`: section 8);
* coroutines under GC stress (coroutines.bot, co-gc-*, co-release-native-*,
  mv-affine-growth, mv-affine-gc-stress, ma-principal-generate-native,
  ma-nested-affine, ep-gc-stress-coroutine, vc-gc-collect-1): the fallback
  plan has no coroutine support (section 8). Windows refuses native
  coroutines.

The section 3.4 bug was found here first, by reproducing Windows' crash.

With `BOTLISH_NATIVE_GC_STRESS=1`, the GC-relevant files (coroutines,
affine, mutable-vector, mutable-array, native, argv, native-root-liveness,
native-root-storage, native-stack-map, native-alloc, string-allocation,
virtual-construction, value-transport, native-executable, workload-2048)
on interp: 474 passed, 0 failed. tests.yml's own GC-stress job runs on
pushes to main only.

In CI, on `0765017` (both workflows dispatched on the branch):

* tests.yml ([39486064998](https://github.com/mwagner-webdev/botlish/actions/runs/39486064998))
  passed every job it runs off main:
  * the Tcl suite on interp (8491 tests: 8451 passed, 40 skipped, 0
    failed) and on compile (8491: 8446 passed, 45 skipped, 0 failed);
  * its cranelift and cranelift-generic coverage;
  * the golden suites beside their Tcl originals, four shards;
  * the native Rust unit tests and the stub-linked executables;
  * the warning gate and the method-filter audit.

  Its GC-stress job runs on pushes to main only, so it did not run here.
  The skips name host tools and libraries the runner lacks (BoringSSL's,
  SDL3's and Tcl's pinned sources and libraries, MinGW-w64, the single
  executable) and other hosts' tests (`linuxAarch64`, `appleAvailability`,
  and `windowsProcess` for the five Windows argv tests).
* tests-arm64.yml ([39486069355](https://github.com/mwagner-webdev/botlish/actions/runs/39486069355))
  passed every job. On Linux AArch64 these were:
  * the Tcl suite on interp and on compile;
  * its cranelift and cranelift-generic coverage;
  * the golden suites, four shards;
  * the native Rust unit tests, plain and under GC stress;
  * the Tcl suite under `BOTLISH_NATIVE_GC_STRESS=1`: 8491 tests, 8391
    passed, 100 skipped (46 of them `linuxX86_64`), 0 failed.

The changes since `0765017` (`3ad9633` AGENTS.md, `f816bf2` aot-facts'
Windows row, `49cbea2` two test files' constraint) do not run on Linux
differently: aot-facts' Windows expectations are read on Windows only, and
`executableAot` holds on Linux.

### 6.5 Mutants

* `audit/target-model/tools/mutate.tcl`: 18 of 18 killed, including the
  new `host-check-architecture-only` text (the environment check removed
  with the architecture one) and `windows-environments-one-target`.
* `audit/native-aot/tools/mutate.tcl`: 14 killed, 3 skipped (another
  host's), none surviving, including the new `msvc-link-plan-is-gnus`,
  `msvc-crt-dynamic` and `msvc-crt-imposed-on-c-programs` (killed by the
  link-plan and CRT unit tests) and the rewritten macOS ones.
* `audit/c-ffi/tools/mutants.txt`: `macos-link-plan-is-gnus` updated to the
  three-way `LINKER` (it applies on macOS only).
* No mutant covers the call-effect fix of section 3.4 on Linux: there
  `depth_checked` is false and removing the new line changes nothing. It is
  killed where it matters: by `a_botlish_call_fails_exactly_where_depth_is_checked`
  under the `fallback-roots` build, and on Windows by native-status's
  `recursion-limit` and aot-facts' `standalone-depth-limit`, which crashed
  without it.

## 7. CI

### 7.1 The workflow

`.github/workflows/windows-x86_64.yml`, on every push to any branch
(documentation-only pushes skip):

* runner `windows-2025`: Windows Server 2025 (10.0.26100), image
  `windows-2025-vs2026`, Visual Studio 18 (MSVC, its `link.exe`, the
  Windows SDK);
* stable Rust for `x86_64-pc-windows-msvc` (rustc 1.99.1 on these runs),
  the setup checking that it is rustc's host;
* Tcl 9.0.1 built from its pinned source release (sha256-checked) with
  MSVC's `nmake` by `tests/platform/setup-windows.ps1`, and cached;
* clang (the image's LLVM) for the C ABI facts, targeting MSVC;
* `bash` from Git for Windows for the steps' scripts: the tests themselves
  use no shell;
* production code only: no probe patch, no `BOTLISH_PROBE_*`.
  `windows-probe.yml` stays as the census's evidence.

Jobs:

* **smoke**, every push. Each check runs whatever an earlier one found,
  and every log is uploaded. Steps:
  1. the host and the toolchains;
  2. the release build;
  3. the Rust unit tests (`--lib --bins`) and the stack test target;
  4. `cabi-facts.tcl` against clang's MSVC target;
  5. `native-status.tcl`;
  6. `aot-facts.tcl`;
  7. `gc-workloads.tcl -repeat 5`;
  8. the census's programs through `main.tcl`, as is and under stress;
  9. the pure program's and the 2048 benchmark's executables, run and
     checked;
  10. `dumpbin` on the object and the executable;
  11. `tier.tcl smoke` (main.tcl's examples on all four backends, the
      front-end files on interp and compile) plus `argv.test`,
      `target-model.test`, `native-executable.test`, `main-cli.test`,
      `application-modules.test`, `workload-2048.test`, `native.test` and
      `c-abi-types.test`.
* **acceptance**, every push, four shards after smoke: `tier.tcl
  acceptance`, which is every Tcl test file on interp and every golden
  suite (on interp and compile, section 6.3), minus `notYetByHost`'s
  windows-x86_64 entries. That list is empty.
* **full**, opt-in (`[ci-full]` in the head commit, or a manual run): the
  acceptance tier under `BOTLISH_NATIVE_GC_STRESS=1`.

### 7.2 The brief's ten checks

| # | Check | Where | Result |
|---|---|---|---|
| 1 | driver and runtime compile | smoke: build | pass (runs 4-9) |
| 2 | Rust unit tests | smoke | lib 242, driver 48, 0 failed; the stack test target reports no guard |
| 3 | pure programs through both Cranelift variants | smoke: native-status `jit`, the census's programs through main.tcl, tier `examples` | pass: fib 6765; the pure program, uri-steady and 2048 on both variants; every example |
| 4 | `.exe` generation and execution | aot-facts, executables step, native-executable.test | pass: linked in ~0.5-0.8 s, `.exe` named and returned, run moved with System32-only `PATH` |
| 5 | allocation-heavy programs | gc-workloads, main.tcl step | pass: 133 runs; 12 through main.tcl |
| 6 | GC stress | gc-workloads, main.tcl step, executables step, full tier | pass: gc-workloads, main.tcl, executables, and the GC-stress acceptance tier (8491 tests per backend, 0 failed) |
| 7 | target mismatch rejection | native-status `other-target`, `other-environment`; target-model.test | pass: linux-x86_64 and windows-x86_64-gnu programs are NATIVE TARGET |
| 8 | PE/COFF properties | aot-facts, dumpbin, native-status `object`/`executable` | pass: COFF machine 0x8664, REL32/ADDR64, undecorated symbols; PE console subsystem |
| 9 | the executable's CRT dependencies | aot-facts `executable-imports`, dumpbin `/dependents` | pass: api-ms-win-core-synch-l1-2-0, bcryptprimitives, KERNEL32, ntdll; no CRT DLL |
| 10 | Windows CLI and argv | argv.test, main-cli.test, native-executable.test (`cli-paths`, `format`), application-modules.test | pass: the five `argv-windows-*` tests, `.exe` naming through main.tcl, CRLF of main.tcl's lines |

### 7.3 Runs

| Run | Head | What it showed |
|---|---|---|
| 1-3 | `c317c0f`-`92c4dcf` | run 1: the build, the Rust tests and native-status on real Windows (the coroutine refusal's error code corrected after it); runs 2 and 3 cancelled by the next pushes |
| [4](https://github.com/mwagner-webdev/botlish/actions/runs/39473051525) | `c410904` | native-status as recorded; COFF and PE checks; static CRT imports; gc-workloads 133/133; the 2048 executable; harness failures in aot-facts (an `env` restore), argv.test (Unix permissions), a `/bin/sh` launch, MinGW's `cc`, ca-native-code's CLIF count |
| [5](https://github.com/mwagner-webdev/botlish/actions/runs/39477134948) | `aa0d402` | the depth-limit crash (section 3.4); the first acceptance run: about 170 failures, every one classified in `0765017` (section 6.3) |
| [6](https://github.com/mwagner-webdev/botlish/actions/runs/39486044527) | `0765017` | acceptance: 4 of 4 shards, 8491 tests, 0 failed; smoke: every step but the depth-limit check's expectation (the outcome was right) |
| [8](https://github.com/mwagner-webdev/botlish/actions/runs/39493281912) | `f816bf2` | smoke: every step; the GC-stress acceptance tier: 4 of 4; acceptance shards 2-4. GitHub reports the run "cancelled": the next push cancelled acceptance shard 1, which passed in runs 6 and 9 and, under GC stress, in this run |
| [9](https://github.com/mwagner-webdev/botlish/actions/runs/39501615079) | `49cbea2` | every job: smoke, every step; acceptance 4 of 4, 8491 tests, 0 failed, the two `executableAot` skips gone |

macOS: on `f816bf2`
([39493274921](https://github.com/mwagner-webdev/botlish/actions/runs/39493274921))
and on `49cbea2`
([39501615229](https://github.com/mwagner-webdev/botlish/actions/runs/39501615229)),
smoke, both acceptance shards and the Linux control passed. The second is
the first macOS run in which decimal-rounded.test's and float64.test's
executable tests run, since macOS links executables too.
The c-bindgen workflow on `0765017`
([39486090132](https://github.com/mwagner-webdev/botlish/actions/runs/39486090132))
passed, including the Win32 profile's version check and the fixture tests
(section 6.3). Linux CI: section 6.4.

## 8. Remaining limitations

Explicitly unsupported on Windows, each refused with its own error:

| Capability | Today on windows-x86_64 | Owner |
|---|---|---|
| native coroutines | `NATIVE UNSUPPORTED value` (no Win64 stack switching) | a coroutine milestone; see below |
| C calls (`extern c fn`) | `NATIVE LINK`, refused before the linker runs (`C_CALLS`) | the next milestone (section 9) |
| platform IO (`io::IO`, printing from a program) | no Windows context; `linux::*` is `UNSUPPORTED-PLATFORM` | with C calls (section 9) |
| stack guard | none: an exhausted native stack ends the process in Rust's report | the vectored-exception guard milestone |
| native-frame GC roots | the fallback plan (shadow stack) | unwind metadata (`.pdata`/`.xdata`, `RtlVirtualUnwind`) |
| JIT unwind tables | not registered (on no host does the native backend emit or register any) | with unwind metadata |
| the stub linker, the single executable | Linux only, by design | out of scope |
| Windows ARM64 | no target row runs | out of scope |

Known issues and limits:

* **The fallback plan does not support coroutines.** A suspended
  coroutine's shadow slots break the shadow stack's LIFO order. Under the
  `fallback-roots` build on Linux, coroutine programs crash under GC stress
  (mutable-vector.test's `mv-affine-growth`, `mv-affine-gc-stress`;
  coroutines.test). It is unreachable on Windows, which refuses native
  coroutines. Win64 coroutines need either native-frame roots on Windows
  or one shadow stack per coroutine stack.
* **Recursion depth is counted in shadow slots, not stack bytes.** The
  fallback plan's bound is 2^22 slots, at least one per frame and one per
  root live across a call. A deep recursion holding many values ends in
  `NATIVE LIMIT STACK` sooner than on Linux, where the guard lets it use
  the whole 1 GiB stack. native-stack-overflow.test's
  `wide(1000000)`, six Ints live across its call, completes on Linux and
  is `NATIVE LIMIT STACK` under the fallback plan (observed with the
  `fallback-roots` build; the test carries `nativeStackGuard`).
* **Line endings differ by writer**: main.tcl's lines are CRLF on Windows,
  a native program's or an executable's output is LF (section 6.3).
* **A linked run's argument zero**, as above (section 4).
* **Stack exhaustion** on a small stack, or inside the runtime, is a
  process crash with Rust's report, not `NATIVE LIMIT STACK` (section 5).
* **The MSVC link plan and the LNK diagnostics** are unit-tested only,
  since no program that calls C links on Windows yet (section 2).
* **rustc must match** the driver's own: the startup crate links the
  runtime library the driver was built with. As on every host, a different
  rustc first on `PATH` fails the link with rustc's E0514.
* **The golden suites run on the Tcl backends only** on Windows: their
  runner is a coroutine. Native coverage on Windows is the Tcl test files'
  native tests, the platform scripts and the examples.
* **Pre-existing, not Windows'**: two mutants in `hir/range.tcl`'s mutation
  lists no longer apply on main as it stands (c-abi-types'
  `implicit-ptr-conversion`, enums' `cross-enum-parameter`). They were
  stale before this milestone and are left for their owners.

No failure is unresolved. Every test the Windows tier does not run is
skipped by a named capability constraint (section 6.1), and
`notYetByHost windows-x86_64` is empty.

## 9. Next milestone

**WINDOWS-X86-64-MILESTONE-2: C calls and the Windows console.** It is the
smallest slice that makes a Windows Botlish program useful on its own:
today a Windows executable can compute a value and return it, but cannot
print.

1. Open `C_CALLS` for `windows`+`msvc`. The link plan of section 2.3
   already exists. Validate the Win64 C ABI against real callees the way
   macOS milestone 6 did: `cf-abi-*`, a capture fixture assembled for
   Win64, narrow and stack arguments (the first four in registers,
   then the stack with its 32-byte shadow space), and a test in
   `ffi_link_plan_*`'s place that really links a `.lib`.
2. Give the linked run its argument zero (section 4) with a command line
   written by the driver.
3. A Windows console context for `io::IO`, over kernel32's `GetStdHandle`
   and `WriteFile`, declared as `extern c fn` with hand-written facts, as
   the census's `win32.bot` already showed working. Then the 2048 demo
   and the examples that print run on Windows' native backends.
4. Keep the fallback root plan. Native-frame roots through unwind
   metadata, the vectored-exception guard and Win64 coroutines are three
   further, independent slices. Coroutines need either of the first or a
   shadow stack per coroutine (section 8).
