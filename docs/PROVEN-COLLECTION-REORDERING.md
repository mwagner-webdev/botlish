# Proven collection reordering

## Result

`std::mutable_map::MutableMap` and `std::mutable_set::MutableSet` have an
explicit, programmer-chosen iteration order. Three operations on each
collection are written in ordinary Botlish over the shared engine
`std::ordered_table`:

* `m.order()` returns the collection's current order.
* `m.validate_order(candidate)` checks an arbitrary candidate order once.
* `m.reorder(order)` installs an order.

An order is an insertion-ordered MutableSet holding exactly the
collection's members. The compiler admits a reorder only where it knows
that fact. The fact relates two particular values; it is not a type.

* **Insertion order is the default history of a map, not an immutable
  prison.** A reorder changes traversal metadata, never the mapping. Every
  key keeps its stored key, its value and its stored keyed hash. The
  length, the membership and every lookup are unchanged.
* **An order is valid only when it is a permutation of the collection's
  actual members**, and the compiler must know it at the call. The fact
  is SameMembers(order, m), which neither value's type states.
  `hir/relations.tcl` proves it flow-sensitively from the operations'
  declared relational contracts. Anywhere else the call is the static
  error REORDER-NOT-PROVEN.
* **A type says what values may occur; a relational fact says how these
  particular values are related.** `MutableSet[K]` admits any set of keys.
  Neither equal cardinality nor a subset is equal membership, and neither
  proves anything.
* **Validation establishes knowledge once; proven operations consume it
  without checking again.** `order()` and `validate_order` mint the fact.
  A proven reorder runs no membership check, raises no error and computes
  no keyed hash.
* **Membership-changing mutation invalidates the relation. Order-only
  mutation does not.** A set, remove or clear of either value loses the
  fact. Reads, copies and reorders keep it.
* **The hidden hash chooses buckets; the programmer may choose the
  iteration order.** A reorder finds each entry by the order's stored hash
  and Botlish equality. Its result is the same under every hidden key.
* **Cost.** A reorder is a structural O(n) operation: an arrangement by
  probes, then one pass that moves the entries and rebuilds the index from
  the stored hashes. Its managed allocations do not depend on the size,
  and it computes no table hash (Performance).

Nothing below HIR knows any of this. There is no runtime map or set, no
NIR instruction, no native and no runtime ownership or relation state. The
compiler change is one analysis plus the diagnostic it reports, and the
relation never reaches code: a proven program's NIR is the program's
ordinary NIR.

The evidence:

* Tcl tests: tests/collection-reorder.test (36 tests) and seven new tests
  in tests/ordered-table.test.
* A golden suite, tests/golden/collection-reorder.bot (77 cases on all
  four backends).
* The extended collection oracle and stateful fuzzer, with reorders on by
  default.
* A relational-proof fuzzer with an independent model of the rules.
* 45 mutants of reorder semantics, proof soundness and value semantics.
* A benchmark at 16 to 262144 keys.
* The regression and GC-stress runs listed under Regression and CI.

## Semantics

A MutableMap is its associations plus an order, which is a permutation of
its keys. A MutableSet is its membership plus an order of its elements.
Content identity (which keys map to which values) and order are separate
properties. A reorder changes only the order.

| | `m.reorder(order)` changes | keeps |
|---|---|---|
| map | the iteration order, to exactly ORDER's | every association; each key's *stored* key (the one first set, not an equal key of ORDER); each value; each stored keyed hash; the length; the result of every `contains`, `at` and `length` |
| set | the iteration order, to exactly ORDER's | the membership; each stored element; the length |

What a reorder does not change:

* **Default behaviour.** It is an explicit operation and changes none of
  the existing rules (`cr-later-operations`, golden
  `cr-later-operations-*`):
  - A new key is appended after the current last entry.
  - Setting an existing key keeps its place, which is its new place after
    a reorder.
  - Remove then set appends the key.
  - A duplicate add to a set does not move the element.
  - Growth and compaction keep the order.
  - `clear` starts a new order.
* **Iteration snapshots.** A loop over a collection that the loop body
  reorders still iterates the collection as it was when the loop began.
  The next loop sees the new order (`cr-iteration-snapshot`).
* **Value semantics.** A copy is an independent value: reordering one
  copy never reorders another (`cr-copies-independent`,
  `cr-copy-then-reorder-then-mutate`). `s.reorder(s)` reorders a set by
  its own value as it was read, which is a no-op (`cr-observer-overlap`).
* **The empty and singleton cases.** An empty collection is reordered by
  the empty order, and a singleton by itself. Reordering to the current
  order changes nothing observable (`cr-empty-and-singleton`,
  `cr-current-order`).

## API

| `std::mutable_map` | |
|---|---|
| `order(m) -> std::mutable_set::MutableSet[K]` | M's keys in M's order: a set of exactly M's keys, which the compiler knows (it mints the relation). O(1): the set shares M's table, and the first write to either copies. |
| `validate_order(m, candidate) -> std::mutable_set::MutableSet[K] errors OrderMismatch` | CANDIDATE unchanged, after one check that it holds exactly M's keys, in any order (it mints the relation). Otherwise the declared error `std::mutable_map::OrderMismatch`. M is not reordered. O(n) probes with the candidate's stored hashes; no key is hashed. |
| `reorder(place m, order: std::mutable_set::MutableSet[K]) -> unit` | M's entries in ORDER's order. It requires SameMembers(ORDER, M) at the call and declares no error. |

| `std::mutable_set` | |
|---|---|
| `order(s) -> MutableSet[T]` | A copy of S, which mints the relation. Any copy of S is an order of S. |
| `validate_order(s, candidate) -> MutableSet[T] errors OrderMismatch` | As for a map; the error is `std::mutable_set::OrderMismatch`. |
| `reorder(place s, order: MutableSet[T]) -> unit` | As for a map. |

```
import std::mutable_map
import std::mutable_set

m = std::mutable_map::create[str, int]()
m.set("first", 1)
m.set("second", 2)
m.set("third", 3)
wanted = std::mutable_set::create[str]()
wanted.add("third")
wanted.add("first")
wanted.add("second")
o = m.validate_order(wanted):
    on std::mutable_map::OrderMismatch:
        m.order()                 # keep the current order
m.reorder(o)
loop e in m:
    e.key                         # ["third", "first", "second"]
```

A candidate one key short, one key extra, or with one key replaced is
OrderMismatch. Both inputs are then unchanged (`cr-validate-mismatch`,
`cr-validate-changes-nothing`). The error propagates like any declared
error. Unhandled, it is UNHANDLED-ERROR (`cr-validate-propagates`).

`std::mutable_set::table_of` and `of_table` give std::mutable_map's order
operations a set's table. They are not API:

* They are `nomethod` and internal members of the standard library
  (`core::native::declareInternalMember`).
* An application that names them gets INTERNAL-NAMESPACE.
* Compilerpedia and the standard-library census leave them out
  (`cr-internal-members`).

## Relational proof

**The fact.** SameMembers(A, B) means that the members of the value A are
exactly the members of the value B. A map's members are its keys and a
set's are its elements. The fact says nothing about order: two ordered
sets with the same members may iterate differently. It says nothing about
identity: two independent copies have the same members. It belongs to
neither value's type.

**Why it is not a scalar refinement.**

* A refinement such as `List[T]{length: N}` or `DecimalRounded{...}` is a
  property of one value that its type can carry. It can be declared on a
  parameter or a result and checked at a boundary.
* SameMembers is a relation between two values. A type that carried it
  would have to name the other value (`OrderOf[m]`), which makes it a
  dependent type.
* The milestone adds no dependent type, no scalar refinement, no
  `requires`/`ensures` syntax and no theorem language. The parser and the
  type representation are unchanged. The fact exists only inside one
  analysis, for the duration of one walk.

**Representation.** The analysis gives every *place* a members token.

* A place is a binding, or a field path from a binding
  (`hir::mutvec::Path`), that holds a tracked collection. Two places or
  values with the same token have the same members.
* A value's members are an *abstract value*: a dict from a leaf path to a
  token. The leaf path is `{}` for a collection itself, and the field path
  for a collection inside a struct (followed to depth 4).
* A place's token is either explicit, the token of the value it was bound
  to, or implicit: `{v PATH STAMP}`.
* The implicit token means "PATH's value since its last change, or since
  the last change of a place that overlaps it". The stamp numbers that
  change; it is 0 when there has been none. That is how a parameter, or a
  binding nothing has changed, relates to an order taken from it.

**Where it is consumed.** A call whose contract `requires {I J}` is
admitted when two tokens are equal:

* the token of argument I as it was read (the order's), and
* the token of place argument J when the call runs, after every argument
  is evaluated (the collection's).

Otherwise the call is REORDER-NOT-PROVEN, with this message:

```
`c` is not known to hold exactly the current keys of `m`, which
std::mutable_map::reorder requires of its order (an order of the right
type may hold other keys, and equal lengths are not equal keys): take the
order from `m.order()`, or check a candidate once with
`m.validate_order(candidate)` (std::mutable_map::OrderMismatch when it does
not hold them), and change neither `m`'s keys nor the order's elements
before the call
```

* The message does not attempt a historical explanation of which change
  lost the fact. The brief allows one only where existing proof tooling
  supports it reliably, and none does.
* A static compile block reifies the diagnostic as
  `std::compiler::DiagnosticCode::ReorderNotProven`.
* Compilerpedia explains it in `error.reorder-not-proven`, with order,
  membership and content identity distinguished in
  `concept.collection-order` and the proof in `proof.same-members`.
* The diagnostic has no call `subject`, because it is an obligation of a
  call and never a reason to pick another candidate. Method decisions
  never read it (`cr-proof-method-syntax`).
* It is owned by an earlier rejection of its call or of one of its
  arguments (`hir::recovery::OwnedPositions`). An order of the wrong type
  is reported as the type error only, never restated as unproven
  (`cr-proof-no-cascade`).

**Where it runs.** `hir::relations::verify` is part of `hir::CheckOnce`,
after the iteration protocol's check. It walks only the invocations that
hold a reachable call with a `requires` contract, each once, in
evaluation order. A program with no reorder pays nothing beyond one pass
over its calls.

## Minting

Facts come from contracts, never from bodies: an implementation accident
is not an API. The contracts table is `hir::relations`'s `contracts`.
Each row is keyed by a function's declaration identity, which is the
standard-library module's own binding of the function, resolved to its
block (`Contracts`):

| function | contract |
|---|---|
| `std::mutable_map::order`, `std::mutable_set::order` | `mints 0`: the result has argument 0's members, as the call read them |
| `std::mutable_map::validate_order`, `std::mutable_set::validate_order` | `mints 0` on the call's normal completion |
| `std::mutable_map::reorder`, `std::mutable_set::reorder` | `requires {1 0}` and `preserves 0` |

* `o = m.order()` binds `o` to a value whose token is `m`'s token when
  the call ran.
* `o = m.validate_order(c)` does the same with the *validator's result*,
  never its argument. `c` stays unrelated (`cr-proof-type-is-not-enough`).
* A handled validation is a join (Control flow). The relation holds after
  it only when the handlers also give `m`'s token: a handler that falls
  back to `m.order()` keeps it, and one that returns the candidate or a
  new set loses it (`cr-proof-joins`).
* A failed validation mints nothing, because its error completion is the
  handler's path.
* A copy of a proven order is proven. For a set, a copy of the set is its
  order, so `s.reorder(s)` and `t = s; t.reorder(s)` are proven.

## Invalidation

Membership-changing operations lose the relation; order-only operations
and reads keep it (`cr-proof-membership-changes`,
`cr-proof-order-only-and-reads-preserve`):

| operation on the collection `m` or the order `o` | members | relation |
|---|---|---|
| `m.set(k, v)` (a new or an existing key) | may change | **lost**. The analysis does not know whether k is present, and a place argument may change anything. |
| `m.remove(k)`, `m.clear()` | may change | **lost** |
| `o.add(x)`, `o.remove(x)`, `o.clear()` | may change | **lost** |
| any call given `m`, `o` or a struct holding one as a place argument (`place` parameter) | may change | **lost**. Also for a field: `b.m` changed loses `b.m` and `b`'s other leaves are kept only when no path overlaps. |
| `m.reorder(o)`, `o.reorder(p)` | unchanged | **kept**: the contract's `preserves 0` |
| `m.length()`, `m.empty?()`, `m.contains(k)`, `m.at(k)`, a loop over `m` or `o` | read | kept |
| `m.validate_order(c)`, `m.order()` | read | kept |
| a function given `m` or `o` by value | a copy | kept |
| `n = m`, `p = o`, a struct field or literal | a copy | the copy has the original's token until either changes |
| any call that may change the installed context (`hir::cardinality::ContextSite`) | for a context member | **lost** for every place rooted at a context parameter, including at a call that only reads the context |
| a call returning a collection (not a contract's) | unknown | a fresh token: nothing crosses a function boundary but by a contract |

**Reorder preserves the relation.**

* `preserves 0` exempts the reordered place from the call's invalidation.
* `m.reorder(o)` followed by `m.reorder(o)` is proven, and so is
  reordering the order itself (`o.reorder(p)` with `p` an order of `o`)
  before `m.reorder(o)`.
* The relation-lost-after-reorder mutant (`reorder-loses-relation`) dies
  in `cr-proof-order-only-and-reads-preserve`.

**Future operations** fit the same table without a new mechanism:

* `reverse`, `sort` or `rotate` of an order would be rows that
  `preserve 0`.
* A `filter` would have no row. It would be an ordinary call whose result
  is unknown, and whose place argument (if it took one) would be killed.
* add and remove are place calls already.

## Copies and aliases

Facts track value versions, never variable names:

* A copy has its source's members until either changes. Changing the copy
  gives the copy's place a fresh stamp and leaves the original's relation
  intact. The reverse also holds (`cr-proof-copies`).
* The relation is tied to the value form. `o = m.order()` followed by
  `m2 = m` and `m2.reorder(o)` is proven, because `m2` has `m`'s token.
  After `m.set(...)`, `m2.reorder(o)` is still proven while
  `m.reorder(o)` is not.
* A relation never transfers between independent values. Two maps built
  alike have different tokens. A parameter, an element read from a List,
  a capture and a helper's result are unrelated
  (`cr-proof-type-is-not-enough`, `cr-proof-function-boundary`).
* Overlapping places are invalidated together. Changing `b` kills `b.m`
  and `b.o`, and changing `b.m` kills `b` as a whole value
  (`hir::relations::Overlap`: one place's path is a prefix of the
  other's).
* The runtime side of aliasing is the collections' ordinary value
  semantics:
  - A reorder rewrites its own place's vectors.
  - A shared vector is copied before its first write: MutableVector's
    logical copies, `hir::mutvec::Elaborate`.
  - An observer bound from the place before the reorder keeps the old
    order.
  - A loop iterates its snapshot.

  These are the existing place and copy-on-write rules (PLACE-PARAMETERS.md,
  MUTABLE-VECTOR.md). The reorder adds no new aliasing, and the
  value-semantics mutants below mutate exactly those seams.

## Control flow

Nothing is optimistic. A relation survives a join exactly when it holds
on every completing incoming path, for the same value forms
(`cr-proof-joins`, `cr-proof-loops`).

* **The join.** The paths' states are merged place by place (and the
  joined value leaf by leaf) by the pair of tokens each had on the two
  paths:
  - A place whose two tokens are equal keeps that token.
  - Places whose pairs are equal share one new token.
  - Every other place gets a token of its own.

  Two places, or a place and the joined value, therefore share a token
  after the join exactly when they shared one on each path. A place whose
  last change differs between the paths gets a new stamp, and its
  implicit token stands for its pair (`hir::relations::JoinState`,
  `JoinToken`). This is the join of two partitions into equal-members
  classes. It keeps what every path proves, however each path proved it,
  and nothing a path does not prove.
* **`if`.** Both branches are walked from the state before the `if`. A
  condition the type checker has decided (`hir::types::KnownOutcome`)
  walks only its live branch. The cases of `cr-proof-joins`:

  | form | verdict |
  |---|---|
  | `o = if b: m.order() else: m.validate_order(c)` with a handler falling back to `m.order()` | proven: every path gives `m`'s token |
  | `o = if b: (m.set(5, 5); m.order()) else: m.order()` | proven: on each path `o` and `m` agree, through different tokens |
  | `o = if b: m.order() else: n.order()`, then `m.reorder(o)` | REORDER-NOT-PROVEN |
  | the same with `m.set(5, 5)` before `m.order()` in the first branch | REORDER-NOT-PROVEN: one path relates `o` to `m`, the other to `n` |
  | `o = if b: m.order() else: set_of([1])` | REORDER-NOT-PROVEN |
  | `o = m.order()`, then `if b: m.set(5, 5)` (one branch), or a set in both branches | REORDER-NOT-PROVEN |
  | `o = m.order()`, then `if false: m.set(5, 5)` | proven: the dead branch is not walked |

* **Paths that do not complete** contribute nothing: `return`, `fail`,
  `break`, `continue` and unreachable statements. The early-return
  narrowing analogue: `o = m.order()`, then `if b: m.set(5, 5); return`,
  then `m.reorder(o)`, is proven.
* **Handlers.** A handled call is a join of its normal completion and each
  handler body:
  - A handler is entered with every place that the handled call (and its
    arguments) may change already given a new stamp.
  - A handler that falls back to `m.order()` keeps the relation, also
    after changing `m` first.
  - A handler that falls back to the candidate loses it, and so does a
    handled call that changes `m`.
* **Loops.**
  - Every place written anywhere in a loop's body is given a new stamp on
    entry. A value of one iteration survives into the next only through a
    place.
  - The body is walked once, and those places are given new stamps again
    after the loop.
  - A loop that changes `m`, anywhere in its body, loses the relation in
    the body and after the loop. One that does not keeps it.
  - An order taken inside the body is proven there.
  - A `loop` value is the join of its `break` values.

## Implementation

The reorder is ordinary Botlish in `std::ordered_table`
(stdlib/ordered_table.bot, "Membership and order"), shared by both
collections. A map adds one call for its values:

```
fn reorder(place m: MutableMap[K, V], order: std::mutable_set::MutableSet[K]) -> unit:
    perm = m.table.arrangement(std::mutable_set::table_of(order))
    m.table.permute_values(perm, m.vals)
    m.table.permute(perm)

fn reorder(place s: MutableSet[T], order: MutableSet[T]) -> unit:
    perm = s.table.arrangement(order.table)
    s.table.permute(perm)
```

* **`arrangement(t, c)`** builds a `MutableArray[int]` of length
  `t.length()`. Rank i holds the position of T's entry whose key equals
  C's live entry of rank i.
  - C's entries are walked in order, dead ones skipped.
  - Each is located by `t.slot_of(h, key)`, which probes T's index from
    the home slot of C's stored hash h and compares a key only at an entry
    whose stored hash equals h (`holds?`). Equality, not the hash, decides
    identity.
  - Expected O(n) probes; no key is hashed.
* **Totality (`complete`).** An order key T lacks is skipped. T's entries
  that C does not name follow in their own order.
  - When C holds exactly T's keys, as a proven reorder's order does, there
    are neither, and the cost is one comparison (`n < t.length()`).
  - When it does not, the program was compiled despite its
    REORDER-NOT-PROVEN, in a lenient (`-strict 0`) build such as the
    compiler service's. The reorder then still changes no content: every
    entry is kept with its value (`cr-unproven-run-keeps-content`).
  - This was found during the milestone. Before `complete`, such a run
    dropped the unnamed entries (a map of three keys reordered by `{3}`
    became empty).
* **`permute_values(t, perm, place values)`** rebuilds a map's value
  vector in PERM's order. It shares the old vector (a logical copy), clears
  the place, and pushes `old[perm[i]]` for every live `perm[i]`. It is
  called before `permute`, so liveness is read from the table as it was.
* **`permute(place t, perm)`** rebuilds the table:
  - It shares the old hash and key vectors and clears them in place.
  - It pushes `(hashes[p], keys[p])` for `p = perm[i]`, skipping dead
    positions.
  - It sets the live count to the number of entries pushed.
  - It rebuilds the index at its current slot count (`reindex`, the
    second half of the existing `rebuild`, extracted for this). The index
    is filled from the stored hashes with `place_entry`.
* **Validation.** `same_members?(t, c)` is
  `t.length() == c.length() and t.count_shared(c) == c.length()`.
  `count_shared` counts C's live entries found in T by C's stored hash and
  equality.
  - C's keys are distinct, being a table's, so equal counts mean the same
    members.
  - Expected O(n), with no hashing. A failed validation raises after the
    count, having written nothing (both arguments are parameters, which
    are copies).

**Complexity.** Each step is linear, so there is no O(n²) path:

| step | cost |
|---|---|
| order | O(1) |
| validate_order | expected O(n) |
| arrangement | expected O(n) |
| complete, when called | O(positions) |
| permute | O(n) entries plus O(slots) for the index |

The O(slots) term is the one cost not proportional to the live entries:
a reserved index is rebuilt at its reserved size (Dead entries and
capacity). The benchmark checks linearity from 16 to 262144 keys
(Performance).

## Stored keys, values and hashes

They stay aligned, by construction:

* **Keys and hashes move together.** `permute` pushes `hashes[p]` and
  `keys[p]` for the same p in the same iteration, so a stored hash is
  still its own key's.
* **The table's invariant holds unchanged.** That invariant is
  `hashes[i] == table_hash(keys[i])` for every live position i. No key
  is replaced by an equal key of the order: the order's keys are only
  probed with, never stored (`cr-map-string-keys` reorders by
  independently built equal Strings).
* **Values move with their keys.** `permute_values` visits the same
  `perm[i]` sequence and skips exactly the positions `permute` skips:
  `live_at?(p)`, which reads `hashes[p] >= 0` on the table before
  `permute` runs. So `vals[i]` is `keys[i]`'s value for every i
  (`cr-map-values-aligned`, the oracle's associations, mutant
  `reorder-values-misaligned`).
* **The index is consistent.** It is rebuilt from the moved stored
  hashes. `tests/ordered-table.test`'s invariant checker verifies after
  every operation of a random history with reorders that:
  - every live entry is found by its own key;
  - every index slot points at a live position;
  - the live count is right;
  - every stored hash is the table hash of its key
    (`ot-reorder-invariants-*`).
* **No hash is recomputed.** Natively, the NIR of `order`, `reorder`,
  `arrangement`, `permute` and `validate_order` has no `tablehash`
  operation (`cr-no-rehash`). On the Tcl compiler's backend a build with
  two reorders calls `core::hashing::tableHash` exactly as often as the
  same build without them (`ot-reorder-hashes-not-recomputed`). The
  benchmark's table-hash column is 0 for every reorder mode.
* **The reorder checks nothing.** `cr-reorder-checks-nothing` walks every
  function `reorder` reaches: none counts shared members or validates,
  and `reorder` declares no error.

## Dead entries and capacity

* **Dead entries.** A reorder drops the table's dead entries, which is a
  compaction: after it, positions equal the live count. It keeps the
  index's slot count, so a reservation survives. The case
  `ot-reorder-drops-dead-keeps-slots` reports slots, positions and live
  entries:
  - 64 slots, 40 positions, 32 live before the reorder; 64, 32, 32 after.
  - A `with_capacity` map keeps its 256 slots, and the reserved
    insertions after the reorder do not rebuild.
* **Dead entries of the order** are skipped. An order from `m.order()`
  after removals shares the map's table, dead entries included.
* **Why the slot count is kept.**
  - The reorder neither adds nor removes members, so the load after it is
    at most the load before, and no growth is due.
  - Shrinking the index is the garbage rule's decision, made on removal,
    and `with_capacity` is a request the program made.
  - A reorder that resized the index would make the cost and the next
    growth depend on the reorder's history. The mutant that resizes
    (`reorder-shrinks-index`) dies in the reservation test.
* **The cost of keeping it** is an O(slots) index refill, measured in
  `reorder-reserved` (Performance).

## Hidden-key independence

The hidden table-hash key chooses where an entry lives in the index, and
never its position in the order. The evidence:

* `cr-hidden-key-independent` runs the same reorders under two fixed
  hidden keys and the process's own, on the Tcl compiler's backend and
  natively. Every observation is identical.
* `ot-reorder-invariants-hidden-keys`: under each of two fixed keys, the
  representation's invariants hold after every operation of a random
  history with reorders, and every observation is the model's.
* The stateful fuzzer runs every program under two fixed hidden keys on
  every compiled backend (`-keyed 1`, the default). Its reorders and
  validations must give exactly the model's observations, and the model
  never hashes.
* `kcollide` keys are genuine collisions of the table's own hash under the
  key `{1 2}`, all on one home slot. Reordering a probe cluster of them
  finds every entry by equality (`ot-reorder-keyed-collisions`, and the
  fuzzer's `kcollide` key kind).
* With full stored-hash collisions, every element's stored hash is equal
  in a private library whose table hash keeps two bits.
  `cr-full-hash-collisions` shows that the reorder still moves every
  entry to its own key's rank with its own value: equality decides.
* The planted bucket-order mutant (`reorder-bucket-order`) arranges by
  walking the index's slots, which is the hidden hash's placement, instead
  of the order. It dies in the ordinary reorder tests.

## Oracle and fuzzing

**The oracle.** `audit/mutable-map/tools/oracle.py` models a map as
associations plus an ordered list of keys, and a set as membership plus an
ordered list. It never hashes, and it models semantics, never the proof.

* Each reorder operation takes a candidate built from the current order by
  one of seven modes: rotate, reflect, evens then odds, one key short, one
  key absent added, one key replaced, or a seeded Fisher-Yates shuffle.
* The oracle independently decides membership. For a valid candidate it
  replaces only the ordered list. An invalid one is a mismatch, and
  nothing changes.
* `reorder-same` reorders by `order()`. `reorder-via-order` reorders the
  order first. `reloop` reorders inside a loop over the collection, whose
  snapshot the model keeps.
* `python3 -I audit/mutable-map/tools/oracle.py selftest` passes.

**Stateful fuzzing.** `audit/mutable-map/tools/fuzz.tcl -reorders PERCENT`
(default 10) mixes these operations into the existing histories:

* the operations: growth, removal, compaction, clear and refill, copies,
  and mutation during iteration;
* every key kind: int, str, enum, struct, nested, list, the public hash's
  collision corpus and the table hash's own collisions;
* every value kind;
* maps and sets alike;
* every compiled backend, under two fixed hidden keys;
* GC stress with `-gc-stress 1`.

| run | programs | operations | observations | result |
|---|---:|---:|---:|---|
@@FUZZ@@

**The proof fuzzer.** `audit/collection-reorder/tools/proofs.tcl` checks
the compiler's admission decisions.

* **What it generates.** Each program is one function body of random
  statements:
  - orders taken, validated (with handlers that return, fall back, or
    change the map first), copied, built by a helper, and chosen by `if`;
  - map copies, and boxes (structs) holding maps and orders, and their
    copies;
  - membership changes, including place calls over a map or a box;
  - reads, value calls and loops;
  - `if`s and early returns;
  - reorder sites of maps, box fields and sets.
* **Verdict 1: the model.** For every site, the compiler's verdict must
  equal that of `proof_model.py`, an independent model written from the
  documented rules. The model reads the generator's own statement tree,
  never HIR.
* **Verdict 2: soundness.** The program runs again under twelve inputs
  with an assertion of exact membership before every admitted site. An
  admitted site whose order differs in membership is UNSOUND.
* The changes in the programs always change members (fresh keys), so the
  runs observe what the proof must rule out.

| run | programs | sites (admitted) | observations | disagreements | unsound |
|---|---:|---:|---:|---:|---:|
| `-seed 21 -n 40` | 40 | 159 (36) | 1,434 | 0 | 0 |
| `-seed 22 -n 40` | 40 | 152 (30) | 1,361 | 0 | 0 |
| `-seed 23 -n 40` | 40 | 177 (53) | 1,544 | 0 | 0 |
@@PROOFS@@

## Mutation testing

`audit/collection-reorder/tools/mutate.tcl` runs the collections' harness
(`audit/mutable-map/tools/mutate.tcl`) with its own `mutants.txt`. Each
mutant gets a private copy of the tree; a native mutant also gets a
rebuilt native backend. The detectors run in order until one kills the
mutant:

1. the mutant's own test files, then tests/collection-reorder.test,
   ordered-table.test, mutable-map.test and mutable-set.test;
2. the collection fuzzer against its model;
3. the proof fuzzer against its model and the runs.

@@MUTANTS@@

**The brief's mutants with no non-equivalent version.** The file's header
explains each:

* **"reorder replaces the stored key with the candidate's equal key".** Two
  equal Hashable keys are indistinguishable to every observation, as for
  replacement on `set`. `permute` never reads the order's keys.
* **"same length / subset implies SameMembers".** The proof reads no
  length or membership fact; only a contract mints. The family's mutants
  are therefore the validator's (`validate-length-only`,
  `validate-subset-only`), plus `any-order-admitted` for the proof.
* **"failed validation changes an input".** `validate_order` takes both
  values as ordinary parameters, which are copies, so no code in it can
  write the caller's.
* **"relation lost after a read-only operation" by a read's own
  contract.** Reads have no contract; `reads-lose-relation` is the
  analysis's version of this mutant.
* **"the order's dead entries ranked".** An order's dead entry
  (h = -1) is skipped by `arrangement`'s `h < 0` test. Without that test,
  the probe skips it: it never matches -1, since the index holds live
  positions only, and totality's `p < 0` then skips the result. The test
  is a shortcut, and its removal is equivalent. The mutant existed and
  was killed before totality made it equivalent; it was removed.
* **A handler entered without the handled call's changes.** The handled
  call's own completion carries those changes into every join.

The existing harnesses still kill their mutants. Three of
`audit/mutable-map/tools/mutants.txt`'s mutants were retargeted to the new
text, each keeping its rule:

* `compaction-stale-index` now mutates `rebuild`'s call of the extracted
  `reindex`.
* `set-value-storage` follows the new error declaration and `of_table`.
* `iteration-materializes` follows the map's new import.

@@EXISTING-MUTANTS@@

## Performance

`bench/collection-reorder.tcl` measures the native backend. It runs one
driver per key kind, sizes 16, 1024, 65536 and 262144, and the
difference of two repetition counts. Times are the best of five runs, on a
4-core container, in nanoseconds per operation. Instruction counts come
from callgrind (`-instructions 1`). Managed objects, vector shares and
detaches per operation come from `native::allocationReport`
(`-allocations 1`), and keyed-hash computations per operation are counted
on the Tcl compiler's backend (`-hash-calls 1`).

**Instructions per operation.** These come from callgrind and are exact
up to placement: the hidden key changes probe lengths by a few percent.
Validation and reorder are linear, so the cost per entry is shown in
parentheses.

| keys | n | `order()` | `validate_order`, valid | invalid | map reorder | set reorder | reorder, n/2 dead entries | reorder, `with_capacity(8n)` | reorder of a fresh copy |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Int | 16 | 781 | 9,354 (585) | 17,907 (1,119) | 37,255 (2,328) | 28,807 (1,800) | 34,911 (2,182) | 54,135 (3,383) | 43,458 (2,716) |
| Int | 1,024 | 784 | 593,390 (579) | 610,830 (597) | 1,671,647 (1,632) | 1,479,916 (1,445) | 1,607,818 (1,570) | 2,920,072 (2,852) | 1,724,057 (1,684) |
| Int | 65,536 | 1,194 | 37,822,629 (577) | 36,755,409 (561) | 106,616,140 (1,627) | 95,019,986 (1,450) | 110,735,375 (1,690) | 195,438,655 (2,982) | 111,744,216 (1,705) |
| Int | 262,144 | 1,161 | 151,134,890 (577) | 150,940,525 (576) | 421,122,362 (1,606) | 377,499,149 (1,440) | 436,366,221 (1,665) | 778,444,612 (2,970) | 440,275,853 (1,680) |
| String | 16 | 781 | 10,030 (627) | 21,146 (1,322) | 34,194 (2,137) | 30,518 (1,907) | 42,946 (2,684) | 55,336 (3,458) | 43,850 (2,741) |
| String | 1,024 | 786 | 638,179 (623) | 620,178 (606) | 1,703,588 (1,664) | 1,519,842 (1,484) | 2,001,358 (1,954) | 2,962,998 (2,894) | 1,754,597 (1,713) |
| String | 65,536 | 1,196 | 40,202,210 (613) | 39,792,548 (607) | 107,587,691 (1,642) | 97,514,880 (1,488) | 107,185,927 (1,636) | 187,865,019 (2,867) | 111,027,767 (1,694) |
| String | 262,144 | 1,145 | 159,154,316 (607) | 158,963,260 (606) | 430,523,949 (1,642) | 411,345,131 (1,569) | 444,816,446 (1,697) | 749,269,715 (2,858) | 450,608,452 (1,719) |

The cost is O(n), with no O(n²) path:

* **The cost per entry is flat.** From 1,024 to 262,144 keys, a map
  reorder costs 1,606 to 1,664 instructions per entry, and validation 576
  to 623. At 16 entries the fixed part of each operation shows (the
  arrangement's arrays, the vector shares).
* **What a reorder costs per entry:**
  - the arrangement's probe;
  - three or two pushes onto the rewritten vectors;
  - the index refill;
  - for a map, the value's move (a set reorder is 10% cheaper).

  A reorder costs about one insertion into a presized map per entry
  (1,480 to 1,520 instructions in the hot-path runs below).
* **An invalid candidate costs as much as a valid one.** The check counts
  every member before it fails. The difference at 16 entries is the error
  raised and the empty set the handler builds.
* **Dead entries add no work per entry.** The test removes and re-adds the
  last half of the keys, leaving n/2 dead entries, which the order shares.
  At 65,536 and 262,144 keys the reorder's net cost is then within 4% of a
  clean map's. The smaller sizes' net figures range from −6% to +26%;
  each is the difference of two runs whose removals and re-insertions
  cost several times the reorder (and, for String keys, their allocations
  and collections).
* **A reserved index costs O(slots).** A map made `with_capacity(8n)`
  keeps its slots (the power of two above 8n/0.7) through the reorder,
  and the refill costs about 97 instructions per extra slot: 2,970
  instead of 1,606 per entry at 262,144 Int keys. This is the
  price of keeping the reservation (Dead entries and capacity).
* **A shared map's first write costs no copy.** Reordering a fresh copy
  costs the same as reordering an unshared map (1,680 against 1,606 per
  entry). The reorder replaces each vector it rewrites, and the
  copy-on-write rule never copies one that is about to be replaced.

**Allocations, shares and detaches per operation.** These come from
`native::allocationReport`, with Int keys. The figures are the same for
String keys, apart from the keys the dead-entry mode builds.

| operation | managed objects | vector shares | detaches | backing growths, n = 16 / 1,024 / 65,536 / 262,144 |
|---|---:|---:|---:|---|
| `order()` | 1 | 0 | 0 | 0 |
| `validate_order`, valid | 1 | 0 | 0 | 0 |
| `validate_order`, invalid (error handled, empty set built) | 11 | 0 | 0 | 0 |
| map reorder | 5 | 3 | 0 | 9 / 27 / 45 / 51 |
| set reorder | 4 | 2 | 0 | 6 / 18 / 30 / 34 |
| map reorder by `m.order()` after removals (the order shares the map's table) | 13 | 7 | 0 | 13 / 37 / 61 / 69 |
| reorder of a fresh copy (`c = m`, then `c.reorder(c.order())`) | 13 | 7 | 0 | 13 / 37 / 61 / 69 |

* **The managed objects are constant in n.** For a map reorder they are
  the permutation array, its rank counter, and the logical copies of the
  hash, key and value vectors that the rewrite reads from. There is never
  a List of entries, keys or values (`cr-allocations-constant`).
* **No detaches.** A reorder never copies a vector.
* **Growths.** The vectors it rewrites start empty and grow by doubling,
  which gives about log₂ n reallocations each. MutableVector has no
  reserve, the same limitation as `with_capacity` (ORDERED-MUTABLE-MAP-SET.md,
  Limitations).

**Keyed-hash computations per operation.** These are counted as
`core::hashing::tableHash` calls on the Tcl compiler's backend, at 16 keys
of each kind, and are exact:

| `order()` | `validate_order` | reorder (map, set, reserved, shared) | reorder after removals |
|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 beyond the 16 of the removals and re-insertions themselves (the same in its base) |

**Time.** Nanoseconds per operation, natively, the best of five runs:

@@TIMES@@

**The existing operations did not regress.** `bench/mutable-map.tcl
-instructions 1` was run twice with the same compiler, once against this
standard library and once against the base revision's (`-stdlib`, the
standard library of the commit before this work):

* Int and String keys, 1,024 and 4,096 entries.
* Every hot path: build (growing and presized), hit, miss, contains hit
  and miss, replace, remove, iterate, and the set's add, hit and miss.

Over the 48 rows, the change in instructions per operation has a mean of
−0.31% and a median of −0.05%, and ranges from −5.2% to +7.4% in both
directions. That scatter is placement noise: each run draws its own hidden
hash key, which changes probe lengths. Iteration, which never probes, is
identical (280 against 280).

The native code shows that nothing else changed. A program using every
operation was compiled against both standard libraries and its NIR was
compared function by function:

* 35 of the 41 functions the hot paths use are identical.
* `at`, `remove` and `iteration_at` differ only in the numeric id of
  `KeyNotFound` (1 became 2: the new `OrderMismatch` is numbered first).
* `rebuild` calls the extracted `reindex` instead of inlining the same
  loop. That is one call per growth step.

The relation is compile-time knowledge: no proven or unproven program's
NIR holds any trace of it.


## Regression and CI

@@REGRESSION@@

## Future representation-independent equality/hash

This milestone deliberately comes before content identity. Explicit order
had to be under the programmer's control first. With it, the
three properties a value Map needs are separable:

* **Map content identity can ignore order.** A map's content is its
  associations and a set's is its membership. Reorder now demonstrates
  that order is metadata: it changes the traversal and nothing a lookup,
  a length or a membership test can see. An `==` defined on content alone
  would make `m` and `m` reordered equal, with no special case.
* **Iteration remains explicitly controllable.** Insertion order is the
  default history, `reorder` replaces it, and the order is itself a value
  (a MutableSet) that the program builds, validates and passes around. An
  equality that ignores order loses nothing a program cannot get back
  from `order()`.
* **A future immutable reorder** can therefore produce an *equal* value
  with a different traversal order. On an `ImmutableMap`, `m.reordered(o)`
  would return a new map equal to `m` under content `==`, with the same
  content hash, iterating in `o`'s order. The SameMembers relation and its
  contracts carry over unchanged: `reordered` would `require` the relation
  and `mint` it for its result.

What remains for that milestone is unchanged from ORDERED-MUTABLE-MAP-SET.md,
"Future immutable Map":

* an opaque struct's content `==` and content hash, defined by its module
  under the totality rules of the intrinsic Hashable witnesses, or an
  intrinsic `ImmutableMap` beside ImmutableSet;
* `freeze`.

None of it is here. There is no `==` and no `hash` of either collection,
no Hashable MutableMap or MutableSet, no ImmutableMap, no user-defined
content equality or hash, no change to ImmutableSet's representation, and
no freeze or thaw.

## Limitations

* **`m.set(k, v)` of a key already present loses the relation.** The
  analysis cannot tell statically whether k is present, and it never
  inspects a body. Take the order again after a batch of updates
  (`m.order()` is O(1)).
* **Relations do not cross function boundaries except by contract.** A
  helper that builds an order and returns it is unproven at its caller,
  however it is written. The only contracts are the standard library's
  six rows. There are no user-declared contracts and no `requires` or
  `ensures` syntax, by design.
* **Context members are conservative.** A place rooted at a context
  parameter is invalidated at every call that may change the installed
  context (`hir::cardinality::ContextSite`), also one that only reads it.
  Take the order after such calls.
* **Struct leaves are followed to depth 4**, and a collection inside a
  List element, a capture or a MutableVector element has no place: values
  read from them are unrelated.
* **Lenient builds.** An unproven reorder compiled with `-strict 0` runs.
  Totality keeps its content intact, but its order is then what the order
  names followed by the rest; that is no specified meaning, only a safe
  one.
* **Validation hashes nothing, but building a candidate does.** A
  MutableSet built by `add` hashes each element once. `validate_order`
  itself probes with the candidate's stored hashes.
* **A reorder of a map by its own `order()` copies the table's vectors.**
  The order shares the map's table, so the reorder's first write detaches
  every vector it rewrites. This is the copy-on-write rule at work, and it
  is counted in Performance (`reorder-shared`).
* **The O(slots) index refill**, above.

## What to run

When changing `hir/relations.tcl`, its contracts, the order operations or
the engine's `count_shared`, `same_members?`, `arrangement`, `complete`,
`permute`, `permute_values` or `reindex` (AGENTS.md, "Collection order and
relational facts"):

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/collection-reorder.test
tclsh9.0 tests/ordered-table.test
tclsh9.0 tests/mutable-map.test
tclsh9.0 tests/mutable-set.test
tclsh9.0 tests/local.tcl tests/golden/collection-reorder.bot
python3 -I audit/mutable-map/tools/oracle.py selftest
tclsh9.0 audit/mutable-map/tools/fuzz.tcl -seed S            # several seeds; -gc-stress 1 once
tclsh9.0 audit/collection-reorder/tools/proofs.tcl -seed S   # several seeds
tclsh9.0 audit/collection-reorder/tools/mutate.tcl -jobs 3   # every mutant killed
tclsh9.0 audit/mutable-map/tools/mutate.tcl -jobs 3          # for an engine change
tclsh9.0 bench/collection-reorder.tcl                        # the performance report
```

A change to the diagnostic also needs:

* `tests/static-compile.test`, which holds the census of diagnostic kinds;
* `tests/diagnostic-recovery.test`;
* `tclsh9.0 tools/compilerpedia.tcl check`.
