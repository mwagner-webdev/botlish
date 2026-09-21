# Closed-call effect summaries

## Outcome

Exact, statically resolved NIR calls now carry two independent settled facts: `may_error` and `may_gc`. The analysis runs after specialized HIR has become NIR, so removed guards, raw arithmetic, scalar replacement, exact instance identities, and reachable runtime fallbacks are already reflected. Calls remain calls. The facts only suppress an impossible no-value check and/or remove that call instruction from GC-safepoint planning.

Changed compiler files:

- `native/lower.tcl`: `-call-effects-opt` / `BOTLISH_NATIVE_CALL_EFFECTS_OPT`, emitted as the NIR program option `call-effects=0|1`.
- `native/src/nir.rs`: independent call fields, per-function summaries, local-effect scan, graph fixpoint, and focused tests.
- `native/src/runtime/ops.rs`: authoritative `op_may_error`, alongside existing `op_may_allocate`.
- `native/src/codegen/clif.rs`: conditional post-call completion check and stack-map marking.
- `native/src/codegen/roots.rs`: direct calls are safepoints exactly when their settled `may_gc` is true; diagnostics show both function effects.

Focused ON/OFF artifacts are in `audit/post-call-effects/{loop-count,sum-refined,fib,refined-checks}/{on,off}`. Each directory contains HIR, specialization and range explanations, exact call facts, NIR, CLIF, and roots. These committed artifacts do not yet include true VCode or disassembly.

## Semantics and representation

`may_error=true` means some reachable execution path can produce the runtime `NO_VALUE` sentinel after recording a Botlish semantic error. Direct sources are guards, Boolean guards, unbound-cell checks, explicit `raise`, dynamically dispatched calls, and NIR operations classified by the runtime ABI failure table. OOM, signals, assertions, and divergence are not Botlish Error completions.

`may_gc=true` means some reachable operation can invoke managed collection before the function returns. Direct sources are managed cell/closure construction, NIR operations accepted by the existing `op_may_allocate` authority, and dynamic calls. Allocation is semantic and conservative, not profile-dependent.

The two booleans are stored separately on each exact NIR function and each direct-call instruction. Tests cover false/false, false/true, true/false, and true/true.

The pass first scans every body for direct local effects, initializes the two monotone lattices to false, and repeatedly unions exact callee summaries until no summary changes. Recursive SCCs therefore converge by false-to-true growth. No call flags are published until the whole fixpoint is complete. Dynamic calls remain true/true. With `call-effects=0`, analysis remains available on functions but every direct call is published conservatively as true/true.

This placement is deliberately downstream of specialization/value facts but upstream of root liveness and Cranelift. It reuses final specialized NIR semantics rather than duplicating native-registration metadata. `op_may_allocate` remains the GC authority; `op_may_error` is the parallel completion authority derived from the runtime ABI table.

## Primary structural evidence

| Workload / exact target | successful value | may_error | may_gc | completion check | call safepoint |
|---|---:|---:|---:|---|---|
| `drive<int,int> -> work<int>` | `[7,7]` | false | false | removed | removed |
| `sum<int,int> -> step<int>` | Int, nonconstant | false | true | removed | retained |
| recursive `fib<int> -> fib<int>` | Int, range unknown | false | true | removed | retained |

### loop-count

`work<int>` contains no reachable guard, error-producing op, allocation, or call, so it is false/false. Its divergent path does not alter either summary. In `drive`, the direct call remains visible in NIR and CLIF, but its sentinel branch and stack map disappear.

`drive` root consequences:

| metric | OFF | ON |
|---|---:|---:|
| safepoints | 2 | 1 |
| root candidates | 4 | 3 |
| physical root slots | 3 | 3 |
| entry-zero slots | 0 | 0 |

Slots do not fall because the remaining arbitrary-precision addition safepoint still needs three simultaneously live roots. Machine code for the whole program falls from 765 to 672 bytes (-93). `work` itself remains 78 bytes and its call remains semantically mandatory.

### sum-refined

`step<int>` is false/true. Specialization removed its Int-kind error path, while checked `iadd` retains the reachable BigInt allocation fallback. Consequently `sum` loses the post-call completion check but retains the call safepoint, root publication, two physical slots, and arbitrary-precision arithmetic. Whole-program code falls from 604 to 516 bytes (-88).

### fib

`fib<int>` converges through the ordinary recursive fixpoint to false/true. Recursive completion checks disappear; all three safepoints, four root candidates, two physical slots, one entry zero, and checked BigInt-capable result addition remain. Whole-program code falls from 724 to 607 bytes (-117).

### refined-checks

Allocation-heavy behavior remains. Selected nonallocating exact calls cease to be safepoints, but allocating String/List paths remain MayGc. Whole-program code changes from 25,227 to 25,209 bytes (-18). The committed roots reports provide the per-instance detail; no algorithmic String optimization was made.

Across these four focused programs, measured machine code changes from 27,320 to 27,004 bytes (-316). Largest shrink is `fib` (-117); no program grows. This is not presented as the requested 13-program corpus census.

## Lowering and roots

For a direct call whose `may_error` is false, Cranelift uses the unchanged return ABI and simply omits `check(result)`. `NO_VALUE` remains reserved. For a call whose `may_gc` is false, `roots::is_safepoint` returns false and codegen does not attach a stack map. F3 liveness, coloring, F3b entry initialization, and root stores then recompute normally. No special case was added inside F3/F3b.

The pass does not infer purity, termination, totality, side-effect freedom, or removability. It does not reorder, eliminate, inline, hoist, or CSE calls. Generic/dynamic calls retain conservative bookkeeping.

## Verification

- Rust release tests: 55 passed, including three new effect groups (independence matrix, transitive/recursive convergence, feature-OFF conservatism).
- WSL Ubuntu 24.04, Tcl 9.0, `BOTLISH_NATIVE_GC_STRESS=1`:
  - interpreter phase: 1,458/1,458 passed;
  - compile phase: 1,458/1,458 passed;
  - focused native root-liveness suite: 17/17 passed.
- Primary ON/OFF NIR, CLIF, roots, outcomes, and code sizes were regenerated.

GC stress revealed no unsound non-MayGc classification on the supported Linux stack-map path. Windows stress runs crashed even with `call-effects-opt=0`; WSL verification isolates that as a pre-existing/platform-specific native stack-walking issue, not an effect-summary result.

Not measured in this snapshot: the full 13-program census, canonical/repeated benchmark timings, VCode/disassembly files, and the requested Rust/Go assembly refresh. Those are reporting gaps, not claimed results.

## Answers

1. `may_error` means a reachable path can return `NO_VALUE` with a recorded Botlish semantic error.
2. `may_gc` means a reachable path can invoke managed GC before return.
3. Yes, they are independent booleans.
4. Reachable NIR guards, checks, raises, constructions, dynamic calls, and authoritative runtime-op classifications contribute local effects.
5. Exact direct-call edges union the target's two settled bits independently.
6. A monotone false-to-true whole-graph fixpoint handles recursion; consumers run only afterward.
7. Yes. A specialized instance can lose a guard while a generic entry retains it.
8. Yes: `step<int>` and `fib<int>` are false/true.
9. Yes; the test matrix uses fallible nonallocating modulo as true/false.
10. `work<int>` is false/false.
11. `drive` loses the work-result completion check and that call's safepoint/root obligation.
12. Yes, the work call remains.
13. `step<int>` is false/true.
14. `sum` loses the post-call completion check.
15. Its safepoint and roots remain because checked addition can allocate BigInt.
16. `fib<int>` is false/true.
17. No, its exact recursive-call completion tests are unnecessary and removed.
18. Yes, recursive safepoints/roots remain because reachable checked addition is MayGc.
19. The four-program focused snapshot shows the expected primary removals; a 13-program call-site count was not measured.
20. `drive -> work` and selected refined-checks calls cease to be safepoints; a complete corpus count was not measured.
21. In `drive`, candidates fall 4 to 3 while slots remain 3; broader corpus pressure was not measured.
22. No. F3/F3b required no special-case logic.
23. No on WSL/Linux; both full 1,458-test phases pass under forced GC stress.
24. Remaining primary differences include arbitrary-precision overflow fallbacks, managed-GC roots at real allocation paths, real non-inlined calls, and language divergence/error semantics—not unconditional closed-call completion bookkeeping.
25. The remaining broad scalar candidate should be selected from a fresh audit; this milestone does not implement it. The known regalloc2 copy issue remains upstream and was not changed.