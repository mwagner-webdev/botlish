# C-CALLBACK-MILESTONE-1.md

Synchronous C callbacks into the active Botlish execution environment: the
completion report.

A Botlish program can now declare a function C may call back, make a C
function pointer of it, hand that pointer to a C function, and have C call
it synchronously while the Botlish code that called C waits. The callback
runs nested in that same execution environment -- the same heap, context
area, statics and coroutine chain -- may allocate, call C again and be
called back again, and returns an exact C value. The collector keeps every
waiting Botlish frame's values across the C frames in between without ever
reading one of them. Every other way of calling the pointer -- on another
thread, after the call that gave it returned, from another stack -- is
refused before any Botlish code runs, and a callback that fails ends the
process: a C callback has no error channel, and nothing is made up for C.

```botlish
import std::ffi::c

extern c fn count_accepted(decide: std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Int], return: std::ffi::c::Int}] noescape, n: std::ffi::c::Int) -> std::ffi::c::Int

callback c fn decide(value: std::ffi::c::Int) -> std::ffi::c::Int:
    if value > 0:
        return 1
    0

cb = std::ffi::c::callback(decide)
count_accepted(cb, 10)
```

The architectural rule this milestone keeps: foreign code invokes Botlish
code only through an entry point whose execution environment, authority and
lifetime are accounted for. A callback's machine address is no authority: it
selects no execution environment, makes no actor, context or heap, and
inherits no context dependency.

## Contents

1. [Syntax and static semantics](#1-syntax-and-static-semantics)
2. [The pointer and its type](#2-the-pointer-and-its-type)
3. [The C ABI entry and return](#3-the-c-abi-entry-and-return)
4. [Relationship to exported c fn](#4-relationship-to-exported-c-fn)
5. [Activation and execution ownership](#5-activation-and-execution-ownership)
6. [Reentrant GC and the stack-rooting invariant](#6-reentrant-gc-and-the-stack-rooting-invariant)
7. [Errors, suspension and failure](#7-errors-suspension-and-failure)
8. [Lifetime: the non-retention contract](#8-lifetime-the-non-retention-contract)
9. [Floating values](#9-floating-values)
10. [Acceptance against real C](#10-acceptance-against-real-c)
11. [Raven](#11-raven)
12. [Performance and allocation](#12-performance-and-allocation)
13. [Tests, fuzzing, mutation, backends](#13-tests-fuzzing-mutation-backends)
14. [Limitations and the next milestone](#14-limitations-and-the-next-milestone)
15. [What to run when changing this](#15-what-to-run-when-changing-this)
16. [Files](#16-files)

## 1. Syntax and static semantics

### The declaration

`callback` is a contextual function modifier beside `nomethod` and
`exported`, and like `exported` it names the foreign ABI, `c`
(surface/parser.tcl's `Function`):

```botlish
callback c fn NAME(PARAM: CTYPE, ...) -> CTYPE:
    BODY
```

It sets the block's `callback c` field (hir/syntax.tcl's `withCallback`),
which resolution copies, HIR text prints (`... captures () callback c ...`)
and hir::parse reads back, so interchange and the front-end cache carry it
(`cb-declaration-hir`, `cb-interchange`). A function is a C export or a C
callback, never both (`exported c callback c fn` is a syntax error: the two
have different C ABIs), and `callback` stays an ordinary name everywhere
else (`callback = 3` is fine).

To Botlish callers a callback is an ordinary function: it is called,
specialized and inlined like any other, on every backend (`cb-tcl-backends`,
the golden suite's `cb-tcl-backends/describe`).

### What makes a callback (hir/callbacks.tcl)

`hir::callbacks::verify` runs in every compilation (`hir::CheckOnce`, after
the exports' check) and diagnoses each `callback c fn`:

| kind | the rule |
|---|---|
| CALLBACK-PLACEMENT | a top-level function of the entry program or of a module: C calls its entry point with no enclosing function |
| CALLBACK-SIGNATURE | every parameter's type declared and one whose conversion from C is total (section 3); the result declared, one whose conversion to C is total (`-> unit` for void); no declared errors; no flags, context parameters, variadic parameter or resume clause |
| CALLBACK-ENVIRONMENT | it captures no value (calling other top-level functions is no capture; a module static is fine), requires no context (transitively: `hir::contexts::required`), and never suspends (`hir::coroutines::MayYield`) |

The checks are exports' (hir/exports.tcl) in shape, with the C signature
rule in place of the export boundary types. A callback's body is otherwise
ordinary code under every other analysis: its errors are none, so the
completion analysis reports any error it may raise and does not handle
(UNHANDLED-ERROR) -- through erased callables too (the erased-callable
contract charges unknown calls); a direct call in it without a context of
its module to mediate it makes the module direct (DIRECT), which a callback
-- having no context -- can only satisfy by `direct module`
(`cb-direct-authority-in-body`).

The four kinds are DiagnosticCode cases (`CallbackEnvironment`,
`CallbackPlacement`, `CallbackReference`, `CallbackSignature`), so a
`static compile:` block's rejection reifies them (the golden suite's
`cb-placement-environment/nested`), and each has a Compilerpedia topic with
a rejected example (`error.callback-*`).

## 2. The pointer and its type

`std::ffi::c::callback(NAME)` (core/cabi.tcl) is the one way to a
callback's C function pointer:

* **Its argument names a `callback c fn`.** A reference, by name, to a
  binding whose value is a block with `callback c`
  (`hir::callbacks::Referenced`): an ordinary function, a parameter holding
  a function value, a closure, any computed value is CALLBACK-REFERENCE
  ("a C function pointer is made only of a top-level function declared
  `callback c fn` ..."). The identity is established statically.
* **It is only called.** Taken as a value (`g = std::ffi::c::callback`) it
  is CALLBACK-REFERENCE: a function value of it would make a pointer of
  whatever it got at run time.
* **Its type is the declaration's C signature.** The native's result shape
  `{callback-pointer 0}` (hir::types::ShapeResult) types the call
  `std::ffi::c::FnPtr[Fn{args: [...], return: R}]` of exactly the declared C
  types -- a declared Float64 result as `std::ffi::c::Double` -- the same
  canonical `{cfnptr F}` an `extern c fn`'s parameter spells. Any other
  signature admits it nowhere (TYPE: `cb-pointer-type`, the golden suite's
  `cb-pointer-type/other-signature`); a call that names no callback is
  poison (no cascade).
* **No implicit conversion.** A Botlish `Fn` is not a `FnPtr`, either way
  (TYPE: `cb-reference`, `cb-reference/function-value`).
* **It is affine**, like every C pointer (C-ABI-TYPES.md): bound, then
  passed; a temporary passed to an observing parameter is
  AFFINE-TEMPORARY-UNSUPPORTED, a second use after a move USE-AFTER-MOVE,
  `cb.clone()` the explicit second alias. No adaptation of the affine rules
  was needed: binding the pointer first is the ordinary spelling, and a
  static callback's pointer needs no ownership of its own.
* **The callback keeps its contract.** Passing the function's name to the
  operation erases nothing (hir::callables's `ArgContexts`): every call
  through the pointer converts C's values into exactly the declared types.

Natively the call lowers to `%d = cbaddr N` (native/lower.tcl's
`CallbackAddress`), the address of callback N's entry point tagged as a C
address word; the reference itself makes no closure. The Tcl backends have
no machine for C to call, so making a pointer there is NATIVE-ONLY at run
time (`core::cabi::callbackImpl`); a program that only declares callbacks
and calls them as functions runs on all four backends.

## 3. The C ABI entry and return

### Which C types a callback takes

A callback has no error channel (section 7), so every conversion at its
boundary must be total: no C value of a parameter's type may fail to become
a Botlish value, and no Botlish value of the result's type may fail to
become a C value. `hir::callbacks::CType` states it per position:

| declared | as a parameter | as the result |
|---|---|---|
| a C integer scalar (`std::ffi::c::SChar` ... `ULongLong`) | yes: every C value is an Int of the domain (a 64-bit one beyond the small range a BigInt) | yes: the checker proved the result in the domain |
| `std::ffi::c::Bool` (bool) | yes, C `_Bool` (a byte other than 0 or 1 is refused: section 7) | yes |
| `std::ffi::c::RawFloat`, `RawDouble` | yes: every bit pattern | yes: its bits |
| `std::ffi::c::Ptr[T]`, `FnPtr[F]` | yes (an address the C address word cannot hold is refused: section 7) | yes |
| Float64 (what `std::ffi::c::Double` means as a value type) | **no**: C's NaN or infinity has no Float64 -- CALLBACK-SIGNATURE, naming RawDouble | yes, as C `double`: every Float64 is one |
| `std::ffi::c::Float` | no (no Botlish value type: TYPE) | no |
| `unit` | no | yes: `void` |
| anything else (`int`, `str`, a List, a refinement, an imprint variable) | no | no |

"Total" includes two C values no conforming C caller passes -- a `_Bool`
byte other than 0 or 1, and an AArch64 top-byte-tagged address, which no
60-bit C address word holds -- and the policy for them is explicit: they
are refused before the body runs (NATIVE CALLBACK ARGUMENT), as a C result
of the same kind is refused after a C call (NATIVE BOOL, NATIVE ADDRESS).

### The entry point (native/src/codegen/callback.rs)

Each callback has one C entry point, `botlish_callback_N`, a local function
of the program's object (or JIT module) compiled by Cranelift:

* **Its signature is the C signature in the target's C calling convention**
  (`target::c_call_conv`: System V on Linux and macOS x86-64, AAPCS64 and
  Apple's AArch64 convention, Win64): each parameter at its class's machine
  type (`clif::c_type`: an integer at its width, a raw float or double in
  the floating-point register of its finite counterpart, a pointer a
  64-bit word), a narrow integer or `_Bool` result extended to its register
  by its signedness (the ABIs leave those bits unspecified; this callee
  defines them).
* **It stores its arguments as words**: an integer sign- or zero-extended
  by its class, a `_Bool` zero-extended, a floating value's bits by
  `bitcast` (a float's 32 zero-extended), never a conversion instruction,
  so no NaN is quieted, no payload canonicalized and no negative zero
  changed on the way in.
* **It calls the runtime once**, `rt_callback_call(entry, desc, desc_len,
  words, out)`: ENTRY the callback function's generic entry (`func_addr`,
  a relocation within the object), DESC its descriptor -- a local
  read-only data object of the result class, the parameter classes and the
  name (runtime::callback's `descriptor`) -- and OUT a stack slot for the
  result word.
* **It returns the result word as its C type**: an integer narrowed
  (`ireduce`), a raw value `bitcast` back into its floating-point register,
  a Float64's bits as a double, nothing for void.

There is no libffi, no executable-memory trampoline and no run-time code
generation: an entry point is a static function of the program's code,
emitted with it -- in a standalone executable, linked with it, with no Tcl,
no JIT and no source (`cb-executable`). Nothing names it but `cbaddr`; it
has no global symbol.

The runtime (native/src/runtime/callback.rs's `run`) converts each word
into the Botlish value of its class (`argument`: an Int of the C integer's
value, re-derived from the word's own low bits; `true`/`false`; a raw C
floating value of the bits, `Vm::new_raw_float`; a C address word), rooting
each in `Vm::temp_roots` while the next is made, calls the generic entry
with them, and converts the result (`result_word`: the Int's two's
complement in its range, 0 or 1, the raw value's bits, a Float64's bits,
the address). The generic entry of the callback function's generic instance
is what an export's trampoline calls too (section 4): it takes tagged
values and runs the open instance compiled under the declared contract
alone.

### Roots of compilation

A callback's function is a root whether or not Botlish code calls it:

* native lowering passes every valid callback's block to specialization as
  an export root (`hir::specialize::analyze -exports`, beside a library's
  exports), so its generic instance is used and open -- no caller's fact
  (a range, a raw ABI, a folded branch) ever reaches it;
* the header's `callback N func=F params="..." result=K name="NAME"`
  declares it (nir.rs's `CallbackDecl`, validated: F an environment-free
  function of that arity with a generic entry);
* coroutine fusion's dead-code elimination keeps what the callbacks reach
  (fusion.rs's `drop_unreferenced`): nothing calls a callback's function
  but its entry point (the mutant `root-dropped-by-fusion` shows the bug
  this prevents).

### Cross-target lowering

The driver's Cranelift has its host's ISA only. On an x86-64 host the Rust
tests compile a program's entry points and transition shim for
`x86_64-unknown-linux-gnu`, `x86_64-apple-darwin` and
`x86_64-pc-windows-msvc` and check each signature is the triple's C
convention (System V, System V, Win64), the raw values bitcast and never
converted (codegen::callback's tests). The AArch64 conventions (AAPCS64,
Apple's) are compiled and run where they are the host's: tests/c-callbacks.test
on CI's Linux arm64 and macOS arm64 workflows. This report's machine-code
and run results are Linux x86-64's; no AArch64 hardware was available to
this milestone, and no claim is made about it beyond what its CI runs.

## 4. Relationship to exported c fn

| | `exported c fn` (NATIVE-LIBRARY-MILESTONE-1.md) | `callback c fn` |
|---|---|---|
| who calls it | a C host, through the library's public symbol `LIB_NAME` | C code a Botlish program called, through a function pointer the program gave it |
| execution environment | an instance the host created (`LIB_create`), checked out for the call | the environment waiting in the foreign call (section 5); none is created |
| C ABI | int64_t/bool/double/str, the instance first, a status result, out-parameters, owned errors | the declared C types directly: no instance, no status, no out-parameter |
| errors | data: a status and an owned error object | none: a failure ends the process (section 7) |
| symbol | global, public | none (a local entry point) |
| re-entry | a host call into an instance already in a call is REENTRANT-CALL | a callback is re-entry by design, through a transition |

What they share: the root rule (both are specialization's open roots, kept
by dead-code elimination), the generic entry the trampoline calls, the
shape of the Cranelift-emitted entry (words in a stack slot, one runtime
call), the C signature machinery (`target::c_call_conv`, `clif::c_type`)
and the collector's refusal to read host frames (a library's
`Vm::stack_ceiling`; a callback's segment jump, section 6). The library's
lifecycle, statuses, error objects and REENTRANT-CALL are unchanged: a host
entering an instance through `LIB_FN` while it runs is still refused, and a
callback never goes through `botlish_library_call`
(NATIVE-LIBRARY-MILESTONE-1.md, "Thread affinity", updated). A library's
program may declare callbacks: they run in the instance whose call is
waiting in C, under the library's private runtime copy (whose thread-local
activation is its own).

## 5. Activation and execution ownership

### Transitions

A C function whose contract lets it call back -- a `std::ffi::c::FnPtr`
parameter declared noescape (`hir::foreign::CallsBack`; section 8) -- is
marked `callbacks=1` in NIR's `foreign` declaration. Every call of it is a
**foreign transition**: generated code calls, at the same safepoint, a
*transition shim* (codegen::callback's `shim`, one per call shape) of the C
call's own signature with the Vm first, which

1. calls `rt_ffi_open(vm)`: records the shim's own frame record on the Vm
   (`Vm::foreign_open`, innermost last) and makes the Vm this thread's
   **active** execution environment (`ACTIVE`, a thread-local), returning
   the one it replaces;
2. calls the C function with its arguments unchanged (through its variadic
   stub where it has one);
3. calls `rt_ffi_close(vm, previous)`: pops the transition and restores the
   previous active environment;

and returns C's result. Calls of every other C function are as before: a
direct call, no shim, no activation.

### Entry

A callback's entry point runs the callback only in the **active execution
environment of the calling thread** (`run`):

| condition | otherwise |
|---|---|
| this thread has an active environment: a Vm waiting in an open transition | NATIVE CALLBACK THREAD when another thread opened one (a C thread: `cb-refused-thread`), NATIVE CALLBACK INACTIVE when none is open here (C kept the pointer and called it after the call, or during a call that may not call back: `cb-refused-retained`) |
| the callback's frame is on the stack that environment is running (its thread's, or the running coroutine's: `Vm::running_stack`), below the transition's frame | NATIVE CALLBACK STACK (C switched to a stack of its own: `cb-refused-stack`, ucontext) |
| the host runs callbacks (`runtime::callback::SUPPORTED`) | NATIVE CALLBACK UNSUPPORTED (Windows, the fallback root plan: section 14) |

Each refusal ends the process before any Botlish code of the callback runs
(section 7): a wrong-thread entry is a real C thread's (pthread_create in
the fixture), never a simulated identifier. The thread check is the
thread-local itself -- a callback on another thread finds no active
environment there -- and the diagnosis between THREAD and INACTIVE is a
plain process-wide record of the thread that opened a transition last (no
locked instruction on the transition's path).

Then the callback runs nested in that Vm: `ACTIVE` is cleared (the Vm is no
longer waiting in C: a C call the callback makes needs its own transition,
and a pointer C calls from a non-transition call made by the callback is
INACTIVE), its segment is pushed (section 6), and on return both are
restored exactly -- the segment popped, the Vm waiting in C again, so C
may call the callback again during the same call (`cb-decisions`: a
thousand calls in one C loop) and nested transitions stack
(`cb-nested-gc`, `cb-recursion`: 300 levels of Botlish -> C -> Botlish).
`rt_ffi_close` checks the balance: a segment still naming the closing
transition is NATIVE CALLBACK BUG, so a missing pop cannot pass silently.

### Execution ownership today, and actors

The runtime has no actor scheduler yet: an execution environment is one Vm
on one thread (an executable's worker; a library instance on its owning
thread). The milestone implements the smallest explicit ownership that the
intended hierarchy -- a thread with one event loop, actors on it,
coroutines per actor -- needs to keep: **a callback runs in the environment
that is suspended across the initiating foreign call, on its thread**. The
function pointer selects nothing; the transition does. When actors arrive,
the transition is per actor: `rt_ffi_open` records the running actor (not
only the Vm) as the one waiting in C, and the entry checks that the waiting
actor is the one the transition names. Nothing in the safety argument
changes: the pointer remains no authority, a callback still never creates
or switches to an actor, and an actor that is not suspended in a
transition is never entered by one. No multi-actor scheduling was built for
this.

What a callback may not do, and does not: construct a Vm, actor, context or
heap (nothing on its path allocates one), enter another environment (only
`ACTIVE`'s), run on a foreign worker (THREAD), access an unavailable context
(a callback requires none: CALLBACK-ENVIRONMENT), or schedule asynchronous
work as its result (its result is its body's value, returned synchronously).

## 6. Reentrant GC and the stack-rooting invariant

### The problem

```text
Botlish frame A           live references, its call of C a safepoint
  transition shim         (codegen::callback; a Cranelift frame)
    C frames              any frame layout, frame pointer or not
      callback entry      (codegen::callback; a Cranelift frame)
        run               (runtime::callback; a Rust frame)
          Botlish frame B allocates: the collector runs
```

The collector finds roots by walking frame records (runtime::framewalk):
each record's return address names a safepoint of the Botlish frame above
it, whose stack map lists its live roots. The chain from B climbs through
Rust frames (built with frame pointers) to `run`, the entry point and then
C. C compiled without frame pointers uses the frame-pointer register as an
ordinary callee-saved register: its value there is no frame (it may stop
the walk, or send it into arbitrary memory), and A's roots -- which only a
record whose return address is in A names -- would be missed.

### The invariant

**A collection during a callback visits every root of every waiting
Botlish frame of the execution environment, and reads no word of a C
frame.** It holds because:

* A's call of C is a safepoint: `ForeignCall` was already one ("foreign
  code may reach the runtime"), and its call is now the call of the
  shim, so A's live values are in A's stack map at the shim's return
  address (the mutant `foreign-call-not-safepoint` shows the bug otherwise).
* The shim's frame record holds A's frame pointer and the return address
  into A at that safepoint -- Cranelift opens every frame that calls with a
  frame record -- and `rt_ffi_open` records exactly that record (its own
  record's first word: the shim is its caller).
* `run` pushes its own frame record and the transition's
  (`Vm::callback_segments`) before any allocation, and pops it after the
  last. `framewalk::walk_segmented` walks as before, except that from a
  segment's entry record it continues at the transition's record instead
  of the saved frame pointer: the shim's record, whose return address is
  A's safepoint, then A's own chain. The frames in between -- the shim's
  call of C, C, the entry point -- are never read. Segments nest (each
  callback's entry is distinct; each transition is above its entry on the
  same stack, which entry checks).
* A coroutine's resumer stack is walked the same way
  (`walk_from_segmented`): a callback that resumes a coroutine is a
  resumer whose stack holds a segment (`cb-coroutines`). A suspended
  coroutine's stack never holds one: a callback never suspends, and a
  yield never crosses C (section 7).
* Arguments are rooted as they are made (`temp_roots`); the result is
  converted before anything allocates again. A byte exposure of A's call is
  kept alive by its keepalive after the call (C-POINTER-BORROWING.md), and
  the collector never moves an object, so the address C holds stays valid
  across a callback's collections (`cb-exposure-survives`: C reads the
  exposed bytes before and after a callback that collects).

### The adversarial check

The first version of the tests passed with the jump removed: the fixture's
C, compiled at -O2, never touched the frame-pointer register, so the chain
happened to run through it. The fixture now calls the nesting callbacks
through `call_without_frame` (x86-64 and AArch64 inline assembly: the
register set to 16, an address no stack has, around the call). With the
jump removed, `cb-nested-gc` under GC stress aborts in the runtime
(heap corruption of main's list); with it, every backend returns the right
values. The mutants `walk-reads-c-frames` (no jump),
`actor-outermost-transition` (a nested callback jumping to the outermost
transition, past the frames of the callback that called C: the middle
callback holds a String across its inner C call) and `segment-not-popped`
are killed by it (section 13).

## 7. Errors, suspension and failure

**Static.** A callback declares no errors, and the completion analysis
holds its body to that (UNHANDLED-ERROR for any declared error it may
raise, through erased callables too: `cb-error-propagation`); it never
suspends (CALLBACK-ENVIRONMENT for a yield, directly or through a callee);
it requires no context. The existing effect and contract machinery decides
all of it; no callback-specific error check was added.

**Run time.** Declared errors excluded, a callback can still fail: a
run-time semantic error (`mod(7, 0)`: CORE SEMANTIC ARITHMETIC), an invalid
foreign value inside its body (a C function returning an address no C
pointer holds: NATIVE ADDRESS), stack exhaustion, an argument no value of
its type is, or a runtime defect. The policy is fail-closed:

* **Nothing unwinds into C.** Botlish failures are values (NO_VALUE and the
  Vm's error), never unwinding; `rt_callback_call` runs everything inside
  `catch_unwind`, so a panic of the runtime is caught there.
* **Nothing is made up.** No value is returned to C for a failure: the
  process ends (`Fatal::terminate`).
* **It is reported.** NATIVE CALLBACK FAILED carries the callback's name and
  the failure's own message and code ("callback divide failed, and a C
  callback has no error channel to its C caller: mod: division by zero
  (CORE SEMANTIC ARITHMETIC)"); a refusal its own kind (THREAD, INACTIVE,
  STACK, ARGUMENT, RESULT, UNSUPPORTED, BUG). The driver's result line when
  the driver runs the program (`error {NATIVE CALLBACK FAILED} {...}`, exit
  status 0, like the stack guard's line), else the message on standard
  error and exit status 1 (a standalone executable: `cb-executable-failure`;
  a native library's host).
* **Nothing returns to C.** `platform::report_fatal` writes with write(2)
  and ends with _exit(2): no atexit handler or stdio lock of the C library
  (whose frames are below) runs.
* **Stack exhaustion** is the guard's: NATIVE LIMIT STACK, terminal as
  everywhere (`cb-stack-exhaustion`).

Each is tested in a child process: a program that calls C always runs as a
linked executable, the driver's child.

## 8. Lifetime: the non-retention contract

Four lifetimes are distinct:

* **The code**: an entry point lives as long as the program's image.
* **The `FnPtr` value**: an affine C address word, which owns nothing.
* **The activation**: the dynamic extent of one foreign call that may call
  back -- the only time C may call the pointer.
* **A retained registration**: a pointer C keeps for later, which would
  need an owner whose lifetime bounds C's use. Not here (section 14).

The contract that a C function calls a pointer during the call and keeps
it no longer is the existing escape fact on its `FnPtr` parameter,
`noescape` (declared, or proven), which C-FFI.md and C-POINTER-BORROWING.md
already defined as "C does not keep the pointer past the call". It is the
binding author's statement, never inferred: the compiler and the binding
generator read no fact from a `FnPtr`'s type (the generator's bindings
leave every escape unknown unless a profile states it). What it adds:

* a C function with a noescape `FnPtr` parameter is a transition
  (`hir::foreign::CallsBack`), so C may call back during its calls;
* a `FnPtr` parameter that may keep its pointer (`captures`, or nothing
  stated) is no transition, and is the existing retaining call -- a direct
  edge of the calling module (hir/direct.tcl), DIRECT outside a direct
  module (`cb-retention-is-authority`): an unproven retention assumption is
  visible and subject to the airlock;
* a data pointer's noescape says nothing of callbacks.

If C breaks the contract -- keeps the pointer and calls it after the call
returned, or during a call that is no transition -- the runtime refuses it
(NATIVE CALLBACK INACTIVE): no retained callback can outlive its
activation through the safe path, and the unsafe path (a direct module
handing the pointer to a retaining function) still ends in the same
refusal, never in Botlish code running outside an activation.

The affine `FnPtr` rules needed no extension: a static callback's pointer
is bound, then passed to a noescape parameter, which observes it; nothing
about it is owned or released.

## 9. Floating values

Callbacks reuse RAW-C-FLOAT-FFI-MILESTONE-1.md's representations unchanged:

* a `std::ffi::c::RawFloat` or `RawDouble` parameter or result crosses as
  its bits -- every NaN payload, signaling NaNs, both infinities, negative
  zero, subnormals -- with no admission and no conversion instruction in
  the entry point (bitcasts only) or the runtime (`new_raw_float` of the
  bits, `raw_bits` back): `cb-raw-floats` returns thirteen patterns through
  RawDouble and RawFloat identity callbacks unchanged, reads their bits in
  Botlish as C built them, classifies them as C does, and C checks every
  one of them by its own bits;
* the C `float` and `double` machine signatures are the finite types' (an
  F32 or F64 parameter in the floating-point registers), as for an extern;
* nothing admits a raw value implicitly: a callback admits one explicitly
  (`std::ffi::c::raw::double_to_float64`, handling NonFiniteFloat), and
  `cb-raw-floats`' `admit` returns the finite patterns as C doubles
  (negative zero admitted as zero, as Double's rule says);
* the finite `std::ffi::c::Float` and `Double` are refused where their
  conversion can fail (a Double parameter, a Float anywhere: section 3), and
  a Float64 result is a C double (total).

A mixed signature of 23 parameters -- every integer width, raw floats and
doubles, a `_Bool`, a pointer, interleaved past every convention's
registers, so some arrive on the stack -- hands every argument back to C,
which compares each with what it passed (`cb-mixed-abi`: 0 wrong).

## 10. Acceptance against real C

tests/cffi/callback-fixture.c (built by the tests with the host's C
toolchain) calls the callbacks and checks their answers itself -- with its
own arithmetic and its own reading of the bits it passed, never a value the
Botlish side computed -- and returns the number of wrong answers. Every
result below is the same on cranelift and cranelift-generic, normally and
under BOTLISH_NATIVE_GC_STRESS=1 (a collection at every allocation site)
(`cbAgree`):

| test | what C does | result |
|---|---|---|
| `cb-round-trip` | calls an int callback, before and after an unrelated C call | 42, 5, 44, -14 |
| `cb-decisions` | acts on parity answers (C counts wrong ones), filters by a callback, calls a void callback of no arguments 7 times, sums 1000 calls in a tight loop | 0, 45, 7, 999000 |
| `cb-nested-gc` | the central test: main holds heap values; C outer calls callback 1, which allocates and calls C inner, whose callback 2 allocates; both C calls with no frame chain | main's values intact, C's result 205 |
| `cb-recursion` | recursion C -> Botlish -> C ... 300 levels, C checking each level | 300, 10, 0 errors |
| `cb-scalars` | every integer class and `_Bool` and a pointer at their limits, in and out | 0 wrong each |
| `cb-raw-floats` | thirteen bit patterns through raw callbacks: identity, bits, classification, admission | 0 wrong each |
| `cb-mixed-abi` | 23 mixed parameters, stack-passed ones included | 0 wrong |
| `cb-exposure-survives` | reads an exposed Bytes before and after a callback that collects | 0 (unchanged) |
| `cb-coroutines` | a callback that runs a coroutine; a coroutine that calls C that calls back (fused and on the general runtime) | 21, 10, 12 |
| `cb-qsort` | the system C library's qsort sorts exposed byte storage with a Botlish comparator reading native views | sorted, the original unchanged |
| `cb-executable` | the nested test as a standalone executable, moved, empty environment, and under GC stress | the same values |
| `cb-refused-thread` | calls a callback on a pthread while the Botlish thread waits | NATIVE CALLBACK THREAD |
| `cb-refused-stack` | calls a callback on a ucontext stack of its own (Linux) | NATIVE CALLBACK STACK |
| `cb-refused-retained` | keeps a pointer past the call and calls it in a later call | NATIVE CALLBACK INACTIVE |
| `cb-refused-arguments` | a `_Bool` byte 2; an address no word holds | NATIVE CALLBACK ARGUMENT |
| `cb-failure-is-fatal` | callbacks whose bodies fail (division by zero; a NATIVE ADDRESS inside), after successful calls | NATIVE CALLBACK FAILED with the failure's code |
| `cb-stack-exhaustion` | a callback that recurses without bound | NATIVE LIMIT STACK |
| `cb-executable-failure` | a standalone executable's failing callback | its message on stderr, exit status 1 |

No test has a C bridge compute an answer for Botlish: every callback's body
is Botlish code the test wrote, and every number above is C's count or C's
arithmetic over what the callbacks returned.

## 11. Raven

audit/c-callbacks/tools/raven-census.tcl reads the committed Raven binding
(RAVEN-BINDINGS.md) and classifies its 74 callback-taking functions by when
and where Raven calls what they are given (audit/c-callbacks/raven-callbacks.tsv):

| category | functions | what they need |
|---|---:|---|
| synchronous, non-retaining (this milestone) | 0 | -- |
| retained: kept, called on the UI thread during later frames (`Rdraw_frame`, `Rwait_frame`) | 70 | a retained registration |
| -- of which Raven acts on the returned value | 11 | (virtual list items, drag data, close and drop decisions, event consumption, XML tag creation) |
| -- of which notifications (void) | 59 | the event bridge already records the reporting ones; paint and measure still run code inside the frame |
| on worker threads (`Rtask_run_async`, `Rparallel_for`, the Vulkan queue lock) or the thread that raised an error (`Rerror_set_callback`) | 4 | thread and actor integration |
| with a C `float` in the callback's signature | 9 | a RawFloat declaration (the binding's `representations`, or a raw-float callback type) |

So, distinguishing what the brief asks:

1. **Callback machinery proved against real C**: the fixture's calls, and
   the system C library's `qsort` (`cb-qsort`).
2. **Raven APIs usable through it now**: none. Every Raven callback is
   registered and called later, or on a worker. No Raven acceptance test
   was added: one would need a bridge to call Botlish outside an
   activation, which the runtime refuses by design, or a C bridge that
   computes the answer itself, which would prove nothing.
3. **Raven APIs awaiting retained registration**: the 70, among them every
   use case of RAVEN-BINDINGS.md section 7.1 -- custom painting
   (`Rcustom_set_paint_callback`, `..._measure_callback`), virtual lists
   (`Rlist_view_set_virtual_items`, `Rtile_view_set_items`), event
   consumption (`Rwidget_set_event_callback`, `Rwindow_set_event_hook`),
   drop and close decisions.
4. **Raven worker callbacks awaiting thread/actor integration**: the 4.

The event bridge (packages/raven/native/raven_bridge.c) stays the path for
notifications: its buffered model is right for them, and this milestone
does not replace or change it.

### The smallest retained registration for custom painting

`Rcustom_set_paint_callback(widget, cb, user_data)` keeps `cb`; Raven calls
it on the UI thread inside `Rdraw_frame` for each frame that paints the
widget, until another callback (or NULL) replaces it. With this milestone's
mechanism, the smallest sound addition is:

1. **A registration resource**: an affine, opaque value a context owns
   (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md), made by registering a
   `callback c fn` with a retaining C function (`captures`) through the
   binding's own context -- the registration is the authority, so it is
   mediated, not a bare DIRECT call -- and released by calling the
   binding's unregistration (`Rcustom_set_paint_callback(widget, NULL,
   NULL)`) before the context drops it.
2. **Dispatching calls**: a contract fact on C functions that do not take
   the pointer but may call registered ones -- `Rdraw_frame`,
   `Rwait_frame` -- making each of their calls a transition of the
   registering actor, exactly as a noescape parameter does today (NIR's
   `callbacks=1`, the shim). Nothing in sections 5 and 6 changes: the
   callback runs nested in the actor waiting in `Rdraw_frame`.
3. **A live-registration check**: the entry consults the registration
   (generation-checked) and refuses a callback whose registration was
   released (INACTIVE), so a library that calls after unregistration fails
   closed rather than running code without an owner.
4. **Float positions**: `RPaintCallback`'s rectangle is floats; the
   callback declares RawFloat (or the profile's representations make them
   raw) and admits explicitly.

That unlocks painting and measuring; virtual lists and the decision
callbacks follow with the same pieces.

## 12. Performance and allocation

bench/c-callbacks.tcl measures each scenario as the linked executable a
program that calls C is, best of RUNS executions, compilation and linking
excluded, and reads one run's allocations from the runtime's own counters
(runtime::metrics' summary, the counters the JIT's `--alloc` reports use;
a linked run now reports them with `botlish-native run --alloc summary`,
main.rs's `run_linked` passing `BOTLISH_NATIVE_ALLOC` to the executable's
driver protocol). No instrumentation was added to allocation: the counters'
off state is the existing single branch.

BENCHMARK_TABLE

Reading it:

* **A callback costs CALLBACK_NS ns** (callback-int: C ABI entry, the
  runtime's checks and conversions, the generic entry, the result, the
  activation's save and restore), against C_PLAIN_NS ns for a C call
  without one and BOTLISH_NS ns for a Botlish call (below the loop's noise:
  the call is inlined). The transition alone -- a call of a C function that
  may call back and does not -- adds TRANSITION_NS ns (two runtime calls,
  a thread-local and a Vec push and pop).
* **Raw floating values allocate one FloatObj per incoming parameter and
  per raw value returned through a raw-producing operation**: raw-float-in
  and raw-double-in measure exactly 1.00 RawFloat or RawDouble allocation
  per call, 16 bytes each; a raw value returned (raw-*-trip) is the same
  object, unboxed by the result conversion (no second allocation). The
  cost of the box is RAW_BOX_NS ns per call over callback-int.
* **Inspection** (raw-inspect) adds a third of an allocation per call:
  `double_nan?` reads the bits as an Int, and the bits of negative zero,
  one pattern in three, are beyond the small-Int range (a BigInt).
* **Explicit admission** (raw-admit) adds one Float64 FloatObj per call (2
  allocations: the raw value and the admitted Float64).
* **Two levels** (nested-2: an outer callback that calls C that calls an
  inner one) cost NESTED_NS ns per outer call.
* **Collector**: no scenario but the allocating ones collects during the
  measured run; `allocating` (a String per call) shows the collections it
  causes.

What cannot be isolated with this instrumentation: the C ABI entry
(the entry point's stores and loads) and the activation (the runtime's
thread-local and segment bookkeeping) are one path, timed together; the
collector's share is visible only as collection counts. An earlier version
of the runtime allocated a Rust `String` and two `Vec`s per callback (the
descriptor's name and messages formatted eagerly) and used two locked
atomic increments per transition: callback-int measured about 108 ns and
the transition 26 ns. Making the success path allocation-free and the
transition's diagnosis a plain store -- an obviously safe change of this
milestone's own code -- brought them to the numbers above. The FloatObj per
raw parameter is the representation RAW-C-FLOAT-FFI-MILESTONE-1.md chose
(raw values are boxed); removing it would be an unboxed raw-value
representation, which this milestone does not attempt. The measured
baseline -- one 16-byte FloatObj per raw floating argument -- is what a
custom-painting callback receiving four floats per call would pay.

## 13. Tests, fuzzing, mutation, backends

### tests/c-callbacks.test (35 tests)

Static, on every host: the declaration and its HIR text (`cb-declaration-hir`),
the grammar (`cb-modifier-grammar`), the signature rules
(`cb-signature-total-conversions`, `cb-signature-sections`), placement and
environment (`cb-placement-environment`, `cb-context-requirement`), the
pointer operation (`cb-reference`, `cb-pointer-type`), retention as
authority (`cb-retention-is-authority`, `cb-direct-authority-in-body`),
errors (`cb-error-propagation`), the Tcl backends (`cb-tcl-backends`),
interchange (`cb-interchange`), NIR (`cb-nir`) and CLIF (`cb-clif`).
Running callbacks, where they run (nativeCCallbacks): sections 10's table.
The whole file runs in about 25 s.

### The golden suite (tests/golden/c-callbacks.bot, 9 tests)

What a Botlish program can express of it, on all four backends: callbacks
as ordinary functions, a nested declaration (CallbackPlacement), the
pointer operation's references (CallbackReference) and its exact type.
Everything else -- C, top-level declaration errors, refusals that end a
process, generated code -- stays in the Tcl file, which stays
authoritative; the census and fragment record each test
(audit/golden/migration/census/c-callbacks.tsv,
fragments/c-callbacks.tsv: 4 SPLIT, the rest KEEP-*).

### Rust unit tests

`cargo test --release --manifest-path native/Cargo.toml callback`: the NIR
parser's callback declarations, validation and `callbacks=1`
(nir.rs's `callback_tests`); the runtime's descriptors and result words
(runtime::callback's tests); the cross-target entry points and shims
(codegen::callback's tests, section 3).

### The fuzzer (audit/c-callbacks/tools/fuzz.tcl)

Random callbacks of up to sixteen parameters of every class (integer
limits, raw float and double patterns among them signaling NaNs, pointers,
`_Bool`), interleaved past the registers; a result echoing a parameter or a
constant; sometimes allocating, sometimes nesting a second callback through
C; a C driver per callback, generated as real C, calling it a random number
of times and checking every argument (handed back) and the result by bits.
FUZZ_RESULTS

### Mutation (audit/c-callbacks/tools/mutate.tcl)

MUTATION_RESULTS

### Backends and hosts

cranelift and cranelift-generic run every callback test, normally and under
GC stress; interp and compile run the static tests and the golden suite
(making a pointer is NATIVE-ONLY there). Standalone executables link with
the rustc linker (the tests) and the system linker (checked by hand on this
container); the stub linker refuses any program that calls C, as before.
Linux x86-64 is this report's evidence. Linux AArch64 and macOS AArch64 run
the same tests in their CI workflows (the capability `cCallbacks` includes
them: the frame-record chain and the walk are the same there, and the
fixture's frame-pointer clobbering has an AArch64 form); Windows refuses a
callback at run time (section 14).

### Regression

Run after the change: REGRESSION_RESULTS

## 14. Limitations and the next milestone

* **No retained registrations.** A callback C keeps and calls later is
  refused (INACTIVE). Section 11 sketches the smallest retained
  registration; it is the recommended next milestone, as a context-owned
  affine resource, with dispatching-call transitions and generation-checked
  entry.
* **No context-bearing callbacks**: a callback requires no context. A
  registration whose dependencies were established when it was made is the
  path (the same next milestone).
* **No worker-thread entry, no cross-actor dispatch, no asynchronous
  callbacks.** A C thread's call is refused; Raven's four worker callbacks
  wait for thread and actor integration.
* **Windows x86-64 and the fallback root plan refuse callbacks** at run
  time (NATIVE CALLBACK UNSUPPORTED): Windows walks frames with its
  unwinder, which does not yet jump across a transition, and the fallback
  plan keeps roots on a shadow stack the transition does not bracket.
  Neither was needed for the milestone's hosts. tests/platform/native-status.tcl
  has no callback probe yet: its Windows expectation (the refusal's report
  through the Windows result path) could not be checked here.
* **A failure ends the process.** By design for this milestone; a C API
  with a concrete error convention for its callbacks would be the reason
  to add more.
* **A null `FnPtr`** still has no operation (C-ABI-TYPES.md).
* **Variadic callbacks** stay unsupported (no type spells one).
* **Raw floating parameters are boxed** (one FloatObj each: section 12).
* **AArch64 evidence is CI's**, not this container's (section 3).

## 15. What to run when changing this

AGENTS.md, "C callbacks (callback c fn)", is the list: tests/c-callbacks.test
(also under BOTLISH_NATIVE_GC_STRESS=1), the golden suite, the Rust tests
(`callback`), the fuzzer (several seeds, once with `-gc-stress 1`) and the
mutants (every one applied and killed), plus tests/c-ffi.test,
tests/native-library.test, tests/coroutines.test and
tests/raw-c-float-ffi.test for shared code. `bench/c-callbacks.tcl`
regenerates section 12; `audit/c-callbacks/tools/raven-census.tcl` section 11.

## 16. Files

| file | what |
|---|---|
| surface/parser.tcl, surface/ast.tcl, surface/recover.tcl, surface/lower.tcl | the `callback c` modifier |
| hir/syntax.tcl, hir/resolve.tcl, hir/format.tcl, hir/read.tcl, hir/hir.tcl | the block's `callback` field and its text |
| hir/callbacks.tcl | the rules, the pointer's type, the records |
| hir/types.tcl, core/native.tcl | the `callback-pointer` result shape |
| hir/callables.tcl | the pointer operation keeps its argument's contract |
| hir/foreign.tcl | `CallsBack`: a noescape FnPtr parameter makes a transition |
| hir/static.tcl, stdlib/compiler.bot | the four DiagnosticCode cases |
| core/cabi.tcl | `std::ffi::c::callback` (NATIVE-ONLY on the Tcl backends) |
| native/lower.tcl | callback roots, `callback` lines, `cbaddr`, `callbacks=1` |
| native/src/nir.rs | `CallbackDecl`, `Inst::CallbackAddress`, `ForeignDecl::callbacks` |
| native/src/codegen/callback.rs | transition shims and callback entry points |
| native/src/codegen/clif.rs, mod.rs, fusion.rs, roots.rs, nirtext.rs | the call through the shim, `cbaddr`, listings, roots |
| native/src/runtime/callback.rs | `rt_ffi_open`, `rt_ffi_close`, `rt_callback_call`, the activation, the fatal policy |
| native/src/runtime/framewalk.rs, vm.rs | `walk_segmented`, `Vm::foreign_open`, `callback_segments`, `running_stack` |
| native/src/runtime/platform/guard.rs | `report_fatal` |
| native/src/runtime/aot.rs, native/src/main.rs | `--alloc summary` of a linked run |
| native/native.tcl, tests/helpers.tcl | the `cCallbacks` capability, `nativeCCallbacks` |
| tests/c-callbacks.test, tests/cffi/callback-fixture.c, tests/cffi/cbx.bot | the tests and their C |
| tests/golden/c-callbacks.bot | the golden suite |
| audit/c-callbacks/tools/ | fuzzer, mutants, Raven census; raven-callbacks.tsv |
| bench/c-callbacks.tcl | section 12 |
| compilerpedia/ | concept.c-callbacks, error.callback-*, error.native-callback, stdlib.std::ffi::c::callback |
