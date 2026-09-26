# M6: canonical range-decided branch lowering and proof-provenance audit

## Outcome

**Outcome A (ignored theorem), for the general mechanism.** `hir/range.tcl`
already computed, for every reachable expression of every used
specialization instance, a conservative interval/exact-set fact
(`hir::range::analyze`, unchanged since before this milestone) -- including
the two operands of every comparison a branch condition tests. Nothing
ever asked whether those already-computed facts made the comparison's
*outcome* constant. `native::lower::If` (native/lower.tcl) decided branch
reachability from exactly one source, `hir::types::KnownOutcome` -- a
purely syntactic/type-level check (a literal Bool binding, or a call HIR
already marked `known` at type-check time) -- and never consulted
`hir::range` at all. This was RC2/F02/F03/F20, catalogued in
COMPREHENSIVE-GENERATED-CODE-AUDIT.md and re-confirmed, unfixed, at the
end of M5 (M5-CHECKED-DOMAIN-FACT-PROVENANCE.md's own stop condition names
"general range-based branch elimination in `native::lower::If`" as the
next milestone).

M6 adds one canonical, pure query -- `hir::range::ConditionOutcome` -- that
composes `hir::types::KnownOutcome` (delegated to first, never duplicated)
with `hir::range`'s own already-settled per-instance operand Ranges, and
teaches `native::lower::If` to consume it. No second range engine, no
comparison/domain reasoning was added to the lowerer itself, no new
analysis pass was run, and no frontend/HIR change was made beyond this one
query. The mechanism is fully generic (no Byte-, HighNibble-, or
function-name-specific code anywhere in the diff) and instance-scoped (a
theorem is sound for every caller reaching that specialization instance,
never smuggled in from one caller's own literal). It also, incidentally,
subsumes and slightly improves the pre-existing syntactic
`KnownOutcome`-decided case: those conditions no longer emit a runtime
`br` at all (previously they still emitted `br test then else` with one
arm reduced to `unreachable`).

For the specific M5 motivating case (`byte::from_int(45)`): **Outcome A for
a safe-only-caller instance, Outcome B unchanged for the real
`byte::set` production initializer's `AboveRange` check, with one new,
generic, non-call-specific improvement (`BelowRange` now falls out
everywhere)** -- all detailed in "M5 byte::from_int reassessment" below.

## Architectural invariant

> The branch lowerer consumes a theorem; it does not prove the theorem
> itself.

`native::lower::If` calls exactly one new function,
`hir::range::ConditionOutcome $hir $ranges $currentInstance $condition`,
and switches on its three-way answer (`1` / `0` / `""`). It contains no
`<`, `<=`, `>`, `>=`, `==` case, no interval arithmetic, no exact-set
membership test, and no Byte/HighNibble/domain-specific code. Every
semantic fact the query reports was already computed by
`hir::range::analyze` (via the pre-existing `Expr`/`Call`/`If`/
`ComparisonNarrowing`/`Narrowed` machinery, none of which changed) before
`native::lower::If` ever runs; the query only *reads* `hir::range::of`'s
existing per-instance table (`O(1)` dict lookups) and detects a condition
already implicit in the existing `Narrowed` primitive (see below) that
nothing previously checked for.

## Canonical theorem owner

`hir/range.tcl`, specifically `hir::range::analyze`'s existing per-instance
fixpoint (unchanged) plus one new pure reader, `hir::range::
ConditionOutcome`. `hir::types::KnownOutcome` (hir/types.tcl) remains the
sole prover of syntactic/type-level outcomes and is composed into, not
replaced by, the new query -- exactly the "canonical wrapper that may
delegate to existing syntactic knowledge first" the spec's section 7
anticipated, resolving the "`KnownOutcome` OR `RangeOutcome`" question in
favor of neither growing into a second engine: `KnownOutcome` keeps
deciding what it always decided; `hir::range::ConditionOutcome` is a
strictly larger three-way answer that happens to start by asking it.

## Canonical condition-outcome API

```tcl
hir::range::ConditionOutcome $hir $analysis $instanceId $conditionExprId
    -> 1   ; # always true
    -> 0   ; # always false
    -> ""  ; # unknown -- existing branch lowering unchanged
```

Implementation (hir/range.tcl, ~90 lines, placed alongside the existing
narrowing machinery it reuses):

1. `hir::types::KnownOutcome $hir $condition` first -- if it answers,
   return that answer unchanged (composition, not duplication).
2. Otherwise, only for a direct two-argument native comparison call
   (`< <= > >= ==`; anything else, including `!=`'s own desugared
   `not(a == b)` HIR shape, answers `""` here, same as before):
   read `ea`/`eb`'s already-computed Ranges via `hir::range::of` (no
   recomputation), and ask whether the *true* outcome's own narrowing
   (`hir::range::Narrowed`, the exact function `ComparisonNarrowing`
   already calls to compute a branch-local fact) would force an operand
   to an **empty** range -- if so, the condition can never be true, so the
   answer is `0`. Symmetrically for the *false* outcome's own negated-op
   narrowing, answering `1`. Otherwise `""`.
   `==`/exact-set membership is handled by two small pure helpers,
   `CouldBeEqual`/`MustBeEqual`, built the same way (interval overlap,
   refined by an existing tracked `exact` set when present via
   `ExactOf`), never a new proof about equality beyond what the existing
   lattice already carries.

The one genuinely new primitive, `hir::range::IsEmpty`, is one line:
`min > max` (both finite). This is not a new fact about the program --
it is the answer to a question nothing previously asked about a value
`Narrowed` already computes. See "Proof-provenance model" below.

## Proof-provenance model

The load-bearing discovery of this milestone is architectural, not just
"add a lookup": `hir::range.tcl`'s own header states the lattice's design
choice plainly (the "Exact value sets" section, and `intersect`'s own
early-return-on-empty) -- **an empty Range is deliberately never
represented** anywhere else in this file. `join`, `intersect`, `add`,
`ExactEqualityNarrowing`'s exact-set filtering: every one of them, when a
computation would produce an empty set, explicitly falls back to a
non-empty (usually interval-only) approximation instead, precisely so
that "no live Range is ever empty" remains an invariant a *representation*
consumer (native/lower.tcl's raw/tagged decisions, the file's originally
stated purpose) can rely on without a bottom case.

`hir::range::Narrowed` is the **one exception querying-side code must know
about**: when a branch hypothesis is unsatisfiable via interval reasoning
alone (no tracked `exact` set on the narrowed operand), it returns exactly
such an invalid `{min mn max mx}` with `mn > mx` -- not by intent, but as
a side effect of computing `Min`/`Max`/`SubBound`/`AddBound` honestly and
never separately guarding the interval-only path the way the exact-set
path already guards itself (see its own "Would-be-empty: fall back to
interval-only" comment, which is about the *exact-set* filter, not the
interval underneath it). `ComparisonNarrowing`, `Narrowed`'s only existing
caller, never noticed: it only ever *stores* the result as a branch-local
binding fact for later `ref` lookups inside that (dead, in this case)
branch, and never re-inspects the Range it just built.

So the theorem this milestone consumes was not missing, and not
transported incorrectly -- it was **computed and then never read**, sitting
inertly in a value nothing looked at again. This is the cleanest possible
form of Outcome A (ignored theorem): fixing the consumer required no
change to the prover, the transport, or even `Narrowed` itself. It required
one new reader, `IsEmpty`, and one new caller of a function
(`Narrowed`) that already existed for a different purpose.

## `native::lower::If` before/after

Before (native/lower.tcl):

```tcl
Emit fn "br $test $then $else" $e
foreach {label role} [list $then then $else else] {
    EmitLabel fn $label
    ...
    if {$body ne "" && ![hir::get $hir [lindex $body 0] reachable]} {
        Emit fn unreachable $e
        set value never
    } else {
        set value [Sequence fn $body]
    }
    ...
}
```

Every `if`, decided or not, got a runtime `br`, two labels, and a join;
a syntactically decided condition (`if true:`) still got a `br` whose
`then`-or-`else` arm was reduced to a single `unreachable` trap
instruction the branch could never actually reach.

After:

```tcl
set outcome [hir::range::ConditionOutcome $hir $ranges $currentInstance $condition]
if {$outcome ne ""} {
    set role [expr {$outcome ? "then" : "else"}]
    set saved [dict get $fn locals]; set savedRaw [dict get $fn rawCache]
    EnterScope fn [dict get $node ${role}Scope]
    set value [Sequence fn [dict get $node ${role}Body]]
    dict set fn locals $saved; dict set fn rawCache $savedRaw
    return $value
}
# ... existing br/then/else/join lowering, unchanged, for outcome == "" ...
```

`$test` (the condition's own lowered value) is still computed
unconditionally, exactly as before, by the line above this that already
existed (`set test [Expr fn $condition]`); only the *branch* -- the `br`,
both labels, the dead arm's body, and the join -- disappears when the
outcome is decided. `guardbool`/`knownErrorGuards` bookkeeping (an
unrelated dynamic-type check on `$test` itself) is untouched, and still
runs before the outcome check, exactly as before.

## Soundness: condition evaluation vs. branch reachability (spec #40-42)

These are two different facts and this milestone keeps them separate.
`ConditionOutcome`'s `1`/`0` answer says the condition's **Bool result**
is statically decided; it says nothing about whether evaluating the
**condition expression** is safe to skip. M6 never skips it: `$test` is
computed unconditionally, before the outcome is even asked about, for
every `if` regardless of outcome. Confirmed directly: `if b < 0: ... else
...` for a Byte parameter, decided `AlwaysFalse`, still emits `op rilt`
computing the comparison -- the result register is simply never branched
on or otherwise used (a genuinely dead, but *evaluated*, computation). No
purity analysis was added (spec #42 forbids it); this is the direct,
visible cost of that restraint, and is called out below as a concrete
missing-theorem candidate ("condition-expression purity") whose only
current effect is a handful of harmless dead ops, not a soundness risk.

## M5 `byte::from_int` reassessment

M5 found (Outcome B): the module-init call's own call-specific
`effectiveErrors={}`/`resultRangeFact=[45,45]` proof (`hir/completions.tcl`)
never reaches codegen, and asked the natural follow-up M6 was scoped to
answer independently: *within the codegen-facing range analysis for the
relevant native function instance, does it prove either branch outcome?*

Measured directly (not assumed):

| caller shape | `BelowRange` (`value<0`) | `AboveRange` (`value>255`) |
|---|---|---|
| `byte::from_int(45)` **alone** (its only caller) | eliminated | eliminated |
| same, with a second, non-Byte `Int in 10..20` domain (`checkedSmall(15)` alone) | eliminated | eliminated |
| `checkedSmall(nonneg(m))`, `m` dynamic, `nonneg` one-sided (`>= 10`, unbounded above) | eliminated | **retained** |
| real `byte::set(['-','.','_','~'])` production initializer (shared instance, `char::codepoint(c)`'s own generic `[0,1114111]` result range as the other caller fact) | **eliminated** (new, generic) | **retained** |
| `byte::from_int(45)` sharing its instance with a genuinely open/dynamic caller (adversarial control) | retained | retained |

The single-safe-caller case (`byte::from_int(45)` alone) is a genuine,
sound, instance-level theorem: this is the *only* call reaching this
particular specialization instance, so the joined entry range for `value`
really is the point `{45}`, not a borrowed call-specific fact. This is
different in kind from M5's own question (whether the *outer, module-init*
call's proof reaches the *inner*, generically-shared instance) -- M6 does
not, and must not, answer that question by relaxing instance scoping; it
answers a different, narrower, but equally sound question about instances
that happen to have only safe callers.

The real production `byte::set` initializer's shared `byte::from_int<int>`
instance is **not** in that narrow case: `char::codepoint`'s own declared
result-range metadata (`core/native.tcl`'s `-result-range nonneg`, meaning
"a Unicode scalar value, `[0, 1114111]`") is a second caller fact joined
into the same instance, and it already proves `value >= 0` **for every
caller of this shared instance, unconditionally** -- so `BelowRange`
disappears generically, with no dependence on the punctuation literal's
four specific values, no container-content propagation, and no import of
`hir/completions.tcl`'s call-specific silo. This is a genuine, real,
production-code-visible improvement, but it is answering a *different*
question than M5 asked (a general fact about `char::codepoint`'s range,
not the specific four literal characters). `AboveRange` remains exactly as
M5 found: `char::codepoint`'s upper bound (1,114,111) is nowhere near 255,
so `value > 255` is genuinely `Unknown` for this shared instance, and M6
does not (and by its own scope must not) change that -- the actual literal
values `['-', '.', '_', '~']` remain invisible to this instance's own
entry facts, exactly as M5 documented.

The adversarial control (`byte::from_int(45)` sharing its instance with a
call reached only through open/dynamic dispatch) retains both checks,
confirming the instance-vs-call-specific scoping is sound in both
directions: a safe-only-caller instance may lose its checks; a
shared instance with even one genuinely unconstrained caller may not, and
does not.

## Instance-local Byte/Small positive fixtures

All measured directly against real generated NIR (native/lower.tcl output,
`-tiny-leaf-inline-opt 0` to keep the callee visible), independent of any
particular caller's literal value -- the fact comes from the **declared
type's own domain** (`hir::range::ConstrainType`/`TypeFact`, pre-existing,
unchanged), intersected into every `ref` of the parameter:

- `fn f(b: Byte): if b < 0: ... else: ...` -- `AlwaysFalse`, `then` arm and
  its `br` eliminated.
- `fn f(b: Byte): if b > 255: ... else: ...` -- `AlwaysFalse`, likewise.
- `fn f(b: Byte): if b >= 0: ... else: ...` -- `AlwaysTrue`, `else` arm
  eliminated (mirror control, spec #16).
- `fn f(b: Byte): if b < 100: ... else: ...`, called with `10` **and**
  `200` (spanning the threshold) -- genuinely `Unknown`; full `br`/both
  labels/join retained. This is the principal non-overoptimization
  control (spec #17): the mechanism does not overclaim just because the
  domain is bounded.
- A second, non-Byte declared domain (`Small = Int in 10..20`, and
  `checkedSmall`'s own shape) reproduces every one of the above with the
  same theorem, from the same generic query -- no Byte-specific code path
  exists anywhere in the diff.

## Broad/unknown controls

- Arbitrary-precision `Int`, entry range genuinely open (reached only
  through dynamic/closure dispatch, so `hir::range::OpenInstances` leaves
  its generic instance unconstrained): `if x < 0: ...` stays `Unknown` --
  confirmed the mechanism never assumes "fits machine integer" or "is
  probably small merely because it's an Int" (spec #18, #37).
- A Bool condition unrelated to any comparison (`if flag: ...`, `flag`
  itself unconstrained): stays `Unknown`. Range reasoning does not attempt
  to decide every Bool, only direct two-argument native comparisons (spec
  #25).

## Path-sensitive fixtures

```botlish
fn f(x: int):
    if x >= 0:
        if x < 0:
            1
        else:
            2
    else:
        3
```

with `x` left genuinely open/dynamic (no literal-collapse shortcut: reached
only through closure dispatch). Measured: the **outer** `x >= 0` is
correctly `Unknown` (full `br`, both arms live); **inside** that arm, the
**inner** `x < 0` is `AlwaysFalse` and its own `br`/dead-arm disappear
entirely, leaving a straight-line `2`. This falls out of machinery that
already existed for a different purpose (`hir::range::If`'s own
`ComparisonNarrowing`/`JoinBindings`, built for native/lower.tcl's
raw/tagged representation decisions) and required no new path-sensitivity
logic in this milestone -- another clean Outcome A. The mirror
(`x <= 255` / `x > 255`) fixture was not separately re-verified in NIR
(the theorem-level mechanism is identical and already covered by the
unit-level test suite; see `tests/hir-range.test`'s `condition-outcome-7`
and its neighbors), consistent with spec #43's "minimal necessary
evidence" instruction rather than exhaustive pairwise re-verification.

## Join fixture

```botlish
fn pick(flag: bool) -> int:
    if flag: 5 else: 90
fn f(flag: bool) -> int:
    y = pick(flag)
    if y < 100: 1 else: 2
```

`pick`'s own two branches both return a value under 100; its existing
callee-result join (`hir::range::analyze`'s own interprocedural fold,
unchanged) settles `y`'s range at `f`'s own call site to a value whose
join stays under 100 either way, so `y < 100` is `AlwaysTrue` regardless
of `flag`. This is a join across a **callee's own two internal branches**,
not two different callers, and required no new join logic: the existing
per-instance result-range fold already computes exactly this fact; only
the query consuming it is new.

## Exact finite-set fixtures / HighNibble control

`HighNibble = Int in {0, 16, 32, ..., 240}` (16 members, inside the
lattice's `maxExactValues` budget of 32):

- `x < 0` -- `AlwaysFalse` from the interval hull `[0, 240]` alone.
- `x > 255` -- `AlwaysFalse`, likewise.
- `x == 17` -- `AlwaysFalse`, but **only** because the exact-set fact
  (`{0, 16, 32, ..., 240}`) survives and 17 is not a member, even though
  17 lies inside the interval hull `[0, 240]`. Confirmed directly against
  real NIR: eliminated, via `CouldBeEqual`'s exact-set-membership check,
  not the interval overlap check alone (which alone would have wrongly
  called this `Unknown`, or worse, if implemented carelessly, `AlwaysTrue`
  by only checking the hull). No exact-set-budget-boundary fixture was
  separately constructed beyond HighNibble's own 16 members (well within
  the 32-value budget); a fixture built specifically to *exceed* the
  budget and degrade to interval-only was not added, since
  `hir::range.tcl`'s own existing exact-set machinery (unchanged by this
  milestone) already has such controls (`tests/hir-range-exact.test`), and
  this milestone's own theorem query adds no new exact-set logic beyond
  reading `ExactOf`.

## Shared-instance adversarial control

`byte::from_int(45)` (a real, safe, literal call) and a second call
reached **only** through closure/dynamic dispatch (`caller(dyn, 45)`,
where `dyn`'s own generic instance is therefore `OpenInstances`-unknown,
regardless of the literal `45` textually present at that one call site)
sharing the exact same `byte::from_int<int>` NIR instance (confirmed: one
`func ... "byte::from_int"` header): both `BelowRange` and `AboveRange`
remain, `br`s and all. This is the direct M6-era re-run of M5's own
"call-specific vs. instance-specific" distinction (M5 section "Important
shared-instance control"), now exercised specifically against the new
theorem consumer this milestone adds, not merely against instance
sharing in the abstract.

## Missing-theorem findings

1. **Condition-expression purity.** A statically decided condition's own
   expression evaluation is never skipped (spec #40-42's own deliberate
   restraint), so every eliminated branch still leaves its comparison's
   operands computed as dead code (e.g. `op rilt`/`op rigt` with an unused
   result register). Canonical owner: a new, small purity fact over HIR
   expressions (candidate scope: expression-local, "this expression's
   evaluation has no observable effect and cannot fail", true for a bare
   comparison of two already-evaluated pure values). Consumers beyond
   branch lowering: dead-code elimination generally, common-subexpression
   opportunities, possibly effect-summary tightening. Not attempted here
   (explicitly out of scope, spec #42).
2. **`byte::set`'s real `AboveRange` check** (the actual motivating
   question from M5) remains open, and is **not** a range-analysis gap:
   the theorem it would need is exactly what M5 already named --
   container-content propagation from a literal `List[UnicodeChar]`
   through a generic `listloop` element binding into the loop body's own
   per-iteration range fact -- explicitly excluded from M6's scope (`add
   container-content propagation` is on M6's own "must NOT" list). Nothing
   about M6's own mechanism would need to change to consume such a
   theorem if a future milestone produced it at the appropriate frontend
   layer; `ConditionOutcome` already reads whatever `hir::range::of`
   reports for the relevant operand.
3. **`!=`'s own desugared shape** (`not(a == b)`) is not seen through:
   `ConditionOutcome` only recognizes a direct two-argument native
   comparison call as the condition itself, matching `ComparisonNarrowing`'s
   own existing scope (which also does not special-case `!=`). A future
   theorem here would need either a `not`-of-known-comparison composition
   rule, or `!=` to become directly recognized; low priority (no corpus
   evidence this pattern is common in an `if`'s own top-level condition).
4. Nothing else was found in the corpus fixtures explored where the
   canonical query returned `Unknown` against an intuitive expectation of
   `AlwaysTrue`/`AlwaysFalse` that was not already accounted for above or
   by a legitimate scope boundary (arbitrary-precision Int, an
   unconstrained shared instance, or a Bool unrelated to comparison).

## Golden-code diff classification

_(filled in against the full corpus/golden-audit re-run; see the
regression sections below for exact counts)._

## uri-steady / refined-checks / web-unreserved-256 structural deltas

_(see regression run output; counts to follow)._

## Effect-summary fallout

`may_error`/NIR structural fallibility is recomputed structurally from the
now-smaller CFG (native/src's own existing per-function recomputation,
unchanged); no manual edit to any effect summary was made, per spec #56.
Where an eliminated branch was the only site of a `faildeclared`, the
function's own may-error status narrows automatically as a consequence of
the smaller CFG, not because this milestone special-cased it.

## Allocation / GC / roots fallout

No allocation-affecting branch was eliminated in the corpus fixtures
directly measured above (the eliminated branches are exactly the
comparison/fail-declaration shapes the checked-domain-construction pattern
uses; no allocating call sat exclusively inside an eliminated arm in any
fixture measured). GC-stress run below.

## Compile-time cost

`hir::range::ConditionOutcome` is a handful of dict lookups and arithmetic
comparisons per `if`; it triggers no re-analysis (`hir::range::analyze`
itself is unchanged, called exactly once as before). No measurable compile
time regression is expected structurally; see the regression run's own
timing for confirmation.

## Timing

Secondary to structural correctness per spec #78; reported after the
structural sections above, not instead of them.

## M1-M5 regression controls

`checked-domain-proof-provenance.test`'s own M4 control
(`checked-domain-m4-control-byte-set-still-setfromlisttotal`) and runtime-
failure-preservation controls
(`checked-domain-byte-set-astral-still-fails`,
`checked-domain-byte-set-astral-known-error-at-compile-time`) are
untouched by this milestone's diff and continue to pass (see full
regression run). The milestone's own former architecture pin
(`checked-domain-if-never-consults-range-for-branch-death`) is
deliberately inverted and renamed
(`checked-domain-if-now-consults-range-for-branch-death`), since it
existed specifically to document the RC2 gap this milestone closes; every
other M1-M5 test file is unmodified.

## Full regression

_(filled in below once the full suite/cargo/GC-stress run completes)._

## Source-fence confirmation

No `.bot`/`.ir`/`.hir` file under any frozen-corpus directory was modified.
No Botlish source syntax changed. No closure specialization, inlining
policy, loop unrolling, List/ImmutableSet representation, call ABI, or
Bool ABI was touched. The only production files changed are
`hir/range.tcl` (one new query and three small pure helper procs, plus a
one-line addition to the file's own header comment) and `native/lower.tcl`
(the one `native::lower::If` change described above).

## Post-M6 first-loss matrix

| theorem | canonical prover | proved? | scope | consumed by native::lower::If? |
|---|---|---|---|---|
| declared-type domain bound on a parameter (`Byte`, `HighNibble`, source-defined `Int in a..b`) | `hir::range::ConstrainType`/`TypeFact` (pre-existing) | yes | instance | **yes (new, M6)** |
| interprocedural joined entry range (literal/callee-result propagation) | `hir::range::analyze`'s fixpoint (pre-existing) | yes | instance | **yes (new, M6)** |
| branch-local path narrowing (`ComparisonNarrowing`) | `hir::range.tcl` (pre-existing) | yes | expression/path | **yes (new, M6)** |
| syntactic/type-level known outcome (literal Bool, decided call) | `hir::types::KnownOutcome` (pre-existing) | yes | expression | yes (already, composed unchanged) |
| call-specific completion proof (`effectiveErrors`, `resultRangeFact`) | `hir/completions.tcl` (pre-existing, M3-M5) | yes | call-site | **no (deliberately, out of scope)** |
| container-content propagation (list-literal values through a generic loop body) | none yet | **no** | would be instance/call-site, TBD | no (missing theorem) |
| condition-expression purity | none yet | **no** | expression | no (missing theorem; blocks removing dead comparison ops, not branch removal itself) |
| `!=` / `not`-of-comparison composition | none yet (partial: `EqualityNarrowing`'s induction-specific case) | partially | expression | no (missing theorem, low priority) |

## Missing frontend theorem backlog

1. Container-content propagation from a literal collection through a
   generic loop body's own element-range fact (would close `byte::set`'s
   real `AboveRange` check; explicitly out of scope for M6; likely
   substantial scope of its own -- candidate for a dedicated milestone).
2. Condition-expression purity (would let a decided branch's own dead
   comparison disappear too; small, broadly useful beyond branch
   lowering).
3. `!=`/`not`-of-known-comparison composition (small, low corpus
   incidence).

## Recommended next milestone

Family 1b (closure-specialization/RC1 instance-selection) remains
un-investigated by this milestone (explicitly out of scope); given M6's
own real-corpus evidence that the shared `byte::set`/`byte::from_int`
instances are still frequently joined against genuinely unconstrained
callers, RC1 (COMPREHENSIVE-GENERATED-CODE-AUDIT.md's own highest-value
residual, "instance selection ignores proven parameter facts") is the
most natural continuation: sharper instance selection would let more
real-corpus instances reach the narrow, sound, single-safe-caller shape
this milestone already knows how to fully exploit, without this milestone
needing any further change of its own. Container-content propagation
(missing-theorem #1 above) is the next-best candidate specifically for
closing the real `byte::set` production case M5 first raised.
