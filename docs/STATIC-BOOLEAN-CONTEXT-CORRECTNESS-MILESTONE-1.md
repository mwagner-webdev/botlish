# STATIC-BOOLEAN-CONTEXT-CORRECTNESS-MILESTONE-1.md -- statically invalid conditions do not reach run time

Completion report. METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md, section
12, recorded a construct that is not a call with the defect that milestone
fixed for calls:

```
fn f(a: List[int]) -> int:
    if a:
        1
    else:
        2

f([1])
```

compiled, and raised `if condition must be a Boolean, got [1] (CORE SEMANTIC
NOT-BOOLEAN)` on every backend. This milestone establishes why, fixes it for
every Boolean-consuming construct that shared it, and pins the invariant with
adversarial tests and mutants:

> A known-invalid condition is a compile-time error. A genuinely dynamic
> condition is checked at run time. The distinction is the program's static
> contract, not whichever caller or backend happens to execute it.

The base of every "before" below is `f9e0ed0` (main when the milestone
started). The change is on the branch `ccr-656fd8f1-hua5hn`.

## Contents

1. Result
2. The original reproducer
3. The Boolean-context census
4. Root cause
5. The static contract
6. Generic behavior
7. Implementation
8. Diagnostics and recovery
9. Evaluation is unchanged
10. Core IR and the backends
11. Compiler-service evidence
12. Mutation evidence
13. Regression results
14. Performance
15. Remaining limitations
16. Handoff to RUNTIME-ERROR-RECOVERY-CENSUS

## 1. Result

**Fixed, with its siblings.** Every Boolean-consuming construct of Botlish's
grammar -- an `if` or `elif` condition, the operand of `not`, each operand of
`and` and `or` -- is lowered to an HIR `if` (surface/lower.tcl), and none of
them held its operand to Bool: a condition statically of another kind
compiled and raised NOT-BOOLEAN when it was tested. Now the construct's own
check rejects it, at the operand, in the construct's name:

```
if-list-condition.bot:9:8: the condition of an if requires bool, but this
condition has type List[int]: testing it could only fail when it runs
(CORE SEMANTIC TYPE)
```

* The reproducer, and the same mistake in each construct and with every
  concrete kind (Int, String, UnicodeChar, Float64, unit, List, struct, enum,
  MutableVector, a function reference, a native, DecimalRounded, a raw C
  floating value), is rejected before any backend runs, on all four, and
  through the compiler service (sections 2, 3, 11).
* Valid conditions compile and run as before, and the generated code of an
  accepted program is unchanged (sections 9, 14).
* An untyped parameter used as a condition keeps its checked `bool`
  contract, enforced at its callers (unchanged); a rigid imprint variable is
  now rejected at the definition, for every T, declared, trait-constrained
  or inherited, where it used to be checked only through the instantiation
  that ran (section 6).
* `any` stays dynamic: an `any` condition holding a List compiles and raises
  the run-time NOT-BOOLEAN on every backend, exactly as before (section 5).
* A rejected condition decides nothing: the `if` no longer narrows a value it
  could not test to `bool`, which used to turn every later use of a List
  condition into a second, wrong diagnostic ("this argument has type bool";
  section 8).
* Existing stronger checks keep their diagnostics: a trait view's
  TRAIT-VIEW-MISUSE, an affine value's AFFINE-ERASURE-UNSUPPORTED, a poisoned
  operand's own error; core IR text keeps its run-time semantics
  (sections 8, 10).
* NOT-BOOLEAN is not made handleable (section 16).

## 2. The original reproducer

`audit/static-boolean-context/repro/if-list-condition.bot` (the program
above, with a header comment), on `f9e0ed0`:

```
$ tclsh9.0 main.tcl -backend interp audit/static-boolean-context/repro/if-list-condition.bot
== if-list-condition.bot (interp)
   error: if condition must be a Boolean, got [1] (CORE SEMANTIC NOT-BOOLEAN)
   help: tclsh9.0 main.tcl -help error.not-boolean
```

and the same error on `compile`, `cranelift-generic` and `cranelift`. The
compiler reported nothing: the strict HIR had no diagnostic.

**The HIR.** One `if` node; its condition a `ref` of static type `List[int]`;
the `if`'s type `int` (the lub of its branches); both branches reachable;
`refinements {1 {} 0 {}}`. After the `if`, the generic walk had narrowed the
binding `a` to `bool` (`hir::types::If`: "The if raises unless the condition
is a Boolean") -- which is how section 8's cascade arose.

**After.** Rejected at compile time with the one diagnostic of section 1, at
the condition (9:8), on every backend, before running
(`sbc-reproducer-rejected`, `-strict`, `-every-backend`,
`-compiler-service`). The HIR is the same but for two facts
(`sbc-reproducer-hir`): the `if` carries `written {form if}`, and `a` is no
longer narrowed (the rejected condition decides nothing).

## 3. The Boolean-context census

Botlish's grammar (surface/parser.tcl, surface/lower.tcl's rules) has these
Boolean-consuming constructs; every one was probed on the base with small
programs (interp and cranelift, and all four backends for the operators):

| construct | lowered to | required | statically incompatible operand on `f9e0ed0` | untyped parameter | `any` | now |
|---|---|---|---|---|---|---|
| `if c:` | `if c {..} {..}` | Bool | compiles; run-time NOT-BOOLEAN | checked contract `bool`, enforced at the call | run-time NOT-BOOLEAN | TYPE at `c` ("the condition of an if") |
| `elif c:` | an `if` alone in the previous clause's else | Bool | compiles; run-time NOT-BOOLEAN | the same | the same | TYPE ("the condition of an elif") |
| `not a` | `if a {false} {true}` | Bool | compiles; run-time NOT-BOOLEAN | the same | the same | TYPE ("the operand of not") |
| `a and b` | `if a {if b {true} {false}} {false}` | Bool, both | compiles; run-time NOT-BOOLEAN (the right operand only when the left is true) | the same | the same | TYPE ("the left/right operand of and") |
| `a or b` | `if a {true} {if b {true} {false}}` | Bool, both | the same | the same | the same | TYPE ("the left/right operand of or") |
| `a != b` | `if (== a b) {false} {true}` | Bool, of `==`'s result | nothing to reject: `==` always returns a Bool | -- | -- | unchanged |

The kinds probed, each as an `if` condition (`sbc-other-concrete-kinds`):
`3`, `"ab"`, `'a'`, `1.5`, `unit`, a List literal, a struct, an enum case, a
MutableVector, a function reference written without its call (`if ready:`), a
native, a DecimalRounded value, a raw C floating value -- each compiled and
raised NOT-BOOLEAN on the base, each is TYPE now. A unit-valued validator call
as a condition (`refinement-validators.test`'s `validator-not-a-condition`)
and an Int `elif` (`elif.test`'s `elif-non-boolean-condition`) were pinned
by existing tests as run-time NOT-BOOLEAN; they are compile-time TYPE now.

What is not a Boolean-consuming construct here, and why:

* **Loops.** `loop:` has no condition (it ends by `break`), `loop x in xs` an
  iterable, `loop i from a to b` Int bounds, a lockstep loop both. There is no
  `while` and no loop guard, so no loop consumes a Bool. (Their operands' own
  kinds are the subject of section 15.)
* **Guards.** There are no pattern guards; an `on` handler discriminates an
  error identity, never a value (ERROR-PAYLOADS.md).
* **Natives whose parameters require a Bool** are ordinary calls: the
  native-argument check of METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md
  holds them already (no second check here).
* **Constructs a front end synthesizes** -- a recognizer's dispatch
  (surface/dfa.tcl), a static block's (hir/static.tcl), `!=`'s inner test --
  test values the compiler built Bool: they are no operand the program wrote
  (section 7).
* **Explicitly dynamic operations** are the conditions of type `any`
  (section 5).

## 4. Root cause

The reproducer's `if` was traced through each stage:

1. **Parsing and lowering** (surface/lower.tcl): `if a:` becomes an HIR `if`
   whose condition is the reference `a`; `not`, `and`, `or` become `if`s too.
   The lowering kept no record of which construct an `if` was written as.
2. **The condition's static type**: `List[int]`, from the declared
   parameter, in the generic typing walk (`hir::types::If` types the
   condition first).
3. **The Boolean requirement** was known in four places, and each used it
   for something other than rejecting the program -- the shape the receiver
   milestone found for natives:
   * the generic walk (`hir::types::If`) *narrowed* the condition's binding
     to `bool` afterwards ("The if raises unless the condition is a
     Boolean") -- a flow fact, so later code saw `a: bool`;
   * region inference (`hir::specialize`, the `spec` walk of `If`) typed such
     an `if` `never` ("the condition is statically not a Boolean, so the if
     always raises NOT-BOOLEAN") -- an optimization;
   * an untyped parameter's contract inference (hir/signatures.tcl) imposed
     the *checked* requirement `bool` on a parameter used as a condition, so
     `fn f(a): if a: ...` called with a List was rejected at the call --
     while a parameter *declared* `List[int]` was not;
   * and the closed-AOT readiness inspection (`hir::aot::Require`) records
     such a condition as a `known-error` fact.
4. **Diagnostics**: none was produced, so none was lost or suppressed.
5. **Semantic instances** type a body again under one caller's argument
   types; they saw the same `List[int]` and, like the generic walk, only
   narrowed.
6. **Every backend** lowered the `if` as written and reached its own run-time
   test of the condition (`core::runtime`'s `if` on the interpreter, the Tcl
   compiler's `CompileCondition`, native lowering's `guardbool`), the first
   place the omission became observable.

**The defect: no check of the construct.** Nothing held the condition of an
`if` to its required kind; the stage with enough information is the same as
for a native argument -- the generic walk's types, read by the program's
checks after inference (`hir::range::verifyDeclaredParams`'s walk of every
expression, which `VerifyNativeKinds` runs in). Like the native case, the
defect was shared by every construct lowering to an `if`, so the fix is the
construct's own check -- never a rule for `if` alone or for List.

## 5. The static contract

For the operand of every Boolean-consuming construct the program writes:

* **Known Bool** (`bool`, a refinement whose values are Bools such as a
  `proves`-established `Yes`, a comparison, `not`/`and`/`or`, a function's
  declared or inferred `bool` result): accepted. No run-time obligation is
  added; the backends' existing defensive test of a non-Bool value is kept
  for the dynamic case and for core IR (section 10), and it was already
  absent from code where the operand is statically Bool.
* **Known incompatible** -- a static type whose runtime kind is fixed and is
  not `bool` (`hir::types::KindMismatch bool TYPE`): a compile-time TYPE
  error at the operand (section 8), in reachable and dead code alike, as
  every check of the program as written.
* **`any`**: no fixed kind, so no rejection; tested when it runs, NOT-BOOLEAN
  otherwise, unchanged (`sbc-any-dynamic-true-false`,
  `-incompatible`, `-operands`, `sbc-any-element`,
  `sbc-any-after-observable-operations`, `sbc-any-in-coroutine`). No declared
  error is attached to it.
* **`never` and poison**: an operand that never completes cannot be a wrong
  value, and an operand an earlier diagnostic rejected (poison: an unknown
  field, an invalid call, a syntax hole) is that diagnostic's; neither is
  reported (`sbc-no-cascade-invalid-operand`, `sbc-syntax-recovery`).
* **Types of no fixed kind** that are not `any` -- a structural function
  type, a trait view -- are not judged by the kind rule (the rule the native
  check uses, unchanged): a trait view keeps TRAIT-VIEW-MISUSE, a structural
  function type stays a run-time check (section 15).

## 6. Generic behavior

* **An untyped parameter** used as a condition imposes the *checked*
  contract `bool` (hir/signatures.tcl, unchanged): the body alone compiles,
  its contract is `bool` (`sbc-generic-untyped-definition`), a caller giving
  a Bool runs (`-satisfied`), and one giving a List is rejected at the call,
  once -- the condition itself is not reported, since the body sees `any`
  and a semantic instance's view is never judged (`-violated`).
* **A rigid imprint variable** is checked once, for every T
  (C-ABI-TYPES.md; the receiver milestone, section 6): `if b.v:` with
  `b: Box[T]` used to compile and run for a `Box[bool]` and fail for a
  `Box[List[int]]`; now it is rejected at the definition with no call, a
  convenient call and an inconvenient one alike ("... has type T: the
  function is checked once, for every T, and not every T is bool",
  `sbc-generic-imprint-unconstrained`), for every construct
  (`-operands`). A trait constraint names no kind (`T satisfies Hashable`,
  `-trait-constrained`). An *inherited* imprint variable (an untyped
  forwarder `fn first(b): if unbox(b):`, whose `b` inherits `Box[T']`) is
  held the same way (`-inherited`). An imprint variable in an operation that
  requires no kind (`b.v == b.v` as the condition) is valid for every T and
  runs (`-kind-free`). No generic constraint syntax was added; Botlish has
  none that establishes Bool admissibility, so none is preserved or needed.
* **`any` is never judged through an instance.** The check runs on the
  program as written, never in a semantic instance's view (where `f([1])`
  would show `a: List[int]` for `a: any`): `sbc-any-dynamic-incompatible`
  compiles, and the mutant `instance-contamination` is killed by it.

## 7. Implementation

Production files:

* **surface/lower.tcl** -- every `if` the `if` rule (with `elif`), `not`,
  `and`, `or` and `!=` build carries `written`: the construct, and for
  `and`/`or` the operand (`hir::syntax::withWrittenIf`). The marker is the
  `if` twin of a call's `written` (how it was spelled, for diagnostics and
  for scoping the check to what the program wrote).
* **hir/syntax.tcl** -- `withWrittenIf` and the marker's documentation; an
  `if` a front end synthesizes or core IR wrote carries none.
* **hir/resolve.tcl** -- copies the marker to the resolved `if`
  (`{form F}` or `{form F operand O}`).
* **hir/types.tcl** -- the kind comparison, stated once:
  `KindMismatch WANTED TYPE` (a fixed kind other than WANTED) and
  `RequirementMismatch WANTED TYPE` (plus the rigid imprint variable). The
  native rules ask them (`NativeKindMismatch`, `NativeArgumentMismatch`,
  through `NativeParamKind`), and so does the new `ConditionMismatch TYPE`
  (`RequirementMismatch bool`). In `If`, region inference's dead `if` asks
  `KindMismatch bool` (it used to compare `kindOf` itself), and the generic
  walk's `RejectsCondition` makes a rejected condition decide nothing, as a
  poisoned one does (section 8); a condition typed `bool` is decided by its
  first test (section 14).
* **hir/range.tcl** -- `VerifyCondition`, the construct's check, in the walk
  that runs `VerifyNativeKinds` (`VerifyCallArguments`, every expression of
  every block, reachable or not), and `ConditionConstruct` for the wording.
  It skips a semantic instance's view, an `if` with no marker, a poisoned
  operand, and a reachable affine operand (the ownership discipline's).

No special case for List, for `if` or for any one construct; no run-time
check added or removed; no change to HIR's other fields, Core IR, NIR, or any
backend. The method-call decision is untouched: the diagnostic is the
construct's, with no subject, so a condition never selects a candidate
(`sbc-method-condition-not-a-subject`).

Tests, tools and documents:

* `tests/static-boolean-context.test` (51 tests; census rows in
  `audit/golden/migration/census/static-boolean-context.tsv`, names in
  `audit/golden/migration/tcl-names.txt`, the regenerated
  `tests/golden/manifest.tsv`).
* `audit/static-boolean-context/repro/if-list-condition.bot`, the reproducer.
* `audit/static-boolean-context/tools/mutate.tcl` (with `-jobs N`) and
  `mutants.txt` (section 12).
* Tests that pinned the old behavior, updated (section 13), with their census
  rows; the receiver milestone's `mrt-rule-one-statement` and two of its
  mutants (`imprint-variable-deferred`, `equal-kinds-rejected`) follow the
  rule to `RequirementMismatch`/`KindMismatch`, keeping their rules.
* Compilerpedia: error.type (the condition family, a rejected example),
  error.not-boolean (only an `any` condition reaches it; no handler catches
  it), concept.booleans, concept.if-expressions. docs/README.md (the
  operators' paragraph), docs/INDEX.md.

## 8. Diagnostics and recovery

**The diagnostic** is the established TYPE category (`CORE SEMANTIC TYPE`,
`std::compiler::DiagnosticCode::Type` in a static block:
`sbc-static-compile-rejects`), at the operand, naming the construct, Bool,
the operand's static type and why:

```
the condition of an if requires bool, but this condition has type List[int]: testing it could only fail when it runs
the condition of an elif requires bool, but this condition has type str: testing it could only fail when it runs
the operand of not requires bool, but this operand has type List[int]: testing it could only fail when it runs
the right operand of and requires bool, but this operand has type int: testing it could only fail when it runs
the condition of an if requires bool, but this condition has type T: the function is checked once, for every T, and not every T is bool
```

"... requires bool, but ... has type ..." is the wording of the native
argument's diagnostic; no Boolean-specific code was introduced. The
diagnostic is the construct's own: it has no `subject`, so it is never a
method-style call's problem -- with two visible `ready` functions returning
`bool` and `int`, `if s.ready():` stays AMBIGUOUS-METHOD-CALL rather than
selecting the Bool one (`sbc-method-condition-not-a-subject`); a call decided
by its own checks is then judged as a condition like any value
(`sbc-method-condition-decided-alone`).

**Ownership of the diagnostic.** It is reported where the construct is
written, for the operand the program wrote -- never at a native the
construct lowers to, and never for an `if` a construct synthesizes. A more
specific diagnostic keeps an operand: a trait view's TRAIT-VIEW-MISUSE (a
view has no kind, so the rule never fires: `sbc-trait-view-misuse-kept`), a
reachable affine value's AFFINE-ERASURE-UNSUPPORTED (the condition does not
carry ownership, `sbc-affine-condition-kept`; in dead code, where the
ownership analysis never looks, the TYPE reports it), and every poisoned
operand's own error -- `if a + "s":` reports the `+` only, an unknown field
or an unbound name only themselves (`sbc-no-cascade-invalid-operand`).

**Independent errors** are independent diagnostics, in source order: an
`if`'s and its `elif`'s condition, both operands of one `and`
(`sbc-independent-conditions`), the condition beside an error in each branch
(`sbc-recovery-branches-checked`), an error after the `if`
(`sbc-recovery-later-statements`), every construct nested in arguments,
List elements, nested functions, loop bodies and handlers
(`sbc-nested-positions`).

**What the rejection poisons.** The condition decides nothing -- the
existing treatment of a poisoned condition (hir/types.tcl, "Poison": "a
poisoned `if` condition leaves both branches reachable and undecided"): both
branches are typed reachable, no branch refinement or implication is
recorded, and the condition's value is never narrowed to `bool`. The operand
itself is not poisoned (it is a valid expression of its own type: a hover
still shows `List[int]`), and the `if` keeps its branches' type, so a use of
its value is judged by what the branches give: a valid use reports nothing
more, an invalid one is its own error (`sbc-recovery-result-used`). On the
base the narrowing produced a cascade, which this removes:

```
import std::list

fn f(a: List[int]) -> int:
    if a:
        1
    else:
        2
    std::list::length(a)
```

was rejected on `f9e0ed0` -- for the wrong reason, by the native-argument
check -- with "argument 1 of native std::list::length requires list,
but this argument has type bool" at 8:23, and is now rejected with the
condition's diagnostic alone (`sbc-no-cascade-after`, also inside a branch,
and in dead code: `sbc-no-cascade-dead-code`).

**Syntax recovery.** Past a syntax error, an independently analyzable
conditional still gets its check: the syntax errors first, unchanged, then
the condition's TYPE (`sbc-syntax-recovery`, `surface::readProgramFile
-recover-syntax 1`); a syntax hole as a condition is poison and reports
nothing more.

## 9. Evaluation is unchanged

The check reads types and writes diagnostics; it changes no HIR expression,
binding or scope of an accepted program, adds no node, no operation and no
run-time test. For an accepted program the one HIR difference is the
`written` marker on its `if`s, which no lowering or backend reads:
`sbc-valid-backend-code-unchanged` compiles a function with every construct
with and without the markers and finds the Tcl compiler's code (numbering
normalized) and the specialized NIR identical. On every backend, the tests
pin:

* valid conditions of every source (a literal, a Bool parameter, a function's
  result, a comparison, logical operators, an untyped helper's inferred
  result, a refinement predicate's proof; `sbc-valid-conditions`), the
  refinement still narrowing and a value of a refinement of bool itself a
  condition (`sbc-valid-conditions-no-diagnostic`);
* short-circuiting and evaluation order: `false and a`, `true or a` never
  test an `any` operand holding a List (`sbc-any-dynamic-operands`); the
  operands' yields happen in written order, the right one only when needed
  (`sbc-valid-yields-in-conditions`); an `any` condition's failure comes
  exactly where it is tested, after the yields before it
  (`sbc-any-after-observable-operations`);
* declared errors in conditions propagate and are handled as before
  (`sbc-valid-errors-in-conditions`); affine moves around a valid condition
  (`sbc-valid-affine-in-branches`); a condition reading an installed context
  (`sbc-valid-context-in-condition`).

No truthiness or coercion was added: a List, an Int or a String never becomes
an acceptable condition.

## 10. Core IR and the backends

**Where the guarantee is established.** In the front end, once: the generic
walk's types, read by `hir::range::VerifyCondition` during the program's
checks (`hir::CheckOnce`). A source program with such a condition is
rejected there; a lenient (`-strict 0`) HIR keeps the diagnostic, and a
backend given one compiles it checked again without poison
(`hir::recovery::runnable`, unchanged), where the `if` keeps its run-time
test. The
four backends have no rejection logic of their own and gained none: they
lower the `if` as before and keep their defensive run-time test of a
condition whose kind is not established (`core::runtime`'s, the Tcl
compiler's `CompileCondition`, native lowering's `guardbool`), which the
dynamic case and core IR need.

**Core IR text** has no declarations and is past the source boundary: its
`if`s carry no marker, so it keeps its run-time semantics -- `if (const 1)`
builds strictly and raises NOT-BOOLEAN when it runs (`sbc-core-ir-unchanged`,
control.test's `if-4`, backends.test's `differential-non-boolean`
unchanged). Nor is anything in a HIR read back from core IR poisoned
(`hir::types::MakesPoison`), as for every check of this kind.

**How it survives lowering.** Lowering does not need it: an accepted program
has no non-Bool condition of known kind, so the defensive test is either
absent (the operand is statically Bool) or the dynamic one (`any`).
Region inference still types an `if` with a statically non-Bool condition
`never`, which only a core IR program or a lenient run can contain.

## 11. Compiler-service evidence

* `sbc-reproducer-compiler-service`: a workspace analysis of the reproducer
  has outcome `semantic` and the one error `CORE SEMANTIC TYPE` at 9:8-9
  with the command line's message -- the service's ordinary checking path.
* `sbc-compiler-service-revisions`: one workspace, one document edited
  through six revisions -- `a: List[int]` (TYPE at 2:8), `a: bool` (ok),
  `List[int]` again (TYPE), `a: any` (ok), the condition removed (ok), the
  condition restored (TYPE): each revision's diagnostics are its own source's.
* `sbc-cache-hit-equals-build`: through the front-end cache, a valid
  program's entry carries the markers exactly as its build did, and a
  rejected program is rejected again on its second compilation. The front
  end's fingerprint covers
  `surface/` and `hir/`, so every older entry was invalidated by the change.

## 12. Mutation evidence

`tclsh9.0 audit/static-boolean-context/tools/mutate.tcl` (`-jobs N` runs N
private trees at once) applies each mutant of
`audit/static-boolean-context/tools/mutants.txt` to a private copy of the
tree and runs `tests/static-boolean-context.test`; a mutant counts as killed
only when one of the tests its `!!` line names fails -- the test that states
the rule it breaks -- so a mutant that breaks the build, or only some other
test, is reported as not killed for its reason.

| mutant | the incorrect implementation | killed by |
|---|---|---|
| `condition-unchecked` | the census defect for every construct: no condition is ever a mismatch | `sbc-reproducer-rejected`, `-strict`, `-every-backend`, `-compiler-service`, `sbc-constructs`, `sbc-constructs-every-backend` |
| `if-unchecked` | the original defect for `if`/`elif` alone | `sbc-reproducer-rejected`, `sbc-constructs`, `sbc-other-concrete-kinds` |
| `logical-operands-unmarked` | `and`/`or` lowered without their marker: both operands unchecked | `sbc-constructs`, `sbc-written-markers` |
| `right-operand-unmarked` | only the right operand's test unmarked | `sbc-constructs`, `sbc-written-markers`, `sbc-nested-positions` |
| `not-unmarked` | `not` lowered without its marker | `sbc-constructs`, `sbc-written-markers`, `sbc-nested-positions` |
| `diagnostic-suppressed` | the mismatch recognized (the condition decides nothing) but never reported | `sbc-reproducer-rejected`, `-strict`, `-every-backend`, `-compiler-service` |
| `dead-code-exempt` | a condition in dead code skipped | `sbc-dead-code-checked`, `sbc-no-cascade-dead-code`, `sbc-affine-condition-kept` |
| `construct-misnamed` | every construct named an if | `sbc-constructs`, `sbc-nested-positions` |
| `any-rejected` | `any` treated as a known incompatible kind | `sbc-any-dynamic-true-false`, `-incompatible`, `-operands`, `sbc-any-element`, `sbc-any-after-observable-operations`, `sbc-any-in-coroutine`, `sbc-rule-cases` |
| `imprint-variable-deferred` | a rigid imprint variable treated as `any` (checked through instantiations) | `sbc-generic-imprint-unconstrained`, `-operands`, `-trait-constrained`, `-inherited`, `sbc-rule-cases` |
| `instance-contamination` | the check also run in a semantic instance's view | `sbc-any-dynamic-incompatible`, `sbc-generic-untyped-violated` |
| `untyped-contract-dropped` | an untyped parameter used as a condition imposes no contract | `sbc-generic-untyped-definition`, `-violated` |
| `poison-dropped` | a rejected condition still narrows its value to bool (the cascade) | `sbc-no-cascade-after`, `sbc-no-cascade-dead-code` |
| `affine-restated` | a reachable affine condition reported twice (TYPE beside AFFINE-ERASURE-UNSUPPORTED) | `sbc-affine-condition-kept` |
| `condition-selects` | the condition's diagnostic made a method-style call's own problem (a subject): SFIAE for a use of a call's value | `sbc-method-condition-not-a-subject` |

Every mutant applies exactly once and is killed by a test it names (exit 0).
The catalog's "loop condition unchecked" has no implementation path to mutate
(Botlish has no conditional loop, section 3); its "double diagnostic" is
`affine-restated`, the one existing stronger check the kind rule could
restate (a trait view has no kind, a poisoned operand no type to judge).

The receiver milestone's harness was brought along: two of its mutants
(`imprint-variable-deferred`, `equal-kinds-rejected`) targeted the native
rule's text, which now asks `RequirementMismatch`/`KindMismatch`; each was
updated to the new text keeping its rule, and `audit/method-receiver-types/
tools/mutate.tcl` kills them (section 13).

## 13. Regression results

All on the final code but where a row says otherwise, in a 4-core container
(`LANG=C.utf8`, Tcl 9.0.1, the native driver built from this tree).

| check | command | outcome |
|---|---|---|
| the regression file | `tclsh9.0 tests/static-boolean-context.test` | 51 passed, 0 failed |
| the local suite | `tclsh9.0 tests/local.tcl` (247 Tcl test files on interp and compile, golden duplicates skipped; 113 golden suites on four backends, through the front-end cache) | Tcl: interp 7,878 passed, compile 7,873 passed, 1 failed on each (below); golden suites 113 run, 0 failed: interp 5,424/5,424, compile 5,424/5,424, cranelift-generic 5,332/5,332, cranelift 5,434/5,434 |
| the files edited or added, every test (golden duplicates included, as CI runs them) | `tclsh9.0 tests/local.tcl -all 1` on many-boolean-arguments, static-boolean-context, elif, surface-lowering, refinement-validators, method-receiver-types, control, branch-form-boolean | interp 423 passed, compile 423 passed, 0 failed |
| the golden manifest | `tclsh9.0 audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1` | no problem (12,186 rows) |
| Compilerpedia | `tclsh9.0 tools/compilerpedia.tcl check` | 1,134 topics, 686 examples run, 0 problems |
| the warning gate | `tests/warning-gate.test` in the local suite | 6 passed on each backend: the shipped corpus compiles as before |
| this milestone's mutants | `tclsh9.0 audit/static-boolean-context/tools/mutate.tcl -jobs 2` | all 15 apply exactly once and are killed by a test their `!!` line names (exit 0) |
| the receiver milestone's mutants this change moved | `tclsh9.0 audit/method-receiver-types/tools/mutate.tcl -only imprint-variable-deferred,equal-kinds-rejected,reachable-only,any-rejected-through-instances` | each applies and is killed by its named test (exit 0) |
| branch-form Boolean lowering (the `and`/`or`/`not`/`!=` rules gained a marker) | `tclsh9.0 audit/branch-form-boolean/tools/mutate.tcl` | 18 mutants, 18 killed |
| diagnostic recovery (a rejected condition decides nothing, as poison does) | `tclsh9.0 audit/diagnostic-recovery/tools/mutate.tcl`; `audit/diagnostic-recovery/tools/efficiency.tcl` | 27 mutants, 26 killed, `poison-return-check` survives -- **the same on `f9e0ed0`** (below); the corpus: 15 files, every known primary in the first compilation, no cascade, every case clean once fixed |
| the static-decision schedulers | `tclsh9.0 audit/static-decisions/tools/fuzz.tcl -n 4 -seed 17` and `-seed 41` | 120 and 132 sites, 0 failures each |
| the schedulers on conditions | a program of seven static blocks whose conditions read other functions' inferred results and other blocks' outcomes, under the batched and `BOTLISH_STATIC_SCHEDULER=sequential` | identical decisions (4 rejected, 3 accepted) |
| HIR interchange and the front-end cache (an `if` gained a field) | `tclsh9.0 audit/hir-interchange/tools/roundtrip.tcl -via interchange`, `-via cache` | 12 suites, 108 and 120 artifacts and outcomes compared, 0 differ |
| generated code of accepted programs | the Tcl compiler's code and generic and specialized NIR of twelve programs (the 2048 suite and benchmark, Icy Tower's headless run, eight condition-heavy golden suites, two benchmarks) on `f9e0ed0` and on the branch | identical, all 36 artifacts, once the checkout's path in reified static-block messages is normalized |

**What failed along the way, and why.** Every failure was a test that pinned
the old behavior or the old text, none a wrong rejection of a valid program:

* pinned the run-time NOT-BOOLEAN of a statically wrong condition:
  `elif.test`'s `elif-non-boolean-condition` (an Int `elif`), `surface-
  lowering.test`'s `lower-boolean-operands` (`1 and true`, `true and 1`,
  `false or 1`, `not 1`), `refinement-validators.test`'s
  `validator-not-a-condition` (a unit validator call). Each now pins the
  compile-time TYPE and its construct's wording; `lower-boolean-operands`
  keeps a run-time half with `any` operands, `validator-not-a-condition` its
  HIR half. Their census rows moved from KEEP-RUNTIME-ONLY to KEEP-INTERNAL
  (they observe messages and HIR fields), and the manifest was regenerated;
* stated the native rule's one statement in its old procedure:
  `method-receiver-types.test`'s `mrt-rule-one-statement` (now: the native
  rules ask `KindMismatch` through `NativeParamKind`, and state no `kindOf`
  of their own);
* a source audit of the exact text of the lines that build `true`/`false`:
  `many-boolean-arguments.test`'s `mb-synthesized-bool-refs-enumerated` (the
  same five sites in `!=`, `not`, `and`, `or`, now wrapped in
  `withWrittenIf`); this is the local suite's one failure on each backend,
  fixed after that file had run and passing since (the `-all 1` row).

No golden suite and no other Tcl test relied on a statically wrong condition
compiling: control.test's `if-4`/`if-5` and backends.test's
`differential-non-boolean` are core IR, which keeps its run-time semantics.

**An unrelated mainline survivor.** `audit/diagnostic-recovery/tools/
mutate.tcl -only poison-return-check` (`hir::range::verifyDeclaredResults`
holding a poisoned function result to its declared type) survives on
`f9e0ed0` too: a poisoned result's inferred type is `never`, which the range
proof admits, so the guard it removes no longer decides an outcome -- an
equivalent mutant on the current mainline, not this milestone's to change.

**In CI.** `tests.yml` (the whole Tcl suite with its duplicates on interp and
compile, the cranelift coverage, the golden suites beside their Tcl
originals, the method-call decision's oracle under the reference audit) and
`static-decisions.yml` (the golden suites' batched against sequential
comparison, which runs in CI only) were dispatched on the branch: runs
41221431429 and 41221434171 on `802ae4f` (the change before the `bool`
short circuit of section 14, which changes no result and whose final code
the local rows above cover). Both are **pending** as this is written, their
jobs waiting for runners: of `tests.yml`, the method-call decision job (its
oracle and fuzzer, and every golden suite under the reference audit), golden
shard 1/4 (the golden suites beside their Tcl originals) and the warning
gate have passed; the interp and compile suites and the native Rust unit
tests are running; the cranelift and cranelift-generic coverage, the stub-
and system-linked executables and golden shards 2-4 are queued. Of
`static-decisions.yml`, the batched-against-sequential comparison has passed
for mutable-array.bot and shards 2/4 and 3/4 (no `DISAGREE`, no `DOES NOT
COMPILE`); shards 1/4 and 4/4 are queued. The push also ran `icy-tower
(windows x86-64)` and `icy-tower (macos arm64)`, which passed.

## 14. Performance

The change is two small checks over facts that already exist; it adds no
analysis, no pass, no fixed point and no run-time operation.

**What it costs per call.** The generic walk asks `RejectsCondition` at every
`if` of every inference round; it is decided by its first test for a
condition typed `bool`, nearly every one: 0.39 µs per call (`time`, 50,000
iterations), 4.8 µs for a condition of another type. The condition's check
runs once per source `if` per check of the program (4.5 µs when it reaches
the kind rule). Counted on the most condition-heavy suites with execution
traces: tests/golden/values.bot asks `RejectsCondition` 4,370 times and
`VerifyCondition` 547 times in one build, about 2 ms of a 3.3 s front end;
the 2048 suite 510 and 243 times. The HIR grows by one small dict field per
source `if`.

**Measured front-end time.** Base `f9e0ed0` against the branch, each
program built in a fresh process, the two trees alternated, the minimum of
three builds each (`surface::readProgramFile`, no cache, warnings off; the
first four rows overlapped another job on the machine, the last line re-times
two of them alone, five builds each):

| program | base (ms) | branch (ms) | |
|---|---:|---:|---:|
| examples/games/2048/golden.bot | 5,294 | 6,255 | +18.2% |
| examples/games/2048/bench.bot | 471 | 479 | +1.6% |
| examples/games/icy-tower/golden.bot | 37,683 | 38,185 | +1.3% |
| examples/games/icy-tower/headless.bot | 3,103 | 3,466 | +11.7% |
| tests/golden/values.bot | 3,331 | 3,342 | +0.3% |
| tests/golden/core-semantics.bot | 9,102 | 9,423 | +3.5% |
| tests/golden/callables.bot | 16,439 | 15,945 | -3.0% |
| tests/golden/declared-errors.bot | 11,768 | 11,619 | -1.3% |
| tests/golden/callable-contracts.bot | 24,257 | 23,652 | -2.5% |
| tests/golden/types.bot | 7,629 | 7,671 | +0.6% |
| tests/golden/loop-collecting.bot | 7,409 | 6,951 | -6.2% |
| tests/golden/coroutines.bot | 12,643 | 14,241 | +12.6% |
| tests/golden/range-and-contract-values.bot | 15,125 | 15,186 | +0.4% |
| tests/golden/branch-form-boolean.bot | 5,459 | 5,834 | +6.9% |
| bench/refined-checks.bot | 657 | 533 | -18.8% |
| bench/uri-steady.bot | 437 | 420 | -3.7% |
| **total** | **160,806** | **163,202** | **+1.5%** |
| re-timed alone: 2048 golden.bot, icy-tower headless.bot | 4,688 / 2,758 | 4,614 / 2,877 | -1.6% / +4.3% |
| the final code, alone, five builds each: coroutines.bot, branch-form-boolean.bot, headless.bot | 12,857 / 5,327 / 3,158 | 12,633 / 5,273 / 3,260 | -1.7% / -1.0% / +3.2% |

The per-program differences scatter in both directions by more than any
cost the change can have (the counts above bound it to milliseconds: on
Icy Tower's headless.bot, whose three re-timings came out +11.7%, +4.3% and
+3.2%, the walk asks `RejectsCondition` 1,701 times, the kind rule runs 882
times for conditions and `KindMismatch` 12,222 times in all -- mostly the
native-argument check that existed before, now one procedure call deeper --
about 17 ms of a 3 s build), and
an earlier run of whole passes over the same sixteen programs measured the
base itself at 193.1 s and 197.3 s, two percent apart: the container's
timing noise is of the order of the totals' difference. These measurements
but the last row were taken before the `bool` short circuit, which lowered
the walk's per-call cost by a further factor of ten. No regression beyond
these milliseconds is attributable to the change.

**Generated code and run time.** Unchanged for accepted programs: the
generated code of twelve programs is identical on both trees (section 13),
so no backend's output and no program's run time changed. The front-end
cache's fingerprint covers `hir/` and `surface/`, so the change invalidated
every older entry once; entries are otherwise as before (one more field per
`if`).

## 15. Remaining limitations

Concrete, independently reproducible issues only:

* **A structural function type's value as a condition compiles and fails
  when it runs.**

  ```
  fn f(g: Fn{args: [], return: int}) -> int:
      if g:
          1
      else:
          2

  fn h() -> int:
      3

  f(h)
  ```

  raises `if condition must be a Boolean, got <block ()>` on every backend.
  The kind rule this milestone shares with native arguments gives a
  structural function type no fixed kind (its value is a Block or a native),
  so it judges neither a condition nor a native argument of that type (a
  `Fn` value given to `std::str::length` also compiles). A function
  *reference* is rejected (`if ready:` for `if ready():`, its type is the
  exact Block's). Closing this means stating "every kind this type admits
  excludes the required one", which the method-call decision's kind proofs
  ask too and AGENTS.md confines to the plain value kinds: one rule for
  natives, conditions and the decision, a change of its own.
* **A loop's operands statically of another kind fail when the loop runs.**
  `loop x in 3:` (`loop iterable: expected list, got 3`, interp; `loop:
  expected list, got 3`, cranelift) and `loop i from 0 to "x":` (`loop end:
  expected int, got "x"`) compile and raise TYPE at run time, the same shape
  as the defect fixed here for a construct that does not consume a Bool (an
  untyped parameter used there already gets the checked contract `list` /
  `int`). Outside this milestone's class (section 3); the fix would be the
  same check for those operands.
* **An affine condition's diagnostic names the wrong position.** `if s:` with
  `s` a coroutine handle is rejected at compile time, as before, by the
  ownership discipline: "`s` is an affine Coroutine{...}, which cannot become
  the value of an if of type int" -- hir/affine.tcl's `Consumer` treats any
  child of an `if` as its value. The rejection is right and kept (section 8);
  its wording describes a branch result, not a condition.

## 16. Handoff to RUNTIME-ERROR-RECOVERY-CENSUS

What remains of NOT-BOOLEAN after this milestone, unchanged on purpose:

* **Where it can arise from source.** Only a condition whose static type has
  no fixed kind: a value of type `any` (a parameter declared `any`, an
  element of a List of mixed values, a result of untyped code that the
  inference leaves `any`), an untyped parameter's value when its caller's
  argument is itself `any` (the checked contract lets an `any` through), and
  a structural function type's value (section 15). Core IR text keeps it for
  any condition.
* **Its observable behavior** is the same on every backend: the program
  stops with `CORE SEMANTIC NOT-BOOLEAN` and `if condition must be a Boolean,
  got V` -- the same text for an operand of `not`, `and` and `or`, which the
  run time does not distinguish from an `if` (the compile-time diagnostic
  does). The failure happens exactly when the operand is tested: after every
  operation before it, never for a right operand a short circuit skips
  (`sbc-any-after-observable-operations`, `sbc-any-dynamic-operands`).
* **It is not a declared error.** No `on` handler catches it, no function's
  `errors` clause admits it, the completion analysis charges no call with
  it, and a `static compile:` block classifies it as a run-time kind
  (tests/static-compile.test's census: `runtime {NOT-CALLABLE NOT-BOOLEAN}`).
  A golden suite that reaches one aborts as a whole (the census rows of
  control.test's `if-4`/`if-5`, backends.test's `differential-non-boolean`,
  surface-lowering.test's `lower-boolean-operands`: RUNTIME-ONLY:NOT-BOOLEAN).
* **Its implementations** are `core::runtime` (the reference interpreter),
  the Tcl compiler's `CompileCondition`, native lowering's `guardbool` with
  the runtime helper `rt_not_boolean` (`RtError::NotBoolean`), each emitted
  only where a condition's kind is not established statically.

Whether a dynamic NOT-BOOLEAN (and TYPE) should become a declared error an
`any` operation carries, and with which obligation, is that census's
question; nothing here presumes the answer.
