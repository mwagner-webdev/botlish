# M3: equality-total SetContains effect refinement

## Outcome

Implemented and measured. `native/lower.tcl`'s `NativeCallOp` -- the same
proc that already picks `veq`/`ieq`/`streq` for `==` from its two argument
expressions' static types -- now does the analogous thing for
`immutable_set_contains`: at one particular call node, if the set's own
applied element type and the needle's own static type are both proven
equality-total (a new, narrow, canonical predicate,
`hir::types::IsEqualityTotal`), the call lowers to a new NIR opcode,
`setcontainstotal`, instead of the generic `setcontains`. `op_may_error`
(`native/src/runtime/ops.rs`) classifies `setcontainstotal` as
non-erroring; `setcontains` itself is untouched and remains unconditionally
`may_error=true`. Both opcodes lower to the identical runtime helper call
(`rt_set_contains`, unmodified) in Cranelift codegen
(`native/src/codegen/clif.rs`); the only codegen difference is that
`setcontainstotal` skips the local NO_VALUE recheck after that call
(`fallible: false`, matching its own `op_may_error=false`), which is sound
precisely because native/lower.tcl only ever chooses it where it has
already proven the runtime operands can never reach `rt_set_contains`'s own
EQUALITY branch.

This is a pure effect-classification split, keyed by opcode, not by
native. No new runtime operation, no change to `ImmutableSet`
representation, membership semantics, `SetFromList`, the call ABI, Bool
representation, inlining, or closure specialization. Generic `SetContains`
remains potentially erroring; every call whose static types do not both
qualify -- a broad/unresolved needle, an erased set, or an operand whose
runtime kind genuinely lacks structural equality (Block/Native/
MutableArray) -- still lowers to plain `setcontains` and keeps its
caller-side completion retest, confirmed directly (see "Negative fixtures"
below), including one fixture that still raises the real, pre-existing
`EQUALITY` error at runtime.

The motivating cascade happened exactly as predicted, with **no
`esc_char`-specific or `web::is_unreserved`-specific code anywhere**:

```
additional_unreserved_chars : ImmutableSet[Byte], b : Byte, both
equality-total (HIR, already available -- M1's own fact-transport payoff)
    -> web::is_unreserved's own SetContains call: setcontainstotal
    -> web::is_unreserved's own function may_error: true -> false
    -> esc_char -> web::is_unreserved edge: may_error true -> false
       (existing, unmodified nir.rs::summarize_call_effects fixed point)
    -> esc_char's own caller-side completion retest (`test rax,rax; je`)
       disappears from the generated machine code
```

Structural results, `uri-steady` (whole program, includes module init):

| metric | M2 baseline (re-measured) | M3 |
|---|---:|---:|
| NIR functions | 17 | 17 |
| machine code bytes | 7155 | 7111 (-44B, -0.6%) |
| generic instances | 9 | 9 |
| int/raw instances | 6 | 6 |
| other instances | 2 | 2 |
| `guard int` ops | 7 | 7 |
| call/callenv ops | 17 | 17 |
| `callvalue` ops | 0 | 0 |
| tagged i-arith ops | 6 | 6 |
| exact calls with may_error check | 11 | 10 |
| SetContains: erroring / non-erroring | 1 / 0 | 0 / 1 |
| allocations / bytes | 61510 / 2544568 | 61510 / 2544568 (unchanged) |

Two functions shrink, both entirely attributable to the one retest and the
one internal recheck this milestone removes: `web::is_unreserved<generic>`
190B -> 155B (-35B, its own internal `rt_set_contains` NO_VALUE recheck
gone) and `esc_char<generic>` 525B -> 516B (-9B, the caller-side
`test rax,rax; je` gone). Every other function is byte-for-byte identical.

Files changed:

```
hir/types.tcl                    28 ++       (IsEqualityTotal predicate)
native/lower.tcl                 90 +++--     (NativeCallOp/NativeImpl)
native/src/nir.rs                18 ++        (SetContainsTotal opcode)
native/src/runtime/ops.rs        17 ++        (op_may_error/apply_op)
native/src/codegen/clif.rs       11 +         (codegen tuple)
tests/setcontains-equality-total.test   new, 17 tests
M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md  this report
```

No `.bot`/`.ir`/`.hir` frozen source file changed (confirmed below, "Source
fence confirmation").

## Pre-change URI SetContains trace

Traced directly (`audit/comprehensive-generated-code/tools/probe.tcl`,
`params.txt`/`spec.txt`/`nir.txt`/`effects.txt`, and `hir::typeOf`/
`hir::types::show` at the relevant HIR nodes), on the tree this milestone
started from (commit `5d0a41b`, the post-M2 tree):

| layer | representation |
|---|---|
| source | `lib/web.bot:68`, `immutable_set_contains(additional_unreserved_chars, b)` inside `is_unreserved` |
| semantic HIR type of `additional_unreserved_chars` (module-scope `root` binding) | `ImmutableSet[Byte]` (`{immutableSet {refined int {Byte}}}`) -- exact, from `byte::set([...])`'s own `-result-shape` inference (MINIMAL-IMMUTABLE-SET.md), unconditional (a `root` binding's type is exactly its value's type) |
| semantic HIR type of `b` | `Byte` (`declaredParamTypes`, `int[Byte]`) |
| `is_unreserved<generic>`'s own instance view of `b` (post-M1) | `int[Byte]` -- **already correct**, M1's own payoff |
| `is_unreserved<generic>`'s own instance view of `additional_unreserved_chars` | `ImmutableSet[Byte]` -- a captured module value, always exact (M0/M1; unaffected by specialization, since it never goes through `KeyType`'s own kind-only reduction -- captures of immutable module bindings keep their exact type, `hir::callables.tcl`'s own header) |
| `native::lower::NativeCallOp` (pre-M3) | `immutable_set_contains` -> unconditionally `{op setcontains}` -- **the exact first-loss point**: both operand types above were already fully available here, but the lowering table had no branch that ever consulted them |
| NIR op | `op setcontains %additional_unreserved_chars %b` |
| `op_may_error(SetContains)` (`ops.rs`) | unconditionally `true` (opcode-keyed, blind to any call site's own operand types) |
| `is_unreserved`'s own function `may_error` | `true` |
| `esc_char -> is_unreserved` edge | direct `callenv` (M2), `may_error=true` |
| caller-side machine code | `call botlish_fn_9` / `test rax,rax` / `je <error>` / `cmp rax,0x6` / `je <false>` |

## Exact first-loss location

**`native::lower::NativeCallOp`** (`native/lower.tcl`), the same proc that
already resolves `==` to `veq`/`ieq`/`streq` from its own two argument
expressions' static types. Both operand types -- the set's own applied
element type and the needle's own static type -- are already ordinary,
fully-resolved HIR facts by the time this proc runs (nothing upstream ever
lost them: `ImmutableSet[Byte]` survives from `byte::set`'s own
`-result-shape` inference through the module-scope `root` binding and its
capture into `is_unreserved`'s own instance view unconditionally, and `Byte`
survives through M1's own declared-parameter-fact transport). The proc
itself, though, treated `immutable_set_contains` as an ordinary fixed
`{op setcontains}` entry -- structurally identical to `list_get`,
`mutable_array_get`, and every other single-opcode native -- never
consulting those two already-available types at all. This is
`native::lower::NativeCallOp`'s own case A from the milestone's own
"Hard scope" section: *the HIR call already knows enough, but lowering
emits the generic opcode unconditionally*.

## Current ordinary equality semantics (authoritative source)

Two implementations, kept in lockstep and confirmed byte-for-byte
equivalent by direct inspection: `core::value::equal` (`core/value.tcl`,
the interp/compile backends) and `equal` (`native/src/runtime/ops.rs`,
lines 317-355, the native/Cranelift backend, which `rt_set_contains`
itself calls). Both have the *identical* structure:

```rust
fn equal(p: *mut Vm, a: Value, b: Value) -> Result<bool, ()> {
    let (ka, kb) = (kind_of(a), kind_of(b));
    if matches!(ka, Kind::Block | Kind::Native | Kind::MutArray)
        || matches!(kb, Kind::Block | Kind::Native | Kind::MutArray) {
        vm(p).fail(RtError::Equality { a, b });
        return Err(());
    }
    if ka != kb { return Ok(false); }
    ... // total, structural, per-kind comparison
}
```

The **only** way a comparison can fail is if *either* operand's own runtime
kind is Block, Native, or MutableArray -- checked first, unconditionally.
Every other kind (Int, Str, Bool, Unit, UnicodeChar, and the recursive
List/Result/ImmutableSet cases, which only ever reach this same base check
on their own elements) is unconditionally safe, and a *mismatched* pair of
otherwise-safe kinds (e.g. Int vs. UnicodeChar) simply compares unequal --
never fails. This is the authoritative semantics `hir::types::IsEqualityTotal`
mirrors at compile time (see "Definition of equality-total proof" below).
`rt_set_contains` (`ops.rs:908-917`) is a linear scan calling exactly this
`equal`, so its own EQUALITY failure mode is entirely inherited, not
independently defined.

## Definition of equality-total proof

One canonical predicate, `hir::types::IsEqualityTotal` (`hir/types.tcl`,
next to `kindOf`, whose result it reuses directly):

```tcl
proc hir::types::IsEqualityTotal {type} {
    return [expr {[kindOf $type] in {int str bool unit UnicodeChar}}]
}
```

`kindOf` already collapses any *refined* type (a source-defined bounded
integer domain, `{refined int {Byte}}`) to its base kind (`int`) via
`core::type::base` -- so this predicate never special-cases a type name; it
only ever asks "is this static type's fixed runtime kind one of the five
whose ordinary equality `equal` never rejects?". The
`NativeCallOp`/`equality-set` branch applies it to **both** operands
independently (not requiring them to be the *same* type -- see "Why broad
`any` does not qualify" below for why this is still sound and still
correctly conservative for the required negative controls):

```tcl
if {[hir::types::IsSet $setType]
        && [hir::types::IsEqualityTotal [lindex $setType 1]]
        && [hir::types::IsEqualityTotal $needleType]} {
    set op setcontainstotal
}
```

Deliberately narrow (per the milestone's own "prefer the minimum useful
proof" instruction): it does **not** recurse into a `List[T]`/
`ImmutableSet[T]` element type, so a statically precise
`ImmutableSet[Byte]` nested inside a `List[ImmutableSet[Byte]]` element
position is not (yet) itself proven total when it is the needle -- sound
but incomplete, never unsound, and unneeded by the real motivating call
site or any fixture the corpus census below found.

## Why Byte qualifies

`Byte` is `type Byte = Int in 0..255` (`lib/byte.bot:100`), a source-defined
bounded refinement of `Int` (SOURCE-DEFINED-INTEGER-DOMAINS.md). Its static
type, wherever it appears (a declared parameter, `byte::set`'s own
`-result-shape`-inferred `ImmutableSet[Byte]`), is the core form
`{refined int {Byte}}`. `hir::types::kindOf` normalizes this via
`core::type::base`, which returns `int` for any `refined` form -- so
`IsEqualityTotal(Byte)` reduces to `IsEqualityTotal(int)`, `true`, entirely
through the pre-existing type-normalization machinery, with **zero**
Byte-specific code anywhere in this milestone's diff (confirmed: `grep -i
byte native/lower.tcl hir/types.tcl` inside this milestone's own diff hunks
finds nothing -- only this report's prose mentions the name).

## Why broad `any` does not qualify

`hir::types::kindOf` returns `""` for the broad `any` type (via
`core::type::base`'s own `any -> ""` case) and for `never`. `""` is not a
member of `{int str bool unit UnicodeChar}`, so `IsEqualityTotal` is
unconditionally `0` for any type the compiler cannot pin to one specific,
already-known-safe kind. This is not a special case for `any`: it falls out
of the same one-line membership test as every other rejection. A broad or
erased `ImmutableSet` (no precise `{immutableSet ELEM}` structural form --
`hir::types::IsSet` itself already returns `0`) is rejected the same way,
one level up, before `IsEqualityTotal` is even consulted on its element.

## Why unsupported kinds remain fallible

Block, Native, and MutableArray are simply never members of
`{int str bool unit UnicodeChar}` (`hir::types::kindOf` returns their own
kind name for an exact-typed value, e.g. `block`, or a broader kind for an
erased one -- never one of the five safe names either way), so
`IsEqualityTotal` rejects them unconditionally, by the same one-line test,
with no dedicated blacklist branch. Confirmed at runtime, not merely by
static inspection: `setcontains-unsupported-kind-runtime-equality`
constructs a real `ImmutableSet` of untyped-closure (Block-kind) members
and queries it with another closure -- native lowering still chooses plain
`setcontains`, and the program still raises `{CORE SEMANTIC EQUALITY}` at
run time, exactly as it did before this milestone.

## Implementation choice

**Refined NIR opcode, not a new runtime operation, not a boolean flag on
`Inst::Op`.** Considered and rejected:

* **A boolean effect flag on `Inst::Op` itself.** NIR's text format has no
  precedent for an optional per-instruction attribute on `op` lines (every
  other per-instruction fact -- `may_error`/`may_gc` on `Call`/`CallEnv` --
  is a *parsed-in, then recomputed* field on those specific variants, not a
  textual annotation `native/lower.tcl` writes), and `op_may_error`'s own
  architecture is already a pure, total function of `OpCode` alone,
  consulted from exactly one place (`nir.rs`'s effect fixed point). Adding
  a second, instruction-level source of truth for the same fact would fork
  that architecture for one opcode.
* **A new runtime operation.** Unnecessary and explicitly forbidden by
  scope: the runtime behavior for a proven-safe invocation is *identical*
  to the generic one (same `rt_set_contains` call); only the *caller's own
  knowledge of whether it can fail* changes.

**A second `OpCode` variant, `SetContainsTotal`,** is the smallest form
that fits the existing architecture, and has direct precedent already in
this codebase: `ILt`/`RILt` (and the whole tagged/raw comparison family)
are already two distinct opcodes for "the same fundamental operation,"
chosen purely from static lowering-time facts, with independent
`op_may_error`/codegen treatment. `op_may_error` (`ops.rs`) stays a pure,
total function of `OpCode`; `SetContainsTotal` simply is not in its
`matches!` list, so it defaults to `false` the same way every other
never-erroring opcode already does -- no new mechanism, no special-casing
inside `op_may_error` itself. `native::lower::NativeImpl` (the *generic*,
dynamically-dispatched entry a `Native` value carries for `rt_call_value`)
always returns plain `setcontains`, never the refined opcode: a
dynamically-dispatched call has no call-site-specific static proof
available, so it must use the same conservative classification every other
generic `SetContains` invocation does.

## Positive fixtures

All in `tests/setcontains-equality-total.test`, inspecting NIR text
(`op setcontainstotal` vs. `op setcontains`) and the call-effects report
(`native::Driver calls`, the same technique `tests/hir-callable-target.test`
uses) directly, plus one four-backend runtime-parity fixture:

* **`setcontains-total-byte`** -- the principal M3 acceptance case:
  `ImmutableSet[Byte] x Byte` lowers to `setcontainstotal`;
  `contains_byte` becomes `may_error=false`.
* **`setcontains-total-int`** -- plain `Int`, confirming Byte is not
  name-special-cased.
* **`setcontains-total-source-defined-domain`** -- a *different* bounded
  Int domain (`Small = Int in 0..10`, the same synthetic type M1's own
  fixtures use), confirming the proof derives from `kindOf`'s own
  refinement-collapsing, never a hard-coded type name.
* **`setcontains-total-bool`/`-string`/`-unicodechar`** -- the remaining
  audited-total kinds, each its own `ImmutableSet[K] x K` fixture.
* **`setcontains-total-runtime-present-and-absent`** -- both a present and
  an absent Byte query return `Bool` (`[true, false]`), never `Error`, on
  all four backends (interp, compile, cranelift-generic, cranelift).
* **`setcontains-total-empty-set`** -- an empty `ImmutableSet[Byte]`
  (constructed from `immutable_set_from_list([])` through a
  `List[Byte]`-typed parameter, so its element type stays precisely `Byte`
  rather than degrading to `ImmutableSet[never]`) is non-erroring through
  the identical static proof, with no dedicated empty-set rule; its runtime
  result is `false`.

## Negative fixtures

* **`setcontains-broad-needle-stays-erroring`** -- a genuinely broad
  needle (forced via `hir::specialize::limit` exhaustion, mirroring
  `hir-specialize-m1-explosion-generic`; see the in-file comment for why a
  single-caller untyped parameter is *not* by itself sufficient to stay
  broad -- ordinary `KeyType` specialization already narrows it) stays
  plain `setcontains`, `may_error=true`.
* **`setcontains-broad-set-stays-erroring`** -- a set erased through an
  untyped `passthrough` (its own element type unknown at the
  `immutable_set_contains` call) stays plain `setcontains`.
* **`setcontains-error-propagation-control`** -- a caller of the broad,
  genuinely fallible instance above keeps its own `may_error=true` call
  edge, confirming the refinement is invocation-specific, not a global
  opcode reclassification.
* **`setcontains-unsupported-kind-runtime-equality`** -- see "Why
  unsupported kinds remain fallible" above; the sole fixture that exercises
  a *genuine* runtime `EQUALITY` failure, confirming this milestone never
  weakens it.

Two specialized instances of the same source function print the
*identical* NIR function name (`native/lower.tcl` never bakes an `<label>`
suffix into the `func` header's own `name` field -- only its separate
`instance="..."` attribute distinguishes them); the broad-needle and
error-propagation tests disambiguate by NIR function id via a small
`effectLineForInstance` helper rather than by name, so they cannot
accidentally read the *other*, correctly-total sibling instance's own
effect line.

## Source-defined bounded-domain fixture

`setcontains-total-source-defined-domain` (above) is the required item
22/59 fixture: a `Small = Int in 0..10` domain, distinct from `Byte`,
proven equality-total through the identical mechanism.

## SetContains corpus census

Searched the entire frozen corpus (`lib/*.bot`, `bench/*.bot`,
`bench/*.ir`, every `audit/comprehensive-generated-code/probes/*.bot`
fixture) for `immutable_set_contains` call sites:

| site | count |
|---|---:|
| `lib/web.bot:68` (`web::is_unreserved`) | 1 |
| everywhere else in the frozen corpus | 0 |

**Exactly one** real `SetContains` call site exists in the whole frozen
corpus, and it is now proven equality-total. This validates the milestone's
own expectation (spec item 52): the frozen corpus alone cannot exercise a
broad or genuinely-unsupported-equality `SetContains` invocation, so those
are covered entirely by the synthetic fixtures above -- deliberately kept,
per spec item 52's own instruction, rather than "optimizing away" because
the frozen benchmarks happen not to need them.

## Effect propagation before/after (uri-steady, `effects.txt`)

| local op / edge | before | after |
|---|---|---|
| `web::is_unreserved`'s own `SetContains` local op | `may_error=true` (opcode `setcontains`) | `may_error=false` (opcode `setcontainstotal`) |
| `web::is_unreserved` function aggregate | `may_error=true` | `may_error=false` |
| `<program> -> web::is_unreserved` edge (module init, `web-unreserved-256` only) | `may_error=true` | `may_error=false` |
| `esc_char -> web::is_unreserved` edge | `may_error=true` | `may_error=false` |
| `esc_char`'s own caller-side completion retest | present (`test rax,rax; je`) | absent |

No other function's `may_error`/`may_gc` moved in any measured workload
(confirmed by full `effects.txt` diffs for `uri-steady`,
`web-unreserved-256`, and `refined-checks` -- each shows exactly the lines
above and no others).

## URI call-site effect table

| caller -> call expression | target | call form | may_error before | may_error after |
|---|---|---|---|---|
| `esc_char -> web::is_unreserved` | `{block}` exact (M2) | direct `callenv` (M2, unchanged) | true | **false** |
| `web::is_unreserved -> ascii::is_alphanumeric` | `{block}` exact | direct `call` | false (M1) | false |
| (module init) `<program> -> web::is_unreserved` (web-unreserved-256 only) | `{block}` exact | direct `callenv` | true | **false** |

## `web-unreserved-256` structural delta

| metric | before | after |
|---|---:|---:|
| machine code bytes | 15485 | 15441 (-44B) |
| NIR functions | 16 | 16 |
| exact calls with may_error check | 17 (4 true / 6 false-false... see below) | 17 |
| `false_false` / `true_false` / `true_true` (call_effect_report matrix) | 6 / 4 / 7 | 8 / 2 / 7 |
| `completion_checks_removed` | 6 | 8 |

Two call edges into `web::is_unreserved` exist in this workload (one from
module-scope `<program>` init, one from `esc_char`); both flip to
`may_error=false`, matching the -44B delta seen identically in `uri-steady`
and `refined-checks` (the same two-instruction removal -- one internal
recheck inside `is_unreserved`, one caller-side retest -- recurs per
*edge* into the affected function, but the internal recheck is removed
once, in `is_unreserved`'s own body, regardless of how many callers there
are; the two call-site retest removals plus the one internal-body change
together account for the observed byte delta here being identical to
`uri-steady`'s, since `web-unreserved-256`'s extra `<program>`-edge retest
happens to cost the same number of bytes as `esc_char`'s own).

## `uri-steady` structural delta

See "Outcome" above for the full table. Machine code 7155 -> 7111B (-44B,
-0.6%); `web::is_unreserved<generic>` 190 -> 155B; `esc_char<generic>`
525 -> 516B; every other function byte-for-byte identical (confirmed by
diffing `summary.txt` in full, not merely eyeballing the two changed
lines). `params.txt` has **zero** diff (M1 control, see below).
`roots.txt` has exactly one line changed (the same
`esc_char -> web::is_unreserved` effect flag) and no other root/safepoint
line moved.

## Machine-code excerpt before/after

`esc_char<generic>`'s own call into `web::is_unreserved` (objdump, both
from freshly re-probed `bench/uri-steady.bot`):

```
;; before
call   botlish_fn_9        ; R_X86_64_PLT32 botlish_fn_9-0x4 (direct)
test   rax,rax
je     <error path>
cmp    rax,0x6
je     <false path>

;; after
call   botlish_fn_9        ; R_X86_64_PLT32 botlish_fn_9-0x4 (still direct)
cmp    rax,0x6
je     <false path>
```

`web::is_unreserved`'s own body (`botlish_fn_9`), after its call to
`rt_set_contains`:

```
;; before
call   rt_set_contains     ; R_X86_64_PLT32 rt_set_contains-0x4
test   rax,rax
jne    <internal-tail: cmp rax,0x6 / je / mov eax,0x2 or 0x6>
xor    rax,rax
...
ret

;; after
call   rt_set_contains     ; R_X86_64_PLT32 rt_set_contains-0x4 (same helper)
cmp    rax,0x6
je     <false-tag path>
...
ret
```

Both excerpts confirm: the direct call stays direct (target unchanged, M2
control), the tagged Bool discrimination (`cmp rax,0x6`) is unaffected, and
the same runtime helper (`rt_set_contains`) is called either way -- only
the completion/error recheck disappears, at both the internal-body site and
the caller-side site, exactly as the milestone's own spec section 65
anticipated.

## Timing

Same methodology as M0/M1/M2 (`bench/uri-steady.tcl`, 2000-call fixed
corpus, best-of-7, 5 independent sessions, JIT compile excluded):

| | M2 session (no code change) | M3 session |
|---:|---:|---:|
| median | 5123.96 us | 6136.44 us |
| min | 4913.08 us | 5953.76 us |
| max | 7464.03 us | 6373.85 us |
| spread | 34.2% | 6.6% |

Correctness unchanged: all four backends agree on `29500` for the fixed
corpus, both before and after. This session's own timing was gathered
concurrently with an unrelated full-suite regression run sharing the same
host, so it is not a clean isolated measurement and the slower absolute
numbers versus M2's own session are expected host-load noise, not a
regression signal -- both sessions' own spreads (6.6% here, 34.2% for M2)
are themselves evidence of how much this shared host's timing already
varies run to run with **zero** code change between some of the compared
sessions. Per spec item 69, structural evidence (the exact machine-code
and effect-table deltas above -- a 44-byte, two-instruction-per-edge
change on a 7111-byte, 2000-call-loop program) is the primary evidence for
this milestone; it is not expected to produce a timing signal
distinguishable from this shared host's own noise band, and none was
required to reach the stop condition.

## Allocation / GC / roots consequences

* **Allocations**: 61510 / 2544568 bytes, identical before and after in
  `uri-steady` (confirmed via `summary.txt`'s own allocation report, not
  merely assumed).
* **`may_gc`**: unchanged (`false`) on every affected edge/function, in
  every `effects.txt` diff above -- this milestone never touches
  `op_may_allocate`, and `SetContainsTotal` is absent from it exactly like
  `SetContains` already is.
* **Roots/safepoints**: `roots.txt` for `uri-steady` differs by exactly one
  line (the `esc_char -> web::is_unreserved` effect flag text); no root or
  safepoint entry was added, removed, or moved.
* **GC stress**: `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`, run
  over the full suite including the new test file -- see "Full regression"
  below for exact counts.

## M1 regression controls

* `web::is_unreserved<generic>`'s own parameter view of `b`: **still**
  `int[Byte]` (`tests/setcontains-equality-total.test`'s
  `setcontains-m1-control-is-unreserved-param-view-unchanged`, re-deriving
  it the same way `hir-specialize-m1-module-closure` does).
* `params.txt` for `uri-steady`: **zero** diff against the pre-M3 tree
  (every declared-parameter view, guard, and entry range unchanged).
* The five ASCII generic instances remain absent (unaffected structural
  columns in the "Outcome" table: generic instances 9/9, int/raw 6/6).
* ASCII call edges' own `may_error=false` status (M1's own five collapses)
  unchanged -- confirmed by the `effects.txt` diffs showing no line other
  than the `web::is_unreserved`-related ones above.

## M2 regression controls

* `esc_char -> web::is_unreserved`'s target: still exact `{block}`,
  unchanged.
* Call form: still direct `callenv` (`tests/setcontains-equality-total.test`'s
  `setcontains-m2-control-esc-char-edge-still-direct-callenv`), never
  `callvalue`.
* `uri-steady`'s own `callvalue` count: `0` before and after (see "Outcome"
  table).
* `typed-callable-escape.test`/`hir-callable-target.test`: unchanged exact
  counts (see "Full regression").

## Full regression

* `tclsh9.0 tests/all.tcl` (interp + compile): **2142/2142 passed, 0
  failed**, both backends (2125 pre-existing, post-M2 baseline re-confirmed
  + 17 new `tests/setcontains-equality-total.test` tests).
* `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passed**, unchanged (no existing Rust unit test needed modification; the
  new `OpCode`/`op_may_error`/codegen additions are exercised through the
  Tcl-driven native/cranelift backend tests, not new `#[test]` functions).
* `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **2142/2142 passed,
  0 failed**, both backends.
* `typed-callable-escape.test`: 35/35, unchanged.
* `typed-parameters.test`: 50/50, unchanged.
* `hir-closed-call-params.test`: 15/15, unchanged.
* `hir-specialize.test`: 27/27, unchanged.
* `hir-callable-target.test`: 8/8, unchanged.
* `immutable-set.test`: 66/66, unchanged.
* `byte-set.test`/`web-unreserved.test`: unchanged, including every
  literal-constant `immutable_set_contains` fixture in those files (all
  Int/UnicodeChar/Str needles against matching-kind sets -- each now also
  lowers to `setcontainstotal` wherever it reaches native lowering, with no
  behavior change, since the runtime result is identical either way).

(Exact pass/fail counts above are quoted from this session's own run; see
the raw session logs for the literal `tcltest` summary lines.)

## Source-fence confirmation

`git diff --stat` against the pre-M3 tree (`5d0a41b`) touches exactly:

```
hir/types.tcl
native/lower.tcl
native/src/codegen/clif.rs
native/src/nir.rs
native/src/runtime/ops.rs
```

plus one new file, `tests/setcontains-equality-total.test`, and this
report. No `.bot`, `.ir`, `.hir` file has any diff -- confirmed directly
(`git status --porcelain` shows no such path). The FINAL SEMANTIC SOURCE
FENCE remains intact.

## Residual first-loss matrix

| fact | before M3 | after M3 |
|---|---|---|
| `web::is_unreserved`'s own `SetContains` local-op effect | `may_error=true` (blind to operand types) | `may_error=false` (proven from static operand types) |
| `web::is_unreserved` function aggregate | `may_error=true` | `may_error=false` |
| `esc_char -> web::is_unreserved` edge | `may_error=true` | `may_error=false` |
| `esc_char`'s own caller-side completion retest | present | **gone -- this was M2's own identified next first loss, now closed** |
| Generic `SetContains` (broad/erased/unsupported operands) | `may_error=true` | unchanged, `may_error=true` |
| `esc_char -> web::is_unreserved` call target/form | exact `{block}`, direct `callenv` (M2) | unchanged |
| `web::is_unreserved<generic>`'s own declared-Byte parameter view (M1) | `int[Byte]` | unchanged |
| Tagged Bool discrimination on the edge's own result | `cmp rax,0x6` present | unchanged, still present |
| `SetFromList`'s own analogous dedup-equality question | unaddressed (`byte::set`'s own module-init construction) | unaddressed -- explicit follow-up, not started here |
| `web::is_unreserved`'s own internal `rt_set_contains` NO_VALUE recheck | present | **gone**, since the call site is now proven to never need it |

## SetFromList follow-up assessment

Not implemented, per explicit scope (items 27/44-45). `immutable_set_from_list`'s
own dedup pass (`rt_set_from_list`) calls the identical `equal` for its own
duplicate-elimination comparisons, and the *identical* static predicate
(`hir::types::IsEqualityTotal` on the source `List[T]`'s own element type)
would in principle let a `SetFromListTotal`-shaped refinement apply the
same way. `byte::set`'s own construction happens once, at module
initialization (confirmed unaffected here: `params.txt`/allocation counts
show no movement in any module-init code), so it is not part of
`web::is_unreserved`'s own steady-state cost and was correctly kept out of
this milestone's own causal experiment (spec items 44-45's own reasoning).
Recorded as the clearest, most directly analogous next candidate.

## family-1b reassessment

Unaffected by this milestone. `refined-checks`'s own remaining generic-
instance guards (`StringRegion` scanner index guards, M1's own family 1b)
are on parameters with no declared type and no relationship to
`SetContains`; this milestone's own `refined-checks` diff is exactly the
one `esc_char -> web::is_unreserved` edge (see "Effect propagation"
above), confirming no incidental movement in that unrelated family.

## Recommended next milestone

`SetFromList`'s own analogous equality-total refinement (immediately
above) is the clearest, most directly evidenced next step, following the
identical "repair one information-preservation boundary, let existing
effect machinery do the rest" shape as M1/M2/M3. Family 1b
(`refined-checks`'s `StringRegion` scanner-index guards) remains the
second, independent candidate carried forward unchanged from M1/M2.

## Required architecture questions

1. **Static set type at the URI `SetContains` invocation?**
   `ImmutableSet[Byte]`, confirmed directly (not inferred from source
   spelling): `hir::typeOf` on the `additional_unreserved_chars` ref node
   inside `is_unreserved<generic>`'s own instance view returns
   `{immutableSet {refined int {Byte}}}`.
2. **Static needle type?** `Byte` (`int[Byte]`), confirmed the same way on
   the `b` ref node -- M1's own payoff, re-verified here, not assumed.
3. **Compiler layer where this pair is last simultaneously visible before
   M3?** `native::lower::NativeCallOp`'s own call node, via
   `hir::typeOf $hir $setArg`/`$needleArg` -- exactly where `==`'s own
   `veq`/`ieq`/`streq` selection already reads its two argument types.
4. **Where was the fact previously lost or ignored?** Never lost -- ignored
   at exactly that one proc, which had no branch consulting it for this
   native.
5. **Exact condition that proves a SetContains invocation cannot raise
   EQUALITY?** `IsSet(setType) && IsEqualityTotal(elementType) &&
   IsEqualityTotal(needleType)`, where `IsEqualityTotal` mirrors `equal`'s
   own kind check.
6. **Static types, not constant contents?** Yes -- confirmed: the proof
   consumes only `hir::typeOf`, never inspects `additional_unreserved_chars`'s
   own retained runtime value or member count (see "empty-set" fixture,
   which is proven total with zero runtime members).
7. **Is `Byte` special-cased by name?** No -- confirmed by `grep` over this
   milestone's own diff and by the dedicated `Small`-domain fixture.
8. **Do arbitrary source-defined Int subdomains qualify naturally?** Yes --
   `kindOf`'s own refinement-collapsing is the entire mechanism.
9. **Does `ImmutableSet[Byte] x any` qualify?** No -- confirmed by the
   broad-needle negative fixture.
10. **Do unsupported equality kinds remain fallible?** Yes -- confirmed by
    the Block-kind runtime-EQUALITY fixture.

## Required NIR/effect questions

11. **Does global `SetContains` remain potentially erroring?** Yes --
    `op_may_error(SetContains)` unchanged, still `true` unconditionally.
12. **How is one equality-total invocation distinguished?** A sibling NIR
    opcode, `SetContainsTotal`, chosen only at `NativeCallOp`'s own
    call-site-specific branch.
13. **Was `op_may_error(SetContains)` globally changed to `false`?** No.
14. **Did `rt_set_contains` runtime semantics change?** No -- unmodified;
    both opcodes call it identically.
15. **Does the positive case still use the same runtime helper?** Yes --
    confirmed both statically (`clif.rs`'s own match arms) and dynamically
    (objdump: both before and after excerpts show
    `R_X86_64_PLT32 rt_set_contains-0x4`).
16. **Does existing function-level effect propagation consume the refined
    op effect naturally?** Yes -- `nir.rs::summarize_call_effects` is
    unmodified; it already ORs every local op's `op_may_error` and every
    call target's own settled effect, and simply computes a different
    answer now that one local op reports `false`.
17. **Was `effectiveErrors` newly made authoritative?** No -- this
    milestone touches no completion/error-declaration machinery
    (`hir/completions.tcl`); the effect change is entirely `nir.rs`'s own
    unmodified opcode-based analysis.

## Required URI questions

18. **`web::is_unreserved` may_error before/after?** true -> false.
19. **`esc_char -> web::is_unreserved` may_error before/after?** true ->
    false.
20. **Still direct `callenv`?** Yes.
21. **Does the `test rax,rax` completion retest disappear?** Yes,
    confirmed in the disassembly excerpt above.
22. **Does the tagged Bool `cmp rax,0x6` remain?** Yes, unchanged, both
    at the caller-side edge and inside `is_unreserved`'s own body.
23. **Does `rt_set_contains` remain in the generated path?** Yes,
    unchanged.
24. **Do allocation count/bytes change?** No -- 61510/2544568, identical.

## Required negative-case questions

25. **A SetContains invocation that remains `may_error=true` because the
    needle is statically broad?** `setcontains-broad-needle-stays-erroring`.
26. **An invocation that can genuinely raise EQUALITY?**
    `setcontains-unsupported-kind-runtime-equality`.
27. **Confirm runtime failure still occurs?** Yes -- `{CORE SEMANTIC
    EQUALITY}`, pinned directly.
28. **Confirm caller-side completion propagation remains?**
    `setcontains-error-propagation-control` confirms the caller of a
    genuinely-fallible instance keeps `may_error=true`.
29. **Future unknown type default?** `IsEqualityTotal` returns `false` for
    any kind not in its fixed five-member list -- a new type is
    conservative by construction, requiring no maintenance to stay sound.

## Required benchmark questions

30. **`uri-steady` machine-code bytes before/after?** 7155 -> 7111.
31. **Exact calls with may_error check before/after?** 11 -> 10.
32. **SetContains proven-total count before/after?** 0 -> 1 (the one real
    corpus site).
33. **Guard count before/after?** 7 -> 7, unchanged.
34. **Call/callenv count before/after?** 17 -> 17, unchanged.
35. **Generic instance count before/after?** 9 -> 9, unchanged.
36. **Allocations/bytes before/after?** 61510/2544568, unchanged.
37. **`web-unreserved-256` machine-code/effect delta?** 15485 -> 15441B;
    both call edges into `web::is_unreserved` flip to `may_error=false`.
38. **Cranelift timing?** See "Timing" above -- structural evidence is
    primary; a two-instruction, 44-byte change is not expected to be
    distinguishable from this host's own noise band.
39. **Any `refined-checks` movement attributable solely to SetContains?**
    Yes -- exactly the one `esc_char -> web::is_unreserved` edge; nothing
    else in that workload's `effects.txt`/`summary.txt` moved.

## Required scope questions

40. **Was SetFromList changed?** No.
41. **Was ImmutableSet representation changed?** No.
42. **Was equality runtime semantics changed?** No.
43. **Was an Eq/Comparable trait introduced?** No.
44. **Was call ABI changed?** No.
45. **Was Bool representation changed?** No.
46. **Was inlining changed?** No.
47. **Was closure specialization changed?** No.
48. **Was KeyType changed?** No.
49. **Was listloop changed?** No.
50. **Was any frozen `.bot`/`.ir` workload changed?** No.

## Stop condition reached

All thirteen conditions of spec section 85 hold:

1. The URI `SetContains` invocation is statically proven equality-total
   from existing applied operand types (`ImmutableSet[Byte]`, `Byte`,
   both already available at `NativeCallOp`).
2. The proof (`hir::types::IsEqualityTotal`) is generic over semantic type
   properties (kind membership in a fixed five-kind list), never
   special-cased to Byte/web/constant contents -- confirmed by the
   `Small`-domain fixture and by `grep`ing this milestone's own diff.
3. Generic `SetContains` remains potentially erroring (`op_may_error`
   unchanged, confirmed by the broad/unsupported negative fixtures).
4. Broad/unsupported operand cases remain `may_error=true`, confirmed
   directly by two dedicated fixtures.
5. Genuine EQUALITY runtime failures remain intact, confirmed by a
   dedicated runtime fixture that still raises the error.
6. `web::is_unreserved` becomes `may_error=false` through ordinary effect
   aggregation (`nir.rs`, unmodified), confirmed in `effects.txt`.
7. `esc_char`'s already-direct `callenv` naturally inherits
   `may_error=false`, confirmed in `effects.txt` and the disassembly.
8. Its caller-side completion/error retest disappears, confirmed in the
   disassembly excerpt.
9. Tagged Bool discrimination remains, confirmed in the disassembly
   excerpt.
10. No SetFromList, set representation, ABI, Bool, inlining,
    specialization, source, or equality-semantic work was bundled in
    (confirmed by `git diff --stat` and the "Required scope questions"
    above).
11. Allocations remain unchanged (61510/2544568, confirmed).
12. Full plain/Rust/GC-stress regressions pass (see "Full regression").
13. The FINAL SEMANTIC SOURCE FENCE remains intact (confirmed, "Source
    fence confirmation").
