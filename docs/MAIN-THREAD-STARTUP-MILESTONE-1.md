# MAIN-THREAD-STARTUP-MILESTONE-1.md

Explicit main-thread startup for macOS AArch64 executables: candidate A of
[MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md](MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md),
made a supported startup policy of a standalone executable.

> Which thread hosts an executable's initial Botlish program is a property
> of the executable's startup contract, not of the program's libraries,
> contexts or functions. Choosing the process main thread must preserve the
> same Botlish semantics and runtime safety as choosing the existing worker,
> subject to the explicitly documented stack-capacity difference.

Every platform claim below is marked **Executed** (run, with the run named),
**Inspected** (read from code, documentation or a tool's output without
running the claim itself) or **Not implemented**. Census evidence
(the disposable experimental runtime of the census) is marked as such and
kept apart from this milestone's own results.

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

RESULT-PENDING

## 2. Starting census findings

The census (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md, three runs on GitHub's
`macos-15` Apple Silicon runners) established, on its experimental runtime
(**census evidence**, not this milestone's):

* production executables run Botlish on a 1 GiB worker, which SDL3's Cocoa
  backend refuses ("No available video device") while `SDL_IsMainThread()`
  answers true;
* running the unchanged program on the process's main thread made the same
  Botlish SDL3 program EXECUTED-COCOA (a Cocoa window, Metal, 30 frames and
  3 from a kept coroutine, a quit event polled back, a clean shutdown);
* the macOS stack discovery and guard already serve the main thread; GC
  stress, stack maps and kept coroutines work unchanged; Cocoa and Metal work
  from a coroutine's stack on the main thread;
* the default main stack is about 8 MiB; Apple ld's `-stack_size` (LC_MAIN)
  is accepted up to 512 MiB on arm64 and refused above; with 512 MiB every
  finite recursion probe returned its value;
* both the rustc and the system linker's startups reach the same `aot::run`;
* one process-semantic regression: a Rust panic on the main thread escaped
  into Rust's startup (status 101) instead of the worker's `native
  executable panicked (NATIVE BUG)`, status 1.

The census's recommendation (its section 30) is what this milestone
implements; its candidates B (a dispatcher) and C (SDL's callbacks) are not
implemented and stay archival.

## 3. Final public CLI

```sh
botlish -native-startup main-thread -emit-native-executable app.bot   # macOS aarch64
botlish -native-startup worker -emit-native-executable app.bot        # the default, explicit
botlish -emit-native-executable app.bot                               # the default
```

(`tclsh9.0 main.tcl` in a checkout; `Botlish.app/Contents/MacOS/botlish`
on a Mac.) The Tcl API is `native::executable HIR PATH -startup
worker|main-thread`; the driver's is `botlish-native executable OUT
FILE.nir --startup worker|main-thread`. One spelling everywhere: `worker`
and `main-thread`.

The option is an option of executable emission only (**Executed**,
Linux; `tests/main-cli.test`'s `cli-malformed-*`, exit status 2, nothing
compiled):

| Invocation | Outcome |
|---|---|
| no `-native-startup` | the worker |
| `-native-startup worker` (also repeated) | the worker |
| `-native-startup main-thread` on macOS aarch64 | a main-thread executable |
| `-native-startup main-thread` on any other target | `NATIVE UNSUPPORTED startup`, status 1, before anything is linked; an earlier executable at the path is left as it was |
| `-native-startup` without a value | usage error (`option -native-startup needs an argument (POLICY)`) |
| `-native-startup main` (unknown) | usage error (`unknown startup policy "main" (known: worker main-thread)`) |
| two different policies | usage error (`-native-startup is given twice with different policies`) |
| without `-emit-native-executable` (a run, `-emit-hir-interchange`, `-emit-native-library`) | usage error (`-native-startup is an option of -emit-native-executable`) |
| with `-check` or `-lsp` | their own usage errors (`cannot be combined with -native-startup`) |

The driver refuses `--startup` on any command but `executable`, an unknown
policy, a missing value and two different ones (usage, status 2;
`mts-driver-option-errors`), and refuses `main-thread` where unsupported
with `error {NATIVE UNSUPPORTED startup} ...`, status 1, before writing
anything (`mts-driver-refused-where-unsupported`).

## 4. Startup policy semantics

`runtime::program::Startup` has two values:

* **worker** (word 0): `runtime::aot::run` creates a thread with a stack of
  `BOTLISH_NATIVE_STACK_BYTES` (1 GiB by default, at least 1 MiB), runs the
  program there and joins it -- exactly the executable startup before this
  milestone.
* **main-thread** (word 1): `run` runs the program on the thread that called
  it -- the thread that entered the executable's `main`, the process's main
  thread -- on the stack the link reserved for it. No thread is created for
  the program.

The policy is fixed into the executable when it is linked; no environment
variable selects it at launch (the census's `BOTLISH_EXPERIMENT_THREAD` is
gone), and nothing infers it: not SDL3 or AppKit being linked, not a
framework declaration, not a context, an import, a coroutine or an event
loop. An application linking Cocoa may use the worker, and one using no
foreign library may use the main thread. Nothing about the program's
analysis changes (section 24).

## 5. Target restrictions

`main-thread` is supported for **macos-aarch64** only; everywhere else it is
refused before anything is lowered, written or linked:

* the front end refuses it by the capability table
  (`native::capabilities`'s `mainThreadStartup {macos-aarch64}`, read for the
  target the HIR is compiled for -- its own, else the host's -- by
  `native::StartupPolicy`): `NATIVE UNSUPPORTED startup`, with the target's
  reason (Linux: "Linux's main thread has no confirmed stack guard (glibc
  reports none, so the runtime's stack guard refuses it), and its startup has
  had no main-thread acceptance"; Windows: "Windows' main thread would need
  its own stack reservation and validation (its stack is the link's
  reservation, 1 MiB unless it reserves more), and its startup has had no
  main-thread acceptance");
* the driver refuses it by its own gate (`runtime::aot::MAIN_THREAD_STARTUP`,
  `codegen::aot::startup_refusal`) with the same code, for anyone calling the
  driver directly;
* `aot::run` refuses a record naming it on a target without it (NATIVE
  STARTUP, status 1), and the stub refuses one (section 21): a hand-damaged
  executable never starts on a guessed thread.

The message never says main-thread execution is impossible elsewhere; it
says what each target lacks. **Executed** on Linux x86-64 (this sandbox:
`mts-refused-where-unsupported`, `mts-driver-refused-where-unsupported`,
`mts-cli-startup`, native-status's `main-thread-executable`, aot-facts'
`main-thread-refused`); Linux AArch64 and Windows in CI (sections 33-34).

## 6. Representation in botlish_program

The program record (`runtime::program::LinkedProgram`, emitted by
`codegen::define_program_record` as `botlish_program`) gains a seventh word,
`startup`, after the six it had: 56 bytes, the policy at offset 48. It is the
one carrier: no second descriptor, no generated startup source, no
environment dependency. `Startup::word` encodes it (0 worker, 1
main-thread), `Startup::from_word` refuses any other word, and
`program::startup_of` reads it after checking the magic and the fingerprint
-- reading nothing the record points at.

A main-thread executable's program object differs from a worker one's in
exactly one byte, the startup word's lowest (`codegen`'s
`startup_policy_is_the_objects_only_difference`: the same machine code,
descriptor, stack maps, symbols and relocations). A native library's object
always names the worker (`emit_library_object`), and `botlish_library_create`
refuses a library record that names anything else (NATIVE STARTUP): the
executable-only policy is represented as the default and never read by the
library contract.

## 7. Runtime ABI compatibility

The ABI fingerprint (`aotimage::abi_fingerprint`, the record's second word)
now covers the record's own layout -- its size and the startup word's
offset (`RECORD_LAYOUT = [56, 48]`) -- through `abi_fingerprint_for`. So:

* a record of the old layout (six words, the old fingerprint) is refused by
  a new runtime ("the program was compiled for a different native runtime
  build", NATIVE STARTUP) before its seventh word -- which it does not have
  -- is read;
* a new record is refused by an old runtime archive, rlib or stub the same
  way;
* `aot_fingerprint_covers_the_record_layout` checks that a runtime of
  another record layout fingerprints differently, and the mutant that drops
  the layout from the fingerprint is killed by it (section 29).

The system-linked, rustc-linked and stub-linked executables read the same
record (`tests/system-linker.test`'s startup reports, unchanged and equal).
The stub's image check uses the new record size
(`size_of::<LinkedProgram>()`).

## 8. AOT runtime refactor

The census's experiment (`patches/main-thread-experiment.patch`)
reorganized `aot::run` around one closure; that structure is kept, its
switches are not. In `native/src/runtime/aot.rs`:

* `start_linked(linked)` -- the executables' startup, called by the rustc
  startup crate (`codegen::aot`'s `STARTUP`, now three lines: it names the
  record and calls `start_linked`) and by the runtime archive's `main`
  (`linked_main`, after `rust_process_setup`): reads the policy on the
  calling thread (`program::startup_of`), then `run(startup, process_argv(),
  init)`, INIT reading the record on the thread that runs the program
  (`program::instantiate_linked`);
* `run(startup, argv, init)` -- one body (INIT, the startup report, the
  argument snapshot, the driver protocol or the guard and the program, the
  value or error), run by `std::thread::Builder::spawn` for the worker
  (unchanged) or by `on_this_thread` for the main thread;
* `on_this_thread(body)` -- the body under `catch_unwind`, a panic reported
  by `panicked()`, the worker's own report;
* `startup_facts` -- the startup report's last lines (section 14);
* `injected_fault` -- `BOTLISH_NATIVE_RUNTIME_FAULT=panic`, a test-only
  panic on the program's thread right before the entry (section 11);
* `MAIN_THREAD_STARTUP` -- the target gate.

The stub's loader (`aotimage::main`) reads the policy from the loaded record
(`Loaded::startup`) and refuses anything but the worker. Nothing else of the
runtime changed: not the collector, the stack maps, the coroutine runtime,
the guard, the C FFI or the value representation. `Vm` gained one accessor
(`native_stack`, for the report).

## 9. Worker-path preservation

The worker path is the code it was: the same `BOTLISH_NATIVE_STACK_BYTES`
default and floor, the same `spawn`/`join`, the same panic and spawn-failure
reports, the same guard installation, protocol, lines and statuses. Two
observable additions apply to both policies:

* the startup report (`BOTLISH_NATIVE_STARTUP_REPORT`) ends with three lines
  -- `startup worker`, `thread worker` (no `thread` line on Windows, which
  has no such question), `stack usable BYTES guard BYTES` -- after the Vm's
  unchanged report; the system, rustc and stub linkers' reports stay equal
  (`tests/system-linker.test`, **Executed** on Linux x86-64; the macOS app's
  `compare.sh` in CI);
* a startup word that names no policy is refused (NATIVE STARTUP).

Linux and Windows executables start exactly as before (section 30's
measurements), and every worker test passes there (sections 32-34).

## 10. Main-thread startup sequence

```text
main (rustc's startup crate, or the runtime archive's C main
      after rust_process_setup)                       process main thread
  start_linked(&botlish_program)
    program::startup_of: magic, fingerprint, word     process main thread
    run(MainThread, process_argv(), init)
      on_this_thread(body)                            process main thread
        init(): program::instantiate_linked
          read_linked: descriptor, code table
          Vm::new: NativeStack::current() (LC_MAIN's stack), PROGRAM
          constants, statics, frame map
        startup report (BOTLISH_NATIVE_STARTUP_REPORT)
        vm.set_argv(argv)
        driver protocol (BOTLISH_NATIVE_RESULT), or
        OverflowGuard::install_executable(main stack)
        entry(vm): the compiled program, its C calls,
          its coroutines on their own stacks          process main thread
        value or error, status
  std::process::exit(status)
```

Every thread-dependent step -- the Vm (its native stack, its thread-local
current program), the guard, the program, the collections, the coroutine
stacks -- happens on the thread that runs the program. The Vm is never made
on one thread and moved to another (it is not `Send`).

## 11. Panic and error behavior

A panic on the program's thread is `native executable panicked (NATIVE
BUG)`, status 1, on either thread (after Rust's own panic message): the
worker's through `join`, the main thread's through `on_this_thread`'s
`catch_unwind`, so nothing unwinds into Rust's `main` or across the runtime
archive's `extern "C" main`. A stack overflow is no panic: the guard ends
the process with its line before anything unwinds.

`BOTLISH_NATIVE_RUNTIME_FAULT=panic` injects the panic, in plain runs and in
the driver protocol. **Executed** on Linux x86-64 for the worker with the
default, system, rustc and stub linkers (`mts-panic-is-native-bug`), on
macOS for both policies and both linkers (sections 28 and 31); the unit test
`startup_on_this_thread_catches_a_panic` runs the main-thread wrapper on
every host.

Other outcomes are unchanged on both threads: an ordinary runtime error
(its line and code, status 1), a startup or report IO failure (NATIVE IO,
status 2), a native stack overflow (NATIVE LIMIT STACK, status 1), an
unrelated SIGSEGV (death by the signal, never relabeled), a normal
completion (the value, status 0).

## 12. Main-stack reservation

A main-thread executable for macOS reserves its main thread's stack at link
time: `-Wl,-stack_size,0x20000000` (`codegen::aot::MAIN_STACK_BYTES`, 512
MiB, Apple ld's largest on arm64), given

* by the system linker in its argument list (`system_link_args`, after the
  flavor's flags, before the objects), and
* by the rustc linker as `-C link-arg=-Wl,-stack_size,0x20000000`
  (`startup_link_args`, the same function, rustc's spelling).

A worker executable's link is unchanged (no flag), and no other linker
flavor is ever given one (`startup_main_thread_reserves_lc_main_stack`:
the Apple main-thread link differs from the worker's by that one argument;
GNU and MSVC links are identical for both policies). The reservation is
address space, which the kernel maps as the stack grows; RLIMIT_STACK is
not raised (census section 11). The worker's stack stays a run-time choice
(1 GiB by default); the main thread's cannot be resized by the environment.

| Property | Worker | Main thread |
|---|---|---|
| Initial execution thread | spawned worker | process main thread |
| Default stack capacity | 1 GiB | 512 MiB |
| Stack size selected | at run time | at link time |
| `BOTLISH_NATIVE_STACK_BYTES` | applies | does not apply |
| Overflow guard | the shared guard | the same guard |
| Coroutine stacks | unchanged | unchanged |

## 13. LC_MAIN inspection

LCMAIN-PENDING

## 14. Main-thread native stack discovery

DISCOVERY-PENDING

## 15. Overflow-guard acceptance

GUARD-PENDING

## 16. Stack-capacity acceptance

CAPACITY-PENDING

## 17. GC root correctness

GC-PENDING

## 18. Coroutine and suspended-stack correctness

COROUTINE-PENDING

## 19. System linker integration

SYSTEM-PENDING

## 20. Rustc linker integration

RUSTC-PENDING

## 21. Stub linker behavior

The stub (Linux x86-64 only) links worker executables only:

* the driver refuses `main-thread` on Linux before any link (section 5); on
  a host that has the policy, `BOTLISH_NATIVE_LINKER=stub` with
  `main-thread` is refused before the image is written ("the stub linker
  ... links executables that start their program on a worker only",
  NATIVE AOT);
* the stub's loader refuses an image whose record names the main thread
  ("the stub linker's executables start their program on a worker ...",
  NATIVE STARTUP, status 1) and one whose word names no policy;
* its image check uses the seven-word record.

**Executed** on Linux x86-64: `tests/aot-stub-linker.test` (6 of 6),
`tests/system-linker.test`'s stub comparisons (15 of 15), the stub cases of
`mts-damaged-startup-word` (an image patched to word 1 and to word 2) and
`mts-stub-links-worker-only`.

## 22. Native JIT noninterference

The driver's JIT keeps its own 1 GiB worker (`native/src/main.rs`'s `main`,
unchanged) and never reads a policy; `--startup` on `run`, `bench`, `batch`,
`object` or `library` is a usage error (`mts-driver-option-errors`), and
main.tcl refuses `-native-startup` beside a run. A program that calls C,
which the native backends run as a linked executable (the driver protocol),
is linked as a worker executable always (`run_linked` passes
`Startup::Worker`): **Executed** on Linux x86-64 (`mts-linked-run-is-worker`:
its startup report says `startup worker`) and on macOS (the acceptance's
`id-linked-run`: the fixture says the program is not on the main thread).

## 23. Native-library noninterference

A native library's record names the worker (`emit_library_object`), its
calls run on the host's calling thread as before, and the thread affinity,
reentrancy and instance checks are unchanged; `botlish_library_create`
refuses a record that names an executable's policy. **Executed** on Linux
x86-64: `tests/native-library.test` 28 of 28; `startup_policy_is_recorded`
(a library object's word is 0). Native libraries remain Linux glibc's;
macOS native libraries are **Not implemented** (a non-goal).

## 24. Compiler-service and HIR noninterference

The policy is not part of the program: it never enters HIR, the front-end
cache key, HIR interchange or NIR (`native::executable` strips `-startup`
before lowering and passes `--startup` to the driver's `executable`
command alone). The same HIR lowers to the same NIR and the same program
object but for one byte (section 6). `-check`, the compiler service and the
language server never see it (`-check` and `-lsp` refuse the option as they
refuse any building option). Link-plan resolution is unchanged
(`tests/native-link-plan.test` in CI); static SDL3's declarations
(`extern c library "SDL3" static at ...`, `extern c framework ...`) stay
ordinary link-plan entries, and nothing in them selects the policy.

## 25. Packaged Botlish.app acceptance

APP-PENDING

## 26. Cocoa/Metal graphical acceptance

GRAPHICAL-PENDING

## 27. Graphical positive controls

CONTROLS-PENDING

## 28. Process and linked-run parity

PARITY-PENDING

## 29. Mutation testing

Two campaigns cover the policy: `audit/native-aot/tools/mutate.tcl`
(executable emission; 19 new mutants, three repaired) and
`audit/native-stack/tools/mutate.tcl` (the stack guard; one new mutant).
Each mutant rebuilds a private copy of `native/` and runs every detector:
the cargo tests (`--bin botlish-native -- aot startup`, `--lib -- aotimage
program runtime::aot`), `native-executable.test`, `argv.test`'s standalone
tests, the 2048 executable, `system-linker.test`, `main-thread-startup.test`,
`aot-facts.tcl` and `native-status.tcl`. The native-stack campaign runs its
own detectors plus `main-thread-startup.test`'s `mts-policy-*` and
`mts-main-*`. A `%%` line limits a mutant to the hosts whose code it changes.
Elsewhere the mutant is SKIPPED: its code is another host's gate. Linux:
**Executed** in this sandbox (Linux x86-64). macOS: **Executed** in the
macOS workflow's full tier (section 31).

| Mutant | What it breaks | Linux x86-64 | macOS AArch64 |
|---|---|---|---|
| `cli-startup-dropped` | main.tcl's `-native-startup main-thread` builds a worker | KILLED: main-thread-startup.test (`mts-cli-startup`) | MACOS-AOT-PENDING |
| `api-default-main` | `native::executable` defaults to the main thread | KILLED: main-thread-startup.test | -- |
| `api-capability-linux` | the capability table gives Linux the policy | KILLED: main-thread-startup.test (`mts-refused-where-unsupported`) | SKIPPED |
| `api-capability-windows` | the capability table gives Windows the policy | SKIPPED (Windows') | SKIPPED |
| `api-driver-worker` | `native::executable` asks the driver for the worker whatever the policy | SKIPPED (macOS') | MACOS-AOT-PENDING |
| `driver-startup-ignored` | the driver's `executable` ignores `--startup` | KILLED: main-thread-startup.test (`mts-driver-refused-where-unsupported`) | -- |
| `driver-startup-anywhere` | the driver takes `--startup` on any command | KILLED: main-thread-startup.test (`mts-driver-option-errors`) | -- |
| `driver-default-main` | the driver's `executable` defaults to the main thread | KILLED: native-executable.test, system-linker.test | -- |
| `startup-anywhere` | every host takes the policy for supported | KILLED: Rust (`startup_main_thread_is_macos_aarch64s_only`), main-thread-startup.test | SKIPPED |
| `record-startup-unwritten` | the record never carries the policy | KILLED: Rust (`startup_policy_is_recorded`, `..._the_objects_only_difference`) | -- |
| `record-startup-ignored` | the runtime reads every word as the worker | KILLED: Rust (`linked_program_startup_policy`), main-thread-startup.test (`mts-damaged-startup-word`) | MACOS-AOT-PENDING |
| `record-startup-unchecked` | a word naming no policy reads as the worker | KILLED: Rust, main-thread-startup.test (`mts-damaged-startup-word`) | -- |
| `fingerprint-ignores-record` | the ABI fingerprint leaves the record layout out | KILLED: Rust (`aot_fingerprint_covers_the_record_layout`) | -- |
| `main-thread-spawns-worker` | a main-thread executable runs on a worker after all | SKIPPED (macOS') | MACOS-AOT-PENDING |
| `main-thread-panic-escapes` | a main-thread panic unwinds out of `run` (status 101) | KILLED: Rust (`startup_on_this_thread_catches_a_panic`) | MACOS-AOT-PENDING |
| `main-thread-no-guard` | a main-thread executable runs unguarded | SKIPPED (macOS') | MACOS-AOT-PENDING |
| `system-lc-main-dropped` | the system linker drops LC_MAIN's stack size | KILLED: Rust (`startup_main_thread_reserves_lc_main_stack`) | MACOS-AOT-PENDING |
| `rustc-lc-main-dropped` | the rustc linker drops LC_MAIN's stack size | SKIPPED (macOS') | MACOS-AOT-PENDING |
| `stub-runs-main` | the stub runs a main-thread image on a worker | KILLED: main-thread-startup.test (`mts-damaged-startup-word`) | SKIPPED |
| `startup-no-guard` (repaired) | an executable runs without the guard | KILLED | -- |
| `sys-runtime-variable-ignored` (repaired) | `BOTLISH_NATIVE_RUNTIME` is not read | KILLED | -- |
| `sys-startup-failure-succeeds` (repaired) | an unreadable record (magic, build, policy) exits 0 | KILLED | -- |
| `macos-size-from-rlimit` (native-stack) | the main thread's size read as the stack rlimit (8 MiB): LC_MAIN's 512 MiB unused | SKIPPED (macOS') | MACOS-STACK-PENDING |

`--`: not run on that host. Each of those mutants is portable code that
the same detectors kill on every host; the macOS run spends its time on
the mutants that only macOS compiles differently.

Linux x86-64, native-aot: 17 killed, 0 survived, 5 skipped (another host's
code), across the 22 above. Every mutant in every `mutants.txt` still
applies to the code it mutates (a check over all of them), apart from two
in `hir/cabi.tcl` (c-abi-types' `ptr-as-int`, native-view's
`view-is-a-pointer`), a file this milestone does not touch. Two mutants
of other campaigns (c-ffi's, native-link-plan's) were updated to the new
signatures, and both are still KILLED on Linux x86-64: c-ffi's
`link-failure-removes-earlier` (by `cf-link-failure-keeps-executable`) and
native-link-plan's `system-loses-static` (by `nlp-linkers-agree`). The native-stack campaign on Linux x86-64 (all of its mutants,
the new detector included): 51 mutants, 22 killed, 0 survived, 29 skipped
(macOS' and Windows' code).

## 30. Executable size and performance

**Linux x86-64, worker executables: before and after** (**Executed**, this
sandbox; four cores, shared). The baseline is `17d6904f` (the census
commit, the branch's base), built in its own worktree. "After" is this
branch with the startup report's kernel-only thread check (`d566f3a1`).
Every executable is the same source, linked by each linker: `trivial`
prints `42`, `bench` is the 2048 workload's benchmark program
(`examples/games/2048/bench.bot`, checksum 2002720). Sizes come from
`stat` and `size`; the file is mostly debug information.

| Linker | Program | File bytes before | after | text before | text after | data+bss before | after |
|---|---|---:|---:|---:|---:|---:|---:|
| system | trivial | 9,942,656 | 9,930,104 | 639,404 | 639,080 | 26,992 | 27,040 |
| system | bench | 10,041,280 | 10,028,752 | 721,624 | 721,752 | 28,832 | 28,880 |
| rustc | trivial | 10,046,928 | 10,027,880 | 652,327 | 649,807 | 30,043 | 28,483 |
| rustc | bench | 10,142,192 | 10,123,720 | 733,262 | 730,958 | 31,035 | 29,235 |
| stub | trivial | 10,440,828 | 10,429,756 | 979,717 | 980,885 | 42,667 | 45,595 |
| stub | bench | 10,476,944 | 10,465,872 | 979,717 | 980,885 | 42,667 | 45,595 |

Text moves by -2.5 KiB to +1.2 KiB: the startup gained `start_linked`,
`startup_facts`, `on_this_thread` and the policy check. The rustc
linker's startup crate shrank to three lines that no longer instantiate
`run` themselves. The stub's own text, shared by every stub executable,
grew by 1,168 bytes. No program's code changed (section 6).

Run time, interleaved (each round runs the twelve executables once, in
turn; 300 rounds of `trivial`, 15 of `bench`). Medians, with p10 and p90:

| Linker | Program | Before | After |
|---|---|---|---|
| system | trivial | 2.344 ms (2.088-2.816) | 2.349 ms (2.111-3.003) |
| rustc | trivial | 2.425 ms (2.149-3.036) | 2.473 ms (2.209-3.023) |
| stub | trivial | 2.498 ms (2.234-3.089) | 2.545 ms (2.252-3.278) |
| system | bench | 9.512 ms (7.738-12.347) | 8.533 ms (7.851-12.972) |
| rustc | bench | 8.909 ms (7.779-10.388) | 8.932 ms (8.282-12.709) |
| stub | bench | 8.656 ms (8.150-9.805) | 8.963 ms (8.227-13.212) |

The worker's startup costs the same: every difference is within this
machine's spread, and the policy check reads one word.

**macOS AArch64, both policies** (the acceptance's `timing` group on the
macos-15 runner): MACOS-TIMING-PENDING

A main-thread executable's program object differs from a worker one's by
one byte (section 6), and its link by one argument. On a Mach-O that
argument sets LC_MAIN's `stacksize` field, which is already there, so the
two policies' executables are the same size (MACOS-SIZE-PENDING).

## 31. macOS CI results

MACOS-PENDING

## 32. Linux x86-64 CI results

LINUX-PENDING

## 33. Linux AArch64 CI results

ARM64-PENDING

## 34. Windows CI results

WINDOWS-PENDING

## 35. Documentation and Compilerpedia

* `docs/SINGLE-EXECUTABLE.md`: "Where an executable runs its program" (the
  two policies' table) and the startup's `start_linked`.
* `docs/MACOS-AARCH64-PORT-AUDIT.md`: section 6's note on the main thread,
  the CI table's `main-thread-startup` job.
* `docs/MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md`: a follow-up pointer at its
  top.
* `docs/NATIVE-STACK-OVERFLOW.md`: the main thread's stack and guard.
* `docs/README.md`: the standalone executables' startup policy and the Tcl
  API's `-startup`.
* `docs/INDEX.md`: this report.
* `AGENTS.md`: "The executable startup policy (the process's main thread)"
  (the rules and what to run), and the shared startup in "The single-file
  compiler and the stub linker".
* Compilerpedia: `cli.options` (`-native-startup`, its malformed
  invocations), a new topic `backend.main-thread-startup` (what it is, why
  it exists, what stays the same, what chooses it, where it is refused),
  `backend.native-executable` ("Where its program runs"),
  `backend.platforms`, `error.native-unsupported` (`NATIVE UNSUPPORTED
  startup`), `error.native-bug` (the panic on either thread).
  `tools/compilerpedia.tcl check`: **Executed**, 1081 topics, 0 problems.
* main.tcl's header comment, `cliOptions` and usage summary
  (`tests/main-cli.test`'s `cli-options-documented`,
  `cli-usage-fits-a-terminal`).

The policy is described as a property of the executable, never as a
language effect.

## 36. Remaining limitations

* **macOS AArch64 only.** `main-thread` is refused for every other target
  (section 5). That is a statement of what was accepted, not of what is
  impossible: Linux needs its own main-thread stack discovery (glibc reports
  no guard for the main thread, so the guard refuses it), Windows its own
  stack reservation and validation. Both are **Not implemented**.
* **512 MiB, fixed at link time.** The main thread's stack is half the
  worker's default and cannot be changed when the executable runs:
  `BOTLISH_NATIVE_STACK_BYTES` does not apply, and Apple ld refuses more on
  arm64. A program whose recursion needs between 512 MiB and 1 GiB of stack
  ends in `NATIVE LIMIT STACK` on the main thread where the worker would
  return its value. The compiler cannot know a program's depth, so there is
  no warning; the difference is documented (section 12, Compilerpedia's
  `backend.main-thread-startup`). Every census probe returned its value at
  512 MiB (section 16).
* **Executables only.** `-backend cranelift` runs (the JIT, and the linked
  run of a program that calls C) stay on the worker. A program that needs
  Cocoa has to be emitted as an executable with the policy; running it with
  `main.tcl -backend cranelift` still fails the way the census recorded
  (no video device). Native libraries run on their host's thread, and macOS
  native libraries are **Not implemented**.
* **The stub linker** stays Linux x86-64's and worker-only (section 21).
* **Signing.** Executables are signed ad hoc by the linker, as before.
  Nothing is notarized or Gatekeeper-approved. Launching from Finder
  (an `.app` bundle with an `Info.plist`) is not part of this milestone:
  the acceptance launches executables from a shell in the runner's console
  session.
* **No macOS event-loop driver.** `std::event_loop` has its deterministic
  driver and the Linux package; a driver that integrates with Cocoa's run
  loop is later work. The policy only makes it possible, because that
  driver's thread is now the main thread.
* **Not examined:** an Objective-C exception thrown through Botlish frames
  (as on the worker, nothing catches it), Apple's crash reporter and
  unwinder across Botlish frames on the main thread, and AppKit's own run
  loop (`NSApplication run`) driving a Botlish program. SDL3 pumps Cocoa's
  events from the program's own calls, which is what was accepted.

## 37. Prerequisites for graphical macOS Icy Tower

What a graphical macOS Icy Tower still needs, now that a Botlish
executable can run on the main thread (each item **Not implemented**):

1. **The generated SDL3 binding for macos-aarch64.** The SDL3 profile
   lists the target (`tools/c-bindgen/profiles/sdl3.tcl`), but only
   `generated/c/sdl3/linux-x86_64` and `linux-aarch64` are committed.
   Generating the macOS binding needs the macOS SDK
   (`BOTLISH_C_SYSROOT_macos_aarch64`, or a Mac) with the pinned clang, and
   a CI job that checks it. That includes the C type of SDL's enumeration
   constants on that target (AGENTS.md: never one C scalar for both of
   Linux's and MSVC's).
2. **The static SDL3 link plan in the staged package.** The game stages
   its binding as a package (`tools/c-bindgen.tcl stage -package 1`). On
   macOS that package needs `extern c library "SDL3" static at ...` and
   the frameworks SDL3's `sdl3.pc` names, as
   `tests/platform/link-plan-sdl3.sh` and this acceptance write them.
3. **A macOS entry program**, `main-darwin.bot`, which installs
   `std::darwin::io::create()` and `sdl::create()` and runs `game::main`,
   like `main-windows.bot`. Everything else stays in `game.bot`, one
   source for every platform.
4. **A build script** that emits the game with `-native-startup
   main-thread`, and the workload's executable tests on macOS
   (`tests/workload-icy-tower.test`'s executable half needs a macOS SDL3:
   `tests/cffi/sdl3.tcl` builds Linux's and Windows'), plus a session check
   in the census's style (`screencapture` of the window) instead of
   `xvfb-session.py`'s X11.
5. Nothing more from the runtime: the game's recursion is shallow, SDL3
   pumps its own events, and its objects stay behind the `Sdl` context on
   the one thread that runs the program.

## 38. Exact files changed

Production code:

| File | Change |
|---|---|
| `native/src/runtime/program.rs` | `LinkedProgram.startup` (the seventh word); `Startup` (word, name, parse); `startup_of`; `read_linked` checks the word; tests of the policy and the layout |
| `native/src/runtime/aotimage.rs` | the fingerprint covers the record's layout (`RECORD_LAYOUT`, `abi_fingerprint_for`); the stub's loader reads the policy (`Loaded::startup`) and refuses the main thread; a test of the fingerprint's cover |
| `native/src/runtime/aot.rs` | `MAIN_THREAD_STARTUP`; `start_linked`; `linked_main` through it; `run(startup, ...)` with one body on a worker or on the calling thread; `on_this_thread`, `panicked`, `injected_fault`, `startup_facts`; tests of the caught panic and the refusal |
| `native/src/runtime/vm.rs` | `Vm::native_stack` (an accessor, for the report) |
| `native/src/runtime/library.rs` | a library's record must name the worker |
| `native/src/codegen/mod.rs` | `emit_executable_object(program, startup)`; the record's seventh word; a library's object names the worker; tests of the recorded policy and of the one-byte difference |
| `native/src/codegen/aot.rs` | the startup crate calls `start_linked`; `MAIN_STACK_BYTES`; `startup_refusal`; `emit_executable(..., startup)`; `startup_link_args` in both linkers' links; the stub refuses a main-thread executable; tests of the link arguments and the refusal |
| `native/src/main.rs` | `executable --startup`, `extract_startup`, the refusal (`NATIVE UNSUPPORTED startup`); a linked run's worker |
| `native/native.tcl` | the capability `mainThreadStartup`; `native::StartupPolicy`; `native::executable -startup` |
| `main.tcl` | `-native-startup POLICY` (the table, the header, the checks) |

Tests, tools, CI and documentation:

| File | Change |
|---|---|
| `tests/main-thread-startup.test` | new: the policy on every host, the main thread on macOS (section 31) |
| `tests/cffi/mainthread-fixture.c` | new: the C witness (pthread_main_np / gettid, the thread's stack, a fault, a sleep) |
| `tests/helpers.tcl` | the constraints `mainThreadStartup`, `notMainThreadStartup` |
| `tests/main-cli.test` | eight malformed invocations of `-native-startup` |
| `tests/system-linker.test` | the record's comment (seven words) |
| `tests/platform/native-status.tcl` | the probe `main-thread-executable`, per host |
| `tests/platform/aot-facts.tcl` | `main-thread-executable` (macOS: LC_MAIN, signature, report) or `main-thread-refused` |
| `tests/platform/tier.tcl` | `native-aot-mutants=NAMES`, `native-stack-mutants=NAMES` |
| `audit/native-aot/tools/mutants.txt`, `mutate.tcl` | 19 mutants of the policy; two stale mutants repaired, one retargeted; the detectors (main-thread-startup.test, the new unit tests) |
| `audit/native-stack/tools/mutants.txt`, `mutate.tcl` | `macos-size-from-rlimit`; the detector main-thread-startup.test |
| `audit/c-ffi/tools/mutants.txt`, `audit/native-link-plan/tools/mutants.txt` | two mutant texts updated to the new signatures |
| `audit/main-thread-startup/` | new: the graphical acceptance (`tools/acceptance.py`), its README |
| `.github/workflows/macos-arm64.yml` | the `main-thread-startup` job |
| `compilerpedia/topics/backends.topic`, `errors-runtime.topic` | section 35 |
| `AGENTS.md`, `docs/*.md` | section 35 |


## 39. Commands for reproducing the acceptance

Linux (any host): the policy's tests, the CLI, the Rust tests, the status
and facts scripts, the mutants:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
CORE_BACKEND=interp tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" -file "main-thread-startup.test main-cli.test system-linker.test"
cargo test --release --manifest-path native/Cargo.toml --lib -- aotimage program runtime::aot
cargo test --release --manifest-path native/Cargo.toml --bin botlish-native -- aot startup
tclsh9.0 tests/platform/native-status.tcl
tclsh9.0 tests/platform/aot-facts.tcl
tclsh9.0 audit/native-aot/tools/mutate.tcl
tclsh9.0 main.tcl -native-startup main-thread -emit-native-executable examples/surface/02-recursion.bot   # Linux: NATIVE UNSUPPORTED startup
```

macOS (Apple Silicon, Apple's developer tools, Tcl 9.0.1 from
`tests/platform/setup-macos.sh`, Rust): the same, then the application, the
static SDL3 and the acceptance -- what the `main-thread-startup` job runs:

```sh
single/macos/build.sh -o dist
export BOTLISH_SDL3_STATIC_PREFIX="$HOME/Library/Caches/botlish-sdl3-static"
bash tests/platform/link-plan-sdl3.sh dist/Botlish.app
dist/Botlish.app/Contents/MacOS/botlish -native-startup main-thread -emit-native-executable app.bot
otool -l app | grep -A3 LC_MAIN          # stacksize 536870912
BOTLISH_NATIVE_STARTUP_REPORT=/dev/stdout ./app | tail -n 3   # startup main-thread / thread main / stack usable 536870912 guard ...
python3 -I audit/main-thread-startup/tools/acceptance.py --work /tmp/mts --out mts-results \
  --sdl-prefix "$BOTLISH_SDL3_STATIC_PREFIX" --app dist/Botlish.app --repeat 10
python3 -I audit/main-thread-startup/tools/acceptance.py --work /tmp/mts2 --out mts-results-checkout \
  --sdl-prefix "$BOTLISH_SDL3_STATIC_PREFIX" --app dist/Botlish.app --checkout "$PWD" \
  --tclsh "$(command -v tclsh9.0)" --only identity,lc-main,report,semantics,graphical
```

The macOS mutants, from a branch: a pushed head commit with `[ci-full]` and a
`CI-Tests: native-aot-mutants=NAMES native-stack-mutants=NAMES` trailer
(section 29).

