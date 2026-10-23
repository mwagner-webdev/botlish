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

⟨RESULT⟩

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
check, and the guard now also covers it -- a `fallback-roots` driver on a
small stack whose native frames run out before its shadow stack does
(2^22 slots) ends in the guard's report, where until now the process died.

## 7. Tests

### 7.1 Real exhaustion, case by case

Every case runs the program in a process of its own -- the driver, an
executable, or a child of the native stack test -- so a terminal failure
never ends the harness. No case asserts a depth: each asserts how the run
ended.

| Case | Required | Where tested | On Windows |
|---|---|---|---|
| deep Botlish recursion, default 1 GiB stack | terminal NATIVE LIMIT STACK | native-status `stack-depth-limit`, `recursion-limit`; native-stack-overflow.test `native-stack-overflow-default-size`; aot-facts `standalone-depth-limit`; before-after `down` | ⟨W⟩ |
| deep Botlish recursion, small stack (1, 4, 16 MiB) | the same | native-status `stack-overflow`; native-stack-overflow.test `native-stack-overflow-1`, `ns-main-small-stack`, `ns-main-shapes`; aot-facts `standalone-stack-overflow`; native-executable.test | ⟨W⟩ |
| deep recursion with many live roots | the same | `ns-main-shapes` (a String, six Ints held across the call), `ns-gc-stress-main` (allocating, under GC stress, 1 MiB) | ⟨W⟩ |
| a large frame | growth, or the report | native-status `large-frame-overflow`, `native-stack-overflow-wide-1` (600 live values, unrolled probes) | ⟨W⟩ |
| frames using Cranelift's probe loop | the same | `native-stack-overflow-probe-loop` (3000 live values, about 24 KiB a frame); native_stack's `probe-loop` (the loop's access pattern in Rust); milestone 3's single-step unwind of probe loops (unchanged, green) | ⟨W⟩ |
| exhaustion in a Rust helper | terminal report | native-status `runtime-stack-overflow`, `ns-runtime-helper` (a List equality a million deep on 16 MiB), aot-facts `standalone-runtime-overflow`, native-executable.test; native_stack's Rust recursions (small frames, 64 KiB frames) | ⟨W⟩ |
| exhaustion in a C function | terminal report | c-ffi.test `cf-c-stack-overflow` (MSVC-compiled `bcf_deep`), in the linked run and as an executable | ⟨W⟩ |
| linked run | the driver's report, exit 0 | `cf-c-stack-overflow` (the driver protocol) | ⟨W⟩ |
| standalone executable | the line on standard error, exit 1 | aot-facts, native-executable.test, native_stack `executable` | ⟨W⟩ |
| an ordinary invalid access | not NATIVE LIMIT STACK | native-status `c-access-violation` (memset through null, in C, through the real driver); native_stack `fault null`, `fault reserved` | ⟨W⟩ |
| an exception on another thread | not claimed | native_stack `fault other-thread` (an exhausted thread), `fault other-thread-raised` (a record naming the guarded stack) | ⟨W⟩ |
| deep recursion that fits | completes | native-status `jit`; `ns-main-finite`; aot-facts `standalone-deep-finite`; native_stack `finite`; before-after `finite` | ⟨W⟩ |

⟨TESTS-REST⟩
⟨SECTIONS 8-10⟩
