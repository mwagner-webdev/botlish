# Bounded bit-shift lowering: generic exact bitwise transfer + raw shift native lowering

This milestone continues directly from `BYTE-NIBBLE-BIT-ARITHMETIC.md` and
`CLOSED-CALL-PARAMETER-FACTS.md`. Those established that inside the real
compiled `byte::nibble<int>` instance (`bench/refined-checks.ir`'s
`web::high_nibble` chain), the parameter `x` already carries

```
x:
    semantic type: int
    interval: [0, 240]
    exact:    {0, 16, 32, ..., 240}
```

purely from the existing generic closed-call range fixpoint -- nothing here
is inferred from the function's name. What remained deficient was
downstream of that fact: `hir/range.tcl`'s `BitOp` ignored an operand's
exact set for `bit_and`/`bit_or`/`bit_xor`, and ignored the shift amount
entirely for `shift_right`; separately, native lowering's raw-representation
machinery (`native/lower.tcl`) excluded `iand`/`ior`/`ixor`/`ishl`/`ishr`
from raw eligibility altogether, so `ishr` always called the generic
`rt_int_shr` helper even when analysis already proved every precondition
that helper exists to check. This milestone fixes both layers, in that
order, with no code anywhere that mentions `Byte`/`Nibble`/`HighNibble`/
`byte::nibble`/`byte::high_nibble` by name.

## 1. Files changed

- `hir/range.tcl` -- `CrossExact` generalized to recompute a tight bound
  from the actual cross-product values (previously it only ever decorated
  a caller-supplied bound with an `exact` key); `BitOp`'s `bit_and`/
  `bit_or`/`bit_xor` cases now try that exact transfer before falling back
  to their pre-existing sound interval reasoning (AND's mask-submask
  enumeration is preserved as the *second* fallback, not removed);
  `shift_right` now consults the shift amount's own range/exact facts, not
  just the shifted value's; `shift_left` is a wholly new case (previously
  `shift_left` had no range transfer of any kind, native/lower.tcl's own
  natives table aside); a new `maxShiftLeftAmount` bound (§ 5.4) protects
  the whole file from a discovered compile-time hazard.
- `native/lower.tcl` -- `PureBitwiseEligible`/`FoldPureBitwise`/
  `WantConvert` (new): a lowering-time-only (never a HIR rewrite) generic
  simplification for pure `iand`/`ior`/`ixor` calls, hooked into
  `NativeCall`. `RawEligibleShift` (new): the raw-shift eligibility proof.
  `RawEligibleCall` extended to dispatch `ishr`/`ishl` to it, and to let a
  raw-eligible shift's own operands be demanded raw directly (no
  intermediate tagged value). `RawArithOrCompare` renamed to `RawIntOp`
  (spec's own naming instruction, § 31) and extended with the shift case.
  `NativeCall`'s own raw-eligible-operand branch extended with `ishr`/
  `ishl` -> `rishr`/`rishl`. A new `rawShiftMax` (64, the host word width)
  variable.
- `native/src/nir.rs` -- two new `OpCode` variants, `RIShr`/`RIShl` (raw
  shift): parsing, `raw_result`/`raw_operands`.
- `native/src/codegen/clif.rs` -- `RIShr`/`RIShl` lower directly to
  Cranelift's `sshr`/`ishl` on the already-raw operand (no unbox/shift/
  rebox scheme of its own: reuses the exact same `RBox`/`RUnbox` transitions
  every other raw op already uses -- § 6.3).
- `native/src/runtime/ops.rs` -- `RIShr`/`RIShl` added to `apply_op`'s
  "never a dynamic native" arm (the same one `RIAdd`/`RISub`/`RIMul`/etc.
  already occupy); *not* added to `op_may_allocate`/`op_may_error` (they
  never do either, by construction -- same as every other raw op).
- `tests/hir-range-bitop.test` (new, 29 tests) -- Phase A in isolation:
  exact AND/OR/XOR transfer, budget bounding, dense canonicalization, point
  results, shift-right/shift-left interval and exact transfer, the
  `maxShiftLeftAmount` safety bound.
- `tests/native-bitshift.test` (new, 20 tests) -- Phase B/C: the real
  `byte::nibble` closed instance's own facts/NIR/CLIF, `byte::high_nibble`
  staying on its existing tagged fast path, synthetic raw-eligible/
  raw-rejected cases (negative operand, BigInt operand, non-constant shift
  count, shift count >= the raw width, shift-left result overflow, a
  guard-needing operand), a raw-operand chain staying raw, and generic-path
  differential-parity regressions (negative shifts, BigInt shifts, invalid
  shift counts, values straddling the raw/small-Int boundary).
- `tests/native-byte.test` -- one test's setup changed (§ 8's own
  explanation); no assertion's *meaning* changed.
- `tests/refined-signatures.test` -- one test's example changed, one new
  test added, both explained in § 8.

No change to `core/scalarbits.tcl`, `lib/byte.bot`, `lib/web.bot`,
`hir/specialize.tcl`, `hir/types.tcl`, `hir/refine.tcl`, `core/type.tcl`, or
any other file. No new Byte/Nibble-specific code, opcode, or peephole
anywhere in this diff.

## 2. Phase A: `hir/range.tcl`

### 2.1 What `CrossExact` was, and what it is now

Before this milestone, `CrossExact` (`add`/`sub`/`mul`'s shared exact-set
transfer) took a precomputed sound interval `R` and, when both operands'
exact sets were tracked and the cross product was cheap, *decorated* `R`
with an `exact` key -- it never touched `R`'s own `min`/`max`. That was
correct for `+`/`-`/`*` only because interval arithmetic is already *tight*
for those three operations: the corner values `(a.min,b.min)` etc. that the
interval bound is computed from are always themselves members of the full
cross product, so recomputing bounds from the complete set could never do
better.

That tightness does not hold for `bit_and`/`bit_or`/`bit_xor`: their
existing interval reasoning is a sound *superset* bound (e.g. AND's "0..the
nonnegative operand's own max"), not a tight one. Decorating that loose
bound with an exact list would have been self-contradictory (a Range whose
`min`/`max` don't match its own `exact` set's `min`/`max` violates every
other consumer's assumption -- `ExactOf`, `fitsSmall`, `show`). So
`CrossExact` was generalized to recompute `min`/`max` from the *actual*
values in the cross product before calling `Normalize`:

```tcl
proc hir::range::CrossExact {r a b opProc} {
    ...
    if {$ea eq "" || $eb eq "" || [llength $ea] * [llength $eb] > $maxExactValues} {
        return $r
    }
    set values {}
    foreach x $ea { foreach y $eb { lappend values [{*}$opProc $x $y] } }
    set mn ""; set mx ""
    foreach v $values {
        if {$mn eq "" || $v < $mn} { set mn $v }
        if {$mx eq "" || $v > $mx} { set mx $v }
    }
    return [Normalize [dict create min $mn max $mx] $values]
}
```

This is proven to change nothing for `+`/`-`/`*` (their own corner values
are always members of the full cross product, so the recomputed bound is
provably identical to the old one) and is what makes the new callers below
correct.

### 2.2 Exact AND/OR/XOR transfer

`BitOp`'s `bit_and` now tries `CrossExact` *before* falling back to its
pre-existing sound-interval-then-submask-enumeration path:

```tcl
bit_and {
    set r [unknown]
    if {$ymn ne "-inf" && $ymn >= 0} {
        set r [dict create min 0 max $ymx]
    } elseif {$xmn ne "-inf" && $xmn >= 0} {
        set r [dict create min 0 max $xmx]
    }
    set cross [CrossExact $r $x $y {apply {{a b} {expr {$a & $b}}}}]
    if {$cross ne $r} { return $cross }
    if {$ymn ne "-inf" && $ymn >= 0 && $ymn eq $ymx} { return [AndMaskExact $r $ymn] }
    if {$xmn ne "-inf" && $xmn >= 0 && $xmn eq $xmx} { return [AndMaskExact $r $xmn] }
    return $r
}
```

`bit_or`/`bit_xor` are the same shape, minus the AND-specific submask
fallback. This is the mandatory case (spec § 7), verified directly
(`tests/hir-range-bitop.test`'s `bitop-and-primary-sparse-mask`):

```
{0,16,32,...,240} & {15}  ->  [0, 0] {0}
```

Generic (`tests/hir-range-bitop.test`'s own AND/OR/XOR tests, no HighNibble
involved): `{1,2,4,8}&{3} -> [0,2]` (dense, canonicalizes without a stored
`exact` key -- itself informative: spec § 8's own examples turn out to be
*dense* relative to their own interval once actually computed, not sparse
as the spec text's naive phrasing might suggest -- `{8,12}&{7} -> [0,4]
{0,4}` is the genuinely sparse one). `bit_or`/`bit_xor`:
`{0,16}|{1,2} -> [1,18] {1,2,17,18}` (tighter at *both* ends than the old
sum bound `[0,18]`, because 0 does not survive ORed with a nonzero value).

**AND-mask enumeration remains** (spec § 10): `bit_and(x, 15)` for an `x`
with no exact facts of its own still gets `[0,15]` from `AndMaskExact`,
unchanged.

**Budget**: unchanged at 32 (spec § 6); two 32-value sets never trigger a
1024-pair evaluation for any of the three ops (checked before the O(n·m)
work, per `CrossExact`'s own cardinality guard) --
`tests/hir-range-bitop.test`'s `bitop-budget-rejects-expensive-and`/`-or`.

### 2.3 A real, generic consequence: `bit_or` now combines two `bit_and`
results into their true union

`tests/refined-signatures.test`'s pre-existing `refined-signature-verify-4`
asserted `bit_or(bit_and(x,128), bit_and(x,112))` (for an unconstrained
`x`) does **not** prove a declared `-> HighNibble` result -- documenting a
known limitation of interval-only reasoning at the time it was written.
`bit_and(x,128)` and `bit_and(x,112)` already produced exact sets
(`{0,128}`, `{0,16,...,112}`) via the *pre-existing* `AndMaskExact`
fallback (unaffected by this milestone); what was missing was `bit_or`
ever combining them. It now does, generically, with zero code specific to
this composition:

```
bit_or({0,128}, {0,16,...,112}) = {0,16,32,...,240}
```

-- exactly `HighNibble`'s own 16-value domain, because `128` and `112` are
disjoint, contiguous bitmasks that together span it. This is now a real,
positive test (`refined-signature-verify-4`, updated) instead of a
documented gap; a new `refined-signature-verify-4b` pins the genuine
remaining limitation (one side's own mask exceeds the 32-submask budget,
so that side stays interval-only and the union correctly does not prove a
sparse type).

### 2.4 Shift-right: using the shift amount

```tcl
shift_right {
    if {$xmn eq "-inf" || $xmn < 0} { return [unknown] }
    set r [dict create min 0 max $xmx]
    if {$ymn eq "-inf" || $ymn < 0} { return $r }
    set mx [ShiftRightBound $xmx $ymn]
    set mn [expr {$ymx eq "+inf" ? 0 : [ShiftRightBound $xmn $ymx]}]
    set r [dict create min $mn max $mx]
    return [CrossExact $r $x $y {apply {{a b} {expr {$a >> $b}}}}]
}
```

Primary case (spec § 15, no exact set needed on `x`):
`[0,240] >> {4} -> [0,15]`. Exact case (spec § 16):
`{0,16,...,240} >> {4}` computes the true 16-value cross product
(`{0,1,...,15}`), which *canonicalizes back to `[0,15]`* (dense -- exactly
the spec's own predicted outcome, verified directly:
`bitop-shift-right-exact-transfer`). A possibly-negative or unproven shift
amount keeps the old, shift-amount-independent bound (sound, unchanged);
a possibly-negative shifted value stays `unknown` (spec § 19, § 47 --
deliberately not expanded).

### 2.5 Shift-left: symmetric interval/exact treatment, with a discovered
compile-time hazard and its fix

`shift_left` previously had no transfer at all (not even in `hir::range::Call`'s
own dispatch list). Added generically: `[xmn<<ymn, xmx<<ymx]` for
nonnegative `x`/`y`, plus the same `CrossExact` attempt. While building the
adversarial regression tests spec § 83/§ 92 ask for, this surfaced a real,
measured hazard, not a hypothetical one: shift-left is the first transfer in
this file whose result's *bit-length* grows linearly in one operand's own
*value* (the shift count), unlike `+`/`-`/`*`, whose result bit-length only
grows with its operands' own bit-lengths. A single `shift_left` call with an
ordinary-looking, individually-small shift count near `core/scalarbits.tcl`'s
own `MAX_SHIFT` (`1<<20`, a value this milestone's own generic shift
contract accepts as *valid*, not adversarial) produces a bound with roughly
a million bits. Computing that shift is fast (Tcl's arbitrary-precision
`<<` is linear in the result's bit-length), but this file's own sentinel
convention -- comparing a candidate bound against the literal strings
`"-inf"`/`"+inf"` via `ne`/`eq`, in `Normalize`'s own dense-interval check
among other places -- forces Tcl to materialize that bound's full decimal
text first. That conversion is quadratic; measured directly, a single
`shift_left` call with a shift count of `2^18` already cost **4.8 seconds**
in that one comparison alone, extrapolating past a minute at `MAX_SHIFT`
itself (confirmed: `hir::range::analyze` on `shift_left(5, 5000000)` did
not return within a 20-second timeout before the fix below).

The fix (`maxShiftLeftAmount`, 4096, `hir/range.tcl` § near its other named
budgets): `BitOp`'s `shift_left` case declines (falls back to `unknown`,
its ordinary sound-fallback idiom) whenever the shift amount's own upper
bound exceeds this threshold or is unbounded, *before* attempting either
the interval or the `CrossExact` computation --

```tcl
if {$ymx eq "+inf" || $ymx > $maxShiftLeftAmount} {
    return [unknown]
}
```

4096 is far above any realistic bit-manipulation shift (nibble/byte/word
positioning) and keeps the worst case a few milliseconds
(`tests/hir-range-bitop.test`'s `bitop-shift-left-amount-at-threshold-still-works`
confirms the bound is still computed *exactly*, not merely "did not
crash", right at the threshold; `bitop-shift-left-amount-too-large-falls-back`
pins the decline). This also happened to fix a second, related symptom
found in the same investigation: `shift_left(5, 99999999999)` (a shift
count that is itself invalid -- `>MAX_SHIFT` -- but numerically modest,
~37 bits) previously produced a *different* wrong outcome specifically on
`cranelift`/`cranelift-generic` (`error NONE {integer value too large to
represent}`, diverging from `interp`/`compile`'s correct `{CORE SEMANTIC
RANGE}`), because analysis tried to compute `5 << 99999999999` -- a
~12.5 GB bound -- before native lowering ever got a chance to reject the
call as raw-ineligible. With the cap in place all four backends agree
(`tests/native-bitshift.test`'s `bitshift-generic-invalid-count-parity`).

Negative operands/amounts remain conservative fallback to `unknown`
(spec § 19), matching `shift_right`'s own restriction.

## 3. Phase B: pure-bitwise simplification (`native/lower.tcl`)

This is a **lowering-time-only** decision -- exactly like raw
representation itself (§ 4 below): it never touches HIR, never changes
what a value *is*, only which instructions native code emits. Two
generic simplifications, both gated on `PureBitwiseEligible` (mirrors
`RawEligibleCall`'s own safety discipline: neither operand may still need a
runtime kind guard or known-error guard -- a call that does is not even
proven to evaluate to an Int, so no replacement would be sound):

1. **Singleton-result constant fold.** If `hir::range::of` already proves
   the whole `iand`/`ior`/`ixor` call's result a single value, the call
   becomes that Int constant directly, with no `op` instruction at all
   (spec § 23-26's own `x & 15 -> 0` example). Sound unconditionally for
   these three ops: they are pure, total, and allocation-free, and `Call`
   already evaluated both operands (with whatever side effects, if any)
   before `NativeCall` runs, so choosing not to emit the op never skips an
   evaluation.
2. **Zero/self identities**, decided purely from already-computed
   `hir::range` facts (no mask-specific or nibble-specific pattern
   anywhere):
   - `ior`/`ixor`: if one operand's own range is exactly `{0}`, the result
     is unconditionally the other operand's own value (`0|x`, `x|0`,
     `0^x`, `x^0` -- ordinary Int bit semantics, spec § 27).
   - `iand`: if one operand (`B`) is a single proven constant and the
     other (`A`) is nonnegative, and the call's own already-computed
     result range/exact-set is *identical* to `A`'s own, this AND changes
     nothing. Proof: AND-with-any-mask can only ever clear bits of a
     nonnegative `A` (`a&b <= a` for every `a>=0`, any `b`, in two's
     complement), so a finite value set that maps *onto itself* under a
     *fixed* mask is a self-map bounded above by the identity on every
     element -- on a finite set, that forces the identity map exactly
     (sort the set; its minimum can only map to itself, and induction up
     from there, using that the map only visits each output at most once
     -- the "same cardinality" precondition -- completes the argument).
     This is what removes the real body's own trailing
     `bit_and(..., 15)` (§ 5's own "final masking", § 5.2) once the OR
     it wraps is already proven to land in `[0,15]`.

Both are generic bitwise identities the milestone's own hard-scope list
explicitly allows ("generic trivial bitwise identities if needed for the
real simplification") -- neither is byte/nibble/mask-specific in its
*code* (the constants `0`/`15` never appear in `native/lower.tcl`; only in
the real program being compiled).

## 4. Phase C: raw shift lowering

### 4.1 Why shifts were excluded before

`iand`/`ior`/`ixor` already have a genuine branch-free fast path on the
*tagged* word (`int_bitop`, from the prior milestone): AND/OR/XOR of two
tag-1 words is still a valid tagged-word AND/OR/XOR of the logical
integers (the tag bit is fixed by construction for AND/OR, restored with
one `or` for XOR). A shift has no such property -- shifting the tagged word
`(n<<1)|1` shifts the *tag bit itself* into the payload, which is not the
same operation as shifting the logical integer `n`. So `IShl`/`IShr` were
always plain helper calls (`rt_int_shl`/`rt_int_shr`), with no fast path of
any kind, `IMod`'s own existing tier.

### 4.2 What makes a shift raw-eligible now (`RawEligibleShift`)

```tcl
proc native::lower::RawEligibleShift {e argExprs op} {
    ...
    if {!$reprOpt || [llength $argExprs] != 2} { return 0 }
    foreach a [list $ex $ek] {
        if {[dict exists $guards [list $e $a]] || [dict exists $knownErrors [list $e $a]]} { return 0 }
    }
    set rangeX [hir::range::of $ranges $currentInstance $ex]
    if {![hir::range::fitsSmall $rangeX] || [dict get $rangeX min] eq "-inf" || [dict get $rangeX min] < 0} { return 0 }
    set rangeK [hir::range::of $ranges $currentInstance $ek]
    set kmn [dict get $rangeK min]; set kmx [dict get $rangeK max]
    if {$kmn eq "-inf" || $kmn ne $kmx || $kmn < 0 || $kmn >= $rawShiftMax} { return 0 }
    set resultRange [hir::range::of $ranges $currentInstance $e]
    return [hir::range::fitsSmall $resultRange]
}
```

No type name anywhere. Every condition is a generic fact `hir::range.tcl`
already computes:

- neither operand needs a runtime kind guard (same discipline as ordinary
  arithmetic raw eligibility);
- the shifted value's own range fits the runtime's small-Int
  representation *and* is proven nonnegative (spec § 47's own deliberate,
  documented restriction -- see § 4.5);
- the shift amount is a *single* already-proven value (spec § 40's own
  conservative first cut), nonnegative, and strictly below `rawShiftMax`
  (64, the host machine word width -- **not**
  `core/scalarbits.tcl`'s much larger `MAX_SHIFT`; a proven constant this
  small is always inside that separate, generic-path-only contract, so
  raw eligibility never needs to consult it directly);
- the call's own already-computed result range (Phase A's own transfer)
  also fits the small-Int representation -- automatic for `shift_right`
  (which never grows the value), load-bearing for `shift_left` (spec
  § 38-39: growth, not the operand's own rawness, is what must be proven
  there).

### 4.3 Lowering (`RawIntOp`, renamed from `RawArithOrCompare`)

Renamed per the milestone's own naming instruction (§ 31): the old name
promised "arith or compare"; it now also covers shifts. Both the
already-raw-operands path (`NativeCall`'s own `rawEligible` branch) and the
declined-then-retroactively-checked path (`RawIntOp` itself) gained
`ishr rishr` / `ishl rishl` alongside the existing arithmetic/comparison
table, reusing the exact same `RawOf`/`AssignRaw`/`TaggedOf` machinery
every other raw op already uses -- no second unbox/shift/rebox scheme (spec
§ 36).

### 4.4 Native (Cranelift) codegen

```rust
RIShr => self.b.ins().sshr(a[0], a[1]),
RIShl => self.b.ins().ishl(a[0], a[1]),
```

`sshr` (arithmetic, sign-extending), not `ushr`: Botlish's `shift_right` is
an arithmetic (floor) shift for arbitrary-precision Int, and
`RawEligibleShift`'s nonnegative-operand restriction makes the two
coincide for every value that reaches this instruction. Both operands are
already raw (host i64) by the time this runs -- `RIShr`/`RIShl` join
`RIAdd`/`RISub`/`RIMul`/the `RI*` comparisons in `raw_operands()`/
`raw_result()`; no new representation-transition instruction, no second
`RBox`/`RUnbox`-shaped mechanism.

### 4.5 Deliberately not attempted

- **Negative shifted values.** `RawEligibleShift` requires `x >= 0`. A raw
  right shift of a negative host i64 (`sshr`) happens to already match
  Botlish's own arbitrary-precision signed floor-shift semantics for
  values that would fit raw either way, but this milestone did not
  attempt to rigorously extend the *proof* to the representation boundary
  for negative operands (e.g. a value near `smallMin`); spec § 47's own
  escape hatch ("if this complicates the milestone, restrict eligibility
  to a nonnegative operand") is exercised verbatim, documented here rather
  than silently narrowed.
- **A general known-bits/bit-vector solver.** Every fact above is either an
  interval, a single proven value, or a small bounded exact set --
  never "which specific bits are known clear," which spec § 86 explicitly
  defers.
- **AND/OR/XOR raw promotion.** Audited (spec § 30) and deliberately
  declined (spec § 32): their existing tagged-word fast path is already
  branch-free and already correct; raw promotion would only duplicate that
  work for no measured benefit, and the milestone's mandatory target is
  `ishr` (with `ishl` symmetric where the same proof discipline already
  covers it cleanly -- it does, so both landed together).

## 5. The real `byte::nibble` microscope

`lib/byte.bot`'s actual body (not the milestone brief's simplified
sketch) is

```
fn nibble(x) -> Nibble:
    bit_and(bit_or(bit_and(x, 15), shift_right(x, 4)), 15)
```

-- i.e. `(x & 15) | (x >> 4)`, *then* wrapped in one more `bit_and(..., 15)`,
the "final masking [the] broad all-Int implementation" needs so the
function is total and correct for *every* Int, not merely a Byte's own
domain. Both the "before" and "after" evidence below is freshly captured
from this session's own build (`bench/refined-checks.ir`, native `cranelift`
backend), not copied from an earlier report.

### 5.1 Before (this session's own HEAD, prior to this milestone's changes -- captured via `git stash`)

Parameter fact (unchanged by this milestone, already proven by the prior
milestone's own closed-call fixpoint):

```
x: [0, 240] {0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240}
```

Body facts (`hir::range::of` on each `bit_and`/`shift_right` call):

```
x & 15         :  [0, 15]        -- fails to prove exact 0
x >> 4         :  [0, 240]       -- ignores the shift amount entirely
(x&15)|(x>>4)  :  [0, 255]
((x&15)|(x>>4)) & 15 : [0, 15]
```

NIR (`native::nir`):

```
func 2 "byte::nibble" params=1 ... instance="int" rawregs="2 5 9" @e14
    %1 = int 15 @e22
    %2 = rawint 15
    %3 = op iand %0 %1 @e19
    %4 = int 4 @e26
    %5 = rawint 4
    %6 = op ishr %0 %4 @e23
    %7 = op ior %3 %6 @e17
    %8 = int 15 @e27
    %9 = rawint 15
    %10 = op iand %7 %8 @e15
    ret %10
end
```

`ishr` here is the plain helper form: Cranelift lowering calls
`rt_int_shr` unconditionally (§ 4.1). `byte::nibble`'s own machine code:
**329 bytes**. Whole-program (`refined-checks.ir`) machine code: **16713
bytes**, **27** functions. `count("op ishr")` across the whole program: **1**
(the only shift in the program, `byte::nibble`'s own, on the generic
helper path). `count("op iand")`: **3** (`byte::high_nibble`'s own mask,
`byte::nibble`'s inner `x&15`, and its outer final mask). `count("op ior")`:
**1**.

### 5.2 After (this milestone)

Body facts:

```
x & 15         :  [0, 0] {0}     -- Phase A's own mandatory case
x >> 4         :  [0, 15]        -- Phase A's shift-amount-aware transfer
(x&15)|(x>>4)  :  [0, 15]        -- (0 | y -> y is applied at lowering time, §4.2)
((x&15)|(x>>4)) & 15 : [0, 15]   -- unchanged as a *range fact*; removed at
                                    lowering time by the AND-identity, §3
```

NIR:

```
func 2 "byte::nibble" params=1 env=0 regs=12 pnames="x" captures=0 instance="int" rawregs="2 4 5 7 8 11" @e14
    %1 = int 15 @e22
    %2 = rawint 15
    %3 = int 0 @e19
    %4 = rawint 0
    %5 = op runbox %0
    %6 = int 4 @e26
    %7 = rawint 4
    %8 = op rishr %5 %7 @e23
    %9 = op rbox %8
    %10 = int 15 @e27
    %11 = rawint 15
    ret %9
end
```

`%1`/`%3`/`%10` are dead leftover constant materializations from the three
now-elided calls' own literal operands (Call evaluates every argument
unconditionally before the containing call decides whether to keep it --
§ 3's own note); no `iand`, no `ior`, no `guard`, no `raise`, survives on
this path. `count("op iand")` for the whole program: **1** (only
`byte::high_nibble`'s own, unchanged, § 4.5's own scope decision).
`count("op ior")`: **0**. `count("op ishr")`/`rt_int_shr` call sites for
the whole program: **0**. `count("op rishr")`: **1**.

True Cranelift IR (`native::clif`, `function u0:52`, `byte::nibble`'s own
compiled body verbatim):

```
function u0:52(i64, i64) -> i64 system_v {
block2(v0: i64, v1: i64):
    v7 -> v1
    jump block0
block0:
    v9 = sshr.i64 v7, v8      ; v8 = 1   (RUnbox: untag)
    v12 = sshr v9, v11        ; v11 = 4  (RIShr: the raw shift itself)
    v14 = ishl v12, v13       ; v13 = 1  (RBox, part 1: retag)
    v16 = bor v14, v15        ; v15 = 1  (RBox, part 2: retag)
    return v16
}
```

No `call` instruction anywhere in this function's own Cranelift IR -- true
machine-lowering evidence, not merely NIR text (spec § 73/§ 76:
`tests/native-bitshift.test`'s `bitshift-real-byte-nibble-clif-no-helper-call`
pins exactly this: no `call ` substring in this function's own CLIF text,
and an `sshr` present).

Actual x86-64 machine code (`objdump -d`, `native::object`'s own AOT
output, `botlish_fn_2` == `byte::nibble`):

```
0000000000000450 <botlish_fn_2>:
 450:  55                      push   rbp
 451:  48 89 e5                mov    rbp,rsp
 454:  48 c1 fe 05             sar    rsi,0x5
 458:  48 d1 e6                shl    rsi,1
 45b:  48 89 f0                mov    rax,rsi
 45e:  48 83 c8 01             or     rax,0x1
 462:  48 89 ec                mov    rsp,rbp
 465:  5d                      pop    rbp
 466:  c3                      ret
```

Cranelift's own instruction selector fused the two separate `sshr`
instructions in the IR above (untag-by-1, then the raw shift-by-4) into
**one** `sar rsi, 0x5` (5 = 1+4) -- the entire function is 8 machine
instructions: one combined arithmetic shift, one retag (`shl`+`or`), no
branch, no call, no guard, exactly matching the milestone's own stop
condition (§ 102) at the actual machine-code level, not merely NIR.
`byte::nibble`'s own machine code: **40 bytes** (was 329 -- an 88%
reduction for this one function). `byte::high_nibble`'s own machine code:
**203 bytes**, byte-for-byte unchanged (§ 4.5).

### 5.3 Why the outer `bit_and(..., 15)` disappears too

Phase A alone leaves `((x&15)|(x>>4)) & 15`'s own range fact at `[0,15]`
(unchanged from before -- it was already correctly `[0,15]`, just not
provably *redundant*). What removes the instruction is Phase B's
AND-identity (§ 3, case 2): the outer AND's own operand `A` (the OR's
result) has range `[0,15]`, its mask operand `B` is the proven constant
`15`, and the AND's own computed result range is *identical* to `A`'s own
-- exactly the "AND changes nothing" precondition, proven generically from
range facts, with the constant `15` never appearing in
`native/lower.tcl`'s own source.

## 6. Composition: `web::high_nibble` end to end

`web.bot`'s `high_nibble(b) = byte::nibble(byte::high_nibble(b))` still
compiles to two calls (`high_nibble`'s own NIR: `%1 = call 1 %0; %2 = call
2 %1; ret %2`) -- this milestone adds no inlining. `high_nibble`'s own
machine code: **96 bytes** (was 109 -- both callee functions shrank; the
call sequence itself is unchanged).

## 7. Benchmark/corpus evidence: `refined-checks`

| | before (this session's HEAD) | after (this milestone) |
|---|---|---|
| `cranelift` value | `[400, 0]` | `[400, 0]` (unchanged) |
| `compile`/`cranelift` agreement | `[400, 0]` / `[400, 0]` | `[400, 0]` / `[400, 0]` |
| Machine code, total | 16713 bytes | **16411 bytes** (-302, -1.8%) |
| Function count | 27 | 27 (unchanged) |
| `byte::nibble` code size | 329 bytes | **40 bytes** (-88%) |
| `byte::high_nibble` code size | 203 bytes | 203 bytes (unchanged) |
| `high_nibble` (web.bot wrapper) code size | 109 bytes | 96 bytes |
| `op ishr` (generic, helper) sites, whole program | 1 | **0** |
| `op rishr` (raw) sites, whole program | 0 | **1** |
| `op iand` sites, whole program | 3 | **1** |
| `op ior` sites, whole program | 1 | **0** |

Both builds were produced by rebuilding the native backend from the exact
same working tree via `git stash`/`git stash pop` (not from a previously
committed report), so these numbers are this session's own fresh evidence,
per spec § 61/§ 91's own instruction not to copy prior numbers. No
timing benchmark was re-run: this benchmark's dominant cost was never
`high_nibble` (`NATIVE-OPAQUE-REFINEMENT.md`'s and
`BYTE-NIBBLE-BIT-ARITHMETIC.md`'s own prior notes), and a strictly smaller,
call-free replacement of an already-small leaf cannot plausibly regress it;
consistent with spec § 70's own "do not require a particular speedup."

## 8. Test suite updates and why

Two pre-existing tests changed behavior *because the generic mechanism
this milestone was asked to build now proves more than it used to* -- not
because of any special-cased fix:

- **`tests/refined-signatures.test`'s `refined-signature-verify-4`**
  (§ 2.3 above): `bit_or(bit_and(x,128), bit_and(x,112))` now provably
  proves `HighNibble` for an *unconstrained* `x`, a direct, unavoidable
  consequence of adding exact transfer to `bit_or` (Phase A alone, no
  Phase B/C involvement). The test's assertion is flipped to the new,
  correct outcome; a new `refined-signature-verify-4b` preserves coverage
  of a genuine remaining limitation (one side's own submask budget
  exceeded).
- **`tests/native-byte.test`'s
  `native-byte-high-nibble-nir-is-mask-not-branch`**: its original
  `extract(200)` call site made `b`'s own entry range a true singleton
  (`point(200)`, via the *pre-existing* literal-seeding mechanism), which
  this milestone's Phase A (AND now consulting `x`'s own facts, not only
  the mask's) plus Phase B (singleton constant fold) together now
  legitimately eliminate the `iand` entirely -- correct, but it stopped
  testing what the test's own name promises: that an *arbitrary* `b`
  still lowers to a mask, not a branch. Its caller was changed to
  `extract(mod(200, 1000000))` (a genuinely non-singleton, `[0,+inf)`
  argument), restoring the test's original intent; the newly-enabled
  singleton-fold capability itself is covered by
  `tests/native-bitshift.test`'s own synthetic tests instead.

No other pre-existing assertion changed.

## 9. Regression evidence

- `cargo test --release --manifest-path native/Cargo.toml`: **60/60**
  passed (no Rust test added, removed, or changed -- only new production
  code, same as the prior milestone's own precedent).
- `tclsh9.0 tests/all.tcl`: **1635/1635 passed, 0 failed**
  (both the default and `compile`-backend passes; 59 test
  files, including this milestone's two new ones).
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **1635/1635 passed,
  0 failed** -- a raw shift result is never a managed heap pointer, and
  this confirms the existing root-map/safepoint machinery (spec § 77-79)
  correctly excludes it under forced-collection stress, with no separate
  rooting mechanism added. Run directly in this session's own Linux
  sandbox (not WSL); AGENTS.md's own WSL instructions are for validating
  stack-walking specifically against Windows's differing implementation,
  which this milestone's changes do not touch.
- `hir::range.tcl`'s new exact/shift transfer, and native lowering's new
  raw-shift/pure-bitwise-fold paths, are exercised on every corpus program
  `tests/all.tcl` already runs (`bench/*.ir`, `lib/*.bot`, every `.test`
  file's own programs) with no other regression.
- Cross-call/type-to-fact stability (spec § 55-56): the prior milestone's
  own `tests/hir-closed-call-params.test` and
  `tests/refined-signatures.test`'s type-domain tests pass unchanged
  (aside from § 8's own two updates, both explained as legitimate
  strengthenings, not regressions of the propagation mechanism itself).

## 10. Remaining abstraction cost, and the inlining question

After this milestone, `web::high_nibble(b)` still compiles to:

```
call byte::high_nibble(b)   -- one iand (tagged fast path, still correct/cheap)
call byte::nibble(...)      -- one raw sar + one retag (this milestone's own result)
```

i.e. two real function calls plus, inside `byte::nibble`, one tag
transition pair (`runbox`/`rbox`) that a caller *already holding* a raw
value for `x` could not avoid either way (the function boundary itself
requires a tagged ABI value in and out -- spec § 15/§ 27/§ 76's own
"unavoidable... existing ABI mechanics"). This milestone does not attempt
to remove the call boundary itself (spec § 29's own explicit
prohibition).

**Are the remaining costs predominantly function calls?** Yes, at this
point essentially entirely: both `byte::high_nibble` and `byte::nibble`
are now minimal (one branch-free ALU instruction sequence each, no
runtime helper, no guard in `byte::nibble`'s own case), so the two `call`
instructions and their own prologue/epilogue overhead are what remains,
not any further-optimizable arithmetic.

**Are any tagged/raw transitions still unnecessarily repeated?** No new
ones from this milestone: `byte::nibble`'s own `runbox`/`rbox` pair is
exactly one of each, required once by the function's own tagged ABI in and
tagged ABI out; nothing repeats it.

**Is a tiny closed leaf-inliner now clearly justified by the evidence?**
Recommend **yes, narrowly**, based on what this milestone's own evidence
now shows and could not show before it: both `byte::high_nibble` and
`byte::nibble` are now provably minimal, single-basic-block, call-free (or
call-free but for their own runtime-independent ALU ops), branch-free
leaves with a single call site each in the corpus (`web::high_nibble`'s
own two calls) -- exactly the shape a *narrowly scoped, exact-leaf-only*
inliner (never a general call-graph inliner) would need to recognize
safely. Before this milestone, `byte::nibble` still contained a genuine
helper call (`rt_int_shr`) and a `iand`/`ior` sequence, so inlining it
would have inlined real runtime-boundary complexity, not just arithmetic;
after it, inlining is now purely a matter of eliminating two call/return
sequences and their matching tag transitions around already-minimal
arithmetic -- a much smaller, better-justified next increment than it
would have been before this milestone's own work. This is a
recommendation, not an implementation: no inlining was added here (spec
§ 29, § 63, § 102, § 41 of the "required scope questions").

## 11. Required architecture questions

1. **How did `BitOp` represent bitwise facts before this milestone?** A
   sound interval only, derived from nonnegative-integer reasoning about
   each operation in isolation, plus (for `bit_and` specifically) bounded
   constant-mask submask enumeration when the *mask* operand alone was a
   known constant -- never consulting the *other* operand's own exact
   facts.
2. **How does exact-set transfer work now?** `CrossExact`, generalized
   (§ 2.1): given both operands' exact sets (tracked or reconstructible
   within budget), compute the true pairwise cross product and recompute
   the Range's own `min`/`max` from those actual values, then
   `Normalize`.
3. **Does it reuse `CrossExact` or a generalized equivalent?** The same
   `CrossExact`, generalized in place (not duplicated) so `add`/`sub`/`mul`
   and the new bitwise/shift callers share one implementation.
4. **What cost test happens before cross-product evaluation?**
   `[llength $ea] * [llength $eb] > $maxExactValues` (32), checked before
   any pairwise work runs -- unchanged mechanism, now serving more callers.
5. **How are dense results normalized?** `Normalize` (unchanged): a
   computed exact set exactly as large as its own interval span is
   dropped, keeping only the interval.
6. **How does shift transfer use the shift operand now?** `shift_right`
   computes `ShiftRightBound` from the shift amount's own `min`/`max` (or a
   full `CrossExact` cross product when both sides are tracked exact
   sets); `shift_left` symmetrically, bounded by `maxShiftLeftAmount`.
7. **Which signed cases get tight interval reasoning?** None new: negative
   shifted values (either shift direction) and negative-or-unproven shift
   amounts both fall back to the same conservative behavior that existed
   (or, for `shift_left`, would have existed) before this milestone.
8. **Which cases conservatively fall back?** Negative operands (either
   side, either shift direction); an unproven/possibly-negative shift
   amount for `shift_right`; a shift amount exceeding `maxShiftLeftAmount`
   or unbounded for `shift_left`; any exact-set cross product exceeding
   budget, for all four ops.
9. **Did singleton facts already feed constant folding?** No consumer of
   `hir::range` did this before this milestone (verified: no such
   mechanism exists in `hir/refine.tcl`/`native/lower.tcl` prior to this
   diff).
10. **If not, what generic bridge was added?** `native/lower.tcl`'s
    `PureBitwiseEligible`/`FoldPureBitwise` (§ 3): a lowering-time-only
    (not HIR-level) bridge, scoped to the three pure, total, allocation-free
    bitwise ops this milestone's real case needs.

## 12. Required raw-lowering questions

11. **Why were shifts excluded from raw lowering previously?** No proof
    machinery existed to establish the shift-amount validity, operand
    nonnegativity, or result-representability preconditions a safe raw
    shift needs; `RawEligibleCall` only recognized `+ - * < <= > >= ==`.
12. **What generic proof now makes a shift raw-eligible?**
    `RawEligibleShift` (§ 4.2): no guard needed on either operand, shifted
    value nonnegative and small, shift amount a single proven value below
    the host word width, result small.
13. **Does eligibility depend on a type name?** No -- verified by
    inspection (`RawEligibleShift`'s own body has no type-name literal)
    and by test (`tests/native-bitshift.test`'s synthetic cases use plain
    `fn f(x)`, no declared type at all).
14. **Does eligibility require an exact set, or can intervals suffice?**
    Intervals suffice for the shifted value (only `fitsSmall`+nonnegative
    is required, no exact set); the shift amount specifically needs a
    *single* proven value (an interval alone is not enough, by this
    milestone's own conservative choice, spec § 40).
15. **How is shift-count validity proven?** `0 <= k < rawShiftMax(64)`,
    checked directly from `hir::range::of`'s own proven bound for the
    shift-amount expression -- far inside `core/scalarbits.tcl`'s own much
    larger `MAX_SHIFT` (`1<<20`), so a raw-eligible shift is always also
    generically valid.
16. **How is raw result representability proven?** `hir::range::of` on the
    call expression itself (Phase A's own shift transfer already computed
    it) checked against `hir::range::fitsSmall`.
17. **How are BigInt cases preserved?** Any operand or result outside the
    small-Int range fails `fitsSmall` and `RawEligibleShift` returns 0;
    the ordinary `op ishr`/`ishl` (helper-backed, full BigInt semantics)
    is emitted unchanged.
18. **Are negative right shifts raw-optimized?** No.
19. **If not, why are they conservatively excluded?** Documented in § 4.5:
    a rigorous proof that raw `sshr` matches Botlish's own
    arbitrary-precision signed floor-shift semantics at the representation
    boundary was not attempted in this milestone; spec § 47's own
    "restrict to nonnegative" escape hatch is used explicitly.
20. **Did the implementation reuse existing unbox/raw/rebox
    infrastructure?** Yes, entirely: `RawOf`/`AssignRaw`/`TaggedOf`, the
    same functions `RIAdd`/`RISub`/`RIMul` already use; no second
    representation-transition scheme was added anywhere.

## 13. Required real-case questions

21. **What fact does `x` have inside `byte::nibble`?**
    `[0, 240] {0,16,32,...,240}` (unchanged by this milestone; established
    by the prior closed-call-parameter-facts work).
22. **What fact does `x & 15` have now?** `[0, 0] {0}` -- a genuine point.
23. **Is it folded to constant 0?** Yes, at lowering time
    (`FoldPureBitwise`'s singleton-result case); no `iand` instruction
    survives for this call.
24. **What fact does `x >> 4` have now?** `[0, 15]`.
25. **Does `0 | y` disappear generically?** Yes, via `FoldPureBitwise`'s
    zero-identity case; the `ior` call's own result register becomes `y`'s
    (the shift's) own register directly.
26. **What NIR remains for the successful body?** One `runbox`, one
    `rishr`, one `rbox`, `ret` -- plus harmless dead constant
    materializations from the three elided calls' own literal operands
    (§ 5.2).
27. **Does `rt_int_shr` remain on this path?** No -- confirmed both by NIR
    text (no `op ishr` for this call) and by the Cranelift IR/machine code
    (no `call` instruction in `byte::nibble`'s own compiled body at all).
28. **What actual machine shift instruction appears?** `sar rsi, 0x5` (one
    x86-64 arithmetic shift, Cranelift having fused the untag shift and
    the raw `>>4` shift into one instruction -- § 5.2).
29. **Are any runtime guards/checks left around that shift?** No.
30. **Why?** Every precondition (operand kind, operand/result
    representability, shift-count validity) was already statically proven
    by the time `NativeCall` decided to lower it raw; nothing remains to
    check at run time.

## 14. Required genericity questions

31. **Does any new logic mention Byte/Nibble/HighNibble names?** No --
    verified by direct inspection of every changed proc in `hir/range.tcl`
    and `native/lower.tcl`; the only files that ever mention those names
    (`core/scalarbits.tcl`, `lib/byte.bot`, their own tests) are unchanged
    by this diff.
32. **Would a future source-defined sparse integer domain gain the same
    optimization?** Yes: everything here consumes `hir::range` facts
    (interval/exact) that `TypeFact`/`ConstrainType` already seed from
    `core::type::integerFacts` -- a future `type HighNibble = Byte in
    {0,16,...,240}` declaration lowering into the same metadata would
    reach `BitOp`/`RawEligibleShift` identically, with zero change to
    either.
33. **Does an anonymous/test-local sparse exact set gain the same bitwise
    precision?** Yes -- demonstrated directly, with no HighNibble
    involvement at all, by `tests/hir-range-bitop.test`'s own generic AND/
    OR/XOR/shift examples (`{1,2,4,8}&{3}`, `{0,16}|{1,2}`, etc.).
34. **Does interval-only bounded input gain raw shift lowering?** Yes for
    the shifted value (only an interval fact is required there); the
    shift amount specifically still needs a proven single value (§ 12,
    question 14).
35. **Is any optimization dependent on the current Tcl source of type
    registration?** No -- confirmed by the same inspection as question 31;
    every mechanism here operates on `Range` facts, never on
    `core::type::register`'s own Tcl-side bookkeeping.

## 15. Required remaining-cost questions

36. **After this milestone, what prevents `byte::nibble(byte::high_nibble(b))`
    from becoming one logical right shift end to end?** Two real,
    separate function-call boundaries (each with its own tagged-ABI
    prologue/epilogue and, for `byte::nibble`, one tag-transition pair);
    no interprocedural expression simplification exists to look through a
    call and continue folding across it.
37. **Are the remaining costs predominantly function calls?** Yes (§ 10).
38. **Are any tagged/raw transitions still unnecessarily repeated?** No
    (§ 10) -- exactly one unbox/rebox pair, required once by the ABI,
    inside `byte::nibble` itself; none inside `byte::high_nibble` (its
    own AND never leaves the tagged representation).
39. **Is a tiny closed leaf-inliner now clearly justified by
    measured/generated evidence?** Yes, narrowly (§ 10).
40. **Recommend or reject it based on evidence; do not implement it.**
    Recommended (not implemented) -- § 10's own reasoning.

## 16. Required scope questions

41. **Was function inlining added?** No.
42. **Was any Byte/Nibble-specific peephole added?** No.
43. **Was known-bits analysis added?** No.
44. **Were type declarations moved into `.bot`?** No.
45. **Were parameter annotations added?** No.
46. **Was ASCII added?** No.
47. **Was `is_unreserved` changed?** No.
48. **Was `join` added?** No.
49. **Was `Bytes` added?** No.
50. **Was checked-constructor native support added?** No.

## 17. Stop condition, met

Inside `byte::nibble`'s real closed instance: `x: [0,240] {0,16,...,240}`;
`x & 15: [0,0] {0}`; `x >> 4: [0,15]`; the successful computation lowers to
`shift_right(x,4)` equivalent (the `iand`/`ior`/outer `iand` all elided at
lowering time, generically); native representation is raw-safe; machine
lowering is one fused `sar` with no `rt_int_shr` call anywhere on this
path. No inlining of `byte::nibble` into its caller was added.

Per § 10/§ 39-40: the evidence now points at function-call/ABI-boundary
overhead, on two now-minimal, single-block, effectively call-free leaves,
as the dominant remaining abstraction cost -- a narrowly-scoped
exact-leaf-inlining milestone is a reasonable next step, recommended here,
not attempted.
