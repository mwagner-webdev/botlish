# ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md -- hiding SDL behind a context

An architectural census, not a feature milestone. The Icy Tower vertical
slice (ICY-TOWER-VERTICAL-SLICE-1.md) threaded an affine `sdl::Video` --
seven fields, six of them C pointers -- through its frame loop: 56 pointer
`.clone()`s, structs taken apart and rebuilt to be used at all, every exit
of the loop carrying the Video back so that `sdl::close` could consume it.
This census first put the game into the architecture Botlish says it
encourages,

```
raw SDL / foreign authority  ->  context airlock  ->  ordinary operations  ->  pure game logic
```

and only then asked which language features are missing. The refactored
game is `examples/games/icy-tower/`; the evidence -- counting tools,
minimal reproducers, design variants, the warning census, the call-trace
comparison -- is `audit/icy-tower/context-refactor/`.

## Contents

1. Result
2. Before / after
3. Final architecture
4. The six questions
5. Remaining affine exposure
6. Context deficiencies
7. Design A against Design B (and the ID variant)
8. Application code quality
9. Behavior preserved
10. The compiler bug found and fixed
11. Warning proposal
12. SDL3 wrapper package implications
13. Language conclusions
14. Recommendation
15. Artifacts and what to run

## 1. Result

**Can Icy Tower hide SDL's affine foreign resources behind contexts with
the current language? Mostly -- yes for everything above the wrapper, by a
workaround inside it.**

* Above `sdl.bot` nothing of SDL's remains: no module but `sdl` names a C
  pointer type, no function outside it takes or returns one, no call
  carries one across a module boundary (38 such calls before, 0 after), no
  struct holding one exists (4 before), nothing is cloned (48 clones in
  render.bot before), taken apart or rebuilt (14 cleanup-plumbing sites in
  main.bot and render.bot before), and no SDL function is called (one
  before). `render.bot` draws with `sdl::fill(x, y, w, h)`; `main.bot`'s
  frame loop carries the world and nothing else. `tests/workload-icy-
  tower.test`'s new `workload-icy-tower-sdl-airlock` pins it.
* The behavior is the same, call for call: over a 2400-frame dummy-driver
  run the SDL call trace -- 204,297 calls with every argument, rectangles,
  strings and colors included -- is identical but for one `SDL_malloc(56)`
  and its `SDL_free` (section 9).
* **The limiting factor: a context cannot hold an affine value.**
  Installing a context struct with a C pointer in it is
  `AFFINE-ERASURE-UNSUPPORTED` (installation takes any value), and so is
  any aggregate holding one -- a struct, a MutableVector (reproducers
  a1, a1b, a2). The context therefore cannot retain the pointers
  themselves. The refactor retains them anyway, the one way current
  Botlish allows: in *native memory*, a 56-byte record written through a
  native edit, whose unrestricted `NativeView` the context holds inside a
  MutableVector member (whose emptiness is the closed state). Each
  operation reads the pointers it needs back through the view. That is
  correct and cheap (+0.7 % instructions a frame), but it steps outside
  the affine discipline through raw memory, needs direct authority (views
  and edits) merely to *store* handles, and moves 90 lines of ceremony into
  the airlock.
* **Observing affine access is not needed.** After encapsulation there is
  no pointer above the airlock to observe; inside it, 6 clones remain (a
  pointer passed to a private helper). The ceremony the vertical slice
  blamed on affine pointers was the application's architecture, not a
  missing parameter mode.

## 2. Before / after

Measured by `audit/icy-tower/context-refactor/tools/census.tcl` from the
front end's HIR (types, call targets, origins; a site is a source
location), except the two spelling measures (marked *); before is commit
6df89a8e's `examples/games/icy-tower/`, after is this commit's.
`counts.txt` has both full outputs.

| metric | before | after |
|---|---:|---:|
| pointer `.clone()`s* (all modules) | 56 | 6 |
| -- of them outside sdl.bot | 48 | 0 |
| functions whose parameters or result hold a C pointer | 24 (sdl 15, render 8, main 1) | 7 (sdl only: private helpers, public for want of module privacy) |
| pointer-holding struct types | 4 (`sdl::Video`, `sdl::Polled`, `render::Drawn`, `Ended`) | 0 |
| destructurings of pointer-holding values | 6 (main 3, render 1, sdl 2) | 0 |
| constructions of pointer-holding values | 16 (main 8, render 2, sdl 6) | 0 |
| cleanup plumbing sites in main.bot and render.bot (the two rows above, there) | 14 | 0 |
| calls carrying a C pointer across a module boundary | 38 (render 34, main 4) | 0 |
| warning-candidate sites (section 11, rules R1-R4) | 40 | 0 |
| SDL C call sites outside sdl.bot | 1 (`SDL_GetPerformanceCounter` in main) | 0 |
| native view/edit operations outside sdl.bot | 0 | 0 |
| modules naming a C pointer type* | 2 (sdl, render) | 1 (sdl) |
| raw-binding imports (`import sdl3::...`) outside sdl.bot* | 3 (main 2, render 1) | 1 (main: `sdl3::scancode`, the key constants) |
| `sdl::close` call sites | 1 | 2 (play; main's NonFiniteFloat handler) |
| functions of sdl.bot requiring `Sdl` (context parameters) | 17 | 20 |
| functions above sdl.bot requiring `Sdl` (transitively) | 13 (main 5, render 8) | 13 (main 5, render 8) |
| module statuses (DIRECT-MODULES.md) | sdl contextualized, all others ordinary | the same |
| code lines (non-blank, non-comment) sdl / render / main | 179 / 120 / 128 | 269 / 107 / 127 |

The last row is the honest cost: the airlock grew by 90 lines while the
application shrank by 14. Of the 90: 40 are the per-operation session
lookup (`session = sdl.open.at(0): on IndexNotFound: return false`, the
view, the pointer bound to a local), 15 the Handles record and its
writer, the rest open's longer failure paths and the context's
lifecycle. Section 8 shows where.

## 3. Final architecture

```
tower.bot  hud.bot  options.bot        pure: no SDL, no clock, no input device
     |
render.bot  main.bot                    ordinary modules: values and sdl:: operations;
     |                                  no pointer, no SDL call, no view or edit
     |   requires sdl::Sdl (13 functions, transitively)
     v
sdl.bot                                 the airlock (status contextualized)
  opaque context struct Sdl:              installed once: with context sdl::create()
      open: MutableVector[Session]        empty = closed; one Session = open
  Session {handles: NativeView[Handles], synced: bool}
  layout Handles (native memory, 56 B)   record, window, renderer, keys, rect, text, event
  operations: open close synced? poll seconds sleep counter
              color clear present fill line text scale
     |   38 SDL call sites, 6 views/edits, all mediated by Sdl
     v
generated/c/sdl3/linux-x86_64/sdl3/    the generated binding (staged by build.sh)
     |
libSDL3 / native memory
```

The authority shape is the one the brief hoped for, measured: `sdl`
holds every raw call (status contextualized, every edge mediated by
`sdl::Sdl`); `main` and `render` hold contextual SDL authority only (13
functions require `Sdl`; none makes a raw call); `tower`, `hud` and
`options` hold none. One raw-binding import remains above the airlock:
main.bot's `sdl3::scancode`, whose `SDL_SCANCODE_*` constants name the
keys the game reads -- values, not authority.

## 4. The six questions

### 4.1 Can a context retain affine foreign resources?

**No, as affine values; yes, once their affinity is shed -- and today
that means native memory.** Exactly:

| attempt | result | reproducer |
|---|---|---|
| a context struct with a `Ptr` field, read in an operation | `AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE` at the read, `AFFINE-ERASURE-UNSUPPORTED` at the installation | a1 |
| the same, destructuring the context local instead of reading the field | the read is accepted (it consumes the *local*); the installation is still `AFFINE-ERASURE-UNSUPPORTED` | a1b |
| a context holding a struct of pointers, or a `MutableVector[Ptr[...]]` | `AFFINE-ERASURE-UNSUPPORTED` at each installation: affinity is compositional | a2 |
| non-affine state that evolves (a `MutableVector[Session]` member: open pushes, close pops) | supported on all four backends; natively the vector header is a GC root of the context slot | b1 |
| pointers stored in a native-memory record, its `NativeView` in the context's vector | supported natively (C calls do not run on the Tcl backends) | b2 |
| the same view as a bare context member | accepted by the front end, `CONTEXT-NATIVE-LOWERING-UNSUPPORTED` natively although a view's word is an immediate | b2b |

In the brief's terms: holding affine pointers is **not supported** (a
deliberate restriction: C-ABI-TYPES.md says "a context struct may not hold
one (installation erases it)"); retaining *resources* is **supported after
a small local refactor** -- for SDL's windows also through SDL's own IDs
(section 7), for anything through native memory -- and the native-memory
form is **supported only by stepping around another intended rule**:
affinity exists to make aliasing visible, and pointers read back from a
record alias freely without a written clone. Native memory is raw by
design (NATIVE-LAYOUT-WRITES.md: "a holder of write authority can pun bits
into a pointer"), which is why making the view is direct authority; the
airlock has that authority anyway, so nothing new leaks, but a wrapper of
a library that needs no raw memory would have to acquire it just to store
its handles.

Why the restriction exists, and why it is not arbitrary: a context
parameter is an ordinary immutable local (CONTEXTS.md, "Context
parameters"), loaded afresh in every function that requires the context.
If the installed value held an affine pointer, every load would be a new
owner of it. A context that *owns* affine members needs a different access
rule for them -- members reached as places, never copied out -- which is
what the MutableVector member already is for unrestricted values (b1) and
what section 6, A, proposes for affine ones.

### 4.2 Can resource ownership stay behind the context boundary?

Yes. `sdl::Video`, `Polled.video`, `Drawn` and `Ended.video` are gone;
`run(world, frames, last, o)` carries the world; render.bot's functions
take a world, a camera, a platform and coordinates. The application-facing
calls are what the brief sketched:

```
{quit, held, failure: unread} = sdl::poll(scancodes())
undrawn = render::draw(next)                 # sdl::color / fill / line / text / ... inside
now = sdl::seconds()
```

### 4.3 What genuinely must escape?

Nothing affine. What leaves the context are values: `Polled {quit: bool,
held: List[bool], failure: str}`, Bools from every drawing operation,
`Float64` seconds, the counter (an Int seed), `synced?()`, and the
declared error `SdlFailed {call: str}`. No C pointer, view, edit or
pointer-holding struct crosses (0 warning-candidate sites). Section 5
lists what stays visible *inside* sdl.bot and why.

### 4.4 How much affine ceremony remains?

Above the airlock none (table, section 2). Inside it: 6 `.clone()`s, all
of the shape `text.clone().log_failure(...)` / `buffer.clone().write_text
(...)`: a pointer handed to a Botlish helper moves, and the same pointer
is needed after the call. One more kind of ceremony is new: an extern call
may not observe a pointer temporary (`AFFINE-TEMPORARY-UNSUPPORTED`), so
each operation binds the pointer it reads from the view before calling SDL
(`renderer = h.renderer` then `renderer.SDL_RenderClear()`): 13 such
bindings. Neither would justify a parameter mode.

### 4.5 Does cleanup become simpler?

Yes, and it became more complete.

* **Centralized.** `sdl::close(failure)` needs no value, so it is called
  where the run ends, not where a value happens to be: `play` after the
  loop, and `main`'s `NonFiniteFloat` handler. The loop's seven exits no
  longer carry anything.
* **Explicit, not automatic.** A context has no scope exit (installation
  is program-wide: CONTEXTS.md item 58, "Before resource struct / RAII");
  close is an ordinary operation. That is enough here.
* **Idempotent and safe after close.** Closing a closed Sdl does nothing;
  every operation of a closed Sdl reports failure (`false`, or poll's
  failure text) instead of touching freed memory -- the vector's emptiness
  is checked before the view is read (b1 shows the protocol).
* **The old guarantee was weaker than it looked.** The vertical slice wrote
  that "the types forced every exit path to carry the Video back". Affine
  is at-most-once, not exactly-once: an affine value may be dropped
  unused (AFFINE-VALUES.md), and the baseline's `play` did drop its Video
  -- without closing SDL -- when `sdl::seconds()` or `tower::new_world`
  failed after `sdl::open` (unreachable in practice: nothing there can
  overflow). Reproducer c3 shows the shape compiling silently. The
  refactor closes on that path too (`main`'s handler), which the affine
  design could not do without threading the value to the handler.
* **Partial initialization** is unchanged and local: `open` releases what
  it made, in reverse, on each failure (identical traces for the SDL_Init
  and SDL_CreateRenderer failures, section 9). It cannot move to the
  installation: `with context EXPR` takes no handler (c1, c1b) and cannot
  be conditional (c2) -- and Icy Tower's `--headless`, `--help` and usage
  errors must open no window -- so the installed context starts closed
  (`sdl::create()` makes no SDL call) and `open` is an operation.
* **Restart** stays pure: a new game is a new World; SDL is not touched.

valgrind's memcheck over 30 and 600 frames: 0 errors, 0 bytes definitely
or indirectly lost (the 600-frame run reports 544 bytes still reachable,
SDL's own).

### 4.6 Does capability structure become clearer?

| module | raw C calls | native views/edits | requires `sdl::Sdl` | status |
|---|---:|---:|---|---|
| sdl.bot | 38 sites, all mediated | 6, all mediated | its own context | contextualized |
| main.bot | 0 SDL (4 calls of libc's `exit`, non-retaining) | 0 | 5 functions, transitively | ordinary |
| render.bot | 0 | 0 | 8 functions, transitively | ordinary |
| tower.bot, hud.bot, options.bot | 0 | 0 | none | ordinary |

Before, the statuses were the same -- DIRECT-MODULES.md's accounting was
already satisfied -- but raw *resources* (not raw calls) leaked upward:
render.bot named `std::ffi::c::Ptr[sdl3::ctypes::SDL_Renderer]` in all 8 of
its signatures and main.bot called `SDL_GetPerformanceCounter` directly.
Directness tracks who makes raw calls; it says nothing about who holds raw
handles. That gap is what the warning of section 11 would cover.

## 5. Remaining affine exposure

Nothing affine escapes the context. Inside sdl.bot:

| what | where | why it is there | language or API? |
|---|---|---|---|
| 7 functions with pointer parameters: `write_text`, `log_failure`, `free_text`, `release`, `remember`, `quit_requested?`, `down?` | sdl.bot | private helpers of the airlock; public because a module has no private members (IMPORTS.md lists them as not done) | language (module privacy) |
| 6 `.clone()`s | log_failure, release, open (3), text | a pointer passed to a helper moves; the caller needs it afterwards | general affine rule; acceptable |
| the `Handles` layout and `Session` struct types | sdl.bot | the native record and its view: the workaround of 4.1 | language (context-owned affine state) |
| the record's own address in its first field | sdl.bot | a view never becomes a pointer again, so `close` reads the address it frees from the record | consequence of the workaround |

A design hazard the refactor met and avoided: a public helper returning the
session's view (`fn handles(context sdl: Sdl) -> NativeView[Handles]`, an
early draft) hands every importer the pointers -- a view is unrestricted
and reading one someone else made is no authority. Reproducer g1 shows an
ordinary module reading a C string pointer out of such a view and passing
it to a `read noescape` C function, with no diagnostic and no directness.
The refactor reads the session inline in each operation instead.

## 6. Context deficiencies

Every reproducer is a `.bot` file of `audit/icy-tower/context-refactor/
repro/` (or a directory of modules) with its expected outcome on each
backend in its header; `tclsh9.0 audit/icy-tower/context-refactor/tools/
repro.tcl` runs all of them (55 runs, all as expected). None needs SDL.

### A. A context cannot retain affine state -- the one that matters

* **Reproducers:** a1 (a pointer field: read and installation), a1b
  (destructured instead of read: installation only), a2 (a struct of
  pointers; a MutableVector of pointers).
* **Current behavior:** `AFFINE-ERASURE-UNSUPPORTED` at `with context`,
  on every backend:

  ```
  error: a1-affine-pointer-in-context.bot:36:1: `context#1643` is an affine
  Holder, which cannot become an argument of the native context#install,
  which takes any value: that position does not carry ownership, so the
  value would be duplicated or lost (keep it in a binding, a parameter, a
  result, a struct field or a List of an affine type)
  ```

  and, for a field read through the context parameter,
  `AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE`. The installation message is
  also a diagnostic-quality bug: it names the hygienic temporary
  (`context#1643`, against AGENTS.md's rule never to print a binding's
  `name`) and its remedies (a binding, a parameter...) do not apply to a
  context, where the truthful one is "a context cannot hold an affine
  value".
* **Desired semantics:** *context-owned affine members.* An installed
  context owns its affine members for the program's lifetime; a function
  requiring the context reaches such a member only as a **place** -- an
  extern call's argument or `clone`'s receiver (observed), or a
  MutableVector/MutableArray member's `push`/`pop`/`take`/`swap` (moved in
  and out, exactly as a vector place is mutated today, MUTABLE-VECTOR.md)
  -- never by copying the context or destructuring it. Natively the slot
  holds the pointer word (an immediate) or the vector header (already a
  root). With that, sdl.bot's Handles record, its self-address and its
  views disappear: `Sdl {renderer: Ptr[SDL_Renderer], ...}` and
  `renderer.SDL_RenderClear()` through the context parameter.
* **Classification:** a **deliberate restriction** today (C-ABI-TYPES.md:
  "a context struct may not hold one (installation erases it)"), and a
  **missing feature** for the architecture contexts are meant to carry:
  DIRECT-MODULES.md's own "Context construction" describes contexts made
  from "a handle a foreign library returns" -- for a C library that handle
  is a pointer, and the pointer is the one thing a context cannot keep. A
  new semantic capability (an access rule for a context's affine members),
  not a bug fix: a follow-up milestone, not part of this census. Note it is
  narrower than observing parameters: it observes only what the
  environment owns, and needs no borrow of a caller's value.

### B. Private state that evolves -- supported

* **Reproducer:** b1 (open pushes a session, close pops it, every function
  requiring the context sees the same vector; use after close is a defined
  outcome; double close closes once), on all four backends.
* A context member of type MutableVector or MutableArray is mutated in
  place (MUTABLE-VECTOR.md, "Context-field receiver mutation") and natively
  rooted (`ctxroot`). For unrestricted state this is exactly the private,
  evolving state an airlock needs. The one gap is A's: the elements cannot
  be affine.
* **A small native gap, recorded, not fixed (b2b):** a context member of
  type `NativeView[L]` is `CONTEXT-NATIVE-LOWERING-UNSUPPORTED` ("a value
  that may be (or contain) a GC-managed heap object"), though a view's word
  is the C address word `(address << 4) | 0b1110` (NATIVE-LAYOUT-VIEWS.md),
  an immediate. CONTEXTS.md's eligibility *principle* ("a leaf must be a
  value whose tagged word is never a heap pointer") admits it; the
  enumeration in `native::lower::ContextLeaves` does not. Not needed here
  -- a session also needs a closed state, which a bare view cannot express
  -- so not fixed.

### C. Context lifetime cannot run cleanup -- explicit close suffices

* **Reproducer:** c3 (an affine handle dropped on an error path: no
  diagnostic; close runs on one path only).
* A context lives as long as the program; there is no scope exit and no
  destructor (CONTEXTS.md item 58 plans `resource` and scoped `with`).
  The census found an explicit, idempotent `close` sufficient and *simpler*
  than the affine design's: it is called where the run ends, needs no
  value, and is safe to call twice or on a closed context. What neither
  design gives is a guarantee that close runs at least once: affinity is
  at-most-once, and a context has no end. For a game that exits through C's
  `exit()` on failure, the operating system's cleanup is the backstop
  either way.
* **Classification:** not a deficiency for this workload; lifecycle
  support remains a planned feature, not a prerequisite.

### D. Ordinary value results without leaking authority -- supported, with one hazard

* Every result that leaves sdl.bot is a value (`Polled`, Bools, Float64,
  an Int, `SdlFailed`); the contextual operations leak nothing.
* **Hazard (g1):** a native view is unrestricted, and reading a view
  someone else made needs no authority. A contextualized module that
  returns its record's view hands every importer the pointers in it, and
  an ordinary importer can pass one to a `noescape` C function without
  becoming direct. No diagnostic. Not a context-system bug -- a view is
  meant to be shareable -- but the most likely way for an airlock to leak,
  and the reason section 11's rule includes views (R3).

### E. Context nesting and wrapping -- composition, not encapsulation

* **Reproducer:** e1 (`e1-wrapper-context/`: a wrapper context holding the
  lower layer's context *value* does not install it; the entry program
  gets MISSING-CONTEXT with the chain `wrapper::sprite -> lowlevel::
  allocate`; installing both, in order, runs).
* What composes: a module can turn a **direct module's** raw authority into
  its own context (e1's wrapper mediates `raw.bot`'s direct calls with its
  own Platform context: status contextualized) -- the SDL airlock is this.
  What does not: a context cannot encapsulate a **lower context**. A
  requirement is satisfied only by an installation, never by a value a
  wrapper holds; installation is the entry program's alone; so every layer
  of `OS -> SDL -> game platform` is installed by the entry program, in
  dependency order, and appears in requirement chains. And one value per
  context type can be installed: no context per window.
* **Classification:** deliberate (contexts are static environment
  dependencies, CONTEXTS.md section 2) and acceptable for dependency
  injection -- the entry program *should* see what environment it runs in.
  Its consequence for a package is real, though: SDL root, window and
  renderer cannot be three nested contexts; they are one root context and
  a table (section 12).

### G. Installation is unconditional, infallible and program-wide

(A category the brief did not list.)

* **Reproducers:** c1 (a constructor with a declared error at `with
  context`: `UNHANDLED-ERROR`), c1b (a handler block after `with context
  EXPR`: a syntax error), c2 (installation inside the function that plays:
  `CONTEXT-INSTALLATION-UNSUPPORTED`, then `MISSING-CONTEXT`).
* Consequence: a resource that may fail to open, or that a run may not
  want at all (Icy Tower's `--headless`, `--help` and usage errors open
  no window), cannot be acquired *by* installation. The airlock installs
  closed and opens by an operation -- which needs B's mutable state.
  Supported after a small local refactor; it is why the refactored
  context's member is a vector.
* **Classification:** deliberate restrictions of the first context
  milestone (CONTEXTS.md items 54 and 58 plan scoped installation and
  resources). Mild here.

### F. No language deficiency -- above the airlock

For the application (main.bot, render.bot) the current language already
supports the intended shape completely: no ceremony remains, and nothing
the brief listed as a possible deficiency (observing parameters, borrow
syntax, non-consuming field reads) is needed by code that uses the
airlock. The deficiencies are the airlock's own: A (and its native gap),
plus two that are not context rules -- no private module members (section
5) and the diagnostic text of A.

## 7. Design A against Design B (and the ID variant)

Three designs were built to the same reference behavior -- the same
summaries for seeds 7 and 11 (also under GC stress), the same SDL_Init and
SDL_CreateRenderer failure messages and exit statuses, memcheck clean --
so their costs compare directly. Each has its directory and NOTES.md under
`audit/icy-tower/context-refactor/variants/`.

* **Design B, retained context state** (the committed game): the context
  owns the session; pointers in a native record behind a view.
* **Design B', retained context state through SDL's IDs** (`variants/ids/`):
  the same public operations -- render.bot and main.bot compile unchanged
  against it -- but the session is `{window: SDL_WindowID, synced}`: every
  operation recovers the window (`SDL_GetWindowFromID`) and its renderer
  (`SDL_GetRenderer`), and allocates and frees its own scratch memory. No
  native memory is retained and nothing in the context is a view.
* **Design A, opaque resource values** (`variants/opaque-values/`): no
  state in a context (an authority-only `Sdl {tag: unit}` mediates); an
  `opaque struct Video` holds the pointers; `open` returns it, `close`
  consumes it, every operation takes it -- and, with no observing
  parameter, must hand it back.

| | baseline | B (committed) | B' (IDs) | A (opaque values) |
|---|---:|---:|---:|---:|
| pointer clones (all / outside sdl.bot) | 56 / 48 | 6 / 0 | 3 / 0 | 11 / 0 |
| calls carrying a pointer across modules | 38 | 0 | 0 | 7 (the opaque Video) |
| raw pointer representation crossing (R2) | 37 | 0 | 0 | 0 |
| pointer-holding struct types | 4 | 0 | 0 | 5 |
| main.bot: `Ended` exits carrying the handle / handle destructurings | 8 / 3 | 0 / 0 | 0 / 0 | 8 / 3 |
| code lines sdl / render / main | 179 / 120 / 128 | 269 / 107 / 127 | 250 / 107 / 127 | 239 / 109 / 133 |
| SDL C calls a frame (callgrind) | 89 | 89 | 319 | 89 + the list's |
| instructions a frame vs B | -0.7 % | -- | +3.6 % | +13 % CPU time (the display list) |
| use after close / double close | static error | run-time no-op / `false` | the same as B | **static error** (USE-AFTER-MOVE) |
| forgotten close | silent | silent | silent | silent (both leak; valgrind finds it) |
| native memory retained to hold handles | -- | 56 B record | none | -- |
| retains textures, streams, any pointer | yes | yes | **no** (IDs exist for windows, joysticks, gamepads, haptics, sensors only) | per value, but not inside a display list |

**Design A's honest spelling.** A's agent wrote three spellings of the
same 26-line sample (`walls`, `player`) and kept the cheapest:

* *S1, a result struct per operation* (`{video: v1, ok: shade} =
  v0.color1(...)`): 49 lines, handles numbered `v0`..`v5` (a scope cannot
  rebind a name);
* *S2, a failure flag inside the value* (calls chained,
  `video.color(...).fill(...)`): 37 lines;
* *S3, a display list*: render.bot's functions return
  `List[sdl::Command]`, and one `sdl::show(video, commands)` per frame
  makes the calls: 22 lines. The variant uses it.

S1 and S2 ran into three language facts, each with its diagnostic:
a function holding the handle may not fail (the handle dies with the
callee: USE-AFTER-MOVE in the caller's handler), a handler covers one call
and not its arguments (`row(std::float64::from_int(k) * brick, camera): on
NonFiniteFloat:` leaves `from_int` UNHANDLED-ERROR), so every fallible
computation is lifted into a helper; and a loop cannot thread an affine
value (AFFINE-NOT-DEFINITELY-LIVE), so each of render's 4 drawing loops
becomes a recursive helper. S3 avoids all three by changing the rendering
style from immediate to retained -- the affine handle forces it -- at
about 13 % more CPU a frame (81 Command values allocated a frame). And a
display list must be unrestricted data: an affine texture cannot ride in
it (AFFINE-LIST-OPERATION-UNSUPPORTED, USE-AFTER-MOVE when one texture is
drawn twice), so textures would again be named by unrestricted ids into a
table -- the retained design.

**Which current semantics make cleaner, safer code.** For Icy Tower,
Design B. It removes everything above the airlock (A keeps main.bot's
handle threading: 8 exits, 3 destructurings, 3 close sites), it is the only
design in which immediate-mode drawing costs nothing, and it centralizes
cleanup. Design A is the safer one in one respect: use after close and
double close are compile-time errors, where B makes them defined run-time
outcomes (`false`, a no-op). Neither catches a forgotten close.

**The ID variant** shows that the retained design does not depend on
native memory where the library offers non-affine handles -- and that this
is rarely enough. Every draw paid `SDL_GetRenderer`, a locked, string-keyed
property lookup costing more than the draw call it precedes (915 against
244 instructions for `SDL_SetRenderDrawColor`), and per-call scratch moved
correctness from structure to hand-written free-on-every-path code that no
diagnostic checks (a dropped pointer is silent). Of SDL3's object types,
only windows, joysticks, gamepads, haptics and sensors round-trip through
an ID; textures, audio streams, surfaces, cameras, I/O streams and every
GPU resource do not. SDL's property sets could hold any pointer under a
name, but the binding gives the name parameters no contract (Botlish bytes
cannot be lent to them) and binds none of SDL's `SDL_PROP_*` names.

### 7.1 A context trait between render.bot and SDL

`variants/canvas/` takes Design B one step further: render.bot declares

```
context trait Canvas:
    fn color(r: std::ffi::c::UChar, g: std::ffi::c::UChar, b: std::ffi::c::UChar) -> bool
    fn clear() -> bool
    fn present() -> bool
    fn fill(x: Float64, y: Float64, w: Float64, h: Float64) -> bool errors NonFiniteFloat
    fn line(x1: Float64, y1: Float64, x2: Float64, y2: Float64) -> bool errors NonFiniteFloat
    fn text(x: Float64, y: Float64, text: str) -> bool errors NonFiniteFloat
    fn scale(factor: Float64) -> bool errors NonFiniteFloat
```

and its drawing functions require `context canvas: Canvas` and call
`canvas.fill(...)`; it imports no SDL module. `sdl::Sdl` satisfies Canvas
through sdl.bot's own functions with **no change to sdl.bot or main.bot**
(`main.tcl -traits`: `context sdl::Sdl implements render::Canvas (color ->
sdl::color, ...)`), and a recording context in a test program (a
`MutableVector[str]` log) satisfies it too. Results:

* **It works and costs nothing at run time.** The trait plan clones the 8
  render functions and the 3 of main.bot on their path, each clone
  replacing its original; the NIR is the committed game's up to
  renumbering, the generated code's instruction counts are identical, the
  executable 16 bytes smaller, and the SDL call trace identical (204,299
  calls, `diff` empty). Every reference behavior holds.
* **Rendering becomes testable on every backend.** The recording program
  draws `tower::new_world(7, 1)` (92 commands) and the world after 600
  frames (81 commands, the HUD reading SCORE 260, FLOOR 26, BEST 29.1 M,
  TIME 10.0, the player's rectangle at x 262.8) with identical logs on
  interp, compile, cranelift-generic and cranelift, also under GC stress.
* **But a golden test cannot draw inside its check.** A check is stored as
  a function value, and a function requiring a context cannot be a value
  (`CONTEXT-FUNCTION-VALUE`: "function first_frame requires context
  recorder::Recorder, render::Canvas, so it can only be called"). Drawing
  when the suite registers its cases works -- 3 rendering tests, 68 of 68
  passing on four backends, and a planted spacing bug fails 3 of them --
  at the price of failure isolation (an unhandled error at registration
  aborts the suite) and of one shared recorder (one installed value per
  context type).
* **Satisfaction is structural and by name.** A forwarding or recording
  canvas cannot sit beside `sdl::Sdl` (`AMBIGUOUS-CONTEXT-IMPLEMENTATION`:
  "no installed context is preferred over another"), so decorating the
  real canvas (a frame recorder, a debug overlay) would need sdl.bot's
  drawing functions renamed and an adapter context of its own module.
  And with sdl.bot's exact types the trait names a C type
  (`std::ffi::c::UChar`); a game domain (`type Channel = Int in 0..255`)
  satisfies just as well and keeps render.bot free of C.
* **Front-end time doubles for a program that loaded no trait before**:
  golden.bot's `-check` goes from 7 s to 17 s (TRAITS.md's second build),
  its four-backend run from 36 s to 69 s. The game itself already paid
  it (main.bot imports `std::io`).

**Not adopted into the game**, deliberately: the gain (render.bot
testable) comes with a doubled front end for the workload's suite in every
CI run, a test pattern (draw at registration) that is a workaround of the
function-value frontier, and a coupling of sdl.bot's function names to a
trait contract. It belongs in the package design instead (section 12),
where an adapter module can own the implementation.

**A hybrid is the package shape** (section 12): B's ownership and
lifetime (one root context, one close), and, where several resources of a
kind exist, unrestricted typed handles -- indices into the context's table
-- which is what both A (textures in a display list) and B' (IDs) end up
needing.

## 8. Application code quality

**Where the ceremony was.** Before, render.bot's walls:

```
fn walls(renderer: std::ffi::c::Ptr[sdl3::ctypes::SDL_Renderer], rect: std::ffi::c::Ptr[sdl3::ctypes::SDL_FRect], camera: tower::Camera) -> bool errors NonFiniteFloat, NativeEditNull:
    shade = renderer.clone().color(54, 64, 96)
    left = renderer.clone().fill(rect.clone(), 0.0, 0.0, tower::wall, tower::view_height)
    right = renderer.clone().fill(rect.clone(), tower::view_width - tower::wall, 0.0, tower::wall, tower::view_height)
    ...
        a = renderer.clone().line(0.0, y, tower::wall, y)
```

after:

```
fn walls(camera: tower::Camera) -> bool errors NonFiniteFloat:
    shade = sdl::color(54, 64, 96)
    left = sdl::fill(0.0, 0.0, tower::wall, tower::view_height)
    right = sdl::fill(tower::view_width - tower::wall, 0.0, tower::wall, tower::view_height)
    ...
        a = sdl::line(0.0, y, tower::wall, y)
```

The signature lost two raw pointer types and a native-memory error
(`NativeEditNull` is the airlock's business now: an operation that cannot
write its scratch rectangle reports `false`, like any failed draw). Every
render function's error list is now `NonFiniteFloat` alone -- the one
failure that belongs to the caller's numbers.

The draw step, before -- the Video taken apart so its pointers could be
cloned into `frame`, rebuilt into the result so the loop could carry it:

```
fn draw(video: sdl::Video, world: tower::World) -> Drawn:
    {window, renderer, keys, rect, text, event, synced} = video
    drawn = renderer.clone().frame(rect.clone(), text.clone(), world):
        on NonFiniteFloat:
            false
        on NativeEditNull:
            false
        on IndexNotFound:
            false
    ...
    Drawn {video: sdl::Video {window: window, renderer: renderer, keys: keys, rect: rect, text: text, event: event, synced: synced}, synced: synced, failure: failure}
```

after:

```
fn draw(world: tower::World) -> str:
    drawn = frame(world):
        on NonFiniteFloat:
            false
    if drawn:
        return ""
    "drawing a frame"
```

The loop, before and after (two of its seven exits):

```
fn run(video: sdl::Video, world: tower::World, frames: int, last: Float64, o: options::Options) -> Ended:
    ...
    {video: polled, quit, held, failure: unread} = video.poll(scancodes())
    if unread != "":
        return Ended {video: polled, world: world, frames: frames, failure: unread}
    ...
    {video: drawn, synced, failure: undrawn} = polled.draw(next)
    ...
    drawn.run(next, frames + 1, now, o)

fn run(world: tower::World, frames: int, last: Float64, o: options::Options) -> Ended:
    ...
    {quit, held, failure: unread} = sdl::poll(scancodes())
    if unread != "":
        return Ended {world: world, frames: frames, failure: unread}
    ...
    undrawn = render::draw(next)
    ...
    next.run(frames + 1, now, o)
```

**Where it went.** Not every operation got shorter. The airlock's `fill`,
before and after:

```
fn fill(renderer: std::ffi::c::Ptr[sdl3::ctypes::SDL_Renderer], rect: std::ffi::c::Ptr[sdl3::ctypes::SDL_FRect], x: Float64, y: Float64, w: Float64, h: Float64, context sdl: Sdl) -> bool errors NonFiniteFloat, NativeEditNull:
    e = std::binary::native::edit(sdl3::layouts::SDL_FRect, rect)
    std::binary::store(e, sdl3::layouts::SDL_FRect.x, x)
    ...
    renderer.SDL_RenderFillRect(rect)

nomethod fn fill(x: Float64, y: Float64, w: Float64, h: Float64, context sdl: Sdl) -> bool errors NonFiniteFloat:
    session = sdl.open.at(0):
        on IndexNotFound:
            return false
    handles = session.handles
    rect = handles.rect
    e = std::binary::native::edit(sdl3::layouts::SDL_FRect, rect):
        on NativeEditNull:
            return false
    std::binary::store(e, sdl3::layouts::SDL_FRect.x, x)
    ...
    renderer = handles.renderer
    renderer.SDL_RenderFillRect(rect)
```

Nine operations open with the same four lines (36 in all) and bind the
pointer they need before the C call (10 bindings: an extern call cannot
observe a pointer temporary). A helper returning the renderer would remove
them -- and hand every importer a raw pointer, since nothing in a module is
private (section 5). `open` grew a record, an edit, a view and two
impossible-failure handlers; `close` reads the pointers back from the
record it then frees. That is the price of the workaround of 4.1, paid
once, in the one module whose job is to pay it.

**Assessment**, application side (main.bot, render.bot):

| | before | after |
|---|---|---|
| FFI concepts the code must understand | C pointer types, `.clone()`, affine moves, destructure-and-rebuild, native-memory errors (`NativeEditNull`, `IndexNotFound`) | none: operations, Bools, a failure string, one declared error (`sdl::SdlFailed`) |
| lifetime boilerplate | 14 sites carrying the Video to `close` | 2 `sdl::close` calls |
| operation density (render.bot) | 34 SDL calls in 120 code lines, each with 1-2 clones | 34 SDL calls in 107 code lines, none with anything but its own arguments |
| visibility of authority | every render signature names the renderer | the `sdl::` prefix; the requirement is inferred (`main.tcl -contexts` explains it) |
| testing the pure logic | unchanged: tower/hud/options run on every backend | unchanged; rendering is still testable only with SDL (section 7: a context trait makes it testable) |
| reasoning about cleanup | follow the Video through every exit | two calls; close is idempotent and safe after close |

## 9. Behavior preserved

The refactor changes no game semantics and no SDL usage. Evidence, all
on the refactored executable (`audit/icy-tower/artifacts/icy-tower`,
rebuilt by build.sh) against the baseline built from commit 6df89a8e:

| check | result |
|---|---|
| SDL call trace, 2400 dummy-driver frames, seed 7 (`tools/trace-compare.sh`: an LD_PRELOAD interposer logging every draw, poll, clock and resource call with its arguments -- rectangles and floats in C99 hex, strings, colors) | 204,297 calls before, 204,299 after; identical except one `SDL_malloc(56)` after the scratch allocations and its `SDL_free` before SDL_Quit (the Handles record) |
| traces of the failure paths (`SDL_VIDEO_DRIVER=nosuch`, `SDL_RENDER_DRIVER=nosuch`) | identical (the record is allocated after the last failure point that logs) |
| `--headless` | no SDL call at all, before and after (the interposer never runs) |
| summaries: headless and dummy driver, 600 frames, seed 7; 2400 frames (a restart); 120 frames seed 11 with and without `BOTLISH_NATIVE_GC_STRESS=1`; 600 frames under GC stress | identical to the baseline and to the oracle |
| `tests/workload-icy-tower.test` (16 tests: the 15 of the vertical slice and the new airlock test) on interp and compile, executables included (the package-owned libSDL3 built) | all passed |
| `golden.bot`, 65 tests, four backends | passed (the pure modules are unchanged) |
| `audit/icy-tower/mutate.tcl` | 26 of 26 mutants killed |
| `python3 audit/icy-tower/oracle.py compare` | 0 differences |
| valgrind memcheck, 30 frames (the test) and 600 frames | 0 errors; 0 bytes definitely, indirectly or possibly lost |
| `audit/icy-tower/tools/xvfb-session.py` (an SDL3 built with its x11 driver, Xvfb, XTest) | 6 of 6 checks, before and after: Right moves the player right and Left back, Escape exits 0, the autopilot plays 1513 frames in 25 s (60 Hz vsync; baseline 1512), a window-manager close ends the run cleanly |
| the airlock test on the baseline sources | fails, 57 findings (it can fail) |

**Cost** (callgrind, unstripped builds, 240 minus 60 frames, seed 7):

| per frame | before | after |
|---|---:|---:|
| instructions, dummy driver | 2,140,843 | 2,155,662 (+0.7 %) |
| -- in the program | 487,181 | 500,334 |
| -- of them runtime helpers | 181,998 | 193,336 |
| -- of them generated code | 26,032 | 27,736 |
| program mallocs | 524.9 | 520.9 |
| C calls into SDL | 89 | 89 |
| instructions, headless | 220,646 | 220,645 |

About 150 instructions per SDL operation for reaching the session -- the
vector's bounds-checked `at`, the view's field loads -- and 4 fewer
allocations a frame (no Polled, Drawn or rebuilt Video). Not measurable
in wall time against SDL's software renderer.

## 10. The compiler bug found and fixed

The first context-shaped build crashed the front end:

```
core::native: no native named "extern#exit#1" (NONE)
    (procedure "core::native::metadata") ... hir::mutvec::OpKind ... hir::mutvec::verify
```

Not a context rule: a compiler bug the new shape exposed. An `extern c
fn`'s binding is named after its native (`extern#exit`, hygiene's
qualifyExterns). When the same extern is called both from a function the
trait plan clones -- `main` and `session` require `std::io::IO` through
`std::io::write_error_line` -- and from one it does not -- `play` --
the clone's reference resolves to the root native binding `extern#exit`,
and hygiene's ProtectEarlierRefs renames the extern's own binding to
`extern#exit#1`. The baseline had that rename too; it crashed nothing
because no analysis asked which native the call was. The refactor added a
MutableVector (Sdl's member), and `hir::mutvec::verify` asks
`hir::affine::NativeName` of every call, which returned the binding's
name and fed `extern#exit#1` to the native registry.

Fixed in `hir::affine::NativeName`: a root binding's native is its
`symbol`'s name (what `hir::cardinality::NativeName` and
`hir::construction::NativeName` already read), the binding name only for
a binding without a native symbol. Regression test:
`tests/c-ffi.test`'s `cf-renamed-binding-native-name` (a 24-line program:
fails without the fix with the same error, passes with it); reproducer
f1. Checked as AGENTS.md asks for a change to hir/affine.tcl: the
affine, coroutine, mutable-vector, mutable-array, list-length and c-ffi
test files and their golden suites on all backends (all passed),
`audit/affine/tools/fuzz.tcl` on seeds 3, 17 and 41 (120 programs, 0
disagreements), `audit/affine/tools/mutate.tcl` (29 of 29 mutants killed) and
`audit/coroutines/tools/mutate.tcl` (52 of 52 killed).

## 11. Warning proposal

TODO(after agents)

## 12. SDL3 wrapper package implications

A sketch the refactor and its variants support -- not a final design, and
nothing of it is built. Four layers:

```
application        ordinary modules: values, operations, its own context traits (Canvas)
     |               requires the root context (inferred), never names SDL
sdl3 (the airlock) one contextualized module (or a few with one owner):
     |               opaque context struct Sdl -- SDL's lifetime, every resource table
     |               operations taking and returning values and typed handles
     |               adapters implementing the application-facing context traits
sdl3::raw          tiny helpers below the airlock: scratch records, C strings,
     |               event-type and key-state layouts (EventType, KeyState)
generated/c/sdl3   the generated binding: extern declarations, constants, layouts
```

**What the evidence decides.**

* **Retain resources inside one root context; hide raw pointers entirely.**
  Design B removed every pointer, clone and cleanup site above the airlock
  (section 2); Design A could not remove main.bot's handle threading, and
  its immediate-mode spellings cost 37-49 lines where B costs 26 (section
  7). No public operation of the package should take or return a C
  pointer, a native view or edit, or a non-opaque struct holding one -- the
  warning of section 11 enforces exactly that boundary.
* **One root context, not one context per subsystem or window.** A context
  type is installed once, only by the entry program, and a wrapper cannot
  install or hide a lower one (6.E, 6.G). So `Sdl` owns SDL's lifetime and
  a *table* per resource kind (windows, renderers, textures, audio
  streams), and close releases everything it holds before SDL_Quit -- the
  ordering Design A cannot express once SDL's lifetime is its own value
  (its notes, "Multiple windows").
* **Multiplicity through unrestricted typed handles.** A window or a
  texture the application names is an opaque, non-affine handle (`opaque
  struct Texture: slot: int, generation: int`) into the root context's
  table: copyable into display lists and loops (where an affine texture
  cannot go: AFFINE-LIST-OPERATION-UNSUPPORTED), checked at each use (a
  stale handle is a declared error, as SDL's own window IDs are a NULL),
  never a pointer. Both other designs converge here: B' uses SDL's IDs
  where they exist (windows, input devices), A needs ids for textures in a
  display list.
* **Retention mechanism: native records today.** SDL's IDs cover windows,
  joysticks, gamepads, haptics and sensors and cost a hash lookup per
  renderer access (B'); textures, streams, surfaces and GPU objects have
  only their pointer. Until contexts can own affine members (6.A), the
  package keeps its pointers in native records held by views inside
  MutableVector members, as Icy Tower's sdl.bot does -- an implementation
  detail the API does not show, so it can change when 6.A does.
* **Stateless rendering above a retained renderer.** Icy Tower's draw
  operations take coordinates and colors and nothing else; a package
  exposes the same, plus handles for textures. Whether the application
  draws immediately (B) or builds a display list (A's S3) is the
  application's choice; with B it costs nothing either way.
* **Application-facing context traits, implemented by adapters.** The
  Canvas variant makes rendering code SDL-free and testable on all four
  backends with a recording canvas at zero run-time cost (7.1). Because
  satisfaction is structural and by name, the package should implement
  such traits in an adapter module of its own (its functions named after
  the trait's requirements, its context forwarding to the root), not by
  making the root context's own functions match a trait -- that keeps the
  root's names free and lets a test or a decorator install a different
  implementation.
* **Event polling as value production.** `poll` returns a value (quit, the
  keys asked for, a failure). A package would return a List of event
  values; that needs `SDL_Event` read field by field, which the generated
  binding cannot yet describe (C bool fields: ICY-TOWER-VERTICAL-SLICE-1.md,
  "FFI").
* **Error retrieval inside the airlock.** `SDL_GetError`'s text reaches the
  user only through `SDL_Log` today (no C-string decoding); a package would
  put it into the declared error's payload (`SdlFailed {call, message}`)
  once a C string can become a String.
* **Lifecycle.** `open` and `close` as idempotent operations on a context
  installed closed (6.G); close safe after close. Use-after-close is a
  run-time `false`, not a compile error (Design A's one advantage).
* **Headless and tests.** A headless SDL is the same root context opened
  with the dummy or offscreen driver; tests of application rendering use
  a recording implementation of the application's traits (7.1), within the
  limits of one installed value per type and no context in a golden
  check.

**What a package needs from the language, in order** (none blocks it):
module privacy (so the airlock's helpers and lookups need not be public,
section 5); context-owned affine members (6.A, to retire the native
records); C-string decoding and C bool layout fields (FFI); the native
context slot for views (6.B, small).

## 13. Language conclusions

**Problems caused by the original application architecture** (fixed by the
refactor, no language change): the Video threaded through the loop and
every exit; 48 pointer clones in render.bot; destructure-and-rebuild in
`poll` and `draw`; render signatures naming raw pointer types and
native-memory errors; an SDL call (`SDL_GetPerformanceCounter`) in the
entry program; cleanup reachable only where the Video was. Every one was a
consequence of resource *values* travelling above the wrapper -- the
vertical slice's own list item "affine pointers in ordinary code" was
this.

**Problems contexts already solve:** authority confinement (unchanged and
already right before: sdl contextualized, everything else ordinary);
ownership confinement, once the state lives in the context (0 pointers
above the airlock); evolving private state (a MutableVector member,
mutated in place, natively rooted); centralized, idempotent, value-free
cleanup; failure reporting as ordinary values and declared errors.

**Genuine context-system deficiencies:**

1. A context cannot own affine state (6.A) -- the only one that forced a
   workaround, and the workaround (pointers in native memory behind a
   view) is sound but steps around affinity and needs raw-memory
   authority to store handles. A new capability, proposed for a
   follow-up milestone.
2. The native context slot omits views although they are immediates
   (6.B, b2b): a small, principled gap; not needed here.
3. Installation is unconditional, infallible, top-level and one value per
   type (6.G, 6.E): deliberate; it pushes resource lifetime into state
   inside a program-lifetime context, and multiplicity into a table.
4. Wrapping composes requirements but cannot hide a lower context (6.E):
   deliberate; every layer is visible to the entry program.

**General affine-type deficiencies that remain after encapsulation:** none
that justify a feature. Inside the airlock, 6 clones (a pointer passed to
a helper moves) and 10 pointer bindings (an extern call cannot observe a
temporary). Affine is at-most-once, not exactly-once (c3): the old design's
cleanup was never guaranteed by the types, and the new one does not need
it to be.

**FFI-specific issues** (unchanged by this census; ICY-TOWER-VERTICAL-
SLICE-1.md, "FFI"): no layout for `SDL_Event` (C bool fields), no Botlish
storage for a non-byte pointee (so the scratch rectangle is native
memory), no `read noescape` contract on `SDL_RenderDebugText`'s string,
no C-string-to-String (so SDL's error text can only be logged by SDL).

**Package and library design issues:**

* **No private module members** (IMPORTS.md). The airlock's seven
  pointer-taking helpers are public; that is harmless only because an
  importer cannot mint a non-null pointer without its own direct
  authority -- and it forced every operation to repeat its session lookup
  rather than share a helper that would return a pointer or a view.
  `release` was made SDL_Quit-free for the same reason: anything public is
  callable by every importer that has the context installed.
* **Views are unrestricted** (g1): an airlock leaks by returning one; the
  language cannot tell an intended view (a parsing helper's) from a leaked
  one, so this is a warning's job, not a rule's.
* **One installed value per context type** shapes any multi-resource
  wrapper into a root context with a table of resources and non-affine
  handles into it (section 12).
* **Diagnostics:** the context-installation case of
  `AFFINE-ERASURE-UNSUPPORTED` prints a hygienic temporary and irrelevant
  remedies (6.A).

## 14. Recommendation

TODO

## 15. Artifacts and what to run

| path | what |
|---|---|
| `examples/games/icy-tower/sdl.bot`, `render.bot`, `main.bot` | the refactored game (tower.bot, hud.bot, options.bot unchanged) |
| `audit/icy-tower/artifacts/icy-tower` | the executable, rebuilt by build.sh |
| `audit/icy-tower/context-refactor/README.md` | the index of the evidence below |
| `audit/icy-tower/context-refactor/counts.txt`, `tools/census.tcl` | the before/after counts (section 2) |
| `audit/icy-tower/context-refactor/repro/`, `tools/repro.tcl` | the minimal reproducers and their runner (section 6) |
| `audit/icy-tower/context-refactor/tools/sdltrace.c`, `tools/trace-compare.sh` | the call-trace comparison (section 9) |
| `audit/icy-tower/context-refactor/variants/` | the ID variant, Design A, the Canvas trait (section 7) |
| `audit/icy-tower/context-refactor/tools/escape-candidates.tcl`, `warning-census/` | the warning candidate's instrument and the repository census (section 11) |
| `tests/workload-icy-tower.test` | `workload-icy-tower-sdl-airlock` (new): no pointer, view, edit or SDL call outside sdl.bot |
| `tests/c-ffi.test` | `cf-renamed-binding-native-name` (new): the compiler fix of section 10 |
| `hir/affine.tcl` | the fix: `hir::affine::NativeName` |
| `AGENTS.md`, "Workloads (examples/games/icy-tower)" | the airlock rule and the trace comparison added to what to run |

When changing the game's SDL side: `tests/workload-icy-tower.test`
(executables with the package-owned libSDL3), `audit/icy-tower/mutate.tcl`,
`python3 audit/icy-tower/oracle.py compare EXECUTABLE`,
`audit/icy-tower/context-refactor/tools/trace-compare.sh OLD NEW` (the
trace must be the same unless the change means to change it), the Xvfb
session, and `tclsh9.0 audit/icy-tower/context-refactor/tools/repro.tcl`
when the context, affine or native-view rules change (a reproducer whose
outcome changes is a census finding that changed: update the report).
