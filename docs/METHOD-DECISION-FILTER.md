# Kind proofs in the method-call decision

`receiver.name(args)` means the one visible function `name` whose ordinary
call `name(receiver, args)` is valid (METHOD-SUGAR.md). `hir/methods.tcl`
decides it (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md): a candidate is
judged by the call's own checks (the diagnostics whose `subject` is the
call), relative to the decided configuration itself -- in the decided build,
in a single deviation of it, or by a *kind proof*. This document is about the
kind proofs: a candidate the receiver's kind (or a named struct's declaration)
rules out is not applicable without a build of its own.

They began as the **kind filter** (`hir/methodfilter.tcl`), a second decision
procedure beside the exact one, which handed every call it could not settle
to the exact decision, made from the start. That arrangement is gone: the
filter's rule is now one of the decision's sources of evidence, inside the one
procedure, and there is no hand-over (History, below).

## The rule

Most method calls are settled by the kind of the receiver. `xs.length()` on a
List cannot be `std::str::length`, because the native's first parameter is a
String -- exactly the problem the candidate's own build would report. A
candidate is *excluded* for a call (`hir::methods::Excluded`) when the
receiver's type already makes the ordinary call invalid by kind alone, or by
a named struct's declaration:

* a qualified native (`std::list::at`) whose first parameter has another known
  kind than the receiver's -- `hir::methods::NativeMismatch`, which asks the
  one statement of the rule, `hir::types::NativeKindMismatch`: the call's own
  check reports it as a TYPE diagnostic (`hir::range::VerifyNativeKinds`,
  METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md; until then a native's kind
  mismatch was its run-time TYPE error, not diagnosed, and
  `hir::methods::CallProblems` added it to a call's own problems itself) and
  the kind proof excludes by it;
* a module function (`std::mutable_array::get`) one of whose first-parameter
  contracts -- declared, trusted-inferred or checked-inferred
  (hir/signatures.tcl) -- has another kind than the receiver's, when both are
  among the plain value kinds `int str bool unit UnicodeChar list struct enum
  mutvec mutarray` (and the floating kinds);
* a module function (`std::mutable_set::length`) whose *declared* first
  parameter is a named struct of another declaration than the receiver's
  named struct type (a `std::mutable_map::MutableMap[int, int]`) --
  `hir::methods::NominalMismatch`. Every struct has the kind `struct`, so the
  kind rule cannot tell two structs apart; their declarations can, because
  named structs are nominal: a struct argument is admitted by subtyping alone
  (`hir::range::ProvesValueAcceptedBy`), and a struct type is a subtype of a
  named one only when it is the same declaration (`hir::types::subtype`). Only
  the declaration is compared, never the type arguments (a declared
  `MutableMap[K, V]` carries imprint variables, and two applications of one
  struct are judged by their builds); only a declared parameter counts, never
  an inferred contract; and only a receiver that is itself a named struct:
  `any`, an imprint variable, a trait view or an anonymous struct excludes
  nothing by it.

A candidate that is not excluded is a *survivor*. Nothing excludes a lexical
candidate (a bare name: a function of the file, a parameter, a binding), and
nothing is excluded for a receiver that is `any`, `never` or a function, or by
a kind outside the list above (a pointer, say). A domain or a refinement has
the kind of its base: an Int receiver does not exclude a parameter of an
integer domain (a range proof admits a literal), a String receiver does.

## How the decision uses them

* **Certification.** In the decided build, every call's excluded candidates
  are not applicable; every survivor is judged by a build (the decided build
  for the candidate the call stands at, a single deviation for every other).
  A call with one survivor costs no build beyond the decided one; a call with
  none has no applicable candidate (NO-APPLICABLE-METHOD, whose message gives
  every candidate's reason from its own build, made for the message only).
  The kind proof reads the receiver the build really gives: never a guess.
* **Kind waves (search).** Before certification, a call whose receiver leaves
  one survivor stands at it; a receiver that is a plain reference to a binding
  is *guessed* to have the type the binding was defined with (a parameter's
  declared type, else the type of its value) whenever that has a kind --
  the default candidates of the calls before it may have narrowed the binding
  to nothing (in `a.at(0)`, `a.at(1)` on a MutableArray, `std::list::at`
  standing for the first call narrows `a` to `never` for the second). One build
  per wave, until no stand-in moves (`hir::methods::maxWaves`, 8). A guess only
  chooses where certification starts: a stand-in decides nothing, and a wrong
  one moves at certification (`mf-wrong-guess-corrected`).

## Why the kind proofs change no outcome

An exclusion states the problem the candidate's own build reports for the
call: a native's kind mismatch is exactly what `CallProblems` reports in that
build, and a module function's first-parameter contract of another plain kind,
or declared named struct of another declaration, is an argument its own
admission check rejects (TYPE, with the call as its subject). The receiver's
type in a single deviation is the decided build's whenever the call's own
decision does not change its own receiver (the acyclic case; the milestone's
"Remaining limitations" has the other).

That is checked, not trusted. `hir::methodKindProofs 0` is the *reference
rule*: every candidate is judged by its own build, none by a kind proof (the
waves still choose stand-ins). `hir::methodReferenceAudit 1` decides every
program by both rules and fails unless both give the same decisions and the
same HIR (`hir::ReferenceAudit`). The unit tests, the fuzzer and the golden
suites run under it.

Neither switch is a front-end input: they choose between two ways of
establishing one outcome, so they are in no cache key and no interchange
fingerprint beyond `hir/`'s own text.

## What it touches

* `hir/methods.tcl`: `NativeMismatch`, `Excluded`, `ParamKinds`,
  `DeclaredParam`, `CandidateBlock`, `NominalMismatch`, `DefinedType`,
  `Survivors`; `hir::methods::maxWaves`; a trace
  (`BOTLISH_METHOD_TRACE=1`: the waves, the trial rounds and the
  certification steps, on stderr).
* `hir/hir.tcl`: `hir::DecideMethodCalls` and `hir::ReferenceAudit`; the
  switches `hir::methodKindProofs` (`BOTLISH_METHOD_KIND_PROOFS=0`) and
  `hir::methodReferenceAudit` (`BOTLISH_METHOD_REFERENCE_AUDIT=1`).
* Build counters (`hir::BuildStats`): the waves', the trial rounds' and the
  single deviations' builds are `methodTrials` (so "builds besides method
  trials", which `tests/golden.test` bounds, keeps its meaning),
  `methodDeviations` the single deviations built among them, `methodFinals`
  a final program built again, `methodReused` a build read from its record.

## Tools and tests

* `tests/method-filter.test`: the rule and its one statement, what the kind
  waves settle and at what cost, what is left to the candidates' own builds,
  the reference audit and that it can fail, the switches.
* `audit/method-filter/tools/fuzz.tcl`: random programs of receivers of every
  kind, chained and narrowed, with ambiguous, wrongly-typed and lexical cases,
  and named-struct receivers from three modules of a private library (two
  structs of the same fields, a parameterized struct with imprinted and
  concrete parameters over it, an untyped function with an inferred
  contract; MutableMap and MutableSet) -- modules that also define `length`,
  `at` and `get` over their structs beside the standard collections', the
  trigger EXACT-METHOD-DECISION-MISATTRIBUTION.md describes, which the fuzzer
  had to leave out while the exact decision misattributed it. Each program is
  compiled under the reference audit, under the audit of build reuse
  (`hir::methodBuildAudit`) and plainly, and the outcomes must be equal.
* `audit/method-filter/tools/mutate.tcl`: mutants of the kind proofs and of
  the reference audit (an exclusion rule weakened or reversed, a lexical name
  excluded, a contract source ignored, the nominal rule dropped, comparing
  type arguments, excluding the same declaration, trusting an inferred
  contract or a receiver that is no named struct, the waves, the seeds and
  trait decisions, the audit's comparisons); each must be killed by the unit
  tests or the fuzzer. The decision's own mutants are
  `audit/method-resolution/tools/mutate.tcl`'s.
* `bench/method-filter.tcl`: builds and front-end time of the golden suites
  that decide method calls, with the kind proofs and (`-reference 1`) by the
  reference rule, and (`-audit 1`) under the reference audit.

## Performance

The kind proofs settle most calls without a build of their own: every
golden suite's decided program is reached with no single deviation at all
except where a call is genuinely left to its candidates' builds (a lexical
candidate, an untyped receiver, two candidates of one kind).
METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md ("Economics") has the
measurements of the decision as a whole, against the filter and exact
decision it replaced, and of the reference rule.

## History

The kind filter was introduced to save trial builds of the exact decision
(`hir::DecideMethodCallsExact`), which built the whole program once per
candidate index of every pass of a receiver chain and judged a candidate by
the diagnostics located inside the call (`hir::MethodCallProblems`). The
filter decided in waves from exclusions, took back decisions a later build
contradicted, accepted its result with a certificate (every call decided, no
chosen candidate with a problem of its own) and otherwise handed the whole
program to the exact decision, made from the start; `hir::methodFilterAudit`
made the exact decision as well whenever the filter certified one and failed
unless both agreed.

Its claim -- "it changes how many builds a decision takes, never its outcome"
-- rested on the exact decision being right. It was not:
EXACT-METHOD-DECISION-MISATTRIBUTION.md records a valid chain the exact
decision rejected (an outer candidate's rejection of the inner call's result,
reported at the inner call's node, counted as the inner call's problem), so a
program's outcome depended on whether the filter or the exact decision decided
it, and an unrelated call the filter could not settle made a valid chain fail.
METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md replaced both procedures with one
whose verdicts are a call's own checks, certified relative to the decided
configuration; the filter's exclusion rule survived unchanged as the kind
proofs described above, and its audit became the reference audit.
