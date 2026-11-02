# STATIC-COMPILE-EXPECTED-DIAGNOSTICS-MILESTONE-1.md

Negative compilation tests of static semantic proofs -- KNOWN-ERROR above
all -- through `static compile:` (STATIC-COMPILE.md) and the golden
framework's matchers (GOLDEN-TEST-FRAMEWORK.md). Completion report.

## Contents

1. [Result](#1-result)
2. [The reproducers and the original failure](#2-the-reproducers-and-the-original-failure)
3. [Existing syntax and assertion semantics](#3-existing-syntax-and-assertion-semantics)
4. [Root cause](#4-root-cause)
5. [The correction](#5-the-correction)
6. [Why KNOWN-ERROR itself is unchanged](#6-why-known-error-itself-is-unchanged)
7. [Diagnostic ownership, isolation and recovery](#7-diagnostic-ownership-isolation-and-recovery)
8. [Static scheduling and dependency ordering](#8-static-scheduling-and-dependency-ordering)
9. [Compiler service and incremental behavior](#9-compiler-service-and-incremental-behavior)
10. [Positive and negative tests](#10-positive-and-negative-tests)
11. [Mutation evidence](#11-mutation-evidence)
12. [Regression results](#12-regression-results)
13. [Source compatibility](#13-source-compatibility)
14. [Remaining limitations](#14-remaining-limitations)

## 1. Result

**The facility the brief asks for already existed, and works.** A
`static compile:` block whose code is a statically known failure is
rejected with the ordinary KNOWN-ERROR, reified as
`std::compiler::DiagnosticCode::KnownError` at the failing call, and
`std::test::rejects` / `rejects_at` assert it; the enclosing program
compiles; the same failure in ordinary code is still rejected. This holds
for every form the brief lists (direct, handled, on a reachable branch, a
helper failing on every path, constant arithmetic, range narrowing, exact
`mod`), and the matchers tell KnownError apart from a Type, an
UnhandledError, an Unbound, no diagnostic and a KnownError at another call.
140 KnownError expectations in 29 golden suites already relied on it. No
language change was made for it.

**The census found one real gap, and it is fixed.** A rejected block
standing as a *statement* made the code after it in its function
unreachable for the checks: the reified failure is a `fail`, and the
ordinary rule reports no completion or ownership diagnostic after a
statement that never completes. So a negative test silently switched off
the checks of the code around it -- that code's KNOWN-ERROR,
UNHANDLED-ERROR (an undeclared error escaping its function), USE-AFTER-MOVE,
unhandled bounds, relational proofs and emission checks, and the
diagnostics of a later block in the same sequence -- and gave the range
analysis no facts there (a provable admission became a spurious TYPE). Whether
the surrounding code was checked depended on whether the test's block
compiled. That is exactly an expected diagnostic escaping its testing scope.

The fix is general -- every diagnostic kind, every analysis that ends a
statement sequence at a statement that never completes -- and narrow in
position: a rejected block in statement position ends no sequence for the
checks (`hir::static::reifiedStatement`). The run time is unchanged.

## 2. The reproducers and the original failure

The brief's conceptual reproducer, in the repository's syntax, passes
unchanged on the tree before this milestone (`sced-known-error-forms`,
`tests/golden/static-compile-expected-diagnostics.bot`):

```botlish
fn handled() -> int errors std::compiler::CompilerError:
    static compile:
        r = reject():
            on ParseError:
                42
        r
std::test::rejects_at("handled", std::compiler::DiagnosticCode::KnownError, 28, 17, handled)
```

The motivating case -- exact `mod` (EMISSION-CLAIMS-MILESTONE-1.md,
section 4) turned `g(mod(500, 11) - 5)` into a KNOWN-ERROR, and the tests
that wanted the run-time value hid the input with `std::int::from_string`
-- is pinned directly now (`sced-exact-mod`): the literal form is a
`rejects_at` KnownError at the call, the hidden form a value `[3, -1]`.
Hiding the input was the right fix for those tests (their theorem is the
run-time value of a recursion on an input the compiler cannot decide); the
compile-time fact simply had no test of its own.

The smallest reproducer of the gap (`dead3`, `sced-following-code-checked`):

```botlish
fn t() -> int errors std::compiler::CompilerError:
    static compile:
        missing          # the test: rejected Unbound
    reject()             # ParseError escapes t, which declares only CompilerError
```

Before: the program compiled -- `reject()` was dead code after the reified
`fail`, so its KNOWN-ERROR and the escaping ParseError were never
reported. With the block accepted instead (`1`), the program is rejected.
The census's full table (the program diagnostics of code after a block,
rejected / accepted, before this milestone):

| code after the block | rejected (before) | accepted |
|---|---|---|
| a handled known-failing call | none | KNOWN-ERROR |
| an unhandled always-failing call | none | KNOWN-ERROR (twice: the call, and t's caller) |
| `a = step` then `b = step` | none | USE-AFTER-MOVE |
| `std::list::at([1, 2], n)` | none | UNHANDLED-ERROR |
| `want(20)` (a 0..10 parameter) | TYPE, facts `[-∞, +∞]` | TYPE, facts `[20, 20]` |
| `want(5)` | TYPE (spurious: no facts) | none |
| `m.reorder(order)`, order unproven | none | REORDER-NOT-PROVEN |
| a second block, a known failure | the block accepted | the block rejected KnownError |
| a callee's yield after its rejected block, under an `emits` claim | EMIT-INCOMPLETE | the claim's violations at the yield |
| `1 + "s"` | TYPE | TYPE |

TYPE errors were reported anyway (types are checked in dead code), which is
why the gap went unnoticed: the existing tests of rejected blocks followed
by code (`sc-tx-refinement/rejected`) expect a TYPE.

## 3. Existing syntax and assertion semantics

* **`static compile:`** (STATIC-COMPILE.md) is a recoverable
  semantic-compilation boundary, deliberately *not* an assertion: an
  accepted block is its body; a rejected one is
  `fail std::compiler::CompilerError {code, primary, related, message}`
  reifying the block's first diagnostic (the one a strict compilation would
  raise first), located in the block's file. A block takes exactly the
  diagnostics whose primary location lies in its body (the innermost
  block, same file); every other diagnostic is the enclosing program's. A
  parse error is the program's, never a block's.
* **The assertions are the golden framework's** (`stdlib/test.bot`):
  `std::test::rejects(name, code, body)`, `rejects_at(..., line, column,
  ...)`, `rejects_message`, `rejects_containing`, `rejects_any`, and the
  matcher `std::test::diagnostic` for custom checks. They compare the
  reified `code` (and location, message) when the suite runs, and report a
  mismatch -- naming what was observed -- as data. They are the only
  assertion language; this milestone added none.
* **KNOWN-ERROR and the reified failure** (STATIC-COMPILE.md, report item
  18): a path ending in a reified failure sets the completion walk's
  `intended` flag, so a call of a function whose block was rejected is
  never KNOWN-ERROR -- reporting that failure is the intrinsic's purpose.

What "the enclosing program is rejected when the assertion fails" means
here: a block that compiles when the test expected a diagnostic makes the
suite report a FAIL (`tests/golden/run.tcl` exits 1, CI fails); the
compiler cannot reject it, because `static compile:` is not an assertion
and has no expected code to compare (STATIC-COMPILE.md, "The construct").
Every test of this milestone checks both directions.

## 4. Root cause

Not collection, reification, scheduling or attribution -- all four were
right (sections 7, 8). The cause was reachability. Rejecting a block
replaces it, in the program the checks see, with a `fail`; a `fail` never
completes; every analysis ends a statement sequence at a statement that
never completes, and reports nothing (completions, ownership, relations,
emission) or checks without facts (ranges) after it. The `intended` rule
already said the opposite to the block's *callers* -- a rejected block may
complete normally, because its failure is the test's report and not the
program's behavior -- but nothing said it to the code after the block in
its own function. Each analysis that ends a sequence did it in its own walk:

| analysis | where it ended the sequence |
|---|---|
| types (the `reachable` flags every other analysis reads: coroutines, contexts, signatures, specialization, decimal, fold, operators, refinements) | `hir::types::Sequence` (`Halts`) |
| ranges | `hir::range::Sequence` |
| completions (KNOWN-ERROR, UNHANDLED-ERROR, bounds, summaries) | `hir::completions::Seq` |
| ownership (USE-AFTER-MOVE, releases) | `hir::affine::Seq` (state `dead`) |
| relations (REORDER-NOT-PROVEN) | `hir::relations::Seq` |
| emission claims (EMIT-*) | `hir::emission::EvalBody` |

## 5. The correction

`hir::static::reifiedStatement HIR SEQUENCE E` is 1 when E is a rejected
block's reified failure standing as a statement of SEQUENCE: any element
but the last, its value discarded. Each walk above goes on after such an
element as if the block completed:

* **types**: no halt -- the code after it is `reachable`, for every
  analysis that reads the flags;
* **ranges**: the walk continues -- the code after it has its facts;
* **completions**: the CompilerError is charged, the walk continues, and
  the `intended` flag is restored: no path ends at the block, so it is no
  intended completion either. A function whose code after the block always
  fails is therefore a KNOWN-ERROR to call -- exactly as with the block
  accepted (`sced-following-code-checked`'s caller);
* **ownership**: the block's failure is still an exit (its state recorded,
  `ExitReleases` releasing there what the function owns), and the code
  after it is analyzed with what was owned before it (the payload is
  constants);
* **relations, emission**: the walk continues from the state before the
  block (emission still records the failure point, so prefixes at it are
  checked).

What it does *not* touch: the backends (native lowering stops at its own
`never`, the Tcl backends raise), the exit releases at the failure, and
every run-time decision that depends on the failure's real control flow
(`hir::mutvec::LaterIn`'s moves). At run time the block fails there and
nothing after it runs (`sced-following-code-never-runs`: the same value on
every backend; the coroutine handle is released by the failure, an exit).

Value positions keep the ordinary rule: where the block's value is used --
a binding's value, a destructuring's, a `return`'s, the last expression of
a body -- the reified failure is that value's failure, and the code
reading the value is unreachable as after any failure. Checking it would
check uses of a value that never exists: `x = static compile: missing`
then `std::list::at([1], x)` must not report an unhandled IndexNotFound
for an `x` with no facts (`sced-value-position-unchanged`). A block as a
body's last expression, a binding's or a `return`'s value is a divergence,
and the decided program holds no poison (`sced-value-position-diverges`;
DIAGNOSTIC-RECOVERY.md: poison never exists in a valid program).

No new diagnostic, mechanism, HIR form, side table or runtime operation.
The `static` mark the completion walk and SAME-FAILURE already read is read
by one more rule. The change is the six walks above plus the predicate.

## 6. Why KNOWN-ERROR itself is unchanged

KNOWN-ERROR's rule -- a call that can never complete normally under the
facts proven at it is an error, handler or not -- is untouched: no
demotion, exemption for handled failures, `never`, or suppression. The
only completion change is where a walk *ends*: code that used to be
unreachable after a rejected statement is reachable now, so KNOWN-ERROR
applies to more code, never to less. The `intended` exemption is unchanged
for every path that ends in a reified failure; a rejected statement simply
ends no path.

One consequence is a stronger rule for the code around a test, not a
weaker one: before, `fn t(): static compile: missing; fail Boom` was
exempt to its callers (its only reachable path ended in the reified
failure); now the `fail Boom` after it is reachable, `t` always fails Boom
under the as-if-completed model, and a handled `t()` is KNOWN-ERROR -- as
it is when the block is accepted.

## 7. Diagnostic ownership, isolation and recovery

* **Ownership.** A diagnostic belongs to the innermost block whose body
  holds its primary location, *in the same file* (`hir::static::Owner`
  compares the file before the offsets). Pinned: a module's KNOWN-ERROR
  whose line, column and character offset all fall inside the entry
  program's block stays the program's (`sced-other-file`); a KNOWN-ERROR in
  a function the block calls (`sced-outside-scope` (a)) or in a sibling
  block (b) is never the tested block's.
* **Isolation.** A block's expected diagnostic is never the program's: the
  same handled call in ordinary code still rejects the program, at its own
  location, and is the program's only diagnostic
  (`sced-ordinary-known-error-rejects`); an independent TYPE is reported
  beside it (`sced-independent-diagnostic-visible`). With this milestone a
  rejection also no longer hides the diagnostics of the code after it
  (section 5): for each of seven snippets the program's diagnostics are
  *identical* with the block rejected and accepted.
* **One diagnostic per block.** A block reifies its first diagnostic; a
  matcher pinning another call of the same block fails
  (`sced-assertion-distinguishes`, `second-call`). A second diagnostic in a
  rejected body is part of that body, discarded with it -- one expectation
  per block is the testing contract.
* **Recovery.** Unchanged: DIAGNOSTIC-RECOVERY.md's dependency model
  decides what the enclosing program reports; the newly reachable code is
  ordinary code (no poison, no holes, nothing tainted).

## 8. Static scheduling and dependency ordering

The sequential order and the three schedulers were already right for
expected diagnostics:

* **Resolution first.** A round that stops after resolution rejects the
  blocks with resolution diagnostics and builds again; a block holding a
  known failure and, in a later statement, an unbound name is Unbound --
  never a KnownError certified from a program that does not resolve
  (`sced-resolution-first`). An unbound name of the enclosing program
  rejects the program whatever the blocks expect.
* **No stale verdict.** In `sced-callee-dependency`, `h`'s block (a TYPE,
  then `fail E`) makes `h` always fail E in the first build, so `a`'s
  handled `h()` is a KNOWN-ERROR there. The batched scheduler rejects `h`'s
  block, marks `a`'s *unknown* (it depends on `h`'s: "position function a
  -> calls function h -> holds site", the trace says) and builds again,
  where `a`'s block is accepted -- `h`'s rejection is an intended outcome.
  The sequential order decides the same.
* **Agreement.** `scedSame` checks the batched, sequential and legacy
  schedulers decide identically, with no misprediction, on the programs
  with sequence siblings, resolution-first blocks and the distinguishing
  suite (`sced-schedulers-agree`, `sced-following-sequence-siblings`).

The fix changes decisions only where it should: a later block in the same
statement sequence as a rejected one now keeps its own diagnostic (it used
to be accepted: `se-equal-sequence`, updated, and
`sced-following-sequence-siblings`). That makes a block's verdict depend on
*less* -- not on whether an earlier sibling compiled. hir/staticdeps.tcl's
position edge (a site depends on the region its body stands in, because a
rejection could make the code after it unreachable) is kept: it is still
true for value positions and costs nothing here.

The golden suites' batched-against-sequential comparison runs in CI only
(AGENTS.md); it was dispatched on this branch
(`.github/workflows/static-decisions.yml`), see section 12.

## 9. Compiler service and incremental behavior

Through `service/service.tcl` (`sced-service`,
`sced-service-following-code`):

* an expected KNOWN-ERROR is no diagnostic of the program: the revision's
  outcome is `ok`, its HIR's block rejected KNOWN-ERROR;
* editing the tested call makes a new revision whose block is accepted;
  the old revision is unchanged (revisions are immutable), and the first
  text again gives the first result;
* an ordinary KNOWN-ERROR beside the block is reported at its own location,
  the block still rejected;
* a syntax error elsewhere gives `syntax`/`partial` with only the syntax
  diagnostic and *no* decided block (syntax recovery turns blocks into
  holes: an expectation is never certified from missing analysis);
* the code after a rejected block keeps its diagnostics, at their own
  locations, the same as with the block accepted.

The front-end cache keys an entry by the program text, so an edited block
is a miss and is decided again; the old text is a hit with the old
decision (`sced-cache`, through `surface::cache::stats`). HIR interchange
carries the reified failures as ordinary HIR: a decoded program has the
same sites and the same report on every backend (`sced-interchange`). The
language server consumes the service unchanged; no feature was added.

## 10. Positive and negative tests

`tests/static-compile-expected-diagnostics.test` (21 tests, about 90 s) and
its golden port `tests/golden/static-compile-expected-diagnostics.bot` (32
tests, every backend; 6 whole-program builds). On the tree before this
milestone the Tcl file fails exactly its five tests of the gap
(`sced-following-code-checked`, `-range-facts`, `-sequence-siblings`,
`-emission`, `sced-service-following-code`) and the golden suite exactly
its seven `following` tests; everything else passed already.

The brief's section 8, item by item:

| # | case | test |
|---|---|---|
| 1 | the expected KNOWN-ERROR occurs | `sced-known-error-forms` (9 forms) |
| 2 | the call becomes valid: the assertion fails | `sced-assertion-distinguishes` (`valid`: FAIL, value 1) |
| 3 | another diagnostic: the assertion fails | `sced-assertion-distinguishes` (Type, UnhandledError, Unbound: FAIL naming each) |
| 4 | the diagnostic outside the tested scope | `sced-outside-scope` (callee, sibling), `sced-other-file` |
| 5 | beside an independent unexpected diagnostic | `sced-independent-diagnostic-visible`, `sced-following-code-checked` |
| 6 | an unresolved dependency | `sced-resolution-first` |
| 7 | discovered through range analysis | `sced-known-error-forms` (`narrowed`, `exact-mod`), `sced-exact-mod` |
| 8 | a nearby ordinary KNOWN-ERROR still rejects | `sced-ordinary-known-error-rejects` |
| 9 | two tests expecting different diagnostics | `sced-outside-scope` (b), `sced-following-sequence-siblings` |
| 10 | a change re-evaluates | `sced-service`, `sced-cache`, `sced-callee-dependency` |

The brief's section 6 forms are `sced-known-error-forms`'s nine cases,
each with its ordinary-compilation counterpart in the table above (a
possible failure and a branch the facts rule out are accepted and run).
Several whole-program theorems are ported as an *outer* block holding the
program: the outer block is rejected with the diagnostic the program would
be, while a block nested in it is decided first and keeps its own
(STATIC-COMPILE-ADAPTATION in the manifest). Every golden test can fail
(`audit/golden/tools/perturb.tcl`: 32 inverted, 32 altered, 23 located all
fail as required).

Two existing tests pinned the old behavior and were updated, with their
census rows: `se-equal-sequence` (the second block in a sequence keeps its
KNOWN-ERROR) and `se-equal-emission-callee` (a claim over a yield after a
rejected block is judged on that yield; its violations are those of the
accepted variant).

## 11. Mutation evidence

17 mutants were added to `audit/static-compile/tools/mutants.txt`, whose
harness now runs `tests/static-compile-expected-diagnostics.test` beside
`tests/static-compile.test` by default (and copies `service/` and
`audit/static-decisions/`, which it sources):

| mutant | the bug |
|---|---|
| `known-error-escapes` | a KNOWN-ERROR never reaches its block: the program's |
| `known-error-wrong-code` | KNOWN-ERROR reified as UnhandledError |
| `attribute-ignores-file` | a diagnostic of another file belongs to a block |
| `attribute-past-end` | a diagnostic after a block belongs to it |
| `matcher-any-code` | `std::test::rejects` accepts any code |
| `matcher-any-location` | `rejects_at` accepts any location |
| `resolution-round-final` | a resolution-only build taken as final |
| `stale-decision-kept` | a rejection does not make its dependents unknown |
| `cache-key-ignores-source` | an edited block read back with the old decision |
| `statement-dead-types` ... `statement-dead-emission` | each of the six walks stops at a rejected statement again |
| `statement-keeps-intended` | a rejected statement still counts as an intended completion |
| `reified-any-position` | the rule applied to the last expression of a body too |

**All 38 mutants apply and are killed.** The 17 new ones by
`tests/static-compile-expected-diagnostics.test` alone (`-tests` it,
`-fuzz-count 0`):

| mutant | killed by |
|---|---|
| `known-error-escapes` | 12 tests (the suites stop compiling) |
| `known-error-wrong-code` | `sced-known-error-forms`, `-assertion-distinguishes`, `-exact-mod` |
| `attribute-ignores-file` | `sced-other-file` |
| `attribute-past-end` | `sced-ordinary-known-error-rejects`, `-independent-diagnostic-visible`, `sced-service` |
| `matcher-any-code`, `matcher-any-location` | `sced-assertion-distinguishes` |
| `resolution-round-final` | `sced-resolution-first`, `-assertion-distinguishes`, `-following-sequence-siblings` |
| `stale-decision-kept` | `sced-callee-dependency` |
| `cache-key-ignores-source` | `sced-cache` |
| `statement-dead-types` | `sced-following-code-checked`, `-range-facts`, `-emission` |
| `statement-dead-completions` | `sced-following-code-checked`, `-sequence-siblings`, `sced-service-following-code` |
| `statement-keeps-intended` | `sced-following-code-checked`, `sced-service-following-code` |
| `statement-dead-affine`, `-relations` | `sced-following-code-checked` |
| `statement-dead-range` | `sced-following-code-checked`, `-range-facts` |
| `statement-dead-emission` | `sced-following-emission` |
| `reified-any-position` | `sced-value-position-diverges` |

The first run found two survivors, both gaps of the tests, not of the
compiler: `attribute-ignores-file` survived a `sced-other-file` whose
module diagnostic overlapped the block by line and column but not by
character offset (attribution compares offsets): the test now places it
inside by both and asserts that it does. `reified-any-position` -- the rule
applied to a body's last expression too, which makes a function whose whole
body was rejected return poison instead of diverging -- had no test of the
value positions' divergence: `sced-value-position-diverges` pins that the
decided program holds no poison. Both were then killed.

The 21 mutants the harness had before are killed by its original detectors
(`tests/static-compile.test` and the fuzzer, 12 programs): every one by
failing tests, 14 of them by fuzz disagreements as well -- none weakened by
this change.

## 12. Regression results

**Results pending**: the full local run, the fuzzers and CI's `static-decisions` comparison are in progress; this section is completed with their results in the next commit. Done so far: `tests/static-compile-expected-diagnostics.test` 20/20, its golden suite 32/32 on all four backends, `tests/static-compile.test` 83/83, `tests/errors.test` 51/51, the golden suites `static-compile.bot`, `diagnostics.bot` and `completion-regressions.bot` on all four backends, `tools/compilerpedia.tcl check` (0 problems).

## 13. Source compatibility

A program that compiled may now be rejected only if it has a rejected
static block in statement position followed, in the same sequence, by code
with a diagnostic of its own -- a diagnostic it would have with the block
accepted. Nothing in the repository's corpus but the tests named above has
such code: across `tests/golden/`, `examples/` and `stdlib/` seven blocks
are followed by statements in their sequence, all in `static-compile.bot`,
and its 81 tests pass unchanged on every backend. The run time of every
program is unchanged.

## 14. Remaining limitations

* **Value positions.** Where a rejected block's value is used, the code
  reading it stays unreachable for the checks, including code that does not
  read the value (statements between the binding and its first use, or
  after it). Telling those apart needs poison semantics for a value of a
  *valid* program, which DIAGNOSTIC-RECOVERY.md reserves for programs with
  a diagnostic; a test that wants the code after its block checked writes
  the block as a statement.
* **An unhandled call of a fully rejected function.** A function whose
  whole body is a rejected block and that declares no result type
  (`fn t() errors std::compiler::CompilerError:`) infers the result
  `never`, so a call of it that the caller does not handle (it admits
  CompilerError) diverges for the types: the caller's code after that call
  is unreachable for the flag-reading analyses (ownership among them),
  while the completion analysis, by the `intended` rule, still checks it.
  The test framework never calls a body that way (`body()` stands under a
  handler, whose value does not diverge), and a declared result (`-> int`)
  types the call by the declaration, so the code after it keeps every
  diagnostic. Treating such calls as non-divergent would need a typed
  notion of "never only by intention" for calls -- the mutant
  `reified-any-position` shows that reusing poison for it puts poison in a
  valid program -- and is left for a milestone that needs it.
* **A pre-existing defect outside this milestone.** Ordinary dead code
  after a statement that always fails (`fail Other` then `want(5)`) gets no
  range facts, yet range admission checks it: a provable call is a spurious
  TYPE naming `[-∞, +∞]`. It is not about expected diagnostics (it needs no
  static block) and is left as it is; the statement rule fixed it only
  after a rejected block.
* **A stale description elsewhere.** `tests/byte-set.test`'s
  `byte-set-generic-domain-check-out-of-range` calls
  `check(mod(500, 11) + 10)` "for a dynamic out-of-domain n"; with exact
  `mod` the argument is the constant 15. The test compiles leniently
  (`-strict 0`) on purpose and still observes the run-time check, so it
  passes; its description no longer matches.
* **Hover inside a rejected block** shows the reified `fail` (type
  `never`): the block's code is not in the decided program. The block's
  decision is in the revision's HIR (`hir::static::sites`), not a position
  fact; no special LSP feature was added (the brief rules one out).
* **Layout through backward channels** (a loop's next iteration, a
  recursive call, an untyped parameter's inferred contract) is unchanged:
  STATIC-COMPILE.md documents where a later block can still affect an
  earlier one. The census found no such case for KNOWN-ERROR (the
  completion analysis is conservative through recursion).
* **No compile-time assertion.** The assertion is the test framework's and
  runs with the suite; a block that compiles when a test expected a
  diagnostic is a FAIL of the suite, never a compiler error -- by the
  design of `static compile:`.
