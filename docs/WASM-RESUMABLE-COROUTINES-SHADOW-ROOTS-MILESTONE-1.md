# WASM-RESUMABLE-COROUTINES-SHADOW-ROOTS-MILESTONE-1.md

Milestone A0 of the WebAssembly roadmap
(WASM-TARGET-AND-COROUTINE-ARCHITECTURE-MILESTONE-1.md, section 13): general
coroutines without a stack switch, and the ShadowOnly root plan, as
production code of the native backend, run and verified on the native
`fallback-roots` build. No WebAssembly code is generated.

> A suspended coroutine is its chain of heap frames, reachable from its
> handle; running code keeps one LIFO shadow stack per Vm. Every coroutine
> the language allows runs this way when the runtime has no stack switch,
> with fusion or without it, with the same values, releases, errors and
> identities as the interpreter and the stackful native runtime.

Claims are marked as in the architecture report: **[fact]** what the code
does (with its source location), **[obs]** what a command printed in this
session's 4-core Linux x86-64 container (with the command), **[inf]** what
follows from facts and observations but was not run as such.

## Contents

1. [Executive result](#1-executive-result)
2. [Baseline and current-main differences](#2-baseline-and-current-main-differences)
3. [Production resumable-lowering architecture](#3-production-resumable-lowering-architecture)
4. [Frame layout, ownership and hand-off ABI](#4-frame-layout-ownership-and-hand-off-abi)
5. [Liveness and suspension state representation](#5-liveness-and-suspension-state-representation)
6. [ShadowOnly root architecture](#6-shadowonly-root-architecture)
7. [Root publication defect and its fix](#7-root-publication-defect-and-its-fix)
8. [GC tracing and precision evidence](#8-gc-tracing-and-precision-evidence)
9. [Errors, cleanup, abandonment and context semantics](#9-errors-cleanup-abandonment-and-context-semantics)
10. [Fusion integration and its capability rule](#10-fusion-integration-and-its-capability-rule)
11. [Golden and focused test results](#11-golden-and-focused-test-results)
12. [GC-stress and mutation-test results](#12-gc-stress-and-mutation-test-results)
13. [Performance and allocation measurements](#13-performance-and-allocation-measurements)
14. [CI integration](#14-ci-integration)
15. [Known limitations and remaining risks](#15-known-limitations-and-remaining-risks)
16. [Implications for the next Wasm milestones](#16-implications-for-the-next-wasm-milestones)
17. [Files and reproduction](#17-files-and-reproduction)

## 1. Executive result

**Implemented** [fact]:

* **A resumable lowering** (`native/src/codegen/resumable.rs`): a NIR-to-NIR
  pass of the native code generator that makes every function that may
  yield (fusion's `yielding()`, exact because of UNWRAPPED-YIELD) a state
  machine over a heap frame. It runs after fusion, on every program the
  driver loads, wherever the runtime has no stack switch; it is never
  optional there and never runs where coroutines switch stacks.
* **A frame object** (`native/src/runtime/resumable.rs`'s `FrameObj`,
  heap kind `KIND_FRAME`, reported as `ResumeFrame`): resume point, traced
  count, suspended callee frame, then tagged and raw slots, traced exactly
  (`callee` and the first `ntagged` tagged slots).
* **A frame hand-off ABI with no Vm slots**: a hidden trailing frame
  parameter down, the frame itself as the suspension result up (section 4).
* **Inline frame operations**: `frisframe`, `frpoint`, `frcallee`,
  `frsave`, `frrestore` are loads, stores and compares in the generated
  code (`codegen/clif.rs`); only allocation (`rt_frame_new`) and the
  coroutine object's transport (`rt_co_suspend`, `rt_co_msg`) call the
  runtime, once per suspension or resume, never per chain level.
* **Frame reuse** in three forms: an activation that suspends again reuses
  its frame; a call site hands its next call the finished callee's frame;
  a yielding self tail call is the next iteration of the same activation.
  A generator resumed 1,000,000 times makes 2 frames; a declared recognizer
  over 1,000,000 symbols 6 (the prototype: 1,000,007); a loop calling a
  yielding function 100,000 times a handful [obs, section 13].
* **The ShadowOnly root plan** (`codegen/roots.rs`, `RootMode::ShadowOnly`):
  every function with a root slot reserves its slots on the Vm's shadow
  stack, leaf or not, and pops them on every exit. The leaf publication
  through `Vm::native_roots_ptr` is gone, with its fields. The depth token
  is dropped where the native stack guard bounds recursion. The mode is a
  `RuntimeCapabilities` value (`native/src/runtime/capabilities.rs`), the
  same description fusion, call effects and the lowering consult.
* **Fusion's gate** is "a general coroutine mechanism exists"
  (`RuntimeCapabilities::coroutines()`), so fusion runs on the fallback build
  too, before the lowering, and never decides whether a program runs.

**Verified**:

* **Golden parity** [obs]: all 122 golden suites pass on the fallback build
  with resumable coroutines -- cranelift 5,773 of 5,773, cranelift-generic
  5,671 of 5,671 -- with fusion on, with fusion off, and (cranelift, fusion
  off) under GC stress; the stock build passes the same counts (section 11).
* **Focused files** [obs]: the coroutine, actor, event-loop, recognizer,
  resource, affine, context and closure files pass on both builds, with no
  test skipped for being implementation-specific: assertions about one
  mechanism's own counters became mechanism-aware (section 11.2).
* **The leaf re-entry defect** is fixed by the publication model, not the
  reproducer [obs]: `leaf-reentry.bot` returns 340 in every run, with and
  without GC stress, on both root plans; current main's fallback driver
  returns 50 or crashes under GC stress (section 7).
* **An independent corpus** (`tests/resumable/`, 18 programs) agrees with
  the interpreter and the stackful backend, fused and not, under GC stress
  (section 12).
* **Mutation testing** [obs]: [[MUTANT-SUMMARY]] (section 12.2).

**Not done** (out of A0's scope, section 15): a Wasm emitter, WASI, any
change on hosts that switch stacks.

## 2. Baseline and current-main differences

### 2.1 Current main

* **Main moved** [fact]: the milestone started from `db473ee0`, 65 commits
  after the architecture report's `c5b22364`. Two of them reach the code
  this work changes: compiler-managed scratch storage (`fafbd2c`,
  `e18e11d`: `scratchmark`/`scratchtake` regions in the NIR, their marks in
  registers the root planner treats specially). Its storage plan already
  gives no region to a unit that may suspend (`hir/storageplan.tcl`), so no
  scratch mark is live across a suspension; the lowering checks it
  (`check_boundaries`: a yielding function with a scratch operation is a
  compiler bug), alongside a yielding function returning a construction
  plan and unbalanced error-exit spans. The coroutine runtime's protocol
  and the fallback root plan were unchanged since `c5b22364`.
* **CI before the first root or allocation change** [obs]: the last
  completed `tests.yml` run on main (43925972736, `d6b0161c`) passed every
  job, both native GC-stress jobs included; the run on `07dcb10f`
  (44149413304) was still running (11 jobs passed, none failed) when the
  milestone's final checks ran; `macos-arm64.yml` and `windows-x86_64.yml`
  on `07dcb10f` passed.
* **The fallback build of main** (`cargo build --release --features
  fallback-roots`, `db473ee0`) still refused coroutines
  (`coroutine.rs`'s NATIVE_FRAME_ROOTS check) and still published a leaf's
  roots through one Vm pointer.

### 2.2 The architecture report's baseline, reproduced

All in `audit/resumable-coroutines/results/baseline.txt`, with commands.

| Baseline item | Report | Reproduced here | Difference |
|---|---|---|---|
| leaf re-entry on main's fallback build, GC stress | 3 crashes, 2 × `50` in 5 | 4 crashes (exit 139), 6 × `50` in 10; 340 without stress | none in kind [obs] |
| prototype: golden suites | 122 suites, cranelift 5,773 | (prototype not re-swept; this milestone's driver: 122, 5,773 / 5,671) | same counts [obs] |
| prototype: corpus | every case agrees | generator, many, dfa-tail, leaf-reentry agree | not re-run case by case on the prototype |
| prototype: dfa-tail frames | "1,000,004 frames, 88,000,680 bytes" | 1,000,007 unnamed allocations, 88,000,584 bytes | 3 frames, 96 bytes: the prototype's frames have no kind, so both counts are "total minus the named kinds"; not investigated further [obs] |
| prototype: generator | 4 allocations | 4 (2 frames, 96 bytes each) | none [obs] |
| prototype: 10,000 suspended | 2.8 MB frames and coroutines | 1,760,000 B frames (88 each) + 1,040,000 B coroutines | none [obs] |
| prototype: Tcl files | actor 67/67, event-loop 109/109, dfa 84/85, coroutines 79/81 | (this milestone's driver: all pass, section 11.2) | the three failures resolved, not skipped |

**Prototype reproduction** [obs]: `git worktree add PROTO c5b22364`; `patch
-s -p1 < audit/wasm-architecture/patches/resumable-and-wasm-prototype.patch`;
`cargo build --release --features fallback-roots` in `PROTO/native`; NIR from
`PROTO`'s own front end (`tclsh9.0 main.tcl -backend cranelift -emit-nir
FILE`), allocations by `audit/wasm-architecture/tools/allocsum.py`.

### 2.3 What was not transplanted

The prototype patch was read, not applied. Kept: the state-machine shape
(dispatch on a resume point, re-entry of the same call instruction so
handler spans hold), boxing of scalar results, the corpus. Replaced:

| Prototype | Production | Why |
|---|---|---|
| `SUSPEND` sentinel and Vm hand-off slots (`resume_frame`, `pending_frame`) | the frame itself as the result; a hidden frame parameter | no global hand-off state to leave stale (I2 structural), no extra loads/stores per level, the same ABI for direct, environment and multi-result calls (section 4.3) |
| frame helpers (`frtake`, `frput`, `frfinish`, `frpending`, `frsetresume`) | inline `frisframe`/`frpoint`/`frcallee`, `frsave`/`frrestore` as instructions | hot-path field access without calls; the layout constants live in one place (`runtime/resumable.rs`, `FRAME_*_OFFSET`) |
| a separate liveness walk | the root planner's `live_at_many` | one liveness for root slots and frame saves |
| a frame per yielding tail call | the next iteration of the same activation | the DFA frame-per-symbol problem |
| fusion off on the fallback build | fusion on wherever a general mechanism exists | section 10 |
| the old fallback root plan (leaf publication kept) | ShadowOnly | section 7 |

## 3. Production resumable-lowering architecture

### 3.1 Where it runs [fact]

`native/src/main.rs` (driver load): fusion (`codegen::fusion::enabled`,
then `fuse`), then `codegen::resumable::lower` when `applies(program)` --
`program.capabilities.resumable`, the runtime's own description. A lowering
failure is a NATIVE BUG, never a refusal of the program. The pass ends with
`nir::validate` and `nir::resummarize` (call effects of the new shape). The
driver's `resumable FILE.nir` command prints the pass's report; `fused`
prints the lowered NIR, which reads back and validates
(`tests/resumable-coroutines.test`'s rc-nir-lowered).

### 3.2 Which functions [fact]

`fusion::yielding()`: a function with a `coyield`, or a direct `call`,
`callenv`, `callmulti` or `callenvmulti` of one, to a fixpoint. It is exact
because a function that may yield never becomes a value (UNWRAPPED-YIELD,
COROUTINES.md point 37): the coroutine runtime's call of the thunk is the
only indirect entry. Checked against current source:

* `check_boundaries` (`codegen/resumable.rs:264`) refuses a yielding program
  function, C callback or library export (a compiler bug upstream).
* A capturing yielding closure appears in NIR only as the environment of a
  direct `callenv`; the closure register is saved across the suspension
  (the re-entered callee reads its captures through it).
* Any dynamic call of a lowered function (`rt_call_value`) would pass one
  argument too few -- the hidden frame parameter -- and fail its arity check
  before running: no Rust activation can sit between a suspension and its
  resumer. Runtime operations that call function values (`generate`,
  `map`, sort comparators, cleanup) call non-yielding functions, which the
  pass leaves untouched.

### 3.3 The shape of a lowered function [fact]

```text
    %fr = move %fp                    entry; %fp the hidden frame parameter
    %b = op frisframe %fp             (specialized: %fp is UNIT or a frame)
    br %b DISPATCH START
  label START
    %h_j = unit ...                   each yielding call site's hand-off register
  label LOOP                          (only when a self tail call loops)
    ...the body, each suspension point rewritten in place...
  label S_k                           suspend at point k
    %fr = op frensure %fr             the activation's frame, made once
    frsave %fr k [callee %t] tagged LIVE_k raw LIVE_k
    ret %fr                           (retmulti %fr unit ...)
  label DISPATCH
    %p = op frpoint %fr
    switch %p BAD 0:START 1:D_1 ...
  label D_k
    frrestore %fr tagged LIVE_k raw LIVE_k
    ...continue at point k
  label BAD
    unreachable
```

* **A yield** `%d = op coyield %v` becomes `cosuspend %v; jump S_k; label
  Y_k; %d = op comsg`; D_k continues at Y_k, inside the yield's own handler
  spans.
* **A yielding call** `%d = call g ARGS` becomes `label C_k; %t = call g
  ARGS %h; br (frisframe %t) S_k N_k; label N_k; %d = %t` (unboxed for a
  scalar result). D_k defines the arguments the callee ignores on a resume
  (dummies of their kinds), takes the callee's frame into `%h` (`frcallee`)
  and jumps to C_k: the same call instruction, in the same handler spans,
  continues the callee, and its failure reaches the handler it reaches
  natively.
* **A self tail call** (`tail ARGS`) becomes `t = ARGS; params = t; jump
  LOOP` (a parallel move): the next iteration of the same activation,
  rewritten before liveness (`loop_self_tail_calls`, section 4.5). A
  `tailenv`, or a `tail` moving a construction plan, keeps the instruction
  and passes `%fr` as its hidden frame argument.
* **Results**: a raw, short or packed-ASCII result is boxed at the yielding
  function's returns (`RBox`, `ShortToStr`, `AsciiToStr`; exact because the
  front end proved it small or short) and unboxed by each caller after its
  suspension check. A multi-result companion (scalar replacement) carries
  the frame in its first result and UNIT in the rest.

### 3.4 The NIR it adds [fact]

Six ops and two instructions (`native/src/nir.rs:507` onwards, parsed and
printed by `nirtext.rs`), legal only in a function with a frame shape (the
header attribute `resumable="T R"`, `Function::frame`):

| Spelling | Meaning | Code |
|---|---|---|
| `%f = op frensure %f` | %f if a frame, else a new frame of the function's shape | allocation helper `rt_frame_new(vm, T, R)` (a safepoint) |
| `%b = op frisframe %v` | %v is a frame (a suspension result or hidden argument) | inline: nonzero, aligned, heap kind == KIND_FRAME; on `%fp`, `!= UNIT` |
| `%k = op frpoint %f` | resume point, raw (0: not suspended) | inline `uload32` |
| `%c = op frcallee %f` | take the suspended callee, leave UNIT | inline load + store |
| `%u = op cosuspend %v` | store the yield's outward value in the running coroutine | helper `rt_co_suspend` |
| `%d = op comsg` | the resume message; fails while abandoning | helper `rt_co_msg` |
| `frsave %f K [callee %c] tagged ... raw ...` | point := K, ntagged := #tagged, callee, slots | inline stores |
| `frrestore %f tagged ... raw ...` | define the registers from the slots; point := 0, ntagged := 0 | inline loads + 2 stores |

`nir::validate_resumable` (`nir.rs:3664`) checks: frame operations only in
frame-shaped functions; no `coyield` left once any function is lowered;
every `frsave`/`frrestore` within the shape; points from 1; the hidden
parameter last, tagged, not a plan; the result tagged. `validate_plans`
treats `frsave` as consuming its plan registers and `frrestore` as defining
them, so a construction plan live across a suspension is owned by the frame
in between.

## 4. Frame layout, ownership and hand-off ABI

### 4.1 Layout [fact]

`runtime/resumable.rs:61`, `#[repr(C)]`, one allocation:

| Offset | Field | |
|---|---|---|
| 0 | `Header` | heap kind KIND_FRAME (22) |
| 8 | `point: u32` | resume point; 0 = fresh or running |
| 12 | `ntagged: u32` | tagged slots the collector traces |
| 16 | `callee: Value` | the suspended callee's frame, or UNIT |
| 24 | `cap_tagged: u32`, `cap_raw: u32` | the shape |
| 32 | `slots[cap_tagged]` | tagged (traced up to `ntagged`) |
| 32 + 8·cap_tagged | `slots[cap_raw]` | raw: raw Ints, short and packed-ASCII Strings, C words (never traced) |

The code generator reads the offsets from the constants
(`FRAME_POINT_OFFSET`, `FRAME_NTAGGED_OFFSET`, `FRAME_CALLEE_OFFSET`,
`FRAME_SLOTS_OFFSET`; `clif.rs`'s `raw_slot_offset`), and the AOT ABI
fingerprint (`aotimage.rs`) includes `RESUMABLE` and the two slot offsets, so
an image built against another layout is refused. A frame of shape (1, 0)
is 40 bytes, (2, 2) 64 [obs: `many.bot`'s 20,000 frames, 800,000 bytes].

### 4.2 Ownership [fact]

* **Creation**: an activation's frame is made by its own first suspension
  (`frensure` in its S_k block), never earlier: an activation that never
  suspends allocates nothing.
* **The outermost frame** belongs to the coroutine (`CoroutineObj::frame`),
  set by `segment` when the thunk's activation returns a frame.
* **A suspended callee** belongs to its caller's frame (`callee`, written
  by `frsave ... callee %t`).
* **Transfer**: on a resume, `segment` takes the outermost frame out of the
  coroutine (`std::mem::replace` with UNIT) into the thunk's argument; each
  activation's D_k takes its callee's frame out of its own frame
  (`frcallee`, leaving UNIT) into the call's hand-off register. A frame is
  in exactly one place at a time: a running activation's register, a
  caller frame's `callee`, the coroutine, or an argument/result in flight.
* **Reuse**: only by the activation holding it (section 4.5).
* **Release**: completion and failure leave every frame unreachable (no
  activation returns one); `rt_co_release` and abandonment set
  `co.frame = UNIT` (I8). A frame is an ordinary heap object: unreachable
  frames are swept.

### 4.3 The hand-off ABI, and the rejected alternative [fact, dec]

**Chosen: a hidden trailing frame parameter, and the frame as the
suspension result.**

* **Down**: a lowered function's last parameter is its frame -- UNIT for a
  fresh activation, a frame to continue (a resume) or to reuse (a recycled
  callee frame, section 4.5). `segment` passes the outermost frame to the
  thunk's generic entry as its one argument.
* **Up**: a suspended activation returns its frame as its (first) result.
  A frame is never a program value: only protocol blocks create one, and
  it flows only through hidden parameters, `callee` fields, suspension
  results and the coroutine. `frisframe` therefore tells a suspension from
  every language value; an error is the existing convention (NO_VALUE, 0,
  with the Vm's pending error), checked by the call's error edge before
  `frisframe` is evaluated; a multi-result suspension is the frame plus
  UNITs, checked on the first result.

**Rejected: Vm hand-off slots** (the prototype's `resume_frame` and
`pending_frame`, the `SUSPEND` sentinel):

* They are global state between two activations: every exit -- error,
  abandonment, a runtime operation that re-enters Botlish in between --
  must clear them, which is invariant I2 as a dynamic obligation; with
  the parameter, I2 holds by construction (there is no location to leave
  a frame in).
* They cost loads and stores of the Vm per chain level per resume and
  suspension, and a frame in a Vm slot must be traced as a root while in
  flight; a parameter and a result are registers, rooted by the root plan
  like any other value.
* On Wasm they would be globals or linear-memory words the host and every
  re-entry must save around; a parameter is the core ABI.
* Stackful calling conventions are untouched: only lowered functions have
  the parameter, and only where the pass runs.

### 4.4 Frames rooted across allocations [fact]

`%fr`, `%t` (a returned callee frame) and the hand-off registers are tagged
NIR registers; the root planner (`codegen/roots.rs`) runs on the lowered
function and gives each one live across a safepoint (`frensure` is one) a
shadow slot like any other value. In the runtime, `segment` holds the
outermost frame only between taking it and passing it, with no allocation
in between.

### 4.5 Frame reuse, and when it is valid [fact]

1. **Suspending again**: `frensure %fr` returns %fr when it is already a
   frame. Valid: the activation holds it, and `frsave` overwrites exactly
   the fields the new point needs.
2. **A call site recycling its callee's frame**: the hand-off register `%h`
   keeps, after the callee returns, the frame of that finished activation
   (its point is 0, its callee UNIT); the site's next call passes it down
   and the callee starts afresh in it. Valid: a finished activation's
   frame is referenced by nothing but `%h` (the callee returned a value,
   not the frame; the frame is not its caller's `callee` any more, since
   `frcallee` took it), and it is the same function's frame, so the shape
   matches. A yielding call in a loop -- an event loop's `yield_now` per
   dispatch -- makes one frame.
3. **A yielding self tail call** (`loop_self_tail_calls`,
   `codegen/resumable.rs:188`): the parameters are rebound by a parallel
   move and control jumps back past the hand-off registers' UNIT. Valid
   because, checked against the brief's conditions:
   * *no caller state live after the call*: a tail call is the
     activation's last act; the arguments are moved into the parameters
     first; the rewrite runs before liveness, so whatever the next
     iteration reads is live across every suspension point of the loop
     and saved there;
   * *no outstanding cleanup needs the old activation's frame*: the
     rewrite changes nothing before the jump -- whatever the activation did
     before its tail call, releases included, it still does -- and `tail`
     has no error edge, so no handler or release pad spans it;
   * *layout and capacity*: the same function, so the same shape;
   * *ownership and callee relationships*: while an activation runs its
     frame has point 0, `ntagged` 0 and callee UNIT (`frrestore`,
     `frcallee`), so the next iteration starts from a fresh activation's
     state but for the frames it already owns (its own and its call sites'
     recycled ones);
   * *error behavior*: unchanged -- the iteration's failure propagates
     exactly as the activation's did.
   Where the rewrite does not apply (a `tailenv`, whose closure is rebound
   too, or a `tail` moving a plan) the tail call passes `%fr` as its hidden
   frame argument: the same frame, re-entered at point 0, only the recycled
   callee frames dropped. There is no shape-incompatible case: a NIR tail
   call is always a self call.

**Evidence** [obs]: section 13 and `rc-frames-per-resume` (2 frames for
1,000,000 resumes), `rc-dfa-tail-frames`, `rc-loop-call-frames`,
`rc-tail-call-frames` (each a handful, never one per symbol, call or
iteration); the mutants `handoff-not-recycled`, `tail-frame-not-reused`,
`tail-handoffs-reset` and `caller-frame-handed-down` (section 12.2).

## 5. Liveness and suspension state representation

* **One liveness** [fact]: `lower_function` inserts the hand-off registers
  (UNIT at the body's start, each read by its call as the last argument)
  and rewrites self tail calls, then calls the root planner's
  `live_at_many` on the function before the protocol is inserted. A
  suspension point saves the registers live after it, minus its own
  results and its own hand-off register (its resume redefines that one by
  `frcallee`), plus a `callenv`'s closure.
* **Kinds** [fact]: tagged registers go to tagged slots, every unboxed
  kind (raw Int, short and packed-ASCII String, i64/u64 C words) to raw
  slots. The shape is the widest point's of each.
* **Construction plans** [fact]: a plan register live across a suspension
  is saved like any tagged register; `validate_plans` sees `frsave`
  consume and `frrestore` redefine it (the report's `plans` count;
  exercised by `destructuring`, `loop-collecting` and
  `fold-virtual-construction` golden suites with fusion off).
* **Precision** [fact]: what a point saves is exactly the planner's live
  set; `frsave` stores it from slot 0 and sets `ntagged`; `frrestore` sets
  `ntagged` to 0, so a running activation's frame retains nothing (its
  values are in its shadow-stack frame). A value dead at the point is
  never in a traced slot (I4; section 8).
* **Census** [obs]: `botlish-native resumable` per program, e.g.
  `tests/resumable/nested.bot`: 3 yields, 6 yielding calls; `deep.bot`: 1
  self tail call; `scalars.bot`: 1 boxed result; `dfa-tail.bot`: 2 tail
  calls (`rc-lowering-report`). `rc-nir-lowered` pins `nested.bot`'s
  shapes: `leaf` (1, 0), `middle` (2, 0), `down` (1, 0), `driver` (2, 2).
* **Unit tests** [fact]: `codegen::resumable::tests` (state machines,
  exact live saves, idempotence and read-back, the tail-call loop with its
  parallel move and the hand-off register saved around the loop, boundary
  refusals).

## 6. ShadowOnly root architecture

### 6.1 Selection [fact]

`RuntimeCapabilities` (`native/src/runtime/capabilities.rs`) has
`frame_roots`, `stack_guard`, `stack_switching`, `resumable`;
`root_mode()` is `NativeFrame` when `frame_roots`, else `ShadowOnly {
depth_token: !stack_guard }`; `coroutines()` is `stack_switching ||
resumable`; `prologue_may_fail()` is `!stack_guard`. Compile-time asserts:
exactly one general coroutine mechanism; native-frame roots need the stack
guard. `host()` is the runtime's own constants; a `Program` carries the
capabilities its code is generated for, and the planner, call effects,
fusion and the lowering read them there -- so a future Wasm target sets
them without consulting the compiler host's constants. The driver prints
them (`botlish-native capabilities`: `roots shadow-only`, `coroutines
resumable` on the fallback build). Native-frame roots are untouched:
`RootMode::NativeFrame` plans exactly as before (`roots.rs:846`).

### 6.2 Storage and discipline [fact]

* **Every function with a root slot**, leaf or not, reserves `num_slots`
  words of the Vm's shadow array in its prologue (`clif.rs`'s
  `prologue_runtime_stack`): load `ss_top`, add, compare with `ss_limit`
  **before any slot is written**, store `ss_top`, zero the slots the
  definite-initialization analysis needs. A function with no slot
  reserves nothing.
* **Every exit pops**: `restore_root_frame` stores the frame's base back
  into `ss_top` on every `ret`/`retmulti` and on the shared error exit. A
  suspension is a `ret` of each activation (it returns its frame), so it
  pops too; a self tail call stays in the frame (a jump).
* **Why strict LIFO holds**: Botlish errors are returns (NO_VALUE plus the
  Vm's pending error), not unwinding; runtime operations that run Botlish
  code call it as an ordinary nested call above the caller's frame; a
  coroutine segment's activations all return before `segment` does; an
  abandonment resumes the coroutine, whose `comsg` fails and returns
  through every activation. No path leaves a function without its exit
  sequence, and no activation outlives its segment.
* **Checked**: `segment` compares `ss_top` with its entry value after every
  segment and reports a Bug (invariant I1, `runtime/resumable.rs:244`).
* **Dead slots at a scratch reset** [fact, obs]: the collector scans a
  shadow frame whole, dead slots included (native frames' stack maps are
  precise per safepoint). A dead slot still holding a String of a scratch
  region (STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md) just reset was a
  root into released storage -- skipped safely (the collector tests the
  address before reading), but counted as `stale_roots`, which must be 0:
  `scratch-storage.test`'s census program p07b, under GC stress, counted
  2,997. The planner now lists, per `scratchreset`, the slots no register
  live after it occupies (`RootPlan::scratch_reset_dead`), and the code
  generator zeroes them right after the reset; a slot is only a root,
  never read back for a value, so zeroing a dead one changes nothing else.
  Unit test `a_scratch_reset_clears_dead_shadow_slots`.
* **Size** [fact]: the shadow array is as large as the running thread's
  stack, and at least the former 4Mi slots (`vm.rs`'s `shadow_slots`).
  Under native-frame roots each root slot takes 8 bytes of its function's
  native frame, so roots that fit the stack fit the array, and a recursion
  that fits the stack returns its value on either plan
  (`native-stack-overflow.test`'s `ns-main-finite`, which main's fallback
  build failed with its fixed 32 MiB array). The array is a zeroed
  allocation, reserved and touched only as far as a run reaches.

### 6.3 The depth token [fact, inf]

The depth token gave every function with a call a shadow frame so the
shadow array's end bounded recursion where nothing else did. Where the
native stack guard exists (every host the native backend supports), the
guard bounds native recursion, so a function without roots needs no
reservation: `depth_token` is false, `num_slots` is the colored roots alone
(0 allowed), and `prologue_may_fail()` is false -- call effects
(`nir.rs:2647`) no longer make callers check a prologue that cannot fail.
The array's own bound is still checked on every reservation, before any
write; a full array is reported the guard's way (`rt_shadow_overflow`,
`ops.rs:432`: the terminal NATIVE LIMIT STACK line where the guard exists,
an in-band failure otherwise) [obs: a deep recursion on the fallback build
prints the guard's line]. Where no guard exists (the future Wasm target)
`depth_token` is true and the old discipline, with in-band failures and
checked callers, applies unchanged [inf: no such native host exists to run
it; `roots.rs`'s unit tests cover the plan].

## 7. Root publication defect and its fix

**The defect** [fact, obs]: on main's fallback plan a function without a
Botlish call kept its root slots in its own native frame and published
their address through `Vm::native_roots_ptr`/`native_roots_len`, one
pointer for the whole Vm. An operation that runs Botlish code
(`std::mutable_array::generate`'s factory) in such a leaf overwrote the
pointer with the factory's own block; a collection inside the factory then
missed the leaf's List. `audit/wasm-architecture/corpus/leaf-reentry.bot`:
340 without stress; under GC stress `50` or a segmentation fault
(section 2.2).

**The fix is the model** [fact]: ShadowOnly has no publication at all. The
leaf's slots are in the shadow array below the factory's frame, which the
factory pushes and pops above them; the collector scans the array from its
base to `ss_top`. The fields `native_roots_ptr`/`native_roots_len`, their
offsets in the ABI fingerprint, their reset and their scan were removed
from `runtime/vm.rs` and `aotimage.rs`, so no code can publish again.
Nested execution cannot hide an older activation's roots (I9) because
nothing but the one LIFO array holds roots on this plan.

**Evidence** [obs]: `leaf-reentry.bot` 340 in every run, plainly and
under GC stress, on the fallback build (5/5 and 5/5) and the stock build
(5/5 and 5/5); `rc-leaf-reentry` (both plans, five stressed runs) and
`rc-leaf-reentry-shadow-frames` (every function of the program has
shadow-stack storage, leaf or not); the mutant `leaf-roots-unscanned`
(section 12.2).

## 8. GC tracing and precision evidence

* **Tracing** [fact]: `heap.rs:254`: `KIND_FRAME => stack.extend(
  frame_of(v).traced())`, where `traced()` is `callee` followed by
  `tagged[..min(ntagged, cap_tagged)]`; `object_size` and `free_frame`
  likewise. A suspended frame is reachable only through its coroutine or
  its caller frame's `callee`; a running activation's values are in its
  shadow frame. Unit tests: `runtime::resumable::tests` (layout constants,
  `traced()` returns callee and exactly the first `ntagged` slots, raw slots
  never).
* **Reachability** [obs]: `retention.bot` (a suspended coroutine retaining
  a List of 2,000 Strings while 20,000 are allocated elsewhere), `deep.bot`
  (deep nested suspension), `many.bot` (10,000 suspended handles),
  `cleanup-gc.bot` (frames abandoned while cleanup allocates) all keep
  their values under a collection at every allocation (rc-corpus-gc-stress).
* **Reclamation** [obs]: `reclaim.bot` -- coroutines released at their last
  use while suspended, completed, and dropped at scope end: 9,000 frames
  made, 0 live after its collections, 2,000 suspended releases, 0 left to a
  sweep, plainly and under GC stress (rc-reclaimed).
* **Precision** [obs]: `precision.bot` -- 200,000 Strings in a List dead at
  the suspension point: fewer than 50,000 Strings live at the end (only the
  main program's own churn), 2 frames (rc-precision). Object death at a
  suspension point: the same program's List is collectible while its
  coroutine stays suspended.
* **Invariant checks** (the brief's I1-I9):

| | Invariant | Executable check |
|---|---|---|
| I1 | a segment restores the shadow stack | runtime check in `segment`; mutants `shadow-frame-not-popped`, `segment-check-removed`; `fallback_tests`'s leaky entry |
| I2 | no frame left in a hand-off location | structural: no hand-off location exists (section 4.3); `frcallee` and `segment` clear what they take; mutant `callee-frame-dropped` |
| I3 | suspended references reachable | `traced()` unit test; GC-stress corpus; mutants M1 `tagged-slots-untraced`, `callee-untraced` |
| I4 | dead references not retained | rc-precision; `frrestore` zeroes `ntagged`; mutants `dead-registers-saved`, `running-frame-traced` |
| I5 | live registers restored | `nir::validate` (definite definition on every resume path); exact-save unit test; mutants M2 `live-register-unsaved`, `closure-unsaved`, `handoff-unsaved` |
| I6 | tagged and raw distinct | layout (raw after `cap_tagged`), `traced()` unit test; mutants `raw-slots-traced`, `raw-slots-overlap` |
| I7 | unique frame ownership | ownership rules (4.2); mutants `caller-frame-handed-down`, `handoff-not-recycled`, `tail-frame-not-reused`, `tail-handoffs-reset` |
| I8 | completion/abandonment release the chain | `rt_co_release` clears `co.frame`; rc-reclaimed; `fallback_tests`; mutants `release-keeps-frames`, `abandonment-not-unwound` |
| I9 | no leaf publication | the fields are gone; rc-leaf-reentry(-shadow-frames); mutant `leaf-roots-unscanned` |

## 9. Errors, cleanup, abandonment and context semantics

No cleanup or error semantics of their own [fact]: resource release, affine
ownership and handlers are the front end's NIR (release pads, error edges),
which the lowering keeps in place -- a yield's `comsg` and a re-entered
call stay at their original positions in their handler spans, so a resumed
failure reaches the same pad or handler as natively. `runtime/affine.rs`
is unchanged. Abandonment (`rt_co_abandon`) resumes with NO_VALUE; `comsg`
fails with the pending abandonment; the frames' release pads run on the way
out, exactly as the stackful runtime unwinds a suspended stack.

Acceptance coverage [obs], each program's `# expect:` value the
interpreter's and checked on interp, compile, cranelift-generic, cranelift
and cranelift-unfused (rc-corpus-agree), and under GC stress:

| Brief's case | Where |
|---|---|
| errors before the first yield | `errors.bot`: `start_early(2)` fails at the construction, its handler gives 42 |
| errors immediately after resumption | `errors.bot`: `drive_deep(7)`'s third segment fails right after its resume (`-7`) |
| errors through several yielding activations | `errors.bot`: `deep` calls `later`, which fails two activations down; `deep.bot` |
| handlers spanning suspension points | `errors.bot`: `inside` handles a failure of a call that suspended twice (`500`) |
| reraise after resumption | `errors.bot`: a failed coroutine raises its error again on the next resume (`-1007`), then reports done |
| abandonment of a suspended coroutine | `tests/resources/coro.bot` (a handle's scope ends with the coroutine suspended), `cleanup-gc.bot` |
| a parent owning a suspended child | `coro.bot`'s `parent`/`child`; `cleanup-gc.bot` (coroutines suspended two activations deep) |
| nested resources released in order | `coro.bot`, `cleanup-gc.bot`: the frames' releases, innermost first, in the log |
| cleanup re-entering Botlish | `cleanup-gc.bot`: a release builds a MutableArray through its Botlish factory |
| cleanup allocating and triggering GC | `cleanup-gc.bot` under GC stress |
| context values across suspension | `contexts.bot`: a value read from a context before a yield stays live across it |
| construction under one context, later execution | `contexts.bot`: coroutines constructed in one function, resumed in another, each operation going to the providers its construction selected |
| closures and captures | `closures.bot` |

**Cleanup order** is part of each value: the release pads append to a log
the program returns (`cleanup-gc.bot`'s 19 entries, `coro.bot`'s 13), so
an order difference is a value difference. The focused files'
release-count and error-path tests (affine, context-affine, resources,
golden-framework's coroutine cleanup) pass on both mechanisms.

## 10. Fusion integration and its capability rule

* **The rule** [fact]: `codegen::fusion::enabled` is
  `program.capabilities.coroutines() && BOTLISH_NATIVE_COROUTINE_FUSION !=
  0`: fusion runs exactly where a general mechanism runs every coroutine,
  so fusing never makes a program run that the general mechanism would
  refuse (AGENTS.md, "Coroutine fusion", updated).
* **Order** [fact]: fusion first, then the lowering; whatever fusion leaves
  is lowered. Fusion's helpers (`yielding`, `callee`, `max_label`,
  `rename`) are shared, and `rename` handles the frame instructions.
* **Fusion off is tested** [obs]: the golden sweep with fusion off on the
  fallback build (every coroutine on the general mechanism), the corpus's
  `cranelift-unfused` column, CI's golden step (`BOTLISH_NATIVE_COROUTINE_FUSION=0`).
* **DFA fusion tests' intent restored** [obs]: `dfa.test`'s
  `dfa-lowering-fused-no-allocation`, the prototype's failure, passes
  unchanged on the fallback build: fusion now runs there.
* **Semantic versus optimization tests** [fact]: `coroutine-fusion.test`
  asserts fusion's own effects (no coroutine object, no stack, no frame)
  and compares the general program's helpers and NIR operations through
  `cfGeneralHelpers`/`cfStackfulOps`, which name a resumable yield as its
  two halves; `cf-no-coroutine-at-run-time` asserts "stacks mapped" on the
  stackful mechanism and "frames made, no stack mapped" on the resumable
  one.

## 11. Golden and focused test results

### 11.1 Golden suites [obs]

`BOTLISH_NATIVE_BIN=DRIVER tclsh9.0 tests/local.tcl -parts golden
-golden-backends cranelift,cranelift-generic -jobs 4` (front-end cache on):

[[GOLDEN-TABLE]]

No golden was changed. The prototype's 122 suites / 5,773 tests is the
current count too.

### 11.2 Focused Tcl files [obs]

[[FOCUSED-TABLE]]

**Semantic versus implementation-specific assertions** [fact]
(`tests/helpers.tcl`): `nativeCoroutines` (a value, release, error or
collection, the same under both mechanisms); `nativeStackfulCoroutines` and
`nativeResumableCoroutines` (one mechanism's own evidence; the driver says
which it has, `native::driverCapability`); `nativeShadowOnlyRoots`.
`coroutineCounters`/`expectedCoroutineCounters` compare the counters both
mechanisms have (`released`, `releasedSuspended`, `sweptSuspended`) and the
stack counters only where stacks exist. `releasedSuspended` and
`sweptSuspended` now count a coroutine holding suspended state -- a stack or
a frame chain (`coroutine.rs`'s `holds_suspended_state`) -- so they are
semantic. The prototype's three failures: `co-release-native-stacks` and
`co-exit-release-native-stacks` compare `coroutineCounters`;
`dfa-lowering-fused-no-allocation` passes unchanged (section 10). Also
changed for the same reason: `af-drop-native`, `cao-error-paths`,
`gf-coroutine-cleanup-native`, `contexts-native-machine-code` (native-frame
code shape, now `nativeFrameRoots`), and the coroutine-op lists of
`co-source-operations`, `higher-order-completions.test`,
`structural-contract-completions.test` and `static-compile.test`.

The whole Tcl suite run on the fallback driver (section 11.3) found more
tests encoding the old fallback plan or one mechanism, now plan- or
mechanism-aware: `native-root-storage.test` (a leaf's storage: native
frame, or the shadow stack on ShadowOnly), `native-stack-map.test` and
`nativeDepthChecked` (the depth reservation and fallible prologues only
where no stack guard exists; used by `native.test`'s `native-aot-2`,
`hashable.test`, `setcontains-equality-total.test`,
`setfromlist-equality-total.test`), `withoutShadowOverflow` (the ShadowOnly
prologue's cold `rt_shadow_overflow` call left out of the machine-code call
lists of `abi-bytes.test` and `abi-mutable-bytes.test`),
`native-stack-overflow.test`'s `ns-co-edge` and `ns-co-fused` (a
coroutine's recursion is bounded by its own 8 MiB stack where coroutines
switch stacks, by its resumer's thread stack where they are resumable
frames: section 15), and `scc-affine-payload-native` (releases counted
against coroutines made, plus the stack identity where stacks exist),
`native-library.test`'s `nl-stack-safety-coroutine` (the same bound, in a
library on a 512 KiB thread) and `nl-coroutine-stacks-released` (the
stackful runtime's stack pool: `nativeStackfulCoroutines`).

Two capabilities the fallback build lacks by design, as on main, are now
detected from the driver instead of assumed from the host:
`nativeCCallbacks` (`hostSupports cCallbacks`: the runtime refuses C
callbacks unless native frames hold the roots, C-CALLBACK-MILESTONE-1.md)
and `nativeEmitsForTargets` (a driver emits code for another target only
when that target's runtime has its capabilities, `codegen/target.rs`'s
`check_emit`; every shipped target's runtime is native-frame and stackful).
Main's fallback build failed those tests outright (its comment in
`native/native.tcl`: "the tests of the native-frame plan then fail, by
design"); they are now constrained out on it and run unchanged on the
stock build. No test of a capability the fallback build has is skipped on
it.

### 11.3 The whole Tcl suite on the fallback driver [obs]

`BOTLISH_NATIVE_BIN=FALLBACK-DRIVER tclsh9.0 tests/local.tcl -parts tcl
-backends interp -jobs 4` (every test file, the golden-duplicated tests
skipped as locally by default):

[[TCL-SUITE]]

## 12. GC-stress and mutation-test results

### 12.1 GC stress [obs]

[[STRESS-TABLE]]

### 12.2 Mutation testing [obs]

`tclsh9.0 audit/resumable-coroutines/tools/mutate.tcl -seed-target
native/target-fallback` (`audit/resumable-coroutines/tools/mutants.txt`, 19
mutants). Detectors per mutant: the fallback build's Rust tests of the
frame, segment protocol, root plan and capabilities; the corpus with fusion
off, plainly and under GC stress, compared with the unmutated build's
values; five stressed leaf re-entry runs; the allocation evidence (frames
per resume, per symbol, per call, per tail-call iteration, 10,000
suspended, reclamation, precision); then, for a mutant those miss,
`tests/resumable-coroutines.test`.

[[MUTANT-TABLE]]

Mutants of other catalogs whose code this milestone moved were updated to
the code they now mutate and run through their own harnesses:
[[FOREIGN-MUTANTS]]. `tools/mutant-catalogs.tcl`: 118 catalogs, 3,975
mutants, 0 problems.

## 13. Performance and allocation measurements

`tclsh9.0 bench/resumable-coroutines.tcl -resumable FALLBACK-DRIVER` (the
stock driver is the stackful one); best of 3 in-process runs (`botlish-native
bench`, compilation excluded), one `run --alloc summary` for allocation
counts, peak live heap and collections, a separate run for the process's
peak RSS. Times are this container's, comparable within a table only.

[[BENCH]]

## 14. CI integration

`.github/workflows/tests.yml`, job `resumable` ("tests (fallback roots,
resumable coroutines)"), after the canary, skipped on branch pushes like the
other non-canary jobs (dispatch runs it), Linux x86-64 -- a host where stack
switching exists, so the alternate mechanism has continuous independent
coverage:

1. builds the fallback driver (`native/target-fallback`, cached);
2. **proves the mechanism from the driver**, not the job's name:
   `botlish-native capabilities` must print `roots shadow-only` and
   `coroutines resumable`, and `rc-capabilities` checks the same from Tcl;
3. the fallback build's Rust tests (frame layout and tracing, segment
   protocol, I1 check, root plans, capabilities, the lowering);
4. every golden suite on cranelift and cranelift-generic with fusion off
   (every coroutine on the general mechanism);
5. focused files: resumable-coroutines (corpus, leaf re-entry, evidence),
   coroutines, coroutine-fusion, actor, event-loop, dfa, resources, affine,
   context-affine, contexts, golden-framework, and the root-plan files
   whose fallback-plan expectations section 11.3 found wanting --
   native-root-storage, native-stack-map, native-stack-overflow,
   scratch-storage (its census under GC stress), native-library;
6. GC stress: the Rust tests and the coroutine and tree golden suites with
   a collection at every allocation (the corpus's stressed runs are in
   step 5);
7. mutants M1, M2 and `leaf-roots-unscanned` through the catalog's harness
   (the full catalog is run by hand, section 12.2).

`tools/ci/test_runs.py` (the workflows' segmentation tests) passes. The
stock lanes run `resumable-coroutines.test` too: its semantic tests
(corpus agreement, leaf re-entry on native-frame roots) run there, its
resumable-evidence tests are constrained out.

## 15. Known limitations and remaining risks

* **A coroutine's recursion limit differs** [fact, obs]: a stackful
  coroutine runs on its own 8 MiB stack, so a deep recursion inside it is
  NATIVE LIMIT STACK at about ten million levels of a small function; a
  resumable coroutine's activations run on its resumer's stack (1 GiB for a
  program's thread), so the same recursion returns its value up to about
  22 million levels (`ns-co-edge`'s bisection) -- as a fused coroutine
  already did. Values, releases and errors are otherwise the same; only
  this resource limit is wider.
* **C callbacks and cross-target emission stay native-frame only**
  [fact]: unchanged from main. ShadowOnly's strict LIFO stack suggests a
  callback re-entering Botlish could push above the C frames like any
  runtime operation that runs Botlish code [inf], but enabling it is a
  change of the callback milestone's contract, out of A0's scope.
* **Per-yield helpers** [fact]: `rt_co_suspend` and `rt_co_msg` remain
  calls (they touch the coroutine object through `Vm::co_current` and
  report abandonment); `rt_frame_new` is an allocation. Their cost is in
  the generator and deep-chain rows of section 13: a resume pays them
  once, not per level.
* **Resume cost grows with chain depth** [fact, obs]: a resume re-enters
  every activation of the chain (dispatch, restore, re-call), so resuming a
  yield D activations deep costs O(D), where the stackful runtime switches
  once. Section 13's deep-1..1000 rows measure it. Fusion removes the chain
  where it applies; a chain of recursive yielding functions is never fused.
* **`tailenv` and plan-moving tail calls** keep the entry protocol: their
  own frame is reused, their call sites' recycled callee frames are not
  (one callee frame per iteration if such a loop calls a yielding
  function). No golden or corpus program has one [inf: rare -- a yielding
  closure calling itself in tail position, or a tail call passing a
  construction plan].
* **The no-guard ShadowOnly discipline** (depth token, in-band overflow,
  checked callers) has no native host to run on; it is the pre-existing
  code path, covered by unit tests only [inf].
* **The shadow array's reservation** is the thread's stack size (1 GiB for
  a program's thread): a zeroed allocation, lazily backed on Linux and
  macOS [fact: glibc and macOS satisfy large `calloc`s with fresh zero
  pages]; on Windows the heap commits it, which counts against the commit
  limit though not physical memory [inf; no Windows fallback build here].
* **Windows and macOS fallback builds** were not built here; the fallback
  feature is host-independent code, and the lane runs on Linux x86-64
  [inf].
* **Prototype frame-count difference** (1,000,007 here, 1,000,004 in the
  report) was recorded, not investigated (section 2.2).

## 16. Implications for the next Wasm milestones

* **The mechanism is the Wasm one** [inf]: the lowered NIR uses no stack
  switch and no stack map; `frensure`/`frisframe`/`frpoint`/`frcallee`/
  `frsave`/`frrestore` are loads, stores, compares and one allocation call
  in any target; `cosuspend`/`comsg` are runtime calls. A NIR-to-Wasm
  emitter consumes the lowered program the driver prints (`fused`), which
  validates on its own (rc-nir-lowered).
* **Capabilities first**: a Wasm target sets `RuntimeCapabilities {
  frame_roots: false, stack_guard: false, stack_switching: false,
  resumable: true }`: ShadowOnly with the depth token, in-band overflow,
  checked callers, fusion on, the lowering on -- every decision already
  keyed on the description, none on the compiler host's constants.
* **ABI**: a hidden trailing parameter and a result are plain Wasm
  parameters and results; the frame layout is fixed by `FrameObj`'s
  constants; on wasm32 a Value is 8 bytes as natively (the architecture
  report's section 3.4), so the offsets hold, but the emitter must read them
  from the runtime crate rather than restate them.
* **What B should not redo**: the corpus, the semantic/mechanism test
  split, the mutation catalog and the evidence tests apply to a Wasm
  driver unchanged once it reports `coroutines resumable`.
* **What B must add**: the resume-depth cost (section 15) matters more on
  Wasm, where a host's event loop resumes coroutines often; the deep rows
  are the baseline to compare an engine-level stack switch with, when one
  becomes available.

## 17. Files and reproduction

| File | Role |
|---|---|
| `native/src/codegen/resumable.rs` | the lowering |
| `native/src/runtime/resumable.rs` | frame object, segment protocol, `rt_frame_new`, `rt_co_suspend`, `rt_co_msg` |
| `native/src/runtime/capabilities.rs` | `RuntimeCapabilities`, `RootMode` |
| `native/src/codegen/roots.rs` | ShadowOnly planning |
| `native/src/codegen/clif.rs` | frame operations, ShadowOnly prologue/epilogue |
| `native/src/nir.rs` | ops, `frsave`/`frrestore`, `validate_resumable`, call effects |
| `native/src/runtime/{coroutine,heap,vm,ops,metrics,aotimage}.rs` | integration, tracing, removed publication, overflow, `ResumeFrame` |
| `native/src/codegen/fusion.rs` | the capability gate |
| `tests/resumable/*.bot` | the independent corpus (`# expect:` = the interpreter's value) |
| `tests/resumable-coroutines.test` | corpus agreement, GC stress, leaf re-entry, evidence |
| `audit/resumable-coroutines/tools/{mutants.txt,mutate.tcl}` | mutation catalog and harness |
| `audit/resumable-coroutines/results/baseline.txt` | section 2's measurements |
| `bench/resumable-coroutines.tcl` | section 13 |

Reproduction:

```bash
cargo build --release --manifest-path native/Cargo.toml
```

```bash
cargo build --release --manifest-path native/Cargo.toml --features fallback-roots --target-dir native/target-fallback
```

```bash
native/target-fallback/release/botlish-native capabilities
```

```bash
BOTLISH_NATIVE_BIN=$PWD/native/target-fallback/release/botlish-native BOTLISH_NATIVE_COROUTINE_FUSION=0 tclsh9.0 tests/local.tcl -parts golden -golden-backends cranelift,cranelift-generic
```

```bash
BOTLISH_NATIVE_BIN=$PWD/native/target-fallback/release/botlish-native tclsh9.0 tests/all.tcl -file "resumable-coroutines.test coroutines.test actor.test event-loop.test dfa.test resources.test"
```

```bash
tclsh9.0 audit/resumable-coroutines/tools/mutate.tcl -seed-target native/target-fallback
```

```bash
tclsh9.0 bench/resumable-coroutines.tcl
```
