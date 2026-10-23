# Hash tables: the compiler and runtime pressure catalogue

This is the catalogue of deficiencies that the
[hash-table experiment](HASH-TABLE-EXPERIMENT.md) found. Each deficiency is
something that makes an otherwise good Botlish implementation of a hash
table, a set or a membership test cost more than its algorithm does. Every
entry records:

* the smallest source that shows it;
* the fact or optimization the source deserves;
* what the compiler does today, and the HIR or NIR evidence;
* the run-time and benchmark consequence;
* how far it reaches beyond hash tables;
* a candidate fix, whether it was prototyped, and the result.

The prototypes of every entry marked "prototyped" are merged into this
branch, except RT-1, which is a patch,
`audit/hash-table/patches/probe-primitive.patch`.
An adversarial review of the merged prototypes found soundness bugs that
they caused or exposed, and several older ones; all are fixed ("Found by
the adversarial review of the prototypes", at the end).
Their commits are cited by ID. HASH-TABLE-EXPERIMENT.md, "Compiler
experiments" and "Runtime experiments", gives each one's validation and
measured effect.

**Entries by class.** An entry's class is the experiment's gap
classification (brief section 1):

| prefix | class | meaning |
|---|---|---|
| VS | avoidable allocation | the value-semantics elaboration (`hir/mutvec.tcl`) writes a logical copy that the program does not need; the next write copies the whole array |
| CP | missing proof | a fact that holds in every run is not proven, so a check, an error edge or a handler stays |
| CG | codegen deficiency | a lowering that is correct but much slower than the operation needs |
| RO | runtime primitive overhead | an existing runtime helper doing work that is no part of its specification |
| CO | missing specialization or optimization | a general optimization (inlining, CSE, specialization) that does not fire |
| RT | runtime pressure (brief section 34) | an operation ordinary Botlish cannot express efficiently even with the compiler work above |

**Cost.** A proof or optimization is called *cheap* when it is local: one
function, one rule, no new kind of fact. It is *costly* when it needs a
fact that crosses a function boundary, an invariant over a struct or over
mutable contents, or a whole-program analysis.

## Summary

| ID | deficiency | class | cost | prototyped | result |
|---|---|---|---|---|---|
| [VS-1](#vs-1-last-use-is-per-binding-not-per-path) | last use is per binding, not per field path | allocation | cheap | yes (`720c826`) | the rebuild idiom copies nothing |
| [VS-2](#vs-2-a-struct-literal-in-an-exclusive-position-does-not-demand-its-fields) | a struct literal in an exclusive position does not demand its fields | allocation | cheap | yes (`6c76947`) | memo: 15.6 M elements copied -> 0 |
| [VS-3](#vs-3-a-consumed-argument-read-again-by-a-later-argument) | a consumed argument that a later argument reads | allocation | cheap | no | workaround: bind first |
| [VS-4](#vs-4-a-dead-copy-keeps-the-backing-shared-until-the-collector-runs) | a dead copy keeps the backing shared until the collector runs | allocation | (by design) | no | removed statically by VS-1..3 |
| [VS-5](#vs-5-one-value-use-of-a-function-costs-every-direct-call-a-copy) | one value use of a function costs every direct call a copy | allocation | moderate | no | |
| [VS-7](#vs-7-a-nested-function-capturing-a-read-out-makes-a-reader-copy) | a nested function capturing a read-out makes a reader's parameter not observed-only | allocation | moderate | no | `lp` still detaches on every write after VS-1 and VS-2 |
| [VS-6](#vs-6-copies-are-invisible) | inserted copies are invisible | tooling | cheap | no (the experiment's `tools/copies.tcl`) | |
| [BUG-1](#bug-1-an-argument-read-by-reference-saw-a-later-arguments-write) | an argument read by reference saw a later argument's write | **miscompilation** | -- | fixed (`9c79b28`) | five wrong values on every backend |
| [CP-1](#cp-1-an-index-reduced-by-the-containers-own-size) | `mod(x, capacity(a))` / `bit_and(x, capacity(a) - 1)` is not an index of `a` | proof | cheap | yes (`e0b7b9c`) | proven |
| [CP-2](#cp-2-a-guard-on-a-computed-local) | a guard on a computed local proves nothing | proof | cheap | yes (`b1144fe`) | proven |
| [CP-3](#cp-3-a-field-path-is-a-new-container-each-time-it-is-written) | a field path is a new container each time it is written; writes through a field place are never proven | proof | cheap | yes (`a1e281d`) | proven, in-place |
| [CP-4](#cp-4-facts-do-not-cross-a-call) | an index computed in one function and used in another | proof | costly | no | the main reason no table index is proven |
| [CP-5](#cp-5-parallel-arrays-equal-capacities) | parallel arrays' equal capacities | proof | costly | no | |
| [CP-6](#cp-6-mutable_vectorat-is-never-proven) | `std::mutable_vector::at` has no bounds registration | proof | cheap | no | |
| [CP-7](#cp-7-a-collections-contents-cannot-bound-anothers-index) | one collection's contents cannot bound another's index | proof | costly | no (not a candidate) | |
| [CP-8](#cp-8-the-binary-search-midpoint) | the binary-search midpoint | proof | moderate | no | |
| [CG-1](#cg-1-every-mutablearray-access-is-a-helper-call) | every MutableArray access is a helper call, proven or not | codegen | moderate | yes (`0bd45ff`, `11fe677`) | at 6.6 -> 1.6 ns, set 9.3 -> 1.3 ns |
| [CG-2](#cg-2-mod-is-always-a-fallible-allocating-helper) | `mod` is always a fallible, allocating helper | codegen | cheap | yes (`71e4be1`, `3b9f42c`, `3c2bfc4`) | `i.mod(1024)` 78 -> 26 instructions, `i.mod(n)` 81 -> 34 |
| [BUG-2](#bug-2-a-divisor-beyond-64-bits-aborted-the-front-end) | a divisor beyond 64 bits aborted the front end (Tcl 9.0.1's `max()`) | **crash** | -- | fixed (`19bd2ff`) | |
| [CG-3](#cg-3-cranelift-generic-cannot-lower-an-untyped-struct-projection) | cranelift-generic cannot lower an untyped struct projection | codegen | -- | no | a coverage gap |
| [RO-1](#ro-1-hash-allocates) | `hash` mallocs for an Int and clones a struct's shape | runtime overhead | cheap | yes (`4bc7c94`) | hash(i) 29.7 -> 19.2 ns, 0 mallocs |
| [CO-1](#co-1-small-helpers-stay-calls-on-every-probe-step) | small helpers stay calls on every probe step | optimization | cheap with CG-2 | partly (`2b6a055`) | a `mod` leaf whose divisor excludes 0 inlines; `lpa`'s do not |
| [CO-2](#co-2-pure-helper-calls-are-never-cse-d-or-hoisted) | pure helper calls are never CSE'd or hoisted | optimization | -- | through CG-1 | |
| [CO-3](#co-3-untyped-slot-storage-costs-generic-equality-in-every-instance) | untyped slot storage costs generic equality in every instance | specialization | costly | no | measured: typed vs generic |
| [CO-4](#co-4-hash-and-generic-equality-have-no-total-siblings) | `hash` and `==` have no total siblings | optimization | cheap | no | |
| [CO-5](#co-5-collecting-loops-and-empty-literals-allocate) | collecting loops and empty literals allocate more than they need | allocation | moderate | no | chain0: 4 objects per lookup |
| [CO-6](#co-6-struct-keys-are-hashed-and-compared-through-materialized-objects) | struct keys are hashed and compared through materialized objects | allocation | moderate | partly (RO-1) | |
| [CO-7](#co-7-native-lowering-of-a-large-list-literal-is-quadratic) | native lowering of a large List literal is quadratic in its length | compile cost | moderate | no | 15,531 elements: 173 s; 62,949: out of 15 GB |
| [CO-8](#co-8-a-long-equality-chain-exceeds-the-front-ends-nesting-limit) | a long `or` chain exceeds the front end's nesting limit | compile limit | cheap | no | 1,024 terms: "too many nested evaluations" |
| [RT-1](#rt-1-a-probe-primitive) | a probe primitive | runtime | -- | yes (`audit/hash-table/patches/probe-primitive.patch`) | 2-41 % on the baseline; 0-10 % against proof-shaped Botlish after the compiler work: not justified |
| [RT-2](#rt-2-a-runtime-owned-table) | a runtime-owned table | runtime | -- | no (the Rust reference stands in) | |
| [RT-3](#rt-3-a-keyed-hash) | a keyed hash: no table can defend itself against chosen keys | runtime | -- | no (a semantic decision) | colliding keys: 2.8-9.0 µs per hit at 1,024 keys on the baseline |

The rest of this document gives the entries in full, in the order of the
table.

---------------------------------------------------------------------------

## Value semantics

A MutableArray or MutableVector is a value over a copy-on-write backing
(MUTABLE-ARRAY.md, MUTABLE-VECTOR.md). `hir::mutvec::Elaborate` writes out
the logical copies (`mutable_vector#share`) that value semantics need. The
next write through a header whose backing is shared copies the whole array
(the runtime's detach). A needless copy therefore costs O(capacity) on the
next write, not O(1). In a table, every update is such a write, so one
needless copy per update turns an O(1) insert into an O(n) one. That makes
every build quadratic.

Every entry here is a precision gap: the elaboration is sound, but it is
conservative in ways that ordinary table code triggers. Every
implementation in the experiment except `lp` follows the rules of SPEC.md
section 7, which avoid these triggers, and `tools/copies.tcl` audits each
one at 0 shares and 0 detaches in steady state.

### VS-1. Last use is per binding, not per path

* **Minimal source** (`impl/lp.bot`'s `with_count`, the natural way to
  update an Int field of a table):

  ```
  struct Table:
      hashes: MutableArray[int]
      keys: mutarray
      vals: mutarray
      count: int

  fn with_count(t: Table, c: int) -> Table:
      Table {hashes: t.hashes, keys: t.keys, vals: t.vals, count: c}
  ```

  The same holds for `T {keys: t.keys, vals: t.vals, count: t.count + 1}`,
  for `fill(r.table, i + 1, acc + r.old)`, and for `store(t, i, t.count +
  1)`.
* **Expected.** Each read-out of `t.hashes`, `t.keys` and `t.vals` is that
  path's last use: the three paths are disjoint, and nothing reads them
  later. Each header moves into the new struct, and the function is fresh.
* **Current behavior.** `NoLaterUse` asks whether the *binding* `t` is used
  later. `t.keys` is followed by `t.vals`, a use of `t`, so every field but
  the last is copied. `with_count` is not fresh, so its callers copy its
  result again.
* **Evidence.** HIR: `mutable_vector#share` around `t.hashes` and `t.keys`.
  NIR: `mvshare ... "h"` in `with_count`, `"s3.0.h1.h2.h"` in its callers.
  Counters (`tools/copies.tcl lp`, 1,024 Int inserts, then 2,000
  replacements):

  | | shares | detaches | elements copied |
  |---|---:|---:|---:|
  | build (1,024 inserts) | 13,488 | 7,344 | 9,223,752 |
  | replace (2,000) | 25,488 | 9,344 | 13,319,752 |

* **Consequence.** An insert costs 2.8 us at 16 entries and 23.3 us at
  1,024 (baseline), against 0.2-0.3 us for `lpa`, which keeps the count in a
  one-slot array and never rebuilds the struct. That is O(n) per insert,
  so the build is quadratic.
* **Generality.** This affects any struct that holds more than one
  collection and is rebuilt from its own fields:
  * the CSV records of examples/stdlib;
  * the 2048 engine's state;
  * a BFS state of frontier, seen flags and count. The prototype measured
    an N x N grid at N = 100 going from 313 ms to 1.1 ms, and at N = 200
    from 4.48 s to 13.6 ms;
  * every "functional update" of a record.
* **Candidate fix.** Last use per path. A read-out of path P moves unless a
  later use may read a header at P. Such a use is P itself, a prefix of P,
  or an extension of P that may hold a header. Disjoint sibling paths, and
  extensions that hold none (an Int field), do not count.
* **Prototyped.** Yes, as commit `720c826`, merged. The commit includes:
  * tests: `mv-path-last-use-semantics` (eleven programs: each overlapping
    later use keeps its copy, each disjoint one moves);
    `mv-path-last-use-copies`; `ma-path-last-use-copies`;
  * a third fuzzer family `PATHS` in `audit/mutable-vector/tools/fuzz.tcl`;
  * eleven `path-*` mutants, all killed (the fuzzer alone kills six of the
    nine unsound ones);
  * MUTABLE-VECTOR.md, "Last uses per path".
* **Result.**
  * The value-semantics survey's rebuild programs go from 400 shares, 198
    detaches and 198,000 elements copied to 0. The wrong-field-order
    resize, 1,000 inserts, goes from 9,696 shares and 6.0 M elements to 0.
  * The natural `lp` goes from 13,488 shares to 7,368, but it still
    detaches on every write. Two other triggers cause that: VS-3 and VS-7.
    With their workarounds applied as well, `lp` copies nothing (VS-7's
    table).
* **Soundness fix after review.** The rule relies on every slot of a held
  binding owning its headers. A struct's share descriptor skipped its
  `any` slots (`s1.0.h` for `{a: MutableVector[int], d1: any, d2: any}`),
  so such a slot kept its source's header, and `k = w.d1` moved while
  `w.d2` held the same header: a miscompile the per-binding rule had hidden
  (the unrestricted copy of an `any` slot was wrong before it too, through
  a place). The descriptor now lists an imprecise slot with `d`, a copy of
  what it holds at run time (MUTABLE-VECTOR.md, item 8;
  `mv-any-slot-copies`, `ma-any-slot-copies`); a struct without `any`
  slots copies exactly as before.
* **Cost.** Cheap: one analysis, no new kind of fact.

### VS-2. A struct literal in an exclusive position does not demand its fields

* **Minimal source** (`drivers/memo.bot`, a memoized recursion written
  naturally):

  ```
  struct Steps:
      memo: table::Table
      count: int

  fn steps(memo: table::Table, v: int) -> Steps errors IndexNotFound:
      ...
      Steps {memo: table::put(memo, v, found), count: found}
  ```

  The compact dict's growth helper is the same case: `T {index:
  std::mutable_array::create(...), items: t.items}`.
* **Expected.** A literal returned from a function, entered into a place,
  or passed as a consumed argument is in an exclusive position. Its
  collection-bearing fields are exclusive positions too, so the binding
  they hold is consumed and the function is fresh.
* **Current behavior.**
  * `ExclusivePositions` follows only `ref`, `project` and `call`. A
    literal that holds a parameter or a plain local is therefore not fresh,
    and every caller copies its result.
  * `FreshFunctions` is computed before the read-outs are written. A
    literal whose field *becomes* a copy is fresh after elaboration, but
    callers have already decided to copy.
* **Evidence.** `tools/copies.tcl` on the `memo` driver with `lpa`, N =
  1,000: 8,908 shares, 8,872 detaches, 15,606,418 elements copied, and
  15,642 object allocations. At N = 10,000 it takes 2.7 s natively on the
  baseline compiler. The same algorithm written as a read-only walk
  followed by a threaded insert loop (`drivers/memo2.bot`) takes 12 ms,
  and the Rust reference 2.3 ms.
* **Generality.** Any function that returns a record holding a
  collection: memo results, parse states, builders.
* **Candidate fix.** Two parts:
  * `ExclusivePositions` follows a literal into its collection-bearing
    fields, through nested literals;
  * `FreshFunctions` is computed again once the read-outs are written.
* **Prototyped.** Yes, as commit `6c76947`. Tests:
  * `mv-literal-demand-semantics`: a literal of a parameter the caller
    still uses, of one parameter in two fields, nested, of a local;
  * `mv-literal-demand-copies`.

  Mutants: `literal-fields-not-exclusive` and
  `literal-fresh-before-readouts` (the second is economic).
* **Result.** The memo driver with `lpa` at N = 1,000 goes to 0 shares, 0
  detaches, 0 elements copied and 53 allocations, with the same value.
* **Cost.** Cheap.

### VS-3. A consumed argument read again by a later argument

* **Minimal source** (found by the Robin Hood implementation's first
  draft):

  ```
  placed_from(t, home(h, slots(t)), h, key, value, 0)
  ```

* **Expected.** `t` moves into `placed_from`. `slots(t)` only reads `t`
  (an observed parameter), and the callee runs after its arguments, so no
  write can come between the move and the read.
* **Current behavior.** A later operand reading `t` makes the first
  argument not a last use, so `t` is copied. Per-path last use (VS-1)
  keeps this behavior on purpose: the later operand reads the same path.
* **Evidence.** 1,024 inserts: 9,792 shares, 8,376 detaches, 9.2 M
  elements copied. Binding `i = home(h, slots(t))` first gives 0.
* **Generality.** Any `f(x, g(x))` where `f` consumes `x` and `g` only
  observes it.
* **Candidate fix.** A consumed argument may move when every later operand
  only observes the path: a direct observed-only callee, no context member,
  nothing that may run code that retains the header. This is the converse
  of BUG-1's rule, so the same `ByReference` and `WrittenLater` machinery
  decides it.
* **Prototyped.** No. The workaround (bind the reading call first) is SPEC.md
  section 7, rule 9.
* **Cost.** Cheap, once BUG-1's machinery exists.

### VS-4. A dead copy keeps the backing shared until the collector runs

* **Source.** Share a table, drop the copy, write the original. This is
  the pattern a needless VS-1..3 copy creates.
* **Behavior.** The copy's header holds its `Rc` on the backing until the
  collector frees the header. The next write sees a strong count of 2 and
  detaches, even though nothing can ever read the other header again
  (value-semantics survey, `t11_context_install.bot`).
* **Why there is no runtime fix.** The runtime cannot know that the other
  header is dead without a liveness-aware count, and MUTABLE-ARRAY.md
  forbids runtime ownership state. Eliding the copy statically is the
  fix, which is what VS-1..3 do. The inline-access prototype (CG-1) caches
  "this backing is mine" in the header. Its helper refreshes that cache
  after a collection, so the cost is one slow write per collection, not
  one per write. The copy is not avoided.

### VS-5. One value use of a function costs every direct call a copy

* **Source.** A reader or updater that is also used as a value somewhere
  (`apply(find, t)`).
* **Behavior.** `DirectOnly` is all-or-nothing per function. With one value
  use, the reader's parameter is no longer observed, and every direct call
  inside a mutating loop shares the table: 100 iterations give 100 shares,
  100 detaches and 100,000 elements copied. An updater's parameter is no
  longer consumed: 101 calls give 202 copies (survey `t12`, `t07`).
* **Generality.** Any function a program both calls and passes, for
  example as a callback and as a helper.
* **Candidate fix.** A per-call-site convention, or a clone of the function
  for its value uses. Not prototyped; no table in the experiment uses one
  of its functions as a value.

### VS-7. A nested function capturing a read-out makes a reader copy

* **Minimal source** (`impl/lp.bot`'s `find`, a lookup with a local walk):

  ```
  fn find(t: Table, h: int, key) -> int errors IndexNotFound:
      hashes = t.hashes
      keys = t.keys
      cap = hashes.capacity()
      fn walk(i: int) -> int errors IndexNotFound:
          s = hashes.at(i)
          if s < 0 or s == h and std::mutable_array::at(keys, i) == key:
              return i
          walk(next_slot(i, cap))
      walk(home(h, cap))
  ```

* **Expected.** `find` only reads `t`: `walk` is called only directly and
  never escapes `find`, so its captures are observations within `find`'s
  extent. The parameter is observed-only, and callers hand `t` over
  uncopied.
* **Current behavior.** The capture of `hashes` and `keys` by `walk` makes
  `find`'s parameter not observed-only. Every caller copies the table
  before calling `find`, then writes it, and the write detaches.
* **Evidence.** `tools/attribution.tcl` builds `lp` from 1,024 Int keys,
  then makes 2,000 replacements. It runs `lp` as written, with VS-3's
  workaround (the reading argument bound first), with VS-7's (both walks
  top-level functions taking the table), and with both
  (`results/attribution.txt`). Columns are shares / detaches / elements
  copied:

  | `lp` variant | baseline: build | baseline: replace | VS-1 + VS-2 tree: build | VS-1 + VS-2 tree: replace |
  |---|---:|---:|---:|---:|
  | as written | 13,488 / 7,344 / 9.22 M | 25,488 / 9,344 / 13.3 M | 7,368 / 7,344 / 9.22 M | 13,368 / 9,344 / 13.3 M |
  | no VS-3 | 10,648 / 4,496 / 5.31 M | 22,648 / 6,496 / 9.41 M | 4,504 / 4,480 / 5.31 M | 10,504 / 6,480 / 9.40 M |
  | no VS-7 | 10,416 / 7,344 / 9.22 M | 16,416 / 9,344 / 13.3 M | 4,296 / 4,296 / 5.88 M | 4,296 / 4,296 / 5.88 M |
  | no VS-3, no VS-7 | 6,144 / 3,072 / 3.36 M | 12,144 / 5,072 / 7.46 M | **0 / 0 / 0** | **0 / 0 / 0** |

  So natural `lp`'s copies are exactly VS-1, VS-3 and VS-7:
  * the per-path tree removes VS-1's share;
  * the two workarounds remove the rest;
  * with VS-1 fixed but VS-7's closure kept, the 2,000 replacements still
    copy (replace minus build: 6,000 shares and 2,000 detaches);
  * without the closure, they copy nothing.
* **Generality.** Any reader written with a local helper over the fields
  of a collection-bearing parameter, which is the ordinary way to write a
  search.
* **Candidate fix.** A capture by a nested function that is called only
  directly (no value use) and does not escape counts as an observation of
  what it captures. That needs the nested function's escape fact, which
  hir/escape.tcl computes for other purposes. Moderate cost. Not
  prototyped. The workaround is SPEC.md section 7's rule 3: readers are
  top-level functions taking the table.

### VS-6. Copies are invisible

Nothing reports an inserted copy: there is no diagnostic and no warning.
Only the HIR text (`mutable_vector#share`), the NIR (`mvshare`) and the
allocation counters show it. A warning would need the compiler to prove
that the copy is avoidable, which is AGENTS.md's bar for warnings. A
"where are the copies" report (like `native::roots`) needs no proof, and
it is what the experiment's `tools/copies.tcl` was written for. Candidate:
a `-explain-copies` listing in main.tcl, or a Compilerpedia page on the
SPEC.md section 7 rules. Not prototyped.

### BUG-1. An argument read by reference saw a later argument's write

The per-path prototype found a real miscompilation, older than this
experiment, while widening the move rule. The elaboration hands some
arguments over uncopied although they are not their path's last use:

* the argument of an observed-only parameter;
* a native argument whose ownership role does not keep it;
* a collection operation's receiver.

That relied on "the callee reads it while the caller waits", but a call
runs *after* its later arguments, and those could change the header first.
Every backend agreed on the wrong values:

```
obs2(v, grow1(v, 5))     33, not 23
v.at(pop1(v) - 7)        IndexNotFound, not 9
obs2(v, v.pop())         12, not 22
v.at(v.pop() - 7)        IndexNotFound, not 9
at(c.values, bump())     1, not IndexNotFound   (bump mutates the context member)
```

Commit `9c79b28` fixes it. Such an argument counts as a later use for the
operands after it. It is copied itself when a later argument of the call
mutates the same place, or, for a context member, calls anything that may
run code. The commit's test is `mv-cow-by-reference-arguments`, and its
mutants are `byref-earlier-ignored`, `byref-later-write-ignored`,
`byref-context-call-ignored` and `byref-place-copied`. This entry is a
correctness bug, not pressure, and it should land whatever is decided
about the rest.

---------------------------------------------------------------------------

## Proofs

The bounds of `std::mutable_array::at`/`set` are decided by
`hir::completions::IndexBounds`, which is open-world and pattern-based
(PROOF-FACT-CENSUS.md). A proven call lowers to a `*proven` opcode that
has no error edge, so its function can stop being `may_error` and its
callers can drop their completion checks.

The census of `lpa` with Int keys (`tools/nirstats.tcl`) shows that **no
table operation in any implementation is proven today**:

| function | ops | effects |
|---|---|---|
| `table::find_from` | `mutarrayget=2 ieq=1 veq=1 call=3` | `may_error=true may_gc=true` |
| `table::get` | `mutarrayget=2 hash=1 call=1` | `may_error=true may_gc=true` |
| `table::store` | `mutarrayset=3` | `may_error=true may_gc=false` |
| `table::put` | `mutarrayget=1 mutarrayset=1 hash=1 call=8` | `may_error=true may_gc=true` |

The same holds for examples/stdlib/hashtable.bot (13 checked gets, 15
checked sets) and csv_records.bot (13 and 13). In both files, the only
proven sets are `counts.set(0|1, 0)` on a capacity-2 allocation.

### CP-1. An index reduced by the container's own size

* **Minimal source.** `a.at(h.mod(a.capacity()))`, or `a.at(bit_and(h,
  a.capacity() - 1))` after `if a.capacity() < 1: return`.
* **Expected.** `mod` is Euclidean and returns only when the divisor is not
  0, so `0 <= r < |D|`. With D a size of `a`, r is an index of `a`. And
  `0 <= x & m <= m` for any `m >= 0`.
* **Current behavior.** `hir::range::Mod` gives the interval `[0, M-1]`.
  With a size as the divisor that is `[0, 2^62-2]`: an interval, never "less
  than capacity(a)". `bit_and` with `capacity(a) - 1` gives nothing at all
  (the mask may be -1). Only a constant capacity under a local `create(16,
  ...)` proves.
* **Generality.** Every hash-indexed or modular array access: ring buffers,
  open addressing, bucket arrays, rotations.
* **Candidate fix.** One rule in `IndexBounds` (`ReducedIndex`). It covers
  `mod(X, D)` with D's form one of the container's size forms, and
  `bit_and(X, M)` with `M + 1`'s form a size form and `M >= 0` proven. No
  power of two is required: that matters only for distribution. A
  container of known size 0 keeps its KNOWN-ERROR.
* **Prototyped.** Yes, as commit `e0b7b9c`. The commit includes:
  * tests: `bounds-reduced-*`, accepted and rejected shapes: another
    container's size, size + 1, an unrelated divisor, a mask without
    m >= 0, the size itself as the mask, the empty container;
  * `bounds-nir-reduced-index` and `bounds-values-agree-reduced`, the
    latter on four backends with negative and beyond-word indices;
  * golden ports;
  * Compilerpedia `proof.list-bounds`, whose stale "a proven call still
    performs its bounds check at run time" is corrected;
  * the new `audit/bounds-proofs/` fuzzer and mutants.
* **Result.**
  * The survey's shapes q1, q1d, q2, q3, q5, p4, p5 and p6 are proven, and
    each proven call lowers to the existing `*proven` opcode with no
    lowering change. The rejected shapes stay rejected, and each of the
    fuzzer's eleven unsound T1-type shapes has an input that really
    fails.
  * The fuzzer also found a sound shape the first version missed: a
    caller passing an exact empty List to a guarded callee. That is
    commit `a137676`: a known size below a proven minimum is a
    contradiction, the same reading IndexBounds already gives two
    disagreeing known sizes.
  * Elsewhere in the repository, nothing changes. Across the 54 programs
    of examples/ and bench/, plus a loader for each lib module, the NIR
    opcodes and per-call verdicts are identical before and after, because
    that corpus was written around the old prover. In the tables, the
    only new proof is the bench driver's own miss-pool read,
    `std::list::at(pool, mod(j, std::list::length(pool)))`.
  * In `lpmask`, the table written for the rules (every index reduced by
    its array at the access), every access becomes proven:
    `mutarraygetproven`/`setproven` throughout, and `store`, `counted`,
    `moved`, `shifted` and `empty_from` lose `may_error`
    (`tools/nirstats.tcl lpmask`). The lookups keep `may_error` through
    `hash` and generic `==` (CO-4).
  * Generality beyond tables: the 2048 workload's `empties.get(roll.mod(count),
    default)`, whose default never happens, can now be written as a proven
    `empties.at(roll.mod(count))`; so can ring buffers.
* **Cost.** Cheap: intraprocedural, and the forms already exist.

### CP-2. A guard on a computed local

* **Minimal source.**

  ```
  j = i + 1
  if j < 0 or j >= a.capacity():
      return d
  a.at(j)
  ```

* **Current behavior.** `BranchRelation` recorded a guard's upper bound only
  when the guarded value's alias chain ended at a parameter or a loop
  variable. A computed local chases to its defining expression, so the
  guard and the read keyed different things (PROOF-FACT-CENSUS.md's G12).
* **Generality.** Every "compute an index, check it, use it" in any
  program.
* **Candidate fix.** One key for relations and lookups (`RelationKey`): the
  binding, or the defining expression a computed local's chain ends at.
  This is sound because the binding is single-assignment, and a relation
  lives only in the scope that proved it.
* **Prototyped.** Yes, as commit `b1144fe`, with tests (one-sided with a
  possibly negative local, another container's size, the inline form, a
  guard whose loop scope ended), golden ports and Compilerpedia.
* **Result.** Proven. An index written inline twice (in the guard and in
  the read) is two expressions and stays unrelated, as it should.
* **Cost.** Cheap.

### CP-3. A field path is a new container each time it is written

* **Minimal source.** `if i < 0 or i >= t.slots.capacity(): return d`, then
  `t.slots.at(i)` or `t.slots.set(i, v)`.
* **Current behavior.** The size atoms keyed a container that is not a
  binding by the one projection expression it ends at, so `t.slots`
  written twice gives two atoms. Binding `s = t.slots` proves a read, but
  `s` is a logical copy: a write through it is not the table's. So **a
  proven write through a field place and an in-place write excluded each
  other**:
  * the guarded-helper workaround `Table {slots: put(t.slots, i, v)}`
    proves the set but copies the array on every write
    (`detachElements 8` per write, survey `w1.bot`);
  * the direct write `t.slots.set(i, v)` is in place but checked.
* **Generality.** Every record that holds an array: tables, grids, buffers,
  the 2048 board (its S9 lockstep loop is proven by the same change).
* **Candidate fix.** Key a projection by its path, `{p KEY FIELD}`. A field
  path names one value however often it is written, because:
  * its root is single-assignment;
  * struct fields are immutable;
  * a MutableArray's capacity is fixed at allocation.
* **Prototyped.** Yes, as commit `a1e281d`, with tests `bounds-field-path-*`
  (index, write, rejected, lockstep) and `bounds-nir-field-path-write`, and
  the Compilerpedia limitation turned into a recognized pattern.
* **Result.** `t.slots.set(i, v)` under a guard on `capacity(t.slots)`
  lowers to `mutarraysetproven` with no share.
* **Cost.** Cheap.
* **Soundness correction (review).** A field path names one value, but a
  `MutableVector`'s length is not fixed: `b.v.push(x)` (or a callee's push
  to a context member) changes it in place. With the path key, two loops
  over `b.v` around a push had one length, and a read of the first loop's
  List at an index proven against the second's lowered to an unchecked
  `listgetproven` past its end. CP-1's reductions reached the same defect
  with a local vector, and the counted-loop and lockstep forms had it
  before both changes. The fix keys a vector's length only when nothing
  can change it: no mutating operation anywhere in the program has a
  receiver with its key (a copy is keyed like its source, so a push on
  either counts) and the key is not rooted at a context parameter. Any
  other vector is measured by its place (binding and field path), which a
  copy's push does not change: a place nothing mutates keeps one length,
  and a loop over any other has the length the vector has at that
  evaluation, shared with the evaluations of the same place that no
  mutation of it -- for a context member, also no call that runs Botlish
  code and no yield -- can come between: consecutive statements of one
  body holding none (`hir::cardinality::Evaluation`). A vector built with
  pushes and then walked twice keeps the proof; two loops with a push
  between them do not. The review's second round found one route no size
  form saw: a mutating operation taken as a value (`p =
  std::mutable_vector::push; p(v, 4)`, or one passed to a function or stored in
  a field) mutated whatever its caller passed, behind the copies the
  elaboration never wrote out for it, so it also broke value semantics
  (`c = v` then changed, on the baseline too). Such an operation is now
  only ever called (`MUTABLE-PLACE-RECEIVER` at the reference). List and
  MutableArray lengths keep their keys (`lpmask`'s NIR is unchanged). The
  cost: two loops over a vector with a mutation of it between them, or,
  for a context's vector, any function call between them are unrelated
  (whether or not the callee can reach the member), and an operation
  that mutates can no longer be a function value (none was, in the corpus
  or the tests); the analysis is computed once per function body and pass,
  so the front end costs what it did before the fix. A second hole of the
  same kind was the interpreter's alone:
  its `listloop` drained any vector it met, so a vector reaching an unmarked
  loop through an `any`-typed path was walked (and emptied) there while the
  other backends raised the loop's TYPE error; it now requires a List like
  them, and only a loop the compiler marks consuming moves a vector's
  elements out (`mv-untyped-loop`). The third round narrowed the
  rule to what soundness needs, recovering sound proofs the second had
  dropped: only an operation that may change a length counts (a swap is
  registered `-keeps-length`); a vector keeps its key's length unless a
  place its own value was copied through is resized (so `u = v;
  u.push(x)` leaves `v` and `w = v` one length); a place is a context
  member by its root, so a local copy `items = log.items` is a place of
  its own; a call is a site of a context member only when it may reach
  the installed context (its callee requires the context, directly or
  through what it calls, it runs or resumes a coroutine, or it is a
  function value given an affine argument, which may carry a handle);
  and the first run of an `if` branch or a handler, entered with no site
  before it, continues the run before the statement (a loop in a branch
  before the branch's own push, a `static compile:` block among them). A
  lockstep diagnostic now records the evaluations it locates as related
  origins. What stays unrelated: two loops with a resize of the vector
  between them on some path, a pop's shorter length read against the
  longer earlier one (a size form states equalities, no order), and an
  operation that mutates taken as a value (rejected, even when its
  receiver is a temporary: telling that apart would need the flow of
  function values).

### CP-4. Facts do not cross a call

* **Minimal source** (`lpa`, as modular code is written):

  ```
  fn home(h: int, cap: int) -> int:
      h.mod(cap)

  fn find_from(t: Table, h: int, key, i: int) -> int errors IndexNotFound:
      stored = t.hashes.at(i)
      ...
      find_from(t, h, key, next_slot(i, slots(t)))
  ```

* **Expected.** `i` is always an index of `t.hashes`: every caller passes
  `home(h, slots(t))` or `next_slot(i, slots(t))`.
* **Current behavior.**
  * `i` is a parameter with no guard. The fact that its arguments are
    reduced by `slots(t)` is in other functions, so `find_from` cannot
    prove the access.
  * A caller's own proof does not travel to its callee either. If the
    callee declares `errors IndexNotFound` (survey q7), the caller must
    handle it, even when its counted loop proves the index.
  * None of CP-1..3 changes this. With all three prototypes, hashtable.bot,
    csv_records.bot and `lpa` gain **zero** proven operations: the index is
    always computed in a helper and passed as a parameter.
* **Consequence.** Every probe step keeps a checked `mutarrayget`, its
  error edge, and `may_error` on every function up the chain.
* **Generality.** All modular code: the cost of a proof is paid by whoever
  computes the index, never by whoever uses it.
* **Candidate fix.** Costly either way:
  * relational result summaries, for example "the result of `home(h, c)`
    is `< c`" plus call-site substitution of `c := capacity(t.hashes)`,
    which would also need CP-5 for the other arrays;
  * HIR-level inlining of small helpers before the completion analysis.

  The source-level workaround is to reduce the index at every access, by
  the array it indexes (`lpmask`): `t.keys.at(bit_and(i,
  t.keys.capacity() - 1))`, one mask per array, because the arrays' equal
  capacities are not known (CP-5). That costs an extra `bit_and` and a
  capacity load per access, which a proof should make unnecessary.
* **Prototyped.** No.

### CP-5. Parallel arrays' equal capacities

`lpa`'s `hashes`, `keys` and `vals` always have the same capacity: they are
created together and never resized. But `capacity(t.keys) ==
capacity(t.hashes)` is a struct invariant that nothing records.
`BranchRelation`'s `==` records only a size equal to an exact Int. Even
a guard `if capacity(t.keys) != capacity(t.hashes): return` proves nothing,
with or without the prototypes (survey `p11.bot`). Candidate: record
size-form equalities at a struct's construction sites, which is
whole-program over the struct's literals. Costly. The alternatives are a
layout with one array per probe sequence, or one `mod` per array.

### CP-6. `std::mutable_vector::at` is never proven

`std::mutable_vector::at` declares `IndexNotFound` but has no `-bounds`
registration (core/mutvec.tcl), so no form proves it, not even
`loop i from 0 to v.length(): v.at(i)`. The compact dict (`cd`) reads its
entries with a checked `mvat` on every probe step. Candidate: a `-bounds`
registration with `length` as the size form. This is cheap for reads. For
writes it is cheap too, because a vector's length changes only through
`push`, `pop`, `take` and `clear` (and, for a context member, any call
that may reach it), so the size form would be invalidated by those calls.
Not prototyped.

### CP-7. A collection's contents cannot bound another's index

The compact dict's invariant `0 <= index[i] < length(entries)` holds by
construction, and it is what makes `ekey.at(index.at(i))` safe. Nothing in
the proof system can state a fact about a MutableArray's *elements*.
Recorded; not a candidate: it would need invariants over mutable storage.

### CP-8. The binary-search midpoint

`sorted`'s probe is `mid = shift_right(lo + hi, 1)` with `0 <= lo <= hi <=
length(keys)`. Two facts are missing:

* that `lo <= mid < hi` when `lo < hi`, which is relational;
* that `lo + hi` stays small. With `collection-length` ranges `[0,
  2^62-1]`, the sum may exceed a small Int, so `ishr` is the generic
  helper instead of a raw shift.

The second is cheap: the sum of two collection lengths fits 63 bits. The
first is moderate: an averaging rule in the relational prover. Parallel
key and value Lists have no length relation either (CP-5's List form).
Not prototyped.

---------------------------------------------------------------------------

## Lowering and code generation

### CG-1. Every MutableArray access is a helper call

* **Source.** `t.hashes.at(i)`, `t.vals.set(i, v)`,
  `t.hashes.capacity()`, proven or not.
* **Current behavior.**
  * `rt_mutarray_get`, `_set`, `_capacity`, `_get_proven` and
    `_set_proven` are out-of-line Rust helpers.
  * `MutArrayObj` holds an `Rc<[Value]>` and a start offset, not words at
    fixed offsets, so codegen cannot load a slot.
  * A proven access saves only the `NO_VALUE` check (about 0.5 ns for a
    get, 2 ns for a set).
  * Compare `ListObj`, whose `len`/`ptr` are at fixed offsets, so
    `listgetproven` is a bare load.
* **Evidence.** The native-ops survey's variant table: `capacity` 3.5-4.0
  ns, `at(table, 5)` 4.9-5.6 ns, against an iteration baseline of 1.2 ns.
* **Generality.** Every MutableArray program: matrices, buffers, the
  2048 board, typed-array builders.
* **Candidate fix.** Header words that the runtime keeps current and
  generated code reads. They are PTR (the first slot), LEN, and UNIQUE
  (nonzero only while the backing is this header's alone). UNIQUE may be
  stale only towards 0:
  * construction and a detach set it from the counts;
  * `share_backing`, the one place a backing gains a holder, clears it;
  * every runtime write's entry refreshes it from `Rc::get_mut`.

  Inline `capacity` is one load. Inline `at` is the small-Int tag test, an
  unsigned compare against LEN and a load; the proven form is the load
  alone. Inline `set` adds the UNIQUE test, then one store. A shared
  backing or a bad index goes to a cold block that calls the old helper.
  The store allocates nothing and is no safepoint. The header grows to 48
  bytes, and the UNIQUE offset is in the AOT image's ABI fingerprint.
* **Prototyped.** Yes, as commits `0bd45ff`, `11fe677` and `243455f`
  (MUTABLE-ARRAY.md). The validation
  covered:
  * the MutableArray, MutableVector, affine, construction and hashtable
    test files, normally and under GC stress;
  * the stub linker, and every Rust unit test under GC stress;
  * `audit/mutable-array/tools/fuzz.tcl`, five seeds plus one under GC
    stress (0 disagreements), and the hash-table fuzzer on four backends
    (540 checks, 0 failures);
  * eight native mutants, all killed. Two of them are new:
    `share-keeps-unique-native` and `detach-keeps-stale-pointer-native`.
* **Result** (1M-iteration loops, best of 7, the old and new binaries
  interleaved):

  | loop body | before | after |
  |---|---:|---:|
  | `capacity(a)` | 3.12 ns | 1.13 ns |
  | `at(a, 0)` | 6.60 ns | 1.57 ns |
  | proven walk `at(a, i)` | 12.05 ns | 3.24 ns |
  | `set(a, i, v)` | 9.34 ns | 1.29 ns |
  | read-modify-write | 17.41 ns | 2.26 ns |
  | step with capacity | 21.79 ns | 2.70 ns |
  | `swap` (still a helper) | 17.76 ns | 11.73 ns |
  | `at(a, i.mod(1024))` | 85.0 ns | 78.9 ns (the `mod` dominates: CG-2) |

  For the tables, see HASH-TABLE-EXPERIMENT.md, "Compiler experiments".
* **Cost.** Moderate: a runtime representation change with a cache
  invariant, but no new semantics.

### CG-2. `mod` is always a fallible, allocating helper

* **Source.** `h.mod(cap)`, `mod(i + 1, cap)`.
* **Current behavior.**
  * NIR `imod` always becomes `rt_int_mod`.
  * It is fallible (ARITHMETIC on a zero divisor), so a `brif` follows
    every call.
  * It is classed as allocating, so it is a GC safepoint: its function is
    `may_gc`, and every caller roots its live values and keeps stack maps.
  * There is no raw form, although the raw table has iadd, isub, imul,
    comparisons, shifts and the bitwise ops.
  * There is no constant-divisor or power-of-two strength reduction.
  * Tiny-leaf inlining (TINY-EXACT-LEAF-INLINING.md) excludes `imod` on
    purpose, so `home` and `next_slot` stay calls (CO-1).
* **Evidence.** `i.mod(1024)` costs 5.6 ns per iteration against 1.3 for
  `bit_and(i, 1023)`. `lpa`'s `home` and `next_slot` are `may_gc=true`.
  NATIVE-RESULT-BOUNDS.md already names "a raw `imod`" as the fix for
  hashtable boxing.
* **Generality.** Every `mod` in every program: modular arithmetic,
  cycles, ring indices, calendar code.
* **Candidate fix.** Four general rules, each selected by facts the range
  analysis already has:
  1. raw `rimod` and `rimodtotal` when both operands are proven small.
     The remainder of two small Ints is small, so the op never allocates
     and is no safepoint. It is `srem` with the fix-up `r < 0 ? r + |d| :
     r`. `rimodtotal` is used when the divisor's Range excludes 0. `rimod`
     adds an inline zero test whose cold branch calls the helper, so the
     ARITHMETIC error is unchanged;
  2. a divisor proven to be exactly +-2^k is a mask (`riand`, or the
     tagged `iand`). This is correct for negative and BigInt dividends,
     because the low k bits of a two's-complement Int are its residue;
  3. an inline both-small fast path in the tagged `imod`; only a BigInt or
     a zero divisor calls `rt_int_mod`;
  4. tiny-leaf inlining (CO-1) admits a `mod` whose divisor's Range
     excludes 0, the same shape of proof `LeafShiftSafe` gives a shift.
* **Prototyped.** Yes, as commits `71e4be1`, `3b9f42c`, `3c2bfc4` and
  `2b6a055`, merged. Validation:
  * `tests/native-mod-lowering.test` (NIR forms, effects, values on four
    backends, the zero-divisor error, a GC-stress loop);
  * `codegen::euclid_mod_tests` (the JIT'd forms over a grid of operands
    against `rem_euclid`);
  * a new differential fuzzer, `audit/mod-lowering/tools/fuzz.tcl`. It
    compares interp, compile, cranelift, cranelift-generic and native
    with each of three optimizations off. Seed 1 ran 300 programs and
    seed 1001 ran 80 under GC stress, with 0 disagreements, and it
    catches planted bugs;
  * 24 Tcl test files, also through `tests/local.tcl`, and under GC
    stress where they touch roots.
* **Result.** These are callgrind instruction counts per iteration, which
  are deterministic:
  * `i.mod(1024)` 78 -> 26 (a mask: the same as the empty loop);
  * `i.mod(1000)` 78 -> 37;
  * `i.mod(n)` 81 -> 34;
  * `i.mod(capacity(t))` 98 -> 61;
  * `at(t, hash(i).mod(capacity(t)))` 580 -> 543 (the hash dominates).

  In examples/stdlib/hashtable.bot, `ht_probe_start` and `ht_probe_next`
  become `rimod`: not `may_gc`, no safepoint, no root slots. stdlib/web.bot's
  percent-encoding (`b.mod(16)`) becomes a mask. `bench/uri-steady.bot`
  runs 1.9 % fewer instructions.

  **`lpa`'s own `home` and `next_slot` stay the tagged op** (now with the
  fast path, still a safepoint), for two reasons:
  * some callers pass a hash read back from a `MutableArray[int]`, whose
    element Range is unknown;
  * a capacity's Range is `[0, 2^62-1]`, so the divisor may be 0.

  The per-operation instruction counts of the tables fall by 2-19 %
  (`lpmono` str-short miss: 581 -> 470).

  A fact "capacity >= 8", the table's own invariant, would make these
  `rimodtotal` and inlinable. That fact is CP-5's kind of struct
  invariant.
* **The facts it trusts.** The mask, `rimodtotal` and the leaf rule read
  the divisor's Range with no runtime check, so an unsound Range is now a
  wrong value or a SIGFPE where the tagged `imod` used to be right. A
  review found two such Ranges, both from hir/induction.tcl and both older
  than CG-2 (they had misled branch decisions on the baseline):
  * the proof read only the self *tail* calls, so a non-tail self call
    (`x = f(i + 3, 2)`) was a way into the instance it never saw;
  * an `==` bound that is a native call with a registered Range
    (`std::char::scalar_value(c)`) was taken as stable whatever its argument,
    so a `c` recomputed every step was a different bound each time.

  Both are fixed in the proof, not the lowering: every self call is a step
  of the proof (the same step or none, inside the guard's continuing side),
  and a call bound must be determined by arguments that are themselves
  invariant -- unchanged parameters, context parameters, fields of them,
  structs, `if` values and closures built from them, and bindings from
  outside the function only when every self call runs the same closure (a
  self call through a parameter can reach another closure, with another
  captured bound) -- through natives classified repeatable or registered
  `-mutation-stable` (an array's capacity, which no mutation changes)
  (PROOF-FACT-CENSUS.md, F.2). `tests/hir-range.test` and
  `tests/native-mod-lowering.test` have the reproducers, and the fuzzer
  generates both shapes (a non-tail self call; a varying or invariant
  native bound, checked against a model at 1114112 calls deep).
* **Cost.** Cheap.

### BUG-2. A divisor beyond 64 bits aborted the front end

`hir::range::Mod` computed `max(abs($dmn), abs($dmx))` over the divisor's
Range bounds. In Tcl 9.0.1, `max()` and `min()` abort the process (`free():
invalid pointer`) when an argument is a BigInt that the same expression
computed: `abs()` of a bound below -2^63, a negation, or a sum. So any
program containing `mod(x, 0 - 100000000000000000000)` crashed the
compiler on the baseline.

The CG-2 work found it: its fuzzer had to avoid such divisors. Commit
`19bd2ff` computes the magnitudes in separate expressions, and the
regression test is `tests/hir-range.test` range-lattice-8 (the unfixed
tree aborts on it). This was the only `max()` or `min()` over computed
BigInts in the front end; the others take variables or small Ints. The
Tcl bug itself is like the `incr` one in AGENTS.md: it is in the Tcl
core, outside this repository.

### CG-3. cranelift-generic cannot lower an untyped struct projection

examples/stdlib/hashtable.bot, compiled as it is (`fn ht_size(table) ...
table.counts`), is NATIVE UNSUPPORTED struct-shape on cranelift-generic:
the projection's receiver has type `any`, so its slot is not statically
known. The specialized backend compiles it, so the existing prototype
(`ht0`) runs on three backends, not four. This is a backend coverage gap;
no fix is needed for the experiment, because typed parameters avoid it.

---------------------------------------------------------------------------

## Existing runtime helpers

### RO-1. `hash` allocates

* **Current behavior.** `rt_hash` hashes an Int or a UnicodeChar as the
  FNV-1a of its canonical decimal text. It formats that text with
  `to_string()`, which is one malloc and free per hash: valgrind counts
  100,055 allocations for 100k `hash(7)` calls, against a baseline of 55.
  A BigInt is cloned, then formatted (4 mallocs). A struct clones its
  shape's name and its field-name `Vec<String>` on every call (6 mallocs
  for two fields, 10 nested).
* **Consequence.** On Int keys, `hash` costs 26-30 ns of a 42 ns
  `hash(k).mod(cap)` plus `at` probe, about 70 % of it. That makes it the
  largest single cost of an Int lookup.
* **Generality.** Every hash of an Int, a char or a struct: sets, maps,
  dedup, memo keys.
* **Candidate fix.** Write the decimal text into a 40-byte stack buffer:
  * a small Int as i64, a BigInt of at most 128 bits through `to_u128`, a
    code point as a u32;
  * a struct borrows its shape inside `current_program`'s closure.

  The bytes, and so every hash value, are unchanged, with core/hashing.tcl
  as the reference.
* **Prototyped.** Yes, as commit `4bc7c94`. Tests:
  * unit tests against the previous implementation kept as a reference;
  * `hash-parity-kinds-1`: 87 values at the native representation's edges
    agree on four backends.
* **Result.**
  * hash(i) 29.7 -> 19.2 ns; hash(7) 24.6 -> 11.0; a code point 27.4 ->
    14.3;
  * a two-field struct argument 133.6 -> 37.3, a nested struct 233.5 ->
    70.0;
  * 0 Rust heap allocations per hash for every Int up to 128 bits, every
    code point and every struct.

  Strings and enums are unchanged.
* **Cost.** Cheap: a local runtime change with identical output.

The FNV byte loop itself (about 0.75 ns per byte) and the decimal text
encoding are the specification (`core::hashing`). A faster hash for Ints,
such as a multiplicative mix of the word, would change every hash value
and every iteration order that depends on one. That is a language
decision, outside this milestone (HASH-TABLE-EXPERIMENT.md, "Hash
quality": FNV's distribution is not the problem).

---------------------------------------------------------------------------

## Specialization and optimization

### CO-1. Small helpers stay calls on every probe step

* **Minimal source.** `fn next_slot(i: int, cap: int) -> int: mod(i + 1,
  cap)` and `fn slots(t: Table) -> int: t.hashes.capacity()`. Both are
  called once per probe step from `find_from`.
* **Current behavior.** Tiny-leaf inlining (native/lower.tcl
  `LeafInlineEligible`) takes bodies of at most 8 ops from `iadd isub imul
  ilt ile igt ige ieq iand ior ixor ishr ishl`. `imod` is excluded ("no
  existing error-safety proof"), and so is any helper call. There is no
  general inliner.
* **Evidence.** `table::find_from` has `call=3` per step (`next_slot`,
  `slots`, the self-tail call) and is `may_gc=true`, because
  `next_slot`'s `imod` is a safepoint. `lpmono`, the same algorithm
  inlined by hand with the capacity hoisted, has `call=1`.
* **Consequence.** A call costs about 1.5-2.5 ns plus spills. `lpa` against
  `lpmono` is the measured difference (HASH-TABLE-EXPERIMENT.md,
  "Abstraction-cost experiments").
* **Generality.** Every accessor wrapper in every program; the corpus
  hashtable.bot's `ht_probe_next` has the same shape.
* **Candidate fix.** With CG-2's raw `rimod`, the `next_slot` and `home`
  bodies become leaf-eligible (that prototype's state B). Accessor
  wrappers need inlining of a `structget` plus one helper, or, with CG-1,
  of two loads.

### CO-2. Pure helper calls are never CSE'd or hoisted

`std::mutable_array::capacity(t.hashes)` is called on every probe step of a
loop that never changes `t.hashes`. A helper call clobbers caller-saved
registers, Cranelift treats it as reading and writing all memory, and NIR
has no CSE of pure natives. Yet `capacity` is fixed for an array's
lifetime, so the value is loop-invariant by construction. With CG-1 it is
a load from the header, which Cranelift's own GVN can reuse. CG-1's
inline `set` stores in the slots' alias region, so it does not invalidate
a header word already loaded.

### CO-3. Untyped slot storage costs generic equality in every instance

* **Source.** `struct Table: keys: mutarray` (`lpa`) or `struct Entry:
  key: any` (`chain`), then `t.keys.at(i) == key` in the String instance.
* **Expected.** `streq` (or `ieq`) where the instance's key type is known.
* **Current behavior.** A struct field's type is the declaration's. Structs
  have no type parameters, and specialization keys a function's
  parameters, never the element type held in a field. The element read
  from an untyped array is `any`, so `==` lowers to `veq` (`rt_value_eq`,
  fallible) in every instance. Typing the array (`lpstr`:
  `MutableArray[str]`) gives `streq`.

  An element of a raw `mutarray` cannot be narrowed to a struct type at
  all. The chain implementation's first draft got "argument for parameter
  "b" cannot be proven to satisfy List[Entry] (argument type: any)", so
  containers of structs must be typed.
* **Consequence.** Measured as `lpa` against `lpint` and `lpstr`
  (HASH-TABLE-EXPERIMENT.md, "Typed against generic").
* **Generality.** Every generic container written in Botlish.
* **Candidate fix.** (Taken: TRAIT-CONSTRAINED-IMPRINTED-TYPES.md's
  parameterized structs; its typed-storage probe compares String and Int
  keys with `streq` and `ieq`.) This is not a proof. One option is generic struct
  declarations, a language feature outside this milestone. The other is
  specialization of a struct-typed parameter's field element types from its
  construction sites, which is whole-program, like the instance entry facts.
  Costly.

### CO-4. hash and generic equality have no total siblings

`hash` is fallible (EQUALITY for callables), and `veq` is too. So every call
has a `brif` to the error exit and makes its function `may_error`, even when
`hir::types::IsEqualityTotal` holds for the argument's type. That proof is
the one `setcontainstotal` already uses
(M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md). Candidate: `hashtotal` and
`veqtotal` opcodes selected by the same proof, following M3's pattern.
Cheap; not prototyped. On its own it removes only a branch, but together
with CP-1..4 it would let a lookup be `may_error=false`.

### CO-5. Collecting loops and empty literals allocate

* **Source.**
  * `loop k from 0 to std::list::length(b): std::list::at(b, k)` on a one-element `b`
    allocates 3 objects (`listnew`'s empty List, a ListPlan, the
    materialized List), where `[x]` allocates 1.
  * `x = []` allocates a fresh List on every evaluation.
* **Consequence.**
  * `chain`'s replacement costs 4 objects: an Entry plus 3.
  * `chain0`'s membership test is written as the 15-puzzle study wrote it
    (`loop other in bucket: if other != b: continue; other`, then
    `.length() > 0`). It allocates 4 objects per lookup:
    `tools/copies.tcl chain0` counts 12,122 objects in hit mode against
    4,122 for the build, over 2,000 lookups.
  * The sorted table's collecting loops copy about 2.3 times their
    output, and none is presized.
* **Candidate fix.**
  * A static empty List constant.
  * A collecting loop whose result is only measured (`length() > 0`)
    compiled as an early-exit search, or the idiom answered by a library
    `any?` that does not allocate.
  * A capacity hint for collecting loops of known trip count.

  Moderate; not prototyped.

### CO-6. Struct keys are hashed and compared through materialized objects

`==` on structs is `rt_value_eq` over two materialized structs. Building a
struct that was virtual costs `structnew`: 2 mallocs and a safepoint.
`hash` of a struct materializes it too. A Point key built in a loop
therefore allocates on every query: in the native-ops survey's
`eqstruct.bot`, that is 95 ns per iteration, 1M Struct allocations and 45
GC cycles. RO-1 removes the shape cloning (a two-field struct's hash goes
from 133.6 to 37.3 ns) but not the materialization. Candidate: a
field-wise `==` and a field-wise `hash` for a statically known shape.
Moderate; not prototyped.

### CO-7. Native lowering of a large List literal is quadratic

The constant-membership experiment's tables are module-level List
literals: the perfect-mod table, the direct table, the sorted array.
Lowering them natively costs far more than their length:

| strategy, set size | literal elements | front end | native lowering |
|---|---:|---:|---:|
| int-dense `list`, 1,024 | 1,024 | 0.6 s | 0.9 s |
| int-dense `pmod`, 512 | 3,840 | 1.9 s | 7.7 s |
| int-sparse `pmod`, 256 | 5,218 | 3.0 s | 15.1 s |
| int-sparse `pmod`, 512 | 15,531 | 8.3 s | 172.8 s |
| int-dense `pmod`, 1,024 | 17,280 | 7.3 s | 180.3 s |
| int-sparse `pmod`, 1,024 | 62,949 | -- | killed: 10.5 GB resident, out of the container's memory |

The front end grows about linearly; native lowering about quadratically.
A threefold longer literal takes 11.5 times as long, and the 62,949-element
table ended the first membership run. The cause was not investigated
(NIR lowering, the NIR text, or Cranelift's function size). Any
compiler-generated constant table depends on it, as would a perfect hash
of a large literal set, and so does a large literal written by hand.
`tools/membership.tcl -data-limit` (default 16,384 elements) keeps the
experiment's tables below it. Moderate cost to fix; not prototyped.

### CO-8. A long equality chain exceeds the front end's nesting limit

`x == c1 or x == c2 or ... or x == c1024` does not compile: "too many
nested evaluations (infinite loop?)". `or` lowers to nested `if`s, and the
front end's recursive walks hit Tcl's nesting limit somewhere between 512
terms (which compile) and 1,024 terms (which do not). Long chains are
costly well before the limit. The `length` strategy for 512 String
literals is a dispatch on the length, then an equality chain per length.
Its front end took 21.7 s for 25.7 KB of machine code. At 1,024 literals
the front end's process grew to 14 GB and was killed. This matters for
constant membership: a compiler that selects an equality chain for small
sets never generates one this long, but source written that way, or a
macro-like expansion of a literal set, fails rather than compiling slowly.
Cheap to fix: an iterative walk, or `or` chains flattened in the lowering.
Not prototyped.

---------------------------------------------------------------------------

## Runtime pressure

Brief section 34 asks for the operations that stay awkward or expensive
*after* the compiler work, catalogued apart from the deficiencies above.

### RT-1. A probe primitive

* **Operation needed.** Find the slot holding a key, or the empty slot that
  ends its probe sequence, in a linear-probing table of stored hashes:
  `find_from` and `empty_from`.
* **Why ordinary Botlish pays for it.** Each step pays:
  * two checked array reads (CG-1, CP-4);
  * a `mod` (CG-2);
  * two calls (CO-1);
  * generic equality (CO-3).

  So a step costs several helper calls where a compiled loop costs a load,
  a compare and an increment.
* **Smallest plausible primitive.**
  `std::mutable_array::probe_linear(hashes, keys, h, key) -> int`. It runs the
  whole probe sequence in Rust and returns the slot. The table's policy,
  layout, growth and deletion stay Botlish.
* **Runtime and GC implications.** It allocates nothing, is no
  safepoint, and is fallible only through `==`. It fixes one probe
  discipline (linear, stored hashes, -1 for empty) into the runtime. Robin
  Hood, quadratic probing and tombstones would each need their own
  primitive.
* **Other users.** None outside open addressing. It is not a general
  operation.
* **Prototype.** `lpp.bot`, with
  `audit/hash-table/patches/probe-primitive.patch` applied. It is
  registered in core/mutarray.tcl (Tcl `probeLinear`), lowered as
  `mutarrayprobe` and implemented in Rust as `rt_mutarray_probe`. It
  passes the fuzzer on four backends (144 checks).
* **Measured improvement** (HASH-TABLE-EXPERIMENT.md, "Runtime
  experiments": ladder C2, median of three alternating rounds, and
  callgrind):
  * on the baseline compiler, against `lpa`: 2-41 % off lookups and
    builds (Int hit 65.9 to 57.1 ns, String miss 69.9 to 41.5 ns);
  * on the merged tree, against the modular `lpa`: 3-28 %;
  * against the proof-shaped `lpmask`: 0-10 %. That is nothing on Int
    builds, 4-6 % on Int lookups, about 10 % on String lookups and Point
    hits, and 1 % on Point misses (Int hit 37.5 against 39.9 ns, 492
    against 496 instructions; Point miss 103 against 104 ns).

  The compiler work removed the same per-step costs the primitive
  removes. What is left is CO-1, CO-2 and CO-3, which would help every
  table and every other program. Verdict: not justified.

### RT-2. A runtime-owned table

The experiment did not build one: brief section 1 says not to "simply
implement a complete Rust hash map and compare it to Botlish". Its ceiling
is the Rust reference's `std` (SipHash) and `stdb` (`std::HashMap` driven
by Botlish's hash) columns. HASH-TABLE-EXPERIMENT.md, "Recommended
division of labor", weighs it against the measured gap that remains after
CG-1, CG-2, RO-1 and the proofs.

### RT-3. A keyed hash

* **Operation needed.** A hash that someone choosing the keys cannot
  predict. It has the same contract as `hash` (equal values hash equal
  under one key), with a key a table draws when it is made.
* **Why ordinary Botlish cannot express it.**
  * `hash` is a fixed, public function of the value: FNV-1a over a kind
    tag and a canonical text (core/hashing.tcl), the same in every
    process. Every table written in Botlish is built on it.
  * A table can mix a secret salt into `hash(x)` afterwards. That
    permutes the slots of keys whose hashes differ, but keys with equal
    64-bit hashes stay together under every salt, and FNV-1a collisions
    are cheap to construct offline.
  * Only a keyed function of the canonical bytes resists that, and those
    bytes (an Int's decimal text, a struct's field encoding) are the
    runtime's. No Botlish source can reach them.
  * Botlish also has no wrapping 64-bit arithmetic to write such a
    function in. The same gap keeps `hash` itself a native
    (core/hashing.tcl's header).
* **Measured consequence.**
  * `int-collide` (SPEC.md section 5) uses keys found by black-box search
    whose hashes are 0 mod 1,024. Every open-addressed table degrades to
    a scan of one cluster: 2.8-9.0 µs per hit at 1,024 keys on the
    baseline compiler (2.4-4.5 µs on the merged tree) against 70-90 ns,
    and builds become quadratic (HASH-TABLE-EXPERIMENT.md, "Key types").
  * Chaining degrades least (1.05 µs on the baseline, 0.95 µs merged).
    Rust's `std::HashMap`, with SipHash and a per-process random key,
    takes 10.9 ns on the same keys.
* **Smallest plausible primitive.** `hash_keyed(x, k)`: SipHash-1-3, or a
  comparable keyed function, over the same canonical bytes `hash` walks.
  A table would draw `k` at `fresh` from a process-wide random source.
* **Runtime and GC implications.** None beyond `hash`'s: the same walk,
  allocation-free since RO-1. The cost is semantic:
  * hash values, and the iteration order of any table built on them,
    would differ from run to run;
  * the backends would agree only for equal keys;
  * an API that exposes slot order would have to stop doing so, or sort.
* **Other users.** Every hash-based structure that takes untrusted keys,
  such as parsers of request parameters (stdlib/web.bot).
* **Prototype.** None. Whether `hash` is seeded, and whether iteration
  order is part of the semantics, are decisions for the hash
  specification that core/hashing.tcl defers ("seeding/collision-
  hardening policy") and for a Set/Map API. The measurement is what they
  should weigh. A compact dict (`cd`) iterates in insertion order whatever
  the hash, so choosing it would decouple the two decisions.

---------------------------------------------------------------------------

## Found by the adversarial review of the prototypes

After the five prototypes were merged, a review workflow tried to break
each one with targeted programs (HASH-TABLE-EXPERIMENT.md,
"Correctness"). An independent verifier reproduced every finding. Each
fix was made in its own branch, with tests and mutants, and checked by
two more verifiers, one hunting unsoundness and one hunting regressions.

| ID | what went wrong | cause | fixed in |
|---|---|---|---|
| AR-1 | a reduced index (`mod(h, length(zs))`, the mask form too) over one snapshot of a MutableVector proven for another taken after a push: an unchecked read past a List's end | CP-1 reaching an older defect: a vector's length keyed like an immutable value's | merge `a71467d` |
| AR-2 | the same through a field path `b.v` around `b.v.push`, a context member grown by a callee, and a lockstep loop | CP-3's path keys reaching the same defect | merge `a71467d` |
| AR-3 | a counted loop over two snapshots around a push | the same defect, on the baseline too | merge `a71467d` |
| AR-4 | `k = w.d1` moved while `w.d2` shared its header: a write through `k` showed in `w.d2` | VS-1's per-path moves over a share descriptor that skipped `any` slots | `0935cb3` (merge `cd7ba76`) |
| AR-5 | the `any`-slot descriptor itself: a struct copy left `any` slots sharing with the source | older | `0935cb3` |
| AR-6 | a move before `break` or `continue` taken as the binding's last use | older | `3a9f010` |
| AR-7 | a context member passed by reference while a later argument yields | older: a gap in BUG-1's fix | `14a4819` |
| AR-8 | a mutated handler payload binding (`on E details:`) had no entry copy | older | `e687ef5` |
| AR-9 | a mask computed `mod` wrongly, and `rimodtotal` divided by zero (SIGFPE), under an induction fact that ignored a non-tail self call | CG-2 trusting an older unsound fact of hir/induction.tcl | merge `1198a1d` |
| AR-10 | `rimodtotal` SIGFPE under an `==` bound whose native call's argument changed every step | the same | merge `1198a1d` |
| AR-11 | a mutating operation taken as a function value (`p = std::mutable_vector::push; p(v, 4)`) mutated a copy's header too, and hid the mutation from the size forms | older; found by the bounds fix's second review round | `147e543`: such a value is now `MUTABLE-PLACE-RECEIVER` |
| AR-12 | the interpreter's `listloop` drained any vector reaching it through an `any` path, where the other backends raised the loop's TYPE error | older, interp only | `65d48d3` |

The inline-array (CG-1) and hash (RO-1) reviews found nothing.

**Open after the fixes: precision, not soundness.** The bounds fix
measures a MutableVector's length by its place, and loses proofs the
merged prototypes had made:
* two loops over a context's vector are unrelated around any call that
  may reach the context, even one that only reads it;
* a resize in a branch that cannot complete normally (`if c: v.push(x);
  return`) still separates the loops after it;
* a pop's shorter length is not known to bound the longer earlier one: a
  size form states equalities, not order.

The old keying proved them unsoundly in general; soundness does not
require losing them, but keeping them needs a finer analysis than the
fix's. The induction fix
recovers every sound fact the verifiers tried, except bounds over
`hash(s)` and relational bounds. The `mod` lowering still trusts Ranges
without a runtime check. That is by design, so an unsound Range anywhere
else would again be a wrong value or a SIGFPE.

---------------------------------------------------------------------------

## Pre-existing problems found on the way

These problems are not caused by the experiment, and they are not fixed
here:

* **The stdlib-namespaces fuzzer's negative expectations are stale.**
  `audit/stdlib-namespaces/tools/fuzz.tcl` reports 10-13 "negative escapes"
  per seed, identically on the baseline (f496a91). Three shapes expect
  older diagnostics:
  * shape 6 expects 'no function named "at" is visible' and now gets
    MISSING-IMPORT (DIAGNOSTIC-RECOVERY.md);
  * shape 5 now reports KNOWN-ERROR first;
  * shape 2 now reports MISSING-IMPORT.

  The oracle and the backends agree.
* **`audit/collecting-loops/tools/fuzz.tcl` crashes** with a SURFACE SYNTAX
  error from `ImportHeader`, identically on the baseline.
* **The hash-table driver of `lp` had stopped compiling**, when its own
  module started importing `list`: `keys.at(i)` on an untyped parameter is
  ambiguous between `std::list::at` and `std::mutable_array::at`. It is fixed in the
  experiment (explicit `std::mutable_array::at`), and its fuzz runs and 12
  mutants were run again.

