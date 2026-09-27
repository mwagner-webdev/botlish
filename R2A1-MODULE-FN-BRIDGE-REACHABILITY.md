# R2.a.1: module-function bridge reachability correctness

## Outcome

**Correctness goal: achieved. Allocation goal: partly achieved; the rest is
reported below, not forced.**

- A `-module-fn`-bridged Botlish function whose body references other
  module bindings now compiles and runs from any caller: program root,
  top-level function, nested capturing or non-capturing function, branch,
  returned closure. This holds on `cranelift` and `cranelift-generic`,
  and `interp`/`compile` are unchanged.
- The fix is general to `-module-fn`. Nothing in it names `emailish?`,
  `ImmutableSet`, a predicate, or a benchmark. It fixes `uriEscape` too:
  R2's "uriEscape + result-typed branch" bug has **the same root cause**,
  and a pinned reproducer now passes.
- `local_extra_chars` is back at true module scope. Its List and
  ImmutableSet are each built once, at module initialization. The R2.a
  per-call workaround is deleted.
- On `refined-checks`, total allocations go from 11,620 to **10,023**, and
  allocated bytes from 523,464 to **421,240**. All 1,600 per-call
  List/ImmutableSet allocations are gone.
- The spec expected the total to fall to roughly R2's 20. It does not, for
  two measured reasons that the spec's premise did not account for:
  1. **800 `is_local_char` closures per run remain.** `is_local_char` is
     nested in `is_emailish` and now captures the *module* binding
     `web::local_extra_chars`. In this compiler a module value is reached
     by capture, so this is still a closure (see "`is_local_char`
     representation").
  2. **9,200 of R2.a's 11,600 extra allocations were never the
     workaround.** They are `char_at` substrings materialized by R2.a's
     predicate passing: `scan_while(i, predicate)` passes `char_at(i)` to a
     `callvalue`. They are identical with and without the workaround, and
     spec item 27 forbids touching them. R2.a's own report called them
     "pre-existing"; that was inaccurate, because R2 had 4 Strings in total.
- **One structural consequence, reported and not "fixed":** `check` in
  `refined-checks` becomes `check<generic>`, where it was
  `check<int, int, str, str>`, and loses M9's `n ∈ [0, 400]` entry fact.
  - Cause: `check` must now reach `web::is_emailish`'s closure. It does so
    by capturing it, exactly as an ordinary `web::is_emailish(s)` call
    would. `hir::specialize` keys every closure with a non-Int capture
    generically.
  - This is shown to be identical for ordinary qualified module calls. It
    is not caused by the bridge.
  - The benchmark still gets faster: best-of-30 runtime goes from 938 µs
    to 782 µs.

R2.a remains **unfrozen**. See "R2.a source status".

## Fresh failure reproduction

This is from the R2.a tree (`63b2199`) with only `local_extra_chars` moved
back to module scope, before any production change:

```
Emailish? root         cranelift-generic/cranelift: value true
Emailish? user-block   cranelift-generic/cranelift:
    {NATIVE BUG} native lowering: binding b45 is not reachable from e501
emailish? user-block   (identical)
bench/refined-checks.ir: native lowering: binding b45 is not reachable from e501
```

The IDs, identified freshly rather than remembered:

- `b45` is `web::is_emailish` (kind `local`, scope `s45` = web's module
  section).
- `e501` is the block bound to `check` (captures: none, pre-fix).

The same failure with the unmodified R2.a source, via `uriEscape` in a user
block: `binding b48 is not reachable from e501` (`b48` =
`web::uri_escape_text`). On the pre-R2 tree (`0c2dead`) it is `binding b47
is not reachable from e322`, so it predates R2.

## Minimal reproducer

This reproducer is independent of `lib/web.bot`. It uses a scratch module
and a test-only native (`tests/module-fn-bridge-reachability.test`):

```
namespace bridgefix
offset = 10
fn one_dep(v):
    v + offset

core::native::register probe_one ... -module-fn {bridgefix one_dep}

{bind check {block {s} {call {ref probe_one} {ref s}}}}
{call {ref check} {const int 2}}
```

The four pre-fix cells were each run fresh:

| | program-root call | call through user block |
|---|---|---|
| module dependency present (`v + offset`) | passes | **FAILS** (`binding b2 is not reachable from e10`) |
| dependency made local (`off = 10; v + off`) | passes | passes |

After the fix, all four pass on all four backends. They are pinned as
`module-fn-bridge-probe_one-*`, `module-fn-bridge-probe_local-*` and
`module-fn-bridge-minimal-reproducer`.

## Current module-fn architecture

These are the answers to the §4 questions.

- **How `-module-fn` discovers the implementation.**
  - `native::ExpandNativeBodiesIn` walks the program's raw IR.
  - For each `(call (ref NAME) ...)` whose canonical native carries a
    `moduleFn`, it records the call path in `moduleNativeCalls`.
  - `native::ModuleNativeBridge` loads those namespaces with
    `surface::modules::LoadNamespaces`. It passes their sections as
    `-modules`, plus `NATIVE NAMESPACE NAME` triples as
    `-module-native-targets`, to `hir::buildSyntax`.
- **How the implementation becomes callable.**
  - `hir::ResolveModuleNativeTargets` resolves each target to its module
    function's block expression (`moduleNativeTargets`).
  - `hir::types::BindingType` then types every reference to that native's
    root binding as `{block M arity any}`. The call target becomes the
    module Block.
  - `hir::types::BridgedNative` still recovers the native's identity, for
    refinement and known-folding.
- **How references inside the module function resolve.**
  - Ordinary resolution applies. A module section is a `program`-kind scope,
    a sibling of the program's top scope.
  - A reference in `M`'s body to another module binding `D` is an ordinary
    reference to a binding outside `M`'s block, so `M` captures `D`
    (`hir::resolve::ResolveRef` → `Capture`).
  - `M` therefore is a closure, not an environment-free function. Its
    closure is created once, at module initialization, into `M`'s own
    module binding.
- **How reachability is checked.**
  - `native::lower::Access fn b`:
    1. If the current function holds `b` as a local, it uses that.
    2. Otherwise, if `b` is bound to an environment-free block, it uses the
       static `fnvalue`.
    3. Otherwise it loads `b` from the current region's capture list.
  - If none of these applies: `binding b is not reachable from REGION`.
  - The capture lists come from HIR `captures`, which resolution decides.

## ModuleBridgeBinding semantics

`native::lower::ModuleBridgeBinding calleeExpr targetKind`, as it was
before R2.a.1:

| property | before R2.a.1 |
|---|---|
| input | a callee `ref` whose binding is a **root** binding holding a native value, with call target kind `block` |
| target module function | looked up again at lowering time: registry `moduleFn` → `hir modules` → module scope `names` → `NAMESPACE::NAME` |
| synthetic/bridge binding created | none; it returns the module function's existing `local` BindingId (`M`) |
| BindingId ownership | `M` is owned by the module section scope |
| SymbolId ownership | the ref keeps the native's root SymbolId (predicate identity); `M` has none |
| region/scope attached | none; the caller's region was never told about `M` |
| participates in captures | **no**: the ref's binding is `root`, and root references never capture (`ResolveRef`) |
| AOT materialization | `M`'s closure is materialized at module init (program region); no caller materializes anything for it |
| native lookup | `Call`: if `M` is environment-free, `skipCallee` (static target); else `Access fn M` → **fails from any non-program region** |
| HIR typing | the ref is typed `{block M arity any}` (`BindingType`) |
| specialization | the call targets `M`'s block like any direct block call (instances keyed by argument facts) |

**What R2.a.1 changes (one property):**

- The bridged reference's reachability provenance is now recorded in HIR at
  the point where the bridge is established. The ref carries
  `bridge = M`, and every enclosing block captures `M`, exactly as a
  qualified `NAMESPACE::NAME` reference already does.
- `ModuleBridgeBinding` now simply reads the recorded `bridge` field. The
  duplicated registry/module/scope lookup is removed.
- Unchanged: the ref's own root binding and SymbolId, its type, and its
  call target.

## Reachability architecture

`Access`'s query is **runtime availability for this lowered region**: is
the value in a local, a static `fnvalue`, or the region's environment? It
answers from capture lists, which record **lexical free-variable
reachability** computed by resolution.

For every ordinary reference the two agree by construction: a reference
that denotes binding `b` causes its enclosing blocks to capture `b`. The
bridge broke that agreement.

- By type, a bridged ref denotes `M`'s Block, whose value lives in `M`'s
  binding.
- By capture, it denotes the root native, which needs nothing.

The two concepts are not separated globally; that is not needed. The fix
restores their agreement at the only producer of the mismatch, the bridge
bookkeeping. Root bindings stay non-captured. No reachability rule is
weakened.

## Exact first loss

The earliest incorrect representation decision is
**`hir::ResolveModuleNativeTargets`** (`hir/hir.tcl`). It redirected what a
root-native reference *denotes* (its type becomes `M`'s Block) without
redirecting what the reference *needs* from its enclosing regions.

- The HIR state claims both "this reference evaluates to `M`'s closure"
  and "this reference captures nothing".
- Everything downstream trusts the captures: `hir::aot::StaticBlocks`,
  `envless`, blockescape, `CaptureList`, and `Access`.
- So native lowering was the first place to notice the inconsistency. It
  was not the place that introduced it.

These are the answers to the §60 questions.

1. **What is `ModuleBridgeBinding`?** It is native lowering's helper that
   maps a bridged native callee to the module function's own BindingId, so
   that `Call` can fetch that function's closure.
2. **Why does it exist?** A bridged call's target is a module Block. When
   that Block has captures, the root native value is not its closure: the
   closure lives in the module binding.
3. **Owner before R2.a.1:** the module section scope, correctly. But no
   caller region had any access path to it, so it was effectively owned
   only by the program region, where module bindings are locals.
4. **Owner it should have:** still the module section scope. Callers must
   *reach* it the way they reach any module binding: through capture of
   `M` itself, never of `M`'s dependencies.
5. **How native lowering decides reachability:** `Access`, as described
   above: local → static `fnvalue` → the region's capture list →
   `NATIVE BUG`.
6. **Why a nested caller changes the answer.** At program root, `M` is a
   local of the program function. Inside any block, the only path is the
   block's capture list, which never contained `M`.
7. **Why a second module dependency exposes it.**
   - With no module dependency, `M` is environment-free (`StaticBlocks`),
     and `Access` returns a static `fnvalue` from anywhere. Before that,
     `Call`'s `bridgeEnvless` skips the callee entirely.
   - One captured module value makes `M` a closure, which is reachable only
     by capture.
   - Note on "second": R2.a's `is_emailish` referenced one *extra* module
     binding. Any single non-function module value, or any module function
     that is itself a closure, triggers it.
8. **Missing information:** the caller blocks' `captures` lacked `M`. More
   exactly, the bridged ref had no recorded binding for the value it
   denotes.
9. **Layer:** module-bridge bookkeeping in HIR (`ResolveModuleNativeTargets`)
   is the root cause. AOT/`envless`, specialization and native lowering were
   correct consumers of incomplete provenance.
10. **Earliest correct fix:** record the bridge provenance where the bridge
    is established. That is the new `hir::BridgeProvenance`, called from
    `ResolveModuleNativeTargets`, which runs after resolution and hygiene
    and before type inference and every later analysis.

## Correct invariant

A module function executes in the environment where it was defined. For
`caller C → bridged M → module dependency D`:

- `D` is reachable from `M` through `M`'s own closure. It was captured when
  `M`'s body was resolved, in `M`'s module section.
- `C` needs to reach `M`, the value its call denotes, exactly as an ordinary
  `NS::M(...)` call from `C` would. It never needs `D`.

## Chosen fix

`hir/hir.tcl`, `hir::BridgeProvenance` (called by
`ResolveModuleNativeTargets`). For every `ref` whose binding is a bridged
native's root binding (an alias spelling shares it):

1. Set `bridge = M` on the ref.
2. Walk the ref's scope chain. Each enclosing `block` scope whose body does
   not contain `M`'s scope captures `M`. This is exactly
   `hir::resolve::Capture`'s rule; for a module-section binding, every
   enclosing block is affected.

`native/lower.tcl`'s `ModuleBridgeBinding` now reads `bridge` instead of
re-deriving `M` from registry metadata.

**Diff footprint:**

- Production: `hir/hir.tcl` +55 lines; `native/lower.tcl` −14 lines net;
  `lib/web.bot` (source restoration).
- **No** runtime, Rust, parser or lexer changes.
- **No** changes to `hir/range.tcl`, `hir/blockescape.tcl`,
  `hir/stringregion.tcl`, `hir/traversal.tcl`, `hir/specialize.tcl`,
  `hir/callables.tcl`, or callvalue lowering.

Things this fix does **not** do:

- It does not make root bindings reachable everywhere.
- It does not capture `D` in callers or add synthetic dependency copies.
- It does not clone `M` per caller, add a dynamic fallback, or add
  `-native-body` / `ExpandNativeBodies` substitution.
- Callers of an environment-free `M` are unaffected. `CaptureList` already
  drops a capture of a static block (`fnvalue`), and `StaticBlocks` still
  counts the caller static. On `refined-checks` with R2.a's *old* source,
  the fix produces **byte-identical** NIR, `spec.txt` and `summary.txt`.

**About the trailing parameter.** The caller-side capture of `M` is later
flattened into a trailing parameter by the existing blockescape
de-closure pass (`check`'s `pnames="n acc s q web::is_emailish"`). That is
not a bridge-specific synthesized argument. It is blockescape's general
treatment of any captured binding of a directly-called closure, and an
ordinary qualified call produces exactly the same shape
(`pnames="s bridgefix::two_deps"`).

## Why caller lexical scope must not own module dependencies

- If `C` captured `D`, `M`'s legal dependencies would depend on where it is
  called from.
- Each caller would carry copies of `M`'s environment.
- Transitive chains would have to be re-walked per caller.
- Worst, `D` would become lexically visible to `C`.

The pinned negative control shows that `D` stays invisible: `offset`
referenced unqualified inside a caller of `probe_one` is still
`{CORE SEMANTIC UNBOUND}` on every backend.

The transitive test pins that each dependency stays with its own definer:

- the caller captures only `{bridgefix::transitive}`;
- `transitive` captures `{bridgefix::is_marked}`;
- `is_marked` captures `{bridgefix::marks}`.

## Before/after HIR/bridge representation

The fixture is `check(s) = if Emailish?(s) ...`, with the module-scope set:

| | before (pre-fix) | after |
|---|---|---|
| `check` (`e501`) captures | `{}` | `{web::is_emailish}` |
| `web::is_emailish` captures | `{web::local_extra_chars}` | `{web::local_extra_chars}` (unchanged) |
| callee ref binding | root `emailish?` | root `emailish?` (unchanged) |
| callee ref `bridge` | — | `b45` (`web::is_emailish`) |
| callee ref type | `{block e167 1 any}` | unchanged |

For interp/compile (plain `hir::build`, no bridge), the HIR is unchanged:
no capture and no `bridge` field (pinned).

## Emailish module-set restoration

`lib/web.bot` now holds the set at module scope:

```
local_extra_chars = immutable_set_from_list([".", "_", "%", "+", "-"])

fn is_emailish(v):
    n = length(v)
    ...
    fn is_local_char(c):
        is_tcl_alnum(c) or immutable_set_contains(local_extra_chars, c)
```

The per-call `local_extra_chars = ...` inside `is_emailish` is deleted, and
no fallback remains. The comment explaining the workaround is replaced.
Unchanged, as items 21–24 require: the `is_emailish` name, the recursive
`domain_loop`, `scan_while(i, predicate)`, and the set-membership idiom.

NIR excerpt for `refined-checks`, cranelift. Before (R2.a):

```
func 9 "web::is_emailish" params=1 env=0 ... instance="str"
    %1 = op strlen %0
    %2 = str "." ... %6 = str "-"
    %7 = op listnew %2 %3 %4 %5 %6
    %8 = op setfromlisttotal %7
    %9 = closure 12 %8                 ; is_local_char, env = the fresh set
```

After (R2.a.1):

```
func 0 "<program>" ...                 ; module init, once
    %5 = op listnew %0 %1 %2 %3 %4
    %6 = op setfromlisttotal %5
    %7 = closure 9 %6                  ; web::is_emailish's own closure
func 9 "web::is_emailish" params=1 env=1 ... instance="generic"
    guard str %0 "length"
    %1 = op strlen %0
    %2 = capture 0                     ; the retained set
    %3 = closure 12 %2                 ; is_local_char, env = the retained set
```

## `is_local_char` representation before/after

It is **still a closure** (`env=1`), for one exact reason: it captures
`web::local_extra_chars`.

- In the native backend a module *value* binding is a local of the program
  function. A function nested in `is_emailish` reaches it only by capture.
- `hir::aot::StaticBlocks` counts a block environment-free only if every
  capture is bound to an environment-free block. A captured ImmutableSet
  disqualifies it.
- Because `is_local_char` is created per `is_emailish` invocation, it
  allocates one closure per call: 800 per run. Its content is now the
  shared retained set, not a fresh one.

It did not become an envless `fnvalue`, and it was not hoisted to a module
function. The spec's item-37 expectation assumed module values were static.
They are not. Removing these 800 allocations would need one of three
things, all outside R2.a.1:

1. Static module-value storage: a runtime/NIR change, excluded by item 28.
2. An optimizer rule that hoists closures whose captures are all
   once-bound module bindings: excluded by item 36.
3. The source hoisting `is_local_char` to module scope: excluded by
   item 44.

## Allocation census

`native::allocationReport` on `bench/refined-checks.ir`, cranelift, one run
(800 real `is_emailish` calls). All three states were measured fresh, from
worktrees at `e7d53b6` (R2) and `63b2199` (R2.a):

| | R2 | R2.a | **R2.a.1** |
|---|---|---|---|
| total allocations | 20 | 11620 | **10023** |
| allocated bytes | 1064 | 523464 | **421240** |
| String | 4 | 9204 | 9204 |
| List | 11 | 811 | **12** |
| ImmutableSet | 1 | 801 | **2** |
| Block | 2 | 802 | **803** |
| StringPlan | 2 | 2 | 2 |
| static (module/startup) objects / bytes | 28 / 1195 | 31 / 1299 | 31 / 1299 |
| GC cycles | 0 | 0 | 0 |
| list elements copied | 35 | 8035 | 45 |

Site-level (`probe.tcl` `summary.txt`) in the R2.a.1 `lib/web.bot` line
numbers:

| site | R2.a | R2.a.1 | meaning |
|---|---|---|---|
| `local_extra_chars` `listnew` | x800 (web.bot:100) | **x1** (web.bot:87) | module init |
| `local_extra_chars` `setfromlisttotal` | x800 (web.bot:100) | **x1** (web.bot:87) | module init |
| `is_emailish` `closure` | — | x1 (web.bot:89) | module init (it now captures the set) |
| `is_local_char` `closure` | x800 (web.bot:105) | x800 (web.bot:96) | per `is_emailish` call; env = retained set |
| `char_at` `substr` | x9200 | x9200 | per scanned char; predicate passing (item 27) |
| other startup (hex_digits, byte::set, uri closures, program list) | unchanged | unchanged | |

These are the answers to the §63 questions.

22. Total allocations: 11,620 → 10,023. R2 was 20.
23. Allocated bytes: 523,464 → 421,240.
24. local-extra List constructions: 800 → **1**, at module init.
25. ImmutableSet constructions: 800 + 1 → **1 + 1**, at module init. The
    other set is `additional_unreserved_chars`.
26. `is_local_char` closure allocations: 800 → 800. No per-call closure
    exists *to carry a per-call set* any more, but the closure itself
    remains, because it captures the module binding (see above). Stop
    condition 9 ("where naturally implied") is therefore **not** met by
    implication. It is reported, not forced.
27. Remaining hot allocations: 9,200 `char_at` substrings and 800
    `is_local_char` closures.
28. New GC cycles: none (0 → 0).

Startup vs. hot, for the §40 accounting:

- Static objects: 31 (1,299 bytes), unchanged.
- Runtime allocations: 23 startup/one-time, plus 10,000 hot
  (9,200 String + 800 Block).
- The one persistent set per module set is as expected: 2 ImmutableSets
  total.

## Instance/call graph census

`hir::specialize::analyze` / `hir::range::OpenInstances` /
`hir::blockescape::analyze` on `refined-checks`, fresh:

| | R2.a | R2.a.1 |
|---|---|---|
| used instances | 26 | 26 |
| compiled functions | 25 | 25 |
| `web::is_emailish` | `<str>`, envless, closed | `<generic>` (captures an ImmutableSet), open |
| `is_local_char` | `<generic>`, captures `local_extra_chars` (local) | `<generic>`, captures `web::local_extra_chars` (module) |
| `scan_while`/`tld_ok`/`domain_loop`/`char_at` | one generic instance each, blockescape-virtualized, flat `{n v}`/`{v}` | identical |
| `check` | `<int, int, str, str>`, envless, closed | `<generic>`, open, blockescape-virtualized, flat `{web::is_emailish}` |
| program `materializedBlocks` | `is_unreserved`, `uri_escape_text` | + `web::is_emailish`, `check` |
| anonymous instances | 0 | 0 |

These are the answers to §35 and §64.

- **29. Used instances:** 26 → 26; no identity proliferation.
- **34. materializedBlocks:** program +2 (`web::is_emailish`, `check`).
  `check`'s Block is virtualized away by blockescape, so it adds no
  allocation. `is_emailish` materializes the same five helpers.
- **35. OpenInstances:** `web::is_emailish` and `check` become open, both
  because they are now generic and materialized. Every scanner's state is
  unchanged.
- **36. Scanner Range facts:** unchanged. `params.txt`/`callfacts.txt` for
  `scan_while`, `tld_ok`, `domain_loop` and `char_at` are identical modulo
  line numbers.
- **Changed facts:** only `check`'s own entry facts (`n: [0, 400] → [-∞,
  +∞]`, `acc: [0, +∞] → [-∞, +∞]`) and `is_emailish`'s view type of `v`
  (`str → any`, now guarded).

Why `check` became generic:

- `hir::specialize::Handle` keys a non-static closure with a non-Int
  capture generically ("bound code growth for value-capturing closures").
- `check` now captures a Block (`web::is_emailish`'s closure). That is
  required for it to reach the closure, and it is what an ordinary
  qualified call does.
- This is the same rule that already makes `web::uri_escape_text` and
  `web::is_unreserved` generic.
- Demonstrated directly: for `check(s) = bridgefix::two_deps(s)` written as
  an ordinary surface-module call, the unmodified R2.a tree yields
  `bridgefix::two_deps<generic>`, `bridgefix::two_deps<int>` and
  `check<generic>`. The bridged spelling on R2.a.1 yields the identical
  family. This is pinned as
  `module-fn-bridge-matches-qualified-call-instances`.

**Caller-shape independence (§13–15).** Across all six caller shapes:

- The bridged function's generic instance has one identical compiled
  header.
- An `<int>` instance additionally appears exactly when some call passes a
  statically Int argument (literals at root or in a branch, `s + k` in the
  returned closure). That is argument facts, not caller identity.
- Three unrelated block callers share one instance and one compiled
  function.
- The module function is never cloned per caller (pinned).

## Machine/NIR census

`probe.tcl` on `refined-checks`, cranelift, totals over all functions:

| | R2 | R2.a | R2.a.1 |
|---|---|---|---|
| machine bytes | 9868 | 9490 | 10027 |
| compiled functions | 24 | 25 | 25 |
| NIR lines | 757 | 659 | 662 |
| call | 22 | 23 | 22 |
| callenv | 2 | 2 | 3 |
| callmulti | 5 | 2 | 2 |
| callvalue | 0 | 1 | 1 |
| tail | 7 | 5 | 5 |
| guards | 1 | 4 | 5 |
| setfromlisttotal | 1 | 2 | 2 |
| setcontainstotal | 1 | 2 | 2 |
| closure | 2 | 3 | 4 |
| fnvalue | 0 | 1 | 1 |
| capture | 3 | 4 | 5 |

Where the +537 bytes went:

- `<program>` +416: module-set init and `is_emailish`'s closure.
- `check` +260: generic.
- `is_emailish` −128: no set construction.

Other deltas:

- `callenv` +1: `check` → `is_emailish` is now a closure call.
- `call` −1: the same call was a direct `call` before.
- `closure` +1: `is_emailish`'s module-init closure.
- `guard` +1: `is_emailish`'s generic `str` guard on `v`.

The static count of `setfromlisttotal` is unchanged (2). One site moved
from `is_emailish` into module init. Nothing here was optimized against.

## Alias/refinement controls

All pinned, on all four backends where applicable:

- **19.** `emailish?` and `Emailish?` both work through a user block, over
  the whole R2 corpus: `someone@example.com`, `café@例え.テスト`,
  `not-an-email`, `@example.com`, `"a b"@example.com`,
  `foo@bad_domain.com`, `foo@example.c`, `""`, `@`.
  - Results are the same as R2 (`module-fn-bridge-emailish-user-block-*`).
  - The existing `emailish-predicate-parity-*` root-level corpus also
    passes.
- **20.** Refinement still works. In the combined fixture (§34: user-block
  caller, module-retained set, first spelling `emailish?`, redundant second
  spelling `Emailish?`), `s` is `str[Emailish]` in the true branch.
- **21.** The redundant second call stays folded (`known 1`). NIR has
  exactly one real `callenv` to `web::is_emailish`
  (`module-fn-bridge-emailish-refinement-in-user-block`, plus the two
  updated `*-nir-shape` tests).
- Alias identity is unchanged: one Binding, one Symbol, one instance
  family.

## uriEscape bug comparison

- **37. Same root cause?** **Yes.**
  - `web::uri_escape_text` captures `web::hex_digits` and
    `web::is_unreserved`, so it is a closure.
  - Called through `uriEscape` from any user-defined block, it hit the
    identical `binding bNN is not reachable from eNN`. `bNN` was
    `uri_escape_text`'s binding, reproduced on R2.a and on pre-R2
    `0c2dead`.
  - The "result-typed `if`/`ok`/`error-value` branch" in R2's note was
    incidental. The same branch at program root always worked. Only the
    enclosing user block mattered.
- **38. Fixed by R2.a.1?** Yes. Both shapes are pinned:
  `module-fn-bridge-uriescape-user-block` and
  `module-fn-bridge-uriescape-result-branch`.
- **39.** Not applicable: they do not differ.
- **40. Remaining module-fn bugs:** see "Residual module-fn limitations".

## Focused tests

New file `tests/module-fn-bridge-reachability.test` (74 tests).

It contains the reachability matrix: 8 bridged functions × 6 caller shapes,
4-way parity each.

- **Bridged functions:**
  - no dependency (`plain`);
  - local dependency (`local_dep`);
  - one retained Int (`one_dep`);
  - two retained Ints (`two_deps`);
  - retained String (`string_dep`);
  - retained List (`list_dep`);
  - bridged fn → module helper → retained ImmutableSet (`transitive`);
  - an environment-free module-function dependency (`fn_dep`).
- **Caller shapes:**
  - root;
  - top-level function;
  - nested non-capturing function;
  - nested capturing function;
  - branch;
  - returned closure.
- **Root/native references:** `length` and `list_length` inside
  `string_dep` and `list_dep` are root-native references.

It also pins:

- the minimal reproducer;
- provenance: callers capture only `M`, dependencies stay in `M` including
  transitively, the ref keeps its root identity, and the interp HIR is
  unbridged;
- an envless target leaves its caller envless;
- three callers share one implementation;
- caller-shape identity independence;
- parity of captures and instance family with an ordinary qualified call;
- two negative controls: module dependency not visible to callers, and an
  ordinary out-of-scope local still gets an UNBOUND diagnostic;
- `uriEscape` from a user block, and R2's result-branch shape;
- the Emailish corpus through a user block, both spellings;
- refinement plus folding combined in a user block;
- module retention: list and set sites x1 each, and no `listnew` or
  `setfromlist` in `web::is_emailish`.

Updated tests. Each pinned R2.a's workaround structure, and each is
replaced with an assertion of the module-retained form, not loosened:

| test | change |
|---|---|
| `native-block-escape.test` `…refined-checks-1` | 11620/802/9204/811 → 10023/803/9204/12, plus ImmutableSet = 2; R2.a's workaround comment replaced |
| `emailish-predicate.test` `…redundant-check-nir-shape` | one real call is now `callenv` |
| `native-tcl-unicode.test` `…emailish-known-result-nir-shape` | same |
| `emailish-predicate.test` `…check-n-control` | now pins `check<generic>` and `[-∞, +∞]`, with the cause documented, as a disclosed loss |
| `native-refinement-propagation.test` `…no-explosion` | `check` is still exactly one instance, now generic; the "no fork" intent is unchanged |
| `surface-modules.test` `…uri-hex-digits-startup` | `op listnew` 3 → 4, for `local_extra_chars`' own module-init list |
| `web-unreserved.test` `…set-built-once` | two module sets, each built once (`{byte.bot 1} {web.bot 1}`) |

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl`: see the final section
for the exact counts. The first three canonical benchmarks were run fresh
on R2, R2.a and R2.a.1:

| bench | cranelift NIR / bytes | cranelift-generic NIR / bytes | value |
|---|---|---|---|
| fib | 36 / 292 | 37 / 431 | 17711 |
| loop-count | 56 / 287 | 59 / 630 | 3500 |
| sum-refined | 36 / 286 | 49 / 769 | 80200 |

The R2.a and R2.a.1 NIR text is **byte-identical** for these three
(specialized and generic). They are negative controls, and zero
allocations throughout.

`refined-checks`:

- cranelift value `[400, 0]`, unchanged.
- best-of-30: 938 µs (R2.a) → 782 µs (R2.a.1), with R2 at 217 µs, measured
  in the same session.
- cranelift-generic cannot compile it on any of the three trees.
  `UriQueryValue?` has no native implementation unless specialization folds
  it; this is pre-existing and unchanged.

## GC stress

`BOTLISH_NATIVE_GC_STRESS=1 LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0
tests/all.tcl`: see the final section for the exact counts.

Rust sources are **unchanged**. `native/src`, `Cargo.*` and the runtime are
not in the diff, so no Rust suite rerun is required. The release binary was
built from the unchanged tree.

## Residual module-fn limitations

1. **Bridged reference to a later definition, from inside a module.**
   - The shape: a module function `G` calls a bridged native whose target
     `M` is defined *after* `G`, in the same or a later-loaded section.
     For example `fn early(v): probe_late(v) + 1` before `fn late`.
   - It still fails with `NATIVE BUG: binding edgefix::late is not
     reachable from program`. Pre-fix it failed too, with
     `... not reachable from eN`.
   - Cause: `G`'s closure is created before `M` is bound. The ordinary
     remedy for such forward references (`hir::aot::unprovenReferences` →
     a `cell`) keys off a ref's own `binding`, and a bridged ref's binding
     is the root native.
   - Supporting it means extending the init proof and cells to `bridge`
     provenance, which is a larger change than this milestone. No shipped
     module does this. It fails loudly and never miscompiles.
2. **Callers of a closure-valued module function are keyed generic.**
   - Any block that calls a module function which is itself a closure
     (bridged or qualified) captures that closure, and so becomes a
     generic-keyed closure.
   - That weakens argument facts flowing through it. `refined-checks`'
     `check` loses M9's `n ∈ [0, 400]`.
   - This is a specialization-policy question, not a bridge bug: a capture
     of a once-bound module binding does not vary between creations. It is
     the obvious next finding. It was not changed here, per items 25/36.
3. **Nested functions that reference module values stay closures.**
   `is_local_char`'s 800 per-call closures come from this (see
   "`is_local_char` representation").
4. **Pre-existing, unrelated and unchanged:**
   - Native `uriEscape` results carry no `UriQueryValue` evidence (by
     design, documented in `native-uri-escape.test`).
   - `refined-checks` is unsupported on `cranelift-generic`.

R2.a.1 does **not** claim the bridge is universally correct. Limitation 1
is the one remaining known failure of `-module-fn` bridging.

## R2.a source status

**Not frozen.** R2.a.1 removed only the bridge workaround. The next steps
are:

- **R2.a.2:** ordinary trailing-`?` identifiers (`web::emailish?`).
- **R2.a.3:** counted-loop syntax and the `domain_loop` rewrite.

The name `is_emailish`, the recursive `domain_loop`,
`scan_while(i, predicate)` and the set-membership idiom are all
deliberately unchanged here.

## Next step: R2.a.2

Rename `web::is_emailish` to an ordinary trailing-`?` identifier. This
needs the lexer to admit `?` in ordinary identifiers, which is a parser
change deliberately kept out of R2.a.1.

For whoever takes on the performance side afterward, two findings above
are candidates:

- keying policy for closures whose captures are once-bound module bindings;
- the 9,200 predicate-passing `char_at` substrings (a StringRegion/
  callvalue question).
