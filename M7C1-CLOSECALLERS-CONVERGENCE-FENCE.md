# M7.c.1: CloseCallers convergence fence

## Outcome

Implemented and regression-tested. `CloseCallers` (M7.c,
M7C-CLOSED-CLOSURE-ENTRY-FACTS.md) is now a **transactional** post-Fixpoint
precision pass: its candidate analysis is committed only after a complete
round of its own bounded round loop changes nothing; if its round budget is
exhausted while a complete round is still changing state, the whole
candidate is discarded and the ordinary pre-CloseCallers specialization
snapshot (the already-sound baseline `-closed-caller-facts-opt 0` also
produces) is returned unchanged.

```
git diff --stat (production + this milestone's own report correction):
 hir/specialize.tcl              | 72 +++++++++++++++++++++++++++++++++++--
 M7C-CLOSED-CLOSURE-ENTRY-FACTS.md | 24 +++++++++++++
 2 files changed, 93 insertions(+), 3 deletions(-)

New test file: tests/close-callers-convergence.test, 24 tests, all passing.
```

No other production file changed. `native/lower.tcl`, `hir/blockescape.tcl`,
`hir/types.tcl`, `hir/range.tcl`, and every other module are byte-for-byte
unmodified. No `.bot`/`.ir`/`lib/*.bot` source changed.

## Current CloseCallers convergence semantics (before this milestone)

Before this milestone, `CloseCallers`' own round loop (`for {set round 1}
{$round <= $passLimit} {incr round} { ... if {!$changed} break }`) had no
failure branch at all: whether the loop exited because a round changed
nothing, or because `passLimit` (16) rounds were exhausted while state was
still changing, every already-applied per-instance overlay/result change
was kept regardless, and `analyze` returned it as final. A partially
ascended, unproven candidate could therefore be committed exactly as if it
were a genuine fixpoint -- the gap this milestone closes. (In practice the
production budget of 16 is ample for every case measured in M7.c's own
report or this milestone's own fixtures, so this gap was never observed to
fire in shipped output; it is a latent safety hole, not a reproduced
regression.)

## Mutation-surface audit (spec section 5)

Inspected directly, by grepping every `dict set state`/`dict incr state`/
`dict lappend state` in `hir/specialize.tcl` and reading each one's
surrounding proc:

- **`Reanalyze`** (the M7.c per-instance re-inference proc `CloseCallers`
  calls every round): writes exactly one place, `dict set state instances
  $id $instance`, and only when its own `changed` test is true. The
  `instance` value it writes has `overlay`, `reachable`, and `result` set
  from this call's own re-inference; `seeds`, `calls`, `creates`, `values`,
  `edges`, `args`, `generic`, `name`, `block`, `id`, `passes` are all
  whatever `dict get $state instances $id` already held -- `Reanalyze`
  never assigns any of them. It touches no other `state` field: no
  `queue`/`deps`/`refs`/`byBlock`/`seeds` (the top-level captured-binding
  seed table, distinct from an instance's own `seeds` field)/`current`/
  `building`/`analyses`. It calls `hir::types::inferRegion` with
  `FrozenHandle`, which for `call` only ever reads `[dict get $state
  instances ... result]` (no write) and for `create` does nothing at all
  (`return` with no body) -- confirmed by reading `FrozenHandle` directly:
  it never calls `Instance`, `Requeue`, `AddRef`, or `DropRef`.
- **`CloseCallers`** itself: `dict set state instances $id result never`
  (the pre-round-loop reset, for every id `ClosedCallerFacts` found a fact
  for) and, per round, whatever `Reanalyze` itself wrote. No other `state`
  field is ever assigned inside `CloseCallers`.
- **`ClosedSet`/`InstanceClosed`/`MaterializedBlocks`/`ClosedCallerFacts`/
  `CombineCallerTheorem`**: read-only. None contains a `dict set`/`dict
  incr`/`dict lappend` on `state` at all (confirmed directly: grepping the
  whole M7.c section, lines 785-1220 of the pre-M7.c.1 file, for those three
  forms finds exactly the two sites above and nothing else).
- **`hir::blockescape::analyze`** (called once per `CloseCallers` run): the
  whole module (`hir/blockescape.tcl`) declares zero namespace variables
  (confirmed by grep) -- it is a pure function of its `$hir $snapshot`
  arguments, with no cache or other global state to leak through.
- **`hir::types::intern`** (called by `view`/`inferRegion` while computing
  overlays): takes its `hir` argument by `upvar` and writes only into that
  local variable's own `types`/`typeIds` tables -- never a namespace
  variable. `hir/types.tcl`'s own namespace variables
  (`aggregateDepth`/`shapeLength`/`constructors`) are fixed configuration
  constants, never written during analysis.

**Answers (spec section 5's own required answers):**

- *Which fields can change during CloseCallers?* Exactly `overlay` and
  `result`, on `state instances`, and only for an instance `ClosedCallerFacts`
  found a fact for.
- *Which are intentionally frozen?* Everything else: `calls`, `creates`,
  `values`, `edges`, `args`, `generic`, `name`, `block`, `id`, `seeds`,
  `passes`, the whole `used`/`keys`/`queue`/`deps`/`refs`/`byBlock` set, and
  every namespace variable outside `state instances` itself.
- *Does Reanalyze mutate only the snapshot dict passed to it?* `Reanalyze`
  does not take a snapshot argument at all -- it mutates `state instances`
  directly (the same shared namespace variable `Analyze`/`Fixpoint` use).
  This is fine for transactionality precisely because `state instances` is
  the *only* field it (or `CloseCallers`) ever touches: capturing that one
  field's value before the pass and restoring it afterward is a complete
  rollback, without needing a separate snapshot argument-threading scheme.
- *Does anything escape into namespace/global state that rollback of the
  snapshot would fail to restore?* No (see the module-by-module audit
  above): `hir::blockescape` and `hir::types::intern` are the two calls
  that could plausibly cache something, and neither does.

## No new graph structure (spec section 6)

`Reanalyze` calls `hir::types::inferRegion` with `FrozenHandle` (never the
ordinary `Handle`) in place of the region-inference handler. `FrozenHandle`
implements exactly two ops:

```tcl
call    { if {![dict exists $calls $e]} { return any }
          return [dict get $state instances [dict get $calls $e] result] }
create  { return }
```

`create` does nothing (no `Instance` call, so no new instance; no seed
write, so no new captured-binding fact). `call` never calls `Instance`; it
can only resolve to a target already present in `$calls` (the *frozen*
snapshot of `id`'s own `calls` map, passed in as `FrozenHandle`'s own bound
argument, exactly as it stood when the ordinary `Fixpoint` last analyzed
`id`) -- an unrecognized call position degrades to `"any"` rather than
inventing a target. So: no new instance, no new call edge, no new closure
creation, no new used block -- confirmed by reading `FrozenHandle` itself,
not merely assumed from the header comment above it. **Expected: only fact
state changes. Confirmed.**

## Convergence, defined exactly (spec section 7)

Convergence means: one complete `CloseCallers` round (a single pass of the
round loop's own body: recompute `ClosedCallerFacts`, then `Reanalyze` every
instance with a fact) produces zero relevant state changes. "Relevant state
change" is `Reanalyze`'s own `changed` test:

```tcl
set changed [expr {$overlay ne [dict get $instance overlay] || $inferred ne $oldResult}]
```

This is the *complete* change signal, not merely a convenient proxy,
because `overlay` and `result` are the *only* two fields this pass ever
writes (the mutation-surface audit above) -- there is no third field a
later round, or a downstream consumer (`view`, `hir::aot::analyzeRegion`),
could read a stale value from that this test does not already cover.
`overlay` itself is compared as a whole dict, and a change in an
expression's `reachable` flag (relative to the *semantic* base HIR) is
already one of the three conditions that puts an entry in `overlay` in the
first place (`hir/specialize.tcl`'s own `Analyze`/`Reanalyze`, identical
construction) -- so a round-to-round reachability change necessarily shows
up as an overlay-dict difference too; there is no way for `reachable` to
drift without `overlay` also differing. Convergence is **not** "we executed
`passLimit` rounds" (the pre-M7.c.1 code never even distinguished the two;
this milestone's whole point is to distinguish them), and **not** "result
happened not to change but overlay did" (the `||` in the test above already
treats either alone as a change; this milestone changes nothing about the
test itself, only what happens when it never once reports "no change"
within the budget).

## Off-by-one semantics, pinned (spec section 8)

Required and confirmed by direct test (`boundary-stable-on-final-round-
commits`, `boundary-changing-on-final-round-rolls-back`,
`tests/close-callers-convergence.test`):

- Round `N` produces no change, and `N == roundLimit`: **converged, commits**
  (the loop's own `if {!$changed} { set converged 1; break }` fires exactly
  at round `N`, whether or not `N` is the last permitted round).
- Round `roundLimit` still changes state: **not converged, rolls back** (the
  `for` loop's own condition `$round <= $roundLimit` becomes false after
  incrementing past `roundLimit` without ever seeing `changed == 0`, so
  `converged` is left at its initial `0`).

Empirically (not merely by inspection of the loop), using the primary
fixture below: round budget 1 does not converge (round 1's own reset-driven
change is never confirmed stable); round budget 2 converges (round 2 is
stable). Using the cascade fixture: round budget 2 does not converge (round
2 itself still changes state, from the cascade); round budget 3 converges.

## Transaction boundary (spec section 9)

```tcl
set baseline [dict get $state instances]
...
if {!$converged} {
    dict set state instances $baseline
}
```

`baseline` is captured by a single, ordinary `dict get`/assignment, at the
very top of `CloseCallers`, before any mutation (including the pre-round-
loop `result never` reset) happens. Tcl dicts (like every Tcl value) have
copy-on-write value semantics: `set baseline [dict get $state instances]`
binds `baseline` to the dict *value* `state instances` holds at that
instant; every subsequent `dict set state instances $id ...` inside
`Reanalyze`/`CloseCallers` rebinds the `state` variable to a new value --
it does not, and structurally cannot, mutate the value `baseline` still
refers to. No deep-copy helper, snapshot library, or reference-breaking
machinery is needed; this is the same value-semantics argument the file's
own pre-existing code already leans on throughout (e.g. `CloseCallers`'
own pre-existing `snapshot` variable, built the identical way). This is
proven, not merely assumed, by the structural-equality tests below
(`instanceDump` compares the *actual* returned value after rollback against
the actual `-closed-caller-facts-opt 0` baseline, field by field, for every
used instance).

## No mutation of baseline (spec section 10)

`baseline`'s own nested values (each instance's `overlay`/`result`/etc.,
themselves dicts/lists) are never mutated in place either, for the same
reason: Tcl has no in-place-mutable nested containers reachable through a
plain variable copy -- `dict set outer key value` on a *different* variable
(`state`) cannot reach into `baseline`'s own copy of that nested structure.
`tests/close-callers-convergence.test`'s own
`forced-insufficient-round-matches-opt-off-baseline`,
`cascade-insufficient-budget-rolls-back-both-instances`, and
`recursive-result-full-structural-rollback` tests demonstrate this directly:
each compares `instanceDump` (identity, args, generic, full overlay, result,
calls, edges, for every used instance, in `used` order) between a forced-
insufficient run and the true `-closed-caller-facts-opt 0` baseline and
asserts `eq` (Tcl's exact structural/string equality over the whole nested
value) -- not merely that one particular guard or theorem matches.

## Prefer complete pass rollback (spec section 11)

Implemented exactly this way: `CloseCallers` restores the *entire*
`instances` dict via one `dict set state instances $baseline`, never a
per-instance or per-SCC conditional restore. The cascade fixture's own
`cascade-insufficient-budget-rolls-back-both-instances` test demonstrates
this is not vacuous: at the forced round budget used there, `middle`'s own
theorem was already individually stable after round 1 (it depends only on
`outer`'s literal calls, needing no iteration), while `inner`'s own theorem
was not yet stable (it depends on `middle`'s own, still-settling view) --
yet the test confirms `middle` is *also* rolled back to its pre-CloseCallers
value, not kept merely because it happened to look converged on its own.

## Why `result = any` alone is insufficient (spec section 12)

Documented in the source comment directly on `CloseCallers` (see "Source
comment" below) and demonstrated by `recursive-result-partial-result-not-
committed`/`recursive-result-partial-overlay-not-committed`: `CloseCallers`
can change **both** `overlay` and `result` for a reanalyzed instance, and a
downstream consumer (`view`, `hir::aot::analyzeRegion`, hence
`paramGuards`) reads the *overlay*, not `result`, to decide whether a
representation guard is still present. Poisoning only `result` to `any`
would leave an unconverged, partially-narrowed `overlay` (e.g. a guard
already removed on the strength of an unproven theorem) fully in place --
unsound, and not even self-consistent (a guard-free region whose own
declared `result` is simultaneously the least-informative type). Whole-pass
rollback of the one field that contains both (`instances`) is the only rule
that cannot leave such a mismatch.

## Chosen fallback semantics (spec section 3, repeated for the record)

Transactional rollback of the whole `CloseCallers` pass to the ordinary
pre-CloseCallers snapshot -- not "keep the current result," not "poison
only `result`," not "keep overlays but poison result," not "salvage
instances that look converged," not "guess which SCC caused the problem."
The mutation-surface audit above is what makes this the *provably*
sufficient smallest rule: since overlay and result are the only fields this
pass ever writes, and both live in the one `instances` field restored,
nothing else needs restoring.

## Exact convergence/off-by-one rule

Stated fully above ("Convergence, defined exactly" / "Off-by-one
semantics"). Summary: a round that changes nothing is convergence,
regardless of which round number it is; exhausting the budget while still
changing is not, regardless of which round number that is either.

## Internal forced-limit test mechanism (spec section 16)

A test-only namespace variable, `hir::specialize::closeCallersRoundLimit`
(default `""`, meaning "use the production `passLimit`, 16"), read only by
`CloseCallers` itself:

```tcl
set roundLimit [expr {$closeCallersRoundLimit ne "" ? $closeCallersRoundLimit : $passLimit}]
```

Never read by the ordinary `Fixpoint`'s own `passLimit` (a completely
separate namespace variable, never assigned by this mechanism). No new
user-visible surface flag was added: `-closed-caller-facts-opt` still means
exactly what it meant before (whether the M7.c pass is attempted at all);
this variable only ever narrows *how many rounds* an already-attempted pass
gets, and only when a test explicitly sets it. A second test-only variable,
`hir::specialize::closeCallersConverged` (default `1`), records whether the
most recently completed `CloseCallers` run committed (`1`) or rolled back
(`0`) -- a debug/audit signal in the same spirit as `passes` (already an
existing, inspectable per-instance counter), not a new diagnostic surfaced
to users or written to any HIR/program-visible state. `native/lower.tcl` is
untouched: this milestone adds no native-boundary option at all (spec
sections 31-32).

## Primary forced-nonconvergence fixture

Reused directly from `tests/closed-closure-entry-facts.test`'s own
`positiveFixture` (one value-capturing closure, two exact Int callers):

```
fn outer(tag):
    fn inner(x):
        x + length(tag)
    inner(1) + inner(2)
outer("v")
```

Empirically (confirmed by a throwaway probe script before writing the test,
then pinned directly by the test itself), round budget 1 does not converge:
`CloseCallers`' own pre-round-loop reset (`result` -> `never`, needed for
the *separate*, genuinely recursive case below) makes round 1 look like a
change for *any* closed+called instance whose true result is not itself
`never` -- so even this simplest, non-cascading fixture needs round 2 to
*confirm* round 1's own theorem was already stable. This is documented
explicitly in the test file and in "Boundary-round controls" below, because
it means round budget 1 is already the correct, smallest boundary fixture
for the off-by-one pin -- no separate, more complex construction was needed
for it specifically. With round budget 1: not converged, `inner`'s own
guard (`UnknownParameterKind`) remains, and the whole candidate is
structurally identical (`instanceDump`) to the `-closed-caller-facts-opt 0`
baseline.

A second, genuinely cascading fixture (spec item 17's own preference for
reusing a real cascade) is reused from the same suite's own
`capturedThroughParentFixture`:

```
fn outer(tag):
    fn inner(x):
        x + length(tag)
    fn middle(y):
        inner(y)
    middle(1) + middle(2)
outer("v")
```

`middle`'s own theorem (Int) is available starting round 1 (from `outer`'s
literal calls, needing no iteration); `inner`'s own theorem is derived from
`middle`'s own *already-reanalyzed* view of its call to `inner`, so it only
starts improving once `ClosedCallerFacts` is recomputed fresh in round 2 --
confirmed empirically: round budget 2 does not converge (round 2 itself
still changes state, because of `inner`'s cascade), round budget 3 does.
This is the fixture `cascade-needs-more-than-two-rounds`,
`cascade-insufficient-budget-rolls-back-both-instances`, and
`cascade-sufficient-budget-converges` exercise.

## Baseline-vs-rollback structural comparison

`instanceDump` (in `tests/close-callers-convergence.test`) captures, per
used instance, in `used` order: `id`, `name`, `args`, `generic`, the full
`overlay` dict, `result`, `calls`, and `edges` -- i.e. identity, the key,
genericity, both fields `CloseCallers` can ever write, and both fields that
witness the call graph. `forced-insufficient-round-matches-opt-off-
baseline`, `cascade-insufficient-budget-rolls-back-both-instances`, and
`recursive-result-full-structural-rollback` each assert this whole
structure is `eq` (exact) between a forced-insufficient (rolled-back) run
and the true `-closed-caller-facts-opt 0` baseline -- not merely that one
instance's guard count matches.

## Successful convergence control

`sufficient-round-budget-converges`/`sufficient-round-budget-guard-
eliminated` (primary fixture, budget 2) and `cascade-sufficient-budget-
converges`/`cascade-sufficient-budget-theorem-and-guard` (cascade fixture,
budget 3) confirm the same fixtures used for the rollback controls above do
converge with enough budget, and produce the improved theorem/eliminated
guard -- proving the rollback controls are genuinely exercising the
rollback of a useful optimization, not a no-op.
`production-default-converges-and-matches-forced-sufficient` and `cascade-
production-default-matches-forced-sufficient` further confirm the
production default (16, no override) reaches the *identical* structural
result as the forced-sufficient budget, for both fixtures.

## Boundary-round controls

`boundary-stable-on-final-round-commits` (budget 2, primary fixture:
converges) and `boundary-changing-on-final-round-rolls-back` (budget 1,
same fixture: rolls back) pin the off-by-one rule directly, as does the
cascade fixture's own budget-2-vs-3 pair. See "Off-by-one semantics" above
for why budget 1 is already the correct boundary case for the primary
fixture (no separate "round 1 changes, round 2 stable" construction was
needed beyond what this fixture already does).

## Recursive/result control

`recursiveResultFixture` (new fixture, not reused, because none of M7.c's
own existing fixtures exercises a genuinely self-referential *result* --
see below):

```
fn outer(tag):
    fn inner(x, n):
        if n <= 0:
            [x, length(tag)]
        else:
            concat([x], inner(x, n - 1))
    inner(1, 3)
outer("v")
```

`inner`'s own *result* (not merely a representation guard) is imprecise
pre-theorem: the recursive branch's own list literal must join with
`inner`'s own self-referential result, which only narrows once `x`'s own
closed-caller theorem (Int, from the sole non-self caller `inner(1, 3)`)
reaches it. Empirically: `-closed-caller-facts-opt 0` and a forced round
budget of 2 both leave `inner`'s own result at `list[any, int]` (`x`'s own
contribution to the list literal unresolved) with `inner`'s own guard
present; round budget 3 narrows the result to `List[int]` and removes the
guard. `recursive-result-partial-result-not-committed` confirms the
*exact* pre-theorem value (`list[any, int]`, not some other partially-
narrowed value) survives at budget 2, matching the true baseline exactly;
`recursive-result-full-structural-rollback` confirms this across every
field of every used instance, not just `inner`'s own result. This directly
exercises the class of issue M7.c's own result-reset-then-widen discipline
(`Reanalyze`'s "widen, never overwrite" comment) was designed to make safe
once `CloseCallers` converges -- this milestone's own fence is what makes
it safe when `CloseCallers` does *not* converge.

## Normal M7.c behavior preservation

`tests/closed-closure-entry-facts.test`: **32/32 passing**, unmodified
(same file, same expected values as M7.c's own report). Frozen-corpus guard
counts, re-measured directly with `audit/m7a-instance-selection/tools/
corpus.tcl` (unmodified) against the current tree:

| | `uri-steady.bot` | `refined-checks.ir` |
|---|---:|---:|
| used instances | 19 (unchanged) | 39 (unchanged) |
| machine code bytes | 5746 (unchanged) | 14898 (unchanged) |
| guards | **0** (unchanged) | **3** (unchanged) |

Byte-for-byte identical to M7.c's own recorded post-M7.c figures. The
production round budget (16) is never the limiting factor for either
benchmark (both cascades this report already measured resolve well inside
it), so this milestone's own fence is never exercised by shipped output --
confirmed, not merely assumed, by these unchanged measurements.

## Identity/allocation/codegen preservation

Instance counts (19/39), Block allocations (1/2, from M7.c's own report,
unaffected by a diff confined to `hir/specialize.tcl`'s fact-state fields),
and machine-code byte counts above are all unchanged. No native lowering
rule, closure layout, RC/ABI decision, or runtime representation was
touched -- confirmed by `git diff` touching only `hir/specialize.tcl` (plus
this milestone's own two `.md` files and one new `.test` file) with no
`native/`, `hir/blockescape.tcl`, or `hir/escape.tcl` change at all.

## Focused regressions

Run directly against the current tree with this milestone's own changes in
place:

| suite | result |
|---|---|
| `tests/close-callers-convergence.test` (new) | 24/24 passed |
| `tests/closed-closure-entry-facts.test` | 32/32 passed |
| `tests/conjunctive-entry-facts.test` | 28/28 passed |
| `tests/hir-specialize.test` | 27/27 passed |
| `tests/hir-range.test` | 52/52 passed |
| `tests/hir-call-facts.test` | 8/8 passed |
| `tests/hir-callable-target.test` | 8/8 passed |
| `tests/hir-closed-call-params.test` | 15/15 passed |
| `tests/native-block-escape.test` | 48/48 passed |
| `tests/typed-callable-escape.test` | 35/35 passed |

Every count matches the pre-M7.c.1 baseline exactly, plus the 24 new tests,
all passing.

## Full regression

```
tclsh9.0 tests/all.tcl
```

Run to completion after every production change in this milestone was in
place (native Cranelift backend rebuilt first, per `AGENTS.md`, with a
`rustup` stable toolchain new enough for the pinned `cranelift-*`/
`wasmtime-internal-*` crates): **2298/2298 passing, 0 failed**, 81 test
files sourced (M7.c's own report recorded 2274/2274 across 80 files; the
difference is exactly this milestone's own 24-test file, 2274 + 24 = 2298,
confirming nothing else regressed). `interp`/`compile` backend coverage per
`tests/all.tcl`'s own `foreach backend {interp compile}` header;
`cranelift`/`cranelift-generic` coverage confirmed separately via the
frozen-corpus tool above and `tests/closed-closure-entry-facts.test`'s own
four-backend `runtime-parity-*` tests (all still passing, unmodified).

## GC policy

Not run. This milestone's entire production diff is confined to
`hir/specialize.tcl`'s own static specialization-analysis layer (a
transaction boundary and a round-budget check around an existing pass); no
closure layout, rooting, retain/release placement, allocation site, stack
map, or GC-sensitive lowering rule was touched, and no `native/` file
changed at all. Per the project's own stated policy (`AGENTS.md`), a
theorem/control-flow-only change with this diff shape does not require it.

## Source-fence confirmation

`git status`/`git diff` confirm no change under `bench/*.bot`, `bench/*.ir`,
or any file under `lib/`. The only files this milestone touched are
`hir/specialize.tcl` (production), `M7C-CLOSED-CLOSURE-ENTRY-FACTS.md`
(the drive-by documentation correction spec item 33 asks for), and the new
`tests/close-callers-convergence.test`.

## M7.c documentation update

`M7C-CLOSED-CLOSURE-ENTRY-FACTS.md` gained a new "M7.c.1 drive-by:
CloseCallers' own convergence fence" section, immediately after "Cascades
and fixpoint," stating the transactional rule in the report's own words
(see that section) without rewriting any of M7.c's own results tables.

## Remaining convergence risk

None identified within this milestone's own scope. The production round
budget (16) is unchanged and has never been observed to be insufficient for
any real cascade this report or M7.c's own report measures; this
milestone's fence only changes what happens in the (currently
unobserved-in-production) case where it would be. The one honestly-reported
residual is architectural, not a risk this milestone leaves open: `M7.c.1`
does not attempt SCC-specific salvage (out of scope, spec item 4/11), so a
program whose family-1b cascade is deep enough to need more than 16 rounds
would lose the *entire* pass's improvement for every instance in that
cascade, not just the slow-converging ones -- exactly the documented,
intentional trade-off ("prefer complete pass rollback") rather than an
oversight. No frozen-corpus or fixture program in this repository comes
close to that depth.

---

## Required architecture questions

1. **What exact state does `CloseCallers` mutate?** Exactly two fields of
   `state instances` (`overlay`, `result`), for instances `ClosedCallerFacts`
   found a caller-derived fact for. See "Mutation-surface audit."
2. **Does any mutation escape the snapshot object?** No -- confirmed by
   inspecting `Reanalyze`, `FrozenHandle`, `hir::blockescape::analyze`, and
   `hir::types::intern` directly, not merely by assuming the pre-existing
   header comment was complete.
3. **Is the pre-CloseCallers snapshot already a complete, sound ordinary
   specialization result? Required: yes.** Yes: it is exactly what
   `hir::specialize::Fixpoint` (unmodified, unaffected by this milestone)
   already produces, and exactly what `-closed-caller-facts-opt 0` returns.
4. **What exact event establishes convergence?** One complete round of the
   loop (`ClosedCallerFacts` recomputed, every id in `facts` reanalyzed)
   with `changed` staying `0` for that entire round.
5. **Does "round budget exhausted" by itself establish convergence?
   Required: no.** No -- this is the exact gap this milestone closes;
   `converged` is only ever set to `1` inside the `if {!$changed}` branch,
   never by the `for` loop's own exit condition alone.
6. **If the final permitted round is stable, is that success? Required:
   yes.** Yes -- confirmed by `boundary-stable-on-final-round-commits`.
7. **If the final permitted round changes state, what happens? Required:
   rollback.** Rollback -- confirmed by `boundary-changing-on-final-round-
   rolls-back` and the cascade fixture's own budget-2 test.
8. **What exact snapshot is returned on rollback?** `baseline`: the value
   `dict get $state instances` held at the very start of `CloseCallers`,
   before any mutation in this pass (including the pre-round-loop `result
   never` reset).
9. **Can any caller-derived theorem remain after rollback? Required: no,
   except facts that were already present independently before M7.c.**
   Confirmed by every `instanceDump`-based structural-equality test: a
   rolled-back candidate is `eq` to the true `-closed-caller-facts-opt 0`
   baseline, which by definition carries no caller-derived theorem at all.
10. **Can any re-settled result fact remain after rollback? Required:
    no.** Confirmed directly by `recursive-result-partial-result-not-
    committed`: `inner`'s own result at a forced-insufficient budget is
    the exact pre-theorem value, not a partially re-settled one.

## Required safety questions

11. **Why isn't keeping the current partially ascending result safe?**
    Because a later round's own facts are derived from an earlier round's
    overlays (`ClosedCallerFacts` reads the *current* `snapshot`, updated
    after each round) -- a partial round's cross-instance dependencies mean
    an instance that "looks" stable may still depend on a sibling's
    not-yet-stable fact (the cascade fixture's own `middle`, individually
    stable after round 1 but rolled back anyway because `inner` never
    stabilized within budget, is a measured demonstration, not merely an
    argument).
12. **Why isn't merely setting the result to `any` enough?** Because
    `overlay` (which is what guard elimination actually reads, via `view`/
    `hir::aot::analyzeRegion`) is a *separate* field from `result`, and both
    can carry unproven precision; poisoning only one leaves the other's
    unsound improvement in place (see "Why result = any alone is
    insufficient").
13. **Why is whole-pass rollback obviously conservative?** Because the
    pre-CloseCallers snapshot is exactly the already-established,
    independently sound ordinary-Fixpoint result -- the same one
    `-closed-caller-facts-opt 0` returns and every M1-M7.b guarantee already
    holds for. Discarding an unproven candidate can only return to a state
    already known correct, never to an unknown one.
14. **Can rollback make a legal program illegal? Required: no.**
    `CloseCallers`/`Reanalyze` never call `hir::Diagnose` or raise a static
    error either way (unchanged from M7.c: see that report's own Q44); a
    rollback is simply "use the pre-existing, already-legal snapshot."
15. **Can rollback change runtime semantics relative to M7.c being
    disabled? Required: no.** A rolled-back candidate is structurally `eq`
    to the `-closed-caller-facts-opt 0` baseline (confirmed by the
    structural-equality tests), and M7.c's own report already establishes
    that toggling that flag never changes runtime behavior (its own
    `runtime-parity-*` tests, unmodified, still passing).
16. **Can non-convergence produce a compiler error? Required: no.**
    Confirmed: every fixture in the new test file, including the
    intentionally forced-insufficient ones, compiles and analyzes without
    error; `CloseCallers` has no error/throw path added by this milestone.
17. **Can non-convergence alter specialization identity? Required: no.**
    Confirmed by `identity-unchanged-across-off-insufficient-sufficient`:
    instance labels and used-instance counts are identical across the
    baseline, a rolled-back run, and a committed run.
18. **Can non-convergence create/remove instances? Required: no.**
    Confirmed by `call-graph-unchanged-across-off-insufficient-sufficient`
    and the `FrozenHandle` audit above (`Reanalyze` never calls `Instance`).

## Required testing questions

19. **How is non-convergence forced deterministically?** The test-only
    namespace variable `hir::specialize::closeCallersRoundLimit`, read only
    by `CloseCallers`, set via the test file's own `specWithRoundLimit`
    helper (which restores it to `""` in a `finally` block even if the body
    errors).
20. **Does the forced mechanism avoid changing the ordinary Fixpoint
    budget? Required: yes.** Yes -- `hir::specialize::passLimit` (the
    ordinary Fixpoint's own namespace variable) is never read or written by
    this mechanism; `CloseCallers` reads its own `roundLimit` local,
    computed from `closeCallersRoundLimit` if set, else `passLimit` itself
    (read, never written).
21. **Is there a fixture that needs multiple CloseCallers rounds?
    Required: yes.** Yes -- the cascade fixture (`inner`/`middle`), needing
    3, and the recursive-result fixture, also needing 3.
22. **With an insufficient limit, does it exactly match the optimization-
    off baseline? Required: yes.** Yes -- confirmed by `instanceDump`
    structural equality for all three non-convergence tests (primary,
    cascade, recursive-result).
23. **With a sufficient limit, does the M7.c theorem appear? Required:
    yes.** Yes -- confirmed by the "sufficient" pair for each fixture
    (guard gone, theorem present/result narrowed).
24. **Is the last-round stable/unstable off-by-one behavior pinned?
    Required: yes.** Yes -- `boundary-stable-on-final-round-commits`/
    `boundary-changing-on-final-round-rolls-back`.
25. **Is partial overlay leakage tested? Required: yes.**
    `recursive-result-partial-overlay-not-committed` and every
    `instanceDump`-based structural-equality assertion (overlay is one of
    the compared fields).
26. **Is partial result leakage tested? Required: yes.**
    `recursive-result-partial-result-not-committed` and the same
    structural-equality assertions.

## Required regression questions

27. **Do all 32 existing M7.c tests still pass?** Yes, unmodified,
    confirmed directly.
28. **Do ordinary M7.c successful programs produce the same guard/code
    output?** Yes -- `uri-steady.bot`/`refined-checks.ir` re-measured
    byte-for-byte identical to M7.c's own report (0/3 guards, 5746/14898
    bytes, 19/39 instances).
29. **Are instance counts unchanged?** Yes (19/39, both benchmarks).
30. **Are allocation counts unchanged?** Yes, re-measured directly by the
    same corpus-tool run: `uri-steady.bot` 61,510 objects / 2,544,568 bytes
    (Block=1); `refined-checks.ir` 23 objects / 1,085 bytes (Block=2) --
    both byte-for-byte identical to M7.c's own recorded figures.
31. **Are closure/capture/call forms unchanged?** Yes -- `git diff` shows no
    change to `native/lower.tcl` or any lowering-adjacent file; NIR-op
    counts were not re-run standalone but follow from the identical
    machine-code byte counts and unchanged instance/guard counts above.
32. **Was no native lowering rule changed?** Confirmed: `native/lower.tcl`
    is byte-for-byte unmodified (`git diff` shows no change to it).
33. **Was no source program changed? Required: yes.** Confirmed: no
    `.bot`/`.ir`/`lib/*.bot` file appears in `git status`/`git diff`.
