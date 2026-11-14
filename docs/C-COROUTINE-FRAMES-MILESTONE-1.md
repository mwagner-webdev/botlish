# C-COROUTINE-FRAMES-MILESTONE-1: persistent stackless coroutine frames in freestanding C

Completion report. The C backend (`main.tcl -emit-c`,
C-COMPILE-FREESTANDING-MILESTONE-1.md, C-CONTEXTS-FREESTANDING-MILESTONE-1.md)
now compiles ordinary Botlish coroutines to freestanding C11 state machines.
A function that may yield is a C function over an explicit *frame* -- a
struct holding its resume point, its parameters and exactly the values that
live across one of its suspensions -- and a construction is a fixed-size
object of the constructing function's own frame. Several coroutines suspend
and resume in any order on one ordinary C stack, each with its own state and
the context providers its construction selected. No thread, no stack per
coroutine, no `setjmp`, no allocation, no scheduler and no runtime service.

> A coroutine is a persistent execution state, not a thread. Its frame is a
> C struct the program can see and the target compiler can measure; its
> suspension is a `return`, its resumption a `switch`.

Evidence is marked throughout as **[inspection]** (read in the code),
**[test]** (an assertion of `tests/c-compile.test`, which runs in the
ordinary suite), **[run]** (a compiler, linker or program actually run
during this milestone, with the command), **[emulated]** (run under
qemu-user, an emulator, not hardware) and **[design]** (intended, not
implemented). Nothing here was run on embedded hardware.

## Contents

1. Executive outcome and acceptance status
2. Existing coroutine architecture census
3. HIR representation and existing lowering facts
4. Comparison with the interpreter, the Tcl compiler and Cranelift
5. Supported coroutine subset
6. Frame layout and generated-code examples
7. Suspension and resumption protocol
8. Independent frame execution
9. Coroutine ownership and affine-handle semantics
10. Context retention and lifetime correctness
11. Control flow across suspension
12. Yield, completion and error behavior
13. Nested coroutine execution
14. Allocation and storage model
15. Measured frame sizes and resource accounting
16. Runtime-service manifest integration
17. Freestanding compilation and execution
18. Cross-target compilation and emulated results
19. Cross-backend parity results
20. Unsupported constructs and diagnostics
21. Existing regression and CI results
22. Known limitations
23. Recommended next milestone
24. Files, and what to run when changing this

---

## 1. Executive outcome and acceptance status

**Implemented** -- in `ccompile/ccompile.tcl` only (no file of `hir/`,
`core/`, `surface/`, `compiler/` or `native/` changed):

* a *yielding instance* (an instance of `hir::specialize` whose block may
  yield by `hir::coroutines`' `mayYield`, or a construction's thunk) is a C
  function over its frame: a dispatch on the frame's resume point, its
  parameters read from the frame, and a frame pass (`Persist`) that makes
  every C variable live across one of its suspensions a frame field and
  leaves every other one a C local;
* `yield V`, a call of a yielding function from a yielding function (deep
  yields, any depth), `coroutine {step, first} = f(...)` (`coroutine#create`
  and `#start`), `step(...)` (`#resume`), `std::coroutine::done?`, release
  (nothing to do), handled constructions and resumes;
* a *kind* per construction's thunk: a storage struct holding the handle's
  target (state, cached failure, outward value, message), the context
  pointers the construction's requirement names, and the thunk's frame;
* the handle as a pointer to its storage's target; a *resume function* per
  handle type, which answers a terminal coroutine's cached result or error
  and otherwise runs its next segment (a direct call per kind);
* frame types in `PREFIX.h` and a `coroutine_frames` section in
  `PREFIX.runtime.json` listing every coroutine type, what it holds and
  which fields survive a suspension;
* C UNSUPPORTED for what has no correct translation yet (section 20).

Outside the compiler: the parking-meter example `examples/c-freestanding/
kiosk/` (three coroutines per session, two configurations), the tool
`examples/c-freestanding/frame-sizes.sh` (each coroutine type's size and
alignment on a target, read from a probe object), demonstration 5 of
`demo.sh`, and 30 new tests in `tests/c-compile.test` (91 in all).

| # | acceptance criterion (brief, section 20) | status | evidence |
|---|---|---|---|
| 1 | ordinary coroutines in a meaningful subset compile to freestanding C11 | met | [test] 11 `cc-parity-coroutine-*` corpus programs, `cc-co-kiosk`; section 5 |
| 2 | explicit persistent state machines, no preserved C call stack | met | [test] `cc-co-frames-explicit`, `cc-co-no-stack-switching`; section 6 |
| 3 | several independent instances suspend and resume interleaved | met | [test] `cc-parity-coroutine-interleaved`, `-nested`, `-shared`, `cc-co-kiosk-two-apps`; section 8 |
| 4 | their state stays isolated and correct | met | [test] the same, against interp, compile and cranelift; `cc-co-storage-of-the-constructor` |
| 5 | yield, completion and error semantics preserved | met | [test] `cc-parity-coroutine-errors`, `-mod-zero`, `-principal`, `-endless`; section 12 |
| 6 | affine handle ownership not weakened | met | section 9; [test] `cc-co-storage-of-the-constructor` (no storage ever copied), `cc-co-unsupported-escape` |
| 7 | frames retain the construction's contexts | met | [test] `cc-parity-coroutine-contexts`, `cc-co-contexts-retained`; section 10 |
| 8 | no dangling retained authority | met | section 10's lifetime argument; [test] `cc-co-unsupported-escape` |
| 9 | no heap, thread, scheduler or coroutine runtime service | met | [test] `cc-co-kiosk` (no service), `cc-co-freestanding-objects`, `cc-co-kiosk-freestanding` (no undefined symbol) |
| 10 | frame storage has a measurable, explicit representation | met | frame types in `PREFIX.h`, [test] `cc-co-manifest-frames`, `cc-co-frame-sizes`; [run] section 15 |
| 11 | a nontrivial multi-coroutine example compiles and runs without libc | met | [test] `cc-co-kiosk-freestanding`; [emulated] `cc-co-kiosk-cross` |
| 12 | runtime-service manifests remain accurate | met | section 16; [test] `cc-co-freestanding-objects` (every undefined symbol a listed service) |
| 13 | unsupported cases are diagnostics, not incorrect C | met | [test] `cc-co-unsupported-*`; section 20 |
| 14 | interp, Tcl compiler, native and C parity | met | [test] every corpus program, gcc and clang at -O0 and -O2, against all three |
| 15 | existing compiler and backend regressions pass | met | section 21 |

The implementation does not fuse: every construction is persistent storage
and every resume a call of a resume function, whether or not the coroutine
would be fusible natively (COROUTINE-FUSION-MILESTONE-1.md).

## 2. Existing coroutine architecture census

Established by reading COROUTINES.md, COROUTINE-FUSION-MILESTONE-1.md,
DFA-COROUTINE-MILESTONE-2.md, `hir/coroutines.tcl`, `hir/affine.tcl`,
`core/coroutines.tcl`, `native/lower.tcl`'s coroutine operations,
`hir/specialize.tcl` and the HIR of probe programs [inspection, run]:

1. **Construction.** `coroutine {step, first} = f(a, b)` lowers to a bind of
   each non-literal argument to a hygienic temporary (`coroutine#N#argK`),
   `step = coroutine#create(THUNK)`, `first = coroutine#start(step)`. THUNK
   is a zero-parameter block whose body is the call `f(...)` of the
   temporaries (literals stay in it); it captures the temporaries and `f`.
2. **When the body starts.** Eagerly: `start` follows `create` at once, so a
   fresh coroutine is never observable.
3. **Suspension points.** `yield V` is a call of the internal root native
   `coroutine#yield`; a yield may occur at any depth of the synchronous call
   stack below the root (a *deep* yield): every function that may reach one
   is in `hir::coroutines`' `mayYield`, computed over the exact call graph.
4. **Resumption and yielded values.** `step(m)` is `coroutine#resume(step,
   m)`; the yield evaluates to the message; the segment returns the next
   yield's outward value or the root's result.
5. **Inputs.** One protocol per coroutine: zero messages (`unit`) or one
   named struct type; resolved by the fixed point of `hir::coroutines::
   Solve`, recorded in the handle type `Coroutine{args: [M], return: R,
   errors: [E]}`.
6. **Completion.** The root's return value is the final result; the
   coroutine is completed; `done?` is true.
7. **Errors.** A segment's unhandled declared error crosses the start or
   resume call as an ordinary error; every segment is charged the root's
   declared errors. A run-time error of the language (mod by zero) leaves
   the body the same way; the coroutine is then failed with it.
8. **After completion.** Every later resume returns the cached final result
   (after failure: raises the cached error) and runs no body code. There is
   no exhaustion error.
9. **Ownership.** A handle is affine (`hir::affine`): moved by a binding, an
   argument, a result; never copied; a use after a move is USE-AFTER-MOVE; a
   resume is a use, not a move; released after its last use or on an exit
   leaving its scope (a side table every backend consults; not HIR nodes).
10. **Nested calls.** A yielding call suspends the whole chain; resuming
    continues the innermost frame, whose callers return in turn.
11. **Values live across suspension.** The front end computes none: the Tcl
    runtime keeps the whole Tcl coroutine, the native one the whole stack.
    The C backend decides it on its own generated C (section 6), which is
    representation, not semantics.
12. **Representation of state.** Tcl: one Tcl coroutine per Botlish
    coroutine and a store entry (`core::coroutines::store`). Native: an 8 MiB
    stack per started coroutine, switched by assembly (`bl_co_switch`); the
    collector walks suspended stacks.
13. **Contexts at construction.** A construction is treated as a call of
    its thunk (`hir::contexts::Callee`), so the thunk carries a
    `requiredContexts` like any block; a coroutine runs with the providers
    its construction selected (COROUTINES.md, section 39), and
    CONTEXT-RETAINED-AUTHORITY keeps a coroutine with more authority from
    being resumed inside an inject block.
14. **Fusion.** Natively, a coroutine whose handle never leaves the
    constructing function and whose yielding chain is non-recursive and
    environment-free is compiled into its consumer (fusion.rs); everything
    else uses the stackful runtime.
15. **Persistent storage beyond a call.** Every non-fused native coroutine
    (its own stack); every Tcl coroutine.
16. **Allocation and cleanup.** Native: the stack (pooled) and a 96-byte
    coroutine object; release returns the stack. Tcl: the store entry.
    Release must stay unobservable: it never runs Botlish code, except a
    resource's cleanup (resources: an `opaque resource struct`, which C
    does not compile).

**Classification** [inspection, test]:

| class | constructs |
|---|---|
| A. direct state-machine lowering | yielding functions at any depth (non-recursive chains), `yield`, zero-message and struct protocols, constructions (temporaries and literals), start, resume, `done?`, handled constructions and resumes, cached terminal states, yields inside `if`, loops, folds and handlers, `break`/`continue`/`return` around yields, yielding self tail calls, nested coroutines, coroutines needing contexts and context traits, inject blocks, handles as locals, parameters and results of functions that construct none, moves and joins of handles, release (no cleanup needed) |
| B. state machines needing more storage or ownership support | a handle that leaves the function constructing it (its storage would have to be its caller's: a return-slot convention for frames); a handle inside a struct or List (the aggregate's move and drop discipline in C); a frame owning affine state other than handles (resources and their cleanup); coroutines that outlive one `PREFIX_run` (an application-instance API, section 10) |
| C. needing an external runtime service | none. (Arbitrary-precision Ints use the existing `int.*` services, coroutine or not.) |
| D. unsupported by this backend | a recursive yielding chain (unbounded storage); a yielding function reached by coroutines of different slot representations; abandonment of a suspended coroutine (only with resources); declared recognizers (DFA-COROUTINE-MILESTONE-2.md: their errors carry String payloads, and `dfa#transition` is a native this backend does not compile); everything the C subset excludes anyway (Strings, Lists of unknown length, Float64, closures) |

C and D stay distinct: no coroutine operation became a service symbol.

## 3. HIR representation and existing lowering facts

COROUTINES.md's principal program, as `main.tcl -hir` prints it [run]:

```
e2 block s3 (b2 base:int) ... resume Message coroutine-effect (yields Event, resume Message) ...
    e4 call native(coroutine#yield) : Message
e11 block s4 (b6 base:int) captures (b1 deep) ... coroutine-effect (yields Event, resume Message) ...
    e13 call block(e2) : int
    e17 call native(coroutine#yield) : Message
e25 bind b10 step : Coroutine{args: [Message], return: Event, errors: []}
    e26 call native(coroutine#create) : Coroutine{args: [Message], return: Event, errors: []}
        e28 block s5 () captures (b5 worker) : block(e28)/0 -> Event
            e29 call block(e11) : Event
e32 bind b12 first : Event
    e33 call native(coroutine#start) : Event
e38 call native(coroutine#resume) : Event
```

What the C backend reads, all established before it runs [inspection]:

| fact | from | used for |
|---|---|---|
| `mayYield` (block may yield) | `hir::coroutines::MayYield` | an instance is a state machine (`IsYieldingInstance`) |
| `thunks` (thunk -> root, create, call) | `hir/coroutines.tcl` side table | kinds, comments |
| the handle type's protocol and outward type | `hir::types::CoroutineResume`, `CoroutineOutward` | slot representations (`HandleKey`) |
| instances and their call targets | `hir::specialize` (the thunk's generic instance, its `calls`) | one C function per instance, sub-frames |
| Ranges of parameters and captured temporaries | `hir::range` (it propagates capture Ranges through the thunk into the root's parameters) | `int64_t` where proven |
| the thunk's `requiredContexts` | `hir::contexts::required` | the storage's context pointers |
| handle affinity | `hir::types::IsAffine` | the escape rule, refusals |
| self tail calls | `hir::aot::selfTailCalls` | a yielding loop over one frame |

Releases are the affine analysis's side table; the C backend needs none
(section 9). `coroutine#abandon` appears only in programs with resources.

## 4. Comparison with the interpreter, the Tcl compiler and Cranelift

| | interp, compile (Tcl) | cranelift (native) | C (this milestone) |
|---|---|---|---|
| suspended state | the Tcl coroutine's own frames (NRE) | a private 8 MiB stack per coroutine; or, fused, registers of the consumer | a frame struct per yielding function, nested in the storage |
| suspend | Tcl `yield {yielded V}` | `bl_co_switch` (assembly) | `*yslot = V; fr->resume = K; return PREFIX_SUSPEND;` |
| resume | resume the Tcl coroutine | switch stacks | call the resume function; each yielding function dispatches on its resume point |
| deep yield | free (the whole stack is kept) | free (the whole stack is kept) | each function on the chain records its call site's label; its callee's frame is in its frame's union |
| storage | per-run store dict | stack pool, heap object, GC | an object of the constructing function's frame |
| contexts | the per-run dict | the Vm's context area | pointers in the storage, filled at construction |
| what is persistent | everything | everything | exactly what is read after a suspension (section 6) |
| allocation | Tcl objects | stack mapping (pooled), coroutine object | none |
| recursion of yielding functions | supported | supported (unfused) | C UNSUPPORTED (unbounded storage) |

The C translation is closest to fusion in spirit (state register, inlined
control flow), but differs in the property this milestone needs: a C
coroutine's state lives in storage independent of any consumer's control
flow, so a handle may be passed to functions, resumed from several places
and suspended across arbitrary interleavings with other coroutines.

## 5. Supported coroutine subset

[inspection; test where named]:

* yielding functions with parameters and results of every type the C
  backend represents, calling each other to any depth (a non-recursive
  chain), with any of the backend's statements around their yields;
* zero-message and struct protocols; outward types the backend represents
  (Int, domains, Bool, unit, enums, structs);
* constructions anywhere a function or the program runs: in loops, in
  yielding functions (nested coroutines), with omitted `step` or `first`;
* resumes, `done?`, moves, handles as parameters and results of functions
  that construct none, joins (`if`) of handles;
* coroutines needing contexts and context traits; constructions inside
  inject blocks;
* declared errors in segments, before the first yield, handled at the
  construction, at resumes or inside the coroutine; run-time errors in
  segments; cached terminal states;
* yielding self tail calls (a loop over one frame), endless generators.

`tests/c-compile.test`'s corpus programs `coroutine-principal`,
`-interleaved`, `-control`, `-errors`, `-mod-zero`, `-nested`, `-contexts`,
`-handles`, `-loops`, `-endless`, `-shared` cover each item.

## 6. Frame layout and generated-code examples

### Frames

For COROUTINES.md's principal program (`deep` yields under `worker` under
the coroutine's thunk), `PREFIX.h` declares [run] (`tclsh9.0 main.tcl
-emit-c principal.bot`):

```c
typedef struct principal_coh1 {
    unsigned char state;
    principal_status failure;
    principal_Event value;
    principal_Message message;
} principal_coh1;

/* The frame of deep (i3): what survives its suspensions. */
typedef struct principal_3_deep_frame {
    unsigned char resume;
    int64_t p_base_2;
} principal_3_deep_frame;

/* The frame of worker (i2): what survives its suspensions. */
typedef struct principal_2_worker_frame {
    unsigned char resume;
    int64_t p_base_6;
    union {
        principal_3_deep_frame c1;
    } sub;
} principal_2_worker_frame;

/* The frame of the coroutine of worker, constructed at principal.bot:16:1: what survives its suspensions. */
typedef struct principal_1_coroutine_frame {
    unsigned char resume;
    union {
        principal_2_worker_frame c1;
    } sub;
} principal_1_coroutine_frame;

/* The storage of a coroutine of worker, constructed at principal.bot:16:1: a fresh one is all zero (suspended before its start). */
typedef struct principal_co1 {
    principal_coh1 head;
    principal_1_coroutine_frame body;
} principal_co1;
```

A frame holds, in order: the resume point (the smallest unsigned type
holding them), a thunk's captured values, the parameters (where the caller
writes the arguments), the *persistent* variables, and a union of the frames
of its yielding calls (one is in progress at a time, so they share storage).

### Which values persist

`Persist` decides it on the function's own generated C, which is
representation, not semantics [inspection]:

* a C variable declared at D, whose scope holds a resume label L after D,
  is persistent when a reference to it is reachable from L -- after L in
  its scope, or anywhere in a loop of its scope that encloses L (the next
  iteration) -- and becomes a frame field: its declaration an assignment of
  `fr->NAME`, every use a read of it;
* one whose scope holds a label but no reachable reference is declared at
  the function's top (an assignment where it was), so the dispatch's jump
  skips no declaration and reads no indeterminate value;
* every other declaration stays where it was;
* a construction's storage is always a frame field of a yielding function.

The kiosk's `keypad` (four yields) keeps exactly the three values it reads
after a later yield [run]:

```botlish
fn keypad(resume Key) -> Screen:
    z1 = yield Screen {prompt: Prompt::Zone, zone: 0, minutes: 0}
    z2 = yield Screen {prompt: Prompt::Zone, zone: z1.digit, minutes: 0}
    zone = z1.digit * 10 + z2.digit
    m1 = yield Screen {prompt: Prompt::Minutes, zone: zone, minutes: 0}
    m2 = yield Screen {prompt: Prompt::Minutes, zone: zone, minutes: m1.digit}
    Screen {prompt: Prompt::Done, zone: zone, minutes: m1.digit * 10 + m2.digit}
```

```c
typedef struct kiosk_bench_13_meter_keypad_frame {
    unsigned char resume;
    kiosk_bench_meter_Key v_z1_6;
    int64_t v_zone_10;
    kiosk_bench_meter_Key v_m1_11;
} kiosk_bench_13_meter_keypad_frame;

static kiosk_bench_status kiosk_bench_13_meter_keypad(kiosk_bench_13_meter_keypad_frame *fr, kiosk_bench_meter_Screen *yslot, kiosk_bench_meter_Key *mslot, kiosk_bench_meter_Screen *out)
{
    kiosk_bench_meter_Key msg1;
    kiosk_bench_meter_Key msg2;
    kiosk_bench_meter_Key v_z2_7;
    kiosk_bench_meter_Key msg3;
    switch (fr->resume) {
    case 1:
        goto resume_1;
    ...
    default:
        break;
    }
    *yslot = ((kiosk_bench_meter_Screen){.f_prompt = kiosk_bench_meter_Prompt_Zone, .f_zone = INT64_C(0), .f_minutes = INT64_C(0)});
    fr->resume = 1;
    return kiosk_bench_SUSPEND;
resume_1:;
    msg1 = *mslot;
    fr->v_z1_6 = msg1;
    *yslot = ((kiosk_bench_meter_Screen){.f_prompt = kiosk_bench_meter_Prompt_Zone, .f_zone = (fr->v_z1_6).f_digit, .f_minutes = INT64_C(0)});
    fr->resume = 2;
    return kiosk_bench_SUSPEND;
resume_2:;
    msg2 = *mslot;
    v_z2_7 = msg2;
    fr->v_zone_10 = (((fr->v_z1_6).f_digit * INT64_C(10)) + (v_z2_7).f_digit);
    ...
resume_4:;
    kiosk_bench_meter_Key msg4 = *mslot;
    kiosk_bench_meter_Key v_m2_12 = msg4;
    *out = ((kiosk_bench_meter_Screen){.f_prompt = kiosk_bench_meter_Prompt_Done, .f_zone = fr->v_zone_10, .f_minutes = (((fr->v_m1_11).f_digit * INT64_C(10)) + (v_m2_12).f_digit)});
    return kiosk_bench_OK;
}
```

`z2` and `m2` stay C locals (dead before any later suspension); the messages
are copied out of the slot (a later yield replaces it). A counted fold
suspended in its body keeps its counter, its bound and its intermediate and
none of its dead temporaries [run] (a generator `fold i from start to limit
with intermediate acc 0: yield i; acc + i`: frame `resume, p_start,
p_limit, hi, acc, i`); [test] `cc-co-frames-explicit` pins the rule on a
straight-line program (its frame is exactly `resume`, the parameter and the
one value read after the first yield).

### A yielding call

`worker` calls `deep`, which may suspend [run]:

```c
static principal_status principal_2_worker(principal_2_worker_frame *fr, principal_Event *yslot, principal_Message *mslot, principal_Event *out)
{
    botlish_rt_v1_int r1;
    principal_status st2;
    botlish_rt_v1_int v_x_7;
    switch (fr->resume) {
    case 1:
        goto resume_1;
    case 2:
        goto resume_2;
    default:
        break;
    }
    fr->sub.c1.p_base_2 = fr->p_base_6;
    fr->sub.c1.resume = 0;
resume_1:;
    st2 = principal_3_deep(&fr->sub.c1, yslot, mslot, &r1);
    if (st2 == principal_SUSPEND) {
        fr->resume = 1;
        return principal_SUSPEND;
    }
    if (st2 != principal_OK) {
        return st2;
    }
    v_x_7 = r1;
    *yslot = ((principal_Event){.f_value = v_x_7});
    fr->resume = 2;
    return principal_SUSPEND;
resume_2:;
    principal_Message msg3 = *mslot;
    principal_Message v_message_8 = msg3;
    *out = ((principal_Event){.f_value = (v_message_8).f_value});
    return principal_OK;
}
```

The arguments are written into the callee's frame before the label, so a
resumed call does not evaluate them again; the call is made again after the
label, and the callee continues from its own resume point.

## 7. Suspension and resumption protocol

[inspection; test] for every function `F` that may yield:

* `static PREFIX_status F(F_frame *fr, CONTEXT..., OUT *yslot, [MSG
  *mslot,] RESULT *out)`: the frame, the contexts of `F`'s requirement (as
  every function takes them), the coroutine's outward slot, its message
  slot for a struct protocol, and the result.
* It returns `PREFIX_OK` (completed: `*out` written), an error status, or
  the internal `PREFIX_SUSPEND` (-1, defined in `PREFIX.c`): suspended, its
  resume point recorded in `fr->resume`. Every caller tests
  `PREFIX_SUSPEND` before anything else, so a suspension never reaches a
  handler's dispatch, never becomes a failure and never leaves the resume
  function.
* A kind's segment function `PREFIX_coK_step(PREFIX_coK *co)` calls its
  thunk's function with `&co->body`, the stored context pointers and the
  slots of `co->head`, and on completion stores the result (in the outward
  representation) in `co->head.value`.
* A handle type's resume function `PREFIX_cohH_resume(PREFIX_cohH *co, OUT
  *out)`: a completed coroutine answers `co->value` again, a failed one
  `co->failure` again, running nothing; otherwise it runs the next segment
  (one direct call, or a `switch` on `co->kind` when several kinds share
  the handle type) and records `PREFIX_CO_COMPLETED` or `PREFIX_CO_FAILED`
  with the status.
* `start` is the first resume (a fresh coroutine is zero: state
  `PREFIX_CO_SUSPENDED`, every resume point 0); `resume(h, m)` first stores
  the message in `h->message`.

```c
static principal_status principal_coh1_resume(principal_coh1 *co, principal_Event *out)
{
    principal_status st;
    if (co->state == principal_CO_COMPLETED) {
        *out = co->value;
        return principal_OK;
    }
    if (co->state == principal_CO_FAILED) {
        return co->failure;
    }
    st = principal_co1_step((principal_co1 *)co);
    if (st == principal_SUSPEND) {
        *out = co->value;
        return principal_OK;
    }
    if (st != principal_OK) {
        co->state = principal_CO_FAILED;
        co->failure = st;
        return st;
    }
    co->state = principal_CO_COMPLETED;
    *out = co->value;
    return principal_OK;
}
```

The conversion `(principal_co1 *)co` is from a pointer to a struct's first
member back to the struct (C11 6.7.2.1p15): the handle points to its
storage's `head`.

C constraints observed [inspection, test]: every label is followed by a
null statement (`resume_K:;`, so a declaration may follow it); no jump
enters the scope of a variable that is read after it without being assigned
(`Persist`); no variable-length array; no compiler extension; nothing
depends on evaluation order; every program compiles under the strict flags
(`-std=c11 -pedantic-errors -Wall -Wextra -Werror -Wshadow
-Wstrict-prototypes -Wmissing-prototypes -Wconversion -Wsign-conversion
-Wcast-qual -Wundef`) with gcc and clang at -O0 and -O2.

## 8. Independent frame execution

[test] `cc-parity-coroutine-interleaved` runs, against interp, compile and
cranelift, three coroutines -- two of one root (`counter(10, 1)`,
`counter(20, 5)`) and one of another -- in the order

```
construct A, construct B, construct C
B B A C A C          (each at a different point)
B -> completes       A -> completes       B -> cached result
done?(A), done?(B), done?(C)
```

giving `[10, 11, 12, 10000, 20, 25, 30, 20000, 20000, 7, 57, 57, [true,
true, true]]` on every backend and both C compilers at both levels. A single
state variable per root (or per kind) would mix A and B up: each
construction is its own storage object, and the two `counter` coroutines
run the same C functions over different frames.

The structural guarantees [test] `cc-co-storage-of-the-constructor`:

* the generated C of the coroutine programs declares no writable object of
  static storage duration (only the `const` status tables);
* every construction zeroes its own storage object (`coN =
  (PREFIX_coK){0};`), one per construction site in the source;
* no storage object is ever assigned from anything else: a handle is copied,
  its storage never.

`cc-parity-coroutine-nested` (two instances of a coroutine that drives its
own inner coroutine, interleaved) and `cc-parity-coroutine-shared` (a helper
serving two roots, a handle passed into another coroutine) add instances
whose frames nest. The kiosk runs three coroutines of different kinds per
session, and `cc-co-kiosk-two-apps` runs two configurations of it, A B B A A
B, in one executable [test].

## 9. Coroutine ownership and affine-handle semantics

The affine analysis is the front end's and stays the authority
(`hir/affine.tcl`): one owner per handle, use after move rejected, resumes
uses, releases placed at last uses and exits. What C adds [inspection,
test]:

* **The handle is a pointer, the storage never moves.** A Botlish move
  (`other = step`, an argument, a result) copies the pointer; the front end
  has made the source dead. No generated code copies a storage object
  (`cc-co-storage-of-the-constructor` counts the assignments), so a copy of
  a handle can never duplicate an execution: there is one frame per
  coroutine, wherever its pointers go.
* **Release needs no code.** No frame of the supported subset owns anything
  to clean up: its fields are values (Ints, enums, structs of them) and
  pointers (handles, contexts) that own nothing; resources and other affine
  state are C UNSUPPORTED. A released coroutine's storage is simply never
  reached again (the affine analysis proves it). Early abandonment (a handle
  dropped while its coroutine is suspended) is the same: nothing runs, as
  on every backend (COROUTINES.md, "Release at the last use": a release
  never runs Botlish code).
* **No handle outlives its storage.** Storage is an object of the
  constructing function's frame (section 14). Rule: a function that
  constructs a coroutine may not have an affine result type (C UNSUPPORTED
  otherwise, `cc-co-unsupported-escape`). Proof that no handle survives its
  storage: a handle is a value of an affine type, and affinity is a
  property of types (a value of an unrestricted type holds no handle; erasure
  to `any` and captures are rejected by the front end). The only ways a value
  leaves a function are its result, its yields' outward values, resume
  messages, error payloads, contexts and module bindings. The front end
  already makes outward values, messages and cached errors' payloads
  unrestricted (`hir::coroutines::AffineProtocol`), module bindings cannot
  hold handles, and C rejects affine context state and error payloads; the
  rule closes the result. So every handle stays within the dynamic extent
  of the function that constructed it -- passed down to callees and back
  up to that function at most.
* **Invalid operations.** A use after move or a resume of a released handle
  are compile-time errors of the front end (no run-time check exists or is
  needed); a resume of a completed or failed coroutine is valid and answers
  its cached outcome (`cc-parity-coroutine-interleaved`, `-errors`). A
  coroutine resuming itself is impossible in the subset (its handle cannot
  reach its own body: arguments are evaluated before it exists, messages
  are unrestricted, captures are rejected), so the C has no RUNNING state.

## 10. Context retention and lifetime correctness

**Retention.** A kind's storage holds one `T *` per context in the thunk's
`requiredContexts` -- exactly what the construction's requirement names --
filled in by the construction from the constructing function's own pointers
(`ContextArgs`, as every call passes them). Each segment passes them from
the storage down the yielding chain as ordinary parameters; the frames hold
none, the resume function takes none [test] `cc-co-contexts-retained`:

```c
typedef struct kiosk_bench_co3 {           /* payment */
    kiosk_bench_coh3 head;
    kiosk_bench_bench_BenchTerminal *ctx_bench_BenchTerminal;
    kiosk_bench_bench_SimClock *ctx_bench_SimClock;
    kiosk_bench_6_coroutine_frame body;
} kiosk_bench_co3;
...
    co19 = (kiosk_bench_co3){0};
    co19.ctx_bench_BenchTerminal = ctx_bench_BenchTerminal;
    co19.ctx_bench_SimClock = ctx_bench_SimClock;
    co19.body.c_coroutine_3365_arg1_51 = (r24).f_minutes;
```

The payment coroutine needs the terminal and, through the terminal's
`stamp`, the clock; the keypad needs neither and holds none. Context traits
are resolved before C (the trait plan's clones call the selected
implementation directly: `meter::payment<devices::Payment=bench::BenchTerminal>`).
A coroutine constructed inside `inject context Fee:` holds only `Fee`
(`cc-parity-coroutine-contexts`); resuming a coroutine with more authority
inside an inject block is CONTEXT-RETAINED-AUTHORITY, before C. Nothing is
resolved at a resume, nothing comes from the resumer, no registry exists.

**Lifetime.** The installed contexts are objects of `PREFIX_program`'s frame
(C-CONTEXTS-FREESTANDING-MILESTONE-1.md), each from its `with context`
statement to the end of the run. A pointer to one reaches a storage object
only at a construction that requires it, which verification places after
its installation. Every storage object lives in the frame of a function
running inside `PREFIX_program` (or, nested, in the frame of a coroutine
whose storage does), and no handle outlives its storage (section 9). So no
retained context pointer is usable after the installed object's lifetime
ends: when `PREFIX_program` returns, every coroutine of the run is
unreachable -- the language's own rule that a coroutine does not outlive its
run, now true of its C storage too.

**Externally driven execution (the brief's shape B).** Not supported, and
recorded rather than worked around [design]: `PREFIX_run` runs a whole entry
program, and all of its coroutines live and die inside that call. An
embedding that wants to construct an application once and deliver events
to it in later calls needs (1) a way to keep an entry program's installed
contexts and its coroutines' storage in embedding-owned storage between
calls, and (2) entry points that resume the application's coroutines. The
frames themselves already allow it: they are position-independent structs
reached only through pointers, with no reference to the C stack. What is
missing is a language-level notion of an application instance whose top
level suspends instead of completing (an entry program that yields, or an
event-driven entry form) -- a language question first, not a C one, like
C-CONTEXTS-FREESTANDING-MILESTONE-1.md's "an embedding cannot supply a
context". No global application singleton was introduced.

## 11. Control flow across suspension

[test] `cc-parity-coroutine-control`:

```botlish
fn walker(limit: Small, resume Msg):
    fold i from 0 to limit with intermediate acc 0:
        if i == 1:
            continue
        m = yield acc + i
        r = risky(m.v):
            on Stop:
                m2 = yield 999
                m2.v
        if r > 50:
            break
        if r == 7:
            return 777
        acc + r
```

A yield inside a fold's body, after a `continue`, before a `break` and a
`return`, and inside an `on Stop:` handler: the counter, bound and
intermediate persist; after the handler's own resumption a failure would
still reach the same dispatch (its `hst` variable persists). Also
[test]: a yield inside a counted loop (`-endless`, `-interleaved`), an
`if` (`-errors`), a loop constructing a coroutine per iteration
(`-loops`: the storage reused per iteration), a yielding fold constructing
and driving a coroutine per iteration, and a yielding self tail call:

```botlish
fn count(n: int, acc: int):
    if n == 0:
        return acc
    yield acc
    count(n - 1, acc + n)
```

compiles to `goto top` over the same frame: no recursion, no growth.
Recursion that is not a tail call is section 20's.

## 12. Yield, completion and error behavior

[test] against interp, compile and cranelift:

| behavior | program | C |
|---|---|---|
| first segment at construction; `first` its outward value | all | `start` is the first resume |
| a return before any yield completes the construction | `-endless` (`squares(3)` with `first` only) | the first resume completes |
| the final result answered again, nothing run | `-principal` (`again`), `-interleaved` (`b4`) | `state == COMPLETED` |
| a declared error after a yield crosses that resume, handled there | `-errors` (`run(9)`) | the segment's status, through the resume function, to the resume's handlers |
| the same error on every later resume, nothing run | `-errors` (`b`, `c`) | `state == FAILED`, `failure` |
| a failure before the first yield crosses the construction | `-errors` (`startup(4)`) | the start's status, the construction's handlers |
| a run-time error in a segment ends the run with its code | `-mod-zero` | `error: mod: division by zero (CORE SEMANTIC ARITHMETIC)` |
| a failure handled inside the coroutine never reaches the resume | `-control` (`on Stop:`) | the handler's dispatch inside the frame |
| `done?` true exactly when completed or failed | `-interleaved`, `-endless`, `-handles` | `state != SUSPENDED` |
| an endless generator | `-endless` | never completes; `done?` false |

A suspended coroutine is never a failed one (`PREFIX_SUSPEND` is tested
first everywhere and never stored as a failure); a failed coroutine never
completes normally; nothing terminates the process.

## 13. Nested coroutine execution

[test] `cc-parity-coroutine-nested`:

```botlish
fn outer(base: Small):
    coroutine {step: s, first: a} = inner(base)
    yield a
    b = s()
    yield b
    c = s()
    c + 100
```

`outer`'s frame holds the inner coroutine's storage and its handle, both
live across `outer`'s own yields [run]:

```c
    fr->co1 = (nested_co2){0};
    fr->co1.head.kind = 1;
    fr->co1.body.c_coroutine_127_arg1_7 = v_coroutine_127_arg1_7;
    fr->v_s_9 = (&fr->co1.head);
    st3 = nested_coh1_resume(fr->v_s_9, &r2);
```

Two `outer` coroutines interleaved each drive their own `inner`. A
yielding chain of any depth needs no bound of its own: each function's frame
holds its callee's in a union, so the depth is the call graph's, fixed when
the program is compiled. A coroutine handed another's handle at
construction resumes it from its segments (`-shared`); handles passed to
ordinary functions that resume them, return them or choose between them
(`-handles`) compile too.

## 14. Allocation and storage model

* **No allocation after entry, ever.** Every coroutine's storage is an
  object of the constructing function's frame: a C local declared at the
  function's top (so a handle may outlive the C block of its
  construction), or, when that function may yield, a field of its own
  persistent frame. A construction zeroes it with `(PREFIX_coK){0}` -- a
  compound literal of the universal zero initializer, which needs no data
  object and passes both compilers' `-Wmissing-braces` and
  `-Wmissing-field-initializers` [run] -- and fills in its captured values
  and context pointers. Zeroing also means no field of a frame is ever
  indeterminate, whatever a C optimizer inlines.
* **A construction site is one slot.** A construction executed again
  reuses its site's storage (a loop's next iteration, a function's next
  activation through its own frame). The previous coroutine of that site
  is unreachable by then: a handle survives an iteration only through state
  carried across iterations, and the C subset has none that may hold one --
  fold intermediates may not be affine (AFFINE-FOLD-UNSUPPORTED), collected
  Lists and mutable collections are not compiled, a `break` value is not
  compiled. So the site's capacity, one, is never exceeded, and no
  capacity check or allocation failure exists [test] `-loops`.
* **Recursion of the constructing function** gives each activation its own
  storage (it is in that activation's frame).
* **Storage that is not bounded** is refused: a yielding chain that
  recurses, or a yielding function that constructs a coroutine of itself,
  would need a frame that holds itself (section 20).
* **What is not in a frame:** the C stack of a segment while it runs (the
  resume function, the segment function, the thunk, the chain's functions
  and the ordinary functions they call: freed when the segment suspends),
  the runtime-service provider's numbers (an unbounded Int is a
  `botlish_rt_v1_int` handle to provider storage), and the installed
  contexts (the run's frame).

The design keeps the later allocation strategies the brief lists open
[design]: a storage type is a plain struct, so a fixed pool of
`PREFIX_coK` objects, per-actor storage or an arena would hold it unchanged;
the frame's lifetime is tied to its constructing function's frame, never to
a thread or a thread-local scratch area.

## 15. Measured frame sizes and resource accounting

Structural facts [inspection, test]: the kiosk's session constructs three
coroutines whose storage is live at once (`co1` keypad, `co2`
housekeeping, `co3` payment, all objects of `meter::session`'s C frame);
`day()` runs two sessions one after the other, so at most three storage
objects exist at any time; no memory is allocated after entry; the frames
hold, besides resume points and parameters, `keypad`'s `z1`, `zone`, `m1`,
`housekeeping`'s loop counter and bound, `payment`'s `price` (the
manifest's `suspension_values`).

Measurements [run] (`examples/c-freestanding/frame-sizes.sh DIR kiosk_bench
TARGET...`: `sizeof`/`_Alignof` of each manifest type as clang 18.1.3 (gcc
13.3.0 for the host) lays it out, read from a probe object; nothing runs),
bytes/alignment:

| type | x86-64 host | aarch64 | riscv64 | thumbv7m | thumbv6m | riscv32 | i386 | msp430 | avr |
|---|---|---|---|---|---|---|---|---|---|
| `coh1` (keypad's target) | 40/8 | 40/8 | 40/8 | 40/8 | 40/8 | 40/8 | 36/4 | 30/2 | 29/1 |
| `coh2` (housekeeping's) | 24/8 | 24/8 | 24/8 | 24/8 | 24/8 | 24/8 | 24/4 | 20/2 | 19/1 |
| `coh3` (payment's) | 32/8 | 32/8 | 32/8 | 32/8 | 32/8 | 32/8 | 28/4 | 22/2 | 21/1 |
| `13_meter_keypad_frame` | 32/8 | 32/8 | 32/8 | 32/8 | 32/8 | 32/8 | 28/4 | 26/2 | 25/1 |
| `4_coroutine_frame` (keypad's thunk) | 40/8 | 40/8 | 40/8 | 40/8 | 40/8 | 40/8 | 32/4 | 28/2 | 26/1 |
| `co1` (keypad's storage) | 80/8 | 80/8 | 80/8 | 80/8 | 80/8 | 80/8 | 68/4 | 58/2 | 55/1 |
| `12_meter_housekeeping_frame` | 24/8 | 24/8 | 24/8 | 24/8 | 24/8 | 24/8 | 20/4 | 18/2 | 17/1 |
| `5_coroutine_frame` | 32/8 | 32/8 | 32/8 | 32/8 | 32/8 | 32/8 | 24/4 | 20/2 | 18/1 |
| `co2` (housekeeping's storage) | 64/8 | 64/8 | 64/8 | 64/8 | 64/8 | 64/8 | 52/4 | 42/2 | 39/1 |
| `7_meter_payment_frame` | 24/8 | 24/8 | 24/8 | 24/8 | 24/8 | 24/8 | 20/4 | 18/2 | 17/1 |
| `6_coroutine_frame` | 40/8 | 40/8 | 40/8 | 40/8 | 40/8 | 40/8 | 32/4 | 28/2 | 26/1 |
| `co3` (payment's storage) | 88/8 | 88/8 | 88/8 | 80/8 | 80/8 | 80/8 | 68/4 | 54/2 | 51/1 |

(Type names shortened: each is prefixed `kiosk_bench_`, and the
housekeeping and payment frames carry their trait clones' names.) So a
session's three coroutines take 232 bytes on a 64-bit target, 224 on
32-bit ARM and RISC-V, 188 on i386, 154 on MSP430 and 145 on AVR. These are one compiler's layouts for one
target, not properties of the program; C fixes no struct layout, and the
manifest names the types so that an embedding asks its own compiler.

Transient C stack [run] (`gcc -fstack-usage`, x86-64, the bench
configuration): at -O0 the largest frames are `meter::session` 1776 bytes
(its three storage objects and every temporary), `meter::payment` 208,
`keypad` 136, each segment function 64, each resume function 48; at -O2 gcc
inlines everything into `meter::session` (672 bytes) and the resume
functions take 8. A segment's stack is freed when it suspends: what
persists is only the storage.

## 16. Runtime-service manifest integration

The manifest's format version is unchanged; a program with coroutines gets
one more member, `coroutine_frames` (none in a coroutine-free program,
whose manifest is byte-identical to before) [test] `cc-co-manifest-frames`:

```json
  "coroutine_frames": [
    {"type": "kiosk_bench_coh1", "role": "handle", "holds": []},
    ...
    {"type": "kiosk_bench_13_meter_keypad_frame", "role": "frame", "of": "meter::keypad (i13)", "holds": [], "suspension_values": ["v_z1_6", "v_zone_10", "v_m1_11"]},
    {"type": "kiosk_bench_4_coroutine_frame", "role": "frame", "of": "the coroutine of meter::keypad, constructed at meter.bot:94:5", "holds": ["kiosk_bench_13_meter_keypad_frame"], "suspension_values": []},
    {"type": "kiosk_bench_co1", "role": "storage", "of": "the storage of a coroutine of meter::keypad, constructed at meter.bot:94:5", "holds": ["kiosk_bench_4_coroutine_frame", "kiosk_bench_coh1"]},
    ...
  ]
```

Suspension adds no service: no `coroutine.*` service exists. The kiosk
needs none at all [test] `cc-co-kiosk`; the corpus programs whose values are
plain `int` need what any such program needs -- `int.to_decimal` to display
an Int that is not a domain, `int.add`/`int.mul` where the range analysis
proves no bound -- and their objects reference exactly those
[test] `cc-co-freestanding-objects` (every undefined symbol of every
coroutine program's freestanding object, gcc and clang at -O2, is a service
its manifest lists or one of the four memory functions the C toolchain may
call). Measured lists [run]: `-principal`, `-interleaved`, `-contexts`,
`-endless`: `int.to_decimal`; `-control`, `-loops`, `-mod-zero`, `-nested`,
`-shared`: `int.add`, `int.to_decimal`; `-errors`, `-handles`: `int.add`,
`int.mul`, `int.to_decimal`.

## 17. Freestanding compilation and execution

[test, run] with gcc 13.3.0, clang 18.1.3, GNU ld 2.42, ld.lld 18.1.3:

* every coroutine program compiles under the strict flags with gcc and
  clang at -O0 and -O2 (the parity tests build each four ways);
* its generated C includes `stdbool.h`, `stddef.h`, `stdint.h` and nothing
  else, and contains no `setjmp`, `longjmp`, `ucontext`, thread, allocation,
  `__builtin`, `asm` or `__attribute__` [test] `cc-co-no-stack-switching`;
* the kiosk's objects reference no symbol at all, freestanding at -O2,
  under both compilers [test] `cc-co-freestanding-objects`;
* both kiosk configurations link into one static executable with no C
  library (`-ffreestanding -nostdlib -static`, `harness/linux_start.c`) whose
  `nm -u` is empty, and it prints each run's value, interleaved, and
  `repeated runs: identical` [test] `cc-co-kiosk-freestanding`; [run]
  `examples/c-freestanding/demo.sh` section 5:

```
a static executable with no C library: ELF 64-bit LSB executable, x86-64, statically linked
its undefined symbols: []
kiosk_bench run 1: value: meter::Day {morning: meter::Summary {zone: 42, minutes: 30, price: 60, outcome: meter::Stage::Paid, again: meter::Stage::Paid, paid_at: 30600, beats: 4, keypad_done: true, repeat: meter::Prompt::Done}, evening: meter::Summary {zone: 17, minutes: 99, price: 198, outcome: meter::Stage::Declined, again: meter::Stage::Declined, paid_at: 30600, beats: 4, keypad_done: true, repeat: meter::Prompt::Done}}
kiosk_field run 1: value: meter::Day {... evening: meter::Summary {..., outcome: meter::Stage::Paid, again: meter::Stage::Paid, paid_at: 52440, ...}}
...
repeated runs: identical
```

### The demonstration application

`examples/c-freestanding/kiosk/`: a parking meter. `devices.bot` declares
the hardware it needs as context traits (`Clock`, `Payment` with the error
`Declined`); `bench.bot` implements them on a test bench (a simulated clock,
a terminal declining anything above 100), `field.bot` in the street (a
real-time clock's hour and minute registers, a terminal accepting 500);
`meter.bot` has the three activities and the session:

| activity | coroutine | state across its suspensions |
|---|---|---|
| input interaction | `keypad(resume Key) -> Screen`: resumed with one key press each, yields the screen, completes with the zone and minutes | the digits read so far |
| payment | `payment(minutes, context pay: devices::Payment) -> Status errors Declined`: yields its stages, then asks the terminal; Declined fails the coroutine | the price |
| housekeeping | `housekeeping(context clock: devices::Clock) -> Beat`: a heartbeat stamped by the clock | the beat counter |

`session` plays a scripted sequence of events by resuming them in a
deliberately interleaved order (keypad, beat, keypad, keypad, beat,
keypad, payment construction, payment, beat, payment, payment again, keypad
again); there is no event loop. It shows persistent state (the keypad's
digits), three independent frames, interleaved resumption, context
retention (the payment's terminal and clock, the housekeeping's clock), a
successful completion, an exceptional one (the bench's evening payment of
198 is declined, and the next resume answers Declined again), no heap and
no runtime service, and deterministic output. `kiosk_bench.bot` and
`kiosk_field.bot` install the two configurations; their `# expect:` lines
are the values every backend gives [test] `cc-co-kiosk`. The example
compiles under `-warnings error` [test] `cc-co-kiosk-warning-clean`.

## 18. Cross-target compilation and emulated results

**Compiled** [test] `cc-co-cross-targets`: the kiosk's two configurations
and the corpus programs `-principal`, `-interleaved`, `-nested`, `-contexts`
compile with clang 18.1.3 under the strict flags at -O2 for
thumbv6m-none-eabi (Cortex-M0), thumbv7m-none-eabi (Cortex-M3),
riscv32-unknown-elf, riscv64-unknown-elf, msp430-none-elf (16-bit `int` and
pointers), avr `-mmcu=atmega328p` (8-bit), mips-unknown-elf,
powerpc-unknown-elf (both big endian) and aarch64-none-elf; no object
references a symbol of its own program or a Botlish symbol its manifest does
not list. (At -O0, clang 18's AVR backend reports "ran out of registers
during register allocation" on the 64-bit arithmetic of the kiosk: a limit
of that compiler, which is why the test, like `cc-ctx-cross-targets`,
compiles at -O2.)

**Executed** [emulated] `cc-co-cross-execution`: the eleven coroutine corpus
programs, each linked with no C library (`linux_start.c`) and the reference
Int provider by clang/lld, run under qemu-user 8.2.2 on AArch64, RISC-V 64,
s390x (big endian) and ARMv7 (with the cross libgcc 13), and natively as
i386: 55 runs, every line equal to interp's and compile's.
`cc-co-kiosk-cross`: the two-configuration kiosk executable on the same
five targets, every run's line the reference's and `repeated runs:
identical`. Emulation and a 32-bit mode of an x86-64 machine, not hardware;
no bare-metal image was linked.

## 19. Cross-backend parity results

`tests/c-compile.test`, [test]: each of the eleven coroutine corpus
programs compiled to C once, built by gcc and by clang at -O0 and at -O2
under the strict flags, linked with the reference provider, run, and its
line required equal to the line interp, compile and cranelift (the native
backend built from this checkout) give the same HIR -- which must agree
among themselves:

| program | value |
|---|---|
| `coroutine-principal` | `[Event {value: 10}, Event {value: 20}, Event {value: 30}, Event {value: 30}]` |
| `coroutine-interleaved` | `[10, 11, 12, 10000, 20, 25, 30, 20000, 20000, 7, 57, 57, [true, true, true]]` |
| `coroutine-control` | `[0, 4, 999, 9, 15, 11, 11]` |
| `coroutine-errors` | `[3004055, 9102300, 0, 10946]` |
| `coroutine-mod-zero` | `error: mod: division by zero (CORE SEMANTIC ARITHMETIC)` |
| `coroutine-nested` | `[10, 20, 11, 21, 112, 122, 122, 112, 112]` |
| `coroutine-contexts` | `[4, 7, 3, 3, 309]` |
| `coroutine-handles` | `30026016` |
| `coroutine-loops` | `[60, 0, 3, 6, 9, 0, 4, 7, 9, 10, 10]` |
| `coroutine-endless` | `[5, 5, 5, 0, 1, 4, -1, -1, false]` |
| `coroutine-shared` | `[1, 2, 3, 1, 11, 52, 10, 30]` |

Plus the kiosk's two configurations (`cc-co-kiosk`: four C builds each
against the three backends and the `# expect:` line). Counting C builds,
that is 52 C executions compared with 39 reference runs per test run, all
equal.

## 20. Unsupported constructs and diagnostics

Each is C UNSUPPORTED at the construct, through `core::raiseDiagnostics`
like every other: never a service symbol, never an internal error [test]:

| construct | located at | message (after "the C backend cannot compile") |
|---|---|---|
| a yielding call that recurses, directly or through other yielding functions (not a tail call) | the call closing the cycle | "a coroutine whose suspended calls recurse (a function that may yield, called or constructed again from its own suspended call chain, needs a frame that holds itself: unbounded storage)" (`cc-co-unsupported-recursion`) |
| a yielding function constructing a coroutine of itself | the construction closing the cycle | the same |
| a function that constructs a coroutine and may return a handle | its first construction | "a function that may return a handle of a coroutine it constructs (the coroutine's frame is storage of the function's own frame, which ends when it returns)" (`cc-co-unsupported-escape`) |
| a handle inside a struct or a List | the aggregate | "a coroutine handle held in a struct or a List (TYPE)" (`cc-co-unsupported-aggregate`) |
| a yielding helper reached by coroutines whose outward values or messages have different C representations | the call reaching it second | "a function that may yield reached by coroutines whose outward values or messages have different C representations" (`cc-co-unsupported-mixed-slots`) |
| the abandonment of a suspended coroutine | the operation | "the abandonment of a suspended coroutine (resources)" (only with resources, which are refused first) |
| a handle whose type is not known statically; a protocol `any` | the value | as worded |

The recursion check works on the frame types: every frame and storage type
records what it holds by value with the expression that made it so, and a
depth-first search finds a type that would hold itself (`FrameCycles`);
C would reject such a struct as incomplete. A program the front end
rejects never reaches the backend: a program value holding a handle is the
front end's AFFINE-ERASURE-UNSUPPORTED, an affine outward value or message
its COROUTINE-CONTRACT. Compilerpedia's `backend.c` (a COROUTINES section)
and `error.c-unsupported` state the subset and these refusals
(`tools/compilerpedia.tcl check`: 0 problems).

## 21. Existing regression and CI results

### main's CI when the branch was made

[run] Read before branching, as AGENTS.md asks: main's head was fb194f72
(documentation only: it started no test workflow), and the latest runs of
the four test workflows, at b0ae98fe, were **red on every host, on exactly
two tests**, `argv.test`'s `argv-focused-valid-fuzz` and
`native-tcl-unicode.test`'s `native-tcl-unicode-lowercase-all-scalars`
(native `std::str::lowercase` disagrees with the Tcl reference for scalars
of planes 0 and 1 -- probably the runners' new rustc's Unicode tables
against Tcl 9.0.1's Unicode 16; b0ae98fe's own message records main red with
the same two since 14937461). Every failing job of tests.yml,
tests-arm64.yml, windows-x86_64.yml and macos-arm64.yml failed on one or
both of them and on nothing else; no job failed for infrastructure.
Neither test involves the C backend or anything this branch changes.

### Local runs

[run] on this branch, Linux x86-64, Tcl 9.0.1, gcc 13.3.0, clang 18.1.3,
ld.lld 18.1.3, qemu-user 8.2.2, the cross libgcc 13 packages, the native
backend built from this checkout (rustc 1.97.0):

* `tests/c-compile.test`: 91 tests, 91 passed, none skipped -- the 61 of
  the earlier milestones (61 of 61 before the change on the same machine,
  `cc-ctx-unsupported-around-contexts` excepted: it asserted that a
  coroutine needing a context is C UNSUPPORTED, and now keeps only its
  Linux-I/O half; the coroutine compiles, `cc-parity-coroutine-contexts`)
  and the 30 new ones.
* Coroutine-free programs are unaffected: the generated files of the
  example programs (`programs/`, `contexts/`, nine `examples/surface`
  programs: 49 files) are byte-identical to main's backend's.
* `tests/coroutines.test`: 81 of 81. `tests/main-cli.test`: 72 of 72.
  `tests/numeric-looking-names.test`: 5 of 5 (its source check reads
  `ccompile/`). `tests/golden.test`: 9 of 9. `tests/compilerpedia.test`: 43
  of 43; `tools/compilerpedia.tcl check`: 1300 topics, 778 examples, 0
  problems. `tools/mutant-catalogs.tcl`: 108 catalogs, 3717 mutants, 0
  problems.
* `audit/golden/migration/merge.tcl`: the 30 new tests' census rows merge
  into the manifest (13844 rows). Its `-check 1` reports nine problems --
  census rows of `android-target.test` and `c-bindgen.test` tests absent
  from `tcl-names.txt` -- identically on main before this change (checked
  on a worktree of the branch's base): not this branch's.
* `examples/c-freestanding/demo.sh`: all five demonstrations.

### CI on the branch

See section 25 (written once the branch's runs have finished).

## 22. Known limitations

* **Recursive yielding chains** are refused (section 20): a coroutine whose
  suspended call chain may be unboundedly deep needs storage no fixed frame
  has. A tail-recursive one compiles as a loop.
* **Handles stay inside their constructing function's extent.** A function
  cannot hand a coroutine it constructs to its caller; it may receive, use,
  move and return handles it was given. A return-slot convention (storage
  passed down by the caller) would lift this for a statically known chain
  [design].
* **No handle inside a struct or a List.**
* **One slot representation per yielding function.** A helper shared by
  coroutines whose outward types have different C representations (an
  `int` and a domain) is refused; compiling it once per representation
  would lift it.
* **The frame pass reads the generated C** (block structure, labels, names),
  which the backend itself writes; it is conservative (a variable may be
  persistent that a finer liveness would not keep), never optimistic.
* **Zeroing at construction** costs a store per byte of storage per
  construction; a target counting cycles could initialize only what is read
  before written [design].
* **No external embedding lifecycle** (section 10): coroutines live within
  one `PREFIX_run`.
* **Kinds sharing a handle type** are dispatched by a `switch` on a tag in
  the handle's target; a single kind needs no tag (none is emitted).
* **Not run on hardware**; the cross executions are emulated; no bare-metal
  image was linked.

## 23. Recommended next milestone

**C-BOUNDED-STORAGE-MILESTONE-1**, as the brief proposes, now with concrete
inputs: every storage type is a named fixed-size struct the manifest lists,
and a construction site is one slot. The next steps, in order:

1. **Caller-provided storage for constructions** -- a function that makes a
   coroutine for its caller receives the storage from it (the return-slot
   convention of section 22), statically sized; this is also the first
   step to fixed frame pools, where the pool is the caller.
2. **Context-owned mutable storage** in C (MutableVector/MutableArray with
   a capacity bound), so a driver context can hold queues and timers -- the
   prerequisite of an event loop written in ordinary Botlish
   (EVENT-LOOP-MILESTONE-1.md).
3. **An application-instance boundary** (section 10's shape B): a language
   design for an entry program whose top level stays suspended between
   events, which the frames already support.

Then C-EVENT-LOOP-FREESTANDING-MILESTONE-1: `std::event_loop::Driver`
implemented by a context over a target's event sources, the simulated and
the hardware driver two entry programs of one application -- the shape
`kiosk_bench.bot` and `kiosk_field.bot` already have.

## 24. Files, and what to run when changing this

* `ccompile/ccompile.tcl`: the Coroutines section (`IsThunk`,
  `IsYieldingInstance`, `ParamName`, `FrameName`, `ThunkInstance`,
  `ThunkTitle`, `ThunkCaptures`, `HandleKey`, `HandleSlots`, `SetYieldH`,
  `CoKind`, `Create`, `Resume`, `Yield`, `YieldingCall`, `Dispatch`,
  `ResumeType`, `FrameType`, `FrameCycles`, `FrameOrder`, `Unmark`,
  `Persist`, `Fields`, `CoroutineTypes`, `CoroutineCode`, `KindTags`,
  `CoroutineManifest`), `Function` (state machines, the escape rule, the
  frame pass, `(void)out`), `Params` (thunks), `Decl` and `Declarator`, the
  `co` representation in `ReprOf`, `CType`, `ZeroOf`, `StorageRepr`'s
  refusal, `BlockCall`'s routing, `NativeCall`'s coroutine operations,
  `StaticBindings` (a thunk's captured temporaries are locals),
  `Assemble` and `Manifest`.
* `examples/c-freestanding/kiosk/`, `frame-sizes.sh`, `demo.sh` (section
  5), `README.md`.
* `tests/c-compile.test` (the coroutine corpus, the `cc-co-*` section),
  `audit/golden/migration/census/c-compile.tsv`,
  `audit/golden/migration/tcl-names.txt`, `tests/golden/manifest.tsv`
  (regenerated).
* `compilerpedia/topics/backends.topic` (`backend.c`),
  `compilerpedia/topics/errors-runtime.topic` (`error.c-unsupported`).

When changing any of it, run what AGENTS.md's "The C backend" lists --
`tests/c-compile.test` (its cross tests need clang, ld.lld, qemu-user and
the cross libgcc packages), `tests/main-cli.test`, `tools/compilerpedia.tcl
check`, `examples/c-freestanding/demo.sh` -- and, for a change to what the
backend reads of coroutines (`mayYield`, the thunks table, the handle type's
contract, `hir::affine`'s affinity), `tests/coroutines.test` and the affine
tests to keep those facts what they are.

Reproduce:

    examples/c-freestanding/demo.sh OUT                 # section 5 of its output
    tclsh9.0 tests/c-compile.test -match 'cc-co-* cc-parity-coroutine-*'
    tclsh9.0 main.tcl -emit-c -out OUT examples/c-freestanding/kiosk/kiosk_bench.bot
    examples/c-freestanding/frame-sizes.sh OUT kiosk_bench avr thumbv6m-none-eabi msp430-none-elf
