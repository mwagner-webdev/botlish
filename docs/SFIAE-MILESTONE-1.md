# SFIAE-MILESTONE-1.md -- obligations do not select operations

Completion report of a narrow semantic correctness milestone following
METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md. It removes the inconsistency
that report recorded (its section 10.1, "Context obligations"), and states
the rule behind the correction as a language principle:

> **SFIAE -- Substitution Failure Is An Error.** Failure to satisfy a
> selected operation's obligations is an error, not an invitation to select
> another operation.

The base of every "before" below is `d27e8745` (main when the milestone
started). The change is on the branch `ccr-8833f57f-8cv6wd`.

## Contents

1. Result
2. Previous behavior
3. Normative principle
4. Implementation
5. Tests
6. Independent validation
7. Integration
8. Documentation
9. Remaining limitations

## 1. Result

* **The semantic change.** Whether a context trait a candidate requires has
  exactly one installed implementation (`AMBIGUOUS-CONTEXT-IMPLEMENTATION`)
  is now an obligation of the selected call, like whether a required context
  is installed at all (`MISSING-CONTEXT`): it is one of
  `hir::methods::ObligationKinds`, so it is never a method candidate's
  problem. What is installed -- no context, one, two implementing the same
  trait, an exact context or not -- no longer influences which candidate a
  method-style call is decided to, or whether it is ambiguous:

  | situation | before | now |
  |---|---|---|
  | one candidate fits the arguments, its required context absent | that candidate, MISSING-CONTEXT | the same |
  | one candidate fits, two installed contexts implement its context trait | **NO-APPLICABLE-METHOD** | that candidate, AMBIGUOUS-CONTEXT-IMPLEMENTATION |
  | two fit, only one has satisfiable contexts (the other's trait has two providers) | **decided to the other, silently** | AMBIGUOUS-METHOD-CALL |
  | two fit, one's context missing, the other's trait ambiguously implemented | **decided to the one with the missing context** | AMBIGUOUS-METHOD-CALL |
  | one fits with an unmet context obligation, beside one that does not fit | NO-APPLICABLE-METHOD when the obligation is the ambiguous implementation | that candidate, with its context error |
  | installations change, argument applicability does not | the decision could change | the decision never changes |

* **Complete for the defect.** A census of every diagnostic kind a call's
  own checks record (section 4.3) finds no other obligation that counts
  against a candidate: the obligation kinds that reach a call's `subject`
  are MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION, UNHANDLED-ERROR and
  AMBIGUOUS-METHOD-CALL, all now in the list; every other one is a check of
  the supplied arguments against the callee. Context-trait provider
  selection already ignored a provider's own obligations (section 4.4).
* **A second, consistent effect.** The same list says which diagnostics
  reject no argument of a call for diagnostic recovery (`hir/recovery.tcl`):
  the ownership analysis's erasure of an argument is now reported beside an
  ambiguous implementation, as it already was beside a missing context
  (section 4.5).
* **The principle.** SFIAE is stated, with its rationale, examples,
  boundary and its force for future features, in
  LANGUAGE-DESIGN-PRINCIPLES.md, a new document of the normative design
  principles, linked from INDEX.md, the root README, METHOD-SUGAR.md,
  CONTEXTS.md, CONTEXT-TRAITS.md, AGENTS.md and Compilerpedia
  (`rule.sfiae`).
* **Not claimed.** The guarantees are those of the method-call decision
  (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, section 5), with one more
  obligation kind: no new proof of the decision's uniqueness for cycles, no
  change to which checks are owned (section 9).

## 2. Previous behavior

A context requirement is a check of a top-level call against its callee
(`hir::contexts::Obligations`, run inside `hir::CheckingCall`), so its
diagnostics carry the call as their `subject`, and the method-call decision
reads a call's diagnostics with that subject, minus the obligation kinds, as
the candidate's problems (`hir::methods::OwnedBySubject`). MISSING-CONTEXT
was in the list, AMBIGUOUS-CONTEXT-IMPLEMENTATION was not: with two
providers installed, a candidate requiring the trait had a problem of its
own and was not applicable -- the location rule's verdict, which the previous
milestone kept.

A minimal reproducer -- six application modules and an entry program:

```
-- env.bot                     -- ca.bot                         -- cb.bot
context trait Env:             context struct CA:                context struct CB:
    fn tick(n: int) -> int         k: int                            k: int

                               fn tick(n: int, context c: CA)    fn tick(n: int, context c: CB)
                                       -> int:                           -> int:
                                   n + c.k                           n * c.k

-- alpha.bot                   -- beta.bot                       -- gamma.bot
import env                     fn f(x: int) -> int:              fn f(x: str) -> int:
                                   x + 1000                          0
fn f(x: int, context e: env::Env) -> int:
    e.tick(x)

-- main.bot
import ca
import cb
import alpha
import beta                    # or: import gamma
<installations>
7.f()
```

Each row compiled once by the base's front end and once by this
milestone's (`-strict 0`; builds are whole-program builds, method trial
builds, single deviations and final programs built again):

| imports | installed | base `d27e8745` | builds | now | builds |
|---|---|---|---|---|---|
| alpha, beta | none | AMBIGUOUS-METHOD-CALL (and the placeholder's MISSING-CONTEXT) | 3/1/0/1 | the same | 3/1/0/1 |
| alpha, beta | CA | AMBIGUOUS-METHOD-CALL | 3/1/0/1 | the same | 3/1/0/1 |
| alpha, beta | CA, CB | **decided beta::f, no diagnostic: runs to 1007** | 3/1/0/0 | AMBIGUOUS-METHOD-CALL (and the placeholder's AMBIGUOUS-CONTEXT-IMPLEMENTATION) | 3/1/0/1 |
| alpha, gamma | none | alpha::f, MISSING-CONTEXT | 1/0/0/0 | the same | 1/0/0/0 |
| alpha, gamma | CA | alpha::f, runs to 8 | 2/0/0/0 | the same | 2/0/0/0 |
| alpha, gamma | CA, CB | **NO-APPLICABLE-METHOD** (and AMBIGUOUS-CONTEXT-IMPLEMENTATION) | 3/1/1/1 | alpha::f, AMBIGUOUS-CONTEXT-IMPLEMENTATION | 1/0/0/0 |

The base program with alpha and beta compiled and ran a function its author
may not have meant, chosen by what the entry program installed: adding the
second installation turned an ambiguity into a silent decision. Its
variants: with `delta::f(x: int, context c: cx::CX)` in beta's place and
CA, CB and CX installed, the base decided delta::f and ran it; with CX
missing it decided delta::f and reported its MISSING-CONTEXT
(`mr-sfiae-installation-changes-no-decision`, `mr-sfiae-competing-candidates`
on the base). The qualified call `alpha::f(7)` reported
AMBIGUOUS-CONTEXT-IMPLEMENTATION where its method spelling reported
NO-APPLICABLE-METHOD: the spellings carried different obligations
(`mr-sfiae-qualified-obligations` on the base).

Only a method call in top-level code was affected: context requirements are
checked at top-level calls, and a call in a function body passes its
callee's requirement to the enclosing function, whose own top-level call
carries the obligation. So no program whose method calls are all inside
functions -- every program of the method-call oracle and fuzzer before this
milestone -- could show the defect (section 6.1).

`tclsh9.0 main.tcl -check main.bot` on the reproducer prints the diagnostics
of the table.

## 3. Normative principle

LANGUAGE-DESIGN-PRINCIPLES.md, section 1, is the authoritative statement.
In brief:

* **Applicability** -- which operation the program denotes -- is answered
  by the language's explicit applicability rules, from the arguments and the
  visible declarations: for method syntax, the one visible candidate whose
  ordinary call is valid (arity, flags, admission of the receiver and the
  arguments by declared and inferred parameter contracts, domains,
  refinements, native kinds, nominal and structural types, trait
  constraints, imprinting, semantic-instance validity, the place and
  ownership requirements that admit the supplied arguments).
* **Obligations** -- whether the selected operation can be used here -- are
  what it requires of the place and the environment it is called in: its
  declared errors handled (UNHANDLED-ERROR, KNOWN-ERROR), its contexts
  installed and each required context trait implemented by exactly one
  installed context (MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION), its
  direct authority mediated (DIRECT).
* A failed obligation is a diagnostic of the selected call. It never removes
  an applicable candidate, prefers one, resolves an ambiguity, makes the
  operation depend on the environment, or introduces fallback or ranking.
* **Boundary.** Method syntax still rules inapplicable candidates out, and a
  rejected candidate's diagnostics are not errors of the program; no
  established applicability check is reclassified; an implementation's
  fallback from a specialized to a general way of running the same operation
  (coroutine fusion, a declined instance) selects no operation; and
  `static compile:` is an explicit, written observation of compilation whose
  handler is the program's own decision.
* **Future features.** SFIAE constrains every future feature that involves
  selection, fallback, effects, capabilities or contextual dependencies:
  selecting by an obligation needs an explicit language-design decision.
  Botlish offers no C++-style substitution-failure fallback and has no
  conventional overloading; the name is a mnemonic only.

## 4. Implementation

### 4.1 The change

One kind added to the obligation list (`hir/methods.tcl`):

```
proc hir::methods::ObligationKinds {} {
    ...
    return {UNHANDLED-ERROR KNOWN-ERROR UNDECLARED-ERROR AMBIGUOUS-METHOD-CALL
            MISSING-CONTEXT AMBIGUOUS-CONTEXT-IMPLEMENTATION DIRECT}
}
```

and comments: the list's own (why both context kinds are obligations, and
SFIAE), the header of `hir/methods.tcl`, and the call of `Obligations` in
`hir::contexts::verify`. Nothing else in the compiler changed.

### 4.2 Why it is the smallest sufficient correction, and no new mechanism

* The previous milestone already separated a call's own checks (`subject`)
  from the obligations a valid call may carry, and already classified
  MISSING-CONTEXT as one. AMBIGUOUS-CONTEXT-IMPLEMENTATION is reported by
  the same check (`hir::contexts::Obligations`), about the same thing -- the
  installed contexts at the call -- so the correction is its classification,
  in the one list that holds the classification.
* No decision procedure, fallback, preference or special case was added:
  `Problems`, the kind proofs, the waves, the trial rounds and the
  certification are unchanged. The reference rule (`hir::methodKindProofs
  0`) reads the same `OwnedBySubject`, so both rules change alike, and the
  reference audit stays an identity check.
* The context check keeps running inside `hir::CheckingCall`: its
  diagnostics are the call's own (the call's callee requires the contexts),
  and the decision does not read them because they are obligations -- the
  same structure as UNHANDLED-ERROR. Moving the check out of
  `CheckingCall` instead would have given the same decisions while making
  ownership false.
* Context resolution itself (installation, satisfaction, provider
  selection, dependency inference, the monomorphization) is unchanged.

### 4.3 Census: which diagnostics are a call's own problems

To find every obligation that could count against a candidate, the kind of
every diagnostic recorded with a `subject` was logged (a scratch copy of the
front end whose `hir::Diagnose`/`DiagnoseAt` appended the kind to a file)
while 35 test files ran on interp: static-compile, diagnostic-recovery,
method-resolution (before this milestone's tests), method-filter,
method-sugar, contexts, context-traits, direct-modules, errors,
error-payloads, affine, coroutines, flags, variadics, mutable-vector,
mutable-array, traits, hashable, trait-constrained-types, c-abi-types,
binary-layout, decimal-rounded, list-length-refinement, refinement-values,
module-privacy, namespaced-errors, structural-contract-completions,
higher-order-completions, place-parameters, syntax-recovery, imports,
static-economics, semantic-instances, mutable-map, type-predicates (2,130
tests, all passing). 28 kinds occurred:

| kinds | occurrences | what they judge | class |
|---|---:|---|---|
| TYPE | 3,049 | argument admission, instance validity, callable contracts | applicability |
| MUTABLE-PLACE-RECEIVER | 396 | a mutation's receiver is a place | applicability |
| OPAQUE-REPRESENTATION | 288 | the callee's instance takes apart an opaque argument | applicability (instance) |
| IMPRINT | 109 | the arguments imprint the callee's variables | applicability |
| TRAIT-NOT-SATISFIED | 50 | an argument satisfies a parameter's trait | applicability |
| AFFINE-ERASURE-UNSUPPORTED, AFFINE-EQUALITY-UNSUPPORTED, AFFINE-ELEMENT-COPY-OUT, AFFINE-DUPLICATION-UNSUPPORTED, AFFINE-LIST-OPERATION-UNSUPPORTED, USE-AFTER-MOVE | 79 | the ownership roles that admit an argument (USE-AFTER-MOVE: an instance's own) | applicability |
| UNKNOWN-FLAG, DUPLICATE-FLAG, FLAG-CALLEE-UNKNOWN, ARITY | 32 | flags and arity | applicability |
| COROUTINE-RESUME-ARITY, COROUTINE-NOT-FUNCTION | 23 | a coroutine operation's operands | applicability |
| TRAIT-UNKNOWN-OPERATION, TRAIT-VIEW-MISUSE | 15 | a trait-view use | applicability |
| LAYOUT-NATIVE-ONLY, LAYOUT-UNION, BINARY-OPERAND | 8 | a layout operation's operands | applicability |
| MISSING-IMPORT, PRIVATE-ACCESS | 4 | the callee's instance names what it cannot see | applicability (instance) |
| **MISSING-CONTEXT** | 54 | the environment provides a required context | **obligation** (listed before) |
| **AMBIGUOUS-CONTEXT-IMPLEMENTATION** | 4 | the environment provides exactly one implementation of a required context trait | **obligation** (listed now) |
| **UNHANDLED-ERROR** | 1 | an instance's own unhandled error (`hir::semantic::DerivedKind` keeps the kind) | **obligation** (listed before) |
| AMBIGUOUS-METHOD-CALL | 1 | a trait call's own ambiguity | the ambiguity check (listed before) |

KNOWN-ERROR, UNDECLARED-ERROR and DIRECT never occurred with a subject
(they are reported by the completion walk, resolution and the direct-module
analysis, outside any call's check); they stay in the list. A semantic
instance's invalidity is reported at the call with `TYPE` unless its first
problem is one of the kinds `DerivedKind` keeps; the instance checks
(`hir::semantic`) run no context or completion analysis, so no other
obligation reaches a call's problems through an instance. The census is of
the checks the test corpus exercises, not a proof over every check; the
static reading of each `hir::CheckingCall` scope (the list in
METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, section 4.1) agrees with it.

### 4.4 Other places where an obligation could select

Each place where the compiler chooses among alternatives was checked:

* **Context-trait provider selection** (`hir::contexts::Obligations`): the
  providers are the installed contexts that satisfy the trait
  (`satisfiesTrait`, the owner namespace's signatures), and the selected
  implementation's own requirements are obligations of the call
  (`ct-implementation-obligations`). A provider whose implementation needs a
  context nobody installed is still a provider, so two stay ambiguous --
  already so; pinned now by `ct-implementation-obligations-select-nothing`.
* **Value traits** (`hir::traits::satisfies`): a witness is the argument's
  concrete type; there is no alternative to select.
* **Handled calls**: `on E:` discriminates the identity only; a handler
  present or absent decides no candidate (an ambiguous `n.g()` stays
  ambiguous with a handler for one candidate's error).
* **Static decisions**: `static compile:` is the explicit, written
  observation of compilation (section 3, "Boundary"). The change removes a
  way installations could reach a method call's decision and adds no
  dependency, so the dependency analysis (`hir/staticdeps.tcl`) needs no new
  edge.
* **Platform modules, linkers, coroutine fusion, instances**: selection by
  an explicit input (the target) or execution strategy, not by an
  obligation.

No other place where an obligation affects selection was found.

### 4.5 Diagnostic recovery

`hir::recovery::OwnedPositions` does not report the ownership analysis's
erasure of an argument (AFFINE-ERASURE-UNSUPPORTED) when an earlier check
rejected that argument or its call -- where "rejected" is any diagnostic
but an obligation, `ObligationKinds` again. Before: a call of
`keep(v: any, context o: out::Out)` with a coroutine argument reported
MISSING-CONTEXT and the erasure with no provider installed, but with two
providers only AMBIGUOUS-CONTEXT-IMPLEMENTATION, as if the call's
arguments had been rejected. Now the erasure is reported beside either
obligation, as with one provider (`dr-obligations-reject-no-argument`).
The list is the one statement of the classification for both readers.

### 4.6 A stale mutant, and why DIRECT is in the list

`audit/direct-modules/tools/mutants.txt`'s `method-obligation-dropped`
(DIRECT made evidence against a candidate) still edited `hir/hir.tcl`, where
the obligation list lived before METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md
moved it to `hir/methods.tcl`: it could not apply. Retargeted to the list as
it is, it applied and **survived**: DIRECT is reported at the call by the
module analysis (`hir::direct::verify`), outside any check of the call, so
it never has a `subject`, and taking it out of the list changes no decision
-- only recovery's reading of the list (section 4.5), which no direct-module
test exercises. Under the subject rule, "a direct call through method syntax
makes its candidate unfit" takes two edits: the DIRECT diagnostic made the
call's own (inside `hir::CheckingCall`) and the kind taken out of the
obligations. So rewritten, the mutant is killed by
`dm-method-sugar-two-candidates`. The census agrees (section 4.3): of the
list's kinds only MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION,
UNHANDLED-ERROR and AMBIGUOUS-METHOD-CALL ever carry a subject; KNOWN-ERROR,
UNDECLARED-ERROR and DIRECT are in it for diagnostic recovery and so that a
future check that reports one of them as the call's own cannot turn it into
selection evidence.

## 5. Tests

`tests/method-resolution.test`, section "Obligations do not select": an
application of a context trait `env::Env`, its two providers `ca::CA` and
`cb::CB`, an exact context `cx::CX`, and four functions `f` -- alpha::f (an
Int, requires Env), delta::f (an Int, requires CX), beta::f (an Int,
requires nothing), gamma::f (a String). Every compilation runs under
`hir::methodReferenceAudit` (the kind proofs and the reference rule decide
alike, or the compilation fails); the tests read the decided candidates
(`methodDecided`), not messages.

| test | pins | before |
|---|---|---|
| `mr-sfiae-unique-candidate` | alpha::f beside gamma::f is decided to alpha::f with no Env provider (MISSING-CONTEXT), one (runs to 8), two (AMBIGUOUS-CONTEXT-IMPLEMENTATION); delta::f beside gamma::f is delta::f without CX (MISSING-CONTEXT) and with it (12) | two providers: NO-APPLICABLE-METHOD |
| `mr-sfiae-competing-candidates` | alpha::f and beta::f are AMBIGUOUS-METHOD-CALL between them with no, one and two Env providers; delta::f (CX missing) and beta::f; alpha::f (two providers) and delta::f (CX missing) | two providers: decided beta::f, silently; alpha/delta: decided delta::f |
| `mr-sfiae-qualified-obligations` | `7.f()` and `alpha::f(7)` report the same diagnostics (kind and message) and the same value under every installation | two providers: different diagnostics |
| `mr-sfiae-installation-changes-no-decision` | under six installations (none, CA, CB, both, CX, all three) a program with `7.f()`, `"s".f()` and a call in a function body decides alike (alpha::f, gamma::f, alpha::f), and with delta::f visible too both Int calls stay ambiguous | CA and CB installed: the top-level call NO-APPLICABLE-METHOD, or decided delta::f |

`tests/context-traits.test`: `ct-implementation-obligations-select-nothing`
(two providers, one of whose implementation needs a missing Clock, are
ambiguous; the other is not selected; with the Clock installed they stay
ambiguous). `tests/diagnostic-recovery.test`:
`dr-obligations-reject-no-argument` (section 4.5). Every new test was run
against the base and fails there (except the context-traits pin, which
holds on both: provider selection was already right); each has a census row
(`audit/golden/migration/census/method-resolution.tsv`, `context-traits.tsv`,
`diagnostic-recovery.tsv`; the names file and the manifest regenerated:
`merge.tcl -check 1` clean).

## 6. Independent validation

### 6.1 The oracle with contexts

The method-call oracle (`audit/method-resolution/tools/oracle.tcl`,
METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, 7.1) predicts every decision
from rules it states itself and never calls the decision procedure. Its
programs put every method call in a function body, where no context
obligation reaches a decision (section 2), so it could not see this defect.
`-contexts 1` (new, opt-in; the default programs are unchanged) extends the
universe:

* a module function may require the context trait `env::Env` (35%), which
  two installable contexts `ca::CA` and `cb::CB` implement, or the exact
  context `cx::CX` (15%);
* about half of a program's statements are top-level code (`rI =
  as_int(EXPR)`, no `at`, so no error to handle), where each method call is
  a top-level call and its candidate's requirement is checked at it;
* each check (the program as written, and with its modules renamed)
  installs one of seven sets of the three contexts, chosen at random;
* the rule it adds is SFIAE's: decisions are predicted exactly as without
  contexts, whatever is installed; a program whose calls are all decided is
  rejected exactly when a decided callee's requirement (in a function body:
  its top-level caller's) has no provider (MISSING-CONTEXT) or two
  (AMBIGUOUS-CONTEXT-IMPLEMENTATION), with exactly those diagnostic kinds;
  an accepted program runs to its qualified spelling's value.

Its reader of the compiler's decisions now takes them from the checked
source of a trait program (`traitSource`: a program requiring `env::Env` is
monomorphized), as `tests/method-resolution.test`'s `mrDecidedIn` does.

| front end | seeds | programs | checks accepted / rejected (by an obligation) | disagreeing programs |
|---|---:|---:|---:|---:|
| this milestone | 1-500 | 500 (2,838 calls, both checks) | 272 / 728 (36) | **0** |
| base `d27e8745` | 1-500 | 500 | -- (each program stops at its first disagreement) | **45** |

Every one of the base's 45 first disagreements is under an installation with
both providers of `env::Env` (19 with CA and CB, 26 with CX too): 29
genuinely ambiguous calls **decided** (to the candidate that needed no
ambiguous context, e.g. `zz::size`, `std::list::length`), 7 valid calls
rejected NO-APPLICABLE-METHOD, 9 ambiguous calls reported as
NO-APPLICABLE-METHOD. The default programs are unchanged: this oracle and
the base's on seeds 1-200 print the same summary (200 programs, 1,128 calls,
122 accepted / 278 rejected, 0 disagreements).

Reproduce: `tclsh9.0 audit/method-resolution/tools/oracle.tcl 500 1
-contexts 1` (267 s here); `-seed-only S -contexts 1 -dump 1` prints one
program. CI's `method-filter` job runs it on 300 seeds beside the default
500 (`.github/workflows/tests.yml`), and the method-resolution mutation
harness uses it as a detector after the default oracle.

### 6.2 Reference audit and fuzzers

* Every compilation of the new method-resolution tests runs under
  `hir::methodReferenceAudit`: the kind proofs and the reference rule
  (every candidate judged by its own build) decide alike and give the same
  HIR, or the compilation fails.
* `audit/method-filter/tools/fuzz.tcl 20 1` (CI's seeds): 20 programs, 12
  rejected, 25 single deviations, 127 builds plainly and 1,231 under the
  audits, 0 disagreements (532 s).
* `audit/context-traits/tools/fuzz.tcl -n 40 -seed 1`: 40 programs (20
  accepted with 34 selections, 20 rejected MISSING-CONTEXT), 0
  disagreements.
* `audit/static-decisions/tools/fuzz.tcl -n 10 -seed 17`: 10 programs, 240
  static sites (116 rejected), 0 failures, no layout pair taking different
  rounds.

### 6.3 Mutation testing

| harness | mutants | result |
|---|---|---|
| `audit/method-resolution/tools/mutate.tcl` | all 17: the 15 of the previous milestone and the new `ambiguous-context-is-a-problem` (the previous behavior: AMBIGUOUS-CONTEXT-IMPLEMENTATION evidence against a candidate) and `missing-context-is-a-problem` | 17 killed (693 s); both new ones by all four `mr-sfiae-*` tests |
| `audit/contexts/tools/mutate.tcl` | `method-candidate-dropped` (MISSING-CONTEXT made evidence) | killed |
| `audit/direct-modules/tools/mutate.tcl` | `method-obligation-dropped` (stale, rewritten: section 4.6) | killed by `dm-method-sugar-two-candidates` |
| `audit/context-traits/tools/mutate.tcl` | the selection mutants: `choose-first-of-several`, `choose-last-installed`, `missing-provider-silent`, `caller-imports-provide` | 4 killed |
| `audit/static-decisions/tools/mutate.tcl` | the method-call mutants: `stale-method-reuse`, `method-key-alias`, `same-choices-unchecked`, `method-memo-by-index`, `method-final-any-build`, `method-trial-ignored`, `method-memo-initial-only`, `never-reuse-methods` | 8 killed (1,069 s) |
| `audit/diagnostic-recovery/tools/mutate.tcl` | all 25 | 25 killed |

`audit/diagnostic-recovery/tools/efficiency.tcl`: the corpus's 14 files, 29
primaries, every one reported by the first compilation, no cascade, every
case clean once fixed -- as before.

## 7. Integration

* **HIR.** No new field, node, side table or registry; the HIR of a program
  differs only where a top-level method call has a candidate whose required
  context trait has several installed providers (decided, or rejected as
  ambiguous, where it was eliminated) -- and in that program's recovered
  diagnostics (section 4.5).
* **Static decisions.** The seeds, cones and channels are unchanged; a
  block's outcome changes only for such a call (it was accepted with the
  eliminating decision, it is now rejected AmbiguousMethodCall or decided).
  `tests/static-economics.test` (87) and `tests/static-compile.test` (83)
  pass.
* **Contexts and context traits.** Installation, satisfaction, selection
  and the monomorphization are unchanged: `tests/contexts.test` (74) and
  `tests/context-traits.test` (40) pass.
* **Compiler service and language server.** They report the strict
  compilation's diagnostics; `-check` on the reproducer reports
  AMBIGUOUS-METHOD-CALL where it reported nothing.
  `tests/compiler-service.test` (54) passes.
* **Front-end cache, interchange, isolation.** No new process state or
  input; `hir/methods.tcl` is part of the front end, so the cache's
  fingerprint changes and entries are rebuilt.
* **Economics.** No new build or decision path: the change only empties
  some candidates' problem sets, which the decision reads exactly as before.
  In the reproducer the formerly mis-decided rows cost what their
  neighbours cost (section 2: 3/1/0/1 and 1/0/0/0, where the base took
  3/1/0/0 and 3/1/1/1); a program in which no candidate's required context
  trait has several providers sees the same problem sets, and so makes the
  same builds and decisions.
* **The whole suite.** `tclsh9.0 tests/local.tcl -jobs 3` (every Tcl test
  file on interp and compile, every golden suite on all four backends,
  through an empty front-end cache): Tcl tests 7,326 passed on interp and
  7,321 on compile, 0 failed; 108 golden suites, 0 failed (interp 5,180,
  compile 5,180, cranelift-generic 5,088, cranelift 5,190 tests passed);
  3,734 s, beside the mutation runs. The files this milestone touches, run
  on their own: method-resolution (26), method-filter (35), method-sugar
  (126), static-economics (87), static-compile (83), contexts (74),
  context-traits (40), diagnostic-recovery (52), compiler-service (54), all
  passing; `tools/compilerpedia.tcl check`: 845 topics, 629 examples, 0
  problems.
* **CI on the branch** (commit `21f130de`). `static-decisions` run
  40130448132, dispatched for `contexts.bot` and `modules.bot` (the golden
  suites that report AMBIGUOUS-CONTEXT-IMPLEMENTATION): passed, both
  schedulers agreeing. The Windows workflow (run 40130431297: smoke, root
  plans, the four acceptance shards, the system linker) and the macOS
  workflow (run 40130431314: Linux control, smoke, both acceptance shards,
  the system linker) passed every job. `tests` run 40130445992 (dispatched):
  passed every job -- the warning gate, the four golden shards, interp,
  compile, cranelift and cranelift-generic coverage, the native Rust tests,
  the stub- and system-linked executables, and the method-call job:
  method-resolution (26) and method-filter (35), the oracle on 500 seeds
  (2,682 calls, 0 disagreements) and on 300 with `-contexts 1` (1,714 calls,
  159 accepted / 441 rejected, 21 of them by an obligation, 0
  disagreements), the fuzzer on 20 seeds (0 disagreements), and the 25
  method-deciding golden suites under the reference audit, which make 140
  builds, 33 trial builds, 3 single deviations and 7 final rebuilds:
  exactly METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md's totals (its 7.3),
  so no golden suite's decision or build count moved. (GC stress runs on
  pushes to main only.)

## 8. Documentation

* **LANGUAGE-DESIGN-PRINCIPLES.md** (new): the authoritative statement of
  SFIAE -- name, rule, applicability and obligations, rationale, examples
  (declared errors, context requirements, competing context
  implementations), boundary, future features, where it is enforced. There
  was no document of language-design principles before; Compilerpedia's
  `principle.*` topics are programming practice, not language design.
* **Compilerpedia** `rule.sfiae` (index rules; aliases SFIAE, SFINAE,
  "substitution failure is an error"; a rejected and an accepted example
  over application modules), referenced from `rule.method-resolution` (whose
  rule text now names context obligations), `error.missing-context` and
  `error.ambiguous-context-implementation`.
* **References**: METHOD-SUGAR.md ("Several candidates": a context the
  environment does not provide is no evidence against a candidate),
  CONTEXTS.md ("Method syntax": both context kinds, competing candidates),
  CONTEXT-TRAITS.md (section 4, "Obligations select nothing"),
  METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md (4.1 and 10.1 point here),
  INDEX.md (a "Design principles" section, and this report), the root
  README ("And more"), AGENTS.md ("Method-call decisions": obligations never
  select; "Context traits": selection never by an implementation's own
  requirements).

## 9. Remaining limitations

Deliberately left to later milestones (METHOD-RESOLUTION-CORRECTNESS-
MILESTONE-1.md, section 10):

* **Placeholder diagnostics.** A rejected call stands at a placeholder
  candidate whose obligations are reported with the rejection: the
  ambiguous `7.f()` of section 2 comes with alpha::f's MISSING-CONTEXT or
  AMBIGUOUS-CONTEXT-IMPLEMENTATION. The decision is right; the report is
  noisy (milestone 2, diagnostics). Resolved by
  METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md: the reported program
  resolves a rejected call to no candidate, so `7.f()` reports
  AMBIGUOUS-METHOD-CALL alone.
* **Checks not yet owned, cycles, related locations, candidate
  explanations** -- unchanged.
* **The obligation list is a list of kinds.** SFIAE is enforced by
  classifying diagnostic kinds; a future check that reports an obligation
  under a kind that also reports applicability problems would need a finer
  classification. None exists today (section 4.3).
