# Tiny exact-leaf inlining

This milestone continues directly from `BOUNDED-BIT-SHIFT-LOWERING.md`,
which closed the scalar-lowering gap inside `byte::nibble` itself (its own
body now lowers to one fused `sar` and a retag, no helper call, no
branch) and explicitly recommended this as its own next step (`§ 10`,
`§ 39-40`): the dominant remaining abstraction cost in the real
`web::high_nibble` chain was, by that point, no longer arithmetic at all,
but the function-call boundary itself --

```
call byte::high_nibble(b)
call byte::nibble(...)
```

-- two real `call` instructions plus, inside `byte::nibble`, one tag-
transition pair a caller already holding a raw value for its argument could
not avoid either way, purely because the function boundary demands a
tagged ABI value in and out.

This milestone adds the smallest inliner that removes that boundary for
exactly the cases that need it, without becoming a general inliner.

## Outcome

The real acceptance case holds exactly as specified: `web.bot`'s local
`high_nibble` wrapper (nested inside `uri_escape_text`) now contains
**zero** `call`/`callenv` instructions to either `byte::high_nibble` or
`byte::nibble` -- their own mask/shift/retag operations run directly inside
`high_nibble`'s own compiled body, with the same value, the same runtime
guard where one was already needed, and no runtime helper call
(`rt_int_shr` or otherwise) anywhere on this path. The source functions
(`lib/byte.bot`, `lib/web.bot`) are byte-for-byte unchanged: this is a
compiler-only optimization, driven entirely by generic structural/effect
facts, with no code anywhere that mentions `Byte`, `Nibble`, `HighNibble`,
`byte::`, or `web::`.

## 1. Files changed

- `native/lower.tcl` -- the whole feature: a new "Tiny exact-leaf inlining"
  section (`LeafInlineEligible`/`LeafInlineEligibleUncached`/
  `LeafBlockLooksSmall`/`LeafExprStructural`/`LeafBodyEligible`/
  `LeafExprEligible`/`LeafShiftSafe`/`InlineLeafCall`), a new dispatch
  inside `Call`'s existing ordinary block-call path (right where it would
  otherwise emit `call`/`callenv`), five new module-level variables
  (`tinyLeafInlineOpt`, `leafEligible`, `leafInlineMaxOps`,
  `leafInlineSafeOps`), and the new `-tiny-leaf-inline-opt` option threaded
  through `program` the same way every other `-*-opt` flag already is.
- `tests/native-tiny-leaf-inline.test` (new, 30 tests): the real acceptance
  case (NIR/value/assembly-adjacent evidence), a generic non-byte leaf,
  every mandated eligible/ineligible shape, argument-evaluation semantics
  (evaluated once, order preserved, unused-still-evaluated, errors
  preserved), the size budget at and beyond its threshold, multi-call-site
  behavior and determinism, dynamic-call non-inlining alongside the same
  callee's own direct call site still inlining, and a GC-stress smoke case.
- This report.

No change to `lib/byte.bot`, `lib/web.bot`, `core/scalarbits.tcl`,
`hir/range.tcl`, `hir/specialize.tcl`, `hir/aot.tcl`, or any Rust source
(`native/src/**`): the mechanism reuses every one of those unmodified.

## 2. Architecture: where the inliner lives, and why

### 2.1 The two candidate layers, evaluated

**A. HIR-level exact-leaf substitution.** Rewrite the caller's HIR: replace
the `call` node with the callee's own body expressions, spliced into the
caller's own scope, with fresh binding/scope/expr IDs remapped so nothing
collides, and a new local `bind` per parameter holding the (once-evaluated)
argument. This is the layer a "compilers usually inline in the middle end"
intuition reaches for. It would need: (a) an ID-remapping scheme (this
program's HIR allocates every ID once, globally, so cross-instance
collision is not actually a risk here -- see § 5.1 below -- but a
substitution *within a single instance's own view*, which is what an HIR
rewrite would be, still has to build a fresh sub-scope, threading
`hir::hygiene`'s own binding-identity discipline correctly); (b) a new
scope/binding-count bookkeeping path parallel to `hir::resolve`/
`hir::hygiene`; (c) re-running `hir::types::infer` and `hir::range::analyze`
over the rewritten region (or very carefully partial-updating them), since
both key facts by ExprId and the rewritten call site now has entirely new
descendant ExprIds; (d) doing all of this *before* `hir::specialize`, which
means it would have to work generically over every possible instance a
callee could ever have, not just the one instance a given call site
actually resolved to.

**B. Native/NIR lowering-time exact-leaf expansion.** Never touch HIR.
Decide, at the point `native/lower.tcl`'s `Call` would otherwise emit
`call`/`callenv` for an exact instance, whether that instance is a tiny
leaf; if so, lower its own body directly into the caller's NIR function
being built, reusing the caller's own already-computed argument registers
as the callee's parameter bindings.

### 2.2 Precedent already in this file

`native/lower.tcl` already does layer B, twice, for two different narrower
purposes: **`TraversalAccess`** (the "String traversal" section) and
**`InlineRegionConsumerCall`**/`EmitRegionConsumerBody` (the "String
regions" section). Both recognize a call whose callee's own shape a prior
whole-program HIR analysis (`hir::traversal.tcl`, `hir::stringregion.tcl`)
already proved eligible, and lower that callee's body **directly in the
caller's own function**, never emitting a `call`/`callenv` for that site,
with the callee's own canonical function still emitted unconditionally for
every other caller. This milestone's `InlineLeafCall` is architecturally
the same move, generalized from "a specific String-region/traversal shape"
to "a small, straight-line, effect-safe body" -- reusing the identical
discipline (a lowering-time-only decision, HIR untouched, the callee's own
canonical function preserved by ordinary reachability).

### 2.3 Why B, not A, for this milestone

Per this milestone's own instruction ("the first implementation should use
the smallest layer that ... does not require a general CFG inliner ..."):
layer B needs no new ID-remapping scheme, no new fact re-analysis, and no
new scope-construction machinery, because of one property specific to this
codebase's HIR (spec's own § 22 asks this be demonstrated, not assumed --
see § 5.1): **binding IDs, scope IDs and expr IDs are allocated once,
monotonically, over the whole program** (`hir/hir.tcl`'s own header:
`NewId` takes one counter per ID kind, keyed on the *program's* HIR dict,
not per-function). A callee's own parameter `BindingId` can therefore never
collide with anything already live in the caller's own NIR function state,
with no remapping step needed at all -- see § 5.2. Layer B also needs no
new fact machinery: `hir::range::analyze`'s existing interprocedural
fixpoint (`CLOSED-CALL-PARAMETER-FACTS.md`) already computed facts for
*every used instance*, callees included, before lowering ever starts, so a
callee's own body facts are already sitting there to be read, by instance
id, with zero incremental recomputation. Layer A would have had to
re-derive or carefully patch both of these from scratch. Layer B is simply
smaller, for this specific codebase, not merely by convention.

### 2.4 Was any existing internal-variant machinery reused? (spec § 21)

Investigated and **not reused directly**, deliberately: `hir::blockescape`'s
"capture-explicit internal variant" machinery exists to convert a captured
closure into an ordinary function taking its captures as extra trailing
parameters -- solving a completely different problem (de-closure
conversion) that this milestone's own eligibility rule (captures = 0,
required) never needs to invoke at all. `hir::stringregion`'s
`InlineRegionConsumerCall`/`EmitRegionConsumerBody` *is* architecturally
the right precedent (§ 2.2 above), but its own `EmitRegionConsumerBody` is
a small bespoke recursive lowering function handling exactly three HIR node
kinds (`ref`, `if`, `call`) special-purposed for one designated
region-consuming parameter -- it does not (and, for its own purpose,
should not) go through the *general* `Sequence`/`Expr`/`Bind`/`NativeCall`
machinery. This milestone's own `InlineLeafCall` intentionally does the
opposite: it re-enters the *general*, ordinary per-expression lowering
(`Sequence`/`Expr`/`Bind`/`NativeCall`, the exact same procs an ordinary
function body already goes through), because a tiny leaf's body can contain
anything `LeafInlineEligible` allows (`bind` locals, any of the safe native
ops), not one fixed three-shape grammar -- reusing the *general* lowering
machinery, rather than a purpose-built narrow walker, is what lets
`RawEligibleCall`/`RawEligibleShift`/`PureBitwiseEligible` and everything
else `NativeCall` already does keep working, unmodified, on an inlined
body's own operations (§ 8 below).

## 3. Eligibility class

A callee instance is a tiny exact leaf (`LeafInlineEligible`) iff **all**
of the following, purely structural/effect-based, with no callee name
anywhere in the logic:

1. **Exact target.** The call already resolved (`hir::specialize`, via the
   caller's own `fn targets`) to one specific instance -- never a dynamic/
   open call (`callvalue`).
2. **Environment-free.** The callee's own block is in `ENVLESS`
   (`hir::aot`'s own whole-program fact: zero captures, needs no closure
   value at all).
3. **Straight-line body.** Every expression reachable in the body is
   `const`, `ref`, `bind`, or a `call` -- never `if`, `loop`, `break`,
   `continue`, `return`, `ok`, `error`, or a nested `block`. Since `block`
   is the only HIR shape that could introduce recursion or capture an
   environment, and it is categorically excluded, this alone also makes
   the body trivially nonrecursive (and not mutually recursive) and
   closure-free -- no separate recursion check exists or is needed.
4. **Native-only calls.** Every `call`'s target is a `native`, never
   another `block` -- the second half of ruling out any internal function
   call (and therefore recursion) entirely.
5. **Safe op family.** Every such native call resolves (`NativeCallOp`,
   the same dispatch `RawEligibleCall`/`PureBitwiseEligible` already use)
   to one of `iadd isub imul ilt ile igt ige ieq iand ior ixor ishr ishl`
   -- the pure, total, allocation-free scalar-Int arithmetic/comparison/
   bitwise/shift family already in `native::lower::natives`'s own op
   table. Deliberately excluded: `imod` (can raise on a zero divisor, no
   existing error-safety proof for it), `veq`/`streq` (equality across
   non-proven-Int operands; not proven allocation-free), and every
   string/list/hash/mutable-array op (`strcat`, `listnew`, `mutarrayset`,
   `hash`, ...).
6. **No proven-always-failing call.** None of the body's own calls is
   `hir::aot`'s own `knownErrors` fact (an operation *proven* to always
   raise). An ordinary, merely *unproven* runtime kind guard (`guards`) is
   **not** a reason to decline -- see § 4 below; this is the one place
   this milestone's own reading of "may_error = false" is narrower than a
   literal "zero possible runtime check", and is explained there.
7. **Shift error-safety.** A shift call (`ishr`/`ishl`) additionally
   proves its own shift amount a single already-known value strictly
   within `rawShiftMax` (the same bound `RawEligibleShift` already uses --
   `LeafShiftSafe`): the only op in the safe family whose generic runtime
   helper can otherwise raise `{CORE SEMANTIC RANGE}`, so this is the one
   place eligibility positively proves an otherwise-possible error path
   statically excluded, rather than merely reading an existing blocker.
8. **Size budget.** The body's own total native-call count does not exceed
   `leafInlineMaxOps = 8` (below).

Nothing here inspects a callee's name, module, or declared result type.

### 3.1 The budget: why 8

`byte::high_nibble`'s own body has 1 native call (`bit_and`);
`byte::nibble`'s has 4 (`bit_and`, `shift_right`, `bit_or`, `bit_and`
again -- `bit_and(bit_or(bit_and(x,15), shift_right(x,4)), 15)`). 8 is
comfortably above both real target bodies, with headroom for a small
synthetic multi-op test (§ 7 below pins the exact boundary at 8/9), and is
not guessed large: no cost model beyond a flat call count exists anywhere
in this milestone (spec's own "do not create a complex cost model").

### 3.2 Was "single caller" used as an eligibility criterion? (spec § 39)

No. Eligibility never inspects a callee's caller count at all (§ 3.4 shows
`csv_records`/`hashtable` each inlining 4 *distinct* eligible instances,
several with more than one call site -- § 6 below). Stated per spec's own
§ 41 instruction: **no callee-size x call-site-count global budget exists
in this milestone** -- `leafInlineMaxOps` bounds a callee's own body size
only, so a tiny leaf called from many sites inlines at every one of them
(§ 9's `tiny-leaf-multi-call-site-all-inline` test; § 6's corpus table
shows this never grew whole-program code size in the actual corpus this
milestone measured). This is a deliberate, documented scope decision, not
an oversight: adding a call-site-count-aware budget is the natural next
refinement if a much-more-called leaf is ever found to matter, but nothing
in this milestone's own real or synthetic corpus needed it.

## 4. Why a needed runtime kind guard does not disqualify eligibility

`byte::high_nibble`'s own body, `bit_and(b, 240)`, needs a guard at its own
call site: its parameter `b`, called from `web.bot`'s wrapper, is not
statically proven `int` there (the chain runs through `list_get`/
`encode_utf8`, whose own static types are broader than `int`), so
`EmitArgGuards` emits `guard int %0 "bit_and"` regardless of whether the
call is inlined. This was the one restriction that, if kept as strict as
`RawEligibleCall`'s/`PureBitwiseEligible`'s own "no guard needed"
precondition (which those procs need for an unrelated reason -- deciding
whether to *skip* an operation's own instruction entirely, which is only
sound when nothing could still need checking), would have made
`byte::high_nibble` itself ineligible and defeated this milestone's own
mandatory acceptance target. Relaxed here: `LeafExprEligible` only declines
on a *`knownErrors`* entry (proven-always-fails); an ordinary `guards`
entry is left to `EmitArgGuards`, which emits the identical check wherever
`NativeCall` runs -- inlined or not. This is sound, not a loophole: the
check is not duplicated, skipped, or reordered relative to its own operand;
it simply now runs in the caller's own function instead of the callee's,
checking the same value, in the same position, raising the same error on
the same invalid input either way (§ 8's differential evidence confirms
this: value and error parity hold identically with the flag on and off).

## 5. Argument evaluation, binding, and provenance

### 5.1 No ID collision, by construction

`hir/hir.tcl`'s own header: every `ExprId`/`BindingId`/`ScopeId` is
allocated once, monotonically, over the *whole program's* HIR (`NewId`
takes one counter per program, not per function). A callee's own parameter
`BindingId` is therefore, by construction, disjoint from every binding
already live in the caller's own `fn locals` -- confirmed directly rather
than assumed: `native::lower::InlineLeafCall` needed no remapping table of
any kind, and none was written.

### 5.2 Substitution is `fn locals`, not a bespoke environment

`native::lower::Access` (the function every `ref` lowering already goes
through) looks up a binding's storage in `fn locals` **first**, before
falling back to capture/closure lookup. `InlineLeafCall` exploits this
directly: it evaluates the caller's own argument expressions exactly once
each (reusing `Call`'s own already-computed `argRegs`, from the ordinary
`CallArgs` path every other call site already uses -- § 5.3), then simply
sets `dict set fn locals $calleeParamBindingId [list reg $argReg]` for each
parameter before lowering the callee's own body statements
(`Sequence fn $body`) and restores whatever was there before (nothing, for
every real case) afterward. Every `ref` to that parameter anywhere in the
callee's body resolves through the **ordinary**, completely unmodified
`Ref`/`Access` machinery, identically to any other already-bound local --
no new code path exists in either proc, and none needed to be added.

### 5.3 Evaluation order, once-only, unused arguments, errors

`Call`'s own ordinary block-call dispatch already computes `argRegs` via
`CallArgs` (`foreach arg $argExprs { ... Expr fn $arg ... }`, strictly in
source left-to-right order) **before** deciding whether the target is a
self-tail call, a virtualized/region call, or (this milestone's own new
case) an inlineable leaf -- `InlineLeafCall` is hit only *after* that
evaluation already happened, unconditionally, exactly once per argument,
regardless of how many times (zero or many) the callee's own body
references the corresponding parameter. This is not new plumbing this
milestone added: it is the existing call-argument-evaluation path, simply
reused instead of bypassed. Verified directly (§ 9,
`tiny-leaf-argument-evaluated-once`/`tiny-leaf-unused-argument-still-
evaluated`/`tiny-leaf-argument-order-preserved`/`tiny-leaf-argument-error-
preserved`, all differential on/off): a parameter referenced twice still
has its own argument evaluated once; an argument whose parameter the body
never references is still evaluated; two argument expressions with
observable effects still evaluate left to right; an argument that raises
still raises the same error (`{CORE SEMANTIC ARITHMETIC}` for `mod(5,0)`),
before the (now-absent) callee frame would ever have been entered, in
both configurations.

### 5.4 Facts, representation, and the ABI boundary

`HIR`, `CURRENTINSTANCE`, `GUARDS`, and `KNOWNERRORS` (four
`native::lower` module variables) are switched to the callee's own
specialized view and instance id for exactly the duration of lowering its
body (saved and restored around it -- the same save/restore discipline
`If`/`Loop` already use for `fn rawCache`). Because `hir::range::analyze`
already computed facts for *every used instance* in one whole-program
fixpoint before lowering starts (`CLOSED-CALL-PARAMETER-FACTS.md`), a
callee's own body facts are read from the *same*, already-complete
`ranges` structure, by instance id -- nothing is recomputed, and nothing
new was added to `hir/range.tcl`. `RawEligibleCall`/`RawEligibleShift`/
`PureBitwiseEligible`/`NativeCall`'s ordinary raw-vs-tagged decision runs
**unmodified** on the inlined body's own operations, using the callee's
own facts, exactly as it would if that body were still a separate
function: this is what lets `byte::nibble`'s own `x >> 4` stay a raw
`sshr`, fused by Cranelift's own instruction selector with the untag shift
right where it used to be (§ 6.4) -- with **zero inlining-specific
representation rule** anywhere in this diff (spec's own "do not force
rawness"). Provenance: every instruction `InlineLeafCall`'s reused lowering
procs emit still carries its own originating HIR expression id (`Emit`'s
existing `@E` suffix, completely unchanged) -- `byte::nibble`'s own
`x & 15` stays traceable to `byte::nibble`'s own expression in NIR/CLIF
text, not to a synthetic node, even though it now runs inside
`web.bot`'s own compiled `high_nibble` function.

## 6. The real acceptance case: before and after

Captured fresh this session (`bench/refined-checks.ir`, native `cranelift`
backend, both configurations of `-tiny-leaf-inline-opt`).

### 6.1 NIR

Before (`-tiny-leaf-inline-opt 0`):

```
"high_nibble" params=1 env=0 regs=3 pnames="b" captures=0 instance="generic" @e74
    %1 = call 1 %0 @e77
    %2 = call 2 %1 @e75
    ret %2
```

After (`-tiny-leaf-inline-opt 1`, default off -- see § 11):

```
"high_nibble" params=1 env=0 regs=15 pnames="b" captures=0 instance="generic" rawregs="2 5 7 8 10 11 14" @e74
    %1 = int 240 @e6
    %2 = rawint 240
    guard int %0 "bit_and" @e3
    %3 = op iand %0 %1 @e3
    %4 = int 15 @e22
    %5 = rawint 15
    %6 = int 0 @e19
    %7 = rawint 0
    %8 = op runbox %3
    %9 = int 4 @e26
    %10 = rawint 4
    %11 = op rishr %8 %10 @e23
    %12 = op rbox %11
    %13 = int 15 @e27
    %14 = rawint 15
    ret %12
```

Zero `call`/`callenv` instructions. `guard int %0` is the one preserved
runtime check (§ 4); every operation after it (`iand`, `runbox`, `rishr`,
`rbox`) is `byte::high_nibble`'s and `byte::nibble`'s own arithmetic,
running directly here, with their own expression ids (`@e3`, `@e23`, ...)
still attached. `%1/%4/%6/%9/%13` are dead leftover constant
materializations from the elided calls' own literal operands (`Call`
evaluates every argument before a containing call decides whether to keep
it -- pre-existing behavior, unrelated to this milestone: the prior
`BOUNDED-BIT-SHIFT-LOWERING.md` report's own § 5.2 documents the identical
pattern inside `byte::nibble` itself).

### 6.2 True Cranelift IR (not just NIR text)

After, `high_nibble`'s own compiled body (`native::clif`): a branchy kind
guard (`brif`, with its own internal fallback calls to `rt_type_error` and,
on `bit_and`'s own pre-existing tagged-word fast path's own miss branch,
`rt_int_and` -- both are the guard/AND op's own generic implementation
detail, unrelated to `byte::high_nibble`/`byte::nibble`), then

```
v40 = sshr v32, v39   ; v39 = 1 (RUnbox: untag)
v43 = sshr v40, v42   ; v42 = 4 (the raw shift itself)
v45 = ishl v43, v44   ; v44 = 1 (RBox, part 1: retag)
v47 = bor v45, v46    ; v46 = 1 (RBox, part 2: retag)
return v47
```

Before, the whole body is two `call fn0(...)`/`call fn1(...)` plus a
`brif` on the first call's own result.

### 6.3 True machine code (objdump, unlinked object, AOT smoke build)

Before (`botlish_fn_4`, 0x4e bytes):

```
call   botlish_fn_1      ; byte::high_nibble
test/jne                 ; (open-coded result check)
call   botlish_fn_2      ; byte::nibble
ret
```

After (`botlish_fn_2`, 0xb6 bytes -- larger in isolation, § 7 explains why
the *whole-program* total still shrinks):

```
; guard int %0 (branchy kind check; only its own failure path calls
; rt_type_error -- never reached for this call chain's own real inputs)
and    rsi, 0x1e1        ; byte::high_nibble's own bit_and(b, 240)
sar    rax, 0x5          ; byte::nibble's own untag(1) + shift(4), fused
shl    rax, 1
or     rax, 0x1
ret
```

**Zero calls to `byte::high_nibble`, zero calls to `byte::nibble`**, in
either the true Cranelift IR or the true machine code, on this call site --
not merely absent from NIR text. Cranelift's own instruction selector fused
the untag-by-1 and the logical shift-by-4 into the single `sar rsi, 0x5`
seen above, exactly mirroring `BOUNDED-BIT-SHIFT-LOWERING.md`'s own
`byte::nibble` finding (§ 5.2 there), now happening one level up, inside
`high_nibble`'s own function, with no ABI boundary left between the two
former callees' own operations at all.

### 6.4 Value and code-size evidence

| | before (`-tiny-leaf-inline-opt 0`) | after (`1`) |
|---|---:|---:|
| `cranelift` value | `[400, 0]` | `[400, 0]` (unchanged) |
| Whole-program machine code | 16411 bytes | **16284 bytes** (-127, -0.77%) |
| Function count | 27 | **25** |
| `call`/`callenv` instructions, whole program | 28 | **26** |
| `byte::high_nibble` own machine code | 203 bytes (separately emitted) | not separately emitted (§ 7) |
| `byte::nibble` own machine code | 40 bytes (separately emitted) | not separately emitted (§ 7) |
| `high_nibble` (wrapper) own machine code | 78 bytes (2 calls) | 182 bytes (0 calls, own arithmetic + guard) |

## 7. Preserving the canonical helper functions (spec § 9, § 36-37, § 104)

`byte::high_nibble`/`byte::nibble` each have **exactly one caller** in this
real corpus program (`CLOSED-CALL-PARAMETER-FACTS.md`'s own prior finding,
reconfirmed here). Once that one call site inlines, `native::lower::
program`'s own **unchanged** reachability worklist (the `pending` list
`Function`/`FunctionRef` already drove before this milestone) simply never
schedules either function for separate emission -- nothing new was built to
cause this; it is the same mechanism that already decided, before this
milestone, which instances get compiled at all. This is exactly the
"unless existing DCE independently proves it unused" exception this
milestone's own spec states for § 9: the canonical function is not
*removed*, it was never *unconditionally re-materialized* in the first
place -- ordinary reachability, not a new pass, decides it (spec § 37:
"do not build a new DCE pass merely to make the object smaller" -- none
was).

**The source functions themselves remain ordinary, valid, ordinarily
callable Botlish** (spec § 104): `lib/byte.bot` is byte-for-byte
unchanged, and the synthetic `tiny-leaf-canonical-still-callable-value`/
`tiny-leaf-dynamic-call-top-level-site-still-inlines` tests demonstrate the
general property directly -- a leaf with a second, *dynamic* caller (a
call through a first-class function value, which never inlines: § 3 rule
1) keeps its own canonical function separately compiled and callable, at
the *same time* its own unrelated direct call site inlines away, in the
*same* program:

```
fn inc(x):
    x + 1

fn apply(g, y):
    g(y)

fn caller():
    inc(5)

[caller(), apply(inc, 5)]
```

`caller`'s own body has zero calls (fully inlined); `apply`'s own body
still calls through `callvalue` (never inlined -- dynamic target); `inc`'s
own canonical function is still separately emitted (needed for `apply`'s
dynamic dispatch); both results are `6`.

## 8. Semantics: differential testing, on vs off

Every argument-evaluation-sensitive synthetic test (§ 5.3) compares
`-tiny-leaf-inline-opt 1` against `0` directly, on the *same* HIR, on
`cranelift`: multi-reference-argument evaluation count, unused-argument
evaluation, two-argument left-to-right order, and argument-error identity
(same `-errorcode`) all agree exactly. The real acceptance case's own value
(`[400, 0]`) is identical in both configurations. No cross-backend
(`interp`/`compile`) semantic difference exists or is possible: this
feature lives entirely inside `native/lower.tcl`, reached only through
`native::lower::program`/the Cranelift backend -- `interp` and `compile`
never execute any code this milestone added (spec's own § 87-88 "no source
semantic changes... native/compiler optimization only" is met by
construction, not merely by testing).

## 9. Corpus audit (spec § 71, § 89)

The 13-program corpus (`bench/*.ir` + `examples/stdlib/*.bot`, each program
compiled with its own trailing sample driver, `-tiny-leaf-inline-opt 1` vs
`0`):

| program | calls (on) | calls (off) | fns (on) | fns (off) | bytes (on) | bytes (off) | eligible instances |
|---|---:|---:|---:|---:|---:|---:|---:|
| fib | 3 | 3 | 2 | 2 | 394 | 394 | 0 |
| loop-count | 2 | 2 | 3 | 3 | 418 | 418 | 0 |
| refined-checks | 26 | 28 | 25 | 27 | 16284 | 16411 | 2 |
| sum-refined | 2 | 2 | 3 | 3 | 292 | 292 | 0 |
| ai_text_clean | 9 | 9 | 5 | 5 | 3003 | 3003 | 0 |
| csv | 4 | 4 | 11 | 11 | 4731 | 4731 | 0 |
| csv_chunked | 12 | 27 | 20 | 21 | 10103 | 10347 | 1 |
| csv_geometric | 9 | 9 | 15 | 15 | 5333 | 5333 | 0 |
| csv_records | 84 | 98 | 55 | 59 | 21624 | 21919 | 4 |
| hashtable | 68 | 82 | 26 | 30 | 12868 | 13166 | 4 |
| matmul | 8 | 8 | 7 | 7 | 4160 | 4160 | 0 |
| string_replace | 7 | 7 | 4 | 4 | 2322 | 2322 | 0 |
| string_reverse | 6 | 6 | 3 | 3 | 798 | 798 | 0 |

`eligible instances` is `LeafInlineEligible` returning true, counted once
per distinct materialized instance in `hir::specialize::analyze`'s own
`used` set (`native::lower::LeafInlineEligible`, invoked directly against
each program's own analysis). Four of the thirteen corpus programs reach a
tiny leaf at all; where they do (`refined-checks`, `csv_chunked`,
`csv_records`, `hashtable`), whole-program machine code **shrinks**, never
grows, and function count drops by exactly the number of instances that
lost their own last caller. `csv_chunked`/`csv_records`/`hashtable` were
not specifically written for this milestone: they are the *pre-existing*
corpus, and their own small helper functions (arithmetic/hash/index-style
leaves) happened to also qualify -- direct evidence the mechanism is not
narrowly tuned to `byte::nibble`'s own shape (spec's own § 26, § 93). A
finer per-decline-reason breakdown (spec § 71's "declined by size / by
effects / by control flow / by openness") was not separately instrumented
beyond `LeafInlineEligible`'s own pass/fail per instance -- the aggregate
call/function/byte counts above and the exhaustive synthetic
eligible/ineligible test matrix (§ 10) are this milestone's own evidence
for that question instead.

## 10. Tests

`tests/native-tiny-leaf-inline.test`, 30 tests, all passing:

| Test | What it pins |
|---|---|
| `tiny-leaf-real-high-nibble-no-calls` | real acceptance case: zero calls |
| `tiny-leaf-real-high-nibble-no-calls-off` | flag off: the pre-existing two calls, unchanged |
| `tiny-leaf-real-high-nibble-has-mask-and-shift` | the mask/shift survive as direct ops, not just "no call" |
| `tiny-leaf-real-value-unchanged` | `[400,0]` both configurations |
| `tiny-leaf-real-helpers-not-separately-emitted` | § 7's reachability finding |
| `tiny-leaf-generic-add-one-inlines`/`-value`/`-off` | genericity: a plain non-byte leaf |
| `tiny-leaf-eligible-multi-op-budget` | exactly 8 ops still inlines |
| `tiny-leaf-ineligible-over-budget` | exactly 9 ops declines |
| `tiny-leaf-ineligible-branch` | `if` in body declines |
| `tiny-leaf-ineligible-loop` | `loop`/`break` in body declines |
| `tiny-leaf-ineligible-self-recursive` | self-recursion declines |
| `tiny-leaf-ineligible-mutually-recursive` | mutual recursion declines |
| `tiny-leaf-ineligible-captures` | a closure over an enclosing local declines |
| `tiny-leaf-ineligible-allocating` | List construction declines |
| `tiny-leaf-ineligible-mutating` | MutableArray mutation declines |
| `tiny-leaf-ineligible-erroring-mod` | `mod` (no error-safety proof) declines |
| `tiny-leaf-ineligible-shift-unproven-count` | two callers, two different shift counts: declines |
| `tiny-leaf-eligible-shift-proven-count` | one proven-safe constant shift count: inlines |
| `tiny-leaf-dynamic-call-not-inlined` | a `callvalue` call never inlines |
| `tiny-leaf-dynamic-call-top-level-site-still-inlines` | ...while the same leaf's own direct call site does |
| `tiny-leaf-argument-evaluated-once` | multi-reference parameter: argument evaluated once |
| `tiny-leaf-unused-argument-still-evaluated` | unused parameter: argument still evaluated |
| `tiny-leaf-argument-order-preserved` | two-argument left-to-right order preserved |
| `tiny-leaf-argument-error-preserved` | an erroring argument still raises, same error code |
| `tiny-leaf-multi-call-site-all-inline` | 5 call sites to one leaf: all inline |
| `tiny-leaf-multi-call-site-deterministic` | byte-identical NIR across repeated lowering |
| `tiny-leaf-canonical-still-callable-value` | value parity with a live dynamic caller |
| `tiny-leaf-gc-stress-smoke` | an inlined call inside an allocating caller |

Every eligible/ineligible synthetic test uses plain `fn`/arithmetic/
control-flow fixtures with no reference to `Byte`/`Nibble`/`HighNibble`/
`byte::`/`web::` anywhere (grepped directly to confirm).

## 11. Feature flag and default

`-tiny-leaf-inline-opt 1|0` (also `BOTLISH_NATIVE_TINY_LEAF_INLINE_OPT=1`
to turn on; unset or `0` stays off), threaded through
`native::lower::program` exactly like every other `-*-opt` flag.

**Default: off** -- the one flag in this file that inverts the convention
every other optimization here uses (all of `-repr-opt`/`-escape-opt`/
`-block-escape-opt`/`-string-region-opt`/`-string-traversal-opt`/
`-param-aggregate-opt` default *on*). This is evidence-based, not
precautionary boilerplate: turning tiny-leaf inlining on by default, while
developing this milestone, broke a substantial number of **pre-existing**
tests across `tests/native-bitshift.test` and other files, whose own
methodology looks up a named function's compiled body by its quoted name
(`FunctionBody`-style helpers, used pervasively across `tests/native-*
.test`) -- a plain top-level `fn f(x): shift_right(x, 4)` with one caller,
exactly the shape several pre-existing synthetic fixtures use, is now a
tiny eligible leaf, and its own canonical function legitimately, correctly
stops being separately emitted (§ 7) the moment its one caller inlines,
which those tests never anticipated. This is precisely the milestone's own
named condition for defaulting off (spec § 59: "if debugger/provenance
uncertainty remains, default-off may be more appropriate") -- here,
"provenance" specifically means *external tooling's* assumption that every
named function stays separately addressable, not this milestone's own
internal provenance (§ 5.4, which is unaffected either way). Rather than
touch a wide, unrelated swath of pre-existing test files to accommodate a
new optimization (out of this milestone's own "smallest capability"
scope), the flag defaults off; every test this milestone added exercises
it explicitly (`1` or `0`), and the real acceptance case is demonstrated
with it explicitly turned on (§ 6). Turning it on globally remains a
one-flag, fully reversible follow-up once (if ever) the wider suite's own
function-lookup idiom is made robust to it -- not attempted here, since
that is a change to many unrelated test files' own methodology, not to
this optimization itself.

Compile-time cost (spec § 90): `native::lower::program` on
`bench/refined-checks.ir`, averaged over 20 runs -- 220.9ms with the flag
off, 221.0ms with it on (~0.1ms difference, noise-level). `LeafInlineEligible`
is a two-phase, memoized-per-instance check: a cheap structure-only walk
(`LeafBlockLooksSmall`/`LeafExprStructural`, no `hir::aot::analyzeRegion`
call at all) runs first and rejects every branchy/loopy/large/internal-
calling instance immediately; only a structurally-plausible small body
ever pays for the full `hir::aot::analyzeRegion` + `CollectChecks` guard/
known-error analysis. No whole-program clone or re-analysis architecture
exists anywhere in this diff (spec's own § 90 "avoid a repeated whole-
program clone").

## 12. Determinism

`LeafInlineEligible` is a pure function of an instance id and the
(fixed, whole-program) `spec`/`context` state, memoized in `leafEligible`
(reset once per `native::lower::program` call); `InlineLeafCall`'s own
lowering walks the callee's body statements in their fixed, HIR-given
list order, using the same `Sequence`/`Expr` procs every ordinary function
body lowering already uses, with no dict-iteration-order dependence
anywhere in the decision path. Verified directly
(`tiny-leaf-multi-call-site-deterministic`): the same program lowered
twice produces byte-identical NIR text.

## 13. GC/rooting/frame implications

Eligible leaves are, by construction (§ 3, rules 3-6), non-allocating and
call only pure scalar-Int ops: inlining one adds ordinary ALU/guard
instructions to the caller's own already-existing function, never a new
kind of value, root, or safepoint. `native/src/runtime/framemap.rs`'s own
`FunctionMap`/`ProgramMap` (the only "frame walking" this backend has) is
indexed by program counter, per *compiled function*, and built from
whatever stack maps that function's own Cranelift lowering already emits
at its own safepoints -- entirely agnostic to whether a given instruction
sequence originated from source written directly in that function or was
spliced in by `InlineLeafCall`; no change was needed or made to
`native/src/**` for this milestone (§ 1). Confirmed empirically, not just
by architectural argument: `tests/all.tcl` under
`BOTLISH_NATIVE_GC_STRESS=1` passes at the same total as the ordinary run
(§ 14) with the flag exercised through the new test file's own
`tiny-leaf-gc-stress-smoke` case and the corpus's own four real inlining
sites (§ 9).

**Debugger implications (spec § 20, § 83-86, § 108 Q26-28):** this
codebase has no interactive step-debugger for native code (searched
directly: no breakpoint/stepping/backtrace-symbol infrastructure exists
anywhere in `native/src/**` or `hir/**`; the only "frame" concept native
code has is the GC's own PC-indexed root map above, which carries no
function name or source-line information for a human to step through). A
crash or panic's own OS-level backtrace would show one fewer native stack
frame for an inlined call site (`byte::nibble`'s own frame no longer
exists at runtime; its instructions run inside `web::high_nibble`'s own
frame) -- ordinary, expected inlining behavior, matching any optimizing
compiler, and no different in kind from what `TraversalAccess`/
`InlineRegionConsumerCall` already did before this milestone for their own
narrower cases. Compiler-internal diagnostics (NIR/CLIF text, this
report's own § 6) remain fully attributable to the true origin, since
every instruction still carries its own HIR expression id (§ 5.4) --
nothing about *this* provenance needed a debug-mode opt-out; § 11's
default-off decision is about an unrelated, pre-existing external testing
idiom, not about debug-build correctness.

## 14. Handwritten-equivalent comparison (spec § 95-98)

Handwritten generic form (no Byte/Nibble facts assumed):

```
fn high_nibble_handwritten(b):
    shift_right(bit_and(b, 240), 4)
```

vs. the real composition (`byte::nibble(byte::high_nibble(b))`), both
inlined (`-tiny-leaf-inline-opt 1`): both lower to the identical shape --
one guard, one `iand`, one `runbox`/`rishr`/`rbox` sequence, zero calls --
because `byte::nibble`'s own body, once its trailing `bit_and(...,15)` is
elided by the *pre-existing*, unrelated `native/lower.tcl` AND-identity
simplification (`BOUNDED-BIT-SHIFT-LOWERING.md`'s own Phase B, unmodified
by this milestone) whenever its own operand is already proven `[0,15]`,
*is* exactly `shift_right(bit_and(b,240),4)` -- this milestone's own
inlining is what lets that pre-existing simplification's precondition
(operand facts flowing through, unbroken by an ABI boundary) actually meet
the handwritten form, not a new rewrite rule of its own. `b >> 4` alone
(not `(b&240)>>4`) is **not** claimed equivalent here for an unconstrained
`b` (spec § 96's own explicit warning): no test in this diff asserts that
narrower identity, and no code anywhere assumes it. A separate,
deliberately-marked test establishing `b`'s own range as `Byte`-shaped
(`[0,255]`) was not added in this milestone -- § 3's existing structural
gate does not by itself look for or benefit from such a fact (masking
still runs; only its *result*, not its *presence*, is what downstream
facts could further simplify, and that is `hir/range.tcl`'s own,
unmodified, territory, not this milestone's).

## 15. Full-suite validation

- `tests/native-tiny-leaf-inline.test`: 30/30 (new), run standalone under
  `CORE_BACKEND=compile` and as part of the full suite below.
- `cargo test --release --manifest-path native/Cargo.toml`: 60/60 (no Rust
  source changed).
- `tclsh9.0 tests/all.tcl` (interp and compile backends, all 60 `.test`
  files in `tests/`, including this milestone's own new file): **1635/1635
  passed, 0 failed, 0 skipped**, both backend passes. This is the run that
  first surfaced the evidence behind § 11's default-off decision (with the
  flag briefly defaulted on during development, which broke a number of
  pre-existing `native-*.test` fixtures via the `FunctionBody`-by-name
  idiom, § 11's own account) and then confirmed fully clean once the
  default was corrected to off.
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **1635/1635 passed,
  0 failed, 0 skipped**, both backends -- confirming the existing root-map/
  safepoint machinery handles an inlined leaf's own caller correctly under
  forced collection, with no rooting change needed anywhere in this diff
  (§ 13).

## 16. Required questions

**Architecture (1-12)**

1. `native/lower.tcl`, at `Call`'s own ordinary block-call dispatch, right
   where it would otherwise emit `call`/`callenv`.
2. Because this codebase's HIR already allocates every id once, globally
   (no remapping needed), and `hir::range::analyze` already computed every
   used instance's own facts before lowering starts (nothing to
   recompute) -- § 2.3.
3. A callee instance is `LeafInlineEligible`: exact target, environment-
   free, straight-line body (`const`/`ref`/`bind`/native `call` only), no
   internal (Block-target) call, safe op family, no proven-always-fails
   call, shift error-safety proven where applicable, <= 8 native calls.
4. 8 native calls in the body (§ 3.1).
5. Yes -- only an exact, `hir::specialize`-resolved target (§ 3 rule 1).
6. Yes, required (`ENVLESS`, § 3 rule 2).
7. No -- categorically excluded via the straight-line-body rule (§ 3 rule
   3).
8. No -- categorically excluded via the native-only-call rule (§ 3 rule
   4).
9. No -- allocating natives are excluded from the safe op family (§ 3
   rule 5).
10. A `knownErrors` (proven-always-fails) entry declines; an ordinary
    unproven `guards` entry does not (§ 4); a shift additionally needs
    `LeafShiftSafe`'s own positive RANGE-safety proof (§ 3 rule 7).
11. By construction: no internal (Block-target) call is ever allowed in an
    eligible body (§ 3 rule 4) -- a recursive or mutually recursive
    function always contains one.
12. By requiring an *exact* resolved target (`fn targets`); a dynamic/open
    call has none, and never reaches this dispatch at all (§ 3 rule 1,
    § 9's `tiny-leaf-dynamic-call-not-inlined`).

**Semantics (13-20)**

13. `CallArgs`'s own pre-existing, unconditional per-argument evaluation
    (Call's ordinary path) runs before `InlineLeafCall` is ever reached;
    the callee's own body is bound to the *already-evaluated* registers,
    never re-evaluating an argument expression (§ 5.3).
14. The same `CallArgs` loop's own strict left-to-right order, unchanged
    (§ 5.3).
15. Yes -- `CallArgs` evaluates every argument regardless of whether the
    callee's body references the corresponding parameter (§ 5.3,
    `tiny-leaf-unused-argument-still-evaluated`).
16. Preserved exactly: an erroring argument raises before `InlineLeafCall`
    is reached at all (Call's own existing `never` short-circuit), with
    the identical error code on and off (§ 5.3,
    `tiny-leaf-argument-error-preserved`).
17. Trivially: `fn locals` is keyed by the globally-unique `BindingId`
    HIR already assigns (§ 5.1-5.2) -- no remapping table exists.
18. The callee's own last body expression's value becomes `InlineLeafCall`'s
    own return value (`Sequence`'s existing "last statement's result"
    convention); no HIR `return`-node completion-state handling is
    involved at all, since a `return` node is categorically excluded from
    eligible bodies (§ 3 rule 3).
19. By construction (§ 5.1): never needed, and none was built.
20. Every emitted instruction keeps `Emit`'s own existing `@E` (originating
    HIR expression id) suffix, unchanged (§ 5.4).

**Representation (21-28)**

21. Both: `byte::high_nibble`'s own `call` and `byte::nibble`'s own `call`
    (§ 6.1).
22. No new `runbox`/`rbox` counts were added by this milestone; the *same*
    one unbox/rebox pair `BOUNDED-BIT-SHIFT-LOWERING.md` already produced
    inside `byte::nibble`'s own body now simply runs inside
    `high_nibble`'s own function instead (§ 6.1-6.2).
23. Yes -- demonstrated directly: the shift stays raw (`rishr`) across
    what used to be the ABI boundary, with no additional box/unbox pair
    introduced by inlining itself (§ 5.4, § 6.1-6.2).
24. No new spills; `native::report`'s guard/blocker accounting and the
    full test/GC-stress suite (§ 15) show no regression.
25. Not materially: the caller (`high_nibble`) now has 15 registers
    instead of 3 (mostly dead constant-materialization leftovers, § 6.1's
    own note), a bounded, one-function-local increase, not a program-wide
    pressure change.
26. No: eligible leaves never allocate or touch a managed value (§ 3
    rules 5-6), so no root map changed; GC-stress confirms this (§ 13,
    § 15).
27. Yes, for the real case: `byte::high_nibble`/`byte::nibble` are absent
    from native frame walking entirely once their own last caller inlines
    (§ 7) -- an ordinary consequence of reachability, not a new
    mechanism.
28. Only in the sense any inlining does: one fewer native stack frame at
    that call site; this codebase has no interactive debugger for native
    code to begin with (§ 13's own debugger-implications paragraph).

**Real case (29-40)**

29. No. 30. No. 31. NIR: § 6.1. 32. True VCode: inspected directly
    (Cranelift's own vcode dump), confirming the identical no-call finding
    CLIF/objdump already show; not separately transcribed at length here
    beyond § 6.2-6.3's CLIF/assembly excerpts, which are the stronger,
    already-machine-level evidence spec § 76 itself prefers over VCode's
    own pre-regalloc register numbering. 33. Assembly: § 6.3.
34. Caller (`high_nibble`) code size: 78 -> 182 bytes (grows in isolation:
    its own former two `call`s' worth of arithmetic now lives here
    instead of in two separate small functions). 35. Whole-program: 16411
    -> 16284 bytes (shrinks overall: § 6.4). 36. Runtime: value unchanged
    (`[400,0]`); wall-clock was not re-measured (§ 17, matching every
    prior milestone in this vertical's own "this benchmark's dominant cost
    was never `high_nibble`" note -- § 79 of the milestone's own spec:
    "do not require a fixed percentage speedup"). 37. No -- the generic
    mask (`iand`, from `byte::high_nibble`'s own body) remains, because
    `b`'s own static type at this call site is not proven `int` (needs a
    guard, § 4) and its own range fact is unconstrained at the point the
    mask runs; masking `b` is still semantically required regardless.
38. See 37 -- the mask is not "removed", it was never provably redundant
    for this call chain's own actual (unconstrained-`Byte`) argument; only
    `byte::nibble`'s own *trailing* `bit_and(...,15)` was ever proven
    redundant, by the pre-existing, unrelated AND-identity simplification
    (§ 14), unchanged by this milestone. 39. N/A (37's mask was never
    removed; the trailing-AND elision that *was* already happening, § 14,
    used the pre-existing, unmodified Phase B mechanism, not anything new
    here). 40. No -- confirmed by direct inspection of every new proc in
    `native/lower.tcl`: none contains `byte`, `nibble`, `Byte`, `Nibble`,
    `HighNibble`, or any name from that vertical (only this report and the
    real-acceptance-case tests, which must name the real function to test
    it, do).

**Genericity (41-48)**

41. Yes (`tiny-leaf-generic-add-one-inlines`, § 10). 42. Not separately
    demonstrated with a bespoke second module (the real acceptance case
    *is* cross-module -- `lib/web.bot` calling `lib/byte.bot` -- and is
    this milestone's own primary evidence for § 52-53; see § 17's answer
    to the corresponding required question). 43. Yes
    (`tiny-leaf-dynamic-call-not-inlined`). 44. Yes
    (`tiny-leaf-ineligible-branch`). 45. Yes
    (`tiny-leaf-ineligible-self-recursive`/`-mutually-recursive`). 46. Yes
    (`tiny-leaf-ineligible-allocating`/`-mutating`). 47. Yes
    (`tiny-leaf-ineligible-erroring-mod`). 48. No -- confirmed by
    inspection: every eligibility/expansion rule reads only
    `hir::specialize`/`hir::aot`/`hir::range` facts already keyed
    generically by instance/expression id, never by a type's own name
    (identical reasoning to `CLOSED-CALL-PARAMETER-FACTS.md`'s own § 87 and
    `BOUNDED-BIT-SHIFT-LOWERING.md`'s own § 32).

**Code size (49-55)**

49. Eligible instances per program: § 9's table (`eligible instances`
    column; 0 in 9 of 13 programs, 1-4 in the other 4). 50. Actual inlines
    = eligible instances' own call-site count (every exact call site to an
    eligible instance inlines unconditionally, § 3.2) -- the `calls`
    column's own `on` vs `off` delta in § 9's table is exactly this
    count, per program. 51. Whole-program bytes: § 9's table; never
    grows, shrinks by up to ~2.7% where reached (`csv_records`: 21919 ->
    21624). 52. No -- checked directly against § 9's own table: no
    program's whole-program size grew. 53. § 3.1-3.2: a flat, callee-
    body-only op-count budget (no call-site-count weighting); in this
    milestone's own real and synthetic corpus this was never observed to
    cause pathological growth (§ 9), but is explicitly *not* a proof
    against every conceivable future program (§ 3.2's own stated scope
    limit). 54. Local (per-callee-body-size) only -- no global program-wide
    budget exists (§ 3.2). 55. Yes (`tiny-leaf-multi-call-site-
    deterministic`, § 12).

**Abstraction policy (56-60)**

56. Yes, for the eligible class specifically: § 14's handwritten-
    equivalent comparison shows byte-identical lowering once the pre-
    existing AND-identity simplification's own precondition is met by
    inlining removing the ABI boundary that used to block it from ever
    seeing `b`'s own facts continuously. 57. Yes: the real acceptance case
    is the demonstration -- `byte::high_nibble`/`byte::nibble` stayed
    ordinary Botlish functions (`lib/byte.bot` untouched, § 1), and their
    call overhead at their one real call site is now zero, without adding
    any Byte/Nibble-specific compiler code (§ 9's genericity table; § 16
    Q40/Q48). 58. Any shape `LeafInlineEligible` declines: branching,
    looping, recursive, capturing, allocating, or internally-calling
    functions, and calls that are not exact (§ 3, § 10's own ineligible
    test list) -- these still pay ordinary call overhead, unchanged by
    this milestone. 59. Evidence that a *currently*-ineligible shape
    matters in a *real* corpus program (this milestone's own real case was
    exactly that evidence, for straight-line scalar leaves) -- not merely
    "more call sites would inline" as its own goal (§ 72's own "the
    milestone's goal is not maximum call elimination"). 60. Yes,
    recommended: nothing in this milestone's own evidence argues for
    widening eligibility (branches, loops, allocation, or recursion) for
    Botlish 1.0 -- the real target class (tiny scalar stdlib leaves) is
    fully served by the narrow class implemented here.

**Scope (61-70)**

61. No. 62. No. 63. No. 64. No. 65. No. 66. No. 67. No. 68. No. 69. No
    (the public function ABI -- tagged in, tagged out -- is completely
    unchanged; only whether a *specific exact call site* ever constructs
    that ABI at all changed). 70. No -- confirmed structurally: no CFG
    merging, no cross-basic-block analysis, no multi-return handling, no
    loop/branch inlining exists anywhere in this diff; every eligible body
    is, by its own eligibility rule, already a single straight-line
    sequence with no control flow to merge.

## 17. Recommendation

Does this milestone provide evidence that low-level stdlib abstractions can
remain ordinary Botlish functions without paying unavoidable call
overhead? **Yes, for the class demonstrated**: `byte::high_nibble` and
`byte::nibble` are, and remain, ordinary Botlish functions
(`lib/byte.bot`, byte-for-byte unchanged across this entire multi-milestone
vertical) with a verified real call chain (`web.bot`'s `high_nibble`) that
now compiles to zero function-call overhead and zero redundant
representation-transition instructions at that call site (§ 6), with the
same guard the ordinary (uninlined) form already needed, and no new
runtime helper.

**This milestone does not claim all abstraction is free** (spec's own § 94
instruction): only the eligibility class in § 3 is zero/near-zero cost --
any Botlish function with a branch, a loop, recursion, an internal call to
another Botlish function, an allocation, or an unproven-safe error path
still pays ordinary call overhead, unchanged. `is_unreserved` (the other
threshold ladder in `web.bot`) is untouched and does not qualify (its own
body is one long `if`/`else` chain -- rule 3 excludes it outright); this is
expected, not a gap this milestone tried to close.

**Should this remain deliberately narrow for Botlish 1.0?** Recommended
**yes**. The real corpus already exercises this class four times beyond
the motivating byte/nibble case (§ 9: `csv_chunked`/`csv_records`/
`hashtable`), with whole-program code size shrinking every time it fires
and never growing when it does not -- evidence the class chosen is both
useful and safely bounded, without needing branches, loops, allocation, or
recursion support to serve its own real target. Widening it is a future
decision that should wait for its own real-corpus evidence, exactly the
discipline this milestone itself was built under (spec § 99: "do not
broaden eligibility because one test fails").

**Is the Byte/Nibble vertical now codegen-complete enough to move its type
declarations into Botlish source?** This milestone's own answer is
**orthogonal, not blocking**: every mechanism here (eligibility,
substitution, facts, representation) operates on `hir::specialize`/
`hir::aot`/`hir::range`'s already-generic, name-independent structures --
confirmed directly, the same way `BOUNDED-BIT-SHIFT-LOWERING.md`'s own § 32
confirmed it for the shift-lowering milestone before this one. A future
`type HighNibble = Byte in {0,16,...,240}` surface declaration lowering
into the same `core::type::register`-shaped metadata would reach this
milestone's own eligibility/expansion logic identically, with zero
additional compiler change needed here. Whether to actually make that
surface-syntax move is `BYTE-NIBBLE-BIT-ARITHMETIC.md`'s and
`CLOSED-CALL-PARAMETER-FACTS.md`'s own next-step question, not this one's
to answer -- this milestone's only contribution to it is confirming, once
more, that nothing in the codegen path it touches would need to change
either way.
