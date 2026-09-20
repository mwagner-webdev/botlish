# Closed-call value facts

## Scope and implementation

This milestone propagates argument and successful-result value facts across exact, statically resolved Botlish calls. It does not infer may_error, may_gc, purity, or totality, and it does not inline or remove a call.

Changed compiler files: hir/specialize.tcl, hir/range.tcl, native/lower.tcl, and native/explain-native.tcl. Regression coverage is in tests/hir-call-facts.test and adjusted structural expectations in tests/hir-specialize.test, tests/native-root-liveness.test, tests/native-tcl-unicode.test, and tests/surface-modules.test. Before/after diagnostic layers are under audit/post-call-facts/.

Before this change, specialization already keyed exact calls by bounded argument types (at most eight specialized instances per source block and 1,000 overall), re-inferred HIR for each instance, joined captured types across creations, and propagated per-instance result types through its own worklist. Named refinement evidence already had an intersection mechanism, and hir/range.tcl already joined caller expression ranges at exact instance calls, including recursive widening. These mechanisms remain the fact channels. The missing pieces were: a value-capturing step was forced to a generic instance despite an exact caller; range analysis did not read a callee's successful-result range at a call.

Exact calls of closures with proven Int captures may now choose the existing kind-keyed specialization. Other value-capturing closures retain the generic policy to control code growth. Captured type seeds are joined across creations and re-analysis is queued if they broaden. Materialized Block values keep a generic entry. The sum benchmark's step gains an Int parameter from sum's refined accumulator; its captured n also has Int kind. The accumulator's magnitude remains unknown, so its numeric range does not become small merely because the call is exact.

The range analysis now tracks loop break values, joins them into the function's successful-result summary, and feeds per-instance result ranges to exact callers during its existing instance rounds. The local proof for work is semantic HIR algebra: an immutable binding b computed by successful arbitrary-precision addition a + 7 makes successful b - a equal 7. Proven error-only native paths add no successful result value. An initial unknown summary is provisional while entry ranges settle; after a concrete summary appears it only widens, and a later invalidation permanently yields unknown. The round budget scales with instance count and throws rather than publishing stale facts if it fails to converge. Existing parameter feedback uses interval hulls and widening, so two callers with [0,10] and [20,30] contribute [0,30] to a shared instance. Recursion follows the same finite widening mechanism.

The result summary belongs to a specialization instance. The successful-result range is distinct from the call's completion and effects. Lowering keeps the exact call, then substitutes a proven small Int constant for later value uses. It never uses a constant result to suppress the call, its no-value check, or its safepoint. Open trait dispatch, dynamic Block calls, unknown function values, and runtime native-name dispatch receive no new facts. Existing native metadata remains intact.

Use -call-facts-opt 0 or BOTLISH_NATIVE_CALL_FACTS_OPT=0 for a differential baseline. The flag disables the new closure specialization and result feedback while leaving the older specialization, refinement, and caller-range mechanisms active. native/explain-native.tcl now emits call-facts.txt with the target, argument kind and range, and successful-result kind and range.

## sum-refined

The unmodified bench/sum-refined.ir has a closed call from sum<int,int> to its local step. Before, step was generic because it captured n. After, the exact call selects step<int>. The semantic generic entry still has an Int guard and arbitrary-precision addition for open callers; only the exact specialization omits the redundant Int-kind guard.

| Layer | Flag off | Flag on |
|---|---|---|
| HIR instance call | sum<int,int> to step<generic> | sum<int,int> to step<int> |
| Callee parameter | x: any; range unknown | x: Int; range unknown |
| NIR | guard int x; checked tagged iadd | no Int guard; checked tagged iadd |
| True VCode | tag and heap-kind guard, cold type-error call, checked addition | guard and type-error path absent; checked addition remains |
| x86-64 step | 206 bytes | 98 bytes |

The sum function remains 162 bytes and still boxes its raw n when passing the captured argument through the tagged call ABI. The call remains direct. The step fast path still checks tags and overflow and retains the cold rt_int_add fallback. This is required: Int kind alone does not prove the accumulator and addition result fit a machine small Int. The sum caller still checks the call result for no-value/error, and its two root slots and call safepoint remain. The removed assembly includes step's Int tag/heap-kind tests and cold rt_type_error sequence; the corresponding operations also disappear in VCode, so the gain is upstream of register allocation.

The generic entry is verified separately through an open Block call with a wrong-kind argument, and a closed BigInt input agrees with the flag-off result. The benchmark value remains 80200.

## loop-count, fib, and refined-checks

For the unmodified bench/loop-count.ir, work<int> has parameter i in [1,500]. Its successful returning paths produce exactly 7; the other branch may diverge. Before, the range pass reported an unknown result at drive's call. After, call-facts.txt shows [7,7]. Drive's NIR still has call work, followed by a tagged literal 7 for the successful value. True VCode and x86-64 retain the call and the post-call no-value test. The machine code uses the tagged literal 0xf and adds 0xe to the tagged total on the fast path. The overflow test and cold rt_int_add remain because total is not proven bounded. Drive shrinks from 373 to 365 bytes; work remains 54 bytes. Drive keeps three root slots and its call safepoints.

The returning-value fact does not prove that work terminates for every input or cannot Error or GC. Those properties are outside this pass. Its body must run, and its call must remain.

Fib remains 463 bytes. Its recursive result range remains unknown, so its checked result addition and BigInt fallback are still justified. No Fibonacci-specific recurrence proof was added. Refined-checks remains 21,002 bytes and returns [400,0]; its String work is unchanged.

## Corpus and performance

The 13-program post-stack corpus uses the same 194 emitted native functions. Generic versus specialized counts change from 58/136 to 57/137: step<int> replaces the emitted step<generic>. No new function is duplicated in the emitted corpus. Total object-function machine code changes from 89,512 to 89,118 bytes (-394, about -0.44%). The largest matched shrink is 108 bytes for step; ht_rehash_scan also shrinks by 104 bytes in each hashtable inclusion. One program, csv_chunked, grows by 20 bytes.

| Program | Bytes off | Bytes on | Root slots off/on |
|---|---:|---:|---:|
| sum-refined | 452 | 344 | 6 / 6 |
| loop-count | 511 | 503 | 5 / 5 |
| csv_chunked | 10,496 | 10,516 | 96 / 96 |
| csv_records | 22,468 | 22,322 | 177 / 176 |
| hashtable | 13,704 | 13,552 | 89 / 88 |
| fib | 463 | 463 | unchanged |
| refined-checks | 21,002 | 21,002 | unchanged |

Corpus root slots total 665 to 663; root candidates 1,046 to 1,042. The two reduced slots are in csv_records and hashtable. Corpus safepoints 607 to 605 arise from existing raw-arithmetic proof removing two possible arithmetic helper calls. Classification of every surviving exact Botlish call remains unchanged. NIR guard sites total 85 to 84, solely step's Int guard. Tagged iadd sites 106 to 104; raw riadd sites 11 to 13, through existing range and representation lowering in the hashtable corpus. The other changed function instances are listed in the corresponding generated per-program summaries and assembly.

Canonical best-of-five benchmark measurements (single WSL host; JIT compilation excluded) are directional because the small native workloads approach timer overhead:

| Program | Cranelift off | Cranelift on, final pass | Value |
|---|---:|---:|---|
| fib | 188.88 us | 191.01 us | 17711 |
| loop-count | 1.79 us | 1.41 us | 3500 |
| sum-refined | 1.51 us | 1.10 us | 80200 |
| refined-checks | 1.6 ms | 1.5 ms | [400,0] |

The final on run followed constant-result lowering. The native improvements are directional observations; structural NIR, VCode, and assembly are the primary evidence.

## Rust and Go comparison

The executing Botlish-only step kind guard and cold type-error path have disappeared. The remaining tagged argument conversion, tagged checked addition, BigInt fallback, completion test, and GC root publication implement Botlish's arbitrary-precision Int, error completion, and GC contracts under the currently available proofs. Rust and Go use fixed-width integers; they inline their local step and do not implement these Botlish checks. Go also has its own stack check. Botlish still makes one real step call per iteration, while the reference compilers inline it. The known loop-carried physical copy pattern attributable to regalloc2 #265 remains separate; no NIR or call-fact workaround was added.

## Verification and next milestone

Focused tests cover exact and open calls, the generic Int guard, BigInt and wrong-kind outcomes, successful result constant and join, an error-only branch, work's divergent branch, cross-module argument and result facts, and on/off native outcome parity. Existing range tests cover mixed callers and recursive convergence. Full Tcl 9 parity passed: 1,458 tests in each of the interp and compile phases. The same full suite passed with BOTLISH_NATIVE_GC_STRESS=1. Release Rust tests passed (53 tests). Canonical benchmark values matched across all backends. No stack, root ABI, String/Bytes, inliner, or effect-summary work was added.

The next milestone can attach may_error and may_gc summaries to the same exact instance identities. This pass provides value summaries only and does not consume those effect facts.


## Direct audit answers

1. Sum previously selected step<generic> because step captured a value and the old specialization policy forced every such closure to its generic entry.
2. Step now receives Int kind for x from sum's refined accumulator. Its magnitude remains unknown; captured n has Int kind but no seeded capture range.
3. The executing step Int guard and cold type-error path disappear.
4. Tagged argument handling, overflow checking, and rt_int_add remain because neither argument/result range proves a small-Int addition.
5. Yes. An open generic step entry retains the guard and BigInt-capable arithmetic.
6. Work<int> exposes successful result range [7,7].
7. Yes. Drive's exact call sees [7,7] and uses tagged literal 7 after the call.
8. Yes. The work call remains in NIR, VCode, and x86-64.
9. Yes. The caller still tests the work call result for no-value/error.
10. A known value says nothing about Error, GC, divergence, or other effects, so it cannot justify call deletion.
11. Exact callers of a shared instance contribute interval hulls; kind keys and captured seeds use their existing joins. An open generic entry stays conservative.
12. Self calls widen parameter ranges, cross-instance calls use prior-round summaries, and the worklist repeats to a stable point with a finite budget.
13. The emitted corpus remains at 194 instances. Its mix shifts by one from generic to specialized.
14. Yes. The plain::inc cross-module fixture has parameter [1,1] and successful result [2,2].
15. Yes. Root slots fall by one in csv_records and one in hashtable through ordinary representation/root lowering.
16. Fib's NIR and 463-byte machine code do not change.
17. Its recursive successful-result range remains unknown, so unchecked result addition would be unjustified under arbitrary-precision Int semantics.
18. Sum loses the step tag/heap-kind guard and type-error call sequence. The same work is absent in VCode.
19. Relative to Rust, Botlish still has arbitrary-precision overflow behavior, error completion, GC roots, and a real closed step call.
20. Relative to Go, the same semantic costs remain; Go additionally has its own stack check while it inlines step.
21. The known loop-carried physical copy pattern remains attributable to regalloc2 #265. This pass does not alter it intentionally.
22. The exact instance identities and value summaries are suitable inputs for a later may_error/may_gc milestone. No such effect summaries are implemented here.
