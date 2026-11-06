# Counted-loop entry: the differential

`tclsh9.0 audit/emission-claims/tools/loops.tcl -count 150 -seed S -cross 10` for S = 11, 12, 13 (EMISSION-COUNTED-LOOP-PRECISION-MILESTONE-1.md, section 12): every claim checked by the compiler and by the rule before that milestone, every (a, n) of the box run on the Tcl compiler (every tenth case also on interp, cranelift-generic and cranelift) and judged by the reference interpreter. Each seed's precision limits (a claim not proved whose every run in the box is valid) are printed with their programs; a false certificate or a regression would be too.

## Seed 11

```
case 45 (n:returns, loop i from 9223372036854775809 to n, helper-invalid; offset 9223372036854775808; ones): rejected EMIT-REJECTED (before: rejected)  (precision limit: no run in the box shows an invalid trace)
fn f45(a: int, n: int) -> unit errors Bad emits ones:
    if n < 9223372036854775810:
        yield 49
        yield 49
        return unit
    loop i from 9223372036854775809 to n:
        sym_then_maybe_fail(49, i == 9223372036854775806):
            on Bad:
                yield 120
        continue
    unit
case 58 (a:upper, n:lower, loop i from -2 through n, continue, helper; offset 0; ones): rejected EMIT-INCOMPLETE (before: rejected)  (precision limit: no run in the box shows an invalid trace)
fn h58(a: int, n: int) -> unit errors Bad:
    if a > 0:
        fail Bad
    if n < -1:
        fail Bad
    loop i from -2 through n:
        if i == -2:
            continue
        yield 49
        continue
    unit

fn f58(a: int, n: int) -> unit errors Bad emits ones:
    h58(a, n)
    unit
case 99 (a:upper, loop i down from a through a, first-differs; offset 0; ones): rejected EMIT-INCOMPLETE (before: rejected)  (precision limit: no run in the box shows an invalid trace)
fn f99(a: int, n: int) -> unit errors Bad emits ones:
    if a > 1:
        fail Bad
    loop i down from a through a:
        if i == a:
            yield 49
        else:
            yield 49
        continue
    unit
case 109 (n:lower, loop i down from n through 100000000000000000000001, continue; offset 100000000000000000000000; ones): rejected EMIT-INCOMPLETE (before: rejected)  (precision limit: no run in the box shows an invalid trace)
fn f109(a: int, n: int) -> unit errors Bad emits ones:
    if n < 100000000000000000000003:
        fail Bad
    loop i down from n through 100000000000000000000001:
        if i == 100000000000000000000002:
            continue
        yield 49
        continue
    unit

cases: 150 (seed 11); verdicts: proven 32, rejected 118, not-proved 0, dependent 0
newly proven (the rule before this milestone did not): 13; regressed (proven before, not now): 0
runs: 25350, invalid traces: 6787; false certificates: 0; precision limits (not proved, every run in the box valid): 4
backends: 45 cross-checks on interp cranelift-generic cranelift, 0 differing from the Tcl compiler's traces
checking: 1.929 s for 150 claims (summaries computed 406, reused 134, rounds 300); the rule before: 1.349 s
```

## Seed 12

```
case 43 (a:upper, n:upper, loop i from -1 to n, later, after, helper; offset 0; ones): rejected EMIT-REJECTED (before: rejected)  (precision limit: no run in the box shows an invalid trace)
fn h43(a: int, n: int) -> unit errors Bad:
    if a > -1:
        fail Bad
    if n > -2:
        fail Bad
    loop i from -1 to n:
        if i != -2:
            yield 120
        yield 49
        continue
    yield 49
    unit

fn f43(a: int, n: int) -> unit errors Bad emits ones:
    h43(a, n)
    unit
case 46 (a:returns, n:upper, loop i down from n through a, helper-invalid, after, helper; offset 0; ones): rejected EMIT-REJECTED (before: rejected)  (precision limit: no run in the box shows an invalid trace)
fn h46(a: int, n: int) -> unit errors Bad:
    if a < 1:
        yield 49
        yield 49
        return unit
    if n > 0:
        fail Bad
    loop i down from n through a:
        sym_then_maybe_fail(49, i == -2):
            on Bad:
                yield 120
        continue
    yield 49
    unit

fn f46(a: int, n: int) -> unit errors Bad emits ones:
    h46(a, n)
    unit

cases: 150 (seed 12); verdicts: proven 43, rejected 107, not-proved 0, dependent 0
newly proven (the rule before this milestone did not): 17; regressed (proven before, not now): 0
runs: 25350, invalid traces: 6202; false certificates: 0; precision limits (not proved, every run in the box valid): 2
backends: 45 cross-checks on interp cranelift-generic cranelift, 0 differing from the Tcl compiler's traces
checking: 1.97 s for 150 claims (summaries computed 404, reused 184, rounds 300); the rule before: 1.211 s
```

## Seed 13

```

cases: 150 (seed 13); verdicts: proven 31, rejected 119, not-proved 0, dependent 0
newly proven (the rule before this milestone did not): 8; regressed (proven before, not now): 0
runs: 25350, invalid traces: 6472; false certificates: 0; precision limits (not proved, every run in the box valid): 0
backends: 45 cross-checks on interp cranelift-generic cranelift, 0 differing from the Tcl compiler's traces
checking: 1.854 s for 150 claims (summaries computed 388, reused 148, rounds 300); the rule before: 1.274 s
```
