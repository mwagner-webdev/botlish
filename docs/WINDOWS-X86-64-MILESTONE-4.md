# WINDOWS-X86-64-MILESTONE-4.md

Milestone 4 of the Windows x86-64 port: the native stack guard on Windows,
and the end of the interim stack-limit checks. The census is
WINDOWS-TOOLCHAIN-CENSUS.md, the milestones before it
WINDOWS-X86-64-MILESTONE-1.md (the driver, executables, the fallback root
plan), WINDOWS-X86-64-MILESTONE-2.md (C calls, Windows I/O) and
WINDOWS-X86-64-MILESTONE-3.md (unwind information, native-frame roots, the
stack-limit check this milestone removes). The guards it joins are
NATIVE-STACK-OVERFLOW.md's and MACOS-AARCH64-MILESTONE-4.md's. Developed on
Linux. Every Windows fact below was observed on GitHub's `windows-2025`
runners, through `.github/workflows/windows-x86_64.yml` (production code)
and `.github/workflows/windows-stack-guard-probe.yml` (the experiments, a
program of their own). No Wine, no WSL.

> On Windows, as on Linux and macOS, an exhausted native stack ends the
> run in NATIVE LIMIT STACK, and no Botlish call can fail for the stack.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (run and job named);
* **controlled experiment**: a test, a probe build or a measurement run on
  purpose (where: Linux, or a Windows runner);
* **cross build**: compiled on Linux for `x86_64-pc-windows-msvc` and
  type-checked (`cargo check`), never run there -- evidence that the code
  builds, of nothing else;
* **code inspection**: what the code does, read, not run.

Commits are named by their hashes on the branch `claude/dreamy-fermi-3zu2ap`,
where every CI run below ran.

## Result

The milestone is complete: Windows x86-64 has the native stack guard, and
the interim stack-limit checks are gone.

* **Every exhaustion of the stack that runs Botlish code ends in
  NATIVE LIMIT STACK** (real Windows, section 7.1): Botlish recursion,
  large frames, frames Cranelift probes with its loop, recursion inside
  the runtime and recursion in MSVC-compiled C. The report is the driver's
  line with exit status 0, the same line through a linked run's protocol,
  or the line on standard error with exit status 1 from an executable.
  Until now an exhaustion inside the runtime or C killed the process with
  Rust's own report (real Windows, section 8.1).
* **The guard** (sections 2 to 4) is a vectored exception handler, first
  in the chain, installed by the thread that runs Botlish code with a
  32 KiB stack guarantee for its own path. It claims only
  STATUS_STACK_OVERFLOW that Windows' memory manager raised on that
  thread at an address of that thread's stack. It writes the line with
  WriteFile and ends the process with TerminateProcess: no allocation, no
  lock, no unwinding, no resumption. An access violation, a raised
  exception and another thread's exhaustion end exactly as they do
  without it (section 7.2).
* **The compiler** no longer checks the stack pointer in any prologue,
  reserves no depth and gives no Botlish call an error for the stack, on
  every host with native-frame roots (section 5). The fallback plan keeps
  its own depth check, and stack probes stay. On the benchmark workloads
  machine code is 7 to 50 % smaller, and run time and collection cost are
  unchanged within the noise (section 8).
* **Checked** on real Windows by the smoke, `roots`, acceptance and
  GC-stress tiers (runs 39954270512 and 39986842398). All 21 Windows-relevant mutants of the
  stack guard and all 17 of the unwind information were killed there
  (section 7.6). Linux and macOS are unchanged and green (section 7.7).
* **Not covered:** an interactive console as the destination, and native
  coroutines, which Windows does not have yet (sections 9 and 10).

## Contents

1. Census: the stack-overflow path before this milestone
2. Experiments: what Windows does when a stack runs out
3. The Windows guard
4. Terminal reporting
5. Compiler changes: the interim checks removed
6. GC interaction
7. Tests
8. Performance
9. Remaining limitations
10. Next milestone

## 1. Census: the stack-overflow path before this milestone

Code inspection of 85753d9 (main before this milestone), checked against
the Windows runs of milestone 3 and against the probe (section 2).

### 1.1 One path per host

| Piece | Linux x86-64 and AArch64, macOS AArch64 | Windows x86-64 (milestone 3) |
|---|---|---|
| worker stack | `main.rs` and `runtime/aot.rs` spawn the thread that runs Botlish code with 1 GiB (`BOTLISH_NATIVE_STACK_BYTES`, at least 1 MiB) | the same: a Rust thread whose stack is a 1 GiB reservation (`STACK_SIZE_PARAM_IS_A_RESERVATION`), committed by Windows page by page |
| bounds | `NativeStack::current()`: the pthread stack and its confirmed guard (`platform/linux.rs`, `platform/macos.rs`) | `GetCurrentThreadStackLimits` in `native_stack.rs`, no guard (`guard_low == low_bound`) |
| GC roots | native frames (`NATIVE_FRAME_ROOTS`) | native frames (milestone 3) |
| what bounds recursion | the guard: a fault in the published stack's guard region, on the guarded thread, classified on an alternate signal stack (`platform/guard.rs`) | `prologue_stack_limit` (`clif.rs`): every function with a Botlish call compares RSP with `Vm::stack_limit` -- the stack's low bound plus an eighth of its size, 64 KiB to 1 MiB (`NativeStack::stack_limit`, `stack_limit_checked`) -- and calls `rt_stack_overflow` below it |
| how it ends | the handler writes `error {NATIVE LIMIT STACK} {...}` with `write` and `_exit`s: 0 for the driver, 1 for an executable | `rt_stack_overflow` records `RtError::StackOverflow` and the function returns its error to its caller, up to the entry: an ordinary run-time error |
| root plan | `depth_reservation` false (`depth_checked(true)` is false) | `depth_reservation` true for every function with a Botlish call |
| call effects | a Botlish call fails only if its callee can | `depth_checked` makes every function with a Botlish call `may_error`: every caller checks the status word |
| driver report | the guard's line on the result descriptor (`set_result_fd`: `--result`'s file or standard output); exit 0 | the driver's ordinary `error` line for the run's error; exit 0 |
| driver protocol (linked runs) | the guard's line in `BOTLISH_NATIVE_RESULT`'s file; exit 0 | the ordinary error line in that file |
| executable | the guard's line on standard error, exit 1 | `MESSAGE (CODE)` on standard error, as any run-time error, exit 1 |
| stack probes | Cranelift's inline probes (`codegen::stack_probes`) | the same, needed by Windows' stack growth anyway |

### 1.2 What Windows did with each kind of exhaustion

| Exhaustion | Milestone 3 on Windows | Evidence |
|---|---|---|
| Botlish recursion | NATIVE LIMIT STACK as an ordinary error, from the stack-limit check: the driver's `error` line; an executable's `MESSAGE (CODE)` on standard error | real Windows: before-after's `down` with the driver of 85753d9 (section 8.1) |
| a frame larger than a page (3,000 live values, about 24 KiB) | the same, while the frame stays under the check's margin (64 KiB to 1 MiB) | real Windows: before-after's `huge-frame` (section 8.1) |
| a frame larger than the margin | its probes run past the stack: STATUS_STACK_OVERFLOW, Rust's own report, the process ended with 0xC00000FD | code inspection; the same mechanism as the next row |
| recursion inside the runtime (Rust) | Rust's report (`thread '<unknown>' has overflowed its stack`), the process ended by the exception, nothing on the driver's protocol: no check runs in Rust code | real Windows: before-after's `runtime-overflow`, in the JIT and as an executable (section 8.1) |
| recursion inside C | the same | code inspection; section 2's probe (MSVC-compiled C on a Rust thread) |
| an access violation unrelated to the stack | the process ended with 0xC0000005, nothing reported | section 2 |

### 1.3 What had to change

The first five rows are one event to Windows -- the thread's stack is
exhausted, wherever the code that exhausts it came from -- and the sixth
is another. So the guard (section 3) is one handler of that event, in place
for the whole run on the thread that runs Botlish code, and the sixth stays
what it was. Once the guard reports every exhaustion, the check that made
every Botlish call fallible has nothing left to do (section 5). The error
system is unchanged: NATIVE LIMIT STACK keeps its code, its message and its
line.

## 2. Experiments: what Windows does when a stack runs out

`audit/windows-stack-guard/probe` is a program of its own -- no
botlish-native code -- built and run on a `windows-2025` runner by
`windows-stack-guard-probe.yml` (real Windows: run
[39939107805](https://github.com/mwagner-webdev/botlish/actions/runs/39939107805),
attempt 2, b1f2727). Every experiment that exhausts a stack or faults runs
in a child process. A vectored exception handler, first in the chain,
writes one line about the exception with `WriteFile` -- its record, the
faulting context's RSP, its own RSP, the thread's bounds -- and ends the
process with `TerminateProcess(0x42)`, or passes the exception on, as the
experiment asks. Three kinds of thread: the process's main thread (a 1 MiB
reservation), a Rust thread (16 MiB; Rust's runtime gives its threads a
20 KiB stack guarantee), and a thread of `CreateThread`'s own (16 MiB, no
guarantee asked). Five ways to run out: Rust recursion with 256-byte
frames; Rust recursion with 64 KiB frames, which Rust probes with
`__chkstk`; MSVC-compiled C (`cl /O2`) with 256-byte frames and with
64 KiB frames (`__chkstk` again); and an inline loop that moves the stack
pointer down a page at a time and touches each page -- the access pattern
of Cranelift's probe loop.

### 2.1 What arrives

All 33 exhaustions -- five ways, three threads, and the Rust thread with
guarantees of 32 KiB, 64 KiB, 256 KiB and 1 MiB -- arrived the same way:

* code `0xC00000FD` (`STATUS_STACK_OVERFLOW`), flags 0, two parameters:
  the first 1, the second the faulting address, always inside the thread's
  reservation;
* on the exhausted thread, to the vectored handler first in the chain,
  which ran every time;
* raised when an access reaches the last page Windows lets the guard page
  move to: the faulting address was always in the page that starts
  `G + 4 KiB` above the reservation's bottom, `G` the thread's guarantee
  (20 KiB on Rust's threads: faults at 28,480 to 28,656 bytes above the
  bottom; 32 KiB: 40,944 to 40,952; 64 KiB: 73,704 to 73,720; 256 KiB:
  270,320; 1 MiB: 1,056,752). A thread that asked for no guarantee behaved
  as if it had 8 KiB (faults at 12,288 to 16,376);
* with the stack then committed down to 4 KiB above the bottom (NT_TIB's
  `StackLimit` at bottom + 0x1000): the reservation's lowest page is never
  committed.

Frames that `__chkstk` probes (Rust's and MSVC's 64 KiB frames) fault
below the stack pointer, which is still higher (24,576 bytes above the
bottom, RSP 46 to 56 KiB above it); the probe loop faults at its own stack
pointer, which is the worst case for the handler's room.

### 2.2 How much room the handler has

| Thread, guarantee | Exhausted by | Handler's RSP above the bottom | Dispatch (context RSP to the handler's) |
|---|---|---:|---:|
| Rust thread, 20 KiB | 256-byte Rust frames | 24,736 | 3,792 |
| Rust thread, 20 KiB | MSVC C frames | 24,864 | 3,760 |
| Rust thread, 20 KiB | the probe loop | 21,216 | 3,792 |
| main thread, 20 KiB | the probe loop | 23,712 | 3,760 |
| `CreateThread`'s, none | 256-byte Rust frames | 12,512 | 3,776 |
| `CreateThread`'s, none | the probe loop | 9,440 | 3,744 |
| Rust thread, 32 KiB | 256-byte Rust frames | 37,152 | 3,760 |
| `CreateThread`'s, 32 KiB | 256-byte Rust frames | 37,088 | 3,792 |
| Rust thread, 64 KiB | 256-byte Rust frames | 69,984 | 3,744 |

Of the room above the bottom the lowest 4 KiB are never committed. The
dispatcher -- the kernel's exception frame (`CONTEXT`, the record) and
`KiUserExceptionDispatcher` down to the vectored handlers -- took 3,744 to
3,792 bytes in every real exhaustion (3,968 for one `RaiseException`
raised).

How much the handler's own path needs, measured end to end: the handler
first used N KiB of stack (1 KiB frames), then wrote and terminated; N
was raised by 1 KiB, each in its own process, until the run failed:

| Thread, guarantee, exhausted by | Largest N that still reported | At N + 1 |
|---|---:|---|
| Rust thread, 20 KiB, Rust frames | 17 | exit 0xC0000005, nothing written |
| Rust thread, 20 KiB, MSVC C frames | 17 | the same |
| Rust thread, 20 KiB, the probe loop | 13 | the same |
| `CreateThread`'s, none, Rust frames | 6 | the same |
| Rust thread, 32 KiB, Rust frames | 27 | the same |
| Rust thread, 64 KiB, Rust frames | 56 | the same |

So the write at the bottom of the handler -- a 1 KiB line formatted on
the handler's stack, then `WriteFile` -- needs well under 3 KiB beyond the
frames burned (each a little over 1 KiB): each guarantee's extra kilobyte
bought one more frame (17, 27, 56), and running out ended in an access
violation of the never-committed bottom page: no report, never a hang.
`TerminateProcess` runs after the burn has returned, at the handler's own
depth. Of the calling process it returns nothing to measure, but it
completed in every experiment, the least room being the probe loop on a
thread with no guarantee: 9,440 bytes above the bottom at the handler's
entry, 5.2 KiB above the never-committed page. Painting the stack below a
caller (stack-use): `WriteFile` of the line to a pipe, a file and the null
device used 120 bytes below the caller's stack pointer; `TerminateProcess`
of another process's handle 4,832.

`SetThreadStackGuarantee` raised the guarantee to whatever was asked up to
1 MiB on a 16 MiB stack, kept the larger of the old and the new (asking
32 KiB on a Rust thread: 20,480 before, 32,768 after), and refused a
guarantee larger than the stack (32 MiB on 16 MiB: error 87, the
guarantee unchanged).

### 2.3 What else arrives

| Experiment | With a handler that reports and passes the exception on | Without any handler of the probe's |
|---|---|---|
| a read of address 8 | `0xC0000005`, parameters 0 and 8 (not in the stack); the process ends 0xC0000005 | 0xC0000005 |
| a read 64 KiB above the bottom of the reservation (uncommitted: a skipped guard page) | `0xC0000005`, parameters 0 and that address, inside the stack; 0xC0000005 | 0xC0000005 |
| a read of the guard page itself | nothing: Windows commits it and moves the guard down (`StackLimit` one page lower); the program goes on | the same |
| `RaiseException(STATUS_STACK_OVERFLOW)`, no parameters | `0xC00000FD`, flags **0x80**, no parameters, raised in kernelbase; Rust's report; 0xC00000FD | Rust's report, 0xC00000FD |
| the same with parameters 1 and an address of the stack | `0xC00000FD`, flags **0x80**, parameters exactly a real exhaustion's; Rust's report, 0xC00000FD | the same |
| an exhausted thread the handler does not claim | the handler declines; Rust's report on that thread, 0xC00000FD | -- |
| any exhaustion, the handler passing it on | Rust's report ("thread '...' has overflowed its stack"), 0xC00000FD | the same |

Flags 0x80 is `EXCEPTION_SOFTWARE_ORIGINATE` (winnt.h): `RaiseException`
sets it and the memory manager does not (flags 0 in all 33 real
exhaustions). Rust's own handler (rustc 1.97's std: `AddVectoredExceptionHandler(0, ...)`,
last in the chain, and `SetThreadStackGuarantee(0x5000)` for the main thread
and every thread std starts; code inspection of its source) prints its line
for any `STATUS_STACK_OVERFLOW` and passes it on; the process then ends
with 0xC00000FD. It intercepts nothing: a handler first in the chain sees
every exhaustion before it.

### 2.4 The choice

A vectored handler, first in the chain, is reliable for every way a
Botlish run can exhaust its stack: it ran in all 33 exhaustions, on every
kind of thread, with room to spare, and `WriteFile` and `TerminateProcess`
from it reported and ended the process as asked. `SetThreadStackGuarantee`
is what makes the room independent of who made the thread: a thread that
asked for nothing has 8 KiB, enough for the probe's handler with little
left; Rust's threads have 20 KiB, which the guard should not depend on
(its threads are Rust's today, an embedding's need not be). The guard asks
32 KiB (`GUARANTEE`). In the worst case measured -- a probe loop, which
costs the handler 3.5 KiB of a Rust thread's room -- that leaves about
29 KiB above the never-committed page at the handler's entry, more than
five times the 5.2 KiB in which its whole path, `WriteFile` and
`TerminateProcess`, has been seen to complete. It costs address space at
the stack's end, committed only when the stack is exhausted. The
classification (section 3.3) is the record's code, flags and address --
all three observed -- and the thread. No unwinding, no alternate stack, no
manual guard page and no `SetThreadStackGuarantee` on another thread: the
supported mechanisms suffice.

## 3. The Windows guard

`runtime/platform/windows.rs`, under the contract every host's guard keeps
(`runtime/platform/mod.rs`): an `OverflowGuard` installed by the thread
that runs Botlish code, in the driver's mode (`install`) or an
executable's (`install_executable`), for as long as it runs it;
`set_result_file` for the driver's `--result` file; one line,
`OVERFLOW_LINE`, which a test pins to the driver's own line for
`RtError::StackOverflow`; exit status 0 for the driver, 1 for an
executable. The POSIX guard (`guard.rs`) and this one share that contract
and nothing else: a signal handler on an alternate stack and a vectored
exception handler on the exhausted stack are two mechanisms.

### 3.1 Installation and lifetime

`main.rs`'s `execute` installs it after compiling, before the first run,
and drops it after the last line is written; `runtime/aot.rs` installs it
before the program's entry in an executable's own run and in the driver
protocol (after the result file is created: the guard is declared after
the file, so it is dropped first). Installation, under `GUARDED`'s `BUSY`
state (one guard per process):

1. `SetThreadStackGuarantee(GUARANTEE)` on the calling thread, and the
   thread's guarantee read back (`SetThreadStackGuarantee` of 0): below
   `GUARANTEE` -- the request failed, or Windows ignored it -- the install
   is refused. A request below the thread's current guarantee is ignored by
   Windows, so the guard never lowers one (Rust's runtime asks 20 KiB for
   its own threads);
2. the system's guard page confirmed (`confirmed_guard_page`, section 3.4);
3. the destination resolved (section 4) and stored with the mode and the
   guarded stack's reservation;
4. `AddVectoredExceptionHandler(1, handler)`: first in the process's chain,
   ahead of Rust's own handler (which std registers last, at startup);
5. `GUARDED` set to the thread's id, with release ordering: from here the
   handler claims.

Dropping it sets `BUSY`, removes the handler and sets `UNGUARDED`. The
thread keeps its stack guarantee: Windows lowers none. A refused install
is an error the drivers turn into a panic (`expect`), never a run without
the guard; in the driver that is NATIVE BUG, in an executable "native
executable panicked (NATIVE BUG)".

### 3.2 Thread ownership

Vectored handlers are process-wide: the handler runs for every exception
of every thread. It claims one only on the thread whose id `GUARDED` holds
(`GetCurrentThreadId`, a read of the thread's own TEB), and only while a
guard is installed. That thread runs nothing but the run while the guard
lives -- generated code, the runtime's helpers, the C functions the
program calls, re-entries from Rust into Botlish code
(`std::mutable_array::generate`'s factory) and the formatting of the
result -- so "the guarded thread, while installed" is exactly "an active
native Botlish execution", whatever code holds the stack pointer when it
runs out: no test of the faulting instruction's address is needed or
made. Another thread's exception -- a thread a C library started, the
driver's main thread -- is never claimed (`fault other-thread`,
`other-thread-raised`, section 7). Nested runs on one thread do not exist
(one Vm per worker); a second guard is refused (`AlreadyExists`).

### 3.3 Classification

`is_overflow` claims an exception when all four hold:

* its code is `STATUS_STACK_OVERFLOW` (0xC00000FD);
* it was raised on the guarded thread, while installed;
* its record's second parameter -- the address whose access could not
  grow the stack (section 2) -- lies in the guarded thread's reservation,
  `[DeallocationStack, StackBase)`;
* its flags lack `EXCEPTION_SOFTWARE_ORIGINATE`: Windows' memory manager
  raised it, not `RaiseException`.

Everything else continues the search, as if the guard were not there:

| Exception | Why not an overflow | What happens (section 7) |
|---|---|---|
| `STATUS_ACCESS_VIOLATION` anywhere, a null read included | not exhaustion | the process ends with 0xC0000005, as without the guard |
| an access violation in the stack's uncommitted reservation | a frame that stepped over the guard page: a missing stack probe, with stack to spare | the same; never relabelled, whatever its address |
| an access to the guard page itself | Windows commits it and moves the guard down: no exception reaches a vectored handler | the run goes on |
| `STATUS_STACK_OVERFLOW` on another thread | another thread's stack | Rust's report on that thread, 0xC00000FD, as without the guard |
| `STATUS_STACK_OVERFLOW` raised by `RaiseException`, with or without parameters naming the stack | software raised it (`EXCEPTION_SOFTWARE_ORIGINATE`); without parameters it names no address either | the same |
| any other code (breakpoints, single steps, C++ exceptions) | -- | the next handler's |

A record raised by software is refused by its flags: `RaiseException`
sets `EXCEPTION_SOFTWARE_ORIGINATE` and the memory manager does not
(section 2.3), so even `RaiseException(STATUS_STACK_OVERFLOW)` on the
guarded thread with a record naming its own stack -- otherwise exactly a
real exhaustion's -- goes on unclaimed (`fault raised-in-stack`).

### 3.4 The guard page, confirmed

On Windows an exhausted stack is not a fault in an address range, so
`NativeStack` has no guard range there (`guard_low == low_bound`; the
reservation's bounds still limit the frame walk). What the guard depends on
is that the stack still grows by Windows' guard page -- without one, the
last access would be an access violation, not `STATUS_STACK_OVERFLOW` --
and that is confirmed, never assumed: `confirmed_guard_page` asks
`VirtualQuery` for the region at the reservation's bottom (it must be
`MEM_RESERVE`, uncommitted) and the region directly above it (it must be
committed with `PAGE_GUARD`). A stack committed to its bottom, or laid out
otherwise, is refused. `a_guard_page_is_confirmed_only_above_an_uncommitted_reservation`
checks the predicate on a reservation laid out by hand; the native stack
checks confirm it on every kind of thread Botlish runs on (section 7).

### 3.5 What the handler does not do

It never returns to the faulting code, unwinds no frame (no
`RtlVirtualUnwind`, no `RtlLookupFunctionEntry`: milestone 3's unwind
information is not needed to classify, and the exhausted stack is no place
to walk), runs no destructor, allocates nothing, takes no lock, and touches
neither the heap, the collector nor the Vm. It reads atomics stored before
the fault -- `GUARDED`, the reservation, the mode, the destination -- and
calls `GetCurrentThreadId`, `WriteFile`, `GetCurrentProcess` and
`TerminateProcess` (section 4). It runs on the exhausted stack itself,
inside the guarantee Windows committed for it: Windows has no alternate
stack for exception handlers.

## 4. Terminal reporting

### 4.1 Where the line goes

The destination is resolved when the guard is installed, while the stack
is whole, and kept as a handle (`DESTINATION`):

| Mode | Installed by | Destination | Exit status | Then |
|---|---|---|---|---|
| `botlish-native run`/`bench`/`batch`, `--result PATH` (main.tcl's way) | `main.rs`'s `execute` | the result file's handle (`set_result_file`; the file lives in the driver's `RESULT` for the whole process) | 0 | the host reads the line as the run's result |
| the same without `--result` | `execute` | standard output (`GetStdHandle(STD_OUTPUT_HANDLE)`, read at installation) | 0 | the same |
| the driver protocol: a linked run of a program that calls C (`BOTLISH_NATIVE_RESULT`) | `runtime/aot.rs`'s `driver_protocol` | the result file `driver_protocol` created (`set_result_file`) | 0 | the driver, which started the executable, relays the file's lines (`run_linked`) |
| a standalone executable's own run | `runtime/aot.rs`'s `run` | standard error (`GetStdHandle(STD_ERROR_HANDLE)`) | 1 | the line, exactly the POSIX guard's |

The handles are the process's own (standard handles, which nothing closes)
or a file whose owner outlives the guard (the driver's static `RESULT`;
`driver_protocol`'s local, declared before the guard and so dropped after
it).

### 4.2 Writing

`write_overflow_line`: `WriteFile` of the static line, synchronous, no
`OVERLAPPED`, again for whatever a partial write left: each call writes at
least one byte or ends the attempt, so there are at most as many calls as
the line has bytes. A failed write (no standard error, a closed pipe, an
invalid handle) ends the attempt; nothing is retried, and the process
still ends with its status. `WriteFile` on a file or a pipe is the
`NtWriteFile` system call: no user-mode buffering, nothing to flush, so
the bytes are the file's or the pipe's when the process ends. Its stack
use, and the dispatcher's, were measured (section 2).

### 4.3 Ending the process

`terminate`: `TerminateProcess(GetCurrentProcess(), STATUS)`. It ends every
thread of the process with that exit status and runs no DLL detach
routine, no TLS callback and none of the C runtime's or Rust's exit
handlers -- nothing that could take a lock or need stack -- unlike
`ExitProcess`, which runs them all. On the calling process it does not
return (section 2: the exit statuses observed are exactly the ones
passed). Should it ever return, the handler fails fast: `int 0x29` with
`FAST_FAIL_FATAL_APP_EXIT`, which ends the process with no handler run.
The handler never returns `EXCEPTION_CONTINUE_EXECUTION` and never returns
at all after a claimed exception.

## 5. Compiler changes: the interim checks removed

With the guard on Windows, `native_stack_overflow_supported()` lists
Windows x86-64 (MSVC), and everything that read it follows, through the
same predicate as on Linux and macOS:

| What | Before (milestone 3, Windows) | Now |
|---|---|---|
| `native_stack::depth_checked(true)` | true | false, on every host with native-frame roots |
| `codegen::roots::plan`'s `depth_reservation` | true for every function with a Botlish call | false: only the fallback plan's `RuntimeStack` storage reserves depth |
| `codegen::clif`'s prologue | `prologue_stack_limit`: RSP against `Vm::stack_limit`, a cold block calling `rt_stack_overflow` | nothing |
| nir's call effects | every function with a Botlish call `may_error`; every caller checks | a Botlish call fails only where its callee can |
| `Vm::stack_limit`, `VM_STACK_LIMIT_OFFSET`, `NativeStack::stack_limit`, `stack_limit_checked` | the check's limit | removed |

The two capabilities stay two -- `NATIVE_FRAME_ROOTS` (where the roots are)
and `native_stack_overflow_supported()` (what bounds the stack) -- but a
host with the first needs the second, and the code says so: a compile-time
assertion in `native_stack.rs` (`!NATIVE_FRAME_ROOTS ||
native_stack_overflow_supported()`), and in `roots::plan` an assertion
that no native-frame function reserves depth, which codegen no longer
knows how to do. A new host starts on the fallback plan (AGENTS.md).

What did not change: the fallback plan (the `fallback-roots` build, and
any host without native-frame roots) keeps its shadow stack, its depth
check in every function with a Botlish call (`prologue_runtime_stack`'s
`rt_stack_overflow`) and the call effects that go with it -- its Rust
tests run in the `roots` job, `the_depth_is_checked_only_on_the_fallback_plan`
and `a_botlish_call_fails_exactly_where_depth_is_checked` pin both sides.
Stack probes stay on (`codegen::stack_probes`): Windows commits a stack a
page at a time, and a frame that skipped the guard page would fault on
reserved memory instead of raising the exception the guard reports. The
`Vm`'s layout lost a word, which moves `VM_STATICS_OFFSET` on every host:
the stub linker's ABI fingerprint covers it (its tests and
`aot-stub-linker.test` pass, section 7).

## 6. GC interaction

The guard and the collector meet nowhere: the handler never walks a stack
and never reads a root, and the collector's walk (milestone 3:
`RtlVirtualUnwind` across Rust frames, frame records across Botlish ones)
is unchanged. What changed under the collector is the frames it walks:
without the stack-limit check a function's prologue has no compare and
branch, and a call's continuation no status check, so frames and stack
maps differ in code size, not in shape; every root is still a stack-map
entry keyed by an exact return address. The JIT's function table and the
executable's `.pdata` are untouched, and no Botlish function gained an
exception handler: the vectored handler is called before Windows looks
for frame-based handlers, and ends the process before it would.

The fallback plan is untouched too (section 5): it never depended on the
check, and the guard now also covers it. A `fallback-roots` driver on a
16 MiB stack, whose native frames run out before its shadow stack does
(2^22 slots), ends in the guard's report (real Windows, section 8.1).
Until now nothing caught that exhaustion: the shadow stack's check never
fired, and Windows ended the process (code inspection).

## 7. Tests

### 7.1 Real exhaustion, case by case

Every case runs the program in a process of its own -- the driver, an
executable, or a child of the native stack test -- so a terminal failure
never ends the harness. No case asserts a depth: each asserts how the run
ended. The Windows column is real Windows: the smoke and `roots` jobs of
run 39944775051 (eee16a5) and the smoke, `roots` and acceptance jobs of
run [39954270512](https://github.com/mwagner-webdev/botlish/actions/runs/39954270512)
(62ba9cd).

| Case | Required | Where tested | On Windows |
|---|---|---|---|
| deep Botlish recursion, default 1 GiB stack | terminal NATIVE LIMIT STACK | native-status `stack-depth-limit`, `recursion-limit`; native-stack-overflow.test `native-stack-overflow-default-size`; aot-facts `standalone-depth-limit`; before-after `down` | passed: native-status, aot-facts (smoke); the test file (acceptance); before-after |
| deep Botlish recursion, small stack (1, 4, 16 MiB) | the same | native-status `stack-overflow`; native-stack-overflow.test `native-stack-overflow-1`, `ns-main-small-stack`, `ns-main-shapes`; aot-facts `standalone-stack-overflow`; native-executable.test | passed: native-status, aot-facts, native_stack's five threads (smoke); the test files (acceptance) |
| deep recursion with many live roots | the same | `ns-main-shapes` (a String, six Ints held across the call), `ns-gc-stress-main` (allocating, under GC stress, 1 MiB) | passed (acceptance), `ns-gc-stress-main` under GC stress |
| a large frame | growth, or the report | native-status `large-frame-overflow`, `native-stack-overflow-wide-1` (600 live values, unrolled probes) | passed: native-status (smoke); `native-stack-overflow-wide-1` (acceptance); before-after `huge-frame` |
| frames using Cranelift's probe loop | the same | `native-stack-overflow-probe-loop` (3000 live values, about 24 KiB a frame); native_stack's `probe-loop` (the loop's access pattern in Rust); milestone 3's single-step unwind of probe loops (unchanged, green) | passed: native_stack `probe-loop` (smoke); the test (acceptance) |
| exhaustion in a Rust helper | terminal report | native-status `runtime-stack-overflow`, `ns-runtime-helper` (a List equality a million deep on 16 MiB), aot-facts `standalone-runtime-overflow`, native-executable.test; native_stack's Rust recursions (small frames, 64 KiB frames) | passed: native-status, aot-facts (smoke); the test files (acceptance); before-after (until now: Rust's report, the process killed) |
| exhaustion in a C function | terminal report | c-ffi.test `cf-c-stack-overflow` (MSVC-compiled `bcf_deep`), in the linked run and as an executable | passed: smoke and acceptance (shard 4) |
| linked run | the driver's report, exit 0 | `cf-c-stack-overflow` (the driver protocol) | passed: the same |
| standalone executable | the line on standard error, exit 1 | aot-facts, native-executable.test, native_stack `executable` | passed: aot-facts' three, native_stack (smoke); native-executable.test (acceptance) |
| an ordinary invalid access | not NATIVE LIMIT STACK | native-status `c-access-violation` (memset through null, in C, through the real driver); native_stack `fault null`, `fault reserved` | passed: `c-access-violation` ended 0xC0000005 with the driver's "no result"; `fault null`, `fault reserved` as without the guard |
| an exception on another thread | not claimed | native_stack `fault other-thread` (an exhausted thread), `fault other-thread-raised` (a record naming the guarded stack) | passed: both ended as without the guard (Rust's report, 0xC00000FD) |
| deep recursion that fits | completes | native-status `jit`; `ns-main-finite`; aot-facts `standalone-deep-finite`; native_stack `finite`; before-after `finite` | passed: native-status `jit`, aot-facts (100,000 levels), native_stack `finite` (smoke); `ns-main-finite` (acceptance); before-after |

### 7.2 The guard's own checks

`native/tests/native_stack/windows.rs` (`cargo test --release --test
native_stack`, the smoke job's "Native stack guard checks" step) runs each
scenario in a child process of the test executable and compares the result
with what it must be:

| Check | Scenario | Must end |
|---|---|---|
| `facts THREAD` | the stack as `NativeStack::current` reads it on the main thread, std's default thread, 1 MiB and 1 GiB std threads, a 1 MiB thread made by `CreateThread` | the stack pointer inside it, the guard page confirmed above an uncommitted reservation, no guard range (`guard_low == low_bound`) |
| `guarantee` | the guard installed, then dropped, on a thread of `CreateThread`'s (no guarantee of its own) | its guarantee at least `GUARANTEE` while installed, and the same after the drop (Windows lowers none) |
| `guard THREAD driver` | each of those threads, the guard in the driver's mode, 256-byte frames | the overflow line on standard output, exit 0 |
| `guard std-1MiB executable` | an executable's mode | nothing on standard output, the line on standard error, exit 1 |
| `guard std-1MiB result-file` | the driver with `set_result_file` | the line in the file and nothing on standard output, exit 0 |
| `guard std-1MiB wide`, `probe-loop` | 64 KiB frames (`__chkstk`); Cranelift's probe pattern | the line, exit 0 |
| `guard std-1MiB finite` | a recursion that fits | it returns |
| `guard std-1MiB dropped` | a guard installed and dropped, then exhaustion | exactly what an unguarded thread does: Rust's report, 0xC00000FD, no line |
| `guard std-1MiB reinstalled` | a second guard after the first was dropped | the line |
| `fault null`, `fault reserved` | a read of address 8; a read of the guarded stack's uncommitted reservation | 0xC0000005, exactly as without the guard, no line |
| `fault guard-page` | a read of the system's guard page | the stack grows and the program goes on, as without the guard |
| `fault raised`, `raised-in-stack` | `RaiseException(STATUS_STACK_OVERFLOW)` with no parameters; on the guarded thread with parameters naming its own stack | Rust's report, 0xC00000FD, as without the guard |
| `fault other-thread`, `other-thread-raised` | another thread's exhausted stack; another thread raising an exception that names the guarded stack | the same |

Each `fault` scenario also runs without the guard, and the two must end
identically (exit status and standard output).

On Windows every check passed (real Windows: the smoke job of run
[39944775051](https://github.com/mwagner-webdev/botlish/actions/runs/39944775051),
eee16a5):

* **The threads.** The main thread (1 MiB), std's default thread (2 MiB)
  and the 1 MiB and 1 GiB std threads had Rust's 20,480-byte guarantee.
  The `CreateThread` thread had none. Every one had its guard page
  confirmed.
* **The guarantee.** The guard raised the `CreateThread` thread's to
  32,768 bytes, and it stayed 32,768 after the drop.
* **The overflows.** Each of the five threads ended in the line with exit
  0, and so did the 64 KiB frames and the probe loop. The executable mode
  gave exit 1 and the line on standard error. The result-file mode put the
  line in the file and left standard output empty.
* **Without the guard.** A dropped guard and a guard never installed both
  ended in Rust's own report, `thread '<unknown>' (...) has overflowed its
  stack`, with 0xC00000FD.
* **The faults.** Each ended exactly as without the guard: 0xC0000005 for
  `null` and `reserved`, the program going on for `guard-page`, and Rust's
  report with 0xC00000FD for the four `STATUS_STACK_OVERFLOW`s the guard
  must not claim.

### 7.3 Unit tests

* `runtime::platform::windows` (Windows only):
  - `this_threads_stack_contains_the_stack_pointer_and_grows_by_a_guard_page`;
  - `a_guard_page_is_confirmed_only_above_an_uncommitted_reservation`: a
    reservation laid out with `VirtualAlloc`, with and without a guard
    page, committed with and without one;
  - `only_the_guarded_stacks_overflow_is_claimed`: the classifier over
    every row of section 3.3's table.
* `runtime::platform`: `the_overflow_line_is_the_drivers_line_for_a_stack_overflow`
  pins `OVERFLOW_LINE` to the driver's line for `RtError::StackOverflow`
  on every host.
* `runtime::native_stack::the_depth_is_checked_only_on_the_fallback_plan`
  and `nir`'s `a_botlish_call_fails_exactly_where_depth_is_checked`: with
  native-frame roots, no depth check and no fallible Botlish call; with
  `fallback-roots`, both.

### 7.4 NIR and machine code

The Tcl tests that read the compiler's output expect the host's behavior
by capability (`nativeStackGuard`, `nativeDepthChecked`), never by
operating system. They ran on Windows in the acceptance tier and now
expect what Linux and macOS have:

* native-stack-map.test, `stack-map-fib-1` and `stack-map-fib-2`: `fib`
  reserves no depth, and its CLIF imports no `rt_stack_overflow`;
* native-root-storage.test, `storage-call-crossing-2`: the same for a
  function whose roots cross a call;
* hashable.test's `hb-nir-table-hash-total` and the `may_error` tests of
  setcontains-equality-total.test and setfromlist-equality-total.test:
  a function whose only fallible operation was its Botlish call is now
  `may_error=false` in the NIR;
* native.test's `native-aot-2` (Linux x86-64 only: ELF relocations) now
  expects the helper's relocation where `nativeDepthChecked` holds, not by
  operating system.

Section 8 counts the same on real Windows, before and after, over the
benchmark workloads.

### 7.5 GC

What section 6 claims, checked:

* **Windows, the collector's walk.** Real Windows, the smoke job of runs
  39944775051 (eee16a5) and
  [39954270512](https://github.com/mwagner-webdev/botlish/actions/runs/39954270512)
  (62ba9cd).
  - `tests/platform/gc-workloads.tcl` under GC stress: 133 runs on
    cranelift, cranelift-generic and as executables, 0 failed.
  - The same workloads under Windows' unwind check: 70 runs, 0 failed.
    Every Botlish frame the collector walked was the frame Windows
    unwinds to, 188,079 frames in 33,508 walks for the 2048 engine alone.
  - The census's programs through main.tcl, under GC stress and under the
    unwind check: green.
* **Windows, the fallback plan.** The `roots` job: its Rust tests (274 and
  76) and the GC workloads with the `fallback-roots` driver, 91 runs, 0
  failed.
* **Windows, an exhausted stack under GC stress.** `ns-gc-stress-main`
  (native-stack-overflow.test, the acceptance tier's shard 2) fills a
  1 MiB stack with an allocating recursion and ends in the guard's line.
  The GC-stress tier (run
  [39986842398](https://github.com/mwagner-webdev/botlish/actions/runs/39986842398),
  d38feb0, `[ci-full]`) ran the whole acceptance tier under
  `BOTLISH_NATIVE_GC_STRESS=1` on interp and compile, in four shards of
  28, 48, 23 and 57 minutes, with no test failed. Shard 2 held
  native-stack-overflow.test and native-executable.test, and shard 4
  c-ffi.test, hashable.test and native-root-storage.test.
* **The cost of a collection.** Under GC stress it is what it was (section
  8.2): the frames lost instructions, not shape.
* **Linux x86-64, a controlled experiment.** Under
  `BOTLISH_NATIVE_GC_STRESS=1`, in this session's container:
  - the Rust tests: 296 library, 73 binary;
  - `native/tests/native_stack.rs`: every check;
  - native-stack-overflow.test: 20 of 20;
  - native-executable.test: 19 of 19;
  - native-root-storage.test: 10 of 10;
  - native-stack-map.test: 11 of 11.

* **Linux AArch64.** The arm64 workflow's GC-stress job on d38feb0 (run
  [39986848710](https://github.com/mwagner-webdev/botlish/actions/runs/39986848710))
  ran the whole Tcl suite and the Rust tests under GC stress: green, in
  1 h 52 min, the time it takes on main.

The first GC-stress runs found a defect in this milestone's own tests, not
in the guard. `ns-runtime-helper` and the nested-List case of
`native-executable-stack-overflow` build a List nested a million deep in a
loop. Under GC stress each of the loop's allocations traces every List
built so far: 2.7 s for 10,000 levels and 22 s for 30,000 (measured on
Linux), so some seven hours for a million (extrapolated).

The suite under GC stress therefore never finished. The arm64 workflow's
GC-stress job ran past four hours in the test suite before it was
cancelled, and the local run stood on `nest(1000000)` for 26 CPU minutes.
Both tests now run that case without GC stress (d38feb0). They are about
the guard ending an exhaustion inside the runtime; the guard under GC
stress is `ns-gc-stress-main`'s subject. The Cranelift probe-loop test
needs no such treatment: its 3,000 one-character Strings are immediate
values, and it took 3.1 s with and without stress.

### 7.6 Mutation testing

`audit/native-stack/tools/mutate.tcl` holds 44 mutants. Each is a
deliberate bug of one rule of sections 3 to 5, or of the guards it joins.
On each host, every mutant whose code that host compiles is built into a
private copy of the tree and run against the detectors, cheapest first,
until one fails:

1. the Rust tests (`rust`);
2. `native/tests/native_stack.rs` (`native_stack`);
3. native-stack-overflow.test;
4. native-status;
5. aot-facts;
6. the `fallback-roots` build's Rust tests (`fallback`).

A mutant of code the host never compiles is skipped: platform/linux.rs,
macos.rs, windows.rs, guard.rs, and coroutine.rs off the coroutine hosts.
The milestone's own mutants are the sixteen `win-*` (the Windows guard)
and four of the host-independent rules: `effects-fallible-again`,
`effects-infallible-on-fallback`, `depth-reserved-on-native-frames` and
`stack-probes-disabled`.

| Host | Where | Killed | Survived | Skipped |
|---|---|---:|---:|---:|
| Windows x86-64 | real Windows: run [39954270512](https://github.com/mwagner-webdev/botlish/actions/runs/39954270512), the full tier's shard 1 (62ba9cd), 889 s | 21 | 0 | 23 |
| macOS AArch64 | real macOS: run [39945819468](https://github.com/mwagner-webdev/botlish/actions/runs/39945819468), Tier C shard 1 (eee16a5), 899 s | 25 | 0 | 19 |
| Linux x86-64 | controlled experiment: this session's container, the tree of 1f69b66 | 21 | 0 | 23 |

Each mutant and the first detector that killed it, per host (`--`:
skipped there):

| Mutant | The bug | Linux x86-64 | macOS AArch64 | Windows x86-64 |
|---|---|---|---|---|
| `linux-bounds-reversed` | the thread stack's top and bottom swapped (Linux) | rust | -- | -- |
| `linux-size-halved` | the stack size read as half of what glibc reports (Linux) | rust | -- | -- |
| `linux-constant-bound` | the stack's low bound a constant 8 MiB below its top (Linux) | native_stack | -- | -- |
| `macos-bounds-reversed` | the thread stack's top and bottom swapped (macOS) | -- | rust | -- |
| `macos-address-is-the-bottom` | pthread_get_stackaddr_np taken for the stack's lowest address (macOS) | -- | rust | -- |
| `macos-size-halved` | the stack size read as half of what libpthread reports (macOS) | -- | rust | -- |
| `macos-constant-bound` | the stack's low bound a constant 8 MiB below its top (macOS) | -- | rust | -- |
| `macos-reported-bottom-trusted` | the reported bottom taken as usable without looking (the main thread's is inaccessible) (macOS) | -- | native_stack | -- |
| `macos-guard-assumed` | one 16 KiB page below the stack taken for its guard, unconfirmed (macOS) | -- | rust | -- |
| `page-size-4096` | the guard taken as one 4 KiB page below the stack, a page size Apple Silicon does not have (macOS) | -- | native_stack | -- |
| `publish-before-switch` | the stack about to run published before the switch, not on arrival | native_stack | native_stack | -- |
| `start-publishes-thread-stack` | a coroutine's first segment publishes the thread's stack, not its own | native_stack | native_stack | -- |
| `resume-not-published` | a resumed coroutine does not publish its stack | native_stack | native_stack | -- |
| `yield-not-restored` | the resumer does not publish its stack when a segment returns to it | native_stack | native_stack | -- |
| `guard-range-swapped` | the published guard and low bound swapped: no address is in the guard | native_stack | native_stack | -- |
| `guard-includes-stack` | the guard range runs up into the usable stack: a fault there is an overflow too | native_stack | native_stack | -- |
| `every-fault-overflows` | every fault on the guarded thread is reported as an overflow | native_stack | native_stack | -- |
| `any-thread-overflows` | the faulting thread is not checked: another thread's fault in the guard is an overflow | native_stack | native_stack | -- |
| `no-alternate-stack` | the handler is installed without SA_ONSTACK: it runs on the stack that overflowed | native_stack | native_stack | -- |
| `report-without-line` | the overflow ends the process without its result line | native_stack | native_stack | -- |
| `report-ignores-result-fd` | the overflow line goes to standard output, not the --result descriptor | native_stack | native_stack | -- |
| `defer-exits-quietly` | an unrelated fault ends the process with exit status 0, not under the disposition it had before | native_stack | native_stack | -- |
| `drop-leaves-guard-busy` | a dropped guard never returns to UNGUARDED: no second guard installs | native_stack | native_stack | -- |
| `gc-walk-half-stack` | the frame walk of the thread's stack bounded at its middle | rust | rust | rust |
| `win-handler-not-registered` | the vectored handler is never added: the guard installs and nothing claims an overflow (Windows) | -- | -- | native_stack |
| `win-any-exception-code` | any exception at an address of the guarded stack is an overflow, whatever its code (Windows) | -- | -- | rust |
| `win-access-violation-is-overflow` | an access violation at an address of the guarded stack is reported as an overflow (Windows) | -- | -- | rust |
| `win-software-raised-claimed` | a STATUS_STACK_OVERFLOW raised by software (RaiseException) naming the guarded stack is claimed (Windows) | -- | -- | rust |
| `win-any-thread` | the raising thread is not checked: another thread's exception naming the guarded stack is claimed (Windows) | -- | -- | rust |
| `win-no-address-check` | STATUS_STACK_OVERFLOW is claimed whatever address its record names, or none (Windows) | -- | -- | rust |
| `win-no-guarantee` | the guard asks for no stack guarantee and checks none: the thread keeps whatever it had (Windows) | -- | -- | rust |
| `win-guard-page-assumed` | the system's guard page taken for granted, unconfirmed (Windows) | -- | -- | rust |
| `win-no-destination` | the report's destination never stored: the line goes nowhere (Windows) | -- | -- | native_stack |
| `win-result-file-ignored` | the driver's line goes to standard output, not the --result file (Windows) | -- | -- | native_stack |
| `win-report-without-line` | the overflow ends the process without its result line (Windows) | -- | -- | native_stack |
| `win-statuses-swapped` | the driver exits 1 and an executable 0 after an overflow (Windows) | -- | -- | native_stack |
| `win-handler-returns` | the handler writes the line and returns instead of ending the process (Windows) | -- | -- | native_stack |
| `win-drop-leaves-guard-busy` | a dropped guard never returns to UNGUARDED: no second guard installs (Windows) | -- | -- | rust |
| `win-driver-unguarded` | the driver runs Botlish code without the guard (Windows) | -- | -- | native-stack-overflow.test |
| `win-executable-unguarded` | a standalone executable runs its program without the guard (Windows) | -- | -- | aot-facts |
| `effects-fallible-again` | a Botlish call is fallible again where native frames hold the roots: callers check for an error the guard makes impossible | rust | rust | rust |
| `effects-infallible-on-fallback` | a Botlish call proven infallible on the fallback plan, whose shadow stack's depth check can fail it: callers do not check | fallback | fallback | fallback |
| `depth-reserved-on-native-frames` | a function with a Botlish call reserves depth where native frames hold the roots, as the stack-limit check did | rust | rust | rust |
| `stack-probes-disabled` | generated code does not probe a frame larger than a page: a large frame steps over the system's guard | rust | rust | rust |

Each Windows mutant is killed by the check that states its rule:

* **The classification** (`win-any-exception-code`,
  `win-access-violation-is-overflow`, `win-software-raised-claimed`,
  `win-any-thread`, `win-no-address-check`): the classifier's unit test,
  section 3.3's table.
* **The guard page and the guarantee** (`win-guard-page-assumed`,
  `win-no-guarantee`, `win-drop-leaves-guard-busy`): the unit tests that
  lay out a reservation with `VirtualAlloc` and install a guard.
* **Reporting** (`win-handler-not-registered`, `win-no-destination`,
  `win-report-without-line`, `win-statuses-swapped`,
  `win-handler-returns`): real exhaustion in a child process.
* **The drivers** (`win-driver-unguarded`, `win-executable-unguarded`):
  native-stack-overflow.test, eight of whose tests fail, and aot-facts'
  three standalone overflows. Nothing in the Rust tests exhausts a stack
  through the driver.

`audit/windows-unwind/tools/mutate.tcl` lost the three mutants of the
stack-limit check (`stack-limit-unchecked`,
`stack-limit-at-the-stacks-end`, `effects-infallible`): their code is
gone, and the rules that replace them are the four host-independent
mutants above. Its seventeen other mutants were all killed on Windows in
the same run (338 s), every one by the Rust tests, as in milestone 3.

### 7.7 Linux and macOS

The guard's contract is shared (`runtime/platform/mod.rs`), and the
compiler change reads a predicate every host answers, so Linux and macOS
were run in full:

* **Linux x86-64.**
  - Run [39944778138](https://github.com/mwagner-webdev/botlish/actions/runs/39944778138)
    (eee16a5; `tests.yml`, dispatched): every job green. That is the Tcl
    suite on interp and compile, its cranelift and cranelift-generic
    coverage, the native Rust tests, the four golden shards, the
    stub-linked executables, the warning gate and the method-filter audit.
    Its GC-stress job runs on pushes to main only.
  - Controlled experiments in this session's container:
    - `tests/local.tcl` on 2bab253: 6,878 and 6,873 Tcl tests passed on
      interp and compile, and the 103 golden suites on four backends,
      none failed (39 minutes, 4 jobs);
    - the stub linker's run of the executable tests;
    - the GC-stress checks of section 7.5;
    - the mutants of section 7.6.
* **Linux AArch64.** Run
  [39944781420](https://github.com/mwagner-webdev/botlish/actions/runs/39944781420)
  (eee16a5, dispatched): every job green but the GC-stress job, which
  section 7.5's defect held past four hours until it was cancelled.
  Run
  [39986848710](https://github.com/mwagner-webdev/botlish/actions/runs/39986848710)
  (d38feb0, with section 7.5's correction): every job green, the GC-stress
  job included.
* **macOS AArch64.** Run
  [39945819468](https://github.com/mwagner-webdev/botlish/actions/runs/39945819468)
  (eee16a5, dispatched with the mutants): every job green. That is the
  smoke job (native-status' new probes, aot-facts'
  `standalone-runtime-overflow`, the Rust tests and the native stack
  checks), both acceptance shards, the ubuntu control and Tier C's
  mutants. On macOS, `c-access-violation` ends in the signal it always
  did, as native-status records.
  Run
  [39986842454](https://github.com/mwagner-webdev/botlish/actions/runs/39986842454)
  (d38feb0, `[ci-full]`): every job green. That includes Tier C, the
  acceptance tier under GC stress in three shards (58, 36 and 28
  minutes), with this milestone's tests of the thread's stack and of
  coroutine stacks.

### 7.8 The CI runs

Every run of this milestone on the branch, in order:

| Run | Commit | Workflow | What it ran | Outcome |
|---|---|---|---|---|
| [39939107805](https://github.com/mwagner-webdev/botlish/actions/runs/39939107805) (attempt 2) | b1f2727 | windows-stack-guard-probe | section 2's experiments | green |
| 39940958797 | d9231bb | windows-x86_64 (push) | the guard beside the check: smoke | the guard's checks, native-status and aot-facts green; the smoke tier failed on c-ffi.test's `cf-renamed-binding-native-name`, which compiled a Linux program for the host target (fixed in eee16a5); the rest cancelled by the next push |
| [39944775051](https://github.com/mwagner-webdev/botlish/actions/runs/39944775051) | eee16a5 | windows-x86_64 (manual, `probes`) | smoke, `roots` with section 8's probes | green; its acceptance shards, still queued, cancelled by the next run, which ran them |
| [39944778138](https://github.com/mwagner-webdev/botlish/actions/runs/39944778138) | eee16a5 | tests (manual) | Linux x86-64 | green |
| [39944781420](https://github.com/mwagner-webdev/botlish/actions/runs/39944781420) | eee16a5 | tests (linux arm64) (manual) | Linux AArch64 | green but the GC-stress job, cancelled after four hours (section 7.5) |
| [39945819468](https://github.com/mwagner-webdev/botlish/actions/runs/39945819468) | eee16a5 | macos-arm64 (manual, `native-stack-mutants`) | smoke, acceptance, Tier C's mutants | green |
| [39954270512](https://github.com/mwagner-webdev/botlish/actions/runs/39954270512) | 62ba9cd | windows-x86_64 (manual, the two mutant items) | smoke, `roots`, acceptance, the mutants | green |
| 39985866957 | caaabfc | windows-x86_64 (manual, `full`) | the GC-stress tier | cancelled before it started: section 7.5's defect would have held it |
| [39986842398](https://github.com/mwagner-webdev/botlish/actions/runs/39986842398) | d38feb0 | windows-x86_64 (push, `[ci-full]`) | smoke, `roots`, acceptance, the GC-stress tier | green |
| [39986842454](https://github.com/mwagner-webdev/botlish/actions/runs/39986842454) | d38feb0 | macos-arm64 (push, `[ci-full]`) | smoke, acceptance, Tier C under GC stress | green |
| [39986848710](https://github.com/mwagner-webdev/botlish/actions/runs/39986848710) | d38feb0 | tests (linux arm64) (manual) | Linux AArch64, GC stress included | green |

Commits after 62ba9cd change only this report, except d38feb0, which
the last three runs ran.
## 8. Performance

Real Windows: the roots job of run
[39944775051](https://github.com/mwagner-webdev/botlish/actions/runs/39944775051)
(eee16a5, a manual run with `probes`), on one `windows-2025` runner. That
step builds the driver of 85753d9 -- main before this milestone: the
stack-limit check in every function with a Botlish call, every such call
checked for its error, no guard -- next to this branch's. It runs
`audit/windows-stack-guard/tools/before-after.tcl` (8.1) and
`bench/root-plans.tcl -name checks` (8.2) with both drivers. Both drivers
compile the same NIR, which this branch's front end lowers once per
program. So the only differences are the root plan's depth reservation, the
call effects and the prologue.

### 8.1 What each driver does with an exhausted stack

Each program runs on a 16 MiB stack, in the JIT (`botlish-native run`) and
as the standalone executable it links:

* `down`: Botlish recursion with no end;
* `huge-frame`: a recursion whose frame holds 3,000 live Strings, about
  24 KiB, which Cranelift probes with its loop;
* `runtime-overflow`: a List nested a million deep, compared by the
  runtime's recursive equality;
* `finite`: a recursion 100,000 deep that fits.

| Program | 85753d9 (the check), JIT | 85753d9, executable | this branch, JIT | this branch, executable |
|---|---|---|---|---|
| `down` | exit 0, `error {NATIVE LIMIT STACK} {...}` | exit 1, `native stack exhausted: too many nested calls (NATIVE LIMIT STACK)` | exit 0, the guard's line | exit 1, the guard's line on standard error |
| `huge-frame` | the same as `down` | the same as `down` | the same as `down` | the same as `down` |
| `runtime-overflow` | killed by the exception, `thread '<unknown>' (2328) has overflowed its stack`, nothing on standard output | the same (`(8152)`) | exit 0, the guard's line | exit 1, the guard's line |
| `finite` | `100000` | `100000` | `100000` | `100000` |

Tcl reports the killed processes as `CHILDKILLED ... SIGSEGV`: its Windows
pipe code maps an exception's exit status to a signal name. The fallback
driver (`fallback-roots`, this branch) ends every program as this branch's
does, with the guard's line, including the executable's format. Its native
frames run out long before its shadow stack's 2^22 slots, so the guard
reports where until now the process died (section 6).

The line is the same as before wherever the check reported one: in the
driver, `error {NATIVE LIMIT STACK} {native stack exhausted: too many
nested calls}`. An executable used to print the run-time error's own
format and now prints the guard's line, as on Linux and macOS
(`aot-facts`' `standalone-depth-limit` pins it).

### 8.2 Code, checks and time

`bench/root-plans.tcl`, 20 runs by 7 rounds, the drivers alternating
within each round. Times are the median per-run time, the ratio this
branch / 85753d9, and each round's median range:

| Workload | Botlish calls checked for an error | Prologue depth checks | Machine code (bytes) | JIT time, ratio (rounds) | Executable time, ratio |
|---|---|---|---|---|---|
| fib | 3 of 3 → 0 of 3 | 2 → 0 | 416 → 208 (−50 %) | 507.1 → 510.8 µs, 1.007 (505-512 / 511-514) | 1.002 |
| calls | 2 of 2 → 0 of 2 | 2 → 0 | 803 → 646 (−20 %) | 785.9 → 783.9 µs, 0.997 | 0.983 |
| uri | 21 of 25 → 18 of 25 | 12 → 0 | 7,230 → 6,313 (−13 %) | 2,081 → 2,140 µs, 1.028 (2074-2108 / 2068-2225) | 0.996 |
| 2048 | 53 of 55 → 53 of 55 | 23 → 0 | 24,130 → 22,344 (−7 %) | 3,851 → 3,892 µs, 1.011 | 1.011 |
| strings | 1 of 1 → 1 of 1 | 1 → 0 | 407 → 367 (−10 %) | 13,846 → 13,791 µs, 0.996 | 0.998 |
| lists | 3 of 3 → 3 of 3 | 3 → 0 | 888 → 734 (−17 %) | 7,510 → 7,491 µs, 0.997 | 1.042 (7460-7706 / 7240-8601) |

The stack-limit check's cost was its code, not its time:

* **Code.** Every function with a Botlish call lost its prologue compare
  and cold block, and every call whose only possible error was the stack
  lost its status check and error edge. Machine code shrank by 7 to 50 %.
  Unwind information shrank only where a cold block had needed its own
  (`.xdata` 48 → 44 bytes for fib, 556 → 548 for uri).
* **Calls checked.** These fall where the stack was a call's only possible
  error (fib, calls, uri's three). Where a callee can fail for another
  reason (2048, strings, lists), its calls stay checked, as on Linux.
* **Time.** No change outside the noise. The ratios run from 0.983 to
  1.042, both ways, inside the rounds' own spread. The check was a compare
  and a predicted branch per call, and the status check a load and a
  predicted branch, so on this runner neither showed in a call-bound
  recursion (fib) or a workload.
* **The collector.** Under GC stress, collections cost what they did
  (uri 1.39 → 1.33 µs, 2048 1.76 → 1.79 µs, lists 4.38 → 4.17 µs per
  collection): the frames it walks only lost instructions.

The same job compares the native-frame plan with the fallback plan (its
milestone 3 role) on this branch. The fallback still checks depth (2 to 23
prologue checks per workload) and every call it must, and the numbers are
in the run's summary.

## 9. Remaining limitations

* **Interactive consoles are untested.** Every Windows run above wrote the
  line to a pipe or a file: GitHub's runners have no console. On a console
  handle `WriteFile` goes to the console driver (`condrv`) as an ordinary
  `NtWriteFile` on Windows 8 and later. That is code inspection of the
  documented behavior, not a measurement of its stack use in the handler.
* **An access violation stays an access violation.** Code that steps over
  the system's guard page -- a frame larger than a page that probes
  nothing -- faults on the uncommitted reservation, and the guard passes
  that on (`fault reserved`). The process then ends in 0xC0000005, as it
  did before. Botlish code, Rust and MSVC-compiled C probe large frames
  (Cranelift's probes, `__chkstk`), so none of this project's code does
  this. A C library compiled without probes (`/Gs` with a huge threshold)
  would; that is the library's bug, and the guard never relabels it.
* **One stack per guard.** The guard watches the thread that installed
  it: the worker that runs Botlish code. An exhaustion on any other
  thread -- the driver's main thread, a thread C code starts -- is passed
  on to Rust's handler and the system, as on Linux and macOS. There are no
  native coroutines on Windows (next section), so no second stack runs
  Botlish code there.
* **The guarantee outlives the guard.** `SetThreadStackGuarantee` cannot
  lower a guarantee, so the worker thread keeps 32 KiB after the guard is
  dropped. The thread ends with the run, so this costs nothing in practice.
* **Another first handler comes first.** A vectored handler that C code
  adds later with `First = 1` runs before the guard's. If it consumes
  `STATUS_STACK_OVERFLOW` or uses up the guarantee, the guard never sees
  the exception. No C code this project calls does that.
* **The write is best effort.** A destination that refuses the write (a
  closed pipe, no standard error) loses the line; the exit status is still
  the guard's. That matches the POSIX guard.
* **The fail-fast path is unobserved.** `TerminateProcess` of the calling
  process never returned in any experiment or test, so the
  `int 0x29` after it is code inspection only.
* **What remains of the stack check is the fallback plan's.** A build with
  `fallback-roots` still checks its shadow stack's depth in every function
  with a Botlish call and keeps those call effects (section 5). That is
  by design, not a leftover of milestone 3.

## 10. Next milestone

With the guard in place, Windows x86-64 lacks two native capabilities that
Linux and macOS have (`native/native.tcl`'s `capabilities`, the
windows-x86_64 row of `tests/platform/native-status.tcl`):

* **Native coroutines** (`coroutines`). They are the larger of the two,
  and this milestone removes their prerequisite: AGENTS.md holds that a host
  with native coroutines needs native-frame roots, and native-frame roots
  need a guard (section 5). A coroutine's stack on Windows needs:
  - a reservation of its own with a guard page below its committed top,
    so Windows grows it as it grows a thread's;
  - a switch that also exchanges NT_TIB's `StackBase` and `StackLimit` and
    the TEB's `DeallocationStack` (gs:0x08, gs:0x10, gs:0x1478). Windows
    reads these to decide whether a fault grows the stack or raises
    `STATUS_STACK_OVERFLOW`, and `GetCurrentThreadStackLimits` reads them;
  - a guarantee on every coroutine stack. A stack guarantee belongs to the
    thread (the TEB's `GuaranteedStackBytes`), so the switch must carry it
    too, or every coroutine stack must keep the room;
  - publication of the running stack's reservation to the guard
    (`STACK_LOW`/`STACK_HIGH` today), on arrival, as the POSIX switch
    publishes;
  - Win64's callee-saved registers in the switch: XMM6 to XMM15, beside the
    integer ones;
  - unwind information for the switch and the trampoline, so that the
    collector's walk (`RtlVirtualUnwind`, milestone 3) can cross a resumer's
    frames.

  The alternative is Windows' own fibers (`CreateFiber`,
  `SwitchToFiber`), which keep the TIB fields themselves. Choosing between
  them is that milestone's first experiment.
* **Variadic C calls** (`cVariadics`). They need a Win64 lowering checked
  against MSVC-built callees, with a double passed in both registers
  (AGENTS.md, "Windows x86-64 (MSVC)"). This is the smaller one.

The recommendation is native coroutines next. They would also let the
golden suites run on Windows' native backends: the golden runner
(stdlib/test.bot) is a coroutine, so every acceptance shard above ran
them on interp and compile only. The guard it needs is the
one this milestone built, and the Windows guard's design (one stack's
bounds, published, read by the handler) already leaves room for a running
stack that changes.
