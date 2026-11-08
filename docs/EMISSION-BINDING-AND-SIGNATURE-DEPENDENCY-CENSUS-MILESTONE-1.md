# Emission binding and signature dependency census, milestone 1

A census of what the emission checker (`hir/emission.tcl`) depends on when a
claimed function reads a value, a binding or a callable signature whose
declaration holds an unresolved name, a diagnosed expression or a syntax
hole. It follows EMISSION-CALLEE-DEPENDENCY-CORRECTNESS-MILESTONE-1.md,
whose section 17 left two questions open: binding provenance and signature
provenance.

The census answers both, and finds that neither is where the soundness
problem is. **It found two accepted-program soundness failures** -- programs
the compiler accepts, with a certificate for a function whose run yields a
symbol the recognizer rejects, on every backend. Neither involves a
diagnosed declaration:

* **Function identity.** The certificate memo, the per-compilation
  certificate table and the fingerprint validation all identify a function
  by its bare binding name. Two functions of one name in different lexical
  scopes share a certificate (section 15.3).
* **The empty environment.** `hir::emission::Facts` returns the walk's
  environment for a feasible branch and `""` for an infeasible one. An
  empty environment *is* `""`, so in a function with no parameters and
  nothing bound yet, every `if` is taken as infeasible on both sides, and
  the walk ends there (section 13.4).

The binding and signature cases are rejected programs only: wrong verdicts
(class A), one certificate that relies on a recovery placeholder's `never`
(and its memo transition, a class B confined to rejected programs), and no
false certificate in an accepted program.

No production code changes here. The corrections are prototyped, measured
and recorded in `audit/emission-dependencies/prototype/corrections.patch`
for a separate implementation milestone (section 21). The census itself is
`audit/emission-dependencies/`: a corpus of paired programs and a tool that
reproduces every observation in this report (`results/census.md`).

1. [Result and executive conclusion](#1-result-and-executive-conclusion)
2. [The two original binding reproducers](#2-the-two-original-binding-reproducers)
3. [HIR representation of bindings and declaration references](#3-hir-representation-of-bindings-and-declaration-references)
4. [Diagnostic provenance and ownership](#4-diagnostic-provenance-and-ownership)
5. [Value facts versus value provenance](#5-value-facts-versus-value-provenance)
6. [Module and local bindings](#6-module-and-local-bindings)
7. [Captured bindings](#7-captured-bindings)
8. [Callable-value bindings](#8-callable-value-bindings)
9. [Parameter and result declarations](#9-parameter-and-result-declarations)
10. [Declared errors and completion assumptions](#10-declared-errors-and-completion-assumptions)
11. [`never` and recovery-derived noncompletion](#11-never-and-recovery-derived-noncompletion)
12. [Coroutine and trait-call signatures](#12-coroutine-and-trait-call-signatures)
13. [Direct and transitive dependency graphs](#13-direct-and-transitive-dependency-graphs)
14. [Existing `children` and `reads` coverage](#14-existing-children-and-reads-coverage)
15. [Certificate fingerprints and memo transitions](#15-certificate-fingerprints-and-memo-transitions)
16. [HIR interchange and compiler-service behavior](#16-hir-interchange-and-compiler-service-behavior)
17. [Static compile and syntax recovery](#17-static-compile-and-syntax-recovery)
18. [Other static analyses' handling of declaration provenance](#18-other-static-analyses-handling-of-declaration-provenance)
19. [Classification of confirmed defects](#19-classification-of-confirmed-defects)
20. [Correctly handled cases and non-defects](#20-correctly-handled-cases-and-non-defects)
21. [Recommended minimal corrections](#21-recommended-minimal-corrections)
22. [Regression and mutation plan](#22-regression-and-mutation-plan)
23. [Expected implementation costs](#23-expected-implementation-costs)
24. [Remaining uncertainty and next milestone](#24-remaining-uncertainty-and-next-milestone)
25. [Final evaluation questions](#25-final-evaluation-questions)

## 1. Result and executive conclusion

**Accepted programs with false certificates (class C).** Four, each run with
its claims erased on interp, compile, cranelift-generic and cranelift, its
trace judged by the reference interpreter (tests/dfa-support.tcl):

| case | what it is | strict | trace | judged |
|---|---|---|---|---|
| N2 | a top-level `emitter` and a nested `emitter`, both claiming `digit_token`; the nested one yields `'A'` | accepted | `[65]` | invalid |
| N4b (sequence) | an edit to one of two same-named nested helpers, compiled after the unedited program in one process | accepted | `[65]` | invalid |
| F1 | a parameterless claimed function whose first statement is `if flip(): yield 65 else: yield 66` | accepted | `[65]` | invalid |
| F3 | a claimed function calling a parameterless helper `if true: yield 65` | accepted | `[65]` | invalid |

The defects have been present since the checker was integrated (46ff149,
2026-11-02). They went unnoticed because the workloads never meet their
preconditions: the JSON and CSV emitters have no duplicate function names,
and no walk of theirs ever reaches an `if` with an empty environment
(section 23). Every function the fuzzer and the loop differential generate,
helper or claimed, takes parameters and has a name of its own
(`audit/emission-claims/tools/fuzz.tcl`, `loops.tcl`).

**Binding provenance.** A placeholder can only reach a claim's facts as
*top*. A binding whose initializer is an unresolved name's `never` is left
untyped (`any`). A TYPE-diagnosed initializer poisons its binding, and its
references are then poison (the claim is already `dependent`). An exact
value is never derived through an unresolved reference. So binding
provenance produces wrong *rejections* (class A, ten cases), never a false
proof. The one exception is a structural function type whose result is a
placeholder's `never`: the walk ends at the call (V2), reading nothing.

**Signature provenance.** An unresolved parameter type, result type or
error is represented exactly like an omitted one: `{}`, plus a diagnostic
on the function block. The walk treats an omitted component conservatively
(top, may fail) or replaces it with the clean body's genuine facts. A body
that is not clean is read and tainted. So signature diagnostics give wrong
or repair-unstable verdicts in rejected programs (class A or undecided),
never a false proof.

**What the existing machinery already does.** Most of the needed provenance
already exists:

* poison carries TYPE diagnostics through bindings (`hir::types::Bind`);
* the walk's taint carries what it reads (`Taint`, the summaries' `reads`);
* fingerprints carry a non-local binding's exact Int value and type facts,
  and every node's reachability;
* recovery's unit graph (`hir::recovery::Tainted`) carries resolution
  failures from unit to unit.

What is missing is narrow: the identity of a function (it is a name), the
feasibility of a branch (it is a value), and, for rejected programs, a link
from a binding's facts to the unit graph.

**Recommendation.** One correction milestone, in priority order:

1. **identity** (class C): a name bound by more than one function block of
   the compilation identifies nothing: no memo reuse or storage, no
   composition, no validation by it;
2. **feasibility** (class C): `Facts` answers a feasibility flag beside the
   environment;
3. **binding provenance** (class A, and V2's class B): a non-local value
   binding whose facts were derived from code holding a diagnostic makes
   the walk tainted, as poison already does. No memo reuse in a
   compilation where that can happen.

Prototyped together on this commit, the three keep every emission test
(110 of 110) and CSV test (36 of 36) passing, and the output of the
census, the fuzzer and the loop differential identical apart from timings.
They also keep the JSON and CSV summary counts and the checker's time
within noise. They remove all four false certificates, close 17 of the 20
open cases that have an appropriate verdict (B2b, S1 and K1 are left), and
decide three of the six undecided ones `dependent`. They add no HIR field,
no dependency graph, no diagnostic and no certificate format.

## 2. The two original binding reproducers

**R1, `k = missing()` read as `yield 48 + k`.** Reproduced as the previous
report recorded it:

* the UNBOUND's `expr` is the reference `missing` (e39), which is not
  poisoned;
* `k`'s bind (e37, value e38) is reachable, `k` is typed `any` with no
  exact value, and the reference to `k` (e47) is typed `any`;
* the walk reads `k` through `RefValue`: not in its environment, no exact
  Int, so `TypeValue any` = `*`. `48 + *` is every Int, and the yield is
  EMIT-END-SYMBOL (it may be -1) and EMIT-REJECTED;
* the summary has no children, no reads and no taint, so the verdict is
  `rejected`, with no certificate;
* recovery reports UNBOUND only: the emitter's unit refers to `k`, which
  the tainted unit `k = missing()` declares;
* the service's hover says "rejected -- the analysis found a trace the
  recognizer does not accept (see its diagnostics)", while no such
  diagnostic is shown.

This is a wrong verdict in a rejected program (class A): the rejection is
conditioned on a placeholder.

**R2, `f = missing` called as the statement `f()`.** The previous report's
section 17 said R2 behaves like R1. On this commit it does not: R2 is
`proven`, with a certificate depending on `emitter` alone. The trace is
`f()` (a failure point at `start`, no yield) then `yield 49`. A call through
a value yields nothing (a function that may yield never becomes a value,
COROUTINES.md) and may fail, which the walk records. That holds for every
value `f` could have, so the proof assumes nothing about `f`'s declaration
and the certificate is true of every repair (class E). The variant that
behaves like R1 is B2b, `yield 48 + f()`: the call's value is `*`, and the
claim is rejected (class A).

So the two reproducers are not the same finding: R1 is a placeholder fact
used, R2 a declaration not used.

## 3. HIR representation of bindings and declaration references

| thing | representation (on this commit) |
|---|---|
| binding | `bindings BID {kind local\|param\|root\|ambient name NAME scope SID declaredBy EID type TID}`; a module binding and a function's local are both `local`, told apart by their scope |
| declaration | the `bind` expression `declaredBy` names: `{binding BID value EID duplicate 0}`; a function is a `bind` whose value is a `block` |
| reference | `ref {binding BID name NAME}`; an unresolved one has `binding ""` and is typed `never` (`hir::types::Expr`) |
| a value's type | `hir::bindingType`: what `Bind` set (`hir/types.tcl:5147`), or `any` when it set nothing |
| exact value | not stored: `hir::exact::BindingIntOf` derives it on demand from the `bind`'s value |
| function signature | the block's `declaredParamTypes`, `declaredResult`, `declaredErrors`, `declaredResume`, `emits`; an unresolved component is `{}`, which is also what an omitted one is (`hir/resolve.tcl:1220-1410`) |
| poison | `poisoned` holds both expressions and bindings |
| syntax holes | `syntax#hole` references; references whose binding a hole may change are in `syntaxDependent` |
| diagnostics | `diagnostics`: `{kind expr origin message ...}`; `resolutionDiagnostics` holds the resolution phase's, which recovery's unit graph reads |

The table answers the starting point's question directly: a diagnosed
declaration is *not* necessarily a poisoned expression.

* An UNBOUND is a `never` reference with a diagnostic on it.
* A bind of a non-poisoned `never` returns `never` and leaves its binding
  untyped (`hir/types.tcl:5170`). A module or function sequence then stops
  at it (`Halts`), so what follows is `reachable 0` to inference.
* A bind of a poisoned value poisons the binding (`hir/types.tcl:5160-5168`).
* A signature diagnostic is a diagnostic on the block, and the component is
  `{}`.

## 4. Diagnostic provenance and ownership

Where each kind of diagnosed code leaves its mark, and what follows it to a
reader:

| diagnosed code | `expr` of the diagnostic | carried to a reference by | resolution? |
|---|---|---|---|
| an unresolved name (UNBOUND) | the reference | nothing: the reference is `never`, the binding `any` | yes |
| a TYPE in an initializer | the operand or call | poison: the binding and every reference to it | no |
| a syntax hole | the hole | poison and `syntaxDependent` | (SYNTAX-HOLE) |
| an unknown parameter, result or error type, a duplicate parameter | the function block | nothing: the component is `{}` | yes |
| an unhandled error, a known error (completion) | the `fail` or the call | nothing | no |
| a rejected `static compile:` block in value position | the block (UNHANDLED-ERROR when nothing handles the reified CompilerError) | nothing | yes |
| a trait requirement's unknown type | -- | -- (raised: the build stops, no HIR) | -- |

Recovery's unit graph (`hir/recovery.tcl:144`, DIAGNOSTIC-RECOVERY.md) is
the one dependency structure that follows a resolution failure past the
expression it is located at. A *unit* is a top-level expression. It is
tainted when a resolution diagnostic is located in it, or when it refers to
a binding a tainted unit declares, transitively. `reported` withholds the
check diagnostics of tainted units. Its granularity is the unit: every
module binding's statement is one, but a nested function is part of its
enclosing function's unit.

The emission walk's own dependency is finer: an expression it reads
(`Taint`, `hir/emission.tcl:850`). So the two can disagree, and the census
shows both directions:

* the walk can find a claim `proven` in a unit recovery taints. This is
  correct where the walk does not read the diagnosed code (ec-callee-
  unreachable, Z1, B8e);
* the walk can find a claim `rejected` in a unit recovery taints *because*
  of what it read from the tainted unit (R1, and every class A row of
  sections 6-9). Recovery then withholds the EMIT diagnostics, but the
  record and the hover say `rejected`.

Location is not provenance. A diagnostic can be outside the claimed
function and still supply its fact (R1), or inside the enclosing function
and supply nothing (B8e: the captured `k = 1` beside an unrelated
`missing()`).

## 5. Value facts versus value provenance

What the walk reads of a value, all of it from `hir/emission.tcl`:

| reader | fact | from |
|---|---|---|
| `RefValue` (952) | a local the walk bound | the walk's own environment |
| | a non-local binding | `hir::exact::BindingIntOf` (an exact Int), else `TypeValue` of the reference's static type |
| `EvalCall` (972) | a call's result | the callee's summary met with the call's type, or the call's type alone (a value call, a guard, a native) |
| | whether the call returns | the call's static type being `never` |
| `Facts` (1342) | branch feasibility | `hir::types::KnownOutcome` (a call's `known`, an exact Boolean) and the walk's own comparisons over `hir::range::Paths` |
| `Walk` (743) | parameters | the call's argument facts met with the declared parameter types |
| `Declared` (430) | the claimed function's parameters | the declared types alone (`*` when undeclared) |
| `BlockMayFail` (1082) | whether a non-yielding call fails | the callee's declared errors and declared result |

Two observations decide the soundness question.

**A placeholder is top.** An unresolved name's value never reaches a
binding as anything narrower than `*`:

* its bind leaves the binding `any`;
* `hir::exact` follows no unresolved reference ("forgotten at: an unknown
  or user call ... any expression the rules above do not follow",
  `hir/exactvalue.tcl`);
* a poisoned one is poison.

The facts of top are every value, so they can make a claim `rejected` or
`not-proved` but never `proven`. Provenance matters for the *verdict's
honesty* in rejected programs, and for no accepted program.

**`never` is bottom.** Where `never` comes from code the front end could
not establish, the walk believes in no completion that the code does not
describe. The previous milestone closed this for calls of a named function
and for a function block whose result is `never` (`Read`). One route
remains, a structural function type (section 8).

Provenance that is genuinely independent of the diagnostic still exists:

* an exact value both of whose branches agree, its condition unresolved
  (B3);
* a dead branch (B3b);
* a declared result type over a diagnosed body (B5: the binding's type is the
  declaration's; X4, which calls the function itself, reads its body and is
  dependent);
* a narrowing the claim does itself (G1).

The census classifies B3 and G1 as undecided (section 6), and B3b and B5
as correct.

## 6. Module and local bindings

| case | diagnostic source | fact used | verdict | appropriate | certificate dependency | finding |
|---|---|---|---|---|---|---|
| R1 | `k = missing()` | `k`'s type `any` | rejected | dependent | -- | A |
| R1v | none (`k = 1`) | exact 1 | proven+ | proven+ | `emitter` (whose text records `k` by name, exact value 1 and its type's facts) | E |
| B3 | `k = if missing(): 1 else: 1` | exact 1 (both branches) | proven+ | undecided | `emitter` | U |
| B3b | `k = if true: 1 else: missing()` | exact 1 (dead branch) | proven+ | proven+ | `emitter` | E |
| B3c | `k = if missing(): 1 else: 2` | `any` | rejected | dependent | -- | A |
| B4 | `k = 1 + "x"` (TYPE) | poison | dependent | dependent | -- | E |
| B5 | `fn helper() -> Digit: missing()`; `k = helper()` | `Digit` (the declaration) | proven+ | proven+ | `emitter` | E |
| B6 | `fn helper(): missing()`; `k = helper()` | `any` (the bind of a placeholder `never`) | rejected | dependent | -- | A |
| D1 | `{k, j} = missing()` | `any` | rejected | dependent | -- | A |
| D2 | `p = P {k: 1, j: missing()}`; `{k, j} = p` | `any` (unreachable bind) | rejected | dependent | -- | A |
| G1 | `k = missing()`; the claim guards `k` itself | `*` narrowed by its own comparisons | proven+ | undecided | `emitter` | U |
| Z1 | an unrelated `z = missing()` | none | proven+ | proven+ | `emitter` | E |
| B7 | a local of the claimed function, `k = missing()` | read by the walk: tainted | dependent | dependent | -- | E |

`+`: the record holds a certificate. Every row's strict compilation is
rejected, except R1v (accepted).

**Undecided, B3 and G1.** Both proofs are true of every repair.

* B3's exact value does not depend on the unresolved condition: either it
  completes and `k` is 1, or it fails and nothing reads `k`.
* G1's proof uses nothing of `k` but its being an Int where an order
  comparison completed.

Making them `dependent` matches the granularity the checker already uses
for a claim's own code. ec-recovery-dependent makes a claim dependent on
any reachable diagnosed expression its walk reads, whether or not the
trace depends on it. Keeping them `proven` matches the principle that a
proof is independent of what it does not use. The prototype of section 21
makes them dependent, because telling the two apart needs a counterfactual
(would a narrower fact have changed the verdict?) that the walk does not
compute. They are rejected programs, so either reading is safe.

## 7. Captured bindings

A nested claimed function reads an enclosing function's local exactly as a
module binding: not in its environment, through its exact Int value and
its static type (`RefValue`). The canonical text records it as `outer NAME
EXACT FACT` (`CanonBinding`, 599). So the nested function is checked from
its declared parameters and the captured value's *type*, never from the
enclosing function's walk facts or its callers'. Caller independence holds
(ec-nested-function; B8c: the captured exact 1 is the one fact, and it is
the binding's own).

| case | diagnostic source | fact used | verdict | appropriate | finding |
|---|---|---|---|---|---|
| B8 | `k = missing()` in the enclosing function | `any` | rejected | dependent | A |
| B8b | `k = if missing(): 1 else: 1` | exact 1 | proven+ | undecided | U |
| B8c | none | exact 1 | proven+ | proven+ | E |
| B8d | `k = 1 + "x"` | poison | dependent | dependent | E |
| B8e | `k = 1`, an unrelated `missing()` later in the enclosing function | exact 1 | proven+ | proven+ | E |
| B8f | `j = missing()`; `k = j` | `any` (unreachable bind) | rejected | dependent | A |

B8e is the case that rules out recovery's unit granularity for captured
values. The enclosing function is one unit, tainted by its `missing()`,
and recovery withholds every check diagnostic of it, the nested claim's
included. But the claim's fact is `k = 1`'s and is genuine.

## 8. Callable-value bindings

How a call through a value is resolved decides what the walk reads:

| case | the value | call's target | what the walk reads | verdict | finding |
|---|---|---|---|---|---|
| R2v | `f = g` | `block g` (an alias: its type names the block) | `g`'s summary | proven+, depends `emitter,g` | E |
| C1 | `fs = [mk]`, `mk` loops; `std::list::at(fs, 0)()` | `block mk` (the element type names it) | `mk` read (never) | proven+, depends `emitter,mk` | E |
| C2 | C1 with `mk`'s body `missing()` | `block mk` | `mk` read: tainted | dependent | E |
| R2 | `f = missing` | none | nothing (a failure point) | proven+ | E |
| B2b | `f = missing`, `yield 48 + f()` | none | the call's type `any` | rejected | A |
| V1 | `f = if pick(): g else: h`, both loop | none: `f` is `fn {args {} return never errors {}}` | the call's type `never`: the walk ends | proven+, depends `emitter` | E |
| V2 | V1 with `g`'s body `missing()` | none | the call's type `never`: the walk ends | proven+, depends `emitter` | A (and B, section 15) |

A function value whose static type names its block (`block EID ...`) gets
that block as its call's target (`hir/types.tcl`, the call's typing). So
aliases, list elements and locals bound from them are all read through the
callee's summary, and the previous milestone's `Read` covers their
`never`. Only a value whose type is a structural `Fn` -- a join of two
function types -- has no target. Its `never` result is the join of its
possible functions' results, and the walk ends at it without reading any of
them. In V1 that is genuine. In V2, `g`'s `never` is an unresolved name's,
and the claim is certified in a rejected program: the never-helper hole of
the previous milestone, through a type instead of a target.

In an accepted program V1's certificate is sound. A value that may yield is
never a function value, and the walk records the call as a failure point.
If `g` or `h` changed so as to return, the join would no longer be `never`,
the call's type fact would change, and so would the fingerprint.

## 9. Parameter and result declarations

An unresolved type in a signature is diagnosed on the function block, and
the component is dropped to `{}`, exactly what an omitted annotation is.
The walk cannot tell "undeclared" from "unresolved" by the value. It could
only tell it from "the block holds a resolution diagnostic", which does not
say which component.

| case | signature component | what the walk does with `{}` | verdict | appropriate | finding |
|---|---|---|---|---|---|
| S1 | the claimed function's parameter `d: Missing`, used | `Declared`: `*` | rejected | dependent | A |
| S1b | the same, unused | -- | proven+ | proven+ | E |
| S1v | `d: Digit` | 0..9 | proven+ | proven+ | E |
| S2 | the claimed function's result `-> Missing` | nothing (a result is no symbol) | proven+ | proven+ | E |
| S4 | a helper's parameter `d: Missing`, called `helper(1)` | no meet with a declared type: the argument's point 1 | proven+ | proven+ | E |
| S4b | the same, called `helper(65)` | 113 | rejected | undecided | U |
| S5 | a helper's result `-> Missing`, body `5` | the result inferred from the body (5); the call may fail (`BlockMayFail`: no declared result) | proven+ | proven+ | E |
| S5b | a helper's result `-> Missing`, body loops | the result inferred `never`, genuine: the walk ends at the call | proven+ | undecided | U |
| S5bv | S5b with `-> unit` | walked past the call (the existing imprecision) | rejected | rejected | D |
| S5c | a helper's result `-> Missing`, body `missing()` | read: tainted | dependent | dependent | E |
| S5d | `k = helper()` of S5's helper | `k`'s inferred `int` | rejected | dependent | A |
| S10 | a helper's parameter `List[Missing]`, unused | -- | proven+ | proven+ | E |

S4b and S5b are undecided because their appropriate verdict depends on the
repair:

* S4b repaired with `d: Digit` is a rejected program (an admission TYPE at
  the call, which would make the claim dependent). Repaired with `d: int`,
  the claim is rejected.
* S5b's helper genuinely never returns, so its certificate is true of the
  code. But repaired with a declared result, the claim is walked past the
  call and rejected (S5bv).

Neither is a false proof. A dropped component can only make the walk use
the caller's facts (a parameter) or the clean body's (a result), and both
are sound. Writing `-> never` is no way around this: `never` has no source
spelling, so `-> never` is itself an unknown result type, dropped and
inferred.

## 10. Declared errors and completion assumptions

`BlockMayFail` decides from the declaration whether a call of a
non-yielding function is a failure point: it declares errors, or it
declares no result. A handler around the call starts in the states of the
failure points. Dropping an unresolved error name can therefore remove a
failure point:

| case | signature | body | verdict | finding |
|---|---|---|---|---|
| S3 | the claimed function `errors Missing` | -- | proven+ (the claim's own errors are not read) | E |
| S6 | a helper `errors Opps` (a typo), body `fail Oops` under a condition; a handler `on Oops: yield 65` | the `fail` is UNHANDLED-ERROR, read: tainted | dependent | E |
| S6b | a helper `errors Missing` only, body `unit`; the same handler | cannot fail: no failure point, the handler never walked | proven+ | U |
| S6c | the valid program (`errors Oops`) | the handler walked | rejected (its `'A'`) | E |
| S11 | `errors Missing` and `fail Missing` two calls down | UNDECLARED-ERROR on the `fail`, read: tainted | dependent | E |

The removal is harmless. A body that can fail with an error its
declaration does not hold is diagnosed *in the body* -- the `fail`, or the
call that propagates it -- and the walk reads a non-yielding helper's body
(`Child`), so the claim is tainted (S6, S11). A body that cannot fail
(S6b) needs no failure point; its verdict is undecided only because the
repair `errors Oops` would make the walk start the handler from a failure
point the code never reaches.

In an accepted program, a non-yielding function whose declaration holds no
error raises no declared error (the completion analysis proves it), and a
run-time failure that no handler can name (RANGE, TYPE) needs no failure
point: its prefix is in `visits`.

## 11. `never` and recovery-derived noncompletion

The five cases the census distinguishes:

| case | where its `never` comes from | does the walk read the code behind it? |
|---|---|---|
| a function that genuinely loops or recurses forever | the inferred result | yes: `Read` (fingerprint, taint), the walk ends |
| an explicit `-> never` | -- | not expressible: `never` is an unknown type (section 9) |
| an inferred `never` because the body calls an unresolved name | the placeholder | yes, for a block target: `Read` taints (the previous milestone) |
| a structural `Fn` type whose result joins to `never` | the joined types | **no**: V1 (genuine), V2 (placeholder) |
| a declared result that did not resolve, so the body's inferred `never` | the body | yes: `Read`; genuine (S5b) or tainted (S5c) |

So the unresolved signature components create no hole analogous to the
never helper. The structural type does, and only in rejected programs
(section 8).

## 12. Coroutine and trait-call signatures

* **Trait requirements.** An unresolved type in a requirement raises in the
  trait registry even in a lenient build: no HIR exists to read. A trait
  operation is EMIT-UNSUPPORTED before anything else (`traitCall`), and a
  trait or context-trait clone is unsupported when walked. So no trait
  signature supplies a trusted fact.
* **Yielding status.** `hir::coroutines::MayYield` is computed from bodies,
  never declared, so no signature component decides it.
* **Constructed coroutines.** A construction's outward type comes from the
  source function's result, so an unresolved result type makes it the
  inferred one. Case K1: `fn src() -> Missing:
  yield 3; 0` and `coroutine {step, first} = src()`, `yield 48 + first`
  is rejected (the outward type is `int`). That is a class A residue no
  correction of section 21 covers: the fact flows through a native's
  result type (`coroutine#start`), not a binding.
* **Helpers' claims.** An `emits` naming an unknown recognizer makes no
  claim: the helper's body is walked (S8, proven). Composition uses only
  proven claims' certificates.

## 13. Direct and transitive dependency graphs

### 13.1 R1 (a binding's fact): where provenance is lost

```
k = missing()             UNBOUND on the ref `missing`       (resolution diagnostic)
  -> bind k: value never  -> Bind sets no type               (provenance lost here)
  -> binding k: any
  -> ref k in emitter     -> RefValue: not in env, no exact  -> TypeValue any = *
  -> 48 + *               -> every Int
  -> yield                -> EMIT-END-SYMBOL, EMIT-REJECTED  (rejected)
  -> recovery             -> emitter's unit refers to k, k's unit tainted: EMIT withheld
```

### 13.2 V2 (a callable's signature): where provenance is lost

```
fn g(): missing()         UNBOUND                            -> g's inferred result never
f = if pick(): g else: h  -> f: fn {return never}            (the join: provenance lost)
emitter: f()              -> call, no target, type never     -> the walk ends, reads nothing
                          -> certificate: depends {emitter}  (g, h not recorded)
```

### 13.3 N1 (identity): where identity is lost

```
outer1.inner (yield 49)   FunctionName "inner"   -> proven; memo {inner digit_token}; byName inner = outer1.inner
outer2.inner (yield 65)   FunctionName "inner"   -> memo hit {inner digit_token}
                          -> Valid: functions {inner FP}: FP(byName inner) = FP(outer1.inner) -> valid
                          -> reused: proven, a false certificate; the program is accepted
```

The bare name loses identity in four places:

* `Reset` keeps the first block of each name in `byName` (224);
* `CheckClaim` keys the memo and `certs` by `{FunctionName RECOGNIZER}`
  (1997, 2078);
* `UsableCertificates` finds a callee's certificate by its name (1711);
* `Certificate` keys its dependencies by name, so two same-named functions
  in one proof record one fingerprint (1760; case N5).

Module functions are qualified (`a::emitter`, `b::emitter`) and never
collide. Every collision is between functions of one file in different
lexical scopes: a top-level and a nested function, two nested ones, or one
shadowing another in a nested block. Hygiene renames none of them.

### 13.4 F1 (the empty environment): where feasibility is lost

```
Walk: env = [dict create] = ""                    (no parameters, nothing bound yet)
EvalIf: Facts(cond, 1) -> a feasible path: result = penv = ""
        `if {$facts eq ""} continue`               (the then-branch skipped as infeasible)
        Facts(cond, 0) -> "" again                 (the else-branch skipped)
        -> no branch: {} {}                        (the walk ends at the if)
-> exits {}: "never completes normally"           -> proven, a vacuous certificate
```

The walk only skips the `if` itself. Whatever precedes it is still checked
(F2's `yield 49`). Every helper without parameters is affected the
same way: its summary has no exits, so its caller's walk ends at the call
(F3). An `if` reached after a `bind` or with a parameter is decided
correctly (F4).

## 14. Existing `children` and `reads` coverage

* **`children`**: summaries whose behavior (exits, visits, failures,
  violations) the proof judges.
* **`reads`**: summaries of code the proof relies on without judging its
  behavior -- a function whose `never` result ends the walk.

Both are *summaries*: a function, an entry state and argument facts. A
binding is no summary:

* it has no entry state and no arguments;
* it is evaluated once, at its declaration, outside every walk;
* its facts reach the walk as a type and an exact value, not as a trace.

So `reads` is not the right representation for binding provenance. A
binding's validity is a property of its declaration's code. The summary
being walked needs only to know whether that code holds what makes it
`dependent`, which is the summary's `tainted` flag, set by a new reader
of the existing kind: `BindingDependent` beside `Taint`, section 21.3.

Nor is `reads` needed for a binding's certificate dependency:

* the claimed function's fingerprint already records every non-local
  binding it reads, by name, exact Int value and type facts;
* it records every expression's type fact and reachability, which is how a
  non-Int exact value that decides a branch is caught (sequence `string`:
  a String binding deciding an `if`, proved again on change).

Sequence `value` confirms it: a binding's value that changes without its
type is reused correctly (MK3 to MK5), and an exact value or a type that
changes is proved again (MK17, K17).

## 15. Certificate fingerprints and memo transitions

### 15.1 What a certificate records

`depends functions` holds the fingerprint of every function in the read
set, keyed by name (`Certificate`, 1749). A fingerprint (`Canon`, 469) is
the code's canonical text:

* node kinds, reachability, type facts, constants and natives;
* callees by name (`fn NAME`);
* non-local bindings by name, exact Int value and type facts;
* declared parameter, result, error and resume types, and the clone
  markers.

It never holds an id or an origin. The memo (`{FUNCTION RECOGNIZER}`)
reuses a certificate when `Valid` (1819) finds every dependency unchanged.

### 15.2 The transitions (sections A to F of the census's brief)

From `results/census.md`'s sequences, one process, the memo kept:

| transition | steps | verdict, reuse | sound? |
|---|---|---|---|
| A, a valid binding becomes invalid | `k = 1`, then `k = missing()` | proven fresh, then rejected fresh (the reference's type fact changed) | yes; the verdict is class A |
| B, invalid becomes valid | then `k = 1` | proven, reused (the code is the first step's) | yes |
| C, the value changes, its type does not | `mk() -> Digit` returning 3, then 5 | proven fresh, then proven reused (the proof read only `Digit`) | yes |
| C, the type or exact value changes | `mk() -> int` 17; `k = 17` | rejected, fresh | yes |
| D, a signature changes under one name | `h(d: Digit)` then `h(d: int)`; `r() -> Digit` then `r() -> Missing` | proven fresh each time (the declared types are in `h`'s and `r`'s fingerprints) | yes |
| E, a body changes, its signature does not | `r() -> Digit` 3, then 4 | proven fresh (the body is in the fingerprint) | yes |
| F, an unrelated declaration changes | `z = 1` added | proven, reused | yes |
| F', an unrelated module binding becomes unresolved | `z = missing()` (MZM) | proven, fresh (not reused: a halting statement makes every later declaration `reachable 0`, which the fingerprint records) | yes; a lost reuse |
| callable | V1, then V2, then V1 | proven fresh, **proven reused**, proven reused | V2 reused in a rejected program: class B |
| identity | N4a, then N4b | proven fresh, **proven reused** | **no: N4b is accepted and its run yields `'A'`; class C** |

The memo keeps one certificate per name. A step that does not reuse
overwrites the entry (the `signature` sequence proves `MR3` again after
`MRM`).

### 15.3 Identity, the class C

`Valid` validates a dependency by looking its name up in this
compilation's `byName`, which holds the first block of the name. Two
consequences:

* **within one compilation (N1, N2, N3)**: the first same-named claim is
  proven and memoized before the second is checked. The second finds the
  entry, and `Valid` compares the first block's fingerprint with itself.
  The second claim is then certified whatever its code is: proven with the
  memo on, rejected with it off;
* **across compilations (N4a, then N4b)**: a certificate depending on a
  nested helper is validated against another helper of the same name. An
  edit to the helper the claim calls is never seen while the other is
  unchanged.

The outcome of a compilation therefore depends on process history: whether
the memo is on, and which programs this process compiled before. That
contradicts the trust rule that "reuse is process history, never part of
the HIR" (AGENTS.md, Emission claims).

## 16. HIR interchange and compiler-service behavior

**Interchange.** `hir::emission::reverify` re-derives the records by
running `verify` on the decoded HIR, in the reading process, with its
memo. `results/census.md`'s interchange column, decoded with the memo on /
off:

* every case is `kept / kept`, except N1, N2 and N3, which are
  `kept / refused (EMISSION)`. With the memo on, the reader repeats the
  writer's false certificate. With it off, it derives `rejected` and
  refuses the text, so whether interchange text is accepted depends on the
  reader's memo setting;
* F1, F2 and F3 are deterministic, so the reader agrees with the writer and
  keeps the false certificate either way;
* no case loses a dependency in interchange: the reader recomputes
  everything from the HIR. The binding and signature verdicts round-trip
  because they are functions of the HIR.

**The compiler service.** The hover appends `hir::emission::ClaimText` of
the revision's records (`service::Hover`), so it says what the record says:

* for R1, "rejected -- ... (see its diagnostics)", with only UNBOUND
  reported;
* for R2, S5b and V2, "certified" in a rejected revision;
* for N2's nested emitter and F1, "certified" in an accepted one.

The service keeps the process's memo across revisions, so the `identity`
and `callable` sequences are what an editor session does.

## 17. Static compile and syntax recovery

| case | | verdict | finding |
|---|---|---|---|
| SC1 | `k = static compile: missing()` at module level: the reified CompilerError is unhandled (UNHANDLED-ERROR, a resolution diagnostic); `k` is `any` | rejected | A |
| SC2 | a rejected block as a statement, then `k = 1` | proven+ | E |
| SC3 | an accepted program: the claimed function's own `k = static compile: missing()`, its CompilerError declared | proven+ (the function always fails before its yield) | E |
| H1 | a syntax hole as `k`'s initializer: poison | dependent | E |
| H2 | a hole in an unrelated binding | proven+ | E |

A reified diagnostic does not escape its block: SC2 and SC3 keep their
verdicts. `hir::static::reifiedStatement` lets the walk go on after a
rejected block in statement position, and a block in value position is the
`fail` it reifies. The block's UNBOUND is the block's own and appears in no
claim's taint. Holes behave like TYPE diagnostics (poison).

## 18. Other static analyses' handling of declaration provenance

A limited census, each row a small program with a diagnosed and a valid
variant, outside the corpus (which holds claims only); OA1 to OA3 are
described in the rows:

| analysis | uses a declaration's fact without reading it? | tells incomplete from genuine? | recovery tracks it? | false conclusion possible? |
|---|---|---|---|---|
| type inference | it makes the placeholders: an unresolved reference `never`, its binding `any`, later code unreachable | poison yes; `never` no (DIAGNOSTIC-RECOVERY.md, section 2) | resolution units | missing diagnostics after an unresolved call (incomplete), in rejected programs |
| range and exact facts | a binding's exact value (`if missing(): 5 else: 5` is exactly 5) | no | the unit graph withholds what follows | a genuine KNOWN-ERROR from such a fact is withheld (OA1); nothing accepted |
| completion proofs, KNOWN-ERROR | callees' declared contracts (`EffectiveFacts` falls back to them for an incomplete summary) | -- | -- | not probed beyond OA1 and S6c |
| affine ownership | a binding's type (`c = missing()` is `any`, not affine) | no | unit graph | ownership errors not reported (OA3): incomplete |
| coroutine analysis | `MayYield` from bodies | an unresolved callee is not known to yield | unit graph | a missing UNWRAPPED-YIELD (incomplete) |
| static compile | a block's body reads a binding diagnosed outside it (`k = missing()`, the block `k + "s"`) | -- | the program is rejected; the block's TYPE stays a program diagnostic, withheld | none: the block is not reified while the outside UNBOUND stands; repaired (`k = 1`), it is rejected and reified (OA2) |

The shared weakness is real but benign elsewhere. Every analysis turns a
placeholder into missing or incomplete results, and recovery's unit graph
withholds what they say about dependent units. Only the emission checker
turns a rejected program's facts into *reusable artifacts*: certificates,
the memo, hover text. So a general fact-provenance abstraction is not
justified by what was observed. The emission checker needs only to consult
the provenance recovery already computes.

## 19. Classification of confirmed defects

**Class C, accepted-program unsoundness.**

1. *Function identity by name.*
   * Preconditions: two function blocks of one binding name in one
     compilation (a top-level and a nested one, two nested ones, or a
     shadowing one), the first certified first.
   * Effect: the second claim of the name reuses the first's certificate;
     a certificate's dependency on a function is validated against
     whichever block of its name comes first; and composition finds a
     callee's certificate by name.
   * Counterexamples: N1, N2 (run: `[65]`), N3, sequence `identity` (run:
     `[65]`).
   * Implementation fact: `hir/emission.tcl:224, 1711, 1760, 1828, 1997,
     2078`.
2. *An empty environment read as infeasible.*
   * Preconditions: an `if` reached by a walk whose environment is empty --
     a claimed function or helper without parameters, before any `bind` or
     counted loop.
   * Effect: both branches skipped, the walk ends, a vacuous certificate.
   * Counterexamples: F1 (run `[65]`), F2, F3 (run `[65]`).
   * Implementation fact: `hir/emission.tcl:1392-1398, 1431-1432`.

**Class B, a missing certificate dependency.** V1's certificate relies on
`f()` never returning, but records neither `g` nor `h`. Sequence
`callable`: V2 (`g` now `missing()`) reuses it. This is confined to
rejected programs: in an accepted one, every change that could make `f`
return changes the call's type fact, and with it the fingerprint
(section 8).

The identity defect is also a class B for helpers, across compilations
(N4b); it is listed under C because the resulting program is accepted.

**Class A, a wrong verdict in a rejected program.** These were reproduced:

* placeholder facts used, the verdict `rejected` where `dependent` is
  appropriate: R1, B2b, B3c, B6, D1, D2, B8, B8f, X2, SC1, S1, S5d, K1
  (13);
* a certificate where `dependent` is appropriate: V2.

**Undecided.** B3, B8b, G1, S4b, S5b, S6b (sections 6, 9, 10).

**Class B, also.** N5: one proof reading two nested helpers of one name
records one fingerprint for both (section 13.3). Harmless on its own: the
identity correction refuses to validate an ambiguous name.

**Class D, precision.** S5bv: a helper declared to return whose body loops
is walked past, as recorded before. D2v is another: an exact value
through struct destructuring is not followed, so the valid program is
rejected.

## 20. Correctly handled cases and non-defects

| mechanism | cases | why it is right |
|---|---|---|
| poison through bindings | B4, B8d, H1 | `Bind` poisons a poisoned value's binding; a poisoned reference taints the walk |
| the walk's own taint | B7, C2, S5c, S6, S11, X4 | the diagnosed code is code the walk reads |
| a proof that needs nothing of the value | R2, S1b, S10 | top is every value |
| a declaration's fact over a diagnosed body | B5 | the declared result is a contract, held by every repair |
| a dead branch | B3b | the diagnosed code is no part of the value |
| unrelated diagnostics | Z1, X5, B8e | the walk never reads them |
| reified static blocks | SC2, SC3 | the block's diagnostic is its own |
| caller independence of captured values | B8c, ec-nested-function | a captured value is read through its own type and exact value |
| fingerprints of what the walk reads of a binding | sequences `value` and `string` | name, exact Int, type facts, every node's reachability |
| the claimed function's own result and errors | S2, S3 | a result is no symbol; the claim's errors decide nothing in the walk |

## 21. Recommended minimal corrections

One implementation milestone, three corrections, all in `hir/emission.tcl`.
Prototyped together as `audit/emission-dependencies/prototype/
corrections.patch` (165 lines changed; it applies to c483709). The
prototype is measured below, but it is not production code: the correction
milestone writes it again with its tests and mutants (section 22).

### 21.1 Identity (class C)

A name bound by more than one function block of the compilation identifies
no function. `Reset` records such names (`ambiguous`), and then:

* `UsableCertificates` composes with no certificate of an ambiguous callee
  (its body is walked instead);
* `Valid` refuses a dependency on an ambiguous function or certificate;
* `CheckClaim` neither reuses nor stores a memo entry for a claim whose
  function's name is ambiguous.

This is sound because the memo and composition are optimizations: refusing
them falls back to walking. It costs a reuse only in programs with
duplicate function names, and none of the workloads has one. A finer fix,
a stable lexical identity for nested functions, would keep that reuse. It
would also need an identity that survives edits, which nothing in the HIR
gives today; it is not needed.

Must change: N1, N2, N3 (second claim `rejected`) and the `identity`
sequence (N4b `rejected fresh`). Must keep: every memo test
(ec-memo-reuse, ec-memo-invalidate, ec-callee-memo).

### 21.2 Feasibility (class C)

`Facts` returns `{FEASIBLE ENV}` and `EvalIf` tests the flag:

```tcl
    set result ""
    set any 0
    foreach path [hir::range::Paths $hir $condition $outcome] {
        ...
        if {!$feasible} continue
        if {!$any} {
            set result $penv
            set any 1
        } else {
            set result [JoinEnv $result $penv]
        }
    }
    return [list $any $result]
...
        lassign [Facts $cond $outcome] feasible facts
        if {!$feasible} continue
```

Must change: F1, F2 and F3 rejected. Must keep: F4, and every test.
ec-callee-unreachable's `if false:` stays proven, now with the exit its
empty else-branch has (`exits done`, where it was `exits {}`).

### 21.3 Binding provenance (class A; V2's class B)

`BindingDependent B` decides whether a non-local value binding's facts were
derived from code holding what makes a claim dependent. The binding is
declared by a `bind` whose value is not a block, and one of these holds:

* the binding is poisoned;
* the value is unreachable (the declaration follows code that never
  completes), and recovery's unit graph taints the declaring unit;
* the value's reachable code holds a diagnosed, poisoned or syntax-
  dependent expression;
* the value's reachable code refers to a value binding of which this holds;
* the value's reachable code calls a function whose result is inferred and
  whose code depends on a resolution diagnostic (its unit, for a top-level
  function; its own code, for a nested one).

It is memoized per binding. Two readers use it:

* `RefValue`, when the binding is not in the walk's environment, which is
  exactly when the walk reads a non-local binding's facts;
* `EvalCall`'s `never` branch, for a call through a value with no target:
  V2's structural type.

Both set the summary's `tainted` flag; nothing else is added. A named
function's binding is excluded, because its body is read through its
summary. So is a function with a declared result, whose call's type is
the declaration (B5).

The memo needs one more rule. `CheckClaim` neither reuses nor stores a
certificate in a compilation with resolution diagnostics, poison or syntax-
dependent references -- the only compilations in which `BindingDependent`
can answer 1. Without it the `callable` sequence keeps V1's certificate for
V2: the binding's provenance is no fingerprint a certificate records. An
earlier version of the rule refused reuse in every compilation with a
diagnostic. It changed ec-memo-reuse, whose second program holds an
UNHANDLED-ERROR, which is why the condition is narrowed.

Must change:

* R1, B3c, B6, B8, B8f, D1, D2, X2, SC1, S5d and V2 become `dependent`
  (and the `callable` sequence's V2 `dependent fresh`);
* B3, B8b and G1 become `dependent` too (undecided, section 6).

Must keep: B3b, B5, B8e, Z1, R2, every accepted program, and the
`ec-callee-*` and `ec-recovery-*` tests.

Not covered:

* S1 and S4b (the claimed or called function's own signature) need to know
  which signature component a block's diagnostic is about, which the HIR
  does not record (section 9);
* B2b (a value call whose result is used, not `never`) would need the
  callee's provenance asked at every value call, which makes R2 dependent
  too: the counterfactual of section 6;
* K1 (section 12) flows through a native's result type, not a binding.

All are class A and invisible in reported diagnostics; neither a
component-level record nor a check at every value call is justified by
them.

### 21.4 What the three change, measured

On the prototype, against this commit:

| check | result |
|---|---|
| `tests/emission-claims.test` | 110 of 110 |
| `tests/csv-emission.test` | 36 of 36 |
| `audit/emission-claims/tools/census.tcl -part all` | identical to this commit's output (no false proof; 31 of 31 mistakes as the exploratory checker decided) |
| `audit/emission-claims/tools/fuzz.tcl -seeds 1-12` | identical (12,480 runs, no false proof) |
| `audit/emission-claims/tools/loops.tcl -count 80 -seed 11` | identical (13,520 runs, 0 false certificates; summaries 224 computed, 60 reused, 160 rounds) |
| `audit/emission-dependencies/tools/census.tcl` | 0 false certificates (4 on this commit); 17 of the 20 open cases with an appropriate verdict closed (B2b, S1 and K1 left), and B3, B8b and G1 decided `dependent`; every difference from the record is towards the appropriate verdict |
| `tools/mutant-catalogs.tcl` | one mutant no longer applies: `dependent-reports` (emission-claims), whose text `CodeDependent` duplicates; the milestone shares one predicate for both readers and keeps the mutant |

Every row was run on the final prototype. Each of 21.1, 21.2 and 21.3
was also run alone against the emission tests (110 of 110 each).

## 22. Regression and mutation plan

For the correction milestone (the census adds no test to the suite: its
corpus is the reproducer set, `audit/emission-dependencies/`).

**Tests** (tests/emission-claims.test, each with the memo on, the
default, and off):

* identity:
  * N1, N2 and N3, the second claim rejected and strict compilation
    raising EMIT-REJECTED;
  * the `identity` sequence (N4a, then N4b, rejected fresh);
  * composition with a same-named callee not taken;
  * module-qualified names still reused (a::emitter beside b::emitter);
* feasibility:
  * F1, F2 and F3 rejected;
  * a parameterless claim whose `if` is decided both ways proven with its
    exits (`exits done`);
  * F4 unchanged;
* provenance:
  * the class A rows of sections 6 to 9 dependent, through module, captured
    and destructured bindings and V2;
  * B3b, B5, B8e, Z1 and R2 unchanged;
  * the `callable` sequence (V2 dependent fresh; V1 reused after);
  * ec-memo-reuse unchanged.

**Mutants** (audit/emission-claims/tools/mutants.txt), each killed by one
of the tests above:

* identity:
  * `ambiguous-reused` (the memo reuses an ambiguous claim);
  * `ambiguous-validated` (Valid accepts an ambiguous dependency);
  * `ambiguous-composed` (UsableCertificates ignores ambiguity);
  * `ambiguous-first-only` (`ambiguous` never set);
* feasibility:
  * `facts-env-as-feasibility` (the old test);
  * `facts-first-path-only` (the join dropped);
* provenance:
  * `binding-provenance-unread` (RefValue does not ask);
  * `binding-unreachable-trusted`;
  * `binding-alias-unfollowed`;
  * `binding-inferred-callee-ignored`;
  * `binding-declared-callee-followed` (B5 made dependent);
  * `value-never-unread` (V2);
  * `memo-trusts-recovered` (the memo rule dropped);
  * `dependent-reports`, kept applying.

The census tool is the acceptance harness: its `observed` lines are updated
to the new verdicts, and it must report 0 false certificates.

## 23. Expected implementation costs

**Frequency** (`audit/emission-dependencies/tools/counts.tcl`, results/
counts.txt: what the walk reads, compiling examples/dfa/json/
emit_probes.bot's 22 claims and examples/dfa/csv/probes.bot's 52):

| event | JSON | CSV |
|---|---:|---:|
| references read from the walk's environment | 788 | 682 |
| references to module bindings, captured locals | 0 | 0 |
| list-loop element bindings (read through their type) | 11 | 56 |
| root bindings (`true`, ...) | 226 | 120 |
| calls with a named callee (`Taint`) | 1,312 | 888 |
| calls through a value (no target) | 0 | 0 |
| never helpers read (`Read`) | 0 | 0 |
| non-yielding helpers (`Child`), yielding helpers, guards | 12, 159, 4 | 6, 156, 40 |
| `Facts` calls; with an empty environment | 592; 0 | 168; 0 |
| duplicate function names | 0 | 0 |
| summaries computed / reused / rounds | 140 / 60 / 44 | 207 / 121 / 104 |
| summary edges: children / reads | 57 / 0 | 5 / 0 |

None of the three corrections runs on these workloads beyond a dictionary
lookup:

* `BindingDependent` is asked only for a non-local binding, and there are
  none;
* the unit graph is computed only when the program has resolution
  diagnostics;
* `ambiguous` is empty.

**Time.** The checker's own time on the probe programs, 5 fresh processes
each, medians (ms). A background audit shared the machine, so the spread
is wide:

| | this commit | prototype |
|---|---:|---:|
| JSON, 22 claims | 285 (255-384) | 294 (260-310) |
| CSV, 52 claims | 710 (648-735) | 686 (670-754) |

Within noise; summary counts identical.

**Bounds.** `BindingDependent` walks a binding's initializer once per
compilation (memoized). It follows aliases through the memo, which is
cycle-safe: single assignment and no forward references mean an alias
chain has no cycle, and the memo's provisional 0 stops one anyway. The unit
graph is computed once per verify, and only for a program that has
resolution diagnostics. None of it is per reference or per summary round.

## 24. Remaining uncertainty and next milestone

* **Uncertain**: whether anything outside the emission checker identifies
  a function by its bare name in the same way. The census looked only at
  hir::emission's `names`, `byName`, `certs` and the memo.
* **Uncertain**: B3, B8b and G1's appropriate verdicts (section 6), and
  S4b, S5b and S6b's (sections 9 and 10). The prototype decides the first
  three `dependent`, the others not at all.
* **Not covered by any recommendation**: S1, S4b, B2b and K1 (section
  21.3). They are class A, hidden by recovery.
* **Not tested**: the identity defect through the compiler service's real
  revision loop. The `identity` sequence compiles in one process exactly as
  the service does, but no editor session was driven.
* **Next milestone**: EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-
  MILESTONE-1, with sections 21.1 and 21.2 first (class C), and 21.3 in
  the same change or a second milestone. Its scope, negative tests and
  preserved programs are sections 21 and 22.

## 25. Final evaluation questions

**1. What does an emission proof actually depend on?**

The code of every function in its read set: a fingerprint per function,
which includes each expression's type facts, reachability, and the exact
Int value and type facts of every non-local binding it reads. Beyond that,
the statements of the certificates it composed with, the recognizers'
tables and the registered native result sets.

The verifier can identify the *declarations* supplying those values, types
and completion facts, with two exceptions:

* a function's identity is its name, which does not identify it when two
  functions share one (section 15.3);
* a structural function type's `never` names none of the functions it was
  joined from (section 8).

It cannot identify the *provenance* of a non-local binding's facts: it
reads the facts, never the code that made them.

**2. Where is provenance lost?**

In three places:

1. at a bind of an unresolved name's `never`, which leaves the binding
   untyped (section 13.1);
2. at the join of function types into a structural `Fn` (section 13.2);
3. at signature resolution, which records an unresolved component as an
   omitted one (section 9).

The first two reach the walk's facts; the third reaches only its verdicts.
Recovery-derived types (the `never` placeholder) are lost at the first two.

**3. Are the failures merely diagnostic inconsistencies?**

The binding and signature failures are, in every accepted program the
census could construct: the placeholders are top, or genuine body facts.
One reaches a reusable certificate, V2's memo transition, but only in
rejected programs.

The two class C defects found on the way are not inconsistencies. They
invalidate certificates of accepted programs, and they make the outcome of
a compilation depend on process history.

**4. Is the current `reads` mechanism sufficient?**

For what it was made for, yes: the code of a function whose `never` the
walk relies on. It is not the representation for a binding: a binding is
no summary, is evaluated outside every walk, and its facts are already in
its reader's fingerprint. What a binding needs is the summary's existing
`tainted` flag, set by a reader that asks where the binding's facts came
from (section 14).

**5. Should provenance belong to facts or to expressions?**

To expressions -- the existing arrangement. Poison is the provenance of a
TYPE diagnostic, the walk's taint and recovery's unit graph that of a
resolution failure, and all three are keyed by expressions and bindings.
The emission checker should consult them where it reads a fact whose
expression it does not walk (section 21.3).

Attaching provenance to facts (intervals carrying their sources) would
duplicate this inside the checker, for no case the census found.

**6. What is the smallest worthwhile correction?**

Sections 21.1 and 21.2: 33 changed lines in one file (10 and 23), which
close the class C defects. With 21.3 (136 more) the binding cases close
too.

* Scope: hir/emission.tcl.
* Negative tests: N1, N2, N3 and N4b rejected; F1, F2 and F3 rejected; the
  class A rows dependent.
* Preserved: every other accepted program's verdict and the summary counts
  (the JSON and CSV workloads, the census, the fuzzer, the loop
  differential), every memo test, B3b, B5, B8e, Z1 and R2.

**7. What should remain untouched?**

* `never`'s recovery semantics for the other analyses (making an
  unresolved name poison, section 18);
* the certificate format and the memo's key (identity can be refused,
  never guessed);
* a component-level record of signature diagnostics;
* a general fact-provenance abstraction;
* a dependency graph of the emission checker's own beside recovery's;
* a lexical identity scheme for nested functions.

None is justified by an observed defect. The census found no false proof
that any of them would prevent and the three corrections do not.
