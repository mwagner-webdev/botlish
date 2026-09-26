# M4: equality-total SetFromList effect refinement

## Outcome

Implemented and measured. `native/lower.tcl`'s `NativeCallOp` -- the same
proc M3 taught to resolve `immutable_set_contains` from its own operand
types (`equality-set`) -- now does the analogous thing for
`immutable_set_from_list`: at one particular call node, if the source
List's own static element type is proven equality-total (the identical,
unmodified `hir::types::IsEqualityTotal` predicate M3 introduced), the call
lowers to a new NIR opcode, `setfromlisttotal`, instead of the generic
`setfromlist`. `op_may_error` (`native/src/runtime/ops.rs`) classifies
`setfromlisttotal` as non-erroring; `setfromlist` itself is untouched and
remains unconditionally `may_error=true`. `op_may_allocate` lists
`setfromlisttotal` exactly like `setfromlist` (identical allocation
behavior, kept independent of the `may_error` classification). Both
opcodes lower to the identical runtime helper call (`rt_set_from_list`,
unmodified) in Cranelift codegen (`native/src/codegen/clif.rs`); the only
codegen difference is that `setfromlisttotal` skips the local NO_VALUE
recheck after that call (no `self.check(v)`, matching `op_may_error=false`)
while keeping the identical `call_allocating` site-attribution machinery
(same helper, same `KIND_SET`, distinct site label `"setfromlisttotal"` so
allocation-site reports can still tell the two apart) -- sound precisely
because `native/lower.tcl` only ever chooses it where the source list's
element type is already proven to make every comparison
`rt_set_from_list`'s own dedup pass performs `T x T` for an
equality-total `T`.

This is a pure effect-classification split, keyed by opcode, exactly
mirroring M3's own shape. No new runtime operation, no change to
`ImmutableSet`/`List` representation, deduplication semantics, equality
runtime semantics, `rt_set_from_list`'s algorithm, allocation strategy, the
call ABI, Bool representation, inlining, or specialization. Generic
`SetFromList` remains potentially erroring; every call whose source list's
element type does not qualify -- a broad/unresolved List, or one over a
genuinely unsupported-equality kind (Block/Native/MutableArray) -- still
lowers to plain `setfromlist` and keeps its caller-side completion retest,
confirmed directly by dedicated negative fixtures, including one that still
raises the real, pre-existing `EQUALITY` error at runtime.

The motivating real-corpus site behaved exactly as M3's own follow-up
section predicted, with **no `byte::set`-specific code anywhere**:

```
bytes : List[Byte] (byte.bot:177, immutable_set_from_list(bytes))
    -> equality-total (hir::types::IsEqualityTotal(Byte), unchanged since M3)
    -> setfromlisttotal, may_error=false (this milestone's own local-op effect)
    -> byte::set<List[UnicodeChar]>'s own local NO_VALUE recheck around
       rt_set_from_list disappears from the generated machine code
    -> byte::set AS A WHOLE remains may_error=true (unaffected: its own
       checked byte::from_int(char::codepoint(c)) construction, inside the
       same loop, is genuinely fallible with AboveRange -- confirmed, not
       assumed; see "byte::set effect trace" below)
```

Structural results, `uri-steady` (whole program, includes module init;
"default" lowering options, matching M3's own methodology -- see
"Methodology note" below):

| metric | M3 baseline (re-measured, commit `b27c4a5`) | M4 |
|---|---:|---:|
| NIR functions | 17 | 17 |
| machine code bytes | 7111 | 7103 (-8B, -0.11%) |
| `SetFromList`: generic / equality-total | 1 / 0 | 0 / 1 |
| allocations / bytes | 61510 / 2544568 | 61510 / 2544568 (unchanged) |
| `effects.txt` diff | -- | empty (zero lines changed) |
| `roots.txt` diff | -- | empty (zero lines changed) |
| `params.txt` diff | -- | empty (zero lines changed) |

Exactly one function's own machine code shrinks:
`byte::set<List[UnicodeChar]>` 625B -> 617B (-8B, its own internal
`rt_set_from_list` NO_VALUE recheck gone -- `test rax,rax` / `je <error>`,
confirmed in the disassembly below). No caller-side edge changes at all:
`<program> -> byte::set` stays `may_error=true` (unaffected, per
"byte::set effect trace" below), so **zero** completion-retest machinery
moves at any call site in this milestone -- unlike M3, whose refinement
cascaded to a second function (`web::is_unreserved`) and a caller-side edge
(`esc_char -> web::is_unreserved`). This is the correct, fully anticipated
outcome (spec items 27/31/33): SetFromList's own local-op effect is exactly
one property among several that determine `byte::set`'s aggregate
`may_error`, and the other one (checked `Byte` construction) was never in
scope to change.

Files changed:

```
native/lower.tcl                       44 +++--    (NativeCallOp/NativeImpl)
native/src/nir.rs                      22 ++        (SetFromListTotal opcode)
native/src/runtime/ops.rs              28 ++        (op_may_error/op_may_allocate/apply_op)
native/src/codegen/clif.rs             20 ++        (codegen tuple)
tests/setfromlist-equality-total.test  new, 14 tests
tests/byte-set.test                     8 +-        (allocation-site label regression fix)
tests/immutable-set.test               17 +-        (allocation-site label regression fix, x2)
tests/web-unreserved.test                8 +-        (allocation-site label regression fix)
M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md  this report
```

`hir/types.tcl` has **zero** diff: `hir::types::IsEqualityTotal` is reused
completely unchanged, exactly as spec item 4 anticipated. No
`.bot`/`.ir`/`.hir` frozen source file changed (confirmed below, "Source
fence confirmation").

## Methodology note

All structural tables above use `native::lower::program`'s *default*
lowering options (no `-tiny-leaf-inline-opt 0`), matching M3's own
`uri-steady`/`web-unreserved-256` table methodology exactly (confirmed by
re-deriving M3's own numbers -- 17 functions/7111 bytes, 16 functions/15441
bytes -- byte-for-byte from a fresh worktree at commit `b27c4a5`, the
post-M3 tree, before making any M4 change). `tests/setfromlist-equality-
total.test`'s own `nirOf` helper instead passes `-tiny-leaf-inline-opt 0`
for its synthetic single-function fixtures, exactly like M3's own test
file, so tiny-exact-leaf inlining does not fold the one-op callee under
test into its caller and hide the very opcode the test inspects
(TINY-EXACT-LEAF-INLINING.md, orthogonal to this milestone either way).

## Runtime SetFromList equality semantics (authoritative source, confirmed
directly)

`rt_set_from_list` (`native/src/runtime/ops.rs:879-902`):

```rust
pub extern "C" fn rt_set_from_list(p: *mut Vm, l: Value) -> Value {
    let source = list_of(l).items();
    let mut items: Vec<Value> = Vec::with_capacity(source.len());
    for &item in source {
        let mut seen = false;
        for &existing in items.iter() {
            match equal(p, existing, item) {
                Ok(true) => { seen = true; break; }
                Ok(false) => {}
                Err(()) => return NO_VALUE,
            }
        }
        if !seen { items.push(item); }
    }
    let elements = items.len();
    let r = vm(p).new_set(items);
    vm(p).metrics.record_list_copy(elements);
    r
}
```

O(n^2): for each source element, linearly compares it against every
*already-retained* element via `equal` (the identical helper
`rt_set_contains`/`==`/M3's own `equal` use, `ops.rs:317-355`), which fails
(`Err(())`, propagated here as `NO_VALUE`) if and only if either operand's
runtime kind is Block, Native, or MutableArray -- checked first,
unconditionally, before any other comparison logic. Every comparison this
function ever performs is between two elements *of the same source List*,
so every comparison is trivially `T x T` for the list's own static element
type `T`: there is no second, differently-typed operand the way
`SetContains`'s needle is a separate argument -- `SetFromList`'s own proof
is in this sense simpler than M3's own two-operand `SetContains` proof, not
more complex. `EQUALITY` is the only semantic error source in this
function: the only other paths are `list_of(l)` (a dynamic-dispatch guard
ahead of this call, per the native's own `-param-types {list}` declaration,
already enforced before this helper runs) and `vm(p).new_set(items)`
(allocation, modeled entirely separately via `op_may_allocate`, confirmed
unaffected below). No malformed/internal-state path affects ordinary
Botlish semantics: this function's only externally observable outcomes are
"a well-formed `ImmutableSet`" or "the pre-existing `EQUALITY` error."

Confirmed against the actual code (not assumed from M3's `SetContains`
analogy), matching the milestone's own expected model exactly:

```
List[T]
    -> iterate elements
    -> compare candidate against already-retained elements using equal (T x T)
    -> deduplicate
    -> allocate/build ImmutableSet via vm.new_set
```

## Exact first-loss location

**`native::lower::NativeCallOp`** (`native/lower.tcl`), the identical proc
M3 already extended for `immutable_set_contains`. The source list's own
static element type is already an ordinary, fully-resolved HIR fact by the
time this proc runs for `byte::set`'s own `immutable_set_from_list(bytes)`
call: `bytes`'s type is `List[Byte]` (`{list {refined int {Byte}}}`),
directly visible via `hir::typeOf` on the `bytes` ref node inside
`byte::set<List[UnicodeChar]>`'s own instance view, confirmed directly (see
"Architecture trace" below) -- nothing upstream ever lost it. The
`immutable_set_from_list` entry in `native::lower::natives`, though, was
`{op setfromlist}` -- an ordinary fixed single-opcode entry, structurally
identical to `list_get`, never consulting the argument's own static type at
all. This is the exact same shape as M3's own first-loss finding for
`SetContains`: *the HIR call already knows enough, but lowering emits the
generic opcode unconditionally*.

## Reuse of IsEqualityTotal

Zero changes to `hir/types.tcl`. `native::lower::NativeCallOp`'s new
`equality-list` branch:

```tcl
equality-list {
    set op setfromlist
    if {[llength $argExprs] == 1} {
        set listType [hir::typeOf $hir [lindex $argExprs 0]]
        if {[hir::types::IsList $listType]
                && [hir::types::IsEqualityTotal [lindex $listType 1]]} {
            set op setfromlisttotal
        }
    }
    return [list $name $op]
}
```

consumes exactly two pre-existing HIR facts: `hir::types::IsList` (checks
the argument is a precise `{list ELEM}`/`{list ELEM SHAPE}` form, not an
erased/broad type) and `hir::types::IsEqualityTotal` applied to `ELEM`
alone -- the identical, unmodified predicate M3 introduced
(`hir::types::kindOf(type) in {int str bool unit UnicodeChar}`). No second
predicate was invented; `IsEqualityTotal` needed no correctness fix (it was
already generic over "is this static type's fixed runtime kind
equality-safe," independent of which native consumes it).

## Implementation change

Same four-file shape as M3, one file each:

* **`hir/types.tcl`**: unchanged (0 lines).
* **`native/lower.tcl`**: `immutable_set_from_list`'s `natives` entry
  becomes `{equality-list}` (was `{op setfromlist}`); `NativeCallOp` gains
  an `equality-list` switch arm (above); `NativeImpl` (the generic,
  dynamically-dispatched entry for `rt_call_value`) gains
  `equality-list { return setfromlist }` -- always the conservative opcode,
  for the identical reason M3's own `NativeImpl` always returns
  `setcontains`: a `Native` value called through `rt_call_value` carries no
  per-call-site static proof.
* **`native/src/nir.rs`**: new `OpCode::SetFromListTotal` variant (doc
  comment mirrors `SetContainsTotal`'s own), `"setfromlisttotal"` added to
  the string parser, and added to the `arity() -> Some(1)` group alongside
  `SetFromList` (both take exactly one operand).
* **`native/src/runtime/ops.rs`**: `SetFromListTotal` added to
  `op_may_allocate`'s `matches!` list (same allocation behavior as
  `SetFromList`) but *not* to `op_may_error`'s list (so it defaults
  `false`, the same "absence, not a special case" mechanism M3's own
  `SetContainsTotal` uses); `apply_op` gains a
  `SetFromListTotal => rt_set_from_list(p, a[0])` arm (unreachable via
  `NativeImpl`'s own generic dispatch, kept only for match exhaustiveness,
  exactly like `SetContainsTotal`'s own arm).
* **`native/src/codegen/clif.rs`**: new `SetFromListTotal` match arm,
  structurally identical to `SetFromList`'s own `call_allocating` call (same
  helper name, same `KIND_SET`) but with no `self.check(v)` afterward and a
  distinct site label (`"setfromlisttotal"` vs. `"setfromlist"`) so
  allocation-site reports keep the two apart.

**No new effect-annotation mechanism, no boolean flag on `Inst::Op`** --
considered and rejected for the identical reasons M3's own report
documents (`op_may_error`/`op_may_allocate` are already pure, total
functions of `OpCode` alone; adding a second, instruction-level source of
truth for the same fact would fork that architecture for one opcode). A
second `OpCode` variant is the smallest form consistent with M3's own
precedent (`SetContains`/`SetContainsTotal`, and further back,
`ILt`/`RILt`).

## Why may_error and may_gc remain orthogonal

`SetFromList`'s own runtime operation *allocates* (`vm(p).new_set(items)`,
unconditionally, even for zero retained elements -- confirmed by
`op_may_allocate`'s pre-existing, unmodified `SetFromList` membership).
This milestone's refinement is entirely about whether that operation's
*equality comparisons* can fail, a completely separate runtime property
from whether it allocates. `op_may_allocate` and `op_may_error` are two
independent `matches!` functions over the same `OpCode` enum, each
consulted independently by `nir.rs`'s own effect fixed point (`may_error`)
and by `codegen::roots`'s own safepoint classification (`may_gc`,
downstream of `op_may_allocate`) -- neither reads the other. Concretely:
`SetFromListTotal` is added to `op_may_allocate`'s list (still allocates)
and *not* added to `op_may_error`'s list (no longer erroring) -- two
independent, one-line edits to two independent functions, not a single
combined flag. Confirmed directly, not merely asserted: `setfromlist-
total-int`'s own positive fixture (below) pins both `may_error=false` *and*
`may_gc=true` on the identical call edge in one test.

## Positive fixtures

All in `tests/setfromlist-equality-total.test`, inspecting NIR text
(`op setfromlisttotal` vs. `op setfromlist`) and the call-effects report
(`native::Driver calls`) directly, plus a four-backend runtime-parity
fixture, following M3's own established technique:

* **`setfromlist-total-int`** -- the simplest non-Byte control:
  `List[int] -> ImmutableSet[int]` lowers to `setfromlisttotal`; `mk_int`
  becomes `may_error=false` **and** `may_gc=true` on the same call edge
  (the orthogonality pin, above).
* **`setfromlist-total-source-defined-domain`** -- `Small = Int in 0..10`
  (a *different* bounded Int domain than Byte, M1's own synthetic fixture
  shape), confirming the proof derives from `kindOf`'s own
  refinement-collapsing, never a hard-coded type name.
* **`setfromlist-total-bool`** -- `List[Bool]` qualifies, another
  audited-total scalar kind.
* **`setfromlist-total-byte`** -- `List[Byte] -> ImmutableSet[Byte]`, the
  real `byte::set` shape in miniature (a locally-declared `Byte`, per
  M3's own note that `surface::compile` cannot resolve module-qualified
  references -- the real acceptance case is covered separately, below, via
  the frozen `bench/uri-steady.bot` itself).
* **`setfromlist-total-runtime-parity`** -- a real `setfromlisttotal`
  construction (`[1, 1, 2, 3]`, forcing an actual duplicate-elimination
  comparison) agrees with plain membership queries across all four
  backends (interp, compile, cranelift-generic, cranelift): `[true, false]`
  on every backend, never `Error`.
* **`setfromlist-empty-list-stays-generic`** -- see "Empty-list finding"
  below: **not** a positive fixture (deliberately, per spec item 20), kept
  here as the natural place to document the actual, conservative behavior.

## Negative fixtures

* **`setfromlist-broad-element-stays-erroring`** -- a genuinely broad
  source list (forced via `hir::specialize::limit` exhaustion, the
  identical technique M3's own broad-needle fixture uses: two call sites
  with divergent element kinds, `int` and `str`, share one generic
  instance whose own `xs` view is genuinely unresolved) stays plain
  `setfromlist`, `may_error=true` **and** `may_gc=true` (both effect
  dimensions confirmed independently on the fallback case too).
* **`setfromlist-unsupported-kind-runtime-equality`** -- a `List` of two
  distinct untyped-closure (Block-kind) values (`[g, h]`, two *different*
  functions so the dedup pass actually performs a real comparison between
  them, not merely a single-element list that never compares anything --
  see "Ensuring the runtime failure is exercised" below): stays plain
  `setfromlist`/`may_error=true`, and genuinely raises the pre-existing
  `{CORE SEMANTIC EQUALITY}` error at runtime -- confirming this milestone
  never weakens the real failure mode it is refining around.
* **`setfromlist-error-propagation-control`** -- a caller of the broad,
  genuinely fallible generic instance above keeps its own `may_error=true`
  call edge, confirming the refinement is invocation-specific, not a
  global opcode reclassification.
* **`setfromlist-list-of-never`** -- see "List[never] audit" below.

## Ensuring the runtime failure is actually exercised

Per spec item 19's own caution: a single-element list of one unsupported
(Block-kind) value would perform **zero** comparisons (the outer loop's
inner "compare against already-retained elements" loop is empty on the
first element), so it would not actually exercise `equal`'s own
Block-kind rejection at all -- it would simply retain that one element
successfully. `setfromlist-unsupported-kind-runtime-equality` therefore
uses a **two**-element list of two distinct closures (`g`, `h`), forcing
the second element to be compared against the first -- confirmed to
actually raise `{CORE SEMANTIC EQUALITY}` (not merely to lower to the
generic opcode).

## Empty-list finding (spec item 20 -- an important, honest negative result)

Spec item 20 explicitly warns against treating the empty-list case as the
design driver, and explicitly permits "a conservative generic result for
broad/never cases." Investigating this directly (not assumed) surfaced a
genuine, worth-recording asymmetry with M1's own scalar mechanism:

```tcl
fn mk_int(xs: List[int]) -> ImmutableSet[int]:
    immutable_set_from_list(xs)

mk_int([])
```

lowers `mk_int`'s own single instance to `instance="List[never]"` --
**not** `List[int]`, despite `mk_int`'s own declared parameter type being
`List[int]` -- confirmed directly via `native::lower::program`'s NIR text.
`hir::types::IsEqualityTotal(never)` is `false` (`kindOf(never)` returns
`""`, never a member of the five safe kinds), so this instance's own
`SetFromList` call stays generic `setfromlist`, `may_error=true`.

This is **not** a bug this milestone needs to fix, and it is **not** the
same mechanism M1 established for scalar parameters: M1's own "declared
parameter facts survive specialization" result is specifically about a
*scalar* refined-Int parameter's declared type overriding a broader
call-site view (`hir::specialize`'s own `declaredParamTypes` seeding).
For a `List[T]` parameter, `hir::specialize::KeyType` instead keys the
instance from the *actual call sites'* own inferred list-element type, not
from the declared annotation -- so a genuinely empty list literal argument
(no elements to infer a kind from at all) narrows this specific instance
to `List[never]`, independent of what the function's own signature
declares. `setfromlist-total-int`'s own fixture (`mk_int([1, 2, 3])`)
confirms the *non-empty* case does resolve to `List[int]` and is proven
total -- the difference is entirely about what an empty literal's own key
type resolves to, not about whether declared parameter types are honored
in general.

This is exactly the sound-but-incomplete outcome spec item 20 anticipates:
never unsound (an empty list performs zero dynamic comparisons regardless
of classification), conservative rather than optimized, and correctly
*not* worked around by inventing an empty-list special case (which the
spec explicitly forbids). `setfromlist-empty-list-stays-generic`
documents this directly, as itself, rather than mislabeling it a positive
fixture.

## List[never] audit (spec item 21)

`immutable_set_from_list([])` at top level (no declared parameter context
at all) lowers its own list argument as `List[never]` and stays plain
`setfromlist` -- confirmed by `setfromlist-list-of-never`, which asserts
`op setfromlisttotal` is *absent* and `op setfromlist` is present. No crash,
no misclassification, no dedicated optimization: `IsList(never-shaped
type)` still holds (`{list never}` is a valid, precise list-of-never
form), but `IsEqualityTotal(never)` is `false`, so the generic path is
chosen -- sound and conservative, exactly like the empty-list finding
above (they are, in fact, the same underlying mechanism observed from two
different angles: an empty list literal's own inferred element type is
`never`).

## byte::set effect trace (spec items 29-33, the most important check)

Traced directly against the frozen `bench/uri-steady.bot`, not assumed by
analogy:

| fact | before M4 | after M4 |
|---|---|---|
| `byte::set`'s own `SetFromList` local op | `may_error=true` (opcode `setfromlist`) | `may_error=false` (opcode `setfromlisttotal`) |
| `byte::set`'s own internal `rt_set_from_list` NO_VALUE recheck | present | **gone** (confirmed in disassembly, below) |
| `byte::set` function aggregate `may_error` | `true` | **still `true`** -- unaffected |
| `<program> -> byte::set` edge `may_error` | `true` | **still `true`** -- unaffected |
| Cause of `byte::set`'s remaining `may_error=true` | `byte::from_int`'s own genuinely fallible `AboveRange` (checked construction inside the same loop) | **unchanged** -- confirmed the *same* cause, not a new one |
| `byte::set(['Ā'])` (U+0100, past Byte's own range) | raises `CORE SEMANTIC UNCAUGHT-ERROR` (an uncaught `AboveRange`) on all four backends | **unchanged**, all four backends, confirmed directly (`setfromlist-byte-set-real-range-error-preserved`) |

`native::Driver calls`'s own report line for the only call edge into
`byte::set` (`<program> -> byte::set`) is **identical** before and after
except that its callee id's own aggregate stays `may_error=true` for a
*different, unaffected* reason -- confirmed by an empty `effects.txt` diff
across the entire `uri-steady` workload (no line changed at all, not even
this one, since its own `may_error=true` value did not move). This is
spec item 31's own anticipated "zero caller-level effect movement" outcome,
and it is correct: `SetFromList`'s own local-op effect became one property
among several that determine `byte::set`'s own aggregate effect, and the
other one (`byte::from_int`'s checked construction) was never in this
milestone's scope to change (spec item 30 explicitly forbids "erasing"
this).

## Machine-code excerpt before/after

`byte::set<List[UnicodeChar]>`'s own body, immediately after its call into
`rt_set_from_list` (objdump, both from freshly re-probed `bench/uri-
steady.bot`, `botlish_fn_3`):

```
;; before
call   66a <botlish_fn_3+0xea>   ; R_X86_64_PLT32 rt_set_from_list-0x4
test   rax,rax
je     71a <botlish_fn_3+0x19a>  ; the local NO_VALUE recheck
mov    rbx,QWORD PTR [rsp+0x30]
...

;; after
call   66a <botlish_fn_3+0xea>   ; R_X86_64_PLT32 rt_set_from_list-0x4 (same helper)
mov    rbx,QWORD PTR [rsp+0x30]
...
```

Confirms: the same helper is called either way (`rt_set_from_list`,
unmodified target), and only the two-instruction completion/error recheck
(`test rax,rax` / `je <error>`) disappears -- exactly M3's own analogous
finding for `rt_set_contains`, applied here to `rt_set_from_list`.

## SetFromList corpus census

Searched the entire frozen corpus (`lib/*.bot`, `bench/*.bot`, `bench/*.ir`,
every `audit/comprehensive-generated-code/probes/*.bot` fixture) for
`immutable_set_from_list` call sites:

| site | count |
|---|---:|
| `lib/byte.bot:177` (`byte::set`) | 1 |
| everywhere else in the frozen corpus | 0 |

**Exactly one** real `SetFromList` call site exists in the whole frozen
corpus (the identical situation M3 found for `SetContains`), and it is now
proven equality-total. Broad/unsupported-equality `SetFromList` invocations
are covered entirely by the synthetic fixtures above, deliberately kept
per spec item 34's own instruction.

## Effect propagation before/after (`uri-steady`, `effects.txt`)

**Empty diff.** `diff` between a fresh post-M3 probe (commit `b27c4a5`) and
a fresh post-M4 probe of `bench/uri-steady.bot`'s own `effects.txt`
produces **zero** lines -- confirmed directly, not merely summarized. This
is the expected, correct outcome per spec item 31/33: `byte::set`'s own
aggregate `may_error` does not move (see "byte::set effect trace" above),
and it is the only function whose own local `SetFromList` op is affected in
this corpus, so no call-edge fact anywhere in this workload's effect
report changes. The entire visible effect of this milestone in
`uri-steady` is a local, function-internal one (the removed NO_VALUE
recheck), not a call-edge one -- unlike M3, which cascaded to two call
edges. `params.txt` and `roots.txt` are likewise empty diffs (M1/M3
regression controls, confirmed directly, not assumed).

## `uri-steady` / `web-unreserved-256` structural delta

See "Outcome" above for the full `uri-steady` table (7111 -> 7103B, -8B).
`web-unreserved-256` shows the identical delta and the identical single
changed function:

| metric | before | after |
|---|---:|---:|
| machine code bytes | 15441 | 15433 (-8B) |
| NIR functions | 16 | 16 |
| `byte::set<List[UnicodeChar]>` bytes | 625 | 617 (-8B) |
| every other function | unchanged | unchanged |
| `effects.txt` / `roots.txt` / `params.txt` diff | -- | empty |

## Allocation / GC / roots consequences

* **Allocations**: `uri-steady` 61510 allocations / 2544568 bytes,
  identical before and after (confirmed via `summary.txt`'s own allocation
  report). `web-unreserved-256`: 268 / 271976, identical before and after.
* **Allocation site label**: `byte.bot:177`'s own site changes its
  `operation` label from `"setfromlist"` to `"setfromlisttotal"` (its own
  allocation *count* stays `x1` in both workloads) -- a cosmetic
  consequence of the opcode split, not a behavior change. This broke three
  *pre-existing* tests that filtered allocation sites by the literal string
  `"setfromlist"` (`tests/byte-set.test`'s
  `byte-set-module-retained-value`, `tests/immutable-set.test`'s
  `set-module-retained-value`/`set-module-retained-value-unicodechar`, and
  `tests/web-unreserved.test`'s `web-unreserved-set-built-once`) --
  discovered by running the full suite, not anticipated in advance. Fixed
  by widening each filter to `in {setfromlist setfromlisttotal}` (and the
  two `regexp -all {op setfromlist}` NIR-text checks to
  `{op setfromlist(?:total)?}`), with a comment at each site explaining why
  the label changed. This is the one case in this milestone where a
  pre-existing test needed updating -- not because retention/allocation
  behavior changed, but because a test asserted an implementation-detail
  opcode name that legitimately split into two.
* **`may_gc`**: `SetFromListTotal` is in `op_may_allocate`'s list (same as
  `SetFromList`) -- confirmed unchanged on every affected function in every
  `effects.txt`/disassembly view above. See "Why may_error and may_gc
  remain orthogonal" for the direct two-effect pin.
* **Roots/safepoints**: `roots.txt` for both `uri-steady` and
  `web-unreserved-256` has an **empty** diff -- no root or safepoint entry
  added, removed, or moved.
* **GC stress**: `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`, full
  suite including the new test file -- see "Full regression" below.

## M1 regression controls

* `tests/typed-parameters.test`: 50/50, unchanged.
* `tests/hir-specialize.test`: 27/27, unchanged.
* `params.txt` for both `uri-steady` and `web-unreserved-256`: **zero**
  diff against the pre-M4 tree (every declared-parameter view, guard, and
  entry range unchanged).
* `web::is_unreserved<generic>`'s own declared-Byte parameter view: still
  `int[Byte]` (M1's own subject, unaffected -- confirmed by re-running
  M3's own regression test, `setcontains-m1-control-is-unreserved-param-
  view-unchanged`, unchanged, plus `setfromlist-m3-control-web-is-
  unreserved-still-total` in the new file).

## M2 regression controls

* `tests/hir-callable-target.test`: 8/8, unchanged.
* `tests/typed-callable-escape.test`: 35/35, unchanged.
* `esc_char -> web::is_unreserved`: still exact `{block}`, still direct
  `callenv`, still `may_error=false` (M3's own result, unaffected -- this
  milestone touches no code on that call path at all: `byte::set`'s own
  call is a *different*, module-init-only edge, `<program> -> byte::set`).
* `uri-steady`'s own `callvalue` count: `0`, unchanged.

## M3 regression controls

* `web::is_unreserved`'s own `SetContains` call: still `setcontainstotal`,
  still `may_error=false` -- confirmed directly against the frozen
  `bench/uri-steady.bot` (`setfromlist-m3-control-web-is-unreserved-still-
  total`, the new file's own dedicated M3 control) and by re-running
  `tests/setcontains-equality-total.test` in full: 17/17, unchanged.
* Generic broad/erroring `SetContains` still `may_error=true`; the real
  `EQUALITY` `SetContains` fixture still errors (unaffected -- this
  milestone adds no code to any `SetContains`-related path;
  `native/lower.tcl`'s own `equality-set` branch is untouched, confirmed by
  `git diff` producing no hunk inside that switch arm).
* Tagged Bool comparison (`cmp rax,0x6`) remains present in both
  `web::is_unreserved`'s own body and its caller's edge, confirmed in the
  same disassembly excerpts M3 already established (unaffected: this
  milestone's own machine-code delta is confined entirely to
  `byte::set<List[UnicodeChar]>`).

## Full regression

* `tclsh9.0 tests/all.tcl` (interp + compile): **2156/2156 passed, 0
  failed**, both backends (2142 pre-existing post-M3 baseline + 14 new
  `tests/setfromlist-equality-total.test` tests). One intermediate run
  surfaced 4 pre-existing failures from the allocation-site-label rename
  described above ("Allocation / GC / roots consequences"); after fixing
  those four tests' own filters, the full suite is clean.
* `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passed**, unchanged (no existing Rust unit test needed modification; the
  new `OpCode`/`op_may_error`/`op_may_allocate`/codegen additions are
  exercised through the Tcl-driven native/cranelift backend tests, not new
  `#[test]` functions -- identical to M3's own approach).
* `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **2156/2156 passed,
  0 failed**, both backends -- identical to the plain run.
* `tests/immutable-set.test`: 68/68 (66 pre-existing + 2 fixed allocation-
  site filters, both passing).
* `tests/byte-set.test`: 21/21 (20 pre-existing + 1 fixed allocation-site
  filter).
* `tests/web-unreserved.test`: 12/12 (11 pre-existing + 1 fixed
  allocation-site filter).
* `tests/setcontains-equality-total.test`: 17/17, unchanged.
* `tests/hir-specialize.test`: 27/27, unchanged.
* `tests/hir-callable-target.test`: 8/8, unchanged.
* `tests/typed-callable-escape.test`: 35/35, unchanged.
* `tests/typed-parameters.test`: 50/50, unchanged.

## Source-fence confirmation

`git diff --stat` against the pre-M4 tree (`b27c4a5`) touches exactly:

```
native/lower.tcl
native/src/codegen/clif.rs
native/src/nir.rs
native/src/runtime/ops.rs
```

plus four test files (`tests/setfromlist-equality-total.test` new;
`tests/byte-set.test`, `tests/immutable-set.test`,
`tests/web-unreserved.test` each touched only for the allocation-site-label
regression fix above) and this report. No `.bot`, `.ir`, `.hir` file has
any diff -- confirmed directly (`git status --porcelain` shows no such
path). `hir/types.tcl` has **zero** diff. The FINAL SEMANTIC SOURCE FENCE
remains intact.

## Post-M4 generated-code re-census

`uri-steady`'s own post-M4 `summary.txt`, the largest remaining functions
by machine-code bytes:

| function | bytes | notable ops |
|---|---:|---|
| `repeat_uri<generic>` | 1180 | 4 guards, `listget`/`listlen`/`imod`/`strlen`, `tail` |
| `<program><generic>` | 1100 | 3x `listnew`, `closure`, 2 calls |
| `esc_from<generic>` | 1004 | 4 guards, `substr`/`strcat`, `tail` |
| `esc_bytes<generic>` | 864 | 3 guards, `strcat`x2, `tail` |
| `hex_pair<generic>` | 484 | 1 guard, 2x `listget`, `imod`/`strcat` |
| `esc_char<generic>` | 516 | 1 guard, `strutf8bytes`/`listget`, `callenv`/2 `call` |
| `byte::set<List[UnicodeChar]>` | 617 (was 625) | 1 `setfromlisttotal` (was `setfromlist`) |
| `byte::from_int<int>` | 337 | 2 `fail`, `ilt`/`igt` (no `guard` op -- explicit `if`/`else`, not a native-arg guard) |
| `web::is_unreserved<generic>` | 155 | 1 `setcontainstotal`, 1 `call` |

At least reconsidered, per spec item 44:

* **Family 1b / StringRegion scanner-index guards**: still present,
  unaffected (11 total `guard` ops across `high_nibble`/`hex_pair`/
  `esc_bytes`/`esc_char`/`esc_from`/`repeat_uri` -- the same M1-identified
  family, on parameters with no declared type, unrelated to `SetFromList`).
  Still the single largest remaining *class* of guard machinery in this
  workload, unchanged by M3 or M4.
* **Tagged Bool discrimination**: still present (`cmp rax,0x6` at
  `web::is_unreserved`'s own body and its caller edge) -- visually
  conspicuous, per spec item 45's own explicit warning not to auto-
  recommend it merely for that reason.
* **Generic `ImmutableSet[Byte]` representation**: unaffected by M3 or M4
  (both milestones only ever change effect *classification*, never
  representation).
* **`byte::set`'s own temporary `List[Byte]`** (`bytes`, built via
  `listnew`/4x `listappend` before the now-refined `setfromlisttotal`
  call): still present, still a real allocation (`byte.bot:175`'s own
  sites, x1/x4, unchanged before/after) -- explicitly out of scope (spec
  item: "remove the temporary List[Byte]" is a **must NOT**).
* **`char::codepoint` helper**: unaffected, still a direct 39-byte call.
* **Checked `Byte` construction for statically known literals**
  (`byte::from_int`, 337 bytes, still fully generic range-checking logic
  even for the four call-site literals `'-' '.' '_' '~'` that obviously
  fit): still present, still the reason `byte::set` as a whole stays
  `may_error=true` -- explicitly out of scope this milestone (spec items
  30/32 forbid touching it), and now the clearest concrete candidate for a
  **future**, *separate* milestone (a call-specific completion/constant-
  folding refinement analogous to M1-M4's own shape, but for checked
  domain construction over statically-known-in-range literal arguments).
* **`list_get` bounds checks**: unaffected (not exercised by
  `SetFromList`'s own lowering at all).
* **Remaining generic-instance guards / `may_error` retests**: the same 11
  guards above, plus `repeat_uri`/`esc_from`/`esc_bytes`'s own `tail`-call
  completion machinery -- unaffected by this milestone (confirmed by the
  empty `effects.txt` diff).

Nothing above was implemented -- per the milestone's own guiding
principle, this is evidence gathering for the *next* milestone's own
choice, not additional work bundled into M4.

## Residual first-loss matrix

| fact | before M4 | after M4 |
|---|---|---|
| `byte::set`'s own `SetFromList` local-op effect | `may_error=true` (blind to operand type) | `may_error=false` (proven from static list element type) |
| `byte::set`'s own internal `rt_set_from_list` NO_VALUE recheck | present | **gone** |
| `byte::set` function aggregate | `may_error=true` | **unchanged**, `true` (via `byte::from_int`) |
| `<program> -> byte::set` edge | `may_error=true` | **unchanged**, `true` |
| `byte::set(['Ā'])`'s own real RANGE-family failure | raised (`UNCAUGHT-ERROR`/`AboveRange`) | **unchanged**, still raised |
| Generic `SetFromList` (broad/erased/unsupported operands) | `may_error=true` | unchanged, `true` |
| `SetContains`/`setcontainstotal` (M3's own subject) | unaffected | unaffected (confirmed directly) |
| `ImmutableSet`/`List` representation, dedup algorithm, allocation strategy | unaffected | unaffected |
| Checked `Byte`/domain construction over statically-known-in-range literals | unaddressed | unaddressed -- explicit next-milestone candidate (see below) |
| Family 1b (`StringRegion` scanner-index guards) | unaddressed | unaddressed -- carried forward, unchanged, from M1/M3 |

## Recommended next milestone

Two independent, evidenced candidates, neither implemented here:

1. **Checked domain construction over statically-known-in-range literal
   arguments** (the clearest new evidence from this milestone's own
   re-census): `byte::from_int(char::codepoint(c))` inside `byte::set`
   remains fully generic range-checking machinery (337 bytes, 2 `fail`
   paths) even at the one real call site in the frozen corpus, where all
   four actual arguments (`'-' '.' '_' '~'`) are statically known to be in
   Byte's own range -- a call-specific completion proof
   (STATIC-COMPLETION-PROOFS.md's own existing machinery, already used
   elsewhere for e.g. `byte::set`'s own declared-error narrowing) could in
   principle prove `byte::from_int`'s own `AboveRange` unreachable for this
   exact call, closing the *other* half of `byte::set`'s own `may_error`
   classification that M4 deliberately left alone. This would be the
   natural, evidenced continuation of the M1-M4 arc's own shape ("repair
   one information-preservation boundary, let existing effect machinery do
   the rest"), and is explicitly **not** the same thing as "optimizing
   away checked Byte construction" in general (spec items 30/32's own
   prohibition) -- it is a call-specific proof, exactly like
   `byte::set`'s own existing `AboveRange`-impossibility proof for
   *itself* already is.
2. **Family 1b** (`refined-checks`/`uri-steady`'s own `StringRegion`
   scanner-index guards, 11 `guard` ops across
   `high_nibble`/`hex_pair`/`esc_bytes`/`esc_char`/`esc_from`/`repeat_uri`):
   unaffected by M3 or M4, still the largest remaining *class* of guard
   machinery in this workload, carried forward unchanged from M1's own
   original identification.

Per spec item 45's own explicit caution, this is not a recommendation of
whichever looks visually largest (`repeat_uri`/`esc_from` are the biggest
single functions, but their own machinery is unrelated to any of M1-M4's
own equality/effect-refinement arc) -- it is the two candidates this
milestone's own re-census and M1/M3's own carried-forward evidence
actually support.

## Required architecture questions

1. **What static type reaches the real `immutable_set_from_list(bytes)`
   call in `byte::set`?** `List[Byte]` (`{list {refined int {Byte}}}`),
   confirmed directly via `hir::typeOf` on the `bytes` ref node.
2. **Is that fact already present before M4?** Yes -- confirmed: `bytes`'s
   own type is fully resolved (from the `loop c in chars: from_int(...)`
   traversal's own inferred element type) well before `NativeCallOp` runs;
   nothing upstream needed to change.
3. **Where was equality-totality previously ignored?**
   `native::lower::NativeCallOp`'s own `natives` table entry for
   `immutable_set_from_list`, which was a fixed `{op setfromlist}` --
   structurally identical to every other single-opcode native, never
   consulting the argument's own static type.
4. **Does M4 reuse `hir::types::IsEqualityTotal` unchanged?** Yes --
   confirmed by `hir/types.tcl`'s own zero-line diff.
5. **Does Byte qualify through ordinary Int/refined-type semantics?**
   Yes -- identical mechanism to M3 (`kindOf`'s own refinement-collapsing
   via `core::type::base`).
6. **Is any type name special-cased?** No -- confirmed by `grep -i byte`
   over this milestone's own diff hunks in `native/lower.tcl`/
   `native/src/nir.rs`/`native/src/runtime/ops.rs`/
   `native/src/codegen/clif.rs`: nothing (only this report's own prose and
   the test file mention the name).
7. **Does generic SetFromList remain fallible?** Yes --
   `op_may_error(SetFromList)` unchanged, still unconditionally `true`.
8. **Does the generic and refined form use the same runtime helper?**
   Yes -- both `SetFromList` and `SetFromListTotal` call
   `rt_set_from_list` (unmodified), confirmed both statically
   (`clif.rs`'s own match arms, identical helper name) and dynamically
   (objdump: both before/after excerpts show
   `R_X86_64_PLT32 rt_set_from_list-0x4`).
9. **Did runtime deduplication semantics change?** No -- `rt_set_from_list`
   itself has zero diff.
10. **Did ImmutableSet representation change?** No.

## Required effect questions

11. **`SetFromList` generic: `may_error`? `may_gc`?** `true` / `true`
    (unchanged).
12. **Equality-total `SetFromListTotal`: `may_error`? `may_gc`?** `false` /
    `true`.
13. **Does the positive case demonstrate effect orthogonality?** Yes --
    `setfromlist-total-int` pins both facts on the same call edge in one
    test.
14. **Does `byte::set` as a whole become non-erroring?** **No** --
    confirmed directly, not assumed: it remains `may_error=true`.
15. **If it remains erroring, which operation still causes that?**
    `byte::from_int`'s own genuinely fallible `AboveRange`, confirmed by
    `setfromlist-uri-byte-set-stays-erroring-via-from-int` and by the
    disassembly/effects-report trace above.
16. **Does `byte::set(['Ā'])` still produce a real range-family error?**
    Yes -- `CORE SEMANTIC UNCAUGHT-ERROR` (an uncaught `AboveRange`), all
    four backends, unchanged from pre-M4 behavior (confirmed directly
    against `tests/byte-set.test`'s own pre-existing, unmodified
    `byte-set-boundary-256-fails` fixture, plus this milestone's own
    dedicated `setfromlist-byte-set-real-range-error-preserved`).

## Required generated-code questions

17. **Does the refined form remove a local error/NO_VALUE check around
    `rt_set_from_list`?** Yes -- confirmed in the disassembly excerpt
    above (`test rax,rax` / `je <error>` gone).
18. **Does `rt_set_from_list` itself remain present?** Yes, unchanged,
    still the call target either way.
19. **Does allocation machinery remain present?** Yes -- `call_allocating`
    still wraps the call, same `KIND_SET`, same site-attribution
    mechanism (only the site's own text label changed).
20. **Does the temporary `List[Byte]` remain present?** Yes -- `byte.bot:
    175`'s own `listnew`/`listappend` sites, x1/x4, unchanged before/after.
21. **Does module initialization lose any caller-side completion retest?**
    **No** -- confirmed by the empty `effects.txt` diff: `<program> ->
    byte::set` stays `may_error=true`, so its own completion check is
    unaffected. This is the correct, expected outcome (spec item 33): the
    removed machinery is entirely internal to `byte::set`'s own body, not
    at any caller edge.
22. **`uri-steady` machine-code bytes before/after?** 7111 -> 7103 (-8B).
23. **Allocation count/bytes before/after?** 61510/2544568, unchanged.

## Required negative-case questions

24. **A broad-element SetFromList that remains `may_error=true`?**
    `setfromlist-broad-element-stays-erroring`.
25. **An unsupported-equality SetFromList that remains `may_error=true`?**
    `setfromlist-unsupported-kind-runtime-equality`.
26. **A real runtime EQUALITY failure that remains?** Yes -- `{CORE
    SEMANTIC EQUALITY}`, pinned directly by the same test, using a
    two-element Block-kind list to force an actual comparison (see
    "Ensuring the runtime failure is actually exercised").
27. **Does its caller still propagate the Error completion correctly?**
    Yes -- `setfromlist-error-propagation-control` confirms the caller of
    a genuinely-fallible instance keeps `may_error=true`.
28. **What happens for `List[never]`?** Documented above ("List[never]
    audit"): stays plain `setfromlist`, no crash, no misclassification, no
    dedicated optimization.

## Required scope questions

29. **Was SetContains changed?** No, apart from being consulted (read-only)
    by the same `NativeCallOp` proc -- confirmed by `git diff` showing no
    hunk inside the `equality-set` switch arm.
30. **Was `IsEqualityTotal` broadened?** No -- `hir/types.tcl` has zero
    diff.
31. **Was SetFromList representation changed?** No.
32. **Was the runtime helper changed?** No -- `rt_set_from_list` has zero
    diff.
33. **Was allocation behavior changed?** No -- allocation counts/bytes
    identical in both measured workloads.
34. **Was `byte::set` source changed?** No -- `lib/byte.bot` has zero diff.
35. **Was checked Byte construction optimized?** No -- `byte::from_int`
    has zero diff, and `byte::set` still raises the real range error.
36. **Was `char::codepoint` optimized?** No.
37. **Was listloop changed?** No.
38. **Was ABI/Bool representation changed?** No.
39. **Was specialization changed?** No -- `hir/specialize.tcl` has zero
    diff (confirmed: only `native/`-side files and tests changed).
40. **Was any frozen `.bot`/`.ir` workload changed?** No.

## Stop condition reached

All twelve conditions of spec section 52 hold:

1. `SetFromList`'s dedup `EQUALITY` failure mode is confirmed (by direct
   source inspection of `rt_set_from_list`, not analogy) to arise from the
   identical ordinary-equality semantics (`equal`) M3 already modeled for
   `SetContains`.
2. `List[T]` with `IsEqualityTotal(T)` lowers to a non-erroring
   `SetFromListTotal` operation instance, confirmed by the positive
   fixtures and the real `byte::set` trace.
3. Generic/broad/unsupported `SetFromList` remains potentially erroring,
   confirmed by two dedicated negative fixtures.
4. A genuine runtime `EQUALITY` construction failure remains intact,
   confirmed by a dedicated two-element Block-kind fixture.
5. The equality-total operation still has `may_gc=true` (construction
   allocates), confirmed directly on the same call edge as its own
   `may_error=false`.
6. Generic and refined forms retain identical runtime set semantics and
   use the same helper (`rt_set_from_list`, unmodified), confirmed both
   statically and dynamically (objdump).
7. No allocation, representation, fusion, constant-folding, ABI, source,
   or specialization work was bundled in (confirmed by `git diff --stat`
   and the "Required scope questions" above).
8. The real `byte::set` path was re-measured without changing its source
   (`lib/byte.bot` has zero diff), and its own aggregate `may_error`
   outcome was reported honestly (still `true`, via `byte::from_int`) --
   not assumed to have become `false`.
9. Checked `UnicodeChar -> Byte` failure behavior remains intact
   (`byte::set(['Ā'])` still raises the real error, all four backends).
10. Full plain (2156/2156) and Rust (60/60) regressions pass; GC-stress
    recorded in the addendum below.
11. The FINAL SEMANTIC SOURCE FENCE remains intact (`hir/types.tcl` zero
    diff, no `.bot`/`.ir`/`.hir` diff).
12. A fresh post-M4 generated-code re-census identifies two next-milestone
    candidates from measured evidence (checked-domain-construction
    call-specific proof; family 1b), not from visual conspicuousness
    (explicitly declining to recommend `repeat_uri`/`esc_from`'s own
    machinery, or the still-visible tagged-Bool `cmp`, merely for looking
    large).
