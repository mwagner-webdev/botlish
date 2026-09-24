# UnicodeChar: a scalar semantic type distinct from Int and String

## Outcome

`UnicodeChar` is now a first-class, immutable builtin scalar type representing
exactly one Unicode scalar value. Single-quoted literals (`'A'`, `'é'`,
`'😀'`, `'\n'`, `'\''`, `'\\'`) produce `UnicodeChar` values directly, never
`String`. `UnicodeChar` is not implicitly `Int` and not implicitly `String`
in either direction; its scalar numeric value is observed only through the
explicit, total operation `char::codepoint`/`char_codepoint`. The runtime
preserves this distinction through every backend and through untyped/dynamic
execution paths, not only statically. Ordinary (unmodified) `List[T]`
construction inference therefore makes `['-', '.', '_', '~']` a
`List[UnicodeChar]`, with `list_get` recovering `UnicodeChar` through the
existing applied-type machinery, with zero `List`-specific or char-specific
inference code.

Full regression: **1894/1894** Tcl tests pass on both `interp` and `compile`
backends, unchanged by `BOTLISH_NATIVE_GC_STRESS=1`. **60/60** Rust unit
tests pass (`cargo test --release`). The new `tests/unicode-char.test` adds
**75** tests, all passing on `interp` and `compile` (its own backend-parity
tests additionally check `cranelift-generic` and `cranelift`).

`ImmutableSet[T]`, `byte::set`, ASCII predicates, URI logic, predicate flow
refinement, source integer-domain union syntax, Unicode normalization/
categories/grapheme clusters, implicit `UnicodeChar<->Int`/`String`
conversion, UTF-8 encoding, and Byte/Int64 representation specialization
were **not** touched or added — see "Deferred" at the end.

## Semantic definition of UnicodeChar

`UnicodeChar` is exactly one Unicode *scalar value*: an integer in
`0..=0xD7FF` or `0xE000..=0x10FFFF`. Surrogates (`0xD800..=0xDFFF`) can never
inhabit it. It is not `String`, not a one-character `String`, not `Byte`, not
a UTF-8 byte, not a grapheme cluster, and not a source-defined bounded `Int`
alias. It has no ordering, no mutation, no identity API — value equality only.

## Why UnicodeChar is distinct from Int and String

Because the milestone's central soundness requirement (spec items 16-17,
88-89) is that a `UnicodeChar` can never be silently treated as an `Int`
through *any* path — typed, untyped, or through a native's own runtime
dispatch. The only representation that makes that true unconditionally,
rather than "true as long as nobody finds the gap," is a genuinely distinct
runtime kind: one whose *tag bits* differ from every Int representation
(small or big), so `core::value::kind`/`kind_of` can never confuse the two
regardless of what static analysis did or didn't prove. See "Dynamic/untyped
soundness" below for how this plays out at every layer that could have gotten
it wrong.

## Why source integer-domain syntax was not expanded

A source-defined type (`type Byte = Int in 0..255`, `lib/byte.bot`) is
registered with `-base int`: at every backend, a `Byte` value *is* an
ordinary Botlish `Int`, refined by evidence. That is exactly the
representation the milestone explicitly forbids for `UnicodeChar` (item 3:
not a subtype of `Int`; item 24: no numeric value-set admissibility). Adding
a `0..0xD7FF | 0xE000..0x10FFFF` union domain to the source-defined-type
grammar would still leave `UnicodeChar` with base `int`, meaning
`char::codepoint('A')` would be definable, but `'A' + 1` would also
typecheck (same base kind, ordinary Int arithmetic) -- precisely the
"character arithmetic becomes legal" outcome item 16 forbids. So
`UnicodeChar` is registered as its own builtin primitive kind, structurally
parallel to `int`/`str`/`bool`/`unit`, not as a refinement of any of them.
The existing source-defined integer-domain language (one interval, or one
finite exact set, over `Int`) is unchanged.

## Runtime representation audit

Audited `core/value.tcl` (interpreter/compile Tcl tagged-list values: `{TAG
...}`, TAG one of `int str bool unit list result block native mutarray`) and
`native/src/runtime/value.rs` (native backend: one 64-bit word, low bits
tagged — small Int `...1`, heap pointer `...000`, four fixed constants
`false`/`true`/`unit`/`unbound` at 2/6/10/14).

- **Tcl side**: values are already tagged Tcl lists; a new tag is free (no
  encoding budget to manage). Chose the tag `UnicodeChar` (see naming below)
  carrying the canonical decimal codepoint as its payload: `{UnicodeChar
  65}` — structurally identical to `{int 65}`, but a different first
  word, so `core::value::kind` can never conflate them.
- **Native side**: the tag-bit space has exactly one free 3-bit pattern
  among `{001, 010, 011, 100, 101, 110, 111}` not already claimed by small
  Int (`bit0=1`) or a heap pointer (`bits=000`) for *general* use — the four
  fixed constants only occupy four *exact values*, not a whole tag class, so
  a genuinely new class is available. `0b100` was picked and is claimed
  exclusively by `UnicodeChar`.

## Chosen runtime representation

**Immediate, not boxed**, on both backends — this is the preferred outcome
per item 18, and a clean encoding existed, so the boxed fallback (item 19)
was not needed.

- Tcl (`core::value.tcl`): `{UnicodeChar CODEPOINT}`, CODEPOINT canonical
  decimal text — the same 2-element-list shape as `{int N}`, so no new
  allocation class exists at this layer (Tcl lists are already how every
  value is represented).
- Native (`native/src/runtime/value.rs`): `(codepoint << 3) | 0b100`, a
  pure bit-packed word:
  ```
  ccc...ccc100   UnicodeChar, codepoint in bits [3..24)
  ```
  `is_char`/`char_of`/`make_char` (value.rs) are the only three functions
  that touch this encoding; `kind_of` checks `is_char` after the small-Int
  and fixed-constant checks and before falling through to `heap_kind`.
  A Unicode scalar value needs at most 21 bits, so the packed word needs at
  most 24 bits — nowhere near overflowing a 64-bit word, and disjoint from
  the small-Int range's own tag bit by construction.

No GC object, no root slot: `is_pointer(v)` (`v & 7 == 0`) is `false` for
every `UnicodeChar` word by construction, so the existing dynamic root scan
(`heap.rs`'s `if !is_pointer(v) { continue }`) already skips it — confirmed
by `native::allocationReport`, which reports **0 allocations** for
`char::codepoint('A')` end to end (HIR → NIR → machine code → run), and by a
GC-stress run (`BOTLISH_NATIVE_GC_STRESS=1`) that builds thousands of Lists
of chars with no failure.

## Dynamic/untyped soundness

Three places could have let a `UnicodeChar` silently pass as `Int`; all
three were audited and none do, *because* of the distinct-kind design, not
because of a special case added to guard against it:

1. **Arithmetic/bitwise/comparison natives** (`core/primitives.tcl`,
   `core/scalarbits.tcl`): every one calls `core::value::expect int $v
   $name` before touching its payload. `expect` checks `kind $v`, which is
   `UnicodeChar` for a char value — TYPE error, unconditionally. No
   `+`/`-`/`*`/`bit_and`/... needed a UnicodeChar-aware change.
2. **Range analysis** (`hir/range.tcl`'s `SeedRange`/`Seed`): both seed a
   Range fact from a `const` node only `if {[core::value::kind $v] eq
   "int"}`, else `unknown`. A `UnicodeChar` constant's flow-sensitive range
   is therefore always `unknown`, which makes `ProvesType` (the "was this
   value's exact/interval fact proven to lie in the declared type's integer
   domain" check `hir::range::ProvesValueAcceptedBy` uses as its *second*
   admissibility path, alongside nominal subtyping) unconditionally `false`
   for it. Combined with `core::type::integerFacts` itself gating on `base
   type == "int"` (a `UnicodeChar`-typed declaration's base is
   `UnicodeChar`, not `int`), there is no path by which a numeric fact
   about a char's codepoint could satisfy an `Int` parameter, or an `Int`
   literal's numeric-domain fact could satisfy a `UnicodeChar` parameter —
   this is item 24/80-81's requirement, and it holds without a single
   `UnicodeChar`-specific line in `hir/range.tcl`.
3. **Native backend `is_kind`** (`codegen/clif.rs`): a `guard UnicodeChar %v
   ...` instruction, emitted by `native/lower.tcl`'s ordinary
   `EmitArgGuards` exactly where `hir::aot` says a dynamic check is needed
   (e.g. a `UnicodeChar` value reaching `char_codepoint` through an untyped
   passthrough function), compiles to a direct bit-mask compare (`v & 7 ==
   4`) — no call, and it is checked *before* the value is used as anything
   else, the same way an `Int` guard is.

Verified end to end (all three backends agree):

```
fn add_one(x):
    x + 1
add_one('A')
  => CORE SEMANTIC TYPE: "+: expected int, got 'A'"   (interp / compile / cranelift)

fn pass(x): x
char_codepoint(pass(65))
  => CORE SEMANTIC TYPE: "char_codepoint: expected UnicodeChar, got 65"  (all three)
```

## Character literal syntax

Added to `surface/lexer.tcl`: `'` starts a `CHAR` token (previously
unclaimed — a bare `'` was an "unexpected character" lexer error, so this is
purely additive; no existing valid program used `'`). `surface::lexer::Char`
mirrors `String`'s structure closely (same unterminated/invalid-escape
diagnostic shape) but decodes into a list of Unicode *scalar* values (via
`scan $ch %c`, Tcl's ordinal-value read) rather than accumulating text, and
requires that list to have exactly one element once the closing `'` is
found. The token's `value` is the scalar's canonical decimal codepoint text
— the same shape an `INT` token's digits already have, so every downstream
layer that already knows how to carry an `INT`'s digits through
(`surface/ast.tcl`'s `int` node, `hir::syntax::constNode`) needed only a
parallel `char`/`UnicodeChar` case, never new machinery.

`surface/parser.tcl`'s `Primary` gained one `CHAR` case, producing an
AST node `(char TEXT)` (`TEXT` = decimal codepoint) — a dedicated node kind,
not a `string` node plus a conversion call, so the AST records that the
programmer wrote a character literal (spec item 13).

## Unicode scalar validation

Cardinality is counted in **Unicode scalars**, never UTF-8 bytes and never
raw source characters before escape decoding — required by items 8-9, 12,
15-16 of the spec. This falls out almost for free: `core::ReadFile` already
decodes source as UTF-8 into a Tcl string, and Tcl 9's strings are
themselves sequences of Unicode scalar values (`string index`/`string
length` never split a supplementary-plane character — the exact reason this
project pins Tcl 9, per `AGENTS.md`). So `surface::lexer::Char` walking the
source with `string index`/one loop iteration per raw character or escape is
already walking scalars, not bytes: `'é'` is one iteration (however many
UTF-8 bytes its source encoding used), `'😀'` is one iteration, and `'ab'`
or `'e´'` (`e` + a separate combining-acute *scalar*, U+0301 — a real,
distinct visual near-miss for `'é'`) are both two iterations and therefore
rejected with "character literal contains more than one Unicode scalar
value". Validity of the resulting single scalar is checked once, centrally,
by `core::value::isValidScalar` (`core/value.tcl`) — shared by the lexer, by
`core::value::char`'s constructor, and by `core::ir::literalValue`'s
`(const UnicodeChar ...)` case, so there is exactly one place that encodes
"what a Unicode scalar value is" on the Tcl side (mirrored, byte-for-byte
identically as a range check, by `is_valid_scalar` in
`native/src/runtime/value.rs`).

## Escape behavior

Audited existing String escapes (`surface/lexer.tcl`'s `String` proc):
`\\ \" \n \r \t`, nothing else — no `\u` mini-language exists today. Reused
exactly that vocabulary for characters, substituting `\'` for `\"` (the
quote that actually needs escaping in this context): `\\ \' \n \r \t`. No
new escape syntax was invented (item 11). Each decodes to exactly one
scalar, so "decoded to one scalar" is what the validity check actually
counts (not source token length — item 12): `'\n'` is one loop iteration
producing scalar 10, and is valid for the same reason `'A'` is.

## Surrogates / supplementary-plane handling

Supplementary-plane scalars need no special lexer code: `string index` of
raw UTF-8-decoded source already returns one supplementary character as one
"index" position, and `scan %c` on it returns its full codepoint (verified:
`char_codepoint('😀') = 128512`, not a UTF-16 surrogate pair or a partial
byte). Since no escape syntax exists that can spell an arbitrary numeric
codepoint (item 11's choice), a surrogate can only reach `core::value::char`
if the *raw source bytes* somehow decoded to one (which well-formed UTF-8
cannot produce). `core::value::isValidScalar`/`is_valid_scalar` still
reject it explicitly and centrally, as defense in depth exactly as item 10
asks, and as the one shared implementation of "what counts as a valid
scalar" on each side.

## HIR constant representation

Core IR: `(const UnicodeChar CODEPOINT)` — a new literal *type* alongside
`int`/`str`/`list` in `core/ir.tcl`'s `(const TYPE LITERAL)` grammar, not an
`int` literal with a side annotation. `core::ir::literalValue`'s
`UnicodeChar` case calls `core::value::char`, so the *value itself* carries
the `UnicodeChar` kind from construction. HIR (`hir/syntax.tcl`'s
`constNode`) stores exactly this literal verbatim; `hir::lower` reproduces
`(const UnicodeChar N)` unchanged. The expression's semantic *type*
(`hir/types.tcl`) is recovered generically from the constant's own kind
(`hir::types::ofValue` → `core::type::ofValue` → `core::value::kind`) —
no `UnicodeChar`-specific code was needed in `hir/types.tcl` at all.

## HIR serialization

`hir::format`'s generic `const` line (`"const [literal]"`) and
`hir::read`'s generic parser (`core::ir::literalValue` on the read-back
words) needed **zero** changes: because the literal's own words already say
`UnicodeChar CODEPOINT`, round-tripping "just worked" the moment
`core::ir::literalValue`/`CheckShape` understood the new literal type.
Chosen canonical text: **decimal codepoint** (`const UnicodeChar 65`), not
`U+0041` hex or a quoted/escaped form. This is a deliberate deviation from
the spec's own example (`char U+0041`), justified by: (1) it is
byte-for-byte the same choice already made for `Int` literals in this same
grammar, so the format stays internally consistent; (2) plain decimal is
immune to terminal encoding and never hides a control character (item 45),
which was the actual goal the hex suggestion was serving; (3) it needed no
new formatting code in `hir/format.tcl` (the existing generic literal
printer already handles it). Verified deterministic and round-trip-exact
for printable ASCII, quote, backslash, a control escape (`\n`), non-ASCII
BMP (`é`) and a supplementary-plane scalar (`😀`) — see
`char-hir-roundtrip*` in `tests/unicode-char.test`.

`surface::formatAst` (the *source*-level pretty-printer, a different layer)
similarly renders `(char 65)`, matching `(int 42)`'s own un-quoted style,
for the same reasons. `core::value::show` (the *interpreter value* display,
used in error messages) instead renders the source-legible quoted form —
`'A'`, `'\n'`, `'\''` — with the same escape vocabulary as literal syntax,
mirroring `str`'s own `show` exactly (`\\ ' \n \r \t`). All three renderers
(`core::value::show`, `native/src/runtime/show.rs`'s `show_into`, and HIR's
plain-decimal form) were independently verified to agree with each other
across backends (`tests/unicode-char.test`'s parity tests, plus manual
3-way comparison during development).

## char::codepoint

Namespace: `char::codepoint`, backed by the root native `char_codepoint`
(`core/unicodechar.tcl`) — exactly the `byte::high_nibble`/`bit_and`
split already established by `lib/byte.bot`/`core/scalarbits.tcl`: a
namespaced `.bot` wrapper function is how this codebase spells
"operation under a scalar type's own namespace" (there is no mechanism for
a *root* native itself to carry a `::` in its resolvable name — qualified
references resolve only against a loaded module's own definitions,
`hir/resolve.tcl`'s `ResolveQualifiedRef`). `lib/char.bot` is one line:

```botlish
namespace char
fn codepoint(c: UnicodeChar) -> int:
    char_codepoint(c)
```

`char_codepoint` itself (`core/unicodechar.tcl`) is registered
unconditionally at process start (like `scalarbits.tcl`'s bitwise
primitives, not like an optional `lib/*.tcl` library), because the
*primitive operation* is a core language fact even though its namespaced
surface spelling is only reachable once a program's `char::...` reference
pulls in `lib/char.bot` — this mirrors item 21's own contrast between
`UnicodeChar` (always available) and `Byte` (needs `lib/byte.bot` loaded):
the *type* needs nothing loaded; the *namespaced operation* does, exactly
like `byte::`'s own operations.

Total, never fails, never allocates: `core::unicodechar::codepoint`
(interp/compile) is `core::value::expect UnicodeChar` then a plain payload
read; `rt_char_codepoint` (native) is `make_small(char_of(v) as i64)`, one
bit-shift, no call into the runtime's Int-construction path — a Unicode
scalar value (≤ `0x10FFFF`) is always comfortably inside the small-Int
envelope (`2^62`), so it can never itself force a BigInt.

## Parameter/result contracts

`char::codepoint(65)`/`char::codepoint("A")` (the module-qualified,
typed-wrapper spelling) are **compile-time** errors: `codepoint`'s own
declared parameter type `c: UnicodeChar` is checked by
`hir::range::verifyDeclaredParams`, exactly like any other typed function
parameter — no `UnicodeChar`-specific code needed there either. Calling the
*bare root native* `char_codepoint(65)` directly, however, is (like any
other native call, e.g. `bit_and("A", "B")`) only checked **dynamically**:
`hir::types::Call`'s static per-argument kind check only runs during
specialization's region inference, not ordinary whole-program inference —
this is pre-existing behavior, unrelated to `UnicodeChar`, and is exactly
why `lib/char.bot`'s thin typed wrapper is what actually gives
`char::codepoint` its compile-time contract. `tests/unicode-char.test`
covers both: the compile-time rejection through the module, and the
dynamic `CORE SEMANTIC TYPE` rejection of the bare native.

## List[UnicodeChar] inference

`['-', '.', '_', '~']` lowers (unchanged, `surface/lower.tcl`) to `call
^list '-' '.' '_' '~'`, and the `list` native's existing `-result-shape
elements` metadata (`core/primitives.tcl`) already makes
`hir::types::Call`'s generic `ShapeResult` compute the elements' `lub` as
the call's result element type. `hir::types::lub` for two `UnicodeChar`
operands falls through to `core::type::lub`, which — since both share base
`UnicodeChar` and neither carries evidence — returns plain `UnicodeChar`.
`hir::types::MakeList` wraps that as `{list UnicodeChar}`, the *same*
structural form `List[UnicodeChar]` a declared annotation resolves to
(`MINIMAL-APPLIED-LIST-TYPES.md`'s own invariant). **No List-specific or
char-specific code was written or needed** for this — it is a direct,
verified consequence of `UnicodeChar` being an ordinary primitive kind with
no evidence, exactly the shape the `List[T]` milestone already generalized
over. Confirmed for a mixed-codepoint list (`['A', 'é', '😀']`, different
UTF-8 lengths and numeric values — still `List[UnicodeChar]`) and for a
`UnicodeChar`/`String` mix (`['A', "A"]` — falls back to the ordinary
broad/heterogeneous `list`, per existing LUB semantics, no coercion).

## list_get projection

`list_get(List[UnicodeChar], i)`'s result type is `UnicodeChar`, recovered
the same way: `list_get`'s `-result-shape {element 0 1}` metadata lets
`ShapeResult` read the element type straight off the argument's own
`{list UnicodeChar}` static type. Verified for direct calls, for a
declared-parameter `List[UnicodeChar]` (a function `first(chars:
List[UnicodeChar]) -> UnicodeChar: list_get(chars, 0)`), and through an
intermediate alias (`copy = chars; list_get(copy, 0)`) — the immutable-
binding type-propagation this project already had.

## Typed-callable regression

A function taking `UnicodeChar` or `List[UnicodeChar]` remains an ordinary
typed callable (≥1 declared parameter type): passing it into an untyped
higher-order context (`fn apply(f, v): f(v)` then `apply(consume, 'A')`)
is still rejected by the existing `hir::callables::verify` pass with its
usual diagnostic ("...typed parameter requirements that cannot be
preserved..."), unchanged. An exact alias (`f = consume; f('A')`) still
works and still enforces the contract (`f(65)` still rejected). Ordinary
container erasure through an untyped passthrough still loses precision
(`lost = passthrough(chars); consume(lost)` still rejected) — no
`UnicodeChar`-aware reconstruction was added, matching item 42's "no
runtime reconstruction" requirement. None of `hir/callables.tcl` was
modified.

## Cross-module behavior

`char::codepoint` is loaded via the ordinary module mechanism
(`surface/modules.tcl`): a program referencing `char::codepoint` pulls in
`lib/char.bot` exactly as any `NAMESPACE::NAME` reference pulls in
`lib/NAMESPACE.bot`, with the identical compile-time parameter-type
enforcement any cross-module typed function gets after module combination
(no special-casing — this was true of `byte::`'s own functions already,
and remains true here, verified with `surface::readProgramFile` end to
end, including the rejection case across the module boundary).

## Interpreter / compile / native parity

All three backends were run against the same source for every acceptance
case (literals of each shape, equality, `char::codepoint`,
`List[UnicodeChar]`, `list_get`, the dynamic-soundness cases, a GC-stress
run) and agree exactly — see `tests/unicode-char.test`'s
`char-parity-*` tests and the manual 3-way comparisons captured during
development (identical values, identical error codes and messages).

- **interp**: `core::unicodechar::codepoint` reads `core::value::charOf`.
  Equality: `core::value::equal`'s existing `int - str - bool` case
  extended to `- UnicodeChar` — canonical-text comparison, same as Int, and
  correct because the kind check above it already rejects cross-kind
  comparisons (`'A' == 65` and `'A' == "A"` are `false`, never a coercion).
- **compile** (Tcl-generated code): needed **zero** changes. The compiler
  already represents every value as its literal tagged-list runtime value
  (`{UnicodeChar 65}`) and already has fully generic paths for: constant
  literals (`CompileForm`'s `const` case falls through to the generic
  "box whatever the value already is" branch the moment the value's kind
  isn't `int`), native calls (`DirectNativeCall`/`ContractCheck` check
  `[lindex $word 0] ne "$type"` generically for any kind string), and kind
  guards. This was true before this milestone and needed no
  `UnicodeChar`-awareness because the representation choice (tagged list,
  same shape as every other kind) is exactly what the compiler already
  assumed for "a kind it doesn't specifically optimize."
- **native (Cranelift)**: see "Chosen runtime representation" and the
  codegen microscope below; is the one backend that needed real new code
  (a new `Kind` variant, its bit-pattern predicate, a NIR literal form, one
  op, one helper), all exhaustiveness-checked by the Rust compiler as each
  `Kind`/`Inst`/`OpCode` match was extended.

## Allocation/GC behavior

Immediate on both backends: no allocation, no GC object, no root slot.
`native::allocationReport`'s `total.allocations` for `char::codepoint('A')`
(HIR → NIR → JIT-compiled machine code → run) is **0**. GC stress
(`BOTLISH_NATIVE_GC_STRESS=1`, forcing a collection at every safepoint) run
over the full suite, and separately over a hand-written program building
thousands of `List`s of mixed ASCII/BMP/supplementary-plane chars across
2000 recursive calls, passes cleanly.

## Codegen microscope

```botlish
fn code() -> int:
    char_codepoint('A')
code()
```

NIR:
```
func 1 "code" params=0 env=0 regs=2 pnames="" captures=0 instance="generic"
    %0 = char 65
    %1 = op charcodepoint %0
    ret %1
end
```

Cranelift IR (excerpt):
```
block0:
    v2 = iconst.i64 524          ; (65 << 3) | 4 = 524 -- the packed immediate
    v3 = call fn0(v0, v2)        ; fn0 = rt_char_codepoint
    return v3
```

The literal compiles to one `iconst` (no allocation, no call — `Inst::Char`
codegen in `codegen/clif.rs`); `char_codepoint` compiles to one direct call
to `rt_char_codepoint` (a runtime helper, matching the existing pattern for
other single-payload-read ops like `ResultValue`/`ResultError`, rather than
inlining the bit-shift directly in Cranelift IR — a deliberate, documented
choice to stay consistent with this codebase's own established style for
"read one field, no allocation, no failure path" ops, at the cost of one
call rather than zero; a later optimization pass could inline it, exactly
as item 19's "later codegen audit may justify a more compact ... scalar
representation" anticipates. Nothing about the *value representation*
would need to change for that; only this one op's codegen).

## Tests

`tests/unicode-char.test` (**75 tests**, `tests/all.tcl`): lexer (token
shape, escapes, all diagnostics — empty, multi-scalar, combining-accent
near-miss, unterminated, raw newline, invalid escape), parser/AST,
`core::value`/`core::ir` validation and round-trip, semantic-type
distinction (identity/take_int/char::codepoint accept and reject cases,
kind distinctness, non-coercive equality), `List[UnicodeChar]` inference
(homogeneous, mixed-codepoint, mixed-kind fallback) and `list_get`
projection, typed-callable escape regression, cross-module behavior via
`lib/char.bot`, dynamic/untyped soundness (`add_one('A')`,
`char_codepoint(pass(65))`), HIR round-trip (ASCII, quote, backslash,
control escape, BMP, supplementary plane), source-type coexistence
(`Small` alongside `UnicodeChar`), repeated-compilation isolation,
4-way backend parity (`interp`/`compile`/`cranelift-generic`/`cranelift`),
and the zero-allocation claim.

## Full regression / GC stress

```
tclsh9.0 tests/all.tcl                          -> Total 1894  Passed 1894  Failed 0  (interp)
                                                 -> Total 1894  Passed 1894  Failed 0  (compile)
cargo test --release --manifest-path native/Cargo.toml
                                                 -> 60 passed; 0 failed
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
                                                 -> Total 1894  Passed 1894  Failed 0  (interp)
                                                 -> Total 1894  Passed 1894  Failed 0  (compile)
```

No test was weakened or skipped to accommodate this milestone; all prior
suites (source-defined types, typed parameters, typed-callable escape,
applied `List[T]`, range analysis, specialization, native, module, string)
pass unchanged.

## Deferred (explicitly out of scope for this milestone)

`ImmutableSet[T]`, `byte::set`, ASCII predicates (`is_letter`/`is_digit`/
case conversion/Unicode categories), URI/`web::` logic, predicate flow
refinement, source integer-domain union/`except` syntax, Unicode
normalization, grapheme clusters, an `Int -> UnicodeChar` constructor or any
other implicit `UnicodeChar<->Int`/`String` conversion, UTF-8 encoding of a
`UnicodeChar`, and Byte/Int64 representation specialization were **not**
added. `UnicodeChar` values obtain their scalar numeric value only through
`char::codepoint`, which is exactly the seam the next vertical
(`byte::set(chars: List[UnicodeChar]) -> ImmutableSet[Byte]`) is meant to
build on: `char::codepoint` → `Int` → an explicit, checked `Byte`
refinement/construction of that `Int` (rejecting any codepoint outside
`0..255`, e.g. `'Ā'` or `'😀'`) → `Byte`. No UTF-8 encoding is involved in
that future composition, and nothing here needs to change to support it.

## Architecture questions (spec item 100)

1. **What exactly is UnicodeChar semantically?** Exactly one Unicode scalar
   value (`0..=0xD7FF` or `0xE000..=0x10FFFF`), never a surrogate.
2. **Why is it not represented as a source-defined integer domain?** Because
   that would give it base `int`, making `'A' + 1` typecheck (same base
   kind) — see "Why source integer-domain syntax was not expanded" above.
3. **Is it a subtype of Int?** No.
4. **Can Int values implicitly satisfy UnicodeChar parameters?** No
   (`identity(65)` is a compile-time `CORE SEMANTIC TYPE` error).
5. **Can UnicodeChar values implicitly satisfy Int parameters?** No
   (`take_int('A')` is a compile-time `CORE SEMANTIC TYPE` error).
6. **What explicit operation observes its scalar numeric value?**
   `char::codepoint`/`char_codepoint`.
7. **Is that operation total?** Yes — no Error completion, ever.
8. **What is the runtime representation?** An immediate tagged word on both
   backends: `{UnicodeChar CODEPOINT}` (Tcl) / `(codepoint << 3) | 0b100`
   (native).
9. **Is UnicodeChar dynamically distinguishable from Int?** Yes, in every
   context — verified through untyped/dynamic paths on all three backends.
10. **Can an untyped/dynamic path accidentally feed UnicodeChar to an Int
    primitive as though it were Int?** No — every Int primitive checks
    `core::value::expect int` (interp/compile) or emits a `guard int`
    (native), and a `UnicodeChar` value fails both unconditionally.
11. **Does the representation allocate?** No.
12. **If yes, what is the measured cost...?** N/A.
13. **If no, what tag/immediate encoding is used?** See item 8 above; full
    detail in "Chosen runtime representation".

## Literal questions (spec item 101)

14. **How is exactly one Unicode scalar counted?** By decoding
    (post-escape) into a list of scalar values and requiring exactly one
    element, over source already decoded to a Tcl 9 (scalar-value-aware)
    string.
15. **Are UTF-8 bytes involved in literal cardinality?** No.
16. **How are supplementary-plane values handled?** Natively — Tcl 9's
    strings represent them as single index positions; `scan %c` reads their
    full codepoint directly.
17. **How are surrogates rejected?** Centrally, by
    `core::value::isValidScalar`/`is_valid_scalar`, called from the lexer,
    from `core::value::char`, and from `core::ir`'s literal validation.
18. **What escape syntax is supported?** `\\ \' \n \r \t`.
19. **Was it reused from String syntax or newly invented?** Reused (String's
    own `\\ \" \n \r \t`, substituting `\'` for `\"`).
20. **Is normalization performed?** No.
21. **Are grapheme clusters supported as one literal?** No — a base+combining
    sequence is explicitly two scalars and rejected.

## Integration questions (spec item 102)

22. **What static type does `['-', '.', '_', '~']` infer?**
    `List[UnicodeChar]`.
23. **Did List inference need char-specific code?** No.
24. **What does `list_get(List[UnicodeChar], i)` return?** `UnicodeChar`.
25. **Can a `List[String]` satisfy `List[UnicodeChar]`?** No.
26. **Can a `List[Int]` satisfy it?** No.
27. **Does typed-callable escape protection still work for functions
    consuming UnicodeChar/List[UnicodeChar]?** Yes, unchanged.

## Runtime/backend questions (spec item 103)

28. **How does interp represent UnicodeChar?** `{UnicodeChar CODEPOINT}`
    (`core/value.tcl`).
29. **How does compile backend represent it?** The identical tagged-list
    value, embedded as a Tcl literal in generated code — no separate
    representation.
30. **How does native represent it?** `(codepoint << 3) | 0b100`, one word,
    immediate.
31. **Are their semantics identical?** Yes — verified by 4-way backend
    parity tests.
32. **Does equality compare scalar value rather than object identity?**
    Yes (it is not an object at all on either backend: word/text equality
    *is* value equality).
33. **Does char::codepoint compile to a helper or direct payload
    extraction?** A helper call (`rt_char_codepoint`) on native, matching
    this codebase's existing convention for other single-field-read ops; a
    plain payload read in Tcl (interp/compile).
34. **Are any String allocations involved?** No.
35. **Are any new GC objects involved?** No.

## Scope questions (spec item 104)

36-48. Was `ImmutableSet` added? No. `byte::set`? No. ASCII? No. URI logic
changed? No. Predicate flow refinement? No. Source integer-domain union
syntax? No. Unicode normalization? No. Unicode categories? No. Grapheme
clusters? No. Implicit `char<->Int` conversion? No. Implicit
`char<->String` conversion? No. UTF-8 encoding? No. Byte/Int64
representation specialization? No.

## Acceptance table

| Expression / call | Result |
|---|---|
| `'A'` | `UnicodeChar` U+0041 |
| `'é'` | `UnicodeChar` U+00E9 |
| `'😀'` | `UnicodeChar` U+1F600 |
| `''` | syntax error (empty character literal) |
| `'ab'` | syntax error (more than one Unicode scalar) |
| `'e´'` (e + combining acute, two scalars) | syntax error |
| `"A"` | `String` |
| `65` | `Int` |
| `identity('A')` | valid |
| `identity(65)` | compile error |
| `identity("A")` | compile error |
| `take_int('A')` | compile error |
| `take_int(char::codepoint('A'))` | valid |
| `char::codepoint('A')` | `65` |
| `char::codepoint('é')` | `233` |
| `char::codepoint('😀')` | `128512` |
| `char_codepoint(65)` (bare native, wrong dynamic kind) | runtime `CORE SEMANTIC TYPE` |
| `['-', '.', '_', '~']` | `List[UnicodeChar]` |
| `['A', 'é', '😀']` | `List[UnicodeChar]` |
| `['A', "A"]` | broad/heterogeneous `list` |
| `consume(chars: List[UnicodeChar])` called with `List[UnicodeChar]` | valid |
| `consume(...)` called with `List[String]` | compile error |
| `consume(...)` called with `List[Int]` | compile error |
| `list_get(List[UnicodeChar], 0)` | `UnicodeChar` |
| `'A' == 'A'` | `true` |
| `'A' == 'B'` | `false` |
| `'A' == 65` | `false` |
| `'A' == "A"` | `false` |
| `add_one('A')` (untyped `x + 1`) | runtime `CORE SEMANTIC TYPE` |

## Stop condition

All of the following hold, verified by the test suite and by manual 3-way
backend comparison during development:

- `UnicodeChar` is a first-class immutable scalar type representing exactly
  one Unicode scalar value.
- Single-quoted literals produce `UnicodeChar` directly.
- `UnicodeChar` is not implicitly `Int` or `String`, in either direction.
- Its scalar numeric value is exposed only through the explicit total
  operation `char::codepoint`/`char_codepoint`.
- The runtime preserves that distinction even through untyped/dynamic
  execution paths, on all three backends.
- `['-', '.', '_', '~']` infers as `List[UnicodeChar]` through ordinary
  existing `List[T]` inference, with `list_get` recovering `UnicodeChar`
  through the existing applied-type machinery — no char-specific List code.

Not started: `ImmutableSet[T]`, `byte::set`, ASCII predicates, URI rewrites,
predicate refinement, Byte/Int64 representation specialization.
