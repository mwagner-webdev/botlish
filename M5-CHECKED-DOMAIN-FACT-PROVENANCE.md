# M5: checked-domain construction fact-provenance audit

## Outcome

**Outcome B.** The exact/finite caller fact behind

```botlish
additional_unreserved_chars = byte::set(['-', '.', '_', '~'])
```

does reach a real, already-shipped static proof (`hir::completions.tcl`,
STATIC-COMPLETION-PROOFS.md): the module-init call's own
`effectiveErrors` is genuinely `{}`, confirmed fresh against the current
tree, not merely asserted from an earlier report. But that proof is
computed and consumed entirely *within* `hir/completions.tcl`'s own
private, non-materializing recursive re-walk (`analyzeBlock`), which never
writes back into the HIR node fields of `byte::set`'s own inner
`from_int(char::codepoint(c))` call. Those inner nodes -- and every
downstream pass that could act on them for *code generation*
(`hir/range.tcl`, `hir/specialize.tcl`, `native/lower.tcl`) -- see only the
generic, unseeded fact from `byte::set`'s own single, one-time,
non-call-specific body check. No downstream pass ever reads
`effectiveErrors`/`resultRangeFact`/`mayReturnNormally` at all (confirmed
by direct grep: only `hir/completions.tcl` itself and its own consumer
`hir/errorsets.tcl` reference these fields anywhere in production code).
`native::lower::If` -- the one thing that could turn a proof into a
removed branch/guard -- decides branch reachability exclusively from HIR
`reachable` (`hir::types::KnownOutcome`, a purely syntactic/type-level
check), never from `hir::range`, confirmed directly in the current source
(`native/lower.tcl:4677`, `hir/types.tcl:1061-1094`).

This is not a new discovery: it is the pre-existing, already-catalogued
residual `RC2`/`RC5` (and the concrete instances `F02`/`F03`) from
`COMPREHENSIVE-GENERATED-CODE-AUDIT.md`, re-confirmed here, fresh, against
the *current* post-EXPLICIT-ERROR-COMPLETIONS/STATIC-COMPLETION-PROOFS
source (where the old `Byte(x)` callable-constructor syntax this milestone's
own brief describes no longer exists at all -- see "A note on stale brief
text" below). Repairing it would mean teaching `native::lower::If` -- the
shared, golden-file-assembly-audited branch lowerer for *every* `if` in the
language, not something scoped to checked-domain construction -- to consult
range facts for dead-branch elimination. That is a general optimizer
feature, already explicitly declined once, for the same reason, by the
milestone that introduced the very proof this one traces
(STATIC-COMPLETION-PROOFS.md's own "Path-sensitive range facts": "teaching
it new precision risks silently changing generated code"). It is not "the
narrowest existing mechanism" this milestone's own scope permits, so no
production code was changed.

**No production code was changed.** One new test file
(`tests/checked-domain-proof-provenance.test`, 17 tests, all passing) was
added, purely to pin the facts this report describes. Full regression
passes unchanged. The FINAL SEMANTIC SOURCE FENCE remains intact.

## A note on stale brief text

This milestone's own brief is written in terms of a callable
`Byte(char::codepoint(c))` construction and a generic
`core::type::CheckedConstruct`/`ProvesValueAcceptedBy` checked-constructor
mechanism reachable from Botlish source. That mechanism **no longer exists
as source syntax**: `EXPLICIT-ERROR-COMPLETIONS.md` (commit `90cfe54`,
already an ancestor of this milestone's own starting `HEAD`, merged via
`aececac Merge main`) removed the bare `NAME(x)` callable-constructor
syntax from the language entirely. `core::type::declareIntConstructor`
(`core/type.tcl:290-292`) now registers *only* the type's membership
predicate (`NAME?`, itself unreachable from any Botlish source program --
see "HighNibble control" below, a separate, pre-existing, unrelated
limitation), never a callable native. `native::lower::CheckedIntDomainConstruct`
(`native/lower.tcl:4155-4197`, the native-lowering fix
`BYTE-SET.md` describes as "the one real gap this milestone closed") is
now confirmed **dead code**: no native is registered anywhere with `-impl
{core::type::CheckedConstruct NAME}` any more (grepped directly; the
proc is referenced only by its own doc comment and itself), and no test
file exercises it. `lib/byte.bot`'s own current source
(`fn from_int(value: int) -> Byte errors BelowRange, AboveRange: if value <
0: fail BelowRange else: if value > 255: fail AboveRange else: value`) is
ordinary, ordinary-if/fail user code, not a "checked construction" HIR/NIR
form at all -- this is exactly the point of EXPLICIT-ERROR-COMPLETIONS.md
(spec item 19-20 of that milestone: "a type name is not a magical
value-level function"). Every fixture in this report and its test file
therefore uses the real, current shape -- `byte::from_int`'s own real body,
or an equivalent user-defined `if`/`fail` function over a second,
non-Byte domain -- never the removed syntax. This does not change the
audit's own conclusion: the underlying question ("does a caller-specific
value/range fact reach the point where a runtime range check could be
removed") is identical whether that point is a dedicated checked-
constructor node or an ordinary `if`; the current architecture answers it
via ordinary `if`-branch lowering, traced directly below.

## M4 allocation-label cleanup/preflight (spec section 2)

Already resolved, intentionally, by M4 itself -- no change made. M4's own
report (`M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md`, "Allocation / GC / roots
consequences") explicitly chose to keep `setfromlist`/`setfromlisttotal`
as two distinct allocation-site labels ("distinct site label ... so
allocation-site reports can still tell the two apart"), and already
updated every consuming test (`byte-set.test`, `immutable-set.test`,
`web-unreserved.test`) to accept `{setfromlist setfromlisttotal}` as
equivalent for census purposes. Confirmed directly against the current
tree (`native/src/codegen/clif.rs:1468-1494`): the site-attribution string
passed to `call_allocating` is literally the same source-code string as
the NIR opcode's own match arm (`"setfromlist"` / `"setfromlisttotal"`),
so the label is not a separate, driftable instrumentation artifact --
splitting it from the opcode name would be a larger, riskier change than
this preflight step justifies, and the *only* real `SetFromList`-family
call site in the whole frozen corpus (`byte::set`'s own
`immutable_set_from_list(bytes)`) means no double-counting is even
possible today. No code change made; recorded as already resolved, per the
spec's own explicit escape hatch ("If the current tree has already
resolved this, record that and do nothing").

## Current checked-domain-construction semantics (current architecture)

- `type Byte = Int in 0..255` (`lib/byte.bot`, `SOURCE-DEFINED-INTEGER-DOMAINS.md`):
  a source-declared bounded-integer type. `core::type::CheckedConstruct`
  (`core/type.tcl:276-283`) is the generic, still-present Tcl-level
  membership-check-and-raise implementation, but it is **only ever called
  from Tcl-trusted code** now (nothing registers it as a Botlish-callable
  native) -- confirmed dead from source (see above).
- The one real, reachable "checked construction" in the current language is
  ordinary user code: `byte::from_int(value: int) -> Byte errors
  BelowRange, AboveRange: if value < 0: fail BelowRange else: if value >
  255: fail AboveRange else: value` (`lib/byte.bot:150-157`).
- `hir/completions.tcl` (`STATIC-COMPLETION-PROOFS.md`) computes, for every
  call whose target is an exact statically-known function,
  `effectiveErrors(call)` (a subset of the callee's declared errors, never
  a superset) and `resultRangeFact`, from concrete argument facts reachable
  at that one call site -- including, for a `listloop` over a small literal
  list (`hir::completions::EvalListloop`/`LiteralListOf`), each element's
  own exact literal value. This is a **static-legality** pass: it decides
  which programs compile (a proven-always-failing call is a compile-time
  `KNOWN-ERROR`; a proven-always-safe call needs no handler), never what
  machine code an already-legal program compiles to
  (`STATIC-COMPLETION-PROOFS.md`'s own "Why this is semantic proof, not
  optimization").
- This pass is **deliberately siloed** from `hir/range.tcl` (the
  interprocedural, codegen-facing fixpoint `native/lower.tcl` actually
  consults) -- confirmed both by that milestone's own explicit design
  rationale ("Building that specifically inside `hir/range.tcl`'s own
  shared `If`/`Expr`/`AnalyzeInstance` was rejected deliberately ...
  teaching it new precision risks silently changing generated code") and,
  freshly here, by grep: `effectiveErrors`/`resultRangeFact`/
  `mayReturnNormally` appear in exactly `hir/completions.tcl` (the pass
  itself), `hir/errorsets.tcl` (the legality checker consuming
  `effectiveErrors`), and `audit/comprehensive-generated-code/tools/probe.tcl`
  (read-only audit tooling) -- **nowhere** in `hir/range.tcl`,
  `hir/specialize.tcl`, or `native/lower.tcl`.

## Real byte::set source path (frozen `lib/byte.bot`, unchanged)

```botlish
fn from_int(value: int) -> Byte errors BelowRange, AboveRange:
    if value < 0:
        fail BelowRange
    else:
        if value > 255:
            fail AboveRange
        else:
            value

fn set(chars: List[UnicodeChar]) -> ImmutableSet[Byte] errors AboveRange:
    bytes = loop c in chars:
        from_int(char::codepoint(c))
    immutable_set_from_list(bytes)
```

## Caller list-literal fact

`['-', '.', '_', '~']` is `List[UnicodeChar]`, an ordinary List literal of
four exact `UnicodeChar` constants. Nothing about the *list value's own
static type* encodes the four values (`hir::typeOf` on the literal gives
`List[UnicodeChar]`, the same type any other four-character literal would
get) -- the exact contents are a *separate* fact, tracked (only) by
`hir/completions.tcl`'s own `ctx.exactList`/`LiteralListOf` machinery for
this one call's own literal-list argument, confirmed by that pass's own
documented mechanism, not inferred by us.

## byte::set call-site fact (module-init call)

Measured directly, against a fresh, real
`additional_unreserved_chars = byte::set(['-', '.', '_', '~'])` program:

```
outer call node (top-level bind's RHS): effectiveErrors = {}
```

Confirmed via `hir::completions::effectiveErrorsOf`/direct HIR node
inspection (`dict get $node effectiveErrors`), not assumed. This is a real,
existing compiler result (STATIC-COMPLETION-PROOFS.md's own worked
example, re-verified here fresh) -- **not** something this milestone had to
add.

## byte::set parameter-instance fact / listloop element fact / char::codepoint fact

Measured on the *same* program, at `byte::set`'s own inner call
`from_int(char::codepoint(c))` (`lib/byte.bot:176`, and the nested
`char::codepoint(c)` at the same line):

```
inner from_int call node:        effectiveErrors = {AboveRange}   (BelowRange already
                                   pruned, generically, from char::codepoint's own
                                   nonneg fact -- unrelated to the literal-list question)
nested char::codepoint(c) node:  resultRangeFact = [0, 1114111]   (the full Unicode
                                   scalar domain -- NOT narrowed to {45,46,95,126}
                                   or even to [45,126])
```

This is the **exact same pair of facts** `byte::set`'s own body carries
when checked completely generically (e.g. from a program that only calls
`byte::from_int(45)` and never mentions `byte::set`'s own literal call at
all) -- confirmed by comparing the two probes byte-for-byte. **This is the
exact first-loss location, precisely characterized**: `hir::completions::
checkBlock` walks `byte::set`'s own function *body* exactly once, under
`chars` unseeded/generic, and stamps that single walk's own facts onto the
inner HIR nodes (`e77`/`e79` in this probe). The *separate*, call-specific
recursive proof (`analyzeBlock`, seeded with the four literal values) that
correctly derives the *outer* call's `effectiveErrors = {}` is a pure,
transient computation -- it produces the right answer for the outer call's
own legality check, but it has no HIR node of its own to write the
narrower per-call fact back into, and no consumer downstream of
`hir/completions.tcl` would read it even if it did. The loss is not at the
listloop/container boundary in the sense of "the value-set fails to
propagate at all" (it *does* propagate, correctly, all the way to a real
proof of `effectiveErrors={}` for the one call that needs it) -- it is at
the boundary between two lattices: the one that decides *legality*
(`hir/completions.tcl`) and the one that decides *code generation*
(`hir/range.tcl`/`native/lower.tcl`), which never communicate, by explicit,
documented design.

## Byte-checked-construction fact / resultRangeFact / effectiveErrors trace

See tables above; summarized as the spec's own required trace:

| stage | semantic type | nominal/refined type | numeric interval | exact finite set | resultRangeFact | effectiveErrors |
|---|---|---|---|---|---|---|
| `['-','.','_','~']` (caller) | `List[UnicodeChar]` | same | -- | not in the *type*; tracked only in `hir/completions.tcl`'s own `ctx.exactList` | n/a | n/a |
| `chars` (byte::set's own parameter, generic body check) | `List[UnicodeChar]` | same | -- | none (unseeded) | n/a | n/a |
| `c` (listloop element, generic body check) | `UnicodeChar` | same | -- | none (unseeded) | n/a | n/a |
| `char::codepoint(c)` (generic body check) | `int` | same | `[0, 1114111]` | none | `[0, 1114111]` | (native, no declared errors) |
| `from_int(char::codepoint(c))` (generic body check) | `Byte` | same | `[0,255]` on success | none | `{min 0 max 255}` (success value) | `{AboveRange}` |
| `byte::set(['-','.','_','~'])` (the one real call that matters) | `ImmutableSet[Byte]` | same | n/a | n/a | n/a (non-Int result) | `{}` |

## Q1: local literal checked construction control

Fresh, direct measurement against the real, unmodified `lib/byte.bot`
(`tests/checked-domain-proof-provenance.test`,
`checked-domain-q1-real-byte-from-int-45-effective-errors-empty`/
`-still-emits-both-checks`):

- `byte::from_int(45)`'s own call node: `effectiveErrors = {}`,
  `resultRangeFact = [45, 45] {45}` -- the HIR-level proof genuinely
  exists, and is exact (a singleton).
- `byte::from_int<int>`'s own generated NIR (real production body, via
  `native::lower::program` on a real `.bot` file), regardless: still
  contains **both** `op rilt`/`op rigt` comparisons and **both**
  `faildeclared "BelowRange"`/`faildeclared "AboveRange"` blocks,
  unconditionally.

Answer: **no**, a locally obvious literal does not eliminate/falsify the
generated-code range check today -- confirmed against the real production
`byte::from_int`, not a synthetic look-alike, and reconfirmed generically
(non-Byte) via `checked-domain-q1-generic-domain-literal-still-emits-both-checks`
(a second bounded domain, `Small = Int in 10..20`, same result). This
exactly reproduces `COMPREHENSIVE-GENERATED-CODE-AUDIT.md`'s own probe D
finding (`from_int(45)`: entry range `[45,45]{45}`, both compares, both
fail paths, 118 bytes), unchanged by any of the intervening milestones.

Per decision-tree item 46, **Q1 = no** routes to "investigate checked-
constructor proof consumption locally first" -- done, directly, below.

## Q2: range-proven nonliteral control

`checked-domain-q2-partial-range-elimination-effective-errors`/
`-still-emits-both-checks`: a value statically known `>= 10` (but not
upper-bounded) needs only a `TooLarge` declaration (HIR-level proof
narrows correctly, mirroring `STATIC-COMPLETION-PROOFS.md`'s own
`nonneg`/`byte::from_int` shape generically). The generated NIR for the
shared `checkedSmall<int>` instance, regardless, still contains **both**
`faildeclared "TooSmall"` and `faildeclared "TooLarge"` blocks.

Answer: **no** -- the same RC2 gap. There is exactly **one** shared NIR
instance per `{block, argument-kind}` (confirmed by
`checked-domain-shared-instance-from-int`: `byte::from_int(45)` and a
genuinely dynamic `byte::from_int(m: int)` caller produce exactly one
`func ... "byte::from_int"` header, not two), so even where
`hir::range`'s own *instance-level* joined entry range is informative
(e.g. `[0,+∞]`, a real, retained fact), no mechanism ever asks it whether
a specific comparison is decided.

## Q3: real byte::set result

**Does the real `byte::set` inner constructor receive a fact strong enough
to eliminate the check? No.** Measured three ways, all on the real,
current, unmodified `lib/byte.bot`, via the actual production module
initializer shape:

1. HIR fact trace (above): the inner `from_int`/`char::codepoint` nodes
   carry only the generic `[0, 1114111]`/`{AboveRange}` facts, never the
   caller's own narrower literal-derived proof.
2. Real generated NIR (`checked-domain-q3-real-nir-retains-both-checks`):
   `byte::from_int<int>`'s own body, lowered from the real
   `additional_unreserved_chars = byte::set(['-','.','_','~'])` program,
   still contains both compares and both fail paths.
3. Shared-instance adversarial control
   (`checked-domain-shared-instance-byte-set`): the all-safe module-init
   call and a genuinely dynamic, handled `byte::set(chars)` call share
   **one** `byte::set` NIR instance (one `func ... "byte::set"` header),
   confirming that even a hypothetical future per-instance optimization
   could not soundly special-case this shared instance's own inner
   construction without becoming unsound for the dynamic caller.

## Exact first-loss location

The boundary between `hir/completions.tcl` (the call-specific static
*legality* proof, which correctly reaches the exact caller literal values)
and `hir/range.tcl`/`native/lower.tcl` (the codegen-facing lattice, which
never reads `hir/completions.tcl`'s output at all). This is a deliberate,
documented architectural silo (`STATIC-COMPLETION-PROOFS.md`'s own "Path-
sensitive range facts" section), not an oversight -- and, independently of
that silo, `native::lower::If` does not consult *even `hir::range`'s own*
facts for branch elimination (`RC2`), so repairing the silo alone would
not be sufficient to close this gap; both would need to change, and the
second is a general optimizer feature (see "Outcome A implementation" --
none -- below).

## Outcome A implementation: none

No proof-consumption repair was made. The one case spec item 47 explicitly
permits fixing even under Outcome B -- "local checked-constructor proof
consumption is itself missing" -- is exactly what Q1/Q2 found, but it is
not a narrow, checked-construction-scoped defect: it is `native::lower::
If`'s own general branch-reachability decision (used by *every* `if` in
the language), which only ever consults `hir::types::KnownOutcome`
(purely syntactic/type-level), never `hir::range`. Teaching it to consult
`hir::range` for dead-branch elimination is a general, shared-fixpoint
optimizer feature -- explicitly the kind of change `STATIC-COMPLETION-
PROOFS.md` itself already declined to make in the adjacent, more
favorable position (that milestone already has both a proof *and* a
value-set representation for the relevant facts, and still chose not to
feed them into codegen). It is not "the smallest existing mechanism," it
has no existing narrow analogue (M1/M3/M4's own opcode-selection-by-
static-type-predicate shape does not generalize to a *value*-dependent
branch), and its blast radius is every `if` in the compiler, not
`byte::set`. Per this milestone's own scope (forbidding "general constant
propagation," and by the same principle, general branch-elimination
machinery introduced as a side effect of a four-character audit), this was
correctly left alone.

## HighNibble / non-contiguous-domain soundness control

`checked-domain-highnibble-membership-exact-not-interval`: `HighNibble`'s
own domain is the 16-value exact set `{0,16,...,240}`, a *subset* of its
own `[0,240]` interval hull. `17` lies inside that interval hull but is not
one of the 16 exact members. `core::type::validate` (the one generic
runtime membership check every `NAME?` predicate -- and any future
checked-construction proof consumer -- would have to share) correctly
rejects `17` and accepts `16`/`240`/`0`, confirmed directly against the
real, unmodified `lib/byte.bot` registration. (Note: `NAME?` predicates
have no Botlish source spelling at all -- `surface/lexer.tcl` rejects a
trailing `?` as "reserved and cannot be part of a name" -- a separate,
pre-existing, unrelated limitation this milestone neither touches nor
needs to; the check above is exercised at the `core::type` layer directly,
per spec item 58's own "test at the appropriate analysis layer if
necessary".) Since Outcome B adds no new proof consumer, there is no
latent unsoundness introduced by this milestone for a future one to
inherit; this control exists to confirm that if a future milestone ever
does teach a consumer to use `hir::range`-level facts for checked
construction, the *existing* exact-vs-interval membership machinery
underneath it is already sound and would not need to be built from
scratch.

## byte::set runtime failure preservation

- `checked-domain-byte-set-astral-known-error-at-compile-time`:
  `byte::set(['Ā'])` remains a compile-time `KNOWN-ERROR` under ordinary
  compilation.
- `checked-domain-byte-set-astral-still-fails`: with that compile-time
  proof bypassed (`-strict 0`, matching `tests/byte-set.test`'s own
  established `moduleErrorKinds` technique), the underlying runtime
  operation still fails (`error`) on every backend -- unaffected, matching
  `tests/byte-set.test`'s own pre-existing, unmodified
  `byte-set-boundary-256-fails`/`byte-set-astral-fails`.
- `tests/byte-set.test` itself: 21/21, unchanged.

## Generated-code before/after

**No change.** `uri-steady`: 17 NIR functions, 7103 machine-code bytes
(re-measured fresh against the current tree; byte-for-byte identical to
M4's own post-M4 number). `web-unreserved-256`: 16 NIR functions, 15433
bytes (identical to M4's own post-M4 number). `byte::from_int`'s own body,
in both the real production shape and every synthetic control, retains
both `rilt`/`rigt` compares and both `faildeclared` blocks.

## Effects before/after

No change. `byte::set`'s own `SetFromList` call remains `setfromlisttotal`
(`checked-domain-m4-control-byte-set-still-setfromlisttotal`), `may_error`
unaffected. `byte::set` as a whole and `<program> -> byte::set` remain
`may_error=true` (via `byte::from_int`'s genuinely-necessary `AboveRange`
check), exactly as M4 left them.

## Allocation / GC / roots consequences

No change (no production code touched). Corpus census
(`checked-domain-corpus-census-single-real-call-site`): `from_int(` occurs
as a real call exactly once in the whole frozen corpus (`lib/byte.bot:176`,
inside `byte::set`'s own loop) -- module-initialization-only, confirming
any future proof-consumption work here would only ever pay rent at
startup, never in the request-serving path.

## M1-M4 regression controls

- M1: `tests/typed-parameters.test` 50/50, `tests/hir-specialize.test`
  27/27 -- both unchanged (see "Full regression" below for exact counts).
- M2: `tests/hir-callable-target.test` 8/8, `tests/typed-callable-escape.test`
  35/35 -- unchanged.
- M3: `tests/setcontains-equality-total.test` 17/17 -- unchanged;
  `web::is_unreserved`'s own `SetContains` call still `setcontainstotal`.
- M4: `tests/setfromlist-equality-total.test` 14/14 -- unchanged;
  `byte::set`'s own `SetFromList` call still `setfromlisttotal`
  (re-confirmed above); `byte::set(['Ā'])` still fails.

## Full regression

- `tclsh9.0 tests/all.tcl` (interp + compile backends, native backend
  freshly built with `cargo build --release --manifest-path
  native/Cargo.toml` under `rustup`-installed stable 1.98.1, per this
  repo's own pinned-Cranelift-version requirement): **2173/2173 passed, 0
  failed**, both backends (2156 pre-existing M4 baseline + 17 new
  `tests/checked-domain-proof-provenance.test` tests).
- `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passed**, unchanged.
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **2173/2173 passed,
  0 failed**, both backends -- identical to the plain run, as expected
  (this milestone touches no allocation/GC/rooting path at all: no
  production code changed).
- Targeted files with exact counts: `tests/byte-set.test` 21/21,
  `tests/errors.test` 40/40, `tests/source-types.test` 46/46,
  `tests/setfromlist-equality-total.test` 14/14,
  `tests/setcontains-equality-total.test` 17/17,
  `tests/hir-specialize.test` 27/27, `tests/typed-parameters.test` 50/50,
  `tests/hir-callable-target.test` 8/8 (all unchanged from their
  pre-M5 counts).

## Source-fence confirmation

`git status --porcelain` before this milestone's own commit shows exactly
two new files: `tests/checked-domain-proof-provenance.test` and this
report. No `.bot`/`.ir`/`.hir` file has any diff. No `hir/`, `core/`,
`native/`, `surface/`, or `compiler/` file has any diff. The FINAL
SEMANTIC SOURCE FENCE remains intact.

## Post-M5 residual first-loss matrix

| fact | before M5 | after M5 |
|---|---|---|
| `byte::set(['-','.','_','~'])`'s own outer-call `effectiveErrors` | `{}` (already proven, STATIC-COMPLETION-PROOFS.md) | unchanged, `{}` |
| `byte::set`'s own inner `from_int`/`char::codepoint` node facts | generic, unseeded (`[0,1114111]`/`{AboveRange}`) | unchanged |
| `hir/completions.tcl` -> `hir/range.tcl`/`native/lower.tcl` fact flow | none (siloed by design) | unchanged |
| `native::lower::If` branch-reachability source | `hir::types::KnownOutcome` only, never `hir::range` | unchanged (RC2) |
| `byte::from_int<int>`'s own generated NIR (real corpus and every synthetic control) | both compares, both fail paths, unconditionally | unchanged |
| `byte::set`/`byte::from_int` aggregate `may_error` | `true` (via `AboveRange`) | unchanged |
| `byte::set(['Ā'])` | `KNOWN-ERROR` at compile time; runtime `AboveRange` if bypassed | unchanged |
| Machine-code size (`uri-steady`/`web-unreserved-256`) | 7103B/17 funcs, 15433B/16 funcs | unchanged |
| Family 1b (`StringRegion` scanner-index guards) | unaddressed | unaddressed, carried forward |

## Recommended next milestone

Two independent, evidenced candidates, neither implemented here (matching
M4's own "Recommended next milestone" section, since neither has moved):

1. **General range-based branch elimination in `native::lower::If`** (the
   actual, general form of RC2/Q1/Q2's finding): teaching the shared `If`
   lowerer to consult `hir::range`'s own decidability (not merely
   `hir::types::KnownOutcome`) before emitting a branch. This is larger
   and more general than any single milestone in the M1-M5 arc so far --
   it touches every `if` in the compiler, is pinned by the golden-file
   assembly audits (`SCALAR-ASM-AUDIT.md`), and would need its own careful
   scoping (soundness for non-contiguous/exact domains, interaction with
   the tiny-leaf inliner, interaction with `hir::range`'s own 32-value
   exact-set budget) before it could be attempted safely. Closing it would
   make `byte::from_int(45)`'s own callee body branch-free, and, via
   ordinary existing effect propagation (the M1-M4 arc's own established
   pattern), would very likely make `byte::set`'s own aggregate
   `may_error` `false` for the one real corpus call, *without* ever
   needing to feed `hir/completions.tcl`'s own literal-list facts into
   codegen at all -- the caller-specific literal values are not actually
   necessary for this: `char::codepoint`'s own registered `nonneg`
   `hir::range` fact plus a `[0,255]`-provable *result* type would already
   be enough for `native::lower::If` to decide `value > 255` is undecided
   in general but that a smaller closed corpus of individually-analyzed
   calls could be proven safe once branch decidability itself works from
   range facts.
2. **Family 1b** (`refined-checks`/`uri-steady`'s own `StringRegion`
   scanner-index guards): unaffected by M3, M4, or this milestone, still
   the largest remaining *class* of guard machinery in this workload,
   carried forward unchanged since M1's own original identification.

Per the milestone's own explicit instruction (spec item 81), this report
does **not** propose a general constant-container/literal-propagation
framework merely to optimize away four retained URI punctuation
characters' worth of module-init-only range checks -- the measured cost
(one function, `byte::from_int<int>`, 118-337 bytes depending on
representation, executed once at module load in the real corpus) does not
justify inventing new interprocedural machinery, and candidate 1 above,
if ever pursued, would benefit every checked-domain construction and every
ordinary comparison in the language, not just this one call.

## Guiding principle carried forward

M1 showed: repair a forgotten fact. M2 showed: verify the supposed loss
exists before optimizing it. M3/M4 showed: distinguish generic fallibility
from statically impossible failure modes. M5 adds: a fact can be
*correctly proven* by one pass (here, `hir/completions.tcl`, for legality)
and still never reach a second pass that could act on it for a completely
different purpose (code generation) -- because those two passes were
deliberately built not to talk to each other, for good, load-bearing
reasons (protecting a golden-file-audited codegen fixpoint from silent
behavioral drift). The source being obviously constant to a human, and
even the compiler *proving* it to itself for one purpose, does not mean
a *different* part of the same compiler has that fact. Trace the proof to
its actual consumer, not merely to where it is first established.

## Required architecture questions (spec section 74)

1. **What does the compiler know about `['-', '.', '_', '~']` at its
   construction site?** `List[UnicodeChar]`, exact length 4, four exact
   literal `UnicodeChar` values -- the *type* encodes only
   `List[UnicodeChar]`; the four values are a separate fact, tracked only
   by `hir/completions.tcl`'s own `ctx.exactList`.
2. **Does the specialization key for `byte::set` contain those values?**
   No -- confirmed: `hir/specialize.tcl` has zero diff, and the shared-
   instance control shows one `byte::set` NIR instance regardless of
   caller literal contents.
3. **What is `chars`'s type/fact inside the selected `byte::set`
   instance?** `List[UnicodeChar]`, generic, unseeded by caller contents.
4. **What is `c`'s type/fact inside the listloop?** `UnicodeChar`, no
   finite-value fact (confirmed: the generic body-check's own facts for
   the inner calls are the same with or without a literal caller).
5. **What exact fact does `char::codepoint(c)` produce?** `resultRangeFact
   = [0, 1114111]` (the Unicode scalar domain), inside `byte::set`'s own
   generic body check -- not narrowed to the caller's four values.
6. **What exact fact reaches `Byte`/`from_int`'s construction?**
   `effectiveErrors = {AboveRange}` (BelowRange already pruned
   generically); no value-specific fact beyond that reaches it for the
   real call.
7. **Does that fact prove membership in Byte's domain?** No -- it proves
   only that `BelowRange` is impossible, not that `AboveRange` is.
8. **Can the same `byte::set` instance receive `'Ā'`?** Yes -- confirmed
   directly (`checked-domain-shared-instance-byte-set`): the all-safe
   literal call and a dynamic, handled call share one instance.
9. **If yes, how could marking its inner construction globally safe
   possibly be sound?** It could not, without a call-specific (not
   instance-wide) mechanism -- which is exactly what `hir/completions.tcl`
   already *proves* for the outer call, but which never reaches the inner
   construction for codegen purposes (the central finding of this report).
10. **Where is the first point at which the four caller literal values
    cease to be represented?** They never cease to be *represented*
    within `hir/completions.tcl`'s own proof of the outer call; they are
    simply never *written* anywhere the inner nodes, or any codegen pass,
    could read.

## Required local-proof questions (spec section 75)

11. **Does `byte::from_int(65)`-shape emit a runtime range check before
    this milestone?** Yes (confirmed against the real `byte::from_int(45)`).
12. **Does it after?** Yes -- unchanged; no production code changed.
13. **Does a nonliteral value with an existing proven range still emit a
    check?** Yes (`checked-domain-q2-still-emits-both-checks`).
14. **Does a broad Int still emit a check?** Yes.
15. **Does an out-of-range literal preserve current failure/rejection
    behavior?** Yes -- `byte::from_int(999)` remains a compile-time
    `KNOWN-ERROR` (`checked-domain-q1-out-of-range-literal-still-known-error`).
16. **Is the (absent) proof generic over source-defined integer domains?**
    N/A -- no proof-consumption change was made; the *existing*
    `hir/completions.tcl` proof itself is already generic (demonstrated on
    a second, non-Byte domain in every fixture above).
17. **Is Byte special-cased by name?** No, anywhere in this milestone's
    own (test-only) diff.

## Required soundness questions (spec section 76)

18. **Precondition fact or postcondition?** N/A -- no new consumption was
    added. `hir/completions.tcl`'s own existing proof is precondition-based
    (`ComparisonNarrowing` on the argument's own range before the branch).
19. **Is `effectiveErrors` used as proof of impossibility?** Only by
    `hir/errorsets.tcl`'s own pre-existing, unmodified legality check --
    exactly its designed purpose, unrelated to this milestone.
20. **Can interval reasoning incorrectly accept a non-contiguous domain?**
    No latent risk was introduced (no new consumer added); the existing
    `core::type::validate` machinery underneath any future consumer is
    confirmed exact-domain-sound (`checked-domain-highnibble-membership-exact-not-interval`).
21. **Is arbitrary-precision Int correctly distinguished from "fits
    machine integer"?** Unaffected; no representation code touched.
22. **Are runtime RANGE failures still observable?** Yes, confirmed
    (`checked-domain-byte-set-astral-still-fails`).

## Required real byte::set questions (spec section 77)

23. **Does the real punctuation initializer's inner construction become
    non-erroring?** No.
24. **If yes, what pre-existing proof justified it?** N/A.
25. **If no, what is the exact missing fact?** A codegen-visible
    (`hir::range`-level, or better) proof that `char::codepoint(c) <= 255`
    for this exact call, *and* a branch-reachability mechanism in
    `native/lower.tcl::If` capable of consuming it -- neither exists.
26. **Does `byte::set` as a whole become `may_error=false`?** No.
27. **Does `<program> -> byte::set` lose a completion retest?** No.
28. **Does `byte::set(['Ā'])` still fail?** Yes.
29. **Does `byte::set(['A','Ā'])` still fail left-to-right?** Yes
    (unaffected; `tests/byte-set.test`'s own pre-existing
    `byte-set-mixed-failure`, re-run, unchanged).
30. **Are allocations unchanged?** Yes (7103B/17 funcs, 15433B/16 funcs,
    byte-for-byte identical to M4's own post-M4 numbers).

## Required scope questions (spec section 78)

31. **Was `KeyType` changed?** No.
32. **Was listloop changed to propagate container contents?** No.
33. **Was `byte::set` source changed?** No.
34. **Was `char::codepoint` semantics changed?** No.
35. **Was checked construction globally weakened?** No -- none exists to
    weaken (removed by EXPLICIT-ERROR-COMPLETIONS.md); the one reachable
    checked-domain function, `byte::from_int`, is untouched.
36. **Was a new constant-container abstraction introduced?** No.
37. **Was inlining changed?** No.
38. **Was closure specialization changed?** No.
39. **Was family 1b touched?** No.
40. **Was any frozen `.bot`/`.ir` workload changed?** No.

## Stop condition reached (Outcome B, spec section 80)

1. The real punctuation caller has locally obvious constant values --
   confirmed.
2. Those values are not represented as a usable fact at the inner
   `from_int`/`char::codepoint` calls -- confirmed directly (HIR node
   inspection).
3. The exact boundary where that information stops being usable is
   documented above: between `hir/completions.tcl`'s own private,
   call-specific proof and every codegen-facing pass, which never reads
   it -- a deliberate, documented architectural silo, not an oversight.
4. The same `byte::set` instance can legally process out-of-range
   `UnicodeChar` values -- confirmed (shared-instance control).
5. The inner checked construction remains genuinely fallible for that
   instance -- confirmed (real NIR still checks and can fail at runtime).
6. No container-content specialization, loop unrolling, inlining-policy
   change, or constant-list propagation was added.
7. Local checked-constructor proof consumption was independently tested
   (Q1/Q2) and found already-absent generically (`native::lower::If`'s own
   `RC2` gap) -- correctly left alone, since fixing it is a general
   optimizer feature, not a narrow local repair.
8. Full regressions pass (2173/2173 Tcl, 60/60 Rust; GC-stress reported
   separately once complete).
9. The FINAL SEMANTIC SOURCE FENCE remains intact.
10. The next milestone is selected from a fresh residual census (general
    range-based branch elimination in `native::lower::If`; family 1b), not
    by forcing this startup-only optimization.
