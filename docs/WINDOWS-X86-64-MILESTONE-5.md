# WINDOWS-X86-64-MILESTONE-5.md

Milestone 5 of the Windows x86-64 port: native coroutines on Windows. The
census is WINDOWS-TOOLCHAIN-CENSUS.md; the milestones before it are
WINDOWS-X86-64-MILESTONE-1.md (the driver, executables, the fallback root
plan), WINDOWS-X86-64-MILESTONE-2.md (C calls, Windows I/O),
WINDOWS-X86-64-MILESTONE-3.md (unwind information, native-frame roots) and
WINDOWS-X86-64-MILESTONE-4.md (the stack guard). The coroutines are
COROUTINES.md's, the same ones that run natively on Linux and on macOS
(MACOS-AARCH64-MILESTONE-3.md). The work was developed on Linux. Every
Windows fact below was observed on GitHub's `windows-2025` runners
(Windows Server 2025, 10.0.26100; rustc 1.99.1 for
`x86_64-pc-windows-msvc`), through two workflows:

* `.github/workflows/windows-x86_64.yml`, which runs the production code;
* `.github/workflows/windows-coroutines-probe.yml`, which runs the
  experiments: `audit/windows-coroutines/probe`, a program of its own that
  uses no botlish-native code.

No Wine and no WSL were used.

> On Windows, as on Linux and macOS, a coroutine runs on a native stack of
> its own. The stack is a Windows fiber with its own stack guarantee. Its
> frames are GC roots while it runs and while it is suspended, and when it
> is exhausted the run ends in NATIVE LIMIT STACK.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (run and job named);
* **controlled experiment**: a test, a probe build or a measurement run on
  purpose (where: Linux, or a Windows runner);
* **cross build**: compiled on Linux for `x86_64-pc-windows-msvc` and
  type-checked (`cargo check --all-targets`, with and without
  `fallback-roots`), never run there. This shows only that the code builds;
* **other hosts**: Linux x86-64 and AArch64 and macOS AArch64, where the
  code this milestone shares with them runs;
* **code inspection**: what the code does, read, not run.

Commits are named by their hashes on the branch `ccr-84695215-ngembr`,
where every CI run below ran.

## Contents

1. Result
2. Architecture comparison
3. Selected implementation
4. Windows state
5. Stack guard
6. GC correctness
7. Ownership and errors
8. Tests
9. Performance
10. Remaining limitations
11. Next milestone recommendation

## 1. Result

PENDING-RESULT

## 2. Architecture comparison

### 2.1 What a Windows stack is

On Linux and macOS a coroutine stack is memory plus registers. The switch
(runtime/coroutine.rs's `bl_co_switch`) saves the callee-saved registers on
the stack it leaves, stores the stack pointer and loads the other one.
Nothing in the system needs to know which stack is running.

On Windows the thread environment block (TEB) describes the running stack,
and Windows reads that description:

| TEB field | Offset (x64) | Documented | What reads it |
|---|---:|---|---|
| NT_TIB `StackBase` | gs:0x08 | yes (winnt.h) | stack growth, `GetCurrentThreadStackLimits`, exception dispatch's checks of every frame's stack pointer, Rust's and the C runtime's stack probes |
| NT_TIB `StackLimit` | gs:0x10 | yes | the same; it moves down as the guard page commits the stack |
| NT_TIB `FiberData` | gs:0x20 | yes (`GetCurrentFiber`) | the fiber API |
| `DeallocationStack` | 0x1478 | no | the reservation's low end: the low bound `GetCurrentThreadStackLimits` reports, and where the guard page may still go |
| `GuaranteedStackBytes` | 0x1748 | no | `SetThreadStackGuarantee`: the room the memory manager commits before it raises `STATUS_STACK_OVERFLOW` |

A switch that keeps only the registers leaves every field above
describing the other stack. Milestone 4 listed the fields such a switch
would have to exchange (WINDOWS-X86-64-MILESTONE-4.md, section 10). It
also named the alternative: Windows' own fibers, whose switch
(`SwitchToFiber`) is documented to keep them. Choosing between the two
was the first experiment.

### 2.2 The experiments

`audit/windows-coroutines/probe` (commit 3533b7fd, real Windows: run
[40120109347](https://github.com/mwagner-webdev/botlish/actions/runs/40120109347),
image 20261021.278.1) runs each scenario in a child process of its own,
with a 60-second limit, so that a crash is an exit status and never ends
the probe. It covers:

* **Fibers (A):** `ConvertThreadToFiberEx`, `CreateFiberEx`,
  `SwitchToFiber` and `DeleteFiber`. They ran from three kinds of
  threads: a Rust `std` thread, a raw `CreateThread` thread with no Rust
  runtime, and the process's main thread.
* **A custom Win64 switch (B):** a hand-written switch in the shape of the
  POSIX one. It saves RBX, RBP, RDI, RSI, R12–R15, XMM6–XMM15, MXCSR and
  the x87 control word, and exchanges stack pointers. It ran in three TEB
  modes:
  - mode 0 writes no TEB field;
  - mode 1 also exchanges NT_TIB's documented `StackBase` and `StackLimit`;
  - mode 2 also exchanges the undocumented `DeallocationStack` and
    `GuaranteedStackBytes`.

  Its stacks are `VirtualAlloc` reservations laid out as Windows lays out
  a fiber's: a committed top, a guard page and an uncommitted reservation
  below.

Every scenario names its probe: the scenario names printed in the run's
log. The exhaustion scenarios install a vectored handler first in the
chain. It records what arrives (code, flags, parameters, the faulting
address, the stack bounds Windows reports in the handler) and how much
stack the handler has left. Then it ends the process with exit status
0x42, as the production guard ends it.

### 2.3 Fibers

All of the following is real Windows from run 40120109347.

**Conversion:**

* After `ConvertThreadToFiberEx`, `IsThreadAFiber` is true, and NT_TIB's
  `FiberData` (`GetCurrentFiber`) is the value the conversion returned.
* A second conversion returns null with error 1280 (ERROR_ALREADY_FIBER).
* Converting changes neither the thread's limits nor its guarantee:
  - the `std` thread keeps 20480 bytes, Rust's;
  - the raw thread keeps 0;
  - the main thread keeps 20480.
* `ConvertFiberToThread` restores everything: `IsThreadAFiber` false, the
  same limits and the same guarantee.

**A fiber's stack.** These facts come from the stack's first entry, then
again after a round trip to the thread:

* `CreateFiberEx(64 KiB, 8256 KiB)` reserves exactly 8256 KiB.
  - While the fiber runs, `GetCurrentThreadStackLimits` and NT_TIB both
    describe that reservation.
  - Its guard page is in place (PAGE_GUARD directly above the uncommitted
    reservation), and 76 KiB are committed.
  - When the thread runs again, it sees its own stack again.
* **A fiber starts with no stack guarantee (0).**
  `SetThreadStackGuarantee(32768)` on the fiber succeeds, and the guarantee
  stays the fiber's: it is 32768 when the fiber is entered again, while the
  thread's own guarantee is unchanged (20480 on the `std` thread, 0 on the
  raw thread).
* Two MiB of recursion on the fiber grow it by its guard page.
  `StackLimit` moves down, the guard page moves with it, and 2472 KiB end
  up committed.
* After `DeleteFiber` of a suspended fiber, its reservation is free.
* With the default sizes (`CreateFiberEx(0, 0)`) a fiber gets 1024 KiB of
  reservation and 16 KiB of commit.

**Registers and floating-point state.** Every Win64 callee-saved register
was loaded with a distinct pattern around three rounds of switches, on
both sides: RBX, RBP, RDI, RSI, R12–R15 and both 64-bit halves of each of
XMM6–XMM15. None changed, with `FIBER_FLAG_FLOAT_SWITCH` and without it.
MXCSR and the x87 control word are state of their own:

* the fiber set 0x7f80 and 0x7f;
* the thread saw its own 0x1f80 and 0x27f afterwards;
* the fiber found its own values again after a round trip.

This held in both flag modes on this image. The documented contract is
that only `FIBER_FLAG_FLOAT_SWITCH` saves the floating-point state, so
production asks for it.

**TLS, FLS and errno:**

* A fiber shares the thread's Rust `thread_local!`s and `TlsAlloc` slots
  (it saw 7 and 11; the thread then saw the fiber's 8 and 12).
* Fiber-local storage (`FlsAlloc`) and the C runtime's `errno` are per
  fiber:
  - the fiber saw 0 for both;
  - the thread kept 21 and 31 while the fiber set 22 and 32;
  - the fiber found 22 and 32 again after a round trip.
* `DeleteFiber` ran the fiber's FLS callback exactly once, with its last
  value.

**Calls:**

* On a fiber, all of these work:
  - Rust's allocator and formatting (1000 strings);
  - MSVC-compiled C through int, double and pointer arguments (a 64-bit
    product, 6.25, 12288);
  - a Rust panic caught on the fiber;
  - a Rust panic caught on the thread between two of the fiber's segments.
* C recursion that grows the fiber's stack after a suspension completes:
  20000 frames, 64 bytes each.

**Virtual unwind** (`RtlLookupFunctionEntry` and `RtlVirtualUnwind`, the
collector's walk since milestone 3):

* *From inside a fiber whose start routine is an ordinary function:* four
  frames — the probe's two frames, then KERNELBASE+0x107800 and
  ntdll+0x3f279 (Windows' fiber start) — ending at a zero return address
  inside the fiber's stack.
* *From inside a fiber whose start routine is an assembly stub with SEH
  unwind directives* (production's `bl_co_fiber_entry`): also four frames,
  ending the same way.
* *A suspended fiber's stack, unwound from the thread:* the walk starts
  from the RIP, RSP and RBP its switch recorded. It climbs 36 frames (32 of
  recursion) to the fiber's start and a zero return address, and the
  switch recorded the right fiber.
* *A fiber restarted 1000 times* from the stub's recorded top (section
  3.3), each time after parking 50 frames deep: the restarted body's stack
  pointer is identical every time (240 bytes below the top, 16-byte
  aligned), and its walk is the same four frames every time.

**Exhaustion.** Every exhaustion of a fiber's stack arrived at the
vectored handler as 0xC00000FD with flags 0 and parameters (1, address),
the address inside the fiber's own reservation. The handler saw the
fiber's limits in every case. The cases were:

* Rust recursion, with small frames and with 64 KiB frames;
* MSVC C recursion, both ways;
* Cranelift's probe loop (a function that only probes);
* the same on a fiber nested inside another fiber.

With the fiber's own 32 KiB guarantee:

| Exhaustion | Room left to the handler | Of which dispatch used | Fault above the low bound |
|---|---:|---:|---:|
| Rust recursion | 35520 B | 5328 B | 40944 B |
| Rust, 64 KiB frames | 49536 B | 5312 B | 36864 B |
| C recursion | 35456 B | 5360 B | 40848 B |
| C, 64 KiB frames | 52608 B | 5312 B | 36864 B |
| probe loop | 34048 B | 5344 B | 39392 B |
| nested fiber, Rust | 35520 B | 5344 B | 40944 B |
| nested fiber, probe loop | 34560 B | 5360 B | 39920 B |
| **Rust recursion, no guarantee asked** | **10880 B** | 5328 B | 16368 B |

* A fiber with no guarantee raises the exception about 16 KiB above its
  low bound. That leaves the handler 10.9 KiB, roughly two of the
  guard's own reports (WINDOWS-X86-64-MILESTONE-4.md measured 5.2 KiB per
  report).
* A sweep that used up stack inside the handler before reporting found
  the limits:
  - with 32 KiB guaranteed, 26 KiB of Rust frames or 24 KiB of probe loop
    still reported;
  - with no guarantee, 4 KiB still reported and 6 KiB did not;
  - every step past those ended in 0xC0000005.
* When the handler passed the exception on, or was not installed, Rust's
  own report and 0xC00000FD followed, as for a thread's stack.
* The thread's own stack, exhausted after fibers had run and set their
  own guarantees, still overflowed with the thread's own 32 KiB.

**Lifetime:**

* A fiber whose start routine returns ends the thread, with exit code 0;
  the code after its switch never runs.
* `DeleteFiber` of the running fiber ends the thread, with exit code 1.
* On a thread that something else had already converted (a host's
  conversion), our fibers ran and switched back to the host's fiber, and
  the thread was still a fiber afterwards.
* Twenty thousand fibers were created, entered and deleted one at a time,
  with no growth and no failure.

### 2.4 A custom switch, three ways

Same run. "TEB" means what the switch writes besides the registers and the
stack pointer.

| Probe | Mode 0 (no TEB) | Mode 1 (`StackBase`, `StackLimit`) | Mode 2 (also `DeallocationStack`, `GuaranteedStackBytes`) |
|---|---|---|---|
| callee-saved registers, XMM6–15 | kept | kept | kept |
| MXCSR, x87 control word | per stack | per stack | per stack |
| limits Windows reports on the custom stack | the thread's | [the thread's `DeallocationStack`, the custom `StackBase`): 1.6 TB, wrong | the custom stack's |
| C calls (int, double, pointer; recursion) | **0xC0000005** | work | work |
| growth by the guard page (2 MiB) | **0xC0000005** | works | works |
| a Rust panic caught on it | **uncaught (0xE06D7363)** | caught | caught |
| unwind from inside | 2 frames | 2 frames | 2 frames |
| exhaustion, Rust / C / probe loop | **0xC0000005**, no handler | 0xC00000FD, but the **thread's guarantee** (20480), fault 24 KiB above the low bound, **wrong limits** | 0xC00000FD, 32 KiB guarantee, fault 40 KiB above the low bound, the custom stack's limits |
| round trip | 22.8 ns | 23.0 ns | 23.8 ns |

* **Mode 0** is unusable. Windows takes every access below the thread's
  `StackLimit` that is not the thread's own as an access violation. That
  includes the custom stack's growth, a C function's `__chkstk`, and
  exception dispatch, whose stack checks reject the frames.
* **Mode 1** works until the stack runs out. Then:
  - Windows commits the *thread's* guarantee, not the coroutine stack's;
  - the limits the handler sees span from the thread's reservation to the
    custom stack's top;
  - every bounds-based decision (the guard's own, the collector's walk
    bounds) would be wrong.
* **Mode 2** is correct in every probe, but only because it writes two
  undocumented TEB offsets on every switch. Those are exactly the offsets
  the brief rules out "without a compelling, verified reason".

### 2.5 Cost

Same run, release build, medians of their loops (real Windows):

| Operation | Cost |
|---|---:|
| `SwitchToFiber` round trip (thread → fiber → thread, float switch) | 57.9 ns |
| the production switch's round trip (section 3.4: the record, `SwitchToFiber`, the restart check) | 60.6 ns |
| custom switch round trip, modes 0 / 1 / 2 | 22.8 / 23.0 / 23.8 ns |
| a fiber's life: `CreateFiberEx` of 8 MiB + 64 KiB, first entry, `DeleteFiber` | 14.63 µs |
| a start on a parked fiber (switch, restart at its top, a body that switches back) | 56.5 ns |
| `ConvertThreadToFiberEx` + `ConvertFiberToThread` | 25 ns |

A fiber round trip costs about 35 ns more than mode 2's. A fiber's
creation is about 15 µs, and the pool (section 3.3) pays it once per
pooled stack, not once per coroutine.

### 2.6 The choice

**Fibers.** Each requirement compared:

* **Correctness:** both fibers and mode 2 pass every probe, and the other
  two modes fail as shown.
* **Contract:** a fiber's TEB bookkeeping is Windows' own and documented,
  and it holds wherever Windows reads the TEB, today and in later Windows
  versions. Mode 2's holds only while two undocumented offsets keep their
  meaning on every Windows the product runs on.
* **Cost:** 35 ns per round trip and 15 µs per fresh stack. That is real
  but small beside what a coroutine's segment does, and section 9 measures
  it on whole programs.

No concrete incompatibility showed up:

* the unwinder climbs a suspended fiber's stack from the switch's record;
* a fiber can be restarted, so it can be pooled;
* a fiber's guarantee is its own;
* conversion can be owned.

The custom switch is not kept beside fibers (the brief: "do not maintain
both"). The probe keeps it, as evidence.

## 3. Selected implementation

### 3.1 The seam

The platform layer under the coroutine runtime is the four things
runtime/coroutine.rs's assembly gives Linux and macOS. On Windows they come
from `runtime/coroutine/windows.rs`, and nothing else in the runtime
changed shape:

| Piece | POSIX hosts | Windows |
|---|---|---|
| a stack, `CoStack` | an `mmap`ed region with a PROT_NONE guard | a fiber with its own guarantee (3.2) |
| a fresh start, `prepare` | a trampoline frame on the new stack | a start record for a parked fiber (3.3) |
| the switch, `bl_co_switch` | callee-saved registers pushed, stack pointer exchanged | the running fiber and its frame recorded, `SwitchToFiber` (3.4) |
| where a suspended stack's walk starts | the saved stack pointer (`SwitchPoint = usize`) | the fiber and the switch's frame (`SwitchPoint { fiber, frame, start }`) |

Everything above that seam is the code Linux and macOS run:

* the coroutine states and the transport slot;
* segments (`segment`, `co_body`, `rt_co_yield`);
* releases, failures and cached failures;
* the stack pool (`POOL`, `POOL_LIMIT` 32);
* publication of the arriving stack to the guard;
* the collector's walk of suspended and resumer stacks.

`CoroutineObj`'s fields keep their names (`saved_sp`, `resumer_sp`), now of
type `SwitchPoint`. `STACK_SWITCHING` is true on Windows x86-64 (MSVC), as
on the other three hosts, only together with native-frame roots
(section 7.4).

### 3.2 A fiber's life

`CoStack::new` does five things:

1. **It makes the thread a fiber, if it is not one yet** (`thread_fiber`,
   section 3.5).
2. **It takes a pooled fiber of the requested usable size** when the pool
   has one.
3. **Otherwise it creates a fiber.** The call is `CreateFiberEx` with:
   - the usable size (8 MiB by default,
     `BOTLISH_NATIVE_COROUTINE_STACK_BYTES` as on every host) plus
     `GUARD_BYTES` (64 KiB) reserved;
   - one page committed, a thread's default: Windows commits the rest by
     the guard page as the fiber grows (section 9 measures what a fiber
     commits);
   - `FIBER_FLAG_FLOAT_SWITCH`;
   - the entry stub `bl_co_fiber_entry`, with a `Slot` (the fiber's own
     record) as its parameter.
4. **It switches to the fiber once.** Its first frame, the stub, stores
   its own stack pointer in `Slot.top` and calls `co_fiber_setup`. That
   function, on the fiber:
   - asks the fiber's own guarantee, `SetThreadStackGuarantee(32 KiB)`,
     the guard's `GUARANTEE`;
   - records the stack Windows reports for the fiber
     (`GetCurrentThreadStackLimits`) in the Slot, where `CoStack::bounds`
     reads it (a coroutine object holds the fiber, its Slot and its size,
     not a copy of the bounds);
   - confirms the guard page, as the guard confirms the thread's
     (`confirmed_guard_page`: an uncommitted reservation from the low
     bound, PAGE_GUARD directly above), and that the recorded top is on
     that stack;
   - parks: switches back to its creator, never to continue there.
5. **It checks what the setup found.** A fiber whose guarantee is below
   32 KiB, or that has no confirmed guard page, is deleted, and the start
   fails (`NATIVE BUG`) before any Botlish code could run on it.

The stub is 40 bytes of frame: the shadow space of the call it makes, plus
alignment. Its `.seh_proc`/`.seh_stackalloc`/`.seh_endprologue` directives
give it unwind information. Every frame above it then unwinds into
Windows' fiber start as a fresh fiber's does (the probe's four frames,
section 2.3). The return address its call leaves, `bl_co_fiber_return`, is
an `int3`: nothing ever returns there.

### 3.3 Starts, restarts and the pool

`prepare(stack, p, co)` writes the coroutine to run into the fiber's Slot
and returns a `SwitchPoint` whose `start` names that Slot. The switch to
it (3.4) leaves the start in the thread-local `START`, which every fiber
of the thread shares, and calls `SwitchToFiber`. The parked fiber
continues inside its own last `bl_co_switch`, takes the start and
restarts (`bl_co_fiber_restart`):

1. its stack pointer goes back to `Slot.top`;
2. `bl_co_fiber_return` is pushed, as the stub's call pushed it;
3. it jumps to `co_body(p, co)`, the body every host runs.

Whatever the fiber was parked in is abandoned, as a pooled POSIX stack's
old frames are:

* its setup;
* a finished coroutine's final switch;
* the yield of a coroutine released while suspended.

No frame on a coroutine stack owns a value with a destructor
(COROUTINES.md), so nothing is lost. Every fiber is therefore
restartable, and `CoStack`'s `Drop` pools fibers exactly as the POSIX
`Drop` pools mappings (up to 32 per thread).

The probe restarted one fiber 1000 times with the same result each time:
the same stack pointer and the same unwind (section 2.3). The Rust test
`a_pooled_fiber_starts_again_at_its_top` checks it in production (real
Windows, section 8).

### 3.4 The switch

`bl_co_switch(save, load, transfer)` is never inlined and does three
things:

1. **It records where it leaves.** The record, written to `save`, holds:
   - the running fiber (`GetCurrentFiber`: NT_TIB's `FiberData`, gs:0x20,
     which winnt.h's inline function reads);
   - its own frame's RIP, RSP and RBP, read at its body. A Win64 body
     moves no stack pointer, so these are the values at the call of
     `SwitchToFiber`.
2. **It passes on a start.** When `load` is a start, it sets `START`.
3. **It calls `SwitchToFiber(load.fiber)`.** When this context is
   continued, it checks `START` (a start of this parked fiber restarts it,
   3.3) and returns `transfer`.

The recorded frame is where the collector's walk of a stack that is not
running begins (section 6).

The switch does no publication. As on every host, the side that *arrives*
publishes its stack to the guard, after the switch (`segment`, `co_body`,
`rt_co_yield`; section 5). The pushes of `SwitchToFiber` itself land on
the stack being left, which is still the one published.

### 3.5 Thread conversion and its owner

`SwitchToFiber` needs a fiber on both sides, so the thread that runs
Botlish code must be a fiber. `thread_fiber` handles two cases:

* **The thread is already a fiber** (`IsThreadAFiber`). Something else
  converted it: an embedding, a host. The runtime records `HOSTED` and
  leaves the conversion alone. It never repeats it (which would fail with
  ERROR_ALREADY_FIBER) and never undoes it.
* **Otherwise the runtime converts it** (`ConvertThreadToFiberEx` with
  `FIBER_FLAG_FLOAT_SWITCH`) and records `CONVERTED` with the fiber it
  made. That thread-local's destructor converts the thread back
  (`ConvertFiberToThread`) when the thread ends, but only if the
  conversion was the runtime's and the thread is running on that very
  fiber.

A conversion that fails ends the start with COROUTINE-STATE and the
system's message (section 7.3). The test
`a_thread_made_a_fiber_by_its_host_stays_the_hosts` converts a thread
itself, runs coroutines on it, and checks that the runtime recorded no
conversion of its own and that the thread is still the host's fiber
afterwards. The probe's `host-fiber` scenario is the same on a raw thread.

### 3.6 Deletion

`DeleteFiber` is called in one place: `CoStack`'s `Drop`, for a fiber the
pool has no room for. That fiber is parked, by construction (a coroutine
that is running never drops its own stack, COROUTINES.md's lifecycle).
`Drop` checks it anyway: a fiber that is the running one is never
deleted, and that state aborts with a NATIVE BUG line, because deleting it
would end the thread (probe: exit code 1). A pooled fiber is deleted when
its thread's pool is destroyed. `DeleteFiber` runs the fiber's FLS
callbacks (the C runtime's per-fiber data, section 4) on the deleting
thread and frees the reservation (probe, section 2.3).

### 3.7 Creation failures

* A fiber that cannot be created (`CreateFiberEx` null) fails the start
  with COROUTINE-STATE, naming the reservation and the system's message.
* A fiber whose setup finds no guarantee or no guard page is deleted and
  fails with NATIVE BUG: a Windows that refuses a fiber its guarantee
  breaks the guard's premise and is no program error.

Neither consumes the coroutine: the start fails, as an `mmap` failure
fails it on the POSIX hosts.

## 4. Windows state

What each switch keeps, and where each piece of state lives:

| State | Kept by | Evidence |
|---|---|---|
| RBX, RBP, RDI, RSI, R12–R15 | `SwitchToFiber` (the Win64 callee-saved set) | probe (real Windows); `callee_saved_registers_survive_every_switch`, whose Windows `pattern_call` loads and checks every one around each switch (real Windows, section 8) |
| XMM6–XMM15, both halves | `SwitchToFiber` | the same |
| MXCSR, x87 control word | `SwitchToFiber` with `FIBER_FLAG_FLOAT_SWITCH`, which both the thread's conversion and every fiber ask | probe; `mxcsr_is_part_of_the_context` (a coroutine sets its rounding mode, and the resumer's and the coroutine's own survive each other's segments) |
| NT_TIB `StackBase`, `StackLimit`, the TEB's `DeallocationStack`, `GuaranteedStackBytes` | Windows, per fiber | probe; `a_coroutine_runs_on_a_fiber_of_its_own_with_the_guards_guarantee` (inside a coroutine, `GetCurrentThreadStackLimits` is the fiber's reservation, its guarantee is 32 KiB, and the resumer's are its own again afterwards) |
| the stack guarantee | the fiber's own, asked once at setup and kept by every switch | the same |
| Rust `thread_local!`s, `TlsAlloc` slots | the thread, shared by every fiber of it | probe |
| FLS (`FlsAlloc`), the C runtime's `errno` | the fiber | probe |
| the guard's published stack | the runtime, on arrival (section 5) | `native_stack`'s publication check |

The runtime keeps one piece of state per thread: the stack pool, the
`START` handoff, the conversion record and the Vm's own data. All of it
is in Rust `thread_local!`s or on the heap, so every fiber of the thread
sees the same copy, and that is intended.

The one thing that lives per fiber and that Botlish code could notice is
the C runtime's `errno`. The C FFI reads it right after the call that set
it, in the same function (C-FFI-ERROR-CAPTURE-MILESTONE-1.md), and no
switch can come between them: a yield is a call of the runtime that
switches. A binding therefore reads its own fiber's `errno`, as it reads
its own thread's elsewhere.

Production reads one TEB field, gs:0x20 (`FiberData`). That is what
winnt.h's documented inline `GetCurrentFiber` reads; production writes no
TEB field. No undocumented offset appears in production code (code
inspection: `grep -rn 'gs:\[' native/src` finds that read in
coroutine/windows.rs and once more in a test).

## 5. Stack guard

The guard is milestone 4's vectored exception handler. Three things
changed.

1. **The published stack.** `STACK_LOW`/`STACK_HIGH` became a double
   buffer, as in the POSIX guard (`SLOTS`, `SLOT`). `set_active_stack`
   writes the new reservation to the slot not in use, and one release
   store selects it. An exception at any instruction, a publication's own
   included, therefore reads one consistent reservation. The handler
   claims STATUS_STACK_OVERFLOW only when the faulting address is in the
   *published* stack's reservation, on the guarded thread, not raised by
   software; otherwise the search continues as if the guard did not exist.
2. **Publication on arrival.** The runtime publishes whichever stack it
   arrives on, at the same three points on every host, right after the
   switch:
   - `co_body` publishes the coroutine's stack when a fresh start arrives
     on it;
   - `rt_co_yield` publishes the coroutine's stack when a resume arrives
     back on it;
   - `segment` publishes the resumer's stack (the thread's, or an outer
     coroutine's) when the segment returns to it, whether the coroutine
     yielded, completed or failed.

   `vm.rs`'s `publish_active_stack` now includes Windows. The switch
   itself (3.4) publishes nothing, and nothing publishes before the
   switch.
3. **Every stack the guard can name has the guarantee its report needs.**
   The thread's stack gets it when the guard installs (milestone 4). Every
   fiber gets its own at setup, before any Botlish code runs on it
   (section 3.2): a fiber starts with none, and its guarantee is its own
   (section 2.3), so it cannot be asked once for the thread.

So an exhaustion of any stack that runs Botlish code ends in NATIVE LIMIT
STACK. The stack can be the thread's or any coroutine's, at its start,
after yields, or nested three deep, and the frames that exhaust it can be
Botlish code, the runtime or C. The report is the driver's line with
status 0, or the line on standard error with status 1 from an executable
(real Windows: `native_stack`'s coroutine checks, `native-status.tcl`'s
`coroutine-stack-overflow` probes, `aot-facts.tcl`'s
`standalone-co-overflow`; section 8). NATIVE LIMIT STACK stays terminal:
the handler never resumes, unwinds or switches fibers.

What is not an overflow stays what it is. `native_stack`'s coroutine fault
checks compare each case with the guard installed and without it:

| Fault | Ends with the guard | Without it | Relabeled |
|---|---|---|---|
| a coroutine touches its own reservation's uncommitted pages | 0xC0000005 | 0xC0000005 | no |
| the thread touches a suspended coroutine's reservation | 0xC0000005 | 0xC0000005 | no |
| a coroutine touches the thread's uncommitted reservation | 0xC0000005 | 0xC0000005 | no |
| `RaiseException(STATUS_STACK_OVERFLOW)` on a coroutine's stack | 0xC00000FD | 0xC00000FD | no |

The switch path itself was swept. A child descends to X bytes above where
the stack it is on stops growing (X from 0 to 2 KiB in 16-byte steps), then
switches. That covers the four directions:

* a resume from the thread;
* a fresh start from the thread;
* a resume from inside a coroutine;
* a yield back to it.

Wherever the switch's own frames meet the end of the stack — the
runtime's, `SwitchToFiber`'s, the arriving side's — the run either
completes or ends in the overflow line, never a crash, and both outcomes
occur in every direction (section 8).

## 6. GC correctness

The collector finds roots in native frames (milestone 3). A coroutine
adds stacks that are not running:

* **A suspended coroutine's stack.** `heap.rs`'s walk of every suspended
  coroutine starts from `suspended_rbp(co.saved_sp)`, which on Windows is
  the frame its switch recorded (section 3.4).
* **A running coroutine's resumer's stack.** `vm.rs` walks the resumers'
  stacks from `resumer_sp`, the same record.

`framewalk::walk_from` builds a CONTEXT at that frame (RIP, RSP, RBP; the
other registers zero, as no frame's unwind reads them) and climbs it with
Windows' unwinder. The climb crosses the switch's Rust frames,
`co_body`'s, the runtime helper that yielded, and every Botlish frame, up
to the fiber's start. It is bounded by that stack's own bounds (the
`NativeStack` the fiber's setup recorded), as the running stack's walk is
bounded by the thread's. A Botlish frame is visited by its stack map, as
on the running stack (`walk_context`, shared).

Lifetime of what the walk reads:

* **JIT code and its function table** (`codegen::jitunwind`) live in the
  `CompiledProgram`, which main.rs keeps for the whole run and drops after
  the Vm. A suspended coroutine's frames are walked only while its Vm
  lives, so the code and the unwind information its return addresses
  name exist whenever a walk can reach them.
* **A pooled fiber's abandoned frames** may name code of a program that
  is gone. Nothing walks or unwinds them: a restart resets the stack
  pointer (3.3), and `DeleteFiber` runs no code on the fiber.
* **An executable's code and unwind information** (`.pdata`/`.xdata`) are
  in its image for the life of the process.

Deterministic missed-root tests:

* **`suspended_root_tests` (codegen/mod.rs, every host).** A NIR program
  whose coroutine holds a list across a yield while a churning coroutine
  and the program allocate. It runs under GC stress (a collection at
  every allocation) with heap poisoning: a freed object's memory is
  overwritten. A root the walk misses is then a poisoned read and a wrong
  value, never a lucky one. The expected value
  (8 + 240 + 320 + 240 + 56) holds only if every live object survived.
  - On Windows the test also forces `BOTLISH_NATIVE_UNWIND_CHECK`, which
    compares every walked Botlish frame with Windows' unwinder, and
    requires the check's count of frames to grow.
  - Controlled experiment (Linux): with heap.rs's walk of suspended
    stacks disabled, the test fails (17601 instead of 1729).
* **The coroutine GC workloads** (`tests/platform/gc-workloads.tcl`:
  `coroutine-roots`, `coroutine-nested`, `coroutine-many`, the programs
  of coroutines.test's GC tests). They run under GC stress and under the
  unwind check, on the general runtime (coroutine fusion off, so the
  coroutine objects and their stacks exist).
* **`a_suspended_stack_unwinds_to_its_fibers_start` (Rust, Windows).**
  Windows' unwinder, from a suspended coroutine's record, climbs only
  inside the coroutine's stack, always upward, and ends at a zero return
  address in that stack.
* **The mutants** `walk-suspended-stacks-skipped`,
  `walk-suspended-with-the-running-bounds`,
  `switch-records-its-callers-stack-pointer` and
  `switch-records-no-frame-register` (audit/windows-unwind; section 8.4).

## 7. Ownership and errors

### 7.1 The affine lifecycle

Nothing about ownership changed: it is static (COROUTINES.md,
AFFINE-VALUES.md), and the native runtime's part is the same code on
every host:

* a construction starts the coroutine eagerly on a fresh or pooled
  fiber;
* resumes run segments;
* the last use releases the handle (`coroutine#release`), and the
  coroutine's fiber goes back to the pool, whatever it is parked in;
* an early exit releases it too.

A suspended coroutine that is released is never resumed: its fiber's next
start restarts at the top (3.3), and its abandoned frames own nothing.
The Rust tests that pin this lifecycle on every host now run on Windows
too (section 8):

* `an_abandoned_suspended_coroutine_is_collected_and_its_stack_pooled`;
* `repeated_lifecycles_map_one_stack_and_reuse_it`;
* `nested_coroutines_run_on_their_own_stacks`;
* `return_before_any_yield_completes_at_the_start`.

### 7.2 Failures

A coroutine that fails reaches the terminal failed state, its error and
payload are cached, and a later resume raises them again
(`a_failure_is_terminal_and_raised_again`,
`error_payload_of_a_failed_coroutine_is_cached_and_raised_again`). This is
`co_body`'s and `rt_co_failed`'s code on every host. NATIVE LIMIT STACK
on a coroutine's stack is no failure: it ends the process (section 5).

### 7.3 Errors of the platform layer

| When | Error |
|---|---|
| `ConvertThreadToFiberEx` fails | COROUTINE-STATE, "cannot make the thread a fiber for its coroutines: SYSTEM MESSAGE" |
| `CreateFiberEx` fails | COROUTINE-STATE, "cannot create a N-byte coroutine stack: SYSTEM MESSAGE" |
| a fiber without the guarantee or the guard page | NATIVE BUG, naming its bounds, its guarantee and whether its guard page was confirmed |
| the running fiber dropped | an abort with a NATIVE BUG line (never reached: 3.6) |

### 7.4 The fallback root plan

The fallback plan (`fallback-roots`) keeps roots in a shadow stack that
frames push and pop in order. A suspended coroutine's slots would sit in
the middle of the resumer's, and the brief rules out making the fallback
coroutine-aware. So:

* `STACK_SWITCHING` is defined as the host's switch *and*
  `NATIVE_FRAME_ROOTS`. A fallback build therefore has no native
  coroutines on any host, and coroutine fusion (which runs only where
  `STACK_SWITCHING` holds) cannot make one run.
* `rt_co_start` refuses with NATIVE UNSUPPORTED when native-frame roots
  are off. The message names the fallback plan.
* `fallback_tests::the_fallback_plan_refuses_native_coroutines` checks
  both (Linux in a fallback build, and the Windows `roots` job).
* The mutant `fallback-runs-coroutines` lifts both refusals. It was killed
  on Linux by that test (controlled experiment, section 8.4).

## 8. Tests

### 8.1 Rust tests of the coroutine runtime

`runtime::coroutine`'s tests are host-independent; they were Linux and
macOS only and now run on Windows too:

* `yields_resumes_and_keeps_its_final_result`;
* `a_failure_is_terminal_and_raised_again`;
* `error_payload_of_a_failed_coroutine_is_cached_and_raised_again`;
* `return_before_any_yield_completes_at_the_start`;
* `collections_inside_and_between_segments_keep_live_values`;
* `nested_coroutines_run_on_their_own_stacks`;
* `an_abandoned_suspended_coroutine_is_collected_and_its_stack_pooled`;
* `repeated_lifecycles_map_one_stack_and_reuse_it`;
* `yield_outside_a_coroutine_is_an_error`;
* `the_stack_pointer_is_aligned_and_on_the_coroutines_stack`;
* `callee_saved_registers_survive_every_switch`. On Windows, a naked Win64
  `pattern_call` loads distinct patterns into RBX, RBP, RDI, RSI, R12–R15
  and both halves of XMM6–XMM15 around each operation, and checks every
  one after it.

Windows' own tests:

| Test | What it holds |
|---|---|
| `a_suspended_stack_unwinds_to_its_fibers_start` | Windows' unwinder, from a suspended coroutine's switch record, climbs only inside that coroutine's stack, always upward, to a zero return address there |
| `a_coroutine_runs_on_a_fiber_of_its_own_with_the_guards_guarantee` | while the body runs, `GetCurrentThreadStackLimits` is the coroutine's own reservation, its guarantee is at least 32 KiB and the thread is a fiber; the resumer's limits and guarantee are its own again afterwards; the two stacks do not overlap |
| `mxcsr_is_part_of_the_context` | a body's rounding mode and the resumer's survive each other's segments |
| `a_pooled_fiber_starts_again_at_its_top` | four lifecycles (released while suspended twice, swept by the collector twice) on one fiber, every body at the same stack pointer |
| `a_fresh_fiber_commits_its_guarantee_and_a_page` | what a fresh fiber commits, and what it keeps after a coroutine ran 64 KiB deep on it (section 9.2) |
| `a_thread_made_a_fiber_by_its_host_stays_the_hosts` | a thread converted by its host stays the host's fiber; the runtime records no conversion of its own |

Every host, including Linux:

* `suspended_root_tests` (codegen/mod.rs): a suspended coroutine's root
  survives other stacks' collections under GC stress with heap poisoning
  (section 6). On Windows it also forces the unwind check.
* `fallback_tests::the_fallback_plan_refuses_native_coroutines`, in a
  `fallback-roots` build.

Results:

* **Other hosts (Linux x86-64):**
  - `cargo test --release --lib --bins`: 299 and 93 passed;
  - the fallback build's refusal test passed;
  - `cargo test --test native_stack`: every check passed.
* **Real Windows:**
  - run 40123395211's `roots` job (48056543): the fallback plan's Rust
    tests, 278 + 96 passed, the refusal among them;
  - the smoke job's Rust tests: PENDING-WIN-RUST.
* **Cross build:** `cargo check --all-targets` for `x86_64-pc-windows-msvc`,
  with and without `fallback-roots`: clean, no warnings.

### 8.2 Exhaustion and faults on coroutine stacks

`native/tests/native_stack/windows.rs` runs every faulting check in a
child process. The coroutine checks:

* **Exhaustion:** a coroutine's own stack exhausted at its start, after
  yields, at the bottom of three nested coroutines, by 64 KiB frames and by
  Cranelift's probe loop. Each case runs in the driver's mode (the line on
  the result file or standard output, status 0); the nested case also runs
  in an executable's mode (the line on standard error, status 1).
* **Faults that are no overflow,** each the same with and without the
  guard (section 5's table).
* **Publication:** at every point of a nested lifecycle, the stack the
  guard reads is the one Windows reports as running.
* **The switch-edge sweep** (section 5): each of the four directions, at
  129 offsets.

Results:

* **Real Windows:** PENDING-WIN-NATIVE-STACK.
* **Other hosts (Linux):** the POSIX checks of the same file pass. The
  sweeps there gave 12/85, 48/49, 12/85 and 6/91 completed/overflowed.

### 8.3 The capability tables and the test files

* **The capability table.** `native/native.tcl`'s `coroutines` row now
  names windows-x86_64. That makes `nativeCoroutines` true on Windows, and
  every Tcl test that carries it runs there:
  - coroutines.test's native and fused comparisons (`coAgree`, the GC
    evidence);
  - coroutine-fusion.test;
  - dfa.test's and dfa-workloads.test's native backends;
  - native-stack-overflow.test's coroutine cases.
* **The golden runner** (a coroutine) now runs every suite on the native
  backends on Windows too.
* **`tests/platform/native-status.tcl`:**
  - the probes `coroutine-general` and `coroutine-stack-overflow-general`
    are new, with fusion off, so that a coroutine object exists;
  - the Windows row expects the general runtime's value and NATIVE LIMIT
    STACK, where it recorded NATIVE UNSUPPORTED.
* **`tests/platform/aot-facts.tcl`:**
  - `standalone-coroutine-refused` is replaced by `standalone-coroutine`
    and `standalone-coroutine-gc`;
  - with fusion off: `standalone-coroutine-general`,
    `standalone-coroutine-unwind-check` (GC stress and the unwind check in
    an executable) and `standalone-co-overflow`.
* **`tests/platform/gc-workloads.tcl`** gains three coroutine workloads
  (`coroutine-roots`, `coroutine-nested`, `coroutine-many`, the programs of
  coroutines.test's GC tests, fusion off). They run under GC stress and
  under the unwind check.
* **The smoke tier** adds coroutines.test, coroutine-fusion.test,
  native-stack-overflow.test and coroutines.bot. `tier.tcl`'s Windows
  `notYet` stays empty.

Results:

* **Real Windows** (smoke, the acceptance tier's four shards,
  system-linker): PENDING-WIN-ACCEPTANCE.
* **Other hosts (Linux):**
  - `tclsh9.0 tests/local.tcl`, the whole local suite: Tcl tests on interp
    7320 passed and on compile 7315 passed, 0 failed; golden suites 108
    run, 0 failed (interp 5180/5180, compile 5180/5180, cranelift-generic
    5088/5088, cranelift 5190/5190);
  - `BOTLISH_NATIVE_GC_STRESS=1 tests/coroutines.test`: 81 passed;
  - `audit/coroutines/tools/fuzz.tcl` (seeds 3, 17, 41, 40 programs
    each): 0 disagreements;
  - gc-workloads.tcl's coroutine workloads pass.

### 8.4 Mutants

| Mutation tool | Mutant | Breaks | Killed on |
|---|---|---|---|
| audit/native-stack | `publish-before-switch` | the stack about to run published before the switch | Linux (native_stack sweeps); Windows PENDING-WIN-MUTANTS |
| audit/native-stack | `start-publishes-thread-stack` | a first segment publishes the thread's stack | Linux; Windows pending |
| audit/native-stack | `resume-not-published` | a resumed coroutine does not publish its stack | Linux; Windows pending |
| audit/native-stack | `yield-not-restored` | the resumer does not publish its stack when a segment returns | Linux; Windows pending |
| audit/native-stack | `fallback-runs-coroutines` | the fallback plan starts native coroutines | Linux (the fallback build's refusal test) |
| audit/native-stack | `win-published-stack-ignored` | the Windows guard reads the stack it was installed with | Windows pending |
| audit/native-stack | `win-fiber-without-guarantee` | a fiber gets no stack guarantee, and none is checked | Windows pending |
| audit/native-stack | `win-fiber-never-pooled` | a fiber is deleted, never pooled | Windows pending |
| audit/native-stack | `win-fiber-not-restarted` | a pooled fiber continues where it parked | Windows pending |
| audit/native-stack | `win-host-fiber-converted-back` | a host's conversion taken for the runtime's | Windows pending |
| audit/windows-unwind | `walk-suspended-stacks-skipped` | the collector never walks a suspended stack | Windows pending |
| audit/windows-unwind | `walk-suspended-with-the-running-bounds` | a suspended stack walked within the running stack's bounds | Windows pending |
| audit/windows-unwind | `switch-records-its-callers-stack-pointer` | the switch's record off by its return address | Windows pending |
| audit/windows-unwind | `switch-records-no-frame-register` | the switch's record without RBP | Windows pending |

* **Linux:** `audit/native-stack/tools/mutate.tcl` (the six above with
  `gc-walk-half-stack`): 6 mutants on linux-x86_64, 6 killed.
* **Linux:** `audit/coroutines/tools/mutate.tcl`'s ten native mutants of
  the runtime and the collector's walks: 10 killed by coroutines.test, the
  fuzzer and the Rust tests:
  - `native-construction-lazy`, `native-first-yield-discarded`,
    `native-completed-raises-exhaustion`, `native-completed-reruns-body`;
  - `native-failed-loses-error`, `native-message-wrong-yield`,
    `native-deep-stack-not-preserved`, `native-release-keeps-stack`;
  - `gc-suspended-frames-untraced`, `gc-resumer-frames-untraced`.
* **Every mutant text** of the native-stack, windows-unwind, coroutines,
  error-payloads, affine and coroutine-fusion mutation tools still applies
  (211 checked).

### 8.5 Linux, Linux AArch64 and macOS

This milestone changes no Linux or macOS code path. On those hosts the
POSIX switch, stack and walk are the code they were, behind `cfg`s. Two
shared changes reach them:

* `STACK_SWITCHING` is now conditioned on native-frame roots, which is
  true there;
* the fallback refusal in `rt_co_start`, a constant check there.

The evidence:

* machine code identical before and after on 31 programs (section 9.5);
* the local suite and the GC-stress, fuzz and mutant runs above (other
  hosts, Linux x86-64);
* CI: tests.yml PENDING-LINUX-CI, tests-arm64.yml PENDING-ARM64-CI,
  macos-arm64.yml PENDING-MACOS-CI.

## 9. Performance

Times are observations of one machine at one moment. The Windows figures
come from a `windows-2025` runner (AMD EPYC 9V74); the Linux ones from this
milestone's development container (Intel Xeon, 2.10 GHz, 4 cores, the same
day). Read a ratio between the two hosts as an order of magnitude, never
as a measurement of Windows alone. The fused rows below run the same
machine code on both, with no switch, and they show the two machines to be
about equally fast.

### 9.1 Coroutine operations

`bench/coroutines.tcl -backends native -runs 5`: the general runtime
(fusion off), 200,000 operations per program, best of 5. Each row is
(program − baseline) / n, the whole program in parentheses.

| Operation | Windows (real Windows, run 40123395211, 48056543) | Linux (controlled experiment) |
|---|---:|---:|
| construction (to the first yield) | 566 ns (567 ns) | 432 ns (433 ns) |
| construction + resume to completion + one cached call | 758 ns (763 ns) | 493 ns (500 ns) |
| resume (yield in the root) | 192 ns (194 ns) | 132 ns (132 ns) |
| resume, yield 1 frame deep | 200 ns (207 ns) | 155 ns (165 ns) |
| resume, yield 8 frames deep | 211 ns (232 ns) | 146 ns (184 ns) |
| resume, yield 32 frames deep | 206 ns (308 ns) | 179 ns (280 ns) |
| resume of a coroutine that resumes one nested in it | PENDING-WIN-NESTED | 211 ns (212 ns) |
| construction, abandoned on an early return | 556 ns (560 ns) | 518 ns (520 ns) |
| construction, abandoned on a fail | 605 ns (694 ns) | 396 ns (453 ns) |
| construction, abandoned on a callee's propagated error | 599 ns (690 ns) | 408 ns (468 ns) |
| construction, abandoned on a break | 568 ns (637 ns) | 432 ns (496 ns) |

* **A resume costs the same at any depth**, on Windows as elsewhere: 192
  to 211 ns from the root to 32 frames deep. Nothing is copied or unwound,
  and the fiber keeps its frames where they are.
* **A resume is about 60 ns dearer than on Linux.** A resume and its yield
  are one round trip. The probe's round trip of `SwitchToFiber` costs
  57.9 ns, against 22.8 ns for a custom switch on the same runner
  (section 2.5). The difference is in that range, and it is the fibers'
  price.
* **A construction is a pooled fiber's start** (56.5 ns in the probe, a
  switch and a restart), plus the runtime's object, thunk and first
  segment. A fresh fiber is about 15 µs (section 2.5); the pool makes that
  once per pooled stack.
* **Destruction** (the abandoned rows) is a release: the coroutine's fiber
  goes back to the pool without running anything on it (section 3.3).

### 9.2 What a coroutine holds

| | Windows | Linux |
|---|---:|---:|
| the coroutine object (allocation report, per construction) | 200 B at 48056543; PENDING-WIN-OBJECT after ceff7aa3 | 96 B |
| the stack's reservation (address space) | 8256 KiB (8 MiB usable + 64 KiB) | 8256 KiB (8 MiB + the PROT_NONE guard) |
| committed by a fresh fiber, after its setup | PENDING-WIN-COMMIT | -- (Linux commits nothing up front: 4.1 KiB resident per suspended coroutine, `bench/coroutines.tcl`'s resident table) |
| committed after a coroutine ran 64 KiB deep on it | PENDING-WIN-GROWN | -- |

* **The coroutine object** carried two `SwitchPoint`s (5 words each, the
  POSIX hosts' are one) and a copy of the fiber's bounds. Commit ceff7aa3
  moved the bounds into the fiber's Slot, which the object points to.
* **The commit** is what Windows charges against the system's commit
  limit, touched or not (section 10). A fresh fiber commits one page, its
  guard page and the guard region the setup's 32 KiB guarantee asks.
  `a_fresh_fiber_commits_its_guarantee_and_a_page` measures it on every
  smoke run and fails above 64 KiB. Before ceff7aa3 a fiber also committed
  its first 64 KiB up front (`CreateFiberEx`'s commit size).

### 9.3 Collections with suspended coroutines

`bench/coroutines.tcl`'s collection rows, under `BOTLISH_NATIVE_GC_STRESS=1`
(a collection at every allocation site). The workload makes 200
constructions while K coroutines are held suspended, and each run is
measured against the same recursion without the constructions. Every one
of the 600 collections walks the K suspended stacks, each from its
switch's record (section 6).

| K suspended | Windows | Linux (controlled experiment) |
|---:|---:|---:|
| 0 | PENDING-WIN-GC0 per collection | 3.3 µs per collection |
| 1000 | PENDING-WIN-GC1000 per collection | 386 µs per collection |
| **per suspended coroutine, per collection** | **PENDING-WIN-GCEACH** | **383 ns** |

### 9.4 The DFA and JSON workloads

`bench/dfa.tcl -runs 3 -rounds 3`, in ns per item (a character, or a byte
for utf8-*), at 200,000 items. "General" is the coroutine runtime
(`BOTLISH_NATIVE_COROUTINE_FUSION=0`), "fused" the default, which compiles
these coroutines into their consumer (COROUTINE-FUSION-MILESTONE-1.md).
Each figure is the median of three driver processes.

| Workload | Windows general | Windows fused | Linux general | Linux fused |
|---|---:|---:|---:|---:|
| coroutine (hand-written JSON-like lexer) | 354.0 | 9.4 | 268.2 | 11.2 |
| dfa-lex (json_lex.bot, RFC 8259's lexical grammar) | 430.8 | 11.8 | 328.3 | 13.0 |
| dfa-validate (the same with the structural layer) | 539.0 | 26.0 | 411.1 | 23.0 |
| yaml-tokens | 426.2 | 17.7 | 327.9 | 20.2 |
| utf8-coroutine | 205.7 | 7.2 | 143.5 | 9.0 |
| utf8-dfa | 203.7 | 6.4 | 151.4 | 7.4 |
| dfa-micro (one recognizer, per symbol) | 202.4 | 3.5 | 139.0 | 4.1 |
| hand-micro (the same by hand) | 209.3 | 2.7 | 155.1 | 4.6 |

(Windows: real Windows, run 40123395211's `roots` job, 48056543. Linux:
controlled experiment.)

* **Fused code is equally fast on both.** It is the same machine code with
  no switch: 9.4 against 11.2 ns per character, the Windows runner slightly
  ahead.
* **The general runtime is 50 to 60 ns per item dearer on Windows**, where
  every item is one switch round trip (dfa-micro: 202 against 139). That is
  the resume's difference of 9.1 again. The DFA workloads that matter run
  fused, at 3.5 to 26 ns per item on Windows. The general runtime remains
  what runs the coroutines fusion cannot take (a handle that leaves its
  function, a recursive yielding chain), and the golden runner.

### 9.5 Programs without coroutines, before and after

**On Windows** (real Windows, run 40123395211's `roots` job): main's driver
before this milestone (b5b17a39, built in the job) was compared with this
branch's on `bench/root-plans.tcl`'s workloads, 20 runs × 7 rounds, under
the JIT and as executables, plus collection cost under GC stress:

| Workload | JIT, this / before | Executable, this / before | Code, `.pdata` + `.xdata` |
|---|---:|---:|---|
| fib | 1.005 | 1.000 | identical (208 B; 48 + 44 B) |
| calls | 0.926 | 0.984 | identical (646 B) |
| uri | 1.029 | 1.014 | identical (6313 B; 408 + 548 B) |
| 2048 | 1.007 | 0.989 | identical (22344 B; 792 + 1196 B) |
| strings | 1.000 | 0.996 | identical (367 B) |
| lists | 1.015 | 1.040 | identical (734 B) |

* The machine code and unwind information are byte-for-byte the same size.
* The checks (Botlish calls checked for an error, prologue depth checks)
  are identical.
* Each ratio lies within its own rounds' spread.
* Collections cost the same: 1.36 against 1.39 µs, 0.84 against 0.86 µs.

**On Linux** (controlled experiment): the same NIR was compiled by main's
driver before this milestone and by this branch's, for 31 programs: the
benchmark programs, the coroutine GC workloads, 2048's benchmark and demo,
the DFA JSON and YAML workloads, the surface examples and the coroutine
golden suite. The machine code (`botlish-native vcode`), the fused NIR
(`fused`) and the stack maps (`roots`) are identical for every one. On
Linux the milestone changes no code a program compiles to, only where the
runtime's Windows code is.

## 10. Remaining limitations

* **A fiber switch costs more than a custom one.** It costs about 35 ns
  more per round trip than the custom switch of mode 2 (section 2.5). Mode
  2 is the only custom switch that was correct, and it writes two
  undocumented TEB offsets on every switch. The price is the documented
  contract (section 2.6); section 9 measures it on whole programs.
* **A fresh fiber costs about 15 µs.** The pool keeps 32 fibers per thread
  (`POOL_LIMIT`, as on every host), so only a program with more than 32
  coroutines alive at once pays it repeatedly.
* **A pooled fiber keeps its committed stack.** Windows commits stack
  pages as a fiber grows and never decommits them. A pooled fiber that
  once grew to 2 MiB keeps 2 MiB charged against the system's commit
  limit (pagefile-backed) until it is deleted. Linux's untouched pages
  cost nothing and touched ones stay resident too, but Windows counts
  commitment up front. Nothing resets a pooled fiber's stack. The
  reservation itself, 8 MiB + 64 KiB per fiber by default, is address
  space only.
* **A host's conversion is the host's.** On a thread that something else
  made a fiber, the runtime switches from and back to that fiber and never
  converts it back (section 3.5). Two consequences:
  - If the host made its fiber without `FIBER_FLAG_FLOAT_SWITCH`, Windows'
    documented contract does not save that fiber's MXCSR and x87 control
    word across our switches. The probe saw them kept even without the
    flag on this image (section 2.3), but production relies on no
    behavior the documentation does not state. A host that needs its
    floating-point state kept should convert with the flag.
  - Executables and the driver run Botlish code on a thread the runtime
    converts itself. An embedding with its own fibers only arises once
    Windows has native libraries (section 11).
* **C code must not switch fibers under Botlish.** Several things on a
  thread that runs Botlish coroutines are unsupported, as is a C library
  that switches the stack pointer under the runtime on any host:
  - a C function called from Botlish that converts the thread back
    (`ConvertFiberToThread`);
  - one that switches to a fiber of its own and returns on another;
  - one that deletes a fiber it did not create.

  None of the C this project calls does that.
* **Coroutines are thread-affine.** A coroutine runs on the thread that
  made it, as on every host. Cross-thread migration of a fiber is out of
  scope (the brief).
* **Interactive consoles are untested.** Every run above wrote the
  overflow line to a pipe or a file, as in milestone 4.
* **Windows on ARM64 and MinGW are not covered.** The backend is Windows
  x86-64 with MSVC's toolchain only (AGENTS.md, "Windows x86-64 (MSVC)").

## 11. Next milestone recommendation

With native coroutines, the windows-x86_64 row of `native/native.tcl`'s
`capabilities` differs from Linux x86-64's in two capabilities. It now
has `jit`, `executables`, `cCalls`, `coroutines`, `stackGuard` and
`frameRoots`, and lacks:

* **`cVariadics`.** Variadic C calls need a Win64 lowering:
  - a double passed in both its XMM register and its integer register;
  - the shadow space;
  - Microsoft's rules for the variadic part.

  The lowering must be checked against MSVC-built callees, as milestone 2
  checked fixed calls (AGENTS.md, "Windows x86-64 (MSVC)"). It is small
  and self-contained: `codegen/clif.rs`'s `c_call_signature`, c-ffi.test's
  `cf-va-*`, a Win64 row in the variadic table. Until then a variadic C
  function (the `printf` family, the C runtime's `_open`) cannot be called
  from Botlish on Windows: a codegen error (`nativeCVariadics`).
* **`libraries`.** Native libraries are Linux glibc's only, on macOS as
  well. A Windows DLL export is a larger design question:
  - export tables;
  - the static C runtime policy across a DLL boundary (milestone 2's
    "never impose the executable's runtime");
  - the stack guard on a caller's thread, where NATIVE-LIBRARY-MILESTONE-1.md
    already records that overflow is process-fatal;
  - and now a host's fibers, section 10.

**The recommendation is Win64 variadic C calls next.** It is the one
capability every other native host has and Windows lacks. It is bounded,
and the evidence it needs (real MSVC callees, a register and stack capture
like fixture-win64.asm's) is the kind milestones 2 and 4 already built. Native
libraries on Windows should follow as their own milestone, together with
macOS's, because their design questions are shared across hosts.
