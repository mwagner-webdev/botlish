# Typed MutableArray builder source refactor

> **Note (MUTABLE-ARRAY.md).** A MutableArray is a value now: the
> builder's grown storage is a logical copy of what it is given, and the
> HashTable this report mentions is a struct of four arrays every update
> returns.

## Outcome

The geometric mutable builder (the shared implementation in
`examples/stdlib/csv_geometric.bot` and its verbatim duplicate in
`csv_records.bot`) no longer uses raw `mutable_array_allocate` and no longer
packs `[storage, length]` into a List. Its storage is a typed
`MutableArray[T]` created with `mutarray::create`, seeded from the first real
element, and storage and length are threaded as two separate values. The
`geo_*` functions are ordinary untyped source: one `geo_append`, one
`geo_grow`, one `geo_new`, one `geo_finish`, no generic syntax, no per-type
copy. No compiler, runtime or native-lowering file changed.

Headline results, all measured (numbers below, artifacts in
`audit/typed-mutarray-builder-refactor/out/`):

* **Typed flow works where the values are precise.** On the real corpus source
  one untyped `geo_append` gives `List[str]`, `List[List[str]]` and
  `List[mutarray]` (pinned in `tests/typed-mutarray-builder.test`), and a
  wrong-typed value is rejected. In `csv_records` the row-table path is
  `MutableArray[mutarray]` -> `List[mutarray]` -> `mutarray`: all nine
  historical `ht_get`/`ht_size` consumers see `mutarray` in the semantic HIR
  (before: `any`).
* **The typed-primitive-plus-untyped-functions experiment is NOT fully
  sufficient.** An untyped function that receives typed storage as a parameter
  and appends a value of its own precise type is rejected at its *definition*
  (`csv_records`' `build_rows`). It needs one explicit concrete parameter
  contract, `outer: MutableArray[mutarray]` (not generic syntax, not on any
  `geo_*` function). See "Definition-level obstruction".
* **The strict-contract counterfactual does not improve**: 9 of 31 programs,
  **38 sites** (was 32). The nine row-table sites remain. A scratch experiment
  (not merged) shows why: with declared `MutableArray[mutarray]` contracts on
  the row path the nine sites and the new builder-boundary sites disappear
  (total 23). Semantic instances cannot rescue a definition.
* **Allocation**: one `MutableArray` allocation fewer per fields builder
  (`csv_geometric` 10,000 rows: 40,033 -> 30,027) and 240 KB fewer bytes; no
  `List` allocation changes (the pair was already virtualized natively); no
  extra allocation from the type-seeding default; GC cycles unchanged.
* **Codegen got bigger**: machine code +1,952 B (`csv_geometric`, 5,626 ->
  7,578) and +2,124 B (`csv_records`, 21,526 -> 23,650); 2 new emitted guards in
  `csv_geometric`; 13 more used codegen instances corpus-wide (245 -> 258),
  all closed. Timings are within noise (-5.8% .. +7.2%).
* **Two compiler-side sensitivities were found by dogfooding** (reported, not
  fixed, per the fence): the specializer is *definition-order sensitive* (a
  first draft that defined a caller before its callee produced 34 emitted
  functions and 18 guards for `csv_geometric`; the file's own callee-first
  convention gives 20 and 2), and a raw `mutarray` parameter joined with a
  typed `MutableArray[T]` constructor result widens to `any` in codegen
  instances (the source of the 2 remaining guards).

Success conditions (item 69):

| # | condition | result |
|---|---|---|
| 1 | no raw `mutable_array_allocate` for homogeneous element storage in the builder | yes: 0 (was 2 per file) |
| 2 | typed storage through `mutarray::create` | yes: 2 sites per file |
| 3 | storage and length not in a positional List on the targeted path | yes |
| 4 | one untyped append serves the real element types | yes (three element kinds, one definition each) |
| 5 | instances infer element-specific meanings without generic syntax | yes at call sites; **no** at an untyped intermediate function that appends its own precise value (one declared concrete contract needed) |
| 6 | freeze gives `List[T]` | yes (`List[mutarray]`; `List[str]`/`List[List[str]]` on real values; `list` = `List[any]` where the scan pair erased T) |
| 7 | row-table path is `List[mutarray]` | yes |
| 8 | nine sites statically `mutarray` | yes in the semantic HIR; still flagged by the strict counterfactual |
| 9 | no HashTable refactor | yes: the HashTable section is byte-identical |
| 10 | no compiler feature or optimization | yes |
| 11 | strict counterfactual rerun | yes: 38 sites |
| 12-15 | census, codegen/AOT, allocation/NIR/asm/runtime, compile time | done below |
| 16 | full regression and backend parity | see "Full regression" |
| 17 | new source fence | yes: `88e0166` |
| 18 | remaining failures attributable to records/contracts/dynamic boundaries rather than missing generic-function machinery | **partly**: the residue is products and contracts, plus one definition-level generic relation that only annotations (or a future generic-contract mechanism) discharge under the strict regime |

## Why this source fence was reopened

The previous milestone (`OPPORTUNISTIC-SEMANTIC-INSTANCES.md`, "Readiness for
typed-builder source refactor") showed by a scratch control that the machinery
should be sufficient once the storage is typed and not paired. This milestone
performs that refactor on the real source and measures it. Reopened for one
region only: the geometric builder and the callers whose calling convention
had to change. `tests/mutable-array-type.test`'s `mat-fence-1` (the old fence:
"nothing outside `lib/mutarray.bot` uses the new API") now names exactly
`csv_geometric.bot` and `csv_records.bot`; `tmb-fence-1..3` pin what those two
files may use it for.

## Exact source scope

Canonical `.bot` files changed: `examples/stdlib/csv_geometric.bot`,
`examples/stdlib/csv_records.bot` (`csv_chunked.bot` has a different builder
and is untouched; `hashtable.bot` untouched). Functions that changed:

| function | change |
|---|---|
| `geo_new` | `()` -> `(first)`: `mutarray::create(1, first)` |
| `geo_grow` | `(storage, length)` -> `(storage, length, value)`: fresh array via `mutarray::create(new_capacity, value)` |
| `geo_append` | `(builder, value)` -> `(storage, length, value)`, returns the (possibly grown) storage |
| `geo_finish` | `(builder)` -> `(storage, length)` |
| `geo_new_capacity` | unchanged (growth policy unchanged) |
| `scan_record` | split: `scan_record(text, index)` scans the first field and starts the builder; new `scan_record_rest(text, stop, fields, count)` is the loop |
| `scan_records` | gains `count` |
| `csv_parse` | empty text returns `[]`; otherwise the first record starts the builder |
| `build_rows` (csv_records) | gains `count`; `outer: MutableArray[mutarray]` |
| `csv_records_generic` (csv_records) | `<= 1` records returns `[]`; the first row table starts the outer builder |

Not touched (item 3): scan pairs `[field, index]`, HashTable record storage
`[newControls, newKeys, newValues]`, test-selection `[name, dependencies]`,
`list::find`, loop and recursion style, annotations elsewhere, `csv_chunked`.
Harness changes forced by the source (no compiler): `corpus::compile` (a
module-aware text compile in `examples/stdlib/corpus.tcl`, because
`surface::compile` does not resolve `mutarray::create`, only
`surface::readProgramFile` does), the two `native/generate-*.tcl` scripts use
`readProgramFile`, the HIR round-trip test exempts programs with a module
reference in *code* (as `surface-samples.test` already documents), and
source-derived counts in `native.test`, `hir-specialize.test`,
`native-param-aggregate.test` were updated.

## Source before

```
fn geo_new():
    [mutable_array_allocate(0), 0]

fn geo_grow(storage, length):
    capacity = mutable_array_capacity(storage)
    if length < capacity:
        return storage

    new_capacity = geo_new_capacity(capacity, length)
    fresh = mutable_array_allocate(new_capacity)
    mutable_array_copy(fresh, 0, storage, 0, length)
    fresh

fn geo_append(builder, value):
    storage = list_get(builder, 0)
    length = list_get(builder, 1)
    grown = geo_grow(storage, length)
    mutable_array_set(grown, length, value)
    [grown, length + 1]

fn geo_finish(builder):
    storage = list_get(builder, 0)
    length = list_get(builder, 1)
    mutable_array_freeze(storage, length)
```

## Source after

```
fn geo_new(first):
    mutarray::create(1, first)

fn geo_grow(storage, length, value):
    capacity = mutable_array_capacity(storage)
    if length < capacity:
        return storage

    new_capacity = geo_new_capacity(capacity, length)
    fresh = mutarray::create(new_capacity, value)
    mutable_array_copy(fresh, 0, storage, 0, length)
    fresh

fn geo_append(storage, length, value):
    grown = geo_grow(storage, length, value)
    mutable_array_set(grown, length, value)
    grown

fn geo_finish(storage, length):
    mutable_array_freeze(storage, length)
```

and the callers thread `count` next to the storage (`geo_append(fields, count,
x)`, then `count + 1`), start each builder from its first element, and return
`[]` for the two inputs that have no first element.

## Typed initialization design

* **Empty builder initialization**: there is none. A builder is created by
  `geo_new(first)` from a real element. `csv_parse("")` returns `[]` without
  creating storage; `csv_records` of a header-only or empty CSV returns `[]`
  before any row builder exists. (The old `[mutable_array_allocate(0), 0]`
  handled emptiness inside the builder; the new design pushes the empty case to
  the two callers that can have it.)
* **What value establishes T**: the first appended element (`first`), and on
  growth the element being appended (`value`).
* **Runtime cost solely for typing**: none. `create(1, first)` *is* the
  builder's first storage: capacity 1, slot 0 already holds `first`, length 1.
  No dummy, no zero-capacity placeholder, no throwaway HashTable. (Measured:
  `tmb-alloc-1..4`: empty input allocates no MutableArray, one one-field record
  allocates exactly two.) The old design allocated a capacity-0 array and then a
  capacity-1 one for the first element; the new one allocates one, which is where
  the allocation delta comes from.
* **Growth**: `mutarray::create(new_capacity, value)`, then the existing typed
  `mutable_array_copy(fresh, 0, storage, 0, length)`. Capacity sequence is
  unchanged (1, 2, 4, ...; `length + 1` if doubling is not enough).
* **Default slots**: `create` fills *every* slot with `value`. Slots at `length`
  and beyond alias that value until overwritten; `geo_append` overwrites slot
  `length` at once and `freeze(length)` copies only the first `length`. Pinned:
  `tmb-alias-1..4` (after growth 1->2->4 the frozen list is exactly the appended
  elements; slot 3 really aliases `t2`; `list_get(frozen, 3)` is RANGE; a later
  append overwrites the default slot and an earlier frozen list is unaffected)
  and `tmb-copy-1` (growth copies exactly `[0, length)` over 1->2->4->8->16).
* The runtime cost that *does* exist: `create` writes every slot of every
  grown array (`2^(k+1) - 1` slot stores for a builder that reaches capacity
  `2^k`, e.g. 7 for a 4-field record, 63 for a 20-field one), through a real
  emitted function `mutarray::create<int, T>` (461 B). See "Constructor-default
  overhead".

## Why no generic syntax is needed

There is none in the source: `geo_*` carry no annotation, type variable or
per-type copy (`tmb-source-*-3` pins 0 annotations, 0 generic spellings, exactly
5 `geo_` functions per file). Semantic instances give each call its element
type from the argument types alone:

```
geo_append<MutableArray[str], int, str>           -> MutableArray[str]
geo_append<MutableArray[List[str]], int, List[str]> -> MutableArray[List[str]]
geo_append<MutableArray[mutarray], int, mutarray> -> MutableArray[mutarray]
```
(the first two on driver programs, the third in `csv_records`;
`tmb-types-1..5`). And the refactored `csv_records.bot` **cannot compile without
semantic instances**: with `hir::semantic::enabled 0` it is rejected
(`MutableArray[mutarray]` cannot enter an untyped `mutarray`-contract
parameter), while `csv_geometric` is accepted either way (its element type is
`any`). Output: `out/semantic-off.txt`. This is the second real-world
validation of the semantic layer: the source is only expressible because it
exists.

## Definition-level obstruction (the stop-condition report, item 65)

*Source pattern.* An untyped function that receives typed storage as a
parameter and appends a value whose type it computes itself:

```
fn forward_precise(storage, length):
    geo_append(storage, length, "x")
forward_precise(geo_new("a"), 1)
```
`csv_records.bot`'s `build_rows` is exactly this (its `table` is a precise
`mutarray`).

*Existing facts.* `forward_precise`'s definition is analyzed with `storage` as
an untyped parameter whose inferred requirement is the raw `mutarray`. At the
call `geo_append(storage, length, "x")` the instance is
`geo_append<mutarray, int, str>`, and inside it `geo_grow` would copy a
raw-`mutarray` source of unknown elements into a `MutableArray[str]`.

*Rule that rejects it.* The typed-copy rule ("the source's element type is
unknown, so its slot values are not proven admissible to element type str").
The rejection is correct: a raw array could hold anything.

*Missing fact.* Nothing the *caller's definition* knows says its parameter is a
`MutableArray[str]`. The call instance is analysed under the concrete argument
types, but a definition is analysed generically, and "a semantic instance never
rescues a definition" (`OPPORTUNISTIC-SEMANTIC-INSTANCES.md`).

*Probes* (`out/experiments/probes-definition-obstruction.txt`; pinned as
`tmb-obstruction-1..3`):

| probe | result |
|---|---|
| A: untyped forwarder appends its own `"x"` | REJECT at the forwarder's definition |
| B: forwarder takes `value` as a parameter (`any` inside) | accepted; `List[str]` and `List[List[str]]` at two calls |
| C: `storage: MutableArray[str]` declared | accepted; `List[str]` |
| D: forwarder that only `mutable_array_set`s | accepted |

Only concrete declared contracts (probe C), never generics, get past A. That is
why `build_rows` declares `outer: MutableArray[mutarray]`. The field/record
builders do not need it: the values they append come out of the positional scan
pair as `any` (probe B's shape), so their storage is `MutableArray[any]`, which
accepts anything. I did not add any compiler rule (stop condition honoured).

## Why row HashTables remain raw mutarray

A row table is heterogeneous mutable storage (`[controls, keys, values, size,
tombstones]`: an `int`-state array, key and value arrays, two counters). It is
still `mutable_array_allocate(5)` with 11 heterogeneous slot writes
(`tmb-fence-3`); `MutableArray[T]` would be a lie for it. The outer builder is
typed, the table is not: `row_table(...)` is `mutarray`, the rows storage is
`MutableArray[mutarray]`, the frozen rows are `List[mutarray]` and
`list_get(rows, i)` is `mutarray`, which is all `ht_get`/`ht_size` need. The
whole HashTable section of `csv_records.bot` is byte-identical to the fence
commit.

## Semantic type flow

Real programs, semantic HIR (`out/trace-after.txt`, `out/typedsites-after.txt`):

| expression | before | after |
|---|---|---|
| `geo_new(...)` result | `list` | `MutableArray[any]` (fields, records); `MutableArray[mutarray]` (rows) |
| `geo_append(...)` | `list` | `MutableArray[any]` / `MutableArray[mutarray]` |
| `geo_finish(...)` | `list` | `list` (= `List[any]`) / `List[mutarray]` |
| `build_rows`, `csv_records_generic`, `csv_records`, `csv_records_presized` | `list` | `List[mutarray]` |
| `row_table`, `row_fill` | `any` (call site) | `mutarray` |
| `rows`, `presized_rows` | `list` | `List[mutarray]` |
| `first`, `second`, `presized_first` | `any` | `mutarray` |
| `csv_parse`, `scan_records` | `list` | `list` (unchanged) |

## String builder flow

Real fields path: `value = list_get(scanned, 0)` where `scanned =
scan_field(...)` is the positional pair `[field, index]`. The pair erases
`str`, so `value : any`, storage `MutableArray[any]`, freeze `list`. **The T
is lost at the scan pair, not at the builder.** On a real string the same
untyped source gives the ideal chain (driver programs on the real corpus
source):

```
geo_new("a")                                  : MutableArray[str]
geo_append(geo_new("a"), 1, "b")              : MutableArray[str]
geo_finish(geo_append(geo_new("a"), 1, "b"), 2) : List[str]
```

## Record builder flow

Records path: `value = list_get(scanned, 0)` where `scanned = scan_record(...)`
returns `[fields, stop]`, another positional pair; `value : any`, so
`MutableArray[any]` -> `list`. **It is not `List[List[str]]`**: the source
boundary is the scan pair (item 19). Direct drivers give
`geo_new(["x"]) : MutableArray[List[str]]` and `List[List[str]]` after two
appends (`tmb-types-2`). The scan pair was deliberately not touched.

## Row-table builder flow

```
row_table(...)                       mutarray
geo_new(first)                       MutableArray[mutarray]    (instance geo_new<mutarray>)
geo_append(outer, count, table)      MutableArray[mutarray]    (instance geo_append<MutableArray[mutarray], int, mutarray>)
geo_finish(outer, count)             List[mutarray]
build_rows / csv_records_generic     List[mutarray]
rows = csv_records(...)              List[mutarray]
first = list_get(rows, 0)            mutarray
ht_get(first, ...), ht_size(first)   accepted; result any (raw slots)
```

## Semantic instance census before/after

`audit/.../tools/census.tcl` on the 17-program canonical corpus, fence
`0969a30` vs `88e0166`:

| | before | after |
|---|---|---|
| exact-block call requests considered | 1665 | 1715 |
| trivial (not an instance) | 592 | 578 |
| cache hits | 821 | 869 |
| semantic instances created / valid | 252 / 252 | 268 / 268 |
| invalid / declined | 0 / 0 | 0 / 0 |
| recursive / SCC participants | 91 | 95 |
| functions with more than one instance | 64 | 69 |
| maximum instances of one function | 7 | 7 |
| body walks (sum of passes) | 343 | 363 |
| maximum passes per instance | 2 | 2 |
| walk rounds | 17 | 17 |
| retained analysis state (text size) | 435,061 B | 462,464 B |

Delta (+16 instances, +20 walks) is entirely `csv_geometric` (19 -> 24
instances, 27 -> 34 walks) and `csv_records` (68 -> 79, 91 -> 104); every other
program is identical. Sources of the new instances: the new `geo_new`,
`scan_record_rest`, and the typed builder instances per element kind. Nothing
failed or was declined. (The first draft, which defined `scan_record` before its
callee, needed 19 rounds instead of 17: forward calls force an extra
environment round.)

## Per-builder semantic instances

Real programs (semantic entry types -> semantic result; every one valid, 1 pass;
`out/census-after.txt`):

| function | semantic entry types | semantic result | codegen instance(s) executing it |
|---|---|---|---|
| `geo_new` (csv_records) | `<mutarray>` | `MutableArray[mutarray]` | `geo_new<mutarray>` |
| `geo_new` (csv_geometric/records) | via `scan_record`/`csv_parse` | `MutableArray[any]` | `geo_new<str>`, `geo_new<list>` |
| `geo_grow` | `<MutableArray[any], int, any>` | `MutableArray[any]` | `geo_grow<mutarray, int, str>`, `<.., list>` |
| | `<MutableArray[mutarray], int, mutarray>` and `<.., any, mutarray>` | `MutableArray[mutarray]` | `geo_grow<mutarray, int, mutarray>` |
| | `<mutarray, int, any>` (generic-body view) | `mutarray` | shared with the above |
| `geo_append` | `<MutableArray[any], int, any>` | `MutableArray[any]` | `geo_append<mutarray, int, str>`, `<.., list>` |
| | `<MutableArray[mutarray], int, mutarray>` and `<.., any, mutarray>` | `MutableArray[mutarray]` | `geo_append<mutarray, int, mutarray>` |
| | `<mutarray, int, any>` (generic-body view) | `mutarray` | shared |
| `geo_finish` | `<MutableArray[any], int>` | `list` | `geo_finish<mutarray, int>` (one shared) |
| | `<MutableArray[mutarray], int>` and `<.., any>` | `List[mutarray]` | same shared instance |
| `geo_new_capacity` | `<int, int>` | `int` | `geo_new_capacity<int, int>` |
| `mutarray::create` | not an instance (intrinsic container rule) | `MutableArray[typeof default]` | `mutarray::create<int, str|list|mutarray>` |

"Program call count" is 0 for most builder instances because the calls are
inside `scan_*`/`build_rows` (the census counts calls made by the program's own
top level). On driver programs the three element kinds `str`, `List[str]`,
`mutarray` give one instance each (see "Why no generic syntax"). No builder
instance fails.

## Exact-call precision census

`tools/calltypes.tcl` (semantic instances off vs on, per tree):

| | before | after |
|---|---|---|
| exact-block call sites | 403 | 414 |
| result more precise because of semantic instances | 62 | 72 |
| `csv_geometric` sites / improved | 25 / 0 | 30 / 0 |
| `csv_records` sites / improved | 123 / 2 | 129 / 12 |

`csv_records` improved sites after (`out/calltypes-diff-after.txt`):
`row_fill` (any -> mutarray), `row_table` x2 (any -> mutarray),
`geo_new` (`MutableArray[any]` -> `MutableArray[mutarray]`), `geo_append`
(`mutarray` -> `MutableArray[mutarray]`), `geo_finish` (`list` ->
`List[mutarray]`), `build_rows` x2, `csv_records_generic` x2, `csv_records`,
`csv_records_presized` (`list` -> `List[mutarray]`). `csv_geometric` gains
nothing from instances: its elements are `any`. All 15 other programs are
identical (the 62 previous improvements are intact; the +10 are all
`csv_records`).

## Nine row-table sites before/after

`csv_records.bot` `sample()`: line 452 -> 490 and 453 -> 491 (the file grew).
Argument = the `first`/`second`/`presized_first` variable at the call.

| site (was) | consumer | before arg type | after arg type (semantic HIR) | producer chain after | consumer result | strict counterfactual |
|---|---|---|---|---|---|---|
| 490:20 (452:20) | `ht_get(first, "name")` | any | mutarray | `list_get(List[mutarray], 0)` | any | still flagged |
| 490:45 (452:45) | `ht_get(presized_first, "name")` | any | mutarray | idem | any | still flagged |
| 490:81 (452:81) | `ht_size(first)` | any | mutarray | idem | any | still flagged |
| 490:99 (452:99) | `ht_size(presized_first)` | any | mutarray | idem | any | still flagged |
| 491:32 (453:32) | `ht_get(first, "name")` | any | mutarray | idem | any | still flagged |
| 491:55 (453:55) | `ht_get(first, "age")` | any | mutarray | idem | any | still flagged |
| 491:77 (453:77) | `ht_get(first, "city")` | any | mutarray | idem | any | still flagged |
| 491:100 (453:100) | `ht_get(second, "name")` | any | mutarray | idem | any | still flagged |
| 491:124 (453:124) | `ht_get(second, "city")` | any | mutarray | idem | any | still flagged |

Producer chain (after): `row_table -> mutarray`; `geo_append<MutableArray[mutarray],
int, mutarray> -> MutableArray[mutarray]`; `geo_finish -> List[mutarray]`;
`build_rows -> List[mutarray]`; `csv_records(...) -> List[mutarray]`;
`list_get(rows, i) -> mutarray` (`tools/nine-sites.tcl`, `out/trace-after.txt`).
The types reach codegen too: in the benchmarks' pipeline `ht_get`/`ht_find_get`
are now keyed `<mutarray, ...>` instead of `<any, ...>` and five guarded generic
HashTable accessor instances (`ht_controls/keys/values/size/capacity<generic>`)
plus one `row_fill` guard disappear (-6 emitted guards, `out/guards-csv_records-*.txt`).

The strict diagnostics still print `argument type: any` for these nine
arguments although the final semantic HIR says `mutarray`; the diagnostic pass
reads the type at the moment it runs, in a regime where the builder
definitions are already invalid. I did not root-cause that reading further.

## Strict counterfactual before/after

`variant-all-trusted.patch`, same experiment, `tools/strict-table.py`:

| | programs with diagnostics | sites |
|---|---|---|
| before (`0969a30`) | 9 of 31 | 32 |
| after (`88e0166`) | 9 of 31 | **38** |
| after, scratch: row-builder path declared `MutableArray[mutarray]` (not merged) | 9 of 31 | 23 |

The 12 sites in the other programs are identical before and after (lex-strategy
1, test-selection 4, uri-steady 1, csv 2, csv_chunked 2, hashtable 1, matmul 1);
no site moved because of shifted line numbers except in the two rewritten
files. Changes in the two files:

* gone: the four `[storage, length]` sites (`geo_append` `storage`/`length`
  x2 files) and csv_records' `headers` site;
* new: the two `stop` sites per file (`scan_record`, `scan_record_rest`): my
  split of `scan_record` passes the pair element `list_get(scanned, 1)` through
  a new parameter boundary instead of an arithmetic result; and one more
  `fields` site in csv_records (the second `row_table` call, for the first row);
* new: three definition-level builder sites in `build_rows` (six diagnostics):
  `MutableArray[mutarray]` flowing into `geo_finish`'s and `geo_grow`'s
  *inferred* raw `mutarray` parameters ("would lose its element contract",
  "cannot erase element contract"), and the `outer` contract;
* unchanged: the nine row-table consumers, now behind that builder relation.

Do all nine disappear? **No**, not under the strict regime, and not by
asserting: measured. They disappear only in the scratch run where the row path
carries declared contracts.

## Remaining strict sites classified (38)

| category | sites | where |
|---|---|---|
| struct/product boundary: scan pair `[field, index]` / `[record, index]` | 12 | csv 2, csv_chunked 2, csv_geometric 4, csv_records 4 |
| struct/product boundary: `[newControls, newKeys, newValues]` | 2 | hashtable, csv_records |
| struct/product boundary: `[name, dependencies]` (test-selection, with the `list::find` erasure) | 4 | test-selection |
| record-list element `any` from the pair-fed accumulator (`fields`) | 2 | csv_records |
| definition-level explicit contract | 3 | `total_valid` tokens, `esc_bytes` bytes, matmul `a_row` |
| **generic function relation at definition level (typed array into an inferred-raw contract)** | 6 diagnostics at 3 positions + 9 downstream consumers = 15 | csv_records `build_rows` and the nine |
| dynamic/unknown callable target | 0 | |
| raw heterogeneous MutableArray slot | 0 | |

The obsolete "generic function relation" category is *not* dropped: the
previous milestone solved it at call sites (the real regime), but the strict
all-trusted regime evaluates definitions, where it survives. That regime is a
counterfactual experiment, not the compiler's behaviour.

## Remaining annotation candidates

`total_valid` tokens, `select_affected` tests, `esc_bytes` bytes: **unchanged**;
their strict sites are byte-identical before and after (`lex-strategy` 79:63,
`test-selection` 57:16/61:26/71:15/68:13, `uri-steady` `b`). The builder
refactor does not touch them. One annotation was *added*: `build_rows`'
`outer: MutableArray[mutarray]` (see the obstruction). No annotation was added
to any builder function.

## Remaining struct boundaries

Positional products that still lose information after this milestone:

| product | where | effect |
|---|---|---|
| `[field, index]` | `scan_unquoted`, `scan_quoted`, `scan_field` results | `stop`/`index` and the appended field become `any`; fields builder is `MutableArray[any]` |
| `[fields, index]` (record, stop) | `scan_record_rest`/`scan_record` results | records builder `MutableArray[any]`; `csv_parse` stays `list`; `headers`/`fields` `any` |
| `[newControls, newKeys, newValues]` | `ht_rehash` `src`/`dest` | one strict site per file |
| `[name, dependencies]` | test-selection | `List[list]` with `any` fields |

`[storage, length]` is **removed from the target path** and drops out of the
census. This is the roadmap evidence the milestone was for: after typing the
builder, the CSV element type is limited by `[field, index]` and
`[fields, index]`, exactly as expected (item 34): `list` -> `List[List[str]]` is
*not* achieved on the real programs; the scan pair is the limiting factor.

## Allocation census

`native::allocationReport` summary, last run, same fixtures
(`out/workloads-compare.txt`, `tools/workloads.tcl`):

| workload | allocations | bytes | MutableArray allocs | List allocs | String allocs | GC cycles |
|---|---|---|---|---|---|---|
| csv_geometric 100 rows | 2,934 -> 2,828 | 131,179 -> 128,635 | 426 -> 320 | 106 -> 106 | 2,302 -> 2,302 | 0 -> 0 |
| csv_geometric 1,000 rows | 29,938 -> 28,932 | 1,337,129 -> 1,312,985 | 4,029 -> 3,023 | 1,006 -> 1,006 | 23,903 -> 23,903 | 1 -> 1 |
| csv_geometric 10,000 rows | 308,943 -> 298,937 | 13,894,039 -> 13,653,895 | 40,033 -> 30,027 | 10,006 -> 10,006 | 248,904 -> 248,904 | 7 -> 7 |
| csv_records 1,000x5 | 15,120 -> 14,107 | 915,429 -> 891,117 | 9,083 -> 8,070 | 1,014 -> 1,014 | 5,023 -> 5,023 | 0 -> 0 |
| csv_records 1,000x20 | 38,137 -> 37,124 | 3,463,046 -> 3,438,734 | 17,085 -> 16,072 | 1,014 -> 1,014 | 20,038 -> 20,038 | 2 -> 2 |
| csv_records presized 1,000x20 | 32,137 -> 31,124 | 2,743,046 -> 2,718,734 | 11,085 -> 10,072 | 1,014 -> 1,014 | 20,038 -> 20,038 | 2 -> 2 |
| csv_records 10,000x5 | 150,128 -> 140,115 | 9,354,141 -> 9,113,829 | 90,091 -> 80,078 | 10,014 -> 10,014 | 50,023 -> 50,023 | 3 -> 3 |

(-1 `MutableArray` per fields builder, one per record, plus one for the records
builder; `StringPlan` allocations unchanged too.) Every other kind is 0 before
and after.

## Constructor-default overhead

* **Allocations caused solely by the default**: 0. There is no dummy object;
  the default *is* the element being appended.
* **Bytes**: none extra; total bytes fall (-2.5 KB per 100 records, -240 KB at
  10,000 rows).
* **Execution**: `mutarray::create` runs once per builder creation and once per
  growth. Slot stores it adds: `2^(k+1) - 1` per builder reaching capacity
  `2^k` (computed from the growth policy, not separately instrumented): about
  7 per 4-field record, 63 per 20-field record, 32,767 for a 10,000-record
  builder. These are the only cost of seeding the type; they are the likely
  source of the small `csv_records` 1,000x20 slowdown below.
* `create` is a real emitted function (461 B x number of element kinds), not
  inlined.

## List pair allocation removal

The `[storage, length]` pair was **already virtualized natively** before the
refactor (`geo_append` was `params=3 results=2`, `retmulti`; `paramagg-geometric-2`),
so removing it saves no runtime List allocation: List allocations are
identical before and after in every workload. What it removes is source and
NIR structure (`csv_geometric`: `retmulti` statements 11 -> 9; `geo_append` no
multi-value result, one `call` + one `mutarrayset`), and the
`paramagg-geometric-2` pin changed from `{0 1}` to `{0 0}` accordingly. NIR ops
(`nir-all`, relifted pipeline): `listnew` 0 -> 1 (the new `return []`),
`listget` 0 -> 0 in `csv_geometric`; 2 -> 3 and 7 -> 8 in `csv_records` (one more
`list_get(records, 1)` site).

## NIR before/after

Pipeline: `native::buildProgramHir (hir::lower ...)` (as the asm audit), files
in `out/nir/`:

| | csv_geometric before | after | csv_records before | after |
|---|---|---|---|---|
| NIR functions | 15 | 20 | 55 | 63 |
| NIR lines | 312 | 415 | 1,108 | 1,270 |
| `mutarrayallocate` | 2 | 2 | 9 | 10 |
| `mutarrayset` | 2 | 4 | 22 | 25 |
| `mutarraycopy` | 1 | 2 | 1 | 3 |
| `mutarrayfreeze` | 1 | 1 | 1 | 1 |
| `mutarraycapacity` | 1 | 2 | 3 | 5 |
| `listnew` / `listget` | 0 / 0 | 1 / 0 | 2 / 7 | 3 / 8 |
| guards | 0 | 0 | 29 | 28 |
| direct `call` | 9 | 18 | 84 | 99 |
| `retmulti` | 11 | 9 | 12 | 9 |

(In the benchmarks' pipeline, HIR compiled directly, `csv_geometric` has 20
functions, 418 lines and **2 guards**, `csv_records` 57 / 1,227 / 26; the
difference to the relifted pipeline is the module information lost in the
relift. Both pipelines are in `tools/`.)

Representative before/after of the main append path:

```
before  func "geo_append" params=3 pnames="builder.0 builder.1 value" results=2
          %3 = call geo_grow %0 %1
          %4 = op mutarrayset %3 %1 %2
          %7 = op iadd %1 1
          retmulti %3 %7
after   func "geo_append" params=3 pnames="storage length value"      instance="mutarray, int, str"
          %3 = call geo_grow %0 %1 %2
          %4 = op mutarrayset %3 %1 %2
          ret %3
before  func "geo_finish" params=2 pnames="builder.0 builder.1": %2 = op mutarrayfreeze %0 %1; ret %2
after   func "geo_finish" params=2 pnames="storage length":       %2 = op mutarrayfreeze %0 %1; ret %2
before  func "geo_grow"   params=2:  ...  %7 = op mutarrayallocate %6   ...  mutarraycopy
after   func "geo_grow"   params=3:  ...  %8 = call mutarray::create %7 %2 ...  mutarraycopy
after   func "mutarray::create" params=2: mutarrayallocate, loop { mutarrayset %2 %5 %1 ; %5 += 1 }
```

Function parameter counts: `geo_new` 0 -> 1, `geo_grow` 2 -> 3, `geo_append` 3 -> 3
(previously the unpacked pair), `geo_finish` 2 -> 2, `mutarray::create` new (2),
`scan_record` 4 -> 2 + `scan_record_rest` 4, `scan_records` 4 -> 4, `build_rows`
6 -> 7.

## Machine code before/after

`native/generate-scalar-audit.tcl` (committed corpus `audit/native-scalar-asm`
regenerated): exactly two programs differ, the other 15 are byte-identical.

| | before | after |
|---|---|---|
| whole corpus (17 programs) | 76,966 B | **81,042 B** (+4,076) |
| `csv_geometric` | 5,626 B, 15 functions | **7,578 B**, 20 functions |
| `csv_records` | 21,526 B, 55 functions | **23,650 B**, 57 functions |

Affected functions (bytes): `geo_new` 78 -> 81 (x2 kinds; x3 in records);
`geo_grow` 381 -> 412 (x2/x3); `geo_append` 272 -> 279/278 (x2/x3);
`geo_finish` 81 -> 81; new `mutarray::create` 461 (x2/x3); `scan_record` 695 ->
`scan_record_rest` 783 + `scan_record` 215; `scan_records` 456 -> 488;
`csv_parse` 171 -> 325 (empty-input test and first-record scan); `build_rows`
528 -> 629; `csv_records_generic` 580 -> 698.

Runtime helper calls (`out/asm-helper-calls.txt`): `csv_geometric`
`rt_mutarray_set` 2 -> 4, `rt_mutarray_copy` 1 -> 2, `rt_mutarray_capacity` 1
-> 2, `rt_int_cmp` 5 -> 8, `rt_int_add` 13 -> 15, `rt_str_len` 3 -> 4,
`rt_list_new` 0 -> 1, **`rt_type_error` 0 -> 2** (the two guards);
`csv_records` `rt_type_error` 29 -> **26**, `rt_mutarray_get` 20 -> 16,
`rt_mutarray_set` 22 -> 25, `rt_mutarray_copy` 1 -> 3, `rt_mutarray_allocate` 9
-> 10, `rt_int_cmp` 12 -> 17, `rt_list_get` 7 -> 8. Why bigger: the builder now
exists once per value kind for four functions instead of one or two (`create`
is new, `geo_grow` and `geo_new` split by value kind), the empty-input and
first-element handling adds code, and `scan_record` became two functions.
Guards: added 2 (`csv_geometric`), 3 in `csv_records` (see the join gap below);
removed 6 in `csv_records` (typed rows reach the HashTable accessors). Byte
identity was explicitly not expected.

## Semantic-to-codegen mapping

Every typed builder semantic instance (`out/census-after.txt`,
"codegen relationship"):

| semantic instance | codegen instance executing it | shared? | inlined? |
|---|---|---|---|
| `geo_new<mutarray>` -> `MutableArray[mutarray]` | `geo_new<mutarray>` | own | no |
| `geo_grow<MutableArray[any], int, any>` | `geo_grow<mutarray, int, str>`, `<.., list>` | shared by value kind | no |
| `geo_grow<MutableArray[mutarray], int, mutarray>` | `geo_grow<mutarray, int, mutarray>` | own | no |
| `geo_append<MutableArray[any], int, any>` | `geo_append<mutarray, int, str>`, `<.., list>` | shared by value kind | no |
| `geo_append<MutableArray[mutarray], int, mutarray>` | `geo_append<mutarray, int, mutarray>` | own | no |
| `geo_finish<MutableArray[any]|MutableArray[mutarray], int>` | `geo_finish<mutarray, int>` | one shared for all | no |
| `mutarray::create` (intrinsic, no instance) | `mutarray::create<int, str|list|mutarray>` | per value kind | no |

Codegen keys follow the *value's representation kind* (`str`, `list`,
`mutarray`), never the element type argument: `KeyType(MutableArray[T]) =
mutarray` is unchanged. Semantically distinct element types that share a value
kind share the machine function; conversely `geo_grow`/`geo_new`/`create` are
now keyed by value kind because `value` is now a parameter of them (the old
`geo_append` was already keyed that way). That is a consequence of threading
the seed value, not of semantic-instance multiplicity. Verification that
semantic instances add no codegen instance: on the old source, semantic
instances on/off both give 245 used / 234 emitted; on the new source the
`csv_records` program is not accepted with instances off, so no on/off pair
exists (and `hir/semantic.tcl` calls nothing in `hir::specialize`).

## Codegen instance census

| | before | after |
|---|---|---|
| used codegen instances | 245 | 258 |
| emitted functions (lowered NIR) | 234 | 247 |
| semantic instances | 252 | 268 |
| semantic instances running through an emitted codegen instance | 180 | 193 |
| semantic instances sharing a codegen instance | 158 (66 codegen) | 168 (70 codegen) |
| inlined / no used call site | 7 / 11 | 7 / 11 |
| `csv_geometric` used / emitted | 14 / 15 | 19 / 20 |
| `csv_records` used / emitted | 58 / 55 | 66 / 63 |

`csv_geometric` instance-label change: removed `geo_new<generic>`,
`geo_grow<mutarray,int>`, `geo_append<list[mutarray,int],str|list>`,
`geo_finish<list[mutarray,int]>`, `scan_record<..>`, `scan_records<..>`; added
`mutarray::create<int,str|list>`, `geo_new<str|list>`,
`geo_grow<mutarray,int,str|list>`, `geo_append<mutarray,int,str|list>`,
`geo_finish<mutarray,int>`, `scan_record_rest<..>`, `scan_record<str,int>`,
`scan_records<..>` (`hir-specialize-corpus-1`: 25 blockers, 2 specialized
guards, 0 generic + 18 specialized instances; was 24, 0, 1 + 12). `csv_records`:
86 blockers, 26 guards, 6 generic + 53 specialized instances (was 84, 29, 12 +
45): the generic instances fell from 12 to 6.

Element-type multiplicity does not mechanically produce machine functions: the
three value kinds (`str`, `list`, `mutarray`) produced the same three
`geo_append` codegen instances before and after; only the functions that now
take `value` multiplied (`geo_grow` 1 -> 3, `geo_new` 1 -> 3, `create` 0 -> 3
in records).

## AOT classification

Used codegen instances (`hir::aot`, `out/aot-*.txt`): closed / guarded / open:
**200 / 41 / 4 -> 213 / 41 / 4**. All 13 new instances are closed. The
`<program>` classification is unchanged in both programs (`csv_geometric`:
closed / transitively closed; `csv_records`: closed / transitively guarded,
before and after). `hir-aot.test` (`hir::aot` explain) needed no change.

## Runtime timings

`native::measure`, best of 15 runs inside one process, three separate
processes per tree, same fixtures, specialized cranelift (JIT), machine idle;
`min / median of the three bests` (microseconds; `out/workloads-*`):

| workload | before | after | delta (min) |
|---|---|---|---|
| csv_geometric 100 rows | 297.3 / 298.6 | 298.3 / 301.9 | +0.3% |
| csv_geometric 1,000 rows | 4,232.8 / 4,263.0 | 4,258.0 / 4,281.5 | +0.6% |
| csv_geometric 10,000 rows | 58,603 / 59,417 | 55,229 / 56,378 | -5.8% |
| csv_records 1,000x5 | 2,752 / 2,766 | 2,808 / 2,842 | +2.0% |
| csv_records 1,000x20 | 12,581 / 12,722 | 13,485 / 13,560 | +7.2% |
| csv_records presized 1,000x20 | 11,079 / 11,145 | 11,393 / 11,669 | +2.8% |
| csv_records 10,000x5 | 36,201 / 36,797 | 36,110 / 36,867 | -0.3% |
| csv_records sample() | 19.4 / 19.6 | 19.3 / 19.4 | -0.7% |

Within about +/-7%: not interpreted beyond noise. `csv_records` 1,000x20
(twenty fields per record, so the largest per-record fill) is the only one with
a repeatable slowdown across all three runs, consistent with the slot-fill
cost above. Deterministic changes (allocation counts, NIR, code size) are the
result; the timing is not.

## Compile-time impact

Front-end (`surface::readProgramFile -strict 0`, 17 programs), median of 7
(runs 1-2) and 11 (runs 3-4), four interleaved before/after pairs,
`out/compiletime-*`, `out/compiletime-summary.txt`:

| | before | after |
|---|---|---|
| total (median of 4 runs) | 1,685.8 ms | 1,862.6 ms (+10.5%) |
| per run, before | 1,673 / 1,842 / 1,694 / 1,678 | |
| per run, after | | 1,834 / 1,974 / 1,793 / 1,891 |
| `csv_geometric` | 107.3 ms | 143.2 ms (+33%) |
| `csv_records` | 472.8 ms | 547.3 ms (+16%) |

Noise floor: unchanged-source programs drift up to +18% (`csv_chunked`,
`csv` +13%, `sum-refined` +30% on 9 ms) in the same runs, so about 110 of the
177 ms total delta is attributable to the two rewritten programs and the rest is
noise. Hotspot census: `csv_geometric` 24 instances (was 19), 34 body walks
(27), one verification per instance (24); `csv_records` 79 instances (68), 104
walks (91). Typed builder instances raise semantic-analysis cost about in
proportion to their count (+5 / +11 instances, +7 / +13 walks); they do not
introduce re-analysis loops (maximum passes stays 2, rounds stay 17). Compared
to the previous milestone's +48%, this refactor's incremental analysis cost is
small.

## GC stress

`BOTLISH_NATIVE_GC_STRESS=1` for the whole file (a forced collection at every
allocation site), `out/gc-stress.txt`: `typed-mutarray-builder.test` 64/64
(including `tmb-gc-1..3`: many-record parse, csv_records row tables with the
typed outer builder, and typed create/copy/freeze of Strings, Lists and
MutableArrays held only by the builder), `native-csv-records.test` 21/21,
`native-mutarray.test` 49/49, `mutable-array-type.test` 118/118,
`mutarray-construction.test` 76/76, `stdlib.test` 151/151 (cranelift on every
corpus case). No GC machinery was changed; the runtime representation of these
arrays is the same as before.

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl`, native backend built
(rustc 1.98.1), Tcl 9.0.1:

| | tests | passed | failed |
|---|---|---|---|
| fence `0969a30`, interp | 3,122 | 3,122 | 0 |
| fence `0969a30`, compile | 3,122 | 3,122 | 0 |
| `88e0166`, interp | 3,184 | 3,184 | 0 |
| `88e0166`, compile | 3,184 | 3,184 | 0 |

The Cranelift coverage embedded in `stdlib.test`, `native*.test` runs inside
both. New file: `tests/typed-mutarray-builder.test` (64 tests: source shape,
type flow for three element kinds, semantic instances, the obstruction,
growth boundaries against `csv`/`csv_geometric`/`csv_chunked` on every backend,
alias/copy correctness, allocation, GC stress, the new fence). Two `stdlib-hir-*`
round-trip tests are exempted for programs with module references in code (the
documented exemption in `surface-samples.test`).

## Benchmark parity

`bench/bench.tcl -runs 1` exits 0 (interp, compile, native agree on all 8
canonical programs; `out/bench-runs1.txt`). `bench/corpus.tcl -runs 1 csv
csv_geometric csv_chunked` exits 0 on every backend (`out/corpus-csv-runs1.txt`);
the corpus reports `csv_geometric` code 8,423 -> 7,625 B (generic vs
specialized), 16 -> 20 functions, 27 -> 2 guards. `stdlib-csv_geometric-*` and
`stdlib-csv_records-*` cases compare all four backends.

## New source fence

Commit `88e016636c33f79ce9d2af02c2c10be33c761366` (tree
`6df552ca8071447c7203bfa20f43dc272198dde7`), parent `0969a30`
(tree `b61eb41d6d645c16462e4765b71ec7346c7143c3`). Source diff:
`git diff 0969a30 88e0166 -- examples/stdlib/csv_geometric.bot
examples/stdlib/csv_records.bot` (144 insertions, 76 deletions); regenerated
audit artifacts are in the following commit, separately. All measurements
above are against this fence; the source was not tuned after measuring, with
one honest exception disclosed here: the first draft defined `scan_record`
*before* `scan_record_rest`, breaking the file's own callee-before-caller
convention. It measured 34 emitted functions and 18 guards for `csv_geometric`
(299 used / 283 emitted codegen instances corpus-wide, `out/draft1/`), which
turned out to be the specializer's sensitivity to forward references rather
than to typed arrays (`out/experiments/`; reordering alone gives 20 functions
and 0 guards in the relifted pipeline). I moved the helper before its caller
*before* the fence was committed, added a comment to that effect, and report
both numbers.

## Definition-order sensitivity (compiler-side finding, not fixed)

With `scan_record` defined before its callee `scan_record_rest`, the
specialization retained generic guarded instances of `csv_parse`,
`scan_record`, `scan_records`, `scan_record_rest` from `<program>` (8 generic
instances; `<any, any, str>` builder instances reachable from them) and the
corpus grew from 245 to 299 used codegen instances. The number of semantic
instances was identical either way (268, all valid); only how many call
sites *needed* an instance to be precise differed (78 vs 72, because with the
callee first the generic walk already types `scan_record*` as `list`).
Callee-first order: 0 generic instances. Recommendation: a later specialization milestone should make
retention independent of definition order (or diagnose it), under its own
fence.

## Join gap (compiler-side finding, not fixed)

The two remaining `csv_geometric` guards (three in `csv_records`) are
`geo_append<mutarray, int, str|list|mutarray>`: "the result of `geo_grow` has no
static kind". In a codegen instance `storage` enters as raw `mutarray` (the
`KeyType` projection) while `mutarray::create` returns `MutableArray[str]`; the
early-return join of the two widens to `any` (`out/experiments/join-gap-v*.bot`:
v0 early return `any`, v1 fresh only `MutableArray[str]`, v2 both raw
`mutarray`). Semantic instances keep both branches typed, so it does not show
up there. Fix belongs to the type algebra (`join(mutarray, MutableArray[T]) =
mutarray`) or to keeping the applied type in the key; not done here.

## Remaining source-level information losses

Measured, classified (item 64):

1. **True product/record values** (the dominant loss): `[field, index]`,
   `[fields, index]`, `[newControls, newKeys, newValues]`, `[name, dependencies]`
   (20 of 38 strict sites, and the reason CSV element types stay `any`). Only
   structs recover these.
2. **Definition-level contracts** (3 of 38, unchanged): `total_valid`
   `tokens`, `esc_bytes` `bytes`, matmul `a_row`; declared parameter types.
3. **A definition-level generic relation** (15 of 38 under the strict regime; 1
   real annotation in the fence): a typed `MutableArray[T]` passed through an
   untyped function that also appends its own precise value. Instances cannot
   discharge it; only a declared concrete contract can, or a future mechanism
   that lets a definition state "same element type in and out". This is the one
   loss that is *not* a product or an API contract, and it means the earlier
   claim "typed primitive data + untyped functions + opportunistic instances is
   enough" holds for calls and fails for intermediate definitions.
4. **Dynamic/open callable targets**: none in this path (0 sites).

## Recommended next milestone

In order of evidence:

1. **Structs / product types** (largest, cleanest). Removing `[field, index]`
   and `[fields, index]` is what turns `MutableArray[any]`/`list` into
   `MutableArray[str]`/`List[List[str]]` on the real CSV programs and removes the
   `stop`/`index` strict sites (12 of 38).
2. **A definition-level relation for typed arrays**, only if a struct milestone
   does not subsume it: decide between "declared concrete contracts on
   intermediate functions" (what this fence does, one annotation) and a
   generic-contract mechanism. The obstruction and its three probes are the
   requirements document.
3. **A codegen-shape milestone** under a new source fence: the join gap (2 + 3
   guards), definition-order independence of specialization, and
   `mutarray::create` (an emitted fill loop per value kind).
4. Harness: hoist `corpus::compile` into `surface::` so text programs can use
   library modules (found by this refactor; a `surface::compile` limitation).

## Answers to the required questions

**Source (58).** Changed builder functions: `geo_new`, `geo_grow`, `geo_append`,
`geo_finish` (and `scan_record` -> `scan_record` + `scan_record_rest`,
`scan_records`, `csv_parse`, and `build_rows`, `csv_records_generic` in
csv_records). Canonical files: `examples/stdlib/csv_geometric.bot`,
`examples/stdlib/csv_records.bot`. `[storage, length]` was removed by threading
`count` next to the storage through the callers. Empty builder initialization:
there is none; callers with an empty case return `[]`. T comes from the first
appended value. No runtime cost solely for typing. Growth: `mutarray::create(
new_capacity, value)` then the existing typed copy. Append is still one ordinary
untyped function: **yes**.

**Typing (59).** Storage types: `MutableArray[any]` (fields, records; the scan
pair erases T), `MutableArray[mutarray]` (rows); `MutableArray[str]` /
`MutableArray[List[str]]` on real values (drivers). String case:
`MutableArray[str]` only on real string values, not on the CSV path. Row-table
case: yes, `MutableArray[mutarray]`. Record-list case: `MutableArray[any]`,
freeze `list`; the boundary is `[fields, index]`. Freeze: `List[T]` where T is
known, `list` (= `List[any]`) otherwise. `list_get(rows, i)` afterwards:
`mutarray`. The nine consumers receive `mutarray` in the semantic HIR.

**Semantic instances (60).** 252 -> 268; distinct builder instances: 14 in
csv_records, 7 in csv_geometric (`out/census-after.txt`); yes, one source
`geo_append` serves every real element type; none fails; body walks for the
builder functions: 1 pass each (walk total 343 -> 363); instance pressure rose
by +16 instances / +20 walks corpus-wide, about +10% front-end time overall of
which most is noise.

**Codegen (61).** 245 -> 258 used, 234 -> 247 emitted. Distinct semantic
builder instances share codegen by value kind. Semantic element-type
multiplicity did not create machine duplication; threading `value` into
`geo_grow`/`geo_new` did (x3). Builder functions whose machine code changed:
all of them (see the table). Guards that disappear: 6 in csv_records (five
generic HashTable accessors and one `row_fill`) because typed rows reach
`ht_get`; none in csv_geometric (it had none). List packing/unpacking that
disappears: `geo_append`'s multi-value result and the `list_get(builder, ..)`
unpack in `geo_append`/`geo_finish`, already virtualized natively before, so no
runtime List operations changed.

**Strict (62).** 32 sites / 9 of 31 -> 38 sites / 9 of 31. The nine row-builder
sites do **not** disappear; the remaining boundary is the definition-level
`MutableArray[mutarray]` -> inferred-raw `mutarray` relation in `build_rows`
(they do disappear, 23 sites in all, in the scratch run with declared row-path
contracts). Unrelated sites: none changed. Categories: see the table.

**Performance (63).** List allocations removed: 0 (already virtualized).
MutableArray allocations: -1 per builder start (-10,006 at 10,000 rows). Default
overhead: 0 allocations, extra slot stores. Allocated bytes: -240 KB at 10,000
rows. Native timing: csv_geometric -5.8% .. +0.6%, csv_records -0.3% .. +7.2%
(noise-level). Code size increases (+1,952 B / +2,124 B; corpus +4,076 B).

**Roadmap (64).** After replacing the raw builder idiom with typed
`MutableArray`, the information still lost that opportunistic semantic
instances cannot recover: (1) true product/record values (`[field, index]`,
`[fields, index]`, `[newControls, newKeys, newValues]`, `[name, dependencies]`),
(2) declared definition/API contracts (`total_valid`, `esc_bytes`, matmul
`a_row`), and (3) the definition-level element-type relation for typed arrays
through intermediate untyped functions (one annotation in this fence, 15 strict
sites). No dynamic/open callable targets remain on this path.

## Files

* Source fence: `examples/stdlib/csv_geometric.bot`, `csv_records.bot`.
* Harness/tests: `examples/stdlib/corpus.tcl` (`corpus::compile`),
  `tests/typed-mutarray-builder.test` (new), `tests/mutable-array-type.test`
  (`mat-fence-1`), `tests/stdlib.test`, `tests/native.test`,
  `tests/hir-specialize.test`, `tests/native-param-aggregate.test`,
  `tests/native-csv-records.test`, `bench/csv_records.tcl`,
  `native/generate-scalar-audit.tcl`, `native/generate-post-stack-details.tcl`.
* Audit: `audit/typed-mutarray-builder-refactor/` (`README.md`, `tools/`,
  `out/`), regenerated `audit/native-scalar-asm/`.
