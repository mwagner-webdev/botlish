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

PENDING: the results of the macOS runs are filled in below as
`.github/workflows/icy-tower-macos.yml` reports them.

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

PENDING (the macOS runs).

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

PENDING (run results: counts, timings, the diff against linux-x86_64).

## 6. SDL3 target and SDK evidence

PENDING (the manifest's toolchain lines and the runner's SDK).

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
the game was compiled with (the staged `.bot_modules/sdl3`). PENDING (run
results).

## 8. Binding-generator defects

PENDING (none expected to need a generator change; the run says).

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
ordinary, std::darwin::io contextualized). **Executed** on macOS: PENDING.

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
NATIVE-LINK-PLAN-MILESTONE-1.md section 7). PENDING (the run's checksum).

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

PENDING (the run's `link plan:` lines).

## 14. Main-thread startup and LC_MAIN evidence

PENDING.

## 15. Standalone Mach-O dependencies

PENDING.

## 16. Compilation with distributed Botlish.app

PENDING.

## 17. Application-root relocation

PENDING.

## 18. Headless simulation

PENDING.

## 19. Independent oracle results

PENDING.

## 20. SDL dummy-driver results

PENDING.

## 21. Cocoa window creation

PENDING.

## 22. Metal rendering

PENDING.

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
`workload-icy-tower-macos-session-selftest`). On macOS: PENDING.

## 24. Keyboard input: left and right

PENDING.

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
generator's rules: the run's final summary (round 2, floor 0, its rng and
platform count) must be `new_world(S, 2)` for an S the old game's generator
reached (the oracle walks the generator from seed 254), and the platforms
in the capture after R must be that tower's. PENDING (the run).

## 26. Window-close behavior

PENDING.

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
outside. PENDING (the run).

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
window with Metal (fixed steps, the autopilot): PENDING (the run).

The probe also writes `SDLTRACE_INFO`: SDL's video driver and renderer,
`pthread_main_np()` at each SDL call (counted: every call off the main
thread), the window's and drawable's sizes and the session's times.

## 29. Context-owned native resource lifecycle

Unchanged: `sdl::Sdl` owns the session (CONTEXT-OWNED-AFFINE-STATE-
MILESTONE-1.md); open pushes it, close pops and releases it -- scratch
memory, renderer, window, then SDL_Quit -- and every failure path releases
what it made. On macOS every one of those calls is on the main thread (the
probe's account) and in Linux's order (the trace's teardown). PENDING.

## 30. Error and exit behavior

PENDING (the macOS section of tests/workload-icy-tower.test).

## 31. GC-stress execution

PENDING.

## 32. Native stack/coroutine safety

PENDING.

## 33. Linux regressions

PENDING.

## 34. Windows regressions

PENDING.

## 35. Mutation testing

PENDING.

## 36. Fuzzing

No new fuzzer: the game's simulation space is the oracle's grid and the
golden suite's, unchanged, and the macOS-specific risk -- the binding's C
ABI -- is covered by the exact ABI check (section 7) and the call trace
(section 28) rather than by random inputs. The input cases the milestone
lists are cases of the session: both keys held (`keyboard`), release after
sustained movement and reversal (Right then Left, D then A), game over
then R (`restart`), Escape during play (`keyboard`, `restart`), the window
closed during play (`close`).

## 37. Performance and size

PENDING.

## 38. macOS CI results

PENDING.

## 39. Generated artifacts and their provenance

PENDING.

## 40. Remaining limitations

PENDING (final list).

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

PENDING.
