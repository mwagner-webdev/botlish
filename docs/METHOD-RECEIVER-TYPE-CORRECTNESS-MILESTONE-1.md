# METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md -- method-style calls enforce their selected callable's parameter contract

Completion report. The HTTP stack census (HTTP-STACK-INTEGRATION-CENSUS.md,
section 17, B11) recorded a method-style call with a statically known,
incompatible receiver that compiled and failed when it ran:

```
import std::mutable_array

fn f(a: List[int]) errors IndexNotFound:
    d = std::mutable_array::create(1, 0)
    d.set(0, a.at(0) - 1)
```

`receiver.name(args)` is ordinary call syntax with the receiver supplied as
the first argument (METHOD-SUGAR.md). This milestone establishes why that
program compiled, fixes the demonstrated cause, and pins the invariant with
adversarial tests and mutants:

> The selected callable determines the contract. Method syntax enforces that
> contract exactly, including its receiver, without diagnostic-driven
> fallback.

The base of every "before" below is `6572767` (main when the milestone
started). The change is on the branch `ccr-a86fc76b-n9xo1z`.

## Contents

1. Result
2. The original reproducer
3. Root cause
4. The method-resolution contract: no SFINAE
5. Typing behavior: the rule and ordinary-call equivalence
6. Generic receivers and `any`
7. Implementation
8. Diagnostics and recovery
9. Cross-backend and compiler-service evidence
10. Mutation evidence
11. Regression results
12. Remaining limitations

## 1. Result

**Fixed.** The defect was not in method syntax: it was the ordinary call's.
A call of a native (an intrinsic or an operator) did not hold its arguments
to the kinds the native's parameters require (`-param-types`), by design --
"a native's argument kinds are checked at run time" -- so `a.at(0)` and
`std::mutable_array::at(a, 0)` both compiled for a `List[int]` `a`, and both
raised the native's run-time TYPE error on every backend. The method spelling
was exactly as wrong as the ordinary one; it had no separate path to fix.

Now the call's own check rejects an argument whose type is statically of a
known kind other than the one the native's parameter requires, for every
argument of every native call the program writes, in every spelling (where
a more specific check already held an argument statically -- a C call's,
a layout operation's, a mutation's place check -- that check keeps it,
section 7):

```
method-at-list.bot:15:14: argument 1 of native std::mutable_array::at requires
mutarray, but the receiver has type List[int]: the call could only fail when
it runs (CORE SEMANTIC TYPE)
```

* The original misuse is rejected at compile time, before any backend runs,
  on all four, and through the compiler service (section 9).
* A valid MutableArray receiver compiles and runs as before.
* The method spelling and the ordinary spelling report the same diagnostic at
  the same argument, with the call as its subject; only the wording names the
  receiver as the receiver (section 5).
* Generic functions are checked against their declared or inferred contracts,
  never against an instantiation: an untyped parameter by its checked
  contract (unchanged), an imprint variable `T` as what it is -- any `T` --
  so `b.v.at(0)` on a `Box[T]` slot is rejected at the definition (new;
  section 6).
* `any` stays dynamic: an argument of type `any` reaches the native's
  run-time check exactly as before (section 6).
* No candidate selection changed: the method decision's one native-specific
  rule (`hir::methods::CallProblems` adding the kind mismatch to a
  candidate's problems) is removed, because the call's own diagnostic now
  carries it; no candidate is added, ranked or retried (section 4).
* Errors, yields, coroutine protocols, affine moves and context requirements
  are unchanged (the regression tests' `mrt-affine-*`, `mrt-context-*`,
  `mrt-error-*`; the suites of section 11).

## 2. The original reproducer

`audit/http-stack/repro/method-at-list.bot`, on `6572767`:

```
$ tclsh9.0 main.tcl -backend interp audit/http-stack/repro/method-at-list.bot
== method-at-list.bot (interp)
   error: std::mutable_array::at: expected mutarray, got [1, 2] (CORE SEMANTIC TYPE)
```

and the same error on `compile`, `cranelift-generic` and `cranelift`. The
compiler reported nothing: the strict HIR had no diagnostic.

**The selected callable.** With only `std::mutable_array` imported, the one
visible function named `at` is the intrinsic `std::mutable_array::at`
(`mutarray int -> any`; `std::list::at` exists but is not imported, so it is
no candidate: METHOD-SUGAR.md, "What visible means"). The call has one
candidate, so there is no method decision (`methodCalls` is empty): resolution
rewrites it to the ordinary call.

**The HIR.** The method spelling and the ordinary spelling compile to the
same call node -- callee a reference to the root native, target
`{native std::mutable_array::at}`, two arguments, the receiver a reference of
static type `List[int]` -- differing only in the front end's provenance
marker `written` (`{form method}` against `{form function}`), which only
diagnostics read. With zero diagnostics in both:

```
a.at(0)                       target native y1  written form method    receiver type {list int}  diagnostics 0
std::mutable_array::at(a, 0)  target native y1  written form function  receiver type {list int}  diagnostics 0
```

**The verdict depended on how many functions named `at` were visible.** On
the base, with the same function body:

| imports | outcome on `6572767` | now |
|---|---|---|
| `std::mutable_array` | compiles; run-time TYPE | TYPE at 4:5 (compile time) |
| `std::mutable_array`, `std::mutable_vector` | NO-APPLICABLE-METHOD (each rejects the receiver) | NO-APPLICABLE-METHOD (each candidate's own TYPE) |
| `std::mutable_array`, `std::list` | `std::list::at`, runs | unchanged |

A program was rejected for a List receiver when two wrong functions named
`at` were visible, and accepted when one was.

**After.** Rejected at compile time with the one diagnostic of section 1, at
the receiver (15:14), on every backend, before running
(`mrt-reproducer-rejected`, `-strict`, `-every-backend`,
`-compiler-service`).

## 3. Root cause

The call was traced through each stage:

1. **Parsing and resolution** (`hir/resolve.tcl`'s `MethodCandidates`): the
   candidate set is `{std::mutable_array::at}` -- correct under the
   visibility rules (an import makes exactly that namespace's members
   candidates). *Not class A*: no wrong candidate was selected.
2. **The ordinary-call equivalent**: built, and identical to the ordinary
   call (section 2). No separate method path exists to omit anything.
3. **The receiver's static type**: `List[int]`, from the declared parameter,
   in the generic typing walk; generic inference or specialization changes
   nothing (a declared parameter is its contract).
4. **The call's own check** (`hir::range::VerifyCallChecks`, inside
   `hir::CheckingCall`): for a native target it checked a MutableArray's
   element contract, hashing, foreign contracts, imprinted parameter types,
   C pointers and layout writes -- and stated, in its comment, "A native's
   parameter types are run-time-checked kind requirements". The receiver was
   never held to `mutarray`. **This is the defect: class B, callable typing,
   shared by every native call.**
5. **Diagnostics**: none was produced, so none was lost. *Not class C.*
6. **Every backend**: lowered the call as written and reached the native's
   own run-time kind check (`core::value::expect` on the Tcl backends, the
   runtime's on native), the first place the omission became observable.

**The earliest stage with enough information** is the generic typing walk
(`hir::types::Call`), where the argument types and the native's
`-param-types` are both known; its check is `hir::range::VerifyCall`. Why
nothing rejected there was a documented decision, not an oversight in one
place: Compilerpedia's error.type said "A direct call of an intrinsic or
operator is not rejected at compile time for an argument of the wrong kind
(`1 + "a"` compiles)". Yet the compiler already *knew* the call could only
fail, in three places, each of which used the knowledge for something else:

* region inference (`hir::specialize`) typed such a call `never` ("the
  argument is statically of another kind: the call always raises TYPE");
* the method decision added the mismatch to a candidate's problems
  (`hir::methods::CallProblems`: "not diagnosed at compile time ... but it
  is plainly not the function the method-style call means when another
  candidate accepts the receiver") -- consulted only for calls with several
  candidates, hence section 2's table;
* a *wrapper* of the native was stricter than the native: an untyped
  parameter's checked contract, inferred from the native's `-param-types`,
  rejects an argument of a statically known inadmissible type at the call
  ("the deliberate strengthening: `wrapper(123)` no longer reaches the
  native's run-time TYPE error", hir/signatures.tcl).

So `fn g(x): std::mutable_array::at(x, 0)` called with a List was rejected,
while `std::mutable_array::at(list, 0)` -- and `list.at(0)` -- compiled.

**Scope of the defect.** Every native call with an argument of a known other
kind, not only `std::mutable_array::at` and not only receivers:
`std::str::length([1])`, `std::str::substring("abc", xs, 1)`,
`std::char::scalar_value(65)`, `[1, 2] + 0`, an opaque struct `+ 1`, a
coroutine handle's `.length()`, a MutableMap given to
`std::mutable_array::set`. The fix is therefore the shared one -- the
ordinary call's check -- and never a rule for `at`, for List, for
MutableArray, or for method syntax.

## 4. The method-resolution contract: no SFINAE

Nothing in candidate selection changed, and nothing new consults a failure to
choose:

* **One candidate** (the reproducer): there is no decision. The call is that
  function's; its check fails; the program is rejected. No other function is
  searched (`mrt-no-fallback-single-candidate`: `std::list::at` exists, is not
  imported, and is never reached; `methodCalls` stays empty).
* **An ordinary call** resolves its callee by its one lexical binding, never
  by argument types (`mrt-no-fallback-ordinary-call`: a file's
  `at(s: str, i: int)` called with a List is TYPE, never `std::list::at`).
* **Several visible candidates** are decided by METHOD-SUGAR.md's existing
  rule -- the call is the one candidate whose ordinary call is valid, judged
  by each candidate's own checks relative to the decided program, certified,
  with AMBIGUOUS-METHOD-CALL when more than one is valid and
  NO-APPLICABLE-METHOD when none is (METHOD-RESOLUTION-CORRECTNESS-
  MILESTONE-1.md). That rule already counted a native's kind mismatch
  against a candidate; it now reads it where it reads every other problem,
  the call's own diagnostic, and its private copy of the rule is gone.

**Why that rule is not SFINAE.** SFINAE tries a callable, inspects whatever
failure it produces, and silently moves on to the next callable that happens
to type-check. The method rule differs in each respect that matters:

| | SFINAE (rejected) | the method rule (unchanged) |
|---|---|---|
| candidate set | grows with the search: any function of that name | fixed before typing: the visible functions (lexical names, direct imports) |
| what is read | any diagnostic the attempt produces | the call's own checks against its callee only (`subject`), never a check of its result by its user, never an obligation |
| more than one fits | the first in some order wins | AMBIGUOUS-METHOD-CALL: no precedence of any kind |
| obligations (contexts, errors, direct authority) | a failure moves to another overload | an obligation of the selected call, never evidence against it |
| the outcome | depends on the search order | a property of the program, certified against single deviations (and audited against the reference rule) |

This milestone adds no candidate, no search and no ranking. Its tests
demonstrate the boundary from both sides: candidates whose obligations fail
stay the call (`mrt-context-obligation-never-selects`,
`mrt-error-obligation-never-selects`), two valid candidates are ambiguous
(`mrt-several-candidates-ambiguous`), and the decision is the reference
rule's in every compilation of the test file (each is made under
`hir::methodReferenceAudit`). The mutants `fallback-to-every-namespace` (a
receiver the visible `at` rejects looks up every standard namespace's `at`),
`context-obligation-selects` and `error-obligation-selects` are each killed by
the test that states the rule (section 10).

## 5. Typing behavior: the rule and ordinary-call equivalence

**The rule** (`hir::types::NativeKindMismatch NAME INDEX TYPE`, stated once):
an argument at position INDEX of a call of native NAME whose static TYPE has a
known kind (`hir::types::kindOf`) other than the kind the parameter requires
(`core::type::base` of its `-param-types` entry) is a mismatch; the call can
only raise TYPE when it runs, whatever the value. Nothing is a mismatch for a
parameter that requires no kind (`""`, `any`), for an argument of no fixed
kind (`any`, a structural function type, a trait view, `never`), or past the
native's parameter list. It is the same comparison region inference already
used to type such a call `never`; now that use and the new check ask the one
procedure.

**The check** (`hir::range::VerifyNativeKinds`, the first step of
`VerifyCallChecks` for a native target, inside `hir::CheckingCall`): every
argument of a call the program wrote is held to the rule, each mismatch a TYPE
diagnostic at the argument whose subject is the call. As every check of a
call against its callee, it judges the program as written, reachable or not
(a declared parameter's check reports in dead code too).

**Ordinary-call equivalence.** `receiver.f(x, y)` validates exactly what
`f(receiver, x, y)` validates, because there is one call node and one check.
`mrt-ordinary-call-equivalent` compiles both spellings and compares kind,
location (the first argument), subject (the call) and callee; the messages
are equal after naming: "the receiver" for a method spelling's argument 1,
"this argument" for an ordinary one, "this operand" for an operator's. Later
arguments are the ordinary argument errors in both spellings
(`mrt-later-arguments`: `m.at("x")` and `m.pick("x")`).

**Operators** are calls of natives: `[1, 2] + 0`, `1 - "a"` and an opaque
struct `+ 1` are compile-time TYPE now (`mrt-operators`). Operators a
floating-point operand selected, and `/`, keep their own check
(`hir::operators::verify`, unchanged).

## 6. Generic receivers and `any`

Botlish has no function-side generics (`fn f[T]` does not exist): a generic
function is one with untyped parameters, or with imprint variables
established by applied types (`fn first(b: Box[T])`). Each is checked against
what it declares, never against an instantiation that happens to work.

* **An untyped parameter** imposes, through the native it is given to, a
  *checked* contract (hir/signatures.tcl): its body compiles alone
  (`mrt-generic-untyped-definition`: the contract is `mutarray`), a call with
  a MutableArray runs (`-satisfied`), and a call with a List is rejected at
  the call, once (`-violated`: "argument for parameter "a" is statically
  incompatible with mutarray, the parameter type inferred from the function
  body"). The semantic instance typed under the List does not report the
  body's native a second time: the rule is not applied in an instance's view
  (below).
* **An imprint variable is rigid**: "the body is checked once, for every T"
  (C-ABI-TYPES.md). `b.v.at(0)` with `b: Box[T]` used to compile -- `T` has
  no fixed kind, so it went the `any` way -- and then ran for a
  `Box[MutableArray[int]]` and failed for a `Box[List[int]]`: precisely type
  checking deferred until an instantiation supplied a convenient
  implementation. Now `hir::types::NativeArgumentMismatch` adds the rigid
  variable to the rule: no kind admits every `T`, so the call is rejected at
  the definition, with no call, with a convenient call and with an
  inconvenient one alike (`mrt-generic-imprint-unconstrained`: "argument 1
  of native std::mutable_array::at requires mutarray, but the receiver has
  type T: the function is checked once, for every T, and not every T is a
  mutarray"). A trait constraint names no kind and changes nothing
  (`-trait-constrained`, `T satisfies Hashable`); a native that requires no
  kind (`==`) takes every `T` (`-kind-free-use`). This is the stricter of
  the two statements and is kept apart: region inference, whose types are
  concrete, still asks only "can only fail".
* **A trait view** is typed from its trait alone, as before
  (`mrt-generic-trait-view`): `value.at(0)` with `std::mutable_array::at`
  visible is TRAIT-UNKNOWN-OPERATION, never that function;
  `std::mutable_array::at(value, 0)` is TRAIT-VIEW-MISUSE.

**`any` is intentionally dynamic, and stays so.** A receiver whose static
type is `any` -- a declared `a: any` parameter's value, an element of a
mixed List -- has no fixed kind, so the rule does not apply and the native's
run-time check decides (`mrt-any-receiver-dynamic`: given a MutableArray it
runs, given a List it compiles and fails with the native's own run-time TYPE
error on every backend, in both spellings). Two decisions keep the dynamic
path from contaminating the static one or the other way round:

* the rule is applied to the program *as written* only, never in a semantic
  instance's view (hir/semantic.tcl types a body again under one call's
  argument types: `first([1, 2])` would see `a: List[int]` there and reject
  the `any` call); an argument the program types `any` is the run-time
  check's, and an untyped parameter's caller is held to the checked contract
  instead;
* the rule is never applied to a type that is not known: `any` is no kind
  (`kindOf any` is `""`), so no receiver is rejected for merely not being a
  concrete collection.

## 7. Implementation

Production files:

* **hir/types.tcl** -- `NativeKindMismatch` (the rule, moved here from
  `hir::methods::NativeMismatch` and generalized to every argument position)
  and `NativeArgumentMismatch` (the rule plus the rigid imprint variable).
  In `Call`, a native call whose argument mismatches is dead in the generic
  walk too, not only in region inference: its value is poison (the
  diagnostic exists), so nothing that uses its result is judged again. Not in
  a semantic instance's walk (the rule is the program's as written), nor in a
  program read from core IR text (`MakesPoison`, as for all poison).
* **hir/range.tcl** -- `VerifyNativeKinds`, the check, and
  `NativeArgumentNoun`/`WrittenForm` for the wording. It is scoped to calls
  the program wrote (the front end's `written` marker, which only diagnostics
  read: a call a construct lowers to is that construct's to check, e.g.
  `with context 5` is NOT-A-CONTEXT; core IR text is past the source
  boundary and keeps its run-time semantics). It leaves to the more specific
  check that already reports it:
  - a foreign call (`extern c fn`, `-foreign`): its C signature holds every
    argument (`hir::borrow::VerifyCall`, which also records the refusals an
    unchecked run replays);
  - an imprinted intrinsic: its imprinted parameter types
    (`VerifyImprintedNative`);
  - a binary layout operation (`-layout` role): its operand roles
    (BINARY-OPERAND);
  - a floating-point operator and `/`: `hir::operators::verify`;
  - a mutating collection operation's receiver the place check rejects
    (MUTABLE-PLACE-RECEIVER, `hir::mutvec::RejectsReceiver`) -- and only
    those: a struct the place check cannot judge (a MutableMap given to
    `std::mutable_array::set`) is the kind check's (`mrt-mutation-receiver-
    struct`);
  - a byte owner where a C address is required
    (`hir::borrow::VerifyPointerKinds`), a C address, native view or edit
    where another kind is (`hir::cabi::VerifyCallKinds`), another value
    where a DecimalRounded is (`hir::decimal::verify`).
  Each says more than "another kind" (why an address is no Int, why nothing
  converts to a DecimalRounded), and each keeps its established diagnostic.
* **hir/methods.tcl** -- `CallProblems` no longer adds a native's kind
  mismatch itself (the call's own diagnostic carries it); `NativeMismatch`,
  which the kind proofs (`Excluded`) rule candidates out by, asks
  `hir::types::NativeKindMismatch`. One statement of the rule
  (`mrt-rule-one-statement`, `mf-native-rule-one-statement`).
* **hir/mutvec.tcl** -- `RejectsReceiver`: whether the place check reports a
  receiver (reachable, no element place, a mutating operation, a
  `ReceiverProblem`).

No special case for MutableArray, List, `at` or method syntax; no new
dispatch; no run-time check; no change to trait or context resolution, to
HIR, Core IR, NIR or any backend.

Tests, tools and documents:

* `tests/method-receiver-types.test` (35 tests, census rows in
  `audit/golden/migration/census/method-receiver-types.tsv`).
* `audit/method-receiver-types/tools/mutate.tcl` and `mutants.txt` (section
  10).
* Tests that pinned the old behavior, updated to the new rule (section 11's
  list), with their census, fragment and manifest rows.
* Compilerpedia: error.type (the rule, its wording, an example),
  error.no-applicable-method (a single candidate is checked like any call;
  the explanation's text), proof.types' limitation.
* README.md, METHOD-SUGAR.md, METHOD-DECISION-FILTER.md, STATIC-COMPILE.md,
  HTTP-STACK-INTEGRATION-CENSUS.md (B11 fixed), the reproducer's header.

## 8. Diagnostics and recovery

**The diagnostic** is the ordinary function-argument TYPE, at the argument,
naming the callable, the kind its parameter requires, the argument's type and
why the call is invalid:

```
argument 1 of native std::mutable_array::at requires mutarray, but the receiver has type List[int]: the call could only fail when it runs
argument 2 of native std::mutable_array::at requires int, but this argument has type str: the call could only fail when it runs
argument 1 of native + requires int, but this operand has type List[int]: the call could only fail when it runs
argument 1 of native std::mutable_array::at requires mutarray, but the receiver has type T: the function is checked once, for every T, and not every T is a mutarray
```

"argument N of native F requires K" is the wording a checked contract's
provenance already uses ("inferred from the function body: argument 1 of
native std::mutable_array::at requires mutarray"). No method-specific
diagnostic was introduced; the receiver is named as the receiver because the
call was written that way.

**Recovery.** The rejected call has no value (poison), so its uses do not
restate it: an outer native given its result, a method chain on it, a
declared result (`mrt-recovery-no-cascade`, one diagnostic each); each
independently wrong argument is its own diagnostic (`mrt-independent-
arguments`). Where a more specific check owns the argument (section 7), only
that check reports. With several candidates and none valid, the one
NO-APPLICABLE-METHOD explains each candidate by its own TYPE:

```
method-style call "at": none of the visible functions of that name accepts
the call (std::list::at rejects the receiver: argument 1 of native
std::list::at requires list, but the receiver has type str: the call could
only fail when it runs; std::mutable_array::at rejects the receiver: ...)
```

Diagnostic suppression played no part in the defect (section 3); the
mutants `diagnostic-suppressed` and `subject-lost` show the tests would see
it if it did.

## 9. Cross-backend and compiler-service evidence

* **Rejection before execution, every backend.** `mrt-reproducer-every-
  backend` runs `main.tcl -backend B` on the reproducer for interp, compile,
  cranelift-generic and cranelift: each exits 1 with the compile-time
  diagnostic at 15:14 and never prints the native's run-time "expected
  mutarray" error. The rejection is the front end's, shared by all four; no
  backend has rejection logic of its own.
* **The compiler service** (`mrt-reproducer-compiler-service`): a workspace
  analysis of the reproducer has outcome `semantic` and the one error
  diagnostic `CORE SEMANTIC TYPE` at 15:14-15 with the same message -- the
  ordinary checking path, not only main.tcl's final compilation.
* **Positive execution, every backend** (`sourceAgree`: the four outcomes
  must be equal): a MutableArray receiver in both spellings (`value 37`),
  an untyped parameter given a MutableArray (`value 7`), the decided
  candidates of several-candidate calls (`value 2`, `value 1`), an imprint
  variable's kind-free use (`value true`), a coroutine handle receiver moved
  once (`value [1, 5]`), and the `any` path's run-time TYPE on every backend.

## 10. Mutation evidence

`tclsh9.0 audit/method-receiver-types/tools/mutate.tcl` applies each mutant
of `audit/method-receiver-types/tools/mutants.txt` to a private copy of the
tree and runs `tests/method-receiver-types.test`; a mutant counts as killed
only when one of the tests its `!!` line names fails -- the test that
states the rule it breaks -- so a mutant that breaks the build, or only some
other test, is reported as not killed for its reason.

| mutant | the incorrect implementation | killed by |
|---|---|---|
| `receiver-unchecked` | a native call's first argument is never held to its kind (the census defect, for every call) | `mrt-reproducer-rejected`, `-strict`, `mrt-ordinary-call-equivalent`, `mrt-other-concrete-receivers` |
| `method-receiver-unchecked` | a weaker method-specific path: only a method spelling skips its receiver | `mrt-reproducer-rejected`, `mrt-ordinary-call-equivalent` |
| `diagnostic-suppressed` | the call is still poison but its diagnostic is never reported | `mrt-reproducer-rejected`, `-strict`, `-every-backend`, `-compiler-service` |
| `subject-lost` | the diagnostic is reported but is no call's own (no subject): the decision cannot read it | `mrt-reproducer-rejected`, `mrt-ordinary-call-equivalent`, `mrt-several-candidates-none-applicable`, `mrt-mutation-receiver-struct` |
| `operators-exempt` | a special case: operators left to the run-time check | `mrt-operators` |
| `reachable-only` | dead code, and a call a resolution failure leaves unreachable, unjudged | `mrt-dead-code-checked` |
| `mutation-receivers-all-deferred` | every mutation receiver left to the place check, which cannot judge a struct | `mrt-mutation-receiver-struct` |
| `any-rejected-through-instances` | the rule applied in a semantic instance's view: `any` judged by one caller's type | `mrt-any-receiver-dynamic` |
| `imprint-variable-deferred` | an unconstrained imprint variable treated as `any` (checked against instantiations) | `mrt-generic-imprint-unconstrained`, `mrt-rule-cases` |
| `poison-dropped` | the rejected call keeps its result type: its uses cascade | `mrt-recovery-no-cascade` |
| `equal-kinds-rejected` | the required kind itself reported as a mismatch | `mrt-valid-receiver`, `mrt-generic-untyped-satisfied`, `mrt-rule-cases` |
| `fallback-to-every-namespace` | SFINAE: a method name also looked up among every standard namespace's natives | `mrt-reproducer-rejected`, `mrt-no-fallback-single-candidate` |
| `context-obligation-selects` | a missing context counts against a candidate | `mrt-context-obligation-never-selects` |
| `error-obligation-selects` | an unhandled error counts against a candidate | `mrt-error-obligation-never-selects` |

Every mutant applies exactly once and is killed by a test it names. One
finding of the harness itself: `error-obligation-selects` first removed
UNHANDLED-ERROR from `hir::methods::ObligationKinds` alone and survived --
an equivalent mutant, because a plain call's UNHANDLED-ERROR is reported by
the completion analysis with no subject, so that list entry can never
select; and the test it named was too weak (a literal receiver's error is
ruled out by exact-value narrowing, so no error was unhandled). The mutant
now also makes the unhandled error the call's own problem, the test uses an
Int parameter, and the mutant is killed.

The method decision's own harnesses were brought along: two mutants of
`audit/method-filter/tools/mutate.tcl` (`native-equal-kinds-excluded`,
`native-type-problem-lost`) and one of `audit/method-resolution/tools/
mutants.txt` (`nested-call-problems-charged`) targeted code this milestone
moved; each was updated to the new text, keeping its rule (section 11).

## 11. Regression results

All on the final code, in a 4-core container (`LANG=C.utf8`, Tcl 9.0.1, the
native driver built from this tree). The machine's speed and the session's
2-hour limit on a background command split the whole local run into parts.

| check | command | outcome |
|---|---|---|
| the regression file | `tclsh9.0 tests/method-receiver-types.test` | 35 passed, 0 failed |
| against the base | the same file on `6572767` | 18 failed (every test of the defect), 17 passed (the invariants: `any`, generic contracts, decisions, obligations, affine moves, C calls, METHOD-ELIGIBLE, the place check) |
| Tcl tests, part 1 (the 52 files a first, interrupted run had not reached, and every file this milestone edits) | `tclsh9.0 tests/local.tcl -parts tcl FILES` | interp 1807 passed, compile 1803 passed, 0 failed (warning-gate.test among them: the shipped stdlib, libraries, examples and benchmarks compile as before) |
| golden suites, all 111, four backends | `tclsh9.0 tests/local.tcl -parts golden` | 109 suites passed; 2 failed (below) |
| Tcl tests, part 2 (the other 170 files) and the 2 golden suites | `tclsh9.0 tests/local.tcl FILES SUITES` | 7 tests failed on each backend (below); the 2 suites 195/195 on each backend |
| the 4 files fixed after part 2 | `tclsh9.0 tests/local.tcl -parts tcl FILES` | 64 passed on each backend, 0 failed |
| the golden duplicates local.tcl skips (FROZEN-DUPLICATE-ORACLE: CI runs them) | each file `-match` its manifest names, interp and compile | 266 runs, 4,700 test executions, 0 failed |
| the golden manifest | `tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | no problem (12,021 rows) |
| Compilerpedia | `tclsh9.0 tools/compilerpedia.tcl check` | 1105 topics, 676 examples, 0 problems |
| this milestone's mutants | `tclsh9.0 audit/method-receiver-types/tools/mutate.tcl` | all 14 apply exactly once and are killed by a test their `!!` line names (exit 0) |
| the method decision's mutants this milestone's change moved | `tclsh9.0 audit/method-filter/tools/mutate.tcl 2 'native-*'`; `tclsh9.0 audit/method-resolution/tools/mutate.tcl -only nested-call-problems-charged` | `native-equal-kinds-excluded`, `native-type-problem-lost`, `nested-call-problems-charged`: each applies and is killed by the unit tests |
| the method decision's independent oracle | `tclsh9.0 audit/method-resolution/tools/oracle.tcl 200 1` and with `-contexts 1` | 200 programs, 1128 calls, 0 disagreements; 200 programs, 1202 calls (18 rejected by an obligation), 0 disagreements |
| the kind proofs' fuzzer (decisions under the reference audit) | `tclsh9.0 audit/method-filter/tools/fuzz.tcl 8 1` | 8 programs, 654 audited builds, 0 disagreements |
| the static-decision schedulers' fuzzer | `tclsh9.0 audit/static-decisions/tools/fuzz.tcl -n 4 -seed 17` and `-seed 41` | 120 and 132 sites, 0 failures each |
| diagnostic recovery's corpus | `tclsh9.0 audit/diagnostic-recovery/tools/efficiency.tcl` | 15 files: every known primary reported, no cascade, every case clean once fixed |
| the one-character-literal fuzzer (its catalog of rewrites) | `tclsh9.0 audit/one-char-string-literal/tools/fuzz.tcl 40 1` | 0 failures; a character passed to a native's `str` parameter is now catalogued `rejected/TYPE` |
| the enums fuzzer (its model updated) | `tclsh9.0 audit/enums/tools/fuzz.tcl -n 100 -seed 1000` | case arithmetic and ordering now static TYPE (run-time-rejected 2 -> 0); 46 disagreements, **the same 46 on the base** -- unrelated, below |

**What failed along the way, and why.** Every failure was a test or a
fuzzer model that pinned the old behavior -- a statically wrong native
argument compiling and failing at run time -- or a program that relied on
it; none was a wrong rejection of a valid program:

* pinned the run-time TYPE: `sc-native-type-error-is-runtime` (now
  `-is-static`), `ns-char-scalar-value-is-canonical`,
  `oc-str-native-argument-warns`, `fa-conversion-leftover-native-read-is-a-
  run-time-error` (a GAP, now `-is-a-type-error`), `ic-native-direct-
  unchanged` (now `-static`), `mutarray-arg-1`, `char-scalar-value-static-
  contract`, `enum-principal-rejections`, `enum-arithmetic-rejected`,
  `enum-ordering-rejected`, `abi-numeric-not-arithmetic`,
  `abi-numeric-collections-stay-int`, `linux-syscall-register64-is-transport-
  not-arithmetic`, `str-append-char-type-*`, and their golden ports where
  they have one;
* needed a value only the run-time check sees (now an `any`): `opaque-print-
  runtime-errors-all-backends`, `opaque-print-ordinary-struct-error-
  unchanged`, `gf-registration-would-abort`, `gf-runtime-only-failure-aborts`,
  `opt-tail-7`, `str-append-char-type-dynamic`, `hir-specialize-11` (an
  untyped parameter), `hir-aot-12` (core IR);
* carried a wrong expression the test did not care about:
  `vt-gc-frontier-strings` (a never-called String added to an Int),
  `imports-root-primitives-need-no-import` (`[1, 2] + 0`),
  `loop-interval-lockstep` (a U8 added to an Int);
* reported one more independent error, correctly: `sr-strict-unchanged`
  (`1 + "s"` beside a syntax error);
* stated the method decision's removed rule: `mf-native-rule-one-statement`,
  `mr-diag-candidate-explanations` (the explanation's text),
  `mf-never-receiver-is-not-guessed` (its `never` receiver came from the
  now-rejected call: `mf-poisoned-call-narrows-nothing`);
* the place check's, the context check's, the layout checks' and the
  decimal check's established diagnostics, which the first version of the
  check preceded or duplicated (`ma-place-receiver/not-an-array`,
  `contexts-not-a-context-install`, `ne-not-a-pointer`,
  `ne-write-diagnostics`, the DecimalRounded Compilerpedia example) -- the
  deferrals of section 7;
* the two golden suites of the part-2 failures: shortening a test moved the
  lines that `rejects_at` and the `sc-diag-exact-*` values pin; the comments
  now keep every later line where it was;
* the enums fuzzer's model (`audit/enums/tools/fuzz.tcl`: case arithmetic
  and ordering are TYPE at compile time now).

**An unrelated mainline failure.** `audit/enums/tools/fuzz.tcl -n 100 -seed
1000` reports 46 disagreements on `6572767` too: its programs `import fz`
and are compiled from text, which has no application root since
application modules (IMPORTS.md), so the compiler rejects them with
UNKNOWN-NAMESPACE where the model predicts each program's own fault (the
first: program 1001, the oracle expecting TYPE). The fuzzer, not the
compiler, is out of date; this milestone does not touch it beyond the model
of case arithmetic and ordering.

**In CI.** The sequential-scheduler comparison of the golden suites
(`audit/static-decisions/tools/compare.tcl`) runs in CI only (AGENTS.md):
the `static-decisions` workflow was dispatched on the branch, and so was
`tests.yml` (the whole Tcl suite with its duplicates on interp and compile,
the cranelift coverage, the golden suites beside their Tcl originals, the
method-call decision's oracle under the reference audit; the GC-stress job
runs on pushes to main). Both ran on `9d6ca0b` (the final code: the commits
after it change only this report) and passed: `tests.yml` run 41156803237
and `static-decisions.yml` run 41156805434, every job successful (no
`DISAGREE`, no `DOES NOT COMPILE`).

## 12. Remaining limitations

Concrete, independently reproducible issues only:

* **An `if` condition statically of another kind than Bool compiles and
  fails when it runs.** The same gap for a construct that is not a call:

  ```
  fn f(a: List[int]) -> int:
      if a:
          1
      else:
          2

  f([1])
  ```

  is accepted and raises `if condition must be a Boolean, got [1] (CORE
  SEMANTIC NOT-BOOLEAN)` on every backend (checked on interp and cranelift).
  An untyped parameter used as a condition already gets a checked `bool`
  contract (hir/signatures.tcl), as a native's argument did before this
  milestone; the condition itself is not held to it. It is no call, so it is
  outside this milestone; the fix would be the same shape (the condition's
  own check, the value poison, `any` dynamic).

Not limitations, but boundaries this milestone keeps on purpose (section 6,
7): an argument of type `any` is checked when the call runs; core IR text,
which has no declarations, keeps its run-time semantics (a strict core IR
build is not held to the kinds); a call a construct lowers to is checked by
that construct (`with context 5` is NOT-A-CONTEXT).
