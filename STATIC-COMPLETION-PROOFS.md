# Static completion proofs: integrating explicit errors with the proof lattice

## Outcome

The explicit-error milestone (EXPLICIT-ERROR-COMPLETIONS.md) closed the
original undeclared-runtime-error hole but left the static-proof side
deliberately conservative: every call to a declared-fallible function had to
handle or re-declare *every one* of its callee's declared errors,
unconditionally, even when the concrete argument in hand made a particular
error provably unreachable -- and a call that could *never* succeed still
compiled cleanly as long as a handler happened to be present for its one
guaranteed error.

This milestone restores Botlish's intended three-way rule in full:

```
statically provable success   -> no runtime-error obligation
statically provable failure   -> compile-time diagnostic
runtime-uncertain success/failure -> explicitly declared runtime error completion
```

Concretely:

- `byte::from_int` is now honestly typed `int -> Byte` (a typed `value: int`
  parameter, STRICT-TYPED-PARAMETERS.md's usual static-proof obligation at
  every call site -- no runtime type check inserted).
- A new, general **call-specific completion proof** (`hir/completions.tcl`)
  computes, for every call whose target is an exact, statically known
  function, `effectiveErrors(call)` (a subset -- never a superset -- of the
  callee's declared error set) and `mayReturnNormally(call)`, from the
  concrete argument facts reachable at that exact call site.
- `effectiveErrors(call) - handledErrors(call) ⊆ enclosingDeclaredErrors`
  replaces the old, flow-insensitive `declaredErrors(callee) -
  handledErrors(call) ⊆ enclosingDeclaredErrors` as the central legality
  rule.
- A call proven unable to complete normally under the current facts is a new
  compile-time diagnostic, `KNOWN-ERROR` -- independent of whether a handler
  is present (a handler is not a way to encode an `if` for a statically
  known condition).
- A pre-existing, unrelated proof-lattice bug (`hir/range.tcl`'s
  `ProvesType`, found but deliberately left unfixed by the previous
  milestone) is fixed: a function declared to return the broadest possible
  scalar type, plain `int`, is no longer rejected merely because its
  inferred result is a non-dense exact finite set.
- `char::codepoint` exposes truthful static facts (`0 <= result <=
  0x10FFFF`, exact for a literal character), which lets `byte::set`'s own
  declared error set shrink, *generically proven*, from `BelowRange,
  AboveRange` to `AboveRange` alone.
- UTF-8 encoding's static result type is now the truthful `List[Byte]`
  (still exactly the same runtime representation), which lets `lib/web.bot`
  drop its last redundant `byte::from_int(...)` conversion.
- `lib/web.bot`'s `additional_unreserved_chars` module initializer is
  restored to its clean, handler-free form:
  `additional_unreserved_chars = byte::set(['-', '.', '_', '~'])` -- the
  call-specific proof establishes `effectiveErrors = {}` for this exact
  call, so no handler, no placeholder fallback set, and no
  `byte::from_int(0)` construction are needed.

All of this is **static semantic analysis**, not an optimization: it changes
which source programs are statically legal (a provably-failing call is now
rejected even with a handler present; a provably-safe call no longer needs
one), never what machine code an already-legal program compiles to. No
codegen, representation, or optimizer file was touched (see "Scope
questions" below).

## Why this is semantic proof, not optimization

The previous milestone's own scope boundary (its item 82) explicitly
permitted leaving "this error cannot happen at this call site" unproven, on
the grounds that the *mechanism* (declare/fail/handle) was the deliverable,
not a dead-branch eliminator for it. This milestone's brief revoked that
permission for exactly the reason the previous report already flagged: a
program whose every call site must handle every declared error, whether or
not it can actually occur, is not "conservative" -- it silently defeats the
whole point of Botlish's own three-way completion rule, because a call that
provably *always* fails still compiles as long as a syntactically-present
handler exists for it. Making the compiler see that is changing the
*acceptance* of source programs (some now-legal programs, like
`byte::set(['-','.','_','~'])` with no handler, were previously rejected;
some now-illegal programs, like `byte::from_int(999): on AboveRange: 255`,
were previously accepted) -- the textbook definition of a semantic-analysis
change, not a machine-code shape change. Every acceptance test in this
report is a `hir::diagnostics`-level (or `hir::completions::
effectiveErrorsOf`/`mayReturnNormallyOf`-level) assertion, never a
generated-code assertion.

## Path-sensitive range facts

Items 6-10's "minimal general branch-sensitive range-fact mechanism" turned
out to already exist, essentially complete, in `hir/range.tcl`
(`ComparisonNarrowing`/`Narrowed`/`ExactEqualityNarrowing`/`JoinBindings`),
built for an earlier, unrelated milestone (native representation analysis).
It already:

- computes, for `x < C`/`x <= C`/`x > C`/`x >= C`, the narrowed `Range` of
  `x` on each outcome (`Narrowed`), intersecting with any existing fact
  (interval bounds are simply tightened, never loosened);
- scopes that fact to exactly the corresponding lexical branch
  (`hir::range::If`'s own `dict set ctx bindings $saved` restore before each
  branch, and `JoinBindings` afterward);
- preserves an existing *exact* fact through compatible narrowing rather
  than widening it to a bare interval (`Narrowed` filters `ExactOf`'s
  tracked set, not just the interval, on every comparison);
- accumulates facts through nested `if`s for free, because each nested
  `If` call runs inside the *already-narrowed* `ctx.bindings` its enclosing
  branch established -- `byte::from_int`'s own two-level `if`/`fail`/`if`/
  `fail`/`else` shape (items 9/66) needs no special handling at all.

**Nothing in `hir/range.tcl` needed to change for items 6-10.** What this
milestone actually needed, and did not have, was *branch feasibility from
those facts* (item 29: a condition may be provably true, provably false, or
unknown, from range facts, not just from `hir::types::KnownOutcome`'s own
purely syntactic/type-level decided-condition check) and *tracking which
declared error names are reachable through a `fail`* (`hir/range.tcl`
already treats `fail` as an opaque `never`, correct for its own purpose but
uninformative for this one). Building that *specifically inside*
`hir/range.tcl`'s own shared `If`/`Expr`/`AnalyzeInstance` was rejected
deliberately (see "HIR representation" below): that fixpoint doubles as
`native/lower.tcl`'s own raw-representation eligibility analysis, with its
own golden-file assembly audits (`SCALAR-ASM-AUDIT.md`), so teaching it new
precision risks silently changing generated code -- exactly what item 60-61
forbid. `hir/completions.tcl` is instead a **separate, focused, local**
walker (never interprocedural, never touched by native lowering) that reuses
`hir/range.tcl`'s own pure lattice operations (`join`, `intersect`,
`ComparisonNarrowing`, `Narrowed`, `RefBinding`, `TypeFact`/`ConstrainType`,
`add`/`sub`/`mul`/`BitOp`, `ExactOf`, `point`, `unknown`, `JoinBindings`)
directly, and adds exactly the two capabilities above on top: an empty
narrowed `Range` (both bounds finite, `min > max`) is treated as a genuinely
infeasible branch outcome, pruned before its body is ever walked
(`hir::completions::BranchOutcome`/`RangeEmpty`), and every `fail NAME`
reached (respecting that same pruning) is recorded into the walk's own
`ctx.errors` set.

## Comparison branch refinement

Unchanged from `hir/range.tcl`'s own pre-existing implementation (see
above): `<`/`<=`/`>`/`>=` on an immutable local/param binding against a
statically known scalar bound intersect the existing fact on both outcomes,
mirrored for either operand order, with the false branch using the
comparison's negation (`hir::range::ComparisonNarrowing`'s own operator
table). `hir/completions.tcl` calls this directly, through a small read-only
shim `{exprs CTX.EXPRS monotone {}}` (its own `exprs` cache of this walk's
already-evaluated argument Ranges, `monotone` always empty since
`hir::induction.tcl`'s own equality-termination proof is a whole-program,
interprocedural fact this local walk never computes or needs -- `==`
narrowing here always takes `ComparisonNarrowing`'s general
`ExactEqualityNarrowing` fallback instead, which is exactly right).

## Exact-set acceptance fix

`hir/range.tcl::ProvesType` conflated two different reasons a declared
type's own `core::type::integerFacts` can come back empty: "this type is
`int` with no further domain restriction" (every int is trivially a
member) and "this type is not int-based at all" (nothing is provable from
an int `Range` fact). Both returned `0` unconditionally. Reproduced
directly: a function whose declared result is plain `int` and whose
inferred *nominal* type is `any` (e.g. its value is an otherwise-untyped
parameter, narrowed only by `hir/range.tcl`'s own equality-branch analysis
to an exact set like `{0, 78, 999}`) failed `hir::types::subtype(any, int)`
(since `subtype` rejects `any` on the left unconditionally) and then failed
the old `ProvesType` too, for a value that is, by construction, always an
`Int`.

Fixed generically, per the milestone's own stated rule (item 11):

```
ExactSet{v1...vn} accepted by T iff every member vi is accepted by T
```

applied to the trivial case where `T` is unrestricted `int`:

```tcl
if {$facts eq {}} {
    return [expr {[core::type::base $type] eq {int} && ![isUnknown $range]}]
}
```

A non-`int`-based `type` still correctly proves nothing (a `Range` fact is
never meaningfully attached to a non-Int-typed expression in this file
regardless, per its own header), and a fully unknown `Range` still correctly
proves nothing either. No special case for `{0, 78}`/`int`, or for the test
that exposed the bug: `hir/range.tcl::ProvesType` is the only file touched.
Pinned generically (`tests/source-types.test`, `source-type-exact-set-
accepted-by-broad-int`/`source-type-exact-set-member-rejected-by-narrow-
type` -- the second confirms a *narrower*-than-`int` declared type still
correctly rejects an out-of-domain exact-set member).

## Typed `byte::from_int`

```botlish
fn from_int(value: int) -> Byte errors BelowRange, AboveRange:
    if value < 0:
        fail BelowRange
    else:
        if value > 255:
            fail AboveRange
        else:
            value
```

`value`'s previous milestone comment explained *why* it was left untyped:
declaring `value: int` would make every call site that could not statically
*prove* its argument an `Int` (e.g. `list_get`'s own untyped `List[int]`
element) uncallable, and that motivated leaving the strict-typed-parameter
check out entirely. This milestone's own item 5 is explicit that the fix
belongs in the *producers*, not in weakening `from_int` back: `encode_utf8`'s
own truthful `List[Byte]` result type (below) and `char::codepoint`'s own
truthful `int`-with-facts result mean every actual caller in this codebase
now has a statically provable `Int` (or `Byte`, itself a subtype) in hand at
every `from_int` call site, so the typed parameter costs nothing in
practice -- confirmed directly: `lib/byte.bot`/`lib/web.bot` both compile
clean under `-strict 1` with the typed parameter and zero call-site
weakening.

`byte::from_int("hello")` is now a static `TYPE` diagnostic
(`STRICT-TYPED-PARAMETERS.md`'s own existing mechanism, unchanged): `str`
is not provably `int`. No dynamic kind check is inserted for the declared
parameter -- the existing invariant (argument proven admissible -> call
legal; not proven -> compile-time `TYPE` error) is unchanged and untouched
by this milestone.

## Call-specific completion analysis (`hir/completions.tcl`)

A new, focused proof pass, deliberately kept separate from `hir/range.tcl`'s
own interprocedural, codegen-facing fixpoint (see "Path-sensitive range
facts" above for why). Two entry points:

- `hir::completions::checkBlock hir BLOCK ENCLOSING-ERRORS` -- the
  once-per-function-body legality driver `hir/errorsets.tcl`'s own
  "blocks" loop calls once per function (plus once for the program root,
  whose own enclosing set is always `{}` -- top-level closure, item 54,
  falls straight out of this one shared rule with no separate check). Walks
  the block's own body, diagnosing every call/handle it finds directly in
  its own lexical scope (never descending into a different block's own
  body -- that gets its own independent top-level entry from the same
  driver loop, exactly matching the previous milestone's own `WalkExpr`
  scoping).
- `hir::completions::analyzeBlock hir BLOCK ARGRANGES ARGEXACT ARGEXACTLISTS
  GUARD` -- pure fact computation (never diagnoses): what a call to `BLOCK`,
  under concrete per-parameter facts, may complete with. Used recursively
  (a fallible call nested inside the body currently being checked, item 33)
  and by a `handle` node's own effective-set computation.

### Facts threaded through the walk

- **Range** (`ctx.bindings`, `bindingId -> Range`): reuses `hir/range.tcl`'s
  own lattice verbatim.
- **Exact non-Int value** (`ctx.exact`, `bindingId -> core value`): a
  general mechanism for propagating an exact scalar constant of *any* kind
  (not just Int) through an immutable binding -- the motivating case is a
  literal `UnicodeChar` (item 22), but nothing here is UnicodeChar-specific.
- **Exact List elements** (`ctx.exactList`, `bindingId -> {value ...}`):
  the List-typed counterpart, for small-literal-list proof (items 36-40).
  Both of these cross an exact call boundary the same way an Int `Range`
  fact already does (`ArgExactValues`/`ArgExactLists`, seeded into the
  callee's own fresh `ctx` by `analyzeBlock`) -- this is what lets
  `byte::set(['-','.','_','~'])`'s own literal argument reach `set`'s own
  `loop c in chars:` (whose `iterable` is a plain `ref` to the parameter
  `chars`, not the literal list expression itself) as a genuine small
  literal list, with **zero** `byte::set`/`web`-specific code anywhere in
  this file.
- **Errors** (`ctx.errors`, `name -> 1`): every declared error name a
  reachable `fail` (respecting branch-feasibility pruning) contributed,
  *plus* every error a nested call's own effective set left unhandled
  (`MergeErrors`, called from both a bare call and a `handle`'s own
  unhandled remainder) -- this second half was the actual hardest bug in
  this milestone (see "A note on the implementation" below): a nested
  call's own possible errors are, from the *enclosing* function's own
  perspective, exactly as much a possible completion as a direct `fail`.

### Possible completions, not merely possible errors

For an exact call under concrete facts, `hir::completions::EffectiveFacts`
(recursing into `analyzeBlock`, guarded and budgeted -- see below) computes
`{normal errors resultRange}` together, never errors alone:

```
from_int(45):    normal=true,  errors={}
from_int(999):   normal=false, errors={AboveRange}
from_int(x:int): normal=true,  errors={BelowRange, AboveRange}
```

`fail NAME` contributes `normal=false` with `NAME` added to the possible
error set for that path -- never a value, aligned with the pre-existing
completion model (`core/completion.tcl`'s `propagate-error`, unchanged by
this milestone). An ordinary value path contributes `normal=true` with no
error merely because the *enclosing function's own signature* declares one
-- declarations are upper bounds on what a call may produce, never a claim
that every call site reaches every one of them.

### `if` analyzed by branch feasibility

`hir::completions::EvalIf` mirrors `hir::range::If`'s own shape (evaluate
the condition once to populate the walk's `exprs` cache, then decide each
outcome), but decides feasibility two ways, in order: `hir::types::
KnownOutcome` (cheap, purely syntactic, reused unchanged) first, then
`ComparisonNarrowing` against the concrete facts -- if narrowing produces an
empty `Range` for any touched binding, that outcome is infeasible and its
body is never walked at all (no error it contains is ever added to
`ctx.errors`, exactly matching runtime left-to-right completion semantics,
item 73). An infeasible branch's own contribution to the join is `never`,
exactly like a `fail`-ending branch's own value; `hir::range::JoinBindings`
(reused verbatim) decides what code textually after the `if` sees. Sequence
composition (item 32) falls out of `Seq`'s own short-circuit on the first
`never` sub-expression, mirroring `hir::range::Sequence` exactly.

### Effective error sets and the legality rule

```
effectiveErrors(call) = declaredErrors(callee) - errors proven impossible
                          for this call, under the facts reachable here
```

computed, never a superset, never invented outside `declaredErrors(callee)`
(item 46/98: `ctx.errors` only ever grows from a `fail NAME` the callee's
own body legitimately contains -- itself only legal there because
`hir/resolve.tcl` already independently checked `NAME` is in that
function's own `errors` clause -- so `effectiveErrors` is a subset of
`declaredErrors` by construction, with no extra check needed). Legality
(`hir::completions::CheckCallLegality`) is now:

```
effectiveErrors(call) - handledErrors(call) subseteq enclosingDeclaredErrors
```

replacing the previous milestone's flow-insensitive `declaredErrors(callee)
- handledErrors(call) subseteq enclosingDeclaredErrors` at the one place it
was checked. `effectiveErrors = {}` trivially satisfies this for *any*
enclosing set (the `foreach name $errors` loop never fires) -- exactly item
20's "no handler/declaration obligation" behavior, with no special case
written for it: it falls straight out of the general rule.

### Known-success and known-failure diagnostics

`CheckCallLegality` checks `mayReturnNormally` **first**, before `handled`
is even consulted (item 50): if a call cannot complete normally under the
current facts, it is always a `KNOWN-ERROR`, independent of any handler --
`byte::from_int(999): on AboveRange: 255` is rejected exactly like the
unhandled bare call, because a handler is not a way to encode an `if` for a
statically decided condition. The diagnostic names the call and the
guaranteed error(s) (item 19/80):

```
this call can never complete normally under the facts proven for its
arguments here -- it always produces the declared error(s) AboveRange; a
handler does not make a statically known failure legal
```

Only once `mayReturnNormally` is true does the ordinary
subset-admission check against `enclosingDeclaredErrors`/`handledErrors`
run, producing the pre-existing `UNHANDLED-ERROR` diagnostic per remaining
name.

### Partial error-set elimination

Falls out of the same general mechanism with no extra code: if a value is
statically nonnegative (e.g. `char::codepoint`'s own result, or an
in-source `nonneg`-shaped helper) but not upper-bounded,
`BelowRange`'s branch is pruned as infeasible (the narrowed `Range` for
`value < 0` becomes empty) while `AboveRange`'s branch remains live, so
`effectiveErrors = {AboveRange}` only -- confirmed both for `byte::from_int`
directly (`tests/source-types.test`) and for the general `bounded` fixture
in `tests/errors.test`.

### Nested calls, recursion, and the proof budget

A nested call inside an analyzed callee's own body (item 33) is handled by
the *same* `EffectiveFacts` -> `analyzeBlock` recursion, seeded from the
current walk's own facts for that call's arguments -- no separate
mechanism. Two safeguards keep this from ever running away or claiming
something unproven:

- **Recursion guard** (item 34/16): `EffectiveFacts` checks the current
  `guard` (a `blockId -> 1` dict, accumulated down the recursion) *before*
  ever recursing; a target already in `guard` (self- or mutual recursion)
  falls back to that callee's own full declared contract, `normal=true`,
  `errors=declaredErrors(target)`, `resultRange=unknown` -- never a claim
  of impossibility the cycle did not actually verify.
- **Proof budget** (item 35, `hir::completions::maxAnalyses`, 256): once a
  single top-level `checkBlock` walk has run this many distinct recursive
  `analyzeBlock` analyses, every further nested call falls back to the same
  conservative contract. Documented directly in the source; generous enough
  for every corpus shape (a handful of calls per literal-list element,
  `byte::set`'s own single level of `from_int` nesting) while bounding a
  pathological call chain.
- **Memoization** (a plain performance fix, not a semantic one --
  `hir::completions::cache`, reset once per whole-program `errorsets::
  verify` pass): `analyzeBlock`'s own result is cached by `{target
  argRanges argExact argExactLists}`, since the overwhelmingly common case
  is many call sites to the same helper sharing identical (often fully
  unconstrained) argument facts, and re-walking the same callee body from
  scratch at every one of them compounds multiplicatively with program
  size. Sound regardless of which `guard` chain a cache hit and its
  original computation ran under, because `guard` only ever makes a
  sub-computation *more* conservative (a cycle/budget fallback widens
  toward the callee's full declared contract, never narrows) -- reusing a
  result computed under a stricter guard can only cost precision, never
  introduce a false claim of impossibility (item 82's own soundness rule).
  A target already in the *current* guard is checked before the cache is
  even consulted, so a genuine cycle is never short-circuited by a stale
  hit.

## `char::codepoint` facts

`char::codepoint` (`lib/char.bot`) wraps the root native `char_codepoint`
(`core/unicodechar.tcl`), already registered `-result-range nonneg` for
`hir/range.tcl`'s own (unrelated, codegen-facing) purposes -- unchanged,
deliberately, to avoid the same generated-code blast radius discussed above
(strengthening that shared metadata could shift `native/lower.tcl`'s own
raw-representation eligibility decisions and the golden-file assembly audits
keyed to them). Instead, `hir/completions.tcl` carries its **own**, local,
never-registered fact for this one native
(`hir::completions::NativeResultRange`):

```
0 <= char_codepoint(c) <= 0x10FFFF
```

sound because `UnicodeChar` is a Unicode scalar value by construction
(`core/value.tcl`'s own `isValidScalar`), and, when the argument is provably
an exact `UnicodeChar` constant (a literal, or `ctx.exact` propagation
through an immutable binding), the exact codepoint itself:

```
char::codepoint('A') -> exact 65
char::codepoint('é') -> exact 233
char::codepoint('Ā') -> exact 256
```

Pinned directly (`tests/errors.test` via `hir::completions::
resultRangeOf`). No constant folding for codegen purposes: this fact is
consumed only by this file's own proof, never by any backend.

## `byte::set` contract reduction

```botlish
fn set(chars: List[UnicodeChar]) -> ImmutableSet[Byte] errors AboveRange:
    bytes = loop c in chars:
        from_int(char::codepoint(c))
    immutable_set_from_list(bytes)
```

`BelowRange` is gone from the declaration, *proven*, not asserted: when
`set`'s own body is independently checked (its own top-level `checkBlock`
entry, `chars` unseeded/generic), the dynamic loop over `chars` evaluates
`from_int(char::codepoint(c))` once, with `char::codepoint(c)`'s own fact
(`[0, 0x10FFFF]`, from the previous section) as `from_int`'s argument Range
-- `value < 0`'s narrowed Range for that fact is empty (`min=0` already
excludes it), so `BelowRange`'s branch is pruned and never contributes to
`ctx.errors`, while `value > 255`'s branch remains live and does. The
resulting `effectiveErrors = {AboveRange}` is checked against `set`'s own
newly-narrowed declaration, `errors AboveRange` -- admitted, so the function
itself compiles clean. `AboveRange` remains genuinely possible (any
`UnicodeChar >= U+0100` reaches it dynamically) -- `set` is still fallible,
just honestly so.

## Small literal-list proof

`hir::completions::EvalListloop`/`LiteralListOf`: when a `listloop`'s own
`iterable` is (directly, or through `ctx.exactList` propagation across an
exact call boundary) a small literal list -- a direct call to the variadic
`list` native whose every argument is a plain `const`, within `hir/
range.tcl`'s own existing exact-value budget (`$::hir::range::maxExactValues`,
32 -- reused, never reintroduced) -- the loop body is walked once per
element, **left to right**, each under that element's own exact fact. The
first element whose own body proves unable to complete normally stops the
whole listloop there (matching runtime left-to-right completion semantics,
item 73): later elements are never analyzed, exactly mirroring what would
actually happen at runtime. An empty literal list never executes the body
at all (item 92): trivially always completes normally, no errors, with no
container-variance special-casing needed (this is a proof-time fact about
an already-typed `List[UnicodeChar]` value, not a new type). This is
general, not `byte::set`-specific: the same `list`-native-call recognition
and per-element walk apply to any `loop x in [literal, ...]:` shape,
whatever fallible calls its body happens to make.

```
byte::set(['A'])                -> effectiveErrors {} (65, safe)
byte::set(['é'])                -> effectiveErrors {} (233, safe)
byte::set(['ÿ'])                -> effectiveErrors {} (255, safe)
byte::set(['Ā'])                -> KNOWN-ERROR (256, guaranteed AboveRange)
byte::set(['😀'])               -> KNOWN-ERROR (128512, guaranteed AboveRange)
byte::set(['A', 'Ā', 'B'])      -> KNOWN-ERROR at 'Ā'; 'B' never analyzed
byte::set(['-', '.', '_', '~']) -> effectiveErrors {}, no handler needed
```

## UTF-8 result type

`core/strings.tcl`'s `encode_utf8` (`str -> List`, one UTF-8 byte per
element, each definitionally in `0..255`) now declares
`-result-shape {typed Byte}` -- a new `-result-shape` kind
(`core/native.tcl::ValidShape`/`hir/types.tcl::ShapeResult`) distinct from
the pre-existing `elements`/`element`/`append`/`immutable-set` kinds: those
all derive a result's element type *from its own arguments*; `typed NAME`
is a fixed, argument-independent fact about the native itself, resolved
**lazily**, at ordinary whole-program type-inference time
(`core::type::isNamed NAME`), not at native-registration time. This
indirection is necessary, not stylistic: `encode_utf8` is registered once,
at Tcl-process bootstrap (`core.tcl` sources `core/strings.tcl`
unconditionally), long before a compiling program's own `type Byte = Int in
0..255` declaration (`lib/byte.bot`, parsed per-compilation) exists in
`core::type`'s registry -- `Byte` is stored in the shape tuple as a
symbolic name and resolved only once type inference actually runs, by which
point every source-defined type the compiling program itself loaded is
already registered. If a program never loads `lib/byte.bot` at all,
`isNamed` is false and `ShapeResult` falls back to the native's own plain
declared `-result-type list` -- never a false claim (per item 86: no `0`/
`255` bound is hardcoded into the compiler; the `Byte` name is resolved
against whatever the compiling program's own type registry currently
holds, and its *domain* still comes entirely from `lib/byte.bot`'s own
declaration). No runtime representation change (item 27): `encodeUtf8`'s
own Tcl implementation is untouched, still `List[Int]`-shaped at runtime,
same bytes, same order.

`list_get`'s own pre-existing, fully generic `{element 0 1}` shape then
gives `list_get(bytes, i) : Byte` automatically, with **zero** list-get- or
web-specific code (item 75).

## `web` migration

`lib/web.bot`'s `esc_char` no longer converts:

```botlish
fn esc_char(c):
    bytes = encode_utf8(c)
    if list_length(bytes) == 1:
        b = list_get(bytes, 0)
        if is_unreserved(b):
            c
        else:
            esc_bytes(bytes, 0, "")
    else:
        ...
```

`list_get(bytes, 0)` is now directly `Byte`-typed; the previous
`byte::from_int(...): on BelowRange: ... on AboveRange: ...` conversion (and
its always-unreachable-in-practice fallback) is gone -- it was working
around an under-typed `encode_utf8`, never a genuine runtime possibility,
and item 26/54 is explicit that a redundant conversion should not remain in
library source once its producer's own static contract is honest.

## URI punctuation module initialization

Restored exactly:

```botlish
additional_unreserved_chars = byte::set(['-', '.', '_', '~'])
```

No handlers, no placeholder `ImmutableSet[Byte]` sentinel, no
`byte::from_int(0)` construction. The call-specific completion proof
establishes `effectiveErrors = {}` for this exact call (every element is a
statically known safe literal, per "Small literal-list proof" above), which
trivially satisfies the legality rule at the module's own top level
(`enclosingDeclaredErrors = {}`) with no `foreach` iteration even firing.

## Module retention

`hir/modulebinding.tcl`'s own `ImmutableExpr`/`fail`-case `{diverge}`
mechanism (added by the previous milestone) needed **no code change**.
Re-examined directly: it already drops a `diverge`-marked branch
*unconditionally*, regardless of whether that branch is provably reachable
under any concrete facts -- its own soundness always rested entirely on
`hir/errorsets.tcl`'s **separate** static proof that every `fail` it
encounters is legitimately handled or re-declared somewhere (its own
existing comment says exactly this). Since this milestone made that
separate proof strictly *more* precise (an actually-unreachable `fail`
inside an inlined callee body no longer forces a caller to declare/handle
an error that can never really propagate), `hir/modulebinding.tcl`'s own
existing leniency became *exact* rather than merely hopeful, with nothing
in it needing to change: a module binding's initializer, having no free
variables, either fails deterministically every run (in which case
`hir/errorsets.tcl` already rejects the whole program before
`hir/modulebinding.tcl` even matters) or never fails at all (in which case
dropping the `diverge` branch is exactly correct). `additional_unreserved_
chars` is confirmed still `built once, retained, zero per-call
reconstruction` (`tests/byte-set.test`'s own `byte-set-module-retained-
value`, updated for the clean initializer, still checks exactly one
`setfromlist` allocation site).

## Conservative fallback / proof budget

Documented above (recursion guard, proof budget, memoization). The
governing soundness rule throughout (item 82-83): a branch is pruned as
infeasible only when `ComparisonNarrowing`'s own narrowed `Range` for a
touched binding is provably empty (`min > max`, both bounds finite); a call
is diagnosed `KNOWN-ERROR` only when `mayReturnNormally` computed `false`;
every fallback path (guard hit, budget exhausted) widens toward the
callee's full declared contract, never narrows. False negatives (an error
this proof *could* in principle rule out but does not) are acceptable and
expected outside this milestone's own corpus (item 82); a false claim of
impossibility is not, and none of the mechanisms above can produce one by
construction.

## HIR representation

No new HIR node kinds. `hir::completions::CheckCallLegality` stashes two
new fields onto an already-checked `call`/`handle` expression node --
`effectiveErrors` (the name list) and `mayReturnNormally` (0/1) -- purely
for later inspection (item 62/89: useful input to the later comprehensive
generated-code audit, and this milestone's own HIR-inspection tests), never
read back by this pass itself and never consulted by any backend. A third,
`resultRangeFact`, records the `Range` this pass computed for a checked
call's own value (used by the `char::codepoint` exact-fact tests). Plain
dict fields on an existing node, ignored by every unrelated pass exactly the
way `calleeErrors`/`known` already are; `hir/format.tcl`/`hir/read.tcl`'s
text round-trip is unaffected (these fields are never part of the canonical
text format, matching `hir/read.tcl`'s own "not re-derived by the reader"
philosophy for post-analysis facts).

## Backend parity

`hir/completions.tcl` runs entirely before any backend executes, as part of
`hir::buildSyntax`'s existing diagnostic-collection sequence (`hir::
errorsets::verify`'s own call site, unchanged). No file in `compiler/`,
`core/evaluator.tcl`, `native/lower.tcl`, or `native/src/` was touched by
this milestone (confirmed directly: `git diff --stat` for this milestone
touches only `hir/`, two `core/` files whose only change is a new,
inert-until-consulted native-registration option and one `-result-shape`
annotation, and library/test source) -- every genuinely runtime-uncertain
case (a dynamic `byte::from_int`/`byte::set` call) reaches the *same*,
completely unmodified runtime error-completion machinery on all four
backends the previous milestone already established parity for. A
program this milestone's own proof rejects at compile time (a known
failure, or an unhandled/undeclared propagation) never reaches any backend
at all -- there is nothing for parity to even ask about in that case.
`tests/errors.test`'s own `parity`/`moduleParity` helpers continue to
exercise all four backends (`interp compile cranelift-generic cranelift`)
for every genuinely runtime-uncertain scenario in this report.

## Generated-code baseline (intentionally unoptimized)

Per item 61/101-102, no codegen change was made, and none should be
inferred from this report's own precision. Concretely, and left exactly as
found for the later comprehensive generated-code audit to address:

- `byte::from_int(dynamic int)` still compiles both its `<`/`>` range
  checks and both `fail` paths on every backend, unconditionally --
  unaffected by this milestone's own static proof that a *specific* call
  site's own facts make one or both unreachable.
- `byte::from_int(45)` (statically safe) still compiles the identical
  callee body -- the same two range checks, the same two `fail` paths --
  even though this milestone's own proof establishes that neither can ever
  fire for this particular call. No inlining, no specialization, no
  guard/error-edge elimination was added.
- `byte::set(dynamic chars)` still compiles its own loop body exactly as
  before, including the `BelowRange`-shaped range check inside the
  `from_int` it calls, even though `byte::set`'s own *declared* contract no
  longer admits `BelowRange` at all (the discrepancy between "declared
  impossible" and "still range-checked at runtime" is exactly the kind of
  input the later audit is meant to use).
- `web::is_unreserved`'s own path is unchanged at the machine-code level:
  removing the source-level `byte::from_int(...): on ...` conversion around
  `list_get(bytes, 0)` removes exactly the Tcl/NIR this milestone's own
  static proof already knew was dead source, not a codegen decision --
  `native/native.tcl`'s `ExpandNativeBodiesIn` and `native/lower.tcl` are
  untouched, so the *remaining* generated code for the surviving call
  shapes is bit-for-bit whatever those files already produced.

This is deliberate, tracked input for the next milestone, not a regression:
"Generated code may remain redundant" (item 61) is the explicit acceptance
criterion here.

`audit/native-scalar-asm/` (`tclsh9.0 native/generate-scalar-audit.tcl`) was
regenerated against this milestone's own final source, matching every
previous milestone's own practice. The one corpus entry it touches,
`bench/refined-checks.ir` (which exercises the real `web`/`byte`/`ascii`
pipeline), shrinks from 34 functions/19043 bytes to 33 functions/17855
bytes: `byte::from_int` no longer appears as its own separately-compiled
function (nothing in this corpus's own reachable call graph still calls
it directly -- `esc_char`'s own conversion is gone, per "web migration"
above), and `esc_char` itself drops from 31 to 23 NIR registers (the
removed handler code). Exactly the same kind of consequence
EXPLICIT-ERROR-COMPLETIONS.md's own item 78 already called out for
allocation counts: **not** an optimization achievement -- nothing about
*how* Cranelift compiles a reachable function changed -- purely the
mechanical result of fewer source call sites left to compile, after this
milestone's own semantic changes removed source-level dead code. No other
corpus entry (`bench/fib.ir`, `bench/loop-count.ir`, `bench/sum-refined.ir`,
or any `examples/stdlib/` file) changed at all.

## Tests

`tests/errors.test` grew from 31 to 37 tests. New/changed:

- `errors-byte-from-int-known-safe-literal-no-handler`/`-known-failure-
  literal`/`-known-failure-with-handler-still-rejected`: items 20/50/64.
- `errors-byte-from-int-partial-range-elimination`: item 21/65.
- `errors-byte-from-int-branch-refinement-result`: item 9/66 (`lib/byte.bot`
  itself compiles clean under `-strict 1`, proving the declared `Byte`
  result from ordinary branch-sensitive facts, no builtin escape hatch).
- `errors-generic-bounded-fixture`: item 15/67 (the exact `bounded`
  fixture, generic, no Byte-specific compiler code).
- `errors-byte-from-int-unhandled-rejected`, `errors-rejects-unhandled-
  at-top-level`, `errors-rejects-duplicate-handler`, `errors-rejects-
  wrong-handler-type`, `errors-cross-module-unhandled-rejected`: all five
  previously used a *literal*, statically-decidable argument to exercise an
  unrelated check (duplicate-handler/wrong-handler-type/cross-module
  propagation); under this milestone's own new precision that argument's
  own call became independently, correctly flagged `KNOWN-ERROR`/accepted
  with no diagnostic, which is *correct* but no longer exercises what each
  test actually intends to pin. Each now routes its argument through an
  untyped (or, where the callee itself requires `int`, explicitly
  `: int`-typed) wrapper-function parameter, so the value is genuinely
  unconstrained at that call site -- restoring each test's own original,
  narrower intent alongside this milestone's own new behavior.
- `tests/source-types.test`: `source-type-exact-set-accepted-by-broad-int`/
  `-member-rejected-by-narrow-type` (item 11/68).
- `tests/byte-set.test`: `byte-set-accepts-char-list`/`-module-retained-
  value` rewritten to the clean, handler-free call shape (items 70-71/77);
  `byte-set-result-type`/`-rejects-string-list`/`-rejects-int-list` and the
  dynamic-input tests (ASCII/`é`/`ÿ` success, `Ā`/`😀` `AboveRange`) are
  unaffected and continue to pass unchanged.
- `tests/surface-modules.test`: `surface-modules-uri-hex-digits-startup`'s
  own `op listnew` count drops from 5 to 3 (item 78-79) -- the two
  placeholder-fallback handler bodies' own one-element lists no longer
  exist in source to lower, not an optimization of anything that remained.
- `tests/ascii.test`/`tests/web-unreserved.test`/`tests/native-byte.test`/
  `tests/refined-signatures.test`/`tests/native-uri-escape.test`: run
  unchanged and pass -- their own dynamic-loop-variable call shapes
  (`loop n in ns: b = byte::from_int(n): on ... on ...`) are genuinely
  unconstrained at the point `hir::completions.tcl` analyzes them (the
  literal list `ns` is bound via a plain top-level `bind`, never a direct
  `listloop` iterable and never propagated through `ctx.exactList`, so this
  milestone's own small-literal-list proof correctly does not fire for
  them), preserving their original, still-legitimate fallibility.

`hir::completions::effectiveErrorsOf`/`mayReturnNormallyOf`/`resultRangeOf`
give every new test direct HIR-level access to this pass's own computed
facts (item 89), rather than relying solely on whether a program happens to
compile.

## Full regression / GC stress

`tclsh9.0 tests/all.tcl` (interp backend): **Total 2093, Passed 2093,
Skipped 0, Failed 0**. The same run's own second pass (`#### backend:
compile`, `tests/all.tcl`'s own built-in second invocation over the compile
Tcl-codegen backend): **Total 2093, Passed 2093, Skipped 0, Failed 0**.
(2093 = the previous milestone's own 2085 baseline + 8 tests this milestone
adds: 6 in `tests/errors.test`, 2 in `tests/source-types.test`.)

`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: interp pass **Total
2093, Passed 2093, Skipped 0, Failed 0**; compile pass **Total 2093, Passed
2093, Skipped 0, Failed 0**.

`cargo test --release --manifest-path native/Cargo.toml`: **60 passed; 0
failed; 0 ignored**.

Getting a clean `tests/all.tcl` run surfaced two real bugs in this
milestone's own first implementation of `hir/completions.tcl`, both fixed
before these final counts and both worth recording here since they are
exactly the kind of soundness/robustness gap the "Conservative fallback"
section above exists to prevent:

- **Arity mismatch crash**: a call built from raw core IR with fewer
  arguments than its exact callee's own parameter list (only reachable by
  bypassing the surface parser's own arity checking -- `tests/backends.test`'s
  own `differential-arity` corpus entry, `{call {block {x} {ref x}}}`)
  crashed `analyzeBlock` with a Tcl `dict` lookup error: zipping `params`
  against a shorter `argRanges` via Tcl's own `foreach` silently pads the
  shorter list with empty strings rather than stopping, corrupting
  `ctx.bindings` with a value that is not a valid `Range`. Fixed by checking
  arity explicitly in `EffectiveFacts` and falling back to the same
  conservative contract a recursion cycle uses -- diagnosing an arity
  mismatch itself is not this pass's job (the interp/compile backends
  already raise `CORE SEMANTIC ARITY` for it identically at run time).
- **`return` mistaken for a failure**: `Eval`'s `return`/`break` case
  originally, like `hir::range::Expr`'s own (unrelated) `return` case,
  contributed `never` to its own enclosing sequence -- correct for that
  purpose (later sibling statements are indeed unreachable), but this
  file's own `analyzeBlock` was then using that same `never` to decide
  `mayReturnNormally`, without hir::range::AnalyzeInstance's own
  companion mechanism (`ctx.returnRange`, joined into the final result
  at the very end) to recognize that an explicit `return` is an ordinary,
  *successful* completion, not a failure. Any function that always exits
  through `return` (a common tail-recursive shape, `tests/
  compiler-opt.test`'s own `opt-tail-5`) was therefore wrongly treated as
  `mayReturnNormally = false` for every call to it. Fixed by adding an
  explicit `ctx.returned` flag, set whenever a `return` reaching an actual
  function boundary contributes a non-`never` value, and folded into
  `analyzeBlock`'s own final `normal` determination alongside the
  fall-off-the-end result.

Both were caught by the *existing*, previously-passing corpus
(`tests/backends.test`, `tests/compiler-opt.test`, `tests/hir-types.test`,
`tests/inference.test`, `tests/hir-lowering.test`,
`tests/surface-samples.test`) -- not by any test this milestone itself
added -- which is exactly the value of running the full suite rather than
only the directly-affected files before reporting success.

## FINAL SEMANTIC SOURCE FENCE

Established per item 103-104: the following vertical is now frozen at its
current *source* shape until the comprehensive generated-code/
representation audit completes its own work:

```
byte::from_int
byte::set
ascii:: predicates
UTF-8 byte production (core/strings.tcl encode_utf8)
web::is_unreserved
the URI escape workload (web::uri_escape_text and its own helpers)
explicit error handling semantics (error/errors/fail/handle, hir/errorsets.tcl, hir/completions.tcl)
```

No further source-level refactor or optimization milestone should touch
this vertical before that audit runs and measures `A -> B` (compiler/
backend improvement with source held frozen) separately from a later `B ->
C` (source modernization). This report's own "Generated-code baseline"
section above is the audit's starting input.

## Required architecture questions

1. **What facts are added on the true and false branches of `<`, `<=`,
   `>`, `>=`?** The comparison's own narrowed interval on the relevant
   bound (`hir/range.tcl::Narrowed`, reused directly): e.g. `x < C` narrows
   `x`'s own upper bound to `C-1` on the true branch and its lower bound to
   `C` on the false branch, intersected with any existing fact (including a
   tracked exact set, filtered to the surviving members).
2. **Are those facts scoped to the corresponding lexical branch?** Yes.
   Each `if` restores the pre-condition bindings before walking each branch
   body, and only the *narrowed* copy is used inside that branch; code
   after the `if` sees `hir::range::JoinBindings`'s own join (or, when one
   side is provably infeasible/dead, that side's own facts exactly, no
   join needed).
3. **Can the final success branch of `byte::from_int` prove `value :
   Byte` without cast syntax?** Yes -- confirmed directly:
   `lib/byte.bot` compiles clean under `-strict 1` with no diagnostics.
4. **Is `byte::from_int` now typed `int -> Byte`?** Yes:
   `fn from_int(value: int) -> Byte errors BelowRange, AboveRange:`.
5. **Can a non-int value reach its `<` checks dynamically?** No --
   rejected statically (`TYPE`, `STRICT-TYPED-PARAMETERS.md`'s own
   pre-existing mechanism) before the function body is ever reached, for
   any caller whose argument is not provably `int`.
6. **What is an effective error set?** `effectiveErrors(call) =
   declaredErrors(callee) - errors proven impossible for this exact call,
   under the facts reachable at this call site` (`hir/completions.tcl`).
7. **Can effective errors ever exceed the declared function error set?**
   No -- it is computed as a subtraction from `declaredErrors(callee)` by
   construction (`ctx.errors` only ever grows from a `fail NAME` the
   callee's own already-independently-checked body legitimately contains).
8. **What happens when all declared errors are proven impossible at a
   call?** No handler and no enclosing re-declaration are required --
   `effectiveErrors = {}` trivially satisfies the subset-admission rule for
   any enclosing set.
9. **What happens when normal completion is proven impossible?** A
   compile-time `KNOWN-ERROR` diagnostic, citing the call and the
   guaranteed error(s).
10. **Does a handler make a statically guaranteed failure legal?** No --
    `mayReturnNormally` is checked before `handled` is even consulted;
    `byte::from_int(999): on AboveRange: 255` is still rejected.

## Required proof questions

11. **Does `byte::from_int(45)` require handlers?** No.
12. **Does `byte::from_int(999)` compile?** No (`KNOWN-ERROR`).
13. **What errors remain for `byte::from_int(x)` when `x : int` is
    otherwise unconstrained?** `{BelowRange, AboveRange}`, both.
14. **What errors remain when `x` is statically nonnegative?**
    `{AboveRange}` only, unless an upper bound also proves that
    impossible.
15. **Is this implemented generically for source-defined test
    functions?** Yes -- the `bounded`/`TooSmall`/`TooLarge` fixture in
    `tests/errors.test` demonstrates identical behavior with zero
    Byte-specific compiler code.
16. **What happens when proof analysis exceeds its budget or encounters
    recursion?** Conservative fallback to the callee's declared errors
    and `mayReturnNormally = true` -- never a claim of impossibility the
    analysis did not actually verify.

## Required Byte/String questions

17. **What static facts does `char::codepoint(c)` expose for arbitrary
    `UnicodeChar`?** `0 <= result <= 0x10FFFF` always; the exact codepoint
    when the argument is a provably exact `UnicodeChar` constant.
18. **Can it ever be negative?** No.
19. **Which errors does `byte::set(List[UnicodeChar])` now declare?**
    `AboveRange` only.
20. **Why is BelowRange absent?** Because `char::codepoint`'s own result
    is always nonnegative, which the call-specific proof carries generically
    into `from_int`'s own call inside `set`'s body, pruning `BelowRange`'s
    branch as infeasible.
21. **Does a dynamic UnicodeChar >= U+0100 still produce a declared
    runtime error?** Yes -- `AboveRange` remains genuinely possible and is
    still declared and still a real runtime completion on every backend.
22. **Does `byte::set(['Ā'])` reach runtime?** No -- statically known
    failure (`KNOWN-ERROR`).
23. **Does `byte::set(['-', '.', '_', '~'])` require handlers?** No.

## Required UTF-8/web questions

24. **What is the static result type of UTF-8 encoding now?**
    `List[Byte]`.
25. **Does runtime representation change?** No -- identical Tcl-side
    `List[Int]` construction, identical byte values and order.
26. **What is the static result of `list_get` on that value?** `Byte`.
27. **Does `web` still call `byte::from_int` on an encoded UTF-8 byte?**
    No.
28. **Does `additional_unreserved_chars` still contain impossible
    handlers?** No.
29. **Is it again written directly as `additional_unreserved_chars =
    byte::set(['-', '.', '_', '~'])`?** Yes.
30. **Is it still retained once?** Yes -- confirmed via
    `tests/byte-set.test`'s own module-retention test (one `setfromlist`
    allocation site, called twice, same value).

## Required scope questions

31. **Was callable type syntax reintroduced?** No.
32. **Were type imports added?** No.
33. **Was Result added?** No.
34. **Were error payloads added?** No.
35. **Was machine-code error-edge elimination implemented?** No.
36. **Was the inliner changed?** No.
37. **Was Byte representation specialized?** No.
38. **Was ImmutableSet specialized?** No.
39. **Was broad historical `.bot` source modernized?** No -- only the
    directly affected vertical named in the "FINAL SEMANTIC SOURCE FENCE"
    section above.
