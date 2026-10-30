# Representation-independent value identity

## Result

An opaque immutable struct can now say what its values *mean*, apart from
how they are stored, and every operation that compares or hashes follows
it: `==`, the public `hash`, the standard library's keyed table hash, the
Hashable and Equatable witnesses, ImmutableSet membership, MutableMap keys.

```
opaque struct ImmutableMap[K satisfies Hashable, V]:
    keys: List[K]
    vals: List[V]
    hashes: List[int]
    index: List[int]
    identity associations(keys, vals)
```

* **One mechanism, two forms.** `identity members(F)` -- the elements of a
  List field, in no order -- and `identity associations(K, V)` -- the pairs
  of two List fields (the i-th key with the i-th value), in no order. Two
  values of the declaration are equal exactly when they hold the same
  entries, each as many times; both hashes are an order-independent
  combination of complete entry hashes. Every other field (an index, stored
  hashes, a note, the order the entries happen to be in) is representation:
  nothing that compares or hashes reads it.
* **No user code runs.** An identity is a declaration the compiler and both
  runtimes interpret by one rule, not an `==` or `hash` function. Coherence
  (`a == b` implies equal public and equal keyed hashes) follows from that
  rule by construction, for every declaration, whoever writes it.
* **Owner-only, one per type, immutable only.** The clause is part of an
  opaque struct's declaration: only its module writes it, a type has at most
  one, no other module or import can change it, and a struct that declares
  one may hold no MutableVector, MutableArray, C pointer, native view or
  affine value.
* **Integrated with Hashable, not beside it.** The totality analysis
  (`hir::types::Totality`, so HashClass, IsHashable and IsEqualityTotal)
  reads an identity struct's identity elements instead of its fields:
  `ImmutableMap[str, int]` is Hashable, `ImmutableMap[str, MutableVector[int]]`
  neither Equatable nor Hashable, decided per application. `==` and `hash`
  of an admitted value lower to the total operations (`veqtotal`,
  `hashtotal`, `tablehashtotal`) with no EQUALITY edge, recursively through
  fields and elements, because those lowerings already ask that predicate.
* **Equatable landed** as a second intrinsic trait, with no operation:
  total equality. Hashable refines it.
* **`std::immutable_map::ImmutableMap[K satisfies Hashable, V]`** is
  ordinary Botlish over the ordered table frozen into Lists: `freeze` from
  a MutableMap (O(n), order and associations exact), O(1) expected lookups
  through the frozen index of stored keyed hashes, iteration in its frozen
  order, `order`, `validate_order` and `reordered` on the existing
  SameMembers contracts, and `==`/`hash` by associations. It is Hashable
  when V is: a map can be a key of a MutableMap, of a MutableSet, of an
  ImmutableSet, of another ImmutableMap.
* **ImmutableSet stays intrinsic**, for three precise API blockers
  (section "ImmutableSet"); its construction and equality now match by hash
  (expected O(n) instead of O(n^2)), its public hash is unchanged, and
  `MutableSet.freeze` builds one.
* **Application authors may define representation-independent identity**
  for their own opaque immutable types, with the same two forms and the
  same guarantees as the standard library (section "Trust boundary").

Design laws, as the milestone states them and as this implementation keeps
them:

* A value's representation is how it is stored; its identity is what it
  means.
* Iteration order may be observable without being part of value identity.
  `m.reordered(o) == m` and `hash(m.reordered(o)) == hash(m)`, while the two
  loops visit the keys differently.
* Equal values hash equally under both the deterministic and the keyed
  hash; neither hashes irrelevant representation.
* Hashable remains a trustworthy semantic capability, not an operator
  overloading hook; mutable values never become Hashable.

## Starting problem

`==` of a struct compared every field slot by slot, and its hash folded
every field (STRUCTS.md; HASHABLE-AND-KEYED-HASH.md). That is right for a
record, and wrong for a value whose representation holds machinery. A
frozen ordered hash table holds index slots, stored keyed hashes, a slot
count chosen by its growth history and the entries in insertion order; its
meaning is only its associations. Two such maps built in different orders,
or with a removal and a reinsertion, or under different hidden hash keys,
are the same map and would compare unequal. ORDERED-MUTABLE-MAP-SET.md
("Future immutable Map") and PROVEN-COLLECTION-REORDERING.md ("Future
representation-independent equality/hash") recorded exactly this as the
blocker of an ordinary Botlish ImmutableMap: order had been separated from
content (reorder), but the language could not state content equality for a
user type. ImmutableSet had the same need and met it as a runtime kind
whose `==` and `hash` the runtimes define by membership.

## Architecture census

### Where equality and hashing were selected

Every place that decided what `==` or a hash means, before this milestone:

| Selected by | Place | What it decided |
|---|---|---|
| runtime kind | `core::value::equal` (Tcl), ops.rs `equal` (native) | structural equality per kind; refusal of `core::value::incomparable` kinds (EQUALITY) |
| runtime kind | `core::hashing::Encode` (Tcl), ops.rs `walk` over a `CanonicalSink` (native) | the canonical input of both folds per kind; refusal of `core::hashing::unhashable` kinds |
| runtime kind | `immutableSet` cases of the four above | membership equality; XOR of member hashes |
| opaque representation | the opaque-struct cases of `equal` (both runtimes) | representation equality, with a refusal that names the opaque values, never the fields |
| intrinsic value kind | `core::immutableset` Dedup/contains, ops.rs `setfromlist`/`setcontains` | deduplication and membership by the generic equality |
| compiler witness | `hir::types::Totality` -> `HashClass`, `IsHashable`, `IsEqualityTotal`; Hashable's intrinsic row in `hir::traits` | which types are Hashable / equality-total, field by field |
| compiler lowering | native/lower.tcl's `NativeCallOp` (`==` -> `veqtotal`; `hash`, `std::table_hash::of` -> `hashtotal`, `tablehashtotal`; set ops) | the total, error-free operations, by those predicates |
| compiler lowering | the Tcl compiler's `IntrinsicValueEqual` | inline scalar comparison, else `core::value::equal` |
| compile-time values | `hir::exact` (exact values of constants) | `core::value::equal` on canonical values |
| admission | `hir::range::VerifyHashing`, the checked `hash` | TRAIT-NOT-SATISFIED for a statically unhashable argument |
| DecimalRounded | `hir::decimal::Mentions` | refuses `==` of a type mentioning a DecimalRounded |

There was no registry and no dispatch beyond the kind switch: the
witnesses came from one totality walk over types, and every runtime
decision from one kind switch per runtime. The milestone keeps exactly that
shape. It adds one case to each switch (a struct whose shape has an
identity) and one case to the totality walk (a struct type whose
declaration has an identity), and nothing else selects behavior: the
lowering, the exact values, the Tcl compiler, admission and the set
operations follow automatically, because they already ask those
predicates and call those runtime functions.

### Alternatives

Each design was weighed by ordinary Botlish expressibility, soundness,
totality, Hashable coherence, module ownership, compiler and runtime
complexity, future user extensibility and the ability to migrate a
representation without changing clients.

* **A. Owner-defined `equal`/`hash` functions recognized by the compiler.**
  The owner writes two Botlish functions; the compiler checks their shape
  and effects and supplies the witnesses. Expressive, but the coherence law
  becomes a promise about arbitrary code: nothing proves that the owner's
  hash agrees with the owner's equality, and the keyed table hash would
  need a third function or a keyed mix of the public one (which the
  Hashable milestone rejected). Equality runs inside the runtimes' own
  equality (a List of maps compared by the native `equal`), so a Botlish
  callback would have to run from inside a runtime helper that today is not
  a safepoint and runs no Botlish code: a GC, re-entrancy and error-path
  change to both runtimes, plus a purity analysis Botlish does not have
  (`-context-free`, no I/O, no yield, no failure, no hidden state).
  Rejected: largest change, weakest guarantee.
* **B. Ordinary functions plus a narrow compiler/stdlib registration.**
  The same callback problem as A, with the trust moved to a registration
  table. It restricts authority to the standard library but does not make
  the law hold; it only names who is trusted to keep it. Rejected for the
  same runtime reasons.
* **C. Intrinsic witnesses whose implementation calls owner functions.**
  Same as B from the runtimes' side.
* **D. Keep collections intrinsic** (the control): an `ImmutableMap`
  runtime kind beside ImmutableSet, with membership-style `==` and `hash` in
  both runtimes. Sound and fast, but a second runtime collection (its
  table, lookup, iteration, freeze and GC tracing in Tcl and Rust), no
  ordinary Botlish, and nothing general: the next value with a
  representation would need another kind.
* **E (chosen): restricted declarative identity forms.** The brief's own
  section 13: equality and hash expressed through restricted semantic
  combinators whose coherence follows compositionally. The owner names
  which List fields carry the meaning and how (members or associations);
  the runtimes implement each form once, equality and both hashes from the
  same entries, so coherence holds for every declaration by construction.
  No Botlish code runs inside equality or hashing, so nothing changes about
  safepoints, purity or errors; totality is the ordinary walk over the
  identity's element types; the representation is ordinary Botlish and can
  change (add an index, drop the stored hashes) without changing a client
  or a hash. Two forms cover every collection the census found (a set, a
  multiset, a map, an association list, a JSON object); a third, if ever
  needed (an ordered sequence of one field is already a List field of an
  ordinary struct), is a row of `hir::structs::identityForms` and one case
  per encoder.

Why E over a theorem language: it is not one. It names no predicate, proves
nothing about owner code and needs no effect system, because the meaning it
gives is the language's own (multiset equality of entries the language
compares) and the representation is never consulted.

## Trust boundary

Who may define semantic equality and hash, and why each guarantee holds:

| Property | How it holds |
|---|---|
| `a == b` implies `hash(a) == hash(b)` and equal keyed hashes | **proven by construction**: both hashes are a commutative sum of whole entry hashes over the multiset that equality compares, in each runtime (`core::hashing::Identity`, ops.rs `identity_walk`); pinned by the oracle and the mutants |
| equality is total for an admitted type | **compiler proof**: the totality walk over the identity's element types (TRAIT-NOT-SATISFIED otherwise); a refusal can only come from an element, never from representation |
| equality and hash are stable | **restricted construction**: the struct is immutable (no mutable or affine component), its fields are Lists, the entries are compared by the language's own equality |
| one meaning per type, no orphan instance | **declaration**: the clause is part of the opaque declaration, at most one, resolved by declaration identity |
| only the owner constructs and reads the representation | **opaque structs** (OPAQUE-STRUCTS.md): construction and field access are the declaring module's |
| ImmutableMap's lookups agree with its equality (its hashes and index match its keys, its keys are distinct) | **trusted, privileged ownership**: the representation is built only by `freeze`, `reordered` and `empty` (and the internal member `of_parts`, which no program outside the standard library can name); a wrong index would make lookups miss, never `==` or a hash disagree |

So application authors **may** define representation-independent equality
and hashing for their own opaque immutable types after this milestone, with
the same syntax and the same guarantees as the standard library:

```
opaque struct Tags:
    items: List[str]
    rendered: str               # a cache: representation
    identity members(items)
```

What they get is exactly what the standard library gets: the forms, never
an arbitrary function. The coherence law is not a contract the author must
keep -- they cannot break it -- and the Hashable witness is still the
language's, computed from the element types. What an author must keep
consistent is only their own representation (a cache that disagrees with
the identity is a bug in their module, invisible to `==` and `hash`).
Owner-only declaration, immutable type, total and effect-free equality and
hash, one witness per type, no orphan instance and no dynamic witness
selection all hold structurally.

Multiset semantics, not set semantics, is deliberate: equality compares
the entries with their multiplicities. For an owner that keeps its members
or keys distinct (ImmutableMap, a set-like type) that is set or map
equality; for one that does not (a bag) it is still a lawful equivalence,
coherent with the sum-combined hash. No owner invariant is needed for `==`
and `hash` to agree.

## Equatable

`Equatable` landed, as an intrinsic trait beside Hashable (`hir/traits.tcl`'s
intrinsics table): no requirement and no operation (`==` is every
value's), witness `hir::types::EqualityClass` -- the same totality walk as
Hashable's `HashClass`, for the equality operation -- and guarantees
`{equality}` against Hashable's `{equality hash}`. It is not cosmetic:

* It is what ImmutableMap's comparability actually needs: `==` of
  `ImmutableMap[K, V]` is total exactly when V's equality is, a weaker
  condition than V Hashable, and a function (or a struct slot `T satisfies
  Equatable`) can now require exactly that.
* **Hashable refines Equatable**, by the guarantees: `hir::traits::Refines`
  accepts a view of a trait whose guarantees include the expected one's, so
  a Hashable value or view is accepted where an Equatable one is expected
  (`EntryView` re-views it), never the reverse. There is no second witness
  table: one walk, two operations.
* Today the two traits have the same witnesses, because the runtimes'
  refusal lists coincide (`core::value::incomparable` is
  `core::hashing::unhashable`: functions, natives, mutable collections,
  coroutines, C pointers, DecimalRounded). They are separate guarantees, and
  the day a kind is comparable but not hashable they part without a change
  here (the mutation section records the one equivalent mutant this
  causes).

## Semantic-value contract

### Source

```
opaque struct NAME[SLOTS]:
    FIELD: TYPE
    ...
    identity members(F)
    identity associations(K, V)     (one clause, either form)
```

surface/parser.tcl's `IdentityClause` reads `identity FORM(FIELD, ...)` as
a struct body line (a field named `identity` is still a field: the clause
is `identity` followed by a name and a parenthesis); a second clause is a
syntax error. It lowers to the declaration's `identity` entry.

### Checks (`hir::structs::ValidateIdentity`)

| Rule | Diagnostic (TYPE) |
|---|---|
| the struct is opaque | `struct "S" declares an identity but is not opaque: ...` |
| it is not a context struct | `context struct "C" cannot declare an identity ...` |
| the form is `members` or `associations` | `unknown identity form ...` |
| members names one field, associations two | `identity associations takes 2 fields, got 1 ...` |
| each named field exists, once | `... names "f", which is not a field of it` / `... twice` |
| each named field is a List (`List[T]`) | `... an identity field is a List (List[T]) ...` |
| no field of the struct is mutable or affine | `... every value of it is an immutable value whose meaning never changes, but field "f" (...) holds a MutableVector` |

The last rule reads every field, the representation included: an identity
promises a stable meaning, and a mutable component anywhere would let a
value's hash change under a key. `hir::structs::MutableComponent` walks
Lists, sets, tuples and nested structs (a nested identity struct is
immutable by its own check); a slot, `any` or a function is no component of
the declaration (an application's own elements decide its totality).

### HIR and the runtimes

The struct registry entry carries `identity {form F fields {...}}`
(compilation isolation and HIR interchange carry it with the entry); HIR
text prints `identity FORM(F1,F2) ` before `fields` and `hir/read.tcl`
reads it back. The runtimes learn a shape's identity, never a type's name:

* Tcl: `core::value::setIdentityTest hir::structs::RuntimeIdentity`, the
  identity `{FORM {POSITION ...}}` of a declaration (slot positions).
* Native: NIR `shape NAME ... opaque identity="associations keys vals"`,
  parsed into `ShapeInfo.identity` (`Identity::Members(f)` /
  `Associations(k, v)`), and the program descriptor (FORMAT 2) carries it
  into standalone executables, the stub image and native libraries.

## Totality

`hir::types::Totality OPERATION TYPE` decides, once, whether every value of
TYPE has total equality (`equality`) or total hashing (`hash`). Its named
struct case now reads the identity of a struct that declares one: the
components are the element types of the identity fields, labelled in the
type's terms -- "the members of Bag[int]", "the keys of
std::immutable_map::ImmutableMap[str, Fn{...}]", "the values of ..." --
never a field name (the representation is the owner's). So:

* `ImmutableMap[str, int]`, `ImmutableMap[str, List[int]]`, a map of maps,
  a struct holding a map, a List of maps: Hashable and Equatable.
* `ImmutableMap[str, Fn{...}]`, `ImmutableMap[int, MutableVector[int]]`:
  neither; TRAIT-NOT-SATISFIED names the values of the map.
* A representation field of any type takes no part: a DecimalRounded cache
  beside the identity fields keeps the type Hashable
  (`vi-equality-not-hash`; `hir::decimal::Mentions` reads the identity
  fields the same way, so `==` is not refused for it).
* K's constraint is the struct's own (`K satisfies Hashable`): no map type
  with an unhashable key exists, so no witness has to check K again.

These are conditional witnesses over parameterized types with no new
machinery: the walk runs per application, through
`hir::structs::AppliedFieldTypes`.

## Lowering

Nothing in the lowering knows identities. `==` lowers to `veqtotal` when
`hir::types::IsEqualityTotal` holds for both operands, `hash` to
`hashtotal` and `std::table_hash::of` to `tablehashtotal` when
`hir::types::IsHashable` holds, with no error edge and `may_error=false`
(`vi-nir-total`, `im-nir`: one `tablehashtotal` per frozen lookup, the
probe's key comparison `veqtotal`). Those predicates now answer by the
identity, so an admitted map anywhere inside a value -- a field, an
element, a key -- gets the total path. The total operations call the same
runtime functions as the generic ones, whose struct case finds the shape's
identity; a trait view (a Hashable or Equatable parameter) is monomorphized
to the concrete type and hashes by the same runtime case. There is no
registry, witness object or name lookup at run time: the shape table is
the program's, read by index.

Both runtimes compare and hash without running Botlish code and without
allocating on the managed heap (native: the buckets are two Rust vectors
per comparison of more than eight unmatched entries; the hash walk keeps a
few words on the stack). Equality stays no safepoint, so nothing about
rooting changed (GC stress below).

## ImmutableMap

### Representation

```
opaque struct ImmutableMap[K satisfies Hashable, V]:
    keys: List[K]           the live keys, in iteration order
    vals: List[V]           their values, aligned
    hashes: List[int]       their stored keyed table hashes, aligned
    index: List[int]        open-addressed slots: a position or -1
    identity associations(keys, vals)
```

The engine's frozen section (stdlib/ordered_table.bot: `live_keys`,
`live_hashes`, `live_values`, `frozen_index`, `frozen_position`,
`of_frozen`, `permuted`) reuses the mutable table's layout and its probing
rule over Lists. `hashes` and `index` are representation; so is the order
of the three aligned Lists.

### API (`import std::immutable_map`)

| Operation | Meaning | Cost |
|---|---|---|
| `std::mutable_map::freeze(m)` / `m.freeze()` | the ImmutableMap of m's current associations, in m's current order | O(n + slots), no key hashed again |
| `std::immutable_map::empty[K, V]()` | the empty map | O(1) |
| `length`, `empty?` | | O(1) |
| `contains(f, k)`, `at(f, k)` | lookup by the stored keyed hashes; `at` fails with `std::immutable_map::KeyNotFound` | O(1) expected |
| `loop e in f:` | `ImmutableMapEntry {key, value}` in frozen order (the loop protocol) | O(n) |
| `order(f)` | the keys as a MutableSet, in f's order (mints SameMembers) | O(n) |
| `validate_order(f, c)` | C, checked once to hold exactly f's keys, or `OrderMismatch` | O(n) |
| `reordered(f, o)` | f in O's order: O must be known to hold exactly f's keys (REORDER-NOT-PROVEN otherwise) | O(n) |
| `std::mutable_set::freeze(s)` | the ImmutableSet of s's members | O(n) |
| `==`, `hash`, a MutableMap/MutableSet key | by associations | O(n) |

`freeze` copies the live entries into Lists and builds the index at the
map's own slot count: the result shares nothing mutable with the source, so
later mutation of the MutableMap cannot reach it (`im-freeze-snapshot`), and
the frozen map has no mutation API at all. `reordered` uses the existing
relational contracts (hir/relations.tcl: `order` mints SameMembers,
`reordered` requires it of its receiver and order arguments and mints it
for its result), with no immutable-specific proof; a receiver that is no
place (a call's result) is unproven, with a message that asks to bind it
first.

## Map equality

`a == b` for two values of one identity declaration
(core/value.tcl's `IdentityEqual`; ops.rs's `identity_equal`):

1. Different declarations: unequal (the shape comparison every struct
   makes). Different entry counts: unequal, O(1).
2. The positional prefix: entries equal in place are matched in place (two
   maps frozen from the same history compare without hashing).
3. More than eight unmatched entries: hash buckets. B's remaining entries
   are indexed by key hash; each of A's probes its bucket and is matched to
   an unused entry whose key **and value** are equal. Expected O(n). Tcl's
   buckets use the public hash, native ones the keyed table hash.
4. Otherwise (or when an entry has no hash: the comparison below is where
   it is refused, as before): pairwise with used marks.

A pair matches a pair whose key and value are both equal; each entry is
used once (multiset equality). For ImmutableMap's distinct keys this is
exactly "same length, every key of a maps to an equal value in b". Equal
hashes never decide anything: every match ends in `==` of the entries
(`vi-hash-collision-not-equal` builds members, keys and values from two
Ints whose public hashes collide, compared pairwise and through buckets;
`im-full-hash-collisions` injects equal stored keyed hashes for unequal
keys). Nothing is sorted or materialized beyond the bucket index.

## Map public hash

`hash(m)` folds, after the struct's kind tag and its declaration identity
(as every struct's hash does):

```
form tag            1 (members) or 2 (associations)
count               8 bytes, little-endian
sum                 the wrapping 64-bit SUM, 8 bytes little-endian, of each
                    entry's whole hash from a fresh state:
                      member: the member's own fold
                      pair:   fold(entry tag 3, key as a nested value,
                                   value as a nested value)
```

* order-independent: a sum is commutative; the count and the form are
  included;
* association boundaries unambiguous, key and value roles distinguished: a
  pair is hashed as one unit, so `{a: 1, b: 2}` and `{a: 2, b: 1}` sum
  different entry hashes (`tcl-pair-boundary-lost` is the mutant);
* no cancellation: a sum, not an XOR, so a repeated member never cancels
  (`tcl-members-xor`);
* domain-separated: the struct kind tag and declaration identity first,
  then the form tag, so a map, a set, a List and a struct of the same
  entries never share an encoding by construction;
* no keyed or table hash, no index, no stored hash, no order, no other
  field is read.

The public hash is the deterministic FNV-1a fold as before, so it is equal
across processes, backends and table-hash keys: `hash(bag([1, 2, 3], "x"))`
is 2303140193253857579 and `hash(dict(["a", "b", "c"], [1, 2, 3], 1))`
26301586116918609 on every backend (`vi-public-hash-pinned`), and every
existing value kind's public hash is unchanged (no case but the identity
struct's changed; the Hashable pins and `tests/native-hashing.test` pass).

## Map keyed hash

The keyed table hash runs the same walk into the SipHash-1-3 sink: the same
form tag, count and wrapping sum, each entry's whole hash a fresh SipHash
state under the process key over the same entry input. It is a semantic,
keyed content hash -- never a keyed mix of the public hash (the mutant
`tcl-keyed-post-mixes-public` is killed by the fixed-key oracle) -- so
equal maps have equal table hashes in one process whatever their orders,
histories or the key their own tables were built under
(`im-different-secrets`, `vi-hash-coherent`). The two folds share one walk
per runtime (`core::hashing::Encode`/`Identity`; ops.rs's `walk`/
`identity_walk` over a `CanonicalSink`), as they did before.

## ImmutableSet

**Not migrated.** The general mechanism expresses ImmutableSet's semantics
exactly (`identity members(items)` is its equality and an order-independent
hash), but rewriting it as an ordinary opaque struct changes its API in
three ways the brief forbids without an existing defect:

1. **Unconstrained elements.** `std::immutable_set::from_list(xs)` accepts
   any `List`: untyped code (`List`, `List[any]`), sets of functions (one
   function, or several that never need comparing), and the run-time
   EQUALITY when two incomparable members meet (`vi-intrinsic-set-unhashable`,
   MINIMAL-IMMUTABLE-SET.md's "Deduplication semantics"). An ordinary
   Botlish set needs a key placement, and the ordered table places by
   `std::table_hash::of`, which requires Hashable statically: `any`
   satisfies nothing, so every untyped program building a set would stop
   compiling.
2. **Cross-kind membership.** `contains(ImmutableSet, any)` answers false
   for a value of another kind (`set-membership-cross-kind-false`: `{'A',
   'B'}` contains 65 is false, not a TYPE error). An ordinary
   `contains(s: ImmutableSet[T], x: T)` rejects such a call statically.
3. **A built-in structural type.** `ImmutableSet[T]` is spelled without a
   namespace in programs and in the standard library (`std::byte::set` ->
   `ImmutableSet[Byte]`), has a bare kind `ImmutableSet` that two
   differently-elemented sets join to (`hir::types` lub), and is a type
   test's kind. A parameterized struct is `std::immutable_set::ImmutableSet[T]`
   (one canonical identity, no flat alias: STD-NAMESPACE.md), has no bare
   form and no join of two applications. Every program naming the type
   would change: before this milestone, 23 Tcl test files, 8 golden
   suites, 5 benchmark programs and `std::byte`.

None of these is a defect of the set; each is a property of a *runtime*
kind that the ordinary map deliberately does not have (its K is Hashable).
So ImmutableSet keeps its runtime representation and its public API and
hash outputs, and gets what the census found cheap and representation-
independent:

* `from_list` of more than eight members deduplicates by hash buckets (Tcl:
  public hash; native: keyed hash), comparing only a bucket's members:
  expected O(n) instead of O(n^2), the same first-occurrence result, the
  pairwise scan where a member has no hash;
* `==` of sets of more than eight members matches by hash buckets, the
  same rule as identity equality;
* `MutableSet.freeze` builds one from a MutableSet's members.

`contains` stays a linear scan: an O(1) membership needs a stored index in
the runtime representation, the "hashed representation in a milestone of
its own" ORDERED-MUTABLE-MAP-SET.md recommended. Its public hash (XOR of
member hashes, MINIMAL-IMMUTABLE-SET.md) is unchanged: pinned outputs
stay, and the XOR is not ambiguous for a set, whose members are distinct.
Iteration does not exist for ImmutableSet and none was added.

## Order versus identity

```
m = std::mutable_map::create[str, int]()
m.set("a", 1)
m.set("b", 2)
n = std::mutable_map::create[str, int]()
n.set("b", 2)
n.set("a", 1)
f = m.freeze()                          iterates a, b
g = n.freeze()                          iterates b, a
f == g                                  true
hash(f) == hash(g)                      true
f.reordered(g.order())                  REORDER-NOT-PROVEN: g's order is
                                        not known to hold f's keys
o = f.validate_order(g.order()):        checked once
    on std::immutable_map::OrderMismatch:
        f.order()
r = f.reordered(o)                      iterates b, a; r == f and
                                        hash(r) == hash(f)
```

`im-equality-ignores-order`, `im-freeze-histories`, `im-representation-
perturbation` (different capacity, growth path, removals and reinsertion,
a cleared map refilled, copies), `im-different-secrets` (two hidden keys)
and `im-reordered` pin it on all four backends: equal, equal public hashes,
equal keyed hashes under a fixed key, iteration as constructed. Compilerpedia
states it in `concept.collection-order` and `concept.immutable-map`.

## Nested values

`im-nested`, `im-map-as-key`, `im-sets-of-maps` and `vi-nested`:

* a map of maps, a map whose values are Lists of maps, a List of maps, a
  struct holding a map, a Bag of Bags;
* a map as a MutableMap key, a MutableSet member, an ImmutableSet member
  and an ImmutableMap key, looked up with an equal map built in another
  order;
* every one equal, equally hashed and found across orders, on every
  backend, with no runtime case per nesting shape (the struct case of the
  one walk recurses).

## JSON specimen

`im-json` (and its golden port) builds a JSON-like value:

```
enum Kind: Null, Num, Text, Arr, Obj
struct Json:
    kind: Kind
    num: int
    text: str
    items: List[Json]
    fields: std::immutable_map::ImmutableMap[str, Json]
```

An object parsed into a MutableMap and frozen. Two documents whose objects
(and nested objects) list the same members in different source orders are
`==`, hash equally, deduplicate in a MutableSet of documents, and keep
their own member orders (`["id", "tags", "meta"]` against `["meta", "id",
"tags"]`); a document whose array differs in order is a different document
(arrays are Lists).

## Oracle

`audit/value-identity/tools/oracle.py` is an independent model that shares
no code with either runtime: a MutableMap is a Python dict with the
collection's rules (a new key last, a replaced key in place, a removed key
gone, `reorder` an id list), an ImmutableMap a frozen snapshot of one,
equality Python mapping equality, iteration the stored order. Keys and
values are built from Int ids by injective constructions the fuzzer and the
oracle state alike (Int, colliding Int, String, struct, List, small
ImmutableMap keys; Int, String, List, ImmutableMap values). Exact hashes
come from the Hashable oracle (audit/hashable/tools/oracle.py, written from
the reports, not from either runtime), extended with the identity encoding
(`{"identity": {"id": ..., "members"|"associations": [...]}}`), for the
public hash and the keyed hash under a fixed key. `selftest` checks both.

## Fuzzing

`audit/value-identity/tools/fuzz.tcl` builds programs of several
MutableMaps, each through a random history, freezes them and observes
everything identity decides (its header has the full list). It biases
toward the cases that matter: the same associations inserted in another
order or reordered through a validated candidate; the same content after
another history (a reserved capacity, junk keys added and removed so dead
entries and compaction differ, values set wrong then replaced, a clear
midway, a run of fresh keys drained again); one value or one key changed;
one key more or fewer; and a frozen map's `reordered` copy. Key kinds are
Int, Ints of the public hash's collision corpus, String, a struct, a List
and a small ImmutableMap (maps keyed by maps); value kinds Int, String,
List and ImmutableMap. Per program it observes each map's length and
iteration, the pairwise equality of the maps and of their public hashes,
each map's exact public hash and its table hash under a fixed key (through
a privileged fixture module), and the maps used as keys (distinct count in
a MutableMap and in a MutableSet, the first equal map found as a key).
Every observation must equal the oracle's.

| Run | Programs | Observations | Backend runs | Disagreements |
|---|---:|---:|---:|---:|
| seed 2, compiled backends | 6 | -- | 18 | 0 |
| seed 11, all four backends (interp every third program) | 10 | 1,520 | 34 | 0 |
| seed 12, all four backends | 10 | 1,570 | 34 | 0 |
| seed 13, all four backends | 10 | 1,290 | 34 | 0 |
| seed 21, compiled backends and native GC stress | 6 | 742 | 24 | 0 |

The mutation harness runs it once more per mutant (seed 5, six programs,
the compiled backends).

## Mutation testing

`audit/value-identity/tools/mutate.tcl` applies each mutant of its
`mutants.txt` to a private copy of the tree (rebuilding the native backend
for a native mutant), then runs the detectors in order until one kills it:
`tests/value-identity.test`, `tests/immutable-map.test`, then the fuzzer.
**66 mutants, 66 killed, none survived.** The first detector of each:

| Mutant | The bug | First detector |
|---|---|---|
| `identity-non-opaque-admitted` | an identity declared by a struct that is not opaque is accepted | value-identity.test: `vi-decl-not-opaque` |
| `identity-context-admitted` | a context struct may declare an identity | value-identity.test: `vi-decl-context` |
| `identity-field-not-list-admitted` | an identity field need not be a List | value-identity.test: `vi-decl-forms` |
| `identity-mutable-admitted` | a struct with an identity may hold a MutableVector, a MutableArray or an affine value | value-identity.test: `vi-decl-immutable` |
| `identity-lost-in-hir-text` | HIR text prints no identity clause | value-identity.test: `vi-hir-text` |
| `identity-lost-in-read` | reading HIR text drops the identity clause | value-identity.test: `vi-hir-text` |
| `identity-lost-in-install` | installing a HIR's declarations (compilation isolation) drops the struct's identity | value-identity.test: `vi-hir-text` |
| `runtime-identity-positions-wrong` | the runtimes' identity test gives every identity field the first slot | value-identity.test: `vi-associations-equality`, `vi-hash-coherent` and more |
| `native-lowering-drops-identity` | the NIR shape of a struct with an identity carries none | value-identity.test: `vi-associations-equality`, `vi-compilation-isolation` and more |
| `tcl-identity-ignored-in-equality` | == of two values of an identity struct compares every field (the representation) | value-identity.test: `vi-associations-equality`, `vi-compilation-isolation` and more |
| `tcl-equality-by-order` | == of two identity values compares the entries in order (no matching after the positional prefix) | value-identity.test: `vi-associations-equality`, `vi-compilation-isolation` and more |
| `tcl-equality-ignores-length` | == of two identity values matches the first one's entries without comparing the counts | value-identity.test: `vi-members-equality` |
| `tcl-equal-by-hash` | == of two members identities is the equality of their entries' public hashes (same length, same hashes) | value-identity.test: `vi-hash-collision-not-equal` |
| `tcl-pair-value-ignored` | an association matches on its key alone (the value takes no part) | value-identity.test: `vi-associations-equality`, `vi-hash-collision-not-equal` and more |
| `tcl-pairwise-reuses-entry` | pairwise matching lets two entries match one entry (a set's equality, not the multiset's) | value-identity.test: `vi-members-equality` |
| `tcl-bucket-reuses-entry` | matching by hash buckets lets two entries match one entry | value-identity.test: `vi-hash-matching` |
| `tcl-bucket-trusts-hash` | matching by hash buckets takes an entry of the same public hash as equal (identities and large sets) | value-identity.test: `vi-hash-collision-not-equal`, `vi-hash-matching` and more |
| `tcl-set-dedup-trusts-hash` | a large ImmutableSet's construction drops a member whose public hash equals a kept one's | value-identity.test: `vi-intrinsic-set-collision` |
| `tcl-hash-includes-representation` | the hash of an identity value also folds every field after its identity | value-identity.test: `vi-equality-not-hash`, `vi-equatable-conditional` and more |
| `tcl-pair-hash-in-order` | an associations identity's entry hashes are combined in order (sum times 31) | value-identity.test: `vi-hash-coherent`, `vi-hash-matching` and more |
| `tcl-member-hash-in-order` | a members identity's member hashes are combined in order (sum times 31) | value-identity.test: `vi-equality-not-hash`, `vi-equatable-conditional` and more |
| `tcl-members-xor` | a members identity's member hashes are XOR-combined (a repeated member cancels) | value-identity.test: `vi-hash-oracle`, `vi-public-hash-pinned` |
| `tcl-hash-omits-value` | an association's hash leaves out its value | value-identity.test: `vi-hash-coherent`, `vi-hash-oracle` and more |
| `tcl-hash-omits-key` | an association's hash leaves out its key | value-identity.test: `vi-hash-coherent`, `vi-hash-oracle` and more |
| `tcl-pair-boundary-lost` | an association's hash is the sum of its key's and its value's (keys and values rearranged across pairs keep the sum) | value-identity.test: `vi-hash-coherent`, `vi-hash-oracle` and more |
| `tcl-domain-tag-omitted` | the hash of an identity folds no form tag | value-identity.test: `vi-hash-oracle`, `vi-public-hash-pinned` |
| `tcl-count-omitted` | the hash of an identity folds no entry count | value-identity.test: `vi-hash-oracle`, `vi-public-hash-pinned` |
| `tcl-keyed-post-mixes-public` | the table hash of an identity folds its entries' public hashes (a keyed mix of the unkeyed hash) | value-identity.test: `vi-hash-oracle` |
| `native-identity-ignored-in-equality` | native == of two values of an identity shape compares every field | value-identity.test: `vi-associations-equality`, `vi-compilation-isolation` and more |
| `native-equality-by-order` | native == of two identity values compares the entries in order | value-identity.test: `vi-associations-equality`, `vi-compilation-isolation` and more |
| `native-pair-value-ignored` | a native association matches on its key alone | value-identity.test: `vi-associations-equality`, `vi-hash-collision-not-equal` and more |
| `native-bucket-ignores-value` | native matching by hash buckets compares an entry's key, never its value | value-identity.test: `vi-hash-collision-not-equal`, `vi-hash-matching` |
| `native-pairwise-reuses-entry` | native pairwise matching lets two entries match one entry | value-identity.test: `vi-members-equality` |
| `native-hash-includes-representation` | the native hash of an identity value also walks every field | value-identity.test: `vi-equatable-conditional`, `vi-executable` and more |
| `native-pair-hash-in-order` | native association hashes are combined in order | value-identity.test: `vi-hash-coherent`, `vi-hash-matching` and more |
| `native-member-hash-in-order` | native member hashes are combined in order | value-identity.test: `vi-equality-not-hash`, `vi-equatable-conditional` and more |
| `native-hash-omits-value` | a native association's hash (public and keyed) leaves out its value | value-identity.test: `vi-hash-coherent`, `vi-hash-oracle` and more |
| `native-domain-tag-omitted` | the native hash of an identity folds no form tag | value-identity.test: `vi-executable`, `vi-hash-oracle` and more |
| `native-descriptor-drops-identity` | a standalone executable's program descriptor loses every shape's identity | value-identity.test: `vi-executable` |
| `witness-reads-representation` | Totality walks every field of an identity struct (its representation), not its identity's elements | value-identity.test: `vi-equality-not-hash`, `vi-equatable-conditional` |
| `conditional-witness-always` | an identity's elements are taken to be total whatever their type (Bag[MutableVector[int]] is Equatable) | value-identity.test: `vi-equatable-conditional`, `vi-nir-total` |
| `refines-dropped` | Hashable no longer refines Equatable (a Hashable view is not Equatable) | value-identity.test: `vi-hashable-refines-equatable` |
| `refines-reversed` | the refinement runs backwards (an Equatable view is accepted as Hashable) | value-identity.test: `vi-hashable-refines-equatable` |
| `decimal-guard-reads-representation` | == of an identity struct is refused for a DecimalRounded field of its representation | value-identity.test: `vi-equality-not-hash` |
| `identity-reads-stored-hashes` | the map's identity pairs its keys with its stored hashes, not its values | immutable-map.test: `im-conditional-witness`, `im-different-secrets` and more |
| `identity-reads-index` | the map's identity is the members of its index (the hidden placement) | immutable-map.test: `im-conditional-witness`, `im-equality-associations` and more |
| `identity-keys-only` | the map's identity is its keys alone (values take no part) | immutable-map.test: `im-conditional-witness`, `im-equality-associations` and more |
| `k-constraint-dropped` | the map's key slot is unconstrained | immutable-map.test: `im-allocation`, `im-conditional-witness` and more |
| `iteration-reversed` | iteration visits the associations last to first | immutable-map.test: `im-equality-ignores-order`, `im-freeze-basic` and more |
| `at-off-by-one` | `at` returns the value after the key's | immutable-map.test: `im-freeze-basic`, `im-freeze-histories` and more |
| `reordered-not-permuted` | `reordered` returns the map in its own order | immutable-map.test: `im-reordered` |
| `reordered-drops-values` | `reordered` permutes the keys and their hashes but not the values | immutable-map.test: `im-reordered` |
| `reordered-stale-index` | `reordered` keeps the source's index over the permuted hashes | immutable-map.test: `im-reordered` |
| `validate-order-not-checked` | `validate_order` accepts any candidate | immutable-map.test: `im-validate-mismatch` |
| `freeze-keeps-dead-keys` | freezing keeps the keys of removed entries | immutable-map.test: `im-freeze-histories`, `im-freeze-snapshot` and more |
| `freeze-values-misaligned` | freezing keeps the values of removed entries (values shift against their keys) | immutable-map.test: `im-freeze-histories`, `im-freeze-snapshot` |
| `freeze-keeps-dead-hashes` | freezing keeps the hashes of removed entries (the index points past them) | immutable-map.test: `im-freeze-histories` |
| `freeze-empty-index` | freezing builds an index that places no entry | immutable-map.test: `im-freeze-basic`, `im-freeze-histories` and more |
| `place-frozen-overwrites` | building the frozen index overwrites an occupied slot instead of probing on | immutable-map.test: `im-freeze-histories`, `im-full-hash-collisions` and more |
| `frozen-probe-trusts-hash` | a frozen lookup takes an entry of the same keyed hash for the key | immutable-map.test: `im-full-hash-collisions` |
| `frozen-probe-stops-early` | a frozen lookup stops at the first occupied slot of another key | immutable-map.test: `im-allocation`, `im-freeze-basic` and more |
| `set-freeze-first-member-lost` | a frozen MutableSet loses its first member | immutable-map.test: `im-set-freeze`, `im-sets-of-maps` |
| `reordered-contract-dropped` | `reordered` has no contract: an unproven order is accepted | immutable-map.test: `im-reordered-not-proven` |
| `order-not-minted` | `order` mints no fact: m.reordered(m.order()) is unproven | immutable-map.test: `im-reordered` |
| `reordered-value-receiver-unchecked` | a receiver that is no place (a call's result) is taken to hold the order's members | immutable-map.test: `im-reordered-not-proven` |
| `immutable-map-not-iterable` | a loop over an ImmutableMap is no loop protocol's | immutable-map.test: `im-allocation`, `im-conditional-witness` and more |

Notes on the families the brief names:

* Order-sensitive equality and hashes (`*-by-order`, `*-in-order`), hashes
  of representation (`*-includes-representation`, `identity-reads-index`,
  `identity-reads-stored-hashes`, `freeze-keeps-dead-*`), trust-hash
  equality (`tcl-equal-by-hash`, `tcl-bucket-trusts-hash`,
  `tcl-set-dedup-trusts-hash`, `frozen-probe-trusts-hash`), the encoding
  (`*-domain-tag-omitted`, `tcl-count-omitted`, `tcl-pair-boundary-lost`,
  `tcl-members-xor`, `*-hash-omits-*`, `tcl-keyed-post-mixes-public`),
  conditional witnesses (`conditional-witness-always`,
  `witness-reads-representation`, `k-constraint-dropped`,
  `identity-keys-only`), owner and coherence rules
  (`identity-non-opaque-admitted`, `identity-context-admitted`,
  `identity-mutable-admitted`), trait views (`refines-*`), and the
  cross-backend walk (every `native-*` mutant, the descriptor's included)
  are all killed.
* `k-constraint-dropped` and `immutable-map-not-iterable` are killed by a
  compile-time rejection, which is the property they break (without the
  constraint the module itself does not compile: the keyed hash requires
  Hashable statically).
* Equivalent mutants, not in the file (its header records why): the
  native buckets trusting a bucket's hash (they are the keyed hash's: a
  wrong answer needs a 64-bit SipHash collision under the process key), the
  Equatable witness read from the hash predicate (the two refusal lists are
  the same list today), and freeze aliasing the mutable map or a frozen map
  becoming mutable (a frozen map holds Lists, immutable values; the
  declaration check refuses any mutable component).
* Two kills were not of the property and were fixed before the final run:
  `set-freeze-first-member-lost` first failed to compile (the module did
  not import `std::list`); it now compiles and dies in `im-set-freeze`. The
  collision tests first never reached the hash buckets (a matching
  positional prefix came first); they now put the colliding entry before
  nine reordered fillers, which is what kills `tcl-bucket-trusts-hash`.

## Performance

`bench/value-identity.tcl` (its header defines every row), on this
container's x86-64 cores, the native backend (cranelift), best of five runs,
each row a difference of two runs so the setup cancels; keys Int, String
(`id_` and hex digits) and a struct `Point {x, y}`, each key id i holding
the value i. Results: `audit/value-identity/results/time.tsv` and
`instructions.tsv`.

| operation (ns) | int 16 | int 1024 | int 65536 | str 16 | str 1024 | str 65536 | struct 16 | struct 1024 | struct 65536 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| freeze, per entry | 154.75 | 113.02 | 129.71 | 183.93 | 111.92 | 149.33 | 176.32 | 110.56 | 145.76 |
| MutableMap build, per entry | 291.41 | 188.93 | 219.16 | 331.64 | 368.23 | 677.12 | 424.13 | 342.45 | 416.04 |
| `at` hit | 44.49 | 51.67 | 115.95 | 50.11 | 63.57 | 292.19 | 153.71 | 150.11 | 323.63 |
| `contains` miss | 59.88 | 68.21 | 84.78 | 44.73 | 64.89 | 102.41 | 131.32 | 134.18 | 158.97 |
| MutableMap `at` hit | 63.66 | 71.26 | 140.82 | 71.77 | 83.06 | 366.83 | 157.70 | 172.93 | 376.43 |
| MutableMap `contains` miss | 71.94 | 83.11 | 86.93 | 56.94 | 73.02 | 125.34 | 123.01 | 143.91 | 164.91 |
| loop, per entry | 13.15 | 7.35 | 7.73 | 13.40 | 7.50 | 8.13 | 13.11 | 7.50 | 7.71 |
| `==` equal, same order, per entry | 13.23 | 10.50 | 11.87 | 15.38 | 14.44 | 29.40 | 30.40 | 28.61 | 27.10 |
| `==` equal, reversed, per entry | 66.04 | 70.31 | 87.48 | 71.26 | 72.28 | 158.88 | 209.95 | 221.65 | 251.56 |
| `==` first association differs, per entry | 30.33 | 27.51 | 33.98 | 32.58 | 29.40 | 46.11 | 101.46 | 86.67 | 100.59 |
| `==` last association differs, per entry | 64.48 | 66.91 | 94.51 | 69.74 | 73.46 | 150.86 | 219.10 | 215.19 | 250.36 |
| `==` lengths differ, per comparison | 16.85 | 17.08 | 19.73 | 18.21 | 17.85 | 29.74 | 17.53 | 17.57 | 15.98 |
| public hash, per entry | 24.56 | 17.79 | 20.93 | 20.84 | 18.84 | 22.22 | 54.98 | 56.10 | 58.42 |
| table hash, per entry | 45.54 | 42.33 | 42.52 | 44.21 | 42.27 | 50.54 | 105.27 | 104.45 | 112.98 |
| List `==`, per element | 5.40 | 4.57 | 4.60 | 9.60 | 8.34 | 20.03 | 24.03 | 22.02 | 23.07 |
| ImmutableSet `==`, reversed, per member | 55.76 | 60.63 | 77.94 | 62.55 | 65.99 | 171.14 | 222.59 | 211.35 | 240.04 |
| ImmutableSet hash, per member | 7.78 | 7.56 | 8.12 | 8.30 | 8.12 | 11.40 | 36.29 | 37.81 | 38.68 |

Instructions per operation (callgrind, one run each: no machine noise),
for the Int and String keys at 16 and 1024 entries:

| operation (instructions) | int 16 | int 1024 | str 16 | str 1024 |
|---|---:|---:|---:|---:|
| freeze, per entry | 2253 | 1527 | 2206 | 1529 |
| `at` hit | 779 | 838 | 835 | 898 |
| `contains` miss | 1150 | 1039 | 831 | 853 |
| MutableMap `at` hit | 973 | 1073 | 1090 | 1112 |
| loop, per entry | 207 | 134 | 207 | 135 |
| `==` equal, same order, per entry | 224 | 202 | 325 | 301 |
| `==` equal, reversed, per entry | 1149 | 1147 | 1326 | 1291 |
| `==` first association differs, per entry | 549 | 472 | 604 | 497 |
| `==` last association differs, per entry | 1145 | 1141 | 1321 | 1292 |
| public hash, per entry | 365 | 390 | 374 | 384 |
| table hash, per entry | 748 | 772 | 806 | 812 |
| List `==`, per element | 93 | 79 | 192 | 178 |
| ImmutableSet `==`, reversed, per member | 1047 | 1063 | 1221 | 1211 |
| ImmutableSet hash, per member | 136 | 150 | 145 | 143 |

What the numbers say:

* **Complexity is as designed.** Per-entry costs are flat from 16 to
  65,536 entries for freeze, iteration, every kind of `==` and both hashes
  (the rise at 65,536 entries, largest for String keys, is the memory
  hierarchy's: the MutableMap's own build and lookups rise the same way);
  lookups are flat per lookup. `==` of
  maps of different lengths is O(1), about 17 ns at every size. Nothing
  sorts, nothing is O(n log n), nothing is quadratic.
* **Equality.** Two maps built alike match positionally: 200-300
  instructions per entry, about 2.5 times a List `==` of the keys alone (a
  map compares a key and a value per entry, through the identity's
  dispatch). Reordered maps go through the hash buckets: about 1,150-1,300
  instructions per entry, most of it two keyed SipHash folds per key (the
  table hash alone is about 750-810 per entry). An inequality found at the
  first association costs half of one found at the last: B's buckets are
  built either way, A's probes stop at the first miss. ImmutableSet `==`
  (now matched by the same buckets) costs the same as a map's per member.
* **Hashing.** The public hash is about 370-390 instructions per entry
  (an entry is hashed as a unit, its key and value as nested values), the
  table hash about twice that (SipHash rounds); neither allocates or
  depends on order. A set's hash (an XOR of member hashes, unchanged) is
  cheaper per member: it hashes one value, not a pair.
* **Lookups** in a frozen map are expected O(1) through the stored keyed
  hashes and the frozen index -- about 780-900 instructions per hit, a
  little cheaper than a MutableMap's (970-1,110). A miss costs about the
  same.
* **Freeze** is O(n): about 1,500 instructions per entry at 1,024 entries
  (110-180 ns), cheaper than building the MutableMap it copies (190-680 ns
  per entry). It hashes nothing (the stored hashes are copied) and makes 11
  managed allocations per freeze whatever the size (22 for two at 16,
  1,024 and 65,536 entries alike: a List is one block).
* **Allocations.** None per lookup, per entry of a loop, per `==` (either
  path) or per hash, in either fold: the native buckets are two Rust
  vectors per comparison of more than eight unmatched entries, off the
  managed heap.
* **No hash caching.** A map's hash is recomputed per call, O(n); at about
  20 ns per Int entry a 65,536-entry map hashes in about 1.4 ms. Caching it
  would put a field in the value that equality must ignore and
  serialization must recompute; nothing measured here needs it.

## Regression and CI

Run in this container (4 cores), on the final code:

| Check | Result |
|---|---|
| `tests/value-identity.test` | 33/33 |
| `tests/immutable-map.test` | 26/26 |
| both, under `BOTLISH_NATIVE_GC_STRESS=1` | 33/33, 26/26 |
| golden `value-identity.bot`, `immutable-map.bot` | 18 and 30 tests, all four backends |
| `tests/local.tcl` (every Tcl test file on interp and compile, every golden suite on four backends; two runs, the second the files the first had not reached when it stopped, and the files and suites the fix below touches) | 0 failures |
| `cargo test --release --lib` / `--bins` | 302 / 109 passed |
| `python3 -I audit/value-identity/tools/oracle.py selftest`, Hashable's, MutableMap's | ok |
| `audit/hir-interchange/tools/roundtrip.tcl` (default suites; and value-identity, immutable-map, mutable-map, collection-reorder, hashable, `-via interchange` and `-via cache`) | 108, 45 and 50 artifacts and outcomes, 0 differ |
| `audit/compilation-isolation/tools/interleave.tcl` (default suites; and the four suites above) | 96 and 32 compared, 0 differ |
| `audit/refactor/tools/gate.tcl` (the warning gate) | passed (`stdlib/immutable_map.bot` is listed like `mutable_map.bot`: it imports the internal engine) |
| `tools/compilerpedia.tcl check` | 1098 topics, 659 examples, 0 problems |
| golden manifest (`merge.tcl -check 1`) | consistent (11,875 rows) |
| value-identity fuzzer | 0 disagreements (above) |
| mutation harnesses: value-identity, Hashable, traits, trait-constrained types, mutable-map, collection-reorder (with its proof fuzzer) | 66/66, 45/45, 40/40, 43/43, 57/57, 46/46 killed |

What the runs found:

* `tests/method-filter.test`'s `mf-nominal-receivers-decided` failed once:
  std::mutable_map imports std::immutable_map (for `freeze`), so every
  program importing the collections compiles `immutable_map.bot`, whose
  `m.vals.at(p)` and `iteration_at`'s two `at` calls had the module's own
  `at` as a second, lexical candidate -- three deviation builds per
  compilation where the test pins none. The engine's rule applies (the
  collections' own method calls are written so the kind proofs decide
  them): the three calls are now qualified, `std::list::at`.
* Hashable's mutant `keyed-is-keyed-mix-of-hash-native` no longer applied
  (its anchor, the start of a SipHash walk, now also opens `bucket_hash`);
  it is retargeted at `table_hash_with_key`, the same rule.
* Three mutants of other harnesses do not apply to this checkout
  (native-aot's `startup-no-guard` and `sys-runtime-variable-ignored`,
  native-view's `view-is-a-pointer`); they edit files this milestone does
  not touch, and were not run.

CI on the branch `claude/confident-archimedes-9gikyw`, at the last code
commit (a7e803ba): `tests.yml`, `tests-arm64.yml` and `static-decisions.yml`
dispatched by hand (static-decisions because the front end and the standard
library changed: the batched against the sequential scheduler, never run
locally), the macOS and Windows workflows on push. Passed: the Windows
Icy Tower workflow, and the Windows workflow's smoke job (its Rust tests,
native status, GC workloads under GC stress and the unwind check, the
Windows-relevant test files) and root-plans job. Still queued behind the
repository's runner backlog when this was written, so **pending, not
passed**: `tests.yml`, `tests-arm64.yml`, `static-decisions.yml`, the macOS
workflow, and the Windows acceptance shards and system-linker job.

## Limitations

* ImmutableSet is not migrated (section "ImmutableSet"); its `contains` is
  still O(n).
* There is no direct ImmutableMap construction but `empty()` and `freeze`;
  no literal syntax, no `from_list` of pairs, no update returning a new
  map (`with`, `without`): freeze a MutableMap again.
* Two identity forms only. An identity over a single ordered sequence is an
  ordinary struct's own equality; a form over nested identities (a map of
  sets) is the composition of declarations. A third form is a deliberate
  addition (a row and an encoder case per runtime), never a function.
* Lookups of an ImmutableMap trust its owner's representation (its index
  and stored hashes are the frozen table's); equality and hashes do not.
* No hash caching: `hash` and `==` of a map are O(n) every time (measured
  below; no value-model change to cache them).
* Equatable and Hashable have the same witnesses today; nothing in the
  language yet distinguishes them.
