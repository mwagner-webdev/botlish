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

Measured against a true pre-M6 baseline (a `git worktree` at M5's own tip,
`7b2ed38`, reusing the identical `botlish-native` binary -- M6 touches no
Rust code, so the same binary is valid for both sides), via
`audit/comprehensive-generated-code/tools/probe.tcl`, across every probe
in that directory plus `bench/uri-steady.bot` and `bench/refined-checks.ir`:

| workload | changed? | classification |
|---|---|---|
| `uri-steady` | yes | correct theorem consumption (`byte::from_int`'s `BelowRange` check) |
| `web-unreserved-literals` | yes | correct theorem consumption (same) |
| `refined-checks` | yes | correct theorem consumption (same, **plus** `check`'s own `unreachable`-arm cleanup, see below) |
| `steady-ascii` | no | none (negative control) |
| `steady-ascii-param` | no | none (negative control) |
| `steady-ascii-capture` | no | none (negative control) |
| `ascii-256` | no | none (negative control) |
| `web-unreserved-256` | no | none (negative control) |

Every changed function's diff is the same one theorem
(`char::codepoint`'s own declared `nonneg` result-range metadata proving
`byte::from_int`'s `value >= 0` unconditionally, described above under "M5
`byte::from_int` reassessment"), so no separate per-function classification
table was needed beyond the one already given there. No workload exercised
in this probe set showed a range-analysis bug, a lowering bug, or a
test-expectation-only change beyond the two golden-value updates already
described (`tests/checked-domain-proof-provenance.test`'s Q1/Q2/Q3
expectations, and `tests/native-root-liveness.test`'s `work` register
count from the `bench/loop-count.ir` structural benchmark, a ninth
workload discovered as a side effect of the plain regression run rather
than this probe set -- see "Full regression" below).

An aside, not attributable to M6: three of these probes'
**committed** `audit/comprehensive-generated-code/artifacts/*/summary.txt`
files (`steady-ascii-capture`, `web-unreserved-256`,
`web-unreserved-literals`) were already stale *before* M6 -- they predate
several already-landed, unrelated improvements (`ascii::is_digit` and its
neighbors specializing from `<generic>` to `<int>` and losing a
`guardbool`; `byte::set`'s `setfromlist` becoming `setfromlisttotal`).
Comparing directly against those committed files would have wrongly
attributed several earlier milestones' gains to M6; the pre-M6 worktree
baseline above avoids that. These committed audit artifacts were not
refreshed by this milestone (regenerating and re-curating that whole
directory is a documentation-maintenance task orthogonal to M6's own
scope), but are flagged here since the mismatch could otherwise mislead a
future milestone's own before/after comparison the same way.

## uri-steady / refined-checks / web-unreserved-256 structural deltas

All three tables below compare the same true pre-M6 baseline (M5 tip
`7b2ed38`) against this milestone's own tip, via `probe.tcl`'s
`summary.txt`. `web-unreserved-256` itself shows no delta (its own
`byte::set` call path resolves to the shared, mixed-caller instance
below); `web-unreserved-literals` is reported instead, since it is the
probe that actually exercises the changed `byte::from_int<int>` instance
via a literal-shaped caller.

**`uri-steady`** (`bench/uri-steady.bot`, `-specialize 1`):

| metric | before | after |
|---|---|---|
| NIR functions | 17 | 17 (unchanged) |
| machine code bytes (whole program) | 7103 | 7055 (-48) |
| `byte::from_int<int>` NIR regs | 9 | 8 |
| `byte::from_int<int>` machine code bytes | 337 | 289 (-48) |
| `byte::from_int<int>` `br` count | 2 | 1 |
| `byte::from_int<int>` `fail` count | 2 | 1 (`BelowRange` gone) |
| static/constant allocations (whole program, one run) | 32 | 31 |
| dynamic allocations/bytes (one run) | 61510 / 2544568 | unchanged |

**`refined-checks`** (`bench/refined-checks.ir`):

| metric | before | after |
|---|---|---|
| NIR functions | 33 | 33 (unchanged) |
| machine code bytes (whole program) | 16791 | 16743 (-48) |
| `byte::from_int<int>` regs/bytes/br/fail | 9 / 337 / 2 / 2 | 8 / 289 / 1 / 1 (identical shape to `uri-steady`) |
| `check<int, int, str, str>` NIR regs | 28 | 27 |
| `check<int, int, str, str>` `br` count | 4 | 3 |
| `check<int, int, str, str>` `unreachable` count | 1 | 0 |
| `check<int, int, str, str>` machine code bytes | 504 | 504 (unchanged -- register-count drop with no code-size effect) |

`check`'s own diff is a *different* pattern from `byte::from_int`'s: a
syntactically pre-existing `KnownOutcome`-decided arm that used to lower
to `br ... ; label Ldead: unreachable` now lowers with no `br` and no
`unreachable` trap at all (the "before/after" section above, generalized:
this is the pre-existing-syntactic-case improvement, not a new range
theorem). Its register count drops by one (the join register the old
two-arm-plus-unreachable shape needed) with no change in machine code
bytes -- register renumbering absorbed by the allocator with no size
effect, not a missing optimization.

**`web-unreserved-literals`** (`audit/comprehensive-generated-code/probes/web-unreserved-literals.bot`):

| metric | before | after |
|---|---|---|
| NIR functions | 16 | 16 (unchanged) |
| machine code bytes (whole program) | 6020 | 5972 (-48) |
| `byte::from_int<int>` regs/bytes/br/fail | 9 / 337 / 2 / 2 | 8 / 289 / 1 / 1 (identical shape) |
| static allocations (one run) | 27 | 26 |

All three corpora show the exact same 48-byte-per-instance
`byte::from_int` delta (it is the same shared instance, reached from
different call graphs in each probe) plus, in `refined-checks` only, the
independent `check` cleanup. No other function in any of the eight probed
workloads changed at all -- the negative controls (`steady-ascii` and its
param/capture variants, `ascii-256`, `web-unreserved-256`) are
byte-for-byte identical before and after, confirming the mechanism does
not move code it has no theorem for.

## Effect-summary fallout

`byte::from_int<int>`'s own `may_error` status in every probed workload
remains `true` after M6 (confirmed directly in each `roots.txt`/
`summary.txt`): eliminating `BelowRange` alone does not make the function
non-fallible, since `AboveRange` remains a live, structurally reachable
`fail`. This is exactly the expected, proportionate result -- `may_error`
is recomputed structurally from the smaller CFG (native/src's own
pre-existing per-function recomputation, untouched by this milestone; no
effect summary was hand-edited anywhere), and it only ever changes when
*every* fallible path out of a function is eliminated. The `work`
function in `bench/loop-count.ir` (the one case where a whole branch,
not just one comparison of two, was eliminated) shows this the other way:
it had no `fail`/error path to begin with (`may_error=false` before and
after), so its own register-count drop is a pure register-pressure/CFG
effect with no effect-summary consequence to observe. No probed workload
in this corpus had a function whose *entire* fallibility was proven
impossible by M6 alone.

## Allocation / GC / roots fallout

Measured directly (`native::roots`/`allocationReport`, before vs. the true
pre-M6 baseline, same probes as above): dynamic allocation counts and
byte totals are unchanged in every probed workload (`uri-steady`:
61510 allocations / 2544568 bytes, identical). Only **static** (module-
init-time constant) allocation counts drop by exactly one in each workload
that lost `byte::from_int`'s `BelowRange` arm (`uri-steady` 32->31,
`web-unreserved-literals` 27->26, `refined-checks` 40->37 -- the larger
drop there reflects `check`'s own additional cleanup) -- each is the
`BelowRange`/dead-arm's own no-longer-constructed error-kind constant, not
a semantic allocation-behavior change (M6 spec #60 explicitly permits
this: "allocation invariance is not an M6 requirement... any allocation
movement must be attributable to a proven-dead branch," which this is).
`work`'s own root/safepoint shape (`bench/loop-count.ir`, see "Full
regression" below) is unaffected beyond its register count: `safepoints:
0` and `shadow slots: 0` both before and after, since it made no
allocating call either way. No root candidate, safepoint, or shadow slot
disappeared anywhere in the probed corpus as a result of this milestone --
every eliminated branch in every measured case was allocation-free at
runtime (the `fail`/`unreachable` control-flow shapes themselves, and the
one constant each `fail` used to construct, not a runtime allocation
site).

## Compile-time cost

`hir::range::ConditionOutcome` is a handful of dict lookups and arithmetic
comparisons per `if`; it triggers no re-analysis (`hir::range::analyze`
itself is unchanged, called exactly once as before, same call site).
Consistent with that, the full two-backend Tcl regression suite's own
wall-clock time (`time tclsh9.0 tests/all.tcl`, ~2185 tests x 2 backends,
dominated by `stdlib.test`'s own program execution, not by compilation)
showed no attributable regression: successive runs on this shared,
otherwise-idle host measured within their own run-to-run noise band (both
in the 10-11 minute range), and no individual probe's `probe.tcl`
invocation (each a single compile-and-lower pass) took perceptibly longer
after this milestone than before.

## Timing

Structural correctness (above) is the primary evidence per spec #78;
per-workload native execution timing was not separately re-run beyond the
structural probes above, since none of the changed functions
(`byte::from_int`, `check`, `work`) sit on any hot per-call path measured
by this repository's own `bench/*.tcl`/`tools/bench-baseline.sh`
methodology in a way this milestone's own scope calls for re-measuring
(`byte::from_int`/`check` are called once each per probed program; `work`
is `loop-count.ir`'s own hot loop body, but its change is a register-count
reduction with no correctness or algorithmic change, not expected to move
wall-clock time outside host noise). No regression is claimed or expected
beyond the structural deltas already reported.

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

```
tclsh9.0 tests/all.tcl                            -> interp: 2185/2185, compile: 2185/2185, 0 failed
cargo test --release --manifest-path native/Cargo.toml
                                                   -> 60/60 passed (unchanged from M5: no Rust code changed)
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl -> interp: 2185/2185, compile: 2185/2185, 0 failed
```

The plain run found exactly one real, expected diff on first pass:
`tests/native-root-liveness.test`'s `root-structural-2` (`bench/loop-
count.ir`'s own `work` function, register count 17 -> 16 -- see the golden
update and its explanatory comment in that test file, and the structural
delta table above). After that one golden-value update, both backends
pass at 2185/2185 with **zero** other diffs anywhere in the suite --
`tests/hir-range.test`'s own 12 new `ConditionOutcome` unit tests, and
`tests/checked-domain-proof-provenance.test`'s updated Q1/Q2/Q3/
architecture-pin expectations, are included in that 2185 total. The
GC-stress run (mandatory per this repository's own native stack-map/root
validation discipline) reproduces the identical 2185/2185 result on both
backends with no additional failures, confirming the smaller root
maps/CFGs the eliminated branches leave behind remain sound under an
aggressively colliding allocator, not merely under the default GC
cadence.

Focused suites (all re-run individually, exact counts):

```
checked-domain-proof-provenance.test    17/17
byte-set.test                           21/21
source-types.test                       46/46
errors.test                             40/40
hir-specialize.test                     27/27
typed-parameters.test                   50/50
setcontains-equality-total.test         17/17
setfromlist-equality-total.test         14/14
hir-callable-target.test                 8/8
```

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

## Required architecture questions

1. **Canonical prover for branch outcome?** `hir::range::ConditionOutcome`
   (hir/range.tcl), composing `hir::types::KnownOutcome` with
   `hir::range::analyze`'s already-settled per-instance operand facts.
2. **Does `native::lower::If` perform semantic range reasoning itself?**
   No -- it calls the one query and switches on `1`/`0`/`""`.
3. **Exact values the query returns?** `1` (always true), `0` (always
   false), `""` (unknown) -- `hir::types::KnownOutcome`'s own convention.
4. **Consumes already-computed facts rather than rerunning analysis?**
   Yes -- `hir::range::analyze` is called exactly once, at the same call
   site as before this milestone; the query only reads `hir::range::of`.
5. **Existing `KnownOutcome` cases preserved?** Yes, and improved: they no
   longer emit a redundant `br`/`unreachable` pair either (see `check`'s
   own delta above).
6. **Is theorem scope represented correctly?** Yes -- every fact consumed
   is an instance-level joined fact (`hir::range::analyze`'s own
   interprocedural fold), never a call-specific one.
7. **Can call-specific facts accidentally prune a shared function
   instance?** No -- confirmed by the shared-instance adversarial control
   (both checks retained when even one caller is genuinely unconstrained).
8. **Any Byte-specific branch logic?** No -- confirmed by the identical
   `Small = Int in 10..20` reproduction of every Byte fixture.

## Required proof-provenance questions

For the primary fixture (a Byte/domain-typed parameter's own comparison):
9. **Theorem needed:** the parameter's value lies within its declared
   domain at this program point. 10. **Canonical prover:**
   `hir::range::ConstrainType`/`TypeFact`, feeding `hir::range::analyze`'s
   per-instance fixpoint (both pre-existing). 11. **Currently proved?**
   Yes, and was already computed before this milestone. 12. **Scope:**
   instance-level (every `ref` of the parameter within that specialization
   instance). 13. **Materialized where?** `hir::range::of $analysis $id
   $exprId`'s per-instance `exprs` table. 14. **Transport to lowering?**
   Direct -- `native::lower.tcl` already held `$ranges`/`$currentInstance`
   for representation decisions; the new query reads the same table. 15.
   **First loss:** ignored (Outcome A) -- the fact reached the table;
   nothing asked `hir::range::Narrowed`'s own already-computed
   hypothetical-empty-range question about it. 16. **If missing, was it
   deliberately left unimplemented?** N/A here (it was not missing); see
   the container-content-propagation and condition-purity theorems in the
   backlog, both deliberately left unimplemented.

## Required byte::from_int questions

17. **Does `byte::from_int(45)`'s call-specific completion proof now
    directly prune the shared callee body?** No -- the elimination in the
    safe-only-caller case comes entirely from `hir::range`'s own
    instance-level joined fact (this call being the instance's only
    caller), never from `hir/completions.tcl`'s call-specific silo.
18. **Does an instance whose entry range is provably within Byte
    eliminate its two failure branches?** Yes, confirmed directly
    (`checked-domain-q1-real-byte-from-int-still-emits-both-checks`,
    updated result `{1 1 0 0}`).
19. **Does a mixed dynamic instance retain needed branches?** Yes,
    confirmed (shared-instance adversarial control, both checks retained).
20. **Does `byte::set(['Ā'])` remain a known/runtime error as
    appropriate?** Yes, unchanged
    (`checked-domain-byte-set-astral-still-fails`/
    `-known-error-at-compile-time`, both still passing verbatim).
21. **Does the frozen URI punctuation initializer improve at all?** Yes,
    partially and generically: `BelowRange` is eliminated (`char::
    codepoint`'s own declared floor), `AboveRange` is not (still genuinely
    `Unknown` for this shared instance) -- see "M5 `byte::from_int`
    reassessment" above.

## Required range questions

22. **Does a Byte parameter prove `b < 0` false?** Yes.
23. **`b > 255` false?** Yes.
24. **`b < 100`?** Unknown, confirmed with a two-literal-caller control
    spanning the threshold.
25. **Does a `Small` (`10..20`) parameter prove `x < 10` false?** Yes
    (`condition-outcome-5`, reproduced generically).
26. **Does HighNibble prove impossible exact values where exact-set facts
    survive?** Yes (`x == 17` -> `AlwaysFalse`, `condition-outcome-11`).
27. **Exact-set budget boundary behavior?** Not separately re-verified
    beyond HighNibble's own 16-member set (well inside the 32-value
    budget); the query adds no exact-set logic of its own; degradation
    beyond budget is `hir/range.tcl`'s own pre-existing, unchanged
    behavior (`tests/hir-range-exact.test`).
28. **Arbitrary-precision Int semantics preserved?** Yes -- confirmed by
    the open/dynamic broad-Int control staying `Unknown`; no bound ever
    assumes a machine-word width.

## Required lowering questions

29. **AlwaysTrue lowers to?** The `then` body only, straight-line, no
    `br`, no `else` label, no join.
30. **AlwaysFalse?** Symmetric, the `else` body only.
31. **Unknown?** The pre-existing `br`/two-labels/join form, unchanged.
32. **Condition evaluation preserved where it may have effects?** Yes,
    unconditionally, for every outcome -- confirmed directly (`op
    rilt`/`op rigt` remain as dead computations under a decided outcome).
33. **Did M6 add a semantic evaluator to lowering?** No.
34. **Did M6 add a general CFG optimizer?** No -- only the minimal
    dead-arm/branch omission described above; no block-merging pass.

## Required generated-code questions

35. **Conditional branches eliminated in `uri-steady`?** One
    (`byte::from_int`'s `BelowRange` check; `br` count 2 -> 1).
36. **In `refined-checks`?** Two (`byte::from_int`'s, plus `check`'s own
    pre-existing-syntactic-case cleanup; `br` counts 2->1 and 4->3
    respectively).
37. **How many were existing `byte::from_int` checks?** One per probe
    (`BelowRange`), consistently, everywhere the shared instance appears.
38. **Unrelated user-code `if`s changed?** Yes -- `check` in
    `refined-checks.ir`, and `work` in `bench/loop-count.ir` (a
    hand-written IR benchmark, not user Botlish source, but not a
    `byte::from_int`-family function either).
39. **Were all changes backed by explicit canonical theorems?** Yes --
    each is traced to a specific pre-existing fact (`char::codepoint`'s
    `nonneg` metadata; `drive`'s induction-derived `i` range; a
    syntactic `KnownOutcome`) in the sections above.
40. **Did any previously-fallible function naturally become
    non-erroring?** No -- `byte::from_int` keeps `may_error=true`
    (`AboveRange` remains); no probed function's fallibility fully
    cleared.
41. **Did any root/safepoint disappear because its only use was dead?**
    No -- every probed elimination was allocation/safepoint-free either
    side.
42. **Did allocations change?** Only static (module-init-time) constant
    counts, by exactly one per eliminated `fail`'s own no-longer-built
    error-kind constant; dynamic allocation counts/bytes are identical.

## Required missing-theorem questions

43. **Every important branch that remains emitted despite seeming
    decidable, with theorem/owner/reason/scope/consumers:** see "Missing-
    theorem findings" and the "Post-M6 first-loss matrix" above
    (container-content propagation; condition-expression purity;
    `!=`/`not`-of-comparison composition).
44. **Highest-value candidate (not implemented here)?**
    Container-content propagation -- it is the one that would close the
    actual real-production `byte::set` case M5 first raised, and per
    "Recommended next milestone" above, RC1/instance-selection sharpening
    is judged even higher-value corpus-wide, since it would let more
    existing instances reach the shape this milestone already exploits.

## Required scope questions

45. **Was `hir/completions.tcl` merged into range analysis?** No.
46. **Were completion-call-specific facts imported into native
    lowering?** No.
47. **Was `KeyType` changed?** No.
48. **Was closure specialization/family 1b changed?** No.
49. **Was inlining changed?** No.
50. **Was loop unrolling added?** No.
51. **Was source syntax changed?** No.
52. **Was any frozen `.bot`/`.ir` workload modified?** No.
