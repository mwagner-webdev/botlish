# Ordered MutableMap and MutableSet

## Result

`std::mutable_map::MutableMap[K satisfies Hashable, V]` and
`std::mutable_set::MutableSet[T satisfies Hashable]` are production
standard-library collections, written in ordinary Botlish: opaque
parameterized structs over MutableVectors, sharing one table engine
(`std::ordered_table`, internal to the standard library). Nothing about
them is a runtime subsystem: no native, no NIR instruction, no runtime
object, no Tcl helper of either collection.

* **Order.** Iteration is insertion order. Setting a present key replaces
  its value in place; removing a key and setting it again appends it.
  Growth, compaction and clear never reorder what remains, on every
  backend, in every process, under every hidden hash key.
* **Hashing.** Placement uses the private keyed table hash
  (`std::table_hash::of`, SipHash-1-3 under a process-local secret,
  HASHABLE-AND-KEYED-HASH.md), computed once per operation and stored per
  entry; equality decides identity.
* **Types.** Keys keep their type: an Int or String probe compares with
  `ieq`/`streq`, a structural key with the total `veqtotal`, never the
  fallible `veq`. Hashable is enforced at every application of the type.
* **Values.** A map or set is a value: copies are independent through
  insertion, replacement, removal, growth, compaction and clear, and a
  unique collection is never copied by its own operations.
* **Cost.** Amortized O(1) contains, at, set, add and remove, O(n)
  iteration, no allocation per lookup, replacement or loop element, and dead
  entries bounded by the live ones under any churn.

Three general language and compiler changes made it expressible, each with
its own tests and mutants:

1. **Place parameters** (`place m: T`, PLACE-PARAMETERS.md): a parameter
   that is its caller's place, so a Botlish function can mutate its caller's
   collection in place, as the collection operations themselves do. This is
   what `m.set(k, v)` is.
2. **The loop protocol** (`hir/iteration.tcl`): `loop x in c` over a
   standard-library collection struct, elaborated into a counted loop over
   its owner module's internal protocol operations, with MutableVector's
   snapshot rule and no materialization.
3. **MutableVector index proofs** (`hir/cardinality.tcl`'s
   `VectorLength`): `std::mutable_vector::at` is proven in range by the
   forms that prove a List's, when nothing resizes the vector's place.

and one correction: `==` refused inside an opaque struct names the opaque
values, never their representation (a map's index would otherwise show the
hidden hash's placement in an error message).

The evidence: six Tcl test files (105 tests) and four golden suites (89
cases, every backend), an independent Python model, a stateful
differential fuzzer, 57 mutants (every one killed), and a benchmark beside
the hash-table experiment's tables and Rust's `HashMap`.

## Public API

`std::mutable_map` (stdlib/mutable_map.bot):

| member | meaning |
|---|---|
| `opaque struct MutableMap[K satisfies Hashable, V]` | the map type |
| `struct MutableMapEntry[K, V]` (`key`, `value`) | an entry, as a loop visits it |
| `error KeyNotFound` | a key with no entry |
| `create[K, V]() -> MutableMap[K, V]` | an empty map |
| `with_capacity[K, V](count) -> MutableMap[K, V]` | an empty map that holds COUNT entries without growing (a performance request only) |
| `length(m) -> int`, `empty?(m) -> bool` | the entry count |
| `contains(m, key) -> bool` | whether KEY has an entry |
| `at(m, key) -> V errors KeyNotFound` | KEY's value |
| `set(place m, key, value) -> unit` | a new key appended, a present key's value replaced in place (its stored key kept) |
| `remove(place m, key) -> V errors KeyNotFound` | the entry removed, its value returned; the map unchanged on KeyNotFound |
| `clear(place m) -> unit` | every entry removed |
| `loop e in m:` | every entry, in insertion order, as a `MutableMapEntry[K, V]` |

`std::mutable_set` (stdlib/mutable_set.bot):

| member | meaning |
|---|---|
| `opaque struct MutableSet[T satisfies Hashable]` | the set type |
| `create[T]()`, `with_capacity[T](count)` | an empty set |
| `length(s)`, `empty?(s)`, `contains(s, x)` | as for a map |
| `add(place s, x) -> bool` | true when X was added (last), false when present (unmoved) |
| `remove(place s, x) -> bool` | true when X was removed, false when absent |
| `clear(place s) -> unit` | every element removed |
| `loop x in s:` | every element, in insertion order |

Construction states its types (`create[str, int]()`): an empty collection
has no element to imprint them from. Every mutating operation takes the
collection as a place parameter, so its receiver is a place of the caller
(MUTABLE-PLACE-RECEIVER otherwise), written `m.set(k, v)`. There is one
missing-key outcome, the declared error KeyNotFound: no null, no default, no
sentinel. `std::mutable_map::iteration_end`, `iteration_live?` and
`iteration_at` (and the set's) are the loop protocol, internal to the
standard library (INTERNAL-NAMESPACE, or NOMETHOD-CALL with method syntax).

## Semantic order

The contract is the order a list of operations defines, independent of
hashing:

* a key's position is fixed when it is first set (or, after a removal,
  when it is set again): every later `set` of the key replaces the value
  and keeps both the position and the stored key;
* removing a key removes its position; setting it again creates a new
  position, after every existing one;
* a set's `add` of a present element changes nothing, and `remove` then
  `add` moves it last;
* `clear` empties the collection; what is added afterwards starts a new
  order.

The independent model (audit/mutable-map/tools/oracle.py) is exactly this:
a Python dict, whose iteration order follows these rules, and an ordered-set
model of a membership set beside the list of live elements.

## Representation

A compact ordered table (the hash-table experiment's `cd`, with removal):

```
opaque struct Table[K satisfies Hashable]:   # std::ordered_table
    index: MutableVector[int]     # 2^k slots (k >= 3): -1 or an entry position
    hashes: MutableVector[int]    # per position: the entry's keyed hash, or -1 (dead)
    keys: MutableVector[K]        # per position: the key
    live: MutableArray[int]       # one cell: the live entry count

opaque struct MutableMap[K satisfies Hashable, V]:
    table: std::ordered_table::Table[K]
    vals: MutableVector[V]        # per position: the value

opaque struct MutableSet[T satisfies Hashable]:
    table: std::ordered_table::Table[T]   # no value per element
```

The *entries* are dense, in insertion order, across the parallel vectors
`hashes`, `keys` (and a map's `vals`); the *index* is an open-addressed
array of entry positions. Iteration walks the positions in order and skips
the dead ones; the keyed hash only places a position in the index.

Alternatives considered (the hash-table experiment, HASH-TABLE-EXPERIMENT.md,
measured them all on this compiler):

* **Linear probing with entries in the slots (`lp`/`lpa`).** The fastest
  general table the experiment found (40-46 ns hits), but its iteration
  order is slot order -- the hash's placement -- so insertion order would
  need a separate order structure (a linked list through the slots, or an
  order vector with its own tombstones), and every resize would move every
  entry. It cannot meet "the keyed hash decides where an entry lives, never
  where it appears in iteration" without becoming a compact dict anyway.
* **Robin Hood (`rh`).** Bounded miss tails for 30-45 % more insert work;
  the order problem of `lp`.
* **Separate chaining (`chain`).** An allocation per entry and three times
  the build cost; order again separate.
* **A sorted array.** O(n) insertion, and its order is the keys', not the
  insertions'.

## Why this representation

* Insertion order is the entries' own order, so the order law holds by
  construction: no operation but compaction ever moves an entry, and
  compaction is a stable filter. Resizing rebuilds only the index.
* The experiment measured the compact dict at 138 ns per growing insert
  (the cheapest growing build on its baseline) and the least memory, 40-57
  bytes per entry against 48-98 for `lpa`, at the cost of one more
  indirection on a lookup (15-25 % on hits).
* Its open question was removal ("a real one needs either tombstones in the
  entry vectors or a compaction"). Production answers it with both halves
  of the experiment's evidence: the index never holds a tombstone (removal
  is `lp`'s backward shift, so probe lengths stay those of the live
  entries), and the entry vectors hold dead entries until a stable
  compaction drops them.
* Everything is a MutableVector of a concrete element type: typed storage,
  copy-on-write per vector, no allocation per entry, and every operation
  expressible as ordinary Botlish over the vector operations.

## Hashing

Every operation that takes a key computes `std::table_hash::of(key)` once,
in the collection's own function (`contains`, `at`, `set`, `remove`, `add`),
and carries it through the probe; the engine never hashes. The NIR of a
map program has exactly one `tablehashtotal` per operation and no public
`hash` (`tests/mutable-map.test`'s `mm-one-keyed-hash`).

The stored hash (61 bits, never negative; -1 marks a dead entry) serves
three purposes: the probe compares a key only at an entry whose stored hash
equals the key's (`holds?`: 200 hits, 200 misses and 200 fresh insertions
of struct keys compare exactly 200 keys, `ot-keys-compared-on-hash-match-only`);
rebuilding the index never rehashes a key; and a dead entry is its -1.

The secret affects placement only. Every observation is the same under any
hidden key: the tests run the same programs under two fixed keys and the
processes' own drawn ones (`mm-secret-independent`,
`ot-invariants-hidden-keys`), the fuzzer runs every program under two fixed
keys on every compiled backend, and the collision corpus of the public hash
(`audit/hashable/data/int-collide-1024.txt`) is a set of ordinary keys to
the table. Collisions of the table's own hash need the secret: under a
fixed test key they are made deliberately (Collision corpus, below).

## Typed storage

`keys: MutableVector[K]` holds the key type the application states, so a
key read back is a K, and an operation's equality is K's. The struct
registry shows the representation (`ms-no-value-storage`: a set's fields
are `table`, a map's `table vals`). Natively, the probe instance of a
`MutableMap[str, V]` compares keys with `streq` and of a `MutableMap[int,
V]` with Int equality, and even unspecialized (cranelift-generic) the
comparison is the total `veqtotal`, never `veq` (`mm-typed-probe`,
`ms-typed-probe`). The mutants `erased-key-storage`, `untyped-key-equality`
and `untyped-string-equality` are killed by them.

## Equality lowering

| key type | Tcl compiler | native |
|---|---|---|
| Int | Tcl `==` on the words | `ieq` (a word compare for small Ints) |
| String | `string equal` | `streq` |
| enum | case word compare | `enumeq` |
| struct, List, nested | `core::value::equal` | `veqtotal`: structural, cannot refuse a kind |

Hashable admits exactly the types whose equality is total
(`hir::types::HashClass`), so no probe has an EQUALITY error edge.

## Probing

`slot_of(t, h, key)` probes the index linearly from the home slot
`bit_and(h, slots - 1)`: a slot holding -1 ends the probe (absent); a slot
holding position e is the key's when `hashes[e] == h` and `keys[e] == key`.
Invariants, which `tests/ordered-table.test` checks after every operation
of random sequences (on the Tcl backend, reading the vectors through the
runtime):

* the index has a power of two of at least 8 slots, each -1 or the position
  of a live entry, and every live position is in exactly one slot;
* every live entry's slot is reachable from its home slot through occupied
  slots (no empty slot between them);
* a live entry's stored hash is its key's table hash; a dead entry's is -1;
* `hashes`, `keys` (and a map's `vals`) have one element per position;
* the live count is the number of live entries.

Removal is backward shift: the emptied slot is filled by the next entry of
the cluster whose home slot is not cyclically in (hole, slot], until an
empty slot. The index therefore never holds a tombstone, and a lookup's
probe length is the live entries'.

## Growth

* Slots: a power of two, at least 8.
* Load: an insertion that would make the live entries exceed 7/10 of the
  slots rebuilds first.
* A rebuild sizes the index for the live entries plus the one being added
  at most half full (the smallest power of two that holds them at load
  1/2), and compacts the entries when any is dead.
* `with_capacity(n)` sizes the index for n entries the same way, so n
  insertions never rebuild.

Alternatives measured: TBD (Performance, "Policy").

## Deletion

A removal takes the entry's slot out of the index (backward shift), marks
the entry dead (hash -1) and decrements the live count. The dead entry's
key and value stay in the entry vectors, unreachable (no slot points at
them, and iteration skips them), until the next compaction.

**The garbage rule.** A removal that leaves at least max(8, live) dead
entries rebuilds the table. So dead entries never outnumber live ones by
more than 8: churn (insert, remove, insert...) keeps the entry vectors
bounded, and after a mass removal the index shrinks back to the live
entries' size (`ot-churn-bounded`: 600 insertions, each removed two
operations later, never exceed 10 positions and 8 slots;
`ot-shrink-after-removal`: 2000 entries removed to 3 shrink the index from
4096 slots to 16).

## Compaction

A rebuild with dead entries first compacts, in place: one pass over the
positions moves each live entry down to the next write position (keys and
hashes together; a map's values by the same pass over the same liveness,
before the table's), then truncates the vectors to the live count. The pass
is a stable filter, so the order survives; the index is then rebuilt from
the compacted positions. A compaction allocates one counter (a one-cell
MutableArray) and nothing else.

## Copy and value semantics

Every field of a map or set is a collection header, so a logical copy is
one share per field (`mutable_vector#share`, O(1)): copy-on-write is the
vectors' own, per vector. The first write to a shared vector detaches that
vector alone (one shallow copy); a unique collection is never copied by its
own operations, because every mutation reaches it through place parameters:
building and updating 3000 entries of a map makes no logical copy and no
detach of any of its vectors (`mm-no-copies`; `pp-no-copies` for 10000
updates through a recursive place function).

Copies stay independent through every mutation, including the multi-vector
ones -- growth (all three vectors and the index rebuilt), compaction (the
entry vectors rewritten and truncated) and clear: `mm-copies-independent`
(a binding, an argument, a result, a struct field, a List element) and
`mm-copies-adversarial` (a, b = a, c = b mutated in turn across growth,
deletion, compaction and clear: each exactly its own history, the vectors of
one logical version never mixed with another's), and the fuzzer's programs,
which copy collections and mutate the copies in turn. The native mutants
`push-after-sharing-aliases` and `clear-after-sharing-aliases` (a push or a
clear that skips the detach) are killed by them.

## Iteration

`loop x in c` over a MutableMap or MutableSet is the loop protocol of its
owner module (hir/iteration.tcl): three `nomethod` functions over positions,
`iteration_end(c)` (the position count), `iteration_live?(c, i)` and
`iteration_at(c, i)`. After the checks, the loop is written out as

```
c#domain = c                       # a logical copy: the snapshot
loop c#position from 0 to iteration_end(c#domain):
    if iteration_live?(c#domain, c#position): (nothing) else: continue
    x = iteration_at(c#domain, c#position)
    BODY
```

The element is `MutableMapEntry[K, V]` for a map (built field by field and
scalar-replaced: no allocation per element) and the element for a set.
Every other rule is the List loop's: the loop collects the body's values,
`continue` contributes nothing, `break` ends with the List so far.

**Mutation during iteration** is MutableVector's existing rule: the loop
iterates the collection as it was when the loop began. The domain is a
logical copy of the collection, so a body that mutates the collection
detaches what it writes (the copy keeps the old vectors); a body that does
not touch it copies nothing (`ci-snapshot-copies-only-when-needed`).
Nothing is materialized: iterating 1000 or 2000 entries allocates the same
(`ci-no-materialization`).

The protocol is a seam, not map knowledge: `hir::iteration`'s table names
the iterable structs, and each one's module provides the three functions.
The protocol operations are internal to the standard library. A lockstep
loop cannot iterate a collection (TYPE): its clauses advance over a count
the compiler proves equal, which a collection's is not.

## MutableMap API

```
import std::mutable_map

counts = std::mutable_map::create[str, int]()
loop word in ["fig", "pear", "fig", "kiwi", "pear", "fig"]:
    n = counts.at(word):
        on std::mutable_map::KeyNotFound:
            0
    counts.set(word, n + 1)

loop e in counts:            # [["fig", 3], ["pear", 2], ["kiwi", 1]]
    [e.key, e.value]

old = counts.remove("pear"):
    on std::mutable_map::KeyNotFound:
        0
counts.set("pear", 9)        # "pear" is now last
```

A function that updates a map takes it as a place parameter:

```
fn tally(place m: std::mutable_map::MutableMap[str, int], word: str) -> unit:
    n = m.at(word):
        on std::mutable_map::KeyNotFound:
            0
    m.set(word, n + 1)
```

## MutableSet API

```
import std::mutable_set

seen = std::mutable_set::create[int]()
fresh = loop x in [5, 2, 5, 9, 2]:
    seen.add(x)              # [true, true, false, true, false]
seen.remove(5)
seen.add(5)
loop x in seen:              # [2, 9, 5]
    x
```

## Mutable equality and the Hashable boundary

* `==` of two maps or two sets is refused at run time (EQUALITY), as for
  their MutableVectors, and the message names the opaque values
  (`<opaque std::mutable_map::MutableMap> == <opaque ...>`), never their
  representation (`mm-no-equality`).
* Neither is Hashable: they hold MutableVectors, which are not, and
  Hashable has no user witness. `hash(m)` and a Hashable parameter refuse
  one statically (TRAIT-NOT-SATISFIED, `mm-not-hashable`). Neither received
  an exception.
* Content comparison is ordinary Botlish over the public API, and order is
  no part of it: same length, and every key present with an equal value
  (`mm-content-comparison`, `ms-content-comparison`). The milestone adds no
  content `==` and no content hash: a mutable value's hash would change
  under it, and an order-independent content hash would have to be
  specified first (a commutative combination of the keyed entry hashes is
  possible in ordinary Botlish over the iteration, but it would be the
  public hash's, and no use needs it yet).

## ImmutableSet

TBD (measured comparison and recommendation).

## Oracle

`audit/mutable-map/tools/oracle.py`: a Python model that shares nothing
with the implementation but the meaning of the operations. A map is a
Python dict (insertion-ordered with exactly the collection's rules); a set
is a membership set beside the ordered list of its live elements. It never
hashes. Keys are integers: the fuzzer builds every Botlish key from one id
by an injective construction, so two keys are equal exactly when their ids
are. `oracle.py selftest` checks the model on the rules themselves.

## Fuzzing

TBD.

## Mutation testing

TBD.

## Collision corpus

Two corpora, of two different hashes:

* **The public hash's** (`audit/hashable/data/int-collide-1024.txt`, the
  hash-table experiment's): 1024 Ints on one home slot under `hash`. To the
  table they are ordinary keys, because the table never uses the public
  hash: their keyed hashes are as spread as any others'. `mm-collision-corpus`
  (256 of them: every lookup, every third removed, the order after),
  `ms-collision-corpus` (512, a set) and the fuzzer's `collide` kind use
  them; the benchmark's `int-collide` rows measure them, and cost what
  `int-sparse` keys cost (Performance).
* **The keyed hash's** (`audit/mutable-map/data/keyed-collide.txt`, written
  by `audit/mutable-map/tools/keyed-collide.tcl`): 512 Ints whose table hash
  under the hidden key {1 2} has its low 10 bits zero, so they share one
  home slot in every index of up to 1024 slots. These are genuine
  collisions of the table's hash, possible only because the tests install
  the key (`core::hashing::useTableHashKey`, the driver's
  `--table-hash-key`); under a process's own drawn key they are ordinary
  keys again. `ot-keyed-collisions` builds 64 of them into one probe cluster
  of 64 occupied slots (every live entry's home the same slot), removes a
  third from inside the cluster (backward shift), replaces a third and
  reinserts some, and checks every invariant after every operation; the
  fuzzer's `kcollide` kind runs its programs under that key on every
  backend.
* **Collisions of the full stored hash** (two different keys with the same
  61-bit keyed hash) cannot be found under SipHash: `mm-full-hash-collisions`
  injects them with a private library whose map keeps two bits of the hash,
  and every lookup, removal and replacement is still decided by key
  equality.

## Performance

TBD.

## Compiler changes

Every change is general -- none names a map or a set, a key type or the
engine -- and each has its own tests and mutants (audit/mutable-map/tools/
mutants.txt, "Place parameters", "The loop protocol", "MutableVector index
proofs", "Opaque equality refusals").

1. **Place parameters** (PLACE-PARAMETERS.md). The parser's `place` marker
   (surface/parser.tcl's `PlaceMarker`; a parameter must state its type),
   a block's `places` (hir/syntax.tcl's `withPlaces`, carried by resolution,
   HIR text and its reader, hence by interchange and the front-end cache),
   the checks (hir/mutvec.tcl: the parameter's type holds a collection and is
   unrestricted; the argument is a place of the caller; no two place
   arguments of one call overlap; never a function value; never captured;
   hir/traits.tcl: never a trait implementation) and the elaboration (no
   entry copy, never moved, read out by copy; an argument the same call
   updates an overlapping place of is copied). The length proofs count a
   place call as resizing every vector under its place
   (hir/cardinality.tcl's `ResizedPlaces`, `Mutated`).
   Why: a Botlish function could not change its caller's collection; the
   collections' mutating operations are such functions. Evidence: 28 Tcl
   tests, 42 golden cases (with the index proofs'), 5 mutants; the map's and
   set's own tests and fuzzer use place calls throughout; a unique map is
   never copied (`mm-no-copies`: 0 shares, 0 detaches over 3000 entries).
2. **The loop protocol** (hir/iteration.tcl). A table of iterable
   standard-library structs; a loop over one is typed by its owner's
   `iteration_at` (hir/types.tcl, hir/affine.tcl), refused in a lockstep
   loop, and elaborated after the checks (before MutableVector's copies,
   which give it its snapshot) into a counted loop over the protocol. The
   protocol's operations are internal to the standard library
   (surface/modules.tcl's `CheckInternal`), `nomethod`, and left out of the
   generated reference (tools/compilerpedia.tcl) and marked std-internal in
   the standard-library census.
   Why: the brief's "smallest collection-agnostic seam" -- the existing
   `loop x in xs` over a List or a vector, extended to any struct whose
   module states positions, liveness and element; no iterator object, no
   materialized List, and MutableVector's snapshot rule unchanged.
   Evidence: 15 Tcl tests, 10 golden cases, 3 mutants (plus the
   collections' own iteration mutants); iterating 2000 entries allocates
   what 1000 do.
3. **MutableVector index proofs** (CP-6-lite). `std::mutable_vector::at`
   joins the bounds family `mutvec` (core/mutvec.tcl's `-bounds`), and
   `hir::cardinality::VectorLength` gives a vector's length a stable form
   exactly when the vector's place is not resized anywhere in its function
   (no push, pop, take or clear on it, no place call over it) and its root
   is no context parameter; every proof form of a List (guard, counted
   loop, reduction by `mod` or a mask) then applies.
   Why: the engine's total reads -- `key_at`, a map's `iteration_at` -- read
   a K or a V at a position reduced into the vector's own length, which no
   default value can stand in for (a handler needs a value of the element
   type, and K has none in general). The proof is the analysis's only:
   natively a proven vector read is still the checked runtime call
   (`mvat`, `rt_mv_at`), because native lowering's check-free siblings
   (`provenOps`) cover List and MutableArray reads but not MutableVector's
   (Performance, "Where the instructions go"). Evidence: 13 Tcl tests (6 proven, 6 unproven, and a sweep
   running every proven read in range on every backend), their golden
   ports, and 4 wrong-fact mutants (a length that ignores resizes, ignores
   place calls, is one form for every vector, or trusts a context member),
   each killed.
4. **Opaque equality refusals.** `==` refused inside an opaque struct is the
   opaque values' refusal on every backend (core/value.tcl's struct case,
   ops.rs's `equal`), so the message never shows the representation. 2
   mutants.
5. **Internal Botlish modules** (`core::native::declareInternalModule`): a
   standard-library module no program may import, as an intrinsic namespace
   can already be internal (`std::table_hash`). `std::ordered_table` is the
   first.

## Regression and CI

TBD.

## Limitations

Deliberate omissions, and costs measured but not fixed:

* **Method syntax with both collections imported.** `m.length()` in a
  program that imports std::mutable_map *and* std::mutable_set has two
  candidates of one kind (`struct`), which the method-call kind filter
  (METHOD-DECISION-FILTER.md) may not tell apart: it excludes by the plain
  value kinds only, never by a type's name (AGENTS.md). Such a program gets
  the exact decision's whole-program trial builds. The cost is real: the
  three golden suites of this milestone, written as one suite importing
  both, took 45 builds (40 method trials) and a 173 s front end; split by
  imports (a call both modules define written qualified in the one suite
  that needs both), 47 s for the same 47 cases. A small program importing
  both compiles in 2.2 s with method calls against 0.9 s without (7 builds
  against 3). The fix is a general one -- exclude a candidate whose first
  parameter is a different nominal struct than the receiver's -- and needs
  a design decision on that AGENTS.md rule, so it is a follow-up, not part
  of this milestone. Until then: import the collection a program uses, or
  write the shared names qualified.
* **No get-with-default and no update-in-place.** A lookup of a key that
  may be absent is `at` with a handler, and incrementing a value is `at`
  then `set` (two probes, two keyed hashes). An `update` or `entry` API is
  a later addition; it needs a callable that may fail, under the
  callable-contract model.
* **No keys()/values() Lists**: a loop collects them (`loop e in m: e.key`).
* **`with_capacity` presizes the index only.** MutableVector has no
  reserve, so the entry vectors still grow by doubling (O(log n)
  allocations over n insertions, amortized O(1)).
* **Values are unrestricted.** An affine V (a coroutine handle) is refused
  at `create` (IMPRINT: an imprinted function may copy its values), and an
  affine key is not Hashable. The refusal of `create` currently also
  reports follow-on diagnostics at the uses of the map (its type becomes
  `MutableMap[any, any]` instead of poison: DIAGNOSTIC-RECOVERY.md's rule,
  for the imprint check), a recovery gap of the imprint check, not of the
  collections.
* **No content `==`, no content hash** (above), and neither collection is
  Hashable.
* **The index shrinks only by the garbage rule** (and `clear`): removing a
  few entries from a large map keeps its index until dead entries reach
  max(8, live).
* **The reference interpreter is slow on these collections**: about 4 ms
  per operation (every engine helper is interpreted), against about 0.1 ms
  on the Tcl compiler and 60-300 ns natively. The fuzzer runs the
  interpreter on a third of its programs.
* **ImmutableSet was not rewritten** (below).

## Future immutable Map

An immutable ordered value Map is the obvious next collection for JSON and
value-tree workloads, and this milestone makes it buildable, but not as
ordinary Botlish yet.

* **What JSON needs.** An object is a value: immutable, nested inside other
  values, compared with `==` (two documents are equal when their objects
  are), usable inside a set or as a key (Hashable when its keys and values
  are), and iterated in its source order. MutableMap gives the order and
  the O(1) lookups, but it is not comparable and not Hashable, so it cannot
  be a field of a value that is.
* **What carries over.** The engine's layout -- dense entries in order, an
  index of positions, stored keyed hashes -- is exactly a frozen map's: a
  parser builds a MutableMap and freezes it (as MutableArray freezes into a
  List), and lookups in the frozen form cost what they cost here. Ordered
  iteration, typed storage and the keyed hash's independence carry over
  unchanged.
* **What is missing: content equality.** `==` of an ordinary Botlish struct
  is structural over its representation, and an ordered table's
  representation depends on its history (dead entries, the index's size)
  and on the hidden hash key (the index's slots). Two equal maps would
  compare unequal. An immutable map needs `==` and `hash` defined by its
  contents (order-insensitive equality is the natural choice for JSON
  objects, with the order kept for iteration), which Botlish cannot state
  for a user type today: there is no module-defined equality, by design
  (Hashable has no user witness, HASHABLE-AND-KEYED-HASH.md).
* **Recommendation.** The next collection milestone is
  `ImmutableMap[K satisfies Hashable, V]`, insertion-ordered, with
  `std::mutable_map::freeze`, content `==` and a content hash (Hashable when
  K and V are). Either as an intrinsic beside ImmutableSet, whose equality
  and hash the runtimes already define by content, or -- the ordinary
  route -- after a milestone that lets an opaque struct's module define its
  equality and hash under the same totality rules as the intrinsic
  witnesses. The second is the larger change and the one that would also
  let ImmutableSet become ordinary (below).

