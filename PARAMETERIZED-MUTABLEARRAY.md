# Parameterized MutableArray[T]

## Outcome

**Delivered:** `MutableArray[T]`, a real one-argument applied type
(`{mutarray T}` internally, `MutableArray[T]` in source and diagnostics),
built on the existing applied-type machinery (`hir::types::constructors`,
`resolveApplication`, `Bound`, `show`, the `-result-shape` mechanism for
natives) and on the existing typed-callable escape audit
(`hir/callables.tcl`), which is generalized from "callable contract bearing"
to "non-erasable contract bearing". Two typed constructors
(`mutarray::from_list`, and the new `mutarray::create(capacity, default)` in
`lib/mutarray.bot`), typed `mutable_array_get` / `_freeze` / `_set` /
`_copy`, invariance, and a transitive non-erasure rule.

**Unchanged, as required:** the runtime object (`MutArrayObj`, `KIND_MUTARRAY`,
`{mutarray ID}`, GC layout, slots, capacity), `mutable_array_allocate`
(still returns the bare `mutarray`), every raw operation on a bare `mutarray`,
`hir::exact`, the frozen source corpus (every `.bot` file except
`lib/mutarray.bot`), and the generated code of the whole canonical corpus
(byte-identical).

**Measured, and different from what one might hope:** because the frozen
corpus uses raw allocation only, nothing in it changes: the strict-contract
counterfactual is byte-identical before and after (10 programs, 35 sites), the
corpus census is identical, the AOT classification of all 245 instances is
identical, the scalar assembly of the 17 programs and the NIR of the 8
benchmarks are byte-identical. A zero-site change, reported honestly. What the
milestone *does* show, with scratch controls that are not merged, is that the
nine builder sites disappear once the builder stores rows in a
`MutableArray[mutarray]` created with `create` (§ "Nine builder-flow sites
revisited"); what is left after that is a struct boundary (the
`[storage, length]` pair) and the one-builder-for-three-element-types generic
relation, not anything about MutableArray.

**Soundness review found and closed two holes before shipping** (stop
condition 97): a *forward reference* from a closure to a local that is bound
later is typed `any` by `hir::types::ForwardType`, which handed out an erased
alias of a typed array (`x = peek(); if mutarray?(x): <store an int>`), and the
same for a forward reference to a *function* whose result is a typed array
(`caller()` calling a later-defined `later()`, or passing `later` to an untyped
parameter). Both are now rejected (`hir::callables::CheckReference`), with
tests (`mat-atk-17..20`). See "Element-contract bearing / non-erasure".

## Motivation

The previous audit showed that MutableArray *kind* typing was already complete
and that the remaining loss was different:

```
value : T  ->  mutable storage  ->  read / freeze
```

lost `T`. Conceptually the missing theorem is `set(array, i, v:T)` preserves
`MutableArray[T]`, `get(array, i) : T`, `freeze(array, n) : List[T]`. That is a
real semantic property of a mutable container and deserves a real type.

## Why MutableArray[T] is now justified

Two things are true now that were not before. (1) `mutarray?`, `from_list` and
the `List[mutarray]` chain establish the *kind* everywhere, so the only
information still lost across mutable storage is the element contract.
(2) The escape audit for typed callables already existed and already has the
exact shape needed for a second bearing form, so a mutable contract can be
introduced without a second bespoke checker.

## Surface syntax

```
fn f(xs: MutableArray[str]) -> MutableArray[str]: ...
List[MutableArray[int]]
MutableArray[List[str]]
MutableArray[MutableArray[int]]
Fn{ args: [MutableArray[str]], return: MutableArray[str], errors: [] }
```

Legal anywhere a type is legal; nesting works (up to the aggregate depth 3, see
limitations). `MutableArray` alone (no argument), `MutableArray[int, str]`,
`mutable-array[int]` are rejected. No generic syntax was added (`fn f[T]`,
`where T`, `forall` are all syntax or unknown-type errors); the only new type
syntax is `MutableArray[T]` and the only new function is `mutarray::create`.

## Internal type representation

`{mutarray ELEM}`, a two-element list, exactly parallel to `{immutableSet ELEM}`
and `{list ELEM}`; the bare atom `mutarray` remains the raw kind.

* `hir::types::constructors` gains `MutableArray 1`; `resolveApplication` maps
  it to `MakeMutArray`; the source parser and `ResolveTypeExpr` needed no
  change (the grammar already accepts any `NAME[ARG]`), and `hir/read.tcl`'s
  type notation (`ParseType`/`CanonicalType`) learned the one new form.
* `IsSpecific` includes `mutarray`, so `kindOf` is `mutarray` and `semantic`
  is `mutarray`: every backend, every kind guard and every native
  `-param-types {mutarray ...}` check sees an ordinary MutableArray.
* `MakeMutArray` does **not** fold `any` into the bare kind (unlike
  List/ImmutableSet): `MutableArray[any]` is a distinct, printable type. It
  folds a `never` element (the empty List) into `any`. Past the aggregate depth
  it returns the bare kind; that is sound only because the audit compares a
  value's own type with the position it flows into *exactly*, so a precise
  array flowing into a truncated position is an erasure and is rejected.
* `show` renders `MutableArray[T]`; `hir::read::ParseType` and
  `CanonicalType` round-trip it (`mat-alg-7`).

## Runtime erasure

`T` never reaches the runtime. `git diff` touches no file under `native/`,
`core/value.tcl`, or the Tcl handle representation; the only `core/` edits are
two new *static* `-result-shape` tags on `mutable_array_get` / `_freeze`
(metadata read by `hir::types::ShapeResult`) and their validity check. No
opcode was added: `mutarray::create` lowers to `mutarrayallocate` +
`mutarrayset` (`out/guard-elision.txt`). Native runtime code is byte-identical.

## Bare mutarray vs MutableArray[T]

`mutarray` is the raw, element-untyped substrate type. Static writable
substitutability and runtime-kind compatibility are different questions:

| view | admissible for |
|---|---|
| `MutableArray[T]` | `MutableArray[U]` iff T and U are equivalent (identical, or each admissible for the other); the kind checks of natives; `mutarray?` |
| `MutableArray[T]`, T != any | **not** the bare `mutarray`, **not** `MutableArray[any]`, **not** `any` |
| bare `mutarray` | `mutarray`; `MutableArray[any]` |
| `MutableArray[any]` | `MutableArray[any]`; the bare `mutarray` |

`MutableArray[any]` and the bare `mutarray` are mutually admissible on purpose:
the contract "every slot holds an `any`" restricts nothing, so no view of one
can violate the other, and code that used `from_list` on heterogeneous data and
passed the result to a `mutarray` parameter keeps working.

## Initialization model

No typestate. A `MutableArray[T]` exists only from a constructor that fills
every slot: `from_list(xs)` writes every slot from `xs`; `create(n, d)` writes
`d` into every slot before returning. There is no uninitialized or partially
initialized typed array; raw `mutable_array_allocate` stays raw and is never
promoted (no inference from allocate + set patterns, tests `mat-raw-4`,
`mat-nc-2`).

## mutarray::from_list typing

```
fn from_list(xs: list) -> mutarray:      # unchanged runtime body
```

The *call* is typed by the central container-rule registry
(`hir/containers.tcl`): `xs : List[T]` gives `MutableArray[T]`; a broad `list`,
`List[any]`, a heterogeneous literal and `[]` all give `MutableArray[any]`
(never the bare kind; documented canonical form). The element type is the
argument's *static* element type; exact list contents are never inspected.

| call | type |
|---|---|
| `from_list(List[int])` | `MutableArray[int]` |
| `from_list(List[str])` | `MutableArray[str]` |
| `from_list(List[MutableArray[int]])` | `MutableArray[MutableArray[int]]` |
| `from_list(list)` / `List[any]` / `["x", 1, true]` / `[]` | `MutableArray[any]` |

## mutarray::create typing and implementation

```
fn create(capacity: int, default) -> mutarray:
    storage = mutable_array_allocate(capacity)
    loop i from 0 to capacity:
        mutable_array_set(storage, i, default)
    storage
```

Ordinary Botlish over the existing substrate; no new native. `create(n, d : T)`
is `MutableArray[T]` for the *static type* of `d` (an exact callable is
recorded by its structural contract; a refined default such as a `Byte` gives
`MutableArray[Byte]`; a literal `0` gives `MutableArray[int]`, never an
exact-value element). Capacity 0 still establishes `T` (the object contract,
not the current occupants, defines `T`). A negative capacity is not clamped:
`mutable_array_allocate` raises `RANGE` (identical to raw allocation, pinned by
`mat-run-3`). Every positive-capacity slot is initialized; the default is shared
by reference (not copied deeply), pinned by `mat-run-4/5`.

## Mutable invariance

`MutableArray[T]` is invariant. `subtype`, `Admits`, the callable variance
rules, `Preserves` and `lub` all go through one relation,
`hir::types::Equivalent`. Pinned: `MutableArray[Byte]` is not `MutableArray[int]`
(`mat-inv-1`); `MutableArray[str]` is not `MutableArray[any]` (either way,
`mat-inv-2`); invariance is deep (`List[MutableArray[str]]` is not
`List[MutableArray[any]]`, `mat-inv-3`); structural `Fn` parameters and results
cannot turn it into covariance (`mat-inv-5/6`).

## Element-contract bearing / non-erasure

The compiler already had one general concept for "a value whose static
contract must not disappear at an untyped boundary": callable bearing
(`hir/callables.tcl`, TYPED-CALLABLE-ESCAPE-SOUNDNESS.md). It is generalized,
not duplicated:

* `Bearing(T)`: a `MutableArray[T]` with `T` other than `any` is bearing;
  bearing is transitive through `List`, `ImmutableSet`, `MutableArray`,
  structural `Fn` results and exact blocks' results, by the existing recursion.
* `Preserves(type, position)`: a MutableArray is preserved only into an
  equivalent MutableArray contract (invariance), through the same recursion.
* Every position the audit already visits (call argument, `if` join, loop
  join, return, trailing value, returning loop, handler, Result wrapper) now
  protects arrays; the per-call argument contexts come from `ArgContexts`,
  extended for: the container rules of the library constructors
  (`hir/containers.tcl` `BlockContexts`), the two element-projecting natives
  (their existing shape mechanism), `mutable_array_set/copy` (the stored value
  must land in the array's own element contract), and *non-retaining* natives
  (scalar result, no mutation: `list_length`, `mutarray?`, `capacity`, ...),
  which merely use their arguments.
* **Forward references** are a second way a view can be less precise than the
  binding: `hir::callables::CheckReference` compares every reference's type with
  the binding's own type and rejects a bearing array that a closure would see
  as `any`.

Diagnostics (all `TYPE`):

```
argument for parameter "x" cannot be proven to satisfy mutarray (argument type:
  MutableArray[str], ...); MutableArray[str] would lose its element contract as
  the raw mutarray type, permitting writes of values that are not str
cannot erase element contract MutableArray[str] passed as an ordinary call
  argument: its element type would be lost, permitting writes of values it does
  not admit through an alias that no longer knows the contract (a
  MutableArray[T] is invariant and may only flow into a position that keeps
  MutableArray[T])
cannot erase element contract MutableArray[str]: "m" is read here as any, before
  its binding is initialized (a forward reference from a closure created ahead
  of it), ...; define the binding before the code that reads it, or pass the
  array in as a typed parameter
```

## Alias soundness

Aliases keep the type (`b = a`), and any store through any alias is checked
against it (`mat-inv-7`). There is no legal program that views one array under
two element contracts (`mat-inv-8`); the second view is rejected. A raw array
never contains a contract-bearing value (a store, a copy or a `from_list` into
untyped storage is rejected), so a `get` from raw storage can never yield a typed
array; a typed array's slots only ever hold `T`s.

Attempted corruption and its rejection:

```
fn smash(x: mutarray):
    mutable_array_set(x, 0, 123)
m = mutarray::from_list(["hello"])
smash(m)          # rejected at compile time (mat-atk-1)
```

```
fn f(x):                                   # untyped: x is any
    if mutarray?(x): mutable_array_set(x, 0, 123) else: unit
m = mutarray::from_list(["a"])
f(m)              # rejected: cannot erase element contract MutableArray[str]  (mat-atk-2)
```

Hard-acceptance attacks pinned as compile-time rejections (`mat-atk-1..21`, the last a 19-program flow matrix, `audit/parameterized-mutablearray/tools/probes-attack-matrix.txt`, in which every sink is followed by a write of the wrong value and nothing compiles):
raw `mutarray` parameter; `any` parameter (implicit and explicit); untyped
parameter then `mutarray?` then write; declared `any`/`mutarray` result; joins of
different contracts or of typed with raw; List literals and `list_append` that
would join contracts; `List[MutableArray[str]]` into an untyped / `list` /
`any` parameter; nested arrays at every depth; storing a typed array into a raw
array or a `MutableArray[any]`; passing through a callable value or an untyped
callee; an inferred raw contract; forward reference to a binding; forward call of
a function that returns an array; passing a function that returns an array to
an untyped parameter; `mutarray?` used as if it proved the element type.

## Typed get

`mutable_array_get(MutableArray[T], i) : T` (via `-result-shape
{mutarray-element 0}`, next to `list_get`'s `element` shape); bare
`mutarray` still `any`. The same runtime operation; the distinction is static.
A typed `int` read needs no `guard int` before arithmetic
(`out/guard-elision.txt`).

## Typed set

`mutable_array_set(MutableArray[T], i, v)` requires `v` proven admissible for
`T` by the ordinary proof every declared parameter is held to
(`ProvesValueAcceptedBy`: subtype, or the argument's integer range/exact-set
fact inside an integer-domain `T`), else a compile-time `TYPE` error:
`value of type int is not admissible to element type str of MutableArray[str]`.
Never a widening, never an inserted guard; the array keeps its type. Bare
`mutarray` keeps `value: any`. Bounds (`RANGE`) are unchanged
(`mat-run-7`).

## Typed freeze

`mutable_array_freeze(MutableArray[T], n) : List[T]` for a dynamic `n` (count
affects length only; via `{mutarray-freeze 0}`), `List[any]` is the broad
`list`; bare `mutarray` still `list`. Nested contracts survive:
`freeze(MutableArray[MutableArray[int]]) : List[MutableArray[int]]`.

## Capacity

`int` for both, independent of `T`; a non-retaining native, so it keeps a typed
argument. No metadata change.

## Copy

`mutable_array_copy(dst, ds, src, ss, n)`:

* typed destination `MutableArray[T]` (T other than `any`): the source must be
  a `MutableArray[S]` with `S` admissible for `T` (so `S <: T` copies are
  accepted, e.g. `MutableArray[Byte]` into `MutableArray[int]`); a bare/unknown
  source is rejected (its slots prove nothing);
* raw destination (or `MutableArray[any]`): accepted for non-bearing elements;
  copying elements that themselves carry a contract into untyped storage is
  rejected as an erasure;
* raw to raw: unchanged.

This is the general `S admissible for T` rule, not only equal contracts.

## Type algebra

* equality/subtype: `Equivalent` on the element contracts (invariance);
* `lub(MutableArray[T], MutableArray[T]) = MutableArray[T]`;
  `lub` of different contracts, of typed with raw, of typed with `any`, is
  `any` (there is no typed join); the audit then rejects the branch that would
  lose the contract at the join with the erasure diagnostic;
  `lub(MutableArray[any], mutarray) = mutarray`;
* `glb`/requirement meet: identical or equivalent contracts meet in
  themselves; a native's kind requirement (`mutarray`) adopts an applied
  contract (each use that could write is re-verified against the value's real
  type); conflicting contracts have no meet (the existing failure);
* `narrow`: a kind test never changes an applied contract; a declared
  contract is adopted by a raw/unknown seed.

## Specialization / KeyType

`KeyType` projects `MutableArray[T]` to the kind `mutarray` (List keeps its
applied argument; ImmutableSet and everything else project). This does not
lose the contract: a typed array can only reach a parameter that declares its
full contract (or an untyped forwarder whose trusted-inferred contract is
that declaration), the declared/entry type is what the instance seeds
(`Analyze`/`Reanalyze` adopt a specific declared type outright), and the audit
forbids every other route. Consequently the change creates **no new instances
anywhere**: the 245 instances of the canonical corpus are identical
(`out/aot-{before,after}.txt`), and typed helpers called with many differently
built arrays share one instance (`mat-sp-6`). Retaining `T` in the key would
only duplicate instances between `mutarray` and `MutableArray[any]` callers.

## Structural Fn integration

`MutableArray[T]` is legal in `Fn{...}` argument and return types and is
bearing there. Callable argument contravariance goes through `Admits`, return
covariance through `ReturnFits`; since both bottom out in the invariant
relation, `Fn` variance cannot make mutable contracts covariant (tests
`mat-inv-5/6`: a callee taking `MutableArray[any]` or the raw `mutarray` is not
usable where `MutableArray[str]` is passed, and a function returning
`MutableArray[str]` is not usable as one returning `MutableArray[any]` or raw).

A relational function value `(T) -> MutableArray[T]` is not representable
without generic function types. `f = mutarray::create; f(2, "x")` still
returns `MutableArray[str]` (the exact callee identity is known and carries the
rule, also through aliases: `mat-id-2`); the same function viewed through a
declared structural `Fn` exposes only the raw result (`mat-id-3`); and the
result is then a fresh array that has no typed alias, so this is sound.

## mutarray? interaction

`mutarray?(x)` with `x : any` refines to the bare `mutarray` only (never
`MutableArray[?]` or `MutableArray[any]`); with `x : MutableArray[str]` the true
branch keeps `MutableArray[str]` (and the test is decided statically). It
cannot satisfy a typed parameter (`mat-atk-14`). Public meaning unchanged; no
element-type predicate or descriptor exists (`mat-raw-5`).

## Exact-value interaction

`hir::exact` is unmodified; no array or content of an array has an exact fact
(`mat-ex-1/2`).

## Raw allocation remains raw

`mutable_array_allocate(n) : mutarray`, raw get/set/freeze/capacity/copy keep
their exact legacy behavior, raw arrays stay heterogeneous and writable
(`mat-raw-1..4`); no element type is inferred from writes (`mat-nc-2`).

## Source-fence result

The only canonical `.bot` file changed is `lib/mutarray.bot` (`create` added,
header updated). `mat-fence-1` scans `bench/`, `examples/surface`,
`examples/stdlib` and `lib/` for uses of `mutarray::create` / `MutableArray[`
outside comments.

## Central rule registry (identity, not spelling)

One file, `hir/containers.tcl`, holds every container-specific rule:

* module functions, keyed by the *resolved* module binding
  (`mutarray::from_list`, `mutarray::create`: the qualified name only a
  module section can create), indexed once per build (`hir::containers::index`,
  called from `hir::check`) into `intrinsicBlocks: BlockId -> rule`, and consulted
  in `hir::types::Call` for the exact callee block. A user function named
  `from_list`/`create` acquires nothing (`mat-id-1`); an alias keeps the rule
  (`mat-id-2`);
* the two mutating natives (`mutable_array_set`, `mutable_array_copy`) for the
  static store/copy proof, called from `hir::range::VerifyCall`, which already
  has each expression's Range;
* the escape-audit argument contexts for these.

`mat-id-4` pins that no other pass names these functions.

## Strict-counterfactual before/after

`audit/intrinsic-function-contracts/tools/validity.tcl` with
`variant-all-trusted.patch`, unchanged corpus and diagnostics:

| | programs with diagnostics | sites |
|---|---|---|
| before (`498e3c3`) | 10 of 31 | 35 |
| after | 10 of 31 | 35 |

`out/strict-counterfactual-{before,after}.txt` are byte-identical (after
normalizing the scratch path) and identical to the previous milestone's. No
site changed category. Why not: the frozen corpus builds every row table and
every builder with raw allocation, and the loss is downstream of the
constructor (below).

## Positive builder controls

Scratch rewrites of representative builder operations, appended to a copy of
`csv_records.bot` under `variant-all-trusted` (`tools/controls.tcl`,
`out/controls-variant.txt`); nothing merged:

| control | verdict | what it shows |
|---|---|---|
| typed storage `MutableArray[mutarray]` from `create(0, allocate(0))`, grown by `create` + `copy`, `append` by `set`, frozen; `first = list_get(rows, 0)`; `ht_get(first, ..)` | accepted | the expected typed flow works: `freeze : List[mutarray]`, `list_get : mutarray` |
| same, as a recursive typed builder (`tb_build`) with `List[List[str]]` records | accepted | the typed storage is threaded as parameters, with explicit annotations |
| raw rows `[allocate, allocate]` | accepted | raw programs unchanged |
| `[from_list([1]), from_list([2, 3])]` into `ht_size` (inferred raw `mutarray` contract) | rejected | typed arrays do not flow into raw-`mutarray` contracts (by design) |
| `from_list` rows into a `MutableArray[int]` parameter | accepted | |
| `pair = [typed_storage, 1]` | rejected | a typed array cannot ride in a positional pair: struct boundary |
| untyped forwarder to a typed function | accepted | a trusted-inferred typed contract is sound |
| untyped raw writer given a typed array | rejected | inferred raw contract |
| `set(raw, 0, from_list(..))` | rejected | typed array into raw storage |

## Nine builder-flow sites revisited

Sites (`csv_records.bot`): `452:{20,45,81,99}`, `453:{32,55,77,100,124}`: `first`,
`second`, `presized_first` passed to `ht_get`/`ht_size`, which under the
counterfactual demand a `mutarray` argument. All nine have one chain
(`out/trace-after-variant.txt`):

```
row_table -> ht_alloc                    raw table: allocate(5), heterogeneous slots
build_rows -> geo_append(outer, table)   [storage, length] positional pair; untyped `value`
geo_finish -> mutable_array_freeze       raw storage: `list`, not List[mutarray]
first = list_get(rows, 0)                any
```

For each of the nine:

* **Would direct use of `create`/`from_list` establish `T` here?** For the
  *row table itself* no, and it is not needed: `ht_alloc` is a record-shaped
  raw array (three arrays and two ints in one array), so even `create` would
  give `MutableArray[any]`, which is the raw kind; the consumer only needs the
  kind `mutarray`, which is already known at the constructor. For the *rows
  storage* yes: `create(cap, filler)` gives `MutableArray[mutarray]`, whose
  freeze is `List[mutarray]`, and the control above shows the consumers accepted.
* **Where is `T` subsequently lost?** At three points, in order: the untyped
  `value` parameter of `geo_append` (generic value -> element relation); the
  `[grown, length + 1]` positional pair (struct/product); and
  `mutable_array_freeze` of a raw storage (raw builder).
* **What does the remaining loss require?** Category after this milestone,
  per site: **raw builder** (allocation without a filler value) plus
  **struct/product boundary** (the pair) plus a **generic relation** (one
  `geo_append` serves three element types: field strings, record lists, row
  tables). None is typed mutable storage any longer: this milestone provides
  that. Without any generic-function feature, a source refactor could remove
  all nine by (a) storing rows in a `MutableArray[mutarray]` created with
  `create`, (b) threading storage and length as two typed parameters instead
  of a pair, (c) annotating `value: mutarray`. Because `geo_*` is shared by
  three element types, that means one typed copy per element type (or
  `MutableArray[any]`); a single shared builder needs the generic relation.
  Not performed here.

The four record-contained sites (`[storage, length]` in `csv_geometric.bot:52:22`,
`csv_records.bot:126:22`; `[newControls, newKeys, newValues]` in
`csv_records.bot:311:29`, `hashtable.bot:226:29`) stay unchanged: they are
struct problems. The pair sites would additionally need the pair split;
the `dest` triple is homogeneous only by accident of the hash-table layout
(expected to yield to an explicit `List[mutarray]` annotation; not measured).

Updated terminology: the old label "MutableArray failure" is retired. The
current buckets are *raw builder*, *generic value -> storage relation*,
*record/struct boundary*, and *untyped function boundary*.

## Remaining generic boundaries

Unchanged (7): `list::find`, `chars_of`, `records` accumulators, `ht_fold`, and
now also every use where an untyped function carries a typed array through
(`fn identity(x): x` rejects a typed array; `mat-sp-5`). Also inferred
contracts: an untyped function that merely reads or takes the capacity of an
array infers the raw `mutarray` contract and therefore rejects typed arrays,
because no effect typing separates reads from writes (`mat-bd-5`).

## Remaining struct boundaries

Unchanged (15): scan pairs, `[storage, length]`, `[newControls, ...]`,
`[name, dependencies]`. A typed array inside a positional pair is rejected
(`mat-bd-2`), which is the correct conservative answer in the absence of
product types.

## Diagnostics

See "Element-contract bearing". Also: a bad store, a bad copy
(`cannot copy from MutableArray[int] into MutableArray[str]: source element type
int is not admissible to destination element type str`), an invariance failure
(`MutableArray is invariant in its element type: MutableArray[str] cannot be
viewed as MutableArray[int], ...`), a raw source into a typed parameter (`only a
value already known to be a MutableArray[str] satisfies this contract: a kind
test proves the kind, never the element type, and no element check is inserted`).
`out/probes-*.txt` has the diagnostic of every probe.

## Runtime / GC effects

None: no runtime object, GC layout, rooting, slot or capacity change; the
lowering of `create` is `mutarrayallocate` + `mutarrayset`. Verified:
`tests/mutable-array-type.test` (118 tests, including a standalone AOT
executable exercising managed defaults, nested typed arrays,
`List[MutableArray[T]]`, aliases, freeze and copy) passes on all four
in-process backends and under `BOTLISH_NATIVE_GC_STRESS=1`; see "Full
regression".

## Generated-code effects

The frozen corpus is byte-identical: `native/generate-scalar-audit.tcl` output
for all 17 programs equals the committed `audit/native-scalar-asm` (only that
directory's `README.md` differs, in its `git commit:` line), and the NIR of the
8 benchmarks is identical. For a focused typed program the stronger types give
the existing elision: a typed `MutableArray[int]` read has no `guard int` before
`iadd`, the raw one keeps `guard int` (`out/guard-elision.txt`). No backend
rule was added.

## Compile-time impact

Median of 7 front-end compiles of the same 17 programs
(`audit/intrinsic-function-contracts/tools/compiletime.tcl 7`), parent tree vs
this tree, two interleaved runs (`out/compiletime-*-run{1,2}.txt`):

| | before | after |
|---|---|---|
| run 1 total (ms) | 987.3 | 982.3 |
| run 2 total (ms) | 1018.9 | 968.2 |

Differences of -0.5% and -5.0% are run-to-run noise (an earlier pair of runs on
an earlier revision of this tree gave +5.1% and -7.6%: opposite signs). The
added work is one `dict for` over the binding table per build
(`hir::containers::index`), a constant-time rule lookup per exact block call,
and a `ref` comparison in the escape audit. Instance count: unchanged (245).

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl` (Tcl 9.0.1 from the pinned
Ubuntu packages, native backend built with rustc 1.98.1) runs the whole suite
on both Tcl backends; `stdlib.test`, `native*.test`, `backends.test` and others
additionally run the Cranelift backends inside each of those runs:

| backend | total | passed | skipped | failed |
|---|---|---|---|---|
| interp | 3045 | 3045 | 0 | 0 |
| compile | 3045 | 3045 | 0 | 0 |

The parent tree is 2926 tests per backend, 2926/2926 (measured before any
change). This milestone adds `tests/mutable-array-type.test` (118 tests) and
one test in `tests/mutarray-construction.test` (75 -> 76, plus updated
expectations for the now-typed constructors): 2926 + 118 + 1 = 3045.

Additional runs, all passing: `mutable-array-type.test` (118) on interp,
compile, cranelift-generic and cranelift; `mutable-array-type.test` (118),
`mutarray-construction.test` (76) and `native-mutarray.test` (49) under
`BOTLISH_NATIVE_GC_STRESS=1` on interp and compile; `mutarray-construction.test`
on cranelift and cranelift-generic. Every parity test in the new file runs its
program on interp, compile, cranelift-generic and cranelift and requires
identical outcomes; one test builds a standalone AOT executable and runs it
with and without GC stress. The full suite under GC stress runs in CI
(`gc-stress` job); it was not repeated locally.

## Benchmark parity

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 bench/bench.tcl -runs 1` (native backend
built, rustc 1.98.1): exit status 0. `bench.tcl` exits 1 if the Botlish
backends disagree on any program's result, and none did, on all 8 canonical
benchmarks (fib, lex-strategy, loop-count, refined-checks, source-checks,
sum-refined, test-selection, uri-steady) across Tcl interp, Tcl compile and
Cranelift (`out/bench-runs1.txt`). Timings are not compared: the generated code
is byte-identical to the committed audit corpus, so there is nothing to
compare. The stdlib corpus programs are agreement-tested by `tests/stdlib.test`
and `tests/bench-corpus.test` inside the full regression.

## Known limitations

* **Untyped function boundary.** A typed array cannot be passed to an untyped
  parameter, and inferred `mutarray` contracts (from natives) reject typed
  arrays. `fn identity(x): x` cannot carry `MutableArray[T]`; that is
  generic-function territory. Sound by rejection.
* **Forward references.** A closure that reads a local (or calls a function)
  bound later types it as `any`; when that would carry an array contract the
  program is rejected (define before use, or pass as a typed parameter). Mutual
  recursion between functions whose results are typed arrays is therefore
  rejected. Direct self-recursion works.
* **Nesting depth.** `MakeMutArray` shares the aggregate bound (3): four
  nested levels are rejected as an erasure, never widened. Lists of lists of
  lists of arrays likewise.
* **Callable values.** `mutarray::create` viewed through a structural `Fn`
  exposes the raw result.
* **No effect typing.** A read-only or capacity-only untyped wrapper rejects
  typed arrays.
* **-strict 0 mode.** With diagnostics recovered, a typed store violation has
  no run-time guard (by design, spec item 64); the region is a native AOT
  blocker exactly like every other static TYPE diagnostic.
* **Compatibility.** `from_list` results are now `MutableArray[T]`, so passing
  one to a parameter declared `mutarray` is rejected (the previous milestone's
  `mutarray-type-9` accepted it); the canonical corpus does not do this. The raw
  constructor, or a `MutableArray[any]` (mutually admissible with the raw kind),
  is the migration path.
* `MutableArray` values still cannot be returned to the native host (unchanged).

## Readiness for generic relationship inference

The mutable-container abstraction exists and its boundary is now measured. The
next question, generic functions, has concrete evidence: the two things a
`MutableArray[T]`-aware program cannot yet say are (1) `T in -> T out` for an
untyped function that only forwards or reads an array
(`identity`, wrappers over `get`/`capacity`), and (2) the shared-builder
relation `value : T -> MutableArray[T]` used by `geo_append` for three element
types. The pair (struct) boundary is orthogonal. Recommended order: struct/
product typing for the `[storage, length]` shape, then generic function
relations, whose first users are `list::find`/accumulators and the shared
builder.

## Answers to the required questions

### Architecture

1. **Representation:** `{mutarray ELEM}` (a two-element list), rendered
   `MutableArray[ELEM]`; the bare atom `mutarray` is the raw kind.
2. **Existing applied-type machinery:** yes: `constructors`,
   `resolveApplication`, `Bound`, `show`, `ParseType`, `-result-shape`, the
   escape audit.
3. **Does the runtime object contain T?** No.
4. **Meaning of bare `mutarray`:** the raw, element-untyped MutableArray;
   writable with anything; admissible for and from `MutableArray[any]` only.
5. **Does raw allocation still return bare `mutarray`?** Yes.
6. **Which operations create `MutableArray[T]`?** `mutarray::from_list`,
   `mutarray::create`, an explicit `MutableArray[T]` contract, and ordinary
   propagation of an already-typed value.
7. **Is element type ever inferred from raw writes?** No.

### Construction

8. `from_list(List[int])`: `MutableArray[int]`.
9. `from_list(list)`: `MutableArray[any]`.
10. `create(10, "x")`: `MutableArray[str]`.
11. `create(0, x:T)`: `MutableArray[T]` (capacity 0, `T` from the default).
12. Yes: `create` writes the default into every slot of a positive capacity.
13. Yes: the default/source elements are shared by reference according to
    existing value semantics, never deep-copied (`mat-run-4/5`).

### Mutation

14. `get(MutableArray[T])`: `T`.
15. `set(MutableArray[T], ...)` accepts exactly the values proven admissible to
    `T`; anything else is a compile-time error.
16. Does an incompatible store widen `T`? No.
17. `freeze(MutableArray[T])`: `List[T]`.
18. For bare `mutarray`: `get : any`, `set` takes any value, `freeze : list`
    (unchanged).

### Soundness

19. Covariant? No. Invariant.
20. `MutableArray[str]` as `MutableArray[any]`? No.
21. Silently as bare `mutarray`? No.
22. Silently erased to `any` and recovered by `mutarray?`? No.
23. **How the compiler prevents it:** `MutableArray[T]` (T other than `any`) is
    a bearing type in the generalized escape audit (`hir/callables.tcl`): every
    position that changes a value's type is checked with `Preserves`, which
    admits only an equivalent MutableArray contract; forward-reference views
    are compared with the binding's own type; invariance keeps every
    admissibility check exact.
24. **Transitive through aggregates?** Yes, through `List`, `ImmutableSet`,
    `MutableArray`, `Fn` results/arguments and exact blocks' results.
25. **Alias corruption attempt:** `smash` / `f(x)` above; both rejected
    (`mat-atk-1/2`).

### Refinement

26. `mutarray?(x:any)` proves `mutarray` only.
27. Already `MutableArray[str]`: preserved.
28. Can `mutarray?` recover an element type? No.

### Specialization

29. **Does `KeyType` preserve `MutableArray[T]` like other applied types?** No:
    it projects to the kind, like ImmutableSet and unlike List; see the
    argument in "Specialization / KeyType" (no contract loss, no instance
    change).
30. **Can a concrete specialized instance retain the element contract?** Yes:
    through the declared/entry type it seeds (`mat-sp-2/3`, `mat-bd-1`).
31. **Excessive duplication?** No: 245 instances, identical.
32. **Where does absence of generic function typing force precision loss?**
    Untyped forwarders/wrappers of arrays (rejected), callable values of
    `create`/`from_list` (raw result), shared builders across element types.

### Corpus

33. Does the frozen corpus change? No.
34. Does the strict counterfactual change? No.
35. Why not? The corpus uses raw allocation and record-shaped builders; the
    loss is downstream of the constructor.
36. **The nine former "MutableArray" sites are now:** *raw builder* (allocation
    without a filler), *struct/product boundary* (`[storage, length]`), and
    *generic relation* (the shared `geo_append` value -> element). None is a
    MutableArray-kind or missing-typed-storage problem.
37. **Which would disappear after a source refactor from raw allocation to
    typed construction, without any generic-function feature?** All nine
    primary sites, with typed storage created by `create`, storage and length
    threaded as two parameters, and `value` annotated (control accepted); at
    the cost of one typed builder per element type. The `dest` triple sites
    likely also, by annotation. The pair-record and shared-builder generality
    do not.

## Files

New: `hir/containers.tcl`, `tests/mutable-array-type.test`,
`PARAMETERIZED-MUTABLEARRAY.md`, `audit/parameterized-mutablearray/`.
Modified: `hir/types.tcl` (representation, algebra, shapes, call rule),
`hir/callables.tcl` (bearing generalization, contexts, reference check,
diagnostics), `hir/range.tcl` (admissibility, native hook, clauses),
`hir/signatures.tcl` (meet), `hir/read.tcl`, `hir/hir.tcl`, `core/mutarray.tcl`
and `core/native.tcl` (two result shapes), `lib/mutarray.bot` (`create`),
`tests/mutarray-construction.test` (expectations updated for typed
constructors), `README.md` (one row).
