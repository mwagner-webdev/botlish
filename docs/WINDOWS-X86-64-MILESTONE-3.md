# WINDOWS-X86-64-MILESTONE-3.md

Milestone 3 of the Windows x86-64 port: Windows unwind information for
Botlish machine code, and GC roots in native frames on Windows. The census
is WINDOWS-TOOLCHAIN-CENSUS.md, the milestones before it
WINDOWS-X86-64-MILESTONE-1.md (the driver, executables, the fallback root
plan) and WINDOWS-X86-64-MILESTONE-2.md (C calls, Windows I/O). Developed on
Linux. Every Windows fact below was observed on GitHub's `windows-2025`
runners through `.github/workflows/windows-x86_64.yml`, running production
code (the one probe, strategy B's anchors, is a separate build measured
beside it: section 3.3). No Wine, no WSL.

> Every Botlish function is described to Windows' unwinder, in the
> executable and in the JIT, and the collector finds Botlish roots in
> native frames by crossing Rust frames with that unwinder.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (run and job named);
* **controlled experiment**: a test, a probe build or a measurement run on
  purpose (where: Linux, or a Windows runner);
* **cross build**: compiled on Linux for `x86_64-pc-windows-msvc` and
  type-checked (`cargo check`), never run there -- evidence that the code
  builds, of nothing else;
* **code inspection**: what the code does, read, not run.

## Result

Every Botlish function on Windows x86-64 now has Windows x64 unwind
information. In a COFF object it is a `RUNTIME_FUNCTION` in `.pdata` and its
`UNWIND_INFO` in `.xdata`, which link.exe merges into the executable's
exception directory. In the JIT it is a function table registered with
`RtlAddFunctionTable` for exactly as long as the code exists. On that basis
Windows joins the hosts whose GC roots live in native frames:
`NATIVE_FRAME_ROOTS` is true for `windows-x86_64` (MSVC), and the collector
crosses Rust frames with `RtlLookupFunctionEntry` and `RtlVirtualUnwind` and
reads Botlish frames' roots from their stack maps. Recursion is bounded by a
stack-pointer limit check instead of shadow-stack slots, which also turns
two Windows process deaths into NATIVE LIMIT STACK. The shadow stack remains
the fallback plan, built and tested as such.

```text
Cranelift's UnwindInst (exact)  --codegen::unwind-->  UNWIND_INFO (Windows' own prologue form)
  AOT: cranelift-object's ObjectProduct + .xdata + .pdata (ADDR32NB)  --link.exe-->  exception directory
  JIT: CodeMemory (one reserved range)  +  UNWIND_INFO in the module  --RtlAddFunctionTable-->  until dropped
collection: RtlCaptureContext -> Rust frames by RtlVirtualUnwind | Botlish frames by their frame record
            -> roots at RSP + stack-map offset, keyed by the exact return address
```

| Criterion | Status | Evidence |
|---|---|---|
| A census of what Windows needs and what Botlish had | done | section 1 (code inspection; controlled experiments for Cranelift's encoding) |
| A discovery strategy chosen on evidence | done: Windows' unwinder across Rust frames | section 3: both strategies probed, B's per-call cost measured on Windows |
| Valid AOT unwind metadata, by Microsoft's tool and Windows' APIs | real Windows | dumpbin decodes every Botlish entry; Windows' lookup finds each function at exactly its code and unwinds every Botlish frame of every collection like its frame record (section 7.2) |
| JIT registration with a correct lifetime | real Windows | registered before the code can run, deleted before the code is released, nothing left after (section 2.3, 7.1) |
| Virtual unwinding of JIT and AOT frames | real Windows | at calls, with callee-saved registers restored, and from every instruction of JIT code (section 7.2) |
| Native-frame GC roots on Windows, one capability throughout | real Windows | section 4; the collector's walk checked against Windows' unwinder under GC stress; the GC workloads, the census's programs, the acceptance tier and the full tier under GC stress (section 7.4) |
| A caller's roots never missed | real Windows, Linux, macOS | `a_callers_root_survives_its_callees_collections`; the walk's mutants (section 7.3) |
| Depth and errors: no stack-exhaustion safety lost | real Windows | section 5: every case that ended in NATIVE LIMIT STACK still does, two that killed the process now do too; call effects unchanged |
| The fallback plan preserved and tested | real Windows, Linux | section 6; the `roots` job |
| Hostile tests and mutants | real Windows, Linux | section 7.3 |
| Performance on one runner | real Windows | section 8: in ordinary runs faster than the fallback on a call-bound recursion and within noise on the allocation-heavy workloads; slower on one call-only microbenchmark, as on Linux (not this milestone's mechanism); the walk's cost per collection under GC stress |
| CI: the Windows workflow extended; Linux x86-64, Linux AArch64, macOS | CI | section 7.4, 7.5 |

## Contents

1. Census: what Windows needs and what Botlish discarded
2. Architecture: unwind information, AOT and JIT
3. Discovery strategy: Windows' unwinder against frame anchors
4. GC correctness: the native-frame root path on Windows
5. Depth and overflow
6. The fallback plan
7. Tests
8. Performance
9. Remaining limitations
10. Next milestone

## 1. Census: what Windows needs and what Botlish discarded

### 1.1 What Windows' unwinder reads

A Windows x64 image describes every function that has a prologue -- that
moves RSP or saves a nonvolatile register -- by a `RUNTIME_FUNCTION` in its
exception directory (the linker's `.pdata`): the function's first and
one-past-last byte and its `UNWIND_INFO` (`.xdata`), all three
image-relative 32-bit addresses (`IMAGE_REL_AMD64_ADDR32NB` relocations in
an object). A function without one is a leaf: its return address is at RSP.
`UNWIND_INFO` (version 1) holds the prologue's size, its unwind codes in
reverse order -- each the offset of the end of the instruction it undoes --
and an optional frame register with a frame offset: once the frame register
is set, the unwinder computes the *establisher frame* as `FP - 16 *
FrameOffset`, and every register save (`UWOP_SAVE_NONVOL`, offset scaled by
8; `UWOP_SAVE_XMM128`, by 16) counts upward from it. In an epilogue the
unwinder recognizes `add rsp`/`lea rsp`, `pop`s and `ret` from the code
itself and simulates them. `RtlLookupFunctionEntry` finds a PC's entry (in a
loaded image, or in a table registered at run time with
`RtlAddFunctionTable`, whose addresses are relative to a base the caller
names); `RtlVirtualUnwind` applies it to a `CONTEXT`. Chained unwind
information (`UNW_FLAG_CHAININFO`) describes a function split in several
ranges; Cranelift emits each function in one contiguous range, so none is
needed (code inspection).

### 1.2 What Cranelift computes

Cranelift 0.135.2's x86-64 prologue is the same for every function: its
setup area is unconditional (`isa::x64::abi`'s `compute_frame_layout`), so
even a leaf or a stub that only traps pushes RBP (controlled experiment, a
function compiled for `x86_64-pc-windows-msvc`: `55 48 89 e5 0f 0b`):

```text
  0: push rbp
  1: mov  rbp, rsp                  (48 89 e5)
  4: [inline stack probe loop]      frames over a page (codegen::stack_probes)
     sub  rsp, FRAME                fixed storage + clobbers + outgoing arguments
     mov  [rsp + X + OFF], REG      each clobbered callee-saved register
     ... body: RSP fixed ...
     mov  REG, [rsp + X + OFF]      each, again
     add  rsp, FRAME
     mov  rsp, rbp
     pop  rbp
     ret
```

It describes the prologue as a list of `UnwindInst`s in
`MachBufferFinalized::unwind_info` (public): `PushFrameRegs` at 1,
`DefineNewFrame { offset_downward_to_clobbers }` (the clobber area's size,
a multiple of 16) after the probes and the allocation, and one
`SaveReg { clobber_offset, reg }` per save. That description is complete
and exact (code inspection of `gen_prologue_frame_setup` and
`gen_clobber_save`, and the controlled experiment's disassembly).

Cranelift also encodes it as Windows `UNWIND_INFO`
(`isa::unwind::winx64::UnwindInfo`, `CompiledCode::create_unwind_info` for a
`windows_fastcall` function). That encoding is wrong for any function that
saves a callee-saved register (controlled experiment, decoded by hand and by
LLVM's `llvm-readobj --unwind`):

* the frame offset is written as `offset_downward_to_clobbers << 4` into a
  byte -- a byte count where the field holds sixteens, so for every clobber
  size (a multiple of 16) the field is 0, and the establisher frame is RBP
  itself, above the clobber area;
* a general register's save offset is divided by 16, where
  `UWOP_SAVE_NONVOL` multiplies by 8: the saves at clobber offsets 0 and 8
  both read as slot 0.

For a function saving RSI and RDI with a 16-byte clobber area it emits
`01 12 06 05 | 12 74 00 00 | 0d 64 00 00 | 04 03 | 01 50`: RSI and RDI
restored from `[rbp]`, the caller's saved RBP. RIP, RSP and RBP come out
right (they come from the frame pointer), so a backtrace looks plausible;
every other nonvolatile register of the caller does not.
`codegen::unwind::tests::cranelift_windows_encoding_defect_still_present`
pins the defect. Section 7.2 shows Windows itself restoring the registers
correctly from this milestone's encoding.

### 1.3 What Botlish discarded

| Piece | Before this milestone | Where it went |
|---|---|---|
| `unwind_info` (the prologue description) | computed by Cranelift for every function, never read | `codegen::unwind` encodes it |
| Cranelift's Windows `UNWIND_INFO` | never requested | not used: wrong (section 1.2) |
| `.pdata`/`.xdata` in the object | none: cranelift-object's unwind support writes System V `.eh_frame` only and drops Windows information silently (`unwind::UnwindBuilder::add_function`), and Botlish never enabled it (census E9) | `codegen::add_windows_unwind` |
| JIT registration | none on any host; cranelift-jit has no Windows function-table support | `codegen::jitunwind` |
| The JIT's code lifetime | `SystemMemoryProvider` maps each allocation where the system puts it and leaks every mapping when the module is dropped | on Windows: one reserved range, released with the `CompiledProgram` |

### 1.4 The integration points

* **Per function**: `clif::define` already holds the compiled code of the
  direct function and the generic entry; it now also keeps each one's
  `UNWIND_INFO` (`DefineResult::direct_unwind`, `entry_unwind`) when the
  module's code is Windows x86-64's (`unwind::windows_x64`).
* **AOT**: `emit_object` finishes the cranelift-object module into an
  `ObjectProduct`, whose `object::write::Object` and function symbols are
  public: the two sections and their relocations are added there, through
  the `object` crate, before the object is written.
* **JIT**: `CraneliftJit::compile_actual` builds the module; the provider of
  its memory is pluggable (`JITBuilder::memory_provider`), data objects can
  be defined beside the code, and absolute addresses exist after
  `finalize_definitions`, where the stack-map table is already built.

Nothing else changes: the object writer, the linker, rustc's startup crate
and Cranelift itself are untouched.

### 1.5 The boundaries between Botlish and Rust frames

Code inspection of every transition (WINDOWS-TOOLCHAIN-CENSUS.md, B2):

| Transition | Where | What can happen inside |
|---|---|---|
| driver -> Botlish | `main.rs`'s `execute`, `runtime::aot::run` and `driver_protocol`, the stub's `aotimage` (Linux), tests | the whole run |
| Botlish -> runtime helper | every `call_helper` of `codegen::clif` | the helpers that allocate collect (`Vm::alloc` and the `alloc_*` paths) |
| runtime helper -> Botlish | `rt_call_value` (a function value's generic entry, reached by a jump: no frame of its own in an optimized build), the runtime functions that call a closure and go on (`mutable_array::generate`, the affine and mutable-vector bodies), coroutine thunks (not on Windows) | further Botlish frames, more collections |
| Botlish -> C | `foreigncall` | C cannot allocate Botlish memory; the borrow fixture's `read_reentrant` (Rust) collects, standing for re-entry |

A collection always starts in Rust (`Vm::collect_with`), several Rust frames
above the innermost Botlish frame, and a Rust frame -- a runtime function
that calls a closure, such as `mutable_array::generate`'s -- can sit
between two Botlish frames. (`rt_call_value` cannot: it ends in a call of
the closure's code that LLVM makes a jump -- `jmp *%rax` in the release
build, controlled experiment; section 7.3 tells what assuming otherwise
cost.)

## 2. Architecture: unwind information, AOT and JIT

### 2.1 The encoding (codegen::unwind)

`unwind::unwind_info(code, prologue)` encodes Cranelift's `UnwindInst`s as
the prologue Windows' own compilers emit for the same frame:

```text
  push rbp                     UWOP_PUSH_NONVOL RBP   at 1
  sub  rsp, CLOBBERS           UWOP_ALLOC CLOBBERS    at 4   (none when CLOBBERS is 0)
  lea  rbp, [rsp + CLOBBERS]   UWOP_SET_FPREG         at 4,  FrameOffset = CLOBBERS / 16
  mov  [rsp + OFF], REG        UWOP_SAVE_NONVOL REG, OFF / 8   (XMM: UWOP_SAVE_XMM128, OFF / 16)
```

Windows needs the establisher frame at or below the saves (their offsets
are unsigned), and Cranelift puts the frame pointer above them. The
equivalent prologue describes exactly the machine state of Cranelift's at
every instruction boundary the unwinder distinguishes:

* at offset 0 nothing applies; from 1 the pushed RBP is popped;
* from 4 (`mov rbp, rsp` done) the frame pointer is fixed until the
  epilogue's `pop rbp`, and the unwinder computes everything from it: the
  establisher frame `rbp - CLOBBERS` (where the saves are), RSP set to it,
  the allocation code adding CLOBBERS back to reach the pushed RBP, then the
  return address. The real RSP -- moving through the probe loop, then
  allocated -- is never read, which is what makes a probed frame unwindable
  at every instruction of its prologue, its probe loop included;
* each save applies from the instruction after it, from its slot below the
  frame pointer;
* in the epilogue, the clobbers are reloaded while their slots still hold
  what the prologue stored, `add rsp` and `mov rsp, rbp` leave the frame
  pointer as it is, and the unwinder simulates `pop rbp; ret` and `ret` from
  the code (it recognizes them: they are its epilogue form).

That is the argument (code inspection); `windows_unwinds_every_instruction_of_jit_code`
checks it on Windows, one unwind step from every instruction a program
executes, probe loops included (section 7.2).

`SET_FPREG` is placed where the frame pointer is set (offset 4), not where
Cranelift's `DefineNewFrame` stands (after the probes and the allocation:
offset 44 in a 1 MiB frame). The code's own bytes are checked to be `55 48
89 e5`; the push at 1 with 16 bytes to the caller's stack pointer, the one
frame definition, a clobber area that is a multiple of 16 and at most 240
bytes (the format's FrameOffset limit), saves aligned and inside it, in
order, every code offset under 256: anything else is a `NATIVE CODEGEN`
error naming the function, never an approximate record. Version 1, no
handler, no chained information.

Every function of a Windows x86-64 compilation gets it: each direct
function and each generic entry (`DefineResult::direct_unwind`,
`entry_unwind`). Each is 8 bytes for a frame that saves nothing; a frame
that saves registers adds its allocation code (2 or 4 bytes) and 4 bytes
per register, rounded up to a multiple of 4: at most 80 bytes (seven
general and ten XMM registers). Section 8 has the sizes of real
programs.

### 2.2 AOT: .pdata and .xdata (codegen::add_windows_unwind)

`emit_object` finishes the cranelift-object module and, when the functions
have unwind information (Windows x86-64's COFF object, which is the same
for both Windows environments), adds to it, through the `object` crate:

* `.xdata`: every `UNWIND_INFO`, 4-byte aligned;
* `.pdata`: one `RUNTIME_FUNCTION` per function in address order, each
  three `IMAGE_REL_AMD64_ADDR32NB` relocations: the start and the end
  against the function's own symbol (the end's addend its size, as the
  object crate writes a COFF addend: into the field), the unwind
  information against `.xdata`'s section symbol.

Both sections are read-only initialized data, 4-byte aligned. link.exe
merges `.pdata` into the executable's exception directory with the C
runtime's and Rust's, and relocates it: nothing of Botlish's sits between
the object and the linker. LLVM's own reader decodes the object's records
as written (`llvm-readobj --unwind`, controlled experiment on Linux), MSVC's
`dumpbin /unwindinfo` reads the object and the executable on the runner
(section 7.2), and Windows' own lookup finds every function of a linked
executable at exactly its code (section 7.2).

### 2.3 JIT: one code range and a function table (codegen::jitunwind)

A function table registered with `RtlAddFunctionTable` holds 32-bit
addresses relative to a base: every function and every `UNWIND_INFO` must
lie within 4 GiB above it. cranelift-jit's system memory provider maps each
allocation wherever Windows puts it, and its arena provider commits its
whole reservation on Windows. So on Windows the JIT allocates from
`CodeMemory`, a `JITMemoryProvider` of its own: one 1 GiB range reserved up
front (address space only), committed page by page into segments of one
kind each (code, read-only data, writable data), protected when the module
is finalized (`PAGE_EXECUTE_READ` with `FlushInstructionCache`,
`PAGE_READONLY`, `PAGE_READWRITE`), released when dropped. Then:

1. `define_unwind_data`, before `finalize_definitions`: every function's
   `UNWIND_INFO` in one read-only data object of the same module, so in
   the same range;
2. `finalize_definitions` relocates and protects the code: the final
   addresses exist from here;
3. `register`, right after: the `RUNTIME_FUNCTION`s of every direct function
   and generic entry from their finalized addresses, relative to the range's
   base, sorted, checked for overlap and for the 4 GiB reach (an error, never
   a partial table), passed to `RtlAddFunctionTable`, whose refusal is an
   error. Windows reads the table in place: it lives in the `FunctionTable`
   that registered it.

Lifetimes: the table is registered before the `CompiledProgram` exists, so
before any of its code can run. `CompiledProgram` holds it in a field
declared before the module's: dropping the program deletes the table
(`RtlDeleteFunctionTable`) and then releases the code range. A program's
code runs only while its `CompiledProgram` is alive (main.rs drops the Vm
first; so do the tests), so no frame of it is on a stack when its table
goes, and no table outlives its code (`every_jit_function_is_registered_for_its_code_only`).
Before this milestone the JIT's code was never released at all; on Linux
and macOS it still is not (their providers are unchanged).

## 3. Discovery strategy: Windows' unwinder against frame anchors

The collector must get from its own frame (`Vm::collect_with`, Rust) to
every Botlish frame's stack pointer -- the base of its stack-map entries --
across the Rust frames above, between and below the Botlish ones. Within a
run of Botlish frames Cranelift's frame records chain (`push rbp; mov rbp,
rsp` in every function: section 1.2), so the question is only how to cross
the Rust frames, whose RBP on Windows is no frame record (LLVM's Win64
prologue: `lea rbp, [rsp+K]`).

### 3.1 Strategy A: Windows' unwinder across Rust frames

`runtime::framewalk::windows`: the walk starts from `RtlCaptureContext` and
climbs one frame at a time:

* a frame whose return address is Botlish code (`ProgramMap::find`): its
  stack pointer is the context's RSP, so its roots are at `RSP + entry`
  exactly as on Linux x86-64; its frame record (`[rbp]`, `[rbp + 8]`,
  `rbp + 16`) gives its caller's RBP, RIP and RSP;
* any other frame: `RtlLookupFunctionEntry` and `RtlVirtualUnwind` from the
  Rust code's own `.pdata` (or a leaf's return address at RSP).

What it needs to be exact: the RIP and RSP of every frame (each step's
output) and the RBP of every Rust frame whose unwind uses it as its frame
register. RtlVirtualUnwind restores RBP where a Rust frame saved it, and a
Botlish frame's record holds its caller's, so RBP is exact throughout. The
other callee-saved registers are not restored by the frame-record step, and
no frame's unwind reads them (LLVM's and MSVC's frame register is RBP;
Windows' unwinder reads only the frame register and RSP to compute a
frame). The walk ends at a zero return address or an RSP outside the
thread's stack or not ascending, like Linux's at the end of its chain.

It costs nothing per call. Per collection it costs one `RtlVirtualUnwind`
step per Rust frame on the stack -- the collector's own, the helper's, any
runtime function between Botlish frames, and the driver's and the system's
below the program, down
to `RtlUserThreadStart` -- plus a frame-record step per Botlish frame, as on
Linux. It reuses the authoritative metadata of every Rust frame: nothing of
Rust's frame conventions is assumed.

### 3.2 Strategy B: explicit frame anchors

The alternative records, at every transition into Rust code that may
collect, an anchor -- the Botlish frame's stack pointer -- in the Vm, so the
collector starts from the anchor instead of unwinding to it. Code inspection
of what it would take (section 1.5's transitions):

* **which calls**: every runtime call at a GC safepoint -- one store of RSP
  before each (`call_helper` where `RootPlan::safepoint_slots` has the
  instruction), and the C calls that may re-enter (the borrow fixture's);
* **nested runtime calls**: a Rust frame that calls back into Botlish code
  (`mutable_array::generate`, the affine and mutable-vector bodies, any future one)
  must save the anchor and restore it after the call -- an anchor stack, or
  every walk would stop at the first such frame and miss every Botlish frame
  above it. Each such transition is code to remember to write: forgetting
  one is a missed root, silently;
* **leaf frames and nested contexts**: a Botlish function always has a frame
  record (section 1.2), so an anchor in a callee reaches its callers by the
  chain; contexts change nothing (they are a data area, not frames);
* **lifetime**: an anchor is valid from its store to its call's return; a
  stale one (a collection with no Botlish frame active: `Vm::reset`, the
  constants' installation) must be cleared, or it names a frame that no
  longer exists;
* **FFI and callbacks**: C never calls Botlish code; a foreign call that may
  collect needs an anchor like a helper call;
* **coroutines (future)**: each coroutine stack would need its own anchors,
  saved and restored by the switch.

What it would buy: no unwinding of Rust frames per collection. What it
costs: a store per runtime safepoint call, the anchor bookkeeping at every
re-entry, and a second, Botlish-specific way to cross Rust frames beside the
platform's, which every debugger and exception path still needs anyway.

### 3.3 Measured, and the decision

Both strategies' costs on one `windows-2025` runner (real Windows: run
[39812831363](https://github.com/mwagner-webdev/botlish/actions/runs/39812831363),
the `roots` job, adb94a8; `bench/root-plans.tcl`, section 8 has the method):

* **A's cost is per collection.** Under GC stress (a collection before
  every allocation) a collection costs 1.2 to 1.7 us more with the walk
  than with the fallback's shadow-stack scan on the three workloads that
  collect with shallow stacks (`strings` 1.34 against 0.13 us, `uri` 1.83
  against 0.50, `2048` 2.49 against 0.81), and 3.9 us more on `lists`, a
  200-frame recursion, where the Botlish frames' own lookups add to it (as
  on Linux: they are the same code).
  The unwind check's account of the 2048 benchmark's executable under GC
  stress gives the walk's shape (real Windows, the smoke job's 2048 step):
  33,508 walks crossed 268,065 frames that are not Botlish code -- 8.0 per
  walk: the collector's, the helper's, the driver's and the system's below
  the program -- and 188,079 Botlish frames, 5.6 per walk. So one
  `RtlVirtualUnwind` step costs roughly 150 to 200 ns there.
* **B's cost is per runtime call.** `audit/windows-unwind/tools/anchors.patch`
  stores RSP to the Vm before every runtime call at a GC safepoint -- the
  anchor B's collector would start from -- which nothing reads; the `roots`
  job's probe step builds it and compares it with the production driver
  (`[ci-probes]`). Time: native/anchors between 0.975 and 1.058 over the
  six workloads, JIT and executables -- within each workload's spread of
  rounds, so no difference is measurable. Code: 0 to 8.8 % more machine code
  (fib +0, uri +2.8 %, 2048 +7.0 %, lists +8.8 %), and up to 10 % more
  `.xdata` where a store needs one more register saved.

**Decision: A, Windows' unwinder across Rust frames.** Its cost exists only
per collection, and only GC stress makes collections frequent enough to see
it: in ordinary runs no workload is slower with the walk than with the
fallback (section 8). B would save those Rust frames' steps, but at a
store per runtime call in every run, and with a correctness obligation at
every entry into Botlish code from Rust -- `mutable_array::generate`, the
affine and mutable-vector bodies and every future re-entry must save and
restore the anchor, and forgetting one misses roots
silently (section 3.2) -- where A crosses any Rust frame, present or
future, by the metadata the platform keeps for it anyway.

Not done, deliberately: a lower bound for the walk -- stopping at the frame
that entered the program instead of unwinding the driver's and the
system's frames to the thread's start -- would save part of the eight steps
per collection, but it is an anchor every entry into Botlish code must set:
B's obligation, for a gain only GC stress shows.

## 4. GC correctness: the native-frame root path on Windows

### 4.1 One capability

`runtime::framewalk::NATIVE_FRAME_ROOTS` now includes
`all(target_arch = "x86_64", target_os = "windows", target_env = "msvc")`,
and every decision that must agree still reads only it (milestone 1's
table, section 3.2): stack-map emission (`clif.rs`'s `stack_maps`), each
function's root storage and depth bound (`roots::plan`), nir's call effects
(`depth_checked`), the shadow stack's allocation (`Vm::new`, now: only
without the capability), the root report, and the walk. The test harness's
table agrees (`native/native.tcl`'s `frameRoots` lists `windows-x86_64`;
`tests/helpers.tcl`'s `nativeFrameRoots`, and `nativeDepthChecked` still true
on Windows: no guard), and so does native-status's Windows row. The walk on
Windows is chosen by `cfg(windows)` within the capability, not by a second
capability: there is one answer to "are the roots in native frames".

### 4.2 Invariants

1. **Every root a collection may need is in a stack-map slot of a frame on
   the stack.** Unchanged from Linux: the root plan and Cranelift's
   `UserStackMapEntry`s are the same code (`roots::plan`,
   `clif::mark_safepoint`), on every native-frame host. A collection runs
   only inside a runtime call at a safepoint, which carries its entries.
2. **Every Botlish frame on the stack is visited, each once, with its
   stack pointer at its call.** The first is reached by unwinding the Rust
   frames from the collector's own context; each next one by its callee's
   frame record (a Botlish callee) or by unwinding the Rust callee
   (`mutable_array::generate`'s, a helper's) from an exact context. Its
   stack pointer is
   the context's RSP because the frame above it was unwound to it: the
   address just above the return address its call pushed. Cranelift's
   x86-64 frames keep RSP fixed in the body, so that is the RSP every stack
   map entry is relative to (`DefineResult::safepoints`).
3. **Only Botlish frames are read for roots, and only the entries of the
   safepoint their return address names.** A Rust frame is never read for a
   root; the stack-map table is keyed by exact return addresses
   (`ProgramMap::roots_at`), so a stale or arbitrary stack word is never
   taken for a root, and a slot is read only within the thread's stack.
4. **The walk stays within the stack and ascends.** Every read address and
   every RSP is checked against the thread's bounds; a step that does not
   raise RSP ends the walk, and a frame record outside the stack ends it.
5. **The roots of the shadow stack, `native_roots_ptr`, the pending error,
   the payload, `temp_roots`, the context roots and the statics are
   unchanged** (`Vm::collect_with`): on Windows the first two are empty, as
   on Linux.
6. **The unwind information agrees with the frame records.** Not needed
   for the walk -- it uses the frame records for Botlish frames -- but checked
   by it: with BOTLISH_NATIVE_UNWIND_CHECK=1 every Botlish function's entry
   must span exactly its code (`check_map`, when the program's stack-map table
   is installed) and every Botlish frame of every walk must unwind by Windows'
   unwinder to the RIP, RSP and RBP its frame record gives, with every
   callee-saved register restored from inside the frame (`check_frame`); a
   difference ends the process as a NATIVE BUG.

### 4.3 Root correctness cases

| Case | Where tested | How |
|---|---|---|
| roots in an allocating function, its callers, nested calls | `a_callers_root_survives_its_callees_collections`, `the_collectors_walk_agrees_with_windows_on_jit_frames`, native-status `gc-frame-walk` | GC stress |
| roots across a Rust frame between Botlish frames | `a_callers_root_survives_its_callees_collections` (`mutable_array::generate` calling a factory that collects) | GC stress; kills a walk that stops at that frame (section 7.3) |
| leaf-function roots | every workload | a leaf's roots are stack-map entries of its own frame, like any |
| roots across C calls, borrowed bytes | c-ffi.test's `cf-gc-calls`, c-byte-borrowing.test's stress tests, the borrow fixture's re-entrant collection | acceptance tier, GC-stress tier |
| mutable collections | mutable-vector, mutable-array tests, gc-workloads | acceptance and GC-stress tiers |
| contexts | contexts.test, context-traits.test | acceptance and GC-stress tiers |
| recursion, deep and allocating | `chain`/`down` programs of the Rust tests, gc-workloads' `uri`, the stack-limit tests | GC stress |
| error propagation | error-payloads, explicit-error-completions tests; workloads' handled errors | acceptance and GC-stress tiers |
| collection during expression evaluation | every allocation site is a safepoint: GC stress collects at each | GC-stress tier, gc-workloads |
| JIT and AOT, both Cranelift backends | gc-workloads (cranelift, cranelift-generic, executables), the census's programs through main.tcl | plain, GC stress, unwind check |

## 5. Depth and overflow

### 5.1 What the fallback reservation did, and what replaces it

Under the fallback plan every function with a Botlish call bumps the
shadow stack by its root slots (at least one) and fails with NATIVE LIMIT
STACK when the array (2^22 slots) is full; nir's call effects therefore
make every such function fallible (`depth_checked`), and every call of it
checks for the error (WINDOWS-X86-64-MILESTONE-1.md, section 3.4). That was
Windows' only clean NATIVE LIMIT STACK, and it bounded *slots*, not bytes.

With the roots in native frames the shadow stack has nothing to hold. Taking
the reservation away without a replacement would leave Windows with no
bound at all: a deep recursion would run into the end of the thread's
stack and Windows' `STATUS_STACK_OVERFLOW` (Rust's "has overflowed its
stack" report), not a Botlish diagnostic. Keeping the reservation as a bare
depth counter -- the dormant `prologue_depth_token` path, one slot per frame
-- would be *less* safe than the fallback was: 2^22 frames of more than 256
bytes do not fit the default 1 GiB stack, and native frames grow by the
roots the shadow stack used to hold. So it is replaced by a bound in bytes:

* `NativeStack::current()` on Windows reads the thread's stack from
  `GetCurrentThreadStackLimits` (no guard confirmed: `guard_low ==
  low_bound`); `Vm::new` sets `Vm::stack_limit` to its low bound plus a
  margin, an eighth of the stack's size between 64 KiB and 1 MiB
  (`NativeStack::stack_limit`): room for what may run below a checked frame
  -- one more Botlish frame, already allocated and probed before it checks,
  frames that make no Botlish call, the runtime's helpers (the collector's
  marking is iterative), and what Windows keeps at a stack's end (its guard
  page and the thread's stack guarantee, 20 KiB for a Rust thread);
* `clif.rs`'s `prologue_stack_limit`, in every function with a Botlish call
  (`RootPlan::depth_reservation`, now "bounds recursion in its prologue"),
  compares the stack pointer with it -- `mov rsp` to a register, one load,
  one compare, a branch to a cold block calling `rt_stack_overflow` -- and
  has nothing to undo on return;
* the failure is the same NATIVE LIMIT STACK error as the fallback's, so
  nir's call effects are unchanged: `depth_checked(NATIVE_FRAME_ROOTS)` is
  still true on Windows, every function with a Botlish call is still
  fallible, and every caller still checks (`native_stack::stack_limit_checked`
  names where the check is the stack pointer's).

No shadow stack is allocated where native frames hold the roots (`Vm::new`):
the 32 MiB array exists only for the fallback plan.

### 5.2 Why fallible, not terminal

On Linux and macOS NATIVE LIMIT STACK is terminal: the guard's handler
writes the result line and ends the process, so no call returns an error
for it and no caller checks. The stack-limit check could do the same from
normal code -- report and exit -- and then Windows' call effects would be
Linux's. It does not, deliberately: a terminal report needs the guard's
reporting half on Windows (where the result line goes for the driver, its
`--result` file, an executable's standard error, the driver protocol's
file, and the exit statuses), which is the Windows stack guard milestone's
work, and this milestone's scope excludes it. The check keeps the error
path the fallback already had, which every reporting mode already handles.
Section 8's comparison does not isolate the checks' cost: both of its
Windows drivers have them.

### 5.3 What changed for programs

| Case on Windows | Before (fallback plan) | Now |
|---|---|---|
| `down(10^8)`, default 1 GiB stack (native-status `recursion-limit`, aot-facts `standalone-depth-limit`) | NATIVE LIMIT STACK after 2^22 shadow slots | NATIVE LIMIT STACK at the stack limit |
| the same on a 16 MiB stack (aot-facts `standalone-stack-overflow`) | the process died: "has overflowed its stack", `STATUS_STACK_OVERFLOW` | NATIVE LIMIT STACK, exit status 1 |
| `stack_overflow.ir` on a 4 MiB stack (native-status `stack-overflow`) | NATIVE BUG (the driver died of the same) | NATIVE LIMIT STACK |
| a recursion of 1,000 frames on a 1 MiB thread (`the_stack_limit_ends_a_recursion_deeper_than_the_stack`) | (no such test) | runs |
| 10,000,000 frames on a 1 MiB thread (the same test) | the thread's stack exhausted | NATIVE LIMIT STACK |
| deep recursion inside the runtime, or one frame larger than the margin | the process dies | the process dies (the stack guard's work: section 10) |

What still needs the stack guard: an overflow in Rust code (a runtime
helper's own recursion), in C code, or within a single frame larger than
the margin; and NATIVE LIMIT STACK as a terminal report that lets nir treat
Botlish calls as infallible (section 10).

## 6. The fallback plan

The shadow-stack plan stays, as the bootstrap of a host without
native-frame roots: a function with a Botlish call keeps its roots on the
shadow stack, a leaf publishes its frame's roots through
`Vm::native_roots_ptr`, the shadow stack's end bounds recursion, and no
frame is walked. One capability still selects it, `NATIVE_FRAME_ROOTS`:
false on any host outside its list (a new operating system or CPU starts
there), and in the `fallback-roots` test build on any host. Nothing in it
changed but this: Windows no longer uses it, and the dormant
"native-frame roots with a shadow depth token" combination is gone (the
stack-limit check took its place, section 5).

Its support boundary, recorded in AGENTS.md: programs without native
coroutines. A suspended coroutine's shadow slots break the shadow stack's
LIFO order, so a host whose native coroutines run needs native-frame roots;
the fallback is not to be made coroutine-aware.

Tested how (section 7.4): the fallback build's Rust tests, on Linux and on
the Windows runner (CI's `roots` job), the GC workloads on the Windows
runner with the fallback driver, and `a_callers_root_survives_its_callees_collections`
under both plans.

## 7. Tests

### 7.1 Where each claim is tested

| Claim | Test | Runs on | Evidence |
|---|---|---|---|
| The encoding of every frame shape: no saves, general and XMM saves, the largest clobber area, a probed frame; any other prologue refused; Cranelift's own encoding still wrong | `codegen::unwind::tests` (6) | any x86-64 host: functions compiled for `x86_64-pc-windows-msvc` and decoded, never run | controlled experiment (Linux, and the Windows runner) |
| The object: one `RUNTIME_FUNCTION` per function in address order, three `ADDR32NB` relocations each, each naming its own function's `UNWIND_INFO` (frames of more than one shape) | `codegen::object_format_tests::a_windows_object_has_an_unwind_entry_for_every_function` | any x86-64 host | controlled experiment |
| Microsoft's tool reads the object's table, the executables' exception directories and every Botlish entry's codes | the dumpbin steps | the Windows runner | real Windows |
| Windows finds every function of a linked executable at exactly its code and unwinds every Botlish frame of every collection by it as by its frame record | aot-facts `object-unwind`, `standalone-unwind-check`; gc-workloads `-unwind-check 1` (executables); the 2048 benchmark's executable under the check | the Windows runner | real Windows |
| The JIT's table: every function found from any address of its code, at exactly its code, gone with it | `every_jit_function_is_registered_for_its_code_only` | Windows | real Windows |
| Windows' unwinder alone climbs JIT frames to the instructions that called them, callee-saved registers restored | `windows_unwinds_jit_frames_to_their_callers` | Windows | real Windows |
| ... from every instruction of every function | `windows_unwinds_every_instruction_of_jit_code` | Windows | real Windows |
| The collector's walk agrees with Windows' unwinder on every Botlish frame of every collection | `the_collectors_walk_agrees_with_windows_on_jit_frames`; gc-workloads `-unwind-check 1`; the census's programs under the check | Windows | real Windows |
| A caller's roots survive its callees' collections, across a Rust frame too | `codegen::caller_root_tests::a_callers_root_survives_its_callees_collections` | every host, both plans | real Windows, Linux, macOS |
| A recursion deeper than its thread's stack ends in NATIVE LIMIT STACK; a shallower one runs | `the_stack_limit_ends_a_recursion_deeper_than_the_stack`; native-status `stack-overflow`, `stack-depth-limit`, `recursion-limit`; aot-facts `standalone-depth-limit`, `standalone-stack-overflow` | Windows | real Windows |
| The limit's margin; where the stack pointer is checked; the capability's hosts | `the_stack_limit_keeps_a_margin_of_the_stacks_size`, `the_stack_pointer_is_checked_where_no_guard_backs_native_frame_roots`, `native_frame_roots_are_the_frame_pointer_and_unwinder_hosts` | every host | real Windows, Linux, macOS |
| Roots through whole programs | gc-workloads (both Cranelift backends and executables, plainly and under GC stress), the census's programs through main.tcl, native-status `gc-frame-walk`, the smoke and acceptance tiers, the full tier under GC stress | Windows | real Windows |
| The fallback plan | the `roots` job: the `fallback-roots` build's Rust tests and the GC workloads on it | the Windows runner; Linux | real Windows; controlled experiment |

### 7.2 Virtual unwinding, JIT and AOT

**At calls** (`windows_unwinds_jit_frames_to_their_callers`): a JIT program
calls a foreign function, `probe`, from the bottom of a recursion of
depth 4 below `wide`, which holds eight values across its call, below the
program; `probe` unwinds with `RtlVirtualUnwind` alone, from its own
context, to the instruction after the test's call of the program's entry.
Every frame's return address follows a call instruction (a direct call's
target is the function of the frame below), each step lands where
Cranelift's frame record says (`rsp == rbp + 16`), every restored register
comes from inside its frame, and at the end RBX, RSI, RDI and R12-R15 hold
the magic values the test put there before the call: restored through
the frames that saved them.

**At every instruction** (`windows_unwinds_every_instruction_of_jit_code`):
the program runs with the trap flag set, and a vectored exception handler
sees each instruction before it runs. For every instruction of a Botlish
function it unwinds one frame from the exact context and requires the
activation's return address, the stack pointer above it, and RBX, RBP,
RSI, RDI, R12-R15 and XMM6-XMM15 as the function found them -- in the
prologue (the push, the frame pointer, the allocation, the saves), in the
stack probes of a frame of more than one page (unrolled) and of more than
five (Cranelift's probe loop, where RSP moves on every iteration), in the
body, and in the epilogue to its `ret`. Six functions: the program, `wide`,
`down` (a recursion), two functions holding 700 and 3,000 raw integers
across a call, and a leaf. On the runner (run
[39823274563](https://github.com/mwagner-webdev/botlish/actions/runs/39823274563),
19a04b2): "15460 instructions unwound (15266 distinct), 0 elsewhere;
frames of 5656 and 24584 bytes" -- every instruction executed was Botlish
code and unwound exactly, through one page's unrolled probe and six
pages' probe loop.

**AOT**: aot-facts' probe program as an executable under GC stress with
the check on: "8 functions, 53 Botlish frames, every one as Windows
unwinds it; 3 walks unwound 25 other frames" -- `check_map` found each of
the 8 functions' entries in the executable's own exception directory at
exactly its code, and `check_frame` unwound each of the 53 Botlish frames
by Windows' unwinder to the RIP, RSP and RBP of its frame record, its
saves from inside it. The 2048 benchmark's executable under GC stress:
"66 functions, 188079 Botlish frames, every one as Windows unwinds it;
33508 walks unwound 268065 other frames". MSVC's dumpbin decodes each
Botlish function's entry in fib.exe:

```text
the object's table: 4 entries, sizes 0xd5 0x16 0xdf 0x30; the image's: 1502 entries, runs of them that match: 1
Botlish entries at RVA 0x55f6..0x57f0; another frame: none

  000835F4 000055F6 000056CB 00075138          a direct function: saves RSI and RDI
    Unwind version: 1
    Unwind flags: None
    Size of prologue: 0x12
    Count of codes: 7
    Frame register: rbp
    Frame offset: 0x10
    Unwind codes:
      12: SAVE_NONVOL, register=rdi offset=0x8
      0D: SAVE_NONVOL, register=rsi offset=0x0
      04: SET_FPREG, register=rbp, offset=0x10
      04: ALLOC_SMALL, size=0x10
      01: PUSH_NONVOL, register=rbp

  00083600 000056CB 000056E1 0007514C          a generic entry: saves nothing
    ...
      04: SET_FPREG, register=rbp, offset=0x00
      01: PUSH_NONVOL, register=rbp
```

(`audit/windows-unwind/tools/dumpbin-entries.tcl`: dumpbin's listing of an
image names no function, so the program's entries are found as the one
run of the image's 1,502 matching the object's own table -- the same
sizes, their `UNWIND_INFO` at the same distances -- and each must be this
frame.) RSI is restored from the establisher frame, `rbp - 0x10`, RDI from
8 bytes above it: exactly where Cranelift's prologue stored them, where
Cranelift's own encoding (section 1.2) would have read both from `[rbp]`.

### 7.3 Caller-root omission and mutants

`a_callers_root_survives_its_callees_collections` builds a list, calls a
function that allocates and collects thirty times -- once through a
function value, once directly, and three times from the factory of a
`mutable_array::generate`, whose runtime frame stays between the factory's
frames and the caller's -- and then reads the list: under GC stress its
root is only in its own frame. A walk that stops at the first Botlish frame
frees it (the `walk-first-botlish-frame-only` mutant, killed by it on Linux
and on Windows), and so does a walk that stops at the first Rust frame
above a Botlish frame (`walk-stops-at-rust`; on Linux, the same mutation of
the frame-pointer walk, applied by hand: the caller's list read as 999s).

The test did not have the `generate` until the first Windows mutation run:
`walk-stops-at-rust` survived it, because its function-value call was
meant to put `rt_call_value`'s Rust frame between the two Botlish frames,
and in the release build `rt_call_value` has none -- it jumps to the
closure's code (`jmp *%rax`). No other detector -- GC workloads, native
status, aot-facts -- collects with a Rust frame between Botlish frames
either; section 7.6.

`audit/windows-unwind/tools/mutate.tcl` (tier item `windows-unwind-mutants`)
applies twenty deliberate bugs to a private copy of the checkout, rebuilds
it and runs the detectors cheapest first: the Rust tests; on Windows
native-status; gc-workloads on the URI and 2048 workloads with the unwind
check; on Windows aot-facts.

| Mutant | What it breaks | Linux x86-64 | Windows x86-64 |
|---|---|---|---|
| `unwind-frame-offset-zero` | Cranelift's own frame offset: the establisher frame at RBP | killed: rust (the encoder's tests) | @@W1 |
| `unwind-save-scaled-by-16` | a general save's offset in sixteens, as Cranelift does | killed: rust | @@W2 |
| `unwind-no-clobber-allocation` | no allocation code: the unwinder's RSP stays at the establisher frame | killed: rust | @@W3 |
| `unwind-frame-pointer-at-definition` | `SET_FPREG` where Cranelift defines the frame, after the probes | killed: rust | @@W4 |
| `unwind-no-prologue-check` | any prologue taken for Cranelift's | killed: rust | @@W5 |
| `pdata-missing` | no unwind sections: every Botlish frame a leaf to Windows | killed: rust (the object test) | @@W6 |
| `pdata-end-short` | every entry one byte short of its function | killed: rust | @@W7 |
| `pdata-unsorted` | the table in declaration order | killed: rust | @@W8 |
| `pdata-wrong-unwind-info` | every entry naming the first `UNWIND_INFO` | killed: rust, once the object test had frames of two shapes (section 7.6) | @@W9 |
| `jit-unregistered` | the JIT's code never registered | skipped (Windows only) | @@W10 |
| `jit-table-deleted-early` | the table deleted right after it is registered | skipped | @@W11 |
| `jit-stale-registration` | the table never deleted: entries for released code | skipped | @@W12 |
| `jit-end-short` | every JIT entry one byte short | skipped | @@W13 |
| `walk-frame-pointers-through-rust` | the census's frame-pointer walk through Rust frames again | skipped | @@W14 |
| `walk-stops-at-rust` | the walk ends at the first Rust frame above a Botlish frame | skipped | @@W15 |
| `walk-roots-from-the-frame-pointer` | roots read at RBP plus the offset, not RSP | skipped | @@W16 |
| `walk-first-botlish-frame-only` | only the innermost Botlish frame's roots | skipped | @@W17 |
| `stack-limit-unchecked` | no stack-limit check in prologues | skipped | @@W18 |
| `stack-limit-at-the-stacks-end` | the limit at the stack's low bound: no margin | skipped | @@W19 |
| `effects-infallible` | a function with a Botlish call proven infallible: callers do not check | skipped | @@W20 |

On Linux x86-64 (controlled experiment, this container): the nine
host-independent mutants all killed, by the Rust tests, which build Windows
objects and unwind information on any x86-64 host; the eleven Windows-only
mutants (`%% windows-x86_64`) skipped.
@@MUTANTS-WINDOWS

### 7.4 Results on Windows

The workflow's run on this milestone's final code: run
[39823274563](https://github.com/mwagner-webdev/botlish/actions/runs/39823274563)
(19a04b2; `windows-2025`, MSVC, `x86_64-pc-windows-msvc`).

| Job, step | Result |
|---|---|
| Rust unit tests | lib 265 passed, driver 77 passed, 0 failed: every test of section 7.1 that runs on Windows, by name in the summary |
| native status | every probe as recorded: `gc-frame-walk`; `stack-overflow`, `stack-depth-limit`, `recursion-limit` NATIVE LIMIT STACK; coroutines still refused |
| aot-facts | every check ok: `object-unwind` (8 `RUNTIME_FUNCTION`s for 8 functions, `ADDR32NB`, `UNWIND_INFO` in `.xdata`), `standalone-unwind-check`, `standalone-depth-limit` (1 GiB stack), `standalone-stack-overflow` (16 MiB stack), and milestone 2's C calls and C runtime matrix |
| GC workloads | 133 runs, 0 failed (two backends and executables, five times under GC stress) |
| GC workloads under the unwind check | 70 runs, 0 failed, each executable with its account, e.g. the URI workload's "34 functions, 61513 Botlish frames, every one as Windows unwinds it; 10509 walks unwound 86072 other frames" |
| the census's programs through main.tcl | ok on both Cranelift backends, plainly, under GC stress, under GC stress with the check |
| the 2048 benchmark's executable | its value plainly, under GC stress, and under the check: "66 functions, 188079 Botlish frames, ..." |
| dumpbin | the object's table, both executables' exception directories, the Botlish entries decoded (section 7.2) |
| smoke tier and the Windows-relevant files | 9 commands, 0 failed: the examples on all four backends, 25 Tcl test files on interp and compile |
| `roots`: the fallback plan | its Rust tests lib 265, driver 77 passed; GC workloads on it 91 runs, 0 failed; root-plans (section 8) |
| acceptance, four shards | 0 failed: every Tcl test file on interp (212; none excluded for Windows), every golden suite (103) on interp, compile, cranelift-generic and cranelift -- the native backends' roots in native frames throughout |

**GC stress**: run
[39831136598](https://github.com/mwagner-webdev/botlish/actions/runs/39831136598)
(a manual run of the full tier on 19a04b2: the acceptance tier under
`BOTLISH_NATIVE_GC_STRESS=1`, four shards), every job green: every Tcl test
file on interp and compile and every golden suite on interp, compile,
cranelift-generic and cranelift, with a collection before every allocation
-- shard 1 (53 files, 26 suites, the examples on all four backends), shard 2
(53, 26) and shard 4 (53, 25): 0 failed, by their summaries; shard 3's step
succeeded too (tier.tcl exits 1 on any failure), but GitHub never closed
its check run, so its summary was not recorded. The same run repeated the
smoke, `roots` and acceptance jobs on the same commit: green.

### 7.5 Linux and macOS

The commits after ac93df3 changed only Windows-only test code
(`codegen::jitunwind`'s tests), the Windows workflow, a CI tool and this
report, so the Linux runs on ac93df3 test the final code of every other
host.

* **Linux x86-64, CI**: tests.yml run
  [39820321497](https://github.com/mwagner-webdev/botlish/actions/runs/39820321497)
  (ac93df3): every job green -- the Tcl suite on interp and compile,
  cranelift and cranelift-generic coverage, the golden suites (four
  shards), the native Rust tests, the stub-linked executables, the warning
  gate, the method-call filter audit. (Its native GC-stress job runs on
  pushes to main only.)
* **Linux x86-64, locally**: `tclsh9.0 tests/local.tcl -jobs 3` (e0b0cf0;
  the later commits changed tests, tools and Windows-only code, which the
  CI runs above cover): 212 Tcl test files on interp and
  compile, 6673 and 6668 tests passed, 0 failed; 103 golden suites on all
  four backends, 0 failed (interp 4997, compile 4997, cranelift-generic
  4905, cranelift 5007 tests). The Rust tests (19a04b2): lib 290, driver 73
  passed; under `BOTLISH_NATIVE_GC_STRESS=1` the same. @@LINUX-STRESS
* **Linux AArch64, CI**: tests-arm64.yml run
  [39820325771](https://github.com/mwagner-webdev/botlish/actions/runs/39820325771)
  (ac93df3): every job green -- the Tcl suite on interp and compile,
  cranelift and cranelift-generic coverage, the golden suites (four
  shards), the native Rust tests, and the native GC-stress job (the
  AArch64 frame walk under a collection before every allocation).
* **macOS arm64, CI**: run
  [39823274470](https://github.com/mwagner-webdev/botlish/actions/runs/39823274470)
  (19a04b2): every job green -- smoke, the Linux control, both acceptance
  shards.
* **Cross builds**: `cargo check --target` for `x86_64-pc-windows-msvc`,
  `aarch64-apple-darwin` and `aarch64-unknown-linux-gnu` (library, driver and
  tests) before each push: evidence that they build, nothing more.

What changed for the other hosts: `NATIVE_FRAME_ROOTS`' list (Windows
added), the shadow stack no longer allocated where native frames hold the
roots (Linux and macOS included: they never used it), the frame walk's Unix
half gated `not(windows)`, and test code; their root plans, call effects,
walk and stack guard are unchanged.

### 7.6 What the Windows runs found

| Run | Found | Cause | Fix |
|---|---|---|---|
| 72539fc's | the capability test asserted no native-frame roots on Windows | the test predates this milestone | it lists Windows among the unwinder's hosts |
| e0b0cf0's (macOS) | the Windows-ISA tests failed on macOS | an AArch64 build has no x86-64 backend | x86-64 hosts only (242a662) |
| 242a662's, adb94a8's | GC workloads under the unwind check: every executable's *link* failed | the driver printed the check's account at exit after the `executable` command too, and that line ended the command's result | the account is printed only after a program ran (528d49a) |
| the same | dumpbin's step | an object's function table is relocations: dumpbin lists it undecoded, with no names | the codes are read from fib.exe's, its Botlish entries found by name (528d49a) |
| Linux mutation run | `pdata-wrong-unwind-info` survived on Linux | the object test's functions all had the same frame, so another function's identical `UNWIND_INFO` was right by accident | functions of more than one frame shape (528d49a) |
| ac93df3's (both builds) | the single-step test: "every activation returned" | the test's own bookkeeping: its last trap, back in the test, returned before popping the program entry's activation; no instruction unwound wrongly | popped there too (19a04b2) |
| the same | dumpbin's Botlish entries not found | dumpbin's listing of the image names no function | the entries are the one run matching the object's table: `audit/windows-unwind/tools/dumpbin-entries.tcl` (19a04b2) |
| dbbbcdd's mutation run | `walk-stops-at-rust` survived every detector | no test collected with a Rust frame between Botlish frames: the caller-root test's function-value call goes through `rt_call_value`, which jumps to the closure (section 7.3) | the caller-root test calls `mutable_array::generate`, whose factory collects; the comments and AGENTS.md that named `rt_call_value` corrected (@@FIXCOMMIT) |

## 8. Performance

Same runner, same compiler: the `roots` job builds the production driver
and the `fallback-roots` driver from one checkout, and
`bench/root-plans.tcl` runs the same NIR on both (each driver decides its
own root plan and call effects), alternating the two within each of 7
rounds of 20 runs; the JIT's time is the driver's own per-run timing, an
executable's its own (`BOTLISH_NATIVE_RUNS`). Real Windows, run
[39823274563](https://github.com/mwagner-webdev/botlish/actions/runs/39823274563)
(19a04b2). Times are medians in microseconds; the ratio is native-frame
roots over the fallback.

| Workload | JIT native | JIT fallback | ratio | Executable native | Executable fallback | ratio |
|---|---:|---:|---:|---:|---:|---:|
| fib (call-bound recursion, fib(25)) | 581.9 | 696.8 | 0.835 | 587.2 | 704.8 | 0.833 |
| calls (a 100,000-deep recursion of calls) | 1001.0 | 861.7 | 1.162 | 975.9 | 910.0 | 1.072 |
| uri (the census's URI workload) | 2762.1 | 2777.3 | 0.995 | 2770.3 | 2816.0 | 0.984 |
| 2048 (the engine's benchmark) | 4883.9 | 4988.0 | 0.979 | 5059.1 | 5118.7 | 0.988 |
| strings (200,000 string allocations) | 16819.9 | 16941.0 | 0.993 | 19091.5 | 16820.5 | 1.135 |
| lists (list building, 200-deep recursion) | 9331.1 | 8844.9 | 1.055 | 9018.9 | 9121.6 | 0.989 |

The same comparison in three runs on three runners (the measured code is
the same in all three: the commits between them changed tests and CI
only), JIT / executable:

| Workload | [39812831363](https://github.com/mwagner-webdev/botlish/actions/runs/39812831363) | [39819883860](https://github.com/mwagner-webdev/botlish/actions/runs/39819883860) | [39823274563](https://github.com/mwagner-webdev/botlish/actions/runs/39823274563) |
|---|---|---|---|
| fib | 0.830 / 0.831 | 0.700 / 0.768 | 0.835 / 0.833 |
| calls | 1.283 / 1.158 | 1.110 / 1.138 | 1.162 / 1.072 |
| uri | 0.993 / 0.988 | 0.974 / 0.976 | 0.995 / 0.984 |
| 2048 | 1.003 / 1.005 | 0.999 / 1.002 | 0.979 / 0.988 |
| strings | 0.996 / 0.957 | 1.002 / 0.989 | 0.993 / 1.135 |
| lists | 0.988 / 0.968 | 0.913 / 0.989 | 1.055 / 0.989 |

* Native-frame roots are 17 to 30 % faster on `fib` (no shadow-stack
  bookkeeping per call), and within the runs' noise of the fallback on the
  allocation-heavy workloads (`uri`, `2048`, `strings`, `lists`: ratios
  between 0.91 and 1.06, except `strings`' executable in the last run,
  1.135, whose native rounds spread from 17,656 to 19,347 us).
* `calls` is slower in every run, by 7 to 28 %. It is not this milestone's
  mechanism: on Linux x86-64, which has native-frame roots without the
  stack-limit check and without the walk across Rust frames, the same
  comparison goes the same way (controlled experiment, this container:
  native/fallback 1.161 for the JIT, 1.013 for the executable, 10 runs x 3
  rounds). Both plans store a call's roots on the hot path -- to stack-map
  slots in the frame, or to the shadow stack -- and a 100,000-deep
  recursion of nothing but calls is where their different frame layouts
  show; `bench/root-plans.tcl -code calls` prints both drivers' code for
  it. A program that does anything per call besides calling (`fib`, the
  workloads) does not show it.

Under GC stress (a collection before every allocation; the JIT's median of
three runs, the plain run's time subtracted, divided by the collections),
run 39823274563:

| Workload | collections | native, per collection | fallback, per collection |
|---|---:|---:|---:|
| uri | 10,510 | 1.84 us | 0.47 us |
| 2048 | 33,509 | 2.40 us | 0.82 us |
| strings | 200,001 | 1.11 us | 0.11 us |
| lists | 40,201 | 5.24 us | 1.46 us |

(The other two runs: 1.83/0.50, 2.49/0.81, 1.34/0.13, 5.41/1.49 us, and on
a faster runner 1.07/0.27, 1.41/0.46, 0.61/0.06, 3.10/0.89 us.) The
difference is the walk (section 3.3): about eight `RtlVirtualUnwind` steps
per collection across Rust and system frames (the 2048 benchmark's
executable: 8.0), plus the Botlish frames' own steps, against a scan of a
dense array. It is paid per collection: under GC stress `strings` takes
239.1 ms against 39.8 ms; in ordinary runs, where collections follow heap
growth, it does not show (the first table).

Code and unwind information (the program's machine code, `botlish-native
size`; its COFF object's `.pdata` and `.xdata`):

| Workload | native code | fallback code | native .pdata + .xdata | fallback .pdata + .xdata |
|---|---:|---:|---:|---:|
| fib | 416 | 550 | 48 + 48 | 48 + 64 |
| calls | 803 | 901 | 48 + 48 | 48 + 64 |
| uri | 7,230 | 7,765 | 408 + 556 | 408 + 596 |
| 2048 | 24,130 | 25,712 | 792 + 1,196 | 792 + 1,276 |
| strings | 407 | 548 | 48 + 48 | 48 + 68 |
| lists | 888 | 1,056 | 72 + 76 | 72 + 96 |

Native-frame roots make smaller code (no shadow-stack pushes and pops) and
smaller `.xdata` (fewer saved registers). Unwind information costs 12
bytes of `.pdata` per function (direct function and generic entry each)
and 8 bytes of `.xdata` for a frame that saves nothing (18 on average in
the 2048 benchmark): 8 % of the 2048 benchmark's code. The JIT's table is
the same entries, in memory.

## 9. Remaining limitations

* **No stack guard on Windows.** NATIVE LIMIT STACK comes from the
  stack-limit check in functions with a Botlish call. An overflow in Rust
  code (a runtime helper's own recursion), in C code, or within one frame
  larger than the margin (64 KiB to 1 MiB) still ends the process with
  Windows' `STATUS_STACK_OVERFLOW`, as before this milestone. The
  vectored-exception guard is the next milestone (section 10).
* **NATIVE LIMIT STACK is an error, not a terminal report, on Windows**: every
  function with a Botlish call stays fallible and every caller checks
  (section 5.2), where Linux and macOS have neither. Those checks are the
  price of a clean report without the guard; the guard removes them.
* **No native coroutines on Windows** (unchanged, `NATIVE UNSUPPORTED`). The
  walk reads the thread's stack bounds; a coroutine stack would need its
  own bounds for the walk, `NT_TIB`'s stack fields switched for Windows'
  unwinder and exception dispatch, and its own overflow handling.
  `nativeCoroutines` stays false.
* **Cranelift's own Windows encoding is not used** and not fixed here
  (section 1.2); a Cranelift upgrade that changes the prologue's shape makes
  every Windows compilation a NATIVE CODEGEN error naming the function
  (`unwind_info`'s checks), never an approximate record. Upstreaming the
  fix would let Botlish take Cranelift's bytes again.
* **No language-specific handlers, no chained unwind information**: no
  Botlish function has an exception handler, so no SEH exception is caught
  in a Botlish frame, and a Rust panic in a runtime helper still ends the
  process at the helper's `extern "C"` boundary, as on every host. Windows
  can now unwind *through* Botlish frames -- for exception dispatch, a
  debugger, a crash dump, a profiler, the walk -- and does so exactly.
* **The JIT reserves 1 GiB of address space per program** and commits what
  it uses; a program with more than 1 GiB of code and data fails to
  compile, with an error. The JIT on Linux and macOS still never releases
  its code (unchanged).
* **The walk crosses every frame to the thread's start** on each collection
  (section 3.3): about eight `RtlVirtualUnwind` steps, visible only under
  GC stress.
* **windows-x86_64-gnu** objects carry the same unwind information (one COFF
  writer), but that environment has no supported native driver, so nothing
  of it runs (unchanged).

## 10. Next milestone

**WINDOWS-X86-64-MILESTONE-4: the Windows stack guard.** Unwind information
is what it needed: a vectored exception handler for `STATUS_STACK_OVERFLOW`
(with `SetThreadStackGuarantee` for room to run in) can now tell, through
`RtlLookupFunctionEntry` and the stack-map table, whether the overflow is
in Botlish code, and report NATIVE LIMIT STACK the way Linux's and macOS's
guards do -- through every reporting mode (the driver's result file, an
executable's standard error, the driver protocol, the exit statuses) --
for overflows the stack-limit check cannot see (Rust and C code, a frame
larger than the margin). With a terminal report, `depth_checked` becomes
false on Windows as on Linux, the stack-limit check and every Botlish
call's error check go, and `nativeStackGuard` becomes true.

After it, **Win64 native coroutines**: stack switching with each coroutine
stack's bounds for the walk, `NT_TIB`'s stack fields switched with it for
Windows' unwinder and exception dispatch, and the guard on each stack. The
coroutine stacks are unwound by the same unwind information; the fallback
plan stays coroutine-unaware (AGENTS.md).
