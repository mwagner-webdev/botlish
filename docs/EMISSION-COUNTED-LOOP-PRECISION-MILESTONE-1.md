# Emission counted-loop precision, milestone 1

A counted loop no longer contributes an impossible zero-iteration exit to
an emission proof: where the facts the code establishes before a counted
loop prove that every start and end it may have put the start in its
domain, the emission checker (`hir::emission::EvalLoop`) drops that exit,
and only that exit. Everything the iterations that do run may do -- break,
continue, return, fail, complete without a yield, yield a symbol the
recognizer rejects -- is still followed. The selective CSV field emitter
is certified with one natural counted loop; its peeled first character is
gone.

1. [Result](#1-result)
2. [The selective CSV reproducer](#2-the-selective-csv-reproducer)
3. [Counted-loop semantics](#3-counted-loop-semantics)
4. [Root cause](#4-root-cause)
5. [The rule](#5-the-rule)
6. [Soundness](#6-soundness)
7. [Exact, ranged and unbounded bounds](#7-exact-ranged-and-unbounded-bounds)
8. [First-iteration analysis](#8-first-iteration-analysis)
9. [Break, continue, return and error paths](#9-break-continue-return-and-error-paths)
10. [The selective CSV emitter, before and after](#10-the-selective-csv-emitter-before-and-after)
11. [Newly certified and still unprovable](#11-newly-certified-and-still-unprovable)
12. [Differential and exhaustive testing](#12-differential-and-exhaustive-testing)
13. [Mutation evidence](#13-mutation-evidence)
14. [Certificate reuse and caller independence](#14-certificate-reuse-and-caller-independence)
15. [Compilation and native performance](#15-compilation-and-native-performance)
16. [Regression and CI results](#16-regression-and-ci-results)
17. [Files changed](#17-files-changed)
18. [Remaining precision limits](#18-remaining-precision-limits)
19. [Recommendation](#19-recommendation)
20. [Final questions](#20-final-questions)

## 1. Result

* **The rule.** `hir::range::DomainEntered START END DIRECTION ENDKIND` is 1
  when the loop's own test (core::forms::CountTest) holds for its first
  value against every end, at the worst pair of operands -- `START.max <
  END.min` for `from ... to`, `<=` for `through`, the mirror for `down` --
  with the bound it reads finite. `EvalLoop` calls it (through `Entered`,
  on the hulls of the bounds' interval sets) and, when it holds, leaves the
  states before the loop out of the loop's exits. Nothing else changes: the
  exits of the iterations, the fixpoint, peeling, unrolling, failure points.
* **CSV.** `selective_emit::field` and `field_strict` are one guarded loop
  `loop i from 0 to n:` inside the `n == 0 or needs_quotes(...)` decision's
  else branch, certified. The natural (unguarded) selective spelling is
  still rejected (a fact about the whole string), and so is the guarded
  loop without the `n == 0` exclusion (nothing bounds the count away from
  zero).
* **Soundness evidence.** No false certificate and no regression in 450
  generated counted-loop emitters run on every argument tuple of a box
  (76,050 runs, 135 cross-backend checks), the census unchanged, the
  fuzzer clean; the rule held to concrete evaluation for every pair of
  small ranges (both directions, both endpoint kinds); 15 targeted mutants
  of the rule and its boundaries, every one killed, and the whole mutation
  suite killed (section 13).
* **Cost.** One comparison per counted loop whose count is not exact, and
  for an entered loop with an inexact start one more walk of its body; on
  the CSV and JSON workloads no measurable difference (section 15). No
  executable code changes: the checker is a compile-time analysis, and the
  CSV programs' fused native code is identical with and without claims.
* **Found on the way** (recorded, not fixed here: section 18): a claim whose
  code calls a name declared later (UNBOUND) is reported `proven`, not
  `dependent`.

## 2. The selective CSV reproducer

CSV-EMISSION-VALIDATION-MILESTONE-1.md, section 5, left this variant
uncertified (`csv-selective-precision`, the census's `selective-unpeeled`):

```
fn field_strict(value: str) -> unit errors csv_common::UnsupportedCSVCharacter, QuotingDecision emits csv_strict::field:
    n = value.length()
    if n == 0 or needs_quotes_strict(value):
        strict_emit::quoted_field(value)
    else:
        loop i from 0 to n:
            c = value.char_at(i).scalar_value()
            csv_strict::text_char(c):
                on std::dfa::UnrecognizedInput:
                    fail QuotingDecision {at: i, value: c}
                on std::dfa::UnexpectedEnd:
                    fail QuotingDecision {at: i, value: c}
            yield c
            continue
    unit
```

`csv_strict::field` is a quoted field or a nonempty unquoted one, so the
claim needs the else branch to yield at least one character. Before this
milestone: `rejected EMIT-INCOMPLETE`. A trace of `EvalLoop` on that loop
(the claim's own walk, the composite state of the field's start):

```
start = {0 0}   end = {1 4611686018427387903}
entry = {{} {csv_strict field} start}
exits = {{{{csv_strict field} accept}} {csv_strict unquoted_field} text} {{} {csv_strict field} start}
```

The end's facts are right: `value.length()` is the native's registered
result range 0..2^62-1 and the `or`'s false outcome removed 0 (`n == 0`
false narrows n by `!=`, hir::intset::Narrow). The start is exactly 0. And
yet the entry state, the field's `start`, is among the loop's exits: a
normal completion of the function from it has yielded nothing, which the
recognizer rejects at the end of the input -- EMIT-INCOMPLETE.

## 3. Counted-loop semantics

From docs/README.md ("Collecting loops"), core/ir.tcl's `countloop` and
`lockloop` and core/evaluator.tcl's `op-countloop` (the reference
implementation; every backend agrees with it, `csv-backends-agree` and the
differential below among the checks):

* **Forms.** `loop i from A to B` (A <= i < B), `from A through B` (A <= i
  <= B), `down from A to B` (A >= i > B), `down from A through B` (A >= i
  >= B). HIR: a `countloop` with `start`, `end`, `direction` (`up` |
  `down`) and `endKind` (`exclusive` | `inclusive`); the lockstep form a
  `lockloop` whose count domains carry the same fields.
* **Evaluation.** START then END, each exactly once, left to right, in the
  enclosing scope, before any iteration; each must be an Int (checked at
  run time: a non-Int is the ordinary TYPE failure). A failure of either
  propagates before the loop starts: the body never runs.
* **Iteration.** I starts at START and steps by exactly one (+1 up, -1
  down) for as long as the loop's test `I < END` / `I <= END` / `I > END` /
  `I >= END` holds (core::forms::CountTest). The inclusive forms test with
  `<=`/`>=`; no END+1 or END-1 is ever formed. Ints are arbitrary
  precision: any magnitude, no wrapping.
* **Zero iterations** exactly when the first value fails the test: START >=
  END (`to`), START > END (`through`), and the mirror for `down`. Equal
  bounds: `to` runs zero times, `through` once. A domain never reverses
  direction.
* **Lockstep.** Every domain of a `lockloop` has the same count -- a
  compile-time obligation (hir/lockstep.tcl: LOCKSTEP-UNPROVEN,
  LOCKSTEP-UNEQUAL); a rejected one's loop raises its diagnostic before
  anything runs. So one counting domain's emptiness is the loop's.
* **Leaving.** A bare `break` leaves (with the List so far), `continue`
  goes to the next iteration, `return` and a failure leave the function or
  reach a handler; exhaustion completes the loop.

## 4. Root cause

Not the loop-entry facts (they were right, section 2), not the fixpoint's
join (it unites states, it never adds the entry), not branch-fact
propagation (the else branch's environment reached the loop): `EvalLoop`
itself. Its two paths for a counted loop that is not unrolled both made the
entry states an exit, unconditionally:

* with an exact start (peeled), `lappend out {*}$s` after the first
  iteration -- the zero-iteration exit, whatever the bounds;
* otherwise, the fixpoint's head was seeded with the entry states (`set
  head $s`) and every head state is an exit, so the entry was one.

The loop transfer read the bounds' facts for the counter (Peel,
`hir::range::InductionBinding`) and for an exact count (Unrolled, at most
8 iterations), but never asked whether zero iterations were possible. For
`from 0 to n` with n in 1..2^62-1 the count is not exact, so neither
unrolling nor anything else removed that exit.

## 5. The rule

```
proc hir::range::DomainEntered {startR endR direction endKind}
```

beside `InductionSeed` and `InductionBinding` in hir/range.tcl, the
counted-loop theorems the analyses share. For Ranges STARTR and ENDR:

| loop | entered when |
|---|---|
| `up to` | START.max < END.min |
| `up through` | START.max <= END.min |
| `down to` | START.min > END.max |
| `down through` | START.min >= END.max |

and 0 when the bound it reads is infinite (-inf or +inf), when either Range
is `never`, empty or contradictory, or has an infinity as its only bound (no
Int). The other side may be unbounded: `n >= 1` is END.min 1, END.max +inf.

In `hir::emission::EvalLoop` (after the unchanged exact-count unrolling):

```
lassign [Peel $induction] counter all first later
set entered [Entered $induction]
...
if {$counter ne "" && $entered && $first eq ""} {
    set first $all
    set later $all
}
if {$counter ne "" && $first ne ""} {
    ... the first iteration from the entry states ...
    lappend out {*}[dict get $breaks $e]
    if {!$entered} {
        lappend out {*}$s        ;# the zero-iteration exit
    }
    ... later iterations from the head after it ...
}
```

`Entered` passes the hulls of the bounds' interval sets (their extrema are
the sets' own) and answers 0 for a bound of no known Int set (`*`) or no
value (`{}`). A lockstep loop's first counting domain decides (section 3).

Three cases, then:

* **Exactly counted, at most 8 iterations** (both bounds exact points):
  unrolled as before; each iteration has its own counter, and a count of 0
  leaves only the entry.
* **Exact start** (an exactly counted loop of more iterations included):
  peeled as before -- the first iteration with the counter at the start,
  the later ones past it -- and the entry states are an exit only when the
  loop may not be entered.
* **Inexact start, entered** (new): the first iteration is walked on its
  own from the entry states with every counter value the loop may have
  (`all`), the later ones from the head after it, also with `all`; the
  entry is no exit. Not entered: as before (the fixpoint from the entry).

## 6. Soundness

Claim: for a counted loop reached on a normal path in composite states S
with environment E, the exits EvalLoop returns contain every composite
state in which a concrete execution consistent with S and E leaves the loop
normally, and every return and failure such an execution makes inside the
loop is recorded where it was before.

Let an execution evaluate START to a and END to z (each normally: a
failure of an operand is a failure point recorded by its own walk, before
the loop, and the body never runs). The checker's values are
over-approximations: `vs` contains a and `ve` contains z (hir/intset.tcl's
transfers, tests/interval-sets.test). Suppose DomainEntered(hull(vs),
hull(ve)) = 1, and take `up to`: a <= max(vs) = START.max < END.min =
min(ve) <= z, so a < z, which is exactly the loop's test of its first
value: the body runs at least once (`through` and `down` alike, with <=,
>, >=). So no execution leaves the loop after zero iterations, and the
exit dropped is one no execution takes.

Every other way out is kept. An execution that runs k >= 1 iterations
leaves:

* by a `break` in some iteration: its states are recorded (`breaks`) by
  the walk of the first iteration (k = 1) or of a later one, and every
  recorded break is an exit;
* by exhaustion after iteration k: the head after k iterations is in the
  fixpoint of the heads after one or more (the first iteration's
  completions and continues, then every later iteration's from them), and
  every head state is an exit;
* by `return` or a failure: recorded by the walk in `returns` and `fails`
  as before (a failure point of the first iteration is where a handler
  starts), never an exit of the loop.

The walks cover the iterations that run: the first one with the counter in
`first` (the exact start, or `all`), every later one with the counter in
`later` (past the start, or `all`); `all` is `InductionBinding`'s interval,
which holds every iteration's counter (`iset-induction-sound`). The rule
reads no relation between START and END, no caller's facts (the walk's
facts are the declared parameters' and the code's: section 14) and no
infinity as a value.

Where DomainEntered is 0 the transfer is the one before this milestone,
exactly: `Entered` answering 0 makes every line of the new code inert,
which is how the tools below compute the old verdicts in-process.

## 7. Exact, ranged and unbounded bounds

| bounds (facts at the loop) | entered | why |
|---|---|---|
| `from 0 to n`, n in 1..+inf | yes | 0 < 1 |
| `from 0 to n`, n in 0..+inf | no | n = 0 runs zero times |
| `from 0 through n`, n in 0..+inf | yes | 0 <= 0 |
| `down from n to 0`, n in 1..+inf | yes | 1 > 0 |
| `down from n through 0`, n in 0..+inf | yes | 0 >= 0 |
| `from a to n`, a in 0..3, n in 4..+inf | yes | every pair: 3 < 4 |
| `from a to n`, a in 0..3, n in 3..+inf | no | a = n = 3 |
| `from n to 10^23`, n in 0..+inf | no | the start's maximum is +inf |
| `from 10^23 - 1 to n`, n >= 10^23 | yes | arbitrary precision |
| `from 2^63 to n`, n >= 2^63 / `through` | no / yes | equal at 2^63 |
| `from 0 to big`, `big = 10^23` (exact) | yes | an exact count past the unrolling limit |
| `from 0 to m`, m = f(n) through a function value | no | every Int |
| `from 0 to n`, n untyped | no | no known Int set |

(`ec-loop-entered-guards`, `-endpoints`, `-huge`, `-unknown`;
`iset-domain-entered-edges` for the Ranges themselves, a sentinel 10^21
mutant among the mutants.) Facts reach the loop by the ordinary path
analysis: a failing guard, a returning branch, `not`, `or`, `and`, a
declared integer domain, an earlier binding (`m = n + 1` after `n >= 0`),
an exact module or local constant. A guard whose failure is handled
(`check(n): on Bad: unit`) establishes nothing on the handler's path, and
the loop after it may run zero times (`handled_guard`).

## 8. First-iteration analysis

Peeling (an exact start) and unrolling (an exact count of at most 8) are
unchanged; the new walk is the inexact-start entered case's first
iteration, with every counter value. So:

* a loop of exactly one iteration is unrolled (`exactly_one`: `n != 1`
  failing first, one digit); it acquires no second iteration;
* a loop of at least one but possibly many keeps its later iterations (`n
  in 1..3` claimed as one digit: rejected EMIT-AFTER-TOKEN; the
  `entered-only-first` mutant, which walks only the first, is killed by
  it);
* a first iteration that differs from the later ones keeps its own facts
  (`first_differs`: 'a' when i = 0, 'b' after, claimed as `a b*`:
  certified once n >= 1);
* the fixpoint of the later iterations runs to convergence after an
  entered first iteration (`ec-loop-entered-fixpoint`: a '.' every other
  iteration after a '0' is found in the second round; the `loop-one-round`
  mutant certifies it, and is killed).

## 9. Break, continue, return and error paths

Proving that a loop runs is not proving that it emits. Every one of these
entered loops (n >= 1) is still rejected (`ec-loop-entered-not-emitting`,
`ec-loop-entered-failures`), each because of an exit or a path of an
iteration that runs:

| body | why |
|---|---|
| `if i == 0: break` before the yield | the first iteration's break exits with nothing yielded |
| `if b: break` (a Bool parameter) | a break in any iteration |
| `if i == 0: continue` before the yield | n = 1: one iteration, no symbol |
| `if i == 0: return unit` before the yield | a normal completion of the function with nothing |
| `if b: yield 49` | an iteration that completes without a symbol |
| `if i > 0: yield 120` | a later iteration's invalid symbol (EMIT-REJECTED) |
| `yield 98` claimed as `a b*` | the first symbol is no 'a' |
| an inner `loop j from 0 to m`, m unrestricted | the inner loop may run zero times |

and the failure paths: a bound's own failure (`loop i from 0 to bound(n)`,
bound failing for n < 1) starts its handler from the states before the
loop -- a handler that emits nothing leaves the caller's claim incomplete
(`bound_fails_empty` rejected, `bound_fails_emits` certified); a helper
that yields '1' and then fails in the first iteration starts its handler in
the state after that '1' (`after_yield_invalid` rejected for its 'x',
`after_yield_valid` certified); a `fail` in the first iteration of a loop
entered by a declared domain is a failure point before any symbol, so a
caller that handles it by emitting nothing is rejected
(`caller_of_fail_first_domain`). Each way out of an iteration -- break,
continue, return, failure, a later iteration -- has a mutant that drops it
for an entered loop, killed by these tests (section 13).

## 10. The selective CSV emitter, before and after

Before (`selective_emit::field`, CSV-EMISSION-VALIDATION-MILESTONE-1.md):

```
    else:
        c0 = value.char_at(0).scalar_value()
        csv_utf8::text_char(c0):
            on std::dfa::UnrecognizedInput:
                fail QuotingDecision {at: 0, value: c0}
            on std::dfa::UnexpectedEnd:
                fail QuotingDecision {at: 0, value: c0}
        yield c0
        loop i from 1 to n:
            c = value.char_at(i).scalar_value()
            csv_utf8::text_char(c):
                ...
            yield c
            continue
```

After:

```
    else:
        loop i from 0 to n:
            c = value.char_at(i).scalar_value()
            csv_utf8::text_char(c):
                on std::dfa::UnrecognizedInput:
                    fail QuotingDecision {at: i, value: c}
                on std::dfa::UnexpectedEnd:
                    fail QuotingDecision {at: i, value: c}
            yield c
            continue
```

The decision (`n == 0 or needs_quotes(value)`) and the per-character guard
stay: the guard restates per character what the decision knew of the whole
string, which is a relation the checker does not carry (section 18). The
three variants of the comparison, now (`csv-selective-precision`, which
builds the other spellings from the shipped one):

| variant | before | now |
|---|---|---|
| natural: decide, then yield every character unchecked | rejected (EMIT-REJECTED, -BEYOND-TOKEN, -INCOMPLETE) | still rejected, the same kinds |
| guarded, one loop (shipped) | rejected (EMIT-INCOMPLETE) | **certified** |
| guarded, first character peeled (the former shipped one) | certified | certified |
| guarded, one loop, without `n == 0` in the decision | rejected (EMIT-INCOMPLETE) | rejected (EMIT-INCOMPLETE): nothing bounds n away from 0 |

The 52 claims of the CSV modules are all certified, as before. The mutation
census (audit/csv-emission/census/mutants.txt) replaces `selective-unpeeled`
by `selective-count-unknown` (the decision without `n == 0`: correct,
EMIT-INCOMPLETE, unprovable) and `selective-empty-unquoted` (the empty
value judged unquotable as well: the field is empty, EMIT-INCOMPLETE, and
the ordinary examples' runs show the invalid trace -- static), and
`selective-guard-weakened` now weakens the one loop's guard; every
selective mutant is as its class states. The program's output is the same
(`csv-selective-runs`, `csv-selective-native-erasure`, the probes on every
backend).

## 11. Newly certified and still unprovable

Newly certified, among the tests (`ec-loop-entered-*`): a loop after a
failing guard (`n <= 0`, `not (n > 0)`, `n < 1 or n > 10`), inside an `and`
branch, after a returning branch that yields a token itself, over a
binding (`m = n + 1` after `n >= 0`), over a declared domain (`Int in
1..1000`), to an exact `10^23` (past unrolling), `through` an end >= 0,
`down` from n >= 1, from a negative start, from an inexact start below
every end, at 2^63 and past 10^23, in a lockstep loop, nested loops both
entered, a helper's loop entered by its caller's facts (and only that
caller's), a claimed helper with a positive domain composed through its
certificate. In the differential's generated emitters, 38 claims of 450.

Still rejected, correctly: every loop that may run zero times
(unrestricted n; `n >= 0` with `to`; a handled guard; an unknown bound),
and every entered loop with an empty, invalid or beyond-token path (section
9). The emission census (audit/emission-claims/census/cases.txt) decides
every case as before, `zero-iterations` (a digits loop over every n)
rejected and disproven by a run for n = 0; the 31 mistakes are decided as
the exploratory checker decided them.

No claim of the JSON workload (22) or of the CSV workload (52) changes
verdict: all were certified before (the peeled CSV fields being the only
counted-loop workaround in them).

## 12. Differential and exhaustive testing

**The rule against concrete evaluation** (tests/interval-sets.test):
`iset-domain-entered-sound` enumerates every start and end pair of 600
random pairs of small Ranges (both directions, both endpoint kinds) and
requires DomainEntered to be 1 exactly when every pair runs the body
(core::forms::CountSize > 0, and the evaluator's own CountTest of the first
value) -- sound and, for finite Ranges, exact; `iset-domain-entered-edges`
pins 29 edges (equal and adjacent bounds, each unbounded side, 2^63, 10^23
and 10^27, no value, empty and contradictory Ranges, infinities).

**Generated emitters against execution**
(`audit/emission-claims/tools/loops.tcl`, results in
`audit/emission-claims/results/loops.md`). Each case is a claimed
`f(a: int, n: int) errors Bad emits R` (R `ones` = '1'+ or `ab` = 'a' 'b'*,
both nonempty) built from random guards on the parameters the loop reads
(none, `<`, `>`, both, a hole, a point, a returning branch, a handled
guard), a counted loop (start and end each a parameter or a constant, up
or down, `to` or `through`), a body (the token's symbols, a break,
continue, return or fail at one iteration, a later invalid symbol, a
first-iteration symbol of its own, a helper that yields then may fail
under three handlers, a nested loop), sometimes a symbol after the loop,
sometimes all of it in a helper, every constant offset by 0, 2^63 or
10^23. The compiler decides each claim, and so does the rule before this
milestone (in the same process); then every (a, n) of the 13 x 13 box
around the offset runs on the Tcl compiler (every tenth case also on the
interpreter and both native backends) and the reference interpreter judges
each trace.

| seed | cases | proven | newly proven | regressed | runs | invalid traces | false certificates | precision limits | backend checks (differing) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 11 | 150 | 32 | 13 | 0 | 25,350 | 6,787 | 0 | 4 | 45 (0) |
| 12 | 150 | 43 | 17 | 0 | 25,350 | 6,202 | 0 | 2 | 45 (0) |
| 13 | 150 | 31 | 8 | 0 | 25,350 | 6,472 | 0 | 0 | 45 (0) |
| all | 450 | 106 | 38 | 0 | 76,050 | 19,461 | 0 | 6 | 135 (0) |

A precision limit is a claim not proved whose every run in the box is
valid; the six are of four kinds (section 18): a minimum count above one
(a loop that always runs at least twice whose first iteration may skip its
symbol), a relation between the bounds (`down from a through a`), a Bool
argument's value (`i == K` for a K the counter never reaches), and a loop
the bounds prove empty whose body is still checked.

**The existing evidence**, rerun: the emission census and mistakes
(unchanged), the emission fuzzer (section 16), and the CSV differential
(every corpus, exhaustive and fuzzed value through every source kind on
five backends, the reference interpreter and the independent oracle:
section 16).

## 13. Mutation evidence

Fifteen new mutants in audit/emission-claims/tools/mutants.txt, each a way
the rule or its boundaries could certify falsely (or lose precision), each
killed by a targeted test; the related existing ones re-checked against the
new tests:

| mutant | the bug | killed by |
|---|---|---|
| `entered-always` | every counted loop entered | `ec-loop-entered-guards`, `-endpoints`, `-huge`, `-contexts`, `-lockstep`, `-not-emitting`, ... |
| `entered-unknown-bound` | a bound of no known Int set read as entered | `ec-loop-entered-unknown` |
| `entered-sentinel` | an unbounded side read as 10^21 | `ec-loop-entered-huge` (n >= 0 to 10^23) |
| `entered-exclusive-as-inclusive` | `to` tested as `through` | `-endpoints`, `-guards`, `-huge`, `-lockstep`, `-trust`, `iset-domain-entered-*` |
| `entered-inclusive-as-exclusive` | `through` tested as `to` | `-endpoints`, `-huge`, `iset-domain-entered-*` |
| `entered-down-equal` | `down ... to` entered at equal bounds | `-endpoints`, `iset-domain-entered-*` |
| `entered-direction-swapped` | a descending loop judged by the ascending extrema | `-endpoints`, `iset-domain-entered-*` |
| `entered-some-pair` | some start below some end, not every pair | `-endpoints` (a in 0..3, n >= 3), `-guards`, `-contexts`, ... |
| `entered-no-value` | a Range of no Int read as an operand | `iset-domain-entered-edges` |
| `entered-drops-body-exits` | an entered loop's breaks dropped with its zero exit | `-not-emitting` |
| `entered-first-break-ignored` | the first iteration's break forgotten | `-not-emitting` |
| `entered-only-first` | an entered loop's later iterations never walked | `-count`, `-not-emitting` |
| `entered-first-failures-dropped` | the first iteration's failure points forgotten | `-failures` (`caller_of_fail_first_domain`) |
| `entered-first-returns-dropped` | the first iteration's return forgotten | `-not-emitting` |
| `entered-first-continues-dropped` | the first iteration's continue not carried | `-count`, `-fixpoint`, `-not-emitting` |

and of the existing ones `loop-one-round` (now also killed by
`ec-loop-entered-fixpoint`, after it was rewritten so that only a second
round finds its violation), `peel-later-is-first`, `unroll-short`,
`summary-context-free` (a helper's summary shared between argument
contexts: `ec-loop-entered-contexts`, whose two callers differ only in
whether the helper's loop is entered), `join-first-state`,
`range-induction-exclusive`. The whole suite: see section 16.

## 14. Certificate reuse and caller independence

* **Caller-independent.** The rule reads the walk's facts, which are the
  claimed function's declared parameters and its own code (Walk enters a
  function with `Declared`); a helper's loop is entered by the argument
  facts of each call, its summary keyed by them
  (`ec-loop-entered-contexts`: `guarded` certified, `unguarded` rejected,
  through the same helper; the `summary-context-free` mutant, which shares
  them, killed). A claimed function no program calls is decided the same
  (every test above is uncalled). Adding a caller cannot make a claim
  succeed: no caller's facts reach a claim's walk.
* **Interchange and the cache.** A certificate resting on an entered loop
  reads back from interchange text and is verified again by this process's
  checker (`ec-loop-entered-trust`; the forged-certificate tests are
  unchanged). The front-end cache's key holds the front end's fingerprint
  (core, hir, surface, stdlib), so an entry written before this change --
  hir/emission.tcl and hir/range.tcl are in it -- is never read after it.
* **The memo.** The in-process memo reuses a certificate while every
  function its proof read is unchanged by canonical fingerprint; the
  guard's constant is in the fingerprint, so `if n < 1` changed to `if n <
  0` is proved again, and rejected (`ec-loop-entered-trust`). The rule is
  code of the checker, which a process does not change, so it needs no
  dependency of its own.
* **The compiler service** shows the corrected verdict with no change of
  its own (`csv-service-hover` and the CSV navigation tests pass; hover
  reads the claim's record).

## 15. Compilation and native performance

`audit/emission-claims/tools/loops-bench.tcl` (each scenario a fresh
process, the memo off, the median of 5; `before` is the rule before this
milestone, computed in the same compiler with `Entered` answering 0;
`audit/emission-claims/results/loops-bench.md`):

| workload | rule | claims proven | check ms (median) | of it: certificates ms | summaries computed / reused | rounds | loop evaluations | loop walks |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| csv | before | 49 / 52 | 694.935 | 51.39 | 212 / 152 | 104 | 56 | 104 |
| csv | current | 52 / 52 | 664.709 | 48.09 | 207 / 121 | 104 | 44 | 80 |
| json | before | 22 / 22 | 243.657 | 34.229 | 140 / 60 | 44 | 32 | 48 |
| json | current | 22 / 22 | 246.94 | 32.967 | 140 / 60 | 44 | 32 | 48 |
| selective-peeled | before | 40 / 40 | 514.307 | 41.795 | 164 / 98 | 80 | 44 | 80 |
| selective-peeled | current | 40 / 40 | 499.438 | 39.026 | 164 / 98 | 80 | 44 | 80 |
| selective-loop | before | 38 / 40 | 537.471 | 39.326 | 170 / 128 | 80 | 56 | 104 |
| selective-loop | current | 40 / 40 | 508.85 | 38.107 | 164 / 98 | 80 | 44 | 80 |
| loops | before | 0 / 12 | 15.581 | 0.0 | 26 / 0 | 24 | 24 | 48 |
| loops | current | 8 / 12 | 27.252 | 10.636 | 26 / 0 | 24 | 24 | 48 |

* **Checking time** is the same within the measurement's noise on the CSV
  (52 claims) and JSON (22) workloads: 665 against 695 ms and 247 against
  244 ms, against the CSV report's 0.59-0.76 s and the JSON report's 0.30 s
  (the same machine type). The rule is one comparison of two bounds per
  counted loop that is not unrolled.
* **Summaries and walks.** Under the rule before, the shipped CSV source
  proves 49 of its 52 claims (the two selective fields, and the source that
  composes with the UTF-8 one); now all 52, with *fewer* summaries computed
  (207 against 212), fewer reused (121 against 152) and fewer loop walks (80
  against 104), the CSV report's 207 / 121 / 104 rounds exactly. A
  rejected claim's callers are walked through its body; a certified one's
  compose with its certificate. The peeled and the one-loop selective
  fields cost the same now (164 / 98 summaries, 80 walks).
* **The counted-loop tests** cost the same to analyze (26 summaries, 24
  rounds, 48 walks either way); the time added (16 to 27 ms) is the eight
  certificates the claims now have -- fingerprints and statements, 10.6 ms
  -- not the rule.
* **Fixpoint rounds** are unchanged everywhere.
* **Native execution.** No executable code changes: the checker is a
  compile-time analysis no backend reads (`ec-claim-erased`,
  `ec-native-erasure`, `csv-native-erasure` and the new
  `csv-selective-native-erasure`: the selective document's fused NIR is the
  same with and without every claim, with no coroutine object, and the same
  output on all four backends). The selective field's own code changed
  (one loop, the first character no longer written apart); the CSV
  differential and the probes show the same bytes. Its native cost is the
  source's, not the claim's.

## 16. Regression and CI results

Locally (the 4-core container; LANG=C.utf8; the native backend built from
this tree):

| check | result |
|---|---|
| tests/emission-claims.test | 95 / 95 (11 new) |
| tests/interval-sets.test | 37 / 37 (2 new) |
| tests/csv-emission.test | 36 / 36 (2 new; `csv-selective-precision` rewritten) |
| tests/dfa.test, tests/dfa-workloads.test | 85 / 85, 21 / 21 (the CSV modules warning-clean under `-warnings error`) |
| tests/hir-range.test | 74 / 74 |
| tests/static-compile.test, tests/static-compile-expected-diagnostics.test, tests/static-economics.test | 83 / 83, 21 / 21, 93 / 93 |
| tests/diagnostic-recovery.test | 57 / 57 |
| tests/hir-interchange.test, tests/hir-cache.test | 11 / 11, 19 / 19 |
| tests/compiler-service.test | 55 / 55 |
| tests/coroutine-fusion.test | 17 / 17 |
| tests/compilerpedia.test, `tools/compilerpedia.tcl check` | 42 / 42; 1,218 topics, 744 examples, 0 problems |
| audit/emission-claims/tools/mutate.tcl | 72 mutants, 72 killed |
| audit/emission-claims/tools/census.tcl | every modular case as expected, no false proof; 31 of 31 mistakes as the exploratory checker decided |
| audit/emission-claims/tools/loops.tcl, seeds 11-13 | 450 cases, 0 false certificates, 0 regressions (section 12) |
| audit/csv-emission/tools/census.tcl, the selective mutants | every one as its class states |
| audit/emission-claims/tools/fuzz.tcl | PENDING |
| audit/csv-emission/tools/differential.tcl | PENDING |
| audit/csv-emission/tools/census.tcl, whole | PENDING |
| audit/refactor/tools/gate.tcl | PENDING |

CI: PENDING.

`main` when this branch was made (2026-11-05): its newest runs were
queued; of the last completed ones, `tests` failed on
`package-authoring.test`'s `pa-add-refusals` (the runner's GNU ld has no
AArch64 emulation for clang's cross link: an environment failure, in the
interp and system-linker jobs, and the jobs that ran the same file) and
`tests (macos arm64)` on its system-linker job; every other workflow
passed. Neither touches the emission checker.

## 17. Files changed

* `hir/range.tcl` -- `hir::range::DomainEntered`, beside `InductionSeed`
  and `InductionBinding`.
* `hir/emission.tcl` -- `EvalLoop` (the zero-iteration exit only when not
  entered; the inexact-start entered first iteration), `Entered`; the
  header's account of loops.
* `examples/dfa/csv/selective_emit.bot` -- the selective fields as one
  guarded loop; its header.
* `tests/emission-claims.test` -- `ec-loop-entered-*` (11 tests);
  `tests/interval-sets.test` -- `iset-domain-entered-sound`, `-edges`;
  `tests/csv-emission.test` -- `csv-selective-precision` (four variants),
  `csv-selective-native-erasure`.
* `audit/emission-claims/tools/mutants.txt` -- 15 mutants;
  `audit/emission-claims/tools/loops.tcl` (the differential),
  `loops-bench.tcl` (the costs), `results/loops.md`, `results/mutants.md`,
  README.md.
* `audit/csv-emission/census/mutants.txt` -- the selective mutants;
  `audit/csv-emission/results/census.md`.
* `compilerpedia/topics/emission.topic` -- EMIT-INCOMPLETE: a counted loop
  that may run zero times (rejected) and the guarded one (certified).
* `docs/` -- this report, INDEX.md, notes in
  CSV-EMISSION-VALIDATION-MILESTONE-1.md (sections 5, 19, 20) and
  EMISSION-CLAIMS-MILESTONE-1.md (section 8); AGENTS.md ("Emission
  claims").

## 18. Remaining precision limits

What the rule does not prove, with the differential's examples:

* **A minimum count above one.** The rule proves at least one iteration;
  every head state stays an exit. `loop i from -2 through n` with `n >=
  -1` always runs twice or more, but its first iteration's `continue`
  before the symbol leaves the head in the token's start state, which the
  checker cannot exclude as the last one (cases 58 and 109 of seed 11).
* **Relations between the bounds.** `down from a through a` runs exactly
  once whatever a is; `from n - 1 to n` once; `from 0 to xs.length()` as
  often as the List is long. Each operand's own facts say nothing of the
  other (case 99 of seed 11). That is relational analysis, out of scope.
* **Values that are no Int.** A Bool argument (`i == K` passed to a
  helper), a String's contents: `needs_quotes(value)` returning false is a
  fact about every character of the string, which is why the selective
  field still guards each character. Iteration-count precision is not
  content precision.
* **List and plain loops.** A `loop x in xs` over a List the checker knows
  to be nonempty, and a `loop:` exited by `break`, are untouched: lengths
  are not interval facts of the emission walk.
* **A loop proved empty.** The converse rule -- bounds whose every pair
  fails the test, such as `from -1 to n` with `n <= -2` -- is not applied:
  the body of a loop that never runs is still walked, and what it would
  yield is still checked (cases 43 and 46 of seed 12, rejected for a symbol
  no run writes). Sound, and imprecise; only an exactly counted loop of
  zero iterations (two points) is known empty.
* **At most one iteration.** A loop the bounds limit to at most one
  iteration but do not prove entered (an exact start, an end that may equal
  it) still walks its later iterations, with no counter value: an
  over-approximation, as before.
* **No value at all.** A bound whose fact is empty (unreachable code)
  proves nothing; the zero-iteration exit stays, as before.
* **An unbound callee** (found on the way, not fixed here): a claim whose
  function calls a name declared later (UNBOUND, a forward reference) is
  reported `proven` with no EMIT diagnostic, not `dependent` --
  `EvalCall` does not visit a call's `ref` callee, so the poison is not
  seen, and the call's `never` type ends the walk. The compilation is
  rejected for the UNBOUND, so no program that runs has such a
  certificate, but the claim's record and the service's hover say
  "certified". It predates this milestone (the same verdict with the
  change stashed). The fix is to treat a poisoned or diagnosed callee like
  any other tainted expression in `EvalCall`.

## 19. Recommendation

Keep the rule: it is local, non-relational, a few lines on top of the
facts the checker already had, and it removed the one syntactic workaround
the CSV workload needed. Next, in order of value:

1. **The unbound-callee verdict** (section 18): a one-line taint check in
   `EvalCall`, with a test that a claim calling a forward reference is
   `dependent`.
2. **A minimum count**, only if a workload needs it: `DomainEntered` is the
   k = 1 case of "the domain holds at least k values" (START.max + k - 1 <
   END.min for `up to`); a k >= 2 rule would let the head after an early
   `continue` stop being an exit. No workload so far does.
3. Relational facts stay out of scope; the selective field's per-character
   guard is their price, and it is a check that cannot fail, not an unsafe
   program.

## 20. Final questions

**1. Was the CSV workaround genuinely unnecessary?** Yes. The facts that
made the unquoted branch nonempty were already at the loop (start 0, end
1..2^62-1); only the loop transfer ignored them. The guarded selective
emitter is one natural counted loop and is certified, with no peeled
iteration. The per-character guard is still needed: that one is a
relational fact, not a count.

**2. What exactly can the compiler prove?** That a counted loop runs at
least once when, for the facts at its entry, the loop's own test holds for
its start against its end at the worst pair: `START.max < END.min` (`to`),
`<=` (`through`), mirrored for `down`, each bound read finite. The facts
are the emission walk's: declared domains, guards that fail or return,
`and`/`or`/`not`/`!=`, bindings, exact constants, guards of recognizers. It
stays conservative for an unbounded side, an unknown or untyped bound, a
handled guard, a relation between the bounds, a count above one, and
anything not an Int.

**3. Is the proof sound through control flow?** Yes: the rule removes
only the exit taken after zero iterations. A definitely entered loop that
breaks, continues, returns, fails or completes an iteration without a
symbol is still rejected (section 9, each path with a mutant that drops it
and is killed), and failures before the first iteration -- a bound's -- are
failure points of the operands, before the loop.

**4. Does the improvement generalize?** To every emitter whose counted
loop's count is bounded away from zero by facts before it: a guard, a
domain, a branch. In the repository's workloads that was exactly the
selective field (the JSON and CSV workloads were already certified,
through peeling); in the generated emitters, 38 of 450 claims became
provable without changing their source, and none was lost.

**5. What is the cost?** One comparison per counted loop that is not
unrolled, and one more walk of the body for an entered loop with an inexact
start; no measurable checking time on the workloads, fewer summaries on the
CSV one. No native cost: no executable code changes.

**6. What remains out of scope?** Iteration-count precision is not content
precision: a fact about every character of a String (the natural selective
spelling), relations between bounds or between values, minimum counts
above one, List lengths, and coroutine typing (a source's symbols and its
final value share one outward type: CSV-EMISSION-VALIDATION-MILESTONE-1.md,
section 20) are untouched.
