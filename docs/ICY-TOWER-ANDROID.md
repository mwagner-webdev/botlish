# Icy Tower on Android

The Icy Tower vertical slice (ICY-TOWER-VERTICAL-SLICE-1.md) as an Android
application: arm64-v8a, Android 5.0 (API 21) and later, phones and tablets
in either orientation, played by touch. It is the same game -- the same
rules (`tower.bot`), text (`hud.bot`), frame loop (`game.bot`), drawing
(`render.bot`) and SDL airlock (`sdl.bot`) the Linux, Windows and macOS
executables are built from -- with Android's platform code supplied the way
Botlish supplies platform code: by the contexts the entry program installs.

```
examples/games/icy-tower/build-android.sh OUTDIR    -> OUTDIR/icy-tower.apk
```

## The platform seam: a context trait

What differs between a desktop and a phone is how the player is read and
shown the controls, and how a finished frame is completed. That is one
context trait, `controls::Controls` (`controls.bot`, pure):

```
context trait Controls:
    fn read_controls() -> Reading
    fn controls_banner(world: tower::World) -> List[str]
    fn present_frame() -> bool
```

`game.bot` reads the player with `controls::read()` and `render.bot` names
the controls with `controls::banner_lines(world)` and finishes a frame with
`controls::present()`. Two contexts implement it, each in its own module:

| context | module | installed by | reads | draws |
|---|---|---|---|---|
| `keyboard::Keyboard` | `keyboard.bot` | `main.bot`, `main-windows.bot`, `main-macos.bot` | the keys (Left/A, Right/D, R, Escape) | nothing |
| `touch::Touch` | `touch.bot` | `main-android.bot` | SDL's finger and back-key events, and the keys of a keyboard the device may have | two pads around the scaled view |

The compiler selects the one installed implementation statically and
compiles every call to a direct call (CONTEXT-TRAITS.md): there is no
platform test anywhere in the game, and no dispatch at run time.

`keyboard.bot` is what `game.bot` and `render.bot` did before the seam,
moved: one `sdl::poll` of the same keys, hud's banner, `sdl::present()`.
The desktop executables make the same SDL calls with the same arguments in
the same order as before (`workload-icy-tower-trace-reference` compares the
Linux executable's trace with `audit/icy-tower/trace-reference.txt`,
unchanged). The desktop's changes are that move, one installation line in
each desktop entry, and two calls in `render.bot` that now go through the
trait.

The Android entry, `main-android.bot`, installs android_io's `std::io::IO`
(logcat, tag `IcyTower`), `sdl::create()` and `touch::create()`, and runs
`game::main` like every other entry.

## The screen: scaled to the device

`sdl.bot` already letterboxes the game's 480 x 720 logical view into the
window (`SDL_SetRenderLogicalPresentation`, one policy for every density).
On Android the window is the whole screen -- `touch.bot` makes it
fullscreen (immersive: the system bars hidden until swiped in) at its first
read -- so the view is scaled to the largest size the screen holds, on any
phone or tablet, in either orientation (the generated SDLActivity handles
rotation without recreating the Activity, and SDL recomputes the
presentation every frame).

The pads go where the view leaves room (`touchpad::pads`, pure, in the
window's pixels as fractions of its shorter side):

* a tall screen (a phone held upright): in the band below the view, left
  and right halves;
* a wide screen (a tablet, a phone on its side): in the bands beside it;
* a screen the view nearly fills (a 3:4 tablet held upright): as outlines
  over the view's lower corners.

To draw them, `touch::present_frame` turns the logical presentation off
(`sdl::unscaled`), draws in pixels, presents, and turns it on again
(`sdl::scaled`): SDL's presentation is a transform, safe to toggle within a
frame. The rules are untouched: the world is still exactly 480 x 720 units.

## The controls

* Hold the left or right half of the screen to run (`touchpad::steering`:
  the whole screen is the pad, so a thumb need not find a button); the pad
  of the held side is drawn pressed.
* A finger put down after a fall starts a new game (a finger held through
  the fall starts nothing).
* Back (the button or the gesture) quits; so do Escape and the Activity's
  destruction (SDL's quit).

The fingers come from SDL's finger events, decoded in `sdl.bot`
(`sdl::poll_touch`, an operation that takes and returns values, like every
operation of the airlock), never from SDL's polled touch state: Android's
back gesture sends its key down and up between two frames, which a polled
state misses, and events are what the 2048 milestone's Linux touch host can
inject.

Pausing needs no code: SDL blocks its event pump while the Activity is in
the background (`SDL_HINT_ANDROID_BLOCK_ON_PAUSE`'s default), and the first
frame after it counts at most `tower::max_dt`.

## Building

`build-android.sh` follows RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-
MILESTONE-1.md: the packages sdl3 (its android-aarch64 view: the committed
generated binding, SDL 3.4.18's `libSDL3.so`, SDL's Java classes),
android_io and botlish_target_android_aarch64 installed in a project with
the game's modules, `main-android.bot` compiled under `-warnings error` as
the application library `icytower`, and integrations/android's tool
generating and building the SDLActivity project. The APK is signed with the
debug key: a sideloadable build, not a store release. The `android sdl3
2048` workflow builds it from the same packages as the 2048 APKs.

## Evidence

* `golden.bot`: five tests of `touchpad.bot` (steering by halves; the pads
  of a tall, a wide and a filled screen; the banner) beside the 67 of the
  rules, on every backend; four mutants of `touchpad.bot` in
  `audit/icy-tower/mutants.txt`, each killed by one of them.
* The desktops unchanged: the rebuilt Linux executable's SDL call trace is
  `audit/icy-tower/trace-reference.txt`, every call, argument and result
  of every frame (`workload-icy-tower-trace-reference`), and its runs equal
  the oracle's. `audit/icy-tower/tools/abi-check.py` also checks the
  layouts the touch controls read (the binding's `SDL_TouchFingerEvent`,
  `sdl.bot`'s `KeyEvent`) against SDL's headers.
* `tests/workload-icy-tower.test`: the Android entry compiles for
  android-aarch64 under `-warnings error`, with `touch.bot` and
  `touchpad.bot` ordinary modules and android_io mediated by its context
  (`-android-modules`); no SDL call outside `sdl.bot`
  (`-android-airlock`); no Android name in a module the desktops are built
  from (`-android-shared-sources`); and the touch controls running on
  Linux under the 2048 milestone's touch host (SDL_main on a thread named
  SDLThread, fingers and the back key pushed from another thread):
  steering both ways and quitting by Back (`-touch-steering`), a long run
  falling and restarted by taps (`-touch-restarts`).
* The frames of that host run on SDL's offscreen driver, at a 540 x 1200,
  a 1024 x 768 and a 600 x 800 window, show the three layouts with the
  held side's pad pressed.
* The APK passes the 2048 milestone's inspection
  (`audit/android-sdl3-2048/tools/inspect-apk.sh`): arm64-v8a only, every
  native library AArch64 with 16 KiB LOAD alignment and stored
  uncompressed, the application library the manifest's, SDL the sdl3
  package's.

Not established: a run on an Android device or emulator. The container
this was built in has no KVM, and an arm64-v8a APK runs on an x86_64
emulator image only through Android's native bridge; the 2048 milestone's
emulator acceptance (`acceptance-2048.sh`) is the model for one.
