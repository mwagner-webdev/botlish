# Phase B: native stack overflow protection

The x86-64/Linux JIT runs on the existing Rust worker pthread. `main.rs`
requests a 1 GiB stack with `thread::Builder::stack_size`; the optional
`BOTLISH_NATIVE_STACK_BYTES` override is used by overflow tests. The JIT,
Rust runtime helpers, and ordinary C ABI calls use this same stack.

`NativeStack` describes the usable half-open range, guard start, active
state, and a dormant saved stack pointer. It has no knowledge of frame
pointers or GC offsets. On Linux, `pthread_getattr_np` followed by
`pthread_attr_getstack` and `pthread_attr_getguardsize` discovers the
actual stack and guard. glibc/NPTL places the guard inside the pthread
allocation; the reported stack range is the usable part. This is why the
guard lies immediately below `low_bound`, and why the discovered usable
size may be slightly smaller than the requested builder size. See the
[Linux pthread guard manual](https://man7.org/linux/man-pages/man3/pthread_attr_setguardsize.3.html)
and [glibc's pthread attribute implementation](https://codebrowser.dev/glibc/glibc/nptl/pthread_getattr_np.c.html).

A 64 KiB alternate signal stack is installed on the worker before JIT
execution. The SIGSEGV/SIGBUS handler compares the fault address with that
worker's discovered guard interval and checks the faulting thread ID. For a
guard fault it writes the existing `error {NATIVE LIMIT STACK} ...` protocol
line with the async-signal-safe `write` syscall, then calls `_exit(0)`.
The handler does no allocation, locking, formatting, GC, or Rust unwinding.
An unrelated fault gets the default signal disposition. The process exit
means no exhausted Rust or JIT stack is resumed and no destructor is
skipped within a continuing process. The OS reclaims the whole process.

This is a deliberate recovery boundary: a guard fault becomes the same
external Botlish error result, but it cannot populate `Vm::error` or let a
`bench` process continue to its next run. An in-process recovery would
need a separate, audited entry boundary that can unwind only JIT frames;
jumping over arbitrary Rust helpers would violate their invariants. Each
normal CLI execution is already a separate process, and two independent
overflow executions are tested.

Cranelift's default large-frame stack probes are disabled. On the supported
target, inline probes at 4 KiB spacing are enabled. They add no check to
ordinary small-frame calls and prevent a large frame from skipping past
the pthread guard. A recursive frame with 600 simultaneously live list
values emits the probes and reaches the same controlled overflow result.

The x86-64 frame walker receives the current `NativeStack` bounds through
`Vm`. It validates the saved-frame and return-address pair before
dereferencing them and checks each computed root address. Existing
alignment, monotonicity, and maximum-frame checks remain. Frame-pointer
semantics stay in `framewalk.rs`.

On x86-64/Linux, `RootPlan::depth_reservation` is false, the per-call
`prologue_depth_token` and restore are bypassed, and `Vm::shadow` is
empty. Generated code has no `ss_top`, `ss_limit`, zeroed depth-token, or
prologue `rt_stack_overflow` traffic. The old RuntimeStack storage and
depth check remain for unsupported targets. Native root slots, stack maps,
and safepoints are unchanged.

## Assembly

The committed scalar audit was regenerated with Tcl 9. `fib<int>` before
Phase B used 700 bytes across its two functions. Its recursive function
began with:

```asm
mov rbx,[rdi]
mov rax,[rdi+0x8]
lea rcx,[rbx+0x8]
cmp rcx,rax
ja overflow
mov [rdi],rax
mov [rbx],0
mov [rsp+0x8],0
```

After Phase B the same program uses 463 bytes. The recursive function
starts with normal frame setup and a native root-slot initialization:

```asm
push rbp
mov rbp,rsp
sub rsp,0x30
mov [rsp+0x8],0
...
mov [rsp],rsi
call botlish_fn_1
...
mov [rsp+0x8],rsi
call botlish_fn_1
```

Its `rt_stack_overflow` cold block is gone. The additional recursive,
allocating `build(400)` function also has native root stores and its
recursive call, with no shadow-depth traffic. Its program code size falls
from 700 to 447 bytes. The wide recursive fixture confirms inline probe
instructions precede the large frame allocation.

## Verification

The Linux release backend passes the native stack-map, root-storage,
native integration, and new guard tests. The new tests run shallow fib,
two independent overflowing processes, a large-frame overflow, and 400
simultaneously live recursive allocating frames under
`BOTLISH_NATIVE_GC_STRESS=1`. The latter returns the expected 800-character
string. Rust unit tests check pthread discovery and explicit frame bounds.

Ordinary foreign calls remain on the pthread stack and retain the normal
SysV ABI. A later coroutine can carry its own `NativeStack`, saved stack
pointer, and continuation; this phase adds no stack switching.

## Benchmarks

Linux/WSL x86-64, release builds from the unchanged commit and Phase B,
same NIR inputs. Each entry is the median of five process medians; process
order alternates. Timings exclude JIT compilation. Values below are
microseconds per run; code size is total generated function bytes.

| Program | Before | After | Change | Code bytes |
|---|---:|---:|---:|---:|
| fib | 214.624 | 193.642 | -9.8% | 700 ? 463 |
| sum-refined | 1.297 | 1.497 | +15.4% | 674 ? 452 |
| loop-count | 1.596 | 1.896 | +18.8% | 731 ? 511 |
| build(400) | 39.601 | 40.200 | +1.5% | 700 ? 447 |
| build(400), GC stress | 3555.389 | 3995.187 | +12.4% | 700 ? 447 |

The fib result is consistent with removal of its per-call sequence.
Sub-2-microsecond scalar differences are sensitive to code layout and
WSL scheduling. Forced GC remains dominated by native frame walking and
did not improve in this measurement.
