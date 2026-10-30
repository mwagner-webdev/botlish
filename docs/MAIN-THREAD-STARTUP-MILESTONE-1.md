# MAIN-THREAD-STARTUP-MILESTONE-1.md

Explicit main-thread startup for macOS AArch64 executables: candidate A of
MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md as a supported, explicit
executable-startup policy.

> Which thread hosts an executable's initial Botlish program is a property
> of the executable's startup contract, not of the program's libraries,
> contexts or functions. Choosing the process main thread must preserve the
> same Botlish semantics and runtime safety as choosing the existing worker,
> subject to the explicitly documented stack-capacity difference.

Every platform claim below is marked:

* **[executed]** run on the platform it is about (macOS AArch64: GitHub's
  `macos-15` runners; Linux x86-64: this repository's sandbox and CI);
* **[inspected]** read from code, a linker command line or a tool's output
  about a file, without running the program on that platform;
* **[not implemented]** no such capability exists, by design or for now.

Evidence from the census's disposable experimental runtime is marked
**[census]** and is never counted as this implementation's.

## Contents

1. [Result](#1-result)
2. [Starting census findings](#2-starting-census-findings)
3. [Final public CLI](#3-final-public-cli)
4. [Startup policy semantics](#4-startup-policy-semantics)
5. [Target restrictions](#5-target-restrictions)
6. [Representation in botlish_program](#6-representation-in-botlish_program)
7. [Runtime ABI compatibility](#7-runtime-abi-compatibility)
8. [AOT runtime refactor](#8-aot-runtime-refactor)
9. [Worker-path preservation](#9-worker-path-preservation)
10. [Main-thread startup sequence](#10-main-thread-startup-sequence)
11. [Panic and error behavior](#11-panic-and-error-behavior)
12. [Main-stack reservation](#12-main-stack-reservation)
13. [LC_MAIN inspection](#13-lc_main-inspection)
14. [Main-thread native stack discovery](#14-main-thread-native-stack-discovery)
15. [Overflow-guard acceptance](#15-overflow-guard-acceptance)
16. [Stack-capacity acceptance](#16-stack-capacity-acceptance)
17. [GC root correctness](#17-gc-root-correctness)
18. [Coroutine and suspended-stack correctness](#18-coroutine-and-suspended-stack-correctness)
19. [System linker integration](#19-system-linker-integration)
20. [Rustc linker integration](#20-rustc-linker-integration)
21. [Stub linker behavior](#21-stub-linker-behavior)
22. [Native JIT noninterference](#22-native-jit-noninterference)
23. [Native-library noninterference](#23-native-library-noninterference)
24. [Compiler-service and HIR noninterference](#24-compiler-service-and-hir-noninterference)
25. [Packaged Botlish.app acceptance](#25-packaged-botlishapp-acceptance)
26. [Cocoa/Metal graphical acceptance](#26-cocoametal-graphical-acceptance)
27. [Graphical positive controls](#27-graphical-positive-controls)
28. [Process and linked-run parity](#28-process-and-linked-run-parity)
29. [Mutation testing](#29-mutation-testing)
30. [Executable size and performance](#30-executable-size-and-performance)
31. [macOS CI results](#31-macos-ci-results)
32. [Linux x86-64 CI results](#32-linux-x86-64-ci-results)
33. [Linux AArch64 CI results](#33-linux-aarch64-ci-results)
34. [Windows CI results](#34-windows-ci-results)
35. [Documentation and Compilerpedia](#35-documentation-and-compilerpedia)
36. [Remaining limitations](#36-remaining-limitations)
37. [Prerequisites for graphical macOS Icy Tower](#37-prerequisites-for-graphical-macos-icy-tower)
38. [Exact files changed](#38-exact-files-changed)
39. [Commands for reproducing the acceptance](#39-commands-for-reproducing-the-acceptance)

---

## 1. Result

Census candidate A is a supported startup policy. `botlish -native-startup
main-thread -emit-native-executable app.bot` makes a macOS AArch64
executable that runs its ordinary compiled program on the process's
original main thread, with no worker, over a 512 MiB main stack its link
reserves (LC_MAIN, through the system and the rustc linker alike). The
policy is the executable's: one word of the existing `botlish_program`
record, covered by the ABI fingerprint, read before anything else at
startup, an unknown word refused. `worker` stays the default everywhere,
and every other target refuses `main-thread` before anything is written
(NATIVE UNSUPPORTED startup). Nothing else changed: semantics, the C FFI,
contexts, the collector, coroutines, the stack guard, the JIT, linked
runs, native libraries and the stub linker behave as before, and a panic
of the main thread's body is NATIVE BUG, status 1, as the worker's is.

What was executed, and where (section 31 and the sections it names):

* **macOS AArch64** (GitHub's `macos-15`, never a shared Mac): the
  policy's tests (`tests/main-thread-startup.test`: the main thread by
  libpthread's answer, also inside a kept coroutine; LC_MAIN; each linker's
  usable stack; every exhaustion as NATIVE LIMIT STACK; finite recursions
  the worker holds; GC stress; kept coroutines; faults; process semantics
  and the startup report against the worker's), plainly and under GC
  stress; the acceptance tier; the graphical census on the production
  policy with every case as predicted -- the main-thread executable
  **EXECUTED-COCOA** (a Cocoa window, Metal, presented frames, events,
  shutdown, all on the main thread) through Botlish.app's system linker,
  the rustc linker and under GC stress, the same program on the worker
  FAILED-CORRECTNESS as the positive control; Botlish.app building
  main-thread executables, its signature intact (section 25); every
  mutant of the policy that compiles on macOS killed (11 of 11, one of
  them after a test this milestone added for it).
* **Linux x86-64, Linux AArch64, Windows x86-64**: the refusal, the worker
  default unchanged (the whole Tcl suite, golden suites, executables,
  every linker, GC stress), and their mutants killed (Linux x86-64: 19 of
  19 applicable; Windows: 7 of 7).

Not implemented (section 36): main-thread startup on any other target, a
stack-size option, coordination with a host's run loop, an application
bundle, Developer ID signing or notarization of executables, macOS native
libraries, iOS, the graphical Icy Tower build (section 37 lists what it
needs). The census's own evidence is kept apart from this milestone's
(section 2; MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md).

## 2. Starting census findings

MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md established on `macos-15` runners
**[census]**:

* the production executable runs every Botlish instruction and C call on a
  1 GiB worker the process's main thread spawns and joins, and SDL3's
  Cocoa driver refuses it ("No available video device"), while
  `SDL_IsMainThread()` -- initialization-defined -- answers true;
* the same compiled program executed on the process's main thread (the
  experimental `aot::run` running its body on the calling thread) is
  EXECUTED-COCOA: a Cocoa window, Metal, 30 + 3 frames (the last three
  from a kept coroutine's stack), events, shutdown, plain and under GC
  stress, with the rustc and the system linker;
* `NativeStack::current()` already discovers the main thread's stack and
  confirms its guard; the existing guard reports every exhaustion there
  (small and wide frames, Strings held, a `Fn` call, a 9.5 KiB probed
  frame, a coroutine's stack after it yielded) and leaves other faults to
  their signal;
* the default main stack is 8 MiB: three finite recursions the worker holds
  (`down(10^6)`, `wide(10^5)`, `rec(10^5)`) exhaust it; Apple ld's
  `-stack_size` (LC_MAIN) gives the main thread up to 512 MiB on arm64
  (more is refused), with which every probe passes;
* the experiment's one process-semantic regression: a Rust panic on the
  main thread escaped (status 101) instead of NATIVE BUG status 1.

This milestone implements that recommendation (the census's section 30)
and turns its probes into permanent regression tests and a CI gate. The
census's architectural comparison (candidates B and C) is not repeated.

## 3. Final public CLI

```sh
botlish -native-startup main-thread -emit-native-executable app.bot   # macOS AArch64
botlish -native-startup worker -emit-native-executable app.bot        # explicit default
botlish -emit-native-executable app.bot                               # the worker
```

`-native-startup POLICY` (main.tcl's `cliOptions`, group `build`):

| Invocation | Outcome |
|---|---|
| absent | the worker |
| `worker` | the worker (the same executable behavior, record word 0) |
| `main-thread` on macOS AArch64 | the main thread |
| `main-thread` elsewhere | `PATH: the startup policy main-thread is supported for macOS AArch64 native executables only, and this executable is for TARGET. ... (NATIVE UNSUPPORTED startup)`, status 1, nothing written |
| the same policy twice | one choice |
| two different policies | usage error, status 2 (`-native-startup is given twice with different policies`) |
| no value | usage error (`option -native-startup needs an argument (POLICY)`) |
| an unknown policy | usage error (`unknown native startup policy "X" (known: worker main-thread)`) |
| without `-emit-native-executable` (a run, `-backend cranelift`, `-emit-native-library`) | usage error: `-native-startup is an option of -emit-native-executable ...` |
| with `-check` or `-lsp` | their existing refusal of every option they do not take |

The other layers spell the policy the same way: `native::executable HIR
PATH -startup worker|main-thread` (and `native::object`), the driver's
`executable OUT FILE.nir --startup worker|main-thread` (and `object`),
whose default is the worker's and which refuses `--startup` for every other
command (`run`, `bench`, ...: usage, status 2). An explicit choice is never
ignored or replaced.

## 4. Startup policy semantics

| Property | `worker` | `main-thread` |
|---|---|---|
| initial execution thread | a worker the process's main thread starts and joins | the process's main thread |
| default stack capacity | 1 GiB | 512 MiB |
| stack size selected | at run time (`BOTLISH_NATIVE_STACK_BYTES`) | at link time (LC_MAIN) |
| `BOTLISH_NATIVE_STACK_BYTES` | applies | does not apply |
| overflow guard | the existing one | the same existing one |
| coroutine stacks | unchanged | unchanged (8 MiB each, on the same thread) |
| panic | NATIVE BUG, status 1 (the join) | NATIVE BUG, status 1 (`catch_unwind`) |
| targets | all | macOS AArch64 |

The policy is the executable's, fixed when it is emitted: no environment
variable selects it when the executable runs, and nothing infers it from
SDL3, Cocoa, a framework, a C function, a module, a context, a coroutine or
an event loop. An application linking Cocoa may choose the worker; one
linking nothing may choose the main thread. Nothing of the program's
meaning depends on it.

## 5. Target restrictions

`main-thread` is accepted for an executable whose target is macOS AArch64
(`codegen::target::main_thread_startup`: Darwin or macOS and AArch64, by
the executable's own target -- the program's NIR `target` line, which
`check_host` requires to be the host's, else the host's). Every other
target refuses it in `codegen::aot::startup_refusal`, the first thing
`emit_executable` does: before a work directory exists, before any object
or link, so an existing executable at the destination is kept and no
temporary file is left (`mts-cli-refused`, `mts-api-refused` with the
rustc, system, stub and auto linkers **[executed, Linux x86-64]**). The
refusal names the target and the platform reason:

* Linux: "glibc reports no guard below the process's main thread's stack,
  and the stack-overflow guard runs only on a stack whose guard is
  confirmed (NATIVE-STACK-OVERFLOW.md)" -- the census executed this refusal
  on Linux (its section 26);
* Windows: "the main thread's stack is the 1 MiB link.exe reserves unless
  the link reserves more, which no Botlish link does yet";
* every target: "No other target has had main-thread startup's
  acceptance".

It does not say main-thread execution is impossible there, and points at
the worker, supported everywhere. The runtime agrees independently:
`runtime::aot::MAIN_THREAD_STARTUP` (macOS AArch64), and a record that asks
for the main thread on another host is refused at startup (NATIVE STARTUP,
status 1) -- a damaged or moved executable, since the driver never emits
one (`mts-record-damage` **[executed, Linux]**). A unit test pins that the
driver's rule for the host is the runtime's
(`main_thread_startup_is_the_runtimes`). The capability table
(`native/native.tcl`) records `mainThreadStartup {macos-aarch64}`, which
`tests/helpers.tcl`'s `mainThreadStartup` constraint and
`tests/platform/native-status.tcl`'s `main-thread-executable` probe read.

## 6. Representation in botlish_program

The record (`runtime::program::LinkedProgram`) gains one word, the
seventh:

| Offset | Word | Since |
|---|---|---|
| 0 | magic `BOTLPRG1` | NATIVE-LIBRARY-MILESTONE-1.md |
| 8 | the runtime ABI fingerprint | |
| 16, 24 | the descriptor's address and length | |
| 32, 40 | the code table's address and function count | |
| **48** | **the startup policy**: 0 `worker`, 1 `main-thread` | this milestone |

`runtime::program::Startup` is the policy (`word`, `of_word`, `spelling`,
`parse`); an unknown word is refused ("the program record names an unknown
startup policy (N)"), never taken for the default. `codegen`'s
`define_program_record` writes it (`emit_executable_object(program,
startup)`); the policy changes exactly that one byte of the object
(`executable_object_records_the_startup_policy`). A native library's record
is written by the same function with the worker's word, which nothing reads
(`mts-library-record` **[executed, Linux]**). No second startup descriptor,
no generated startup per policy, no environment variable.

## 7. Runtime ABI compatibility

The record's layout is part of the ABI fingerprint: `aotimage::abi_words`,
which `abi_fingerprint` digests, now ends with the record's size (56) and
the startup word's offset (48) (`abi_fingerprint_covers_the_program_record`).
Every startup checks the magic and the fingerprint before it reads the
startup word (`program::linked_startup`), so:

* a new record read by an older runtime archive: refused at the
  fingerprint ("the program was compiled for a different native runtime
  build (NATIVE STARTUP)"), before the word it does not know is read;
* an old record (six words) read by this runtime: refused at the
  fingerprint likewise;
* a record whose word was altered: refused ("names an unknown startup
  policy", or on a host without main-thread startup "asks to run its
  program on the process's main thread"), status 1, nothing on standard
  output (`mts-record-damage`, every linker of the host).

The stub's image format is unchanged (it carries the record, whose length
the image's bounds check reads from `size_of::<LinkedProgram>()`).

## 8. AOT runtime refactor

`runtime::aot` (the experiment's closure, graduated):

```text
start_linked(record)                      rustc startup crate's main;
    linked_startup(record)?                 runtime archive's main
    run(policy, process_argv(), init)       (linked_main); the stub's
                                            loader does the same with
run(policy, argv, init)                     its relocated image
    main-thread elsewhere -> NATIVE STARTUP
    body := init (the Vm, on the thread that runs it)
            -> startup report -> argv snapshot
            -> driver protocol | guard + program -> value | error
    worker:      spawn(BOTLISH_NATIVE_STACK_BYTES) -> join   (panic: NATIVE BUG)
    main-thread: catch_unwind(body) on this thread          (panic: NATIVE BUG)
```

* One body for both policies: VM initialization, the startup report, the
  argument snapshot, the guard, the driver protocol, benchmark repeats,
  the result or error -- never two copies.
* The rustc linker's startup crate (`codegen::aot`'s `STARTUP`) shrinks to
  `std::process::exit(unsafe { aot::start_linked(&botlish_program) })`;
  the system linker's `linked_main` is `rust_process_setup` then the same
  `start_linked`. No hand-written main-thread startup crate.
* The startup report (`BOTLISH_NATIVE_STARTUP_REPORT`) ends in three lines
  after the Vm's own (`startup_lines`): `startup POLICY`,
  `process-main-thread 1|0|unknown` (libpthread's `pthread_main_np` on
  macOS, the thread id against the process id on Linux, `unknown` on
  Windows) and `stack USABLE GUARD` (the stack the Vm recorded with
  `NativeStack::current`).

## 9. Worker-path preservation

The worker path is the previous code moved into the shared body: the same
stack size rule (`BOTLISH_NATIVE_STACK_BYTES`, at least 1 MiB, 1 GiB by
default), the same spawn and join, the same NATIVE BUG and NATIVE STARTUP
reports, the same exit statuses, the same driver protocol and the same
Windows unwind-check summary. The executable test files pass unchanged on
Linux x86-64 with every linker (section 32), and the three linkers' startup
reports stay byte-identical (`tests/system-linker.test`).

## 10. Main-thread startup sequence

```text
dyld -> main (runtime archive's C main | Rust's main)       process main thread
  rust_process_setup (system linker) | lang_start (rustc)
  start_linked: magic, fingerprint, startup word            (no Vm yet)
  run(main-thread): catch_unwind(body) -- no thread spawned
    init: read_linked, Vm::new (NativeStack::current() of the main
          thread: 512 MiB, its guard confirmed), constants, statics,
          frame map
    startup report, argv snapshot
    OverflowGuard::install_executable (or the driver protocol's install)
    entry(&mut vm): compiled Botlish; C calls; coroutines switch stacks
          on this thread
    value -> stdout, or error -> stderr; status
  std::process::exit(status)
```

Nothing is initialized on one thread and moved to another: the Vm, its
thread-local current program and coroutine pool are the main thread's from
the start.

## 11. Panic and error behavior

The census's regression is fixed: on the main thread `run` catches the
body's panic with `catch_unwind` and reports "native executable panicked
(NATIVE BUG)", status 1 -- the worker's join's line and status -- before
the panic could reach the runtime archive's `extern "C" fn main` or Rust's
own startup (status 101). Stack overflow is a signal, never an unwind, and
is the guard's (`NATIVE LIMIT STACK`). The deliberate fault is a program
whose big Int constant's digits are damaged in the executable, so that the
startup's constant installation panics inside the body
(`mts-panic-native-bug`): **[executed, Linux x86-64]** with the system,
rustc and stub linkers on the worker; on macOS with both linkers and both
policies (section 31).

## 12. Main-stack reservation

`codegen::aot::MAIN_THREAD_STACK_BYTES` is 512 MiB, Apple ld's arm64
maximum; `startup_link_args(flavor, startup)` is
`-Wl,-stack_size,0x20000000` for Apple's ld and the main-thread policy,
nothing otherwise. The system linker passes it after `-Wl,-dead_strip`
(`system_link_args`); the rustc linker passes it as `-C
link-arg=-Wl,-stack_size,0x20000000`. Worker executables get nothing; no
other linker flavor ever gets it (`main_thread_startup_link_args`). It is a
reservation of address space -- the kernel maps the stack below the main
thread with one inaccessible guard page -- not memory allocated at startup.
No general stack-size option exists.

**The limit [executed, macOS AArch64]** (census run 41036403542, its
`stack` group, Xcode's ld on `macos-15`): a C program linked with
`-stack_size` 0x4000000, 0x10000000 and 0x20000000 runs with that main
stack, touches it to within 256 KiB of its bottom and faults in its guard
below; 0x40000000 and 0x80000000 do not link (`ld: -stack_size must be <=
512MB on arm64 platforms`). 512 MiB is the largest reservation the linker
accepts.

## 13. LC_MAIN inspection

**[executed, macOS AArch64]** (macos-arm64.yml run 40992453520 at
3c87f83a, the `system linker` job: every executable test file with
`BOTLISH_NATIVE_LINKER=system`, tests/main-thread-startup.test's own links
naming each linker): `mts-main-lc-main` passed -- `otool -l` of a
main-thread executable shows `LC_MAIN ... stacksize 536870912` with the
system and the rustc linker alike, of a worker executable `stacksize 0`
(the default). The same run's smoke job linked one of each in
tests/platform/aot-facts.tcl, whose main-thread executable ran
(`main-thread-run`: exit 0, its value), kept a valid signature
(`main-thread-signature`: `codesign -v`) and exhausted its main stack with
the guard's line (`standalone-main-thread-overflow`). Its
`main-thread-lc-main` check failed on its own parsing: `cmd
LC_MAIN.*?stacksize (\d+)`, a non-greedy expression throughout in Tcl,
read one digit ("5"); it reads from LC_MAIN on now, as the test file does.
With the fix (run 41004334314's smoke job, 9d86232e): `ok main-thread-lc-main
LC_MAIN stacksize: worker 0 main-thread 536870912`, beside
`main-thread-signature`, `main-thread-run` and
`standalone-main-thread-overflow` ("512 MiB main stack: exit 1 ...
NATIVE LIMIT STACK") **[executed, macOS AArch64]**.

## 14. Main-thread native stack discovery

**[executed, macOS AArch64]** (the same job): inside the actual main-thread
executables the startup report's lines are `startup main-thread`,
`process-main-thread 1` (libpthread's `pthread_main_np`) and a `stack`
line with a confirmed guard below the usable stack:

| Linker | usable bytes | why |
|---|---:|---|
| system | 536,870,912 | LC_MAIN's 512 MiB, all of it: the runtime archive's C `main` |
| rustc | 536,854,528 | 512 MiB less one 16 KiB page: Rust's runtime start (`lang_start`) makes the main stack's lowest reported page its own guard (std's `install_main_guard`, the default path on macOS: the page mapped and `mprotect`ed `PROT_NONE`) |

The runtime's discovery (`NativeStack::current`, platform/macos.rs) never
trusts the reported end: it takes the first accessible address at or above
it and confirms the inaccessible run below, so it finds both, and the guard
reports either stack's exhaustion (section 15). This is the census's
observation explained: its C probe saw the reported bottom usable, the
runtime's Rust test binary (Rust's start) one page above it.
`mts-main-identity` and `mts-main-report-parity` first expected the
system linker's value from both linkers and failed on the rustc one; each
linker's value is pinned now (`mtsMainUsable`), the reports compared but
for the `stack` line, and the census harness's `report-main-rustc` expects
the page less. The worker's stack is the same under both linkers.

The census on the production policy (run 41036403542) read the same
reports **[executed, macOS AArch64]**: `report-main` (Botlish.app's system
linker) `startup main-thread`, `process-main-thread 1`, 536,870,912 usable
bytes over a 16 KiB guard; `report-main-rustc` 536,854,528 over 32 KiB
(Rust's page and the kernel's); `report-worker` `startup worker`,
`process-main-thread 0`, the worker's 1,073,754,112 over 16 KiB. Its
`identity` rows agree by Foundation's `NSThread.isMainThread` as well as
libpthread: `id-botlish-main` and `id-botlish-main-rustc` on the main
thread (one thread in the process, the main thread's thread id), every
worker executable and the linked run (`id-botlish-linked-run`) on a second
thread.

## 15. Overflow-guard acceptance

**[executed, macOS AArch64]** (the same job): `mts-main-overflow` -- the
small frame, a String held, six Ints held, a call through a `Fn`, a
9.5 KiB probed frame and a coroutine's stack after it yielded, each `error
{NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}`,
status 1, on the main thread -- `mts-main-rustc-overflow` (the rustc
link's main stack) and `mts-main-fault` (C's write through a null pointer
ends by its signal on both policies, never `NATIVE LIMIT STACK`) passed;
aot-facts' `standalone-main-thread-overflow` likewise. The census's
candidate-A rows on the production policy: section 31.

## 16. Stack-capacity acceptance

**[executed, macOS AArch64]** (the same job): `mts-main-capacity` passed --
`down(10^6)` 1000000, `keep(10^5)` 200000, `wide(10^5)` 0, `rec(10^5)`
100000 and 100 frames of 9.5 KiB return the worker's values on the 512 MiB
main stack, the recursions the census showed the default 8 MiB main stack
exhausting -- and `mts-main-stack-bytes`: with
`BOTLISH_NATIVE_STACK_BYTES=1048576` a worker's `down(10^5)` is NATIVE
LIMIT STACK while the main thread's, sized by the link, returns 100000.
The 8 MiB control (a main-thread executable linked without the stack
size) is the census harness's: section 31.

## 17. GC root correctness

**[executed, macOS AArch64]** (the same job, plain): `mts-main-gc-stress`
passed -- under `BOTLISH_NATIVE_GC_STRESS=1` kept, resumed and abandoned
coroutines with Strings in their frames, `keep(3000)`, frames of 9.5 KiB
holding a String and closures holding managed values give the worker's
values on the main thread -- and `mts-main-report-parity`'s Vm report
(constants, shapes, statics, stack maps) is the worker's under both
policies and both linkers. The whole file under GC stress is the
`main-thread-startup` job's (section 31).

## 18. Coroutine and suspended-stack correctness

**[executed, macOS AArch64]** (the same job): `mts-main-kept-coroutines`
passed with both linkers and both policies (`[[0, [1, 4, -1]], [4, 5, 6,
7, -1], [110, 34, 0, 0, 3]]`: a handle passed to another function, four
suspended frames of a recursive yielding function, two coroutines abandoned
while suspended), and `mts-main-identity`'s coroutine, kept on the general
runtime, answered `pthread_main_np() == 1` after it was resumed: a
coroutine's stack is switched to on the process's main thread, so its C
calls are the main thread's. The coroutine's stack exhaustion is
`mts-main-overflow`'s last case (section 15).

## 19. System linker integration

The system linker links the same program object (its record's word the
policy) with the precompiled runtime archive, whose `main` reaches
`start_linked`; the only argument the policy adds is LC_MAIN's stack size
(section 12). No generated C startup, no Rust at application build time.

## 20. Rustc linker integration

The rustc linker's startup crate is the same text for both policies
(`start_linked`), compiled once per link as before; the policy adds the
`-C link-arg` of section 12.

## 21. Stub linker behavior

The stub is Linux x86-64's, where `emit_executable` refuses the main-thread
policy before choosing a linker; `link_stub` refuses it again itself. The
stub's loader reads the record's policy (`aotimage::Loaded::startup`) and
`run` refuses a main-thread record on Linux at startup (`mts-record-damage`
with the stub **[executed, Linux x86-64]**). Its worker-startup programs
are unchanged: `tests/aot-stub-linker.test` and the executable test files
under `BOTLISH_NATIVE_LINKER=stub` (section 32).

## 22. Native JIT noninterference

The driver's JIT keeps its own worker (`native/src/main.rs`'s `main`,
unchanged). `--startup` is refused for `run` and `bench`, and main.tcl
refuses `-native-startup` without `-emit-native-executable`, `-backend
cranelift` included (`mts-cli-usage`, `mts-driver-option`).

## 23. Native-library noninterference

A native library's record carries the worker's word (`emit_library_object`)
and nothing reads it: `runtime::library` makes the Vm on the host's calling
thread as before, its thread affinity and reentrancy checks unchanged.
`tests/native-library.test` passes unchanged **[executed, Linux x86-64]**;
macOS native libraries remain refused **[not implemented]**.

## 24. Compiler-service and HIR noninterference

The policy enters at native emission only: no surface syntax, no HIR, no
HIR interchange field, no front-end cache key, no compiler-service fact.
`-check` refuses the option; a program's diagnostics, its HIR and its
`.hirx` are the same whichever policy it is later emitted with.

## 25. Packaged Botlish.app acceptance

**Botlish.app's compiler builds main-thread executables [executed, macOS
AArch64]** (census run 41036403542 at 44a5b4fa): the application built
from the branch (`single/macos/build.sh`, signed ad hoc) compiled every
"main" probe of the census with its own `botlish -native-startup
main-thread -emit-native-executable` -- the system linker, the
application's `auto` for a program that calls C, the runtime archive in
its Resources, no rustc -- and every one ran on the process's main thread
with the 512 MiB stack (sections 14 and 26); after the census the
application's signature still verified (`codesign --verify --deep
--strict`, the job's last check), the compiler having written nothing
into it. A main-thread and a worker executable of the same program are
the same size (848,120 bytes for the identity program, 3,675,080 for the
SDL one): the policy is a word of the record and a link flag.

**Without the checkout, Cargo or rustup, from a path with a space and
non-ASCII characters [executed, macOS AArch64]** (macos-arm64.yml run
41036399870 at 44a5b4fa, the `main-thread-startup` job). The application
from the run's `app` job, verified by its checksum and `codesign --verify
--deep --strict`, was unpacked to `$RUNNER_TEMP/Prögram Fïles/Botlish.app`;
the checkout, `~/.cargo` and `~/.rustup` were moved away and every PATH
directory holding `cargo`, `rustc` or `rustup` left out, the step requiring
all three gone. From a directory of its own (`startup kit`) the
application's `botlish` built `-native-startup main-thread
-emit-native-executable identity.bot` (0.31 s) and the same program with
the default (0.34 s), a program that calls `pthread_main_np` through `extern
c fn`, directly and from inside a kept coroutine:

* both are `Mach-O 64-bit executable arm64`; `otool -l`: the main-thread
  one's LC_MAIN `stacksize 536870912`, the worker's `stacksize 0`;
* the main-thread executable prints `[1, 1]` (the main thread, also in the
  coroutine), the worker `[0, 0]`;
* the main-thread one's startup report ends in `startup main-thread`,
  `process-main-thread 1`, `stack 536870912 16384`;
* the application's signature verified afterwards, and again at the job's
  end, after the strict census and the policy's tests had used it.

The first attempt (run 41004334314) stopped at the step's own check: the
runner's rustup is Homebrew's, whose proxies stay on PATH without
`~/.rustup` (section 31).

## 26. Cocoa/Metal graphical acceptance

**EXECUTED-COCOA [executed, macOS AArch64]** (census run 41036403542,
`macos-15`, the runner's graphical session: one 1024x768 display, the
console user logged in). The census's SDL program -- the pinned static
SDL3 3.4.18 linked into a Botlish executable through the link plan (its
22 libraries the system's and Apple's frameworks, Cocoa, Metal and AppKit
among them, none SDL3's: `deps-main-sdl`), a window, a Metal renderer, 30 presented frames of
which 3 from inside a kept coroutine on its own stack, a pushed quit event
polled back, the renderer, window and SDL shut down -- compiled by
Botlish.app with `-native-startup main-thread` and run with no
environment variable:

| Case | Build | Class | What the fixture saw |
|---|---|---|---|
| `a-main-cocoa` | Botlish.app, system linker | EXECUTED-COCOA | driver `cocoa`, a Cocoa window, renderer `metal`, 30 frames presented (3 in the coroutine), 7 events, the quit polled, everything destroyed; every SDL stage with `pthread_main_np() == 1`; the window captured: its centre (255, 0, 255), 89.5 % of it the drawn colour |
| `a-main-cocoa-gc` | the same, `BOTLISH_NATIVE_GC_STRESS=1` | EXECUTED-COCOA | the same, a collection at every allocation |
| `a-main-rustc-cocoa` | the checkout, rustc linker | EXECUTED-COCOA | the same |
| `t-a-main-sdl` (five timed runs) | Botlish.app | EXECUTED-COCOA | the same, each run (section 30) |
| `s-main-sigterm-sdl` | Botlish.app | EXECUTED-COCOA | SIGTERM one second in: SDL's handler, installed on the main thread, makes it a quit event, polled back; status 0, everything shut down |
| `a-main-headless`, `-gc` | Botlish.app, `SDL_VIDEODRIVER=dummy` | EXECUTED-HEADLESS | the dummy driver on the main thread: never counted as Cocoa |

The class is the census's unchanged classifier (MACOS-GRAPHICAL-MAIN-
THREAD-CENSUS.md, section 19): EXECUTED-COCOA only when SDL's video driver
is `cocoa`, the window has a Cocoa window, every stage ran where
`pthread_main_np()` -- never SDL's own answer -- said main, frames were
presented, the pushed quit came back and everything was shut down; its
self-tests (an incomplete record, a dummy driver claiming Cocoa, Cocoa off
the main thread, a window the fixture did not see, a quit never polled)
classify as they must in the same run. Nothing in the runtime knows SDL,
Cocoa or AppKit: the executable is an ordinary Botlish program whose
startup word is the main thread's.

## 27. Graphical positive controls

**[executed, macOS AArch64]** (census run 41036403542): each control fails
where it must, on the same host, in the same run --

| Case | What runs | Class (as predicted) | Why it fails |
|---|---|---|---|
| `a-worker-cocoa` | the very program of `a-main-cocoa`, built by Botlish.app with the default (worker) startup | FAILED-CORRECTNESS | SDL_Init: "No available video device"; `pthread_main_np() == 0` at every stage, no window, nothing presented |
| `bl-worker-cocoa`, `-hint` | the census's production baseline on the worker (with `SDL_VIDEODRIVER=cocoa`) | FAILED-CORRECTNESS | "No available video device"; "cocoa not available" |
| `c-worker-cocoa` | C's own SDL program on a pthread | FAILED-CORRECTNESS | "No available video device" |
| `c-appkit-worker` | an NSWindow made on a pthread | FAILED-CORRECTNESS | AppKit: "NSWindow should only be instantiated on the main thread!" |
| `c-main-cocoa`, `c-appkit-main` | the same C programs on the main thread | EXECUTED-COCOA, EXECUTED-THREAD | the reference the Botlish main-thread executable matches |
| `pc-main-baddriver` | `a-main-cocoa`'s executable with `SDL_VIDEODRIVER=nonexistent` | FAILED-CORRECTNESS | SDL_Init fails: never a window, even on the main thread |
| `pc-nopump`, `pc-nodestroy`, `pc-baddriver` | C controls: the quit never polled, no cleanup, a missing driver | FAILED-CORRECTNESS | the classifier notices each missing stage |
| `pc-dummy-not-cocoa` | the dummy driver on the main thread | EXECUTED-HEADLESS | a headless run is never Cocoa |
| `a-main-8mib-*` | the main-thread program objects linked without `-stack_size` (8 MiB) | NATIVE LIMIT STACK on the three recursions the 512 MiB stack holds | the reservation is what holds them, and the guard reports the smaller stack's exhaustion too |

The worker's Cocoa failure is the reason for the policy: the same source,
the same compiler and the same SDL fail on the worker and succeed on the
main thread, the startup word being the only difference. The census's
candidates B (a dispatcher to the main thread) and C (SDL's main
callbacks) ran on the experimental build beside it as before (B's Cocoa
dispatch and C's callbacks EXECUTED-COCOA, B's two deadlock controls
FAILED-CORRECTNESS as predicted); they are the census's record, not this
milestone's.

## 28. Process and linked-run parity

**[executed, macOS AArch64]** (run 40992453520's `system linker` job):
`mts-main-process-semantics` passed -- a declared error handled, a runtime
error (status 1, its line), the driver protocol (`BOTLISH_NATIVE_RESULT`,
and `BOTLISH_NATIVE_RUNS=3`'s timing lines), an unwritable startup report
(NATIVE IO, status 2), the overflow line and the program's arguments are
the same under both policies with both linkers -- as did
`mts-main-darwin-io` (Darwin I/O's `write`, standard input through `read`,
and a failing `read`'s -1 with errno 9 on both threads),
`mts-panic-native-bug` (a Rust panic of the body: "native executable
panicked (NATIVE BUG)", status 1, never Rust's 101, both linkers, both
policies), `mts-main-link-failure` (a failed main-thread link keeps the
previous file), `mts-worker-identity` and `mts-linked-run-worker` (a
program that calls C, run by main.tcl's native backend, runs on its
worker: `[0, 0]`). **[executed, Linux x86-64]**: section 32.

## 29. Mutation testing

The policy's mutants extend the existing campaigns -- `audit/native-aot`
(23 new or refreshed) and `audit/native-stack` (one) -- with
`tests/main-thread-startup.test` among both harnesses' detectors; each
mutant runs in a private tree, and one that does not build or no longer
applies is never counted as killed. Three native-aot mutants had gone
stale (two before this milestone: `startup-no-guard`'s and
`sys-runtime-variable-ignored`'s texts; one by it,
`sys-startup-failure-succeeds`, whose record read moved into
`start_linked`); each was rewritten as a mutant of the same rule.
`tests/platform/tier.tcl`'s `native-aot-mutants` and `native-stack-mutants`
take `=NAME,...` so a Tier C push can run the ones only macOS or Windows
compiles differently.

**Linux x86-64 [executed]**: `audit/native-aot/tools/mutate.tcl -only` the
23: 19 killed, 0 survived, 4 skipped (macOS's or Windows' code).

| Mutant | Specification row | Linux x86-64: killed by |
|---|---|---|
| `cli-drops-main-thread` | CLI silently drops main-thread | `mts-cli-refused` (on macOS `mts-cli-main-thread`: below) |
| `cli-default-main-thread` | worker default changed to main | `mts-cli-default-is-worker`, native-executable.test (8), workload-2048's executable |
| `api-replaces-main-with-worker` | driver replaces main-thread with worker | `mts-api-refused`, `mts-cli-refused`, native-status's `main-thread-executable` |
| `api-default-main-thread` | worker default changed to main | native-executable.test (10), argv.test (13), system-linker.test (13), aot-facts |
| `driver-default-main-thread` | worker default changed to main | `mts-driver-option`, native-executable-stack-overflow, system-linker-no-rust-toolchain |
| `driver-startup-for-run` | main option leaks into JIT | `mts-driver-option` |
| `linked-run-main-thread` | (linked runs stay the worker's) | `mts-linked-run-worker`, system-linker-linked-run, native-status's C probes |
| `policy-not-recorded` | startup policy not recorded | `executable_object_records_the_startup_policy` |
| `library-record-main-thread` | main option changes native-library calls | `mts-library-record` |
| `record-policy-ignored` | record decoding ignores policy | `linked_program_startup_policy`, `mts-record-damage` |
| `unknown-policy-accepted` | unknown policy accepted | `linked_program_startup_policy`, `mts-record-damage` |
| `fingerprint-ignores-record` | ABI fingerprint ignores record layout | `abi_fingerprint_covers_the_program_record` |
| `system-link-no-stack-size` | system linker omits LC_MAIN stack size | `main_thread_startup_link_args` |
| `linux-accepts-main-thread` | unsupported Linux target accepts main mode | `main_thread_startup_refusal`, `mts-api-refused`, `mts-cli-refused`, `mts-driver-option`, native-status |
| `runtime-main-thread-on-linux` | (the runtime's own refusal) | `main_thread_startup_refusal`, `mts-record-damage` |
| `stub-ignores-policy` | stub interprets main as supported | `mts-record-damage` (the stub's damaged record) |
| `startup-no-guard` (refreshed) | -- | native-executable.test's overflows, aot-facts' standalone overflows |
| `sys-runtime-variable-ignored` (refreshed) | -- | system-linker-runtime-failures |
| `sys-startup-failure-succeeds` (refreshed) | -- | system-linker-damaged-description, `mts-record-damage` |
| `rustc-link-no-stack-size` | rustc linker omits LC_MAIN stack size | macOS only (skipped here) |
| `main-thread-on-a-worker` | main-thread mode spawns a worker; VM initialized on a worker | macOS only |
| `main-thread-panic-escapes` | main-thread panic escapes | macOS only |
| `windows-accepts-main-thread` | unsupported Windows target accepts main mode | Windows only |
| `main-thread-unguarded` (native-stack) | main-thread overflow guard omitted | macOS only |

The census's "coroutine switch loses guarded stack" row is the existing
native-stack mutants of publication (`publish-before-switch`,
`start-publishes-thread-stack`, `resume-not-published`,
`yield-not-restored`), whose detectors now include the main-thread test;
"compiler bundle omits updated runtime" is the existing macOS application
mutants (`sys-runtime-bundle-*`, `audit/macos-app`), unchanged.

**macOS AArch64 [executed]** (macos-arm64.yml run 40960887650, Tier C
shard 1, 95e3648f: `tier.tcl native-aot-mutants=... native-stack-mutants=...`
on `macos-15`): native-aot 9 mutants reported 8 killed, 0 survived, 1
skipped (`windows-accepts-main-thread`, Windows' code); native-stack 3 of
3 killed.

| Mutant | macOS, run 40960887650 (a tree without `audit/`; see below): what failed |
|---|---|
| `rustc-link-no-stack-size` | `mts-main-lc-main` and the other main-thread tests of the rustc link (10), aot-facts' `main-thread-lc-main` |
| `system-link-no-stack-size` | `main_thread_startup_link_args`, main-thread-startup.test (10, `mts-main-lc-main` among them), aot-facts |
| `main-thread-on-a-worker` | main-thread-startup.test (9: `mts-main-identity`, `mts-main-capacity`, `mts-main-overflow`, ...), aot-facts, native-status's `main-thread-executable` |
| `main-thread-panic-escapes` | main-thread-startup.test (10), aot-facts |
| `cli-drops-main-thread` | main-thread-startup.test (9), aot-facts' `main-thread-lc-main` |
| `api-replaces-main-with-worker` | main-thread-startup.test (10), aot-facts, native-status |
| `record-policy-ignored` | `linked_program_startup_policy`, main-thread-startup.test (10), aot-facts, native-status |
| `policy-not-recorded` | `executable_object_records_the_startup_policy`, main-thread-startup.test (10, `mts-driver-option` among them), aot-facts, native-status |
| `main-thread-unguarded` (native-stack) | main-thread-startup.test (5: `mts-main-identity`, `mts-main-overflow`, `mts-main-process-semantics`, `mts-main-report-parity`, `mts-main-rustc-overflow`) |
| `macos-reported-bottom-trusted`, `macos-guard-assumed` (native-stack, existing) | native_stack's main-thread and pthread checks, as before |

**That run's native-aot verdicts are not evidence.** The native-aot
harness's private tree left out `audit/`, so every main-thread test that
runs a census program (`mts-main-capacity`, `-gc-stress`,
`-kept-coroutines`, `-overflow`, `-process-semantics`, ...) failed in it
for every mutant -- and would have on the unmutated tree, which the harness
never ran; aot-facts' `main-thread-lc-main` failed for every mutant too,
by its own `LC_MAIN` parse (section 13). A kill counted only from those
failures is none: `rustc-link-no-stack-size`, `main-thread-on-a-worker`
and `main-thread-panic-escapes` (the three only macOS compiles) and
`cli-drops-main-thread` had no other detector in that run, and the re-run
below shows the last of them surviving; the others were also killed by a
unit test or by native-status, which read no census program. Fixed: the tree
holds what the detectors read (`audit/`, `bench/`, `service/` and `lsp/`,
as audit/native-stack's does), and the harness now runs every detector on
the unmutated tree first and judges no mutant unless that baseline passes.
On Linux x86-64 the fixed harness's baseline passes and its kills are the
earlier run's (`-only linux-accepts-main-thread,policy-not-recorded`: 2 of
2, by the same detectors) **[executed]**; on Linux no main-thread test
reads a census program (they are macOS's), so the 19 Linux verdicts above
stand. The native-stack harness's tree was complete (it copies `audit/`):
`main-thread-unguarded`'s five failures, with every capacity, GC and
coroutine test passing beside them, are a kill.

**The re-run on macOS with the fixed harness [executed, macOS AArch64]**
(macos-arm64.yml run 41004334314 at 9d86232e, Tier C, `macos-15`):
`BASELINE (the unmutated tree): ok`; native-aot 8 mutants, 7 killed, **1
survived** (`cli-drops-main-thread`); native-stack 3 of 3 killed.

| Mutant | macOS, run 41004334314: killed by |
|---|---|
| `rustc-link-no-stack-size` | `mts-main-lc-main`, `mts-main-identity`, `mts-main-rustc-overflow`, aot-facts' `main-thread-lc-main` |
| `system-link-no-stack-size` | `main_thread_startup_link_args`, `mts-main-capacity`, `mts-main-identity`, `mts-main-lc-main` |
| `main-thread-on-a-worker` | `mts-main-capacity`, `mts-main-identity`, `mts-main-report-parity`, `mts-main-rustc-overflow`, `mts-main-stack-bytes`, native-status's `main-thread-executable` |
| `main-thread-panic-escapes` | `mts-panic-native-bug` |
| `api-replaces-main-with-worker` | `mts-main-identity`, `mts-main-lc-main`, `mts-main-report-parity`, `mts-main-stack-bytes`, aot-facts, native-status |
| `record-policy-ignored` | `linked_program_startup_policy`, `mts-main-identity`, `mts-main-report-parity`, `mts-main-stack-bytes`, `mts-record-damage`, native-status |
| `policy-not-recorded` | `executable_object_records_the_startup_policy`, `mts-driver-option`, `mts-main-identity`, `mts-main-report-parity`, `mts-main-stack-bytes`, native-status |
| `cli-drops-main-thread` | **survived**; killed by `mts-cli-main-thread` since b05d000d (run 41029861079) |
| `main-thread-unguarded` (native-stack) | `mts-main-overflow`, `mts-main-process-semantics`, `mts-main-rustc-overflow` |
| `macos-reported-bottom-trusted`, `macos-guard-assumed` (native-stack, existing) | native_stack's main-thread and pthread checks |

Each kill now names the tests the mutant breaks and nothing else: the
capacity, GC-stress and coroutine tests that failed for every mutant of
the incomplete tree pass beside them. The three only macOS compiles are
killed by tests of what they break -- the rustc link's stack by its
`LC_MAIN` and its overflow at depth, the worker by the thread's identity
and the stack it was given, the escaping panic by Rust's status 101 where
NATIVE BUG is expected.

`cli-drops-main-thread` survived, and the earlier run's "kill" of it was
the incomplete tree's alone. On Linux and Windows `mts-cli-refused` kills
it (the mutant builds the worker's executable where the refusal is
expected); on macOS no test built a main-thread executable through
main.tcl -- `mts-main-*` build theirs through `native::executable`, and the
census harness, which runs `botlish -native-startup main-thread`, is not
a detector of the harness. Answered with a test, not by weakening the
mutant: `mts-cli-main-thread` (b05d000d) builds `-native-startup
main-thread` executables through main.tcl, once and repeated, and requires
the record's word 1, the startup report's `startup main-thread` and
`process-main-thread 1`, and the run's output and status. Against the
mutant on macOS (run 41029861079 at 4d449294, Tier C `native-aot-mutants=
cli-drops-main-thread main-thread-startup.test`): `BASELINE (the unmutated
tree): ok`, then `KILLED cli-drops-main-thread ... main-thread-startup.test
(1 failed: mts-cli-main-thread)`; the file itself on interp and compile, 24
tests, 21 passed, 3 skipped, 0 failed **[executed, macOS AArch64]**. Every
native-aot and native-stack mutant of the policy that applies on macOS is
killed.

**Windows x86-64 [executed]** (windows-x86_64.yml run 40960887683, Tier C
shard 1): 5 killed, 0 survived, 4 skipped -- and `windows-accepts-main-thread`
among the skipped, "not compiled differently for windows nt-x86_64". The
harness named a Windows host by Tcl's `tcl_platform(os)`, "Windows NT",
so no `%% windows-x86_64` mutant of audit/native-aot ever applied on
Windows (`c-calls-refused-on-windows`, from WINDOWS-X86-64-MILESTONE-2.md,
neither; no report counted it). Fixed: the host is `windows-x86_64` there,
as audit/c-ffi's and audit/native-link-plan's harnesses name it.

With the fixed harness (windows-x86_64.yml run 40992453597 at 3c87f83a,
Tier C shard 1; the baseline passed, else no mutant would have been judged):
10 mutants, 7 killed, 0 survived, 3 skipped (macOS's code) **[executed,
Windows x86-64]** --

| Mutant | Windows: killed by |
|---|---|
| `windows-accepts-main-thread` | `main_thread_startup_refusal`, main-thread-startup.test (the refusal tests), native-status's `main-thread-executable` |
| `c-calls-refused-on-windows` (WINDOWS-X86-64-MILESTONE-2.md's, its first run on Windows) | system-linker.test, aot-facts' `c-call-run`, native-status's C probes (`c-call`, `c-access-violation`, `c-byte-borrow`, `windows-write`, `windows-io`, `windows-executable`) |
| `cli-drops-main-thread`, `api-replaces-main-with-worker`, `record-policy-ignored` | main-thread-startup.test (the refusal and the damaged record), native-status, `linked_program_startup_policy` |
| `policy-not-recorded`, `system-link-no-stack-size` | their unit tests |

That run printed a failing test file as "(0 failed: )": its count of
failures was right (the verdict reads it), but the names were not, the
harness reading the child's CRLF lines untranslated; it reads them as LF
lines now.

## 30. Executable size and performance

**Worker executables against the tree before the milestone [executed,
Linux x86-64]** (e43a37fe, built beside this tree; three programs, every
host linker; medians of interleaved runs on the 4-core sandbox, 400 runs of
`value`, 41 of `fib`, 31 of `deep`):

| Program | Linker | Size before | Size after | Median before | Median after |
|---|---|---:|---:|---:|---:|
| `40 + 2` | system | 9,942,672 | 9,973,056 | 1.66 ms | 1.69 ms |
| | rustc | 10,046,944 | 10,069,648 | 1.66 ms | 1.70 ms |
| | stub | 10,440,852 | 10,472,812 | 1.83 ms | 1.86 ms |
| `fib(30)` | system | 9,942,744 | 9,973,136 | 7.45 ms | 7.72 ms |
| | rustc | 10,047,296 | 10,069,992 | 7.46 ms | 7.74 ms |
| | stub | 10,440,972 | 10,472,932 | 7.92 ms | 8.00 ms |
| `down(10^6)` | system | 9,957,360 | 9,991,848 | 50.52 ms | 50.60 ms |
| | rustc | 10,061,144 | 10,083,936 | 51.79 ms | 52.10 ms |
| | stub | 10,441,322 | 10,473,282 | 51.35 ms | 51.14 ms |

* Every executable grows by 22-34 KB (0.2-0.3 %): the runtime's policy
  code that every executable carries (the record's policy read, the
  main-thread body behind `catch_unwind`, the report's three lines), one
  record word, and nothing per program. Every output and status is
  identical.
* Startup (`40 + 2`) costs about 0.03 ms more of a 1.7 ms run, the same on
  every linker. The two compute-bound programs run the same machine code:
  `fib`'s two functions are instruction for instruction the program before
  the milestone's, at other addresses (the runtime before them grew), so
  their spread -- from -0.4 % to +3.7 %, the rustc and system links
  slower, the stub's not -- is placement and the shared machine's noise,
  not a cost of the policy, which runs nothing after the program starts.

**The main thread against the worker on macOS [executed, macOS
AArch64]** (census run 41036403542, its `timing` section: five repetitions
of each case on one `macos-15` runner, medians with [min, max]; the
programs built by Botlish.app's system linker but the C reference):

| Case | wall ms | entry since exec ms | SDL init ms | frame ms | SDL_PumpEvents us | threads |
|---|---|---|---|---|---|---|
| identity, worker | 18.1 [10.5, 22.7] | 13.9 [9.3, 20.4] | - | - | - | 2 |
| identity, main thread | 11.0 [8.2, 12.2] | 10.4 [7.5, 10.9] | - | - | - | 1 |
| SDL, main thread, Cocoa (EXECUTED-COCOA) | 1934.8 [1786.9, 2152.5] | 13.1 [10.6, 24.8] | 92.0 [71.7, 157.5] | 50.6 [49.4, 56.8] | 9.83 [5.36, 12.73] | 5 |
| SDL, main thread, headless | 2081.5 [1651.8, 3428.6] | 17.8 [14.6, 37.6] | 0.20 [0.17, 0.24] | 64.6 [49.0, 102.3] | 0.17 [0.09, 0.21] | 3 |
| SDL, worker, headless | 2846.6 [2464.3, 2932.7] | 13.9 [10.0, 21.2] | 0.16 [0.12, 0.28] | 84.4 [72.0, 88.4] | 0.10 [0.07, 0.17] | 4 |
| SDL, main thread, headless, GC stress | 2741.9 [2490.3, 3280.9] | 8.0 [6.5, 10.1] | 0.10 [0.10, 0.22] | 85.5 [73.1, 97.4] | 0.09 [0.08, 0.09] | 3 |
| SDL, worker, headless, GC stress | 2855.2 [2035.7, 2946.2] | 7.6 [6.7, 9.2] | 0.10 [0.10, 0.11] | 82.2 [61.5, 93.5] | 0.09 [0.08, 0.10] | 4 |
| kept coroutines, GC stress, main thread | 2.67 [2.56, 6.93] | - | - | - | - | - |
| kept coroutines, GC stress, worker | 3.01 [2.88, 6.72] | - | - | - | - | - |
| C's SDL program, main thread, Cocoa | 2692.2 [2500.6, 3126.2] | 12.0 [7.6, 37.0] | 44.9 [42.0, 46.8] | 85.2 [79.8, 100.8] | - | 6 |

* The main-thread executable has one thread fewer -- the worker's -- and
  nothing else measurable here: startup, frames and the GC-stressed runs
  of the two policies overlap within their ranges on a shared runner, and
  this table claims no speed-up for either. Frame times are the census
  program's own pacing over 30 frames, not a rendering benchmark.
* A Botlish main-thread executable's Cocoa run costs what C's does
  (SDL init 92 against 45 ms, frames 51 against 85 ms, both within the
  runner's spread); `SDL_PumpEvents` on the main thread with a real
  window is about 10 us.
* Sizes: a main-thread and a worker executable of one program and linker
  are the same number of bytes (identity 848,120 by the system linker and
  924,312 by the rustc linker under both policies; the SDL program
  3,675,080); the policy is the record's word and a link flag.

## 31. macOS CI results

**Run 41004334314** (macos-arm64.yml, `workflow_dispatch` at 9d86232e,
`tier full`, Tier C `native-aot-mutants=...` and `native-stack-mutants=...`;
every job on `macos-15` but the Linux control) **[executed]**:

| Job | Result |
|---|---|
| Botlish.app (the distribution: build, verify, smoke, FFI smoke, app-test, compare, bench) | passed |
| smoke (Tier A: the Rust unit tests, native_stack, native-status, aot-facts with the fixed `LC_MAIN` parse, the smoke tier) | passed |
| acceptance (Tier B), shard 1/2 | passed |
| acceptance (Tier B), shard 2/2 | passed: 120 Tcl test files on interp, 54 golden suites on four backends, 0 failed |
| system linker (its tests, the executable and C test files system-linked, both under GC stress) | passed |
| Botlish.app without developer tools | passed |
| static SDL3 through Botlish.app | passed |
| linux control (Tier A, ubuntu x86-64) | passed |
| full (Tier C), shard 1/3: the mutants | failed: 1 native-aot mutant survived (section 29); the baseline passed |
| full (Tier C), shards 2/3 and 3/3 | nothing to run (every item in shard 1) |
| main-thread startup | failed in its packaged step's own setup, before the compiler ran: Homebrew's rustup proxies stayed on PATH (below); the census step was skipped; `tests/main-thread-startup.test` passed, plainly and under GC stress |

`tests/main-thread-startup.test` on macOS AArch64 at 9d86232e (the job's
test step): 23 tests, 20 passed, 3 skipped (two of `mainThreadRefused`,
one of `nativeLibraries`: a native library is Linux's), 0 failed --
the same under `BOTLISH_NATIVE_GC_STRESS=1` **[executed]**.

The packaged step moved `~/.cargo` and `~/.rustup` away and then required
`cargo` and `rustc` to be gone from PATH; the runner's rustup is Homebrew's,
whose proxies (`/opt/homebrew/opt/rustup/bin/cargo`) stay on PATH without
`~/.rustup`, so the check stopped the step. The step now leaves out every
PATH directory holding `cargo`, `rustc` or `rustup` for its duration and
requires all three gone (4d449294).

**Run 41029861079** (macos-arm64.yml at 4d449294, `tier full`, Tier C
`native-aot-mutants=cli-drops-main-thread main-thread-startup.test`)
**[executed]**: Botlish.app, smoke, acceptance 1/2, system linker,
Botlish.app without developer tools and the Linux control passed; Tier C
killed `cli-drops-main-thread` (section 29) and passed
`tests/main-thread-startup.test` on interp and compile (24 tests, 21
passed, 3 skipped, 0 failed). Cancelled before its main-thread startup
job ran: that job's census step would have run the harness bug below.

**The census on the production policy, first attempt** (the census
workflow, run 41029857631 at 4d449294) **[executed]**: every candidate-A
case up to the semantics group ran as predicted -- the worker's, the main
thread's (Botlish.app's system linker), the rustc linker's and the 8 MiB
control's depths, overflows, kept coroutines, GC stress, faults and large
frames (the control exhausting exactly the three recursions the census
measured) -- and then the harness failed: candidate A's depth loop named
its expectation `want`, the name of `cases()`'s group filter, so
`want("semantics")` called a dictionary (TypeError). Fixed (44a5b4fa); the
harness's Linux dry run (every group the main-thread startup job selects,
`--strict`, the checkout's compiler; on Linux every main-thread row is a
predicted FAILED-BUILD) completes with no case not as predicted
**[executed, Linux x86-64]**.

**The census on the production policy** (the census workflow, run
41036403542 at 44a5b4fa, `repeat 5`) **[executed, macOS AArch64]**: every
group -- env, identity, stack, c-graphical, botlish-baseline, candidate A
(production), semantics, startup, candidate B and C (the experimental
build), controls, timing -- 170 records: EXECUTED-COCOA 12,
EXECUTED-HEADLESS 13, EXECUTED-THREAD 125, FAILED-CORRECTNESS 13 (each a
predicted one: sections 26 and 27), FAILED-BUILD 2 (the linker's 512 MB
limit), UNAVAILABLE-GUI 0, NOT-TESTED 0; **not as predicted: none**. The
production tree and Botlish.app's signature were unchanged after it.

**Run 41036399870** (macos-arm64.yml, `workflow_dispatch` at 44a5b4fa,
`tier acceptance`) **[executed]**: every job passed --

| Job | Result |
|---|---|
| Botlish.app (build, verify, smoke, FFI smoke, app-test, compare, bench) | passed |
| smoke (Tier A) | passed |
| acceptance (Tier B), shard 1/2 | passed: 121 Tcl test files on interp, 55 golden suites, 2 checks, 0 failed |
| acceptance (Tier B), shard 2/2 | passed: 120 Tcl test files on interp, 54 golden suites, 0 failed |
| system linker (its tests, the executable and C test files system-linked, both under GC stress) | passed |
| Botlish.app without developer tools | passed |
| static SDL3 through Botlish.app | passed |
| linux control (Tier A, ubuntu x86-64) | passed |
| **main-thread startup** | passed: the packaged step (section 25); the strict census -- env, identity, stack, c-graphical, botlish-baseline, candidate A, semantics, startup, controls, timing: EXECUTED-COCOA 8, EXECUTED-HEADLESS 11, EXECUTED-THREAD 120, FAILED-CORRECTNESS 9, FAILED-BUILD 2, **not as predicted: none**; `tests/main-thread-startup.test` 24 tests, 21 passed, 3 skipped, 0 failed, plainly and under `BOTLISH_NATIVE_GC_STRESS=1`; the application untouched |

With run 41029861079's Tier C (the mutants, section 29; at 4d449294, which
differs from 44a5b4fa in `census.py` alone) and the census workflow's run
41036403542, every macOS acceptance the milestone names has run on the
branch's final code; the commits after 44a5b4fa change only this report.
Linux and Windows CI ran earlier (sections 32-34: 95e3648f, 3c87f83a);
what changed on their side since is test and harness code -- the
main-thread tests' per-linker stack (guarded by `mainThreadStartup`),
`mts-cli-main-thread` (macOS only), aot-facts' `LC_MAIN` parse (macOS
only), the native-aot harness's CRLF reading (Windows) and the census
rows -- run locally on Linux x86-64 (`tests/main-thread-startup.test`: 10
passed, 14 skipped by host, 0 failed; `tests/golden-duplicates.test`).

## 32. Linux x86-64 CI results

**[executed]** in this repository's Linux x86-64 sandbox (Ubuntu, glibc
2.39, Tcl 9.0.1, rustc 1.97), at the milestone's commits:

| Check | Result |
|---|---|
| `cargo test --release` (lib 303 + 2 new, driver 113 + 5 new, native_stack) | all pass |
| `cargo check --target aarch64-apple-darwin` and `--target x86_64-pc-windows-msvc`, every target and test | clean (type-checked only) |
| `tests/main-thread-startup.test`, plain and under `BOTLISH_NATIVE_GC_STRESS=1` | 10 pass, 13 skipped (`mainThreadStartup`, `otool`) |
| native-executable, system-linker, aot-stub-linker, native-library, argv, native-program-output, native-stack-overflow, c-ffi, c-byte-borrowing, c-ffi-error-capture, native-link-plan, coroutines, linux-syscall, main-cli | all pass |
| the stub-linker job's 65 files (`BOTLISH_NATIVE_LINKER=stub`) | 3410 tests: 1 failure, `linux-syscall-machine-code-routes-registers` -- the startup report's thread check had made every executable import libc's `getpid`; fixed (both ids by the raw system call, 95e3648f) and the file passes with the stub, rustc and system linkers |
| the system-linker job's files (`BOTLISH_NATIVE_LINKER=system`) | all pass |
| `tests/local.tcl -parts golden` (every golden suite, all four backends, the driver's changed command line on the JIT's path) | 109 suites, 0 failed: interp 5257, compile 5257, cranelift-generic 5165, cranelift 5267 |
| `cargo check --target aarch64-unknown-linux-gnu --all-targets` | clean (type-checked only; section 33 has the run) |
| `tests/platform/native-status.tcl`, `tests/platform/aot-facts.tcl` | as recorded (the refusal probes included) |
| `tools/compilerpedia.tcl check` | 1084 topics, 666 examples, 0 problems |
| `audit/golden/migration/merge.tcl -check 1` | the manifest is current (23 census rows) |
| the census harness's Linux dry run (`--strict`) | every case as predicted: the main-thread rows predicted FAILED-BUILD (the refusal), the worker and C controls headless |
| native-aot mutants | section 29 |

**GitHub [executed, Linux x86-64]**: `tests` dispatched on the branch at
95e3648f (run 40960937937): every one of its 13 jobs passed -- the whole
Tcl suite on interp and on compile (BoringSSL and Neovim included), its
cranelift and cranelift-generic coverage, the four golden shards beside
their Tcl originals, the native Rust unit tests, the stub-linked and the
system-linked executable jobs (the latter also under GC stress), the
warning gate and the method-call decision's oracle and reference audit.
Its `native GC-stress` job runs on pushes to main only (skipped here).
The later commits change only tests, harnesses and documents (section 38).

## 33. Linux AArch64 CI results

**[executed, Linux AArch64]** (`tests (linux arm64)` dispatched on the
branch at 95e3648f, run 40960941733, ubuntu-24.04-arm): all 11 jobs passed
-- the Tcl suite on interp and on compile, cranelift and cranelift-generic
coverage, the four golden shards, the native Rust unit tests (also under GC
stress), the system-linked executables (also under GC stress) and the whole
suite under GC stress. tests/main-thread-startup.test ran there with its
refusal tests (`mts-cli-refused`, `mts-api-refused`, `mts-record-damage`'s
main-thread word): the policy refused for linux-aarch64 and the runtime's
own refusal of a main-thread record, as on x86-64.

## 34. Windows CI results

* `icy-tower (windows x86-64)` at 95e3648f (run 40960887711)
  **[executed, Windows x86-64]**: success -- the game's MSVC SDL3 binding
  generated, the game compiled and linked by link.exe as a worker
  executable carrying the new record, its Windows tests, its headless and
  SDL dummy-driver plays, the signing dry run and the signed copies' plays.
* `tests (windows x86-64)` at 3c87f83a (run 40992453597) **[executed,
  Windows x86-64]**: every job passed -- smoke (the Rust unit tests, the
  native stack guard checks, native-status with the `main-thread-executable`
  refusal, aot-facts' `main-thread-refused`, the GC workloads, Windows
  I/O, dumpbin, the smoke tier and the Windows-relevant test files), root
  plans (the fallback plan), the system linker in a Developer environment,
  the four acceptance shards and Tier C (section 29's mutants). The
  earlier run at 95e3648f (40960887683) was cancelled by the next push.

## 35. Documentation and Compilerpedia

* **Compilerpedia** (`compilerpedia/topics/`): a new topic,
  `backend.native-startup` (what the policy is, why a macOS graphical
  program needs it, what stays the same -- meaning, errors, statuses, the
  collector, coroutines, the guard -- what differs -- the thread and
  512 MiB against 1 GiB -- and where it is supported); `cli.options` lists
  `-native-startup` and its usage errors;
  `backend.native-executable` gains "WHICH THREAD", `backend.platforms`
  the target row, `backend.macos-application` the graphical program's
  build; `error.native-unsupported` the `startup` kind (code `NATIVE
  UNSUPPORTED startup`) with its cause and fix, `error.native-startup` the
  record's two new refusals. `tools/compilerpedia.tcl check`: 0 problems
  **[executed, Linux x86-64]**.
* **SINGLE-EXECUTABLE.md**: "The startup policy" (the two policies, the
  record word, the link's stack, the refusal) and the macOS application's
  "Graphical programs" bullet.
* **MACOS-AARCH64-PORT-AUDIT.md**: the main thread in section 6 (stacks and
  the guard) and the `main-thread-startup` job in the CI table.
* **MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md**: a follow-up note at its head,
  pointing here; its evidence is unchanged and stays the census's.
* **AGENTS.md**: "Executable startup policy (worker, main-thread)" -- the
  rules to keep (the policy is the executable's; one body, one record; the
  refusal before anything is written; nothing else changes) and what to run
  when changing it -- and the macOS application's rule that neither the
  application, the launcher nor the driver chooses the policy.
* **INDEX.md**: this report.
* main.tcl's header comment and `cliOptions` (which `tests/main-cli.test`
  compares with `cli.options`), native/native.tcl's header (`-startup`).

## 36. Remaining limitations

* **One target.** `main-thread` is macOS AArch64's. Linux would need a
  discovery of its main thread's guard (glibc reports none; the kernel's
  gap below the main stack exists but nothing reports it) and an answer to
  its RLIMIT_STACK-sized, growable stack; Windows a link-time `/STACK:`
  reserve and its own acceptance; neither needs the main thread for its
  windowing systems **[not implemented]**.
* **Capacity.** 512 MiB against the worker's 1 GiB, fixed at link time:
  the deepest recursions a worker holds may end in NATIVE LIMIT STACK on
  the main thread, and the environment cannot enlarge it. Apple ld refuses
  more on arm64; the kernel's own limit was not probed (it would need a
  patched Mach-O, which Botlish never makes). There is no stack-size option
  and no source-level recursion analysis.
* **No coordination with a host's run loop.** The program owns the main
  thread for its whole life, as a synchronous SDL3 program does; an AppKit
  run loop the program does not pump, App Nap, occlusion and sleep/wake are
  not addressed. Interactive input and a person looking at the window were
  not tested (the window is captured and its pixels read).
* **Linked runs and the JIT stay the worker's.** `-backend cranelift` of a
  graphical program runs it as a linked executable on its worker, where
  Cocoa refuses it; such a program is built with `-native-startup
  main-thread -emit-native-executable` and run.
* **No application bundle, Developer ID signing or notarization** for the
  executables (each is linker-signed ad hoc, a command-line Mach-O); no
  macOS native libraries; no iOS.
* **The census's evidence is one runner image**: macOS 15 on Apple's
  virtualization, one display; bare-metal Macs, other releases, several
  displays and HiDPI were not run.

## 37. Prerequisites for graphical macOS Icy Tower

What a graphical macOS build of examples/games/icy-tower now needs, in
order:

1. **A macOS AArch64 SDL3 binding**: the committed bindings are Linux's
   (generated/c/sdl3/); the generator's `-target macos-aarch64` needs the
   macOS SDK (C-BINDGEN.md), so it is generated on a macOS runner, as the
   Windows build generates its MSVC binding where it builds the game
   (ICY-TOWER-WINDOWS.md).
2. **An entry program installing `std::darwin::io`'s context** beside
   `main.bot` and `main-windows.bot` (the game's layering keeps every
   platform name in the entries).
3. **A build script** that stages the binding, links the pinned static
   SDL3 (NATIVE-LINK-PLAN-MILESTONE-1.md's `extern c library "SDL3" static
   at`, the frameworks SDL3's `sdl3.pc` names) and emits the executable
   with `-native-startup main-thread` -- the step this milestone makes
   possible: the same `sdl.bot` context, whose window, renderer and events
   then live on the process's main thread.
4. **Acceptance on a macOS runner**: the census harness's graphical
   classifier (EXECUTED-COCOA) over the game's frame loop, the oracle
   (`audit/icy-tower/oracle.py`) against its rules, and the SDL call trace
   against Linux's. An application bundle, its signing and notarization
   are a separate decision.

## 38. Exact files changed

Against e43a37fe, the tree the milestone started from:

| File | Change |
|---|---|
| `native/src/runtime/program.rs` | `LinkedProgram.startup` (the seventh word); `Startup` (`word`, `of_word`, `spelling`, `parse`); `linked_startup`; `read_linked` reads through it; unit tests of the word and the layout |
| `native/src/runtime/aot.rs` | `MAIN_THREAD_STARTUP`; `start_linked`; `run(startup, argv, init)` with one body, the worker's spawn and join and the main thread's `catch_unwind`; `startup_lines` and `process_main_thread`; `linked_main` through `start_linked` |
| `native/src/runtime/aotimage.rs` | `abi_words` (the fingerprint's inputs, now with the record's size and the word's offset); `Loaded::startup`; the stub's main passes the policy |
| `native/src/runtime/vm.rs` | `Vm::native_stack` (the stack the Vm recorded, for the report) |
| `native/src/codegen/mod.rs` | `emit_executable_object(program, startup)`; the record's word in `define_program_record`; a library's record the worker's |
| `native/src/codegen/target.rs` | `main_thread_startup(target)`, `executable_triple`; tests against the runtime's rule |
| `native/src/codegen/aot.rs` | the startup crate's `start_linked`; `MAIN_THREAD_STACK_BYTES`, `startup_link_args`, `startup_refusal`; `emit_executable`'s policy (the refusal first, both links' stack size, the stub's refusal); tests |
| `native/src/main.rs` | `--startup` for `executable` and `object` (`extract_startup`), refused for every other command; linked runs the worker's; `NATIVE UNSUPPORTED startup` |
| `native/native.tcl` | `native::executable`/`native::object` `-startup`; `StartupOption`; the capability `mainThreadStartup` |
| `main.tcl` | `-native-startup POLICY` (`cliOptions`, validation, usage errors, the header comment) |
| `tests/main-thread-startup.test` | new: 23 tests (10 on every host, 13 on macOS AArch64) |
| `tests/helpers.tcl` | the `mainThreadStartup` constraint |
| `tests/platform/native-status.tcl` | the `main-thread-executable` probe (macOS: runs on the main thread; elsewhere: the refusal) |
| `tests/platform/aot-facts.tcl` | LC_MAIN of both policies, the signature, the run and the main thread's exhaustion on macOS; the refusal elsewhere |
| `tests/platform/tier.tcl` | `native-aot-mutants=NAMES`, `native-stack-mutants=NAMES` |
| `tests/golden/manifest.tsv`, `audit/golden/migration/census/main-thread-startup.tsv`, `audit/golden/migration/tcl-names.txt` | the new tests' census rows (KEEP-INTERNAL), the manifest regenerated |
| `audit/native-aot/tools/mutants.txt`, `mutate.tcl` | 20 policy mutants, 3 refreshed; the new test file among the detectors |
| `audit/native-stack/tools/mutants.txt`, `mutate.tcl` | `main-thread-unguarded`; the new test file among the detectors |
| `audit/macos-graphical-main-thread/tools/census.py`, `README.md` | candidate A on the production policy (the application's system linker, the rustc linker, the 8 MiB control), the startup group, `--strict` |
| `.github/workflows/macos-arm64.yml` | the `main-thread-startup` job |
| `.github/workflows/macos-graphical-main-thread.yml` | the experiment's runtime at its base commit |
| `compilerpedia/topics/backends.topic`, `errors-runtime.topic` | section 35 |
| `docs/MAIN-THREAD-STARTUP-MILESTONE-1.md` | this report |
| `docs/INDEX.md`, `docs/SINGLE-EXECUTABLE.md`, `docs/MACOS-AARCH64-PORT-AUDIT.md`, `docs/MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md`, `AGENTS.md` | section 35 |

No file of the front end (`core/`, `hir/`, `surface/`, `stdlib/`), the Tcl
compiler, the collector, coroutines, the stack guard, the C FFI, the JIT,
`runtime::library` or the single executable's packing changed.

## 39. Commands for reproducing the acceptance

On Linux (the refusal, the record, the panic, every linker, the mutants):

```sh
cargo build --release --manifest-path native/Cargo.toml
cargo test --release --manifest-path native/Cargo.toml --lib -- aotimage program
cargo test --release --manifest-path native/Cargo.toml --bin botlish-native -- aot:: target::
tclsh9.0 tests/main-thread-startup.test -tmpdir "$(mktemp -d)"
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/main-thread-startup.test -tmpdir "$(mktemp -d)"
tclsh9.0 tests/platform/native-status.tcl
tclsh9.0 tests/platform/aot-facts.tcl
tclsh9.0 audit/native-aot/tools/mutate.tcl
tclsh9.0 audit/native-stack/tools/mutate.tcl
```

On an Apple Silicon Mac (or GitHub's `macos-15`: macos-arm64.yml's
`main-thread-startup` job runs exactly this):

```sh
cargo build --release --manifest-path native/Cargo.toml
single/macos/build.sh -o dist
export BOTLISH_SDL3_STATIC_PREFIX="$HOME/Library/Caches/botlish-sdl3-static"
bash tests/platform/link-plan-sdl3.sh dist/Botlish.app "$(command -v tclsh9.0)"
dist/Botlish.app/Contents/MacOS/botlish -native-startup main-thread -emit-native-executable app.bot
otool -l app | grep -A4 'cmd LC_MAIN'            # stacksize 536870912
BOTLISH_NATIVE_STARTUP_REPORT=report ./app; tail -n 3 report
python3 -I audit/macos-graphical-main-thread/tools/census.py \
  --work /tmp/census --out census-results --sdl-prefix "$BOTLISH_SDL3_STATIC_PREFIX" \
  --app dist/Botlish.app --checkout "$PWD" --tclsh "$(command -v tclsh9.0)" --repeat 5 \
  --only env,identity,stack,c-graphical,botlish-baseline,candidate-a,semantics,startup,controls,timing --strict
tclsh9.0 tests/main-thread-startup.test -tmpdir "$(mktemp -d)"
tclsh9.0 tests/platform/tier.tcl native-aot-mutants native-stack-mutants
```
