# Range fixpoint scaling

## Outcome

`hir::range::analyze` scaled quadratically with program size because
`Fixpoint`'s rounds, and `NarrowRounds`' rounds, redid all of their work on
every instance in every round, while the number of rounds grows with the
depth of the call graph. Both loops now redo only the work whose inputs
changed. The iteration itself is unchanged (same rounds, same order, same
facts after every round), so the analysis result is identical by
construction. It was also checked byte for byte: the range analysis results
and the NIR of every compilation in `tests/all.tcl`, `tests/native-coverage.tcl`,
the corpus (`bench/corpus.tcl`) and every example/bench `.bot` file are
identical to the parent's (§ 4).

Files: `hir/range.tcl` (`Fixpoint`, `NarrowRounds`, five small helpers),
`tests/range-fixpoint-scaling.test` (4 tests),
`audit/range-fixpoint-scaling/tools/` (program generators, timing harness,
output dump and comparison).

## 1. Diagnosis

### The hypothesis

The starting hypothesis was that `Fixpoint` runs whole rounds over every used
instance, that a fact on a call chain needs a round per call edge to travel,
and so that the cost is O(n²). That is confirmed, with one addition: the
narrowing rounds have the same shape.

### What a round did

`Fixpoint`'s ascending loop is a Jacobi iteration. Each round

1. settles every used instance (`SettleInstance`: one `AnalyzeInstance`
   walk, plus its own self-call passes) from the facts the previous round
   left;
2. folds every reached exact call's argument Ranges into its callee's
   entry facts, every creation site's capture Ranges into its child block's
   capture facts, and every instance's result into its summary;
3. stops when no fact changed.

The folds are applied at the end of the round, so a fact crosses exactly one
call edge per round. In the benchmark chain (`fN` calls `f(N-1)` in both
branches of an `if`), the entry facts of `fN` are known after round 1 and
those of `f(N-k)` after round k+1. Results flow back up the same way. So the
loop needs about N rounds, and each round walked all N instances:

| N (functions) | used instances | rounds | `SettleInstance` calls |
|---|---|---|---|
| 50 | 52 | 52 | 2,704 = 52² |
| 100 | 102 | 102 | 10,404 = 102² |

`NarrowRounds` (M9's post-widen narrowing and the result-narrowing pass)
has the same structure: every round re-walks every instance once. On the
benchmark chain it converges in one round, because the ascending phase's
facts are already exact there. When a *narrowed* fact has to travel down a
chain it needs one round per edge as well. In the `narrow` shape
(`tools/chains.tcl`: a self-tail loop whose widened `[0, +∞]` entry the
narrowing recovers as `[0, 500]`, then a chain of N callees), both
`NarrowRounds` calls take N+2 rounds. At N=100, range analysis took 10.9 s
there.

`hir/rangerec.tcl` re-runs `Fixpoint` up to twice when it solves a closed
self-recursive instance. That multiplies the cost by a constant (at most 3),
and does not change its growth. Neither benchmark shape re-runs it: `chain`
has no self-recursive instance, and the solve of `narrow`'s `drive` is
rejected (its measure grows), so each analysis is one `Fixpoint` call.

### Why the rounds cannot simply be reordered

Ordering the worklist by call-graph SCCs (callers before callees for entry
facts, callees before callers for summaries) would cut the number of rounds
on a chain to a handful. But it changes the iteration: the facts each step
sees would differ from the Jacobi rounds'. The ascending phase is not a
plain monotone fixpoint. It widens self-derived entry facts. A non-self-
recursive parameter's entry is *replaced* by each round's fresh caller
contribution instead of joined. And a self-recursive one is poisoned once
its own feedback widens it to unknown. Its result therefore depends on the
order in which facts arrive. An SCC order would produce different (sound,
possibly better or worse) facts on some programs, which is a semantic
change. It is also unnecessary: the redundant work is not in the number of
rounds but in what each round redoes.

## 2. The change

Both steps keep the round structure and only skip work that would recompute
a value already present.

### Step 1: reuse a walk whose inputs did not change

An instance's walk (`SettleInstance` in the ascending phase, `AnalyzeInstance`
in `NarrowRounds`) is a pure function of its arguments. Within one `Fixpoint`
call, only three of them change between rounds:

* the instance's entry Ranges,
* its block's capture seed,
* the result summaries of its own exact-call targets. `Call` reads
  `calleeResults` only at a target in the walked instance's
  `instanceCalls`. `ResultsRead` extracts exactly that part.

Each loop keeps, per instance, the key `{entry captureSeed ResultsRead}` of
its last walk and the walk's answer, and reuses the answer when the key is
equal. Tcl values are their strings, so equal keys mean equal inputs.

This alone cut the number of walks to a small constant per instance (§ 3),
but every round still folded every instance's calls and creation sites and
re-ran every entry fold and summary update. That is O(instances + calls)
of cheap but not free work per round, so it stayed quadratic with a smaller
constant.

### Step 2: incremental rounds

Each round now redoes only the steps whose inputs changed:

* **Settles / walks.** Only the instances whose entry Ranges, capture seed
  or callee summaries changed in the previous round are re-settled
  (`settle` in `Fixpoint`, `walk` in `NarrowRounds`). They are still checked
  against the step 1 memo, so an instance whose inputs came back to those
  of its last walk is not walked again.
* **Contributions.** A target's contribution (the per-argument join of its
  callers' reached argument Ranges) is refolded only when one of its
  possible callers was re-walked (`readersOf`, the inverted `calleesOf`).
  It is refolded over those callers' current outcomes in ids order, then
  call order, which is the same order a full round's fold uses
  (`Contribution`). Likewise, a child block's capture facts are refolded
  only when one of its creators was re-walked (`CaptureFacts`,
  `NoteCreates`).
* **Folds.** An entry fold, capture fold or summary update runs again only
  when one of its inputs changed or its last run changed its value
  (`refold`, `renarrow`, `summarize`). A fold that ran on the same inputs and
  left its value unchanged would leave it unchanged again. This is the
  general argument, so it holds for every fold whether or not the fold is
  idempotent. The ascending phase's `widen` of an exact-set fact, for
  example, is not.

Everything skipped would have recomputed the value it already has. The
rounds are therefore exactly those of redoing everything every round: how
many there are, which round reaches `HIR RANGE LIMIT`, and every fact each
round leaves. That includes the key order of every dict a later stage
reads. New keys are inserted in first-appearance order, as before.

Total work is now proportional to the number of fact changes times the
fan-out of the changed facts, not to rounds × instances. On a call chain,
each instance's facts change a constant number of times.

## 3. Timings

Pending: measured on a quiet machine once the verification runs (§ 4) finish.

## 4. Verification

Pending: the full-suite and corpus comparison runs are in progress.

## 5. Other quadratic terms found

### `hir::specialize::view`

`view` returns the program HIR with one instance's overlay applied. The
first `dict set hir exprs ...` duplicates the program's whole `exprs`
dictionary (copy on write), so each call costs O(program) time and memory.
Thirteen passes of native lowering each build a view of every used instance.
On the 100-function chain that is 1,524 view constructions (about 15 per
instance), taking 1.06 s of a 2.77 s `native::lowered`:

| caller | calls | ms |
|---|---|---|
| `RegionInfo` | 204 | 204 |
| `Round` | 204 | 104 |
| `Regions` | 101 | 101 |
| `Arities` | 101 | 100 |
| `Fixpoint` (range) | 102 | 94 |
| `View` | 102 | 78 |
| `LeafInlineEligibleUncached` | 101 | 65 |
| `Function`, `WalkInstance`, `Bindings`, `CallSites`, `ConsumingParams`, `CharAccessorShape` | 101-102 each | 47-61 each |

Range analysis itself holds one view per instance for the whole `Fixpoint`
(and again for each `rangerec.tcl` re-run). That is now the largest
remaining quadratic term inside `hir::range::analyze`: about a third of its
time at N=200, plus the cost of freeing the copies. A per-specialization
view cache would remove the factor of 15 but not the O(program) copy per
instance. Making a view linear needs an overlay representation (a region's
exprs only) rather than a modified copy of the whole program. That touches
every view consumer, so it is not part of this change.

## 6. Deep static call chains

At N=200 (about 2,000 lines) the frontend failed with Tcl's `too many nested
evaluations`, inside `hir::check` → `hir::errorsets::verify` →
`hir::completions::checkBlock`.

**Cause.** `hir::completions` proves call-specific completions by
analyzing an exact callee's body under the call's argument facts. Every
exact call does this, whether or not the callee declares errors:
`EvalCall` → `EffectiveFacts` → `analyzeBlock` → `WalkBlock` → `Seq` →
`Eval` → … → `EvalCall` of the callee's own calls. That is about nine Tcl
frames per level of the static call chain. At Tcl's default recursion limit
of 1000 the threshold is about 110 levels. A 105-function chain compiles; a
120-function one does not. The pass's own bound, `maxAnalyses` (256
analyses per top-level `checkBlock` walk), limits how many analyses run,
not how deep they nest, so the eval limit is reached first.

**Should a deep legal chain be supported?** Yes. The program is legal, and
the pass is already designed to lose precision rather than fail when its
budget runs out (`maxAnalyses` falls back to the callee's declared
contract). Failing with an internal Tcl error at a depth that ordinary
generated or layered code can reach is a defect, not a limit of the
language.

**How.** There are two parts:

1. *Bound the nesting depth* in `EffectiveFacts` with the same
   conservative fallback the cycle and budget cases use
   (`list 1 $declared [hir::range::unknown]`). The `guard` dict already
   holds the chain of callees being analyzed, so its size is the depth.
   This turns the failure into precision loss beyond the bound, which is
   sound by the pass's own argument (the fallback never claims an error
   impossible).
2. *Bound or remove the frame cost per level.* The frames per level depend
   on each body's syntactic nesting, so a depth bound alone does not
   guarantee staying under 1000 evaluations. Either raise
   `interp recursionlimit` where the compiler is entered, or make the walk
   iterative (an explicit stack of pending callee analyses). Raising the
   limit is the cheap option: Tcl 9's non-recursive engine does not grow the
   C stack for proc recursion, 62 test files already raise it (most to
   100000 or 1000000), and the 400-function chain compiles with a limit of
   20000 (frontend 15.9 s). It is a process-wide setting, though, so a
   library entry point setting it is a design decision of its own.

Neither part is in this change. The depth bound changes completion
precision for chains deeper than the bound. A completion verdict feeds
code generation through a native call's bounds verdict
(`BoundsVerdictsOf`), so it can change NIR. That needs its own tests and
its own audit.
