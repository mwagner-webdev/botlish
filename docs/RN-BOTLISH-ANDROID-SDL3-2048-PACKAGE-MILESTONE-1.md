# RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md

## A standalone Android SDL3 application written in Botlish, distributed through independent target and application packages

An implementation milestone. It builds a playable Android 2048 whose entry
program, contexts, loop, input interpretation, UI state and rendering
decisions are Botlish, started by SDL3's own Android bootstrap through the
host-startable `NAME_main` ABI (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md),
from ordinary packages: SDL3's Android view, an Android IO context, a touch
airlock over SDL3, the shared played-game rules, and an external generator
tool that turns a schema 3 application manifest into a Gradle project.

> Botlish can be the language of the application itself, with platform
> integration provided as an ordinary dependency. The compiler does not
> know which UI framework consumes the application; the Android
> integration package does not know which game it hosts; the SDL3 package
> does not know which application uses its renderer.

Material: `../integrations/android/` (the tool `botlish_android`: its C
source, templates and package), `../packages/sdl3/`, `../packages/sdlscreen/`,
`../packages/android_io/`, `../examples/games/2048/game2048_play.bot`,
`../examples/android-sdl3/` (the 2048 game and the counter),
`../audit/android-sdl3-2048/` (the Linux touch host, the build, the APK
inspection, the emulator acceptance, the oracles, the screenshot checker,
the measurements, the clean room, the mutation catalog), the tests
`../tests/android-sdl3-2048.test` and `../tests/native-library.test`'s
`nl-package-native-dir`, and the workflow
`../.github/workflows/android-sdl3-2048.yml`.

Evidence is labeled throughout:

* **observed** -- run in this milestone's container (Linux x86-64, 4 cores,
  no KVM; Tcl 9.0.1, rustc 1.100.0, the Android NDK r29 29.0.14206865, the
  Android SDK's platform 35 and build tools 35, OpenJDK 21, Gradle 8.12 and
  AGP 8.7.3 through the generated project's wrapper);
* **static** -- read from source or from an artifact's bytes;
* **CI** -- a completed workflow run on a named revision of this branch;
* **projected** -- not executed.

No Android device with an ARM processor was available. Every Android run
below is an **x86_64 emulator image executing the arm64-v8a code through
Android's native bridge** (`libndk_translation.so`): translated, never
native ARM execution.

## Contents

1. Executive result
2. Starting architecture
3. SDL3 Android distribution
4. Android IO package
5. Shared 2048 package
6. Botlish application architecture
7. Native bootstrap
8. SDL lifetime and native resource ownership
9. Pointer tagging
10. Application loop
11. Rendering
12. Touch input
13. Android lifecycle
14. Persistence
15. External generator
16. Gradle and APK
17. Artifact integrity
18. Android execution
19. 2048 interpreter oracle
20. Second application
21. Cleanroom
22. Negative tests
23. Mutation testing
24. Regression and CI
25. Performance and footprint
26. Remaining limitations
27. Next milestones

## 1. Executive result

**Implemented** (on branch `claude/magical-johnson-gz47q2`, commits
0d2f89d1, bc31909c, bbd5a750, 47a57871 and this report's):

* **SDL3's Android distribution**: `sdl3` 0.3.0's android-aarch64 view --
  the committed binding, SDL 3.4.18's libSDL3.so built from the pinned
  commit with NDK r29 (16 KiB segments), SDL's 12 Java classes, resources,
  Gradle wrapper and license, and a descriptor of every file's SHA-256;
  one release for three targets.
* **android_io** 0.1.0: `std::io::IO` over liblog.
* **sdlscreen** 0.1.0: an SDL3 airlock for touch applications (events as
  values, integer drawing, private storage), with pure gesture and layout
  modules.
* **game2048_play**: the played game's rules, extracted from the React
  Native facade, which now delegates to it with unchanged signatures and
  errors; seed 42's 401-snapshot oracle unchanged (digest fbee79e6).
* **botlish_android** 0.1.0: a protocol 1 external tool package that
  validates a schema 3 application manifest, its artifacts, the runtime
  ABI and the installed SDL3 view, then generates (and, when asked,
  builds) an SDLActivity Gradle project; generic, deterministic, inert
  when installed.
* **The 2048 application**: entry, contexts, loop, input interpretation,
  UI state, layout, rendering decisions, lifecycle policy and persistence
  in Botlish, started by SDL's own bootstrap through `NAME_main` on
  SDLThread; and a second, unrelated application (the counter) through the
  same tool.
* **Evidence infrastructure**: a Linux host shaped like SDL's Android
  bootstrap, APK inspection from bytes, emulator acceptance scripts, the
  interpreter oracle, a screenshot checker, a clean room, 23 tests, a
  35-mutant catalog, measurements, and a CI workflow running all of it.
* **Fixes found on the way**: SDL 3.4.18's Android event wait spinning a
  core (worked around in sdlscreen); SDL 3.4.18 never queueing its
  application lifecycle events (a pause and a resume are read from the
  window's Minimized and Restored instead); an Activity recreated by a
  configuration change ending SDL's process (SDL's default, kept and
  tested); Android's immersive-mode notice over a fullscreen board (the
  game is not fullscreen); a compiler defect in the native library link
  (fixed narrowly, with a regression); the package reproducibility
  workflow's failure on main; a stale test expectation; the generator
  leaving an earlier build's APK behind a failed build; and two bugs of
  the acceptance itself (the layout line parsed with sed's `\10`, which
  sent every restart tap off the screen; a race in a wait).

**Observed**: every Linux-side claim -- the packages built and audited,
the application libraries built for android-aarch64, the APKs built and
inspected, both applications under the Linux bootstrap host (taps, swipes
move by move against the interpreter, lifecycle, persistence, frames cell
by cell, GC stress, idle CPU), the generator's refusals and outputs, the
clean room from the single-file compiler, the mutation catalog (35 of 35
killed), the regression files (470 tests on each of interp and compile).

**CI** (section 18): the APKs in Android application processes on
emulator images of 4 KiB and 16 KiB pages -- **translated** arm64-v8a
code (x86_64 images, `libndk_translation`), never native ARM.

**Deferred / projected**: execution on native ARM hardware, live tagged
heap pointers in the application process (the translated process gets
untagged pointers), MTE, other ABIs, release signing.

## 2. Starting architecture

The milestone builds on three merged ones (**static**, at main b0ae98fe,
where this branch starts):

* **Host-startable application libraries**
  (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md):
  `-emit-native-library NAME -application FILE.bot` builds an ordinary
  entry program -- its contexts, its state, its loop -- as a native library
  whose `int32_t NAME_main(int argc, char **argv, NAME_error **error)` runs
  it on the calling thread in a VM made and dropped inside the call; the
  manifest is schema 3, with an `application` member.
* **The Android AArch64 target** (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md):
  the target support package `botlish_target_android_aarch64`, whose
  runtime archive is Botlish's runtime built for `aarch64-linux-android`;
  the NDK's toolchain links a library's shared object (16 KiB segments,
  `-z defs`, `-z text`).
* **Tagged pointers** (RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md):
  on android-aarch64 a C address word keeps a heap pointer's whole top
  byte (`address-word top-byte-tagged`), and a C call's byte exposure is the
  full tagged address.

The runtime ABI fingerprints this milestone's artifacts carry (**observed**,
`botlish-native runtime-abi TRIPLE`): `08043a5642fed7dc` for
`aarch64-linux-android` (address word top-byte-tagged), `3109b2adb00065a9`
for `x86_64-unknown-linux-gnu` (canonical-60) -- the values the
host-startable milestone recorded: no runtime change here.

Three things were missing for an SDL3 Android application: SDL's Android
side as a distributed package (the binding was committed, but not the
library or SDL's Java classes), a way to turn an application manifest into
an Android project, and an application whose loop is Botlish's.

## 3. SDL3 Android distribution

`sdl3` 0.3.0 (`../packages/sdl3/botlish.json`; `sdlkit` 0.3.0 relocks it)
adds an android-aarch64 target view to the linux-x86_64 and linux-aarch64
ones. One release, one artifact, every target (**static**: the package's
descriptor; **observed**: `tools/package-repository.tcl` packs it, the
release audit passes for all three targets):

| part | android-aarch64 view |
|---|---|
| binding | `generated/c/sdl3/android-aarch64/` (the NDK's clang at API 21, committed by the host-startable milestone); `sdl3/version.bot` states 3.4.18 |
| native library | `native/libSDL3.so`: SDL 3.4.18 (tag `release-3.4.18`, commit 829a65d769d935c4852f8159e964312c0957260a) built by SDL's CMake with the NDK r29 for arm64-v8a, API 21, `llvm-strip --strip-unneeded`; SONAME libSDL3.so; 16 KiB LOAD segments; sha256 034b5892b1fd633f... |
| loader dependencies | libm, libOpenSLES, libdl, liblog, libandroid, libGLESv1_CM, libGLESv2, libc -- all Android platform libraries (`pm/target.tcl` gains libGLESv1_CM.so) |
| Java | the 12 classes of SDL's `android-project/app/src/main/java/org/libsdl/app/` |
| project files | the launcher icons and value resources, the Gradle wrapper jar and `gradlew`, SDL's LICENSE.txt and proguard rules |
| descriptor | `android/sdl3-android.json` (schema 1, kind `botlish-sdl3-android`): SDL's version, tag and commit, the minimum API, and every file's path and SHA-256 |

The binding profile (`tools/c-bindgen/profiles/sdl3.tcl`) now states
`modules always`: SDL_dlopennote.h's module (`sdl3/dlopennote.bot`), which
the Linux bindings had and the Android binding lacked, exists on every
target, because the release audit refuses a package whose targets offer
different modules. The Android binding was regenerated with it (one new
module), and the Linux manifests' profile digests changed accordingly.

The author's recipe (`tools/package-repository.tcl`'s `author::sdl3Android`,
`author::strip`) builds the library from the pinned source with the NDK
named by `ANDROID_NDK_ROOT`; the pinned author image
(`tools/package-build/Dockerfile`) installs NDK r29 by its SHA-256. A
consumer installs the artifact and compiles nothing of SDL's.

## 4. Android IO package

`android_io` 0.1.0 (`../packages/android_io/`) is `std::io::IO` over
Android's log: the opaque context `AndroidIO` (an output priority, an error
priority, a tag), `create()` (tag "Botlish") and `create_tagged(TAG)`. Each
write is one `__android_log_write` call (liblog, a platform library: never
bundled), output at ANDROID_LOG_INFO and error output at ANDROID_LOG_ERROR.
The tag and the text are Botlish byte storage lent to the call
(`read noescape`): nothing is copied to native memory or kept by C. The
extern is `private`; the module mediates its one C call through its own
context, so its importers need no `direct module`.

Evidence: `as-android-io` (**observed**) builds an application whose only
platform package is android_io for android-aarch64 -- its manifest states
liblog as its one native dependency, its shared object needs liblog.so and
no SDL, and imports `__android_log_write`. At run time every protocol line
both applications print reaches logcat through it: the acceptance reads
nothing else (**CI**, section 18).

## 5. Shared 2048 package

`game2048_play` (`../examples/games/2048/game2048_play.bot`, packed beside
`game2048` by `../audit/android-aarch64-target/tools/package.sh`) holds the
played game the React Native facade used to implement: a game between moves
(`Played`: the engine's game, a 32-bit linear congruential generator's
state, the number of changing moves, whether the last move changed the
board), `start(seed)`, `moved(p, d)` (a move that changes the board scores
its merges and spawns one tile; one that does not changes nothing but
`changed`), `placed`, `won?`, `over?`, `cells_of`, and the versioned
snapshot text `2048/1 RNG SCORE MOVES CHANGED OVER WON C0 ... C15`, which
`played(text)` reads only after checking it is a game's (23 fields, the
generator's range, flags that are the board's facts, cells that are tiles:
`InvalidSnapshot` otherwise).

The facade (`../examples/react-native/2048/game.bot`) keeps its exports'
signatures and declared errors exactly and delegates each to game2048_play,
translating the package's errors into its own (`on
game2048_play::InvalidSnapshot: fail InvalidSnapshot`). Evidence:

* the seed-42 self-test oracle -- 401 snapshots, digest `fbee79e6` -- is
  byte-identical before and after the extraction on interp, compile and
  cranelift (**observed**), and `as-play-oracle` compares game2048_play's
  own oracle with the facade's on every run;
* `as-play-single-source` (**static**): neither the facade nor any module
  of the SDL3 game names a member of the engine but its `Direction` type
  and `CellOccupied` error -- no spawn, move or game-over check of its own;
* `as-play-snapshot` (**observed**): a game restored from its snapshot
  halfway plays on exactly as the uninterrupted one (the generator's state
  included), and seven kinds of tampered snapshot are refused;
* the React Native workflow on the extraction's revision: section 24.

## 6. Botlish application architecture

The 2048 application is `../examples/android-sdl3/2048/`, six modules:

| module | role | SDL? |
|---|---|---|
| `main.bot` | the Android entry: `with context android_io::create_tagged("Botlish2048")`, `with context sdlscreen::create()`, `app::main()` | installs the context |
| `main-linux.bot` | the same with `std::linux::io` (the Linux host's) | installs the context |
| `app.bot` | the state, the loop, the lifecycle policy, persistence | through sdlscreen |
| `board.bot` | the layout from the drawable size and safe area; the frame as data (`Draw::Fill`, `Draw::Text`) | no |
| `input.bot` | a gesture's meaning: a move, a restart, nothing | no |
| `render.bot` | draws a frame board.bot decided, then presents it | through sdlscreen |

`sdlscreen` (`../packages/sdlscreen/`) is the airlock, in the shape Icy
Tower's `sdl.bot` established: the opaque context `Screen` owns the open
session (the window, the renderer and scratch memory as affine pointers in
a private record); an application gets values -- `Event` (a payload enum:
finger down, motion, up, cancelled; the lifecycle events; resize; render
reset; back; quit; idle), `Size`, `Area`, a file's text -- and draws with
integers (`color`, `fill`, `text` in SDL's 8x8 debug font, `present`).
Every function that takes or returns a pointer or a native view is
`private`. Its two pure modules, `sdlscreen::gesture` (one gesture per
finger: a tap or a swipe) and `sdlscreen::layout` (integer rectangles), run
on every backend.

`android_io` and `sdlscreen` are installed contexts the entry program
supplies; the application modules require them as context parameters. No
module of the application names a C function, and the generated native
host names none of the application's (section 7).

## 7. Native bootstrap

The generated project starts the program with SDL's own machinery, unchanged
(**static**: the templates; **CI**: the logs of section 18):

1. Android starts the generated `MainActivity`, a subclass of SDL's
   `SDLActivity` whose `getLibraries()` is `{"SDL3", "NAME", "main"}`:
   SDLActivity's `onCreate` loads libSDL3.so, the Botlish application
   library and `libmain.so`, in that order (`SDL.loadLibrary`, which calls
   `System.loadLibrary`).
2. SDLActivity starts its thread `SDLThread` (`SDLMain` in SDL's Java),
   which calls `nativeRunMain` and SDL's `SDL_RunApp`, which looks up and
   calls `SDL_main` in libmain.so.
3. `SDL_main` (`../integrations/android/templates/main.c.in`) logs the
   environment once (the API level, and the top byte of a fresh `malloc`
   pointer: whether Bionic tags heap pointers), pins the application library
   (`dlopen(..., RTLD_NOLOAD | RTLD_NODELETE)` on API 23+, so the runtime's
   per-thread state can never outlive its code), then calls
   `NAME_main(argc, argv, &error)` once and returns 0, or logs the owned
   error, releases it and returns 1.
4. `NAME_main` makes the VM on SDLThread, runs module initialization and the
   entry program: the program installs its contexts, opens SDL, loops, closes
   SDL and returns; the VM is dropped on SDLThread before `NAME_main`
   returns. When `SDL_main` returns, SDLActivity finishes the Activity.

`libmain.so` is built by the project's CMake from that one C file, linked
against the imported application library and libSDL3.so (`-z defs`,
16 KiB pages). It holds no application logic, installs no context, keeps no
handle and calls no SDL function: `as-tool-shim` checks the generated file
(one call of `NAME_main`, none of `NAME_create`, no thread, no `exit` or
`abort`, no SDL call, no `dlclose`, `RTLD_NODELETE`, no masking of a
pointer, nothing that disables heap pointer tagging).

With the test configuration (`android generate -intent-arguments`) the
Activity also passes its launching intent's string array extra
`org.botlish.android.ARGUMENTS` as the program's arguments
(`getArguments`), which the acceptance uses for `--seed 42 --fresh`; the
production configuration passes none.

## 8. SDL lifetime and native resource ownership

`sdlscreen::open` (**static**) sets the hints (one: `SDL_HINT_ANDROID_BLOCK_ON_PAUSE`
"0", `nonblocking_pause()`), calls `SDL_Init(SDL_INIT_VIDEO)`, disables the
poll sentinel (section 10), creates the window (`SDL_WINDOW_FULLSCREEN` when
asked) and the renderer, turns vertical sync on when asked, and keeps the
window, the renderer and its scratch memory in the context. Every failure releases what was made, in reverse
order, and fails `ScreenFailed {call, reason}` with SDL's error text, read
before anything is released. `sdlscreen::close` destroys the renderer, then
the window, frees the scratch memory, then calls `SDL_Quit`; closing a
closed screen does nothing. `as-sdlscreen-teardown` checks that order and
that nothing is destroyed after an `SDL_Quit` in any block of the module.

The application's order (`app::main`): open SDL, read the saved game, run
the loop, save, close, return. The application library is never unloaded
while SDLThread runs: Android never unloads a library loaded with
`System.loadLibrary`, and the shim pins it besides (**static**; on API 34
the log line "libNAME.so pinned yes": **CI**).

Ownership: the window, renderer and scratch buffers are affine
`std::ffi::c::Ptr`s owned by the installed context (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md);
the byte exposures of a call (a hint's text, a file path, the save's data)
are made by the call itself and kept alive across it
(C-POINTER-BORROWING.md). sdlscreen holds no global state and no process-wide
handle.

## 9. Pointer tagging

Nothing in the application, the packages, the generator or the generated
project touches heap pointer tagging (**static**: `as-tool-shim` finds no
`allowNativeHeapPointerTagging`, `mallopt`, `M_BIONIC*` or heap-tagging
name in any generated file, and no masking of a pointer in the shim). The
window, the renderer and sdlscreen's scratch buffers are `std::ffi::c::Ptr`
values: on android-aarch64 each is the runtime's top-byte-tagged address
word, which carries a heap pointer's tag through Botlish unchanged
(RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md); the byte exposures
-- a hint's text, a file path, a save's bytes, the tag and text android_io
lends liblog -- are made by the C call itself, at the full tagged address.

What the emulators showed (**CI**): the shim's probe logs
`heap-pointer-tag 0x00` on every image (API 34, 35): a process whose
arm64-v8a code is translated by `libndk_translation` gets untagged heap
pointers from Bionic, so tagging was **not exercised live** by this APK.
The tagged path rests on the previous milestone's execution under
qemu-user with Android's own arm64-v8a userspace, which observed tagged
pointers on API 30 and later through SDL3's own objects (`at-tagged-sdl3`)
-- with the same SDL3 build this package ships (the package's libSDL3.so is
that build stripped) -- and on the runtime ABI fingerprint, unchanged
(section 2).

## 10. Application loop

`app::run` (**static**): draw when something changed and the application is
visible, then `sdlscreen::wait(timeout)` -- at most a second while visible,
indefinitely while hidden -- and `react` to the one event. Every event is
read on SDLThread, by the Botlish program: touch events Android produces on
its UI thread reach the program through SDL's queue only. The state
(`State`: the game, the gesture tracker, the layout, visibility,
whether a redraw is due, frames drawn, the save's path and the last text
saved) is an immutable value threaded through the loop.

An idle board costs no CPU, and the first emulator run found that this was
not so. On the API 34 image the counter's SDLThread used 428 of 500 clock
ticks in five idle seconds in the foreground (0 in the background)
(**CI**, run 43737218437 at bc31909c). The cause is SDL 3.4.18's Android
event wait (`SDL_WaitEventTimeoutNS`, src/events/SDL_events.c, **static**):
each round pumps -- which pushes a fresh poll sentinel -- and every
pushed event posts a lifecycle wakeup (`SDL_SendWakeupEvent`,
`Android_SendLifecycleEvent(SDL_ANDROID_LIFECYCLE_WAKE)`), which the
round's own `Android_PumpEvents(delay)` then takes at once, so the wait
spins until its timeout. Paused, `GetLifecycleEventTimeout` turns that
loop's zero timeouts into 100 ms waits, which is why the background
measured 0. `sdlscreen::open` disables the poll sentinel
(`SDL_SetEventEnabled(SDL_EVENT_POLL_SENTINEL, false)`): nothing in
sdlscreen reads poll cycles, and with no self-posted wakeup the wait sleeps
until a real event (a touch, a lifecycle change) wakes it. The result on the
emulators after the change: section 18.

`as-2048-lifecycle` (**observed**) measures SDLThread's CPU with the Linux
host over 1.5 idle seconds and requires under a tenth of the wall time;
`loop-busy-spins` (a timeout of 0) is the mutant it kills.

## 11. Rendering

`board.bot` (**static**, pure) decides everything shown, as data: `layout`
computes, from the drawable size and SDL's safe area alone, a square board
inside the safe area with a margin of a 24th of the smaller side, a header
of a sixth of it split into the score box and the restart button ("NEW"),
a message line under the board, sixteen cells with a gap of a 40th of the
board (at least 2 px); `frame` lists the draws -- the background, the score
box and "SCORE N", the restart button, the board, each tile in the classic
palette with its number centered and fitted, and the message ("SWIPE TO
MOVE", "YOU WIN! KEEP GOING" when game2048_play's `won?` holds, "GAME OVER -
TAP NEW" when its `over?` does). `render.bot` paints each draw through
sdlscreen and presents the frame; it decides nothing. Text is SDL's 8x8
debug font (`SDL_RenderDebugText`) scaled by integers: ASCII, legible at
the scales the layout chooses.

The layout is recomputed whenever the drawable size or the renderer may
have changed (Resized, RenderReset, Restored), never hard-coded
to a resolution (`as-layout`: a phone, a tablet, landscape and a 120x160
screen; the mutant `geometry-hardcoded` fails it).

Checking a frame is the game it holds (`../audit/android-sdl3-2048/tools/screen.py`):
the application prints its layout ("2048: layout WxH board X Y SIDE gap G
restart ..."); the checker locates the sixteen cells from it and samples
each an eighth into the cell (away from its number), requiring the color
of the tile the snapshot holds there -- an independent statement of the
palette, not the application's code. `as-2048-frames` (**observed**)
applies it to the frames SDL's offscreen driver saves under the Linux host:
the first frame shows the new game, the last the last move's board, and the
first frame checked against the last state fails (the checker can fail).
On the emulators the same checker reads `screencap` screenshots (section
18).

## 12. Touch input

`sdlscreen::gesture` (**static**, pure) turns SDL's finger events into at
most one gesture per finger: a finger lifted after moving less than the
threshold on both axes is a tap at its start, otherwise a swipe toward its
larger movement (a tie horizontal); nothing while a finger is down; a
second finger cancels the gesture until its own finger is up; an
`SDL_EVENT_FINGER_CANCELED` (the system took the touch) or a reset (the
background, a lost surface) drops it; another finger's up is ignored.
Coordinates are SDL's normalized finger positions scaled to the drawable
size. `input.bot` maps a gesture to an action: a swipe to a move of its
direction, a tap on the restart button to a restart, any other tap to
nothing; the threshold is a twelfth of the board's side (at least 8 px).

Evidence (**observed**): `as-gesture-classify`, `as-gesture-exactly-once`
and `as-input` on the interpreter; under the Linux host, every swipe of
`as-2048-host` produces exactly one move whose snapshot is the
interpreter's, and the counter counts a tap once, a swipe, a two-finger
gesture and a cancelled finger not at all (`as-counter-host`). On the
emulators, `input swipe` and `input tap` through Android's real input
pipeline (section 18).

## 13. Android lifecycle

`SDL_HINT_ANDROID_BLOCK_ON_PAUSE` is "0", so the loop sees each lifecycle
event when it happens instead of SDL blocking inside the pump.

What reaches the queue is SDL's decision, and SDL 3.4.18 queues less than
its event names suggest (**static**, SDL's source; **observed** on the
emulators, section 18). Android's `onPause` makes SDL call
`SDL_OnApplicationWillEnterBackground` and `..DidEnterBackground`, `onResume`
the two foreground ones (`SDL_androidevents.c`); those send every window an
`SDL_EVENT_WINDOW_MINIMIZED` (on the pause) or `SDL_EVENT_WINDOW_RESTORED`
(on the resume), which are queued, and the application events
`SDL_EVENT_WILL_ENTER_BACKGROUND` .. `SDL_EVENT_DID_ENTER_FOREGROUND`,
`SDL_EVENT_TERMINATING` and `SDL_EVENT_LOW_MEMORY` through
`SDL_SendAppEvent`, which hands them to event watchers and never queues them
("it needs to be handled in this call stack by an event watcher"). A watcher
would be a retained C callback, which Botlish does not have (C-CALLBACK-
MILESTONE-1.md: synchronous callbacks only). So a program that reads the
queue -- every Botlish program -- learns of a pause from `Minimized`, of a
resume from `Restored`, and of the Activity's destruction from
`SDL_EVENT_QUIT` (`Android_OnDestroy` sends both TERMINATING and QUIT; only
QUIT is queued); a low-memory notice never reaches it. The first emulator
runs found this: the application reacted to the application events alone
and logged no pause (run 4, section 18). sdlscreen now decodes `Minimized`
and `Restored` and documents the rest; the applications react to them; the
Linux touch host's `background` and `foreground` call SDL's own
`SDL_OnApplication*` functions, so SDL decides what the queue gets there
too.

The policy (`app::react`, **static**):

| event | the application |
|---|---|
| Minimized (Android's pause) | drops the gesture in progress, saves the game, stops drawing (the surface may go) |
| Restored (the resume) | draws again, measuring the layout again |
| Resized, RenderReset | measures the layout again and redraws (only while visible) |
| LowMemory (only if pushed) | saves the game |
| Quit, Terminating (only if pushed) | saves, ends the loop; SDL is closed and the entry returns |
| Back (SDLK_AC_BACK, which SDL3 leaves to the program) | the same: the program returns, and SDLActivity finishes the Activity |
| the application events | nothing (never queued by SDL 3.4.18; if a later SDL queued them as well, the window's events would still say it once) |

The generated manifest keeps SDL's `configChanges` (rotation and resizing
are resizes of the running Activity, never a new one) and `launchMode
singleInstance`. A configuration change outside that list -- the display's
density, the SIM's mcc and mnc -- recreates the Activity, and SDL 3.4.18's
contract for that is its default: the old Activity's `onDestroy` queues
Quit and waits for `SDL_main`; the program saves and returns
(`game_main` returns 0); the new Activity's `onCreate` finds SDL's main
finished and, recreation not allowed (`SDL_HINT_ANDROID_ALLOW_RECREATE_
ACTIVITY` unset), ends the process ("activity finished", `System.exit(0)`).
The next launch is a new process, which restores the saved game. The
application keeps that default: allowing recreation would need the hint to
survive `SDL_Quit` (which resets hints) and a second `SDL_main` in one
process, which this milestone does not design.

Evidence (**observed**, Linux host): `as-2048-host` (the pause and the
resume, through SDL's own functions, in the middle of a game, the snapshots
unchanged), `as-2048-lifecycle` (nothing drawn while hidden, a render reset
and a resize then included; drawn again in the foreground), `as-2048-
terminate` (Quit, and Quit then Terminating, each save and return 0). On
Android: section 18.

## 14. Persistence

One file, `game.txt`, in SDL's private storage (`SDL_GetPrefPath("Botlish",
"2048")`: the app's internal files directory on Android), holding the
game's snapshot text. `sdlscreen::save` writes `game.txt.tmp` and renames it
over `game.txt` (`SDL_SaveFile`, `SDL_RenamePath`), so an interrupted save
leaves the previous game whole. The application saves after every change
(a move, a restart) and on the pause (Minimized), LowMemory, Quit,
Terminating and Back, writing only when the text changed since its last
save. At start it reads the file and asks game2048_play to validate it: an
invalid, foreign-version or empty save is a fresh game, never a failure
("2048: invalid save ignored"); `--fresh` ignores the save.

Evidence (**observed**): `as-2048-restore` -- a later start restores the
saved game exactly; `--fresh` ignores it; garbage, version `2049/1`, an empty
file and a board whose won flag is not its fact each start a fresh game with
status 0; a stray `game.txt.tmp` beside a good save leaves the good save in
force. `as-play-snapshot`: a restored game plays on exactly as the
uninterrupted one. On Android (section 18): the process killed with `am
force-stop` restores; boards one move from the win and from the end,
written into the app's storage, are played.

## 15. External generator

`botlish_android` 0.1.0 (`../integrations/android/`) is an external tool
package (schema 4, `tools.android`, protocol 1, a linux-x86_64 program,
input kind `native-library`, environment `ANDROID_HOME`), packed by
`../integrations/android/package.sh`: a C99 program (`src/main.c`, its JSON
reader, ELF reader and SHA-256) whose templates are compiled in
(`src/embed.c` turns `templates/*.in` into `templates.h`). Installing it
copies an inert file (`as-tool-not-run-by-install`: no execute bit;
`botlish tools` lists it without running it); only `botlish tool ...
android COMMAND` runs it, and then from a private copy (pm/tools.tcl).

Commands:

* `android generate [-application-id ID] [-name TEXT] [-activity CLASS]
  [-android-api N] [-version-code N] [-version-name TEXT] [-packaging
  uncompressed|extracted] [-assets DIR] [-sdl3 PACKAGE]
  [-intent-arguments] [-replace]` writes the project into the request's
  output directory;
* `android build [-task assembleRelease|assembleDebug]` runs that
  project's Gradle wrapper (default `assembleRelease`) with the SDK
  `ANDROID_HOME` names, refusing a directory it did not generate
  (AN-OUTPUT) or a missing SDK (AN-TOOLCHAIN).

Inputs, all read before anything is written (**static**: src/main.c;
`as-tool-reads` traces a generation with strace and finds nothing else
opened): the protocol request (`BOTLISH_TOOL_REQUEST`), the application
library's manifest and its three files, the installed SDL3 package's
android-aarch64 view (its descriptor, every file it states, its binding's
`version.bot`), and the output directory. No Botlish source, no compiler
file, no network, no program run by `generate`.

Genericity: the tool knows no application. Its source and templates hold no
word of 2048 (`as-tool-generate` greps them), its defaults derive from the
library's name (`org.botlish.NAME`, display name NAME), and the same program
generates the counter (section 20) and the game. Determinism: generating
twice gives the same bytes (`as-tool-generate`; build.sh regenerates the
counter's project and compares every file). Output safety: a directory
inside `.bot_modules`, a non-empty directory the tool did not make, and its
own project without `-replace` are refused and left as they were;
`-replace` removes exactly the files of its record (`as-tool-output`).

## 16. Gradle and APK

The generated project (37 files for the game, **observed**): `settings.gradle`,
`build.gradle` (AGP 8.7.3), `gradle.properties`, the wrapper
(`gradle-wrapper.properties` pins Gradle 8.12's distribution by its
SHA-256 7a00d51f...; the jar and `gradlew` are SDL's), `app/build.gradle`
(namespace and application ID, compileSdk and targetSdk 35, minSdk 21,
`ndkVersion "29.0.14206865"`, `abiFilters 'arm64-v8a'` for the build and the
packaging, `externalNativeBuild` CMake 3.22.1, `jniLibs.srcDirs` the
imported libraries, `useLegacyPackaging false`, release signed with the
debug key: a test APK), `AndroidManifest.xml` (SDL's template:
`configChanges` covering rotation and resizing, `launchMode
singleInstance`, no attribute on heap pointer tagging), `MainActivity.java`,
SDL's 12 Java classes and resources, `app/src/main/cpp/{main.c,
CMakeLists.txt, NAME.h}`, `app/src/main/botlish/arm64-v8a/{libNAME.so,
libSDL3.so}`, `README.md`, `LICENSES/SDL.txt`, `app/proguard-rules.pro` and
the record `botlish-android.json` (the generator's version, the library's
name, entry, manifest and shared object digests, runtime ABI and target
support package; the SDL3 package, SDL's version, commit and library digest;
the Android settings; the file list).

CMake re-checks both imported libraries' SHA-256 against the record before
linking `libmain.so`, and refuses another ABI or a lower API level.

Commands (**observed**, and in CI's build job):

```bash
botlish tool -out OUT/android/game -artifact lib/game.manifest.json -target android-aarch64 \
    android generate -application-id org.botlish.sdl2048 -name "Botlish 2048"
botlish tool -out OUT/android/game -artifact lib/game.manifest.json -target android-aarch64 \
    android build
```

What the APK holds (`../audit/android-sdl3-2048/tools/inspect-apk.sh`, read
from its bytes: aapt2, dexdump, unzip, llvm-readelf; **observed** for every
APK of build.sh and the clean room): package and launchable Activity,
minSdk 21, targetSdk 35; native code arm64-v8a only; exactly
`lib/arm64-v8a/{libSDL3.so, libNAME.so, libmain.so}`, each stored
uncompressed at a 16 KiB-aligned offset (`zipalign -c -P 16`), each ELF
AArch64 with every LOAD segment 16 KiB-aligned; libmain.so needing
libNAME.so and libSDL3.so and defining `SDL_main`; libNAME.so being the
manifest's library as the Android build strips it (`llvm-strip
--strip-unneeded` of the manifest's file, byte for byte) and libSDL3.so the
package's, byte for byte; classes.dex holding `org.libsdl.app.SDLActivity`
and the generated Activity.

## 17. Artifact integrity

The tool refuses, before writing anything (each a status, an `AN-` code and
an empty output directory: `as-tool-refusals`, **observed**):

| input | refusal |
|---|---|
| an ordinary library (schema 2, no entry) | AN-NOT-APPLICATION |
| another target than the request's | AN-TARGET |
| a stale shared object or header (digest not the manifest's) | AN-ARTIFACT |
| an entry that is not `NAME_main` | AN-ENTRY |
| a runtime ABI other than the target support package's | AN-RUNTIME-ABI |
| an undeclared native dependency (`-lssl`) | AN-DEPENDENCY |
| no SDL3 package for android-aarch64 | AN-SDL3 |
| Linux's libSDL3.so in the package (digest stated, then refused by its ELF) | AN-SDL3, AN-ELF |
| a binding of another SDL (`SDL_VERSION` 3004017) | AN-SDL3 |
| a changed Java class of SDL's | AN-SDL3 |
| a shared object with 4 KiB segments (digest updated) | AN-ELF |
| a shared object of another machine (x86-64's e_machine, digest updated) | AN-ELF |
| invalid application IDs, a Java keyword, a shell character, a control character in the name, an Activity named like SDL's | AN-NAME |
| an unknown command; an API level below the floor | AN-USAGE |
| an API level above the compile SDK | AN-ANDROID-API |
| an asset that is a link, a hidden asset | AN-ASSETS |

The record and CMake carry the digests on into the build (section 16), and
the APK inspection closes the chain: the library in the APK is the
manifest's.

## 18. Android execution

Evidence class: **CI**, translated. The workflow `android sdl3 2048`
(`../.github/workflows/android-sdl3-2048.yml`) builds everything from the
checkout on one runner -- `build.sh` (the packages, both applications, the
APKs, their inspection, the interpreter's oracles) and the clean room --
then two emulator jobs install and play the APKs: one image of 4 KiB pages
(API 34, `google_apis` x86_64: the first of the job's images that runs
arm64-v8a code) and one of 16 KiB pages (API 35, `google_apis_ps16k`
x86_64). Both are x86_64 images: the arm64-v8a code runs through Android's
native bridge (`ro.dalvik.vm.native.bridge` is `libndk_translation.so`,
and it is mapped in the application process). Every result below is
**translated execution, not native ARM**. `adb root` works on both images
(the process's maps and the app's storage are readable).

Each emulator job runs, after the device has settled (boot completed, the
SIM's state final, ten quiet seconds: `lib.sh`'s `settle`):

1. `acceptance-counter.sh` with the counter's APK;
2. `acceptance-2048.sh` with build.sh's `game-test.apk` (the test
   configuration: its launching intent's arguments, `--seed 42 --fresh`,
   are the program's);
3. `acceptance-2048.sh` again with the clean room's `game-test.apk`.

### What the runs found

The first runs were findings more than verdicts; each changed the code or
the harness, never an expectation:

* Run 1 (43733678933, at 0d2f89d1): the counter alone (the 2048 game did
  not exist yet); its acceptance failed on both images.
* Run 2 (43737218437, at bc31909c): the foreground idle spin of SDL's
  Android wait (section 10): 428 of 500 ticks; under the native bridge
  the libraries are mapped from base.apk, not as files (the check reads
  the APK's entry offsets since).
* Run 3 (43739295620, at bbd5a750): its build job and clean room passed;
  its emulator jobs were still waiting for runners when the next push
  cancelled them.
* Run 4 (43742636396, at 47a57871), the 4 KiB image: the 2048 game passed
  its start, seed 42's game, SDLThread, the three libraries mapped from
  base.apk, every screenshot (16 of 16 cells, four times), 24 swipes in
  three phases each applied once and each snapshot the interpreter's, a
  short gesture ignored, the hidden and the idle foreground program using
  0 ticks, the win and the game-over boards, the back key's clean exit and
  no crash. It failed four things, each a finding:
  - no `2048: background` or `foreground` line: SDL 3.4.18 never queues
    its application lifecycle events (section 13);
  - the restart button's tap never reached the program: `InputDispatcher:
    Not sending touch gesture to ... ActivityRecordInputSink ... because
    it has config NO_INPUT_CHANNEL`. I read it then as the top edge of a
    fullscreen window belonging to the system; run 7 showed the real cause,
    a bug of the harness (below);
  - "don't keep activities" set from the shell (`settings put global
    always_finish_activities 1`) destroyed nothing;
  - the counter's first start ended half a second after it began, on both
    images: the emulator's SIM came up (`CARRIER_CONFIG_CHANGED`), the
    configuration's mcc and mnc changed, Android recreated the Activity,
    and SDL's `onCreate` logged "activity finished" and called
    `System.exit(0)` -- on the 16 KiB image before the program had a
    renderer (`counter: failed SDL_CreateRenderer: Android activity has
    been destroyed`; the program reported it and returned).
* Run 4, the 16 KiB image: Android's immersive-mode notice ("Viewing full
  screen -- To exit, swipe down from the top of your screen -- Got it")
  covered the fullscreen board for the whole run, so every screenshot
  check and most swipes failed there; the low-memory killer ended 67
  processes during the 2048 run.

Commits 609ce6b0 and 112dc0a4 answer them: sdlscreen decodes the window's
Minimized and Restored, and the applications react to those (section 13);
the game is not fullscreen (the immersive-mode notice); the acceptance waits for the device to settle,
starts once more if SDL ended the process for a recreation anyway, and
tests recreation by a density change, which SDLActivity does not handle,
expecting SDL's documented default (the program saves and returns, SDL ends
the process, the next launch restores the game).

* Run 6 (43748600810, at 112dc0a4), the 16 KiB image: the counter passed
  every check (one start after the settle, no recreation), and the 2048
  game passed every check -- the pause and the resume seen, the density
  recreation as SDL's contract has it, the restore, the win and game-over
  boards, every screenshot, both APKs (build.sh's and the clean room's)
  -- but the restart button: its tap, after a background and a
  foreground, went to `ActivityRecordInputSink` again (no application
  window took it), although the screenshot taken after the foreground's
  swipes, ten seconds earlier, shows the button where the layout says. The 4 KiB job was still waiting for a
  runner when the next push cancelled it. Commit 7235327a taps the button
  once more right after the first start, in a fresh process, and records
  `dumpsys input` and the window state before each restart tap.
* Run 7 (43753654899, at 7235327a), the 4 KiB image: the tap failed in a
  fresh process too, and the capture explained it. `dumpsys input` held
  the application's window touchable over the whole screen, nothing above
  it but the 24-pixel status bar -- and the launcher's gesture monitor
  logged the tap at `y=1637.0`, below the 640-pixel screen. The acceptance
  parsed the layout line with one `sed` of ten groups; sed numbers its
  groups `\1` to `\9`, so `\10` is group 1 followed by a 0, the button's
  height read as 3200, and every restart tap of runs 4, 6 and 7 went to
  y = 13 + 1600 + 24. No window holds that point but the activity's input
  sink, which takes every touch inside its task's bounds that no window
  of the activity takes. Commit e44f8760 reads the line by words. The same
  run found a race of my own early end of a wait (commit a1256dd1: a line
  that arrived between the count and SDL's "activity finished" was not
  counted, though the kept log held it).

### The final run

Run 9 (43760740709, at a1256dd1): **pending** -- queued for a runner when
this was written.

## 19. 2048 interpreter oracle

`../audit/android-sdl3-2048/tools/oracle.tcl SEED DIRECTIONS` prints the
snapshots the Botlish **interpreter** computes with game2048_play for a seed
and a sequence of moves (the new game's, then one per move);
`-from SNAPSHOT` starts from a checked snapshot instead. `oracles.sh` makes
the acceptance's expectations: seed 42 and the 24 swipes it plays
(`013201320231023102130213`: twelve, a burst of eight, four after the
background), a board one move (left) from 2048, a board one move (right)
from the end, and the React Native self-test's 401 snapshots.

The application prints `2048: new S`, `2048: move D S` and `2048: restart S`
lines; every comparison is of those texts with the interpreter's, exactly:

* the self-test's oracle from game2048_play equals the facade's
  (`as-play-oracle`, **observed**: 401 snapshots, digest fbee79e6);
* under the Linux host, seed 42's new game and all 16 snapshots of
  `as-2048-host` equal the interpreter's, also under
  `BOTLISH_NATIVE_GC_STRESS=1` (`as-gc-stress`) (**observed**);
* on the emulators, seed 42's new game, all 24 swipes' snapshots, and the
  win and game-over boards' moves (section 18, **CI**).

The native application library and the interpreter agree move by move
because the rules have one source (section 5) and one compiler; the
oracle is the interpreter's, not the application's.

## 20. Second application

`../examples/android-sdl3/counter/` is an unrelated SDL3 application built
through the same packages and the same tool: a rectangle whose color
changes with each tap and the count of taps (a swipe or a two-finger
gesture counts nothing), with its own names (library `counter`, application ID
`org.botlish.counter`, display name "Botlish Counter"), no game2048 and no
board. It was the milestone's first integration gate (initialize SDL3,
create a window and renderer, draw, exit) before any game code.

Evidence that the generator holds no 2048 assumption: its source and
templates hold no word of the game, and the counter's generated project
holds none either (`as-tool-generate`, **observed**); the counter's APK
passes the same inspection (**observed**); it runs in an Android
application process on both emulators (**CI**, section 18); and under the
Linux host it counts each tap once, ignores swipes, two-finger gestures and
a cancelled finger, survives the background and ends on the back key
(`as-counter-host`, **observed**).

## 21. Cleanroom

`../audit/android-sdl3-2048/cleanroom/cleanroom.sh BOTLISH REPO RESULTS`
reproduces the APK from the distributed single-file compiler
(`single/build.sh`'s `single/out/botlish`) and the published artifacts
only. The room is a fresh directory holding a copy of the compiler, the
seven `.botpkg` files and the application's Botlish sources (the Linux
entry left out), nothing of the checkout besides:

1. **Botlish, traced** (an empty environment: HOME, TMPDIR and the caches in
   the room, PATH `/usr/bin:/bin`, ANDROID_NDK_ROOT and ANDROID_HOME;
   strace of `execve`, `open`, `openat`, `stat`, `newfstatat`, `access`):
   `botlish add` of sdlscreen, android_io, game2048, game2048_play and the
   target support package for android-aarch64 and of botlish_android;
   `botlish tools`; the application library built with `-warnings error`;
   each of its files checked against its manifest's SHA-256; the tool run
   explicitly (`botlish tool ... android generate`).
2. **Gradle**: the tool's `android build` (the generated wrapper downloads
   Gradle 8.12 and AGP from Google's Maven: the project's, not Botlish's).
3. **The APK**: inspect-apk.sh's facts.
4. **The acceptance's configuration**: the same library generated again
   with `-intent-arguments`, built and inspected -> `game-test.apk`, which
   the CI's emulator jobs then play (section 18).

Results (**observed**, this container, at 112dc0a4's sources; single
executable sha256 d4e06eda91f6c29a..., 16,126,100 bytes -- built before
the last commits, none of which changes what it packs):

```
ok the Botlish steps touched nothing of this checkout
ok no Tcl of the system: the compiler is the single file
  manifest: libgame.a 690a4fc2b8032b0e...
  manifest: libgame.so f19794259f330e8c...
  manifest: game.h 385e328a6e9cd182...
  manifest: an application library (schema 3)
  android: generated .../out/android (37 files): org.botlish.sdl2048 for game, SDL 3.4.18, minimum API 21
ok the tool wrote the project
ok the tool's Gradle build (BUILD SUCCESSFUL in 1m 3s)
ok the generated project names nothing of this checkout
apk 3470668 bytes sha256 03ce2973a631b611...
ok the APK's facts (12 checked)
ok the acceptance's configuration: game-test.apk (12 facts)
result: passed
```

The programs the traced steps started: the single executable (9 times),
its own extracted driver (in the room's cache), the NDK's clang, ld.lld,
llvm-ar and llvm-objcopy (the library's link), `sha256sum`, `tr`, `sed`,
`cut`, `grep` (the script's own checks), and once the tool's program, from
the private copy `botlish tool` makes -- the explicit generation; no
program of any package ran at installation.

The package hashes the room installed (build.sh's packages; sdlscreen rebuilt after its lifecycle events, commit 609ce6b0):

| artifact | sha256 |
|---|---|
| android_io-0.1.0.botpkg | 83b7de5816c456a9602e05e843228a1b0bd4ad09c28dd39d5e627045ecda1955 |
| botlish_android-0.1.0.botpkg | 1b5f2c45b0de92dc8e869808acb17f36d96d04190b14f36fe1dcf3ea41f1231d |
| botlish_target_android_aarch64-0.1.0.botpkg | 43a29f92cace1bc52ebf4d756b91fabe5c6a14f1c1098e7bcf70859e3d982fd9 |
| game2048-0.1.0.botpkg | 9c0147801f9e40733376c93691f51c5d7b60feb7c163f16b25ed6ec269f053a5 |
| game2048_play-0.1.0.botpkg | ee9c29a2edbef061a9e122b15bb241a90d9dbea73f866b3514c77e7fee6f1c6e |
| sdl3-0.3.0.botpkg | 125c5dd2857f94f2324eeca7dde94c1c9a7c2b8f82daba0e2d90866ca9f9aaf6 |
| sdlscreen-0.1.0.botpkg | 5a2afc37cb8f3139b1f2bd956eb94b98e4122039ba8149e883bd82aa502e924a |

Two rooms built from the same inputs give APKs that differ in exactly two
places (**observed**): the signature (each room's Gradle makes its own
debug key) and `libmain.so`'s 20-byte build ID (derived from its build
directory, the room's random path). The Botlish application library,
libSDL3.so and classes.dex are byte-identical.

(The sdl3, android_io, sdlscreen and botlish_android releases are new
versions; none is recorded in `packages/RELEASES.tsv` yet: a release is
recorded once published, built in the pinned author image.)

The same clean room ran in CI's build job at bbd5a750 (**CI**, run
43739295620): `ok the APK's facts (12 checked)`, `ok the acceptance's
configuration: game-test.apk (12 facts)`, `result: passed`.

## 22. Negative tests

Refusal contracts, each with its test (**observed**):

* the generator's input refusals: section 17 (`as-tool-refusals`), its
  output-directory refusals and `-replace` (`as-tool-output`), a build of a
  directory it did not generate or without an SDK (`as-tool-output`), a
  failed build (`as-tool-failed-build`);
* a library of another machine (`as-tool-refusals`, `machine`);
* persistence: an invalid save, a save of another version, an empty file and
  a board whose flags are not its facts each start a fresh game, never a
  failure; a save interrupted before its rename (a stray `game.txt.tmp`)
  leaves the previous game whole (`as-2048-restore`);
* tampered snapshots refused by game2048_play itself (`as-play-snapshot`);
* gestures: a second finger cancels a gesture, a cancelled finger's later
  up makes nothing, a finger's gesture is made once however long it moves
  (`as-gesture-exactly-once`, `as-counter-host`);
* installation runs nothing (`as-tool-not-run-by-install`,
  `et-install-runs-nothing`);
* the generated native side's invariants (`as-tool-shim`) and the files the
  generator reads (`as-tool-reads`);
* the native library link: a package's bundled shared library found
  without -L (`nl-package-native-dir`, the compiler defect's regression);
* failed generations leave nothing: every refusal above checks that the
  output directory is empty afterwards, and `as-tool-output` that a refused
  directory is untouched.

A failed build leaves no APK that looks like its result: `android build`
removes the project's `app/build/outputs` before it starts Gradle, so an
earlier build's APK cannot survive a failed one (`as-tool-failed-build`:
the project's wrapper made to fail, the earlier APK gone, the tool's status
1; with the removal taken out the test fails, the stale APK still there --
a defect this test found in the tool, fixed). build.sh and the clean room
copy an APK only after a successful build.

## 23. Mutation testing

`../audit/android-sdl3-2048/tools/mutate.tcl` with `mutants.txt`: the 35
defects the milestone names, in its order, each an exact source edit with
a named detector (`!!`). For each mutant the harness copies the tree (not
`.git`; `native/target` linked, as no mutant touches `native/` and the
harness refuses one that does), applies the edits, runs the named tests
there with a private `-tmpdir` and `-match` them, and classifies: KILLED
when a named detector fails, SURVIVED when every one that ran passed,
UNTESTED when none ran, NOT-APPLIED when an edit's text does not occur
exactly once. Static detectors check source and distribution invariants;
the rest run the code (the interpreter, the Linux host, the generator on
damaged inputs). No Gradle build or emulator is a detector: nothing
unrelated can count as a kill.

Result (**observed**, with BOTLISH_SDL3_2048_PACKAGES and ANDROID_NDK_ROOT
set): **35 mutants: 35 killed, 0 survived, 0 untested, 0 not applied** --
at 47a57871 and again at 112dc0a4's sources (after the lifecycle change of
section 13), each mutant killed by the same detectors both times.
`tools/mutant-catalogs.tcl` applies every mutant of every catalog
(114 catalogs, 3875 mutants, 0 problems).

| # | mutant | defect | file | detectors | verdict (what failed) |
|---:|---|---|---|---|---|
| 1 | `facade-own-spawn` | the React Native facade's new_game spawns its tile itself instead of asking game2048_play | `examples/react-native/2048/game.bot` | `as-play-single-source`, `as-play-oracle` | KILLED (as-play-oracle, as-play-single-source) |
| 2 | `app-own-spawn` | the SDL application's restart spawns its tile itself instead of starting a game2048_play game | `examples/android-sdl3/2048/app.bot` | `as-play-single-source`, `as-2048-host` | KILLED (as-2048-host, as-play-single-source) |
| 3 | `spawn-without-change` | a move that does not change the board still spawns a tile | `examples/games/2048/game2048_play.bot` | `as-play-oracle`, `as-2048-host` | KILLED (as-play-oracle) |
| 4 | `snapshot-without-rng` | the snapshot does not save the generator's state (a restored game spawns elsewhere) | `examples/games/2048/game2048_play.bot` | `as-play-snapshot`, `as-play-oracle` | KILLED (as-play-oracle, as-play-snapshot) |
| 5 | `snapshot-unvalidated` | a snapshot is accepted when its fields are numbers, whatever its flags and cells | `examples/games/2048/game2048_play.bot` | `as-play-snapshot`, `as-2048-restore` | KILLED (as-2048-restore) |
| 6 | `game-over-in-ui` | the application decides the game is over itself, not by game2048_play | `examples/android-sdl3/2048/board.bot` | `as-play-single-source` | KILLED (as-play-single-source) |
| 7 | `shim-drains-events` | the native shim reads SDL's events before the Botlish program does | `integrations/android/templates/main.c.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 8 | `loop-busy-spins` | the visible loop polls instead of waiting (a timeout of 0) | `examples/android-sdl3/2048/app.bot` | `as-2048-lifecycle` | KILLED (as-2048-lifecycle) |
| 9 | `move-twice` | one swipe moves the game twice | `examples/android-sdl3/2048/app.bot` | `as-2048-host` | KILLED (as-2048-host) |
| 10 | `cancel-retained` | a cancelled finger stays tracked: its later up still makes a gesture | `packages/sdlscreen/sdlscreen/gesture.bot` | `as-gesture-exactly-once`, `as-counter-host` | KILLED (as-counter-host, as-gesture-exactly-once) |
| 11 | `draw-while-hidden` | the loop draws whenever something changed, also in the background with no surface | `examples/android-sdl3/2048/app.bot` | `as-2048-lifecycle` | KILLED (as-2048-lifecycle) |
| 12 | `shim-exits` | a failed application ends the process with exit() instead of returning from SDL_main | `integrations/android/templates/main.c.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 13 | `termination-ignored` | the loop goes on after SDL_EVENT_QUIT and SDL_EVENT_TERMINATING | `examples/android-sdl3/2048/app.bot` | `as-2048-terminate` | KILLED (as-2048-terminate) |
| 14 | `swipe-reversed` | a horizontal swipe is read the wrong way round | `packages/sdlscreen/sdlscreen/gesture.bot` | `as-gesture-classify`, `as-2048-host` | KILLED (as-2048-host, as-gesture-classify) |
| 15 | `threshold-ignored` | any movement at all makes a swipe (the threshold is not read) | `packages/sdlscreen/sdlscreen/gesture.bot` | `as-gesture-classify` | KILLED (as-gesture-classify) |
| 16 | `gesture-per-motion` | every motion of a finger is classified: one touch makes several gestures | `packages/sdlscreen/sdlscreen/gesture.bot` | `as-gesture-exactly-once`, `as-2048-host` | KILLED (as-2048-host, as-gesture-exactly-once) |
| 17 | `geometry-hardcoded` | the board's size is one phone's, whatever the screen | `examples/android-sdl3/2048/board.bot` | `as-layout`, `as-2048-frames` | KILLED (as-layout) |
| 18 | `stale-frame` | a move changes the game but not the screen: the score and board shown stay the previous state's | `examples/android-sdl3/2048/app.bot` | `as-2048-frames` | KILLED (as-2048-frames) |
| 19 | `restart-ui-only` | the restart button logs and redraws a restart but keeps the game | `examples/android-sdl3/2048/app.bot` | `as-2048-host` | KILLED (as-2048-host) |
| 20 | `win-in-ui` | the win message reads the board itself, not game2048_play's won? | `examples/android-sdl3/2048/board.bot` | `as-play-single-source` | KILLED (as-play-single-source) |
| 21 | `library-unloaded` | the shim closes the application library instead of pinning it while SDLThread runs | `integrations/android/templates/main.c.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 22 | `create-not-main` | the shim makes an instance (NAME_create) instead of running the entry program (NAME_main) | `integrations/android/templates/main.c.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 23 | `renderer-after-quit` | sdlscreen quits SDL before destroying the renderer and the window | `packages/sdlscreen/sdlscreen.bot` | `as-sdlscreen-teardown` | KILLED (as-sdlscreen-teardown) |
| 24 | `foreign-thread` | the shim runs the entry program on a thread of its own, not on SDLThread | `integrations/android/templates/main.c.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 25 | `tag-masked` | the shim clears the top byte of the argument pointers before handing them to Botlish | `integrations/android/templates/main.c.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 26 | `tagging-disabled` | the generated manifest turns Bionic's heap pointer tagging off | `integrations/android/templates/AndroidManifest.xml.in` | `as-tool-shim` | KILLED (as-tool-shim) |
| 27 | `wrong-architecture` | the generator accepts an x86-64 library as the arm64-v8a one | `integrations/android/src/main.c` | `as-tool-refusals` | KILLED (as-tool-refusals) |
| 28 | `reads-source` | the generator reads the application's Botlish source beside its artifacts | `integrations/android/src/main.c` | `as-tool-reads` | KILLED (as-tool-reads) |
| 29 | `java-omitted` | the generator leaves SDL's SDLActivity out of the project | `integrations/android/src/main.c` | `as-tool-generate` | KILLED (as-tool-generate) |
| 30 | `stale-sdl-accepted` | the generator takes the SDL3 package's files without comparing their digests | `integrations/android/src/main.c` | `as-tool-refusals` | KILLED (as-tool-refusals) |
| 31 | `manifest-digests-skipped` | the generator takes the library's files without comparing their digests with the manifest's | `integrations/android/src/main.c` | `as-tool-refusals` | KILLED (as-tool-refusals) |
| 32 | `wrong-library` | the project gets the library's static archive under the shared library's name | `integrations/android/src/main.c` | `as-tool-generate` | KILLED (as-tool-generate) |
| 33 | `alignment-4k` | the generator accepts a library whose segments are aligned for 4 KiB pages only | `integrations/android/src/main.c` | `as-tool-refusals` | KILLED (as-tool-refusals) |
| 34 | `install-runs-tool` | listing a project's tools makes each runnable program executable and runs it | `pm/tools.tcl` | `as-tool-not-run-by-install`, `et-install-runs-nothing` | KILLED (as-tool-not-run-by-install; et-install-runs-nothing) |
| 35 | `names-of-the-game` | the generator's default application ID is the game's, whatever library it is given | `integrations/android/src/main.c` | `as-tool-generate` | KILLED (as-tool-generate) |

Two findings came out of the catalog run itself. The termination mutant
first hung its detector: SDL installs a SIGTERM handler that turns the
signal into `SDL_EVENT_QUIT`, so `timeout 60`'s SIGTERM was one more quit
event the mutant ignored, and the host never ended. The tests now pass
`timeout -k 5 60`. And `spawn-without-change` is killed by the oracle but
not by `as-2048-host`, whose sixteen swipes happen to change the board
every time: the oracle's 400 moves include no-op moves.

## 24. Regression and CI

### Local regressions (**observed**)

`tclsh9.0 tests/local.tcl -jobs 2` over the files the milestone's changes
reach -- each on interp and compile, 19 minutes:

| file | covers | interp / compile |
|---|---|---|
| application-library.test | native application libraries, `NAME_main` | 18 / 18 passed |
| native-library.test | ordinary native libraries, C ABI and error ownership | 33 / 33 passed |
| native-link-plan.test | native link plans | 34 / 34 passed |
| android-target.test | Android target support (link half with the NDK) | 22 / 22 passed |
| c-bindgen.test | the C binding generator (Android included) | 64 / 64 passed |
| external-tools.test | PM-7A external tools, runtime ABI fingerprints | 49 / 49 passed |
| package-manager.test | the package manager | 86 / 86 passed |
| package-native.test | target-aware packages | 45 / 45 passed |
| package-workloads.test | sdl3/sdlkit/raven/event loop packages | 16 / 16 passed |
| bot-modules.test | package-scoped modules | 69 / 69 passed |
| workload-2048.test | the game2048 core workload | 9 / 9 passed |
| workload-icy-tower.test | SDL3 bindings and Icy Tower | 25 / 25 passed |

Total: 470 passed, 0 failed on each backend. Besides:
`tests/android-sdl3-2048.test` (23 tests, all run with the packages and the
NDK; again at 112dc0a4's sources: 23 of 23), `nl-package-native-dir` (passes; fails with native/library.tcl before
the fix), `tools/mutant-catalogs.tcl` (114 catalogs, 3875 mutants, 0
problems), `tools/compilerpedia.tcl check` (1306 topics, 787 examples, 0
problems), `audit/refactor/tools/gate.tcl` (the warning gate: passed).

Three repairs outside the milestone's own files, each found on the way:

* `tools/package-repository.tcl` sourced `tools/http-package.tcl` inside a
  procedure, so its namespaces -- and `tools/rust-unit.tcl`'s `rustunit`,
  which it sources -- were `::author`'s, and httppkg's calls of
  `rustunit::localize` failed: the package reproducibility workflow had
  failed on main the same way since rust-unit.tcl arrived (run 43705620553
  at a3c32d66). It is sourced at the global level now; both reproducibility
  builds succeed (**CI**, run 43739295688 at bbd5a750).
* `tests/package-workloads.test`'s `pw-sdl3-two-targets` expected the
  package layout before shared package graphs (it fails the same on main;
  it runs only where the arm64 cross compiler is installed): its
  expectation states the shared graph's.
* A narrow compiler defect: a native library's
  link searched no directory of the program's target package tree, so a
  library linking a package's bundled shared library (libSDL3.so) needed
  -L by hand; `native::library` now searches the tree's `.lib` after -L's,
  as an executable's link does (`nl-package-native-dir`).

### CI on this branch (**CI**)

| workflow | run | commit | result |
|---|---|---|---|
| android sdl3 2048 | runs 1-7 | 0d2f89d1 .. 7235327a | section 18 |
| c-bindgen (dispatched on the branch: it runs only on main, a pull request or a dispatch) | 43750835551 | 112dc0a4 | **success**: every committed binding checked with the pinned toolchain (Ubuntu 26.04, clang 21.1.8; sdl3's android-aarch64 with NDK r29), the generator's tests, the Raven package's tests, both fuzzers |
| react-native 2048 | 43737218482 | bc31909c | **success**: the facade over game2048_play, the generated package, the APK on both emulators; no later commit changes what it builds |
| package reproducibility | 43739295688 | bbd5a750 | both builds succeeded (they had failed on main since a3c32d66: section 24's first repair) |
| package reproducibility | 43748311615 | 609ce6b0 | both builds succeeded; the comparison job was still waiting for a runner when this was written |

## 25. Performance and footprint

### Footprint (**observed**, build.sh's output for this revision's sources)

| item | bytes |
|---|---:|
| `sdl3-0.3.0.botpkg` (three targets' views) | 2,741,152 |
| `botlish_android-0.1.0.botpkg` | 439,068 |
| `android_io-0.1.0.botpkg` | 1,843 |
| `sdlscreen-0.1.0.botpkg` | 12,404 |
| `game2048_play-0.1.0.botpkg` | 3,975 |
| `botlish_target_android_aarch64-0.1.0.botpkg` (the Android runtime archive) | 9,845,117 |
| generated Gradle project (sources, both libraries, wrapper; no build outputs) | 4,100,402 |
| `libgame.so` as built (the manifest's) / as packaged (stripped by the Android build) | 1,359,120 / 961,080 |
| `libcounter.so` as built / as packaged | 1,229,216 / 848,144 |
| `libSDL3.so` (the package's, already stripped) | 2,401,784 |
| `libmain.so` (the shim) as linked / as packaged | 12,528 / 5,904 |
| the game's APK (`game.apk`, release, debug-signed) | 3,470,667 |
| the counter's APK | 3,356,002 |
| native libraries installed (stored uncompressed, loaded in place from the APK: nothing extracted) | 3,368,768 |

The Botlish application library is about a quarter of the APK, SDL a
little under three quarters; Java and resources are the rest. The React
Native 2048 APK (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md, its clean
room's release APK) is 11,287,309 bytes: React Native and Hermes against
SDL here. The two applications' library sizes are not comparable as a cost
of the platform: the SDL3 game's library holds the UI, the input, the loop
and the airlock as well as the rules.

No coroutine stack is reserved: neither application constructs a
coroutine. The renderer's resources are SDL's (one window, one renderer,
SDL's debug font texture); sdlscreen allocates ten small scratch buffers
with `SDL_malloc` at open and frees them at close.

### The Linux host (**observed**, `../audit/android-sdl3-2048/tools/measure.py`, 5 rounds)

The application library and the touch host, SDL's dummy video driver, this
container while it also ran the mutation catalog and the regression files
(the figures are upper bounds):

```
start-up to the first frame          median    19.1 ms  (min 18.9, max 30.5, n 5)
swipe to the program's move line     median     0.8 ms  (min 0.0, max 10.1, n 80)
SDLThread CPU in 2 s idle            36 ms in 2000 ms, 43 ms in 2000 ms, 34 ms in 2000 ms, 39 ms in 2000 ms, 35 ms in 2002 ms
```

Start-up is process start to the program's "ready ... drawn" line, which
it prints after presenting its first frame: VM creation, module
initialization, SDL's initialization, the window, the renderer, the save
read, the layout and the first frame. A swipe is the host's mark after its
last finger event to the program's "move" line: the gesture recognized, the
game moved, the snapshot formed and printed (the frame follows). The idle
figure is SDL's dummy driver polling every millisecond (it has no event
wait); `as-2048-lifecycle` holds it under a tenth of the wall time.

### The emulators (**CI**, translated: x86_64 images running arm64-v8a code through `libndk_translation`)

From the acceptance logs of run 7 (4 KiB image, API 34) and run 6 (16 KiB
image, API 35), which played the same phases; build.sh's game-test.apk
(the clean room's APK gives the same figures within a few tens of
milliseconds). Times are logcat's and `am start -W`'s; a "tick" is a
hundredth of a second of CPU time (`/proc/PID/stat`).

| measure | 4 KiB, API 34 | 16 KiB, API 35 |
|---|---:|---:|
| cold start, `am start -W` TotalTime (first launch after install) | 664 ms | 1020 ms |
| cold start, later launches (restore, win, over, recreation) | 475-513 ms | 487-503 ms |
| hot resume after the background, TotalTime | 39 ms | 56 ms |
| process start to `game_main` entered (Zygote fork, ART, SDLActivity's `onCreate`, three libraries loaded, SDLThread) | 187-254 ms | 197-467 ms |
| `game_main` entered to "ready ... drawn" (VM, module initialization, SDL's video, window, renderer, the save read, the first frame presented) | 455-667 ms | 1226-1596 ms |
| SDLThread while idle in the foreground, 5 s | 0 ticks | 0 ticks |
| the whole process while idle in the foreground, 5 s | 1 tick | 1 tick |
| the whole process while hidden, 5 s | 0 ticks | 0 ticks |
| the counter, cold start TotalTime / `counter_main` to ready | 1503 ms / 806 ms | 1404 ms / 1541 ms |

What these are and are not:

* The program's own start (`game_main` to its first frame) is 19 ms under
  the Linux host and 0.5-1.6 s here. The difference is the emulator and
  the native bridge, not measured apart: `libndk_translation` translates
  arm64 code as it first runs (VM creation and module initialization run
  each function once), SDL's renderer goes through the bridge's proxies
  of EGL and GLES, and the 16 KiB image runs under steady memory
  pressure (its low-memory killer ended dozens of processes during each
  run). It says nothing about native ARM, which remains **projected**.
* Idle is genuinely idle: with the poll sentinel off, SDLThread used no
  measurable CPU in five seconds in the foreground on both images, and
  the hidden process none at all (run 2 measured 428 ticks for the
  counter's SDLThread before the fix).
* Touch latency was not measured on the emulators. The only timestamps
  are logcat's, written by different processes: on the 4 KiB image the
  launcher's gesture monitor logs each finger-up, and the program's move
  line follows it by a median 1 ms (n 24, max 465 ms: the burst) --
  evidence of order and of no queueing delay, not a latency figure. The
  Linux host's figure (0.8 ms median from the last finger event to the
  move line) is the program's own cost.
* Memory was not measured on the emulators beyond what the footprint table
  states.

## 26. Remaining limitations

* **No native ARM execution.** Every Android run was an x86_64 emulator
  image translating arm64-v8a code (`libndk_translation.so`). Native ARM
  hardware (a phone, an ARM CI runner with an emulator) remains
  **projected**: the application's behavior there, its CPU and latency
  figures, and the tagged-pointer path live.
* **Heap pointer tagging was not exercised live by the APK.** The
  translated process reports top byte 0x00 for a fresh `malloc` pointer on
  API 34 and 35 images (section 9): Bionic hands translated code untagged
  pointers there. The tagged path rests on the previous milestone's
  observation under qemu-user with Android's own userspace (tags on API 30+,
  SDL3's objects included) and on the unchanged runtime ABI; this milestone
  adds no pointer conversion and disables nothing.
* **MTE** (memory tagging, as opposed to top-byte tagging) was not
  exercised anywhere.
* **One ABI.** arm64-v8a only: the generated project refuses another ABI,
  and an x86_64 emulator runs the app only through its native bridge.
  armeabi-v7a and x86_64 Android targets do not exist in Botlish.
* **Text** is SDL's 8x8 debug font scaled: legible, ASCII only, no SDL_ttf.
* **Accessibility, IME, rotation-specific layouts, multi-window and
  foldables** are not addressed beyond what SDLActivity does (the layout is
  recomputed on every resize).
* **The Activity recreation** follows SDL 3.4.18's default: a recreated
  Activity ends the process, and the next launch restores the saved game.
  A recreation that keeps the process (SDL_HINT_ANDROID_ALLOW_RECREATE_ACTIVITY
  and a second `SDL_main` in one process) is not designed. Android's
  "don't keep activities" setting could not be enabled from a shell
  (`settings put global always_finish_activities 1` changed nothing in run
  4: the system reads it through the developer options' own call), so the
  recreation tested is a density change.
* **Low-memory notices** never reach a program that reads SDL's queue
  (SDL 3.4.18 hands SDL_EVENT_LOW_MEMORY to watchers only); the game saves
  after every change, so nothing depends on one.
* **Signing** is the debug key: a test APK, not a release.
* **The poll sentinel workaround** depends on SDL 3.4.18's Android wait;
  a later SDL may fix the self-wakeup, and the hint stays harmless then.
* **The Linux host's figures** come from SDL's dummy video driver, which
  has no event wait (SDL polls every millisecond there): they bound the
  application's own costs, not a desktop SDL application's.

## 27. Next milestones

* Run the same APK on native ARM hardware (and an MTE-capable device) to
  observe tagging, latency and idle CPU without translation.
* Reuse sdlscreen and the generated bootstrap for a second SDL3 target
  (desktop Linux with a real window, or iOS through SDL's own bootstrap),
  keeping the application modules unchanged.
* Grow sdlscreen's drawing vocabulary only as applications need it
  (textures, SDL_ttf text), still as values, never handles.
* Let the generator take more of an application's Android surface as data
  (orientation, permissions, icons) without application knowledge.
