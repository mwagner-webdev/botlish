# Variant B-prime ("ids"): retained SDL state without native-memory handles

Part of ICY-TOWER-CONTEXT-REFACTOR-CENSUS. `sdl.bot` here is a drop-in
replacement for the context-refactored `examples/games/icy-tower/sdl.bot`
(commit 4be79514, called "the working tree" or "wt" below; it was the
uncommitted working tree when this variant was written). It has the same
operations and the same `Sdl` context, but the context keeps no pointer and
no native memory. The baseline is the pre-refactor game, commit 6df89a8e
(HEAD~1 now), which threaded an affine `sdl::Video` through the frame loop.

## The design

| | working tree (4be79514) | ids variant |
|---|---|---|
| Context | `opaque context struct Sdl: open: MutableVector[Session]` | the same |
| Session | `{handles: NativeView[Handles], synced: bool}` | `{window: std::ffi::c::UInt, synced: bool}`, the SDL_WindowID from `SDL_GetWindowID` |
| Native memory retained | a 56-byte `Handles` record (window, renderer, keys, rect, text, event, the record's own address), plus a 16-byte rect, a 128-byte text buffer and a 128-byte event, all SDL_malloc'd by `open` | none |
| Window, renderer | read back through the view | `SDL_GetWindowFromID(id)`, then `SDL_GetRenderer(window)`, on every operation |
| Keyboard state | pointer kept in `Handles` | `SDL_GetKeyboardState(NULL)` on every poll, read through one `KeyState` view |
| Scratch memory | allocated once by `open`, freed by `close` | allocated and freed by each call that needs it: `fill` (SDL_FRect), `text` (text buffer), `poll` (SDL_Event), `log_failure` (format string) |

Both modules keep the same public operations, with identical names,
parameter and result types and declared errors: `create`, `open`, `close`,
`synced?`, `poll` / `Polled`, `seconds`, `sleep`, `counter`, `color`,
`clear`, `present`, `fill`, `line`, `text`, `scale`, `Sdl` and `SdlFailed`.
`render.bot` and `main.bot` compile against the variant unchanged. The staged
copies were compared byte for byte with the working tree's.

A module has no private members, so the helper functions are public too, and
there the two modules differ (no game module calls any of them):

* wt: `write_text(buffer: Ptr)`, `log_failure(buffer: Ptr, call)`,
  `free_text(Ptr)`, `release(window, renderer, rect, text, event, failure)`,
  `remember(NativeEdit[Handles], 7 pointers)`, `quit_requested?(event: Ptr)`,
  `down?(keys: Ptr, scancode)`, and the layout `Handles`.
* ids: `write_text(buffer: Ptr)` and `quit_requested?(event: Ptr)` as in wt;
  `log_failure(call)` (no pointer); `free_text`, `free_rect`, `free_event`
  (each takes a Ptr); `release(window, renderer, failure)`;
  `store_rect(NativeEdit[SDL_FRect], x, y, w, h)`. There is no `Handles`,
  `remember` or `down?`.

No ids helper returns a pointer. Each operation finds the renderer itself
instead of calling a shared `renderer()` helper, because such a helper would
be public and would hand any importer the renderer pointer.

### Failure messages and release order

| Path | wt | ids |
|---|---|---|
| SDL_Init fails | log, free text buffer, fail `SDL_Init` | log (its buffer allocated and freed inside), fail `SDL_Init`; same stderr bytes |
| SDL_CreateWindow fails | log, free text, SDL_Quit, fail | log, SDL_Quit, fail |
| SDL_CreateRenderer fails | log, free text, destroy window, SDL_Quit, fail | log, destroy window, SDL_Quit, fail; same stderr bytes |
| setup fails | free record, log "SDL_malloc, SDL_GetKeyboardState or SDL_SetRenderLogicalPresentation", free rect, event, text, destroy renderer, destroy window, SDL_Quit, fail `setup` | log "SDL_GetWindowID or SDL_SetRenderLogicalPresentation", destroy renderer, destroy window, SDL_Quit, fail `setup` |
| up-front malloc fails | fail `SDL_malloc` without logging | no up-front allocation. If a later log buffer cannot be had, nothing is logged |
| close(failure) | pop, log, free rect, event, text, destroy renderer, destroy window, free record, SDL_Quit | pop, log, look up window and renderer by ID, destroy renderer, destroy window, SDL_Quit |
| operation on a closed Sdl | `false` / "polling a closed SDL" | the same |

`close` logs before it looks anything up. SDL keeps one error string, so a
failed lookup would otherwise replace the text of the failure being logged.
The SDL objects are released in the same order as in wt: log, renderer,
window, SDL_Quit.

## Method

1. Copied the working tree's `examples/games/icy-tower/*.bot` into a scratch
   application directory and replaced `sdl.bot` with this one.
2. Staged it with the SDL3 binding (`tools/c-bindgen.tcl stage sdl3 -target linux-x86_64 -app APP -into STAGE`).
3. Ran `tclsh9.0 main.tcl -warnings error -check STAGE/main.bot`, which
   printed `ok`.
4. Built with `tclsh9.0 main.tcl -warnings error -emit-native-executable -L
   $SDL STAGE/main.bot`. The build passed under `-warnings error` on the
   first attempt.
5. Built the unmodified working tree (4be79514, byte-identical files) the
   same way, for the comparison runs.

I also wrote an error-path probe, `errpaths.bot` (scratch only, not
committed). It imports `sdl` and calls `fill`, `text`, `line` and `poll` on
a closed Sdl, after `open`, with `1.0e300` arguments that overflow binary32,
with a 130-character text, and again after a double `close`. I built it
against both versions. Every number below is from the final `sdl.bot` in
this directory.

## Verification

All commands ran with `LD_LIBRARY_PATH=$SDL` and the package-owned headless
SDL3.

| Check | Command | Result (ids) | Same as wt |
|---|---|---|---|
| headless | `EXE --headless --frames 600 --seed 7` | exit 0, the reference line exactly | yes (stdout, stderr, exit) |
| SDL loop | `SDL_VIDEO_DRIVER=dummy EXE --autopilot --fixed-step --frames 600 --seed 7` | exit 0, the reference line exactly | yes |
| seed 11 | `... --frames 120 --seed 11` | exit 0, `"frames=120 round=1 floor=5 score=50 best=5.7 time=2.0 over=no x=132 y=614 camera=218 platforms=13 rng=3691588132"` | yes |
| GC stress | the same with `BOTLISH_NATIVE_GC_STRESS=1` | identical stdout and stderr to the unstressed run | yes |
| no video driver | `SDL_VIDEO_DRIVER=nosuch EXE --frames 10` | exit 1, stdout empty, stderr exactly `Icy Tower: SDL_Init failed: nosuch not available\n` | yes |
| no render driver | `SDL_VIDEO_DRIVER=dummy SDL_RENDER_DRIVER=nosuch EXE --frames 10` | exit 1, stdout empty, stderr exactly `Icy Tower: SDL_CreateRenderer failed: nosuch not available\n` | yes |
| memcheck | `SDL_VIDEO_DRIVER=dummy valgrind --leak-check=full --error-exitcode=9 EXE --autopilot --fixed-step --frames 30 --seed 7` | exit 0, `ERROR SUMMARY: 0 errors from 0 contexts`, definitely lost 0 bytes, indirectly lost 0 bytes (42,930 allocs, 42,929 frees; wt 41,991 / 41,990) | yes |
| 3000 frames | `... --frames 3000 --seed 7` | `"frames=3000 round=2 floor=52 score=520 best=54.0 time=17.6 over=no x=271 y=5435 camera=5039 platforms=12 rng=476811792"` | yes |
| error paths (probe) | `valgrind --leak-check=full errpaths` | `["fill:false", "text:false", "poll:polling a closed SDL", "fill:true", "fill:NonFiniteFloat", "text:true", "text:NonFiniteFloat", "text:true", "line:NonFiniteFloat", "poll:", "fill:false", "poll:polling a closed SDL"]`, 0 errors, definitely and indirectly lost 0. Every per-call allocation is freed on the NonFiniteFloat paths too | yes (identical list); the same under GC stress |
| failure paths under memcheck | the two `nosuch` runs under valgrind | definitely and indirectly lost 0. One "possibly lost" 304-byte record, the runtime worker thread's TLS (`allocate_dtv`) when C `exit(1)` is called from that thread | yes, the same single record in wt |

## Counts

`census.tcl` on the variant's application directory, against the working
tree and the baseline (`-rev` of 6df89a8e, which was HEAD when it ran):

| Measure (total) | baseline 6df89a8e | wt 4be79514 | ids |
|---|---:|---:|---:|
| functions | 90 | 94 | 95 |
| pointer-functions | 24 | 7 | 6 (all in sdl) |
| pointer-struct-types | 4 | 0 | 0 |
| pointer-clones (spelling / HIR) | 56 / 56 | 6 / 6 | 3 / 3 |
| pointer-destructurings | 6 | 0 | 0 |
| pointer-struct-constructions | 16 | 0 | 0 |
| cross-module-calls | 58 | 61 | 61 |
| pointer-crossing-calls | 38 | 0 | 0 |
| sdl-c-calls (static sites) | 31 | 38 | 50 |
| other-c-calls | 4 | 4 | 4 |
| native-view-edit | 4 | 6 | 4 |
| names-c-pointer-types | 2 | 1 | 1 |
| raw-binding-imports | 14 | 12 | 12 |
| sdl-context-parameters | 17 | 20 | 21 |
| sdl-requiring-functions | 30 | 33 | 34 |
| direct status | sdl contextualized, rest ordinary | the same | the same |

The ids pointer-functions are `write_text`, `free_text`, `free_rect`,
`free_event`, `release` and `quit_requested?`, all called only inside
`sdl.bot`.

`escape-candidates.tcl -target linux-x86_64 STAGE/main.bot` prints
`totals: ` (empty) for both ids and wt: no site in any bucket. As a positive
control, the baseline (6df89a8e) staged the same way gives `{hit R1} 37 {hit
R2} 37 {hit R4} 3 {hit sites} 40 {no-context R1} 1 {no-context R2} 1
{no-context R4} 1 {no-context sites} 2`.

Source size of `sdl.bot`: wt 424 lines (269 code), ids 407 lines (250 code).
The ids file has:

* 8 places that recover the renderer (window lookup plus renderer lookup):
  color, clear, present, fill, line, text, scale and close;
* 4 allocation sites with 9 `free_*` calls;
* 5 handlers that exist only to free the scratch memory: 2 re-raise
  (`on NonFiniteFloat {result}: ... fail NonFiniteFloat {result: result}`)
  and 3 return.

## Costs against the working tree

### SDL C calls per frame

Counted from the code:

* wt makes **R + 2 + E** calls per frame: R renderer operations, one
  `SDL_PollEvent` per event plus one, and one `SDL_GetTicksNS`.
* ids makes **3R + 2(F + T) + 5 + E** calls per frame:
  * each renderer operation adds `SDL_GetWindowFromID` and `SDL_GetRenderer`;
  * each `fill` (F per frame) and each `text` (T per frame) adds one
    `SDL_malloc` and one `SDL_free`;
  * the poll is `SDL_malloc`, `SDL_PollEvent` × (1 + E), `SDL_free` and
    `SDL_GetKeyboardState`;
  * one `SDL_GetTicksNS`.

To confirm it, I ran `valgrind --tool=callgrind --dump-instr=no` at 60 and
240 frames (autopilot, fixed step, seed 7) and divided the difference by 180.
A small parser of the callgrind file counted calls from the program's object
into libSDL3, and the inclusive cost of those calls. It measured R = 87,
F = 21.33, T = 5.33 and E = 0 in steady state:

| SDL function | calls/frame wt | calls/frame ids | instr/call |
|---|---:|---:|---:|
| SDL_GetWindowFromID | 0 | 87.00 | 16.0 |
| SDL_GetRenderer | 0 | 87.00 | **915.0** |
| SDL_malloc | 0 | 27.67 | 132.4 |
| SDL_free | 0 | 27.67 | 103.8 |
| SDL_GetKeyboardState | 0 | 1.00 | 7.0 |
| SDL_RenderLine | 34.00 | 34.00 | 3,659 |
| SDL_SetRenderDrawColor | 23.00 | 23.00 | 244 |
| SDL_RenderFillRect | 21.33 | 21.33 | 678 |
| SDL_RenderDebugText | 5.33 | 5.33 | 9,536 |
| SDL_SetRenderScale | 1.33 | 1.33 | 506 |
| SDL_PollEvent, SDL_GetTicksNS, SDL_RenderClear, SDL_RenderPresent | 1 each | 1 each | (present: 1,319,224) |
| **total** | **89.00** | **319.33** (3.6×) | |

The formula gives 87 + 2 = 89 for wt and 261 + 53.33 + 5 = 319.33 for ids,
which matches callgrind exactly.

### Instructions

Steady state, per frame (callgrind Ir, 240 − 60 frames):

| | wt | ids | Δ |
|---|---:|---:|---:|
| whole process | 2,155,661 | 2,232,750 | **+77,089 (+3.6 %)** |
| inside SDL calls (inclusive) | 1,531,759 | 1,619,293 | +87,534 |
| outside SDL calls | 623,902 | 613,458 | −10,444 |
| 3000-frame run, whole | 4,377,203,853 | 4,597,967,167 | +5.0 % |

Where the extra SDL instructions go:

* `SDL_GetRenderer` is **79,605 instr/frame, 91 %** of the added SDL work. It
  is `SDL_GetPointerProperty(SDL_GetWindowProperties(window),
  "SDL.window.renderer", NULL)` (pinned SDL3 source, `SDL_render.c`), so each
  call does object validation, a string hash (`SDL_HashString`), two
  hash-table lookups, a mutex and a reader-writer lock. Callgrind's exclusive
  deltas show exactly these: SDL_HashString +20.5k, SDL_FindInHashTable
  +20.4k, the pthread rwlock and mutex calls about +20k,
  SDL_GetPointerProperty +4.4k, strcmp and SDL_KeyMatchString +3.5k,
  SDL_FindObject +1.8k and SDL_GetWindowProperties +1.7k.
* `SDL_GetWindowFromID` costs 16 instructions: a walk of the window list,
  which here holds one window.
* The per-call scratch memory costs **6,533 instr/frame**, 0.29 % of a frame:
  236 instructions per malloc/free pair.
* Outside SDL, ids runs about 10k instr/frame fewer than wt. wt's pointer
  reads through the view are runtime calls (`rt_native_load_ptr` 3.9k/frame,
  `nview::view_address` 2.7k/frame more than ids).

The frame is dominated by `SDL_RenderPresent`, the dummy driver's software
renderer, at 61 % of instructions.

### Wall time

The workload was `SDL_VIDEO_DRIVER=dummy EXE --autopilot --fixed-step
--frames 3000 --seed 7`, with wt and ids runs interleaved on the shared
4-core machine (load average 1.3–2.5):

| Batch | wt | ids |
|---|---|---|
| best of 3, final build | 1.333 s | 1.386 s |
| final build, 10 runs each | min 1.333, median 1.404 | min 1.353, median 1.389 |
| pre-final build, 22 runs each (only `close` changed since) | min 1.333, median 1.373 | min 1.268, median 1.367 |
| rusage, 6 runs each | user median 1.345 s, max RSS 8.9–9.2 MB, 1,295–1,297 minor faults | user median 1.30 s, max RSS 9.0–9.2 MB, 1,291–1,300 minor faults |

The wall-time difference is below what this machine can resolve. The sign
of the difference flips from batch to batch, and the gap is at most about
4 %. Callgrind's +3.6 % instructions per frame is the reliable number. Its
cache and branch simulation (`--cache-sim=yes --branch-sim=yes`, same
frames, run on the build before the `close` change, whose frame loop is
identical) also says ids does slightly more work, not less:

* D1 write misses: 28,013 vs 28,021 per frame;
* conditional mispredicts: 6,608 vs 6,050 per frame;
* indirect mispredicts: 916 vs 338 per frame.

So the batches where ids ran faster are noise, not an effect.

## How far IDs generalize: SDL3's objects in the generated binding

I classified the binding's 1,218 C declarations
(`generated/c/sdl3/linux-x86_64/sdl3/*.bot`) by how a pointer to each object
type can be recovered from a non-affine value:

| Kind | Objects | Mechanism |
|---|---|---|
| ID and lookup from the ID | **Window** | `SDL_GetWindowID` / `SDL_GetWindowFromID`. IDs come from SDL's atomic object counter (`SDL_GetNextObjectID`, which skips 0), so an ID is not reused within 2^32 objects and a stale ID yields NULL rather than a freed window |
| | **Joystick**, **Gamepad** | `SDL_Get{Joystick,Gamepad}ID` / `SDL_Get{Joystick,Gamepad}FromID`, also `...FromPlayerIndex` |
| | **Haptic**, **Sensor** | `SDL_Get{Haptic,Sensor}ID` / `SDL_Get{Haptic,Sensor}FromID` |
| Object is only an ID (no pointer at all) | audio devices, displays, keyboards, mice, touch devices, pens, timers, property sets | `SDL_OpenAudioDevice` returns an `SDL_AudioDeviceID` and `SDL_CloseAudioDevice` takes one; the others are IDs throughout. This fits a context perfectly. Note that `SDL_AddTimer` needs a C callback |
| Recovered from another recoverable object | **Renderer** (one per window) | `SDL_GetRenderer(window)`: a properties lookup, about 915 instructions |
| | window surface | `SDL_GetWindowSurface(window)` |
| | GPU device of a GPU renderer | `SDL_GetGPURendererDevice(renderer)` |
| | the current render-target texture | `SDL_GetRenderTarget(renderer)` |
| | joystick of a gamepad | `SDL_GetGamepadJoystick` |
| | palette of a texture or surface | `SDL_Get{Texture,Surface}Palette` |
| | tray menu / entry relations | `SDL_GetTrayMenu`, `SDL_GetTrayEntryParent`, ... |
| Only "the current one" | cursor, GL context, window with keyboard / mouse focus or grab | `SDL_GetCursor`, `SDL_GL_GetCurrentContext`, `SDL_GetKeyboardFocus`, `SDL_GetMouseFocus`, `SDL_GetGrabbedWindow`: global state, not a handle |
| ID exists, but no lookup from it | **Camera**, thread | `SDL_GetCameraID` and `SDL_GetThreadID` exist, but there is no `SDL_GetCameraFromID` or thread lookup |
| | **AudioStream** | `SDL_GetAudioStreamDevice` goes from stream to device only |
| No ID, no lookup | **Texture** in general, Surface, AudioStream, IOStream, AsyncIO and AsyncIOQueue, Storage, Process, SharedObject, Mutex, RWLock, Condition, Semaphore, Tray, hid_device, and every GPU resource (buffer, texture, sampler, shader, pipelines, command buffer, fence, transfer buffer) | the pointer is the only handle |

So the ID approach covers the window and the input-device families, and
covers for free anything SDL already exposes as a bare ID (audio devices,
displays, timers). It covers the renderer at a per-call hash-lookup cost.
It does **not** cover textures, the first thing a sprite-drawing wrapper
needs. Nor does it cover audio streams, the second, or cameras, surfaces,
I/O streams, GPU resources or synchronization objects.

### The one universal fallback: SDL properties

SDL can hold any pointer in a property set:

* `SDL_SetPointerProperty(props: UInt, name, value)` stores it;
* `SDL_GetPointerProperty(props, name, NULL)` reads it back;
* `std::ffi::c::retype[T]` then gives the pointer back its type.

A context could keep just a property-set ID (`SDL_CreateProperties`,
`SDL_DestroyProperties` at close) and recover every object by name. This is
exactly SDL_GetRenderer's mechanism, so its cost would be about 900
instructions per access plus the string. In this binding it is blocked
three ways:

* **Names have no contract.** The `name` parameter of the property functions
  carries no contract fact, because the SDL3 profile declares only
  `SDL_CreateWindow`'s and `SDL_SetWindowTitle`'s. Botlish bytes cannot be
  lent to it (C-POINTER-BORROWING.md), so every name would have to be built
  in SDL_malloc'd memory per access, or retained, which is the original
  problem.
* **SDL's own property names are not bound.** They are string-literal
  macros, which the generator does not bind: 565 such macros are unsupported
  in `report.txt`, 286 of them `SDL_PROP_*`.
* **The type is unchecked.** `retype` is an assertion: the pointee type is
  only as right as the program's use of the name.

A `read noescape` profile fact for the property names would remove the first
obstacle. The other two remain.

### What scratch-per-call costs

* **Run time:** small. 27.7 malloc/free pairs per frame here, at about 236
  instructions each, is 6.5k instr/frame (0.3 %). It also adds 2 × 27.7 SDL
  calls per frame and roughly 900 more heap allocations in a 30-frame run.
* **Correctness:** this is the real cost. Every exit after an allocation
  must free it:
  * `fill` and `text` turn a `NonFiniteFloat` raised by the float narrowing
    into "free, then re-raise";
  * `poll` frees on its view-failure path;
  * the NativeEditNull handlers return without freeing, which is right only
    because an edit fails only for a null pointer.

  The compiler checks none of this. A C pointer is affine but may be
  dropped unused, and dropping one is silent, so a forgotten `free_*` is a
  leak that only valgrind finds. The error-path probe and memcheck runs
  above are what show the four allocation sites are freed on every path.
* **Safety:** none of the scratch outlives its call. SDL copies a rectangle
  into its command queue (`QueueCmdFillRects`) and walks a debug-text string
  glyph by glyph before returning (`SDL_RenderDebugText`). Memcheck reports
  no invalid read.

## Findings

1. **Retained context state without native memory works, for SDL's window.**
   A session holding only a `UInt` window ID meets every reference behavior
   byte for byte and at the same exit statuses, also under GC stress and
   memcheck. It needs no `Handles` layout, no record that stores its own
   address, no `remember`, and no NativeView inside the context. The
   context's state is non-affine, so it never meets AFFINE-ERASURE-
   UNSUPPORTED, AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE or
   CONTEXT-NATIVE-LOWERING-UNSUPPORTED, and `render.bot`/`main.bot` are
   untouched. The warning-candidate detector finds nothing (0 sites, as for
   wt). The census is the same as wt or slightly lower in pointer plumbing:
   3 clones instead of 6, 4 native view/edit sites instead of 6, and 6
   internal pointer functions instead of 7.
2. **The price is SDL calls on the hottest path.**
   * SDL calls per frame go from 89 to 319 (3.6×), and instructions per
     frame rise 3.6 %.
   * 91 % of the added work is `SDL_GetRenderer`: the renderer has no ID, so
     every draw call does a locked string-keyed hash lookup that costs more
     than `SDL_SetRenderDrawColor` itself (915 vs 244 instructions).
   * The window lookup (16) and the scratch memory (236 per pair) are minor.
   * Wall time did not resolve the difference on this machine (within ±4 %,
     sign varying by batch).
3. **IDs are not a general retention mechanism for SDL.** Only windows,
   joysticks, gamepads, haptics and sensors have ID lookups. Audio devices,
   displays and timers are IDs already. Renderers, window surfaces and the
   render target are reachable from a window or renderer.
   * Textures, audio streams, cameras, surfaces, I/O streams, GPU resources
     and synchronization objects are not recoverable from any non-affine
     value.
   * SDL properties would recover them, but the binding blocks it: there is
     no contract for the name strings and no bound `SDL_PROP_*` names, and
     the type comes back only through `retype`.
   * A future SDL wrapper that keeps textures across frames therefore cannot
     use this design. It needs retained native memory (the working tree's
     design), a table on the C side, or a language way to keep an affine
     resource in a context.
4. **Affinity of `Ptr` is not ownership of the C object.** The variant makes
   a fresh, independent affine `Ptr` for the same window on every operation,
   and `close` makes another to destroy it. Each is a legitimate C result.
   What keeps the program correct is the context discipline: one `Session`
   in the vector, popped by `close`, plus SDL's validation of IDs. The
   affine type does not. A stale ID is safe (SDL returns NULL and every call
   used here fails cleanly), which a stale pointer would not be.
5. **Scratch-per-call moves correctness from the type system to
   hand-written error paths.** No diagnostic exists for a dropped C pointer,
   so per-call scratch is only as leak-free as its tests. Here that is the
   memcheck runs and the error-path probe.

## Reproducing

```sh
export LANG=C.utf8 LC_ALL=C.utf8
SDL=/root/.cache/botlish/sdl3/829a65d769d935c4852f8159e964312c0957260a
APP=$(mktemp -d); STAGE=$(mktemp -d)/stage
cp examples/games/icy-tower/*.bot "$APP"/
cp audit/icy-tower/context-refactor/variants/ids/sdl.bot "$APP"/sdl.bot
tclsh9.0 tools/c-bindgen.tcl stage sdl3 -target linux-x86_64 -app "$APP" -into "$STAGE"
tclsh9.0 main.tcl -warnings error -check "$STAGE"/main.bot
tclsh9.0 main.tcl -warnings error -emit-native-executable -L $SDL "$STAGE"/main.bot
LD_LIBRARY_PATH=$SDL SDL_VIDEO_DRIVER=dummy "$STAGE"/main --autopilot --fixed-step --frames 600 --seed 7
tclsh9.0 audit/icy-tower/context-refactor/tools/census.tcl "$APP"
tclsh9.0 audit/icy-tower/context-refactor/tools/escape-candidates.tcl -target linux-x86_64 "$STAGE"/main.bot
LD_LIBRARY_PATH=$SDL SDL_VIDEO_DRIVER=dummy valgrind --tool=callgrind --dump-instr=no \
    --callgrind-out-file=cg.240 "$STAGE"/main --autopilot --fixed-step --frames 240 --seed 7
```

The per-function call counts come from walking `calls=` lines whose caller
object is the executable and whose callee object is libSDL3. Take the
difference of the 240- and 60-frame runs and divide by 180.
