# Design A: opaque resource values

A variant of the Icy Tower game for ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md,
for comparison with the retained-context design (commit 4be79514,
`examples/games/icy-tower/` at HEAD) and the baseline it replaced
(6df89a8e, HEAD~1). It keeps no SDL state in a context:

* `sdl::Video` is an `opaque struct` holding the window, renderer, keyboard
  state and native scratch pointers, plus `synced`. It is affine, because it
  holds C pointers. `sdl::open(...) -> Video errors SdlFailed` makes one,
  `sdl::close(video, failure)` consumes it, and `sdl::poll` and `sdl::show`
  take it and hand it back in a result struct (`Polled`, `Shown`).
* `sdl::Sdl {tag: unit}` is the authority-only context, installed with
  `with context sdl::authority()` as in the baseline. The `sdl` module is
  `contextualized`, and render and main stay `ordinary`.
* render.bot and main.bot never see the representation. There is no
  destructuring, field read or construction of a Video outside sdl.bot, and
  any attempt is `OPAQUE-REPRESENTATION` (probe below). No pointer is read
  through native memory: the pointers live in the Video, never in a
  `NativeView`.
* Drawing is data. render.bot builds the frame as a `List[sdl::Command]`
  with pure constructors (`sdl::color`, `sdl::fill`, `sdl::line`,
  `sdl::text`, `sdl::scale`, `sdl::clear`, `sdl::present`, plus
  `sdl::joined` to concatenate). `sdl::show(video, commands)` makes the SDL
  calls in one call per frame. Only `render::draw` holds the Video.

Files here: `sdl.bot`, `render.bot`, `main.bot`. `tower.bot`, `hud.bot` and
`options.bot` are the game's own (`examples/games/icy-tower/`, unchanged by
any design), copied beside these when building.

```sh
export LANG=C.utf8 LC_ALL=C.utf8
SDL=$HOME/.cache/botlish/sdl3/829a65d769d935c4852f8159e964312c0957260a
app=$(mktemp -d); stage=$(mktemp -d)
cp examples/games/icy-tower/{tower,hud,options}.bot $app/
cp audit/icy-tower/context-refactor/variants/opaque-values/*.bot $app/
tclsh9.0 tools/c-bindgen.tcl stage sdl3 -target linux-x86_64 -app $app -into $stage
tclsh9.0 main.tcl -warnings error -check $stage/main.bot
tclsh9.0 main.tcl -warnings error -emit-native-executable -L $SDL $stage/main.bot
```

## Spellings

Botlish has no observing parameter: passing the Video to a Botlish function
moves it, so every operation must return it. Three spellings were written for
the same sample, `walls` and `player` from render.bot (11 SDL operations, one
loop). All three compiled under `-warnings error` and ran once natively on
the dummy driver, drawing successfully.

**S1, a result struct per operation.** Each operation returns
`sdl::Drew {video, ok}`:

```botlish
fn player(v0: sdl::Video, p: tower::Player, camera: tower::Camera) -> sdl::Drew:
    f = p.figure(camera):
        on NonFiniteFloat:
            return sdl::Drew {video: v0, ok: false}
    {video: v1, ok: body_color} = v0.color1(250, 112, 72)
    {video: v2, ok: body} = v1.fill1(p.x, f.top, tower::player_width, tower::player_height)
    {video: v3, ok: eye_color} = v2.color1(28, 28, 40)
    {video: v4, ok: left_eye} = v3.fill1(f.left_eye, f.eyes, 4.0, 7.0)
    {video: v5, ok: right_eye} = v4.fill1(f.right_eye, f.eyes, 4.0, 7.0)
    sdl::Drew {video: v5, ok: body_color and body and eye_color and left_eye and right_eye}
```

**S2, the failure carried inside the value.** The Video gets a sticky `ok`
field, operations return the Video, and calls chain. `sdl::spoil(video)`
marks a failure of the caller's own:

```botlish
fn player(video: sdl::Video, p: tower::Player, camera: tower::Camera) -> sdl::Video:
    f = p.figure(camera):
        on NonFiniteFloat:
            return video.spoil()
    video.color(250, 112, 72).fill(p.x, f.top, tower::player_width, tower::player_height).color(28, 28, 40).fill(f.left_eye, f.eyes, 4.0, 7.0).fill(f.right_eye, f.eyes, 4.0, 7.0)
```

**S3, a display list (the one chosen).** Render functions are pure and
return `List[sdl::Command]`. One operation draws the list:

```botlish
fn player(p: tower::Player, camera: tower::Camera) -> List[sdl::Command] errors NonFiniteFloat:
    top = row(p.y + tower::player_height, camera)
    look = if p.vx < -20.0: ... (as before)
    [sdl::color(250, 112, 72), sdl::fill(p.x, top, ...), sdl::color(28, 28, 40), sdl::fill(p.x + 6.0 + look, top + 8.0, 4.0, 7.0), ...]
```

S1 and S2 inherit four costs from the language, each observed while writing
the samples:

1. **A function holding the handle may not fail.** If a callee that took
   the Video raises, the Video dies with it, and the caller's handler cannot
   return it: `` `r` was used after its affine value was moved ``
   (USE-AFTER-MOVE). So every function on the handle path must be total.
2. **A handler covers one call, not its arguments.** In
   `y = row(std::float64::from_int(k) * brick, camera): on NonFiniteFloat:`
   the argument stays unhandled: `this call of "std::float64::from_int" may
   produce the declared error "NonFiniteFloat", which is neither handled here
   nor admitted by the enclosing function's own "errors" declaration`
   (UNHANDLED-ERROR). Constant expressions such as `tower::view_width -
   tower::wall` and every `Float64` `+ - * /` behave the same way. Each
   fallible computation therefore has to be lifted into a helper (`figure`,
   `brick_row`, `first_brick`, a `Figure` struct) and called once under a
   handler. Lifting them into module constants works only for constants.
3. **A loop cannot thread the handle.** `` `r` is not definitely live here:
   its affine value was moved on some path reaching this use ``
   (AFFINE-NOT-DEFINITELY-LIVE). Every loop that draws becomes a recursive
   helper (`mortar(video, camera, k, last)`). The full render has 4 such
   loops: walls, platforms, status lines and banner lines.
4. **No rebinding in a scope.** `duplicate binding "r" in the same lexical
   scope` (DUPLICATE). S1 numbers its handles (`v0` ... `v5`); S2 avoids
   names by chaining.

S1 has one further hazard. A destructured `ok:` name can shadow a function:
`{video: v4, ok: mortar} = ...` followed by `v4.mortar(...)` called the
*bool*, giving `` `v4` is an affine sdl::Video, which cannot become an
argument of a function value whose parameters are not known: ... ``
(AFFINE-ERASURE-UNSUPPORTED), plus UNPROVEN-FIELD and TYPE errors.

S3 has none of the four. Render is pure and propagates `NonFiniteFloat` like
any function; loops collect commands; the handle appears once per frame.
Its own costs: a Command type (an enum plus a 9-field opaque struct), 7
constructors, a dispatcher and executor in sdl.bot, and list concatenation.
Botlish has no List concatenation, and a typed empty MutableVector needs a
typed seed: `std::mutable_vector::from_list([])` is `MutableVector[never]`,
giving `value of type sdl::Command is not admissible to element type never of
MutableVector[never] ...` (TYPE). `joined` seeds it with
`no_commands() -> List[Command]`.

The sample, measured as non-comment, non-blank lines of the items each needs:

| spelling | lines for walls + player | handle plumbing at the 11 SDL ops | extra structure |
|---|---:|---|---|
| baseline (pointers) | 26 | 10 of 11 calls carry `.clone()` arguments (14 clones) | -- |
| retained context (HEAD) | 26 | none | -- |
| S1 result struct | 49 | 11 destructurings, each binding a new handle name (`v1` ... `v5`) | 3 fallible helpers + `Figure`; 1 recursive helper; 3 handlers |
| S2 sticky flag | 37 | 11 chained calls threading the handle | 3 fallible helpers + `Figure`; 1 recursive helper; 3 handlers |
| S3 display list | 22 | none (constructors); 1 `show` per frame | `sdl::joined` x2 |

S3 is the least-ceremony spelling current Botlish allows, so the variant uses
it. It is a change of rendering style (immediate to retained), and the
affine handle is what forces it. The retained-context design could adopt a
display list too, but would gain nothing, since its operations already
need no plumbing.

## Verification

All on the native executable built as above. Each was run, and each matched:

| check | result |
|---|---|
| `--headless --frames 600 --seed 7` | `"frames=600 round=1 floor=26 score=260 best=29.1 time=10.0 over=no x=263 y=2947 camera=2551 platforms=11 rng=3699965314"`, exit 0 |
| `SDL_VIDEO_DRIVER=dummy --autopilot --fixed-step --frames 600 --seed 7` | the same line, exit 0 |
| dummy `--autopilot --fixed-step --frames 120 --seed 11`, plain and with `BOTLISH_NATIVE_GC_STRESS=1` | identical (`cmp`): `"frames=120 round=1 floor=5 score=50 best=5.7 time=2.0 over=no x=132 y=614 camera=218 platforms=13 rng=3691588132"` |
| `SDL_VIDEO_DRIVER=nosuch --frames 10` | stderr exactly `Icy Tower: SDL_Init failed: nosuch not available`, stdout empty, exit 1 |
| `SDL_VIDEO_DRIVER=dummy SDL_RENDER_DRIVER=nosuch --frames 10` | stderr exactly `Icy Tower: SDL_CreateRenderer failed: nosuch not available`, stdout empty, exit 1 |
| valgrind `--leak-check=full --error-exitcode=9`, dummy, `--autopilot --fixed-step --frames 30 --seed 7` | `ERROR SUMMARY: 0 errors from 0 contexts`, definitely lost 0 bytes, indirectly lost 0 bytes, exit 0 |

The baseline and HEAD executables, built the same way, print the same two
lines for seed 7 x 600 and seed 11 x 120.

## Measurements

### census.tcl

`census.tcl -rev HEAD~1` (B), `census.tcl examples/games/icy-tower` (W, the
retained context, HEAD), `census.tcl` on the assembled variant (A). Note that
`-rev HEAD` now measures W: the refactor was committed while this variant was
being written. hud, options and tower are identical in all three.

| measure | main B / W / A | render B / W / A | sdl B / W / A | total B / W / A |
|---|---|---|---|---|
| functions | 11 / 11 / 11 | 10 / 10 / 9 | 21 / 25 / 27 | 90 / 94 / 95 |
| pointer-functions | 1 / 0 / 1 | 8 / 0 / 1 | 15 / 7 / 10 | 24 / 7 / 12 |
| pointer-struct-types | 1 / 0 / 1 | 1 / 0 / 1 | 2 / 0 / 3 | 4 / 0 / 5 |
| pointer-clones | 0 / 0 / 0 | 48 / 0 / 0 | 8 / 6 / 11 | 56 / 6 / 11 |
| pointer-clones-hir | 0 / 0 / 0 | 48 / 0 / 0 | 8 / 6 / 11 | 56 / 6 / 11 |
| pointer-destructurings | 3 / 0 / 3 | 1 / 0 / 1 | 2 / 0 / 3 | 6 / 0 / 7 |
| pointer-struct-constructions | 8 / 0 / 8 | 2 / 0 / 2 | 6 / 0 / 8 | 16 / 0 / 18 |
| cross-module-calls | 17 / 20 / 20 | 39 / 39 / 46 | 0 / 0 / 0 | 58 / 61 / 68 |
| pointer-crossing-calls | 4 / 0 / 6 | 34 / 0 / 1 | 0 / 0 / 0 | 38 / 0 / 7 |
| sdl-c-calls | 1 / 0 / 0 | 0 / 0 / 0 | 30 / 38 / 31 | 31 / 38 / 31 |
| other-c-calls | 4 / 4 / 4 | 0 / 0 / 0 | 0 / 0 / 0 | 4 / 4 / 4 |
| native-view-edit | 0 / 0 / 0 | 0 / 0 / 0 | 4 / 6 / 4 | 4 / 6 / 4 |
| names-c-pointer-types | 0 / 0 / 0 | 1 / 0 / 0 | 1 / 1 / 1 | 2 / 1 / 1 |
| raw-binding-imports | 2 / 1 / 1 | 1 / 0 / 0 | 11 / 11 / 11 | 14 / 12 / 12 |
| sdl-context-parameters | 0 / 0 / 0 | 0 / 0 / 0 | 17 / 20 / 13 | 17 / 20 / 13 |
| sdl-requiring-functions | 5 / 5 / 5 | 8 / 8 / 1 | 17 / 20 / 13 | 30 / 33 / 19 |

Direct status, all three: sdl contextualized; every other module ordinary.
A's pointer-struct-types are `Ended`, `render::Drawn`, `sdl::Polled`,
`sdl::Shown` and `sdl::Video`. Its crossings are main -> render::draw,
sdl::open, sdl::poll and sdl::close (3 sites), and render -> sdl::show.

### escape-candidates.tcl

`-target linux-x86_64` on each staged main.bot:

| design | totals |
|---|---|
| B | `{hit R1} 37 {hit R2} 37 {hit R4} 3 {hit sites} 40 {no-context R1} 1 {no-context R2} 1 {no-context R4} 1 {no-context sites} 2` |
| W | (none) |
| A | `{hit R1} 6 {hit R4} 2 {hit sites} 8 {no-context R1} 1 {no-context R4} 1 {no-context sites} 2` |

A's sites:

| bucket | site | rule | what |
|---|---|---|---|
| hit | render.bot:145:5 | R4 | destructure `sdl::Shown` |
| hit | render.bot:145:34 | R1 | call `sdl::show` |
| hit | main.bot:94:5 | R4 | destructure `sdl::Polled` |
| hit | main.bot:94:52 | R1 | call `sdl::poll` |
| no-context | main.bot:114:5 | R4 | destructure `render::Drawn` |
| no-context | main.bot:114:48 | R1 | call `render::draw` |
| hit | main.bot:126:13 | R1 | call `sdl::open` |
| hit | main.bot:136:13 | R1 | call `sdl::close` |
| hit | main.bot:140:13 | R1 | call `sdl::close` |
| hit | main.bot:143:5 | R1 | call `sdl::close` |

There is no R2 or R3: the opaque Video stops the raw search, so no C
address's representation and no native view crosses. Every R1 is the design
working as intended: opaque resource ownership crossing the airlock. The R4
sites are the non-opaque result structs (`Polled`, `Shown`) that hand the
Video back. The warning proposal as measured would flag all 8 sites of a
design whose crossings are all opaque, so it cannot tell A's API apart from
the baseline's raw one except by R2.

### Exact counts

Lines are non-comment, non-blank. "SDL-operation call sites" are calls from
render.bot to functions of sdl.bot, listed from the HIR (a scratch script
modelled on census.tcl; each site is a source location).

| | baseline | retained context | Design A |
|---|---:|---:|---:|
| render.bot lines | 120 | 107 | 109 |
| main.bot lines | 128 | 127 | 133 |
| sdl.bot lines | 179 | 269 | 239 |
| render: calls into sdl | 34 | 34 | 41 |
| of which SDL operations (make SDL calls) | 34 | 34 | 1 (`show`) |
| of which pure Command constructors | -- | -- | 34 |
| of which list joins (`sdl::joined`) | -- | -- | 6 |
| SDL-op sites needing plumbing | 25 (34 `.clone()` arguments) | 0 | 1 (`show`: result destructured, handle rebound as `shown`) |
| other render plumbing | 14 clones into render's own helpers; draw destructures and rebuilds the Video | none | draw: 1 handler returning the Video in `Drawn` |
| main: `Ended {video: ...}` constructions in `run` | 8 | 0 (Ended has no video) | 8 |
| main: handle-carrying destructurings | 3 (poll, draw, run results) | 0 | 3 |
| main: close sites | 1 | 1 (+1 in main's handler) | 3 (1 + 2 close-and-re-raise handlers) |

Two notes on the counts:

* **Formatting.** A's render.bot writes its five multi-element list
  literals one element per line: 35 of its 109 lines. Written one literal
  per line, the way the baseline writes its long calls, it would be 79.
* **main.bot.** A's main.bot is the baseline's plus two handlers (+6 lines),
  less `import sdl3::timer`, which `sdl::counter()` replaces as in W. The
  handlers close the Video when `tower::new_world` or `sdl::seconds` fails
  after `open`: on those two paths the baseline silently dropped its Video
  (and never called SDL_Quit). Re-raising needs the payload:
  `fail NonFiniteFloat` alone is `error "NonFiniteFloat" carries a payload,
  which "fail NonFiniteFloat" must construct: write "fail NonFiniteFloat
  {result: ...}" (the error's name alone is not its payload)`
  (MISSING-ERROR-PAYLOAD), so it is spelled `on NonFiniteFloat {result}: ...
  fail NonFiniteFloat {result: result}`.

### Run time

The display list allocates every frame. `--autopilot --fixed-step --frames
6000 --seed 7` on the dummy driver, 5 interleaved runs each. The machine is
a shared 4 cores, so this is indicative only.

| | user CPU, s (5 runs) | median |
|---|---|---:|
| baseline | 2.504 2.624 2.634 2.678 2.661 | 2.634 |
| retained context | 2.666 2.628 2.643 2.624 2.675 | 2.643 |
| Design A | 3.090 2.986 3.033 2.985 2.941 | 2.986 |

That is about +13%, roughly 59 us per frame. The frame of seed 7 after 600
frames has 81 Commands.

## Cleanup: does anything catch a forgotten close?

No. A copy of A's main.bot whose success path forgets to close (it moves
`done.close(failure)` into the failure branch) passes
`-check -warnings error` and `-check -warnings default` with no diagnostic.
This is AFFINE-VALUES.md's rule: an affine value may be dropped, and a
pointer owns nothing, so dropping one releases nothing (C-ABI-TYPES.md).
Built and run, it prints the correct summary. Under valgrind (30 frames) it
exits 9:

```
definitely lost: 344 bytes in 4 blocks    (16 rect, 128 text, 128 event, 72 + 462 indirect)
indirectly lost: 462 bytes in 6 blocks
possibly lost: 1,460,944 bytes in 2 blocks
ERROR SUMMARY: 6 errors from 6 contexts
```

The same omission in the retained-context design (HEAD's main.bot with
`sdl::close(failure)` moved into the failure branch) is equally silent at
compile time, and under valgrind it also exits 9: definitely lost 128 bytes
in 2 blocks, indirectly lost 734 bytes in 9 blocks, 4 errors.

What A does catch statically is the opposite mistake. Closing twice is
`` `done` was used after its affine value was moved `` (USE-AFTER-MOVE, moved
by `done passed to sdl::close`). So is any use after close, and so is
drawing with a Video another operation already took. In the retained
context, a second close is a run-time no-op and drawing after close returns
false at run time.

## Other diagnostics hit and awkward spots

* `OPAQUE-REPRESENTATION` (probe, reading a field of an opaque struct
  outside its module): `field access on res::Res is not available outside
  module "res"; res::Res has an opaque representation, so its fields can be
  neither projected nor destructured here (use the public operations
  provided by that module)`. This is the property A relies on.
* An error payload can carry the handle back
  (`error Lost: r: res::Res`; `fail Lost {r: r}`; `on Lost {r: back}:`
  compiled and ran on interp and cranelift). It does not remove cost 1
  above: every `NonFiniteFloat` must still be caught and converted.
* `AMBIGUOUS-METHOD-CALL` in the sample harness, which imported S1 and S2
  together: `method-style call "player" is ambiguous: more than one visible
  function accepts the receiver (s1::player, s2::player); ...`. Every
  operation takes the handle first, so same-named operations in two
  imported modules collide under method syntax. The variant itself has
  none. Naming sdl's operation `draw` beside `render::draw` was tested and
  is not ambiguous: their second parameters tell them apart.
* Small syntax notes from writing the Command type (not Design-A-specific):
  an enum's cases are one comma-separated line (`expected "," between the
  enum cases "Color" and "Fill" ...`), and there are no lambdas
  (`expected an expression, found "fn"`, help `capability.lambdas`), so
  `std::list::all?` needed a named helper.
* `show` keeps the baseline's failure semantics. A false SDL return is
  recorded and drawing goes on; an error (a Float64 beyond a C float, a
  scratch write) stops the frame. The collecting loop `break`s from the
  handler, and `ok` compares the collected count with the command count.
* A side benefit: render.bot's frame is now pure and needs no Sdl context
  (sdl-requiring-functions in render: 1, against 8), so it runs without
  SDL. A probe computing `std::list::length(render::frame(world))` for seed
  7 after 600 frames printed 81 on interp, compile and cranelift (cranelift
  with `-L $SDL`, since the program links SDL). A frame's commands could be
  golden-tested on every backend.

## Multiple windows and textures

Design A is more natural for coarse resources, but not for resources that
drawing data must name.

* **Windows: better in A, with a caveat.** Several Videos are just several
  values: a loop state struct holding two, each closed once, with use after
  close and double close rejected statically. The retained context holds
  one installed instance per context type, installed only at the entry
  program's top level. Several windows there means a table (its
  `MutableVector[Session]` indexed by an id the game holds): ids are
  unrestricted ints, so a stale id is a run-time failure, never a compile
  error.
  The caveat: this variant's `open`/`close` also start and end SDL
  (SDL_Init/SDL_Quit), as the baseline's did. Two windows need SDL's
  lifetime split into its own affine value, and nothing in Botlish can
  require every Video to be closed before that value is (no borrows or
  lifetimes; dropping is allowed). The retained context gets that ordering
  for free: one `close` releases everything it holds, then calls SDL_Quit.
* **Textures: no better in A.** A display list must be unrestricted data so
  that loops can collect it and the executor can iterate it. An affine
  texture inside a Command breaks that. Probe: a `Blit {texture: Texture,
  x}` with `opaque struct Texture: p: Ptr[Void]` gives `` `t` was used after
  its affine value was moved `` (USE-AFTER-MOVE) when one texture is drawn
  twice; `this loop would collect affine values (Blit) into a List: ...`
  (AFFINE-LIST-OPERATION-UNSUPPORTED) for a collecting loop; `` `t` is not
  definitely live here ... `` (AFFINE-NOT-DEFINITELY-LIVE); and
  `` `bs` is a List[Blit]: iterating a List of affine values would copy
  each element into the loop variable while the List still owns it ... ``
  (AFFINE-LIST-OPERATION-UNSUPPORTED) for the executor's loop.
  So a texture has to be named by an unrestricted id into a table the Video
  owns, the same handle-by-index structure the retained context uses. The
  alternative is threading each affine Texture through render, which
  brings back all four S1/S2 costs.

## Summary

With the display-list spelling, Design A costs about the same lines as the
retained context in render.bot (109 against 107; 79 written compactly) and
a few more in main.bot (133 against 127). That is because main still
threads the handle exactly like the baseline: 8 `Ended {video: ...}` exits,
3 handle-carrying destructurings, and close on every path, by hand. A's
gains over the baseline are real: no pointer clones outside sdl.bot (56 to
11, all in sdl.bot), and no raw C address crossing a module boundary (R2 37
to 0). It also makes double close and use after close static errors. It
does not catch a forgotten close: neither design does, and both leak
silently when one is forgotten. Its immediate-mode spellings (S1, S2) are
far more expensive than either: 37 to 49 lines for a 26-line sample, a
helper and handler for every fallible computation, and recursion for every
drawing loop. They are driven by three language facts: no observing
parameter, handlers that bind only the outermost call, and affine values
that cannot be threaded through a loop.
