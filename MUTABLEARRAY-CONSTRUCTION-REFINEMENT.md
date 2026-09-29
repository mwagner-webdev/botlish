# MutableArray construction and refinement

## Outcome

**Delivered:** `mutarray?(v)` (a genuine, non-throwing, allocation-free type
test registered through the ordinary type-test metadata, on every backend)
and `mutarray::from_list(xs)` (an ordinary Botlish function over the
existing MutableArray substrate, in `lib/mutarray.bot`). `mutarray` remains
the one canonical MutableArray type. No `MutableArray[T]`, no cast, no
element/slot typing, no positional List schema, no exact-value machinery
for MutableArrays, no runtime representation change.

**Measured, and different from what the milestone brief assumed:** the
audit found that *constructor result typing was already correct before this
milestone*. `mutable_array_allocate` — the only operation in the tree that
returns a fresh MutableArray — has been registered with `-result-type
mutarray` since the MutableArray substrate landed, and ordinary
`List[T]`/`list_get` typing has always carried it (`[mk(), mk(), mk()] :
List[mutarray]`, `list_get(rows, i) : mutarray`, in the *parent* commit).
What was missing was the *public* construction API and the *dynamic
refinement* primitive. Consequently:

* the strict-contract counterfactual (`variant-all-trusted`) is
  **byte-identical before and after: 10 programs, 35 sites**;
* **0 of the 9 primary MutableArray failures disappear**, and the four
  record-contained ones also remain (as required);
* the corpus census is identical before and after (the frozen corpus uses
  neither new name), as are generated code (all 17 scalar-assembly audit
  files), NIR (8 benchmarks), and AOT classification (245 instances).

The 9 primary sites were not "missing a constructor fact": each `first`/
`second`/`presized_first` is a `list_get` of the `rows` List that
`csv_records` returns, and that List is produced by a *builder*
(`geo_append`/`geo_finish`) that stores rows through an untyped
MutableArray slot into a `[storage, length]` pair and freezes them into a
plain `list`. The construction fact is intact right up to `geo_append` and
is lost there (§ "Primary strict-counterfactual failures"). Recovering it
would need `MutableArray[T]`-style slot typing, a product type, and a
generic value-to-element relationship — three things the brief forbids in
this milestone and assigns to later ones. The honest result is therefore
**9 -> 9, with the exact information-loss boundary identified**, and a
positive control (below) showing that the same consumers are accepted the
moment the container is an ordinary typed List.

## Motivation

The strict-contract counterfactual isolated a `MutableArray` category (9
primary sites, plus 4 overlaps with positional records). The brief's
hypothesis was that MutableArray creation and dynamic refinement did not
establish the `mutarray` kind strongly enough for it to flow through
ordinary `List[T]` typing. This milestone tests that hypothesis, closes the
two real gaps it exposed (no genuine `mutarray` type test; no public,
intended-name constructor), and records precisely where the counterfactual
failures actually come from.

## Previous MutableArray type boundary

Static kind: `mutarray` (`core/type.tcl`'s primitive list; `core/value.tcl`
kind `mutarray`; Rust `Kind::MutArray`/`KIND_MUTARRAY`). Every native that
requires a MutableArray already declared `mutarray` as its parameter type;
every native that produces one already declared it as its result type.
Before this milestone there was:

* no type test for it — the only way to "prove" a value was a MutableArray
  was to call an operation with a `mutarray` precondition (which is an
  operation with a precondition, not a predicate, and which a body-inference
  pass reads as a *requirement*, not a refinement);
* no constructor other than raw `mutable_array_allocate(capacity)` with
  hand-written fill loops in the stdlib programs.

## Current runtime representation

Unchanged. Tcl: `{mutarray ID}` handle into `core::mutarray::store` (a dict
of fixed-length slot lists). Native: `MutArrayObj` heap object, heap kind
`KIND_MUTARRAY` (tag byte `8`). Capacity never changes after allocation;
"growing" means allocate + `mutable_array_copy`. Equality is undefined.

## Current constructors and result metadata

Audit of every operation that can create or return a MutableArray (registry
`core::native::metadata`, pinned by `mutarray-meta-1..4`):

| surface name | native/core name | runtime result kind | static result type (before -> after) | native metadata | canonical call sites |
|---|---|---|---|---|---|
| `mutable_array_allocate` | `core::mutarray::allocate` / op `mutarrayallocate` (`rt_mutarray_allocate`) | MutableArray, unconditionally | `mutarray` -> `mutarray` | `-param-types {int} -result-type mutarray -runtime mutarray-alloc -context-free 1` | 21 (csv_chunked 3, csv_geometric 2, csv_records 9, hashtable 7) |
| `mutable_array_capacity` | `core::mutarray::capacity` | int | `int` (unchanged) | `-param-types {mutarray}` | — |
| `mutable_array_get` | `core::mutarray::get` | any slot value | `any` (slots are untyped; unchanged) | `-param-types {mutarray int}` | — |
| `mutable_array_set` | `core::mutarray::set_` | `unit` (verified: returns `core::value::unit`, not the array or value) | `unit` (unchanged) | `-param-types {mutarray int any}` | — |
| `mutable_array_copy` | `core::mutarray::copy` | `unit` | `unit` | `-param-types {mutarray int mutarray int int}` | — |
| `mutable_array_freeze` | `core::mutarray::freeze` | immutable List (always copies) | `list` | `-param-types {mutarray int}` | — |
| *(growth)* | none — the substrate has no push/grow/reserve/clone (`core/mutarray.tcl`'s header); growth is allocate + copy in Botlish | — | — | — | `geo_grow` etc. are ordinary functions whose result is `mutarray` by ordinary inference |
| `mutarray::from_list` | **new**, ordinary Botlish over `mutable_array_allocate`/`mutable_array_set` | MutableArray | `mutarray` (declared and also inferred) | (a module function, not a native) | 0 in the frozen corpus |

Findings: **no operation previously had incorrect or broad result
metadata**; **no `mutarray` parameter was missing** (every one of the five
operations that requires a MutableArray declares it); **exactly one
operation returns a MutableArray unconditionally** (`mutable_array_allocate`;
test `mutarray-meta-3` asserts no other registered native ever declares a
`mutarray` result). Nothing returns "an existing MutableArray" in the
registry: `mutable_array_get` returns whatever the slot holds, hence `any`.

## Public API: `mutarray::from_list`

`lib/mutarray.bot`:

```
namespace mutarray

fn from_list(xs: list) -> mutarray:
    count = list_length(xs)
    storage = mutable_array_allocate(count)
    loop i from 0 to count:
        mutable_array_set(storage, i, list_get(xs, i))
    storage
```

* **No new runtime constructor.** It is the allocate-then-fill sequence the
  stdlib builders already write by hand, so the runtime construction path
  — allocation, rooting, bounds checks, GC behavior — is **unchanged** (the
  same `rt_mutarray_allocate`/`rt_mutarray_set` helpers; parity proven on
  every backend and under GC stress, below).
* **Semantics** (all inherited, none invented): the result is a new
  MutableArray of capacity `list_length(xs)` with slot `i` = `list_get(xs,
  i)`; order and values preserved; elements are shared, not deep-copied (a
  nested MutableArray element keeps its identity, `mutarray-sem-7`); the
  source is only read, so it stays an ordinary immutable List and later
  mutation of the result never reaches it (`mutarray-sem-2/3`); `[]` gives a
  capacity-0 array (`mutarray-sem-5`); a heterogeneous List is accepted
  (`mutarray-sem-6`); an alias shares storage exactly as before
  (`mutarray-sem-4`). No copy-on-write or aliasing behavior was added.
* **Argument contract:** `xs: list` is an ordinary declared parameter, so a
  statically non-List argument is rejected at compile time (`from_list(123)`,
  `from_list("abc")`), an untyped parameter forwarded into it infers a
  checked `list` requirement, and a value that cannot be proven a List is
  rejected under the standard typed-parameter rule — nothing is coerced and
  no implicit guard is inserted (`mutarray-arg-1..4`, `mutarray-sem-10`).
* **Errors:** whatever the substrate exposes (RANGE for an impossible
  capacity, which `list_length` can never produce).
* **Result type:** declared `mutarray`, and — with the declaration removed —
  the same `mutarray` is inferred from `mutable_array_allocate`'s metadata,
  so the annotation is documentation, not compensation for missing compiler
  metadata.

## Type predicate: `mutarray?`

```
core::native::register mutarray? ... -tests-type mutarray   (core/predicates.tcl)
```

Registered in the same `foreach` that registers `integer?`, `string?` and
`list?`: `core::predicates::KindIs mutarray` (the same runtime-kind
comparison — `core::value::kind`, i.e. the `{mutarray ID}` tag — that
`core::value::expect mutarray` uses inside every MutableArray operation).
`register`'s `-tests-type` protocol derives everything else:

```
paramTypes {any}   resultType bool   testsType mutarray
refinesTrue {0 mutarray}   refinesFalse {}   runtime {}
```

`mutarray-meta-6` asserts its full metadata shape equals `list?`'s.

* Semantics: true iff the argument is a MutableArray; never raises; accepts
  any value (`mutarray-run-1`: MutableArrays, Lists, ints, strings, bools,
  `unit`, natives, ImmutableSets).
* Static result: `bool` in the semantic view and in every used specialization
  view (`mutarray-pred-1`, `-15`).
* Structural callable type: identical to its siblings —
  `Fn{args: [any], return: bool, errors: []}`; it can be passed where such an
  `Fn` is expected (`mutarray-pred-14`). This falls out of the registry
  metadata; no `-param-types` was misused as a runtime type.
* **Backends** (the same set exercised for `integer?`/`list?`/`string?`):
  interp and Tcl compiler use the registered `-impl`; the Cranelift backends
  use a new opcode `IsMutArray` (`native/lower.tcl`'s name -> op table gains
  `mutarray? {op ismutarray}`; `native/src/{nir,codegen/clif,runtime/ops}.rs`
  gain one match arm each). The Cranelift arm reuses the existing `is_kind`
  code generator, which already contained the `Kind::MutArray` case — so the
  test is the same inline shape as `list?` (`out/predicate-asm.txt`):
  pointer-tag test, one byte load of the heap-object kind, compare with `8`
  (`list?` compares with `3`), **no `rt_*` call, no allocation, no safepoint,
  not in `op_may_error`**. The standalone AOT executable goes through the same
  lowering and is covered as well (`mutarray-run-6`, also under
  `BOTLISH_NATIVE_GC_STRESS=1`).

## Refinement integration

The refinement engine learns nothing by name. `hir/refine.tcl` reads
`refinesTrue` from the registry entry; `mutarray?` is a registry entry
exactly like `list?`, so:

```
fn f(x):
    if mutarray?(x):
        mutable_array_capacity(x)     # x : mutarray here
    else:
        0
```

types `x` as `any` at the test and `mutarray` in the true branch (`e6 ref x :
any`, `then s4 refines b2 x : mutarray` in `out/refinement-probe.txt`; test
`mutarray-pred-3`), with **no** dependence on `mutable_array_capacity(x)` —
the argument is `mutarray` before the call is reached. Also pinned:

* immutable aliases keep the refined kind, including chains
  (`y = x`, `z = y`): `mutarray-pred-7/8`;
* the refined value flows out of the branch as `mutarray`, joined with
  another `mutarray` (`mutarray-pred-9`);
* the refinement does **not** escape the branch: `if mutarray?(x): ...` then
  `mutable_array_capacity(x)` still requires (checked) `mutarray` after the
  branch, and a statically-known non-MutableArray argument is still rejected
  at compile time; with the diagnostic recovered (`-strict 0`) all four
  backends raise `TYPE` at run time (`mutarray-pred-10..12`, `mutarray-run-4`);
* **negative branch:** the repository's refinement system only materially
  tracks positive kinds for kind predicates (`refinesFalse {}` for
  `integer?`/`list?` too), so `else` gains nothing and no complement type
  exists; the join after the test is `any` (`mutarray-pred-13`);
* **no MutableArray-specific special case**: `mutarray-arch-1` scans
  `hir/`, `compiler/` and `surface/` and asserts that no pass mentions
  `mutarray?` or `mutarray::from_list`. The only places the name appears are
  the registration itself and the native-backend opcode table (where every
  native predicate — `integer?`, `string?`, `list?`, `ok?` — appears).

## Intrinsic-contract interaction

Unchanged policy, verified:

* `fn capacity(x): mutable_array_capacity(x)` still infers `x : mutarray`
  as a **checked** requirement (`mutarray-pred-6`);
* `fn maybe_capacity(x): if mutarray?(x): mutable_array_capacity(x) else: 0`
  infers **nothing** for `x` — the use occurs under the refinement, and the
  path-sensitive rule already recognizes that (`x: any (none)`,
  `mutarray-pred-5`); `fn p(x): mutarray?(x)` also imposes nothing
  (`mutarray-pred-2`);
* an unguarded use after a branch-local test still contributes the checked
  requirement (`mutarray-pred-11`);
* trusted/checked semantics are otherwise untouched; `hir/signatures.tcl`,
  `hir/exactvalue.tcl` and every other analysis file are unmodified by this
  milestone, so exact-value inference is unchanged by construction.

## Constructor result propagation

`m = mutarray::from_list(xs)` and `n = m` are `mutarray`; `xs` stays
`List[int]` (`mutarray-type-1..3`). The low-level constructor is `mutarray`
(`-type-4`). `from_list(["x", 1, true])` and `from_list([])` are plain
`mutarray` — no `MutableArray[any]` (`-type-5/6`). Slots stay untyped:
`mutable_array_get(m, 0) : any` (`-type-7`). There is no `MutableArray`,
`MutableArray[int]` or `mutable-array` spelling (all rejected;
`-type-8`).

## Function result propagation

`fn make(): mutarray::from_list([1,2,3])` infers `mutarray` with no
annotation; so do forwarding (`fn forward(): make()`), a function that
mutates then returns its array, and `fn make(n): mutable_array_allocate(n)`
(`mutarray-fn-1..4`). Same-kind conditional branches join to `mutarray`
through ordinary `lub` (`mutarray-join-1`); mixed joins use the existing
fallback (`mutarray` vs `[]` -> `any`; `mutarray` vs unknown -> `any`) — no
union types (`mutarray-join-2/3`).

## `List[mutarray]` propagation

Homogeneous List construction already preserved named/core element types;
no LUB change was needed and none was made. `[from_list(..), from_list(..)]
: List[mutarray]`; `list_append(List[mutarray], mutarray) : List[mutarray]`;
adding a non-MutableArray element widens to plain `list`
(`mutarray-list-1/4/6`). An accumulator built through recursion
(`collect(list_append(acc, from_list(..)), n - 1)`) is `any`: preserving
`T` from `acc` to the result is the generic relationship, deliberately
**not** solved here (`mutarray-list-7` pins it; classified below).

## `list_get(List[mutarray])`

`list_get(rows, i) : mutarray` for an arbitrary (dynamic) `i`, through a
top-level `rows`, and through a function-returned `List[mutarray]` (`fn
rows(): [mk(), mk(), mk()]`, `list_get(rows(), i)`); no exact index or exact
List fact is involved — exact facts do not cross the function boundary and
the type is the same in the un-inlined generic instance
(`mutarray-list-2/3/5`, `out/probe-typing.txt`). It is homogeneous element
typing, not positional typing.

The corpus already contained this chain in the parent commit, in the *caller*
side of the rehash code (`ht_rehash`: `dest = [newControls,
mutable_array_allocate(n), mutable_array_allocate(n)]` is `List[mutarray]`
and `list_get(dest, 0..2)` are `mutarray`; 6 `List[mutarray]` expressions
and 3 `mutarray`-typed `list_get` sites in each of `csv_records.bot` and
`hashtable.bot`) — which is why the census below shows no change.

## Why `MutableArray[T]` is not needed

The 9 primary sites, the 4 record-contained sites, and every other MutableArray
requirement in the corpus need to prove *that a value is a MutableArray*, never
*what slot `i` holds*. `List[mutarray]` says every element is a
MutableArray and nothing about what those contain; `mutable_array_get`
remains `any`. What the primary failures do need is an element-typing
relationship for **freezing a builder** — i.e. exactly slot typing — and that
is the stop condition the brief gives for this milestone; it is reported as
the boundary, not built.

## Why MutableArray contents are not exact-value facts

A MutableArray is mutable: any exact fact about its contents becomes stale at
the next `mutable_array_set` through any alias. `hir/exactvalue.tcl` is
unchanged; it still tracks a MutableArray-typed expression as an *opaque*
value (`exact-list[mutarray?, mutarray?, mutarray?]` shows the kind marker
only), and `mutarray-neg-6` pins that `from_list([1,2,3])` has no exact fact
at all. Capacity is likewise not a type fact.

## Primary strict-counterfactual failures

Re-run of the frozen `variant-all-trusted` counterfactual
(`audit/intrinsic-function-contracts/tools/validity.tcl` in a scratch tree
with `variant-all-trusted.patch` applied; corpus and diagnostics unedited):

| | programs with diagnostics | sites |
|---|---|---|
| before (parent commit) | 10 of 31 | 35 |
| after (this milestone) | 10 of 31 | 35 |

`out/strict-counterfactual-before.txt` and `-after.txt` are byte-identical
(and identical to the exact-value milestone's committed run).

**The 9 primary sites** are `csv_records.bot:452:{20,45,81,99}` and
`453:{32,55,77,100,124}` — the `ht_get`/`ht_size` calls on `first`, `second`,
`presized_first` in `sample()`. Full chain (`out/trace-after-variant.txt`,
identical before/after):

```
constructor          mutable_array_allocate                     mutarray   (before: mutarray)
                     ht_alloc / ht_new_sized / ht_new           mutarray
                     row_new                                    mutarray
                     row_fill, row_table                        mutarray   (under the counterfactual)
                                    │
                                    ▼   geo_append(outer, table)   builder: list, value: any -> list
container            [grown, length + 1]   (the `[storage, length]` positional pair)
                     geo_finish -> mutable_array_freeze         list       (slots are untyped)
                     build_rows / csv_records_generic / csv_records        list
                     rows, presized_rows                        list       (before: list)
projection           first = list_get(rows, 0)                  any        (before: any)
                     second = list_get(rows, 1)                 any
                     presized_first = list_get(presized_rows,0) any
consumer             ht_get(first, "name") / ht_size(first)     table : mutarray (trusted) <- any
```

The chain is *not* constructor -> `List[mutarray]` -> `list_get`: the
List is never `List[mutarray]`. Precisely, the loss happens at three
successive points, all downstream of the construction fact:

1. `geo_append(builder, value)`: `value` is an untyped parameter; the row
   enters the builder as `any` (generic value -> element relationship);
2. `mutable_array_set(grown, length, value)` stores it in an **untyped
   slot**, and the new `[grown, length + 1]` pair is a heterogeneous
   positional record (`list`) — struct territory;
3. `mutable_array_freeze(storage, length)` returns plain `list`: freezing an
   array whose slots are untyped cannot produce `List[T]` without slot
   element typing.

| program | source site | value | before type | provenance / creator | after type | resolved? | why not | category after |
|---|---|---|---|---|---|---|---|---|
| csv_records | `452:20` | `first` | `any` | `list_get(rows, 0)`; rows created by `row_table` (`mutarray`) | `any` | no | builder boundary above | MutableArray (slot/builder flow) |
| csv_records | `452:45` | `presized_first` | `any` | `list_get(presized_rows, 0)` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `452:81` | `first` | `any` | as `452:20` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `452:99` | `presized_first` | `any` | as `452:45` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `453:32` | `first` | `any` | as `452:20` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `453:55` | `first` | `any` | as `452:20` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `453:77` | `first` | `any` | as `452:20` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `453:100` | `second` | `any` | `list_get(rows, 1)` | `any` | no | same | MutableArray (slot/builder flow) |
| csv_records | `453:124` | `second` | `any` | as `453:100` | `any` | no | same | MutableArray (slot/builder flow) |

Classification of each in the brief's A/B/C terms: **not A** (the value does
not come directly from an operation typed `mutarray`); it is a mixture of
**B** (`value` -> `List` element through a builder parameter, and `row_fill`
returning its `table` accumulator — `row_fill`/`row_table` infer `any`
outside the counterfactual because the result is the parameter itself) and
**C** (the `[storage, length]` pair). A fourth kind — reading a MutableArray
*out of a slot* (`ht_controls(table)` = `mutable_array_get(table, 0)` : `any`)
— needs slot typing and is the same boundary; it is not in the brief's A/B/C
and is called out separately here.

**Positive controls** (`tools/controls.tcl`, appended to a scratch copy of
`csv_records.bot`; canonical source untouched; `out/controls-variant.txt`):

| control | before | after |
|---|---|---|
| `rows = [row_table(..), row_table(..)]`, `first = list_get(rows, 0)`, `ht_get(first, ..)`/`ht_size(first)` | accepted | accepted |
| `rows = list_append([row_table(..)], row_table(..))` (same consumers) | accepted | accepted |
| `rows = geo_finish(geo_append(geo_new(), row_table(..)))` (same consumers) | REJECTED | REJECTED |
| `rows = [mutarray::from_list(..), mutarray::from_list(..)]`; `ht_size`/`mutable_array_capacity` of `list_get(rows, 0)` | *(API absent)* | accepted |
| `fn table(n): mutarray::from_list([n, n])`; `list_get([table(1), ..], i)` through a function-returned List | *(API absent)* | accepted |

Same consumers, same constructors: what changes the verdict is only whether
the rows travel through an ordinary typed List or through the builder. That
is the "information-loss boundary", demonstrated rather than asserted.

## Record-contained negative controls

The four overlaps stay unresolved, as required — `storage` in
`[storage, length]` (`csv_geometric.bot:52:22`, `csv_records.bot:126:22`) and
`newControls` in `[newControls, newKeys, newValues]`
(`csv_records.bot:311:29`, `hashtable.bot:226:29`); none was recovered from
slot position. `mutarray-neg-1..5` pin the mechanism: a function returning
`[from_list(..), 0]` and `list_get(mk(), 0)` are `any`; the literal is plain
`list`; `list_get(p, 0)` on a parameter is `any`; the only `mutarray` fact
about a *local* pair is the pre-existing, local, exact-value fact
(`p = [m, 0]; list_get(p, 0) : mutarray`, unchanged, and gone at the first
function boundary: `mutarray-neg-5`).

One observation worth recording for the explicit-contract milestone, not
acted on: for the `newControls` pair, the *caller* (`ht_rehash`) builds
`dest = [newControls, alloc, alloc]`, which ordinary homogeneous typing
already types `List[mutarray]`, and `list_get(dest, i) : mutarray` there
(pre-existing). The failing sites are in the *callee* (`ht_rehash_insert`),
which receives `dest` through an untyped parameter. That value is homogeneous
by accident of the current hash-table layout, not by schema; carrying it
across the call needs either a caller-derived List schema (forbidden) or an
explicit `List[mutarray]` annotation (not added — no annotation was added in
this milestone). I did not reclassify these two sites; they stay in the
record-shaped category.

## 35-site strict-counterfactual before/after

`out/strict-counterfactual-table.md` has every site with its workaround,
category and verdict.

| category | before | after |
|---|---|---|
| record-shaped List / struct | 15 | 15 |
| MutableArray (9 primary; now with an identified builder/slot boundary) | 9 | 9 |
| generic relationship | 7 | 7 |
| genuine annotation | 4 | 4 |
| resolved | 0 | 0 |
| other / new | 0 | 0 |
| **total** | **35** | **35** |

No site changed category, none migrated silently, and no generic or
record failure was "accidentally solved" — nothing changed at all. The
MutableArray category is unchanged in size but re-scoped: no construction or
`mutarray`-kind fact is missing anywhere in it; what remains is downstream
of the builder (slot element flow), which depends on the struct and
generic-relationship work.

## Corpus census (before / after)

`tools/census.tcl` over `bench/*.bot`, `examples/stdlib/*.bot`,
`examples/surface/*.bot` and the loaded `lib/*.bot` (each source location
once; **semantic** types of the source HIR). The outputs are identical
before and after in both the real regime and the all-trusted counterfactual
regime (`out/census-{before,after}[-variant].txt`), as they must be for a
frozen corpus that uses neither new name:

| measure | before | after |
|---|---|---|
| MutableArray constructor call sites | 21 (`mutable_array_allocate`) + 0 (`mutarray::from_list`) | 21 + 0 |
| constructor result type at those sites | `mutarray` (21/21) | `mutarray` (21/21) |
| functions returning `mutarray` (real regime / counterfactual regime) | 9 / 11 | 9 / 11 |
| expressions typed `List[mutarray]` | 12 (`ht_rehash` in `csv_records.bot`, `hashtable.bot`; 6 each) | 12 |
| `list_get` sites whose result is `mutarray` | 6 of 73 | 6 of 73 |
| MutableArray requirement sites (native param or user fn param that requires `mutarray`) | 239 | 239 |
| ... statically proven (argument is `mutarray`) real / counterfactual | 54 / 173 | 54 / 173 |
| ... still a checked `any -> mutarray` boundary real / counterfactual | 185 / 66 | 185 / 66 |

Functions returning `mutarray` (real regime): `geo_grow` (csv_geometric,
csv_records), `ht_alloc`, `ht_new`, `ht_new_sized` (csv_records, hashtable),
`row_new`. Under the counterfactual `row_fill` and `row_table` join them (their
accumulator parameter `table` becomes a trusted `mutarray`).

**Remaining `any -> MutableArray` boundaries** in the counterfactual regime
(66), classified by what the argument is: 20 arguments that are *direct slot
reads* (`ht_controls(table)`, `ht_keys(table)`, `ht_values(table)`: a
MutableArray read out of an untyped slot of the table array), 8 that are
variables bound by such a slot read, 8 that are `list_get` of a positional
pair (`dest`, `src`), 22 variables bound by `list_get` of a positional pair or
of the chunk List (`storage`/`current`/`chunk`), and 8 references to
parameters (these show `any` in the semantic view, which is what the census
measures; the used specialization instance seeds the trusted contract and the
consumer is proven there, so they are not real boundaries). Every real
boundary is therefore *slot typing* (28) or a *`list_get` of a pair/List that
arrived through an untyped parameter* (30: the positional records, plus
csv_chunked's chunk List) — none comes from a constructor whose result is
not `mutarray`.

## Remaining generic failures

Untouched (7): `chars_of` accumulator return (`lex-strategy 57:20`),
`list::find` callable erasure (`source-checks 89:40`), `found` from
`list::find` (`test-selection 71:15`), `is_affected?` erased into
`list::find` (`test-selection 68:31`), `csv_records` `records` accumulator
(`416:46`, `429:28`), `ht_collect_pair` erased into `ht_fold`
(`hashtable 362:47`). The `row_fill`/`row_table` accumulator-return shape
(`table` in -> `table` out) that makes those helpers infer `any` *outside*
the counterfactual is the same `T in -> T out` relationship.

## Remaining annotation candidates

The four proposed annotations all remain necessary, unchanged:
`chars_of result` (`lex-strategy 57:20`, categorized generic-relationship),
`total_valid tokens` (`lex-strategy 79:63`), `select_affected tests`
(`test-selection 61:26`) and `esc_bytes bytes` (`lib/web.bot 204:70`). The
fourth "genuine annotation" site in the counterfactual table is
`matmul.bot:38:23` (`list_get(a, i)` on an untyped matrix parameter). MutableArray
typing indirectly removes none of them, as expected. No annotation was added.

## Remaining struct failures

Unchanged: `[field, index]` scan pairs (8 sites across csv/csv_chunked/
csv_geometric/csv_records), `[storage, length]` (4), `[newControls, newKeys,
newValues]` (2), `[name, dependencies]` (`test-selection 57:16`) — 15 sites.
None was addressed by positional inference; `hir/specialize.tcl`'s
optimization-only positional shapes were not extended.

## Generated-code effects

None, and that is a result, not an omission: the frozen corpus uses neither
new name and its constructor typing was already `mutarray`. Verified by
regeneration:

* `native/generate-scalar-audit.tcl` output for all 17 programs is
  byte-identical to the committed `audit/native-scalar-asm/*.asm` and
  `*.summary.txt` (only that directory's `README.md` differs, in its
  `git commit:` line, because the scratch run had no `.git`) — no baseline
  was updated;
* NIR + instance labels of the 8 benchmarks (`audit/intrinsic-function-
  contracts/tools/nir.tcl`) are identical before/after;
* AOT classification of every used instance of the 17 canonical programs
  (`tools/aot.tcl`, `out/aot-{before,after}.txt`): identical —
  `closed 200, guarded 41, open 4`, no blocker changed.

Where a *new-API* program gains stronger facts, existing machinery consumes
them unchanged, which `mutarray-run-7` and `out/guard-elision.txt` show: a
consumer `cap(x) = mutable_array_capacity(x)` reached through
`list_get(rows(), i)` on a `List[mutarray]` of `from_list` results is
specialized `cap<mutarray>` and its NIR has **no** `guard mutarray`
(`op mutarraycapacity` directly), while the `any`-typed call keeps `cap<generic>`
with `guard mutarray "mutable_array_capacity"`. That is the existing static-proof
rule at work — no backend-specific rule was added and no new notion of proof
was introduced.

## Runtime/GC effects

* `mutarray?` retains, allocates and roots nothing (inline tag test, no
  helper call: `out/predicate-asm.txt`).
* `mutarray::from_list` **runtime construction path unchanged**: it calls the
  same `mutable_array_allocate`/`mutable_array_set` natives; no allocation
  or rooting code was written or modified.
* Because no managed-object construction/rooting path changed, a full
  GC-stress run is not required by the brief; nevertheless
  `tests/mutarray-construction.test` (73 tests, including the standalone AOT
  executable, which is also run with `BOTLISH_NATIVE_GC_STRESS=1`) and
  `tests/native-mutarray.test` (49) both pass under
  `BOTLISH_NATIVE_GC_STRESS=1`, and the repository's `gc-stress` CI job runs
  the whole suite on push.

## Compile-time impact

Median of 7 front-end compiles (`surface::readProgramFile`: parse, resolve, type inference including intrinsic contract inference, every static check) of the same 17 canonical benchmark/stdlib programs as the previous two reports (`audit/intrinsic-function-contracts/tools/compiletime.tcl 7`, run on a quiet machine, parent tree vs this tree; `out/compiletime-{before,after}.txt`):

| program | before (ms) | after (ms) |
|---|---|---|
| fib.bot | 4.2 | 4.0 |
| lex-strategy.bot | 45.4 | 43.6 |
| loop-count.bot | 10.0 | 7.7 |
| refined-checks.bot | 11.3 | 10.9 |
| source-checks.bot | 32.1 | 41.1 |
| sum-refined.bot | 6.4 | 7.1 |
| test-selection.bot | 48.0 | 44.0 |
| uri-steady.bot | 164.6 | 151.3 |
| ai_text_clean.bot | 38.8 | 36.3 |
| csv.bot | 47.0 | 58.2 |
| csv_chunked.bot | 73.7 | 85.2 |
| csv_geometric.bot | 64.0 | 66.1 |
| csv_records.bot | 292.4 | 252.3 |
| hashtable.bot | 192.5 | 195.8 |
| matmul.bot | 27.7 | 28.5 |
| string_replace.bot | 28.3 | 28.0 |
| string_reverse.bot | 10.5 | 10.9 |
| **total (17 programs)** | **1096.8** | **1071.1** |

The totals differ by -25.7 ms (-2.3%), which is run-to-run noise: no front-end pass was added or changed. `mutarray?` is a registry entry consumed by the existing refinement code, and `mutarray::from_list` is only parsed/typed by programs that name it (no canonical program does).

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl` (Tcl 9.0.1 from the pinned
Ubuntu packages, native backend built with rustc 1.98.1) runs the whole suite
on both Tcl backends; `stdlib.test`, `native*.test`, `backends.test` and
others additionally run the Cranelift backends inside each of those runs:

| backend | total | passed | skipped | failed |
|---|---|---|---|---|
| interp | 2926 | 2926 | 0 | 0 |
| compile | 2926 | 2926 | 0 | 0 |

(The parent tree is 2851 tests per backend; this milestone adds
`tests/mutarray-construction.test`, 75 tests, and nothing else. Exit status 0.)
The new file also passes, on its own, under `CORE_BACKEND=cranelift` and
`CORE_BACKEND=cranelift-generic` (75/75 each), and both it and
`tests/native-mutarray.test` (49) pass under `BOTLISH_NATIVE_GC_STRESS=1` on
both Tcl backends. Every parity test in the new file runs its program on
interp, compile, cranelift-generic and cranelift and requires identical
outcomes; one test additionally builds a standalone AOT executable, and runs
it with and without GC stress.

## Benchmark parity

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 bench/bench.tcl -runs 1` with the native backend built (rustc 1.98.1, `cargo build --release --manifest-path native/Cargo.toml`): exit status 0 — bench.tcl exits 1 if the Botlish backends disagree on any program's result, and none did, on all 8 canonical benchmarks (fib, lex-strategy, loop-count, refined-checks, source-checks, sum-refined, test-selection, uri-steady) across Tcl interp, Tcl compile and Cranelift (`out/bench-runs1.txt`). Timings are not compared: generated code is byte-identical to the committed audit corpus, so there is nothing to compare. The stdlib corpus programs are agreement-tested by `tests/stdlib.test` and `tests/bench-corpus.test` inside the full regression.

## Known limitations

* `mutarray::from_list` is a loop over `mutable_array_set`; it is not a
  single bulk runtime operation. That is intentional (no new runtime code),
  and identical in cost to the stdlib's hand-written fill loops.
* `MutableArray` values cannot be returned to the native host (pre-existing
  `NATIVE UNSUPPORTED value`); the new tests return non-MutableArray results.
* The negative branch of `mutarray?` carries no fact (no complement types),
  matching `integer?`/`list?`.
* A statically wrong `from_list` argument is a compile-time rejection under
  the standard typed-parameter rule; the same program compiled with
  diagnostics recovered (`-strict 0`) raises `TYPE` at run time on every
  backend.
* The 9 primary counterfactual failures are not fixed by this milestone
  (see above); they are not fixable within its constraints.
* No canonical source was rewritten to use `mutarray?` or `from_list`; the
  frozen-source measurement is unchanged by design. No `as_mutarray` helper
  exists or was merged: where source genuinely needs a dynamic check, `if
  mutarray?(v):` is now the honest primitive (recorded separately from the
  frozen counterfactual, which still uses its original workaround
  vocabulary).

## Readiness for generic helper relationships

The residual strict failure set is now cleanly partitioned, and the
MutableArray *kind* dimension is closed: constructors, refinement, function
results, joins, `List[mutarray]` and `list_get` are all first-class and
tested. The next milestone's evidence set is: 7 generic-relationship sites,
plus the `T in -> T out` accumulator returns (`row_fill`, `row_table`,
`csv_parse`'s `records`) and the `value -> List[element]` builder relationship
(`geo_append`), whose resolution would also determine how much of the
9-site MutableArray boundary remains once struct and slot typing are
decided. The 15 record sites and 4 annotation candidates are separate
milestones and are unaffected.

## Answers to the required questions

### Architecture

1. **Canonical internal type:** `mutarray` (`core/type.tcl` primitive; kind
   `mutarray` in `core/value.tcl`; `Kind::MutArray` in the native runtime).
2. **Constructors today:** exactly one — `mutable_array_allocate`; plus the new
   `mutarray::from_list` (built on it). `mutable_array_freeze` produces a
   List; there is no grow/clone operation.
3. **Previously incorrect/broad result metadata:** none.
4. **Runtime constructor added or exposed?** Neither: an ordinary Botlish
   wrapper over the existing constructor. A runtime *predicate* was added.
5. **What backs `mutarray::from_list`:** `lib/mutarray.bot`, over
   `mutable_array_allocate` + `mutable_array_set` + `list_length`/`list_get`.
6. **Copy/alias/transform of the source List:** allocates a new MutableArray
   and copies element references (shallow); the source List is only read and
   stays immutable and untouched.
7. **`mutarray?` implementation:** `core::predicates::KindIs mutarray`
   (Tcl backends); opcode `IsMutArray` -> inline `is_kind(MutArray)` /
   `rt_is_kind` (Cranelift backends).
8. **How the refinement engine learns the true branch:** the registry entry's
   `-tests-type mutarray` -> derived `-refines-true {0 mutarray}`, consumed
   by `hir/refine.tcl` like any other predicate.
9. **MutableArray-specific special case outside normal metadata?** No.
   (`mutarray-arch-1`; the only additions outside the registration are the
   backend opcode-table row and the Rust opcode, mirroring `list?`.)

### Typing

10. `m = mutarray::from_list(xs)` -> `m : mutarray`: **yes.**
11. A function returning `m` infers `mutarray`: **yes** (also through
    forwarding).
12. A List literal of only such values infers `List[mutarray]`: **yes**
    (already true in the parent commit for `mutable_array_allocate`).
13. `list_get` from that List with a dynamic index infers `mutarray`:
    **yes.**
14. Any of this `MutableArray[T]`: **no.**
15. Slots more precisely typed: **no** (`mutable_array_get` : `any`).

### Refinement

16. `if mutarray?(x): mutable_array_capacity(x)` compiles for arbitrary `x`:
    **yes.**
17. True-branch type of `x`: `mutarray`.
18. Outside the branch: `any` (no fact escapes; a later use re-imposes the
    checked requirement).
19. The predicate allocates: **no.**
20. Identical on all backends: **yes** (interp, compile, cranelift-generic,
    cranelift, and a standalone AOT executable, also under GC stress).

### Inference

21. Unconditional `mutable_array_capacity(x)` still infers a checked
    `mutarray` requirement: **yes.**
22. A use guarded by `mutarray?(x)` avoids imposing `mutarray` on the
    parameter: **yes** (`x: any (none)`).
23. Trusted/checked semantics otherwise unchanged: **yes** (no change to
    `hir/signatures.tcl`).
24. Exact-value inference changes: **no.**

### Counterfactual

25. Primary MutableArray failures that disappear: **0 of 9.**
26. Survivor reasons: the rows pass through the `geo_append`/`geo_finish`
    builder (untyped `value` parameter -> untyped slot in a `[storage,
    length]` pair -> `mutable_array_freeze` -> plain `list`); the constructor
    fact is intact until `geo_append`.
27. The four MutableArrays inside positional records remain failures:
    **yes.**
28. If any did not: n/a.
29. New table: see "35-site" (15 / 9 / 7 / 4 / 0 resolved / 0 new).
30. Accidental generic "solutions" through a special case: **none**; nothing
    changed.
31. A record-shaped List acquired positional typing: **no.**
