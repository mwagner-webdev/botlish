# Phase B milestone: native stack bounds replace the remaining shadow recursion guard

This document records the Phase B change in the native runtime and the updated test assumptions that go with it.

## Scope

This milestone does not re-implement the earlier Phase A root-storage work. The stack-map/native-frame root discovery already in place remains the basis of the design. The remaining gap was the last primary-path recursion-depth token: a shared shadow-stack reservation that still existed even though root storage had already moved off the runtime shadow stack.

Phase B removes that remaining shadow recursion-depth guard from the primary x86_64/Linux path and replaces it with the active native stack bounds.

## New contract

On the primary path:

- GC roots live in native frame slots, discovered through stack maps plus the rbp chain.
- The collector walks the active native call stack and uses per-safepoint metadata to find live roots.
- Recursion overflow is detected using the current thread's native stack bounds, not a one-slot `ss_top`/`ss_limit` reservation.
- The old `rt_stack_overflow` helper is no longer expected on the primary path for the shadow depth-token case.

On the legacy fallback path:

- The old `RuntimeStack` guard remains available for unsupported hosts / non-stack-map execution.
- That fallback still preserves the older behavior and safety net, but it is no longer the default when the native frame-walk path is active.

## Why the change is correct

The underlying GC behavior is unchanged: the test suite still checks the same things as before, just under the new assumption that stack overflow protection comes from the machine stack itself rather than the shadow stack.

The core invariants remain:

- root discovery still works across calls and recursive frames
- stack maps still locate live values in suspended Botlish frames
- collections under `BOTLISH_NATIVE_GC_STRESS` still preserve live roots
- function behavior and runtime semantics are unchanged

The only changed assumption is where the recursion limit is enforced.

## Updated test assumptions

The tests now capture the Phase B contract rather than the old shadow-depth implementation detail.

Examples:

- `fib<int>` still uses `NativeFrame` storage
- `fib<int>` no longer expects a shadow depth reservation on the primary path
- call-crossing roots still resolve to native frame storage
- `rt_stack_overflow` is no longer required in the primary stack-map CLIF path for these cases

This preserves the same functional coverage as before while removing the implementation-specific expectation that a recursion guard must use the shared runtime shadow stack.

## Coverage retained

The rewritten suite still covers the same functionality as the pre-change version:

- root storage layout
- native frame reuse and slot assignment
- multi-frame root discovery across recursive calls
- foreign frame boundary handling
- GC under stress
- call-crossing root survival
- value preservation across later allocations

In short, the behavior remains the same; only the overflow mechanism moves from the shadow stack to the thread's actual native stack bounds.
