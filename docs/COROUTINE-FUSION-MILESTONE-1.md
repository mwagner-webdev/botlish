# COROUTINE-FUSION-MILESTONE-1.md

Botlish's first coroutine fusion milestone: a coroutine whose whole protocol
is statically closed inside one function is compiled, by the production
native compiler, into that function's own control flow -- one native stack,
no coroutine object, no stack switch, no runtime coroutine operation -- and
means exactly what it means on the general coroutine runtime
(COROUTINES.md), which stays the oracle and the fallback.

> A coroutine is a semantic abstraction, not an implementation mechanism.
> Where every start, resume, query and release of a coroutine is an
> operation of one function and every frame it can suspend in is a function
> the compiler can inline, the suspended call chain is nothing but registers
> of that function and the one fact "after which yield", and resuming it is
> a branch. The general runtime is what a coroutine costs when that proof
> is not available, never what it must cost.

## Contents

1. [Result](#1-result)
2. [Starting architecture](#2-starting-architecture)
3. [Semantic model: what makes a coroutine fusible](#3-semantic-model-what-makes-a-coroutine-fusible)
4. [Transformation](#4-transformation)
5. [Deep-yield findings](#5-deep-yield-findings)
6. [Multi-coroutine findings](#6-multi-coroutine-findings)
7. [Fallback behavior](#7-fallback-behavior)
8. [Correctness evidence](#8-correctness-evidence)
9. [Native evidence](#9-native-evidence)
10. [Performance](#10-performance)
11. [GC and ownership](#11-gc-and-ownership)
12. [Compiler costs](#12-compiler-costs)
13. [Future architecture](#13-future-architecture)
14. [Recommendations](#14-recommendations)
15. [Files](#15-files)

## 1. Result

**Implemented** (native/src/codegen/fusion.rs, applied by the driver to
every program it loads, so the JIT, objects, standalone executables and every
inspection command compile the fused program):

* **Single-coroutine fusion.** A producer/consumer pair written with the
  existing syntax -- `coroutine {step, first} = numbers(42, count)`, a loop
  of `step()` -- runs as one function: the producer's loop and the
  consumer's loop interleave by branches, the generator's state (its loop
  counter, its MutableArray) is registers of the consumer's frame, and a
  resume is one compare of a state register and a jump
  (audit/coroutine-fusion/programs/lcg.bot, lcg-struct.bot).
* **Deep-yield fusion.** A yield two calls below the coroutine's root
  (`scan` -> `row` -> `cell`, grid.bot), a helper that yields inside a
  recognizer (`digit_run`, tokens.bot), three levels of continuation-byte
  helpers (utf8.bot) and COROUTINES.md's principal program are fused: the
  yielding call chain is inlined, so the suspended call chain is the
  inlined frames' registers plus the state.
* **Multiple cooperating coroutines.** The tokenizer's character source (one
  coroutine for the whole run) and its number and string recognizers (one
  per token, fed one character per resume) are three state machines in one
  frame, two alive at once; a coroutine whose own code constructs and
  drives another is fused together with it (nested fusion); two generators
  zipped in one loop, and a coroutine per frame of a recursion, are fused
  (case-structure.bot, held.bot).
* **Streaming recognition.** A UTF-8 validator written as a coroutine that
  is handed one byte per resume, whatever the chunking, is fused; its
  verdicts over random splits of random inputs equal an independent
  reference's (utf8.bot, `cf-streaming-boundaries`).
* **Scalar transport.** A struct a fused coroutine yields, returns or
  receives that nothing but projections reads is never built: the
  generator's `Item`s, the recognizers' `Answer`s and `Ch`s and the
  validator's `Byte`s become registers.
* **Every observable property** of COROUTINES.md -- eager construction,
  argument order, deep suspension, both protocols, stable terminal results
  and failures (with payloads), affine moves, last-use and early-exit
  releases, abandonment, contexts fixed at construction -- is preserved and
  tested fused and unfused (section 8).
* **Conservative fallback.** Everything the pass cannot prove keeps the
  general runtime, never an error: a handle that leaves its function (an
  argument, a field, a List, a result), a recursive yielding function, a
  yielding closure (section 7).

**Measured** (section 10): per item, fused code is 11.5 to 28 times faster
than the general runtime on streaming workloads, and 470 to 1,000
times where a coroutine is made per item (the general runtime maps a stack
for each). It runs within 1.1 to 1.4 times of hand-written procedural
Botlish doing the same work in one flat loop (the generator, the deep-yield
scan) -- the remainder is a spill slot and the state test, no coroutine
machinery (section 9) -- and faster than the procedural tokenizer (0.74 to
0.87) and streaming validator (0.92 to 0.98). A fused run allocates no
coroutine and maps no stack, and never allocates more than the procedural
baseline.

**Not achieved, and why** (sections 7, 12, 13):

* Coroutines whose handle crosses a function boundary (passed to a
  scheduler, stored, returned) are not fused: the pass reasons within one
  function.
* A recursive yielding function (a tree walk) is not fused: its suspended
  frames are unboundedly many, which no fixed set of registers holds.
* Fused code is larger: every start and resume gets its own copy of the
  coroutine's code (a precise control-flow graph, section 4.3). The
  generator's consumer grows from 640 to 2,279 bytes; whole programs by up
  to 1.7 times, or not at all where the producer's own function is dropped
  (section 10).
* Scalar replacement of a passed struct is the fusion pass's own, limited to
  the values the coroutine passes; values the producer builds and keeps are
  scalar-replaced only where native lowering already does it (before
  fusion), so a fused producer is not re-optimized as a whole (section 13).
* On a host without native coroutines (Windows) fusion is off by design: a
  fused program would run where the general runtime refuses it, which is
  an observable difference (section 3.4).

## 2. Starting architecture

**Front end.** COROUTINES.md is the semantics; its point 5 is the
representation. Every coroutine operation is a call of an internal root
native (`coroutine#create`, `#start`, `#resume`, `#yield`,
`std::coroutine::done?`, `coroutine#release`); `coroutine {step, first} =
worker(a)` lowers to a thunk `(block {} (call worker (ref arg1)))` whose
construction and start are two bindings. The side table `coroutines`
(hir/coroutines.tcl) records the thunks, their root calls (`boundaries`),
every yield and its function, the exact call graph (`edges`), the reachable
yield effect (`mayYield`) and each function's protocol; `hir/affine.tcl`
(AFFINE-VALUES.md) records ownership, moves, last-use releases and the
releases of early exits.

**Native lowering.** native/lower.tcl maps the natives to NIR operations
(`op cocreate THUNK`, `costart`, `coresume H M`, `coresume0`, `coyield V`,
`codone`, `corelease`), the thunk to an ordinary function (`fnvalue T`, or
`closure T %args...` when it captures the argument temporaries), and a
release-on-error edge of a call to a `pusherrorexit` pad. NIR is a list of
functions over *mutable* numbered registers (one register may have several
definitions) with labels and branches; a `handle` or release pad is a
lexical `pusherrorexit L ... poperrorexit` span.

**Code generation.** codegen::clif makes every coroutine operation a call of
a runtime helper (`rt_co_create`, `rt_co_start`, `rt_co_resume`,
`rt_co_resume0`, `rt_co_yield`, `rt_co_done`, `rt_co_release`); all but
`codone` and `corelease` are fallible safepoints, so a call that may suspend
has its frame's roots in a stack map.

**Runtime.** runtime/coroutine.rs: a `CoroutineObj` (96 bytes: state, thunk,
transport slot, cached failure, stack, saved stack pointers, resumer), an
8 MiB stack per started coroutine (pooled), `bl_co_switch` in x86-64 and
AArch64 assembly, and a collector that walks suspended and resumer stacks.
COROUTINES.md point 58 measured a resume at about 150 ns natively, flat in
the depth of the yield.

### 2.1 The fusion frontier

Where a coroutine graph can be recognized, and where it can be transformed:

| representation | what it knows | why fusion is (not) done here |
|---|---|---|
| surface AST | syntax | no resolution, no types |
| HIR | the coroutine tables, protocols, ownership, every exact callee, types | the *earliest* point that recognizes a closed graph; but HIR is expression-structured (no labels, no jumps) and serves four backends -- a state machine is a native representation decision, and expressing one in HIR would need a new node kind (COROUTINES.md forbids coroutine node kinds) |
| native lowering (HIR -> NIR) | the above, per instance, while choosing representations | a precedent exists (`InlineLeafCall` re-runs lowering on a callee's body), but only for straight-line leaves: a whole body with returns, loops, handlers, self tail calls and per-function representation state (raw registers, plans, scalar-replaced structs, release pads) would have to be re-entered mid-function |
| **NIR** | **every coroutine operation as an explicit op on a register; exact callees as function numbers after specialization; a CFG over mutable registers; errors as lexical spans** | **the latest point before the operations become helper calls; a suspended frame's locals can be registers of the consumer's frame, because registers are mutable variables; the transformation is a graph rewrite whose result the validator checks** |
| Cranelift IR | SSA values, helper calls, stack maps | too late: the coroutine operations are opaque calls |

The pass therefore *recognizes* on NIR and relies on HIR's guarantees: the
affine discipline (a handle has one owner, never copied: point 31-33) makes
"every use of the handle is in this function" a syntactic check on NIR
registers; the effect analysis (point 8) guarantees that a yielding function
is never a value, so the direct call graph is the whole yield graph; the
protocol analysis guarantees each resume's message shape. It recomputes on
NIR only what it transforms: which functions contain or reach a `coyield`
through direct calls, which registers alias the handle, and liveness.

### 2.2 Classification

| case | fusion | why |
|---|---|---|
| construction, starts, resumes, `done?`, releases and moves all in one function; root and yielding helpers environment-free, non-recursive | **fused** | the protocol is closed: every continuation is reachable from the function's own code |
| the same inside a loop body, or once per frame of a recursion | **fused** | one coroutine of the construction alive at a time per frame (checked) |
| several constructions alive at once in one function | **fused** (each its own state machine) | independent registers per site |
| a construction inside a fused coroutine's code | **fused** (nested) | the copies duplicate it; one site of several `cocreate`s |
| a yielding nested function that captures (a closure) | might be, after inlining closures | its captures live in a closure object fusion would have to read (`callenv`) |
| a yielding function reached through a multi-result companion (`callmulti`) | might be | the inliner handles `call` only |
| a handle passed to a function, stored in a struct or List, returned, put in an error payload | must keep the runtime (here) | the continuation is resumed by code the pass does not see; an interprocedural closed graph is section 13's work |
| two or more coroutines of one construction alive at once (only expressible through Lists or fields) | must keep the runtime | one set of registers per construction |
| a recursive yielding function | must keep the runtime | unboundedly many suspended frames: an explicit continuation stack, which is what the runtime's own stack already is |
| a host without native coroutines | off | fusion must not make runnable what the general runtime refuses |

## 3. Semantic model: what makes a coroutine fusible

### 3.1 The closed graph

A construction site is the register a `cocreate` defines (its *handle*). It
is fused when all of these hold, each checked by the pass
(`fuse_site`):

1. **The body is a known thunk.** The `cocreate`'s operand is defined only by
   `fnvalue T` or `closure T %c...` (the same T and captures wherever it is
   defined -- see 4.6), used by nothing but constructions; T takes no
   parameters, returns one tagged value and uses no scalar ABI.
2. **The handle never leaves the function.** Every register that can hold
   it -- the handle and every register a `move` copies it into, transitively
   -- is written only by the construction, a `move` from another such
   register, or `unit`, and read only as the handle of `costart`,
   `coresume`, `coresume0`, `codone` or `corelease`, or by such a `move`.
   An argument, a closure capture, a struct field, a List element, a
   payload, a return, a guard or a message is a use the pass does not
   follow. Under the affine discipline this is exactly "the function owns
   the coroutine for its whole life".
3. **One coroutine of the site at a time.** No register holding the handle
   but the one the construction defines is live after the construction
   (codegen::roots's liveness). Then the coroutine an earlier execution of
   the construction made is unreachable when the next one is made, and one
   set of state registers per site suffices. Valid programs always satisfy
   it (a second live handle needs storage, which condition 2 excludes); it
   is the pass's own guard.
4. **The yield graph is inlinable.** Let *yielding* be the least set of
   functions containing a `coyield` or a direct call of a yielding function.
   Starting from T, every direct `call` of a yielding function is inlined,
   recursively; each inlined function must be environment-free (T excepted),
   single-result, reached by `call` (not `callenv`, `callmulti`), and not
   already on the inlining stack (no recursion; a self tail call is a loop
   and fine); the whole is within a budget (20,000 inlined instructions,
   100,000 for all copies). Calls of non-yielding functions stay calls.

Nothing else is required: the coroutine's code may allocate, fail, handle
errors, construct and drive coroutines of its own, read contexts, loop,
branch and tail-call.

### 3.2 Why these preserve every observable property

* **Eager construction and argument order.** The lowering already evaluates
  the arguments before `cocreate` (into the closure's captures) and puts
  `costart` right after it. Fused, the closure's definition copies the
  captured values into registers the inlined thunk reads, and `costart`
  jumps to the inlined thunk's entry: the body runs to its first yield, its
  return or its failure before the start's result exists, as before.
* **Deep suspension.** A yield anywhere in the inlined chain stores the
  outward value and its own number, and jumps back to the operation that
  ran the segment; the inlined frames' registers keep their values (they
  are the function's registers), so resuming at "after yield k" continues
  that frame with its callers' frames around it -- each a region of the
  same code with its `ret` turned into a jump to the call's continuation.
* **Protocols.** `coresume` stores its message in `msg`, `coresume0` stores
  unit; the k-th resume point reads `msg` into the yield's destination.
* **Stable terminal states.** The root's return stores its value in `out`
  (the cache) and the state -1; a later resume dispatches -1 straight to the
  operation's continuation, which reads `out`: the same value, no code. A
  failure stores the state -2 and its error in a terminal failed coroutine
  object (`op cofailed`, below), which every later resume raises again.
* **Errors cross the operation that ran the segment.** Each copy of the
  coroutine's code is one `pusherrorexit` span; its failure pad caches the
  error and jumps to a stub placed *where the start or resume was*, inside
  the error-exit spans that operation was in, which raises it: handlers on
  the resume, release pads of other handles and the enclosing function's
  error exit see exactly the error the runtime's `rt_co_resume` would have
  returned.
* **Ownership.** A move of the handle is a register move (it copies unit);
  `done?` is `st < 0`; a release is nothing -- the coroutine's state is
  registers whose last uses have passed -- so abandoning a suspended
  coroutine runs nothing after its yield, as releasing one does.
* **Contexts** are static (CONTEXTS.md, CONTEXT-TRAITS.md): the inlined code
  is the code the construction selected.
* **Stack depth is a resource, not a property.** A fused coroutine's code
  runs on its consumer's stack (the thread's: 1 GiB by default), not on an
  8 MiB stack of its own, so a recursion inside it deep enough to exhaust 8
  MiB but not the thread's stack returns its value fused where the general
  runtime stops with NATIVE LIMIT STACK. Recursion depth was already a
  resource limit that differs between backends (Compilerpedia's NATIVE
  LIMIT STACK topic), and an overflow of the thread's stack is still
  NATIVE LIMIT STACK, never a crash, because the stack guard covers it
  (native-stack-overflow.test's `ns-co-fused`). The tests of the coroutines'
  own stacks and guards run on the general runtime.

### 3.3 The cached failure: one runtime operation

A fused coroutine that fails must raise the same error at every later
resume. The pending error (an `RtError`, its declared id, its payload) is
the runtime's; NIR has no value for it. `op cofailed` (nir.rs, ops.rs,
`rt_co_failed` in runtime/coroutine.rs) takes it, exactly as a coroutine
body's unhandled failure is taken (`co_body`), into a new `CoroutineObj` in
state FAILED -- no thunk, no stack -- and `op coresume0` of that object
raises it through the runtime's own stable-terminal-failure path
(`reraise`). It is allocated only when a fused coroutine fails; a run that
does not fail calls no coroutine helper at all (section 9).

### 3.4 Hosts

The pass runs where native coroutines exist (Linux x86-64 and AArch64, macOS
AArch64: `runtime::coroutine::STACK_SWITCHING`). On Windows the general
runtime reports NATIVE UNSUPPORTED for every coroutine; a fused program would
run there, which would make fusion observable. Enabling fusion on Windows is
a decision for a later milestone (tests/platform/native-status.tcl records
the refusal).

## 4. Transformation

### 4.1 The template

The thunk and its yielding call chain are inlined once into a *template*:
their registers renumbered into fresh registers of the consumer (with their
kinds: raw, plan, short, packed ASCII, C word), their labels into a private
label space. Per inlined function: its parameters are bound to the call's
argument registers (a raw parameter of the tagged ABI unboxed, as the
prologue would do: `runbox`), its body copied, its `ret` turned into a move
to the call's destination and a jump to the call's continuation, a self
`tail` into a parallel rebinding of its parameters and a jump to its inlined
entry. Five registers of the consumer carry the coroutine:

```text
st      0 fresh, k suspended at the k-th yield, -1 completed, -2 failed (raw)
out     the outward value: a yield's, or the final result (the cache)
msg     the resume message
failbox a terminal failed coroutine holding the failure
caps    the thunk's captured values
```

A `coyield %v` (the k-th) becomes `out = v; st = k; jump BACK; label
RESUME_k; dst = msg`; the thunk's `ret %r` becomes `out = r; st = -1; jump
BACK`.

### 4.2 The consumer's operations

| operation | fused |
|---|---|
| `%f = closure T %c...` | `caps[i] = move %c_i` |
| `%h = op cocreate %f` | `st = 0; %h = unit;` reset of the template's tagged registers live into a dispatch (4.5) |
| `%r = op costart %h` | `jump ENTRY(copy)`; then `label RAISE: op coresume0 failbox`; `label BACK: %r = out` |
| `%r = op coresume %h %m` | `msg = %m; jump DISPATCH(copy)`; the same stub and continuation |
| `%r = op coresume0 %h` | `msg = unit; jump DISPATCH(copy)`; the same |
| `%d = op codone %h` | `%d = op rilt st 0` |
| `%u = op corelease %h` | `%u = unit` |
| `%h2 = move %h` | unchanged (it copies unit) |

### 4.3 One copy per start and resume

Every start and every resume gets its own *copy* of the template, placed
after the function's code, over the *same* registers but with its own
labels, whose BACK is that operation's continuation:

```text
label DISPATCH_j                   (resumes only)
pusherrorexit FAIL_j
  st == 1 -> RESUME_1_j ... st == K -> RESUME_K_j
  st == -1 -> BACK_j (the cached result)    else -> RAISE_j (the failure)
label ENTRY_j
  <template, labels renamed>
poperrorexit
label FAIL_j
  failbox = op cofailed; st = -2; jump RAISE_j
```

The first version of the pass shared one copy between all operations, with
a `site` register saying where to go back. It was correct, but its control
flow graph was not: from the shared code every operation's continuation is
reachable, so liveness, root plans and the validator see paths no run takes.
The validator caught it (the safety net of 4.7): four golden suites'
collecting loops (a private List plan extended once per iteration,
validate_plans' linearity) were rejected as "plan register may be consumed
twice", on a path entering the loop body through another resume's
continuation. With a copy per operation a segment returns only to the
operation that ran it, as in the source, and the per-yield site dispatch
disappears from the hot path too. The cost is code size (section 12); code
of a copy reachable only from another operation's copy is dead and removed
by Cranelift.

One infeasible edge per continuation remains, in the dispatch itself: the
graph lets each copy's dispatch reach every continuation of the copy, while
a run reaches only the continuation of the yield the coroutine is suspended
at, and none after it has completed or failed. The census of the whole test
suite (section 7) found the validator rejecting twelve sites for it, in four
golden suites, all one shape: a producer that yields inside a collecting
loop consumes the loop's plan and completes, and a later resume's dispatch
-- on a path only the graph has -- enters a continuation that consumes the
plan again. 4.5's plan clearing closes it.

### 4.4 Scalar transport

Fusion puts the struct a yield sends (or a resume hands in) and the
projections that read it into one function. When every register a `move`
connects to `out` (or `msg`) is written only by `structnew` of one shape, a
`move` or `unit`, and read only by `structget` or a `move`, the struct is
never needed as an object: each such register becomes a register per field,
`structnew` copies its fields, `structget` reads one (`scalar_transport`).
Any other use -- a List, a call, a return, a field -- leaves the struct an
object. Native lowering's own scalar replacement (hir/escape.tcl) ran before
fusion and could not see this: the yield and the projection were in
different functions, with a stack switch between them.

### 4.5 Resets, plan clearing and dead code

At each construction the template's tagged registers that are live into a
dispatch are reset to unit, so a construction in a loop does not keep the
previous coroutine's values alive as roots, and no register is read unset on
a path the liveness considers.

Plan registers (a collecting loop's List under construction, which
validate_plans requires to be consumed at most once on every path) are
cleared to unit where the template suspends at a yield whose continuation
does not read them, and where it completes or fails (`clear_plans`). "Reads"
is liveness over the template alone, where a yield goes on to its own
continuation, as a run does once resumed: a plan read after a *later* yield
is live at every earlier continuation and is never cleared there. So every
dispatch is entered with each plan a continuation reads unconsumed: either
the run's own continuation reads it, and the producer's code had it
unconsumed there (it validated), or it was cleared. Unit is an ordinary
value a plan register may always hold, and a cleared register is one no
code a run reaches reads. The clearing costs nothing unless a plan lives
across a yield; case-plan.bot is its test (fused, on every backend and
under GC stress), and two mutants pin it (section 8): without the clearing
the sites fall back; with liveness that stops at the next yield, a plan
needed after the second of two yields is cleared at the first and the run
fails. After a function's sites are fused, every
function nothing refers to any more (a fused coroutine's thunk, and the
producers only it called) keeps its number but loses its code
(`unreachable`), so machine code size counts what runs.

### 4.6 Repeated and nested fusion

The pass fuses a function's sites one at a time, scanning again after each.
A construction inside a fused coroutine's code is copied into every copy of
the template: one handle register defined by several `cocreate`s, with the
same thunk register, defined by the same `closure` everywhere. Such a group
is one site (conditions 1-3 apply to the group), so it is fused in turn and
the outer and inner coroutines become two state machines in one frame
(`cf-nested-fusion`). A site that fails a condition is reported and kept;
its function stays as it was.

### 4.7 Validation and fallback

Each rewritten function is validated (`nir::validate_function`: kinds,
labels, call agreement, plan linearity) before it replaces the original; a
rewrite that does not validate is discarded and reported as a fusion bug.
After the program is fused, `nir::resummarize` settles every function's and
call site's effects again. `BOTLISH_NATIVE_COROUTINE_FUSION=0` turns the pass
off: the oracle every test compares with.

### 4.8 Inspection

* `botlish-native fusion FILE.nir` -- what became of each construction
  site: `fused FUNCTION eORIGIN {inlined NAMES yields K creates C starts S
  resumes R queries Q releases L template T copied N unboxed U}` or `kept
  FUNCTION eORIGIN REASON` (`native::fusion` in Tcl).
* `botlish-native fused FILE.nir` -- the NIR every other command compiles,
  printed by codegen::nirtext (it reads back: `cf-fused-nir-reads-back`;
  `native::fusedNir`).
* `BOTLISH_NATIVE_COROUTINE_FUSION_LOG=FILE` -- appends the report of every
  program the driver loads: a census of a whole test run.
* audit/coroutine-fusion/tools/evidence.tcl -- the NIR before and after and
  the machine code of each workload's consumer (section 9).

### 4.9 A small example

```botlish
fn counter(m: int) -> V:
    loop i from 0 to m:
        yield V {n: i}
    return V {n: m}

fn consume(m: int) -> int:
    coroutine {step, first} = counter(m)
    total = first.n
    loop i from 0 to m:
        total2 = step().n
    total
```

lowers to (the consumer; `counter` and the thunk are functions 1 and 3):

```text
func 2 "consume"
    %1 = op rbox %0
    %2 = closure 3 %1
    %3 = op cocreate %2
    %4 = op costart %3
    %6 = structget 0 %4
    ...
  label L1
    %12 = op coresume0 %3
    %13 = structget 0 %12
    ...
  label L4
    %17 = op corelease %3
    ret %6
```

and is fused into (abridged; `%18` is `st`, `%47` the one field of `out`,
`%20` `msg`, `%21` the failure box):

```text
func 2 "consume"
    %22 = move %1                   ; the closure: its capture
    %18 = rawint 0                  ; the construction
    %3 = unit
    %25 = unit  %47 = unit  %20 = unit  %21 = unit     ; resets
    jump L8                         ; the start: the start copy's entry
  label L6                          ; the start's failure stub
    %39 = op coresume0 %21
    unreachable
  label L5                          ; back from the start
    %45 = move %47
    %6 = move %45                   ; first.n (V {n} scalar-replaced)
    ...
  label L1                          ; the resume in the loop
    %20 = unit                      ; zero-message protocol
    jump L31                        ; the resume copy's dispatch
  label L20
    %44 = op coresume0 %21          ; its failure stub
    unreachable
  label L19                         ; back from the resume
    %46 = move %47
    %13 = move %46                  ; step().n
    ...
  label L31                         ; the resume copy
    pusherrorexit L32
    %41 = op rieq %18 1  -> L30     ; suspended after yield 1
    %43 = op rieq %18 -1 -> L19 else L20
  label L26                         ; counter's loop body (inlined)
    %32 = op rbox %29
    %47 = move %32                  ; yield V {n: i}: out
    %18 = rawint 1
    jump L19                        ; straight back to the resume
  label L30                         ; after yield 1
    %34 = move %20
    ... (counter's loop continues: i + 1, i < m)
  label L23                         ; counter returned V {n: m}
    %47 = move %48
    %18 = rawint -1
    jump L19
    poperrorexit
  label L32                         ; a failure inside the resume copy
    %21 = op cofailed
    %18 = rawint -2
    jump L20
```

## 5. Deep-yield findings

Inlining the yielding call chain answers the brief's question for every
non-recursive chain: the native call stack between the coroutine's root and
a yield is an implementation detail the compiler can reconstruct, because a
fixed, statically known set of frames can be one function's registers.

* **grid.bot**: `scan` loops over rows calling `row`, which loops over cells
  calling `cell`, which yields -- every yield two calls below the root. The
  fused consumer contains `scan`, `row` and `cell` inlined; resuming jumps
  into `cell`'s code after its yield, whose `ret` jumps into `row`'s loop,
  and so on: three loops nested in one function, entered from the middle.
  It runs *faster* than the procedural baseline that calls `cell` and `row`
  (section 10): fusion inlined the calls.
* **The principal program** (COROUTINES.md): `worker` calls `deep`, which
  yields; resumed with messages. Fused at the top level, three resumes.
* **tokens.bot**: the number recognizer calls `digit_run` twice, which
  yields per digit: both calls inlined (two copies of `digit_run` in the
  template).
* **utf8.bot**: the validator calls `continuation` three times per
  character, each yielding.
* **case-tail.bot**: a yielding function that loops by a self tail call
  (`return walk(from + step, to, step)`): inlined, the tail call is a jump
  to its inlined entry with its parameters rebound.

Limits: recursion (a tree walk; `fallbacks.bot`'s `leaves`) is not fused --
its suspended state is a stack of unbounded depth, and an explicit
continuation stack in the frame would be a reimplementation of the runtime's
own stack; a yielding closure (`case-closure.bot`) is not inlined, since
its captures live in a closure object read by `capture` through `callenv`.
Both are recognized and reported.

## 6. Multi-coroutine findings

**Several coroutines become several state machines in one frame**, each with
its own registers; cooperation is ordinary control flow between them.

* **tokens.bot** (after json_tokens.bot): `lex` owns the character source
  `chars(text)` for the whole run and constructs a `number()` or `string()`
  recognizer per token, feeding it the source's characters (a struct message
  per resume) until it answers "done". All three constructions are fused
  into `lex`: two coroutines alive at once, three state machines, one stack,
  no coroutine operation. The recognizers keep no state but the yield they
  are suspended at -- "a number between its sign and its digits" and "inside
  its fraction" are different yields, "a string that just read a backslash"
  is the yield that takes the escaped character -- which is exactly what a
  hand-written DFA's state number encodes.
* **Nested fusion** (case-structure.bot's `nested`): a coroutine `outer`
  whose own code constructs and drives `counter` coroutines; fusing `outer`
  into its consumer copies `counter`'s construction into every copy, and the
  pass then fuses that group too. The consumer runs both without a
  coroutine operation.
* **Two generators zipped** in one loop (`zipped`): two sites, fused
  independently.
* **One coroutine per recursion frame** (`held`, held.bot): each activation's
  registers are its own coroutine's; K coroutines alive at once cost K
  frames on the one stack, against K coroutine objects and K stacks.

**What explicit local state does not cover.** Two continuations of *one*
construction alive at the same time need two sets of registers; the
language can only express that through storage (a List or struct of
handles), which the pass does not follow, so the general runtime keeps them.
A coroutine that resumes a coroutine its *consumer* owns (a pipeline where
the handle is handed down) needs the handle passed as an argument -- the
interprocedural case of section 13. The tokenizer avoids it by letting `lex`
mediate: the recognizers receive characters, they do not pull them.

Combining the state machines further -- one dispatch over the product of
their states, or eliminating the dispatch where a state is statically known
at a resume -- is not done: each resume of each coroutine is one compare of
its own state (section 9), which measured below the noise of the
surrounding work.

## 7. Fallback behavior

`fallbacks.bot` keeps one coroutine per reason, beside two that fuse
(`cf-fallbacks`); every one runs the same either way:

| function | construction | reason the pass reports |
|---|---|---|
| `passed` | handle passed to `drain(step)` | its handle reaches `%N = call F %N`, which fusion does not follow |
| `stored` | handle put in a struct field, destructured, passed on | its handle reaches `%N = call F %N` (native lowering had already scalar-replaced the struct) |
| `made` | handle returned to the caller | its handle reaches `ret %N` |
| `tree` | a recursive yielding function | its yielding function leaves is recursive |
| `listed` | handles in a List literal | its handle reaches `%N = op listnew %N %N` |
| `outer` (case-closure.bot) | a yielding closure capturing `base` | its function #5 calls a yielding function in a form fusion does not inline: `%1 = callenv 4 %0` |
| `held`, `local`, `nested` | per recursion frame; local; an environment-free nested yielding function | fused |

How often each happens, counted with `BOTLISH_NATIVE_COROUTINE_FUSION_LOG`
over whole runs (every native compilation the run made):

| corpus | sites fused | kept | reasons kept |
|---|---:|---:|---|
| tests/coroutines.test | 194 | 13 | 12 a recursive `deep` helper, 1 a recursive `down` |
| audit/coroutines/tools/fuzz.tcl, seeds 1, 3000, 7000 (300 programs) | 2,196 | 0 | -- |
| the golden suites (every backend) | see section 8 | | |

The fuzzer's generator never stores, passes or recursively yields a handle
(COROUTINES.md point 52), so all of its sites are fusible; the coroutine
test file's recursive helpers are its only fallbacks.

## 8. Correctness evidence

**tests/coroutine-fusion.test** (17 tests, every one passing):

| test | what it shows |
|---|---|
| `cf-workloads-agree` | the nine workload programs have their stated values on interp, compile, cranelift-generic, cranelift (fused) and cranelift-unfused |
| `cf-workloads-fused` | which sites are fused in each workload |
| `cf-fallbacks` | the kept sites and their reasons (section 7) |
| `cf-cases-agree`, `cf-cases-fused` | ten correctness cases, fused, on every backend: construction order and eager start (case-eager), completion during construction and cached results (case-early), terminal failure with a payload at construction and in a segment, raised again by every later resume (case-failure), moves, abandonment, early returns, breaks and continues (case-owners), loops, two live coroutines, nested and per-frame fusion (case-structure), collection pressure (case-gc), contexts (case-context), a self tail call (case-tail), a collecting loop whose List plan lives across two yields, then completion and failure and later resumes (case-plan, 4.5), and the closure that falls back (case-closure) |
| `cf-nested-fusion` | the nested site is one group, fused; no coroutine operation is left in the consumer |
| `cf-gc-stress` | ten programs under `BOTLISH_NATIVE_GC_STRESS=1`, fused and unfused, equal and as stated |
| `cf-nir-no-coroutine-operations` | the fused consumers' NIR keeps only `cofailed` and `coresume0` of the failure object |
| `cf-clif-no-coroutine-helpers` | the fused programs' Cranelift IR refers to no coroutine helper but `rt_co_failed` and `rt_co_resume0` |
| `cf-no-coroutine-at-run-time` | a fused run allocates no coroutine and maps no stack |
| `cf-failure-allocates-the-cache` | a fused failure allocates one object (the cache) and maps no stack |
| `cf-scalar-transport`, `cf-scalar-transport-escapes` | passed structs read only by projections are not allocated; Events the principal program collects are |
| `cf-fused-nir-reads-back` | the printed fused NIR is valid and runs to the same value |
| `cf-fusion-off` | the switch turns the pass off |
| `cf-executable` | a standalone executable of the tokenizer, also under GC stress |
| `cf-streaming-boundaries` | 60 random inputs x 3 random splits through the validator, against an independent Tcl validator, fused and unfused |

**tests/coroutines.test** runs every program of the coroutine milestone on
five backends now -- `coAgree` adds `cranelift-unfused` (tests/helpers.tcl's
`outcomeUnderHir`) -- so each of its programs is checked fused against the
general runtime: 81 tests, 81 passed. Its three tests of the runtime's own
resources (the handle's allocation, stack reuse after releases) run with
fusion off (`withoutCoroutineFusion`), since fusion removes what they count;
its source audit of the coroutine operations lists `cofailed`.

**The coroutine fuzzer** (audit/coroutines/tools/fuzz.tcl, its default
backends now including cranelift-unfused): seeds 1, 3000 and 7000, 100
programs each, 178 accepted programs compared value by value on five
backends with the oracle, 122 rejected ones by diagnostic class: 0
disagreements; every one of the 2,196 construction sites it produced was
fused.

**Rust**: the fusion pass's unit tests (`cargo test --release --bin
botlish-native fusion`: a generator fused and run without the coroutine
runtime, a collecting loop's plan across two yields fused and run, a handle
reaching a call kept, a recursive yielding function kept, the report's
text) and the NIR printer's round trip (`nirtext`).

**Mutation testing** (audit/coroutine-fusion/tools/mutate.tcl, mutants.txt):
13 deliberate bugs of the pass, each applied to a private copy of the
compiler and native backend, rebuilt, and run against the fusion pass's Rust
tests, tests/coroutine-fusion.test, tests/coroutines.test and the coroutine
fuzzer (25 programs, seed 11, five backends). **13 killed, 0 survived**:

| mutant | what killed it |
|---|---|
| **escape-followed**: a handle reaching a call, field, List or return is fused anyway | `cf-fallbacks`, `cf-workloads-agree`; the Rust test of a handle reaching a call |
| **recursion-unchecked**: a recursive yielding function is inlined (until the budget stops it) | `cf-fallbacks`; the Rust test of recursion |
| **yield-state-lost**: a yield does not record where the coroutine is suspended | 51 tests; 17/25 fuzz programs; the Rust generator test |
| **completion-not-cached**: the root's return does not mark the coroutine completed | 16 tests; 5/25 fuzz programs |
| **failure-not-cached**: a failure marks the coroutine completed, not failed | 7 tests (`co-errors-segment`, `co-errors-startup`, `co-context-portable-io`, ...); 2/25 fuzz programs |
| **terminal-swapped**: a completed coroutine's resume raises, a failed one's returns | 23 tests; 7/25 fuzz programs |
| **message-dropped**: a resume does not hand its message in | 23 tests; 9/25 fuzz programs |
| **done-inverted**: `done?` is true while suspended | 14 tests; 11/25 fuzz programs |
| **captures-confused**: every capture reads the first captured value | `cf-gc-stress`, `cf-workloads-agree` |
| **tail-no-rebind**: an inlined self tail call does not rebind its parameters | `cf-cases-agree` (case-tail), `cf-gc-stress`, `co-effect-recursive` |
| **raw-parameter-not-unboxed**: a raw parameter of the tagged ABI gets the tagged argument | `cf-cases-fused` -- the rewrite no longer validates, so the site silently keeps the general runtime (the safety net of 4.7), and only the test that pins fusion notices |
| **transport-escape-ignored**: a passed struct some use needs as an object is scalar-replaced anyway | 6 tests (`cf-scalar-transport-escapes`, `co-terminal-identity`, ...); 18/25 fuzz programs |
| **referenced-dropped**: a function only a Block value refers to loses its code | `cf-workloads-agree` |

The fuzzer alone misses the mutants of constructs it never generates
(handles that escape, recursive or tail-calling yielding functions, multiple
captures, raw parameters, closures); a focused test kills each.

REGRESSION-PLACEHOLDER

## 9. Native evidence

audit/coroutine-fusion/evidence/ holds, per workload, the NIR the lowering
writes (`NAME.general.nir`), the NIR after fusion (`NAME.fused.nir`), the
fusion report, and the machine code of the consumer function fused, unfused
and in the procedural baseline (`NAME.{fused,general,procedural}.s`,
objdump of `botlish-native object`); summary.md tabulates them:

| workload | consumer | bytes: fused / general / procedural | calls: fused / general / procedural | coroutine helpers the fused code calls | the general code calls |
|---|---|---:|---:|---|---|
| lcg | `sum` | 2,279 / 640 / 863 | 25 / 12 / 9 | `rt_co_failed` 1, `rt_co_resume0` 3 (failure paths) | create, start, `resume0` 2, release 2 |
| lcg-struct | `sum` | 2,279 / 631 / 863 | 25 / 12 / 9 | the same | the same |
| grid | `total` | 1,551 / 661 / 445 | 9 / 12 / 5 | `rt_co_resume0` 2 (failure paths) | create, start, `resume0` 2, release 2 |
| tokens | `lex` | 5,581 / 2,965 / 1,817 | 56 / 61 / 24 | `rt_co_resume0` 5 (failure paths) | create 3, start 3, resume 2, `resume0` 3, release 14 |
| utf8 | `validate` | 4,141 / 1,557 / 3,789 | 33 / 20 / 39 | `rt_co_resume0` 1 (failure path) | create, start, resume, release 2 |

The calls the fused code makes besides those are the producer's own, now
inlined: the arithmetic helpers on their overflow paths (`rt_int_mul`,
`rt_int_add`, `rt_int_and`), the MutableArray's copy-on-write slow path
(`rt_mutarray_set_proven`), the tokenizer's String and List operations.
The general consumers' calls are the coroutine operations and little else,
because the producer is a separate function there.

lcg-struct's fused consumer is lcg's, instruction for instruction: the same
2,279 bytes, with two stack slots assigned in another order. Its producer
yields `Item {value: ...}` and the consumer reads `.value`; scalar transport
(section 4.4) turned the Item into the register lcg yields directly, so the
struct exists nowhere in the fused program -- where the general runtime
allocates one per item (section 10's allocation table: 100,005 objects
against 2).

The coroutine helpers left in fused code are on failure paths only: each
start's and resume's raise stub (`rt_co_resume0` of the failure object) and
each copy's failure pad (`rt_co_failed`). Where nothing in a coroutine's code
can fail, Cranelift removes the pads as unreachable (grid, tokens and utf8
call no `rt_co_failed` at all). A successful run calls none of them
(`cf-no-coroutine-at-run-time`: no coroutine object allocated).

The hot path of the fused LCG consumer (lcg.fused.s), one item:

The loop body is the consumer's `acc.set(0, acc.at(0) + step())` with the
resume's copy of the producer in place of `step()` (objdump of `botlish-native
object`; comments added, the slow paths' bodies elided):

```
 5c6:  mov    %rcx,%r15              ; consumer: acc
 5d2:  mov    0x10(%r15),%r11        ;   acc.at(0)
 5d6:  mov    (%r11),%rsi
 5e3:  cmp    $0x1,%r12              ; step(): the dispatch. st in %r12, a raw word
 5e7:  je     678                    ;   suspended at the yield: resume the producer
 5ed:  cmp    $0xffffffffffffffff,%r12   ;   completed (st = -1)?
 5f1:  jne    601                    ;   no: failed -> the raise stub
 5f7:  mov    0x48(%rsp),%rdx        ;   yes: the cached result
 5fc:  jmp    842
 601:  ...                           ; raise stub: rt_co_resume0 of the failure object, rt_raise
 678:  add    $0x1,%r13              ; producer: `loop i from 0 to count`, i a raw word in %r13
 67f:  cmp    %rbx,%r13
 682:  jl     6a7
 688:  mov    $0xffffffffffffffff,%rdx   ;   loop done: `return -1` (st = -1, out = -1)
 6a2:  jmp    842
 6a7:  mov    0x58(%rsp),%rsi        ; state.at(0)
 6ac:  mov    0x10(%rsi),%rax
 6b0:  mov    (%rax),%rsi
 6dd:  sar    $1,%rax                ; * 1103515245: inline on small Ints,
 6e0:  imulq  0x251(%rip)            ;   rt_int_mul only on overflow (6fe)
 72d:  add    $0x6072,%rsi           ; + 12345: inline, rt_int_add only on overflow (74a)
 787:  and    0x1b2(%rip),%rsi       ; mod 2^31 as a mask; rt_int_and only for a BigInt (773)
 79d:  mov    0x18(%rsi),%rax        ; state.set(0, next): copy-on-write check,
 7b8:  mov    %rdx,(%rcx)            ;   store (rt_mutarray_set_proven only if shared)
 7bb:  mov    $0x1,%r12d             ; yield: st = 1
 7c6:  sar    $1,%rdx                ; next.mod(1000) by reciprocal multiplication
 7d3:  imulq  0x16e(%rip)
 ...
 834:  or     $0x1,%rdx              ;   retagged: the yielded value, out
 842:  ...                           ; the resume's continuation, back in the consumer
 857:  test   $0x1,%rdi              ; acc.at(0) + step(): both small Ints?
 870:  add    %r9,%rcx               ;   tagged add, rt_int_add only on overflow (88a)
 892:  mov    0x18(%r15),%rax        ; acc.set(0, ...): copy-on-write check, store
 8a3:  mov    %rcx,(%rax)
 8a6:  add    $0x1,%r14              ; consumer: `loop i from 1 to count`
 8b5:  jmp    327                    ;   back to the loop test
```

Per item: one compare and branch of the state word instead of
`rt_co_resume0`, the stack switch into the producer and the switch back;
the producer's counter and state are the consumer's registers and stack
slots (%r13, 0x58(%rsp)); the yield is a store of an immediate into %r12.
No helper is called on the path a successful item takes.

What separates this loop from the procedural one (lcg.procedural.s, the same
operations in one loop: `sum`'s body at 0x245-0x346) is register allocation
and the dispatch: the procedural loop keeps `next` in %r15, while the fused
one keeps the value register its copies share in a spill slot, 0x48(%rsp),
stored and reloaded around nearly every step of `next.mod(1000)` (it is
assigned on three paths that join at 0x842: the yield, the producer's
`return -1` and a completed coroutine's cached result), and it tests `st`
once per item. That is the 1.2-1.4x of section 10, not coroutine machinery: there is
none left to remove here.

## 10. Performance

`tclsh9.0 bench/coroutine-fusion.tcl` (defaults: best of 5 in-process runs,
5 interleaved driver processes per variant, minimum and median over them;
an Intel Xeon @ 2.10 GHz, 4 cores, in a shared container, so medians move by
10-20% from run to run and the occasional outlier is the machine's). Every
workload runs three ways, natively on cranelift: **general** (fusion off:
its coroutines on the general runtime), **fused** (the default) and
**procedural** (its hand-written baseline without coroutines, the same
work). Times are ns per item: a generated value (lcg, lcg-struct), a grid
cell (grid), an input character (tokens), an input byte (utf8), a recursion
frame holding a suspended coroutine (held).

| workload | items | general min | general med | fused min | fused med | procedural min | procedural med | fused / procedural (med) | general / fused (med) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| lcg | 10,000 | 63.69 | 69.37 | 5.02 | 5.94 | 4.21 | 4.35 | 1.37 | 11.7 |
| lcg | 100,000 | 62.16 | 67.21 | 5.12 | 5.83 | 3.85 | 4.35 | 1.34 | 11.5 |
| lcg | 1,000,000 | 62.50 | 63.99 | 5.31 | 5.46 | 3.98 | 4.50 | 1.21 | 11.7 |
| lcg-struct | 10,000 | 107.63 | 117.14 | 5.04 | 5.58 | 4.53 | 4.53 | 1.23 | 21.0 |
| lcg-struct | 100,000 | 137.34 | 154.64 | 5.22 | 5.54 | 4.54 | 7.68 | 0.72 | 27.9 |
| lcg-struct | 1,000,000 | 145.59 | 147.65 | 5.34 | 6.08 | 4.38 | 4.64 | 1.31 | 24.3 |
| grid | 10,000 | 77.97 | 85.99 | 3.63 | 3.99 | 3.24 | 3.34 | 1.19 | 21.5 |
| grid | 100,000 | 77.20 | 83.52 | 3.67 | 4.00 | 3.02 | 3.27 | 1.22 | 20.9 |
| grid | 1,000,000 | 79.65 | 82.91 | 4.06 | 4.17 | 3.15 | 4.91 | 0.85 | 19.9 |
| tokens | 2,000 | 272.63 | 292.68 | 10.85 | 12.15 | 14.70 | 15.11 | 0.80 | 24.1 |
| tokens | 20,000 | 286.26 | 303.65 | 12.08 | 12.51 | 14.47 | 14.57 | 0.86 | 24.3 |
| tokens | 200,000 | 274.84 | 287.20 | 12.15 | 12.37 | 13.89 | 15.11 | 0.82 | 23.2 |
| utf8 | 2,000 | 115.95 | 117.79 | 8.77 | 9.44 | 9.11 | 9.66 | 0.98 | 12.5 |
| utf8 | 20,000 | 121.98 | 132.98 | 8.27 | 9.08 | 9.02 | 9.52 | 0.95 | 14.6 |
| utf8 | 200,000 | 152.32 | 165.63 | 9.44 | 10.08 | 10.17 | 10.65 | 0.95 | 16.4 |
| held | 1,000 | 10,296.75 | 10,751.95 | 21.40 | 23.05 | 11.87 | 12.24 | 1.88 | 466.5 |
| held | 5,000 | 19,335.33 | 20,057.17 | 21.54 | 23.64 | 12.71 | 13.93 | 1.70 | 848.5 |
| held | 20,000 | 26,870.14 | 28,454.65 | 27.38 | 27.65 | 13.32 | 17.45 | 1.58 | 1,029.0 |

Two ratios in the median column are the machine's, not the code's: the
procedural medians of lcg-struct at 100,000 (7.68) and grid at 1,000,000
(4.91) are outliers; by the minimums those rows are 1.15 and 1.29.

Per workload, at its middle size: allocations of every kind (the
allocation-counting build's summary), coroutine objects and stacks, the
driver's peak resident memory, the program's machine code (every function,
`botlish-native size`), native lowering's time and the driver's (fusion and
Cranelift):

| workload | variant | allocations | coroutine objects | stacks | peak RSS KiB | code bytes | lower ms | driver compile ms |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| lcg | general | 4 | 1 | 1 | 11,184 | 1,530 | 19.1 | 3.7 |
| lcg | fused | 2 | 0 | 0 | 11,164 | 2,572 | 18.0 | 3.7 |
| lcg | procedural | 2 | 0 | 0 | 11,184 | 966 | 18.8 | 2.0 |
| lcg-struct | general | 100,005 | 1 | 1 | 11,524 | 1,620 | 19.0 | 3.0 |
| lcg-struct | fused | 2 | 0 | 0 | 11,168 | 2,572 | 20.3 | 4.0 |
| lcg-struct | procedural | 2 | 0 | 0 | 11,128 | 966 | 17.5 | 2.2 |
| grid | general | 3 | 1 | 1 | 11,168 | 1,425 | 28.6 | 3.2 |
| grid | fused | 1 | 0 | 0 | 11,176 | 1,889 | 25.7 | 6.0 |
| grid | procedural | 1,001 | 0 | 0 | 11,136 | 1,036 | 17.2 | 3.4 |
| tokens | general | 31,505 | 3,501 | 3,501 | 11,128 | 6,763 | 107.1 | 11.3 |
| tokens | fused | 3 | 0 | 0 | 11,164 | 6,672 | 117.8 | 11.8 |
| tokens | procedural | 3 | 0 | 0 | 11,148 | 4,259 | 108.5 | 5.9 |
| utf8 | general | 20,002 | 1 | 1 | 11,156 | 2,888 | 84.9 | 4.8 |
| utf8 | fused | 1 | 0 | 0 | 11,152 | 3,783 | 102.0 | 7.8 |
| utf8 | procedural | 1 | 0 | 0 | 11,208 | 2,072 | 86.6 | 4.0 |
| held | general | 10,000 | 5,000 | 5,000 | 30,592 | 1,212 | 48.7 | 2.6 |
| held | fused | 0 | 0 | 0 | 11,152 | 1,166 | 48.9 | 3.2 |
| held | procedural | 0 | 0 | 0 | 11,140 | 474 | 27.2 | 1.6 |

What the numbers say:

* **Against the general runtime**, fused code is 11.5 to 28 times faster per
  item on the streaming workloads, and 470 to 1,000 times faster where a
  coroutine is made per item (held: the general runtime maps a stack per
  coroutine, and its cost per frame grows with the number of stacks alive,
  from 10 to 27 microseconds). The streaming speedups are the switch pair
  and the helper calls of each resume (lcg, utf8: 11-16 times), plus the
  allocations the boundary forced on the general runtime -- a boxed message
  or result per resume (utf8: 20,002 objects), an Item per item
  (lcg-struct: 100,005), three coroutines and their stacks per token
  (tokens: 3,501 stacks) -- which the fused program does not make (lcg-struct,
  tokens, grid: 21-28 times).
* **Against hand-written procedural code**, fused code is within 1.1 to 1.4
  times of it where the procedural version is the same loop written flat
  (lcg, lcg-struct, grid); section 9 shows the remainder is a spill slot and
  the state test. It is *faster* than the procedural tokenizer (0.74-0.87)
  and validator (0.92-0.98), because their procedural versions, written as
  a programmer would without coroutines, pay for what the coroutines' form
  avoids: the procedural tokenizer scans with helper calls (`code`,
  `number_end`, `digits_end`, `string_end`), some of which read a character
  again, where the fused recognizers are inlined and see each character
  once; the procedural validator keeps the decoder's state between bytes in
  a four-slot MutableArray, read and written per byte, which the coroutine
  keeps in locals that fusion makes registers. held's procedural baseline does
  none of the counter's work, so its 1.6-2.1 is the cost of keeping a
  suspended coroutine's registers live across a recursive call (a larger
  frame and its root slots), not of resuming it.
* **Allocation.** A fused run allocates no coroutine object and maps no
  stack, and never more than the procedural baseline (grid's procedural
  version allocates an accumulator per row, 1,001 objects; the coroutine
  version yields its cells and needs none). held's general run needs 30.6 MB at its deepest point
  against 11.2 MB fused, which is the procedural program's.
* **Code size.** Whole programs grow by up to 1.7 times (lcg: 1,530 to 2,572
  bytes; the consumer function alone 640 to 2,279, section 9), grid and
  utf8 by 1.3 times, and shrink where the producer's own function is no
  longer needed (tokens 6,763 to 6,672, held 1,212 to 1,166). The procedural
  programs are smaller than either.
* **Sizes.** Per-item times are flat across sizes for every fused and
  procedural workload: fusion adds no per-run cost that a long run would
  amortize, and none that grows with the input. The general runtime's
  per-item time grows with held's depth (live stacks) and, mildly, with
  utf8's input (its boxed messages).

## 11. GC and ownership

* **Roots.** A suspended fused coroutine's values are the template's
  registers. They are live from the yield that suspended it to the next
  resume -- across the consumer's own code -- so codegen::roots, which
  computes liveness over the function's control flow graph, gives them
  shadow slots and stack-map entries at every safepoint in between, like
  any long-lived local. The precise per-operation copies matter here too:
  no register is live on a path the program cannot take. No suspended stack
  exists, so the collector's walks of suspended and resumer stacks have
  nothing to do for a fused coroutine.
* **Resets.** A construction resets the template's tagged registers that are
  live into a dispatch: a coroutine made in a loop never keeps the previous
  one's values reachable, and liveness never sees one read unset.
* **One imprecision.** The dispatch's edges to every continuation (4.3) make
  a value that some *other* continuation reads live while the coroutine is
  suspended at a yield after which nothing reads it: it stays a root until
  the coroutine moves on, where the general runtime's stack map at that
  yield would have dropped it. That retains memory longer; it never changes
  a value (the collector only keeps more). Clearing such registers at each
  yield, as 4.5 does for plans, would remove it at a store per register per
  yield; this milestone clears only plans, whose double consumption is a
  validity question, not a retention one.
* **GC stress.** Every workload and case runs under
  `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
  site) fused and unfused with equal values (`cf-gc-stress`), including
  case-gc.bot, whose coroutine keeps a growing MutableVector and Strings only
  in its suspended state, two inlined frames deep, while the consumer
  allocates between resumes; the tokenizer's executable also runs under
  stress (`cf-executable`).
* **Ownership.** Affinity is unchanged and still static: moves are register
  copies of unit, releases are no-ops, and nothing at run time records an
  owner. The general runtime is untouched (its only addition is
  `rt_co_failed`), and every program of tests/coroutines.test still runs on
  it (cranelift-unfused).
* **Releases and abandonment.** The affine analysis placed `corelease` after
  the last use and on every early exit; fused, the coroutine simply stops
  being resumed: its registers die, and nothing after its yield ever runs
  (case-owners.bot counts every segment's side effects).

## 12. Compiler costs

COMPILE-PLACEHOLDER

## 13. Future architecture

* **Interprocedural closed graphs.** The commonest fallback is a handle that
  crosses a call: a scheduler, a `drain(step)` helper, a coroutine returned
  from a factory. Fusing these needs the closed graph to span functions --
  inlining the function the handle goes to (when it is the handle's last
  owner), or passing the coroutine's state registers as a hidden aggregate
  the callee resumes through. Both want the affine analysis's ownership
  facts (who is the last owner) carried into NIR, rather than recomputed.
* **Fusion before scalar replacement.** Fusion runs after native lowering's
  escape analysis and scalar replacement, so a struct built and kept *inside*
  the producer is optimized only as the producer alone allowed; scalar
  transport covers the values crossing the boundary. Doing fusion on HIR,
  or re-running scalar replacement on fused NIR, would let one optimization
  see the whole fused program. The first needs a HIR form for "the code
  after yield k" (a labeled continuation), which COROUTINES.md's no-new-node
  rule would have to be revisited for.
* **Code size.** The per-operation copies are the price of a precise graph.
  Most of a copy is dead in that copy (the start's copy never runs the code
  after a yield it does not reach; a resume's copy never runs the entry),
  and Cranelift removes unreachable blocks, but code reachable through the
  producer's loops is duplicated. Partial duplication (copy only the region
  between a resume point and the next yield) or a shared region with the
  site dispatch, for operations the validator can prove safe, would trade
  some precision for size.
* **Recursion.** A recursive yielding function needs a stack of suspended
  frames. An explicit continuation stack (a MutableVector of frames) would
  work but would be the runtime's stack in another form; the general runtime
  is the right implementation there.
* **Closures.** Inlining a closure needs its captures as registers: when the
  closure is made in the same function (the usual nested helper), its
  `closure` instruction's operands are those registers.
* **Dispatch.** A resume compares `st` against each yield in turn. With many
  yields, a jump table (a NIR `switch`, Cranelift's `br_table`) or jump
  threading where `st` is statically known at a resume (after the first
  yield of a loop with one yield, it always is) would remove it.
* **Hosts.** On Windows, fusion would let fused coroutines run where the
  general runtime cannot yet; a later milestone can decide to accept that
  difference (or to finish the Windows stack switch first).

## 14. Recommendations

**The coroutine optimizer needs another milestone before DFA syntax is
explored -- and the evidence suggests the DFA syntax may not be needed for
the reason it was proposed.**

* *What the experiment shows.* The tokenizer's recognizers and the UTF-8
  validator are written as coroutines whose only state is where they are
  suspended; fused, their native code *is* a state machine -- a state
  register, one compare per resume, the transitions straight-line code --
  and it runs as fast as or faster than the hand-written procedural lexer
  and validator (section 10), with no allocation of its own. A declarative
  DFA syntax's main promise, "a state machine with no runtime machinery",
  is what fusion already delivers for every recognizer driven from one
  function. Coroutines also handle what DFAs do not: deep helpers
  (`digit_run`), loops with counters, calls, errors with payloads, nested
  recognizers.
* *What blocks the general case.* A reusable recognizer library hands
  coroutines across functions -- a `lex(source)` that receives its character
  source, a scheduler that owns many -- and today that is the first
  fallback (section 7). The next milestone should make the closed graph
  interprocedural (the last owner's function inlined, or the state passed
  as a hidden aggregate), carry the affine analysis's ownership facts into
  NIR instead of recomputing them, and move fusion before native lowering's
  scalar replacement (or re-run it on fused NIR), so a fused producer is
  optimized as a whole. Measuring the code-size cost on real programs, and a
  dispatch-free resume where the state is statically known, belong there
  too.
* *When to revisit DFA syntax.* If, after that milestone, recognizers
  written as coroutines and composed through library functions still fall
  back -- or if a table-driven form (a byte classifier, an LL(1) or LR
  table) turns out to need guarantees coroutines cannot state, such as a
  bounded state count checked by the compiler -- a declarative form would
  have a case of its own. It should then lower to the same fused coroutine
  machinery, not to a second runtime.

## 15. Files

| file | what |
|---|---|
| native/src/codegen/fusion.rs | the pass: recognition, the template, the copies, scalar transport, dead-code removal, the report; its Rust tests |
| native/src/codegen/nirtext.rs | NIR text from a parsed program (`fused`), with a round-trip test |
| native/src/codegen/roots.rs | `def_use` and `live_at_many` shared with the pass (`block_liveness` factored out of the root analysis) |
| native/src/nir.rs | `cofailed`; `validate_function`, `resummarize`, the header's `call_effects` kept; `Function: Clone` |
| native/src/runtime/coroutine.rs | `rt_co_failed`; `STACK_SWITCHING` |
| native/src/runtime/ops.rs, native/src/codegen/clif.rs | `cofailed`'s effects, helper and codegen |
| native/src/main.rs | fusion in the driver's load path; `fusion` and `fused`; `BOTLISH_NATIVE_COROUTINE_FUSION`, `BOTLISH_NATIVE_COROUTINE_FUSION_LOG` |
| native/native.tcl | `native::fusion`, `native::fusedNir` |
| tests/helpers.tcl | the `cranelift-unfused` backend, `withoutCoroutineFusion` |
| tests/coroutine-fusion.test | this milestone's tests |
| tests/coroutines.test | `coAgree` on five backends; the runtime's resource tests pinned to the general runtime; `cofailed` in the source audit |
| audit/coroutine-fusion/programs/ | the workloads, their procedural baselines, the correctness cases, the fallbacks |
| audit/coroutine-fusion/tools/evidence.tcl, evidence/ | the native evidence |
| audit/coroutine-fusion/tools/mutate.tcl, mutants.txt | mutation testing of the pass |
| audit/coroutines/tools/fuzz.tcl | cranelift-unfused among its default backends |
| bench/coroutine-fusion.tcl | the performance report |
| bench/coroutines.tcl | pinned to the general runtime |
