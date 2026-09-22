# Scalar domains and typed bit arithmetic: `Byte`, `Nibble`, `LowNibble`, `HighNibble`

A foundational milestone deliberately taken before the larger String-construction
audit (`STRING-BYTES-CONSTRUCTION-AUDIT.md`) identified as the next likely
target. This milestone introduces four bounded scalar Int domains, typed bit
arithmetic over them, bounded exact finite-value facts alongside the existing
interval analysis, and uses all of that to replace `web.bot`'s branch-ladder
`high_nibble` with compact, typed Botlish.

## 1. Files changed

- `core/scalarbits.tcl` (new) -- the four domains (`Byte`/`Nibble`/
  `LowNibble`/`HighNibble`: `core::type::register` + `definePredicate` +
  checked constructors), and the generic bitwise primitives (`bit_and`,
  `bit_or`, `bit_xor`, `shift_left`, `shift_right`). Loaded unconditionally
  (`core/core.tcl`'s own file list), like `primitives.tcl`/`predicates.tcl` --
  these are core language types, not an optional library.
- `lib/byte.bot` (new) -- the `byte::` namespace: `high_nibble`, `low_nibble`,
  `nibble`, `complement`, `position_low`, `position_high`, as ordinary,
  ordinarily-typed Botlish over the primitives above.
- `lib/web.bot` -- `high_nibble`'s 15-way threshold ladder replaced by
  `byte::nibble(byte::high_nibble(b))`. `is_unreserved` untouched.
- `hir/range.tcl` -- the interval `Range` lattice gains an optional `exact`
  field (a bounded, sorted finite-value set) alongside every existing
  min/max: `join`/`add`/`sub`/`mul`/branch-narrowing all propagate it when
  cheap; a `<,<=,>,>=` branch narrowing (`Narrowed`) and a new `==`/`!=`
  narrowing (`ExactEqualityNarrowing`) filter it; a new `BitOp` gives
  `bit_and`/`bit_or`/`bit_xor`/`shift_right` sound interval bounds.
- `native/lower.tcl` -- five `natives` table entries (`bit_and` -> `iand`,
  etc.), mirroring `+`/`-`/`*`/`mod`'s existing entries exactly.
- `native/src/nir.rs` -- five new `OpCode` variants (`IAnd`, `IOr`, `IXor`,
  `IShl`, `IShr`) + text-name parsing.
- `native/src/codegen/clif.rs` -- `IAnd`/`IOr`/`IXor` get a genuine
  branch-free tagged-word fast path (new `int_bitop`, mirroring `int_arith`
  but with no overflow branch: see \167 4); `IShl`/`IShr` are plain helper
  calls (mirroring `IMod`'s own shape, no fast path -- see \167 4's own scope
  note).
- `native/src/runtime/ops.rs` -- `rt_int_and`/`rt_int_or`/`rt_int_xor`/
  `rt_int_shl`/`rt_int_shr` (the slow-path/generic-call runtime helpers),
  registered in `helpers()`/`apply_op`/`op_may_allocate`/`op_may_error`.
- `tests/scalarbits.test`, `tests/hir-range-exact.test`, `tests/native-byte.test`
  (new): 20 + 16 + 12 = 48 new tests. `tests/hir-range.test`,
  `tests/hir-call-facts.test`: 11 pre-existing pinned `hir::range::show`/raw-dict
  strings updated to include the new (strictly more informative) exact-set
  annotations -- no other change to either file.

No change to `core/type.tcl`, `core/native.tcl`, `hir/specialize.tcl`,
`hir/types.tcl`, `hir/refine.tcl`, `native/native.tcl`, or any other Rust
source. No runtime wrapper object, evidence bit, or side table of any kind
exists anywhere in this diff (\167 6, \167 10).

## 2. `web.bot`'s `high_nibble`: before and after

Before (the milestone's own mandatory acceptance case -- 15 nested
thresholds, ~45 source lines):

```botlish
fn high_nibble(b):
    if b <= 15:
        0
    else:
        if b <= 31:
            1
        else:
            ... 13 more nested levels ...
                                else:
                                    15
```

After (2 lines):

```botlish
fn high_nibble(b):
    byte::nibble(byte::high_nibble(b))
```

`is_unreserved` (the milestone's other, deliberately-untouched threshold
ladder) is byte-for-byte unchanged.

## 3. The four domains: what they are, and how they're represented

All four are **ordinary, validator-backed refined `int` types**
(`core/type.tcl`'s existing mechanism -- the same one `Emailish`/`NonEmpty`
already use for `str`, just with `-base int` instead): membership is decided
**structurally**, by re-running the validator against the actual Int value,
never by nominal evidence tracking. This is deliberate and load-bearing (\167 8,
\167 43): `core::type::register`'s `-opaque` path (the only one needing runtime
evidence) is restricted to `str` (`evidenceKinds`), so a validator-backed
`int` type was the smallest architecture change consistent with "no runtime
wrapper" -- no new type-declaration mechanism, no new constrained-type
machinery, reusing `subtype`/`lub`/`narrow`/`acceptsValue` exactly as they
already existed.

| Type | Validator | Domain |
|---|---|---|
| `Byte` | `0 <= n <= 255` | 256 values |
| `Nibble` | `0 <= n <= 15` | 16 values |
| `LowNibble` | `0 <= n <= 15` | 16 values (same domain as `Nibble`, distinct name/identity) |
| `HighNibble` | `0 <= n <= 240 && n % 16 == 0` | exactly `{0,16,32,...,240}`, 16 values |

**Why `Nibble` and `LowNibble` are distinct types despite an identical
domain**: `Nibble` means "a logical four-bit integer"; `LowNibble` means "a
nibble already positioned in the low half of a Byte." They are numerically
interchangeable today (`byte::position_low` is a bare identity function --
see \167 5) but are never unified into one type, because the domains would
diverge the moment any future operation cares about *position* rather than
*value* (exactly `HighNibble`'s own domain already diverging from `Nibble`'s
today). Collapsing them would be a nominal-typing decision this milestone
was explicitly told not to make (spec \167 79-80: "prefer [a shared mechanism]
... but do not collapse merely because two presently share an interval").

**No runtime wrapper, anywhere.** A `Byte`/`Nibble`/`LowNibble`/`HighNibble`
value is, at every layer, an ordinary Botlish `Int` -- the same tagged
`(n<<1)|1` small-int word or `BigIntObj` every other Int already is. The
*type* exists only as: (a) a `core::type::register` entry (surface/semantic
layer), (b) a native's declared `-param-types`/`-result-type` (a trusted
contract, checked dynamically on interp/compile, trusted unconditionally by
Cranelift), and (c) `hir::range`'s interval/exact-set *facts* about a given
expression (a wholly separate, analysis-only layer -- \167 6 below). Nothing
in NIR, Cranelift IR, or machine code ever distinguishes a `Byte` register
from a plain `int` register.

## 4. Construction and conversion

**Checked construction from `Int`** (`Byte(x)`, `Nibble(x)`, `LowNibble(x)`,
`HighNibble(x)`): each is a native, arity 1, `-param-types int`,
`-result-type` the domain itself, `-impl core::scalarbits::CheckedConstruct`
-- validates via the type's own registered validator and raises
`{CORE SEMANTIC RANGE}` on failure, never masking or truncating (spec \167 9-10).
`HighNibble(10)` fails (`10` is in `[0,240]` but not a multiple of 16);
`HighNibble(0)`/`HighNibble(240)` succeed. **These four constructors are
interp/compile-only**: Cranelift has no dynamic-check machinery for a
native's own declared contract at all (\167 6, \167 9 below), and no
core-IR "raise" primitive exists for a `-native-body` to compose a check
from, so `Byte(300)` on `cranelift`/`cranelift-generic` is
`NATIVE UNSUPPORTED` -- reported, never silently wrong (see \167 9's parity
discussion for why this is the honest, minimal-risk choice for this
milestone rather than a new dedicated NIR op).

**Position-preserving extraction** (`byte::high_nibble`, `byte::low_nibble`
-- `lib/byte.bot`): `byte::high_nibble(0xAB)` is `0xA0` (`HighNibble`'s own
domain), never logical `0xA`. `byte::high_nibble(b) = bit_and(b, 0xF0)`;
`byte::low_nibble(b) = bit_and(b, 0x0F)`. Both are **total over every
`Int`**, not just valid `Byte`s: AND-with-a-nonnegative-mask can only ever
clear bits, never set one outside the mask, so the result is *always* in the
mask's own domain (`{0,16,...,240}`/`[0,15]`) regardless of the input's sign
or magnitude -- no validation is possible to omit here because none is ever
needed (spec \167 39, \167 69: "must not perform a redundant runtime
validation").

**Normalization** (`byte::nibble` -- positioned nibble, either half, to
logical `Nibble`): `byte::nibble(x) = bit_or(bit_and(x, 0x0F), shift_right(x, 4))`.
One branch-free formula covers both positions: for `x <= 15` (already
low-positioned), `shift_right(x,4) = 0`, so the result is `x` unchanged; for
`x` a valid `HighNibble` (a multiple of 16), `bit_and(x, 0x0F) = 0`, so the
result is `shift_right(x,4)`. Total and correct for every `x` in `Byte`'s own
domain `[0,255]` (both operands of the final `bit_or` are themselves in
`[0,15]`, and ORing two 4-bit values can never set a 5th bit) -- a strictly
larger, cleaner domain than "LowNibble or HighNibble" would have been, with
no special-casing of which half `x` came from.

**Positioning** (`byte::position_low`, `byte::position_high` -- `Nibble` to
`LowNibble`/`HighNibble`): `position_low` is the identity (representation-
preserving); `position_high(n) = shift_left(n, 4)`, always in
`{0,16,...,240}` for `n` in `[0,15]`.

**Widening** (`LowNibble`/`HighNibble`/`Nibble` -> `Byte`): not implemented as
a separate conversion at all -- every one of the values above is *already*
an ordinary `Int`, so "widening to `Byte`" is definitionally free (no
conversion exists to write). What *is* implemented, and load-bearing, is
keeping normalization (`byte::nibble`, a genuine `>>4`/positional shift) and
widening (a no-op) from ever being conflated: `HighNibble(0xA0) -> Byte` is
`0xA0` unchanged (there is no code path that could do anything else, since
both are the same Int); `HighNibble(0xA0) -> Nibble` is `0xA` via
`byte::nibble`'s real shift (spec \167 13).

## 5. Bitwise operations

`bit_and`, `bit_or`, `bit_xor` (`core/scalarbits.tcl`): **total over every
Int** (positive, negative, or zero), two's-complement, matching Tcl's own
`&`/`|`/`^` and Rust's `num_bigint::BigInt`'s `BitAnd`/`BitOr`/`BitXor`
exactly -- never fail. `shift_left`/`shift_right`: the value shifted may be
any Int (exact multiplication/floor-division by `2^k`, sign-extending); the
shift amount must be a nonnegative Int `<= 2^20` (`core::scalarbits::maxShift`,
mirrored exactly in `native/src/runtime/ops.rs`'s `MAX_SHIFT`), or
`{CORE SEMANTIC RANGE}` -- never silent truncation, never UB, bounded so a
shift amount can't itself try to allocate an astronomical BigInt.

**No generic `~`.** A full one's-complement of an arbitrary-precision Int is
well-defined (`-(x+1)`, exactly what Tcl/Rust both already give) but is not
what this milestone's domains need, and inheriting it as "the meaning of
`~Byte`" is exactly the mistake spec \167 15 warns against. Only
`byte::complement(b) = bit_xor(b, 0xFF)` exists, confined to `Byte`'s 8-bit
domain by construction: `byte::complement(0x00) = 0xFF`,
`byte::complement(0xF0) = 0x0F`.

**Result types for `&`/`|` combinations** (spec \167 16-17: "check whether
general interval reasoning already proves the result before adding a
dedicated rule"): no per-type dispatch table exists anywhere in this diff.
`hir/range.tcl`'s new `BitOp` (\167 6.4 below) proves, purely from "AND's
result bits are a subset of whichever operand is nonnegative,"
that `bit_and(byteValue, lowNibbleValue)`'s *interval* is `[0,15]` and
`bit_and(byteValue, highNibbleValue)`'s is `[0,240]` -- the same fact spec
\167 16's `Byte & LowNibble -> LowNibble` example wants, derived generically,
with zero code that mentions `Byte`, `LowNibble`, or `HighNibble` by name.
`HighNibble | LowNibble -> Byte` similarly falls out of `BitOp`'s `bit_or`
case (`[max(a.min,b.min), a.max+b.max]` for two nonnegative operands: here
`[0, 255]`, exactly `Byte`'s own interval) without any dedicated rule.

## 6. Bounded exact finite-value facts (`hir/range.tcl`)

### 6.1 Representation

A `Range` (pre-existing: `{min MIN max MAX}`) may now also carry `exact`, a
sorted, duplicate-free list of every value the expression could actually
take. `ExactOf` reads it (returning `""` for "not tracked"); a bare point
(`min == max`) or any *finite, in-budget* interval answers its own implicit
member list even with no `exact` key stored (needed for composition -- \167 6.3),
but `hir::range::show` (diagnostics) only ever *displays* an explicitly
stored `exact` key or a point's own trivial singleton, never a reconstructed
dense range -- keeping an ordinary bounded loop's `[0,3]` looking exactly
like it did before this milestone, not suddenly annotated with a redundant
`{0,1,2,3}`.

### 6.2 Budget

`hir::range::maxExactValues = 32` (a named constant, `hir/range.tcl`):
comfortably above the required minimum of 16 (`HighNibble`'s own domain),
with headroom for a small branch join, chosen per spec \167 27's own
"16 or 32 are reasonable."

### 6.3 Join / narrow / widen / transfer

- **Join** (`hir::range::join`): unions both sides' exact sets when both are
  tracked and the union fits the budget; drops to interval-only the moment
  either side is untracked or the union would exceed it. `if cond: x=0 else:
  x=255` therefore produces `[0,255]` with exact set `{0,255}` with **no
  code specific to this pattern** -- it falls straight out of `point`
  carrying its own singleton and `join` unioning two tracked sets (verified:
  `tests/hir-range-exact.test`'s `range-exact-branch-join`).
- **Arithmetic transfer** (`add`/`sub`/`mul`, via new `CrossExact`): computes
  the pairwise cross product when `|A|*|B| <= 32`, else declines (checked
  *before* the O(n·m) work, never after) -- `{1,2}+{10,20} ->
  {11,12,21,22}` stays exact; two 32-value sets never trigger a 1024-pair
  product (`tests/hir-range-exact.test`'s `range-exact-expensive-transfer-widens`).
- **Comparison narrowing** (`Narrowed`, extended): a `<,<=,>,>=` branch
  filters an already-tracked exact set by the same interval bound it already
  computes -- `x = {1,4,7,10}; x<7` narrows the true branch to `{1,4}`, false
  to `{7,10}` (`range-exact-comparison-filter`).
- **Equality narrowing** (new `ExactEqualityNarrowing`/`PointEqualityNarrow`,
  independent of `hir/induction.tcl`'s own monotone-termination proof): `x ==
  K` (K a proven point) narrows `x` to exactly `{K}` when true; the false
  branch removes `K` from `x`'s own tracked exact set --
  `x : {0,16,32}; x != 16` narrows the false branch to `{0,32}`
  (`range-exact-equality-filter-false`).
- **Widening** (`widen`, induction fixpoint): deliberately never carries an
  `exact` key forward -- a growing induction variable has no finite set left
  to track once it starts widening.
- **Normalization** (`Normalize`, the single funnel every producer above
  goes through): a set larger than budget, or exactly as dense as its own
  interval (spec \167 106-108 -- `{0,1,...,15}` says nothing `[0,15]` doesn't
  already), is never stored.
- **Unreachability** (spec \167 84): deliberately **not** implemented via this
  lattice. A filter that would produce an empty exact set (an
  unsatisfiable equality, for instance) falls back to the unfiltered
  interval instead of trying to represent "no value" through `Range`'s own
  bottom (`never`) -- plumbing that would require every binding-range
  consumer in this file to additionally handle a binding whose range is
  `never`, which this milestone does not add. Documented here rather than
  silently narrowed away, per spec \167 71's own "if not, document the
  missing consumer."

### 6.4 `HighNibble`'s own exact set

`core/scalarbits.tcl`'s `IsHighNibble` validator *is* the 16-value domain
`{0,16,...,240}`; this milestone did **not** additionally wire "seed
`hir::range`'s exact set from a value's own named type" (spec \167 40's
`HighNibble -> [0,240]` interval seeding is real -- see \167 6.5 -- but the
*exact*-set seed from the type itself is not). This is a genuine, deliberate
scope cut, not an oversight: reaching it would need either (a) a
type-directed range-seeding consumer this milestone does not add, or (b)
teaching `hir::range::BitOp` "known-zero-bits" reasoning (`bit_and(x, 0xF0)`
always has its low 4 bits clear) that spec \167 86 explicitly defers. What
*is* demonstrated, directly, is the general mechanism `HighNibble` motivates:
`tests/scalarbits.test`'s `scalarbits-highnibble-exact-set` proves the
type's own validator enforces exactly `{0,16,...,240}` (not "every int in
`[0,240]`"), and `tests/hir-range-exact.test` proves the *general* exact-set
lattice can represent and propagate a set shaped exactly like it (see
`range-exact-sparse-survives-normalize`, which uses `HighNibble`'s own 16
values as its test data, with zero `HighNibble`-specific code in
`hir/range.tcl` itself -- spec \167 35's "the mechanism must not contain
concepts named HighNibble").

### 6.5 Interval-only facts for the bitwise ops (`BitOp`)

`bit_and`/`bit_or`/`bit_xor`/`shift_right` get sound (not always tightest)
interval bounds in `hir::range::Call`, generically, with no per-type
knowledge (\167 5 above has the exact proof for each). `Byte -> [0,255]`,
`Nibble -> [0,15]`, `LowNibble -> [0,15]`, `HighNibble -> [0,240]` (spec
\167 40) are true of these types' own *validators*, verified directly by
`tests/scalarbits.test`'s boundary tests; feeding them into `hir::range` as
*seeded* parameter facts (rather than validator-checked construction facts)
is the same, not-taken, type-directed-seeding extension as \167 6.4.

## 7. A hard architecture wall this milestone discovered

The original design put `byte::high_nibble`/`byte::nibble`/etc. behind
**natives** with a declared `HighNibble`/`Nibble` result type and a
`-native-body` (or `-module-fn`) bridge to the underlying bit ops, exactly
mirroring `uriEscape`/`web::uri_escape_text`. This compiled and ran
correctly for a native called *directly from an `.ir` program's own
top-level code* (confirmed: `nibble(byte::high_nibble(171))` as a literal
`.ir` call). It **failed** natively (`NATIVE UNSUPPORTED`) the moment the
same native was called from *inside* a cross-file module function -- exactly
`byte::high_nibble`'s own real shape, and `web.bot`'s.

Root cause, traced directly (`native/native.tcl`): `ExpandNativeBodies`
(substitutes `-native-body`) and `ModuleNativeBridge` (retargets a
`-module-fn` native) are **both** driven by `ExpandNativeBodiesIn`'s own
recursive walk, which only ever traverses a program's **raw core IR
exprs** -- the literal `.ir` file's own top-level expression list -- never
the HIR a cross-file `.bot` module's own body compiles to. A native whose
sole native-lowerable form is `-native-body`/`-module-fn` is therefore
Cranelift-unsupported the instant it is reached only from inside another
module's compiled function, regardless of how trivial its underlying
operation is.

This is a genuine, previously-undocumented (as far as this milestone found)
boundary of an established, working mechanism (`uriEscape` never hits it,
because it is always called directly from a program's own top level in
every existing test/benchmark). **The fix taken**: `byte::high_nibble`,
`byte::low_nibble`, `byte::nibble`, `byte::complement`, `byte::position_low`,
`byte::position_high` are **ordinary, plainly-typed Botlish functions**
(`lib/byte.bot`) over `bit_and`/`bit_or`/`bit_xor`/`shift_left`/`shift_right`
-- which *are* real entries in `native/lower.tcl`'s op table, so calling
them needs no substitution or bridging of any kind, from any call site,
module-nested or not. The cost: the nominal `HighNibble`/`LowNibble`/
`Nibble` type label does not survive the `byte::` call boundary (a call to
`byte::high_nibble(b)` from another module infers plain `int`, not
`HighNibble`) -- \167 6.5's interval facts (and, where the caller's own
argument is itself a tracked exact set, \167 6.3's propagation) recover
equivalent *fact* precision independently of that label, which is what spec
\167 103/105 actually asks diagnostics to demonstrate. Not investigated
further: whether `ExpandNativeBodiesIn`/`ModuleNativeBridge` could be
extended to also walk into loaded module sections -- a real, bounded-looking
extension, but a change to a different, carefully-designed subsystem, out of
this milestone's "smallest capability" scope.

## 8. Native (Cranelift) lowering: mask/shift, not a branch ladder

Direct NIR evidence (`native::nir`, `bench/refined-checks.ir` after this
milestone's rewrite):

```
func 1 "byte::high_nibble" params=1 ... rawregs="2" @e2
    %1 = int 240 @e6
    %2 = rawint 240
    guard int %0 "bit_and" @e3
    %3 = op iand %0 %1 @e3
    ret %3
end

func 2 "byte::nibble" params=1 ... instance="int" rawregs="2 5" @e14
    %1 = int 15 @e20
    %2 = rawint 15
    %3 = op iand %0 %1 @e17
    %4 = int 4 @e24
    %5 = rawint 4
    %6 = op ishr %0 %4 @e21
    %7 = op ior %3 %6 @e15
    ret %7
end
```

`byte::high_nibble`: one `guard int` (a kind check on its own parameter --
present because this call site's argument isn't statically proven `int`,
not because of anything `byte::high_nibble` itself needs) + one `iand` + ret.
No comparison, no branch, no loop, no call. `byte::nibble`: `iand` + `ishr` +
`ior` + ret -- again no comparison, branch, or call anywhere; no `guard` at
all here, since its argument (`byte::high_nibble`'s own result) is already
statically `int` at this call site. Confirmed structurally by
`tests/native-byte.test`'s `native-byte-high-nibble-nir-is-mask-not-branch`
(greps the generated NIR text directly for the *absence* of `ilt`/`ile`/
`igt`/`ige`, not merely for the program compiling).

`iand`/`ior` compile to a single Cranelift `band`/`bor` instruction on the
tagged words directly (`int_bitop`, \167 4 above) whenever both operands are
already proven small-tagged (`both_small_split`'s existing runtime test,
unchanged); `ishr` is a real helper call (`rt_int_shr`) -- the one place this
milestone did not give a branch-free fast path (\167 4's own scope note: unlike
AND/OR, a tagged word's shift does not correspond to shifting the logical
integer, so a fast path needs unbox/shift/rebox, a materially larger, riskier
Cranelift-IR change this milestone chose not to attempt; `IMod` already
occupies exactly this same "helper call, no fast path" tier, so this is not
a new class of cost in this codebase).

## 9. Semantic parity across backends

**Where it holds, unconditionally**: `bit_and`/`bit_or`/`bit_xor` are total
over every Int on every backend (no error path exists to diverge on).
`shift_left`/`shift_right`'s shift-amount check
(`core::scalarbits::CheckShiftAmount` / `native/src/runtime/ops.rs`'s
`shift_amount`) is mirrored exactly (same bound, same `RANGE` error) in both
the Tcl reference and the Rust runtime helper, and is exercised on every
backend since `IShl`/`IShr` are *always* real calls (\167 8) -- confirmed by
`tests/native-byte.test`'s `native-shift-range-error-parity`.
`byte::high_nibble`/`byte::low_nibble`/`byte::nibble`/`byte::complement`/
`byte::position_low`/`byte::position_high` are exhaustively verified
identical across `interp`/`compile`/`cranelift-generic`/`cranelift` for
every value in their real domain (\167 11).

**Where it does not, by design, and why this is pre-existing, not new**: the
four checked constructors' *validity check* is `interp`/`compile`-only (\167 4);
calling `Byte(300)` gets a clean `{CORE SEMANTIC RANGE}` there and
`NATIVE UNSUPPORTED` on Cranelift. Separately, declaring a native's
`-param-types` as a *named* refined type (not the base kind) and calling it
with an argument whose static type isn't already exactly that refinement
produces divergent behavior for an *invalid* value specifically (interp/
compile: a `{CORE CONTRACT TYPE}` contract-violation error via the existing,
unconditional post-call `AssertCanonical` check every native already gets;
Cranelift: no check exists, so an invalid value is silently accepted).
Confirmed this is not new to this milestone: `Emailish?`/`UriQueryValue?`
already have the identical property (compiled code "never re-checks
[declared types]... generic calls go through the runtime, which checks" --
`README.md`, pre-existing). This milestone's own natives sidestep it
entirely by declaring every bit-operation's param type as plain `int` (\167 5's
"total over every Int" is exactly what removes the need to ever hit this
gap) -- the four *constructors* are the only place a named refined param
type is declared, and there the gap is fully closed by being honestly
unsupported on Cranelift rather than silently divergent.

## 10. Testing

- `tests/scalarbits.test` (20 tests): bitwise primitive correctness
  (including bigint-sized operands, negative operands, shift-amount RANGE
  errors), all four constructors' full boundary behavior (`-1`/`0`/`15`/`16`
  for `Nibble`; `-1`/`0`/`16`/`240`/`241`/`255`/`15`/`17` for `HighNibble`,
  explicitly distinguishing "in interval" from "in exact valid set"),
  predicates and branch refinement, interp/compile differential parity, "no
  wrapper" (`integer?` on every domain value).
- `tests/hir-range-exact.test` (16 tests): the exact-value-set lattice in
  isolation (point/join/widen/dense-normalization/budget) and through real
  HIR (branch join producing `{0,255}`, a three-way join, `<`-branch
  filtering, `==`/`!=`-branch filtering) -- deliberately generic, using
  `HighNibble`'s own 16 values as test data in exactly one case, with no
  other reference to `Byte`/`Nibble`/`HighNibble` anywhere in the file (spec
  \167 60's own instruction).
- `tests/native-byte.test` (12 tests): four-way (`interp`/`compile`/
  `cranelift-generic`/`cranelift`) parity for every `byte::` operation;
  **exhaustive** (all 256 `Byte` values, all 16 `Nibble` values) checks of
  the reconstruction invariant (`byte::high_nibble(b) | byte::low_nibble(b)
  == b`), the normalization invariant (`byte::nibble(byte::high_nibble(b)) ==
  b >> 4`, `byte::nibble(byte::low_nibble(b)) == b mod 16`), `byte::complement`
  being its own inverse, and `position_low`/`position_high` round-tripping
  through `byte::nibble` -- each checked on all four backends via a single
  compiled recursive-accumulator program, not 256 separate test cases;
  direct NIR-text inspection proving `byte::high_nibble` has no comparison
  instruction; `bench/refined-checks.ir`'s own value (`[400, 0]`) on
  `cranelift`, matching `compile` exactly, unchanged from
  `NATIVE-OPAQUE-REFINEMENT.md`'s own pre-milestone baseline; a direct
  string check that `web.bot` no longer contains the old ladder's own
  `b <= 239` line.
- **Regression**: `tclsh9.0 tests/all.tcl` -- 55 test files (1553 tests:
  1505 pre-existing + 48 new across the 3 new files), 0 failed (re-verified
  after every source change in this diff, most recently as this report was
  written). `cargo test --release --manifest-path native/Cargo.toml` --
  60/60 passed; no Rust test was added or removed, only new production
  functions (`rt_int_and`/`rt_int_or`/`rt_int_xor`/`rt_int_shl`/`rt_int_shr`
  and their NIR/codegen wiring). 11 pre-existing tests' pinned
  `hir::range::show`/raw-dict expected strings updated (never their
  underlying assertions) to include the new exact-set annotations --
  exactly the same kind of intentional pin update
  `NATIVE-OPAQUE-REFINEMENT.md` \167 1 made for its own milestone.

## 11. Benchmark evidence: `refined-checks`

| | before (this milestone) | after |
|---|---|---|
| Cranelift value | `[400, 0]` | `[400, 0]` (unchanged) |
| Machine code, total | 26317 bytes (`NATIVE-OPAQUE-REFINEMENT.md` \167 11) | **16655 bytes** |
| Function count | 30 | **27** |

A ~37% reduction in total machine-code size and 3 fewer compiled functions,
directly attributable to replacing the 15-branch `high_nibble` ladder (15
nested `if`/`ilt`/`ile` comparisons, each its own conditional branch) with
`byte::high_nibble`+`byte::nibble`'s two tiny functions (\167 8: 5 instructions
total between them, one guard, zero branches). `compile`/`cranelift`
continue to agree exactly (`[400, 0]`); `interp` continues to hit Tcl's own
recursion-depth limit at this benchmark's `n=400` depth, confirmed
unrelated to this milestone (pre-existing, per `NATIVE-OPAQUE-REFINEMENT.md`
\167 12). Scalar regression controls (`fib.ir`, `loop-count.ir`,
`sum-refined.ir`) were not re-benchmarked for timing: this milestone touches
no code path any of the three exercises (none uses `Byte`/`Nibble`/bitwise
ops), so no timing regression is plausible there and none was measured --
consistent with spec \167 88's "do not require a specific speedup" and \167 95's
"do not claim broad performance impact if no other corpus program uses the
new types yet."

## 12. Scope: what this milestone explicitly did not touch

- **No `Bytes` container.** `Bytes = an immutable packed sequence of Byte`
  is the anticipated future relationship (spec \167 116); nothing here
  implements it. `byte::high_nibble`'s/`byte::low_nibble`'s scalar `Byte`
  result type is exactly the "already-established scalar result type" a
  future `Bytes[index] -> Byte` would want (spec \167 7).
- **No ASCII/encoding interpretation.** No `byte::is_ascii_*`, no
  `ascii::`/`encoding::ascii::` namespace, no character-class reasoning
  anywhere in `core/scalarbits.tcl` or `lib/byte.bot`.
- **`is_unreserved` is untouched**, byte-for-byte, deliberately -- it remains
  the acceptance case for the next (ASCII-interpretation) milestone, whose
  likely shape (spec \167 99):
  ```botlish
  fn is_unreserved(b: Byte):
      ascii::is_alphanumeric(b) or b == ...
  ```
  is now buildable on top of this milestone's `Byte` type and bit
  primitives, but no such syntax or namespace exists yet.
- **No String construction/join work** (the `STRING-BYTES-CONSTRUCTION-AUDIT.md`
  milestone this one was explicitly ordered before) was touched.
- **No general known-bits analysis** (`known_zero_bits`/`known_one_bits`) --
  \167 6.4 already covers exactly where this would have been used and wasn't.
- **No type-directed range/exact-set seeding** from a named type
  (`HighNibble`'s own validator feeding `hir::range` directly) -- \167 6.4.
- **The `ExpandNativeBodies`/`ModuleNativeBridge` cross-module gap** (\167 7) is
  reported, not fixed.

## 13. Answers to the milestone's required questions

**Type questions (1-12)**

1. **What exactly is `Byte`?** A validator-backed refined `int` type, `0 <=
   n <= 255`; at runtime, an ordinary Int, no wrapper.
2. **What exactly is `Nibble`?** A validator-backed refined `int` type, `0
   <= n <= 15`, meaning "a logical four-bit value."
3. **Why are `Nibble` and `LowNibble` distinct despite both currently having
   numeric values 0..15?** `Nibble` means "logical value"; `LowNibble` means
   "already positioned in the low half of a Byte" -- distinct semantic
   identities that happen to share a numeric domain today (\167 3), the same
   way two structurally-identical validator types can be nominally distinct
   anywhere else in this type system.
4. **What exactly is `HighNibble`?** A validator-backed refined `int` type
   whose domain is exactly `{0,16,32,...,240}` (16 values), not every
   integer in `[0,240]`.
5. **Does `HighNibble` transparently retain its shifted value?** Yes --
   `HighNibble(0xA0)` *is* the Int `160`; there is no separate "positioned"
   representation to retain or lose.
6. **What does `byte::high_nibble(0xAB)` produce?** `0xA0` (`160`),
   statically `HighNibble`'s own domain (an ordinary `int` once called from
   another module -- \167 7), by construction.
7. **What does `byte::nibble(byte::high_nibble(0xAB))` produce?** `0xA`
   (`10`).
8. **What does `byte::low_nibble(0xAB)` produce?** `0xB` (`11`).
9. **What conversions are checked?** Only the four explicit constructors
   (`Byte(x)`/`Nibble(x)`/`LowNibble(x)`/`HighNibble(x)`), and only on
   interp/compile (\167 4, \167 9).
10. **What conversions are proof-preserving/check-free?**
    `byte::high_nibble`/`byte::low_nibble`/`byte::nibble`/`byte::complement`/
    `byte::position_low`/`byte::position_high` -- every one of them, on every
    backend, always (\167 4, \167 8): each is total by construction over its
    own declared domain.
11. **Are any wrapper objects allocated?** No, none, anywhere (\167 3, \167 6).
12. **What machine representation is used during computation?** The same
    tagged-word (`(n<<1)|1`) small-Int / `BigIntObj` representation every
    other Botlish Int already uses; `AND`/`OR` on two small-tagged words
    compute directly on the tagged bits (\167 4, \167 8).

**Bit-arithmetic questions (13-20)**

13. **Result types of `&`,`|`,`^`,`~` for `Byte`?** `bit_and`/`bit_or`/
    `bit_xor` are declared `int -> int -> int` (generic); their *interval*
    result for `Byte`-domain operands is proven `[0,255]`-consistent by
    `BitOp` (\167 6.5), not by a declared nominal type. There is no generic
    `~`; `byte::complement : Byte -> Byte` is the Byte-specific one's
    complement (\167 5).
14. **Which operations preserve `HighNibble`/`LowNibble` specifically?**
    None nominally, by declared type, once called across a module boundary
    (\167 7); `BitOp`'s interval reasoning proves the equivalent *fact*
    generically (\167 6.5).
15. **Can `HighNibble | LowNibble` prove `Byte` directly?** Yes, via
    `BitOp`'s generic `bit_or` rule (\167 5's own walkthrough) -- interval
    `[0,255]`, no dedicated rule.
16. **How are generic shifts defined for these types?** `shift_left`/
    `shift_right` are plain `Int -> Int -> Int` natives (any value, a
    nonnegative bounded shift amount) -- see \167 5, no type-specific
    semantics at all.
17. **Which nibble transformations use named typed operations rather than
    generic shifts?** `byte::nibble` (normalization) and
    `byte::position_high` (positioning) are both *implemented* with
    `shift_right`/`shift_left` but *exposed* as named, total, unchecked
    operations with a stronger contract than the generic shift underneath
    (spec \167 20).
18. **Does high-nibble extraction lower to a mask rather than a branch
    tree?** Yes -- confirmed directly in generated NIR (\167 8): one `iand`,
    no comparisons.
19. **Does normalization lower to a shift?** Yes, plus a mask and an OR
    (\167 8) -- three branch-free ALU ops, not "shift alone," because the
    formula is deliberately branch-free and total over both nibble
    positions (\167 5).
20. **Does the composition simplify to essentially one right shift for
    web.bot's logical high-nibble use?** Close, honestly reported as such:
    `byte::high_nibble` is one `iand`; `byte::nibble` is `iand`+`ishr`+`ior`.
    Four ALU instructions total (plus one kind guard), zero branches, zero
    calls except `ishr`'s own helper call (\167 8) -- not literally "one
    shift" (that would need the known-zero-bits reasoning \167 6.4/spec \167 86
    defers), but the qualitative claim ("branch ladder -> mask/shift-sized
    straight-line sequence," spec \167 53) is fully met and measured (\167 11).

**Finite-set questions (21-32)**

21. **How are exact finite integer alternatives represented?** A sorted,
    deduplicated Tcl list under `Range`'s new `exact` key (\167 6.1).
22. **Stored alongside intervals or instead of intervals?** Alongside,
    always -- `exact`, when present, is always a subset of `[min,max]`, and
    every existing interval computation is completely unchanged (\167 6.1,
    \167 6.3).
23. **Cardinality budget?** 32 (`hir::range::maxExactValues`), a named
    constant (\167 6.2).
24. **What triggers widening (of the exact set)?** Exceeding the budget in
    `Normalize`/`CrossExact`/`join`, or reaching `hir::range::widen`
    (induction fixpoint) at all (\167 6.3).
25. **What remains after widening?** The interval, always, exactly as
    precise as it would have been without this milestone (\167 6.1, \167 6.3).
26. **How are joins handled?** Union of both sides' tracked sets, within
    budget; interval join is completely unaffected either way (\167 6.3).
27. **How are comparison branches filtered?** `Narrowed`
    (`<,<=,>,>=`) filters by the same bound it already computes for the
    interval; `ExactEqualityNarrowing` (`==`/`!=`) narrows to a singleton or
    removes one value (\167 6.3).
28. **How are singleton sets related to existing exact constants?** A point
    Range (`min==max`) is definitionally an exact singleton; no separate
    "constant" representation exists or was added (\167 6.1's `ExactOf`).
29. **Are dense contiguous sets canonicalized back to intervals?** Yes,
    always (`Normalize`, \167 6.3) -- verified
    (`range-exact-dense-canonicalizes-to-interval`).
30. **Does `HighNibble` retain the exact 16-value sparse set?** The type's
    own validator *is* that exact set (verified,
    `scalarbits-highnibble-exact-set`); `hir::range`'s general lattice can
    represent and propagate a set of that exact shape (verified,
    `range-exact-sparse-survives-normalize`), but no automatic seeding from
    the *named type* into a tracked `hir::range` fact exists (\167 6.4,
    documented gap, not implemented).
31. **Can a branch join such as `{0,240}` prove a later `HighNibble`
    conversion valid where interval `[0,240]` alone cannot?** The lattice
    mechanism that would let it (join producing a genuine sparse two-element
    exact set from two literals) is implemented and tested
    (`range-exact-branch-join`); wiring that fact into eliding a
    `HighNibble(x)` constructor's own runtime check is not (the constructors
    are unconditionally checked -- \167 4 -- and Cranelift-unsupported
    regardless, \167 9), so this specific composed claim is not demonstrated
    end-to-end. Documented rather than implemented, per spec \167 71.
32. **Does finite-set analysis remain bounded on adversarial test cases?**
    Yes -- verified directly: two 32-value sets do not trigger a
    combinatorial cross product (`range-exact-expensive-transfer-widens`,
    checked *before* any O(n·m) work runs, not merely capped after).

**`web.bot` questions (33-42)**

33. **How many source lines/branches did old `high_nibble` require?** 15
    nested `if`/`else` levels, ~47 source lines.
34. **What is its new source form?** `byte::nibble(byte::high_nibble(b))`,
    2 lines.
35. **What type does its parameter have?** Unannotated (Botlish has no
    parameter type-annotation syntax -- see \167 14 below); dynamically, any
    Int `b` was already passed here.
36. **What type does it return?** Dynamically a plain Int in `[0,15]`;
    statically, plain `int` (\167 7's cross-module gap -- see \167 6.5 for the
    interval fact that survives instead).
37. **What intermediate type does `byte::high_nibble` produce?** `HighNibble`
    when reasoned about directly (\167 3); plain `int`, with a provably
    `[0,240]` interval, once called from another module (\167 6.5, \167 7).
38. **Does `hex_digits` indexing consume `Nibble` without conversion
    noise?** `hex_pair`'s `list_get(hex_digits, high_nibble(b))` is
    unchanged source (still calls the *local* `high_nibble` wrapper, whose
    body is now the one-liner) -- no caller-side conversion was needed at
    all (spec \167 50-51): `high_nibble(b)`'s call sites in `web.bot` are
    completely unmodified.
39. **Did any redundant runtime range/bounds check remain?** No -- confirmed
    directly in NIR (\167 8): zero comparison instructions in either
    `byte::high_nibble` or `byte::nibble`.
40. **How much did `high_nibble`'s NIR/VCode/assembly shrink?** From 15
    nested compare-and-branch HIR `if` nodes (one Botlish function) to 2
    tiny Cranelift functions totaling 5 ALU instructions, 1 guard, 0
    branches, 1 helper call (\167 8); whole-program machine code 26317 ->
    16655 bytes, 30 -> 27 functions (\167 11).
41. **What happened to `refined-checks`'s runtime and machine-code size?**
    Code size: -37% (\167 11). Value: unchanged (`[400,0]`). Wall-clock
    timing was not re-measured (\167 11's own note: this benchmark's dominant
    cost was never `high_nibble` to begin with, and no timing regression is
    plausible from a strictly-smaller, branch-free replacement).
42. **Was `is_unreserved` deliberately left unchanged?** Yes, byte-for-byte
    (verified, `native-refined-checks-no-old-ladder` checks `high_nibble`'s
    own marker line is gone while leaving the file otherwise intact).

**Scope questions (43-50)**

43. **Was any ASCII behavior added to `byte::`?** No.
44. **Was any `Bytes` container added?** No.
45. **Was any UTF-8 behavior added?** No.
46. **Was join/String construction touched?** No.
47. **Was generic known-bits analysis added?** No (\167 6.4, \167 12).
48. **What is deliberately deferred to the ASCII milestone?** `ascii::is_alpha`/
    `is_digit`/`is_alphanumeric` etc., taking `Byte`, returning `Bool` (spec
    \167 98) -- `Byte` and the bit primitives are now available for it to build
    on; nothing about the interpretation layer itself exists yet.
49. **What is deliberately deferred to the future `Bytes` milestone?**
    `Bytes = immutable packed sequence of Byte` (spec \167 116) -- `Byte` as a
    scalar element type is settled independently of any container
    representation, exactly as asked (spec \167 7).
50. **Did this milestone reveal any type-system limitation that should be
    resolved before either?** Yes, one, significant: \167 7's
    `ExpandNativeBodies`/`ModuleNativeBridge` cross-module-call gap. A future
    milestone wanting a *nominally*-typed (not just plainly-typed)
    cross-module native -- e.g. an eventual `Bytes[index] -> Byte` needing
    its own declared result type from inside a module function -- will hit
    this exact wall unless it is fixed first or that future work is
    restricted to natives called only from program top level.

## 14. Type declaration mechanism: why validator-refined `int`, not something new

Per spec \167 78-79's own instruction to identify and justify this before
implementing: three candidates existed --

1. **A new, dedicated "bounded scalar" primitive mechanism.** Rejected: would
   duplicate `core::type.tcl`'s existing validator machinery
   (`subtype`/`lub`/`narrow`/`acceptsValue`) wholesale for no new capability
   -- every one of `Byte`/`Nibble`/`LowNibble`/`HighNibble`'s domains is
   exactly expressible as "a predicate over an `int`."
2. **Opaque refined types** (like `UriQueryValue`), with a trusted native
   minting runtime evidence. Rejected outright: `core::type::register`'s own
   precondition restricts `-opaque` to `evidenceKinds = {str}` -- an `int`
   opaque type isn't even constructible in the current registry without a
   change to that restriction, which would be a second, needless
   architecture change on top of the one below.
3. **Validator-backed refined `int` types** (`Emailish`'s own mechanism,
   `-base int` instead of `-base str`). **Chosen.** Zero changes to
   `core/type.tcl` itself; every one of `Byte`/`Nibble`/`LowNibble`/
   `HighNibble`'s four domains -- including `HighNibble`'s non-contiguous
   one -- is exactly a validator predicate; structural (not evidence-based)
   membership checking is what makes "no runtime wrapper" (\167 3) free, since
   nothing has to be attached to or stripped from a value at any operation
   boundary.
