# Deciding method-style calls by kind

`receiver.name(args)` means the one visible function `name` whose ordinary
call `name(receiver, args)` is valid (METHOD-SUGAR.md). `hir::DecideMethodCalls`
finds it by *trial builds*: it builds the whole program once per candidate
index of every pass of a receiver chain, reads the diagnostics inside each
call, and keeps the candidate that is the only valid one. A build is the only
way to learn what a configuration reads, so this costs whole-program builds
(STATIC-DECISION-ECONOMICS.md, "Within one decision: no configuration built
twice", is its floor). Attributing every build of the 94 golden suites to its
caller gave 318 builds, 82 of them method trials and finals (26%) and 45% of
the time spent building, the first builds and the static-block rounds taking
the rest.

The **kind filter** (`hir/methodfilter.tcl`) reaches the same decisions in
fewer builds when the receivers' kinds settle every call, and leaves every
other decision to the exact one. It changes how many builds a decision takes,
never its outcome.

## The idea

Most method calls are settled by the kind of the receiver. `xs.length()` on a
List cannot be `std::str::length`, because the native's first parameter is a String
-- and that is exactly the TYPE problem a trial build finds in the call
(`hir::MethodCallProblems`). The filter derives the same fact without a build.

* **Excluded.** A candidate is *excluded* for a call when the receiver's type
  already makes the ordinary call invalid by kind alone, or by a named
  struct's declaration:
  * a qualified native (`std::list::at`) whose first parameter has another known
    kind than the receiver's -- `hir::methodfilter::NativeMismatch`, the one
    statement of the rule: `hir::MethodCallProblems` reports its TYPE problem
    by it and the filter excludes by it;
  * a module function (`std::mutable_array::get`) one of whose first-parameter
    contracts -- declared, trusted-inferred or checked-inferred
    (hir/signatures.tcl) -- has another kind than the receiver's, when both
    are among the plain value kinds `int str bool unit UnicodeChar list struct
    enum mutvec mutarray`;
  * a module function (`std::mutable_set::length`) whose *declared* first
    parameter is a named struct of another declaration than the receiver's
    named struct type (a `std::mutable_map::MutableMap[int, int]`) --
    `hir::methodfilter::NominalMismatch`. Every struct has the kind `struct`,
    so the kind rule cannot tell two structs apart; their declarations can,
    because named structs are nominal: a struct argument is admitted by
    subtyping alone (`hir::range::ProvesValueAcceptedBy`), and a struct type
    is a subtype of a named one only when it is the same declaration
    (`hir::types::subtype`), never a struct of the same fields from another
    declaration or an anonymous one, so the ordinary call is the TYPE problem
    a trial would find. Only the
    declaration is compared, never the type arguments (a declared
    `MutableMap[K, V]` carries imprint variables, and two applications of one
    struct are the exact decision's to judge); only a declared parameter
    counts, never an inferred contract (`mf-nominal-inferred-contract-not-compared`);
    and only a receiver that is itself a named struct (an application or
    not): `any`, an imprint variable, a trait view or an anonymous struct
    excludes nothing by it.

  A candidate that is not excluded is a *survivor*. Nothing excludes a lexical
  candidate (a bare name: a function of the file, a parameter, a binding), and
  nothing is excluded for a receiver that is `any`, `never` or a function, or by
  a kind outside the list above (a pointer, say). A domain or a refinement has
  the kind of its base: an Int receiver does not exclude a parameter of an
  integer domain (a range proof admits a literal), a String receiver does.
* **Decided.** A call with exactly one survivor is decided to it.
* **Waves.** The receiver's type is read from the last build, in which the
  calls not yet decided stand at their first candidate. Those defaults can
  poison the receivers after them: in `a.at(0)`, `a.at(1)`, `a.at(2)` on a
  MutableArray, `std::list::at` standing for the first call narrows `a` to nothing
  for the others. A receiver that is a plain reference to a binding is
  therefore *guessed* to have the type the binding was defined with (a
  parameter's declared type, else the type of its value) whenever that has a
  kind, which decides the whole chain in one wave. The guess is only a guess:
  after the build, every decision is read again from the receivers the build
  really gives, without it (below). Where nothing can be guessed (a receiver
  that is a call's result, an untyped parameter) a build gives the next wave
  its receivers, one build per wave.
* **Taken back.** A decision made from a receiver that a later decision changes
  (an earlier call stood at a candidate that narrowed the binding) is taken
  back when the next build shows the receiver it really has: the filter
  recomputes the survivors of every decision it made, without the guess, and
  evicts those that are not still exactly the decision. A decision taken back
  is decided again only from a real receiver, never from the guess.
  `tests/method-filter.test`, `mf-stale-decision-taken-back` pins a program
  where this happens.
* **Certificate.** The result is accepted only when every call is decided, the
  last build was made under exactly the decisions that stand, every survivor
  set in it -- from the receivers it really has, so a `never` receiver
  (`mf-poisoned-receiver-is-not-guessed`) is never certified -- is still the
  decision, and no chosen candidate has a problem of its own
  (`hir::MethodCallProblems`). That build is the final program.
* **Hand-over.** Anything else is the exact decision's, made from the start:
  a call with several survivors (an untyped receiver, a lexical candidate), none
  (no applicable method), a chosen candidate with a problem, a decision taken
  back and not made again, the wave limit (`hir::methodfilter::maxWaves`, 8).
  Every rejection, every ambiguity and every message is the exact one's. A call
  with several survivors or none whose receiver nothing can change -- a
  constant, a typed parameter, a native applied to such (`Closed`), and not
  `never` -- ends the attempt at once, before any build is spent on the other
  calls: it can only be the exact decision's.

## Why the outcome is the exact decision's

The exact decision defines the outcome: a call is the candidate whose ordinary
call is the only valid one, judged with every other call decided.

* **The filter cannot accept an ambiguity or skip a valid candidate.** An
  exclusion proves a candidate invalid (the same TYPE problem the trial finds),
  never that another is valid. So the survivors contain every valid candidate:
  two valid candidates are two survivors, and a call with two survivors is not
  decided. A call with one survivor is ambiguous only if that candidate is the
  one valid candidate -- which the certificate's last check ("no problem of its
  own") establishes on the final build.
* **The certificate is the exact decision's fixed point.** In the final build
  every call is at its decision, the survivor set of every call is exactly its
  decision (so every other candidate is invalid there, with the receiver the
  call really has -- a call's own choice does not change its receiver), and
  the decision is valid. That is a configuration in which every call is the
  unique valid candidate given the others. The exact decision ends in such a
  configuration, and dataflow is acyclic: a call's receiver is a function of
  earlier calls (and of inferred contracts of functions, which flow from
  callees to callers), so the configuration is determined call by call.
* **It is checked, not trusted.** `hir::methodFilterAudit` (below) makes the
  exact decision as well whenever the filter certified one and fails unless
  both give the same decisions and the same HIR. The golden suites, the
  fuzzer and the unit tests all run under it.

What the argument does not cover is stated, not assumed: a mutual dependency
between calls through a recursive function's inferred contract, which the audit
has not found (and which would make the filter hand over, not decide
differently, wherever the receiver is not the same in the final build).

## What it touches

* `hir/methodfilter.tcl`: `Decide`, `Survivors`, `Receiver`, `Excluded`,
  `ParamKinds`, `DeclaredParam`, `NominalMismatch`, `Closed`,
  `NativeMismatch`; `hir::methodfilter::maxWaves`; a trace
  (`BOTLISH_METHOD_FILTER_TRACE=1`: one line per wave, decision taken back and
  hand-over, on stderr).
* `hir/hir.tcl`: `hir::DecideMethodCalls` tries the filter and otherwise calls
  the exact decision, now `hir::DecideMethodCallsExact`, unchanged;
  `hir::FilterAudit`; `MethodCallProblems` asks `NativeMismatch` for the native
  TYPE problem. The switches `hir::methodFilter` (0 turns the filter off;
  `BOTLISH_METHOD_FILTER=0`) and `hir::methodFilterAudit`
  (`BOTLISH_METHOD_FILTER_AUDIT=1`). The exact decision's own audits
  (`hir::methodBuildAudit`, `hir::methodBuildReuse 0`) run without the filter.
  Neither switch is a front-end input: they choose between two paths of one
  outcome, so they are in no cache key and no interchange fingerprint beyond
  `hir/`'s own text.
* Build counters (`hir::BuildStats`): the filter's waves are counted as
  `methodTrials` (so "builds besides method trials", which
  `tests/golden.test` bounds, keeps its meaning), and `methodFiltered` (a
  decision it completed), `methodFilterAbandoned` (one it gave to the exact
  decision after building) and `methodFilterEvicted` (decisions taken back) are
  new.
* Seeds. A round of `hir/static.tcl` passes the decisions of the previous
  round that nothing since can have touched (`MethodSeeds`) as the first
  build's choices and as `seeds`; the filter takes them as decided and never
  takes them back, as it takes the calls decided by a trait (a method-style
  call on a trait view is an operation of the trait, decided before any
  candidate is looked at). A decision with nothing left for the filter to
  decide is the exact one's, which makes at most one build.
* Process state. A certified decision leaves the process in the state of the
  last build, which is the final program (or of the first build, when the
  decisions are the first candidates and no wave built anything), as the exact
  decision does. A hand-over after builds calls `hir::activate` on the first
  build's HIR before the exact decision starts.

## Performance

`tclsh9.0 bench/method-filter.tcl -suites` compiles each golden suite that
decides method calls by trial builds with the filter off and on, each in a
process of its own (the same tool with `-audit 1` also runs it under the audit).

| program | builds off → on | method trials off → on | front end ms off → on | filter |
|---|---:|---:|---:|---|
| callable-contracts.bot | 7 → 6 | 2 → 1 | 27300 → 23174 | filtered 1, abandoned 0, taken back 0 |
| collections.bot | 7 → 5 | 2 → 1 | 9058 → 6311 | filtered 1, abandoned 0, taken back 0 |
| declared-errors.bot | 7 → 4 | 3 → 1 | 17955 → 10202 | filtered 1, abandoned 0, taken back 0 |
| destructuring.bot | 7 → 5 | 1 → 0 | 50077 → 39432 | filtered 1, abandoned 0, taken back 0 |
| diagnostics.bot | 6 → 6 | 1 → 1 | 5315 → 5907 | filtered 0, abandoned 0, taken back 0 |
| framework-semantics.bot | 7 → 7 | 2 → 2 | 13970 → 15626 | filtered 0, abandoned 0, taken back 0 |
| imports.bot | 11 → 11 | 7 → 7 | 17864 → 17405 | filtered 0, abandoned 0, taken back 0 |
| method-equivalence-imported.bot | 5 → 5 | 1 → 1 | 4997 → 5302 | filtered 0, abandoned 0, taken back 0 |
| methods.bot | 6 → 5 | 1 → 1 | 34163 → 26852 | filtered 1, abandoned 0, taken back 0 |
| mutable-array.bot | 18 → 7 | 12 → 2 | 166999 → 54342 | filtered 1, abandoned 0, taken back 0 |
| mutable-vector.bot | 10 → 12 | 4 → 6 | 20830 → 26508 | filtered 0, abandoned 1, taken back 0 |
| opaque.bot | 8 → 5 | 2 → 0 | 19532 → 11048 | filtered 1, abandoned 0, taken back 0 |
| ownership.bot | 8 → 5 | 3 → 1 | 11840 → 6607 | filtered 1, abandoned 0, taken back 0 |
| recursive-types.bot | 2 → 2 | 1 → 1 | 1581 → 1667 | filtered 1, abandoned 0, taken back 0 |
| refinements.bot | 7 → 7 | 3 → 3 | 18529 → 17843 | filtered 0, abandoned 0, taken back 0 |
| static-compile.bot | 14 → 12 | 4 → 3 | 36382 → 28107 | filtered 1, abandoned 0, taken back 0 |
| stdlib-namespaces.bot | 8 → 4 | 4 → 1 | 25606 → 10673 | filtered 1, abandoned 0, taken back 0 |
| structs-and-enums.bot | 16 → 6 | 11 → 1 | 37176 → 13006 | filtered 1, abandoned 0, taken back 0 |
| traits.bot | 10 → 10 | 3 → 3 | 20927 → 19495 | filtered 0, abandoned 0, taken back 0 |
| **all 19 programs** | **164 → 124** | **67 → 36** | **540101 → 339507** | |

(Measured on the sandbox's four cores with other jobs running beside, so the
milliseconds are indicative; the build counts are exact. "Builds" are every
whole-program build of the front end, the first build of each round and the
trait rebuild among them, so the filter's saving is the difference. Every
decision the filter completed was also made by the exact decision under
`-audit 1`, and the two agreed.)

Programs with no method call that has several candidates take the same path as
before (the filter is not tried). A program whose method calls the filter hands
over (the ambiguity and no-applicable-method tests of the suites, calls on
untyped receivers) pays the builds the filter made before it gave up -- none
when no call is decidable from the first build.

Where the filter hands over the program pays for the builds it made first:
`mutable-vector.bot` (10 → 12 builds) has a chosen candidate with a problem of
its own (a use after a move of an affine value inside a call), which the filter
does not judge, and finds out only after two builds. Handing over is decided
without a build whenever a call has several survivors or none and a receiver
that nothing can change (a constant, a typed parameter, a native applied to
such), as in the ambiguity and no-applicable-method tests of the suites:
`imports.bot`, `diagnostics.bot`, `refinements.bot` and `traits.bot` make the
builds they made before.

The case that motivated the filter -- a 15-puzzle test harness whose data
module makes 300 calls into a module that imports `test`, `board` and `solver`,
and whose own 19 method calls were decided by 6 trial and final builds, each
re-checking the 300 entries -- takes 2 builds instead of 7 (the first, and the
filter's one wave): 19.1 s to 6.0 s with other jobs running.

## Tools and tests

* `tests/method-filter.test`: the rule, what is decided and at what cost, what
  is handed over, the audit and that it can fail, the switches.
* `audit/method-filter/tools/fuzz.tcl`: random programs of receivers of every
  kind, chained and narrowed, with ambiguous, wrongly-typed and lexical cases,
  and of named-struct receivers (three modules of a private library: two
  structs of the same fields, a parameterized struct with imprinted and
  concrete parameters over it, an untyped function with an inferred
  contract; MutableMap and MutableSet); each is compiled with the filter off
  and under the audit and the outcomes must be equal. The summary also
  reports the builds both took.
* `audit/method-filter/tools/mutate.tcl`: mutants of the filter and of its use
  (an exclusion rule weakened or reversed, a lexical name excluded, a contract
  source ignored, the nominal rule dropped, comparing type arguments,
  excluding the same declaration, trusting an inferred contract or a receiver
  that is no named struct, the eviction, the certificate's checks, the seeds
  and trait decisions, the audit's comparisons); each must be killed by the
  unit tests or the fuzzer.
* `bench/method-filter.tcl`: the table above.

Validation at the time of writing: `tests/method-filter.test` 30 tests;
`audit/method-filter/tools/fuzz.tcl` 200 seeds, 0 disagreements, 167 of the 200
programs certified, the 17 handed over all programs the exact decision rejects
(ambiguity, no applicable method), 1,994 builds with the filter off against 779
on; `audit/method-filter/tools/mutate.tcl` 27 mutants, all killed by the unit
tests; the 94 golden suites, the Tcl tests of `tests/local.tcl` and the
test files that decide method calls (`method-sugar`, `method-eligible`,
`imports`, `static-compile`, `static-economics`, `surface-modules`) pass, the
last under `BOTLISH_METHOD_FILTER_AUDIT=1`; the static-decision mutants of
`hir/hir.tcl` (`audit/static-decisions/tools/mutate.tcl`) are all still killed,
and its fuzzer and the method-sugar fuzzer find nothing under the audit.

The nominal rule (added later, for ORDERED-MUTABLE-MAP-SET.md's collections)
was validated the same way: `tests/method-filter.test` 35 tests (5 of them the
rule's); the fuzzer with named-struct, MutableMap and MutableSet receivers 60
seeds, 0 disagreements, 26 programs certified, 719 builds with the filter off
against 524 on; `audit/method-filter/tools/mutate.tcl` 32 mutants (5 of the
rule), all killed by the unit tests; `bench/method-filter.tcl -audit 1` on the
19 suites of the table and six later ones (collection-iteration, mutable-map,
mutable-set, place-parameters, hashable, trait-constrained-types) with the same
builds and method trials as before the rule in every one (223 → 155 builds, 103
→ 46 trials: no suite calls a function two structs' modules share by method
syntax), every certified decision agreeing under the audit; `method-sugar`,
`imports`, `static-economics`, `static-compile` and `surface-modules` pass. A
program calling `length` on a MutableMap and a MutableSet took 9 builds (6
method trials) before the rule and takes 3, as with the calls written
qualified.

If you change `hir/methodfilter.tcl`, `hir::DecideMethodCalls`,
`hir::MethodCallProblems`, the candidate gathering of method calls
(`hir::resolve::MethodCandidates`), what a trusted or checked parameter
contract records (`hir/signatures.tcl`'s `inferredParamTypes` and
`checkedParamTypes`), the kind a type has (`hir::types::kindOf`), or when a
struct type is a subtype of a named one (`hir::types::subtype`), run
`tests/method-filter.test`, `tests/static-economics.test`,
`tests/static-compile.test`, `tests/method-sugar.test`, `tests/imports.test`,
`audit/method-filter/tools/fuzz.tcl` (several seeds) and
`audit/method-filter/tools/mutate.tcl` (every mutant must be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of the
same rule); and run the suites above and the golden suites under
`BOTLISH_METHOD_FILTER_AUDIT=1`.

## A defect of the exact decision

Extending the fuzzer to named-struct receivers found a program the exact
decision rejects and the filter accepts. It is not the filter's: the
compiler before the nominal rule rejects it the same way, and the filter
decides it as METHOD-SUGAR.md says. With a module `std::boxlen` that
declares `struct Box` and `fn length(b: Box) -> int`:

```
import std::list
import std::str
import std::mutable_array
import std::mutable_vector
import std::boxlen

fn f() -> int errors IndexNotFound:
    [[1, 2], [3], [4, 5, 6]].at(2).length()
```

`std::list::length(std::list::at(xs, 2))` compiles clean, and so does the
method spelling with the filter on (it rules out every candidate of both
calls but the List ones, by kind). With the filter off -- or wherever the
filter hands a program over -- the exact decision reports NO-APPLICABLE-METHOD
for `at` ("std::list::at: argument for parameter "b" cannot be proven to
satisfy std::boxlen::Box (argument type: List[int])") and then
AMBIGUOUS-METHOD-CALL for `length`.

The cause is what "inside the call" means. A candidate is valid when its
trial build has no diagnostic located in the call's subtree
(`hir::MethodCallProblems`), and the subtree includes the call's own node.
Candidates are ordered by name, and trial t gives every undecided call its
t-th candidate, so `std::list::at` (the first of `at`'s three) is judged by
trial 0, where `length` stands at its first candidate too:
`std::boxlen::length`, whose name sorts before `std::list::length`. That
candidate rejects its receiver -- the `at` call's List result -- and a
rejected receiver is diagnosed at the receiver (METHOD-SUGAR.md, "Source
locations and diagnostics"), which is the `at` call's node. So the outer
call's problem is read as the inner call's, in the trial that judges the
inner call's one valid candidate; the other two have problems of their own
kind (and an invalid candidate's result is poison, which the outer check
skips), so nothing is shared and std::list::at is found invalid.

It needs an inner method call with several candidates (one with a single
candidate is not decided) and an outer candidate that rejects the inner
result and sorts first: a module whose name sorts after `std::list`
(`std::zbox`) does not trigger it, and an application module does, since
`bag::length` sorts before every `std::` name. The same program with
`import bag` (a `struct Bag` and `fn length(b: Bag)`) compiles clean with the
filter and fails with it off, or wherever the filter hands the program over
because of some other call.

The fuzzer leaves the trigger out (its modules define no `length`, `at` or
`get`); the unit tests and the fuzzer test the filter, not this. Fixing it
changes the exact decision -- which diagnostics a call owns -- so it is a
decision of its own: the outcome changes for programs the exact decision
rejects today, and the static-decision harnesses would have to agree.
EXACT-METHOD-DECISION-MISATTRIBUTION.md is the full report (open, not
fixed): the reproduction, the variants, the mechanism step by step, when it
occurs and what a fix would involve.

## What was tried and not done

* **A type-to-method map as the authority.** A table from the first
  argument's type to the admissible methods cannot decide: validity is the
  validity of the ordinary call (the other arguments, arity, range proofs, the
  receiver's flow-dependent type, inferred contracts that depend on bodies that
  contain undecided calls), and the candidates visible depend on the call's
  scope. The filter is the part of such a map that is sound -- an
  over-approximation used to exclude, certified by a build.
* **Cheaper trial builds.** A spike that re-checked only the functions a
  trial can reach (the functions holding undecided calls and what they
  reference) gave identical problems and receiver types on 32 trial builds of
  seven programs at one tenth of the check time for most of them. It is not
  done: it needs a locality theorem the checker does not give (the demotion
  re-check, the instance budget, the erased-callable contract, the ownership
  verdict are whole-program facts: COMPILER-BOTTLENECKS.md, 3.10). The filter
  leaves it for the calls that are handed over.
* **Reusing an older build as the final one.** The filter's last build is the
  final program already; the exact decision's final rebuild is the case the
  filter avoids.
* **Deciding with the seeds of the exact decision after a hand-over.** The
  decisions the filter made before it handed over are discarded: the exact
  decision's calls are decided with all other calls undecided, and keeping the
  filter's would make the outcome depend on which calls it happened to settle.
