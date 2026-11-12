# WINDOWS-X86-64-MILESTONE-9.md

Milestone 9 of the Windows x86-64 port: synchronous native C callbacks.
The existing `callback c fn` facility (C-CALLBACK-MILESTONE-1.md) runs on
Windows x86-64 with MSVC's toolchain: a C function compiled by cl calls a
Botlish callback's function pointer during a foreign call whose
`std::ffi::c::FnPtr` parameter is noescape, and the callback runs in the
Botlish execution environment waiting in that call -- with the Win64 ABI,
every live root of the waiting Botlish frames found across C's frames, and
no transfer of execution ownership across threads, stacks or library
instances. The milestones before it are WINDOWS-X86-64-MILESTONE-1.md (the
driver, executables) to WINDOWS-X86-64-MILESTONE-8.md (native libraries as
DLLs). The work was developed on Linux.

> A Windows C function can synchronously call back into the Botlish
> execution environment that called it, with the correct ABI, complete GC
> roots, and no accidental transfer of execution ownership across threads,
> stacks or library instances.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner through
  `.github/workflows/windows-x86_64.yml`, run named;
* **real Linux** and **real macOS**: this repository's Linux x86-64
  container, and the Linux x86-64, Linux arm64 and macOS arm64 CI
  workflows, run named;
* **cross-built**: a Windows object made on Linux (Cranelift's
  `x86_64-pc-windows-msvc` ISA) or the Windows driver checked on Linux
  (`cargo check --target x86_64-pc-windows-msvc`) -- never run;
* **code inspection**: what the code does, read, not run.

No Wine and no WSL were used. Commits are on the branch
`ccr-ded2e6b6-05sy19`, where every CI run below ran.

## Contents

1. Result
2. Starting state
3. Root cause
4. Architecture experiments
5. The selected continuation
6. The Windows segmented walk
7. Safepoints and GC
8. The Win64 ABI
9. Unwind metadata
10. Activation and refusal
11. Coroutines and fibers
12. Native libraries
13. A real Win32 API
14. Failure semantics
15. The fallback plan
16. Tests and mutants
17. Performance
18. CI
19. Remaining limitations
20. Files changed, and what to run

## 1. Result

**Done.** On Windows x86-64 with MSVC's toolchain, `callback c fn`
executes synchronously: C compiled by cl (and hand-written ml64 assembly,
and kernel32) calls a Botlish callback's pointer during a foreign call
whose FnPtr parameter is noescape, and the callback runs in the waiting
Botlish execution environment -- in standalone executables (the rustc and
system linkers), in the native backends' linked runs (cranelift,
cranelift-generic), in the JIT (Rust tests), and inside Botlish DLLs.
Source semantics are unchanged: no language change, no new syntax, type,
diagnostic, or contract; the same program compiles to the same HIR and NIR
on every target.

What makes it sound, and what was changed for it:

* **The Windows walk crosses a foreign transition** (sections 3-7): from a
  callback's entry frame it jumps to the transition shim's frame record and
  resumes in the Botlish frame that called C at its call's safepoint --
  never unwinding C, the entry point or the shim, never reading a C frame,
  checking the record before using it.
* **The transition is the shim's frame register**, handed on by a naked
  two-instruction `rt_ffi_open` on every host (Linux and macOS read the same
  value as before, from a different place).
* **The C side of callbacks has Windows unwind information** (section 9):
  every transition shim and callback entry point, in COFF objects,
  executables, DLLs and the JIT's function table.
* **Failures are coded on Windows** (section 14): a Windows `report_fatal`
  gives the driver its result line, an executable its message and status 1.
* **A defect on every host fixed** (section 10): a library's callback during
  a call made on a host-made stack (a host's fiber, a `ucontext` stack) was
  refused NATIVE CALLBACK STACK.
* **The capability is the walk's**: `SUPPORTED = NATIVE_FRAME_ROOTS &&
  CROSSES_TRANSITIONS`; `cCallbacks` names windows-x86_64; the fallback root
  plan still refuses.

RESULT-EVIDENCE

## 2. Starting state

Before this milestone a Windows program with a callback compiled, linked
and ran up to the first time C called the callback's pointer, and then
ended the process with NATIVE CALLBACK UNSUPPORTED, by design:

* the front end accepted `callback c fn` and `std::ffi::c::callback` on
  every target (hir/callbacks.tcl reads no target), with the pointer typed
  `std::ffi::c::FnPtr` of the declaration's C signature;
* native lowering emitted the program's `callback N` declarations, `cbaddr`
  and `callbacks=1` on a foreign call whose FnPtr parameter is noescape, for
  every target;
* codegen::callback wrote every transition shim and callback entry point in
  the target's C convention -- `windows_fastcall` for
  `x86_64-pc-windows-msvc` (checked by its cross-target Rust tests on
  Linux) -- and the shims ran on Windows (`rt_ffi_open`, `rt_ffi_close`
  around every such C call);
* the runtime refused the callback itself: `runtime::callback::SUPPORTED`
  was `NATIVE_FRAME_ROOTS && cfg!(not(windows))`, so `run` returned NATIVE
  CALLBACK UNSUPPORTED before any Botlish code; on Windows
  `Fatal::terminate` printed the message and called `exit(1)` (no result
  line for the driver: `report_fatal` was the POSIX guard's only);
* `framewalk::walk_segmented` and `walk_from_segmented` on Windows took
  their jumps as `_jumps` and ignored them: "Windows makes no foreign
  transitions";
* `native/native.tcl`'s `cCallbacks` capability named Linux x86-64 and
  AArch64 and macOS AArch64, so tests/c-callbacks.test skipped every test
  that runs a callback on Windows, and tests/platform/native-status.tcl had
  no callback probe at all.

The refusal was the right restriction, not the defect: a collection inside
a callback must find the roots of the Botlish frames waiting in C, and the
Windows walk could not reach them.

## 3. Root cause

The Windows collector walks a stack from a machine context (WINDOWS-X86-64-
MILESTONE-3.md): a Botlish frame by its Cranelift frame record (`[rbp]`,
`[rbp + 8]`, `rbp + 16`), every other frame -- the collector's, runtime
helpers, the driver -- with Windows' unwinder (`RtlLookupFunctionEntry`,
`RtlVirtualUnwind`; a function with no function table entry taken for a
leaf). Between a callback's Botlish frames and the Botlish frame that called
C lie, from the inside out: `runtime::callback::run` and `rt_callback_call`
(Rust), the callback's C entry point (Cranelift, then without unwind
information), C's frames (MSVC's -- or anything: hand-written assembly,
another compiler, a frame without a function table entry), C's call of the
callback, and the transition shim (Cranelift, also without unwind
information). The walk had two ways to try to cross that, and neither is
sound:

* Windows' unwinder through every one of those frames needs each to have
  truthful unwind information. The C side of callbacks had none (a
  generated shim or entry point was taken for a leaf: the walk would read a
  stack slot as a return address), and C's frames are not this runtime's to
  vouch for: a C function without a function table entry is unwound as a
  leaf, and the walk then reads whatever is at its stack pointer.
* The frame-pointer chain the Linux and macOS walkers follow is not there:
  MSVC keeps no frame record at RBP, and RBP is an ordinary nonvolatile
  register to C.

What was missing is the Windows counterpart of the frame-pointer walk's
segment jump: a recorded continuation, valid for the whole foreign call,
that lets the walk leave the callback's entry frame and resume exactly in
the Botlish frame that called C, at its call's safepoint, without reading a
single frame in between. The jumps were already recorded on every host
(`Vm::callback_segments`); only the Windows walk ignored them, and the
recorded transition itself was read from a place Windows does not keep it.

`rt_ffi_open` found the transition as "the first word of my own frame
record": its frame pointer's saved value, which is the shim's frame record
where every Rust frame keeps the frame-pointer chain (-C
force-frame-pointers=yes on Linux and macOS). On Windows that read is
garbage: LLVM's Win64 prologue sets the frame register inside the frame
(`push rbp; sub rsp, N; lea rbp, [rsp + K]`: UWOP_SET_FPREG), when it sets
one at all, so `[rbp]` of a Rust frame is no saved frame pointer
(WINDOWS-TOOLCHAIN-CENSUS.md, B2) -- and `framewalk::frame_record()` on
Windows returns the stack pointer, so the old code would have read a stack
slot of `rt_ffi_open`'s own frame.

## 4. Architecture experiments

The question each candidate answers: where does the walk get, while a
callback runs, the machine state of the Botlish frame waiting in C -- its
RIP at its call (the safepoint naming its stack map), its RSP at the call
(the base of the map's offsets) and its RBP (its frame record, how the walk
goes on) -- valid for the whole foreign call, independent of C?

**A. Capture a continuation with Windows' unwinder at every transition.**
`rt_ffi_open` captures its own context (`RtlCaptureContext`) and unwinds
one frame (`RtlLookupFunctionEntry`, `RtlVirtualUnwind`): the result is the
shim's context at its call of `rt_ffi_open`, and unwinding the shim (given
unwind information) is the Botlish caller's. Correct where every frame
involved has truthful unwind information -- the shim then needs it, which
this milestone gives it anyway (section 9) -- but it costs a context
capture, a function-table search and a virtual unwind on every call of
every C function that may call back, whether it calls back or not:
measured on Windows at UNWINDER-COST per capture (bench/c-callbacks.tcl's
last line, run RUN-BENCH), against TRANSITION-COST for the whole transition
today. It also stores a 1232-byte CONTEXT (or its three words) per open
transition. Rejected for its cost; its correctness argument is kept as a
check (`check_transition`, below).

**B. Pass the shim's frame pointer from generated code.** Cranelift has
`get_frame_pointer`; the shim would pass it to `rt_ffi_open` as a second
argument. Its verifier refuses the instruction unless the ISA flag
`preserve_frame_pointers` is set (cranelift-codegen 0.135.2,
`verifier/mod.rs`: "enabling `preserve_frame_pointers`"), and that flag is
module-wide: every Botlish function -- leaves included -- would get a frame
record, changing code generation, stack maps and the frame records' shape
everywhere for one 2-instruction need. Rejected.

**B'. Hand on the shim's frame register at `rt_ffi_open`'s entry.** At the
instant the shim's `call rt_ffi_open` lands, RBP (AArch64: x29) still holds
the shim's frame record: Cranelift's prologue made it (`push rbp; mov rbp,
rsp`), the shim's body never changes it (Cranelift reserves the frame
register), and it is nonvolatile in every convention involved. A naked
function of two instructions reads it there and jumps on:

    rt_ffi_open:            ; System V        ; Win64           ; AAPCS64
        mov rsi, rbp        ;  (2nd argument)   mov rdx, rbp      mov x1, x29
        jmp rt_ffi_open_at  ;                   jmp ...           b ...

It leaves no frame (so needs no unwind information: Windows takes it for
the leaf it is), costs two instructions, keeps `rt_ffi_open`'s C ABI, the
helper table and every shim unchanged, and is the same mechanism on every
host -- on Linux and macOS it yields exactly the value the old read of
`rt_ffi_open`'s own frame record did, so the frame-pointer walk's input does
not change. **Selected.**

What the walk then derives from the record is the Botlish caller's state at
its call of the shim, by the same frame-record step every Botlish callee
already gets (WINDOWS-X86-64-MILESTONE-3.md, invariant 2): RIP `[t + 8]`,
RSP `t + 16`, RBP `[t]`. Valid as long as the shim's frame is live, which is
the whole foreign call; read only while a callback of that call runs.

**Comparison.**

| | A (unwinder) | B (get_frame_pointer) | B' (naked hand-on) |
|---|---|---|---|
| stack-map lookup | exact (the caller's RIP) | exact | exact |
| RIP/RSP/RBP | from Windows' unwinder | from the record | from the record |
| survives optimization | yes | yes | yes (no Rust frame involved) |
| independent of C's frames | yes | yes | yes |
| nested transitions | one capture each | one record each | one record each |
| coroutine stacks | yes | yes | yes |
| walk overhead | none extra | none extra | none extra |
| per-transition cost | UNWINDER-COST | one argument | two instructions |
| JIT, AOT, DLL | yes | needs a global flag | yes |
| other hosts | Windows only | all, changed codegen | all, unchanged codegen |

The experiment on real Windows that settles B' is the check
BOTLISH_NATIVE_UNWIND_CHECK=1 now runs at every transition
(`framewalk::windows::check_transition`): from inside `rt_ffi_open_at`
Windows' unwinder (candidate A) unwinds into the shim, whose RBP must equal
the record B' handed on, and unwinds the shim to exactly the (RIP, RSP,
RBP) the walk's jump will make of it. Observed equal on every transition
of the callback tests' executables (section 16).

## 5. The selected continuation

* **What is saved:** per open transition, one word -- the transition
  shim's frame record `t` (`Vm::foreign_open`, as on every host); per
  running callback, the pair (its entry frame, `t`)
  (`Vm::callback_segments`). On Windows the entry frame is `run`'s stack
  pointer (`framewalk::frame_record()` reads RSP there); elsewhere `run`'s
  frame record.
* **Its lifetime:** `t` is pushed by `rt_ffi_open_at` right before the shim
  calls C and popped by `rt_ffi_close` right after C returns; the segment
  is pushed by `run` before the first argument is converted (the first
  allocation a callback can make) and popped after its result is
  converted (the last). A segment never outlives its transition
  (`rt_ffi_close` ends the process, NATIVE CALLBACK BUG, if one does).
* **Its validity:** while a segment exists, its transition's shim is
  suspended in its call of C, so `[t]` and `[t + 8]` are the shim's saved
  frame pointer and return address and `t + 16` its caller's stack pointer
  at the call -- the shim's caller is always Botlish code (only
  `ForeignCall` calls a shim), and that call is a safepoint
  (`mark_safepoint` after `ForeignCall`), so `[t + 8]` names a stack map.
* **Its use:** the walk reads `t` only while a callback of that transition
  runs, and only through `jump`, which checks it first (section 6).

## 6. The Windows segmented walk

`framewalk::windows::walk_context` climbs from a context one frame at a
time, as before (a Botlish frame by its record, any other by Windows'
unwinder), with one more case: a frame that is not Botlish code and whose
RSP equals a segment's entry -- `run`'s frame, reached from the callback's
Botlish frames (the generic entry `run` called is a Botlish frame whose
record step yields exactly `run`'s RSP, which `run`'s body never moves) --
is not unwound. `jump` makes the next context the waiting Botlish frame's:

    RIP = [t + 8]      the shim's return address: the ForeignCall safepoint
    RSP = t + 16       the waiting frame's stack pointer at that call
    RBP = [t]          its frame record

and the climb goes on there, reading that frame's roots at `RSP + entry`
for the safepoint's entries, then its callers. Everything between --
`run`'s callers in the runtime, the callback's entry point, C's frames,
C's call of the callback, the shim -- is never read.

Checks, each a coded failure, never a guess (`transition_failed`: NATIVE
CALLBACK BUG and the process ends): `t` must lie above the entry frame,
8-aligned, inside the stack being walked (the thread's, a coroutine's, a
host fiber's, bounded by a library call's ceiling), and `[t + 8]` must be
Botlish code (`ProgramMap::find`). A transition is never accepted because
it merely lies in the stack's numeric range.

Nesting: a callback that calls C that calls a second callback has two
segments; the inner `run`'s RSP is below the outer's, so the walk meets the
inner first, jumps to the inner transition (inside the first callback's
Botlish frames), climbs them, meets the outer `run`, jumps to the outer
transition. Each entry is matched by its own RSP, so a nested walk never
jumps from one segment's entry to another's transition (the mutants
`windows-jump-to-outermost-transition` and
`windows-jump-to-innermost-transition` do, and are killed).

Suspended and resumer stacks (`walk_from_segmented`, from a coroutine
switch's recorded frame) take the same jumps: a segment's entry on another
stack never matches there, its transition is on its own stack.

With BOTLISH_NATIVE_UNWIND_CHECK=1 a jump also checks that the frame it
leaves is `run`'s (`check_entry_frame`: the function table entry containing
its RIP is `run`'s), and the run's summary line reports the jumps.

The walk without segments is unchanged: `walk` is `walk_segmented` with no
jumps, and `walk_from` `walk_from_segmented` with none.

## 7. Safepoints and GC

The argument that every live root of the waiting Botlish frames survives a
collection inside a callback, on Windows:

1. **The waiting frame's roots are in a stack map.** A call of a C function
   that may call back is a `ForeignCall` through the transition shim, a
   safepoint (codegen::clif's `foreign_call`: `mark_safepoint` on the call),
   unchanged from Linux; its stack map lists every rooted value live across
   it, at offsets from the frame's RSP at the call.
2. **The collection's walk reaches the callback's entry frame.** It starts
   in the collector (`Vm::collect_with`), climbs the runtime's Rust frames by
   Windows' unwinder and the callback's Botlish frames by their records --
   the existing walk -- and arrives in `run` with RSP equal to the segment's
   entry (section 6).
3. **The jump lands exactly on the waiting frame at its safepoint.** RIP is
   the shim's return address, the address right after the `ForeignCall`
   instruction; RSP is the waiting frame's stack pointer at that call
   (`t + 16`: the call pushed the return address at `t + 8`, the shim's
   `push rbp` the saved RBP at `t`); RBP is its frame record. So
   `ProgramMap::roots_at(RIP)` is the safepoint's entry list and `RSP +
   entry` each root's slot -- what the frame-record step computes for any
   Botlish callee.
4. **No foreign frame is read for roots.** Only `run`'s RSP is compared
   (with a recorded value), and no word of the runtime's frames above `run`,
   the entry point's, C's or the shim's is read but `[t]` and `[t + 8]` of
   the shim's own frame record. A foreign return address is never taken for
   a safepoint: after the jump RIP is checked to be Botlish code, and roots
   are only ever read through `roots_at`, keyed by exact return addresses.
5. **Nested callbacks and middle frames.** Each callback's own frames are
   walked between its `run` and the transition its Botlish caller opened;
   a middle callback's frames (holding values across the inner C call) are
   visited between the inner jump and the outer `run` (cb-nested-gc,
   cb-nested-loop: level1's String held across `cbx::inner`).
6. **No root twice in a way that matters.** Each frame is visited once (the
   walk's RSP strictly ascends; a jump goes up); the roots are a set of
   slots marked by a non-moving collector, so a duplicate would be harmless
   anyway.
7. **Byte exposures stay valid.** A `read noescape` exposure of the outer
   call is kept alive by its NIR `keepalive` after the call -- a use, so the
   owner is a root of the waiting frame's stack map
   (C-POINTER-BORROWING.md); cb-exposure-survives reads the exposed bytes
   in C before and after an allocating callback.
8. **After fusion and specialization.** The callback's function is a root
   of specialization and of fusion's dead-code elimination; stack maps are
   computed on the code that runs (fused or not): cb-coroutines and
   cb-nested-in-coroutine run with fusion on and off (`withoutCoroutineFusion`).

The adversarial check: on Windows the nesting callbacks' C calls are made
by `cbx_win64_call_without_frame` (tests/cffi/callback-fixture-win64.asm),
a frame with no function table entry whose stack pointer holds 0 and whose
RBP holds 16. Windows' unwinder takes it for a leaf and reads a return
address of 0 there, so any walk that unwound C instead of jumping stops
before the waiting frames: their values are collected while still in use.
The mutant `windows-walk-ignores-segments` (the jump never taken) is
killed by exactly that (section 16).

## 8. The Win64 ABI

The entry point's signature is `windows_fastcall` (Cranelift's Win64), as
generated since C-CALLBACK-MILESTONE-1.md; nothing about the convention
changed in this milestone. What changed is that it is now checked against
real callers on Windows:

* **MSVC's own calls** (tests/cffi/callback-fixture.c compiled by cl /O2):
  every integer class at its limits, `_Bool`, pointers (cb-scalars), raw
  floats and doubles of every bit pattern -- signaling NaNs with payloads,
  both infinities, negative zero, subnormals -- in and out, compared by bits
  in C (cb-raw-floats), the 23-parameter mixed signature past every register
  (cb-mixed-abi), each argument handed back to C and compared.
* **A hand-placed call** (callback-fixture-win64.asm's
  `cbx_win64_abi_call`, ml64): `long long f(int, double, float, long long,
  double, int, signed char, double)` -- by Win64's rule an argument's
  register is its position's, so the float third goes in XMM2 and the
  integer fourth in R9, the rest in 8-byte stack slots above the 32-byte
  shadow space. The caller makes it adversarial: RCX's upper 32 bits and
  XMM2's upper 32 dirty, the stack-passed int and signed char with dirty
  bits above their widths, the unused register of every register position
  (RDX, R8, XMM0, XMM3) dirty. It holds a distinct sentinel in RBX, RBP,
  RDI, RSI, R12-R15 and XMM6-XMM15 across the call and reports a bit for
  every one that changed. cb-abi-preserved requires the four floating
  arguments' bits, the integer sum, and no changed register -- also when
  the callback allocates and collects (GC stress).
* **The result**: a narrow integer or `_Bool` result is extended by its
  signedness (the entry point's `sext`/`uext` return attribute), so the
  bits a C caller reads above its width are defined; a raw floating result
  is its bits in XMM0.

## 9. Unwind metadata

A transition shim and a callback entry point are real Win64 functions:
Cranelift's frame record, outgoing calls (the shim three, the entry point
one), stack slots (the entry point's argument words and result), and in
the shim the callee-saved registers its arguments are kept in across
`rt_ffi_open`. Before this milestone neither had unwind information: the
AOT object's `.pdata` listed the program's functions and generic entries
(and a library's public functions, WINDOWS-X86-64-MILESTONE-8.md), the
JIT's function table the same -- codegen::callback compiled the C side of
callbacks without asking Cranelift for its `UNWIND_INFO`.

Now `codegen::callback::define` records each shim and entry point it
compiles as a `Defined` -- its id, its code's size, its `UNWIND_INFO`
(`clif::windows_unwind`: codegen::unwind's encoding of Cranelift's own
prologue description, the same as every Botlish function's; never
Cranelift's winx64 encoder), whether it is an entry point -- in
`clif::Symbols::callback_code`:

* **AOT, executables and DLLs:** `codegen::add_windows_unwind` writes them
  to `.xdata` and `.pdata` beside the program's functions and a library's
  public functions (one RUNTIME_FUNCTION each, against the function's own
  symbol, its end's addend its size). A library object goes through the
  same function, so a DLL's callback code has it too.
* **The JIT:** `jitunwind::define_unwind_data` places their `UNWIND_INFO`
  in the module's unwind data, and `jitunwind::register` adds them to the
  function table registered with `RtlAddFunctionTable` before any of the
  code can run; the table is deleted before the code is released, as
  before (`CompiledProgram`'s field order).

Evidence: cross-built, `codegen::callback`'s
`windows_objects_describe_every_shim_and_entry_point` (every host with an
x86-64 backend; run on Linux) parses a Windows object of a program with a
shim and two entry points and finds each one's RUNTIME_FUNCTION and its
exact UNWIND_INFO (version 1, frame register RBP, at least the push and the
frame register's setting). Real Windows:
`jit_callback_code_is_in_the_function_table` (the entry point a
`cbaddr` gives starts its function table entry, the shim's call is inside
one, both gone with the code), `jit_callbacks_cross_a_frame_windows_cannot_unwind`
and cb-windows-unwind-check (every shim and entry point unwound by
Windows' unwinder as it runs, compared with its frame record:
`check_transition`, `check_entry_point`), and cb-windows-unwind-through: from
C called by a nested callback, Windows' unwinder alone -- no help from the
runtime -- climbs through both callbacks' entry points, the runtime, the
inner call's transition shim and the Botlish frames between, to both C
functions that called back.

## 10. Activation and refusal

The activation model is C-CALLBACK-MILESTONE-1.md's, unchanged: a pointer
selects a function, never an execution environment; the transition shim
establishes the environment (`ACTIVE`, this thread's waiting Vm), and the
callback enters it only if it is there, on its thread and stack.

* **Wrong thread** (cb-refused-thread): the fixture calls the callback from
  a thread of `CreateThread` while the Botlish thread waits in
  `WaitForSingleObject`. The C thread's ACTIVE is null and the last thread
  that opened a transition is another: NATIVE CALLBACK THREAD, nothing ran.
  The report goes through the guard's records (the Botlish thread's, since
  the C thread has none) to the driver's result file.
* **Retained** (cb-refused-retained, cb-refused-inside-callback): a pointer
  kept by `cbx_store` (a `captures` parameter, in a direct module) and
  called later -- after its call returned, or during a call that may not
  call back -- finds no waiting environment: NATIVE CALLBACK INACTIVE, even
  with an outer transition open (a running callback clears ACTIVE).
* **Wrong stack** (cb-refused-stack): the fixture switches to a fiber of
  its own (`CreateFiber`; the thread converted with `ConvertThreadToFiber`
  unless it already is a fiber) and calls the callback there. `run`'s stack
  pointer is not on the running stack the transition left: NATIVE CALLBACK
  STACK, nothing ran. The check compares stacks, not threads: the thread is
  the right one.
* **Nested**: an inner transition replaces ACTIVE and `rt_ffi_close`
  restores the previous one, so an inner callback binds to the inner
  transition and the outer is exactly as it was afterwards (cb-nested-gc,
  cb-nested-repeated, cb-recursion 300 deep).

The running stack is now `Vm::running_stack`'s: a coroutine's; else, during
a native library's call on a stack the host made (a host fiber, a
`ucontext` stack), that stack (`Vm::entry_stack`,
WINDOWS-X86-64-MILESTONE-8.md); else the thread's. Before this milestone it
ignored `entry_stack`, so a library's callback during a call made on a
host's own stack was refused NATIVE CALLBACK STACK on every host -- a defect
found by nl-callbacks' host-stack case (Linux `ucontext`, Windows fiber),
fixed in the same change (mutant `running-stack-ignores-entry-stack`).

## 11. Coroutines and fibers

* **A coroutine calls C, C calls back** (cb-coroutines, cb-nested-in-coroutine,
  general runtime and fused): the transition is opened on the coroutine's
  fiber stack, the callback runs there (the running stack is the
  coroutine's), and a collection walks the fiber from the callback's
  frames, jumps to the transition on the same fiber, climbs the
  coroutine's frames, then walks the resumer's stack from the switch's
  recorded frame (`walk_from_segmented`, the same jumps).
* **A callback drives a coroutine** (cb-coroutines' `steps`): a collection
  in the coroutine walks its fiber, then the resumer's -- the main stack,
  from `bl_co_switch`'s recorded frame -- up through the callback's frames,
  where the jump to the outer transition is taken.
* **A host fiber runs a DLL export that calls back** (nl-callbacks, host
  stack): see section 10.
* **C switches fibers and calls back there**: refused (section 10).
* **No suspension across C**: a callback that yields is still
  CALLBACK-ENVIRONMENT (cb-placement-environment); a coroutine driven by a
  callback completes or stays suspended inside the callback's frames,
  never across C.

## 12. Native libraries

A Botlish DLL's code may declare callbacks and pass them to C its exports
call (on Windows from a DLL of the host's: a DLL cannot import from its
executable). The callback enters the library's instance whose call is
waiting in C, nested in that call -- never through the registry
(`checkout`), so it is no REENTRANT-CALL; a host's call of that instance
from inside the callback is, as before. nl-callbacks and
nl-callbacks-two-libraries, on Linux (static archives) and Windows (DLLs
built by link.exe, MSVC hosts), plainly and under GC stress (`nlRunBoth`):

* three plain round trips (`run(7) = 26`: C calls the callback, which
  allocates around a host call);
* reentrancy: from inside the callback the host calls the same instance's
  export -- `REENTRANT-CALL`, status 4 -- and the callback goes on;
* instances: before calling the callback, C runs the *other* instance's
  export, which opens and closes its own transition and runs its own
  callback; the first instance's callback then enters the first instance
  (`26026`). The mutant `library-wrong-instance` (a closed transition
  leaving its Vm active) fails it;
* a host stack: the host runs the export on a fiber it made (Linux: a
  `ucontext` stack), and the callback runs there;
* two libraries: library A's callback calls library B's export through
  the host, B allocates and collects in its own instance (and once fails
  with its own declared error, `Odd`), A's callback allocates and collects
  again in A's. Each library carries its own runtime -- its own ACTIVE,
  `rt_callback_call` and `run` -- so neither can enter the other's
  instance.

Unloading: a callback's pointer is valid only during its activation; a DLL
unloaded and reloaded gives no stored pointer an activation (code
inspection: ACTIVE is per runtime copy, and a reloaded copy starts with
none, so a stored pointer called later is INACTIVE if it still points at
code, and the host's undefined behavior if it does not). The preconditions
of WINDOWS-X86-64-MILESTONE-8.md, section 11, are unchanged.

## 13. A real Win32 API

kernel32's `EnumSystemLocalesEx(LOCALE_ENUMPROCEX, DWORD, LPARAM, LPVOID)`
calls its `BOOL CALLBACK (LPWSTR, DWORD, LPARAM)` once per locale,
synchronously, on the calling thread, and keeps it no longer (Microsoft's
documentation); a FALSE answer stops the enumeration. The program declares
it by its C types -- a Win32 `BOOL` is a 32-bit int (`std::ffi::c::Int`),
never C's `_Bool`; `DWORD` is `unsigned long` (`std::ffi::c::ULong`, 32 bits
on Windows); `LPARAM` is pointer-sized (`std::ffi::c::LongLong`); the
callback pointer `noescape`, `lpReserved` a null pointer. The callbacks
allocate (under GC stress, collecting with kernel32's frames between them
and the waiting Botlish frame) and hand each call to C, which counts. No
locale list or order is assumed: cb-win32-locales requires at least three
locales, every call with a name and the program's lParam (12345), and a
callback answering 0 at its third call stops the enumeration at three.

## 14. Failure semantics

The policy is C-CALLBACK-MILESTONE-1.md's: a C callback has no error
channel, so whatever still fails ends the process after its report, and
nothing unwinds into C or returns a made-up value. What Windows needed:

* **A coded report.** `Fatal::terminate` called the POSIX guard's
  `report_fatal` on Unix and printed and `exit(1)`ed elsewhere. Windows now
  has its own `platform::report_fatal` (runtime/platform/windows.rs): the
  driver's result line `error {NATIVE CALLBACK KIND} {MESSAGE}` to the
  guard record's destination (the `--result` file) and exit status 0 while
  a driver's guard is installed -- after the thread's label when the record
  is the reporting thread's own, through any guarded thread's record from a
  thread C created -- else `MESSAGE (NATIVE CALLBACK KIND)` on standard
  error and exit status 1 (a standalone executable, a native library's
  host). Only WriteFile and TerminateProcess (and `__fastfail` should
  TerminateProcess ever return): it runs inside C's frames, whose locks the
  C runtime's exit handlers might need. So every refusal reaches the test
  harness as data (`{CALLBACK THREAD} ...`, `{CALLBACK STACK} ...`), and
  cb-executable-failure's executable prints its message and exits 1.
* **The codes**: NATIVE CALLBACK THREAD, INACTIVE, STACK (refused entries),
  ARGUMENT (a `_Bool` byte other than 0 or 1, an address no C pointer word
  holds), FAILED (the body's run-time failure, its own code in the
  message), RESULT (an unchecked program's ill-typed result), BUG (a
  defect of this runtime -- among them, new, a transition the Windows walk
  cannot cross), UNSUPPORTED (the fallback plan). Stack exhaustion inside a
  callback is the stack guard's NATIVE LIMIT STACK (cb-stack-exhaustion:
  Windows' vectored handler, WINDOWS-X86-64-MILESTONE-4.md).
* **Nothing unwinds into C**: `rt_callback_call` catches a panic of the
  runtime and reports it as NATIVE CALLBACK BUG; the mutant
  `failure-panics-into-c` (the failure a panic out of the entry point:
  Rust aborts it uncoded at the `extern "C"` boundary) is killed by the
  coded expectations of cb-failure-is-fatal.
* **A library's host** gets the message on standard error and exit status
  1: the callback contract makes a failing callback terminal for the
  process, also inside a DLL; this is intentional and distinguishable from
  a crash (a coded line, a status of 1, not an exception code).
* **No SEH recovery**: an access violation or other structured exception
  in C stays outside the callback error model; nothing here catches one
  (the c-access-violation native-status probe still reports the linked
  program's 0xc0000005).
* **Refused before any Botlish code**: THREAD, INACTIVE and STACK are
  decided in `run` before ACTIVE is touched, the segment pushed or an
  argument converted, so a refusal changes no other instance's heap,
  coroutine or transition state on its way to the process's end.

## 15. The fallback plan

The `fallback-roots` cargo feature (a test build: shadow-stack roots, no
frame walk) still refuses callbacks: `SUPPORTED` is `NATIVE_FRAME_ROOTS &&
framewalk::CROSSES_TRANSITIONS`, and `NATIVE_FRAME_ROOTS` is false in that
build on every host. The capability is derived from the walk that exists,
never from a host name: `CROSSES_TRANSITIONS` is true where a walker with
jumps is compiled (x86-64 and AArch64), and the stubs of other
architectures walk nothing. The Windows workflow's `roots` job builds that
driver and runs its Rust tests (the JIT callback tests return early there:
they check `runtime::callback::SUPPORTED`).

## 16. Tests and mutants

### The tests

The callback tests stay in `tests/c-callbacks.test` (42 tests), and every
one runs on Windows where its constraints hold: the fixture
(tests/cffi/callback-fixture.c) is built by MSVC's cl through
tests/ctoolchain.tcl, with tests/cffi/callback-fixture-win64.asm assembled
by ml64 beside it; its threads are `CreateThread`'s, its other stack a
fiber of its own, its sort size `size_t` (a ULongLong under LLP64). New or
changed for this milestone:

* **cb-nested-loop** -- repeated nested round trips, both levels
  allocating and collecting, a String of the outer callback's held across
  each inner C call (the middle callback's roots).
* **cb-nested-in-coroutine** -- the same inside a coroutine's body, fused
  (inlined into its consumer) and unfused (its own stack: a fiber on
  Windows).
* **cb-abi-preserved** -- the Win64 ABI by hand (section 8): ml64's caller
  places eight mixed arguments, the narrow ones with dirty upper bits, with
  a sentinel in every nonvolatile register including XMM6-XMM15, and
  reports which changed.
* **cb-windows-unwind-through** -- Windows' unwinder alone, from C called
  by a nested callback, climbs to both C functions that called back
  (section 9): every function between has a function table entry
  describing its frame.
* **cb-win32-locales** -- kernel32's EnumSystemLocalesEx calling a Botlish
  callback for every locale, its BOOL answers stopping the enumeration
  (section 13), under GC stress too.
* **cb-windows-unwind-check** -- the nested callbacks' executable under
  BOTLISH_NATIVE_UNWIND_CHECK=1 and GC stress: every transition shim and
  entry point unwinds as the jump assumes, every walk's jump counted.
* **cb-refused-stack** -- now on Windows too: a callback C calls on a fiber
  of its own is NATIVE CALLBACK STACK.

`tests/native-library.test`'s **nl-callbacks** and
**nl-callbacks-two-libraries** (section 12) run on Linux and on Windows
(cbhost.dll, the libraries as DLLs); `tests/platform/native-status.tcl`'s
`c-callback` probe (qsort with a Botlish comparator, under GC stress) says
`[true, true]` on every host. Rust tests:
`codegen::callback::windows_objects_describe_every_shim_and_entry_point`
(any x86-64 host: a COFF object made for `x86_64-pc-windows-msvc`, its
`.pdata` covering every shim and entry point -- cross-built), and on Windows
`codegen::jitunwind`'s `jit_callbacks_cross_a_frame_windows_cannot_unwind`
(a JIT program whose callback is called by an assembly frame without a
function table entry, collecting at every allocation under the forced
unwind check) and `jit_callback_code_is_in_the_function_table`.

### The fuzzer

`audit/c-callbacks/tools/fuzz.tcl` keeps its independent C oracle: one to
sixteen parameters of mixed classes (integer boundaries of every C width,
raw floating patterns, pointers), register and stack positions, repeated
and nested calls, allocating callbacks, several callback declarations per
program. About half its programs now call the drivers from a coroutine's
body, one per segment after its first yield, and those also run on
`cranelift-unfused`, so the general runtime's own stack (a fiber on
Windows) is below the callbacks. Invalid activation (another thread,
another stack, a retained pointer, a call inside a callback) ends the
process by design, so it is exercised by c-callbacks.test's refusal tests,
each in a child process, not by the fuzzer. On Windows the tier item
`c-callbacks-fuzz` runs seeds 1, 2 and 3, and 9 and 10 under GC stress:
all five passed, 0 disagreements, with the coroutine programs (real
Windows, run 43118788340 at 88a5740c; 7-16 s each). On Linux seeds 11-13 (13 under GC stress) after the coroutine
mode: 0 disagreements.

### The mutants

The brief's 27 mutations, each a mutant of `audit/c-callbacks/tools/
mutants.txt` (14 of them new and `%% windows-x86_64`, four new and run on
every host, the rest the catalog's since C-CALLBACK-MILESTONE-1.md), with
the test of its contract that kills it on Windows. The GC mutants
(2-8, 13-16) are killed by a value collected while still in use -- a
wrong answer or a crash of the test's program -- or by the jump's own
check of the record, never by an assertion that callbacks are enabled. A
mutant that does not build is reported NOT-BUILT by the harness, never
killed.

| # | the brief's mutation | catalog mutant (audit/c-callbacks/tools/mutants.txt) | Windows verdict | killed by |
|---|---|---|---|---|
| 1 | restore Windows' refusal | windows-callbacks-refused | W1 | every callback test (NATIVE CALLBACK UNSUPPORTED) |
| 2 | ignore callback segments in the walk | windows-walk-ignores-segments | W2 | cb-nested-gc, cb-nested-loop: a held value collected |
| 3 | resume from the wrong transition | windows-jump-to-innermost-transition | W3 | cb-nested-gc: the outer callback's walk resumes in the middle frames |
| 4 | the outermost transition instead of the innermost | windows-jump-to-outermost-transition; actor-outermost-transition | W4 | cb-nested-gc, cb-nested-loop: the middle callback's values collected |
| 5 | a temporary helper frame for the continuation | transition-records-helper-frame | W5 | NATIVE CALLBACK BUG at the first collection in a callback |
| 6 | an incorrect RSP | windows-transition-records-stack-pointer | W6 | the jump's check (the record's return address is no Botlish code) |
| 7 | an incorrect RIP | windows-continuation-wrong-rip | W7 | no safepoint at the continuation: the waiting frame's roots unvisited |
| 8 | incorrect stack-map offsets after the jump | windows-continuation-wrong-rsp | W8 | the waiting frame's slots read a word off: values collected |
| 9 | a transition from another stack | stack-unchecked | W9 | cb-refused-stack (a fiber of the fixture's) |
| 10 | a callback on another thread | thread-unchecked | W10 | cb-refused-thread (CreateThread) |
| 11 | activation left set during the callback | activation-kept-during-callback | W11 | cb-refused-inside-callback |
| 12 | activation not restored after return | activation-lost-after-callback | W12 | cb-decisions, cb-qsort, cb-scalars, ... |
| 13 | a callback segment left after return | segment-not-popped | W13 | the next collection's jump into frames gone |
| 14 | the foreign-call safepoint removed | foreign-call-not-safepoint | W14 | cb-nested-gc: the waiting frame's values in no stack map |
| 15 | the waiting caller's roots omitted | windows-waiting-caller-skipped | W15 | cb-nested-gc, cb-exposure-survives |
| 16 | a middle callback's roots omitted | windows-middle-callback-roots-skipped | W16 | cb-nested-gc, cb-nested-loop: level1's held String |
| 17 | no unwind information for the entry point | windows-entry-point-unwind-dropped | W17 | cb-windows-unwind-check, cb-windows-unwind-through |
| 18 | no unwind information for the shim | windows-shim-unwind-dropped | W18 | cb-windows-unwind-check |
| 19 | JIT unwind information not registered | windows-jit-callback-code-unregistered | W19 | the Rust test jit_callback_code_is_in_the_function_table |
| 20 | System V instead of Win64 for the entry | entry-system-v-convention | W20 | every callback test with an argument |
| 21 | mixed arguments past the fourth misplaced | arguments-past-fourth-swapped | W21 | cb-abi-preserved, cb-mixed-abi, the fuzzer |
| 22 | a nonvolatile XMM register clobbered | windows-xmm6-clobbered | W22 | cb-abi-preserved (the sentinel in XMM6) |
| 23 | raw floating values converted | raw-float-argument-promoted; raw-result-through-double; raw-nan-canonicalized | W23 | cb-raw-floats, cb-abi-preserved |
| 24 | a retained callback treated as active | activation-kept-after-call | W24 | cb-refused-retained |
| 25 | a callback error unwinding into C | failure-panics-into-c | W25 | cb-failure-is-fatal, cb-executable-failure |
| 26 | an invalid _Bool accepted | bool-argument-unchecked | W26 | cb-refused-arguments |
| 27 | a callback entering the wrong DLL instance | library-wrong-instance | W27 | nl-callbacks (cbhost.dll's two instances) |
MUTANTS-WINDOWS

On Linux (real Linux, this container): the five new mutants that run on
every host, all killed (arguments-past-fourth-swapped by cb-abi-preserved,
cb-mixed-abi and the fuzzer; bool-argument-unchecked by
cb-refused-arguments; failure-panics-into-c by cb-failure-is-fatal and six
others; library-wrong-instance by cb-refused-retained and nl-callbacks;
running-stack-ignores-entry-stack by nl-callbacks), and the ten existing
mutants of the code this milestone changed -- activation-kept-after-call,
activation-lost-after-callback, activation-kept-during-callback,
thread-unchecked, actor-outermost-transition, stack-unchecked,
walk-reads-c-frames, segment-not-popped, transition-not-popped,
foreign-call-not-safepoint -- all killed. The other audits' mutants that
this milestone's edits touched were updated to apply again (the
native-library catalog's public-unwind-dropped, the windows-unwind
catalog's two walk-suspended mutants); `tools/mutant-catalogs.tcl`: 106
catalogs, 3651 mutants, 0 problems.

## 17. Performance

`bench/c-callbacks.tcl` (C-CALLBACK-MILESTONE-1.md's harness, extended):
each scenario a linked executable of the callback fixture's program, best
of RUNS executions, compilation and linking excluded; C's loops in C, a
Botlish loop's per-call cost its loop minus the same loop without the call
(so the two loop-differential rows, `botlish-call` and `c-plain`, are
noise around 0 at these sizes). New scenarios: `collecting` (a List of 40
Strings per callback: collections inside callbacks, their walks crossing
the transition) and `in-coroutine` (the callback loop made by a coroutine's
body on the general runtime: its own stack, a fiber on Windows). On Windows
the fixture is MSVC's, and a last line measures the rejected alternative A
(section 4). `bench/native-library.tcl` gained a DLL callback scenario:
an export of a library whose callback C calls 100 times per call.

### Windows (real Windows)

WINDOWS-BENCH

### Linux, and the milestone's effect there (real Linux)

This container, `cranelift`, N = 2,000,000, best of 7 (ns per call; the
allocation columns are per call):

| scenario | ns/call | allocs | bytes | collections |
|---|---:|---:|---:|---:|
| transition (no callback) | 5.1 | 0 | 0 | 1 |
| callback-int | 13.6 | 0 | 0 | 0 |
| callback-decision | 13.8 | 0 | 0 | 0 |
| raw-float-in | 44.2 | 1 | 16 | 30 |
| raw-double-in | 44.3 | 1 | 16 | 30 |
| raw-inspect | 72.5 | 1.33 | 32 | 61 |
| raw-admit | 76.9 | 2 | 32 | 61 |
| nested-2 | 34.0 | 0 | 0 | 0 |
| allocating | 92.4 | 2 | 71.9 | 137 |
| collecting (N/40 calls) | 4607 | 83 | 2900 | 161 |
| in-coroutine | 13.4 | 0 | 0 | 0 |

Under GC stress (a collection at every allocation; N = 20,000, best of 3)
a callback that allocates once (raw-float-in) costs 222 ns against 44: a
collection inside a callback, its walk across the transition included,
about 180 ns here; `collecting`'s 83 collections per call about 400 ns
each, over a larger heap.

Against the branch's base (73c32da8, built in a private worktree, the same
container and runs; two rounds each), and with the two trees' drivers
swapped (`BOTLISH_NATIVE_BIN`: each tree's programs and fixture on the
other's runtime) to tell the runtime's share from the generated program's:

| scenario | base | base programs, new runtime | new programs, base runtime | new |
|---|---:|---:|---:|---:|
| transition | 10.7, 10.9 | 11.9, 11.5 | 6.6, 5.6 | 4.7, 5.1 |
| callback-int | 12.9, 12.8 | 13.6, 13.9 | 12.8, 12.6 | 13.4, 13.6 |
| nested-2 | 30.3, 30.8 | 34.2, 32.0 | 30.8, 31.2 | 34.3, 34.0 |

* The transition's row follows the *programs*, not the runtime: the naked
  `rt_ffi_open` (section 4, B') costs nothing measurable, and the
  difference between the two program sets is the derived differential's
  sensitivity to the generated loop (the programs' shared header gained two
  functions).
* A callback follows the runtime: about +0.7 ns per callback
  (callback-int), +1 to +3.5 ns for nested-2's two callbacks and one
  transition. What changed on Linux's callback path is `Vm::running_stack`
  consulting `entry_stack` first (the defect fix of section 10) and the
  trampoline's extra jump; the measurement was not taken below that
  granularity, so no finer attribution is claimed.

## 18. CI

Every run below is of the branch `ccr-ded2e6b6-05sy19`. A branch push
runs only each test workflow's canary (the files the branch changes, then
the ones that failed recently on that host); the rest was dispatched
(`workflow_dispatch` on the branch), the Windows workflow with `tier:
full` and the milestone's tier items (`tests:`). A newer push or dispatch
on the branch cancels a running test workflow, so the runs that count are
the last ones at each commit.

**At 0091882e** (the implementation, pushed with `[ci-full]` and
`CI-Tests: c-callbacks.test native-library.test rust`):

* Windows canary, run 43112406174: c-callbacks.test (all 42, the
  Windows-only ones included), native-library.test (nl-callbacks,
  nl-callbacks-two-libraries) and the other files the branch changes --
  Total 594, Passed 498, Skipped 96, Failed 0 (real Windows). Its full
  shards were cancelled by the next push.
* Linux arm64 canary, run 43112406126: 286 tests, 0 failed, c-callbacks
  and native-library among them (real Linux arm64).
* macOS smoke, run 43112406310: the Rust tests, native-status.tcl (the
  `c-callback` probe), the smoke tier and the canary passed (real macOS);
  its ubuntu control's native-status passed.

**At fcd7aca4** (mutants, fuzzer, benchmark, documentation): dispatched
runs 43115329429 (Windows), 43115333575 (tests), 43115337678 (Linux
arm64), 43115341967 (macOS). The Windows canary passed (23:00-23:12
UTC), the Linux x86-64 canary passed; both were superseded by the next
push before their other jobs finished. icy-tower (windows x86-64), run
43115316258: success.

**At 88a5740c** (main merged in; the fuzzer's coroutine mode; the
middle-callback mutant; the mutant harness's `-first 1`; the benchmark's
GC-stress run): dispatched runs 43118788340 (Windows: `c-callbacks-fuzz`,
the 14 Windows-only mutants and the 2 library mutants), 43118793329
(tests), 43118797190 (Linux arm64), 43118801019 (macOS). What finished
before the next push superseded them:

* Windows: the canary passed (23:31-23:44 UTC; 594 tests, 0 failed, the
  unwind check's account above); the root plans job passed (the fallback
  plan's Rust tests and GC workloads); the fuzzer passed on every seed,
  1-3 and 9-10 under GC stress, its coroutine programs included (real
  Windows). The mutant run exposed a defect of the harness, not of the
  callbacks: it read the test files' output with `-translation lf`, and on
  Windows every failing test's line kept its carriage return, so the
  test-file detector reported every mutant surviving --
  windows-callbacks-refused too, which ends every callback. The fuzzer and
  the Rust tests, parsed otherwise, still killed nine (windows-callbacks-
  refused, windows-jump-to-innermost-transition, windows-continuation-
  wrong-rsp, windows-transition-records-stack-pointer and
  transition-records-helper-frame by the fuzzer, the last four only under
  GC stress; windows-walk-ignores-segments and
  windows-jit-callback-code-unregistered by the JIT's Rust tests;
  windows-entry-point-unwind-dropped and windows-shim-unwind-dropped by
  the COFF test). Fixed in 4499c79e (`-translation auto`, as the other
  mutation harnesses read their pipes).
* Linux x86-64: the canary (00:16-00:20) and the native Rust unit tests
  passed.

**At 4499c79e** (the harness fixed; `Defined::entry_point`, a field only a
test read, removed): dispatched runs 43135863896 (Windows: `c-callbacks-
fuzz`, all 29 mutants of the brief's table and the 2 library mutants,
`c-callbacks-bench`, `native-library-bench`), 43135867330 (tests),
43135870665 (Linux arm64), 43135873858 (macOS).

* Windows canary: passed (03:26-03:34 UTC).
* Windows smoke: passed (04:36-05:19) -- the native Rust unit tests (the
  JIT callback tests and the COFF test among them), the native stack
  guard checks, native-status (the `c-callback` probe: `[true, true]`
  under GC stress), the GC workloads under GC stress and under the unwind
  check, the smoke tier and the Windows-relevant test files
  (c-callbacks.test among them), the native libraries' DLL hosts
  (native-library.test: nl-callbacks, nl-callbacks-two-libraries), the
  filesystem and the variadic C calls under GC stress.

RUNS-FINAL

## 19. Remaining limitations

* **No retained registrations**, unchanged: a window procedure, a timer, a
  thread-pool or IOCP completion callback, a message hook -- anything that
  keeps the pointer -- is INACTIVE when called later. They need a
  registration lifetime and an execution authority of their own
  (C-CALLBACK-MILESTONE-1.md, sections 11 and 14).
* **No cross-thread callbacks**: a callback C calls on another thread is
  THREAD.
* **A failure ends the process**, by design, also a DLL's host.
* **No SEH recovery**, by design.
* **The fallback root plan refuses callbacks** (section 15).
* **Windows ARM64**: no native backend there at all.
* **A stored pointer after a DLL unload** is undefined behavior of the
  host's (section 12): the runtime cannot tell a stale pointer to unmapped
  code from any other.
* **`run`'s body must keep one stack pointer** (no `alloca`-like growth):
  the Windows segment's entry is that stack pointer. A future change that
  allocated dynamically on `run`'s stack would break the match;
  BOTLISH_NATIVE_UNWIND_CHECK's `check_entry_frame` and every GC-stress
  callback test would catch it.


## 20. Files changed, and what to run

**The runtime.**

* `native/src/runtime/callback.rs`: `SUPPORTED` is `NATIVE_FRAME_ROOTS &&
  framewalk::CROSSES_TRANSITIONS`; `rt_ffi_open` is a naked trampoline on
  x86-64 (System V, Win64) and AArch64 handing the shim's frame register to
  `rt_ffi_open_at`, which runs the transition check under
  BOTLISH_NATIVE_UNWIND_CHECK on Windows; `run` runs the entry-point check;
  `Fatal::terminate` reports through `platform::report_fatal` on Windows
  too; `entry_frame_function`; the module doc's stale `Vm::program_token`
  claim replaced by what holds.
* `native/src/runtime/framewalk.rs`: `CROSSES_TRANSITIONS`; the Windows
  `walk`, `walk_from`, `walk_segmented`, `walk_from_segmented` with jumps;
  `windows::walk_context`'s jump case, `jump`, `transition_failed`,
  `check_entry_frame`, `check_transition`, `check_entry_point`, their
  counters, `transition_counts`, the summary's extension.
* `native/src/runtime/platform/windows.rs`, `platform/mod.rs`: Windows'
  `report_fatal`.
* `native/src/runtime/vm.rs`: `running_stack` prefers `entry_stack`;
  `framemap()` (Windows).

**Code generation.**

* `native/src/codegen/callback.rs`: `Defined` (id, size, UNWIND_INFO) for
  every shim and entry point, in `Symbols::callback_code`; the cross-built
  `.pdata` test.
* `native/src/codegen/clif.rs`: `Symbols::callback_code`.
* `native/src/codegen/mod.rs`: `add_windows_unwind` writes them;
  the JIT passes them to the function table.
* `native/src/codegen/jitunwind.rs`: `define_unwind_data`, `register` take
  them; the Windows JIT tests of callbacks (an assembly caller with no
  function table entry, the function table's entries).

**Capabilities and documentation of them.** `native/native.tcl`
(`cCallbacks` names windows-x86_64), `tests/helpers.tcl`,
`tests/platform/native-status.tcl` (the `c-callback` probe, every host's
row), `AGENTS.md` ("C callbacks (callback c fn)"), Compilerpedia
(`error.native-callback`, `concept.c-callbacks`, `backend.native-library`),
`docs/C-CALLBACK-MILESTONE-1.md`, `docs/WINDOWS-X86-64-MILESTONE-3.md`,
`docs/WINDOWS-X86-64-MILESTONE-8.md`, `docs/INDEX.md`.

**Tests, fixtures and tools.** `tests/c-callbacks.test` (the Windows
fixture build, `otherStackHost`, `windowsHost`, `cbRunClean`, qsort's
size_t, cb-nested-loop, cb-nested-in-coroutine, cb-abi-preserved,
cb-windows-unwind-through, cb-win32-locales, cb-windows-unwind-check),
`tests/cffi/callback-fixture.c` (Windows threads and fibers, the ABI
wrapper, the unwinder trace, the locale bookkeeping, the rejected
alternative's measurement), `tests/cffi/callback-fixture-win64.asm` (new),
`tests/cffi/cbx.bot`, `tests/native-library.test` (`nlCallbackHost`,
nl-callbacks, nl-callbacks-two-libraries), `audit/c-callbacks/tools/`
(mutants.txt's Windows section and generic additions; mutate.tcl's Windows
host, `-match`, `-first`, `lsp/` and `-translation auto`; fuzz.tcl's
toolchain and coroutine programs), `audit/native-library/tools/mutants.txt` and
`audit/windows-unwind/tools/mutants.txt` (three mutants' text moved),
`bench/c-callbacks.tcl`, `bench/native-library.tcl`,
`tests/platform/tier.tcl` (the `c-callbacks-*` items; the bench item's
GC-stress run).

**What to run** (AGENTS.md, "C callbacks (callback c fn)"):

    tclsh9.0 tests/c-callbacks.test                       # every host
    tclsh9.0 tests/native-library.test -match nl-callbacks*
    cargo test --release --manifest-path native/Cargo.toml callback
    tclsh9.0 audit/c-callbacks/tools/fuzz.tcl -n 4 -seed S [-gc-stress 1]
    tclsh9.0 audit/c-callbacks/tools/mutate.tcl [-first 1] [-only NAMES]
    tclsh9.0 audit/c-callbacks/tools/mutate.tcl -first 1 -tests "tests/c-callbacks.test tests/native-library.test" -match "cb-* nl-callbacks*" -only library-wrong-instance,running-stack-ignores-entry-stack
    tclsh9.0 tests/platform/native-status.tcl
    tclsh9.0 tools/mutant-catalogs.tcl
    tclsh9.0 bench/c-callbacks.tcl [-gc-stress 1 -n 20000 -runs 3]
    tclsh9.0 bench/native-library.tcl

On Windows, the Windows workflow dispatched on the branch with `tier`
full and `tests` naming the tier items: `c-callbacks-fuzz`,
`c-callbacks-mutants=...`, `c-callbacks-library-mutants=...`,
`c-callbacks-bench`, `native-library-bench` (or a `[ci-full]` push with a
`CI-Tests:` trailer); its smoke job runs the Rust tests (the JIT callback
tests among them) and native-status, its acceptance shards every test file.
