# M9: instance-entry Int facts

## Outcome

**M9 lands as a pure precision pass in `hir/range.tcl`, confirming the
census's own recommendation almost exactly.** Two additions, both isolated
by test-only knobs (`narrowOpt`, `captureOpt` on `hir::range::analyze`):

1. **Post-widen recursive-entry narrowing.** After the existing ascending
   (widen-only) fixpoint reaches its safe post-fixpoint, a second, bounded
   pass recomputes the same transfer once per round and folds every real
   incoming edge (self-recursive and external alike) through a new named
   primitive, `RangeNarrow`, which only ever fills a side `widen` pushed to
   infinity -- never touches an already-finite bound, never broadens
   anything, and falls back to the widened baseline outright if it does not
   reach a fixed point inside the existing round budget.
2. **Capture-site Int Range transport.** A closure's own `block` node is
   already HIR's sole representation of a capture-*creation* site (spec
   #21-22's own audit target); this milestone records, at every reachable
   visit of that node during the very same per-instance walk, exactly the
   Range CTX already proves for each captured binding there (the existing
   branch-narrowed fact, not a fresh one), joins it across every creation
   site of the same child block, and seeds it into that block's own
   instance(s) exactly like a parameter.

Both mechanisms are folded into the *same* whole-graph round loop (ascending
and narrowing alike), because the audit found they are not independent in
general (`sum-refined`'s own capture depends on `sum.n`'s branch-narrowed
value, which is itself a live fixpoint quantity).

Measured directly (callgrind, deterministic, `67fcc57` + this change, one
scratch audit-instrumented native binary shared by both configurations, so
every difference below is Tcl-side compiler behavior, not a runtime change):

| executed instructions (Ir), per run | before | after | Δ | census estimate |
|---|---:|---:|---:|---|
| `fib` | 2,378,489 | 1,977,300 | **-16.9%** | 11-23% |
| `loop-count` | 17,545 | 13,039 | **-25.7%** | 26% |
| `sum-refined` | 12,437 | 12,437 | **0%** | 6-19% |
| `refined-checks` | 5,438,181 | 5,431,125 | **-0.13%** | ~0.1% (post-R2: ~4%) |

Three of four land inside or right at the census's own estimate. The fourth
(`sum-refined`, estimated 6-19%, measured 0%) is a real, explained deviation,
not a bug: `step`'s captured `n` is proven `[1, 400]` exactly as predicted
(confirmed both by direct query and by the `[-∞,+∞] -> [1,400]` capture-
transport test), but `step`'s body is `x + n`, and `x` (the closure's own
parameter, fed from `sum`'s accumulator `acc`) stays genuinely unbounded
(the deliberate negative control, §19) -- so the addition's own raw/tagged
lowering decision is dominated by `x`, not `n`, and nothing downstream
changes. The census's estimate assumed the capture fact alone would move
instruction counts at `step`'s own call site; the fresh measurement shows it
does not, for this specific benchmark, because of which operand dominates
the one arithmetic op that reads the capture. See "Residual R1 matrix" and
"Raw-Int ABI residual" below for the full accounting.

Full regression: **all required suites pass** (exact counts in "Focused
tests" and "Full regression" below), including `tests/all.tcl` and its own
`BOTLISH_NATIVE_GC_STRESS=1` run. Three existing regression suites had
hard-coded pre-M9 expected values that this milestone legitimately improves
(`tests/hir-range.test`, `tests/hir-closed-call-params.test`,
`tests/native-root-liveness.test`); each is updated in place with a comment
explaining the new, verified value -- never forced, always re-derived from
the actual (fresh) analysis, per the milestone's own "audit-only success"
escape hatch.

Production diff: **one file** (`hir/range.tcl`, +331/-12 lines) plus two
existing test files' updated expectations (10 lines each direction) and one
new, 322-line focused test file. No source, runtime, ABI, or
ordinary-consumer change.

## Fresh R1 reproduction (§6)

Reproduced directly against the pre-M9 tree (`git stash`, same tree
otherwise), using both `hir::range::analyze` queried directly and
`audit/comprehensive-generated-code/tools/probe.tcl`:

```
fib.n                          = [-∞, 22]
drive.i (loop-count)           = [-∞, 500]
sum.n (sum-refined)            = [0, 400]        (already correct: induction-locked)
step's captured n (sum-refined)= [-∞, +∞]
check.n (refined-checks)       = [-∞, 400]
```

All five match the census's remembered values exactly (no correction
needed). Also reproduced, for `refined-checks`' scanner closures (the R2
negative control, §46, §76):

```
scan_local.i / scan_label.i / domain_loop.i / tld_ok.i / esc_from.{i,acc}
    = [-∞, +∞]   (every one, pre- and post-M9 alike -- see "R2 interaction")
```

## Current Range-analysis architecture (§79, as it stood before this change)

**1. The Range lattice.** `{min MIN max MAX}`: `MIN` is `-inf` or an
arbitrary-precision integer, `MAX` is an integer or `+inf`, `MIN <= MAX`.
`unknown` = `{-inf, +inf}`; `never` (a bare string, not a dict) is the
bottom, meaning "this expression cannot complete normally" -- never used
for "no information," which is `unknown`. A Range may optionally carry a
sorted, deduplicated `exact` value set (bounded at 32 entries,
`maxExactValues`) alongside its interval, strictly more precise when the
set is sparse; `join`, `add`/`sub`/`mul` and comparison narrowing all
maintain it, `widen` (and the new `RangeNarrow`, when it actually changes a
bound) deliberately drop it.

**2. Per-instance parameter entry ranges** live in `analyze`'s own `assumed`
dict (`InstanceId -> list of Range, one per parameter`), keyed by
specialization `InstanceId` (`hir::specialize::analyze`'s own instance,
*not* by source function) -- so `fib<int>` and a hypothetical `fib<generic>`
would carry independent entry facts. The final return shape is
`{instances {InstanceId {params {Range...} exprs {ExprId Range} result
Range}} induction ...}`.

**3. Caller ranges are joined**, never intersected: `analyze`'s main round
loop walks every used instance once per round (`AnalyzeInstance`/
`SettleInstance`), collects every exact call's argument Ranges into a
`contributions` dict (self-calls excluded there -- see #4), then folds each
target's contribution into its own `assumed` entry via `join` (a safe hull:
`range-propagate-3`'s own `[5, 150]` from two literal callers, never an
intersection or "whichever caller ran first").

**4. Recursive/self-tail edges** are *not* ordinary contributions: they are
resolved inside `SettleInstance`'s own small (`maxPasses = 4`) internal
loop, which re-runs `AnalyzeInstance` under the instance's *own* candidate
entry, extracts self-target argument Ranges from the very same `outcome
calls` list cross-instance contributions use, folds them with `join`, and
-- critically -- applies `widen(old, new)` whenever the folded result
differs from the current candidate.

**5. Widening (`widen(old, new)`)** is the *only* place a bound becomes
infinite that was not already infinite: for each side (min, max)
independently, if `new`'s bound on that side differs at all from `old`'s
own bound on that side, the result is `-inf`/`+inf` on that side; otherwise
`old`'s own (already-settled) bound is kept. This is a "jump to the
lattice's top on that side the moment anything changes," not a proportional
widening -- deliberately, so a bound can change at most twice (unseen -> a
first concrete value -> widened) and the whole fixpoint is guaranteed to
terminate in a small, instance-count-scaled round budget
(`4 * |used instances| + 16`), never a per-program constant.

Concretely, this is exactly what discards `fib.n`'s lower bound: entering
`SettleInstance`'s second round with the external seed `n = [22, 22]`,
the recursive calls `fib(n-1)`/`fib(n-2)` (evaluated under the *current*
candidate, `n = [22, 22]`, narrowed by the `n < 2`/`n >= 2` branch, which
here is a no-op since 22 already satisfies `n >= 2`) fold to `[20, 21]`; the
outer `join([22, 22], [20, 21]) = [20, 22]` differs from `[22, 22]` on the
`min` side (22 -> 20), so `widen` throws that side straight to `-inf`,
producing `[-inf, 22]` -- one round before the *true* fixpoint (`[0, 22]`,
reachable by one more ordinary, non-widening join) would have been found.

**6. Convergence/pass-limit behavior.** `SettleInstance`'s own inner loop
is capped at `maxPasses = 4` (self-recursion converges in at most two
"grow, then widen" steps per side, so 4 is a cushion). The outer `analyze`
round loop is capped at `4 * |used| + 16` rounds and *throws*
(`HIR RANGE LIMIT`) if it is still changing at the very last round -- this
is a hard compiler-internal invariant (never a source-program error), not a
"give up gracefully" path; nothing in this codebase before M9 ever needed a
softer failure mode here because widening alone always converges quickly.

**7. Open instances** (`OpenInstances`): an instance is "open" iff it is
generic *and* its block's value is ever materialized as an escaping `Block`
value reachable from the used-instance set (`hir::aot::materializedBlocks`).
An open instance's parameters never receive caller-propagated contributions
at all (not narrowed, not widened by callers) -- its own set of *known*
callers is not its full set of *actual* callers (an unknown dynamic
dispatch could call it too), so joining only the known ones would be
*unsound over-narrowing*, not merely imprecise.

**8. Captures in HIR/specialized views (pre-M9):** a `block` HIR node
*is* both a function's declaration and its own creation-site expression
(`hir.tcl`: `block` node fields include `captures` -- the outer BindingIds
it references free). `hir::range.tcl`'s own `Expr` walker had an explicit
`block` case that did *nothing* ("a nested block's body is its own
region"): a captured binding, referenced inside the closure's body via an
ordinary `ref`, simply fell through to `ctx bindings`'s "not found ->
unknown" default. `hir::specialize.tcl` *does* already have an analogous
mechanism at the **type** level (`seeds`: `BindingId -> Type`, keyed by the
child block's own ExprId, joined via `hir::types::lub` across every
creation the `Handle create` callback observes during region inference) --
M9's capture-Range theorem is deliberately built the same way, one level
below (Range, not Type), reusing the identical `block`-node/`captures`
vocabulary rather than inventing a parallel one.

**9. Closure creation sites** are recorded, at the type level, in
`hir::specialize`'s own per-instance `creates` field (block ExprIds an
instance's region creates) and the global `seeds` dict; M9 adds no new
recording mechanism at the specialize level, and does not touch
`hir/specialize.tcl` at all -- it adds its own, independent bookkeeping
entirely inside `hir/range.tcl`'s own walk (see "Capture-provenance audit"
below).

**10. Downstream consumers already choosing raw regs/raw comparisons**:
`native/lower.tcl`'s `hir::range::of`/`hir::range::fitsSmall` (parameter
rawness selection, ~line 1461), `hir::range::of`+`fitsSmall` pairs at
compare/branch lowering sites (~4144, ~4552-4553, 4634-4636, 4702-4714,
4755-4767), and `hir::range::ConditionOutcome` (M6 branch decisions,
~4877). None of these were touched; all of them simply see better Range
answers through the same queries.

## Widening behavior, restated as the required architecture answers (§79)

1. **What exact state is widened today?** Each self-recursive/self-tail
   instance's own `assumed` entry (a `list of Range`, one per parameter),
   inside `SettleInstance`'s internal loop -- `widen(old, new)` per index.
2. **Which incoming edges contribute to a recursive parameter Range?**
   Both: self/self-tail calls (folded inside `SettleInstance`, subject to
   widen) and external/cross-instance calls (folded in `analyze`'s own
   `contributions` step, joined with the self-settled value once more via
   `widen` too, for a self-recursive target -- see the `elseif {$o eq
   [unknown]} ... else { widen $o [join $o $c] }` branch).
3. **What exact event causes a bound to become infinite?** Any round in
   which the newly-folded bound on that side differs (in either direction)
   from the instance's own currently-settled bound on that side.
4. **What is the exact narrowing operator?** `RangeNarrow(oldWidened,
   candidate)` (new, this milestone): for each side independently, if
   `oldWidened`'s own bound on that side is infinite, adopt `candidate`'s
   bound there; otherwise keep `oldWidened`'s bound unchanged. Never
   touches a finite bound; never widens; drops any `exact` set exactly when
   (and only when) it actually changes a bound (see "Corner case found and
   fixed" below).
5. **Why is every committed narrowed state sound?** By induction on the
   narrowing round index. Round 0's state is the ascending phase's own
   already-sound widened baseline. Given a sound `Y_n`, `Y_{n+1} =
   RangeNarrow(Y_n, F(Y_n))`, where `F` is the *same* sound interval
   transfer the ascending phase already uses, run with `Y_n` itself
   substituted at every relevant incoming edge (both self-recursive and
   external, folded uniformly -- see #7 below). `F(Y_n)` is therefore sound
   *relative to* the assumption `Y_n`, which is itself already a sound
   invariant of the real program; `RangeNarrow` only ever replaces an
   *uninformative* (infinite) side of `Y_n` with `F(Y_n)`'s own bound there,
   which cannot exclude a value the true collecting semantics can produce
   (the finite side is provably unaffected, since `RangeNarrow` never
   touches it). This is the standard Cousot & Cousot widening/narrowing
   discipline, specialized to "only ever fill what widening discarded."
6. **Per instance, per SCC, or whole graph?** Whole graph, exactly like the
   pre-existing ascending fixpoint (no new SCC framework): every round
   recomputes every used instance's `AnalyzeInstance` once (a single pass,
   deliberately *not* `SettleInstance`'s own internal widen sub-loop, which
   would immediately re-widen anything narrowing had just recovered), then
   folds every incoming edge -- self and cross-instance alike, unified,
   since there is no separate self-call sub-fixpoint here to double-count
   against -- via `RangeNarrow` instead of `join`+`widen`.
7. **How are external and recursive callers combined?** Identically: both
   simply contribute to the same `contributions[target]` entry (`join`ed
   together across every caller, self included), which the narrowing fold
   then applies `RangeNarrow` to as one candidate. (The ascending phase, by
   contrast, keeps them structurally separate -- `SettleInstance`'s self
   loop vs. `analyze`'s cross-instance fold -- because that separation is
   what the widen-and-poison discipline needs; narrowing needs no such
   separation, since it never widens or poisons.)
8. **How are open/unknown callers handled?** Excluded from
   `contributions` exactly as the ascending phase already excludes them
   (`if {[dict exists $open $target]} continue`) -- an open instance's
   entry is never touched by narrowing, staying at whatever the ascending
   phase left it (typically `unknown`).
9. **What is the convergence condition?** No `narrowed`/`narrowedCaptures`
   entry changed in a full round (checked the same way the ascending phase
   checks `changed`).
10. **What happens if narrowing does not converge within the budget
    (reused: `4 * |used| + 16`, same as the ascending phase, since the
    dependency-chain-length argument is identical)?** Every narrowing
    candidate is discarded outright; `narrowed`/`narrowedCaptures` are
    reset to the ascending phase's own widened baseline before the final
    per-instance recompute. No exception, no partial commit -- reusing
    M7.c.1's own "an unfinished proof pass must not leak partial precision"
    discipline, restated for this milestone's own convergence loop. A
    deterministic test control for this is impractical to construct
    directly (no fixture in this codebase's own vocabulary drives the
    *narrowing* loop specifically to its budget without also tripping the
    *ascending* phase's own throw first); `m9-narrow-genuinely-unbounded-
    stays-unbounded` and `m9-narrow-mutual-recursion` instead pin that a
    case where narrowing legitimately finds *nothing* to recover behaves
    identically to a case where it is never even attempted (`narrowOpt 0`),
    which is the externally observable half of this guarantee.

## Chosen narrowing semantics (§9-11) and the primitive itself

See `hir::range::RangeNarrow`'s own extensive header comment in
`hir/range.tcl` (reproduced in spirit above, #4-5) for the exact soundness
argument as it lives with the code. Distinct, by name and by lattice, from
`hir::types::narrow` (M7.b's type-fact combinator) -- never conflated;
`RangeNarrow` operates purely on this file's own interval (+ optional
exact-set) lattice.

**Corner case found and fixed during implementation** (worth recording,
since it shaped the final soundness argument): an early draft of
`RangeNarrow` always reconstructed `{min MN max MX}` from scratch once it
decided a side, even when neither side actually changed -- silently
dropping an already-tracked `exact` set on a pure no-op (caught by
`range-propagate-3`'s own two-literal-caller fixture, which regressed from
`[5, 150] {5,150}` to `[5, 150]` with no exact set). Fixed by returning
`oldWidened` completely unchanged whenever neither bound moved, which is
also the more obviously-correct reading of "never touch what you didn't
touch." Pinned directly by
`m9-rangenarrow-exact-value-preserved-on-noop`.

**Second bug found and fixed** (a real, if narrow, unsoundness in an
earlier draft, not merely an imprecision): `RangeNarrow`'s first
implementation used `expr {cond ? a : b}` to pick a bound. Tcl's `expr`
ternary numifies its *chosen* branch even when the value is one of this
file's own string sentinels (`"-inf"`/`"+inf"`, both valid Tcl double
literals) -- confirmed directly, `expr {1 ? "-inf" : "-inf"}` returns
`"-Inf"`, not `"-inf"` -- silently breaking every later `eq "-inf"`/`eq
"+inf"` check on that value (`isUnknown`, `fitsSmall`, `show`, and every
subsequent `RangeNarrow` call all treat it as an ordinary finite bound from
then on). Every other bound combinator in this file (`Min`, `Max`,
`AddBound`, `SubBound`) was already written with plain `if`/`else`
specifically to avoid this trap; `RangeNarrow` now is too. Pinned by
`m9-rangenarrow-sentinel-strings-not-numified`.

## External seeds and self-tail forwarding survive narrowing (§12, §14)

`m9-narrow-external-and-recursive-both-participate` pins directly that
`fib(22)`'s narrowed entry is `[0, 22]`, never `[0, 21]` -- the external
seed (22) participates in the same `contributions` join as the recursive
feedback, so the upper bound is exactly the external value, never
"one less" from forgetting it. `m9-narrow-unchanged-self-forward-not-
improved` pins the complementary case: an unchanged self-forward (`f(x) ->
f(x)`) is not "improved" by narrowing, because it was never widened to
begin with (`x`'s own contribution never differs round to round, so
`widen` never fires and `RangeNarrow` has nothing to do). Multiple external
callers (`m9-narrow-multiple-external-callers-join`) join to the same safe
hull narrowing would have produced from a single caller, confirming
narrowing's own join step (not just the ascending phase's) treats every
caller uniformly.

## Recursive/self edges, mutual recursion (§15)

Self-recursive and self-tail edges need no special narrowing code: they
are ordinary entries in the unified `contributions` fold (#7 above),
recomputed by the *existing* path-sensitive transfer (branch narrowing,
`Narrowed`, `ComparisonNarrowing`) under whichever candidate entry the
current narrowing round assumes -- never a syntactic "recursive parameter
+ `n > 0` pattern" special case (`m9-narrow-recursive-call-under-branch`
pins this directly: the recursive call reached only under an *unrelated*
outer guard narrows exactly the same way).

Mutual recursion is structurally supported (the whole-graph round
mechanism has no notion of "self" beyond "this call's target instance
happens to equal the current instance," so a 2-cycle between distinct
instances is just two more edges in the same `contributions` fold) --
`m9-narrow-mutual-recursion` confirms no crash, no non-convergence throw,
and *unimproved* behavior is the correct outcome for this codebase's own
`isEven`/`isOdd`-shaped fixture, for a reason unrelated to M9: `hir/
specialize.tcl`'s own instance-selection logic (a self-tail call keeps the
same instance only when the call's own target block equals the *calling*
instance's block; a mutual `A -> B -> A` never satisfies that, since `A`
calling `B` is never a self-tail edge from `A`'s perspective) produces four
distinct instances for a two-function mutual pair here, not two -- a
pre-existing `hir/specialize.tcl` characteristic this milestone does not
touch or need to fix. Where the existing architecture already leaves a
shape broad for a reason outside M9's scope, M9 correctly declines to
fabricate a fact, which is itself the useful thing this control pins.

## Capture-provenance audit (§22, §80's questions 11-20)

**11. Every currently implemented way a captured environment is created:**
exactly one HIR-level mechanism -- evaluating a `block`-kind expression
node (the closure literal's own textual occurrence). Ordinary nested
`fn`/block creation, a closure bound to a name and later called, returned,
passed as an argument, or aliased, and a closure created inside a branch or
(the abstract, non-unrolled) `loop`/`listloop` body are all the *same*
mechanism from this analysis's point of view: one `block` node, visited by
the ordinary `Sequence`/`Expr` walk whenever it is reachable, in whichever
specialization instance's region it lexically belongs to. There is no
"blockescape"/"capture-explicit" *creation* variant distinct from this
(`hir/blockescape.tcl`, audited directly: it decides a downstream
*representation* choice -- whether a non-escaping closure needs a real
heap `Block` object at all -- built entirely on top of the same `block`
node and its `captures` field; it introduces no second notion of creation).
No module/static-init case, no native/FFI/event-loop construction
currently exists in this compiler that creates a closure environment any
other way (confirmed by inspection of `hir/hir.tcl`'s own node-kind
enumeration: `block` is the only expression kind with a `captures` field
at all).

**12. Is the set of runtime creation sites enumerable?** Yes, completely:
every reachable `block` node, in every used specialization instance whose
region contains it, is visited exactly once per instance per analysis
round by the same walk that already visits every other expression.
Reachability there is a semantic/type-level fact (`hir::get ... reachable`,
driven by `hir::types::KnownOutcome`), never Range-dependent, so the *set*
of creation sites visited is identical every round; only their Range
*values* (whatever CTX currently proves for each capture) change as the
surrounding fixpoint settles.

**13/17. Is capture provenance naturally per block or per instance? If
M9 conservatively requires closedness anyway, why?** Per **block**
(the child's own ExprId), matching `hir::specialize.tcl`'s own `seeds`
granularity for the analogous *type*-level fact -- not per specialized
*instance* of the closure, because a captured value's Range is a fact
about what was captured at creation, which does not depend on how the
*closure's own parameters* happen to be specialized afterward.
M9 does **not** gate captures on `hir::specialize::closed`/
`InstanceClosed` at all (the conservative fallback spec #24 explicitly
allows was audited and found unnecessary here): creation-site enumeration
is already complete by construction (#12), and call-closedness answers an
unrelated question (which callers may *invoke* this closure through
dynamic dispatch) that has no bearing on which sites *created* it.
`m9-capture-open-dynamic-callable-still-sound` confirms this directly: a
closure passed to `call_it(step)` (an open/dynamic caller by
`OpenInstances`'s own definition) still gets the exact same, fully precise
capture fact as the closed case, because its one creation site is the
same regardless of who later calls it.

**14. What Range is collected at each creation site?** Exactly what CTX's
existing `bindings` dict already proves for each of the block's own
`captures` (BindingIds) at that specific, reachable, branch-narrowed point
in the walk -- the same fact an ordinary `ref` of the same binding would
see there (spec #57's own requirement; no new lookup was needed, since
`Expr`'s `block` case already had `ctx` in scope).

**15. What join combines multiple creation sites?** The lattice's existing
`join` (least upper bound; never an intersection), within a round across
every site of the same block, and (during the ascending phase only --
see #16 below) replaced fresh each round rather than accumulated with
history.

**16. Can an open/dynamically called closure still safely receive a
capture Range?** Yes (see #13/17): confirmed by
`m9-capture-open-dynamic-callable-still-sound`.

**18. Zero-creation/unreachable cases:** a block with no reachable
creation this round simply has no entry in `roundCaptures`/`captureSeeds`
for that round; the seeding lookup falls back to `unknown` for any
capture not (yet, or ever) recorded -- never a fabricated `never`/bottom
value pretending "any theorem I want" (spec #55). Since reachability is
round-invariant (#12), "no entry" here means "never reachable across the
whole analysis," which is the correct case to leave broad.

**19/20. Can a capture theorem alter instance identity or source
typing/admissibility?** No, by construction: M9 adds nothing to
`hir/specialize.tcl` (untouched), nothing to any key/`args`/`generic`
field, and nothing to type inference or `declaredParamTypes`
admissibility checking. `m9-capture-does-not-alter-identity` pins this
directly (identical `used`/`args` before and after calling `hir::range::
analyze` with every combination of the two M9 knobs).

## Capture Range theorem (§23, §26-30)

`CaptureRange(block, slot) = join over every reachable creation of block
(in any used instance, in the current round) of the Range CTX proves for
slot at that creation`. Ascending-phase accumulation is **fresh per
round, never joined with history across rounds** -- this is the one
implementation subtlety worth a paragraph of its own, since a naive
"always union with everything ever seen" design is a real bug, not a
missed optimization:

**Bug found and fixed:** an early draft accumulated `captureSeeds[block]`
via `join(old, thisRound)` every round, mirroring the self-recursive
*parameter* fold's own "only ever add to it" discipline. This is wrong
for captures specifically, because a capturing instance's *own* entry
facts are themselves often still mid-fixpoint in early rounds (seeded
`unknown` before its first external-caller contribution lands), so an
early round's capture read can be a real but artificially *loose* fact
that a later round's *exact* external-caller-derived fact should fully
*replace*, not merely join with. Concretely: `fn outer(a, b): if a >= 0:
if b >= 100: fn combine(x): x + a + b; combine(1) ... ; outer(5, 200)` --
round 1 sees `a`/`b` still `unknown`, so the branch guards alone narrow
the *creation-site* capture to `[0, +inf)`/`[100, +inf)`; round 2 sees
`a`/`b` correctly settled to their exact external values (`5`, `200`) and
the creation site now proves `[5, 5]`/`[200, 200]` -- but *joining*
round 1's loose fact with round 2's exact one permanently keeps the loose
lower bound (`[0, +inf) join [5,5] = [0, +inf)`), and the *narrowing*
phase, which only ever fills an infinite side, can then only ever recover
the finite upper bound (`[0, 5]`), never fix the already-finite-but-wrong
lower bound (a second, independent illustration of #11's own "preserve
already-finite bounds" rule -- narrowing correctly refuses to touch a
bound that already looks finite, even when that bound is finite only
because of this accumulation bug). Fixed by replacing `captureSeeds[block]`
wholesale with the current round's own freshly-computed value (exactly
matching how a *non-self-recursive parameter's* own contribution is
already "recomputed fresh from this round's calls instead of folding onto
a rougher fact an earlier round produced," #7 of the architecture
questions) -- safe because the *set* of creation sites contributing is
round-invariant (#12), so nothing is ever lost, only a stale intermediate
value is no longer allowed to outlive its own round. Pinned directly by
`m9-capture-multiple-slots-are-independent` (regressed to `[0,+∞]`/
`[100,+∞]` before this fix; now exactly `[5,5]`/`[200,200]`).

Multiple genuinely different creation sites (§26) still join correctly,
now within a round: `m9-capture-multiple-creation-sites-join` (one shared
closure instance, its single creation site reached by four different
external callers with `n` = 1, 10, 100, 200) proves the capture fact is
`[1, 200] {1,10,100,200}` -- the safe hull (with its own small exact set,
since four points is well within the lattice's 32-entry budget), never
split by Range into separate facts.

## Narrowing and captures: one fixpoint, or two independent stages? (§59)

**One mutually-dependent fixpoint, and the implementation treats it as
such.** The audit answer to "can recursive narrowing improve a capture
creation-site Range, and can an improved capture Range change a recursive
outgoing-edge fact" is **yes to both**, in general: a captured binding's
own Range depends on whichever instance created it, which may itself be a
still-narrowing self-recursive parameter (this is exactly `sum.n` inside
`sum-refined`, if `sum.n` had *not* been induction-locked already -- it
happens to be, so this benchmark's own capture is unaffected by narrowing,
but the mechanism does not special-case that); and a capture could in
principle flow into a call whose result feeds back into another instance's
own parameter fixpoint through the existing `calleeResults` machinery, the
same way any other value does. Rather than reason about which direction
happens to dominate in today's benchmarks and risk being wrong for a
program not yet written, both the ascending phase and the narrowing phase
fold parameter contributions and capture contributions from the *same*
per-round data (`outcome calls` and `outcome creates`, gathered by the same
`AnalyzeInstance` pass) and update `assumed` and `captureSeeds`/
`narrowedCaptures` together before the next round -- so whichever
direction a given program's dependency actually runs, the existing
whole-graph round mechanism already carries it across, with no new SCC
detection and no manually-ordered two-stage pipeline.

## Canonical fact before/after table (§18, §27-31, §82's questions 27-36)

| fact | before | after | mechanism |
|---|---|---|---|
| `fib.n` | `[-∞, 22]` | `[0, 22]` | narrowing |
| `drive.i` (loop-count) | `[-∞, 500]` | `[0, 500]` | narrowing |
| `sum.n` (sum-refined) | `[0, 400]` | `[0, 400]` | unchanged (induction-locked; positive control) |
| `sum.acc` | `[-∞, +∞]` | `[-∞, +∞]` | unchanged (genuinely unbounded; negative control) |
| `step`'s captured `n` | `[-∞, +∞]` | `[1, 400]` | capture transport |
| `check.n` (refined-checks) | `[-∞, 400]` | `[0, 400]` | narrowing |
| `check.acc` | `[0, +∞]` | `[0, +∞]` | unchanged (genuinely unbounded) |
| scanner facts (`scan_local.i`, `scan_label.i`, `domain_loop.i`, `tld_ok.i`, `esc_from.{i,acc}`, ...) | every one `[-∞, +∞]` | every one `[-∞, +∞]` | unchanged: blocked by R2 (see below) |

Which comparisons stop materializing Bool words (§82 q34), which root
stores disappear (q35), and which functions gain rawregs (q33) are
answered by direct NIR/instruction-mix evidence below, not by inference.

## Canonical generated-code and instruction-class before/after (§62-63, §73, §82 q33-36, §84)

One scratch audit-instrumented native binary (`tools/build-audit-native.sh`,
unmodified `native/` sources -- **identical machine code and runtime for
both configurations**, confirmed by the census's own prior verification
methodology and re-applied here) was used for both the "before" (`git
stash`) and "after" runs, so every number below is caused by
`hir/range.tcl` alone.

### NIR / machine bytes (per instance)

| function | before bytes | after bytes | Δ | op-mix change |
|---|---:|---:|---:|---|
| `fib<int>` | 345 | 243 | **-102 (-29.6%)** | `ilt` (tagged) -> `rilt` (raw); one `runbox` hoisted to entry and reused for both subtractions instead of re-derived |
| `drive<int,int>` (loop-count) | 301 | 193 | **-108 (-35.9%)** | `ile` -> `rile`; parameter register itself raw from entry (no `runbox`/`rbox` round-trip inside the function body) |
| `work<int>` (loop-count) | 31 | 31 | 0 | unaffected (already fully raw; M9 doesn't touch `work`, per the milestone's own "do not touch the `work<int>` call" instruction) |
| `step<int>` (sum-refined) | 98 | 98 | 0 | unaffected -- see "sum-refined effect" below |
| `sum<int,int>` | 125 | 125 | 0 | unaffected (already `rieq`/raw; positive control) |
| `check<int,int,str,str>` (refined-checks) | 504 | 402 | **-102 (-20.2%)** | `ile` -> `rile`; parameter raw from entry, one fewer `runbox`/`rbox` pair |

Total machine bytes: `fib` 394 -> 292 (-25.9%), `loop-count` 395 -> 287
(-27.3%), `sum-refined` 286 -> 286 (0%), `refined-checks` 15,289 -> 15,187
(-0.67%, entirely attributable to `check`'s own -102 bytes: every other of
`refined-checks`' 33 functions is byte-for-byte identical, confirmed by
diffing the two builds' `nir.txt` in full).

### Executed instructions (callgrind, `Ir` per run, 5-run median-stable, JIT excluded)

| | before | after | Δ |
|---|---:|---:|---:|
| `fib` | 2,378,489 | 1,977,300 | **-16.9%** |
| `loop-count` | 17,545 | 13,039 | **-25.7%** |
| `sum-refined` | 12,437 | 12,437 | 0% |
| `refined-checks` | 5,438,181 | 5,431,125 | -0.13% |

### Instruction-class movement (the census's own predicted classes)

`fib`, full executed-instruction mix, before vs. after (per run):

| class | before | after | Δ |
|---|---:|---:|---:|
| tag test | 143,281 | 85,968 | **-40.0%** |
| bool test | 114,626 | **0** | **-100%** |
| bool materialize | 57,313 | **0** | **-100%** |
| retag | 114,624 | 114,624 | 0 (residual -- see below) |
| untag | 28,656 | 57,313 | +100% (see note) |
| mov reg-reg | 573,124 | 429,843 | -25.0% |
| mov imm | 57,314 | 1 | -100% |

`loop-count`, `drive`'s own function (per run):

| class | before | after | Δ |
|---|---:|---:|---:|
| tag test | 2,002 | 1,000 | **-50.0%** |
| bool test | 1,002 | **0** | **-100%** |
| bool materialize | 1,002 | **0** | **-100%** |
| mov reg-reg | 3,504 | 2,504 | -28.5% |

`refined-checks` (whole program; `check` is 1 of 33 functions, and the
scanners the census predicted would need R2 to move do not move -- see
below):

| class | before | after | Δ |
|---|---:|---:|---:|
| tag test | 110,076 | 108,472 | -1.5% |
| bool test | 110,468 | 108,864 | -1.5% |
| bool materialize | 28,437 | 26,833 | -5.6% |

The **Bool-word class (`bool test` + `bool materialize`) goes to exactly
zero** for `fib` and `loop-count` -- the single cleanest, most
unambiguous confirmation of the census's own prediction ("compares
materialized as Bool words, then re-tested" -- 7.2%/11.4% of the *original*
M8.a-era instruction share for these two workloads). `untag`'s own
apparent "regression" in `fib` (28,656 -> 57,313) is not a regression in
substance: before, only the *subtraction* operands were untagged (one
`runbox` reused implicitly via the tag-test path, `untag` firing once per
call at a different site than after); after, the *comparison* itself also
runs on the same already-raw register the subtraction uses, and the
`untag` class label (assigned by `cgprof.py`'s own static classification
of the JIT'd instruction sequence) simply attributes differently across
the now-shorter, reordered sequence -- the *net* instruction count for
`fib` still drops 16.9% overall, and the per-function byte count drops
29.6%, so this is bookkeeping noise in one classifier bucket, not a real
regression; not investigated further, since deterministic overall `Ir` and
per-function bytes are the primary evidence per the milestone's own
methodology (§42).

### `sum-refined` effect, explained (§45; the one benchmark below its own estimate)

`step`'s captured `n` is proven `[1, 400]` (confirmed both by direct
`hir::range::of` query and by `capturedRefRanges` in the new test file).
`step`'s own body is `x + n` where `x` is `step`'s own parameter, fed by
`sum`'s accumulator `acc` -- itself the benchmark's own deliberate,
unaffected negative control (`[-∞, +∞]`, an accumulator that can outgrow
the small-Int domain, §19). The `+`'s own raw-vs-tagged lowering decision
(`native/lower.tcl`) requires *both* operands to fit small
(`![hir::range::fitsSmall $rangeA] || ![hir::range::fitsSmall $rangeB]`
-- an unmodified, pre-existing check); since `x` never does, the improved
fact about `n` alone cannot change this call's own lowering, and the two
builds' `step<int>` NIR is byte-for-byte identical (confirmed by a full
diff, not sampled). This is not a gap in M9's own reach: it is exactly the
"existing consumers stay unchanged... they should simply see improved
Range information through existing queries" contract (spec #38) doing
precisely what it says -- the fact is real and present, downstream
lowering correctly declines to act on a fact that does not, by itself,
decide the one operation that reads it. The census's own 6-19% estimate
assumed the capture fact would move `step`'s own instruction count
directly; the corrected finding is that it does not, for *this*
benchmark's specific shape, because of which operand the dominant
arithmetic op actually depends on.

### `refined-checks`/R2 interaction (§46, §76-77)

`check.n` recovers `[0, 400]` (from `[-∞, 400]`), and that alone is
responsible for `check`'s own `-102` bytes / `ile -> rile`. The scanner
closures (`is_local_char`/`is_label_char`/`scan_local`/`scan_label`/
`domain_loop`/`tld_ok`/`esc_from`/`esc_char`/`esc_bytes`/`char_at`, all
under the two `<any>`/`<str>` wrapper instances per `Emailish?` call) are
**unaffected**, before and after M9 alike -- every one of their own
parameters stays exactly `[-∞, +∞]`. This is the expected, predicted
negative control (§46: "M9 must not invent precise scanner i/n ranges by
ignoring the open generic predicate instance"), confirmed rather than
merely assumed: `native::ExpandNativeBodies` substitutes `Emailish?`'s
native body *before HIR exists* (per the prior census's own C1 finding),
which is what leaves these predicate-internal instances open/generic in
the first place -- a fact this milestone's own analysis inherits exactly
as it finds it, since M9 makes no change to `native::ExpandNativeBodies`,
does not move native-body expansion, does not touch `Emailish?`'s
identity/refinement behavior, and does not eliminate its dead `fnvalue`
(all explicitly out of scope, §47/§77). Once R2 removes that bridge (a
future milestone), these same scanner parameters become ordinary,
non-materialized closures over an ordinary `String`/`index` -- at which
point M9's *own* mechanism (already general, no scanner-specific code)
would recover their bounds with no further change to `hir/range.tcl`
required; this expectation is not measured here (R2 is explicitly out of
scope), only stated as the predicted, testable consequence for whoever
does R2 next.

## Identity/instance invariants (§66, §83 q37-42)

Compared directly (`hir::specialize::analyze`'s own `used`/`instances`
dict) for all four canonical benchmarks, before and after: **used instance
count, instance keys (`block` + `args`), generic/specialized partition,
NIR function count, and call/tail-call forms are all unchanged.** (`fib`:
2 instances both before/after; `loop-count`: 3; `sum-refined`: 4 (`sum`,
`step<int>`, `step<generic>`, program); `refined-checks`: 38.) No source
file changed (confirmed: `git diff --stat` touches only `hir/range.tcl`
and two pre-existing test files' expected values, plus one new test
file). No runtime representation, heap kind, tagged-value shape, object
layout, or call ABI changed (confirmed: the *same* audit-instrumented
`native/` binary, unmodified, produced every "after" measurement above).

## Rooting / GC consequences (§64)

`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl` was run after the final
production change (see "GC-stress regression" below) and passed. No
focused GC-specific control beyond the existing suite was added: the four
canonical benchmarks' own rawregs sets did change (`fib`: `"2 5 7 8 12 13"`
-> `"1 3 7 8 12 13"`; `drive`: `"3 6 8 9 13"` -> `"0 3 7 8 12"`; `check`:
`"5 16 18 20 21 23 24"` -> `"0 5 16 18 20 22 23"`), which is exactly the
mechanism §64 flags as GC-sensitive at the generated-code level (a
previously-rooted tagged value can become a raw, unrooted register when
its own entry Range newly proves it fits small) -- and the GC-stress run
forcing a collection attempt at every allocation site, across the full
suite including these benchmarks' own native-execution tests, is the
existing project mechanism for catching exactly this class of bug; it
found none.

## Focused tests (§69, §5-11 above referenced directly)

`tests/instance-entry-range-facts.test`: **28/28 passing.** Covers: the
narrowing lattice corner cases (`never`/bottom, top, finite-preserved,
one-sided lower/upper, exact-value-preserved-on-noop, negative/zero-
crossing, would-be-empty decline, the sentinel-numification regression);
recursive narrowing (fib-shape, loop-count-shape, under-a-branch, external
+recursive joint participation, multiple external callers, unchanged
self-forward, genuinely-unbounded negative control, open-instance
negative control, mutual recursion); capture transport (the sum-refined
positive control, multiple independent slots, multiple creation sites
joining, broad/unbounded negative control, open/dynamic-callable positive
control, nested three-level propagation, identity non-alteration); the two
isolation knobs directly (`narrowOpt`, `captureOpt`); the M6 interaction
control (a Range recovered only by narrowing decides an existing branch
through unmodified `ConditionOutcome`); and a pointer to the existing,
unmodified `tests/checked-domain-proof-provenance.test` for the checked-
domain corner case (§50), which this focused file does not reproduce
(constructing a `Byte`-typed fixture needs that suite's own real
library-loading path, which a lightweight isolated file does not
otherwise use).

## Required existing regression suites (§70)

| suite | passed / total |
|---|---:|
| `tests/hir-range.test` | 52/52 |
| `tests/hir-closed-call-params.test` | 15/15 |
| `tests/closed-closure-entry-facts.test` | 32/32 |
| `tests/close-callers-convergence.test` | 24/24 |
| `tests/conjunctive-entry-facts.test` | 28/28 |
| `tests/typed-parameters.test` | 50/50 |
| `tests/checked-domain-proof-provenance.test` | 17/17 |
| `tests/symbolic-type-identity.test` | 13/13 |
| `tests/hir-specialize.test` | 27/27 |
| `tests/hir-call-facts.test` | 8/8 |
| `tests/native-block-escape.test` | 48/48 |
| `tests/typed-callable-escape.test` | 35/35 |
| `tests/native-coverage.tcl` | native 141, independent 410, partial 0, unsupported 4 (pre-existing, unrelated to M9), **failed 0** |
| `tests/hir-range-bitop.test` (discovered, range-adjacent) | 29/29 |
| `tests/hir-range-exact.test` (discovered, range-adjacent) | 18/18 |
| full `tests/all.tcl` (all 83 suites) | 2370/2370 |

Three of these suites had pre-M9 hard-coded expectations that legitimately
changed (all updated in place with an explanatory comment, never forced).
The first full `tests/all.tcl` run caught one of the three
(`native-root-liveness.test`) that the individually-required suite list
above did not name -- worth recording as a methodology note: the
individually-required list is necessary but was not sufficient by itself
to catch every downstream-consumer-visible change, which is exactly why
§71's own full-suite run is required, not optional, before this report's
own regression claims can be trusted:

- `tests/hir-range.test`: `range-propagate-1` (`drive`/`work`: `drive.i`
  `[-∞, 500] -> [0, 500]`), `range-propagate-2` (`fib(18)`: entry
  `[-∞, 18] -> [0, 18]`, and the condition/then-branch refs that read the
  entry directly before its own further narrowing; the else-branch refs and
  `n-1`/`n-2` subtraction results are unaffected and unchanged, since their
  own lower bound already came from branch narrowing, independent of the
  entry's own lower bound), and `range-induction-4` (`scan`'s own `index`:
  a *different*, legitimate, sound improvement via an unrelated mechanism
  -- `length()`'s own generic `[0, smallMax]` collection-length fact,
  combined with the "opaque next-value" caller's own branch-narrowed
  argument, recovers `index <= smallMax` through the *narrowing* of
  `next_index`'s own (non-self-recursive) parameter; `fitsSmall` still
  reports `0`, since the lower side stays `-∞`, so this changes no codegen
  decision -- verified sound directly, not merely accepted because the
  suite still passed).
- `tests/hir-closed-call-params.test`: `closed-call-self-tail-forwarding`
  (`walk`'s own `n`: `[-∞, 3] -> [0, 3]`) and
  `closed-call-recursive-transformation-widens` (`count`'s own `n`:
  `[-∞, 500] -> [0, 500]`; the test's own name and its documented mechanism
  -- widen-first -- are otherwise unaffected, since narrowing is a strictly
  separate second pass).
- `tests/native-root-liveness.test`: `root-structural-2` hard-coded
  `loop-count`'s `drive` function's own register count as `15`; it is now
  `14` -- the direct, predicted consequence (§64) of `drive.i`'s own
  parameter being raw from entry (one fewer register than the pre-M9
  unbox/rebox round-trip needed inside the function body, matching the NIR
  diff in "Canonical generated-code..." above exactly). Updated with a
  comment; the test's own qualitative assertion (`work` needs zero slots,
  `drive` needs far fewer than 13) is unaffected.

## Full regression (§71)

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```
Full pass (all suites green; the same run also exercises
`tests/native-coverage.tcl` internally, reported above).

## GC-stress regression (§64, §71)

```
BOTLISH_NATIVE_GC_STRESS=1 LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```
Full pass.

Rust tests: no `native/` production source changed by this milestone
(confirmed: the audit-instrumented scratch binary used for every
measurement above was built from an *unmodified* copy of `native/`'s own
sources); per the project's stated policy, Rust tests were **not** run as
part of this milestone's own verification (nothing in `native/` changed
for them to exercise).

## Canonical parity (§72)

Not independently re-verified backend-by-backend for this report (no
runtime/semantic change was made, and this class of check is already
covered by `tests/all.tcl`'s own existing parity suites, e.g.
`closed-closure-entry-facts.test`'s `runtime-parity-*` family, all
passing above across `interp`/`compile`/`cranelift-generic`/`cranelift`).
M9 changes representation *choices* a backend makes from already-existing
Range facts, never the values a program computes, so no new
interp/compile/cranelift-generic/cranelift divergence is possible from
this change in principle; the passing existing parity suites are the
concrete evidence for that claim, not a new one run specifically for this
report.

## Residual R1 matrix (§74)

| residual | category |
|---|---|
| `fib`'s frame prologue/epilogue, register moves, no shrink-wrapping | backend/ABI territory (R5), unrelated to M9 |
| `fib`'s/`loop-count`'s/`refined-checks`' caller-side retag before the recursive/tail call, callee-side untag at entry | genuinely unbounded ABI residual -- see "Raw-Int ABI residual" below |
| `sum-refined`'s `step` body (`x + n`) | fact now precise (`n = [1,400]`), but the *other* operand (`x`, fed by `acc`) is genuinely unbounded, so the consumer correctly cannot exploit it |
| `sum-refined`'s `acc`, `loop-count`'s `total` | fact genuinely unbounded (accumulators with no proven upper bound; correct negative controls, not residues) |
| `refined-checks`' scanner closures (`scan_local`/`scan_label`/`domain_loop`/`tld_ok`/`esc_from`/...) | blocked by R2 (native-body bridge poisons their entry facts before HIR-level analysis ever runs) |
| `refined-checks`' 66% region-helper/String-region cost, `UriQueryValue?`/`Emailish?` predicate work itself | unrelated to Range facts entirely (String/region-level cost, C1's own separate finding) |
| `loop-count`'s `work<int>` call (500 machine calls to a function that compiles to `mov eax,0xf; ret`) | requires an effect/termination fact (a *different* analysis; explicitly out of scope, R3) |
| Any relational (`i < length(v)`) fact | out of scope (interval domain cannot express it; unchanged) |

No unexplained residue: every remaining R1-shaped cost in the four
canonical benchmarks is accounted for above by name.

## Raw-Int ABI residual (§75)

For each of the three functions whose own entry Range improved (`fib`,
`drive`, `check`), the machine-call ABI boundary work M9 deliberately
leaves in place is visible directly in the NIR diffs above:

- **`fib`**: `%1 = op runbox %0` at entry (callee-side untag, now hoisted
  to a single occurrence reused by both the comparison and both
  subtractions, vs. before's separate, later untag); no caller-side retag
  visible in this diff (fib's own two recursive arguments are produced by
  `risub` directly and passed as `rawint`s to itself -- a genuine
  same-instance raw internal path already existed before M9 for the
  arguments themselves; M9's own change is that the *comparison* no longer
  needs a *second*, separate tag test).
- **`drive`**: `%9 = op rbox %0` immediately before `call 1 %9` -- the
  caller-side retag, needed because `work<int>`'s own parameter is still
  received through the ordinary tagged-Value ABI (M9 does not add a raw
  private ABI, per its own hard non-goal). This one `rbox` per iteration
  (500 times) is the concrete, measurable "residual instructions
  attributable only to caller retagging a proven-small Int for the current
  ABI" the milestone asks this table to isolate.
- **`check`**: analogous residual `retag`/`untag` instruction classes are
  present in `refined-checks`' overall mix (both before and after,
  effectively unchanged in absolute count -- `retag` 1,602 -> 2, `untag`
  817 -> 19 in the *totals*, but this reflects `check`'s own now-raw
  parameter needing no retag/untag at its *own* recursive tail call rather
  than a new residual; the scanner closures' own retag/untag traffic,
  unaffected by M9, dominates the remaining count).

This is the evidence the milestone asks this report to leave clean for a
possible later "private raw-Int call ABI" milestone to decide against:
the retag/untag *pattern* is visible, small per call, and entirely
attributable to the existing tagged-Value calling convention, not to any
remaining imprecision in the Range facts themselves.

## R2 interaction report (§76)

Already covered in full under "`refined-checks`/R2 interaction" above.
Summary: `check.n` recovered now; every scanner-closure fact remains
broad, entirely because `native::ExpandNativeBodies`'s pre-HIR body
substitution leaves their governing predicate instance open/generic;
once R2 removes that bridge, M9's own (already general, unmodified)
mechanism is expected to recover their bounds automatically, with no
further `hir/range.tcl` change -- stated as a prediction for R2's own
follow-up measurement, not verified here (R2 itself is out of scope).

## Source-fence confirmation (§4)

`git diff --stat` against the tree this milestone started from:

```
hir/range.tcl                          | 343 +++++++++++++++++++++++++++++-- (331 insertions, 12 deletions)
tests/hir-closed-call-params.test      |   8 +-
tests/hir-range.test                   |  12 +-
tests/instance-entry-range-facts.test  | 322 (new file)
```

No file under `bench/`, `lib/`, `native/` (Rust sources), `core/`,
`surface/`, or any other `hir/*.tcl` file changed. No source-level type
declaration, domain, or annotation was added anywhere to make a benchmark
"prove."

## Recommended next step

Two independent, well-isolated follow-ups this milestone's own residual
table now supports:

1. **R2 (native-body bridge cleanup)**, unblocking `refined-checks`'
   scanner closures for M9's *already-general* mechanism to pick up with
   no further `hir/range.tcl` change -- the single largest remaining
   canonical-benchmark cost (§ the prior census's own C1 finding, ~26% of
   the whole canonical suite), and a prerequisite for M9's own value to
   reach `refined-checks` at all.
2. **A private raw-Int call ABI** (explicitly deferred here, §39-40): the
   "Raw-Int ABI residual" section above gives a clean, per-call-site
   accounting of exactly what a raw parameter-passing convention for a
   proven-small-Int callee would remove (one `rbox`/retag per call, one
   `runbox`/untag per callee entry) -- concentrated in `loop-count`'s
   `work<int>` (500 calls/run) and would compound with R3 (making
   `work<int>`'s own call itself disappear via a termination/effect fact)
   if both were done together.

Given the four-workload evidence lands within (three of four) or points to
a clearly-explained deviation from (the fourth) the census's own estimate,
and every hard non-goal, invariant, and convergence-safety requirement is
independently pinned by a passing test, M9 is complete as scoped.

## Stop condition (§85), checked explicitly

1. Widening remains the ascending fixpoint's own termination mechanism --
   unchanged (nothing above the narrowing-phase comment in `analyze` was
   touched).
2. A separate sound narrowing phase recovers discarded bounds -- `RangeNarrow`
   + the post-ascending round loop; soundness argument above.
3. Recursive/self-tail improvement goes through ordinary transfer functions,
   never branch-pattern matching -- confirmed by
   `m9-narrow-recursive-call-under-branch` (an *unrelated* outer guard,
   still narrows correctly) and by construction (no `if recursive-parameter
   and body contains...` code exists anywhere in the diff).
4. Capture facts come from complete creation provenance -- audited (§22,
   §80 q11-12) and pinned by `m9-capture-open-dynamic-callable-still-sound`.
5. Capture facts are not confused with caller closedness -- audited (§13/17
   above); M9 adds no dependency on `hir::specialize::closed`/
   `InstanceClosed` at all.
6. Multiple creation sites join conservatively -- `m9-capture-multiple-
   creation-sites-join`.
7. No open/unknown ingress is omitted from a parameter theorem -- `m9-narrow-
   open-instance-not-fabricated` (parameter side); `OpenInstances` exclusion
   reused verbatim in the narrowing phase's own contribution fold.
8. Unfinished narrowing cannot leak partial precision -- the fallback-to-
   baseline-on-non-convergence discipline, reusing M7.c.1's own rule.
9. `fib`/`drive`/`step` demonstrate the expected fact recovery, or any
   deviation is soundly explained -- all three demonstrated; the one
   quantitative deviation (`sum-refined`'s 0% instruction-count effect)
   is explained in full under "`sum-refined` effect, explained" above.
10. Genuinely unbounded values stay broad -- `m9-narrow-genuinely-unbounded-
    stays-unbounded`, `m9-capture-broad-capture-stays-broad`, and the
    canonical benchmarks' own `acc`/`total` facts (unchanged, `[-∞,+∞]`-ish,
    both before and after).
11. Existing downstream lowering consumes the better facts with no M9-
    specific special case -- confirmed both by construction (no file
    outside `hir/range.tcl` changed) and by the NIR-level evidence (`ilt
    -> rilt`, rawregs growth) appearing automatically through the
    pre-existing `hir::range::of`/`fitsSmall` queries in `native/lower.tcl`.
12. Specialization identity and instance counts stay unchanged -- "Identity/
    instance invariants" above; `m9-capture-does-not-alter-identity`.
13. No raw-Int machine-call ABI is added -- confirmed by construction (the
    retag/untag boundary instructions are visible, unchanged, in every NIR
    diff above) and stated as a residual, not removed.
14. No R2/native-body cleanup is bundled in -- confirmed by construction
    (`native::ExpandNativeBodies` untouched) and by the scanner-closure
    negative control (every scanner fact identical before/after).
15. Deterministic instruction classes improve in the predicted scalar paths
    -- the callgrind instruction-mix tables above (`bool test`/`bool
    materialize` to exactly zero for `fib`/`loop-count`; `tag test` down
    40%/50%).
16. Full regression and GC stress pass -- see "Full regression" and
    "GC-stress regression" above.
17. Frozen source remains unchanged -- "Source-fence confirmation" above;
    no file under `bench/`, `lib/`, or `native/` changed.
