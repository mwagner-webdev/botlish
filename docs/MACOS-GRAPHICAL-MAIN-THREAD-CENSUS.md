# MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md

Hosting a graphical application on macOS without compromising Botlish's
native runtime: how an AOT-compiled Botlish program should take part in
macOS's graphical main-thread model.

> **Follow-up:** the recommendation is implemented by
> MAIN-THREAD-STARTUP-MILESTONE-1.md: `-native-startup main-thread` builds
> a macOS AArch64 executable that runs its program on the process's main
> thread with a 512 MiB LC_MAIN stack, and this census's harness now runs
> candidate A on that production policy (`tools/census.py`, macos-arm64.yml's
> `main-thread-startup` job). Everything below is the census as it was run,
> on the disposable experimental runtime; candidate B's experiment is
> rebuilt at the census's base commit, the only one the patch applies to.

A census, not a milestone: executable evidence, three architectures
compared, and a recommendation for the smallest next implementation. No
production code changed. The probes, a disposable experimental runtime
patch, the harness and the recorded outcomes are under
`audit/macos-graphical-main-thread/` (its README lists them); the macOS
evidence comes from GitHub's `macos-15` Apple Silicon runners through
`.github/workflows/macos-graphical-main-thread.yml` (the shared Apple
Silicon development machine was not used).

> Botlish must be able to run as a citizen of a host-owned graphical
> environment. The process main thread, native stack and event lifecycle
> belong to the host's contracts; Botlish's GC, coroutines and safety
> guarantees belong to its own.

Every result below is marked:

* **[macOS]** executed on the actual target: the `macos-15` arm64 runner,
  run 40825370442 (run 1, commit a5c6ca45) unless another run is named
  (run 2: 40827366250, commit 0ef97fd9; run 3: 40828677344, commit
  7e5e2bdf; section 34);
* **[Linux]** executed on Linux x86-64 (this repository's sandbox) --
  never evidence about macOS;
* **[code]** inspected from code or documentation;
* **[experimental]** executed, but on the disposable experimental runtime
  (`patches/main-thread-experiment.patch`), not the production one;
* **[not run]** / **[env-blocked]** no execution evidence.

Outcome classes (the harness's, section 22): EXECUTED-COCOA,
EXECUTED-HEADLESS, EXECUTED-THREAD, UNAVAILABLE-GUI, FAILED-CORRECTNESS,
FAILED-BUILD, NOT-TESTED.

## Contents

1. [Result and recommendation](#1-result-and-recommendation)
2. [The starting AOT execution model](#2-the-starting-aot-execution-model)
3. [The native JIT and native libraries](#3-the-native-jit-and-native-libraries)
4. [The Apple and SDL3 contracts](#4-the-apple-and-sdl3-contracts)
5. [Static SDL3 and the toolchain](#5-static-sdl3-and-the-toolchain)
6. [The runner's graphical session](#6-the-runners-graphical-session)
7. [Thread identity controls](#7-thread-identity-controls)
8. [The C SDL3 graphical control](#8-the-c-sdl3-graphical-control)
9. [Today's Botlish executable and SDL3](#9-todays-botlish-executable-and-sdl3)
10. [Candidate A: the program on the process's main thread](#10-candidate-a-the-program-on-the-processs-main-thread)
11. [The main thread's stack](#11-the-main-threads-stack)
12. [The overflow guard on the main thread](#12-the-overflow-guard-on-the-main-thread)
13. [GC roots on the main thread](#13-gc-roots-on-the-main-thread)
14. [Coroutine stack switching on the main thread](#14-coroutine-stack-switching-on-the-main-thread)
15. [Candidate A, graphically](#15-candidate-a-graphically)
16. [Candidate B: the worker and a main-thread dispatcher](#16-candidate-b-the-worker-and-a-main-thread-dispatcher)
17. [Dispatcher deadlock analysis](#17-dispatcher-deadlock-analysis)
18. [Dispatcher ownership and cleanup](#18-dispatcher-ownership-and-cleanup)
19. [Candidate C: SDL3's callback-owned lifecycle](#19-candidate-c-sdl3s-callback-owned-lifecycle)
20. [Native-library export feasibility](#20-native-library-export-feasibility)
21. [Process error and exit semantics](#21-process-error-and-exit-semantics)
22. [Headless versus Cocoa evidence](#22-headless-versus-cocoa-evidence)
23. [Candidate comparison](#23-candidate-comparison)
24. [Timings and executable sizes](#24-timings-and-executable-sizes)
25. [Positive controls](#25-positive-controls)
26. [Platform-specific and cross-platform limitations](#26-platform-specific-and-cross-platform-limitations)
27. [Consequences for context-owned resources](#27-consequences-for-context-owned-resources)
28. [Consequences for the actor and event-loop model](#28-consequences-for-the-actor-and-event-loop-model)
29. [Consequences for iOS and React Native](#29-consequences-for-ios-and-react-native)
30. [The recommended next milestone](#30-the-recommended-next-milestone)
31. [The production files that milestone would change](#31-the-production-files-that-milestone-would-change)
32. [The regression tests that implementation must keep](#32-the-regression-tests-that-implementation-must-keep)
33. [What is still unobserved](#33-what-is-still-unobserved)
34. [GitHub Actions runs and artifacts](#34-github-actions-runs-and-artifacts)
35. [Reproduction](#35-reproduction)

---

## 1. Result and recommendation

**Today's executable model cannot host a Cocoa application, and SDL3 does
not say so.** Every Botlish instruction and every C call of a standalone
executable runs on a 1 GiB worker thread that the process's main thread
spawns and joins (section 2). On that worker, `SDL_Init(SDL_INIT_VIDEO)`
fails with "No available video device" -- SDL3's Cocoa driver refuses any
thread but the main one -- while `SDL_IsMainThread()` answers **true**
before and after, because SDL3 defines its main thread as the one that
initialized it, not the one that runs `main()` **[macOS]** (sections 4,
9). AppKit itself, without SDL, raises `NSInternalInconsistencyException:
NSWindow should only be instantiated on the main thread!` on a worker and
makes the window on the main thread **[macOS]** (section 7). A C program
with the same static SDL3 archive, on the same runner, creates a real
Cocoa window, renders it with Metal, presents 30 frames, polls a quit event
back and shuts down -- on the main thread, and fails exactly like Botlish
on a joined worker **[macOS]** (section 8). The runner has a genuine Aqua
session with WindowServer, one 1024x768 display and screen-capture access:
the window's pixels were captured (section 6).

**Running the unchanged program on the process's main thread works, with
every runtime guarantee kept, at one cost: stack capacity.** The
experimental runtime's candidate A executes the same `botlish_program`
record, the same Vm initialization and the same compiled entry on the
thread that called `aot::run` -- the process's main thread
**[experimental, macOS]** (sections 10-15):

* the Botlish SDL3 probe -- every SDL operation a call of the Botlish
  program -- is EXECUTED-COCOA: `cocoa` driver, Metal renderer, 30 frames
  on the thread's stack and 3 more from a kept coroutine's own stack,
  events pumped and polled, the window captured (its center pixel the
  program's magenta), destroyed, `SDL_Quit`; also under
  `BOTLISH_NATIVE_GC_STRESS=1`;
* the runtime's stack discovery reads the main thread as milestone 4
  recorded (8,372,224 usable bytes, a confirmed 56 MiB inaccessible
  reservation below), the guard installs there, and every exhaustion --
  small frames, Strings held across calls, wide frames, calls through a
  `Fn`, a 9.5 KiB frame walked by stack probes, a coroutine's stack after
  it yielded -- ends in `NATIVE LIMIT STACK`, status 1; a non-stack fault
  still dies by SIGSEGV, never relabelled; without the guard (the positive
  control) the same overflows die by SIGSEGV and SIGBUS;
* kept coroutines, abandoned suspended coroutines and allocation-heavy
  recursion give the worker's values plainly and under GC stress;
* **but the default main stack is 8 MiB, the worker's 1 GiB**: three finite
  recursions the worker returns (`down(10^6)`, `wide(10^5)`, `rec(10^5)`)
  end in `NATIVE LIMIT STACK` on the main thread -- correctly reported,
  but a regression of capacity. Apple ld's `-stack_size` (LC_MAIN) gives
  the main thread a larger stack with a confirmed one-page guard, **up to
  512 MB on arm64** (ld refuses more: `-stack_size must be <= 512MB on
  arm64 platforms`); linked with 512 MiB, every probe passes, SDL3
  included **[experimental, macOS]** (section 11).

**Candidate B -- the worker plus a main-thread dispatcher -- works, but
moves the problem rather than solving it** **[experimental, macOS]**
(sections 16-18): with the main thread serving the worker's requests
instead of joining it, a full SDL3 lifecycle is EXECUTED-COCOA, every SDL
call on the main thread, at 6.6-10 us per round trip. But every SDL
function needs a C proxy (Botlish cannot pass code to another thread), the
dispatcher's queue is not SDL's own -- `SDL_RunOnMainThread(..., true)`
from the worker deadlocks under the dispatcher just as it does with
`aot::run`'s joining main thread (both demonstrated, a watchdog ending
each) -- and every SDL object is then owned on one thread and usable on
another, which nothing in the language expresses.

**Candidate C -- SDL3's main callbacks -- is a host lifecycle, not a
macOS necessity** (sections 19-20): in C on macOS it is EXECUTED-COCOA with
every callback on the main thread, but on macOS `SDL_EnterAppMainCallbacks`
is SDL's generic loop on the calling thread (no AppKit run loop of its
own) **[code]**, so it offers a macOS desktop program nothing that a
main-thread program loop lacks. Botlish code can be called from those
callbacks only as a native-library export, which runs on the host's thread
and stack -- demonstrated under SDL3's callbacks on Linux, 61 calls from
the process's main thread, also under GC stress **[Linux, headless]** --
and native libraries are Linux glibc's only: `-emit-native-library` is
refused on macOS **[macOS]**.

**Recommendation: candidate A, as an explicit startup policy of a
standalone executable** (section 30): the program's first and only Botlish
thread is the process's main thread when the executable is emitted with
that policy, on macOS, with LC_MAIN's stack size set at link time (512 MiB,
ld's maximum on arm64); the worker remains the default and the only policy
elsewhere; the JIT and native libraries are unchanged; no syntax, no
SDL-specific runtime code, no event loop, no dispatcher. The answers the
census was asked for:

| Question | Answer under the recommendation |
|---|---|
| 1. Who owns the process main thread? | The executable's own `main` (the runtime archive's or Rust's), which runs the Botlish program on it and then exits, as it owns it today. |
| 2. Which OS thread executes ordinary Botlish code? | The process's main thread (for an executable emitted with the policy); the worker otherwise. |
| 3. Who initializes SDL's video subsystem? | The Botlish program, by its own `SDL_Init` call, on the main thread. |
| 4. Who pumps events? | The program (`SDL_PollEvent`/`SDL_PumpEvents`), on the main thread -- its loop, as today. |
| 5. Where do C calls execute? | On the main thread, or a coroutine's stack on it (SDL3 and Cocoa both work from a coroutine stack, section 14). |
| 6. Native stack bounds and overflow? | `NativeStack::current()` of the main thread (macOS discovery already handles it) and the existing guard, installed there; LC_MAIN gives the capacity (512 MiB maximum). |
| 7. How does the GC find roots? | Unchanged: the frame walk of the running stack, bounded by the Vm's stack (the main thread's), and every suspended coroutine stack. |
| 8. How do coroutines switch? | Unchanged: their own mapped stacks, switched on the one thread, each switch publishing the arriving stack. |
| 9. How are native resources cleaned up? | By the program's explicit calls (`SDL_DestroyWindow`, `SDL_Quit`) on the main thread -- the thread Cocoa requires -- as today; nothing at exit. |
| 10. Errors and exit? | Unchanged lines and statuses on standard output and error, and in the driver protocol; the process exits with the program's status (section 21). |
| 11. What changes in executable startup? | `aot::run` runs `init` and the entry on the calling thread when the policy says so; the link passes `-stack_size`; the program record carries the policy. |
| 12. The native JIT? | Unchanged (its own worker; a JIT program calls no C). |
| 13. Native-library exports? | Unchanged (the host's thread and stack). |
| 14. New syntax? | None. |
| 15. Dependencies on the actor/event-loop model? | None, and none obstructed (section 28). |
| 16. A normal synchronous SDL3 application loop? | Yes: `programs/sdl.bot` is one, EXECUTED-COCOA. |

**The evidence** is three census runs on GitHub's `macos-15` runners
(section 34), every case classified by the harness from what the fixture
observed (section 22). Run 1's nine surprises are findings of this report
-- Apple ld's 512 MB ceiling on LC_MAIN and the 8 MiB main stack's three
exhaustions (section 11) -- and became the harness's predictions; run 2
(156 cases, 14 of them EXECUTED-COCOA) and run 3 (159 cases, the same 14)
came out exactly as predicted. The Linux x86-64 runs are the harness's dry run and
Linux's own rows (section 26), never evidence about macOS.

## 2. The starting AOT execution model

Inspected from code at 7aec2a11 (the branch's base), and confirmed by the
identity probes of section 7. A standalone executable, from the operating
system's entry point to its first Botlish instruction:

| # | Step | Code | Thread |
|---|---|---|---|
| 1 | dyld calls `main` | system linker: the runtime archive's `main` (`native/runtime-archive/src/lib.rs:32`); rustc linker: the startup crate's `fn main` (`codegen/aot.rs:140`, `STARTUP`); stub linker (Linux x86-64 only): the stub's loader | process main |
| 2 | `linked_main` (system linker only): `rust_process_setup` -- descriptors 0-2 opened on /dev/null when missing, SIGPIPE ignored, the thread named `main` | `runtime/aot.rs:157, 194` | process main |
| 3 | the argument snapshot: `process_argv()` copies the C runtime's `argc`/`argv` (Rust's `args_os`) | `aot.rs:52`, called in step 1 | process main |
| 4 | `run`: reads `BOTLISH_NATIVE_STACK_BYTES` (default 1 GiB, at least 1 MiB), `BOTLISH_NATIVE_RESULT`, `BOTLISH_NATIVE_STARTUP_REPORT` | `aot.rs:217-224` | process main |
| 5 | spawns the worker: `std::thread::Builder::stack_size(1 GiB)`, libpthread's default guard | `aot.rs:225` | process main creates the worker |
| 6 | `init()`: `program::instantiate_linked` -- the program record checked (`read_linked`), `Vm::new` (which records `NativeStack::current()`, the calling thread's stack, and sets the thread-local current program `PROGRAM`), constants, statics, the frame map | `program.rs:387, 437`; `vm.rs:101, 280-300` | worker |
| 7 | the startup report (`BOTLISH_NATIVE_STARTUP_REPORT`) | `aot.rs:229-236` | worker |
| 8 | `vm.set_argv(argv)`: the snapshot moved into the Vm | `aot.rs:236` | worker |
| 9a | driver protocol (`BOTLISH_NATIVE_RESULT`): the guard installed in the driver's mode (the overflow line to the result file, status 0), `BOTLISH_NATIVE_RUNS` runs with `vm.reset()` between them, result lines to the file | `aot.rs:288-350` | worker |
| 9b | otherwise: `OverflowGuard::install_executable` on the worker's own stack (line to standard error, status 1) | `aot.rs:240-245`, `platform/guard.rs` | worker |
| 10 | `entry(&mut vm)`: compiled Botlish code | `aot.rs:246` | worker |
| 11 | C functions Botlish calls: direct calls from the compiled code (C-FFI.md) | -- | worker (or a coroutine stack on it) |
| 12 | coroutines: created, started, resumed and switched by the runtime (`coroutine.rs`; its stack pool is a thread-local, `coroutine.rs:225`), each switch publishing the arriving stack to the guard | `coroutine.rs` | worker (stack switches, never a thread switch) |
| 13 | collection: the frame walk of the running stack, bounded by `vm.native_stack`, and every suspended coroutine stack | `framewalk.rs`, `heap.rs` | worker |
| 14 | the value printed (`show(result)` to standard output) or the error (`describe_error`, code) to standard error; status 0 or 1 | `aot.rs:248-260` | worker |
| 15 | `worker.join()`; a panic on the worker becomes `native executable panicked (NATIVE BUG)`, status 1 | `aot.rs:263-276` | process main |
| 16 | `std::process::exit(status)` (flushes Rust's standard output) | `aot.rs:209`; `STARTUP` | process main |

So, of the questions the census asks: the process's main thread first
enters the Rust runtime (step 1), captures the arguments, reads the
environment and spawns the worker; the worker initializes the Vm, installs
the program's metadata and stack maps, installs the overflow guard,
executes every Botlish instruction, every C function Botlish calls, every
coroutine, every collection, owns the result and prints it or the error;
the worker *computes* the exit status and the main thread, blocked in
`join()` for the whole run, *applies* it. Nothing else runs on the main
thread while the program runs.

Linkers: the system and rustc linkers reach the same `aot::run` (steps 4-16
are shared code; `tests/system-linker.test` requires the startups' reports
to be equal). The rustc-linked executable's `main` is Rust's: Rust's own
startup (`lang_start`) runs first and installs Rust's handler for its main
thread's guard page. The system-linked one runs `rust_process_setup`
instead, which installs no handler (`aot.rs:140-156`).

## 3. The native JIT and native libraries

**The driver's JIT** (`botlish-native run`, `native::evalHir`, main.tcl's
native backends) has the same shape in another process
(`native/src/main.rs:157-185`): the driver's `main` spawns a 1 GiB worker
(`BOTLISH_NATIVE_STACK_BYTES`), which parses the command, compiles with
Cranelift, builds the Vm, installs the guard in the driver's mode
(`main.rs:857`) and runs the code. The process's main thread joins.
**A JIT-run program never calls C:** a program that calls C is a *linked
run* (C-FFI.md, "Running a program that calls C"; `main.rs:608`
`run_linked`) -- the driver links it as an executable and runs that as a
child process with `BOTLISH_NATIVE_RESULT`, so its Botlish code and its C
calls run on the child's worker through step 9a above. Section 7 confirms
it (`id-botlish-linked-run`). An SDL program run with `main.tcl -backend
cranelift` is therefore an executable like any other, in the driver
protocol's mode.

**Native libraries** (NATIVE-LIBRARY-MILESTONE-1.md, `runtime/library.rs`)
have no worker and no `main` of their own. `NAME_create` makes the Vm on
the *calling* thread and runs the program's initialization there; every
call and `NAME_destroy` must come from that thread (WRONG-THREAD,
`library.rs:204`), one at a time (REENTRANT-CALL), and runs on the
caller's thread **and stack**: the frame walk stops at the call's own frame
(`Vm::stack_ceiling`, `library.rs:250-259`), the thread-local current
program is the instance's for the call and restored after it, and Botlish
recursion is bounded by a stack-pointer check against the running stack's
limit (`NativeStack::stack_limit`, an eighth in reserve) -- a library
installs no guard and never `_exit`s. Libraries are Linux glibc's only
(`codegen::library::SUPPORTED`, `native/library.tcl:108`): on macOS
`-emit-native-library` is refused (`NATIVE UNSUPPORTED library`, section
20).

So the four execution paths already differ in thread ownership:

| Path | Who owns the process's main thread | Thread that runs Botlish code | Its stack | Guard |
|---|---|---|---|---|
| system-linked executable | the runtime archive's `main`: spawns, joins, exits | a 1 GiB worker | the worker's | `install_executable` |
| rustc-linked executable | Rust's `main` (startup crate): the same | the same | the same | the same |
| linked run (driver protocol) | the child executable's `main`: the same | the child's worker | the worker's | `install` (driver mode) |
| JIT (`botlish-native run`) | the driver's `main`: spawns, joins | the driver's worker | the worker's | `install` (driver mode) |
| native-library export | the host | the host's calling thread, any thread the host chooses (one per instance) | the host's | none: a stack-limit check |

The library row is already "host-chosen thread"; only the three executable
rows have a fixed policy, and it is the one policy that keeps Botlish off
the main thread.

## 4. The Apple and SDL3 contracts

### SDL3 3.4.18 (the pinned release; read from its headers and source)

Documentation (the headers the wiki is generated from,
`include/SDL3/*.h`):

* `SDL_Init` / `SDL_InitSubSystem`: "`SDL_INIT_VIDEO`: video subsystem
  ...; should be initialized on the main thread"; thread safety: "This
  function should only be called on the main thread."
* `SDL_CreateWindow`, `SDL_CreateRenderer`, `SDL_RenderPresent`,
  `SDL_PumpEvents`, `SDL_PollEvent`, `SDL_DestroyWindow`,
  `SDL_GetCurrentVideoDriver`, `SDL_Quit`: "should only be called on the
  main thread." `SDL_PushEvent`: "safe to call from any thread."
* `SDL_IsMainThread`: "On Apple platforms, the main thread is the thread
  that runs your program's main() entry point. On other platforms, the
  main thread is the one that calls SDL_Init(SDL_INIT_VIDEO) ... If you
  are using the main callbacks, SDL_AppInit(), SDL_AppIterate(), and
  SDL_AppQuit() are all called on the main thread."
* `SDL_RunOnMainThread(callback, userdata, wait_complete)`: "If this is
  called on the main thread, the callback is executed immediately. If this
  is called on another thread, this callback is queued for execution on
  the main thread during event processing. Be careful of deadlocks ...
  You should not have the main thread wait for the current thread while
  this function is being called with `wait_complete` true."
* `SDL_RunApp`: "Generally this is called once, near startup, from the
  process's initial thread." `SDL_EnterAppMainCallbacks`: "not safe to
  call ... anywhere except as the only function call in SDL_main."
  `SDL_AppIterate`/`SDL_AppEvent`/`SDL_AppQuit`: `SDL_AppEvent` "may get
  called concurrently with SDL_AppIterate() or SDL_AppQuit() for events
  not pushed from the main thread."

What the implementation does, which the documentation does not say:

* **`SDL_IsMainThread()` is initialization-defined, on Apple too**
  (`src/SDL.c:272-289`): it compares the current thread with the thread
  that initialized video, else events, else the first `SDL_Init` of
  anything (`SDL_InitMainThread`, `SDL.c:292-299`), and **before any
  initialization it returns true on every thread**. Nothing in it asks
  the operating system which thread runs `main`. So on a worker that calls
  `SDL_Init` first, SDL calls the worker its main thread, whatever the
  header says. Sections 7 and 9 observe it. SDL's answer is therefore
  never evidence of thread identity in this census: `pthread_main_np()`
  and `[NSThread isMainThread]` are.
* **Cocoa refuses a worker without an error of its own**
  (`src/video/cocoa/SDL_cocoavideo.m:63`): `Cocoa_CreateDevice` returns
  NULL unless `[NSThread isMainThread]` ("this doesn't SDL_SetError()
  because SDL_VideoInit is just going to overwrite it"). With no
  `SDL_VIDEODRIVER` hint every other driver on macOS (offscreen, dummy) is
  demand-only, so `SDL_Init(SDL_INIT_VIDEO)` on a worker fails with "No
  available video device"; with the hint `cocoa`, "cocoa not available"
  (`src/video/SDL_video.c:659-697`). An `SDL_assert(SDL_VideoThreadID ==
  SDL_MainThreadID)` for Apple (`SDL.c:406`) is compiled out of a release
  build.
* **`SDL_RunOnMainThread` runs the callback on the calling thread** when
  `SDL_IsMainThread()` is true *or events were never initialized*
  (`src/events/SDL_events.c:1405-1410`); otherwise it queues it and wakes
  the main thread (`SDL_SendWakeupEvent`), and only
  `SDL_PumpEventsInternal` -- `SDL_PumpEvents`, `SDL_PollEvent`,
  `SDL_WaitEvent*` on the main thread -- drains the queue
  (`SDL_RunMainThreadCallbacks`, `SDL_events.c:1509`). With
  `wait_complete` the caller waits on a semaphore without a timeout.
* **The main callbacks on macOS are a plain loop**
  (`src/main/generic/SDL_sysmain_callbacks.c`): `SDL_RunApp` is the
  generic one (`src/main/SDL_runapp.c`: `SDL_SetMainReady` and a direct
  call), and `SDL_EnterAppMainCallbacks` calls `SDL_AppInit`, then
  `SDL_PumpEvents` and `SDL_AppIterate` in a loop on the calling thread,
  then `SDL_AppQuit` and `SDL_Quit`. It owns no AppKit run loop (no
  `[NSApp run]`): on macOS the callback model is an inversion of control,
  not a different relationship with Cocoa. iOS has its own
  (`src/main/ios/SDL_sysmain_callbacks.m`, a CADisplayLink on the main run
  loop).
* `SDL_main.h` defines neither `SDL_MAIN_NEEDED` nor `SDL_MAIN_AVAILABLE`
  for macOS: a program with its own `main` -- Botlish's -- needs no
  `SDL_SetMainReady` there.

### Apple

Apple's Threading Programming Guide ("Thread Safety Summary", archived
2014, "subject to change") is the documentation that states AppKit's
rules: "The main thread of the application is responsible for handling
events" (`NSApplication`'s `run`); `NSView` and its descendants are
main-thread-only for creation, destruction, resizing and moving; drawing
from secondary threads needs `lockFocusIfCanDraw`. It still says "You can
create a window on a secondary thread". Current AppKit enforces more than
that text: creating an `NSWindow` off the main thread raises
`NSInternalInconsistencyException` ("NSWindow should only be instantiated
on the main thread!", as reports against VTK, SDL and Apple's own
NSWorkspace show). Rather than trust either text, the census asks AppKit
itself (`native/appkit.m`, section 7): a window made directly, no SDL, on
the main thread and on a worker. The census never infers the contract from
a call that happens to succeed.

## 5. Static SDL3 and the toolchain

**[macOS]** The runner (Host step and the harness's environment census):
macOS 15.7.9 (24G830), Darwin 24.6.0
(`xnu-11417.140.69.711.44~1/RELEASE_ARM64_VMAPPLE`: Apple Silicon under
Apple's virtualization, `kern.hv_vmm_present` 1), 3 CPUs, 7.5 GB, 16 KiB
pages; Xcode 16.4, SDK 15.5, Apple clang 17.0.0 (clang-1700.0.13.5);
rustc 1.99.1; Tcl 9.0.1 built by `tests/platform/setup-macos.sh`.

SDL3 is the pinned release of NATIVE-LINK-PLAN-MILESTONE-1.md: 3.4.18,
commit 829a65d769d935c4852f8159e964312c0957260a
(`tools/c-bindgen/profiles/sdl3.tcl`), built static (and shared) for arm64,
deployment target 11.0, by `tests/platform/link-plan-sdl3.sh` -- the same
script, cache path and key as macos-arm64.yml's `link-plan-sdl3` job,
which this workflow runs whole first: Botlish.app (built in the job by
`single/macos/build.sh`) links the archive into an executable, by a path
from the application root, with the frameworks SDL3's own `sdl3.pc` names,
and the executable runs with no SDL3 dependency (`static SDL3 3.4.18: ok`).
The archive is 4,651,024 bytes. Its `Libs.private`: the frameworks
CoreMedia, CoreVideo, Cocoa, UniformTypeIdentifiers, IOKit, ForceFeedback,
Carbon, CoreAudio, AudioToolbox, AVFoundation, Foundation, GameController,
Metal, QuartzCore and CoreHaptics, the libraries pthread and m.

The census's own links (`tools/census.py`):

* **Botlish probes** declare, in a generated binding module (`probe.bot`
  from `programs/probe.bot.in`), `extern c library "SDL3" static at
  "native/libSDL3.a"`, the fixture's `extern c library "mtprobe" static at
  "native/libmtprobe.a"`, one `extern c framework` per framework above plus
  AppKit, and `extern c library` for pthread, m and **objc** -- the fixture
  asks Foundation through the Objective-C runtime's C interface, which a
  program without SDL's Objective-C objects must link by name (run 1's
  first attempt, a5c6ca45's parent, was fixed before it ran). The binding
  is hand-written from SDL3's headers: 15 functions (section 9), no
  generated macOS binding.
* **Production executables** are built by Botlish.app's own `botlish`
  (`-emit-native-executable`; the application's `auto` linker is the
  system linker on macOS) from another working directory; a rustc-linked
  one by the checkout's `main.tcl` with `BOTLISH_NATIVE_LINKER=rustc`.
* **Experimental executables** are built by the experimental worktree's
  `main.tcl` with `BOTLISH_NATIVE_LINKER=system` (and rustc for the
  rustc-linked rows), its runtime archive the patched one.
* **C controls** are built by Apple clang with the same archive and
  frameworks.

Which calls originate where. In every Botlish probe, the SDL *operations*
-- `SDL_IsMainThread`, `SDL_Init`, `SDL_CreateWindow`, `SDL_CreateRenderer`,
`SDL_SetRenderDrawColor`, `SDL_RenderClear`, `SDL_RenderPresent`,
`SDL_PumpEvents`, `SDL_PollEvent` (a 128-byte `MutableBytes`, `write
noescape`), `SDL_PushEvent` (a `std::binary::emit` of a one-field layout,
`read noescape`), `SDL_Delay`, `SDL_DestroyRenderer`, `SDL_DestroyWindow`,
`SDL_Quit`, `SDL_RunOnMainThread` -- are the Botlish program's own calls.
The fixture (`native/mtprobe.c`, `mtprobe_sdl.c`) only *reads*: thread
identity, stacks, the clock, thread counts, and from SDL `SDL_GetError`
(thread-local), `SDL_GetCurrentVideoDriver`, `SDL_GetRendererName`,
`SDL_GetWindowFlags`, `SDL_GetWindowID` and the window's Cocoa pointer;
`mtp_capture` runs `/usr/sbin/screencapture -x -o -l WINDOW`. The one
exception is candidate B's client (`native/mtdispatch.c`), which makes
the SDL calls on purpose -- it is the dispatcher's client -- and says so in
every line it prints.

## 6. The runner's graphical session

**[macOS]** Before any window was attempted:

| Fact | Value | Source |
|---|---|---|
| launchd manager of the job's processes | `Aqua` (a GUI login session, not `Background`) | `launchctl managername` |
| console user / job user | `runner` / `runner` | `stat -f %Su /dev/console`, `id -un` |
| WindowServer, loginwindow | running (pids 151, 149) | `pgrep -lx` |
| CoreGraphics session | present, on console, login done, user `runner` | `CGSessionCopyCurrentDictionary` (`native/session.c`) |
| displays | 1 active, the main one 1024 x 768 | `CGGetActiveDisplayList`, `CGDisplayPixels*` |
| screen capture permitted | yes (`CGPreflightScreenCaptureAccess` 1) | session.c |
| `SDL_VIDEODRIVER` | unset | environment |
| executables | command-line Mach-O, no `.app` bundle, linker-signed (ad hoc) | Apple ld signs every arm64 executable it links |

So the runner offers a genuine Cocoa session: windows can be created,
rendered with Metal and captured (section 8). `system_profiler
SPDisplaysDataType` printed nothing on the runner (recorded as empty); the
CoreGraphics answers are the census's display evidence. Nothing in the
runner's settings was changed.

## 7. Thread identity controls

**[macOS]** The fixture reports, at a probe's first instruction, three
independent answers: libpthread's `pthread_main_np()`, Foundation's
`[NSThread isMainThread]` (through the Objective-C runtime's C interface),
and whether the calling thread's `pthread_threadid_np` equals the one a
constructor recorded (constructors run on the process's initial thread
before `main`). SDL's `SDL_IsMainThread()` is recorded separately and never
used as evidence (section 4).

| Case | What runs | pthread_main_np | NSThread isMainThread | same thread id as main | stack (bytes) | threads |
|---|---|---|---|---|---|---|
| `id-c-main` | plain C `main` | 1 | 1 | yes | 8,372,224 | 1 |
| `id-c-worker` | C, a 1 GiB pthread the main thread joins | 0 | 0 | no | 1,073,754,112 | 2 |
| `id-rust-main` | plain Rust `main`, then a std thread | 1, then 0 | 1 | yes | 8,372,224 | 1 |
| `id-botlish-aot-prod` | the production executable (Botlish.app, system linker) | 0 | 0 | no | 1,073,754,112 | 2 |
| `id-botlish-aot-rustc` | the production runtime, rustc-linked | 0 | 0 | no | 1,073,754,112 | 2 |
| `id-botlish-linked-run` | `botlish -backend cranelift identity.bot` (a linked run: driver protocol) | 0 | 0 | no | 1,073,754,112 | 2 |
| `id-botlish-exp-worker` | the experimental build, production model | 0 | 0 | no | 1,073,754,112 | 2 |
| `id-botlish-exp-main` | the experimental build, candidate A | 1 | 1 | yes | 8,372,224 | 1 |
| `id-botlish-exp-dispatch` | the experimental build, candidate B (the program's own thread) | 0 | 0 | no | 1,073,754,112 | 2 |

Foundation and libpthread agree in every case. The production Botlish
program runs on a thread that is not the process's main thread, on a 1 GiB
stack (1 GiB plus libpthread's 12 KiB rounding), with the main thread alive
and idle (2 threads); under candidate A the program's first instruction
runs on the main thread itself, the only thread. A JIT-run program cannot
be asked (it calls no C, section 3): `id-botlish-linked-run` is what
`main.tcl -backend cranelift` does with a C-calling program, and it is the
worker.

AppKit's own rule, no SDL involved (`native/appkit.m`):

| Case | Result |
|---|---|
| `c-appkit-main` | `NSWindow` created (windowNumber 30) |
| `c-appkit-worker` | `NSInternalInconsistencyException: NSWindow should only be instantiated on the main thread!` |

That is the contract this census works against, observed on macOS 15.7.9
-- stricter than the archived Threading Programming Guide's "You can
create a window on a secondary thread".

**`SDL_IsMainThread()` on a worker [macOS]**: true before any SDL call and
true after `SDL_Init(SDL_INIT_VIDEO)` failed there, in the C worker control
and in the Botlish production executable alike (`sdl_is_main_before_init`,
`sdl_is_main_after_init` in sections 8 and 9), while `pthread_main_np()`
is 0 -- the implementation section 4 reads.

## 8. The C SDL3 graphical control

**[macOS]** `native/csdl.c`, the lifecycle `programs/sdl.bot` runs, in C,
linked against the same archive and frameworks:

| Case | Thread | Driver | Outcome | Facts |
|---|---|---|---|---|
| `c-main-cocoa` | process main | cocoa | **EXECUTED-COCOA** | Cocoa window, renderer `metal`, 30 frames presented, the pushed quit polled back (7 events), destroyed, `SDL_Quit`; capture: 320 x 268 (the content and the title bar), center pixel (255, 128, 0) -- the orange the control draws -- and 89.5% of the sampled pixels within 48 of it; up to 6 threads (Cocoa's and Metal's) |
| `c-main-headless` | process main | dummy | EXECUTED-HEADLESS | software renderer, 30 frames, quit polled back (18 events) |
| `c-worker-cocoa` | a 1 GiB worker, main joined | none | FAILED-CORRECTNESS | `SDL_Init(SDL_INIT_VIDEO)` false: "No available video device"; `SDL_IsMainThread()` true |
| `c-worker-headless` | the same worker | dummy | EXECUTED-HEADLESS | the dummy driver has no thread rule |

The control establishes the environment: Cocoa windows work on this
runner, on the main thread, from a statically linked SDL3 -- so a Botlish
failure on the worker is not the runner's. And it shows the worker's
failure in C: it is the thread, not Botlish.

## 9. Today's Botlish executable and SDL3

**[macOS]** The production executable -- built by Botlish.app, the
production runtime -- running `programs/sdl.bot`:

| Case | Driver | Outcome | Facts |
|---|---|---|---|
| `bl-worker-cocoa` | (default) | FAILED-CORRECTNESS | the program's value `[true, false, true, [false]]`: `SDL_IsMainThread()` true, `SDL_Init` false, `SDL_IsMainThread()` true; `SDL_GetError()` "No available video device"; every stage on `pthread_main_np` 0; status 0 (the program handled the failure); no crash, no hang |
| `bl-worker-cocoa-hint` | `SDL_VIDEODRIVER=cocoa` | FAILED-CORRECTNESS | "cocoa not available" |
| `bl-worker-headless` | dummy | EXECUTED-HEADLESS | software renderer, 30 frames on the worker's stack and 3 from a kept coroutine's stack, quit polled back |
| `bl-worker-headless-gc` | dummy, GC stress | EXECUTED-HEADLESS | the same value |

The failure is clean and deterministic: SDL3's Cocoa bootstrap returns
NULL off the main thread before touching AppKit (section 4), so nothing
crashes or hangs -- the program simply cannot have a window. Its causes,
told apart by the controls: not the graphical session (the C main control
draws), not the renderer (the failure is before any renderer), not the
binding (the same program draws headless, and on the main thread in
section 15), not Cocoa initialization as such (Cocoa initializes on the
main thread), not a runtime defect (the C worker control fails the same
way): **thread affinity**.

## 10. Candidate A: the program on the process's main thread

**[experimental]** `patches/main-thread-experiment.patch` (202 lines;
`native/src/runtime/aot.rs` and 9 lines of `native/src/codegen/aot.rs`)
reorganizes `aot::run` around one closure, the worker's body today, and
lets the environment choose where it runs:

* `BOTLISH_EXPERIMENT_THREAD=main`: the body runs on the calling thread --
  `linked_main`'s or the rustc startup's `main`, the process's main thread
  -- and `run` returns its status;
* unset: the worker, exactly as today; `dispatch`: candidate B (section
  16);
* `BOTLISH_EXPERIMENT_NO_GUARD=1`: no guard (a positive control);
* `BOTLISH_EXPERIMENT_REPORT=1`: one line of what the runtime found (the
  thread, `NativeStack::current()`);
* at link time, `BOTLISH_EXPERIMENT_MAIN_STACK=SIZE` adds
  `-Wl,-stack_size,SIZE` to the Apple system link.

Nothing else is different: the same `botlish_program` record and
`instantiate_linked`, the same Vm, constants, statics and frame map, the
same `install_executable` (or `install` for the driver protocol), the same
compiled entry, coroutine runtime, collector, value representation, error
reporting and argument snapshot. No interpreter, no trampoline, no second
runtime: the main thread runs the program's normal compiled entry. The
experimental build is a worktree of this commit with the patch applied,
built beside the production one; the workflow checks the checkout
untouched afterwards (`git diff --exit-code`, Botlish.app's signature).

The ten questions of the census's brief, answered by the runs of sections
11-15:

1. `NativeStack::current` discovers the process main stack correctly
   (section 11).
2. The main stack has a confirmed guard: a 56 MiB inaccessible reservation
   by default, one 16 KiB page with LC_MAIN's stack size (section 11).
3. `OverflowGuard::install_executable` installs on the main thread and
   reports its exhaustion (section 12).
4. The handler identifies the guarded thread by `pthread_self()`, which is
   the main thread's (section 12).
5. The frame walk accepts the main thread's bounds: GC stress passes
   (section 13).
6. Safepoints and roots work unchanged (section 13).
7. Coroutine switches work unchanged (section 14).
8. No thread-local assumption breaks: the thread-local current program
   (`vm.rs`'s `PROGRAM`) and coroutine pool (`coroutine.rs`'s `POOL`) are
   simply the main thread's, set by the same code (sections 13-14).
9. Rust's runtime does not need the main thread outside Botlish: the
   rustc-linked startup's main thread runs the program too
   (`a-main-rustc-cocoa`, EXECUTED-COCOA, section 15, and the rustc-linked
   column of section 21, identical to the system-linked one; run 2).
10. The executable's shutdown is unchanged: `run` returns the status and
    `linked_main` (or the startup crate) exits with it (section 21) --
    except a Rust panic, which no longer becomes "NATIVE BUG" status 1
    (section 21).

## 11. The main thread's stack

**[macOS]** `native/mainstack.c` reads the main thread's stack the way the
runtime does (`platform/macos.rs`: libpthread's top and size, the first
accessible address at or above the reported bottom, the run of
inaccessible mappings directly below it), then recurses in 16 KiB frames to
within 256 KiB of the bottom (`touch`), or without end, with a handler on
an alternate stack that reports where the fault was (`overflow`). Linked
once without and once per `-stack_size`:

| LC_MAIN stack size | Link | Usable | Confirmed guard below | RLIMIT_STACK (cur) | Touch | Overflow |
|---|---|---|---|---|---|---|
| (none: the default) | ok | 8,372,224 (8176 KiB, the rlimit) | 58,736,640 (57,360 KiB of reservation) | 8,372,224 | -- | SIGSEGV, 8 bytes below the usable bottom, in the guard |
| 64 MiB (`0x4000000`) | ok | 67,108,864 | 16,384 (one page) | 8,372,224 | 2,454 frames to 254,504 bytes above the bottom | SIGBUS, in the guard |
| 256 MiB | ok | 268,435,456 | 16,384 | 8,372,224 | 10,272 frames | SIGBUS, in the guard |
| 512 MiB (`0x20000000`) | ok | 536,870,912 | 16,384 | 8,372,224 | 22,712 frames | SIGBUS, in the guard |
| 1 GiB (`0x40000000`) | **refused**: `ld: -stack_size must be <= 512MB on arm64 platforms` | -- | -- | -- | -- | -- |
| 2 GiB | refused, the same | -- | -- | -- | -- | -- |

Facts that matter for candidate A:

* **The default main stack is 128 times smaller than the worker's** (8 MiB
  against 1 GiB). Its guard is confirmed (the kernel's 64 MiB reservation,
  of which the top 8 MiB are usable), so it is *safe*; it is *small*.
* **LC_MAIN's stack size works and is honoured exactly**: libpthread
  reports it, all of it is usable, and directly below it the kernel leaves
  one inaccessible 16 KiB page that the runtime's walk confirms -- the
  same shape as a created thread's guard (milestone 4, section 6),
  faulting with SIGBUS like it. RLIMIT_STACK is not raised (it stays 8 MiB,
  so a child process inherits nothing).
* **Apple ld's limit on arm64 is 512 MB.** Whether the kernel would accept
  more was not probed: Botlish links with ld, and patching a Mach-O after
  the link is no option (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md: never a
  patched executable).
* The worker's size is a *run-time* setting today
  (`BOTLISH_NATIVE_STACK_BYTES`, 1 GiB by default, at least 1 MiB); the
  main thread's is a *link-time* property of the executable. A program on
  the main thread cannot have its stack resized by the environment.

The runtime's own reading, from inside the experimental executables
(`BOTLISH_EXPERIMENT_REPORT`):

| Executable | Thread | usable | guard |
|---|---|---|---|
| default link, `THREAD=main` | main (`pthread_main_np` 1) | 8,372,224 | 58,736,640 |
| `-stack_size 0x20000000`, `THREAD=main` | main | 536,870,912 | 16,384 |
| default, worker | worker | 1,073,754,112 | 16,384 |

And the runtime's checks of the main thread in its own test binary
(`native/tests/native_stack.rs`, whose `main` runs on the process's main
thread; this job's log): `runtime stack main: [0x16a9a0000, 0x16b198000)
(16 KiB above the reported bottom), guard [0x167198000, 0x16a9a0000) 57376
KiB`; `guard main driver` and `guard main guard bottom`: the overflow line;
`every native stack check passed`. (That binary's reported bottom page was
inaccessible and stepped over, as milestone 4 recorded; the census's
probes saw a reported bottom that was usable. Both are handled by the
same walk, which never trusts the reported end.)

**The capacity, measured in Botlish recursion [experimental, macOS]**
(`programs/depth.bot`, the shapes of tests/native-stack-overflow.test):

| Shape, depth | worker (1 GiB) | main, default (8 MiB) | main, 512 MiB |
|---|---|---|---|
| `down` 10^4, 10^5 | value | value | value |
| `down` 10^6 | 1000000 | **NATIVE LIMIT STACK** | 1000000 |
| `keep` 10^4, 10^5 | value | value | value |
| `wide` 10^4 | value | value | value |
| `wide` 10^5 | 0 | **NATIVE LIMIT STACK** | 0 |
| `rec` 10^4 | value | value | value |
| `rec` 10^5 | 100000 | **NATIVE LIMIT STACK** | 100000 |
| `big` 100 (9,680-byte frames) | value | value | value |

On the default main stack the runtime fails correctly -- the defined
error, status 1, never a crash -- but programs that run today would stop
running. With LC_MAIN at 512 MiB every one returns its value; the
remaining difference from the worker is a factor of two in the deepest
recursion, and the loss of the run-time override. (Run 1 expected the
worker's values on the 8 MiB main stack and recorded the three
exhaustions as FAILED-CORRECTNESS, not as predicted; from run 2 the harness
predicts the line there, and the rows are as predicted.)

## 12. The overflow guard on the main thread

**[experimental, macOS]** Every exhaustion, on the worker, on the default
main stack and on the 512 MiB main stack (`programs/depth.bot` with depth
0, `programs/co_overflow.bot`, the generated `big.bot`):

| Program | worker | main (8 MiB) | main (512 MiB) |
|---|---|---|---|
| `down` unbounded | NATIVE LIMIT STACK, status 1 | the same | the same |
| `keep` unbounded (a String held across every call) | the same | the same | the same |
| `wide` unbounded | the same | the same | the same |
| `rec` unbounded (through a `Fn` value) | the same | the same | the same |
| `big` unbounded: 600 Ints and a String live across the call, a 9,680-byte frame whose pages Cranelift probes before allocating it (`botlish_fn_1` of the Linux x86-64 build: `sub $0x1000,%rsp; movl $0x0,(%rsp)` twice, `add $0x2000,%rsp`, then `sub $0x25d0,%rsp`; the AArch64 code was not disassembled) | the same (on an 8 MiB worker, `BOTLISH_NATIVE_STACK_BYTES`) | the same | the same |
| a coroutine's stack, after two yields and resumes | the same | the same | the same |
| `fault.bot`: a store to address 16 (no stack involved) | **SIGSEGV** (status -11), no NATIVE LIMIT STACK | the same | -- |

The line is the stack's exhaustion, wherever the stack is: the guard's
handler compares the faulting address with the published stack's guard --
the main thread's 56 MiB reservation, its one-page LC_MAIN guard, or a
coroutine's 64 KiB `PROT_NONE` -- on the guarded thread (`pthread_self()`
of the main thread). A fault elsewhere goes to the previous disposition
and the process dies by its signal: no relabelling. Nothing unwinds, nothing
continues on an exhausted stack, no boundary is guessed: the same handler
and the same confirmation as on the worker, with no code of its own.

Positive controls (`BOTLISH_EXPERIMENT_NO_GUARD=1` on the main thread):
the unbounded `down` dies by **SIGSEGV** and the coroutine overflow by
**SIGBUS**, with no line -- so the line in the table above is the guard's
work, not something the main thread gives for free.

## 13. GC roots on the main thread

**[experimental, macOS]** Under `BOTLISH_NATIVE_GC_STRESS=1` (a
collection attempted at every allocation site):

| Program | worker | main (8 MiB) | main (512 MiB) |
|---|---|---|---|
| `depth keep 3000`: a String live in every frame, an allocation per level | 6000 | 6000 | 6000 |
| `big 8`: 9.5 KiB frames holding a String | 7928616 | 7928616 | 7928616 |
| `kept.bot` (below) | the value | the value | the value |
| `sdl.bot`, Cocoa | -- (no window on the worker) | EXECUTED-COCOA | -- |
| `sdl.bot`, dummy driver | EXECUTED-HEADLESS (`bl-worker-headless-gc`) | EXECUTED-HEADLESS (`t-a-main-sdl-headless-gc`, ten repetitions, run 2) | -- |

The collector's frame walk is bounded by the Vm's `native_stack` -- the
stack of the thread that made the Vm, which candidate A makes on the main
thread -- and walks every suspended coroutine stack as before. Nothing in
`framewalk.rs` or `heap.rs` asks which thread it runs on.

## 14. Coroutine stack switching on the main thread

**[experimental, macOS]** `programs/kept.bot`:
`audit/macos-app/programs/coroutine-kept.bot`'s coroutines (a handle passed to another function; a
recursive yielding function with four suspended frames) and two
coroutines abandoned while suspended -- one 20 frames deep, Strings live
in every frame -- released at their handles' last use, then allocation:

| | worker | main (8 MiB) | main (512 MiB) |
|---|---|---|---|
| value | `[[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]]` | the same | the same |
| under GC stress | the same | the same | the same |
| `co_overflow.bot` | NATIVE LIMIT STACK | the same | the same |

**C calls from a coroutine's stack on the main thread**: `sdl.bot`'s
`frame_task` is a kept coroutine (its handle is an argument) whose body
presents a frame and pumps SDL's events at every resume. On the main thread
the fixture reports it running with `pthread_main_np` 1 and a stack
pointer outside the thread's own stack (`coroutine_on_own_stack`), and its
3 frames were presented through Cocoa and Metal -- **AppKit and SDL3 work
on a stack that is not the thread's own** **[experimental, macOS]**.

What a coroutine switch is, against a thread switch: a coroutine switch
changes the stack pointer on the same OS thread, so `pthread_main_np()`,
`[NSThread isMainThread]`, libpthread's thread descriptor and every
thread-local -- the runtime's, SDL's, AppKit's -- are the same before and
after; the runtime publishes the arriving stack to the guard. Dispatching
work between OS threads (candidate B) changes all of them. The main
thread's special constraint is not about switching: it is that its own
stack is small unless LC_MAIN says otherwise (coroutine stacks stay 8 MiB
each, `BOTLISH_NATIVE_COROUTINE_STACK_BYTES`, whichever thread runs them).

## 15. Candidate A, graphically

**[experimental, macOS]** `programs/sdl.bot`, the experimental build:

| Case | Model | Driver | Outcome | Facts |
|---|---|---|---|---|
| `a-main-cocoa` | main thread | cocoa | **EXECUTED-COCOA** | `SDL_IsMainThread()` true, `SDL_Init` true; a Cocoa window, renderer `metal`; 30 frames on the main thread's stack and 3 from the coroutine's; the pushed quit polled back (7 events); destroyed; `SDL_Quit`; every stage `pthread_main_np` 1; capture 320 x 268, center pixel **(255, 0, 255)** -- the program's magenta -- and 89.5% of the sampled pixels within 48 of it; up to 6 threads |
| `a-main-cocoa-gc` | main thread, GC stress | cocoa | **EXECUTED-COCOA** | the same value |
| `a-main-big-cocoa` | main thread, LC_MAIN 512 MiB | cocoa | **EXECUTED-COCOA** | the same value |
| `a-main-headless` | main thread | dummy | EXECUTED-HEADLESS | the same value with the software renderer |
| `a-worker-cocoa` | the experimental build's worker | none | FAILED-CORRECTNESS | "No available video device", as production |
| `a-main-rustc-cocoa` | main thread, rustc-linked (the startup crate's `main`) | cocoa | **EXECUTED-COCOA** (run 2) | the same lifecycle: renderer `metal`, 30 + 3 frames, the quit polled back (6 events), destroyed, every stage `pthread_main_np` 1, up to 5 threads |

The window is real: SDL's current driver is `cocoa`, the window has a Cocoa
window (`SDL_PROP_WINDOW_COCOA_WINDOW_POINTER`), `screencapture -l` of its
window number captured the pixels the program drew, and the classification
requires all of it on `pthread_main_np` 1 (an EXECUTED-COCOA row is never a
dummy-driver pass: section 22). No Icy Tower port was attempted.

Candidate A's simplicity is real: the probe is an ordinary synchronous SDL3
program -- create, draw, pump, poll, destroy -- whose C calls are direct
calls, as on the worker today; no proxy, no callback, no queue. The same
source that fails on the worker succeeds on the main thread.

## 16. Candidate B: the worker and a main-thread dispatcher

The second architecture keeps the worker's large stack and gives the main
thread to the graphical subsystem: the program asks, the main thread does.

**The experiment [experimental]**: with `BOTLISH_EXPERIMENT_THREAD=dispatch`
the experimental `aot::run` spawns the worker as ever, but instead of
`join()` its main thread loops on a queue until the worker ends
(`experiment::serve`): each request is a C function and its argument,
which the main thread calls, then wakes the waiting worker. The worker's
side is one exported C function, `botlish_experiment_main_call(f, data)`
(synchronous; -1 when no main thread serves -- the production model). It
is generic: the runtime knows nothing of SDL. Botlish cannot hand the main
thread Botlish code (no callbacks, and the main thread has no Vm), so the
client is C: `native/mtdispatch.c`'s `mtd_*` functions, each one request
that makes its SDL calls on the main thread (init; create the window; the
renderer; one frame -- color, clear, present, pump; push the quit; one
poll; destroy and quit). `programs/dispatch.bot` drives the same lifecycle
as `sdl.bot` through them, and times 1000 empty requests.

**[experimental, macOS]**

| Case | Outcome | Facts |
|---|---|---|
| `b-dispatch-cocoa` | **EXECUTED-COCOA** | value `[1, true, [true, true, 30, true, [7, 1], true]]`: served, init, window, renderer, 30 frames, quit pushed, quit polled back, destroyed; every request ran with `pthread_main_np` 1 and `SDL_IsMainThread()` true, every caller on the worker; driver `cocoa`; an empty request's round trip 6.6 us |
| `b-dispatch-headless` | EXECUTED-HEADLESS | the same; round trip 10.5 us |
| `b-dispatch-refused` | EXECUTED-THREAD (as predicted) | the production model: no main thread serves; every request refused at once, the program sees `[0, false, [false]]` -- it cannot even ask |
| `b-c-pump-runonmain` (C: SDL's own queue, the main thread pumping) | **EXECUTED-COCOA** | 32 `SDL_RunOnMainThread(..., true)` callbacks (window and renderer, 30 frames, destroy), all 32 on the main thread; 200 empty ones: 21.9 us each |

So a dispatcher can host a Cocoa application with Botlish on its worker,
and SDL3's own `SDL_RunOnMainThread` can too -- when the main thread runs
SDL's event processing. The costs are the next two sections.

## 17. Dispatcher deadlock analysis

Three facts of section 4 make the deadlock structural, not an accident of
a probe:

1. `aot::run`'s main thread is blocked in `join()` for the whole run
   (section 2, step 15): it processes no event and drains no queue.
2. SDL3 drains `SDL_RunOnMainThread`'s queue only inside its own event
   processing on the thread it considers main (`SDL_PumpEventsInternal`),
   and a `wait_complete` request waits on a semaphore without a timeout.
3. SDL's "main thread" is whichever thread initialized it.

So in today's production model `SDL_RunOnMainThread` cannot deadlock --
and that is the problem: the main thread never calls SDL, so SDL takes the
worker for its main thread and runs every "main-thread" callback on the
worker. The request is silently executed on the wrong thread instead of
waiting for the right one (`SDL_IsMainThread()` true on the worker,
section 9).

It deadlocks as soon as something makes the process's main thread SDL's
main thread while that thread is not processing SDL's events
**[macOS]**:

* **`b-c-join-runonmain`** (C, the shape of `aot::run`): the main thread
  calls `SDL_Init(SDL_INIT_VIDEO)`, starts a worker and joins it; the
  worker calls `SDL_RunOnMainThread(callback, NULL, true)`. Neither
  proceeds: the main thread waits for the worker, the worker for the main
  thread's event processing. The watchdog ended it after 5 s: status 124,
  a `deadlock` line.
* **`b-runonmain-deadlock`** (Botlish, the experimental dispatcher): the
  main thread *does* serve requests -- the runtime's queue -- and SDL was
  initialized through that queue, so SDL's main thread is the process's.
  The Botlish worker then calls `SDL_RunOnMainThread(..., true)` itself:
  the main thread is waiting in the runtime's queue, not in SDL's event
  processing, so SDL's queue is never drained. Status 124 after 5 s. **A
  dispatcher that serves its own queue does not serve a library's.**
* **`b-c-pump-runonmain`** (the control): with the main thread in a loop
  of `SDL_WaitEventTimeout(NULL, 10)` until the worker is done, every
  request completes on the main thread (section 16).

Two requirements follow for any dispatcher architecture: the main thread
must run *every* main-thread queue a library brings (SDL's, by pumping
SDL's events; another toolkit's, by its own means), and no request may wait
for a thread that is waiting for it. The first means the runtime's
main-thread loop must know how to pump each library -- SDL-specific code in
a generic runtime, or a registration mechanism for pumps (the event loop's
"pump hooks", EVENT-LOOP-EXPLORATION.md, section 13). The second is a
global property of the program, which no local check of one call
establishes. Candidate A has neither problem: with one thread, a
"main-thread" request is a direct call -- `SDL_RunOnMainThread` runs the
callback at once on the main thread, by its own definition.

## 18. Dispatcher ownership and cleanup

What candidate B does to ownership, from the experiment's code and runs
**[code; experimental]**:

* **Where resources live and where they are owned diverge.** Every SDL
  object is created, used and destroyed on the main thread, while the
  Botlish program on the worker holds its address (an affine
  `std::ffi::c::Ptr`). Nothing stops the worker from passing that pointer
  to an SDL function directly -- an ordinary `extern c fn` call, which
  compiles -- and breaking Cocoa's rule without a diagnostic: the language
  has no thread affinity for a resource, and the dispatcher adds none.
* **Every operation needs a proxy.** Each SDL function the program uses
  needs a C function that packs its arguments, runs it on the main thread
  and unpacks the result (`mtdispatch.c` is 200 lines for nine
  operations). Botlish cannot write the proxy itself: it cannot pass code
  to another thread, and the main thread has no Vm to run Botlish code on.
* **A worker's failure leaves resources behind.** With synchronous
  requests the worker cannot fail during one (it is waiting). If the
  program fails between requests -- a runtime error, `NATIVE LIMIT STACK`
  -- the worker ends, the main thread sees it finished, stops serving and
  joins: the window, the renderer and SDL itself are never destroyed or
  quit; only the process's exit reclaims them. An orderly shutdown would
  need the runtime to know what to destroy -- SDL-specific code again.
* **The main thread cannot exit first** in this design (it exits after
  `join`); in a host that owns the main thread (iOS) it could end the
  process while the worker waits.
* **Values crossing the boundary** are C words only (pointers, integers,
  the bools of the results). A Botlish value never crosses: the worker's
  heap is its Vm's, and nothing runs Botlish code on the main thread. A
  callback from the main thread into Botlish (an SDL event watch, a hit
  test) is impossible -- isolation, but also a hard limit: anything that
  needs a synchronous answer from the program cannot be dispatched.
* **Shared mutable state.** The request queue is a process-wide static of
  the runtime (`Mutex<Option<Sender>>`): runtime state shared between two
  threads, outside every Botlish ownership rule. Acceptable inside the
  runtime; but it is exactly the cross-thread messaging the actor model
  is to design (section 28).

A native-only dispatcher like the experiment's is buildable; as an
architecture for Botlish applications it needs a proxy per foreign
function, a pump per library, a cleanup policy per resource kind and a
thread-affinity rule the language does not have.

## 19. Candidate C: SDL3's callback-owned lifecycle

SDL3's main callbacks invert control: SDL's `main` owns the loop and calls
the application's `SDL_AppInit` once, `SDL_AppIterate` per iteration,
`SDL_AppEvent` per event and `SDL_AppQuit` at the end.

**What SDL3 does on macOS [code]**: `SDL_main.h` with
`SDL_MAIN_USE_CALLBACKS` defines `main`, which calls `SDL_RunApp` -- on
macOS the generic one: `SDL_SetMainReady` and a direct call -- and then
`SDL_EnterAppMainCallbacks`, also generic on macOS
(`src/main/generic/SDL_sysmain_callbacks.c`): `SDL_AppInit`, then a loop of
`SDL_PumpEvents`, event dispatch and `SDL_AppIterate` at
`SDL_HINT_MAIN_CALLBACK_RATE` (as fast as presentation allows by default),
then `SDL_AppQuit` and `SDL_Quit`, all on the calling thread. It owns no
AppKit run loop. On macOS the callback model is therefore exactly a
main-thread program loop written by SDL -- which candidate A lets a Botlish
program write itself. Only on iOS does SDL's callback host differ
(CADisplayLink on the main run loop), and there it is the only model
(section 29). `SDL_AppEvent` may also be called concurrently from other
threads, for events pushed off the main thread (`SDL_main.h`), which a
thread-affine Botlish instance would refuse (WRONG-THREAD, section 20).

**[macOS]** `native/csdl_callbacks.c`:

| Case | Outcome | Facts |
|---|---|---|
| `c-callbacks-cocoa` | **EXECUTED-COCOA** | `cocoa` driver, renderer `metal`; 60 iterations, 60 frames presented, 6 events; all 68 callback calls on the main thread; 348 ms from `SDL_AppInit` to `SDL_AppQuit` |
| `c-callbacks-headless` | EXECUTED-HEADLESS | dummy driver, 80 calls on the main thread, 16 ms |

The lifecycle works on macOS from C. For Botlish the questions are what
can be called from it (next section) and what survives between calls.

**What would a Botlish application need from a host-owned lifecycle?**
(**[code]**, from NATIVE-LIBRARY-MILESTONE-1.md and
EVENT-LOOP-EXPLORATION.md):

* *Compiled entry points on the host's main thread*: a native library's
  exports are exactly that -- they run on the calling thread and stack
  (section 20).
* *The runtime initialized once and used across callbacks*: an instance
  (`NAME_create` once, calls, `NAME_destroy`) does that; its heap persists
  between calls.
* *VM state across callbacks*: only what the program returns to C. A
  library's entry file holds declarations only, has no mutable module
  state and installs no context (CONTEXTS.md: only an entry program
  installs one) -- so the application's state cannot live in Botlish
  between `SDL_AppIterate` calls, and suspended coroutines cannot survive a
  call either (no suspension across the boundary, EVENT-LOOP-EXPLORATION.md
  section 1). The event-loop exploration's host-driven experiments worked
  around exactly this with a C fiber inside one executable.
* *Errors without unwinding across FFI*: a library call returns a status
  and an owned error object; nothing unwinds (`library.rs`'s `guarded`).
* *Ownership guarantees*: a context cannot be installed, so the program's
  resources would be owned by C between callbacks.

So candidate C for an *application* needs an application-entry contract
the language does not have -- state and coroutines that persist across a
host's calls -- while candidate A needs none. For a *library* called by a
host (React Native, a game engine's plug-in), the callback shape is the
native-library model, which exists (on Linux).

## 20. Native-library export feasibility

**[macOS]** `-emit-native-library` is refused on macOS:
`native libraries are made on Linux glibc (x86_64, aarch64) only; this
host is macos-aarch64 (NATIVE-LIBRARY-MILESTONE-1.md) (NATIVE UNSUPPORTED
library)`, status 1 (`c-library-macos`). No exported Botlish function
could be called from SDL's callbacks on macOS.

**[Linux, headless]** On Linux x86-64, `tools/library-callbacks.sh` builds
the library `mtplib` -- one export, `step(n)`, which builds a String by a
16-level recursion (allocation, and frames on the host's stack) -- and
`csdl_callbacks.c` with `-DMTP_BOTLISH_LIBRARY`: `SDL_AppInit` makes one
instance (`mtplib_create`, on the main thread) and calls it; every
`SDL_AppIterate` calls it; `SDL_AppQuit` destroys it. With the dummy
driver: 61 calls, 0 failures, the last value 81 (60 + 21), every call on
the process's main thread; the same under `BOTLISH_NATIVE_GC_STRESS=1`
(`results/linux-x86_64/library-callbacks.txt`). So the current export
boundary already supports a host-owned lifecycle on the host's main thread:
the instance is the thread's, its calls run on the host's stack with the
stack-limit check (no guard: a library never installs one), and the
collector's walk stops at the call's frame.

What it would take on macOS **[code]**: the library build is GNU-specific
-- an ELF relocatable object, `objcopy --keep-global-symbols` to localize
the private runtime, `codegen::library::SUPPORTED` Linux glibc only -- so a
macOS library needs Mach-O equivalents (an `ld -r` with
`-exported_symbols_list` or a two-level-namespace dylib) and its own
milestone. Nothing in candidate A or B depends on it.

## 21. Process error and exit semantics

**[experimental, macOS]** (run 2, 40827366250; the signals during a C call
run 3, 40828677344) `programs/errors.bot`, `depth.bot`, `sleep.bot` and `sdl.bot`, on
the worker, on the main thread (system-linked and rustc-linked) and on the
main thread's 512 MiB stack:

| Outcome | worker | main | main, rustc-linked | main, 512 MiB |
|---|---|---|---|---|
| success: a declared error failed and handled (`errors declared`) | `1008` on standard output, status 0 | the same | the same | the same |
| a runtime error (`+` of an erased `list`, checked when it runs) | standard output empty; standard error `+: expected int, got [true] (CORE SEMANTIC TYPE)`; status 1 | the same | the same | the same |
| the same in the driver protocol (`BOTLISH_NATIVE_RESULT`) | the result file holds `error {CORE SEMANTIC TYPE} {+: expected int, got [true]}`; status 0; standard output empty | the same | the same | the same |
| the driver protocol with `BOTLISH_NATIVE_RUNS=3` | `times A B C`, `timing 0 BEST 3 COLLECTIONS`, `value {int 1008}` | the same | the same | the same |
| the startup report unwritable (`BOTLISH_NATIVE_STARTUP_REPORT`) | `... (NATIVE IO)`, status 2 | the same | the same | the same |
| a native stack overflow | `error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}` on standard error, status 1 | the same | the same | the same |
| a fault that is no overflow (`fault.bot`, run 1) | death by SIGSEGV (status -11) | the same | -- | -- |
| a failing C call (`SDL_Init` false, section 9) | the program's own value, status 0 | -- (Cocoa succeeds) | -- | -- |
| SIGTERM while SDL runs (`sdl.bot`, signalled after 1 s) | -- | the process ends normally, status 0: SDL's handler (installed by `SDL_INIT_EVENTS`, `src/events/SDL_quit.c`) made it a quit event, which the program polled | -- | -- |
| SIGTERM / SIGINT in a 5 s C call, no SDL (`sleep.bot`, signalled after 1 s) | killed by the signal (status -15 / -2, a shell's 143 / 130) after about 1 s; no line, no result | the same | -- | -- |

Every line, file and status is the same on every thread: the reporting is
`aot::run`'s body, which candidate A runs unchanged. Clean SDL shutdown is
section 15's (`SDL_DestroyRenderer`, `SDL_DestroyWindow`, `SDL_Quit`, then
the program's value and status 0); an abnormal SDL initialization is the
program's own value (section 9); a declared Botlish error cannot reach the
process at all -- the checker requires every one handled (UNHANDLED-ERROR),
which `errors.bot` first ran into. Signals: the runtime installs handlers
for SIGSEGV and SIGBUS only (the guard) and ignores SIGPIPE
(`rust_process_setup`), so SIGTERM and SIGINT keep their dispositions on
either thread: a process blocked in C dies by the signal on the worker and
on the main thread alike (run 3) -- until SDL's own handler replaces them
and makes the signal a quit event the program polls.

One difference the experiment introduces **[Linux; code]**: a Rust panic.
On the worker a panic is caught by `join` and reported "native executable
panicked (NATIVE BUG)", status 1 (`aot.rs:263-276`). On the main thread it
escapes `run`: through `linked_main`'s `catch_unwind` (status 101, Rust's
panic message) or out of the rustc startup's `main` (Rust's own status
101). Observed on Linux, where the guard refuses the main thread with a
panic (`the stack-overflow guard: ... no confirmed guard`, status 101,
section 26). No panic was triggered on macOS. The implementation must catch
the body's panic to keep NATIVE BUG (section 30). Nothing calls
`std::process::exit` from a callback or a signal path in any model, and no
graphical shutdown is forced: the program returns and `main` exits.

## 22. Headless versus Cocoa evidence

The classes are assigned by `tools/census.py` from the fixture's lines and
the program's own value, never from a status code alone:

* **EXECUTED-COCOA** requires SDL's current video driver to be `cocoa`, the
  window to have a Cocoa window, every reported stage to run with
  `pthread_main_np()` 1, frames presented, the pushed quit polled back, and
  the window, renderer and SDL shut down -- and the program's value to
  agree with the fixture (a value claiming a window the fixture did not see
  is FAILED-CORRECTNESS).
* **EXECUTED-HEADLESS** is the same lifecycle with the `dummy` (or
  `offscreen`) driver. It proves SDL's headless path, the binding and the
  runtime's handling of the calls -- nothing about Cocoa or AppKit.
* A Cocoa failure is **UNAVAILABLE-GUI** only when the C control on the
  main thread could not make a Cocoa window either; on this runner it
  could, so every Cocoa failure here is FAILED-CORRECTNESS with its cause.

Every graphical claim of this report is EXECUTED-COCOA on the runner: 11
rows in run 1 (C main, C callbacks, C RunOnMainThread pump, Botlish
candidate A plain, under GC stress and with a 512 MiB stack, candidate B,
and the timing repetitions), 14 in run 2 (those, candidate A
rustc-linked, SIGTERM during the SDL program, and candidate A's 512 MiB
timing repetitions). The headless rows are listed as such and
used only for what they prove: that the probes and the runtime behave the
same on the worker and the main thread when Cocoa is not involved
(sections 9, 15, 24). No dummy-driver run was counted as Cocoa
(`pc-dummy-not-cocoa`, and the classifier's own self-test, section 25).

## 23. Candidate comparison

Observed facts, with the unknowns named:

| Dimension | A: direct main thread | B: worker + dispatcher | C: host callbacks |
|---|---|---|---|
| Cocoa/SDL affinity | **met**: EXECUTED-COCOA, the program's own SDL calls on the main thread **[macOS]** | **met**: EXECUTED-COCOA, every SDL call proxied to the main thread **[macOS]** | **met** in C (EXECUTED-COCOA); Botlish callable only as a library -- not on macOS **[macOS]** |
| Native stack safety | **kept**: the existing guard on the main thread's confirmed guard, every overflow the line, faults not relabelled **[macOS]** | the worker's, unchanged; the dispatcher runs C on the main thread's 8 MiB, unguarded by Botlish (C code; as today's C on the worker is guarded) | the host's stack, a library's stack-limit check, no guard; a C or runtime overflow is fatal (NATIVE-LIBRARY-MILESTONE-1.md) |
| Stack capacity | 8 MiB by default (three finite probes fail); **512 MiB with LC_MAIN** (all pass); link-time, not run-time | 1 GiB, run-time configurable, as today | the host's thread's (8 MiB on a main thread) less the library's reserve |
| GC and stack maps | **unchanged**, GC stress identical **[macOS]** | unchanged on the worker; nothing crosses | unchanged inside a call; the walk stops at the call |
| Coroutines | **unchanged**: kept coroutines, overflow, abandoned suspension; SDL/Cocoa from a coroutine stack works **[macOS]** | unchanged on the worker | none across calls (no suspension across the boundary) |
| Ordinary synchronous C calls | **direct** | a C proxy per function; synchronous round trip 6.6-10 us | direct inside a call |
| Ownership clarity | one thread: every resource made, used and destroyed where the program is | split: owned on the worker, live on the main thread; no rule says which calls need which thread | owned by C between calls (no context in a library) |
| Event pumping | the program's own loop, on the main thread | the program asks the main thread to pump; SDL's own queue needs the main thread in SDL's event processing (deadlock otherwise, **[macOS]**) | the host's loop |
| Error propagation | the existing lines and statuses (section 21) | two threads: a worker failure leaves resources undestroyed | statuses and owned error objects; no unwinding |
| Shutdown | the program's explicit calls; `exit` as today | needs a policy per resource kind; else the process's exit | the host's `SDL_AppQuit`; `NAME_destroy` |
| Implementation complexity | the patch's body change (one closure, one branch) plus a selection mechanism and the link flag (section 31) | a runtime queue, a C proxy per foreign function, a pump per library, a cleanup policy | macOS native libraries (a Mach-O build), plus an application-entry contract for state across calls |
| macOS desktop suitability | **suitable**, with LC_MAIN | works, at a per-call and per-library cost | no benefit over A on macOS (SDL's loop is a plain loop) |
| iOS portability | the thread and stack shape carries over; owning `main` does not (section 29) | the host owns the main thread: a dispatcher would need the host's run loop | the iOS model (projected) |
| Native-library suitability | not applicable: libraries never own `main` (unchanged) | possible host coordination, unneeded | natural: it is the library model |

## 24. Timings and executable sizes

**[macOS; experimental]** Ten repetitions per row (run 2, 40827366250);
median [min, max]. The runner is a 3-CPU virtual machine shared by
nothing else in the job, but GitHub's scheduling is not controlled:
dispersion is wide, and differences inside the ranges are not findings.

| Case | wall ms | first instruction, ms after exec | SDL init ms | frame ms | `SDL_PumpEvents` us | shutdown ms | threads |
|---|---|---|---|---|---|---|---|
| identity, production worker | 7.9 [6.7, 19.4] | 7.1 [6.1, 17.3] | | | | | 2 |
| identity, candidate A (main) | 7.6 [6.3, 13.7] | 7.0 [5.7, 12.5] | | | | | 1 |
| identity, candidate B (dispatcher) | 24.9 [16.3, 33.9] | 9.5 [7.6, 15.3] | | | | | 2 |
| C, main thread, Cocoa | 2692 [1937, 3080] | 16.7 [9.0, 32.0] | 73.4 [54.5, 140.8] | 83.8 [57.5, 95.9] | | 29.0 [26.4, 48.2] | 6 [5, 6] |
| Botlish, candidate A, Cocoa | 2943 [2283, 3375] | 10.9 [8.0, 36.0] | 58.9 [44.4, 79.7] | 86.5 [64.6, 96.1] | 5.2 [4.2, 12.5] | 26.1 [24.7, 29.2] | 6 [5, 6] |
| Botlish, candidate A, Cocoa, LC_MAIN 512 MiB | 2919 [2358, 3499] | 17.5 [9.0, 37.5] | 69.7 [55.2, 208.5] | 82.9 [67.5, 104.2] | 6.1 [4.1, 48.4] | 27.8 [25.1, 41.5] | 6 [5, 6] |
| Botlish, candidate A, dummy | 2381 [1934, 3090] | 9.3 [7.7, 20.7] | 0.11 | 73.8 [60.8, 92.5] | 0.09 | 0.08 | 3 |
| Botlish, worker, dummy | 2264 [1598, 3430] | 8.7 [6.9, 14.7] | 0.10 | 65.0 [48.3, 100.6] | 0.10 | 0.11 | 4 |
| Botlish, candidate A, dummy, GC stress | 2439 [1770, 2814] | 10.1 [8.4, 15.8] | 0.11 | 72.1 [56.5, 85.7] | 0.09 | 0.12 | 3 |
| Botlish, worker, dummy, GC stress | 2615 [2075, 3274] | 12.2 [10.1, 19.8] | 0.12 | 76.4 [60.8, 98.7] | 0.10 | 0.13 | 4 |
| Botlish, candidate B, Cocoa (30 frames without delay, 1000 empty requests) | 350 [246, 563] | 14.0 [11.5, 51.7] | | | | | 7 [6, 8] |
| C, SDL3 main callbacks, Cocoa (60 iterations) | 332 [219, 439] | 13.0 [10.4, 41.0] | | | | | 6 [5, 7] |
| `kept.bot` under GC stress, candidate A | 4.9 [3.5, 34.1] | | | | | | |
| `kept.bot` under GC stress, worker | 4.2 [3.6, 6.6] | | | | | | |

Reading it:

* **Startup**: the main thread spares the worker's creation; the first
  instruction comes 0.1-2.5 ms sooner (run 1: 5.6 against 8.1 ms) --
  inside the dispersion. Candidate B's extra wall time is its exit: the
  experiment's main thread notices the worker's end only between 2 ms
  waits for a request, and that loop, not the dispatching, costs the
  median 17 ms (an artifact of the experiment's polling loop, not measured
  further).
* **SDL3 on the main thread costs what it costs C**: Cocoa video init 59
  ms against C's 73 ms (run 1: 61 against 53), presentation and shutdown
  alike, the same 5-6 threads (Cocoa's and Metal's). The frame time is
  dominated by the probes' `SDL_Delay(16)`, which slept far longer on the
  runner, for C and Botlish alike.
* **Event pumping**: one `SDL_PumpEvents` costs 5.2 us with Cocoa on the
  main thread (0.09 us with the dummy driver) -- the pump's own cost,
  measured from Botlish over 100 calls.
* **Dispatch latency**: an empty request through candidate B's queue costs
  6.6-10 us (run 1: 6.6 and 9.9 us; run 2: 6.9 and 5.7 us); one through
  SDL's own `SDL_RunOnMainThread` with the main thread pumping, 22-38 us
  (runs 1 and 2). Every SDL call of a candidate-B program pays one.
* **GC stress** costs the same on either thread.
* **Coroutines**: `kept.bot` (resumes, yields, abandoned suspension) runs
  in the same time on either thread.

**Executable sizes [macOS]**: the same executable runs every model of the
experiment, so the models cost no code; LC_MAIN's stack size costs no
bytes (`exp/sdl` and `exp-big/sdl` 3,813,848 bytes; the patch's own code
is in all experimental executables). Representative sizes (run 2):

| Program | production (Botlish.app, system linker) | experimental (system linker) | experimental, rustc linker |
|---|---|---|---|
| `identity.bot` | 831,240 | 965,032 | 1,008,504 |
| `sdl.bot` (SDL3 static) | 3,658,488 | 3,813,848 | 3,841,272 |
| `big.bot` | 3,211,144 | 3,347,928 | -- |

The production and experimental columns come from different runtime
archives (Botlish.app's and the experimental worktree's builds), so their
difference is not the patch's alone; it was not isolated further.

## 25. Positive controls

Each control's job is to show that the probe that distinguishes two
architectures can fail. Run, and what each exposed **[macOS]** unless
noted:

| Control | How | What it showed |
|---|---|---|
| The worker misreported as main | `SDL_IsMainThread()` is SDL's opinion; the classification reads `pthread_main_np()` | SDL said true on the worker in every worker case; the independent checks said 0, and the classifier's self-test rejects a Cocoa record whose stages ran with `pthread_main_np` 0 |
| SDL called on the worker while "claiming" main | `bl-worker-cocoa`, `c-worker-cocoa` | FAILED-CORRECTNESS: "No available video device" |
| AppKit off the main thread | `c-appkit-worker` | `NSInternalInconsistencyException` |
| Event pumping removed | `pc-nopump`: the quit is pushed, never polled | FAILED-CORRECTNESS: `quit_seen` false -- never reported processed |
| SDL initialization failing | `pc-baddriver`: `SDL_VIDEODRIVER=nonexistent` | FAILED-CORRECTNESS: "nonexistent not available"; no window reported |
| Window destruction skipped | `pc-nodestroy`: no destroy, no `SDL_Quit` | FAILED-CORRECTNESS: `destroyed` missing |
| The guard not installed on the main thread | `pc-main-noguard-overflow`, `pc-main-noguard-co-overflow` (`BOTLISH_EXPERIMENT_NO_GUARD=1`) | death by SIGSEGV and by SIGBUS, no line: the overflow tests detect a missing guard |
| The main thread blocked while the worker waits | `b-c-join-runonmain`, `b-runonmain-deadlock` | both deadlock; the watchdog's status 124 |
| The dummy driver claimed as Cocoa | `pc-dummy-not-cocoa`, and the self-test's synthetic record | EXECUTED-HEADLESS, never EXECUTED-COCOA |
| A failing return value suppressed | the self-test: a value claiming a window the fixture never saw | FAILED-CORRECTNESS ("the program's value and the fixture disagree") |
| A coroutine stack or root dropped under GC stress | -- | **[not run]** on the main thread: it needs a runtime mutant; audit/coroutines' and audit/native-stack's mutation harnesses cover dropped roots and unpublished stacks on the worker, and nothing in candidate A changes that code |

The classifier's self-test (`oracle_selftest`, five synthetic records) runs
in every census and its rows are in the outcomes: a complete Cocoa record is
EXECUTED-COCOA; the same with the dummy driver EXECUTED-HEADLESS; with the
stages off the main thread, with a value contradicting the fixture, with
the quit never polled, FAILED-CORRECTNESS.

## 26. Platform-specific and cross-platform limitations

What each candidate would do to the hosts that share `aot::run` (inspected
from code; Linux x86-64 also executed, section 10):

| Host | Candidate A (main thread) | Candidate B (dispatcher) | Candidate C (host callbacks) |
|---|---|---|---|
| Linux x86-64 / AArch64 | **Refused today** (executed on Linux x86-64): glibc reports a guard size of 0 for the main thread, so `NativeStack::current()` confirms no guard and `OverflowGuard::install_executable` refuses the stack -- `the thread's stack has no confirmed guard`, status 101 before the program runs (`id-botlish-exp-main` on Linux). The kernel's own gap below the main stack exists (the C probe's overflow faults 520 bytes below the reported bottom, outside any reported guard), but nothing reports it; using it would be a new discovery rule for Linux's main thread, with its own evidence. The main stack is RLIMIT_STACK's (8 MiB by default) and grows on demand; an ELF cannot ask for more. No Linux graphical toolkit SDL uses (X11, Wayland, KMS/DRM) needs the main thread. | Unaffected unless selected; the queue is portable Rust. | Native libraries exist (glibc), and run on the host's thread and stack (executed headless, section 20). |
| Windows x86-64 (MSVC) | Possible in principle: `GetCurrentThreadStackLimits` and the guard's STATUS_STACK_OVERFLOW confirmation (`platform/windows.rs`) are per thread, and the main thread has a guard page. But its stack is the PE header's reserve, **1 MiB** by link.exe's default -- a thousandth of the worker's 1 GiB -- unless the link says `/STACK:`. Win32 has no process-wide "main thread" rule: a window belongs to the thread that creates it and its messages to that thread's queue, so Windows does not need candidate A at all. | Unaffected unless selected. | No native libraries on Windows. |
| macOS AArch64 | The candidate (sections 10-15); the stack is LC_MAIN's (`-stack_size`, section 11). | Sections 16-18. | No native libraries on macOS (section 20). |
| the JIT, every host | Unchanged: the driver's worker; a JIT program calls no C. | Unchanged. | Unchanged. |

So a main-thread startup must be a property a target can support or
refuse, not a change of `aot::run`'s one path: on Linux it would need a new
stack discovery first, on Windows a link-time stack reserve, and neither
host needs it for its windowing system. Nothing in candidate B or C is
platform-specific in the runtime, but B is useful only where a toolkit
needs the main thread (macOS, iOS), and C needs native libraries where they
do not exist yet.

Limits of the evidence itself:

* Every macOS fact is the `macos-15` arm64 runner's: Apple Silicon under
  Apple's virtualization, one macOS version, one SDK, one display
  configuration (section 6). A bare-metal Mac, another macOS release and a
  logged-in user's desktop with real displays were not run; the shared
  development Mac was not used.
* The Cocoa results are from an SDL3 renderer on the runner's
  virtual display; GPU-specific behaviour (a discrete GPU, ProMotion,
  multiple displays) is outside it.

## 27. Consequences for context-owned resources

Thread affinity and authority are different properties and the census
keeps them apart:

* **Running on the main thread grants nothing.** Candidate A changes which
  thread executes the program, not what the program may do: every SDL call
  is still an `extern c fn` call that the direct-module rules
  (DIRECT-MODULES.md) judge as before -- the probes are `direct module`
  for the same reason Icy Tower's `sdl.bot` mediates its calls through the
  `Sdl` context. No context, capability or declaration is involved in
  choosing the thread, and none should be: a library's declaration must
  never move the program to another thread (section 30's selection rule).
* **A context does not make a resource safe to use from any thread.**
  Today a program has one thread, so every context-owned SDL object
  (Icy Tower's `Sdl` session: window, renderer, scratch memory, as affine
  pointers in the context's vector, CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md)
  is used on the thread that made it. Under candidate A that thread is the
  main thread, so the existing ownership model is already correct for
  Cocoa's rules with no new rule. Under candidate B the objects would be
  *made* on the main thread and *owned* by a context on the worker:
  ownership and affinity would point at different threads, and nothing in
  the type system says which operations need which thread.
* **Destruction on a required thread.** Today nothing releases what an
  installed context owns at the program's end (no lifecycle, by design),
  and a released affine pointer runs no code. A window SDL created must be
  destroyed on the main thread by the program's own explicit `close`;
  under candidate A that call naturally runs there. A future drop action
  for resources (EVENT-LOOP-EXPLORATION.md, section 8: "a drop action that
  runs no Botlish code") would need, for a thread-affine resource, to run
  on its owning thread -- which is trivial while there is one thread and a
  scheduling problem as soon as there are two.
* **Actor isolation** (next section) would make "the thread that owns the
  resource" a first-class fact. The census's evidence suggests the
  integration point: a thread-affine native resource is owned by the actor
  that runs on the thread the toolkit requires, and is reached by messages
  -- never by a pointer shared between threads.

Nothing here needs a new capability or thread-affinity type system now:
with one Botlish thread, which is the main thread, every SDL object is
created, used and destroyed on the thread Cocoa requires.

## 28. Consequences for the actor and event-loop model

* **Candidate A does not depend on it, and does not obstruct it.** A
  program on the main thread runs exactly the coroutines, contexts and
  scheduling it runs on the worker (sections 13-14):
  EVENT-LOOP-EXPLORATION.md's scheduler -- an ordinary module over coroutines -- runs
  unchanged on whichever thread the startup chose, and its SDL driver
  (`evsdl.c`'s "hybrid" mode, polling and pumping SDL on the loop's own
  thread) is correct on macOS only if that thread is the main thread. The
  exploration's macOS row ("SDL's Cocoa backend pumps the main run loop")
  was a projection; this census adds the missing premise: the loop's
  thread must be the process's main thread, and candidate A is how an
  executable gets there.
* **The event loop as a standard-library facility**
  (EVENT-LOOP-MILESTONE-1.md, which reached main after this census's base
  and changes none of the startup code it inspected): Linux has its only
  native driver, and the driver assumes the thread that installed it runs
  the loop, which it says GUI hosts that require the main thread (macOS
  AppKit, iOS) fit. For a macOS executable that holds only when the
  installing thread is the main thread: today's worker is not (sections 7,
  9), candidate A's is. A macOS driver therefore depends on this census's
  recommendation, not the other way round.
* **Candidate B is a message-passing protocol in miniature**, built below
  the language: requests from the worker, served by the main thread, with
  their own deadlock (section 17) and their own ownership split (section
  18). Building it now would pre-empt the actor model's design of exactly
  that: which actor owns the main thread, how messages to it are typed and
  how a request's lifetime relates to its sender's. The census's evidence
  is that it is not needed for a synchronous SDL application.
* **The main thread as an actor.** When actors exist, "the actor bound to
  the process's main thread" is the natural owner of a Cocoa UI; candidate
  A is its degenerate case (one actor, bound to the main thread). Nothing
  in candidate A's startup policy would have to be undone: the policy says
  where the *first* Botlish thread runs.
* **SDL_RunOnMainThread is not a substitute for a scheduler.** It drains
  only during SDL's event processing on the main thread (section 4); a
  Botlish runtime that serves its own queue does not drain it (section 17).
  Any future cross-thread design has to treat a library's private
  main-thread queue as one more event source of the main thread's loop,
  never assume one queue serves another.

## 29. Consequences for iOS and React Native

* **iOS** (projected; no iOS target exists): the application's main
  thread belongs to `UIApplicationMain`, which never returns; an app runs
  code from the main run loop's callbacks. SDL on iOS starts the
  application's own `main` (`SDL_main`) from inside the application
  delegate's launch callback, on the main thread, and pumps the run loop
  when the application polls (`src/video/uikit/`), or uses CADisplayLink
  callbacks in the callback model (`src/main/ios/SDL_sysmain_callbacks.m`).
  So the iOS shape is "Botlish's entry runs on the main thread, called by
  the host, on the host's stack" -- the shape of candidate A's thread and
  of a native library's stack. What carries over from candidate A: the
  runtime must run on the main thread with a confirmed guard on a stack it
  did not create (the main thread's), and the program's value and errors
  must reach a host that, not the runtime, ends the process (section 21).
  What does not: an executable that owns `main` and calls
  `std::process::exit`. iOS's main-thread stack size and guard were not
  measured.
* **React Native** (NATIVE-LIBRARY-MILESTONE-1.md's host probe): a
  TurboModule is called on the JavaScript thread or a module queue the host
  chooses; UI work goes to the UI thread by the host's own dispatch. The
  native-library model is already right for it -- a thread-affine instance
  on the thread the host calls from, no worker, no main-thread assumption
  -- and none of the candidates should change it. A Botlish module that
  needs the UI thread would be called on it by the host, not move itself
  there.
* **What to avoid now**: making "the program owns main()" an assumption of
  the runtime's startup (iOS forbids it), making "the main thread" an
  implicit property of a library's code (React Native calls from elsewhere),
  and making an SDL-specific rule (SDL is one of many hosts). Candidate A's
  selection as an explicit property of an executable's startup, recorded
  where the startup reads it, avoids all three.

## 30. The recommended next milestone

**MAIN-THREAD-STARTUP-MILESTONE-1: a standalone executable's startup
policy, `main-thread`, on macOS AArch64.** The smallest architecture that
satisfies the established contracts is candidate A, made explicit:

1. **The policy is a property of the executable, chosen when it is
   emitted.** An option of executable emission (`main.tcl
   -native-startup main-thread`, `native::executable ... -startup main`, the
   driver's `emit-executable --startup main`), recorded in the program
   object's `botlish_program` record -- the one startup datum every linker's
   startup already reads (`runtime::program`) -- and read by `aot::run`
   before it decides where to run. Not an environment variable (a program's
   thread must not change with its caller's environment), not a property of
   a library, a context, a declaration or a foreign function (never "SDL3 is
   linked, so ..."), not inferred from anything. A language-level entry
   annotation is not needed: the evidence shows nothing in the program's
   meaning changes with the thread -- its values, errors, coroutines and
   collections are the same (sections 13-14, 21) -- so the choice is the
   executable's, like its linker.
2. **`worker` stays the default and the only policy elsewhere.** `main` is
   accepted for macos-aarch64 only, refused for the others with the
   reason: Linux's main thread has no confirmed guard (glibc reports none:
   executed, section 26) and would need its own discovery first; Windows'
   is 1 MiB unless the link reserves more, and no Windows toolkit needs the
   main thread. Both are later decisions with their own evidence.
3. **`aot::run` runs `init` and the entry on the calling thread** under the
   policy -- the experiment's closure, the same body -- keeps every report,
   status and line, and catches a panic of the body so that it stays
   "native executable panicked (NATIVE BUG)", status 1, as the worker's
   `join` makes it today (the experiment let it escape: status 101, section
   21).
4. **The stack size is a link-time property.** The link passes LC_MAIN's
   `-stack_size`: 512 MiB, ld's maximum on arm64, through both the system
   linker (`system_link_args`) and the rustc linker (`-C
   link-arg=-Wl,-stack_size,...`); `BOTLISH_NATIVE_STACK_BYTES` does not
   apply to it and the policy's documentation says so. Whether a program
   that needs more than 512 MiB of recursion should be refused or warned
   about is the milestone's question; every probe the census ran returned
   its value at 512 MiB (section 11).
5. **Nothing else changes.** The JIT keeps its worker (a JIT program never
   calls C), native libraries keep the host's thread, the guard, the
   collector, coroutines and the C FFI are untouched, no SDL, AppKit or
   event-loop code enters the runtime.
6. **Acceptance** is this census's harness on the policy instead of the
   patch: the SDL3 probe EXECUTED-COCOA on macos-15, every runtime probe of
   sections 11-14 and 21 on the policy, the regression tests of section 32
   on both policies, and a native_stack check of the LC_MAIN guard.

After it, in order of dependency: an Icy Tower macOS build on the policy
(the generated SDL3 binding for macos-aarch64 first); then, separately, the
event loop's macOS driver (whose thread is now the main thread), macOS
native libraries (the host-callback shape for iOS and React Native), and
the actor model's main-thread actor.

What the census rules out, and why:

* **Candidate B as the architecture**: correct Cocoa behaviour bought with
  a proxy per foreign function, a pump per library, a cleanup policy per
  resource kind, a deadlock class (two demonstrated) and a split between
  where a resource is owned and where it lives -- to keep a stack size the
  main thread can have anyway (512 MiB). It is a message-passing system in
  miniature that the actor model should design, not the runtime improvise.
* **Candidate C for desktop applications**: no Cocoa benefit on macOS, and
  it needs macOS native libraries plus an application-entry contract
  (state and coroutines across callbacks) that the language does not have.
  It remains the right shape for hosts that own the main thread (iOS,
  React Native), through native libraries.
* **Running the program on the main thread with the default 8 MiB
  stack**: safe but a regression -- programs that run on the worker today
  would end in `NATIVE LIMIT STACK`.
* **Switching the main thread onto a runtime-allocated stack** (as a
  coroutine does): AppKit and SDL3 did work from a coroutine stack on the
  main thread (section 14), but the census did not verify the main
  program's whole lifetime -- AppKit's run loop, autorelease pools, crash
  reporting, Apple's unwinder -- on a stack libpthread does not know, and
  LC_MAIN gives the size without it.

## 31. The production files that milestone would change

Inspected; nothing below was changed by this census.

| File | Change |
|---|---|
| `native/src/runtime/program.rs` | `LinkedProgram` (the `botlish_program` record) gains the startup policy word; `read_linked` reads it; the ABI fingerprint (`aotimage::abi_fingerprint`) covers the record's new layout |
| `native/src/runtime/aot.rs` | `run` takes the policy: `worker` (today's path, unchanged) or `main` -- `init` and the program on the calling thread, the same body (`experiment`'s `body` closure is the shape); the panic and exit paths of the main mode (section 21) |
| `native/src/runtime/aotimage.rs` | the stub's image carries the same word (or the stub refuses `main`: it is Linux x86-64 only, where `main` is refused anyway) |
| `native/src/codegen/aot.rs` | `emit_object` writes the word; the rustc link (`-C link-arg=-Wl,-stack_size,SIZE`) and the system link (`system_link_args`, Apple flavor) pass LC_MAIN's stack size when the policy is `main`; refusal of `main` for a target that does not support it (Linux, Windows) |
| `native/src/main.rs` | the driver's emission option that selects the policy (`emit-executable --startup main`) and its validation |
| `native/native.tcl` | `native::executable ... -startup main`, the capability row (`capabilities`: `mainThreadStartup {macos-aarch64}`) |
| `main.tcl` | the command-line option (`-native-startup main-thread`), `cliOptions`, the header comment (tests/main-cli.test checks all three) |
| `compilerpedia/topics/` | `cli.options`, the option's topic, `backend.platforms` |
| `native/src/runtime/platform/macos.rs` | none expected: discovery already confirms the main thread's guard (MACOS-AARCH64-MILESTONE-4.md, section 5; section 11 here) -- the milestone re-proves it for the LC_MAIN sizes it supports |
| `tests/helpers.tcl` | a `mainThreadStartup` capability constraint |
| `tests/platform/native-status.tcl`, `tests/platform/aot-facts.tcl` | the policy's status per host; LC_MAIN's `stacksize` in a main-thread executable (`otool -l`) |
| `docs/` | the milestone report; SINGLE-EXECUTABLE.md, MACOS-AARCH64-PORT-AUDIT.md, AGENTS.md's "The native stack guard" and "The single-file compiler and the stub linker" |

Not changed: the JIT (`main.rs`'s worker), native libraries
(`library.rs`), coroutines, the collector, the guard's mechanism, the C
FFI, the language.

## 32. The regression tests that implementation must keep

* every executable test file on the `worker` policy, unchanged: the
  executable and C files the `system-linker` job runs
  (`grep -l -e native::executable -e emit-native-executable -e 'extern c '
  tests/*.test`), `tests/system-linker.test` (the three startups' reports
  equal), `tests/aot-stub-linker.test`, `tests/native-executable.test`,
  `tests/argv.test`, `tests/native-program-output.test`,
  `tests/native-library.test`;
* the same files with the `main` policy on macOS, where they apply: the
  argument snapshot, standard output and error, status codes, the driver
  protocol (`BOTLISH_NATIVE_RESULT`, `BOTLISH_NATIVE_RUNS`) and the
  startup report must be identical to the worker's;
* `cargo test --release --manifest-path native/Cargo.toml --test
  native_stack` (its `guard main` checks become the product's),
  `tests/native-stack-overflow.test` and `tests/coroutines.test` on both
  policies, plain and under `BOTLISH_NATIVE_GC_STRESS=1`;
* `audit/native-stack/tools/mutate.tcl` and `audit/native-aot/tools/mutate.tcl`
  with new mutants of the policy (the policy ignored; the guard not
  installed on the main thread; LC_MAIN's size dropped; a `main` executable
  accepted on Linux);
* the macOS app jobs (`single/macos/app-test.sh`, `compare.sh`), since
  Botlish.app's driver emits the policy;
* this census's harness as the graphical acceptance:
  `tools/census.py`'s candidate-A rows on the policy instead of the
  experimental patch.

## 33. What is still unobserved

* **Other Macs**: every macOS fact is the `macos-15` runner's: macOS
  15.7.9 under Apple's virtualization, one 1024 x 768 display. Bare-metal
  Macs, other macOS releases, several displays, a discrete GPU, ProMotion
  and HiDPI scaling were not run; the shared development Mac was not used.
* **The kernel's limit on LC_MAIN's stack size** above Apple ld's 512 MB
  was not probed (only a patched Mach-O could, which Botlish never makes).
* **Interactive input**: no synthetic mouse or keyboard events; the event
  path is a pushed quit event, polled back, and the window's own events.
  Latency of user input on either thread is unmeasured.
* **A visible window to a person**: the windows were captured
  (`screencapture -l`) and their pixels checked; nobody looked at them, and
  the captures are in the run's artifact only.
* **A panic on the macOS main thread** (only on Linux, through the guard's
  refusal); **a dropped coroutine root under GC stress on the main thread**
  (a runtime mutant; not run).
* **Long runs**: each graphical probe runs for about three seconds; no
  minutes-long session, no App Nap or occlusion behaviour, no sleep/wake.
* **An `.app` bundle**: every probe is a command-line Mach-O; an
  application bundle's activation, Dock presence and Info.plist were out
  of scope (and the census's non-goals exclude an Icy Tower bundle).
* **A JIT-run program's identity through C**: impossible by design (a JIT
  program calls no C; section 3).
* **Native libraries on macOS**: refused; the callback model with a Botlish
  export ran on Linux only, headless.
* **iOS, React Native, Windows and Linux main-thread startups**: inspected
  and projected only (sections 26, 29); Linux's main-thread refusal was
  executed.

## 34. GitHub Actions runs and artifacts

`.github/workflows/macos-graphical-main-thread.yml`, job "graphical
main-thread census (macOS arm64)" on `macos-15`; each run's artifact
`macos-graphical-main-thread-census` holds `census-results/` (the outcomes
JSON, the summary, a log per case and per build, the window captures),
`census.log`, the Botlish.app build log, `link-plan-sdl3.log` and
`native-stack.log`.

| Run | Commit | What |
|---|---|---|
| 40824303902, 40824764646 | 84a3c7d5, 2679fc8e | cancelled while queued (superseded by fixes pushed before they started) |
| [40825370442](https://github.com/mwagner-webdev/botlish/actions/runs/40825370442) | a5c6ca45 | **run 1**: success; 130 cases and 5 self-tests, 9 not as predicted -- the two refused LC_MAIN sizes and three 8 MiB main-stack depths and their four dependent rows, which became the predictions of run 2; `results/macos-aarch64/run-40825370442.log` |
| [40827366250](https://github.com/mwagner-webdev/botlish/actions/runs/40827366250) | 0ef97fd9 | **run 2**: success; 156 cases and 5 self-tests, all as predicted; process semantics, the pump's cost, GC-stress timings; `results/macos-aarch64/run-40827366250.log` |
| [40828677344](https://github.com/mwagner-webdev/botlish/actions/runs/40828677344) | 7e5e2bdf | **run 3**: success; 159 cases and 5 self-tests, all as predicted, every case of run 2 in the same class; SIGTERM and SIGINT during a C call on both threads; `results/macos-aarch64/run-40828677344.log` |

`tests (macos arm64)` runs of this branch (40824303861, 40824764669,
40825370455, 40827366242, 40828677450) were cancelled to free the
account's macOS runners for the census: the branch changes no production
code (the census workflow checks the checkout unchanged after every run),
so they would have repeated the base's runs -- `tests (macos arm64)` at
2fa79ebf, the base's parent, succeeded (40820220484); 7aec2a11, the base,
changes only the regenerated scalar assembly audit corpus. The Windows
workflows of the same pushes ran on their own runners.

## 35. Reproduction

On macOS (GitHub's `macos-15`), the workflow runs everything:
`.github/workflows/macos-graphical-main-thread.yml` (a push that changes
it or `audit/macos-graphical-main-thread/`; `workflow_dispatch` with
`repeat` once it is on main). By hand, on an Apple Silicon Mac with Apple's
developer tools, Tcl 9.0.1 (`tests/platform/setup-macos.sh`) and Rust:

```sh
cargo build --release --manifest-path native/Cargo.toml
single/macos/build.sh -o dist
export BOTLISH_SDL3_STATIC_PREFIX="$HOME/Library/Caches/botlish-sdl3-static"
bash tests/platform/link-plan-sdl3.sh dist/Botlish.app
git worktree add --detach /tmp/exp HEAD
git -C /tmp/exp apply "$PWD/audit/macos-graphical-main-thread/patches/main-thread-experiment.patch"
cp -c -R native/target /tmp/exp/native/target
cargo build --release --manifest-path /tmp/exp/native/Cargo.toml
python3 -I audit/macos-graphical-main-thread/tools/census.py \
  --work /tmp/census --out census-results --sdl-prefix "$BOTLISH_SDL3_STATIC_PREFIX" \
  --app dist/Botlish.app --checkout "$PWD" --exp /tmp/exp --tclsh "$(command -v tclsh9.0)" --repeat 10
```

`--only GROUP,...` narrows it (`env`, `identity`, `stack`, `c-graphical`,
`botlish-baseline`, `candidate-a`, `semantics`, `candidate-b`,
`candidate-c`, `controls`, `timing`). One experimental executable by hand:
`BOTLISH_EXPERIMENT_THREAD=main BOTLISH_EXPERIMENT_REPORT=1
/tmp/census/exp/sdl` (candidate A), `BOTLISH_EXPERIMENT_THREAD=dispatch
/tmp/census/exp/dispatch` (candidate B); `/tmp/census/csdl MODE` for the C
controls.

On Linux (the dry run and the Linux rows), with a static SDL3 3.4.18 built
with `-DSDL_STATIC=ON -DSDL_SHARED=OFF -DSDL_UNIX_CONSOLE_BUILD=ON`:

```sh
python3 -I audit/macos-graphical-main-thread/tools/census.py --work /tmp/cw --out /tmp/cr \
  --sdl-prefix /tmp/sdl-prefix --checkout "$PWD" --exp /tmp/exp --repeat 2
bash audit/macos-graphical-main-thread/tools/library-callbacks.sh tclsh9.0 "$PWD" /tmp/sdl-prefix /tmp/libcb
```
