# Exact constants and value-fact propagation

## Outcome

The compiler now keeps what it already knows about a value instead of
collapsing it to a broad type. One small module, `hir/exactvalue.tcl`
(`hir::exact`), answers "is this expression exactly a known value?" from the
HIR alone -- following immutable bindings back to what they construct -- and
three existing consumers read it: ordinary/specialization type inference
(`hir/types.tcl`), the Range analysis (`hir/range.tcl`) and the completion
proof pass (`hir/completions.tcl`).

```
x = ["a", 7]                 list_get(x, 0)   : str          (was any)
i = 1                        list_get(x, i)   : int, == 7    (was any / unknown)
                             list_length(x)   == 3           (was [0, 2^62-1])
y = [["a",1],["b",2]]        list_get(list_get(y, 1), 0) : str
fn f(): xs = ["x", 7]; list_get(xs, 0)     f returns str     (was any)
fn test_name(test): list_get(test, 0)      valid; returns any; test : list
```

What it deliberately does **not** do is equally pinned: no tuple, record or
positional type, no schema inferred from how a parameter is indexed or from
what its callers pass, no fact surviving a join with unknown data, no fact
past a size or depth bound. `test_name` stays legal and stays `any`.

Measured, honestly (all in `audit/exact-value-facts/`):

- **Full regression: interp 2851/2851 and compile 2851/2851** (95 test files;
  baseline 2779/2779 in 94). New: `tests/exact-value-facts.test` (71 cases)
  and one new case in `tests/intrinsic-contracts.test`. Four pre-existing
  expectations changed, each because an argument that used to be `any` is now
  provably known (listed under "Full regression").
- **Benchmark parity**: `bench/bench.tcl -runs 1` exits 0, no `VALUES DIFFER`
  on any of the 8 programs.
- **Canonical corpus effect is tiny, and that is the finding.** Of 73
  `list_get` sites, 59 have an exact (literal) index -- but only **one**
  site in the whole corpus reads a *locally known* List: `bench/uri-steady.bot`
  `list_length(corpus)` is now exactly 4. Zero `list_get` results gain a
  narrower type or an exact fact. Instance labels, NIR of all 8 benchmarks and
  the whole scalar-assembly audit corpus are **byte-identical**.
- **Strict-contract counterfactual: 35 of 35 sites survive.** No cast or
  annotation workaround disappears purely because of exact value facts. The
  positional-record Lists in the corpus (`[field, index]`, `[storage,
  length]`, `[name, deps]`) always reach their `list_get` through a function
  result or a parameter, never as a locally known literal. That is exactly
  the evidence the struct milestone wanted.
- **Compile time**: 903.7 ms -> 870.1 ms over the 17 canonical benchmark and
  stdlib programs (median of 7; within noise, no measurable cost).
- No runtime, representation, root or allocation code changed; no new
  backend op or peephole.

## Motivation

`i = 0; list_get(xs, i)` lost `i == 0` at the type layer (the positional-shape
lookup accepted only a syntactic `const` index), a literal List's contents
were forgotten by ordinary inference (`Unshaped` strips them, so `fn f():
xs = ["x", 7]; list_get(xs, 0)` was `any`), and the Range analysis knew
neither a literal List's length nor its elements. The compiler processes
`["x", 7]` completely -- both element expressions, their types, their
ranges -- and then discarded all of it. This milestone stops discarding
knowledge the compiler already has, without turning Lists into tuples.

## Existing constant/range representation

**Q1. What existed before?** Four partial mechanisms, none authoritative for
aggregates:

| mechanism | domain | where it lives | limits |
|---|---|---|---|
| Range | `{min max ?exact}`: Int interval plus a sorted exact set of at most 32 values; a point range *is* the exact constant | `hir/range.tcl`, per expression per used instance | Ints only; a List/String/Bool expression is `unknown` |
| `known` | 1/0: a call statically decided | `hir/types.tcl` (`Call`), type tests only | no comparisons; not carried by aliases |
| positional shape | `{list ELEM {P0 ...}}`: per-position *types* of one List, at most `shapeLength` = 8 positions, outermost list only | `hir/types.tcl`, specialization inference only (ordinary inference strips it) | index must be a syntactic `const`; no values; no nesting; no alias |
| completion exact facts | exact core values of `const`s and of a List of `const`s (`ctx exact`, `ctx exactList`) | `hir/completions.tcl`, local to the completion proof pass | literals only; not visible to types or ranges |

**Q2. New fact domain, or extend/reuse?** Reuse. There is no new *stored* fact
domain and nothing new in any HIR type. `hir::exact` is a derivation: a pure
function of the HIR that produces, on demand, facts in the vocabulary the
compiler already has -- exact Ints (which become an ordinary Range point),
exact scalar core values (`core::value`, the same domain completions'
`ExactValueOf` uses) and a List fact whose elements are *references to the
element expressions* (whose own types and Ranges are the existing ones).
`hir::range::add/sub/mul`-style arithmetic is not re-implemented; the exact
Int folding is four lines with a magnitude bound (see "Fact bounds").

## Type facts vs value facts

```
Type fact:    x is List[int]             hir::types  (a static type; ordinary
                                          inference and declared annotations)
Value fact:   x is exactly [1, 2, 3]     hir::exact  (this milestone; ephemeral)
Range fact:   i is exactly 0 / 0..2      hir::range  (a Range)
```

They interact -- a value fact yields a type (the selected element's) and a
Range (its exact value) -- but are not interchangeable and no value is ever
encoded in a type. A fact never appears in a HIR type, an annotation, an
intrinsic parameter contract or a public signature. It may be forgotten at
any point; correctness never depends on retaining it.

**Rendering (no tuple-like type forms).** Facts render as facts:

```
type: list                      facts: exact-list[str("x"), int(7)]
                                       exact-list[exact-list[str("a"), int(1)], ...]
                                       int(7)   str("x")   bool(true)
```

`hir::exact::describe` is the only renderer. The pre-existing internal
positional-shape *type* still prints as `list[int, str]` in specialization
views (unchanged, never source-spellable); nothing new prints that way.

## Exact scalar facts

`hir::exact::Of HIR E` returns `{int N}`, `{val V}` (a str, bool, unit or
UnicodeChar core value) or `{list LEVEL SRC...}` or `""`. It follows:

- a `const` (a scalar, or a constant List value);
- a `ref` to an immutable local binding (its one `bind`), or to a scalar
  root constant (`true`, `false`, `unit`);
- `+ - *` of two exact Ints;
- a statically decided call (`known`), `list_length` of an exact List,
  `list_get` of an exact List at an exact index;
- an `if` whose condition is decided (its taken branch), or whose two
  branches are provably the *same* exact value.

Booleans follow the existing branch machinery and add to it: `hir::types`
now decides `==` (both operands exact scalars of one kind: `3 == 3` true,
`"a" == "b"` false, by value never identity, `1 == "a"` undecided) and `< <=
> >=` (two exact Ints), and `KnownOutcome` decides an `if` on an alias of an
exact Boolean or on an exact Boolean element. `not false` and `true and
false` are exact through their `if` lowering. `3 < 4`, `0 + 1`, `not false`
all tested (`ev-ordering-decided`, `ev-simple-arithmetic`,
`ev-not-exact-bool`, `ev-if-alias-bool-decided`).

*Strings.* Exact strings are represented (`str("field")`) and flow through
aliases and projections. No string *operation* is folded (`substring("abc",
1, 2)`, `length("abc")`): the existing machinery has no string constant
evaluator, and the brief makes it optional. Not added.

## Immutable aggregate facts

**Q3. How is an exact immutable List represented?**

```
{list LEVEL SRC...}
   LEVEL  nesting level inside the outermost List of the query (0 = it)
   SRC    {e EXPR}   the value of expression EXPR -- its own type, Range and
                     fact are the element's
          {v VALUE}  a constant core value (an element of a constant List)
```

Sources: a call of the `list` native (a List literal -- the one canonical
constructor the HIR has), `list_append` of an exact List (bounded), a
constant List value (`const list`, e.g. from core IR: same facts, no
dependence on surface syntax), or `list_get` of an exact List at an exact
index whose element is itself a List (nested). Because a SRC is a reference
to an expression the compiler already processed, retaining the fact adds no
new traversal and no copy of any element.

**Q4. Is that representation a type? No.** It is not in `hir::types`, is never
stored on a node, binding or signature, and is not producible from source.
The ordinary type of `["x", 3]` is whatever it always was (`list`;
`[1, 2, 3]` is `List[int]`). Q4 has one honest caveat: the *pre-existing*
positional-shape type `{list ELEM {P0 ...}}` (specialization inference only)
does live in the type lattice. This milestone leaves that mechanism as it
was, except that its index lookup now accepts an exact alias, not just a
literal; nothing new was added to it.

## Fact bounds

| bound | value | rationale |
|---|---|---|
| maximum exact aggregate size | **8 elements** (`hir::exact::maxElements`) | the existing positional-shape bound (`hir::types::shapeLength`): every aggregate fact the compiler has forgets at one boundary |
| maximum nesting depth | **3 List levels** (`maxDepth`) | the existing `aggregateDepth`; a fourth nested List is forgotten |
| query steps | 64 (`maxSteps`) | a cycle or pathological alias chain answers "no fact"; a determinism guard |
| exact Int arithmetic | \|n\| < 2^63 (`maxMagnitude`) | a larger fact is not a useful index; never computes a huge number |

A List past a bound **keeps its ordinary type** (and, from the native's own
metadata, its length range) and **loses the whole exact vector** -- never a
truncated one (`ev-bound-nine-forgotten`, `ev-append-bounded`,
`ev-nested-depth-bound`). Everything is a pure function of (HIR, expression),
so no result depends on traversal order (`ev-order-independent`,
`ev-bound-deterministic`).

**What causes a fact to be forgotten** (`""`): a parameter, a loop element, a
call of a user function, a MutableArray, a join of two different values, a
`list_append` or literal past 8 elements, a fourth nesting level, a
projection out of bounds, magnitude past 2^63, and anything the rules above
do not follow.

## Immutable alias propagation

`i = 0; j = i; k = j` -- `Of(k)` follows each single `bind` (single
assignment is what makes this sound with no flow analysis), so `k` is
exactly 0 at the type layer and the Range layer alike (`ev-alias-chain`);
the same holds for a List (`ev-get-alias-of-list`), a projection bound to a
name (`ev-nested-via-alias`) and module-level bindings referenced from
functions.

## Exact selector/index propagation

**Q5. How is exact index 0 represented?** Three views of one thing: the fact
`{int 0}` in `hir::exact`; a Range point `{min 0 max 0}` in the Range
analysis (`hir::range::point`, already how a literal 0 has always been
represented); and, syntactically, the `const` node. **Where was it lost?**
Only in `hir::types::ShapeResult`, which required `kind eq const` -- an alias
(`i = 1`) or computed index (`0 + 1`, `list_length(x) - 1`) fell back to the
List's element type. It now asks `IntOf` (`ev-get-alias-index`,
`ev-get-computed-index`, `ev-get-index-from-length`). The Range layer
already carried the exact index through aliases.

## list_get from known aggregate

**Q6. How does `list_get` combine aggregate and index facts?** Two
projections, one per consumer, over the same `ListOf`/`IntOf`:

- `hir::exact::ProjectType` (used by `ShapeResult`, ordinary *and*
  specialization inference): exact List + exact in-bounds index -> the
  selected element expression's type. Otherwise the pre-existing rule.
- `hir::exact::ProjectRange` (used by `hir::range::Call` and
  `hir::completions`): the join of the Ranges of the elements the index can
  select (`ExactOf`/interval of the index Range, clipped to the List).

**Q16-Q19.**

```
x = ["a", 7]
list_get(x, 0)      : str,  fact str("a")
list_get(x, 1)      : int,  == 7  (Range [7,7] {7}, fact int(7))
i = 1; list_get(x, i)   : int, == 7
alias y = x; list_get(y, 0)   : str
```

An exact string fact survives (`str("a")`), an exact Int becomes a Range
point, the public function signature stays structural `int` (`ev-fn-return-
exact-internal`). **Q20.** After a join with an unknown List, nothing survives:
`x = if flag(): ["a", 1] else: other()` has no fact, `list_get(x, 0)` is
`any`, its Range unknown (`ev-join-unknown-loses-fact`).

## Unknown/ranged indexes

The Range domain has an exact set (<= 32) and an interval; a ranged index
selects exactly those elements: index in {0, 2} of `[10, 20, 30]` gives
`[10, 30] {10,30}`; indices past the end are dropped (they raise, they return
nothing); an unrestricted valid index gives the join of every element
(`[10, 30] {10,20,30}`). Always sound: any successful read returns some
in-bounds element. No arbitrary finite-integer-set analysis was added
(`ev-ranged-index-join`, `ev-ranged-index-clipped`, `ev-unknown-index-range-
join`). For the *type*, a non-exact index keeps the ordinary element type
(`ev-unknown-index-falls-back`).

## Known list_length

`list_length(x)` of an exact List is a Range point: `[1,2,3]` -> `[3, 3]
{3}`, `[]` -> `[0, 0] {0}`, `list_append(["a"], 7)` -> 2, and an exact
length also feeds exact indexes (`list_get(x, list_length(x) - 1)`).

`list_append` of an exact List with room keeps a bounded exact List;
past 8 elements it forgets the vector. There is no List concatenation native.

## Bounds facts

Known length plus an exact/ranged index classifies a read as in bounds,
out of bounds, or unknown (`hir::exact::BoundsOf`). **No check is
eliminated**: nothing in the pipeline consumes an in-bounds proof for
`list_get` (the native `listget` op always carries its check; an unchecked
variant would be a new backend op, which this milestone excludes), and
there is no static RANGE diagnostic to reuse -- an out-of-bounds read is,
and stays, the run-time `RANGE` error (`ev-oob-keeps-runtime-error`). An
out-of-bounds or negative exact index makes no claim about the result type
(the ordinary element type) and never clamps or wraps.

## Nested projections

`list_get(list_get(y, 1), 0)` is `str` for `y = [["a",1],["b",2]]`, exact
`str("b")`; `list_get(list_get(y, 1), 1)` is exactly 2. Within the depth
bound: three nested Lists project; the fourth is forgotten and reads fall
back to the ordinary type.

## Joins and fact loss

**Q7. When are facts forgotten?** (list above). At joins specifically: an `if`
keeps a fact only when its condition is decided (the taken branch) or both
branches provably produce the *same* exact value (canonical structural
equality of materialized values, `hir::exact::Equal`; never object
identity). Two different exact Lists **do not** become a per-position
product (`ev-join-different-lists-no-fact`). A List returned by a user
function has no fact at the source level (`ev-opaque-call-loses-fact`).

## Function parameter boundary

A parameter never has a fact. `Of` returns nothing for a parameter, and no
pass reads a body's indexing or a caller's arguments to build one
(`ev-param-fact-not-from-body`).

**Q25.** Whether a fact crosses an ordinary function boundary follows the
existing architecture, unchanged: at the source level (semantic inference,
which is what strict checking and intrinsic contracts read) a function
result is its ordinary type -- `pair()` returning `["x", 3]` is `list` and
`list_get(pair(), 0)` is `any`. In specialization instance views the
existing positional shape crosses a call (`pair<generic> -> list[str, int]`,
`f<generic> -> str`), exactly as before. No tuple-like exported contract
was invented. **This is the milestone's main limitation:** the corpus's
positional records are built in one function and read in another, which is
precisely the boundary a value fact does not cross.

## Why test_name remains supported but not tuple-typed

**Q10-Q15.**

```
fn test_name(test):
    list_get(test, 0)
```

10. Does it infer a positional schema for `test`? **No.**
11. Its intrinsic parameter contract: **`test : list`** (inferred, checked --
    from `list_get`'s `-param-types`), nothing more (`ev-test-name-contract-
    is-list-only`).
12. Its result type without stronger provenance: **`any`**, both the
    function's semantic result and the call `test_name(["a", 1])`.
13. Does an exact index alone imply the type of a slot? **No.** The selector
    identifies the slot read, not what an arbitrary List stores there
    (`ev-exact-index-alone-implies-nothing`: `i = 0; list_get(xs, i)` with
    parameter `xs` is `any`, `xs : list`).
14. Does an exact known aggregate + exact index imply the selected element's
    type/facts? **Yes** -- that is the whole milestone.
15. Does the compiler inspect callers to invent slot schemas? **No.**

Inspection of the corpus's own `test_name`/`test_deps` (bench/test-selection.bot):
`tests` is a 14-element literal at top level -- past the 8-element bound, and
in any case it reaches `select_affected`/`test_name` through *parameters*
(`tests`, `test`) and through `list::find`'s result. Exact facts exist only
at the literal (and its aliases); they are lost at the first parameter. The
handler's literal `["<none>", []]` is exact where it is written but is joined
with `list::find`'s `any` result, so `found` has no fact. Their imprecision is
recorded here as evidence for structs, not repaired.

## Intrinsic contract interaction

Exact/range facts sharpen the *facts* the recently added contract inference
already reads, and nothing else:

- `fn f(xs): list_get(xs, 0)` (also via `i = 1; j = i; list_get(xs, j)`)
  requires only `xs : list`, checked (`ev-contract-exact-index-requires-
  list-only`, `ev-contract-alias-index`).
- `scan_while`'s predicate stays `Fn{args: [str], return: bool, errors: []}`
  (`ev-contract-scan-while-unchanged`); the existing 58 intrinsic-contract
  tests pass unchanged except two adjusted for stronger knowledge (below);
  the trusted-vs-checked distinction and the relational stop rule are
  untouched.
- The one visible interaction: an argument read out of a *literal* List at
  an exact index is now exactly known, so it proves a trusted contract its
  value satisfies (`fwd(list_get([1, "ab"], 0))` is accepted for a `Byte`
  contract) and is still rejected when the exact value violates it
  (`ic-trusted-exact-element-proves-contract`).

## No caller-derived record inference

**Q15 / stop condition.** `fn first(x): list_get(x, 0)` called as
`first(["a", 1])` and `first(["b", 2])` keeps `x : list` (`ev-callers-do-not-
infer-slots`). Reported separately, as the brief asks: the pre-existing
instance mechanism gives the specialized instance `first<list[str, int]>` its
*own argument's* shape (an instance value fact, existing behavior, not a
parameter contract); a caller with a different shape gets a different
instance (`ev-callers-instance-fact-reported-separately`,
`ev-callers-mixed-shape-instances`). No call site is read to establish a
parameter's schema.

## Counterfactual corpus methodology

**The corpus described in the brief -- literal `as_int`/`as_list`/`as_str`/
`as_mutarray` cast sites and four proposed annotations -- is not in this
repository** (no `as_*` helper exists anywhere in the tree, in any branch or
in history). What is committed is its mechanical source: the previous
milestone's `variant-all-trusted.patch` (one line: every inferred requirement
treated exactly like a declaration -- seeded, structural, precondition-
bearing, `any` arguments rejected), whose failure set *is* the set of sites
that would need a cast or annotation. This milestone reruns that
counterfactual unchanged and maps each diagnostic to the workaround it
needs by the requirement it reports: `requires int` -> `as_int`, `list` ->
`as_list`, `str` -> `as_str`, `mutarray` -> `as_mutarray`, a callable erased
into a helper -> an explicit annotation. Before this milestone, at HEAD, the
counterfactual rejects **10 of 31 programs, 35 sites**
(`strict-counterfactual-before.txt`, byte-identical to the previous
milestone's committed run once paths are normalized). No canonical or
counterfactual source was edited.

## Strict-corpus before/after

`strict-counterfactual-after.txt` is **identical** to `-before.txt`: 10 of 31
programs, 35 sites, every one *still necessary*. Full table:
`audit/exact-value-facts/out/strict-counterfactual-table.md`.

| category | sites | which |
|---|---:|---|
| resolved by exact value fact | **0** | -- |
| still record-shaped List / struct | 15 | see below |
| still MutableArray | 9 | csv_records 452-453 |
| still generic relationship | 7 | see below |
| still genuine annotation | 4 | see below |
| **total** | **35** | |

By the cast the site needs: `as_int` 11, `as_mutarray` 13 (9 primary + the
`storage`/`dest` slots inside 4 record-shaped sites), `as_list` 6, `as_str`
2, annotation (callable erasure) 3.

## Resolved workaround sites

**None.** Q26: no strict-corpus workaround site disappears. This is not a
failure of the mechanism -- each formerly required cast's operand was checked
individually: it is a `list_get` of a function result, a parameter, a loop
element or a `list::find` result, never of a locally known literal (below).
Where a literal *is* local (the `bench/uri-steady.bot` `corpus`, the
`["<none>", []]` handler literal) the fact is used but does not feed a
strict-contract site.

## Remaining MutableArray failures

Q30, Q34 (9 primary + 4 inside records). MutableArray values lack proper
construction/refinement typing, or MutableArray slots erase type:

- `csv_records.bot:452:20/45/81/99`, `453:32/55/77/100/124`: `ht_get(first,
  ...)`, `ht_size(first)`: `first`/`second`/`presized_first` are
  `list_get(rows, i)` of a List of MutableArray tables (slot erases type).
- inside records (counted under record-shaped): `csv_geometric.bot:52:22`,
  `csv_records.bot:126:22` (`storage` of a `[storage, length]` builder);
  `csv_records.bot:311:29`, `hashtable.bot:226:29` (`newControls` of the
  `[newControls, newKeys, newValues]` record).

Not touched (stop condition: no `MutableArray[T]`, no construction typing).

## Remaining generic-relationship failures

Q33: `list::find` (`source-checks.bot:89:40`, `test-selection.bot:68:31` --
callable erased into a relational helper; `test-selection.bot:71:15` --
`found` is `list::find`'s result), `ht_fold` (`hashtable.bot:362:47`), and
accumulator-returning recursion (`lex-strategy.bot:57:20` -- `chars_of`
returns its caller's accumulator; `csv_records.bot:416:46`, `429:28` -- the
`records` accumulator `csv_parse` returns). `list::any?/all?/none?` do not
reject in this counterfactual (their predicates are relational and left
untyped), but stay untyped for the same reason. Not touched.

## Remaining genuine annotation candidates

**Q31. Which of the four proposed annotations remain necessary? All four.**

| proposed annotation | site | still necessary? | why exact facts do not help |
|---|---|---|---|
| `chars_of` result | `lex-strategy.bot:57:20` | **yes** | `chars_of(s, i, acc)` returns its caller's accumulator: a relational result, not a known value |
| `total_valid tokens` | `lex-strategy.bot:79:63` | **yes** | `tokens` is an untyped parameter; the 8-element top-level literal of the same name is a different binding, and the index `i` is not exact |
| `select_affected tests` | `test-selection.bot:61:26` | **yes** | `test` is the loop element of parameter `tests`; the 14-element literal is past the bound and behind a parameter |
| `esc_bytes bytes` | `lib/web.bot:204:70` | **yes** | `hex_pair(list_get(bytes, i))`: `bytes` is a parameter, `i` is a recursion parameter (not exact) |

Plus `matmul.bot:38:23` (`list_get(a, i)`, an untyped matrix parameter --
homogeneous, not a record). They will be reconsidered after MutableArray and
generic-relationship work, per the source-fence sequence.

## Remaining record-shaped List failures

Q32. Sites whose missing type comes from positional-record Lists (input to
the struct milestone). Each one's `list_get` operand is a function result or
a parameter, never a locally known literal:

- `[field, index]` scan pairs (`scanned = scan_field(...)` /
  `scan_record(...)`, read `list_get(scanned, 0/1)`): `csv.bot:66:28`,
  `81:24`; `csv_chunked.bot:106:28`, `120:24`; `csv_geometric.bot:101:28`,
  `115:24`; `csv_records.bot:172:28`, `186:24` (8 sites, all `as_int`).
- `[storage, length]` builder pairs (`geo_append`): `csv_geometric.bot:
  52:22`, `52:31`; `csv_records.bot:126:22`, `126:31` (4).
- `[newControls, newKeys, newValues]` (`ht_rehash_insert`'s `dest`):
  `csv_records.bot:311:29`, `hashtable.bot:226:29` (2).
- `[name, dependencies]` (`test_deps(test)`): `test-selection.bot:57:16` (1).

**CSV boundary (Q38 / item 38).** Locally known: `csv.bot`'s
`[substring(text, start, index), index]` is exactly a 2-element List *inside
`scan_unquoted`* -- its own two elements have their own types there. Once
returned it is `list` in the caller (`scanned`): "exact projection may
recover the field" holds only in the function that builds the pair, "only
`list` remains" across the boundary, and no schema is reconstructed.

## Corpus-wide fact census

`audit/exact-value-facts/out/census-{before,after}.txt` (31 canonical
programs plus the `lib/*.bot` modules they load; each source location once):

| measure | before | after |
|---|---:|---:|
| `list_get` / `list_length` call sites | 73 / 23 | 73 / 23 |
| exact constants tracked (source locations with an exact fact) | -- | 803 |
| known exact immutable Lists tracked (literals and aliases) | -- | 130 |
| exact-index `list_get` sites | -- | **59** (all literal; **0** derived from an alias or arithmetic) |
| `list_get` result types improved (semantic or any instance) | -- | **0** |
| `list_get` exact result facts improved | -- | **0** |
| known-length results improved | -- | **1** (`bench/uri-steady.bot:35:36`, `list_length(corpus)` = 4) |
| runtime guards/checks removed as a consequence | -- | **0** |

**Q21.** 59 exact-index projection sites. **Q22.** 0 gain a narrower result
type. **Q23.** 0 gain an exact scalar result fact (one `list_length`
does). **Q24.** No runtime check disappears. **Q25.** Only `uri-steady`
benefits, and only in a Range fact (its `mod(i, list_length(corpus))` sees
the exact 4): no generated code changes. High counts were not a goal;
the true count of *locally known* aggregates read at an exact index in the
frozen corpus is zero.

## Generated-code effects

None. Audited three ways (spec item 51): (1) the used-instance labels and
the full NIR text of all 8 canonical benchmarks are identical to the parent
commit (`audit/intrinsic-function-contracts/tools/nir.tcl`); (2)
`native/generate-scalar-audit.tcl` regenerated over the whole audit corpus
is byte-identical to the committed `audit/native-scalar-asm/` (only the
recorded commit hash differs), so every `.asm`, `.vcode` and summary is
unchanged; (3) the parity benchmark agrees on all backends. The new exact
facts therefore change no machine code on the canonical corpus. In programs
with locally known Lists the same facts *would* let existing consumers drop
a `guardbool`/type guard (the semantic type of a `list_get` result is
narrower), exactly as the intrinsic-contract milestone's did; no new
backend peephole was added, and the `hir::escape` virtualization keeps its
own syntactic-`const` index rule (an aliased exact index still allocates the
List, a known missed optimization, not enabled here).

## Compile-time impact

`compiletime.tcl 7` (median of 7 front-end compiles of the 17 canonical
benchmark and stdlib programs): **903.7 ms before, 870.1 ms after** (the
difference is noise; `csv_records` 222.0 -> 226.8 ms, `uri-steady` 114.9 ->
109.5 ms). A query is O(alias chain + element count), lazily, bounded by 64
steps and 8 elements per level; nothing is stored, so no fact grows.

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl                         # interp
LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=compile tclsh9.0 tests/all.tcl    # compile
```

- before (HEAD `0d42355`): interp 2779/2779 (94 files);
- after: interp **Total 2851, Passed 2851, Skipped 0, Failed 0** and compile
  **Total 2851, Passed 2851, Skipped 0, Failed 0**, 95 files: the new
  `tests/exact-value-facts.test` (71 cases: exact scalars/aliases, exact
  selectors, `list_get`/`list_length`/`list_append`, nested projections,
  bounds, joins and fact loss, fact bounds, the `test_name` and caller-pattern
  boundaries, intrinsic-contract interaction, determinism/canonical form,
  a core-IR constant List, exact booleans/equality, backend parity) plus
  `ic-trusted-exact-element-proves-contract`.
- (The interp and compile suites both write temp files into the project
  root, so they must not share a working tree when run concurrently.)

Four existing expectations changed, each *because an argument that used to
be `any` is now exactly known*, each still pinning its original concern with
an argument the compiler genuinely does not know (a helper's result):

- `ic-trusted-any-argument-rejected`, `ic-callable-unknown-rejected`: the
  `any` argument now comes out of `first_of(...)`; read straight out of a
  literal it is exactly `1` / `is_tcl_alpha` and legitimately proves the
  contract (new test above pins both sides).
- `stdlib-string_reverse-not-a-string`: `reverse_chars(list_get([12, "a"],
  0))` is now a compile-time error (`12` is provably not a `str`); the
  run-time-`TYPE` case is kept through a helper.
- `hir-aot-16`: `1 == 2` is decided by two exact Ints and needs no runtime
  support at all (`{{} structural-equality}`, was `{bigint ...}`).

All 31 canonical programs still compile with no diagnostics; `bench/`,
`lib/` and `examples/` are byte-identical to HEAD (the source fence holds).

## Benchmark parity

`tclsh9.0 bench/bench.tcl -runs 1` (native backend built): exit 0, no
`VALUES DIFFER` on any of the 8 programs across interp, compile and
Cranelift. No runtime, GC-root or allocation code changed, so GC stress was
not required.

## Known limitations

- **Facts do not cross ordinary function boundaries at the source level**
  (the dominant reason the corpus does not benefit). Specialization
  instances keep their pre-existing positional result shapes.
- **No fact for parameters, loop elements, user-call results or
  MutableArrays**, by design.
- **List facts are bounded** (8 elements, 3 levels): the 14-element `tests`
  literal and the 16-element `hex_digits` carry none.
- **Strings**: exact strings are facts and compare by value, but no string
  operation is folded.
- **`hir::escape` virtualization** still requires a syntactic `const` index;
  an aliased exact index still allocates. Not changed (no backend work).
- **No consumer of the bounds classification**: no check is eliminated and
  no static RANGE diagnostic exists.
- **`known` on comparisons is new** (`== < <= > >=` of exact operands): it
  prunes the dead branch at the type layer like a decided type test. It
  changed one AOT expectation (`hir-aot-16`) and no canonical program.
- Two different exact Lists deliberately do not join (no per-position
  product); only identical values do.

## Required question index

Architecture Q1-Q9: "Existing constant/range representation" (Q1, Q2),
"Immutable aggregate facts" (Q3, Q4), "Exact selector/index propagation" (Q5),
"list_get from known aggregate" (Q6), "Joins and fact loss" (Q7), "Fact
bounds" (Q8), and **Q9. Are facts deterministic and traversal-order
independent? Yes**: `Of` is a pure function of (HIR, expression) with fixed
bounds, no memo table and no shared state; `ev-order-independent` and
`ev-bound-deterministic` pin it. Boundary Q10-Q15: "Why test_name remains
supported but not tuple-typed". Projection Q16-Q20: "list_get from known
aggregate". Corpus Q21-Q25: "Corpus-wide fact census". Counterfactual
Q26-Q34: **Q27** `as_int` sites remaining: all 11; **Q28** `as_list`: all 6;
**Q29** `as_str`: both; **Q30** `as_mutarray`: all 13; **Q31**: all four
proposed annotations; **Q32** positional-record sites: 15 listed above;
**Q33** generic-helper sites: 7; **Q34** MutableArray sites: 9 primary + 4
inside records.

## Readiness for MutableArray construction/refinement

The failure set is cleaner for the next milestone: 0 sites are explained by
value facts, so the 9 primary + 4 in-record MutableArray sites are exactly
the sites a MutableArray construction/refinement type could address, with no
overlap from this milestone. Note the interaction the MutableArray milestone
will meet: 4 of its 13 sites sit *inside* positional records (`[storage,
length]`, `[newControls, ...]`), so typing the slot will also need the
struct milestone (or a local exact fact, where the record is built and read
in one function) before those go away. `hir::exact` already gives a bounded,
order-independent place to hang "this List holds a freshly frozen
MutableArray" if that milestone wants a value fact for it; it needs no change
to the fact vocabulary beyond a new `{v ...}`/`{e ...}` source kind.

No struct, tuple, record, generic, `MutableArray[T]`, codeTarget or union
type, and no source annotation, was added.
