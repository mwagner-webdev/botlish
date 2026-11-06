# Emission callee dependency correctness, milestone 1

A claim whose function calls a name that did not resolve -- unknown, or
declared later (a forward reference) -- is no longer certified. Botlish
types an unresolved reference `never` with no target, and the emission
walk read that `never` as a call that cannot return: the walk ended before
anything after the call, and the claim was `proven` with a certificate,
while the compilation was rejected for UNBOUND. The claim is now
`dependent` on the UNBOUND. UNBOUND stays the only diagnostic: no
certificate is made, no EMIT diagnostic is added, and nothing is memoized.
The same correction closes the transitive version of the defect. A helper
whose inferred result is `never` *because* it calls an unresolved name was
believed from its type and never read, so neither the helper's taint nor
its fingerprint reached the proof.

1. [Result](#1-result)
2. [Minimal reproducer](#2-minimal-reproducer)
3. [The original incorrect verdict](#3-the-original-incorrect-verdict)
4. [The HIR of the invalid call](#4-the-hir-of-the-invalid-call)
5. [Root cause in EvalCall](#5-root-cause-in-evalcall)
6. [The correction](#6-the-correction)
7. [Direct and transitive dependencies](#7-direct-and-transitive-dependencies)
8. [`never` and genuine noncompletion](#8-never-and-genuine-noncompletion)
9. [Error handling and coroutine boundaries](#9-error-handling-and-coroutine-boundaries)
10. [Diagnostic ownership and recovery](#10-diagnostic-ownership-and-recovery)
11. [Compiler-service behavior](#11-compiler-service-behavior)
12. [Certificates, the memo, interchange and the cache](#12-certificates-the-memo-interchange-and-the-cache)
13. [Positive and negative tests](#13-positive-and-negative-tests)
14. [Mutation evidence](#14-mutation-evidence)
15. [Regression results](#15-regression-results)
16. [Performance and files changed](#16-performance-and-files-changed)
17. [Remaining limitations and related omissions](#17-remaining-limitations-and-related-omissions)

## 1. Result

* **The rule.** A claim is `proven` only if its walk read every call it
  relies on. Two things count as read even though the walk does not
  evaluate them as values:
  * a call's callee reference;
  * the code of a function whose `never` result ends the walk at a call.
  If either holds a diagnostic of the program's own, poison or a syntax
  hole, the claim is `dependent`, the verdict the checker already gave for
  such code in the claim's own body (`ec-recovery-dependent`).
* **The change** is in `hir/emission.tcl`, in three parts:
  * The taint check moves out of `Eval` into `hir::emission::Taint`. `Eval`
    calls it for every expression it evaluates, and `EvalCall` calls it for
    a `ref` callee, which it does not evaluate.
  * `EvalCall`'s `never` branch *reads* a non-yielding function callee
    (`Read $t $vals`) before it records the failure point and ends the
    walk. `Read` takes the callee's ordinary summary over a second kind of
    edge, `reads`, beside `children`.
  * `CheckClaim` decides `dependent`, and builds the certificate's
    dependencies, from everything the proof read (children and reads). It
    judges violations only over the children, as before.

  No new diagnostic, HIR node, type, effect, verdict or runtime operation.
  Resolution, `never`, the `dependent` rule and the certificate format are
  unchanged.
* **Verdicts.** Every reproducer listed in section 7 is `dependent`; each
  was `proven`, or `rejected` with an EMIT diagnostic the walk made up. A
  claim whose walk reads no unresolved call is decided as before:
  * an independent claim in the same program;
  * a call that genuinely never returns;
  * an unresolved call in a branch the walk decides infeasible.
* **Certificates.** A certificate that relies on a helper never returning
  now lists that helper's fingerprint. Before this change, in-process
  certificate reuse (the memo) kept a certificate after the helper's body
  changed into a call of an unresolved name (section 12).
* **Accepted programs.** Valid programs keep their verdicts, including one
  whose `never` helper calls a trait operation. A first version of the
  change took that helper's summary as an ordinary child, which made the
  claim EMIT-UNSUPPORTED and rejected an accepted program (section 6). The
  read edge exists for that case.
* **Evidence.**
  * 15 new tests: 12 fail on the tree before the change, and the other 3
    pin behavior that must not change.
  * 14 new mutants; the catalog is 86 of 86 killed.
  * The JSON and CSV emitters stay certified with the same summary counts.
  * The census, the fuzzer and the loops differential are identical to
    the baseline.
  * `tests/local.tcl` passes: every Tcl test file on two backends and
    every golden suite on four (section 15).

## 2. Minimal reproducer

```botlish
import std::dfa

class digit = '0'..'9'

dfa digit_token over ascii:
    start:
        digit -> accept

fn emitter() -> unit emits digit_token:
    later()
    yield 49
    unit

fn later() -> unit:
    unit

0
```

`later` is declared after `emitter`, and Botlish has no forward references,
so `later()` is UNBOUND: `unbound name "later": "later" is declared later;
forward references are not allowed`. The program is rejected. The same
holds with `missing()`, a name never declared.

## 3. The original incorrect verdict

Compiled leniently (`-strict 0`, which the compiler service and the tests
use), the claim's record before the change:

```
diagnostic: UNBOUND expr e40
record: verdict proven, certificate 1
  exits {}   visits {start}   fails {start}   depends functions {emitter}
service hover: emits digit_token: certified to emit digit_token: every
  normal completion has yielded exactly one token, every prefix it yields
  is viable; its token completes on its own last symbol
```

The certificate is vacuous: it has no exit state, so "every normal
completion" holds of no completion. The one symbol the function would
yield, after `later()`, was never looked at. Running the lenient program
fails at `later()` with an unbound-name error, so no run violates the
certificate. But the certificate says something about code the checker
never read, and a hover over the function said "certified" in a program
whose only diagnostic is that `emitter` cannot be compiled.

## 4. The HIR of the invalid call

```
e39: call   type never  reachable 1  callee e40  target {}  args {}
  e40: ref  name later  binding {}  type never         (UNBOUND's expr)
e41: call   type unit   reachable 0  coroutine#yield(49)
e44: ref    unit        reachable 0
```

Neither the call nor its callee is in the `poisoned` table. The
reference's type is `never` because `hir::types::Expr` types an unbound
`ref` that way (`if binding eq "" -> never`). DIAGNOSTIC-RECOVERY.md,
section 2, records that this placeholder is also a divergence: "an
unresolved reference is typed `never` (and the completion and range
analyses treat it as never completing)". Type inference therefore made
everything after the call unreachable: the yield is `reachable 0`. The
UNBOUND diagnostic's `expr` is the reference `e40`, not the call.

## 5. Root cause in EvalCall

The checker already had the right rule. A summary is *tainted* when the
walk reads an expression that is poisoned, `syntaxDependent`, or the
`expr` of one of the program's diagnostics (`Reset` collects those). A
claim whose reachable summaries include a tainted one is `dependent`
(`CheckClaim`). The defect was what the walk never read:

1. **The callee reference.** `EvalCall` evaluates a callee only when it is
   not a `ref` (`if {[Kind $callee] ne "ref"} { Eval ... }`), since a named
   callee's value is the function and the walk has no use for it. The taint
   check lived in `Eval`, so it never saw `e40`. The call's type is `never`
   and its target is empty, so `EvalCall` took the `never` branch
   (`Failing $s; return {}`). The walk ended with no exit, no violation and
   no taint, and `CheckClaim` certified it.
2. **The code behind a `never`.** For a call of a function whose type is
   `never` and that cannot yield, the same branch believed the type and did
   not take the callee's summary. A helper `fn helper(): missing()` has the
   inferred result `never` only because of the unresolved call; its body
   was never walked, so its taint was never seen. Its fingerprint was not
   among the certificate's dependencies either (section 12).

Hole 1 also showed through helpers the walk *did* read. In
`fn helper() -> unit: missing(); yield 49; unit`, the call is typed `unit`
(declared), so the walk takes the helper's summary. That summary stopped
silently at `missing()`. The emitter then completed with the token
unstarted, and the claim was `rejected` with an EMIT-INCOMPLETE that no
code produces. `hir::recovery::reported` withheld that diagnostic, because
the emitter's unit refers to the helper's tainted unit, but the record and
the hover said "rejected".

## 6. The correction

```tcl
proc hir::emission::Taint {e} {
    variable hir
    variable diagnosed
    variable tainted
    if {[dict exists $hir poisoned $e] || [dict exists $hir syntaxDependent $e] || [dict exists $diagnosed $e]} {
        set tainted 1
    }
}
```

`Eval` calls `Taint $e` where it used to test inline; nothing else in
`Eval` changes. In `EvalCall`:

```tcl
    if {[Kind $callee] ne "ref"} {
        lassign [Eval $callee $s] s -
    } else {
        Taint $callee
    }
    ...
    if {[TypeOf $e] eq "never"} {
        if {$tk eq "block" && [hir::coroutines::MayYield $hir $t]} {
            Apply $e $t $s $vals
        } else {
            if {$tk eq "block"} {
                Read $t $vals
            }
            Failing $s
        }
        return [list {} {}]
    }
```

`Read` is `Child` with another edge: it computes the same summary, keyed
`{T free VALS}`, and appends the key to the walk's `reads` instead of its
`children`. A summary record carries both lists. `Reachable` takes the
edges to follow, and `CheckClaim` computes two sets:

* the **keyset**, over `children`: the summaries whose violations the
  claim is judged by (`Diagnostics`), as before;
* the **read set**, over `children` and `reads`: what decides `dependent`
  and what `Certificate` records as the proof's dependencies (fingerprints,
  composed certificates).

The changes use the existing dependency mechanism:

* The callee is tested by the same three conditions as every evaluated
  expression. The test is for the reference itself, not a second name
  lookup: the resolved HIR already says it failed (an UNBOUND whose `expr`
  is the reference).
* The `never` callee's summary is an ordinary summary. It has the same
  taint, the same fixpoint and the same sharing across claims, so its taint
  reaches `CheckClaim` and its fingerprint the certificate. Its exits are
  empty, as its type says, and it yields nothing (`MayYield` is false).
  The call is a failure point and ends the walk, as before.

**Why a second edge.** A first version took that summary with `Child`.
The JSON and CSV emitters, the census and the fuzzer were unchanged, but
an accepted program was not:

```botlish
fn spin(c: Coded):
    k = c.code()
    loop:
        continue

fn emitter() -> unit emits digit_token:
    yield 49
    spin(Seven {unused: 0})
    unit
```

`spin` is a trait-polymorphic function, so the walk meets its
specialization, which it does not follow (EMIT-UNSUPPORTED). As a child,
that violation became the claim's: `not-proved`, and a compilation that
had been accepted was rejected. Nothing the walk does not follow in such a
helper matters to the trace:

* the helper yields nothing;
* its exits, result and failures are not used: the walk ends at the call,
  and the call is the failure point.

Only what its code holds matters, which is what `Read` keeps. A summary
also reached as a child, from another call that does rely on what the
function does, is judged as one. `ec-callee-genuine-nonreturn` pins the
program above (`proven`, no diagnostic), and the `never-helper-judged`
mutant, which judges the read set, is killed by it.

Evaluation order is unchanged. The callee is read where it was, before
the arguments. A yield before the call is still in the trace (`visits`).
No path through the unknown call is invented: the walk still ends at it,
and the claim is dependent instead of judged.

## 7. Direct and transitive dependencies

Each case is `dependent` after the change, with no EMIT diagnostic and no
certificate:

| case | before |
|---|---|
| `later()` declared after the claimed function; `missing()` never declared | proven |
| `yield 48 + missing()`; `if missing():`; `missing()` after a yield; `missing():` with `on Oops:`; `h(missing())`; inside a counted loop's body; `missing(step)` with a coroutine handle | proven |
| a helper declared `-> unit` whose body calls `missing()` | proven |
| a helper whose inferred result is `never` (`fn helper(): missing()`) | proven |
| two levels: `h1() -> unit` calls `h2()`, whose inferred result is `never` because of `missing()` | proven |
| a yielding helper declared `-> unit`: `missing(); yield 49; unit` | rejected (EMIT-INCOMPLETE) |
| a recursive helper reaching `missing()` on one branch (non-yielding, and yielding) | proven, rejected (EMIT-INCOMPLETE) |
| a function with two claims, `emits digit_token, one` | proven, proven |
| a claimed coroutine source calling `missing()` | proven |
| a partial revision (a syntax error elsewhere) with `missing()` in the claimed function | proven |

Summaries are shared by every claim of a compilation. Taint is a fact of a
summary, never of the claim that first computed it, and it only grows
(`Summary` joins it across rounds). So:

* a helper's clean summary stays clean when a later claim reuses it after
  a claim that also called an unresolved name: `a` is dependent and `b`,
  calling the same helper with the same arguments, is proven;
* a tainted summary stays tainted when reused: `c` and `d` both call one
  broken helper, and both are dependent.

`ec-callee-independent` pins both; the `reuse-drops-taint` and
`final-children-clean` mutants would break them.

## 8. `never` and genuine noncompletion

`never` is unchanged everywhere. What changed is that the walk no longer
ends at a `never` it has not read: the unresolved callee is tested, and
the code behind a function's `never` result is walked.

* **Genuine noncompletion is certified as before.** Each of these is
  `proven`, the yield after the call unreachable, as the guarantee permits
  (prefixes viable, no termination claim):
  * `fn spin(): loop: continue`;
  * an endless recursion `fn forever(n: int): forever(n + 1)` called
    through `spin`;
  * `yield 49; spin(); yield 65`.

  Their summaries are clean and have no exits, consistent with their type.
  The certificate now lists them: `depends functions {emitter forever
  spin}`. A trait operation such a helper calls, which the walk does not
  follow, changes nothing: the helper is read, not judged (section 6).
* **A helper declared to return whose body loops** (`fn spin() -> unit:
  loop: continue; unit`) has the call type `unit`. The walk continues
  after it, as before, so a yield after it is checked (EMIT-AFTER-TOKEN for
  `yield 49; spin(); yield 65`). This is imprecise, never a false proof,
  and not changed here.
* **Unreachable calls.** An unresolved call in a branch the walk decides
  infeasible (`if false:`), or after a call that genuinely never returns,
  is not read. The claim is `proven`, and the UNBOUND is reported as
  always. A TYPE diagnostic in the same place gives the same verdict
  (`ec-callee-unreachable`). The proof does not depend on such a call:
  repairing the name changes nothing the walk reads.
* **An independent violation on another path.** In `if n > 0: missing()`
  followed by `yield 65` (not a digit), the walk reads the unresolved call,
  so the claim is dependent. This is the existing rule: a TYPE diagnostic
  in the same branch also makes it dependent (`ec-recovery-dependent`,
  `ec-callee-independent-path`). The violation is not lost: once the name
  resolves, the same program is `rejected` with EMIT-REJECTED at the yield.
  Before the change this program happened to be `rejected`, because the
  unresolved branch ended silently and only the other path reached the
  yield.

## 9. Error handling and coroutine boundaries

* **Handled calls.** `missing():` with `on Oops:` is evaluated by
  `EvalHandle` through `Eval` and `EvalCall`, so the callee is tested.
  The handler starts where the call may fail, as before, but it does not
  make the call resolved: the claim is dependent. The `handled-taint-scoped`
  mutant makes the taint a handler's and is killed.
* **Coroutine construction.**
  * `coroutine {step, first} = absent()` was already dependent: the
    construction is poisoned (COROUTINE-RHS-NOT-YIELDING).
  * Constructing a coroutine of a *resolved* function whose body calls
    `missing()` is still `proven`, also with `step()` resumed. The
    coroutine's yields are its own, the walk reads a construction as the
    native `coroutine#create`, and the claim's trace does not include the
    coroutine's (`ec-callee-coroutine`).
  * A claimed coroutine source with an unresolved call in its own body is
    dependent (it was proven).
* **Calls through a function value.** A non-`ref` callee is evaluated, as
  before. A local `f = missing` is read through its `bind` and was already
  dependent. A module-level value is section 17's.
* **Trait operations** stay EMIT-UNSUPPORTED before any of this (the
  `traitCall` test comes first), and trait and context-trait clones stay
  unsupported when walked.

## 10. Diagnostic ownership and recovery

* **No new diagnostic.** UNBOUND keeps its location and message and is the
  first diagnostic a strict compilation raises. `dependent` reports
  nothing, as before: there is no EMIT-DEPENDENT. The made-up
  EMIT-INCOMPLETE of a helper walk that stopped at an unresolved call is
  gone (section 5), so the HIR holds no EMIT diagnostic for these programs.
* **The dependency is the walk's.** A claim is dependent only when its walk
  reads the diagnosed code. An unrelated broken function taints nothing
  else: `good` beside a broken `emitter` is proven, and so are
  `good`'s two claims beside `emitter`'s two dependent ones. The
  `taint-everything` mutant, which makes one diagnostic taint every claim,
  is killed.
* **`hir::recovery::reported` is unchanged.** It already withheld the check
  diagnostics of units that depend on a resolution failure. Now the
  record's verdict says the same thing.
* **Static compile.**
  * A claim inside a `static compile:` block that calls `missing()`
    rejects the block with UNBOUND, the block's first diagnostic, both
    before and after the change: the claim adds no diagnostic.
  * A claimed function that holds a rejected block in statement position
    (`static compile: missing()`, then `yield 49`) is `proven` with no
    diagnostic. The block's body is replaced before resolution (its
    UNBOUND is the block's own), and the walk goes on after the reified
    failure (`hir::static::reifiedStatement`).

  Both are `ec-callee-static-compile`.
* **Syntax recovery.** A malformed call (`missing(1 +)`) is a hole and was
  already dependent. An UNBOUND in a partial revision (a syntax error
  elsewhere) is now dependent; it was proven (`ec-callee-syntax-recovery`).

## 11. Compiler-service behavior

The service's hover appends `hir::emission::ClaimText` of the revision's
own records (`service::Hover`). It has no logic of its own, and the
language server only forwards it. `ec-callee-service` edits one buffer
through four revisions:

| revision | diagnostics | `good`'s hover | `emitter`'s hover |
|---|---|---|---|
| `later` declared after `emitter` | UNBOUND | certified | not checked -- its code holds another diagnostic |
| `later` moved before `emitter` | none | certified | certified |
| moved back | UNBOUND | certified | not checked |
| moved back, a syntax error in a third function (partial) | SYNTAX, UNBOUND | certified | not checked |

Both claimed functions are uncalled: a claim is checked from its
declaration whoever calls it.

## 12. Certificates, the memo, interchange and the cache

A dependent claim gets no certificate: none in its record, none in the
compilation's certificates (so no caller composes with it), none in the
memo (`ec-callee-unbound` checks that the memo stays empty). The memo
transitions, one workspace edited in place (`ec-callee-memo`; verdict,
reused):

| program | before the change | after |
|---|---|---|
| v1: `later` declared first | proven, fresh | proven, fresh |
| v2: `later` declared after (UNBOUND) | **proven**, fresh | dependent |
| v3: v1 again | proven, fresh | proven, reused (the code is v1's) |
| w1: `fn h(): loop: continue`; `yield 49; h()` | proven, fresh | proven, fresh (depends on h) |
| w2: `fn h(): missing()` | **proven, reused** | dependent |
| w3: w1 again | proven, reused | proven, reused |
| w4: w1 plus an unrelated function | proven, reused | proven, reused |

w2 was a second hole. The w1 certificate relied on `h` never returning
but did not list `h`'s fingerprint, so a change to `h`'s body that kept
its type `never` validated. The emitter's own fingerprint did not change:
`h()` is still `fn h`, typed `never`. Now the fingerprint is listed and
w2 is proved again. In v2 the emitter's own fingerprint changes: an
unresolved call is printed as a call through a value, with no target.

* **Interchange.** A lenient HIR with the dependent claim round-trips
  through `hir::interchange::encode`/`decode`, and the reader's
  re-verification derives the same records. The dependent record forged
  into `proven` with another claim's certificate is refused
  (`HIR INTERCHANGE EMISSION`).
* **The cache.** A strict compilation with the UNBOUND raises, so it is
  never cached. The repaired program hits its earlier entry, which is
  verified again, `proven` (`ec-callee-cache`).

No new store: the existing fingerprints, the keyset and the memo's
validation do all of this.

## 13. Positive and negative tests

All are in `tests/emission-claims.test`, section "Unresolved callees":

| test | the spec's case | on the tree before the change |
|---|---|---|
| `ec-callee-unbound` | A (forward reference), B (unknown name); UNBOUND's location and message; no memo entry | fails |
| `ec-callee-positions` | nested expression, condition, after a yield, G (handled), an argument, a loop body, a coroutine handle | fails |
| `ec-callee-helpers` | C (helper), the inferred-`never` helper, two levels, a yielding helper, H (recursion, both kinds) | fails |
| `ec-callee-independent` | D (independent claims), summary reuse clean and tainted | fails |
| `ec-callee-genuine-nonreturn` | E (genuine noncompletion), the dependency on the never helper | fails (the dependency) |
| `ec-callee-unreachable` | unreachable calls, parity with TYPE | passes (pins unchanged behavior) |
| `ec-callee-independent-path` | F (an independent violation), parity with TYPE, the repaired program | fails |
| `ec-callee-multiple-claims` | L (multiple claims) | fails |
| `ec-callee-coroutine` | I (coroutine construction and boundary) | fails (the claimed source) |
| `ec-callee-memo` | J (incremental repair) through the memo, the never helper's dependency | fails |
| `ec-callee-interchange` | interchange: re-verification, a forged certificate | fails |
| `ec-callee-cache` | the front-end cache | passes (pins unchanged behavior) |
| `ec-callee-static-compile` | static compile, both directions | passes (pins unchanged behavior) |
| `ec-callee-syntax-recovery` | K (syntax recovery) | fails |
| `ec-callee-service` | the compiler service through four revisions | fails |

The tests were run on the tree before the change by copying the test file
into a worktree of `HEAD` before the change: 12 failed, 3 passed.

## 14. Mutation evidence

14 new mutants in `audit/emission-claims/tools/mutants.txt`, section
"Unresolved callees", each killed by the tests named:

| mutant | the bug | killed by |
|---|---|---|
| `callee-ref-untainted` | the callee reference not read (the defect) | ec-callee-unbound, -positions, -multiple-claims, -memo, -service, -interchange |
| `callee-taint-after-never` | the callee read only for a call that completes | ec-callee-unbound, -positions, -multiple-claims, -memo, -service |
| `callee-nested-untainted` | read only for a call that is a statement of the body | ec-callee-positions |
| `never-helper-unread` | a never helper believed from its type | ec-callee-helpers, -genuine-nonreturn, -memo |
| `never-helper-judged` | a never helper's code judged, not only read: its trait operation rejects an accepted program | ec-callee-genuine-nonreturn |
| `reads-untainted` | the read summaries no part of the dependency | ec-callee-helpers, -memo |
| `reads-not-certified` | the certificate depends on what was judged, not what was read | ec-callee-genuine-nonreturn, -memo |
| `never-helper-dependent` | a genuine nonreturning call made dependent | ec-callee-genuine-nonreturn, -memo, -unreachable |
| `handled-taint-scoped` | a handled call's taint dropped with its failures | ec-callee-positions |
| `reuse-drops-taint` | a reused final summary is clean | ec-callee-independent |
| `final-children-clean` | a converged solve's child summaries clean | ec-callee-helpers, -independent |
| `taint-everything` | one diagnostic taints every claim | ec-callee-independent, -multiple-claims, -unreachable, ec-recovery-dependent |
| `dependent-certified` | a dependent claim still certified and memoized | ec-callee-unbound, -memo |
| `hover-dependent-certified` | the hover says certified for a dependent claim | ec-callee-service |

The whole catalog, `tclsh9.0 audit/emission-claims/tools/mutate.tcl`,
ran 86 mutants: 86 killed, 0 survived, all applied (2 min 36 s). That includes the earlier milestones'
failure-propagation, summary, recursion, budget, memo and trust mutants.
Two existing mutants edit lines this change touched:

* `dependent-reports` edits the test that moved into `Taint`. Its text is
  unchanged and still occurs once, so it now mutates both readers.
* `taint-everything`'s text names the read set now.

`tclsh9.0 tools/mutant-catalogs.tcl`: 86 catalogs, 3,069 mutants, 0
problems.

## 15. Regression results

Measured on the change as committed, with the tree before it (a worktree
of the parent commit) as the baseline where a comparison says "the same":

| check | result |
|---|---|
| `tests/emission-claims.test` | 110 of 110 (95 before, 15 new) |
| `tests/csv-emission.test` | 36 of 36, on interp and compile |
| `audit/emission-claims/tools/census.tcl -part all` | no false proof, every case as expected: the modular census's 25 claims (10 certified, 14 rejected and disproven by a run, 1 not certified with no counterexample), the exploratory mistakes 31 of 31; every row identical to the baseline's |
| `audit/emission-claims/tools/fuzz.tcl -seeds 1-12` | 96 claims, 72 proven, 24 rejected, 0 false proofs, 12,480 runs; identical to the baseline |
| `audit/emission-claims/tools/loops.tcl -count 80 -seed 11` | 15 proven, 65 rejected, 0 regressed, 0 false certificates, 13,520 runs, 24 cross-backend checks agreeing; verdicts and summary counts (224 computed, 60 reused, 160 rounds) the baseline's |
| `audit/emission-claims/tools/mutate.tcl` | 86 of 86 killed |
| `tools/mutant-catalogs.tcl` | 86 catalogs, 3,069 mutants, 0 problems |
| `tools/compilerpedia.tcl check` | passes |
| `tests/local.tcl` (every Tcl test file on interp and compile, every golden suite on four backends, through the front-end cache) | passes: every Tcl test on interp (8,798 passed) and compile (8,793 passed), 0 failed; every golden suite (117) on interp, compile, cranelift-generic and cranelift, 0 failed; 88 minutes with 4 jobs |

The JSON emitters (`examples/dfa/json`) and the CSV emitters
(`examples/dfa/csv`, the selective counted-loop field included) are all
certified, as before: 22 of 22 and 52 of 52 in their probe programs.

**Not run here.** The batched-against-sequential static-decision
comparison runs in CI, never locally (AGENTS.md). It runs on the next push
to main that changes `hir/`. The static-decisions fuzzer generates no
emission claims, so this change gives it nothing new to exercise.
`tests/static-economics.test` and `tests/static-compile.test` are part of
the local suite. The diagnostic-recovery, syntax-recovery,
compiler-service, LSP, HIR interchange and cache, DFA and coroutine test
files are too. No native code is involved: the checker is a compile-time
analysis, and no backend reads a claim.

**CI** (the branch at 5fa86cd):

| workflow | result |
|---|---|
| `tests`, canary (linux x86-64) | passed: every mutant applies, the warning gate, the canary |
| `tests (linux arm64)`, canary | passed |
| `icy-tower (windows x86-64)`, `icy-tower (macos arm64)` | passed |
| `tests (macos arm64)` | failed in one job, `Botlish.app (macOS arm64 distribution)`, step `single/smoke-test.sh` |
| `tests (windows x86-64)` | pending when this was written |

The macOS failure is `FAIL: package graph shows the shared geometry`:
`error writing "stdout": broken pipe` in `pm::commands::graph`. That is
the package manager, which this change does not touch. `main`'s own run
at 12ce65f, the commit this branch starts from, fails the same job at the
same step with the same message. The smoke, system-linker and four
acceptance-tier jobs passed. The full `tests` and `tests (linux arm64)`
workflows run on a branch only when dispatched (AGENTS.md); they were not
dispatched for this report.

**`main` when the branch started (12ce65f).** `tests`, `tests (linux
arm64)`, `tests (windows x86-64)` and `tests (macos arm64)` were in
progress: pending, not passed. `tests (macos arm64)` has since failed in
the job above. The last completed `tests` run (1f076e1) was green. The
last `raven clean room` and `package reproducibility` runs (1f076e1)
failed.

## 16. Performance and files changed

* **Accepted programs are unchanged.** Verdicts are the baseline's
  everywhere measured: the JSON and CSV probe programs, the census, the
  fuzzer and the loops differential. So are the summary counts: JSON 140
  computed, 60 reused, 44 rounds; CSV 207, 121, 104; loops 224, 60, 160.
  The new `never` branch is not taken at all by the JSON and CSV programs:
  no claimed function there calls a function whose result is `never`.
* **Time.** On an idle 4-core container, 5 runs each, medians:
  * JSON's 22 claims: 272 ms to check, against 279 ms before;
  * CSV's 52 claims: 733 ms, against 732 ms.

  That is within the runs' spread (JSON 261-327 ms, CSV 700-846 ms). The
  final version walks the summary graph once more per claim (the read
  set), which this does not show.
* **Programs without claims** do no work: `hir::emission::verify` returns
  before `Reset`, as before.
* **What a claim costs now.**
  * One `Taint` per call with a named callee that the walk visits: three
    dictionary lookups.
  * One ordinary summary per call of a function whose result is `never`
    and that yields nothing: one per function and argument context,
    shared, a body that never yields.
  * The fixpoint, the budgets and the memo's validation are unchanged.
  * A certificate lists the read functions' fingerprints too, so it
    validates a few more entries.
* **No runtime work, and no native code change.**

Files changed:

| file | change |
|---|---|
| `hir/emission.tcl` | `Taint` (`Eval` calls it); `EvalCall` taints a `ref` callee and reads a never helper (`Read`, the summaries' `reads`); `Reachable` over given edges; `CheckClaim`'s read set for the dependency and the certificate; the header's verdicts |
| `tests/emission-claims.test` | 15 tests, the `dependency` helper |
| `audit/emission-claims/tools/mutants.txt` | 14 mutants; `taint-everything`'s text |
| `AGENTS.md` | the emission rule: what the walk reads |
| `docs/INDEX.md`, `docs/EMISSION-COUNTED-LOOP-PRECISION-MILESTONE-1.md` | this report's line; section 18's note points here |

## 17. Remaining limitations and related omissions

Found while investigating; one fixed, the rest recorded:

* **Fixed: the never helper** (sections 5, 8, 12). It is the transitive
  form of the defect and the memo's missing dependency. It is fixed by the
  same mechanism, not a new one.
* **Left: values computed by an unresolved name.** A module binding
  `k = missing()`, or an enclosing function's local captured by a nested
  claimed function, read as `yield 48 + k`. Type inference types such a
  binding `any`, so the walk reads it as unknown. The claim is `rejected`
  with EMIT-END-SYMBOL and EMIT-REJECTED, which `hir::recovery::reported`
  withholds (the unit refers to a tainted unit). The same holds for
  `f = missing` at module level called as `f()`. None of these is a false
  proof: the facts over-approximate. `dependent` would be the accurate
  verdict. That needs a dependency on a binding's *declaration*, which the
  walk does not read (it reads the binding's facts). It is a separate
  question from callees, not taken up here.
* **Left: a helper's unresolved signature.** An unknown result or
  parameter type, or an unknown error, in a helper the claimed function
  calls. The call types normally and the claim is judged by its trace:
  rejected for a bad yield, otherwise proven. An unknown result type on the
  claimed function itself leaves the claim proven, consistently with "a
  claim is about the yield trace, never the result"
  (CSV-EMISSION-VALIDATION-MILESTONE-1.md, section 18). No false proof
  found. The diagnostic is on the declaring block, which the walk does not
  evaluate.
* **Existing, unchanged: a helper declared to return whose body never
  does** (section 8). The walk goes on after the call: imprecise, never
  unsound.
* **Existing, unchanged: an unresolved name is a divergence to the other
  analyses.** Code after `missing()` is unreachable to type inference and
  its own checks do not run (DIAGNOSTIC-RECOVERY.md, section 2). Making the
  placeholder poison would change `never`'s recovery semantics for every
  analysis, which this milestone does not do. The emission checker no
  longer depends on that divergence for these calls.
