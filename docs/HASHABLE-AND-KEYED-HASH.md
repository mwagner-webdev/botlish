# Hashable and collision-hardened hash intrinsics

> «Hashability is a semantic capability, not merely the existence of a
> runtime hash function.» A Hashable value has total equality and total
> hashing; equal values hash equally, unequal values may collide.

## Contents

* [Result](#result)
* [Existing state](#existing-state)
* [Hashable](#hashable)
* [Witness authority](#witness-authority)
* [Contract](#contract)
* [Witness census](#witness-census)
* [Callables](#callables)
* [Public hash](#public-hash)
* [Public hash admission](#public-hash-admission)
* [Total lowering](#total-lowering)
* [Internal keyed hash](#internal-keyed-hash)
* [Hidden secret](#hidden-secret)
* [Why post-mixing is insufficient](#why-post-mixing-is-insufficient)
* [Visibility boundary](#visibility-boundary)
* [Correctness oracle](#correctness-oracle)
* [Collision corpus](#collision-corpus)
* [Fuzzing](#fuzzing)
* [Mutation testing](#mutation-testing)
* [Performance](#performance)
* [Regression and CI](#regression-and-ci)
* [Limitations](#limitations)
* [Future Map/Set handoff](#future-mapset-handoff)
* [What to run when changing this](#what-to-run-when-changing-this)

## Result

What landed:

* **`Hashable`, a built-in trait.** Client code uses it like any other trait:
  as a parameter or result type, through its one operation `x.hash()` (the
  public hash), passed on as a view, and monomorphized per witness. It is
  visible by its bare name in every module with no import, like `Int`. It is
  the first member of a general mechanism, the **intrinsic traits**
  (`hir/traits.tcl`'s `intrinsics` table): traits whose witnesses the
  language implementation supplies by a predicate, never by structural
  conformance.
* **The witness predicate** (`hir::types::HashClass`, built on
  `hir::types::Totality`). It is one walk of a static type, recursing through
  Lists, ImmutableSets and struct fields as `==` and `hash` do. Its per-kind
  facts are the runtimes' own refusal lists: `core::value::incomparable` for
  `equal`, `core::hashing::unhashable` for the hash. The narrow
  `hir::types::IsEqualityTotal` of M3/M4 is now this walk's equality column,
  so it recurses where it used to stop at scalar kinds.
* **Total lowerings.** New NIR ops `hashtotal`, `veqtotal` and
  `tablehashtotal` are selected where the operand is proven Hashable or
  equality-total. They call the same helpers as their fallible siblings
  without the NO_VALUE check, so the functions making them are
  `may_error=false`.
* **Static admission of the public `hash`.**
  * A value statically known not to be Hashable is TRAIT-NOT-SATISFIED at
    compile time: a function, a struct holding one, a MutableArray, a
    MutableVector, a DecimalRounded value.
  * A Hashable value hashes totally.
  * A statically unknown value (`any`) keeps the dynamic, fallible hash. The
    repository's generic hash tables rely on it (census below).
* **The private table hash `std::table_hash::of`.** It is SipHash-1-3 of the
  value's canonical input under a hidden, process-local key the runtime draws
  from the system's random source. It is implemented on all four backends:
  in `core/hashing.tcl` and in `native/src/runtime/ops.rs`.
  * Both hashes share one canonical walk with two folds (`Encode` / `walk`).
    The public hash's outputs are byte for byte unchanged; 107 pinned values
    are checked on every backend.
  * The keyed fold reads the value itself, never the public hash. A full
    64-bit public-hash collision found offline (`collide.rs`) stays apart
    under it.
* **Internal namespaces**, a general visibility mechanism
  (`core::native::declareInternalNamespace`).
  * Only standard library modules may import such a namespace or name its
    members; anyone else gets INTERNAL-NAMESPACE.
  * No code anywhere may take a member as a value
    (INTERNAL-INTRINSIC-VALUE).
  * `std::table_hash` is the first internal namespace.
* **Evidence.**
  * `tests/hashable.test` (48 tests).
  * Two golden suites (`tests/golden/hashable.bot`,
    `tests/golden/hashable-admission.bot`, 20 tests ported).
  * Six Rust unit tests (`cargo test --lib table_hash`).
  * An independent oracle (`audit/hashable/tools/oracle.py`).
  * A differential fuzzer: 200 programs on four seeds, plus GC stress, with
    no disagreement.
  * 45 mutants, all killed. One was equivalent in the first run (it mutated
    dead code) and was retargeted at the live condition (Mutation testing).
  * Performance: the public hash at parity before and after; the table hash
    1.7 to 3.7 times its cost natively; neither allocates.
  * Compilerpedia topics (`concept.hashable`, `error.internal-namespace`,
    `error.internal-intrinsic-value`, and updates to `stdlib.hash`,
    `error.equality` and `error.trait-not-satisfied`).

No Map or Set is implemented, no user-defined hashing is added, and nothing
is hashed by identity.

## Existing state

Before this milestone:

* **`hash(v)`** (`core/hashing.tcl`, `rt_hash` in `ops.rs`) was a root native
  over `any`.
  * It computed FNV-1a (64-bit) over the value's kind tag and payload, with
    the canonical decimal text of an Int or a code point and the UTF-8 bytes
    of a String. A nested value was folded in as its own 64-bit FNV sub-hash;
    set members were XOR-combined. The result was masked to 61 bits.
  * It was deterministic and fallible. EQUALITY stopped the run for a value of
    the kinds `==` refuses: functions, natives, MutableArray, MutableVector,
    coroutine handles, C pointers, DecimalRounded.
  * Since RO-1 (HASH-TABLE-COMPILER-PRESSURE.md) it allocated nothing for Ints
    up to 128 bits, code points and structs.
* **`hash` was never rejected at compile time.** `hash(f)` of a known function
  compiled and stopped when run. A typed function was the exception: the
  erasure check rejected passing it to `any`, for other reasons.
* **`hir::types::IsEqualityTotal`** was `kindOf in scalarKinds`: Int, String,
  Bool, unit, UnicodeChar, enums and floats, with no recursion. Only
  `setcontainstotal` and `setfromlisttotal` (M3, M4) read it. `==` lowered to
  the fallible `veq` for every non-scalar operand, and so did `hash`.
* **Traits.** They were structural. There was no built-in, sealed or
  compiler-supplied trait, and no witness-authority mechanism. `int`, `bool`,
  Lists and anonymous structs had no owner and could not be witnesses.
* **No public `Equatable` trait existed.** Hashable's contract therefore
  includes total equality directly (next sections). An `Equatable` extracted
  later would be `Totality equality` alone; Hashable is the conjunction with
  the hash column, so extracting it changes nothing Hashable means.
* **Intrinsic visibility.** No mechanism made an intrinsic callable from the
  standard library but not from programs: every root native was visible
  everywhere, and qualified ones needed only an import.

## Hashable

To its consumers Hashable is an ordinary trait (TRAITS.md):

```botlish
fn fingerprint(x: Hashable) -> int:
    hash(x)                  # or x.hash(), the trait's operation

fn keep(x: Hashable) -> Hashable:
    x                        # a view keeps its witness

fingerprint(Point {x: 1, y: 2})      # fingerprint<Point>
fingerprint([1, 2])                   # fingerprint<List[int]>
```

* **Entering.** A value enters at a Hashable parameter or result, like any
  trait view. A type outside the witnesses is TRAIT-NOT-SATISFIED there, with
  a source-terms reason that names the field or element that is not Hashable
  (Diagnostics, below).
* **Inside the trait-typed function.** A view supports exactly what views
  support: the operation `x.hash()` (a direct call of `hash` per witness in
  the monomorphized program); `hash(x)` and `x == y` (natives over `any`);
  being passed on to another Hashable parameter; and being returned as a view
  that keeps its witness.
* **Monomorphization.**
  * Each Hashable function becomes one clone per witness its calls pass
    (`fingerprint<int>`, `fingerprint<P>`, `fingerprint<struct{a:int,b:str}>`;
    a clone's name has no spaces).
  * This is ordinary trait semantics. Hashable adds no specialization
    dimension of its own, and a function that merely calls `hash` on a
    concrete type is not cloned.
* **Programs that never spell the name are unaffected.** They are no trait
  program, carry no `traits` field and get no second build
  (`hb-no-traits-unchanged`).
  * The trait is declared into a compilation exactly when its syntax or
    declarations spell the name (`hir::traits::IntrinsicDecls`, read before
    the first build like `UsesCoroutines`).
  * An over-approximation, such as the word in a string literal, only makes
    the program a trait program.
* **Like every trait**, Hashable is not storable (`List[Hashable]` and a field
  of it are TRAIT-STORAGE-UNSUPPORTED), and different witnesses do not join
  (TRAIT-WITNESS-JOIN).
* **The name is reserved** like a built-in type's: a struct, enum, type,
  refinement, layout or trait of that name is rejected.
* **HIR text** prints it as `trait Hashable intrinsic owner - requires
  hash(value: Hashable) -> int` and reads it back only as this front end's
  intrinsic trait. Interchange and compilation isolation carry the registry
  entry like any trait's.

## Witness authority

| | ordinary trait | intrinsic trait (Hashable) |
|---|---|---|
| declared by | source (`trait N:`) | the implementation's `intrinsics` table |
| named | by identity / `import type` | by bare name, everywhere |
| a type satisfies it when | its owner namespace declares compatible functions | the implementation's predicate (`HashClass`) says `total` |
| requirements implemented by | the owner's functions | the table's natives (`hash`), for every witness |
| a program can add a witness | yes, by declaring the functions | no: no declaration takes part |

`hir::traits::satisfies` checks the intrinsic case before structural
conformance. A module that declares `fn hash(value: Holder) -> int` makes
nothing Hashable, and a struct needs no such function to be Hashable
(`hb-witness-not-user-definable`). This is an implementation policy, not a
language law. A later version may move witnesses into ordinary Botlish
behind the same trait without changing client code.

No custom hashing exists: no user hash or equality implementation, no seed,
no strategy, and no way to assert that a type is Hashable. Opening that
would need its own design for the coherence laws (`a == b → hash(a) ==
hash(b)`, totality, stability).

## Contract

A Hashable value has:

* **total equality.** `==` between it and any value of an equality-total
  type never raises EQUALITY. Values of different kinds compare unequal.
* **total hashing.** Neither `hash` nor the table hash ever raises EQUALITY.
* **coherence.** `a == b → hash(a) == hash(b)`, and in one process
  `table_hash(a) == table_hash(b)`. Unequal values may collide.
* **stable value semantics.** Every witness is an immutable value, or a value
  with copy semantics.

`HashClass` is `Totality` of both columns: `none` if either column is,
then `unknown` if either is, else `total`. The witnesses are exactly
`total`. The two columns coincide on today's kinds. Each is still checked on
its own, and a test narrows one of them at a time to prove it
(`hb-witness-requires-hash-support`, `hb-witness-requires-total-equality`).

## Witness census

`hb-witness-census` computes `HashClass` and `IsEqualityTotal` of these
types; `hb-witness-agrees-with-the-operations` runs the operations on them.

| type family | equality total? | hash defined? | Hashable? | why |
|---|---|---|---|---|
| Int, every integer domain (`type Small = Int in 0..10`) | yes | yes | **yes** | canonical decimal text |
| C integer scalars (`std::ffi::c::Int`, ...) | yes | yes | **yes** | integer domains over Int |
| String, a String refinement (`refined type Word = str`) | yes | yes | **yes** | the UTF-8 bytes; evidence is no part of the value |
| Bool, unit, UnicodeChar | yes | yes | **yes** | |
| Float64 | yes | yes | **yes** | one representation (no NaN, no -0): bit equality |
| enum cases | yes | yes | **yes** | nominal: declaration identity and case name |
| a struct (named, anonymous, opaque) of Hashable fields | yes | yes | **yes** | structural, field by field; an opaque struct's representation, which `==` already compares |
| a recursive struct (`kids: List[Tree]`) of Hashable fields | yes | yes | **yes** | every value is finite (the walk treats a revisited struct as total) |
| List[T], ImmutableSet[T] of Hashable T; `List[never]` | yes | yes | **yes** | element by element; a set order-free |
| a struct, List or set holding a non-Hashable component | no | no | no | the component's reason, named ("field \"f\" of Holder (...): ...") |
| functions (`Fn{...}`, any exact function) | no | no | **no** | `==` of functions is not defined: no function identity |
| MutableArray, MutableVector | no | no | no | a mutable header's identity is never a value's |
| coroutine handles | no | no | no | affine; comparing would observe what it owns |
| C pointers, NativeView, NativeEdit | no | no | no | no address identity is observable |
| DecimalRounded | no (type-blind) | no | no | equal only at its static precision, which type-blind equality and hash do not know |
| `any`, an untyped field, a bare `list`/`struct` kind | unknown | unknown | no | a value of unknown type may hold a function |
| a view of another trait | unknown | unknown | no | no conversion between traits |
| an imprint variable `T` | unknown | unknown | no | no constraint holds `T` (Limitations) |
| `std::abi::bytes::Bytes`, `MutableBytes` | unknown | unknown | no (today) | their field is declared `storage: any`: byte storage has no static type yet |
| Results | (no source type) | | | not a source-visible type |

Equality-totality and hashing coincide everywhere, as their runtimes'
refusal lists do. The last unknown rows are honest limits of static
knowledge, not of the values. A Bytes value hashes, dynamically. Making it
Hashable needs a static type for byte storage; nothing was broadened to
increase trait coverage.

## Callables

A function is not Hashable: `==` of functions is not defined, so its
equality is not total. One rule rejects every route a function could take:

* the function at a Hashable parameter;
* a struct field holding one, or a nested struct's;
* a List of functions;
* `hash` of a value statically known to be one.

All are TRAIT-NOT-SATISFIED, at compile time, with the reason in source
terms. Nothing is hashed by address, and no identity equality was added.

```
argument for parameter "x" does not satisfy trait Hashable:
Holder does not satisfy Hashable
field "f" of Holder (Fn{args: [int], return: int, errors: []}): a function has no total equality (== of two functions is not defined: there is no function identity)
```

## Public hash

* **The operation is unchanged:** deterministic, public, the same on every
  backend, every run and every process. It is not promised across compiler
  versions.
* **One shared walk.** Its implementation is now the shared canonical walk
  with the FNV fold:
  * Tcl: `core::hashing::Encode public` and `Fold public`.
  * Rust: `walk::<Fnv>`, a monomorphized generic, so the public path costs
    what `hash_mix` did.
* **Before and after.** Before any change, 107 values were hashed on all
  four backends; they cover:
  * Ints at the small/big/128-bit/BigInt edges;
  * code points at every UTF-8 length;
  * Strings;
  * Bool, unit, Lists, nested Lists;
  * Float64s;
  * named, anonymous and nested structs;
  * enums;
  * byte storage, MutableBytes;
  * sets in two orders.

  After, `hb-public-hash-pinned` and the golden `hb-public-hash-pinned`
  require exactly those Ints.
* **An independent check.** The Python oracle reproduces 13 of them from
  JSON descriptions (`hb-public-hash-oracle`): BigInts past 128 bits, a set,
  Bytes and nested structs.
* **RO-1's allocation-freedom is unchanged** (Performance).

## Public hash admission

The preferred end state, `hash` accepting exactly Hashable, would break
legitimate programs. `audit/hashable/tools/census.tcl` classifies every
`hash` call of the repository's programs (examples, bench, golden suites,
the hash-table experiment and the frozen corpus):

* **30 programs: 58 calls total (Hashable), 108 dynamic (statically
  unknown), 0 statically not Hashable.**
* **The 108 dynamic calls** are the generic hash tables of
  `examples/stdlib/hashtable.bot`, `csv_records.bot` and 13 of the
  experiment's implementations, plus `std::abi::bytes::Bytes`.
  * Botlish has no type parameters. A container written in Botlish stores
    its keys untyped (`keys: mutarray`, `key: any`) and hashes what it reads
    back.
  * `std::abi::bytes::Bytes` hashes dynamically too, because its storage field is
    `any`.

So `hash` takes the smallest coherent migration (`-hashing {0 checked}`,
read by `hir::range::VerifyHashing`):

* **Hashable argument (total).** Admitted; the call is total (`hashtotal`).
* **Statically not Hashable (none).** TRAIT-NOT-SATISFIED at compile time.
  This used to be EQUALITY at run time. The affine case stays the ownership
  discipline's AFFINE-EQUALITY-UNSUPPORTED rather than being restated.
* **Statically unknown (any).** The dynamic, fallible hash, exactly as
  before.

The dynamic path is kept distinct. It is no Hashable path: `any` is not
Hashable, and the private table hash (`-hashing {0 required}`) admits only
Hashable arguments. So the future Map's key contract cannot rest on it.

The rejection is judged once, in the program as written. It is never judged
in a semantic instance's view (whose key may forget an element type), nor in
the monomorphized build: there, a witness type would turn a generic body's
dynamic hash of another trait's view into a rejection no source type states
(TRAITS.md, "No delayed duck typing"; `hb-hash-generic-body-not-duck-typed`).

Changed outcomes of existing tests: `hash` of a value statically a vector
(`mutable-vector.test`'s `mv-show`) or statically DecimalRounded
(`decimal-rounded.test`'s `dr-equality-refused`) is now a compile-time
rejection. Both tests now hash those values through an untyped function,
which still observes the run-time refusal they pin. `float64.test`'s
`float-value-kind` called the removed internal `core::hashing::Mix`; it now
calls `Fold public`.

## Total lowering

| site | before | now (when proven) | proof |
|---|---|---|---|
| `hash(x)` | `hash` (may_error) | `hashtotal` | `hir::types::IsHashable` of x's static type |
| `a == b` (non-scalar) | `veq` (may_error) | `veqtotal` | `IsEqualityTotal` of both operands |
| `std::table_hash::of(x)` | -- | `tablehashtotal` | admission (required) and `IsHashable` |
| `std::immutable_set::contains`, `from_list` | `setcontainstotal`/`setfromlisttotal` for scalar kinds | the same, now for any equality-total element | the recursive `IsEqualityTotal` |

* **Codegen.**
  * Each total op calls the same helper (`rt_hash`, `rt_value_eq`,
    `rt_table_hash`). `veqtotal` keeps `veq`'s small-Int fast path.
  * The NO_VALUE check is dropped (`clif.rs`).
  * `op_may_error` lists the fallible ops only, so a function's
    `may_error` summary falls out of the fixed point.
* **NIR examples.** `fingerprint<P>`, `e(a: P, b: P) -> bool: a == b` and a
  function calling the table hash on a struct are all `may_error=false`. An
  untyped `h(x): hash(x)` stays `may_error=true` (`hb-nir-hash-total`,
  `hb-nir-equality-total`, `hb-nir-table-hash-total`).
* **Safepoints.** None of the hash ops allocates (`op_may_allocate`), so none
  is a safepoint (`may_gc=false`).
* **HIR is unchanged.** EQUALITY is a semantic abort, never a declared error,
  so the completion analysis never charged it.
* **The Tcl backends** have no error edges to remove.

## Internal keyed hash

`std::table_hash::of(x: Hashable) -> int` (internal name; no source outside the
standard library can spell it):

* **Canonical input.** The same walk as the public hash, folded differently.
  * A variable-length text (Int and code point decimal text, String bytes,
    enum and struct identities, field names) is its byte count (8 bytes LE)
    followed by its bytes, so the input is prefix-free.
  * A nested value is walked inline into the same state, never folded as its
    public sub-hash.
  * A set's members are XOR-combined keyed hashes (order-free), each from a
    fresh state under the same key.
  * Kind tags, counts and separators are the public walk's.
* **Algorithm.** SipHash-1-3, the variant Rust's HashMap uses: one
  compression round, three finalization rounds, a 128-bit key. The result is
  masked to 61 bits, always a small Int.
* **Implementations.**
  * `core::hashing::SipHash13` (Tcl, with explicit 64-bit masks).
  * `Sip<C, D>` (Rust, streaming, round counts as const parameters so tests
    can check it against std's SipHash-2-4).
* **Totality.**
  * The call is admitted only for a Hashable argument
    (`-hashing {0 required}`), and is then `tablehashtotal`.
  * A program compiled `-strict 0` can still reach the generic `tablehash`
    with a value that has no hash; that refuses the value with EQUALITY,
    exactly as `hash` would.
* **Semantics.** Within one process, `a == b → table_hash(a) ==
  table_hash(b)`, and repeated hashes of one value agree. Across processes
  and versions nothing is promised. The algorithm is an implementation
  detail: a later version may replace it without changing `Hashable`,
  `hash` or any client API, as long as these laws hold.

## Hidden secret

* **Native.**
  * `TABLE_HASH_KEY` is a `OnceLock<(u64, u64)>` in `ops.rs`, drawn on the
    first table hash of the process.
  * The key comes from std's `RandomState`, which reads the operating
    system's entropy (getrandom, arc4random, ProcessPrng): two states built
    in one thread carry different SipHash keys, and a hash of a fixed input
    under each yields one 64-bit word.
  * That gives 128 bits of the system's randomness on every host, with no
    dependency of our own.
  * It is process-local, never per table and never per thread.
* **Tcl backends.**
  * `core::hashing::TableKey` draws from `/dev/urandom` once per process.
  * Where there is none (Windows), it falls back to the clock, the process id
    and Tcl's counters: unpredictable to a program, but not a cryptographic
    source. The native runtime is the production one.
* **Not a Botlish value.**
  * No native returns, stores or compares it. A source audit checks that no
    native's implementation reads it, and that only `hashing.tcl` and
    `ops.rs` name it (`hb-secret-not-a-value`).
  * The table hash is not `-context-free`, so it is never evaluated or folded
    before run time with a compile-process key.
  * No context is needed and no random API is exposed.
* **Test key** (harnesses only).
  * `core::hashing::useTableHashKey {K0 K1}` fixes the Tcl backends' key.
  * `native::RunDriver` forwards it to the driver as `--table-hash-key HEX`
    for `run`, `bench` and `batch`.
  * A standalone executable has no such option and always draws its own key.
  * The production path itself is tested only for its laws:
    * one key per process (`table_hash_process_key_is_drawn_once`);
    * repeated hashes equal in one run on every backend
      (`hb-keyed-process-key`);
    * a 64-value smoke check that two processes' keys differ
      (`hb-keyed-differs-across-processes`).

## Why post-mixing is insufficient

The hash-table experiment's RT-3 showed the attack: keys whose public hash is
0 mod 1024 turn every open-addressed table into one cluster (2.8-9.0 µs per
hit at 1024 keys, against 70-90 ns). A table could mix a secret into
`hash(x)` afterwards, but any function of `hash(x)` and a secret sees
identical input for keys with equal public hashes.

The milestone makes this concrete. `audit/hashable/tools/collide.rs`, a
parallel distinguished-point search, found in 46 seconds on three cores two
Ints whose 64-bit FNV states are identical:

```
17384044247497657079   13834495523901255922   (state 0x6c6d116e05bd70eb)
```

Their public hashes are equal, and so are the public hashes of `[a]` and
`[b]` and of `P {x: a, y: 0}` and `P {x: b, y: 0}`, because nesting folds
the 64-bit sub-hash. On every backend:

* `hash(a) == hash(b)` holds, nested as well;
* `table_hash(a) == table_hash(b)` does not, nested as well
  (`hb-keyed-not-post-mixed`; `table_hash_reads_the_value_not_its_public_hash`
  in Rust).

The mutants `keyed-is-hash-xor-secret-*`, `keyed-is-keyed-mix-of-hash-*` and
`keyed-nested-uses-public-hash-*` (post-mixing, and folding a child's public
sub-hash) are each killed by this pair, among other detectors.

## Visibility boundary

`std::table_hash` is an **internal namespace**
(`core::native::declareInternalNamespace`, beside its natives in
`core/hashing.tcl`):

* **The loader (`surface/modules.tcl`'s `CheckInternal`)** refuses an
  `import std::table_hash`, or any qualified reference into it, from the entry
  program or an application module: INTERNAL-NAMESPACE (`hb-internal-import`,
  `hb-internal-qualified`, `hb-internal-application-module`).
  * The standard library is the modules of namespaces under `std`
    (STD-NAMESPACE.md), the files under `core::libraryDir` that are not
    recorded as application modules.
  * An application module can never be a standard namespace
    (RESERVED-NAMESPACE).
* **`hir::internal::verify`**, for every program alike: a member is only
  ever called. An alias, an argument, a result, a stored or captured value
  is INTERNAL-INTRINSIC-VALUE, even inside the standard library
  (`hb-internal-no-function-value`).
* **Method syntax.** The native is `-nomethod`, and its namespace is never
  imported by ordinary code (`hb-internal-not-a-method`).
* **Not an export.** Compilerpedia's generator skips internal namespaces:
  no reference topic names it (`hb-internal-not-exported`). The concept page
  explains keyed table hashing without documenting a callable API.
* **Static blocks.** A `static compile:` block asking whether ordinary code
  can reach it gets a CompilerError with its own code `InternalNamespace`
  (`hb-internal-static-compile`).
* **The consumer layer.** It is no Map file by name: it is every standard
  library module, so a future Set, dedup table or symbol table may use it.
  A privileged fixture (a module in a private copy of `stdlib/`) demonstrates
  the intended caller; the same fixture with an untyped argument is
  TRAIT-NOT-SATISFIED (`hb-internal-standard-module-calls`).
* **Trusted inputs.** HIR from core IR text or HIR interchange is past the
  source boundary and trusted, as for every other check.

## Correctness oracle

`audit/hashable/tools/oracle.py` is an independent model. It shares no code
with either runtime: it encodes a JSON description of a value by the
encoding above, then folds it with its own FNV-1a and its own SipHash-c-d.

Its `selftest` checks it against published vectors:

* the SipHash paper's appendix vector and the reference implementation's
  `vectors_sip64` entries (SipHash-2-4);
* Rust core's `test_siphash_1_3` vectors (SipHash-1-3);
* FNV-1a's vector for "a".

Checked against it:

* **The runtimes.** Under one fixed test key, every backend's
  `[hash(v), table_hash(v)]` equals the oracle's for 24 values
  (`hb-keyed-oracle`). These include BigInts past 128 bits, astral
  characters, Float64s, nested and anonymous structs, enums, sets and Lists
  of structs.
* **The fuzzer**, on every program it generates.
* **Rust.** The Rust implementation is checked against the paper's and
  Rust's vectors and against oracle-computed values at every block boundary
  (0-63 bytes).
  * Its SipHash-2-4 instantiation is checked against std's `SipHasher` over
    80 random messages, each written in random splits
    (`table_hash_sip_streams_like_std_siphasher`).

## Collision corpus

The experiment's own adversarial keys are `int-collide`: 1024 Ints whose
public hash is 0 mod 1024, generated by `audit/hash-table/tools/model.py
collide 1024 0` and committed as `audit/hashable/data/int-collide-1024.txt`.

| | buckets used (of 1024) | max load |
|---|---:|---:|
| public `hash` mod 1024 | 1 | 1024 |
| table hash mod 1024 (fixed test key; interp and cranelift agree) | 651 | 5 |
| random keys (expected) | ≈ 647.6 | ≈ 5-6 |

The keyed hash spreads the corpus like random keys: no pathological
equivalence class survives (`hb-keyed-collision-corpus`). This is no claim
that the keyed function is collision-free: two keys collide in a bucket at
the expected rate.

## Fuzzing

`audit/hashable/tools/fuzz.tcl`. Each program:

* **Declarations.** An enum (random case order) and two to four structs of
  Hashable field types.
* **Values.** It hashes 8-16 generated values. They are biased toward Int
  edges (2^61, 2^62, 2^63, 2^64, 2^128, negatives, 60-digit BigInts), code
  points at every UTF-8 length boundary, empty, short and 75-character
  Strings, dyadic Float64s, enum cases, named and anonymous structs, nested
  structs, Lists and sets.
* **Equal pairs.** 3-6 pairs of equal values constructed differently:
  * an Int computed and written;
  * a String concatenated and written;
  * a set from a shuffled List with a duplicate;
  * an anonymous struct's fields in reverse order;
  * a Float64 sum.
* **Expected values.** Each value's public and table hash under the run's
  key must equal the oracle's on every backend, together with
  `fingerprint(v) == hash(v)` and `v == v`. For each pair, `==`, the public
  hashes' equality and the table hashes' equality must all be true.
* **Admission probes.** Structs with one field outside Hashable (a function,
  a MutableArray, or `any`), with Hashable fields only, or nesting such a
  struct, are passed to a Hashable parameter, to the table hash and to the
  public hash. The fuzzer's own three-valued rule predicts acceptance or
  TRAIT-NOT-SATISFIED; an accepted dynamic public hash must run on every
  backend.

| run | programs | values | equal pairs | probes | disagreements |
|---|---:|---:|---:|---:|---:|
| `-seed 1` | 50 | 536 | 206 | 300 | 0 |
| `-seed 17` | 50 | 527 | 219 | 300 | 0 |
| `-seed 41` | 50 | 535 | 199 | 300 | 0 |
| `-seed 99` | 50 | 532 | 206 | 300 | 0 |
| `-seed 5 -gc-stress 1` | 20 | 212 | 80 | 120 | 0 |

## Mutation testing

`audit/hashable/tools/mutate.tcl` (`mutants.txt`). The detectors are:

* `tests/hashable.test` and `tests/native-hashing.test`;
* the fuzzer (`-n 8 -seed 3`);
* for a native mutant, `cargo test --lib hash`.

A runtime defect of both implementations is two mutants, one per runtime.

All 45 mutants apply and are killed. Every one is killed by the Tcl tests;
the fuzzer alone kills 27, and the Rust tests kill 11 of the 12 native
mutants (`hashtotal-is-fallible-native` changes only an effect, which
`hb-nir-hash-total` reads). The fuzzer compares values under a fixed key, so
it misses a defect that is static (a rejection, a lowering choice, an effect,
a visibility rule), a cost (an allocation) or in the drawn key.

`any-becomes-hashable` survived the first run. The kind list it mutated
named `any`, but `kindOf any` is "": that entry was dead, so the mutant was
equivalent. The dead entry is gone, the mutant now drops the live condition
(`$kind eq ""`), and it is killed by five tests and five of eight fuzz
programs.

| mutant | defect | tests failing | fuzz | Rust |
|---|---|---|---:|---|
| `callables-become-hashable` | callables become Hashable: a function type, and the function kinds, count as total | `hb-callable-not-hashable`, `hb-hash-static-rejection` and 4 more | 3/8 | -- |
| `any-becomes-hashable` | any becomes Hashable: a value of unknown type counts as total | `hb-any-not-hashable`, `hb-internal-standard-module-calls` and 3 more | 5/8 | -- |
| `struct-ignores-non-hashable-field` | a struct ignores a field that is not Hashable | `hb-hash-static-rejection`, `hb-list-of-callables-not-hashable` and 3 more | 4/8 | -- |
| `witness-ignores-equality-totality` | the Hashable witness predicate ignores equality totality (only the hash column) | `hb-callable-not-hashable`, `hb-hash-static-rejection` and 2 more | 0/8 | -- |
| `witness-ignores-hash-support` | the Hashable witness predicate ignores hash support (only the equality column) | `hb-witness-requires-hash-support` | 0/8 | -- |
| `recursive-struct-not-hashable` | a struct met again through its own fields is taken as not known, so a recursive Hashable struct is lost | `hb-witness-census` | 0/8 | -- |
| `public-hash-output-changes-tcl` | the public hash changes its output: texts are length-prefixed in the public walk too (Tcl runtimes) | `hash-parity-astral-1`, `hash-parity-bigint-1` and 7 more | 8/8 | -- |
| `public-hash-routed-through-keyed-tcl` | the public hash is routed through the keyed hash (Tcl runtimes) | `hash-parity-astral-1`, `hash-parity-bigint-1` and 7 more | 8/8 | -- |
| `hashable-hash-keeps-equality-edge` | a hash of a Hashable operand keeps the fallible op and its EQUALITY edge (both hashes) | `hb-allocation-free`, `hb-nir-hash-total` and 1 more | 0/8 | -- |
| `veqtotal-not-selected` | equality of equality-total operands keeps the fallible veq | `hb-nir-equality-total` | 0/8 | -- |
| `veqtotal-unsound` | veqtotal is chosen when only one operand is equality-total | `hb-nir-equality-total` | 0/8 | -- |
| `equal-values-hash-differently` | equal values can hash differently: a set folds its members in order (both hashes) | `hash-parity-kinds-1`, `hb-keyed-coherence` and 3 more | 6/8 | -- |
| `keyed-different-for-equal-constructions` | equal values constructed differently get different table hashes: the table hash folds a set in order | `hb-keyed-coherence`, `hb-keyed-oracle` | 6/8 | -- |
| `keyed-is-hash-xor-secret-tcl` | the table hash is hash(x) xor the secret (Tcl runtimes) | `hb-keyed-collision-corpus`, `hb-keyed-not-post-mixed` and 2 more | 8/8 | -- |
| `keyed-is-keyed-mix-of-hash-tcl` | the table hash is a keyed mix of the public hash, keyed_mix(hash(x)) (Tcl runtimes) | `hb-keyed-collision-corpus`, `hb-keyed-not-post-mixed` and 2 more | 8/8 | -- |
| `keyed-omits-kind-tag-tcl` | the table hash omits the kind tag (Tcl runtimes) | `hb-keyed-coherence`, `hb-keyed-collision-corpus` and 1 more | 8/8 | -- |
| `keyed-struct-skips-a-field-tcl` | the table hash of a struct skips its last field (Tcl runtimes) | `hb-keyed-oracle` | 8/8 | -- |
| `keyed-nested-uses-public-hash-tcl` | the table hash folds a nested value as its public sub-hash (Tcl runtimes) | `hb-keyed-not-post-mixed`, `hb-keyed-oracle` | 8/8 | -- |
| `secret-exposed-as-value` | the table hash key is exposed as a value: a native returns it | `hb-secret-not-a-value` | 0/8 | -- |
| `ordinary-code-can-import` | ordinary code can import the internal namespace | `hb-internal-application-module`, `hb-internal-import` and 2 more | 0/8 | -- |
| `ordinary-code-can-fully-qualify` | ordinary code can name the private hash fully qualified (only the import is refused) | `hb-internal-qualified`, `hb-internal-static-compile` | 0/8 | -- |
| `internal-namespace-undeclared` | table_hash is not declared internal: ordinary code can import and call it | `hb-internal-application-module`, `hb-internal-import` and 4 more | 0/8 | -- |
| `private-hash-escapes-as-value` | the private hash can escape as a function value (no value check) | `hb-internal-no-function-value` | 0/8 | -- |
| `private-hash-may-error` | the private hash of a Hashable argument keeps the fallible op (may_error) | `hb-allocation-free`, `hb-nir-table-hash-total` | 0/8 | -- |
| `private-hash-context-free` | the private hash is -context-free, so it may be evaluated before run time | `hb-secret-not-a-value` | 0/8 | -- |
| `secret-regenerated-every-call-tcl` | the process key is drawn again on every table hash (Tcl runtimes) | `hb-keyed-process-key` | 0/8 | -- |
| `sip-rounds-wrong-tcl` | the table hash runs two finalization rounds, not three (Tcl runtimes) | `hb-keyed-collision-corpus`, `hb-keyed-oracle` | 8/8 | -- |
| `trait-typed-hashable-argument-cannot-hash` | a value seen through Hashable is taken as not Hashable: hash of a Hashable parameter is rejected | `hb-allocation-free`, `hb-any-not-hashable` and 14 more | 8/8 | -- |
| `concrete-hashable-constraint-rejected` | a concrete struct is rejected by the Hashable constraint | `hb-allocation-free`, `hb-hir-text-and-interchange` and 13 more | 8/8 | -- |
| `hashable-structural` | Hashable is satisfied structurally, like a source trait: by an owner module's function `hash` | `hb-allocation-free`, `hb-any-not-hashable` and 22 more | 8/8 | -- |
| `hash-static-rejection-dropped` | the public hash no longer rejects a value statically known not to be Hashable | `hb-hash-static-rejection` | 4/8 | -- |
| `hash-dynamic-path-rejected` | the public hash rejects a statically unknown value (the dynamic path is gone) | `hb-hash-dynamic-compatibility`, `hb-hash-generic-body-not-duck-typed` and 3 more | 5/8 | -- |
| `reserved-name-free` | a program may declare a struct named Hashable | `hb-reserved-name` | 0/8 | -- |
| `public-hash-output-changes-native` | the public hash changes its output: texts are length-prefixed in the public walk too (native runtime) | `hash-parity-astral-1`, `hash-parity-bigint-1` and 7 more | 8/8 | killed (4) |
| `public-hash-routed-through-keyed-native` | the public hash is routed through a keyed hash (native runtime) | `hash-parity-astral-1`, `hash-parity-bigint-1` and 7 more | 8/8 | killed (6) |
| `hashtotal-is-fallible-native` | the total hash op is classified may_error (native effects) | `hb-nir-hash-total` | 0/8 | survived |
| `keyed-is-hash-xor-secret-native` | the table hash is hash(x) xor the secret (native runtime) | `hb-keyed-collision-corpus`, `hb-keyed-not-post-mixed` and 1 more | 8/8 | killed (2) |
| `keyed-is-keyed-mix-of-hash-native` | the table hash is a keyed mix of the public hash, keyed_mix(hash(x)) (native runtime) | `hb-keyed-collision-corpus`, `hb-keyed-not-post-mixed` and 1 more | 8/8 | killed (2) |
| `keyed-omits-kind-tag-native` | the table hash omits the kind tag (native runtime) | `hb-keyed-coherence`, `hb-keyed-collision-corpus` and 1 more | 8/8 | killed (1) |
| `keyed-struct-skips-a-field-native` | the table hash of a struct skips its last field (native runtime) | `hb-keyed-oracle` | 8/8 | killed (1) |
| `keyed-nested-uses-public-hash-native` | the table hash folds a nested value as its public sub-hash (native runtime) | `hb-keyed-not-post-mixed`, `hb-keyed-oracle` | 8/8 | killed (2) |
| `private-hash-allocates-temporary` | the private hash allocates a temporary heap object (native runtime) | `hb-allocation-free` | 0/8 | killed (1) |
| `secret-regenerated-every-call-native` | the process key is drawn again on every table hash (native runtime) | `hb-internal-standard-module-calls`, `hb-keyed-coherence` and 3 more | 8/8 | killed (1) |
| `secret-constant-native` | the process key is a constant, not drawn from the system (native runtime) | `hb-keyed-differs-across-processes` | 0/8 | killed (1) |
| `sip-rounds-wrong-native` | the table hash uses other SipHash round counts (native runtime) | `hb-keyed-collision-corpus`, `hb-keyed-oracle` | 8/8 | killed (1) |

## Performance

`bench/hashable.tcl` hashes values already built (a List made first, then
mapped), over the same program mapping identity, so the numbers are the hash
alone. Time per hash over its baseline, the whole program per iteration in
parentheses; best of 7, N = 2000 on the Tcl backends and 200000 natively.

**The new tree, both hashes** (`bench/hashable.tcl -runs 7`):

| operation | Tcl interp, ns | Tcl compile, ns | Cranelift, ns |
|---|---:|---:|---:|
| hash(Int) | 37579.5 (83490.5) | 15101.5 (16897.0) | 10.7 (82.4) |
| hash(String), 16 bytes | 59124.0 (104346.0) | 36117.0 (37720.0) | 19.8 (87.2) |
| hash(simple struct) | 112968.5 (181249.0) | 90400.0 (98589.0) | 57.7 (217.5) |
| hash(nested struct) | 259332.5 (361041.5) | 239877.5 (254928.5) | 131.7 (344.0) |
| table hash(Int) | 134488.5 (180937.5) | 65640.0 (68029.0) | 40.0 (105.4) |
| table hash(String), 16 bytes | 154148.0 (199943.5) | 85724.0 (87335.5) | 35.3 (106.9) |
| table hash(simple struct) | 237413.0 (306122.5) | 168932.5 (176845.5) | 111.1 (266.3) |
| table hash(nested struct) | 436712.5 (540586.5) | 338654.0 (352905.0) | 229.5 (456.8) |

Heap allocations natively (Cranelift's counters, N = 1000): every program
allocates exactly what its baseline does (6 for an Int or a String, 1006 and
2006 for the structs, which are the values themselves), for both hashes.

**The public hash before and after.** A worktree of the commit before this
change, with its own driver, ran the same benchmark (`-keyed 0`) right
before the new tree:

| operation | interp before | interp after | compile before | compile after |
|---|---:|---:|---:|---:|
| hash(Int) | 36.8 µs | 37.8 µs | 14.7 µs | 16.8 µs |
| hash(String) | 64.8 µs | 64.5 µs | 38.3 µs | 38.9 µs |
| hash(simple struct) | 117.9 µs | 118.6 µs | 99.5 µs | 94.4 µs |
| hash(nested struct) | 278.3 µs | 268.6 µs | 245.7 µs | 243.1 µs |

The Tcl backends are unchanged within noise.

Natively a single run cannot tell: the same pre-change binary measured
hash(Int) at 17.8 ns in one session and 7.5 ns in another. Every native
comparison below is therefore interleaved rounds, N = 1000000, best of 9
per round, the per-hash time averaged over rounds:

| comparison | Int | String | simple struct | nested struct |
|---|---:|---:|---:|---:|
| `rt_hash` alone (Rust loop, 5M calls, best of 7; 3 runs each), before | 15.3-15.9 | 12.4-12.7 | 45.3-47.0 | 136.6-144.9 |
| `rt_hash` alone, after | 14.7-15.0 | 13.2-13.3 | 46.4-46.7 | 141.9-142.9 |
| program, identical NIR: before tree / new driver (3 rounds) | 16.3 / 16.6 | 19.8 / 16.3 | 58.1 / 55.9 | 124.9 / 124.8 |
| program, new driver: `hash` / `hashtotal` lowering (4 rounds) | 18.0 / 13.4 | 21.5 / 22.2 | 50.7 / 59.8 | 125.7 / 127.6 |

* **The public hash did not regress.** The runtime function is at parity:
  the rewrite into one walk with two sinks costs nothing measurable (a
  String is 0.7 ns slower, 13.2 against 12.5; everything else is inside the
  old runs' spread). With the same NIR, a program runs as fast on the new
  driver as on the old one.
* **The total lowering changes no work, only the effect.** `hashtotal` is
  the `hash` call without the NO_VALUE branch. Interleaved on one driver it
  is faster for an Int, equal for a String and a nested struct, and slower
  for the simple struct (about 9 ns per hash, 2% of the program). The sign
  varies by shape for one branch fewer, which points to code placement in
  the generated loop rather than to cost; it is recorded here, not
  explained. The point of the lowering is `may_error=false`, which callers
  rely on.
* **The table hash.** SipHash-1-3 over the prefix-free input costs 1.7 to
  3.7 times the public hash natively (35-230 ns; the most for an Int, whose
  input is shortest), and 1.4 to 4.3 times on the Tcl backends, whose
  SipHash is 64-bit arithmetic in Tcl. It allocates nothing:
  `hb-allocation-free` adds eight hashes to a program and sees zero further
  allocations, and the Rust test `table_hash_allocates_nothing` counts the
  runtime heap directly.
* **RO-1 holds**: no allocation for an Int, a String, a struct or a nested
  struct, for either hash.
* **Effects.** Neither hash is a safepoint, and both are total for Hashable
  operands.

## Regression and CI

Run on Linux x86-64 (4 cores) on the final tree.

* **`tests/local.tcl`, whole** (every Tcl test file on interp and compile,
  every golden suite on all four backends; 36 minutes).
  * Golden suites: 103 run, 0 failed (interp 4997/4997, compile 4997/4997,
    cranelift-generic 4905/4905, cranelift 5007/5007).
  * Tcl tests: four files failed on both backends. Three were pins this
    change extends, each updated with its reason:
    * `linux-syscall-native-registered` lists every qualified native:
      `std::table_hash::of` is one.
    * `me-nomethod-native-default-off` lists every `nomethod` native:
      `std::table_hash::of` is one (`k.of()` reads as nothing).
    * `gf-code-name-complete` counts the `DiagnosticCode` cases: 105 became
      107.
  * The fourth was a real defect: `nl-no-string-ternary` found two
    `expr {... ? ... : ...}` selections in `Totality` (one could select a
    type string); both are `if` now.
  * The four files, `hashable.test`, `traits.test` and both hashable suites,
    run again narrowed: 289/289 on each Tcl backend, 20/20 golden tests on
    each backend.
* **Rust**: `cargo test --release` (library 284, driver 61, the native stack
  checks) passes; `--lib hash` (12 tests) also under GC stress.
* **GC stress** (`BOTLISH_NATIVE_GC_STRESS=1`): `tests/hashable.test` 48/48,
  `tests/native-hashing.test` 38/38, and both golden suites on
  cranelift-generic and cranelift.
* **Warning gate** (`audit/refactor/tools/gate.tcl`): passes; the manifest
  is unchanged.
* **Compilation isolation and interchange**, on both hashable suites plus
  the twelve default suites: `interleave.tcl` 112 artifacts and outcomes,
  `roundtrip.tcl -via interchange` 126, `-via cache` 140; none differ.
* **Other harnesses' mutants.** Every mutant in `audit/*/tools/mutants.txt`
  that applied before this change still applies, except five whose text
  was the rewritten hash code (`decimal-rounded`'s `hash-blind`; `enums`'
  `hash-ignores-enum-tcl`, `-native`, `hash-uses-position-tcl`,
  `-native`). Each was rewritten against the new code as the same rule, and
  all five are killed.
* **Traits** (conformance gained the intrinsic branch): `tests/traits.test`
  78/78; `audit/traits/tools/fuzz.tcl` on seeds 1, 17 and 41, 300 programs
  with no failure; `audit/traits/tools/mutate.tcl`, 20 mutants, all killed.
* **The golden framework** (`stdlib/test.bot` names the two new codes):
  `tests/golden-framework.test` 42/42; `audit/golden/tools/fuzz.tcl` seed 3
  and seed 11 under GC stress, no disagreement. Its mutation harness was not
  rerun: it runs every golden suite on four backends per mutant, and the
  change is two entries in `code_name`'s two parallel tables, which no
  mutant touches (all still apply) and `gf-code-name-complete` checks.
* **Fuzzing**: the hashable fuzzer on the final tree, `-n 30 -seed 7`: 30
  programs, no disagreement.
* **Windows CI** (the first push) failed three `hashable.test` tests, all
  defects of the test harness, not of the hashes:
  * `hb-public-hash-oracle` and `hb-keyed-oracle` disagreed with the oracle
    on non-ASCII Strings only: `exec <<` wrote the JSON in the system code
    page and Python read it in its own. The hand-off is ASCII now (non-ASCII
    characters as `\u` escapes, in the test and the fuzzer), and the oracle
    decodes its input as UTF-8 whatever the locale. Under a non-UTF-8 system
    encoding (`LC_ALL=C`) the old hand-off fails here too, and the new one
    passes.
  * `hb-nir-table-hash-total` expected the frame-walk hosts' call effect of
    a function making a Botlish call. Where the depth check bounds recursion
    (`nativeDepthChecked`), such a function is `may_error=true`; the test
    now expects the host's value. A `fallback-roots` driver on Linux gives
    exactly Windows' answer.
* **CI on the branch.** Every job concluded green; the only failures were
  the three Windows harness defects above.
  * `tests.yml`, dispatched on the first commit: the Tcl suite on interp
    (8858 tests, 0 failed) and compile, its cranelift and
    cranelift-generic coverage, the golden shards, the native Rust tests,
    the stub-linked executables, the warning gate and the method-call
    filter audit. Its GC-stress job runs on pushes to main only.
  * `tests-arm64.yml`, dispatched on the first commit: interp (8858 tests,
    0 failed), compile, both coverage jobs (cranelift-generic: 0 failed),
    the golden shards, the Rust tests (also under GC stress) and the whole
    suite under GC stress (8858 tests, 0 failed).
  * `static-decisions.yml`, dispatched on the first commit: all 103 golden
    suites agree between the batched and the sequential scheduler, no
    `DISAGREE` and no `DOES NOT COMPILE`. The two new suites take 2 rounds
    and 3 builds batched, against 9/10 and 5/6 sequential.
  * macOS arm64 and Windows x86-64, on the fix commit: every shard green.

## Limitations

* **Imprint variables cannot be constrained.**
  * Imprinting has no constraints by design (C-ABI-TYPES.md, "Imprinting").
    `List[Hashable]` is TRAIT-STORAGE-UNSUPPORTED, so "K is imprinted from
    the argument and must satisfy Hashable" cannot be written.
  * What exists instead is the trait view: `fn keep(k: Hashable) ->
    Hashable` retains the concrete witness as hidden provenance, and each
    clone has it statically. That is the form available to a future Map
    (next section).
  * Inside an imprinted body, `hash(x: T)` is the dynamic hash, and the
    table hash of a `T` is rejected.
* **Static knowledge bounds the witnesses.**
  * A heterogeneous nested List literal whose element type the checker
    widens to a bare `list` is not provably Hashable.
  * Neither is `std::abi::bytes::Bytes`, whose storage field is declared `any`.
  * Both still hash dynamically.
* **Rejected blocks serialize in a trait program.** The golden suites give
  every rejected block its own Hashable function: blocks that share one
  trait-polymorphic function are decided one plan at a time. Measured: nine
  rounds for eight blocks sharing `fingerprint`, against the suites' budget
  of eight.
* **The Tcl backends' fallback key.** Where no `/dev/urandom` exists
  (Windows), the Tcl reference backends' key is not drawn from a
  cryptographic source.

## Future Map/Set handoff

Available now:

* **`Hashable`**, a key constraint expressed as an ordinary trait: a Map
  operation takes `key: Hashable`.
* **The public `hash`**, deterministic and total for Hashable values.
* **`std::table_hash::of`**, the private, collision-hardened, total table hash,
  callable from any standard library module.

Constraints the collection milestone inherits:

* **Do not expose the keyed numbers.** Bucket placement must never become
  observable: no API may expose slot order or a table hash. Map/Set
  iteration can then stay insertion-ordered while placement is randomized.
* **Stored keys come back as `any`.** Botlish has no generic structs (CO-3),
  so a table's stored keys lose their static type. `std::table_hash::of` admits
  only Hashable, so a table must hash a key at its Hashable-typed boundary
  (the `put`/`get` parameter) and store the keyed hash beside the key, never
  rehash a stored `any`. Comparing a stored key with the probe is `==` of an
  `any`: the dynamic `veq`, unless a typed storage representation proves
  more.
* **Not decided here:** storage, insertion order, Map/Set equality and
  hashing, deletion, resizing and probe policy.

## What to run when changing this

The files are listed below; the Hashable section of AGENTS.md has the
commands.

* `hir/types.tcl`: `Totality`, `Components`, `NoTotality`,
  `IsEqualityTotal`, `HashClass`, `IsHashable`
* `hir/traits.tcl`: the `intrinsics` table, `IntrinsicDecls`, `lookup`,
  `declare`, `resolve`, `satisfies`, `report`, `WitnessName`
* `hir/hir.tcl`'s BuildFull injection
* `hir/range.tcl`'s `VerifyHashing`
* `hir/internal.tcl`
* `hir/direct.tcl`'s intrinsic trait operations
* `hir/format.tcl`, `hir/read.tcl`
* the reserved-name checks in `hir/structs.tcl`, `hir/enums.tcl`,
  `hir/layouts.tcl`, `hir/sourcetypes.tcl` and `surface/modules.tcl`
* `surface/modules.tcl`'s `CheckInternal`
* `core/native.tcl`'s `-hashing` and internal namespaces
* `core/value.tcl`'s `incomparable`
* `core/hashing.tcl`
* `native/lower.tcl`'s `hashing` form and `veqtotal`
* `native/src/nir.rs`
* `native/src/runtime/ops.rs`'s walk, sinks, key and `op_may_error`
* `native/src/codegen/clif.rs`
* `native/src/main.rs`'s `--table-hash-key`
* `native/native.tcl`'s forwarding
