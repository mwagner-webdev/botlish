# Finite callable-target provenance: pre-implementation research notes

**Status: research only. No production code was changed.** This milestone
was paused before any `hir/`, `native/`, or `core/` edit, on the premise
that module-retained immutable bindings (e.g. `web::local_extra_chars`)
should first be re-modeled as static-slot/static-data values rather than
lexical closure captures -- a change (module-static values) that shifts
which functions in the frozen `refined-checks.ir` workload are envless,
which are closures, and which are open, and therefore changes the shape of
`scan_while`'s own predicate targets. The next milestone will be reprompted
from the frozen R2.a baseline with module-static values handled first; this
document preserves what was learned in the meantime so that work is not
re-derived from scratch.

## Why this document exists

`POST-R2A-DYNAMIC-CENSUS.md` recommended "higher-order exact-target
provenance" (a finite callable-target theorem for `scan_while`'s
`predicate`) as the next milestone, with a measured counterfactual ceiling
of -19.7% Ir on `bench/refined-checks.ir`. Before writing any code, this
session did a full architecture audit (an `Explore` subagent covering HIR
call typing, native/native-value representation, blockescape, StringRegion
native-consumer matching, `hir::specialize`'s `KeyType`/`Handle`, and the
existing `ClosedCallerFacts`/`CloseCallers` machinery M7.c already built),
plus a direct reading of `hir/blockescape.tcl` in full and the start of
`native/lower.tcl`'s function-lowering machinery. Mid-investigation, the
premise changed: module-static values are now recognized as a prerequisite,
not a follow-on, because they change which functions are closures at all
in this exact workload. This document captures the audit's findings so
that prerequisite work, and the eventual finite-target milestone, can both
start from accurate ground truth instead of the (now corrected) framing in
the original brief.

## Correction to the milestone brief's own framing

The brief's illustrative claim -- "`local_char?` stopped escaping as a
value, so its capture flattened and ~800 per-run closure allocations
disappeared" -- **does not match what M7C-CLOSED-CLOSURE-ENTRY-FACTS.md
actually says** (grepped for "800", "local_char", "capture flatten",
"counterfactual": no hits; M7C's own fixtures are `uri-steady.bot`'s and
`refined-checks.ir`'s `esc_bytes`/`esc_char`/`char_at`/`scan_local`/
`scan_label`/`domain_loop`/`tld_ok` family, never `lib/web.bot`'s
`emailish?`/`scan_while`). Direct source reading (`hir/resolve.tcl:46`,
`hir/aot.tcl`'s `envless`/`StaticBlocks`) shows `local_char?` (`lib/
web.bot:99-100`) references only its own parameter `c` and the *module-root*
binding `local_extra_chars` -- a root reference is not a capture -- so
`local_char?` has an **empty** `captures` list and is already `envless`
today, lowered as a zero-allocation `fnvalue` constant, not a heap closure.

This means the 800 `Block`/closure allocations the census attributes to
`local_char?` are a **different** function's allocations: `web::emailish?`
itself captures `char_at` (which captures `v`) and possibly other
region-local state to build `local_char?`'s... no -- re-reading the
census's own allocation table (`web.bot:99 closure`, 800 count, "captures
module-retained `local_extra_chars` and escapes as a value") shows the
census attributes the closure to `local_char?` specifically, captured
*because* `local_extra_chars` is module-retained (i.e., in the census's own
current tree, `local_extra_chars` is NOT a plain root/native-like binding
but a module-level `bind` whose value must be threaded as a capture -- this
is exactly the R2.a.1 "module retention" mechanism the census's own
"Generic-keying / lost-M9-fact cost" section describes: *"Since R2.a.1,
`local_extra_chars` is module-retained, so `web::emailish?` captures it and
becomes a closure."* So in the **current, real tree**, `local_extra_chars`
is not an ordinary native-registry root value like `is_tcl_alpha` -- it is
itself a *module-scope closure-captured* value, and that capture propagates:
`local_char?` (which reads it) captures it too, `emailish?` (which defines
`local_char?`) captures whatever `local_char?` needs, and so on up the
chain, exactly the mechanism `POST-R2A-DYNAMIC-CENSUS.md`'s own "B: static
module-retained values" candidate (`local_extra_chars`, `web::emailish?`)
already names as a *separate*, independently measured candidate (ceiling
3.6%, of which 3.3% overlaps the exact-target counterfactual).

**The corrected picture**: `local_char?`'s "capture" is not free-variable
capture of an ordinary lexical value -- it is the module-retention
mechanism's own encoding of "this function needs access to a module-level
immutable value," implemented today as an ordinary HIR/runtime closure
capture purely because no dedicated static-value representation exists yet.
Fixing that representation (module-static values: a stable static slot, or
directly embedded static data, instead of a lexical capture) is exactly
what changes `local_char?`, and very likely `web::emailish?` itself, from
"generic value-capturing closure" to "envless/static function" -- which in
turn changes:

- `hir::specialize::Handle`'s `call` case (`hir/specialize.tcl:646-668`):
  the `scalarCaptures`/`GenericKey` forcing only applies to
  `$block ni [dict get $state context statics]`; an envless-after-module-
  statics `emailish?`/`local_char?` would no longer force `scan_while` (or
  `emailish?` itself) into a generic key on that account.
- `hir::specialize::InstanceClosed`'s two-branch definition (static-block
  materialization test vs. `hir::blockescape::wants`): which branch even
  applies to `emailish?`/`check` changes once they are no longer
  value-capturing closures forced generic by a module-retained value.
  `POST-R2A-DYNAMIC-CENSUS.md`'s own "Generic-keying / lost-M9-fact cost"
  section already documents that `check` is *currently* generic and
  open (`hir::range::OpenInstances` flags it materialized in `<program>`)
  **because of** this exact chain -- a module-static fix plausibly makes
  `check<int,int,str,str>` reappear (as it was pre-R2.a.1), recovering
  `n ∈ [0,400]` "for free," independent of any callable-target theorem.
- Whether `scan_while`'s own two call sites (`emailish?`'s
  `scan_while(0, local_char?)`, `tld?`'s `scan_while(i, is_tcl_alpha)`)
  still present `local_char?` as a *closure value* argument at all, or
  as a plain `fnvalue` reference the same way `is_tcl_alpha` already is --
  which changes the callable-target fact domain's own practical target
  shape for this specific workload (still "one Block identity, one Native
  identity" in essence, but arrived at through static functions on both
  sides rather than one closure and one native).

Concretely: **module-static values must land first**, both because the
census already treats it as a materially overlapping, independently
measured candidate (not a strict subset of the callable-target win), and
because it changes the actual closure/generic/open shape of the exact
functions (`local_char?`, `emailish?`, `check`) any callable-target
analysis would be reasoning about. Implementing the callable-target
theorem against the *current* (module-retention-as-capture) tree risks
building machinery against a shape that a subsequent, clearly-needed
milestone would immediately invalidate.

## Findings preserved from this session's audit (still expected to hold structurally)

These are architecture facts about the compiler, not about this specific
workload's current closure shape, so they should still hold once
module-static values land -- reconfirm before relying on them rather than
re-deriving from scratch.

### 1. How a dynamic dispatch (`callvalue`) arises

There is no separate "callvalue" HIR node kind. `hir::types::Call`
(`hir/types.tcl:1035-1169`) decides purely from the callee's static type:
an exact `{native NAME}` (2-tuple) or `{block B arity result}` (4-tuple)
type sets `target` to `{native NAME}`/`{block B}`; anything else callable
(the bare kind atom `block`/`native`, produced by `hir::specialize::
KeyType` collapsing an exact type for specialization-key purposes) leaves
`target` unset (`""`). `native/lower.tcl`'s `Call` (starting line 3113)
reads `dict get $node target`; when it's `""`, lowering falls through to
the tail of the function (lines ~3544-3553) and emits the NIR op
`callvalue %f %a...`, lowered to the Rust runtime helper `rt_call_value`.
**`native::lower::Call` never independently decides directness -- it is a
pure function of one upstream field, `target`, set once by
`hir::types::Call`.**

### 2. Native functions are already first-class, exactly typed values

`{native NAME}` is a first-class HIR type (`hir/types.tcl:379-385`,
`ofValue`), listed alongside `block`/`list`/`immutableSet` in `IsSpecific`
(`hir/types.tcl:103-106`) as an *exact* type constructor. Every registered
native (`core::native::register`, `core/native.tcl`) is bound in
`core::rootEnv` (`core/evaluator.tcl:373-379`) as an ordinary immutable
root binding whose value is `{native NAME}`; a bare reference to it is
typed via `hir::types::BindingType`'s `root` case, returning `[ofValue
$value]` -- exactly as exact as a root-bound Block reference. No
"native-literal" HIR node kind exists; it is an ordinary `ref` node, same
as any other reference.

### 3. `hir::specialize::KeyType`/`Handle` is where identity is lost, and must not be touched

```tcl
proc hir::specialize::KeyType {type} {
    ...
    set kind [hir::types::kindOf $type]
    return [expr {$type eq "never" ? "never" : $kind eq "" ? "any" : $kind}]
}
```
(`hir/specialize.tcl:264-274`) reduces both `{block B arity result}` and
`{native NAME}` to their bare kind atom (`block`/`native`), discarding
identity, for every specialization-key purpose. `Handle`'s `call` case
(`hir/specialize.tcl:642-700`) writes `dict set state instances $current
calls $e $target` (line 697) -- the exact map both M7.c's
`ClosedCallerFacts` and any future callable-target analysis must read.
`hir::types::lub` (`hir/types.tcl:250-282`) also cannot carry callable
identity through a join: two different Block ExprIds, or a Block and a
Native, both collapse to the bare kind or `any` (confirmed directly for
this workload's own `local_char?`/`is_tcl_alpha` pair in "Bonus" below).
**A future callable-target fact must live in a separate channel, parallel
to (not inside) `KeyType`/the specialization key -- exactly the
architectural separation the milestone brief itself already mandates
(spec section 2/3), and exactly the shape M7.c's own three-channel model
(observed/declared/closed-caller) already establishes as this compiler's
existing pattern for "new fact, same key."**

### 4. `M2-EXACT-CALLABLE-TARGET-PROVENANCE.md` already answered the general question, in the negative, for the current architecture

A prior milestone (`M2-EXACT-CALLABLE-TARGET-PROVENANCE.md`) already asked
"does an exact callable value forwarded through an ordinary, untyped
function parameter (not a capture) ever get devirtualized when it has a
proven singleton target?" and answered **no, correctly so** -- `apply(foo,
1)` with `fn apply(f, x): f(x)` stays `callvalue` even as the program's
only call site, because `KeyType` forces the shared parameter to the bare
kind `block` regardless of how many (or how few) distinct exact values
ever reach it. M2 added one test file (`tests/hir-callable-target.test`,
8 tests, read in full) and zero production code. **The finite-target
milestone is explicitly the follow-up M2 declined to attempt** -- worth
citing directly in that milestone's own motivation section instead of
re-deriving the "why doesn't this already work" question. `tests/
hir-callable-target.test`'s helpers (`nirOf`/`sourceHir`, and the
"extract one function's body text by name, regexp for `callvalue`/`call N
`/`callenv N `" technique, lines 21-31 and 189-201) are directly reusable
for that milestone's own regression tests.

### 5. Existing exact-call lowering paths are cleanly reusable; no finite-dispatch primitive exists yet

Both the exact-Block path (`native/lower.tcl:3380-3536`, `targetKind eq
"block"`) and the exact-Native path (`3357-3379`/`4402-4480`, e.g.
`is_tcl_alpha` maps to a plain raw op `strtclalpha`, not even a `call`) are
pure functions of `dict get $node target`/`targetKind`, with zero
"how was this proven" logic inside `Call` itself -- both are reusable
verbatim by anything that can synthesize the same `target` shape. The one
existing precedent for a *post-hoc* fact rewriting a call's lowering form
without touching `hir::types::Call`'s own `target` field is
`hir::blockescape`'s own early interception in `Call`
(`native/lower.tcl:3151-3187`, `FlattenedVirtualCall`) -- but that path
only ever fires for a **direct call whose callee is already `targetKind
eq "block"`** (i.e., ordinary type inference already proved it exact); it
does not and cannot apply to a `callvalue` site (`targetKind eq ""`)
without a new, structurally analogous interception point.

**No runtime "compare this Value's exact identity against a compile-time
constant" primitive exists** (`guard KIND %v` only checks representation
*kind* -- int/str/block/native/... -- never *which* Block or Native). A
genuine multi-target runtime dispatch (item 55 in the original brief) would
need either a new such primitive, or -- the architecturally cleaner
option, and the one this session was converging on -- avoiding a runtime
check entirely, because **each exact caller already knows, at compile
time, which target it supplies** (that's exactly the fact the join would
be built from). The plan this session was drafting (see "Draft lowering
design" below) routes each caller to a distinct callee-side lowering
variant chosen at the caller's own lowering time, never at the callee's
run time -- consistent with the brief's own item 56 ("do not reconstruct a
runtime callable identity test merely to select a target that was already
known from control provenance").

### 6. `hir::blockescape`'s "internal variant" is a real, reusable precedent -- but is per-*instance*, not per-*target*

Read `hir/blockescape.tcl` in full (567 lines). Its "internal variant"
mechanism (`wants`/`virtual`/`captures`, consumed by `native/lower.tcl`'s
`InternalRef`/`FlattenedVirtualCall`) already produces, for a locally-bound
closure candidate proven to be called only in exact, arity-matching ways,
a **second NIR function** for the callee instance: capture-explicit
(captures passed as ordinary trailing parameters instead of a heap
closure), with every call site that "wants" it routed directly instead of
through the generic entry. This is architecturally the closest existing
thing to "callee-side lowering variant chosen by caller-side knowledge" --
but it is explicitly **one variant per callee instance, shared by every
call site that demands it** (the file's own header, "What this module
still declines... specializing an internal variant's own body differently
per call site"), never one variant per distinct *value* reaching a
parameter. A callable-target milestone that wants one variant per exact
*target* (e.g., `scan_while<generic>~predicate=local_char?` vs.
`~predicate=is_tcl_alpha`) needs a **new**, differently-keyed variant
family -- same architectural shape (a second/third/... NIR function per
instance, callers routed explicitly, parameter dropped from the variant's
ABI, every reference to the substituted parameter either eliminated at its
call-target use or replaced by a synthesized constant value elsewhere) but
keyed by `(InstanceId, target-assignment)` rather than blockescape's own
`(InstanceId)` alone. This is a real, bounded, but nontrivial new lowering
feature -- not a drop-in reuse of `hir::blockescape` itself.

### 7. `native/lower.tcl`'s Function-emission and placeholder/ref machinery (partially read)

`FunctionRef`/`CompanionRef`/`RegionCompanionRef`/`InternalRef`/
`InternalRegionCompanionRef`/`FieldsRef`/`FieldsCompanionRef`
(`native/lower.tcl:1328-1396`) are all the same pattern: append `{id mode}`
to a `pending` worklist, return a placeholder token; `Key`/`Unkey`
(1398-1408) round-trip `id.mode` strings; `program` (not yet read in full)
presumably drains `pending` until fixpoint, lowering each `{id mode}` pair
via `Function id` (1469-...) with `mode`-specific parameter/body
adjustments. A `(InstanceId, target-assignment)`-keyed variant family would
plausibly add one more `mode` value (e.g. `targeted:<param>=<target>`) to
this same placeholder/worklist system, reusing `Function`'s own body-walk
with a caller-supplied substitution context threaded through wherever it
currently reads `envless`/`captureLists`/`blockescape` state. **This part
of the investigation was not finished** -- `Function`'s full body (which
continues past line 1504, and `InternalFunction`'s own separate proc, not
yet read) still needs a full read before any implementation, specifically
to see how it currently threads `captureLists`/`blockescape` substitution
context through the body walk, so a parallel `target-assignment`
substitution context can follow the identical shape rather than a new one.

### 8. StringRegion's native-consumer recognition is a literal name match, gated on ordinary `targetKind eq "native"`

`hir::stringregion::ConsumingNative` (`hir/stringregion.tcl:241-250`)
checks `$name in {is_tcl_alpha is_tcl_alnum}` against the *resolved native
symbol name* of a call whose `targetKind` is already `native`. For
StringRegion to "naturally" recognize an exact-native rewrite of
`predicate(char_at(i))`, the rewritten call must present **exactly** the
ordinary `{native is_tcl_alpha}` `target`/`targetKind` shape a ground-truth
direct native call already has -- not a new "resolved via devirtualization"
wrapper shape, or StringRegion will silently never match it (exactly
analogous to how blockescape's own virtualized calls need their own
explicit StringRegion composition awareness, `hir/blockescape.tcl:492-497`
and `native/lower.tcl`'s `FlattenedVirtualRegionCall`).

## Draft lowering design (not implemented, preserved for reuse)

This design was being drafted when the milestone was paused. It assumed
the *current* tree's closure shapes; it will need re-checking once
module-static values land (particularly: whether `predicate` is still an
opaque parameter of a value-capturing `scan_while<generic>`, or whether
`scan_while` itself changes shape).

1. **Analysis** (a new sibling to `hir::specialize::ClosedCallerFacts`,
   *not* feeding `CombineCallerTheorem`/`Reanalyze`'s Kind-seeding at all --
   this fact is consumed by lowering, not by type inference): for each
   closed instance (`hir::specialize::InstanceClosed`, reused verbatim) and
   each of its parameters, scan every exact closed-caller call site
   (mirroring `ClosedCallerFacts`'s own `used`/`calls`/`reachable`/`view`
   traversal) and read the caller's own argument type at that position via
   `hir::typeOf`. If it is an exact `{block B ...}` or `{native NAME}`,
   contribute that identity (not `KeyType`'s collapsed kind); an unchanged
   self/tail-forward of the callee's own parameter contributes nothing
   (same exclusion `ClosedCallerFacts` already uses, for the same
   convergence reason); anything else (a non-exact argument type) poisons
   the parameter to `Unknown` outright, per the brief's own item 16.
   Join contributing identities via **set union**, not `hir::types::lub`
   (`lub` provably collapses a Block/Native pair to `any`, confirmed
   directly for this workload's own `local_char?`/`is_tcl_alpha` types --
   see "Bonus" in the agent transcript this document summarizes), capped
   at a small budget (mirroring `hir::range`'s own `maxExactValues = 32`
   precedent, though the primary workload only ever needs 2); an
   open instance, an empty caller set, or a set exceeding budget all
   produce `Unknown`, never a partial/poisoned finite set.
2. **Lowering**: for a parameter with a `Finite{T1..Tk}` theorem whose
   *only* references within the instance body are as the callee of an
   exact-arity call (a `RefsAsCalls`-shaped restriction, applied to a
   parameter rather than a local bind -- the scope limit this design
   accepts, matching the brief's own allowance to report a stopping
   point rather than solve the fully general case), emit `k` new
   "callable-resolved" internal variants of the instance (new `pending`
   `mode`, per finding 7 above), each with: the parameter dropped from the
   variant's own ABI, and the parameter's one call-target reference
   rewritten directly (bypassing the generic `targetKind` switch, the same
   early-interception shape `FlattenedVirtualCall` already uses) to a
   direct `call`/`callenv`/native-op emission for that one fixed target,
   reusing the ordinary exact-Block/exact-Native lowering bodies
   unchanged. Each real, non-poisoned exact caller is then routed (at that
   caller's own lowering time, using only its own already-known argument
   identity -- never a runtime check) to the one matching variant, with
   the argument dropped from the call's own argument list; a self-tail or
   non-tail recursive call that forwards the parameter unchanged is routed
   to the *same* variant currently being lowered (mirroring blockescape's
   own "a candidate's own recursive call... calls back into its own
   internal variant" precedent exactly). The instance's ordinary generic
   entry is kept (for `hir::aot::materializedBlocks`/dead-value reasons,
   and as a safety fallback that is provably unreachable once every real
   caller is routed) rather than deleted, satisfying the brief's own
   "provably unreachable fallback is acceptable" allowance without ever
   inserting a new runtime validation check (which the brief explicitly
   forbids, item 21).
3. **Not attempted / explicitly out of scope for a first cut**: relational
   multi-parameter target combinations (item 50 already asks for
   non-relational treatment); a genuine runtime finite-dispatch primitive
   (only needed if a caller's own target isn't staticly known at its own
   lowering time -- not the case for any caller this compiler currently
   resolves through `hir::specialize`'s exact-call machinery, per finding
   1's own "Current closure ingress mechanisms" table in M7C's report);
   higher-order two-level forwarding (`outer`/`inner`, brief item 20) was
   not designed in detail -- flagged as a possible stopping point to report
   explicitly, per the brief's own item 46, rather than a solved case.

## What should happen instead, before this milestone resumes

Per the interrupting instruction: implement module-static values first
(`web::local_extra_chars`, and whatever else the module-retention
mechanism currently forces into lexical captures), reusing the frozen
R2.a baseline as the starting point rather than the current
`refined-checks.ir`-tuned tree, then re-run the dynamic census against the
resulting tree before deciding whether "finite callable-target
provenance" is still the highest-value next step, still shaped the way
this document assumes, or superseded/changed by what module-static values
themselves reveal (e.g., if `check` reappears non-generic "for free," per
finding above, some of the callable-target win's own measured ceiling may
shift).

## Source-fence confirmation

No file under `lib/`, `hir/`, `native/`, or `core/` was changed by this
session. `git status`/`git diff` show no changes outside this new
research-notes file.
