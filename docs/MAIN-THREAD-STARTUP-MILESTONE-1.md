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

**Done.** A standalone executable has a startup policy, fixed when it is
linked and recorded in its `botlish_program` record: `worker`, the
default and every target's, exactly the startup before this milestone, or
`main-thread`, macOS AArch64's, which runs the unchanged program on the
process's main thread with a 512 MiB stack reserved by the link (LC_MAIN).

```sh
botlish -native-startup main-thread -emit-native-executable app.bot
```

On GitHub's macos-15 runners (**Executed**, run 40969956997), through the
packaged Botlish.app with the checkout inaccessible and no Rust on PATH, a
Botlish SDL3 program built with the policy opened a Cocoa window, rendered
with Metal, presented 30 frames and 3 from a kept coroutine, polled its own
quit event back and shut down; the screen capture shows what it drew. The
same program built with the default policy fails as before ("No available
video device"). The rustc and system linkers produce the same result; GC
stress, kept coroutines, deep recursion (10^6 frames), stack exhaustion
(`NATIVE LIMIT STACK`), faults, errors, the driver protocol, signals and
panics (`native executable panicked (NATIVE BUG)`, status 1) behave as on
the worker. Linux and Windows refuse the policy before anything is linked
(`NATIVE UNSUPPORTED startup`), and every worker executable starts as
before, at the same speed and size (section 30).

What remains different on the main thread, by design: its stack is 512
MiB (the worker's is 1 GiB by default) and cannot be resized when the
program runs. What remains undone: a macOS event-loop driver, a graphical
macOS Icy Tower (section 37), main-thread startup on Linux or Windows, and
notarized distribution (section 36).

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

`otool -l`'s LC_MAIN `stacksize`, read line by line (**Executed**, macOS
run 40969956997, the `main-thread-startup` job's acceptance, `lc-main-*`;
`mts-main-lc-main`; `aot-facts.tcl`'s `main-thread-executable`):

| Executable | Linker | LC_MAIN stacksize |
|---|---|---:|
| worker (no option) | Botlish.app's (system) | 0 (the system's default) |
| `-native-startup main-thread` | Botlish.app's (system) | 536,870,912 |
| `-native-startup main-thread` | the checkout's system linker | 536,870,912 |
| `-native-startup main-thread` | the checkout's rustc linker | 536,870,912 |

Apple ld refuses more on arm64, and the census's C probes, built again by
this acceptance, still say so: `-stack_size 0x40000000` and `0x80000000` fail
to link with `ld: -stack_size must be <= 512MB on arm64 platforms`
(**Executed**, the same job). The first macOS run read the field as `5`.
The executables were right (the startup report said 512 MiB); the check was
wrong: in one Tcl regular expression a non-greedy `.*?` first makes every
later quantifier non-greedy, and `(\d+)` matched one digit. The tests and
`aot-facts.tcl` now read otool's lines (section 31).

## 14. Main-thread native stack discovery

The runtime finds the main thread's stack the way it finds any other on
macOS (`platform/macos.rs`): libpthread's top and size, the first
accessible address at or above the reported bottom, and the run of
inaccessible mappings directly below it, confirmed with `mach_vm_region`.
The startup report's `stack usable BYTES guard BYTES` line shows what it
found (**Executed**, macOS):

| Executable | usable | confirmed guard |
|---|---:|---:|
| worker (1 GiB by default) | 1,073,754,112 | 16,384 |
| main thread, system-linked (Botlish.app's, the checkout's) | 536,870,912 | 16,384 |
| main thread, rustc-linked | 536,854,528 | 32,768 |
| (census, C probe) main thread, default link | 8,372,224 | 58,736,640 |

The fixture's own answer, from C, agrees: `pthread_get_stacksize_np` reports
536,870,912 on the main thread of every main-thread executable (`id-main`,
`id-rustc`, `id-checkout`: `stack_bytes`), against the 8,176 KiB that
`ulimit -s` (RLIMIT_STACK) still reports. libpthread reports LC_MAIN's size,
not the rlimit. The mutant that takes the rlimit for the size
(`macos-size-from-rlimit`) is killed (section 29).

The rustc-linked executable's lowest reported page (16 KiB) is
inaccessible, every time it was run (the smoke job's `aot-facts.tcl`, the
system-linker job's `mts-main-record-and-report`, `report-rustc`, in both
macOS runs). The walk steps over it (`usable_low`) and counts it with the
kernel's page as the confirmed guard: usable 512 MiB less one page, guard
two pages. The system-linked executables' bottom page is accessible. Only
the rustc-linked startup runs Rust's own `main` (its panic names the thread
`'main'`, section 11); the system-linked one starts in the runtime
archive's C `main`. That this is the cause is **not established**. It does
not matter to the runtime, which never trusts the reported bottom, and the
tests accept exactly these two outcomes: 512 MiB, or 512 MiB less its
lowest page. The first macOS run expected exactly 512 MiB everywhere and
failed on the rustc-linked executables (section 31).

## 15. Overflow-guard acceptance

The worker's guard is installed on the main thread: `aot::run`'s one body
calls `OverflowGuard::install_executable` on the thread that runs the
program. Exhausting the main thread's 512 MiB is `NATIVE LIMIT STACK`,
status 1, nothing on standard output and the error line exactly as the
worker's (**Executed**, macOS, run 40969956997):

* the acceptance (Botlish.app): `rt-main-overflow-down`, `-keep`
  (Strings held across calls), `-wide` (wide frames), `-rec` (calls
  through a `Fn`), `rt-main-bigframe-overflow` (9,680-byte frames, probed
  page by page) and `s-main-overflow-line`, each the line, status 1, no
  signal;
* a coroutine's stack exhausted from a program on the main thread
  (`rt-main-co-overflow`): the same line;
* a fault that is no overflow, a store to address 16 from C on the main
  thread (`rt-main-fault`, `mts-policy-fault-not-overflow`): the process
  dies by SIGSEGV (status -11), never relabeled `NATIVE LIMIT STACK`;
* `tests/main-thread-startup.test`'s `mts-policy-overflow` and
  `mts-policy-fault-not-overflow`, with the system and the rustc linker.

The mutant that skips the guard on the main thread (`main-thread-no-guard`)
is killed by `mts-policy-overflow` (section 29). The guard itself, its
signal handler and its classification are unchanged (`platform/guard.rs`);
the census had already run them on the main thread (its section 12).

## 16. Stack-capacity acceptance

The census's recursion probes, built by Botlish.app with each policy,
run 10 times each in the acceptance's timing group and once each in its
runtime group (**Executed**, macOS, run 40969956997):

| Shape, depth | worker (1 GiB) | main thread (512 MiB) | main thread, default 8 MiB (census, experimental) |
|---|---|---|---|
| `down` 10^4, 10^5, 10^6 | 10000, 100000, 1000000 | 10000, 100000, 1000000 | 10^6: NATIVE LIMIT STACK |
| `keep` 10^4, 10^5 | 20000, 200000 | 20000, 200000 | values |
| `wide` 10^4, 10^5 | 0, 0 | 0, 0 | 10^5: NATIVE LIMIT STACK |
| `rec` 10^4, 10^5 | 10000, 100000 | 10000, 100000 | 10^5: NATIVE LIMIT STACK |
| `big` 100 (9,680-byte frames) | 928487700 | 928487700 | value |
| each shape without end | NATIVE LIMIT STACK | NATIVE LIMIT STACK | NATIVE LIMIT STACK |

`mts-policy-depth` runs `down` 10^6 and `keep`, `wide`, `rec` 10^5 with
both linkers on both policies, on every host (the main thread on macOS
only), and kills the mutants that drop LC_MAIN's size from either link
(section 29): with the 8 MiB default, three of them end in `NATIVE LIMIT
STACK`.

512 MiB is half the worker's default. No probe here needs more; a program
that needs between 512 MiB and 1 GiB of stack returns its value on the
worker and ends in `NATIVE LIMIT STACK` on the main thread (section 36).

## 17. GC root correctness

`BOTLISH_NATIVE_GC_STRESS=1` (a collection at every allocation site) on
the main thread (**Executed**, macOS, run 40969956997):

* the startup report under GC stress names the same Vm as the worker's
  (`report-main-gc`, `mts-main-gc-stress-report` with both linkers);
* Strings held across 3,000 frames of the main stack (`rt-main-keep-gc`:
  6000), large frames (`rt-main-bigframe-gc`: 7928616), the kept and
  abandoned coroutines (`rt-main-kept-gc`; `t-main-kept-gc`, ten runs):
  the worker's values;
* SDL3 through Cocoa and Metal under GC stress on the main thread
  (`g-main-cocoa-gc`): EXECUTED-COCOA; the dummy driver
  (`t-main-sdl-headless-gc`, ten runs): EXECUTED-HEADLESS;
* `mts-policy-gc-stress`: the kept coroutines and `keep 3000` with both
  linkers and both policies.

Nothing of the collector, the stack maps or the frame walk changed: the
walk starts at the program's frames on whichever stack runs them. The
whole test suite under GC stress on macOS (the full tier with
`CI-GC-Stress: 1`) was not run for this milestone.

## 18. Coroutine and suspended-stack correctness

Coroutines keep their own stacks; only the thread that runs the program
changed (**Executed**, macOS, run 40969956997):

* `mts-main-identity` (both linkers): the program's C calls run on the
  process's main thread, on the thread's own stack; a coroutine's C calls
  run on the same main thread, on a stack that is not the thread's
  (`[1, 0, [1, 1]]`; the worker's `[0, 0, [0, 1]]`);
* the census's kept-coroutine program (`kept`: coroutines passed,
  resumed, walked as a tree, abandoned while suspended):
  `[[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]]` on both
  policies, also under GC stress;
* a coroutine's stack exhausted: `NATIVE LIMIT STACK` (`rt-main-co-overflow`);
* SDL3 presenting 3 frames from inside a kept coroutine on the main thread
  (`presented_in_coroutine: 3`, `coroutine_on_own_stack: true`,
  `coroutine_pthread_main: 1` in `g-main-cocoa`): Cocoa and Metal work from
  a coroutine's stack on the main thread, as the census found.

Each coroutine switch publishes the stack it arrives on (unchanged), so the
guard knows the main stack while the program runs there and a coroutine's
while it runs on its own.

## 19. System linker integration

The system linker (`system_link_args`) puts
`-Wl,-stack_size,0x20000000` among its arguments for a main-thread
executable on Apple's flavor only (`startup_main_thread_reserves_lc_main_stack`:
the Apple main-thread link differs from the worker's by that one argument;
GNU and MSVC links are identical for both policies; **Executed** on every
host's Rust tests).

Botlish.app's compiler links a program that calls C with the system linker
(its `auto`). Every main-thread executable of the acceptance's first phase
was linked that way, and the checkout's system linker
(`BOTLISH_NATIVE_LINKER=system`) in its second (**Executed**, macOS, run
40969956997): LC_MAIN 536,870,912, the main thread, the stack, Cocoa. The
static SDL3 3.4.18 archive was linked into them with the frameworks its
`sdl3.pc` names: `otool -L` lists libSystem, libobjc and Apple's frameworks
only, no SDL3 dylib (`deps-main-sdl`, `deps-checkout-sdl`). The macOS
system-linker job (`BOTLISH_NATIVE_LINKER=system` for every test file that
links an executable, `main-thread-startup.test` among them) passed.

## 20. Rustc linker integration

The rustc linker passes the same reservation as `-C
link-arg=-Wl,-stack_size,0x20000000` (`startup_link_args`, rustc's
spelling). Its startup crate is three lines: it names the record and calls
`aot::start_linked` from Rust's `main`. **Executed**, macOS (run
40969956997, the acceptance's checkout phase and `main-thread-startup.test`):

* LC_MAIN 536,870,912 (`lc-main-rustc`, `mts-main-lc-main`);
* the program and its C calls on the main thread (`id-rustc`), the startup
  report's `thread main`, usable 536,854,528 with a 32 KiB guard (section
  14), the same Vm as the worker (`report-rustc`);
* SDL3 through Cocoa and Metal (`g-rustc-cocoa`: EXECUTED-COCOA);
* errors and the driver protocol as the worker's; the injected panic is
  `native executable panicked (NATIVE BUG)`, status 1, after Rust's own
  message naming the thread `'main'` (`s-rustc-panic`,
  `s-rustc-panic-protocol`);
* `mts-main-linkers-agree`: the system- and rustc-linked main-thread
  executables report the same Vm, policy and thread, and print the same.

The mutant that drops the argument from the rustc link
(`rustc-lc-main-dropped`) is killed by `mts-policy-depth` (section 29).

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
its startup report says `startup worker`) and on macOS (run 40969956997,
the acceptance's `id-linked-run` through Botlish.app and through the
checkout: the fixture says the program runs on a thread that is not the
main thread, one of two).

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

The acceptance's first phase runs the packaged compiler the way a user
gets it, and nothing of the checkout (**Executed**, macOS, run
40969956997, job `main-thread startup (macOS arm64)`):

* Botlish.app is the `app` job's artifact (`botlish-macos-aarch64.zip`, its
  SHA-256 checked), unpacked to `$RUNNER_TEMP/Prögram Files/` (a space and
  a non-ASCII letter in the path), `codesign --verify --deep --strict`
  before and after both phases (valid on disk, satisfies its designated
  requirement): the runs left it untouched;
* the checkout is `chmod 000` for the phase (checked unreadable), the
  harness copied out of it first, and `PATH` is the system's
  (`/usr/bin:/bin:/usr/sbin:/sbin`): no rustc (the harness's environment
  line reports none), cargo or tclsh. Apple's `cc`, `otool`, `sips` and
  `screencapture` are the system's;
* Botlish.app's `botlish` builds all 18 executables (9 programs, each
  policy) from a work directory outside any checkout: `-native-startup
  main-thread -emit-native-executable`, the system linker (`auto`), the
  static SDL3 archive and its frameworks;
* 97 cases, every one as predicted: 6 EXECUTED-COCOA, 8
  EXECUTED-HEADLESS, 79 EXECUTED-THREAD, and the 4 FAILED-CORRECTNESS the
  controls predict.

The runner: macOS 15.8.2 (24H232) on GitHub's `macos-15` arm64 image
(20260907.0337.1), a virtual machine with an Aqua session (WindowServer and
loginwindow running, the console user `runner`, one 1024x768 display,
screen-capture access), Xcode 16.4 (SDK 15.5), Apple clang 17.0.0, 16 KiB
pages. The app's own jobs (`app`: build, `verify.sh`, the smoke tests,
`app-test.sh`, `compare.sh`; `app-clean`: without developer tools) passed in
the same run.

## 26. Cocoa/Metal graphical acceptance

The census's SDL3 program (`programs/sdl.bot` over the static SDL3 3.4.18:
`SDL_Init(VIDEO | EVENTS)`, a 320x240 window, a renderer, 30 magenta frames
presented with the events pumped, 3 more from inside a kept coroutine, an
`SDL_EVENT_QUIT` pushed and polled back, everything destroyed and
`SDL_Quit`), compiled by Botlish.app with `-native-startup main-thread`
and run with nothing that selects the thread (**Executed**, macOS, run
40969956997, `g-main-cocoa`): EXECUTED-COCOA, every fact the census's
classifier requires:

| Fact | Value |
|---|---|
| SDL video driver | `cocoa` (a Cocoa `NSWindow` behind the SDL window) |
| renderer | `metal` |
| `SDL_IsMainThread()` before and after `SDL_Init` | true, true |
| `pthread_main_np()` at every SDL stage | 1 |
| frames presented | 30, and 3 from the coroutine (`coroutine_pthread_main: 1`, on its own stack) |
| the pushed quit | polled back |
| shutdown | window and renderer destroyed, `SDL_Quit` |
| screen capture of the window (320x268) | center pixel (255, 0, 255), 89.5% of the sampled pixels the program's magenta |
| process threads at most | 6 (SDL's and the system's own) |

The acceptance requires the capture: a Cocoa case whose window does not
show the program's color is not as predicted. The same holds for the same
program linked by the checkout's rustc linker (`g-rustc-cocoa`) and system
linker (`g-checkout-cocoa`), under GC stress (`g-main-cocoa-gc`), ten times
in a row (`t-main-sdl`), and with SIGTERM delivered one second in
(`s-main-sigterm-sdl`: SDL's own handler turns it into `SDL_EVENT_QUIT` and
the program ends normally, EXECUTED-COCOA). With `SDL_VIDEODRIVER=dummy` it
runs headless on the main thread (`g-main-headless`): EXECUTED-HEADLESS,
never classified Cocoa.

Timing (median of ten runs, `t-main-sdl`): 1.92 s for the whole process,
the program's entry 14.6 ms after exec, `SDL_Init` 69.6 ms, a frame 52.2
ms (the program's own pacing), `SDL_PumpEvents` 6.0 µs, shutdown 27.2 ms.
The C control (`t-c-main`, the same SDL calls from C's `main`) measured
2.72 s, `SDL_Init` 78.1 ms, a frame 82.6 ms in the same job.

## 27. Graphical positive controls

Each positive control fails as predicted, and each self-test of the
classifier gives its expected class (**Executed**, macOS, run 40969956997):

| Case | What it shows | Outcome |
|---|---|---|
| `c-main-cocoa` | the session can make a Cocoa window at all: C's `main`, the same SDL calls | EXECUTED-COCOA, its capture (255, 128, 0) |
| `g-worker-cocoa` | the worker executable of the same program, the default: SDL refuses Cocoa off the main thread (the census's finding) | FAILED-CORRECTNESS: `No available video device`, `pthread_main_np` 0, while `SDL_IsMainThread()` says true |
| `g-worker-headless`, `-gc` | the worker with the dummy driver | EXECUTED-HEADLESS |
| `pc-dummy-not-cocoa` | a dummy-driver run on the main thread is never Cocoa | EXECUTED-HEADLESS |
| `pc-baddriver` | `SDL_VIDEODRIVER=nonexistent`: no window may be claimed | FAILED-CORRECTNESS |
| `pc-nopump` | the pushed quit never polled | FAILED-CORRECTNESS (`quit_seen` missing) |
| `pc-nodestroy` | nothing destroyed, no `SDL_Quit` | FAILED-CORRECTNESS (`destroyed` missing) |
| oracle self-tests (5) | a complete Cocoa record; a dummy driver claimed as Cocoa; Cocoa off the main thread; a value claiming a window the fixture did not see; the quit never polled | Cocoa, headless, and three FAILED-CORRECTNESS, as expected |

The worker's failure is the reason for this milestone; it is unchanged,
and stays the default.

## 28. Process and linked-run parity

How a program leaves the process is the worker's on the main thread
(**Executed**: macOS run 40969956997 for both policies and both linkers;
Linux x86-64, Linux AArch64 and Windows CI for the worker):

| Case | worker | main thread (Botlish.app, rustc, checkout system) |
|---|---|---|
| a handled declared error (`declared`) | `1008`, status 0 | the same |
| a runtime error (`runtime`) | `+: expected int, got [true] (CORE SEMANTIC TYPE)`, status 1 | the same |
| the driver protocol (`BOTLISH_NATIVE_RESULT`) | the error line in the file, status 0 | the same |
| the protocol, three runs (`BOTLISH_NATIVE_RUNS=3`) | `times`, `timing`, `value {int 1008}` | the same |
| an unwritable startup report | `... (NATIVE IO)`, status 2 | the same |
| a runtime panic (`BOTLISH_NATIVE_RUNTIME_FAULT=panic`) | `native executable panicked (NATIVE BUG)`, status 1 | the same, plainly and in the protocol |
| stack exhausted | the `NATIVE LIMIT STACK` line, status 1 | the same |
| SIGTERM, SIGINT during a 5 s C call | killed by the signal (15, 2) after about 1 s | the same: the runtime installs no handler on either thread |
| standard input to standard output (`mts-policy-stdin-stdout`; Darwin's `read`/`write`, Linux's syscalls) | `hello from stdin`, 17 | the same |
| arguments, values, errors, protocol (`mts-policy-parity`) | | identical outputs, errors and statuses |

A linked run (`-backend cranelift` of a program that calls C) is a worker
executable whatever runs it: Botlish.app's `botlish -backend cranelift`
ran the identity program on a thread that is not the main thread
(`id-linked-run`: `pthread_main_np` 0, two threads), and
`mts-linked-run-is-worker`'s startup report says `startup worker`
(**Executed**, macOS and Linux).

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
| `cli-startup-dropped` | main.tcl's `-native-startup main-thread` builds a worker | KILLED: main-thread-startup.test (`mts-cli-startup`) | -- |
| `api-default-main` | `native::executable` defaults to the main thread | KILLED: main-thread-startup.test | -- |
| `api-capability-linux` | the capability table gives Linux the policy | KILLED: main-thread-startup.test (`mts-refused-where-unsupported`) | SKIPPED |
| `api-capability-windows` | the capability table gives Windows the policy | SKIPPED (Windows') | SKIPPED |
| `api-driver-worker` | `native::executable` asks the driver for the worker whatever the policy | SKIPPED (macOS') | KILLED: main-thread-startup.test (`mts-cli-startup`, `mts-main-identity`, `mts-main-gc-stress-report`, `mts-stub-links-worker-only`) |
| `driver-startup-ignored` | the driver's `executable` ignores `--startup` | KILLED: main-thread-startup.test (`mts-driver-refused-where-unsupported`) | -- |
| `driver-startup-anywhere` | the driver takes `--startup` on any command | KILLED: main-thread-startup.test (`mts-driver-option-errors`) | -- |
| `driver-default-main` | the driver's `executable` defaults to the main thread | KILLED: native-executable.test, system-linker.test | -- |
| `startup-anywhere` | every host takes the policy for supported | KILLED: Rust (`startup_main_thread_is_macos_aarch64s_only`), main-thread-startup.test | SKIPPED |
| `record-startup-unwritten` | the record never carries the policy | KILLED: Rust (`startup_policy_is_recorded`, `..._the_objects_only_difference`) | -- |
| `record-startup-ignored` | the runtime reads every word as the worker | KILLED: Rust (`linked_program_startup_policy`), main-thread-startup.test (`mts-damaged-startup-word`) | KILLED: Rust (`linked_program_startup_policy`), main-thread-startup.test (`mts-cli-startup`, `mts-main-identity`, `mts-main-gc-stress-report`) |
| `record-startup-unchecked` | a word naming no policy reads as the worker | KILLED: Rust, main-thread-startup.test (`mts-damaged-startup-word`) | -- |
| `fingerprint-ignores-record` | the ABI fingerprint leaves the record layout out | KILLED: Rust (`aot_fingerprint_covers_the_record_layout`) | -- |
| `main-thread-spawns-worker` | a main-thread executable runs on a worker after all | SKIPPED (macOS') | KILLED: main-thread-startup.test (`mts-main-identity`, `mts-panic-is-native-bug`, `mts-cli-startup`, `mts-main-gc-stress-report`) |
| `main-thread-panic-escapes` | a main-thread panic unwinds out of `run` (status 101) | KILLED: Rust (`startup_on_this_thread_catches_a_panic`) | KILLED: Rust (`startup_on_this_thread_catches_a_panic`), main-thread-startup.test (`mts-panic-is-native-bug`) |
| `main-thread-no-guard` | a main-thread executable runs unguarded | SKIPPED (macOS') | KILLED: main-thread-startup.test (`mts-policy-overflow`) |
| `system-lc-main-dropped` | the system linker drops LC_MAIN's stack size | KILLED: Rust (`startup_main_thread_reserves_lc_main_stack`) | KILLED: Rust (`startup_main_thread_reserves_lc_main_stack`), main-thread-startup.test (`mts-policy-depth`) |
| `rustc-lc-main-dropped` | the rustc linker drops LC_MAIN's stack size | SKIPPED (macOS') | KILLED: main-thread-startup.test (`mts-policy-depth`) |
| `stub-runs-main` | the stub runs a main-thread image on a worker | KILLED: main-thread-startup.test (`mts-damaged-startup-word`) | SKIPPED |
| `startup-no-guard` (repaired) | an executable runs without the guard | KILLED | -- |
| `sys-runtime-variable-ignored` (repaired) | `BOTLISH_NATIVE_RUNTIME` is not read | KILLED | -- |
| `sys-startup-failure-succeeds` (repaired) | an unreadable record (magic, build, policy) exits 0 | KILLED | -- |
| `macos-size-from-rlimit` (native-stack) | the main thread's size read as the stack rlimit (8 MiB): LC_MAIN's 512 MiB unused | SKIPPED (macOS') | KILLED: Rust (`this_threads_stack_contains_the_stack_pointer_and_has_a_confirmed_guard`) |

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
native-link-plan's `system-loses-static` (by `nlp-linkers-agree`). The
native-stack campaign on Linux x86-64 (all of its mutants, the new
detector included): 51 mutants, 22 killed, 0 survived, 29 skipped (macOS'
and Windows' code).

macOS AArch64 (**Executed**: run 40931039959, the full tier's
`native-aot-mutants=...` and `native-stack-mutants=...` items, macos-15):
native-aot 7 of 7 killed, native-stack 3 of 3 killed (with
`macos-guard-assumed` and `macos-reported-bottom-trusted`, both killed by
`native_stack`'s checks of the main thread and of a pthread). That run's
tree still had the three check mistakes section 31 records
(`mts-main-lc-main`, `mts-main-linkers-agree`, `mts-main-record-and-report`,
`aot-facts.tcl`'s and `native-status.tcl`'s `main-thread-executable` failed
without any mutant). The table names only the detectors that pass on the
unmutated tree: every mutant has at least one.

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

**macOS AArch64, both policies** (**Executed**: run 40969956997, the
acceptance's `timing` group, Botlish.app's executables, ten runs each,
median [min, max]):

| Case | worker | main thread |
|---|---|---|
| the identity program, whole process | 8.547 ms [7.417, 15.164] | 9.443 ms [7.174, 11.105] |
| its entry, since exec | 7.684 ms [6.786, 13.606] | 8.316 ms [6.598, 10.347] |
| the kept coroutines under GC stress, whole process | 5.198 ms [4.111, 5.926] | 4.811 ms [3.608, 12.955] |
| SDL3 headless (dummy driver), whole process | 1667 ms [1567, 1828] | 1685 ms [1524, 1841] |
| SDL3 headless, a frame | 49.8 ms | 49.1 ms |
| SDL3 headless under GC stress, whole process | 2578 ms [1453, 3105] | 1506 ms [1316, 1770] |
| SDL3 through Cocoa and Metal, whole process | (fails: section 27) | 1924 ms [1661, 2125] |

Every difference is within the spread of a shared runner; the main
thread's startup creates no thread and joins none, the worker's creates a
1 GiB one. `aot-facts.tcl`'s whole-process startup of a trivial worker
executable on the same runners: a median of 3.9 to 4.4 ms.

A main-thread executable's program object differs from a worker one's by
one byte (section 6), and its link by one argument, which sets LC_MAIN's
`stacksize` field (already there in every executable). The two policies'
executables are the same size (**Executed**, the same run, Botlish.app's
system linker): `sdl` 3,677,704 bytes, `big` 3,230,488, `kept` 889,720,
`depth` 870,136, `errors` 854,664, `co_overflow` 853,336, `sleep` 832,360
for each policy; `identity` and `fault` differ by 16 bytes (850,456
against 850,472; 832,296 against 832,312), within the ad hoc signature.

## 31. macOS CI results

Two runs of `.github/workflows/macos-arm64.yml` on the branch, both
started by hand (`workflow_dispatch`) so that a later push would not
cancel them:

**Run 40931039959** (head `0f52016f`, `tier=full` with the mutants of
section 29). The program ran on the main thread wherever it was asked to;
four mistakes of the checks, not of the startup, made jobs red:

| Job | Outcome | Why |
|---|---|---|
| smoke | failure | `runtime::platform::macos`'s `region_reads_the_protection_of_a_mapping` (a test older than this milestone): its fresh mapping had another test thread's guard directly below, and the guard walk rightly went on into it; `aot-facts.tcl` read LC_MAIN's size as `5` (section 13) and expected exactly 512 MiB usable (section 14) |
| system linker | failure | `main-thread-startup.test`: the same two checks (`mts-main-lc-main`, `mts-main-record-and-report`, `mts-main-linkers-agree`); its other 3,444 tests passed |
| acceptance shard 1 | failure | the same three tests; 120 other Tcl files and 55 golden suites passed |
| acceptance shard 2 | cancelled | 75 minutes: `tier.tcl` deals the test files to shards by position, and the new file moved about 60 files each way (shard 1 took 43 minutes); on main the shards take 47 to 70 |
| full shard 1 | success | the macOS mutants (section 29) |
| main-thread startup | failure | its policy test step failed (above), and the steps after it had no `if`: the graphical acceptance never ran |
| app, app-clean, static SDL3, linux control | success | |

Fixed in `314afefb` (the checks read otool's lines and accept 512 MiB or
512 MiB less its lowest page; the region test keeps an accessible page
below its guard; the acceptance shards get 120 minutes) and `6fe5057f`
(the acceptance steps run whatever failed before them).

**Run 40969956997** (head `6fe5057f`, `tier=acceptance`):

| Job | Outcome |
|---|---|
| smoke (Tier A: the Rust tests, `native-status.tcl`, `aot-facts.tcl`, the smoke tier) | success |
| system linker (`main-thread-startup.test` and every executable test file with the system linker) | success |
| Botlish.app (build, verify, the smoke tests, `app-test.sh`, `compare.sh`) | success |
| Botlish.app without developer tools | success |
| main-thread startup (`main-thread-startup.test`: 23 passed, 2 skipped (`notMainThreadStartup`); `native-status.tcl`; `aot-facts.tcl`; the acceptance through Botlish.app: 97 cases; through the checkout's linkers: 64 cases) | success, every case as predicted |
| acceptance (Tier B) shard 1 | success |
| acceptance (Tier B) shard 2 | MACOS-SHARD2-PENDING |
| static SDL3 through Botlish.app | MACOS-SDL3-PENDING |
| linux control | success |

On macOS `native-status.tcl` records `main-thread-executable` as
`{macho arm64 execute} 6765 main 512MiB`, and every other row unchanged.

## 32. Linux x86-64 CI results

`tests.yml`, run 40945618194 on `d566f3a1` (started by hand; the commit
carries `[skip ci]` so that it would not cancel the macOS run queued for
the branch; it differs from the later heads only in tests, the acceptance,
the macOS workflow and macOS-only code): the Tcl suite on interp and on
compile, the golden suites (four shards), the system- and stub-linked
executables, the native Rust unit tests, the warning gate, the
cranelift-generic coverage and the method-call oracle all passed. The
cranelift coverage job lost its runner after two hours ("The hosted runner
lost communication with the server"; on main the job takes 66 minutes):
its one re-run: LINUX-RERUN-PENDING. `main-thread-startup.test` under
`CORE_BACKEND=cranelift` takes 16 seconds here.

Before CI, this sandbox (Linux x86-64, four cores) ran the whole local
suite (`tests/local.tcl`): every golden suite on all four backends, every
Tcl test file on interp and compile. It found one regression of this
milestone: the startup report's Linux thread check called libc's `getpid`,
so every Linux executable imported it, and `linux-syscall.test` requires
that a program making raw syscalls link none of libc's. `d566f3a1` asks the
kernel for both ids; the file passes (23 of 23), and so does every other
file: 109 golden suites, 241 Tcl files.

The single-executable workflow (run 40928954017, `11a5f183`: the Linux
x86-64 and AArch64 builds, the smoke and C FFI smoke tests in stock Ubuntu
24.04 and latest) passed.

## 33. Linux AArch64 CI results

`tests-arm64.yml`, run 40945624818 on `d566f3a1` (started by hand):
success. The Tcl suite on interp and on compile, its cranelift and
cranelift-generic coverage, the golden suites (four shards), the
system-linked executables, the native Rust unit tests and the GC-stress
run all passed. `main-thread-startup.test` runs there with the worker
policy and the refusal of `main-thread` (`linux-aarch64`: NATIVE
UNSUPPORTED startup).

## 34. Windows CI results

`windows-x86_64.yml`, run 40931026140 on `0f52016f` (the code is the
final one for Windows: later commits change tests, the acceptance, the
macOS workflow and Linux- or macOS-only code): success.

* smoke: the Rust tests (`startup_main_thread_refused_where_unsupported`,
  `startup_on_this_thread_catches_a_panic`, `linked_program_startup_policy`,
  `startup_main_thread_is_macos_aarch64s_only`,
  `startup_main_thread_reserves_lc_main_stack`, the record tests among
  them); `native-status.tcl`'s `main-thread-executable`: `NATIVE
  UNSUPPORTED startup`, with Windows' reason; `aot-facts.tcl`; the
  executable and C runtime checks;
* root plans, system linker: success;
* acceptance, four shards: success. `main-thread-startup.test` ran in
  shard 3: 17 tests passed, 8 skipped (`mtsMain` 5: the main thread's own;
  `mtsFixture` 2 and `mtsEcho` 1: the C fixture and the echo program are
  POSIX's).

`icy-tower-windows.yml` (runs 40928923072 and 40931026249) passed: the
Windows game builds and runs as before.

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

