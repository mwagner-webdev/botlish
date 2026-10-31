# ICY-TOWER-MACOS-MILESTONE-1.md

## A playable graphical Icy Tower on macOS AArch64

The Icy Tower vertical slice (ICY-TOWER-VERTICAL-SLICE-1.md) ported to macOS
on Apple Silicon as a Cocoa application: the same game -- its rules, its
rendering and its SDL context unchanged -- built by the distributed
compiler, Botlish.app (MACOS-AARCH64-MILESTONE-9.md), into one Mach-O
arm64 executable that runs its program on the process's main thread
(`-native-startup main-thread`, MAIN-THREAD-STARTUP-MILESTONE-1.md), links
the pinned SDL3 into itself as a static archive with the Apple frameworks
SDL3 needs declared in Botlish source (NATIVE-LINK-PLAN-MILESTONE-1.md),
opens a real Cocoa window, renders with SDL3's Metal renderer, and is played
with keyboard events delivered by the window system.

Platform-specific claims are marked **Executed** (the program ran on that
platform), **Inspected** (source, objects or arguments read without
running), **Environment-blocked** (the test environment prevented it) or
**Not implemented**.

The macOS evidence is GitHub's macos-15 runners' (Apple Silicon, macOS
15.8.2, Xcode 16.4), through `.github/workflows/icy-tower-macos.yml`; the
acceptance run is **41164897163** (commit 9340caef), and the runs before
it are cited where they found something.

## Contents

1. [Result](#1-result)
2. [Starting application architecture](#2-starting-application-architecture)
3. [Port census](#3-port-census)
4. [Existing shared-source guarantees](#4-existing-shared-source-guarantees)
5. [macOS SDL3 binding generation](#5-macos-sdl3-binding-generation)
6. [SDL3 target and SDK evidence](#6-sdl3-target-and-sdk-evidence)
7. [Generated ABI and layout checks](#7-generated-abi-and-layout-checks)
8. [Binding-generator defects](#8-binding-generator-defects)
9. [Package staging](#9-package-staging)
10. [macOS entrypoint and contexts](#10-macos-entrypoint-and-contexts)
11. [Static SDL3 archive provenance](#11-static-sdl3-archive-provenance)
12. [Apple framework dependencies](#12-apple-framework-dependencies)
13. [Native link-plan evidence](#13-native-link-plan-evidence)
14. [Main-thread startup and LC_MAIN evidence](#14-main-thread-startup-and-lc_main-evidence)
15. [Standalone Mach-O dependencies](#15-standalone-mach-o-dependencies)
16. [Compilation with distributed Botlish.app](#16-compilation-with-distributed-botlishapp)
17. [Application-root relocation](#17-application-root-relocation)
18. [Headless simulation](#18-headless-simulation)
19. [Independent oracle results](#19-independent-oracle-results)
20. [SDL dummy-driver results](#20-sdl-dummy-driver-results)
21. [Cocoa window creation](#21-cocoa-window-creation)
22. [Metal rendering](#22-metal-rendering)
23. [Screenshot verification](#23-screenshot-verification)
24. [Keyboard input: left and right](#24-keyboard-input-left-and-right)
25. [Keyboard input: restart and Escape](#25-keyboard-input-restart-and-escape)
26. [Window-close behavior](#26-window-close-behavior)
27. [Event pumping and focus handling](#27-event-pumping-and-focus-handling)
28. [SDL call-trace comparison](#28-sdl-call-trace-comparison)
29. [Context-owned native resource lifecycle](#29-context-owned-native-resource-lifecycle)
30. [Error and exit behavior](#30-error-and-exit-behavior)
31. [GC-stress execution](#31-gc-stress-execution)
32. [Native stack/coroutine safety](#32-native-stackcoroutine-safety)
33. [Linux regressions](#33-linux-regressions)
34. [Windows regressions](#34-windows-regressions)
35. [Mutation testing](#35-mutation-testing)
36. [Fuzzing](#36-fuzzing)
37. [Performance and size](#37-performance-and-size)
38. [macOS CI results](#38-macos-ci-results)
39. [Generated artifacts and their provenance](#39-generated-artifacts-and-their-provenance)
40. [Remaining limitations](#40-remaining-limitations)
41. [Prerequisites for an installable macOS .app](#41-prerequisites-for-an-installable-macos-app)
42. [Reproduction commands and exact files changed](#42-reproduction-commands-and-exact-files-changed)

## 1. Result

**Icy Tower plays on macOS AArch64 as a Cocoa application**, **Executed**
on GitHub's macos-15 runners (acceptance run 41164897163, commit 9340caef):

* Botlish.app, built from the commit and run from outside the checkout,
  compiles the unchanged game -- tower.bot, hud.bot, options.bot,
  render.bot, sdl.bot and game.bot as they are on Linux and Windows -- with
  the macOS entry `main-macos.bot` (std::darwin::io, sdl::Sdl) and
  `macos_link.bot` under `-warnings error` and `-native-startup
  main-thread`, into one Mach-O arm64 executable (3.8 MB, 3.3 MB stripped)
  whose LC_MAIN reserves 512 MiB and whose runtime reports the program on
  the process's main thread.
* SDL3 3.4.18 is linked into it from a static archive built from the
  pinned commit; the 15 Apple frameworks and 2 libraries SDL3 needs are
  declared in Botlish source, checked against SDL3's own sdl3.pc; the
  executable depends on system libraries only and runs with SDL3's build,
  its source, the staged application and Botlish.app moved away (and the
  application rebuilds with the checkout, cargo and rustup gone).
* The SDL3 binding is the generator's, run on the Mac with Apple clang
  (1,231 API names bound, unchanged generator), staged as the application's
  package; its every declaration the game uses agrees with Apple clang's
  own types and layouts (123 of 123 checks).
* It opens a real Cocoa window and renders with Metal; captures of the
  window match the independent oracle's geometry (walls, platforms where
  the oracle puts them, the player, the HUD, the banners); it is played
  with keyboard events posted through the window system -- Left/Right and
  A/D move the player, both together cancel, R restarts a game that is
  over into the generator's next tower, Escape quits, the close button
  quits, and a key held when the focus is lost is not stuck after it
  returns; every SDL call is on the main thread; real time runs at the
  display's 60 frames a second.
* Its SDL call trace for a fixed-step run is the Linux executable's, call
  for call, on SDL's dummy driver and in the Cocoa window; its headless
  summaries equal the oracle's (32 of 32); under GC stress, in a Cocoa
  window too, it does what it does without.
* 25 of 25 mutants of the integration are killed; the Linux and Windows
  icy-tower workflows pass on the same commit.

No game rule changed and no shared module was forked: the port is three
new files in the game's directory, a build-time recipe shared with the
link-plan acceptance, and test tooling. Not done here, by the milestone's
own scope: an application bundle, distribution signing, notarization, a
release (sections 40 and 41).

## 2. Starting application architecture

`examples/games/icy-tower/` as this milestone found it:

| File | Role | Platform |
|---|---|---|
| `tower.bot` | the rules: state, movement, platform generation, collision, camera, score, `step(world, input, dt)`, the autopilot | pure |
| `hud.bot` | the HUD's lines, the banners, the summary line | pure |
| `options.bot` | the command line | pure |
| `render.bot` | a frame: walls and mortar lines, platforms, player, HUD, banner, through sdl.bot's operations | shared |
| `sdl.bot` | the SDL airlock: the context `Sdl` owning the session (window, renderer, keyboard state, scratch memory, all affine C pointers inside its MutableVector), operations taking and returning values only | shared |
| `game.bot` | the program: the frame loop, timing, input, failure reports, `main` | shared |
| `main.bot` | Linux's entry: `std::linux::io` and `sdl::create()` installed, `game::main` | Linux |
| `main-windows.bot` | Windows' entry: `std::windows::io` | Windows |
| `headless.bot`, `golden.bot` | the deterministic simulation; the 67-test golden suite | pure |
| `build.sh`, `build-windows.sh` | the Linux and Windows builds | |

The independent oracle (`audit/icy-tower/oracle.py`) implements the rules
from the report's text; `audit/icy-tower/mutants.txt` holds the rules'
mutants, killed by golden.bot; `audit/icy-tower/tools/xvfb-session.py`
plays the Linux executable in an X11 window; the SDL call trace
(`audit/icy-tower/context-refactor/tools/sdltrace.c`, an LD_PRELOAD
interposer) protected the context refactor.

## 3. Port census

The chain, traced through the code before anything was changed:

    SDL3 3.4.18's pinned headers (tools/c-bindgen/profiles/sdl3.tcl)
      -> tools/c-bindgen.tcl generate sdl3 -target macos-aarch64 (Apple clang, the macOS SDK)
      -> the binding staged as the application's package sdl3 (.bot_modules/sdl3)
      -> the shared modules (game, sdl, render, tower, hud, options)
      -> main-macos.bot (std::darwin::io, sdl::Sdl) and macos_link.bot (the link plan)
      -> Botlish.app's compiler, -native-startup main-thread
      -> Apple's ld: the program object, the runtime archive, libSDL3.a, the frameworks
      -> a Mach-O whose program runs on the process's main thread
      -> SDL's Cocoa driver: a window, Metal, the event queue

1. **SDL3 functions the game calls** (sdl.bot; read from the code,
   comments excluded, by abi-check.py): SDL_Init, SDL_Quit,
   SDL_CreateWindow, SDL_DestroyWindow, SDL_CreateRenderer,
   SDL_DestroyRenderer, SDL_SetRenderLogicalPresentation,
   SDL_SetRenderVSync, SDL_GetKeyboardState, SDL_PollEvent, SDL_GetTicksNS,
   SDL_DelayNS, SDL_GetPerformanceCounter, SDL_SetRenderDrawColor,
   SDL_RenderClear, SDL_RenderPresent, SDL_RenderFillRect, SDL_RenderLine,
   SDL_RenderDebugText, SDL_SetRenderScale, SDL_GetError, SDL_strlcpy,
   SDL_malloc, SDL_free -- 24 -- and C's `exit` (game.bot).
2. **Generated modules imported**: sdl3::ctypes, events, error_h, init,
   keyboard, layouts, render, stdinc, timer, video (sdl.bot) and scancode
   (game.bot).
3. **Target-varying types**: `Uint64` is `unsigned long` on Linux and
   `unsigned long long` on macOS (SDL_GetTicksNS, SDL_DelayNS,
   SDL_GetPerformanceCounter, SDL_WindowFlags): the binding's
   `std::ffi::c::ULong` becomes `ULongLong`, both 64 bits, and the game,
   which converts every one through an Int, compiles unchanged; `char` is
   signed on macOS and Linux x86-64, unsigned on Linux AArch64 (the text
   buffer's elements; the game writes only 0..126); SDL's enumerations are
   `unsigned int` on both Unix targets (`int` with MSVC), which is why
   game.bot already takes scancodes as Ints.
4. **Native layouts the game reads**: sdl.bot's own EventType (SDL_Event's
   `Uint32 type` at offset 0, 128 bytes, alignment 8), KeyState (the
   keyboard state's 512 one-byte bools), TextBuffer (128 chars), and the
   binding's SDL_FRect (four floats).
5. **Borrowing**: one Botlish byte storage crosses a call -- the window
   title, a NUL-terminated Bytes, SDL_CreateWindow's `title` read noescape
   by the profile's manual contract; every other pointer is SDL's or native
   scratch memory from SDL_malloc, read and written through views and edits.
6. **Contexts the entry installs**: an `std::io::IO` (Linux:
   `std::linux::io`, Windows: `std::windows::io`, now macOS:
   `std::darwin::io`) and `sdl::Sdl`.
7. **Arguments**: `game::arguments()` is `argv()` without the program's name.
8. **Keyboard state**: `SDL_GetKeyboardState(NULL)` once, at open; each
   frame `poll` takes every queued event, then reads the state's bytes at
   the six scancodes through KeyState.
9. **Quit**: `SDL_EVENT_QUIT` read from the polled event's type (EventType).
10. **Cleanup**: `sdl::close` pops the session from the context and frees
    the scratch memory, destroys the renderer and the window, then
    SDL_Quit; every failure path releases what it made first.
11. **Staging**: both builds run `tools/c-bindgen.tcl stage sdl3 -package 1`
    (Linux with the committed binding, Windows with the one it generates).
12. **What the oracle and the trace observe**: the oracle the summary line
    of a run (frames, round, floor, score, best, time, over, x, y, camera,
    platforms, rng) and the tower's platforms; the trace every drawing,
    polling, timing and resource call with its arguments.

Gaps found and where they belong:

| Gap | Where it was closed |
|---|---|
| no macos-aarch64 SDL3 binding | generated on the Mac by build-macos.sh (the binding generator, unchanged) |
| no Darwin entry | `main-macos.bot` (the application boundary) |
| static SDL3's link dependencies | `macos_link.bot`, checked against sdl3.pc (the application boundary) |
| the main thread | `-native-startup main-thread` in build-macos.sh (the build's choice) |
| the trace's LD_PRELOAD cannot reach a static archive | a link-time wrapper of the archive (test tooling: traced-archive.sh) |
| Xvfb has no macOS counterpart | macos-session.py and macos-input.m (test tooling) |

No compiler, runtime, standard-library or game-module change was needed.

## 4. Existing shared-source guarantees

`tower.bot`, `hud.bot`, `options.bot`, `render.bot`, `sdl.bot` and
`game.bot` are **unchanged** (`git diff` of this milestone touches none of
them). The macOS port adds two files beside them: `main-macos.bot` (the
entry) and `macos_link.bot` (the executable's native dependencies), which
nothing but main-macos.bot imports. The simulation's numbers, the
generator, the HUD and the command line are the shared code's; the macOS
executable's deterministic runs are compared with the oracle exactly
(sections 18 to 20).

## 5. macOS SDL3 binding generation

`build-macos.sh` runs, on the Mac:

    tclsh9.0 tools/c-bindgen.tcl fetch sdl3
    tclsh9.0 tools/c-bindgen.tcl generate sdl3 -target macos-aarch64 -out DIR

-- the normal generator, the normal profile (the whole public header set,
no API selected), with Apple clang and the SDK it finds itself (no
`BOTLISH_C_SYSROOT_macos_aarch64` is needed on a Mac). The disposition
follows the Windows precedent (ICY-TOWER-WINDOWS.md): the binding needs a
target environment no Linux job has, so none is committed; the build
generates it, keeps it with `ICY_TOWER_BINDING=DIR`, and the workflow
uploads it as part of the run's artifact. A kept binding is reused by
`ICY_TOWER_BINDING_FROM=DIR`, which build-macos.sh checks: the directory
must hold a macos-aarch64 manifest whose revision is the pinned commit, and
the staged package must equal it file for file.

**Executed** on macos-15 (run 41140375636, commit bcacf3c8; the runner image
macos-15-arm64 20261028.0489, macOS 15.8.2, Xcode 16.4, SDK 15.5):

    sdl3 macos-aarch64: 1213 direct, 3 alias, 15 thunk, 158 unsupported, 1655 constants (2358 ms)

-- 1231 of the 1389 API names bound (88.6 %), the same proportion as the
committed linux-x86_64 binding; the unsupported ones by blocker:
macro-needs-signature 100, unsupported-macro 43, by-value-aggregate 8,
va-list 7. Generation took 4.8 s with the fetch (the pinned source cached).

`tools/c-bindgen.tcl diff sdl3 -targets linux-x86_64,macos-aarch64`: 123
differences, every one a fact of the targets, none of SDL's API:

* **64-bit integers.** Apple's `int64_t`/`uint64_t` are `long long`, glibc's
  x86-64 ones `long`: Sint64, Uint64, SDL_Time, SDL_ThreadID,
  SDL_WindowFlags, SDL_TouchID and SDL_FingerID (and two callback types
  over them) are `std::ffi::c::LongLong`/`ULongLong` on macOS and
  `Long`/`ULong` on Linux (9 typedefs), and so are the 51 functions and the
  constants (SDL_WINDOW_* among them) that use them. The game's code is
  unchanged by it: a C integer scalar is an integer domain whose values are
  Ints (C-ABI-TYPES.md), and both are 64 bits wide on both targets, so
  `SDL_GetTicksNS()`'s result, `SDL_DelayNS(ns)`'s argument and
  `SDL_WINDOW_RESIZABLE` mean the same in the one sdl.bot.
* **Platform macros.** Linux-only API (SDL_SetLinuxThreadPriority and
  SDL_SetLinuxThreadPriorityAndPolicy) and the ELF dlopen-note macros exist
  only on Linux; SDL_PLATFORM_APPLE and SDL_PLATFORM_MACOS only on macOS;
  SDL_zero and its siblings expand through another callee there (all three
  unsupported either way); SDL_LINE is a line number.

The binding is uploaded with the run's artifact (`sdl3-binding/`), with its
manifest, report and `layouts-check.c`.

## 6. SDL3 target and SDK evidence

The manifest of the binding the game was built with (run 41140375636):

    target macos-aarch64
    source {url https://github.com/libsdl-org/SDL tag release-3.4.18 commit 829a65d769d935c4852f8159e964312c0957260a}
    revision 829a65d769d935c4852f8159e964312c0957260a
    command {clang -E -x c --target=arm64-apple-macos11 -I$SRC/include $TU/entry.c}
    toolchain_version {Apple clang version 17.0.0 (clang-1700.0.13.5)}
    toolchain_target arm64-apple-macos11
    toolchain_sysroot none
    user_label_prefix _
    preprocessed_tokens 44817

`toolchain_sysroot none`: Apple clang found the SDK itself (Xcode 16.4's
MacOSX15.5.sdk); the generator's own check refuses an Apple target off a Mac
without a sysroot, so no Linux header could have been read as the SDK's.
`user_label_prefix _`: Mach-O's symbol prefix, probed. The ABI check
printed the target's scalar facts from Apple clang: `bool` 1 byte, `int` 4,
`long` 8, `long long` 8, `size_t` 8, pointers 8, `float` 4, `double` 8,
`char` signed, Uint64 `unsigned long long`.

## 7. Generated ABI and layout checks

Two independent checks against the target's C compiler:

* `audit/icy-tower/tools/abi-check.py BINDING SDL_INCLUDE WORK [GAME]`
  writes a C++ translation unit that includes SDL3/SDL.h and, for every SDL
  name the game's code uses, compares the binding's Botlish declaration
  with the compiler's own types: each function's parameter and result types
  extracted from the header's prototype by template deduction
  (`std::tuple_element_t<I, args_of<decltype(&SDL_X)>>`) -- not the
  generator's parse and not its comments -- and compared with the C type
  the binding's std::ffi::c type names (an enum by its underlying type, a
  pointer by its pointee, cv-qualifiers aside); every constant's value and
  type; sdl.bot's EventType and KeyState and the binding's SDL_FRect by
  sizeof, alignof and offsetof; and prints the target's scalar widths. On
  Linux x86-64 against the committed binding: **Executed**, 123 checks, 0
  failed (`workload-icy-tower-abi-check`); its positive control -- a binding
  with SDL_RenderLine's x1 a double, SDL_GetTicksNS an unsigned int and
  SDL_EVENT_QUIT 257 -- fails exactly those three checks.
* the generated binding's own `layouts-check.c` (C-BINDGEN-LAYOUTS.md),
  compiled with Apple clang for arm64-apple-macos11.

On macOS both run against the generated binding and against the package
the game was compiled with (the staged `.bot_modules/sdl3`). **Executed**
(run 41140375636): 38 SDL names used by the game, 123 checks, 0 failed, for
the binding and for the staged package alike -- among them
`SDL_CreateWindow parameter 4 (flags): std::ffi::c::ULongLong`,
`SDL_DelayNS parameter 1 (ns): std::ffi::c::ULongLong`,
`SDL_RenderLine parameter 2 (x1): std::ffi::c::Float`,
`SDL_WINDOW_RESIZABLE is a unsigned long long (sdl3::ctypes::c_ulong_long)`,
`sizeof(SDL_Event) = 128, alignof = 8, offsetof(type) = 0` and SDL_FRect's
four floats at 0, 4, 8 and 12; `layouts-check.c` (19 static assertions)
compiles with Apple clang for arm64-apple-macos11.

## 8. Binding-generator defects

None. The generator ran unchanged on the Mac with Apple clang; no profile
change, no manual fact, no hand edit of the output.

## 9. Package staging

`tools/c-bindgen.tcl stage sdl3 -target macos-aarch64 -dir DIR/macos-aarch64
-app examples/games/icy-tower -into APP -package 1`, exactly as the Windows
build stages its binding: APP holds the game's files beside each other and
the binding as the application's package `APP/.bot_modules/sdl3/sdl3/`
(BOT-MODULES-MILESTONE-1.md). No game import changes: `import sdl3::render`
means the package wherever it was generated. The archive is staged at
`APP/native/macos/libSDL3.a`. build-macos.sh then checks the staged package
against the generated binding (`diff -r`) and the binding's revision
against the profile's pinned commit, and refuses a hand-written or foreign
package (`binding-hand-written`, `linux-binding` and `binding-not-staged`
are mutants of exactly that, section 35).

## 10. macOS entrypoint and contexts

`examples/games/icy-tower/main-macos.bot`:

```botlish
import game
import macos_link
import sdl
import std::io
import std::darwin::io

with context std::darwin::io::create()
with context sdl::create()

result = game::main(game::arguments()):
    on std::io::WriteFailed:
        "failed: writing to the terminal"
result
```

main.bot's program with `std::darwin::io`'s context (libSystem's write(2),
MACOS-AARCH64-MILESTONE-8.md) for Linux's, and `macos_link` imported for
its declarations. No SDL call, no game logic, no path, no startup choice:
the policy is the build's (`-native-startup main-thread` in
build-macos.sh), never the source's (MAIN-THREAD-STARTUP-MILESTONE-1.md,
section 4). **Inspected** on Linux: main-macos.bot compiles for
`-target macos-aarch64` under `-warnings error` with the linux-aarch64
binding standing in (a front-end check; `-direct` reports every game module
ordinary, std::darwin::io contextualized). **Executed** on macOS (run 41140375636):
Botlish.app compiles it under `-warnings error`, and the executable writes
its summary line through std::darwin::io's context (sections 18 to 22).

## 11. Static SDL3 archive provenance

`tests/platform/sdl3-static-macos.sh build PREFIX` -- the recipe
`tests/platform/link-plan-sdl3.sh` used, moved into a script both now run,
so the game and the link-plan acceptance link the same archive from one
CMake invocation: SDL3 3.4.18 cloned at tag `release-3.4.18`, the commit
checked against the profile's pin `829a65d769d935c4852f8159e964312c0957260a`,
`-DCMAKE_BUILD_TYPE=Release -DSDL_STATIC=ON -DSDL_SHARED=ON
-DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF
-DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0`,
installed into a prefix cached by the pin; it prints the macOS and SDK
versions, the archive's `lipo -info`, size and SHA-256. build-macos.sh
requires the staged archive to be arm64 (`lipo -archs`) and an `ar`
archive (`file`), and the driver checks every member (Mach-O arm64,
NATIVE-LINK-PLAN-MILESTONE-1.md section 7). **Executed** (run 41140375636):

    SDL3 3.4.18 (829a65d769d935c4852f8159e964312c0957260a)
    macOS 15.8.2, SDK 15.5, Apple clang version 17.0.0 (clang-1700.0.13.5)
    archive: Non-fat file: .../lib/libSDL3.a is architecture: arm64
    archive: 4651024 bytes, sha256 59d82e5e2103bfffb39f3d2ec694aaa59f9c20ebc3ca6ba90b453f6e79460a52
    built in 88 s

## 12. Apple framework dependencies

`macos_link.bot` declares them, in sdl3.pc's order:

    extern c library "SDL3" static at "native/macos/libSDL3.a"
    extern c framework "CoreMedia"   ... "CoreHaptics"   (15 frameworks)
    extern c library "pthread"
    extern c library "m"

The list is SDL3's, not maintained by hand: `sdl3-static-macos.sh
link-interface PREFIX` translates the installed sdl3.pc's Libs.private
(`-Wl,-framework,X`, `-Wl,-weak_framework,X`, `-lNAME`; anything else is an
error), and build-macos.sh refuses to build unless macos_link.bot declares
exactly that list (a `diff -u` of the two, printed). This is the checked
manifest the milestone allows instead of a generated module: the file is
reviewable, compiles like any module, and cannot drift from SDL3's
metadata. **Weak frameworks**: SDL3 links UniformTypeIdentifiers and
CoreHaptics weakly; Botlish's framework declaration has no weak form, so
both are strong -- harmless on macOS 11 and later, which have both (the
archive's deployment target is 11.0); a deployment limitation, recorded in
section 40, not a reason for new syntax.

## 13. Native link-plan evidence

`BOTLISH_NATIVE_LINK_LOG`, as Botlish.app's driver resolved the plan (run 41140375636):

    link plan: static SDL3: /Users/runner/work/_temp/Stäged Gämes/icy tower/native/macos/libSDL3.a (declared at "native/macos/libSDL3.a")
    link plan: framework CoreMedia: -framework CoreMedia
    ... (the 15 frameworks, in sdl3.pc's order)
    link plan: framework CoreHaptics: -framework CoreHaptics
    link plan: library pthread: -lpthread
    link plan: library m: -lm

The archive's path is the application root's (a path with spaces and
non-ASCII letters), joined by the driver at the link; build-macos.sh checks
the line names the staged archive and the declaration that asked for it.
`build-macos.sh` printed `15 frameworks, 2 libraries: as SDL3's sdl3.pc`
(the declarations against `link-interface`).

## 14. Main-thread startup and LC_MAIN evidence

**Executed** (run 41140375636), on the executable build-macos.sh produced:

    cmd LC_MAIN
    cmdsize 24
    entryoff 1819044
    stacksize 536870912

and the runtime's own account (`BOTLISH_NATIVE_STARTUP_REPORT`, its last
three lines):

    startup main-thread
    process-main-thread 1
    stack 536870912 16384

-- the program record's policy word, the program on the process's main
thread, its 512 MiB stack and a 16 KiB guard. The probe's account agrees
from SDL's side: every SDL call of every Cocoa session on the main thread
(`pthread_main_np()`; 0 of 35,091 calls off it in the `cocoa` case, 0 of
118,075 in `autopilot`). `LC_BUILD_VERSION`: platform 1 (macOS), minos
11.0, sdk 15.5.

## 15. Standalone Mach-O dependencies

**Executed** (run 41140375636). `file`: `Mach-O 64-bit executable arm64`;
`lipo -archs`: arm64. `otool -L`: 22 libraries, every one the system's --
libSystem.B, libiconv.2 and libobjc.A from /usr/lib; CoreMedia, CoreVideo,
Cocoa, UniformTypeIdentifiers, IOKit, ForceFeedback, Carbon, CoreAudio,
AudioToolbox, AVFoundation, Foundation, GameController, Metal, QuartzCore,
CoreHaptics, AppKit, CoreFoundation, CoreGraphics and CoreServices from
/System/Library/Frameworks -- and no SDL3. 1,830 `_SDL_*` functions are
defined in the executable itself (`nm`). Signature: ad hoc, linker-signed
(`codesign --verify --strict` passes). Then the executable, copied alone
to another directory, with SDL3's prefix, the pinned SDL3 source, the
staged application, Botlish.app, the probe and the archive moved away, run
with `env -i HOME=...`: the headless and dummy-driver runs print seed 7's
oracle summary, and a Cocoa run under `DYLD_PRINT_LIBRARIES=1` loads
system images only (1,386 of them, none SDL3's).

## 16. Compilation with distributed Botlish.app

**Executed** (run 41140375636). The workflow builds Botlish.app from the
commit (`single/macos/build.sh`, verified: layout, dependencies, the ad hoc
signature, the archive's 201 files) and moves it out of the checkout to
`$RUNNER_TEMP/Prögram Fïles/Botlish.app`; `botlish --version`: source
revision bcacf3c, packaged; Tcl 9.0.1; native backend packaged. build-macos.sh
compiles with that application's `Contents/MacOS/botlish` (no `tclsh9.0
main.tcl`, no checkout path): 45.8 s to compile and link under
`-warnings error`, `codesign --verify --deep --strict` of the application
passing afterwards (nothing written into it).

## 17. Application-root relocation

**Executed** (run 41140375636). The staged application root is moved to
`$RUNNER_TEMP/Möved Äpp/Ícy Tower`, its executable deleted, and -- with the
checkout, `~/.cargo` and `~/.rustup` moved away and no cargo, rustc or
rustup on PATH, from an unrelated working directory -- Botlish.app compiles
`main-macos.bot` there again (63 s). The link plan names the moved root's
archive (`.../Möved Äpp/Ícy Tower/native/macos/libSDL3.a (declared at
"native/macos/libSDL3.a")`), LC_MAIN's stack is 512 MiB, and the new
executable's 600-frame headless summary equals the first build's.

## 18. Headless simulation

**Executed** (run 41140375636): `icy-tower --headless --frames 600 --seed 7`
prints `"frames=600 round=1 floor=26 score=260 best=29.1 time=10.0 over=no
x=263 y=2947 camera=2551 platforms=11 rng=3699965314"`, the Linux
executable's and the oracle's (`workload-icy-tower-macos-headless`).

## 19. Independent oracle results

**Executed** (run 41140375636): `python3 audit/icy-tower/oracle.py compare
EXE` -- seeds 0, 1, 2, 3, 7, 42, 4294967295 and 123456789 at 1, 60, 600
and 3600 frames, 32 summaries -- 0 differences
(`workload-icy-tower-macos-oracle` too).

## 20. SDL dummy-driver results

**Executed** (run 41140375636): `SDL_VIDEO_DRIVER=dummy icy-tower --autopilot
--fixed-step --frames 600 --seed 7` -- the real SDL loop on the process's
main thread: SDL_Init, a window, the software renderer, events, the
keyboard state, 600 frames drawn and presented, everything released --
prints the headless summary (`workload-icy-tower-macos-dummy-driver`), and
the probe's trace of it is the Linux executable's, frame for frame
(section 28).

## 21. Cocoa window creation

**Executed** (run 41140375636; the `cocoa` case, the probe with
`SDL_VIDEO_DRIVER=cocoa SDL_RENDER_DRIVER=metal`). SDL's account
(SDLTRACE_INFO): `init ok=1 driver=cocoa main=1`, `window ok=1
size=480x653 pixels=480x653 main=1` (480 x 656 in the later sessions). The
WindowServer lists the window (CGWindowList: layer 0, on screen, 480 x 684
points with its title bar in `trace-cocoa`), titled "Icy Tower - Botlish". The runner's one display is 1024 x 768 at
scale 1, so the window manager fits the 720-unit-tall window under the
menu bar: SDL's letterbox draws the 480 x 720 view at 0.91 (the walls give
the scale, section 23). The window opened 0.15 s after the process started
(`first-present since_start=0.146`) on a warm run, 1.0 s on the first.

## 22. Metal rendering

**Executed** (run 41140375636): `renderer ok=1 name=metal main=1` in every Cocoa
session (`cocoa`, `trace-cocoa`, `autopilot`), the frames presented
(`presents=389` in `cocoa`'s 6.6 s of play, 1,359 in `autopilot`'s 22 s),
and in real time with vertical sync a frame every 16.8 ms on average
(median 16.7, 90th percentile 19.0, 99th 27.1 ms: `autopilot`). What
Metal drew is checked in the captures (section 23).

## 23. Screenshot verification

`audit/icy-tower/tools/macos-session.py` reads every capture of the game's
window (`screencapture -x -o -l WINDOW`, the window alone, by the
WindowServer's id for it) as the game's 480 x 720 logical view: it finds
the view inside the capture from the walls -- the two columns of wall color
that span the view's whole height -- which gives the letterbox's origin and
scale (the window manager may shrink a window to the screen, and SDL's
letterbox keeps the aspect), and refuses a capture whose walls are not
20-unit columns at both sides of a 2:3 view. Pixels are read as the
nearest of render.bot's colors (the sky, the HUD panel, the eyes and the
mortar are a few units apart). Each frame is checked against the
independent oracle's geometry:

* the walls (95 % of their samples wall or mortar) and their mortar lines
  (at least 10: one every 48 units);
* the HUD panel and its text;
* the player: found by its color, 26 x 34 units, at the x the oracle gives
  (227 at the start);
* the banner: the start banner (a wide first line) or the game-over banner
  (a narrow one), or none, as the game's time says;
* the platforms where the oracle's tower puts them: each one's body in its
  floor's color 4 units in from both ends and in its middle, the sky above
  it, and not its color 4 units past either end (so a platform shifted by
  more than 4 units, or drawn wider, fails) -- every platform the HUD, a
  banner or the player does not cover.

Positive controls (`macos-session.py selftest`, any host, and the
`controls` case on macOS): synthetic frames rendered from the oracle's
worlds pass; a blank capture, a frame without the player, platforms shifted
by 60 units, the game-over banner where the start banner should be, two
identical captures where the tower must have moved, and a player that did
not move are each rejected. **Executed** on Linux (10 checks, 0 failed;
`workload-icy-tower-macos-session-selftest`). On macOS (run 41140375636):
the `controls` case passed -- the selftest, a real capture with the player
painted out rejected, a blank window rejected, a dummy-driver run never
taken for a Cocoa window -- and the start frame of seed 7 in a Cocoa window
passed every check (walls 100 %, 13 mortar lines, the player 26 x 36 at x
228 against the oracle's 227, the start banner, the oracle's platforms 6 of
6). One check failed on the frame after the banner: the HUD panel, 90 % of
its samples the panel's or the text's colors. The renderer scales the
8-pixel debug font to the letterbox with filtering, so a glyph's edge is a
blend of the two; the check now counts a pixel well inside the segment
between the panel's color and the text's as the panel's (never the sky's,
a few units from the panel's end), and that run's 83 captures, read again,
measure 95 to 97 %. **Executed** (run 41154281867): every check of the `cocoa`
case held -- the start frame and the frame after the banner, the HUD panel
96 % of its samples, the player at x 228 against the oracle's 227, the
oracle's platforms 6 of 6 and 7 of 7 -- and every capture the other cases
judged was located the same way.

## 24. Keyboard input: left and right

Each key is a tap: the helper presses it and releases it after 0.18 s
(`macos-input hold`: the down and up events posted by one process, the
hold timed there), from rest, with room to move -- the player is first
moved away from a wall it would hit (a tap runs about 90 units: RUN_ACCEL
to MAX_RUN, then friction). The player's x is read from the capture
before and after. The tower does not wait: the player bounces and climbs
while the keys move it, and a fall below the camera ends the game, so a
game that ended during a move is restarted with R and the move made again
(the run's summary counts the rounds). The oracle, over 300 runs of the
sequence with random capture delays, judged every move.

Which of Quartz's paths delivers a key is calibrated first: the HID event
tap (as a keyboard's events enter), else the session's tap, else posting to
the game's process. **Executed** (run 41154281867), through the HID tap:

    PASS Right: the player moved +88 units (wanted +20)
    PASS Left: the player moved -116 units (wanted -20)
    PASS D: the player moved +117 units (wanted +20)
    PASS A: the player moved -96 units (wanted -20)
    PASS Left and Right held together: the player moved +0 units (friction only)
    PASS Escape quits: status 0 (exited)
    PASS the summary, round 2 (the games the tower ended were restarted with R 1 time(s))

Both keys are pressed together (one helper process, both down events back
to back), so neither runs alone for a frame: the game's neither-or-both
rule holds the player.

The first run (41140375636) held keys for 0.45 to 0.9 s, which carried the
player up six floors and into a fall; its later captures had no player. The
keys themselves had worked (Right moved the player +185 units); the
harness was changed, not the game.

## 25. Keyboard input: restart and Escape

The restart needs a game that is over, reached by play, not by editing the
game's state. Keyboard play reaches game over only after the tower starts
rising (a best height of 6 m), so the scenario was chosen with the oracle:
seed 254, Right held from 3.5 s on. The oracle, with frame times 1/60 s,
jittered, uniform between 1 and 50 ms and mixed 60/120/30/240 Hz, and the
press anywhere between 2.5 and 9 s (300 runs), always reaches game over
within 1.7 s of the press: running against the right wall, the player
bounces up the platforms that reach it, the camera follows and starts
rising, and the next fall ends the game. After the game-over banner, Right
is released and R pressed; the new game is checked twice against the
generator's rules: the run's final summary (round 2, its rng and platform
count) must be `new_world(S, 2)` for an S the old game's generator reached
(the oracle walks the generator from seed 254), and the platforms in the
capture after R must be that tower's. Round 2 is then played with no key
down, so the oracle also predicts its player: the capture's player must be
centred and its feet on a view row the oracle's no-input run of that tower
draws them on between the moment R was posted and the moment of the
capture (both timed; the camera included), and the summary's floor the
oracle's at the summary's time (with no key down the player bounces from
the ground onto floor 1 within a second, onto floor 2 by 1.5 s: the first
run's expectation of floor 0 was wrong, not the game). **Executed** (run 41154281867):

    PASS Right held reaches game over (the oracle: within 1.7 s of the press)
    PASS a game that is over stays over until R (the game-over banner)
    PASS R: the banner is gone (round 2 has no start banner)
    PASS the summary: round 2, not over
    PASS the new game is the next tower of the same generator (after 11 platforms: seed 224168805)
    PASS R: the new game's player centred, its feet at view row 613, where the oracle's
         run of round 2 with no key down draws them 0.6 to 1.0 s after R (rows 560 to 680)
    PASS the summary's floor 0 is the oracle's at 0.9 s of round 2 with no key down ([0])
    PASS round 2's platforms where the oracle's next tower puts them: 7 of 7
    PASS Escape quits: status 0 (exited)

Escape quits during play in every keyboard case (`keyboard`, `restart`,
`focus`: status 0, the summary printed). A press the window system delivers
before SDL has given the window the keyboard focus does not reach the game
(the mutation runner's baseline run once saw it: Right held, the player
never moved); a held key is therefore confirmed by the player's move and
pressed again after the focus is taken again.

## 26. Window-close behavior

The close is the window's own: Accessibility presses the close button of
the game's window (`AXUIElementPerformAction` on its `AXCloseButton`, what
a click does), else the Window menu's Close through Command-W, else a click
at the button's place. SDL turns the close request into
SDL_EVENT_WINDOW_CLOSE_REQUESTED and, for the last window, SDL_EVENT_QUIT;
the game's poll sees the quit and ends the loop through the ordinary
release path. **Executed** (run 41140375636): `closing the window ends the run:
status 0 (exited, by Accessibility: the close button pressed)`, the summary
printed (`frames=143 ... over=no`), the game drawn before the close.

## 27. Event pumping and focus handling

SDL3's Cocoa driver sends a key press only to a window that has keyboard
focus (`Cocoa_HandleKeyEvent`: `SDL_GetKeyboardFocus()`), and since macOS
14 SDL no longer activates an application itself
(`SDL_HINT_MAC_BACKGROUND_APP` defaults to true there: SDL_cocoaevents.m,
applicationDidFinishLaunching). So the acceptance gives the window the
focus the way a person does -- NSRunningApplication's activation, else a
click on the window's content (the WindowServer activates the application
and makes the window key), else Accessibility -- and records which one
worked. When a window loses the focus, SDL resets the whole keyboard state
(`SDL_SetKeyboardFocus(NULL)` calls `SDL_ResetKeyboard`): the game's own
polling then reads Right as released. The focus case checks that from
outside. **Executed** (run 41154281867):

    PASS Right held runs the player right: the player moved +100 units (wanted +20)
    PASS another application took the keyboard focus (frontmost: macos-input)
    PASS the game's window took the focus back (a click on the window)
    PASS Left alone moves the player left after the focus came back, so Right is not stuck:
         the player moved -118 units (wanted -20)
    PASS Escape quits: status 0 (exited)

Right went down in the game and up in another application (the helper's own
window, made key); back in the game, Left alone moved the player: a stuck
Right would have cancelled it (the both-held check, section 24). The game
also pumps its events every frame without input: the `autopilot` case's
1,266 frames in 21 s, every frame presented, 0.23 s of it in SDL_PollEvent.

## 28. SDL call-trace comparison

The Linux trace is an LD_PRELOAD interposer; SDL3 linked into the
executable has nothing to interpose at run time. The probe is made at link
time instead: `audit/icy-tower/tools/traced-archive.sh` renames, in a copy
of SDL3's archive, every function sdltrace.c wraps (`--redefine-sym
_SDL_X=_real_SDL_X`, definitions and references alike; llvm-objcopy) and
adds sdltrace.c compiled with `-DSDLTRACE_LINKED`, whose wrappers keep
SDL's names, log the call exactly as the interposer does and call
`real_SDL_X`. build-macos.sh links the same staged game against that
archive (`ICY_TOWER_SDL3_ARCHIVE`): the probe build, the game's source
untouched. SDL's own calls between its functions go through its
dynamic-API layer's `*_REAL` names and are not traced, as on Linux.

**Executed on Linux** (the same tooling, ELF): the game linked against a
static SDL3 3.4.18 wrapped this way writes, for `--autopilot --fixed-step
--frames 600 --seed 7` on the dummy driver, a trace identical, frame for
frame, to the LD_PRELOAD interposer's on the shared library.

`audit/icy-tower/tools/sdl-trace.py` normalizes a trace and compares it
with the committed reference, `audit/icy-tower/trace-reference.txt` (the
Linux x86-64 executable's run, as per-frame SHA-256 digests and
per-function counts; `tools/trace-reference.sh EXE check|write`, and
`workload-icy-tower-trace-reference` keeps it current on Linux). Pointers
are already "ptr"/"null" and timestamps are no part of a line; the one
normalization is the window system's event stream: every poll that
returned an event is dropped, in whichever frame it came (the game takes
every waiting event and acts on none but a quit, which would end the run),
and each frame's final empty poll stays. Nothing else -- a missing call, a
wrong rectangle, a wrong color, a wrong float -- is normalized away. The
macOS probe build's trace is compared on the dummy driver and in a Cocoa
window with Metal (fixed steps, the autopilot). **Executed** (run 41140375636):

    trace-dummy: 52313 normalized calls, 600 frames; reference: 52313 calls, 600 frames
                 identical: every call, argument and result of every frame, and the teardown
    trace-cocoa: 52313 normalized calls, 600 frames: identical

with SDL's video driver `dummy` and `cocoa` respectively (52,330 and
52,321 calls as made: 17 and 8 polls that returned a window-system event
dropped), every call on the main thread, and each run's summary the
oracle's. The Cocoa run is the
same program under the same fixed steps; the only calls that differ are
the window system's events, which the game drains and ignores.

The probe also writes `SDLTRACE_INFO`: SDL's video driver and renderer,
`pthread_main_np()` at each SDL call (counted: every call off the main
thread), the window's and drawable's sizes and the session's times.

## 29. Context-owned native resource lifecycle

Unchanged: `sdl::Sdl` owns the session (CONTEXT-OWNED-AFFINE-STATE-
MILESTONE-1.md); open pushes it, close pops and releases it -- scratch
memory, renderer, window, then SDL_Quit -- and every failure path releases
what it made. On macOS every one of those calls is on the main thread (the
probe's account) and in Linux's order (the trace's teardown). **Executed**
(run 41140375636): every Cocoa session's SDLTRACE_INFO ends with `shutdown ... main=1`
(the renderer, the window and SDL_Quit reached, 0.03 s), and both traces'
teardowns are the Linux reference's, call for call.

## 30. Error and exit behavior

The macOS section of tests/workload-icy-tower.test, **Executed** (run 41154281867:
11 tests, 11 passed, the session's selftest among them):

| test | what it holds |
|---|---|
| `-macos-builds` | build-macos.sh: Mach-O arm64, LC_MAIN 536870912, no SDL library, Metal linked |
| `-macos-headless` | seed 7's 600 frames: the oracle's summary, status 0 |
| `-macos-dummy-driver` | the real SDL loop on the dummy driver: the same summary |
| `-macos-gc-stress` | under GC stress: the same summary as without |
| `-macos-restarts` | 2400 autopilot frames on the dummy driver: games lost and restarted, a later round, a clean end |
| `-macos-sdl-failure` | `SDL_VIDEO_DRIVER=nosuch`: what it made released, `Icy Tower: SDL_Init failed: nosuch not available` on standard error (std::darwin::io), status 1, no summary |
| `-macos-renderer-failure` | `SDL_RENDER_DRIVER=nosuch`: the window and SDL released again, `Icy Tower: SDL_CreateRenderer failed: nosuch not available`, status 1 |
| `-macos-usage` | `--fly`: `icy-tower: unknown option: --fly`, status 2; `--help`: the usage, status 0 |
| `-macos-oracle` | `oracle.py compare`: 0 differences |
| `-macos-failed-build-keeps-old` | an archive without SDL3: the link fails (`Undefined symbols`), build-macos.sh says the compilation failed, status 1, the previous executable byte for byte as it was |

and from the session: Escape (status 0, the summary), the window's close
button (status 0, the summary), a worker-startup executable refused by
SDL's Cocoa video (status 1, `SDL_Init failed: cocoa not available`, no
window).

## 31. GC-stress execution

**Executed** (run 41140375636), `BOTLISH_NATIVE_GC_STRESS=1` (a collection at
every allocation, the main thread's 512 MiB stack walked): the dummy-driver
run of 120 frames, seed 11, prints the same summary as without
(`workload-icy-tower-macos-gc-stress`), in 0.07 s; and in a real Cocoa
window with Metal (the session's `gc-stress` case) the same summary,
`"frames=120 round=1 floor=5 score=50 best=5.7 time=2.0 over=no x=132
y=614 camera=218 platforms=13 rng=3691588132"`, the oracle's.

## 32. Native stack/coroutine safety

The game uses no coroutine and recurses nowhere deep; what this milestone
adds is the main thread as the program's thread. The runtime reports the
stack it recorded and its confirmed guard, `stack 536870912 16384`
(run 41140375636): the guard is installed on the main thread's stack (the
system linker's C `main`, MACOS-AARCH64-MILESTONE-4.md), so an overflow
there would end in `NATIVE LIMIT STACK`, as MAIN-THREAD-STARTUP-
MILESTONE-1.md's own tests show for this policy (its `main-thread-startup`
job). No overflow is provoked in the game.

## 33. Linux regressions

The Linux workflow, `icy-tower.yml`, dispatched on the branch: run
41139588760 (commit a33ca6ac), success -- the golden suite, the
executable, xvfb-session.py, the oracle, the trace (with the new
normalization) and every Linux test of tests/workload-icy-tower.test, the
two new ones included (`workload-icy-tower-trace-reference`,
`workload-icy-tower-abi-check`). Locally: tests/workload-icy-tower.test
39 tests, 23 passed, 16 skipped (the 10 macOS and 6 Windows executable
tests), 0 failed; `audit/icy-tower/mutate.tcl`: 26 of 26 killed. On the
acceptance commit 9340caef: `icy-tower.yml` run 41164900037, success.

## 34. Windows regressions

`icy-tower (windows x86-64)` on the branch: run 41140375585 (commit
bcacf3c8), success -- the Windows executable built from the same shared
modules and tested, the tests file's new Linux and macOS tests skipped
there by their constraints. On the acceptance commit 9340caef: run
41164897203, success. The general Windows workflow (`tests (windows
x86-64)`, run 41164897164) covers nothing this milestone changed but the
shared test file: PENDING.

## 35. Mutation testing

Two sets. The rules' mutants (`audit/icy-tower/mutants.txt`, 26) are
unchanged and still killed by golden.bot: 26 of 26 (Linux, locally). The
port's own, `audit/icy-tower/macos-mutants.txt`, 25 mutants of the macOS
integration, run on the macOS runner by `audit/icy-tower/mutate.tcl -macos
1` (`macos-mutate.tcl`; the workflow's mutants step, on
`[ci-icy-tower-mutants]` or a manual run's `mutants`): each in a private
tree, built with Botlish.app against the generated binding and the cached
archive, and met by the detector its `??` line names -- the build's own
checks, the ABI check, the executable's output, a graphical case of the
session, the relocation, the failed build -- with the failure text that
detector must report. Before any mutant, every detector used is run on the
unmutated game and must pass (a detector that fails there kills nothing).

| mutant | the defect | detector | run 41164897163 |
|---|---|---|---|
| startup-flag-omitted | built without `-native-startup main-thread` | build (LC_MAIN) | killed |
| startup-worker | built with `-native-startup worker` | build (LC_MAIN) | killed |
| startup-worker-unchecked | a worker build with the LC_MAIN check removed too | session:cocoa | killed |
| link-dynamic | SDL3 declared as a shared library, the prefix's lib searched | build | killed |
| archive-path-ignored | `static`, the archive's path dropped | build | killed |
| framework-dropped | Metal not declared | build (against sdl3.pc) | killed |
| archive-in-working-directory | the archive staged beside the working directory | build | killed |
| archive-path-absolute | the archive named by the stage's absolute path | build | killed |
| linux-binding | the committed linux-aarch64 binding staged | build (provenance) | killed |
| binding-not-staged | no binding in the staged application | build | killed |
| binding-hand-written | a hand-written timer module in the binding | build (provenance) | killed |
| binding-scalar-type | SDL_RenderLine's x1 a double | abi | killed |
| binding-scalar-type-traced | SDL_SetRenderScale's scaleX a double | session:trace-dummy | killed |
| darwin-io-silent | a context that writes nothing for std::darwin::io's | output | killed |
| event-type-offset | SDL_Event's type read 4 bytes in | session:close | killed |
| input-swapped | Left and Right swapped | session:keyboard | killed |
| held-keys-ignored | the keyboard state never read as held | session:keyboard | killed |
| escape-ignored | Escape does not quit | session:keyboard | killed |
| restart-ignored | R does not restart | session:restart | killed |
| close-ignored | the close request compared with another event type | session:close | killed |
| present-dropped | every frame drawn, none presented | session:cocoa | killed |
| player-shifted | the player drawn 40 units right | session:cocoa | killed |
| renderer-not-destroyed | the renderer never destroyed | session:trace-dummy | killed |
| sdl-not-quit | SDL_Quit skipped | session:trace-dummy | killed |
| failed-link-hidden | a failed compilation reported as success | failed-build | killed |

**Executed** (run 41164897163): every detector passed on the unmutated
game, and **25 of 25 mutants were killed**, each by its own detector with
its own text -- for instance `startup-worker-unchecked`: `a Cocoa window
appears (status 1: Icy Tower: SDL_Init failed: cocoa not available)`;
`link-dynamic`: `macos_link.bot does not declare the staged archive`;
`binding-scalar-type`: `FAIL SDL_RenderLine parameter 2 (x1):
std::ffi::c::Double`; `event-type-offset` and `close-ignored`: the close
button pressed and the game killed after 6 s, never quitting;
`player-shifted`: `start frame: the player at x 268, the oracle's 227`;
`sdl-not-quit`: the trace's teardown differs from Linux's. 29 minutes for
the 25.

The run before (41154281867) killed 23; the three reasons it was not yet a
pass were all the harness's:

* The baseline restart case failed once (its one Right press never
  reached the game: the player stayed at x 227); the press is now
  confirmed by the player's move and made again after the focus is taken
  again (section 25).
* `startup-worker-unchecked` reached the session, where SDL refused the
  worker thread (`cocoa not available`) -- the defect, found -- but the
  cocoa case classified that refusal as the environment's. It is the
  environment's only where the session has no window server or display;
  with both, it is the executable's failure.
* `link-dynamic` was refused by build-macos.sh's check against sdl3.pc
  (an extra `library SDL3`), not by the archive check its detector names;
  the archive check now runs first.

## 36. Fuzzing

No new fuzzer: the game's simulation space is the oracle's grid and the
golden suite's, unchanged, and the macOS-specific risk -- the binding's C
ABI -- is covered by the exact ABI check (section 7) and the call trace
(section 28) rather than by random inputs. The input cases the milestone
lists are cases of the session: both keys held (`keyboard`), release after
sustained movement (`focus`: Right held, released in another application)
and reversal (Right then Left, D then A), game over then R (`restart`, and
`keyboard`'s own restarts), Escape during play (`keyboard`, `restart`),
the window closed during play (`close`).

## 37. Performance and size

On the macos-15 runner (3 CPUs, 7 GiB; run 41140375636):

| | |
|---|---|
| static SDL3 build (CMake, once per pin; cached) | 88 s |
| binding generation (fetch cached) | 4.8 s |
| compile and link with Botlish.app, `-warnings error` | 45.8 s (33 s with `-warnings off`) |
| of which the system linker (`cc`, timed by a wrapper) | 0.52 s |
| executable, as linked | 3,843,256 bytes |
| stripped (and signed again ad hoc) | 3,309,568 bytes; runs |
| startup to exit (`--help`), 5 runs | 0.01 to 0.03 s |
| headless, 3600 frames, 5 runs | 0.05 to 0.06 s |
| dummy driver, autopilot, 3600 fixed steps, 3 runs | 0.33 to 0.35 s |
| GC stress, dummy driver, 120 frames | 0.07 s |
| first frame presented in a Cocoa window | 0.15 s (1.0 s cold) |
| SDL_Init (Cocoa), window, renderer (Metal) | 0.08-0.73 s, 0.03-0.13 s, 0.004-0.11 s |
| real-time frame interval, Metal with vertical sync | mean 16.8 ms, median 16.7, p99 27.1, max 104 |
| time in SDL_PollEvent | 0.23 s of 22 s (1,372 polls) |

The trace probe adds a logging call per SDL call; the frame times above
come from it, and the unprobed executable's headless and dummy-driver
times from `/usr/bin/time`.

## 38. macOS CI results

`.github/workflows/icy-tower-macos.yml`, on every push to any branch
(documentation-only pushes excepted), `game` job on `macos-15`:

| run | commit | result | what it established or found |
|---|---|---|---|
| 41140375636 | bcacf3c8 | failure | the first run: the binding generated, the ABI (123/123), the build, LC_MAIN, the relocation, the oracle, Cocoa and Metal, both traces, the close button, GC stress and the worker control passed; the harness's expectations of the keyboard, restart, focus, autopilot and HUD cases were wrong, a regex read one digit of LC_MAIN's stack, two shell pipelines died of SIGPIPE, a grep matched USDLib |
| 41154281867 | 4a10d061 | failure | every graphical case EXECUTED under `--strict`; 23 of 25 mutants; a capture's name refused by the artifact upload; the standalone step's `sort \| head` |
| **41164897163** | **9340caef** | **success** | every step: the build, the binding, the ABI, the Mach-O, the relocation, the 11 tests, the oracle, the probes, the graphical acceptance (12 of 12 cases EXECUTED, `not EXECUTED: none`), the executable without its build, 25 of 25 mutants, the measurements; the artifact uploaded |

The acceptance run's session, case by case: env 2 of 2 checks, cocoa 20 of
20, keyboard 14 of 14, restart 9 of 9, close 3 of 3, focus 5 of 5,
autopilot 6 of 6, trace-dummy 5 of 5, trace-cocoa 7 of 7, gc-stress 3 of 3,
worker 3 of 3, controls 4 of 4. Its keyboard moves: Right +116, Left -109,
D +109, A -104 units, both keys +0; focus: Right held +108, Left after the
focus came back -110. The workflow's own summary table classifies any
failure (build, binding generation, native link, headless mismatch,
graphical, keyboard, test harness) and never counts an
ENVIRONMENT-BLOCKED case as passed. No case of any run was
environment-blocked: the runners granted event posting and Accessibility
and had a window server and a display.

The other workflows on the acceptance commit: `icy-tower` (Linux) run
41164900037 success, `icy-tower (windows x86-64)` run 41164897203
success; `tests (macos arm64)` (macos-arm64.yml: the link-plan-sdl3 job,
whose archive recipe moved into `sdl3-static-macos.sh`, and the
main-thread-startup job) run 41164897166 and `tests (windows x86-64)` run
41164897164: PENDING.

## 39. Generated artifacts and their provenance

Nothing macOS-generated is committed: each is made on the runner from
committed, pinned inputs and uploaded with the run (the artifact
`icy-tower-macos-aarch64`), as the Windows build does for its MSVC binding.

| artifact | made from | where |
|---|---|---|
| the SDL3 binding, `sdl3-binding/macos-aarch64/` (modules, `manifest.txt`, `report.txt`, `layouts-check.c`) | `tools/c-bindgen.tcl generate sdl3 -target macos-aarch64`: the profile's pinned SDL3 source (tag release-3.4.18, commit 829a65d7...), Apple clang and the runner's SDK, all recorded in the manifest | the run's artifact; build-macos.sh checks the staged package against it, file for file, and its revision against the pin |
| `libSDL3.a` | `tests/platform/sdl3-static-macos.sh build` from the same pinned source: one CMake invocation, printed with its flags, the SDK and the archive's SHA-256 | the runner's cache (`icy-tower-macos-sdl3-...`, keyed by the profile and the script); staged into the application root |
| the executable, `icy-tower-macos-aarch64/icy-tower`, and its `link.log` | build-macos.sh with Botlish.app built from the same commit | the run's artifact |
| the probe (`probe/icy-tower`) and the worker build (`worker/icy-tower-worker`) | the same staged game, linked against the traced archive; built with the default startup | the run's artifact |
| the session: every capture (PNG), each case's output, `results.json`, `summary.md`, the traces and SDLTRACE_INFO files | macos-session.py | the run's artifact (`session/`) |
| `audit/icy-tower/trace-reference.txt` | the Linux x86-64 executable's trace, `trace-reference.sh EXE write` | committed; `workload-icy-tower-trace-reference` keeps it current |

The Linux executable stays committed (`audit/icy-tower/artifacts/icy-tower`,
unchanged by this milestone: no game source changed); a macOS executable
is a CI artifact, because only a Mac builds one.

## 40. Remaining limitations

* **Not an application bundle, not signed for distribution, not
  notarized.** The executable is a command-line Mach-O with the linker's ad
  hoc signature: run from a terminal it is the game; a copy downloaded from
  the internet is quarantined by Gatekeeper. Section 41 lists what an
  installable application needs. No release publishes it.
* **arm64 only.** No x86-64 slice, no universal binary: the native backend
  is AArch64's on macOS (MACOS-AARCH64-PORT-AUDIT.md).
* **Weak frameworks linked strongly.** SDL3 links UniformTypeIdentifiers
  and CoreHaptics weakly; Botlish's `extern c framework` has no weak form.
  Both exist on macOS 11 and later, the archive's deployment target, so
  nothing fails today; an older deployment target would need a weak form
  (a language decision, not this milestone's).
* **The binding is generated per build.** Building needs Xcode's Apple
  clang and the macOS SDK on the Mac (as Windows needs Visual Studio); no
  macOS binding of SDL3 is committed or checked by a Linux job.
* **Tested on one kind of display.** GitHub's runner has one 1024 x 768
  display at scale 1, which makes the window manager fit the window under
  the menu bar (SDL letterboxes the view at 0.91). The frame checks find the
  scale from the walls and handle any; a Retina display (scale 2) and
  several displays were not run.
* **Real time is real.** In a real-time Cocoa run the frame times follow
  the display, and the autopilot (a fixed-step driver) can lose a round;
  determinism is the fixed-step runs' (the traces, the oracle), as on
  Linux.
* **The game's limits are unchanged**: SDL's debug text, no audio, no
  gamepad, no resizing behavior beyond SDL's letterbox.
* **Input reaches the game through the window system only.** The
  acceptance needs the runner's permission to post events (Quartz) and to
  use Accessibility; GitHub's macos-15 runners grant both (the `env`
  case's preflight). Where a runner does not, the keyboard, restart, focus
  and close cases are ENVIRONMENT-BLOCKED, never counted as passed.

## 41. Prerequisites for an installable macOS .app

The executable is a command-line Mach-O that opens a window: run from a
terminal (or `open` on the file), it is the game. An application a person
installs and double-clicks needs, in order:

1. **A bundle**: `Icy Tower.app/Contents/{Info.plist, MacOS/icy-tower,
   Resources/}` with `CFBundleExecutable`, a `CFBundleIdentifier`,
   `LSMinimumSystemVersion` 11.0 (the archive's deployment target and the
   strong UniformTypeIdentifiers and CoreHaptics links: section 12),
   `NSHighResolutionCapable` and `NSPrincipalClass` NSApplication. The
   executable needs no change for it: the startup policy, the static SDL3
   and the frameworks are the same inside a bundle, and LaunchServices
   activates a bundled application at launch, so the acceptance's focus
   step (section 27) is a terminal-launch matter only. A bundle generator
   for arbitrary programs is NATIVE-LINK-PLAN-MILESTONE-1.md's section 40;
   Botlish.app's own bundle (single/macos/) is the compiler's, not a
   template.
2. **The launch environment**: launched from the Finder, the program has no
   terminal (the summary line and `--help` go nowhere; a failure's report
   should also reach the user, e.g. through an SDL message box -- the
   game's choice, not the compiler's), its working directory is `/`, and
   its arguments are only what LaunchServices passes: `options.bot` refuses
   unknown options with status 2, so whether a launch passes any (old
   releases passed `-psn_...`) must be checked on the supported releases.
3. **Signing and notarization**: today the executable carries only Apple
   ld's ad hoc linker signature (`codesign -dv`: `Signature=adhoc`), which
   Gatekeeper rejects for a downloaded application. A distributable bundle
   needs a Developer ID signature with the hardened runtime and
   notarization -- MACOS-AARCH64-MILESTONE-9.md's "Prerequisites for
   Developer ID signing and notarization" applies unchanged; the game is
   ahead-of-time compiled (no JIT entitlement is needed) and links no
   third-party dylib (no library validation exception).
4. **Packaging**: a zip or DMG and a rolling release, as
   `icy-tower-windows-latest` is for Windows, with its own signing job and
   credentials (ICY-TOWER-WINDOWS.md, "Signing").
5. **Other Macs**: an x86-64 or universal build (no x86-64 macOS target
   exists), displays with a backing scale of 2 (the runner's is 1:
   section 23's checks find the scale, the game draws in logical units),
   several displays, and the weak frameworks (section 12) for a deployment
   target below 11.

## 42. Reproduction commands and exact files changed

On an Apple Silicon Mac with Apple's developer tools, CMake, git, Tcl
9.0.1 (`tests/platform/setup-macos.sh`) and this checkout (the native
backend built), exactly as `.github/workflows/icy-tower-macos.yml` runs it:

```sh
single/macos/build.sh -o dist                      # Botlish.app
(cd "$PLACE" && unzip -q "$OLDPWD/dist/botlish-macos-aarch64.zip")
ICY_TOWER_BOTLISH="$PLACE/Botlish.app" ICY_TOWER_BINDING="$PWD/out/sdl3-binding" \
  ICY_TOWER_STAGE="$TMPDIR/stage/icy tower" \
  examples/games/icy-tower/build-macos.sh out/icy-tower-macos-aarch64
out/icy-tower-macos-aarch64/icy-tower              # play: Left/A, Right/D, R, Escape
out/icy-tower-macos-aarch64/icy-tower --headless --frames 600 --seed 7
python3 audit/icy-tower/oracle.py compare out/icy-tower-macos-aarch64/icy-tower
python3 -I audit/icy-tower/tools/abi-check.py out/sdl3-binding/macos-aarch64 SDL3_SOURCE/include "$TMPDIR/abi"
ICY_TOWER_BOTLISH="$PLACE/Botlish.app" ICY_TOWER_BINDING_FROM="$PWD/out/sdl3-binding" \
  tclsh9.0 tests/workload-icy-tower.test -tmpdir "$(mktemp -d)" -match 'workload-icy-tower-macos-*'
bash audit/icy-tower/tools/traced-archive.sh ~/Library/Caches/botlish-sdl3-static/lib/libSDL3.a "$TMPDIR/traced/libSDL3.a"
ICY_TOWER_BOTLISH="$PLACE/Botlish.app" ICY_TOWER_BINDING_FROM="$PWD/out/sdl3-binding" \
  ICY_TOWER_SDL3_ARCHIVE="$TMPDIR/traced/libSDL3.a" examples/games/icy-tower/build-macos.sh out/probe
clang -fobjc-arc -framework AppKit -framework ApplicationServices -o "$TMPDIR/macos-input" audit/icy-tower/tools/macos-input.m
python3 -I audit/icy-tower/tools/macos-session.py run --exe out/icy-tower-macos-aarch64/icy-tower \
  --probe out/probe/icy-tower --worker WORKER --helper "$TMPDIR/macos-input" \
  --reference audit/icy-tower/trace-reference.txt --out out/session --strict
tclsh9.0 audit/icy-tower/mutate.tcl -macos 1 -app "$PLACE/Botlish.app" -binding out/sdl3-binding \
  -prefix ~/Library/Caches/botlish-sdl3-static -helper "$TMPDIR/macos-input"
```

(WORKER: the staged application compiled by Botlish.app without
`-native-startup`.) On Linux: `tclsh9.0 tests/workload-icy-tower.test`
(the trace reference, the ABI check against the committed binding, the
session's selftest), `python3 -I audit/icy-tower/tools/macos-session.py
selftest` and `sh audit/icy-tower/tools/trace-reference.sh EXE check`.

Files added:

| File | What |
|---|---|
| `examples/games/icy-tower/main-macos.bot` | the macOS entry |
| `examples/games/icy-tower/macos_link.bot` | the macOS executable's link plan (checked against sdl3.pc) |
| `examples/games/icy-tower/build-macos.sh` | the macOS build |
| `tests/platform/sdl3-static-macos.sh` | the pinned SDL3, static, and its link interface (shared with link-plan-sdl3.sh) |
| `audit/icy-tower/tools/abi-check.py` | the binding's C ABI against the target's headers |
| `audit/icy-tower/tools/sdl-trace.py`, `trace-reference.sh`, `audit/icy-tower/trace-reference.txt` | the trace's normalization and comparison, and the Linux reference |
| `audit/icy-tower/tools/traced-archive.sh` | the probe build's archive (link-time wrappers) |
| `audit/icy-tower/tools/macos-session.py`, `macos-input.m` | the graphical acceptance |
| `audit/icy-tower/macos-mutants.txt`, `audit/icy-tower/macos-mutate.tcl` | the port's mutants and mutate.tcl's macOS mode |
| `.github/workflows/icy-tower-macos.yml` | the macOS workflow |
| `docs/ICY-TOWER-MACOS-MILESTONE-1.md` | this report |

Files changed:

| File | What |
|---|---|
| `audit/icy-tower/context-refactor/tools/sdltrace.c` | its `SDLTRACE_LINKED` mode and the probe's `SDLTRACE_INFO` account (the LD_PRELOAD build is unchanged) |
| `audit/icy-tower/mutate.tcl` | `-macos 1` |
| `tests/platform/link-plan-sdl3.sh` | builds and reads SDL3 through sdl3-static-macos.sh |
| `tests/workload-icy-tower.test` | the macOS section; the trace-reference, ABI and selftest tests |
| `.github/workflows/icy-tower.yml` | the macOS tests' skips allowed beside the Windows ones |
| `.github/workflows/macos-arm64.yml`, `macos-graphical-main-thread.yml` | the static SDL3 cache keyed by sdl3-static-macos.sh |
| `AGENTS.md`, `docs/INDEX.md`, `docs/ICY-TOWER-VERTICAL-SLICE-1.md`, `docs/ICY-TOWER-WINDOWS.md`, `docs/MAIN-THREAD-STARTUP-MILESTONE-1.md`, `docs/NATIVE-LINK-PLAN-MILESTONE-1.md`, `docs/MACOS-AARCH64-PORT-AUDIT.md`, `compilerpedia/topics/backends.topic` | cross-references |

No file of `core/`, `hir/`, `surface/`, `compiler/`, `native/`, `stdlib/`,
`tools/` or the game's shared modules changed.
