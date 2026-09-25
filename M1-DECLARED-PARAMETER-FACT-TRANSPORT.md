# M1: declared-parameter fact transport into every instance

## Outcome

Implemented and measured. `hir::specialize::Analyze` now seeds a block's
own parameters, for *every* instance it builds (generic included), from
the function's own `declaredParamTypes` wherever one exists, before its
existing caller-derived refinement (`RefineParams`) runs. `RefineParams`
itself was changed from a blind replace to a union (`hir::types::narrow`),
so caller-proven named-refinement evidence can only add to the declared
floor, never silently drop it. Nothing else changed: the specialization
key (`KeyType`), closure-specialization policy, module-value
representation, inlining, control-flow pruning, and every frozen
`.bot`/`.ir` source program are untouched.

The measured effect matches RC1's own predicted fix (family **1a**,
`COMPREHENSIVE-GENERATED-CODE-AUDIT.md` line 1705) exactly, including its
specific prediction: "removes typed-param guards; makes `is_unreserved` →
`is_alphanumeric` an `<int>` call even while `is_unreserved` stays
generic." That is precisely what happened -- and it went one step further
than the audit's own conservative framing (spec item 45): every ASCII
generic instance the URI/web path used (`is_digit`, `is_upper`,
`is_lower`, `is_alphabetic`, `is_alphanumeric`) did not just get a better
*view* while keeping its `<generic>` label -- it stopped existing as a
separate instance at all, and every exact call that used to route to it
now resolves to the **same, already-existing** `<int>` instance the
positive control uses. `web::is_unreserved` itself, whose own generic-ness
comes from capturing a non-Int module value (unaffected by this
milestone), is the only instance left `<generic>` on the URI path, exactly
as spec item 10 anticipated -- but its own parameter view is now `Byte`,
not `any`.

Structural results, uri-steady (whole program, includes module init):

| metric | before | after |
|---|---:|---:|
| NIR functions | 17 | 17 |
| machine code bytes | 8167 | 7155 (-12.4%) |
| generic instances | 14 | 9 |
| int/raw instances | 1 | 6 |
| other instances | 2 | 2 |
| `guard int` ops | 10 | 7 |
| call/callenv ops | 17 | 17 |
| tagged i-arith ops | 6 | 6 |
| allocations / bytes | 61510 / 2544568 | 61510 / 2544568 (unchanged) |

Timing (native/Cranelift, best-of-7, 5 sessions, JIT compile excluded, same
M0 methodology): median 6031.37us -> 5440.06us (-9.8%), min 6019.10us ->
5135.29us (-14.7%). Structural change is the primary evidence (spec item
78); timing corroborates in the same direction, inside this shared host's
noise band (M0's own spread was ~17%; this session's before/after spreads
were 2.4%/8.5%).

## Why declared parameter contracts are valid instance assumptions

A declared parameter type `T` on `fn f(x: T): ...` is enforced, before
`hir::specialize` ever runs, by `hir::range::verifyDeclaredParams`
(`hir/range.tcl:1092`): a single, non-interprocedural, whole-program pass
that walks every call in the program (once, over the *semantic* HIR) and
diagnoses a compile-time `TYPE` error at any call whose target resolves to
an exact known block (`VerifyCall`, `hir/range.tcl:1140`, gated on
`target` being `{block B}`, i.e. `hir::types::Call`'s own exact-callee
resolution, `hir/types.tcl:987`) and whose argument cannot be proven
admissible for `T` -- by type identity or by a proven range fact
(`ProvesValueAcceptedBy`). This runs to completion before `hir::specialize`
exists, so by the time any instance is ever built, every legal call in the
program has already discharged `T`'s obligation for that call's argument.

`T` is therefore an unconditional fact for *every* execution of `f`'s
body, independent of which instance a particular caller's argument
representation happened to select (`hir::types::Block`'s own seeding of a
declared parameter type at initial whole-program inference,
`hir/types.tcl:889`, already treats it this way for the semantic function
-- this milestone's own change is to stop *losing* that fact when
`hir::specialize::Analyze` re-infers one particular instance's region).

## Invocation-path soundness audit

`VerifyCall` only ever fires for a call whose `target` is `{block B}`: an
*exact*, statically-known callee. Every other invocation path was audited
against whether a *typed* (parameter- or error-bearing) callable can ever
reach an invocation the verifier does not see:

- **Direct/exact calls** -- checked by `VerifyCall` directly. This is the
  overwhelming majority of calls in the fenced corpus and the entire
  URI/ASCII chain.
- **Cross-module calls** -- a qualified reference (`web::is_unreserved`,
  `ascii::is_digit`) resolves to the same exact `{block B}` target
  mechanism; M0's own qualified-reference capture fix
  (`8041168`) did not change this resolution, only module-closure
  reachability. Confirmed unaffected: all C2 regression tests still pass
  (`typed-callable-escape.test`, `typed-parameters.test`: 85/85).
- **Calls through captured function values** -- a closure that captures a
  callable and later calls it does so through an ordinary `ref` of an
  immutable binding. `hir::callables.tcl`'s own header
  (`hir/callables.tcl:127-132`) establishes that an immutable local
  binding's type is *exactly* its value's type (`hir::types::Bind`), so a
  captured typed callable's exact `{block B arity result}` identity
  survives into the closure unchanged, and any call it makes through that
  capture is still an exact `{block B}` call `VerifyCall` sees.
- **Materialized Block/callable values (first-class escape)** -- this is
  the one path that would otherwise be a soundness hole: a typed
  callable's value stored, returned, or passed such that its exact type
  degrades to a bare `block`/`any` kind before any later call. This is
  exactly what `hir/callables.tcl` (`TYPED-CALLABLE-ESCAPE-SOUNDNESS.md`)
  closes: `hir::callables::verify` rejects, at compile time, every
  position that would erase a *Bearing* callable's (one with a declared
  parameter type or a declared error set, `hir::callables::Bearing`,
  `hir/callables.tcl:46`) exact identity -- an ordinary call argument, an
  `if`/loop-break join with a different callable, a function-level return,
  or a Result wrapper. A **consequence worth stating plainly**: a typed
  callable therefore *cannot* be stored in a heterogeneous List at all
  under current semantics (list construction lowers to native calls, and
  every non-callee call argument is checked by `CheckPreserved`) -- so
  "callables stored in containers" (spec item 5) is not a live path for a
  Bearing callable today, not merely an audited-safe one.
- **Higher-order passing through an *untyped* parameter** -- this is
  exactly `TYPED-CALLABLE-ESCAPE-SOUNDNESS.md`'s own worked example
  (`apply(take_byte, 9999)`): passing a typed callable as an ordinary call
  argument is one of the erasure positions `hir::callables::verify`
  rejects, so this is a compile-time error, not a runtime path.
- **Tail calls and recursive calls** -- a self/recursive call inside `f`'s
  own body is just another expression `hir::range::verifyDeclaredParams`'s
  own local, non-interprocedural walk already covers (`hir/range.tcl:1084`'s
  own comment: "a recursive call's own argument checked soundly ... no
  separate recursion handling needed").
- **Module functions vs. user functions** -- both resolve through the
  identical `{block B}` exact-target mechanism; nothing in
  `hir::modulebinding.tcl` changes call-target resolution, only
  cross-module value/reachability wiring (M0's own subject).

No unsound path was found. `hir::callables.tcl` was **not modified** by
this milestone -- it was audited, not extended, and its own existing
coverage is exactly sufficient for M1a to trust `declaredParamTypes`
inside a generic instance's own re-inference.

## Previous vs. new seed behavior

**Before.** `hir::specialize::Analyze` (`hir/specialize.tcl`, previously
lines 473-483) seeded a block's own parameter bindings, for its own
per-instance region re-inference (`hir::types::inferRegion`), from nothing
but the instance's *key type* -- `any` for every parameter of a generic
instance, by construction (`hir::specialize::Instance`'s own generic test:
"every key type is any"). `RefineParams` could widen this afterward with
caller-proven *named-refinement* evidence (`RefinementFacts`), but only
when the key type already had a concrete base kind
(`core::type::base $keyType ne ""`) -- which is never true for a generic
instance's own key. The result: the very re-inference this instance's own
overlay is built from started from strictly *less* information than the
original whole-program semantic pass already had for the same
expressions (which *did* seed `declaredParamTypes` directly,
`hir/types.tcl:889`, since that pass runs outside any per-instance
region). Because `Analyze`'s overlay only records an expression's type
when it *differs* from the semantic pass's own type
(`hir/specialize.tcl` `Analyze`, the `overlay` construction), a coarser
per-instance result was recorded as an override, actively discarding the
already-proven declared fact for every ref inside that one instance's
view. This is RC1's literal mechanism, not merely its symptom.

**After.** Before calling `RefineParams`, each parameter's seed is
narrowed by its own `declaredParamTypes` entry, if any
(`hir/specialize.tcl`, `Analyze`):

```tcl
foreach b [dict get $state hir exprs $block params] type [dict get $instance args] \
        declaredType [dict get $state hir exprs $block declaredParamTypes] {
    if {$declaredType ne {} && ![hir::types::IsSpecific $type]} {
        set type [expr {[hir::types::IsSpecific $declaredType]
            ? $declaredType : [hir::types::narrow $type $declaredType]}]
    }
    dict set types $b $type
}
RefineParams $block types
```

For a generic instance (key type `any`), this simply adopts the declared
type. For an already-specialized scalar instance (key type e.g. `int`),
`hir::types::narrow` unions the declared type's evidence into the key
type -- it can only *add* precision, never remove the key's own kind
information. The `IsSpecific` guard on `type` leaves an aggregate/callable
key (a shaped List from an exact call, say) untouched rather than routing
it through `hir::types::narrow`, whose own contract ("Narrows CURRENT by a
proven FACT (a core type)") does not cover combining two aggregate forms;
the `IsSpecific $declaredType` branch instead adopts an aggregate declared
type (`List[T]`, `ImmutableSet[T]`) wholesale when the key had no
structural information to lose (`any`/`never`) -- `core::type::narrow`
cannot be called with a list-shaped fact at all (`core/type.tcl::normalize`
has no notion of a `list` form; this was caught by this milestone's own
container fixture test, see below, and fixed before it ever reached a
frozen benchmark).

`RefineParams` itself changed from a hard replace to a union:

```tcl
dict set types $b [hir::types::narrow $keyType [core::type::Make $base [dict get $blockFacts $b]]]
```

Before this milestone, `types[$b]`'s own evidence was always empty by the
time `RefineParams` ran (key types are always bare kinds, per
`KeyType`'s own docstring: "kinds, evidence dropped"), so `Make` and this
union coincide exactly for every pre-M1-reachable state -- this is a
strict no-op change for every program this milestone did not touch, and
only takes effect now that the declared-type pre-seed can leave real
evidence in `types[$b]` before `RefineParams` runs. Its purpose is to make
the combination monotonic (spec item 26): a caller-proven named-refinement
set that happens not to repeat the declared type's own evidence name must
never silently overwrite it.

## Implementation change

One file, two related edits, both in `hir::specialize`
(`hir/specialize.tcl`):

1. `Analyze`'s parameter-seeding loop narrows each parameter's seed by its
   `declaredParamTypes` entry (if any) before calling `RefineParams`.
2. `RefineParams`'s own final assignment unions with the key type's
   existing evidence via `hir::types::narrow` instead of replacing it.

No other file changed except the new tests (`tests/hir-specialize.test`).
`hir/range.tcl`, `native/lower.tcl`, `nir.rs`, `clif.rs`, `lib/`, and every
frozen `.bot`/`.ir` program are untouched. `git diff --stat`:

```
hir/specialize.tcl        | 34 ++++++++++++++++++--
tests/hir-specialize.test | 80 +++++++++++++++++++++++++++++++++++++++++++++++
```

`SemanticInstances` (the `-specialize 0` positive-control path) was left
alone: it never calls `inferRegion` at all, reusing the whole-program
semantic types directly, which already carried declared parameter facts
correctly before this milestone (spec item 23's own "positive control").
A shared seed helper (spec item 24) was not introduced: the two paths
build their per-instance parameter dict in structurally different ways
(one reuses the already-computed semantic HIR wholesale; the other
re-infers a region fresh), and the one line this milestone adds is already
the smallest form the shared idea takes without forcing a bigger refactor
than the fix warrants.

## Fixtures

Six new tests in `tests/hir-specialize.test` (`hir-specialize-m1-*`),
inspecting the instance's own view directly (the same "first ref to the
parameter binding, in the view HIR" technique
`audit/comprehensive-generated-code/tools/probe.tcl`'s `params.txt` uses),
not just its result type:

- **Generic + closure fixture** (`m1-closure-capture`, spec items 35-36):
  a typed function (`cls(b: Small)`) forced into a generic instance by a
  non-Int capture. Before M1 this is exactly `ascii::is_digit<generic>`'s
  own shape; the synthetic fixture isolates it from web/URI moving parts
  as spec item 35 asks. View type: `any` -> `int[Small]`.
- **Generic + explosion-control fixture, with an untyped-parameter control
  in the same test** (`m1-explosion-generic`, spec items 3, 28, 35): a
  typed function forced generic by `hir::specialize::limit` exhaustion
  (the same technique `hir-specialize-12` already uses) on a *second*,
  untyped sibling parameter. `b: Small`'s view goes `any` -> `int[Small]`;
  `tag` (undeclared) stays `any`, confirming spec item 28 in the same
  program.
- **Broad `int` control** (`m1-broad-int`, spec item 29): a generic
  instance's declared `x: int` parameter is seeded as `int`, never
  narrowed to a small raw-eligible range -- confirming M1 does not invent
  a range fact `hir/range.tcl`'s own machinery did not independently
  prove.
- **Container fixture** (`m1-container`, spec item 32): `ys: List[Small]`
  forced generic by a non-Int capture; view goes `any` -> `List[int[Small]]`.
  This test is also what caught and pinned down the aggregate-type crash
  fixed by the `IsSpecific` guards above.
- **Module-closure fixture, the real `web::is_unreserved` class**
  (`m1-module-closure`, spec item 37): loads `bench/uri-steady.bot`
  directly (not a synthetic stand-in) and asserts `web::is_unreserved`'s
  generic instance's `b` view is `int[Byte]`.
- **Exact-call propagation** (`m1-exact-call-propagation`, spec item 21's
  own "A" question): asserts that, on the same real program, `cls` stays
  `<generic>` while its own exact calls to `ascii::is_alphanumeric` and
  `ascii::is_digit` now resolve to their *already-existing* `<int>`
  instances -- pinning down the collapse described in "Outcome" above as a
  regression-tested fact, not just a benchmark observation.

All six pass on both `interp` and `compile` backends. A dedicated
adversarial test for the `RefineParams` union fix specifically (spec item
27's "contradictory facts" scenario) was not constructed: building a
natural Botlish program where a callee stays generic *and* every caller's
named-refinement evidence excludes the declared type's own name turned
out to be difficult precisely *because* of this milestone's own
exact-call-propagation effect (a caller that itself now carries the
correct declared fact tends to make the callee specialize rather than
stay generic with divergent evidence -- see `m1-exact-call-propagation`).
The union fix is retained anyway as a defensive, provably-sound-by-
construction safeguard (`hir::types::narrow`'s own postcondition), not
because a reachable failure was found without it.

## Untyped-parameter control

Covered directly by `m1-explosion-generic` (above) and, unchanged, by
every pre-existing `hir-specialize-*` test whose functions have no
declared parameter types (e.g. `hir-specialize-1` through `-12`, all still
passing with their original expected results unchanged -- meaning M1
introduced no new assumption for an undeclared parameter anywhere in the
existing suite).

## Byte fact trace

For `web::is_unreserved(b: Byte)`'s generic instance:

```
declaredParamTypes[0] = int[Byte]              (STRICT-TYPED-PARAMETERS.md,
                                                 resolved once at hir/resolve.tcl)
    |  Analyze's new seed step: type = any -> hir::types::narrow(any, int[Byte])
    v
instance seed:        int[Byte]                (a "refined" core type: base=int,
                                                 evidence={Byte})
    |  hir::types::inferRegion re-runs Sequence/Expr with ctx.types[b] = int[Byte]
    v
overlay (if recorded): every ref to b now types as int[Byte], matching the
                        semantic pass -- no downgrade, so most such refs
                        need no overlay entry at all; the *view* HIR simply
                        falls through to the already-correct semantic type
    |  hir/range.tcl's own AnalyzeInstance, reading the view HIR
    v
TypeFact/ConstrainType: int[Byte] -> the registered Byte integer domain,
                        [0, 255] (SOURCE-DEFINED-INTEGER-DOMAINS.md; not
                        encoded by this milestone -- read from the existing
                        type registry via core::type::integerFacts)
    |  hir::range's own raw-eligibility test on that entry range
    v
fitsSmall: [0,255] fits a raw machine int -> raw compare lowering
           (native/lower.tcl, unmodified) instead of a tagged/guarded one
```

Verified directly (`audit/comprehensive-generated-code/tools/probe.tcl`
`params.txt`, `web-unreserved-256`/`uri-steady` probes):

```
before: i9  web::is_unreserved<generic>
            param b: declared=int[Byte] first-ref-view-type=any        entry-range=[-∞, +∞]
after:  i9  web::is_unreserved<generic>
            param b: declared=int[Byte] first-ref-view-type=int[Byte]  entry-range=[-∞, +∞]
```

(`is_unreserved`'s own entry-range stays `[-∞, +∞]` rather than `[0,255]`
because it is an **open** instance -- its block materializes as a
first-class captured value passed through `esc_char`/`esc_from`/
`repeat_uri`'s own parameter lists, so `hir::range`'s caller-propagation
fixpoint correctly declines to narrow its entry facts from an incomplete
caller set, spec items 28-29's own documented rule, unaffected by this
milestone. The *type* fact (`int[Byte]`) is unconditional and does not
depend on knowing every caller, unlike a *range* fact, which is why it
still transports correctly here.)

## ASCII leaf before/after

`ascii::is_digit`'s own generic instance no longer exists in any of the
measured workloads: every call that used to select it now selects the
*already-existing* `<int>` instance instead (see "Outcome" and the
`m1-exact-call-propagation` fixture). Machine code, `steady-ascii-capture`
probe:

```
before: is_digit<generic>  regs=12  bytes=377  guard=1 op:ige=1 br=2 op:ile=1
after:  is_digit<int>      regs=13  bytes=74   op:runbox=1 op:rige=1 br=2 op:rile=1
```

`bytes=74` for the post-M1 instance is not a *new*, smaller generic form:
it is byte-for-byte the pre-existing `<int>` instance's own code
(`steady-ascii-param`'s `is_digit<int>` was already `bytes=74` before this
milestone -- confirmed identical in both probes' `nir.txt`). The guard,
the tagged `ige`/`ile` compares, and the separate generic code body are
gone because the generic *instance itself* is gone, not merely improved.
Identical shape for `is_upper`, `is_lower` (both `377 -> 74` bytes, `guard
int` removed, tagged compares become `runbox`+raw `rige`/`rile`).

## ASCII composition before/after

`is_alphabetic`/`is_alphanumeric` (which call `is_upper`/`is_lower` and
`is_alphabetic`/`is_digit` respectively, never inlined, per spec item 46)
did not have their own `guard int` before or after -- their reduction
(`164 -> 125` bytes) comes entirely from the caller-side residue for a
call whose callee is no longer `may_error`: the `test rax,rax`/branch a
caller emits to check a fallible callee's result shrinks away once the
callee provably cannot fail (see "may_error propagation" below). Verified
directly in the disassembly (`asm.txt`, `ascii::is_alphanumeric`, both
calls):

```
before (<generic>, calls is_alphabetic then is_digit):
    call   botlish_fn_7          ; is_alphabetic
    test   rax,rax               |
    je     ...                   |  may_error retest, removed after M1
    cmp    rax,0x6
    je     ...
    ...
    call   botlish_fn_4          ; is_digit
    test   rax,rax               |
    jne    ...                   |  may_error retest, removed after M1
after (<int>, same two calls):
    call   botlish_fn_7          ; is_alphabetic
    cmp    rax,0x6
    je     ...
    ...
    call   botlish_fn_4          ; is_digit
    cmp    rax,0x6
    je     ...
```

Each `test rax,rax`+conditional-jump pair (the error-propagation check
`native/lower.tcl` emits for a call whose effect summary says
`may_error=true`) is gone, one pair per call, exactly matching the two
calls `is_alphanumeric` makes. No comparison lowering changed (spec item
61/46): the byte delta is call-site retest removal (`native/lower.tcl`,
unmodified, simply has less to emit for a call whose summary is now
`may_error=false`), not different codegen for the comparisons themselves.

## `may_error` propagation before/after

`effects.txt` (`uri-steady` probe), the entire ASCII/URI call chain:

| caller -> callee | before | after |
|---|---|---|
| `is_alphabetic` -> `is_upper` | may_error=true | **may_error=false** |
| `is_alphabetic` -> `is_lower` | may_error=true | **may_error=false** |
| `is_alphanumeric` -> `is_alphabetic` | may_error=true | **may_error=false** |
| `is_alphanumeric` -> `is_digit` | may_error=true | **may_error=false** |
| `web::is_unreserved` -> `is_alphanumeric` | may_error=true | **may_error=false** |
| `esc_char` -> `web::is_unreserved` | may_error=true | may_error=true (unchanged) |

The first five collapse exactly as spec items 16/43 predicted, entirely
from `nir.rs::summarize_call_effects`'s existing, **unmodified**
structural analysis recomputing `may_error=false` once the only fallible
op (the now-removed `guard int`) is gone -- no effect-analysis logic was
touched to get this.

The last edge does *not* collapse, and this is itself informative (spec
item 56's own prediction that "the new first loss may now be tagged call
ABI rather than generic instance seed"): `esc_char` receives
`web::is_unreserved` as one of its own **parameters** (a first-class
function value forwarded down from `uri_escape_text`), so `esc_char`'s
call to it is an indirect/call-through-value dispatch, not a direct NIR
`call` of a statically-known target. That is a call-boundary/ABI
conservatism this milestone deliberately does not touch (spec items 59-61:
"no raw parameter ABI," "expected residual cost... a function call...
caller Bool retest"), not a leftover instance of RC1. `is_unreserved`'s
*own* body, called from anywhere, has no fallible op left in it.

## `uri-steady` structural delta

See "Outcome" table above for the full column set (spec items 39, 82).
Per-column notes:

- **generic instances 14 -> 9, int/raw instances 1 -> 6**: not a
  key-policy change (`KeyType` untouched, spec item 9) -- the five ASCII
  generic instances stopped being *created* at all, because every exact
  call that used to route to them now resolves, through ordinary,
  unmodified `KeyType`/`Instance` lookup, to the identical key the
  existing `<int>` instance already used.
- **`guard int` ops 10 -> 7**: exactly the three guards on `is_digit`,
  `is_upper`, `is_lower`'s own comparisons (see "ASCII leaf" above); the
  remaining 7 are all on parameters with **no** declared type at all
  (`high_nibble`'s `b`, `esc_bytes`/`esc_from`/`repeat_uri`'s loop-index
  and accumulator parameters -- confirmed via `params.txt`: every one
  shows `declared=-`), i.e. spec item 42's "untyped source parameter"
  class, out of scope by construction.
- **call/callenv ops 17 -> 17, tagged i-arith ops 6 -> 6**: unchanged, as
  expected -- no inlining, no call-graph change, no arithmetic-lowering
  change.
- **allocations 61510 / bytes 2544568, both unchanged**: confirms spec
  item 75's expectation exactly; no allocation mechanism was touched, and
  none moved.
- **machine code bytes 8167 -> 7155 (-912B, -12.4%)**: driven by the guard
  removals above plus their downstream caller-side retest removals.

## `uri-steady` timing delta

Same M0 methodology (`bench/uri-steady.tcl`, unmodified): 2000-call fixed
corpus, best-of-7, 5 independent sessions, JIT compile excluded.

| | before | after |
|---|---:|---:|
| median | 6031.37 us | 5440.06 us (-9.8%) |
| min | 6019.10 us | 5135.29 us (-14.7%) |
| max | 6166.08 us | 5611.52 us |
| spread | 2.4% | 8.5% |

Correctness unchanged both before and after: all four backends (interp,
compile, cranelift-generic, cranelift) agree on `29500` for the fixed
corpus, both before and after this change.

Per spec item 51: this is "structural win + directionally-consistent
timing," which is a valid result on its own even before the timing
movement is considered; the timing here happens to move the same
direction and by a magnitude consistent with the ~12% code-size and
guard-removal delta, inside this shared host's noise band (M0's own
baseline session spread was ~17%).

## `steady-ascii` control delta

The three-probe family (spec items 47-48), same `measure.tcl` methodology
(2000 runs, 5 sessions):

| probe | before | after |
|---|---:|---:|
| `steady-ascii` (already `<int>`, unaffected by M1) | 2642.47 us | 2624.88 us |
| `steady-ascii-param` (already correct pre-M1) | 3118.01 us | 3140.95 us |
| `steady-ascii-capture` (the RC1-affected shape) | **4753.53 us** | **3171.08 us** |

`steady-ascii`/`steady-ascii-param` are flat (both differences are inside
session-to-session noise, ~1%) -- exactly as expected, since neither
probe's generic instances were affected (the `param` probe's `cls<int,
List[int]>` was already specialized; the plain `steady-ascii` probe uses
no closures at all). `steady-ascii-capture` -- the fixture whose own
comment says its difference from `-param` was attributed to RC1 -- drops
33.3%, from 52% slower than `-param` to within **1.0%** of it (3171.08 vs
3140.95 us). This is spec item 48's predicted "capture ≈ param" outcome,
confirmed directly rather than merely hypothesized.

Structural confirmation, same probe (`census.tcl`):

| | before | after |
|---|---:|---:|
| machine code bytes | 9823 | 8782 |
| genericFunctions | 6 | 1 (only `cls` itself) |
| guard int (generic-instance param) | 3 | 0 |
| exact calls with may_error check | 9 | 3 |
| rawop | 4 | 10 |
| runbox | 4 | 7 |
| tagged-int `ige` | 4 | 1 |
| tagged-int `ile` | 4 | 1 |
| allocations / bytes | 258 / 271408 | 258 / 271408 (unchanged) |

(The `static=3 -> static=2` line visible in the raw `summary.txt` is a
reclassification *within* the unchanged 258/271408 total -- one of the
five collapsed ASCII functions' own internal allocation-report bucketing
shifted category with its code path change; it is not a new or removed
allocation.)

## `refined-checks` delta

Structural (`census.tcl`, both `Emailish?` scanner copies -- this
milestone made them cheaper, per spec item 54, and deliberately did not
deduplicate them, which remains RC5):

| | before | after |
|---|---:|---:|
| machine code bytes | 17855 | 16843 (-5.7%) |
| genericFunctions | 26 | 21 |
| guard int (generic-instance param) | 19 | 16 |
| exact calls with may_error check | 45 | 40 |
| rawop | 3 | 9 |
| runbox | 3 | 6 |
| tagged-int `ige` | 19 | 16 |
| tagged-int `ile` | 4 | 1 |
| allocations | 23 | 23 (unchanged) |

The reduction here is entirely the same five ASCII functions (`refined-checks.ir`
also exercises `ascii::`/`web::` on its own corpus). The remaining 16
generic-instance `guard int` occurrences are, like `uri-steady`'s, all on
genuinely undeclared parameters (`scan_local`/`scan_label`/`scan_alpha`/
`tld_ok`'s own scan-index `i`, `declared=-` confirmed in `params.txt`) --
`StringRegion` scanner index guards, a different, already-known class
(RC1's F15/1b family in the audit, *not* addressed by this milestone,
which explicitly preserves closure-specialization policy).

Timing (`bench/bench.tcl`, `refined-checks.ir`, Cranelift column,
untouched methodology): 420.44us -> 409.53us (-2.6%, modest and consistent
with the smaller fraction of this program's own guards that were declared-
parameter-caused). `fib.ir`, `loop-count.ir`, `sum-refined.ir` are flat
(within single-digit-percent noise in both directions), as expected --
none of them touch a declared-Byte/int-typed generic instance.

## Root/safepoint consequences

`native::roots` report (`roots.txt`) for the five collapsed ASCII
functions: total root/safepoint entry count in `uri-steady` is unchanged
(34 mentions before and after); what changed per-function is exactly the
`may_error=true -> false` flag (already covered above) and a `+1` raw
register (the comparison operand that is now provably small moves from a
guarded/boxed slot to a raw one). No safepoint was added or removed: these
functions had no BigInt-producing allocation on their guarded path to
begin with (the guard existed purely to *route* between a raw-int and a
BigInt compare, never itself allocating), so removing it removes no
existing root, consistent with the unchanged allocation totals throughout
every workload measured.

## Full benchmark regression

- `tclsh9.0 tests/all.tcl` (interp + compile): baseline 2111/2111 passed,
  0 failed, both backends. After M1 (2117 tests -- 6 new
  `hir-specialize-m1-*`): interp backend 2117/2117 passed, 0 failed,
  confirmed. The compile backend's own full-suite run was still in flight
  (on `native-tiny-leaf-pressure.test`, a known-slow fixture) when this
  report was finalized; it was independently confirmed for the changed
  file itself (`hir-specialize.test`: 27/27 passed under
  `CORE_BACKEND=compile` directly) and for every other file the interp
  backend already exercises identically (this milestone's change is
  purely in `hir::specialize`, a Tcl-side, backend-agnostic analysis pass
  that runs identically before either backend's own lowering). No
  discrepancy between backends is expected or has been observed in any
  file checked so far.
- `cargo test --release --manifest-path native/Cargo.toml`: 60/60 passed,
  unchanged before and after (this milestone touches no Rust source at
  all -- `native/` was not rebuilt by this change).
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: baseline 2111/2111
  passed. After M1: interp backend 2117/2117 passed, 0 failed, confirmed;
  compile backend under GC stress was still running at report time for
  the same reason as above.
- `bench/bench.tcl` (fib, loop-count, refined-checks, sum-refined): all
  four Botlish backends continue to agree with each other and with the
  Python/Rust/Go reference implementations on every program; see
  "`refined-checks` delta" above for the one program affected.
- `bench/uri-steady.tcl`: see "`uri-steady` timing/structural delta"
  above; four-backend correctness (`29500`) unchanged.
- `typed-callable-escape.test` + `typed-parameters.test`:
  85/85 passed, unmodified expected results (the callable-escape
  soundness machinery this milestone's own audit relies on is itself
  untouched and still enforces every rejection it enforced before).
- `hir-closed-call-params.test`: 15/15 passed, unmodified.
- `audit/comprehensive-generated-code/tools/census.tcl` over
  `steady-ascii`, `steady-ascii-param`, `steady-ascii-capture`,
  `ascii-256`, `web-unreserved-256`, `uri-steady`, `refined-checks`: see
  the per-workload tables above; `steady-ascii`, `steady-ascii-param`,
  `ascii-256` show **zero** structural diff (correctly unaffected).

## M1b assessment (not implemented)

Spec item 22/68/83 asks whether F21 (`RefinementFacts` intersecting calls
in *unused* functions too) is independently causing any observed loss in
the measured/fenced workloads, after M1a. Checked directly: every
remaining `guard int (generic-instance param)` occurrence across
`uri-steady`, `web-unreserved-256`, `steady-ascii-capture`, and
`refined-checks` was traced back to `params.txt`'s own `declared=-`
column -- every one is a genuinely undeclared parameter (loop indices,
accumulators, `high_nibble`'s `b`), never a declared parameter whose
evidence was present but excluded by an unused call site. `RefineParams`'s
own `blockFacts` intersection is irrelevant to these guards in the first
place, since they have no `declaredParamTypes` entry to widen. No
measured/fenced workload shows a loss attributable to F21.

**Deferred**, per spec item 68's own instruction when no evidence
supports it. If a future workload introduces a declared-typed parameter
whose only caller-side evidence comes through an unused exact call, F21
would become directly actionable then; nothing in this milestone's own
evidence recommends implementing it now.

## First-loss matrix update

| fact | before M1 | after M1 |
|---|---|---|
| Byte/int/UnicodeChar nominal identity in a generic instance | **lost**, seeded from the instance key (`any`) | **survives**, seeded from `declaredParamTypes` |
| Instance identity for a generic caller's own exact calls | forced generic by the caller's own lost fact (cascading) | resolves through ordinary, unmodified `KeyType` to the already-correct instance |
| `guard int`/tagged compares on a declared-typed generic parameter | present | absent (raw, via existing range/type machinery) |
| `may_error` on a call whose only fallible op was that guard | `true` | `false` (via existing, unmodified structural effect analysis) |
| **new first loss**: call-boundary/ABI cost for an *indirect* (value-forwarded) call of a typed function | not applicable (guard dominated) | **the visible boundary now**: `esc_char -> web::is_unreserved` (forwarded, not a direct NIR call) still costs a frame, a tagged Bool return/retest, and (spec item 59) a `runbox`-equivalent parameter unbox on entry -- unaffected by parameter-fact transport, since it is a property of the call mechanism, not the callee's own facts |
| remaining `guard int` on a *declared* parameter | (none observed after M1, in the fenced corpus) | n/a -- every remaining guard traced to an undeclared parameter |
| remaining `guard int`/`guard list` on an *undeclared* parameter (loop indices, `StringRegion` scan index, `high_nibble`) | present | present, unchanged -- correctly out of scope |

This confirms spec item 56's own prediction directly: the first loss this
milestone leaves behind is the tagged call-boundary/indirect-dispatch
cost, not a lost declared fact.

## Files changed

```
hir/specialize.tcl         (Analyze's parameter seed; RefineParams's
                             replace -> union)
tests/hir-specialize.test  (6 new hir-specialize-m1-* tests)
M1-DECLARED-PARAMETER-FACT-TRANSPORT.md  (this report)
```

No `.bot`, `.ir`, `.hir` frozen source file changed. No `native/src/*.rs`
file changed (confirmed: `cargo build --release` after this change
finished in 0.04s -- nothing to recompile). No `lib/` stdlib source
changed.

## Tests / GC stress

- `hir-specialize.test`: 27/27 passed (21 pre-existing + 6 new), both
  `interp` and `compile` backends, confirmed directly.
- Full suite (`tests/all.tcl`): 2117/2117 passed on `interp`
  (both plain and `BOTLISH_NATIVE_GC_STRESS=1`), confirmed directly; see
  "Full benchmark regression" above for the compile backend's status.
- `cargo test --release`: 60/60 passed (unchanged, no Rust source
  touched).

## Source-fence confirmation

`git diff --stat` against the pre-M1 tree touches exactly
`hir/specialize.tcl` and `tests/hir-specialize.test` (plus this report).
Every `.bot`/`.ir` program used for measurement (`bench/uri-steady.bot`,
`bench/refined-checks.ir`, `bench/fib.ir`, `bench/loop-count.ir`,
`bench/sum-refined.ir`, every `audit/comprehensive-generated-code/probes/
*.bot` fixture) is byte-for-byte what M0 left it as. The FINAL SEMANTIC
SOURCE FENCE remains intact: this is a same-source, better-compiler
result throughout.

## Required architecture questions

1. **What did a generic instance use as its parameter seed before M1?**
   The instance's own key type only -- `any` for every parameter, by
   construction (a generic instance's key is all-`any`).
2. **What does it use after M1?** The key type narrowed by the function's
   own `declaredParamTypes` entry for that parameter, if any (union, never
   replace, for an already-specialized scalar key); unchanged for a
   parameter with no declared type.
3. **Why is it sound to assume the declared parameter type in a generic
   instance?** Because `hir::range::verifyDeclaredParams` already proves
   it for every *legal* exact call in the program, before `hir::specialize`
   ever runs, and `hir/callables.tcl` rejects every position that would
   let a typed callable's exact identity -- and so this obligation --
   escape into a call that mechanism cannot see ("Invocation-path
   soundness audit" above).
4. **Which compiler mechanism guarantees callers cannot violate that
   contract?** `hir::range::verifyDeclaredParams` for every exact call,
   backed by `hir::callables::verify` for every position that could
   otherwise erase a typed callable's exact identity before such a call.
5. **Are declared parameter types now part of specialization keys?**
   Expected: no. **Confirmed no**: `hir::specialize::KeyType` was not
   modified; `git diff` touches no line of it.
6. **Do generic instances still exist?** Expected: yes. **Confirmed
   yes**: `web::is_unreserved<generic>` remains generic on the URI path
   (its captured module value, unaffected by this milestone, is why); 9
   generic instances remain in `uri-steady` after M1 (down from 14, for
   the reason in "Outcome," not because generic instances were disallowed).
7. **Can a generic instance nevertheless have a precise parameter view?**
   Expected: yes. **Confirmed yes**: `web::is_unreserved<generic>`'s own
   `b` view is `int[Byte]`, not `any`.
8. **Does an untyped parameter gain any new assumption?** Expected: no.
   **Confirmed no**: `m1-explosion-generic`'s `tag` parameter, and every
   pre-existing `hir-specialize-*` test's untyped parameters, are
   unchanged.
9. **Can `x: int` be assumed to fit raw small Int?** Expected: no.
   **Confirmed no**: `m1-broad-int`'s generic instance view for a
   declared `x: int` parameter is `int`, not a small range or a raw kind.
10. **Can `b: Byte` be proven small through its existing domain?**
    Expected: yes. **Confirmed yes**: via the pre-existing, unmodified
    `SOURCE-DEFINED-INTEGER-DOMAINS.md`/`hir/range.tcl` machinery, once the
    `Byte` *type* fact itself survives into the instance (see "Byte fact
    trace" above) -- this milestone encodes no `[0,255]` anywhere itself.

## Required URI questions

11. **Is `web::is_unreserved` still a generic instance?** Yes.
12. **What is its parameter view before/after?** `any` -> `int[Byte]`
    (see "Byte fact trace").
13. **Does its `guard int` disappear?** `is_unreserved` itself never had
    one (its own body only calls `is_alphanumeric`/`rt_set_contains`, both
    non-erroring after M1) -- what disappears is the guard inside the ASCII
    functions it (transitively) calls.
14. **Which ASCII predicates remain generic?** None, in every measured
    workload -- all five (`is_digit`, `is_upper`, `is_lower`,
    `is_alphabetic`, `is_alphanumeric`) now resolve to their pre-existing
    `<int>` instance via ordinary exact-call `KeyType` propagation from
    `is_unreserved`'s (and `cls`'s, in the synthetic fixture) own restored
    Byte fact.
15. **Do their Byte/int guards disappear?** Yes, all three that had one
    (`is_digit`, `is_upper`, `is_lower`); `is_alphabetic`/`is_alphanumeric`
    never had their own guard (they only call other ASCII predicates).
16. **Which tagged comparisons become raw?** The `ige`/`ile` in
    `is_digit`/`is_upper`/`is_lower`'s own boundary comparisons (see "ASCII
    leaf before/after").
17. **Which functions stop being `may_error` as a natural consequence?**
    `is_upper`, `is_lower`, `is_alphabetic`, `is_alphanumeric`, and the
    call from `web::is_unreserved` into `is_alphanumeric` (see "`may_error`
    propagation" table) -- `is_digit` itself has no *callees* to report an
    edge for, but its own guard removal is what starts the cascade.
18. **How many exact call checks remain in `uri-steady`?** 11 (`effects.txt`
    "exact calls with may_error check", down from 16 -- see the census
    tables above).
19. **Does the retained-set capture remain?** Expected: yes. **Confirmed
    yes**: `web::is_unreserved`'s NIR still shows `env=1 captures=1`, one
    capture load, unchanged (`additional_unreserved_chars`, M0's own
    subject, untouched).
20. **Does `rt_set_contains` remain?** Expected: yes. **Confirmed yes**:
    `bench/uri-steady.tcl`'s own structural report shows `op:setcontains=1`
    inside `web::is_unreserved`'s NIR, unchanged before/after (the
    top-level `rt_set_contains` *text* count the benchmark script also
    prints is 0 both before and after, exactly as its own comment expects
    -- ImmutableSet membership lowers to a native call, not that literal
    token).

## Required benchmark questions

21. **`uri-steady` machine-code size before/after?** 8167 -> 7155 bytes
    (-912B, -12.4%).
22. **Guard count before/after?** 10 -> 7 `guard int` ops (whole program).
23. **Tagged Int op count before/after?** 6 -> 6 (`tagged i-arith ops` in
    `bench/uri-steady.tcl`'s own report; unaffected -- these are add/sub/mul
    ops elsewhere in the program, not the comparisons this milestone
    affected, which the benchmark script counts separately as `guard int`).
24. **`may_error`-checked exact calls before/after?** 16 -> 11.
25. **Generic instance count before/after?** 14 -> 9.
26. **Allocation count/bytes before/after?** 61510 / 2544568, unchanged
    both before and after.
27. **Cranelift median timing before/after?** 6031.37us -> 5440.06us
    (-9.8%).
28. **Timing spread?** 2.4% (before) / 8.5% (after) -- both comfortably
    inside M0's own recorded ~17% shared-host spread.
29. **What changed in `steady-ascii-capture` relative to
    `steady-ascii-param`?** Timing converged from 52% slower (4753.53 vs
    3118.01us) to within 1.0% (3171.08 vs 3140.95us); structurally,
    `genericFunctions` dropped 6 -> 1 (only `cls` itself remains generic)
    and every guard/tagged-compare/may_error-check delta in the "steady-
    ascii control delta" table above moved in the same direction.
30. **What moved in `refined-checks` structurally and in timing?**
    Machine code 17855 -> 16843 bytes (-5.7%), `genericFunctions` 26 -> 21,
    `guard int` (generic-instance param) 19 -> 16, exact calls with
    may_error check 45 -> 40; Cranelift timing 420.44 -> 409.53us (-2.6%,
    modest, consistent with the smaller share of this program's total
    guard count that was declared-parameter-caused -- most of its
    remaining guards are the `StringRegion` scanner index guards, a
    different, unaddressed class).

## Required M1b questions

31. **After M1a, does F21 still cause any observed loss in the frozen
    workloads?** No -- every remaining `guard int (generic-instance
    param)` in every measured workload traces to a parameter with
    `declared=-` (no declared type at all), not to a declared parameter
    whose evidence an unused call site diluted.
32. **Which exact unused calls, if any, poison `RefinementFacts`?** None
    identified with an observable effect: since the remaining guards are
    all on undeclared parameters, `RefinementFacts`'s own intersection is
    moot for them (there is no declared type to widen in the first place).
33. **Would changing that behavior remove any remaining guards?** Not in
    any workload measured here.
34. **Is M1b therefore justified as the immediate next micro-milestone?**
    No, per the evidence above -- deferred (spec item 68), not implemented.

## Required scope questions

35. **Was closure specialization changed?** Expected: no. **Confirmed
    no** -- `cls`/`web::is_unreserved` remain generic for the same reason
    (non-Int capture) as before; the closure-specialization rule in
    `hir::specialize::Handle`'s `call` case is untouched.
36. **Was module-value representation changed?** Expected: no.
    **Confirmed no** -- `web::is_unreserved`'s own capture (`env=1
    captures=1`, one load of `additional_unreserved_chars`) is
    byte-for-byte unchanged.
37. **Was the specialization key changed?** Expected: no. **Confirmed
    no** -- `hir::specialize::KeyType` has no diff.
38. **Were range facts added to keys?** Expected: no. **Confirmed no**.
39. **Was control-flow pruning added?** Expected: no. **Confirmed no** --
    `byte::from_int`'s own residual guard/error path (spec item 18) is
    unchanged; no `if`/branch was pruned by range facts anywhere.
40. **Was `effectiveErrors` consumed?** Expected: no. **Confirmed no** --
    the `may_error` changes observed are entirely `nir.rs`'s own
    unmodified structural recomputation reacting to the removed guards,
    not a new consumer of `effectiveErrors`/`resultRangeFact`.
41. **Was inlining changed?** Expected: no. **Confirmed no** -- call/callenv
    op counts are identical before/after in every measured workload
    (`uri-steady`: 17 -> 17); the ASCII call chain still calls, never
    inlines.
42. **Was listloop changed?** Expected: no. **Confirmed no** -- allocation
    counts/bytes are identical in every measured workload.
43. **Was Bool ABI changed?** Expected: no. **Confirmed no** -- no
    `cmov`/`cmp rax,6`-style Bool-tag codegen was touched; the only
    lowering-visible change is the comparison operands becoming raw
    (spec item 62's own carve-out: "except where tagged comparisons
    naturally disappear because operands become raw").
44. **Was any frozen `.bot` source changed?** Expected: no. **Confirmed
    no** -- see "Source-fence confirmation" above.

## Recommended next milestone

The clearest, most concrete remaining first loss this milestone's own
evidence points at is the **call-boundary/ABI cost for an indirect
(value-forwarded) call of a now-provably-non-erroring callee**
(`esc_char -> web::is_unreserved`, "First-loss matrix" above) -- exactly
what spec items 56/59-61 anticipated as the next layer once parameter
facts stopped being the dominant cost. This is RC3 territory (tiny-call/
helper-boundary overhead), not a new finding this milestone invented.

A second, smaller candidate: RC1's own audit lists family **1b** (let
exact calls of closures specialize when `hir::blockescape` proves they
are never materialized, or when every capture is a retained immutable
module value) as removing "24 of 27" guards in `refined-checks` -- larger
than 1a's own share there. This milestone deliberately did not touch
closure-specialization policy (spec items 11, 26, 57, 66); 1b remains a
distinct, larger-risk candidate (medium complexity, low-medium semantic
risk per the audit's own table) for a future milestone, not this one.

M1b (RefinementFacts over unused calls only) remains assessed and
deferred, per the section above -- no evidence in the fenced corpus
currently justifies it.
