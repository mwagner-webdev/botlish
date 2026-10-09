# Compiler warnings: `SAME-FAILURE`

## Outcome

Botlish's fourth compiler warning, **`SAME-FAILURE`**, is one pass plus one
registry line on the warning framework of milestones 1-3 (`hir/warnings.tcl`;
WARNINGS-SAME-RETURN.md, WARNINGS-METHOD-ELIGIBLE.md,
WARNINGS-FIXED-ARITY-LIST-RETURN.md): several distinct, reachable exits of one
function `fail` the same declared failure.

```botlish
error Invalid
fn parse_record(text, pos) errors Invalid:
    if text == "":
        fail Invalid
    if pos == 3:
        fail Invalid
    pos + 1
```
```
f.bot:4:9: warning: failure `Invalid` is raised from 2 distinct exits (SAME-FAILURE)
f.bot:6:9: note: also raised here
```

(`tests/same-failure.test`, `sf-parse-record-rendered`; the brief's example
with the `error Invalid` declaration it needs, so its exits are on lines 4 and
6.)

The warning states the fact and stops. It does not say merge the guards, does
not say split `Invalid` into richer failures, and does not say the repetition
is wrong: each can be the right response, and so can keeping the uniform
failure as the API (the one corpus finding is exactly such a case). It completes
the symmetry milestone 1 deferred. There, "`fail` is not a return and is never
grouped with one"; here a return is not a failure and is never grouped with
one, by the same shape of theorem, so the rule is now bidirectional and pinned
both ways.

This is the smallest of the four warnings. It needs no provenance (milestone
2), no annotation (milestone 3), no value identity (milestone 1's
`hir::exact`) and no recording-walk extension: the pass reads the `fail` nodes
HIR already has, the error-name identity the resolver already enforces, and the
two reachability tiers milestones 1 and 3 already use. No frontend file, no
analysis file and nothing under `native/` changed.

Coordination: milestone 3 reversed the parallel-agent split for the warning
pins a new code breaks (its report, "Parallel work"), and `main` shows no
parallel-agent activity since, so this milestone owned and made the minimal
adaptations itself: 4 test pins and the milestone-3 fuzzer's oracle (see
"Kickoff: ownership and the item-2 inventory"). No corpus file was edited. The
corpus was audited at the pinned commit `d9a71f5`.

## The theorem

> A failure group is reported exactly when **two or more distinct, reachable
> exits** of one function **`fail` the same declared failure** -- the same
> failure as the compiler resolves it, not the same text.

One warning per failure group, never one per pair. A function failing `A` twice
and `B` three times produces two warnings; a single exit never warns. Each
clause is pinned:

| clause | pinned by (tests/same-failure.test) |
|---|---|
| two or more | `sf-two-exits`, `sf-three-exits`, `sf-single-fail-silent`, `sf-re-raise-alone-silent` |
| distinct exits (source operations) | `sf-synthesized-boolean-if-never-opened` (one guard on `a or b` is one exit), `sf-every-loop-form` (a fail in a loop body is one exit however often the loop runs) |
| reachable (not proven unreachable) | `sf-dead-branch-never-counts`, `sf-code-after-return-never-counts`, `sf-range-unreachable-pruned`, `sf-range-feasible-control`, `sf-range-pruning-removes-a-group`, `sf-pruning-leaves-the-count-right`, `sf-repeated-range-guard-pruned`, `sf-limit-repeated-equality-guard-counts`, `sf-unreachable-function-is-not-walked` |
| of one function | `sf-never-across-functions`, `sf-nested-function-owns-its-fails`, `sf-nested-function-warns-on-its-own`, `sf-closure-owns-its-fails`, `sf-nested-function-in-branch-and-loop` |
| `fail` (the exit kind) | `sf-returns-never-grouped-with-fails`, `sf-fails-never-grouped-with-returns`, `sf-final-expression-is-not-an-exit`, `sf-propagated-*`, `sf-body-ending-in-bare-failing-call-silent`, `sf-handled-call-is-not-an-exit` |
| the same declared failure, as resolved | `sf-different-declared-failures-never-group`, `sf-similar-names-never-group`, `sf-one-name-is-one-declaration-program-wide`, `sf-module-failure-is-the-same-failure`, `sf-builtin-error-groups`, `sf-unresolved-site-silent`, `sf-identity-is-the-name` |
| one warning per group | `sf-one-diagnostic-per-group-never-pairwise`, `sf-a-a-b-b-c`, `sf-two-groups-are-two-diagnostics` |

The pass is `hir::warnings::SameFailure` with the helpers `SameFailureIn`,
`FailSites`, `FailureGroups` and `FailureWarning`, appended to
`hir/warnings.tcl`. It reuses milestone 1's `BlockNames`, `BodyExprs` and
`HasRepeat` as they are.

## Exits are written `fail` operations: the mirror-image table

The exit set is exactly the reachable `fail` operations whose target is the
function. A `fail` node carries no `target` field: the resolver admits it
against the `errors` clause of the innermost enclosing block
(`hir/resolve.tcl`, the `fail` case reads the context's `errors`, which only a
`block` sets, together with `callable`). That block is the target, and
`BodyExprs` -- the pre-order walk of a block's own body that never enters a
nested block -- enumerates exactly the fails that target it.

| case | `SAME-RETURN-VALUE` (milestone 1) | `SAME-FAILURE` | why | pinned by |
|---|---|---|---|---|
| final-expression value / fall-through | an exit | **not an exit** | a normal completion is a return; a function never fails implicitly | `sf-final-expression-is-not-an-exit`, `sf-fails-and-falls-through` |
| unit exit | skipped (M1) / mismatch (M3) | **does not arise** | no value exits are enumerated | -- (no value is read) |
| the other kind's sites | `fail` not grouped | `return` not grouped | the rule is bidirectional | `sf-returns-never-grouped-with-fails`, `sf-fails-never-grouped-with-returns`, `sf-repeated-returns-and-fails-two-warnings`; `tests/warnings.test`'s `warn-failures-are-not-returns` for the other direction |
| propagated failure (a call that fails) | -- (an ordinary call) | **not an exit** | an ordinary call; the fact would be about the callee | `sf-propagated-failure-is-not-an-exit`, `sf-propagated-beside-one-fail-silent`, `sf-body-ending-in-bare-failing-call-silent`, `sf-handled-call-is-not-an-exit` |

No `FallThroughs` equivalent is needed. A function that both fails and falls
through is fine: the fall-through is not a fail completion and contributes
nothing, while its fails count (`sf-fails-and-falls-through`: two guarded
fails, the second the body's else-less final `if`, are one group of 2). A body
that ends in a bare failing call gets no warning (`sf-body-ending-in-bare-
failing-call-silent`), and neither does a function whose only repeated failure
comes from calls.

## Where fails live

Inherited from milestone 1's rules for returns, applied to the other completion
kind, and pinned:

* **Branches**: `if`/`else` (`sf-if-else-branches`), `elif`, which is a nested
  `if` before analysis (`sf-elif-is-a-nested-if`).
* **Every loop form**: list loop, counted loop, lockstep loop and the
  unconditional `loop:` (`sf-every-loop-form`, `sf-loop-and-top-level`).
* **On-handler bodies**: a `fail` inside `on A:` is an exit of the enclosing
  function (`sf-handler-body`), as is each of two handlers' fails
  (`sf-two-handlers-same-failure`).
* **Re-raise** (`on Invalid: fail Invalid`) is a source operation and counts
  (`sf-re-raise-counts`; alone it is one exit and silent, `sf-re-raise-alone-
  silent`). This is documented, not refined: the corpus audit judges whether
  re-raise noise warrants a refinement, and the corpus contains **no re-raise
  at all** at the pinned commit (the census, below), so there is no evidence
  either way and nothing was pre-refined.
* **Every syntactic position the language allows.** `fail NAME` is a statement
  (EXPLICIT-ERROR-COMPLETIONS.md: "never a value"), so its positions are a
  statement of a body, of a branch body, of a loop body or of a handler body,
  and the final statement (`sf-fail-as-final-statement`).
* **The synthesized boolean `if` is never opened.** It cannot contain a `fail`
  (its branches are the operator's operands, expressions), so what is pinned is
  that a guard on `a or b` or `not a and b` is one exit (`sf-synthesized-
  boolean-if-never-opened`).
* **Nested functions and closures own their fails.** Target confusion is this
  warning's main bug class, and it is guarded twice: `BodyExprs` never enters a
  nested block, and the completion walk never does either (`hir::completions::
  Eval`'s `block` case returns without visiting the body), so a nested
  function's fail could not survive pruning even if it were enumerated. That
  second guard is why the mutant that enumerates nested fails is visible only
  as a wasted walk (see "Mutation testing"). Pinned: the enclosing function and
  its nested function failing `E` once each are both silent, never one group of
  2 (`sf-nested-function-owns-its-fails`); a nested function's repeated fail is
  its own warning, and the enclosing group counts only its own fails
  (`sf-nested-function-warns-on-its-own`); a closure over the enclosing
  parameter (`sf-closure-owns-its-fails`); nested functions defined in a branch
  or a loop body (`sf-nested-function-in-branch-and-loop`); and a nested
  function's fail never makes its enclosing function a walk candidate
  (`sf-walk-only-for-candidates`).
* **Termination is trivial**: a syntax walk per function, no call graph, no
  fixpoint.

## Identity is nominal

Two `fail Invalid` sites are the same failure because the compiler resolves
both to the same declared failure of this function. In Botlish that
resolution is by name, and the name is a complete identity:

* **One name, one declaration, program-wide.** `hir/errordecls.tcl` keeps a
  flat, program-global error namespace ("NAME is the identity, valid and unique
  across one whole compiled program ... never compared by message text"): a
  second `error Invalid` in another module, at the top level, or the name of a
  builtin runtime error is rejected (`UNDECLARED-ERROR`, "error names are
  global"). So *textually identical fails of different declarations* -- the
  anti-text-matching case the brief asks to pin -- cannot occur in a program
  that compiles; that impossibility is what is pinned
  (`sf-one-name-is-one-declaration-program-wide`: two modules, a module and the
  program, a builtin name), and a module's declared failure failed by the
  program is that one identity (`sf-module-failure-is-the-same-failure`).
* **Admitted by the function.** The resolver admits a `fail` only when the
  function declares its name in its own `errors` clause, and normalizes that
  clause into the block's `declaredErrors` (validated names, `hir/resolve.tcl`).
  `FailSites` takes a site only when its name is in that set.
* **Similar names are different failures.** `A`, `A2`, `a` and `AError` never
  group; only a real repeat does, alone (`sf-similar-names-never-group`).
* **Builtin errors are declared failures like any other** (`IndexNotFound`,
  `sf-builtin-error-groups`).
* **The record's `failure` is the name**, and `failureName` is the same name
  (`sf-identity-is-the-name`). The repository represents a declared failure by
  its name everywhere (a block's `declaredErrors`, a call's `effectiveErrors`,
  `Fn{... errors: [...]}` types, `hir::format`), so there is no richer
  representation to carry; the two fields are kept for record-shape parity
  with milestone 1's `function`/`functionName`.

No `hir::exact`, no alias resolution, no `hir::resolve::CandidateIdentity`, no
source text: the resolver decides, and the pass only compares the names it
validated. Because the identity survives `hir::format`/`hir::parse`, HIR read
back from text reports the same group (`sf-hir-text-input-warns`), unlike
milestone 2's provenance-based facts.

### The payload question: `fail` carries no payload

Determined from the language, not assumed: the grammar is `fail = "fail"
IDENT` (`surface/parser.tcl`), `fail E(x)` and `fail E x` are syntax errors,
the HIR `fail` node has a `name` and no value child (`hir::children` of a fail
is empty), and at run time `fail NAME` produces a propagating-error completion
carrying only `{errorId NAME}` (EXPLICIT-ERROR-COMPLETIONS.md, "Semantic
model"). So identity is the name, and the conservative payload rule
(`hir::exact::Identity` on payloads) has nothing to apply to. Pinned by
`sf-fail-carries-no-payload` and `sf-identity-is-the-name`. If Botlish ever
gives `fail` a payload, this pass must adopt that rule (group only when
`hir::exact::Identity` proves the payloads equal, silence otherwise) before the
payload can reach it.

## Declared failures only

A `fail` of an undeclared failure is an error diagnostic (`UNDECLARED-ERROR`),
and a `fail` the function does not admit is one too (`UNHANDLED-ERROR`), so an
eligible program's every `fail` is declared in its function's `errors` clause.
Inherited rule: a program with error diagnostics is never warned about. Pinned
under `-strict 0`, which keeps the diagnostics instead of raising them:
`sf-strict0-unadmitted-fail-never-warned` and `sf-strict0-undeclared-error-
never-warned`.

**Can the resolver fail to bind a `fail` in an otherwise-clean program?** Not
through the surface frontend: every `fail` is checked there. HIR text input is
the one place: `hir::parse` checks only that a `fail`'s name is a declared
error, not that its function admits it, so hand-written HIR text can carry a
`fail E` in a function without `errors E` and no diagnostic. That site is not
bound to any declared failure *of its function* and is silent:
`sf-unresolved-site-silent` removes the `errors E` clause from a function's HIR
text, and the parsed HIR, diagnostic-free, has no warning (the
`unresolved-name-accepted` mutant shows the check is load-bearing).

## Reachability: the soundness argument, restated

Two tiers, as in milestones 1 and 3:

1. **Structural**: HIR's `reachable` flag on each `fail` node (statically
   decided branches such as `if 1 == 2`, code after a completion) and on the
   function's block (a function defined where it cannot run is skipped).
2. **The completion proof's recording walk**
   (`hir::completions::reachedExprs`: parameters unconstrained, branches its
   range facts prove infeasible never entered, nothing after an expression
   that cannot complete), only for a **candidate**. A site absent from the walk
   is pruned.

**The candidate gate is milestone 1's, not milestone 3's.** A candidate is a
function in which some declared failure has at least two *structurally*
reachable sites (`HasRepeat` over the structural groups). Milestone 3 had to
gate on the weakest condition under which pruning could *create* its warning;
here pruning only removes sites from groups, and a group needs two, so a
function without a structural repeat can never warn and is never walked. Pinned
by trace (`sf-walk-only-for-candidates`): of seven functions -- no fail, one
fail, two distinct failures, a pair whose second site is statically dead, a
pair, a pair whose second site is range-unreachable, and one own fail beside a
nested function's fail of the same name -- exactly the two structural pairs are
walked, once each.

**Recording mode.** The recording walk already records `fail` sites: `Eval`
marks every expression it visits, a `fail` included, before dispatching on its
kind, and it walks loop bodies and every on-handler body. **No extension was
needed** (the brief's recording-only contingency was not exercised), so the
completion proof is byte-for-byte unchanged (`hir/completions.tcl` is not in
the diff). `sf-walk-records-fail-sites` pins the walk as it is: a reached site
present, a range-unreachable one absent.

**Soundness, restated -- and why the brief's restatement does not carry over
unchanged.** The walk removes a site only when it is proven unable to execute.
Two consequences, in the compiler's sense of "reachable" (not proven
unreachable by HIR's structure or the completion proof's facts), which is the
theorem's sense, as it is milestone 1's:

* **No executable site is ever missing.** Every `fail` that can execute is
  structurally reachable (HIR marks a node unreachable only when it is decided)
  and survives the walk. So every reported group contains every executable site
  of its failure, the claim "this failure is raised from these N reachable
  exits" is true, and a failure that really is raised from two executable exits
  is never missed.
* **The direction is milestone 1's, not milestone 3's.** Here pruning only
  removes sites from groups, so a more precise walk can only lower a count or
  dissolve a group -- it can never add a warning. Imprecision (a site the walk
  fails to prove dead) *keeps* the site, so its error direction is an
  over-count, never a miss: a group's count can exceed the number of exits that
  actually execute, and a group can be reported whose second site never runs.
  The brief's restatement ("imprecision ... can only cause a missed warning";
  "precision can add a warning, and only a true one") is milestone 3's argument
  for a *uniformity* theorem, where a pruned mismatch can create a warning; for
  a *grouping* theorem the two directions are reversed. What remains true is
  the brief's core: a group needs two sites the compiler cannot prove dead, and
  every reported site is one.

The over-count is real and pinned, as a limitation, rather than argued away: a
repeated `if x == 7: fail E` is dead after the first at run time, but range
facts are intervals and cannot exclude one point, so both sites count
(`sf-limit-repeated-equality-guard-counts`); a repeated `if x < 0: fail E`, by
contrast, is proven dead and pruned (`sf-repeated-range-guard-pruned`). The
programmer's natural response to such a finding (deleting the redundant guard)
is the merge response, so it is not a false positive under item 19's bar; and
milestone 1's `SAME-RETURN-VALUE` has the same exposure for repeated returns.

Pinned: a range-unreachable `fail Invalid` beside two reachable ones leaves the
count at 2 (`sf-range-unreachable-pruned`); the feasible control keeps 3
(`sf-range-feasible-control`); a dead branch's fail never counts
(`sf-dead-branch-never-counts`); a structural pair whose second site is
range-unreachable is no group at all (`sf-range-pruning-removes-a-group`); and
the count, the sites and the notes are exactly the reachable ones
(`sf-pruning-leaves-the-count-right`).

## Record, message, ordering

**Record.** The framework's `{code message primary secondary data}`:

* `primary`: the group's first `fail` in source order (pre-order of the body,
  which is source order), in `hir::originLocation`'s vocabulary. Module code is
  located in the module file, inside loops included (milestone 1's `RemapFile`
  fix; `sf-reach-module-code-located-in-module`).
* `secondary`: the group's other fails, source order, one `note: also raised
  here` line each (`sf-notes-one-per-secondary`).
* `data`: `function` (block ExprId), `functionName`, `failure` (the declared
  name, the repository's representation of a declared failure), `failureName`,
  `exits` (count), `sites` (the `fail` ExprIds, source order) and `note` (the
  note text `render` reads, as in milestones 1 and 3). No rendered source text
  (`sf-record-data-fields`, `sf-no-rendered-source-in-data`).

**Message.** One template, mirroring milestone 1's:

```
failure `NAME` is raised from N distinct exits
```

It names the failure and states the fact with its count; the notes mirror the
verb ("also raised here", as milestone 1's "also returned here"). "Raised" is
the repository's existing word for an error leaving a function
(EXPLICIT-ERROR-COMPLETIONS.md, and the framework's own "raised as a compilation
error"); "failed" would read as the function failing, not the failure being
produced. Nothing prescriptive (`sf-message-text`, and `sf-message-is-not-
prescriptive` scans the rendered text for `merge`, `combine`, `split`,
`richer`, `should`, `consider`, `use`, `instead`, `rewrite`, `or `, ` and `,
`->` and `fail `).

**No idiom document.** Milestone 3 wrote MULTI-VALUE-RESULTS.md because its
warning points at a preferred form the language had decided on (structs name
the parts). This warning prefers nothing: both natural responses (merging the
conditions, splitting the failure) and keeping the code are open, and no idiom
is being created or declared. It is fact-only, in the milestone-1 mold.

**Ordering.** The inherited `Sort`: primary origin, then code, then message.
All four codes interleave by location, in both orders
(`sf-interleaving-four-codes`, `sf-interleaving-four-codes-other-order`), and a
function with repeated returns and repeated fails gets a `SAME-RETURN-VALUE`
and a `SAME-FAILURE` diagnostic, independently
(`sf-repeated-returns-and-fails-two-warnings`). Determinism:
`sf-deterministic`, `sf-interleaving-deterministic`.

**One warning per group, generic HIR once.** The pass reads the final generic
source HIR once per source function. Semantic instances live in the `semantic`
side table and are never walked: a function analyzed as three instances gives
one warning (`sf-generic-hir-once-instances-never-walked`; the
`instances-visited` mutant).

## Architecture

**One pass, one registry line.**

```tcl
variable passes {
    SAME-RETURN-VALUE hir::warnings::SameReturnValue
    METHOD-ELIGIBLE   hir::warnings::MethodEligible
    FIXED-ARITY-LIST-RETURN hir::warnings::FixedArityListReturn
    SAME-FAILURE      hir::warnings::SameFailure
}
```

`git diff hir/warnings.tcl` is two hunks: the inserted registry line, and the
section appended after `FIXED-ARITY-LIST-RETURN` (header comment plus five
procedures). **Framework untouched**: policy modes, `run`/`collect`/`of`, the
record shape, `Sort`, `render`, `Raise`, the stats counter, `BOTLISH_WARNINGS`
and the CLI option are byte-for-byte milestones 1-3. No frontend file, no
analysis file and nothing under `native/` changed.

**Timing and scope.** Discovery happens in `surface::lower::Finish`, after
`hir::buildSyntax`/`hir::check` and strict diagnostics, before any backend,
unchanged. A program with error diagnostics is never warned about.

**What supplied the proof, and what was not needed.** HIR's `fail` nodes (their
`name` and `reachable` flag) enumerated by milestone 1's `BodyExprs`; the
resolver's failure identity (the block's validated `declaredErrors`, over the
program-unique error names of `hir/errordecls.tcl`); structural reachability;
the completion walk; the framework. **Not needed**: `hir::exact` (no values are
compared), `hir::exact::AliasRoot` and `hir::resolve::CandidateIdentity` (no
bindings or callees are followed), milestone 2's written-form provenance and
milestone 3's annotation (no spelling or declaration is read), milestone 1's
`Exits`/`Leaves`/`SynthesizedBranch` and milestone 3's `FallThroughs` (no value
exits exist here), a call graph, and any change to the recording walk.

## No new HIR state, no semantics change

Nothing is recorded on HIR for this warning: no provenance, no annotation, no
field, no side table besides the framework's own `warnings`. Asserted
explicitly (`sf-no-new-hir-state`): under `default` the HIR's top-level keys
are `off`'s plus `warnings` and nothing else, every expression node has exactly
the fields it has under `off`, and the binding and scope tables are identical.
Beyond that, `dict remove $hir warnings`, `hir::format`, `hir::lower` and
`native::nir` (specialized and generic) are identical under `off` and `default`
(`sf-hir-identical-across-modes`, `sf-nir-identical-across-modes`), and
`native::report`, NIR and CLIF are identical with and without the side table
and contain no warning text (`sf-machine-readable-outputs-clean`, `sf-no-
warning-text-in-machine-readable-outputs`). Specialization, inference, proof
facts, optimization and the runtime are untouched.

## Policy, inherited and re-pinned

`default` warns; `off` runs no pass (`hir::warnings::stats` gains no
`SAME-FAILURE` entry, and an execution trace shows 0 calls under `off` and 1
under `default`: `sf-off-runs-no-warning-pass`, `sf-off-runs-no-warning-pass-
via-trace`); `error` raises the sort-first warning across all four codes, as
`{CORE SEMANTIC SAME-FAILURE}` when it is this warning's
(`sf-mode-error-only-this-code` with the exact message,
`sf-mode-error-first-in-sort-order`, `sf-error-promotion-identity`), before
`hir::lower`, `native::prepareHir`, `native::evalHir` or
`core::compiler::evalHir` run (traces: 0 calls, `sf-error-stops-before-
backend`), and `main.tcl -backend cranelift -warnings error` prints no value
(`sf-error-cli-stops-before-backend`). No new CLI surface:
`-Wno-same-failure` is an unknown option in process and through `main.tcl`
(`sf-no-fine-grained-options`, `sf-cli-no-wno-option`); unknown modes are
rejected (`sf-unknown-mode`, `sf-cli-unknown-mode`); the registry is four static
lines and there is no enable/disable (`sf-no-new-modes-or-options`);
`BOTLISH_WARNINGS` is unchanged, read fresh per compilation, and the explicit
option wins (`sf-environment-default`, `sf-mode-default-is-the-default`);
interleaved compilations under different modes do not interact
(`sf-policy-is-per-compilation`); `of` equals `collect`
(`sf-warnings-attached-structurally`). Codes are identities, not switches.

## Backend independence and clean outputs

The warnings are computed from generic HIR before any backend, so the set is the
same on `interp`, `compile`, `cranelift` and `cranelift-generic`. In process,
the program runs identically on all four with warnings on and off, carrying its
one warning (`sf-backend-independent`, `sf-backend-independent-off`). Through
`main.tcl`, the warning text, notes included, is identical on all four backends
for a four-code program (`sf-cli-backend-independent`: 4 warnings and 2 notes,
one of each `SAME-FAILURE`) and for every program of `examples/stdlib`, all
codes (`sf-cli-backend-independent-stdlib`; stdlib itself has no `SAME-FAILURE`
finding, see the corpus audit, so the dedicated program is what shows this
warning's text). Warnings go to stderr only (`sf-cli-stdout-clean`).

**CI's plain corpus steps.** The brief expected them to gain `SAME-FAILURE`
lines. They do not: no program those steps compile loads `abi::bytes`, the
corpus's only finding. Reproduced locally: the native job's example step
(`main.tcl -backend cranelift` over `examples/stdlib`, `examples/surface/0[1-8]`,
`1[1-3]` and `examples/hir/0[1-3]`) exits 0 with exactly milestone 3's 314
stderr lines (8 `FIXED-ARITY-LIST-RETURN`, 301 `METHOD-ELIGIBLE`, 2
`SAME-RETURN-VALUE`, and their notes) and 0 `SAME-FAILURE` lines; the Tcl jobs'
`main.tcl -backend B` (its built-in examples), run on `interp`, exits 0 with an
empty stderr. The
`examples/linux` programs, which do load `abi::bytes`, print the finding, but no
CI step runs them through `main.tcl`; the tests that compile them run under the
harness's `off` default.

## Kickoff: ownership and the item-2 inventory

**Ownership.** Milestone 3's arrangement had a parallel agent own existing test
files. Its own report records that the split was reversed for the pins a new
warning code breaks ("they exist only on a tree that already has the pass ...
Leaving them made `main` red"), and milestone 3 adapted its 8 pins itself
(`0e159ee`). The parallel agent's last commits that milestone 3 names (`ffbebdb`,
the bench scripts passing `-warnings off`, and `faae181`, a test-file cleanup)
precede that; everything on `main` since is milestone 3's own closing work and
an unrelated concurrency fix (`1e5be51`), and nothing touches the warning tests.
So the arrangement was treated as ended, and this milestone owned the minimal
adaptations below.

**Baseline at kickoff (before the pass)**, `interp`: `tests/warnings.test`
81/81, `tests/method-eligible.test` 145/145, `tests/fixed-arity-list-return.test`
149/149, `tests/flags.test` 155/155; the three fuzzers' 60-seed smoke runs:
`same-return-value` 42/18 with/without warnings, 0 failures; `method-eligible`
43/17, 0 failures, 280/280 round trips; `fixed-arity-list-return` 42/18, 0
failures, 42/42 conversions.

**With the pass, before adaptation:**

| file | test | why it fails | the finding is | adaptation (owned here) |
|---|---|---|---|---|
| `tests/warnings.test` | `warn-off-runs-no-warning-pass` | the stats pin enumerates the codes; a fourth exists | -- | `SAME-FAILURE 1` / `2` added to the expected stats |
| `tests/warnings.test` | `warn-failures-are-not-returns` | **not in the brief's list**: it asserts no warning of *any* code over `f`, which fails `Bad` from two reachable exits | true (2 exits) | `codes` -> `sameReturnCodes`, the file's existing code filter (its comment now names this warning too); the pin -- `SAME-RETURN-VALUE` never groups `fail` with `return` -- is unchanged, and its mirror is pinned in the new file |
| `tests/method-eligible.test` | `me-off-runs-no-warning-pass` | the same stats pin | -- | the fourth code added |
| `tests/fixed-arity-list-return.test` | `fa-no-new-modes-or-options` | the registry pin lists the three codes | -- | the fourth code added |
| `tests/fixed-arity-list-return.test` | `fa-fuzz-smoke` | the generator's `fail Bad` guards repeat in some functions: 6 of 60 seeds (6, 13, 17, 23, 38, 59) fail with "unexpected code SAME-FAILURE" | true (construction-known) | the fuzzer's oracle predicts `SAME-FAILURE` (below) |

The brief's other expectations, checked: the fa file's stats and trace off-pins
(`fa-off-runs-no-warning-pass`, `-via-trace`) test `dict exists` and a trace on
their own pass, not the code list, and pass unchanged; no `fa-*` error-mode pin
names a promoted code over a program with a repeated `fail`, and all pass; the
milestone-1 and milestone-2 fuzzers' smoke runs are unaffected (their
generators emit no `fail`, and the libraries they import, `mutable_array` and
`str`, have no finding), and `tests/flags.test` (its `-warnings error` program
has no `fail`) passes 155/155.

**The fa fuzzer: the third option, the oracle predicts `SAME-FAILURE`.** Its
fails are construction-known (`if x == 7:` / `fail Bad` guards and a final
`fail Bad`, never in a dead, range-unreachable or nested position), so the
oracle now records each `fail Bad` site and predicts a group of every function
with two or more, anchored at the first. In `default` mode the `SAME-FAILURE`
warnings must equal the prediction exactly (missed or mislocated is a failure,
unpredicted is counted as an extra), the code is allowed beside the two it
already allowed, and in `error` mode a predicted warning of either code must
reject (the expected code was already the actual sort-first code). The
generator is unchanged, so every seed produces the same program as before. This
was chosen over restricting the generator (which would change milestone 3's
programs) and over filtering by predicted codes (which would leave a code
unverified). Its own warning is still verified under all three modes. Result:
**2000 seeds, the summary line identical to milestone 3's recorded result**
(`1341 with warnings, 659 without; failures 0; extra warnings 0; conversions
1341 of 1341; excluded runs 0`), with 130 predicted `SAME-FAILURE` groups in
128 of the 2000 programs, all matched. The summary line format was kept, so
`fa-fuzz-smoke`'s expected pattern is unchanged.

**After adaptation**, every one of the four files passes on all four backends
(see "Full regression").

## Tests

`tests/same-failure.test`, **99 tests**, every compile passing its policy
explicitly (99/99 on `interp`, `compile`, `cranelift` and `cranelift-generic`):

* **Groups**: the motivating guard pair (rendered exactly), 2 and 3 exits, one
  diagnostic for four sites, `A A B B C`, two groups in one function, a single
  fail, different declared failures, similar names, one name is one declaration
  program-wide, a module's failure, a builtin error, never across functions.
* **Kind separation**: returns never grouped with fails and the reverse, both
  codes on one function, the final expression and the fall-through, fails beside
  a fall-through, propagated calls (also beside one fail), a body ending in bare
  failing calls, a handled call.
* **Placement**: if/else, elif, final `fail`, every loop form, a loop beside a
  top-level fail, an on-handler body, a re-raise (and a lone re-raise), two
  handlers, nested functions and closures (four tests), the synthesized
  boolean `if`.
* **Reachability**: dead branch, code after a return, range-unreachable pruned,
  the feasible control, pruning removes a group, walk only for candidates
  (trace, seven functions), the walk records fail sites, pruning leaves the
  count right, a repeated range guard pruned, a repeated equality guard counted
  (the pinned limitation), an unreachable nested function, module location.
* **Declared only and payload**: `-strict 0` unadmitted and undeclared fails,
  HIR-text input warns, an unresolved site is silent, no payload, identity is
  the name.
* **Structure**: record shape, data fields, no rendered source, message text,
  not prescriptive, notes one per secondary, anchor first in source order,
  source order across functions, determinism, instances never walked.
* **Policy matrix**: four-code interleaving (both orders, determinism),
  default/off/error, the clean program, default-is-default, `BOTLISH_WARNINGS`,
  unknown mode, no `-Wno-same-failure`, the static four-line registry,
  promoted identity, stats and trace off-pins, error diagnostics never warned,
  per-compilation interleaving, `of` equals `collect`, `error` before all four
  lowering entry points.
* **No semantics change**: HIR/format/lower, no new HIR state, NIR (specialized
  and generic), report/NIR/CLIF with and without the side table, no warning
  text in machine-readable output.
* **Backends and CLI**: four backends in process (on and off); CLI modes,
  `-Wno-same-failure`, unknown mode, stdout/stderr separation, `-backend
  cranelift -warnings error` prints no value, identical warning text on all
  four backends (a dedicated four-code program, and all of `examples/stdlib`).
* **Fuzz smoke**: 60 seeds.

## Fuzzing

`audit/same-failure/tools/fuzz.tcl SEEDS FIRST`
(`audit/same-failure/fuzz-result.txt`; `-show SEED` prints one generated
program and its prediction). Each seed generates one to three functions
`gF(x, a, xs)`, each declaring one or two of three deliberately similar
failures (`Bad`, `Bad2`, `Other`), from construction-known pieces:

* **exits**: `if x == K:` / `fail N` guards; elif pairs failing the same or
  another name; fails inside `loop y in xs` and `loop i from 0 to x`; fails in
  on-handler bodies of a call of a single-fail helper `raise_M`, a re-raise when
  the handler handles the name it raises; a final `fail N`;
* **not exits**: returns (a unique constant or `x + C`, so no return value can
  repeat and `SAME-RETURN-VALUE` cannot fire); dead fails (`if 1 == 2`);
  range-unreachable fails (`if x < 0:` / `if x > 5:`); propagating calls
  (`rJ = raise_N(x)`, a final bare `raise_N(x)`, a call of the nested
  function); the final value `x + C`;
* **nested functions** (sometimes closures over `x`) failing one of the
  enclosing function's names from one to three of their own exits, predicted on
  their own;
* each failure raised from 1 to 4 reachable exits of a function; quiet programs
  (a third, by construction) raise each failure at most once per function.

Every call is written so that no other code can fire (method syntax for the
generated functions, one-parameter helpers, no list-literal exits), so the
oracle stays single-code and any other code is a failure. A driver calls each
function for six values of `x` with arguments of two types, handling its
declared failures, so every function has several semantic instances.

The oracle's notion of reachable is the compiler's, stated independently: a
site is an exit unless it was built under `if 1 == 2` or under the
contradictory `if x < 0:` / `if x > 5:` pair. Two guards with the same `K`
are both exits (the second is dead at run time but not provably so: the
pinned over-count of "Reachability").

The oracle is independent of the compiler: per function, it groups the
reachable fail sites it constructed by declared name and predicts each group
with two or more as `{LINE COL NOTES FAILURE FUNCTION EXITS}`. Modes:

* `default`: the `SAME-FAILURE` warnings are exactly the prediction -- anchor,
  notes, failure, function name and count; a missed or mislocated one fails, an
  extra one is printed as `EXTRA` and counted (pinned 0), a group reported
  twice fails, and any other code fails;
* `off`: compiles silently, no pass ran (stats counter and an execution trace
  on the pass), and the HIR equals default's without the side table;
* `error`: rejected with `{CORE SEMANTIC SAME-FAILURE}` iff a warning is
  predicted, compiled otherwise.

**2000 seeds (four chunks of 500): 1148 programs with warnings, 852 without;
0 failures, 0 extra warnings; 2298 predicted groups, all matched.** The
generated corpus: 4003 functions; 7541 reachable fail sites (2702 guards, 898
elif pairs, 891 list-loop and 907 counted-loop fails, 306 handler fails and 600
re-raises, 513 final fails); 1401 dead and 1383 range-unreachable fails; 1879
propagating calls and 761 bare final calls; 2754 returns; 1108 nested
functions; 852 only-silent programs (43%: the third that is quiet by
construction plus programs whose functions happen to repeat no failure). The
suite runs 60 (`sf-fuzz-smoke`). The fuzzer passed on its first full run; its
discriminating power is what the mutation step below measures.

## Mutation testing

`audit/same-failure/tools/mutate.tcl ?SEEDS? ?PATTERN?`
(`audit/same-failure/mutation-result.txt`), milestone-3 style: each mutant is a
small, local break of the pass, applied to a scratch copy of the tree; the
fuzzer runs first (40 seeds), and `tests/same-failure.test` runs for any mutant
the fuzzer does not kill.

| mutant | required | killed by |
|---|---|---|
| grouping disabled (`grouping-disabled`: one warning per site of a group) | yes | fuzz: 141 extra warnings, 23 failures |
| single-fail threshold dropped (`single-fail-threshold-dropped`: `>= 2` -> `>= 1`) | yes | fuzz: 16 extras, 7 failures (a candidate's single-site names warn) |
| dead fails counted (`dead-fails-counted`: the structural `reachable` flag ignored) | yes | unit tests: `sf-walk-only-for-candidates` (the dead pair is walked); output-equivalent, see below |
| walk pruning removed (`walk-pruning-removed`) | yes | fuzz: 17 extras, 13 failures |
| handler-body fails ignored (`handler-body-fails-ignored`) | yes | fuzz: 3 extras, 9 failures |
| nested function's fails grouped with the enclosing (`nested-function-fails-grouped`: the site walk enters nested blocks) | yes | unit tests: `sf-walk-only-for-candidates` (the enclosing function is walked); output-equivalent, see below |
| different declared failures grouped (`different-failures-grouped`: one group per function) | yes | fuzz: 11 extras, 9 failures |
| returns grouped with fails (`returns-grouped-with-fails`) | yes | fuzz: 36 extras, 24 failures |
| candidate gate broken (`candidate-gate-broken`: every function walked) | yes | unit tests: `sf-walk-only-for-candidates` (trace) |
| instances visited (`instances-visited`: one warning per semantic instance) | yes | fuzz: 23 failures (groups reported more than once) |
| re-raise ignored (`re-raise-ignored`) | yes | fuzz: 3 extras, 5 failures |
| similar names grouped (`similar-names-grouped`: grouping by a name prefix, `Bad`/`Bad2`) | extra | fuzz: 38 extras, 21 failures |
| unresolved name accepted (`unresolved-name-accepted`: the `declaredErrors` check dropped) | extra | unit tests: `sf-unresolved-site-silent` |
| unreachable functions walked (`unreachable-functions-walked`: the block's `reachable` flag ignored) | extra | unit tests: `sf-unreachable-function-is-not-walked` |

**14 of 14 mutants killed: the 11 required, 9 of all 14 by the fuzzer and 5 by
the unit tests.** Three of the five the fuzzer cannot see are **equivalent in
output by design**, and that is a finding, not a gap: the two reachability
tiers and the two "own body" guards overlap.

* `dead-fails-counted`: a structurally dead `fail` (under `if 1 == 2`, after a
  `return`) is never visited by the completion walk either, so tier 2 prunes
  what tier 1 no longer filters, and every warning is unchanged. What changes is
  the candidate gate: the dead site now forms a structural pair and the
  function is walked for nothing. The trace pin sees that.
* `nested-function-fails-grouped`: the walk never enters a nested function
  (`Eval`'s `block` case), so a nested `fail` enumerated by the mutated site
  walk is always pruned. Again only the gate changes. The first mutation run,
  before `sf-walk-only-for-candidates` gained its seventh function (one own
  fail beside a nested function's fail of the same name), let this mutant
  **survive** both harnesses; the trace case was added for it, and the second
  run (the one recorded) kills it. This is the "target confusion" mutant, so it
  is worth saying plainly: target confusion cannot reach a warning, because
  two independent pieces of code would both have to be wrong.
* `candidate-gate-broken` is visible only by trace by definition: walking every
  function changes no warning.

The other two unit-test kills are cases the generator deliberately does not
produce: hand-written HIR text with an unadmitted `fail`, and a nested function
defined in a statically dead branch (whose own fails would otherwise count).

## Why there is no conversion law

Milestones 2 and 3 verified *actionability* mechanically, because a mechanical
rewrite existed: the sugared respelling of a call must parse, resolve to the
same callee and compile to the same program (milestone 2's round-trip law), and
the struct conversion of a list-returning function must compile, lose the
warning and keep every value (milestone 3's conversion law). Here the
responses -- merging the conditions into one guard, or splitting the failure
into richer, distinct ones -- are semantic edits with no mechanical form: a
merge needs a condition the programmer chooses (and may lose a branch-specific
fact the separate guards established), and a split changes the function's
contract and every handler of it. The compiler must not suggest or perform
either. So this warning has no law to verify.

Its false-positive defense is instead:

* **nominal identity**, which is nearly impossible to misresolve: the resolver
  decides (program-unique names, admitted by the function's own `errors`
  clause), and the pass compares nothing else;
* **the construction-known oracle** of the fuzzer, over 2000 seeds, with the
  similar-name failures, dead and range-unreachable sites, handler bodies,
  re-raises, propagation and nested functions it generates;
* **mutation testing** of every grouping dimension (above: 14 of 14 killed);
* **the audited corpus** (below: one finding, hand-classified, zero false
  positives).

This is a deliberate downgrade in verification machinery matched to a
deliberate simplicity in the theorem: the more a warning's claim depends on
analysis (milestone 1's value identity, milestone 3's shape and annotation),
the more machinery it needs to be trusted; a claim that is a comparison of
resolver-validated names over a syntax walk needs only that the walk, the
reachability tiers and the grouping are right, and those are exactly what the
oracle and the mutants exercise. The corpus merge check (below) is the closest
thing to actionability evidence this warning has: for its one finding, merging
the guards compiles, removes the finding and keeps every probed value.

## Corpus findings

`audit/same-failure/tools/corpus.tcl`, output
`audit/same-failure/corpus-audit.txt`, at the **pinned commit `d9a71f5`**
(`origin/main` at kickoff and this milestone's base; the corpus paths are
clean). The tree has moved twice under this workstream (milestone 3 pinned
`faae181` and then re-checked `ffbd610`); `d9a71f5` is simply what is current,
and the audit says so in its header. It compiles `examples/stdlib` (9),
`examples/surface` (14), `bench/*.bot` (8) and `lib/*.bot` (8) with warnings
on. 35 of 39 compile standalone: the two deliberate rejections (`09`, `10`),
and `lib/list.bot` and `lib/mutable_array.bot` (which use their own namespace
without importing it, as milestones 2 and 3 recorded).

**1 distinct finding**, hand-classified:

| # | where | function | failure | exits | hand classification |
|---|---|---|---|---|---|
| 1 | `lib/abi/bytes.bot:141:9` (note `:143:9`) | `abi::bytes::replace` | `IndexNotFound` | 2 | **un-split repeated guard (combine-conditions candidate)**: the two halves of one bounds check, `if index < 0: fail IndexNotFound` / `elif index >= mutable_byte_store::count(data.storage): fail IndexNotFound`. The failure itself is uniform by design -- the function's header says "the same error list::at and mutable_array::set use" -- so a richer split is *not* a candidate; the natural responses are merging the guards into one `or` condition, or keeping the two-line form |

It is a library module's finding: `lib/abi/bytes.bot` is not in the `lib/*.bot`
glob, but `lib/linux.bot` (which is) imports it, so it is first seen compiling
`lib/linux.bot`, and every program that loads `abi::bytes` prints it
(`examples/linux/write.bot`, `read-stdin.bot`, `context-hello.bot`). No
`examples/stdlib`, `examples/surface` or `bench` program has a finding.

Totals by item 19's categories: un-split repeated guard **1**; uniform failure
by design kept as is **0** (the finding's *failure* is uniform by design, but
its *exits* are a mergeable guard pair); richer-split candidate **0**; **false
positives 0**. The author would merge or keep the finding as is; it is not a
finding they would do neither for, so it raises no warning-design issue.

**The merge check (scratch copy, the corpus not edited).** The tool copies
`lib/` to a temporary directory, merges the guard pair into `if index < 0 or
index >= mutable_byte_store::count(data.storage): fail IndexNotFound`, and
compiles a probe program against both copies that calls `replace` below range,
at both ends of the range, at and beyond the length, on the empty value, and
with an unchanged byte. The merged copy compiles, loses the finding, and the
probe's value is identical: `[[], [3, false], [3, false], [], [], [], [3,
true]]`.

**The expectation held: the corpus produces almost nothing**, for the reason
the brief gave. The fail census of the corpus (every function the corpus
compiles that has a structurally reachable `fail`): **15 functions, 28
reachable fail sites, 0 re-raises; 2 functions with a single fail site; 12 near
misses** -- functions with two fail sites that are two *distinct* failures, all
the deliberate range-guard pattern: `abi::i8` ... `abi::usize` (10 checked
creators, `AbiIntegerBelowRange`/`AbiIntegerAboveRange`),
`abi::x86_64::register64` (`Register64BelowRange`/`Register64AboveRange`) and
`byte::from_int` (`BelowRange`/`AboveRange`). Those are deliberately not
findings: different declared failures never group. The one finding is the one
range check in the corpus that fails a *uniform* failure from both sides.

**Re-raise noise.** The corpus has no re-raise (`on E: fail E`) at all, so
there is no evidence that re-raises produce noise, and no refinement is
warranted or was made.

## Full regression

All runs are on the committed pass (`f3f3e4f`: the pass, the tests, the tools
and the adaptations, on top of the pinned `d9a71f5`), with the native backend
built from that tree. `tests/all.tcl` ran on both Tcl backends with the
harness's default policy (`BOTLISH_WARNINGS=off`), in one checkout, each run
with a private `-tmpdir` (AGENTS.md, "Running tests concurrently"), in parallel
with native coverage. The suite had **6030 tests before this milestone**
(milestone 3's final count); 6129 = 6030 + the 99 new tests, so no other test
was added or removed.

* **`interp`: 6129 tests, 6129 passed, 0 failed. `compile`: 6129 tests, 6125
  passed, 4 skipped (the existing `coreScoping` constraint), 0 failed.**
* **`tests/same-failure.test`: 99/99 on each of `interp`, `compile`,
  `cranelift-generic` and `cranelift`.**
* **The item-2 files after their adaptation: `tests/warnings.test` 81/81,
  `tests/method-eligible.test` 145/145, `tests/fixed-arity-list-return.test`
  149/149, each on all four backends** (`interp` and `compile` in the full runs,
  `cranelift` and `cranelift-generic` run file by file). Their fuzz smoke tests
  (`warn-fuzz-smoke`, `me-fuzz-smoke`, `fa-fuzz-smoke`) pass, and
  `tests/flags.test` passes 155/155.
* `tests/native-coverage.tcl` (the suite on `cranelift`, as CI's native job):
  6129 tests: 2474 native, 3524 independent of the backend, 71
  passed-partial, 60 unsupported (the constructs it already classifies, the
  same 60 as milestones 2 and 3), **0 failed**. Against milestone 3's 6030 (2470
  native, 3429 independent) the new file adds 4 native and 95 independent tests.
* CI's plain example steps, reproduced: the native job's `main.tcl -backend
  cranelift` corpus step exits 0 with milestone 3's 314 stderr lines and no
  `SAME-FAILURE` line; the Tcl jobs' `main.tcl -backend interp` exits 0 with an
  empty stderr (see "Backend independence and clean outputs").
* This milestone's fuzzer passes 2000 seeds and the mutation tool kills 14/14,
  both on the committed tree; the adapted fixed-arity fuzzer passes 2000 seeds
  with milestone 3's recorded summary line. The corpus audit is the committed
  `corpus-audit.txt`.
* The GC-stress job (`BOTLISH_NATIVE_GC_STRESS=1`, CI on push to `main`) was not
  run locally: nothing under `native/` changed, and the pass runs before any
  backend and changes no HIR (pinned).
* **Second snapshot: the tree merged with `origin/main` `64659f7`** (merge
  `cb939a9`). While this milestone ran, `main` gained the refinement-values
  milestone (REFINEMENT-VALUES.md: `refined type` and `proves` contracts, new
  parser, HIR and native code, a rewritten `lib/web.bot`, a new
  `examples/refinement/` program, and test files added and removed). The only
  textual conflict was AGENTS.md, where both sides appended independent text
  (both kept). Re-run on the merged tree: **`interp` 6090 tests, 6090 passed;
  `compile` 6090, 6086 passed, 4 skipped, 0 failed; native coverage 6090 tests
  (2428 native, 3535 independent, 67 passed-partial, 60 unsupported), 0
  failed**; the four warning test files pass on `cranelift-generic` too (99,
  81, 145, 149). The corpus audit on the merged tree is identical to the
  committed `d9a71f5` audit apart from its commit header (the same single
  finding, the same census and merge check): `main`'s new library and example
  code carries no `SAME-FAILURE` finding, and its new constructs pass through
  the pass without effect. CI's native example step is unchanged (exit 0, the
  same 314 stderr lines, no `SAME-FAILURE` line).

## Known limitations

* **Interprocedural unreachability is not used.** A structurally reachable
  function nobody calls still warns, as in milestones 1-3.
* **A site dead for a reason the compiler cannot prove counts** (the
  over-count direction, see "Reachability"): a repeated `if x == 7: fail E`
  reports 2 exits although the second never runs, because interval range facts
  cannot exclude a single point (`sf-limit-repeated-equality-guard-counts`). A
  smarter walk could only lower such a count or remove such a warning; it can
  never add one.
* **A group's count is per written site.** A `fail` in a loop body is one exit
  however many iterations reach it; two handlers of one call are two exits.
  This is the source-operation rule, inherited.
* **No propagation grouping.** Calls that propagate one failure from several
  places are silent by design (item 4); see "Future warning candidates".
* **No payload rule exercised.** `fail` has no payload today; the conservative
  rule is documented for the day it does (see "The payload question").
* Only the first warning is raised under `error`, as in milestones 1-3.
* Successor note (REFACTOR-WARNINGS-CLEAN.md): the warning-driven refactor
  adopted the merge check's form for `abi::bytes::replace` (one guard, `index
  < 0 or index >= count`), so programs that load `abi::bytes` no longer print
  this code; a gate (`audit/refactor/tools/gate.tcl`, CI) fails on any new
  finding in the corpus.

## Future warning candidates

`SAME-FAILURE` moves from proposal to implemented. Still future, only for
warnings that state a provable fact in this framework:

* a condition that repeats an already established proof;
* manual iteration whose cardinality duplicates another domain (lockstep
  candidates);
* milestone 3's possible extension of `FIXED-ARITY-LIST-RETURN` to helper
  chains (a call-graph worklist), only if a corpus audit shows helper chains
  matter.

**Recorded as a non-candidate: propagation grouping** -- a warning that several
calls in one function propagate the same failure from one callee, or that a
function's written fails and its propagating calls raise one failure. The fact
would be about callees and call sites rather than the function's own exits,
and the corpus shows no evidence for it: the census above has no function whose
repeated failure comes from calls. It stays a non-candidate unless corpus
evidence appears.

Not planned: per-warning flags, `-Wall`/`-Wextra` or levels, call-site
suppression, pragmas or lint-ignore comments, automatic merging of conditions or
exits, a richer-split suggestion or any rewrite or fixit, grouping across
different declared failures, across functions or into nested functions, new
payload-equality machinery, and any new CLI option or `BOTLISH_WARNINGS` value.

## Deviations from the brief

* **The candidate gate is narrower than item 9's definition.** Item 9 defines a
  candidate as "a function with at least one structurally reachable `fail`
  site". The gate here is milestone 1's: some failure has at least two
  structurally reachable sites. Pruning can only remove sites, so a function
  that fails the narrower test can never warn; walking it would only cost time.
  Every walked function is a candidate under the brief's definition too, so
  "walk only for candidates" holds a fortiori, and the trace pin shows a
  one-fail function, a two-distinct-failures function and a dead-site pair are
  not walked.
* **The reachability argument's direction is reversed from the brief's
  wording** (item 9): for this grouping theorem, pruning can only remove
  warnings and imprecision can only over-count; the brief's "imprecision can
  only cause a missed warning / precision can add a warning" is milestone 3's
  uniformity argument. The over-count is pinned as a limitation (see
  "Reachability").
* **CI's plain corpus steps gain no `SAME-FAILURE` line** (item 15 expected
  some): none of their programs loads `abi::bytes`. They still exit 0.
* **The breakage differed from the brief's list.** `tests/warnings.test`'s
  `warn-failures-are-not-returns` broke too (a complete-set assertion over a
  true finding) and was adapted with the file's existing code filter. On the
  fa file, the three-code pin that broke is the registry pin
  `fa-no-new-modes-or-options`, not the stats/trace off-pins (which do not
  enumerate codes), and no `fa-*` error-mode pin broke.
* **"Textually identical fails of different declarations"** cannot be
  constructed: error names are program-unique, so the pin is that every way to
  declare one name twice is rejected (see "Identity is nominal").
* **`data` also carries `note`** (the note text `render` reads), and `failure`
  equals `failureName` because a declared failure *is* its name in this
  repository.
* **No error-style sentence was added.** Item 21 asks for one if the repository
  documents error/failure style. It documents error *semantics*
  (EXPLICIT-ERROR-COMPLETIONS.md) but no style, so none was added; the README's
  warnings section carries the facts.
* **Branch.** `AGENTS.md` says to push finished work to `main`. This session was
  assigned a development branch and told not to push elsewhere without
  permission, so the work was pushed to that branch first, as milestone 3's
  was. It was merged into `main` when asked to, after merging `origin/main`
  (`64659f7`) into it and re-running the regression (above).

## Required questions

**Warning framework**

1. *Enabled by default?* Yes.
2. *All warnings disableable globally?* Yes: `-warnings off`.
3. *All warnings promotable globally?* Yes: `-warnings error`.
4. *Per-warning `-Wfoo`/`-Wno-foo`?* No (`-Wno-same-failure` is an unknown
   option, in process and through `main.tcl`).
5. *Warning groups?* No.
6. *Codes stable?* Yes: `SAME-FAILURE`.
7. *Policy per compilation?* Yes (interleaved compilations pinned).
8. *Does `off` skip the pass?* Yes: no stats entry; a trace shows 0 calls under
   `off` and 1 under `default`.
9. *Does `error` preserve the code?* Yes: `{CORE SEMANTIC SAME-FAILURE}`.
10. *Backend-independent?* Yes: all four backends, in process and through the
    CLI (identical warning text, notes included).

**`SAME-FAILURE`**

11. *Meaning?* Several distinct, reachable exits of one function fail the same
    declared failure.
12. *Grouped with returns?* No: different completion kinds. The rule is now
    bidirectional and pinned both ways (`sf-returns-never-grouped-with-fails`,
    `sf-fails-never-grouped-with-returns`, and milestone 1's
    `warn-failures-are-not-returns`).
13. *Identity?* Nominal: the declared failure the resolver admits the `fail`
    against, which is its program-unique name. No value machinery.
14. *Text matching?* No. Different declarations with identical text cannot
    coexist (rejected, pinned); similar names never group; one declaration
    always groups with itself.
15. *Propagated failures (calls that fail)?* Not exits; silent.
16. *Re-raise inside a handler?* Counts; documented; the corpus has none, so
    there is no noise to judge and no refinement.
17. *Final expression / fall-through?* Not exits (the mirror image of milestone
    1's item 7).
18. *Single exit?* Silent.
19. *Multiple groups per function?* Yes, one per declared failure.
20. *Undeclared failure?* The program has an error diagnostic and is never
    warned (pinned under `-strict 0`).
21. *Prescribes merging or splitting?* No.
22. *Unreachable fails?* Ignored when the compiler can prove them so:
    structural reachability, then the candidate-gated completion walk. No
    executable site is ever dropped; the error direction of imprecision is an
    over-count (a dead site the facts cannot exclude counts, pinned), never a
    miss -- milestone 1's direction, not milestone 3's (see "Reachability").

**Architecture**

23. *Stage?* `surface::lower::Finish`, unchanged.
24. *Which analyses supply the proof?* HIR's `fail` nodes enumerated per
    function (`BodyExprs`), the resolver's failure identity (`declaredErrors`
    over program-unique error names), structural reachability, the completion
    walk, the framework. Not needed: `hir::exact`, alias resolution, candidate
    identity, provenance, annotations, value-exit enumeration, a call graph, or
    any change to the walk.
25. *Record shape and secondary locations?* `{code message primary secondary
    data}`; secondary = the group's other exits, one `note: also raised here`
    line each.
26. *Deterministic ordering, four codes?* The inherited `Sort`; pinned in both
    orders, plus the repeated-returns-and-fails function.
27. *Duplicates across instances?* None: the generic source HIR once; instances
    never walked (pinned, and killed as a mutant).
28. *Framework changes beyond the registry line?* None. The recording-walk
    contingency was not exercised: the walk already records fail sites.
29. *New HIR state?* None (`sf-no-new-hir-state`).
30. *Does `error` reject before backend lowering?* Yes (traces on all four
    entry points; a cranelift CLI run prints no value).
31. *Structurally collectable?* Yes: `hir::warnings::of` / `collect`.
32. *What was the item-2 inventory, and what was adapted by whom?* Five
    breakages (two stats pins, the fa registry pin, `warn-failures-are-not-
    returns`, and the fa fuzzer's smoke), all adapted in this milestone, which
    owned them because the parallel-agent split for such pins had ended; the
    milestone-1/2 fuzzers and `tests/flags.test` were unaffected. See
    "Kickoff".

**Verification**

33. *Corpus findings?* 1 at `d9a71f5`: `abi::bytes::replace`'s
    `IndexNotFound` guard pair, an un-split repeated guard (combine-conditions
    candidate; the failure is uniform by design). 12 near misses, all
    distinct-failure range guards.
34. *False positives?* Zero.
35. *Warning-mode tests pass?* Yes. `tests/same-failure.test` 99/99 on `interp`, `compile`,
    `cranelift-generic` and `cranelift`; after their adaptation
    `tests/warnings.test` 81/81, `tests/method-eligible.test` 145/145 and
    `tests/fixed-arity-list-return.test` 149/149 on the same four backends.
36. *Fuzzer and mutation results?* 2000 seeds, 1148 with warnings and 852
    without, 2298 groups: 0 failures, 0 extras. 14 of 14 mutants killed (the 11 required among them): 9 by the fuzzer, 5 by the unit tests; 3 of those 5 are output-equivalent by design and are killed by the candidate-gate trace pin.
37. *Backend parity?* Identical sets on all four (in process and CLI).
38. *Full regression?* 6129 tests on `interp` (6129 passed) and `compile` (6125
    passed, 4 skipped by the existing constraint), 0 failures each; native
    coverage 6129 tests, 0 failed (2474 native, 3524 independent, 71
    passed-partial, 60 unsupported). The adaptations changed only the five
    pins listed in "Kickoff" (and the fixed-arity fuzzer's oracle, which only
    `fa-fuzz-smoke` runs), so those five are everything the pass broke.
