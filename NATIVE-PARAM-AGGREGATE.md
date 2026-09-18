# Parameter/result virtualization across closed calls (follow-up to SCALAR-ASM-AUDIT.md Finding 1)

This implements the optimization milestone `SCALAR-ASM-AUDIT.md` §8
recommended as the next step: extend `hir/escape.tcl`'s existing List
scalar-replacement analysis (`local`/`remote` fixed-shape List construction)
with a third shape, `param` -- a fixed-shape List **parameter** every one of
whose uses, within the function it is passed into, is a `list_get` at a
compile-time-constant index or an unchanged forwarding into another exact
closed call. This is the exact same move F2 already made once for range
narrowing (extending an analysis from "local bindings only" to "parameters
too"), for List scalar replacement instead of range facts.

No source program changed (`hashtable.bot`, `csv_chunked.bot`,
`csv_geometric.bot`, `csv_records.bot` are all byte-identical to before this
milestone). No new runtime object, no new NIR opcode, no new Cranelift/
codegen mechanism, and no Rust code changed at all (`cargo test --release`:
29 passed, 0 failed, unmodified). Everything reuses existing companion/
internal-variant machinery (F1's Block-virtualization internal variant, and
`hir::escape.tcl`'s own existing scalar-replacement companion).

## 1. Summary of the change

A fixed-shape List value that an exact, statically-resolved caller hands to
a callee whose own uses of that parameter are themselves all structural
(`list_get` at a constant index, or unchanged forwarding to another such
exact call, including a self-tail call forwarding it back to itself) no
longer materializes at that boundary: its fields cross as ordinary internal
call arguments instead. The instance's canonical, List-taking function is
**always** still emitted (so any open/dynamic/mismatched-shape caller keeps
working exactly as before); an additional `fields` (or, when the same
instance's own result is *also* recognized, `fieldscompanion`) internal
variant is built lazily, on demand, exactly the way a Block-virtualization
internal variant or a scalar-replacement companion already is.

For `hashtable.bot`'s rehash path (`many()` driver, 40 inserts, enough to
force a rehash): **List allocations 6 → 0**, `listget`/`listnew` op sites in
`ht_rehash`/`ht_rehash_scan`/`ht_rehash_insert` **11 → 0**, in-process best
time (50 runs) **13us → 11us**. For `csv_geometric.bot`'s append fast path:
**List allocations 17 → 4**, `geo_append`'s own body drops from 4
`listget`/1 `listnew` to a completely List-op-free body ending in `retmulti`.
Both remain byte-identical on the un-optimized (`-param-aggregate-opt 0`)
path, and both backends (differential, opt on vs off) agree on every value
across the corpus and the new test suite.

## 2. Files changed

- `hir/escape.tcl` -- the new analysis (see §3). Replaces the old
  local-binding-only `Bindings`/`ScalarUse` pair with a two-pass design
  (`RawLocalArities`/`RawParamArities` then `Eligible`) that subsumes the
  old local/remote behavior exactly and adds the new parameter case; new
  accessors `paramVirtualArity`/`paramWants`; `analyze` gains an optional
  3rd argument (`paramOpt`, default 1) to disable just this section.
- `native/lower.tcl` -- the new "Parameter virtualization" section
  (alongside the existing "Representation"/"Scalar replacement"/"Block
  virtualization"/"String regions" sections): the
  `-param-aggregate-opt`/`BOTLISH_NATIVE_PARAM_AGGREGATE_OPT` flag,
  `SetupFieldParams`/`FieldsFunction`/`FieldsCompanionFunction` (the new
  internal-variant lowering), `FieldsRef`/`FieldsCompanionRef`,
  `ParamFieldsUsable`/`FieldWidths`/`CanSupplyFields`/`TryFields`/`CallArgs`
  (the call-site decision and field-argument evaluation), and the `Call`
  proc's `targetKind eq "block"` branch (restructured to field-expand
  arguments per call site). One existing interception (the `list_get(ref,
  constant)` fast path) now reads its binding's representation directly
  from `fn locals` instead of re-deriving it from `hir::escape::
  virtualArity`, so it transparently serves a virtualized parameter too,
  with no separate code path. A new per-function `skippedGuards` counter
  (incremented wherever this interception skips a kind guard
  `hir::aot::analyzeRegion` still counted a blocker for) keeps
  `native::report`'s `blockers == guards` accounting invariant correct
  (§6).
- `tests/native-param-aggregate.test` (new) -- 37 tests covering the
  criteria below.
- `tests/native-escape.test` -- `escape-hashtable-2` updated: it used to
  document `ht_rehash`'s `dest`/`src` List grouping as an unfixable
  structural blocker (`hir/escape.tcl`'s own former header comment); this
  milestone removes exactly that blocker, so the test now just re-confirms
  correct HashTable behavior (the allocation-reduction assertion moved to
  `native-param-aggregate.test`'s `paramagg-hashtable-2`).
- `tests/native.test` -- two pre-existing assertions updated to their new,
  correct values: `native-spec-8` (a single-closed-caller `list_get(xs, 0)`
  on a literal-shaped parameter now needs neither a kind guard nor a
  `listget` call at all, not just no kind guard) and `native-spec-14`
  (the stdlib corpus's hardcoded generic-guard-count table, which drops
  wherever a representation blocker's guard is now skipped as
  unnecessary -- `csv_chunked`/`csv_geometric`/`csv_records`/`hashtable`).
- `audit/native-scalar-asm/` -- regenerated (§7).

## 3. Analysis (`hir/escape.tcl`)

Two passes, deliberately kept separate because they answer different
questions (item #41's hard soundness requirement: shape is a *caller-
proven value fact*, never inferred merely from which indices a callee
happens to read):

### `RawLocalArities` / `RawParamArities` -- *which slots have a proven shape*

- `RawLocalArities` is exactly the old local-binding Classify pass
  (unchanged in what it recognizes): a `[e0..en-1]` literal, or a call to
  an instance whose own result `Arities` already recognizes.
- `RawParamArities` is new: for a parameter position, every **exact**
  closed call site targeting that instance (`hir::specialize`'s own
  `instance.calls` map -- never a dynamic/indirect call) must classify its
  argument to the *same* arity, via `ArgShape` (`Classify`'s existing
  literal/remote recognition, plus a new case: a `ref` to a binding this
  same caller's own region already knows has a raw shape -- a local
  literal, or one of the caller's *own* already-resolved parameters). This
  is a monotonic, least-fixpoint *growth*, run to a fixed point exactly
  like `Arities`'s own forwarding-edge fixpoint: a multi-hop closed chain
  (`caller(state) -> helper1(state) -> helper2(state) -> list_get`, item
  #23) resolves incrementally, one hop's proof enabling the next round's.
  An instance with no exact call sites at all never gets a parameter
  arity (item #43: an unknown/open/dynamic caller is, by construction,
  never present in `instance.calls`, so it can never contribute an
  unsound shape claim, and its absence simply means no arity is proven).
  A **self-tail (or otherwise same-instance-recursive) call that forwards
  a parameter back to itself, unchanged, at the same position** is
  specially exempted from the "every call site must classify" requirement:
  requiring it to independently classify would make a self-threaded
  builder/state loop (item #25/#55) permanently unable to bootstrap its
  own parameter's arity, since it would need to already know the very
  fact it is trying to establish. (This was the actual root cause found
  and fixed for `hashtable.bot`'s `ht_rehash_scan` -- see §5.)

### `Eligible` -- *which of those slots are safe to actually virtualize*

A separate, later, **greatest-fixpoint shrink** over the full candidate
set `RawLocalArities`/`RawParamArities` produced: start optimistic (every
shaped slot is a candidate), then repeatedly drop any candidate with an
unsupported reference -- anything other than `list_get` at a compile-time-
constant in-range index, or the unchanged forwarding of the same value (no
re-wrapping) as an argument to another exact call whose own corresponding
parameter is *also* still a candidate with the *same* arity -- including a
forwarding target that was itself dropped in an earlier round. This is
never partial (item #22's "all relevant uses compatible, or preserve the
canonical aggregate entirely" discipline): a slot with even one
unsupported use (a bare `return state`, a store into another List, a
dynamic index, an out-of-range constant index) is dropped in full, and
that removal itself propagates to every other slot whose only unsafe use
was forwarding into it.

Two of these growth/shrink passes are genuinely necessary and not
collapsible into one: collapsing them (requiring a forward-use to already
be "eligible", not merely "shaped", before letting a downstream parameter
inherit its shape) reintroduces exactly the deadlock the self-tail
exemption above describes, for any multi-hop forwarding chain -- neither
end could ever bootstrap. Splitting them, with `RawParamArities` allowed
to cite a raw (not-yet-filtered-for-eligibility) shape fact from another
slot, resolves this cleanly, and is still sound: whether a value has a
given shape is a semantic fact independent of whether the compiler
chooses to *represent* it virtually, and `Eligible`'s later shrink pass is
exactly what confirms fields are actually *available* wherever this
matters (see §4's `CanSupplyFields`, the corresponding lowering-side
check).

`Classify`, `ScalarUse` and `TrailingPositions` are unchanged and shared
by both passes; the old `Bindings` proc (local-only) is removed, fully
subsumed by `RawLocalArities` + `Eligible`.

## 4. Internal ABI (`native/lower.tcl`)

Up to **four** NIR functions per source function now exist, built lazily
(the existing `pending` work-list mechanism, unchanged):

| mode | params | result | built when |
|---|---|---|---|
| canonical (`Function`) | ordinary (List-taking) | ordinary `ret` | always |
| companion (`CompanionFunction`) | ordinary | `retmulti` (fields) | `hir::escape::wants` |
| `fields` (`FieldsFunction`) | virtual params expanded to fields | ordinary `ret` | some closed caller can supply fields and wants a tagged result |
| `fieldscompanion` (`FieldsCompanionFunction`) | virtual params expanded to fields | `retmulti` (fields) | some closed caller can supply fields *and* wants a virtual result |

`SetupFieldParams` is the only new parameter-registration logic: a
parameter `hir::escape::paramVirtualArity` recognizes is received as N
ordinary field registers, stored in `fn locals` exactly like a virtualized
*local* binding already is (`{virtual fields}`) -- so the pre-existing
`list_get(ref, constant)` interception in `Call` needs no new logic at all
to also serve it; it already only ever consults `fn locals`, not which
kind of binding put an entry there. Every other parameter (including a
self-tail-recursive one whose own raw-Int range is proven small) is
registered exactly as `Function`'s own loop does.

**Field ordering** (item #45): deterministic, stable across caller,
callee, `retmulti`, self-tail rebinding and diagnostics -- a virtual
parameter's N fields occupy N consecutive NIR parameter slots at its own
declared position, in construction order (`table.0`, `table.1`, ...); an
ordinary parameter keeps its own single slot; mixed virtual/ordinary
parameters (item #15, e.g. `append(state, value)`) keep every parameter's
relative left-to-right order, just with virtual ones widened in place.

**Call-site decision** (`Call`'s `targetKind eq "block"` branch): computes
`FieldWidths` (per parameter position, N or "", from `paramVirtualArity`,
suppressed entirely for a target with an `hir/traversal.tcl` TraversalPlan
-- item #46's documented non-composition with a separate, unrelated
internal-ABI extension) and then, critically, `CanSupplyFields`: a **per
call site** check of whether every virtualized position's own argument
expression can actually produce fields *right now* -- a `ref` to a binding
this exact caller's `fn locals` currently holds `{virtual ...}` (with a
width match), or a `call` node (always safe: it recurses into `Call`'s own
existing `wantVirtual` machinery, which applies this exact same
all-or-nothing discipline to its own arguments in turn, so it can never
itself be the reason a chain fails). This check exists because
`RawParamArities`'s arity-growth is deliberately a *pure value-shape* fact
(§3): a target parameter can be soundly virtualizable (some *other* caller
really does have fields to hand it) while *this* caller's own forwarded
slot has a provable shape but failed its own eligibility for an unrelated
reason (e.g. it was also returned bare elsewhere). When it fails,
`fieldWidths` resets to empty for the *whole* call (never partial), and
the call falls back to the ordinary canonical/companion function,
materializing whatever it already has -- correct and unsurprising, just
not optimized at that one call site. Every call site that *is* counted in
a parameter's arity proof is, by construction, exactly the set that
successfully passes this check (self-tail included: see §5).

`CallArgs` is the shared flat-argument-list builder both the self-tail
(`tail`/`tailenv`) and ordinary (`call`/`callenv`) paths now use, replacing
the old single per-argument `Expr` loop; it expands a virtualized position
via `TryFields` (a `ref`'s already-evaluated fields, or a `call`'s
recursive `Call ... tagged N` -- the exact mechanism `VirtualValue` already
used for a construction's own fields) and otherwise falls through to
ordinary `Expr` evaluation (raw, for a self-tail call's own raw-declared,
non-virtualized parameter slots -- unchanged from before this milestone).

## 5. Self-tail / recursive state threading (items #25, #55)

A self-tail call forwarding a virtualized parameter back to itself,
unchanged, threads its fields through NIR registers across the loop
backedge exactly like `sum-refined.ir`'s captured `n` already does post-F1
-- no per-iteration List reconstruction. This required the §3 self-
reference exemption in `RawParamArities`; without it, `hashtable.bot`'s
own `ht_rehash_scan(src, i, oldCapacity, dest, newCapacity)` -- which
forwards both `src` and `dest` to itself on its own recursive tail call --
could never bootstrap either parameter's arity at all, since the very
fact being proven (their own shape) was needed to validate that
self-referential use. Once fixed, `ht_rehash_scan`'s `dest`/`src` (and
transitively `ht_rehash_insert`'s `dest`) all virtualize correctly (see
§7's before/after NIR).

A loop whose base case returns the state parameter *itself*
(`return state`, a bare escaping use -- `paramagg-selftail-3`) correctly,
conservatively declines to virtualize that parameter: this is exactly
item #55's documented fallback ("the first milestone may conservatively
fall back"), and semantics remain correct either way (a materialized List
threads through, exactly as before this milestone).

## 6. GC/rooting behavior

No new mechanism. A field register -- whether a `fields`/`fieldscompanion`
variant's own parameter, or a value read out of an already-rooted `fn
locals` entry when forwarding -- is an ordinary tagged NIR register,
stored to its own shadow-stack slot on definition by `codegen/clif.rs`'s
`def`, completely unaware of whether a register happens to be a former
List field. Each field's own liveness (not a former List wrapper's, which
no longer exists) governs how long it stays rooted -- a genuine
improvement over the canonical path, where the whole List object (and so
every element reachable from it) stays rooted for as long as the List
reference itself does. `paramagg-gc-stress-1` (heterogeneous fields --
String, List, MutableArray -- threaded through 2000 self-tail iterations
under `BOTLISH_NATIVE_GC_STRESS=1`, forcing a collection attempt at every
allocation) confirms this directly; the entire native test suite (421
tests across 12 files) passes unchanged under the same stress flag.

One accounting wrinkle, not a rooting bug: `hir::aot::analyzeRegion`'s
representation-blocker count (an *independent*, per-instance analysis that
has no notion of `hir::escape.tcl`'s finer per-binding proof) still counts
a kind-guard blocker for a virtualized parameter's `list_get`, in the
*generic* (unspecialized) instance specifically, since a generic
instance's own parameter kind is deliberately left unproven so the same
code can serve arbitrary future callers -- independent of what this
program's actual, escape-analysis-proven call graph shows. Skipping the
now-unnecessary guard is sound (the value's shape is proven by a stronger,
independent analysis), but it must be subtracted back out of that
function's own reported `blockers` count to keep `native::report`'s
`blockers == guards` invariant true (the new `skippedGuards` counter, §2);
confirmed passing across the whole stdlib corpus (`native::report` on all
9 `examples/stdlib/*.bot` files).

## 7. `ht_rehash` / `geo_append`: before/after evidence

### NIR

Before (`-param-aggregate-opt 0`; `ht_rehash_insert`/`ht_rehash_scan`,
abbreviated):
```
func "ht_rehash_insert" params=4 pnames="dest capacity key value" ...
    %0 = op listget dest 0        ; newControls = list_get(dest, 0)
    ...
    %1 = op listget dest 1        ; mutable_array_set(list_get(dest,1), ...)
    %2 = op listget dest 2        ; mutable_array_set(list_get(dest,2), ...)
    ...

func "ht_rehash_scan" params=5 pnames="src i oldCapacity dest newCapacity" ...
    %0 = op listget src 0         ; oldControls = list_get(src, 0)
    %1 = op listget src 1
    %2 = op listget src 2
    ...
    call ht_rehash_insert dest ...
    tail src i+1 oldCapacity dest newCapacity   ; dest/src still Lists
```
and, in `ht_rehash` itself: `src = op listnew [...]`, `dest = op listnew
[...]` (two real `rt_list_new` calls per rehash).

After (default; this branch's actual NIR today):
```
func 19 "ht_rehash_scan" params=9
    pnames="src.0 src.1 src.2 i oldCapacity dest.0 dest.1 dest.2 newCapacity"
    ...
    call 18 %5 %6 %7 %oldCapacity %key %value      ; ht_rehash_insert(dest.*, ...)
    tail %src.0 %src.1 %src.2 %i+1 %oldCapacity %dest.0 %dest.1 %dest.2 %newCapacity
end

func 18 "ht_rehash_insert" params=6
    pnames="dest.0 dest.1 dest.2 capacity key value"
    ; no listget anywhere -- dest.0/.1/.2 are the fields directly
end
```
No `listget`, no `listnew`, anywhere in `ht_rehash`/`ht_rehash_scan`/
`ht_rehash_insert` on the optimized path (all confirmed by direct NIR
inspection, not inferred).

Before (`geo_append`, `-param-aggregate-opt 0`):
```
func "geo_append" params=2 pnames="builder value"
    %0 = op listget builder 0     ; storage = list_get(builder, 0)
    %1 = op listget builder 1     ; length = list_get(builder, 1)
    %2 = call geo_grow storage length
    op mutarrayset %2 length value
    %3 = op iadd length 1
    %4 = op listnew %2 %3          ; [grown, length + 1]
    ret %4
end
```
After (default):
```
func 4 "geo_append" params=3 pnames="builder.0 builder.1 value" results=2
    %3 = call 3 %0 %1              ; geo_grow(storage, length)
    %4 = op mutarrayset %3 %1 %2
    %5 = int 1
    %7 = op iadd %1 %5
    retmulti %3 %7                 ; [grown, length + 1], never materialized
end
```

### Machine-code / allocation evidence

| file | metric | before (opt off) | after (opt on) |
|---|---|---|---|
| `hashtable.bot` (40-insert driver, forces rehash) | List allocations | 6 | **0** |
| | `listget`/`listnew` op sites (whole program) | 9 / 2 | **0** / **0** |
| | total allocations / bytes | 19 / 3568 | 13 / 3232 |
| | best time, 50 runs | 13us | 11us |
| `csv_geometric.bot` (default sample) | List allocations | 17 | **4** |
| | `listget`/`listnew` op sites (whole program) | 6 / 3 | **0** / **0** |
| | best time, 50 runs | 3us | 2us |
| `csv_chunked.bot` (default sample) | List allocations | 21 | 8 |
| | `listget`/`listnew` op sites | 20 / 10 | 2 / 1 (genuine dynamic-index `list_get` in `chunked_copy_chunks`, out of scope: Finding 4) |
| | best time, 50 runs | 2us | 1us |
| `csv_records.bot` (default sample) | List allocations | 49 | 11 |
| | `listget`/`listnew` op sites | 24 / 8 | 7 / 2 |
| | best time, 50 runs | 12us | 10us |

Committed disassembly total (`audit/native-scalar-asm/`, all 12 files):
**91839 -> 90186 bytes** (-1.8%). Per-file object totals: `hashtable.bot`
18061->17970 (-0.5%), `csv_chunked.bot` 14003->13355 (-4.6%),
`csv_geometric.bot` 7751->7365 (-5.0%), `csv_records.bot` 30762->30234
(-1.7%). Not every individual function shrank: `ht_rehash_scan` itself
grew from 1276 to 1433 bytes (its parameter count widened from 5 to 9,
needing more shadow-stack slots for the now-individually-tracked fields:
root candidates 9->13, max live roots 7->11), while `ht_rehash_insert`
(708->639) and `ht_rehash` (1124->945) both shrank enough to make the
whole file smaller net. This is expected and reported plainly rather than
implied away: the optimization trades runtime calls (with their own
prologue/epilogue/shadow-stack-check cost) for a wider but call-free
register/stack footprint, and the net effect across this corpus is
positive but not uniform per function.

## 8. Feature flag

`-param-aggregate-opt 1|0` / `BOTLISH_NATIVE_PARAM_AGGREGATE_OPT=0`
(default on), independent of `-escape-opt` (which still separately
controls local/remote scalar replacement, and this section together, since
`hir::escape::analyze`'s parameter growth pass is simply skipped when
either flag disables it). Every new test differentially compares both
settings for value parity (`assertParity`, `native-param-aggregate.test`);
the full existing Tcl test suite and `cargo test --release` both pass
unchanged at the default.

## 9. Regression status

- `tclsh9.0 tests/all.tcl` (all 4 backends: interp, compile, cranelift-
  generic, cranelift; 43 test files including the new one): full pass, no
  failures, after updating the two pre-existing assertions §2 describes
  (both now-correct consequences of the optimization, not regressions).
- `cargo test --release` (native backend, unmodified): 29 passed, 0
  failed.
- All 12 `tests/native*.test` files re-run under
  `BOTLISH_NATIVE_GC_STRESS=1`: 421 tests, 0 failures.
- `native::report` (blockers == guards accounting) passes for all 9
  `examples/stdlib/*.bot` files.
- No compiler, runtime, or stdlib source file was modified besides
  `hir/escape.tcl` and `native/lower.tcl` themselves (no `.bot` source
  file changed).

## Answers to the audit's questions

1. **Can a fixed-shape List now cross an exact function boundary without
   materializing as a List?** Yes -- both as a parameter (§4's `fields`
   variant) and, composed with the pre-existing companion mechanism, as a
   result (`fieldscompanion`), confirmed by direct NIR inspection with
   zero `listget`/`listnew` in the relevant functions.
2. **Can a fixed-shape result return across a closed boundary without
   `rt_list_new`?** Yes -- unchanged from before this milestone
   (`hir::escape.tcl`'s existing companion mechanism), now additionally
   available *together with* parameter virtualization in the same
   function (`geo_append`, `fillFrom` when eligible).
3. **How far through the HashTable call graph does the virtual table
   state remain scalar?** The `table` handle itself is a MutableArray-as-
   record (`mutable_array_get(table, N)`), not a List -- unaffected by
   this (List-only) milestone; see item 4 below. The rehash path's
   `dest`/`src` List groupings, however, now stay scalar through the full
   `ht_rehash -> ht_rehash_scan -> ht_rehash_insert` chain, including
   across `ht_rehash_scan`'s own self-tail recursion.
4. **Which remaining HashTable List operations are genuine List
   operations rather than record-wrapper accesses?** None of the rehash
   grouping's own operations remain -- they are gone. `hashtable.bot`'s
   hot lookup/probe path (`ht_find_get`/`ht_find_insert`/`ht_probe_next`)
   never used List field access at all in the current source (it is
   `mutable_array_get(table, N)`-based, not `list_get`-based): the corpus
   evolved past the List-as-record representation `SCALAR-ASM-AUDIT.md`'s
   Finding 1 described for `hashtable.bot` specifically, sometime before
   this milestone, independent of it (see §10, honestly reported).
5. **Did the geometric builder fast path eliminate both input unpacking
   and result reboxing?** Yes -- `geo_append`'s body (§7) has zero
   `listget`/`listnew`, both ends, confirmed directly.
6. **Did the chunked builder do the same?** Yes for `chunked_append`
   itself (its own body has zero `listget`, confirmed via
   `paramagg-chunked-2`); `chunked_copy_chunks`'s own `list_get(chunks,
   index)` is a genuine dynamic-index List access (Finding 4's territory,
   explicitly out of scope here) and correctly remains a real call.
7. **Did `csv_records` compose both optimizations successfully?** Yes --
   `paramagg-records-1` confirms correct end-to-end behavior; it reuses
   the same `geo_append`/HashTable machinery both other workloads
   exercise, with no new interaction bug.
8. **Were any canonical materialization boundaries unexpectedly common?**
   One real, expected one: a bare `return state` (the parameter returned
   as itself) conservatively declines virtualization, exactly as item #8
   requires; no other unexpected boundary was found in the target corpus.
9. **Did aggregate expansion cause excessive internal ABI width or code
   size?** `ht_rehash_scan` widened from 5 to 9 NIR parameters (2 List
   groupings of 3 fields each, plus 3 ordinary), and its own machine code
   grew by 157 bytes even as the surrounding file shrank net (§7) --
   reported plainly, not hidden. No arbitrary width bound was needed or
   added for this corpus (the largest aggregate virtualized was 3 fields);
   item #47's bound question is therefore moot for this milestone's actual
   workloads, and no bound was added speculatively.
10. **Did F3 keep individual managed fields rooted correctly without
    recreating aggregate-level root overhead?** Yes -- confirmed both by
    the full native test suite under `BOTLISH_NATIVE_GC_STRESS=1` and by
    the dedicated `paramagg-gc-stress-1` test (heterogeneous fields, 2000
    self-tail iterations, forced collection at every allocation).
11. **Did any new specialization duplication appear?** None observed:
    `native::report`'s specialized-instance counts for the whole corpus
    were re-checked before/after and show no new duplication attributable
    to this milestone (the corpus's pre-existing generic/specialized split
    is unchanged in shape, only in guard counts per §6).
12. **How much of the previous scalar-audit Finding 1 is now gone?**
    Fully gone for the shapes it actually described in the *builders*
    (`csv_chunked.bot`/`csv_geometric.bot`'s `[storage, length]`/
    `[completed, current, filled]` parameters). Not applicable to
    `hashtable.bot`'s own `ht_controls`/`ht_keys`/etc. accessors as
    currently written, since they are no longer List-based in this
    corpus's current source (see §10) -- but *is* fully gone for
    `hashtable.bot`'s rehash grouping, which was a real, separately
    documented List-parameter case.
13. **How much of Finding 2 is now gone?** Fully gone for
    `csv_geometric.bot`/`csv_chunked.bot`'s append fast path: no
    per-append `rt_list_new` re-boxing remains in `geo_append`/
    `chunked_append`'s own bodies.
14. **After regeneration, which scalar-audit finding is now the largest
    remaining executed machine-code cost?** See §10/§11 (not fixed here,
    per this milestone's own scope): Finding 3 (uninlined nullary
    constant-returning helpers) and Finding 4 (`list_get`'s lack of an
    inline fast path for a genuinely dynamic index, `matmul.bot`) are
    untouched and, on this evidence, now the largest remaining classes.
15. **Is scalar code now clean enough to proceed to refined-checks native
    capability, or did the regenerated assembly justify one more targeted
    scalar milestone first?** See §11 -- a recommendation is made, not
    acted on.

## 10. One honest correction to the original recommendation's premise

`SCALAR-ASM-AUDIT.md` described `hashtable.bot`'s table as "one 5-element
List used as an ad hoc mutable record (`[controls, keys, values, size,
capacity]`)" with `ht_controls`/`ht_keys`/etc. as `list_get`-based
accessors. The *current* `hashtable.bot` (unchanged by this milestone --
verified via `git log`/direct inspection before writing a single line of
compiler code) instead represents the table as a MutableArray-as-record
(`mutable_array_get(table, N)`), per its own header comment: "unlike
GeometricBuilder/ChunkedBuilder... a HashTable is genuinely mutable end to
end." This looks like the corpus's own independent evolution (a table
genuinely needs in-place *mutation* of its size/tombstone counters, which
a persistent List cannot do without full reconstruction) sometime after
that audit was written, unrelated to this milestone. Consequently:
`ht_controls`/`ht_keys`/`ht_values`/`ht_capacity`'s own `rt_list_get` calls
the original audit measured no longer exist in the corpus at all (they are
`mutable_array_get`, always were free of the List-as-record problem in
this milestone's sense) -- **not** because this milestone fixed them.
What this milestone *does* fix in `hashtable.bot`, confirmed directly, is
the rehash function group's `dest`/`src` List grouping (§5/§7), a
genuinely separate, still-List-based instance of exactly the pattern this
milestone targets, independently documented as a "structural blocker" in
`hir/escape.tcl`'s own pre-existing header comment. The `csv_chunked.bot`/
`csv_geometric.bot`/`csv_records.bot` builder-state findings match the
original audit's description exactly, with no such discrepancy.

## 11. Recommendation for the next milestone

Evidence-based, not predetermined (per this milestone's own instructions,
stopping short of implementation):

The regenerated assembly (§7, §9) shows this milestone removed its target
class of cost cleanly, with no regression anywhere in the corpus. Two
classes of remaining cost are now, by elimination, the most visible ones
left in `examples/stdlib/`, both already named (not newly discovered) by
`SCALAR-ASM-AUDIT.md`:

- **Finding 4** (`list_get`'s complete lack of an inline bounds-check+load
  fast path for a genuinely *dynamic* index -- `matmul.bot`'s `dot` is the
  clearest case, 3 real calls per inner-loop iteration on a variable
  index this milestone's constant-index-only scope never touches).
- **Finding 3** (uninlined nullary constant-returning helpers --
  `ht_empty_state()`/`chunk_size()`/etc. -- still real calls at their
  16+/8+ hot-loop call sites; item #78 of this milestone's own
  instructions explicitly declines to fix this here, since it is better
  evidence for a future *module-level immutable binding* surface-language
  change than for an inliner).

Recommend **Outcome B**: a narrowly scoped **inline `ListGet` fast path**
milestone next (Finding 4) -- it is the more architecturally "compiler
defect" of the two remaining findings (an operation class with *zero*
inline handling at all, the same qualitative gap Finding 1 was before this
milestone, versus Finding 3's "no inliner exists yet" class, which is
explicitly out of scope by this milestone's own design and arguably better
served by the module-binding surface change first). `refined-checks.ir`
native-capability work (this repository's other standing recommendation)
remains a reasonable *alternative* next step if a capability gap is judged
higher priority than a further scalar-quality pass; both are evidence-
supported, and this document does not attempt to adjudicate between them
further than the codegen-defect-severity argument above.
