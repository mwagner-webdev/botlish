# LIST-FLAT-MILESTONE-1.md

`std::list::flat[T](lists: List[List[T]]) -> List[T]`: one level of nesting
removed from an immutable List, in order, eagerly, in time linear in the
number of inner Lists plus the number of elements, on every backend.

It follows FOLD-LOOPS-MILESTONE-1.md, which established folding loops and
showed that a List grown by appending in a fold copies its prefix on every
append. This milestone adds flattening as an independent primitive. It does
not fuse construction, add a builder, or change folds or collecting loops:
iteration, aggregation and construction stay three operations, and the
compiler may later eliminate intermediate representations where doing so
preserves what a program observes.

## Outcome

* `std::list::flat` exists on the interpreter, the Tcl compiler,
  cranelift-generic, cranelift and standalone executables, with one meaning:
  the elements of the first List, then of the second, and so on. Empty inner
  Lists contribute nothing, duplicates stay, deeper Lists stay elements, and
  the argument is evaluated once and left unchanged.
* It is linear, by construction and by measurement: one pass over the outer
  List, one result of exactly the total length, each inner List copied into
  place once. The runtime helper's own cost is 30 to 35 instructions per
  inner List plus a constant, independent of n (callgrind, m = 4 to 65,536;
  the element copies are one slice copy per inner List), and the
  native allocation report shows one List and exactly n element copies for
  every shape measured (section "Performance").
* Its type is `List[T]` for `List[List[T]]`, with the exact length N*M kept
  when the argument states both lengths, exact values followed, refinements
  of the element type kept, and callable contracts preserved. A List whose
  elements are of a known non-List kind is a compile-time TYPE error; `any`
  stays a run-time check, with the same message on every backend.
* Collecting loops and folds compose with it as written, unfused. The report
  measures their costs separately and does not claim the pipelines linear.
* 61 Tcl tests (45 ported to a golden suite), 2 Rust tests, a randomized
  differential fuzzer against an independent Python model, and 25 mutants
  (the milestone's seven required kinds and the static side): all killed.

## The operation

```
std::list::flat([[1, 2], [], [3, 4]])     # [1, 2, 3, 4]
std::list::flat([[], []])                 # []
std::list::flat([[[1, 2]], [[3]]])        # [[1, 2], [3]]
std::list::flat([xs, ys])                 # the concatenation of xs and ys
[[1], [2, 3]].flat()                      # method syntax: [1, 2, 3]
```

For an outer List of inner Lists L1, ..., Lm, the result holds the elements
of L1, then those of L2, and so on; its length is the sum of the inner
lengths. The operation:

1. evaluates its argument once, as every call does;
2. keeps every element's position relative to the others;
3. contributes nothing for an empty inner List;
4. keeps duplicates;
5. removes exactly the outermost level: an element that is itself a List
   stays one element;
6. modifies neither the outer List nor any inner List (the result is a new
   List, independent of them);
7. copies each element as the value it is -- never compared, hashed,
   converted or copied deeply; an element that holds a MutableVector is
   copied as a value, as any List operation copies one;
8. makes the empty List of an empty outer List;
9. runs no callback and has no per-element effect.

There is no depth parameter, predicate, mapping callback, recursive
flattening, `flatMap`, `flatten` or `concatMap`. What other languages call
`flat_map` is a collecting loop whose body makes a List, followed by flat:

```
chunks = loop x in xs:
    expand(x)
std::list::flat(chunks)
```

A loop is never a call argument in Botlish (rule.loop-placement), so the
milestone's `flat(loop x in xs: ...)` is written with the loop bound to a
name first. The semantics are the same: flat receives a completed List and
knows nothing of how it was made.

## Census and the decision

What the operation could reuse:

* **Registration and lowering.** Every List intrinsic is a root native in
  core/lists.tcl. The interpreter and the Tcl compiler call its
  implementation directly (`core::compiler::DirectNativeCall`: no per-native
  code); native lowering maps it to one NIR operation (native/lower.tcl's
  `natives` table), codegen to one helper call (codegen/clif.rs), and the
  runtime implements the helper (native/src/runtime/ops.rs). `byte_store::join`
  (WINDOWS-X86-64-MILESTONE-7.md) is the existing flatten of Bytes and the
  model for the helper's two-pass, one-allocation shape.
* **Representation.** A native List is a header and one boxed slice of value
  words (`ListObj`); `Vm::new_list` makes one from a `Vec` with no further
  copy. A Tcl List is `{list ITEMS}`. Neither needs a new representation.
* **Virtual construction** (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md). A plan
  that reaches flat as its operand is materialized there
  (hir/construction.tcl's "flat-only native operation"), exactly as for any
  native that reads a List; flat's result is an ordinary List. No plan
  machinery was needed or changed: the fusion this would allow is the next
  milestone's.
* **Typing.** The existing List intrinsics state their element types by
  result shapes (`append`, `element`, hir/types.tcl's `ShapeResult`), keep
  `any` dynamic through `-param-types` (the run-time kind contract), and let
  untyped forwarders infer a checked contract. Imprinting (hir/imprint.tcl)
  states `name[T](...)` signatures but holds every argument to the imprinted
  parameter type by proof.

**The decision.** flat is a root native with a new NIR operation
(`listflat`) and runtime helper (`rt_list_flat`), typed as the other List
intrinsics are. An imprint signature
(`{list {list {imprint T}}} -> {list {imprint T}}`) was tried first: it
types literals well, but it rejected `fn g(xs): std::list::flat(xs)` (the
untyped parameter's `any` cannot be proven to be a `List[List[any]]`, and
List admission is invariant), which `append` accepts. So flat uses a result
shape, `{flat 0}`, for its type, and keeps the run-time kind contract `list`
for its argument. The one thing a shape cannot say -- that the argument's
*elements* must be Lists -- is a new registry facet, `-element-kinds`, which
the existing native-kind rule reads (next section). No IR form was added:
core IR and HIR see an ordinary call.

## Typing

* **Result.** `{flat 0}`: a `List[List[E]]` (either level refined or not)
  gives `List[E]`; `List[never]`, or a List of `List[never]`s, gives
  `List[never]`; an element type that is no List's (`any`, the raw `list`
  kind, an imprint variable) gives the native's declared `list`. The element
  type is whatever ordinary joining made it: `[[1], ["a"]]`'s elements join
  to the raw `list`, so its flat is a `list` (of proven length 2: both inner
  lengths are 1); refined element types
  (`List[List[Digit]]` gives `List[Digit]`), named and anonymous structs and
  deeper Lists pass through unchanged. Imprinted functions
  (`fn joined(xss: List[List[T]]) -> List[T]`) and untyped forwarders (each
  call's semantic instance) are typed precisely.
* **Length.** `-result-length {flat 0}`: N inner Lists of one proven length M
  make a List of proven length N*M (`[[1, 2], [3, 4], [5, 6]]` flattens to a
  `List[int]{length: 6}`, and indexing it within that length needs no
  handler). That is the sum of the inner lengths whenever the type can state
  the inner length at all: a List whose inner Lists have several lengths
  states none (their join forgets it), and neither does its flat. No
  dependent or symbolic length was added (LIST-CARDINALITY-REFINEMENTS.md's
  rule: a length is a constant equality fact).
* **Exact values.** hir/exactvalue.tcl follows flat of an exactly known List
  of exactly known Lists (within the existing eight-element bound), so
  `std::list::at(std::list::flat([[1, 2], ["ab"]]), 2)` is a `str` and needs
  no handler. A module binding may retain a flat of structurally known Lists
  (hir/modulebinding.tcl), as it may an `append`.
* **Element kinds.** `-element-kinds {list}` is a run-time contract like
  `-param-types`: the implementation raises TYPE for an element that is not a
  List. `hir::types::NativeKindMismatch`, the one statement of the native-kind
  rule (METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md), now also asks
  `ElementKindMismatch`: an argument that is a List whose element type has a
  known other kind is a mismatch, so the call's own check reports it, the
  call is poison (nothing restates it), and the method decision's kind
  proofs read it -- all through the existing paths:

  ```
  argument 1 of native std::list::flat requires a List whose every element
  is list, but this argument has type List[int]{length: 2}, whose elements
  are int: the call could only fail when it runs
  ```

  A List of a rigid imprint variable (`fn f(xs: List[T]): flat(xs)`) is
  rejected for the same reason a bare one is: not every T is a List. An
  element of no fixed kind (`any`) is checked when the call runs:
  `std::list::flat element 2: expected list, got 2`, the same text on every
  backend (core::value::expect's wording, `RtError::Type`'s format).
* **Callable contracts.** hir/callables.tcl gives flat's argument the typed
  position `List[List[E]]` of its result's element type, so a List of typed
  functions flattens without erasing their contracts (as `append` does).
* **Ownership.** `-ownership {copy-out}`: a List of affine values is
  AFFINE-LIST-OPERATION-UNSUPPORTED, like every element-wise List operation.
  A moving flat would be sound but is a language decision of its own.
* **Invalid input and arity.** `flat(5)` and `flat("ab")` are the ordinary
  native-kind TYPE; arity is the run-time ARITY every native has.

## Implementation, stage by stage

| stage | what flat is there |
|---|---|
| registry (core/lists.tcl) | `std::list::flat -arity 1 -param-types {list} -element-kinds {list} -result-type list -runtime list-alloc -result-shape {flat 0} -result-length {flat 0} -ownership {copy-out}` |
| interpreter, Tcl compiler | `core::lists::flat`: one `lappend result {*}ITEMS` per inner List (amortized linear), the element-kind check, `{list RESULT}` |
| HIR, core IR | an ordinary call of the root native |
| native lowering | `std::list::flat {op listflat}` |
| NIR | `ListFlat` ("listflat"), arity 1, may allocate, may error |
| codegen | one call of `rt_list_flat` (an allocating, fallible helper: a safepoint) |
| runtime | `rt_list_flat`: pass 1 checks each element's kind (TYPE with its position) and sums the lengths with saturating addition; the collection ceiling (`MAX_COLLECTION_LENGTH`) refuses an oversized total as RANGE before anything is allocated; pass 2 extends one `Vec` of exactly that capacity with each inner slice; `Vm::new_list` makes the one heap object |

Garbage collection: the result's allocation may collect first. Everything
flat still reads is reachable through its operand, which generated code keeps
rooted across the call, and the collector does not move objects -- the same
argument `rt_list_append` and `rt_bytes_join` rest on. The Rust test
`list_flat_survives_a_collection_at_its_allocation` builds inner Lists of
heap Strings reachable only through the outer List, collects at every
allocation with freed Lists poisoned, and checks every element afterwards;
`tests/list-flat.test` runs entirely, and its standalone executable runs,
under `BOTLISH_NATIVE_GC_STRESS=1`.

Nothing mutates or reuses a source List: the result is always a new object
(`assert_ne!(r, b)` for a one-List argument), so no accidental uniqueness is
relied on, and no unsafe storage operation was added.

## Complexity

With m inner Lists and n elements in all:

* time O(m + n): pass 1 touches each inner List's header once, pass 2 copies
  each element once (a slice copy per inner List);
* storage: the result's n words and its header, allocated once (`Vec` with
  exact capacity, boxed without reallocation);
* no prefix copied twice, no intermediate List, no per-element allocation;
* empty inner Lists cost their header check only: 65,536 inner Lists of
  which 1,024 are non-empty cost 1.97 million helper instructions, linear in
  m (below).

## Performance

All measurements on this container (Linux x86-64, 4 cores, release native
backend), by `audit/list-flat/tools/measure.tcl`. Instruction counts are
callgrind's per run (the difference of two profiles of the standalone
executable, `audit/bench-bimodality/tools/profile.sh`), deterministic;
allocations and element copies are the native allocation report's. Each
"per flat" figure is the difference between a program that flattens its
input R = 16 times and the same program measuring the input's length
instead, divided by R: input construction cancels.

### A. Flat alone, five shapes, n = 128 to 16,384

| shape | m | n | instr/flat | instr/(m+n) | rt_list_flat/flat | Lists/flat | copies/flat |
|---|---:|---:|---:|---:|---:|---:|---:|
| singletons | 128 | 128 | 7,413 | 29.0 | 4,549 | 1 | 128 |
| singletons | 1,024 | 1,024 | 43,750 | 21.4 | 35,909 | 1 | 1,024 |
| singletons | 4,096 | 4,096 | 247,301 | 30.2 | 143,429 | 1 | 4,096 |
| singletons | 16,384 | 16,384 | 1,058,062 | 32.3 | 573,509 | 1 | 16,384 |
| few large | 4 | 128 | 1,133 | 8.6 | 209 | 1 | 128 |
| few large | 4 | 1,024 | 2,338 | 2.3 | 209 | 1 | 1,024 |
| few large | 4 | 4,096 | 4,775 | 1.2 | 209 | 1 | 4,096 |
| few large | 4 | 16,384 | 175,777 | 10.7 | 209 | 1 | 16,384 |
| many empty | 512 | 128 | 19,025 | 29.7 | 15,469 | 1 | 128 |
| many empty | 4,096 | 1,024 | 135,341 | 26.4 | 123,269 | 1 | 1,024 |
| many empty | 16,384 | 4,096 | 605,804 | 29.6 | 492,869 | 1 | 4,096 |
| many empty | 65,536 | 16,384 | 2,432,376 | 29.7 | 1,971,269 | 1 | 16,384 |
| mixed (0..7) | 37 | 122 | 2,460 | 15.5 | 1,339 | 1 | 122 |
| mixed (0..7) | 293 | 1,018 | 25,018 | 19.1 | 10,139 | 1 | 1,018 |
| mixed (0..7) | 1,170 | 4,089 | 95,349 | 18.1 | 40,284 | 1 | 4,089 |
| mixed (0..7) | 4,681 | 16,380 | 391,839 | 18.6 | 160,974 | 1 | 16,380 |
| structs (8 each) | 16 | 128 | 1,604 | 11.1 | 629 | 1 | 128 |
| structs (8 each) | 128 | 1,024 | 30,840 | 26.8 | 4,549 | 1 | 1,024 |
| structs (8 each) | 512 | 4,096 | 108,887 | 23.6 | 17,989 | 1 | 4,096 |
| structs (8 each) | 2,048 | 16,384 | 545,817 | 29.6 | 71,749 | 1 | 16,384 |

(many empty: 4n inner Lists, one in 64 holding 16 elements.)

* **Linear in m + n.** Instructions per (m + n) stay within a narrow band
  for every shape from n = 128 to 16,384 (a 128-fold growth): 21-32 for
  singletons, 26-30 for many empty Lists, 16-19 for mixed lengths, 11-30 for
  structs. A quadratic implementation would grow them 128-fold.
* **The helper's own work is exactly linear in m.** `rt_list_flat`'s
  exclusive instructions are 209 + 35 per inner List (4,549 at m = 128,
  573,509 at m = 16,384; 30 per inner List for the empty ones), and do not
  depend on n: the element copies are one slice copy per inner List
  (`memcpy`, counted separately).
* **One allocation, n copies, every shape.** The allocation report shows one
  List and exactly n element copies per flat, for 65,536 inner Lists as for
  4; heap-backed elements (structs) are copied as words, never deeply.
* **The two outliers are the measurement's.** Few large Lists at 16,384:
  each flat copies 128 KiB, above glibc's non-temporal threshold, where
  memcpy runs a counted vector loop; below it, callgrind counts a `rep movsb`
  copy as a single instruction, so the smaller rows understate the copy. The
  remainder is one collection triggered by the allocation volume (427,234
  collector instructions per run). Singletons at 128 include the fixed cost
  of the call and the allocation over few elements.

### B. Against the existing ways to build the same List

n elements in n/8 inner Lists of 8; per construction (R = 2, profiles of 1
and 3 runs for the quadratic idioms' sake):

| idiom | n = 128 | n = 1,024 | n = 4,096 | Lists (4,096) | copies (4,096) |
|---|---:|---:|---:|---:|---:|
| `std::list::flat(xss)` | 1,373 | 7,520 | 114,515 | 1 | 4,096 |
| append each element in a fold (repeated prefix) | 94,045 | 2,119,467 | 80,194,264 | 4,097 | 8,386,560 |
| `flat([acc, xs])` in a fold | 24,107 | 468,894 | 10,848,841 | 1,025 | 1,051,648 |
| MutableVector pushes, then a collecting loop | 154,073 | 1,242,412 | 5,182,596 | 1,028 | 14,333 |
| self tail recursion appending (plan registers) | 124,762 | 1,159,880 | 4,758,507 | 4,610 | 8,188 |

* The repeated-prefix baseline copies n(n-1)/2 elements (8,128 at 128,
  8,386,560 at 4,096): its instructions per element grow 735 -> 2,070 ->
  19,579, quadratic. Using flat to append one chunk at a time in a fold
  (`flat([acc, xs])`) is still quadratic in m: flat joins two Lists in
  linear time, but the fold still copies its accumulator once per step.
* The linear idioms (MutableVector, plan registers) build the List in
  1,160-1,270 instructions per element; flat of the completed nested List
  costs 7-28 per element. Flat is the efficient operation only when the
  nested List already exists -- which the next sections price.

### C. Collecting-loop composition

`chunks = loop x in xs: expand(x)` (m = n/8 iterations, each `expand` a
collecting loop of 8 Ints), then `std::list::flat(chunks)`; instructions per
run of the whole function:

| variant | n = 128 | n = 1,024 | n = 4,096 | Lists (4,096) |
|---|---:|---:|---:|---:|
| outer loop of scalars only (`loop x in xs: x * 8`) | 19,912 | 107,250 | 398,070 | 4 |
| outer loop of inner Lists (`chunks`) | 104,520 | 821,074 | 3,483,977 | 1,028 |
| ... then flat | 105,824 | 827,973 | 3,507,764 | 1,029 |
| one loop making the flat List directly (`loop i from 0 to n: i`) | 60,104 | 416,635 | 1,664,513 | 4 |

* **Flat is 0.7% of the pipeline** (+23,787 instructions at n = 4,096, of
  which 17,989 in `rt_list_flat`): one more List, n more copies.
* **The inner Lists are the cost.** Making 512 inner Lists of 8 costs about
  3.09 million instructions (the second row less the first): one plan, its
  materialization and a List per iteration. The outer List is built through a
  plan and materialized once (`construct list flat`, then `op listflat`).
* **What fusion could remove:** the pipeline (3.51 M) against a single loop
  producing the same List (1.66 M) -- the inner Lists' allocations, the outer
  List and flat's copy. That is the next milestone's subject; no number here
  is claimed for it.

### D. The chunk-producing fold

FOLD-LOOPS-MILESTONE-1.md's chunk workloads (audit/fold-loops/workloads/),
the chunks then their flat (instructions per run; element copies from the
allocation report):

| workload | n | chunks only | chunks, then flat | flat's share | copies: chunks | copies: + flat |
|---|---:|---:|---:|---:|---:|---:|
| fold | 128 | 308,660 | 317,850 | +9,190 (3.0%) | 1,513 | +117 |
| fold | 1,024 | 3,428,227 | 3,450,932 | +22,705 (0.7%) | 73,686 | +936 |
| tail recursion | 128 | 215,504 | 212,384 | (collection timing) | 502 | +117 |
| tail recursion | 1,024 | 1,864,006 | 1,885,421 | +21,415 (1.1%) | 4,099 | +936 |

* Flattening the completed chunks adds exactly their element count in copies
  (117 at n = 128, 936 at 1,024) and one List.
* **The fold's own construction is not linear**, and flat does not change
  that: the fold copies 73,686 elements at n = 1,024 (its `done` List is
  appended to, copied each time) against the recursion's 4,099 (its `done`
  parameter is a plan register). The pipeline "fold, then flat" is as
  quadratic as the fold. (At n = 128 the recursion with flat measures fewer
  instructions than without: a collection falls on the other side of the
  profile window; the copies are exact.)

### E. Applicability: uri-steady with List intermediates

`audit/list-flat/workloads/uri-flat.bot` computes bench/uri-steady.bot's
value (29,500: the corpus escaped 2,000 times) by building each text's
output as one `List[Byte]` per character -- the character's byte or its
`%XX` bytes -- in a collecting loop, flattening it, and decoding the bytes
once (`std::abi::bytes::from_list`, `decode_utf8`). It agrees with
`std::web::uri_escape_text` on the corpus, on all four backends.

| program | instructions per run | allocator | allocations | Lists | Strings | element copies |
|---|---:|---:|---:|---:|---:|---:|
| bench/uri-steady.bot (String plans) | 25,839,607 | 25.3% | 10,509 | 6 | 2,000 | 42 |
| uri-flat.bot (byte chunks, flat, decode) | 32,827,072 | 50.2% | 31,594 | 25,558 | 2,008 | 132,809 |

* **Practical, not cheaper.** The List representation works as an
  intermediate construction format: exact, typed (`List[std::byte::Byte]`
  all the way to `from_list`) and on every backend, with no String
  constructor or Unicode rule added. It costs 1.27x the String plans,
  because it allocates a List per character (25,558 Lists for 14,000
  characters, counting each escape's own flat of its parts); flat itself is
  2.7% (873,243 instructions).
* That allocation per chunk is exactly what fusing a collecting loop with
  flat would remove (C above).
* Writing it showed one friction: a List literal's element type is the join
  of its elements' static types, so `[37, digit(h), digit(l)]` is a
  `List[int]` although every element is provably a Byte; the probe uses a
  Byte-returning `percent()`. Not changed here.

### Time

Best of 60 runs in one driver process (JIT compilation excluded), the same
pairs; this shared container's timings vary between passes (the fold-loops
report saw 1.5x), and a difference of two best times below about 10 us is
within that noise -- one row (structs, n = 1,024) even came out negative.
The instruction counts above carry the small comparisons; the times show
the large ones:

| n | flat | append in a fold | flat([acc, xs]) in a fold | MutableVector | tail recursion |
|---:|---:|---:|---:|---:|---:|
| 1,024 | 0.99 us | 275 us | 50 us | 103 us | 78 us |
| 4,096 | 3.99 us | 5,254 us | 601 us | 396 us | 346 us |
| 16,384 | 32.4 us | 156,112 us | 15,635 us | 2,002 us | 1,514 us |

(n elements in n/8 inner Lists; per construction. At 16,384 flat is 4,800
times the repeated-prefix baseline's speed and 47 times the fastest linear
idiom's -- but it starts from a completed nested List, which the others
build.) One flat of 65,536 inner Lists holding 16,384 elements took 289 us;
of 16,384 singletons, 98 us; of 4 Lists of 4,096, 29 us. The collecting-loop
pipeline at n = 16,384: 1,100 us for the loop of inner Lists, 1,325 us with
flat, 625 us for one loop making the flat List directly.

## Compiler economics

* **Code.** About 300 lines of compiler and runtime code, half of them
  comments, over thirteen files; the rest of the change is tests, tools and
  documentation.

  | file | lines (+/-) | what |
  |---|---:|---|
  | core/lists.tcl | +36 | the implementation and registration |
  | core/native.tcl | +42/-3 | the `-element-kinds` facet, the `flat` result shape and length form |
  | hir/types.tcl | +88/-6 | the result shape, the length rule, `ElementKindMismatch` |
  | hir/range.tcl | +17/-1 | the element-kind message |
  | hir/exactvalue.tcl | +28/-1 | exact values |
  | hir/modulebinding.tcl | +18 | module bindings |
  | hir/callables.tcl | +13/-1 | callable contracts |
  | hir/methods.tcl | +1/-1 | a comment (the kind proof's result forms) |
  | native/lower.tcl | +1 | `op listflat` |
  | native/src/nir.rs, codegen/clif.rs | +14/-1 | the operation |
  | native/src/runtime/ops.rs | +38 (+83 tests) | `rt_list_flat` |
  | native/src/runtime/vm.rs | +1/-1 | the collection ceiling made crate-visible |

* **Reused.** Registration, direct native calls in both Tcl backends, the
  native-kind rule and its diagnostics, poison, result shapes, length
  minting, exact values, the construction machinery's materialization of a
  plan operand, `Vm::new_list`, the collection ceiling, the allocation
  metrics.
* **New IR.** One NIR operation and one runtime helper; no HIR node, core IR
  form or analysis pass. Intrinsic recognition is the registry's: flat is no
  special case of specialization (an ordinary native call in a semantic
  instance), of HIR text (a call) or of HIR interchange (a call of a root
  native; the front end's fingerprint covers core/lists.tcl).
* **Analyses.** No whole-program analysis was added. `NativeKindMismatch`
  gained one dictionary lookup per native argument whose kind matches, and
  the result shape is evaluated once per call.

* **Compile time.** The same programs compiled by the front end of the
  tree before this change and of the final tree (`surface::readProgramFile`,
  one process each). Wall-clock time varied by up to 8% between rounds of
  the same tree on this container, more than any difference between the
  trees (one round measured the final tree 2% faster on a suite, the next 8%
  slower). Callgrind's instruction counts of the whole process (loading the
  compiler included) are deterministic:

  | program | before | after | change |
  |---|---:|---:|---:|
  | bench/uri-steady.bot | 3,607,658,262 | 3,620,898,385 | +0.37% |
  | tests/golden/loop-collecting.bot (many whole-program builds) | 43,417,760,449 | 43,653,391,380 | +0.54% |

  The cost is the larger sources and the native-kind rule's one more
  registry field read per checked native argument, in every build a static
  compile block makes (libtcl carries no symbols, so callgrind cannot
  attribute it to Tcl procedures). An earlier version of the rule read the
  field through a procedure call per argument (+0.59%); the final one tests
  it inline. NIR is unchanged for programs that do not call flat (378, 468,
  8,809, 6,276 and 7,759 lines for lex-strategy, uri-steady and the
  loop-collecting, stdlib-namespaces and fold-loops suites, before and
  after).

* **Runtime code.** `rt_list_flat` is 883 bytes of machine code
  (`rt_list_append`: 382; `rt_bytes_join`: 584), and a call site is one helper
  call and its error check. The helper list grew by one entry (the ABI
  fingerprint of the native startup data includes it).

## Tests

* **tests/list-flat.test** (61 tests). Behavioral tests run on all four
  backends and fail unless all agree, run-time error messages included. They
  cover the milestone's examples; empty outer and inner Lists; one inner
  List; singletons; order and duplicates; one level only; flattening twice;
  concatenation; method syntax; every representative element kind (Strings
  with astral characters, Bools, Float64, UnicodeChar, enums, named and
  anonymous structs, unit, BigInts, typed functions, MutableVector values);
  heterogeneous elements; equality and hash of the result; types (int, str,
  structs, nested, `List[never]`, refined elements, joins, the N*M length,
  exact values, an unproven declared length, untyped forwarders, imprinted
  functions); Lists returned from functions; a module binding; every
  diagnostic (a List of non-Lists, a non-List, the method receiver, Strings,
  a rigid variable, a declared result, arity, no cascade, the dynamic
  element, a heterogeneous literal, a forwarder's contract, an affine List);
  evaluation once; sources unchanged and shared; every position; collecting
  loops (empty, singleton, variable, nested, branch-dependent chunks,
  `continue`); the chunk fold (zero, one or several chunks per iteration;
  `break`, `continue`, no iterations); a fold of flat; the representation
  (one `op listflat` and no List operation per element, the loop's plan
  materialized once, the Tcl compiler's direct call, HIR text, interchange,
  core IR text, the registration); linearity, structurally (the allocation
  report: one List of 24 + 8n bytes and exactly n copies for 1,000
  singletons, 4 large Lists and 5,000 empty Lists); large inputs (10,000
  elements, 5,000 empty Lists); a seeded randomized differential (40 nested
  Lists against an independent Tcl model); and a standalone executable,
  plain and under GC stress.
* **tests/golden/list-flat.bot** (45 golden tests, all four backends): the
  source-expressible tests, generated with their fragment and census by
  `audit/list-flat/tools/golden-port.py`. 30 are equal-strength ports (the
  manifest freezes their Tcl tests as duplicates), 13 observe a type by
  admissibility or a rejection by its code only (weaker; their Tcl tests stay
  active), 2 are split. The census classifies the other 16 Tcl tests:
  KEEP-INTERNAL (NIR, the compiler's code, HIR text, interchange, core IR,
  the registry, allocation counts, a join's type text), KEEP-RUNTIME-ONLY
  (ARITY and the run-time TYPE errors, which no handler catches),
  KEEP-MULTI-PROGRAM (the module binding, the executable) and
  KEEP-NOT-EXPRESSIBLE (the generated differential).
* **Rust**: `list_flat_removes_one_level_in_order` (values, one allocation, n
  copies, operands unchanged, a new List for one inner List, the TYPE message
  with its position) and `list_flat_survives_a_collection_at_its_allocation`.
* **audit/list-flat/tools/fuzz.tcl**: random programs of eight cases each --
  inner Lists of Ints (small and past 64 bits), Strings, Bools, Lists of Ints
  and structs, a third of them empty -- built as literals, by method syntax,
  by functions, by collecting loops with branches, by folds that append, as
  three-level Lists flattened twice, and (`-profile large`) by counted loops
  of up to 300 elements around many empty Lists; every backend against
  `oracle.py`, a Python model written from the semantics section.
* **audit/list-flat/tools/mutate.tcl**: 25 mutants (Verification).
* Existing tests whose expectations named the `std::list` members
  (`tests/stdlib-namespaces.test`, `tests/golden/stdlib-namespaces.bot`)
  now list `flat`.

## Verification

On this container (Linux x86-64, 4 cores), on the final tree unless said
otherwise:

* **tests/list-flat.test**: 61 of 61, every behavioral test on all four
  backends; 61 of 61 under `BOTLISH_NATIVE_GC_STRESS=1`.
* **tests/golden/list-flat.bot**: 45 of 45 on interp, compile,
  cranelift-generic and cranelift; 45 of 45 natively under GC stress.
  `audit/golden/tools/perturb.tcl -mode both`: 45 of 45 inverted and 44 of 44
  alterable tests fail as required (`list-flat-empty-outer` expects `[]`,
  which has nothing to alter), and the located test fails at a moved column.
  `merge.tcl -check 1`: the manifest is the census's and the fragments'
  (12,443 rows, 61 new).
* **Narrowed local runs** (`tests/local.tcl`, both passes, front-end cache):
  list-flat, stdlib-namespaces, list-length-refinement,
  method-receiver-types, method-resolution, method-filter,
  diagnostic-recovery, loop-collecting, fold-loops, exact-value-facts,
  typed-callable-escape, static-compile, compilerpedia, golden-duplicates,
  golden, module-static-values, hir-interchange, compilation-isolation,
  hir-cache, affine, aot-stub-linker, system-linker and native-executable:
  every Tcl test passes on interp and compile (512 and 372 Tcl tests per
  pass in the two runs, the golden duplicates skipped), and the golden
  suites they pull in pass on all four backends (16 suites with 789 tests,
  then 10 with 536; the runs overlap). The first run
  failed one test, `stdlib-namespaces.test`'s `ns-qualified-inventory`,
  which pins each namespace's intrinsics: it now lists `flat` (as do
  `ns-unknown-member-*`'s expected message and its golden port).
* **Rust**: `cargo test --release`: 322 library and 117 driver tests pass;
  the two new ones also under GC stress.
* **Fuzzing** (`audit/list-flat/tools/fuzz.tcl`, every program against the
  Python model on all four backends): seeds 1, 2, 3 (100 programs each) and 4
  (60): 0 disagreements; `-profile large` seed 7 (40 programs): 0;
  `-gc-stress 1` seed 11 (30 programs, native backends) and `-profile large
  -gc-stress 1` seed 13 (20): 0. The first large-profile run reported 25
  disagreements, all programs the generator itself broke (a reused variable
  gave two functions one name: DUPLICATE); fixed in the generator, rerun
  clean. `oracle.py selftest`: 7 of 7.
* **Mutation testing** (`audit/list-flat/tools/mutate.tcl`, result in
  `audit/list-flat/mutate-result.txt`): 25 mutants, 25 killed -- the seven
  kinds the milestone asks for in both implementations (inner Lists
  reversed, elements reversed, an empty inner List kept or ending the
  result, two levels removed, an element dropped or duplicated, the total
  miscounted, the result built by copying an expanding prefix), the element
  kind check removed in both, and the static side (the result's type, the
  length as a sum or as the outer length, the element-kind rule off, exact
  values, callable contracts, module bindings, the ownership role, the
  lowering). The two mutants whose output is identical to flat's --
  `rs-quadratic` (O(n*m) copies) and `rs-wrong-total` -- are killed only by
  the structural detectors: `list-flat-linear-copies` (the allocation
  report's element copies) and the Rust test's copy count. The four
  mutants of hir/types.tcl were rerun on the final tree: 4 of 4 killed.
* **The repository's other mutants**: every mutant of every `audit/*`
  mutants file whose edits touch a file this change modified still applies
  (460 edits checked). Two needed new text because the native-kind rule was
  restructured -- method-receiver-types' `imprint-variable-deferred` and
  `equal-kinds-rejected`, each kept a mutant of the same rule -- and both are
  killed (`audit/method-receiver-types/tools/mutate.tcl -only ...`).
* **Compilerpedia**: `tools/compilerpedia.tcl check`: 1,150 topics, 704
  examples run, 0 problems (the three new examples among them).
  `audit/stdlib-census/after.tsv` regenerated.
* **Not run locally**: the full `tests/local.tcl` (the narrowed runs cover
  the files this change touches or that pin what it changes), the warning
  gate (no corpus program changed; `audit/list-flat/workloads/` is not
  corpus), the batched-against-sequential static-decision comparison
  (AGENTS.md: CI only) and the macOS and Windows hosts.
* **CI on the branch** (`claude/upbeat-hypatia-34hk1w`).
  - Commit 24921d9: `static-decisions` over list-flat.bot,
    stdlib-namespaces.bot, loop-collecting.bot and fold-loops.bot (run
    41346014910) and both Icy Tower workflows passed. `tests` (run
    41346012641) failed one test of this change's making on interp,
    compile and both coverage jobs: tests/mutable-array.test's
    `ma-roles-audit`, which enumerates every collection primitive's
    ownership roles and did not yet list std::list::flat's `copy-out`
    (fixed in 9ebe8fc). Its other jobs -- the golden shards, the Rust
    tests, the warning gate, the method-call decision, the stub- and
    system-linked executables -- passed. Windows acceptance failed on
    `ma-roles-audit` too (the same fix) and otherwise, like macOS, only
    where main failed then: Windows on package-manager.test's
    `pm-remove`, `pm-crash-recovery` and `pm-lock-busy`; macOS on `mts-main-process-semantics` and the
    graphical census's 15 process-semantics cases (fixed on main since,
    6d9cbbc), and its acceptance shard 1 at the 75-minute limit (as on
    main; list-flat.test took 6 s of it).
  - Commit dedd743 (the fix, main merged): every job of `tests` (run
    41396991298) passed -- interp, compile, the cranelift and
    cranelift-generic coverage, the four golden shards, the Rust tests,
    the warning gate, the method-call decision and the stub- and
    system-linked executables (GC stress runs on main only).
  - Commit 141ae5e (main merged again): both Icy Tower workflows and the
    macOS graphical census passed; `tests (windows x86-64)` failed only
    package-manager.test's three tests above and package-native.test's
    `pn-unsupported-target` and `pn-view-crash-recovery`, exactly the
    failures of main's own run at PM-2 (1ed72b5, run 41395294901).
    `tests (macos arm64)` for it was still queued when this was written.

## What remains, and the next milestone

* **Flat is linear; its inputs' construction is not.** A collecting loop
  still allocates every inner List and its own outer List, and a fold that
  grows a `List[List[T]]` by appending still copies it on every append (the
  chunk fold above: 73,686 element copies at n = 1,024, against flat's 936).
  Nothing here fuses them.
* **Per-chunk allocation dominates List-as-intermediate code.** The URI probe
  spends half its instructions in the allocator, on one List per character;
  flat is 2.7%.
* **List literals do not refine their element type.** `[37, digit(h)]` is a
  `List[int]` even where every element is provably a Byte: typed
  construction needs Byte-returning helpers (the probe's `percent()`). Not
  changed here.
* **The element requirement is not part of an inferred contract.** An untyped
  forwarder `fn g(xs): flat(xs)` holds its callers to `list` (the checked
  contract), so `g([1, 2])` compiles and fails when it runs; a direct
  `flat([1, 2])` is rejected. A checked contract of `List[list]` would need a
  covariant admission for checked contracts, which List admission is not.
* **Memory.** A result larger than the machine's memory fails as any
  allocation does (the process ends); only a total past the collection
  ceiling is refused first, with the RANGE error (no declared error, so no
  handler catches it), as for every List and String.

The next milestone, as planned: virtual List construction across folding
loops and producer-consumer fusion. The concrete starting points:

1. Self tail-recursive List parameters already carry construction plans
   (`planregs`); fold intermediates carry materialized values, so appending
   in a fold copies. Carrying a plan in a fold's intermediate -- also as a
   List field of a struct intermediate -- needs escape, aliasing,
   control-flow and ownership justification (the intermediate is only
   extended, never observed, until the fold ends).
2. `chunks = loop x in xs: expand(x)` followed by `flat(chunks)` could lower
   to one construction when `chunks` has no other use: each iteration's List
   extended into one plan instead of allocated and copied. The loop table
   above measures what that would remove (the inner Lists' allocations, the
   outer List, and flat's copy).
3. Collecting loops, folds and flat should then share one construction
   mechanism, never three.

None of that is an observable mutation: an immutable List stays immutable,
and every elimination must be proven unobservable.

## Documentation

* docs/README.md: the intrinsics table, the static List typing rules, and
  "Flattening" in section 17 beside "Folding loops" (collecting, folding,
  flattening and their composition).
* docs/INDEX.md; AGENTS.md: "Flattening Lists (std::list::flat)", the
  invariants and what to run.
* Compilerpedia: the generated `stdlib.std::list::flat` page and its note
  (two accepted examples and a rejected one, aliases `flatten`, `flat_map`,
  `concat lists`, ...); `stdlib.module.std::list`, `stdlib.std::list::append`
  (appending in a loop is quadratic; flat joins Lists), `capability.map-filter`
  (no flat_map: a loop, then flat) and `concept.lists` updated.
  `audit/stdlib-census/after.tsv` regenerated.

## Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/list-flat.test
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/list-flat.test
tclsh9.0 tests/local.tcl tests/golden/list-flat.bot
cargo test --release --manifest-path native/Cargo.toml --lib list_flat
python3 -I audit/list-flat/tools/oracle.py selftest
tclsh9.0 audit/list-flat/tools/fuzz.tcl -n 100 -seed 1
tclsh9.0 audit/list-flat/tools/fuzz.tcl -n 40 -seed 7 -profile large
tclsh9.0 audit/list-flat/tools/fuzz.tcl -n 30 -seed 11 -gc-stress 1 -backends "cranelift-generic cranelift"
tclsh9.0 audit/list-flat/tools/mutate.tcl
tclsh9.0 audit/list-flat/tools/measure.tcl
bash audit/bench-bimodality/tools/profile.sh audit/list-flat/workloads/uri-flat.bot 2 6
bash audit/bench-bimodality/tools/profile.sh bench/uri-steady.bot 2 6
```
