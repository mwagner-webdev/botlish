# METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md -- method-style calls decided by each call's own checks

Completion report of milestone 1 of the method-resolution correctness
refactor. `receiver.name(args)` is the one visible function `name` whose
ordinary call `name(receiver, args)` is valid (METHOD-SUGAR.md). Before this
milestone the compiler decided which function that is with two procedures --
an exact decision that read diagnostics located inside a call as that call's
failures, and a kind filter that handed over to it -- and the exact decision
could reject valid programs, accept ambiguous ones and decide calls by the
order of their candidates (EXACT-METHOD-DECISION-MISATTRIBUTION.md, and
section 6). Both are replaced by one decision whose verdicts are a call's
own checks, certified relative to the program as decided.

The base of every "before" below is `d88b5fef`. The implementation is
commit `0e89f694` and the commits after it on the branch
`ccr-16f6a693-1k90it`.

## Contents

1. Result
2. Architecture census
3. Alternatives considered
4. Implementation
5. Correctness argument
6. Regression evidence
7. Independent validation
8. Economics
9. Integration
10. Remaining limitations

## 1. Result

* **A candidate is judged by the call's own checks.** A diagnostic now
  records the call whose check against its callee reported it (`subject`,
  set by `hir::CheckingCall`, hir/hir.tcl): the admission of the call's
  arguments by the callee's parameters, its flags, imprints and variadic
  elements, the validity of the callee's semantic instance for it, its place
  arguments and ownership roles. A call's problems are those diagnostics
  (minus the obligations a valid call may still carry, as before) and a
  native's first-parameter kind mismatch. A check of a value by the construct
  that uses it -- an outer call's parameter (that is the outer call's check),
  an operator, a declared result, a binding -- is no call's. Where a diagnostic
  is located, what it says and what other candidates report are no input.
* **Relative to the decided program.** Candidate K of call C is applicable
  when C has no own problem in the build of the decided configuration with
  only C moved to K (the decided build itself when C stands at K), or a kind
  proof rules K out. The decision is the configuration in which every call's
  applicable set is exactly the candidate it stands at; a call with several
  is AMBIGUOUS-METHOD-CALL, with none NO-APPLICABLE-METHOD. The search that
  proposes a configuration (kind waves, trial rounds) decides nothing.
* **One procedure** (`hir/methods.tcl`): `hir::DecideMethodCallsExact`,
  `hir::MethodCallProblems`, `hir/methodfilter.tcl`, the filter's hand-over,
  its take-backs and `hir::methodFilterAudit` are gone. The filter's
  exclusion rule survives as the decision's *kind proofs*
  (METHOD-DECISION-FILTER.md), checked against a *reference rule* that judges
  every candidate by its own build (`hir::methodKindProofs 0`;
  `hir::methodReferenceAudit 1` decides by both and fails on any difference
  in decisions or HIR).
* **Guarantees established** (section 5 for the argument, 6-7 for the
  evidence): an outer call's failure is never an inner call's (or the
  reverse); candidate names, namespaces and enumeration order select
  nothing and invalidate nothing among accepted decisions; an unrelated
  call's ambiguity or failure changes no other call's decision; the kind
  proofs, build reuse, static seeds and the front-end cache change no
  decision. For programs whose calls do not depend on their own decisions
  through a cycle -- every program the tests, the oracle, the fuzzers and the
  golden corpus contain -- the decision is unique and so independent of the
  search; for a cycle it is a certified decision, not shown unique (section
  10).
* **Observed.** The reported chain compiles in every configuration, and so
  does its variant with an unrelated ambiguous call; three further defects
  of the old decision found by this milestone are fixed (sections 6.2-6.4);
  an independent declarative oracle agrees with the new decision on all
  1,000 generated programs (2,670 method calls, every program checked again
  with its modules renamed) and disagrees with the old one on 70 of the
  first 200; every golden suite decides, diagnoses and builds the same
  program as before; every mutant of the method harnesses, and of the
  static-compile, static-decisions and contexts harnesses this change
  touches, is killed.

## 2. Architecture census

### 2.1 The flow

1. **Parsing and lowering.** `receiver.name(args)` is a call of the
   projection `receiver.name` with a `method` marker
   (`hir::syntax::methodCallNode`, surface/lower.tcl); nothing is looked up.
2. **Candidates** (`hir::resolve::MethodCandidates`, hir/resolve.tcl): the
   lexical name and the member `name` of every directly imported namespace,
   minus `nomethod` functions, private members of other modules and
   functions of another arity. One candidate: the call *is* that ordinary
   call. Several: the call is recorded in the build's `methodCalls` table
   (key: file and syntax path; the candidates, sorted) and resolved to the
   candidate the build is told (`methodChoices`), else to the first
   (`MethodChoice`).
3. **Builds.** `hir::BuildFull` builds the program once with every call at
   its default candidate (`hir::BuildOnce`: resolution, signature inference,
   every check of `hir::CheckOnce`), then lets `hir::DecideMethodCalls`
   build it again under other choices until it has decided; the program it
   returns is the build of the decided choices. The trait monomorphization
   (`hir::traits::monomorphize`) and the static rounds (`hir/static.tcl`)
   build on top of that.
4. **Static rounds.** Each round of `static compile:` decisions is a whole
   build of the program with some blocks replaced, so a round decides its
   method calls again; `hir::static::MethodSeeds` passes the previous round's
   decisions on (STATIC-DECISION-ECONOMICS.md, "Method-call decisions"),
   invalidated by the dependency analysis's cones (`hir/staticdeps.tcl`).
5. **Ordinary call.** The decided call is the ordinary call node with a
   `ref` callee; every later phase (inference, lowering, Core IR, the Tcl
   compiler, native lowering) sees an ordinary call. Only the
   field/function-ambiguity check reads the `method` marker.

### 2.2 What judging a candidate needs

Applicability is the validity of the ordinary call, which the existing
checks compute for a qualified call: the argument admission of
`hir::range::VerifyCall` (declared, trusted-inferred and checked-inferred
parameter contracts, domains and refinements by range proofs, nominal and
structural struct types, trait constraints, native argument rules,
hashing admission, borrowing, pointer kinds, layout writes, structural
callable contracts, variadic elements), flags (`hir::flags::ResolveCall`),
imprinting (`hir::imprint::verify`), the C ABI scalars (`hir::cabi`), list
length refinements, layouts, syscalls, decimal conversions, the semantic
instance of an untyped callee for the call's argument types
(`hir::semantic`), places and receivers of mutable collections
(`hir::mutvec`), affine argument roles (`hir::affine`), the erased-callable
boundary (`hir::completions::SubsumeCall`) and trait-view use. The facts
they read are whole-program: inferred contracts come from a fixpoint over
every function (with demotion when a trusted contract is violated), the
semantic instances and the ownership analysis are program-wide, and a
receiver's type is the result of the calls inside it. That is why a
candidate is judged by building the program with the call at it: no
cheaper analysis computes the same facts, and a local re-check of one
function needs a locality theorem the checker makes false in general
(COMPILER-BOTTLENECKS.md, 3.10: demotion, the ownership verdict, the
erased-callable contract and the instance budget are whole-program facts a
candidate swap can change).

### 2.3 The old decision and why it was hard to reason about

* **`hir::DecideMethodCallsExact`** decided all calls together in passes.
  Trial build *t* put every undecided call at its *t*-th candidate at once;
  a candidate was valid if its call had no problem in its trial other than
  those every candidate shared; a call was decided once its receiver had
  the same type in every trial; the pass repeated with the decided calls
  fixed.
* **`hir::MethodCallProblems`** defined a call's problems as every
  diagnostic *located* in the call's subtree (minus obligation kinds), plus
  the native kind mismatch. A census of the diagnostics the golden corpus
  produces (this milestone's, filter on) shows why location cannot be
  ownership: argument admission is reported *at the argument* -- 327 TYPE
  diagnostics of `VerifyCall` at a reference argument, 165 at a call
  argument, 157 at a constant -- so an outer call's rejection of an inner
  call's result is located at the inner call's node, inside the inner
  call's subtree. Conversely an inner call's own failure is inside the outer
  call's subtree. Both directions were charged.
* **The kind filter** (`hir/methodfilter.tcl`) decided calls in waves from
  exclusions, took back decisions a later build contradicted, accepted with a
  certificate and otherwise handed the *whole program* to the exact
  decision, made from the start. `hir::methodFilterAudit` compared the two.
* **Correctness arguments needed:** that location is ownership (false);
  that the coordinated trials' pairing of candidates across calls cannot
  make one call's verdict depend on another call's trial candidate (false
  for arguments: section 6.2); that "shared by every candidate" removes
  exactly the diagnostics of the construct using the call's result (a
  heuristic: a diagnostic that only some candidates' uses produce survives
  it, 6.4); that a verdict in a trial
  configuration holds in the final one (not for whole-program facts); and
  that the filter and the exact decision agree (they did not: the filter
  was right where the exact decision was wrong). Five arguments, two of them
  false, one heuristic.
* **Consequences**, as the defect report lists: a valid chain rejected;
  namespace sorting changing whether a program compiles; the qualified
  spelling compiling where the method spelling failed; an unrelated
  ambiguous call making the filter hand over and the exact decision reject
  the valid chain; filter and exact decision disagreeing.

### 2.4 Genuine and incidental dependencies

* **Genuine.** A call's own checks read its arguments' types, so a call
  depends on the decisions of the method calls inside its arguments
  (receiver chains, calls in argument positions, calls on a function's
  result through its inferred result type). Through whole-program facts --
  an untyped function's inferred contract, demotion, semantic instances --
  a decision can reach calls elsewhere, including back to itself through a
  recursive function's inferred result.
* **Incidental** (created by the old representation or schedule): the
  pairing of candidate indices across calls in one trial; the subtree
  charge of a nested call's problems to its enclosing call and of a
  using construct's check to the call it checks; the whole-program hand-over from
  the filter; the "shared" subtraction, which made a candidate's verdict
  depend on the other candidates' builds.
* **Poison and unknown types.** A call whose receiver is poison (an earlier
  diagnostic proved it invalid in every context, hir/types.tcl) is judged
  by nothing and decides nothing; its cause is that diagnostic. An `any`
  receiver excludes nothing by kind and is judged by builds. A build that
  does not type (resolution failed) decides no call.
* **What the filter contributed.** Its exclusions are cheap proofs of a
  problem the candidate's own build would report; they are kept as kind
  proofs. Its waves (with the binding's defined type as a guess) are a good
  search heuristic; kept as search. Its certificate and hand-over are gone:
  certification is now the decision.
* **Shared static-decision infrastructure.** The seeds, the cones
  (`hir/staticdeps.tcl`'s METHODS mode and its method-trial channel), build
  records keyed by configuration and the audits of reuse are shared with the
  static scheduler and kept; only what a method-call build is read for
  changed.

## 3. Alternatives considered

* **A. Repair the attribution, keep the trials.** Give diagnostics an owner
  and keep `DecideMethodCallsExact`'s coordinated trials. This fixes the
  reported chain, but the trial schedule's own argument remains: in trial
  *t* every undecided call stands at its *t*-th candidate, so a call's
  verdict is relative to a configuration in which the other calls are at
  candidates that are not their decision. The receiver-stability rule covers
  the receiver only (section 6.2's defect is an argument), and no rule
  covers whole-program facts (demotion, instances, inferred contracts): a
  candidate valid in trial *t* need not be valid in the final program. The
  filter would still be a second procedure to keep equal to the first.
  Required arguments: ownership, schedule soundness (for every input of a
  call's checks, not only the receiver), trial-to-final transfer, filter
  equivalence, reuse.
* **B. Restructure around applicability, keep the ordinary checks.** Use the
  checks the ordinary call already runs, owned positively by the call
  (`subject`), and define applicability relative to one configuration -- the
  decided one. Any search may propose it; certification checks it by builds
  that differ from it in one call. Required arguments: ownership (local: the
  check that reports a diagnostic says whose check it is), certification
  (the definition of the rule), reuse (configuration-keyed records, already
  audited), and the kind proofs (each is the problem the build would report;
  audited against the reference rule).
* **C. Unresolved alternatives in HIR.** Keep the candidates in the call
  node and let inference and the checks handle a disjunctive callee. Every
  analysis would need a case for it (types, ranges, completions, instances,
  affine ownership, traits), and the whole-program fixpoints would need to
  carry facts per alternative -- a constraint solver over the program, which
  the milestone rules out unless Botlish needs one. It does not: one
  candidate per call per build, checked by the ordinary analyses, expresses
  the rule exactly.
* **D. Local re-checking.** Re-type only the function containing a call
  when its candidate changes. Unsound without a locality theorem
  (section 2.2), and not needed for correctness.
* **Choice: B.** It removes the class of defect rather than its instance --
  a verdict is never read from a diagnostic another construct owns, nor from
  a configuration other than the decided one -- with the fewest arguments,
  all local; it keeps the HIR and every downstream phase unchanged (the
  decided call is the ordinary call node); it keeps the economics of the
  filter (kind proofs) and of build reuse; and it lets the old fallback, its
  audit and the second procedure go. The ownership tag is semantic data with
  one invariant (set only inside the call's own check), not a diagnostic
  provenance system: nothing reads it but the decision.

## 4. Implementation

### 4.1 Ownership

* `hir::CheckingCall E SCRIPT` (hir/hir.tcl) runs SCRIPT with call E as the
  current subject and restores the previous one (nested checks nest);
  `hir::Diagnose` and `hir::DiagnoseAt` add `subject E` to every diagnostic
  reported meanwhile. HIR interchange carries it with the rest of the HIR
  dict; the HIR text (`hir::format`) prints no diagnostics, and no message
  shows it.
* The checks of a call against its callee run inside it: hir/range.tcl's
  `VerifyCall` (all argument checks, now `VerifyCallChecks`), the semantic
  instance diagnostic (hir/semantic.tcl), call imprints (hir/imprint.tcl),
  places and receivers (hir/mutvec.tcl), callable-contract preservation of
  call arguments (hir/callables.tcl), the erased-callable boundary of call
  arguments (hir/completions.tcl's `SubsumeCall`), C ABI kinds
  (hir/cabi.tcl), list-length validators (hir/listlength.tcl), layout
  operations (hir/layouts.tcl), syscall contracts (hir/syscall.tcl),
  decimal conversions (hir/decimal.tcl), trait-view use (hir/traits.tcl),
  flags and variadic collection (hir/resolve.tcl), affine argument roles
  (hir/affine.tcl, which now records the argument position of each finding,
  `ArgumentOf`), the context requirements of a top-level call's callee
  (hir/contexts.tcl's `Obligations`: MISSING-CONTEXT stays an obligation,
  AMBIGUOUS-CONTEXT-IMPLEMENTATION counts against the candidate, both as
  before).
* Not inside it, deliberately: declared results, operators, bindings,
  captures, an `if` condition -- every check of a value by the construct
  that uses it.

### 4.2 The decision (`hir/methods.tcl`)

* `Problems`/`CallProblems`/`OwnedBySubject`: a call's own problems in a
  build (one index of the diagnostics by subject per build).
* `NativeMismatch`, `Excluded`, `NominalMismatch`, `ParamKinds`,
  `DeclaredParam`, `Survivors`, `DefinedType`: the kind proofs and the waves'
  guess (METHOD-DECISION-FILTER.md).
* `Config`, `Record`, `Build`, `BuildRecord`: a build is a pure function of
  its configuration and is made once per decision; what the decision reads
  of it (each call's problems, receiver, poison, survivors, the trait
  operations) is recorded under the configuration
  (`hir::methodBuildAudit` rebuilds a reused one and compares).
* `Decide`: seeds and trait operations fixed; kind waves; trial rounds
  (`Proposal`, search only); certification (`Verdicts`) to a fixed point,
  bounded; the reasons of calls with no applicable candidate; `Final`;
  `Reject`. The decided calls are `methodDecided`, every call's candidate
  `methodChoices` (for the static seeds).
* `hir::DecideMethodCalls` (hir/hir.tcl) calls it, and under
  `hir::methodReferenceAudit` calls it again by the reference rule and
  compares (`hir::ReferenceAudit`).
* Diagnostics: AMBIGUOUS-METHOD-CALL and NO-APPLICABLE-METHOD keep their
  codes, wording and locations; NO-APPLICABLE-METHOD lists each candidate's
  first own problem from that candidate's build.

### 4.3 Removed

`hir::DecideMethodCallsExact`, `hir::MethodCallProblems`,
`hir::MethodObligationKinds`, `hir::MethodConfig`, `hir::MethodTrialRecord`,
`hir::MethodRecordFor`, `hir::MethodBuildAudit` and the rest of the exact
decision (hir/hir.tcl, about 500 lines); `hir/methodfilter.tcl` (522 lines);
`hir::methodFilter`, `hir::methodFilterAudit`, `BOTLISH_METHOD_FILTER_AUDIT`
and the counters `methodFiltered`, `methodFilterAbandoned`,
`methodFilterEvicted`. `hir/methods.tcl` is 935 lines, about a third of them
comments.

### 4.4 Relationship to qualified calls

A build resolves a method call to an ordinary call node whose callee is the
qualified `ref` of the chosen candidate; the decided program's call is
exactly the qualified call's (METHOD-SUGAR.md's equality of printed HIR,
`tests/method-sugar.test`). The decision only chooses which build is the
program. `mr-reported-chain-compiles`, the oracle (every accepted program
against its qualified spelling, run) and `mr-argument-nested-qualified`
check the equivalence.

## 5. Correctness argument

Notation: a configuration S gives every multi-candidate call one candidate;
`build(S)` is the program built with those choices; `own(C, S)` the
diagnostics of `build(S)` whose subject is C, minus obligation kinds, plus
C's native kind mismatch. K is applicable to C relative to S iff
`own(C, S[C:=K]) = {}`.

1. **Candidate applicability is semantic (3.1).** `own(C, S)` contains
   exactly what the checks of the ordinary call C against its callee report
   in `build(S)`: every check that judges an argument (or the instance, the
   flags, the imprint, a place) for C's callee runs inside
   `CheckingCall C`, and nothing else does. Messages, locations and
   reporting order are no input (the decision tests emptiness; the message
   is carried for NO-APPLICABLE-METHOD's text only). The one remaining
   classification by diagnostic kind is the obligation list (an error
   nobody handled, a missing context, ... -- obligations of a valid call,
   METHOD-SUGAR.md), unchanged.
   *Asymmetry.* A call check not yet run inside `CheckingCall` under-counts
   a candidate's problems: the candidate looks applicable, so the error
   shows as an ambiguity (or the check's own diagnostic in the program),
   never as another candidate's acceptance by elimination. Counting a
   using construct's check as the call's (the old rule) does the opposite:
   it eliminates a candidate by how its result is used -- selection by use,
   which no rule of the language allows (`mr-use-does-not-select`).
2. **Decided relative to the program as decided (3.3, 3.5).** The procedure
   returns S only after a certification round in which every open call's
   verdicts were computed from `build(S)` and `build(S[C:=K])` (or a kind
   proof of `build(S)`'s receiver), and no call moved. So every decided call
   C has applicable set `{S(C)}` relative to S; every rejected call has
   another set relative to S. No verdict from a trial or wave configuration
   survives into the decision.
3. **Nested calls (3.3).** An outer call's check of the inner call's result
   is the outer call's (`own(outer)`), never `own(inner)`; the inner call's
   own failure is never the outer call's (`mr-problems-are-owned`,
   `mr-inner-failure-is-not-the-outer-calls`). A real dependency -- the outer
   call's argument types are the inner call's result -- is respected because
   `build(S[outer:=K])` keeps the inner call at `S(inner)`, its decision.
4. **Uniqueness, hence independence of the search (3.2, 3.4).** Order calls
   by dataflow (a call after the calls in its arguments). If no call's
   arguments depend on its own decision (no cycle through whole-program
   facts), induction gives one configuration: the innermost calls' arguments
   do not depend on any decision, so their applicable sets are fixed; a call
   with one applicable candidate stands at it in every certified S; a call
   with several or none stands at its canonical stand-in (first applicable,
   else first candidate), also fixed; so the next calls' arguments are
   fixed, and so on. Hence every certified configuration is this one,
   whatever the waves, the trial rounds or the order of certification
   proposed -- and an unrelated call (one whose decision reaches none of a
   call's arguments) changes nothing that call's verdict reads. The canonical stand-in uses candidate
   order, but only for calls that are rejected anyway; it can change the
   diagnostics of the calls depending on a rejected call, never an accepted
   decision in a program that compiles.
5. **Ambiguity and failure.** A call is decided only when exactly one
   candidate is applicable; with two or more it is AMBIGUOUS-METHOD-CALL,
   with none NO-APPLICABLE-METHOD, both from verdicts relative to the
   decided configuration. There is no precedence: no step accepts the first
   of several applicable candidates (`first-applicable-decides`,
   `ambiguity-reported-as-none` and `standing-only-judged` are mutants,
   section 7.4).
6. **Kind proofs (3.5).** An exclusion states a problem the candidate's own
   build reports for the call (METHOD-DECISION-FILTER.md, "Why the kind
   proofs change no outcome"), in the acyclic case where the deviation
   leaves the call's receiver as `build(S)` has it. The reference rule
   (every candidate by its own build) makes the same decisions and the same
   HIR on every program the audits run (section 7).
7. **Build reuse, seeds, cache (3.5).** A build is a pure function of its
   configuration (unchanged premise, audited by `hir::methodBuildAudit`);
   the final program is the last build when that is S's, else built again,
   so its process state is S's. A static seed fixes a call's decision as an
   earlier round made it, invalidated whenever the call's cone changed
   (unchanged mechanism, its mutants re-run, 7.4). The front-end cache
   stores a whole HIR, decisions included; an entry equals the build.
8. **Bound.** Certification is bounded (4n + 8 rounds for n open calls); a
   call still moving at the bound depends on its own decision and is
   rejected as ambiguous between the candidates it moved between, never
   decided by the last round (`mr-oscillation-is-ambiguous`).

What this argument does not cover is in section 10: cycles (point 4's
premise), checks not yet tagged (point 1's asymmetry), and kind proofs in a
cycle (point 6's premise).

## 6. Regression evidence

All observed on the base `d88b5fef` (its kind filter on unless stated) and
on this milestone's tree, with the programs in `tests/method-resolution.test`
(the test names below) and `tclsh9.0` scripts that compile them with
`surface::readProgramFile -strict 0`.

### 6.1 The reported chain

`[[1, 2], [3]].at(1).length()` beside an application module's
`length(b: Bag)`, which sorts before `std::list::length` and rejects the List
the inner `at` returns.

| configuration | base | now |
|---|---|---|
| filter on / kind proofs on | compiles (2 builds) | compiles |
| filter off / reference rule | NO-APPLICABLE-METHOD for `at`, AMBIGUOUS-METHOD-CALL for `length` (5 builds) | compiles |
| outer candidate sorting before std (application module), after std (`std::zbox`), between (`std::boxlen`) | -- | compiles in all three (`mr-reported-chain-any-sort-order`) |
| with an unrelated ambiguous `x.length()` on an untyped parameter | NO-APPLICABLE-METHOD for `at`, two AMBIGUOUS-METHOD-CALL (the chain's `length` and the unrelated one), a TYPE: the chain rejected | the unrelated call AMBIGUOUS-METHOD-CALL (and its placeholder's TYPE, 10.2); the chain decided `std::list::at`, `std::list::length` (`mr-unrelated-ambiguous-call`) |
| qualified spelling | compiles | compiles, same value (`mr-reported-chain-compiles`) |

### 6.2 An inner call in an argument position decided an ambiguous outer call

`a.f(2.g())` with `alpha::f(x: int, y: int)`, `beta::f(x: int, y: int)`,
`alpha::g(x: int)`, `beta::g(x: str)`. Both `f`s accept the call: it is
ambiguous. Base: **accepted as `alpha::f`** (value 3), filter on and off --
trial 1 paired `beta::f` with `beta::g`, whose TYPE at `2` is inside `f`'s
subtree, so `beta::f` was "invalid". Now: AMBIGUOUS-METHOD-CALL for `f`,
`g` decided, whichever module holds the `g` that accepts an Int
(`mr-argument-nested-ambiguity`); the qualified outer call compiles and
decides `g` (`mr-argument-nested-qualified`).

### 6.3 An inner call's failure rejected a valid outer call

`(1).pick((7).size())` with `aa::size(s: List[int])`, `zz::size(s:
List[str])` (both return Int), `aa::pick(a: int, b: int)`, `zz::pick(a: str,
b: int)`. No `size` accepts an Int; `pick` is `aa::pick` by its receiver.
Base: NO-APPLICABLE-METHOD for `size` **and for `pick`**, whose message gave
the inner call's TYPE as `aa::pick`'s reason. Now: NO-APPLICABLE-METHOD for
`size` only, `pick` decided `aa::pick`
(`mr-inner-failure-is-not-the-outer-calls`).

### 6.4 How a call's result was used selected its candidate

`aa::size(s: List[int]) -> int` and `zz::size(s: List[int]) -> Float64`:
both accept `[1, 2]`. Base: as the argument of `take(n: int)`, **decided
`aa::size`** -- `take`'s rejection of a Float64, located at the inner call,
was `zz::size`'s problem and not shared by `aa::size`. Now: ambiguous as the
argument of `take`, as an operand of a Float64 `+` and as a declared Int
result (`mr-use-does-not-select`).

### 6.5 The wider matrix

`tests/method-resolution.test` (22 tests) also pins: three-deep chains
whose every link has an earlier-sorting application candidate
(`mr-chain-three-deep`, run on interp and compile and against the qualified
spelling); List, String, MutableArray, MutableVector, MutableMap and a
named-struct receiver with application candidates
(`mr-receivers-of-every-kind`); genuine ambiguity and no applicable method
with application and standard-library candidates; a candidate rejected by
its semantic instance (`mr-instance-failure-is-the-candidates`) and by
imprinting (`mr-imprint-decides`); renamed modules, an added inapplicable
candidate, an unrelated invalid expression, an unrelated syntax error under
syntax recovery, the kind proofs and build reuse off; method calls inside
`static compile:` blocks under both schedulers (`mr-static-blocks`); the
oscillation bound; and the ownership invariants themselves
(`mr-subject-is-the-checked-call`, `mr-consumer-check-has-no-subject`).
`tests/method-filter.test` (35 tests) pins the kind proofs, the waves, the
reference audit and its ability to fail.

## 7. Independent validation

### 7.1 A declarative oracle

`audit/method-resolution/tools/oracle.tcl` generates programs in a small
universe where applicability is decidable by rules the tool states itself:
seven nominal static types (`int`, `str`, `List[int]`, `List[str]`,
`List[List[int]]` and two structs); the natives `std::list::length`,
`std::list::at`, `std::str::length` applicable by receiver kind; module
functions with every parameter declared, applicable by exact parameter
types; templates that overlap across two application modules whose names
sort before and after `std` -- including pairs that differ only in their
result types, so how a result is used could tell them apart, and must
not. It predicts
every call (decided, ambiguous, no applicable method; nothing for a call
depending on a rejected one), compiles the program, and requires the
compiler's decisions and rejections to equal the prediction, an accepted
program to run to the value of its qualified spelling, and the same with the
modules renamed so they sort the other way. It does not call the decision
procedure.

| tree | programs | method calls | checks accepted / rejected | disagreeing programs |
|---|---:|---:|---:|---:|
| this milestone, seeds 1-200 | 200 | 564 (x2: as written, renamed) | 122 / 278 | 0 |
| this milestone, seeds 201-1000 | 800 | 2,106 (x2) | 584 / 1,016 | 0 |
| base `d88b5fef`, seeds 1-200 | 200 | (each program stops at its first disagreement) | -- | 70 |

The base's first disagreement per program: 23 valid calls rejected
(NO-APPLICABLE-METHOD), 21 genuinely ambiguous calls **decided**, 4 calls
with no applicable candidate **decided**, 22 rejections of the wrong kind.
Reproduce: `tclsh9.0 audit/method-resolution/tools/oracle.tcl 200 1` (about
80 s on a quiet machine; `800 201` for the rest); `-seed-only S -dump 1`
prints one program.

### 7.2 The fuzzer, its collisions restored

`audit/method-filter/tools/fuzz.tcl` again generates the named-struct
receivers with application modules that define `length`, `at` and `get`
over their structs beside the standard collections' -- the trigger it had
to leave out while the exact decision misattributed it -- with indices that
are themselves expressions. Each program is compiled under the reference
audit, under the audit of build reuse and plainly; outcomes must be equal.
Seeds 1-100 (`tclsh9.0 audit/method-filter/tools/fuzz.tcl 100 1`, about 24
minutes): 100 programs, 47 rejected (AMBIGUOUS-METHOD-CALL 29,
NO-APPLICABLE-METHOD 26, TYPE 32, IMPRINT 5, KNOWN-ERROR 6 among their
diagnostics), 120 single deviations, 541 builds plainly and 5,384 under the
two audits, **0 disagreements**. CI runs 20 seeds.

### 7.3 Reference rule against kind proofs

The reference rule judges every candidate by its own build, so it does not
depend on the kind proofs being right. `bench/method-filter.tcl -audit 1`
compiles a program under `hir::methodReferenceAudit` (both rules, decisions
and HIR compared). Every golden suite that decides method calls (the 25 of
`bench/method-filter.tcl -suites`) passes it. Builds, trial builds,
single deviations and final rebuilds with the kind proofs; builds and trial
builds by the reference rule; the decisions each compilation audited (one
per static round):

| suite | builds | trials | deviations | finals | reference builds / trials | audited |
|---|---:|---:|---:|---:|---:|---:|
| callable-contracts | 6 | 1 | 0 | 0 | 8 / 2 | 4 |
| collection-iteration | 5 | 1 | 0 | 0 | 37 / 32 | 2 |
| collections | 5 | 1 | 0 | 0 | 27 / 22 | 3 |
| declared-errors | 4 | 1 | 0 | 0 | 24 / 20 | 2 |
| destructuring | 5 | 0 | 0 | 0 | 9 / 3 | 4 |
| diagnostics | 6 | 1 | 0 | 1 | 6 / 1 | 2 |
| float64 | 4 | 1 | 0 | 0 | 4 / 1 | 2 |
| framework-semantics | 6 | 1 | 0 | 1 | 8 / 3 | 3 |
| imports | 8 | 3 | 1 | 1 | 22 / 17 | 3 |
| method-equivalence-imported | 5 | 1 | 0 | 1 | 5 / 1 | 2 |
| methods | 5 | 1 | 0 | 0 | 16 / 11 | 3 |
| mutable-map | 5 | 2 | 0 | 0 | 110 / 105 | 2 |
| mutable-set | 6 | 1 | 0 | 0 | 57 / 51 | 4 |
| mutable-vector | 7 | 2 | 0 | 0 | 69 / 63 | 3 |
| numeric-text | 8 | 4 | 2 | 1 | 19 / 15 | 2 |
| ownership | 5 | 1 | 0 | 0 | 11 / 6 | 2 |
| place-parameters | 3 | 1 | 0 | 0 | 115 / 112 | 2 |
| recursive-types | 2 | 1 | 0 | 0 | 17 / 15 | 1 |
| refinements | 7 | 2 | 0 | 1 | 9 / 4 | 2 |
| static-compile | 12 | 3 | 0 | 1 | 14 / 4 | 3 |
| stdlib-namespaces | 4 | 1 | 0 | 0 | 17 / 13 | 2 |
| structs-and-enums | 6 | 1 | 0 | 0 | 33 / 27 | 3 |
| traits | 6 | 0 | 0 | 0 | 6 / 0 | 4 |
| variadics | 3 | 0 | 0 | 0 | 15 / 11 | 2 |
| mutable-array | 7 | 2 | 0 | 0 | 145 / 139 | 4 |

Two things follow. The kind proofs agree with the reference rule on every
suite (the audit is identity of decisions and HIR, not of counts). And they
are what makes the rule affordable: the 25 suites take 140 builds with
them and 803 by the reference rule (place-parameters 3 against 115,
mutable-array 7 against 145).

### 7.4 Mutation testing

* `audit/method-resolution/tools/mutate.tcl` (15 mutants; detectors:
  `tests/method-resolution.test`, `tests/method-filter.test`, the oracle on
  40 seeds): ownership by location (the old rule), nested calls' problems
  charged to the enclosing call, no subject recorded, a subject leaking past
  its check, argument and instance checks unowned (misattribution); a
  call's other candidates never built, deviations accumulated across calls,
  the standing candidate's problems ignored, the first applicable candidate
  decided, ambiguity reported as none, certification reading the waves'
  guesses, the proposal taken as the decision, an oscillation decided, the
  final program any build (acceptance, ambiguity, order, interference). All
  15 killed. `nested-call-problems-charged` and `subject-leaks` survived the
  first run; `mr-inner-failure-is-not-the-outer-calls`,
  `mr-consumer-check-has-no-subject` and `mr-use-does-not-select` were
  written for them (and found the base defects 6.3 and 6.4).
* `audit/method-filter/tools/mutate.tcl` (22 mutants of the kind proofs,
  the waves, the seeds, trait operations and the reference audit): all
  killed. One mutant of the first run, a wave moving a call with several
  survivors, was equivalent -- the trial round's first move makes the same
  configuration -- and was replaced by waves that move nothing; one, trait
  operations not fixed at the start, was equivalent because the round loop
  fixed them again, and the duplicate was removed from `Decide` so the
  mutant breaks the one place that fixes them.
* `audit/static-decisions/tools/mutate.tcl`, the method mutants retargeted
  to hir/methods.tcl (a seed applied by name, a build read whatever its
  configuration, records keyed by kind of build, the final program any
  build, reuse only of the initial build, the method-trial channel
  ignored): all 6 killed. `method-memo-initial-only` survived the first run
  -- `se-method-memo`'s programs reused only the initial build -- and
  `se-method-memo` gained a program whose certification reads a trial
  round's build (`{1 2 1}` builds with reuse, without, under the audit;
  the mutant makes it `{2 2 2}`).
* `audit/contexts/tools/mutate.tcl`'s `method-candidate-dropped` (a missing
  context made evidence against a candidate): killed, once the harness
  copied `tests/ctoolchain.tcl` into its scratch tree. Its unmutated
  baseline had not run since `tests/helpers.tcl` began to source that file,
  so the harness ran no mutant (fixed in this milestone).
* `audit/static-compile/tools/mutate.tcl` (21 mutants; `hir::Diagnose`
  gained a field): all 21 killed.

## 8. Economics

All build counts are exact; times were measured on the sandbox's four cores
with other jobs running and are indicative only.

### 8.1 The golden corpus, before and after

Every golden suite (108) compiled by the base's front end and by this
milestone's, side by side under the same load (`-strict 0`, no cache), each
recording its builds, method trial builds, final rebuilds, decisions,
diagnostics, static-site outcomes and the formatted HIR:

| | base `d88b5fef` | this milestone |
|---|---:|---:|
| whole-program builds | 334 | 319 |
| method trial builds among them | 48 | 33 |
| final programs built again | 7 | 7 |
| front-end time, summed | 940 s | 902 s |
| suites with the same decisions, diagnostics, sites and HIR | | 108 of 108 |

(The formatted HIR of `traits.bot` differs only in the absolute path of the
standard library inside two messages -- the base's checkout is elsewhere --
and is identical once both roots are normalized.)

101 suites build exactly as before: 83 decide no method call (no trial
build and no decided call in either tree), and the other 18 decide their
calls with the same builds as before. The seven that changed:

| suite | builds | trial builds | time | why |
|---|---:|---:|---:|---|
| mutable-vector | 12 -> 7 | 6 -> 2 | 35 -> 21 s | the base filter handed over (`abandoned 1`): the exact decision started again |
| place-parameters | 8 -> 3 | 6 -> 1 | 17 -> 7 s | the same hand-over |
| imports | 11 -> 8 | 7 -> 3 | 23 -> 16 s | exact decision's trials per candidate index; now one single deviation |
| traits | 10 -> 6 | 3 -> 0 | 29 -> 18 s | trait operations are fixed before any build is judged |
| framework-semantics | 7 -> 6 | 2 -> 1 | 21 -> 17 s | one trial fewer |
| refinements | 7 -> 7 | 3 -> 2 | 22 -> 22 s | one trial fewer, one final rebuild more |
| numeric-text | 5 -> 8 | 1 -> 4 | 12 -> 21 s | see below |

`numeric-text.bot` is the cost of the rule. Its two `x.round()` calls on a
Float64 each have two survivors, `std::float64::round` and
`std::decimal_rounded::round` (whose call without an imprint is a TYPE
problem of the call's own). The base judged both calls' second candidates
in one coordinated build -- sound here only because the calls happen to be
independent, which nothing checked. The new decision judges each in a
single deviation of the decided program (2 builds), and the final program,
no longer the last build made, is built again (1). Measured by the base's
own `bench/method-filter.tcl`, its filter certified none of the decisions of
numeric-text, imports, framework-semantics, refinements and traits (the
exact decision made them) and handed over mutable-vector's and
place-parameters'; mutable-array's it certified (18 builds without the
filter, 7 with it; now 7).

### 8.2 The workloads the milestone names

* **Few or no competing methods**: 83 of the 108 suites decide no method
  call; no method-call build in either tree.
* **Many imports and competing names**: imports.bot (11 -> 8 builds),
  stdlib-namespaces.bot (4 -> 4), methods.bot (5 -> 5).
* **Nested chains**: mutable-array.bot (7 -> 7; 75 decided calls, receiver
  chains on MutableArray bindings), mutable-vector.bot (12 -> 7), the
  oracle's and the tests' chains (section 6).
* **Inference and static-decision dependencies**: static-compile.bot (12 ->
  12), the static-decisions fuzzer (section 9), `mr-static-blocks`.
* **Former filter fallback**: mutable-vector.bot and place-parameters.bot,
  above.

### 8.3 The reference rule, the oracle, the fuzzer

* The reference rule (every candidate by its own build) costs 803 builds on
  the 25 method-deciding suites against 140 with the kind proofs (7.3);
  mutable-array.bot alone 145 builds (1,595 s) against 7. It is a test and CI
  instrument, never the default.
* The oracle: 200 programs in about 80 s on a quiet machine.
* The fuzzer: 100 programs in 24 minutes (each compiled three times, two of
  them under audits that rebuild).

## 9. Integration

* **Static decisions.** The seeds (`hir::static::MethodSeeds`), cones and
  the method-trial channel are unchanged; seeded calls are fixed and not
  certified again. `tests/static-economics.test` (`se-method-memo` counts
  the reference rule's builds, and now also reuses a build other than the
  first),
  `tests/static-compile.test`, the static-decisions mutants above and
  fuzzer (`audit/static-decisions/tools/fuzz.tcl -n 10` on seeds 5, 17 and
  41: 30 programs, 796 static sites, 0 failures). The batched-against-
  sequential comparison of the golden suites runs in CI only (AGENTS.md):
  pending (`static-decisions` run 40100447004 on the branch).
* **`subject` and the static-compile harnesses.** `hir::Diagnose` gained a
  field, so the static-compile fuzzer and mutants ran: 0 disagreements on
  seeds 1 and 2 (20 programs each) and on seed 3 under GC stress (10), and
  21 of 21 mutants killed.
* **Front-end cache, interchange, isolation.** No new registry or process
  state; the decision's switches are no front-end input. `subject` is part of
  the HIR's diagnostics and round-trips (`tests/hir-interchange.test`,
  `tests/hir-cache.test`).
* **Compiler service and language server.** They report the strict
  compilation's diagnostics; the decision runs inside the front end they
  call. `tests/compiler-service.test`, `tests/lsp.test`,
  `tests/syntax-recovery.test` and `tests/diagnostic-recovery.test` pass
  on interp and compile (below); `mr-unrelated-syntax-error` decides a chain beside a malformed
  statement under `-recover-syntax 1` as in the clean program.
* **Backends.** Downstream of the decision nothing changed: the decided call
  is an ordinary call node. `tclsh9.0 tests/local.tcl -jobs 2` over the 17
  test files this change touches (method-resolution, method-filter,
  method-sugar, method-eligible, static-economics, static-compile,
  compiler-service, lsp, hir-interchange, hir-cache, syntax-recovery,
  diagnostic-recovery, main-cli, imports, contexts, compilation-isolation,
  golden): 812 tests passed on interp and 812 on compile, 0 failed; the 20
  golden suites holding their ports passed on all four backends (678 tests
  on interp, compile and cranelift, 670 on cranelift-generic). `main.tcl`
  runs the reported chain on interp, compile and cranelift, and `-check` on
  6.1's variant reports the unrelated ambiguity (and its placeholder's TYPE)
  and nothing on the chain. `tests/affine.test` and
  `tools/compilerpedia.tcl check` (844 topics, 627 examples, 0 problems)
  pass -- the latter only after it found a call of the removed
  `hir::MethodObligationKinds` in `hir/recovery.tcl` (a strict compilation
  reporting AFFINE-ERASURE-UNSUPPORTED failed with an internal error), which
  the narrowed run had not exercised. CI on the branch: pending (`tests` dispatched at `f750a6ac`).
* **Tests and census.** New `tests/method-resolution.test`;
  `tests/method-filter.test` rewritten; census rows in
  `audit/golden/migration/census/method-resolution.tsv` and
  `method-filter.tsv` (KEEP-INTERNAL), the manifest regenerated.
* **CI.** The `method-filter` job of `.github/workflows/tests.yml` runs both
  test files, the oracle on 500 seeds, the fuzzer on 20 and every golden
  suite that decides method calls under the reference audit.
* **Documents.** METHOD-DECISION-FILTER.md rewritten (the kind proofs);
  METHOD-SUGAR.md ("Valid is checked"), STATIC-DECISION-ECONOMICS.md,
  EXACT-METHOD-DECISION-MISATTRIBUTION.md (fixed), COMPILER-BOTTLENECKS.md,
  DIAGNOSTIC-RECOVERY.md, FLOAT64-MILESTONE-1.md, INDEX.md and AGENTS.md
  updated.

## 10. Remaining limitations

### 10.1 Semantic

* **Cycles.** Section 5's uniqueness needs every call's arguments to be
  independent of its own decision. Through whole-program facts -- a
  recursive function's inferred result, a demotion a candidate causes -- a
  call can depend on itself. The procedure then returns a certified
  configuration (every decided call has exactly one applicable candidate
  relative to it) or rejects the oscillating calls as ambiguous, but a
  second certified configuration may exist, and which one is found depends
  on the stand-ins. No such program is known; none was generated. The
  language design does not say what a self-dependent method call means:
  this is an open design question, not a rule the implementation settles.
* **Kind proofs in a cycle.** An exclusion assumes the deviation leaves the
  call's receiver as the decided build has it. The reference audit checks
  this on every program it runs; it is not proven for cycles.
* **Checks not yet owned.** A decimal constant's check
  (`hir::decimal::VerifyConstant`), USE-AFTER-MOVE between a call's own
  arguments and MUTABLE-PLACE-CAPTURE are reported without a subject. By
  section 5.1's asymmetry a candidate that only those checks reject is
  taken as applicable -- the call becomes ambiguous or keeps the check's own
  diagnostic -- never another candidate's acceptance by elimination.
* **Trait programs.** The trait monomorphization rebuilds the program and
  keeps the decisions as `methodChoices`, not `methodDecided` (as before).
* **Context obligations, an inherited inconsistency.** A missing context is
  an obligation of a valid call (CONTEXTS.md, "Method syntax": it never
  makes a candidate inapplicable), but two installed contexts implementing a
  required context trait (AMBIGUOUS-CONTEXT-IMPLEMENTATION) count against
  the candidate, as the location rule counted them. The same reasoning --
  the environment, not the call's arguments -- suggests it is an obligation
  too. The milestone keeps the established behavior and leaves the
  decision to the language design.

### 10.2 Diagnostics (milestone 2)

* A rejected call stands at a placeholder candidate, whose own diagnostics
  and consequences are reported with the rejection: NO-APPLICABLE-METHOD
  comes with the placeholder's TYPE (6.3: as in the base), an ambiguous call
  with what its placeholder makes of its use (6.1's unrelated call: a
  TYPE, because the placeholder `bag::length` infers the untyped parameter
  as a Bag; 6.4's operand: a TYPE of the `+`). The decision is right; the
  report is noisy.
* NO-APPLICABLE-METHOD lists one problem per candidate, from that
  candidate's build; a candidate a kind proof rules out is built for the
  message only.
* `subject` is not shown, related locations do not point at the candidate's
  declaration, and the order of a program's rejections is the decision's,
  not the source's.

### 10.3 Economics

* The decision costs a single deviation per candidate the kind proofs
  leave, where a coordinated trial could test one candidate of every call
  at once; programs with many independent calls of several survivors pay
  more builds (numeric-text.bot, 5 -> 8). Fewer would need an argument that
  two calls cannot affect each other's checks -- the locality theorem
  section 2.2 says the checker does not give -- or a cheaper re-check of a
  single deviation; neither is in this milestone.
* When the last build made is a deviation, the final program is built
  again (its process state must be the final configuration's: the reuse
  of an older build stays unaudited, as before).
* The reference rule takes from as many builds as the kind proofs (float64,
  traits, diagnostics) to 38 times as many (place-parameters, 115 against
  3; mutable-array 145 against 7); it is a test and CI instrument only.
  CI's `method-filter` job runs every method-deciding suite under the
  reference audit (both rules each time), so it lasts at least as long as
  the reference rule on mutable-array.bot (1,595 s here, under load) plus
  the rest.
