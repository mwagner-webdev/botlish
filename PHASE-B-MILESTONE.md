# Phase B milestone: NativeStack bounds are useful, but real native guard-page overflow remains pending

This document records the current state of the native-stack-overflow work accurately: the `NativeStack` bounds integration and the frame-walk bounds validation are useful improvements, but they do not implement the real Linux guard-page control path for native stack exhaustion.

## Current status

The repository already has several important pieces in place:

- `NativeStack` reads the active thread stack bounds and exposes `contains_address`/`contains_frame` checks.
- `framewalk.rs` stops walking when the rbp chain or safepoint addresses leave the bounds of the active stack.
- the collector continues to rely on native frame root discovery and stack maps for GC root traversal.

Those are valid improvements, but they are not the same thing as native-stack-overflow detection. A frame walker runs during collection, after the stack has already been reached; it cannot detect the ordinary guard-page fault that occurs when recursive execution pushes past the native stack limit.

The current implementation therefore keeps the existing shadow-recursion reservation as the actual overflow-safety mechanism until a real signal-and-recovery path is demonstrated.

## Safe contract for now

On the primary path:

- GC roots still live in native frame slots and are discovered through stack maps plus the rbp chain.
- the collector may still use `NativeStack` bounds to constrain frame walking and to reject out-of-bounds frames during collection.
- recursion overflow is still guarded by the existing shadow depth token until the real guard-page signal path is in place.
- `rt_stack_overflow` remains expected on recursive call paths where the old guard is still the effective overflow check.

On the legacy fallback path:

- the old `RuntimeStack` guard remains available for unsupported hosts or non-stack-map execution.
- fallback behavior is still preserved as a compatibility and safety net.

## Why this is the correct interim state

The root cause is that guard-page faults are not equivalent to frame-walk termination:

- `framewalk.rs` only runs while collecting, not while ordinary recursive execution is still pushing frames
- the OS produces a SIGSEGV/SIGBUS when the stack hits the guard page
- the runtime must positively identify that fault as belonging to the active native stack guard region and recover through a safe, controlled path
- that actual fault-handling mechanism is not yet implemented, so removing the shadow depth reservation would discard the only working overflow safety mechanism

This milestone therefore keeps the old shadow depth bookkeeping in place while retaining the NativeStack/framewalk improvements as independent work.

## Test expectations retained

The current test suite reflects the safe intermediate state:

- `fib<int>` keeps `NativeFrame` storage
- recursive functions on the primary path still import the shadow depth-token overflow helper until the real guard-page path exists
- the new `NativeStack` bounds checks remain valid and independent of overflow detection
- the runtime still distinguishes genuine stack-overflow conditions from unrelated faults only once that actual signal path is added

This is intentionally conservative: it preserves the working runtime safety mechanism while leaving the separate native-stack-bounds improvement in place.

## Deliverable status

The project is not yet ready to claim the Phase B milestone as complete. The missing pieces are:

- actual guard-page size/region discovery for the active thread
- exact Linux fault signal behavior on guard-page access
- whether `sigaltstack` is required and how it is used safely
- a real recovery path that leaves the signal handler and resumes execution on a usable stack
- a test that intentionally exhausts the real native stack and verifies the controlled Botlish stack-overflow result
- a test showing an unrelated invalid-memory fault is not classified as stack overflow

Until that is implemented and demonstrated, the shadow depth reservation remains necessary and correct.
