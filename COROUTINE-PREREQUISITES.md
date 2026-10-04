# Coroutine prerequisites

What the current architecture already provides toward Tcl-like coroutines,
what has to be built, where the roadblocks are, and what the design implies
for the planned NIR-consuming register-bytecode interpreter. It covers every
vertical: the Tcl reference interpreter (`interp`), the Tcl compiler
(`compile`), and the native backend (Cranelift JIT, AOT objects and standalone
executables).

This is a research document written before any implementation.

* No production code was changed.
* Code claims cite `path:line` at commit `66b52cd`.
* Appendix B's import inventory was measured on a standalone executable built
  at `f7bb13c`, whose `native/src` and `native/Cargo.toml` are identical to
  `66b52cd`'s.
* Experiments ran under Tcl 9.0.1 (`tclsh9.0`), using throwaway scripts that
  are not committed. Appendix A reproduces their essential parts and their
  output.
* **Async functions and deferred async calls are out of scope.** They are a
  separate, later feature. §8 lists only the constraints they place on a
  coroutine design that should not have to be redone for them.

## Outcome

**The Tcl backends can already suspend Botlish code.** A Botlish native whose
Tcl implementation calls Tcl's own `yield` suspends and resumes correctly when
the program runs inside a Tcl `coroutine`. This holds on both `interp` and
`compile`:

* through recursion, collecting loops and calls of function values
  (`core::runtime::callValue`);
* with no "cannot yield: C stack busy" anywhere on a runtime path
  (Appendix A.1).

The evaluator is a recursive Tcl-proc tree walker, generated code is plain
procs, and Tcl 9 runs both on its non-recursive engine (NRE). Nothing
C-stack-bound sits between a coroutine base and a `yield`.

What is missing on the Tcl side is lifetime and dynamic-scope bookkeeping, not
a control-flow mechanism:

* The frame store's program-end cleanup is a watermark. A finishing program
  drops frames that a *still suspended* program created after it started.
  This was reproduced on both backends (A.2).
* Deleting a suspended Tcl coroutine runs no `finally` block (A.3).
* `core::compiler::ModuleBase` and the argv snapshot are process-global
  dynamic scopes.

**The native runtime was deliberately shaped for this, but cannot switch
stacks.** Already in place:

* `NativeStack` already reserves a `Suspended` state and a `saved_sp`, both
  "for future coroutine stacks" (`native/src/runtime/native_stack.rs:2-14`).
* GC roots are precise, per-safepoint stack maps in each function's own native
  frame. The frame walker hands out root *addresses* (NATIVE-STACK-MAPS.md §6).
* Errors are return values: there is no unwinding, `longjmp` or
  `catch_unwind`.
* No Botlish object ever lives on the native stack.
* Every function receives the `Vm` as its first argument.
* Exactly one runtime helper calls back into generated code (`rt_call_value`).

Missing:

* stack allocation and the switch itself;
* a GC walk over more than one stack;
* an overflow guard per stack;
* a coroutine heap object that can be reclaimed;
* making "may suspend" imply "is a GC safepoint" (`may_gc`);
* removing process- and thread-global runtime state.

The program body should run as the actor's root coroutine (§6). The runtime
then allocates every stack Botlish code runs on. That removes glibc's stack
discovery and the 1 GiB worker thread, a step toward not depending on glibc,
and it can land first, on its own (§4.5).

**HIR needs much less than one might expect.**

* Every HIR fact describes an immutable value bound once. No analysis keeps
  facts about MutableArray contents, which are the only mutable state. Because
  scheduling is cooperative and stackful, **no existing fact needs to be killed
  at a suspension point**.
* The real HIR work is the coroutine's typing contract:
  * how yield and resume values are typed, given the existing rule that a
    typed callable or a `MutableArray[T]` must not be erased;
  * which error set a resume carries;
  * how "yield outside a coroutine" is classified.
* Declared errors and the planned `context` field of structural function types
  are ready-made templates for all of this.

**NIR is already frame-address-free.** That makes it a good base for an
interpreter with resumable heap frames. No NIR instruction takes an address
(`native/src/nir.rs:449-586`), handlers are static per instruction
(`nir.rs:2078-2091`), and register kinds are declared per function.

For coroutines, the interpreter should be **non-recursive, with one register
stack per coroutine** (the Lua model). That makes a coroutine a few hundred
bytes and makes switching a pointer swap. It also requires one rule to hold
forever: **no runtime helper calls Botlish code**. `rt_call_value` is the only
violation today.

**Roadblocks, most serious first:**

1. Multi-stack root discovery and per-stack overflow detection on native.
2. Per-coroutine stack memory. Stacks have a fixed size and cannot be copied,
   so creating one costs a mapping.
3. Hosts other than Linux x86-64, for different reasons.
   * Windows can switch stacks natively (Fibers, or the same short `asm`
     switch adapted to the Win64 ABI). Its gap is this repository's GC frame
     walk and overflow handling, which are not reliable there even without
     coroutines.
   * Wasm hides its call stack from the program. It can neither walk frames
     nor switch stacks without engine support.
4. The typing of values that cross yield and resume.
5. Global per-thread runtime state that actors will not tolerate.
6. *Future* transfer of a suspended coroutine between actors. Suspended native
   frames hold the `Vm` pointer in registers and spill slots that no stack map
   describes.

---

## 1. The model these prerequisites serve

| Level | Is | Owns | Relation |
|---|---|---|---|
| thread | an OS thread | one scheduler; one or more actors | every thread has a default actor |
| actor | an isolated runtime namespace within a thread | heap, module-static instances, coroutines | nothing mutable is shared between actors |
| coroutine | a resumable activation stack | its frames and its suspension point | created in an actor and stays there unless explicitly transferred (future) |
| frame | one Botlish function activation | registers or locals | on exactly one coroutine's stack |

Botlish is single-actor and single-thread today. The invariants a coroutine
design must establish now, so that actors and threads can be added later
without revisiting it:

* **C1. Stackful, Tcl-like.** A suspension may happen at any call depth below
  the coroutine's body: through closures, value calls and library functions.
  There is no colouring of functions at the surface. Tcl's `yield` works this
  way, and so do Botlish-on-Tcl today (A.1).
* **C2. Asymmetric interface, symmetric core.** The interface is Tcl's: create,
  resume, yield. Internally, implement one *transfer to a given context*
  primitive (Tcl's `yieldto`) and layer yield and resume on it. A future
  actor scheduler (§8) needs the symmetric form.
* **C3. Cooperative and one-at-a-time per actor.** Within an actor exactly one
  coroutine runs. Control changes hands only at resume, yield and completion,
  so interleaving happens only at suspension points.
* **C4. Locality.** A coroutine is created in an actor and runs only there. The
  guarantee follows from heap isolation: a coroutine handle is not sendable
  (like a MutableArray, §6), so no other actor can ever name it.
* **C5. A handle is a stateful value with identity.** Its precedent is
  MutableArray's `{mutarray ID}`:
  * equality is undefined, an `EQUALITY` error
    (`core/value.tcl:327-337`, where `block`, `native` and `mutarray` are
    already excluded);
  * it is not hashable;
  * like a MutableArray, it must be rejected as a module-static value
    (`MODULE-IMMUTABLE`, `hir/modulebinding.tcl:187-221`).
* **C6. Abandonment is unobservable.** Botlish has no `finally`, `defer` or
  destructors. A coroutine that is never resumed can be reclaimed without
  running anything, and no completion or value fact depends on it (it behaves
  like divergence). This is a property to keep, or to replace deliberately with
  a cancellation semantics if resources with cleanup are ever added.
* **C7. Completions at the body boundary.** The body is a Block invocation, so
  the existing callable boundary applies unchanged (`core/completion.tcl:46-63`):
  * `return v` completes the coroutine, and `v` becomes the result of the
    resume that ran it;
  * `break`/`continue` cannot cross it;
  * an uncaught declared error leaves the body and **completes the resume** in
    the resumer.

  Tcl's behavior is the same: an error in a coroutine propagates to the caller
  of the resume (verified, including return codes 0-5).
* **C8. One-shot continuations.** Each suspension is resumed at most once, as
  in Tcl. Construction plans depend on this. A plan "is extended in place, so it
  must have exactly one continuation" (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md:212-221).
  Multi-shot or cloneable continuations are excluded.

The Tcl operations and illustrative Botlish counterparts are below. The names
are placeholders. They follow STDLIB-NAMESPACES.md's pattern of standard
intrinsics in a flat namespace, so the core feature needs no new syntax or
keyword.

| Tcl | Botlish (illustrative) | Notes |
|---|---|---|
| `coroutine NAME CMD ARGS` (runs to the first yield) | `coroutine::start(f, ...)` | Tcl's eager first run versus a separate first `resume` is a decision (§4.1) |
| `NAME ?v?` (resume) | `coroutine::resume(c, v)` | Tcl cannot tell a yielded value from the final one. Botlish should be able to (§4.1) |
| `yield ?v?` | `coroutine::yield(v)` | must not be typed `never` (§4.1) |
| `yieldto CMD ARGS` | internal transfer primitive | needed later by a scheduler (§8), not exposed now |
| `info coroutine` | `coroutine::current()` | optional |
| resume a finished coroutine: "invalid command name" | declared error, e.g. `CoroutineFinished` | dynamic state, checkable at the resume site |
| resume a running coroutine: "coroutine … is already running" | declared error, e.g. `CoroutineRunning` | dynamic state |
| `yield` outside a coroutine: "yield can only be called in a coroutine" | see §4.1 | a placement rule, not an application error |

---

## 2. What exists today

### 2.1 Tcl reference interpreter (`interp`)

**Control is explicit and lives in Tcl proc locals.**

* `core::interp::evalIn` (`core/evaluator.tcl:58-66`) dispatches through the
  `forms` dict to one handler per form.
* Every handler returns a completion: `{value V}`, `{return V}`, `{break V}`,
  `{continue}` or `{propagate-error {errorId NAME}}` (`core/completion.tcl:5-23`).
* `valueOf` propagates an abrupt completion with `return -level 2`
  (`evaluator.tcl:93-98`). That is ordinary Tcl within one stack, and it
  behaves the same inside a Tcl coroutine.
* All evaluator state (node, environment id, completion) is in proc locals,
  which is exactly what a Tcl coroutine captures.

**Nothing on a runtime path blocks yielding.**

* Yield fails through only these Tcl commands, out of everything tested:
  `lsort -command`, `regsub -command`, `interp eval` and variable traces.
* None of them appears on a runtime path. The only `lsort -command` runs at
  type registration (`core/type.tcl:163`).
* No native calls back into Botlish. The higher-order helpers (`any?`, `all?`,
  `none?`, `find`) are ordinary Botlish (`lib/list.bot:84-102`), and type
  validators are pure Tcl.
* This is the Tcl form of the rule §7 needs for the bytecode interpreter: a
  callback through a C-bound host frame pins the stack.

**Frames are released per stack.**

* The interpreter releases a scope's frame in `try/finally`: block invocation
  (`core/block.tcl:39-44`), `if` branches, loop iterations and handler bodies
  (`evaluator.tcl:143-148, 156-160, 474-478`).
* A suspended Tcl stack therefore keeps its unpinned frames alive simply
  because their `finally` has not run.
* An unpinned frame is reachable only from its own stack, so releases on
  different stacks can interleave safely.

**What breaks:**

* **`core::env::releaseSince` is a watermark.** It drops "every frame created
  after a mark, … pinned or not" (`core/env.tcl:57-60, 80-92`). Program end
  calls it unless the result contains a Block (`evaluator.tcl:571-575`).
  * Two interleaved programs: the one that finishes first drops frames the
    other created after the first one started. Reproduced (A.2):
    `core::env: no such environment "env7"`.
  * Within one program, a coroutine handle in the program's result must count
    like a Block, which `core::value::containsBlock` (`value.tcl:300-320`) does
    not do. A further probe resumed such a handle after its program ended,
    and `interp` failed the same way. `compile` happened to succeed, because
    the captured value was a Tcl local of a non-materialized scope.
* **Abandonment leaks.** Deleting a suspended Tcl coroutine (`rename C {}`)
  runs neither `finally` nor `catch` (A.3).
  * The abandoned coroutine's unpinned frames survive until the program-end
    `releaseSince`.
  * Its Tcl coroutine command survives the program run unless something
    deletes it.
* **The frame-lifetime model's own assumptions no longer hold.**
  `core/env.tcl:46-56` assumes that "the only runtime values that refer to a
  frame are Blocks" and that nested scopes end before their parents. A
  suspended stack is a second kind of frame owner.

**State classification** (from the interpreter survey). Tcl namespace
variables are per-interp.

| State | Where | Must become |
|---|---|---|
| frame store `frames`, `bindingIndex`, `nextFrame`, `nextBinding` | `core/env.tcl:22-28` | per actor, with frame ownership recorded per coroutine (§4.2) |
| MutableArray store `store`, `nextId` | `core/mutarray.tcl:29-30` | per actor. Entries are never freed today |
| argv snapshot `core::process::current` | `core/process.tcl:35, 66-80` (`withArgv`: save, `uplevel 1`, restore in `finally`) | per actor, copied in at actor creation. Safe within one program |
| backend selection `core::backend` | `evaluator.tcl:26` | per actor or process |
| native, type, kind and form registries; constants | `core/native.tcl:152-192`, `core/type.tcl:62-66`, `value.tcl:76`, … | process-global (immutable after loading) |
| compile-time state `core::compiler::{nextId, hir, pending, …}`, `hir::sourcetypes::generation` | `compiler/compiler.tcl:85-112`, `hir/sourcetypes.tcl:24-72` | never live across a yield. Not re-entrant: two actors compiling in one interp would clash |

### 2.2 Tcl compiler (`compile`)

* **Generated code shape** (A.1 verifies yields work in it):
  * units are `proc unitN {base}`;
  * blocks are `proc blockN {captured argv}`;
  * loops are `while`, `foreach` and `for`;
  * control is Tcl return codes, with declared errors as code 5;
  * self tail calls become `while 1 … continue` (`compiler/compiler.tcl:674-686`).
  * There is no `tailcall`, `uplevel` or `upvar` in generated code.
* **Frame lifetime differs from the interpreter.** Compiled code never calls
  `release`. It materializes a frame only for scopes that create closures
  (`compiler.tcl:61-67`), and every such frame lives until program end. So the
  watermark issue is the same, and abandonment leaks nothing extra.
* **`core::compiler::ModuleBase` is the second dynamic scope.**
  * It is a single namespace variable (`compiler.tcl:100-105`). Each unit proc
    sets it and restores it in `try/finally` (`compiler.tcl:650-653`).
  * Every module-static reference reads it (`compiler.tcl:954`).
  * Within one program every coroutine runs inside the unit's extent, so this is
    correct. Two programs or actors interleaved in one interp would read each
    other's module frame.

### 2.3 Native backend: what is already shaped for coroutines

| Property | Evidence | Why it matters |
|---|---|---|
| Stack descriptor with a suspended state | `native_stack.rs:2-14`: `enum StackState { Active, Suspended }`, `saved_sp: Option<usize>`, both annotated "reserved for future coroutine stacks". `is_guard_fault` is already true only for an `Active` stack (`:22-24`), and the unit test pins this (`:51-52`) | per-coroutine stacks were planned into the type. NATIVE-STACK-OVERFLOW.md:104-106: "A later coroutine can carry its own `NativeStack`, saved stack pointer, and continuation; this phase adds no stack switching." |
| Precise per-safepoint stack maps in native frames | NATIVE-STACK-MAPS.md §1-3; `codegen/clif.rs:918-927` (`mark_safepoint`); `runtime/framemap.rs` | a suspended frame's roots are exactly the roots at its return address. "This frame's own slots cannot change while suspended inside a call" (`codegen/roots.rs:578-584`) holds per stack |
| Address-based, relocation-ready walk | `runtime/framewalk.rs:126` hands `visit` a `*mut Value`. NATIVE-STACK-MAPS.md §6 | the same mechanism could later relocate roots, which future cross-actor transfer needs (§6) |
| Walk crosses Rust frames | frame pointers are forced for the runtime crate (`.cargo/config.toml`). The walk "does not stop at the first non-Botlish return address" (NATIVE-STACK-MAPS.md §5) | a coroutine suspended inside a callback (`rt_call_value` → closure → yield) is walkable |
| Terminates on `rbp == 0` | `framewalk.rs:129` | a coroutine entry frame with a zeroed saved `rbp` ends that stack's walk with no new check |
| Errors are return values | 0 means an error is pending in `Vm::error` (`clif.rs:11-12`, `vm.rs:134`). No `setjmp`/`longjmp`/`catch_unwind`. `handle` is compile-time (`clif.rs:1506-1515`) | a body's error reaches the resumer as an ordinary 0 return through the switch. No unwinder has to cross stacks |
| No Botlish object on the native stack | closures capture by value (`native/lower.tcl:75-82`); block escape de-closures without stack allocation (NATIVE-BLOCK-ESCAPE.md); every object is a heap allocation | stackful suspension needs no relocation of objects |
| `vm` is the first argument of every function | `clif.rs:3-9`; `Vm` is `#[repr(C)]` (`vm.rs:85-178`) | an actor maps to a `Vm` instance with no codegen change (§6) |
| Transitive call-effect summary | `summarize_call_effects` (`nir.rs:1042-1104`): `(may_error, may_gc)` per function and per direct call; `CallValue` is `(true, true)` | a third bit, `may_suspend`, fits the same fixpoint (§4.3) |
| One re-entry point | `rt_call_value` (`runtime/ops.rs:1443-1466`) is the only helper that calls generated code, through `ClosureObj.code`. No higher-order opcodes exist | the stack can contain Rust frames below a yield in exactly one known shape |
| Non-moving heap | `runtime/heap.rs:1, 34` | raw pointers held across a switch stay valid |

### 2.4 HIR: what already fits

* **No fact about mutable contents.**
  * MutableArray is the only mutable kind (`core/mutarray.tcl:1-7`).
  * Exact values (`hir/exactvalue.tcl:44-58`), ranges (`hir/range.tcl:35-75`;
    `hir/induction.tcl:77-79`), cardinality atoms (capacity is fixed:
    `hir/cardinality.tcl:339-342`) and completion-walk relations
    (`hir/completions.tcl:399-403`) all describe immutable values.
  * "Any exact fact about its contents becomes stale at the next
    `mutable_array_set` through any alias", so none is kept
    (MUTABLEARRAY-CONSTRUCTION-REFINEMENT.md:298-305).
  * Element *type* facts hold under any interleaving, because every store
    through any alias is checked against `T`.
  * Cooperative interleaving at yield points therefore invalidates nothing.
* **Declared errors are a typed completion channel carried in function types.**
  * The legality rule is `effectiveErrors(call) - handledErrors(call) ⊆
    enclosingDeclaredErrors` (`hir/errorsets.tcl:4-6`), with the program root's
    set `{}` (`:36`).
  * Calls record `calleeErrors` from an exact block, a native's registry entry,
    or a structural `Fn` (`hir/types.tcl:2142-2155`).
  * A resume's error set (§4.1) can reuse all of it.
* **There is a planned extension slot for an effect.** A `context` field of
  structural function types is reserved. The parser rejects it "not supported
  yet" (`surface/parser.tcl:651-653`), and adding it is "one more named entry in
  `MakeFn`'s dict" (STRUCTURAL-FUNCTION-TYPES.md:158-166; `hir/types.tcl:296-300`).
* **Escape and materialization barriers already fire at natives and value
  calls.** If creation, yield and resume reach HIR as natives (or `callvalue`),
  the following treat the body callable and every transported value as escaping
  with no new mechanism:
  * `hir::aot::materializedBlocks` (`hir/aot.tcl:256-299`);
  * the "only exact direct calls" rule of `hir/blockescape.tcl:56-72`;
  * aggregate transport (`hir/escape.tcl:84-110`);
  * construction-plan barriers (`hir/construction.tcl:60-70`).
* **Strict reference determinism.** Bindings are visible from their definition
  onward and captures are values (STRICT-REFERENCE-DETERMINISM.md:34-40). A
  coroutine body can never observe an unbound capture, whatever the scheduling.
* **Module initializers are already isolated from coroutines.** Natives default
  to `-context-free 0` (`core/native.tcl:207`), so a coroutine operation in a
  module initializer is already rejected (`MODULE-CONTEXT`).

### 2.5 NIR: what already fits

* **No addresses.**
  * There is no address-of, no stack slot, and no pointer into a frame
    (`nir.rs:449-586`).
  * Self tail calls are back edges (`clif.rs:1410-1428`).
  * The only native-stack pointers are introduced by codegen, within one
    instruction: argument arrays (`clif.rs:1024-1040`), `construct` words, and
    the result buffer of a function with more than two results
    (`clif.rs:1049`).
* **Static handlers.** The error-exit handler active at each instruction is
  computed statically (`nir.rs:2078-2091`). A suspended frame needs no runtime
  handler stack.
* **Per-function register kinds.**
  * Each register is declared tagged, raw, short or ascii for the whole function
    (`nir.rs:276-285`, `726-730`).
  * Root planning is Cranelift-free and "operates on `nir::Function` alone"
    (`codegen/roots.rs:6-7`).

---

## 3. Experiments

All under Tcl 9.0.1, using a test native whose Tcl implementation is
`yield [core::formatValue $v]` and that returns the resumed Int (Appendix A).

| # | Probe | interp | compile |
|---|---|---|---|
| A.1 | Yield from a recursive function, from inside a collecting `loop x in […]`, and through a value call `apply_to(walk, n - 1)`; resume 9 times | correct: 9 yields `3,100,200,2,100,200,1,100,200`, result `12000` | identical |
| A.2a | Two programs suspended at once. The short one runs to completion while the long one is suspended, and the long one created its frames *before* the short one started | both correct (`14`, `8`) | identical |
| A.2b | Same, but the long program creates a closure-capturing frame *after* the short one started, and the short one then finishes | long program fails: `core::env: no such environment "env7"` | fails: `"env12"` |
| A.3 | `rename` (delete) a Tcl coroutine suspended inside `try … finally` | `finally` does not run; the command is gone (plain Tcl, backend-independent) | — |
| A.4 | Recursion limit 200: recurse 150 levels, create a coroutine there, and recurse 150 levels inside it | `too many nested evaluations`: the creator's depth counts against the coroutine (plain Tcl) | — |

The interpreter survey adds:

* About 9 Tcl levels per interpreted Botlish call; 1 per compiled direct call;
  5 per compiled value call; 0 per self tail call.
* NRE keeps the C stack flat: depth 200,000 worked inside a coroutine.
* Tcl's recursion limit is the only bound, and it is a resource limit, not
  semantics (README §20).

---

## 4. What must be implemented

### 4.1 Language and HIR

**Intrinsics and kind.**

* Add a `coroutine` value kind: a store-indexed handle like `{mutarray ID}`.
  Equality is undefined, it is unhashable, and it is not context-free.
* Add the intrinsics in a `coroutine::` namespace (§1). They must reach HIR as
  natives, or calls through a structural `Fn`, and never as a special form or an
  exact `call` node. That gives them §2.4's barriers for free and keeps them out
  of the following, which would be wrong for them:
  * specialization result feedback (`hir/types.tcl:2077`);
  * successful-result summaries (CLOSED-CALL-FACTS.md:13);
  * block-escape eligibility.
* Kind lists to extend:
  * `core/value.tcl:76` and the `equal` exclusion list (`:337`), `show`,
    `containsBlock` (or a generalization of it);
  * `core/type.tcl:62` primitives and `core/hashing.tcl:78/119`;
  * a kind test in `core/predicates.tcl:41`;
  * `compiler/compiler.tcl:1213`;
  * `hir/types.tcl:201` and `hir/signatures.tcl:787`;
  * the native backend's heap kinds.

**Decisions this layer must make.** Each is listed with a recommendation.

1. **What `yield` returns.** It returns the resumed value. It must never be
   typed `never`, which would make the code after it unreachable for M6 branch
   removal and `reachable`. A body that loops forever while yielding correctly
   infers `never` for its *own* result.
2. **How transported values are typed.** A stackful `yield` cannot know
   statically which coroutine it runs in, so at the yield site the resumed value
   is `any`, and so is the yielded value at the resume site.
   * Code after a resume is then *guarded*, and `-emit-native-executable`
     rejects guarded instances (`NATIVE AOT NOT-READY`, README §20) until a type
     test refines the value. This is acceptable: refinement closes kinds.
   * **The real constraint is erasure.** Passing a typed callable or a
     `MutableArray[T]` to a native parameter of type `any` is rejected
     (`hir/callables.tcl:89-160`; TYPED-CALLABLE-ESCAPE-SOUNDNESS.md:181-207).
     So yield and resume cannot transport such values unless the handle's type
     carries a protocol.
   * Recommendation: start with untyped transport and accept the rejection.
     That is a compile-time rejection, consistent with "known failure ->
     compile-time rejection" (EXPLICIT-ERROR-COMPLETIONS.md:10-11). Add a typed
     protocol later as named fields on the handle type, never as a positional
     form.
3. **Which error set a resume carries.** Errors escape the body into the
   resumer (C7), so the handle type must carry the body's error set, exactly as
   a structural `Fn` carries `errors`.
   * Resume's `calleeErrors` = the body's errors ∪ {`CoroutineFinished`,
     `CoroutineRunning`}.
   * `x = coroutine::resume(c, v): on E: …` then works unchanged, because
     `handle` wraps a bare call (EXPLICIT-ERROR-COMPLETIONS.md:113-121).
   * Erasing an error-bearing handle to `any` must be rejected by the same
     `Bearing` rule that protects callables.
   * Seen as a Tcl coroutine *command*, a handle is close to a callable of type
     `Fn{args: [R], return: Y, errors: [E…]}`. Treating it as a separate kind
     keeps the yielded-versus-returned distinction expressible.
4. **Yielded versus final value.** Tcl cannot tell them apart. Botlish's "kinds
   never blur" principle argues for a resume result that distinguishes them, or
   for a `done` query. Which one it is matters less than not copying Tcl's
   ambiguity.
5. **Yield outside a coroutine.** Make it a semantic *placement* error
   (`CORE SEMANTIC YIELD-OUTSIDE-COROUTINE`), checked at run time, like
   `BREAK-OUTSIDE-LOOP` at a call boundary (README §5, §7).
   * A *declared* error would be the wrong channel. Every function that yields,
     and every caller up the chain, would have to handle or admit it. That is
     function colouring through the error system, against C1.
   * The future actor model (§8) makes the program root the actor's root
     coroutine. A later version may then give "yield in the root" a meaning
     (suspend to the scheduler), which is a compatible extension of an error.
6. **Eager or lazy start.** Tcl runs the body to its first yield at creation.
   Lazy start (created suspended, run by the first resume) is simpler to type,
   because the first resume's argument is ignored, and it is what deferred async
   calls will want (§8). Recommendation: lazy.

**The suspension effect.**

* HIR facts need no `suspends` effect for soundness. The mandatory summary is
  NIR's (§4.3).
* An HIR-level fact only becomes necessary when either of these appears:
  * a static rule, such as a contract field `suspends` via the `context` slot,
    or a non-suspending program root;
  * an optimization that keeps facts about mutable contents across calls.
* **Guardrail for the second case.** Any future fact about MutableArray
  contents, any load reuse, or a zero-copy `freeze` must be killed at a call
  that *may suspend* while an alias is reachable from another coroutine. Being
  killed at calls that may write the array is not enough. Stackful suspension
  means any call that may suspend lets every other coroutine of the actor run.
* If the effect is ever made static, choose between two meanings for a call
  through `any`:
  * "suspends" as a bearing obligation (erasure rejected, like errors). This
    colours APIs, and the untyped higher-order helpers (`list::any?`,
    `list::find`) could no longer take a yielding predicate;
  * conservatively "may suspend", like NIR's `CallValue`.

  For a stackful design only the conservative reading is consistent with C1.
* No new specialization keys are needed: stackful code is identical on any
  stack. A contract-level `suspends` field adds no instances, because the
  contract is a function of the block's identity (`hir/specialize.tcl:394-402`).

**Sendability (prepare now, enforce with actors).** A type-level check is not
enough: block types do not reveal captures (STRUCTURAL-FUNCTION-TYPES.md:292-305).
The capture-walking "transitively immutable" check of
`hir/modulebinding.tcl:206-221` is the existing proof to reuse. Coroutine
handles and MutableArrays are never sendable.

### 4.2 Tcl interpreter and compiler

1. **The coroutine value and store.**
   * `{coroutine ID}` indexes a per-actor store. An entry holds the Tcl
     coroutine command name, its state (`fresh`, `running`, `suspended`,
     `done`), the body Block, and the transport slot.
   * Create Tcl coroutine commands in a private namespace, never under
     user-visible names.
2. **The intrinsics.**
   * `start` creates the Tcl coroutine around `core::callable::invoke` of the
     body. The body must pass through `atCallBoundary`, so the resumer always
     receives a completion.
   * `yield` is Tcl `yield`, after checking `info coroutine` against the store
     (otherwise the placement error).
   * `resume` checks the state, records `running`, calls the command, then
     records `suspended` or `done`.
   * A `propagate-error` returned from the body is re-signalled at the resume
     call: the interpreter's completion, or code 5 in compiled code
     (`core::runtime::callValue`, `core/runtime.tcl:27-37`, already does this
     for value calls).
   * Map Tcl's own "already running" error to `CoroutineRunning`, and resuming a
     deleted command to `CoroutineFinished`.
3. **Frame ownership instead of a watermark.**
   * Record, per frame, the coroutine (or program) that created it.
   * At program end, release the program's frames and those of every coroutine
     the program created, unless the result contains a Block *or a coroutine
     handle*.
   * At coroutine completion, release its remaining unpinned frames.

   This fixes A.2b and the handle-in-result case. An id set per owner suffices;
   the scheme does not need to be clever.
4. **Abandonment.**
   * At program end, delete the Tcl coroutine commands of every coroutine the
     program created.
   * Optionally reclaim during a run: kill a coroutine by resuming it with a
     private cancel token, so that the yield native raises a dedicated Tcl error
     and the stack unwinds through the `finally` clauses that release frames.
     Plain deletion skips them (A.3).

   Without a GC of handles, an abandoned coroutine's frames otherwise live until
   program end. That is acceptable for a reference interpreter but should be
   documented.
5. **Dynamic scopes per actor.** `ModuleBase` and `core::process::current`
   are correct within one program, as A.1 and A.2a show. They have to become
   per-actor before two actors share an interp.
6. **Actors and threads in the reference interpreter.** Model them *logically*,
   inside one Tcl interp on one OS thread, with per-actor state dicts for the
   frame store, the mutarray store, the coroutine store, `ModuleBase` and argv.
   * Tcl coroutines cannot migrate between interps or threads. If the reference
     used Tcl child interps or the Thread package, future coroutine transfer
     between actors would be impossible to specify there.
   * With logical actors, transfer is a change of owner on a store entry.

### 4.3 Native runtime and codegen

**Stacks and switching.**

1. **Coroutine stacks.**
   * Each coroutine gets an `mmap`ed region with a `PROT_NONE` guard region
     below it (larger than one page, §4.5), described by a `NativeStack`
     (state `Suspended` while not running, `saved_sp` set).
   * Stacks cannot be copied or grown in place. Codegen keeps callee-to-caller
     interior pointers in registers (argument arrays, the multi-result buffer
     held for the callee's whole lifetime: `clif.rs:1049-1056, 1460-1476`), and
     Rust frames are opaque. So each stack has a fixed reserved size, and a
     pool of stacks avoids an `mmap`/`munmap` per coroutine (§4.5).
2. **The switch routine.** It needs a few instructions of `asm` per target.
   * x86-64 SysV: save `rbx`, `rbp`, `r12`-`r15`, plus MXCSR and the x87
     control word, store `rsp` in the from-context, load the to-context, and
     return.
   * It must open a standard `push rbp; mov rbp, rsp` frame record. A suspended
     stack's walk then starts at its saved `rbp`, and `rbp + 16` is still the
     caller's SP that the stack maps are relative to (`framewalk.rs` header).
3. **The coroutine entry trampoline.**
   * Its own saved `rbp` is 0, so each walk terminates at the stack base
     (`framewalk.rs:129`).
   * It calls the body's generic entry (`botlish_entry_F`, `clif.rs:293-410`).
   * It stores the body's result or its 0 return, marks the coroutine `done`,
     and transfers back to the resumer.
   * It never unwinds. Helpers are `extern "C"` in edition 2024, so a panic in
     a helper already aborts rather than unwinding.

**GC.**

4. **A multi-stack walk.**
   * Generalize `framewalk::walk(map, Option<&NativeStack>, visit)`
     (`framewalk.rs:126`), which starts at the *current* `rbp` within one
     stack, to `walk_from(start_rbp, &NativeStack, visit)`.
   * `Vm::collect_with` (`vm.rs:320-365`) then walks:
     * the running stack from the current `rbp`;
     * the chain of resumers, each suspended inside `resume`, from their saved
       contexts;
     * every other suspended coroutine reachable from the heap.
   * Bounds and monotonicity checks stay per segment. Today the monotonicity
     check `saved_rbp <= rbp` (`framewalk.rs:153`) would stop a walk that
     crossed stacks.
5. **A coroutine heap kind.** `CoroutineObj {hdr, state, stack, saved context,
   body closure, transport value}`.
   * Tracing a *suspended* coroutine walks its stack. Its liveness is
     reachability of its handle.
   * Tracing collects cycles (a body that captures its own handle), where
     Tcl's named commands only ever leak.
   * The sweep needs a kind-specific finalizer that returns the stack to the
     pool. Today `heap.rs` only frees boxes (`:161-165`).
   * The running coroutine and its resumer chain are roots.

**Call effects.**

6. **`may_suspend` implies a safepoint.** This is mandatory. A direct call with
   `may_gc == false` gets no stack-map entry (`roots.rs:190-197`;
   CLOSED-CALL-EFFECTS.md:68). If that callee yields and another coroutine
   collects, the suspended caller's live values are unrooted.
   * Add a third bit to `summarize_call_effects` (`nir.rs:1042-1104`). Its
     local sources are the suspension instructions and `CallValue`, and it
     propagates over exact edges like `may_gc`.
   * The consumer rule is: a call is a safepoint iff `may_gc || may_suspend`.
   * Modelling yield as an allocating, failing op would also produce this, but
     hide the reason. An explicit bit keeps it auditable.

**Values that cross a switch.**

7. **Transport values are tagged `Value`s.** Raw Ints are boxed with `rbox`
   (never allocating, because they are proven small), short and ascii strings
   are converted, virtual structs and lists materialize, and construction
   plans materialize.
   * This happens automatically if the operations are native ops: native
     arguments are materialization points (VALUE-TRANSPORT-MATERIALIZATION.md;
     `hir/escape.tcl:84-110`).
   * The pending-error slot `Vm::error`/`declared_error` can stay per `Vm`. No
     switch happens while an error is pending, and a body's 0 return becomes
     the resume's 0 return.

**Overflow.**

8. **One overflow guard per active stack.**
   * The SIGSEGV/SIGBUS handler compares the fault address with one
     process-global guard range for one thread id
     (`runtime/platform/x86_64_linux.rs:27-55`), installed once per run.
   * Each switch must publish the active stack's guard range in a per-thread,
     async-signal-safe record, and the handler must check that record.
     `NativeStack::is_guard_fault` already answers per stack.
   * Inline stack probes for frames over 4 KiB (`codegen/mod.rs:155-160`) keep
     working on small stacks.
   * Overflow stays a process exit (NATIVE-STACK-OVERFLOW.md:29-35). A
     coroutine cannot recover from its own overflow in-process.

**Other per-coroutine and per-thread state.**

9. **Fallback hosts** (non-Linux, other ISAs).
   * The shadow array `ss_base..ss_top` (`vm.rs:87-88, 131-132`) and the
     LIFO `native_roots_ptr`/`_len` registration (`vm.rs:104-108`) are per
     stack. Each coroutine needs its own shadow segment, swapped at every
     switch.
   * CRANELIFT-WASM.md:987-993 already reproduced the failure this prevents:
     two suspended JSPI runs sharing `ss_top` clobbered a shadow root.
10. **Process- and thread-global runtime state.**
    * `thread_local! PROGRAM` (`vm.rs:76-83`) is last-writer-wins per thread.
      Move it into the `Vm`, or index it by actor.
    * The overflow atomics (`x86_64_linux.rs:27-31`) assume one guarded thread.
    * `Rc<ProgramInfo>` and `Rc<ProgramMap>` make `Vm` `!Send`. That is harmless
      for coroutines, but threads will need `Arc`.

**Codegen and the AOT executable.**

11. **Codegen.** Two helper calls (`rt_co_resume` and `rt_co_yield`, or NIR
    instructions, §4.4) plus creation. They are marked as safepoints, and no
    other code shape changes.
12. **AOT executables.** They need no change beyond the runtime. Stacks come
    from `mmap` in the runtime; the generated `startup.rs` and the link step are
    untouched.

### 4.4 NIR

* **Make suspension points explicit instructions**, for example `%r = cocreate
  %f`, `%v = coresume %c %x` and `%v = coyield %x`, rather than opcodes hidden
  behind `apply_op`. Three consumers need to see them:
  * the call-effect fixpoint (`may_suspend`);
  * a future interpreter, for which they are dispatch-loop operations rather
    than helpers (§7);
  * a future selective-CPS or Asyncify-style transform on hosts without stack
    switching (§5, R3), which must know which functions can suspend.
* Their operands are tagged registers. The validator's "every other use must be
  tagged" rule (`nir.rs:1861-1868`) covers this.
* **Extend the `nir 1` header compatibly.** It has never been bumped while the
  format grew (`nir.rs:996-1007`). Adding instructions follows the usual
  practice: the format is internal between Tcl and Rust (`native/native.tcl:149-185`).

### 4.5 Runtime-owned stacks, the root coroutine, and glibc

The root coroutine (§6) means the runtime allocates every stack Botlish code
runs on, the root's included. Not depending on glibc is a long-term goal of
the project, and this design moves the stack side of that goal most of the way
for little extra work.

**What glibc does for stacks today.**

| Use | Where | Through |
|---|---|---|
| Discovering the stack and guard bounds | `runtime/platform/x86_64_linux.rs:6-25`, called from `Vm::new` (`vm.rs:221-226`) and when the guard is installed | `pthread_self`, `pthread_getattr_np`, `pthread_attr_getstack`, `pthread_attr_getguardsize`, `pthread_attr_destroy` |
| A 1 GiB worker thread, spawned only to get a large stack | `main.rs:68-72`, `runtime/aot.rs:26-31` | `std::thread::Builder::stack_size`, which is glibc's `pthread_create` |
| Overflow signal handling | `x86_64_linux.rs:34-118` | `sigaction`, `sigaltstack`, `sigemptyset`, `signal`, `raise` |
| Trivial system calls | the same handler | `syscall(SYS_gettid)`, `write`, `_exit` |

**What a runtime-allocated root stack removes.**

* **Discovery.** The runtime chose the bounds, so it knows them. There are no
  `_np` calls. The quirk that "the discovered usable size may be slightly
  smaller than the requested builder size" (NATIVE-STACK-OVERFLOW.md:8-17)
  disappears.
* **The worker thread.** The root coroutine's 1 GiB reservation replaces the
  thread's stack. The JIT driver and the AOT executable's `aot::run` can run
  the program from the main thread.
* **A second kind of stack.** Root and pooled stacks share one allocator, one
  guard layout and one `NativeStack` description. The GC walk ends at the root
  stack's base, at the trampoline's zeroed saved `rbp`, instead of climbing
  through the driver's frames and `std`'s thread-start frames.
* Windows later uses the same design, with `VirtualAlloc` in place of `mmap`.

**What it does not remove, and how each would go.**

* **The OS thread's own stack.** The main thread's stack comes from the
  kernel. The plan, a future decision, is to create later threads with raw
  `clone` and allocate their stacks with the same allocator, so every stack in
  the process belongs to the runtime.
  * The reasoning: once the runtime allocates, guards and walks its own
    stacks, a libc thread library adds only a second, differently discovered
    kind of stack. Botlish needs nothing else from it.
  * With the root coroutine, a thread's own stack runs only the scheduler and
    the runtime entry, so it can stay small.
* **Signal handling.** `sigaction` and `sigaltstack` are libc wrappers around
  the `rt_sigaction` and `sigaltstack` system calls, and can be replaced by raw
  calls.
  * The one trap: on x86-64, `rt_sigaction` needs `SA_RESTORER` and a restorer
    trampoline that the caller supplies, a few instructions that issue
    `rt_sigreturn`. glibc supplies it today.
  * The handler body is already async-signal-safe: atomic loads, `gettid`,
    `write` and `_exit` (`x86_64_linux.rs:34-55`).
* **Rust `std`.** It links libc on the `-gnu` target and installs its own
  SIGSEGV handler for the main thread's guard. Leaving glibc ultimately means
  a `no_std` runtime or the project's own system-call layer, which
  `linux::abi::syscall` (LINUX-X86-64-SYSCALL.md) already points toward.
  Appendix B lists, measured on a real executable, every glibc and libgcc
  symbol a produced executable imports, which code needs each one, and what
  replaces it.

**Guard regions larger than one page.**

* Use 64 KiB to 1 MiB of `PROT_NONE` below every runtime-owned stack, root and
  pooled alike.
* A single 4 KiB page is enough only because every large frame probes:
  * Cranelift's inline probes for frames over 4 KiB (`codegen/mod.rs:155-160`);
  * Rust's stack probes.
* Unprobed code, such as a future C or hand-written helper with a large frame,
  could step over one page.
* A `PROT_NONE` region costs address space only, never memory. The kernel's
  own gap below the main thread's stack is 1 MiB (`stack_guard_gap`).
* `NativeStack`'s `guard_low..low_bound` already describes a guard of any size.

**The stack pool: its value is reuse, not pre-allocation.**

* Reserving a stack is one `mmap` with `MAP_NORESERVE`, and its pages get
  memory only when touched. Pre-reserving N stacks at start-up saves N cheap
  system calls. Starting empty and growing on demand (for example by doubling)
  is just as good.
* What matters is a free list. With it, short-lived coroutines do not pay
  `mmap`/`munmap` plus page-fault churn each time. Touched pages of free stacks
  above a high-water mark go back with `madvise(MADV_DONTNEED)`.
* Pooled stacks share one size class. The root stack is the exception, with
  its large reservation.
* **Whether a program needs the pool at all is already answerable.**
  * Give the creation intrinsic a `-runtime` tag, for example
    `coroutine-stack`.
  * `hir::aot` already collects `-runtime` tags into each closed program's
    requirement list (README §19; `core/native.tcl:157-186`).
  * The root stack is always allocated; only the pool depends on the tag.

**First milestone: the root coroutine alone.** This is a standalone runtime
refactor that can land before any coroutine syntax exists. It has no
semantics change and no NIR change.

* Allocate the root stack and its guard, switch into it once from the main
  thread, run the program function (`botlish_fn_0`, module initialization
  included), and switch back.
* Remove the worker thread (`main.rs:68-72`, `runtime/aot.rs:26-31`) and the
  pthread discovery (`x86_64_linux.rs:6-25`). `Vm::new` takes the root stack's
  `NativeStack` instead of `NativeStack::current()`, and the overflow handler
  checks the runtime-owned guard.
* It exercises §4.3's switch routine (item 2), the walk's termination at a
  stack base (item 3) and the per-stack overflow record (item 8), with exactly
  one stack. The multi-stack GC (item 4) arrives with real coroutines.
* Validation:
  * the existing suite, plain and under `BOTLISH_NATIVE_GC_STRESS=1`;
  * the overflow tests NATIVE-STACK-OVERFLOW.md lists (two overflowing
    processes, a large-frame overflow, 400 live recursive frames under GC
    stress).

  `BOTLISH_NATIVE_STACK_BYTES` keeps working; it now sizes the root
  reservation.

---

## 5. Roadblocks and risks

| # | Roadblock | Severity | Why | Mitigation |
|---|---|---|---|---|
| R1 | Root discovery over many stacks | high | `framewalk::walk` starts only at the current `rbp`, is bounded by one `NativeStack`, and relies on monotonic ascent (`framewalk.rs:126-157`). `Vm.native_stack` is a single `Option` (`vm.rs:177`) | §4.3 items 4-5. The per-frame model is already correct; only the enumeration of stacks is new |
| R2 | Stack memory per coroutine | high | Stacks cannot be copied or segmented (interior callee-to-caller pointers; opaque Rust frames). A fixed reservation trades recursion depth against address space and RSS. Today's 1 GiB worker (`main.rs:68-72`, `runtime/aot.rs:26-31`) is the program's whole recursion budget. Rust helpers also recurse proportionally to value nesting (`equal` `ops.rs:376+`, `hash_mix` `:506`, `show`) | a stack pool whose value is reuse (§4.5); `madvise(MADV_DONTNEED)` above a high-water mark; a configurable default size in the style of `BOTLISH_NATIVE_STACK_BYTES`; the actor's root coroutine keeps the large reservation. Depth limits are resource limits, not semantics (README §20), so `interp`, `compile` and native may differ |
| R3 | Hosts other than Linux x86-64 | high (portability) | **Windows can switch stacks** (Fibers: `CreateFiberEx`/`SwitchToFiber`, which also maintain the TIB stack bounds and per-fiber guard page; or a hand-written switch saving the larger Win64 callee-saved set, `rdi`/`rsi` and `xmm6`-`xmm15` included). Its gap is the existing frame walk: Windows x64 takes the stack-map path (`clif.rs:527` tests only the ISA), but frame pointers are forced only for the Linux and macOS targets (`.cargo/config.toml:42-46`), so the rbp walk through Rust helper frames is unreliable. GC-stress crashes on Windows are recorded (CLOSED-CALL-EFFECTS.md:81). Overflow uses the in-band shadow-stack depth token, because the guard handler is Linux-only (`native_stack.rs:31-33`, `roots.rs:722`). **Wasm** exposes no stack to the program: no frame walk (CRANELIFT-WASM.md:257), and no stack switching in Wasm 3.0 (JSPI only suspends to JavaScript) | Windows: force frame pointers for the MSVC target too, which the walker needs without coroutines as well; then Fibers or an `asm` switch, and an overflow guard per fiber (a vectored exception handler in place of SIGSEGV). Wasm: per-coroutine shadow segments plus a per-coroutine Rust `__stack_pointer`; then the wasm stack-switching proposal, or an Asyncify-like transform of exactly the `may_suspend` functions (§4.4). The bytecode interpreter (§7) is the portable engine that needs neither |
| R4 | Typing of transported values | medium | `any` at yield and resume sites makes code guarded (AOT-unready until refined); the erasure rules reject typed callables and `MutableArray[T]` as transport values | untyped transport first (§4.1 item 2), then typed protocol fields on the handle type |
| R5 | Global per-thread runtime state | medium (blocks actors, not coroutines) | `thread_local PROGRAM`, process-global guard atomics, `Rc`; in Tcl, `ModuleBase`, argv, frame/mutarray stores per interp, and non-re-entrant compile state (`hir/sourcetypes.tcl:24-66`) | §4.2 item 5; §4.3 item 10 |
| R6 | Frame-store lifetime in the Tcl backends | medium (correctness bug once interleaving exists) | the watermark `releaseSince` (A.2b); `containsBlock` blind to handles; abandonment skips `finally` (A.3) | §4.2 items 3-4 |
| R7 | A Rust frame below a yield | low | `rt_call_value` can sit between a closure that yields and its caller. It holds only the raw `p: *mut Vm` and forms short-lived `&mut` borrows (`ops.rs:1444-1456`); release builds may compile it to a tail call (CRANELIFT-WASM.md:1947-1949) | keep the rule "helpers never hold a `&mut Vm` across a call into generated code"; audit new helpers against it |
| R8 | Blocking system calls | low now, central for async | `linux::abi::syscall` runs in a helper (`runtime/syscall.rs:73`). A blocking call stops every coroutine of the thread, by design of cooperative scheduling | nothing for coroutines; async I/O is a later design (§8) |
| R9 | Cross-actor heap pointers | future | marking writes `header.marked` into any non-static object it reaches, and only the owning heap's sweep clears it (`heap.rs:121-129, 161-165`). A foreign pointer would leave another heap's object permanently marked. A walk over a stack shared by two actors cannot tell their frames apart | every actor's activations, including its root, run on actor-owned stacks (§6). Sendability forbids sharing mutable or handle values |
| R10 | Moving a suspended coroutine to another actor or thread | future | suspended native frames hold the `Vm` pointer in callee-saved registers and spill slots no stack map describes. A Rust helper frame holds `p`. Stack maps describe only `Value` roots | §6. Interpreter frames do not have this problem (§7) |

**R3 in plain terms.** Windows and wasm fall short for different reasons.

* **Windows can switch stacks natively**, arguably more easily than Linux.
  Fibers are stackful coroutines built into the OS. `CreateFiberEx` and
  `SwitchToFiber` also do the Windows-specific bookkeeping: they update the
  thread's recorded stack bounds, give each fiber its own guard page, and keep
  stack probes and exception handling working. The alternative is the same
  short assembly switch as on Linux, saving the larger Win64 set of preserved
  registers.
* **Windows's real gap is the existing GC frame walk**, and it needs fixing
  even without coroutines.
  * Windows x64 uses the same stack-map plus frame-pointer walk as Linux,
    because the check selects it by ISA only (`clif.rs:527`).
  * The walk follows the frame-pointer chain through the runtime's Rust helper
    frames. Frame pointers are forced only for the Linux and macOS targets
    (`.cargo/config.toml:42-46`). Rust on Windows omits them by default, so
    the walk can read garbage partway up. That fits the recorded Windows
    GC-stress crashes (CLOSED-CALL-EFFECTS.md:81).
  * Overflow detection (guard page plus SIGSEGV handler) is Linux-only, so
    Windows falls back to the slower in-band depth counter.
  * The fix is to force frame pointers for the Windows target too, and to add
    a guard per fiber through a vectored exception handler in place of
    SIGSEGV.
* **Wasm is different in kind.** WebAssembly is a sandboxed bytecode whose
  call stack belongs to the engine (the browser or Wasmtime). The program has
  no stack-pointer register it can swap, and cannot read its own frames or
  return addresses. That blocks both mechanisms:
  * **The GC cannot walk frames.** Roots must live in a separate shadow stack
    in ordinary memory, which CRANELIFT-WASM.md §4.4 already plans.
  * **The program cannot switch stacks itself.** It needs engine support, and
    every option costs something:
    * a stack-switching proposal that is not part of Wasm 3.0;
    * JSPI, which only suspends out to JavaScript;
    * a compile-time rewrite such as Asyncify. It turns functions that may
      suspend into state machines that unwind and later rebuild their frames,
      at a cost in code size.
* **The bytecode interpreter (§7) sidesteps all of this.** It keeps each
  coroutine's frames in its own memory, so it needs neither a frame walk nor
  stack switching.

Both platforms are later on the roadmap; R3 records what they will need.

---

## 6. Actors and threads: what coroutine work should leave ready

* **An actor is a `Vm`.**
  * Native: every function already takes `vm`, so running another actor means
    passing another `Vm`.
  * Its heap, module-static instances (`statics_table`, `vm.rs:109-130`),
    stacks and pending error are per actor.
  * Module statics are context-free and transitively immutable, and object
    identity is unobservable (callable `==` is invalid; ARGV.md:48-50). So
    re-running module initialization per actor is observably the same as
    sharing.
  * Sharing statics would need a shared, immortal region, as the constant table
    already is (`is_static`, `heap.rs:126`). That is an optimization, not a
    prerequisite.
  * Tcl: a logical per-actor state dict (§4.2 item 6).
* **Run every activation on actor-owned stacks, including the program entry.**
  Make the program's own body the actor's *root coroutine* on an actor-owned
  stack, and keep the thread's own stack for the scheduler only. This gives
  four things at once:
  * GC walks never leave the actor's stacks (R9);
  * overflow handling is uniform;
  * "suspend the root" can be given a meaning later (§8) without moving the
    program;
  * every stack Botlish code runs on belongs to the runtime, which removes
    glibc's stack discovery and the worker thread (§4.5).
* **Keep locality structural.** C4 holds because a handle cannot leave its
  actor's heap: sendability rejects handles, and actors share nothing mutable.
  No runtime ownership check is needed while that holds.
* **Plan for future transfer, but don't build it.** A suspended coroutine
  could move between actors in three ways:
  * **Copy plus relocate.** Copy everything reachable from its stack into the
    destination heap and rewrite its roots through the address-based walk
    (§2.3).
    * Immutable values make the copy unobservable.
    * MutableArrays and nested handles have identity, so they must be
      transferred with it or rejected. The capture-walking proof (§4.1) decides
      which.
  * **Vm pointer reload.** The obstacle is R10: frames keep the old `vm`. A
    codegen mode that reloads `vm` from a per-thread context after every
    `may_suspend` call would remove it, at a cost per call that may suspend.
  * **Transfer only frameless states.** Allow transfer only of coroutines that
    have not started (a closure plus arguments, both values) or that run in the
    interpreter (§7).

  Moving to another *thread* also needs `Send` runtime structures (`Arc`), and a
  stack memory region that moves with the coroutine (which is just memory).

---

## 7. Influence on a future NIR → register-bytecode interpreter

DIRECT-HIR-NATIVE-PATH.md:691-697 already plans that interpreter: it reads
NIR, shares `native::prepareHir`, the HIR analyses and the NIR grammar, and
needs nothing from Core IR or Cranelift. Coroutines decide its frame
architecture.

**Recommendation: a non-recursive dispatch loop, with one register stack per
coroutine.**

* A NIR call pushes a frame onto the *current coroutine's* register stack and
  continues the loop. It never recurses on the host stack.
* A coroutine is then a small heap object holding its register stack, its frame
  records (function, pc, destination registers, closure slot), and its state.
* Resume and yield change the loop's "current coroutine" and continue. No
  native stack is involved, so the interpreter needs none of R1-R3's machinery
  and works unchanged on wasm.
* This is the Lua model, and Tcl's NRE is the same idea. Both run Botlish
  coroutines today (A.1).

**What NIR already gives it** (§2.5, plus the NIR survey):

* **Exact frame size.** `regs=R` per function, dense. In the corpus: median 13
  registers, p99 62, max 128, and one synthetic 603-register fixture
  (`native/tests/fixtures/large_frame_overflow.nir`).
* **Fixed width.** Every register is 64 bits, in four physical kinds (tagged,
  raw, short, ascii) declared per function.
* **An exact root bitmap per function.** The collector dereferences any
  low-3-zero word (`value.rs:311-313`, `heap.rs:118-125`), so the interpreter
  must never scan raw, short or ascii registers. Kind declarations make a
  static tagged-register bitmap exact.
  * With frames zeroed on entry, scanning every tagged register of every frame
    of every coroutine is sound, and over-retains only dead values.
  * Precise per-pc maps come from reusing `roots::plan`'s `safepoint_slots`.
    `roots.rs` is Cranelift-free but lives in the binary's `codegen`;
    `lib.rs` exports only `nir` and `runtime`, so it would move into the
    library.
* **Static handler regions** (`nir.rs:2078-2091`). They become a pc → handler
  table, so a suspended frame carries no handler state.
* **Errors as returns, with no unwinding.** A pending error is a status the
  loop propagates frame by frame.
* **Only self tail calls**, as back edges. No general tail-call machinery is
  needed.
* **The runtime helpers are callable as they are** (`ops.rs:1-66`; generic
  `apply_op`, `ops.rs:1488-1570`). The interpreter supplies only the inline-only
  operations: guards, capture and `structget` loads, raw arithmetic, and the
  short and ascii operations.

**Rules NIR and the runtime must keep, so this stays possible.** These are the
interpreter's coroutine prerequisites:

1. **No helper calls Botlish code.**
   * A callback through a host frame pins the host stack, which is Lua's
     "attempt to yield across a C-call boundary" and Tcl's "cannot yield: C stack
     busy". The interpreter could then no longer suspend that coroutine without
     native stack switching.
   * Today only `rt_call_value` violates this. The interpreter must dispatch
     `callvalue` on closures itself, by `ClosureObj.func` (`value.rs:265-274`),
     and use the helper path only for natives.
   * Every future higher-order intrinsic must be written in Botlish (as
     `lib/list.bot`'s already are) or lowered to NIR-level calls, never
     implemented as a Rust helper that calls a closure.
2. **No instruction exposes a register's or frame's address.** That keeps
   register stacks *relocatable*: the interpreter holds indices, never raw
   pointers, across a call or suspension.
   * A coroutine can then start with a tiny register stack (hundreds of bytes)
     and grow by reallocation. That is what makes coroutines and later deferred
     async calls cheap.
   * JIT stacks can never do this (R2).
   * Codegen-only pointers (argument arrays, result buffers) are fine, because
     they are not NIR.
3. **Suspension points are explicit instructions** (§4.4). In the interpreter,
   resume and yield manipulate the loop state, so they cannot be helpers.
4. **Register kinds stay per function**, so root bitmaps stay static.

**Encoding implications for fixed-width bytecode.**

* 8-bit register operands cover the corpus, with a wide-operand escape for
  frames above 255 registers.
* Calls and constructors take variable operand lists (up to 600 in the fixture)
  and need an argument-window convention. Lua's "arguments in consecutive
  registers at the top of the caller's frame, which becomes the base of the
  callee's frame" avoids copying.
* Multi-result companion calls (`callmulti`, up to 3 results), the status word
  of failing scalar results (`clif.rs:125-140`), and unbox-on-entry of a raw
  parameter at a tagged ABI position (`clif.rs:589-605`) are part of the frame
  protocol.
* Frame depth is an explicit check at frame push, so overflow can be an
  in-band, *recoverable* error per coroutine. That is better than the JIT's
  process exit (NATIVE-STACK-OVERFLOW.md:29-35).

**Mixed execution with the JIT.**

* A Block's `code` is a raw machine address (`value.rs:270-271`), but JIT code
  never calls it. Only `rt_call_value` does.
  * Interpreter-created Blocks can carry the address of one Rust trampoline that
    dispatches on `func`.
  * The interpreter can call JIT Blocks through `code`.
* **A coroutine cannot span both engines without native stacks.** Heap frames
  cannot capture JIT frames. If a coroutine has a JIT frame anywhere below its
  suspension point, it needs a native coroutine stack (§4.3); the interpreter
  then runs recursively on that stack for the portion JIT code called.
* Recommendation: choose the engine per actor (or per program) first, and treat
  tiered mixing as a later design that inherits §4.3's machinery.
* The `Backend` trait's `CompiledProgram` is Cranelift-shaped: a `JITModule`,
  machine entry addresses and a `framemap` (`codegen/mod.rs:93-145`). A bytecode
  backend generalizes it, and adds a root source "coroutine register stacks"
  to `Vm::collect_with`.

**Effect on transfer (R10).** Interpreter frames hold no `vm` pointer; the loop
does. Moving a suspended interpreter coroutine to another actor is therefore
"copy or re-own its reachable values, rewrite its registers by the static
bitmaps, change its owner". If cross-actor transfer of *suspended* coroutines
becomes a requirement, that is an argument to run such actors on the
interpreter, or to adopt the `vm`-reload codegen mode (§6).

---

## 8. Async functions: constraints only

Async calls are not part of this work. They resemble `vwait`: by default the
caller waits, and a deferred form yields a handle. Coroutines should not
foreclose them:

* **The root activation must be able to suspend later.** Tcl's `vwait` runs a
  nested event loop on the C stack. The coroutine-native form suspends the
  current coroutine *to the actor's scheduler*, and that only works if the
  program body is itself a coroutine (§6). Make it one now, even though
  "yield in the root" is a placement error today (§4.1 item 5).
* **Keep a symmetric transfer primitive under yield and resume** (C2). A
  scheduler picks the next coroutine; it is not "the resumer".
* **Creation must be cheap.** A deferred call would create a coroutine per call.
  On native that is a stack from a pool (R2); in the interpreter a few hundred
  bytes (§7). This favours lazy start (§4.1 item 6).
* **The suspension effect must mean "may suspend", not "may yield to the
  resumer"**, so that awaiting reuses the same `may_suspend` summary, safepoint
  rule and future static field.
* **Errors travel through the resume's error set** (§4.1 item 3), so an
  awaited result's errors propagate with no new channel.

---

## 9. Suggested order of work

1. **Preparatory fixes, no language change:**
   * Tcl: frame ownership instead of the watermark (§4.2 item 3).
   * Native:
     * `framewalk::walk_from` with per-segment bounds;
     * `PROGRAM` into the `Vm`;
     * an overflow-guard record per active stack;
     * the `may_suspend` bit in `summarize_call_effects` (always false until
       something sets it).
2. **The root coroutine alone** (§4.5): a runtime-owned root stack with a large
   guard region, one switch in and out, no worker thread, and no pthread
   discovery. No language or NIR change.
3. **Coroutines on `interp` and `compile`:**
   * the kind, store, intrinsics, placement error and declared errors;
   * a differential test corpus like `tests/backends.test` (generators, nested
     resumes, errors escaping a body, abandoned coroutines, handles in program
     results).
4. **Native coroutines on Linux x86-64:**
   * stacks, switching, the coroutine heap kind with finalizer, multi-stack GC
     and safepoints;
   * run the step-3 corpus under `BOTLISH_NATIVE_GC_STRESS=1`, with collections
     triggered while several coroutines are suspended at different depths and
     inside `rt_call_value` callbacks.
5. **Typing:** error-bearing handle types, then typed transport protocols (R4).
   AOT readiness follows from refinement.
6. **Fallback hosts and wasm** (R3), and the bytecode interpreter (§7) as the
   portable engine.

---

## Appendix A: the Tcl probes

All probes load `compiler/compiler.tcl` and `surface/surface.tcl` and register
one test native:

```tcl
proc yieldImpl {v} {
    set resumed [yield [core::formatValue $v]]
    return [core::value::int $resumed]
}
core::registerNative test_yield -arity 1 -impl yieldImpl
```

A program is run inside a Tcl coroutine with
`core::evalProgram [hir::lower $hir]` (interp) or
`core::compiler::evalHir $hir` (compile), and resumed by calling the coroutine
command.

**A.1** (resumed with `1000`, `2000`, …):

```botlish
fn apply_to(f, v):
    f(v)

fn walk(n):
    if n < 1:
        return 0
    got = test_yield(n)
    inner = loop x in [1, 2]:
        test_yield(x * 100)
    apply_to(walk, n - 1) + got
walk(3)
```

```
interp: yields=3,100,200,2,100,200,1,100,200 result=12000
compile: yields=3,100,200,2,100,200,1,100,200 result=12000
```

**A.2b** (L is started; S is started; L is resumed, creating `make`'s frame
and closure `k`; S finishes; L is resumed):

```botlish
# L
fn make(base):
    fn k(y):
        base + y
    k
fn run(n):
    a = test_yield(1)
    adder = make(n + a)
    b = test_yield(2)
    adder(b)
run(5)

# S
fn quick(base):
    a = test_yield(10)
    base * a
quick(7)
```

```
interp: short=done 14 long=1 {core::env: no such environment "env7"}
compile: short=done 14 long=1 {core::env: no such environment "env12"}
```

A.2a is the same pair with L's frames all created before S starts; both
programs complete correctly.

**A.3:**

```tcl
proc body {} {
    try { set x [yield first]; puts "resumed with $x" } finally { puts "finally ran" }
}
coroutine C body
rename C {}        ;# prints nothing: no finally
```

**A.4:** with `interp recursionlimit {} 200`, recursing 150 levels and then
running `coroutine cz deep 150` there fails with `too many nested evaluations
(infinite loop?)`, while `deep 150` alone succeeds.

---

## Appendix B: what produced executables take from Rust `std` and glibc

**Summary.**

* **`std` is not monolithic over glibc, but on the current target it is
  glibc-bound.** `core` needs no operating system, `alloc` needs only an
  allocator, and `std` adds an OS layer that the `-gnu` target implements on
  glibc (B.1). Almost all of the runtime uses only the first two layers. Linking
  `std` still brings in its own startup code, its own stack-overflow handler
  and its panic machinery, whether the runtime uses them or not.
* **A produced executable imports 81 symbols** from `libc.so.6`, `libm.so.6`
  and `libgcc_s.so.1`. Every one is attributed to the code that calls it, and
  a script checked that B.2's table covers all 81.
* **Allocation is the big one.** Every `Box`, `Vec` and `String`, and every GC
  heap object, goes through glibc's `malloc`. Replacing it means writing the
  runtime's own allocator.
* **The root coroutine (§4.5) already removes** the worker thread
  (`pthread_create`/`join`) and the stack-bounds discovery calls.
* **The rest are small, separable items, each with a clear replacement:**
  * **`libm` comes only from `num-bigint`.** With its default `std` feature it
    calls `f64::log2`; without it, it uses integer math. Setting
    `default-features = false` drops `libm.so.6` with no code change.
  * **`getrandom` only seeds the `HashMap` in the allocation-site metrics.** A
    fixed hasher removes it.
  * **The thread-local `PROGRAM`.** Moving it into the `Vm` is already a
    prerequisite for actors (§4.3 item 10).
  * **Environment and argument reading, the result and error printing, timing
    for GC metrics, and exit.**
  * **`libgcc_s` comes only from panic unwinding and backtraces.**
    `panic = "abort"` plus a panic handler removes it. That handler must print
    the existing `NATIVE BUG` line itself, because today a panic is caught when
    the worker thread is joined.
  * **The memory intrinsics** (`memcpy` and friends) are emitted by the
    compiler and need the runtime's own implementations without libc.
* **The `botlish-native` driver** (JIT, `rustc` invocation) is a host tool and
  can stay on `std`.
* **Routes off glibc** (B.4):
  * musl, with `std` unchanged but still a libc;
  * `#![no_std]` on the current target, linked with `-nostdlib -static`, which
    works on stable Rust;
  * `x86_64-unknown-linux-none`, which this `rustc` knows but `rustup` ships no
    prebuilt standard library for, so it needs nightly `-Zbuild-std`.

  B.4 ends with a seven-step removal order, cheapest first.

**Method.** At `f7bb13c`, `examples/stdlib/csv.bot` was compiled with
`tclsh9.0 main.tcl -emit-native-executable`. The executable's dynamic imports
were then listed with `nm -D --undefined-only`. Each imported symbol was
attributed to the functions that call it, using the demangled disassembly
(`objdump -d -C`). The program's own code is irrelevant here: every produced
executable links the same runtime library and the same generated
`startup.rs` shape (`native/src/codegen/aot.rs:20-117`).

### B.1 Rust `std` is layered, not monolithic

* **`core`** needs no operating system and no allocator: pointers, `mem`,
  slices, `fmt`, atomics, `asm!`, `Cell`/`RefCell`/`OnceCell`, iterators.
* **`alloc`** needs only a global allocator: `Box`, `Vec`, `String`, `Rc`,
  `Arc`, `BTreeMap`, `format!`.
* **`std`** re-exports both and adds the operating-system layer:
  * process startup;
  * threads, and thread-locals with destructors;
  * the environment, arguments, I/O, files and time;
  * `HashMap`'s random seed;
  * panic unwinding and backtraces.

  On `x86_64-unknown-linux-gnu`, that layer is implemented on glibc.

Almost all of the runtime uses only `core`- and `alloc`-level items. Only the
uses listed in B.3 need the OS layer. On the `-gnu` target, however, linking
`std` also brings in `std`'s own runtime initialization, its own overflow
handler and its panic machinery, whether the runtime uses them or not. B.2
marks those groups "`std` itself".

### B.2 Imports

`ldd` lists `libc.so.6`, `libm.so.6`, `libgcc_s.so.1` and
`ld-linux-x86-64.so.2`. The executable has 81 undefined dynamic symbols.

| Group | Imported symbols | Needed by | Without glibc |
|---|---|---|---|
| Process startup and exit | `__libc_start_main`, `exit`, `abort`, `pause`, `__cxa_finalize`; the weak `__gmon_start__` and `_ITM_*` | the C startup objects rustc links on `-gnu` (`_start` calls `__libc_start_main`); `std::rt::lang_start_internal`; the generated `fn main` and its `std::process::exit` (`std::sys::exit::unique_thread_exit` uses `pause`) | the runtime's own `_start`, reading `argc`/`argv`/`envp` from the initial stack, and `exit_group` |
| `std`'s runtime initialization (`std` itself) | `poll`, `fcntl`, `open64`, `dup`, `signal`, `sysconf`, `pthread_self`, `pthread_getattr_np`, `pthread_attr_getstack` | `std::rt::lang_start_internal`: checks that fds 0-2 are open (reopening `/dev/null`), ignores SIGPIPE, records the main thread's stack | nothing; the runtime needs none of it |
| `std`'s own stack-overflow handler (`std` itself) | `sigaction`, `sigaltstack`, `mmap64`, `mprotect`, `munmap`, `getauxval`, `pthread_attr_getguardsize`, `gettid` | `std::sys::pal::unix::stack_overflow::imp::{make_handler, drop_handler, signal_handler}`: a second SIGSEGV handler, beside the runtime's own | nothing; the runtime's handler (§4.5) is the only one needed |
| The runtime's overflow guard | `pthread_self`, `pthread_getattr_np`, `pthread_attr_getstack`, `pthread_attr_getguardsize`, `pthread_attr_destroy`, `sigaction`, `sigaltstack`, `sigemptyset`, `signal`, `raise`, `syscall` (for `gettid`), `write`, `_exit`, `__errno_location` | `runtime/platform/x86_64_linux.rs`: `current_stack` (6-25), `fault_handler` (34-55), `OverflowGuard::install_mode` and its `Drop` (65-118) | discovery disappears with the root coroutine (§4.5). The rest become raw system calls: `rt_sigaction` with `SA_RESTORER`, `sigaltstack`, `gettid`, `write`, `exit_group`, `tgkill` |
| The worker thread | `pthread_create`, `pthread_join`, `pthread_attr_init`, `pthread_attr_setstacksize`, `pthread_attr_destroy`, `pthread_setname_np`, `sysconf`, `dlsym` (`std` looks up `__pthread_get_minstack`) | `std::thread::Builder` in `runtime/aot.rs:31`, and its `join` at `:57-64` | disappears with the root coroutine (§4.5). Later threads use raw `clone` |
| Memory allocation | `malloc`, `calloc`, `realloc`, `posix_memalign`, `free` | `std`'s `System` allocator (`__rdl_alloc` and siblings) behind every `Box`, `Vec`, `String` and `Rc`. **That includes every GC heap object**: `runtime/heap.rs` allocates objects as boxes, and `runtime/strobj.rs:78` calls `std::alloc::alloc` directly | a `#[global_allocator]` of the runtime's own over `mmap`. This is the largest single piece of work: the collector's heap currently sits on glibc's `malloc` |
| Thread-locals | `__tls_get_addr`, `__cxa_thread_atexit_impl`, `pthread_key_create`, `pthread_key_delete`, `pthread_setspecific` | `thread_local! PROGRAM` (`runtime/vm.rs:76-83`), whose `RefCell<Option<Rc<…>>>` needs a destructor; `std`'s own thread-locals | move `PROGRAM` into the `Vm`, already a prerequisite for actors (§4.3 item 10). Then the runtime needs no thread-local at all |
| Environment and arguments | `getenv`, `strlen` | `std::env::var` for `BOTLISH_NATIVE_STACK_BYTES` (`runtime/aot.rs:26`), `BOTLISH_NATIVE_GC_STRESS` and `BOTLISH_NATIVE_GC_MIN` (`runtime/heap.rs:63-64`); `std::env::args_os` in the generated `startup.rs`. On glibc, `std` receives `argc`/`argv` from glibc's `.init_array` call | read `envp` and `argv` from the initial stack in `_start` |
| Output | `write`, `writev`, `__errno_location`, `__xpg_strerror_r` | `writeln!(std::io::stdout().lock(), …)` for the program's value and `eprintln!` for errors (`runtime/aot.rs:46-66`); `std::io::Error`'s `Display` | `write` on fd 1 or 2 of a `String` formatted with `core::fmt` |
| Time | `clock_gettime` | `std::time::Instant` for collection timing (`runtime/heap.rs:41, 119`), only when metrics are enabled | `clock_gettime` through the vDSO or a raw system call, or no timing in executables |
| Randomness | `getrandom`, plus `poll` and `close` on its fallback path | `std::collections::HashMap`'s `RandomState` in the allocation-site statistics (`runtime/metrics.rs:42, 212, 257`), seeded when the table is created | a fixed hasher or a `BTreeMap`; site statistics need no resistance to hash flooding |
| Panics and backtraces (`std` itself) | `_Unwind_*` (12 symbols from `libgcc_s`), `dl_iterate_phdr`, `open64`, `read`, `fstat64`, `stat64`, `statx`, `lseek64`, `readlink`, `realpath`, `getcwd`, `mmap64`, `munmap`, `close` | `std`'s panic runtime: `rust_eh_personality`, `__rust_start_panic`, and the default hook's backtrace printer (`std::backtrace_rs`, which symbolizes by reading the executable's own debug information) | `panic = "abort"` plus a `#[panic_handler]` that writes one line and exits: no unwinder, no symbolization. Today `runtime/aot.rs:57-64` reports a worker panic as `native executable panicked (NATIVE BUG)` through `join`; without the worker thread, the panic handler must print that line itself to keep the external protocol |
| Compiler-emitted memory intrinsics | `memcpy`, `memmove`, `memset`, `bcmp`, `strlen` | code rustc generates for copies and comparisons throughout (`core` string search, `num-bigint`, `Vm::new`) | the runtime's own implementations. On the `-gnu` target the toolchain expects libc to supply them |
| libm | `log2` | `num-bigint`'s radix conversion (`from_radix_digits_be`, `to_radix_le`). With its default `std` feature it estimates sizes with `f64::log2`; without it, it uses integer `ilog2` (`num-bigint-0.4.8/src/biguint/convert.rs:96-105`) | `default-features = false` on `num-bigint` and `num-traits` in `native/Cargo.toml`. `libm.so.6` drops out with no code change |

All three runtime dependencies are `#![no_std]` crates. `num-bigint` and
`num-traits` enable `std` only through their default `std` feature, and
`unicode-general-category` needs no feature at all.

### B.3 The runtime's own uses of `std`'s OS layer, by source

| Where | Use |
|---|---|
| `runtime/aot.rs:26, 31, 46-66` | `std::env::var`, `std::thread::Builder`, `std::io::stdout` plus `writeln!`, `eprintln!`, and the worker's `join` |
| `runtime/heap.rs:41, 63-64, 119` | `std::time::Instant`, `std::env::var` |
| `runtime/metrics.rs:42, 212, 257` | `std::collections::HashMap` (random seed) |
| `runtime/vm.rs:76-83` | `thread_local!` |
| `runtime/strobj.rs:78` | `std::alloc::{alloc, dealloc, handle_alloc_error}`. The same functions exist in `alloc::alloc`, but they still need a global allocator |
| `runtime/platform/x86_64_linux.rs:4` and its `libc::` calls | `std::io::Error::last_os_error`; the `libc` crate (bindings only, which call glibc) |
| `nir.rs:7, 1108, 2063` | `std::collections::HashMap`/`HashSet` in the NIR parser and validator. The executable never parses NIR, so this code is not linked into it |
| the generated `startup.rs` (`codegen/aot.rs:20-117`) | `fn main`, `std::env::args_os`, `std::os::unix::ffi::OsStringExt`, `std::process::exit` |
| the link step (`codegen/aot.rs:119-180`) | refuses anything but `target_env = "gnu"` (`:120`) and runs `rustc` for the default `-gnu` target, which links glibc's startup objects and `libc.so.6`, `libm.so.6` and `libgcc_s.so.1` dynamically |

Everything else in `runtime/` uses `core`- and `alloc`-level items.

The `botlish-native` driver (JIT, object emission, linking) is a host-side
tool built on Cranelift, `std::process::Command` (for `rustc`), files and
threads. It is not part of a produced executable and can stay on `std`.

### B.4 Routes off glibc

* **`x86_64-unknown-linux-musl`.** `std` is unchanged, statically linked
  against musl. This removes glibc but not libc. The link step's target check
  and `rustc --target` change, and the runtime library is built for the same
  target.
* **`#![no_std]` on the `-gnu` target triple.**
  * The triple's prebuilt `core` and `alloc` need no libc.
  * The runtime library becomes `#![no_std]` with `alloc`, and `startup.rs`
    becomes `#![no_main]`.
  * Link with `-nostartfiles -nostdlib -static` and `panic = "abort"`.
  * The runtime then supplies `_start`, the global allocator, the panic
    handler, the memory intrinsics and the system calls.

  This works on stable Rust.
* **`x86_64-unknown-linux-none`.** It is in this toolchain's target list
  (rustc 1.97), but `rustup` offers no prebuilt standard library for it. It
  therefore needs `core` and `alloc` built from source: nightly
  `-Zbuild-std`, or a vendored sysroot.

**Work in order of effort.** Each step stands alone, and each removes imports
from B.2:

1. `default-features = false` on `num-bigint` and `num-traits`: `libm` goes.
2. A fixed hasher for the metrics map: `getrandom` goes.
3. `PROGRAM` moved into the `Vm`: the runtime's thread-local goes.
4. The root coroutine (§4.5): the worker thread and the pthread discovery go.
5. `panic = "abort"` plus a panic handler that keeps the `NATIVE BUG` line:
   `libgcc_s` and the backtrace machinery go.
6. The runtime's own allocator: `malloc` and its siblings go.
7. The runtime's own `_start`, argument and environment reading, output,
   exit and signal system calls, plus the memory intrinsics. `std` and glibc
   are then gone from produced executables.
