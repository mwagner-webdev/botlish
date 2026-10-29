# Trait-implementation context requirements, milestone 1

A compiler-correctness milestone. It fixes the defect recorded in
TRAIT-IMPLEMENTATION-CONTEXT-TRAIT-DEFECT.md (found during
WINDOWS-X86-64-MILESTONE-7.md, section 12.2), and completes for context
requirements what TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md
completed for coroutine effects:

> Once a trait operation's implementation is selected, its actual context
> requirements are attributed to the call. A specialization requires the
> contexts of the implementations it invokes, and acquires no requirements
> from implementations it does not invoke.

It is not a new language feature, a context-trait redesign or a runtime
milestone: no syntax, annotation, dispatch mechanism or provider-passing
convention. The existing language now compiles according to its established
semantics.

## Contents

1. [Result](#1-result)
2. [Starting evidence](#2-starting-evidence)
3. [Root cause](#3-root-cause)
4. [Architecture](#4-architecture)
5. [Feedback and convergence](#5-feedback-and-convergence)
6. [Clone planning](#6-clone-planning)
7. [Diagnostics](#7-diagnostics)
8. [Cross-analysis consistency](#8-cross-analysis-consistency)
9. [Static dependencies](#9-static-dependencies)
10. [Compiler economics](#10-compiler-economics)
11. [Tests and mutants](#11-tests-and-mutants)
12. [Cross-platform regression results](#12-cross-platform-regression-results)
13. [Remaining limitations](#13-remaining-limitations)
14. [Files changed](#14-files-changed)
15. [What to run when changing this](#15-what-to-run-when-changing-this)

---

## 1. Result

**Fixed.** `tclsh9.0 audit/trait-impl-context-trait/tools/run.tcl` reports
`deviations 0` (it reported 15 at the starting tree): every defect case
runs, or is MISSING-CONTEXT, on every backend it can run on, and every
control is unchanged
(`audit/trait-impl-context-trait/results/before-3be0e0c5.txt`, `after.txt`):

| case | before (3be0e0c5) | now |
|---|---|---|
| `entry-io` | CORE MALFORMED | prints `A` twice, value 2 (native backends) |
| `entry-user-trait` | CORE MALFORMED on all four backends | 22 on all four |
| `entry-indirect` | CORE MALFORMED | 2 |
| `module-impl` | Tcl error: `key "message" not known in dictionary` | 2 |
| `split-modules` | CORE MALFORMED | 2 |
| `two-witnesses` | CORE MALFORMED | 22 (A, A, B, B printed) |
| `missing-context` | CORE MALFORMED | MISSING-CONTEXT, in source terms |
| `control-struct` | 22 | 22 |
| `control-none` | 2 | 2 |
| `control-direct` | 2 | 2 |
| `control-context-operation` | 111 | 111 |

The compiler now establishes, for a selected implementation's direct and
transitive requirements:

* a specialization requires what the implementations its operations bind
  require, and nothing of any other: with three witnesses whose
  implementations need `Log`, `Clock` or nothing, `twice` for each needs
  exactly that, a missing `Log` invalidates neither `twice` for B nor for C,
  an ambiguous `Clock` neither `twice` for A nor for C, and the two
  specializations keep their own selections
  (`twice<A,Log=LP>`, `twice<B,Clock=CP>`, `twice<C>`);
* MISSING-CONTEXT and AMBIGUOUS-CONTEXT-IMPLEMENTATION at the top-level call,
  in source terms (the specialization, the operation, its implementation,
  where it is called, the helpers);
* the selected implementation stays selected whatever is installed (no
  SFIAE): a visible context-free `show(A)` never stands in for A's own;
* every replaced implementation is called through its clone, by one rule for
  trait and context-trait operations; no plan action names a dropped
  declaration (checked: TRAIT-INTERNAL, never malformed IR);
* a build whose only diagnostics are the compiler's own is one coded
  COMPILER-INTERNAL error, never an uncoded Tcl crash;
* yields and context requirements come from the same selected implementation
  edges; the monomorphized program has only direct calls, no trait or
  context-trait operation and no runtime selection.

Probing beyond the reproducers found three further failures of the same
family, all fixed (section 3.3): a constrained-slot application checked
again in build 2 found no implementation once the implementation was
replaced; a nested function used as a value that needs a context only in one
specialization; and an operation in a nested function its specialization
never calls. Context *struct* requirements through implementations, which
were checked only in build 2 ("in the monomorphized program: ... twice<A>"),
are now checked in build 1, in source terms.

## 2. Starting evidence

At `3be0e0c5` (the tree this milestone starts from; main), the defect's
runner, unchanged, reproduces the defect record exactly:

```
entry-io                   cranelift-generic  DEFECT: should be value 2, got error MALFORMED
entry-user-trait           interp             DEFECT: should be value 22, got error MALFORMED
...
module-impl                cranelift          DEFECT: should be value 2, got error TCL-ERROR
missing-context            interp             DEFECT: should be error MISSING-CONTEXT, got error MALFORMED
control-struct             interp             ok
...
deviations 15
```

(the whole output: `audit/trait-impl-context-trait/results/before-3be0e0c5.txt`;
every control `ok`). The reproducers were not edited. Without its
installation `control-struct` was, as the record says, a build-2 diagnostic
naming a clone:

```
error: cs-missing.bot:23:1: in the monomorphized program: Log is required by this call but is not
installed here (...):
    twice<A>
     -> show
     -> bump
        directly requires Log (CORE SEMANTIC MISSING-CONTEXT)
```

## 3. Root cause

### 3.1 Confirmed

The record's sections 4.1 to 4.4 hold for the current code, line for line:

1. `hir::contexts::required` derived a function's requirement from calls
   with a known callee; `t.show()` in `twice` has none before
   monomorphization (`hir::contexts::Callee` returns no callee for a typed
   trait operation, CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md), so
   `twice`'s requirement was empty although each specialization needs its
   witness's implementation's.
2. So `hir::contexts::verify` selected nothing for the top-level call and
   reported nothing missing.
3. `hir::traits::Plan` dropped `show` (its requirement includes a context
   trait: it is replaced by its clone) and made no clone of it: no call the
   plan resolves reached it.
4. `PlanCalls`' ordinary-trait branch always named the implementation's
   original declaration (`{trait {... impl {entry show}}}`), with no check
   of the drop, no clone key, no edge and nothing queued; the context-trait
   branch redirected to the clone. Build 2 resolved the dangling identity:
   CORE MALFORMED for the entry program and another module, an UNBOUND
   diagnostic for the module making the call.

### 3.2 Corrected: why `module-impl` crashed

The record says `hir::recovery::reported` "never reports an internal
diagnostic". It does report them in general (the struct case above is one).
What happens in `module-impl`: build 2's two UNBOUND diagnostics are
*resolution* diagnostics, recorded in the HIR twice -- in `diagnostics` and
in `resolutionDiagnostics`. `hir::traits::monomorphize` rewrote the first
list (the "in the monomorphized program: " prefix, `internal 1`) and not the
second, so `reported` no longer found them among the resolution
diagnostics, found them in units those resolution diagnostics taint, and
reported none. `surface::lower::Finish` then raised the empty report and
`core::raiseDiagnostics` read the first entry of nothing. The consequence is
the record's; the fix belongs where it says, at the boundary (section 7.3):
a report can be empty while a build has diagnostics for reasons other than
this one, and recovery's rules stay as they are.

### 3.3 Found beyond the record

Probing the fix with programs the reproducers do not cover found three more
failures of the same family -- each an analysis or a build-2 check reading
the program as written where the specialization, or the replaced
implementation, decides:

* **Constrained slots in build 2.** `struct P[T satisfies Printable]` and an
  imprinted `fn show(p: P[T]): p.value.describe()` whose `describe` for
  Person needs a context trait: build 2 checks the application `P[Person]`
  again, by conformance, which reads the implementation by name in Person's
  namespace -- and the plan had replaced `describe` there by its clone,
  bound under the clone's name: "in the monomorphized program: ... no
  function std::imp::people::describe exists" (TRAIT-NOT-SATISFIED).
* **A function value in one specialization.** A nested function of a
  trait-polymorphic function, performing the operation on the enclosing
  view and used as a value, needs a context only in the specialization
  whose implementation does. The function as written needs nothing, so no
  CONTEXT-FUNCTION-VALUE; nothing selected the context for the
  specialization (the value is no call), and the plan met the
  implementation's clone with no selection (TRAIT-INTERNAL).
* **Never-executed operations.** The same nested function never called:
  the plan walked it in the specialization's clone and met the clone with
  no selection, where code no provider reaches must be the placeholder of
  never-executed code, as for every other context-requiring call.

## 4. Architecture

### 4.1 One selected implementation graph

The yield milestone made hir::check learn, from the plan's own call
resolution, which implementation each trait operation binds and which
specialization each call of a trait-polymorphic function calls
(`hir::coroutines::Implementations` over `hir::traits::PlanCalls`), so the
coroutine analysis sees build 2's call graph in build 1. This milestone
makes that graph *the* call graph through trait operations of the checked
program, read by every analysis that needs one:

```
            hir::traits::PlanCalls (the plan's call resolution)
                         |
       hir::coroutines::Implementations   -- one graph, kept edges:
                         |                   into a node that may yield,
                         |                   receives a yield's value,
                         |                   or carries a context requirement
                         v
           HIR `implementations` (hir::CheckWith, from the feedback)
          /                 |                     \
 coroutine analysis   hir::contexts::verify   hir/staticdeps.tcl, the legacy
 (yields, protocols)  (requirements per       scheduler's units
                      specialization,         (ImplementationTargets)
                      obligations)
```

No consumer resolves a trait operation itself: no second resolver, no
conformance or witness selection of its own, no visible function of the
operation's name, no union over a requirement's implementations. The graph
keeps an edge when it matters to either analysis, so both see the same
edges where they overlap; an edge one analysis does not need changes
nothing in it (an edge into a node that neither yields nor requires
anything adds no yield, protocol constraint or requirement).

The graph had to change in one respect: a specialization was named by its
clone key, `{FUNCTION WITNESSES SELECTION ?BINDING?}`, and the selection is
exactly what the context analysis now learns from the graph. A key that
changes between checks would leave stale nodes in the union. The graph
names a specialization by its identity, `{FUNCTION WITNESSES BINDING}`
(`hir::traits::Specialization`); the clone key's selection is a function of
it (the program's providers of the context traits that specialization
requires), so the identity is stable while the feedback learns.

`hir::traits::PlanCalls` records, besides the plan's actions, what every
call binds (`bound`), also when the plan makes the call the placeholder of
never-executed code because the check's selection does not reach it: what an
operation binds does not depend on which providers the check knew, and the
feedback must not lose an edge to a selection it has not learned yet.

### 4.2 Requirements per specialization

`hir::contexts::Requirements` (factored out of `verify`) computes the
requirement fixed point over nodes: every block (each function as written),
and for each specialization K of the graph, `{K BLOCK}` for every block of
its function's region (the block as the clone K has it). A node's call
edges (`hir::contexts::Targets`):

| call | in a specialization K | in a block's own node |
|---|---|---|
| an ordinary trait operation | the implementation the graph binds in K | only where the graph binds it alike for every witness (a concrete view), else none |
| a context-trait operation | none: its implementation is the installed provider's, whose requirement is the selecting call's obligation (`Obligations`, unchanged) | none |
| a call of a trait-polymorphic function the graph resolves | the specialization's function node `{K' F}` | the same, for a call passing concrete witnesses |
| any other call | its exact callee, in K's region a node of K | its exact callee |

So `twice` as written requires nothing, `{twice for A}` requires `Log`, and
an ordinary function calling `twice(A {...})` requires `Log` too (and becomes
context-trait-dependent, cloned under the selection, as any caller of a
context-trait function). A top-level call's obligations are its targets'
requirements (`Obligations` now takes the list of target nodes): the
specialization it calls, or the implementation of a top-level operation on
a concrete view. `verify` records each specialization's requirement
(`contexts specialized`), which the plan reads for the clone's selection.

### 4.3 What the language already said

Nothing here is a new rule: CONTEXT-TRAITS.md's "every function whose
requirement includes a context trait is cloned for the selection" now holds
for implementations too; MISSING-CONTEXT and AMBIGUOUS-CONTEXT-IMPLEMENTATION
are the existing obligations of a valid call (`hir::CheckingCall`,
`hir::methods::ObligationKinds`); the selected implementation is the
witness's, by the existing conformance (`hir::traits::satisfies`, the
witness's owner namespace only), whatever is installed.

## 5. Feedback and convergence

The order, per check of build 1 (`hir::check`, unchanged in shape):

1. `hir::CheckWith` stores the feedback's graph in the HIR
   (`implementations`, only when it has an edge) and the coroutine analysis
   reads it as before;
2. typing decides which calls are trait operations and their witnesses;
3. `hir::contexts::verify` computes requirements over the graph's nodes,
   checks every reachable top-level call's obligations, selects providers
   (`contexts selected`, program-wide as before) and records each
   specialization's requirement;
4. `Feedback` asks the plan's call resolution -- with this check's
   selection and specialization requirements -- what every operation and
   call binds, and adds the edges it keeps to the graph;
5. if the graph grew, check again from the same input.

The plan of build 2 (`hir::traits::Plan`) runs on the last check, whose
graph is the fixed point: the requirements it read are the ones the plan's
own walk binds.

**Why it stabilizes.** As for yields: the feedback is the union of every
check's, over finitely many calls, implementations and specializations (the
specializations come from semantic instances, which are budgeted), so it
only grows and is finite. What makes the context edges converge too is that
none of them depends on a selection: an operation's implementation is its
witness's (typing), a call's specialization its instance's (typing), and
the specialization's identity has no selection in it (4.1). The selection
changes only clone keys and placeholder actions, which are no part of the
graph. Typically build 1 is checked twice: the first check finds the edges,
the second confirms them with the requirements they imply. A third check is
needed only where the yield milestone's is (a typing the second check makes
gives an operation a witness it had none for). `hir::check`'s bound of 64
checks, an internal error only a compiler bug could reach, is unchanged.

**An impossible or inconsistent plan.** A replaced implementation or a
specialization whose context traits have no selection where the plan must
call its clone is TRAIT-INTERNAL ("... has no selected context provider")
-- never in a converged valid program, where the top-level call that
reaches it selected (or failed to select: then build 1 already reported
MISSING-CONTEXT or AMBIGUOUS-CONTEXT-IMPLEMENTATION and the plan never
runs). Polymorphic recursion across witnesses stays TRAIT-POLYMORPHIC-
RECURSION; a clone needed before its implementation is established stays
TRAIT-IMPL-ORDER, which now also covers a replaced implementation (the
order check reads every implementation an operation calls).

**When the plan is asked.** The yield milestone's gate (`MayBind`) asks the
plan only when an edge could be kept. The context half
(`hir::coroutines::ImplementationsRequire`): an implementation of an
ordinary trait the program performs an operation of has a context
requirement in the check. Every context requirement starts at a context
parameter and, after the last operation on the way, is reached through
ordinary calls and calls of functions as written, which the check sees with
no trait-operation edge: so that operation's implementation already has a
requirement. A function that declares a context parameter is no
implementation (TRAIT-NOT-SATISFIED) and is left out; so are context
traits' implementations, whose requirements are the selecting call's
obligations.

## 6. Clone planning

### 6.1 One rule for both kinds of operation

`PlanCalls` resolved a context-trait operation whose implementation is
replaced to `{context OPERATION KEY}` with an edge and the clone queued, and
an ordinary trait operation always to `{trait OPERATION}`. Both now go
through one procedure, `hir::traits::CallImplementationClone`: when the
implementation is a function the plan replaces (`IsReplaced`, the drop
condition `Replaces` stated once), the action is `{KIND OPERATION KEY}`,
KEY the clone the selection in force makes of it; the placement edge is
recorded (`CallsClone`: from live code the top-level position, from a clone
an edge, which `TopoOrder` and TRAIT-POLYMORPHIC-RECURSION read) and the
clone is queued; build 2 resolves the action to the clone
(`hir::resolve::ResolvePlannedCall`'s `trait` case reads KEY as the
`context` case did). The order check (TRAIT-IMPL-ORDER) now reads every
implementation an operation calls, replaced or not.

The rule is stated for every declaration the plan replaces. Today an
implementation can be replaced only because its requirement includes a
context trait (one clone, under the program's providers): a
trait-polymorphic implementation would need a requirement over another
trait (rejected: trait composition), an imprinted one does not satisfy a
requirement. For those kinds the procedure names no clone and reports
TRAIT-INTERNAL ("replaced by specializations this operation selects none
of") rather than an action that would dangle, so lifting either restriction
cannot silently reopen the defect.

### 6.2 Selections per specialization

A specialization's clone key carries the selection of its own requirement
(`hir::traits::SpecializationTraits`, from `contexts specialized`, and
`SpecializationSelection`), so `twice<A,Log=LP>` and `twice<B,Clock=CP>` are
two clones under two selections, and a clone's `provided` set is what its
code may call. A specialization whose requirement includes context traits
its function as written does not is reached exactly as a context-requiring
function is (`CallSpecialization`): from a reachable top-level call, or a
reachable call in a clone providing those traits; anywhere else it is
never-executed code, the placeholder `context#unreachable`. A call of a
replaced implementation follows the same rule (3.3, the third case).

### 6.3 No action names a dropped declaration

`hir::traits::Dangling` checks the plan before build 2: every action --
`redirect`, `trait`, `context` (with or without a clone key), `method`, and
the method choices of every clone's calls the actions do not override --
names an identity build 2 can resolve: never a declaration the plan drops
(by its `{entry NAME}` or `{module NS NAME}` identity, aliases included),
never a clone it does not make. A violation is TRAIT-INTERNAL at the call
(`Plan` returns it as a plan diagnostic, `monomorphize` reports it on the
checked HIR), never `core::malformed` in build 2. No program of the tests,
the golden suites or the fuzzers triggers it; the mutant that restores the
original defect (`trait-redirect-dropped`) is reported by it, and a mutant
that removes the check is killed by `trait-implementation-context-dangling`,
which builds a valid plan, removes a clone key from an action (the original
defect) or names a clone the plan does not make, and expects the
diagnostic.

### 6.4 The replaced implementation in build 2

Build 2 checks a constrained slot's application (`P[Person]`, a type
written in the program) again, by conformance, which reads Person's
namespace by name. The plan places a replaced implementation's clone where
its first user needs it, under the clone's name. In the planned build the
implementation index (`hir::traits::index`) lists that clone under the name
of the function it replaces, in its own namespace: in the monomorphized
program the implementation *is* the clone (`trait-implementation-context-
imprint`, `[204, 106]` on four backends).

## 7. Diagnostics

### 7.1 Missing and ambiguous providers

Reported at the top-level call, in source terms -- no clone key, no
"monomorphized program". The chain names the specialization by its function
and witnesses, the step through the operation by the operation, its trait,
the selected implementation and where the operation is called, then the
helpers to the function that declares the context
(`hir::contexts::ChainLines`, `NodeName`, `Via`):

```
std::io::IO is required by this call, but no installed context implements it (install one with
"with context EXPR" before the call):
    twice (for A)
     -> show, the implementation of Thing's operation show for A, called at main.bot:18:5
     -> std::io::print_line
        directly requires std::io::IO
installed contexts:
    none
```

Through a context-trait provider whose own implementation needs another
context trait, and through another specialization an implementation calls,
the chain continues as before:

```
    std::tic::traits::twice (for std::tic::d::D)
     -> std::tic::d::show, the implementation of std::tic::traits::Thing's operation show for std::tic::d::D, called at tic/traits.bot:17:5
     -> std::tic::traits::twice (for std::tic::a::A)
     -> std::tic::a::show, the implementation of ... for std::tic::a::A, called at tic/traits.bot:17:5
     -> std::tic::a::via
     -> std::tic::traits::logged
        directly requires std::tic::traits::Log
```

AMBIGUOUS-CONTEXT-IMPLEMENTATION applies the existing semantics: every
installed provider listed, no ranking, no installation-order preference,
reported only at a call whose specialization needs the trait.

| situation | diagnostic |
|---|---|
| a selected implementation needs a context no installed context provides | MISSING-CONTEXT at the top-level call |
| two installed providers of a context trait it needs | AMBIGUOUS-CONTEXT-IMPLEMENTATION at that call |
| an unused provider, or two of a trait no selected implementation needs | none |
| a witness whose implementation needs nothing | none, whatever others need |
| a context struct it needs, not installed | MISSING-CONTEXT in build 1 (was: in the monomorphized program, naming `twice<A>`) |
| a nested function used as a value that needs a context in one specialization | CONTEXT-FUNCTION-VALUE at the use: `function inner (for A) requires context Log ...` |
| a construction whose implementation yields and needs a missing provider | MISSING-CONTEXT (its UNWRAPPED-YIELD or acceptance unchanged otherwise) |
| a plan action naming a dropped declaration or an unmade clone | TRAIT-INTERNAL at the call (a compiler bug) |

### 7.2 No unnecessary obligations, no fallback

A specialization acquires nothing from an implementation it does not invoke
(the graph has no edge to it), so an unavailable context of an unused
witness's implementation is no obligation of any call
(`trait-implementation-context-missing`, `-ambiguous`). Provider
availability never selects an implementation: with no `Log` installed, an
operation on A still binds A's own `show` (MISSING-CONTEXT), although a
context-free function `show(A)` is visible to the program; installing a
provider changes no selection (`trait-implementation-context-no-fallback`).

### 7.3 A build whose diagnostics are all the compiler's

`hir::recovery::entries` never returns an empty report for a build with
diagnostics: when none is reported -- each the compiler's own -- it returns
one COMPILER-INTERNAL entry (`{CORE SEMANTIC COMPILER-INTERNAL}`,
`hir::recovery::Internal`) whose text names each of them with its kind, as
the compiler's, located at the first, its record holding them all. Recovery's
rule is unchanged: none of them is presented as a source error of its own
(no entry, no code, no help topic of its kind). The strict boundary
(`surface::lower::Finish`, `hir::buildSyntax`'s) and the compiler service
read the same entries, so a lenient analysis of such a build is a failure,
never a clean revision; `core::raiseDiagnostics` refuses an empty list with
the same code. Its Compilerpedia topic is `error.compiler-internal`, and the
kind is in tests/static-compile.test's census (`internal`: never a static
block's rejection). The regression tests (`dr-internal-*`,
tests/diagnostic-recovery.test) construct the state independently of the
trait plan -- a lenient build whose resolution diagnostics are rewritten as
`monomorphize` rewrites build 2's -- so they keep exercising the boundary
now that the plan no longer produces it; ordinary and mixed builds report
exactly what they did.

## 8. Cross-analysis consistency

* **One graph.** The coroutine analysis and the context analysis read the
  same edges (4.1): an implementation that both yields and needs a context
  contributes both through the same edge
  (`trait-implementation-context-yield`: `[5, 5, 210, 6]` with the provider,
  MISSING-CONTEXT without it, UNWRAPPED-YIELD at a top-level call, and the
  context-free witness's specialization acquires neither effect).
* **Build 1 and build 2 agree.** `trait-implementation-context-agreement`
  compares, per specialization, the context traits of build 1's requirement
  with the selection of its clone in build 2, and the contexts the clone
  requires with the selected providers' -- identical. The yield milestone's
  `trait-implementation-yield-agreement` still holds.
* **The monomorphized program.** No trait or context-trait operation is
  left; every former operation is a direct call of a clone the plan made or
  of an implementation it did not replace
  (`trait-implementation-context-monomorphized`); `trait-source-audit`,
  `ct-source-audit` and the native evidence tests are unchanged: no runtime
  provider lookup, slot, dictionary or hidden argument.

## 9. Static dependencies

The new cross-function fact is a function's requirement read through its
specializations' implementations. `hir::coroutines::ImplementationTargets`
(call -> implementation blocks) now reads the shared graph, so
hir/staticdeps.tcl's regions' own targets, subtrees and call edges follow
an operation to the implementation it binds whether it yields or carries a
requirement; the legacy scheduler's units (`hir::static::Units`) follow the
same targets (a trait operation calls the implementation the program
selects for it, which its references never showed). The edges are a
superset per operation over the specializations the program makes --
conservative, never across an implementation no specialization selects.

The change experiments (section 13 of the brief), each decided by the
batched and the sequential scheduler alike with no build contradicting a
prediction, as static decisions (tests/static-economics.test):

| experiment | test | outcome |
|---|---|---|
| a selected implementation acquires / loses a requirement | `se-equal-implementation-context` | g's block CONTEXT-FUNCTION-VALUE / accepted, depending on show's block |
| a helper of the selected implementation acquires / loses one | `se-equal-implementation-context-changes` | the same through `via` |
| an unselected implementation changes its requirement | same | g's decision does not wait for it: every independent rejection in one round |
| an implementation changes its yield and its requirement together | same | the construction accepted / COROUTINE-RHS-NOT-YIELDING, waiting for the block it depends on |

and as edits through the front-end cache (`hc-implementation-context-edits`,
tests/hir-cache.test: an implementation acquiring a requirement, an
installation added and removed, the requirement moving into a helper, a
second provider, the witness changing, an unselected implementation
changing, an implementation changing its yield and requirement): every
compilation through the cache has the outcome of a clean one. (Installations
are top-level statements, never inside a static block, so they are edits,
not static decisions.)

Without the new targets the batched scheduler mispredicts and disagrees with
the sequential order (the mutant `staticdeps-implementation-contexts-
ignored`, which keeps only yield-capable implementations: g's block is
committed as rejected); without them in the legacy units, the legacy
scheduler rejects g's block beside show's (`legacy-units-without-
implementations`). The `static-decisions` workflow's comparison of the two
schedulers over every golden suite is section 12's.

## 10. Compiler economics

**Counts** (deterministic, `hir::BuildStats` and a count of `hir::traits::
Plan`/`PlanCalls`; the starting tree `3be0e0c5` against the final one, each
program compiled once with no front-end cache): builds / checks / trait
plans / effect plans (the feedback's plan runs):

| program | before | now |
|---|---|---|
| golden `traits.bot` | 8 / 7 / 3 / 0 | 8 / 7 / 3 / 0 |
| golden `traits-path.bot` | 3 / 3 / 1 / 0 | 3 / 3 / 1 / 0 |
| golden `contexts.bot` | 6 / 5 / 1 / 0 | 6 / 5 / 1 / 0 |
| golden `coroutines.bot` | 5 / 4 / 1 / 0 | 5 / 4 / 1 / 0 |
| golden `trait-constrained-types.bot` | 4 / 3 / 1 / 0 | 4 / 3 / 1 / 0 |
| golden `hashable.bot` | 3 / 3 / 1 / 0 | 3 / 3 / 1 / 0 |
| golden `mutable-map.bot` | 5 / 5 / 1 / 0 | 5 / 5 / 1 / 0 |
| golden `structs-and-enums.bot` | 6 / 5 / 1 / 0 | 6 / 5 / 1 / 0 |
| golden `ownership.bot` | 5 / 4 / 1 / 0 | 5 / 4 / 1 / 0 |
| golden `harness.bot` | 2 / 1 / 0 / 0 | 2 / 1 / 0 / 0 |
| event loop `a-smoke`, `a-gameserver` | 3 / 3 / 1 / 0 each | 3 / 3 / 1 / 0 each |
| yield repro `ordinary/coroutine.bot`, `context/coroutine.bot` | 2 / 3 / 1 / 2 each | 2 / 3 / 1 / 2 each |
| `control-none`, `control-direct`, `control-context-operation` | 2 / 2 / 1 / 0 each | 2 / 2 / 1 / 0 each |
| `control-struct` (a context struct through the implementation) | 2 / 2 / 1 / 0 | 2 / 3 / 1 / 2 |
| `entry-io`, `entry-user-trait`, `entry-indirect`, `split-modules` | 2 / 1 / 1 / 0 (CORE MALFORMED) | 2 / 3 / 1 / 2 (runs) |
| `module-impl` | 2 / 2 / 1 / 0 (Tcl error) | 2 / 3 / 1 / 2 (runs) |
| `two-witnesses` | 2 / 1 / 1 / 0 (CORE MALFORMED) | 2 / 3 / 1 / 2 (runs) |
| `missing-context` | 2 / 1 / 1 / 0 (CORE MALFORMED) | 1 / 2 / 0 / 2 (MISSING-CONTEXT in build 1) |

Every program that needs no edge through an implementation's requirement
compiles with exactly the builds, checks, plans and effect plans it did. A
program that does checks its source build twice (the second confirms the
edges) -- one check more than a program whose implementations need nothing,
and the same as the yield milestone's programs -- and one that misuses it is
now rejected one build earlier. `trait-implementation-context-economics`
pins both, including a program that loads std::io::fs (whose FilePath
implementations need LinuxFS) without performing a FilePath operation, and
one whose only function with a context parameter is no implementation.

**What the measurements changed.** The first version of the gate asked the
plan whenever any declared ordinary trait had an implementation with a
requirement: traits.bot, contexts.bot and traits-path.bot -- which load
std::io::fs through std::linux::path, or declare an implementation-shaped
function with its own context parameter -- ran 6, 4 and 2 effect plans that
kept nothing. Restricting the gate to the traits the check's operations
perform, and leaving out functions that declare a context parameter (never
implementations), brought every one back to 0 (the mutant
`context-plan-gate-every-trait` keeps it).

**Specialization workloads.** The adversarial programs of the tests and the
fuzzer (three witnesses with distinct needs, several specializations of one
function, two context traits, nested and recursive specializations, unused
implementations, a provider whose implementation needs another context
trait): every one settles in two checks of build 1; the graph holds one
impl edge per operation per specialization that needs it and one spec edge
per call of a needing specialization (`two-witnesses`: 4 impl and 2 spec
edges, 2 specializations, 5 clones). Nothing enumerates witness and provider
combinations: requirements are a fixed point over the specializations the
plan makes, and the selection is the existing program-wide one.

**Time.** PENDING: the share of each compilation spent in the feedback's
plan runs and in `hir::contexts::Requirements`, measured on an idle
container after the full suite.

## 11. Tests and mutants

**Regression tests** (every accepted program on interp, compile,
cranelift-generic and cranelift through one HIR: `sourceAgree`,
`moduleAgree`):

* tests/traits.test: `trait-implementation-context-witnesses` (three
  witnesses, a specialization calling another), `-per-specialization`
  (requirements, selections and clone keys per specialization), `-missing`,
  `-ambiguous`, `-transitive` (helpers, an implementation calling another
  specialization, a recursive helper, trait-polymorphic self-recursion, a
  provider whose implementation needs another context trait), `-yield`,
  `-no-fallback`, `-layouts` (the defect's entry-user-trait, module-impl and
  split-modules shapes, with the program's own context trait, and their
  missing installations), `-imprint`, `-reach`, `-function-value`,
  `-monomorphized`, `-dangling`, `-economics`, `-agreement`.
* tests/context-traits.test: `ct-implementation-context-provider` (a
  provider's own implementation reaching such an operation; declaration and
  installation order), `ct-implementation-context-summary` (`-contexts`).
* tests/portable-io.test: `io-implementation-context` (std::io::IO through
  implementations in the entry program, a module of their own, two
  witnesses in two modules, under a test provider: four backends),
  `io-implementation-context-missing`, `io-implementation-context-executable`
  (entry-io as a standalone executable over std::linux::io).
* tests/diagnostic-recovery.test: `dr-internal-only-coded`,
  `-only-entries`, `-mixed-ordinary`, `-ordinary-unchanged`, `-empty-raise`.
* tests/static-economics.test: `se-equal-implementation-context`,
  `se-equal-implementation-context-changes`.
* tests/hir-cache.test: `hc-implementation-context-edits`.
* tests/filesystem.test: `fs-missing-context-linux`'s description (the
  requirement is now found in the checked program).

**The differential fuzzer**, `audit/trait-implementation-yield/tools/
fuzz.tcl`, extended (`-contexts 1`, the default; `-contexts 0` generates the
yield milestone's programs exactly, from a random stream of their own):
each implementation also needs `Log`, `Clock` or nothing, through 0-2
helpers, and the program installs 0, 1 or 2 providers of each. Its oracle
knows the selected implementation's need: no provider is MISSING-CONTEXT,
two AMBIGUOUS-CONTEXT-IMPLEMENTATION, one adds the provider's value; another
implementation's need or an unused provider changes nothing; with the yield
forms (coroutine, top-level call, both specializations in one program).

| run | programs | forms | accepted | needing a context | failures |
|---|---:|---:|---:|---:|---:|
| seed 1 | 40 | 99 | 28 | 25 | 0 |
| seed 2 | 40 | 99 | 26 | 25 | 0 |
| seed 3 | 40 | 100 | 27 | 29 | 0 |
| the starting tree (`3be0e0c5`), seed 1, interp and cranelift, 12 programs | 12 | 32 | 7 | 7 | **11** (6 CORE MALFORMED) |

**Mutants.** New mutants, each killed by a test of the invariant it
violates (results: PENDING), and two re-anchored to code this milestone
moved, each still a mutant of the same rule (`transitive-trait-requirement-
dropped`, context-traits; `context-reselected-per-resume`, coroutines):

| harness | mutant | the invariant it violates |
|---|---|---|
| context-traits | `implementation-context-ignored` | a selected implementation's requirement is the call's (1) |
| traits | `context-requirement-from-function-as-written` | requirements per specialization, not from the function as written (2) |
| traits | `context-requirement-every-witness` | no union over the witnesses' implementations (3) |
| traits | `specialization-selection-shared` | each specialization its own selection (4) |
| traits | `trait-redirect-dropped` | the trait operation's clone redirection (5) |
| traits | `implementation-clone-not-queued` | the replaced implementation's clone is made (6) |
| traits | `clone-edge-omitted` | the placement edge to the clone (7) |
| traits | `dangling-unchecked` | no action names a dropped declaration (8) |
| static-decisions | `staticdeps-implementation-contexts-ignored`, `legacy-units-without-implementations` | requirements in the static dependency model (9) |
| traits | `context-requirement-lost-when-yielding` | one implementation's yield and requirement both (10) |
| context-traits | `implementation-missing-context-suppressed` | MISSING-CONTEXT for a specialization's requirement (11) |
| context-traits | `ambiguous-provider-chosen` | no provider chosen among several (12) |
| diagnostic-recovery | `internal-only-empty-report`, `internal-only-presented-as-source` | the empty report (13) and recovery's policy |
| traits | `context-edges-unkept`, `context-plan-gate-closed`, `context-plan-gate-every-trait` | the graph keeps context edges; the gate asks for them, and only when they can exist (economics) |
| traits | `replaced-implementation-unindexed`, `function-value-judged-as-written`, `implementation-clone-reached-everywhere` | section 3.3's three cases |

Semantic mutants (1-5, 9-12) are killed by a behavior test: a program that
runs wrongly, a diagnostic missing or added, a scheduler disagreement.
Internal-invariant mutants (6-8) are killed by the plan's own check or by
the unit test of `hir::traits::Dangling`; the economic one
(`context-plan-gate-every-trait`) only by `-economics`.

**Existing harnesses and suites.** PENDING (section 12).

## 12. Cross-platform regression results

PENDING: `tclsh9.0 tests/local.tcl` (every Tcl test file on interp and
compile, every golden suite on four backends), the mutation harnesses, and
CI on the branch: tests.yml, tests-arm64.yml, macos-arm64.yml,
windows-x86_64.yml and static-decisions.yml.

## 13. Remaining limitations

* **An implementation still cannot declare a context parameter**
  (`fn show(t: B, context c: Clock)`: TRAIT-NOT-SATISFIED, "context-dependent
  implementations are not supported yet"). It acquires a requirement only
  through what it calls, which is every case this milestone covers; lifting
  the restriction is a language decision, not a fix of inference.
* **The yield milestone's boundary is unchanged**: a coroutine construction
  inside a trait-polymorphic function whose root yields only through that
  function's own witnesses is judged by the function as written
  (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md, section 12). Context
  requirements have no such boundary: a requirement is a fact of each
  specialization, checked where the specialization is called, and a
  function value is judged per specialization (7.1).
* **A construction's selection failure** through a specialization is
  reported beside COROUTINE-RHS-NOT-YIELDING when the selected
  implementation does not yield: both are independently true (the
  implementation is selected whatever is installed), unlike a context
  trait's operation, whose implementation does not exist without a provider
  (the yield milestone's suppression is for that case).

## 14. Files changed

Compiler:

* `hir/contexts.tcl` -- `Requirements` (the requirement fixed point over the
  graph's nodes, factored out of `verify`), `Targets` (each call's nodes per
  context), `verify` (top-level targets, `contexts specialized`),
  `Obligations` (a list of target nodes), `ChainLines`/`NodeName`/`Via`
  (chains in source terms), `CheckValues` (function values per
  specialization), `summary` (`specialization` lines).
* `hir/traits.tcl` -- `PlanCalls`: per-specialization selections
  (`SpecializationTraits`, `SpecializationSelection`), `CallSpecialization`,
  `CallImplementationClone` (one rule for both kinds of operation),
  `CallsClone`, `bound`; `Replaces`/`IsReplaced`; `Specialization`;
  `Dangling` and `Plan`'s check; clone records' `fname` and the key's
  selection; `index` (a replaced implementation's clone in build 2);
  `SetAction` records `bound`.
* `hir/coroutines.tcl` -- `Implementations` (the shared graph: every
  binding, specialization identities, context-relevant edges, no coroutine
  required), `MayBind` and `ImplementationsRequire` (the gate),
  `ImplementationTargets` (the shared graph), `AddClone`.
* `hir/hir.tcl` -- `hir::CheckWith` stores the feedback's graph as the
  HIR's `implementations`.
* `hir/resolve.tcl` -- `ResolvePlannedCall`'s `trait` case with a clone key.
* `hir/recovery.tcl` -- `entries` never empty for a build with diagnostics;
  `Internal`.
* `core/errors.tcl` -- `core::raiseDiagnostics` refuses an empty report.
* `hir/static.tcl` -- the legacy scheduler's `Units` follow implementation
  targets.

Tests, tools and evidence: the test files of section 11;
`audit/trait-implementation-yield/tools/fuzz.tcl`; mutants in
`audit/traits/tools/mutants.txt` (14 new), `audit/context-traits/tools/
mutants.txt` (3 new, 1 re-anchored), `audit/coroutines/tools/mutants.txt` (1
re-anchored), `audit/static-decisions/tools/mutants.txt` (2 new),
`audit/diagnostic-recovery/tools/mutants.txt` (2 new);
`audit/trait-impl-context-trait/results/` (the runner's output before and
after).

Documentation: this report; TRAIT-IMPLEMENTATION-CONTEXT-TRAIT-DEFECT.md
(status: resolved); CONTEXT-TRAITS.md (sections 5 and 6); TRAITS.md
("Specialization", "Contexts"); AGENTS.md ("Traits": the selected
implementation graph); INDEX.md; Compilerpedia's `error.missing-context`
(the meaning, a likely cause, an example), `error.ambiguous-context-
implementation`, `error.context-function-value` and the new
`error.compiler-internal`.

## 15. What to run when changing this

If you change the selected implementation graph (`hir::coroutines::
Implementations`, `Distinct`, `MayBind`, `ImplementationsRequire`,
`ImplementationTargets`), the context requirement graph
(`hir::contexts::Requirements`, `Targets`, `Obligations`, `CheckValues`),
the plan's call resolution or clone planning (`hir::traits::PlanCalls`,
`CallSpecialization`, `CallImplementationClone`, `CallsClone`,
`SpecializationTraits`, `Specialization`, `Dangling`, `index`'s planned
part), `hir::CheckWith`'s feedback, `ResolvePlannedCall`, or the recovery
boundary (`hir::recovery::entries`, `Internal`, `core::raiseDiagnostics`),
run:

* `tclsh9.0 audit/trait-impl-context-trait/tools/run.tcl` (exits 0);
* tests/traits.test, tests/context-traits.test, tests/portable-io.test,
  tests/contexts.test, tests/coroutines.test,
  tests/trait-constrained-types.test, tests/diagnostic-recovery.test,
  tests/static-economics.test, tests/static-compile.test,
  tests/hir-cache.test, tests/filesystem.test,
  tests/compiler-service.test;
* `audit/trait-implementation-yield/tools/fuzz.tcl` (several seeds; once
  with `-gc-stress 1`), `audit/traits/tools/fuzz.tcl`,
  `audit/context-traits/tools/fuzz.tcl`;
* the mutation harnesses `audit/traits/tools/mutate.tcl`,
  `audit/context-traits/tools/mutate.tcl`,
  `audit/coroutines/tools/mutate.tcl`,
  `audit/static-decisions/tools/mutate.tcl` and
  `audit/diagnostic-recovery/tools/mutate.tcl` (every mutant must still
  apply and be killed: update a mutant's text when you change the code it
  mutates, keeping it a mutant of the same rule);
* the static-decision harnesses, and the `static-decisions` workflow on the
  branch (batched against sequential, in CI only);
* `tclsh9.0 tools/compilerpedia.tcl check`.
