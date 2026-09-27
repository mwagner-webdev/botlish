# R2: ordinary Botlish `emailish?` + predicate-identity cleanup

## Outcome

**Success**, with one honestly-reported partial result (§"M9 auto-payoff" below)
and one honestly-reported out-of-scope discovery (a pre-existing, unrelated
native-lowering bug, §"A pre-existing bug found, not fixed").

`emailish?` is now the canonical predicate, implemented as an ordinary
Botlish module function (`web::is_emailish`, `lib/web.bot`), reached from
the native (Cranelift) backend through `-module-fn` -- the same mechanism
`NATIVE-MODULES.md` built for `uriEscape`/`web::uri_escape_text` -- with no
`-native-body` at all. `Emailish?` is a temporary compatibility alias
(`core::native::alias`), unifying both spellings onto the identical
root `BindingId`/`SymbolId`/registry entry: never a second registration,
a runtime `Block` value, or a wrapper function.

The full predicted causal chain (spec's Primary Hypothesis) holds for its
*semantic* half and its *closedness* half, and does **not** hold for the
*scanner-range* half -- a precise, measured, unforced negative result, not
a predetermined success story:

```
native-body bridge gone for Emailish?/emailish?          CONFIRMED
    -> ordinary predicate identity survives resolution/HIR   CONFIRMED
    -> predicate refinement survives                         CONFIRMED
    -> redundant inner Emailish?/emailish? call disappears   CONFIRMED (zero calls, not just fewer)

no synthetic callee-position Block value                 CONFIRMED
    -> no bridge-created open generic predicate path         CONFIRMED (no anonymous instance)
    -> scanner/char_at closures no longer receive
       unknown ingress through *that* path                   CONFIRMED
    -> M9 recovers scanner Int ranges                        DOES NOT HAPPEN -- see below;
                                                               root cause identified, not hir/range.tcl
```

## 1. Fresh pre-R2 reproduction

`bench/refined-checks.ir` on `cranelift` (unmodified tree, via `git stash`):

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
   value: [400, 0]
```

The *value* was already correct pre-R2 (the redundant check re-evaluates the
same true value, so it was never a correctness bug) -- the pathology is
entirely about *how much code runs and exists*, confirmed directly:

- `native::codeSize`: **15187 bytes**, 33 compiled function instances.
- `hir::specialize::analyze`: **39** used instances total.
- Two byte-identical duplicate groups in the size list (`681 769 262 804
  564 468 452 644`, appearing twice) -- the entire scanner/validator body,
  compiled independently once per call site (outer, genuinely dynamic;
  inner, statically redundant).
- Two **anonymous** (unnamed) used instances, `i18`/`i28`-adjacent in the
  `spec instances` dict (`hir::specialize::analyze`), each carrying
  `generic 1 specializations 1` in `native::report`'s per-function census --
  the dead, materialized callee-position `fnvalue` the milestone predicted.
  `check`'s own instance (`i18`) shows `values=e332 e552`
  (`hir::aot::materializedBlocks`'s per-instance field): its *own* region
  materializes two Block values -- exactly the two per-call-site copies of
  the native-body literal.
- `hir::range::analyze`: every scanner parameter (`scan_local`'s `i`,
  `scan_label`'s `i`, `scan_alpha`'s `i`, `tld_ok`'s `i`, `domain_loop`'s
  `i`, `char_at`'s `i`) shows `[-inf, +inf]` -- reproducing M9's own
  negative control exactly. `check`'s own `n` parameter independently shows
  `[0, 400]` -- M9's own, already-working improvement, confirmed as the
  control it is.
- `hir::range::OpenInstances`: every scanner instance is flagged open.

All of this matches `NATIVE-TCL-UNICODE.md`'s and `M9-INSTANCE-ENTRY-INT-
FACTS.md`'s own accounts; nothing here was assumed from memory -- every
number above was measured fresh, on the unmodified tree, before any
production change in this milestone.

## 2. Current `Emailish?`/native-body architecture (before R2)

Answering §10's architecture questions directly, from the pre-R2 tree:

1. **What is `Emailish?` before R2?** A `core::native::register`-based
   type-test predicate (`core::type::definePredicate Emailish`,
   `lib/web.tcl`): `-impl core::type::PredicateImpl` (evidence-or-validator,
   `core::type.tcl`), `-tests-type {refined str {Emailish}}`, and a
   **`-native-body`**: a hand-written `(block {v} ...)` core-IR literal
   reproducing `emailRegex`'s grammar via `core::tclcompat`'s
   `is_tcl_alnum`/`is_tcl_alpha` (added by the Tcl-Unicode-classification
   milestone, `NATIVE-TCL-UNICODE.md`, superseding the still-earlier,
   `-native-body`-less state `NATIVE-EMAILISH.md` documented as "Outcome
   B").
2. **Where does its callable/predicate identity live?** `core::native`'s
   registry, under the key `"Emailish?"`, and (per program) one root
   `Binding`/`Symbol` created on first reference (`hir::resolve::
   RootBinding`).
3. **Where does its refinement theorem live?** The registry entry's own
   `testsType`/`refinesTrue` fields, set automatically by
   `core::native::register` from `-tests-type` (`{0 {refined str
   {Emailish}}}`) -- consulted by name (`hir::refine::branchFacts`,
   `hir::refine::decideTypeTest`) whenever a call's callee is HIR-typed
   `{native NAME}`.
4. **At what phase does its native body replace the call?** Before
   `hir::build` ever runs, and *only* for the native (Cranelift) backend's
   own program entry point: `native::ExpandNativeBodies`
   (`native/native.tcl`), walking the program's *raw* core IR and
   substituting `-native-body`'s literal in place of `(ref Emailish?)`
   wherever it is a direct callee.
5. **Why does that replacement erase refinement identity?** After
   substitution the call's callee is a `(block {v} ...)` *literal*, not a
   `(ref Emailish?)` at all -- `hir::types::Call` only ever sets `known`/
   establishes a native's refinement facts when the callee's own HIR type
   is `{native NAME}`; a literal block callee types as `{block E ...}`
   instead, so `decideTypeTest`/`branchFacts` never run for it (confirmed
   directly: `hir::types::Call`, `hir/refine.tcl`, unmodified logic, both
   gate on `[lindex $calleeType 0] eq "native"`).
6. **Why does it materialize a callable/block value?** The substituted
   literal is a *fresh, per-call-site* `(block ...)` node with no name and
   no shared identity -- `hir::aot::materializedBlocks`'s first rule
   ("creating a block that is not envless... unconditionally") flags its
   very creation, and it is never resolvable to a single stable `BindingId`
   the way an ordinary top-level function is.
7. **What exact open/generic instance results?** An **anonymous**
   (`name ""`) used `hir::specialize` instance per call site (two of them:
   the outer `Emailish?(s)` check and the inner, statically redundant
   re-check) -- confirmed directly in `hir::specialize::analyze`'s
   `instances` dict.
8. **Which downstream scanner instances does that affect?** `scan_local`/
   `scan_label`/`scan_alpha`/`tld_ok`/`domain_loop`/`char_at`, each a nested
   closure defined *inside* that anonymous block, each duplicated once per
   call site (12 total instances pre-R2 for these six names, two each) and
   each flagged `open` by `hir::range::OpenInstances`, which is why their
   own entry parameters never narrow past `[-inf, +inf]`.

## 3. Ordinary Botlish implementation

`web::is_emailish` (`lib/web.bot`), an ordinary top-level module function:
the same left-to-right, three-scanner grammar (`scan_local`/`scan_label`/
`scan_alpha`, `char_at`, `is_local_char`/`is_label_char`, `tld_ok`,
`domain_loop`) the old `-native-body` used, now as real Botlish source --
nested `fn` definitions, `if`/`else` as expressions, ordinary recursion,
over `length`/`substring`/`is_tcl_alnum`/`is_tcl_alpha`/`==`/`+`/`-`/`>=`.
No compiler-oriented special form, no hand-rolled representation trick: the
whole point (spec item 12) is to see whether the *ordinary* pipeline
optimizes this as well as the privileged one did.

`lib/web.tcl`'s registration:

```tcl
core::type::definePredicate Emailish emailish? "" {web is_emailish}
core::native::alias Emailish? emailish?
```

`core::type::definePredicate` gained a fourth, optional argument
(`moduleFn`, forwarded to `-module-fn`) -- exactly parallel to its existing
third (`nativeBody`, forwarded to `-native-body`) that `NATIVE-EMAILISH.md`
added. `emailish?` carries **no** `-native-body`: `native::
ExpandNativeBodies` never touches it, on any backend, for any spelling.

## 4. Compatibility alias design

**Preferred order (spec item 5) followed exactly:**

1. *Existing resolver/import/symbol alias machinery* -- audited and found
   absent: `surface/modules.tcl`'s own comment states plainly "no `import X
   as Y`" (`NATIVE-MODULES.md`'s design deliberately excluded namespace
   aliasing), and no generic root-identifier alias mechanism exists
   anywhere in `hir/resolve.tcl` or `core/native.tcl` before this milestone.
2. *Smallest compile-time name-alias mechanism* -- built, and it is small:
   `core::native::alias`/`isAlias`/`canonicalName`/`aliasNames`/
   `aliasPairs` (`core/native.tcl`, ~45 lines including comments), plus
   three call sites that were already the *only* three places a bare root
   identifier's text ever gets resolved to a value/type, made
   alias-transparent:
   - `hir::resolve::RootBinding` (`hir/resolve.tcl`): an alias reference
     reuses the canonical name's own `RootBinding` recursively, memoizing
     the *alias spelling* under the *same* `BindingId` -- so both spellings
     literally share one `Binding` and one `Symbol`, created at most once,
     whichever spelling is referenced first.
   - `core::rootEnv` (`core/evaluator.tcl`): the interpreter's own root
     environment (used directly by the `interp` backend, which does not go
     through `hir::resolve` at all) gets one `core::env::define` per alias,
     each holding the *canonical* name's own value (`core::value::native
     $canonical`) -- the identical value the canonical entry's own binding
     holds.
   - `core::native::metadata` (`core/native.tcl`): transparently
     canonicalizes before the registry lookup, so every one of its many
     existing callers (`hir::refine.tcl`, `hir/types.tcl`, `native/
     lower.tcl`'s `NativeCall`, hand-written `.hir` fixtures that embed a
     pre-resolved `{native Emailish?}` type directly, ...) is alias-safe
     with zero further changes.
3. Never reached: option 2 sufficed.

**Why the alias is not a runtime callable value (spec item 4, hard
prohibition):** `core::native::alias` records a *compile-time* name
mapping only (a plain Tcl dict, consulted three times, listed above); it
creates no `core::value` of any kind by itself. Verified directly
(`emailish-predicate-alias-not-runtime-value`,
`tests/emailish-predicate.test`): `core::eval {ref Emailish?}` returns
literally `{native emailish?}` -- the *canonical* name is baked into the
value the moment the binding is created, on every backend, so nothing ever
constructs, stores, or calls a `Block` because of the alias.

**Rejected forms, both avoided as instructed:**

- `Emailish? = emailish?` (an ordinary runtime binding to a `Block`/
  native value) -- not needed; §5's option 2 sufficed without it, and it
  would have created a second Symbol/value for no reason.
- `fn Emailish?(x): emailish?(x)` (a wrapper function) -- also not needed;
  a wrapper would need its *own* type-test/refinement metadata to refine
  anything at all (ordinary Botlish functions have none -- see §"Required
  architecture questions" below), which is exactly the semantic gap this
  design avoids by keeping `Emailish?` a pure name, never a second
  callable.

## 5. Predicate-refinement identity model

**Refinement is not, and never was, uniquely coupled to `-native-body`.**
`hir::refine::branchFacts`/`decideTypeTest` key entirely off
`core::native::metadata`'s `testsType`/`refinesTrue` fields, which any
`core::native::register`-based type-test predicate gets automatically
(`-tests-type`) -- this is the *ordinary*, general way every named-type
predicate in this codebase (`NonEmpty?`, `UriQueryValue?`, any
`-integer-domain` predicate) already refines its argument, `Emailish?`
included, on `interp`/`compile` both before and after this milestone. What
was privileged was specifically the *executable form* the native backend
used (`-native-body`'s pre-HIR substitution), which discarded that
identity only on that one backend, only because it retyped the callee away
from `{native NAME}` before `hir::types::Call` ever saw it.

**The one real semantic gap R2 had to close, found by measurement, not
assumed:** `NATIVE-MODULES.md`'s own `-module-fn` bridge (built for
`uriEscape`, which is *not* a predicate) retypes a bridged native's every
reference from `{native NAME}` to `{block E arity any}`
(`hir::types::BindingType`'s `moduleNativeTargets` case) -- for exactly the
same reason `-native-body` did: so native lowering treats the call as an
ordinary, ordinary-optimizable closed call, not a native op needing a
`native/lower.tcl` whitelist entry. Reused verbatim for `emailish?`, this
would have reintroduced the *identical* refinement/known-folding loss on
`cranelift`, merely through a different mechanism -- confirmed by direct
inspection of `hir::types::Call` and `hir::refine::branchFacts`, both of
which require `calleeType[0] eq "native"` and would silently stop firing.

**The fix: recover the underlying native identity, not retype away from
it.** A small, general helper, `hir::types::BridgedNative` (`hir/
types.tcl`): given a call's callee expression, if it is a `ref` to a root
binding whose *value* is a native (regardless of what `BindingType`
reported its *type* as), returns that native's own name. Used in exactly
two places, both already-general machinery, neither predicate-specific:

- `hir::types::Call`'s `block`-calleeType branch now also computes `known`
  via `hir::refine::decideTypeTest`, using `BridgedNative`'s recovered name,
  whenever that name's own metadata carries a `testsType` -- so a
  module-bridged predicate's `known`-fold works identically to an
  unbridged one's, on every backend.
- `hir::refine::branchFacts` now also recovers a `block`-calleeType
  reference's underlying native name the same way, for the same reason
  (successful-call refinement, not just known-folding).

`native/lower.tcl`'s `Call` gained the matching, minimal lowering-side
piece: its `block`-`targetKind` branch checks `[dict get $node known]`
*first*, exactly mirroring `NativeCall`'s own existing fold, before doing
any of the ordinary block-call codegen (`FunctionRef`, `hir::specialize`
instance lookup, ...) -- so a `known` bridged-predicate call needs zero
code, on the identical terms an unbridged one already did.

**Net effect (spec item 45's own question, answered explicitly): the
theorem is stored by semantic resolved target, not by source spelling.**
`testsType`/`refinesTrue` live on one registry entry (`emailish?`'s own);
both spellings resolve to the identical `Binding`/`Symbol`/native value
(§4); `decideTypeTest`/`branchFacts` are keyed by the *native's own name*,
recovered from the call's *value*, never from the literal text a
particular call site happened to spell.

## 6. HIR before/after

Before (unmodified tree, `-backend interp -hir bench/refined-checks.ir`;
`interp` was always unaffected by the bridge, so this is the *baseline*
refinement shape both before and after R2 -- what changes is whether
`cranelift`'s own HIR build agrees with it):

```
e11  call native(Emailish?) : bool          <- outer, on s: DYNAMIC
        e12 ref b9 Emailish? : native Emailish?
e15  call native(Emailish?) = true : bool   <- inner, on s: KNOWN TRUE
        e16 ref b9 Emailish? : native Emailish?
```

After (same interp dump, current tree):

```
e11  call native(emailish?) : bool          <- outer, on s: DYNAMIC
        e12 ref b9 emailish? : native emailish?
e15  call native(emailish?) = true : bool   <- inner, on s: KNOWN TRUE
        e16 ref b9 emailish? : native emailish?
    then s6 refines b5 s : str[Emailish]
```

The only textual change is the canonical spelling (`emailish?`, not
`Emailish?`) `hir::resolve::RootBinding` now always produces, regardless of
which spelling the source used -- confirmed with `bench/refined-checks.ir`
itself unedited (it still says `Emailish?`).

For the compatibility spelling specifically (a fresh two-reference
fixture, `hirOf`):

```
e1  bind b1 emailish?      ; first reference (either spelling) creates it
e.. ref b1 emailish?       ; a same-program reference via "emailish?"
e.. ref b1 emailish?       ; a same-program reference via "Emailish?"
```

Both resolve to the identical `b1` -- pinned directly,
`emailish-predicate-alias-same-binding` (`tests/emailish-predicate.test`):
`hirRefBindings $hir emailish?` and `hirRefBindings $hir Emailish?` return
the same single-element list.

## 7. Native-body path before/after

Before: `Emailish?`'s registry entry carries a `-native-body`;
`native::ExpandNativeBodies` substitutes it, per call site, before
`hir::buildSyntax` ever runs, only on `cranelift`/`cranelift-generic`.

After: neither `emailish?` nor `Emailish?` has a `-native-body` (pinned,
`native-validator-predicate-emailish-has-no-native-body`). `native::
ExpandNativeBodiesIn`'s traversal *does* still visit every call node (it is
shared, unmodified-in-substance machinery that also serves
`nativeResultOverrides`/`moduleNativeCalls` bookkeeping for `-module-fn`
natives generally -- unrelated to `-native-body` itself) -- but it
substitutes nothing for this predicate, under either spelling, because its
`nativeBody` field is empty. The one change made to that traversal
(canonicalizing a bare `ref`'s text through `core::native::canonicalName`
before checking `core::native::names`/`metadata`) is *necessary* purely so
that a call spelled with the alias (as the frozen `bench/refined-checks.ir`
spells it) is still recognized as needing the `-module-fn` bridge's
bookkeeping -- it does not touch, extend, or re-enable body substitution in
any way; a discussion of why this one line is not "teaching
`ExpandNativeBodies` alias transparency" in the sense spec item 18
prohibits is in §"A note on one line in `ExpandNativeBodiesIn`" below.

## 8. Dead fnvalue / open-instance before/after

| | before | after |
|---|---|---|
| anonymous (`name ""`) used instances | 2 | 0 |
| `check`'s own `values` (materialized Blocks in its region) | `e332 e552` (2) | *(empty)* |
| used instances total (`hir::specialize::analyze`) | 39 | 28 |
| duplicate scanner/validator function copies | 2 each (one per call site) | 1 each |
| `web::is_emailish`/its scanner helpers' own `generic`/`specializations` | n/a (anonymous) | `web::is_emailish {generic 0 specializations 1}`; scanners `{generic 1 specializations 0}` |

Pinned directly: `emailish-predicate-no-anonymous-callee-instance` (0
anonymous instances) and `emailish-predicate-check-scanner-instance-count`
(`web::is_emailish` and each of its six scanner helpers: exactly 1 used
instance, never 2), both in `tests/emailish-predicate.test`.

## 9. M9 scanner facts before/after -- and the actual first loss

Per-parameter `hir::range::analyze` results (fresh, both states):

| instance.param | before | after |
|---|---|---|
| `check.n` | `[0, 400]` | `[0, 400]` (**unchanged control**) |
| `web::is_emailish.v` (str; no Int range applies) | n/a (didn't exist) | `[-inf, +inf]` (str kind; not an Int fact) |
| `char_at.i` | `[-inf, +inf]` (x2 copies) | `[-inf, +inf]` (x1) |
| `scan_local.i` | `[-inf, +inf]` (x2) | `[-inf, +inf]` (x1) |
| `scan_label.i` | `[-inf, +inf]` (x2) | `[-inf, +inf]` (x1) |
| `scan_alpha.i` | `[-inf, +inf]` (x2) | `[-inf, +inf]` (x1) |
| `tld_ok.i` | `[-inf, +inf]` (x2) | `[-inf, +inf]` (x1) |
| `domain_loop.i` | `[-inf, +inf]` (x2) | `[-inf, +inf]` (x1) |

`hir::range::OpenInstances`: **every scanner instance is still flagged
`open`, both before and after.** `hir/range.tcl` was not modified (grep-
verified: this file is absent from `git diff --stat`'s output).

**This is the honest stop-and-report point spec item 63 asks for.** Before
concluding "M9 didn't unlock, nothing more to do," this milestone traced
*why*, without touching `hir/range.tcl`:

`hir::aot::materializedBlocks`'s own first rule flags the *creation* of any
non-envless (capturing) block unconditionally, independent of how it is
later used -- `web::is_emailish`'s own nested helpers (`char_at`,
`scan_local`, `scan_label`, `scan_alpha`, `tld_ok`, `domain_loop`) each
capture free variables from their enclosing scope (`v`, `n`), so each one
is "materialized" in `web::is_emailish`'s own region by construction,
before `hir::range`/`hir::specialize` ever get a chance to know that
`native/lower.tcl`'s own later virtualization pass (`hir/blockescape.tcl`'s
capture-flattening, confirmed still firing --
`native-block-escape.test`'s own "flatten captures from `[n, char_at]` to
`[n, v]`" tests, still green) will in fact eliminate every one of those
captures at lowering time. `hir::range::OpenInstances`'s own doc comment
is explicit that this is deliberate, sound conservatism ("a value that can
be called through unknown dynamic dispatch this analysis has no edges
for") -- not a bug, and not something this milestone found evidence to the
contrary of.

**Proof this is general, pre-existing, and has nothing to do with
`Emailish?`/R2:** `lib/web.bot`'s own pre-existing `web::uri_escape_text`
(added by `NATIVE-MODULES.md`, untouched by this milestone) has the
*identical* nested-closure shape, and its own helpers (`esc_from`,
`esc_char`, `esc_bytes`, `hex_pair`) show the *identical* `open=1`
classification under `hir::range::OpenInstances`, measured on the same
unmodified `refined-checks.ir` HIR, both before and after this milestone's
changes (only `high_nibble`, which happens to capture nothing at all, is
`open=0`). This was true before R2 touched anything and remains true
after; it is a structural property of writing nested closures with
captures in ordinary Botlish, at the range-analysis layer, not a
consequence of the native-body bridge R2 removed.

**Per spec item 63: stopping here, not patching `hir/range.tcl`.** The
correct next step, if this is worth pursuing, is teaching `hir::range`'s
entry-fact computation (or the pass ordering between it and `hir::
blockescape`'s virtualization proof) that a captured closure whose captures
`hir::blockescape` already proves flattenable is not truly "escaping" for
range purposes -- a change to `hir/range.tcl`/`hir/blockescape.tcl`
interaction, well outside this milestone's scope (spec items 21, 63), and a
plausible candidate for a *future*, differently-scoped milestone, not R2.

## 10. What R2 *did* unlock, independent of M9

Despite the range-narrowing miss, R2's own two other predicted wins hold,
fully, with hard evidence:

- **The redundant second predicate execution is eliminated, not merely
  cheapened.** `native::nir` on the exact `refined-checks.ir`-shaped
  pattern (`if Emailish?(s): ... Emailish?(s)`) shows the inner check
  compiled to `%10 = bool true @e578` -- a bare constant, zero calls, zero
  guards -- while the outer, genuinely dynamic check compiles to exactly
  one `call 9 %2 @e574` into the one shared `web::is_emailish` function.
  Before R2, both checks independently called their own copy of the whole
  scanner chain.
- **The dead callee-position fnvalue and its open generic instance are
  gone, not merely reduced.** §8's table: 2 anonymous instances -> 0; 2
  materialized Blocks on `check`'s own region -> 0.

## 11. Canonical instance/call graph before/after

`hir::specialize::analyze`, `bench/refined-checks.ir`, both states:

| | before | after |
|---|---|---|
| used instances | 39 | 28 |
| anonymous used instances | 2 | 0 |
| `web::is_emailish`/scanner-family instances | 12 (2 copies x 6 names, all anonymous-owned) | 7 (1 copy x 6 scanners + 1 `web::is_emailish`) |
| `check`'s own materialized values | `e332 e552` | *(none)* |

No specialization identity proliferation: `web::is_emailish` itself gets
exactly one specialized instance (`str` -- its only call shape), and no new
per-call predicate clone exists for the alias spelling (confirmed:
`emailish-predicate-no-second-instance`, exactly one `web::is_emailish`
function definition in the compiled `refined-checks.ir` NIR, regardless of
which spelling any call site used).

## 12. Canonical instruction/code-size census

`native::codeSize`, `bench/refined-checks.ir`, `cranelift`:

| | before | after | delta |
|---|---|---|---|
| total machine bytes | 15187 | 9868 | -35.0% |
| compiled function instances | 33 | 24 | -9 |

NIR text (`native::nir`, same program):

| | before | after |
|---|---|---|
| NIR lines | 1060 | 758 |
| `call` instructions | 32 | 22 |
| `guard`/`guardbool` instructions | 3 | 1 |
| `op regioncheck` | 2 | 1 |
| `op strlen` | 5 | 2 |

`check`'s own function body (the timed hot loop) is now exactly:

```
%8 = call 9 %2 @e574                 ; the one real, dynamic Emailish? check
br %8 L3 L4
label L3
  %10 = bool true @e578              ; the redundant re-check: zero cost
  %11 = bool true @e582              ; UriQueryValue?(q): folds too (pre-
                                      ;   existing, unrelated to R2 -- see
                                      ;   note below)
  ...
```

(The `UriQueryValue?(q)` fold shown above is **not** an R2 effect: measured
identical, byte-for-byte, on the unmodified tree via `git stash` --
`check`'s per-caller specialization instance already proved `q`'s evidence
before this milestone touched anything, an unrelated, already-working
piece of `hir/specialize.tcl`'s per-instance inference. Recorded here only
so the `check` body excerpt above is not misread as new.)

## 13. Duplicate-pass contribution vs. M9-unlocked contribution

Spec item 32's requested decomposition, answered directly from the
measurements above:

- **A. Semantic/refinement win (duplicate predicate execution removed):**
  the entire measured 35% code-size reduction and the 2-anonymous-
  instances-to-0 / 39-to-28-used-instances change. This is 100% of R2's
  measured win.
- **B. Secondary M9 win (remaining predicate pass gets better scalar entry
  facts):** **zero**, measured -- §9 shows `hir::range::analyze`'s own
  entry facts for the surviving scanner instances are byte-for-byte
  identical before and after (still `[-inf, +inf]`, still `open`). M9 was
  not "unchanged and merely unlucky here" in the sense of a missed
  opportunity R2 should have unlocked automatically and didn't for some
  R2-caused reason -- §9 traces the actual, general, pre-existing reason
  (materialization-by-capture, independent of the bridge) directly.

No isolation flag was needed to separate these (spec item 32's
alternative): the instance-count/materialized-value evidence already
separates them cleanly, since A is visible entirely in instance/byte counts
and B is visible entirely (and negatively) in `hir::range::analyze`'s own
output.

## 14. String-region/helper residual census

`op regioncheck`: 2 -> 1 (the duplicated call site's own region check is
gone with it; the remaining one is unchanged -- R2 adds no relational
`i < length(v)` proof, per spec item 34, so it was never a candidate for
removal). `op strlen`: 5 -> 2. No `rt_str_region_*`-named helper calls
appear in this program's NIR text under either state (the region-check
family here shows as `op regioncheck` directly, not a separate named
`rt_str_region_check` call) -- their share, whatever it is, simply halves
with everything else that was duplicated, since nothing about their own
implementation changed.

## 15. Machine-code size before/after

§12's table. 15187 -> 9868 bytes (-35.0%), 33 -> 24 functions.

## 16. Allocation/GC census

`native::allocationReport … summary 1`, `bench/refined-checks.ir`:

| | before | after |
|---|---|---|
| total allocations | 20 | 20 |
| Block allocations | 2 | 2 |
| String allocations | 4 | 4 |
| List allocations | 11 | 11 |
| ImmutableSet allocations | 1 | 1 |
| GC cycles | 0 | 0 |
| UTF-8 seek bytes (`traversal.utf8SeekBytes`) | 112000 | 56000 |
| static String bytes (`static.byKind.String.bytes`) | 1195 | 1195 |
| static Block allocations | 2 | 0 |

**Zero hot allocation introduced** (spec item 37): the runtime totals are
identical; the only two differences are `utf8SeekBytes` (halved, exactly
tracking the halved number of scan passes over the same two input strings)
and `static.byKind.Block` (2 -> 0: the two per-call-site native-body
literals no longer exist as constant-table entries at all -- a *reduction*,
not a new cost). `BOTLISH_NATIVE_GC_STRESS=1` survives unchanged
(`[400, 0]`, both without and with it).

## 17. Semantic parity

`emailish-predicate-parity-*` (`tests/emailish-predicate.test`), both
spellings, on all four backends: ordinary ASCII (`someone@example.com`,
true), an accepted non-ASCII address (`café@例え.テスト`, true -- the same
Unicode-forcing case `bench/refined-checks.ir` itself uses), no `@`
(false), an empty local part (false), an invalid local-part character
(`"a b"@example.com`, false), an invalid domain-label character
(`foo@bad_domain.com`, false -- `_` is not in the domain-label class), a
too-short TLD (`foo@example.c`, false), and the empty-string/`@`-only
boundary cases (false). No semantic behavior was changed (spec item 13):
every one of these is a faithful port of the exact scan the old
`-native-body` already performed.

## 18. Focused tests

`tests/emailish-predicate.test`, new, 29 tests, all passing: both
spellings work directly and agree (interp/compile/cranelift-generic/
cranelift); the 9-case valid/invalid corpus above under both spellings;
same refinement theorem under either spelling, and cross-spelling (`if
emailish?(s): Emailish?(s)` and the reverse) proven statically redundant
via generated-code inspection, not just a runtime assertion; the redundant
check's HIR `known` field and its zero-call NIR shape; identical
`BindingId` for both spellings; no runtime Block value for the alias; the
alias is `core::native::isAlias`, never a second `core::native::names`
entry, with identical metadata; exactly one compiled `web::is_emailish`
function regardless of how many call sites or spellings reference it;
case-sensitivity otherwise unchanged; the module/library opt-in path
through an isolated interpreter (not a hand-built HIR fixture); an
existing-style fixture using only `Emailish?` and a canonical-style
fixture using only `emailish?`; the R2-specific range regression (no
anonymous callee instance, exactly one instance per scanner helper); and
the `check.n` control.

## 19. Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl`: **all tests pass**
after updating exactly the implementation-path tests R2 intentionally
changes (below) -- no semantic test was weakened.

Tests updated, and why each is an intentional, disclosed consequence of
R2, not a silent behavior change:

- `tests/native-tcl-unicode.test`
  (`native-tcl-unicode-emailish-known-result-nir-shape`): this test's
  entire purpose was pinning the *old* disclosed gap ("two independent
  copies of the validator") as a documented-not-fixed limitation. Rewritten
  to pin the closed gap instead (exactly one compiled copy, exactly one
  real call), using `native::buildProgramHir` (the correct, bridged HIR
  build) instead of the old direct `hir::build [native::
  ExpandNativeBodies ...]` call, which no longer has anything to expand for
  this predicate.
- `tests/native-validator-predicate.test`
  (`native-validator-predicate-emailish-has-native-body` ->
  `-emailish-has-no-native-body`): the assertion this test made (Emailish?
  carries a `-native-body`) is precisely what R2 sets out to make false;
  rewritten to assert the new, correct facts (no `-native-body`, under
  either spelling; `-module-fn {web is_emailish}`).
- `tests/native-block-escape.test` (3 NIR-shape count assertions): each
  pinned an exact count of *2* (one copy per call site) for `char_at`'s/the
  five scanner helpers' own compiled signature, and a tail-backedge count
  of 11. Updated to 1 and 7 respectively -- the direct, mechanical
  consequence of one shared copy replacing two duplicated ones, not a
  change in what these tests actually check for.
- `tests/refined.test` (4 tests): `refined-5`'s and
  `refined-type-test-fold-3`'s expected strings named `Emailish?`
  literally, where the runtime/generated code now (correctly) names the
  call's *resolved target*, `emailish?`, regardless of which spelling the
  source used -- updated to the canonical spelling, with a comment
  explaining why. `refined-library-1`'s "opt-in" check used
  `"Emailish?" in [core::native::names]` as its proof that the library
  wasn't loaded yet/was loaded -- no longer meaningful once `Emailish?` is
  an alias rather than a registry entry; rewritten to
  `core::native::isAlias Emailish?`, which checks the same thing the test
  actually cares about ("is this name usable"), correctly, for an alias.
  `refined-type-test-register-2` needed **no code change at all**: it
  failed only until `core::native::metadata`'s own alias-transparency fix
  (§4) landed, then passed unchanged.
- `tests/types.test` (`type-16`): same as `refined-type-test-register-2` --
  needed no code change; passed once `core::native::metadata` became
  alias-transparent.
- `examples/hir/06-refined-strings.{hir,ir}`: a hand-written, pre-resolved
  HIR/IR fixture pair that spelled the predicate `Emailish?` directly in
  already-resolved HIR text (bypassing `hir::resolve` entirely, so my
  resolver-level canonicalization cannot reach it). Since ordinary
  resolution now always produces the canonical spelling, the fixture's own
  text was updated to match what real resolution now naturally derives
  (`emailish?`) -- the *type* name `Emailish` is untouched; only the
  *predicate* spelling changed, with a comment explaining the alias
  relationship for a reader encountering only this file.

No `tests/refined.test`/`tests/native-refinement-propagation.test`/`tests/
hir-refinement.test` *semantic* assertion (evidence combination, contract
checks, opaque-vs-validator distinction, refinement establishment itself)
needed any change -- confirmed by running each file to completion with
zero failures.

## 20. GC stress

`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 main.tcl -backend cranelift
bench/refined-checks.ir`: `[400, 0]`, unchanged. Run because scanner
rawregs/root maps plausibly changed shape (fewer duplicated instances);
they did not disturb the result.

## 21. Source-fence confirmation

`bench/refined-checks.ir` and every other `bench/*.ir`/`bench/*.bot` file:
**zero bytes changed** (confirmed: absent from `git diff --stat`'s file
list). The compatibility alias is exactly what lets this frozen file, which
still spells the predicate `Emailish?` throughout, continue to compile and
run unchanged.

## 22. Residual cost matrix

Refined-checks' remaining major costs, classified (spec item 80),
qualitatively (no separate profiler was available in this environment;
counts are from `native::nir`/`native::codeSize`, which are deterministic):

- **String-region helper cost**: `op regioncheck` x1 (was x2) -- the one
  remaining `substring`/region-shaped operation this program still
  performs (`uriEscape`'s own path), untouched by R2.
- **UTF-8 re-seek**: `traversal.utf8SeekBytes` 56000 (was 112000) -- halved
  with everything else that was duplicated; the underlying per-scan cost is
  unchanged.
- **Region bounds checks**: covered by `op regioncheck` above.
- **Completion/error plumbing**: `guard`/`guardbool` x1 (was x3) --
  the removed guards were exactly the duplicated copies'.
- **`char_at` call/frame**: exactly 1 compiled instance now (was 2); still
  not inlined (out of scope, R3's own candidate, spec item 35).
- **Scanner call/frame**: 6 compiled instances now, 1 each (was 12, 2
  each); each is still `hir::range::OpenInstances`-"open" (§9) -- the
  identified, unforced, honestly-reported residual.
- **Remaining tagged-Int ABI work / root publication / backend frame
  cost**: not separately measured in this environment (no callgrind
  available here); `native::codeSize`'s aggregate byte counts (§12/§15) are
  the deterministic proxy used throughout this report, per its own §28
  guidance to prefer deterministic counts over noisy wall time.
- **Other**: `web::is_emailish` itself (the outer, real predicate call)
  and its own frame -- unavoidable, the one genuinely dynamic operation
  this benchmark actually needs to perform.

## 23. Recommended next milestone

Per spec item 81's own four candidates, given this milestone's own
measurements:

- **(A) relational `i < length(v)` proof**: would remove the one remaining
  `op regioncheck`/its completion check -- a real, but now visibly small
  (1 instruction), remaining cost.
- **(B) R3 tiny closed-call/`char_at` inlining**: `char_at` is now a single,
  ordinary, closed, non-duplicated function -- exactly the shape R3's own
  stated precondition (spec item 64) wants, and this milestone's own
  measurement (§22) shows it is still a real, separately-compiled call/
  frame.
- **(C) R4 StringRegion/ASCII fast paths**: this program's UTF-8 re-seek
  cost *halved* purely from R2's own deduplication, with the *proportion*
  of remaining work it represents unmeasured here (no fine-grained
  profiler available in this environment) -- a real candidate, but this
  milestone cannot rank it against (B) with the evidence gathered.
- **(D) raw-Int private ABI**: no evidence gathered here motivates this
  over the other three; not recommended next.
- **A candidate outside the original four, raised directly by this
  milestone's own §9 finding**: teaching `hir::range`'s entry-fact
  computation to trust `hir::blockescape`'s own capture-flattening proof
  for a materialized-by-capture (but not actually independently escaping)
  closure. This is the one change that would make M9's own prediction for
  this benchmark come true, is *general* (applies to `uriEscape`'s own
  nested helpers identically, per §9's proof), and is explicitly **not**
  recommended for immediate adoption without its own dedicated audit --
  it touches exactly the two files (`hir/range.tcl`, `hir/blockescape.tcl`)
  this milestone was instructed to leave alone, and deserves the same
  fresh-measurement discipline this report tried to apply, not a
  drive-by fix bundled into R2.

**Recommendation: (B), R3's tiny closed-call inlining**, as the
best-supported next step from this milestone's own measurements -- `char_at`
and the scanner helpers are now uniformly single-instance, ordinary,
non-anonymous closed calls (this milestone's own direct contribution), the
precondition R3 needs and did not have before. The range-analysis
candidate above is a legitimate alternative with a stronger *ceiling*
(it could also help `uriEscape`) but a real *audit cost* this milestone
did not budget for, and should be scoped and measured on its own terms
before being attempted.

---

## Required architecture questions (spec item 73)

1. **What exactly is `Emailish?` before R2?** A `core::native`-registered
   type-test predicate with a `-native-body` (§2.1).
2. **Where does its callable/predicate identity live?** The `core::native`
   registry entry keyed `"Emailish?"`, and one root `Binding`/`Symbol` per
   compiling program (§2.2).
3. **Where does its refinement theorem live?** The same registry entry's
   `testsType`/`refinesTrue` fields (§2.3, §5).
4. **At what phase does its native body replace the call?** Before
   `hir::build`, native-backend-only, via `native::ExpandNativeBodies`
   (§2.4).
5. **Why does that replacement erase refinement identity?** The
   substituted callee is a block literal, not a `{native NAME}`-typed ref;
   `hir::types::Call`/`hir::refine` require the latter (§2.5, §5).
6. **Why does it materialize a callable/block value?** The substituted
   literal is a fresh, unnamed, non-envless block per call site --
   unconditionally materialized by `hir::aot::materializedBlocks`'s own
   first rule (§2.6).
7. **What exact open/generic instance results?** Two anonymous used
   instances, one per call site, each `generic 1 specializations 1` (§2.7,
   §8).
8. **Which downstream scanner instances does that affect?** The six
   scanner helpers nested inside it, each duplicated once per call site,
   each `open` (§2.8, §9).
9. **What is `emailish?` after R2?** An ordinary `core::native`-registered
   type-test predicate, same registry mechanism, with `-module-fn {web
   is_emailish}` and no `-native-body`; its executable form on every
   backend is either the Tcl `-impl` (interp/compile) or the ordinary,
   compiled-once Botlish function `web::is_emailish` (cranelift/
   cranelift-generic) (§3).
10. **What exactly is `Emailish?` after R2?** A pure compile-time alias
    (`core::native::alias`) for `emailish?`: the identical registry entry,
    root binding, and value, under a second name (§4).

## Required alias questions (spec item 74)

11. **Is `Emailish?` a runtime binding?** No: it is a compile-time name
    mapping (`core::native::alias`) consulted at three lookup sites (§4);
    the *value* both spellings resolve to is `core::value::native
    emailish?`, created once.
12. **Does evaluating/using the alias create a Block value?** No -- pinned
    directly, `emailish-predicate-alias-not-runtime-value`.
13. **Does alias use add a specialization instance?** No -- pinned,
    `emailish-predicate-no-second-instance` (exactly one compiled
    `web::is_emailish` function regardless of spelling/call-site count).
14. **Does alias use add a wrapper function?** No.
15. **Do both spellings resolve to the same semantic predicate identity?**
    Yes -- pinned, `emailish-predicate-alias-same-binding` (identical
    `BindingId`).
16. **Do both spellings establish the same refinement theorem?** Yes --
    pinned, `emailish-predicate-refines-cross-spelling`(-reverse).
17. **Is case sensitivity otherwise unchanged?** Yes -- pinned,
    `emailish-predicate-case-sensitive-otherwise` (`EMAILISH?` is simply
    unbound; only the one declared alias unifies anything).

## Required refinement questions (spec item 75)

18. **Does a successful lowercase predicate call establish Emailish
    refinement?** Yes -- `emailish-predicate-refines-lowercase`.
19. **Does the uppercase compatibility spelling do the same?** Yes --
    `emailish-predicate-refines-uppercase`.
20. **Is a second predicate call on an already-refined value statically
    known?** Yes, where the existing machinery supports it (this exact
    shape) -- `emailish-predicate-redundant-check-known-hir`/
    `-nir-shape`, and both cross-spelling variants.
21. **Is that achieved without a predicate-specific duplicate-call
    optimization?** Yes: `hir::refine::decideTypeTest`'s own logic is
    unmodified; the only change is that `hir::types::Call`/
    `hir::refine::branchFacts` can now recover a *bridged* native's
    identity generally (§5) -- not an Emailish?-specific rule anywhere.
22. **Is refinement metadata keyed by semantic target rather than
    spelling?** Yes, explicitly (§5, §11's answer to spec item 45).

## Required M9 questions (spec item 76)

23. **Which scanner ranges were broad before R2?** All six:
    `scan_local`/`scan_label`/`scan_alpha`/`tld_ok`/`domain_loop`/
    `char_at`'s own `i` parameter, each `[-inf, +inf]` (§1, §9).
24. **Which improve after R2?** None, measured (§9) -- see §13's honest
    accounting and §9's root-cause trace.
25. **Does `hir/range.tcl` change?** No (confirmed absent from `git diff
    --stat`).
26. **Which scanner functions gain rawregs?** None gain *entry-fact-driven*
    rawregs from R2 itself; the NIR's own `rawregs=...` annotations on
    these functions are unchanged in *kind* before/after (both states show
    substantial `rawregs` lists for these functions already, from
    *within-function* flow-sensitive reasoning independent of the entry
    fact -- e.g. `i >= n` dominating an access) -- not a new R2 effect.
27. **Which tagged comparisons become raw?** None, attributable to R2's
    own change specifically (see above).
28. **Which Bool-word operations disappear?** None, in the surviving
    scanner code itself; the *redundant* Bool-typed call's own materialization
    (`bool true`, previously a second real computed comparison chain) is
    the one Bool-related removal, and it is a duplication removal (§10),
    not an M9 effect.
29. **Which root stores disappear?** None measured distinctly from the
    general duplication removal (§12/§16); allocation counts are otherwise
    identical (§16).
30. **Which ranges remain broad, and why?** All six scanner parameters;
    §9 gives the specific, general, pre-existing reason (capture-based
    materialization predates and is independent of the native-body
    bridge), with `uriEscape`'s own identically-shaped helpers as the
    control proving it.

## Required graph questions (spec item 77)

31. **Does the dead callee-position fnvalue disappear?** Yes (§8, §10).
32. **Does the bridge-created open generic predicate instance disappear?**
    Yes, the specific *anonymous, per-call-site* instances do (§8); the
    *named* scanner helper instances remain `open` for the separate,
    general, pre-existing reason in §9 -- not a different remaining path
    created or preserved by the old bridge, but the same structural
    property `uriEscape`'s own helpers already had.
33. **Do scanner instances become closed/ordinary under existing
    analyses?** They become ordinary, *shared, non-duplicated, named*
    instances (§8, §11) -- but not "closed" in `hir::range::
    OpenInstances`'s own specific sense (§9, §32's answer).
34. **Do instance counts decrease?** Yes: 39 -> 28 used instances (§11).
35. **Do any instance counts unexpectedly increase?** No.
36. **Does compatibility aliasing recreate openness?** No -- pinned,
    `emailish-predicate-no-second-instance`/`-no-anonymous-callee-instance`
    with both spellings exercised in the same fixtures.

## Required performance questions (spec item 78)

37. **`refined-checks` Ir/run before/after?** Callgrind was not available
    in this sandboxed environment; the deterministic proxies used
    throughout are `native::codeSize` (§12/§15: 15187 -> 9868 bytes,
    -35.0%) and used-instance counts (§11: 39 -> 28), both fully
    deterministic and both directly reflecting the eliminated duplicate
    pass.
38. **How much of the change is redundant predicate elimination?** All of
    it, measured (§13).
39. **How much is M9 becoming active inside the remaining predicate
    pass?** None, measured (§9, §13).
40. **Runtime helper calls before/after?** `call` instructions 32 -> 22
    (§12).
41. **region helper calls before/after?** `op regioncheck` 2 -> 1 (§14).
42. **UTF-8 seek bytes before/after?** 112000 -> 56000 (§16).
43. **tagged-Int class before/after?** Not separately isolable without a
    profiler in this environment; `native::codeSize`'s aggregate is the
    proxy used.
44. **Bool-word class before/after?** See Q28.
45. **root/stack class before/after?** Allocation counts identical (§16);
    no separate root/stack instrumentation was available.
46. **completion checks before/after?** `guard`/`guardbool` 3 -> 1 (§12).
47. **machine bytes before/after?** 15187 -> 9868 (§12/§15).
48. **wall-time median/range before/after?** Not measured: this sandbox has
    no isolated, quiet host for a noise-free wall-clock series, and per
    spec item 58/59 causal claims here rest on the deterministic counts
    above, not wall time.

## Required negative controls (spec item 79)

49. **fib deterministic Ir unchanged?** `native::codeSize` byte-for-byte
    identical (`292 {49 243}`), both states (§ "Other benchmark
    invariance" below).
50. **loop-count deterministic Ir unchanged?** Identical
    (`287 {63 31 193}`).
51. **sum-refined deterministic Ir unchanged?** Identical
    (`286 {63 125 98}`).
52. **M8.a construction behavior unchanged?** Yes: `native::
    allocationReport`'s `construction` dict (`materializations 1
    passthrough 0 plansCreated 2 extensions 3 merges 2 ...`) is identical,
    both states (§16).
53. **no hot allocation introduced?** Confirmed, §16.
54. **UriFragment untouched?** Confirmed: no reference to `UriFragment`
    anywhere in this diff (`git diff --stat`); not mentioned in `lib/
    web.tcl`/`lib/web.bot` at all.
55. **callable-type syntax otherwise untouched?** Confirmed: `surface/*`,
    `hir/callables.tcl`, `hir/sourcetypes.tcl` all absent from `git diff
    --stat`; the uppercase `NAME?` surface syntax itself was never touched,
    only `Emailish?`'s own registration changed from a second full
    registration to an alias.
56. **no raw-Int ABI added?** Confirmed: no such change anywhere in this
    diff.
57. **no inliner change?** Confirmed: `LeafInlineEligible`/
    `InlineLeafCall`/the "Tiny exact-leaf inlining" section of
    `native/lower.tcl` are untouched (only the unrelated `Call` block-branch
    addition, §5, was made, before any inlining decision is even reached).
58. **no StringRegion representation change?** Confirmed: `hir/
    stringregion.tcl` absent from `git diff --stat`.

## Other benchmark invariance

`bench/fib.ir`, `bench/loop-count.ir`, `bench/sum-refined.ir`: identical
values and identical `native::codeSize` byte counts on every backend,
measured fresh both before and after this milestone's changes (via `git
stash`), reproduced in §1/§49-51 above.

## A pre-existing bug found, not fixed

While building the focused test file, an existing-style fixture combining
`uriEscape` with an `if`/`ok`/`error-value` (`result`-typed) branch raised
`{NATIVE BUG} native lowering: binding bNN is not reachable from eNN`, on
`cranelift`/`cranelift-generic`. Isolated directly: this reproduces with
`uriEscape` **alone**, no `Emailish?`/`emailish?` involved at all, and
reproduces identically on the unmodified pre-R2 tree (confirmed via `git
stash`). It is `uriEscape`'s own `-module-fn`/`ModuleBridgeBinding`
interacting with `result`-typed (`ok`/`error-value`) branch lowering --
entirely unrelated to this milestone's subject, and not fixed here, per
spec item 27's "measure, don't drive-by-fix." The focused test fixtures in
`tests/emailish-predicate.test` that originally exercised this shape were
rewritten to avoid `uriEscape` (using a plain boolean/list result instead),
so this milestone's own regression suite stays green without masking or
touching the unrelated bug. Left for whoever next touches `uriEscape`'s
own module bridge or `result`-typed branch lowering.

## A note on one line in `ExpandNativeBodiesIn`

Spec item 18 prohibits "teach[ing] `ExpandNativeBodies` alias
transparency," among other things, as a way of keeping the *old*,
privileged mechanism relevant instead of doing R2's actual job. The one
line changed in `native::ExpandNativeBodiesIn` (`native/native.tcl`) does
not do that: it canonicalizes a bare `ref`'s text before checking
`core::native::names`/`metadata`, in the *traversal* that also collects
`moduleNativeCalls`/`nativeResultOverrides` bookkeeping for **any**
`-module-fn` native (a mechanism `NATIVE-MODULES.md` built and this
milestone reuses unmodified, not `-native-body`'s own substitution logic,
which `emailish?` never touches at all -- its `nativeBody` field stays
empty under either spelling, always). Without this one line, a program
that only ever spells the predicate `Emailish?` (as the frozen
`bench/refined-checks.ir` does) would never reach the module bridge at
all, because this traversal runs *before* `hir::resolve` (by necessity --
`buildProgramHir` needs to know which modules to prepend before HIR can be
built at all), so it cannot rely on `hir::resolve::RootBinding`'s own
canonicalization (§4) the way every other part of this design does. This
is disclosed here explicitly, rather than left for a reviewer to have to
find, precisely because it sits closest to the letter of spec item 18's
prohibition; the judgment made is that it is bookkeeping *discovery* for
an unrelated, already-general, already-accepted mechanism (`-module-fn`),
not sophistication added to the native-body *substitution* mechanism spec
item 18 is actually about.
