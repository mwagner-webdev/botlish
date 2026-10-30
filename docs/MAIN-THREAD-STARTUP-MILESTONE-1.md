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

(Filled in from the CI evidence: see section 31.)

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

## 13. LC_MAIN inspection

(From the macOS runs: `otool -l` of each executable; section 31.)

## 14. Main-thread native stack discovery

(From the macOS runs: the startup report's `stack` line inside the actual
main-thread executables, `mts-main-identity`; section 31.)

## 15. Overflow-guard acceptance

(From the macOS runs: `mts-main-overflow`, `mts-main-fault`, the census's
candidate-A rows; section 31.)

## 16. Stack-capacity acceptance

(From the macOS runs: `mts-main-capacity`, `mts-main-stack-bytes`, the
census's depth rows on the worker, the 8 MiB control and the main thread;
section 31.)

## 17. GC root correctness

(From the macOS runs: `mts-main-gc-stress`, `mts-main-report-parity`, the
census's GC-stress rows; section 31.)

## 18. Coroutine and suspended-stack correctness

(From the macOS runs: `mts-main-kept-coroutines`, `mts-main-identity`'s
coroutine, the census's kept and SDL coroutine rows; section 31.)

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

(From macos-arm64.yml's `main-thread-startup` job; section 31.)

## 26. Cocoa/Metal graphical acceptance

(From the census harness on the production policy; section 31.)

## 27. Graphical positive controls

(Section 31.)

## 28. Process and linked-run parity

(Section 31; Linux evidence in section 32.)

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
| `cli-drops-main-thread` | CLI silently drops main-thread | `mts-cli-refused` |
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
never ran. Its kills of `rustc-link-no-stack-size`, `main-thread-on-a-worker`
and `main-thread-panic-escapes` (the three only macOS compiles) may be
those failures alone; the others are also killed by a unit test or by
aot-facts or native-status, which read no census program. Fixed: the tree
holds what the detectors read (`audit/`, `bench/`, `service/` and `lsp/`,
as audit/native-stack's does), and the harness now runs every detector on
the unmutated tree first and judges no mutant unless that baseline passes.
On Linux x86-64 the fixed harness's baseline passes and its kills are the
earlier run's (`-only linux-accepts-main-thread,policy-not-recorded`: 2 of
2, by the same detectors) **[executed]**; on Linux no main-thread test
reads a census program (they are macOS's), so the 19 Linux verdicts above
stand. The native-stack harness's tree was complete (it copies `audit/`):
`main-thread-unguarded`'s five failures, with every capacity, GC and
coroutine test passing beside them, are a kill. The re-run on macOS:
section 31.

**Windows x86-64 [executed]** (windows-x86_64.yml run 40960887683, Tier C
shard 1): 5 killed, 0 survived, 4 skipped -- and `windows-accepts-main-thread`
among the skipped, "not compiled differently for windows nt-x86_64". The
harness named a Windows host by Tcl's `tcl_platform(os)`, "Windows NT",
so no `%% windows-x86_64` mutant of audit/native-aot ever applied on
Windows (`c-calls-refused-on-windows`, from WINDOWS-X86-64-MILESTONE-2.md,
neither; no report counted it). Fixed: the host is `windows-x86_64` there,
as audit/c-ffi's and audit/native-link-plan's harnesses name it. The two
Windows mutants' run on Windows, behind the new baseline: section 34.

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

**The main thread against the worker on macOS** (the census harness's
`timing` section, five repetitions each: the identity program's startup,
the SDL program with a window on the main thread and headless on both
policies, both headless runs and the kept-coroutine program under GC
stress, beside C's own SDL program; and every executable's size): section
31.

## 31. macOS CI results

(Pending.)

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

GitHub's `tests` and `tests (linux arm64)` workflows, dispatched on the
branch, are recorded below as they complete.

## 33. Linux AArch64 CI results

(Pending.)

## 34. Windows CI results

* `icy-tower (windows x86-64)` at 95e3648f (run 40960887711)
  **[executed, Windows x86-64]**: success -- the game's MSVC SDL3 binding
  generated, the game compiled and linked by link.exe as a worker
  executable carrying the new record, its Windows tests, its headless and
  SDL dummy-driver plays, the signing dry run and the signed copies' plays.
* `tests (windows x86-64)` at 95e3648f (run 40960887683): pending.

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
