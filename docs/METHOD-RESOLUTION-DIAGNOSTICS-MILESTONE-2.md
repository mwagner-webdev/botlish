# METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md -- method failures reported without changing method decisions

Completion report of milestone 2 of the method-resolution correctness
refactor. METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md made a method-style
call's decision a property of the program as decided; SFIAE-MILESTONE-1.md
made the boundary between a candidate's applicability and its obligations
explicit. Both left the same artifact in what a rejected program reports: a
call the decision rejects keeps standing at a *placeholder* candidate -- the
decision needs one, so the program keeps typing -- and the placeholder's
checks, obligations, errors, result type and parameter contracts were
reported as if the program had selected it. This milestone separates what
the compiler temporarily assumed from what it reports, without touching
what it decides.

The base of every "before" below is `b29787c` (main when the milestone
started). The change is on the branch `claude/nice-newton-vfi92x`.

## Contents

1. Result
2. Starting census
3. Architecture decision
4. Implementation
5. Placeholder recovery
6. Candidate explanations
7. SFIAE integration
8. Semantic invariance
9. Diagnostic validation
10. Economics and integration
11. Remaining limitations

## 1. Result

* **The reported program is not the placeholder build.** The decision is
  unchanged: it reads the check records of its own builds, as before. Once
  it has decided, the program it returns -- the one every consumer reads
  (a strict compilation's error, the compiler service, the language
  server, `main.tcl -check`, a static compile round's attribution) -- is
  the decided configuration with every rejected call resolved to **no
  candidate** (`hir::resolve::RejectedMethodChoice`): its written callee is
  kept and marked `methodRejected`, and `hir::types::Project` makes it
  poison (DIAGNOSTIC-RECOVERY.md's recovery state for a value no analysis
  can establish). So nothing of the placeholder reaches the program: not
  its own checks (the TYPE that NO-APPLICABLE-METHOD already gives as its
  reason), not its obligations (MISSING-CONTEXT,
  AMBIGUOUS-CONTEXT-IMPLEMENTATION, UNHANDLED-ERROR of its declared
  errors), not its result type (an operator's, an argument's, a declared
  result's TYPE), not its parameter contracts (a TYPE at an untyped
  function's caller), not its ownership roles (a USE-AFTER-MOVE "passed to
  a::f").
* **Rejections are reported only when they hold.** A rejection whose
  verdict read an operand the reported program does not establish -- the
  result of another rejected call, an argument an earlier check rejected
  -- is recorded but not reported (`hir::methods::Rejection`'s `why`): an
  outer call that fails only on its inner call's placeholder result is no
  error of the program. One that holds whatever that operand is (every
  candidate rejects the receiver) is reported.
* **Explanations.** NO-APPLICABLE-METHOD names, for each candidate, the
  operand its own first problem rejects (`rejects the receiver`, `rejects
  argument N`, `rejects the call`), and both rejections carry **notes**
  locating the candidates' declarations: a small general field of a HIR
  diagnostic (`notes`: an origin and a text each), carried by
  `hir::recovery::entries`, the compiler service, the language server's
  related information and `main.tcl`'s `note:` lines -- never part of a
  diagnostic's identity, so never a static block's `related`.
  AMBIGUOUS-METHOD-CALL says no precedence exists by namespace, result
  type, the result's use or met context requirements, and keeps the
  suggestion to call one explicitly.
* **Order.** A program's rejections come first, as before, now in source
  order (the units' order, then the method name's offset) -- before, each
  was prepended in turn, so the last call the decision recorded came first.
* **Decisions unchanged** (section 8): over every golden suite and
  workload suite, compiled by the base's front end and by this one, the
  decided calls, every call's candidate, every static site's outcome and
  every accepted program's HIR are identical; the method-call oracle (with
  and without contexts), the reference audit and the fuzzers agree.
  `mr-diag-decision-unchanged` checks the separation directly: with the
  reporting replaced by nothing and the final program left at the
  placeholders, the same programs decide alike.
* **One semantic correction**, in a corner the corpus does not reach
  (section 8.3): a static compile round now reads the reported program, so
  a block is never rejected by a placeholder's consequence. Before, a
  block calling `g([1])` beside `fn g(x): x.length()` -- ambiguous outside
  the block -- was rejected with the TYPE the placeholder `bag::length`'s
  parameter contract produced.
* **Found, not fixed** (section 11): a kind proof decides a call whose
  receiver's type is inferred from that call's own candidate (an uncalled
  `fn g(x): x.length()` is decided `bag::length` and accepted; the
  reference rule rejects it as ambiguous). It is the "kind proofs in a
  cycle" limitation of milestone 1, section 10.1, now with a reproducer;
  it is out of this milestone's scope.

## 2. Starting census

### 2.1 Where a method failure's diagnostics come from

1. **The checks of each build.** `hir::CheckOnce` runs every check; the
   checks of a call against its callee run inside `hir::CheckingCall`, so
   their diagnostics carry `subject`, the call. A build's `diagnostics` is
   one list: what the checks found, in their order.
2. **The decision reads them as evidence.** `hir::methods::Record` reads,
   per build, each method call's own problems (`OwnedBySubject`: the
   diagnostics whose subject is the call, minus `ObligationKinds`, plus a
   native's kind mismatch) -- whether they are empty decides applicability;
   their text is kept for NO-APPLICABLE-METHOD's message.
3. **Placeholder.** A call with several applicable candidates, or none,
   keeps the canonical stand-in certification moved it to (its first
   applicable candidate, else its first). The final program was the build
   of that configuration: the rejected call there is the ordinary call of
   that candidate.
4. **`Reject`** prepended one diagnostic per rejected call to the final
   build's list, in key order -- each in turn, so in reverse.
5. **Reporting.** `hir::recovery::reported` (taint, owned positions,
   syntax holes) chooses what a strict compilation raises
   (`hir::BuildSyntax`, `surface::lower::Finish`), what the compiler
   service reports (`service::Analyze`) and so what the language server
   and `main.tcl -check` show; `hir/static.tcl`'s `Attribute` reads the raw
   list of each round to judge the sites. `ObligationKinds` is read by the
   decision and by recovery's `OwnedPositions`.

So the same records were the decision's input and, through the final build,
the program's diagnostics -- and the final build contained every
consequence of the placeholders.

### 2.2 What a rejected program reported

`audit/method-resolution/tools/census.tcl` (new) writes 28 small
applications, runs `main.tcl -check` on each and prints the diagnostics it
reports, in order (`-before DIR` the same with another checkout first;
`-full 1` the whole report). Before and after this milestone (locations in
`main.bot`):

| case | before (b29787c) | after |
|---|---|---|
| sfiae-ambiguous-providers | AMBIGUOUS-METHOD-CALL 8:3, AMBIGUOUS-CONTEXT-IMPLEMENTATION 8:1 | AMBIGUOUS-METHOD-CALL 8:3 |
| sfiae-missing-context | AMBIGUOUS-METHOD-CALL 6:3, MISSING-CONTEXT 6:1 | AMBIGUOUS-METHOD-CALL 6:3 |
| sfiae-in-a-body | AMBIGUOUS-METHOD-CALL 7:7, MISSING-CONTEXT 9:1 | AMBIGUOUS-METHOD-CALL 7:7 |
| sfiae-unique-missing | MISSING-CONTEXT 6:1 | MISSING-CONTEXT 6:1 |
| sfiae-unique-ambiguous | AMBIGUOUS-CONTEXT-IMPLEMENTATION 8:1 | AMBIGUOUS-CONTEXT-IMPLEMENTATION 8:1 |
| none-alone | NO-APPLICABLE-METHOD 4:5, TYPE 4:2 | NO-APPLICABLE-METHOD 4:5 |
| none-inner | NO-APPLICABLE-METHOD 4:14, TYPE 4:11 | NO-APPLICABLE-METHOD 4:14 |
| none-operator | NO-APPLICABLE-METHOD 5:9, TYPE 5:6 | NO-APPLICABLE-METHOD 5:9 |
| none-placeholder-errors | NO-APPLICABLE-METHOD 5:9, TYPE 4:9, UNHANDLED-ERROR 7:1, UNHANDLED-ERROR 5:6 | NO-APPLICABLE-METHOD 5:9 |
| none-poisoned-arg | NO-APPLICABLE-METHOD 5:11, TYPE 5:6, NOT-A-STRUCT 5:20 | NO-APPLICABLE-METHOD 5:11, NOT-A-STRUCT 5:20 |
| none-receiver-dependent-arg | NO-APPLICABLE-METHOD 5:20, NO-APPLICABLE-METHOD 5:11, TYPE 5:6, TYPE 5:17 | NO-APPLICABLE-METHOD 5:11, NO-APPLICABLE-METHOD 5:20 |
| none-independent-error | NO-APPLICABLE-METHOD 8:13, TYPE 8:10, TYPE 9:18 | NO-APPLICABLE-METHOD 8:13, TYPE 9:18 |
| nested-failing | NO-APPLICABLE-METHOD 4:16, TYPE 4:13 | NO-APPLICABLE-METHOD 4:16 |
| amb-argument | AMBIGUOUS-METHOD-CALL 7:13, TYPE 7:6 | AMBIGUOUS-METHOD-CALL 7:13 |
| amb-operator | AMBIGUOUS-METHOD-CALL 5:12, TYPE 5:5 | AMBIGUOUS-METHOD-CALL 5:12 |
| amb-result | AMBIGUOUS-METHOD-CALL 5:12, TYPE 4:5 | AMBIGUOUS-METHOD-CALL 5:12 |
| amb-binding | AMBIGUOUS-METHOD-CALL 5:16, TYPE 6:5 | AMBIGUOUS-METHOD-CALL 5:16 |
| amb-condition | AMBIGUOUS-METHOD-CALL 5:15, TYPE 5:8 | AMBIGUOUS-METHOD-CALL 5:15 |
| amb-receiver | AMBIGUOUS-METHOD-CALL 7:8, TYPE 7:1 | AMBIGUOUS-METHOD-CALL 7:8 |
| amb-list | AMBIGUOUS-METHOD-CALL 5:13, TYPE 4:5 | AMBIGUOUS-METHOD-CALL 5:13 |
| amb-several | AMBIGUOUS-METHOD-CALL 10:9, NO-APPLICABLE-METHOD 6:13, AMBIGUOUS-METHOD-CALL 5:13, TYPE 9:5, TYPE 6:10 | AMBIGUOUS-METHOD-CALL 5:13, NO-APPLICABLE-METHOD 6:13, AMBIGUOUS-METHOD-CALL 10:9 |
| amb-untyped-param | AMBIGUOUS-METHOD-CALL 6:7, TYPE 8:3 | AMBIGUOUS-METHOD-CALL 6:7 |
| amb-affine-argument | AMBIGUOUS-METHOD-CALL 12:14, AMBIGUOUS-METHOD-CALL 11:14, USE-AFTER-MOVE 12:9 | AMBIGUOUS-METHOD-CALL 11:14, AMBIGUOUS-METHOD-CALL 12:14 |
| amb-independent-arg | AMBIGUOUS-METHOD-CALL 8:7, TYPE 8:18 | AMBIGUOUS-METHOD-CALL 8:7, TYPE 8:18 |
| amb-poisoned-arg | AMBIGUOUS-METHOD-CALL 5:7, NOT-A-STRUCT 5:13 | NOT-A-STRUCT 5:13 |
| amb-unbound-arg | UNBOUND 5:9 | UNBOUND 5:9 |
| nested-dependent | AMBIGUOUS-METHOD-CALL 5:18, NO-APPLICABLE-METHOD 5:9, TYPE 5:14 | AMBIGUOUS-METHOD-CALL 5:18 |
| static-placeholder-cascade | ok | AMBIGUOUS-METHOD-CALL 7:7 |

Classified, every diagnostic of the base's reports beyond the rejections
and the genuine errors -- 28 of its 62 reported diagnostics over the 28
programs (the other 34 are kept; the 35th of this milestone's report is
static-placeholder-cascade's ambiguity, section 8.3):

* **Candidate evidence reported as an error** (10): the TYPE beside each
  NO-APPLICABLE-METHOD is the placeholder's own check of the receiver --
  word for word the first reason the rejection's message already gives
  (none-alone, none-inner, none-operator, nested-failing, none-poisoned-arg,
  none-independent-error, none-receiver-dependent-arg (two), amb-several,
  nested-dependent).
* **The placeholder's obligations** (6): MISSING-CONTEXT and
  AMBIGUOUS-CONTEXT-IMPLEMENTATION of alpha::f (sfiae-ambiguous-providers,
  sfiae-missing-context, and sfiae-in-a-body, where the requirement reached
  the caller `h()` in another statement); std::list::at's IndexNotFound,
  twice -- at the rejected call and at the top-level call of its function
  -- and the function result's TYPE of the placeholder's `any`
  (none-placeholder-errors).
* **Downstream of the placeholder's result type** (8): a TYPE where the
  Int the placeholder aa::size returns meets a Float64 -- an argument, an
  operator, a declared result, a binding used later, a condition, another
  call's receiver, a list element (amb-*), amb-several's declared result.
* **Backwards from the placeholder** (2): an untyped parameter's inferred
  Bag contract, violated at `g([1])` (amb-untyped-param); a USE-AFTER-MOVE
  "step passed to a::f" (amb-affine-argument).
* **Dependent rejections** (2): `pick`'s NO-APPLICABLE-METHOD in
  nested-dependent (both picks reject only the placeholder Int of their
  ambiguous argument), `f`'s AMBIGUOUS-METHOD-CALL in amb-poisoned-arg
  (its second argument is NOT-A-STRUCT, which every candidate's check
  skipped).

Kept as genuine: the rejections that hold (with `pick`'s receiver-only
NO-APPLICABLE-METHOD in none-receiver-dependent-arg), the selected
candidate's obligations (sfiae-unique-*), and the independent errors
(TYPE at `take_str(5)` and `take_str(9)`, NOT-A-STRUCT, UNBOUND).
Recovery's taint already hid `f`'s rejection in amb-unbound-arg.
static-placeholder-cascade, accepted before, is section 8.3's corner.
The order of amb-several's three rejections was the reverse of the source.

## 3. Architecture decision

Three ways to separate the evidence from the report were compared.

* **A. Keep the check records as the decision's input; make the report a
  separate projection.** The decision reads its builds' records exactly as
  before. The report is built afterwards, from the decided configuration,
  and cannot reach back: everything it does happens after the last build
  the decision reads.
* **B. Separate semantic failure facts from diagnostics.** Each check would
  record a typed failure fact for its call (`callProblems`) and a
  diagnostic built from it; the decision would read the facts. It makes
  the separation structural inside each check, but every check that runs
  inside `hir::CheckingCall` (about twenty, section 4.1 of milestone 1)
  would have to emit both, and the risk the milestone names -- a change to
  a diagnostic changing applicability -- is a risk of *editing how
  diagnostics are made inside checks* (a check that stops reporting a
  diagnostic changes both under B as under A), not of presentation. B adds
  a second representation of every call-owned failure for no case A cannot
  cover.
* **C. Filter the final build's diagnostics after the fact.** Remove the
  placeholder's own diagnostics (`subject`), and those "caused by" its
  result type. The first half is easy; the second needs a dependency
  analysis from the placeholder's result -- through operators, bindings,
  conditions, declared results, list literals -- and its backward channels
  -- an untyped parameter's inferred contract, propagated errors and
  context requirements, ownership roles. That is poison propagation and a
  copy of several whole-program analyses, done a second time.

**Chosen: A, with the report as a build of its own.** The reported program
is a configuration the decision never builds: the decided calls at their
decisions, the rejected calls at no candidate. Everything the placeholder
contributed is then absent by construction, through the existing recovery
representation of a method call no function was established for (the
method-call projection a missing import becomes, DIAGNOSTIC-RECOVERY.md),
which every analysis already handles: inference makes it poison, nothing
gets a contract, an error, a context requirement or an ownership role from
it, and its receiver and arguments are checked as the expressions they
are. Why it is preferable:

* **Semantic independence.** The decision's inputs are the records of the
  builds it makes; the reported program is built after all of them, from
  their outcome (section 4.2). No reporting rule -- a message, an order, a
  suppression, a note, recovery's taint -- is read by the decision; the
  mutants that would make it so are killed (section 9.3).
* **No second analysis.** No new dependency analysis, no new type, no
  analysis case per check: three small cases (`Project`, the projection
  check, a context-trait receiver) say what the marker means.
* **Dependent and independent separate themselves.** Poison is "invalid,
  but no divergence": independent errors in the receiver, the arguments
  and the code after the call are checked as before, and a consumer of the
  value is not.
* **Cost.** One build per compilation that rejects a call -- and none when
  the decision's last build was not the decided configuration anyway (the
  final rebuild it replaces). A valid program builds exactly as before.

What remains a classification by kind is `ObligationKinds` (SFIAE): this
milestone does not need a finer one (section 7).

## 4. Implementation

### 4.1 Stages and responsibilities

| stage | file | responsibility |
|---|---|---|
| decision | `hir/methods.tcl` `Decide`, `Verdicts`, `Proposal`, `Record` | unchanged: verdicts from the builds' check records; a problem record also keeps its location (`{kind message expr origin}`, for the explanation only) |
| reported form | `hir/methods.tcl` `Final` | with rejected calls, build the decided choices with each rejected call at `RejectedMethodChoice` (counted `methodReports`); without, as before |
| resolution | `hir/resolve.tcl` `MethodChoice`, the `call` case | a call told `#rejected` resolves to no candidate: its written callee (the projection `receiver.name`) marked `methodRejected`, recorded in `methodCalls` as ever |
| typing | `hir/types.tcl` `Project` | a `methodRejected` projection is poison in semantic inference (`ProjectionFailed`: `any` in unreachable code and in the unpoisoned recheck of a lenient run, `never` in region inference) |
| checks | `hir/structs.tcl` `ProjectionProblem`; `hir/contexts.tcl` `ContextTraitReceiver` | no field diagnostic for it; its receiver is a method-call receiver |
| report | `hir/methods.tcl` `Report`, `Rejection`, `Diagnostic`, `SourceOrder`, `Operands`, `CandidateOrigin` | decide what of each rejection is reported and how: the record (`methodRejected` side table, every rejected call), the diagnostic with its notes, the order |
| dependency analysis | `hir/staticdeps.tcl` | a rejected call's operands are its projection's receiver and its arguments (`hir::methods::Operands`) |
| presentation | `hir/recovery.tcl` `entries`; `core/errors.tcl`; `service/service.tcl` `Record`; `lsp/server.tcl` `Diagnostic`; `main.tcl` `printNotes` | carry a diagnostic's `notes`: entries' `notes` (located text and span), the service's `notes` (a range, `message`, `text`), the protocol's `relatedInformation` (with each note's own message), `note:` lines |

### 4.2 Why the decision cannot see the report

`Decide` computes every verdict, the reasons of NO-APPLICABLE-METHOD (each
candidate's problems from its own build) and the decided set before
`Final` runs; `Final` makes the one build the decision never reads, and
`Report` only adds to that program. `methodChoices` and `methodDecided` are
written from the decision's own variables (`choices`, `decided`), not read
from the reported program; `methodChoices` never names `#rejected`
(`mr-diag-decision-unchanged`). A static round reads the reported program
(its attribution and dependency analysis run on what `BuildFull` returns),
but a round's method decisions are made inside its `BuildFull` from its own
builds as before; the seeds the next round takes are `methodDecided`.

## 5. Placeholder recovery

### 5.1 Ambiguous calls

The rejected call is the program's one diagnostic there. In the SFIAE
reproduction (`7.f()`, alpha::f requiring env::Env with two providers
installed, beta::f requiring nothing):

    before: error: main.bot:8:3: method-style call "f" is ambiguous: more than one visible function accepts the receiver (alpha::f, beta::f); there is no precedence between them: call the one you mean explicitly, e.g. alpha::f(receiver, ...) (CORE SEMANTIC AMBIGUOUS-METHOD-CALL)
            error: main.bot:8:1: env::Env is required by this call, and more than one installed context implements it: ... alpha::f directly requires env::Env (CORE SEMANTIC AMBIGUOUS-CONTEXT-IMPLEMENTATION)
    after:  error: main.bot:8:3: method-style call "f" is ambiguous: more than one visible function accepts the call (alpha::f, beta::f); there is no precedence between them (none by namespace, result type, how the result is used, or which one's context requirements are met): call the one you mean explicitly, e.g. alpha::f(receiver, ...) (CORE SEMANTIC AMBIGUOUS-METHOD-CALL)
            note: alpha.bot:3:1: alpha::f accepts the call
            note: beta.bot:1:1: beta::f accepts the call

The decision is the same (ambiguous; `mr-diag-obligations-of-the-placeholder`,
`mr-sfiae-*`). The same holds with no provider (MISSING-CONTEXT gone), for
the call in a function body whose top-level caller alpha::f's requirement
reached (`h()`), and for a placeholder's declared error (an untyped
receiver's `q.at(0)` beside std::mutable_array::at no longer reports
std::list::at's IndexNotFound).

### 5.2 No applicable candidate

`(7).size()`, aa::size taking a `List[int]`, zz::size a `List[str]`:

    before: error: main.bot:4:5: method-style call "size": none of the visible functions of that name accepts the receiver (aa::size: argument for parameter "s" cannot be proven to satisfy List[int] (argument type: int); zz::size: argument for parameter "s" cannot be proven to satisfy List[str] (argument type: int)) (CORE SEMANTIC NO-APPLICABLE-METHOD)
            error: main.bot:4:2: argument for parameter "s" cannot be proven to satisfy List[int] (argument type: int) (CORE SEMANTIC TYPE)
    after:  error: main.bot:4:5: method-style call "size": none of the visible functions of that name accepts the call (aa::size rejects the receiver: argument for parameter "s" cannot be proven to satisfy List[int] (argument type: int); zz::size rejects the receiver: argument for parameter "s" cannot be proven to satisfy List[str] (argument type: int)) (CORE SEMANTIC NO-APPLICABLE-METHOD)
            note: aa.bot:1:1: aa::size is declared here
            note: zz.bot:1:1: zz::size is declared here

The TYPE was aa::size's own check: the first reason of the message, again,
as if aa::size had been chosen.

### 5.3 Uses of a rejected call

`mr-diag-uses-of-a-rejected-call` pins one program with an ambiguous
`[1, 2].size()` (aa::size an Int, zz::size a Float64: the placeholder is
the Int one) used as a Float64 argument, an operand of a Float64 `+`, a
declared Float64 result, a bound value then used as one, the operand of a
comparison in a condition, the receiver of another (ordinary) method call
and a List[Float64] element: seven AMBIGUOUS-METHOD-CALL, nothing else. The
base reported a TYPE for each use the Int contradicts. Backwards:
`mr-diag-backward-channels` (no Bag contract for an untyped receiver, no
USE-AFTER-MOVE for a handle a rejected call does not move).

### 5.4 What stays

* **Independent errors.** An ill-typed argument inside an ambiguous call
  (`1.f(take_str(5))`'s TYPE at `5`), an independent error after a call
  with no applicable candidate, an argument an earlier check rejected
  (NOT-A-STRUCT): reported as before (`mr-diag-independent-errors-survive`,
  `mr-diag-dependent-rejections`).
* **Dependent rejections.** `Rejection` reports a rejection only when it
  holds whatever the operands the reported program does not establish are
  (`poisoned` operands): an ambiguity with a poisoned operand is not
  reported (with a real value there, a candidate might reject it); a call
  with no applicable candidate is reported when every candidate has a
  problem located in an established operand, and its explanation uses
  those problems. A call whose receiver is poison was already dismissed
  (DIAGNOSTIC-RECOVERY.md); its receiver can now also be a rejected call's
  result. Each record keeps `reported` and `why` (`receiver`,
  `trait-operation`, `operand`), and an unreported rejection is still not
  decided.
* **Recovery.** Taint (an unbound name in the unit) still hides a
  rejection whose unit depends on a resolution failure
  (`amb-unbound-arg`), as before.

### 5.5 A lenient run

A `-strict 0` HIR runs with its diagnostics (DIAGNOSTIC-RECOVERY.md). A
rejected call used to run its placeholder -- a function the program does
not denote; it now raises where it is reached (`field projection ".size":
expected a struct`, on interp and compile), and native lowering refuses
the projection (`NATIVE UNSUPPORTED struct-shape`), as for the missing-import
form. Only the test harness runs rejected programs.

## 6. Candidate explanations

* **Each candidate's reason is its own check's**, the first problem its own
  build recorded (unchanged source), now with the operand it is located in:
  `rejects the receiver`, `rejects argument N` (N counts the arguments in
  the parentheses), `rejects the call` (an instance or imprint problem at
  the call itself). A kind proof's candidate is built for its message, as
  before (`std::list::length rejects the receiver: the receiver is a int,
  but argument 1 of native std::list::length requires list`).

      method-style call "g": none of the visible functions of that name accepts the call (p::g rejects argument 1: argument for parameter "b" cannot be proven to satisfy str (argument type: int); q::g rejects the receiver: argument for parameter "a" cannot be proven to satisfy str (argument type: int))
      note: p.bot:1:1: p::g is declared here
      note: q.bot:2:1: q::g is declared here

* **Notes** locate each candidate declared in source (a module's function,
  a lexical function), for NO-APPLICABLE-METHOD every candidate, for
  AMBIGUOUS-METHOD-CALL the applicable ones; an intrinsic has no source
  and no note. The note's location is the declaration (the `fn` statement:
  the HIR records no name span for a binding). A note is no `related`
  location: STATIC-COMPILE.md's `related` is part of a reified
  CompilerError (`SourceLocation` is a line and column of the block's own
  file), and candidates are in other files; notes are presentation only
  (`mr-diag-static-and-cached`: a block's reified diagnostic has no related
  location and the strict compilation's message).
* **Location.** A rejection stays at the method name; a receiver rejected
  by parameter 1 is still located at the receiver when the call is an
  ordinary one (METHOD-SUGAR.md, "Source locations"), and no check's
  ownership moved.
* **Order.** Rejections first, in source order: by unit, as `hir::roots`
  orders them (a module before the file importing it, as the loader
  reports), then by the method name's offset. Other diagnostics keep the
  build's order (`mr-diag-source-order`). Within a file the decision's key
  order already followed the source except for a chain (whose outer call is
  resolved before its receiver), where both cannot be reported (the outer
  call's receiver is the inner call's rejected result); the old reversal
  came from prepending each rejection in turn.
* **Wording.** "accepts the receiver" became "accepts the call" (both
  rejections are about the whole call); AMBIGUOUS-METHOD-CALL adds what
  there is no precedence by. Compilerpedia's `error.ambiguous-method-call`,
  `error.no-applicable-method`, `rule.method-resolution` and `rule.sfiae`
  say what is reported and what is not, with a new rejected example of a
  candidate rejecting its argument.

## 7. SFIAE integration

* **A selected call keeps its obligations.** `mr-diag-obligations-of-the-placeholder`:
  alpha::f the one applicable candidate reports MISSING-CONTEXT without a
  provider and AMBIGUOUS-CONTEXT-IMPLEMENTATION with two, at top level and
  through a function body's caller; `mr-sfiae-unique-candidate` and
  `mr-sfiae-qualified-obligations` (method and qualified spellings report
  the same diagnostics) pass unchanged.
* **A rejected call has none.** With beta::f also applicable, the call is
  AMBIGUOUS-METHOD-CALL alone under every installation (none, two
  providers, and in a body); the base added the placeholder alpha::f's
  obligation each time.
* **No second applicability filter.** The reporter reads the decision's
  verdicts; it never asks which candidate's obligations can be met. The
  obligation list (`ObligationKinds`) is unchanged and still read by the
  decision and by recovery's `OwnedPositions` only; nothing in the report
  reads it. SFIAE-MILESTONE-1.md, section 9, noted that a future check
  reporting an obligation under an applicability kind would need a finer
  classification; nothing here adds one, and no presentation rule now
  reads the classification.
* The SFIAE mutants (`ambiguous-context-is-a-problem`,
  `missing-context-is-a-problem`) and the oracle with `-contexts 1` still
  hold (section 9).

## 8. Semantic invariance

### 8.1 The corpus, decided by both front ends

`audit/method-resolution/tools/invariance.tcl` (new) compiles each program
in a process of its own with a given checkout's front end (`-strict 0`, no
cache, warnings off, the program's platform target) and records what the
front end decided -- the decided calls (`methodDecided`), every call's
candidate (`methodChoices`), each static site's outcome and reified code,
whether the program is accepted and, if it is, the CRC-32 of its HIR text --
and what it reports; `-compare` lists every difference, a difference in the
decisions, choices, static outcomes or an accepted program's HIR as
*semantic*. It never calls the decision procedure: it compares what two
front ends recorded. (The HIR text is compared with two normalizations: a
rejected static block's reified message constant -- the rejection's text,
which this milestone changes -- and the standard library's directory,
which the base's checkout has elsewhere.)

| corpus | programs | semantic differences | reporting differences |
|---|---:|---:|---:|
| every golden suite (108) and the 2048 and Icy Tower suites | 110 | **0** | 0 (all accepted) |
| the census's 28 rejected applications (section 2.2) | 28 | 1: static-placeholder-cascade (8.3) | 24 |

Every accepted program's HIR is byte-identical (once normalized), so every
backend compiles the same program as before; every rejected one decides the
same calls at the same candidates. Reproduce: `tclsh9.0
audit/method-resolution/tools/invariance.tcl -root BASE -out before.txt`,
the same with `-root .` and `-out after.txt`, then `-compare before.txt
after.txt` (about 15 minutes each on a quiet four-core machine, 40 here
under load).

### 8.2 Independent checks of the decision

* **The separation itself** (`mr-diag-decision-unchanged`): four programs
  with rejected calls -- a cascade, a dependent rejection, an SFIAE program
  with a decided call beside an ambiguous one, the reported chain beside an
  unrelated ambiguous call -- compiled as they are and with `Report`
  replaced by nothing and `Final` building the placeholders' configuration:
  the same `methodDecided`, the same `methodChoices`, the same number of
  trial builds.
* **The reference audit**: every compilation of `tests/method-resolution.test`
  (42 tests) runs under `hir::methodReferenceAudit` (the kind proofs and the
  reference rule -- every candidate judged by its own build -- must decide
  alike and give the same HIR, reported form included).
* **The oracle** (`audit/method-resolution/tools/oracle.tcl`, independent
  of the decision procedure; its reader of the compiler's decisions now
  finds a rejected call's name origin on its written callee): seeds 1-200,
  200 programs, 1,128 calls, 122 accepted / 278 rejected, **0
  disagreements** -- the summary milestone 1 and SFIAE-MILESTONE-1.md
  recorded, call for call; with `-contexts 1`, 200 programs, 1,202 calls, 96
  / 304 (18 by an obligation), **0 disagreements**.
* **The fuzzer** (`audit/method-filter/tools/fuzz.tcl 20 1`: each program
  under the reference audit, the build-reuse audit and plainly): 20
  programs, 12 rejected, 25 single deviations, 127 builds plainly and 1,231
  under the audits, **0 disagreements** -- the same counts as
  SFIAE-MILESTONE-1.md's run (the trial builds are unchanged; the reported
  form replaces a final rebuild).
* **Qualified-call equivalence** is unchanged by construction (a decided
  call is the same ordinary call node; the accepted HIR is identical), and
  pinned by `mr-reported-chain-compiles`, `mr-chain-three-deep`,
  `mr-sfiae-qualified-obligations` and the oracle's runs of every accepted
  program against its qualified spelling.

### 8.3 The one semantic correction: static rounds never read a placeholder

A static compile round judges each site by its own diagnostics in the
round's build (STATIC-COMPILE.md); that build is what `hir::BuildFull`
returns, now the reported program. A site's outcome therefore changes
exactly when, in some round, its first diagnostic was an artifact of a
placeholder -- a rejected call outside it whose placeholder's consequences
reached it -- and no longer is. The census's case:

```
import std::list
import std::str
import bag                  # struct Bag, fn length(b: Bag) -> int
import std::compiler

fn g(x):
    x.length()              # three candidates accept an untyped receiver: ambiguous

fn k() -> int errors std::compiler::CompilerError:
    static compile:
        g([1])

r = k():
    on std::compiler::CompilerError:
        0
r
```

* **Before**: round 1 rejected the block with a TYPE -- `g([1])` violated
  the Bag contract the placeholder `bag::length` gave `x` -- and the program
  then compiled and ran to 0: with the block's body gone, the call in the
  now uncalled `g` was decided `bag::length` by a kind proof (section 11,
  "found, not fixed"). A placeholder decided a static outcome.
* **Now**: the block is accepted (its body has no diagnostic of its own:
  `g([1])` reads a value nothing established), and the program is rejected
  by the genuine ambiguity at 7:7 (`mr-diag-static-not-by-a-placeholder`).

Static outcomes otherwise did not change anywhere they were compared: no
golden suite's site (8.1), none of the static-decision fuzzer's or tests'
(section 9). The alternative -- rounds on the placeholder build, the
reported program built only at the end -- would keep a static block's
reified diagnostic different from what a strict compilation of its body
reports, and would keep static outcomes that observed a placeholder; it was
rejected for that reason, not for cost.

## 9. Diagnostic validation

### 9.1 The regression matrix

New tests in `tests/method-resolution.test`, section "Diagnostics of
rejected calls" (16), every compilation under the reference audit, and one
each in `tests/compiler-service.test` and `tests/lsp.test`:

| case | expected | test |
|---|---|---|
| one uniquely applicable method | no new diagnostics | the existing suite (`mr-reported-chain-compiles`, `mr-receivers-of-every-kind`, ...) |
| uniquely applicable, missing context | MISSING-CONTEXT preserved | `mr-diag-obligations-of-the-placeholder` |
| uniquely applicable, two context providers | AMBIGUOUS-CONTEXT-IMPLEMENTATION preserved | `mr-diag-obligations-of-the-placeholder` |
| two applicable, one with a missing context (top level and in a body) | AMBIGUOUS-METHOD-CALL alone | `mr-diag-obligations-of-the-placeholder` |
| two applicable, one with two providers | AMBIGUOUS-METHOD-CALL alone | `mr-diag-obligations-of-the-placeholder` |
| no applicable candidate (and a placeholder with declared errors) | one NO-APPLICABLE-METHOD with every reason | `mr-diag-no-applicable-alone` |
| failed method used by an operator, an argument, a declared result, a binding, a condition, a receiver, a list | the rejection only | `mr-diag-uses-of-a-rejected-call` |
| an untyped parameter as receiver; an affine argument | no contract, no move | `mr-diag-backward-channels` |
| an argument invalid independently of the selection | still reported | `mr-diag-independent-errors-survive` |
| nested failing calls; a call on a rejected call; an ambiguity over a rejected argument | no spurious failures; a receiver-only failure kept | `mr-diag-dependent-rejections` |
| several independent invalid calls, a module's among them | each reported, first, in source order | `mr-diag-source-order` |
| candidate names reordered | same verdicts, equivalent explanations | `mr-diag-renamed-candidates` |
| static or cached build | same verdict and diagnostics; the block's CompilerError is the strict diagnostic | `mr-diag-static-and-cached`, `mr-diag-static-not-by-a-placeholder` |
| syntax recovery | the same as the clean program | `mr-diag-syntax-recovery` |
| nominal, structural (instance), imprinted, native candidates | each candidate's own reason, nothing else | `mr-diag-kinds-of-candidates`, `mr-diag-candidate-explanations` |
| explanations | exact text, operands, notes | `mr-diag-candidate-explanations`, `mr-diag-ambiguity-explanation` |
| what recovery hides decides nothing | a tainted unit's call decided by its checks | `mr-diag-decision-reads-every-check` |
| reporting decides nothing | same decisions without the report | `mr-diag-decision-unchanged` |
| the service and the editor | one diagnostic, notes as ranges and related information, the value unknown | `cs-method-rejection-notes`, `lsp-lang-related-candidates` |

Existing tests whose expectations changed, each because it pinned a
placeholder's diagnostic or the old wording: `mr-genuine-ambiguity-and-no-applicable`
(the TYPE beside NO-APPLICABLE-METHOD), `mr-unrelated-ambiguous-call`
(reads the rejected call's name from its written callee), `mr-sfiae-competing-candidates`
and `mr-oscillation-is-ambiguous` ("accepts the call"),
`mf-problem-in-the-only-survivor` (the candidate's TYPE is now inside the
rejection, checked there), `imports-method-no-applicable` (no TYPE),
`imports-method-untyped-receiver-is-ambiguous` (no UNHANDLED-ERROR of
std::list::at), `imports-method-ambiguous-between-namespaces`,
`dr-method-ambiguity-unchanged`, `se-method-memo` (wording),
`se-property-subsume-positions` (reads `Report`'s source where it read
`Reject`'s), `dr-corpus-efficiency` (15 corpus cases). Their census rows
say what they pin now; the manifest is regenerated (`merge.tcl -check 1`
clean).

### 9.2 The diagnostic-efficiency corpus

`audit/diagnostic-recovery/corpus/method-rejections` (new): an ambiguous
call held to a Float64 result, a call no candidate accepts, an independent
TYPE. Base: 5 diagnostics in the first compilation, 3 primaries, 2
cascades (the placeholder's Int result held to Float64; aa::size's
rejection of the receiver); now: 3, 3, none. The other 14 cases are as
before (`results.txt` has both runs).

### 9.3 Mutation testing

`audit/method-resolution/tools/mutate.tcl`, 31 mutants (the 17 of the
previous milestones, two retargeted to the changed code, and 14 new):
**all 31 killed**. The new ones and their killers:

| mutant | what it reintroduces | killed by |
|---|---|---|
| placeholder-reported | the reported program is the placeholder build | `mr-diag-backward-channels`, `-dependent-rejections`, `-independent-errors-survive`, `-kinds-of-candidates`, ... |
| rejected-result-any | a rejected call's value is `any`, not poison | `mr-diag-backward-channels`, `-dependent-rejections`, `-no-applicable-alone`, ... |
| rejected-callee-a-field | the rejected callee is a field access (its projection diagnosed) | `mr-diag-ambiguity-explanation`, ... |
| independent-argument-suppressed | everything located in a rejected call dropped | `mr-diag-independent-errors-survive` |
| reason-of-another-candidate | every candidate explained by the first's problem | `mr-diag-candidate-explanations`, `-no-applicable-alone` |
| dependent-ambiguity-reported | an ambiguity over a poisoned operand reported | `mr-diag-dependent-rejections` |
| dependent-no-applicable-reported | a failure only inside a poisoned operand reported | `mr-diag-dependent-rejections` |
| poisoned-receiver-reported | a call on a rejected call's result judged by the placeholder | `mr-diag-dependent-rejections` |
| rejections-in-decision-order | the old prepend order | `mr-diag-backward-channels`, `-dependent-rejections`, `-source-order`, ... |
| every-diagnostic-in-source-order | the rejection no longer first (a block reifies another diagnostic) | `mr-diag-independent-errors-survive`, `-source-order`, `-syntax-recovery` |
| notes-dropped | no notes | `mr-diag-ambiguity-explanation`, `-candidate-explanations` |
| unreported-rejection-decided | an unreported rejection becomes its placeholder's decision | `mr-diag-decision-unchanged`, `-dependent-rejections` |
| reported-diagnostics-decide | a call's problems read from what recovery reports | `mr-diag-decision-reads-every-check` |
| reported-form-decides | the decision builds deviations with the rejected calls at no candidate | `mr-added-inapplicable-candidate`, `mr-chain-three-deep`, `mr-diag-decision-unchanged`, ... |

No mutant was equivalent. `reported-diagnostics-decide` needed
`mr-diag-decision-reads-every-check`, written for it: no earlier test had a
method call in a unit that recovery's taint hides.

### 9.4 The other harnesses

Every mutation harness and fuzzer that covers code this milestone changed
or reads, run on this branch:

| harness | result |
|---|---|
| `audit/static-decisions/tools/mutate.tcl -only` its eight method-call mutants (`stale-method-reuse`, `method-key-alias`, `same-choices-unchecked`, `method-memo-by-index`, `method-final-any-build`, `method-trial-ignored`, `method-memo-initial-only`, `never-reuse-methods`) | 8 killed |
| `audit/method-filter/tools/mutate.tcl` (the kind proofs) | 21 of 22 killed by the unit tests; `wave-limit-ignored` (the wave limit raised to 1,000) survives the tests and the fuzzer, identically on the base (10.5) |
| `audit/contexts/tools/mutate.tcl -only method-candidate-dropped` | killed |
| `audit/direct-modules/tools/mutate.tcl -only method-obligation-dropped` | killed (`dm-method-sugar-two-candidates`) |
| `audit/diagnostic-recovery/tools/mutate.tcl` | 25 of 25 killed |
| `audit/compiler-service/tools/mutate.tcl` | 21 of 21 killed |
| `audit/lsp/tools/mutate.tcl` | 30 of 30 killed |
| `audit/syntax-recovery/tools/mutate.tcl` | 37 of 37 killed |
| `audit/hir-interchange/tools/mutate.tcl` | @@HIRX@@ |
| `audit/static-decisions/tools/fuzz.tcl -n 10`, seeds 17, 41 and 5 | 240, 304 and 252 sites (116, 184 and 180 rejected), 0 failures |
| `audit/static-compile/tools/fuzz.tcl`, seeds 1 and 2 | 0 disagreements (110 transparent valid sites each; 66 and 68 exact diagnostics) |
| `audit/syntax-recovery/tools/fuzz.tcl`, seeds 1, 2 and 3 | seeds 2 and 3: 46 and 52 damaged programs, 0 failures; seed 1: two failures of one case, identical on the base (pre-existing: 10.5) |
| `audit/method-resolution/tools/oracle.tcl`, `audit/method-filter/tools/fuzz.tcl` | section 8.2 |

## 10. Economics and integration

### 10.1 Builds

A program without a rejected call builds exactly as before: `Final` and
`Report` do nothing new for it. A program with one makes the reported form
instead of rebuilding the placeholder configuration when the decision's
last build was a deviation (the common case: every one of the census's 28
programs), and one build more when the last build was the decided
configuration itself, which the base reused.

| corpus | builds before / after | method trials | deviations | final rebuilds before / after | reported forms | front-end time summed |
|---|---|---:|---:|---|---:|---|
| 110 golden and workload suites | 331 / 332 | 40 / 40 | 6 / 6 | 8 / 2 | 7 | 790 s / 793 s |
| 28 rejected census programs | 92 / 91 | 37 / 37 | 16 / 16 | 26 / 0 | 26 | 2.4 s / 2.5 s |

The one build more is `traits.bot`'s (6 to 7): a round's rejected call
whose decision was settled without a deviation. Six suites swap a final
rebuild for a reported form at the same count (diagnostics,
framework-semantics, imports, method-equivalence-imported, refinements,
static-compile). Times were measured with other jobs running and are
indicative only; the builds are exact. No candidate is rebuilt for an
explanation beyond what the decision already builds (NO-APPLICABLE-METHOD's
reasons for kind-proof candidates were built before, and still are).

### 10.2 Consumers

* **A strict compilation** raises the reported program's diagnostics
  (`core::raiseDiagnostics`, unchanged): the rejection first, its `notes`
  in its `-diagnostics` entry (`hir::recovery::entries`: each note's
  located text, summary and span). `main.tcl` prints them as `note:` lines
  under the diagnostic, for a failed run and for `-check`; its `help:`
  lines are looked up from the code and message as before.
* **The compiler service** (`service::diagnostics`) reports exactly the
  strict compilation's diagnostics -- the same entries in the same order --
  with `notes` as ranges, each with its `message` and located `text`; a
  hover on a binding of a rejected call's result answers that its value is
  not known, never the placeholder's type (`cs-method-rejection-notes`).
* **The language server** re-encodes the service's notes as
  `relatedInformation`, each with the note's own message, after the
  diagnostic's own related locations (`lsp-lang-related-candidates`).
* **Compilerpedia**: `error.ambiguous-method-call`,
  `error.no-applicable-method`, `rule.method-resolution` ("WHAT IS
  REPORTED") and `rule.sfiae` describe the reported program and the
  explanations; the new rejected example of `error.no-applicable-method`
  pins `rejects the receiver` and `rejects argument 1`. `tclsh9.0
  tools/compilerpedia.tcl check`: 849 topics, 636 examples, no problem.

### 10.3 Static compile, the cache and interchange

* **Static compile rounds** read the reported program (section 8.3): a
  round's attribution and its dependency analysis run on what
  `hir::BuildFull` returns; a rejected call's operands in the dependency
  analysis are its projection's receiver and its arguments
  (`hir::methods::Operands`). A block that reifies a rejection reifies the
  strict compilation's message, without notes (`mr-diag-static-and-cached`).
  `tests/static-economics.test` (87 tests) and `tests/static-compile.test`
  (83) pass; the static-decision fuzzer over seeds 17, 41 and 5 (10
  programs each, 240 sites a seed) and the static-compile fuzzer report no
  failure (section 9.4); the batched-against-sequential comparison of the
  golden suites is CI's (10.5).
* **The front-end cache and HIR interchange** hold the HIR dict, so the
  `methodRejected` side table, the projection's `methodRejected` field and
  a diagnostic's `notes` travel with it; nothing reads them from process
  state. A rejected program's lenient HIR encoded and decoded
  (`hir::interchange::encode`/`decode`) is identical, its reported
  diagnostics too; `dr-interchange-rejected` and `mr-diag-static-and-cached`
  read rejected programs back through interchange and the cache. The cache
  key is unchanged (no new input). `tests/hir-interchange.test` (11) and
  `tests/hir-cache.test` (17) pass.
* **Backends** compile accepted programs, whose HIR is identical (8.1); a
  lenient run of a rejected program raises at the rejected call (5.5).

@@LOCAL@@

## 11. Remaining limitations

* **Found, not fixed: a kind proof decides a self-dependent call.** In

  ```
  import std::list
  import std::str
  import bag          # struct Bag, fn length(b: Bag) -> int

  fn g(x):
      x.length()

  0
  ```

  `x.length()` is decided `bag::length` and the program is accepted. All
  three candidates accept an untyped receiver -- the reference rule
  (`BOTLISH_METHOD_KIND_PROOFS=0`) reports AMBIGUOUS-METHOD-CALL, and
  `BOTLISH_METHOD_REFERENCE_AUDIT=1` fails on the difference -- but in the
  build at `bag::length` the receiver's type is the Bag contract that very
  candidate gave the parameter, and the kind proof excludes the other two
  by it. It is METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md's "kind proofs
  in a cycle" (10.1) with a reproducer; with `g` called (`g([1])`) the
  contract is demoted and the call is ambiguous, as it should be. Out of
  this milestone's scope (it explicitly excludes kind-proof soundness in
  cycles); the fix belongs to the milestone on self-dependent decisions --
  a kind proof must not read a receiver type the call's own candidate
  inferred.
* **Dependent rejections are judged conservatively.** An ambiguity with an
  operand nobody established is never reported, even when the candidates'
  parameters there are the same (`1.f((5).q)` with two `f(x: int, y: int)`):
  only the operand's own diagnostic is. A call with no applicable candidate
  is reported only when every candidate has a problem outside the
  unestablished operands; a problem of the call itself (an instance, an
  imprint) then counts as reading every operand.
* **Notes point at declarations, not names.** A note's location is the
  candidate's whole declaration (its `fn` line), since the HIR records no
  name span for a binding; an intrinsic candidate has no note.
* **A lenient run of a rejected program** now raises at the rejected call
  on the Tcl backends and is refused by native lowering (5.5), where it ran
  the placeholder.
* **Unchanged:** self-dependent decisions and cycles, kind-proof soundness
  in cycles, checks not yet owned (milestone 1, 10.1); `ObligationKinds`
  stays a classification by kind (SFIAE-MILESTONE-1.md, 9); `notes` are not
  part of a static block's CompilerError (they name other files, which
  `SourceLocation` cannot).
