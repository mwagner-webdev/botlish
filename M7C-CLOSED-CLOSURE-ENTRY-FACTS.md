# M7.c: closed-closure instances + caller-derived entry-kind theorems

## Outcome

Implemented and regression-tested. Family 1b's remaining guards
(M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md: value-capturing closures whose
`KeyType` is forced generic, so their instance's parameters seed `any` even
where every actual runtime caller passes one consistent kind) are removed by
proving, for each such instance, that its complete runtime ingress is known
(**closed**) and deriving an **entry-kind theorem** from the join of what its
exact callers actually pass -- fed into the exact same per-instance seeding
step M1/M7.b already use, so existing guard/type machinery removes the
guards without being taught anything new.

```
git diff --stat (production files only):
 hir/specialize.tcl             | 458 ++++++++++++++++++++++++++++++++++++-
 native/lower.tcl               |  20 +-
 M7B-CONJUNCTIVE-ENTRY-FACTS.md |  56 ++++
 3 files changed
```

`native/lower.tcl`'s own 20 lines are pure option-threading (a new
`-closed-caller-facts-opt`/`BOTLISH_NATIVE_CLOSED_CALLER_FACTS_OPT` flag,
following the identical existing pattern every other `-*-opt` flag in that
file already uses, e.g. `-call-facts-opt`), added only so tests/tooling can
isolate this milestone's own contribution from every other optimization's
-- no lowering rule changed (see "Native lowering" below).

New test file: `tests/closed-closure-entry-facts.test`, **32 tests, all
passing**. Five pre-existing tests, in four files, updated -- either to
their new, more precise, correct expected value, or (three of them) to add
a third, genuinely-disagreeing caller so their own "genuinely broad/
unresolved kind" premise holds regardless of this milestone (see "M1-M7.b
regression controls" for the full explanation of each): `hir-specialize.test`'s
`hir-specialize-m1-explosion-generic`; `hir-call-facts.test`'s
`call-facts-sum-1`; `setcontains-equality-total.test`'s
`setcontains-broad-needle-stays-erroring` and
`setcontains-error-propagation-control`; `setfromlist-equality-total.test`'s
`setfromlist-broad-element-stays-erroring` and
`setfromlist-error-propagation-control`. No other test file's expectations
changed.

**Frozen-corpus result** (measured directly, not inferred):

| | `uri-steady.bot` | `refined-checks.ir` |
|---|---:|---:|
| guards before | 14 | 24 |
| guards after | **0** | **3** |
| machine bytes before | 7055 | 16743 |
| machine bytes after | 5746 | 14898 |
| used instances (before/after) | 19 / 19 | 39 / 39 |
| Block allocations (before/after) | 1 / 1 | 2 / 2 |
| total allocations (before/after) | 61510 objs / 2,544,568 B (unchanged) | 23 objs / 1,085 B (unchanged) |
| program result (before/after) | `29500` / `29500` | `[400, 0]` / `[400, 0]` |

Every hard invariant this milestone pins (identity, instance count,
allocation count, RC/ABI, program result) is **measured unchanged**, not
merely argued unchanged. The 3 residual `refined-checks` guards and the
0-of-14 `uri-steady` residuals are individually classified below ("Family-1b
production before/after"); none is a gap in this milestone's own reasoning
-- each is either genuinely open, or a dead materialized value needing a
different, out-of-scope fix (M7.a's own mechanism (e)).

No closure specialization key changed. No captured-value kind was added to
`KeyType`. No instance was split per caller argument kind. No closure was
cloned per call site. No closure allocation, environment representation, or
RC behavior changed. `native/lower.tcl` carries no lowering-rule change at
all: its only edit is 20 lines threading a new on/off flag
(`-closed-caller-facts-opt`) through to `hir::specialize::analyze`,
mechanically identical to how every other optimization in that file
(`-call-facts-opt` etc.) already exposes its own on/off flag -- added
because one pre-existing test (`hir-call-facts.test`'s own
`call-facts-sum-1`) needs to disable this milestone's own contribution
specifically to keep isolating a different, earlier optimization's own
effect (see "M1-M7.b regression controls"). No lowering *decision* moved:
every guard disappears because the HIR/specialization layer now hands
`native/lower.tcl` stronger, already-established facts, exactly as spec
item 50 requires.

## M7.b drive-by documentation corrections

Before any M7.c work, `M7B-CONJUNCTIVE-ENTRY-FACTS.md` was corrected (not
rewritten) per spec item 0:

- Added a "Precise characterization" paragraph right after the Outcome's
  own `git diff --stat`, stating the three-channel model in the requested
  vocabulary (persistent observed identity/fact = the specialization key;
  persistent declared theorem = `block.declaredParamTypes`; derived
  per-instance semantic view = `narrow(observed, declared)`), the
  `List[never]`/declared-`List[Byte]`/derived-`List[never]` empty-case
  example, and the explicit disclaimer: *"M7.b preserves the two source
  facts in separate existing channels and derives the strongest currently
  representable consumer view from their conjunction. It does not
  introduce a first-class arbitrary fact-product representation."*
- Added the general specific-key invariant sentence verbatim: *"a specific
  specialization key must not suppress independently proven declared entry
  facts merely because the key itself carries structure"* -- with a
  forward reference to this document for M7.c's own generalization of it.
- Corrected the "Satisfiability model" section with an explicit
  architecture diagram and the sentence *"`FactsSatisfiable` does not gate
  `Analyze`'s `narrow` combination. `Analyze` never calls it, and no
  production code path calls it before (or instead of) `narrow`."* --
  the report's own pre-existing Q31 already implied this correctly (it
  named `verifyDeclaredParams` as the upstream proof), but nothing
  previously stated the non-gating fact as directly as spec item 0 asks
  for.
- Added a source comment directly on `hir/specialize.tcl`'s own M7.b
  aggregate declaration-seeding branch (immediately before its `narrow`
  call), stating: *"The declared parameter theorem and the instance
  observation are already known compatible because declared-parameter
  verification precedes specialization. narrow combines already-compatible
  facts; it is not an admissibility check."*
- No redundant production `FactsSatisfiable` call was added anywhere (spec
  item 0's own explicit prohibition); `FactsSatisfiable` remains exactly
  what M7.b left it: a named, tested query for analyses/tests that
  independently need it.

Answers to the required drive-by questions (spec item 108) are folded into
"Required M7.b drive-by questions" below.

## Fresh family-1b guard census (post-M7.b, pre-M7.c)

Reproduced directly against the current tree with M7.a's own audit tool
(`audit/m7a-instance-selection/tools/corpus.tcl`, unmodified), not merely
re-read from the M7.a report:

```
$ tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl bench/uri-steady.bot OUT
used instances: 19 (program + 9 generic + 9 specialized); open: 7
machine code bytes: 7055
representation blockers (guards): 14
    generic/param/UnknownParameterKind: 12
    generic//UnknownCallResultKind: 2

$ tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl bench/refined-checks.ir OUT
used instances: 39 (program + 22 generic + 16 specialized); open: 20
machine code bytes: 16743
representation blockers (guards): 24
    generic/param/UnknownParameterKind: 23
    generic//UnknownCallResultKind: 1
```

**The remembered 24/14 counts still hold, byte-for-byte, post-M7.b** (M7.b's
own report already confirmed this; this run reconfirms it independently,
against the current tree, with the `git diff` for this milestone stashed
out). M7.b's own aggregate-declaration transport touches a different guard
population (declared `List[T]`/`ImmutableSet[T]` parameters of otherwise
ordinary instances) than family 1b (undeclared parameters of
generic-forced closures) -- zero overlap, confirmed by the unchanged count.

### Guard census table (family-1b candidates, pre-M7.c)

Every guard below is `generic/param/UnknownParameterKind` unless noted;
"declared" is `-` (undeclared) for every one, confirming M7.a's own
"family 1b guards are all undeclared parameters of generic instances"
finding still holds exactly. Guard counts are per-instance (a `refined-
checks` function used twice, once per `Emailish?` scanner copy, gets two
identical rows below, matching guards.txt).

| instance | parameter(s) | guard count | callers (pre-theorem view) | proposed closed-caller theorem |
|---|---|---:|---|---|
| `byte::high_nibble<generic>` | `b` | 1 | `hex_pair<generic>` (itself unresolved pre-theorem: cascade) | Int (once `hex_pair.b` resolves) |
| `hex_pair<generic>` | `b` | 1 | `esc_bytes<generic>` (cascade) | Int (once `esc_bytes.bytes` resolves) |
| `esc_bytes<generic>` | `i`, `bytes`, `acc` | 3 | `esc_char<generic>` (int, List[Byte], str) + self (i+1, bytes fwd, acc concat) | Int, List[Byte], str |
| `esc_char<generic>` | `c` | 1 | `esc_from<generic>` (str, via substring) | str |
| `esc_from<generic>` | `i`, `text`, `acc` | 3 (+1 `UnknownCallResultKind`) | `uri_escape_text<generic>`/self: int, str/cascade, str | Int, str (uri-steady); text stays open in refined-checks (see below) |
| `repeat_uri<generic>` (uri-steady only) | `i`, `total`, `acc` | 3 (+1 `UnknownCallResultKind`) | program + self: int, int, int | Int, Int, Int |
| `char_at<generic>` (×2, refined-checks) | `i` | 2 | 6 exact callers, all Int | Int |
| `scan_local<generic>` (×2) | `i` | 1 | 3 exact callers, all Int | Int |
| `scan_label<generic>` (×2) | `i` | 1 | self (Int) + `domain_loop` (cascade) | Int |
| `scan_alpha<generic>` (×2) | `i` | 1 | self (Int) + `tld_ok` (cascade) | Int |
| `tld_ok<generic>` (×2) | `i` | 1 | `domain_loop<generic>` (Int) | Int |
| anonymous `Emailish?` body (×2) | `v` | 1 | **none** (dead materialized `fnvalue`, M7.a's mechanism (e)) | none: needs dead-value elimination, not a theorem |

Totals: **14/14 `uri-steady` guards and 23/24 `refined-checks` guards** are
family-1b candidates by this classification (the 24th, `esc_from`'s own
`UnknownCallResultKind`, is mechanism (d), covered by the same theorem
once the parameter guards it depends on resolve). This matches M7.a's own
totals exactly.

## Current closure-instance identity model

Unchanged from `hir/specialize.tcl`'s own pre-existing header: a
specialization key is `{BLOCK ARG-TYPES}`; `KeyType` reduces a static type
to the kind an operation's choice depends on; a value-capturing closure
(a block whose `captures` list is non-empty and which is not in
`hir::aot::context`'s own `statics` set) has its key forcibly collapsed to
`GenericKey` by `Handle`'s own pre-existing "call" case, unless every
capture is a proven-Int scalar (`scalarCaptures`). **M7.c changes none of
this.** `hir::specialize::KeyType` has zero lines changed (confirmed by
`git diff`); `Instance`, the `Handle` `call`/`create` cases, `RefineParams`
and the explosion-control policy are byte-for-byte unmodified.

## Current closure ingress mechanisms (audit, spec section 8)

Inspected directly in `hir/aot.tcl`, `hir/types.tcl`, `hir/callables.tcl`,
`hir/blockescape.tcl`:

| mechanism | exists today? | routes through `hir::specialize::Handle`'s `call` op? |
|---|---|---|
| direct call of a known block | yes (`hir::types::Call`'s `{block B arity result}` branch) | **yes** -- the only path that does |
| `callenv` (M2: closure value as environment operand of a still-direct call) | yes (native/lower.tcl; unaffected by this milestone, see "Preserve M2 direct-call semantics") | yes, same as above (M2 never reinterprets the operand as dispatch target) |
| `callvalue`/dynamic dispatch through an unresolved callee | yes (`hir::types::Call`'s "not callable"/bare-kind fallback) | **no** -- `Handle` is invoked only when `calleeType` is the exact 4-element `{block B arity result}` form |
| captured callable forwarded through another block | yes (an ordinary capture; call resolution at the *use* site still goes through the same `{block...}`-or-not test) | only where the forwarded use is itself an exact call |
| returned/stored callable | yes (ordinary first-class value flow) | never itself (a *later* call of the returned/stored value is a fresh `hir::types::Call`, tested independently) |
| joined callable identity (`cond ? f : h`) | yes (`hir::types::lub` on two `{block...}` types; differing targets lose exactness) | only if the join still resolves to one exact `{block...}` |
| module-retained callable / native "-module-fn" bridge | yes (`native/native.tcl`'s `ModuleNativeBridge`; retypes the native reference as the resolved block, per that file's own comment) | in principle yes, but **the reference itself is never a local blockescape candidate** (see "Relationship to OpenInstances") -- confirmed empirically: `refined-checks.ir`'s own `uriEscape`-bridged call to `web::uri_escape_text` is genuinely open |
| native callback ingress | not found: no native registration in `core/native.tcl` takes a Block-typed callback parameter | n/a |
| FFI callback ingress | not applicable -- this compiler has no FFI | n/a |
| dynamic `NativeImpl` dispatch | not found as a separate mechanism from ordinary native calls above | n/a |
| event-loop/task callback ingress | not applicable -- Botlish has no event loop/task runtime construct | n/a |
| reflection/embedding | not implemented in this compiler | n/a |

**Conclusion**: the only mechanism that ever populates `hir::specialize`'s
own `calls` map (hence the only mechanism this milestone's caller-fact scan
can ever read a fact from) is an *exact* direct call. Every other mechanism
above either never reaches `Handle` at all, or reaches it only when it has
*itself* reduced to an exact call. This is the structural reason the
closed-caller theorem is sound by construction for the calls it does read:
an open/dynamic edge is never among them.

## Exact definition of closedness

```tcl
proc hir::specialize::InstanceClosed {snapshot blockescape id} {
    set instance [dict get $snapshot instances $id]
    if {[dict get $instance block] eq "program" || ![dict get $instance generic]} {
        return 1
    }
    set block [dict get $instance block]
    if {$block in [dict get [dict get $snapshot context] statics]} {
        return ![dict exists [MaterializedBlocks $snapshot] $block]
    }
    return [hir::blockescape::wants $blockescape $id]
}
```

In words: `InstanceClosed(instance) == true` exactly when

- the program's own root instance (trivially -- it has no callers to be
  open with respect to), or
- a *specialized* (non-generic) instance (per `hir::range::OpenInstances`'s
  own precedent comment, reproduced here: "a specialized instance's only
  possible callers are exactly the direct calls hir::specialize resolved
  to it, so it is never open regardless" -- a specific key can only be
  selected by an exact call in the first place), or
- a *generic* instance of an ordinary (static/envless) block whose Block
  value is never materialized anywhere in the used-instance set's reachable
  code (the same test `hir::range::OpenInstances` already uses in
  production), or
- a *generic* instance of a value-capturing closure that
  `hir::blockescape`'s own eligibility fixpoint (`RefsAsCalls`, a
  greatest-fixpoint proof that *every* reference to the candidate binding
  -- self, external, or through an equally-eligible sibling -- is nothing
  but an exact, arity-matching call) has already proven `wants` a
  capture-explicit internal variant for.

This is a genuine two-branch definition, not one reused test applied
uniformly (see "Relationship to OpenInstances" for why one test is not
enough on its own).

## Exact proof of callgraph completeness

- **Static-block branch**: `hir::aot::materializedBlocks` is a whole-
  program computation over every used instance's own reachable code
  (`hir::specialize::Analyze` calls it once per instance, unioned via
  `MaterializedBlocks` here); a block never appearing there has, by that
  function's own exhaustive case analysis (block creation, bind, and every
  `ref` of an envless-bound name), no route to escape as a first-class
  value anywhere in the program's *used* code. Combined with the ingress
  table above (only a materialized value can ever reach dynamic dispatch),
  absence from this set is a completeness proof for an ordinary function.
- **Closure branch**: `hir::blockescape::Bindings`' own eligibility
  fixpoint requires, for a candidate to be `wants`-marked, that *every*
  reference to its binding within its own region resolve to a consistent,
  arity-matching call target (`RefsAsCalls`), for all three reference
  classes (self, external, sibling) -- with an explicit, unconditional
  decline ("must not be virtualized") the moment *any* reference is found
  that is not provably a call, or no reference at all is found. This is
  itself already relied on for a *stronger* guarantee (skipping heap
  allocation entirely) in shipped code, so this milestone's reuse of it is
  no less audited than that existing guarantee.

## Relationship to callable escape analysis (`hir::callables`)

Audited directly (`hir/callables.tcl`). `hir::callables::verify` is a
whole-program **legality gate** (a static `TYPE` diagnostic), not a
per-instance oracle: it rejects a program that would erase a *Bearing*
callable's (one with a declared parameter type or declared error set)
exact identity at any join/argument/return position. Family 1b's own
closures are, by construction, *undeclared* (`declared=-` throughout the
guard census above), so `Bearing` is false for every one of them and
`hir::callables::verify` imposes no constraint either way. It is therefore
not reusable as M7.c's closedness proof (it answers a different question:
"is this program legal", not "is this specific instance's ingress
enumerable") -- `hir::blockescape` is the correct reuse target, per the
"Current closure ingress mechanisms" table.

## Relationship to OpenInstances

`hir::range::OpenInstances` (already in production, feeding that module's
own caller-Range-propagation) is **not** reused directly as M7.c's own
closedness test, and this is a deliberate, empirically-verified decision,
not an oversight:

- `hir::range::OpenInstances` uses exactly the same `materializedBlocks`
  union this report's own static-block branch uses.
- `hir::aot::materializedBlocks`'s own `bind` case counts **any** bind of a
  non-envless (value-capturing) closure as materializing its value,
  unconditionally (`$value ni $envless` alone, OR'd with everything else) --
  correct for that function's own conservative contract (nothing there yet
  examines individual references), but it means `OpenInstances` reports
  **open** for essentially every value-capturing closure, regardless of how
  it is actually referenced.
- Confirmed empirically, not asserted: every family-1b guard site in both
  frozen benchmarks except the plain-static cascade (`byte::high_nibble`)
  reads `open=1` under the production `hir::range::OpenInstances` query
  (`audit/m7a-instance-selection/tools/lib.tcl`'s own `open` column, which
  calls it unmodified).
- `hir::blockescape`'s own eligibility fixpoint is the existing, finer test
  that actually examines each reference. Re-running that same audit query
  against `hir::blockescape::wants` instead (a throwaway script, not
  committed) shows it agrees with `wants=1` for essentially the entire
  family-1b population this milestone actually closes (`hex_pair`,
  `esc_bytes`, `esc_char`, `esc_from`, `repeat_uri`, `char_at`,
  `scan_local`, `scan_label`, `scan_alpha`, `tld_ok`, `domain_loop`, and
  `web::uri_escape_text` itself in `uri-steady.bot` specifically).

**Answer to spec Q4/Q5**: closedness is *partly* already represented by
`OpenInstances` (the static-block half, reused verbatim, duplicated as a
private `MaterializedBlocks` helper inside `hir/specialize.tcl` rather than
imported, to avoid reversing `hir::range`'s own existing dependency on
`hir::specialize`). It is **not** already represented for the
closure half; that half is new state (`hir::specialize::InstanceClosed`'s
own closure branch), justified precisely because `OpenInstances`'s own
existing test is provably too coarse for exactly the population this
milestone targets.

## Caller fact collection

`hir::specialize::ClosedCallerFacts {hir snapshot closed}`: for every used
instance's own `calls` map (`ExprId -> target InstanceId`, `hir::specialize`'s
own, already-computed, post-Fixpoint call graph -- never re-derived), for
every call whose target is in `CLOSED` and whose call expression is
`reachable` in the caller's own instance:

- reads the caller's own `hir::specialize::view` (its already-analyzed HIR,
  overlay applied);
- reads each argument's `hir::typeOf`, reduced through the *identical*
  `KeyType` function instance identity itself uses (so the theorem is
  never more precise than what identity already tracks -- "entry kind, not
  exact value", spec item 14);
- **excludes** a position whose argument is nothing but an unchanged
  self-forward of the callee's own parameter (a self/recursive call passing
  a parameter straight through) from that call's own contribution --
  exactly `RefinementFacts`' own pre-existing exclusion, and for the
  identical reason: such a reference's own type is circularly the very
  theorem being computed, so including it (even as a neutral "any"
  placeholder) would permanently poison the join to "any" and never
  converge. **Found empirically, not by inspection**: the first working
  version of this proc, without the exclusion, left `esc_bytes.bytes`
  stuck at `any` forever; adding the exclusion (as a per-call-position
  "no contribution" marker, distinct from the real type atom `any`, which
  must still join normally when it comes from a genuine caller) fixed it,
  confirmed by re-running the frozen-corpus census before and after.
- joins every contributing call's own per-position fact via
  `hir::types::lub` (the same lattice join every other part of this module
  already uses), producing one KeyType per parameter.

## Entry-theorem derivation

`hir::specialize::CombineCallerTheorem {type fact}`, called from
`Reanalyze`'s own parameter-seeding loop, **immediately after** the
existing M1/M7.b declared-theorem combination, on the same `type` variable:

```tcl
proc hir::specialize::CombineCallerTheorem {type fact} {
    if {$fact eq "any" || $fact eq ""} { return $type }
    if {![hir::types::IsSpecific $type]} {
        return [expr {[hir::types::IsSpecific $fact] ? $fact : [hir::types::narrow $type $fact]}]
    }
    if {([hir::types::IsList $type] && [hir::types::IsList $fact])
            || ([hir::types::IsSet $type] && [hir::types::IsSet $fact])} {
        return [hir::types::narrow $type $fact]
    }
    return $type
}
```

This is deliberately the *same* three-branch shape M1/M7.b's own
declared-theorem combination uses (adopt outright when the current type is
unseeded and the fact is itself aggregate/callable-specific; `narrow`
otherwise for a scalar fact; recurse via the M7.b-extended `narrow` for a
matching aggregate pair) -- reused a second time for a second,
independently-proven channel, not a new combination algebra. No new caller
fact algebra was invented (spec item 13): `hir::types::lub` (join across
callers) and `hir::types::narrow` (combine with what is already seeded) are
both pre-existing primitives.

## Fixpoint / recursion handling

**Why a bounded round loop is genuinely needed, not merely permitted**:
the frozen corpus exhibits real cascades (`hex_pair.b` depends on
`esc_bytes.bytes`'s own theorem; `scan_label`/`scan_alpha` depend on
`domain_loop`/`tld_ok`'s own). `hir::specialize::CloseCallers` runs a
small, bounded, monotone round loop, structurally the same shape as
`hir::range::analyze`'s own already-existing caller-propagation fixpoint
(applied to Kind facts here instead of Range facts), over exactly the
closed-instance subset:

1. Compute `closed` once (a pure function of the post-Fixpoint `snapshot`
   and `hir::blockescape::analyze`'s own output -- never touched again).
2. Compute the instances that will ever receive a fact at all (`facts`'s
   own key set is round-invariant, since `calls`/edges are frozen for the
   whole pass); reset exactly those instances' own `result` to `never`
   (see "Result monotonicity" below) -- **not** every closed instance, so
   a genuinely zero-caller closed instance's own result is never disturbed.
3. Each round: recompute `ClosedCallerFacts` fresh (cheap: it only reads
   already-computed overlays), then `Reanalyze` every instance with a fact.
   Stop when a full round changes nothing, or after `passLimit` (16, the
   same constant `Analyze`'s own non-convergence safety valve uses) rounds.

**Recursive self edges** (spec item 17) participate directly: a self-call
whose argument is *not* an unchanged forward (e.g. `inner(x, n - 1)`)
contributes its own derived fact normally; an unchanged forward
contributes nothing (see "Caller fact collection"). Pinned by
`recursive-self-edge-closed-with-theorem` (both parameters resolve to
Int: `x` from two ordinary outer callers, `n` from the same plus the
self-call's own derived `n - 1`).

**Mutually recursive closure instances** (spec item 18): the frozen corpus
contains one real candidate shape (`scan_label`/`domain_loop`,
`scan_alpha`/`tld_ok`), and the round loop's own re-derivation of
`ClosedCallerFacts` from each round's *freshly reanalyzed* overlays is
exactly what lets a later round see an earlier round's improvement on a
different instance -- no separate SCC-detection code was written; the
existing bounded, monotone round budget already subsumes it (confirmed:
both cascades fully resolve, well inside the 16-round budget, for both
frozen benchmarks).

## M7.c.1 drive-by: CloseCallers' own convergence fence

(M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md has the full milestone; this is the
short correction spec item 33 of that milestone asks for, on this report's
own description of the round loop above.)

The round loop described above ("Cascades and fixpoint") did not originally
say what happens if `passLimit` rounds are not enough -- it simply exited
the `for` loop either way, and every previously-applied per-instance change
was kept regardless. That is corrected as of M7.c.1: `CloseCallers` is a
**transactional** post-Fixpoint precision pass. Its candidate analysis --
starting from the already-sound ordinary-Fixpoint snapshot -- is committed
only after a complete round changes nothing (a proven fixpoint, not merely
"the budget ran out"). If the round budget is exhausted while a complete
round is still changing state, the candidate is discarded in full and the
ordinary pre-CloseCallers specialization snapshot is returned unchanged --
identical to running with `-closed-caller-facts-opt 0`. This is a pure
addition of failure semantics: every "successful convergence" measurement
already in this report (frozen-corpus guard/byte counts, instance counts,
the 32-test suite) is reconfirmed unchanged by M7.c.1's own regression run
(see that milestone's own report for the exact figures), because the
production round budget (16) already converges in every case this report
measures.

## Result monotonicity (a fix discovered empirically)

The first working version of `Reanalyze` **overwrote** `instance result`
directly with each round's freshly inferred type. This is unsound for a
self-referential result (`esc_from`'s own recursive branch), and was found
to be so directly: the ordinary (pre-M7.c) ,`Fixpoint` had already pinned
`esc_from`'s own `result` to `any` via its own non-convergence safety valve
("an instance analyzed more than passLimit times gets result any"), and
`lub(any, X) = any` for any `X` -- so a caller-derived improvement could
never climb back down, and the frozen-corpus census kept showing
`esc_from`/`repeat_uri`'s own `UnknownCallResultKind` guards even after
their *parameter* guards were correctly eliminated. Fixed by (a) widening
via `hir::types::lub(oldResult, inferred)` instead of overwriting (mirrors
`Analyze`'s own "result = lub(old, inferred)" exactly), and (b) resetting a
reanalyzed instance's own starting `result` to `never` (the same bottom
`Instance` itself starts every instance at) before the round loop begins,
so this proc's own bounded, monotone re-settling reaches the identical
least fixpoint a correctly-converged ordinary `Fixpoint` would have,
recovering precision the ordinary Fixpoint's own safety valve had
permanently discarded under the weaker (pre-theorem) entry facts. Measured
effect: `uri-steady`'s residual guard count dropped from 2 to 0, and
`refined-checks`'s from 4 to 3, purely from this fix (no other guard-
elimination lever changed).

## Observed vs declared vs closed-caller fact channels

Exactly the "three-channel model" M7.b's own drive-by correction (above)
anticipates:

| channel | source | lifetime | who feeds `Analyze`/`Reanalyze`'s own `types` seed |
|---|---|---|---|
| observed | the specialization key (`instance args`) | fixed per instance | M1's own pre-existing base case (`type = keyType`) |
| declared | `block.declaredParamTypes` | instance-independent | M1/M7.b's own existing combination branch |
| closed-caller | `ClosedCallerFacts`'s own join | recomputed every `CloseCallers` round, for closed instances only | `CombineCallerTheorem`, this milestone's own new branch |

No first-class product type was introduced for this third channel either,
for the identical reason M7.b's own didn't need one: `CombineCallerTheorem`
produces one ordinary `hir::types` value, already whatever shape every
existing consumer (`hir::typeOf`, `Require`, `elementOf`, `ShapeResult`)
already knows how to read.

## Combination semantics

Channel order in `Reanalyze`'s own seeding loop (mirroring `Analyze`
exactly, with the new branch appended, never interleaved):

```
type = observed key
if declared theorem applies: type = combine(type, declared)   [M1/M7.b, unmodified]
type = CombineCallerTheorem(type, closed-caller theorem)      [M7.c, new]
RefineParams(...)                                             [named-refinement widening, unmodified]
```

`declared-and-caller-theorem-coexist-declared-survives` confirms the
declared `List[Byte]` theorem still reaches a closure parameter's own view
with the closed-caller pass running alongside it (unaffected, since M1's
own "adopt declared type outright when unseeded" branch already fully
supplies it before `CombineCallerTheorem` ever runs -- item 38's own
associativity question is moot here because the declared branch already
reaches a fixed point `CombineCallerTheorem`'s own `fact eq "any"` early
return leaves untouched). No test in this milestone's own suite found an
ordering-sensitive case; `narrow` is used throughout, never `lub`
(narrowing, not widening, is what every seeding branch does), and no case
required proving `narrow` associative beyond what M7.b's own report
already established for the declared/observed pair.

## Primary positive fixture

```
fn outer(tag):
    fn inner(x):
        x + length(tag)
    inner(1) + inner(2)
outer("v")
```

`inner` captures `tag` (str, not Int -- so `Handle`'s own `GenericKey`
collapse applies): before this milestone, `inner<generic>`'s own `x` seeds
`any` and its `x + length(tag)` carries an `UnknownParameterKind` guard.
After: `hir::specialize::closed` proves it closed; `closedCallerTheorem`
returns `int` (the join of both exact callers, `multi-caller` test);
`paramGuards` finds no representation blocker at all; the instance's own
label (`inner<generic>`) and the used-instance count (3: program, outer,
inner) are identical with the closed-caller pass on or off.

## Mixed-kind closed fixture

```
fn outer(tag):
    fn inner(x):
        x + length(tag)
    inner(1) + inner(tag)
outer("v")
```

`inner` is still closed (both callers are exact), but they disagree
(Int, str). `closedCallerTheorem` returns `any` (the lattice join of Int
and str is its own top, never a fabricated single kind), and the
kind-requiring guard on `x + length(tag)` correctly **stays**: closedness
never manufactures an unsound narrowing merely because an instance happens
to be closed.

## Open-instance negative fixture

```
fn outer(tag):
    fn inner(x):
        x + length(tag)
    fn apply(f, y):
        f(y)
    inner(1) + apply(inner, 2)
outer("v")
```

`inner` is passed as an ordinary value into `apply`'s own untyped
parameter, from which `apply`'s body calls it dynamically (`f(y)`, never
routed through `hir::specialize::Handle`'s own `call` op at all, so it can
never appear in any instance's `calls` map). `hir::specialize::closed`
returns `0`; `closedCallerTheorem` returns `""` (no theorem attempted at
all, not merely a broad one); the guard on `x + length(tag)` remains; and
`apply`'s own `f(y)` stays a fully dynamic call (`dict get ... calls`
empty for it) -- confirming this milestone never turns an ordinary
`callvalue` into a direct call.

## Alias/escape/capture controls

- **Exact alias** (`alias = inner; inner(1) + alias(2)`): the *actual,
  current* answer, pinned directly rather than assumed, is that `inner`
  is **not** currently proven closed. `hir::blockescape`'s own
  single-level `RefsAsCalls` check only ever recognizes a reference that
  is itself the direct callee of a call; a plain value alias's own
  bind-value reference to `inner` is not that, so the sibling/eligibility
  fixpoint conservatively declines it. This is a real, conservative
  architectural finding (not a defect this milestone introduces or is
  required to fix -- spec item 19 asks the question, it does not mandate
  "yes"), reusing M2's own *type-level* exact-alias semantics would be a
  different, larger change to `hir::blockescape` itself, out of this
  milestone's scope (it changes no representation decision M7.c depends
  on: `inner`'s guard simply stays, soundly, exactly as before this
  milestone for this one construction).
- **Escape** (`apply(inner, 2)`, above): prevents closedness, confirmed.
- **Captured-through-parent**:

  ```
  fn outer(tag):
      fn inner(x):
          x + length(tag)
      fn middle(y):
          inner(y)
      middle(1) + middle(2)
  outer("v")
  ```

  `inner` is referenced only inside its sibling `middle`'s own body (a
  capture-and-call, not a direct call from `outer`'s own top-level code).
  `hir::blockescape`'s own "sibling reference" fixpoint (`Bindings`' 2c)
  proves this transitively -- both `inner` and `middle` are closed, and
  `inner`'s own theorem (`int`) is derived transitively through `middle`'s
  own (also `int`) calls, which are themselves derived from `outer`'s
  literal Int calls to `middle`. Both instances' guards are eliminated.

## Family-1b production before/after

Per-function machine-code bytes, from `audit/m7a-instance-selection/tools/
corpus.tcl`'s own `functions.txt` (unmodified tool, diffed directly):

| function (generic instance) | bytes before | bytes after | guard before | guard after |
|---|---:|---:|---:|---:|
| `byte::high_nibble` (uri-steady/refined-checks, per copy) | 214 | 103 | 1 | 0 |
| `hex_pair` | 484 | 378 | 1 | 0 |
| `esc_bytes` | 864 | 624 | 3 | 0 |
| `esc_char` | 516 | 448 | 1 | 0 |
| `esc_from` (uri-steady) | 1004 | 620 | 4 | 0 |
| `esc_from` (refined-checks, ×1 used) | 1004 | 684 | 4 | 1 |
| `repeat_uri` (uri-steady) | 1180 | 780 | 4 | 0 |
| `char_at` (×2 copies) | 450 | 262 | 2 | 0 |
| `scan_local` (×2) | 884 | 804 | 1 | 0 |
| `scan_label` (×2) | 644 | 564 | 1 | 0 |
| `scan_alpha` (×2) | 540 | 468 | 1 | 0 |
| `tld_ok` (×2) | 540 | 452 | 1 | 0 |
| `domain_loop` (×2, not itself a direct family-1b guard site, benefits from its own callee's improved facts) | 636 | 644 | 0 | 0 |

(`domain_loop`'s own byte count moves slightly because its own
`op:veq`/`op:ieq` choice changes once `tld_ok`'s own comparison operand
kind is known -- an incidental consequence of stronger facts reaching an
existing, unmodified lowering rule, not a new lowering rule.)

**Residual guards, individually classified** (spec item 106's own required
categories):

- `refined-checks.ir`'s `esc_from<generic>`'s own `text` parameter: **open
  instance**. `refined-checks.ir` reaches `web::uri_escape_text` only
  through the legacy `uriEscape` native-module-bridge binding
  (`native/native.tcl`'s own `-module-fn` mechanism), never through an
  ordinary direct HIR call from a locally-bound closure candidate;
  confirmed directly (`hir::specialize::closed` returns `0` for
  `web::uri_escape_text<generic>` under `refined-checks.ir` specifically,
  `1` under `uri-steady.bot`, where the same function is called ordinarily
  from `repeat_uri`). This is exactly why `uri-steady.bot` reaches **0**
  residual guards while `refined-checks.ir` does not: the two programs
  reach the identical library function through structurally different
  ingress.
- `block e332<generic>`/`block e552<generic>` (the two `Emailish?` scanner
  bodies' own anonymous closures), `v` parameter: **capture-derived
  residual, out of scope** -- M7.a's own mechanism (e), a dead
  materialized `fnvalue` with *no* exact caller at all
  (`hir::blockescape` correctly declines it: "no genuine call reference
  observed", so `closed=0`, and this milestone's own zero-caller rule
  correctly refuses to fabricate a theorem for it either way). The fix
  these two guards need is dead-`fnvalue` elimination, not an entry
  theorem -- explicitly flagged out of scope by spec items 25, 72, and
  left untouched.

No residual guard is unexplained.

## Per-instance dumps (centerpiece)

For every optimized instance: instance key, closed-caller theorem, guards
before/after, and machine bytes before/after are all in the table above and
the guard census table earlier in this report ("Guard census table"); the
underlying raw data (`instances.txt`, `guards.txt`, `functions.txt`,
`summary.txt`, before and after) is preserved as this milestone's own audit
artifact set under `audit/m7c-closed-closure-entry-facts/` -- an adjacent
directory to M7.a's own (`audit/m7a-instance-selection/`), per spec item
87's own instruction to keep before/after provenance clear rather than
overwrite or relabel M7.a's own committed artifacts -- generated by
re-running M7.a's own unmodified `tools/corpus.tcl` against each
benchmark, once with `hir::specialize::analyze`'s own
`-closed-caller-facts-opt 0` (pre-M7.c) and once with the default (1,
post-M7.c). Closure/environment identity is unchanged in every row
(confirmed by the "instance count" and "identity" checks below); open/
unknown-edge state is `closed=0`/`theorem=""` exactly for the two residual
categories above and nowhere else.

## Instance-count delta

**Zero**, both benchmarks, confirmed by the actual before/after runs
above: `uri-steady.bot` 19 used (9 generic + 9 specialized) before and
after; `refined-checks.ir` 39 used (22 generic + 16 specialized) before and
after. No new specialized instance exists because of this milestone.

## Block-allocation delta

**Zero.** `uri-steady.bot`: 1 Block allocation per run, before and after
(the rejected naive closure-kind-identity experiment measured **8001**
here -- M7.a's own hard rejection benchmark). `refined-checks.ir`: 2 Block
allocations, before and after. Total allocation counts (objects and bytes)
are identical too, confirmed by the corpus tool's own allocation tracker
(a real program run under the `native` backend, not a static estimate):
61,510 objects / 2,544,568 bytes (`uri-steady`) and 23 objects / 1,085
bytes (`refined-checks`), unchanged in both fields.

## Frozen corpus census (full)

Already given in "Outcome"; NIR-op totals, also unchanged except `guard`
(the whole point):

| | `uri-steady` before | `uri-steady` after | `refined-checks` before | `refined-checks` after |
|---|---:|---:|---:|---:|
| `call` | 16 | 16 | 32 | 32 |
| `callenv` | 1 | 1 | 2 | 2 |
| `callmulti` | -- | -- | 12 | 12 |
| `closure` | 1 | 1 | 2 | 2 |
| `capture` | 1 | 1 | 3 | 3 |
| `tail` | 3 | 3 | 11 | 11 |
| `br` | 19 | 19 | 67 | 67 |
| `faildeclared` | 1 | 1 | 1 | 1 |
| `guard` | 14 | **0** | 24 | **3** |

Every non-`guard` op count is exactly identical: no call form changed, no
closure/capture op appeared or disappeared, confirming no allocation-shape
or ABI-relevant lowering decision moved.

## M1-M7.b regression controls

All run against the current tree with this milestone's own changes in
place:

| suite | result |
|---|---|
| `tests/conjunctive-entry-facts.test` | 28/28 passed |
| `tests/empty-collection-admissibility.test` | 24/24 passed |
| `tests/symbolic-type-identity.test` | 13/13 passed |
| `tests/hir-specialize.test` | 27/27 passed (1 pre-existing test updated -- see below) |
| `tests/hir-range.test` | 52/52 passed |
| `tests/hir-callable-target.test` | 8/8 passed |
| `tests/typed-parameters.test` | 50/50 passed |
| `tests/checked-domain-proof-provenance.test` | 17/17 passed |
| `tests/hir-closed-call-params.test` | 15/15 passed |
| `tests/typed-callable-escape.test` | 35/35 passed |
| `tests/native-block-escape.test` | 48/48 passed |
| `tests/native-escape.test` | 22/22 passed |
| `tests/native-uri-escape.test` | 18/18 passed |
| `tests/source-types.test` | 46/46 passed |
| `tests/hir-aot.test` | 32/32 passed |
| `tests/hir-call-facts.test` | 8/8 passed (1 pre-existing test updated -- see below) |
| `tests/setcontains-equality-total.test` | 17/17 passed (2 pre-existing tests updated -- see below) |
| `tests/setfromlist-equality-total.test` | 15/15 passed (2 pre-existing tests updated -- see below) |
| `tests/closed-closure-entry-facts.test` (new) | 32/32 passed |

**Five pre-existing tests updated, all discovered by the full-suite run**
(not by inspection -- each is exactly the kind of interaction this
report's own "Required M1-M7.b regression controls" section exists to
catch), **all in the same one family**: a construction using
`hir::specialize::limit 1` (or an equivalent single-slot explosion) to
force a generic fallback instance with, before this milestone, exactly one
*actual* exact caller left once a first, divergent call took the one
specific slot. Every one of them previously relied on that fallback's own
parameter staying unresolved (`any`) purely because nothing transported a
fact into it -- precisely the gap this milestone closes, for *any* generic
instance (closure or plain static function alike; `hir::specialize::
InstanceClosed`'s own static-block branch does not distinguish "generic via
explosion control" from "generic via value-capture"). Two different, both
legitimate, fixes were applied depending on each test's own actual intent:

- **`hir-specialize-m1-explosion-generic`** (`tests/hir-specialize.test`):
  the test's own real subject (a *declared* parameter's theorem surviving
  explosion control) is unaffected; its *incidental* pin of the untyped
  sibling parameter at `any` was simply stale. Updated to the new, more
  precise, correct value (`str`, the one actual caller's own literal) --
  confirmed not a regression: the declared-`Small` theorem and the
  instance partition are both unaffected, and the change is exactly the
  kind of guard-eliminating improvement this milestone exists to make.
- **`call-facts-sum-1`** (`tests/hir-call-facts.test`),
  **`setcontains-broad-needle-stays-erroring`**/
  **`setcontains-error-propagation-control`**
  (`tests/setcontains-equality-total.test`), and
  **`setfromlist-broad-element-stays-erroring`**/
  **`setfromlist-error-propagation-control`**
  (`tests/setfromlist-equality-total.test`): each test's own real subject
  *is* "this parameter stays genuinely unresolved" (an earlier milestone's
  own negative control, or an isolation check for a different `-*-opt`
  flag's individual contribution) -- so relying on M7.c's own gap to hold
  that premise up was never intentional, and the fix preserves each test's
  original intent instead of merely accepting the new value:
  - `call-facts-sum-1` isolates `-call-facts-opt`'s own contribution by
    comparing lowering with it on vs. off; with it off, the closure under
    test stays generic and is now *also* reached by this milestone's own
    (independent, still sound) closed-caller theorem, defeating the
    isolation. Fixed by adding `-closed-caller-facts-opt 0` alongside
    `-call-facts-opt 0` in the "off" comparison -- both flags threaded
    through `native/lower.tcl` identically (see "Outcome"), so the test
    can still isolate `-call-facts-opt` alone.
  - The four `setcontains`/`setfromlist` tests each used exactly **two**
    divergent calls into a `limit 1` fallback, leaving exactly one actual
    caller for the fallback once the first (divergent) call took the one
    specific slot -- a single caller this milestone's own theorem
    soundly (not incorrectly) resolves. Fixed by adding a **third**,
    differently-kinded call to each fixture, keeping the fallback's own
    caller set genuinely disagreeing (so the theorem correctly widens to
    "any", preserving each test's own "genuinely broad/unresolved kind"
    premise) regardless of this milestone.

No test's own *real* subject changed meaning; every fix either updates a
stale incidental value or restores a test's own original isolation by
construction. No other test file's expectations changed.

## Full regression

```
tclsh9.0 tests/all.tcl
```

`tests/all.tcl` itself runs every `tests/*.test` file (80 files) under two
backends, `interp` and `compile` (its own header: `foreach backend {interp
compile}`; `cranelift`/`cranelift-generic` coverage is `tests/native-
coverage.tcl`'s own separate concern, plus whatever individual test files
-- including this milestone's own -- loop over all four backends
themselves). Run to completion after every production change in this
milestone was in place: **2274/2274 passing, 0 failed**, 80 test files
sourced. Both frozen benchmarks'
`interp`/`compile`/`cranelift-generic`/`cranelift` parity, and every
individual focused suite named above, were separately confirmed across all
four backends the corpus tool and this milestone's own new test file
exercise.

## GC-stress policy

Not run. This milestone's substantive diff is confined to
`hir/specialize.tcl`'s own static specialization-analysis layer (a new
closedness predicate and a bounded post-Fixpoint re-seeding pass); no
closure layout, rooting, retain/release placement, allocation site, stack
map, or GC-sensitive lowering rule was touched. `native/lower.tcl`'s own
20-line edit is pure option-threading (see "Outcome"/"Native lowering") --
mechanically identical in kind to the pre-existing `-call-facts-opt`
threading right next to it, never itself a Rust/runtime/codegen change;
`native/src/`, `hir/blockescape.tcl`, and `hir/escape.tcl` are all
byte-for-byte unmodified. Per the project's own stated policy (AGENTS.md),
a theorem-only implementation with this diff shape does not require it.

## Source-fence confirmation

`bench/*.bot`, `bench/*.ir`, and every file under `lib/` are byte-for-byte
unmodified (`git status`/`git diff` show no changes under those paths).
Every improvement measured in this report comes from the compiler alone,
against the exact same frozen source M7.a/M7.b measured.

## Residual first-loss matrix

| residual | category | why not closed by this milestone | recommended fix |
|---|---|---|---|
| `refined-checks.ir`'s `esc_from.text` (and the `UnknownCallResultKind` it feeds) | open instance | `web::uri_escape_text` reached only through the legacy `uriEscape` native-module-bridge binding in this one program; `hir::blockescape`'s own single-region candidate model has no notion of a module-native-bridge reference as an "exact call" | a bridge-aware ingress proof (teach `hir::blockescape`, or a sibling analysis, that a `-module-fn` native reference to a block with a *provably singleton* native symbol binding is itself exact) -- a real, separate, smaller milestone, not implied by anything this report found broken |
| `block e332`/`e552`'s own `v` parameter (`Emailish?` scanner bodies) | capture-derived / dead value, out of scope | zero exact callers (M7.a's own mechanism (e)); this milestone correctly refuses to fabricate a theorem for a zero-caller instance | dead-`fnvalue` elimination (M7.a's own recommendation, unchanged by this milestone) |
| exact-alias closedness (`alias = inner`) | scope limitation of the reused proof, not a guard regression in the frozen corpus | `hir::blockescape`'s own `RefsAsCalls` only recognizes a reference that is itself a call's callee; a plain alias bind is not | extend `hir::blockescape`'s own candidate model to treat an exact-alias bind (M2's own type-level identity) as transparent, if a future workload needs it -- no frozen-corpus guard depends on this today |

## Recommended next milestone

The bridge-aware ingress proof above is the only concrete remaining lever
on the frozen corpus (3 guards in `refined-checks.ir`, all traced to the
same root cause). Absent a new workload that needs it, the next milestone
should be chosen by auditing a *different* corpus/guard family (M7.a's own
residual matrix already names several: family 1a and other unrelated
guard families were explicitly out of this milestone's scope) rather than
chasing the last 3 guards of family 1b in one specific program's own
native-bridge shape.

---

## Required architecture questions

1. **What exact runtime object does M7.c call an "instance"?** The same
   object `hir::specialize` already calls one: an entry in
   `hir::specialize::analyze`'s own `instances` dict (`id block name args
   generic result seeds calls creates values edges overlay reachable
   passes`) -- a *compile-time* record of one region analyzed under one
   set of key facts, never a runtime object. M7.c adds no new kind of
   instance and no new field to this record that identity reads.
2. **What are all current ways that instance can be entered?** See
   "Current closure ingress mechanisms" above: direct call, `callenv`
   (never a dispatch-target reinterpretation), `callvalue`/dynamic
   dispatch, captured-and-forwarded (resolved at the use site), returned/
   stored (resolved at the next call), joined callable identity, and the
   module-native bridge. No native/FFI/event-loop/reflection callback
   ingress exists in this compiler today.
3. **What exact compiler fact proves no additional runtime ingress
   exists?** For a static block: absence from `hir::aot::
   materializedBlocks`'s own union across every used instance's reachable
   code. For a closure: `hir::blockescape`'s own `wants` (its
   `RefsAsCalls` greatest-fixpoint proof that every reference reduces to
   an exact call).
4. **Is closedness already represented by existing `OpenInstances`/escape
   state?** Half of it (the static-block half, the identical test,
   duplicated not imported). The closure half is not -- `OpenInstances`
   is empirically too coarse for it (see "Relationship to OpenInstances").
5. **If not, why is the new state distinct?** Because `hir::blockescape`'s
   proof examines individual *references*, where `materializedBlocks`
   only examines *bind sites* -- a strictly finer question that the coarse
   test cannot answer, by that function's own documented, correct,
   conservative design.
6. **At what compiler phase is the complete caller set known?** Only
   after `hir::specialize`'s own ordinary `Fixpoint` converges (every used
   instance's own `calls` map is final) *and* `hir::blockescape::analyze`
   has run over that final instance set.
7. **Can callers be discovered after instance analysis has begun?**
   During the *ordinary* Fixpoint, yes (that is what the fixpoint is for).
   During `CloseCallers`' own pass, no: `calls`/edges are frozen for the
   whole pass (see "Never creating a new instance or edge" in the source
   comment); only per-instance *facts* (overlay, result) still change,
   round over round.
8. **If yes, what fixpoint makes the theorem safe?** `CloseCallers`' own
   bounded, monotone round loop (see "Fixpoint / recursion handling"),
   which only ever narrows a seed type or widens a result via `lub` --
   never the reverse.
9. **If no, what ordering guarantees completeness first?** Closedness and
   the caller-fact scan both run strictly after the ordinary Fixpoint's
   own `Used()` (transitive closure from the program) has stabilized, so
   "every used instance" is already a complete, final set by construction
   before either ever runs.
10. **What is the exact family-1b first-loss point pre-M7.c?**
    `hir::specialize::Analyze`'s own parameter-seeding loop: for a generic
    instance of a value-capturing closure, the loop had exactly two
    sources (observed key, always `any`; declared theorem, always empty
    for family 1b's undeclared parameters) and neither ever supplied a
    fact -- so `types[$b]` stayed `any` unconditionally, identical to
    before M1 ever existed.

## Required identity questions

11. **Does `KeyType` change? Required: no.** Confirmed: zero lines of
    `KeyType` changed (`git diff`).
12. **Do any closure instance keys change? Required: no.** Confirmed by
    every `specLabels`/instance-count test in `tests/closed-closure-
    entry-facts.test`, and by the frozen-corpus instance counts (19/19,
    39/39) above.
13. **Does any target block gain extra specialized instances? Required:
    no.** Confirmed: identical instance counts before/after, both
    benchmarks; `Reanalyze`'s own `FrozenHandle` never calls `Instance`.
14. **Does caller-kind disagreement cause instance splitting? Required:
    no.** The mixed-kind fixture proves the opposite: disagreement widens
    the *theorem* to `any`; the instance stays the single `inner<generic>`.
15. **Does closedness affect identity? Required: no.** `InstanceClosed`
    is read-only over the already-finalized instance set; it writes
    nothing to `args`/`generic`/the `keys` cache.
16. **Does the caller theorem affect identity? Required: no.**
    `CombineCallerTheorem`'s output only ever feeds `Reanalyze`'s own
    local `types` dict, which is never written back to `instance args`.

## Required closedness questions

17. **What makes the primary positive instance closed?** It is a generic
    instance of a value-capturing closure whose only two references
    (`inner(1)`, `inner(2)`) both resolve, via `hir::blockescape`'s own
    `RefsAsCalls`, to exact calls of the one target instance.
18. **What makes the negative fixture open?** `inner` is passed as a
    plain value argument to `apply`, a reference `RefsAsCalls` cannot
    reduce to a call; `hir::blockescape` declines it, so `wants` is false.
19. **Does exact aliasing preserve closedness?** Currently, no (see
    "Alias/escape/capture controls" -- an honestly-reported architectural
    finding, not a forced "yes").
20. **Does escape destroy closedness?** Yes, confirmed directly
    (`open-instance-not-closed`).
21. **How are exact captured/forwarded callable identities counted?**
    Through `hir::blockescape`'s own "sibling reference" fixpoint: a
    capturing sibling closure's own reference counts, transitively,
    *if* the sibling is itself eligible (`captured-through-parent-both-
    closed`).
22. **How are `callvalue` edges handled?** Never routed through
    `hir::specialize::Handle` at all (see ingress table); such an edge can
    never contribute a caller fact, and its presence (via
    `hir::blockescape`'s own decline) is exactly what marks the target
    open.
23. **How are recursive self edges handled?** Participate in the caller-
    fact join like any other edge, except an *unchanged* self-forward
    position contributes nothing (would otherwise permanently poison the
    join at `any` -- see "Caller fact collection").
24. **Can a single existing instance still be open? Required: yes.**
    Confirmed: the negative/escape fixture's `inner<generic>` is exactly
    this.
25. **Can multiple exact callers still form one closed instance?
    Required: yes.** Confirmed: the primary positive fixture (two
    callers) and the multi-caller test (three).

## Required theorem questions

26. **What caller facts are joined?** Each exact call's own per-position
    argument `KeyType` (the same reduction identity itself uses).
27. **What join operation is used?** `hir::types::lub`, the same lattice
    join used throughout `hir/specialize.tcl`/`hir/types.tcl` elsewhere.
28. **Is the theorem per parameter? Required: yes.** Confirmed:
    `ClosedCallerFacts` returns one KeyType per parameter position, joined
    independently; `recursive-self-edge-closed-with-theorem` confirms two
    different parameters can resolve to facts derived from entirely
    different call-site evidence.
29. **Does it track only kind/type, or also Range where already
    available?** Only kind/type (`KeyType`-reduced). No Range-tracking
    code was added; where a caller's argument also carries a useful Range
    fact, that fact is not specifically preserved by this milestone (out
    of scope per spec item 15 -- the primary theorem needed to eliminate
    family-1b kind guards never required it).
30. **Can caller disagreement widen the theorem? Required: yes.**
    Confirmed directly (`closed-mixed-kind-closure-theorem-widens-to-any`).
31. **Can a newly discovered caller invalidate/narrow assumptions?
    Required: it must safely widen/invalidate.** `CloseCallers`' own round
    loop always recomputes `ClosedCallerFacts` fresh from the *current*
    `calls` graph (frozen) and *current* overlays (which only narrow), so
    a "newly discovered" caller within the same pass only ever widens the
    join, never narrows it unsoundly; a caller discovered by a *later*,
    separate `hir::specialize::analyze` call (a different program) simply
    re-derives everything from scratch, with no stale state carried over.
32. **Does zero callers produce arbitrary theorems? Required: no.**
    Confirmed directly (`zero-caller-instance-not-closed`): a zero-caller
    closure is not even closed, so no theorem is attempted at all.
33. **Is theorem provenance distinguishable from a declared theorem?
    Required: conceptually yes.** `hir::specialize::closedCallerTheorem`
    and `declaredParamType`-style direct HIR reads (as
    `tests/conjunctive-entry-facts.test`'s own `declaredParamType` proc
    does) are two entirely separate queries over two separate data
    sources (`ClosedCallerFacts`'s own derived join vs.
    `block.declaredParamTypes`); nothing merges them into one stored
    value.

## Required interaction questions

34. **How does the theorem combine with the instance's observed fact?**
    Via `CombineCallerTheorem`, applied to whatever `type` M1/M7.b's own
    combination already produced from the observed key (see "Combination
    semantics").
35. **How does it combine with a declared parameter theorem?** The
    declared branch runs first (unmodified); the caller-theorem branch
    runs second, on the declared branch's own output -- confirmed not to
    erase it (`declared-and-caller-theorem-coexist-declared-survives`).
36. **Can it erase observed emptiness? Required: no.** No family-1b
    parameter in this milestone's own scope is an aggregate with M7.a.a's
    own emptiness fact; `CombineCallerTheorem`'s own aggregate branch
    reuses the identical M7.b-extended `narrow`, whose bottom case
    (`narrow(never, X) = never`) is exactly what preserves emptiness there
    too, unchanged.
37. **Can it erase a declared refinement? Required: no.** Confirmed
    (`declared-and-caller-theorem-coexist-declared-survives`): the
    declared `List[Byte]` theorem survives unchanged.
38. **Can a declared theorem erase a stronger caller theorem?** Not
    observed to happen in this milestone's own scope: a declared theorem
    always runs *first*, and `CombineCallerTheorem`'s own `narrow`/
    adopt-outright logic only ever narrows further from whatever the
    declared branch left -- it cannot make the type broader.
39. **Does combination order matter?** Not for any construction this
    milestone's own tests exercise; see "Combination semantics".
40. **Is `narrow` sufficient for the supported facts? If yes,
    demonstrate.** Yes -- every combination in `CombineCallerTheorem`
    reuses `hir::types::narrow` (scalar case) or its M7.b-extended
    aggregate recursion; no new combinator was written.

## Required soundness questions

41. **Can an open caller be omitted from the theorem? Required: no.** An
    open *edge* (dynamic dispatch) can never contribute a fact in the
    first place (it never reaches `Handle`), so there is no "omission"
    question for it; what soundness actually requires -- and what this
    milestone delivers -- is that an *instance* reachable through any open
    edge is never itself treated as closed at all (`InstanceClosed`'s own
    closure branch fails the moment `hir::blockescape` finds one
    unaccounted reference).
42. **Can a closure escape and still be marked closed without an existing
    proof that all future ingress remains enumerable? Required: no.**
    Confirmed: the escape fixture (`apply(inner, 2)`) is `closed=0`.
43. **Can a source-untyped parameter become a source-level typed
    obligation? Required: no.** Confirmed directly
    (`untyped-parameter-declared-signature-unaffected`):
    `declaredParamTypes` for `inner`'s block stays empty.
44. **Can theorem inference reject a previously legal program? Required:
    no.** `CloseCallers` never calls `hir::Diagnose`/raises a static
    error; it only ever narrows an *internal* seed type used for
    `inferRegion`, which only produces *fewer* representation guards, not
    new rejections (confirmed: every fixture in this milestone's own test
    file, including the intentionally mixed-kind and open ones, compiles
    without error).
45. **Can failure to prove closedness change runtime behavior?
    Required: no.** An instance that fails to prove closed is simply
    never reanalyzed by `CloseCallers` (no entry in `facts`); its overlay/
    result are exactly what the ordinary Fixpoint already produced --
    identical to this milestone not existing at all, for that instance.
46. **Does the theorem introduce hidden checks? Required: no.** No new
    NIR op, blocker kind, or runtime check was added; guards only ever
    *disappear*, via `hir::aot::analyzeRegion`'s own unmodified `Require`.
47. **Does it remove guards only where existing analysis proves them
    redundant? Required: yes.** Every guard removal in this milestone's
    own measurements is a `hir::aot::Require`/`RepresentationBlockers`
    decision, made by exactly the same unmodified code M1/M7.b already
    rely on, once it is handed a stronger `hir::typeOf` fact through the
    overlay -- no special-cased "if closed then omit" rule exists.

## Required family-1b questions

48. **How many family-1b guards exist in the fresh post-M7.b census?**
    14 (`uri-steady`), 24 (`refined-checks`) -- unchanged from M7.a's own
    count, reconfirmed directly (see "Fresh family-1b guard census").
49. **How many occur in proven-closed instances?** 14 of 14
    (`uri-steady`); 21 of 24 (`refined-checks` -- all but `esc_from.text`
    (genuinely open in that specific program) and the two dead-`fnvalue`
    `block e332`/`e552` guards (zero exact callers, so `hir::blockescape`
    correctly declines them too)).
50. **How many receive a useful homogeneous caller theorem?** 14 of 14
    (`uri-steady`); **21 of 21** closed family-1b guards in
    `refined-checks` -- every closed instance's own theorem turned out
    useful; the 3 residuals are exactly the 3 guards that were never
    closed in the first place (confirmed: 24 total - 21 closed-and-
    resolved = 3 residual, matching the measured guard count exactly).
51. **How many guards disappear?** 14 of 14 (`uri-steady`, **100%**); 21
    of 24 (`refined-checks`, **87.5%** -- the 3 that remain are exactly
    the 3 never-closed guards above, not a shortfall of the theorem
    mechanism itself).
52. **For every residual family-1b guard, why does it remain?** Answered
    per-guard in "Family-1b production before/after"'s own classification
    above: one genuinely open instance (native-module-bridge ingress,
    `refined-checks.ir` only) and two zero-caller dead-value residuals
    (M7.a's own mechanism (e), explicitly out of scope).

## Required structural questions

53. **How many instances before/after?** 19/19 (`uri-steady`), 39/39
    (`refined-checks`) -- unchanged.
54. **How many Block allocations before/after?** 1/1 (`uri-steady`),
    2/2 (`refined-checks`) -- unchanged.
55. **Does the rejected 8001x allocation behavior remain absent?
    Required: yes.** Confirmed: 1, not 8001, for `uri-steady`.
56. **Machine bytes before/after?** 7055/5746 (`uri-steady`, **-18.6%**);
    16743/14898 (`refined-checks`, **-11.0%**).
57. **Guard count before/after?** 14/0 (`uri-steady`); 24/3
    (`refined-checks`).
58. **`call`/`callenv`/`callvalue` counts before/after?** `call`
    16/16 and `callenv` 1/1 (`uri-steady`); `call` 32/32, `callenv` 2/2,
    `callmulti` 12/12 (`refined-checks`) -- all unchanged (`callvalue`
    does not appear as its own NIR op in either program's own emitted
    code, before or after).
59. **Did closure environment ABI change? Required: no.** Confirmed:
    `closure`/`capture` NIR op counts unchanged (1/1, `uri-steady`; 2/2
    and 3/3, `refined-checks`); `native/lower.tcl`'s own only edit is
    option-threading (no lowering rule touched -- see "Outcome").
60. **Did RC behavior change? Required: no.** No retain/release-adjacent
    file (`native/src/runtime`, `hir/escape.tcl`, `hir/blockescape.tcl`)
    was touched; total allocation byte counts are identical before/after
    for both benchmarks, which would not hold if any retain/release
    placement had shifted allocation lifetime.

## Required M7.b drive-by questions

61. **Was M7.b's report corrected to distinguish persistent observed
    fact, persistent declared theorem, derived per-instance semantic
    view? Required: yes.** Done (see "M7.b drive-by documentation
    corrections").
62. **Does the report stop claiming a first-class general fact-product
    representation? Required: yes.** The added disclaimer sentence is
    verbatim what spec item 0 asks for.
63. **Does it state that `FactsSatisfiable` does not gate `Analyze`'s
    `narrow` combination? Required: yes.** Added verbatim, with the
    upstream/specialize/query architecture diagram.
64. **Is the upstream compatibility proof dependency documented near the
    Analyze branch? Required: yes.** The new source comment on `hir/
    specialize.tcl`'s own M7.b aggregate-seeding branch states it
    directly.
65. **Was no redundant production satisfiability check added? Required:
    yes.** Confirmed: `hir::range::FactsSatisfiable` is unmodified and
    uncalled from any new production code path in this milestone.

## Stop condition

All eighteen "implementation success" conditions (spec item 109) are met:
family 1b is freshly and exactly re-censused (14/24, unchanged from M7.a);
closedness has the precise two-branch compiler predicate above; complete
ingress is proven by reusing `hir::aot::materializedBlocks` and
`hir::blockescape`'s own eligibility fixpoint, not a new escape analysis;
proven-closed instances derive and apply caller-based entry facts; open
instances receive no theorem at all; entry theorems feed `Reanalyze`'s own
seeding step, one call site before `inferRegion`; existing guard machinery
(`hir::aot::Require`) removes the resulting guards unmodified; instance
keys, instance counts, and Block/allocation counts are all measured
byte-for-byte unchanged; caller disagreement widens (never splits);
declared and observed facts remain intact; no source-level legality rule
changed; the listed regression suites and this milestone's own new suite
all pass; the frozen source fence is intact; and the M7.b documentation
corrections are included as the required drive-by.
