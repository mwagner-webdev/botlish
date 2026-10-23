# Variant "canvas": a context trait between render.bot and SDL

Part of ICY-TOWER-CONTEXT-REFACTOR-CENSUS. The question: does a context
trait (CONTEXT-TRAITS.md) make the rendering layer independent of SDL and
testable on all four backends?

Short answer: yes, and it costs nothing at run time. `render.bot` declares
`context trait Canvas` and imports no SDL module. `sdl.bot` and `main.bot`
are unchanged, and `sdl::Sdl` satisfies Canvas as it is. The executable
behaves like the working tree's, down to an identical SDL call trace. Its
NIR is the working tree's with functions and statics renumbered. A
recording context draws real frames through `render::frame` on interp,
compile, cranelift-generic and cranelift, and all four print the same
value. The golden suite can host rendering tests only if the frames are
drawn when the tests are registered, not when a case runs. A check that
draws is rejected with `CONTEXT-FUNCTION-VALUE`. The costs are elsewhere:
front-end time for programs that did not already load a trait, and
structural, name-based satisfaction, which rules out a forwarding canvas
beside `sdl::Sdl`.

"Working tree" (wt) below means `examples/games/icy-tower/` at commit
2a91107e (the context-refactored game, committed as 4be79514). Its
`render.bot`, `sdl.bot` and `main.bot` are the files this variant starts
from.

## Files

| file | what |
|---|---|
| `render.bot` | the variant renderer: `context trait Canvas` and the seven drawing functions requiring it. It replaces `examples/games/icy-tower/render.bot` |
| `recorder.bot` | an application module: `context struct Recorder` (a `MutableVector[str]` log), which implements `render::Canvas` with its own seven functions, plus `create`, `recorded`, `forget` and `only` |
| `canvas-test.bot` | the test program. It installs `recorder::create()` and draws `tower::new_world(7, 1)` and that world after `simulate(600)` |
| `canvas-test.out` | its value, the same on all four backends |
| `golden.bot` | a copy of the game's `golden.bot` with three rendering tests added (+59 lines), drawn at registration time. 68 pass on all four backends |
| `golden-check-draws.bot` | the rendering test as one would first write it, with a check that draws. Rejected with `CONTEXT-FUNCTION-VALUE` |

`sdl.bot` and `main.bot` are not here because neither needed a change.

To run them, put the files beside the game's `tower.bot`, `hud.bot` and
(for `golden.bot`) `options.bot`. They need no SDL module and no staged
binding:

```
tclsh9.0 main.tcl -warnings error -backend B canvas-test.bot     # B: the four backends
tclsh9.0 tests/golden/run.tcl golden.bot                         # all four, reports compared
```

To build the game, copy the working tree's `*.bot`, replace `render.bot`
with this one, stage it (`tools/c-bindgen.tcl stage sdl3 -target
linux-x86_64 -app APP -into STAGE`) and build `STAGE/main.bot` with
`-emit-native-executable -L $SDL`.

## The design

```botlish
context trait Canvas:
    fn color(r: std::ffi::c::UChar, g: std::ffi::c::UChar, b: std::ffi::c::UChar) -> bool
    fn clear() -> bool
    fn present() -> bool
    fn fill(x: Float64, y: Float64, w: Float64, h: Float64) -> bool errors NonFiniteFloat
    fn line(x1: Float64, y1: Float64, x2: Float64, y2: Float64) -> bool errors NonFiniteFloat
    fn text(x: Float64, y: Float64, text: str) -> bool errors NonFiniteFloat
    fn scale(factor: Float64) -> bool errors NonFiniteFloat
```

These are the seven drawing operations wt `render.bot` calls, with
`sdl.bot`'s parameter types, result types and errors. The seven functions
that draw (`walls`, `platform_color`, `platform`, `player`, `lines`,
`banner`, `frame`) declare `context canvas: Canvas` and write
`canvas.fill(...)` where wt wrote `sdl::fill(...)`. `draw` declares
nothing: it requires Canvas transitively.

### How much changed

| file | change |
|---|---|
| `render.bot` | 144 -> 167 lines. Code only (comments and blank lines excluded): 42 lines removed, 50 added. That is 34 call sites `sdl::OP(` -> `canvas.OP(`, 7 signatures gaining `context canvas: Canvas`, `import sdl` -> `import std::ffi::c`, and the 8-line trait. Header comment rewritten |
| `sdl.bot` | 0 lines |
| `main.bot` | 0 lines |
| new for tests | `recorder.bot` (85 lines, 43 of code), `canvas-test.bot` (48 lines, 23 of code), `golden.bot` +59 lines |

### Satisfaction: no change to sdl.bot

`-traits` on the staged variant:

```
context sdl::Sdl implements render::Canvas (color -> sdl::color, clear -> sdl::clear, present -> sdl::present, fill -> sdl::fill, line -> sdl::line, text -> sdl::text, scale -> sdl::scale)
context std::linux::io::LinuxIO does not implement render::Canvas: no function std::linux::io::color exists: "color" is not defined by module "std::linux::io" (only the namespace that owns std::linux::io::LinuxIO implements its context-trait operations)
```

Each of `sdl.bot`'s seven functions already has exactly one context
parameter, `context sdl: Sdl`, and the same signature as the requirement.
`nomethod` does not count as a flag. Nothing in `sdl.bot` had to change.

`-traits` also shows how close an accidental match can come. `sdl.bot`'s
helper `write_text(buffer: Ptr, text: str)` has the name of `std::io::IO`'s
requirement:

```
context sdl::Sdl does not implement std::io::IO: sdl::write_text declares no result type: satisfaction is decided from declarations, so an implementation of a requirement with a result must declare it ("-> unit")
```

It is rejected on a declaration detail, and its arity differs as well. See
"Findings" (1).

## Method and results

### 1. Front end

`tclsh9.0 main.tcl -warnings error -check STAGE/main.bot` printed `ok` on
the first attempt: no diagnostic and no warning. Front-end time for `-check`
(two runs each, interleaved): wt 16.6 s and 15.9 s, variant 16.1 s and
15.5 s, so no difference. The game already paid for the second build of
the trait plan, because `main.bot` imports `std::io`, a context trait.

`-contexts` (variant):

```
contextselect e7063 render::Canvas sdl::Sdl
    color -> sdl::color
    ... (all seven)
contextclone render::walls<render::Canvas=sdl::Sdl> render::Canvas=sdl::Sdl
contextclone render::platform_color<...>  render::platform<...>  render::player<...>
contextclone render::lines<...>  render::banner<...>  render::frame<...>  render::draw<...>
contextclone run<render::Canvas=sdl::Sdl>  play<...>  session<...>
contextclone main<render::Canvas=sdl::Sdl,std::io::IO=std::linux::io::LinuxIO>
```

The trait plan clones the 8 render functions and the 3 `main.bot` functions
on the path to them (`run`, `play`, `session`), and `main`'s clone key gains
the selection. With one selection there is one clone per function, and the
clone replaces the original (see "Cost"). wt's `-contexts` lists 3 clones
(the `std::io` ones and `main`); the variant lists 14.

### 2. The recording canvas, on all four backends

`canvas-test.bot` (with `recorder.bot`, `render.bot`, `tower.bot`,
`hud.bot`) was run with `tclsh9.0 main.tcl -warnings error -backend B`.
Every backend exited 0. The `value:` lines are identical (md5
`4bae95ce...`; the full value is in `canvas-test.out`):

| world | succeeded | commands | texts |
|---|---|---|---|
| `tower::new_world(7, 1)` | true | 92 | `SCORE 0`, `FLOOR 0`, `BEST 0.0 M`, `TIME 0.0` at (28, 8 + 12i); banner `LEFT/RIGHT OR A/D TO RUN` at (24, 150), `LAND TO BOUNCE - CLIMB!` at (28, 162) |
| after `simulate(600)` | true | 81 | `SCORE 260`, `FLOOR 26`, `BEST 29.1 M`, `TIME 10.0`; no banner |

These agree with the reference summary (`score=260 floor=26 best=29.1
time=10.0 x=263`; the recorded player rectangle is at x 262.8). The banner
positions can be checked by hand: x = (240 - 8 * length) / 2 and y = (300 +
24 i) / 2 in the scaled view. The counts decompose as 2 + 38 (walls: 2
colors, 2 fills, 17 x 2 lines) + 4 per visible platform + 5 (player) + 3
(panel) + 4 (status) + 7 (banner) + 1 (present): 8 platforms visible in the
first frame, 7 in the later one.

Wall time, compile included: interp 17.2 s, compile 4.8 s, cranelift-generic
3.9 s, cranelift 4.2 s. With `BOTLISH_NATIVE_GC_STRESS=1`, cranelift-generic
and cranelift printed the same value.

`-contexts` for the test: `contextselect ... render::Canvas
recorder::Recorder` (`color -> recorder::color`, ...) and clones
`render::*<render::Canvas=recorder::Recorder>`, `drawn<...>` and
`run<...>`.

For contrast, in wt `render.bot` imports `sdl`. Beside the pure modules
alone, a program importing it does not compile:

```
error: .../sdl.bot:63:8: unknown namespace "sdl3::ctypes": no such module file .../sdl3/ctypes.bot (an application's own modules are the files beside its entry program) (SURFACE MODULE UNKNOWN-NAMESPACE)
```

Staged with the binding, it runs on interp only against a closed `Sdl`:
`render::draw` returns `"drawing a frame"` because every operation answers
false and nothing is observable. Opening SDL on a Tcl backend fails with:

```
error: sdl3::stdinc::SDL_malloc is a C function (extern c fn): calling it runs only on the native backends (cranelift, cranelift-generic, a native executable), which link and call the C library; the Tcl backends have no machine to call it on (CORE SEMANTIC NATIVE-ONLY)
```

### 3. The golden suite (stdlib/test.bot)

**A check that draws cannot be registered.** `golden-check-draws.bot`
registers `fn first_frame() -> list`, which calls `recorder::forget()`,
`render::frame(...)` and `recorder::recorded()`, with `std::test::value`:

```
error: .../golden-check-draws.bot:33:60: function first_frame requires context recorder::Recorder, render::Canvas, so it can only be called (or bound to another name as a statement): it cannot be passed, returned or stored as a value, because a call through an unknown function value could not prove that context installed (CORE SEMANTIC CONTEXT-FUNCTION-VALUE)
```

This is by design (CONTEXTS.md, the higher-order frontier;
GOLDEN-TEST-FRAMEWORK.md, "No parameters, no context"). A suite stores each
case as a function value, so no case can reach an installed context while
it runs. Inlining the Recorder into `golden.bot` (an earlier attempt) gives
the same diagnostic, with `requires context Recorder, render::Canvas`.

**Drawing at registration time works.** `golden.bot` here is the game's
suite plus `import recorder`, `import render`, `with context
recorder::create()` after `with context std::test::suite()`, and
`register_render_tests()`. That function draws three frames when it runs at
the top level, which is allowed because it requires the Suite, Recorder and
Canvas, all installed. Each check only returns the captured result, so it
is context-free:

```botlish
fn register_render_tests():
    start = drawing(new_world(7))
    fn first_frame() -> list:
        start
    std::test::value("icy-render-first-frame", [true, 92, [...6 texts...], ["scale 2.0", "scale 1.0"]], first_frame)
    ...  # icy-render-after-600-frames (81, 4 texts, no scale), icy-render-game-over-banner (92, "GAME OVER" at 84,150 ...)
```

Results:

* `tclsh9.0 tests/golden/run.tcl golden.bot` exited 0: "68 passed, 0
  failed" on interp, compile, cranelift-generic and cranelift, with the
  reports compared by the runner.
* The tests can fail. I changed `lines`' spacing `12.0` to `13.0` in a
  scratch copy of `render.bot` and ran on interp: "65 passed, 3 failed".
  Each failure showed the expected and actual text rows.

What this hosting costs:

* The drawing runs when the suite registers its cases, not when a case
  runs. An error that `drawing` does not handle would abort the whole suite
  rather than fail one case. `render::frame`'s only error, NonFiniteFloat,
  is handled.
* A program installs a context type once (DUPLICATE-CONTEXT), so all tests
  share one Recorder and must `forget()` before drawing.
* Front-end time doubles for a suite that loaded no trait before.
  `golden.bot`'s `-check`: 7.0 s as it is, 15.2 s with only `import render`
  added, 16.8 s with the tests. Importing a module that declares just
  `context trait T: fn f() -> int` gives 13.3 s, and a trait-free module
  7.2 s. So the cost is TRAITS.md's second build, not render.bot. The
  four-backend runner went from 36 s ("compile 7.36s") to 69 s ("compile
  18.38s").

### 4. The executable: every reference behavior

The variant was built with `-warnings error -emit-native-executable -L $SDL`
(25.3 s; wt 26.2 s) and run with `LD_LIBRARY_PATH=$SDL`:

| check | result |
|---|---|
| `--headless --frames 600 --seed 7` | `"frames=600 round=1 floor=26 score=260 best=29.1 time=10.0 over=no x=263 y=2947 camera=2551 platforms=11 rng=3699965314"`, exit 0 |
| dummy, `--autopilot --fixed-step --frames 600 --seed 7` | the same line, exit 0 |
| dummy, `--autopilot --fixed-step --frames 120 --seed 11`, without and with `BOTLISH_NATIVE_GC_STRESS=1` | identical output (`"frames=120 ... rng=3691588132"`), both exit 0 |
| `SDL_VIDEO_DRIVER=nosuch --frames 10` | stderr exactly `Icy Tower: SDL_Init failed: nosuch not available` (plus newline), stdout empty, exit 1 |
| dummy + `SDL_RENDER_DRIVER=nosuch --frames 10` | stderr exactly `Icy Tower: SDL_CreateRenderer failed: nosuch not available`, exit 1 |
| valgrind `--leak-check=full --error-exitcode=9`, 30 frames | exit 0; `ERROR SUMMARY: 0 errors from 0 contexts`, definitely lost 0 bytes, indirectly lost 0 bytes (still reachable 544 bytes in 1 block) |

Further checks:

* The five run outputs and exit statuses above are byte-identical to wt's
  executable.
* SDL call trace: `tools/trace-compare.sh WT VARIANT` (2400 frames, seed 7)
  gave 204,299 calls on each side and `diff`: "(identical)". That covers
  every color, rect, line, float and text argument.
* `python3 -I audit/icy-tower/oracle.py compare VARIANT`: "0 differences"
  (headless, so it does not exercise render.bot).
* The bodies of `tests/workload-icy-tower.test`'s
  `sdl-modules-warning-clean` and `sdl-airlock`, run as a script on the
  staged variant, give their expected results: `ok {{entry program}
  ordinary hud ordinary options ordinary render ordinary sdl contextualized
  tower ordinary}` and `{}`.

### 5. Cost

**Does the plan clone the render functions?** Yes. Each one is replaced,
not duplicated:

* `-emit-nir` lists 112 functions in both programs. The only differences
  are names (`render::frame` -> `render::frame<render::Canvas=sdl::Sdl>`,
  11 functions renamed, `main` re-keyed).
* I normalized both dumps: function numbers replaced by the callee's name
  without its `<...>` key, `@eN` origins and static-slot numbers dropped,
  functions sorted by name. The two dumps are then identical, and so are
  their non-function lines (`context`, `foreign`, `shape`, `link`,
  `target`).
* The static slots moved: render's `thickness` and `brick` went from 346
  and 347 to 23 and 24, and the slots between them shifted by 2. So the
  clones call `sdl::color` and the others directly, with the same operands
  wt passes.

**Size.** `size` reports text 947,212 (variant) against 947,228 (wt) and
bss 2,112 against 2,096, with the same total of 973,244. Stripped, the
files are 974,504 and 974,520 bytes: the variant is 16 bytes smaller, which
is function placement and padding.

**Frame time.** I timed 3000 dummy frames (`--autopilot --fixed-step
--frames 3000 --seed 7`), interleaved, on a shared 4-core machine with load
average about 2.

| | runs 1-3 (ms) | best of 3 | runs 4-8 (ms) | best of 8 |
|---|---|---|---|---|
| wt | 1458, 1400, 1411 | 1400 | 1390, 1351, 1420, 1423, 1350 | 1350 |
| variant | 1384, 1330, 1410 | 1330 | 1380, 1404, 1405, 1337, 1322 | 1322 |

The gap is inside the run-to-run spread. Callgrind is deterministic (two
300-frame runs per side gave identical counts) and settles it:

| | 300 frames | 3000 frames |
|---|---|---|
| wt | 646,781,862 | 4,377,377,000 |
| variant | 646,795,335 (+0.002%) | 4,376,937,445 (-0.010%) |

In the 3000-frame profiles, the generated code (`botlish_fn_*`) has 95
functions on each side. The multiset of their instruction counts is
identical, 80,951,214 in total. The whole difference is in glibc (malloc,
free, consolidation, `strcmp`), which looks like heap-layout noise. It
does not grow with frames: +13 k at 300 frames, -440 k at 3000.

**Compile time.** No change for the game: `-check` and
`-emit-native-executable` times are within noise, because the game already
built twice. A program that did not, like `golden.bot`, pays the second
build (section 3).

### 6. The census tools

* `tools/census.tcl` on the variant directory: every count is identical to
  wt's, including render's `cross-module-calls 39` and
  `sdl-requiring-functions 8`. The tool reads the compiled (monomorphized)
  HIR, where the clones call `sdl::*` and require `sdl::Sdl`, so it cannot
  see the source-level independence.
* Measured on the checked source program instead (`traitSource`, a scratch
  script): render.bot makes **34 Canvas operations and 0 calls into sdl**.
  wt makes 34 calls into sdl. In the compiled program, the variant's 34
  sites are exactly wt's 34 calls into sdl.
* A side observation on the census tool: it, and `icyModuleOf` in
  `tests/workload-icy-tower.test`, identify a game module by its file's
  root name. The staged binding has its own `sdl3/render.bot`, whose
  constant initializers call `sdl3::ctypes::c_uint` and the like, and those
  sites are counted under `render`. My first measuring script was misled
  this way, reporting 15 calls into `ctypes`. In the tools' current
  measures it is harmless: the binding's `render.bot` defines no function,
  and `ctypes` is not a game module. It is a trap for a future measure,
  though.
* `tools/escape-candidates.tcl -target linux-x86_64` on the staged variant,
  `canvas-test.bot` and `golden.bot`: `totals:` is empty for all, the same
  as for wt.

## Every diagnostic hit

The experiment's design itself hit none: the variant compiled on the first
attempt. These diagnostics come from probes and from writing the tests.

| code | where | message (exact) |
|---|---|---|
| CONTEXT-FUNCTION-VALUE | golden.bot, a check that draws | `function first_frame requires context recorder::Recorder, render::Canvas, so it can only be called (or bound to another name as a statement): it cannot be passed, returned or stored as a value, because a call through an unknown function value could not prove that context installed` |
| MISSING-CONTEXT | probe: `Canvas.color` with `int` parameters | `render::Canvas is required by this call, but no installed context implements it (install one with "with context EXPR" before the call):` followed by the chain `main -> session -> play -> run -> render::draw -> render::frame` and `directly requires render::Canvas`, then `installed contexts:` with `std::linux::io::LinuxIO (does not implement render::Canvas: no function std::linux::io::color exists: ...)` and `sdl::Sdl (does not implement render::Canvas: parameter 1 requires std::ffi::c::UChar, which does not admit the required int)` |
| AMBIGUOUS-CONTEXT-IMPLEMENTATION | probe: a forwarding `Tee` context (logs, then calls `sdl::OP`) installed beside `sdl::create()` | `render::Canvas is required by this call, and more than one installed context implements it:` / `sdl::Sdl` / `Tee` / `no installed context is preferred over another (there is no ranking and no installation-order preference): install exactly one context implementing render::Canvas where this call runs` followed by the chain `run -> render::draw -> render::frame` |
| UNKNOWN-NAMESPACE (SURFACE MODULE) | contrast: wt render.bot beside the pure modules | quoted in section 2 |
| NATIVE-ONLY | the staged game's `main.bot` on interp, from `-contexts`/`-traits`, which run it | quoted in section 2 |
| LOCKSTEP-UNPROVEN | my test code: `loop entry in entries and i from 0 to n` | `lockstep loop requires equal iteration counts; could not prove length(entries) == max(n, 0) (clause 1 vs clause 2)` |
| MISSING-IMPORT | my test code: `.substring` without `import std::str` | ``namespace "std::str" is not imported; add `import std::str` to use `std::str::substring` (the method-style call ".substring(...)" applies only a function visible by that name)`` |
| METHOD-ELIGIBLE (warning, an error under `-warnings error`) | my test code: `recorder::only(entries, "text")` | ``call to `recorder::only` is eligible for method syntax``. Answered with `entries.only("text")` |
| RETURN-OUTSIDE-CALLABLE | my probe: `return` in a top-level handler | `return outside callable invocation` |

A probe that passed: `type Channel = Int in 0..255` in `render.bot`, with
`fn color(r: Channel, g: Channel, b: Channel) -> bool` and no `import
std::ffi::c`. `-check` printed `ok`: `sdl::color`'s `UChar` parameters
admit a `Channel`, and a recorder taking `int` channels satisfies it too.
`canvas-test.bot` gave the identical value on cranelift. So the abstraction
need not mention a C type (Findings, 2).

## Findings

1. **Satisfaction is structural and by name, so a second canvas cannot sit
   beside Sdl.** `sdl::Sdl` implements Canvas only because `sdl.bot`
   defines `color`, `fill` and the rest with `context sdl: Sdl`. Two
   consequences follow:
   * A forwarding or recording canvas around SDL is ambiguous whenever
     `Sdl` is installed, and its forwarding calls need `Sdl` installed. A
     frame recorder or debug overlay in the real game would need SDL's
     drawing functions renamed, for example to `sdl::draw_color`, plus one
     adapter context in its own module. That is zero-cost, but it is a
     design change.
   * Any context whose owner happens to spell those seven functions would
     satisfy Canvas. stdlib/test.bot keeps its Suite to two functions for
     exactly this reason.
2. **`UChar` leaks a C type into the abstraction.** With `sdl.bot`'s exact
   types, `render.bot` must import `std::ffi::c`. A game domain (`type
   Channel = Int in 0..255`) works with `sdl.bot` unchanged and keeps
   `render.bot` free of C. `int` does not work: MISSING-CONTEXT, quoted
   above.
3. **Tests draw at registration, never inside a check.** This follows from
   the function-value frontier. It works, but it changes the suite's
   failure isolation (section 3). A standalone program such as
   `canvas-test.bot` has no such limit.
4. **No run-time cost, by construction and by measurement.** The NIR is
   identical up to renumbering, the generated-code instruction counts are
   identical, size changes by -16 bytes, and frame time is within noise.
   The clones replace the originals.
5. **Compile-time cost lands on trait-free programs.** The game pays
   nothing new. A suite or tool that imports `render.bot` and loaded no
   trait before pays the second build: about 2x front-end time for
   `golden.bot`.
6. **Clone names change.** Functions on the path are renamed
   (`render::frame<render::Canvas=sdl::Sdl>`, `run<render::Canvas=sdl::Sdl>`)
   in NIR and diagnostics. No icy-tower tool looks functions up by name;
   `audit/icy-tower/tools` read `botlish_fn_*` buckets only.

## Is adopting it advisable?

Yes, with qualifications. For a 42-out, 50-in line change in `render.bot`
and none in `sdl.bot` or `main.bot`, rendering becomes a pure,
backend-independent module. Its output is tested on all four backends: 3
golden tests, plus a recording program whose full log all backends agree
on. The executable and its SDL trace are unchanged.

If adopted, I would:

* declare `Channel` instead of `std::ffi::c::UChar` in `Canvas`;
* keep `recorder.bot` as the game's test canvas;
* add the registration-time tests to `golden.bot`;
* update `tests/workload-icy-tower.test`'s pinned "65 tests" and the
  ICY-TOWER-VERTICAL-SLICE-1.md layering text (render.bot no longer imports
  SDL);
* run the game's change list from AGENTS.md: `tests/workload-icy-tower.test`,
  `audit/icy-tower/mutate.tcl`, the oracle comparison, the warning gate for
  the new and changed corpus programs, and a rebuild and commit of
  `audit/icy-tower/artifacts/icy-tower`.

The price is the golden suite's front-end time roughly doubling (7 s to
about 17 s per compile; the four-backend run 36 s to 69 s). Also, Canvas
cannot be decorated while `Sdl` itself satisfies it. If a recording or
overlay canvas inside the real game is wanted later, rename `sdl.bot`'s
drawing functions and put the Canvas implementation in an adapter module
instead.
