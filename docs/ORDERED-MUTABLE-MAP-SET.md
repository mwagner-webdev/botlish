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
  entries bounded by the live ones under any churn. Natively an Int hit
  takes 64 ns at 1024 entries and 157 ns at 65536, a presized insertion 95
  and 138 ns, iteration 17-19 ns per entry: 0.9-2.3 times the hash-table
  experiment's tables on lookups and insertions, the difference being
  mostly the keyed hash they did not pay, which in turn keeps a lookup at
  71 ns on the public hash's collision corpus where theirs take 2-2.5 µs
  (Performance).

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

The evidence: six Tcl test files (107 tests, also under GC stress) and
four golden suites (90 cases, every backend), an independent Python model,
a stateful differential fuzzer (0 disagreements in 56 programs and 121,848
observations, under fixed hidden keys and GC stress too), 57 mutants of the collections and their seams (every one killed), the whole Hashable (45) and trait-constrained-type (43) harnesses and 15 rewritten mutants of four others (every one still killed),
and a benchmark beside the hash-table experiment's tables and the Rust
reference, in time and in instructions, whose profile found and removed two
costs of the first engine (Performance, "Where the instructions go").

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
* Every per-entry field is a MutableVector of a concrete element type:
  typed storage, copy-on-write per vector, no allocation per entry, and
  every operation expressible as ordinary Botlish over the vector
  operations.
* The index is a MutableVector too, not the experiment's MutableArray: a
  rebuild changes its size in place, through the table's place parameter,
  and a place can change a vector's length but no Botlish operation
  replaces a field. (That is why a rebuild refills the index one push per
  slot: Performance.) The live count is a one-cell MutableArray for the
  same reason: a place can update a cell, not rebind an Int field.

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

**Alternatives measured** (instructions per operation, Int and String keys
at 1024 and 65536 entries, `policy-*.tsv`: the same benchmark compiled
against a standard library with one rule changed):

| policy | growing `set` | presized `set` | `at` hit | `contains` miss | `remove` | churn |
|---|---:|---:|---:|---:|---:|---:|
| load 7/10, garbage max(8, live) (chosen) | 2,637-2,760 | 1,479-1,539 | 1,036-1,126 | 921-1,108 | 2,876-3,330 | 3,886-4,747 |
| load 1/2 | 2,187-2,402 | 1,458-1,520 | 1,037-1,148 | 914-1,125 | 3,255-3,501 | 3,242-4,698 |
| load 17/20 | 3,302-3,728 | 1,465-1,528 | 998-1,168 | 925-1,142 | 2,964-3,528 | 3,989-4,703 |
| garbage max(8, live / 4) | 2,522-2,814 | 1,455-1,534 | 1,031-1,122 | 904-1,058 | 6,481-6,852 | 6,337-7,216 |

* **Load 1/2** builds 13-20 % cheaper (shorter probe chains near the
  threshold, where linear probing's insertions grow long) and churns up to
  17 % cheaper, with lookups unchanged and removal up to 22 % dearer; it
  costs an index 40 % larger on average (2-4 slots per entry instead of
  1.4-2.9: about 7 more bytes per entry, a sixth of the table), which the
  instruction counts cannot charge and the large sizes' lookups would pay
  in cache misses. 7/10 is the experiment's measured choice (SPEC.md,
  HASH-TABLE-EXPERIMENT.md) and stays; 1/2 is the alternative for
  build-heavy tables.
* **Load 17/20** makes every growing build 21-35 % dearer for an index 18 %
  smaller.
* **Compacting earlier** (a quarter of the live entries dead) makes
  removal 2.0-2.4 times and churn 1.5-1.6 times dearer (compaction runs
  four times as often) to save dead entries nobody reads: the chosen rule
  already bounds them by the live ones.

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
ones -- growth (the index rebuilt, the entry vectors grown), compaction
(the entry vectors rewritten and truncated) and clear: `mm-copies-independent`
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

`std::immutable_set` (MINIMAL-IMMUTABLE-SET.md) is unchanged: an intrinsic
value kind on every backend, whose `==` is set equality and whose `hash`
is order-independent, built by `from_list` and asked by `contains`. Its
representation is the simplest sound one that milestone chose on purpose:
a deduplicated vector, construction O(n^2) and membership O(n) by the
generic equality, no hashing.

Measured beside MutableSet (instructions per operation, Int elements,
`immutable-set.tsv`):

| elements | `from_list`, per element | MutableSet `add` | `contains` hit: ImmutableSet | MutableSet | `contains` miss: ImmutableSet | MutableSet |
|---:|---:|---:|---:|---:|---:|---:|
| 16 | 726 | 2,578 | 795 | 788 | 1,429 | 1,161 |
| 256 | 10,735 | 2,375 | 10,878 | 911 | 21,595 | 1,037 |
| 1024 | 42,992 | 2,363 | 43,129 | 905 | 86,102 | 1,080 |
| 4096 | 172,010 | 2,461 | 172,157 | 930 | 344,154 | 1,138 |

* At 16 elements the two are equal on hits, and ImmutableSet builds 3.5
  times cheaper (one allocation, no index); from a few dozen elements on,
  its linear membership loses by its size: 12 times at 256, 185 times at
  4096.
* **Recommendation: ImmutableSet stays intrinsic, and gets a hashed
  representation in a milestone of its own.** It is not rewritten over the
  engine here (the brief's rule, and the design law that a collection is
  made ordinary when the language can express it cleanly): ordinary Botlish
  cannot state an opaque struct's content equality or content hash, which
  are ImmutableSet's defining properties (`==` regardless of construction
  order, Hashable elements of other sets and maps). What it lacks is
  representation, not semantics, and MINIMAL-IMMUTABLE-SET.md committed to
  none: a frozen compact table (this engine's layout, keyed hash stored per
  element, built once by `from_list`) gives it MutableSet's membership cost
  behind an unchanged API, with its content equality and order-independent
  hash computed as today. Until then a program that tests membership in a
  large set uses MutableSet.

## Oracle

`audit/mutable-map/tools/oracle.py`: a Python model that shares nothing
with the implementation but the meaning of the operations. A map is a
Python dict (insertion-ordered with exactly the collection's rules); a set
is a membership set beside the ordered list of its live elements. It never
hashes. Keys are integers: the fuzzer builds every Botlish key from one id
by an injective construction, so two keys are equal exactly when their ids
are. `oracle.py selftest` checks the model on the rules themselves.

## Fuzzing

`audit/mutable-map/tools/fuzz.tcl` writes stateful programs and compares
every observation with the oracle's, on every backend.

* **A program** is one long operation sequence over several collections
  of one key kind: two to start (a map and a set), then copies of them
  (`b = a`, up to seven variables) mutated in turn. The operations: `set`
  of a new or an existing key, `at` hit and miss, `contains`, `remove` hit
  and miss, `add`, `length`, `clear`, iteration, a copy, a fill (a run of
  fresh keys: several rebuilds), a drain (most of the last fills' keys
  removed: compaction and the index shrinking) and a bump (a loop that
  mutates the collection it iterates: replacement, insertion, removal and
  growth during iteration, against the snapshot rule). Every operation
  pushes observations (a found value, a membership bit, a length, every
  key and value in iteration order); the program's result is their List.
* **Keys** of eight kinds: Int, String, an enum, a struct, a nested struct
  (a struct and a List inside), a List, the public hash's collision corpus
  (`collide`) and the keyed collision corpus under its key (`kcollide`).
  Each key is built where it is used from an integer id, injectively, so
  the oracle needs only the ids. **Values** of five kinds per program: an
  Int, its text, a struct, a List and a MutableVector (collections inside
  the map, copied when read out or moved between entries), built from an
  Int and read back to it.
* **Runs.** Every program runs on interp (every third program: it is two
  orders of magnitude slower), compile, cranelift-generic and cranelift;
  with `-keyed 1` (the default) again on every compiled backend under two
  fixed hidden keys, whose observations must be the same; with
  `-gc-stress 1` once more natively with a collection at every allocation
  site. Every fourth program writes its calls with method syntax, the
  others qualified. `-profile large` uses key pools of 50 to 349 and fills
  of 40 to 439 keys (for the compiled backends).

Runs for this report (all on the final engine, 0 disagreements):

| run | programs | operations | observations | backend runs |
|---|---:|---:|---:|---:|
| `-n 24 -seed 101` | 24 | 3,260 | 22,537 | 224 |
| `-n 16 -seed 202 -gc-stress 1` | 16 | 2,176 | 11,744 | 166 |
| `-n 16 -seed 303 -profile large`, compiled backends | 16 | 2,172 | 87,567 | 144 |

The mutation harness runs the fuzzer once more against every mutant (8
programs, every key kind, 50 operations each). The smaller runs made
during development, on earlier states of the engine, found no
disagreement either.

## Mutation testing

`audit/mutable-map/tools/mutate.tcl` applies each mutant of
`audit/mutable-map/tools/mutants.txt` to a private copy of the tree
(rebuilding the native backend for a native mutant) and runs, until one
kills it: the mutant's own test files, then `tests/ordered-table.test`,
`mutable-map.test`, `mutable-set.test` and `collection-iteration.test`,
then the fuzzer (8 programs, every key kind). **57 mutants, 57 killed**,
the brief's (item 51) and one or more for each general seam this milestone
added. The table names the first test that failed, in the first file that
failed:
**Hashing**

| mutant | the bug | killed by |
|---|---|---|
| `public-hash` | placement uses the public hash instead of the keyed table hash | `ot-churn-bounded` (ordered-table) |
| `post-mix-public-hash` | placement post-mixes the public hash with the secret | `ot-churn-bounded` (ordered-table) |
| `no-stored-hash-check` | a probe compares the key at every occupied slot, never its stored hash first | `ot-keys-compared-on-hash-match-only` (ordered-table) |
| `trust-hash` | a probe trusts an equal stored hash without comparing the keys | `ot-keys-compared-on-hash-match-only` (ordered-table) |
| `identity-equality` | total structural equality (struct and List keys) compares identities natively | `mm-equal-keys` (mutable-map) |
| `erased-key-storage` | the keys are stored erased (MutableVector[any]) | `ot-churn-bounded` (ordered-table) |
| `untyped-key-equality` | the probe compares keys through an untyped helper (fallible veq unspecialized) | `mm-typed-probe` (mutable-map) |
| `untyped-string-equality` | native lowering stops choosing streq for two Strings | `mm-typed-probe` (mutable-map) |
| `unconstrained-key` | the map's key slot drops `satisfies Hashable` | `ot-churn-bounded` (ordered-table) |

**Probing**

| mutant | the bug | killed by |
|---|---|---|
| `no-backward-shift` | removal empties its slot without shifting the entries after it back | `ot-churn-bounded` (ordered-table) |
| `probe-no-wraparound` | a probe stops at the index's end instead of wrapping to slot 0 | `ot-invariants-map-int` (ordered-table) |
| `wrong-home-slot` | a lookup starts one slot past the key's home slot | `ot-churn-bounded` (ordered-table) |
| `wrong-probe-mask` | a probe reduces slots modulo the slot count minus one | `ot-churn-bounded` (ordered-table) |
| `load-off-by-one` | an insertion rebuilds one entry past the 7/10 load | `ot-invariants-hidden-keys` (ordered-table) |
| `shift-before-home` | backward shift moves an entry into the hole even when that is before its home slot | `ot-churn-bounded` (ordered-table) |

**Growth and compaction**

| mutant | the bug | killed by |
|---|---|---|
| `resize-drops-entry` | rebuilding the index leaves the last entry out | `ot-churn-bounded` (ordered-table) |
| `resize-reverses-order` | every rebuild (growth included) moves the entries into reverse order, keys, hashes and values alike | `ot-churn-bounded` (ordered-table) |
| `resize-bucket-order` | every rebuild orders the entries by index slot (the hash's placement), keys, hashes and values alike | `ot-churn-bounded` (ordered-table) |
| `compaction-fills-holes-from-end` | compaction fills each dead position with the last live entry (swap-remove: no copying, the order lost), keys, hashes and values alike | `ot-churn-bounded` (ordered-table) |
| `compaction-loses-value` | compacting a map's values truncates one value too many | `ot-churn-bounded` (ordered-table) |
| `compaction-stale-index` | a rebuild that keeps the slot count keeps the old index (stale entry positions after compaction) | `ot-churn-bounded` (ordered-table) |
| `hash-not-moved-with-key` | compaction moves the keys down but leaves the stored hashes where they were | `ot-churn-bounded` (ordered-table) |
| `map-values-misaligned` | a map's rebuild compacts the keys but not the values | `ot-churn-bounded` (ordered-table) |
| `tombstones-never-compact` | the garbage rule never fires: dead entries are only dropped by growth | `ot-churn-bounded` (ordered-table) |

**Replacement, removal, reinsertion**

| mutant | the bug | killed by |
|---|---|---|
| `replace-appends-duplicate` | setting a present key appends a second entry | `ot-invariants-hidden-keys` (ordered-table) |
| `replace-moves-to-end` | setting a present key removes its entry and appends a new one | `ot-invariants-hidden-keys` (ordered-table) |
| `set-duplicate-moves` | adding a present element moves it to the end (and still answers false) | `ot-invariants-set-int` (ordered-table) |
| `remove-leaves-visible` | removal decrements the count but leaves the entry and its slot | `ot-invariants-map-str` (ordered-table) |
| `remove-decrements-twice` | removal decrements the live count by two | `ot-invariants-map-str` (ordered-table) |
| `reinsert-revives-entry` | inserting a key revives its own dead entry (keeping its old position) instead of appending | `ot-invariants-hidden-keys` (ordered-table) |
| `reinsert-reuses-dead-slot` | inserting a new key reuses the first dead position instead of appending | `ot-churn-bounded` (ordered-table) |
| `miss-returns-arbitrary` | a lookup of a missing key returns the last entry's value (when there is one) | `mm-copies-independent` (mutable-map) |

**Clear**

| mutant | the bug | killed by |
|---|---|---|
| `clear-leaves-membership` | clear only resets the count: index and entries stay | `ot-invariants-set-str` (ordered-table) |
| `clear-leaves-entries` | clear empties the index but leaves the entries | `ot-clear-is-minimal` (ordered-table) |

**Set representation**

| mutant | the bug | killed by |
|---|---|---|
| `set-value-storage` | a set stores a value per element too | `ms-no-value-storage` (mutable-set) |

**Iteration**

| mutant | the bug | killed by |
|---|---|---|
| `iteration-exposes-dead` | the map's loop protocol calls every position live | `mm-churn` (mutable-map) |
| `iteration-bucket-order` | the map's loop protocol walks the index slots (hash order) | `mm-churn` (mutable-map) |
| `set-iteration-bucket-order` | the set's loop protocol walks the index slots: its order depends on the hidden key | `ms-collision-corpus` (mutable-set) |
| `iteration-materializes` | each loop over a map first collects every key into a List | `ci-no-materialization` (collection-iteration) |

**Allocation**

| mutant | the bug | killed by |
|---|---|---|
| `lookup-allocates-list` | a probe step builds two one-element Lists to compare the stored hash | `ot-keys-compared-on-hash-match-only` (ordered-table) |

**Copies**

| mutant | the bug | killed by |
|---|---|---|
| `local-copy-shares-header` | `b = a` of a collection-bearing local gives b a's own headers (no entry copy) | `mm-content-comparison` (mutable-map) |
| `push-after-sharing-aliases` | natively, push onto a shared vector backing appends in place (growth after a copy changes the copy) | `mm-copies-adversarial` (mutable-map) |
| `clear-after-sharing-aliases` | natively, clear of a shared vector backing empties it in place (compaction or clear after a copy changes the copy) | `mm-copies-adversarial` (mutable-map) |

**Place parameters**

| mutant | the bug | killed by |
|---|---|---|
| `place-param-entry-copy` | a place parameter gets an entry copy like a value parameter: the caller never sees the update | `pp-callee-copy-and-result` (place-parameters) |
| `place-overlap-unchecked` | one call may give overlapping places to two place parameters | `pp-diag-overlapping-places` (place-parameters) |
| `place-module-binding` | a module binding is accepted as a place argument | `pp-diag-module-binding` (place-parameters) |
| `place-observer-uncopied` | an argument overlapping a place argument of the same call is read out uncopied (it observes the update) | `pp-observer-overlap-copied` (place-parameters) |
| `places-not-printed` | HIR text drops a block's place parameters | `pp-hir-text` (place-parameters) |

**The loop protocol**

| mutant | the bug | killed by |
|---|---|---|
| `protocol-live-check-dropped` | the elaborated loop visits every position, live or not | `ci-empty` (collection-iteration) |
| `protocol-not-internal` | application code may name a loop protocol operation | `ci-protocol-internal` (collection-iteration) |
| `protocol-lockstep-accepted` | a lockstep loop over a collection is accepted (its element count is no proven count) | `ci-lockstep-refused` (collection-iteration) |

**MutableVector index proofs**

| mutant | the bug | killed by |
|---|---|---|
| `vector-length-ignores-resizes` | a vector's length is taken as stable whatever resizes it | `vb-unproven-place-call` (vector-bounds) |
| `vector-length-ignores-place-calls` | a call giving the vector to a place parameter does not count as resizing it | `vb-unproven-place-call` (vector-bounds) |
| `vector-length-one-atom` | every vector place's length is the same form (one vector's guard proves another's read) | `vb-unproven-other-copy` (vector-bounds) |
| `vector-length-context-member` | a context member's vector length is taken as stable | `vb-unproven-context-member` (vector-bounds) |

**Opaque equality refusals**

| mutant | the bug | killed by |
|---|---|---|
| `opaque-refusal-leaks-tcl` | the Tcl runtimes' refusal of == inside an opaque struct names the representation | `mm-no-equality` (mutable-map) |
| `opaque-refusal-leaks-native` | the native refusal of == inside an opaque struct names the representation | `mm-no-equality` (mutable-map) |

Two mutants survived the first full run, and both exposed a weak detector,
fixed by strengthening the test rather than the mutant:

* `iteration-materializes` survived `ci-no-materialization`, which compared
  object counts at 1000 and 2000 entries: a List of every key is one object
  at any length. The test now compares allocated bytes too (a correct loop
  allocates the same at both sizes; the List doubles).
* `vector-length-one-atom` survived because the place form it collapses is
  the fallback of `VectorLength`, reached only for a vector whose value's
  source was resized but whose own place was not -- which no test built.
  `vb-unproven-other-copy` (two copies of a vector taken around a push: a
  guard on the longer proves nothing about the shorter) reaches it, in the
  Tcl suite and in `place-parameters.bot`.

The brief's mutants with no non-equivalent counterpart here are documented
in `mutants.txt`'s header: replacing the stored key with an equal one
(equal Hashable values are indistinguishable), stopping a probe at a
tombstone (the index has none: `no-backward-shift` is the bug of that
family) and the load threshold off by one (no program observes it, so the
representation's invariant test is its detector: `load-off-by-one`).

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

**Method.** `bench/mutable-map.tcl` times ordinary Botlish driver programs
on the specialized native backend (`cranelift`): the best of 5 runs in one
driver process, each operation's cost isolated by differencing (two build
counts, or one pass against several over the same keys: the header lists
every mode's formula). The machine is a shared 4-vCPU container (Intel
Xeon at 2.1 GHz, 15 GB). Its times scatter by 10-30 % from run to run at
the largest sizes, so every comparison that decides something is also
made in instructions (callgrind, `-instructions 1`: deterministic, and
blind to cache misses). The data: `audit/mutable-map/results/`
(`production.tsv` for the collections, `experiment.tsv` and `rust.tsv` for
the hash-table experiment's `lpa` and `cd` and the Rust reference on the
same machine and the same day, `instructions.tsv`,
`experiment-instructions.tsv`, `allocations.tsv`, `policy-*.tsv`,
`immutable-set.tsv`); `audit/mutable-map/tools/summarize.py` and
`compare.py` print the tables below from them.

Key kinds: `int-dense` (0..n-1), `int-sparse`, `str-short` (decimal text),
`str-medium`, `point` (a two-Int struct), `nested` (a struct holding a
struct and a List) and `int-collide` (the public hash's collision corpus).
Sizes 16, 1024, 65536 and 262144 entries (the last two well beyond the
caches: about 2.6 MB and 10.5 MB of table at Int keys).

### The collections

Int keys (`int-dense`), ns per operation:

| operation | 16 | 1024 | 65536 | 262144 |
|---|---:|---:|---:|---:|
| `set`, growing | 277 | 178 | 191 | 361 |
| `set`, presized (`with_capacity`) | 203 | 95 | 138 | 264 |
| `at`, hit | 53 | 64 | 157 | 216 |
| `at`, miss (KeyNotFound handled) | 112 | 143 | 141 | 184 |
| `contains`, hit | 53 | 64 | 118 | 210 |
| `contains`, miss | 83 | 78 | 98 | 143 |
| `set`, replacing | 65 | 78 | 159 | 241 |
| `remove` (in insertion order, compaction included) | 183 | 272 | 315 | 313 |
| iteration, per entry | 26 | 17 | 18 | 19 |
| mixed: 80 % `at`, 10 % `set`, 10 % `remove` | 99 | 103 | 176 | 229 |
| churn: a fresh `set` and an earlier key's `remove` | 360 | 314 | 332 | 468 |
| copy, then one `set` (the copy's first write) | 1.3 µs | 7.3 µs | 1.5 ms | 5.8 ms |
| MutableSet `add`, growing | 226 | 195 | 192 | 252 |
| MutableSet `contains`, hit / miss | 66 / 69 | 62 / 58 | 128 / 106 | 219 / 136 |

Every other key kind has the same shape (`summarize.py`): String keys cost
5-20 % more than Ints up to 1024 entries and up to 40 % more beyond, a
struct key (`point`) about three times an Int's lookup (its equality and
canonical walk are structural), `nested` six times. Iteration is 17-26 ns
per entry for every kind and size: it reads positions in order, so it
never misses the cache the way a probe does.

* **Amortized O(1).** From 1024 to 262144 entries an Int `at` grows from 64
  to 216 ns and `contains` miss from 78 to 143: the cost of cache misses
  (the index, then the entry's hash, key and value, each in its own
  vector), not of longer probes. The index stays at most 7/10 full and is
  rebuilt to half full, so probe sequences stay short at every size
  (`tests/ordered-table.test` checks the load after every operation).
* **A copy is O(1); its first write is O(n).** Copying a map shares its
  vectors; the first `set` of the copy detaches the four vectors it writes
  (the index and the entry vectors), so it costs a copy of the table: 7.3 µs
  at 1024 entries, 1.5 ms at 65536. That is MutableVector's value model
  applied to each vector, and what the brief's copy-then-mutate case
  measures. A unique map is never copied (`mm-no-copies`).
* **A miss through `at` costs 30-65 ns more than a `contains` miss.** The
  difference is the declared error: KeyNotFound raised in `at` and handled
  by the caller (it cost 100-130 ns more before `at` was changed to fail
  once: Performance, "Where the instructions go"). The brief's minimal API has no get-with-default; a
  program that expects misses calls `contains` first or pays the error
  path (Limitations).

### Beside the hash-table experiment and Rust

The same machine and day: the experiment's `lpa` (linear probing with
stored hashes and backward-shift removal, its recommended table) and `cd`
(the compact dict, this collection's layout without removal), and the Rust
reference's `lp` (the same linear probing) and `std::collections::HashMap`.
A miss is a `contains` miss (the experiment's `get` returns a default).
ns per operation:

| keys | operation | n | MutableMap | `lpa` | `cd` | Rust `lp` | Rust `std` |
|---|---|---:|---:|---:|---:|---:|---:|
| Int | insert, growing | 1024 | 178 | 102 | 85 | 20 | 35 |
| Int | insert, growing | 65536 | 191 | 183 | 140 | 85 | 38 |
| Int | insert, presized | 1024 | 95 | 45 | 65 | 13 | 12 |
| Int | insert, presized | 65536 | 138 | 129 | 91 | 51 | 14 |
| Int | hit | 1024 | 64 | 35 | 40 | 8.9 | 8.1 |
| Int | hit | 65536 | 157 | 81 | 98 | 40 | 19 |
| Int | miss | 1024 | 78 | 42 | 58 | 50 | 8.8 |
| Int | miss | 65536 | 98 | 76 | 94 | 44 | 11 |
| Int | replace | 1024 | 78 | 34 | 46 | 19 | 9.8 |
| Int | remove | 1024 | 272 | 56 | -- | 35 | 46 |
| String | insert, growing | 1024 | 200 | 128 | 102 | 67 | 90 |
| String | hit | 1024 | 58 | 49 | 61 | 8.9 | 13 |
| String | hit | 65536 | 177 | 102 | 197 | 50 | 57 |
| String | miss | 1024 | 71 | 44 | 47 | 21 | 11 |
| struct | insert, growing | 1024 | 279 | 184 | 145 | 36 | 46 |
| struct | hit | 1024 | 156 | 83 | 115 | 26 | 11 |
| struct | hit | 65536 | 318 | 191 | 288 | 72 | 26 |

(`compare.py` prints every kind, size and operation.)

* **Production costs 0.9-2.3 times the experiment's tables on lookups
  and insertions,** and 4.9 times `lpa` on removal; 1.6-9 times Rust's
  `lp` where the experiment's `lpa` is 0.8-5 times in this run. The
  difference has three causes, measured below: the keyed hash, which the
  experiment's tables did not pay (they placed entries by the public
  hash); MutableVector element reads, which are runtime calls; and the
  compaction a removal pays for (`lpa` has no dead entries to drop, `cd`
  cannot remove).
* **What the keyed hash buys.** On the public hash's collision corpus
  (`int-collide`, 1024 keys) the experiment's tables, which hash with the
  public hash, collapse into one probe chain; the production table does
  not notice:

  | 1024 colliding keys | MutableMap | `lpa` | `cd` | Rust `lp` | Rust `std` |
  |---|---:|---:|---:|---:|---:|
  | insert, growing | 206 | 5,829 | 4,697 | 1,387 | 53 |
  | hit | 71 | 2,546 | 2,157 | 231 | 8.1 |
  | replace | 74 | 2,511 | 2,347 | 200 | 9.7 |
  | remove | 239 | 4,215 | -- | 2,162 | 45 |

  (Rust's `lp` hashes with the experiment's public hash too; `std` with its
  own keyed SipHash, which is why it is the one other row that stays flat.)

### Where the instructions go

Instructions per operation (`instructions.tsv`, `experiment-instructions.tsv`;
a miss is a `contains` miss):

| keys | operation | n | MutableMap | `lpa` | `cd` | Rust `lp` | Rust `std` |
|---|---|---:|---:|---:|---:|---:|---:|
| Int | insert, growing | 1024 | 2,510 | 1,334 | 1,233 | 398 | 509 |
| Int | hit | 1024 | 1,078 | 491 | 571 | 144 | 106 |
| Int | hit | 65536 | 1,104 | 525 | 629 | 184 | 106 |
| Int | miss | 1024 | 1,149 | 640 | 645 | 351 | 104 |
| Int | replace | 1024 | 1,066 | 480 | 597 | 189 | 131 |
| String | insert, growing | 1024 | 2,532 | 1,344 | 1,276 | 822 | 1,126 |
| String | hit | 1024 | 1,125 | 669 | 756 | 130 | 168 |
| String | miss | 1024 | 875 | 564 | 568 | 103 | 161 |
| struct | insert, growing | 1024 | 3,646 | 1,937 | 1,797 | 486 | 659 |
| struct | hit | 1024 | 2,472 | 1,358 | 1,448 | 326 | 127 |
| struct | miss | 1024 | 2,116 | 1,168 | 1,173 | 460 | 123 |

A callgrind profile of the native runs (runtime functions by name; the
compiled Botlish code is anonymous) splits an Int hit at 1024 entries,
1,045 instructions, into:

* **the keyed hash, about 425 (41 %)**: SipHash-1-3 over the key's canonical
  input (`Sip::write` 207, `rt_table_hash` 101 -- the state's
  initialization and the three finalization rounds --, the Int's decimal
  text 70, the walk 37). The experiment's tables hashed with the public
  FNV-1a, a few dozen instructions for the same input. This is the price
  of the collision resistance the table above shows, and of the brief's
  rule that placement uses the keyed hash only; Rust's `std` pays it too,
  in 106 instructions for the whole hit.
* **MutableVector reads, about 175 (17 %)**: every element read of the
  index and the entry vectors is a runtime call (`rt_mv_at`, `rt_mv_len`),
  including the reads the bounds proofs settle (Compiler changes, item 3);
  the experiment's `cd` read its index, a MutableArray, inline.
* **the compiled probe and the map's own code, about 445 (42 %)**: the
  probe, the stored-hash comparison, the position and value reads' own
  logic, the calls between the map and the engine.

A presized insertion (1,486) adds the vector writes (`writable`'s
copy-on-write check 112, `rt_mv_push` 102: three pushes, one index swap,
the live count); a growing one (2,510) adds about 1,000 more for the
rebuilds, most of it in per-element vector calls: refilling the index one
push per slot (pushes and copy-on-write checks: +290) and re-placing every
entry (index reads: +150). Before the
engine built its empty index as one filled array (`fresh`), creating a
table cost a List construction per index slot: 532 instructions per
presized insertion, which the same profile found and the change removed
(2,205 to 1,486). A miss through `at` (1,932) costs about 780 more than a
`contains` miss: the declared KeyNotFound raised and handled. It cost
2,563 while `at` read position -1 and converted the IndexNotFound; it now
fails once.

**Viability (the brief's criterion).** The hash-table experiment found
ordinary Botlish tables viable at 2-6 times Rust's run time, with `lpa`
at 4.2-4.4 times Rust's `lp` on hits and 1.7-2.4 on misses. The
production table runs at 0.9-2.3 times the experiment's own tables on
lookups and insertions on this machine -- the same regime, an order of
magnitude from neither -- and at 1.6-9 times Rust's `lp`, the upper end
on small tables where the keyed hash is most of a lookup. What separates it
from `lpa` is, in order: the keyed hash (a semantic requirement), vector
reads as runtime calls, and the index refill on rebuild. The last two are
general compiler and library work, not table logic, and each is a measured
follow-up (Limitations):

* a check-free sibling of `mvat` for proven reads, and an inline vector
  read natively (as MutableArray has), would take most of the 175;
* a bulk in-place fill of a MutableVector (`resize`-like) would replace
  the per-slot pushes of a rebuild;
* writing an Int's canonical input to SipHash in one call instead of three
  (an output-identical change: the same bytes) would shorten the hash.

### Allocations

Managed-heap objects allocated natively (`native::allocationReport`,
`bench/mutable-map.tcl -allocations 1`, 4096 entries, every key kind:
`allocations.tsv`), per operation beyond the build's own:

| operation | Int | String | struct | nested |
|---|---:|---:|---:|---:|
| `at` hit, `at` miss, `contains` hit and miss, replacing `set` | 0 | 0 | 0 | 0 |
| MutableSet `contains` hit and miss | 0 | 0 | 0 | 0 |
| a loop over the map (per loop, any length) | 1 | 1 | 1 | 1 |
| mixed (80 % `at`, 10 % `set`, 10 % `remove`), per 10,000 operations | 0.5 | 0.55 | 0.55 | 0.7 |
| churn, per 10,000 insertion-removal pairs | 4.9 | 5.0 | 5.0 | 5.1 |
| a build, growing or presized, per table | 12 | 12 | 12 | 12 |

* A lookup, a miss (handled) and a replacement allocate nothing; neither
  does an iteration step. A loop's one object is the List it yields, as
  for every loop: `loop e in m: continue` allocates one object over a map
  of 1000 entries, as `loop x in xs: continue` does over a List (the
  snapshot shares the map's vectors and allocates nothing).
* A table is 12 objects whatever its size: the map and table structs, the
  vectors' headers, the live count. Growth reallocates the vectors'
  backings (amortized doubling inside each vector, which the report does
  not count as objects) and allocates no new object; `with_capacity` sizes
  the index in one filled array, and the entry vectors still grow by
  doubling (MutableVector has no reserve: Limitations).
* The few allocations of mixed and churn workloads are the rebuilds'
  compaction counters (a one-cell MutableArray per compaction pass), one
  rebuild per several thousand operations.

### The Tcl backends

The same operations on the reference interpreter and the Tcl compiler, an
insertion or a hit (`T(2N) - T(N)` over whole runs, a few hundred Int
keys): about 5.3 ms per operation on interp and 0.33 ms on compile, where
the native backends take 50-300 ns. Every engine helper is an interpreted
or compiled Tcl call there; the collections are correct on them (every
test and golden case runs on both), not fast.

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
   tests, 43 golden cases (with the index proofs'), 5 mutants; the map's and
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
   (Performance, "Where the instructions go"). Evidence: 14 Tcl tests (6 proven, 7 unproven, and a sweep
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

Run for this report, on the final tree (Linux x86-64, the 4-vCPU container):

* **The new tests**: `tests/mutable-map.test` (28), `mutable-set.test` (12),
  `collection-iteration.test` (15), `ordered-table.test` (10),
  `place-parameters.test` (28) and `vector-bounds.test` (14): 107 tests,
  every one passing, and every one again under
  `BOTLISH_NATIVE_GC_STRESS=1`. Their golden suites, `mutable-map.bot` (27),
  `mutable-set.bot` (10), `collection-iteration.bot` (10) and
  `place-parameters.bot` (43), pass on interp, compile, cranelift-generic
  and cranelift, and `audit/golden/tools/perturb.tcl` makes all 90 fail as
  required under both perturbations (an inverted library and altered
  expectations). The census and fragments classify the 107 Tcl tests
  (68 MIGRATE, 24 KEEP-INTERNAL, 8 SPLIT, 3 KEEP-MULTI-PROGRAM, 2
  KEEP-RUNTIME-ONLY, 2 KEEP-PARSER), and `audit/golden/migration/merge.tcl
  -check 1` finds no problem in the regenerated manifest.
* **The oracle and the fuzzer**: `oracle.py selftest`, and the fuzz runs
  above (0 disagreements, GC stress included).
* **Mutants**: this milestone's 57 (next section) and, for the code the
  milestone changed under other harnesses, the 16 existing mutants
  rewritten against it -- 9 of the bounds-proof harness, 4 of the
  MutableVector one, 1 each of the MutableArray, static-decision and
  Hashable ones -- all killed; and the whole Hashable harness (45 of 45
  killed) and the whole trait-constrained-type harness (43 of 43), which
  the brief asks to stay killed.
* **The gates**: the warning gate (`audit/refactor/tools/gate.tcl`: the
  three modules warning-clean; the manifest lists the two modules that
  import the internal engine as unloadable alone), `tools/compilerpedia.tcl
  check` (the generated reference regenerated; the new topics' examples
  compile and run), the standard-library census regenerated.
* **The whole suite** (`tclsh9.0 tests/local.tcl`, after merging main's
  coroutine fusion into the branch, the native backend rebuilt): every Tcl
  test file on interp (7,000 passed, 0 failed, 90 skipped by constraint)
  and compile (6,995 passed, 0 failed, 95 skipped), the 2,250 golden
  duplicates skipped as the local run does, and all 108 golden suites on
  the four backends (interp 5,180, compile 5,180, cranelift-generic 5,088,
  cranelift 5,190 tests passed, 0 failed); 53 minutes with 4 jobs. The
  native crate's unit tests: 296 passed.

CI (GitHub Actions, on the branch `claude/great-darwin-2ba672`):

* `static-decisions.yml` (every golden suite's static decisions under the
  batched and the sequential scheduler, the four new suites included):
  **passed** on a812dade, the state before the engine's last two changes
  and the merge of main; dispatched again on the final commit, pending.
* `tests-arm64.yml` (Linux AArch64: the Tcl suite on interp and compile,
  its native coverage, the golden suites, the Rust tests, GC stress):
  **passed** on a812dade; dispatched again on the final commit, pending.
* `tests.yml` (Linux x86-64, the whole suite with the golden duplicates,
  native coverage, the warning gate, stub-linked executables) and the
  macOS arm64 and Windows x86-64 workflows (which every push starts and
  the next push cancels): pending on the final commit. The macOS acceptance
  tier of an earlier commit (6c55215a) failed on three checks this
  milestone's own changes broke -- `compilerpedia.test` (new topics'
  summaries over the length limit and aliases another topic already
  claimed), `mutable-array-type.test` (the typed
  MutableArray fence did not admit the engine) and `warning-gate.test`
  (the new modules not yet in the gate's manifest) -- fixed in a812dade.

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
* **`remove` of a missing key raises twice.** It reads the value at the
  missing key's position (-1), whose IndexNotFound it turns into
  KeyNotFound. `at` fails once instead, by guarding the position and
  reading the value by a proven read; `remove` cannot, because the same
  function compacts the values (a place call that resizes them), so no
  read of them in it is stable for the bounds proof, and a second `fail`
  site would be SAME-FAILURE. The second raise cost `at` about 630
  instructions a miss (2,563 against 1,932) before `at` was changed.
* **General performance follow-ups** (Performance, "Where the instructions
  go"): MutableVector reads are runtime calls even where proven, the
  rebuild refills the index one push per slot (no bulk vector fill), an
  Int's canonical input reaches SipHash in three writes, and a declared
  failure raised and handled costs about 780 instructions natively. None is
  table logic, and none was changed here: each is a change to MutableVector,
  native lowering or the keyed hash's runtime, with its own harnesses.
* **The reference interpreter is slow on these collections**: about 5 ms
  per operation (an insertion or a hit, every engine helper interpreted),
  against 0.33 ms on the Tcl compiler and 50-300 ns natively (measured on
  maps of a few hundred Int keys). The fuzzer runs the interpreter on a
  third of its programs.
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

