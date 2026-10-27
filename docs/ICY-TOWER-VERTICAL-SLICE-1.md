# ICY-TOWER-VERTICAL-SLICE-1.md -- a playable Icy Tower-style game in Botlish

An application milestone, not an engine milestone: one small real-time
native game -- graphics, keyboard, a frame clock, physics-like motion,
collisions, a camera, a score, game over and restart -- written in ordinary
Botlish over the generated SDL3 binding, built into a Linux x86-64
executable, and used as a hostile test of the language, its library, its
FFI and its compiler. The game is `examples/games/icy-tower/`; the
executable is `audit/icy-tower/artifacts/icy-tower`.

**Since NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md**, the four conversions this
report lists as missing are the standard library's, and the game uses them:
`hud::int_text` is `std::int::to_string`, `options::number` is
`std::int::from_string` (a number on the command line is now the canonical
text of a nonnegative Int: "007" and "-5" are usage errors, length is
unbounded), `hud::nearest` is `std::float64::round` and
`hud::metres_text`/`tenths_text` are `std::decimal_rounded::to_string`.
hud.bot is 85 lines (146 before), `timer_text` and `summary` no longer
declare NonFiniteFloat, and the golden suite has 67 tests (two added:
`icy-options-numbers-of-any-length`, `icy-summary-shows-positions-at-the-
nearest-int`). One rule changed with the rounding: a position is shown at
its nearest Int with a half to the even one (it was away from zero); of 50
seed and frame-count summaries compared with the earlier executable, one
differs (seed 3 after 60 frames, x=286.5: 287 before, 286 now), and
oracle.py's `nearest` is Python's `round` to match.

**Since ICY-TOWER-WINDOWS.md**, the game also builds for Windows x86-64.
main.bot's program is `game.bot`, an application module, and `main.bot`
(Linux) and `main-windows.bot` (Windows) only install the contexts. The game
makes no variadic C call: a failure's SDL_GetError text is copied out of SDL
with `SDL_strlcpy`, read back through the text buffer's layout, and written
by the game on standard error through `std::io` (the same bytes SDL_Log
wrote; the SDL call trace of a played run is identical). Scancodes are
Ints, since an SDL enumeration constant's C type is the target's. The text
below describes the slice as it was built.

![Three frames of the X11 window under Xvfb: the start, floor 26, a restarted game](../audit/icy-tower/screenshots/xvfb-x11.png)

*Three frames of the executable in a real X11 window (Xvfb, SDL's x11
driver): the first seconds of a game played with injected key presses, the
autopilot at floor 26, and a game after a restart.*

## Outcome

* **The Linux slice is complete.** The game builds from Botlish source with
  the generated SDL3 binding (`examples/games/icy-tower/build.sh`); the
  executable runs its loop in a real X11 window at the display's 60 Hz,
  reads Left/A, Right/D, R and Escape and the window's close button,
  bounces the player off platforms under gravity, generates the tower
  forever, scrolls the camera up (and then lets the tower rise by itself),
  counts floors and the best height, ends the game when the player falls
  out of the view, restarts on R, and releases every SDL object on every
  way out. Every item of the brief's completion criteria is met; section
  "Completion criteria" maps each to its evidence.
* **Tested without a display, and with one.** 65 golden tests of the rules,
  text and command line pass on all four backends with one report; the
  headless simulation agrees on all four backends; the executable's
  headless runs agree with an independent Python oracle on 32 seed x
  frame-count runs (up to 3600 frames, with games lost and restarted); the
  real SDL loop on SDL's dummy video driver plays the same frames as the
  headless run, also under GC stress and under valgrind's memcheck (no
  error, nothing lost); 26 of 26 mutants of the rules are killed; an Xvfb
  session drives the X11 window with XTest key presses and checks the
  player moves right and left, Escape quits and a window-manager close
  ends the run cleanly.
* **One compiler bug found and fixed.** Once main's List length
  refinements (LIST-CARDINALITY-REFINEMENTS.md) were merged in, the front
  end crashed on the game (`TCL LOOKUP DICT` in
  `hir::completions::ExactCopy`): a field read of a struct bound from a
  handled call whose handler has two statements. Fixed in two lines, with a
  regression test that fails without it. Otherwise the four backends, the
  oracle, GC stress and memcheck agree everywhere. Also fixed: one tooling
  bug (`tests/cffi/sdl3.tcl` could not build SDL on a fresh machine), and
  two application bugs the tests found (section "Bugs found and fixed").
* **One stdlib addition:** `std::float64::min`, `max`, `abs`, `clamp`
  (`stdlib/float64.bot`). Everything else the game missed is recorded, not
  added (section "Stdlib").
* **Performance is not a problem for this game, but its profile is a
  finding.** A whole frame costs about 0.6 ms on SDL's software renderer
  (68 % of it in SDL). Of the program's own instructions, half are
  big-integer arithmetic: the one `std::decimal_rounded::round` per frame costs
  about twice all the physics (section "Performance and allocation").
* **Android was not attempted beyond an assessment**: Botlish has no Android
  target and generates native code for the host only (section "Android").

## Source layout

| file | lines (code) | what |
|---|---:|---|
| `examples/games/icy-tower/tower.bot` | 413 (242) | the rules: state, generator, motion, collision, camera, games, the autopilot. Pure |
| `examples/games/icy-tower/hud.bot` | 146 (100) | the text: numbers, heights, the HUD lines, the summary line. Pure |
| `examples/games/icy-tower/options.bot` | 104 (76) | the command line. Pure |
| `examples/games/icy-tower/sdl.bot` | 293 (179) | the thin SDL layer: open/close, poll, draw a rectangle, a line, text, the clock, SDL's error log; the one module with raw authority |
| `examples/games/icy-tower/render.bot` | 158 (120) | one frame drawn with sdl.bot's calls |
| `examples/games/icy-tower/main.bot` | 183 (128) | the entry program: arguments, the frame loop, headless mode, cleanup, exit status |
| `examples/games/icy-tower/headless.bot` | 19 (9) | the deterministic simulation as a program of its own, for every backend |
| `examples/games/icy-tower/golden.bot` | 624 (472) | the golden suite (stdlib/test.bot), 65 tests |
| `examples/games/icy-tower/run.tcl` | | runs the pure programs and the suite on any backend |
| `examples/games/icy-tower/build.sh` | | builds the executable (SDL3, staging, emit, strip) |
| `audit/icy-tower/artifacts/icy-tower` | | the stripped Linux x86-64 executable |
| `audit/icy-tower/oracle.py` | | the independent implementation of the rules |
| `audit/icy-tower/mutants.txt`, `mutate.tcl` | | 26 mutants and their harness |
| `audit/icy-tower/tools/xvfb-session.py` | | the graphical run: Xvfb, XTest, screenshots, WM close |
| `audit/icy-tower/tools/perf.tcl`, `callgrind-frame.py`, `callgrind-split.py` | | the performance and allocation report |
| `tests/workload-icy-tower.test` | | 15 tests in the Tcl suite (8 need the package-owned libSDL3) |
| `.github/workflows/icy-tower.yml` | | CI: SDL3 built, every test run (none skipped), oracle, mutants, Xvfb, the executable uploaded |
| `stdlib/float64.bot` | | the stdlib addition |

Each `.bot` file beside `main.bot` is an application module (IMPORTS.md):
`import tower` is `tower.bot`. The game has no assets: everything is drawn
from rectangles, lines and SDL's built-in 8x8 debug font, so nothing has to
travel beside the executable.

The layering is strict. The pure modules know nothing of SDL, the clock or
input devices; a frame is `tower::step(world, input, dt)`, so the rules run
and are tested on every backend. `sdl.bot` is the only module that holds
raw authority (next sections), `render.bot` draws a `World` with its
calls, and `main.bot` connects the clock, the keyboard and the loop.

## Controls

| key | action |
|---|---|
| Left or A | run left |
| Right or D | run right |
| (landing) | bounce: automatic, higher the faster you run |
| R | a new game, after a fall |
| Escape, or closing the window | quit |

There is no jump key: the player bounces off every platform it lands on,
as Icy Tower's player does once it is airborne and as Doodle Jump's always
does. A manual jump would add a "standing" state, ground friction and
input timing to a slice whose point is elsewhere; automatic bounces keep
the motion one state machine with one transition (landing).

## Gameplay rules

All quantities are in view units (the view is 480 x 720; 100 units are
shown as a metre) and seconds. World y is altitude, up.

* **The tower.** Walls 20 units thick on either side; the player and the
  platforms stay between x = 20 and x = 460. Floor 0 is the ground, a
  full-width platform whose top is at y = 40.
* **The player** is a 26 x 34 box; its x is its left edge, its y its feet.
* **Running.** Holding one direction accelerates at 2400 u/s^2 toward it,
  up to 420 u/s; holding neither (or both) slows the player by friction,
  1800 u/s^2, to a stop, never through zero.
* **Gravity** is 2100 u/s^2.
* **Walls** stop the player and send it back at 0.6 of its speed.
* **Landing and bouncing.** A player whose feet cross a platform's top
  while falling, overlapping it horizontally, lands on it: its feet are put
  on the top and it bounces straight up at 860 + 440 x |vx| / 420 u/s
  (176 units high standing, 402 at full run).
* **Floors and score.** Platforms are numbered from the ground up; the
  floor is the highest floor landed on, and the score is ten points a
  floor. Every 25th floor spans the tower and shows its number.
* **The camera** keeps the player's feet at most 55 % up the view, moving
  up at once, never down. Once the best height shown reaches 6.0 m, the
  tower starts rising by itself, at 30 + 0.9 u/s a floor, at most 170 u/s.
* **Game over** when the player's head is more than 60 units below the
  view's bottom edge. The game freezes; R starts a new game on the next
  tower of the same generator (a restart never replays the same tower).
* **The HUD** shows the score, the floor, the best height (one decimal)
  and the time played (one decimal); the first three seconds of the first
  game show the controls, a lost game "GAME OVER / R: PLAY AGAIN   ESC:
  QUIT".

The game is deliberately not Icy Tower's: no combos, no characters, no
floors of graphics or sound, no menus. It is recognizably the same game:
a tower, a player that climbs by bouncing and running, a camera that
starts chasing you.

## The numerical model

Three numeric kinds meet in this game, each where its semantics belong.

### Float64: the simulation

Positions, velocities, accelerations, the frame length, the camera, the
generator's fractions, every comparison of the collision test: Float64,
the finite binary64 numbers (FLOAT64-MILESTONE-1.md). The simulation is
continuous and its constants are physical, so binary floating point is
the honest representation; and because every backend rounds every
operation the same way (IEEE 754, correctly rounded), the simulation is
bit-for-bit deterministic across the four backends and against Python's
floats, which is what makes the oracle and the fixed-seed tests possible.

The price: every Float64 operation can fail with `NonFiniteFloat`, which
must be handled or declared. 40 of the game's 90 functions declare
`errors NonFiniteFloat`, and the frame loop handles it (a step that
overflowed ends the run with an error, after cleanup). No such failure is
possible in this game -- every quantity is bounded -- but the compiler has
no Float64 ranges to prove it (FLOAT64-MILESTONE-1.md, section 14), so the
declarations are the honest cost of the rule, not a sign of a bug.

### DecimalRounded: what the player is shown, and rules stated in it

`DecimalRounded{minDecimalsPreserved: 1}` (DECIMAL-ROUNDED-MILESTONE-1.md)
is used where a number is *a decimal the player reads* and a rule should
not depend on the binary digits behind it:

* **The best height** (`World.best`). Each frame the feet's height in
  metres is quantized, `std::decimal_rounded::round[DecimalRounded{
  minDecimalsPreserved: 1}]((y - 40) / 100)`, and the record replaces the
  best only when it is greater *at one decimal place* (DecimalRounded's
  `>` compares at the guaranteed precision). A record therefore only
  changes when the number on the screen does
  (`icy-best-height-only-grows-in-displayed-steps`).
* **The rising threshold** is a DecimalRounded constant, `fn rise_height()
  -> DecimalRounded{minDecimalsPreserved: 1}: 6.0`, compared with the
  best height: the tower starts rising exactly when the display reads
  6.0. A feet altitude of 635 (5.95 m, whose binary64 is
  5.9500000000000001776...) shows 6.0 and starts it; 634 (5.94) does not
  (`icy-tower-still-below-the-displayed-6.0`,
  `icy-tower-rises-once-the-display-reads-6.0`; the `rise-on-raw-height`
  mutant, which compares the raw altitude, is killed by them).
* **The timer** shown in the HUD is quantized the same way and printed
  with half-to-even rounding of the clock's exact binary value: 1.25 s
  shows 1.2, 2.35 s (2.3500000000000000888...) shows 2.4
  (`icy-timer-rounds-half-to-even-at-one-place`).

What was learned:

* **It is the right tool for "a rule in the units the player sees",** and
  the comparison rule (at the smaller guaranteed precision) is exactly the
  record and threshold semantics a game wants.
* **It cannot be in the simulation.** Arithmetic on a DecimalRounded value
  known only by its type is rejected (DECIMAL-GUARANTEE-LOST), as it should
  be; the game computes in Float64 and quantizes the result, as the
  milestone intends.
* **It cannot be shown.** There is no DecimalRounded-to-String. The game
  decays the value (`std::float64::from_decimal_rounded`, the Float64 nearest
  the guaranteed decimal), multiplies by ten, rounds to the nearest Int by
  hand (`hud::nearest`: Botlish has `truncate` only) and spells the tenths.
  That path is sound -- the decayed value is within a few units in the
  last place of k/10, so k comes back -- but it is the very binary
  reasoning the type exists to spare its user, written in application
  code.
* **It cannot be named.** `type` declares integer domains only, so
  `DecimalRounded{minDecimalsPreserved: 1}` is spelled out ten times.
* **It is the slice's most expensive operation** (section "Performance
  and allocation"): one quantization costs about twice the whole physics
  of a frame.
* A struct holding a DecimalRounded field (`World`) cannot be compared
  with `==`; tests compare projections.

### std::ffi::c::Float: where Float64 meets SDL

SDL3's renderer takes C `float`s. Every one goes through the
`std::ffi::c::Float` boundary (C-FLOAT-FFI-MILESTONE-1.md): the Float64 is
rounded to binary32, ties to even, and an overflow is `NonFiniteFloat`
before C runs or a byte is written. The game crosses it at:

* **`SDL_FRect` fields**, through native memory: `sdl::fill` writes x, y,
  w and h of the scratch `SDL_FRect` with `std::binary::store(e,
  sdl3::layouts::SDL_FRect.x, x)` (the generated layout's `std::ffi::c::Float`
  fields: four 4-byte stores, each narrowed), then calls
  `SDL_RenderFillRect`. About 21 rectangles a frame: 85 narrowed stores.
* **Arguments**: `SDL_RenderLine(renderer, x1, y1, x2, y2)` (34 a frame:
  the walls' mortar lines), `SDL_RenderDebugText(renderer, x, y, text)`
  (5 a frame), `SDL_SetRenderScale(renderer, sx, sy)` (the 2x banner).

Nothing the game computes in DecimalRounded reaches C, and nothing could:
a DecimalRounded value is no C type, and only its explicit decay is a
Float64.

> **Since this milestone:** ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md moved
> SDL's objects behind the `sdl::Sdl` context. The line counts above, the
> `run(video, ...)` loop below and the Video threading of "Resource
> lifetime" describe the vertical slice as it was built (commit 6df89a8e);
> the game now loops over the world alone, and sdl.bot's operations take
> and return values only. Behavior, rules and SDL calls are unchanged.

## The game loop and timing

```
main ─ options::parse(argv) ─┬─ --headless: tower::new_world(seed).simulate(frames) ─ summary
                             └─ play: sdl::open ─ run(video, world, 0, now, options) ─ sdl::close ─ summary
run(video, world, frames, last, options):          (self-tail-recursive: a loop natively)
    limit reached?            -> Ended {video, world, frames, ""}
    video.poll(keys)          -> Polled {video, quit, held, failure}    (events, keyboard state)
    quit or Escape?           -> Ended
    input                     =  autopilot(world) or the held keys
    now                       =  sdl::seconds()                         (SDL_GetTicksNS)
    dt                        =  now - last, or 1/60 with --fixed-step
    next                      =  world.step(input, dt)                  (dt clamped to [0, 0.05])
    video.draw(next)          -> Drawn {video, synced, failure}         (render, present)
    pace                      =  sleep out the 60 Hz frame unless vsync paces it
    run(video, next, frames + 1, now, options)
```

* **The world is a value replaced each frame.** No mutable state is
  needed anywhere: `step` returns a new `World`, and the loop is a
  self-tail-recursive function, which the native backend compiles to a
  loop (`hir::aot::selfTailCalls`). That worked first time and reads well;
  immutable values were no obstacle to a real-time loop.
* **A bounded variable step.** `dt` is the clock's frame length, clamped
  to [0, 0.05] in `step`: a stalled frame (a breakpoint, a dragged window)
  moves nothing further than a 20 Hz frame would, and a clock that goes
  backwards moves nothing (`icy-a-stalled-frame-counts-as-max-dt`,
  `icy-a-negative-frame-moves-nothing`; the `no-dt-cap` mutant is
  killed). Motion integrates velocity first, then position
  (semi-implicit Euler). There is no fixed-step interpolation: the
  collision test cannot tunnel (next section), so nothing needed one.
* **Pacing.** The renderer asks for vertical sync; with it,
  `SDL_RenderPresent` waits for the display (measured: 1517-1525 frames in
  25 s under Xvfb, 60 Hz). Without it the loop sleeps out the rest of a
  60 Hz frame (`SDL_DelayNS`). `--fixed-step` (the smoke runs) asks for no
  vsync and does not sleep: the run goes as fast as it can, every frame
  1/60 s long, so its result is the headless run's.
* **Deterministic modes.** `--headless --frames N` runs the autopilot
  (`tower::autopilot`, a deterministic player that steers toward the
  platform it falls onto or the next one above, and restarts a lost game)
  for N fixed frames with no SDL at all. `--autopilot --fixed-step
  --frames N` runs the same frames through the real SDL loop. Both print
  the same summary line for the same seed.

## The collision algorithm

```
lands_on?(p, before, after) =
    after.vy < 0                           # falling
    and before.y >= p.y and after.y <= p.y # the feet crossed the top this frame
    and after.x + 26 > p.x and after.x < p.x + p.width   # horizontal overlap (strict)
```

A frame's motion is a segment from `before` to `after`; a landing is the
crossing of a platform's top while falling, whatever the frame's length or
the speed, so nothing tunnels through a platform
(`icy-no-speed-tunnels-through-a-platform`: a fall from 900 to -900 in one
step lands). Among the platforms crossed in one frame the highest is
landed on (`landing` searches from the top down;
`icy-lands-on-the-highest-platform-crossed`). A player rising through a
platform never lands on it, so it can jump up through platforms from
below, as in Icy Tower. Landing puts the feet exactly on the top and sets
the bounce speed, so the next frame starts above the top moving up: no
repeated landing, no jitter. Edges that only touch are no overlap. Each
rule has a test and a mutant (`collision-ignores-descending`,
`landing-on-lowest-crossed`, `touching-edges-overlap`).

## Platform generation

A 32-bit linear congruential generator (`state * 1664525 + 1013904223 mod
2^32`, Numerical Recipes' constants) whose high 16 bits make a fraction in
[0, 1). The world's `rng` is the generator's state; a seed is a tower. For
the floor above `below` (floor f, level = min(f, 200)):

```
gap   = 72 + 0.14 level + r1 (44 + 0.03 level)          # 72..150: at most 150 < 176, a standing bounce
width = every 25th floor: the whole inner width (440)
        else max(200 - 0.6 level, 80) x (0.6 + 0.4 r2)   # narrower higher up, at least 48
x     = 20 + r3 (440 - width)                            # inside the walls
```

Platforms are kept in ascending order. Each frame `grown` adds platforms
above the highest until one is above the view's top edge plus 200, and
`pruned` drops those more than 120 units below the view's bottom edge --
but rebuilds the list only when the lowest platform is to go (not every
frame), and always keeps the highest, the one the next is placed above
(section "Bugs found and fixed"). About 10 to 12 platforms are alive at a
time. Tests: every gap climbable and every platform inside the walls over
five seeds and 25,000 units; milestone floors span; the first floors of
seed 7 exact (against the oracle); the generator's first values (Numerical
Recipes' published constants).

## The camera

`camera.bottom` is the altitude at the view's bottom edge; the renderer's
one conversion is `row(y) = 720 - (y - camera.bottom)`. Nothing in the
world moves for the camera. Each frame:

```
rising = camera.rising or best >= rise_height()          (a DecimalRounded comparison, at 1 place)
risen  = camera.bottom + (rising ? rise_speed(floor) dt : 0)
bottom = max(risen, player.y - 0.55 x 720)               # follow up at once, never down
```

Tests: the camera follows up, waits below the follow line, never moves
down, starts rising exactly at the displayed 6.0, rises at its cap; the
`camera-follows-down` mutant fails ten tests.

## Resource lifetime

> Superseded by ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md: the session now
> lives in the installed `sdl::Sdl` context and `sdl::close` needs no value.
> That census also found the affine Video's cleanup guarantee weaker than
> stated below: an affine value may be dropped, and `play` dropped its Video
> without closing SDL on two (unreachable) error paths.

`sdl::open` makes, in order: a 128-byte text buffer (`SDL_malloc`),
`SDL_Init(SDL_INIT_VIDEO)`, the window, the renderer, a scratch
`SDL_FRect` and a 128-byte `SDL_Event` (`SDL_malloc`), takes the keyboard
state, sets the letterboxed logical presentation and asks for vsync. A
failure at any step logs SDL's error and releases everything made before
it, in reverse, `SDL_Quit` included (`workload-icy-tower-executable-sdl-
failure`: an unknown video driver fails `SDL_Init`;
`-renderer-failure`: an unknown render driver fails `SDL_CreateRenderer`
after the window exists; both exit 1 with SDL's message).

The pointers live in one `sdl::Video` value. C pointers are affine
(C-ABI-TYPES.md), and so is a struct holding them: reading a field would
make a second owner, so `poll` and `render::draw` take the Video whole,
destructure it, use clones of its pointers, and hand it back rebuilt in
their result; `run` threads it from frame to frame; every way out of the
loop -- the frame limit, Escape, the window's close, a failure -- returns
it in `Ended`, and `sdl::close` consumes it: free the scratch memory,
destroy the renderer and the window, `SDL_Quit`. valgrind's memcheck over
a whole dummy-driver run finds no invalid access and nothing lost
(`workload-icy-tower-executable-no-leaks`). Restart replaces the `World`
only: SDL stays up, and a new game is a new value.

There is no automatic release: a C pointer owns nothing (C-ABI-TYPES.md,
"Affinity is not ownership"), so closing is written, and the affine rules
make sure the program holds exactly one Video when it does. That the
types forced every exit path to carry the Video back is the affine model
paying its way.

## SDL APIs exercised

24 functions of SDL 3.4.18, all through the committed generated binding
(`generated/c/sdl3/linux-x86_64/sdl3/`), none declared by hand:

| area | functions |
|---|---|
| init, quit | `SDL_Init`, `SDL_Quit` |
| window, renderer | `SDL_CreateWindow` (its title exposed as a NUL-terminated Bytes, the profile's contract), `SDL_CreateRenderer`, `SDL_SetRenderLogicalPresentation`, `SDL_SetRenderVSync`, `SDL_DestroyRenderer`, `SDL_DestroyWindow` |
| events, keyboard | `SDL_PollEvent` (into native memory, its type read through a layout), `SDL_GetKeyboardState` (a C bool array read through a layout) |
| drawing | `SDL_SetRenderDrawColor`, `SDL_RenderClear`, `SDL_RenderFillRect` (an `SDL_FRect` of C floats in native memory), `SDL_RenderLine` (C float arguments), `SDL_RenderDebugText` (C floats and a C string in native memory), `SDL_SetRenderScale` (C floats), `SDL_RenderPresent` |
| time | `SDL_GetTicksNS`, `SDL_DelayNS`, `SDL_GetPerformanceCounter` (the default seed) |
| memory | `SDL_malloc`, `SDL_free` |
| errors | `SDL_GetError`, `SDL_Log` (a variadic C call: the error string is its trailing argument) |

and the generated constants `SDL_INIT_VIDEO`, `SDL_WINDOW_RESIZABLE`,
`SDL_LOGICAL_PRESENTATION_LETTERBOX`, `SDL_EVENT_QUIT`, six
`SDL_SCANCODE_*`, and the generated layout `sdl3::layouts::SDL_FRect`.
Measured per frame (callgrind): 89 C calls from the program into SDL --
34 `SDL_RenderLine`, 23 `SDL_SetRenderDrawColor`, 21.3
`SDL_RenderFillRect`, 5.3 `SDL_RenderDebugText`, 1.3 `SDL_SetRenderScale`,
one each of present, clear, poll and the clock.

**Authority.** A call that hands SDL a pointer whose escape no contract
states (the renderer, the window, the scratch memory) is a retaining C
call, raw ambient authority (DIRECT-MODULES.md), and so is making a native
view or edit. `sdl.bot` declares an opaque context, `Sdl`, and every
function of it that makes such a call requires it, so its raw calls are
all *mediated* by its own context: `sdl` is a contextualized module, and
`render`, `main` and the pure modules are ordinary
(`hir::direct::summary`; `workload-icy-tower-sdl-modules-warning-clean`
pins it). The entry program installs the capability, `with context
sdl::authority()`, beside `std::linux::io`'s. No module of the game is
`direct module`.

## Build, link and the executable

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml   # once
examples/games/icy-tower/build.sh                          # -> audit/icy-tower/artifacts/icy-tower
```

`build.sh`:

1. builds the package-owned `libSDL3.so` once (`tests/cffi/sdl3.tcl`: the
   release the binding profile pins, 3.4.18, with CMake and Ninja, into
   Botlish's cache, headless by default -- for a window, build it with
   your desktop's video drivers: `BOTLISH_SDL3_DIR=DIR
   BOTLISH_SDL3_CMAKE_FLAGS="" tclsh9.0 tests/cffi/sdl3.tcl`);
2. stages the game's `.bot` files and the committed generated binding of
   the host's target into one application root (`tools/c-bindgen.tcl
   stage`; an application imports only the files beside it);
3. compiles it with `main.tcl -warnings error -emit-native-executable -L
   SDLDIR` (Cranelift code, linked by rustc with the platform linker and
   `-lSDL3`) and strips it.

About 30 s on a 4-core container: 13 s of front end (the program loads 60
files, most of them the binding's modules), the rest code generation and
the link.

**The artifact.**

| | |
|---|---|
| path | `audit/icy-tower/artifacts/icy-tower` (committed; rebuilt by `build.sh`) |
| target | `x86_64-unknown-linux-gnu` (Botlish target `linux-x86_64`) |
| kind | ELF 64-bit PIE executable, dynamically linked, stripped, 960,448 bytes |
| needs | `libSDL3.so.0` (SDL 3.x; built and tested with 3.4.18, soname `libSDL3.so.0`), `libc.so.6` (glibc >= 2.34), `libm.so.6`, `libgcc_s.so.1` |
| rpath | none: Botlish adds no rpath (C-FFI.md); the loader finds SDL on the system path or `LD_LIBRARY_PATH` |
| assets | none: nothing has to stay beside it; it runs from any directory |
| environment | none required; `SDL_VIDEO_DRIVER=dummy` runs it without a display, and `BOTLISH_NATIVE_GC_STRESS=1` works as for every executable |

Even `--headless` needs `libSDL3.so.0` at load time: the executable is
linked against it.

**Running it.**

```sh
# with SDL 3 installed system-wide (a distribution's libSDL3.so.0; the game
# calls only functions SDL 3.2.0 has, but only 3.4.18 has been tested)
audit/icy-tower/artifacts/icy-tower
# or with an SDL 3 built for your desktop (above)
LD_LIBRARY_PATH=DIR audit/icy-tower/artifacts/icy-tower --seed 7

# no display: the deterministic runs
LD_LIBRARY_PATH=DIR audit/icy-tower/artifacts/icy-tower --headless --frames 600 --seed 7
LD_LIBRARY_PATH=DIR SDL_VIDEO_DRIVER=dummy audit/icy-tower/artifacts/icy-tower --autopilot --fixed-step --frames 600 --seed 7
```

Options: `--seed N` (default: the performance counter when played, 7 when
headless), `--frames N`, `--headless`, `--autopilot`, `--fixed-step`,
`--help`. A run prints its summary line as the program's value; a usage
error exits 2, an SDL failure 1 (after its message), otherwise 0.

**Window and display.** A resizable 480 x 720 window (portrait 2:3, fits a
1080p screen with its title bar); the renderer shows a 480 x 720 logical
view letterboxed into it, which is also the one high-DPI policy: SDL scales
the logical view to the window's pixels.

## Results

### Headless smoke

```
$ icy-tower --headless --frames 600 --seed 7
"frames=600 round=1 floor=26 score=260 best=29.1 time=10.0 over=no x=263 y=2947 camera=2551 platforms=11 rng=3699965314"
```

The same line from `headless.bot` on interp, compile, cranelift-generic and
cranelift, from `oracle.py summary 7 600`, and from the real SDL loop on the
dummy driver (`--autopilot --fixed-step --frames 600 --seed 7`), also under
`BOTLISH_NATIVE_GC_STRESS=1`. 6000 headless frames take 187 ms (31 us a
frame); 3000 dummy-driver frames 1.78 s (0.59 ms a frame, SDL's software
renderer included).

### The graphical run

Performed in this environment under Xvfb (a virtual X server) with an SDL3
built with its x11 driver (`audit/icy-tower/tools/xvfb-session.py`):

* **keyboard**: Right held 0.45 s moved the player from x = 320 to 482,
  Left held 0.9 s back to 162 (the player found in screenshots by its
  color); Escape ended the run, exit 0;
* **real time**: the autopilot played 1517-1525 frames in 25 s, the
  display's 60 Hz through vertical sync, losing and restarting a game on
  the way;
* **window close**: `WM_DELETE_WINDOW` sent as a window manager would
  ended the run cleanly through `SDL_EVENT_QUIT`, exit 0;
* the screenshots (top of this report) show the walls, platforms, the
  milestone floor with its number, the player and the HUD.

No physical display and no human player were involved: the game has not
been judged for feel on real hardware. The x11 driver, the renderer, the
input and the timing paths it uses are the ones a desktop run uses.

### Tests

| what | result |
|---|---|
| `golden.bot`, 65 tests (motion 10, collision 18, camera 8, platforms 9, games 10, text 6, options 4), on interp, compile, cranelift-generic, cranelift | 65 passed on each, one report |
| `tests/workload-icy-tower.test`, 15 tests | 15 passed (8 need the package-owned libSDL3; skipped without it) |
| `oracle.py compare` (8 seeds x 1, 60, 600, 3600 frames) | 0 differences |
| `audit/icy-tower/mutate.tcl`, 26 mutants | 26 killed |
| `xvfb-session.py` | 6 checks passed |
| valgrind memcheck, 30 frames on the dummy driver | 0 errors, 0 bytes lost |
| affected suites (`tests/local.tcl` on float64, decimal-rounded, stdlib-namespaces, c-float-ffi, both workloads, golden float64.bot and decimal-rounded.bot) | all passed |
| warning gate, Compilerpedia check | passed |

The mutants include the brief's six (collision ignores the descending
condition; camera follows downward; gravity reversed; removal threshold
wrong; score decreases; restart keeps a stale velocity) and twenty more:
the dt cap, the highest-crossed rule, strict overlap, the run-up bonus,
the wall rebound, friction through zero, the displayed threshold, the
game-over margin, the record, unclimbable gaps, milestone floors, pruning
the highest platform, the generator's bits, the autopilot, three text
bugs, two command-line bugs. Two survived the first run (friction was only
tested on the negative side; pruning was only checked after two frames):
the tests were strengthened, not the mutants weakened.

## Performance and allocation

`tclsh9.0 audit/icy-tower/tools/perf.tcl` measures three things.

**1. The rules** (headless, the native runtime's allocation accounting,
README section 22), per steady-state frame: 36.7 managed objects, 815
bytes: 31.5 boxed Float64s (504 B), 4 structs (the new Player, Camera,
World, Landing), 1 DecimalRounded (the quantized height). One collection
per ~1200 frames; the worst pause seen 1.6-3.2 ms (the whole heap is 1 MB
at peak). The first version allocated 70.5 objects a frame: `xs.get(i,
nowhere())` builds its default on every call, and the platform searches
called it per element (16 sentinel structs a frame). Reading an index known
to be in range with `at`, the impossible miss handled, removed them
(section "Bugs found and fixed").

**2. The whole frame** (callgrind over an unstripped build, the difference
between 60- and 240-frame runs). The in-process accounting cannot run a
program that calls C -- such a program runs as a linked executable -- so
the frame is measured from outside:

| per frame | headless | dummy driver |
|---|---:|---:|
| instructions, all | 220,648 | 2,140,590 |
| in libSDL3 (software rendering) | -- | 1,453,152 (67.9 %) |
| in the program | 185,785 | 486,932 (22.5 %) |
| of which big integers (num_bigint) | 121,704 (65.5 %) | 251,816 (51.7 %) |
| of which runtime helpers | 57,966 | 181,998 |
| of which generated code | 2,265 | 26,032 |
| collector | -- | 8,596 |
| malloc (program) | 170.5 | 524.9 |
| Float64 boxes (`Vm::new_float`) | 30.9 | 198.2 |
| DecimalRounded quantizations (`decimal::represent`) | 1 | 2 |
| `decimal::round_at` calls | 117 | 239 |
| C calls into SDL | 0 | 89 |

Read:

* **Boxed Float64 is not a problem at this scale.** 198 boxes a frame, 60
  frames a second, is 12,000 small allocations a second; the collector
  runs about once every 20 seconds of play. No optimization was needed for
  playability, so none was made: the scalar-replacement roadmap stands as
  it is (FLOAT64-MILESTONE-1.md, section 14). Drawing boxes about 165 of
  them: every coordinate render.bot computes (`row(y)`, `x + 6.0`, the
  text positions) is a fresh boxed Float64 on its way to a C float.
* **The surprise is DecimalRounded.** One `std::decimal_rounded::round` per frame
  (the best height) is two thirds of the program's own instructions in a
  headless frame -- twice the whole physics -- and the HUD's two more
  (the timer's quantization and two decays) make big integers half of the
  program's work in a full frame. The cause is `decimal::represent`
  (native/src/runtime/decimal.rs): it ranks three binary64 candidates by
  `proven`, which walks the precisions 0, 1, 2, ... until the candidate's
  and the true value's roundings differ, each step two `round_at`s with
  fresh big-integer powers of ten: ~117 big-integer roundings for one
  quantization, each a few mallocs. About 40 us a frame here, so not a
  playability problem -- but the obvious first target for a DecimalRounded
  performance pass (a closed form for the proven precision, or a
  machine-integer fast path for small magnitudes), recorded, not done.
* **The FFI is cheap.** 89 SDL calls a frame are a small part of the
  program's cost; the generated foreign calls are direct calls with their
  float narrowing inline, and nothing is boxed for the call itself.
  Writing an `SDL_FRect` through a native edit is four stores. Batching
  (`SDL_RenderFillRects` over an array layout) was not needed.
* **SDL's software renderer dominates** a dummy-driver frame (68 %); on
  the x11 driver vsync paces the loop at 60 Hz with the CPU mostly idle.

**3. Time**: 31 us a headless frame, 0.59 ms a dummy-driver frame.

## Stdlib

### The addition: `std::float64::min`, `max`, `abs`, `clamp`

`stdlib/float64.bot`, ordinary Botlish members of the `float64` namespace
beside its intrinsics (as `stdlib/list.bot` is `list`'s).

* **Why the game needed them**: clamping the frame length, capping the
  run speed both ways, friction that stops at zero, the bounce's |vx|, the
  camera's "never down", the platform width's floor -- nine uses.
* **Why existing facilities were insufficient**: Float64 has comparisons
  and nothing else; each use would be a four-line `if` returning one of
  two values.
* **Why the stdlib**: every program that bounds a Float64 writes them;
  they are type-specific (Botlish has no generic ordering to write one
  `min` for every type), and they cannot fail -- a comparison and at most a
  negation -- so unlike any arithmetic helper they add no `NonFiniteFloat`
  to their callers. `min` and `max` are `nomethod` (symmetric operands, the
  `bit_and` precedent). Compilerpedia documents them (the generated stdlib
  topic, the floats concept); the warning gate lists the module.

### What was missed and not added

| missing | what the game did | where it belongs |
|---|---|---|
| Int to String | `hud::int_text`, digit by digit by subtraction (no integer division); the third copy in the repository (stdlib/test.bot, the 2048 demo) | a `str` or `int` intrinsic: the most-requested stdlib function so far |
| String to Int | `options::number`, digit by digit | the same |
| Float64 to the nearest Int | `hud::nearest` over `truncate` | `std::float64::round` (half away from zero, or to even) |
| DecimalRounded to String | decay, x10, nearest, spell the tenths (`hud::metres_text`) | a DecimalRounded display at its guaranteed precision: the type's whole point is that it knows its digits |
| a random number generator | a 32-bit LCG in tower.bot (`next_random`, `fraction`) | a small seeded PRNG module with an explicit state value |
| the process exit status | `extern c fn exit(status: std::ffi::c::Int)` from libc, declared in main.bot (Compilerpedia already lists the exit status as absent: `capability.process-exit-status`) | a process module |
| a String from a C string | none: SDL's error text reaches the user only through `SDL_Log` | a `str` decoder from bytes (with a byte view of native memory) |
| Float64 text in test failures | `stdlib/test.bot` describes a Float64 as "a value with no text form", so a failed float comparison is unreadable | follows Float64-to-String |
| time, durations | Float64 seconds from `SDL_GetTicksNS` | later |
| reverse iteration, a last element, a search with no default | `at` with a handled miss and `break` | the list module |

## FFI

What worked, unchanged, first time: generated extern declarations,
constants and layouts; C floats in arguments and layout fields; native
memory written and read through generated and hand-written layouts; a
variadic C call (`SDL_Log`); a profile contract exposing a Botlish Bytes
(`SDL_CreateWindow`'s title); linking with `-lSDL3` into an executable;
the direct-module accounting of retaining calls, mediated by a context.

What was awkward:

* **`SDL_Event` has no layout**: its alternatives hold C `bool` fields,
  which no layout field represents (C-BINDGEN.md, "c-bool"). The game
  declares `layout EventType` (the event's `Uint32 type` at offset 0, which
  every alternative shares) and reads only that; a keyboard *event* cannot
  be read at all, so the game reads the keyboard *state* instead (fine for
  a game, but it rules out text input or key-repeat). The keyboard state is
  itself a C `bool` array, read through `layout KeyState` as `array 512 of
  std::ffi::c::UChar`.
* **No Botlish storage for a non-byte pointee.** A Bytes can be lent to a
  C call only for a byte-sized pointee (C-POINTER-BORROWING.md); an
  `SDL_FRect*` is not one. So rectangles go through native memory the game
  allocates with `SDL_malloc`, `retype`s to `Ptr[SDL_FRect]` and writes
  through `std::binary::native::edit` before each call -- correct, explicit and
  cheap, but it puts native memory management (and direct authority) into
  a program that only wanted to pass a rectangle.
* **`SDL_RenderDebugText`'s string has no contract**, so a String reaches
  it through a native char buffer written character by character
  (`std::binary::store_element`), not as an exposed Bytes; a profile contract
  (`str {read noescape}`: SDL reads it during the call) would have let the
  game pass bytes, as the window title does. Not added: changing the
  profile regenerates the committed bindings of every target.
* **Affine pointers in Botlish functions.** An extern call observes a
  pointer, but a Botlish function's parameter takes it: every helper call
  moves its pointers, so call sites clone (57 `.clone()` in sdl.bot,
  render.bot and main.bot), and a struct holding pointers is destructured
  and rebuilt to be used at all (`AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE`).
  A pointer an extern call should observe cannot be a temporary either:
  `SDL_GetKeyboardState(std::ffi::c::null[std::ffi::c::Int]())` is
  `AFFINE-TEMPORARY-UNSUPPORTED` (bind the null pointer first).
* **The binding must be staged.** An application imports only the files
  beside it (IMPORTS.md: two roots, no search path), so the generated
  binding is copied beside the game for every build (`tools/c-bindgen.tcl
  stage`); the game's own directory cannot be compiled as it is.
* **No rpath.** The executable finds `libSDL3.so.0` only on the system path
  or `LD_LIBRARY_PATH`.

## Bugs found and fixed

| where | bug | found by | fix |
|---|---|---|---|
| `tests/cffi/sdl3.tcl` (tooling) | on a machine without the SDL source, `fetch` prints its progress line before the checkout's path, and the script used the whole output as the source directory: the first build always failed | building SDL for this milestone | take the last line of the fetch's output |
| tower.bot (application) | `pruned` could drop every platform when the camera moved far up in one frame, and `grown` then rebuilt the tower from the sentinel at y = -1,000,000 (10,000 platforms) | a golden test (`icy-the-tower-grows-and-sheds-as-the-camera-climbs`) | always keep the highest platform; the `prune-drops-highest` mutant pins it |
| tower.bot (application) | 16 sentinel structs allocated a frame by `get`'s eagerly evaluated default | the allocation report | `at` with the impossible miss handled |
| the test harness (my own) | `array unset ::env` unlinks Tcl's `env` from the process environment, so later overrides never reached a child process | a test passing where it should fail | restore each variable separately (`withEnv`) |
| `hir/completions.tcl` (compiler) | `ExactCopy`'s `handle` case asked `hir::typeOf` for a handler *body* -- a list of statement ids -- as if it were one expression: a front-end crash (`key "e21 e23" not known in dictionary`, TCL LOOKUP DICT) for any program that reads a field, in a condition, of a struct bound from a handled call whose handler has more than one statement. The code predates this milestone; main's List length refinements made type inference reach it from every projection, and main.bot's `o = options::parse(...)` / `if o.help:` is exactly that shape | building the executable after merging main | read the body's last statement, as the same file's other `handle` walk does; `tests/list-length-refinement.test`'s `llr-projection-of-a-handled-call` (a 20-line reproducer, fails without the fix) |

No other compiler or runtime bug: every backend agreed with every other
and with the oracle, the executable was clean under GC stress and
memcheck, and the AOT, dummy-driver and X11 runs behaved identically.

## What Icy Tower taught us about Botlish

**Application problems** (the game's, fixed in the game): the eager `get`
default as an allocation hot spot; the pruning edge case; the start banner
hiding the player from the screenshot checks.

**Missing library convenience**: Int to String and back, Float64 rounding,
DecimalRounded display, a PRNG, an exit status, C-string decoding, Float64
text in test reports. Each cost a small hand-written routine and none
blocked anything. Int-to-String has now been written three times in the
repository; it should be next.

**Language-design friction**, in the order it cost:

1. **Fallible floating point everywhere.** 40 of 90 functions declare
   `NonFiniteFloat`; the golden suite has 31 handlers, because a test body
   may declare no error; several fallible steps returning the same
   sentinel trip `SAME-RETURN-VALUE`, which pushes test helpers into inner
   functions. The rule is principled and caught nothing here, because
   nothing could overflow; ranges for Float64 (the analog of Int domains)
   are what would let the compiler prove that and remove most of the
   clauses.
2. **Affine pointers in ordinary code.** Moving into every Botlish callee,
   no observing parameter, no field read of a pointer-holding struct, no
   temporary given to an observing extern call. The Video threading that
   results is correct and made cleanup total, but it is the most
   ceremony in the program. (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md: the
   ceremony was the application's architecture -- with the session behind
   the `sdl::Sdl` context none of it remains above sdl.bot, and no
   observing parameter is needed; nor was the cleanup total.)
3. **Names for types and values**: no type aliases (DecimalRounded spelled
   out ten times), no struct values at module level (the sentinel had to be
   a function), no struct update syntax (`World` rebuilt with all nine
   fields in `step`, and in every test helper that changes one). And a
   List of an integer domain's values does not prove a `List[int]`
   result: `fn codes() -> List[int]: [one(), one()]` with `one() ->
   std::ffi::c::UInt` (or any `type Small = Int in 0..9`) is "function result
   does not prove declared type List[int]", though `-> int` of one such
   value is accepted, so `scancodes()` is declared `List[std::ffi::c::UInt]`.
4. **Method sugar and its warnings**: a helper named like a module
   function makes method calls ambiguous (`moved`, `landing`, `step`,
   `summary` had to be renamed in the suite); `METHOD-ELIGIBLE` pushes
   receiver syntax where the first argument is no receiver
   (`now.frame_length(last, o)`), answered with `nomethod` or rewrites;
   `ONE-CHAR-STRING-LITERAL` turns `"-"` into `"".append_char('-')`.
5. **Small ones**: no forward references (callees first), `unit` and
   `errors` reserved as names, a handler attaches to a call or an operator
   but not to an `if` choosing between two calls.

What did *not* hurt: immutable values in a real-time loop (a new World a
frame, a self-tail-recursive loop compiled to a loop); structs and lists
for game state; deterministic floating point across backends; error
handling at the loop's edge; contexts for capabilities.

**Compiler correctness**: one front-end crash, reachable only after
main's List length refinements and fixed here (`ExactCopy`); a real
application found it within an hour of the merge, which no test of the
refinements had.

**Compiler and runtime performance**: boxed Float64s (fine at this
scale, ~200 a frame); DecimalRounded quantization through big-integer
precision walks (the top cost of the program); the in-process allocation
accounting not reaching programs that call C; a 13 s front end for a
program whose binding is 57 generated modules.

**FFI**: C bool blocking `SDL_Event`; no lending of Botlish storage to a
non-byte pointee; missing contracts in generated bindings (a string SDL
only reads); staging the binding into every application; no rpath. The
core -- extern calls, C floats, layouts over native memory, variadics,
direct-module accounting -- held up under a real library with no change.

## Completion criteria

| criterion | evidence |
|---|---|
| builds from Botlish source with the generated SDL3 binding | `build.sh`; `workload-icy-tower-executable-builds`; CI |
| a Linux executable artifact | `audit/icy-tower/artifacts/icy-tower` |
| starts and runs its loop | the X11 session (1517-1525 frames in 25 s); dummy-driver tests |
| left/right movement | `icy-run-*`, `icy-*-wall-*`; X11 keyboard session |
| gravity | `icy-gravity-*` |
| landing and bouncing | the 18 collision tests (`icy-lands-*`, `icy-bounce-*`, ...) |
| platforms continue above | `icy-the-tower-grows-*`, `icy-a-new-tower-*`, 3600-frame oracle runs |
| camera scrolls up | `icy-camera-*`, `icy-tower-rises-*` |
| score/height increases | `icy-landing-on-floor-3-scores-30`, `icy-best-height-*`, summaries |
| falling ends the game | `icy-falling-below-the-view-ends-the-game`, `-margin-` |
| restart | `icy-restart-*`; rounds > 1 in long runs |
| SDL resources released | `-no-leaks` (memcheck), `-sdl-failure`, `-renderer-failure`, the window-close session |
| deterministic mechanics tests | 65 golden tests on 4 backends, the oracle |
| headless/dummy executable smoke | `-headless`, `-dummy-driver`, `-gc-stress`, `-restarts` |
| Float64, std::ffi::c::Float, DecimalRounded exercised | section "The numerical model" |
| friction inventoried | sections "Stdlib", "FFI", "What Icy Tower taught us" |

## Android

Not attempted beyond establishing how far the toolchain gets, because
the answer is "not far without a port":

* **Stage reached**: the front end compiles the whole game, SDL modules
  included, for `-target linux-aarch64` against the committed
  linux-aarch64 SDL3 binding, warning-free, and writes its HIR interchange
  file. That is where it stops.
* **Botlish target**: there is no Android target (`core/cabi.tcl`'s table
  has Linux, macOS and Windows rows; Android is Linux's kernel with bionic,
  a different C library, its own data model facts and its own SDL headers),
  so neither the compiler nor the binding generator can name one.
* **Native code**: code generation and executables are for the host's own
  target only (`NATIVE TARGET` for anything else); there is no cross
  compilation, and no shared-library output. SDL's Android integration
  loads the game as `libmain.so` from its Java activity and calls an
  exported `SDL_main`; Botlish emits only executables whose `main` is the
  runtime's own startup.
* **Runtime**: the native runtime's Linux platform layer is glibc's (the
  stack guard's discovery, startup); bionic needs its own.
* **Tooling**: no NDK or Android SDK is installed here (Java and Gradle
  are); the SDL Android project template, Gradle and the NDK would be
  needed even with the compiler ready.
* **Whose blockers**: the target and the shared-library output are
  Botlish's (compiler and runtime); the build is tooling. SDL itself is
  not a blocker.
* **The smallest plausible follow-up**: an `android-aarch64` target row and
  a binding generated for it; native code generation for a non-host target
  (cross compilation) with an object-file output; a shared-library link
  mode exporting `SDL_main`; then the Gradle project around it. That is a
  platform milestone of its own, not a bonus.

No APK artifact exists.

## Follow-ups, in the order this application would rank them

1. Int to String (and String to Int) in the stdlib.
2. DecimalRounded: a display at the guaranteed precision, and a cheaper
   `represent` (the proven precision without a precision walk).
3. Float64 ranges, so bounded simulations need no `NonFiniteFloat` clauses.
4. A way to read a pointer field without consuming its struct (or an
   observing parameter mode) for affine C pointers. (Withdrawn by
   ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md: unnecessary once SDL's objects
   live behind a context; what that census found missing instead is a way
   for a context to own affine members.)
5. Type aliases for scalar refinements; struct values at module level;
   struct update syntax.
6. Generated bindings: contracts for read-only string parameters
   (`SDL_RenderDebugText`), and a story for C `bool` fields in layouts.
7. Allocation accounting for programs that call C (an executable mode).
8. A process exit status; a seeded PRNG module; Float64 rounding.

## What to run when changing this

AGENTS.md, "Workloads (examples/games/icy-tower)": `tests/workload-icy-
tower.test` (with the package-owned libSDL3.so built, for its executable
tests), `audit/icy-tower/mutate.tcl`, `python3 audit/icy-tower/oracle.py
compare EXECUTABLE`, and, for the window, `audit/icy-tower/tools/xvfb-
session.py`; `audit/icy-tower/tools/perf.tcl` for the numbers above. A
rule change changes this report's rules, the oracle and the golden
expectations together, and the committed executable is rebuilt
(`build.sh`) in the same change.
