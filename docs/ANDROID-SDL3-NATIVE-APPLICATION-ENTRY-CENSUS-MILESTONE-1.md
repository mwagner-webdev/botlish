# ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md

## Host-startable Botlish applications, SDL3 lifecycle integration and independently packaged native Android applications

A census, not an implementation milestone. It asks whether a standalone
Android 2048 application can be written substantially in Botlish -- its
entry, its contexts, its game and UI state, its rendering decisions, its
event handling and its main loop -- with SDL3 supplying graphics, input
and Android integration, and what the smallest missing mechanisms are.

Material: `../audit/android-sdl3-entry/` (the probes' sources, the scratch
patch the experiments used, `tools/run-probes.sh` and its output). Nothing
in the compiler, the runtime, the standard library or the packages was
changed.

Evidence is labeled throughout:

* **observed** -- a command run in this census's container (Linux x86-64),
  its output in `audit/android-sdl3-entry/results/run-probes-linux-x86_64.txt`;
* **static** -- read from source or from an artifact's bytes (SDL 3.4.18's
  source at the pinned commit `829a65d7`, Botlish's source at `f06de8e6`);
* **CI** -- a completed workflow of an earlier milestone, cited from its
  report;
* **projected** -- a proposed interface or a consequence not yet shown.

No Android device or emulator ran anything here: the container has no KVM
(`/dev/kvm` is absent), and no phone is attached. Everything said about
Android at run time is static or projected, except what earlier milestones
observed (cited as CI or as theirs).

## Contents

1. [Executive finding](#1-executive-finding)
2. [Starting architecture](#2-starting-architecture)
3. [SDL3 Android lifecycle](#3-sdl3-android-lifecycle)
4. [Current native-library capability](#4-current-native-library-capability)
5. [Entry-program reuse](#5-entry-program-reuse)
6. [Context installation](#6-context-installation)
7. [Thread/lifetime model](#7-threadlifetime-model)
8. [Event-loop choices](#8-event-loop-choices)
9. [Existing SDL3 package](#9-existing-sdl3-package)
10. [External package architecture](#10-external-package-architecture)
11. [Host-startable entry alternatives](#11-host-startable-entry-alternatives)
12. [Exploratory probes](#12-exploratory-probes)
13. [Android lifecycle and rendering resources](#13-android-lifecycle-and-rendering-resources)
14. [ABI and artifact implications](#14-abi-and-artifact-implications)
15. [2048 application plan](#15-2048-application-plan)
16. [Portability](#16-portability)
17. [Risks and correctness tests](#17-risks-and-correctness-tests)
18. [Performance/footprint implications](#18-performancefootprint-implications)
19. [Rejected alternatives](#19-rejected-alternatives)
20. [Recommended next implementation milestone](#20-recommended-next-implementation-milestone)
21. [Main's CI when this census started](#21-mains-ci-when-this-census-started)

## 1. Executive finding

**The preferred architecture is a conventional SDL main loop written in
Botlish, started by SDL3's own Android bootstrap through a 20-line C
`SDL_main` that calls one new, generic native-library entry point: run the
library's entry program on the calling thread, to its end.** SDL3 drives
nothing; the Botlish program installs its contexts, owns its state and its
loop, and returns. SDL3's main callbacks are not used.

**Can a foreign SDL3 host start a Botlish application that installs its own
contexts and runs its own main loop with existing facilities? No, on
Android -- by one policy check, not by missing machinery.** The facts:

* On android-aarch64 the only artifact is a native library
  (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, section 19: an Android
  executable is ARTIFACT). SDLActivity loads shared libraries and calls a
  symbol in one of them (section 3), which matches that artifact.
* A library's entry file holds declarations only (LIBRARY-TOP-LEVEL,
  `native/library.tcl:138` and `:393`), and its exports are
  environment-free: no context, no capture, no suspension
  (EXPORT-ENVIRONMENT and EXPORT-SIGNATURE, `hir/exports.tcl:148`). An
  application's `with context ...` statements and its context-requiring
  functions are therefore refused (**observed**, probe A).
* An instance keeps no mutable state between export calls: a module binding
  cannot be mutated by a function (MUTABLE-PLACE-RECEIVER), and an export
  that reads one captures it (EXPORT-ENVIRONMENT) (**observed**, probe A5).
* Yet the runtime already does exactly what an application entry needs.
  `NAME_create` (`native/src/runtime/library.rs:417`) builds a VM on the
  calling thread and runs the program function -- module initialization,
  then the entry program's top level -- with the library's own stack check
  and no signal handler. With *only* LIBRARY-TOP-LEVEL removed, in a scratch
  copy of the tree:
  * an ordinary entry program -- two context installations, context-owned
    state, a 100,000-frame self-tail-recursive loop -- ran inside
    `f1_create` on a host thread with a 1 MiB stack (**observed**, probe
    F1);
  * a failing entry returned to the host as status 2, NATIVE LIMIT STACK,
    with no signal handler and no `_exit` (**observed**, probe F2);
  * Icy Tower's unchanged application -- the modules game, sdl, render,
    hud, tower and options, the `std::io::IO` and `sdl::Sdl` contexts --
    ran 600 frames under `SDL_RunApp` on a host thread named SDLThread, in
    the shape of SDL's Android bootstrap. Every SDL call the game made ran
    on that thread. The summary line was byte for byte the committed
    executable's, also under `BOTLISH_NATIVE_GC_STRESS=1` (**observed**,
    probe D).

**So the smallest generic addition is a host-startable application entry:
an "application library" whose entry program runs through one new C
function, `NAME_main(argc, argv, &error)`, on the calling thread,
blocking, in a VM made and dropped inside the call** (section 14). It
reuses the program function and M4's entry dispatch, adds no language
construct, no resumable VM, no callback and no second runtime model, and is
not Android-specific. `NAME_create` keeps its meaning (initialization only)
for every library, and LIBRARY-TOP-LEVEL stays for libraries not built as
applications.

**Compiler changes are required, three of them, all generic:**

1. The application entry above (`native/library.tcl`,
   `native/src/runtime/library.rs`, the entry dispatch in
   `native/lower.tcl`, the manifest).
2. **A defect found here:** a cross-target native library with any
   `extern c library` declaration is refused NATIVE TARGET.
   `native/library.tcl:183` asks the driver's `link-plan` command for the
   plan without `--target`, and the driver refuses another target there
   (`native/src/main.rs:776-783`). Observed on the unmodified tree with a
   six-line program (probe E2). No Android library that links SDL3, liblog
   or any other library can be built today; the React Native libraries
   linked nothing, so the Android milestone never met it.
3. The C binding generator has no android-aarch64 target
   (`tools/cheader/toolchain.tcl:82`), so no SDL3 binding can be generated
   for Android (**observed**: `c-bindgen stage sdl3 -target android-aarch64`:
   "no generated binding").

**Everything Android-specific stays outside the core:** an `sdl3` package
target view for android-aarch64 (the binding, a 16 KiB-aligned
`libSDL3.so` and SDL's matching Java classes), a small Android IO package
(no standard namespace is Android's platform interface), and the external
tool `botlish_android` (PM-7A protocol 1). The tool generates the Gradle
project, the `SDLActivity` subclass and the `SDL_main` shim (section 10).

**The first implementation milestone** (section 20) adds the application
entry, fixes the cross-target link plan, adds the generator's Android row,
packages SDL3 for Android, and builds a playable SDL3 2048 APK. Its game
rules are the shared `game2048` engine's and the React Native facade's.
Its UI, input interpretation, rendering decisions and lifecycle policy are
Botlish. It is tested on Linux under `SDL_RunApp` and on the React Native
milestone's Android emulator infrastructure.

## 2. Starting architecture

| Milestone | What it gives this design | What it does not |
|---|---|---|
| PM-7A, EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md | ordinary `.botpkg` dependencies; schema 4 `tools`, run only by `botlish tool`; protocol 1 (input kind `native-library`); the native library manifest, schema 2; target support packages | an application artifact (a new input kind is a new protocol: BOTLISH-TOOLS.md, section 11) |
| ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md | `android-aarch64`, cross-emission of a library's object, the Android runtime archive in a target support package, the NDK link, 16 KiB alignment, API 21 | executables; any library with a link plan (finding 2); a device run |
| BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md | a separately distributed tool package; a library instance owned by one thread, destroyed on it only (the owner-thread reaper); Botlish library code in an Android app process, on a phone natively, under GC stress (owner-observed); APK inspection, 16 KiB pages, native-bridge emulators in CI | an application whose control flow is Botlish's (React Native owns it) |
| PER-THREAD-RUNTIME-STATE-MILESTONE-1.md (M3) | independent thread-affine VMs of one image, each with its own context area and statics | -- |
| BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md (M4) | thread entries as additional roots of one program; entry-specific context checking (`hir/contexts.tcl`'s `entries`); the program function's dispatch on `rt_entry_index` (`native/lower.tcl:10348`) | an entry on a thread Botlish did not make |
| C-CALLBACK-MILESTONE-1.md | synchronous C callbacks during a noescape `FnPtr` call | retained registrations, context-bearing callbacks, foreign-thread entry |
| EVENT-LOOP-MILESTONE-1.md | one scheduler; drivers; the Linux driver's SDL3 hybrid source (a watch wakes, a pump copies on the loop's thread) | an Android driver; production host embedding |
| ICY-TOWER-VERTICAL-SLICE-1.md, ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md | a complete SDL3 application in Botlish: pure rule modules, an SDL airlock behind the `sdl::Sdl` context, a per-platform entry that only installs contexts | an Android entry |
| MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md | the same question on macOS: the program on SDL's main thread (candidate A) beats SDL's callbacks (candidate C), which "need an application-entry contract the language does not have" | -- |

The last row matters: this census reaches the macOS census's conclusion for
Android. Android differs in one respect: the program cannot own the
process's `main`, because Android's process belongs to ART. So the Botlish
entry must be startable from C.

## 3. SDL3 Android lifecycle

The pinned SDL is release-3.4.18 (`tools/c-bindgen/profiles/sdl3.tcl`,
commit `829a65d769d935c4852f8159e964312c0957260a`); everything below is
**static**, read from that commit, unless marked. The wiki pages the brief
lists (README-android, README-main-functions, SDL_AppInit, SDL_AppEvent,
SDL_AppQuit, README-cmake) are generated from the same repository's
`docs/` and `include/SDL3/` files, which were read at the commit instead of
the moving wiki.

### Bootstrap: the ten questions

1. **How SDLActivity starts the native application.**
   `SDLActivity.handleNativeState` creates the thread when the surface is
   ready, the window has focus and `onResume` has been called:
   `mSDLThread = new Thread(new SDLMain(), "SDLThread")`
   (`android-project/.../SDLActivity.java:864`). `SDLMain.run` sets
   display priority, calls `nativeInitMainThread` (saves the thread's
   JNIEnv), `SDLActivity.main()`, then `nativeCleanupMainThread`, and then
   `finish()`es the Activity unless it is already finishing (`:2169-2190`).
   `main()` calls `nativeRunMain(library, function, arguments)` (`:254-261`).
2. **Which library provides the entry.** `getMainSharedObject()` is the last
   name `getLibraries()` returns -- `{"SDL3", "main"}` by default, so
   `libmain.so` -- in the app's native library directory (`:268-296`).
   `getMainFunction()` is `"SDL_main"` (`:283-285`). Both are overridable.
   `nativeRunMain` (`src/core/android/SDL_android.c:827`) `dlopen`s the
   library with `RTLD_GLOBAL` (retrying by bare name for uncompressed App
   Bundle libraries), `dlsym`s the function, builds `argv` with
   `argv[0] = "app_process"`, calls `SDL_RunApp(argc, argv, SDL_main, NULL)`
   (`:903`), and `dlclose`s the library when it returns.
3. **Which thread runs it.** SDLThread: a Java thread SDLActivity made, not
   Android's UI thread and not a thread SDL made. Its stack is ART's default
   for a `java.lang.Thread` created without a size, about 1 MiB (projected:
   not measured here).
4. **JNI initialization and library loading.** `onCreate` loads each name
   of `getLibraries()` on the UI thread (`SDLActivity.java:380`, through
   ReLinker when the app bundles it, else `System.loadLibrary`).
   `libSDL3.so`'s `JNI_OnLoad` (`SDL_android.c:578`) registers its native
   methods and caches classes, so SDL's later JNI calls work from the
   threads it attaches. `libmain.so`'s own `NEEDED` libraries (here the
   Botlish library) are loaded by Android's linker with it.
5. **Which calls must run on SDL's main thread.** `SDL_RunApp`'s generic
   implementation (`src/main/SDL_runapp.c`) calls `SDL_CallMainFunction`,
   which calls `SDL_SetMainReady()` on the calling thread: SDLThread becomes
   `SDL_MainThreadID` (`src/SDL.c:263`). `SDL_IsMainThread()` (`:272`) is
   the video thread once video is initialized, else the events thread, else
   that main thread. The rule is SDL's usual one: video, window, renderer
   and event pumping belong to the thread that initialized video. On
   Android that is whichever thread calls `SDL_Init(SDL_INIT_VIDEO)`.
   (**observed** on Linux in that shape: `SDL_main on thread SDLThread ...
   SDL_IsMainThread 1`, probe D.)
6. **Pause, resume, stop, destroy.** The Activity's callbacks run on the UI
   thread and never call the application. `nativePause`, `nativeResume`,
   `nativeLowMemory` (from `onTrimMemory`) and `nativeSendQuit` (from
   `onDestroy`) only append to a lifecycle queue under a mutex and signal a
   semaphore (`Android_SendLifecycleEvent`, `SDL_android.c:944`; a pause
   cancels a queued resume and the reverse, DESTROY clears the queue). The
   queue is drained on the thread that pumps SDL's events:
   `SDL_PumpEvents` calls `Android_PumpEvents(0)` (`src/events/SDL_events.c:1518`;
   `SDL_WaitEventTimeout` calls it with its delay, `:1755`). There
   `Android_OnPause` sends `SDL_EVENT_WILL_ENTER_BACKGROUND` and
   `SDL_EVENT_DID_ENTER_BACKGROUND`, backs up the EGL context and marks
   the application paused. `Android_OnDestroy` flushes the queue and sends
   `SDL_EVENT_QUIT` and `SDL_EVENT_TERMINATING`
   (`src/video/android/SDL_androidevents.c:113-178`). `onDestroy` waits
   for SDLThread at most **1000 ms** (`mSDLThread.join(1000)`) and then
   `nativeQuit` destroys the lifecycle mutex and semaphore whether or not
   the thread has ended (`SDLActivity.java:687-722`, `SDL_android.c:1529`).
7. **Surface destruction and recreation.** `onNativeSurfaceCreated`,
   `-Changed` and `-Destroyed` run on the UI thread under the activity
   mutex (`SDL_android.c:1262-1330`). Destroyed waits up to 50 x 10 ms for
   SDLThread to have backed up the EGL context (which happens in its pump)
   before releasing the EGL surface. Changed recreates the surface; the
   context is restored on SDLThread when the resume is pumped, and
   `SDL_EVENT_RENDER_DEVICE_RESET` is sent if that fails
   (`SDL_androidevents.c:36-56`). The SDL window survives, and so do the
   renderer and the application's state; only GPU resources may need
   rebuilding.
8. **What SDL manages itself.** The `ANativeWindow`, the EGL surface and
   context backup/restore, audio pause (when blocking on pause), the asset
   manager, the clipboard, the screen keyboard, sensors and HID devices.
9. **What the application supplies.** With the traditional entry: one
   function, `SDL_main(argc, argv)`, returning when the application ends --
   README-android's "Ending your application": return from main, never call
   `exit()` ("it stops the activity badly"). With callbacks: `SDL_AppInit`,
   `SDL_AppIterate`, `SDL_AppEvent`, `SDL_AppQuit`.
10. **The minimal Android host.** SDL's Java classes (`org.libsdl.app`,
    12 files, 6,085 lines, distributed with SDL and version-locked to
    `libSDL3.so`'s JNI signatures), a one-line `SDLActivity` subclass
    overriding `getLibraries()`, the manifest SDL's template ships (its
    `configChanges` list: rotation and size changes are resizes, not
    Activity recreation), and `libmain.so` exporting `SDL_main`. Nothing
    else needs to be the application's.

**Three threads, not one.** Android's UI thread, SDL's main thread and the
Botlish VM's owner are different threads in general. In the recommended
design the last two coincide (SDLThread), and the UI thread never enters
Botlish (section 7).

### Input arrives from the UI thread

`SDLSurface.onTouch` runs on the UI thread and calls `onNativeTouch`, which
calls `SDL_SendTouch` there (`SDL_android.c:1407-1416`). Touch events
therefore enter SDL's queue from the UI thread, and an event *watch* or
*filter* would run on the UI thread for them. `SDL_main.h`'s
`\threadsafety` lines (`:388`, `:407-412`) say that "SDL itself will push
events to the queue on the main thread", which does not hold on Android
for touch. A design that lets a watch, a filter or an event callback enter
a thread-affine VM is therefore wrong on Android even before user threads
push events. A design that only polls SDL's queue on SDLThread never
meets the problem: SDL's queue is thread-safe, and the copy out of it
(`SDL_PollEvent`) happens on the VM's thread.

### Blocking on pause hides the background events from a polling loop

`SDL_HINT_ANDROID_BLOCK_ON_PAUSE` is on by default. `GetLifecycleEventTimeout`
(`SDL_androidevents.c:202`) ignores its `paused` argument and returns -1
(wait forever) as soon as `Android_Paused` is set. So the same
`Android_PumpEvents` call that handled PAUSE (and queued
WILL/DID_ENTER_BACKGROUND) next waits for the following lifecycle event,
RESUME or DESTROY, before it returns. A loop that polls therefore receives
the background events only after the application is back in the
foreground. That is why README-android (and the comment in
`Android_OnPause`) asks applications to handle lifecycle events "in an
event callback" -- an event filter that runs inside the push, on the
pushing thread (SDLThread here). (**static**; to be confirmed on an
emulator in the next milestone.)

For Botlish this decides the policy (section 13): an event filter cannot
be a Botlish function today, so the application sets
`SDL_ANDROID_BLOCK_ON_PAUSE` to `"0"` before `SDL_Init`. It then sees
WILL_ENTER_BACKGROUND in its own loop, saves its state, stops drawing, and
waits in `SDL_WaitEvent` until DID_ENTER_FOREGROUND. With the hint off,
`Android_PumpEvents(0)` waits at most 100 ms per call while paused, and
`SDL_WaitEvent` waits for the next lifecycle event (`:202-212`). Audio is
then not paused automatically; 2048 has none.

### The main callbacks on Android are a loop on SDLThread

With `SDL_MAIN_USE_CALLBACKS`, `SDL_main.h` makes `SDL_main` call
`SDL_EnterAppMainCallbacks`, which on Android is the generic one
(`src/main/generic/SDL_sysmain_callbacks.c:54`): `SDL_AppInit`, then a loop
of `SDL_PumpEvents`, dispatch and `SDL_AppIterate` at
`SDL_HINT_MAIN_CALLBACK_RATE`, then `SDL_AppQuit` and `SDL_Quit`, all on
SDLThread. `SDL_InitMainCallbacks` adds an event watch
(`src/main/SDL_main_callbacks.c:72`, `:112`) that calls `SDL_AppEvent`
*inside the push* for the six lifecycle event types
(`ShouldDispatchImmediately`, `:32`), on whatever thread pushes. On Android
3.4.18 that thread is SDLThread, because the lifecycle queue is drained
there. Every other event is queued and dispatched on SDLThread by the
next iteration. So on Android the callback model is a main loop SDL
writes; the application would get no thread or lifecycle guarantee that
it could not get by writing the loop itself.

### The two models compared for Botlish

| | A. traditional SDL main, a Botlish loop | B. SDL main callbacks, a persistent Botlish instance |
|---|---|---|
| compiler support | an application entry startable from C (section 14) | exports or callbacks that read and change state kept between calls, and see installed contexts: a session model the language does not have |
| runtime support | none new (probe F, D) | state across calls; a VM that is entered four ways |
| native-library ABI | one function, `NAME_main` | four exports or four `callback c fn`s, plus a way to keep state |
| context installation | ordinary `with context` in the entry | none possible: an export installs no context, a callback requires none |
| VM ownership | made, run and dropped inside one call on SDLThread | created in `SDL_AppInit`, destroyed in `SDL_AppQuit`, on SDLThread; any foreign-thread `SDL_AppEvent` is WRONG-THREAD (export) or NATIVE CALLBACK THREAD, which ends the process (callback) |
| state persistence | the program's own values, in its loop | only what crosses the C ABI (int, bool, Float64, str), or hidden in C |
| callback concurrency | none: nothing enters the VM | `SDL_AppEvent` may run on any pushing thread (`SDL_main.h:407-412`) |
| reentrancy | none | a callback re-entering the instance from inside an export: REENTRANT-CALL |
| error propagation | the entry's failure is `NAME_main`'s status and error object | per call; SDL's `SDL_AppResult` must be invented from them in C |
| lifecycle handling | the Botlish loop's decisions (section 13) | split: lifecycle events in `SDL_AppEvent`, frames in `SDL_AppIterate` |
| Android | works with SDL's unchanged bootstrap | works, with the threading caveat |
| desktop portability | the same entry is an executable on Linux, Windows and macOS (main-thread startup) today | needs the same session machinery everywhere |
| future GUI applications | the program owns its loop; an event-loop driver can later own the wait (section 8) | inversion of control everywhere |

**The first implementation uses model A.** B needs a new state and
authority model across calls, gains nothing on Android, and the only
platform where SDL's callbacks are a genuinely different lifecycle is iOS
(a display link on the main run loop), where Botlish has no target.

## 4. Current native-library capability

What exports and instances can do today (**static**, `hir/exports.tcl`,
`native/library.tcl`, `native/src/runtime/library.rs`; NATIVE-LIBRARY-MILESTONE-1.md):

* **Boundary types.** int, bool, Float64, str and unit. No pointer, List,
  struct, handle or callback crosses. An SDL window or renderer cannot be
  passed to or returned from an export.
* **Environment.** An export captures no value, requires no context and
  never suspends (EXPORT-ENVIRONMENT); it declares no context parameter,
  flag section, variadic parameter or resume clause (EXPORT-SIGNATURE).
* **The entry file.** Declarations only (LIBRARY-TOP-LEVEL); at least one
  export (LIBRARY-NO-EXPORTS).
* **Instances.** `NAME_create` makes a VM on the calling thread and runs
  the program function: module statics, and the (empty) top level. Its
  `argv()` is the empty list (`library.rs:427`). It turns the stack-limit
  check on for the creating thread's stack (`:430`) and records the owner
  thread (`:439`). A call from another thread is WRONG-THREAD and a nested
  call REENTRANT-CALL (`:205-209`); a destroy while a call runs is
  REENTRANT-CALL. Handles are never-reused tickets.
* **Stack safety.** No signal handler, no `_exit`; Botlish recursion is
  bounded by a prologue check against the running stack's limit (an
  eighth of the stack in reserve, 64 KiB to 1 MiB). An overflow in C or
  in a runtime helper is still process-fatal.
* **Coroutines** inside a call work (`nl-coroutine-inside`, and the
  coroutine stack-safety tests); suspension across the boundary does not.
* **Threads.** A library instance has no `VmFactory`
  (`native/src/runtime/thread.rs:56`; only `runtime::aot::run` and the
  JIT give one), so `std::thread` has no VM to make in a library: not
  supported, and not needed here.
* **Mutable state between calls.** None. Module bindings are immutable, a
  module-level MutableVector is no place a function may mutate (probe A5),
  and no context is installed.
* **C calls.** An export may call C. A non-retaining call needs nothing
  (probe A6, `getpid`). A retaining call (a pointer parameter whose
  contract is unknown -- every SDL pointer parameter the generator emits)
  is a direct edge, and with no context to mediate it the module must be
  `direct module` (probe A7, accepted; without the marker: DIRECT).

So a host-driven SDL application *can* be assembled from exports today,
but only by:

* giving up contexts (a `direct module` airlock with no authority
  discipline);
* giving up `std::io` (its IO is a context);
* moving the loop and the lifecycle into C;
* passing every frame's state through C as a string.

That is the React Native architecture again, which this application is
meant to go beyond (section 11, option C).

## 5. Entry-program reuse

**Question A: can an ordinary entry be embedded?** Yes, at run time, with
no change. The one obstacle is a policy check:

* *Front end:* an entry program is checked as the main entry --
  installations at the top level, in order, every call's obligations
  against what is installed (`hir/contexts.tcl:66-82`) -- whatever the
  artifact. Nothing in the front end distinguishes a library build.
* *Lowering and code generation:* the program function holds the module
  sections and then the top level (and, with thread entries, M4's dispatch
  between them). A library's program function is the same function: probe
  F's `f1_create` ran the installations and the loop.
* *Runtime startup:* `instantiate` (`runtime/program.rs`) is the one place
  a VM is built from a descriptor, shared by the three executable linkers
  and by libraries.
* *Native-library linking:* unaffected by the top level.
* *The obstacle:* `native::library::TopLevelProblems`
  (`native/library.tcl:393`, called at `:138`) refuses any top-level
  statement that is not a function declaration. Its stated reason is
  sound: "this top-level statement would run whenever an instance is
  created". It is right for libraries called by hosts (React Native),
  whose `create` must not run a script; it is wrong for an application,
  which is a script.
* *What `create` cannot express:* `argv()` is always empty, and a
  completion of the entry is indistinguishable from initialization. The
  manifest describes no entry.

(One presentation defect seen on the way: a single `with context X` line
yields two LIBRARY-TOP-LEVEL diagnostics at the same location, probe A1.
The statement lowers to two top-level roots with one origin.)

**Question B: can an existing export suffice?** Only with the degradations
listed in section 4. An `exported c fn run() -> int:` that runs the loop
must not require a context (EXPORT-ENVIRONMENT). A body that needs
`std::io::IO` or `sdl::Sdl` cannot be called from it, and no context can be
installed anywhere it can see. Rejected for an application.

**Question C: can M4's entry machinery be reused?** Yes, the parts that
matter:

* *Entry-specific context analysis:* the top level already is an entry
  (`entries`). An application library needs no new analysis.
* *Static implementation selection:* one selection per program; it is the
  same for a library.
* *Entry dispatch:* `native::lower::ThreadDispatch` (`native/lower.tcl:10348`)
  asks the runtime which entry this VM runs (`rt_entry_index`: 0 the entry
  program, K a thread entry) where the entry program's own statements
  begin. An application library needs one more answer: "initialize only".
  Then `NAME_create` runs module statics and stops, and `NAME_main` runs the
  top level, through the same switch. That is the whole lowering change.
* *Program metadata, VM construction:* unchanged (`instantiate`).
* *Initialization and result transfer:* not needed. `NAME_main` takes
  `argv` (C strings, made the program's `argv()` as an executable's are)
  and returns a status, not a transferred value.

**The distinction is kept:** a thread entry creates a new OS thread and VM
(`runtime/thread.rs`'s `spawn`, which installs the stack guard); a
host-started entry runs in a VM on a thread the host made, under the
library's stack check, and starts no thread.

**Question D: does the application need multiple calls?** No. The
traditional SDL entry needs exactly one long-lived call. A resumable,
host-driven VM ABI (`init`/`event`/`iterate`/`quit`) is needed only by
SDL's callback model, which section 3 rejects. Not proposed.

## 6. Context installation

A plausible 2048 entry, in the Icy Tower pattern:

```botlish
# app-android.bot -- the Android entry: installs the contexts, runs the app.
import android_io
import sdl
import app

with context android_io::create()
with context sdl::create()

app::main():
    on std::io::WriteFailed:
        unit
```

* **Static selection, explicit installation, restricted injection,
  requirement checking:** all as for any entry program. The entry is
  compiled once into one image; the same checks apply whether the image
  becomes an executable or an application library.
* **VM-owned instances:** each `NAME_main` call's VM owns its context area
  (M3), filled by the entry's own installations. The host installs nothing
  and passes nothing but `argv`. There is no way for C to put a context
  into a VM, and this design adds none.
* **Authority:** SDL invoking `SDL_main` grants nothing. Every SDL call is
  in the Botlish program, mediated by the `sdl::Sdl` context in the
  airlock module that makes it (DIRECT-MODULES.md). Nothing calls into the
  VM from C while it runs.
* **SDL handles and ownership:** Icy Tower's design carries over unchanged
  (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md,
  CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md). The installed `Sdl` owns the
  open session -- window, renderer, scratch memory -- as affine
  `std::ffi::c::Ptr`s in a private session record held in the context's
  vector. Every function that takes a pointer is `private`, and other
  modules see only values. Raw pointers are affine and never sendable.
* **Cleanup ordering:** `sdl::close` releases the scratch memory, the
  renderer, then the window, then calls `SDL_Quit` (`sdl.bot`'s `release`
  and `close`). So the renderer never outlives the window, nor the window
  SDL. In the recommended design the program closes SDL itself before its
  entry returns: on QUIT, on TERMINATING and on every failure. A
  `resource struct` with a `cleanup fn`
  (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md) is the stronger form
  for a later revision of the airlock. Its cleanup may require contexts:
  the cleanup's requirement is charged to the code that may release it.
* **Android Activity destruction:** DESTROY reaches the program as
  SDL_EVENT_QUIT/TERMINATING on SDLThread. The program closes SDL and
  returns, and `NAME_main` drops the VM (its heap, its context area) on
  that thread, inside the 1000 ms `onDestroy` waits (section 13).

## 7. Thread/lifetime model

```text
 Android application process (forked from zygote; ART owns it)
 .----------------------------------------------------------------------------.
 | UI thread  (Java "main")                                                   |
 |   Activity onCreate/onResume/onPause/onDestroy, onTrimMemory               |
 |   SDLSurface: touch -> onNativeTouch -> SDL_SendTouch    (SDL's queue, locked)|
 |   lifecycle -> Android_SendLifecycleEvent  (lifecycle queue + semaphore)    |
 |   onDestroy: nativeSendQuit; SDLThread.join(1000 ms); nativeQuit           |
 |   never calls into Botlish                                                 |
 |        | new Thread(new SDLMain(), "SDLThread").start()                    |
 |        v                                                                   |
 | SDLThread  (Java thread, ART's default stack)                              |
 |   nativeRunMain: dlopen libmain.so, dlsym SDL_main                         |
 |   SDL_RunApp -> SDL_SetMainReady            (SDL's main thread := SDLThread)|
 |   SDL_main  (libmain.so, generated C, ~20 lines)                           |
 |     NAME_main(argc, argv, &error)           (proposed; probes F, D: create) |
 |       VM made           <- owned by this call, on this thread              |
 |       module initialization; entry: with context ...; with context ...     |
 |       app loop: SDL_Init(VIDEO)   (SDL's video thread := SDLThread)        |
 |                 window, renderer  <- owned by the installed sdl::Sdl        |
 |                 SDL_PollEvent / SDL_WaitEvent -> Android_PumpEvents        |
 |                   (lifecycle queue drained HERE)                           |
 |                 draw, present; on QUIT: close renderer, window, SDL_Quit   |
 |       VM dropped        <- heap, context area, on this thread              |
 |     <- status (error object owned by SDL_main, logged, released)           |
 |   dlclose(libmain.so); SDLMain: finish() the Activity                      |
 |                                                                            |
 | SDL's own threads (audio, sensors, HIDAPI): never enter Botlish            |
 '----------------------------------------------------------------------------'
```

| What | Owner |
|---|---|
| Android Activity | ART, the UI thread |
| Java UI thread | Android |
| SDL main/application thread | SDLThread, made by SDLActivity |
| the Botlish VM | the `NAME_main` call, on SDLThread; created and dropped inside it |
| SDL renderer and window | the installed `sdl::Sdl` context of that VM; released by the program before the entry returns |
| SDL initialization and shutdown | the Botlish program (`SDL_Init`, `SDL_Quit` in its airlock) |
| native-library instance | none: `NAME_main` exposes no instance handle |
| event-loop driver | none in the first milestone (section 8) |
| callback registrations | none |
| cleanup responsibility | the program (SDL), then `NAME_main` (the VM); then SDL's bootstrap (`dlclose`, `finish`) |

Because no handle escapes `NAME_main`, the hazards the React Native
milestone had to engineer around -- a host destroying an instance from
another thread, after its thread ended, or while a call runs -- cannot be
expressed. The owner-thread reaper is not needed here.

## 8. Event-loop choices

* **SDL's ordinary poll/wait loop, written in Botlish.** Sufficient for
  2048 and for Icy Tower (whose `run` is one self-tail-recursive function
  the native backend compiles to a loop). Frame pacing comes from vsync
  while animating and from `SDL_WaitEventTimeout` while idle, so an idle
  board costs no CPU. **Recommended for the first milestone.**
* **SDL3's main callbacks.** Rejected (section 3).
* **`std::event_loop` with an SDL source.** Not needed for 2048, and
  without an Android driver it is not possible: the Linux driver package
  is Linux's, and no Android driver exists. The architecture is ready for
  it: EVENT-LOOP-MILESTONE-1.md's Linux driver already integrates SDL3 as
  a *source* in its hybrid mode. An SDL event watch only *posts* a copied
  record from whatever thread pushes the event (never Botlish code), and a
  pump on the loop's thread copies events out of SDL's queue. The tests
  `el-linux-sdl-hybrid` and `el-linux-sdl-hybrid-window` cover the
  watch-before-queue race. That is exactly the shape Android's
  foreign-thread touch events need. A later "Android driver" (Bionic has
  `epoll` and `eventfd`, so the Linux driver's adapter is the first
  candidate; an `ALooper`-based one the alternative) would let a Botlish
  SDL application combine SDL input, network, timers, coroutines and M4
  ports under one scheduler, with no second scheduler and no polling
  bridge. Not implemented here; no Android doorbell either.
* **Where the wait lives** decides composability. In the first milestone
  `SDL_WaitEvent` is the wait. With an event-loop driver, the driver's
  wait is, and SDL's queue is a source pumped in prepare/check. The
  application's frame logic does not change between the two.

## 9. Existing SDL3 package

(**static** unless marked; `generated/c/sdl3/`, `packages/sdl3`,
`packages/sdlkit`, `examples/games/icy-tower/`.)

1. **Bound APIs.** The whole public header set `SDL3/SDL.h` includes:
   1,215 functions bound directly, 1,166 enumerator constants, 103 record
   layouts (`generated/c/sdl3/linux-x86_64/report.tsv`). Everything 2048
   needs is there:
   * `SDL_Init`, windows and renderers, `SDL_RenderFillRect`,
     `SDL_RenderDebugText` (SDL's built-in 8x8 font, which Icy Tower
     already uses), `SDL_SetRenderScale`, `SDL_GetRenderOutputSize`;
   * `SDL_PollEvent`, `SDL_WaitEventTimeout`, the finger events
     (`SDL_EVENT_FINGER_DOWN` ... `_CANCELED`, the `SDL_TouchFingerEvent`
     layout), the lifecycle events (`SDL_EVENT_WILL_ENTER_BACKGROUND` ...
     `SDL_EVENT_TERMINATING`, `SDL_EVENT_LOW_MEMORY`,
     `SDL_EVENT_RENDER_DEVICE_RESET`, `SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED`);
   * `SDL_GetWindowSafeArea`, `SDL_SetHint`, `SDL_GetPrefPath`,
     `SDL_IOFromFile`.
2. **Available on Android unmodified.** All of these: they are SDL's
   portable API, and SDL's Android backend implements them. Its renderer is
   OpenGL ES 2, the first in `src/render/SDL_render.c`'s driver order that
   an Android build has. It also covers touch, lifecycle, and a pref path
   in the app's internal storage.
3. **Desktop-only dependencies.** The binding is a header translation, so it
   does not depend on a platform. Icy Tower's game uses the keyboard state
   (`SDL_GetKeyboardState`), which a touch-only 2048 does not need.
4. **Bundled native libraries.** `sdl3` 0.2.1 bundles libSDL3 for
   linux-x86_64 only and states linux-aarch64's as the system's. There is
   no Android view and no Android libSDL3.
5. **Package target views for android-aarch64.** The package manager knows
   the target (`pm/target.tcl`: ELF machine 183, Bionic, Bionic's and the
   NDK's platform libraries never bundled), so an Android view is a
   descriptor entry and a generated binding away (projected).
6. **Linux/glibc assumptions.** None in the binding text. The generator
   asks a target C compiler for every type, size and offset; for Android it
   needs a row (finding 3). The linux-aarch64 binding has the same data
   model, and probe E links against it. It is a stand-in, not a binding to
   ship.
7. **Ownership.** As section 6. `sdlkit` (packages/sdlkit) is the reusable
   airlock with the same discipline (`sdlkit::Kit`).
8. **Touch events.** Constants and layouts are bound. Reading one is a
   native view of the event buffer's `SDL_TouchFingerEvent`, as Icy Tower
   reads `SDL_EVENT_QUIT` through its `EventType` layout. No airlock exposes
   touch yet.
9. **Lifecycle events.** Constants bound; no airlock handles them yet.
   Hint names are string-literal macros, which the generator does not
   emit as constants (`report.tsv`: `SDL_HINT_ANDROID_BLOCK_ON_PAUSE
   not-constant string-literal`). The application writes
   `"SDL_ANDROID_BLOCK_ON_PAUSE"` itself.
10. **The callback entry model.** Not represented: `SDL_main.h` is not
    included by `SDL.h`, so `SDL_EnterAppMainCallbacks` and `SDL_RunApp` are
    not bound (the callback typedefs of `SDL_init.h` are). The recommended
    design calls neither from Botlish.
11. **Missing Botlish FFI features.** None for model A. Model B would need
    retained and context-bearing callbacks (C-CALLBACK-MILESTONE-1.md,
    section 14).
12. **Reusable renderer and UI logic.** The airlock pattern, the session
    record, error-text capture (`SDL_strlcpy` into a session buffer read
    through a layout), `SDL_RenderDebugText` text, logical presentation,
    and the pure-module/entry split.

### SDL3 Android distribution

| | SDL3 Android AAR (Prefab) | SDL3 from the pinned source with the NDK | a native-library package with Android binaries |
|---|---|---|---|
| reproducibility | SDL's release artifact (`build-scripts/build-release.py`: libraries for four ABIs under `prefab/modules/...`, the Java classes); trusted as published | **observed**: CMake + Ninja + NDK r29, `-DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21`, 250 steps, about a minute here | built by the package's author in the pinned image (PACKAGE-MANAGER-MILESTONE-3.md) from the pinned source, recorded in `packages/RELEASES.tsv` |
| loading | `System.loadLibrary("SDL3")` by SDLActivity | same | same |
| Java bootstrap | in the AAR | SDL's sources, or `SDL3.jar` (`-DSDL_ANDROID_JAR=ON`, needs the Android SDK) | carried in the package's Android view, version-locked to its `libSDL3.so` |
| ABI compatibility | four ABIs; Botlish has arm64-v8a only | arm64-v8a only | arm64-v8a only |
| 16 KiB pages | as built by SDL's release | **observed**: every LOAD segment of `libSDL3.so` aligned 0x4000 (NDK r29's default) | checked from the bytes by the package manager and the tool |
| licence | zlib; the notice travels with the package | same | same |
| size | four ABIs | **observed**: 12,086,056 bytes, 2,401,784 stripped | the stripped one |
| independent distribution | a Gradle dependency outside Botlish's package graph | -- | an ordinary `.botpkg`: one graph, one lock (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md) |

**Recommendation:** the third, built as the second. The `sdl3` package
gains an android-aarch64 view (the generated binding, the bundled
`libSDL3.so`, SDL's Java classes as an opaque file), so SDL3 has one
version per application graph whatever the target. Nothing of SDL enters
the compiler or the Android target support package.

## 10. External package architecture

```text
application project (botlish.json)
  dependencies (one graph, author locks authoritative)
    game2048                         ordinary module package (the engine; unchanged)
    game2048_play (or game2048 0.2)  the played-game rules the RN facade has today (section 15)
    sdl3        (target-aware)       android-aarch64 view: binding, libSDL3.so, SDL Java classes
    android_io  (ordinary)           std::io::IO over liblog (an application's own today: probe E)
    botlish_target_android_aarch64   the Android runtime archive (exists)
    botlish_android (tool package)   protocol 1 tool `android`, input native-library
  build:  botlish -target android-aarch64 -target-support botlish_target_android_aarch64
                  -emit-native-library app -application app-android.bot
  then:   botlish tool -artifact lib/app.manifest.json -target android-aarch64 android generate -out DIR
          (explicit; installing the tool runs nothing)
  then:   the developer's Gradle (or `botlish tool ... android build`, explicit): APK/AAB
```

**Can the full application use the `native-library` artifact kind?** Yes:
an application library is a native library -- static and shared library,
header, manifest -- with one more entry point. The manifest gains an
`application` member (section 14). A tool that needs it refuses a manifest
without it, so protocol 1 and the input kind stay as they are. No HIR, no
source, no compiler internals reach the tool.

**What `botlish_android` generates (projected)**, after checking, as the
React Native tool does, every fact from the manifest and the bytes:

* the manifest's schema, `target` and `targetSupport.platform.minimumApi`;
* the runtime ABI, the `application` member and every file's SHA-256;
* the shared object's ELF: AArch64, 16 KiB segments, its SONAME, platform
  libraries only, and `NAME_main` defined.

From those it writes:

* `settings.gradle`, `build.gradle`, `app/build.gradle`: `minSdk` the
  manifest's, `abiFilters 'arm64-v8a'`, the NDK revision recorded. Native
  libraries are extracted at installation (`useLegacyPackaging`) if
  SDL's loader turns out to need it on native-bridge emulators, as React
  Native's SoLoader did (to be checked, not assumed);
* `AndroidManifest.xml` from SDL's template (its `configChanges`), the
  application's id, name and icon from options;
* `MainActivity extends SDLActivity`, overriding `getLibraries()` to
  `{"SDL3", "<app>", "main"}` -- nothing else;
* `app/src/main/cpp/main.c`, the `SDL_main` shim (probe E's
  `android_main.c`, generic over the library's prefix), and a
  `CMakeLists.txt` that imports the application library and `libSDL3.so`
  by recorded SHA-256 and builds `libmain.so` with
  `-Wl,-z,max-page-size=16384`;
* SDL's Java classes from the `sdl3` package's Android view, and assets
  from the application's directory.

Only the shim (one C file) and the `SDLActivity` subclass (one Java file)
are new host code, both generic. The compiler never learns Gradle,
resources, JNI or APKs.

**Dependency responsibility:**

| Kind | Where it lives |
|---|---|
| Botlish packages | the package graph |
| the Android runtime | the target support package |
| SDL3's native library and Java classes | the `sdl3` package's Android view |
| the SDK, the NDK, Gradle | the developer's installation, located by `ANDROID_NDK_ROOT` and `ANDROID_HOME` as data, checked by the tool |
| Gradle's own dependencies (the Android Gradle Plugin) | pinned in the generated build files |

There is no second Botlish dependency graph, and nothing is fetched by the
compiler.

## 11. Host-startable entry alternatives

**Option A -- SDL's traditional main plus existing exports.** `SDL_main`
creates an instance and calls one export that runs the application. Works
today only if the application drops contexts: no `std::io`, its SDL module
`direct module` (probe A7), state in module-free values. Possible, but
the context architecture is given up exactly where the application begins.

**Option B -- a generic host-startable application entry.** `NAME_main`
runs the entry program (its installations, its loop) on the calling thread
in a VM made for the call. Probes F and D are this option, with `create`
standing in for `NAME_main`.

**Option C -- a persistent host-driven instance.** Four exports or
callbacks (init, event, iterate, quit) over one instance. Probe C measures
it with today's facilities: state crosses as a string twice per call, and
a foreign-thread call is WRONG-THREAD.

**Option D -- a Botlish-owned thread runs the application.** `SDL_main`
would start a VM somehow and then `std::thread::start` a worker that
initializes SDL video. SDL would accept it (its main thread is whichever
initializes video). But it still needs option B's entry to start the first
VM, adds a thread and a second VM, puts the stack guard's signal handler
into an ART process (thread VMs install the guard; libraries must not), and
moves SDL off the thread SDLActivity's lifecycle code joins. No benefit.

| Dimension | A: exports, traditional main | **B: host-startable entry** | C: host-driven instance | D: Botlish-owned thread |
|---|---|---|---|---|
| compiler changes | none | an `-application` library build: LIBRARY-TOP-LEVEL waived, an "initialize only" entry selection in the existing dispatch, `NAME_main`, the manifest member | context- or session-bearing exports/callbacks, persistent mutable instance state, retained registrations | B's, plus thread VMs in libraries (no VmFactory today) |
| runtime changes | none | `botlish_library_main` (argv, entry selection, outcome), about the size of `botlish_library_create` | state across calls; foreign-thread event marshaling | a factory for library instances; a guard policy for ART processes |
| contexts | none (direct module) | ordinary `with context` in the entry | none possible today | ordinary, in the thread entry |
| thread affinity | instance on SDLThread | VM on SDLThread, inside one call | instance on SDLThread; `SDL_AppEvent` may come from others | VM on a Botlish thread; SDL must follow it there |
| lifecycle | C's | the Botlish loop's | split between C and Botlish | the worker's, joined by... nobody SDL knows |
| callback safety | none entered | none entered | foreign-thread or overlapping callbacks refused or fatal | none entered |
| state persistence | in C, or strings | the program's values in its loop | strings through C | the program's values |
| error handling | per call | the entry's failure is one status and error | per call, mapped to `SDL_AppResult` in C | a ThreadFailed, read by whom? |
| cleanup | C destroys the instance | the program closes SDL; `NAME_main` drops the VM, same thread | C, at `SDL_AppQuit` | the worker, unjoined by SDL's shutdown |
| package separation | yes | yes: the shim and Activity are the tool's | yes | yes |
| desktop portability | poor | the same entry is an executable on desktop today | poor | poor |
| future composability | poor | an event-loop driver can own the wait later | needs everything C needs | yes, at a large cost |
| smallest credible milestone | -- (contradicts the goal) | **one artifact option, one C function, two fixes** | a session model, retained callbacks | B plus threads in libraries |

**Decision: B.** A is viable but abandons the property the application
exists to show. C needs a language-level session model to be correct, and
would still be worse than B on Android. D is B with an extra thread.

## 12. Exploratory probes

All sources are in `audit/android-sdl3-entry/probes/`;
`audit/android-sdl3-entry/tools/run-probes.sh [a c f d e]` runs them, and
its complete output is `results/run-probes-linux-x86_64.txt`. Probes F, D
and E use a scratch git worktree of the checkout with
`probes/scratch-tree.patch` applied: LIBRARY-TOP-LEVEL lifted (F, D, E) and
the cross-target link plan by name (E only). The checkout itself was never
modified.

### Probe A: native-library context installation (observed)

| Program | What it tries | Today |
|---|---|---|
| `a1-top-level-install.bot` | an entry installing `std::linux::io` and printing, plus one export | LIBRARY-TOP-LEVEL at 9:1 (twice: the presentation defect of section 5) and 10:1 |
| `a2-export-requires-context.bot` | an export calling a function that requires `std::io::IO` | EXPORT-ENVIRONMENT ("requires the context std::io::IO; a C caller installs no context"), and CONTEXT-FUNCTION-VALUE |
| `a3-export-context-parameter.bot` | an export declaring a context parameter | EXPORT-SIGNATURE, EXPORT-ENVIRONMENT |
| `a4-export-suspends.bot` | an export that yields | EXPORT-SIGNATURE (resume clause), EXPORT-ENVIRONMENT (may suspend), UNWRAPPED-YIELD |
| `a5-export-state.bot` | an export mutating a module-level MutableVector | MUTABLE-PLACE-RECEIVER, EXPORT-ENVIRONMENT (captures) |
| `a6-export-calls-c.bot` | an export calling `getpid` | builds |
| `a7-direct-export-retaining-c.bot` | a `direct module` export calling `free` (a retaining call) | builds; without `direct module`: DIRECT |

The missing capability is exactly one: a way for an entry computation
(installations and statements) to run in a library.

### Probe B: SDL main-thread ownership (static for Android; observed for the shape on Linux)

Android: section 3's ten questions, from SDL 3.4.18's Java and C sources.
Linux, in the same shape (probe D): `sdl_bootstrap.c` starts a thread
named SDLThread with a 1 MiB stack from the process's main thread (playing
the UI thread), which calls `SDL_RunApp(1, {"app_process"}, app_main,
NULL)`:

```text
bootstrap: UI thread tid 14281
bootstrap: SDL_main on thread SDLThread (tid 14282), SDL_IsMainThread 1
```

Every SDL function the game called, recorded by an `LD_PRELOAD` observer
(`sdl_threads.c`) by thread name:

```text
observer: SDL_Init                  1 calls, on SDLThread
observer: SDL_CreateWindow          1 calls, on SDLThread
observer: SDL_CreateRenderer        1 calls, on SDLThread
observer: SDL_PollEvent           611 calls, on SDLThread
observer: SDL_RenderPresent       600 calls, on SDLThread
observer: SDL_RenderDebugText    2876 calls, on SDLThread
observer: SDL_DestroyRenderer       1 calls, on SDLThread
observer: SDL_Quit                  1 calls, on SDLThread
```

What was not observed: an Android Activity, ART, JNI, the UI thread's
touch path, pause, surface loss.

### Probe C: a persistent host-owned instance (observed)

The React Native 2048 facade (`examples/react-native/2048/game.bot`), built
as a host library, driven by `host_driven.c` on one thread:

```text
create: 146.4 us, RSS 2096 -> 2780 KiB (+684)
state: 59 bytes
move: 20000 calls, 29.25 us per call (state crossing twice), 0 refused
foreign-thread call: status 4 identity WRONG-THREAD
destroy: status 0, RSS 4428 KiB
```

A first run measured 27.56 and 25.83 us per call and a 121.8 us create.

* One host thread can create an instance, call it repeatedly and destroy
  it.
* The application's state is retained only by round-tripping it through
  C: the 59-byte snapshot is parsed and re-serialized by every call, since
  the instance itself keeps nothing.
* Contexts and long-lived SDL resources cannot live in it (probe A).
* For comparison, the same engine's moves inside one long-lived
  computation (`examples/games/2048/bench.bot` as an executable, 202,000
  moves in 3,252 ms against 2,000 in 38 ms) cost about 16 us each. The
  host-driven shape adds about 10 us of parsing and crossing per call.

### Probe D: SDL3 rendering through a host-started entry (observed, headless)

`d1-icy-entry.bot` is Icy Tower's `main.bot` with fixed arguments (a
library's `argv()` is empty today): `std::linux::io` and `sdl::Sdl`
installed, `game::main` run. Built as a library by the scratch tree
against the package-owned SDL3 3.4.18 (headless build: dummy and offscreen
drivers), started by `sdl_bootstrap.c` as above, `SDL_VIDEO_DRIVER=dummy`:

```text
frames=600 round=1 floor=36 score=360 best=35.5 time=10.0 over=no x=247 y=3469 camera=3211 platforms=11 rng=659525717
bootstrap: the application returned; destroy status 0
bootstrap: SDL_RunApp returned 0
```

The committed executable, `audit/icy-tower/artifacts/icy-tower --autopilot
--fixed-step --frames 600 --seed 17`, prints the identical line. With
`BOTLISH_NATIVE_GC_STRESS=1` the library run printed it too (538 ms
against 324 ms). The window, renderer, debug-text drawing, polling and
cleanup all ran inside the entry on SDLThread. Not covered: touch input,
resize, background/foreground (a dummy driver has none of them), and a
real GPU renderer.

### Probe E: the Android package boundary (static: built and inspected, not run)

* The Android target support package was built from this checkout
  (`audit/android-aarch64-target/tools/package.sh`, NDK r29
  `29.0.14206865`, API 21, runtime ABI `e6c1492eceebb13c`).
* SDL3 3.4.18 was built for arm64-v8a, API 21, with the NDK.
* `e1-icy-android-entry.bot` is probe D's entry with an application-owned
  IO (`android_log.bot`: `std::io::IO` over liblog's
  `__android_log_write`). `std::linux::*` is UNSUPPORTED-PLATFORM on
  Android, so `std::linux::io` cannot be the IO there.

Building it found:

1. **E2, on the unmodified tree:** any cross-target library with a link
   plan is refused NATIVE TARGET. The six-line `e2-link-plan-cross.bot`
   (`extern c library "log"`, one extern, one export) fails; the same
   program without its `extern` lines builds. (Finding 2, section 1.)
2. **No android-aarch64 SDL3 binding** can be staged or generated
   (finding 3). The linux-aarch64 binding stands in for the probe.
3. **A context field of type str has no native context slot**
   (CONTEXT-NATIVE-LOWERING-UNSUPPORTED). The first `AndroidLog` held its
   tag as a `str`; it now holds two `std::ffi::c::Int` priorities. Not a
   blocker, but an Android IO package must be written around it.

With the scratch patch, the application linked. The three shared objects
an APK would carry, from their bytes (`readelf`, `llvm-strip`):

| File | Machine | NEEDED | LOAD alignment | Bytes / stripped |
|---|---|---|---|---|
| `libicy.so` (the Botlish application) | AArch64 | liblog, libSDL3, libdl, libm, libc | 0x4000 (3 segments) | 1,197,608 / 850,976 |
| `libmain.so` (`android_main.c`, the `SDL_main` shim) | AArch64 | libicy, libSDL3, liblog, libdl, libc | 0x4000 | 6,192 / 4,728 |
| `libSDL3.so` (3.4.18, NDK r29) | AArch64 | libm, libOpenSLES, libdl, liblog, libandroid, libGLESv1_CM, libGLESv2, libc | 0x4000 | 12,086,056 / 2,401,784 |

`libicy.so` imports 24 SDL functions, all versioned `@SDL3_0.0.0`. It
exports only its C API (`icy_create`, `icy_destroy`, `icy_error_*`,
`icy_bytes_release`, `icy_abi_version`, `icy_version`): its private runtime
is localized. Its manifest records the target, both dependencies (`-llog`,
`-lSDL3`) and the target support package. The unavoidable host glue is
`android_main.c` (about 20 lines) plus SDL's own Java and a one-line
Activity subclass; the compiler core holds none of it.

### Probe F: an entry computation inside a library on a host thread (observed)

| Program | Host thread | Outcome |
|---|---|---|
| `f1-entry.bot`: installs `std::linux::io` and a `Frames` context holding a MutableVector, runs 100,000 frames pushing into it, prints the total | 1 MiB | prints `entry ran in the host's thread: total 5000050000`; `create` status 0; `destroy` status 0 |
| `f2-entry-fails.bot`: non-tail recursion 10,000,000 deep | 1 MiB (and 64 MiB) | `create` status 2, identity NATIVE LIMIT STACK; the process lives |

So the runtime already runs an entry on a host's thread:

* the installations are in the VM's context area, and context-owned
  mutable state works;
* the loop is a loop;
* output goes through the installed IO;
* a failure is a status and an error object, and the stack is bounded by
  the library's check (no signal handler).

M4's machinery was traced statically (section 5). No new entry facility
was implemented: the probe changed one line, and only in a scratch tree.

## 13. Android lifecycle and rendering resources

The application's own state machine, in Botlish (projected; the policy of
section 3):

```text
  SDL_main -> NAME_main -> entry: install contexts
        |
        v
   [Starting] -- SDL_Init / window / renderer fails --> [Failed]: close SDL,
        |                                               log the reason, return
        |                                               (NAME_main: status 1)
        v
   [Running] <-------------------------------------------------.
     | each frame: poll all events; finger events -> gestures;  |
     | game2048 moves; draw the board from state (no textures)  |
     |                                                          |
     |-- SDL_EVENT_WILL_ENTER_BACKGROUND -->                    |
     |      save the snapshot (pref path); stop drawing         |
     |      -> [Background]: SDL_WaitEvent, no frames            |
     |            |-- DID_ENTER_FOREGROUND -> redraw everything -'
     |            |-- QUIT / TERMINATING ----------.
     |-- SDL_EVENT_RENDER_DEVICE_RESET: nothing     |
     |   to rebuild; redraw                         |
     |-- WINDOW_PIXEL_SIZE_CHANGED: re-lay out      |
     |-- LOW_MEMORY: nothing to drop                |
     |-- QUIT / TERMINATING -------------.          |
     v                                   v          v
   [Stopping]: save the snapshot; close renderer, window, SDL_Quit;
               the entry ends -> NAME_main drops the VM -> SDL_main returns 0
```

| Event | What happens, and where |
|---|---|
| initial startup | SDLActivity starts SDLThread only once the surface is ready and the Activity resumed and focused; the entry creates window and renderer |
| foreground / resume | RESUME is queued by the UI thread. The pump on SDLThread restores the EGL context and sends WILL/DID_ENTER_FOREGROUND; the program redraws. |
| background / pause | PAUSE is queued. The pump sends WILL/DID_ENTER_BACKGROUND and backs up the EGL context. With blocking off, the program sees them, saves, stops drawing and waits. |
| surface loss | `surfaceDestroyed` on the UI thread waits up to 500 ms for SDLThread's EGL backup (done in its pump). So the program must pump every frame, which a frame loop does, and must not draw while backgrounded. |
| surface recreation | `surfaceChanged` recreates the EGL surface; the context comes back on resume; DEVICE_RESET if it could not |
| size, density, orientation | `configChanges` makes them resizes: WINDOW_PIXEL_SIZE_CHANGED, then layout from `SDL_GetRenderOutputSize` and the safe area |
| touch cancellation | `SDL_EVENT_FINGER_CANCELED` ends a gesture without a move |
| low memory | `onTrimMemory` queues LOWMEMORY. SDLThread sends `SDL_EVENT_LOW_MEMORY` at its next pump, so it is not lost while the loop runs. While backgrounded, it wakes `SDL_WaitEvent`. |
| app termination | `onDestroy` queues DESTROY: QUIT and TERMINATING on SDLThread's next pump. The program must return within 1000 ms, and then the VM is dropped on SDLThread. |
| Activity recreation | not for configuration changes (`configChanges`). Otherwise, with `SDL_HINT_ANDROID_ALLOW_RECREATE_ACTIVITY` off (the default), the new `onCreate` calls `System.exit(0)` (`SDLActivity.java:355-366`, `:425-440`): the process ends, no Botlish code runs, state saved at background survives |
| process death | without callbacks: only what was saved at WILL_ENTER_BACKGROUND survives; the next cold start loads it |

**Immediate versus deferred.** In 3.4.18 nothing reaches the application
"immediately" from another thread: all lifecycle events are produced by
SDLThread's own pump. The one deadline is `onDestroy`'s 1000 ms, which a
frame loop that pumps every frame meets. No host action is needed before
delegating to Botlish: the shim does nothing but call `NAME_main` and
report its outcome.

**State versus graphics resources.**

* *Pure game state:* the `game2048` value (and the played-game layer's
  seed), immutable, replaced every move.
* *UI state:* the gesture in progress, the layout derived from the output
  size, any animation clock: Botlish values in the loop.
* *SDL rendering resources:* window, renderer and scratch memory in the
  `Sdl` context. The window and renderer survive surface loss.
* *Android lifecycle state:* `paused`, a Botlish value the loop keeps.

A renderer that draws every frame from state with filled rectangles and
`SDL_RenderDebugText` owns no textures, so DEVICE_RESET needs nothing
rebuilt. Surface destruction is never game termination.

**Persistence.** The facade's 59-byte snapshot is already a portable
representation (`new_game`, `move` and `score` of `game.bot` read and
write it). Saving it at WILL_ENTER_BACKGROUND and at QUIT under
`SDL_GetPrefPath`, through `SDL_IOFromFile`, needs only bound functions.
`std::io::fs` is not available, since `std::linux::fs` is Linux's
platform. Optional in the first milestone, and nothing in the design makes
it hard.

## 14. ABI and artifact implications

### The one new public C function (projected)

```c
/* Runs the library's application entry on the calling thread: makes a VM,
 * runs the program's module initialization and its entry program's top
 * level -- which installs its own contexts -- to its end, and drops the VM
 * before returning. ARGC and ARGV become argv() (each argument UTF-8
 * checked, as an executable's). Returns NAME_STATUS_OK when the entry
 * completed; otherwise the failure's status, with *ERROR (when ERROR is not
 * NULL) an error the caller owns (NAME_error_release). Botlish code runs on
 * this thread and stack, bounding its own recursion; nothing unwinds.
 * A call while this thread runs a call of the same library is
 * NAME_STATUS_INVOCATION (REENTRANT-CALL). Several threads may each run
 * one: every call has its own VM. */
int32_t NAME_main(int argc, char **argv, NAME_error **error);
```

* **Static checking:** unchanged. The entry program is checked as the main
  entry, as for an executable: one program-wide selection of each context
  trait, its own installations, no inheritance, no captured environment.
* **Compiled image:** one, as for every library. The program function gets
  M4's entry selection at the boundary between module initialization and
  the top level, with one new selector value, "initialize only".
  `NAME_create` selects it; `NAME_main` selects the entry program.
  Executables and ordinary libraries are unchanged. A library built from
  an entry that has thread entries refuses `std::thread` at run time (no
  factory) until that is a milestone of its own.
* **Artifact option:** `-emit-native-library NAME -application` (one
  input file). LIBRARY-TOP-LEVEL is waived and LIBRARY-NO-EXPORTS too;
  exports, if any, keep every export rule and are reached only through
  `NAME_create` instances.
* **Manifest:** schema 3 only for application libraries (schema 2 stays
  byte for byte for every other library, so the React Native tool is
  untouched). It gains `application`: `{c: "int32_t NAME_main(int argc,
  char **argv, NAME_error **error)", thread: "calling", returns:
  "completion", argv: "utf-8", error: {...}}`. A tool needing an
  application refuses a schema 2 manifest.
* **Runtime ABI:** the library object's forwarders call the runtime's entry
  points, so a new one (`botlish_library_main`) is part of the runtime ABI
  the manifest's `runtimeAbi` names. Whether the fingerprint's inputs
  (`runtime::aotimage::abi_words`) must list it, as a program object
  linked against an older runtime would otherwise reach a missing symbol
  at link time, is for the implementation to settle.
* **No VM pointer** reaches C or Botlish, and no Botlish value names one.
* **Blocking, not incremental.** A resumable entry is not part of this
  contract.

### The two fixes

* **Cross-target link plan** (finding 2). The driver's `link-plan` accepts
  `--target` (it resolves names and archive paths and reads archives' bytes:
  a cross-target archive check is the Android runtime check's job), or the
  library path resolves an Android plan itself. Either way the plan stays
  intent in HIR, resolved at link (NATIVE-LINK-PLAN-MILESTONE-1.md).
* **Generator row** (finding 3). `android-aarch64 aarch64-linux-android21`
  in `tools/cheader/toolchain.tcl`'s triples, with the NDK's clang and
  sysroot as `BOTLISH_C_*` data. Then `sdl3`'s profile lists the target
  and its binding is committed like the Linux ones.

### What stays outside the core

The Android IO module, SDL3's Android binaries and Java, the tool, the
shim, the Activity, Gradle and the APK.

## 15. 2048 application plan

* **Shared engine.** `game2048` (examples/games/2048/game2048.bot, the
  package) unchanged.
* **Shared played-game rules.** The React Native facade adds the rules a
  played game needs over the engine: a seeded deterministic generator, two
  starting tiles, a spawn after a changing move, the end and the win. They
  live today in `examples/react-native/2048/game.bot`, next to its C
  exports. The SDL3 application must not have a second copy. The facade's
  rule layer moves into a module both import (a `game2048_play` package,
  or `game2048` 0.2.0). The React Native facade becomes thin exports over
  it, and its tests stay its oracle.
* **Botlish UI** (`ui.bot`, pure, every backend):
  * layout from the output size and safe area;
  * tile rectangles and colours from values;
  * the score and status text as `SDL_RenderDebugText` strings scaled by
    `SDL_SetRenderScale`, so no font package and no texture;
  * gesture interpretation: a finger's down/up delta beyond a threshold,
    the dominant axis giving the direction, a CANCELED finger ignored;
  * a restart button region.

  Testable headless, as Icy Tower's `tower.bot` and `hud.bot` are.
* **The SDL airlock** (`sdl.bot`, or `sdlkit` grown):
  * open, close and frame operations as Icy Tower's;
  * polling that returns values: finger, lifecycle, size and quit events;
  * `SDL_SetHint("SDL_ANDROID_BLOCK_ON_PAUSE", "0")` before `SDL_Init`;
  * pref-path save and load.

  Everything pointer-shaped stays private.
* **The application** (`app.bot`): the loop and the state machine of
  section 13. One application module, no platform name.
* **Entries:** `app-android.bot` installs `android_io` and `sdl`;
  `app-linux.bot` installs `std::linux::io` and `sdl` and is an ordinary
  executable for desktop runs and for headless tests.
* **Text rendering:** SDL's debug font (8x8, ASCII) covers numbers, the
  score and short status lines. A nicer font is a later package (SDL_ttf
  or a bitmap font), not a UI toolkit.
* **Correctness:**
  * a scripted run -- seed and swipe directions, injected on Linux by the
    bootstrap pushing finger events through `SDL_PushEvent`, on Android by
    `adb shell input swipe` -- must give the snapshots the React Native
    facade gives for the same seed and moves under the interpreter;
  * input interpretation is tested on the pure `ui.bot`;
  * game rules are tested only where they live.

## 16. Portability

* **Linux, Windows SDL3:** the application's entry is an ordinary
  executable today (Icy Tower's `main.bot`, `main-windows.bot`). The same
  `app.bot` and `ui.bot` run there unchanged; only the entry's IO
  installation differs.
* **macOS SDL3/Cocoa:** an executable with `-native-startup main-thread`
  (MAIN-THREAD-STARTUP-MILESTONE-1.md) puts the same loop on Cocoa's main
  thread; `Botlish.app`'s and Icy Tower's macOS builds do this.
* **Hosts that own `main` or a run loop and call a plug-in entry** --
  Android's SDLActivity, a game launcher, a test harness, a C program that
  wants to run a Botlish tool in-process -- get `NAME_main`. It means the
  same thing on any Linux glibc host and on Android: run a Botlish
  application here and tell me how it ended. (Probe D ran it on Linux.)
  macOS and Windows libraries do not exist yet (NATIVE-LIBRARY-MILESTONE-1.md),
  so there it waits on them.
* **React Native embedding:** unaffected. Its libraries stay declarations
  only; `NAME_create` keeps meaning initialization.
* **Cocoa run loops, iOS:** SDL's iOS host is a display link on the main
  run loop, the one place where SDL's callbacks are a different lifecycle.
  Botlish has no iOS target. Nothing here is designed for it, and nothing
  forecloses it.

The entry is therefore generally useful rather than an Android
workaround. It is also the smallest interface that serves both the React
Native embedding (unchanged) and an application host.

## 17. Risks and correctness tests

### The correctness questions

| # | Question | Answer | Evidence |
|---|---|---|---|
| 1 | Who owns the Botlish VM? | the `NAME_main` call: made at its start, dropped before it returns | probe F (create as stand-in); projected API |
| 2 | Who owns its OS thread? | SDLActivity (SDLThread), never Botlish | static, SDLActivity.java:864 |
| 3 | Who owns the SDL renderer? | the installed `sdl::Sdl` context of that VM | static, sdl.bot; probe D |
| 4 | Who owns SDL initialization and shutdown? | the Botlish program (`SDL_Init`, `SDL_Quit` in its airlock) | probe D (observer) |
| 5 | Botlish initialization fails? | module initialization's error is `NAME_main`'s status and error; no VM survives | static, library.rs `create`'s path; projected for `main` |
| 6 | A declared error escapes initialization? | it cannot escape the entry silently: the completion analysis requires the top level to handle every declared error (UNHANDLED-ERROR, seen while writing probe A1, before it handled `WriteFailed`); a run-time error is the call's status | observed (probe A1's drafts, F2) |
| 7 | A rendering operation fails? | the airlock reports it as a value (`sdl.bot`'s failure text); the program closes SDL and returns; never `exit()` (README-android) | static |
| 8 | Can an SDL callback arrive while Botlish runs? | none is registered. Touch is queued by the UI thread and lifecycle by SDLThread's pump; Botlish only polls | static, section 3 |
| 9 | Can callbacks originate from another thread? | event watches/filters would run on the UI thread for touch; none is installed into Botlish (and C-CALLBACK-MILESTONE-1.md would refuse one: NATIVE CALLBACK THREAD) | static |
| 10 | Can the host request stop without violating affinity? | yes: DESTROY is queued, and SDLThread's own pump turns it into QUIT, which the program obeys | static |
| 11 | Surface destroyed, Activity/process kept? | window, renderer, VM and state survive; EGL surface recreated; redraw on foreground; DEVICE_RESET needs nothing | static |
| 12 | Activity recreated? | for configuration changes, no (resizes). Otherwise the default hint makes SDLActivity `System.exit(0)` | static, SDLActivity.java:355-366 |
| 13 | What survives process death? | the snapshot saved at WILL_ENTER_BACKGROUND or QUIT, if persistence is implemented | projected |
| 14 | How is cleanup ordering guaranteed? | the airlock releases renderer, window, then SDL; the VM is dropped after the entry ends; `NAME_main` returns before `dlclose` | static, sdl.bot `release`/`close` |
| 15 | May cleanup functions require contexts? | yes: a resource's cleanup may require contexts, charged to the releasing code (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md) | static |
| 16 | Host destroys an instance before an active call returns? | not expressible: `NAME_main` hands out no handle; for `create` instances, destroy during a call is REENTRANT-CALL | static, library.rs |
| 17 | Host calls the VM after shutdown? | no handle exists after `NAME_main` returns | projected API |
| 18 | How do native faults propagate? | Botlish recursion: NATIVE LIMIT STACK status (probe F2). A panic: STATUS_INTERNAL. A fault in C or SDL: the process dies, as for any native code in the app | observed (F2), static |
| 19 | Can it be tested without Android? | yes: the same library under `SDL_RunApp` on Linux (probe D), the pure modules on every backend, the entry as an executable | observed |
| 20 | Can the consumer build run without the checkout? | yes, by construction: the single-file compiler, published packages (target support, `sdl3`, `android_io`, `game2048`, the tool), the NDK, the SDK and Gradle -- the React Native clean room's shape. To be shown by the next milestone's clean room | projected |

### Risks

* **SDLThread's stack.** ART's default Java thread stack is about 1 MiB
  (projected). The library's check reserves an eighth (128 KiB), leaving
  about 19,000 Botlish frames (NATIVE-LIBRARY-MILESTONE-1.md measured
  18,992 on a 1 MiB thread). 2048 and its loop need a handful.
  Deep recursion fails cleanly as NATIVE LIMIT STACK. An application that
  needs more cannot ask SDLActivity for a larger thread; it would have to
  run its work in a coroutine (whose stack the check uses) or wait for
  library-owned stacks.
* **ART's own stack guard region.** The library's limit stays at least
  64 KiB above a Java thread's low end, clear of ART's protected region
  (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, section 5). Botlish
  library code did run on ART threads on a phone, under the React Native
  device builds (owner-observed).
* **`dlclose` after `SDL_main`.** `nativeRunMain` `dlclose`s `libmain.so`
  when `SDL_main` returns, and SDLThread then exits, running thread-local
  destructors the Botlish runtime registered on it. If unloading
  `libmain.so` let Android unload the application library before those
  destructors ran, the process would crash at exit.
  * Bionic keeps a library with pending thread-local destructors loaded
    since API 23 (projected).
  * The shim can pin the application library with one
    `dlopen(..., RTLD_NODELETE)`.
  * The next milestone must test exit on API 21 and on API 23 or later.
* **A loop that stops pumping** for more than about 500 ms risks SDL's EGL
  surface handoff and `onDestroy`'s 1000 ms join. A frame loop pumps every
  frame. Long computations belong in coroutines that yield between frames.
* **Blocking on pause** off (section 3): the application must itself stop
  drawing while backgrounded. A mutation test kills a program that draws
  after WILL_ENTER_BACKGROUND.
* **Native-bridge emulators** run the arm64 code translated
  (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md, section 24). The
  lifecycle acceptance runs there in CI; a native arm64 run stays a device
  check.

### Mutations the implementation milestone should contain

| Mutation | Killed by |
|---|---|
| entering a VM from another thread (`NAME_main`'s instance check removed; a create-instance call off-thread) | `nl-application-wrong-thread`, the existing `nl-threads` |
| reentering a VM from a callback (`NAME_main` inside a callback of the same library) | `nl-application-reentrant` |
| destroying a VM before its entry returns (dropping inside the call) | `nl-application-*` under GC stress |
| `NAME_create` running the top level (the "initialize only" selection lost) | `nl-application-create-initializes-only` |
| `argv()` empty or wrongly encoded in `NAME_main` | `nl-application-argv` |
| destroying SDL before dependent resources (airlock order swapped) | the SDL call trace compared with the reference (Icy Tower's `trace-compare.sh` shape) |
| continuing to render after WILL_ENTER_BACKGROUND | Linux harness pushing lifecycle events; Android acceptance (HOME, then frames counted in logcat) |
| dropping a lifecycle event that required action (no save at background) | the persistence acceptance (background, `am force-stop`, relaunch, same board) |
| losing a pending input event (one poll per frame instead of draining) | scripted swipe parity |
| calling an SDL main-thread API from another thread | the observer's thread check in the Linux harness |
| installing a context in the host / implicitly granting one to an entry | static: MISSING-CONTEXT tests in `tests/native-library.test` for an application whose entry lacks an installation |
| linking the Linux SDL3 into the APK | the tool's ELF check (machine, SONAME, platform libraries) |
| loading a wrong-ABI Botlish runtime | `at-*` runtime ABI refusals (existing), the tool's `runtimeAbi` check |
| failing 16 KiB alignment | the tool's and `ValidateShared`'s alignment checks; `inspect-apk`-style APK check |
| the tool reading compiler internals | the tool's source audit (as `rn-*`: only the request and the manifest) |
| game rules reimplemented outside the shared engine | a source audit of the app's modules (no merge or spawn logic outside `game2048`/the played-game layer) plus parity |
| cross-target link plan regression | probe E2 as a test in `tests/android-target.test` |

Regression suites likely affected:

* `tests/native-library.test` and `audit/native-library/tools/mutate.tcl`;
* `tests/threads.test` and `audit/threads/tools/mutate.tcl` (the dispatch);
* `tests/contexts.test`;
* `tests/external-tools.test` (the manifest schema);
* `tests/react-native-package.test` (schema 2 must stay);
* `tests/android-target.test` and its mutants;
* `tests/c-bindgen.test` and the generator's mutants (a new target);
* `tests/package-workloads.test` (an `sdl3` Android view);
* `tests/workload-icy-tower.test` (if the airlock is shared).

## 18. Performance/footprint implications

Measured here (Linux x86-64, 4 cores, single runs, noisy; **observed**)
unless marked:

| Aspect | Value |
|---|---|
| VM initialization (one instance, the 2048 facade library) | 122-146 us; RSS +684 KiB |
| one host-driven call carrying the game state (option C) | 25.8-29.3 us |
| one engine move inside a long-lived computation (option B's shape) | about 16 us |
| Icy Tower, 600 frames, fixed step, dummy driver: library entry under `SDL_RunApp` / executable | 324 ms / 383 ms (GC stress: 538 ms) |
| Android `libicy.so` (whole Icy Tower application + private runtime) | 1,197,608 bytes; 850,976 stripped |
| React Native's `libgame.so` in its APK (for comparison; theirs) | 756,136 bytes |
| `libmain.so` shim | 6,192; 4,728 stripped |
| `libSDL3.so` 3.4.18 arm64 | 12,086,056; 2,401,784 stripped |
| APK native contribution (arm64-v8a, stripped) | about 3.3 MB, plus SDL's Java classes (projected) |
| 16 KiB pages | every LOAD segment of all three aligned 0x4000 |
| SDLThread stack | about 1 MiB, ART's default (projected); 128 KiB of it the library check's reserve |
| coroutine stacks | a library's coroutine runs on its own mapped stack, bounded by the same check (NATIVE-LIBRARY-MILESTONE-1.md, `nl-stack-safety-coroutine`) |
| idle CPU | none with `SDL_WaitEventTimeout` between animations (projected) |
| SDL renderer initialization | not measured (dummy driver here) |

**Single long-lived entry versus repeated C ABI calls.** The crossing costs
are microseconds against a 16.7 ms frame (under 0.2%), so neither is
decided by speed. The difference is what the host-driven shape cannot
keep: contexts, resources and state. The single entry also avoids the
snapshot round trip, whose cost grows with the state.

## 19. Rejected alternatives

* **SDL3 main callbacks into a persistent instance** (option C). It needs
  state and authority across calls that the language does not have. It
  meets foreign-thread `SDL_AppEvent` calls, which a thread-affine VM must
  refuse or die on. It buys no lifecycle guarantee on Android, where the
  callbacks are SDL's own loop on SDLThread.
* **Exports with a `direct module` airlock** (option A). It compiles today,
  but it gives up contexts, `std::io` and the airlock's authority
  discipline -- the property the application should demonstrate.
* **A Botlish-owned worker thread** (option D). It adds a thread, a VM and
  a signal-handling guard to an ART process for nothing, and still needs
  option B to start.
* **An Android executable started by SDL** (`dlopen` of a PIE). Android's
  target emits no executables, and an executable's startup installs the
  process-wide stack guard, which an ART process should not get. Libraries
  are the right artifact.
* **A new `entry`/`application` language construct.** Not needed. An entry
  program already is the construct; the same file is an executable on
  desktop and an application library on Android. The distinction is the
  artifact's, chosen at build time.
* **Lifecycle handling in an SDL event filter written in Botlish.** A
  filter is a retained registration called inside a C call that has no
  `FnPtr` parameter. It would be NATIVE CALLBACK INACTIVE (process-fatal),
  and it could not reach the program's state (callbacks require no
  context). Turning `SDL_ANDROID_BLOCK_ON_PAUSE` off gives the loop the
  events instead.
* **A JNI/Kotlin UI calling the engine.** The React Native milestone
  already proved that shape; it is not this application.
* **An Android event-loop driver now.** Not needed by 2048; deferred to
  when an application combines SDL with network, timers or actors.

## 20. Recommended next implementation milestone

**BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md** -- a playable Android
2048 whose entry, contexts, state, UI, input interpretation, rendering
decisions, lifecycle policy and main loop are Botlish, packaged
independently of the compiler.

### Prerequisites (core, generic; in this order)

1. **Cross-target link plans** (finding 2): a cross-target library with
   `extern c library` builds, its manifest's dependencies and the
   toolchain link agreeing. Test: probe E2 in `tests/android-target.test`.
2. **The generator's android-aarch64 row** (finding 3), and the `sdl3`
   profile's android-aarch64 binding committed.
3. **Application libraries** (section 14): `-emit-native-library NAME
   -application`, `NAME_main`, "initialize only" for `create`, manifest
   schema 3, the header's text, Compilerpedia's `backend.native-library`
   and the CLI topic. Tests (`nl-application-*`):
   * the entry's installations in the VM, failure statuses and argv;
   * create initializing only, wrong thread, reentrancy;
   * two threads with two VMs, GC stress, the stack limit;
   * probe D as a Linux SDL test where `tests/cffi/sdl3.tcl` has built
     SDL3.

### Packages and tools (outside the core)

4. **`sdl3` 0.3.0:** an android-aarch64 view with the binding, a bundled
   16 KiB-aligned `libSDL3.so` built from the pinned source with the NDK in
   the author image, and SDL's Java classes; recorded in
   `packages/RELEASES.tsv`.
5. **`android_io`:** `std::io::IO` over liblog (probe E's module,
   reworked). Whether Android deserves a standard platform namespace is
   left for when a second facility needs one.
6. **`botlish_android`:** protocol 1, input `native-library`, requires
   `application`. `android generate` writes the project of section 10;
   `android build` runs Gradle only when asked. It checks every fact from
   the manifest and the bytes before writing, under stable `AND-*` codes.
7. **The played-game rules** moved out of the React Native facade into a
   module both applications import; the facade's tests unchanged.

### The application (`examples/android-sdl3/2048/`)

8. `app.bot`, `ui.bot`, the airlock, `app-android.bot`, `app-linux.bot`
   (section 15), warning-clean (the warning gate's corpus).

### Acceptance

* **Linux, observed:**
  * the pure modules on all four backends;
  * the Linux executable headless;
  * the application library under `SDL_RunApp` on a SDLThread-shaped host
    with scripted finger and lifecycle events: swipe parity with the
    React Native facade under the interpreter, saves at background, no
    frames while backgrounded, a clean QUIT, every SDL call on SDLThread;
  * under GC stress.
* **Android, CI:** the React Native milestone's emulator jobs (x86_64
  images with the arm64 native bridge, 4 KiB and 16 KiB pages):
  * install and start; logcat lines from the application;
  * scripted `adb shell input swipe` reaching the expected score;
  * HOME and back, the board kept; rotation (a resize);
  * `am force-stop` and relaunch with the saved board;
  * screenshots compared with the layout's geometry.

  A clean room builds the APK from the single-file compiler and published
  artifacts only. A device build for a phone without adb is a manual
  check, as the React Native milestone's was.
* **APK checks:**
  * `arm64-v8a` only;
  * the three libraries' SHA-256 against the packages' (after Gradle's
    strip);
  * 16 KiB alignment, `zipalign -c -P 16`;
  * no Botlish runtime symbol outside the application library;
  * `libmain.so` defining `SDL_main`.
* **Mutations:** section 17's list, each killed by a named test.

### Non-goals

* SDL main callbacks;
* a resumable or host-driven VM ABI;
* retained or context-bearing callbacks;
* an Android event-loop driver or doorbell;
* Botlish threads in libraries;
* other Android ABIs;
* iOS and Cocoa applications;
* a UI toolkit, fonts beyond SDL's debug font;
* JNI bindings beyond SDL's own;
* React Native changes (schema 2 stays).

## 21. Main's CI when this census started

AGENTS.md asks for `main`'s state at both ends of branch work. At the
start (main at `f06de8e6`, the React Native merge):

* *In progress or queued:* `tests`, `tests (linux arm64)`, `tests (macos
  arm64)`, `tests (windows x86-64)`, `icy-tower`, `icy-tower (macos
  arm64)`, `c-bindgen`, `react-native 2048`, the release gate, and
  `static-decisions` (at `9a714bd0`).
* *Completed, success:* `icy-tower (windows x86-64)`, `single
  executable`, `ci tools`, `prune runs`, `bench`, `scalar-asm-audit`.
* *Nothing red.* The previous `tests` runs on main (`9a714bd0`,
  `ba93014a`, `473a58fa`, `46ab0919`) ended `cancelled`, superseded by
  newer pushes.

At the end (still `f06de8e6`), `icy-tower`, `icy-tower (macos arm64)`,
`c-bindgen` and the release gate had also finished green. `tests`, `tests
(linux arm64)`, `tests (macos arm64)` and `tests (windows x86-64)` were
still queued or running: **pending, not passed**. Nothing was red.

This census adds only documentation and audit material: Markdown, probe
sources, two C harnesses, a shell runner, a patch file and the probes'
output. No compiler, runtime, standard library, package or workflow file
changed. Its push runs only each host's canary job.
