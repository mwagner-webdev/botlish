# Structs and struct values

This milestone adds **structs** to Botlish: anonymous struct values
(`{x: 1, y: 2}`), nominal named structs (`struct Point:` and
`Point {x: 1, y: 2}`) and static field projection (`value.field`), through the
surface syntax, HIR, Core IR, the Tcl interpreter and compiler, NIR and the
Cranelift backend (including standalone executables). It then uses them to
replace the positional Lists that the corpus had been using as records, under
a controlled source-fence amendment, and measures what that did.

Every number below is measured, with the tools in `audit/structs/` (run
against the parent fence `84f4d68`, tree `native/target` shared, as "before",
and against this tree as "after"). Nothing is derived from an expected count.

## Outcome

* **The feature works end to end.** Anonymous and named structs construct,
  project, compare, print, hash, nest, sit in `List`/`MutableArray`/
  `ImmutableSet`, capture in closures, cross modules, and run identically on
  the four backends (interp, compile, cranelift-generic, cranelift) and in
  standalone executables, with one exception that is a design consequence, not
  a bug (see "Known limitations": `cranelift-generic` cannot run a program
  whose projections are proven only by semantic instances).
* **Static, never dynamic.** `x.field` is a slot known at compile time.
  There is no dynamic lookup in any compiled backend. An `any` receiver is
  rejected unless every generically live call of its function has a semantic
  instance in which the struct type is known.
* **Immutable.** No mutable struct, field assignment, update/spread, methods,
  map initializer, destructuring, positional access, reflection, FFI layout or
  annotation syntax for anonymous types was added.
* **The source refactor worked where the information was lost, and exposed
  what was hidden behind it.** The scan pairs `[field, index]` and
  `[fields, stop]`, the rehash triples `[controls, keys, values]` and the test
  group `[name, dependencies]` are gone. Positional literal-index reads fell
  from 60 to 16 (receivers with lost element types: 47 to 7), heterogeneous
  list literals from 41 to 10. `csv_parse` becomes `List[List[str]]` in
  `csv.bot` and in `csv_geometric.bot` (the two typed builders now hold
  `MutableArray[str]` / `MutableArray[List[str]]`), and `select_affected`
  returns `List[Test]` with `name : str`. The typed builder cost two declared
  contracts per builder file, forced by an obstruction that already existed
  (see "CSV scan refactor"); no compiler rule was added.
* **The strict counterfactual got larger, not smaller: 38 to 55 sites.**
  Fifteen product-related sites disappeared; 32 new ones appeared, all of the
  same, pre-existing class ("typed storage passed to an inferred raw
  `mutarray` contract", `build_rows`' class) now reaching the field and record
  builders because their element types became precise. See "Strict-
  counterfactual before/after".
* **Struct code allocates more than the virtualized positional Lists it
  replaced, and is a little slower.** The scan and rehash pairs were
  scalar-replaced by the existing escape/parameter-aggregate machinery (zero
  allocations). Structs are real objects: `csv_geometric_10000` allocates
  50014 more objects (+16.7%) and is 23.7% slower (best of 15; the small
  `csv_geometric` inputs measure 10-16% *faster*, which is run-to-run noise on
  a 0.2-4 ms workload), `csv_records` workloads +43% to +48% allocations and
  +8% to +41% time (best of 15). Per the stop condition, nothing was
  optimized: no struct scalar replacement was added.
  Machine code: `csv_geometric` +396 bytes (+5.2%), `csv_records` -267 bytes
  (-1.1%).
* **Regression:** 3403 tests per backend pass (interp, compile; 4 skipped on
  compile), up from 3282 (+121 new). GC stress, native coverage, Rust tests and
  benchmark parity: see the sections below.

## Terminology

The vocabulary used in code, tests and docs, and nothing else:

| term | meaning |
|---|---|
| **struct** | the language construct, declaration and type family |
| **struct value** | one concrete value |
| **named struct** | a nominal struct declared with `struct Name:` |
| **anonymous struct** | a structurally typed struct value written `{ ... }` |
| **struct field** | one named member |
| **field projection** | `value.field`, resolved statically |

**"record" is not a compiler or language concept here.** It survives only in
the pre-existing CSV vocabulary (`csv_records`, a CSV "record" is a line) and
in the `Person`-style prose of tests. The AST nodes are `anonstruct`,
`namedstruct`, `structdecl`, `project`; the HIR nodes `struct` and `project`;
the Core IR forms `struct` and `project`; the NIR ops `structnew` and
`structget`.

## Language syntax

```
{x: 1, y: 2}                   # anonymous struct value
{}                             # legal: the struct with no fields
{
    x: 1,
    y: 2,                      # trailing comma optional, newlines free inside braces
}

struct Person:                 # named struct declaration (a type, not a value)
    name: str
    age: int

Person {name: "Ada", age: 36}  # named construction: same initializer payload
geo::Point {x: 1, y: 2}        # module-qualified named construction
p.name                         # field projection: static, total
```

* `{` `}` in expression position mean a struct value; executable blocks stay
  indentation/colon based (`structsyn-blocks-stay-indentation`). Brace
  meanings that already existed (a type declaration's integer-set domain and
  `Fn{args: ..., return: ...}`) are unchanged
  (`structsyn-domain-and-fn-type-braces-unchanged`).
* `Name {` (an identifier, or `ns::Name`, directly before `{`) is a named
  construction; `f(x)` followed by a struct literal on the same or the next
  line parses as two expressions (`structsyn-call-then-literal-*`).
* `struct` is a keyword; a field name is an ordinary identifier.
* A struct declaration lives at the top level of a file or module and its
  fields are `name: Type` with any declarable type (including other structs,
  itself, `List[...]`, `MutableArray[...]`, `Fn{...}`).
* Fields are written in any order in a named construction; the declaration
  fixes the slot order.

## Anonymous struct semantics

`{x: a, y: b}` evaluates `a` then `b` in **written order** (a failing or
returning field expression propagates normally, before any struct exists), and
only then builds the value. Its identity is its **field set**, not the order it
was written: `{x: 1, y: 2} == {y: 2, x: 1}` is `true` and both print
`{x: 1, y: 2}` (canonical, sorted order). A duplicate field is a diagnostic.
Anonymous structs are not width-subtyped and cannot be spelled in annotations:
they appear only as inferred types (`List[struct{a: int}]` and so on).

## Named struct declarations

`struct Name:` followed by indented `field: Type` lines. A declaration
introduces a **type, not a value binding** (`struct-named-type-not-value`): it
creates no name in the value namespace. It follows the declaration-order
semantics of the other type declarations (a struct may name a struct declared
later, itself, or a cycle; `struct-named-recursive-declaration`). Duplicate
fields, unknown field types, a repeated name, and a name that shadows a
built-in or declared type are diagnosed at the declaration
(`struct-error-declaration`). Declarations carry source spans for the
declaration, each field and each field's type (HIR `sourceTypes`, kind
`struct`).

## Named struct construction

`Name {a: x, b: y}` is complete, exact and statically type-checked: every
declared field exactly once (`MISSING-FIELD`, `UNKNOWN-FIELD`,
`DUPLICATE-FIELD`), no defaults, and each value must be *proven* admissible for
its declared field type with the same proof a call argument gets for a declared
parameter. **No implicit runtime cast and no runtime guard is inserted**
(`struct-error-no-implicit-guard`: an untyped value is a compile-time TYPE
error). `Name {...}` does **not** allocate an anonymous temporary first: it is
one `struct` HIR node with `named = 1`, one `structnew` NIR op with the
declaration's shape.

## Field projection

`value.field` is resolved at compile time to a slot. The HIR `project` node
carries the receiver and the field name; native lowering turns it into
`structget SLOT`, with the slot taken from the receiver's static struct type.
It cannot become a runtime lookup: there is no lookup operation in any
backend except the reference interpreter's `core::runtime::project`, which
finds the name in the value's own shape and is unreachable for a program that
passed `hir::check` (a well-typed projection cannot fail).

* **Type**: the declared field type (named) or the field's type in the
  inferred struct type (anonymous), e.g. `p.name : str`.
* **Absent field**: `UNKNOWN-FIELD` at the field name, listing the known
  fields. **Non-struct receiver**: `NOT-A-STRUCT`.
* **`any` receiver**: `UNPROVEN-FIELD`, unless the projection sits in a
  function every generically live call of which has a semantic instance in
  which the receiver's struct type is known (next section). No fallback exists.

## Type representation

Three forms, all inside the existing type lattice:

| form | meaning |
|---|---|
| `{struct FIELDS}` | anonymous struct type; FIELDS is a dict field to type, sorted by name, so equal field sets have one representation |
| `{nstruct ID}` | named struct; ID is the declaration identity (`Person`, or `geo::Point` for a module's); the schema is in the registry `hir::structs` |
| `struct` | the bare kind: "some struct" (used by `kindOf` and as the conservative erasure) |

`hir::types` gained `IsStruct`, `IsNamedStruct`, `IsStructLike`, `MakeStruct`,
`StructLayout`, `StructField`, `StructShape`, and struct cases in `subtype`,
`lub`, `narrow`, `Bound`, `kindOf`, `semantic` and `show`. The registry is
per-compilation (like source-defined types): `hir::sourcetypes::apply` is the
one entry, and HIR keeps the canonical entries as its `sourceTypes`.

## Anonymous structural identity

An anonymous struct type is canonicalized by **sorting field names**; the
field types are the structure. Differently ordered literals therefore get the
same type (`struct-anon-types-canonical`), the same runtime shape
(`struct-native-shapes-shared`) and equal values. The written order is kept on
the HIR node (`slots`, `names`, `layout`) for evaluation order only.

## Named nominal identity

A named struct's identity is its **declaration identity**: the declared name
for the entry program and `namespace::Name` for a module's. Two declarations
with identical fields are distinct types and distinct shapes
(`struct-eq-nominal`); two modules' `Point`s never coincide
(`struct-module-distinct-modules`); a named struct is never equal to, nor
accepted for, an anonymous struct with the same fields
(`struct-eq-named-vs-anonymous`, `struct-error-nominal-mismatch`); and an
anonymous shape coincidence never manufactures a named type.

## Type algebra

* **LUB**: two anonymous structs with the **same field names** join
  **fieldwise**; different field names join to `any`. Same named declaration
  joins to itself; two named, or named and anonymous, join to `any`
  (`struct-type-lub-*`).
* **Subtyping**: equal field sets with fieldwise subtyping (immutable values,
  so covariant). **No width subtyping**; named structs are never structurally
  compatible by field coincidence.
* **Field-order canonicalization**: sorted names for anonymous structs;
  declared order for named ones.

## Bearing / non-erasure

A struct is **bearing** (carries a typed `MutableArray[T]` contract) iff a
field is, recursively: `{storage: MutableArray[str]}` is bearing, and so is a
struct holding it, and a `List` of either (`struct-bearing-recursive`). The
non-erasure rules of the typed-MutableArray work (`hir/callables.tcl`:
`Bearing`, `Preserves`, `HasMutArray`, `WalkExpr`) walk struct fields; a
struct's field context is the struct type's own field type.

**Attack test** (`struct-bearing-attacks`), each rejected at compile time:

```
m = mutarray::create(2, "x")
s = {storage: m}
xs = [s, 5]               # a struct into an untyped list: cannot erase element contract
struct Box: value: any    # m into an `any` field: cannot erase ... stored in field "value"
fn f(v: any): v           # s through an untyped parameter
struct Holder: arr: MutableArray[int]   # Holder {arr: m}: str array is not an int array
```

The instance-mediated case is accepted *with the contract kept*
(`struct-bearing-instance-keeps-contract`: `leak(s)` where `leak(v): v` is
analyzed under the actual struct, so `t.storage : MutableArray[str]`).

## Semantic-instance interaction

Semantic instances (`hir/semantic.tcl`) are keyed on the **full semantic
argument types**, so `first({value: "a"})` and `first({value: 7})` are two
instances whose bodies are analyzed under `struct{value: str}` and
`struct{value: int}` (`struct-projection-instance-proves`); result types come
back precise. No struct-specific rule was added to `hir::semantic`: the only
change is a verification rule (below).

**Instances prove projections.** `fn first(x): x.value` has `x : any` in its
generic analysis. An unproven projection is an error only if the generic body
can actually run, i.e. its function is *generically live*: the program top
level is live; a block is live if a live context calls it without a semantic
instance or its value escapes (a reference that is not a callee); a live
context is a live block's generic analysis or an instance some live context
calls. `hir::structs::GenericLive` computes this. In an instance's own
analysis every unproven projection is an error.

**Recursive functions** were a real bug found by the refactor, fixed here: a
function threading a struct parameter through its own recursion
(`fn walk(s, i): ... walk(s, i + 1)`) makes its dead generic body request an
instance `walk<any, int>`, whose unproven projection was reported at that call.
`hir::semantic::verify` now reports an instance problem that is *only* an
unproven projection ("curable") at a generic call only when that call's block
is generically live (`struct-projection-recursive-*`: the recursive function
works, a non-struct call is still rejected, an escaping recursive function is
still rejected).

## KeyType / representation shape

`hir::specialize::KeyType` of an anonymous struct keeps the **layout** (field
names) and reduces each field type to *its* key type exactly as a `List`'s
element is: `{x: MutableArray[int]}` and `{x: MutableArray[str]}` share a key
(both `mutarray`), `{x: int}` and `{x: str}` do not (typed field operations
differ); semantic field types (evidence, applied types) never enter the key.
A named struct is keyed by itself. Result: field-type variation creates codegen
copies **only when a typed operation differs** (`struct-keytype-layout-and-
kinds`; `struct-specialization-census`: five semantic instances lower to four
codegen instances).

The alternative, a key of the layout alone (every field type erased), was
measured on the real corpus (`audit/structs/tools/keyvariant.tcl`,
`out/keyvariant.txt`): **242 codegen instances and 231 emitted functions for
both**, so the kind component costs nothing here, and it is kept because it
separates the cases where the operations differ (`{x: int}` versus `{x: str}`)
that a layout-only key would merge.

On the real corpus (`audit/structs/out/instances-*.txt`): **50 semantic
instances involve a struct type and they fall on 50 distinct codegen keys**, so
no instance shares code with another, and none needed to: in this corpus struct
field types do not vary across instances of one function. Total codegen
instances went 245 to 242 and emitted functions 234 to 231 (more semantic
instances, 268 to 280, but fewer emitted functions).

## Runtime representation

| | |
|---|---|
| interpreter value | `{struct {ID FIELD...} VALUES}`: the shape head (`{}` + sorted fields for anonymous, `{ID FIELD...}` for named) and the values in slot order |
| native object | `StructObj { hdr, shape: u32, len, ptr }`, runtime kind `KIND_STRUCT` (12), distinct from `KIND_LIST`; fields are `ptr[0..len]` |
| shape | an index into the program's static `ProgramInfo::shapes` |

A struct object holds **no field names and no static types**; names live once
in the shape, types are the compiler's. Size: 32 bytes header plus 8 per field
(a two-field struct is 48 bytes; measured `24672 B / 514 objects`).

## Shape metadata

Shapes are **static and interned**: `native/lower.tcl` assigns shape numbers
(`ShapeIndex`), emits `shape N anon fields="a b"` / `shape N named "Name"
fields="..."` declarations in NIR, and the VM's `ProgramInfo` carries them. An
anonymous shape is shared by field set whatever the source order; a named one
is per declaration (`struct-native-shapes-shared`, `struct-native-named-shape`).
Standalone executables emit the shape table at startup.

## Equality

Two struct values are equal iff they have the same shape (same interned shape
number: an anonymous struct's field set, or one declaration) and every field
is equal, slot by slot, by the existing recursive equality. So
`{x: 1, y: 2} == {y: 2, x: 1}`, `Person{..} == Person{..}` by fields, `Person`
never equals an `Account` or an anonymous struct, and a struct is never equal
to a List with the same contents. Fields that currently have no equality
(`MutableArray`, callables) keep that rule: `{a: m} == {a: m}` is an EQUALITY
error (`struct-eq-mutarray-field`). Hashing is shape- and field-wise
(`struct-eq-hash-consistent`; `ImmutableSet` of structs deduplicates).

## Printing

Anonymous: `{age: 45, name: "Grace"}` (canonical order). Named: `Person {name:
"Ada", age: 36}` (declared order, declared name; `geo::Point {...}` for a
module's). The printer never depends on dict iteration order. The interpreter,
the compiler and native code print identically.

## GC

Struct objects are heap objects of kind `KIND_STRUCT`: marking traces
`struct_of(v).fields()` (every field is an ordinary program value), sizing is
`size_of::<StructObj>() + len * 8`, and freeing releases the boxed slot array.
`Vm::new_struct` fills the slots before the object is observable, so no
partially initialized struct is ever visible to the collector or the program.
Metrics report a `Struct` kind.

## Core IR representation

Two explicit forms, in written order:

```
(struct HEAD NAME EXPR ...)      HEAD: {} anonymous, {ID FIELD ...} named
(project EXPR NAME)
```

`core::ir::check` validates arity, duplicates, and the HEAD shape. The
interpreter (`core::forms::op-struct`, `op-project`) and the Tcl compiler share
`core::runtime::structNew` / `project`. Core IR is the Tcl reference path only;
native never goes through it (`tests/direct-hir-native.test` still passes).

## HIR representation

One `struct` node kind for both anonymous and named constructions, with fields
`named` (0/1), `structId` (`""` or the declaration identity), `names` (written
order), `layout` (canonical or declared slot order) and `slots` (written
position to slot), plus per-field origins; and one `project` node with
`receiver`, `name` and `nameOrigin`. HIR is authoritative: every check
(`hir::structs`, `hir::range::VerifyStruct`, `hir::callables`) reads these
nodes and the `sourceTypes` registry, and HIR text round-trips
(`struct-hir-format-roundtrip`).

## NIR representation

```
shape 0 anon fields="left right"
shape 1 named "Point" fields="x y"
%3 = structnew 0 %1 %2        # shape, then one register per field, slot order
%4 = structget 1 %3           # constant slot, total, no allocation
```

The Rust side validates that a `structnew` names a declared shape with exactly
its field count, that shape numbers are dense, and that an anonymous shape's
fields are sorted and unique; `structnew` allocates (a safepoint) and never
fails, `structget` is total. Nothing in NIR carries a field *name* after
lowering, which is what makes it suitable for a future bytecode: a bytecode VM
needs exactly a shape table, `new(shape, fields...)` and `get(slot)`.

## Native lowering

`native/lower.tcl` resolves every struct to a shape number and every projection
to a slot from the receiver's static type: `Struct` emits `structnew`,
`Project` emits `structget`. **No path reconstructs struct semantics from names
after lowering.** A projection whose receiver type is not a known struct is
`{NATIVE UNSUPPORTED struct-shape}`, never a lookup. In Cranelift, `structnew`
is one runtime call (`rt_struct_new`) and `structget` a load at the constant
slot offset from `STRUCT_PTR_OFFSET`. Stack maps, root planning and escape
classification treat a struct like any other heap value.

## Standalone executable support

`-emit-native-executable` emits the shape table with the program and runs
structs identically (`struct-executable-parity`, `struct-executable-module`:
anonymous, named, nested, equality and a module-declared named struct, with the
four-way comparison against the interpreter).

## Module interaction

A module's `struct Name:` is a qualified type (`geo::Point`): its identity is
`geo::Point` and is distinct from the entry program's `Point` and from any other
module's (`struct-module-nominal`, `struct-module-distinct-modules`); fields,
construction (`geo::Point {...}`), projection and annotations
(`fn f(p: geo::Point)`) work through the existing module-qualification type
syntax, with no module flattening. A qualified name the module does not
declare is a module error listing what it does declare
(`struct-module-unknown-struct`). `surface/modules.tcl` loads a module's struct
declarations with its type declarations (`loadedStructs`). A module-level
binding whose initializer is a struct is not supported (known limitation).

## Diagnostics

Every diagnostic uses source field names, never slot numbers, and is located at
the relevant field or projection (`hir::DiagnoseAt` with the field/name span):

| situation | kind | example |
|---|---|---|
| duplicate anonymous field | `DUPLICATE-FIELD` | `duplicate field "a" in this struct initializer: each field may be given only once` |
| duplicate declared field | `TYPE` | `duplicate field "a" in struct "P"` (at the declaration) |
| missing named field | `MISSING-FIELD` | `the Person construction is missing field "age" (every declared field must be given exactly once; there are no defaults)` |
| unknown construction field | `UNKNOWN-FIELD` | `struct Person has no field "height" (declared fields: name, age)` |
| wrong field type | `TYPE` | `field "name" of struct Person cannot be proven to satisfy its declared type str (value type: int, ...)` |
| projection of a missing field | `UNKNOWN-FIELD` | `struct type Person has no field "height" (known fields: name, age)` |
| projection from a non-struct | `NOT-A-STRUCT` | `cannot project field "f" from a value of type int: only a struct has fields` |
| projection from `any` | `UNPROVEN-FIELD` | `...the receiver's struct type is not known here (its type is any), and a field projection is resolved statically, never looked up at run time` |
| unknown struct | `UNKNOWN-STRUCT` | `unknown struct type "Nope": no "struct Nope" declaration is visible` |
| nominal mismatch | `TYPE` | `argument for parameter "p" cannot be proven to satisfy Person (argument type: Account, ...)` |

## Parser/fuzzer coverage

`tests/structs-syntax.test` (30 tests): syntax for every form, shared
initializer payload, node ids and spans, the ambiguity cases (`{}`, `{x: 1}`,
`Person {x: 1}`, nested, call then literal, block boundaries near braces),
malformed input (missing colon, missing value, duplicate comma, bad nested
braces, bad field name, unterminated literal, bad projection name, bad
declaration) with error recovery (`{a 1}` becomes one `error` node and parsing
resumes). The repository has no separate fuzzing stage, so
`structsyn-mutation-robustness` is the fuzz-style coverage: deleting,
duplicating and replacing **every token** of three struct programs with a
struct-relevant replacement set never crashes the lexer or parser.

## Positional-product census before

`audit/structs/tools/positional.tcl` (HIR-level: every list literal of two or
more elements with its element types, every `list_get` with a literal index),
over `bench/*.bot`, `examples/stdlib/*.bot`, `examples/surface/*.bot`:

| | before | after |
|---|---:|---:|
| list literals of 2+ elements | 84 | 49 |
| ... heterogeneous element types | 41 | 10 |
| `list_get` with a literal index | 60 | 16 |
| ... receiver type lost its element types | 47 | 7 |
| struct literals and projections | 0 | 79 |

The known products and their classification:

| product | where | class | action |
|---|---|---|---|
| `[field, index]` | `scan_unquoted`/`scan_quoted`/`scan_field` (4 files) | definite struct candidate | converted |
| `[fields, stop]` | `scan_record`/`scan_record_rest` (4 files) | definite struct candidate | converted |
| `[newControls, newKeys, newValues]` and the matching `src` | `ht_rehash*` (`hashtable.bot`, `csv_records.bot`) | definite struct candidate | converted |
| `[name, dependencies]` | `bench/test-selection.bot` | definite struct candidate, a domain entity | converted (named `Test`) |
| `[completed, current, filled]` | `csv_chunked.bot` builder state | definite struct candidate, not in the agreed set | left; see "Remaining positional Lists" |
| `[storage, length]` | (removed by the typed-builder milestone) | | |
| result tuples of the `expect:` samples, `lex-strategy`/`source-checks` results | | probably sequence / test probes | left |
| matmul rows, `list_get(b, 0)` | | sequence | left |

## Source-fence amendment

The canonical `.bot` files were frozen by earlier milestones. This milestone
reopens exactly these: `examples/stdlib/{csv,csv_chunked,csv_geometric,
csv_records}.bot` (scan pairs; the two builder contracts in the last two),
`examples/stdlib/{hashtable,csv_records}.bot` (rehash) and
`bench/test-selection.bot` (named `Test`). No other source file changed, and
nothing else was tuned afterwards: measurements were taken with the source
frozen. The new fence is pinned by the repinned tests named in each section.
`tests/typed-mutarray-builder.test`'s fence test now counts the typed API as
`csv_geometric.bot 2 creates / 2 typed spellings`, `csv_records.bot 2 / 3`.

## CSV scan refactor

```
fn scan_unquoted(text, start, index):   ... return {field: substring(text, start, index), index: index}
fn scan_quoted(text, index, field):     ... return {field: field, index: index + 1}
fn scan_record_rest(...)                ... {fields: geo_finish(fields, count), stop: stop + 1}
```

`list_get(scanned, 0)` and `list_get(scanned, 1)` became `scanned.field` and
`scanned.index` (`scanned.fields`, `scanned.stop` for records); the four variants
(`csv`, `csv_chunked`, `csv_geometric`, `csv_records`) are identical in
structure. Anonymous structs, because the scan result is a local transport
object whose meaning is its two fields; there is nothing to name.

Types (exact-call census, `audit/structs/out/calltypes-*.txt`):

| | before | after |
|---|---|---|
| `scan_field(...)` | `list` | `struct{field: str, index: int}` |
| `scan_record(...)`, `csv_geometric`/`csv_records` | `list` | `struct{fields: List[str], stop: int}` |
| `csv_parse(...)` `csv.bot` | `list` | **`List[List[str]]`** |
| `csv_parse(...)` `csv_geometric.bot` | `list` | **`List[List[str]]`** |
| `csv_parse(...)` `csv_chunked.bot` | `list` | `list` (raw-array builder, by design) |
| `csv_records` `scan_records(...)` | `list` | `List[List[str]]` |

**Builders:** in `csv_geometric`/`csv_records` the fields builder is now
`MutableArray[str]` freezing to `List[str]`, and the records builder
`MutableArray[List[str]]` freezing to `List[List[str]]`, produced by the
existing untyped `geo_*` source and the existing semantic instances
(`audit/structs/out/typedsites-after.txt`, and the repinned
`tmb-csv-geometric-1`). **No new generic or compiler rule was needed for the
typing.** What the refactor did need:

**The remaining boundary, and two declared contracts.** With the scanned
values precise, an untyped function that appends a value it computes itself
(`scanned.field : str`) to storage it received as a parameter fails at its
*definition*, because nothing in the definition says the storage holds `str`:
the existing "definition-level obstruction" of
`TYPED-MUTARRAY-BUILDER-REFACTOR.md` (probe A), which the old `any`-typed scan
values had hidden (their storage was `MutableArray[any]`, which accepts
anything). The accepted shape is probe C, a concrete declared contract, exactly
as `build_rows` already declares `outer: MutableArray[mutarray]`:

```
fn scan_record_rest(text, stop, fields: MutableArray[str], count)
fn scan_records(text, index, records: MutableArray[List[str]], count)
```

Two contracts per file in `csv_geometric.bot` and `csv_records.bot`. They are
definition contracts forced by an unchanged rule, not annotations added to
improve a count, and they are the price of `csv_parse : List[List[str]]` for
those two variants. `csv.bot` (persistent `list_append`) needed none.

## Hashtable rehash refactor

`src = {controls: ht_controls(table), keys: ht_keys(table), values:
ht_values(table)}` and `dest = {controls: newControls, keys: ..., values:
...}` (in `hashtable.bot` and the embedded copy in `csv_records.bot`), read
with `dest.controls`, `src.keys`, and so on. **Anonymous**: the grouping
exists only "to keep the parameter count readable" (the source's own words), a
local transport object, not a reusable entity; the table itself stays a raw
`mutarray` handle because it is *mutated* and structs are immutable.

Consequence (see "Known limitations"): `ht_rehash_insert(dest, ...)` and
`ht_rehash_scan(src, ..., dest, ...)` are untyped functions whose projections
are proven only by their instances, so `-specialize 0` / `cranelift-generic`
cannot run any program that reaches `ht_rehash` (every `ht_set`). The two tests
that asserted `-specialize 0` parity (`ht-specialize-off-1`,
`csv-records-specialize-off-1`) now pin `NATIVE UNSUPPORTED struct-shape`, and
the four-backend helpers substitute `cranelift` for an undefined generic
baseline (`tests/helpers.tcl`, `GenericBaselineUndefined`).

## Test-selection refactor

```
struct Test:
    name: str
    dependencies: List[str]

tests = [Test {name: "parser-tests", dependencies: [...]}, ...]
```

**Named**: a test group is a domain entity with a nominal identity and declared
field contracts. `tests : List[Test]`, not an anonymous struct list.

| question | answer |
|---|---|
| type of one test specification | `Test` |
| collection | `List[Test]` |
| `name`, `dependencies` | keep their actual types: `test_name(...) : str`; `Test`'s `dependencies : List[str]` |
| `select_affected(...)` result | `List[list]` before, **`List[Test]`** after; `first_affected(...)` `any` before, `str` after |

**The two declared contracts** (`is_affected?(test: Test)` and
`first_affected(tests: List[Test], changed?)`, both needed, verified by
removal one at a time; `select_affected` needs none): `is_affected?` is passed
to `list::find` as a *value*, so its body can run generically and
`test.dependencies` must be proven there. This is the struct analogue of the
boundary `select_affected`'s old contract pressure pointed at: it did **not**
disappear, it moved. The strict counterfactual for `test-selection.bot` fell
from 4 sites to 1 (`affected?`'s `xs` needs `list`: `test_deps(test)` is still
`any` in the *definition's* own analysis; its instances give `List[str]`), but
static projection added two real declared contracts where the old
`list_get(test, 1)` was a dynamic positional read that accepted `any`. That
trade is inherent to "structs are not maps": a struct field is either proven
or rejected.

## Semantic type-flow before/after

| function result | before | after |
|---|---|---|
| `csv.bot` `scan_field` | `list` | `struct{field: str, index: int}` |
| `csv_geometric.bot` `csv_parse` | `list` | `List[List[str]]` |
| `csv_records.bot` `scan_records` | `list` | `List[List[str]]` |
| `test-selection.bot` `select_affected` | `List[list]` | `List[Test]` |
| `test-selection.bot` `test_name` / `first_affected` | `any` | `str` |
| hashtable rehash | `unit` | `unit` (the arrays stay raw `mutarray`; the struct carries them) |

## Strict-counterfactual before/after

`variant-all-trusted` (every inferred parameter contract becomes a trusted
declared one; `audit/intrinsic-function-contracts/out/variant-all-trusted.patch`),
rerun fresh on both trees with `audit/typed-mutarray-builder-refactor/tools/
strict-table.py`; classified by `audit/structs/tools/strict-diff.py`
(`audit/structs/out/strict-diff.txt`).

| | sites |
|---|---:|
| before (fence `84f4d68`) | **38** (+1 forward-reference diagnostic, `09-mutual-recursion`, not a contract site) |
| after | **55** (+1) |
| disappeared | 15 |
| remaining | 23 |
| new | 32 |

**Disappeared (15):** the scan pairs' `index`/`stop needs int (arg any)` (12:
`csv` 2, `csv_chunked` 2, `csv_geometric` 4, `csv_records` 4) and three
test-selection sites (`select_affected` `test needs list`, `first_affected`
`test needs list` and the `list::find` invalid call).

**Moved:** none moved in place. The typed builders' element contracts now show
up one level higher (in the scan functions instead of only `build_rows`).

**Remaining (23):** `build_rows` (7: its `storage`/`outer`/`fields`
contracts and three erasures), `csv_records_generic` `fields`, `ht_rehash_insert`
`newControls needs mutarray (arg any)` in both files (the struct field is `any`
in the definition's own analysis), `sample` (9, `table needs mutarray`),
`affected?` `xs`, `total_valid` `token`, `uri_escape_text` `b`, `product_rows`
`a_row`.

**New (32):** 16 in `csv_geometric.bot` and 16 in `csv_records.bot`, in
`scan_record_rest`, `scan_records` and `csv_parse`, all one class: *typed
`MutableArray[str]` / `MutableArray[List[str]]` storage passed to an inferred
raw-`mutarray` contract* (`param storage needs mutarray (arg MutableArray[str])`,
`erasure of element contract`, `invalid call: geo_append with storage :
mutarray`), plus the declared `fields`/`records` contracts checked against a raw
`mutarray` argument. It is precisely `build_rows`' existing class, reaching the
field and record builders because they are now typed. So the headline is: **the
product-shaped sites are gone, and the typed-builder/erasure class, which
the `38` had only begun to show, now dominates** (`csv_geometric.bot` 4 to 16,
`csv_records.bot` 22 to 34).

**Categories remaining after structs:** (1) typed-storage element-contract
erasure across inferred raw contracts (the builders); (2) argument `any` into an
inferred scalar/list contract at a definition (`total_valid`, `uri_escape_text`,
`product_rows`, `affected?`); (3) the raw-mutarray HashTable record
(`sample`, `ht_rehash_insert`'s `newControls`); (4) `build_rows`' declared
contracts.

## Annotation candidates revisited

| candidate | after structs |
|---|---|
| `total_valid tokens` (lex-strategy) | still a genuine definition contract (no struct involved) |
| `select_affected tests` | **resolved** for `select_affected` itself (no contract needed: the instance gives `List[Test]`); replaced by two real contracts on `is_affected?` and `first_affected` (above) |
| `esc_bytes bytes` (`uri_escape_text b`) | unrelated; unchanged |
| `matmul a_row` (`product_rows`) | unrelated (a matrix row is a sequence); unchanged |
| `build_rows outer` | still a genuine definition contract (typed-storage erasure); unchanged |

No annotation was removed or added to improve a count. Two were added to
`csv_geometric`/`csv_records` and two to `test-selection` because the refactor
made a previously dynamic/erased access static.

## Semantic-instance census

`audit/structs/tools/instances.tcl` over `bench/*.bot` and
`examples/stdlib/*.bot` (17 programs):

| | before | after |
|---|---:|---:|
| semantic instances used | 268 | 280 |
| ... involving a struct type | 0 | 50 |
| distinct codegen keys of those | | 50 |
| sharing machine code despite differing field semantic types | | 0 |

Per program (before to after): `csv` 17 to 17 (10 struct), `csv_chunked` 19 to 20
(9), `csv_geometric` 24 to 29 (10), `csv_records` 79 to 87 (12), `hashtable` 38
to 38 (2), `test-selection` 14 to 12 (7). The csv_geometric/csv_records growth is
the typed builders: the field and record builders are now two instances each of
every `geo_*` function (`str` and `List[str]`) where there was one.

## Codegen census

`audit/typed-mutarray-builder-refactor/tools/codegen-count.tcl`: codegen
instances used **245 to 242**, emitted functions **234 to 231**. Struct codegen
instances: 30 (for example `scan_field<str, int>`, `test_name<Test>`,
`affected?<Test, block>`). Precision and code generation stay separate: 12 more
semantic instances, 3 fewer emitted functions.

AOT classification (`audit/structs/out/aot-*.txt`, status words over every used
specialization instance): 376 closed and 116 guarded before, **377 closed and
109 guarded** after. Of the 226 instance labels present in both, none got
worse and one (`csv_records_generic<str, bool>`) became closed; 28 labels
disappeared and 25 appeared (the scan, rehash and test-selection instances under
their new argument types).

## NIR before/after

`audit/structs/tools/niropcensus.py` over the NIR of the 17 programs
(`audit/structs/out/niropcensus.txt`):

| | before | after |
|---|---:|---:|
| `structnew` | 0 | 39 |
| `structget` | 0 | 52 |
| `listnew` | 81 | 66 |
| `listget` | 45 | 42 |
| guards | 64 | 59 |
| `call` | 303 | 328 |
| `callmulti` | 57 | 29 |
| `callvalue` | 8 | 8 |
| `retmulti` | 50 | 18 |
| functions | 234 | 231 |
| NIR lines | 6104 | 6160 |

Shifts: the scan pairs were returned as **multi-value results** (`callmulti`,
`retmulti`, virtualized by the existing machinery) and are now ordinary
single-value calls returning a struct object (`call` +25, `callmulti` -28,
`retmulti` -32); `listnew`/`listget` fall with the pair/triple/test-group
Lists (-15, -3; the test group was a `listnew` per test); guards fall by 5
(`csv_records` 26 to 23, `test-selection` 5 to 3: constant-index `list_get` on
an unknown list no longer needs a kind guard).

## Machine code before/after

Workloads (`audit/structs/out/workloads-compare.txt`, `native::codeSize`):

| | before | after |
|---|---:|---:|
| `csv_geometric` | 7625 B / 20 fns | 8021 B / 20 fns (+396, +5.2%) |
| `csv_records` | 23748 B / 57 fns | 23481 B / 56 fns (-267, -1.1%) |

Whole corpus (`audit/structs/tools/codebytes.tcl`, `native::codeSize`,
specialized; the two tools count slightly differently, so compare within a
table only):

| program | before | after | change |
|---|---:|---:|---:|
| `test-selection` | 7103 | 6589 | -514 |
| `csv` | 5723 | 6218 | +495 |
| `csv_chunked` | 10168 | 10725 | +557 |
| `csv_geometric` | 7578 | 7974 | +396 |
| `csv_records` | 23650 | 23391 | -259 |
| `hashtable` | 12732 | 12477 | -255 |
| the other 11 programs | 36377 | 36377 | 0 |
| **whole corpus** | **103331** | **103751** | **+420 (+0.4%)** |

Affected-function bytes: the scan functions grow by one `rt_struct_new` call
site each and the projections are inline loads; the programs that shrink
(`test-selection`, `csv_records`, `hashtable`) lose the per-element `listget`
range checks and kind guards of the old positional reads. Struct runtime
helper calls: one `rt_struct_new` per `structnew` (39 NIR sites in the
corpus); `structget` is an inline load. List helper calls removed: the
`listnew`/`listget` counts above.

## Allocation impact

From the workload reports (`byKind` for `List`, `MutableArray`, `String` and
`StringPlan` are **identical** before and after; the whole difference is the
new `Struct` kind). A `Struct` object is 32 + 8 x fields bytes, so every scan
result is 48 bytes.

| workload | allocations before to after | bytes before to after | GC cycles |
|---|---|---|---|
| `csv_geometric_100` | 2828 to 3342 (+514) | 128635 to 153307 | 0 to 0 |
| `csv_geometric_1000` | 28932 to 33946 (+5014) | 1312985 to 1553657 | 1 to 1 |
| `csv_geometric_10000` | 298937 to 348951 (+50014) | 13653895 to 16054567 (+17.6%) | 7 to 8 |
| `csv_records_1000x5` | 14107 to 20137 (+6030) | 891117 to 1180557 | 0 to 1 |
| `csv_records_1000x20` | 37124 to 62169 (+25045) | 3438734 to 4672894 | 2 to 3 |
| `csv_records_presized_1000x20` | 31124 to 52169 (+21045) | 2718734 to 3728894 | 2 to 2 |
| `csv_records_10000x5` | 140115 to 200145 (+60030) | 9113829 to 11995269 | 3 to 5 |

### Runtime

Native execution time in microseconds. Each round of the workload tool
reports the best of 15 executions; three rounds were interleaved between the
two trees, and the table gives the minimum and the median over the three
rounds (`audit/structs/out/workloads-compare.txt`):

| workload | before min / med | after min / med | min change | median change |
|---|---:|---:|---:|---:|
| `csv_geometric_100` | 263.0 / 270.1 | 221.9 / 276.5 | -15.6% | +2.4% |
| `csv_geometric_1000` | 3858.7 / 4284.8 | 3481.7 / 4192.3 | -9.8% | -2.2% |
| `csv_geometric_10000` | 43453.0 / 50664.8 | 53772.4 / 57612.6 | +23.7% | +13.7% |
| `csv_records_1000x5` | 2350.4 / 2355.2 | 2534.8 / 2679.7 | +7.8% | +13.8% |
| `csv_records_1000x20` | 9144.7 / 10968.7 | 11448.4 / 13092.2 | +25.2% | +19.4% |
| `csv_records_presized_1000x20` | 7562.9 / 9250.7 | 10668.6 / 10788.7 | +41.1% | +16.6% |
| `csv_records_10000x5` | 29547.6 / 30906.5 | 37305.6 / 43464.0 | +26.3% | +40.6% |
| `csv_records_sample` | 16.3 / 16.4 | 18.2 / 18.5 | +12.1% | +12.8% |

The direction on the larger inputs follows the allocation counts (+17% to +48%
objects, more GC cycles at 10000); the workload timer is too noisy to resolve
the small ones. No attempt was made to recover it.

**Answers to the generated-code questions:** struct allocations: one per scan
result and two per rehash (the `csv.bot` sample allocates 18, the 6-insert
hashtable sample 2). List allocations that disappear: **zero at the workload
level** (the pair Lists were already virtual, which is why `List` counts do not
move); on the escape-off path the csv sample went from 34 Lists to 16 Lists
plus 18 Structs. The formerly virtualized pair Lists are replaced by **real
allocations**: the escape/parameter-aggregate machinery does not handle
structs, and none was added (`escape-csv-3` and `paramagg-hashtable-2` now pin
that). Per the stop condition, no struct scalar replacement, escape optimizer,
SIMD or register-allocation work was done.

## Compile-time impact

Median of 3 interleaved rounds x 7 runs, `audit/direct-hir-native-path/tools/
compiletime.tcl -mode direct` on both trees (`audit/structs/out/compiletime-*`),
whole canonical corpus, milliseconds:

| stage (whole corpus, median of 3 rounds) | before | after | change |
|---|---:|---:|---:|
| front end (`surface::readProgramFile`: parse, resolve, types, semantic instances, checks) | 1615.8 | 1719.7 | +6.4% |
| `native::prepareHir` | 197.0 | 188.3 | -4.4% |
| NIR lowering (specialization, analyses, text) | 1983.6 | 1916.3 | -3.4% |
| Cranelift JIT | 126.5 | 130.1 | +2.8% |
| **total** | **3922.9** | **3933.6** | **+0.3%** |

Individual programs: `csv_records` front end 459.9 to 545.3 ms (+18.6%, the
program with 12 more semantic instances), `hashtable` 308.0 to 287.3 ms,
`lex-strategy` (no struct) 54.2 to 63.0 ms within the run-to-run spread of its
own rounds (51.9 to 73.1 ms after, 53.0 to 61.8 ms before).

The front end grew 8.9% in a first measurement that used a recursive walk to
verify projections on every instance; replacing it with flat scans
(`hir::structs::verifyExprs`, and a flat scan in `verify`) brought it to the
figure above. Specialization and NIR lowering did not get slower: fewer
emitted functions and fewer NIR guards more than pay for the struct
operations.

Struct canonicalization, shape interning and the projection verification are
cheap (flat scans of the expression table; an earlier recursive walk was
replaced before these measurements); the measurable front-end growth is
concentrated in the programs whose analysis grew (`csv_records`: 12 more
semantic instances, typed builders). The machine is noisy (same-tree runs vary
by 5-15%), so read differences under about 10% as unresolved.

## GC stress

Focused: every struct test file (`structs.test` 89, `structs-syntax.test` 30)
passes with `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempted at every
allocation site), including `struct-native-gc-stress`, which runs the
following under stress: an anonymous struct holding strings, one holding
Lists, a named struct, nested structs, `List[struct]`, `MutableArray[struct]`,
a struct containing a `MutableArray`, and returned/captured struct values.
Standalone executables were run under stress too (`struct-executable-*`).

Whole suite: `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl` on the final
tree, **3403 passed, 0 failed** on interp and **3399 passed, 4 skipped, 0
failed** on compile (1278 s; `audit/structs/out/gc-stress.txt`). This includes
the real CSV, HashTable and test-selection workloads in their struct form
(`native-csv-records`, `native-hashtable`, `stdlib`, `typed-mutarray-builder`,
`structural-fn-types`).

## Full regression

Final tree, `tclsh9.0 tests/all.tcl` (`audit/structs/out/regression-after.txt`;
the parent fence is `regression-before.txt`):

| | before (`84f4d68`) | after |
|---|---:|---:|
| interp | 3282 passed, 0 failed | **3403 passed, 0 failed** |
| compile | 3278 passed, 4 skipped, 0 failed | **3399 passed, 4 skipped, 0 failed** |
| skips | 4 (`coreScoping`) | 4 (`coreScoping`) |
| wall time | 1146 s | 1265 s |

+121 tests: `structs.test` 89, `structs-syntax.test` 30, `surface-lexer.test`
(token kinds) +2; the repinned measured tests keep their counts.

**Native coverage** (`tclsh9.0 tests/native-coverage.tcl`, the whole suite on
the Cranelift backend; `native-coverage-{before,after}.txt`):

| class | before | after |
|---|---:|---:|
| native | 1250 | 1264 |
| independent | 2007 | 2082 |
| passed-partial | 8 | 40 |
| unsupported | 49 | 49 |
| failed | 1 | 1 |
| tests | 3315 | 3436 |

`unsupported` is the same 49 tests for the same constructs and the one
`failed` (`refined-5`) is the same pre-existing test on both trees. The 32
additional `passed-partial` tests are the four-backend tests that reach
`ht_rehash` (`hashtable`, `csv_records`): their `cranelift-generic` leg is
undefined (`NATIVE UNSUPPORTED struct-shape`, see "Known limitations"), the test
helpers substitute `cranelift`, and the coverage tool counts that as a
partially native pass.

**Rust** (`cargo test --release --manifest-path native/Cargo.toml`): 56 + 22 =
78 passed, 0 failed, including new unit tests for shape/`structnew`/`structget`
parsing and rejection (`nir::struct_tests`, 4), and struct equality by shape
and field, the no-equality rule for arrays inside structs, printing in shape
order and GC tracing/reclamation of fields (`runtime::ops::tests`, 5).

## Benchmark/corpus parity

`tclsh9.0 bench/bench.tcl -runs 1` and `tclsh9.0 bench/corpus.tcl -runs 1` on
the final tree both exit 0: every backend agrees on every program and
algorithm value (`audit/structs/out/bench-runs1-after.txt`,
`corpus-runs1-after.txt`; the parent fence's runs are the `-before` files).
Corpus code-size columns (generic to specialized bytes) moved as in "Machine
code": `csv` 5770 to 6265, `csv_geometric` 7625 to 8021, `csv_chunked` 10215 to
10772, everything else identical. Objects allocated per 100-row input:
`csv` 2720 to 3234, `csv_geometric` 2828 to 3342, `csv_chunked` 2828 to 3342.
`-runs 1` timings are single samples and noise-dominated (interpreter, 100
rows: `csv` 2165 to 2195 ms, `csv_geometric` 3195 to 2574 ms, `csv_chunked`
2540 to 2468 ms; the compile column moves both ways by up to 2x); they are
parity evidence, not performance evidence. The performance numbers are the
best-of-15 workload table above.

## Remaining positional Lists

After the refactor `audit/structs/out/positional-after.txt` lists 10
heterogeneous literals and 7 lost-type literal-index reads:

* `csv_chunked.bot`'s builder state `[completed, current, filled]`
  (`chunked_new`, `chunked_append` x2 and their 6 `list_get` reads):
  **a definite struct candidate not in the agreed set** -- left as a List
  deliberately; it is the natural next conversion and would need the same
  two-contract treatment for a typed `current`.
* `matmul.bot`'s `list_get(b, 0)`: a matrix row is a sequence. Unchanged.
* the `expect:` sample tuples and benchmark result lists (`lex-strategy`,
  `source-checks`, `test-selection`, `csv_records`, `hashtable`, `13-hygiene`):
  test probes, not product values.
* `source-checks.bot`'s table of predicates (a List of functions).

## Remaining definition-level contracts

Unchanged by this milestone, and not addressed: a definition cannot state "the
storage parameter holds what the value parameter is" without a declared
concrete contract or a generic relation. Structs made the boundary more
visible in two places (the builder contracts above, `is_affected?`) but did
not create it. **No source type variables, no generic syntax and no rule in
`hir::semantic` were added**; instances recovered every type that flowed
through an ordinary function.

## Known limitations

* **`cranelift-generic` / `-specialize 0` cannot run a program whose field
  projections are proven only by semantic instances** (`NATIVE UNSUPPORTED
  struct-shape`): without specialization every function is compiled once and
  has no slot. Affected: anything reaching `ht_rehash` (`hashtable.bot`,
  `csv_records.bot`). The test helpers substitute `cranelift` for the undefined
  generic baseline and count the substitutions; `native::report` returns
  `generic unsupported` for such a program. A declared parameter type
  (`p: Person`) makes the function generically provable and avoids it.
* A module-level binding whose initializer is a struct is unsupported
  (`modulebinding` initializers are context-free scalars/values today).
* A struct containing `Fn` fields stores callables by value as any other
  field; equality on them is undefined as before.
* Structs are not scalar-replaced or virtualized (see "Allocation impact").
* Anonymous struct types cannot be written in annotations; use a named struct
  when an explicit contract is needed.

## Readiness for mutable struct / map initializer syntax

The representation is ready in the parts that matter: a struct object stores
only a shape index and slots, `structnew` fills every slot before the object is
observable, and shapes are static. A mutable struct would need (a) a distinct
type form so immutability is a property the type algebra can see (today
covariance and equality rely on it), (b) a `structset SLOT` NIR op and a write
barrier story (there is no generational collector, so none is needed today),
(c) a decision on equality for mutable values (identity, as `MutableArray`).
A map initializer is a different construct (dynamic keys, missing-key errors)
and must not reuse struct syntax; this milestone deliberately keeps the two
apart.

## Answers to the required questions

**Syntax.** (1) `{x: 1, y: 2}` is the surface node `anonstruct`, lowered to the
HIR `struct` node (`named = 0`). (2) `Person {x: 1, y: 2}` is `namedstruct`,
the same HIR node with `named = 1` and `structId`. (3) Yes: both carry one
shared `fieldinits` payload produced by one parser routine. (4) Yes, evaluation
follows written order (`struct-eval-source-order`). (5) Yes: identity is the
sorted field set. (6) Yes, optional. (7) Yes, `{}` is the struct with no fields.

**Terminology.** (8) struct, struct value, named struct, anonymous struct,
struct field, field projection. (9) No: "record" is not a compiler or language
concept here.

**Named types.** (10) By declaration identity (`Name` / `ns::Name`) in
`{nstruct ID}` with the schema in `hir::structs`. (11) Yes, distinct. (12) No,
a type, not a value binding. (13) Yes. (14) By the `ns::` prefix in the
identity and the qualified annotation/construction syntax.

**Anonymous types.** (15) Sorted field names with per-field types. (16) Yes.
(17) No. (18) Yes (`List[struct{a: int}]`, `MutableArray[struct{x: int}]`).

**Projection.** (19) To a compile-time slot, from the receiver's static struct
type. (20) No. (21) The field's type (declared, or the anonymous type's
field). (22) `UNKNOWN-FIELD`. (23) `UNPROVEN-FIELD`, unless every generically
live call has an instance in which the receiver's struct type is known.

**Construction.** (24) No. (25) No. (26) No. (27) No: a value not proven
admissible is a compile-time error and no guard is inserted. (28) No.

**Mutability.** (29) No. (30) No. (31) No. (32) No.

**Type algebra.** (33) Joins fieldwise. (34) `any`. (35) No. (36) No.
(37) No.

**Bearing.** (38) Yes. (39) Yes. (40) No: four attacks in
`struct-bearing-attacks`, all rejected; the instance-mediated case is accepted
with the contract kept.

**Runtime.** (41) `StructObj { hdr, shape: u32, len, ptr }`, kind `KIND_STRUCT`.
(42) By an interned field-set shape shared across literals and field orders.
(43) One shape per declaration, carrying the declared name. (44) No: names
live once in the shape. (45) Yes, static and interned in `ProgramInfo::shapes`.
(46) `struct_of(v).fields()` are pushed on the mark stack. (47) By shape index:
unequal shapes are unequal without comparing fields.

**IR.** (48) `(struct HEAD NAME EXPR ...)` and `(project EXPR NAME)`. (49) The
`struct` and `project` nodes. (50) `structnew SHAPE ...` / `structget SLOT V`
plus `shape` declarations. (51) Yes, shape ids and slots. (52) No. (53) Yes:
shape table, allocate-with-fields, load-slot.

**Specialization.** (54) The full struct semantic type. (55) Layout plus each
field's key type (kind), never semantic field types. (56) Only when a typed
operation differs: on the real corpus 50 struct instances fall on 50 keys, and
the unit census shows five instances sharing four. (57) 50 semantic struct
instances against 30 struct codegen instances (242 codegen instances
overall, 231 emitted functions).

**Source refactor.** (58) See the census table. (59) The scan pairs, the
record pairs, the rehash `src`/`dest`, the test group. (60) The chunked
builder triple, matmul rows, result/expect tuples, the predicate table.
(61) Yes. (62) Yes. (63) Yes. (64) Yes. (65) Scan results, rehash `src`/`dest`.
(66) `Test` (`name`/`dependencies`): a domain entity with nominal identity.

**CSV.** (67) `struct{field: str, index: int}`. (68) `str`. (69) `MutableArray[str]`
in `csv_geometric`/`csv_records` (with the declared `fields` contract).
(70) `List[str]`. (71) `struct{fields: List[str], stop: int}`.
(72) `MutableArray[List[str]]`. (73) In `csv.bot` and `csv_geometric.bot`, yes.
In `csv_chunked` no (its builder is deliberately raw arrays). In `csv_records`
the parse result is `List[List[str]]` before `build_rows` turns it into rows.
The exact boundary the untyped source hit, and the two declared contracts that
cross it, is the definition-level obstruction described above.

**Test selection.** (74) `Test`. (75) `List[Test]`. (76) Yes (`name : str`,
`dependencies : List[str]`). (77) Partly: `select_affected` needs no contract
and returns `List[Test]`; the strict site `affected? xs` remains. (78) The
definition's own analysis still sees `test_deps(test) : any`; only instances
see `List[str]`, and a function value passed to `list::find` runs generically,
which is what the two declared contracts pay for.

**Strict counterfactual.** (79) 38. (80) 55. (81) The 12 scan `index`/`stop`
sites and 3 test-selection sites. (82) None in place. (83) 23. (84) The four
categories listed above.

**Generated code.** (85) One per scan result / two per rehash; the workloads
above. (86) Zero at the workload level (already virtual). (87) Real
allocations. (88) Guards fall by 5 across the corpus. (89) 245 to 242.
(90) 234 to 231. (91) `csv_geometric` +396 B, `csv_records` -267 B.
(92) `csv_geometric_10000` +23.7% (min) and `csv_records` +8% to +41%:
see the timing table.

## Files

* `STRUCTS.md` (this file); `README.md` (Values, IR forms, Not implemented,
  Surface syntax).
* Surface: `surface/{lexer,parser,ast,lower,modules}.tcl`.
* HIR: `hir/structs.tcl` (new), `hir/{types,resolve,range,callables,specialize,
  semantic,sourcetypes,hir}.tcl`.
* Core IR and Tcl backends: `core/{ir,evaluator,runtime,value}.tcl`,
  `compiler/`.
* Native: `native/lower.tcl`, `native/native.tcl`, `native/src/{nir,codegen/
  clif,codegen/roots,runtime/{ops,value,heap,show,vm,metrics},aot,main}.rs`.
* Tests: `tests/structs.test` (89), `tests/structs-syntax.test` (30),
  Rust unit tests in `nir.rs` and `runtime/ops.rs`; repinned: `native`,
  `native-escape`, `native-hashtable`, `native-csv-records`,
  `native-param-aggregate`, `hir-aot`, `hir-specialize`,
  `typed-mutarray-builder`.
* Sources: `examples/stdlib/{csv,csv_chunked,csv_geometric,csv_records,
  hashtable}.bot`, `bench/test-selection.bot`.
* Audit: `audit/structs/` (`tools/` and `out/`).
