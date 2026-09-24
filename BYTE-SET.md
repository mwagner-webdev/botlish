# byte::set: UnicodeChar -> checked Byte -> ImmutableSet[Byte]

## Outcome

`byte::set(chars: List[UnicodeChar]) -> ImmutableSet[Byte]` is implemented
in `lib/byte.bot`, as ordinary Botlish library code:

```botlish
fn set(chars: List[UnicodeChar]) -> ImmutableSet[Byte]:
    bytes = loop c in chars:
        Byte(char::codepoint(c))
    immutable_set_from_list(bytes)
```

Auditing the current surface language against this milestone's own
algorithm ("for every element of this List, transform it and accumulate a
result") found no existing general construct for it: the pre-existing
`loop:` repeats its body until `break`, with no per-element binding and no
way to carry a value across iterations. The smallest coherent extension —
`loop x in EXPR:`, a List traversal that binds `x` fresh each iteration and
collects each iteration's own body value into the result, composing
unchanged with `break`/`continue`/`return`/error propagation — was added to
the existing loop family (not a second control-flow subsystem), lowered
directly to existing HIR/core-IR/NIR primitives with no new runtime object
model. This closed a real gap: without it, `byte::set` would have needed
either recursion or hand-rolled index/accumulator plumbing, both explicitly
forbidden by the brief.

Everything else — `char::codepoint`, checked `Byte(...)` construction,
`immutable_set_from_list` — is pre-existing, unmodified machinery, reused
exactly as documented. The one real gap the milestone's own audit uncovered
and closed was **native (Cranelift) support for checked construction of a
source-defined *interval*-domain integer type over a genuinely dynamic
value** — previously `NATIVE UNSUPPORTED` for every such type, Byte
included (SOURCE-DEFINED-INTEGER-DOMAINS.md's own documented, pre-existing
limitation). `byte::set` needs exactly this (`char::codepoint(c)` is never a
compile-time constant), so it was implemented generically, with no
Byte-specific native path.

Full regression, native/Cranelift parity, and GC stress are reported below
under "Full regression / GC stress".

## `byte::set`'s own source, reviewed against item 65's question

> Would we want ordinary Botlish programmers to write this algorithm this
> way?

Yes. `bytes = loop c in chars: Byte(char::codepoint(c))` reads exactly like
the algorithm it implements — for every char, observe its codepoint,
checked-construct a Byte — with no recursion, no manual index, no repeated
domain-range checks, and no branch ladder. `immutable_set_from_list(bytes)`
is the same generic List-to-set conversion every other `ImmutableSet`
consumer already uses. Nothing here is contorted for machine-code reasons;
see "Generated-code baseline" below for what that costs today, deliberately
left unaddressed by this milestone.

## UnicodeChar -> codepoint -> Byte semantics

For every input `UnicodeChar` `c`:

```
c
    |  char::codepoint(c)         -- total, never fails (core/unicodechar.tcl)
    v
n : Int                            -- the ordinary Unicode scalar value
    |  Byte(n)                    -- explicit checked construction
    v
b : Byte                           -- success (0 <= n <= 255), or
    RANGE failure                  -- n outside 0..255
```

`'A'` (U+0041) -> `65` -> `Byte(65)` succeeds. `'é'` (U+00E9) -> `233` ->
`Byte(233)` succeeds. `'ÿ'` (U+00FF) -> `255` -> `Byte(255)` succeeds (the
domain's own upper boundary). `'Ā'` (U+0100) -> `256` -> `Byte(256)` fails.
`'😀'` (U+1F600) -> `128512` -> `Byte(128512)` fails. No arithmetic, no
truncation, no masking: `Byte`'s checked constructor either returns the
value unchanged (now refined `Byte`) or raises; there is no third outcome.

## Existing checked-constructor mechanism (item 5, architecture Q1)

**Byte's own checked constructor already existed** (`type Byte = Int in
0..255`, `lib/byte.bot`, from SOURCE-DEFINED-INTEGER-DOMAINS.md): every
source-declared integer-domain type automatically gets a native constructor
`NAME(x)` via `core::type::declareIntConstructor` -> `core::type::
CheckedConstruct`, the one generic implementation every such type shares
(never a per-type native). `byte::set` calls this exact, pre-existing
mechanism (`Byte(char::codepoint(c))`) — no new checked-constructor
machinery, no second spelling, no Byte-specific conversion helper was
added anywhere in this milestone.

## Native checked-constructor support: the one real gap this milestone closed

**Before this milestone**, `Byte(x)` (and every other source-declared
integer-domain constructor) was `{NATIVE UNSUPPORTED {native Byte}}` on
Cranelift/cranelift-generic for *any* value, even a value trivially in
range like `Byte(0)` — the constructor had no native lowering at all
(SOURCE-DEFINED-INTEGER-DOMAINS.md's own documented limitation: "Cranelift's
pre-existing limitation — checked constructors have no native lowering —
carries over unchanged"). `byte::set`'s own `Byte(char::codepoint(c))` is
exactly the case that limitation would have blocked: `char::codepoint(c)`
is a genuinely dynamic value (never a compile-time constant for a runtime
`List[UnicodeChar]` argument), so `byte::set` could not have compiled
natively at all without fixing this.

**The fix** (`native/lower.tcl`'s new `CheckedIntDomainConstruct`, ~45
lines) is composed *entirely from existing NIR forms* — no new NIR
instruction, no Rust codegen change, no new runtime helper:

```tcl
proc native::lower::CheckedIntDomainConstruct {fnVar e node name meta argRegs} {
    set impl [dict get $meta impl]
    if {[lindex $impl 0] ne "core::type::CheckedConstruct"} { return "" }
    set typeName [lindex $impl 1]
    set domain [dict get [core::type::metadata $typeName] integerDomain]
    if {[lindex $domain 0] ne "interval"} { return "" }
    lassign $domain _ lo hi
    ... EmitArgGuards (proves the operand is Int, exactly as any ordinary
        native call argument would be) ...
    ... %lo = int LO; %hi = int HI (ordinary Int constants: the domain's
        own bounds are compile-time-known even though the *value* being
        checked is not) ...
    ... %okLo = op ige %v %lo; br; %okHi = op ile %v %hi; br ...
    ... raise RANGE on failure; fall through to the unchanged value on
        success ...
}
```

This is called from `NativeCall`'s existing `{NATIVE UNSUPPORTED}` path,
*before* that diagnostic fires: if the native being called is a checked
int-domain constructor (detected generically, via its own registered
`-impl {core::type::CheckedConstruct NAME}` — never by checking whether
`NAME` is literally `"Byte"`) over an **interval** domain, it is now lowered
this way instead; anything else (an ordinary unsupported native, or a
checked constructor over an **exact** domain such as `HighNibble`) falls
through to the pre-existing diagnostic, completely unchanged.

**Why interval-only, not also exact-domain.** `Byte`'s own domain (`0..255`)
is an interval, and so is the brief's own regression example (`Small = Int
in 0..10`) — both need only this. An interval check is two ordinary Int
comparisons against two ordinary Int constants, expressible with zero new
machinery. An exact-domain check (`HighNibble`'s 16-value finite set)
would need either a chain of equality comparisons or an embedded constant
table — a real, separate piece of engineering this milestone's own
motivating consumer (`byte::set`) never needs, since it only ever
constructs `Byte`. `HighNibble(...)` (and any other exact-domain type)
therefore remains exactly as unsupported on Cranelift/cranelift-generic
as it always was — confirmed directly, not merely asserted:
`native-byte-constructors-cranelift-exact-domain-still-unsupported`
(`tests/native-byte.test`) pins `HighNibble(n)` for a genuinely dynamic `n`
still raising `{NATIVE UNSUPPORTED {native HighNibble}}`.

## Failure/completion semantics (item 8, architecture Q4)

`byte::set` is not total. Any input `UnicodeChar` whose scalar value falls
outside `0..255` propagates the *ordinary*, pre-existing checked-constructor
failure — `{CORE SEMANTIC RANGE}` — the exact same completion `Byte(256)`
already raised before this milestone, with no `byte::set`-specific error
kind, wrapper, or `Result` type invented. On interp/compile the message
names the actual out-of-range value (`"Byte: 256 is not a valid Byte"`); on
Cranelift/cranelift-generic the message is necessarily generic (`"Byte:
value is not a valid Byte"`, since the value cannot be rendered into a
compile-time-fixed NIR `raise` message) — the *kind* (`RANGE`) is identical
on every backend; only the interp/compile message additionally names the
value. `byte::set(['A', 'Ā', 'B'])` fails at `'Ā'`, the first invalid
element in left-to-right order, with no partial result ever constructed or
observable (the failing checked construction aborts the whole `loop`
before `immutable_set_from_list` is ever reached).

## Why this is not UTF-8

`byte::set(['é'])` builds `ImmutableSet[Byte]{233}` — one Byte, the Unicode
*scalar* value of `'é'` (U+00E9) — never the two UTF-8 encoding bytes
`0xC3 0xA9` (195, 169). The whole pipeline (`char::codepoint` ->
`core/unicodechar.tcl`'s own scalar-value accessor; `Byte(...)` -> a plain
range check against `0..255`) never touches UTF-8 encoding at any point;
`encode_utf8`/`strutf8bytes` (the actual UTF-8 byte-list operation,
`core/strings.tcl`) is not called anywhere in this file. Pinned directly:
`byte-set-not-utf8` (`tests/byte-set.test`).

## Iteration audit (items 16-27)

**8. Could `byte::set` be written idiomatically using the pre-existing
loop syntax?** No — audited directly (see "Outcome" above): the
pre-existing `loop:` has no per-element binding and no way to carry a
value out of the loop body except via an explicit, single, unconditional
`break`. Writing `byte::set` with it would have required either recursion
(forbidden by item 17) or a hand-maintained index/accumulator pair built
from `list_get`/`list_length` plus a `MutableArray`-based mutable box —
exactly the "manual index plumbing merely because the surface language
lacks the natural general construct" item 15 forbids.

**9. What form was used?** A new surface form, `loop x in EXPR: BODY`
(`surface/parser.tcl`'s `Loop`), alongside the unchanged bare `loop:`.
Lowers to one new core-IR primitive, `(listloop LIST-EXPR (block (ELEM)
BODY...))` (`core/ir.tcl`), reusing the *existing* `(block PARAMS
BODY...)` shape for the element binding (exactly like an ordinary
function's own parameter list) rather than inventing a new binding
construct.

**11. Does the iterable expression evaluate once?** Yes — pinned with a
side-effect-counting test (`loop-in-iterable-evaluated-once`,
`tests/loop-in.test`): an iterable expression that increments a counter as
a side effect and returns a 3-element List is evaluated once (`ticks == 1`)
regardless of how many times the loop body runs.

**12. Does `List[T]` produce loop binding type `T`?** Yes, with no runtime
check: `hir/types.tcl`'s new `listloop` case reads the iterable's own
already-inferred element type (`hir::types::elementOf`, the *same*
accessor `list_get`/`ImmutableSet` construction already use) and seeds the
element binding's fact directly — exactly how a typed function parameter
already seeds its own binding (STRICT-TYPED-PARAMETERS.md's own model, not
a new one). A broad/unknown-element List gives the binding the broad `any`
type, with no inserted whole-list validation (item 21) — pinned:
`loop-in-broad-element-type`, `loop-in-element-type-list-of-t`.

**13. Is traversal left-to-right?** Yes — pinned directly:
`loop-in-left-to-right` (`tests/loop-in.test`), and every acceptance-table
case above whose result order matters (`byte-set-canonical-payload`,
`byte-set-mixed-failure`'s first-invalid-element ordering).

**14. Do existing break/continue/return/Error semantics compose
unchanged?** Yes, exactly. `break [VALUE]` ends the loop immediately,
`VALUE` (or `unit`) becoming the *whole* listloop's result — overriding
whatever was accumulated so far, identically to a bare `loop:`'s own break
semantics; pinned: `loop-in-break-overrides`/`-break-parity`. `continue`
contributes nothing for that iteration and moves on; pinned:
`loop-in-continue-skips`/`-continue-parity`. `return` inside the body
returns from the *enclosing function*, never merely the loop; pinned:
`loop-in-return-propagates`/`-return-parity`. A failing checked
construction (or any other error) inside the body propagates the ordinary
error completion, with no partial result; pinned:
`loop-in-error-propagates`/`-error-parity`. `break`/`continue` lexical-
boundary rules (cannot cross an ordinary callable boundary) are the
identical, unmodified rule `loops.test` already pins for the bare `loop:`,
verified directly for `listloop` too:
`loop-in-break-outside-callable-boundary`,
`loop-in-continue-outside-callable-boundary`.

**15. Was recursion used?** No — neither in `byte::set` itself nor in any
part of the `listloop` implementation across any backend (interp: an
ordinary `foreach` over the already-evaluated items; compile: a generated
Tcl `foreach`; native: an index/accumulator register pair with a loop
back-edge, item 50's own suggested shape).

**16. Was a generic iterator protocol added?** No. `listloop` accepts
only a `List` iterable (or the broad `list` kind); no `Iterator`,
`Iterable`, `Sequence`, generator, or `yield` concept exists anywhere in
this diff. `ImmutableSet`/`String` remain non-iterable, exactly as before
(items 52-53) — untouched.

**17. Were old `.bot` files globally refactored to use the new
construct?** No. The *only* `.bot` source-fence exception (item 62's
"required for semantic integration") is `byte::set` itself, which could
not exist without it. `byte::high_nibble`/`byte::low_nibble`/`byte::
nibble`/`byte::complement`/`byte::position_low`/`byte::position_high`,
`lib/web.bot`, `lib/char.bot`, `lib/mathish.bot`, and every other existing
`.bot` file are byte-for-byte unchanged (confirmed by `git diff --stat`:
`lib/byte.bot` is the only `.bot` file in this diff, and its own existing
six functions are untouched — only new content was appended). The obvious
future refactor candidate this exposes: any existing recursive List-
traversal helper elsewhere in the corpus could now be rewritten with `loop
x in EXPR:` — deliberately not done here (item 62/78).

## `List[T]` element typing inside iteration (items 12, 20-21)

Implemented in `hir/types.tcl`'s `listloop` case: the iterable's own
already-computed type is read via `elementOf` (the identical accessor
`list_get`, `append`, and `ImmutableSet` construction already share — no
new element-type inference was written). The element binding's fact is
seeded from it (`any` when the element type is unknown/broad), scoped
exactly like a branch/loop fact (saved and restored around the loop, so it
never leaks past it) — reusing the pre-existing `ctx facts`/`Narrow`
machinery unchanged.

## Accumulation strategy (items 26-29, questions 18-20)

**18. How are converted Byte values accumulated?** `bytes = loop c in
chars: Byte(char::codepoint(c))` — the loop's own value *is* the
accumulated `List[Byte]`, built by the `listloop` construct itself (one
List contribution per iteration, in order), never by the Botlish source
manually calling `list_append` in a loop. Internally (interp: an ordinary
Tcl list; compile: a generated Tcl `lappend`; native: `op listappend`
against a loop-carried accumulator register, per item 27's own explicit
preference for the pre-existing canonical persistent List-append
operation) each backend's own accumulation strategy is free to differ —
none of it is visible to, or influenced by, `byte::set`'s own source text.

**19. Does a temporary `List[Byte]` exist?** Yes, explicitly bound to
`bytes` — exactly the idiomatic shape items 12/14 ask for
(`List[Byte]` -> `immutable_set_from_list` -> `ImmutableSet[Byte]`).

**20. Is that considered source-level accidental complexity, or an
intentional representation cost deferred to the audit?** Case A (item
28): the source expression (`bytes = loop c in chars: ...`) is the natural,
idiomatic way to write this algorithm; its representation/allocation cost
(one `List[Byte]` materialized, then consumed once by
`immutable_set_from_list`) is exactly the kind of machine-level question
the later generated-code/representation audit is for, not this milestone.
See "Generated-code baseline" below for the concrete baseline numbers.

## ImmutableSet construction (item 12, questions 21-23)

`immutable_set_from_list(bytes)` — the pre-existing, fully generic native
(MINIMAL-IMMUTABLE-SET.md), completely unmodified. **21. Is ImmutableSet
still using the generic vector representation?** Yes — confirmed by `git
diff` touching no line of `core/immutableset.tcl` or
`native/src/runtime/*.rs`'s set representation. **22. Was a Byte bitmap
added?** No. **23. Was construction fusion added?** No: the temporary
`List[Byte]` (`bytes`) is real, separately allocated, and separately
counted in the allocation baseline below — `immutable_set_from_list` is
called as an ordinary runtime operation on it, never hoisted or fused
away.

## Module retained-value behavior (items 39-42, questions 24-27)

**24. Can `additional_unreserved_chars = byte::set(['-', '.', '_', '~'])`
be retained at module scope?** Yes — pinned directly:
`byte-set-module-retained-value` (`tests/byte-set.test`), with zero
diagnostics and a `setfromlist` allocation count of exactly 1 across two
separate calls to a function reading the retained value.

**25. How is its context-freedom/immutability established?**
`hir::modulebinding.tcl` proves two separate facts (unchanged
architecture, MODULE-BINDINGS.md/UNICODECHAR-MODULE-RETENTION.md's own
model): `ContextExpr` (context-freedom: no ambient/ Impure operation
anywhere in the call graph) and `ImmutableExpr` (structural
immutable-value proof). Both needed one new case each for `listloop`,
mirroring the *existing* `if`/`loop`/`call` cases already there rather
than inventing anything:

```tcl
# ContextExpr: iterable checked in the enclosing context, body walked
# exactly like a bare loop's own body (context-freedom is unaffected by
# which element is currently bound).
listloop {
    set result [ContextExpr $hir [dict get $node iterable] state]
    if {[lindex $result 0] ne "ok"} { return $result }
    return [ContextSequence $hir [dict get $node body] state]
}

# ImmutableExpr: the iterable's own List[T] proof already gives one
# structural proof per item; run the body's own structural proof once per
# item, seeding the element binding with that item's proof each time --
# exactly the generic mechanism item 40 asks for, with no byte::set (or
# even listloop) special-casing beyond "this loop's own shape."
listloop {
    set iterProof [ImmutableExpr $hir [dict get $node iterable] facts active]
    if {[lindex $iterProof 0] ne "ok"} { return $iterProof }
    if {[lindex $iterProof 1 0] ne "list"} {
        return {bad unknown "listloop iterable is not structurally known"}
    }
    set results {}
    foreach itemProof [lindex $iterProof 1 1] {
        set bodyFacts $facts
        dict set bodyFacts [dict get $node elementBinding] $itemProof
        set bodyResult [ImmutableSequence $hir [dict get $node body] bodyFacts active]
        if {[lindex $bodyResult 0] ne "ok"} { return $bodyResult }
        lappend results [lindex $bodyResult 1]
    }
    return [list ok [list list $results]]
}
```

Before this, a bare `loop`'s own `ImmutableExpr` case flatly rejected
*every* loop as `{bad unknown "control-flow result cannot be proven
immutable"}` (a pre-existing, still-unchanged conservative stub for the
bare form, whose result is an arbitrary `break` payload with no generic
proof strategy). `listloop`'s own result is structurally *known* — exactly
the List of each iteration's own proven-immutable contribution — which is
what makes this rule sound and general, not specific to `byte::set` or to
`Byte`: it works for any `loop x in EXPR: BODY` whose iterable and body
are themselves immutable/context-free, independent of element type or
body shape.

**26. Was `byte::set` special-cased by name in modulebinding?** No —
grep-confirmed: neither `hir/modulebinding.tcl` nor any other file in this
diff mentions the string `"byte::set"` or `"set"` as a distinguished
native/function name anywhere in this integration. The rule added is
purely about `listloop`'s own generic shape.

**27. How many times is the set constructed for repeated consumers?**
Once, at module initialization — confirmed by allocation-site evidence
(`setfromlist` allocations == 1 for two separate calls to a function that
reads the retained value), the identical methodology MINIMAL-IMMUTABLE-
SET.md's own `set-module-retained-value` test used.

## Source fence decision (items 62-63, question 17 restated)

Held exactly as instructed: `byte::set` (and the minimal `listloop`
extension it needed) are the *only* new/changed `.bot`-visible surface;
every other existing `.bot` file, including `lib/byte.bot`'s own six
pre-existing functions, is untouched. This preserves the A->B (compiler
improvement, source frozen) vs B->C (source refactor) separation the
later audit needs.

## Generated-code baseline (items 74-75, question — not optimized)

For `byte::set(['-', '.', '_', '~'])`, native lowering (Cranelift):

- **HIR shape**: one `listloop` expression inside `byte::set`'s own
  function body, wrapping one `call Byte(...)` and one `call
  char::codepoint(...)`; the module-level `bind` calls
  `immutable_set_from_list` once on the loop's own result.
- **NIR shape** (`native::lower.tcl`'s `ListLoop`): `listlen`, an
  index/accumulator register pair rebound at the loop's own back edge
  (the same "multi-definition-site register" pattern `if`'s own join
  register already uses — no new representation concept), one `listget`
  per iteration (proven in-bounds by construction, but still an ordinary
  `listget` call — item 51's own "leave elimination to the later audit"),
  one `charcodepoint` call, one interval range check (two `ige`/`ile`
  comparisons plus a conditional `raise RANGE`, `CheckedIntDomainConstruct`
  above), one `listappend` per contributed value, one `setfromlist` at the
  end.
- **Runtime/helper calls**: `listlen`, `listget`, `charcodepoint`,
  `listappend` (repeated once per element), `setfromlist` — five distinct
  helper operations, `listappend` the only one called more than once per
  invocation (once per input element).
- **Allocations**: one `List[Byte]` (`bytes`, grown via repeated
  `listappend` — O(n) `listappend` calls, each of which may itself
  reallocate; the exact asymptotic cost of the *reference*
  `core::lists::append`/`rt_list_append` implementation is unaudited here,
  deliberately: item 28's own Case A), one `ImmutableSet[Byte]`
  (`setfromlist`, O(n^2) dedup scan, MINIMAL-IMMUTABLE-SET.md's own
  documented reference-representation cost, unrelated to this milestone).
- **Major obvious checks**: the interval range check inside
  `CheckedIntDomainConstruct` (unconditional per element — not yet
  eliminated even for a value range analysis could in principle narrow,
  since this lowering does not consult `hir::range` facts at all); a
  `listget` bounds check per element that a correctly generated loop can
  never actually fail (item 51: left for the audit, not eliminated here).

None of this was optimized. No representation change, no bitmap, no
constant-set lowering, no fusion of the temporary `List[Byte]` away — all
explicitly deferred to the later generated-code/representation audit, per
items 74-75's own instruction.

## Backend parity (item 72)

`interp`/`compile`/`cranelift-generic`/`cranelift` agree exactly on every
acceptance-table case (valid conversion at every payload size, the 255
boundary, the 256/astral failures — kind, not message text, since
Cranelift's own `raise` cannot render the actual dynamic value — the mixed
first-failure case, duplicates, and the module-retained set), pinned in
`tests/byte-set.test`'s own `moduleParity`/`moduleErrorKinds` helpers, and
separately for the `listloop` construct on its own (independent of
`byte::set`) in `tests/loop-in.test`.

## Tests

- **`tests/loop-in.test`** (31 cases): the `loop x in EXPR:` construct on
  its own — basic map shape and parity, empty List, one element,
  left-to-right order, `List[T]`/broad element typing, static result type
  (`List[R]`), the iterable evaluated exactly once (side-effect counting),
  `break`/`continue`/`return`/error composition (each with a four-backend
  parity pin), nested loops, the pre-existing lexical break/continue
  boundary rules re-verified for `listloop`'s own scope kind, and (added by
  the follow-up `LISTLOOP-BREAK-TYPE-SOUNDNESS.md` audit) 8 adversarial
  soundness cases pinning that a reachable `break VALUE`/bare `break`
  incompatible with a declared `List[R]` result is rejected at compile
  time, that a compatible `break List[R]` payload verifies and returns the
  payload (not the accumulated prefix) at runtime with four-backend parity,
  that an undeclared incompatible case infers the conservative `any` rather
  than a falsely-precise `List[R]`, and that a no-break listloop keeps its
  exact `List[R]` typing.
- **`tests/byte-set.test`** (21 cases): the full acceptance table (basic,
  empty, single, two forms of duplicate collapsing, the 0/255 boundaries,
  the 256/astral/mixed failures, the canonical four-character payload),
  the UnicodeChar-vs-UTF-8 distinction, membership sanity through the
  pre-existing generic `immutable_set_contains`, the static `ImmutableSet
  [Byte]` result type, UnicodeChar/Int distinctness elsewhere, static
  rejection of `List[str]`/`List[int]` callers (no dynamic scanning),
  module retention (with allocation-site evidence), and the generic
  checked-constructor regression using a synthetic `Small = Int in 0..10`
  type (success and dynamic-failure, four-backend parity).
- **`tests/native-byte.test`** (updated): replaced the now-superseded
  `native-byte-constructors-cranelift-unsupported` pin (which asserted
  `Byte(200)` was native-unsupported — the exact limitation this milestone
  closes) with three new cases: `native-byte-constructors-cranelift-
  supported` (a genuinely dynamic in-range value succeeds natively),
  `-cranelift-range-error` (a genuinely dynamic out-of-range value fails
  RANGE natively), and `-cranelift-exact-domain-still-unsupported`
  (`HighNibble`, an exact-domain type, remains native-unsupported,
  confirming the interval-only scope decision above did not silently widen
  further).

## Full regression / GC stress

```
tclsh9.0 tests/all.tcl                                (interp + compile)
cargo test --release --manifest-path native/Cargo.toml
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
```

- `tclsh9.0 tests/all.tcl` (interp and compile backends, native backend
  built with `cargo build --release --manifest-path native/Cargo.toml`):
  **2008/2008 passing, 0 failed** on each backend (69 test files, 0
  skipped) — 1962 pre-existing (baseline before this milestone) + 2 new
  files (`tests/loop-in.test`, 23; `tests/byte-set.test`, 21) + 2
  test-count changes in `tests/native-byte.test` (one pinned expectation
  replaced by three new cases, net +2), including every pre-existing test
  passing unmodified except the one documented pin update below.
- `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passing** — unchanged from the pre-milestone baseline (no Rust source
  was touched by this milestone at all: the native checked-constructor fix
  is composed entirely from existing NIR forms in `native/lower.tcl`, a
  Tcl file).
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **2008/2008
  passing, 0 failed** on each backend — identical to the ordinary run,
  confirming no rooting/allocation-behavior regression in the new
  `listloop` accumulation path (`List`/`ImmutableSet` construction inside
  a loop, on both the interp's own Tcl-list accumulator and the native
  backend's `listappend`-based one) or in the new native checked-domain
  range-check path.
- **Update (`LISTLOOP-BREAK-TYPE-SOUNDNESS.md` follow-up audit):** 8
  adversarial `listloop`/`break`-typing soundness tests were added to
  `tests/loop-in.test` (23 → 31 cases) with no production code change (see
  that report for the full account). Final counts after that addition:
  `tclsh9.0 tests/all.tcl` **2016/2016 passing, 0 failed** on each backend
  (69 test files, 0 skipped); `cargo test --release --manifest-path
  native/Cargo.toml` **60/60 passing**, unchanged; `BOTLISH_NATIVE_GC_
  STRESS=1 tclsh9.0 tests/all.tcl` **2016/2016 passing, 0 failed** on each
  backend, run in isolation (an earlier run concurrent with the ordinary
  suite produced two spurious, contention-caused failures in unrelated
  exhaustive native-byte tests; re-run alone, both passed).
- One pre-existing test's pinned expectation needed updating, unrelated to
  semantics: `refined-signature-cross-module-1`
  (`tests/refined-signatures.test`) asserts an exact `block(eN)` expr-id
  string from `lib/byte.bot`'s own resolved HIR; adding `byte::set` to the
  end of that file shifted that id (`e2` -> `e7`) the same way any content
  addition to a `.bot` file shifts later expr-id numbering. The asserted
  type (`int[HighNibble]`) and range facts
  (`[0, 240] {0,16,32,...,240}`) are byte-for-byte unchanged; only the id
  offset was updated, with a comment explaining why.

## Deferred (unchanged scope)

ASCII classification, `web::is_unreserved`, and any URI-logic rewrite were
**not** started — `additional_unreserved_chars = byte::set(['-', '.', '_',
'~'])` is retainable and correct, but nothing in `lib/web.bot` was changed
to consume it. No Byte-specific set representation (bitmap, comparison
chain, static lookup table, perfect hash) was added — `ImmutableSet`'s
generic vector representation is untouched. No exact-domain (`HighNibble`)
native checked-construction support was added — that remains a distinct,
separately-scoped limitation. No generic iterator protocol, no `String`/
`ImmutableSet` iteration, and no `var`/general mutable-reassignment feature
were added. No existing `.bot` file besides `lib/byte.bot` was refactored.

## Acceptance table

| INPUT / CALL | RESULT |
|---|---|
| `byte::set(['A'])` | `ImmutableSet[Byte]{65}` |
| `byte::set(['é'])` | `ImmutableSet[Byte]{233}` |
| `byte::set(['ÿ'])` | `ImmutableSet[Byte]{255}` |
| `byte::set(['Ā'])` | checked Byte range failure (`{CORE SEMANTIC RANGE}`) |
| `byte::set(['😀'])` | checked Byte range failure (`{CORE SEMANTIC RANGE}`) |
| `byte::set(['A','Ā','B'])` | failure at `'Ā'`, no partial successful result |
| `byte::set(['A','A'])` | same set as `byte::set(['A'])` |
| `byte::set(["A"])` | compile error: `List[str]` (`{CORE SEMANTIC TYPE}`) |
| `byte::set([65])` | compile error: `List[int]` (`{CORE SEMANTIC TYPE}`) |
| `byte::set(['é'])` | `{233}`, NOT the UTF-8 bytes 195/169 |
| `additional_unreserved_chars = byte::set(['-','.','_','~'])` | retained `ImmutableSet[Byte]{45,46,95,126}`, built once |

## Required architecture questions

1. **What existing checked source-defined-type construction mechanism is
   used?** `NAME(x)` (here `Byte(x)`), `core::type::declareIntConstructor`
   -> `core::type::CheckedConstruct`, unmodified.
2. **Does dynamic `Int -> Byte` checked construction work on every
   backend?** Yes — interp/compile already did; cranelift/cranelift-generic
   now do too (this milestone's own native-support fix, interval domains).
3. **If native support had to be added, is it generic over source-defined
   bounded integer types?** Yes — detected via the native's own `-impl
   {core::type::CheckedConstruct NAME}` registration and the type's own
   `integerDomain` metadata, never by checking `NAME eq "Byte"`; proven
   directly with a synthetic `Small = Int in 0..10` (`tests/native-byte.
   test`, `tests/byte-set.test`).
4. **What failure/completion occurs for codepoint 256?** The ordinary
   checked-constructor `{CORE SEMANTIC RANGE}` completion — no new error
   kind.
5. **Does successful construction preserve semantic type `Byte` and its
   `[0,255]` fact?** Yes — unchanged: `CheckedConstruct` returns the value
   with the same static-type machinery every checked constructor already
   uses; nothing in this milestone touches `hir/range.tcl`'s fact
   derivation.
6. **Was any hidden typed-parameter check introduced?** No.
7. **Is UTF-8 involved anywhere?** No.

## Required iteration questions

8-17: answered in "Iteration audit" above.

## Required collection questions

18-23: answered in "Accumulation strategy" / "ImmutableSet construction"
above.

## Required module questions

24-27: answered in "Module retained-value behavior" above.

## Required scope questions

28. Was ASCII added? No.
29. Was `web::is_unreserved` changed? No.
30. Was URI logic changed? No.
31. Was a Byte bitmap added? No.
32. Was hashing/perfect hashing added? No.
33. Was static constant-set lowering added? No.
34. Was List representation changed? No.
35. Was ImmutableSet representation changed? No.
36. Was Byte representation specialized? No.
37. Were existing `.bot` files broadly modernized? No — only `lib/byte.bot`
    gained new content; its own pre-existing functions, and every other
    `.bot` file in the repository, are byte-for-byte unchanged.

## Stop condition

1. `byte::set` is ordinary, idiomatic Botlish library code — reviewed
   against item 65's own question above: yes.
2. Its input contract is `List[UnicodeChar]` — enforced statically, no
   dynamic element scanning.
3. Each `UnicodeChar` is explicitly observed through `char::codepoint`.
4. Each resulting `Int` is explicitly checked/refined into `Byte` using the
   existing generic source-defined-type construction semantics.
5. Values 0..255 succeed; larger Unicode scalars fail strictly (no
   truncation, masking, replacement, or skipping).
6. No UTF-8 encoding occurs anywhere in this path.
7. The successful result is statically `ImmutableSet[Byte]`.
8. The canonical module-level four-character set is retained once and
   reused.
9. No Byte-specific set representation or machine-code optimization was
   added.
10. The implementation uses neither recursion nor an avoidable branch
    ladder.
11. Existing loop syntax could not express the algorithm naturally
    (audited directly); the smallest general extension — `loop x in
    EXPR:` — was added and tested on its own, independent of `byte::set`.
12. Existing `.bot` files were **not** globally refactored to use the new
    syntax — only `lib/byte.bot` gained new content.
