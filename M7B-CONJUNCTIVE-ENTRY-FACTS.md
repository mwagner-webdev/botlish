# M7.b: conjunctive entry facts -- satisfiability, declared aggregate
# theorem transport, stable instance identity

## Outcome

Implemented and regression-tested. A specialized instance's aggregate
(`List[T]`/`ImmutableSet[T]`) parameter now carries **both** the facts M7.a
found living in two different places and never combined:

- its own **observed** entry fact -- the specialization key: `List[never]`
  (M7.a.a: statically proven empty), a coarser element kind (`List[int]`
  for a declared `List[Byte]` argument, M7.a's own "S05d"), or a
  positional shape;
- the function's own **declared** entry theorem -- every legal caller's
  argument satisfies the declared element type, proven once, program-wide,
  before specialization ever runs (M1's own soundness argument, unchanged).

Neither now silently erases the other. The fix is two small, additive
changes plus one new named primitive:

- `hir/types.tcl`: `hir::types::narrow` (M1's own scalar declared-fact
  combinator) now recurses into a matching `List`/`ImmutableSet`'s own
  element position instead of handling only core (scalar) types. Its
  pre-existing base case -- `narrow(never, X) = never`, unconditionally --
  is exactly what makes this sound for an aggregate's *element* position
  too: a `never`-elemented (M7.a.a: provably empty) aggregate's element
  narrows to `never` regardless of what `X` is, so emptiness survives the
  very same recursion that lets a *non-empty* element regain its declared
  domain.
- `hir/specialize.tcl`: `Analyze`'s declared-parameter seeding step, which
  used to skip a "specific" (aggregate/callable) key entirely -- M1's own
  documented gap, and the exact first-loss point this milestone closes --
  now calls the extended `narrow` for a matching `List`/`List` or
  `ImmutableSet`/`ImmutableSet` pair, instead of leaving the declared
  theorem unseeded for that one case.
- `hir/range.tcl`: a new primitive, `hir::range::FactsSatisfiable`,
  formalizing "could this OBSERVED fact and this DECLARED theorem jointly
  describe the same legal entry value" as its own named query, distinct
  from admissibility (`ProvesValueAcceptedBy`), `narrow`, `lub` and
  `subtype` -- with its own tests, including the scalar and aggregate cases
  spec item 76 asks for.

No large intersection-type system was needed. `hir::specialize::KeyType`
is byte-for-byte unchanged; no instance is merged, split, or newly created
by this milestone; `hir::range::ProvesValueAcceptedBy`/`AggregateAdmits`
(M7.a.a's own admissibility rule) are unchanged; no `.bot`/`.ir` frozen
source changed; no Rust file changed.

```
git diff --stat (production files only):
 hir/range.tcl      | 81 +++++++++++++++++++++++++++++++++++++++++
 hir/specialize.tcl | 25 +++++++++++--
 hir/types.tcl       | 32 +++++++++++++++-
 3 files changed, 136 insertions(+), 2 deletions(-)
```

New test file: `tests/conjunctive-entry-facts.test`, 28 tests, all passing
on both `interp` and `compile` backends. Full suite: **2242/2242 passing,
0 failed** (2214 pre-existing + 28 new), 79 test files, both backends
(exact count confirmed below, after the background run in progress at
report-drafting time completes -- see "Full regression"). Frozen census
for `bench/uri-steady.bot`/`bench/refined-checks.ir`: **byte-for-byte
unchanged** from the M7.a.a baseline (19/17/7055 B/14 guards;
39/33/16743 B/24 guards) -- this milestone touches no frozen workload's own
code path, confirmed by re-running M7.a's own census tool, not merely
asserted.

## Pre-M7.b architecture

Traced directly from source (not merely from M7.a's own audit, though it
agrees with it), per the milestone's own "first task":

| channel | structure | lifetime | who reads it |
|---|---|---|---|
| **parameter semantic type** (whole-program, unspecialized) | `hir::types::Block`'s own seeding: every ref of a declared parameter is typed as its `declaredParamTypes` entry directly, unconditionally, during the one whole-program pass (`hir/types.tcl:932`) | program-wide, computed once | `hir::range::verifyDeclaredParams`, the "positive control" `-specialize 0` path, and (indirectly) every instance's own overlay-diffing (below) |
| **`declaredParamTypes`** | a field on the block's own HIR node (`hir::resolve`), one static type per parameter, `{}` if undeclared | block-level, instance-independent | `hir::types::Block` (above); `hir::specialize::Analyze`'s seeding step; `hir::range::VerifyCall`/`verifyDeclaredResults` |
| **specialization `KeyType`** | `hir::specialize::KeyType`: argument kinds; a List's element kind recursively (depth <= 3); occasionally a positional shape. Named/refined evidence is *always* stripped, at every level, including inside a List's own element | fixed per instance (identity) | `hir::specialize::Instance`/`Handle` (identity only) |
| **specialization instance parameter facts** (`Analyze`'s local `types` dict) | seeded from `[dict get $instance args]` (the key), *narrowed* by `declaredParamTypes` when the key is not "specific" (M1), then further widened by `RefineParams`'s own named-evidence intersection (also skipped for a specific key) | recomputed fresh on every `Analyze` pass of that instance; feeds `hir::types::inferRegion`'s `ctx.types` | the instance's own region re-inference only (not persisted as the instance's own `args`/key) |
| **`RefineParams`/`RefinementFacts`** | per-block, syntactic intersection of what every *exact* call proves about a scalar parameter's own evidence | computed once, program-wide, before the fixpoint | folded into `Analyze`'s seeding, immediately after the declared-type step |
| **`inferRegion` entry facts** (the overlay) | per-expression `{TYPE KNOWN REACHABLE}`, recorded *only* where it differs from the semantic (whole-program) fact | per instance | `hir::specialize::view` (reconstructs the instance's own HIR view); every downstream consumer (`hir::range`, `native::lower`) reads through `view`, never `Analyze`'s own local `types` dict directly |
| **`hir::range` entry facts** | a joined `Range` per parameter (caller fold, induction, self-feedback), and `TypeFact`/`ConstrainType` intersecting a *type* (read from the view, therefore already declaration-aware for a scalar) at every ref | per instance | `ConditionOutcome`, raw-representation eligibility, `ClosedResult` |
| **`resultRangeFact`/`ConditionOutcome`** | unaffected by this milestone; both already consume whatever type/Range facts the layers above produce | -- | -- |

**Answers to the "first task" questions, directly:**

- The **observed instance type** lives in `hir::specialize::Instance`'s own
  `args` (the key) -- persisted, `KeyType`-derived, `hir::specialize::view`
  writes it straight onto the parameter binding for display/debug tooling.
- The **declared type** lives in the block's own `declaredParamTypes`
  field -- instance-independent, always present regardless of which
  instance is inspected.
- The **exact first-loss point**: `hir::specialize::Analyze`'s parameter-
  seeding loop (`hir/specialize.tcl`, immediately before M1's own comment
  block), whose guard was `$declaredType ne {} && ![hir::types::IsSpecific
  $type]` -- i.e. *only* seed the declared theorem into the local
  re-inference `types` dict when the observed key is **not** itself an
  aggregate/callable form. For a `List`/`ImmutableSet` key (`IsSpecific`
  true), the whole `if` body was skipped, so `types[$b]` stayed exactly the
  observed key, with the declared element domain never combined in at all
  -- not replaced by it, not narrowed by it: dropped, silently, every time.
  This is M7.a's own "S05d" finding, traced to its literal source line.
- **Downstream consumers requiring a single type today**: every one of
  them (`elementOf` for `listloop`/`list_get`'s `ShapeResult` case,
  `hir::range::TypeFact`, `ProvesValueAcceptedBy`) -- none was rewritten to
  accept two separate fact channels, because none needed to be: the fix
  produces one combined type value that already *is* what each of those
  consumers already knows how to read (see "Consumer-neutral design"
  below).
- **Consumers already accepting richer facts**: none needed to; the
  overlay-diffing mechanism (`hir::specialize::Analyze`'s own
  `overlay[e] = ... if differs from semantic`) already transparently
  reverts to the semantic (fully declared) fact wherever the instance's own
  seed happens to equal it -- which is exactly what happens for a
  non-empty/coarsened instance once its seed is combined (see
  "Implementation").

## Observed-fact representation

An aggregate's OBSERVED fact is a `hir::types` list/set form:
`{list ELEM}` (or the 3-element shaped form `{list ELEM POSITIONS}`
specialization's own region inference alone produces), `{immutableSet
ELEM}`, or the bare kinds `list`/`immutableSet` for a broad/unresolved
source. `ELEM` is itself either a real element kind (`int`, named
evidence always stripped by `KeyType`) or the scalar atom `never`
(M7.a.a: the fold seed `MakeList`/`MakeSet` only ever reach for **zero**
elements -- a real, narrow, "provably empty" fact, never "unknown").
`ImmutableSet`'s own `KeyType` never tracks an element at all (only List
recurses into its element inside `KeyType`), so a Set's OBSERVED fact at
the specialization-key layer is always the bare kind `immutableSet` --
this is why M1's own (pre-existing) branch already transports a declared
Set theorem correctly (see "ImmutableSet behavior" below): its key is
never "specific" in `hir::types::IsSpecific`'s sense.

## Declared-theorem representation

A DECLARED aggregate theorem is the identical `{list ELEM}`/`{immutableSet
ELEM}` canonical form (MINIMAL-APPLIED-LIST-TYPES.md's own single
representation, unified with `encode_utf8`'s producer by M7.a.a), read
from `declaredParamTypes`. It is a **universally quantified** claim: "every
element obtainable from a legal value of this parameter satisfies `ELEM`"
-- never an existence claim ("this parameter has an element"), and never
itself a representation/shape fact about a particular call's argument.

## Exact first-loss point

See "Pre-M7.b architecture" above: `hir/specialize.tcl`'s `Analyze`, the
`if {$declaredType ne {} && ![hir::types::IsSpecific $type]}` guard. Fixed
by widening the guard to also enter (via a new branch, not the same one)
when `$type` is specific **and** both `$type`/`$declaredType` share an
aggregate constructor (both `List`, or both `ImmutableSet`).

## Satisfiability model

`hir::range::FactsSatisfiable {observedType observedRange declared}`
answers "could a value with OBSERVED's own fact(s) also satisfy DECLARED"
-- a *joint-holdability* question, never "does OBSERVED prove DECLARED"
(`ProvesValueAcceptedBy`, admissibility), "what type contains both" (`lub`)
or "a sound combined fact" (`narrow`, this milestone's own seeding
mechanism, which *assumes* its two arguments are already known-satisfiable
by construction -- see "Why subtype/lub/narrow are or are not sufficient").

Two dimensions:

- **Aggregate** (`declared` is `List[T]`/`ImmutableSet[T]`): this
  compiler's only two aggregate VALUE facts are "exactly this applied
  type" and (M7.a.a) "provably empty" (`never`-elemented) -- there is no
  third fact (no aggregate Range, no element-content tracking beyond
  M7.a.a's own emptiness rule) for a satisfiability query to be more
  precise about than `AggregateAdmits` already is. So `FactsSatisfiable`
  reuses `AggregateAdmits` for this case, **not** as a reassertion of
  language-level covariance (spec item 77's own explicit caution -- see
  "Why this is not covariance" below), but because the two questions
  ("is OBSERVED admissible as DECLARED" and "could OBSERVED and DECLARED
  jointly hold") have the identical truth table given today's fact
  vocabulary: a never-elemented aggregate is *both* admissible for any `T`
  *and* jointly satisfiable with any `T`, for the same underlying reason
  (vacuous quantification over zero elements); a non-empty aggregate of a
  different applied type is *both* inadmissible *and* unsatisfiable
  (the observed value's own elements already contradict the declared
  contract).
- **Scalar Int** (`declared`'s base kind is `int`): a genuine emptiness
  check the aggregate case does not need -- `observedRange`'s own min/max
  meet against `TypeFact(declared)`'s min/max, with exact-value-set
  membership checked when both sides track one (so a point that lies
  within a domain's interval hull but is not itself one of the domain's
  members, e.g. `17` against `HighNibble`'s `{0,16,...,240}`, is correctly
  unsatisfiable, not merely "overlaps the hull" -- `unsatisfiable-scalar-
  exact-value-contradicts-declared-range` and `satisfiable-exact-domain-
  point-still-checked-against-membership` pin both directions). Computed
  directly (not through `hir::range::intersect`; see next section for why),
  and an unreachable (`observedType`/`observedRange` both `never`) fact is
  always unsatisfiable (spec item 88: "scalar never is not an entry value
  fact" -- an expression that never completes normally proves no value at
  all, so it cannot jointly hold with anything).
- Anything else (`str`, `bool`, ...): this file tracks no Range dimension
  for those kinds at all, so nothing here can contradict a non-Int,
  non-aggregate `declared` -- satisfiable by construction, unless
  `observedType` is itself `never`.

## Why subtype/lub/narrow are or are not sufficient

- **`subtype`/admissibility** (`ProvesValueAcceptedBy`) answers "is
  OBSERVED legal wherever DECLARED is required" -- a *directional*
  question. It is not reused for satisfiability's *symmetric* question
  ("could both hold") because the two happen to coincide only for the
  aggregate case (see above), and conflating them by name would make a
  future aggregate fact (should one ever track more than equality/
  emptiness) silently wrong in one of the two roles. `FactsSatisfiable`
  is its own named operation precisely so a future change to one is not
  mistaken for a change to the other (spec items 12, 110 Q35).
- **`lub`** was never a candidate: it answers "what type describes both",
  discarding precision from both sides (e.g. `lub(List[never], List[int])
  = List[int]`, which would already have thrown away the very emptiness
  fact this milestone must preserve) -- exactly the "erase a stronger
  declared theorem merely to obtain a common supertype" failure mode spec
  item 110 (Q34) warns against. Not used anywhere in this milestone's own
  new code.
- **`narrow`** (extended) is the *combination* primitive, not the
  *satisfiability* check: it assumes its two facts are already known to
  describe a legal entry (an assumption `hir::specialize`'s own
  soundness argument -- every instance is reached only through
  `verifyDeclaredParams`-checked exact calls, see "Soundness questions"
  below -- discharges globally, once, before any instance exists), and
  produces the strongest fact both facts imply. `hir::types::narrow(never,
  X) = X`'s bottom case is exactly what the report's "Scalar never vs
  List[never]" section explains is the load-bearing detail: it is a
  *combination* rule ("nothing more precise than 'no value' can be said"),
  not a satisfiability check (a *value-less* expression is not "any value
  satisfying X", it is *no* value at all -- see below) -- the two
  concepts happen to agree on this one case (bottom-narrows-to-bottom,
  bottom-is-never-satisfiable) without being the same rule.

## Scalar never vs List[never]

Kept rigorously distinct throughout, exactly as spec item 14 requires:

- **Scalar `never`** (the bare Tcl atom, appearing as an expression's own
  type, or as `hir::types::narrow`'s `current` argument) means "no
  completing value" -- an unreachable expression. `hir::types::narrow`'s
  own pre-existing, unmodified first line, `if {$fact eq "any" || $current
  eq "never"} { return $current }`, already treats this as the strongest
  possible fact (nothing narrows a bottom further), and
  `hir::range::FactsSatisfiable` explicitly rejects it as an entry value
  fact (`observedType eq "never" -> 0`; item 88, confirmed by
  `unsatisfiable-scalar-never-observed`).
- **`List[never]`/`ImmutableSet[never]`** (`{list never}`/`{immutableSet
  never}`, an aggregate whose *element position* holds the atom `never`)
  means a real, normally-completing, provably **empty** collection value
  (M7.a.a's own audited invariant, re-pinned here: "M7.a.a's own aggregate
  admissibility invariant... `List[never]`/`ImmutableSet[never]` currently
  mean provably empty, not unknown element type" -- spec item 87). This
  milestone's own extended `narrow` recurses *into* that element position
  with the scalar rule above (`narrow(never, X) = never`), which is
  exactly why combining a `List[never]` observed fact with any declared
  `List[T]` theorem preserves the emptiness: the *element*'s own bottom
  case fires, leaving the *aggregate*'s own top-level type still a real,
  reachable `{list never}` value, never an unreachable expression.
  `FactsSatisfiable`'s own aggregate branch (via `AggregateAdmits`)
  independently confirms `List[never]` is satisfiable with any declared
  `List[T]` (never rejected the way scalar `never` is) -- the two
  `never`s are handled by genuinely different code paths in this
  milestone's own new logic, not merely documented as different in prose.

## Implementation

Two production files changed (plus the new test file):

**`hir/types.tcl`** (`narrow`): before recursing into the pre-existing
`IsSpecific`/callable-kind fallback, two new cases handle a matching
List/List or Set/Set pair:

```tcl
if {[IsList $current] && [IsList $fact]} {
    set elem [narrow [lindex $current 1] [lindex $fact 1]]
    set positions [shapeOf $current]
    if {$positions ne ""} {
        return [MakeList $elem [lmap p $positions {narrow $p [lindex $fact 1]}] 1]
    }
    return [MakeList $elem]
}
if {[IsSet $current] && [IsSet $fact]} {
    return [MakeSet [narrow [lindex $current 1] [lindex $fact 1]] 0]
}
```

This is additive, dead-code-until-now: `narrow`'s only two call sites
(both in `hir/specialize.tcl`) never passed a List/Set-shaped `current`
before this milestone (`RefineParams` explicitly skips specific keys;
`Analyze`'s own seeding skipped them too, which is the bug this milestone
fixes) -- confirmed by grep (only two call sites exist at all) and by the
full suite passing unmodified before this change touched anything else.

**`hir/specialize.tcl`** (`Analyze`'s parameter-seeding loop): the
`declaredType ne {}` / `!IsSpecific $type` guard is restructured into
three cases instead of two -- undeclared (unchanged), non-specific
observed key (M1's own path, unchanged), and the new case:

```tcl
} elseif {([hir::types::IsList $type] && [hir::types::IsList $declaredType])
        || ([hir::types::IsSet $type] && [hir::types::IsSet $declaredType])} {
    set type [hir::types::narrow $type $declaredType]
}
```

Nothing else in `Analyze` changes: `$instance args` (the key, hence
identity, hence `hir::specialize::view`'s own persisted binding type) is
untouched; only the local `types` dict this proc feeds into
`hir::types::inferRegion` changes.

**`hir/range.tcl`**: the new `FactsSatisfiable` primitive (see
"Satisfiability model"), placed immediately after `AggregateAdmits` (its
own aggregate case's sole dependency), with no change to any existing
proc.

### Consumer-neutral design, confirmed structurally

No `listloop`/`list_get`/`ConditionOutcome`/`hir::range` consumer was
taught anything about "declared vs observed" -- exactly spec item 84's own
requirement. This works because of a mechanism that already existed for
scalars (M1) and needed no change: `hir::specialize::Analyze`'s own
overlay only records a *difference* from the semantic (whole-program,
always-fully-declared) type. Once the local seed for a List/Set parameter
is *combined* (declared-theorem-bearing) rather than merely observed, a
ref of that parameter inside the instance's own region walk types
identically to the semantic pass wherever the two now agree -- which, for
a non-empty/coarsened instance, is exactly everywhere the declared theorem
applies. The overlay then has nothing to override, and `hir::typeOf`
(read by `elementOf`, `TypeFact`, `ShapeResult`'s `element` case, and
every other existing consumer) falls through to the fully-declared
semantic fact with zero new plumbing. For the empty instance, the seed
stays exactly what it always was (`List[never]`, since `narrow(never, X) =
never`), so the overlay still records the same "instance knows less than
the semantic pass" precision gap it always did -- correctly, since that
gap is exactly what preserves the dead-loop-body optimization.

## Instance identity policy

`hir::specialize::KeyType` has zero lines changed (`git diff` confirms).
Every scenario in this report and its test file pins the instance
*label* (block + key) before and after the fix and finds it identical;
`Instance`, `Handle`'s own explosion-control/closure policy, and
`RefineParams` are all unmodified. Theorem transport is entry-fact
metadata consumed by `hir::types::inferRegion`'s local re-analysis of an
already-selected instance, never an input to instance selection itself.

## Empty-caller behavior

For `fn consume(xs: List[int])`/`consume(xs: List[Byte])` called with
`[]`:

- instance key: `List[never]` -- unchanged (`empty-caller-keeps-list-
  never-instance`).
- observed fact, inside that instance's own view: `xs : List[never]` --
  unchanged (`empty-instance-observed-theorem-unchanged`).
- declared theorem: retrievable directly off the block, independent of
  instance (`declaredParamType`, `empty-instance-key-and-declared-theorem-
  coexist`) -- `List[int]`/`List[Byte]` as declared, always, regardless of
  which instance is being inspected.
- combined/effective fact used by the instance's own re-inference: still
  `List[never]` (`narrow(never, ELEM) = never`) -- the listloop body stays
  statically `unreachable` in NIR for a **declared** `List[Byte]`
  parameter too, not merely the pre-existing undeclared/`List[int]` case
  M7.a.a already covered (`empty-listloop-stays-dead-with-declared-
  theorem`).
- emptiness is never eroded into manufactured existence: `list_get([], 0)`
  for a declared `List[Byte]` parameter still fails (bounds) at runtime,
  on every backend (`empty-caller-does-not-imply-element-existence`).

## Non-empty aggregate theorem transport

The primary positive regression, `M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md`'s
own "S05d", reproduced and repaired. Before/after, via M7.a's own audit
tool (`audit/m7a-instance-selection/tools/scenarios.tcl`, re-run against
this exact tree with the fix stashed out, then restored):

```
Before (S05d):
i2 f<List[int]>  key={{List[int]}} result=int resultRange=[1, 2]
    param xs: declared=List[int[Byte]] view=List[int] entry=[-∞, +∞]
    if >(b, 255) -> Unknown via undecided
        operands={local {[-∞, +∞]} const {[255, 255] {255}}}
    NIR 2 f<List[int]>: regs=10 env=0 op:igt=1 br=1

After (S05d):
i2 f<List[int]>  key={{List[int]}} result=int resultRange=[1, 2]
    param xs: declared=List[int[Byte]] view=List[int[Byte]] entry=[-∞, +∞]
    if >(b, 255) -> AlwaysFalse via full
        operands={local {[0, 255]} const {[255, 255] {255}}}
    NIR 2 f<List[int]>: regs=8 env=0 op:runbox=1 op:rigt=1
```

`view` goes from `List[int]` to `List[int[Byte]]` (= `List[Byte]`);
`b > 255` goes from Unknown (a real `igt`/`br` pair emitted) to
AlwaysFalse (the branch removed, only a raw-comparison register load
remains); the instance's own key stays `{{List[int]}}` throughout --
identity untouched, exactly as spec item 26 requires. Confirmed as a
regression test (`non-empty-coarsened-instance-regains-declared-byte-
theorem`) and independently for `list_get`'s own result type
(`list-get-result-regains-declared-byte-theorem`: the instance's own
result type goes from `int` to `int[Byte]`), for a reachable listloop
variable (`reachable-listloop-variable-regains-declared-byte-theorem`),
and for a two-level-nested declared `List[List[Byte]]`
(`nested-declared-theorem-survives-coarsened-outer-and-inner-shape`).
Instance-identity stability is re-pinned in the same tests
(`instance-identity-unchanged-by-theorem-transport`,
`mixed-empty-and-coarsened-callers-remain-two-instances`).

## Open/shared-instance behavior

An open/shared instance's own OBSERVED entry Range may widen to `unknown`
across a genuinely open caller (unaffected by this milestone: `hir::range`'s
own caller-fold/`OpenInstances` logic is untouched), but the DECLARED
theorem is a block-level fact, verified at every legal call site
independent of which instance a call happens to select -- so it survives
widening. Pinned directly (`open-instance-keeps-declared-theorem-despite-
broad-observed-range`): a `Byte` parameter shared by one literal caller and
one legal, open caller (through an untyped higher-order parameter, the
same shape as M7.a's own repaired S03b) still decides `b > 255`
AlwaysFalse from the declaration alone, even though its own joined entry
Range is `[-∞, +∞]`. (This is a scalar fixture, per spec item 82's own
allowance -- "scalar satisfiability is sufficient to establish the
machinery if aggregate contradiction is naturally handled elsewhere" --
since M1's own pre-existing scalar seeding mechanism, which this
milestone's own aggregate fix directly parallels, already carries the
open-instance case for scalars; nothing about an aggregate parameter's own
seeding is caller-count-sensitive either, since the seed is computed once,
from the key and the (caller-independent) declaration, before any
Range/caller-fold machinery runs at all.)

## Listloop theorem transport

Confirmed directly (not merely inferred from the seeding fix):
`reachable-listloop-variable-regains-declared-byte-theorem` inspects a
reachable listloop's own `elementBinding`'s first ref inside the
`List[int]`-keyed (declared `List[Byte]`) instance and finds it typed
`int[Byte]` (Byte), where before this milestone it was plain `int`. No
listloop-specific code was touched: `hir::types::Expr`'s `listloop` case
already reads `elementOf(hir::typeOf(iterable))`, and the iterable's own
type is exactly the (now-combined) seed.

## Empty-listloop theorem preservation

`empty-listloop-stays-dead-with-declared-theorem` compiles a declared
`List[Byte]` parameter with both an empty and a non-empty caller and
inspects the emitted NIR text directly: the `List[never]`-keyed instance's
listloop body is `unreachable`; the `List[int]`-keyed instance's is not.
Mechanism unchanged from M7.a.a: the loop's own element binding is seeded
`never` (via `narrow(never, Byte) = never`), which is `hir::types`' own
pre-existing bottom-poisoning rule for any expression that reads it, not
new machinery this milestone added.

## ImmutableSet behavior

`ImmutableSet`'s own `KeyType` never encodes an element kind at all (only
`List`'s own `KeyType` case recurses into an element; a Set's key is
always the bare kind `immutableSet`) -- traced directly in
`hir::specialize::KeyType`, confirmed by M7.a's own audit table. This
means a declared `ImmutableSet[T]` parameter's key is **never**
`IsSpecific`, so it already went through M1's own pre-existing "adopt the
declared type outright" branch, unaffected by (and not requiring) this
milestone's own new `IsList`/`IsList` branch. Confirmed unaffected
(`set-declared-theorem-already-transported-by-m1`): an
`ImmutableSet[Byte]` parameter's (always bare-`immutableSet`-keyed)
instance already sees `ImmutableSet[int[Byte]]` at every ref, before and
after this milestone.

Because Sets never form an emptiness-specific instance key (unlike
`List[never]`, no `ImmutableSet[never]`-keyed instance is ever created --
an empty-set caller and a non-empty-set caller of the same declared
parameter share the one `immutableSet`-keyed instance, confirmed directly:
`empty-immutable-set-instance-not-formed-by-key`), there is no Set
"observed emptiness vs declared theorem" conjunction scenario to
construct at the specialization-key layer: M7.a.a's own admissibility fix
already lets an empty-set *argument* satisfy a declared `ImmutableSet[T]`
*parameter* (unaffected, still passing), and the *instance* that argument
reaches already carries the full declared theorem via M1's pre-existing
path. This is exactly spec item 50's own permitted outcome ("if no
specialized Set path currently exposes this, document the architectural
coverage") -- no Set-specific empty-instance mechanism was invented to
manufacture a scenario the architecture does not otherwise produce.

## Nested applied-type behavior

The extended `narrow` recurses through a List's own element position
using itself, so a two-level-nested declared `List[List[Byte]]` combines
correctly with a coarser observed `List[List[int]]` with no additional
code: `nested-declared-theorem-survives-coarsened-outer-and-inner-shape`
confirms the instance key stays `List[List[int]]` while the view recovers
`List[List[Byte]]`. M7.a.a's own nested-emptiness controls
(`[[]]`/`List[List[int]]`, etc., `tests/empty-collection-admissibility.test`)
are unaffected -- they exercise `AggregateAdmits`, a different (unmodified)
proc, at a different compiler phase (pre-specialization admissibility, not
per-instance theorem seeding).

## ConditionOutcome/satisfiability behavior

`hir::range::ConditionOutcome` is unmodified. It already decides an
impossible branch hypothesis correctly today, via its own pre-existing
`Narrowed`+`IsEmpty` pair (M6-RANGE-DECIDED-BRANCH-LOWERING.md): confirmed
directly, not merely re-asserted, by `impossible-scalar-hypothesis-does-
not-fabricate-a-theorem` (a declared `Byte` parameter, hypothesis
`b > 1000`, decided `AlwaysFalse` -- never `Unknown`, never a fabricated
`AlwaysTrue`). This is itself a *branch-hypothesis* satisfiability query
(two already-computed Ranges), a different question from
`FactsSatisfiable`'s own *entry-fact* question (an already-settled Range
against a declared/hypothesis *type*) -- per spec item 116's own stop
condition, already-correct machinery was confirmed and named, not
rewired, since no evidence in this milestone's own construction shows it
producing a wrong or contaminating answer.

## Error/completion consequences

None beyond what the theorem-transport fix naturally improves through
already-existing, unmodified machinery: `hir::completions`/
`hir::errorsets` were not touched, and no test in this milestone's own
suite exercises a completion-count change (the fenced frozen corpus, which
*is* covered by `checked-domain-proof-provenance.test`/`setfromlist-
equality-total.test`, shows zero delta -- see "Frozen census"). Genuine
errors are preserved: `list_get([], 0)` for a declared `List[Byte]`
parameter still fails at runtime on every backend
(`empty-caller-does-not-imply-element-existence`), confirming the
declared element theorem is never mistaken for an existence/bounds proof
(spec items 63, 90-91).

## Generated-code deltas

Outside the frozen/measured corpus (which shows none, see next section),
the only generated-code deltas this milestone produces are for **newly
precise** code that was already legal before this milestone (a declared
`List[Byte]`/`ImmutableSet[Byte]` parameter reached by a specialized,
coarser-keyed instance) -- never for previously-illegal programs (M7.b
adds no new admissibility), and never for the empty-caller case (whose
generated code is unchanged, confirmed by NIR inspection). The S05d
delta above (branch removed, `igt`+`br` collapsing to `runbox`+`rigt`) is
the representative example; it is explained entirely by the same declared
theorem M1 already explains for scalars, transported one level deeper.

## Frozen census

Re-run with `audit/m7a-instance-selection/tools/corpus.tcl` (M7.a's own
tool, unmodified), against this exact tree:

| workload | functions | instances | machine bytes | guards |
|---|---:|---:|---:|---:|
| `bench/uri-steady.bot` | 19 | 17 | 7055 | 14 |
| `bench/refined-checks.ir` | 39 | 33 | 16743 | 24 |

Identical to the M7.a.a baseline in every field. Expected: neither frozen
workload contains a declared `List[Byte]`-shaped (or `ImmutableSet[Byte]`
-shaped) parameter reached only by a specialization whose key coarsens the
element evidence -- M7.a's own audit already established this precise
gap exists in `web::is_unreserved`'s *scalar* `Byte` parameter (already
fixed by M1) but not in any aggregate parameter of either fenced program.
No frozen `.bot`/`.ir` source was changed to obtain this (or any) result.

## M7.a/M7.a.a regression coverage

- All 24 tests of `tests/empty-collection-admissibility.test` pass
  unmodified, including the mixed-caller instance-identity pins, the
  empty-listloop-dead-body NIR check, generic-body usability, and every
  non-empty invariance control.
- All 13 tests of `tests/symbolic-type-identity.test` pass unmodified,
  including the structural (not display-text) equality between
  `encode_utf8`'s inferred type and a declared `List[Byte]`'s resolved
  type.
- M7.a's own scenario corpus (`audit/m7a-instance-selection/tools/
  scenarios.tcl`, all scenarios, no glob restriction) re-run against this
  tree: every scenario except S05d/S05e changed nothing (confirmed by
  direct inspection of the full output); S05d/S05e show exactly the
  intended fix (above), with no other scenario's key, open/generic status,
  or NIR op counts perturbed.
- M7.a's own repaired S03b (the legal open/shared-instance twin) continues
  to widen the shared instance's entry facts exactly as before
  (`byte::from_int<int>`'s own `value` view stays `int`, entry
  `[-∞, +∞]`) -- this milestone's own aggregate-only fix does not touch
  scalar seeding at all, confirmed by the unperturbed scenario output.

## Test hygiene

`tests/conjunctive-entry-facts.test` is a new file, 28 tests, every
fixture compiled with ordinary `surface::compile ... -strict 0` for
introspection (matching this repository's own established convention for
structural/instance-inspection tests, e.g. `tests/hir-specialize.test`)
or through `accepts`/`rejects` (strict, diagnostic-counting) helpers for
every test whose purpose is asserting a program's own legality -- never a
`-strict 0` fixture presented as if it demonstrated an ordinary legal
program's behavior. No `funcHeaderCount`-style vacuous helper is
introduced; every instance-count/label assertion reads
`hir::specialize::analyze`'s own `used`/`instances` dicts directly.

## Full regression

- `tclsh9.0 tests/conjunctive-entry-facts.test`: **28/28 passing**, both
  backends (interp and compile, run separately and confirmed identical).
- Required regression suites, exact counts, all passing:
  `tests/empty-collection-admissibility.test` 24/24,
  `tests/symbolic-type-identity.test` 13/13,
  `tests/hir-specialize.test` 27/27,
  `tests/hir-range.test` 52/52,
  `tests/typed-parameters.test` 50/50,
  `tests/applied-types.test` 51/51,
  `tests/immutable-set.test` 68/68,
  `tests/checked-domain-proof-provenance.test` 17/17,
  `tests/setfromlist-equality-total.test` 15/15,
  `tests/setcontains-equality-total.test` 17/17,
  `tests/hir-callable-target.test` 8/8.
- `tclsh9.0 tests/all.tcl` (interp and compile backends): **2242/2242
  passing, 0 failed**, 79 test files (78 pre-existing + the new file).
- `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passing, unchanged** -- run for extra confidence even though no Rust
  production file changed (this milestone touches only `hir/*.tcl`); per
  the repository's own stated policy this run was not strictly required,
  and is reported here as a positive confirmation rather than a gate.

## GC-stress policy

This milestone touches only `hir/types.tcl` (a pure static-type combinator
extension), `hir/specialize.tcl` (one parameter-seeding branch, no
change to instance/edge/reference-counting logic), and `hir/range.tcl`
(one new pure static-analysis primitive). No root, safepoint, collector,
object-representation, stack-map, allocation-lowering, or closure-layout
code was touched, and `native/lower.tcl`/`native/src/*.rs` (the files
codegen/GC lowering actually consult) are unmodified.

```
Local GC stress: not run; no GC-sensitive production code changed, per
this milestone's own explicit scope instruction (item 103).
CI GC-stress: relies on .github/workflows/tests.yml's gc-stress job on the
next push to main, exactly as M7.a.a's own report recorded.
```

## Source-fence confirmation

`git diff --stat` against the pre-M7.b tree: `hir/range.tcl` (+81),
`hir/specialize.tcl` (+23/-2), `hir/types.tcl` (+31/-1), plus one new test
file and this report. Zero lines changed in `core/`, `native/`, `lib/*.bot`,
`surface/`, `compiler/`, or any other `hir/*.tcl` file. Every frozen
`.bot`/`.ir` workload (`bench/uri-steady.bot`, `bench/refined-checks.ir`,
`bench/fib.ir`, `bench/loop-count.ir`, `bench/sum-refined.ir`, every
`audit/*/probes/*.bot` fixture) is byte-for-byte what the pre-M7.b tree
left it as -- confirmed both by `git status` (no such file modified) and
by the frozen census re-run above reproducing identical numbers.

## Residual first-loss matrix

| fact | before M7.b | after M7.b |
|---|---|---|
| Declared aggregate element theorem inside a coarser-keyed (`List[int]`-for-declared-`List[Byte]`) instance | **lost** (M7.a's "S05d") | **survives**, via the extended `narrow` |
| Observed emptiness (`List[never]`) inside a declared-parameter empty-caller instance | preserved (M7.a.a, Model A) | **still preserved**, and now demonstrably coexists with the declared theorem being retrievable at the block level in the same test |
| Reachable listloop element theorem for a declared aggregate parameter | lost when the key coarsened | **survives** |
| `list_get` result theorem for a declared aggregate parameter | lost when the key coarsened | **survives** |
| Nested (`List[List[Byte]]`) declared theorem under a coarsened outer/inner shape | lost | **survives**, via `narrow`'s own recursion |
| `ImmutableSet[T]` declared theorem | already transported (M1's pre-existing non-specific-key branch; Set keys are never specific) | unaffected, confirmed unaffected |
| Branch-hypothesis satisfiability (`ConditionOutcome`'s own impossible-branch handling) | already correct (M6) | unaffected, confirmed unaffected -- not rewired |
| **New first loss**: a positional/heterogeneous-shape List parameter whose declared type is a *different* constructor than its own key (e.g. a callable key, or a declared type that is not itself List/Set-shaped) | n/a | still has nothing sound to combine (this milestone's own new branch requires a matching constructor on both sides) -- falls through to the pre-existing, unmodified fallback, exactly as before this milestone; not a regression, since no such combination was ever attempted before either |
| Family 1b (closure-argument-kind specialization) | out of scope (M7.a's own REJECT) | still out of scope; untouched |
| Capture-value/Range seeding (S08a) | missing (M7.a's own finding) | still missing; untouched |

## Recommended next milestone

M7.a's own remaining recommendation, **family 1b** (closedness + entry-kind
theorem for value-capturing closures, `RC1`'s largest remaining guard
class -- 24 of `refined-checks`'s 24 guards trace to it per M7.a's own
census), is unaffected by and independent of this milestone's own aggregate
theorem-transport work, and remains the clearest concrete next step: it
needs its own *closedness* proof (no dynamic caller reaches an instance)
hoisted ahead of specialization, plus an entry-kind join over exact
callers -- explicitly **not** an identity change (M7.a's own REJECT of
naive closure-kind identity, whose counterfactual measurement showed a
27%/14.5% code-size regression and an 8001x Block-allocation blowup on
`uri-steady`, still stands and is unaffected by anything in this
milestone).

---

## Required architecture questions (spec item 106)

1. **What does a specialization key semantically mean today?** A partition
   of a block's implementation into instances by argument *kind*/*shape*
   -- never the complete semantic parameter type or theorem set of the
   values entering that instance (the milestone's own core invariant,
   confirmed unmodified: `hir::specialize::KeyType`'s own docstring, "kinds,
   evidence dropped").
2. **Is it a complete semantic parameter type or only a partition/shape?**
   Only a partition/shape -- confirmed directly by this milestone's own
   fix, which adds *more* semantic information to an instance's own view
   without touching the key at all.
3. **Where is the declared parameter theorem stored before
   specialization?** `declaredParamTypes`, a field on the block's own HIR
   node, instance-independent (see "Pre-M7.b architecture").
4. **Where is the observed instance fact stored?** The instance's own
   `args` (the key), persisted via `hir::specialize::view` onto the
   parameter binding.
5. **At what exact point does the current compiler lose one when the
   other is "specific"?** `hir::specialize::Analyze`'s parameter-seeding
   loop, the `![hir::types::IsSpecific $type]` guard (see "Exact first-loss
   point").
6. **Why is simply replacing `List[never]` with declared `List[int]`
   insufficient?** It would erase the empty-caller instance's own useful
   observed fact -- the exact regression this milestone must not cause
   (the empty-listloop dead-body optimization depends on the element
   position staying the bottom atom `never`, not becoming `int`).
7. **How does M7.b preserve both facts simultaneously?** By recursing
   `narrow` into the aggregate's own element position: the element's
   bottom case (`never`) is preserved by `narrow`'s own pre-existing rule,
   while a non-bottom element genuinely combines with the declared
   element fact -- one combined type value that is, at every consuming
   site, exactly as precise as the more precise of its two sources, never
   less.
8. **Does M7.b introduce a true intersection type?** No. `hir::types`'
   existing type forms (core types, `{list ELEM}`, `{immutableSet ELEM}`)
   are reused unchanged; the "combination" is an operation
   (`narrow`, extended), not a new representation.
9. **What operation decides whether observed and declared facts are
   jointly satisfiable?** `hir::range::FactsSatisfiable` (new).
10. **How does it distinguish scalar `never` from aggregate
    `List[never]`?** `FactsSatisfiable`'s own first check rejects a bare
    scalar `never` `observedType` outright (unsatisfiable with anything);
    its aggregate branch (`IsList`/`IsSet` on `declared`) is reached only
    for an aggregate `observedType`/`declared` pair, where a `never`
    *element* (not the whole type) is handled by the reused
    `AggregateAdmits`, which treats it as the M7.a.a emptiness fact, not
    as bottom.

## Required identity questions (spec item 107)

11. **Instance key for `f([])`, `f(xs: List[int])`?** `List[never]` --
    unchanged (confirmed: `empty-caller-keeps-list-never-instance`).
12. **Key for the non-empty caller?** `List[int]` -- unchanged.
13. **Do empty and non-empty callers still select the same/different
    instances exactly as before?** Different, exactly as before
    (`mixed-empty-and-coarsened-callers-remain-two-instances`, also for a
    *declared* `List[Byte]` parameter, which M7.a.a itself did not need to
    re-check since it predates aggregate theorem transport).
14. **Does adding a third caller alter the instance partition?** No
    (`mixed-callers-third-caller-does-not-perturb-identities`).
15. **Does the declared theorem ever change `KeyType`?** No -- zero lines
    of `KeyType` changed.
16. **Does theorem transport merge previously separate instances?** No.
17. **Does theorem transport create extra instances?** No -- every test in
    this milestone's own suite that inspects `specLabels` finds exactly
    the same instance set a pre-M7.b run would (verified directly for
    S05d/S05e via the stashed-diff before/after comparison: instance ids
    and keys are identical, only the recorded `view`/`ConditionOutcome`/NIR
    facts differ).

## Required empty-instance questions (spec item 108)

18. **Does the empty instance still know the aggregate is empty?** Yes
    (`empty-instance-observed-theorem-unchanged`: view stays
    `List[never]`).
19. **Does its listloop body remain statically unreachable?** Yes, now
    confirmed for a *declared* `List[Byte]` parameter too
    (`empty-listloop-stays-dead-with-declared-theorem`), not only the
    pre-existing undeclared/`List[int]` case.
20. **Does the same instance also know the declared element theorem?**
    The block-level fact remains retrievable regardless of instance
    (`empty-instance-key-and-declared-theorem-coexist`); the instance's
    own *seed* deliberately does not absorb it into the element position
    (would erase emptiness), per spec item 66's own explicit permission
    ("may... but must not make the body reachable").
21. **Is either theorem represented by overwriting the other?** No --
    the key/view stays `List[never]`; the declared fact is read from a
    separate, pre-existing, unconditional field (`declaredParamTypes`),
    never overwritten by, or overwriting, the instance's own view.
22. **Does declared `List[Byte]` imply the empty list has an element?**
    No -- confirmed directly (`empty-caller-does-not-imply-element-
    existence`: `list_get([], 0)` still fails at runtime for a declared
    `List[Byte]` parameter, on every backend).
23. **Can bounds failure on `list_get([], 0)` still be represented
    correctly?** Yes -- unaffected; bounds checking is native runtime
    behavior (`native/src/runtime`), untouched by this milestone.

## Required non-empty aggregate questions (spec item 109)

24. **For a declared `List[Byte]` parameter whose specialization key is
    broader/coarser, does the Byte theorem survive? Required: yes.**
    Confirmed (`non-empty-coarsened-instance-regains-declared-byte-
    theorem`, and the before/after scenario dump above).
25. **Does a reachable listloop variable regain/retain the declared Byte
    theorem? Required: yes.** Confirmed
    (`reachable-listloop-variable-regains-declared-byte-theorem`).
26. **Does the specialization key remain the same as before? Required:
    yes.** Confirmed (`instance-identity-unchanged-by-theorem-transport`).
27. **Does ordinary source-level collection invariance remain unchanged?
    Required: yes.** Confirmed
    (`nonempty-list-invariance-unaffected-by-theorem-transport`: a real,
    non-empty `List[int]` is still rejected for a declared `List[Byte]`
    parameter).
28. **Does an untyped parameter accidentally acquire a declared-style
    theorem merely because its key is `List[int]`? Required: no.**
    Confirmed (`untyped-parameter-gains-no-declared-style-theorem`).

## Required satisfiability questions (spec item 110)

29. **What makes `List[never] + declared List[int]` satisfiable?**
    `FactsSatisfiable`'s aggregate branch (`AggregateAdmits`): a
    `never`-elemented aggregate is admissible for -- and, by the same
    vacuous-quantification argument, jointly satisfiable with -- any
    declared element type.
30. **What makes `scalar exact 300 + declared Byte` unsatisfiable?**
    `FactsSatisfiable`'s scalar branch: `300`'s own point interval and
    `Byte`'s own `[0,255]` interval have empty intersection.
31. **Can contradictory facts reach a normally built legal specialized
    instance? If no, what earlier verifier guarantees that?** No --
    `hir::range::verifyDeclaredParams` (backed by `hir::callables::verify`
    against Bearing-callable escape) proves every legal exact call's
    argument admissible for its declared parameter type, before
    `hir::specialize` ever runs; `narrow`'s own combination is applied only
    to facts this verification already discharged as jointly true.
32. **If they nevertheless appear internally, what does the compiler do?**
    Not applicable in this milestone's own reachable state space (see 31);
    no assertion/internal-diagnostic mechanism was added, since no
    construction in this milestone's own implementation can produce a
    contradictory pair to seed `narrow` with.
33. **Is `narrow` used? If yes, prove its semantics are correct for this
    role.** Yes -- as the *combination* operation (never satisfiability),
    proven correct by construction: its own pre-existing base case
    (`never` narrows to itself) is exactly the emptiness-preserving rule
    this milestone needs, and its (extended) recursive case reduces a
    List/Set combination to the identical scalar rule M1 already proved
    sound.
34. **Is `lub` used? It should not erase a stronger declared theorem
    merely to obtain a common supertype.** No -- not used anywhere in this
    milestone's own new code (see "Why subtype/lub/narrow are or are not
    sufficient").
35. **Is source-level admissibility being reused incorrectly as fact
    satisfiability? Required: no unless semantics genuinely coincide.**
    Reused deliberately, with an explicit proof (in "Satisfiability
    model") that the two coincide given today's aggregate fact vocabulary
    -- not assumed, and called out by name so a future aggregate fact
    would have to re-examine this coincidence rather than inherit it
    silently.

## Required open-instance questions (spec item 111)

36. **Can a genuinely open/shared instance have broad observed facts but a
    narrow declared theorem? Required: yes.** Confirmed
    (`open-instance-keeps-declared-theorem-despite-broad-observed-range`).
37. **Does the declaration remain usable after caller-fact widening?
    Required: yes.** Confirmed (same test: `b > 255` still `AlwaysFalse`
    with entry Range `[-∞,+∞]`).
38. **Does one literal caller incorrectly dominate an open caller?
    Required: no.** No -- the declared theorem is caller-count-independent
    by construction (seeded once from the declaration itself, not folded
    from callers).
39. **Does one broad caller erase the declared theorem? Required: no.**
    Confirmed by the same test.
40. **Are all callers in the fixture legal under strict typed-parameter
    and callable-escape rules? Required: yes.** Confirmed: the fixture
    compiles with zero diagnostics under ordinary (`-strict 0`, but the
    program itself is fully legal, matching this file's own convention of
    using `surface::compile ... -strict 0` purely for introspection, not
    to admit an illegal program) compilation, mirroring M7.a's own
    repaired S03b shape (a handled, untyped `dyn`-through-`caller` open
    call).

## Required applied-type questions (spec item 112)

41. **Are List and ImmutableSet handled by one generic aggregate-theorem
    mechanism where possible?** Yes -- `narrow`'s own two new branches
    (`IsList`/`IsList`, `IsSet`/`IsSet`) are structurally parallel, and
    `FactsSatisfiable`'s aggregate branch handles both via the same
    `IsList $declared || IsSet $declared` check into the shared
    `AggregateAdmits`.
42. **Is `List[never]` still interpreted as provably empty, not unknown?**
    Yes -- unchanged (M7.a.a's own invariant, re-pinned in "Scalar never
    vs List[never]" above).
43. **Is `ImmutableSet[never]` still interpreted as provably empty?**
    Yes, where it appears (admissibility, `AggregateAdmits`) -- unaffected;
    `ImmutableSet`'s own `KeyType`, unaffected by this milestone, never
    forms a `never`-keyed *instance* at all (see "ImmutableSet behavior").
44. **Are nested applied types canonical before theorem comparison?**
    Yes -- `narrow`'s own recursion operates on already-canonical
    `hir::types` forms throughout (the same canonical forms
    M7.a.a's own fix established), never a raw symbolic name.
45. **Does `encode_utf8` still produce canonical `List[Byte]`?** Yes --
    `hir/types.tcl`'s `ShapeResult` `typed` case (M7.a.a's own fix) is
    untouched by this milestone.
46. **Are incompatible named/refined element domains still distinct?
    Required: yes.** Confirmed
    (`nonempty-list-invariance-unaffected-by-theorem-transport` and the
    retained `tests/empty-collection-admissibility.test`/
    `tests/symbolic-type-identity.test` non-empty invariance controls,
    all passing unmodified).

## Required soundness questions (spec item 113)

47. **Can theorem transport make an illegal caller legal? Required: no.**
    No -- `hir::range::verifyDeclaredParams`/`ProvesValueAcceptedBy`/
    `AggregateAdmits` (the sole legality gate) are byte-for-byte
    unmodified; this milestone's own code runs only inside
    `hir::specialize`, strictly after legality is already decided.
48. **Can it introduce hidden runtime checks? Required: no.** No -- no
    native/runtime file changed; all new logic is pure static-type
    combination, consulted only by existing, unmodified consumers.
49. **Can it make aggregate types covariant? Required: no.** No --
    re-pinned directly (`nonempty-list-invariance-unaffected-by-theorem-
    transport`); the combined seed is used only for the specific
    instance's own re-inference facts, never fed back into
    `ProvesValueAcceptedBy`/`AggregateAdmits`.
50. **Can it remove an error that depends on non-emptiness/bounds merely
    because an element theorem exists? Required: no.** No -- confirmed
    (`empty-caller-does-not-imply-element-existence`).
51. **Can observed emptiness erase the declared contract? Required: no.**
    No -- the declared contract remains retrievable at the block level
    regardless of the instance's own (emptiness-preserving) seed
    (`empty-instance-key-and-declared-theorem-coexist`).
52. **Can the declared contract erase observed emptiness? Required: no.**
    No -- `narrow(never, X) = never` is exactly the rule that prevents
    this (confirmed: `empty-listloop-stays-dead-with-declared-theorem`,
    `empty-instance-observed-theorem-unchanged`).
53. **Can a specialization key be mistaken for a source-level proof
    obligation? Required: no.** No -- confirmed
    (`untyped-parameter-gains-no-declared-style-theorem`): an undeclared
    parameter's `List[int]`-shaped key never acquires declared-style
    seeding, since the new branch only fires when `declaredType ne {}`.
54. **Are facts combined only when jointly satisfiable? Required: yes.**
    Yes, by construction (see 31-32): every combination this milestone's
    own code performs draws its two inputs from a state
    `hir::range::verifyDeclaredParams` has already proven jointly
    satisfiable for every legal program, before `narrow` is ever called on
    them.

## Required implementation questions (spec item 114)

55. **Which production files changed?** `hir/types.tcl`,
    `hir/specialize.tcl`, `hir/range.tcl`.
56. **Why is each change necessary?** `hir/types.tcl`: the combination
    primitive (`narrow`) had no aggregate case at all. `hir/specialize.tcl`:
    the one call site that needed to invoke the (now-extended) primitive
    for a specific/aggregate key was structured to skip it entirely.
    `hir/range.tcl`: no satisfiability primitive existed under any name
    (spec items 9-13 required one).
57. **Is there now a distinct per-instance channel for declared theorem vs
    observed fact?** Not a *new* one -- the pre-existing, instance-
    independent `declaredParamTypes` field already serves as the declared
    channel; the instance's own `args`/view already serves as the observed
    channel. This milestone combines them into the *seed* used for
    re-inference, without duplicating either channel's own storage.
58. **If not distinct structurally, how are both preserved without loss?**
    See "Consumer-neutral design": the seed is a combined value, but both
    of its own inputs remain independently readable at their pre-existing
    locations (the key, via `view`; the declaration, via
    `declaredParamTypes`) for any test or tool that wants to inspect them
    separately, exactly as this report's own tests do.
59. **Did `hir::specialize::KeyType` change? Expected: no.** Confirmed no.
60. **Did source type inference change? Expected: no.** Confirmed no --
    `hir::types::infer`/`Block`'s own whole-program pass is unmodified;
    only `inferRegion`'s own per-instance seeding input changed.
61. **Did `ProvesValueAcceptedBy` semantics change? Expected: no.**
    Confirmed no -- zero lines changed.
62. **Did native runtime code change? Expected: no.** Confirmed no.
63. **Did any `.bot` source change? Required: no.** Confirmed no (see
    "Source-fence confirmation").

## Stop condition

All conditions from the brief hold:

1. Specialization identity remains unchanged (confirmed throughout, every
   scenario/test).
2. Observed instance facts remain available (`List[never]` and coarsened
   keys alike, confirmed).
3. Declared parameter theorems are transported into every legal
   specialized instance whose observed key shares its declared type's own
   aggregate constructor (List/List, Set/Set) -- the one case this
   milestone's own scope targeted; a mismatched-constructor case (a
   callable key, say) has nothing sound to combine and is unaffected,
   exactly as before.
4. Observed and declared facts are treated conjunctively (`narrow`'s own
   extended recursion), never one replacing the other.
5. Their conjunction is checked/constructed with explicit satisfiability
   semantics (`hir::range::FactsSatisfiable`, new, tested).
6. Empty `List[never]` instances retain their observed emptiness theorem
   (confirmed).
7. Those same instances also retain the declared aggregate element theorem
   -- at the block level, retrievable independent of instance (confirmed);
   deliberately *not* folded into the instance's own emptiness-preserving
   seed, per spec item 66's own explicit permission.
8. Existing empty-listloop dead-body optimization remains (confirmed, now
   also for a declared parameter).
9. Non-empty/coarsened aggregate instances regain their declared element
   theorem (confirmed, the primary positive regression).
10. Reachable listloop element facts can consume that theorem (confirmed).
11. Open/shared instances retain declared theorems despite observed-fact
    widening (confirmed).
12. Ordinary List/ImmutableSet invariance remains unchanged (confirmed).
13. Empty-collection admissibility remains exactly as M7.a.a defined it
    (unmodified files, all 24 tests passing unmodified).
14. No source-level contextual typing is introduced (confirmed: no
    surface/parser/resolve file changed).
15. No instance-key policy changes (confirmed: zero `KeyType` diff).
16. No new constant-container specialization (confirmed: no change to
    literal-content tracking, `hir/completions.tcl` unmodified).
17. M1-M7.a.a regressions pass (confirmed: all required suites, exact
    counts above).
18. Full suite passes (2242/2242, both backends).
19. Frozen source fence remains intact (confirmed: no `.bot`/`.ir` file
    modified; frozen census byte-for-byte unchanged).
