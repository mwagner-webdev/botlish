# Preserving trusted opaque refinement across `-native-body` and specialization

Milestone 4 of the "push library semantics into ordinary Botlish" process
(milestone 1: `NATIVE-URI-ESCAPE.md`, `uriEscape`; milestone 2:
`NATIVE-EMAILISH.md`, validator-backed predicates; milestone 3:
`NATIVE-TCL-UNICODE.md`, `Emailish?`). This milestone's outcome is **A**:
`bench/refined-checks.ir`'s last blocker, `UriQueryValue?(q)` inside
`check`, is eliminated *statically*. The benchmark now compiles and runs to
completion on `cranelift`, with **no runtime evidence representation added**
and `UriQueryValue?` still genuinely unsupported dynamically.

## 1. Files changed

- `hir/hir.tcl` -- `hir::build`/`hir::buildSyntax` gain an optional
  `-native-result-overrides` (IR-path -> type form), applied by the new
  `hir::ApplyNativeResultOverrides` between resolution and type inference.
- `hir/types.tcl` -- `hir::types::Call`'s block-callee branch consults a
  call node's `nativeResultOverride` field, when present, in place of its
  callee block's own inferred result.
- `hir/specialize.tcl` -- two new procs, `RefinementFacts` (computed once,
  before the fixpoint, from the semantic HIR) and `RefineParams` (consulted
  in `Analyze`'s parameter-seeding step): together they widen a specialized
  instance's *parameter analysis* with a named refinement every exact call
  reaching that parameter proves, without changing the instance's *key*.
- `native/native.tcl` -- `ExpandNativeBodies`/`ExpandNativeBodiesIn` now
  track the IR path of every call they substitute a native body into
  (mirroring `hir::syntax::fromIR`'s own path assignment) and record, per
  path, the native's registered `-result-type`; `runProgram` passes this
  map to `hir::build` as `-native-result-overrides`.
- `tests/native-refinement-propagation.test` -- new: the positive,
  negative, mixed-caller, recursive-forwarding and transformation-
  invalidation cases below, plus the `refined-checks.ir` acceptance test
  and a specialization-explosion guard.
- `tests/native-validator-predicate.test` -- one pre-existing test updated:
  `native-validator-predicate-refined-checks-blocker` pinned the *old*
  failure (`NATIVE UNSUPPORTED {native UriQueryValue?}`); it now pins the
  new, correct outcome (`[400, 0]`), since this milestone is precisely what
  moves that blocker.

No change to `native/lower.tcl`, `core/type.tcl`, `core/native.tcl`,
`lib/web.tcl`, or any Rust source. No runtime evidence machinery (`Value`
evidence bits, side tables, `rt_has_evidence`/`rt_add_evidence`) exists
anywhere in this diff.

## 2. Reproducing the blocker

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
== refined-checks.ir (cranelift)
   error: ir {0 2 2 3 2 2 2 2 2 2 1}: e451: native lowering does not
   support native UriQueryValue?: the native "UriQueryValue?" has no
   native implementation (NATIVE UNSUPPORTED {native UriQueryValue?})
```

- **Failing expression:** `UriQueryValue?(q)` inside `check`'s body (the
  benchmark's own third, innermost `if`).
- **HIR node:** `e451`, `call native(UriQueryValue?)`, argument `e453 ref
  b6 q : any` -- the callee parameter, statically `any` before this
  milestone (not even `str`).
- **Callee parameter binding:** `b6`, `check`'s own fourth parameter `q`.
- **Caller argument expression:** the two external calls pass `ref b2 q`
  (the program-level binding `uriEscape("a b")` was bound to); the
  recursive call forwards `ref b6 q` (itself) unchanged.
- **Caller argument type:** `str[UriQueryValue]` in the *unexpanded*
  semantic HIR shown by `main.tcl -hir` (which never runs
  `ExpandNativeBodies` -- see \167 3) -- but, critically, `any` on the
  *actual* native pipeline HIR (`native::runProgram`'s own
  `ExpandNativeBodies` + `hir::build`), which is what native lowering
  really lowers.
- **Specialized callee parameter type (before this milestone):**
  `check<int, int, str, any>` -- `q : any`, one `UnknownParameterKind`
  guard (`UriQueryValue?` needs `str`; `q` has no static kind).

This is still `UriQueryValue?`, not a regression elsewhere: `Emailish?`'s
own two calls (`e11`, genuinely dynamic but native-body-backed since
milestone 3; `e15`, redundant, still folds via `known`) are unaffected.

## 3. Tracing `q` end-to-end (before this milestone)

| stage | type | named refinement | specialization key | known |
|---|---|---|---|---|
| `uriEscape`'s registration | `{refined str {UriQueryValue}}` | UriQueryValue | n/a | n/a |
| `e39` (unexpanded semantic HIR) | `str[UriQueryValue]` | UriQueryValue | n/a | -- |
| `e39` (native pipeline, post `ExpandNativeBodies`) | `any` (the substituted body block's own inferred result) | **none** | n/a | -- |
| `bind q` (native pipeline) | `any` | **none** | n/a | -- |
| `check(...)` call argument | `any` | **none** | contributes `any` to the key | -- |
| `check`'s own parameter `q` | `any` | **none** | `check<int,int,str,any>` | -- |
| `UriQueryValue?(q)` | `bool` | n/a | n/a | **unknown (dynamic)** |

Two independent losses, exactly as the milestone's own framing predicted:

1. **`ExpandNativeBodies`** (`native/native.tcl`) rewrites `(call (ref
   uriEscape) ARG)` to `(call (block PARAMS BODY...) ARG)` *before*
   `hir::build` runs. The rewritten call's callee is now an ordinary block
   literal; `hir::types::Call`'s block branch types the call from
   `blockResult` -- the body's *own* inferred result, computed by ordinary
   ascending-fixed-point inference over `esc_from`'s self-tail recursion,
   which (confirmed directly, not assumed) settles at `any`, not even
   `str`. The native's own registered `-result-type {refined str
   {UriQueryValue}}` (`lib/web.tcl`) is never consulted for this call again.
2. **`hir::specialize::KeyType`** (`hir/specialize.tcl:239-250`) reduces
   every type to its base *kind*, unconditionally, for specialization-key
   purposes: `kindOf {refined str {UriQueryValue}}` is `str`, same as plain
   `str`. Even a hypothetically-fixed loss (1) alone would only fix the
   *caller's* fact (`q`'s own binding type); the key `check<...>` chooses,
   and the parameter type seeded for that instance's *own* region
   re-inference, would still be the bare kind -- `hir/specialize.tcl`'s own
   comment already says this is deliberate ("kinds, evidence (named types)
   dropped").

## 4. Compile-time fact vs. runtime evidence

These are kept strictly separate throughout this milestone, per its own
\167 3:

- **Compile-time fact:** "the compiler knows `q`'s value has refinement
  `UriQueryValue`" -- a HIR-level, static property of an expression or
  binding, used only to fold `UriQueryValue?(q)` before native lowering
  ever needs to execute it.
- **Runtime evidence:** "the `Value` `q` is bound to physically carries a
  tag/side-table entry `UriQueryValue?` can inspect at run time" -- this
  does not exist on the native backend, before or after this milestone,
  and nothing here adds it. `interp`/`compile` keep their own,
  Tcl-level runtime evidence (`core::value::hasEvidence`) exactly as
  before (\167 9 below).

Both fixes below are the first kind only. `UriQueryValue?` remains, on the
native backend, exactly as unsupported *dynamically* as it always was
(\167 8, \167 11).

## 5. Fix 1: the native's declared result type survives `-native-body`

`hir/hir.tcl` gains `hir::ApplyNativeResultOverrides`, run once, between
`hir::hygiene::apply` and `hir::types::infer`, inside `hir::buildSyntax`:
given an IR-path -> type-form map, it sets a new, optional
`nativeResultOverride` field on the call expression at each path.
`hir::types::Call`'s block-callee branch, after computing `blockResult`
*and* after invoking the specialize handler (so instance discovery/edges
for the substituted body are unaffected -- codegen still needs to find and
compile that body), overrides the call's `result` with this field when
present:

```tcl
if {!$dead && [dict exists $node nativeResultOverride]} {
    set result [dict get $node nativeResultOverride]
}
```

`native/native.tcl`'s `ExpandNativeBodiesIn` now threads an IR-path
parameter through its recursion, index-for-index identical to
`hir::syntax::fromIR`'s own path assignment (a call node's own path is
unchanged by substituting its callee sub-node, so the path computed *before*
substitution is exactly where the resulting HIR call expression's `origin`
will be). Whenever it finds a native with a `-native-body`, it records
`PATH -> [core::native::metadata NAME].resultType` in a namespace variable;
`runProgram` passes the accumulated map to `hir::build`.

**Why this cannot be forged.** The override's value is read solely from
`core::native::metadata` -- the same trusted registry an *ordinary*
`call native(NAME)` node already gets its type from -- keyed by a path
`ExpandNativeBodies` itself computed, from its own trusted substitution
decision (nothing about which paths get an override, or what type they
get, depends on program-controlled data). `hir::build`'s new option
defaults to empty and is passed only by `native::runProgram`; interp and
compile never call `hir::build` with it. A hand-written `.ir`/`.hir`
program cannot mint this field directly either: `core/ir.tcl`'s `check`
validates the *original* program against a closed op grammar *before*
`ExpandNativeBodies`/`hir::build` ever see it, and the field is never part
of that grammar -- it is a HIR-internal dict key, not a core-IR
construct.

**Result** (`tests/native-refinement-propagation.test`,
`native-refinement-propagation-native-body-preserves-result-type`):

```tcl
{bind q {call {ref uriEscape} {const str {a b}}}}
{ref q}
```

`hirRefTypes` of `q` on the real native pipeline HIR is now
`str[UriQueryValue]` (was `any`; the paired control test,
`...-without-override-loses-it`, pins that omitting the override
reproduces the old, wrong `any`).

## 6. Fix 2: named refinement reaches the specialized parameter, not the key

`hir/specialize.tcl` gains `RefinementFacts` (computed once, from the
*semantic* HIR, before `Fixpoint` runs -- so it has no dependency on
specialization's own discovery order) and `RefineParams` (called from
`Analyze`'s existing parameter-seeding loop).

`RefinementFacts` builds a reverse index of every call whose HIR `target`
is `{block B}` (this is already resolved on the semantic pass,
independently of specialization), grouped by `B`. For each of `B`'s
parameters, it intersects, across every such call:

- a call that forwards the parameter to itself unchanged (`ref` to the
  very same `BindingId`) contributes **no constraint** -- by structural
  induction, whatever is eventually proved for the parameter is trivially
  still true when the same value is passed to itself again; no fixpoint is
  needed (unlike `hir/range.tcl`'s numeric ranges, which genuinely widen
  across recursive calls and do need one -- see the header comment for why
  the two lattices differ);
- any other call's argument contributes `core::type::evidenceOf` of that
  argument's own *semantic* type (already computed by the first, generic
  type-inference pass -- including, after Fix 1, a trusted native's
  declared result).

A parameter with at least one real (non-self-forwarding) caller, all of
whose callers agree on a non-empty evidence set, gets that fact.
`RefineParams` then widens *only the seed types fed to that instance's own
region re-inference* -- never the instance's key (`KeyType` is untouched,
so `check`'s specialization key is still, and remains, `str` for `q`, not
`str[UriQueryValue]`; sharing across callers that do and do not prove the
fact stays sound only because a caller that does not prove it collapses
the intersection to empty, attaching no fact at all -- \167 8).

## 7. `refined-checks.ir` after both fixes

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
== refined-checks.ir (cranelift)
   value: [400, 0]
```

| stage | type (native pipeline) | named refinement | specialization key | known |
|---|---|---|---|---|
| `uriEscape`'s registration | `{refined str {UriQueryValue}}` | UriQueryValue | n/a | n/a |
| `e39`/substituted call | `str[UriQueryValue]` (Fix 1) | UriQueryValue | n/a | -- |
| `bind q` | `str[UriQueryValue]` | UriQueryValue | n/a | -- |
| `check(...)` call argument | `str[UriQueryValue]` | UriQueryValue | contributes `str` (kind only) to the key | -- |
| `check`'s specialized instance | `check<int, int, str, str>` (key unchanged) | -- | one instance, no explosion | -- |
| `check`'s own parameter `q` (seeded, Fix 2) | `str[UriQueryValue]` | UriQueryValue | -- | -- |
| `UriQueryValue?(q)` | `bool` | n/a | n/a | **`= true`** |

`check<int, int, str, str>: closed ... guards: 0` (was `guarded ...
guards: 1`, the `UnknownParameterKind` blocker). Exactly one specialized
instance of `check` is used (`generic 0 specializations 1`,
`native-refinement-propagation-refined-checks-no-explosion`) -- both
before and after this milestone; Fix 2 attaches a fact to an *existing*
shared instance, it never creates a new one.

## 8. The safety model for multiple callers

Named refinement propagation is scoped to *exact, statically resolved
closed calls* only (spec's own \167 16, \167 21): no dynamic dispatch, no
open trait calls, no general interprocedural result-type inference, no
value-equality-based inference (`x == q` never implies `x : UriQueryValue`
-- nothing in this diff does that). The lattice is a plain set
intersection: a fact is attached to a parameter only when *every*
non-self-forwarding caller proves it; any caller that does not collapses
the intersection to empty and no fact is attached at all -- there is no
"most callers agree" heuristic and no per-caller instance forking (spec's
own \167 18's second acceptable outcome, not the first: `inspect`'s single
shared instance simply drops the fact when it is not universal).

**Positive, single caller**
(`native-refinement-propagation-positive-single-caller`):

```tcl
{bind inspect {block {q} {call {ref UriQueryValue?} {ref q}}}}
{bind trusted {call {ref uriEscape} {const str {a b}}}}
{call {ref inspect} {ref trusted}}
```

`cranelift`: `value true` -- folded statically, no native implementation
of `UriQueryValue?` required.

**Mixed caller** (`native-refinement-propagation-mixed-caller-*`):

```tcl
{call {ref list}
    {call {ref inspect} {ref trusted}}
    {call {ref inspect} {const str plain}}}
```

`interp`/`compile` (real runtime evidence): `[true, false]` -- the two
calls are never conflated at the *value* level either. `cranelift`: still
`NATIVE UNSUPPORTED {native UriQueryValue?}` -- the shared instance's `q`
gets no fact (the "plain" caller's argument has no evidence in its
semantic type), so the call stays genuinely dynamic. This is the critical
safety property: an unsound implementation would have silently folded the
untrusted caller's check to `true` and produced a *wrong value*; the
actual, sound behavior is to correctly refuse to compile natively rather
than guess.

**Recursive, unchanged forwarding**
(`native-refinement-propagation-recursive-forwarding`, and
`refined-checks.ir`'s own `check` self-tail call): a trusted `q` forwarded
unchanged through self-tail recursion keeps its fact at every depth, with
no fixpoint needed to "rediscover" it (\167 6) -- verified with an isolated
5-iteration loop, `cranelift`: `value true`.

**Transformation invalidates the fact**
(`native-refinement-propagation-transformation-invalidates-*`):

```tcl
{bind q2 {call {ref concat} {ref trusted} {const str {}}}}
{call {ref inspect} {ref q2}}
```

`concat`'s own registered result type carries no evidence, so this stays
genuinely dynamic on `cranelift` (`NATIVE UNSUPPORTED`) -- correctly
*not* folded to either `true` or `false`. Checked at the value level too
(`interp`/`compile`): `concat` does not carry `UriQueryValue` evidence
forward dynamically either, so the static non-propagation here is not
over-conservative relative to actual semantics, it is simply correct.

**Unknown value, no trusted producer**
(`native-refinement-propagation-unknown-value-*`): `UriQueryValue?(plain
string)` stays `NATIVE UNSUPPORTED` on `cranelift`, and (checked
separately, on `interp`/`compile`) its real dynamic answer is `false` --
never a `false` this milestone's static analysis invented. Absence of
static proof is not treated as proof of absence, matching the opaque
type's own semantics (spec \167 25).

## 9. Preserved, unchanged

- **Opaque trust semantics:** `UriQueryValue` remains opaque, still has no
  validator (`core::type::register`'s own precondition makes "opaque with
  a validator" impossible to construct), and `UriQueryValue?` still has no
  `-native-body` and no native implementation of any kind
  (`native-validator-predicate-opaque-still-unsupported`,
  `native-validator-predicate-opaque-has-no-native-body`, both
  unmodified and still passing). No structural revalidation of
  `UriQueryValue?(s)` was added; no duplication of `uriEscape`'s escaping
  algorithm exists inside the predicate.
- **`uriEscape`'s executable algorithm:** unchanged -- still an ordinary
  compiled `-native-body` on the Cranelift path (`native-uri-escape.test`,
  18/18, unmodified and still passing); this milestone changes only the
  preservation of its *semantic result fact*, never its implementation
  strategy.
- **Validator-backed predicates:** `Emailish?`/`NonEmpty?` are untouched.
  `RefinementFacts`/`RefineParams` only ever widen a parameter's *named*
  refinement (`core::type::evidenceOf` on a core, `refined`-shaped type);
  `hir::types::IsSpecific` guards both new procs against `block`/`native`/
  `list` (HIR-specific, non-core) types, so a callable/aggregate parameter
  is never touched. `tests/native-tcl-unicode.test` (52/52) and
  `tests/native-validator-predicate.test` (12/12, with the one
  intentionally-updated pin from \167 1) pass unchanged.
- **interp/compile semantics:** `hir::build`'s new option defaults to
  empty; `ExpandNativeBodies`/the override map are constructed and
  consumed only inside `native::runProgram`. Neither backend's code path
  changed.

## 10. `-native-body`'s remaining, known limitations (unchanged, out of scope)

Per spec \167 7/28, this milestone deliberately did not move
`ExpandNativeBodies` later in the pipeline (candidate strategy A) or
broadly redesign it -- only the narrow, additive mechanism above. So:

- **Still purely syntactic, pre-resolution.** The shadowing hazard
  `NATIVE-URI-ESCAPE.md` \167 7 already documented (a local `bind` of a
  native's own name is not honored before substitution) is **unchanged**:
  this milestone's fix operates entirely downstream of substitution (on
  the already-built HIR), so it neither fixes nor worsens it. No
  regression test claiming otherwise was added (per spec \167 37, "do not
  force this fix if your implementation doesn't touch that layer" -- it
  doesn't).
- **Still one body per call site.** `uriEscape` is called once in
  `refined-checks.ir`, so this remains a non-issue here, unchanged.
- **Predicate known-result folding through a `-native-body` is still not
  restored.** `NATIVE-EMAILISH.md` \167 8's disclosed gap (a redundant,
  HIR-provably-true `Emailish?`/`NonEmpty?` re-check still executes for
  real, since a native-body-backed predicate's calls are ordinary block
  calls by the time HIR exists, not `{native NAME}`-typed calls
  `hir/refine.tcl`'s `known`-folding looks for) is **unaffected** by this
  milestone: `ExpandNativeBodies` still runs before `hir::build`, so
  `known`-folding for those predicates never sees them either way. This
  milestone's own fix works differently -- it never turns a native call
  into a `known`-folded constant; it keeps the call as a genuine (if
  proven-true) `{native NAME}` HIR node all the way to
  `native/lower.tcl`'s existing `known` short-circuit
  (`NativeCall`, line ~3005), which is what actually eliminates it. So
  `UriQueryValue?(q)` disappears via the *same* mechanism `Emailish?`'s
  redundant check already used before this milestone (\167 11 below); the
  `-native-body`-specific gap is orthogonal and untouched.
  `native-validator-predicate-known-result-nir-shape`'s pinned count (4)
  is unaffected -- confirmed unchanged.

## 11. Machine-code inspection

```
$ native::nir -- refined-checks.ir's full NIR text
grep -c UriQueryValue -> 0
grep -c Emailish     -> 0
```

No `UriQueryValue?` call, helper, or op of any kind exists anywhere in the
lowered NIR (or, downstream, the generated Cranelift/x86-64): the `if
UriQueryValue?(q) ... else ...` HIR node folds to the same "known
`true`" constant-control-flow path `native/lower.tcl`'s pre-existing
`known` short-circuit already gives a provably-redundant `Emailish?`
check (\167 3 of `NATIVE-EMAILISH.md`) -- the `else` branch (`const 0`) is
statically unreachable and contributes no code. `Emailish?`'s own
`-native-body` (its two calls, one genuinely dynamic and one
known-folded) is unaffected and still present, exercising its own helper
functions (`scan_local`, `domain_loop`, etc.) as before.

Representative statistics (`native::codeSize`/`native::allocationReport`/
`native::measure`, specialized build; `BOTLISH_NATIVE_GC_STRESS=1` also
survives a full run):

- Total machine code: 26317 bytes across 30 functions (per-function sizes
  range 270-1817 bytes; `check`'s own instance and `Emailish?`'s
  native-body helpers dominate, as expected -- neither is new to this
  milestone).
- Allocations (one representative run, `n = 400`): 20818 total (13609
  String, 7204 Block, 5 List; 0 BigInt/MutableArray/Result/Cell/Native),
  980061 bytes live at peak, 0 GC cycles at this size.
- One measured run: lower ~113ms, compile ~32ms (both one-time, JIT
  process startup), best-of-N wall time ~1.84ms, 4 collections, value
  `[400, 0]` -- not a rigorous statistical benchmark (this milestone's
  job was correctness/staticness, not performance), reported as a single
  representative data point per spec \167 47/49, not audited further (spec
  \167 49's "do not optimize yet").

## 12. Backend parity

```
interp             -> too many nested evaluations (TCL LIMIT STACK)
compile             -> value [400, 0]
cranelift-generic   -> NATIVE UNSUPPORTED {native UriQueryValue?}
cranelift            -> value [400, 0]
```

`compile` and `cranelift` agree exactly
(`native-refinement-propagation-refined-checks-parity`).
`interp` hits Tcl's own recursion-depth limit at `n = 400`'s ~400-deep
non-tail-call-optimized Tcl evaluation stack -- confirmed pre-existing,
unrelated to this milestone (`git stash`; identical failure on the
pre-milestone commit). `cranelift-generic` (`-specialize 0`, "the guarded
baseline") is unaffected by design: `RefinementFacts`/`RefineParams` are
only consulted from `Analyze`, which `SemanticInstances` (the
non-specializing path) never calls; propagating a caller-proven fact into
a parameter's analysis is inherently a specialization-adjacent mechanism,
and `cranelift-generic` explicitly opts out of specialization altogether.
This is reported, not fixed -- it was never part of this milestone's
acceptance target (spec \167 24's "no native implementation for
`UriQueryValue?` should be required" is about `cranelift`, the
specializing backend the benchmark targets).
`bench/check-unicode-parity.tcl`'s existing 19 cases still agree across
Tcl/interp/compile/cranelift-generic/cranelift/Python/Rust, unaffected
(this milestone touches no `Emailish?`/Unicode logic).

## 13. Regression coverage

- `tests/native-refinement-propagation.test` (new, 14 tests): Fix 1 in
  isolation (with a control proving the override, not something else,
  fixes it), the `refined-checks.ir` acceptance case, its no-explosion
  guard, positive/mixed/recursive/transformation/unknown-value cases (\167
  8), and an `Emailish?` non-regression pin.
- `tests/native-validator-predicate.test` (12/12, one pin intentionally
  updated per \167 1).
- `tests/native-uri-escape.test` (18/18), `tests/native-tcl-unicode.test`
  (52/52), `tests/refined.test` (32/32), `tests/hir-types.test` (20/20),
  `tests/types.test` (16/16), `tests/hir-specialize.test` (21/21),
  `tests/native.test` (88/88) -- all unmodified and passing.
- `tclsh9.0 tests/all.tcl` (full suite) and `cargo test --release
  --manifest-path native/Cargo.toml` (35/35 Rust unit tests) -- both run
  clean; see \167 14.

## 14. Final answers

1. **Was `UriQueryValue?(q)` dynamic because runtime evidence was
   genuinely required, or because static information was discarded?**
   Discarded, entirely. `q`'s producer (`uriEscape`) declares
   `str[UriQueryValue]`; every caller of `check` passed the same,
   unchanged `q`. No runtime evidence representation was ever needed for
   *this specific program* -- \167 7/8 prove it statically.
2. **Where was the first information loss?** `native/native.tcl`'s
   `ExpandNativeBodies`, pre-`hir::build`: substituting a native's body
   for its call's callee discarded the native's own declared result type,
   letting ordinary block-result inference (which settled at `any` for
   `uriEscape`'s recursive helper) take over instead.
3. **Does `-native-body` now preserve the registered native's declared
   result type?** Yes, unconditionally, via `hir::ApplyNativeResultOverrides`
   (\167 5) -- verified directly, not inferred from the benchmark passing.
4. **Does `q` at the caller now have type `str[UriQueryValue]`?** Yes, both
   at the program-level `bind` and at every call-site argument reference,
   on the actual native pipeline HIR (not just the previously-correct,
   but practically irrelevant, unexpanded semantic HIR).
5. **Does that refinement reach `check`'s `q` parameter?** Yes, via
   `hir::specialize::RefinementFacts`/`RefineParams` (\167 6) -- attached to
   the parameter's *analysis*, not to the instance's *key*.
6. **How is propagation kept sound when call sites disagree?** A plain set
   intersection across every non-self-forwarding exact call reaching a
   parameter; any disagreeing caller drops the fact to empty for the
   *whole* shared instance (\167 8) -- verified by a mixed-caller test that
   the untrusted branch is never wrongly folded to `true`.
7. **Does specialization need separate machine instances for refined vs.
   unrefined callers?** No -- the fact is propagated independently of
   specialization identity, exactly as spec \167 14 asked: `check` keeps
   its single `check<int, int, str, str>` instance, unchanged, before and
   after (\167 7).
8. **Does self-tail recursion preserve the opaque fact?** Yes, with no
   fixpoint needed -- an unchanged self-forward is structurally
   guaranteed to preserve whatever the non-recursive callers establish
   (\167 6, \167 8).
9. **Does transforming `q` correctly invalidate the opaque fact?** Yes,
   both statically (the transformed value's own semantic type carries no
   evidence, so the intersection is empty) and, checked separately,
   dynamically (`concat` does not propagate evidence at the value level
   either) -- \167 8.
10. **Is `UriQueryValue?(q)` now HIR-known true inside `refined-checks`?**
    Yes -- `check<int,int,str,str>`'s own guard count for this call drops
    from 1 (`UnknownParameterKind`) to 0, and the call folds through
    `native/lower.tcl`'s existing `known` short-circuit before any
    native-implementation check ever runs (\167 7, \167 11).
11. **Is there any runtime `UriQueryValue?` call in the final NIR/x86-64?**
    No -- confirmed directly by grepping the lowered NIR text, not
    inferred from the program compiling (\167 11).
12. **Does a genuinely dynamic `UriQueryValue?` remain unsupported?** Yes
    -- `native-validator-predicate-opaque-still-unsupported` (unmodified)
    and this milestone's own unknown-value/mixed-caller tests all still
    hit `NATIVE UNSUPPORTED {native UriQueryValue?}` (\167 8, \167 9).
13. **Was any runtime evidence representation added?** No -- no `Value`
    evidence bits, side tables, hash sets, `rt_has_evidence` or
    `rt_add_evidence` exist anywhere in this diff (\167 4, \167 9).
14. **Did the change also improve any known `-native-body` limitations
    such as predicate-folding or shadowing?** No, deliberately not (spec
    \167 7/28/37): the shadowing hazard and the predicate-native-body
    known-folding gap are both unchanged, because this milestone's fix
    operates entirely downstream of `ExpandNativeBodies`'s existing,
    unmoved substitution point (\167 10).
15. **Does `refined-checks` now compile and run natively?** Yes --
    `value [400, 0]`, matching `compile` exactly (\167 7, \167 12).
16. **What does its first complete native machine-code audit reveal?** No
    `UriQueryValue?` code of any kind; 26317 total machine-code bytes
    across 30 functions; ~20.8k allocations (mostly String/Block) for
    `n = 400`; ~1.84ms best-of-N wall time for one representative run
    (\167 11) -- not yet optimized (out of this milestone's scope; F3b
    shadow-slot zeroout cleanup remains the next planned step).
17. **N/A** -- outcome A (the benchmark now runs), so no exact remaining
    call requiring runtime evidence needed to be isolated.
