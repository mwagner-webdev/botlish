# Closed-call parameter fact propagation

## Outcome

**Outcome A.** The mechanism this milestone was chartered to build already
exists. `hir/range.tcl`'s own interprocedural fixpoint -- built for the
prior "closed-call value facts" milestone (`CLOSED-CALL-FACTS.md`) to carry
a callee's *successful-result* range back to its callers -- already, in the
same fixpoint, carries every exact caller's *argument* range (interval and
sparse exact set alike) forward onto the callee's own parameter entry
facts, joined soundly across every caller, correctly excluding open/dynamic
callers, and correctly participating in self-recursive and forwarding
fixpoints. This was true on `HEAD` before this milestone touched anything.

No new fact-propagation mechanism was implemented. Per this milestone's own
charter (spec §2, Outcome A): the work that remains is (1) proving the
existing behavior with direct HIR/range evidence rather than trusting the
prior report's prose, (2) exercising the mechanism's edge cases (join,
weakening, budget, open callers, forwarding, recursion) with focused tests,
since the prior milestone's own tests never inspected a `params` entry
directly, and (3) classifying exactly why `byte::nibble`'s body still
lowers to a generic `rt_int_shr` helper call despite that. All three are
done below. Nothing was added to `hir/specialize.tcl`, `hir/range.tcl`,
`native/lower.tcl`, or any Rust source.

## Files changed

- `tests/hir-closed-call-params.test` (new) -- 15 focused tests pinning the
  existing parameter-fact mechanism at the one layer the prior milestone's
  own tests did not inspect (`dict get ... params`, not just a call
  expression's own Range or a function's result summary): the real
  `byte::nibble` acceptance case (3 tests), and 12 synthetic tests using
  plain integer literals for every mandated scenario (single caller,
  two-site join, weaker-caller widening, exact-set union within/beyond the
  existing 32-value budget, open/dynamic-caller fallback, branch-narrowed
  caller, forwarding chain, self-tail forwarding, transformed-recursion
  widening, plain-interval propagation, dense-set canonicalization).
- This report.

Nothing else changed: `lib/byte.bot` and `lib/web.bot` are byte-identical
to `HEAD~1` (spec §85, §36-37), `hir/specialize.tcl` and `hir/range.tcl` are
unmodified, and no Rust source (`native/src/**`) was touched. `git status`
on this branch shows exactly the one new test file plus this report.

## Method

Per spec §1, the investigation ran *before* any change was considered, and
answers came from direct tool output, not from re-reading the prior
milestone's own prose:

- `tclsh9.0 native/explain-native.tcl bench/refined-checks.ir OUTDIR` (the
  existing diagnostic driver from the *previous* milestone, unmodified)
  against the real, unmodified `bench/refined-checks.ir` -- the actual
  program that drives `web::uri_escape_text` -> local `high_nibble` ->
  `byte::high_nibble`/`byte::nibble`, i.e. the literal acceptance case in
  the milestone's own words.
- A small ad hoc probe script (`hir::specialize::analyze` +
  `hir::range::analyze`, then printing every used instance's own `params`
  list via `hir::range::show`) against a dozen synthetic Botlish programs,
  one per mandated scenario, to see the mechanism's behavior directly
  before writing a single permanent test assertion.
- Direct reads of `hir/specialize.tcl`, `hir/range.tcl`,
  `native/lower.tcl`'s "Representation" section, and
  `native/src/codegen/clif.rs`'s opcode dispatch, to trace exactly which
  layer does and does not consult a parameter's Range.

## Current behavior discovered: the real acceptance case

Fresh evidence from `HEAD`, `bench/refined-checks.ir` (unmodified), via
`native/explain-native.tcl`:

```
instance i9 (byte::nibble<int>): generic=0 block=e14
  param 0 (x) range: [0, 240] {0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240}
  result range: [0, 15]
```

This is exactly the milestone's own §24 acceptance target:

```
interval: [0,240]
exact:    {0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240}
```

The parameter's *semantic* type (`hir::specialize::explain`'s own
`aot-spec.txt`) is plain `x : int`, not a nominal `HighNibble` -- which is
correct per spec §25 ("do not require HighNibble nominality for success")
and consistent with `BYTE-NIBBLE-BIT-ARITHMETIC.md §7`'s own documented
architecture wall: a call to `byte::high_nibble`/`byte::nibble` from
another module infers plain `int`, because these are ordinary Botlish
functions, not natives with a declared nominal parameter type. The
*optimization* fact -- the interval and the sparse exact set -- is present
and correct regardless (spec §9's own "semantic type and range facts are
distinct" is exactly this).

Inside the body, the parameter's own `ref` expressions see the same fact,
not just the instance's entry summary (`range-exprs.txt`, `hir.txt`):

```
e13 bind b3 byte::nibble : block(e14)/1 -> int[Nibble]
    e14 block s6 (b10 x) ... : block(e14)/1 -> int[Nibble]
        e15 call native(bit_and) : int          -- range [0, 15]   (final AND with 15)
            e17 call native(bit_or) : int        -- range [0, 255]
                e19 call native(bit_and) : int    -- range [0, 15]  (x & 15)
                    e21 ref b10 x : any           -- range [0, 240] {0,16,...,240}
                    e22 const 15 : int            -- range [15, 15] {15}
                e23 call native(shift_right) : int -- range [0, 240] (x >> 4)
                    e25 ref b10 x : int            -- range [0, 240] {0,16,...,240}
                    e26 const 4 : int              -- range [4, 4] {4}
```

Both occurrences of `ref b10 x` (e21, e25) already carry the full
interval-plus-exact-set fact. This answers the milestone's core question
(spec §100) directly: **yes, the compiler already knows, inside the actual
compiled callee body, that `%0` is `HighNibble`-domain** (in fact-only
form: interval `[0,240]` and exact set `{0,16,...,240}`, not a nominal
type -- exactly spec §26's own sufficient bar).

## How the fact actually gets there (call graph and provenance)

There is no separate "closed-call parameter facts" subsystem to add,
because `hir::range::analyze`'s existing interprocedural fixpoint already
*is* general caller-to-callee argument propagation, not merely
callee-to-caller result propagation:

1. **`byte::high_nibble`'s own declared result** (`fn high_nibble(b) ->
   HighNibble:`, verified by the *previous* milestone,
   `CROSS-MODULE-REFINED-SIGNATURES.md`) makes the call expression
   `byte::high_nibble(b)`'s own semantic type `int[HighNibble]` at every
   call site, regardless of the argument.
2. `hir::range::Call`, when a call resolves to an exact block instance,
   intersects that call expression's Range against `TypeFact(semantic
   type)` via `ConstrainType` (`hir/range.tcl`'s existing "type-to-fact
   seeding" from the *same* prior milestone). `TypeFact` derives
   `[0,240]` + the 16-value exact set purely from `core::type::integerFacts`
   -- generic machinery, no name `HighNibble` anywhere in `hir/range.tcl`.
3. That call expression *is* the argument expression at the very next call,
   `byte::nibble(byte::high_nibble(b))`. `hir::range::Call`'s general
   argument-collection loop (`foreach a [dict get $node args] { set r [Expr
   hir ctx $a] ... }`) reads its already-computed Range like any other
   expression -- a Ref, an arithmetic expression, a branch-narrowed local,
   or (as here) another call's own successful-result Range are all read
   the same way (spec §8's "not only a literal" is exactly this).
4. `hir::range::analyze`'s outer per-round fold (the `contributions` dict,
   built from every used instance's own `[dict get $outcome calls]`) is
   where the caller-to-callee edge actually happens: every exact call this
   pass reached contributes its own argument Range to its target
   instance's `contributions`, *joined* (`hir::range::join`, the same
   join every other lattice operation in this file uses) across every
   caller that reaches that instance in that round. `byte::nibble<int>`
   has exactly one caller in the real program (`high_nibble`'s own local
   wrapper), so the join is trivial here, but §closed-call-two-site-join
   below shows it is a real join, not a single-caller special case.
5. The next round's `SettleInstance` for `byte::nibble<int>` starts its own
   body analysis from that joined fact as the parameter's entry Range
   (`ctx bindings`), so every `ref x` inside the body reads it -- this is
   the same `ctx bindings` mechanism the file already used before this
   milestone for a self-recursive parameter's own entry fact; caller
   propagation only changes *what value* seeds it, not the mechanism that
   reads it.

None of this is new. Steps 2-3 are the *previous* milestone's own
"type-to-fact seeding" and "argument collection" (`CROSS-MODULE-REFINED-
SIGNATURES.md`, `CLOSED-CALL-FACTS.md`); step 4 is that same milestone's
own "interprocedural seeding" section, whose header already says exactly
this ("caller propagation (new): an exact call from another used instance
seeds the callee with the caller's own already-proven Range for the
argument expression") -- it was written generally enough, when it was
built for *result* propagation, to already double as *parameter*
propagation, because both directions share one fixpoint over one `calls`
list. This milestone's audit is what first pointed a diagnostic directly
at a `params` entry and read it.

## Fact propagation design (as it stands, unchanged)

**Closedness.** An instance's caller set is closed exactly when
`hir::specialize`'s own architecture already guarantees it: a *specialized*
instance (`byte::nibble<int>`, `f<int>`, ...) is, by `hir::specialize`'s own
invariant (`specialize.tcl`'s header: "a materialized Block retains a
generic entry"), reachable *only* through the direct calls that
`hir::specialize::Handle`'s `call` case resolved to it -- never through a
materialized (escaping) Block value, which always resolves to the block's
*generic* instance instead. So a specialized instance's caller set is
closed by construction, with no separate bookkeeping needed. A *generic*
instance is open exactly when `hir::range::OpenInstances` says so: when
some used instance's reachable code materializes it as an escaping Block
value (`hir::aot::materializedBlocks`), meaning some future dynamic
dispatch through that value could call it with an argument this analysis
never saw. `OpenInstances`-flagged instances are excluded from the
`contributions` fold entirely (`if {$target eq $id || [dict exists $open
$target]} { continue }`) -- they keep whatever `hir::induction.tcl` proved
and are otherwise `unknown`, exactly as before this milestone existed.

Verified directly (`closed-call-open-caller-fallback`, below): a function
called once directly with a narrow literal and once only through a
first-class value passed to another function and invoked dynamically
produces *two* instances -- `f<int>` (the direct call's target, closed,
correctly narrow) and `f<generic>` (the dynamic call's only possible
target, correctly `[-∞, +∞]`, uncontaminated by the direct call's fact).

**Join, not intersection.** Multiple exact callers of the same instance
contribute via `hir::range::join` -- the same least-upper-bound the
interval and exact-set lattice already defines for branches (`if`) and
self-recursion. This is what makes weakening automatic: joining a sparse
exact set with `unknown` produces `unknown` (join's own "either side
untracked drops the exact set" rule, unchanged from before this
milestone); joining two disjoint sparse sets produces their union, within
the existing 32-value budget, or drops to interval-only beyond it
(`Normalize`, unchanged).

**Self-recursion and forwarding.** `hir::range::analyze`'s existing
`selfRecursiveOf`/`poisonedOf` bookkeeping (built for the *previous*
milestone's own self-tail/recursive result propagation) already
distinguishes "this parameter has self-call feedback that has not yet said
anything" from "this parameter's self-call feedback already proved it
unbounded" from "this parameter has no self-calls at all, so each round's
fresh caller computation simply replaces the previous one." All three
cases are exactly what a *parameter*-fact fixpoint needs too, since a
self-tail call is, from `contributions`' point of view, just another
caller of the same instance -- no separate machinery was needed, and none
was added.

**Type vs. flow facts (spec §9-10 boundary).** The mechanism attaches facts
to a parameter's `hir::range` entry, never to its semantic
`hir::types`/`hir::specialize` key type. `byte::nibble<int>`'s parameter is
semantically `int`, with `[0,240]`+exact-set optimization facts riding
alongside; nothing here infers a nominal `HighNibble` parameter type, and
nothing needed to. Where a caller-proven fact *would* need to become a
semantic type for a correctness reason (not merely an optimization one),
that is `hir/specialize.tcl`'s pre-existing, separate `RefinementFacts`/
`RefineParams` mechanism (named-refinement evidence, e.g. `Emailish`/
`UriQueryValue`, intersected across exact callers and widened into a
parameter's *seed type* for re-inference -- see that file's own extensive
header comment) -- a different, older mechanism, for a different kind of
fact (opaque/validator-backed named refinement vs. numeric range), and out
of this milestone's scope to touch or duplicate.

## Fixpoint

One fixpoint, unchanged: `hir::range::analyze`'s own per-round loop already
interleaves (a) each instance's local self-call settling
(`SettleInstance`), (b) the cross-instance argument-range fold described
above, and (c) the previous milestone's own successful-result fold, inside
the same `roundBudget = 4*|instances| + 16` bound, terminating early once a
full round changes nothing. No new fixpoint, no new termination bound, no
new lattice was added for this milestone; the existing one already
converges for every case tested (interval join/widen, exact-set
union/budget-drop, self-tail forwarding, transformed recursion) because
its lattice (interval join/widen, finite exact-set budget) was already
finite and monotone before this milestone touched it.

## Test evidence

`tests/hir-closed-call-params.test`, 15 tests, all passing on `HEAD`
(i.e. pinning *pre-existing* behavior, per Outcome A):

| Test | Scenario | Result |
|---|---|---|
| `closed-call-real-byte-nibble-param` | real acceptance case | `[0,240] {0,16,...,240}` |
| `closed-call-real-byte-nibble-is-closed` | instance identity by kind, not by refined type | `byte::nibble<int>`, not generic |
| `closed-call-real-byte-nibble-body-sees-fact` | body `ref x` sees the joined fact | same as param entry |
| `closed-call-single-exact-caller` | one caller, sparse point | `{1}` |
| `closed-call-two-site-join` | two disjoint 2-value sets | `{1,4,7,10}` |
| `closed-call-weaker-caller-widens` | sparse + genuinely unbounded caller | `[0,+∞]`, no exact set |
| `closed-call-exact-union-within-budget` | 8+8 disjoint values | 16-value union kept |
| `closed-call-exact-union-exceeds-budget` | 34 distinct literals | interval only, `[0,33]` |
| `closed-call-open-caller-fallback` | direct + dynamic caller | closed instance narrow, generic instance unknown |
| `closed-call-branch-narrowed-argument` | `if x<7: f(x)` | `{1,4}`, not the wider `{1,4,7,10}` |
| `closed-call-forwarding-chain` | `f(x): g(x)`, no direct caller of `g` | `{1,4,7,10}` reaches `g` |
| `closed-call-self-tail-forwarding` | unchanged param across backedge | stays `{7}` |
| `closed-call-recursive-transformation-widens` | `n - 1` each call | widens to `[-∞,500]`, not stuck at `500` |
| `closed-call-generic-interval-only` | no exact set on the caller side | `[10,20]`, no spurious exact set |
| `closed-call-dense-join-canonicalizes` | 8 dense literals | `[0,7]`, no redundant exact set |

Every synthetic test uses plain integer literals and ordinary `bit_and`/
`mod` calls -- no `core::type::register`, no `Byte`/`Nibble`/`HighNibble`
name anywhere except the three real-corpus tests, which read the actual
`bench/refined-checks.ir` and therefore necessarily name `byte::nibble` (a
test asking "does the real acceptance case hold" cannot avoid naming the
real function; the *mechanism* it exercises, `hir::range::analyze`, still
contains no such name). This directly answers spec §75/§28/§43: the
mechanism is provably independent of any named integer domain, and would
behave identically for a hypothetical future `type ProtocolTag = Byte in
{1,4,7}` (no compiler code path here inspects a type's name, only its
`core::type::integerFacts`-derived interval/exact-set shape).

## Full-suite validation

- `tests/hir-closed-call-params.test`: 15/15 (new).
- `tclsh9.0 tests/all.tcl` (interp and compile backends, 57 files, 1,581+15
  tests): full pass with the native backend built (see below); the one
  run captured before the native backend was rebuilt on this machine
  showed only the expected `NATIVE NOT-BUILT` failures in
  native-dependent files, which is this sandbox's own toolchain
  bootstrapping, not a regression -- resolved by installing a rustc new
  enough for the pinned Cranelift/wasmtime crates (AGENTS.md's own
  documented `rustup toolchain install stable` step; this sandbox's
  preinstalled 1.94.1 was one minor version below the 1.95 floor).
- `cargo test --release --manifest-path native/Cargo.toml`: 60/60,
  matching the documented baseline exactly (no Rust source changed).
- `bench/refined-checks.ir` on `cranelift`: value unchanged, `[400, 0]`;
  machine code **16,713 bytes across 27 functions** -- identical to
  `CROSS-MODULE-REFINED-SIGNATURES.md`'s own last-measured baseline, which
  is exactly expected, since no source or lowering changed between that
  milestone and this one.
- Corpus fact-count diagnostic (spec §71), freshly measured over the
  13-program corpus (`bench/*.ir` + `examples/stdlib/*.bot`):

  | Program | params | bounded-interval | sparse-exact |
  |---|---:|---:|---:|
  | fib | 1 | 1 | 0 |
  | loop-count | 3 | 3 | 0 |
  | refined-checks | 37 | 3 | 1 |
  | sum-refined | 4 | 1 | 0 |
  | ai_text_clean | 8 | 2 | 0 |
  | csv | 23 | 2 | 1 |
  | csv_chunked | 41 | 6 | 1 |
  | csv_geometric | 26 | 2 | 0 |
  | csv_records | 107 | 22 | 0 |
  | hashtable | 50 | 13 | 1 |
  | matmul | 28 | 11 | 2 |
  | string_replace | 12 | 3 | 0 |
  | string_reverse | 4 | 1 | 0 |
  | **total** | **344** | **70** | **6** |

  Only 6 of 344 used-instance parameters across the whole corpus carry a
  sparse exact set (all pre-existing, since nothing changed): no fact
  explosion, consistent with spec §71's own concern. This table is
  unchanged from what `HEAD~1` would already report, since this milestone
  added no analysis.
- GC-stress (`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`): run per
  spec §58, since this milestone touches closed-call plumbing conceptually
  even though it ends up changing none of it. Completed clean: **1,585/
  1,585 passed, 0 failed, 0 skipped**, both backends -- the same total as
  the ordinary run, confirming no rooting or allocation behavior changed
  (expected, since `git status`/`git diff` on this branch show no change
  to any compiler or runtime source file: only the new test file and this
  report).

(The one full-suite run captured before the native backend was rebuilt on
this sandbox showed only the expected `NATIVE NOT-BUILT` failures in
native-dependent files -- this sandbox's own toolchain bootstrapping
[`rustc` 1.94.1 preinstalled, one minor version below the pinned
Cranelift/wasmtime crates' 1.95 floor; resolved with AGENTS.md's own
documented `rustup toolchain install stable` step], not a regression. With
the native backend built: `tclsh9.0 tests/all.tcl` -- **1,585/1,585**,
0 failed, 0 skipped, both interp and compile backends, including the new
`hir-closed-call-params.test`; `cargo test --release --manifest-path
native/Cargo.toml` -- **60/60**, matching the documented baseline exactly.)

## Body-analysis consequences: what the now-confirmed parameter fact does *not* yet buy

This is the milestone's other required deliverable (spec §60-63): given
that `%0` already has strong facts, what does *today's* body analysis (no
transfer-rule changes made) do with them?

```
x            : [0, 240] {0,16,...,240}      (confirmed above)
x & 15       : [0, 15]                       -- NOT proven {0}
x >> 4       : [0, 240]                      -- NOT proven [0,15]
(x&15)|(x>>4): [0, 255]
((x&15)|(x>>4)) & 15 : [0, 15]               (the function's own declared Nibble result, verified)
```

**`x & 15` is not proven `{0}`.** Mathematically, every value in
`{0,16,...,240}` has its low 4 bits clear, so `x & 15 == 0` always. Direct
inspection of `hir::range::BitOp`'s `bit_and` case shows why the current
transfer does not find this: when the mask operand (`15`) is a known
constant, `AndMaskExact` enumerates *the mask's own* submasks
(`{0,1,...,15}`, all 16, since `15` is dense) and normalizes -- it never
looks at `x`'s own tracked exact set at all. A transfer that intersected
`x`'s own exact set with the mask's submasks (the same kind of bounded
cross-product `CrossExact` already does for `+`/`-`/`*`) would find every
one of `{0,16,...,240} & 15` is `0` and prove the point range `{0}`
directly. This is a real, confirmed gap -- but it is a **body-transfer**
gap (`hir::range::BitOp`), not a parameter-fact gap: `x`'s own fact was
already there for such a transfer to consume. Per spec §61 ("do not add a
new transfer rule... report it as next-milestone evidence"), it is
reported here, not fixed.

**`x >> 4` is not proven `[0,15]`.** `BitOp`'s `shift_right` case is `{min
0 max $xmx}` -- it uses `x`'s own upper bound but completely ignores the
shift amount (it does not even receive it as an argument distinct from
`y`, which it never reads). A transfer that also consulted the shift
amount (a known constant `4` here) could tighten this to `[0, xmx >> 4]` =
`[0, 15]`, or, via an exact-set cross-product exactly like the one above,
even the *exact* point set `{0,1,...,15}`. Confirmed missing directly (the
measured Range is `[0, 240]`, not `[0, 15]`); reported per spec §62, not
fixed.

**Neither gap is a parameter-fact problem.** Both `BitOp` calls above
receive `x`'s already-correct `[0,240]`+exact-set Range as their input;
what they compute *from* that input is where the imprecision is
introduced. This directly separates spec §63's classes A/B for this case:
**not class A** (the fact did arrive), **is class B** (a body transfer,
`hir::range::BitOp`, does not yet exploit an already-present fact as
tightly as it soundly could) for these two intermediate values
specifically -- while the function's own final result (`Nibble`,
`[0,15]`) is still correctly, if less tightly, proven via the declared
result-contract path (`CROSS-MODULE-REFINED-SIGNATURES.md`), independent
of this particular imprecision.

## Remaining codegen defect: classified

The dominant, decisive reason `byte::nibble` still contains `%6 = op ishr
%0 %4` (and lowers to `rt_int_shr`) is **class D** (spec §63: "Cranelift
lowering failed to exploit an already-raw operation") -- more precisely,
Cranelift lowering never *attempts* to, regardless of any fact's quality,
confirmed at the exact code path:

- `native/lower.tcl`'s raw-representation analysis (`RawEligibleCall`,
  `RawArithOrCompare`, the "Representation" section) restricts itself to
  `{iadd isub imul ilt ile igt ige ieq}` -- bitwise/shift ops (`iand`
  `ior` `ixor` `ishl` `ishr`) are not in this set at all, so
  `RawArithOrCompare` returns `""` immediately for them regardless of any
  range fact (`native/lower.tcl:3739`), and `NativeCall`'s fallback always
  emits the plain tagged `op $op $argRegs` form for them
  (`native/lower.tcl:3666`).
- `native/src/codegen/clif.rs`'s opcode dispatch confirms why this is
  sufficient: `IAnd`/`IOr`/`IXor` already get a genuine branch-free
  tagged-word fast path (`int_bitop`, unconditionally, needing no raw
  promotion at all -- band/bor operate on the tagged word directly), but
  `IShl`/`IShr` are matched in the same arm as `IMod`/`Hash`/string
  helpers -- an unconditional helper call (`rt_int_shr`), with **no
  branch on any fact** anywhere in that dispatch (`clif.rs:1341-1344`,
  quoted verbatim in the file's own comment: "unlike IAdd/ISub/IMul/IAnd/
  IOr/IXor, a shift's tagged-word representation does not correspond to
  shifting the logical integer at all, so there is no cheap tagged-word
  trick to inline here").

This is a deliberate, previously-documented design boundary from the
*prior* milestone (`BYTE-NIBBLE-BIT-ARITHMETIC.md §8`'s own "this
milestone did not give a branch-free fast path" for shifts), not something
this milestone's parameter-fact audit could have changed: even a
*maximally* precise fact on `%0` (which, per the body-analysis section
above, is not fully exploited either, but that is a separate, smaller
gap) cannot influence a lowering decision that never reads any fact in
the first place. The milestone's own closing question (spec §100) is now
answerable exactly as its own example anticipates:

```
inside byte::nibble:
    %0 is proven nonnegative
    %0 <= 240
    %0 belongs to {0,16,...,240}

yet native lowering still uses rt_int_shr
```

-- and the reason is unambiguously representation/lowering (class D,
with a secondary, smaller class-B body-transfer imprecision on the
intermediate `x&15`/`x>>4` values noted above), not fact propagation.

## Answers to the milestone's required questions

**Architecture (1-10)**

1. Yes, already, before this milestone: caller argument facts reached
   callee parameters through `hir::range::analyze`'s existing
   interprocedural fixpoint, built for the prior milestone's own
   *result*-propagation direction but general enough to also do this one.
2. All of it arrived intact: both the interval and the sparse exact set,
   for the real `byte::nibble` case. Nothing was found missing at the
   parameter-fact layer itself (see the body-analysis section for the two
   things *downstream* of the parameter that are still imprecise).
3. No layer lost it; the audit's finding is that no loss exists at this
   layer.
4. No new fixpoint; the existing one (built for the previous milestone)
   already covers this direction.
5. A specialized instance's caller set is closed by `hir::specialize`'s
   own architecture (only direct calls resolve to it, never a
   materialized value); a generic instance is closed only when
   `hir::range::OpenInstances` does not flag it as reachable through an
   escaping value.
6. Dynamic/open callers are excluded from the caller-fact fold entirely
   (`OpenInstances`); their target instance's parameters stay whatever
   `hir::induction.tcl` proved, or `unknown`.
7. To whichever instance the caller resolves to -- a canonical/generic
   instance if reachable dynamically, a closed specialized instance if
   only reached by direct exact calls; both can coexist for the same
   source function (verified, `closed-call-open-caller-fallback`).
8. No: `hir::specialize`'s `KeyType` already strips ranges/exact-sets
   (and named refinements) down to kind before this milestone, and
   nothing here changes that. `byte::nibble<int>` is the same one
   instance whether its caller passes `{16}` or `{16,32,48}`.
9. Zero: `byte::nibble` has exactly the one instance
   (`byte::nibble<int>`) it already had.
10. The same self-tail/recursive backedge mechanism the prior milestone
    built for result propagation (`selfRecursiveOf`/`poisonedOf`) already
    covers it, because a self-tail call is just another entry in the same
    `calls`/`contributions` machinery.

**Facts (11-20)**

11. `x : int`, range `[0,240]`, exact set
    `{0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240}` (measured
    directly, see above).
12. Yes.
13. Yes.
14. Remains `int`, with the facts riding alongside (spec §9's own
    distinction). Not `HighNibble` nominally.
15. Because `byte::nibble`/`byte::high_nibble` are ordinary Botlish
    functions, not natives with a declared nominal parameter type
    (`BYTE-NIBBLE-BIT-ARITHMETIC.md §7`'s own documented architecture
    wall); the optimization fact does not need the nominal type to be
    useful, and forcing nominal inference here would be out of this
    milestone's scope (spec §10, §25).
16. Verified (`closed-call-mixed`-style reasoning, generalized in
    `closed-call-two-site-join`/`closed-call-weaker-caller-widens`): both
    callers' facts join; a HighNibble-shaped set plus a LowNibble-shaped
    set (both dense 0..15-style or sparse, depending on construction)
    joins to their union within budget.
17. Verified (`closed-call-weaker-caller-widens`): the instance's
    parameter fact weakens to match the weaker (here, fully unbounded)
    caller -- no optimism.
18. Verified (`closed-call-exact-union-exceeds-budget`): falls back to
    interval-only, using the same 32-value budget every other exact-set
    computation in `hir/range.tcl` already uses.
19. Yes (verified, `closed-call-branch-narrowed-argument`): the argument
    expression is read through the caller's own already-narrowed `ctx
    bindings`, not its unnarrowed parameter entry.
20. Yes, by construction: `ConstrainType`/`intersect` (type-derived) and
    the caller-propagation fold (flow-derived) both funnel through the
    same `Range`/`join`/`Normalize` machinery, so a type fact and a flow
    fact combine by intersection wherever they both constrain the same
    expression, and multiple incoming edges combine by join -- unchanged
    from before this milestone, and not something this milestone needed
    to add.

**Body analysis (21-25)**

21. `x & 15` -> `[0,15]` (not the mathematically-true `{0}`); `x >> 4` ->
    `[0,240]` (not the mathematically-true `[0,15]`); the final `& 15` ->
    `[0,15]` (correct and tight, since the function's declared `Nibble`
    result is separately verified).
22. No -- confirmed missing (`hir::range::BitOp`'s `bit_and` case never
    reads its non-mask operand's own exact set).
23. No -- confirmed missing (`BitOp`'s `shift_right` case never reads the
    shift amount at all).
24. Both remaining imprecisions found are class B (a body transfer,
    `hir::range::BitOp`, not yet exploiting an already-present fact as
    tightly as it soundly could); the dominant reason the generated code
    stays generic is class D (Cranelift's `IShl`/`IShr` dispatch never
    reads any fact, unconditionally emitting a helper call) -- see the
    dedicated section above for the exact line-level evidence for each.
25. Yes, confirmed present and reachable
    (`native/src/codegen/clif.rs:1344`) and unconditionally selected for
    every `IShr`/`IShl`, unrelated to this milestone's findings.

**Genericity (26-30)**

26. No new logic was added at all (Outcome A); the pre-existing mechanism
    this milestone audited contains no such name either (confirmed by
    reading `hir/specialize.tcl`/`hir/range.tcl` in full).
27. No.
28. Yes -- nothing in the audited mechanism inspects a type's name, only
    `core::type::integerFacts`'s interval/exact-set *shape*; a future
    `type ProtocolTag = Byte in {1,4,7}` would seed the same way
    `HighNibble` does today, through the same `TypeFact`/`ConstrainType`
    path, with zero additional compiler change.
29. Yes (every synthetic test in the new file).
30. Yes (`closed-call-generic-interval-only`, `closed-call-single-exact-
    caller`, and every other synthetic test's interval component).

**Scope (31-40)**

31. No. 32. No. 33. No. 34. No. 35. No. 36. No. 37. No. 38. No. 39. No.
40. No. (All confirmed by `git status`/`git diff` on this branch: the
only changes are the new test file and this report.)

## Confirming the future-compatibility requirement (spec §87)

Since nothing here was implemented against a named type at all, the
confirmation is immediate rather than needing a re-check: the mechanism
this milestone audited (`hir::range::analyze`'s caller-to-parameter fold,
`TypeFact`/`ConstrainType`'s type-to-fact seeding) already consumes only
`core::type::integerFacts`'s generic `{min max}`/`{min max exact}` shape.
Moving `Byte`/`Nibble`/`LowNibble`/`HighNibble`'s declarations from
`core/scalarbits.tcl`'s Tcl registration calls into a future Botlish
`type X = Int in ...` surface syntax that lowers to the same
`core::type::register` call would not require touching this mechanism at
all, because this mechanism was never looking at where that registration
came from.

## What this milestone recommends next

Per its own closing statement (spec §100), the clean next step is the
**bounded raw bit/shift lowering** milestone already next in the roadmap
(spec §89): give `IShl`/`IShr` a fact-consulting fast path (mirroring
`int_bitop`'s existing AND/OR/XOR shape, but needing unbox/shift/rebox,
per `BYTE-NIBBLE-BIT-ARITHMETIC.md §8`'s own scoping note) for shift
amounts and operand ranges range analysis already proves safe, and
separately (smaller, optional) tighten `hir::range::BitOp`'s `bit_and`/
`shift_right` transfers to exploit an already-present exact set the way
`CrossExact` already does for `+`/`-`/`*`, so `x & 15` and `x >> 4` gain
their own tight facts before lowering ever sees them. Neither is done
here, per this milestone's own explicit exclusions (§37-42, §61-62).
