# M2: exact callable-target provenance and closed-call devirtualization

## Outcome

**No production code changed.** The motivating real path -- `esc_char`'s
call through `web::is_unreserved` in `bench/uri-steady.bot`/`lib/web.bot`
-- is already an ordinary direct `callenv` to a statically known target,
confirmed at every layer down to the actual x86-64 machine code (a
`call rel32` to the fixed symbol `botlish_fn_9`, not an indirect
register-call). This was already true on the tree M2 started from (the
post-M1 tree, commit `dfa2b19`); it does not depend on anything this
milestone did. M1's own report speculated that this edge was "indirect/
call-through-value dispatch" -- that speculation was checked directly
against the real HIR/NIR/asm and found to be **incorrect**: it was inferred
from seeing `web::is_unreserved` listed among `esc_char`'s NIR parameter
names, without checking that `native::lower::Call` already treats any HIR
call node whose semantic `target` resolved to an exact `{block B}` as a
direct call, regardless of whether the callee's *value* arrived via an
ordinary reference, a capture, or (as here) a capture forwarded down
through nested envless functions as an explicit NIR parameter.

The residual conservative behavior actually present on that edge --
`esc_char -> web::is_unreserved` is stamped `may_error=true`, producing one
`test rax,rax`/`je` caller-side retest -- is real, but has **nothing to do
with callable-target identity**. It is caused by `web::is_unreserved`'s own
body containing an `op setcontains` (the `immutable_set_contains` call
lowering, `MINIMAL-IMMUTABLE-SET.md`), and `SetContains` is unconditionally
classified `may_error` by `native/src/runtime/ops.rs::op_may_error`,
because `rt_set_contains`'s runtime implementation can raise `EQUALITY`
for element kinds without structural equality (Block/Native/MutArray) --
a fact about the opcode, not about which function is called or how. This
is explicitly out of M2's own scope ("do not change may_error analysis",
"do not change ImmutableSet representation") and is recorded below as the
next first-loss candidate for a future milestone, not fixed here.

A second, general question this milestone was also chartered to answer --
"does an exact callable value forwarded through an *ordinary, untyped
function parameter* (not a capture) ever get devirtualized when it has a
proven singleton target?" -- was tested directly with synthetic fixtures.
The answer is **no, and correctly so** (Outcome C, "genuinely open"):
`hir::specialize::KeyType` reduces any Block-typed argument to the bare
kind `block` (discarding *which* block), by design and unmodified by this
milestone (per its own explicit instruction not to touch `KeyType`); a
shared instance's own parameter therefore never carries an exact
`{block B arity result}` type unless that binding is itself immutable and
directly typed exactly by the semantic type system (a root/local alias,
or a capture) -- never merely because the instance happens to have one
caller today. `apply(foo, 1)` with `apply(f, x): f(x)` remains a
`callvalue` even with a single call site in the whole program, and this is
the *sound*, unsurprising consequence of a documented, deliberately
unchanged design choice -- not a bug this milestone leaves behind.

Net result: **investigation only.** No first loss was found on the real
motivating path; the general open case was confirmed genuinely open and
left alone, exactly as the milestone's own stop conditions anticipate for
a "genuinely open" outcome. One test file was added
(`tests/hir-callable-target.test`, 8 new tests, both backends) pinning
every fact this report relies on, so a future change cannot silently
regress or silently "fix" this by accident without a test noticing. `git
diff --stat` against the pre-M2 tree:

```
tests/hir-callable-target.test | 190 ++++++++++++++++++++++++++++++++++++++
```

Nothing else changed: no `.tcl`, `.rs`, `.bot`, or `.ir` production file
has any diff.

## Pre-change `esc_char -> web::is_unreserved` trace

Gathered directly from the real, frozen `bench/uri-steady.bot`, via
`audit/comprehensive-generated-code/tools/probe.tcl` (unmodified tooling)
and `objdump`, on the tree this milestone started from (no code changed
since, so this is also the "after" trace):

| layer | representation |
|---|---|
| source | `lib/web.bot:88`, `is_unreserved(b)` inside `esc_char`, itself nested inside `uri_escape_text` |
| resolved HIR | `esc_char`'s body captures `web::is_unreserved` (a qualified reference to a module-scope closure) through the ordinary lexical capture path (`hir::resolve::Capture`, M0's own fix) -- not a call-argument/untyped-parameter position |
| callee binding | a `root`-kind binding at `web`'s module section, whose value is `is_unreserved`'s own Block core value |
| semantic HIR type of the callee ref | `{block B 1 bool}` (exact: `hir::types::BindingType`'s `root` case returns `core::type::ofValue` of a Block value directly -- always exact, independent of instance) |
| call expression type (`hir::types::Call`) | `target = {block B}` (the 4-tuple branch, `hir/types.tcl:983`) |
| specialized-instance view | `esc_char<generic>`'s own call graph edge, `hir::specialize::instance`'s `calls` map: `e272 -> i8 web::is_unreserved<generic>` (`spec.txt`) -- exact at the specializer level too |
| binding type of the callable value at the NIR-parameter boundary | `web::is_unreserved` is envless-static (`hir::aot::context`'s `StaticBlocks`), so its closure value is threaded down through `uri_escape_text -> esc_char` as an ordinary explicit NIR parameter (`pnames="c web::is_unreserved web::hex_digits"`) rather than a runtime environment slot -- this is what M1's report misread as "call-through-value" |
| blockescape/callable analysis | not a virtualization candidate here (`is_unreserved` is itself a closure with a real capture, `additional_unreserved_chars`; `hir::blockescape` targets locally-bound, non-escaping closures, a different case, see "Environment-bearing closure fixture" below) |
| NIR lowering input (`native::lower::Call`) | `targetKind eq "block"`, `target` in `envless`? No (`is_unreserved` has `env=1`, it captures `additional_unreserved_chars`) -> emits `callenv`, never falls to the `callvalue` tail |
| NIR call form | `%13 = callenv 9 %1 %12 @e272` -- direct call to fixed function id 9, closure register `%1` (esc_char's own forwarded `web::is_unreserved` parameter, used purely as the environment value, not as a dispatch target) |
| NIR `may_error` (`nir.rs::summarize_call_effects`) | `true` -- but purely because `effects[9]` (function 9's own fixed-point effect) is `true`, driven by `is_unreserved`'s own local `op setcontains` (`op_may_error(SetContains) == true`), **not** by anything about how the call is dispatched |
| Cranelift/native call form (objdump) | `call botlish_fn_9` (a direct, statically-linked `call rel32`/PLT32 relocation) followed by `test rax,rax` / `je` (the may_error retest) then `cmp rax,0x6` / `je` (the tagged-Bool discrimination) |
| caller-side result/error checks | one `test rax,rax; je <error-path>` (from `may_error=true`) plus the ordinary tagged-Bool `cmp rax,0x6` -- both already present before this milestone and unaffected by it |

## Exact first-loss location

**There is none on this path.** Every layer above already carries the
exact target, from source resolution through to the emitted x86-64 `call`
instruction. The chain that would need repairing under an M1-style
"declared fact lost during re-inference" story simply does not lose
anything here: `hir::types::BindingType`'s `root` case for a module-level
function is exact by construction and does not depend on `hir::specialize`
re-inferring anything (unlike M1's declared-*parameter*-type case, which
specifically was lost during `hir::specialize::Analyze`'s per-instance
region re-inference). The one place callable exactness *can* be lost in
this codebase -- `hir::specialize::KeyType`'s reduction to bare kind for a
Block-typed call/return argument -- is never reached on this path, because
`is_unreserved` never travels as an ordinary call argument; it travels
only through captures and their forwarding as explicit parameters of
*envless* nested functions, a mechanism `native::lower::Call`'s callee-
evaluation step (`ModuleBridgeBinding`/`Access`, lines ~3150-3178) already
threads through to an exact NIR register without ever generalizing the
call's own `target` field.

## Why singleton-target knowledge is available here

Because `is_unreserved` is referenced only in ways `TYPED-CALLABLE-ESCAPE-
SOUNDNESS.md`'s own audit (reused unchanged from M1) already proves
preserve exact callable identity: a qualified module reference resolved to
its own `root` binding, then propagated through nothing but captures of
immutable bindings (`hir::callables.tcl`'s own header: "an immutable local
binding's type is exactly its value's type"). It never passes through an
*ordinary call-argument* position bound to an untyped parameter -- the one
position that would force it through `hir::specialize::KeyType`'s kind-only
reduction and lose its exact identity. `hir::callables::verify` (unchanged)
independently guarantees this can never happen for a *typed* callable like
`is_unreserved` (which declares `b: Byte`): `apply(is_unreserved, x)`-style
erasure into an untyped higher-order parameter is a compile-time rejection,
confirmed unchanged by `typed-callable-escape.test` (35/35).

## Soundness argument

Unchanged from M1's own audit, reused directly: no new call-lowering rule
was added, so no new soundness obligation exists. The pre-existing
invariant this milestone leaned on for its "no code change" conclusion is:

> `native::lower::Call` already emits a direct `call`/`callenv` for *every*
> HIR call node whose semantic `target` is `{block B}`, and `callvalue`
> for every other node -- this is a total, exhaustive dichotomy on the
> `target` field alone (`hir/types.tcl:983`'s own 4-tuple test), with no
> intermediate "maybe" state and no separate lowering-side proof
> obligation.

Since `hir::types::Call`'s own exact-target resolution is the single
source of truth for `target`, and it is driven by ordinary, unmodified
type inference (`BindingType`/`ForwardType`/`KeyType`), any call this
milestone found already direct is direct *because* the type system proved
`{block B}`, and any call this milestone found indirect is indirect
*because* the type system could prove no more than a bare `block` kind.
No new proof mechanism, and therefore no new soundness burden, was
introduced. The multi-target negative fixture (below) is the concrete
regression test for the one class of error this would matter for --
sharing one instance's own callable-typed parameter across two different
concrete callables -- and it confirms lowering still treats that shared
parameter as opaque.

## Implementation change

None in production code. One new test file,
`tests/hir-callable-target.test` (8 tests), documenting the findings below
as regression pins. See "Outcome" for the full `git diff --stat`.

## Fixtures

All fixtures were run through `native::lower::program` (via
`audit/comprehensive-generated-code/tools/probe.tcl` during investigation,
and via `tests/hir-callable-target.test`'s own `nirOf` helper as
committed regression tests), with `-tiny-leaf-inline-opt 0` where needed
so `TINY-EXACT-LEAF-INLINING.md`'s own, unrelated, pre-existing
optimization does not remove the call instruction being inspected
entirely.

### Positive fixture: exact forwarded callable through an ordinary parameter

```botlish
fn foo(x):
    x + 1

fn apply(f, x):
    f(x)

apply(foo, 1)
```

Result: **`callvalue`** (indirect), even with exactly one call site in the
whole program. `apply<block, int>`'s own key for `f` is the bare kind
`block` (`hir::specialize::KeyType` drops which block); `f`'s per-instance
view type inside `apply`'s body is therefore not the 4-tuple exact form,
so `hir::types::Call` cannot set `target = {block B}`, and lowering
correctly falls through to `callvalue`. This is spec item 29's own
anticipated "singleton not proven -> remain indirect" branch -- the
compiler has no structural proof to consume, so none is invented.
(A *typed* callable, e.g. `fn foo(x: Byte)`, cannot even be legally passed
this way at all: `hir::callables::verify` rejects it before this point is
ever reached, per `typed-callable-escape.test`'s own
`callable-escape-apply-bad-arg-rejected`.)

### Negative fixture: two callable targets sharing one instance

```botlish
fn foo(x):
    x + 1

fn bar(x):
    x + 2

fn apply(f, x):
    f(x)

apply(foo, 1)
apply(bar, 2)
```

Result: **one shared instance** (`apply<block, int>`, confirmed directly
via `hir::specialize::analyze`'s own `used` list -- both calls resolve to
the identical instance id, not two separately-specialized ones), and its
call `f(x)` remains **`callvalue`**. This is the same code path as the
positive fixture above -- confirming the positive fixture's own
"indirect" result is not an accident of instance-splitting, and pinning
the milestone's principal anti-unsoundness property: two different
concrete targets reaching one instance's own callable-typed parameter
can never be treated as a single known target, structurally, regardless
of how many distinct callers exist.

### Alias fixture

```botlish
fn foo(x):
    x + 1

f = foo

f(7)
```

Result: **direct `call`**, no `callvalue`. `f`'s top-level binding is
immutable and typed exactly as `foo`'s own Block value
(`hir::types::Bind`/`BindingType`'s `root` case), so `f(7)`'s callee type
is the 4-tuple exact form and lowers exactly like calling `foo(7)` by
name would.

### Captured exact callable fixture (the `esc_char` shape, in miniature)

```botlish
fn foo(x):
    x + 1

fn outer():
    f = foo
    fn inner(y):
        f(y)
    inner(1)

outer()
```

Result: **direct `call`**, no `callvalue`. `inner` is envless, so its
capture of the immutable alias `f` is threaded down as an ordinary
explicit NIR parameter -- exactly `esc_char`'s own relationship to
`web::is_unreserved` -- and the callee type stays exact through that
transport, exactly as the real path's own trace showed. No blockescape
policy change was needed or made to get this result; it was already true.

### Environment-bearing closure fixture

```botlish
fn make_pred(limit):
    fn pred(x):
        x < limit
    pred

f = make_pred(10)

f(5)
```

Result: **direct `callenv`**, carrying `make_pred`'s own returned closure
object as the environment register (`%5 = callenv 3 %2 %3`, where `%2` is
`make_pred`'s own result). This is exactly the milestone's own target
shape (spec item 12): known code target (`pred`'s own instance), dynamic
environment (the closure `make_pred(10)` allocated), never discarded or
constant-folded. Effects: `program -> pred` is stamped `may_error=false,
may_gc=false` by the existing, unmodified `nir.rs::summarize_call_effects`
once `pred<int>`'s own body specializes its comparison to a guard-free raw
op -- no new effect-analysis code, exactly the M1-style natural cascade.

### Erroring-callee control

```botlish
fn foo(x):
    mod(x, 0)

f = foo

f(5)
```

Result: **direct `call`**, and `program -> foo` stays `may_error=true`
(`op imod` is unconditionally `may_error`). Confirms devirtualization
(a direct call) is never conflated with non-erroring: an exact target that
can genuinely fail keeps its caller-side retest.

### Cross-module

The real `esc_char -> web::is_unreserved` trace above already exercises a
qualified module-scope callable forwarded as a value and invoked through a
local/parameter binding, satisfying this without a separate synthetic
fixture (as spec item 64 itself allows).

### Same-target / different-target joins

Not re-tested with new fixtures: `typed-callable-escape.test`'s own
existing `choose`/`chooser`/`pick` family (lines ~149-300, unmodified,
35/35 passing) already exercises exact-callable joins under both
same-target and different-target branches at the `hir::callables::verify`
layer, and M1's own report's "ASCII composition" controls
(`is_alphabetic -> is_upper`/`is_lower`, etc.) already exercise same-target
exact-call stability under this milestone's own re-measurement (see
"uri-steady structural before/after" below: byte-for-byte unchanged).

## Effect-analysis consequences

None, by construction: no call's `target` field changed (nothing was
newly proved exact, nothing newly erased), so `nir.rs::summarize_call_effects`
-- entirely unmodified -- produces byte-for-byte the same `may_error`/
`may_gc` stamps on every call in every measured workload as it did before
this milestone. The one interesting edge (`esc_char -> web::is_unreserved`,
`may_error=true`) is explained above and is unrelated to target identity.

## URI call-site table

| caller -> call expression | target before | target after | call form before | call form after | may_error before | may_error after |
|---|---|---|---|---|---|---|
| `ascii::is_alphabetic -> is_upper` | `{block}` exact | unchanged | direct `call` | unchanged | false (M1) | false |
| `ascii::is_alphabetic -> is_lower` | `{block}` exact | unchanged | direct `call` | unchanged | false (M1) | false |
| `ascii::is_alphanumeric -> is_alphabetic` | `{block}` exact | unchanged | direct `call` | unchanged | false (M1) | false |
| `ascii::is_alphanumeric -> is_digit` | `{block}` exact | unchanged | direct `call` | unchanged | false (M1) | false |
| `web::is_unreserved -> ascii::is_alphanumeric` | `{block}` exact | unchanged | direct `call` | unchanged | false (M1) | false |
| `esc_char -> web::is_unreserved` (M2's own subject) | `{block}` exact | unchanged | direct `callenv` | unchanged | true | true (unrelated `SetContains` residue, see above) |

Every row is unchanged before/after M2, because M2 changed no production
code. The table's own point is that the row M2 was chartered to
investigate was already in the same state as M1's own controls -- direct,
exact -- contrary to M1's own report's guess about it.

## `uri-steady` structural before/after

Identical in every column, because no production code changed. Re-measured
directly (not assumed) via `audit/comprehensive-generated-code/tools/probe.tcl`
and `bench/uri-steady.tcl`, both matching M1's own recorded post-M1
figures exactly:

| metric | M1 baseline | M2 (re-measured) |
|---|---:|---:|
| NIR functions | 17 | 17 |
| machine code bytes | 7155 | 7155 |
| generic instances | 9 | 9 |
| int/raw instances | 6 | 6 |
| other instances | 2 | 2 |
| `guard int` ops | 7 | 7 |
| call/callenv ops | 17 | 17 |
| indirect (`callvalue`) ops in this workload | 0 | 0 |
| tagged i-arith ops | 6 | 6 |
| exact calls with may_error check | 11 | 11 |
| allocations / bytes | 61510 / 2544568 | 61510 / 2544568 |

`uri-steady.bot` has **zero** `callvalue` instructions in its entire NIR
before or after this milestone -- every call in this program's own call
graph already resolves to an exact target (the whole ASCII/URI chain is
either direct-by-name or direct-by-capture, never an ordinary untyped-
higher-order-parameter forwarding). This is itself informative: the
program this milestone's own motivating example lives in was never
actually exercising the "genuinely open" class of call at all.

## Isolated callable-forwarding structural before/after

Covered by the fixtures above rather than a separate frozen benchmark
file: `apply(foo, 1)`/`apply(foo,1); apply(bar,2)` (`callvalue`, the
"genuinely-open control") versus the alias/capture/env-bearing fixtures
(direct `call`/`callenv`, the "converges toward direct-call baseline"
positive controls) and the direct-call baseline itself (`foo(7)` by name,
identical NIR to the alias fixture's own callee instance). No new frozen
`.bot`/`.ir` benchmark file was added to `bench/`; the fixtures live
inline in `tests/hir-callable-target.test` since their purpose is
structural regression pinning, not timing measurement (none of them do
enough work in a loop to be a meaningful microbenchmark on their own, and
manufacturing one would not change any conclusion above).

## Machine-code excerpt before/after

Identical before/after (no production code changed). The relevant excerpt,
`esc_char<generic>`'s own call to `web::is_unreserved`:

```
call   botlish_fn_9        ; direct call, PLT32 relocation to a fixed symbol
test   rax,rax             ; may_error retest (SetContains residue, not target-related)
je     <error path>
cmp    rax,0x6             ; tagged Bool discrimination (unrelated ABI residue)
je     <false path>
```

No `call <register>`/indirect-call form appears anywhere in this
function's disassembly.

## Timing

Same methodology as M0/M1 (`bench/uri-steady.tcl`, 2000-call fixed corpus,
best-of-7, 5 independent sessions, JIT compile excluded), re-run on this
milestone's own host session (no production code changed, so this is a
noise/host-variance data point, not a before/after comparison):

| | this session |
|---:|---:|
| median | 5123.96 us |
| min | 4913.08 us |
| max | 7464.03 us |
| spread | 34.2% |

Correctness unchanged: all four backends agree on `29500` for the fixed
corpus. The spread here (34.2%) is noticeably noisier than M1's own
recorded session (8.5%) -- consistent with ordinary shared-host variance
(M0's own baseline session recorded ~17%), not with any code change, since
none occurred. Per spec item 49, a flat/noisy timing result alongside a
byte-for-byte-unchanged structural baseline is the expected, valid outcome
for a milestone that made no code change.

## Allocation / root / safepoint consequences

None: allocation count and bytes are unchanged in every measured workload
(`uri-steady`: 61510 / 2544568, identical). No call's lowering form
changed, so no root/safepoint metadata plumbing changed either. GC stress
(`BOTLISH_NATIVE_GC_STRESS=1`) was re-run over the full suite, including
the new environment-bearing-closure fixture, with no failures (see "Full
regression" below).

## Full regression

- `tclsh9.0 tests/all.tcl` (interp + compile): **2125/2125 passed, 0
  failed**, both backends (2117 pre-existing + 8 new
  `hir-callable-target.test` tests).
- `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passed**, unchanged (no Rust source touched; `cargo build --release`
  needed a full rebuild only because this session's sandbox had no
  prebuilt `target/` yet, not because any source changed).
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **2125/2125 passed,
  0 failed**, both backends.
- `typed-callable-escape.test`: **35/35 passed**, both backends, unchanged
  expected results.
- `typed-parameters.test`: **50/50 passed**, both backends, unchanged.
- `hir-closed-call-params.test`: **15/15 passed**, both backends,
  unchanged.
- `hir-specialize.test`: **27/27 passed**, both backends, unchanged
  (M1's own six `hir-specialize-m1-*` tests included).
- `tests/hir-callable-target.test` (new): **8/8 passed**, both backends.
- Frozen benchmark regression (`steady-ascii`, `steady-ascii-param`,
  `steady-ascii-capture`, `ascii-256`, `web-unreserved-256`, `uri-steady`),
  re-probed directly: machine code bytes 8647 / 8782 / 8782 / 7951 / 15485
  / 7155 respectively -- all byte-for-byte identical to the post-M1
  figures recorded in `M1-DECLARED-PARAMETER-FACT-TRANSPORT.md`.
  `refined-checks.ir` was also re-probed directly: 16843 bytes, identical
  to M1's own post-M1 figure. `fib`/`loop-count`/`sum-refined` were not
  re-probed individually beyond the full test suite's own coverage of
  them, since no production code changed that could plausibly move them
  and neither M1 nor M2 touches anything in their own call graphs.

## Source-fence confirmation

`git status --porcelain` / `git diff --stat` against the pre-M2 tree shows
exactly one new, untracked file: `tests/hir-callable-target.test`. No
`.bot`, `.ir`, `.hir`, `.tcl` (production), or `.rs` file has any diff.
The FINAL SEMANTIC SOURCE FENCE remains intact -- trivially, since nothing
was changed at all this milestone.

## Residual first-loss matrix

| fact | before M2 | after M2 |
|---|---|---|
| `esc_char -> web::is_unreserved` target exactness | exact (already) | exact (unchanged) |
| `esc_char -> web::is_unreserved` call form | direct `callenv` (already) | direct `callenv` (unchanged) |
| `esc_char -> web::is_unreserved` `may_error` | true, driven by `is_unreserved`'s internal `SetContains` opcode | true, unchanged -- **this is the actual next first loss**, and it is an effect-analysis/opcode-classification question, not a callable-target one |
| callable value forwarded through an ordinary untyped call-argument/parameter with a single legal caller | genuinely open (`callvalue`); no structural proof exists | unchanged -- correctly left alone, per this milestone's own hard scope (`KeyType` untouched) |
| callable value forwarded through a capture (into an envless nested function's own explicit parameter) | exact, direct | unchanged |
| callable value bound to an immutable alias | exact, direct | unchanged |
| closure with a real capture, invoked through an alias/return value | exact code target, direct `callenv` with correct environment | unchanged |

## RC3 reassessment

RC3 (the broad audit's "tiny-call/helper-boundary overhead" bucket) can now
be split, for this specific call, into its actual observed components
rather than "call overhead" as one thing:

- **dispatch**: zero cost -- already a direct `call rel32`, not indirect.
- **closure environment**: one register load (`%1`, the forwarded
  parameter used as `callenv`'s closure operand) -- present, unavoidable
  (the callee genuinely captures a module value), not itself improvable
  without changing module-value/capture representation (out of scope).
- **frame setup**: ordinary function-call frame, unrelated to this
  milestone.
- **parameter unbox**: `is_unreserved`'s own body already unboxes/raw-
  operates its Byte parameter post-M1; nothing left here.
- **tagged Bool result**: still present (`cmp rax,0x6`), recorded, not
  addressed (out of scope: "No Bool optimization").
- **completion/error discrimination**: still present (`test rax,rax; je`),
  and now precisely attributed to `SetContains`'s blanket `may_error`
  classification rather than to dispatch -- **this is what remains of RC3
  on this specific edge**, and it is a `may_error`/opcode-classification
  question (a possible future milestone: proving `SetContains`/
  `SetFromList` cannot raise `EQUALITY` when every element's static type
  has structural equality, e.g. every `Int`/`Byte`-domain type), not a
  call-dispatch one.

## family-1b reassessment

Unaffected by this milestone's own finding: family 1b (letting exact calls
of closures specialize when `hir::blockescape` proves non-materialization,
or when every capture is a retained immutable module value) remains a
distinct, larger-risk candidate, per M1's own assessment. Nothing in M2's
investigation changes its priority -- M2 found no closure-specialization-
related loss on the real path at all (the real path's own call was already
optimal), so 1b's own `refined-checks` motivation (`StringRegion` scanner
index guards, unrelated to callable-target identity) stands exactly as M1
left it.

## Recommended next milestone

The clearest, most concrete, and now precisely attributed remaining first
loss is: **`SetContains`'s (and `SetFromList`'s) blanket `may_error`
classification does not distinguish "the element kind lacks structural
equality" (a real, unavoidable failure mode) from "the element kind is
provably `Int`/`Byte`/any other kind with total structural equality" (a
statically decidable non-failure)**. Proving the latter case impossible
for `web::is_unreserved`'s own `additional_unreserved_chars` set (built
once from `byte::set([...])`, always `Byte` elements) would let existing
effect analysis (unmodified, exactly the M1/M2 pattern) recompute
`is_unreserved`'s own `may_error` as `false`, which would then naturally
remove `esc_char`'s own caller-side retest with no further code change --
the same "repair one information-preservation boundary, let existing
machinery do the rest" shape as M1 and (the investigation-only conclusion
of) M2. This is explicitly **not** implemented here (M2's own hard scope:
"do not change may_error analysis," "do not change ImmutableSet
representation") and is left as the concrete, evidenced recommendation for
the next milestone.

A second, independent candidate, unchanged from M1's own recommendation:
family 1b (`refined-checks`'s `StringRegion` scanner-index guards).

## Required architecture questions

1. **At `esc_char`'s invocation expression, is the exact target
   `web::is_unreserved` known before M2?** Yes.
2. **If yes, in which compiler representation is it last present before
   being lost?** It is never lost -- it survives to the emitted x86-64
   `call` instruction. `hir::types::Call`'s `target` field is `{block B}`
   from the first whole-program semantic pass onward, unmodified through
   specialization and native lowering.
3. **If no, why not?** N/A.
4. **Is the relevant target singleton because of semantic type
   information, instance-specific information, or merely observed caller
   behavior?** Semantic type information (`hir::types::BindingType`'s
   `root` case for a module-level function value, propagated through
   captures `hir::callables.tcl` already proves preserve exact identity).
   Not caller-behavior-based, not profile-based.
5. **Did M2 add callable identity to specialization keys?** No.
   `hir::specialize::KeyType` has no diff (confirmed: `git diff` touches
   no `.tcl` file at all).
6. **Did M2 alter closure specialization?** No.
7. **Did M2 alter callable escape legality?** No --
   `typed-callable-escape.test` unchanged, 35/35.
8. **Did M2 add speculative/runtime-guarded devirtualization?** No.
9. **Can a call with two possible block targets still be devirtualized?**
   No -- confirmed by the negative fixture (`apply(foo,1); apply(bar,2)`,
   one shared instance, `callvalue` retained).
10. **Can two functions with identical signatures be treated as the same
    target?** No -- not tested by identity confusion (the negative fixture
    already uses identical signatures for `foo`/`bar`), and no such
    mechanism exists or was added.

## Required lowering questions

11. **Which NIR operation represented the call before M2?** `callenv 9 %1
    %12` (already direct).
12. **Which operation represents it after M2?** Unchanged: `callenv 9 %1
    %12`.
13. **Is the post-M2 operation an already-existing direct call/callenv
    form?** Yes -- it always was.
14. **If the callee has an environment, how is that environment
    preserved?** Passed as `callenv`'s own closure operand (`%1`,
    `is_unreserved`'s forwarded closure value) -- unchanged, and
    demonstrated generally by the environment-bearing-closure fixture.
15. **Did argument evaluation order change?** No -- no lowering code
    changed.
16. **Did closure allocation change?** No -- allocation counts/bytes
    unchanged in every measured workload.
17. **Did stack/root metadata change?** No.

## Required effect questions

18. **What was `may_error` on the target edge before M2?** `true`.
19. **What is it after M2?** `true`, unchanged.
20. **If it changed, did that happen through existing effect analysis?**
    N/A -- it did not change.
21. **Which caller-side result/error checks disappeared naturally?** None
    on this edge (see above: the retest is unrelated to callable-target
    provenance). Every other URI-chain edge's `may_error=false` status
    (M1's own five collapses) remains unchanged.
22. **Does an exact but genuinely erroring callee retain
    `may_error=true`?** Yes -- confirmed directly by the erroring-callee
    fixture.

## Required benchmark questions

23. **`uri-steady` machine-code bytes before/after?** 7155 / 7155
    (unchanged).
24. **indirect callable calls before/after?** 0 / 0 (this workload has
    none, before or after).
25. **direct call/callenv counts before/after?** 17 / 17.
26. **caller-side error/completion retests before/after?** 11 / 11 (exact
    calls with a may_error check, `effects.txt`'s own count).
27. **guard count before/after?** 7 / 7 -- no regression from M1's own
    figure.
28. **allocations/count bytes before/after?** 61510 / 2544568, unchanged.
29. **Cranelift timing median/min/max/spread before/after?** No
    before/after comparison applies (no code changed); this session's own
    re-measurement: median 5123.96us, min 4913.08us, max 7464.03us,
    spread 34.2% (host-noise, see "Timing" above).
30. **Does the isolated singleton-forwarding probe structurally converge
    toward the direct-call control?** Yes for the capture/alias/
    environment-bearing shapes (all direct `call`/`callenv`, structurally
    identical in call form to calling the target function by name). No
    for the ordinary-untyped-parameter shape (stays `callvalue`,
    correctly, since no proof exists).
31. **Does the genuinely-open control remain indirect?** Yes -- confirmed
    for both the one-caller and two-caller (shared-instance) forms.

## Required scope questions

32. **Was the call ABI changed?** No.
33. **Was Bool representation changed?** No.
34. **Was raw parameter passing introduced?** No.
35. **Was `effectiveErrors` newly consumed?** No -- confirmed directly:
    `e272`'s own `completion.txt` entry shows `declaredErrors={}
    effectiveErrors={}`, and the `may_error=true` residue comes entirely
    from `nir.rs`'s independent, unmodified opcode-based analysis, not
    from `effectiveErrors`.
36. **Was inlining changed?** No.
37. **Was module-value representation changed?** No.
38. **Was listloop changed?** No.
39. **Was any frozen `.bot`/`.ir` workload changed?** No -- confirmed by
    `git status`/`git diff --stat`.

## Stop condition reached

This milestone reached the **genuinely open / already-satisfied** stop
condition (spec section 90), adapted to the actual finding: the real
path's own precise point was not "prevented from proving singleton" but
"already proven singleton, already lowered directly, before this milestone
began" -- a stronger and more specific result than the section's own
anticipated "no singleton target" framing, established by direct
inspection rather than assumption. The synthetic single-caller positive
case (`apply(foo, 1)`) demonstrates existing lowering's own dichotomy
directly: it does *not* consume exact callable identity when none is
proven, and does when it is (the alias/capture/environment-bearing
fixtures). The multi-target negative case confirms the shared-instance
call cannot legally be treated as direct. No speculative devirtualization,
closure-specialization change, or key-policy change was added. Full
regressions pass (2125/2125, both backends, plain and GC-stress; 60/60
Rust). The report above recommends the smallest next information-
preservation milestone the evidence actually points at: `SetContains`'s
own blanket `may_error` classification, not a raw ABI or calling-
convention change.
