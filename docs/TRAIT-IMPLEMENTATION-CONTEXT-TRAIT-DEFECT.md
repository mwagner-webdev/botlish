# TRAIT-IMPLEMENTATION-CONTEXT-TRAIT-DEFECT.md

A defect record, written to be the starting evidence of the milestone that
fixes it: what fails, exactly when, why (traced to the code), what a fix must
establish and how it will be accepted. Nothing here is fixed. Found while
designing std::io::fs (WINDOWS-X86-64-MILESTONE-7.md, section 12.2);
re-checked after merging main at 7aec2a11 (which includes
TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md, the nearest related
work): unchanged.

> A trait operation whose selected implementation needs a context trait
> cannot be compiled. The trait plan replaces that implementation by its
> clones but never makes one, and never redirects the operation to one: the
> monomorphized program refers to a declaration that no longer exists.

## Contents

1. Summary
2. Reproducing it
3. Who is affected
4. Root cause
5. Why the layouts fail differently
6. Two further defects on the same path
7. Fixes that do not work
8. What the fix must establish
9. Acceptance
10. Evidence and history

## 1. Summary

A program with an ordinary (source) trait `Thing`, a witness `A`, and A's
implementation of a requirement `show` whose body needs a **context trait**
-- the standard library's `std::io::IO` (through `std::io::print_line`) or
one the program declares -- and a trait-polymorphic function calling the
operation (`fn twice(t: Thing): t.show() + t.show()`), fails to compile on
every backend. It never reaches a backend: the failure is in the front end's
second build (the monomorphized program), and what the user sees depends on
where the implementation is declared:

| implementation declared in | what the compiler reports |
|---|---|
| the entry program | `malformed IR: trait plan: entry-program binding "show" is not established here` (CORE MALFORMED) |
| the module that calls the operation | a Tcl error, `key "message" not known in dictionary`: the compiler crashes (section 6.2) |
| another module | `malformed IR: unresolved module reference M::show` (CORE MALFORMED) |

With the installation missing it should be MISSING-CONTEXT; it is the same
internal error (section 6.1). The same program runs when the implementation
needs a context **struct**, or no context, or when it is called directly
rather than through the trait.

## 2. Reproducing it

`audit/trait-impl-context-trait/` holds one program per case (`repro/NAME/`,
an entry `main.bot` and its application modules) and a runner:

    tclsh9.0 audit/trait-impl-context-trait/tools/run.tcl

It compiles and runs each case through main.tcl on the backends it can run
on -- the ones that print through std::linux::io on the native backends (the
Tcl backends refuse a syscall's byte buffer at run time, as for every Linux
I/O program), the others on all four -- and compares the outcome with what
the program should do. It exits 1 while any case deviates; the controls must
always pass. The original reproducer,
`audit/filesystem/findings/trait-plan-entry-context-trait.bot`, is the
`entry-io` case.

Result at commit 06bb06ef (this branch with main 7aec2a11 merged; real
Linux x86-64):

| case | what it is | should | is |
|---|---|---|---|
| `entry-io` | trait, witness, implementation (needs std::io::IO through print_line) and caller in the entry program | 2, printing `A` twice | CORE MALFORMED (entry binding not established) |
| `entry-user-trait` | the same with the program's own `context trait Out` and its own context `K` -- no standard library | 22 | CORE MALFORMED, on all four backends |
| `entry-indirect` | the implementation needs the context trait only through a helper it calls | 2 | CORE MALFORMED |
| `module-impl` | trait, witness, implementation and caller in one application module | 2 | Tcl error (the compiler crashes) |
| `split-modules` | std::io::fs's layout: the trait and its caller in one module, the witness and its implementation in another | 2 | CORE MALFORMED (unresolved module reference) |
| `two-witnesses` | two witnesses, both implementations needing std::io::IO, each in its own module | 22 | CORE MALFORMED |
| `missing-context` | `entry-io` without `with context` | MISSING-CONTEXT | CORE MALFORMED |
| `control-struct` | the implementation needs a context **struct** (derived through a helper) | 22 | 22 on all four backends |
| `control-none` | the implementation needs no context | 2 | 2 on all four backends |
| `control-direct` | the `entry-io` implementation called directly, not through the trait | 2 | 2 |
| `control-context-operation` | a context-trait operation (`out.emit`) whose selected implementation itself needs another context trait | 111 | 111 on all four backends |

`runner: deviations 15` (every defect case on each of its backends), every
control `ok`.

## 3. Who is affected

* **Affected:** any trait operation reached through a trait-polymorphic
  function whose selected implementation's requirement includes a context
  trait -- directly (a context-trait parameter), or derived (a call of a
  function that needs one, at any depth: `entry-indirect`). The standard
  library's `std::io::IO` is a context trait, so an implementation that
  prints is enough. Where the implementation lives does not matter (section
  5); the number of witnesses does not.
* **Not affected:** an implementation that needs a context struct (its
  requirement is checked in the monomorphized program and reported there,
  MISSING-CONTEXT included: `control-struct`); an implementation called
  directly (`control-direct`); a context trait's own operation whose
  selected implementation needs another context trait
  (`control-context-operation`: that branch of the plan redirects to the
  implementation's clone, section 4.4).
* **std::io::fs** (WINDOWS-X86-64-MILESTONE-7.md) is not affected: its
  witnesses' implementations need the context structs LinuxFS, WindowsFS and
  DarwinFS. A FilePath witness whose implementation printed through
  std::io::IO would be (`split-modules` is that shape).
* **The other functions the plan replaces cannot be implementations today**,
  so the defect is the context-trait case only: an implementation that is
  itself trait-polymorphic would need a requirement over another trait
  (rejected: "requirements over other traits (trait composition)"), and an
  imprinted implementation (`fn show(t: Wrap[T])`) does not satisfy the
  requirement (TRAIT-NOT-SATISFIED). A fix should still handle every
  replaced kind uniformly (section 8), so that lifting either restriction
  does not reopen it.

## 4. Root cause

Four steps, each verified on `entry-io` (a probe that stops at
`hir::traits::monomorphize` and prints build 1's facts: `show requires:
std::io::IO`, `twice requires:` nothing, `selected:` nothing).

**4.1 Build 1 cannot see a requirement that flows through a trait
operation.** `hir::contexts::required` (hir/contexts.tcl) derives a
function's context requirement from the calls in its body whose callee is
known. Inside `twice`, `t.show()` has no callee before monomorphization: the
witness, and with it the implementation, is a property of each
specialization, not of `twice` as written. So `twice`'s requirement is
empty, although every specialization of it needs whatever its witness's
implementation needs.

**4.2 So no context trait is selected for it.** `hir::contexts::verify`
selects, for each reachable top-level call, the one installed provider of
each context trait its callee requires (`Obligations`), and records the
program-wide `selected` map (hir/contexts.tcl, the loop over
`callsOfRoot`). `twice(A {v: 1})` requires nothing, so nothing is selected
for std::io::IO, although `with context std::linux::io::create()` installed
a provider. It is also why a missing installation is not MISSING-CONTEXT:
there is no requirement to find unmet (section 6.1).

**4.3 The plan drops the implementation and makes no clone of it.**
`hir::traits::PlanCalls` (hir/traits.tcl) records every function whose
requirement includes a context trait as polymorphic (`polys`, with its
`contextTraits` and its `selection`, `ContextSelection`: "-" when no
selection exists). `hir::traits::Plan` then drops every such declaration --
the `drop` loop: `if {[dict get $fn trait] || [dict get $fn contextTraits]
ne {} || [dict get $fn imprint]}` -- because its clones replace it. `show` is
dropped. A clone of it would be made only by a call the plan resolves to it,
and there is none: the one call is the trait operation of 4.4.

**4.4 The trait-operation action names the dropped declaration.**
`PlanCalls` resolves calls in two branches that should agree and do not:

* a **context-trait operation** (`out.emit(n)`): when the selected
  implementation is itself polymorphic -- `if {[dict exists $polys
  $implBlock]}`, commented "The implementation itself requires a context
  trait: it is replaced by its own clone" -- the action is `{context
  OPERATION KEY}`, KEY the implementation's clone, with an edge to it and
  the clone queued (`contextfn`);
* an **ordinary trait operation** (`t.show()`, the branch `elseif {[dict
  exists $node traitCall]}`): the action is always `{trait {... impl
  [ImplIdent $impl] ...}}` -- `{entry show}` or `{module NS show}`, the
  implementation's original declaration -- with no check whether that
  declaration is one the plan drops, no clone key, no edge and nothing
  queued.

Build 2 (`hir::traits::monomorphize`) resolves the action:
`hir::resolve::ResolveIdent` looks `{entry show}` up in the program's top
scope, where the dropped declaration is not (`core::malformed "trait plan:
entry-program binding ... is not established here"`); `{module NS show}`
goes through `ResolveQualifiedRef` (section 5).

The defect is the combination: 4.4 alone would be harmless if 4.3 kept the
declaration; 4.3 alone if 4.4 redirected. And a redirect alone is not enough
(section 7): with no selection (4.2), there is no clone to redirect to.

## 5. Why the layouts fail differently

The same dangling reference reaches three resolution paths in build 2:

* **entry program** (`entry-*`, `missing-context`): `ResolveIdent`'s
  `entry` case checks the top scope and calls `core::malformed` -- an
  internal error, CORE MALFORMED, raised at once.
* **the module that makes the call** (`module-impl`): `{module shapes show}`
  is resolved as a qualified reference within `shapes` itself; the name
  exists in the namespace but is not established before the use (the
  declaration was dropped), so the resolver records an UNBOUND diagnostic --
  `in the monomorphized program: unbound name "shapes::show": "show" is not
  established before this point in its own namespace` -- marked `internal`
  (twice, one per call). Section 6.2 is what happens next.
* **another module** (`split-modules`, `two-witnesses`): the namespace has
  no definition left at all: `unresolved module reference witness::show`,
  CORE MALFORMED.

## 6. Two further defects on the same path

**6.1 MISSING-CONTEXT is reported as an internal error.** `missing-context`
should be rejected as MISSING-CONTEXT, as `control-struct` is without its
installation ("in the monomorphized program: Log is required by this call
but is not installed here", CORE SEMANTIC MISSING-CONTEXT) and as
`control-direct` is ("std::io::IO is required by this call, but no installed
context implements it"). Because the requirement is invisible in build 1
(4.1), the check that would report it never finds it, and the plan's
dangling reference fails first. A fix of 4.4 alone would turn this into a
successful compilation of a program with no provider -- worse -- unless
4.1/4.2 are fixed too.

**6.2 A build whose only diagnostics are internal crashes the compiler.**
In `module-impl` build 2 has two diagnostics, both `internal 1`.
`hir::recovery::reported` (hir/recovery.tcl) never reports an internal
diagnostic, so it returns nothing, and `surface::lower::Finish`
(surface/lower.tcl) -- which raises whenever `hir::diagnostics` is non-empty
-- calls `hir::recovery::raise` with an empty list. `core::raiseDiagnostics`
(core/errors.tcl) reads `[dict get [lindex $diagnostics 0] message]` of an
empty list: a Tcl error, `key "message" not known in dictionary`, with no
error code, instead of a compiler-internal error naming the internal
diagnostics. This is independent of the trait plan: any path that leaves
only internal diagnostics reaches it. The fix belongs at the strict
boundary (never raise an empty report: raise the internal diagnostics as an
internal error), not in recovery's rule that internal diagnostics are not
reported.

## 7. Fixes that do not work

* **Redirect the trait action alone** (in the `traitCall` branch, mirror the
  context branch: when the implementation is in `polys`, emit a clone key):
  the implementation's selection is "-" (4.2), and a clone keyed by "no
  selection" is the plan's "never executed" case -- the program would
  compile against no provider, and `missing-context` would compile.
* **Keep the declaration** (exclude implementations from `drop`): the kept
  `show` still requires a context trait for which no top-level call made a
  selection (4.2), so there is still no provider to bind its operation to;
  and the clone-per-selection rule of CONTEXT-TRAITS.md ("every function
  whose requirement includes a context trait is cloned for the selection")
  would hold for every function but implementations.
* **Give `twice` the requirements of every implementation of `show`** in
  build 1 (a union over all witnesses that implement the requirement): it
  would require std::io::IO of programs whose witnesses never print --
  MISSING-CONTEXT for a program that needs no context -- and it is the
  "visible function of a trait operation's name" confusion that
  CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md removed for yields.
* **Select at run time, or pass a provider**: forbidden (AGENTS.md, "Context
  traits": no runtime provider lookup, no hidden context or dictionary
  argument).

## 8. What the fix must establish

The invariant, in the words of the yield milestone's:

> Once a trait operation's implementation is selected, its context
> requirement is the call's. A specialization requires exactly what the
> implementations its trait operations bind require, and nothing from an
> implementation it does not invoke.

Concretely:

1. **Requirements per specialization in build 1.** A top-level call of a
   trait-polymorphic function requires the context traits of the
   implementations its specialization binds (transitively, through the
   specializations it calls), so `hir::contexts::verify` selects their
   providers (`Obligations`) and reports MISSING-CONTEXT and
   AMBIGUOUS-CONTEXT-IMPLEMENTATION for them -- at the top-level call, in
   source terms (naming the operation, the implementation and the
   specialization), as the yield milestone does for UNWRAPPED-YIELD.
   TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md built the mechanism
   this needs: `hir::check`'s feedback loop (`hir::coroutines::Feedback`,
   `Implementations`) takes the trait-operation edges from the plan's own
   call resolution (`hir::traits::PlanCalls`), so build 1's call graph is
   build 2's. The context analysis needs the same edges, from the same
   source -- never a second resolver.
2. **The plan redirects every operation whose implementation it replaces.**
   In the `traitCall` branch, as in the context branch: when the
   implementation is a polymorphic function the plan drops, the action
   carries the implementation's clone key for the selection in force, adds
   the edge (placement, `TopoOrder`, TRAIT-POLYMORPHIC-RECURSION) and queues
   the clone. One rule for both branches, stated once.
3. **No action names a dropped declaration.** The plan checks it: an action
   whose identity is in `drop` is a TRAIT-INTERNAL diagnostic at the call,
   never a `core::malformed` in build 2. (Today the check would have caught
   the defect as a plan diagnostic.)
4. **The strict boundary never raises an empty report** (section 6.2).
5. **Nothing at run time** (AGENTS.md, "Traits" and "Context traits"): no
   provider lookup, slot, tag, dispatch or hidden argument; every operation
   a direct call of the selected implementation's clone; the
   monomorphized program has no trait or context-trait operation. Conformance
   still reads only the witness's owner namespace, and the context's
   satisfaction only the concrete context's (`satisfiesTrait`).
6. **Static decisions.** The plan's gate and diagnostics are a program-wide
   channel of the static decisions (hir/staticdeps.tcl's `C:plan`); a
   context requirement that now flows through trait operations is a new
   cross-function fact an analysis reads (AGENTS.md, "Static intrinsics"):
   its dependency edges go into hir/staticdeps.tcl, and the batched and
   sequential schedulers must agree.

## 9. Acceptance

* `audit/trait-impl-context-trait/tools/run.tcl` exits 0: every defect case
  runs (or is MISSING-CONTEXT) on every backend it can run on, every control
  unchanged. The cases become tests in tests/traits.test and
  tests/context-traits.test (all four backends through one HIR:
  `sourceAgree`/`moduleAgree`), plus: an AMBIGUOUS-CONTEXT-IMPLEMENTATION
  case (two installed providers of the implementation's context trait); a
  specialization chain (a trait-polymorphic function calling another, the
  inner one's operation needing the context trait); a witness whose
  implementation needs no context beside one that does (the first must not
  acquire the requirement: section 7, third item); a coroutine whose
  implementation both yields and needs a context trait (both feedback edges
  at once).
* tests/compiler-service.test or tests/diagnostic-recovery.test for 6.2: a
  program whose build leaves only internal diagnostics is a coded internal
  error, never a Tcl error.
* Mutants (audit/traits/tools/mutants.txt, audit/context-traits/tools/
  mutants.txt): the redirect dropped (the original defect), the selection
  computed from the function as written (4.1), the drop check of item 3
  removed, a union over all implementations (section 7) -- each killed.
* The harnesses AGENTS.md names for a change to `hir::traits::Plan`, to
  conformance and to context-trait selection: tests/traits.test,
  tests/context-traits.test, tests/portable-io.test,
  audit/traits/tools/fuzz.tcl and mutate.tcl, audit/context-traits/tools/
  fuzz.tcl and mutate.tcl, tests/static-economics.test
  (`se-property-plan-gate`, `se-equal-plan-gate`), the static-decision
  harnesses, and the static-decisions workflow (batched against sequential,
  in CI only); for the feedback loop, the yield milestone's own tests and
  audit/trait-implementation-yield/tools/fuzz.tcl.
* Documentation: CONTEXT-TRAITS.md (an implementation's context trait
  flows to the trait operation's call), TRAITS.md, the Compilerpedia topic
  of MISSING-CONTEXT if its message changes, and this file's status.

## 10. Evidence and history

* Found during WINDOWS-X86-64-MILESTONE-7.md's design (section 12.2), with
  the reproducer audit/filesystem/findings/trait-plan-entry-context-trait.bot
  (the `entry-io` case).
* Re-checked after merging main at 7aec2a11 into the milestone's branch
  (merge commit 06bb06ef), which includes
  TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md ("Attribute a selected
  trait implementation's yields to its call", "Ask the trait plan for
  effect edges only when one can be kept"): every case reproduces as in
  section 2. That milestone fixed the same shape of problem for yields --
  an implementation's effect flowing to the trait operation's call -- and
  did not touch context requirements.
* Evidence kinds: every result in section 2 is a real Linux x86-64 run
  (main.tcl on the backends named); section 4's build-1 facts come from a
  probe that wraps `hir::traits::monomorphize` and prints
  `hir::contexts::required` of `show` and `twice` and `contexts selected`;
  sections 4.3 to 6 are code inspection, line for line, of the procedures
  named.
