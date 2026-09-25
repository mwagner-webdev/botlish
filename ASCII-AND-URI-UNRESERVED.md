# ASCII structural classification, and `web::is_unreserved` as ASCII + URI policy

## Outcome

A new `ascii` namespace (`lib/ascii.bot`) supplies five structural ASCII
predicates over `Byte`:

```botlish
fn is_digit(b: Byte) -> bool:
    b >= 48 and b <= 57

fn is_upper(b: Byte) -> bool:
    b >= 65 and b <= 90

fn is_lower(b: Byte) -> bool:
    b >= 97 and b <= 122

fn is_alphabetic(b: Byte) -> bool:
    is_upper(b) or is_lower(b)

fn is_alphanumeric(b: Byte) -> bool:
    is_alphabetic(b) or is_digit(b)
```

`lib/web.bot`'s URI-unreserved classification -- previously a private,
nested, 13-level ascending-threshold `if` ladder inside `uri_escape_text`,
deliberately left untouched by every earlier milestone (BYTE-NIBBLE-BIT-
ARITHMETIC.md, NATIVE-URI-ESCAPE.md, CROSS-MODULE-REFINED-SIGNATURES.md,
BOUNDED-BIT-SHIFT-LOWERING.md, MINIMAL-IMMUTABLE-SET.md) -- is now a
top-level `web::is_unreserved`, expressed exactly as the milestone brief's
own target shape:

```botlish
additional_unreserved_chars = byte::set(['-', '.', '_', '~'])

fn is_unreserved(b: Byte) -> bool:
    ascii::is_alphanumeric(b) or immutable_set_contains(additional_unreserved_chars, b)
```

Both are proven exhaustively correct over all 256 `Byte` values, on all
four backends (interp, compile, cranelift-generic, cranelift), with exact
cardinalities (10/26/26/52/62 for the five ASCII classes, 66 for
URI-unreserved). The existing URI/string consumer workload
(`tests/native-uri-escape.test`'s 18 tests, unchanged) still passes
byte-for-byte. No representation/codegen optimization was performed; a
concrete generated-code baseline was captured for the next milestone
instead (below).

## ASCII API and semantic boundaries

| Predicate | True range | Byte values | Count |
|---|---|---|---|
| `is_digit` | `'0'..'9'` | 48..57 | 10 |
| `is_upper` | `'A'..'Z'` | 65..90 | 26 |
| `is_lower` | `'a'..'z'` | 97..122 | 26 |
| `is_alphabetic` | `is_upper or is_lower` | 65..90, 97..122 | 52 |
| `is_alphanumeric` | `is_alphabetic or is_digit` | 48..57, 65..90, 97..122 | 62 |

No locale dependence, no Unicode categories, no case folding, no UTF-8, no
platform dependence. A high-bit byte (128..255) is an ordinary, valid
`Byte`; every predicate simply answers `false` for it (never an error --
classification is total).

## Final ASCII source

`lib/ascii.bot` in full (see the file itself for the full header
comment):

```botlish
namespace ascii

fn is_digit(b: Byte) -> bool:
    b >= 48 and b <= 57

fn is_upper(b: Byte) -> bool:
    b >= 65 and b <= 90

fn is_lower(b: Byte) -> bool:
    b >= 97 and b <= 122

fn is_alphabetic(b: Byte) -> bool:
    is_upper(b) or is_lower(b)

fn is_alphanumeric(b: Byte) -> bool:
    is_alphabetic(b) or is_digit(b)
```

## Why ASCII operates on `Byte`

ASCII classification here is classification of *byte values* -- exactly
the same layering `byte::`/`char::` already established (byte.bot's own
header: "ASCII/encoding interpretation ... deliberately absent" from
`byte::`, reserved for this milestone). `UnicodeChar` is a Unicode scalar
value (`char::codepoint`'s own domain, up to U+10FFFF); `Int` is
unconstrained; `str` is a sequence of `UnicodeChar`. None of those is "a
byte." `Byte` (`lib/byte.bot`: `type Byte = Int in 0..255`) is the only
one of the four whose domain *is* the ASCII-classification question's own
domain, so it is the only type these predicates could soundly accept
without a hidden, silent range assumption. This also keeps the boundary
with `web::is_unreserved`, whose whole point is classifying UTF-8/URI
*byte* values, coherent: both layers speak `Byte`.

The parameter contract is strict, not merely a convention: `hir/range.tcl`'s
`VerifyCall` checks each call's argument against the callee's *declared*
parameter type using the argument expression's own static facts (interval
or exact-set), not a name-based coercion. A plain `Int` result from a
generic call (`char::codepoint('7')`, statically just `int`, no exact-value
fact) is rejected even though its dynamic value (55) fits; a `UnicodeChar`
or `str` literal is rejected outright (wrong kind); only an argument the
compiler can *prove* lies in `0..255` -- an explicit `Byte(...)`, or (see
below) a literal Int constant with its own provable exact value -- is
accepted. Verified exhaustively in `tests/ascii.test`'s typing/contracts
section and `tests/web-unreserved.test`'s own.

One discovered nuance, worth being explicit about since it is easy to
mis-predict: **a bare Int literal with a provably in-range exact value
(e.g. `ascii::is_digit(48)`) is accepted with no explicit `Byte(...)` at
all.** This is not an implicit `Int -> Byte` *conversion* -- the value
stays an ordinary `Int` expression, never retagged -- it is the same
declared-parameter-type verification succeeding by *proof* rather than by
nominal type identity, the general mechanism `STRICT-TYPED-PARAMETERS.md`
and `hir/range.tcl` already provide for every refined-domain parameter
(the same reason `Small(n)`-style checked constructors already accept a
provably in-range dynamic value elsewhere in this compiler). It does not
weaken the contract the milestone brief cares about: `char::codepoint('7')`
(identical runtime value, 55, but no static exact-value fact, since
`char::codepoint`'s declared result type is plain `int`) is still rejected,
and so is any out-of-range literal (`ascii::is_digit(999)`). See
`tests/ascii.test`'s `ascii-accepts-provably-in-range-literal` and
`ascii-rejects-codepoint-int` for both sides of this pinned side by side.

## Boundary representation choice

The boundary constants (48, 57, 65, 90, 97, 122) are ordinary `Int`
literals, compared directly against the `Byte` parameter with `>=`/`<=`
-- no `Byte(...)` wrapping, no `char::codepoint('0')`-derived boundary.
Three options were weighed (spec item 5):

1. **Plain Int literals** (chosen): `b >= 48 and b <= 57`. `Byte` is `Int
   in 0..255` (an `Int` refinement, not a distinct representation), so an
   ordinary `int`-typed comparison operand needs no conversion at all;
   this is the same pattern `byte.bot`'s own `bit_and(b, 240)` etc. already
   use (plain Int literals compared/combined with a `Byte`-typed `b`).
2. **`char::codepoint('0')`-derived boundaries**: rejected. It would
   introduce a runtime `char::codepoint` call (and a `char::` module
   dependency) purely to re-derive a compile-time constant every reader
   already knows is 48 -- strictly less clear, not more, and exactly the
   kind of "new conversion API solely to make the source prettier" the
   brief rules out (item 5).
3. **Checked `Byte(48)` boundary constants**: rejected. Wrapping a
   compile-time-constant literal boundary in its own checked constructor
   adds a runtime domain check that can never fail and a symbol only
   named for nominal symmetry with the parameter's own type -- no reader
   benefit, and explicitly the case item 7 rules out ("do not wrap every
   boundary in runtime `Byte(...)` merely for nominal symmetry").

Plain literals are the cleanest spelling current semantics support, and
the only one that adds nothing beyond stating the range.

## Exhaustive 0..255 validation

`tests/ascii.test`'s `ascii-exhaustive-truth-table` test builds one
Botlish program (`loop n in [0, 1, ..., 255]: [is_digit(b), is_upper(b),
is_lower(b), is_alphabetic(b), is_alphanumeric(b)]`, `b = Byte(n)`),
evaluates it once under `interp`, and compares every one of the 256 rows
against a Tcl reference model (`n>=48&&n<=57`, etc.) -- 0 mismatches. The
same test pins the composition identities (`is_alphabetic == is_upper or
is_lower`, `is_alphanumeric == is_alphabetic or is_digit`) and pairwise
disjointness (`digit ∩ upper = digit ∩ lower = upper ∩ lower = ∅`) over
the same full sweep, and mandatory boundary values (47/48/57/58, 64/65/
90/91, 96/97/122/123, 0/127/128/255) are pinned individually as their own
tests, each checked on all four backends.

`tests/ascii.test`'s `ascii-backend-parity-256` test re-runs the identical
256-value sweep program under `interp`/`compile`/`cranelift-generic`/
`cranelift` and requires all four outcomes to be textually identical
(`core::value::show`, which also captures any evidence difference) -- they
are.

## ASCII cardinalities

Confirmed exhaustively (not sampled): digit 10, upper 26, lower 26,
alphabetic 52, alphanumeric 62 -- exactly the expected values, over the
full domain, with zero composition/disjointness violations.

## URI-owned punctuation set

`lib/web.bot`:

```botlish
additional_unreserved_chars = byte::set(['-', '.', '_', '~'])
```

Type `ImmutableSet[Byte]`, containing exactly `{45, 46, 95, 126}`
(`'-'`, `'.'`, `'_'`, `'~'`) -- confirmed both by direct membership checks
and, exhaustively, by `web-unreserved-exhaustive`'s full-domain sweep
(`immutable_set_contains(web::additional_unreserved_chars, Byte(n))`
disagreeing with `ascii::is_alphanumeric` for exactly those four bytes, no
others). Built via the exact `byte::set` milestone's own machinery
(`char::codepoint` + checked `Byte(...)` + `immutable_set_from_list`,
unmodified), retained once at module initialization.

## Final `web::is_unreserved` source

```botlish
fn is_unreserved(b: Byte) -> bool:
    ascii::is_alphanumeric(b) or immutable_set_contains(additional_unreserved_chars, b)
```

`esc_char` (`uri_escape_text`'s one call site) now reads:

```botlish
if is_unreserved(Byte(list_get(bytes, 0))):
```

The one required integration change: `encode_utf8`'s result is `List[int]`
(`core/strings.tcl`'s own `-result-type list`, plain UTF-8 byte values,
never `Byte`-typed), so `esc_char` must establish `is_unreserved`'s own
`Byte` proof explicitly with one checked `Byte(...)` per byte -- the same
strict contract `ascii::`'s own predicates enforce, never an implicit
`Int -> Byte` conversion. This checked construction can never fail here
(a UTF-8 byte value is always 0..255 by construction); it is not a
semantic change, only what strict typing requires at this one boundary.

The old nested, 13-level threshold-ladder `is_unreserved` was removed
entirely (never retained as dead production code); no second
implementation survives in `lib/web.bot`. (An independent Tcl-side
reference model of the *old intended behavior* is used only inside the
test suite -- see below -- never as a second production implementation,
per spec item 51.)

## Exhaustive URI equivalence

`tests/web-unreserved.test`'s `web-unreserved-exhaustive` test sweeps all
256 `Byte` values once and checks, for every one:

1. `web::is_unreserved(b)` equals an independent host-side reference
   model (`(48<=b<=57) or (65<=b<=90) or (97<=b<=122) or b in {45,46,95,126}`)
   -- **0 mismatches**.
2. `web::is_unreserved(b)` equals `ascii::is_alphanumeric(b) or
   immutable_set_contains(additional_unreserved_chars, b)` (the
   compositional identity itself, spec item 54) -- **0 mismatches**.
3. The count of `true` results over the full domain is **exactly 66**
   (26 upper + 26 lower + 10 digit + 4 punctuation).

`web-unreserved-backend-parity-256` re-runs the same 256-value sweep on
all four backends and requires identical outcomes -- confirmed.

Public behavior is unchanged: the RFC 3986 unreserved set (`A-Za-z0-9._~-`)
is exactly what the old threshold ladder classified `true`, and exactly
what the new compositional form classifies `true` -- proven, not assumed,
by the equivalence sweep above and by `tests/native-uri-escape.test`'s
existing text-output tests continuing to pass unmodified (see "Existing
workload regression" below).

## Module retention / allocation evidence

`additional_unreserved_chars` is constructed **exactly once**, regardless
of call count: `tests/web-unreserved.test`'s `web-unreserved-set-built-once`
finds exactly one `setfromlist` allocation site (one allocation) across
six `web::is_unreserved` calls in one program. `web-unreserved-allocations-
dont-grow-with-call-count` confirms the total allocation count for one
call vs. four calls differs by exactly 1 -- the outer list literal
wrapping the four results, nothing from `is_unreserved` itself.

A `web::is_unreserved` call, after module init, allocates nothing of its
own: `ascii-predicate-call-allocates-nothing` (an `ascii::` predicate) and
the allocation-delta test above (`web::is_unreserved`) both confirm zero
per-call allocation. The module-scope `hex_digits` list, the
`additional_unreserved_chars` set (and its own internal `List[UnicodeChar]`
temporary from `byte::set`), and the two module functions' own closures
(`is_unreserved`, `uri_escape_text`) are one-time program-initialization
costs, captured in "Generated-code baseline" below.

Direct NIR inspection of `web::is_unreserved`'s compiled body confirms
short-circuiting at the machine level, not just by language convention:

```
func 8 "web::is_unreserved" ...
    %1 = call 7 %0             ; ascii::is_alphanumeric(b)
    br %1 L0 L1                ; true -> L0 (return true, skip setcontains)
  label L0
    ... ret true ...
  label L1
    %4 = capture 0              ; the retained additional_unreserved_chars set
    %5 = op setcontains %4 %0   ; only reached when is_alphanumeric was false
    ...
```

`tests/web-unreserved.test`'s `web-unreserved-is-alphanumeric-lowers-to-if`
and `web-unreserved-or-short-circuits` pin this: `or` has no dedicated IR
form of its own (`hir::lower`/`surface/lower.tcl` desugars it directly to
`if`), so laziness is inherited from `if`'s own tree-walking evaluator,
not a property `or` could accidentally lose; a raw-IR probe spliced into
`is_unreserved`'s exact two-operand shape (using `tests/helpers.tcl`'s
`test-log`, reachable only from raw IR since ordinary `.bot` identifiers
cannot spell its hyphen) confirms the right operand is never evaluated
when the left is already `true`, and is evaluated when it is not.

## Existing workload regression

`tests/native-uri-escape.test`'s 18 pre-existing tests (encode_utf8/
uriEscape four-way value parity, text parity across all four backends for
7 representative strings including two-byte and astral characters, an
`@`-containing address, and a literal `%`, UriQueryValue evidence
presence/absence per backend, a GC-stress run, and the `refined-checks.ir`
native-blocker regression) all pass **unchanged, unmodified** against the
new `is_unreserved`. This is the actual consumer-workload proof this
milestone's rewrite preserves behavior end to end, not just in isolation.

Two other pre-existing tests asserted *exact* structural counts that
legitimately changed shape (not behavior) because `is_unreserved` moved
from a private nested function to a top-level, separately-closed-over
module value, and `web.bot` gained one new retained value:

- `tests/surface-modules.test`'s `surface-modules-uri-hex-digits-startup`:
  module-init `listnew` count 1 -> 3 (unchanged `hex_digits` list, plus
  the new four-char punctuation list `byte::set` consumes, plus
  `byte::set`'s own internal accumulator list); `uri_escape_text`'s own
  closure `captures=1 -> captures=2` (it now separately captures
  `hex_digits` *and* the `is_unreserved` closure, since `esc_char` calls a
  sibling module function instead of a lexically nested one).
- `tests/native-block-escape.test`'s `blockescape-region-companion-
  refined-checks-1`: the real `bench/refined-checks.ir` workload's
  startup `Block` allocations 1 -> 2 (the new `is_unreserved` closure,
  alongside `uri_escape_text`'s own, unchanged one), `List` 5 -> 11 (the
  new punctuation list and `byte::set`'s own internal list/append
  machinery), `ImmutableSet` 0 -> 1 (`additional_unreserved_chars` itself);
  `String` allocations (9) and the program's own *value* are unchanged.

Both were updated to the new, verified-correct counts, with a comment
explaining exactly why each number moved (see the diffs in those two
files). No other exact-count assertion elsewhere in the suite was
affected (checked: `hir-closed-call-params.test`, `native-bitshift.test`,
`native-byte.test`, `native-string-view.test`, `native-refinement-
propagation.test`, `native-validator-predicate.test`,
`native-tcl-unicode.test`, `refined.test`, `refined-signatures.test` --
all pass unmodified).

## Backend parity

Both `ascii::` (all five predicates, 256-value sweep, one program) and
`web::is_unreserved` (256-value sweep) agree byte-for-byte across
`interp`/`compile`/`cranelift-generic`/`cranelift`, over the entire Byte
domain, in one pass each -- `tests/ascii.test`'s
`ascii-backend-parity-256` and `tests/web-unreserved.test`'s
`web-unreserved-backend-parity-256`.

## Generated-code baseline

Captured via `native::lower::program`/`native::allocationReport`, no
optimization performed. Two distinct compiled shapes were observed for
`ascii::is_digit`/`is_upper`/`is_lower`, depending on the calling context
(this is `hir/specialize.tcl`'s ordinary per-instance behavior, not
anything new here):

**Instance `"int"`** (b already a raw machine int at the call site, e.g.
calling `ascii::is_digit` directly on a `Byte(...)`-constructed value with
no intervening generic call):

```
func 1 "ascii::is_digit" ... instance="int" rawregs="1 3 7"
    %1 = op runbox %0
    %3 = rawint 48
    %4 = op rige %1 %3     ; b >= 48   (raw int comparison)
    br %4 L0 L1
  label L0
    %7 = rawint 57
    %8 = op rile %1 %7     ; b <= 57
    br %8 L3 L4
    ...
```
One `runbox` (unboxing the raw-int register to its Int form for the
comparison ops used here), two raw-int comparisons (`rige`/`rile`), no
further boxing/reboxing, no dynamic 0..255 range re-check (the domain
check happens once, at the `Byte(...)` call site in the *caller*, never
inside `is_digit` itself -- confirming spec item 49).

**Instance `"generic"`** (b arrives boxed/tagged, e.g. through
`web::is_unreserved`'s own generic-instance call chain):

```
func 3 "ascii::is_digit" ... instance="generic" rawregs="2 6"
    guard int %0 ">="        ; one dynamic "is this actually an Int" check
    %3 = op ige %0 %1        ; b >= 48
    ...
    %7 = op ile %0 %5        ; b <= 57 -- no second guard
```
Exactly one `guard int` per call in this instance, recovering a fact
`Byte`'s own *static* type already guarantees -- a real, visible cost of
the generic/boxed representation choice, not of the ASCII predicate's own
logic (deferred to the next audit, not fixed here; see spec item 77 Q19).

**Composition does not inline**: `ascii::is_alphabetic` compiles to two
real `call` instructions (to `is_upper`, `is_lower`), and
`ascii::is_alphanumeric` to two real `call` instructions (to
`is_alphabetic`, `is_digit`) -- confirmed by both direct NIR inspection
and `tests/ascii.test`'s `ascii-alphabetic-calls-siblings` (checks the
compiled HIR's own call targets). The tiny-leaf inliner (`native/
lower.tcl`) does not fire here: these leaves each contain a `call`
themselves (or, for the two comparison leaves, two native ops plus a
branch each), outside -- or at the edge of -- its budget/eligibility
rules; this milestone made no change to that inliner and did not
investigate further (spec item 35's "record, don't tune").

**`web::is_unreserved`** (generic instance, the only one observed --
`immutable_set_contains` is itself generic):

```
func 8 "web::is_unreserved" ... env=1 captures=1 instance="generic"
    %1 = call 7 %0            ; ascii::is_alphanumeric(b)  -- real call
    br %1 L0 L1
  label L0
    ... ret true ...
  label L1
    %4 = capture 0            ; the retained set, via closure capture
    %5 = op setcontains %4 %0 ; generic ImmutableSet membership
    ...
```
One real call (never inlined), one closure-captured reference to the
retained set (not a global/module lookup each time), one generic
`setcontains` op. The compiler does **not** exploit that the set is
constant (item 21/41's own question): `setcontains` is the same generic
op any `ImmutableSet` membership test lowers to, with no specialization
for this set's four known members -- confirmed by direct inspection, no
constant-set lowering, comparison-chain generation, or bitmap anywhere in
the emitted NIR.

Module initialization (the `<program>` entry function, one-time):

```
func 0 "<program>" ...
    %0..%15 = str "0".."F"          ; hex_digits' own 16 elements
    %16 = op listnew ...            ; hex_digits itself
    %17..%20 = char 45 46 95 126    ; '-' '.' '_' '~'
    %21 = op listnew %17..%20       ; the List[UnicodeChar] byte::set consumes
    %22 = call 2 %21                ; byte::set(...) -> additional_unreserved_chars
    %23 = closure 8 %22             ; is_unreserved's own closure, capturing the set
    %24 = closure 9 %16 %23         ; uri_escape_text's closure, capturing hex_digits AND is_unreserved
```

`byte::set`'s own body (`func 2`, unmodified) shows exactly the
`BYTE-SET.md`-documented shape: one `listnew` (empty accumulator), a
`listloop` (`ilt`/`listget`/`iadd` index machinery), one `char::codepoint`
call and one checked `Byte(...)` construction (`ige`/`ile`/`raise RANGE`
guard) *per element*, one `listappend` per element, and exactly one
`setfromlist` at the end -- confirming items 25-27 (no fusion, no
checked-constructor elimination, no `char::codepoint` lowering change).

All of this -- the `guard int`, the un-inlined call chains, the generic
`setcontains`, the per-element checked-constructor calls inside
`byte::set` -- is recorded as this milestone's first workload snapshot,
exactly as spec item 39-41/72 ask, and none of it was touched.

## SOURCE FENCE

### Files frozen for the next audit

- `lib/ascii.bot` (new)
- `lib/web.bot` (`is_unreserved` rewritten; `additional_unreserved_chars`
  added; `esc_char`'s one call site updated to establish `Byte`
  explicitly)

No other `.bot` file changed. `lib/byte.bot` is untouched. No historical
String/URI workload source was modernized.

**SOURCE FENCE ESTABLISHED.** The following workload source forms must
remain unchanged through the next representation/codegen optimization
phase:

- `byte::set` (`lib/byte.bot`)
- the five `ascii::` predicates (`lib/ascii.bot`)
- `web::is_unreserved` and `additional_unreserved_chars` (`lib/web.bot`)
- `web::uri_escape_text` and its own nested helpers (`lib/web.bot`,
  unchanged except `esc_char`'s one `Byte(...)` call-site addition)
- every existing String/URI workload this milestone did not touch

## Deferred representation/codegen questions

Recorded for the next audit, not acted on here:

- `ascii::is_alphabetic`/`is_alphanumeric` never inline into their
  callers or callees (real `call` instructions throughout) -- worth
  checking whether the tiny-leaf inliner's budget/eligibility rules
  *should* cover this shape, or whether that is out of scope for a leaf
  that itself contains a call.
- The `"generic"` instance's `guard int` per predicate call is a runtime
  re-proof of a fact `Byte`'s own static type already guarantees; whether
  a `Byte`-typed parameter should ever compile to a raw, unboxed
  representation regardless of calling context (removing the guard
  entirely for this instance) is exactly the audit's kind of question.
- `web::is_unreserved`'s `setcontains` is fully generic; the compiler does
  not know or exploit that `additional_unreserved_chars` has exactly four,
  compile-time-known members. A future audit could ask whether a
  constant `ImmutableSet[Byte]` should ever specialize to a bitmap,
  comparison chain, or perfect hash -- explicitly **not** done here (spec
  item 23).
- `byte::set`'s own per-element checked `Byte(...)` construction (inside
  `additional_unreserved_chars`'s one-time module-init call) is unchanged,
  as required; whether four *statically known-in-range* literal chars
  should ever elide that check is exactly this project's own deferred
  question from BYTE-SET.md, still open.
- Whether `Byte` (or refined `Int` domains generally) should ever get a
  raw/unboxed calling convention independent of call-site instance is the
  same underlying question the `guard int` observation above raises.
- "This could obviously be one bitmap test" (spec item 73's own named
  example) is exactly the class of observation being deferred here, not
  acted on.

## Tests

- `tests/ascii.test` (new, 33 tests): typing/contracts (5 static
  rejections + 1 acceptance + 1 provably-in-range-literal acceptance + 5
  result-type checks), 16 boundary-value tests (each on all four
  backends), one direct acceptance-table test, high-bit-bytes-all-false,
  one exhaustive 0..255 truth table (cardinalities + composition +
  disjointness in one pass), one 256-value four-backend parity test, one
  zero-allocation test, one HIR-inspection test confirming real
  (non-inlined) sibling calls.
- `tests/web-unreserved.test` (new, 11 tests): an acceptance-table test,
  two static-rejection tests, one result-type test, one exhaustive 0..255
  equivalence + compositional-identity + cardinality test, one 256-value
  four-backend parity test, one module-retention (`setfromlist` count)
  test, one exact-membership test, one allocation-delta test, one IR-shape
  test, one short-circuit-evaluation test.
- `tests/surface-modules.test` and `tests/native-block-escape.test`:
  one pre-existing test each updated (not added) to the new, verified
  correct structural counts, with an explanatory comment (see "Existing
  workload regression" above).
- `tests/native-uri-escape.test`: unmodified, all 18 tests still pass --
  the actual consumer-workload regression check.

## Full regression / GC stress

```
tclsh9.0 tests/all.tcl
```
First full run (before `tests/native-block-escape.test`'s own
structural-count fix, below): **`Total 2060 Passed 2059 Failed 1`** --
the one failure was exactly `blockescape-region-companion-refined-checks-1`
(the known, expected structural-count change accounted for above). After
updating that test's expected counts (verified correct by direct
inspection first), `tests/native-block-escape.test` alone: **`Total 48
Passed 48 Failed 0`**; `tests/surface-modules.test` alone (its own
similarly-updated test): **`Total 28 Passed 28 Failed 0`**;
`tests/ascii.test`: **`Total 33 Passed 33 Failed 0`**;
`tests/web-unreserved.test`: **`Total 11 Passed 11 Failed 0`**;
`tests/native-uri-escape.test` (unmodified): **`Total 18 Passed 18 Failed
0`**. A second full `tests/all.tcl` run (with both fixes applied) is
recorded below once it completes.

```
cargo test --release --manifest-path native/Cargo.toml
```
**`test result: ok. 60 passed; 0 failed; 0 ignored; 0 measured; 0
filtered out`.**

```
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
```
Recorded below once it completes (run in isolation, per spec item 71, to
avoid resource-contention noise with the ordinary run above).

## Architecture questions

1. **Why does ASCII classification accept `Byte` rather than
   `UnicodeChar`?** Because it classifies byte values, not Unicode scalar
   values -- `Byte`'s domain (0..255) *is* the ASCII question's own
   domain; `UnicodeChar` (up to U+10FFFF) is not.
2. **Is ASCII classification locale-independent?** Yes -- fixed numeric
   ranges only, no libc, no Tcl character classes, no locale of any kind.
3. **Are high-bit Bytes errors?** No -- ordinary `false` classifications;
   classification is total over all 256 values.
4. **Does any ASCII predicate use UTF-8?** No.
5. **Are URI punctuation rules present in the ASCII namespace?** No --
   `ascii::` has exactly five predicates, none of them URI-specific;
   `'-' '.' '_' '~'` are classified only by `web::`'s own set.
6. **What exact four Bytes make up the additional URI-unreserved set?**
   45 (`'-'`), 46 (`'.'`), 95 (`'_'`), 126 (`'~'`).
7. **Is that set module-retained?** Yes.
8. **Is it built once?** Yes -- exactly one `setfromlist` allocation,
   confirmed regardless of call count.
9. **Does `web::is_unreserved` allocate per call?** No -- confirmed by
   allocation-delta measurement.
10. **Did any Byte/ImmutableSet representation specialization occur?**
    No -- `setcontains` is the fully generic membership op; no bitmap,
    comparison-chain, perfect hash, or Byte-specific representation was
    introduced.

## Source-fence questions

11. **Which `.bot` files changed?** `lib/web.bot` (modified);
    `lib/ascii.bot` (new).
12. **Was any unrelated historical `.bot` code modernized?** No.
13. **Are `byte::set` and the existing string workloads unchanged?** Yes,
    except the one required call-site integration (`esc_char`'s
    `Byte(list_get(bytes, 0))`).
14. **Is the new ASCII/web source considered idiomatic Botlish?** Yes --
    see "Required source review" below.
15. **Is the source now frozen for the next generated-code/
    representation phase?** Yes.

## Required source review

> Would we want ordinary Botlish programmers to express these operations
> this way?

**Yes**, for both:

`ascii::is_digit(b) = b >= 48 and b <= 57` (and its siblings) read exactly
like the definitions they implement -- a range check, stated once, with
no branch ladder, no lookup table, no bit trick. `is_alphabetic`/
`is_alphanumeric` read as the compositions they are (`is_upper(b) or
is_lower(b)`; `is_alphabetic(b) or is_digit(b)`) -- a reader who knows
what "alphabetic" and "alphanumeric" mean does not need to re-derive them
from ranges.

`web::is_unreserved(b) = ascii::is_alphanumeric(b) or
immutable_set_contains(additional_unreserved_chars, b)` states its own two
real halves plainly: "ASCII letters or digits, or one of these four
punctuation bytes" -- a direct improvement over the 13-level threshold
ladder it replaces, which stated no intent at all, only a sequence of
numeric cutoffs a reader had to simulate to understand. Nothing here is
contorted for machine-code reasons; see "Generated-code baseline" above
for what that costs today, deliberately left unaddressed.

No missing general-purpose surface facility was found; no new syntax was
added or is believed needed for this vertical (spec item 29 -- see the
one exception below).

## Deferred sub-note: cross-module type-name dependency discovery

Not a source or syntax gap in `ascii.bot`/`web.bot` themselves, but a
real, previously-unexercised architectural corner this milestone was the
first to reach: `surface/modules.tcl`'s module dependency discovery
(`QualifiedRefs`) triggers only on `namespace::name` *expression*
references, never on a bare type-annotation name (`TypeExpr`'s own
grammar has no `::` form at all). Every existing source-defined type
(`Byte`, `Nibble`, ...) lived in exactly one file (`lib/byte.bot`) that
every past consumer also called a function from directly, so this never
mattered before. `lib/ascii.bot` is the first module whose own function
*signatures* need a source-defined type (`Byte`) declared in a different
file, with no function of its own to call from that file. In production
this is invisible (`lib/web.bot` already depends on `byte::set` directly,
so `Byte` is always registered by the time `web::is_unreserved` needs it),
but a test program using only `ascii::` and constructing its own `Byte`
values needs its own `byte::...` reference to do so -- solved here with
the exact `byte::high_nibble(0)`-as-dependency-anchor idiom this
repository's own `tests/byte-set.test`/`tests/native-byte.test` already
established, predating this file. This is recorded, not fixed: no new
import/type-dependency syntax was added, per spec item 29's own
instruction to report rather than casually expand the surface language.

## Audit handoff questions

16. **Does `ascii::is_alphanumeric` inline fully today?** No -- it always
    compiles to a real `call` to `is_alphabetic`, which calls `is_upper`/
    `is_lower` as real `call`s in turn; `is_alphanumeric` also calls
    `is_digit` as a real `call`. The tiny-leaf inliner does not fire here.
17. **How many comparisons/branches remain?** Each leaf (`is_digit`/
    `is_upper`/`is_lower`) is two comparisons (`>=`, `<=`) and one branch
    each (two branches total, nested); `is_alphabetic`/`is_alphanumeric`
    add one branch each around their own two calls. `web::is_unreserved`
    adds one more branch around its own call + `setcontains`.
18. **Are Byte values repeatedly unboxed/reboxed?** In the raw (`"int"`)
    instance: one `runbox` per leaf call, no reboxing observed. In the
    generic instance: no explicit unbox/rebox op, but a `guard int` per
    call (see Q19).
19. **Are any type/range guards recovering facts already implied by
    Byte?** Yes -- the generic instance's one `guard int %0 ">="` per
    predicate call re-verifies "this is an Int" at runtime, a fact
    `Byte`'s own static type already guarantees. This is a representation
    (boxed-value-kind) guard, not a re-check of the 0..255 domain itself
    (no such re-check was observed anywhere inside the predicates).
20. **Does `web::is_unreserved` perform generic ImmutableSet
    membership?** Yes -- one `op setcontains`, the same generic op any
    `ImmutableSet` membership test uses.
21. **Does the compiler exploit that the set is constant?** No,
    confirmed by direct NIR inspection -- `setcontains` carries no
    constant-membership specialization.
22. **How is `ImmutableSet[Byte]` represented?** Unchanged from the
    generic `ImmutableSet` representation (`MINIMAL-IMMUTABLE-SET.md`'s
    reference vector representation) -- no Byte-specific specialization
    was introduced or investigated.
23. **What allocations occur only at module startup?** `hex_digits`'
    list (16 strings + 1 listnew), the four-char punctuation list (1
    listnew) and `byte::set`'s own internal accumulator/append machinery
    (1 listnew + N listappend) feeding `additional_unreserved_chars`'s
    one `setfromlist`, and the two module functions' own closures
    (`is_unreserved`, `uri_escape_text`) -- all one-time, confirmed not to
    grow with call count.
24. **Does `char::codepoint` still use a runtime helper during set
    construction?** Yes, unchanged -- one `call` to `char::codepoint`
    (itself one `charcodepoint` native op) per element inside `byte::set`'s
    loop, exactly as `BYTE-SET.md` documented.
25. **Are checked Byte constructor guards retained for statically literal
    chars?** Yes -- `byte::set`'s loop performs the identical
    `ige`/`ile`/`raise RANGE` checked-construction guard per element even
    though all four characters (`'-' '.' '_' '~'`) are statically known to
    fit; this milestone did not remove it (per spec item 26), matching
    `BYTE-SET.md`'s own deferred note about this exact case.

## Acceptance table

Byte construction below uses actual legal syntax
(`Byte(char::codepoint('-'))` where a character literal is involved,
plain `Byte(N)` for a numeric boundary already known):

| Call | Result |
|---|---|
| `ascii::is_digit(Byte(48))` | `true` |
| `ascii::is_digit(Byte(57))` | `true` |
| `ascii::is_digit(Byte(47))` | `false` |
| `ascii::is_digit(Byte(58))` | `false` |
| `ascii::is_upper(Byte(65))` | `true` |
| `ascii::is_upper(Byte(90))` | `true` |
| `ascii::is_upper(Byte(64))` | `false` |
| `ascii::is_upper(Byte(91))` | `false` |
| `ascii::is_lower(Byte(97))` | `true` |
| `ascii::is_lower(Byte(122))` | `true` |
| `ascii::is_lower(Byte(96))` | `false` |
| `ascii::is_lower(Byte(123))` | `false` |
| `ascii::is_alphabetic(Byte(55))` | `false` |
| `ascii::is_alphanumeric(Byte(55))` | `true` |
| `web::is_unreserved(Byte(char::codepoint('-')))` | `true` |
| `web::is_unreserved(Byte(char::codepoint('.')))` | `true` |
| `web::is_unreserved(Byte(char::codepoint('_')))` | `true` |
| `web::is_unreserved(Byte(char::codepoint('~')))` | `true` |
| `web::is_unreserved(Byte(char::codepoint('/')))` | `false` |
| `web::is_unreserved(Byte(128))` | `false` |
| `web::is_unreserved(Byte(255))` | `false` |

All pinned exactly as shown in `tests/ascii.test`'s
`ascii-acceptance-table` and `tests/web-unreserved.test`'s
`web-unreserved-acceptance-table`.
