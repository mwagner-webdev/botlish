# Typed-callable escape soundness

The immediately preceding milestone (`STRICT-TYPED-PARAMETERS.md`) added
strict, statically-checked function parameter types, but only checked them
at calls whose target resolved to an exact known block. This left one real
soundness hole, not merely lost precision: a typed callable's exact value
could flow through an *untyped* higher-order parameter, losing the only
information that made checking possible, and reach a call site the
compiler could no longer verify at all -- while its own body still
unconditionally assumed the declared precondition held.

## Outcome

Closed. A new HIR pass, `hir::callables::verify` (`hir/callables.tcl`,
new file), rejects every point where a *typed callable* (a function with
at least one declared parameter type) would flow into a context that
cannot preserve its exact `{block B arity result}` identity: an ordinary
call argument, an `if`/loop-break join with a different callable, a
function-level return join, or a Result wrapper. Exact identity flowing
through an immutable alias, a transitive alias, a closure capture, or a
same-callable branch join is untouched and remains fully first-class.
Wherever exact identity survives, the *existing*,
unmodified `hir::range::verifyDeclaredParams` (from the previous
milestone) does the one and only argument-admissibility proof -- this
milestone adds no second admissibility mechanism and no runtime check.

The reported program:

```botlish
fn take_byte(x: Byte) -> Int:
    x

fn apply(f, v):
    f(v)

apply(take_byte, 9999)
```

**Before:** compiled, and evaluated to `9999` on every backend (interp,
compile, cranelift).

**After:** rejected at compile time, at the `apply(take_byte, 9999)` call
itself -- specifically, at the point where `take_byte` is passed as an
ordinary argument to `apply`'s untyped parameter `f`:

```
"take_byte" has typed parameter requirements that cannot be preserved
passed as an ordinary call argument: its declared parameter contract
would be erased and could no longer be checked at every future call
```

`apply(take_byte, 7)` is rejected identically (same diagnostic, same
location) -- see "Higher-order apply behavior" below for why this
milestone chose that outcome over the other spec-sanctioned one
(resolving the inner call exactly through specialization).

## Why this was a soundness bug, not merely lost precision

Every declared parameter type is, from the moment `hir::types::Block`
seeds it, an **unconditional** fact inside its own function's body
(`STRICT-TYPED-PARAMETERS.md`'s own closing statement, unchanged by this
milestone -- see "Interaction with typed-parameter fact seeding" below):
`fn take_byte(x: Byte)`'s body may assume `x` is in `[0, 255]` regardless
of how it is invoked. That assumption is sound only if *every* executable
invocation path was proven admissible before it ran. `hir::range::
verifyDeclaredParams` proves this for every call whose target resolves
exactly -- but `apply`'s own body is analyzed once, monomorphically,
independent of any particular caller (this is true of *every* Botlish
parameter, not a defect specific to callables): `f`'s type inside `apply`
is unconditionally `any`, so the inner `f(v)` call's target never
resolves, and `verifyDeclaredParams` never sees it at all. A future
optimization pass that used `x`'s declared `[0, 255]` fact to eliminate a
guard (item 29's own required test, below) would be *unconditionally*
justified in doing so -- except that, before this milestone, a program
existed that could call `take_byte` with `9999` without ever being
checked. That is a genuine semantic-soundness gap, independent of whether
any optimization exploits it today (spec #40's own required point).

## Result-contract vs parameter-contract asymmetry

This distinction is the reason the *previous* milestone's tolerance for
imprecision around **result** types is not a precedent for tolerating
erased **parameter** preconditions, and it is worth stating precisely:

- **Result contract**: the *callee* proves it, for every possible input,
  once, at definition time (`hir::range::verifyDeclaredResults`'s own
  local, caller-independent proof). A dynamic caller cannot violate it --
  there is nothing for a caller to get wrong, because the proof already
  covers every caller.
- **Parameter contract**: the *caller* must prove it, once per call site,
  because it constrains the caller's own argument, which the callee's
  body cannot control. An unchecked dynamic caller *can* violate it --
  and, before this milestone, could.

`CROSS-MODULE-REFINED-SIGNATURES.md`'s own "dynamic calls are precise only
while their block value type remains specific... calls through `any`
remain imprecise" describes the *result*-contract case, where imprecision
only ever costs an optimizer a *fact*, never a *proof*. Applying the same
tolerance to parameters would cost a proof, which is why this milestone
was necessary and the prior one's own design was not extended to (and
explicitly did not need to consider) this case.

## Callable-value representation: audit (spec #9)

Traced directly, with no changes to any of the mechanisms below except the
new erasure check itself:

- **Function reference creation**: `fn f(...): ...` lowers to an ordinary
  `bind f (block ...)` (`surface/lower.tcl`, unchanged). `f`'s own binding
  gets the block's exact type (`{block E arity result}`) the same way any
  other top-level `bind` does.
- **Local alias / rebinding** (`g = f`): `hir::types::Bind` types the
  bind's value as `Expr hir ctx (ref f)` = `BindingType(f)` (already
  computed, exact, since `f`'s own bind already ran in the same
  sequence), then persists it both to the fresh context (`ctx types`) and
  to the binding's own field (`hir bindings $b type`). **Exact identity
  survives**, unconditionally, for any immutable local alias -- this was
  already true before this milestone; nothing here needed to change it.
- **Captures**: `hir::types::Block`'s own per-attempt context always
  starts as `dict set ctx types [dict get $outer types]` -- the *entire*
  outer scope's known types, not just this closure's own capture list.
  A captured binding's type inside the closure is therefore exactly what
  it was outside. **Exact identity survives capture**, already true
  before this milestone.
- **Argument passing**: a call argument's expression keeps its own exact
  type at the *call expression itself* (used by `hir::types::Call` to
  resolve `target`), but the *callee's own parameter*, if untyped, gets no
  connection to any specific caller's argument type at all --
  `hir::types::ForwardType` returns bare `any` for every parameter
  binding, unconditionally, regardless of what any specific call passes.
  **This is the fundamental, structural erasure point**: Botlish's
  ordinary (non-specialized) type inference has never given a parameter a
  caller-specific type, for *any* value kind, not callables specifically.
- **Return values**: a function's own result type is its `inferredResultType`
  (or `declaredResult`, but no *declared* result type can ever *name* a
  callable type -- `core::type::normalize` only accepts primitive/named
  int/str-based types, never `block`, so a declared result annotation on a
  function returning a callable is not expressible and was never
  attempted). An undeclared result stays exactly whatever the body's
  trailing/return expressions infer. **Exact identity survives return**,
  through the very same mechanism that already makes `byte::high_nibble`'s
  declared `HighNibble` result visible to callers -- already true before
  this milestone.
- **`if`/loop-break joins**: `hir::types::lub` requires *the same block
  ExprId* on both sides to keep the precise 4-tuple form; two different
  blocks (even both callable) fall through to `kindOf` comparison, which
  only agrees on the *kind* `block` (bare, no identity) -- exactly
  parallel to how `Small` and an unrelated `Int`-based type would erode to
  bare `int` under `lub`. **This is a second, independent erasure point.**
  A *compile-time-known* condition (`if true: ... else: ...`) bypasses the
  join entirely (`hir::types::If`'s own `known`-branch shortcut returns
  the live branch's type directly) and so does not erase.
- **Specialization** (`hir::specialize.tcl`, used only by the
  native/compile backends' own codegen, via a *scratch* copy of the HIR --
  `hir::types::inferRegion`, confirmed by direct read: `hir::specialize.tcl`
  calls it with a local variable literally named `scratch`, never the
  live program `hir`): per-instance re-inference *could*, for a
  specific specialized instance of `apply`, seed `f`'s type from that
  instance's own actual argument. This never mutates the shared HIR this
  milestone's check (and the previous milestone's) both run against, and
  it never runs at all for the interp backend. Exploiting it here would
  mean moving (or duplicating) admissibility checking into a
  per-instance, per-backend pass -- exactly the "new higher-order/
  function-type machinery" the brief's own item 39 says to avoid. **Not
  exploited**, deliberately (see "Higher-order apply behavior" below).
- **Aggregate/container storage**: `[a, b]` lowers to an ordinary
  `call (ref list) a b` (unchanged), so putting a typed callable into a
  list is already exactly the "ordinary call argument" erasure case above
  -- no separate list-specific logic was needed or added. Ordinary
  (non-specialized) semantic inference never tracks list element types at
  all (`hir::types::Block`'s own header comment: "the list forms are
  aggregate facts... semantic inference never produces them"), so a list
  literal already loses *all* precision for its elements before this
  milestone; this pass makes that already-total erasure a compile error
  specifically when a typed callable is involved.
- **Module-exported function values**: modules are combined into one HIR
  before any checking runs (unchanged, `surface/modules.tcl`), so a
  cross-module typed callable taken as a value is checked by the exact
  same mechanism as a local one -- no module-specific code was added.

## Chosen enforcement rule

At every position that is not one of the identity-preserving ones above
(call argument, `if`/loop-break branch whose joined type differs, a
`return`/implicit-trailing-value whose function-level result type
differs, or a Result wrapper), a **typed** callable's exact type is
checked against the position's own resulting type; if they differ, the
transfer is rejected with a located diagnostic. An **untyped** callable
(no declared parameter types at all -- e.g. `identity`) is never checked,
because it imposes no caller-side obligation to protect (`STRICT-TYPED-
PARAMETERS.md` item 10, restated verbatim in the brief as item 10 again
here): ordinary higher-order programming with untyped callables is
completely unaffected (spec #14, #51, pinned:
`callable-escape-ordinary-untyped-callable-unaffected`).

This is a **conservative, reject-on-erasure** rule (spec #6, #31), chosen
over reject-on-call for a structural reason, not merely a stylistic
preference: by the time an eroded callable value (bare `block` kind, or
`any`) reaches a call site, the type system has already forgotten whether
a typed-precondition callable or only ever untyped ones could have
produced it. Rejecting at the call site would therefore have to reject
*every* call through an unresolved/generic callable type indiscriminately
-- which would also reject `apply(identity, 9999)`, violating spec #14's
explicit requirement that ordinary untyped higher-order programming keep
working. Reject-on-erasure is not merely preferred here; given this
architecture, it is the only rule that can distinguish the safe case from
the unsafe one at all.

## Why no runtime checks were added

The rejection is a compile-time HIR diagnostic (`hir::Diagnose ... TYPE`),
raised during `hir::buildSyntax`, before any backend is selected --
exactly where `hir::range::verifyDeclaredResults`/`verifyDeclaredParams`
already raise theirs. A program that survives this pass is, by
construction, one where every typed callable's exact identity is provably
intact at every reachable call, so `hir::range::verifyDeclaredParams`'s
own existing (unmodified) admissibility proof is both necessary and
sufficient for every such call -- there is no remaining case that would
need a second, dynamic check. Searched directly (`git diff --stat`, and
`core::native::names` for `*check_callable*`/`*assert_parameter*`/
`*validate_dynamic_call*`/`*typed_call_guard*`, all absent, spec #27/#65):
no new native helper, no interpreter-only validation, no generated Tcl
validation, no NIR instruction, and no Cranelift lowering change exist
anywhere in this diff. `native/lower.tcl` and every file under
`native/src/**` are byte-for-byte untouched.

## Direct call behavior

Unaffected, pinned unchanged (`callable-escape-direct-call-valid-
unaffected`, `-invalid-unaffected`; all 50 pre-existing `tests/
typed-parameters.test` cases still pass verbatim). A direct call's callee
is never checked by the new pass (only its *arguments* are, and a direct
call's callee position is not an argument) -- `take_byte(7)`/`take_byte
(9999)` go through exactly the code path they did before this milestone.

## Exact alias behavior

`f = take_byte; f(7)` remains legal; `f(9999)` is rejected by the
*existing*, unmodified `verifyDeclaredParams` (the diagnostic is the
ordinary admissibility one, "cannot be proven to satisfy," not the new
erasure one) -- because `f`'s type stays exactly `take_byte`'s own, `f(...)`
resolves `target` exactly, and the previous milestone's own check already
covers it. Transitive aliasing (`g = f = take_byte; g(...)`) behaves
identically, confirming exact identity is genuinely part of the value's
*type*, not merely syntax-local to one binding
(`callable-escape-alias-valid/-invalid`,
`-transitive-alias-valid/-invalid`).

## Higher-order `apply` behavior

Both `apply(take_byte, 9999)` and `apply(take_byte, 7)` are rejected, at
the same location (the argument-passing point, not the inner `f(v)`
call), with the identical erasure diagnostic. This is the "erased ->
compile-time error" outcome the brief explicitly names as one of two
sound options (spec #50), chosen deliberately over exploiting
specialization to resolve the inner call exactly, for the reason spec #39
itself anticipates: doing so would require running (or duplicating)
admissibility checking against `hir::specialize`'s own per-instance,
per-backend, scratch-copy analysis -- real, new higher-order/function-
type machinery, and one that would not even apply uniformly (the interp
backend never runs `hir::specialize` at all, so backend parity, spec #61,
would break the moment a *specialized* backend accepted a call an
*unspecialized* one could not check). Rejecting at the erasure point
avoids all of that: it is backend-independent by construction, and it
generalizes to every untyped higher-order parameter, not just `apply`'s
own shape (spec #3's own "do not special-case `apply`" -- confirmed by
`callable-escape-mixed-typed-untyped-params-rejected`, `-source-defined-
type-escape-rejected`, `-typed-result-only-unrestricted`, none of which
mention `apply` by name in the implementation, only in tests).

## Capture behavior

A closure capturing a typed callable keeps its exact identity (confirmed:
`hir::types::Block`'s own outer-context carry-over, unmodified). Whether
a subsequent call through that closure is itself legal depends on the
closure's *own* parameter, exactly as it would for any other function:

- `fn inner(v: Byte): f(v)` (the closure's own parameter is *also*
  typed compatibly) -- `inner(7)` is legal, `inner(9999)` is rejected, both
  through the ordinary, unmodified admissibility proof
  (`callable-escape-capture-typed-wrapper-valid/-invalid`).
- `fn inner(v): f(v)` (the closure's own parameter is untyped) -- rejected
  unconditionally, *regardless of what `inner`'s own caller passes*, by
  the *existing* `verifyDeclaredParams`'s own local, caller-independent
  proof (`v`'s declared type is nothing, so its local Range fact is
  `unknown`, and `unknown` can never prove membership in `Byte`) --
  `callable-escape-capture-untyped-wrapper-rejected`. This is not a new
  restriction from this milestone (the diagnostic is the ordinary
  admissibility one, not the new erasure one) and is not a regression: it
  is the pre-existing, correct consequence of `inner` itself imposing no
  provable precondition on `v` before ever calling `f(v)`. A programmer
  who wants `inner` to safely forward to a `Byte`-typed callable must
  declare `inner`'s own parameter compatibly -- exactly the ordinary,
  expected typed-parameter discipline, not a special callable rule.

## Return behavior

`fn chooser(): take_byte` preserves exact identity in its inferred result
(no declared-result syntax can name a callable type at all, so this path
is never in tension with a declared annotation); calling the returned
value is checked normally (`callable-escape-return-preserved-valid/-
invalid`). A function whose *multiple* return sites (or return sites
joined with the implicit trailing value) disagree on which exact callable
they produce is rejected at the return statement that would break the
join (`callable-escape-return-join-different-rejected`) -- the identical
`lub`-erosion mechanism as an `if`, just checked against the enclosing
function's own `inferredResultType` (via each `return` node's existing
`target` field) rather than a sibling branch.

## Branch/join behavior

Two branches producing the *same* exact typed callable join without
erasure and remain legal (`callable-escape-branch-join-same-callable-ok`);
two *different* callables (typed-vs-typed, or typed-vs-untyped) erode to
bare `block` kind under the pre-existing `hir::types::lub` and are
rejected at the join, for whichever branch(es) contributed the typed one
(`-branch-join-different-callables-rejected`, `-branch-join-untyped-vs-
typed-rejected`). Two different *untyped* callables joining is
unrestricted, since neither side has a contract to lose
(`-branch-join-two-untyped-ok`). A compile-time-known condition
(`if true: ...`) never joins at all (`hir::types::If`'s own pre-existing
shortcut), so the live branch's exact identity survives unconditionally
(`-branch-known-condition-preserves-identity`). No union/merged-function-
type machinery was added anywhere for this (spec #18-19's own explicit
prohibition) -- a differing join is simply an error, the same way a
differing scalar-typed branch join was already tolerated as an ordinary
`lub` to a wider (but never invented-union) type before this milestone.

## Cross-module behavior

No module-specific code exists in `hir/callables.tcl` at all. Because
modules are combined into one HIR before any checking runs, a cross-module
typed callable taken as a first-class value (`mod::take_small` bound to a
local alias) is governed by exactly the same rule as a local one --
confirmed directly with a throwaway library module (`callable-escape-
cross-module-alias-valid`, `-cross-module-escape-rejected`, following the
same `$::core::libraryDir` throwaway-module pattern `tests/source-types.
test` and `tests/typed-parameters.test` already established).

## Interaction with `OpenInstances`

Audited directly (`hir::range::OpenInstances`, unmodified by this
milestone): it excludes a *specialized instance* reachable through a
materialized/escaping Block value from the *interprocedural closed-call
fixpoint*'s own caller-fact folding (`hir::range::analyze`'s
`contributions` fold) -- a codegen-*optimization* concern, entirely
separate from, and running much later than, this milestone's own
compile-time admissibility/erasure checking (which happens once, in
`hir::buildSyntax`, before `hir::specialize` exists). It was never the
mechanism that could have closed this soundness hole: `OpenInstances`
protects a *fact-precision* invariant (never assume more than callers
proved), not a *legality* invariant (never let an unproven call execute
at all) -- and it does nothing to stop `f(v)`'s target from being
unresolved in the first place, which is what let the original bug's call
go unchecked. This milestone does not touch `OpenInstances`, and does not
need to: the illegal transfer is now rejected long before `hir::specialize`
or `hir::range::analyze` ever run.

## Interaction with typed-parameter fact seeding

Unconditional and unchanged. `fn f(x: Byte)` still means, inside `f`,
unconditionally, `x : Byte`, `x in [0, 255]` (`hir::types::Block`'s own
declared-parameter seeding, from the previous milestone, not modified by
a single line here) -- regardless of whether `f` is ever materialized as
a first-class value. This milestone does not weaken that fact for "open"
instances, and does not need to: instead of loosening the *callee's* own
guarantee to tolerate an unproven caller, it removes every *executable
path* that could reach the callee without proving its precondition first.
`callable-escape-no-new-error-completion` confirms a typed callable still
has no possible parameter-validation `Error` completion.

## Diagnostics

```
"take_byte" has typed parameter requirements that cannot be preserved
passed as an ordinary call argument: its declared parameter contract
would be erased and could no longer be checked at every future call
```

Other contexts substitute their own clause in place of "passed as an
ordinary call argument": `in an "if" branch whose joined type differs
from the other branch`, `in a loop "break" whose joined type differs`,
`in a "return" whose function-level result type differs`, `as a
function's own trailing value, whose declared/inferred result type
differs`, `wrapped as a Result value`. Every diagnostic names the
callable (its own declaring bind's name, best-effort, or "this callable"
if none is visible), is located at the erasing expression itself, and
never implies a runtime check or cast could rescue the call -- it states
what is being lost and why that is fatal, exactly as `STRICT-TYPED-
PARAMETERS.md`'s own diagnostic-quality precedent for admissibility
failures already does.

## Tests

New: `tests/typed-callable-escape.test`, 35 cases -- the reported bug
(rejected, and specifically via the erasure diagnostic, not the
admissibility one), the `apply` escape (both a bad and a technically-valid
argument, both rejected), ordinary untyped higher-order programming
(unaffected), direct calls (unaffected), exact alias (valid/invalid),
transitive alias (valid/invalid), branch joins (same callable legal,
different callables rejected, typed-vs-untyped rejected, two-untyped
unrestricted, known-condition bypasses the join), return (preserved valid/
invalid, and a differing return join rejected), capture (typed wrapper
valid/invalid, untyped wrapper unconditionally rejected -- documented as
pre-existing, not new, behavior), loop break join, typed-result-only
(unrestricted), mixed typed/untyped parameters, a source-defined type
(not just `Byte`) with both an alias and an escape, a sparse source-
defined type through an exact alias (valid membership and non-membership),
cross-module alias and escape, a semantic-soundness illustration (spec
#29/#60: every legal call keeps a Byte-typed parameter's `else` branch
unreachable; the only path that could inject `9999` is exactly what this
milestone now rejects), no new runtime helper, no new `Error` completion,
and backend parity (interp/compile agree, by construction, since
rejection precedes backend selection). All 50 pre-existing `tests/
typed-parameters.test` cases pass unmodified (none of them encoded the
now-unsound escape behavior -- confirmed by search: no existing test
mentions `apply`, "higher-order", "first-class", or "callable").

`tclsh9.0 tests/all.tcl` (interp and compile backends, native backend
built): **1768/1768 passing, 0 failed** -- exactly 35 more than the
previous milestone's own 1733 (this file's new tests), with no other
change. `cargo test --release --manifest-path native/Cargo.toml`:
**60/60 passing** (no Rust source changed). GC-stress
(`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`, run per spec §63
since this milestone adds a new HIR pass that runs on every build):
**1768/1768 passing, 0 failed** -- identical to the ordinary run on both
backends, confirming no rooting/allocation-behavior regression.

## Backend parity

Confirmed structurally, not just empirically: the new pass runs inside
`hir::buildSyntax`, called once, unconditionally, before `-strict`
diagnostic-raising and long before any backend (interp, compile,
cranelift) is chosen or `hir::specialize` exists. No backend-specific code
was touched (`native/lower.tcl`, `native/src/**` untouched). `callable-
escape-backend-parity` additionally confirms interp/compile agree on the
bug program's rejection code.

## Production diff

```
hir/callables.tcl      new file (the one new pass)
hir/hir.tcl             +2  (source the new file; call hir::callables::verify)
```

No other production file changed. In particular, untouched:
`surface/**` (no syntax change -- spec #46's own expectation), `core/**`,
`compiler/**`, `native/lower.tcl`, `native/src/**` (spec #47's own
expectation -- no runtime/Rust changes), and `lib/**` (no Byte-specific
library edits were necessary or made -- every test above uses either a
throwaway local `type Byte = Int in 0..255`/`type Small = ...` declaration
or a throwaway `$::core::libraryDir` module, matching the previous
milestone's own established testing convention). `hir::moduleSignatures`
(from the previous milestone) is untouched; no new module callable-
signature system was built.

## Deferred general function types

No user-visible function-type syntax, function subtyping, parameter
contravariance, result covariance, higher-rank types, generic callable
constraints, or overloaded function values were added. `hir::callables::
Bearing` is the only new "metadata" this milestone introduces, and it is
not stored at all -- it is a pure function of already-existing,
already-serialized state (`{block B ...}`'s own `B`, and `B`'s own
`declaredParamTypes`, from the previous milestone), recomputed on demand
wherever needed. No HIR format/read change was necessary (spec #44): a
typed callable's "precondition-bearing" status round-trips automatically
because `declaredParamTypes` itself already did.

## Required-question summary

**Architecture (1-14):** An exact function/block value's HIR representation
is unchanged: `{block B arity result}`, where `B` is the block's own
ExprId. `take_byte` lost exact identity in the old `apply(take_byte,
9999)` path at the *argument-passing* boundary: `apply`'s own parameter
`f`, being untyped, is given the caller-independent type `any` by
`hir::types::ForwardType`, the same rule every Botlish parameter has
always had. The new prohibition is `hir::callables::verify`
(`hir/callables.tcl`), called once from `hir::buildSyntax`. It is enforced
at the erasure point (argument passing, branch/loop-break join, return
join, Result wrap), not merely at eventual dynamic call, for the
structural reason in "Chosen enforcement rule" above. Exact aliases of
typed callables remain callable (yes, confirmed). Typed callables can pass
through *typed* function parameters only in the sense that the *callee's*
own body must independently prove admissibility for whatever value it is
given -- they cannot pass through an *untyped* callable parameter at all
(rejected at the transfer). Typed callables can be captured (yes, exact
identity survives) and returned (yes, exact identity survives) and can
pass through a branch join only when both sides are the *same* exact
callable. They can be "stored" in a generic aggregate only in the sense
that doing so is already the ordinary call-argument erasure case (list
construction is an ordinary call). No path remains that can invoke a
typed callable without statically checking its declared parameters:
**answer to #14 is no**, confirmed by every test in "Tests" above and by
the structural argument that every surviving execution path resolves
`target` exactly, which is exactly the condition `verifyDeclaredParams`'s
own admissibility proof requires and already provides.

**Semantics (15-20):** `fn f(x: Byte)` still unconditionally means `x` is
`Byte` inside `f` (yes -- unchanged). Declared parameter fact seeding for
open instances was not weakened (no -- untouched). No runtime validation
was added (no). No new `Error` completion was added (no). No unproven
argument can reach `f` through `callvalue`/dynamic dispatch anymore (no --
the transfer that would have made this possible is rejected before it
happens). Untyped higher-order functions remain fully supported (yes).

**Scope (21-31):** No user-visible function-type syntax (no). No function
subtyping (no). No parameter contravariance (no). No result covariance
(no). No general higher-order type checker (no -- one narrow, specific
erasure-detection pass, not a type system). No predicate flow refinement
(no). No generic/container types (no). No overloading (no). No
variadicity (no). No representation specialization (no). No ASCII work
(no).

## Acceptance table

| Program | Before | After |
|---|---|---|
| `take_byte(7)` | valid | valid (unchanged) |
| `take_byte(9999)` | compile error | compile error (unchanged) |
| `f = take_byte; f(7)` | valid | valid (unchanged) |
| `f = take_byte; f(9999)` | compile error | compile error (unchanged) |
| `g = f = take_byte; g(7)` / `g(9999)` | valid / error | valid / error (unchanged) |
| `apply(take_byte, 9999)` | **valid, ran, returned 9999** | **compile error** |
| `apply(take_byte, 7)` | valid | compile error (erasure -- see "Higher-order apply behavior") |
| `apply(identity, 9999)` (untyped callable) | valid | valid (unchanged) |
| `if cond: take_byte else: take_byte; f(7)` | valid | valid (same callable, no join erosion) |
| `if cond: take_byte else: take_small; f(3)` | valid (uncheckable, unsound) | compile error (join erasure) |
| `fn chooser(): take_byte`; `chooser()(7)` | valid | valid (return preserves identity) |
| `fn inner(v: Byte): f(v)` (captures typed `f`) | valid/error per argument | valid/error per argument (unchanged) |
| `fn inner(v): f(v)` (captures typed `f`, untyped `v`) | compile error (unprovable `v`) | compile error (unchanged, not new) |

## Stop condition

True, without qualification: for every function with a declared parameter
type, every executable invocation path statically preserves and enforces
that parameter contract; a first-class callable flow that would erase the
contract is rejected before execution; no runtime parameter check exists
anywhere in this diff. And: inside `fn f(x: Byte):`, the compiler may
unconditionally treat `x` as `Byte`, regardless of whether `f` is ever
materialized as a first-class value -- because every surviving path to
calling `f` now provably preserved enough information to have checked
that assumption first.
